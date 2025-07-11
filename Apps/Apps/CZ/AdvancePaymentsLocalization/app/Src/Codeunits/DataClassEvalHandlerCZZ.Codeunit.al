// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Bank.Documents;
using Microsoft.CashFlow.Setup;
using Microsoft.Finance.CashDesk;
using Microsoft.Finance.FinancialReports;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Document;
using Microsoft.Sales.Receivables;
using Microsoft.Utilities;
using System.Environment;
using System.Privacy;

codeunit 31093 "Data Class. Eval. Handler CZZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure ApplyEvaluationClassificationsForPrivacyOnAfterClassifyCountrySpecificTables()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    procedure ApplyEvaluationClassificationsForPrivacy()
    var
        AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL";
        Company: Record Company;
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        CashFlowSetup: Record "Cash Flow Setup";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer";
        GeneralLedgerSetup: Record "General Ledger Setup";
        GenJournalLine: Record "Gen. Journal Line";
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
        MatchBankPaymentBufferCZB: Record "Match Bank Payment Buffer CZB";
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"Advance Letter Application CZZ");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Advance Letter Link Buffer CZZ");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Advance Letter Template CZZ");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Advance Posting Buffer CZZ");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Purch. Adv. Letter Header CZZ");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Purch. Adv. Letter Line CZZ");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Purch. Adv. Letter Entry CZZ");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Sales Adv. Letter Header CZZ");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Sales Adv. Letter Line CZZ");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Sales Adv. Letter Entry CZZ");

        DataClassificationMgt.SetFieldToPersonal(Database::"Purch. Adv. Letter Entry CZZ", PurchAdvLetterEntryCZZ.FieldNo("User ID"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Sales Adv. Letter Entry CZZ", SalesAdvLetterEntryCZZ.FieldNo("User ID"));

        DataClassificationMgt.SetFieldToNormal(Database::"Acc. Schedule Extension CZL", AccScheduleExtensionCZL.FieldNo("Advance Payments CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Cash Document Line CZP", CashDocumentLineCZP.FieldNo("Advance Letter No. CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Cash Flow Setup", CashFlowSetup.FieldNo("S. Adv. Letter CF Acc. No. CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Cash Flow Setup", CashFlowSetup.FieldNo("P. Adv. Letter CF Acc. No. CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Cust. Ledger Entry", CustLedgerEntry.FieldNo("Advance Letter No. CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Cust. Ledger Entry", CustLedgerEntry.FieldNo("Adv. Letter Template Code CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"CV Ledger Entry Buffer", CVLedgerEntryBuffer.FieldNo("Advance Letter No. CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"General Ledger Setup", GeneralLedgerSetup.FieldNo("Adv. Deduction Exch. Rate CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("Advance Letter No. CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("Adv. Letter No. (Entry) CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("Use Advance G/L Account CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Iss. Payment Order Line CZB", IssPaymentOrderLineCZB.FieldNo("Purch. Advance Letter No. CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Match Bank Payment Buffer CZB", MatchBankPaymentBufferCZB.FieldNo("Advance Letter No. CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Payment Order Line CZB", PaymentOrderLineCZB.FieldNo("Purch. Advance Letter No. CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Posted Cash Document Line CZP", PostedCashDocumentLineCZP.FieldNo("Advance Letter No. CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Unpaid Advance Letter CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("Unpaid Advance Letter CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Entry", VATEntry.FieldNo("Advance Letter No. CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Posting Setup", VATPostingSetup.FieldNo("Sales Adv. Letter Account CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Posting Setup", VATPostingSetup.FieldNo("Sales Adv. Letter VAT Acc. CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Posting Setup", VATPostingSetup.FieldNo("Purch. Adv. Letter Account CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Posting Setup", VATPostingSetup.FieldNo("Purch. Adv.Letter VAT Acc. CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Vendor Ledger Entry", VendorLedgerEntry.FieldNo("Advance Letter No. CZZ"));
        DataClassificationMgt.SetFieldToNormal(Database::"Vendor Ledger Entry", VendorLedgerEntry.FieldNo("Adv. Letter Template Code CZZ"));
    end;
}
