// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.Foundation;

codeunit 5665 "Create Bank Jnl. Batches"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoGeneralLedger: Codeunit "Contoso General Ledger";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateGenJournalTemplate.General(), Daily(), DailyLbl, Enum::"Gen. Journal Account Type"::"Bank Account", '', CreateNoSeries.GeneralJournal(), false);
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateGenJournalTemplate.PaymentJournal(), PaymentReconciliation(), PaymentReconciliationLbl, Enum::"Gen. Journal Account Type"::"Bank Account", '', CreateNoSeries.PaymentJournal(), true);
    end;

    procedure Daily(): Code[10]
    begin
        exit(DailyTok);
    end;

    procedure PaymentReconciliation(): Code[10]
    begin
        exit(PaymentReconciliationTok);
    end;

    var
        DailyTok: Label 'DAILY', MaxLength = 10;
        PaymentReconciliationTok: Label 'PMT REG', MaxLength = 10;
        DailyLbl: Label 'Daily Journal Entries', MaxLength = 100;
        PaymentReconciliationLbl: Label 'Bank Reconciliation', MaxLength = 100;
}
