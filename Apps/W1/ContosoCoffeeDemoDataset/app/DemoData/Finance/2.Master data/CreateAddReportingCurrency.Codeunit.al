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
        FXGainsAccount: Code[20];
        FXLossesAccount: Code[20];
    begin
        GetResidualCurrencyAccounts(FXGainsAccount, FXLossesAccount);
        Currency.SetFilter(Code, '%1|%2', CreateCurrency.EUR(), CreateCurrency.USD());
        if Currency.FindSet(true) then begin
            repeat
                Currency.Validate("Residual Gains Account", FXGainsAccount);
                Currency.Validate("Residual Losses Account", FXLossesAccount);
                Currency.Modify(true);
            until Currency.Next() = 0;
        end;
    end;

    local procedure GetResidualCurrencyAccounts(var FXGainsAccount: Code[20]; var FXLossesAccount: Code[20])
    var
        CreateGLAccount: Codeunit "Create G/L Account";
        IsHandled: Boolean;
    begin
        OnBeforeGetResidualCurrencyAccounts(FXGainsAccount, FXLossesAccount, IsHandled);
        if IsHandled then
            exit;

        FXGainsAccount := CreateGLAccount.RealizedFXGains();
        FXLossesAccount := CreateGLAccount.RealizedFXLosses();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetResidualCurrencyAccounts(var FXGainsAccount: Code[20]; var FXLossesAccount: Code[20]; var IsHandled: Boolean)
    begin
    end;
}