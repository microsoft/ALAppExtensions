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

codeunit 6104 "Import E-Document Process"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        EDocLog: Record "E-Document Log";
        EDocImport: Codeunit "E-Doc. Import";
        NewStatus: Enum "Import E-Doc. Proc. Status";
        ImportProcessVersion: Enum "E-Document Import Process";
        CreateJournalLineV1: Boolean;
    begin
        EDocument.SetRecFilter();
        EDocument.FindFirst();

        Clear(EDocumentLog);
        EDocumentLog.SetFields(EDocument, EDocument.GetEDocumentService());

        NewStatus := UndoStep ? GetStatusForStep(Step, true) : GetStatusForStep(Step, false);
        ImportProcessVersion := EDocument.GetEDocumentService().GetImportProcessVersion();

        if ImportProcessVersion <> "E-Document Import Process"::"Version 1.0" then
            case Step of
                Step::"Structure received data":
                    if UndoStep then
                        UndoStructureReceivedData()
                    else
                        StructureReceivedData();
                Step::"Read into IR":
                    if UndoStep then
                        UndoReadIntoIR()
                    else
                        ReadIntoIR();
                Step::"Prepare draft":
                    if UndoStep then
                        UndoPrepareDraft()
                    else
                        PrepareDraft();
                Step::"Finish draft":
                    if UndoStep then
                        UndoFinishDraft()
                    else
                        FinishDraft();
            end;

        if ImportProcessVersion = "E-Document Import Process"::"Version 1.0" then begin
            if Step = Step::"Finish draft" then begin
                case EDocImportParameters."Purch. Journal V1 Behavior" of
                    EDocImportParameters."Purch. Journal V1 Behavior"::"Inherit from service":
                        CreateJournalLineV1 := EDocument.GetEDocumentService()."Create Journal Lines";
                    EDocImportParameters."Purch. Journal V1 Behavior"::"Create journal line":
                        CreateJournalLineV1 := true;
                    EDocImportParameters."Purch. Journal V1 Behavior"::"Create purchase document":
                        CreateJournalLineV1 := false;
                end;
                EDocImport.V1_ProcessEDocument(EDocument, CreateJournalLineV1, EDocImportParameters."Create Document V1 Behavior");
            end
        end
        else begin
            EDocLog := EDocumentLog.InsertLog(Enum::"E-Document Service Status"::Imported, NewStatus);
            EDocumentProcessing.ModifyEDocumentProcessingStatus(EDocument, NewStatus);
            EDocument.Get(EDocument."Entry No");

            if (not UndoStep) and (Step = Step::"Structure received data") and (EDocument."Structured Data Entry No." = 0) then begin
                EDocument."Structured Data Entry No." := EDocLog."E-Doc. Data Storage Entry No.";
                EDocument.Modify();
            end;
        end;
    end;

    local procedure StructureReceivedData()
    var
        EDocumentDataStorage: Record "E-Doc. Data Storage";

        FileManagement: Codeunit "File Management";
        FromBlob: Codeunit "Temp Blob";
        IBlobType: Interface IBlobType;
        IBlobToStructuredDataConverter: Interface IBlobToStructuredDataConverter;
        NameWithoutExtension, Content : Text;
        Name: Text[256];
        NewType: Enum "E-Doc. Data Storage Blob Type";
    begin
        EDocument.TestField("Unstructured Data Entry No.");
        EDocumentDataStorage.Get(Edocument."Unstructured Data Entry No.");
        FromBlob.FromRecord(EDocumentDataStorage, EDocumentDataStorage.FieldNo("Data Storage"));

        IBlobType := EDocumentDataStorage."Data Type";

        // Store unstructured data as attachment (pdfs)
        if not IBlobType.IsStructured() and (EDocument."File Name" <> '') then
            AttachUnstructuredDataAsAttachment(EDocument, FromBlob);

        if IBlobType.IsStructured() then begin
            EDocument."Structured Data Entry No." := EDocumentDataStorage."Entry No.";
            EDocument.Modify();
            exit;
        end;

        if not IBlobType.HasConverter() then
            Error(UnstructuredBlobTypeWithNoConverterErr);

        IBlobToStructuredDataConverter := IBlobType.GetStructuredDataConverter();
        Content := IBlobToStructuredDataConverter.Convert(EDocument, FromBlob, EDocumentDataStorage."Data Type", NewType);

        if StrLen(Content) = 0 then
            Error(UnstructuredBlobConversionErr);

        NameWithoutExtension := FileManagement.GetFileNameWithoutExtension(EDocumentDataStorage.Name);
        Name := CopyStr(NameWithoutExtension + '.' + LowerCase(Format(NewType)), 1, 256);
        EDocumentLog.SetBlob(Name, NewType, Content);
    end;

    local procedure UndoStructureReceivedData()
    begin
        EDocument."Structured Data Entry No." := 0;
        EDocument.Modify();
    end;

    local procedure ReadIntoIR()
    var
        EDocumentDataStorage: Record "E-Doc. Data Storage";
        FromBlob: Codeunit "Temp Blob";
        IStructuredFormatReader: Interface IStructuredFormatReader;
    begin
        Edocument.TestField("Structured Data Entry No.");
        EDocumentDataStorage.Get(Edocument."Structured Data Entry No.");

        FromBlob.FromRecord(EDocumentDataStorage, EDocumentDataStorage.FieldNo("Data Storage"));
        IStructuredFormatReader := EDocument.GetEDocumentService()."E-Document Structured Format";

        EDocument."Structured Data Process" := IStructuredFormatReader.Read(EDocument, FromBlob);
        EDocument.Modify();
    end;

    local procedure UndoReadIntoIR()
    begin
    end;

    local procedure PrepareDraft()
    var
        EDocHeaderMapping: Record "E-Document Header Mapping";
        Vendor: Record Vendor;
        IProcessStructuredData: Interface IProcessStructuredData;
    begin
        IProcessStructuredData := EDocument."Structured Data Process";
        EDocument."Document Type" := IProcessStructuredData.PrepareDraft(EDocument, EDocImportParameters);
        EDocHeaderMapping := EDocument.GetEDocumentHeaderMapping();
        EDocument."Bill-to/Pay-to No." := EDocHeaderMapping."Vendor No.";
        if Vendor.Get(EDocHeaderMapping."Vendor No.") then
            EDocument."Bill-to/Pay-to Name" := Vendor.Name;
        EDocument.Modify();
    end;

    local procedure UndoPrepareDraft()
    var
        EDocumentHeaderMapping: Record "E-Document Header Mapping";
        EDocumentLineMapping: Record "E-Document Line Mapping";
    begin
        EDocumentLineMapping.SetRange("E-Document Entry No.", EDocument."Entry No");
        EDocumentLineMapping.DeleteAll();
        EDocumentHeaderMapping.SetRange("E-Document Entry No.", EDocument."Entry No");
        EDocumentHeaderMapping.DeleteAll();
        EDocument."Document Type" := "E-Document Type"::None;
        EDocument.Modify();
    end;

    local procedure FinishDraft()
    var
        IEDocumentFinishDraft: Interface IEDocumentFinishDraft;
    begin
        IEDocumentFinishDraft := EDocument."Document Type";
        EDocument."Document Record ID" := IEDocumentFinishDraft.ApplyDraftToBC(EDocument, EDocImportParameters);
        EDocument.Status := Enum::"E-Document Status"::Processed;
        EDocument.Modify();
    end;

    local procedure UndoFinishDraft()
    var
        IEDocumentFinishDraft: Interface IEDocumentFinishDraft;
    begin
        IEDocumentFinishDraft := EDocument."Document Type";
        IEDocumentFinishDraft.RevertDraftActions(EDocument);
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
        exit(StatusStepIndex(QueriedState) <= StatusStepIndex(EDocument.GetEDocumentImportProcessingStatus()));
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

    procedure IndexToStatus(Index: Integer) Status: Enum "Import E-Doc. Proc. Status"
    begin
        case Index of
            0:
                exit(Status::Unprocessed);
            1:
                exit(Status::Readable);
            2:
                exit(Status::"Ready for draft");
            3:
                exit(Status::"Draft ready");
            4:
                exit(Status::Processed);
        end;
    end;

    procedure GetNextStep(Status: Enum "Import E-Doc. Proc. Status") Step: Enum "Import E-Document Steps"
    begin
        case Status of
            Status::Unprocessed:
                exit(Step::"Structure received data");
            Status::Readable:
                exit(Step::"Read into IR");
            Status::"Ready for draft":
                exit(Step::"Prepare draft");
            Status::"Draft ready":
                exit(Step::"Finish draft");
        end;
    end;

    procedure GetStatusForStep(Step: Enum "Import E-Document Steps"; StepBefore: Boolean) Status: Enum "Import E-Doc. Proc. Status"
    begin
        case Step of
            Step::"Structure received data":
                exit(StepBefore ? Status::Unprocessed : Status::Readable);
            Step::"Read into IR":
                exit(StepBefore ? Status::Readable : Status::"Ready for draft");
            Step::"Prepare draft":
                exit(StepBefore ? Status::"Ready for draft" : Status::"Draft ready");
            Step::"Finish draft":
                exit(StepBefore ? Status::"Draft ready" : Status::Processed);
        end;
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

    var
        EDocument: Record "E-Document";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocumentLog: Codeunit "E-Document Log";

        EDocumentProcessing: Codeunit "E-Document Processing";
        Step: Enum "Import E-Document Steps";
        UndoStep: Boolean;
        UnstructuredBlobTypeWithNoConverterErr: Label 'Cant process E-Document as data type does not have a converter implemented.';
        UnstructuredBlobConversionErr: Label 'Conversion of the source document to structured format failed. Verify that the source document is not corrupted.';
        AIGeneratedContentTxt: Label 'Data was read from a PDF - check for accuracy. AI-generated content may be incorrect.​';
        TermsAndConditionsTxt: Label 'Terms and Conditions';
        TermsAndConditionsHyperlinkTxt: Label 'https://www.microsoft.com/en-us/business-applications/legal/supp-powerplatform-preview', Locked = true;
}