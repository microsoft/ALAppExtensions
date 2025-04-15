// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.Currency;

codeunit 19065 "Create IN Currency Ex. Rate"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCurrency: Codeunit "Contoso Currency";
        CreateCurrency: Codeunit "Create Currency";
        date: Date;
    begin
        date := DMY2Date(2, 1, 2013);
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), date, 100, 100, 7433.0088, 7433.0088);
        date := DMY2Date(2, 4, 2013);
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), date, 100, 100, 7139.0916, 7139.0916);
        date := CalcDate('<CY - 3Y + 1D>', WorkDate());
        ContosoCurrency.InsertCurrencyExchangeRate(CreateCurrency.GBP(), date, 100, 100, 6943.75, 6943.75);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Currency Exchange Rate", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCurrencyExchangeRate(var Rec: Record "Currency Exchange Rate")
    var
        Currency: Codeunit "Create Currency";
        date: Date;
    begin
        date := CalcDate('<CY - 3Y + 1D>', WorkDate());
        if Rec."Currency Code" = Currency.AED() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1623.1224, 1623.1224);
        if Rec."Currency Code" = Currency.AUD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 2381.6707, 2381.6707);
        if Rec."Currency Code" = Currency.BGN() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 2194.8905, 2194.8905);
        if Rec."Currency Code" = Currency.BND() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 2728.8726, 2728.8726);
        if Rec."Currency Code" = Currency.BRL() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1702.5953, 1702.5953);
        if Rec."Currency Code" = Currency.CAD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 2999.0267, 2999.0267);
        if Rec."Currency Code" = Currency.CZK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 3773.3982, 3773.3982);
        if Rec."Currency Code" = Currency.CZK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 184.8305, 184.8305);
        if Rec."Currency Code" = Currency.DKK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 811.03, 811.03);
        if Rec."Currency Code" = Currency.DZD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 77.8901, 77.8901);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 44.8413, 44.8413);
        if Rec."Currency Code" = Currency.FJD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 2092.8629, 2092.8629);
        if Rec."Currency Code" = Currency.HKD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 608.5158, 608.5158);
        if Rec."Currency Code" = Currency.HRK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 820.5109, 820.5109);
        if Rec."Currency Code" = Currency.HUF() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 25.5142, 25.5142);
        if Rec."Currency Code" = Currency.IDR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 0.6702, 0.6702);
        if Rec."Currency Code" = Currency.ISK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 69.0998, 69.0998);
        if Rec."Currency Code" = Currency.JPY() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 40.3082, 40.3082);
        if Rec."Currency Code" = Currency.KES() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 75.1752, 75.1752);
        if Rec."Currency Code" = Currency.MAD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 571.7268, 571.7268);
        if Rec."Currency Code" = Currency.MXN() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 500.6488, 500.6488);
        if Rec."Currency Code" = Currency.MYR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1254.0146, 1254.0146);
        if Rec."Currency Code" = Currency.MZN() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 2.5825, 2.5825);
        if Rec."Currency Code" = Currency.NGN() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 47.219, 47.219);
        if Rec."Currency Code" = Currency.NOK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 712.4899, 712.4899);
        if Rec."Currency Code" = Currency.NZD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 2015.734, 2015.734);
        if Rec."Currency Code" = Currency.PHP() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 93.0251, 93.0251);
        if Rec."Currency Code" = Currency.PLN() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1152.6358, 1152.6358);
        if Rec."Currency Code" = Currency.RON() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1.8232, 1.8232);
        if Rec."Currency Code" = Currency.RSD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 70.9916, 70.9916);
        if Rec."Currency Code" = Currency.RUB() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 163.1792, 163.1792);
        if Rec."Currency Code" = Currency.SAR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 1269.3431, 1269.3431);
        if Rec."Currency Code" = Currency.SBD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 881.1841, 881.1841);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 687.1857, 687.1857);
        if Rec."Currency Code" = Currency.SGD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 2746.2287, 2746.2287);
        if Rec."Currency Code" = Currency.SZL() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 655.0984, 655.0984);
        if Rec."Currency Code" = Currency.THB() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 106.8938, 106.8938);
        if Rec."Currency Code" = Currency.TND() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 4375.3365, 4375.3365);
        if Rec."Currency Code" = Currency.TOP() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 23.6948, 23.6948);
        if Rec."Currency Code" = Currency.TRY() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 3703.7631, 3703.7631);
        if Rec."Currency Code" = Currency.UGX() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 3.4459, 3.4459);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 4505.2717, 4505.2717);
        if Rec."Currency Code" = Currency.VUV() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 33.3333, 33.3333);
        if Rec."Currency Code" = Currency.WST() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 16633.0899, 16633.0899);
        if Rec."Currency Code" = Currency.XPF() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 50.7218, 50.7218);
        if Rec."Currency Code" = Currency.ZAR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 554.8256, 554.8256);

        date := DMY2Date(2, 1, 2013);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 6050.446, 6050.446);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 706.0016, 706.0016);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 4562.206, 4562.206);

        date := DMY2Date(2, 4, 2013);
        if Rec."Currency Code" = Currency.EUR() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 6046.0664, 6046.0664);
        if Rec."Currency Code" = Currency.SEK() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 727.4939, 727.4939);
        if Rec."Currency Code" = Currency.USD() then
            if Rec."Starting Date" = date then
                ValidateCurrencyExchRate(Rec, 4708.7591, 4708.7591);
    end;

    local procedure ValidateCurrencyExchRate(var CurrencyExchangeRate: Record "Currency Exchange Rate"; RelationalExchRateAmount: Decimal; RelationalAdjmtExchRateAmt: Decimal)
    begin
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", RelationalExchRateAmount);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", RelationalAdjmtExchRateAmt);
    end;
}
