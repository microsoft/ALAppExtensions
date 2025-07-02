// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Reporting;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.eServices.EDocument.OrderMatch;
using Microsoft.eServices.EDocument.Service.Participant;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Sales.Document;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Receivables;
using Microsoft.Utilities;
using Microsoft.Sales.Reminder;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Service.Posting;
using System.Automation;
using Microsoft.EServices.EDocument.Processing;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.IO.Peppol;
using Microsoft.Purchases.Setup;
using System.Utilities;

codeunit 6103 "E-Document Subscription"
{
    Access = Internal;
    Permissions =
        tabledata "E-Document" = m;

    // Release events
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReleaseSalesDoc', '', false, false)]
    local procedure OnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean; SkipCheckReleaseRestrictions: Boolean)
    begin
        RunEDocumentCheck(SalesHeader, EDocumentProcessingPhase::Release);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnBeforeReleasePurchaseDoc', '', false, false)]
    local procedure OnBeforeReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; var SkipCheckReleaseRestrictions: Boolean; var IsHandled: Boolean)
    begin
        RunEDocumentCheck(PurchaseHeader, EDocumentProcessingPhase::Release);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Service Document", 'OnBeforeReleaseServiceDoc', '', false, false)]
    local procedure OnBeforeReleaseServiceDoc(var ServiceHeader: Record "Service Header");
    begin
        RunEDocumentCheck(ServiceHeader, EDocumentProcessingPhase::Release);
    end;

    // Posting check events
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterCheckAndUpdate', '', false, false)]
    local procedure OnAfterCheckAndUpdateSales(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
        RunEDocumentCheck(SalesHeader, EDocumentProcessingPhase::Post);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterCheckAndUpdate', '', false, false)]
    local procedure OnAfterCheckAndUpdatePurch(var PurchaseHeader: Record "Purchase Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
        RunEDocumentCheck(PurchaseHeader, EDocumentProcessingPhase::Post);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnAfterInitialize', '', false, false)]
    local procedure OnAfterInitializeService(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line")
    begin
        RunEDocumentCheck(ServiceHeader, EDocumentProcessingPhase::Post);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FinChrgMemo-Issue", 'OnBeforeIssueFinChargeMemo', '', false, false)]
    local procedure OnBeforeIssueFinChargeMemo(var FinChargeMemoHeader: Record "Finance Charge Memo Header")
    begin
        RunEDocumentCheck(FinChargeMemoHeader, EDocumentProcessingPhase::Post);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reminder-Issue", 'OnBeforeIssueReminder', '', false, false)]
    local procedure OnBeforeIssueReminder(var ReminderHeader: Record "Reminder Header"; var ReplacePostingDate: Boolean; var PostingDate: Date; var IsHandled: Boolean; var IssuedReminderHeader: Record "Issued Reminder Header")
    begin
        RunEDocumentCheck(ReminderHeader, EDocumentProcessingPhase::Post);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        EDocumentProcessing: Codeunit "E-Document Processing";
    begin
        if (SalesInvHdrNo = '') and (SalesCrMemoHdrNo = '') then
            exit;

        if not EDocumentProcessing.GetDocSendingProfileForCust(SalesHeader."Bill-to Customer No.", DocumentSendingProfile) then
            exit;

        if SalesInvHdrNo <> '' then begin
            if SalesInvHeader.Get(SalesInvHdrNo) then
                CreateEDocumentFromPostedDocument(SalesInvHeader, DocumentSendingProfile, Enum::"E-Document Type"::"Sales Invoice");
        end else
            if SalesCrMemoHeader.Get(SalesCrMemoHdrNo) then
                CreateEDocumentFromPostedDocument(SalesCrMemoHeader, DocumentSendingProfile, Enum::"E-Document Type"::"Sales Credit Memo");
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure OnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20]; CommitIsSupressed: Boolean)
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        if (PurchInvHdrNo = '') and (PurchCrMemoHdrNo = '') then
            exit;

        if PurchInvHdrNo <> '' then begin
            if PurchInvHeader.Get(PurchInvHdrNo) then
                PointEDocumentToPostedDocument(PurchaseHeader, PurchInvHeader, PurchInvHdrNo, Enum::"E-Document Type"::"Purchase Invoice")
        end else
            if PurchCrMemoHdr.Get(PurchCrMemoHdrNo) then
                PointEDocumentToPostedDocument(PurchaseHeader, PurchCrMemoHdr, PurchCrMemoHdrNo, Enum::"E-Document Type"::"Purchase Credit Memo");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchases & Payables Setup", OnAfterShouldDocumentTotalAmountsBeChecked, '', false, false)]
    local procedure OnShouldDocumentTotalAmountsBeChecked(PurchaseHeader: Record "Purchase Header"; var ShouldDocumentTotalAmountsBeChecked: Boolean)
    var
        EDocument: Record "E-Document";
    begin
        if ShouldDocumentTotalAmountsBeChecked then
            exit;
        EDocument.SetRange(SystemId, PurchaseHeader."E-Document Link");
        if EDocument.FindFirst() then
            ShouldDocumentTotalAmountsBeChecked := EDocument.GetEDocumentService()."Verify Purch. Total Amounts";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchases & Payables Setup", OnCanDocumentTotalAmountsBeEditable, '', false, false)]
    local procedure OnCanDocumentTotalAmountsBeEditable(PurchaseHeader: Record "Purchase Header"; var CanDocumentTotalAmountsBeEdited: Boolean)
    var
        EDocument: Record "E-Document";
    begin
        if not CanDocumentTotalAmountsBeEdited then
            exit;
        if not EDocument.GetBySystemId(PurchaseHeader."E-Document Link") then
            exit;
        CanDocumentTotalAmountsBeEdited := not EDocument.IsSourceDocumentStructured();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnAfterPostServiceDoc', '', false, false)]
    local procedure OnAfterPostServiceDoc(var ServiceHeader: Record "Service Header"; ServShipmentNo: Code[20]; ServInvoiceNo: Code[20]; ServCrMemoNo: Code[20]; var ServDocumentsMgt: Codeunit "Serv-Documents Mgt."; CommitIsSuppressed: Boolean; PassedShip: Boolean; PassedConsume: Boolean; PassedInvoice: Boolean; WhseShip: Boolean)
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHdr: Record "Service Cr.Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        EDocumentProcessing: Codeunit "E-Document Processing";
    begin
        if (ServInvoiceNo = '') and (ServCrMemoNo = '') then
            exit;

        if not EDocumentProcessing.GetDocSendingProfileForCust(ServiceHeader."Bill-to Customer No.", DocumentSendingProfile) then
            exit;

        if ServInvoiceNo <> '' then begin
            if ServiceInvoiceHeader.Get(ServInvoiceNo) then
                CreateEDocumentFromPostedDocument(ServiceInvoiceHeader, DocumentSendingProfile, Enum::"E-Document Type"::"Service Invoice");
        end else
            if ServiceCrMemoHdr.Get(ServCrMemoNo) then
                CreateEDocumentFromPostedDocument(ServiceCrMemoHdr, DocumentSendingProfile, Enum::"E-Document Type"::"Service Credit Memo");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FinChrgMemo-Issue", 'OnAfterIssueFinChargeMemo', '', false, false)]
    local procedure OnAfterIssueFinChargeMemo(var FinChargeMemoHeader: Record "Finance Charge Memo Header"; IssuedFinChargeMemoNo: Code[20])
    var
        IssuedFinChrgMemoHeader: Record "Issued Fin. Charge Memo Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        EDocumentProcessing: Codeunit "E-Document Processing";
    begin
        if not EDocumentProcessing.GetDocSendingProfileForCust(FinChargeMemoHeader."Customer No.", DocumentSendingProfile) then
            exit;

        if IssuedFinChargeMemoNo = '' then
            exit;
        if IssuedFinChrgMemoHeader.Get(IssuedFinChargeMemoNo) then
            CreateEDocumentFromPostedDocument(IssuedFinChrgMemoHeader, DocumentSendingProfile, Enum::"E-Document Type"::"Issued Finance Charge Memo");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reminder-Issue", 'OnAfterIssueReminder', '', false, false)]
    local procedure OnAfterIssueReminder(var ReminderHeader: Record "Reminder Header"; IssuedReminderNo: Code[20]; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
        DocumentSendingProfile: Record "Document Sending Profile";
        EDocumentProcessing: Codeunit "E-Document Processing";
    begin
        if not EDocumentProcessing.GetDocSendingProfileForCust(ReminderHeader."Customer No.", DocumentSendingProfile) then
            exit;

        if IssuedReminderNo = '' then
            exit;
        if IssuedReminderHeader.Get(IssuedReminderNo) then
            CreateEDocumentFromPostedDocument(IssuedReminderHeader, DocumentSendingProfile, Enum::"E-Document Type"::"Issued Reminder");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Sending Profile", 'OnCheckElectronicSendingEnabled', '', false, false)]
    local procedure OnCheckElectronicSendingEnabled(var ExchServiceEnabled: Boolean)
    begin
        ExchServiceEnabled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Sending Profile", 'OnBeforeSend', '', false, false)]
    local procedure BeforeSendEDocument(Sender: Record "Document Sending Profile"; RecordVariant: Variant; var IsHandled: Boolean)
    begin
        if Sender."Electronic Document" <> Sender."Electronic Document"::"Extended E-Document Service Flow" then
            exit;

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterPostGLAcc', '', false, false)]
    local procedure OnAfterPostGLAcc(var GenJnlLine: Record "Gen. Journal Line"; var TempGLEntryBuf: Record "G/L Entry" temporary; var NextEntryNo: Integer; var NextTransactionNo: Integer; Balancing: Boolean; var GLEntry: Record "G/L Entry"; VATPostingSetup: Record "VAT Posting Setup")
    var
        EDocument: Record "E-Document";
    begin
        if not IsNullGuid(GenJnlLine.SystemId) then begin
            EDocument.SetRange("Journal Line System ID", GenJnlLine.SystemId);
            if EDocument.FindFirst() then begin
                EDocument.Validate("Document Record ID", GLEntry.RecordId);
                EDocument."Document No." := GLEntry."Document No.";
                EDocument."Document Type" := EDocument."Document Type"::"G/L Entry";
                EDocument."Posting Date" := GLEntry."Posting Date";
                EDocument.Modify();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeOnDelete', '', false, false)]
    local procedure OnBeforeOnDeletePurchaseHeader(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    var
        EDocument: Record "E-Document";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocImport: Codeunit "E-Doc. Import";
        ConfirmDialogMgt: Codeunit "Confirm Management";
    begin
        if IsNullGuid(PurchaseHeader."E-Document Link") then
            exit;

        if not EDocument.GetBySystemId(PurchaseHeader."E-Document Link") then
            exit;
        if not ConfirmDialogMgt.GetResponseOrDefault(StrSubstNo(DeleteDocumentQst, EDocument."Entry No")) then
            Error('');

        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Prepare draft";
        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Classification Eval. Data", 'OnCreateEvaluationDataOnAfterClassifyTablesToNormal', '', false, false)]
    local procedure ClassifyDataSensitivity()
    var
        DataClassificationEvalData: Codeunit "Data Classification Eval. Data";
    begin
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Doc. Service Data Exch. Def.");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Document");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Documents Setup");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Doc. Data Storage");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Document Integration Log");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Document Log");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Doc. Mapping");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Doc. Mapping Log");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Document Header Mapping");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Document Line Mapping");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Document Purchase Header");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Document Purchase Line");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Doc. Imported Line");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Doc. Order Match");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Doc. Service Supported Type");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Document Service");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Document Service Status");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"Service Participant");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Doc. Purchase Line History");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Document Line - Field");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"ED Purchase Line Field Setup");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Doc. Vendor Assign. History");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Doc. Record Link");
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"E-Document Notification");
#if not CLEAN26
        DataClassificationEvalData.SetTableFieldsToNormal(Database::"EDoc. Purch. Line Field Setup");
#endif
    end;

    local procedure RunEDocumentCheck(Record: Variant; EDocumentProcPhase: Enum "E-Document Processing Phase")
    var
        EDocument: Record "E-Document";
        SourceDocumentHeader: RecordRef;
    begin
        SourceDocumentHeader.GetTable(Record);
        EDocument.SetRange("Document Record ID", SourceDocumentHeader.RecordId);
        if EDocumentHelper.IsElectronicDocument(SourceDocumentHeader) and EDocument.IsEmpty() then
            EDocExport.CheckEDocument(SourceDocumentHeader, EDocumentProcPhase);
    end;

    local procedure IsEDocumentLinkedToPurchaseDocument(var EDocument: Record "E-Document"; OpenRecord: Variant): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        OpenSourceDocumentHeader: RecordRef;
    begin
        OpenSourceDocumentHeader.GetTable(OpenRecord);
        if OpenSourceDocumentHeader.Number() <> Database::"Purchase Header" then
            exit(false);

        OpenSourceDocumentHeader.SetTable(PurchaseHeader);
        PurchaseHeader.SetRecFilter();
        if EDocument.GetBySystemId(PurchaseHeader."E-Document Link") then
            exit(true);
    end;

    local procedure RemoveEDocumentLinkFromPurchaseDocument(OpenRecord: Variant)
    var
        PurchaseHeader: Record "Purchase Header";
        OpenSourceDocumentHeader: RecordRef;
        NullGuid: Guid;
    begin
        OpenSourceDocumentHeader.GetTable(OpenRecord);
        if OpenSourceDocumentHeader.Number() <> Database::"Purchase Header" then
            exit;

        OpenSourceDocumentHeader.SetTable(PurchaseHeader);
        PurchaseHeader.SetRecFilter();
        if not PurchaseHeader.IsEmpty() then begin
            PurchaseHeader.Validate("E-Document Link", NullGuid);
            PurchaseHeader.Modify();
        end;
    end;

    local procedure UpdateToPostedPurchaseEDocument(var EDocument: Record "E-Document"; PostedRecord: Variant; PostedDocumentNo: Code[20]; DocumentType: Enum "E-Document Type")
    var
        EDocService: Record "E-Document Service";
        EDocumentLog: Codeunit "E-Document Log";
        EDocLogHelper: Codeunit "E-Document Log Helper";
        PostedSourceDocumentHeader: RecordRef;
    begin
        PostedSourceDocumentHeader.GetTable(PostedRecord);
        EDocument.Validate("Document Record ID", PostedSourceDocumentHeader.RecordId);
        EDocument."Document No." := PostedDocumentNo;
        EDocument."Document Type" := DocumentType;
        EDocument.Status := Enum::"E-Document Status"::Processed;
        EDocument.Modify(true);

        EDocService := EDocumentLog.GetLastServiceFromLog(EDocument);
        EDocLogHelper.InsertLog(EDocument, EDocService, Enum::"E-Document Service Status"::"Imported Document Created");
    end;

    local procedure CreateEDocumentFromPostedDocument(PostedRecord: Variant; DocumentSendingProfile: Record "Document Sending Profile"; DocumentType: Enum "E-Document Type")
    var
        WorkFlow: Record Workflow;
        PostedSourceDocumentHeader: RecordRef;
    begin
        PostedSourceDocumentHeader.GetTable(PostedRecord);
        if (DocumentSendingProfile."Electronic Document" <> DocumentSendingProfile."Electronic Document"::"Extended E-Document Service Flow") then
            exit;

        if not WorkFlow.Get(DocumentSendingProfile."Electronic Service Flow") then
            Error(DocumentSendingProfileWithWorkflowErr, DocumentSendingProfile."Electronic Service Flow", Format(DocumentSendingProfile."Electronic Document"::"Extended E-Document Service Flow"), DocumentSendingProfile.Code);

        WorkFlow.TestField(Enabled);
        if DocumentSendingProfile."Electronic Document" = DocumentSendingProfile."Electronic Document"::"Extended E-Document Service Flow" then
            EDocExport.CreateEDocument(PostedSourceDocumentHeader, WorkFlow, DocumentType);
    end;

    local procedure PointEDocumentToPostedDocument(OpenRecord: Variant; PostedRecord: Variant; PostedDocumentNo: Code[20]; DocumentType: Enum "E-Document Type")
    var
        EDocument: Record "E-Document";
    begin
        if IsEDocumentLinkedToPurchaseDocument(EDocument, OpenRecord) then begin
            Edocument.TestField(Direction, Enum::"E-Document Direction"::Incoming);
            UpdateToPostedPurchaseEDocument(EDocument, PostedRecord, PostedDocumentNo, DocumentType);
            RemoveEDocumentLinkFromPurchaseDocument(OpenRecord);
        end;
    end;

    var
        EDocExport: Codeunit "E-Doc. Export";
        EDocumentHelper: Codeunit "E-Document Helper";
        EDocumentProcessingPhase: Enum "E-Document Processing Phase";
        DeleteDocumentQst: Label 'This document is linked to E-Document %1. Do you want to continue?', Comment = '%1 - E-Document Entry No.';
        DocumentSendingProfileWithWorkflowErr: Label 'Workflow %1 defined for %2 in Document Sending Profile %3 is not found.', Comment = '%1 - The workflow code, %2 - Enum value set in Electronic Document, %3 - Document Sending Profile Code';
}
