
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using Microsoft.Bank.Payment;
using Microsoft.Finance.GeneralLedger.IRS;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Setup;
using Microsoft.Utilities;
using System.IO;

codeunit 14600 "IS Core"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", OnAfterClassifyCountrySpecificTables, '', false, false)]
    local procedure OnAfterClassifyCountrySpecificTables()
    begin
        ClassifyTablesToNormal();
    end;


    [EventSubscriber(ObjectType::Table, Database::"Sales & Receivables Setup", OnAfterValidateEvent, "Electronic Invoicing Reminder", false, false)]
    local procedure OnAfterValidateElectronicInvoicing(var Rec: Record "Sales & Receivables Setup")
    var
    begin
            if Rec."Electronic Invoicing Reminder" then
                Message(ReminderMsg);
            Rec.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt Export Mgt Cust Ledg Entry", OnPreparePaymentExportDataCLEOnBeforeTempPaymentExportDataInsert, '', false, false)]
    local procedure OnPreparePaymentExportDataCLEOnBeforeTempPaymentExportDataInsert(var TempPaymentExportData: Record "Payment Export Data" temporary; CustLedgerEntry: Record "Cust. Ledger Entry"; GeneralLedgerSetup: Record "General Ledger Setup")
    var
        Customer: Record Customer;
    begin
        if CustLedgerEntry."Customer No." = '' then
            exit;
        Customer.Get(CustLedgerEntry."Customer No.");
        TempPaymentExportData."Recipient Reg. No." := CopyStr(Customer."Registration Number", 1, MaxStrLen(TempPaymentExportData."Recipient Reg. No."));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt Export Mgt Gen. Jnl Line", OnBeforeInsertPmtExportDataJnlFromGenJnlLine, '', false, false)]
    local procedure OnBeforeInsertPmtExportDataJnlFromGenJnlLine(var PaymentExportData: Record "Payment Export Data"; GenJournalLine: Record "Gen. Journal Line"; GeneralLedgerSetup: Record "General Ledger Setup")
    begin
        UpdateRegistrationNoFromGenJournalLine(PaymentExportData, GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pmt Export Mgt Vend Ledg Entry", OnBeforeInsertPmtExportDataJnlFromVendorLedgerEntry, '', false, false)]
    local procedure OnBeforeInsertPmtExportDataJnlFromVendorLedgerEntry(var PaymentExportData: Record "Payment Export Data"; VendorLedgerEntry: Record "Vendor Ledger Entry"; GeneralLedgerSetup: Record "General Ledger Setup")
    var
        Vendor: Record Vendor;
    begin
        if VendorLedgerEntry."Vendor No." = '' then
            exit;
        Vendor.Get(VendorLedgerEntry."Vendor No.");
        PaymentExportData."Recipient Reg. No." := CopyStr(Vendor."Registration Number", 1, MaxStrLen(PaymentExportData."Recipient Reg. No."));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Exp. Pre-Mapping Gen. Jnl.", OnBeforeInsertPaymentExoprtData, '', false, false)]
    local procedure OnBeforeInsertPaymentExoprtData(var PaymentExportData: Record "Payment Export Data"; GenJournalLine: Record "Gen. Journal Line"; GeneralLedgerSetup: Record "General Ledger Setup")
    begin
        UpdateRegistrationNoFromGenJournalLine(PaymentExportData, GenJournalLine);
    end;

    local procedure UpdateRegistrationNoFromGenJournalLine(var PaymentExportData: Record "Payment Export Data"; GenJournalLine: Record "Gen. Journal Line")
    var
        Vendor: Record Vendor;
    begin
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Employee then
            exit;
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor then begin
            Vendor.Get(GenJournalLine."Account No.");
            PaymentExportData."Recipient Reg. No." := CopyStr(Vendor."Registration Number", 1, MaxStrLen(PaymentExportData."Recipient Reg. No."));
        end;
    end;

    local procedure ClassifyTablesToNormal()
    var
        DataClassificationEvalData: Codeunit "Data Classification Eval. Data";
    begin
        DataClassificationEvalData.SetTableFieldsToNormal(DATABASE::"IS IRS Numbers");
        DataClassificationEvalData.SetTableFieldsToNormal(DATABASE::"IS IRS Groups");
        DataClassificationEvalData.SetTableFieldsToNormal(DATABASE::"IS IRS Types");
    end;

    internal procedure BlockDeletingPostedDocument(PostingDate: Date)
    var
        ISPostedDocumentDeletion: codeunit "IS Docs Retention Period";
    begin
        ISPostedDocumentDeletion.CheckDocumentDeletionAllowedByLaw(PostingDate);
    end;

    var
        ReminderMsg: Label 'Reminder to read legal restrictions on form and print/send statement';
}