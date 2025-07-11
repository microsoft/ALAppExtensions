// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using System.Utilities;
using System.IO;
using Microsoft.Purchases.Vendor;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;

/// <summary>
/// This codeunit executes a single step of the import process, it can be configured with the step to run, whether to undo the step or not, and the E-Document to process.
/// </summary>
codeunit 6104 "Import E-Document Process"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    Permissions =
        tabledata "E-Document" = m;

    trigger OnRun()
    var
        EDocumentLog: Codeunit "E-Document Log";
        NewStatus: Enum "Import E-Doc. Proc. Status";
        ImportProcessVersion: Enum "E-Document Import Process";
    begin
        EDocument.Get(EDocument."Entry No");
        Clear(EDocumentLog);

        ImportProcessVersion := EDocument.GetEDocumentService().GetImportProcessVersion();
        if ImportProcessVersion = "E-Document Import Process"::"Version 1.0" then begin
            ProcessEDocumentV1(EDocument, EDocImportParameters, Step, UndoStep);
            exit;
        end;

        NewStatus := GetStatusForStep(Step, UndoStep);
        EDocumentLog.SetFields(EDocument, EDocument.GetEDocumentService());
        EDocumentLog.ConfigureLogToInsert(Enum::"E-Document Service Status"::Imported, NewStatus, UndoStep);

        if UndoStep then
            UndoProcessingStep(EDocument, Step)
        else
            case Step of
                Step::"Structure received data":
                    StructureReceivedData(EDocument, EDocumentLog);
                Step::"Read into Draft":
                    ReadIntoDraft(EDocument);
                Step::"Prepare draft":
                    PrepareDraft(EDocument, EDocImportParameters);
                Step::"Finish draft":
                    FinishDraft(EDocument, EDocImportParameters);
            end;
        EDocument.Get(EDocument."Entry No");

        // If the processing step has not inserted the log entry, we insert it.
        if EDocumentLog.GetLog()."Entry No." = 0 then
            EDocumentLog.InsertLog();

        EDocumentProcessing.ModifyEDocumentProcessingStatus(EDocument, NewStatus);
        EDocumentProcessing.ModifyEDocumentStatus(EDocument);
    end;

    local procedure StructureReceivedData(EDocument: Record "E-Document"; var EDocumentLog: Codeunit "E-Document Log")
    var
        EDocumentDataStorage: Record "E-Doc. Data Storage";
        FileManagement: Codeunit "File Management";
        EDocErrorHelper: Codeunit "E-Document Error Helper";
        IStructuredDataType: Interface IStructuredDataType;
        IStructureReceivedEDocument: Interface IStructureReceivedEDocument;
        IFileFormat: Interface IEDocFileFormat;
        NameWithoutExtension: Text;
        Name: Text[256];
    begin
        EDocument.TestField("Unstructured Data Entry No.");
        EDocumentDataStorage.Get(Edocument."Unstructured Data Entry No.");
        IFileFormat := EDocumentDataStorage."File Format";

        // If previous parts of the process have not specified how to structure the data, we take the preferred one for the file format.
        if EDocument."Structure Data Impl." = "Structure Received E-Doc."::Unspecified then
            EDocument."Structure Data Impl." := IFileFormat.PreferredStructureDataImplementation();

        IStructureReceivedEDocument := EDocument."Structure Data Impl.";
        IStructuredDataType := IStructureReceivedEDocument.StructureReceivedEDocument(EDocumentDataStorage);

        if EDocument."Structure Data Impl." <> "Structure Received E-Doc."::"Already Structured" then begin
            AttachUnstructuredDataAsAttachment(EDocument, EDocumentDataStorage.GetTempBlob());
            IFileFormat := IStructuredDataType.GetFileFormat();
            NameWithoutExtension := FileManagement.GetFileNameWithoutExtension(EDocumentDataStorage.Name);
            Name := CopyStr(NameWithoutExtension + '.' + LowerCase(IFileFormat.FileExtension()), 1, 256);
            EDocumentLog.SetBlob(Name, IStructuredDataType.GetFileFormat(), IStructuredDataType.GetContent());
            EDocumentLog.InsertLog();
            EDocument."Structured Data Entry No." := EDocumentLog.GetLog()."E-Doc. Data Storage Entry No.";

            if IStructuredDataType.GetReadIntoDraftImpl() = Enum::"E-Doc. Read into Draft"::ADI then
                OnADIProcessingCompleted(EDocument, EDocumentDataStorage);

            if EDocument."Structured Data Entry No." = 0 then
                EDocErrorHelper.LogWarningMessage(EDocument, EDocument, EDocument.FieldNo("Structured Data Entry No."), NoStructuredDataErr);
        end
        else
            EDocument."Structured Data Entry No." := EDocument."Unstructured Data Entry No.";

        // If the conversion into structured data specifies a method to read into draft, it will take precedence over the one specified in the E-Document (which could have been set f. ex. by the implementation of receiving the document).
        if IStructuredDataType.GetReadIntoDraftImpl() <> "E-Doc. Read into Draft"::Unspecified then begin
            if EDocument."Read into Draft Impl." <> "E-Doc. Read into Draft"::Unspecified then
                Session.LogMessage('0000PIW', 'Read into Draft implementation overwritten', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', 'E-Document');
            EDocument."Read into Draft Impl." := IStructuredDataType.GetReadIntoDraftImpl();
        end;

        EDocument.Modify();
    end;

    local procedure ReadIntoDraft(EDocument: Record "E-Document")
    var
        EDocumentDataStorage: Record "E-Doc. Data Storage";
        FromBlob: Codeunit "Temp Blob";
        IStructuredFormatReader: Interface IStructuredFormatReader;
    begin
        if EDocumentDataStorage.Get(EDocument."Structured Data Entry No.") then
            FromBlob := EDocumentDataStorage.GetTempBlob();

        // If at this point the E-Document does not have a Read into Draft implementation, we take the one specified by the E-Document service
        if EDocument."Read into Draft Impl." = "E-Doc. Read into Draft"::Unspecified then
            EDocument."Read into Draft Impl." := EDocument.GetEDocumentService()."Read into Draft Impl.";
        IStructuredFormatReader := EDocument."Read into Draft Impl.";

        EDocument."Process Draft Impl." := IStructuredFormatReader.ReadIntoDraft(EDocument, FromBlob);
        EDocument.Modify();
    end;

    local procedure PrepareDraft(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters")
    var
        Vendor: Record Vendor;
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        IProcessStructuredData: Interface IProcessStructuredData;
        VendNo: Code[20];
    begin
        IProcessStructuredData := EDocument."Process Draft Impl.";
        EDocument."Document Type" := IProcessStructuredData.PrepareDraft(EDocument, EDocImportParameters);

        VendNo := IProcessStructuredData.GetVendor(EDocument, EDocImportParameters."Processing Customizations")."No.";
        if VendNo = '' then begin
            EDocumentPurchaseHeader.GetFromEDocument(EDocument);
            VendNo := EDocumentPurchaseHeader."[BC] Vendor No.";
        end;

        if VendNo <> '' then begin
            if Vendor.Get(VendNo) then begin
                EDocument."Bill-to/Pay-to Name" := Vendor.Name;
                EDocument."Bill-to/Pay-to No." := Vendor."No.";
            end;

            OnFoundVendorNo(EDocument, VendNo);
        end;
        EDocument.Modify();
    end;

    local procedure FinishDraft(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters")
    var
        IEDocumentFinishDraft: Interface IEDocumentFinishDraft;
    begin
        IEDocumentFinishDraft := EDocument."Document Type";

        // Clean up / reset E-Document fields
        EDocument."Document Record ID" := IEDocumentFinishDraft.ApplyDraftToBC(EDocument, EDocImportParameters);
        EDocument.Modify();
    end;

    local procedure UndoProcessingStep(EDocument: Record "E-Document"; Step: Enum "Import E-Document Steps")
    var
        EDocumentHeaderMapping: Record "E-Document Header Mapping";
        IEDocumentFinishDraft: Interface IEDocumentFinishDraft;
    begin
        case Step of
            Step::"Finish draft":
                begin
                    IEDocumentFinishDraft := EDocument."Document Type";
                    IEDocumentFinishDraft.RevertDraftActions(EDocument);
                    Clear(EDocument."Document Record ID");
                    EDocument.Modify();
                end;
            Step::"Prepare draft":
                begin
                    EDocumentHeaderMapping.SetRange("E-Document Entry No.", EDocument."Entry No");
                    EDocumentHeaderMapping.DeleteAll();
                    Clear(EDocument."Bill-to/Pay-to Name");
                    Clear(EDocument."Bill-to/Pay-to No.");
                    EDocument."Document Type" := "E-Document Type"::None;
                    EDocument.Modify();
                end;
            Step::"Structure received data":
                begin
                    EDocument."Structured Data Entry No." := 0;
                    EDocument.Modify();
                end;
        end;
    end;

    local procedure ProcessEDocumentV1(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters"; Step: Enum "Import E-Document Steps"; UndoStep: Boolean)
    var
        EDocImport: Codeunit "E-Doc. Import";
        CreateJournalLineV1: Boolean;
    begin
        // V1 documents do not have a distinction between the different steps (e.g. structure, read, prepare, finish),
        // we only consider the step "Finish draft", which calls the previous logic to import.
        if Step <> Step::"Finish draft" then
            exit;

        if UndoStep then begin
            EDocumentProcessing.ModifyEDocumentProcessingStatus(EDocument, "Import E-Doc. Proc. Status"::Unprocessed);
            EDocumentProcessing.ModifyEDocumentStatus(EDocument);
            Clear(EDocument."Document Record ID");
            EDocument.Modify();
            exit;
        end;

        case EDocImportParameters."Purch. Journal V1 Behavior" of
            EDocImportParameters."Purch. Journal V1 Behavior"::"Inherit from service":
                CreateJournalLineV1 := EDocument.GetEDocumentService()."Create Journal Lines";
            EDocImportParameters."Purch. Journal V1 Behavior"::"Create journal line":
                CreateJournalLineV1 := true;
            EDocImportParameters."Purch. Journal V1 Behavior"::"Create purchase document":
                CreateJournalLineV1 := false;
        end;
        EDocumentProcessing.ModifyEDocumentProcessingStatus(EDocument, "Import E-Doc. Proc. Status"::Processed);
        EDocImport.V1_ProcessEDocument(EDocument, CreateJournalLineV1, EDocImportParameters."Create Document V1 Behavior");
    end;

    internal procedure ConfigureImportRun(EDocument: Record "E-Document"; NewStep: Enum "Import E-Document Steps"; EDocImportParameters: Record "E-Doc. Import Parameters"; NewUndoStep: Boolean)
    begin
        this.EDocument := EDocument;
        Step := NewStep;
        UndoStep := NewUndoStep;
        this.EDocImportParameters := EDocImportParameters;
    end;

    procedure IsEDocumentInStateGE(EDocument: Record "E-Document"; QueriedState: Enum "Import E-Doc. Proc. Status"): Boolean
    begin
        EDocument.CalcFields("Import Processing Status");
        exit(StatusStepIndex(QueriedState) <= StatusStepIndex(EDocument."Import Processing Status"));
    end;

    procedure StatusStepIndex(Status: Enum "Import E-Doc. Proc. Status"): Integer
    begin
        case Status of
            Status::Unprocessed:
                exit(0);
            Status::Readable:
                exit(1);
            Status::"Ready for draft":
                exit(2);
            Status::"Draft ready":
                exit(3);
            Status::Processed:
                exit(4);
        end;
    end;

    procedure IndexToStatus(Index: Integer; var Status: Enum "Import E-Doc. Proc. Status"): Boolean
    begin
        case Index of
            0:
                Status := Status::Unprocessed;
            1:
                Status := Status::Readable;
            2:
                Status := Status::"Ready for draft";
            3:
                Status := Status::"Draft ready";
            4:
                Status := Status::Processed;
            else
                exit(false);
        end;
        exit(true)
    end;

    procedure GetNextStep(Status: Enum "Import E-Doc. Proc. Status"; var NextStep: Enum "Import E-Document Steps"): Boolean
    var
        NextStatus: Enum "Import E-Doc. Proc. Status";
    begin
        if not IndexToStatus(StatusStepIndex(Status) + 1, NextStatus) then
            exit(false);
        case Status of
            Status::Unprocessed:
                NextStep := Step::"Structure received data";
            Status::Readable:
                NextStep := Step::"Read into Draft";
            Status::"Ready for draft":
                NextStep := Step::"Prepare draft";
            Status::"Draft ready":
                NextStep := Step::"Finish draft";
        end;
        exit(true);
    end;

    procedure GetPreviousStep(Status: Enum "Import E-Doc. Proc. Status"; var PreviousStep: Enum "Import E-Document Steps"): Boolean
    var
        PreviousStatus: Enum "Import E-Doc. Proc. Status";
    begin
        if not IndexToStatus(StatusStepIndex(Status) - 1, PreviousStatus) then
            exit(false);
        if not GetNextStep(PreviousStatus, PreviousStep) then
            exit(false);
        exit(true);
    end;

    procedure GetStatusForStep(Step: Enum "Import E-Document Steps"; StepBefore: Boolean) Status: Enum "Import E-Doc. Proc. Status"
    begin
        case Step of
            Step::"Structure received data":
                exit(StepBefore ? Status::Unprocessed : Status::Readable);
            Step::"Read into Draft":
                exit(StepBefore ? Status::Readable : Status::"Ready for draft");
            Step::"Prepare draft":
                exit(StepBefore ? Status::"Ready for draft" : Status::"Draft ready");
            Step::"Finish draft":
                exit(StepBefore ? Status::"Draft ready" : Status::Processed);
        end;
    end;

    procedure GetStatusCount(): Integer
    begin
        exit(StatusStepIndex("Import E-Doc. Proc. Status"::Processed) + 1);
    end;

    procedure OpenTermsAndConditions(TermsNotification: Notification)
    begin
        Hyperlink(TermsAndConditionsHyperlinkTxt)
    end;

    local procedure AttachUnstructuredDataAsAttachment(EDocument: Record "E-Document"; FromBlob: Codeunit "Temp Blob")
    var
        EDocAttachmentProcessor: Codeunit "E-Doc. Attachment Processor";
        InStream: InStream;
    begin
        FromBlob.CreateInStream(InStream);
        EDocAttachmentProcessor.Insert(EDocument, InStream, EDocument."File Name");
    end;

    internal procedure AIGeneratedContentText(): Text
    begin
        exit(AIGeneratedContentTxt);
    end;

    internal procedure TermsAndConditionsText(): Text
    begin
        exit(TermsAndConditionsTxt);
    end;

    internal procedure GetStep(): Enum "Import E-Document Steps"
    begin
        exit(Step);
    end;

    [InternalEvent(false, false)]
    local procedure OnADIProcessingCompleted(EDocument: Record "E-Document"; EDocumentDataStorage: Record "E-Doc. Data Storage")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnFoundVendorNo(EDocument: Record "E-Document"; VendNo: Code[20])
    begin
    end;

    var
        EDocument: Record "E-Document";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocumentProcessing: Codeunit "E-Document Processing";
        Step: Enum "Import E-Document Steps";
        UndoStep: Boolean;
        AIGeneratedContentTxt: Label 'Data was read from a PDF - check for accuracy. AI-generated content may be incorrect.​';
        TermsAndConditionsTxt: Label 'Terms and Conditions';
        NoStructuredDataErr: Label 'No structured data is associated with this E-Document. Verify that the source document is in valid format.';
        TermsAndConditionsHyperlinkTxt: Label 'https://www.microsoft.com/en-us/business-applications/legal/supp-powerplatform-preview', Locked = true;
}