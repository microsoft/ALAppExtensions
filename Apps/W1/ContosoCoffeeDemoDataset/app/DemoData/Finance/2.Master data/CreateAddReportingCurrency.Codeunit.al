// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 5627 "Create Add. Reporting Currency"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "General Ledger Setup" = rm,
        tabledata Currency = rm;

    trigger OnRun()
    begin
        ConfigureAdditionalReportingCurrency();
        UpdateCurrencyResidualAccounts();
    end;

    procedure ConfigureAdditionalReportingCurrency()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CreateCurrency: Codeunit "Create Currency";
        ACYCode: Code[10];
    begin
        GeneralLedgerSetup.Get();
        ACYCode := GeneralLedgerSetup."LCY Code" = CreateCurrency.EUR() ? CreateCurrency.USD() : CreateCurrency.EUR();
        GeneralLedgerSetup."Additional Reporting Currency" := ACYCode;
        GeneralLedgerSetup.Modify(true);
    end;

    procedure UpdateCurrencyResidualAccounts()
    var
        Currency: Record "Currency";
        CreateCurrency: Codeunit "Create Currency";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        Currency.SetFilter(Code, '%1|%2', CreateCurrency.EUR(), CreateCurrency.USD());
        if Currency.FindSet(true) then begin
            repeat
                Currency.Validate("Residual Gains Account", CreateGLAccount.RealizedFXGains());
                Currency.Validate("Residual Losses Account", CreateGLAccount.RealizedFXLosses());
                Currency.Modify(true);
            until Currency.Next() = 0;
        end;
    end;
}