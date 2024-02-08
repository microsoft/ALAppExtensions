// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using System.Utilities;
using Microsoft.eServices.EDocument.OrderMatch;

codeunit 6140 "E-Doc. Import"
{
    Permissions =
        tabledata "E-Document" = im;

    internal procedure UploadDocument(var EDocument: Record "E-Document")
    var
        EDocumentService: Record "E-Document Service";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        FileName: Text;
    begin
        if Page.RunModal(Page::"E-Document Services", EDocumentService) = Action::LookupOK then begin
            UploadIntoStream('', '', '', FileName, InStr);

            TempBlob.CreateOutStream(OutStr);
            if CopyStream(OutStr, InStr) then begin
                EDocument.Direction := EDocument.Direction::Incoming;
                EDocument.Status := EDocument.Status::"In Progress";
                if EDocument."Entry No" = 0 then
                    EDocument.Insert(true)
                else
                    EDocument.Modify(true);

                EDocumentLog.InsertLog(EDocument, EDocumentService, TempBlob, Enum::"E-Document Service Status"::Imported);
            end;
        end;
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

    internal procedure ProcessDocument(var EDocument: Record "E-Document"; CreateJnlLine: Boolean)
    var
        EDocService: Record "E-Document Service";
        TempBlob: Codeunit "Temp Blob";
    begin
        EDocErrorHelper.ClearErrorMessages(EDocument);

        EDocService := EDocumentLog.GetLastServiceFromLog(EDocument);
        EDocumentLog.GetDocumentBlobFromLog(EDocument, EDocService, TempBlob, Enum::"E-Document Service Status"::Imported);

        ProcessImportedDocument(EDocument, EDocService, TempBlob, CreateJnlLine);

        if GuiAllowed and EDocErrorHelper.HasErrors(EDocument) then
            Message(DocNotCreatedMsg);
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

        EDocument.Modify();
    end;

    internal procedure ReceiveDocument(EDocService: Record "E-Document Service")
    var
        EDocument, EDocument2 : Record "E-Document";
        EDocumentLogRecord: Record "E-Document Log";
        TempBlob: Codeunit "Temp Blob";
        EDocIntegration: Interface "E-Document Integration";
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

        HasErrors := false;
        for I := 1 to EDocCount do begin
            OnBeforeInsertImportedEdocument(EDocument, EDocService, TempBlob, EDocCount, HttpRequest, HttpResponse, IsCreated, IsProcessed);

            if not IsCreated then begin
                EDocument.Init();
                EDocument."Entry No" := 0;
                EDocument.Status := EDocument.Status::"In Progress";
                EDocument.Direction := EDocument.Direction::Incoming;
                if EDocCount <> 1 then
                    EDocument."Index In Batch" := I;
                EDocument.Insert();
                if EDocCount = 1 then begin
                    EDocumentLogRecord.Get(EDocumentLog.InsertLog(EDocument, EDocService, TempBlob, Enum::"E-Document Service Status"::Imported));
                    EDocBatchDataStorageEntryNo := EDocumentLogRecord."E-Doc. Data Storage Entry No.";
                end else begin
                    EDocumentLogRecord.Get(EDocumentLog.InsertLog(EDocument, EDocService, Enum::"E-Document Service Status"::"Batch Imported"));
                    EDocumentLog.SetDataStorage(EDocumentLogRecord, EDocBatchDataStorageEntryNo);
                end;

                EDocumentLog.InsertIntegrationLog(EDocument, EDocService, HttpRequest, HttpResponse);

                OnAfterInsertImportedEdocument(EDocument, EDocService, TempBlob, EDocCount, HttpRequest, HttpResponse);
            end;


            if not IsProcessed then
                ProcessImportedDocument(EDocument, EDocService, TempBlob, EDocService."Create Journal Lines");

            if EDocErrorHelper.HasErrors(EDocument) then begin
                EDocument2 := EDocument;
                HasErrors := true;
            end;
        end;

        if HasErrors and GuiAllowed then
            if Confirm(DocNotCreatedQst) then
                Page.Run(Page::"E-Document", EDocument2);
    end;

    local procedure ProcessExistingOrder(var EDocument: Record "E-Document"; EDocService: Record "E-Document Service"; var SourceDocumentLine: RecordRef; DocumentHeader: RecordRef; var EDocServiceStatus: Enum "E-Document Service Status")
    var
        PurchaseOrderHeader: Record "Purchase Header";
        TempEDocImportedLine: Record "E-Doc. Imported Line" temporary;
        EDocument2: Record "E-Document";
        ErrorMessage: Record "Error Message";
        TempExistingErrorMessage: Record "Error Message" temporary;
        IsAnEDocAlreadyLinkedToPO: Boolean;
        ItemFound, UOMResolved : Boolean;
    begin
        DocumentHeader.SetTable(PurchaseOrderHeader);

        // We should mark Edoc pending if existing edoc is already linked
        EDocument2.SetRange("Document Record ID", PurchaseOrderHeader.RecordId());
        EDocument2.SetFilter(Status, '<>%1', Enum::"E-Document Status"::Processed);
        IsAnEDocAlreadyLinkedToPO := not EDocument2.IsEmpty();

        // Collect any error message
        ErrorMessage.SetContext(EDocument.RecordId());
        ErrorMessage.SetRange("Context Record ID", EDocument.RecordId());
        ErrorMessage.CopyToTemp(TempExistingErrorMessage);

        // Get lines
        if SourceDocumentLine.FindSet() then
            repeat

                if EDocService."Resolve Unit Of Measure" or EDocService."Lookup Item Reference" or
                   EDocService."Lookup Item GTIN" or EDocService."Lookup Account Mapping" or
                   EDocService."Validate Line Discount" then begin
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
        if IsAnEDocAlreadyLinkedToPO then begin
            EDocServiceStatus := EDocServiceStatus::Pending;
            EDocErrorHelper.LogWarningMessage(EDocument, EDocument2, EDocument2.FieldNo("Entry No"), StrSubstNo(CannotProcessEDocumentMsg, EDocument."Entry No", PurchaseOrderHeader."No.", EDocument2."Entry No"));
        end else
            EDocServiceStatus := EDocServiceStatus::"Order Linked";
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
        EDocument."Document Record ID" := RecordId;
        EDocument.Modify();
    end;

    local procedure ProcessImportedDocument(var EDocument: Record "E-Document"; var EDocService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; CreateJnlLine: Boolean)
    var
        TempEDocMapping: Record "E-Doc. Mapping" temporary;
        Vendor: Record Vendor;
        DocumentHeader, SourceDocumentHeader, SourceDocumentLine : RecordRef;
        EDocumentLogEntryNo: Integer;
        EDocServiceStatus: Enum "E-Document Service Status";
    begin
        if EDocument."Document No." <> '' then
            if GuiAllowed then
                if not Confirm(StrSubstNo(DocAlreadyCreatedQst, EDocument."Document Type", EDocument."Document No.", EDocument."Incoming E-Document No.")) then
                    exit;

        EDocErrorHelper.ClearErrorMessages(EDocument);

        GetDocumentBasicInfo(EDocument, EDocService, TempBlob);
        if EDocErrorHelper.HasErrors(EDocument) then begin
            EDocumentLog.InsertLog(EDocument, EDocService, TempBlob, Enum::"E-Document Service Status"::"Imported document processing error");
            exit;
        end;

        ParseDocumentLines(EDocument, EDocService, TempBlob, SourceDocumentHeader, SourceDocumentLine, TempEDocMapping);
        if EDocErrorHelper.HasErrors(EDocument) then begin
            EDocumentLog.InsertLog(EDocument, EDocService, TempBlob, Enum::"E-Document Service Status"::"Imported document processing error");
            exit;
        end;

        // Always handle corrective document, or handle based on vendor setting
        if Vendor.Get(EDocument."Bill-to/Pay-to No.") then
            case EDocument."Document Type" of
                "E-Document Type"::"Purchase Credit Memo":
                    ReceiveEDocumentToPurchaseDoc(EDocument, EDocService, SourceDocumentHeader, SourceDocumentLine, EDocServiceStatus, CreateJnlLine);
                else
                    case Vendor."Receive E-Document To" of
                        Enum::"E-Document Type"::"Purchase Invoice":
                            ReceiveEDocumentToPurchaseDoc(EDocument, EDocService, SourceDocumentHeader, SourceDocumentLine, EDocServiceStatus, CreateJnlLine);
                        Enum::"E-Document Type"::"Purchase Order":
                            ReceiveEDocumentToPurchaseOrder(EDocument, EDocService, SourceDocumentHeader, SourceDocumentLine, EDocServiceStatus, Vendor);
                        else begin
                            ReceiveEDocumentToPurchaseDoc(EDocument, EDocService, SourceDocumentHeader, SourceDocumentLine, EDocServiceStatus, CreateJnlLine);
                            Vendor."Receive E-Document To" := Vendor."Receive E-Document To"::"Purchase Invoice";
                            Vendor.Modify();
                        end;
                    end
            end
        else
            EDocErrorHelper.LogErrorMessage(EDocument, Vendor, Vendor.FieldNo("No."), FailedToFindVendorErr);

        if EDocErrorHelper.HasErrors(EDocument) then
            EDocumentLog.InsertLog(EDocument, EDocService, TempBlob, Enum::"E-Document Service Status"::"Imported document processing error")
        else begin
            EDocumentLogEntryNo := EDocumentLog.InsertLog(EDocument, EDocService, EDocServiceStatus);
            EDocumentLog.InsertMappingLog(EDocumentLogEntryNo, TempEDocMapping);
        end;
        OnAfterProcessImportedDocument(EDocument, DocumentHeader);
    end;

    procedure ReceiveEDocumentToPurchaseOrder(var EDocument: Record "E-Document"; var EDocService: Record "E-Document Service"; var SourceDocumentHeader: RecordRef; var SourceDocumentLine: RecordRef; var EDocServiceStatus: Enum "E-Document Service Status"; Vendor: Record Vendor)
    var
        DocumentHeader: RecordRef;
    begin
        EDocument."Document Type" := "E-Document Type"::"Purchase Order";
        EDocument.Modify();

        if (EDocument."Order No." = '') and not GuiAllowed() then begin
            EDocServiceStatus := Enum::"E-Document Service Status"::Pending;
            exit;
        end;

        if (EDocument."Order No." = '') and GuiAllowed() then
            FindPurchaseOrder(EDocument, Vendor);

        if OrderExists(EDocument, Vendor, DocumentHeader) then
            ProcessExistingOrder(EDocument, EDocService, SourceDocumentLine, DocumentHeader, EDocServiceStatus)
        else
            CreatePurchaseDocumentFromImportedDocument(EDocument, EDocService, SourceDocumentHeader, SourceDocumentLine, EDocServiceStatus, Enum::"Purchase Document Type"::Order);

    end;

    local procedure FindPurchaseOrder(var EDocument: Record "E-Document"; Vendor: Record Vendor)
    var
        PurchaseHeader: Record "Purchase Header";
        ConfirmManagement: Codeunit "Confirm Management";
        PurchaseOrderList: Page "Purchase Order List";
    begin
        if not GuiAllowed() then
            exit;

        PurchaseHeader.SetRange("Buy-from Vendor No.", Vendor."No.");
        PurchaseOrderList.SetTableView(PurchaseHeader);
        PurchaseOrderList.LookupMode(true);
        Commit();
        if PurchaseOrderList.RunModal() = Action::LookupOK then begin
            PurchaseOrderList.GetRecord(PurchaseHeader);
            if ConfirmManagement.GetResponseOrDefault(StrSubstNo(FindPurchaseOrderConfrimQst, PurchaseHeader."No.", EDocument."Entry No"), true) then begin
                EDocument."Order No." := PurchaseHeader."No.";
                EDocument.Modify();
            end;
        end;
    end;

    local procedure ReceiveEDocumentToPurchaseDoc(var EDocument: Record "E-Document"; var EDocService: Record "E-Document Service"; var SourceDocumentHeader: RecordRef; var SourceDocumentLine: RecordRef; var EDocServiceStatus: Enum "E-Document Service Status"; CreateJnlLine: Boolean)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseDocumentType: Enum "Purchase Document Type";
    begin
        PurchaseDocumentType := SourceDocumentHeader.Field(PurchaseHeader.FieldNo("Document Type")).Value();
        if CreateJnlLine then
            CreateJournalLineFromImportedDocument(EDocument, EDocService, EDocServiceStatus)
        else
            CreatePurchaseDocumentFromImportedDocument(EDocument, EDocService, SourceDocumentHeader, SourceDocumentLine, EDocServiceStatus, PurchaseDocumentType);
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
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SetRange("No.", EDocument."Order No.");
        PurchaseHeader.SetRange("Pay-to Vendor No.", Vendor."No.");

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

    var
        EDocumentLog: Codeunit "E-Document Log";
        EDocImportHelper: Codeunit "E-Document Import Helper";
        EDocErrorHelper: Codeunit "E-Document Error Helper";
        DocNotCreatedQst: Label 'The document was not created due to errors in the conversion process. Do you want to open the document?';
        DocNotCreatedMsg: Label 'The document was not created due to errors in the conversion process.';
        DocAlreadyExistsMsg: Label 'The document already exists.';
        DocAlreadyCreatedQst: Label 'The %1 %2 was already created for the electronic document %3. Do you want to create new document?', Comment = '%1 - Document Type, %2 - Document No., %3 - E-Document ID';
        DocTypeIsNotSupportedErr: Label 'Document type %1 is not supported.', Comment = '%1 - Document Type';
        FindPurchaseOrderConfrimQst: Label 'Are you sure you want to link Purchase Order %1 to E-Document %2?', Comment = '%1 - Purchase Order number, %2 - E-Document entry number';
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