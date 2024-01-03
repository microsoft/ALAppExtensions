// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Document;
using System.Utilities;

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
        if Page.RunModal(Page::"E-Document Services", EDocumentService) <> Action::LookupOK then
            exit;

        if not UploadIntoStream('', '', '', FileName, InStr) then
            exit;

        TempBlob.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);

        EDocument.Direction := EDocument.Direction::Incoming;
        EDocument.Status := EDocument.Status::"In Progress";
        if EDocument."Entry No" = 0 then
            EDocument.Insert(true)
        else
            EDocument.Modify(true);

        EDocumentLog.InsertLog(EDocument, EDocumentService, TempBlob, Enum::"E-Document Service Status"::Imported);
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

    internal procedure ProcessDocument(var EDocument: Record "E-Document"; UpdateOrder: Boolean; CreateJnlLine: Boolean)
    var
        EDocService: Record "E-Document Service";
        TempBlob: Codeunit "Temp Blob";
    begin
        EDocErrorHelper.ClearErrorMessages(EDocument);

        EDocService := EDocumentLog.GetLastServiceFromLog(EDocument);
        EDocumentLog.GetDocumentBlobFromLog(EDocument, EDocService, TempBlob, Enum::"E-Document Service Status"::Imported);

        ProcessImportedDocument(EDocument, EDocService, TempBlob, UpdateOrder, CreateJnlLine);

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
                ProcessImportedDocument(EDocument, EDocService, TempBlob, EDocService."Update Order", EDocService."Create Journal Lines");

            if EDocErrorHelper.HasErrors(EDocument) then begin
                EDocument2 := EDocument;
                HasErrors := true;
            end;
        end;

        if HasErrors and GuiAllowed then
            if Confirm(DocNotCreatedQst) then
                Page.Run(Page::"E-Document", EDocument2);
    end;

    local procedure ProcessImportedDocument(var EDocument: Record "E-Document"; var EDocService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; UpdateOrder: Boolean; CreateJnlLine: Boolean)
    var
        TempEDocMapping: Record "E-Doc. Mapping" temporary;
        PurchHeader: Record "Purchase Header";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentHeader, GenJnlLine, SourceDocumentHeader, SourceDocumentLine : RecordRef;
        EDocumentLogEntryNo: Integer;
        EDocStatus: Enum "E-Document Service Status";
    begin
        if EDocument."Document No." <> '' then
            if GuiAllowed then
                if not Confirm(StrSubstNo(DocAlreadyCreatedQst, EDocument."Document Type", EDocument."Document No.", EDocument."Incoming E-Document No.")) then
                    exit;

        EDocErrorHelper.ClearErrorMessages(EDocument);

        GetDocumentBasicInfo(EDocument, EDocService, TempBlob);

        if not CreateJnlLine then
            PrepareReceivedEDocument(EDocument, TempBlob, SourceDocumentHeader, SourceDocumentLine, TempEDocMapping);

        if EDocumentHasErrors(EDocument, EDocService, TempBlob) then
            exit;

        // Commit before creating document with error handling (if Codeunit.Run then )
        Commit();

        if CreateJnlLine then begin
            CreateJournalLine(EDocument, GenJnlLine);
            EDocStatus := EDocStatus::"Journal Line Created";
            if GenJnlLine.Number <> 0 then
                EDocument."Journal Line System ID" := GenJnlLine.Field(GenJnlLine.SystemIdNo).Value;
        end else
            if UpdateOrder and OrderExists(EDocument, DocumentHeader) then begin
                UpdateDocument(EDocument, SourceDocumentHeader, SourceDocumentLine, DocumentHeader);
                EDocStatus := EDocStatus::"Order Updated";
            end else begin
                CreateDocument(EDocument, SourceDocumentHeader, SourceDocumentLine, DocumentHeader);
                EDocStatus := EDocStatus::"Imported Document Created";
            end;

        if EDocumentHasErrors(EDocument, EDocService, TempBlob) then
            exit;

        if not CreateJnlLine then begin
            if EDocService."Apply Invoice Discount" then
                EDocImportHelper.ApplyInvoiceDiscount(EDocument, SourceDocumentHeader, DocumentHeader);

            if EDocService."Verify Totals" then
                EDocImportHelper.VerifyTotal(EDocument, SourceDocumentHeader, DocumentHeader);
        end;

        case EDocument."Document Type" of
            EDocument."Document Type"::"Purchase Invoice", EDocument."Document Type"::"Purchase Credit Memo":
                if CreateJnlLine then begin
                    EDocument."Document Type" := EDocument."Document Type"::"General Journal";
                    EDocument."Document No." := GenJnlLine.Field(GenJournalLine.FieldNo("Document No.")).Value();
                    EDocument."Document Record ID" := GenJnlLine.RecordId;
                end else begin
                    if EDocStatus = EDocStatus::"Order Updated" then
                        EDocument."Document Type" := EDocument."Document Type"::"Purchase Order";
                    EDocument."Document No." := DocumentHeader.Field(PurchHeader.FieldNo("No.")).Value();
                    EDocument."Document Record ID" := DocumentHeader.RecordId;
                end;
        end;

        EDocument.Status := EDocStatus;
        EDocument.Modify();

        OnAfterProcessImportedDocument(EDocument, DocumentHeader);

        EDocumentLogEntryNo := EDocumentLog.InsertLog(EDocument, EDocService, TempBlob, EDocStatus);
        EDocumentLog.InsertMappingLog(EDocumentLogEntryNo, TempEDocMapping);
    end;

    local procedure PrepareReceivedEDocument(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; SourceDocumentHeader: RecordRef; SourceDocumentLine: RecordRef; TempEDocMapping: Record "E-Doc. Mapping" temporary)
    var
        EDocService: Record "E-Document Service";
        EDocExport: Codeunit "E-Doc. Export";
        EDocGetFullInfo: Codeunit "E-Doc. Get Complete Info";
        SourceDocumentHeaderMapped, SourceDocumentLineMapped : RecordRef;
        EDocInterface: Interface "E-Document";
        ItemFound, UOMResolved : Boolean;
    begin
        OnBeforePrepareReceivedDoc(EDocument, TempBlob, SourceDocumentHeader, SourceDocumentLine, TempEDocMapping);

        case EDocument."Document Type" of
            EDocument."Document Type"::"Purchase Invoice", EDocument."Document Type"::"Purchase Credit Memo":
                begin
                    SourceDocumentHeader.Open(Database::"Purchase Header", true);
                    SourceDocumentLine.Open(Database::"Purchase Line", true);
                end;
            else
                EDocErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(DocTypeIsNotSupportedErr, EDocument."Document Type"));
        end;

        if SourceDocumentHeader.Number <> 0 then begin
            EDocService := EDocumentLog.GetLastServiceFromLog(EDocument);
            EDocInterface := EDocService."Document Format";

            // Commit before getting full info with error handling (if Codeunit.Run then )
            Commit();
            EDocGetFullInfo.SetValues(EDocInterface, EDocument, SourceDocumentHeader, SourceDocumentLine, TempBlob);
            if EDocGetFullInfo.Run() then begin
                EDocGetFullInfo.GetValues(EDocInterface, EDocument, SourceDocumentHeader, SourceDocumentLine, TempBlob);
                EDocExport.MapEDocument(SourceDocumentHeader, SourceDocumentLine, EDocService, SourceDocumentHeaderMapped, SourceDocumentLineMapped, TempEDocMapping, true);

                if EDocService."Resolve Unit Of Measure" or EDocService."Lookup Item Reference" or
                    EDocService."Lookup Item GTIN" or EDocService."Lookup Account Mapping" or
                    EDocService."Validate Line Discount"
                then
                    if SourceDocumentLineMapped.FindSet() then
                        repeat
                            ItemFound := false;
                            UOMResolved := false;

                            if EDocService."Resolve Unit Of Measure" then
                                UOMResolved := EDocImportHelper.ResolveUnitOfMeasureFromDataImport(EDocument, SourceDocumentLineMapped)
                            else
                                UOMResolved := true;

                            // Lookup Item Ref, then GTIN/Bar Code, else G/L Account
                            if UOMResolved then begin
                                if EDocService."Lookup Item Reference" then
                                    ItemFound := EDocImportHelper.FindItemReferenceForLine(EDocument, SourceDocumentLineMapped);

                                if (not ItemFound) and EDocService."Lookup Item GTIN" then
                                    ItemFound := EDocImportHelper.FindItemForLine(EDocument, SourceDocumentLineMapped);

                                if (not ItemFound) and EDocService."Lookup Account Mapping" then
                                    ItemFound := EDocImportHelper.FindGLAccountForLine(EDocument, SourceDocumentLineMapped);

                                if not ItemFound then
                                    EDocImportHelper.LogErrorIfItemNotFound(EDocument, SourceDocumentLineMapped);
                            end;

                            if EDocService."Validate Line Discount" then
                                EDocImportHelper.ValidateLineDiscount(EDocument, SourceDocumentLineMapped);

                            SourceDocumentLineMapped.Modify();
                        until SourceDocumentLineMapped.Next() = 0;


                SourceDocumentHeader.Copy(SourceDocumentHeaderMapped, true);
                SourceDocumentLine.Copy(SourceDocumentLineMapped, true);
            end else
                EDocErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());

            OnAfterPrepareReceivedDoc(EDocument, TempBlob, SourceDocumentHeader, SourceDocumentLine, TempEDocMapping);
        end;
    end;

    local procedure UpdateDocument(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var TempDocumentLine: RecordRef; var DocumentHeader: RecordRef)
    var
        EDocumentUpdateOrder: Codeunit "E-Document Update Order";
    begin
        ClearLastError();

        OnBeforeUpdateDocument(EDocument, TempDocumentHeader, TempDocumentLine, DocumentHeader);

        case TempDocumentHeader.Number of
            Database::"Purchase Header":
                begin
                    Clear(EDocumentUpdateOrder);
                    EDocumentUpdateOrder.SetSource(EDocument, TempDocumentHeader, TempDocumentLine, DocumentHeader);
                    if EDocumentUpdateOrder.Run() then
                        DocumentHeader := EDocumentUpdateOrder.GetUpdatedDocument()
                    else
                        EDocErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());
                end;
        end;

        OnAfterUpdateDocument(EDocument, TempDocumentHeader, TempDocumentLine, DocumentHeader);
    end;

    local procedure CreateDocument(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var TempDocumentLine: RecordRef; var DocumentHeader: RecordRef)
    var
        EDocumentCreatePurchase: Codeunit "E-Document Create Purch. Doc.";
    begin
        ClearLastError();

        OnBeforeCreateDocument(EDocument, TempDocumentHeader, TempDocumentLine, DocumentHeader);

        case TempDocumentHeader.Number of
            Database::"Purchase Header":
                begin
                    Clear(EDocumentCreatePurchase);
                    EDocumentCreatePurchase.SetSource(EDocument, TempDocumentHeader, TempDocumentLine);
                    if EDocumentCreatePurchase.Run() then
                        DocumentHeader := EDocumentCreatePurchase.GetCreatedDocument()
                    else
                        EDocErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());
                end;
        end;

        OnAfterCreateDocument(EDocument, TempDocumentHeader, TempDocumentLine, DocumentHeader);
    end;

    local procedure CreateJournalLine(var EDocument: Record "E-Document"; var JnlLine: RecordRef)
    var
        EDocumentCreateJnlLine: Codeunit "E-Document Create Jnl. Line";
    begin
        ClearLastError();

        OnBeforeCreateJournalLine(EDocument, JnlLine);

        case EDocument."Document Type" of
            EDocument."Document Type"::"Purchase Invoice", EDocument."Document Type"::"Purchase Credit Memo":
                begin
                    Clear(EDocumentCreateJnlLine);
                    EDocumentCreateJnlLine.SetSource(EDocument);
                    if EDocumentCreateJnlLine.Run() then
                        JnlLine := EDocumentCreateJnlLine.GetCreatedJnlLine()
                    else
                        EDocErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());
                end;
        end;

        OnAfterCreateJournalLine(EDocument, JnlLine);
    end;

    local procedure EDocumentHasErrors(var EDocument: Record "E-Document"; var EDocService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"): Boolean
    begin
        if EDocErrorHelper.HasErrors(EDocument) then begin
            EDocumentLog.InsertLog(EDocument, EDocService, TempBlob, Enum::"E-Document Service Status"::"Imported document processing error");
            exit(true);
        end;
    end;

    local procedure OrderExists(EDocument: Record "E-Document"; var DocumentHeader: RecordRef): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        case EDocument."Document Type" of
            EDocument."Document Type"::"Purchase Invoice":
                begin
                    PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
                    PurchaseHeader.SetRange("No.", EDocument."Order No.");
                    PurchaseHeader.SetRange("Pay-to Vendor No.", EDocument."Bill-to/Pay-to No.");
                    if PurchaseHeader.FindFirst() then begin
                        DocumentHeader.GetTable(PurchaseHeader);
                        exit(true);
                    end;
                end;
        end;
        exit(false);
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