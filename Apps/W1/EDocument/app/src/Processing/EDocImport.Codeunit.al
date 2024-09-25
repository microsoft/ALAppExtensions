// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.eServices.EDocument.OrderMatch;
using System.Utilities;

codeunit 6140 "E-Doc. Import"
{
    Permissions =
        tabledata "E-Document" = im,
        tabledata "E-Doc. Imported Line" = imd;

    internal procedure UploadDocument(var EDocument: Record "E-Document")
    var
        EDocumentService: Record "E-Document Service";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        FileName: Text;
    begin
        if Page.RunModal(Page::"E-Document Services", EDocumentService) <> Action::LookupOK then
            exit;

        if not UploadIntoStream('', '', '', FileName, InStr) then
            exit;

        TempBlob.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);

        EDocument.Direction := EDocument.Direction::Incoming;
        EDocument."Document Type" := Enum::"E-Document Type"::None;

        if EDocument."Entry No" = 0 then begin
            EDocument.Insert(true);
            EDocumentProcessing.InsertServiceStatus(EDocument, EDocumentService, Enum::"E-Document Service Status"::Imported);
        end else begin
            EDocument.Modify(true);
            EDocumentProcessing.ModifyServiceStatus(EDocument, EDocumentService, Enum::"E-Document Service Status"::Imported);
        end;

        EDocumentLog.InsertLog(EDocument, EDocumentService, TempBlob, Enum::"E-Document Service Status"::Imported);
        EDocumentProcessing.ModifyEDocumentStatus(EDocument, Enum::"E-Document Service Status"::Imported);
    end;

    internal procedure GetBasicInfo(var EDocument: Record "E-Document")
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

    internal procedure ProcessDocument(var EDocument: Record "E-Document"; CreateJnlLine: Boolean)
    var
        EDocService: Record "E-Document Service";
        TempBlob: Codeunit "Temp Blob";
    begin
        if EDocument.Status = EDocument.Status::Processed then // TODO: Change to test field
            exit;

        DeleteAttachments(EDocument);

        EDocErrorHelper.ClearErrorMessages(EDocument);
        EDocService := EDocumentLog.GetLastServiceFromLog(EDocument);
        EDocumentLog.GetDocumentBlobFromLog(EDocument, EDocService, TempBlob, Enum::"E-Document Service Status"::Imported);

        ProcessImportedDocument(EDocument, EDocService, TempBlob, CreateJnlLine);
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

    internal procedure ReceiveDocument(EDocService: Record "E-Document Service")
    var
        EDocument, EDocument2 : Record "E-Document";
        EDocLog: Record "E-Document Log";
        TempBlob: Codeunit "Temp Blob";
        EDocIntegration: Interface "E-Document Integration";
        EDocumentServiceStatus: Enum "E-Document Service Status";
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
        I, EDocBatchDataStorageEntryNo, EDocCount : Integer;
        HasErrors, IsCreated, IsProcessed : Boolean;
    begin
        EDocIntegration := EDocService."Service Integration";
        EDocIntegration.ReceiveDocument(TempBlob, HttpRequest, HttpResponse);

        if not TempBlob.HasValue() then
            exit;

        EDocCount := EDocIntegration.GetDocumentCountInBatch(TempBlob);
        if EDocCount = 0 then
            exit;

        if EDocCount > 1 then
            EDocumentServiceStatus := Enum::"E-Document Service Status"::"Batch Imported"
        else
            EDocumentServiceStatus := Enum::"E-Document Service Status"::Imported;

        HasErrors := false;
        for I := 1 to EDocCount do begin
            IsCreated := false;
            IsProcessed := false;
            EDocument.Init();
            EDocument."Index In Batch" := I;
            OnBeforeInsertImportedEdocument(EDocument, EDocService, TempBlob, EDocCount, HttpRequest, HttpResponse, IsCreated, IsProcessed);

            if not IsCreated then begin
                EDocument."Entry No" := 0;
                EDocument.Status := EDocument.Status::"In Progress";
                EDocument.Direction := EDocument.Direction::Incoming;
                EDocument.Insert();

                if I = 1 then begin
                    EDocLog := EDocumentLog.InsertLog(EDocument, EDocService, TempBlob, EDocumentServiceStatus);
                    EDocBatchDataStorageEntryNo := EDocLog."E-Doc. Data Storage Entry No.";
                end else begin
                    EDocLog := EDocumentLog.InsertLog(EDocument, EDocService, EDocumentServiceStatus);
                    EDocumentLog.ModifyDataStorageEntryNo(EDocLog, EDocBatchDataStorageEntryNo);
                end;

                EDocumentLog.InsertIntegrationLog(EDocument, EDocService, HttpRequest, HttpResponse);
                EDocumentProcessing.InsertServiceStatus(EDocument, EDocService, EDocumentServiceStatus);
                EDocumentProcessing.ModifyEDocumentStatus(EDocument, EDocumentServiceStatus);

                OnAfterInsertImportedEdocument(EDocument, EDocService, TempBlob, EDocCount, HttpRequest, HttpResponse);
            end;

            if not IsProcessed then
                ProcessImportedDocument(EDocument, EDocService, TempBlob, EDocService."Create Journal Lines");

            if EDocErrorHelper.HasErrors(EDocument) then begin
                EDocument2 := EDocument;
                HasErrors := true;
            end;
        end;

        if HasErrors and GuiAllowed() then
            if Confirm(DocNotCreatedQst, true, EDocument2."Document Type") then
                Page.Run(Page::"E-Document", EDocument2);

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

        ProcessDocument(EDocument, false);
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
                TempEDocImportedLine.Insert(EDocument, SourceDocumentLine, TempEDocImportedLine);
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

    local procedure UpdateEDocumentRecordId(var EDocument: Record "E-Document"; EDocType: enum "E-Document Type"; DocNo: Code[20]; RecordId: RecordId)
    begin
        EDocument."Document Type" := EDocType;
        EDocument."Document No." := DocNo;
        EDocument.Validate("Document Record ID", RecordId);
        EDocument.Modify();
    end;

    local procedure ProcessImportedDocument(var EDocument: Record "E-Document"; var EDocService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; CreateJnlLine: Boolean)
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
            EDocumentProcessing.ModifyEDocumentStatus(EDocument, EDocServiceStatus);
            exit;
        end;

        ParseDocumentLines(EDocument, EDocService, TempBlob, SourceDocumentHeader, SourceDocumentLine, TempEDocMapping);
        if EDocErrorHelper.HasErrors(EDocument) then begin
            EDocServiceStatus := Enum::"E-Document Service Status"::"Imported document processing error";
            EDocumentLog.InsertLog(EDocument, EDocService, EDocServiceStatus);
            EDocumentProcessing.ModifyServiceStatus(EDocument, EDocService, EDocServiceStatus);
            EDocumentProcessing.ModifyEDocumentStatus(EDocument, EDocServiceStatus);
            exit;
        end;

        if ExistingOrderNo <> '' then
            EDocument."Order No." := ExistingOrderNo;

        if Vendor.Get(EDocument."Bill-to/Pay-to No.") then
            if ValidateEDocumentIsForPurchaseOrder(EDocument, Vendor) then
                ReceiveEDocumentToPurchaseOrder(EDocument, EDocService, SourceDocumentHeader, SourceDocumentLine, EDocServiceStatus, Vendor, Window)
            else
                ReceiveEDocumentToPurchaseDoc(EDocument, EDocService, SourceDocumentHeader, SourceDocumentLine, EDocServiceStatus, CreateJnlLine, Window)
        else
            EDocErrorHelper.LogErrorMessage(EDocument, Vendor, Vendor.FieldNo("No."), FailedToFindVendorErr);

        if EDocErrorHelper.HasErrors(EDocument) then
            EDocServiceStatus := Enum::"E-Document Service Status"::"Imported document processing error";

        EDocLog := EDocumentLog.InsertLog(EDocument, EDocService, EDocServiceStatus);
        EDocumentLog.InsertMappingLog(EDocLog, TempEDocMapping);
        EDocumentProcessing.ModifyServiceStatus(EDocument, EDocService, EDocServiceStatus);
        EDocumentProcessing.ModifyEDocumentStatus(EDocument, EDocServiceStatus);

        OnAfterProcessImportedDocument(EDocument, DocumentHeader);
    end;

    local procedure ValidateEDocumentIsForPurchaseOrder(var EDocument: Record "E-Document"; Vendor: Record Vendor): Boolean
    begin
        if EDocument."Document Type" = EDocument."Document Type"::"Purchase Credit Memo" then
            exit(false);
        exit(Vendor."Receive E-Document To" = Enum::"E-Document Type"::"Purchase Order");
    end;

#pragma warning disable AS0022
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
#pragma warning restore AS0022

    internal procedure ProcessEDocPendingOrderMatch(var EDocument: Record "E-Document")
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

        ProcessDocument(EDocument, EDocService."Create Journal Lines");
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

    local procedure ReceiveEDocumentToPurchaseDoc(var EDocument: Record "E-Document"; var EDocService: Record "E-Document Service"; var SourceDocumentHeader: RecordRef; var SourceDocumentLine: RecordRef; var EDocServiceStatus: Enum "E-Document Service Status"; CreateJnlLine: Boolean; var WindowInstance: Dialog)
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
        DocNotCreatedQst: Label 'Failed to create new Purchase %1 from E-Document. Do you want to open E-Document to see reported errors?', Comment = '%1 - Purchase Document Type';
        DocAlreadyExistsMsg: Label 'The document already exists.';
        DocTypeIsNotSupportedErr: Label 'Document type %1 is not supported.', Comment = '%1 - Document Type';
        FailedToFindVendorErr: Label 'No vendor is set for Edocument';
        CannotProcessEDocumentMsg: Label 'Cannot process E-Document %1 with Purchase Order %2 before Purchase Order has been matched and posted for E-Document %3.', Comment = '%1 - E-Document entry no, %2 - Purchase Order number, %3 - EDocument entry no.';

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

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateDocument(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var TempDocumentLine: RecordRef; var DocumentHeader: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateDocument(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var TempDocumentLine: RecordRef; var DocumentHeader: RecordRef)
    begin
    end;

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

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertImportedEdocument(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocCount: Integer; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertImportedEdocument(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocCount: Integer; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; var IsCreated: Boolean; var IsProcessed: Boolean)
    begin
    end;
}