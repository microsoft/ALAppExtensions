// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.HumanResources.Employee;
using Microsoft.HumanResources.Payables;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;

codeunit 31362 "Match Bank Payment CZB"
{
    TableNo = "Gen. Journal Line";

    trigger OnRun()
    begin
        GenJournalLine.Copy(Rec);
        Code();
        Rec := GenJournalLine;
    end;

    var
        OriginalGenJournalLine: Record "Gen. Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        SearchRuleLineCZB: Record "Search Rule Line CZB";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
        TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB" temporary;
        SummaryGenJournalLine: Record "Gen. Journal Line";
        BankAccountNo: Code[20];
        MinAmount, MaxAmount : Decimal;

    local procedure Code()
    begin
        BankAccountNo := GenJournalLine."Bal. Account No.";
        if BankAccountNo = '' then begin
            // the summary line must exist when the post per line is not allowed in the bank account.
            SummaryGenJournalLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
            SummaryGenJournalLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
            SummaryGenJournalLine.SetRange("Document No.", GenJournalLine."Document No.");
            SummaryGenJournalLine.SetRange("Account Type", Enum::"Gen. Journal Account Type"::"Bank Account");
            if not SummaryGenJournalLine.FindFirst() then begin
                GenJournalLine.TestField("Bal. Account Type", Enum::"Gen. Journal Account Type"::"Bank Account");
                GenJournalLine.TestField("Bal. Account No.");
            end;
            BankAccountNo := SummaryGenJournalLine."Account No.";
        end;

        GenJournalLine.TestField("Search Rule Code CZB");
        if GenJournalLine.IsLocalCurrencyCZB() then
            GenJournalLine.TestField("Amount (LCY)")
        else
            GenJournalLine.TestField(Amount);
        GenJournalLine."Search Rule Line No. CZB" := 0;

        BankAccount.Get(BankAccountNo);
        BankAccount.TestField("Disable Automatic Pmt Matching", false);
        if GenJournalLine.IsLocalCurrencyCZB() then
            GetAmountRangeForTolerance(BankAccount, -GenJournalLine."Amount (LCY)", MinAmount, MaxAmount)
        else
            GetAmountRangeForTolerance(BankAccount, -GenJournalLine.Amount, MinAmount, MaxAmount);

        SearchRuleLineCZB.SetRange("Search Rule Code", GenJournalLine."Search Rule Code CZB");
        SearchRuleLineCZB.FindSet();
        repeat
            if SearchRuleLineCZB."Search Scope" = SearchRuleLineCZB."Search Scope"::"Account Mapping" then begin
                // filter rule
                GenJournalLine.Reset();
                GenJournalLine.SetRecFilter();
                if SearchRuleLineCZB."Description Filter" <> '' then
                    GenJournalLine.SetFilter(Description, SearchRuleLineCZB."Description Filter");
                if SearchRuleLineCZB."Variable Symbol Filter" <> '' then
                    GenJournalLine.SetFilter("Variable Symbol CZL", SearchRuleLineCZB."Variable Symbol Filter");
                if SearchRuleLineCZB."Constant Symbol Filter" <> '' then
                    GenJournalLine.SetFilter("Constant Symbol CZL", SearchRuleLineCZB."Constant Symbol Filter");
                if SearchRuleLineCZB."Specific Symbol Filter" <> '' then
                    GenJournalLine.SetFilter("Specific Symbol CZL", SearchRuleLineCZB."Specific Symbol Filter");
                if SearchRuleLineCZB."Bank Account Filter" <> '' then
                    GenJournalLine.SetFilter("Bank Account No. CZL", SearchRuleLineCZB."Bank Account Filter");
                if SearchRuleLineCZB."IBAN Filter" <> '' then
                    GenJournalLine.SetFilter("IBAN CZL", SearchRuleLineCZB."IBAN Filter");
                case SearchRuleLineCZB."Banking Transaction Type" of
                    SearchRuleLineCZB."Banking Transaction Type"::Credit:
                        GenJournalLine.SetFilter("Amount (LCY)", '>0');
                    SearchRuleLineCZB."Banking Transaction Type"::Debit:
                        GenJournalLine.SetFilter("Amount (LCY)", '<0');
                end;
                if not GenJournalLine.IsEmpty() then begin
                    OriginalGenJournalLine := GenJournalLine;
                    SearchRuleLineCZB.TestField("Account Type");
                    SearchRuleLineCZB.TestField("Account No.");
                    case SearchRuleLineCZB."Account Type" of
                        SearchRuleLineCZB."Account Type"::"G/L Account":
                            GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"G/L Account");
                        SearchRuleLineCZB."Account Type"::Customer:
                            GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Customer);
                        SearchRuleLineCZB."Account Type"::Vendor:
                            GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Vendor);
                        SearchRuleLineCZB."Account Type"::"Bank Account":
                            GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"Bank Account");
                        SearchRuleLineCZB."Account Type"::Employee:
                            GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Employee);
                    end;
                    GenJournalLine.Validate("Account No.", SearchRuleLineCZB."Account No.");
                    GenJournalLine."Search Rule Line No. CZB" := SearchRuleLineCZB."Line No.";
                    GenJournalLine.Description := OriginalGenJournalLine.Description;
                    GenJournalLine.Modify();
                end;
                GenJournalLine.SetRange(Description);
                GenJournalLine.SetRange("Variable Symbol CZL");
                GenJournalLine.SetRange("Constant Symbol CZL");
                GenJournalLine.SetRange("Specific Symbol CZL");
                GenJournalLine.SetRange("Bank Account No. CZL");
                GenJournalLine.SetRange("IBAN CZL");
                GenJournalLine.SetRange("Amount (LCY)");
            end else begin
                // search rule
                TempMatchBankPaymentBufferCZB.Reset();
                TempMatchBankPaymentBufferCZB.DeleteAll();
                case SearchRuleLineCZB."Search Scope" of
                    SearchRuleLineCZB."Search Scope"::Balance:
                        begin
                            FillMatchBankPaymentBufferCustomer();
                            FillMatchBankPaymentBufferVendor();
                            FillMatchBankPaymentBufferEmployee();
                        end;
                    SearchRuleLineCZB."Search Scope"::Customer:
                        FillMatchBankPaymentBufferCustomer();
                    SearchRuleLineCZB."Search Scope"::Vendor:
                        FillMatchBankPaymentBufferVendor();
                    SearchRuleLineCZB."Search Scope"::Employee:
                        FillMatchBankPaymentBufferEmployee();
                end;
                OnAfterFillMatchBankPaymentBuffer(TempMatchBankPaymentBufferCZB, SearchRuleLineCZB, GenJournalLine, MinAmount, MaxAmount);

                if TempMatchBankPaymentBufferCZB.Count() > 0 then begin
                    case SearchRuleLineCZB."Multiple Result" of
                        "Multiple Search Result CZB"::"First Created Entry":
                            TempMatchBankPaymentBufferCZB.Ascending(true);
                        "Multiple Search Result CZB"::"Last Created Entry":
                            TempMatchBankPaymentBufferCZB.Ascending(false);
                        "Multiple Search Result CZB"::"Earliest Due Date":
                            begin
                                TempMatchBankPaymentBufferCZB.SetCurrentKey("Due Date");
                                TempMatchBankPaymentBufferCZB.Ascending(true);
                            end;
                        "Multiple Search Result CZB"::"Latest Due Date":
                            begin
                                TempMatchBankPaymentBufferCZB.SetCurrentKey("Due Date");
                                TempMatchBankPaymentBufferCZB.Ascending(false);
                            end;
                        "Multiple Search Result CZB"::"Earliest Posting Date":
                            begin
                                TempMatchBankPaymentBufferCZB.SetCurrentKey("Posting Date");
                                TempMatchBankPaymentBufferCZB.Ascending(true);
                            end;
                        "Multiple Search Result CZB"::"Latest Posting Date":
                            begin
                                TempMatchBankPaymentBufferCZB.SetCurrentKey("Posting Date");
                                TempMatchBankPaymentBufferCZB.Ascending(false);
                            end;
                        "Multiple Search Result CZB"::"Smallest Remaining Amount":
                            begin
                                TempMatchBankPaymentBufferCZB.SetCurrentKey("Remaining Amount");
                                TempMatchBankPaymentBufferCZB.Ascending(true);
                            end;
                        "Multiple Search Result CZB"::"Greatest Remaining Amount":
                            begin
                                TempMatchBankPaymentBufferCZB.SetCurrentKey("Remaining Amount");
                                TempMatchBankPaymentBufferCZB.Ascending(false);
                            end;
                    end;
                    if not ((TempMatchBankPaymentBufferCZB.Count() > 1) and (SearchRuleLineCZB."Multiple Result" = "Multiple Search Result CZB"::Continue)) then begin
                        OriginalGenJournalLine := GenJournalLine;
                        TempMatchBankPaymentBufferCZB.FindFirst();
                        case TempMatchBankPaymentBufferCZB."Account Type" of
                            TempMatchBankPaymentBufferCZB."Account Type"::Customer:
                                GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Customer);
                            TempMatchBankPaymentBufferCZB."Account Type"::Vendor:
                                GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Vendor);
                            TempMatchBankPaymentBufferCZB."Account Type"::Employee:
                                GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Employee);
                        end;
                        GenJournalLine.Validate("Account No.", TempMatchBankPaymentBufferCZB."Account No.");
                        if not SearchRuleLineCZB."Match Related Party Only" then begin
                            GenJournalLine.Validate("Applies-to Doc. Type", TempMatchBankPaymentBufferCZB."Document Type");
                            if GenJournalLine."Account Type" in [GenJournalLine."Account Type"::Customer, GenJournalLine."Account Type"::Vendor] then begin
                                if GenJournalLine."Applies-to Doc. Type" = GenJournalLine."Applies-to Doc. Type"::Invoice then
                                    GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Payment);
                                if GenJournalLine."Applies-to Doc. Type" = GenJournalLine."Applies-to Doc. Type"::"Credit Memo" then
                                    GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Refund);
                            end;
                            if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Employee then
                                if GenJournalLine.Amount > 0 then
                                    GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Payment);
                            GenJournalLine.SetSuppressCommit(true);
                            GenJournalLine.Validate("Applies-to Doc. No.", TempMatchBankPaymentBufferCZB."Document No.");
                        end;
                        if BankAccount."Dimension from Apply Entry CZB" then
                            GenJournalLine.Validate("Dimension Set ID", TempMatchBankPaymentBufferCZB."Dimension Set ID");
                        if GenJournalLine."Currency Code" <> OriginalGenJournalLine."Currency Code" then
                            GenJournalLine.Validate("Currency Code", OriginalGenJournalLine."Currency Code");
                        if GenJournalLine."Currency Factor" <> OriginalGenJournalLine."Currency Factor" then
                            GenJournalLine.Validate("Currency Factor", OriginalGenJournalLine."Currency Factor");
                        if GenJournalLine.Amount <> OriginalGenJournalLine.Amount then
                            GenJournalLine.Validate(Amount, OriginalGenJournalLine.Amount);
                        if GenJournalLine.Description <> OriginalGenJournalLine.Description then
                            GenJournalLine.Description := OriginalGenJournalLine.Description;

                        OnAfterValidateGenJournalLine(TempMatchBankPaymentBufferCZB, GenJournalLine, SearchRuleLineCZB);
                        GenJournalLine."Search Rule Line No. CZB" := SearchRuleLineCZB."Line No.";
                        GenJournalLine.Modify();
                    end;
                end;
            end;
        until (SearchRuleLineCZB.Next() = 0) or (GenJournalLine."Search Rule Line No. CZB" <> 0);
    end;

    local procedure FillMatchBankPaymentBufferCustomer()
    var
        CustomerBankAccount: Record "Customer Bank Account";
        UsePaymentDiscounts: Boolean;
    begin
        CustLedgerEntry.Reset();
        CustLedgerEntry.SetCurrentKey("Customer No.", Open);
        CustLedgerEntry.SetRange(Prepayment, false);
        CustLedgerEntry.SetRange(Positive, GenJournalLine.Amount < 0);
        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) and
           (GenJournalLine."Account No." <> '')
        then
            CustLedgerEntry.SetRange("Customer No.", GenJournalLine."Account No.");
        if SearchRuleLineCZB."Bank Account No." then begin
            if (GenJournalLine."Bank Account No. CZL" = '') and
               (GenJournalLine."Bank Account Code CZL" = '') and
               (GenJournalLine."IBAN CZL" = '')
            then
                exit;
            if CustLedgerEntry.GetFilter("Customer No.") <> '' then
                CustLedgerEntry.CopyFilter("Customer No.", CustomerBankAccount."Customer No.");
            if GenJournalLine."Bank Account Code CZL" <> '' then
                CustomerBankAccount.SetRange(Code, GenJournalLine."Bank Account Code CZL");
            if GenJournalLine."Bank Account No. CZL" <> '' then
                CustomerBankAccount.SetRange("Bank Account No.", GenJournalLine."Bank Account No. CZL");
            if GenJournalLine."IBAN CZL" <> '' then
                CustomerBankAccount.SetRange(IBAN, GenJournalLine."IBAN CZL");
            if CustomerBankAccount.Count() <> 1 then
                exit;
            CustomerBankAccount.FindFirst();
            CustLedgerEntry.SetRange("Customer No.", CustomerBankAccount."Customer No.");
        end;
        CustLedgerEntry.SetRange(Open, true);
        if SearchRuleLineCZB.Amount then
            if GenJournalLine.IsLocalCurrencyCZB() then
                CustLedgerEntry.SetRange("Remaining Amt. (LCY)", MinAmount, MaxAmount)
            else
                CustLedgerEntry.SetRange("Remaining Amount", MinAmount, MaxAmount);
        if SearchRuleLineCZB."Variable Symbol" then begin
            if GenJournalLine.GetVariableSymbolCZB() = '' then
                exit;
            CustLedgerEntry.SetRange("Variable Symbol CZL", GenJournalLine.GetVariableSymbolCZB());
        end;
        if SearchRuleLineCZB."Specific Symbol" then begin
            if GenJournalLine."Specific Symbol CZL" = '' then
                exit;
            CustLedgerEntry.SetRange("Specific Symbol CZL", GenJournalLine."Specific Symbol CZL");
        end;
        if SearchRuleLineCZB."Constant Symbol" then begin
            if GenJournalLine."Constant Symbol CZL" = '' then
                exit;
            CustLedgerEntry.SetRange("Constant Symbol CZL", GenJournalLine."Constant Symbol CZL");
        end;
        case SearchRuleLineCZB."Banking Transaction Type" of
            SearchRuleLineCZB."Banking Transaction Type"::Credit:
                CustLedgerEntry.SetRange(Positive, true);
            SearchRuleLineCZB."Banking Transaction Type"::Debit:
                CustLedgerEntry.SetRange(Positive, false);
        end;
        OnFillMatchBankPaymentBufferCustomerOnAfterCustLedgerEntrySetFilters(CustLedgerEntry, SearchRuleLineCZB, GenJournalLine);
        if CustLedgerEntry.FindSet() then
            repeat
                TempMatchBankPaymentBufferCZB.InsertFromCustomerLedgerEntry(CustLedgerEntry, true, UsePaymentDiscounts);
            until CustLedgerEntry.Next() = 0;
    end;

    local procedure FillMatchBankPaymentBufferVendor()
    var
        VendorBankAccount: Record "Vendor Bank Account";
        UsePaymentDiscounts: Boolean;
    begin
        VendorLedgerEntry.Reset();
        VendorLedgerEntry.SetCurrentKey("Vendor No.", Open);
        VendorLedgerEntry.SetRange(Prepayment, false);
        VendorLedgerEntry.SetRange(Positive, GenJournalLine.Amount < 0);
        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) and
            (GenJournalLine."Account No." <> '')
        then
            VendorLedgerEntry.SetRange("Vendor No.", GenJournalLine."Account No.");
        if SearchRuleLineCZB."Bank Account No." then begin
            if (GenJournalLine."Bank Account No. CZL" = '') and
               (GenJournalLine."Bank Account Code CZL" = '') and
               (GenJournalLine."IBAN CZL" = '')
            then
                exit;
            if VendorLedgerEntry.GetFilter("Vendor No.") <> '' then
                VendorLedgerEntry.CopyFilter("Vendor No.", VendorBankAccount."Vendor No.");
            if GenJournalLine."Bank Account Code CZL" <> '' then
                VendorBankAccount.SetRange(Code, GenJournalLine."Bank Account Code CZL");
            if GenJournalLine."Bank Account No. CZL" <> '' then
                VendorBankAccount.SetRange("Bank Account No.", GenJournalLine."Bank Account No. CZL");
            if GenJournalLine."IBAN CZL" <> '' then
                VendorBankAccount.SetRange(IBAN, GenJournalLine."IBAN CZL");
            if VendorBankAccount.Count() <> 1 then
                exit;
            VendorBankAccount.FindFirst();
            VendorLedgerEntry.SetRange("Vendor No.", VendorBankAccount."Vendor No.");
        end;
        VendorLedgerEntry.SetRange(Open, true);
        if SearchRuleLineCZB.Amount then
            if GenJournalLine.IsLocalCurrencyCZB() then
                VendorLedgerEntry.SetRange("Remaining Amt. (LCY)", MinAmount, MaxAmount)
            else
                VendorLedgerEntry.SetRange("Remaining Amount", MinAmount, MaxAmount);
        if SearchRuleLineCZB."Variable Symbol" then begin
            if GenJournalLine.GetVariableSymbolCZB() = '' then
                exit;
            VendorLedgerEntry.SetRange("Variable Symbol CZL", GenJournalLine.GetVariableSymbolCZB());
        end;
        if SearchRuleLineCZB."Specific Symbol" then begin
            if GenJournalLine."Specific Symbol CZL" = '' then
                exit;
            VendorLedgerEntry.SetRange("Specific Symbol CZL", GenJournalLine."Specific Symbol CZL");
        end;
        if SearchRuleLineCZB."Constant Symbol" then begin
            if GenJournalLine."Constant Symbol CZL" = '' then
                exit;
            VendorLedgerEntry.SetRange("Constant Symbol CZL", GenJournalLine."Constant Symbol CZL");
        end;
        case SearchRuleLineCZB."Banking Transaction Type" of
            SearchRuleLineCZB."Banking Transaction Type"::Debit:
                VendorLedgerEntry.SetRange(Positive, true);
            SearchRuleLineCZB."Banking Transaction Type"::Credit:
                VendorLedgerEntry.SetRange(Positive, false);
        end;
        OnFillMatchBankPaymentBufferVendorOnAfterVendorLedgerEntrySetFilters(VendorLedgerEntry, SearchRuleLineCZB, GenJournalLine);
        if VendorLedgerEntry.FindSet() then
            repeat
                TempMatchBankPaymentBufferCZB.InsertFromVendorLedgerEntry(VendorLedgerEntry, true, UsePaymentDiscounts);
            until VendorLedgerEntry.Next() = 0;
    end;

    local procedure FillMatchBankPaymentBufferEmployee()
    var
        Employee: Record Employee;
    begin
        EmployeeLedgerEntry.Reset();
        EmployeeLedgerEntry.SetCurrentKey("Employee No.", Open);
        EmployeeLedgerEntry.SetRange(Positive, GenJournalLine.Amount < 0);

        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Employee) and
            (GenJournalLine."Account No." <> '')
        then
            EmployeeLedgerEntry.SetRange("Employee No.", GenJournalLine."Account No.");
        if SearchRuleLineCZB."Bank Account No." then begin
            if (GenJournalLine."Bank Account No. CZL" = '') and
               (GenJournalLine."IBAN CZL" = '')
            then
                exit;
            if GenJournalLine."Bank Account No. CZL" <> '' then
                Employee.SetRange("Bank Account No.", GenJournalLine."Bank Account No. CZL");
            if GenJournalLine."IBAN CZL" <> '' then
                Employee.SetRange(IBAN, GenJournalLine."IBAN CZL");
            if Employee.Count() <> 1 then
                exit;
            Employee.FindFirst();
            EmployeeLedgerEntry.SetRange("Employee No.", Employee."No.");
        end;
        EmployeeLedgerEntry.SetRange(Open, true);
        if SearchRuleLineCZB.Amount then
            if GenJournalLine.IsLocalCurrencyCZB() then
                EmployeeLedgerEntry.SetRange("Remaining Amt. (LCY)", MinAmount, MaxAmount)
            else
                EmployeeLedgerEntry.SetRange("Remaining Amount", MinAmount, MaxAmount);
        if SearchRuleLineCZB."Variable Symbol" then begin
            if GenJournalLine.GetVariableSymbolCZB() = '' then
                exit;
            EmployeeLedgerEntry.SetRange("Variable Symbol CZL", GenJournalLine.GetVariableSymbolCZB());
        end;
        if SearchRuleLineCZB."Specific Symbol" then begin
            if GenJournalLine."Specific Symbol CZL" = '' then
                exit;
            EmployeeLedgerEntry.SetRange("Specific Symbol CZL", GenJournalLine."Specific Symbol CZL");
        end;
        if SearchRuleLineCZB."Constant Symbol" then begin
            if GenJournalLine."Constant Symbol CZL" = '' then
                exit;
            EmployeeLedgerEntry.SetRange("Constant Symbol CZL", GenJournalLine."Constant Symbol CZL");
        end;
        case SearchRuleLineCZB."Banking Transaction Type" of
            SearchRuleLineCZB."Banking Transaction Type"::Debit:
                EmployeeLedgerEntry.SetRange(Positive, true);
            SearchRuleLineCZB."Banking Transaction Type"::Credit:
                EmployeeLedgerEntry.SetRange(Positive, false);
        end;
        OnFillMatchBankPaymentBufferEmployeeOnAfterEmployeeLedgerEntrySetFilters(EmployeeLedgerEntry, SearchRuleLineCZB, GenJournalLine);
        if EmployeeLedgerEntry.FindSet() then
            repeat
                TempMatchBankPaymentBufferCZB.InsertFromEmployeeLedgerEntry(EmployeeLedgerEntry);
            until EmployeeLedgerEntry.Next() = 0;
    end;

    procedure GetAmountRangeForTolerance(BankAccount: Record "Bank Account"; StatementAmount: Decimal; var MinAmount: Decimal; var MaxAmount: Decimal)
    var
        TempAmount: Decimal;
    begin
        case BankAccount."Match Tolerance Type" of
            BankAccount."Match Tolerance Type"::Amount:
                begin
                    MinAmount := StatementAmount - BankAccount."Match Tolerance Value";
                    MaxAmount := StatementAmount + BankAccount."Match Tolerance Value";
                    if (StatementAmount >= 0) and (MinAmount < 0) then
                        MinAmount := 0
                    else
                        if (StatementAmount < 0) and (MaxAmount > 0) then
                            MaxAmount := 0;
                end;
            BankAccount."Match Tolerance Type"::Percentage:
                begin
                    MinAmount := StatementAmount * (1 - BankAccount."Match Tolerance Value" / 100);
                    MaxAmount := StatementAmount * (1 + BankAccount."Match Tolerance Value" / 100);
                    if StatementAmount < 0 then begin
                        TempAmount := MinAmount;
                        MinAmount := MaxAmount;
                        MaxAmount := TempAmount;
                    end;
                end;
        end;
        MinAmount := Round(MinAmount);
        MaxAmount := Round(MaxAmount);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFillMatchBankPaymentBuffer(var TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; SearchRuleLineCZB: Record "Search Rule Line CZB"; var GenJournalLine: Record "Gen. Journal Line"; MinAmount: Decimal; MaxAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateGenJournalLine(var TempMatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB"; var GenJournalLine: Record "Gen. Journal Line"; SearchRuleLineCZB: Record "Search Rule Line CZB")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnFillMatchBankPaymentBufferCustomerOnAfterCustLedgerEntrySetFilters(var CustLedgerEntry: Record "Cust. Ledger Entry"; SearchRuleLineCZB: Record "Search Rule Line CZB"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnFillMatchBankPaymentBufferVendorOnAfterVendorLedgerEntrySetFilters(var VendorLedgerEntry: Record "Vendor Ledger Entry"; SearchRuleLineCZB: Record "Search Rule Line CZB"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnFillMatchBankPaymentBufferEmployeeOnAfterEmployeeLedgerEntrySetFilters(var EmployeeLedgerEntry: Record "Employee Ledger Entry"; SearchRuleLineCZB: Record "Search Rule Line CZB"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;
}
