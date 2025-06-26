// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoData.Foundation;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 5230 "Create General Ledger Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateJobQueueCategory: Codeunit "Create Job Queue Category";
        CreateNoSeries: Codeunit "Create No. Series";
        CreateCurrency: Codeunit "Create Currency";
    begin
        InsertData(CreateJobQueueCategory.GeneralLedgerPosting(), 0.01, 1, CreateNoSeries.Bank(), CreateCurrency.GBP(), true, 4);
    end;

    procedure InsertData(JobQueueCategoryCode: Code[10]; InvoiceRoundingPrecisionLCY: Decimal; LocalContAddrFormat: Integer; BankAccountNo: Code[20]; LCYCode: Code[10]; DataCheck: Boolean; AccReceivablesCategory: Integer)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CreateCurrency: Codeunit "Create Currency";
        ACYCode: Code[10];
    begin
        if not GeneralLedgerSetup.Get() then
            GeneralLedgerSetup.Insert();

        GeneralLedgerSetup.Validate("Job Queue Category Code", JobQueueCategoryCode);
        GeneralLedgerSetup.Validate("Inv. Rounding Precision (LCY)", InvoiceRoundingPrecisionLCY);
        GeneralLedgerSetup.Validate("Local Cont. Addr. Format", LocalContAddrFormat);
        GeneralLedgerSetup.Validate("Bank Account Nos.", BankAccountNo);
        GeneralLedgerSetup.Validate("LCY Code", LCYCode);
        GeneralLedgerSetup.Validate("Enable Data Check", DataCheck);
        GeneralLedgerSetup.Validate("Acc. Receivables Category", AccReceivablesCategory);
        ACYCode := LCYCode = CreateCurrency.EUR() ? CreateCurrency.USD() : CreateCurrency.EUR();
        GeneralLedgerSetup."Additional Reporting Currency" := ACYCode;
        GeneralLedgerSetup.Modify(true);
    end;
}
