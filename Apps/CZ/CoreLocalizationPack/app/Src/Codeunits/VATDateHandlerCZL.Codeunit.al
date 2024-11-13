// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Calculation;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.Inventory.Costing;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Service.Posting;
using System.Reflection;
using System.Security.User;

codeunit 11742 "VAT Date Handler CZL"
{

    Permissions = tabledata "G/L Entry" = m,
                  tabledata "VAT Entry" = m,
                  tabledata "Sales Invoice Header" = m,
                  tabledata "Sales Cr.Memo Header" = m,
                  tabledata "Purch. Inv. Header" = m,
                  tabledata "Purch. Cr. Memo Hdr." = m,
                  tabledata "Service Invoice Header" = m,
                  tabledata "Service Cr.Memo Header" = m,
                  tabledata "Cust. Ledger Entry" = m,
                  tabledata "Vendor Ledger Entry" = m;

    var
#if not CLEAN24
        GeneralLedgerSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
#endif
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";

    [EventSubscriber(ObjectType::Table, Database::"G/L Entry", 'OnAfterCopyGLEntryFromGenJnlLine', '', false, false)]
    local procedure UpdateVatDateOnAfterCopyGenJnlLineFromGLEntry(var GLEntry: Record "G/L Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GLEntry."VAT Reporting Date" := GenJournalLine."VAT Reporting Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Microsoft.Sales.Posting."Sales Post Invoice Events", 'OnAfterPrepareInvoicePostingBuffer', '', false, false)]
    local procedure UpdateInvoicePostingBufferOnAfterPrepareSales(var InvoicePostingBuffer: Record "Invoice Posting Buffer"; var SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        InvoicePostingBuffer."VAT Date CZL" := SalesHeader."VAT Reporting Date";
        InvoicePostingBuffer."Original Doc. VAT Date CZL" := SalesHeader."Original Doc. VAT Date CZL";
        InvoicePostingBuffer."Correction CZL" := SalesHeader.Correction xor SalesLine."Negative CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Microsoft.Purchases.Posting."Purch. Post Invoice Events", 'OnAfterPrepareInvoicePostingBuffer', '', false, false)]
    local procedure UpdateInvoicePostingBufferOnAfterPreparePurchase(var InvoicePostingBuffer: Record "Invoice Posting Buffer"; var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        InvoicePostingBuffer."VAT Date CZL" := PurchaseHeader."VAT Reporting Date";
        InvoicePostingBuffer."Original Doc. VAT Date CZL" := PurchaseHeader."Original Doc. VAT Date CZL";
        InvoicePostingBuffer."Correction CZL" := PurchaseHeader.Correction xor PurchaseLine."Negative CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service Post Invoice Events", 'OnAfterPrepareInvoicePostingBuffer', '', false, false)]
    local procedure UpdateInvoicePostingBufferOnAfterPrepareService(var InvoicePostingBuffer: Record "Invoice Posting Buffer"; var ServiceLine: Record "Service Line")
    var
        ServiceHeader: Record "Service Header";
    begin
        ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.");
        InvoicePostingBuffer."VAT Date CZL" := ServiceHeader."VAT Reporting Date";
        InvoicePostingBuffer."Correction CZL" := ServiceHeader.Correction xor ServiceLine."Negative CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnPostInvtPostBufOnBeforeSetAmt', '', false, false)]
    local procedure ClearVatDateOnPostInvtPostBufOnBeforeSetAmt(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."VAT Reporting Date" := 0D;
        GenJournalLine."Original Doc. VAT Date CZL" := 0D;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"G/L Entry-Edit", 'OnBeforeGLLedgEntryModify', '', false, false)]
    local procedure FillVATReportingDateOnBeforeGLLedgEntryModify(var GLEntry: Record "G/L Entry"; FromGLEntry: Record "G/L Entry")
    begin
        GLEntry."VAT Reporting Date" := FromGLEntry."VAT Reporting Date";
    end;

    procedure VATPeriodCZLCheck(VATDate: Date)
    var
        VATPeriodCZL: Record "VAT Period CZL";
        VATPeriodNotExistErr: Label '%1 does not exist for date %2.', Comment = '%1 = VAT Period TableCaption, %2 = VAT Date';
    begin
        VATPeriodCZL.SetRange("Starting Date", 0D, VATDate);
        if VATPeriodCZL.FindLast() then
            VATPeriodCZL.TestField(Closed, false)
        else
            Error(VATPeriodNotExistErr, VATPeriodCZL.TableCaption(), VATDate);
    end;
#if not CLEAN24

    [Obsolete('Replaced by IsVATDateInAllowedPeriod function in User Setup Management codeunit', '24.0')]
    procedure VATDateNotAllowed(VATDate: Date): Boolean
    var
        SetupRecordID: RecordId;
    begin
#pragma warning disable AL0432
        exit(IsVATDateCZLNotAllowed(VATDate, SetupRecordID));
#pragma warning restore AL0432
    end;

    [Obsolete('Replaced by IsVATDateInAllowedPeriod function in User Setup Management codeunit', '24.0')]
    procedure IsVATDateCZLNotAllowed(VATDate: Date; var SetupRecordID: RecordId): Boolean
    var
        VATAllowPostingFrom: Date;
        VATAllowPostingTo: Date;
    begin
        if UserId <> '' then
            if UserSetup.Get(UserId) then begin
                VATAllowPostingFrom := UserSetup."Allow VAT Posting From CZL";
                VATAllowPostingTo := UserSetup."Allow VAT Posting To CZL";
                SetupRecordID := UserSetup.RecordId;
            end;
        if (VATAllowPostingFrom = 0D) and (VATAllowPostingTo = 0D) then begin
            GeneralLedgerSetup.Get();
            VATAllowPostingFrom := GeneralLedgerSetup."Allow VAT Posting From CZL";
            VATAllowPostingTo := GeneralLedgerSetup."Allow VAT Posting To CZL";
            SetupRecordID := GeneralLedgerSetup.RecordId;
        end;
        if VATAllowPostingTo = 0D then
            VATAllowPostingTo := DMY2Date(31, 12, 9999);
        exit((VATDate < VATAllowPostingFrom) or (VATDate > VATAllowPostingTo));
    end;
#endif

    internal procedure IsVATDateInAllowedPeriod(VATDate: Date; var SetupRecordID: RecordID; var FieldNo: Integer): Boolean
    var
        UserSetupManagement: Codeunit "User Setup Management";
    begin
        exit(UserSetupManagement.IsVATDateInAllowedPeriod(VATDate, SetupRecordID, FieldNo));
    end;

    internal procedure IsVATDateInAllowedPeriod(VATDate: Date): Boolean
    var
        SetupRecordID: RecordId;
        FieldNo: Integer;
    begin
        exit(IsVATDateInAllowedPeriod(VATDate, SetupRecordID, FieldNo));
    end;

    procedure CheckVATDateCZL(GenJournalLine: Record "Gen. Journal Line")
    begin
        if not VATReportingDateMgt.IsVATDateEnabled() then
            GenJournalLine.TestField("VAT Reporting Date", GenJournalLine."Posting Date")
        else begin
            GenJournalLine.TestField("VAT Reporting Date");
            VATPeriodCZLCheck(GenJournalLine."VAT Reporting Date");
        end;
    end;

    procedure CheckVATDateCZL(var SalesHeader: Record "Sales Header")
    begin
        if not VATReportingDateMgt.IsVATDateEnabled() then
            SalesHeader.TestField("VAT Reporting Date", SalesHeader."Posting Date")
        else begin
            SalesHeader.TestField("VAT Reporting Date");
            VATPeriodCZLCheck(SalesHeader."VAT Reporting Date");
        end;
    end;

    procedure CheckVATDateCZL(var PurchaseHeader: Record "Purchase Header")
    var
        MustBeLessOrEqualErr: Label 'must be less or equal to %1', Comment = '%1 = fieldcaption of VAT Date';
    begin
        if not VATReportingDateMgt.IsVATDateEnabled() then
            PurchaseHeader.TestField("VAT Reporting Date", PurchaseHeader."Posting Date")
        else begin
            PurchaseHeader.TestField("VAT Reporting Date");
            VATPeriodCZLCheck(PurchaseHeader."VAT Reporting Date");
            if PurchaseHeader.Invoice then
                PurchaseHeader.TestField("Original Doc. VAT Date CZL");
            if PurchaseHeader."Original Doc. VAT Date CZL" > PurchaseHeader."VAT Reporting Date" then
                PurchaseHeader.FieldError("Original Doc. VAT Date CZL", StrSubstNo(MustBeLessOrEqualErr, PurchaseHeader.FieldCaption("VAT Reporting Date")));
        end;
    end;

    procedure CheckVATDateCZL(var ServiceHeader: Record "Service Header")
    begin
        if not VATReportingDateMgt.IsVATDateEnabled() then
            ServiceHeader.TestField("VAT Reporting Date", ServiceHeader."Posting Date")
        else begin
            ServiceHeader.TestField("VAT Reporting Date");
            VATPeriodCZLCheck(ServiceHeader."VAT Reporting Date");
        end;
    end;

    procedure InitVATDateFromRecordCZL(TableNo: Integer)
    var
        DummyGLEntry: Record "G/L Entry";
        DummyCustLedgerEntry: Record "Cust. Ledger Entry";
        DummyVATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        DataTypeManagement: Codeunit "Data Type Management";
        RecordRef: RecordRef;
        PostingDateFieldRef: FieldRef;
        VATDateFieldRef: FieldRef;
    begin
        RecordRef.Open(TableNo);
        if not DataTypeManagement.FindFieldByName(RecordRef, VATDateFieldRef, DummyGLEntry.FieldName("VAT Reporting Date")) then
            if not DataTypeManagement.FindFieldByName(RecordRef, VATDateFieldRef, DummyVATCtrlReportLineCZL.FieldName("VAT Date")) then
                DataTypeManagement.FindFieldByName(RecordRef, VATDateFieldRef, DummyCustLedgerEntry.FieldName("VAT Date CZL"));
        DataTypeManagement.FindFieldByName(RecordRef, PostingDateFieldRef, DummyCustLedgerEntry.FieldName("Posting Date"));
        VATDateFieldRef.SetRange(0D);
        PostingDateFieldRef.SetFilter('<>%1', 0D);
        if RecordRef.FindSet(true) then
            repeat
                VATDateFieldRef.Value := PostingDateFieldRef.Value;
                RecordRef.Modify();
            until RecordRef.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure InitVATReportingDateUsageOnAfteInsertEvent(var Rec: Record "General Ledger Setup")
    begin
        Rec."VAT Reporting Date Usage" := Rec."VAT Reporting Date Usage"::"Enabled (Prevent modification)";
    end;
}
