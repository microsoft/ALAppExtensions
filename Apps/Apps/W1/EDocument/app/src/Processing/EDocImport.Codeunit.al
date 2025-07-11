// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.eServices.EDocument.OrderMatch;
using Microsoft.eServices.EDocument.Integration.Receive;
using Microsoft.eServices.EDocument.Processing.Import;
#if not CLEAN26
using Microsoft.eServices.EDocument.Integration;
#endif
using System.Utilities;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;

codeunit 6140 "E-Doc. Import"
{
    Permissions =
        tabledata "E-Document" = im,
        tabledata "E-Doc. Imported Line" = imd;

    procedure ReceiveAndProcessAutomatically(EDocumentService: Record "E-Document Service"): Boolean
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocument: Record "E-Document";
        EDocIntegrationMgt: Codeunit "E-Doc. Integration Management";
        ReceiveContext: Codeunit ReceiveContext;
        AllEDocumentsProcessed: Boolean;
    begin
#if not CLEAN26
        if EDocumentService."Service Integration V2" = "Service Integration"::"No Integration" then
            exit(EDocIntegrationMgt.ReceiveDocument(EDocumentService, EDocumentService."Service Integration"));
#endif
        EDocIntegrationMgt.ReceiveDocuments(EDocumentService, ReceiveContext);

        EDocImportParameters := EDocumentService.GetDefaultImportParameters();

        AllEDocumentsProcessed := true;
        EDocumentServiceStatus.SetRange("E-Document Service Code", EDocumentService.Code);
        EDocumentServiceStatus.SetRange(Status, "E-Document Service Status"::Imported);
        EDocumentServiceStatus.SetRange("Import Processing Status", "Import E-Doc. Proc. Status"::Unprocessed);
        if EDocumentServiceStatus.FindSet() then
            repeat
                EDocument.Get(EDocumentServiceStatus."E-Document Entry No");
                AllEDocumentsProcessed := AllEDocumentsProcessed and ProcessIncomingEDocument(EDocument, EDocumentService, EDocImportParameters);
            until EDocumentServiceStatus.Next() = 0;
        exit(AllEDocumentsProcessed);
    end;

    procedure ProcessAutomaticallyIncomingEDocument(EDocument: Record "E-Document"): Boolean
    var
        EDocumentService: Record "E-Document Service";
    begin
        EDocumentService := EDocument.GetEDocumentService();
        exit(ProcessIncomingEDocument(EDocument, EDocumentService, EDocumentService.GetDefaultImportParameters()));
    end;

    procedure ProcessIncomingEDocument(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters"): Boolean
    begin
        exit(ProcessIncomingEDocument(EDocument, EDocument.GetEDocumentService(), EDocImportParameters));
    end;

    internal procedure ProcessIncomingEDocument(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocImportParameters: Record "E-Doc. Import Parameters"): Boolean
    var
        ImportEDocumentProcess: Codeunit "Import E-Document Process";
        StatusBefore, StatusAfter : Enum "Import E-Doc. Proc. Status";
    begin
        if EDocImportParameters."Step to Run / Desired Status" = EDocImportParameters."Step to Run / Desired Status"::"Desired E-Document Status" then
            exit(GetEDocumentToDesiredStatus(EDocument, EDocumentService, EDocImportParameters."Desired E-Document Status", EDocImportParameters))
        else begin
            StatusBefore := ImportEDocumentProcess.GetStatusForStep(EDocImportParameters."Step to Run", true);
            StatusAfter := ImportEDocumentProcess.GetStatusForStep(EDocImportParameters."Step to Run", false);
            if not GetEDocumentToDesiredStatus(EDocument, EDocumentService, StatusBefore, EDocImportParameters) then
                exit(false);
            exit(GetEDocumentToDesiredStatus(EDocument, EDocumentService, StatusAfter, EDocImportParameters));
        end;
    end;

    local procedure GetEDocumentToDesiredStatus(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; DesiredStatus: Enum "Import E-Doc. Proc. Status"; EDocImportParameters: Record "E-Doc. Import Parameters"): Boolean
    var
        ImportEDocumentProcess: Codeunit "Import E-Document Process";
        EDocImpSessionTelemetry: Codeunit "E-Doc. Imp. Session Telemetry";
        Status, CurrentStatus : Enum "Import E-Doc. Proc. Status";
        StepToDo, StepToUndo : Enum "Import E-Document Steps";
        StatusIndex: Integer;
    begin
        EDocument.TestField("Entry No");
        Clear(EDocumentLog);
        EDocumentLog.SetFields(EDocument, EDocumentService);

        EDocument.CalcFields("Import Processing Status");
        CurrentStatus := EDocument."Import Processing Status";

        EDocImpSessionTelemetry.SetSession(CurrentStatus, DesiredStatus);
        EDocImpSessionTelemetry.SetBool('Success', true);

        // We undo all the steps that have been done, if CurrentStatus = DesiredStatus we don't need to undo anything
        for StatusIndex := ImportEDocumentProcess.StatusStepIndex(CurrentStatus) downto ImportEDocumentProcess.StatusStepIndex(DesiredStatus) + 1 do
            if ImportEDocumentProcess.IndexToStatus(StatusIndex, Status) then
                if ImportEDocumentProcess.GetPreviousStep(Status, StepToUndo) then begin
                    ImportEDocumentProcess.ConfigureImportRun(EDocument, StepToUndo, EDocImportParameters, true);
                    if not RunConfiguredImportStep(ImportEDocumentProcess, EDocument) then
                        exit(false);
                end;

        EDocument.CalcFields("Import Processing Status");
        CurrentStatus := EDocument."Import Processing Status";

        // We run all the steps that need to be done to reach the desired state
        for StatusIndex := ImportEDocumentProcess.StatusStepIndex(CurrentStatus) to ImportEDocumentProcess.StatusStepIndex(DesiredStatus) - 1 do
            if ImportEDocumentProcess.IndexToStatus(StatusIndex, Status) then
                if ImportEDocumentProcess.GetNextStep(Status, StepToDo) then begin
                    ImportEDocumentProcess.ConfigureImportRun(EDocument, StepToDo, EDocImportParameters, false);
                    if not RunConfiguredImportStep(ImportEDocumentProcess, EDocument) then
                        exit(false);
                end;

        EDocImpSessionTelemetry.Emit(EDocument);
        OnAfterProcessIncomingEDocument(EDocument, EDocImportParameters, CurrentStatus, DesiredStatus);
        exit(true);
    end;

    local procedure RunConfiguredImportStep(var ImportEDocumentProcess: Codeunit "Import E-Document Process"; EDocument: Record "E-Document"): Boolean
    var
        EDocDraftSessionTelemetry: Codeunit "E-Doc. Imp. Session Telemetry";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
    begin
        EDocumentErrorHelper.ClearErrorMessages(EDocument);
        Commit();
        if not ImportEDocumentProcess.Run() then begin
            EDocument.SetRecFilter();
            EDocument.FindFirst();

            EDocErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());
            EDocument.CalcFields("Import Processing Status");
            EDocumentLog.InsertLog(Enum::"E-Document Service Status"::"Imported Document Processing Error", EDocument."Import Processing Status");
            EDocumentProcessing.ModifyServiceStatus(EDocument, EDocument.GetEDocumentService(), Enum::"E-Document Service Status"::"Imported Document Processing Error");
            EDocumentProcessing.ModifyEDocumentStatus(EDocument);
            EDocDraftSessionTelemetry.SetText('Step', Format(ImportEDocumentProcess.GetStep()));
            EDocDraftSessionTelemetry.SetBool('Success', false);
            exit(false);
        end;
        exit(true);
    end;

    internal procedure CreateFromType(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocFileFormat: Enum "E-Doc. File Format"; Filename: Text; InStr: InStream)
    var
        EDocLog: Record "E-Document Log";
    begin
        EDocument.Create(
            EDocument.Direction::Incoming,
            EDocument."Document Type"::None,
            EDocumentService
        );

        EDocument."File Name" := CopyStr(FileName, 1, 256);
        EDocument.Modify(true);

        EDocumentLog.SetFields(EDocument, EDocumentService);
        EDocumentLog.SetBlob(CopyStr(FileName, 1, 256), EDocFileFormat, InStr);

        EDocLog := EDocumentLog.InsertLog(Enum::"E-Document Service Status"::Imported, Enum::"Import E-Doc. Proc. Status"::Unprocessed, false);
        EDocumentProcessing.InsertServiceStatus(EDocument, EDocumentService, Enum::"E-Document Service Status"::Imported);

        EDocument."Unstructured Data Entry No." := EDocLog."E-Doc. Data Storage Entry No.";
        EDocument.Modify();
    end;

    internal procedure UploadDocument(var EDocument: Record "E-Document")
    var
        EDocumentService: Record "E-Document Service";
        EDocLog: Record "E-Document Log";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        FileName: Text;
        EDocumentServiceStatus: Enum "E-Document Service Status";
    begin
        if Page.RunModal(Page::"E-Document Services", EDocumentService) <> Action::LookupOK then
            exit;

        if not UploadIntoStream('', '', '', FileName, InStr) then
            exit;

        EDocument.Direction := EDocument.Direction::Incoming;
        EDocument."Document Type" := Enum::"E-Document Type"::None;
        EDocument.Service := EDocumentService.Code;
        EDocumentServiceStatus := "E-Document Service Status"::Imported;

        OutStr := TempBlob.CreateOutStream();
        CopyStream(OutStr, InStr);

        EDocument."File Name" := CopyStr(FileName, 1, 256);

        if EDocument."Entry No" = 0 then begin
            EDocument.Insert(true);
            EDocumentProcessing.InsertServiceStatus(EDocument, EDocumentService, EDocumentServiceStatus);
        end else begin
            EDocument.Modify(true);
            EDocumentProcessing.ModifyServiceStatus(EDocument, EDocumentService, EDocumentServiceStatus);
        end;

        EDocLog := EDocumentLog.InsertLog(EDocument, EDocumentService, TempBlob, EDocumentServiceStatus);
        EDocument."Unstructured Data Entry No." := EDocLog."E-Doc. Data Storage Entry No.";
        EDocument.Modify();
    end;

    internal procedure V1_GetBasicInfo(var EDocument: Record "E-Document")
    var
        EDocService: Record "E-Document Service";
        TempBlob: Codeunit "Temp Blob";
    begin
        EDocErrorHelper.ClearErrorMessages(EDocument);
        EDocService := EDocumentLog.GetLastServiceFromLog(EDocument);
        EDocumentLog.GetDocumentBlobFromLog(EDocument, EDocService, TempBlob, Enum::"E-Document Service Status"::Imported);

        GetDocumentBasicInfo(EDocument, EDocService, TempBlob);
    end;

    local procedure DeleteAttachments(EDocument: Record "E-Document")
    var
        EDocAttachmentProcessor: Codeunit "E-Doc. Attachment Processor";
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(EDocument);
        EDocAttachmentProcessor.DeleteAll(EDocument, RecordRef);

        if RecordRef.Get(EDocument."Document Record ID") then
            EDocAttachmentProcessor.DeleteAll(EDocument, RecordRef);
    end;

    internal procedure V1_ProcessEDocument(var EDocument: Record "E-Document"; CreateJnlLine: Boolean; AutoProcessDocument: Boolean)
    var
        EDocService: Record "E-Document Service";
        TempBlob: Codeunit "Temp Blob";
    begin
        if EDocument.Status = EDocument.Status::Processed then
            exit;

        DeleteAttachments(EDocument);

        EDocErrorHelper.ClearErrorMessages(EDocument);
        EDocService := EDocument.GetEDocumentService();
        EDocumentLog.GetDocumentBlobFromLog(EDocument, EDocService, TempBlob, Enum::"E-Document Service Status"::Imported);

        V1_ProcessImportedDocument(EDocument, EDocService, TempBlob, CreateJnlLine, AutoProcessDocument);
    end;

    local procedure GetDocumentBasicInfo(var EDocument: Record "E-Document"; EDocService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob")
    var
        EDocument2: Record "E-Document";
        EDocGetBasicInfo: Codeunit "E-Doc. Get Basic Info";
        EDocumentInterface: Interface "E-Document";
    begin
        // Commit before getting basic info with error handling (if Codeunit.Run then )
        Commit();
        EDocumentInterface := EDocService."Document Format";
        EDocGetBasicInfo.SetValues(EDocumentInterface, EDocument, TempBlob);
        if EDocGetBasicInfo.Run() then begin
            EDocGetBasicInfo.GetValues(EDocumentInterface, EDocument, TempBlob);

            EDocument2.SetRange("Incoming E-Document No.", EDocument."Incoming E-Document No.");
            EDocument2.SetRange("Bill-to/Pay-to No.", EDocument."Bill-to/Pay-to No.");
            EDocument2.SetFilter("Entry No", '<>%1', EDocument."Entry No");
            if EDocument2.FindFirst() then
                EDocErrorHelper.LogWarningMessage(EDocument, EDocument2, EDocument2.FieldNo("Incoming E-Document No."), DocAlreadyExistsMsg);

            if EDocService."Validate Receiving Company" then
                EDocImportHelper.ValidateReceivingCompanyInfo(EDocument);
        end else
            EDocErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());

        EDocument.Modify(true);
    end;


    internal procedure UpdatePurchaseOrderLink(var EDocument: Record "E-Document")
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        DocumentHeader: RecordRef;
        NullGuid: Guid;
    begin
        if EDocument.Status = Enum::"E-Document Status"::Processed then
            exit;

        Vendor.Get(EDocument."Bill-to/Pay-to No.");
        if not SelectPurchaseOrderFromList(EDocument, Vendor, DocumentHeader) then
            exit;

        // If new purchase order is selected
        // Release purchase header if it is pointing to this document
        if PurchaseHeader.Get(EDocument."Document Record ID") then
            if PurchaseHeader."E-Document Link" = EDocument.SystemId then begin
                PurchaseHeader.Validate("E-Document Link", NullGuid);
                PurchaseHeader.Modify();
            end;

        EDocument."Order No." := '';
        EDocument."Document Type" := EDocument."Document Type"::None;
        EDocument.Modify();

        V1_ProcessEDocument(EDocument, false, true);
    end;

    procedure ViewExtractedData(EDocument: Record "E-Document")
    var
        EDocumentDataStorage: Record "E-Doc. Data Storage";
        IStructuredFormatReader: Interface IStructuredFormatReader;
    begin
        IStructuredFormatReader := EDocument."Read into Draft Impl.";
        EDocumentDataStorage.Get(EDocument."Structured Data Entry No.");
        IStructuredFormatReader.View(EDocument, EDocumentDataStorage.GetTempBlob());
    end;

    local procedure ProcessExistingOrder(var EDocument: Record "E-Document"; EDocService: Record "E-Document Service"; var SourceDocumentLine: RecordRef; var DocumentHeader: RecordRef; var EDocServiceStatus: Enum "E-Document Service Status")
    var
        PurchaseOrderHeader: Record "Purchase Header";
        TempEDocImportedLine: Record "E-Doc. Imported Line" temporary;
        EDocument2: Record "E-Document";
        ErrorMessage: Record "Error Message";
        TempExistingErrorMessage: Record "Error Message" temporary;
        ItemFound, UOMResolved : Boolean;
    begin
        DocumentHeader.SetTable(PurchaseOrderHeader);

        // Collect any error message
        ErrorMessage.SetContext(EDocument.RecordId());
        ErrorMessage.SetRange("Context Record ID", EDocument.RecordId());
        ErrorMessage.CopyToTemp(TempExistingErrorMessage);

        // Get lines
        if SourceDocumentLine.FindSet() then
            repeat
                if EDocService."Resolve Unit Of Measure" or EDocService."Lookup Item Reference" or
                   EDocService."Lookup Item GTIN" or EDocService."Lookup Account Mapping" then begin
                    ItemFound := false;
                    UOMResolved := false;
                    if EDocService."Resolve Unit Of Measure" then
                        UOMResolved := EDocImportHelper.ResolveUnitOfMeasureFromDataImport(EDocument, SourceDocumentLine)
                    else
                        UOMResolved := true;

                    // Lookup Item Ref, then GTIN/Bar Code, else G/L Account
                    if UOMResolved then begin
                        if EDocService."Lookup Item Reference" then
                            ItemFound := EDocImportHelper.FindItemReferenceForLine(EDocument, SourceDocumentLine);

                        if (not ItemFound) and EDocService."Lookup Item GTIN" then
                            ItemFound := EDocImportHelper.FindItemForLine(EDocument, SourceDocumentLine);

                        if (not ItemFound) and EDocService."Lookup Account Mapping" then
                            ItemFound := EDocImportHelper.FindGLAccountForLine(EDocument, SourceDocumentLine);
                    end;

                    if EDocService."Validate Line Discount" then
                        EDocImportHelper.ValidateLineDiscount(EDocument, SourceDocumentLine);
                end;

                // Save Temp EDocument Import Line for matching to purchase order
                TempEDocImportedLine.Insert(EDocument, SourceDocumentLine, TempEDocImportedLine, ItemFound);
            until SourceDocumentLine.Next() = 0;

        // Clear any error messages created while trying to resolve and reinsert stored.
        ErrorMessage.ClearLog();
        ErrorMessage.CopyFromTemp(TempExistingErrorMessage);

        // Load into imported lines and update edoc state
        PersistImportedLines(EDocument, TempEDocImportedLine);
        UpdateEDocumentRecordId(EDocument, DocumentHeader.Field(PurchaseOrderHeader.FieldNo("No.")).Value(), DocumentHeader.RecordId);

        // We should mark Edoc pending if existing edoc is already linked
        if (not IsNullGuid(PurchaseOrderHeader."E-Document Link")) and (PurchaseOrderHeader."E-Document Link" <> EDocument.SystemId) then begin
            EDocServiceStatus := EDocServiceStatus::Pending;
            EDocument2.GetBySystemId(PurchaseOrderHeader."E-Document Link");
            EDocErrorHelper.LogWarningMessage(EDocument, EDocument2, EDocument2.FieldNo("Entry No"), StrSubstNo(CannotProcessEDocumentMsg, EDocument."Entry No", PurchaseOrderHeader."No.", EDocument2."Entry No"));
        end else begin
            PurchaseOrderHeader.Validate("E-Document Link", EDocument.SystemId);
            PurchaseOrderHeader.Modify();
            EDocServiceStatus := EDocServiceStatus::"Order Linked";
        end;
        EDocument.Status := Enum::"E-Document Status"::"In Progress";
    end;

    local procedure CreatePurchaseDocumentFromImportedDocument(var EDocument: Record "E-Document"; var EDocService: Record "E-Document Service"; var SourceDocumentHeader: RecordRef; var SourceDocumentLine: RecordRef; var EDocServiceStatus: Enum "E-Document Service Status"; PurchaseDocumentType: Enum "Purchase Document Type")
    var
        PurchHeader: Record "Purchase Header";
        DocumentHeader: RecordRef;
        ItemFound, UOMResolved : Boolean;
    begin
        if EDocService."Resolve Unit Of Measure" or EDocService."Lookup Item Reference" or
           EDocService."Lookup Item GTIN" or EDocService."Lookup Account Mapping" or
           EDocService."Validate Line Discount" then
            if SourceDocumentLine.FindSet() then
                repeat
                    ItemFound := false;
                    UOMResolved := false;

                    if EDocService."Resolve Unit Of Measure" then
                        UOMResolved := EDocImportHelper.ResolveUnitOfMeasureFromDataImport(EDocument, SourceDocumentLine)
                    else
                        UOMResolved := true;

                    // Lookup Item Ref, then GTIN/Bar Code, else G/L Account
                    if UOMResolved then begin
                        if EDocService."Lookup Item Reference" then
                            ItemFound := EDocImportHelper.FindItemReferenceForLine(EDocument, SourceDocumentLine);

                        if (not ItemFound) and EDocService."Lookup Item GTIN" then
                            ItemFound := EDocImportHelper.FindItemForLine(EDocument, SourceDocumentLine);

                        if (not ItemFound) and EDocService."Lookup Account Mapping" then
                            ItemFound := EDocImportHelper.FindGLAccountForLine(EDocument, SourceDocumentLine);

                        if not ItemFound then
                            EDocImportHelper.LogErrorIfItemNotFound(EDocument, SourceDocumentLine);
                    end;

                    if EDocService."Validate Line Discount" then
                        EDocImportHelper.ValidateLineDiscount(EDocument, SourceDocumentLine);

                    SourceDocumentLine.Modify();
                until SourceDocumentLine.Next() = 0;

        if EDocErrorHelper.HasErrors(EDocument) then
            exit;

        CreateDocument(EDocument, SourceDocumentHeader, SourceDocumentLine, DocumentHeader, PurchaseDocumentType);
        if EDocErrorHelper.HasErrors(EDocument) then
            exit;

        if EDocService."Apply Invoice Discount" then
            EDocImportHelper.ApplyInvoiceDiscount(EDocument, SourceDocumentHeader, DocumentHeader);

        if EDocService."Verify Totals" then
            EDocImportHelper.VerifyTotal(EDocument, SourceDocumentHeader, DocumentHeader);

        if EDocErrorHelper.HasErrors(EDocument) then
            exit;

        DocumentHeader.SetTable(PurchHeader);

        PurchHeader.Validate("E-Document Link", EDocument.SystemId);
        PurchHeader."Doc. Amount Incl. VAT" := EDocument."Amount Incl. VAT";
        PurchHeader."Doc. Amount VAT" := EDocument."Amount Incl. VAT" - EDocument."Amount Excl. VAT";
        PurchHeader.Modify();

        UpdateEDocumentRecordId(EDocument, DocumentHeader.Field(PurchHeader.FieldNo("No.")).Value(), DocumentHeader.RecordId);
        EDocServiceStatus := EDocServiceStatus::"Imported Document Created";
        EDocument.Status := Enum::"E-Document Status"::Processed;
    end;

    local procedure CreateJournalLineFromImportedDocument(var EDocument: Record "E-Document"; var EDocService: Record "E-Document Service"; var EDocServiceStatus: Enum "E-Document Service Status")
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJnlLine: RecordRef;
    begin
        CreateJournalLine(EDocument, EDocService, GenJnlLine);
        if GenJnlLine.Number <> 0 then
            EDocument."Journal Line System ID" := GenJnlLine.Field(GenJnlLine.SystemIdNo).Value;

        if EDocErrorHelper.HasErrors(EDocument) then
            exit;

        UpdateEDocumentRecordId(EDocument, Enum::"E-Document Type"::"General Journal", GenJnlLine.Field(GenJournalLine.FieldNo("Document No.")).Value(), GenJnlLine.RecordId);
        EDocServiceStatus := Enum::"E-Document Service Status"::"Journal Line Created";
        EDocument.Status := Enum::"E-Document Status"::Processed;
    end;

    local procedure UpdateEDocumentRecordId(var EDocument: Record "E-Document"; DocNo: Code[20]; RecordId: RecordId)
    begin
        UpdateEDocumentRecordId(EDocument, EDocument."Document Type", DocNo, RecordId);
    end;

    local procedure UpdateEDocumentRecordId(var EDocument: Record "E-Document"; EDocType: enum "E-Document Type"; DocNo: Code[20];
                                                                                              RecordId: RecordId)
    begin
        EDocument."Document Type" := EDocType;
        EDocument."Document No." := DocNo;
        EDocument.Validate("Document Record ID", RecordId);
        EDocument.Modify();
    end;

    internal procedure V1_ProcessImportedDocument(var EDocument: Record "E-Document"; var EDocService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; CreateJnlLine: Boolean; AutoProcessDocument: Boolean)
    var
        EDocLog: Record "E-Document Log";
        TempEDocMapping: Record "E-Doc. Mapping" temporary;
        Vendor: Record Vendor;
        DocumentHeader, SourceDocumentHeader, SourceDocumentLine : RecordRef;
        EDocServiceStatus: Enum "E-Document Service Status";
        ExistingOrderNo: Code[20];
        Window: Dialog;
    begin
        if GuiAllowed() then
            Window.Open('Processing E-Document: \ #1');

        // Pending documents that are processed can already be linked to order. In these cases we save order no and reinsert after parsing xml.
        ExistingOrderNo := EDocument."Order No.";
        EDocErrorHelper.ClearErrorMessages(EDocument);

        GetDocumentBasicInfo(EDocument, EDocService, TempBlob);
        if EDocErrorHelper.HasErrors(EDocument) then begin
            EDocServiceStatus := Enum::"E-Document Service Status"::"Imported document processing error";
            EDocumentLog.InsertLog(EDocument, EDocService, EDocServiceStatus);
            EDocumentProcessing.ModifyServiceStatus(EDocument, EDocService, EDocServiceStatus);
            EDocumentProcessing.ModifyEDocumentStatus(EDocument);
            exit;
        end;

        if EDocument.IsDuplicate(true) then begin
            EDocument.Delete(true);
            exit;
        end;

        ParseDocumentLines(EDocument, EDocService, TempBlob, SourceDocumentHeader, SourceDocumentLine, TempEDocMapping);
        if EDocErrorHelper.HasErrors(EDocument) then begin
            EDocServiceStatus := Enum::"E-Document Service Status"::"Imported document processing error";
            EDocumentLog.InsertLog(EDocument, EDocService, EDocServiceStatus);
            EDocumentProcessing.ModifyServiceStatus(EDocument, EDocService, EDocServiceStatus);
            EDocumentProcessing.ModifyEDocumentStatus(EDocument);
            exit;
        end;
        if ExistingOrderNo <> '' then
            EDocument."Order No." := ExistingOrderNo;

        if not AutoProcessDocument then begin
            EDocument.Modify(true);
            exit;
        end;

        if Vendor.Get(EDocument."Bill-to/Pay-to No.") then
            if ValidateEDocumentIsForPurchaseOrder(EDocument, Vendor) then
                ReceiveEDocumentToPurchaseOrder(EDocument, EDocService, SourceDocumentHeader, SourceDocumentLine, EDocServiceStatus, Vendor, Window)
            else
                ReceiveEDocumentToPurchaseDoc(EDocument, EDocService, SourceDocumentHeader, SourceDocumentLine, EDocServiceStatus, Window, CreateJnlLine)
        else
            EDocErrorHelper.LogErrorMessage(EDocument, Vendor, Vendor.FieldNo("No."), FailedToFindVendorErr);

        if EDocErrorHelper.HasErrors(EDocument) then
            EDocServiceStatus := Enum::"E-Document Service Status"::"Imported document processing error";

        EDocLog := EDocumentLog.InsertLog(EDocument, EDocService, EDocServiceStatus);
        EDocumentLog.InsertMappingLog(EDocLog, TempEDocMapping);
        EDocumentProcessing.ModifyServiceStatus(EDocument, EDocService, EDocServiceStatus);
        EDocumentProcessing.ModifyEDocumentStatus(EDocument);

        OnAfterProcessImportedDocument(EDocument, DocumentHeader);
    end;

    local procedure ValidateEDocumentIsForPurchaseOrder(var EDocument: Record "E-Document"; Vendor: Record Vendor): Boolean
    begin
        if EDocument."Document Type" = EDocument."Document Type"::"Purchase Credit Memo" then
            exit(false);
        exit(Vendor."Receive E-Document To" = Enum::"E-Document Type"::"Purchase Order");
    end;

    local procedure ReceiveEDocumentToPurchaseOrder(var EDocument: Record "E-Document"; var EDocService: Record "E-Document Service"; var SourceDocumentHeader: RecordRef; var SourceDocumentLine: RecordRef; var EDocServiceStatus: Enum "E-Document Service Status"; Vendor: Record Vendor; var WindowInstance: Dialog)
    var
        DocumentHeader: RecordRef;
    begin
        EDocument."Document Type" := "E-Document Type"::"Purchase Order";
        EDocument.Modify();

        // Check if document points to existing order
        if OrderExists(EDocument, Vendor, DocumentHeader) then begin
            ProcessExistingOrder(EDocument, EDocService, SourceDocumentLine, DocumentHeader, EDocServiceStatus);
            exit;
        end;

        // Case where we do not find/have order
        if GuiAllowed() and (not HideDialogs) then begin
            if SelectPurchaseOrderFromList(EDocument, Vendor, DocumentHeader) then begin
                WindowInstance.Update(1, DocLinkMsg);
                ProcessExistingOrder(EDocument, EDocService, SourceDocumentLine, DocumentHeader, EDocServiceStatus);
            end else begin
                WindowInstance.Update(1, DocCreatePOMsg);
                CreatePurchaseDocumentFromImportedDocument(EDocument, EDocService, SourceDocumentHeader, SourceDocumentLine, EDocServiceStatus, Enum::"Purchase Document Type"::Order);
            end;
        end else
            EDocServiceStatus := Enum::"E-Document Service Status"::Pending;
    end;

    internal procedure V1_ProcessEDocPendingOrderMatch(var EDocument: Record "E-Document")
    var
        EDocService: Record "E-Document Service";
        EDocServiceStatus: Record "E-Document Service Status";
        EDocLog: Codeunit "E-Document Log";
    begin
        if (EDocument."Document Type" <> Enum::"E-Document Type"::"Purchase Order") or
            (EDocument.Status = Enum::"E-Document Status"::Processed) then
            exit;

        EDocService := EDocLog.GetLastServiceFromLog(EDocument);
        EDocServiceStatus.Get(EDocument."Entry No", EDocService.Code);
        if EDocServiceStatus.Status <> EDocServiceStatus.Status::Pending then
            exit;

        if not IsPendingEDocReadyToProcess(EDocument) then
            exit;

        V1_ProcessEDocument(EDocument, EDocService."Create Journal Lines", true);
    end;

    local procedure IsPendingEDocReadyToProcess(EDocument: Record "E-Document"): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // If no order number is set we need to process document
        if EDocument."Order No." = '' then
            exit(true);

        PurchaseHeader.SetRange("No.", EDocument."Order No.");
        PurchaseHeader.SetRange("Document Type", Enum::"Purchase Document Type"::Order);
        if PurchaseHeader.FindFirst() then
            exit(IsNullGuid(PurchaseHeader."E-Document Link"))
        else
            exit(true);
    end;

    local procedure SelectPurchaseOrderFromList(var EDocument: Record "E-Document"; Vendor: Record Vendor; var DocumentHeader: RecordRef) Found: Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseOrderList: Page "Purchase Order List";
    begin
        Found := false;
        if not GuiAllowed() then
            exit(false);

        PurchaseHeader.SetRange("Buy-from Vendor No.", Vendor."No.");
        PurchaseHeader.SetRange("Document Type", Enum::"Purchase Document Type"::Order);
        if PurchaseHeader.IsEmpty() then
            exit(false);

        PurchaseOrderList.SetTableView(PurchaseHeader);
        PurchaseOrderList.LookupMode(true);
        Commit();
        if PurchaseOrderList.RunModal() = Action::LookupOK then begin
            PurchaseOrderList.GetRecord(PurchaseHeader);
            DocumentHeader.GetTable(PurchaseHeader);
            EDocument."Order No." := PurchaseHeader."No.";
            EDocument.Modify();
            Found := true;
        end;
    end;

    local procedure ReceiveEDocumentToPurchaseDoc(var EDocument: Record "E-Document"; var EDocService: Record "E-Document Service"; var SourceDocumentHeader: RecordRef; var SourceDocumentLine: RecordRef; var EDocServiceStatus: Enum "E-Document Service Status"; var WindowInstance: Dialog; CreateJnlLine: Boolean)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseDocumentType: Enum "Purchase Document Type";
    begin
        PurchaseDocumentType := SourceDocumentHeader.Field(PurchaseHeader.FieldNo("Document Type")).Value();
        if CreateJnlLine then begin
            if GuiAllowed() then
                WindowInstance.Update(1, JnlLineCreateMsg);
            CreateJournalLineFromImportedDocument(EDocument, EDocService, EDocServiceStatus);
        end else begin
            if GuiAllowed() then
                WindowInstance.Update(1, StrSubstNo(DocCreateMsg, Format(PurchaseDocumentType)));
            CreatePurchaseDocumentFromImportedDocument(EDocument, EDocService, SourceDocumentHeader, SourceDocumentLine, EDocServiceStatus, PurchaseDocumentType);
        end;
    end;

    local procedure ParseDocumentLines(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; var SourceDocumentHeader: RecordRef; var SourceDocumentLine: RecordRef; var TempEDocMapping: Record "E-Doc. Mapping" temporary)
    var
        EDocGetFullInfo: Codeunit "E-Doc. Get Complete Info";
        EDocExport: Codeunit "E-Doc. Export";
        SourceDocumentHeaderMapped, SourceDocumentLineMapped : RecordRef;
        EDocInterface: Interface "E-Document";
    begin
        OnBeforePrepareReceivedDoc(EDocument, TempBlob, SourceDocumentHeader, SourceDocumentLine, TempEDocMapping);

        case EDocument."Document Type" of
            EDocument."Document Type"::"Purchase Invoice", EDocument."Document Type"::"Purchase Credit Memo":
                begin
                    SourceDocumentHeader.Open(Database::"Purchase Header", true);
                    SourceDocumentLine.Open(Database::"Purchase Line", true);
                end;
            else begin
                EDocErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(DocTypeIsNotSupportedErr, EDocument."Document Type"));
                exit;
            end;
        end;

        // Commit before getting full info with error handling (if Codeunit.Run then )
        Commit();
        EDocInterface := EDocumentService."Document Format";
        EDocGetFullInfo.SetValues(EDocInterface, EDocument, SourceDocumentHeader, SourceDocumentLine, TempBlob);
        if not EDocGetFullInfo.Run() then begin
            EDocErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());
            exit;
        end;

        EDocGetFullInfo.GetValues(EDocInterface, EDocument, SourceDocumentHeader, SourceDocumentLine, TempBlob);
        EDocExport.MapEDocument(SourceDocumentHeader, SourceDocumentLine, EDocumentService, SourceDocumentHeaderMapped, SourceDocumentLineMapped, TempEDocMapping, true);

        SourceDocumentHeader.Copy(SourceDocumentHeaderMapped, true);
        SourceDocumentLine.Copy(SourceDocumentLineMapped, true);

        V1_PopulateEDocumentPreview(EDocument, SourceDocumentHeader, SourceDocumentLine);

        OnAfterPrepareReceivedDoc(EDocument, TempBlob, SourceDocumentHeader, SourceDocumentLine, TempEDocMapping);
    end;

    local procedure CreateDocument(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var TempDocumentLine: RecordRef; var DocumentHeader: RecordRef; PurchaseDocumentType: Enum "Purchase Document Type")
    var
        EDocumentCreatePurchase: Codeunit "E-Document Create Purch. Doc.";
    begin
        // Commit before creating document with error handling (if Codeunit.Run then )
        Commit();
        ClearLastError();

        OnBeforeCreateDocument(EDocument, TempDocumentHeader, TempDocumentLine, DocumentHeader);

        case TempDocumentHeader.Number of
            Database::"Purchase Header":
                begin
                    Clear(EDocumentCreatePurchase);
                    EDocumentCreatePurchase.SetSource(EDocument, TempDocumentHeader, TempDocumentLine, PurchaseDocumentType);
                    if EDocumentCreatePurchase.Run() then
                        DocumentHeader := EDocumentCreatePurchase.GetCreatedDocument()
                    else
                        EDocErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());
                end;
        end;

        OnAfterCreateDocument(EDocument, TempDocumentHeader, TempDocumentLine, DocumentHeader);
    end;

    local procedure CreateJournalLine(var EDocument: Record "E-Document"; var EDocService: Record "E-Document Service"; var JnlLine: RecordRef)
    var
        EDocumentCreateJnlLine: Codeunit "E-Document Create Jnl. Line";
    begin
        // Commit before creating document with error handling (if Codeunit.Run then )
        Commit();
        ClearLastError();

        OnBeforeCreateJournalLine(EDocument, JnlLine);

        case EDocument."Document Type" of
            EDocument."Document Type"::"Purchase Invoice", EDocument."Document Type"::"Purchase Credit Memo":
                begin
                    Clear(EDocumentCreateJnlLine);
                    EDocumentCreateJnlLine.SetSource(EDocument, EDocService);
                    if EDocumentCreateJnlLine.Run() then
                        JnlLine := EDocumentCreateJnlLine.GetCreatedJnlLine()
                    else
                        EDocErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());
                end;
        end;

        OnAfterCreateJournalLine(EDocument, JnlLine);
    end;

    local procedure V1_PopulateEDocumentPreview(EDocument: Record "E-Document"; SourceDocumentHeader: RecordRef; SourceDocumentLine: RecordRef)
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineNo: Integer;
    begin
        EDocumentPurchaseHeader.InsertForEDocument(EDocument);

        if (EDocument."Document Type" <> EDocument."Document Type"::"Purchase Invoice") and (EDocument."Document Type" <> EDocument."Document Type"::"Purchase Credit Memo") then
            exit;

        SourceDocumentHeader.SetTable(PurchaseHeader);
        V1_CopyFromPurchaseHeader(EDocument, PurchaseHeader, EDocumentPurchaseHeader);

        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        EDocumentPurchaseLine.DeleteAll();
        LineNo := 10000;
        if SourceDocumentLine.FindSet() then
            repeat
                Clear(EDocumentPurchaseLine);
                EDocumentPurchaseLine."E-Document Entry No." := EDocument."Entry No";
                EDocumentPurchaseLine."Line No." := LineNo;
                EDocumentPurchaseLine.Insert();

                SourceDocumentLine.SetTable(PurchaseLine);
                V1_CopyFromPurchaseLine(PurchaseLine, EDocumentPurchaseLine);
                LineNo := LineNo + 10000;
            until SourceDocumentLine.Next() = 0;

    end;

    local procedure V1_CopyFromPurchaseHeader(EDocument: Record "E-Document"; PurchaseHeader: Record "Purchase Header"; var EDocumentPurchaseHeader: Record "E-Document Purchase Header")
    var
        Vendor: Record Vendor;
    begin
        if Vendor.Get(PurchaseHeader."Buy-from Vendor No.") then;
        EDocumentPurchaseHeader."Vendor Company Name" := PurchaseHeader."Pay-to Name";
        EDocumentPurchaseHeader."Vendor Contact Name" := Vendor.Contact;
        EDocumentPurchaseHeader."Vendor Address" := Vendor.Address;
        EDocumentPurchaseHeader."Vendor VAT Id" := Vendor."VAT Registration No.";
        EDocumentPurchaseHeader."Purchase Order No." := PurchaseHeader."Vendor Order No.";
        EDocumentPurchaseHeader."Sales Invoice No." := PurchaseHeader."Vendor Invoice No.";
        EDocumentPurchaseHeader."Invoice Date" := PurchaseHeader."Posting Date";
        EDocumentPurchaseHeader."Due Date" := PurchaseHeader."Due Date";
        EDocumentPurchaseHeader."Currency Code" := PurchaseHeader."Currency Code";
        EDocumentPurchaseHeader."Document Date" := PurchaseHeader."Document Date";
        EDocumentPurchaseHeader."Vendor Address" := PurchaseHeader."Pay-to Address";
        EDocumentPurchaseHeader."Total Discount" := PurchaseHeader."Invoice Discount Amount";
        EDocumentPurchaseHeader."Total" := EDocument."Amount Incl. VAT";
        EDocumentPurchaseHeader."Total VAT" := EDocument."Amount Incl. VAT" - EDocument."Amount Excl. VAT";
        EDocumentPurchaseHeader.Modify();
    end;

    local procedure V1_CopyFromPurchaseLine(PurchaseLine: Record "Purchase Line"; var EDocumentPurchaseLine: Record "E-Document Purchase Line")
    begin
        EDocumentPurchaseLine."Product Code" := PurchaseLine."No.";
        EDocumentPurchaseLine."Description" := PurchaseLine.Description;
        EDocumentPurchaseLine.Quantity := PurchaseLine.Quantity;
        EDocumentPurchaseLine."Unit Price" := PurchaseLine."Direct Unit Cost";
        EDocumentPurchaseLine."Unit of Measure" := PurchaseLine."Unit of Measure Code";
        EDocumentPurchaseLine."Sub Total" := PurchaseLine."Direct Unit Cost" * PurchaseLine.Quantity;
        EDocumentPurchaseLine."Total Discount" := PurchaseLine."Line Discount Amount";
        EDocumentPurchaseLine."VAT Rate" := PurchaseLine."VAT %";
        EDocumentPurchaseLine."Currency Code" := PurchaseLine."Currency Code";
        EDocumentPurchaseLine.Modify();
    end;

    local procedure OrderExists(EDocument: Record "E-Document"; Vendor: Record Vendor; var DocumentHeader: RecordRef): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if EDocument."Order No." = '' then
            exit(false);

        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SetRange("No.", EDocument."Order No.");
        PurchaseHeader.SetRange("Buy-from Vendor No.", Vendor."No.");
        if PurchaseHeader.FindFirst() then begin
            DocumentHeader.GetTable(PurchaseHeader);
            exit(true);
        end else
            exit(false);
    end;

    local procedure PersistImportedLines(EDocument: Record "E-Document"; var TempEDocImportedLine: Record "E-Doc. Imported Line" temporary)
    var
        EDocImportedLine: Record "E-Doc. Imported Line";
    begin
        EDocImportedLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        EDocImportedLine.DeleteAll();
        EDocImportedLine.Reset();
        if TempEDocImportedLine.FindSet() then
            repeat
                EDocImportedLine.TransferFields(TempEDocImportedLine);
                if EDocImportedLine.Insert() then;
            until TempEDocImportedLine.Next() = 0;
    end;

    internal procedure SetHideDialogs(Hide: Boolean)
    begin
        HideDialogs := Hide;
    end;


#if not CLEAN26
    internal procedure V1_AfterInsertImportedEdocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocCount: Integer; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    begin
        OnAfterInsertImportedEdocument(EDocument, EDocumentService, TempBlob, EDocCount, HttpRequest, HttpResponse);
    end;

    internal procedure V1_BeforeInsertImportedEdocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocCount: Integer; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var IsCreated: Boolean; var IsProcessed: Boolean)
    begin
        OnBeforeInsertImportedEdocument(EDocument, EDocumentService, TempBlob, EDocCount, HttpRequest, HttpResponse, IsCreated, IsProcessed);
    end;
#endif

    var
        EDocumentLog: Codeunit "E-Document Log";
        EDocImportHelper: Codeunit "E-Document Import Helper";
        EDocErrorHelper: Codeunit "E-Document Error Helper";
        EDocumentProcessing: Codeunit "E-Document Processing";
        HideDialogs: Boolean;
        JnlLineCreateMsg: Label 'Creating Journal Line';
        DocCreateMsg: Label 'Creating Purchase %1', Comment = '%1 - Document type';
        DocLinkMsg: Label 'Linking to existing order';
        DocCreatePOMsg: Label 'Creating Purchase Order';
        DocAlreadyExistsMsg: Label 'The document already exists.';
        DocTypeIsNotSupportedErr: Label 'Document type %1 is not supported.', Comment = '%1 - Document Type';
        FailedToFindVendorErr: Label 'No vendor is set for Edocument';
        CannotProcessEDocumentMsg: Label 'Cannot process E-Document %1 with Purchase Order %2 before Purchase Order has been matched and posted for E-Document %3.', Comment = '%1 - E-Document entry no, %2 - Purchase Order number, %3 - EDocument entry no.';

    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessIncomingEDocument(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters"; StartState: Enum "Import E-Doc. Proc. Status"; DesiredEndState: Enum "Import E-Doc. Proc. Status")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessImportedDocument(var EDocument: Record "E-Document"; var DocumentHeader: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrepareReceivedDoc(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; SourceDocumentHeader: RecordRef; SourceDocumentLine: RecordRef; TempEDocMapping: Record "E-Doc. Mapping" temporary);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPrepareReceivedDoc(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; SourceDocumentHeader: RecordRef; SourceDocumentLine: RecordRef; TempEDocMapping: Record "E-Doc. Mapping" temporary);
    begin
    end;
#if not CLEAN27
    [Obsolete('This event is not raised.', '27.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateDocument(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var TempDocumentLine: RecordRef; var DocumentHeader: RecordRef)
    begin
    end;

    [Obsolete('This event is not raised.', '27.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateDocument(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var TempDocumentLine: RecordRef; var DocumentHeader: RecordRef)
    begin
    end;
#endif
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateDocument(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var TempDocumentLine: RecordRef; var DocumentHeader: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDocument(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var TempDocumentLine: RecordRef; var DocumentHeader: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateJournalLine(var EDocument: Record "E-Document"; var JnlLine: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateJournalLine(var EDocument: Record "E-Document"; var JnlLine: RecordRef)
    begin
    end;

#if not CLEAN26
    [IntegrationEvent(false, false)]
    [Obsolete('This event is removed. Use new IDocumentReceiver interface instead', '26.0')]
    local procedure OnAfterInsertImportedEdocument(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocCount: Integer; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    begin
    end;

    [IntegrationEvent(false, false)]
    [Obsolete('This event is removed. Use new IDocumentReceiver interface instead', '26.0')]
    local procedure OnBeforeInsertImportedEdocument(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocCount: Integer; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; var IsCreated: Boolean; var IsProcessed: Boolean)
    begin
    end;


#endif
}