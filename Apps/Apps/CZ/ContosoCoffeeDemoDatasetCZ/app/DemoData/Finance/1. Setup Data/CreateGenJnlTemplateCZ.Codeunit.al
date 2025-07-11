// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Foundation;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Reports;

codeunit 31199 "Create Gen. Jnl. Template CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoGeneralLedgerCZ: Codeunit "Contoso General Ledger CZ";
        CreateNoSeriesCZ: Codeunit "Create No. Series CZ";
    begin
        ContosoGeneralLedgerCZ.InsertGeneralJournalTemplate(Banks(), BankStatementsLbl, Enum::"Gen. Journal Template Type"::Payments, false, '', true, Report::"General Ledger Document CZL");
        ContosoGeneralLedgerCZ.InsertGeneralJournalTemplate(Closing(), ClosingOperationsLbl, Enum::"Gen. Journal Template Type"::General, false, '', true, Report::"General Ledger Document CZL");
        ContosoGeneralLedgerCZ.InsertGeneralJournalTemplate(Recurring(), RecurringGeneralJournalLbl, Enum::"Gen. Journal Template Type"::General, true, CreateNoSeriesCZ.RecurringGeneralJournal(), true, Report::"General Ledger Document CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Template", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCurrency(var Rec: Record "Gen. Journal Template")
    var
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
    begin
        if Rec.Name = CreateGenJournalTemplate.General() then
            Rec."Allow VAT Difference" := true;
    end;

    procedure Banks(): Code[10]
    begin
        exit(BANKSTok);
    end;

    procedure Closing(): Code[10]
    begin
        exit(CLOSINGTok);
    end;

    procedure Recurring(): Code[10]
    begin
        exit(RECURRINGTok);
    end;

    var
        BANKSTok: Label 'BANKS', MaxLength = 10;
        BankStatementsLbl: Label 'Bank Statements', MaxLength = 80;
        CLOSINGTok: Label 'CLOSING', MaxLength = 10;
        ClosingOperationsLbl: Label 'Closing Operations', MaxLength = 80;
        RECURRINGTok: Label 'RECURRING', MaxLength = 10;
        RecurringGeneralJournalLbl: Label 'Recurring General Journal', MaxLength = 80;
}
