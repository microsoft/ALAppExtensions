// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Foundation.Enums;
using Microsoft.Finance.Currency;

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
        GenerateGLAccountsForReportingCurrency();
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

    procedure GenerateGLAccountsForReportingCurrency()
    var
        GLAccountCategory: Record "G/L Account Category";
        SubCategory: Text[80];
    begin
        ContosoGLAccount.AddAccountForLocalization(ResidualFXGainsName(), '9350');
        ContosoGLAccount.AddAccountForLocalization(ResidualFXLossesName(), '9360');

        SubCategory := Format(GLAccountCategory."Account Category"::Income, 80);
        ContosoGLAccount.InsertGLAccount(ResidualFXGains(), ResidualFXGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Expense, 80);
        ContosoGLAccount.InsertGLAccount(ResidualFXLosses(), ResidualFXLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
    end;

    procedure UpdateCurrencyResidualAccounts()
    var
        Currency: Record "Currency";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateCurrency: Codeunit "Create Currency";
    begin
        Currency.SetFilter(Code, '%1|%2', CreateCurrency.EUR(), CreateCurrency.USD());
        if Currency.FindSet(true) then begin
            repeat
                Currency.Validate("Residual Gains Account", ResidualFXGains());
                Currency.Validate("Residual Losses Account", ResidualFXLosses());
                Currency.Modify(true);
            until Currency.Next() = 0;
        end;
    end;

    procedure ResidualFXGains(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResidualFXGainsName()));
    end;

    procedure ResidualFXGainsName(): Text[100]
    begin
        exit(ResidualFXGainsLbl);
    end;

    procedure ResidualFXLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResidualFXLossesName()));
    end;

    procedure ResidualFXLossesName(): Text[100]
    begin
        exit(ResidualFXLossesLbl);
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        ResidualFXGainsLbl: Label 'Residual FX Gains', MaxLength = 100;
        ResidualFXLossesLbl: Label 'Residual FX Losses', MaxLength = 100;
}