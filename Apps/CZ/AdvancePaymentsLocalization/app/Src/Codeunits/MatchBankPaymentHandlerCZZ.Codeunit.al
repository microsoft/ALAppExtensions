// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Bank.Documents;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

codeunit 31390 "Match Bank Payment Handler CZZ"
{
    var
        GlobalMinAmount, GlobalMaxAmount : Decimal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Match Bank Payment CZB", 'OnAfterFillMatchBankPaymentBuffer', '', false, false)]
    local procedure MatchAdvancesOnAfterFillMatchBankPaymentBuffer(SearchRuleLineCZB: Record "Search Rule Line CZB"; var TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; var GenJournalLine: Record "Gen. Journal Line"; MinAmount: Decimal; MaxAmount: Decimal)
    begin
        if SearchRuleLineCZB."Search Scope" <> SearchRuleLineCZB."Search Scope"::"Advance CZZ" then
            exit;

        GlobalMinAmount := MinAmount;
        GlobalMaxAmount := MaxAmount;

        case SearchRuleLineCZB."Banking Transaction Type" of
            SearchRuleLineCZB."Banking Transaction Type"::Both:
                begin
                    FillMatchBankPaymentBufferSalesAdvance(SearchRuleLineCZB, TempMatchBankPaymentBufferCZB, GenJournalLine);
                    FillMatchBankPaymentBufferPurchaseAdvance(SearchRuleLineCZB, TempMatchBankPaymentBufferCZB, GenJournalLine);
                end;
            SearchRuleLineCZB."Banking Transaction Type"::Credit:
                FillMatchBankPaymentBufferSalesAdvance(SearchRuleLineCZB, TempMatchBankPaymentBufferCZB, GenJournalLine);
            SearchRuleLineCZB."Banking Transaction Type"::Debit:
                FillMatchBankPaymentBufferPurchaseAdvance(SearchRuleLineCZB, TempMatchBankPaymentBufferCZB, GenJournalLine);
        end;
    end;

    local procedure FillMatchBankPaymentBufferSalesAdvance(var SearchRuleLineCZB: Record "Search Rule Line CZB"; var TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; var GenJournalLine: Record "Gen. Journal Line")
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        CustomerBankAccount: Record "Customer Bank Account";
    begin
        OnBeforeFillMatchBankPaymentBufferSalesAdvance(SalesAdvLetterHeaderCZZ, SearchRuleLineCZB, TempMatchBankPaymentBufferCZB, GenJournalLine);
        SalesAdvLetterHeaderCZZ.SetRange(Status, SalesAdvLetterHeaderCZZ.Status::"To Pay");
        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) and
            (GenJournalLine."Account No." <> '')
        then
            SalesAdvLetterHeaderCZZ.SetRange("Bill-to Customer No.", GenJournalLine."Account No.");
        if SearchRuleLineCZB."Bank Account No." then begin
            if (GenJournalLine."Bank Account No. CZL" = '') and
               (GenJournalLine."Bank Account Code CZL" = '') and
               (GenJournalLine."IBAN CZL" = '')
            then
                exit;
            if SalesAdvLetterHeaderCZZ.GetFilter("Bill-to Customer No.") <> '' then
                SalesAdvLetterHeaderCZZ.CopyFilter("Bill-to Customer No.", CustomerBankAccount."Customer No.");
            if GenJournalLine."Bank Account Code CZL" <> '' then
                CustomerBankAccount.SetRange(Code, GenJournalLine."Bank Account Code CZL");
            if GenJournalLine."Bank Account No. CZL" <> '' then
                CustomerBankAccount.SetRange("Bank Account No.", GenJournalLine."Bank Account No. CZL");
            if GenJournalLine."IBAN CZL" <> '' then
                CustomerBankAccount.SetRange(IBAN, GenJournalLine."IBAN CZL");
            if CustomerBankAccount.Count() <> 1 then
                exit;
            CustomerBankAccount.FindFirst();
            SalesAdvLetterHeaderCZZ.SetRange("Bill-to Customer No.", CustomerBankAccount."Customer No.");
        end;
        if SearchRuleLineCZB.Amount then
            if GenJournalLine.IsLocalCurrencyCZB() then
                SalesAdvLetterHeaderCZZ.SetRange("To Pay (LCY)", GlobalMinAmount, GlobalMaxAmount)
            else
                SalesAdvLetterHeaderCZZ.SetRange("To Pay", GlobalMinAmount, GlobalMaxAmount);
        if SearchRuleLineCZB."Variable Symbol" then begin
            if GenJournalLine."Variable Symbol CZL" = '' then
                exit;
            SalesAdvLetterHeaderCZZ.SetRange("Variable Symbol", GenJournalLine."Variable Symbol CZL");
        end;
        if SearchRuleLineCZB."Specific Symbol" then begin
            if GenJournalLine."Specific Symbol CZL" = '' then
                exit;
            SalesAdvLetterHeaderCZZ.SetRange("Specific Symbol", GenJournalLine."Specific Symbol CZL");
        end;
        if SearchRuleLineCZB."Constant Symbol" then begin
            if GenJournalLine."Constant Symbol CZL" = '' then
                exit;
            SalesAdvLetterHeaderCZZ.SetRange("Constant Symbol", GenJournalLine."Constant Symbol CZL");
        end;
        if SalesAdvLetterHeaderCZZ.FindSet() then
            repeat
                TempMatchBankPaymentBufferCZB.InsertFromSalesAdvanceCZZ(SalesAdvLetterHeaderCZZ, GenJournalLine.IsLocalCurrencyCZB())
            until SalesAdvLetterHeaderCZZ.Next() = 0;
    end;

    local procedure FillMatchBankPaymentBufferPurchaseAdvance(var SearchRuleLineCZB: Record "Search Rule Line CZB"; var TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; var GenJournalLine: Record "Gen. Journal Line")
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        OnBeforeFillMatchBankPaymentBufferPurchaseAdvance(PurchAdvLetterHeaderCZZ, SearchRuleLineCZB, TempMatchBankPaymentBufferCZB, GenJournalLine);
        PurchAdvLetterHeaderCZZ.SetRange(Status, PurchAdvLetterHeaderCZZ.Status::"To Pay");
        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) and
            (GenJournalLine."Account No." <> '')
        then
            PurchAdvLetterHeaderCZZ.SetRange("Pay-to Vendor No.", GenJournalLine."Account No.");
        if SearchRuleLineCZB."Bank Account No." then begin
            if (GenJournalLine."Bank Account No. CZL" = '') and
               (GenJournalLine."Bank Account Code CZL" = '') and
               (GenJournalLine."IBAN CZL" = '')
            then
                exit;
            if PurchAdvLetterHeaderCZZ.GetFilter("Pay-to Vendor No.") <> '' then
                PurchAdvLetterHeaderCZZ.CopyFilter("Pay-to Vendor No.", VendorBankAccount."Vendor No.");
            if GenJournalLine."Bank Account Code CZL" <> '' then
                VendorBankAccount.SetRange(Code, GenJournalLine."Bank Account Code CZL");
            if GenJournalLine."Bank Account No. CZL" <> '' then
                VendorBankAccount.SetRange("Bank Account No.", GenJournalLine."Bank Account No. CZL");
            if GenJournalLine."IBAN CZL" <> '' then
                VendorBankAccount.SetRange(IBAN, GenJournalLine."IBAN CZL");
            if VendorBankAccount.Count() <> 1 then
                exit;
            VendorBankAccount.FindFirst();
            PurchAdvLetterHeaderCZZ.SetRange("Pay-to Vendor No.", VendorBankAccount."Vendor No.");
        end;
        if SearchRuleLineCZB.Amount then
            if GenJournalLine.IsLocalCurrencyCZB() then
                PurchAdvLetterHeaderCZZ.SetRange("To Pay (LCY)", -GlobalMaxAmount, -GlobalMinAmount)
            else
                PurchAdvLetterHeaderCZZ.SetRange("To Pay", -GlobalMaxAmount, -GlobalMinAmount);
        if SearchRuleLineCZB."Variable Symbol" then begin
            if GenJournalLine."Variable Symbol CZL" = '' then
                exit;
            PurchAdvLetterHeaderCZZ.SetRange("Variable Symbol", GenJournalLine."Variable Symbol CZL");
        end;
        if SearchRuleLineCZB."Specific Symbol" then begin
            if GenJournalLine."Specific Symbol CZL" = '' then
                exit;
            PurchAdvLetterHeaderCZZ.SetRange("Specific Symbol", GenJournalLine."Specific Symbol CZL");
        end;
        if SearchRuleLineCZB."Constant Symbol" then begin
            if GenJournalLine."Constant Symbol CZL" = '' then
                exit;
            PurchAdvLetterHeaderCZZ.SetRange("Constant Symbol", GenJournalLine."Constant Symbol CZL");
        end;
        if PurchAdvLetterHeaderCZZ.FindSet() then
            repeat
                TempMatchBankPaymentBufferCZB.InsertFromPurchAdvanceCZZ(PurchAdvLetterHeaderCZZ, GenJournalLine.IsLocalCurrencyCZB())
            until PurchAdvLetterHeaderCZZ.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Match Bank Payment CZB", 'OnAfterValidateGenJournalLine', '', false, false)]
    local procedure ValidateAdvanceNoOnAfterValidateGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; var TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; SearchRuleLineCZB: Record "Search Rule Line CZB")
    var
        OriginalGenJournalLine: Record "Gen. Journal Line";
    begin
        if SearchRuleLineCZB."Match Related Party Only" then
            exit;
        if TempMatchBankPaymentBufferCZB."Advance Letter No. CZZ" = '' then
            exit;

        OriginalGenJournalLine := GenJournalLine;
        GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Payment);
        GenJournalLine.Validate("Advance Letter No. CZZ", TempMatchBankPaymentBufferCZB."Advance Letter No. CZZ");
        GenJournalLine.Validate(Amount, OriginalGenJournalLine.Amount);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Search Rule CZB", 'OnAfterInsertRuleLine', '', false, false)]
    local procedure AddAdvanceRuleLineOnAfterInsertRuleLine(SearchRuleLineCZB: Record "Search Rule Line CZB"; var LineNo: Integer)
    var
        AdvanceSearchRuleLineCZB: Record "Search Rule Line CZB";
    begin
        if SearchRuleLineCZB."Banking Transaction Type" <> SearchRuleLineCZB."Banking Transaction Type"::Both then
            exit;
        if SearchRuleLineCZB."Search Scope" <> SearchRuleLineCZB."Search Scope"::Balance then
            exit;

        LineNo += 10000;
        AdvanceSearchRuleLineCZB := SearchRuleLineCZB;
        AdvanceSearchRuleLineCZB."Line No." := LineNo;
        AdvanceSearchRuleLineCZB.Description := '';
        AdvanceSearchRuleLineCZB.Validate("Search Scope", AdvanceSearchRuleLineCZB."Search Scope"::"Advance CZZ");
        AdvanceSearchRuleLineCZB.Insert(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFillMatchBankPaymentBufferPurchaseAdvance(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; SearchRuleLineCZB: Record "Search Rule Line CZB"; TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFillMatchBankPaymentBufferSalesAdvance(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SearchRuleLineCZB: Record "Search Rule Line CZB"; TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

}
