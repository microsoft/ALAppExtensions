// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ReceivablesPayables;

using Microsoft.Finance.Deferral;
using Microsoft.Finance.GeneralLedger.Journal;
#if not CLEAN22
using Microsoft.Finance.GeneralLedger.Posting;
#endif
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using System.Utilities;

codeunit 31035 "C/V Posting Group Handler CZL"
{
    var
        ConfirmManagement: Codeunit "Confirm Management";
#if not CLEAN22
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteCustSubstPostingGroupsCZLOnAfterDelete(var Rec: Record "Customer Posting Group")
    var
        SubstCustPostingGroupCZL: Record "Subst. Cust. Posting Group CZL";
    begin
        SubstCustPostingGroupCZL.SetRange("Parent Customer Posting Group", Rec.Code);
        SubstCustPostingGroupCZL.DeleteAll();
        SubstCustPostingGroupCZL.Reset();
        SubstCustPostingGroupCZL.SetRange("Customer Posting Group", Rec.Code);
        SubstCustPostingGroupCZL.DeleteAll();
    end;
#pragma warning restore AL0432
#endif

    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnAfterValidateEvent', 'Receivables Account', false, false)]
    local procedure CheckOpenCustLedgEntriesOnAfterValidateReceivablesAccount(var Rec: Record "Customer Posting Group")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ChangeAccountQst: Label 'Do you really want to change Receivables Account although open entries exist?';
    begin
        CustLedgerEntry.SetCurrentKey(Open);
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange("Customer Posting Group", Rec.Code);
        CustLedgerEntry.SetRange(Prepayment, false);
        if not CustLedgerEntry.IsEmpty() then
            if not ConfirmManagement.GetResponseOrDefault(ChangeAccountQst, false) then
                Error('');
    end;
#if not CLEAN22
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertDtldCustLedgEntry', '', false, false)]
    local procedure OnBeforeInsertDtldCustLedgEntry(var DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; GenJournalLine: Record "Gen. Journal Line"; DtldCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.Get(DtldCVLedgEntryBuffer."CV Ledger Entry No.");
#pragma warning disable AL0432
        DtldCustLedgEntry."Customer Posting Group CZL" := CustLedgerEntry."Customer Posting Group";
#pragma warning restore AL0432
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeletevendSubstPostingGroupsCZLOnAfterDelete(var Rec: Record "Vendor Posting Group")
    var
#pragma warning disable AL0432
        SubstVendPostingGroupCZL: Record "Subst. Vend. Posting Group CZL";
#pragma warning restore AL0432
    begin
        SubstVendPostingGroupCZL.SetRange("Parent Vendor Posting Group", Rec.Code);
        SubstVendPostingGroupCZL.DeleteAll();
        SubstVendPostingGroupCZL.Reset();
        SubstVendPostingGroupCZL.SetRange("Vendor Posting Group", Rec.Code);
        SubstVendPostingGroupCZL.DeleteAll();
    end;
#endif

    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnAfterValidateEvent', 'Payables Account', false, false)]
    local procedure CheckOpenVendLedgEntriesOnAfterValidatePayablesAccount(var Rec: Record "Vendor Posting Group")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        ChangeAccountQst: Label 'Do you really want to change Payables Account although open entries exist?';
    begin
        VendorLedgerEntry.SetCurrentKey(Open);
        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.SetRange("Vendor Posting Group", Rec.Code);
        VendorLedgerEntry.SetRange(Prepayment, false);
        if not VendorLedgerEntry.IsEmpty() then
            if not ConfirmManagement.GetResponseOrDefault(ChangeAccountQst, false) then
                Error('');
    end;
#if not CLEAN22
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertDtldVendLedgEntry', '', false, false)]
    local procedure UpdateVendorPostingGroupCZLOnBeforeInsertDtldVendLedgEntry(var DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry"; GenJournalLine: Record "Gen. Journal Line"; DtldCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.Get(DtldCVLedgEntryBuffer."CV Ledger Entry No.");
#pragma warning disable AL0432
        DtldVendLedgEntry."Vendor Posting Group CZL" := VendorLedgerEntry."Vendor Posting Group";
#pragma warning restore AL0432
    end;
#endif

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Deferral Utilities", 'OnBeforePostedDeferralHeaderInsert', '', false, false)]
    local procedure OnBeforePostedDeferralHeaderInsert(var PostedDeferralHeader: Record "Posted Deferral Header"; GenJournalLine: Record "Gen. Journal Line")
    var
        Account: Code[20];
    begin
        if UpdateCustVendorAccount(GenJournalLine, Account) then
            PostedDeferralHeader."Account No." := Account;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Deferral Utilities", 'OnBeforePostedDeferralLineInsert', '', false, false)]
    local procedure OnBeforePostedDeferralLineInsert(var PostedDeferralLine: Record "Posted Deferral Line"; GenJournalLine: Record "Gen. Journal Line")
    var
        Account: Code[20];
    begin
        if UpdateCustVendorAccount(GenJournalLine, Account) then
            PostedDeferralLine."Account No." := Account;
    end;

    local procedure UpdateCustVendorAccount(GenJournalLine: Record "Gen. Journal Line"; var Account: Code[20]) Update: Boolean
    var
        CustomerPostingGroup: Record "Customer Posting Group";
        VendorPostingGroup: Record "Vendor Posting Group";
        GLAccountType: Enum "Gen. Journal Account Type";
    begin
        if (GenJournalLine."Account No." = '') and (GenJournalLine."Bal. Account No." <> '') then
            GLAccountType := GenJournalLine."Bal. Account Type"
        else
            GLAccountType := GenJournalLine."Account Type";

        // Account types not G/L are not storing a GL account in the GenJnlLine's Account field, need to retrieve
        case GLAccountType of
            GenJournalLine."Account Type"::Customer:
                begin
                    CustomerPostingGroup.Get(GenJournalLine."Posting Group");
                    CustomerPostingGroup.TestField("Receivables Account");
                    Account := CustomerPostingGroup.GetReceivablesAccount();
                    Update := true;
                end;
            GenJournalLine."Account Type"::Vendor:
                begin
                    VendorPostingGroup.Get(GenJournalLine."Posting Group");
                    VendorPostingGroup.TestField("Payables Account");
                    Account := VendorPostingGroup.GetPayablesAccount();
                    Update := true;
                end;
        end;
    end;
}
