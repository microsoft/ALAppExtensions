// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Reminder;

using Microsoft.Bank;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;

codeunit 11749 "Reminder Handler CZL"
{
    var
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";

    [EventSubscriber(ObjectType::Table, Database::"Reminder Header", 'OnAfterValidateEvent', 'Customer No.', false, false)]
    local procedure UpdateRegNoOnAfterCustomerNoValidate(var Rec: Record "Reminder Header")
    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
    begin
        CompanyInformation.Get();
        Rec.Validate("Bank Account Code CZL", CompanyInformation."Default Bank Account Code CZL");

        if Rec."Customer No." <> '' then begin
            Customer.Get(Rec."Customer No.");
            Rec."Registration No. CZL" := Customer.GetRegistrationNoTrimmedCZL();
            Rec."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reminder-Issue", 'OnAfterInitGenJnlLine', '', false, false)]
    local procedure UpdateBankInfoOnAfterInitGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; ReminderHeader: Record "Reminder Header")
    begin
        GenJournalLine."VAT Reporting Date" := ReminderHeader."Posting Date";
        if GenJournalLine."Account Type" <> GenJournalLine."Account Type"::Customer then
            exit;

        GenJournalLine."Specific Symbol CZL" := ReminderHeader."Specific Symbol CZL";
        if ReminderHeader."Variable Symbol CZL" <> '' then
            GenJournalLine."Variable Symbol CZL" := ReminderHeader."Variable Symbol CZL"
        else
            GenJournalLine."Variable Symbol CZL" := BankOperationsFunctionsCZL.CreateVariableSymbol(GenJournalLine."Document No.");
        GenJournalLine."Constant Symbol CZL" := ReminderHeader."Constant Symbol CZL";
        GenJournalLine."Bank Account Code CZL" := ReminderHeader."Bank Account Code CZL";
        GenJournalLine."Bank Account No. CZL" := ReminderHeader."Bank Account No. CZL";
        GenJournalLine."Transit No. CZL" := ReminderHeader."Transit No. CZL";
        GenJournalLine."IBAN CZL" := ReminderHeader."IBAN CZL";
        GenJournalLine."SWIFT Code CZL" := ReminderHeader."SWIFT Code CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reminder-Issue", 'OnBeforeIssuedReminderHeaderInsert', '', false, false)]
    local procedure UpdateVariableSymbolOnBeforeIssuedReminderHeaderInsert(var IssuedReminderHeader: Record "Issued Reminder Header"; ReminderHeader: Record "Reminder Header")
    begin
        if IssuedReminderHeader."Variable Symbol CZL" <> '' then
            exit;

        IssuedReminderHeader."Variable Symbol CZL" := BankOperationsFunctionsCZL.CreateVariableSymbol(IssuedReminderHeader."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Issued Reminder Header", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckDeletionAllowOnBeforeDeleteEvent(var Rec: Record "Issued Reminder Header")
    var
        PostSalesDelete: Codeunit "PostSales-Delete";
    begin
        PostSalesDelete.IsDocumentDeletionAllowed(Rec."Posting Date");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reminder Communication", 'OnBeforeExitReportIDOnReplaceHTMLText', '', false, false)]
    local procedure RecordIDOnBeforeExitReportIDOnReplaceHTMLText(ReportID: Integer; var RecordVariant: Variant; var ReportIDExit: Boolean)
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
        RecordReference: RecordRef;
    begin
        if ReportID <> Report::"Reminder CZL" then
            exit;

        if not RecordVariant.IsRecordRef() then
            exit;

        RecordReference.GetTable(RecordVariant);
        if RecordReference.Number <> IssuedReminderHeader.RecordId.TableNo then
            exit;

        ReportIDExit := false;
    end;
}
