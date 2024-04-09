// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

codeunit 31003 "Gen.Jnl.-Post Line Handler CZZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterRunWithCheck', '', false, false)]
    local procedure GenJnlPostLineOnAfterRunWithCheck(var GenJnlLine: Record "Gen. Journal Line"; sender: Codeunit "Gen. Jnl.-Post Line")
    begin
        PostAdvancePayment(GenJnlLine, sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterRunWithoutCheck', '', false, false)]
    local procedure GenJnlPostLineOnAfterRunWithoutCheck(var GenJnlLine: Record "Gen. Journal Line"; sender: Codeunit "Gen. Jnl.-Post Line")
    begin
        PostAdvancePayment(GenJnlLine, sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCreateGLEntriesForTotalAmountsV19', '', false, false)]
    local procedure GenJnlPostLineOnBeforeCreateGLEntriesForTotalAmounts(GenJournalLine: Record "Gen. Journal Line"; var GLAccNo: Code[20])
    var
        SalesAdvLetterManagement: Codeunit "SalesAdvLetterManagement CZZ";
        PurchAdvLetterManagement: Codeunit "PurchAdvLetterManagement CZZ";
    begin
        if not GenJournalLine."Use Advance G/L Account CZZ" then
            exit;

        case GenJournalLine."Account Type" of
            GenJournalLine."Account Type"::Customer:
                GLAccNo := SalesAdvLetterManagement.GetAdvanceGLAccount(GenJournalLine);
            GenJournalLine."Account Type"::Vendor:
                GLAccNo := PurchAdvLetterManagement.GetAdvanceGLAccount(GenJournalLine);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostApply', '', false, false)]
    local procedure GenJnlPostLineOnBeforePostApply(var OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer")
    begin
        OldCVLedgEntryBuf.TestField("Advance Letter No. CZZ", NewCVLedgEntryBuf."Advance Letter No. CZZ");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeApplyCustLedgEntry', '', false, false)]
    local procedure DisableApplicationOnBeforeApplyCustLedgEntry(var GenJnlLine: Record "Gen. Journal Line")
    begin
        if (GenJnlLine."Advance Letter No. CZZ" <> '') or (GenJnlLine."Adv. Letter Template Code CZZ" <> '') then
            GenJnlLine."Allow Application" := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeApplyVendLedgEntry', '', false, false)]
    local procedure DisableApplicationOnBeforeApplyVendLedgEntry(var GenJnlLine: Record "Gen. Journal Line")
    begin
        if (GenJnlLine."Advance Letter No. CZZ" <> '') or (GenJnlLine."Adv. Letter Template Code CZZ" <> '') then
            GenJnlLine."Allow Application" := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPrepareTempCustLedgEntryOnAfterSetFiltersByAppliesToId', '', false, false)]
    local procedure OnPrepareTempCustLedgEntryOnAfterSetFiltersByAppliesToId(GenJournalLine: Record "Gen. Journal Line"; var OldCustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        if (GenJournalLine."Advance Letter No. CZZ" <> '') or (GenJournalLine."Adv. Letter Template Code CZZ" <> '') then begin
            // If the advance letter is posting then the manual application method must be used
            OldCustLedgerEntry.SetRange("Posting Date");
            OldCustLedgerEntry.SetFilter("Amount to Apply", '<>%1', 0);
        end else
            // If the advance letter is not posting then the customer ledger entries applied to advance letter mustn't be used for application
            OldCustLedgerEntry.SetRange("Advance Letter No. CZZ", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"CV Ledger Entry Buffer", 'OnAfterCopyFromVendLedgerEntry', '', false, false)]
    local procedure FillAdvanceLetterNoOnAfterCopyFromVendLedgerEntry(var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer"; VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        CVLedgerEntryBuffer."Advance Letter No. CZZ" := VendorLedgerEntry."Advance Letter No. CZZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"CV Ledger Entry Buffer", 'OnAfterCopyFromCustLedgerEntry', '', false, false)]
    local procedure FillAdvanceLetterNoOnAfterCopyFromCustLedgerEntry(var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer"; CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CVLedgerEntryBuffer."Advance Letter No. CZZ" := CustLedgerEntry."Advance Letter No. CZZ";
    end;

    local procedure PostAdvancePayment(var GenJournalLine: Record "Gen. Journal Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
    begin
        if (GenJournalLine."Advance Letter No. CZZ" = '') or (GenJournalLine.Amount = 0) or (GenJournalLine."Document Type" <> GenJournalLine."Document Type"::Payment) then
            exit;

        case GenJournalLine."Account Type" of
            GenJournalLine."Account Type"::Customer:
                begin
                    CustLedgerEntry.FindLast();
                    SalesAdvLetterManagementCZZ.PostAdvancePayment(CustLedgerEntry, GenJournalLine, 0, GenJnlPostLine, CustLedgerEntry."Posting Date");
                end;
            GenJournalLine."Account Type"::Vendor:
                begin
                    VendorLedgerEntry.FindLast();
                    PurchAdvLetterManagementCZZ.PostAdvancePayment(VendorLedgerEntry, GenJournalLine, 0, GenJnlPostLine, VendorLedgerEntry."Posting Date");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeVendLedgEntryModify', '', false, false)]
    local procedure InitAdvanceLetterOnBeforeVendLedgEntryModify(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        if VendorLedgerEntry.Open and (VendorLedgerEntry."Advance Letter No. CZZ" = '') then
            VendorLedgerEntry."Adv. Letter Template Code CZZ" := '';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCustLedgEntryModify', '', false, false)]
    local procedure InitAdvanceLetterOnBeforeCustLedgEntryModify(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        if CustLedgerEntry.Open and (CustLedgerEntry."Advance Letter No. CZZ" = '') then
            CustLedgerEntry."Adv. Letter Template Code CZZ" := '';
    end;
}
