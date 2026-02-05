// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.Currency;
using Microsoft.DemoData.Localization;

codeunit 11536 "Create Currency NL"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Currency, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCurrency(var Rec: Record Currency)
    var
        CreateCurrency: Codeunit "Create Currency";
    begin
        case Rec.Code of
            CreateCurrency.AED(),
            CreateCurrency.AUD(),
            CreateCurrency.BGN(),
            CreateCurrency.BND(),
            CreateCurrency.BRL(),
            CreateCurrency.CAD(),
            CreateCurrency.CHF(),
            CreateCurrency.CZK(),
            CreateCurrency.DKK(),
            CreateCurrency.DZD(),
            CreateCurrency.FJD(),
            CreateCurrency.HKD(),
            CreateCurrency.HUF(),
            CreateCurrency.HRK(),
            CreateCurrency.IDR(),
            CreateCurrency.INR(),
            CreateCurrency.ISK(),
            CreateCurrency.JPY(),
            CreateCurrency.KES(),
            CreateCurrency.MAD(),
            CreateCurrency.MXN(),
            CreateCurrency.MYR(),
            CreateCurrency.MZN(),
            CreateCurrency.NOK(),
            CreateCurrency.NZD(),
            CreateCurrency.NGN(),
            CreateCurrency.PHP(),
            CreateCurrency.PLN(),
            CreateCurrency.RON(),
            CreateCurrency.RUB(),
            CreateCurrency.RSD(),
            CreateCurrency.SAR(),
            CreateCurrency.SBD(),
            CreateCurrency.SEK(),
            CreateCurrency.SGD(),
            CreateCurrency.SZL(),
            CreateCurrency.THB(),
            CreateCurrency.TND(),
            CreateCurrency.TRY(),
            CreateCurrency.TOP(),
            CreateCurrency.UGX(),
            CreateCurrency.USD(),
            CreateCurrency.VUV(),
            CreateCurrency.WST(),
            CreateCurrency.XPF(),
            CreateCurrency.ZAR():
                ValidateRecordFields(Rec);
            CreateCurrency.GBP():
                begin
                    ValidateRecordFields(Rec);
                    Rec.Validate("Unit-Amount Rounding Precision", 0.00001);
                end;
        end;
    end;

    local procedure ValidateRecordFields(var Currency: Record Currency)
    begin
        Currency.Validate("Realized Gains Acc.", '');
        Currency.Validate("Realized Losses Acc.", '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Add. Reporting Currency", OnBeforeGetResidualCurrencyAccounts, '', false, false)]
    local procedure GetResidualCurrencyAccountsNL(var FXGainsAccount: Code[20]; var FXLossesAccount: Code[20]; var IsHandled: Boolean)
    var
        CreateNLGLAccount: Codeunit "Create NL GL Accounts";
    begin
        FXGainsAccount := CreateNLGLAccount.CurrencyGains();
        FXLossesAccount := CreateNLGLAccount.CurrencyLosses();
        IsHandled := true;
    end;
}
