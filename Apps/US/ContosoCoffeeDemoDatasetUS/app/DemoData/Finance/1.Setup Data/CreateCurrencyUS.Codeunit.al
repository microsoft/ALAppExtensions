// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.Currency;

codeunit 11486 "Create Currency US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record Currency)
    var
        CreateCurrency: Codeunit "Create Currency";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
    begin
        case Rec.Code of
            CreateCurrency.CAD():
                ValidateRecordFields(Rec, CreateUSGLAccounts.InterestIncome(), CreateUSGLAccounts.InterestIncome());
            CreateCurrency.EUR():
                ValidateRecordFields(Rec, CreateUSGLAccounts.InterestIncome(), CreateUSGLAccounts.InterestIncome());
            CreateCurrency.MXN():
                ValidateRecordFields(Rec, CreateUSGLAccounts.InterestIncome(), CreateUSGLAccounts.InterestIncome());
        end;
    end;

    local procedure ValidateRecordFields(var Currency: Record "Currency"; RealizedGainsAcc: Code[20]; RealizedLossesAcc: Code[20])
    begin
        Currency.Validate("Realized Gains Acc.", RealizedGainsAcc);
        Currency.Validate("Realized Losses Acc.", RealizedLossesAcc);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Add. Reporting Currency", OnBeforeGetResidualCurrencyAccounts, '', false, false)]
    local procedure GetResidualCurrencyAccountsUS(var FXGainsAccount: Code[20]; var FXLossesAccount: Code[20]; var IsHandled: Boolean)
    var
        CreateUSGLAccount: Codeunit "Create US GL Accounts";
    begin
        FXGainsAccount := CreateUSGLAccount.CurrencyGains();
        FXLossesAccount := CreateUSGLAccount.CurrencyLosses();
        IsHandled := true;
    end;
}
