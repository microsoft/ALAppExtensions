// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Reports;

codeunit 11482 "Create Gen. Jnl Template US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Template", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Gen. Journal Template")
    var
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
    begin
        case Rec.Name of
            CreateGenJournalTemplate.CashReceipts():
                ValidateRecordFields(Rec, Report::"General Journal - Test", Report::"G/L Register");
            CreateGenJournalTemplate.General():
                ValidateRecordFields(Rec, Report::"General Journal - Test", Report::"G/L Register");
            CreateGenJournalTemplate.InterCompanyGenJnl():
                ValidateRecordFields(Rec, Report::"General Journal - Test", Report::"G/L Register");
            CreateGenJournalTemplate.PaymentJournal():
                ValidateRecordFields(Rec, Report::"Payment Journal - Test", Report::"G/L Register");
        end;
    end;

    local procedure ValidateRecordFields(var GenJournalTemplate: Record "Gen. Journal Template"; TestReportID: Integer; PostingReportID: Integer)
    begin
        GenJournalTemplate.Validate("Test Report ID", TestReportID);
        GenJournalTemplate.Validate("Posting Report ID", PostingReportID);
    end;
}
