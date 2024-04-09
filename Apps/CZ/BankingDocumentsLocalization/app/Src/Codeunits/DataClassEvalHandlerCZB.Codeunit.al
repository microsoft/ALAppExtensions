// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Payment;
using Microsoft.Bank.Reconciliation;
using Microsoft.Bank.Setup;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.HumanResources.Payables;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;
using Microsoft.Utilities;
using System.Environment;
using System.Privacy;
using System.Security.User;

codeunit 31331 "Data Class. Eval. Handler CZB"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure ApplyEvaluationClassificationsForPrivacyOnAfterClassifyCountrySpecificTables()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        BankAccount: Record "Bank Account";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankExportImportSetup: Record "Bank Export/Import Setup";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
        PaymentExportData: Record "Payment Export Data";
        UserSetup: Record "User Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"Bank Statement Header CZB");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Bank Statement Line CZB");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Iss. Bank Statement Header CZB");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Iss. Bank Statement Line CZB");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Payment Order Header CZB");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Payment Order Line CZB");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Iss. Payment Order Header CZB");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Iss. Payment Order Line CZB");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Match Bank Payment Buffer CZB");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Search Rule CZB");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Search Rule Line CZB");

        DataClassificationMgt.SetFieldToPersonal(Database::"Iss. Bank Statement Header CZB", IssBankStatementHeaderCZB.FieldNo("Pre-Assigned User ID"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Iss. Payment Order Header CZB", IssPaymentOrderHeaderCZB.FieldNo("Pre-Assigned User ID"));

        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Default Constant Symbol CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Default Specific Symbol CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Domestic Payment Order ID CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Foreign Payment Order ID CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Dimension from Apply Entry CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Check Ext. No. Curr. Year CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Check CZ Format on Issue CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Variable S. to Description CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Variable S. to Variable S. CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Variable S. to Ext.Doc.No. CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Foreign Payment Orders CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Post Per Line CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Payment Partial Suggestion CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Payment Order Line Descr. CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Non Assoc. Payment Account CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Base Calendar Code CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Payment Jnl. Template Name CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Payment Jnl. Batch Name CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Foreign Payment Ex. Format CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Payment Import Format CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Payment Order Nos. CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Issued Payment Order Nos. CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Bank Statement Nos. CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Issued Bank Statement Nos. CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Search Rule Code CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Pmt.Jnl. Templ. Name Order CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Pmt. Jnl. Batch Name Order CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Acc. Reconciliation", BankAccReconciliation.FieldNo("Created From Bank Stat. CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Export/Import Setup", BankExportImportSetup.FieldNo("Processing Report ID CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Export/Import Setup", BankExportImportSetup.FieldNo("Default File Type CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Cust. Ledger Entry", CustLedgerEntry.FieldNo("Amount on Pmt. Order (LCY) CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Employee Ledger Entry", EmployeeLedgerEntry.FieldNo("Amount on Pmt. Order (LCY) CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("Search Rule Code CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("Search Rule Line No. CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("Variable S. to Description CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("Variable S. to Variable S. CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("Variable S. to Ext.Doc.No. CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Payment Export Data", PaymentExportData.FieldNo("Specific Symbol CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Payment Export Data", PaymentExportData.FieldNo("Variable Symbol CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Payment Export Data", PaymentExportData.FieldNo("Constant Symbol CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Check Payment Orders CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Check Bank Statements CZB"));
        DataClassificationMgt.SetFieldToNormal(Database::"Vendor Ledger Entry", VendorLedgerEntry.FieldNo("Amount on Pmt. Order (LCY) CZB"));
    end;
}
