// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Foundation;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 19022 "Create IN Gen. Journal Batch"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoGeneralLedger: Codeunit "Contoso General Ledger";
        CreateINGenJournTemplate: Codeunit "Create IN Gen. Journ. Template";
        CreateINNoSeries: Codeunit "Create IN No. Series";
    begin
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateINGenJournTemplate.BankPaymentVoucher(), UserA(), DefaultLbl, Enum::"Gen. Journal Account Type"::"G/L Account", '', CreateINNoSeries.BankPaymentVoucher(), false);
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateINGenJournTemplate.BankReceiptVoucher(), UserA(), DefaultLbl, Enum::"Gen. Journal Account Type"::"G/L Account", '', CreateINNoSeries.BankReceiptVoucher(), false);
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateINGenJournTemplate.CashPaymentVoucher(), UserA(), DefaultLbl, Enum::"Gen. Journal Account Type"::"G/L Account", '', CreateINNoSeries.CashPaymentVoucher(), false);
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateINGenJournTemplate.CashReceiptVoucher(), UserA(), DefaultLbl, Enum::"Gen. Journal Account Type"::"G/L Account", '', CreateINNoSeries.CashReceiptVoucher(), false);
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateINGenJournTemplate.ContraVoucher(), UserA(), DefaultLbl, Enum::"Gen. Journal Account Type"::"G/L Account", '', CreateINNoSeries.ContraVoucher(), false);
        ContosoGeneralLedger.InsertGeneralJournalBatch(CreateINGenJournTemplate.JournalVoucher(), UserA(), DefaultLbl, Enum::"Gen. Journal Account Type"::"G/L Account", '', CreateINNoSeries.JournalVoucher(), false);
    end;

    procedure UserA(): Code[10]
    begin
        exit(UserATok);
    end;

    var
        UserATok: Label 'USER-A', MaxLength = 10;
        DefaultLbl: Label 'Default Journal', MaxLength = 100;
}
