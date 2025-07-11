// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Application;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;
using Microsoft.Utilities;

codeunit 18434 "GST Application Session Mgt."
{
    SingleInstance = true;

    var
        OnlineCustomerLedgerEntry: Record "Cust. Ledger Entry";
        OnlineVendorLedgerEntry: Record "Vendor Ledger Entry";
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        GSTTransactionType: Enum "Detail Ledger Transaction Type";
        OnlineCustomerLedgerEntryNo: Integer;
        OnlineVendorLedgerEntryNo: Integer;
        OnlinePostApplicationLastEntryNo: Integer;
        SubcontractingLastGLEntryNo: Integer;
        GLRegisterLastEntryNo: Integer;
        LastUsedItemLedgEntryNo: Integer;
        LastUsedItemApplnEntryNo: Integer;
        LastUsedValueEntryNo: Integer;
        IsSubcontracting: Boolean;
        SubConReceiving: Boolean;
        SubConReceivingMultiple: Boolean;
        IsOnlinePostApplication: Boolean;
        IsCopyDocument: Boolean;
        TransactionNo: Integer;
        AppliestoIDReceipt: Code[50];
        VendorNo: Code[20];
        CustomerNo: Code[20];
        AppliedAmount: Decimal;
        AppliedAmountLCY: Decimal;
        GSTApplicationJournalPostingStarted: Boolean;
        TotalTDSInclSHECessAmount: Decimal;
        TotalTCSInclSHECESSAmount: Decimal;
        GSTAmountLoaded: Decimal;

    procedure SetGSTApplicationSourcePurch(
        TransNo: Integer;
        VendNo: Code[20])
    begin
        GSTTransactionType := GSTTransactionType::Purchase;
        TransactionNo := TransNo;
        VendorNo := VendNo;
        ClearApplicationGenJnlLine();
    end;

    procedure GetGSTApplicationSourcePurch(
        var TransNo: Integer;
        var GSTTransType: Enum "Detail Ledger Transaction Type";
        var VendNo: Code[20])
    begin
        TransNo := TransactionNo;
        GSTTransType := GSTTransType::Purchase;
        VendNo := VendorNo;
    end;

    procedure SetGSTApplicationSourceSales(
        TransNo: Integer;
        CustNo: Code[20])
    begin
        GSTTransactionType := GSTTransactionType::Sales;
        TransactionNo := TransNo;
        CustomerNo := CustNo;
        ClearApplicationGenJnlLine();
    end;

    procedure GetGSTApplicationSourceSales(
        var TransNo: Integer;
        var GSTTransType: Enum "Detail Ledger Transaction Type";
        var CustNo: Code[20])
    begin
        TransNo := TransactionNo;
        GSTTransType := GSTTransType::Sales;
        CustNo := CustomerNo;
    end;

    procedure GetGSTTransactionType(var GSTTransType: Enum "Detail Ledger Transaction Type")
    begin
        GSTTransType := GSTTransactionType;
    end;

    procedure SetGSTApplicationAmount(
        AppliedAmt: Decimal;
        AppliedAmtLCY: Decimal)
    begin
        AppliedAmount := AppliedAmt;
        AppliedAmountLCY := AppliedAmtLCY;
    end;

    procedure GetGSTApplicationAmount(
        var AppliedAmt: Decimal;
        var AppliedAmtLCY: Decimal)
    begin
        AppliedAmt := AppliedAmount;
        AppliedAmtLCY := AppliedAmountLCY;
    end;

    procedure SetOnlineCustLedgerEntry(OnlineCustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        if OnlineCustLedgerEntry."Entry No." > OnlineCustomerLedgerEntryNo then begin
            OnlineCustomerLedgerEntryNo := OnlineCustLedgerEntry."Entry No.";
            OnlineCustomerLedgerEntry := OnlineCustLedgerEntry;
        end;
    end;

    procedure GetOnlineCustLedgerEntry(var OnlineCustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        OnlineCustLedgerEntry := OnlineCustomerLedgerEntry;
    end;

    procedure SetOnlineVendLedgerEntry(OnlineVendLedgerEntry: Record "Vendor Ledger Entry")
    begin
        if OnlineVendLedgerEntry."Entry No." > OnlineVendorLedgerEntryNo then begin
            OnlineVendorLedgerEntryNo := OnlineVendLedgerEntry."Entry No.";
            OnlineVendorLedgerEntry := OnlineVendLedgerEntry;
            OnlineVendLedgerEntry.CalcFields(Amount);
        end;
    end;

    procedure GetOnlineVendLedgerEntry(var OnlineVendLedgerEntry: Record "Vendor Ledger Entry")
    begin
        OnlineVendLedgerEntry := OnlineVendorLedgerEntry;
    end;

    procedure SetOnlinePostApplication(pIsOnlinePostApplication: Boolean)
    begin
        IsOnlinePostApplication := pIsOnlinePostApplication;
    end;

    procedure GetOnlinePostApplication(): Boolean
    begin
        exit(IsOnlinePostApplication);
    end;

    procedure SetOnlinePostApplicationLastEntryNo(pOnlinePostApplicationLastEntryNo: Integer)
    begin
        OnlinePostApplicationLastEntryNo := pOnlinePostApplicationLastEntryNo;
    end;

    procedure GetOnlinePostApplicationLastEntryNo(): Integer
    begin
        exit(OnlinePostApplicationLastEntryNo);
    end;

    procedure SetOnlinePostApplicationLastEntryNoForGLRegister(pGLRegisterLastEntryNo: Integer)
    begin
        GLRegisterLastEntryNo := pGLRegisterLastEntryNo;
    end;

    procedure GetOnlinePostApplicationLastEntryNoForGLRegister(): Integer
    begin
        exit(GLRegisterLastEntryNo);
    end;

    procedure SetSubcontractingEntryNo(ItemLedgEntryNo: Integer; ItemApplnEntryNo: Integer; ValueEntryNo: Integer)
    begin
        LastUsedItemLedgEntryNo := ItemLedgEntryNo;
        LastUsedItemApplnEntryNo := ItemApplnEntryNo;
        LastUsedValueEntryNo := ValueEntryNo;
    end;

    procedure SetSubcontractingItemLedgEntryNo(pItemLedgEntryNo: Integer)
    begin
        LastUsedItemLedgEntryNo := pItemLedgEntryNo;
    end;

    procedure SetSubcontractingItemApplnEntryNo(pItemApplnEntryNo: Integer)
    begin
        LastUsedItemApplnEntryNo := pItemApplnEntryNo;
    end;

    procedure GetSubcontractingEntryNo(var LastItemLedgEntryNo: Integer; var LastItemApplnEntryNo: Integer; var LastValueEntryNo: Integer)
    begin
        LastItemLedgEntryNo := LastUsedItemLedgEntryNo;
        LastItemApplnEntryNo := LastUsedItemApplnEntryNo;
        LastValueEntryNo := LastUsedValueEntryNo;
    end;

    procedure SetSubcontractingLastGLEntryNo(SubconLastGLEntryNo: Integer)
    begin
        SubcontractingLastGLEntryNo := SubconLastGLEntryNo;
    end;

    procedure GetSubcontractingLastGLEntryNo(): Integer
    begin
        exit(SubcontractingLastGLEntryNo);
    end;

    procedure SetSubContractingReceiving(SubConReceive: Boolean)
    begin
        SubConReceiving := SubConReceive;
    end;

    procedure GetSubContractingReceiving(): Boolean
    begin
        exit(SubConReceiving);
    end;

    procedure SetSubContractingReceivingMultiple(SubConReceiveMultiple: Boolean; AppliestoID: Code[50])
    begin
        SubConReceivingMultiple := SubConReceiveMultiple;
        AppliestoIDReceipt := AppliestoID;
    end;

    procedure SetSubcontracting(IsSubcon: Boolean)
    begin
        IsSubcontracting := IsSubcon;
    end;

    procedure GetSubcontracting(): Boolean
    begin
        exit(IsSubcontracting);
    end;

    procedure GetSubContractingReceivingMultiple(var AppliestoID: Code[50]): Boolean
    begin
        AppliestoID := AppliestoIDReceipt;
        exit(SubConReceivingMultiple);
    end;

    procedure CreateApplicationGenJournallLine(
        var GenJournalLine: Record "Gen. Journal Line";
        GLAccountNo: Code[20];
        Amount: Decimal;
        SystemCreatedEntry: Boolean)
    begin
        TempGenJournalLine.Init();
        TempGenJournalLine := GenJournalLine;
        TempGenJournalLine."Line No." := GetTempGenJournalNextLineNo();
        TempGenJournalLine."Account Type" := TempGenJournalLine."Account Type"::"G/L Account";
        TempGenJournalLine."Account No." := GLAccountNo;
        TempGenJournalLine.Description := CopyStr(GetGLAccountDescription(GLAccountNo), 1, MaxStrLen(TempGenJournalLine.Description));
        TempGenJournalLine."Bal. Account Type" := TempGenJournalLine."Bal. Account Type"::"G/L Account";
        TempGenJournalLine."Bal. Account No." := '';
        TempGenJournalLine.Amount := Amount;
        TempGenJournalLine."Amount (LCY)" := Amount;
        if Amount > 0 then begin
            TempGenJournalLine."Debit Amount" := Amount;
            TempGenJournalLine."Credit Amount" := 0;
        end else begin
            TempGenJournalLine."Debit Amount" := 0;
            TempGenJournalLine."Credit Amount" := Amount;
        end;

        TempGenJournalLine."System-Created Entry" := true;
        TempGenJournalLine."Applies-to Doc. Type" := TempGenJournalLine."Applies-to Doc. Type"::" ";
        TempGenJournalLine."Applies-to Doc. No." := '';
        TempGenJournalLine."Applies-to ID" := '';
        TempGenJournalLine."Pmt. Discount Date" := 0D;
        TempGenJournalLine."Payment Discount %" := 0;
        Clear(TempGenJournalLine."Tax ID");
        TempGenJournalLine.Insert();
    end;

    procedure PostApplicationGenJournalLine(var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
    begin
        if GSTApplicationJournalPostingStarted then
            exit;

        if TempGenJournalLine.FindSet() then begin
            GSTApplicationJournalPostingStarted := true;
            repeat
                TempGenJnlLine := TempGenJournalLine;
                TempGenJnlLine."Line No." := 0;
                GenJnlPostLine.RunWithoutCheck(TempGenJnlLine);
                TempGenJournalLine.Delete();
            until TempGenJournalLine.Next() = 0;

            ClearApplicationGenJnlLine();
        end;
        ClearAllSessionVariables();
    end;

    procedure ClearApplicationGenJnlLine()
    begin
        Clear(TempGenJournalLine);
        GSTApplicationJournalPostingStarted := false;
    end;

    procedure ClearAllSessionVariables()
    begin
        Clear(OnlineCustomerLedgerEntry);
        Clear(OnlineVendorLedgerEntry);
        Clear(OnlineCustomerLedgerEntryNo);
        Clear(OnlineVendorLedgerEntryNo);
        Clear(GSTTransactionType);
        Clear(TransactionNo);
        Clear(VendorNo);
        Clear(CustomerNo);
        Clear(AppliedAmount);
        Clear(AppliedAmountLCY);
    end;

    procedure GetTotalTDSInclSHECessAmount(): Decimal
    begin
        exit(TotalTDSInclSHECessAmount);
    end;

    procedure GetTotalTCSInclSHECessAmount(): Decimal
    begin
        exit(TotalTCSInclSHECESSAmount);
    end;

    procedure SetGSTAmountLoaded(GSTAmt: Decimal)
    begin
        GSTAmountLoaded := GSTAmt;
    end;

    procedure GetGSTAmountLoaded(): Decimal
    begin
        exit(GSTAmountLoaded);
    end;

    local procedure GetTempGenJournalNextLineNo(): Integer
    var
        NextLineNo: Integer;
    begin
        if TempGenJournalLine.FindLast() then
            NextLineNo := TempGenJournalLine."Line No.";

        exit(NextLineNo + 10000);
    end;

    local procedure GetGLAccountDescription(GLAccCode: Code[20]): Text
    var
        GLAcc: Record "G/L Account";
    begin
        if GLAcc.Get(GLAccCode) then
            exit(GLAcc.Name);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Subscribers", 'OnAfterGetTDSAmount', '', false, false)]
    local procedure OnAfterGetTDSAmount(Amount: Decimal)
    begin
        TotalTDSInclSHECESSAmount += Amount;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Subscribers", 'OnAfterGetTCSAmount', '', false, false)]
    local procedure OnAfterGetTCSAmount(Amount: Decimal)
    begin
        TotalTCSInclSHECESSAmount += Amount;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopyPurchDocPurchLineOnAfterSetFilters', '', false, false)]
    local procedure OnCopyPurchDocPurchLineOnAfterSetFilters(FromPurchHeader: Record "Purchase Header"; var FromPurchLine: Record "Purchase Line"; var ToPurchHeader: Record "Purchase Header"; var RecalculateLines: Boolean)
    begin
        if FromPurchHeader."GST Vendor Type" <> FromPurchHeader."GST Vendor Type"::" " then
            IsCopyDocument := true
        else
            IsCopyDocument := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Tax", 'OnBeforeCallTaxEngineForPurchaseLine', '', false, false)]
    local procedure DisableTaxEngineCallingForPurchaseLine(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
        if not IsCopyDocument then
            exit;

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopyPurchDocOnAfterCopyPurchDocLines', '', false, false)]
    local procedure OnCopyPurchDocOnAfterCopyPurchDocLines(FromDocType: Option; FromDocNo: Code[20]; FromPurchaseHeader: Record "Purchase Header"; IncludeHeader: Boolean; var ToPurchHeader: Record "Purchase Header")
    begin
        if not IsCopyDocument then
            exit;

        if ToPurchHeader."GST Vendor Type" <> ToPurchHeader."GST Vendor Type"::" " then
            IsCopyDocument := false;
    end;
}
