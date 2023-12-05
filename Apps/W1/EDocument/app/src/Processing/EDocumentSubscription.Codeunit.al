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
using Microsoft.Sales.Document;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Reminder;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Service.Posting;

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
    begin
        if (SalesInvHdrNo = '') and (SalesCrMemoHdrNo = '') then
            exit;

        if SalesInvHdrNo <> '' then begin
            if SalesInvHeader.Get(SalesInvHdrNo) then
                RunEDocumentCreation(SalesHeader, SalesInvHeader, SalesInvHdrNo);
        end else
            if SalesCrMemoHeader.Get(SalesCrMemoHdrNo) then
                RunEDocumentCreation(SalesHeader, SalesCrMemoHeader, SalesCrMemoHdrNo);
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
                RunEDocumentCreation(PurchaseHeader, PurchInvHeader, PurchInvHdrNo);
        end else
            if PurchCrMemoHdr.Get(PurchCrMemoHdrNo) then
                RunEDocumentCreation(PurchaseHeader, PurchCrMemoHdr, PurchCrMemoHdrNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnAfterPostServiceDoc', '', false, false)]
    local procedure OnAfterPostServiceDoc(var ServiceHeader: Record "Service Header"; ServShipmentNo: Code[20]; ServInvoiceNo: Code[20]; ServCrMemoNo: Code[20]; var ServDocumentsMgt: Codeunit "Serv-Documents Mgt."; CommitIsSuppressed: Boolean; PassedShip: Boolean; PassedConsume: Boolean; PassedInvoice: Boolean; WhseShip: Boolean)
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHdr: Record "Service Cr.Memo Header";
    begin
        if (ServInvoiceNo = '') and (ServCrMemoNo = '') then
            exit;

        if ServInvoiceNo <> '' then begin
            if ServiceInvoiceHeader.Get(ServInvoiceNo) then
                RunEDocumentCreation(ServiceHeader, ServiceInvoiceHeader, ServInvoiceNo);
        end else
            if ServiceCrMemoHdr.Get(ServCrMemoNo) then
                RunEDocumentCreation(ServiceHeader, ServiceCrMemoHdr, ServCrMemoNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FinChrgMemo-Issue", 'OnAfterIssueFinChargeMemo', '', false, false)]
    local procedure OnAfterIssueFinChargeMemo(var FinChargeMemoHeader: Record "Finance Charge Memo Header"; IssuedFinChargeMemoNo: Code[20])
    var
        IssuedFinChrgMemoHeader: Record "Issued Fin. Charge Memo Header";
    begin
        if IssuedFinChargeMemoNo = '' then
            exit;
        if IssuedFinChrgMemoHeader.Get(IssuedFinChargeMemoNo) then
            RunEDocumentCreation(FinChargeMemoHeader, IssuedFinChrgMemoHeader, IssuedFinChargeMemoNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reminder-Issue", 'OnAfterIssueReminder', '', false, false)]
    local procedure OnAfterIssueReminder(var ReminderHeader: Record "Reminder Header"; IssuedReminderNo: Code[20]; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
    begin
        if IssuedReminderNo = '' then
            exit;
        if IssuedReminderHeader.Get(IssuedReminderNo) then
            RunEDocumentCreation(ReminderHeader, IssuedReminderHeader, IssuedReminderNo);
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
    begin
        if not IsNullGuid(GenJnlLine.SystemId) then begin
            EDocument.SetRange("Journal Line System ID", GenJnlLine.SystemId);
            if EDocument.FindFirst() then begin
                EDocument."Document Record ID" := GLEntry.RecordId;
                EDocument."Document No." := GLEntry."Document No.";
                EDocument."Document Type" := EDocument."Document Type"::"G/L Entry";
                EDocument."Posting Date" := GLEntry."Posting Date";
                EDocument.Modify();
            end;
        end;
    end;

    local procedure RunEDocumentCheck(Record: Variant; EDocumentProcPhase: Enum "E-Document Processing Phase")
    var
        SourceDocumentHeader: RecordRef;
    begin
        SourceDocumentHeader.GetTable(Record);
        EDocument.SetRange("Document Record ID", SourceDocumentHeader.RecordId);
        if EDocumentHelper.IsElectronicDocument(SourceDocumentHeader) and EDocument.IsEmpty() then
            EDocExport.CheckEDocument(SourceDocumentHeader, EDocumentProcPhase);
    end;

    local procedure RunEDocumentCreation(OpenRecord: Variant; PostedRecord: Variant; PostedDocumentNo: Code[20])
    var
        OpenSourceDocumentHeader, PostedSourceDocumentHeader : RecordRef;
    begin
        PostedSourceDocumentHeader.GetTable(PostedRecord);
        OpenSourceDocumentHeader.GetTable(OpenRecord);
        EDocument.SetRange("Document Record ID", OpenSourceDocumentHeader.RecordId);
        if EDocument.FindFirst() then begin
            EDocument."Document Record ID" := PostedSourceDocumentHeader.RecordId;
            EDocument."Document No." := PostedDocumentNo;
            EDocument.Modify();
        end else
            if EDocumentHelper.IsElectronicDocument(PostedSourceDocumentHeader) then
                EDocExport.CreateEDocument(PostedSourceDocumentHeader);
    end;

    var
        EDocument: Record "E-Document";
        EDocExport: Codeunit "E-Doc. Export";
        EDocumentHelper: Codeunit "E-Document Helper";
        EDocumentProcessingPhase: Enum "E-Document Processing Phase";
}
