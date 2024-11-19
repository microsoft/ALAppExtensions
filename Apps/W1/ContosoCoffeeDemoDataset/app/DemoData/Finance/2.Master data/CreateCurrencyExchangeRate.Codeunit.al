codeunit 5438 "Create Currency Exchange Rate"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        Currency: Codeunit "Create Currency";
        ContosoCurrency: Codeunit "Contoso Currency";
        date: Date;
    begin
        date := CalcDate('<CY - 3Y + 1D>', WorkDate());

        ContosoCurrency.InsertCurrencyExchangeRate(Currency.AED(), date, 100, 100, 23.3753, 23.3753);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.AUD(), date, 100, 100, 34.2995, 34.2995);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.BGN(), date, 100, 100, 31.6096, 31.6096);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.BND(), date, 100, 100, 39.2997, 39.2997);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.BRL(), date, 100, 100, 24.5198, 24.5198);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.CAD(), date, 100, 100, 43.1903, 43.1903);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.CHF(), date, 100, 100, 54.3424, 54.3424);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.CZK(), date, 100, 100, 2.6618, 2.6618);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.DKK(), date, 100, 100, 11.68, 11.68);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.DZD(), date, 100, 100, 1.1217, 1.1217);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.EUR(), date, 1, 1, 0.6458, 0.6458);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.FJD(), date, 100, 100, 30.1402, 30.1402);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.HKD(), date, 100, 100, 8.7635, 8.7635);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.HRK(), date, 100, 100, 11.8165, 11.8165);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.HUF(), date, 100, 100, 0.3674, 0.3674);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.IDR(), date, 100, 100, 0.0097, 0.0097);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.INR(), date, 100, 100, 1.4401, 1.4401);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.ISK(), date, 100, 100, 0.9951, 0.9951);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.JPY(), date, 100, 100, 0.5805, 0.5805);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.KES(), date, 100, 100, 1.0826, 1.0826);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.MAD(), date, 100, 100, 8.2337, 8.2337);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.MZN(), date, 1000, 1000, 0.0372, 0.0372);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.MXN(), date, 100, 100, 7.2101, 7.2101);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.MYR(), date, 100, 100, 18.0596, 18.0596);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.NGN(), date, 100, 100, 0.68, 0.68);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.NOK(), date, 100, 100, 10.2609, 10.2609);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.NZD(), date, 100, 100, 29.0295, 29.0295);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.PHP(), date, 100, 100, 1.3397, 1.3397);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.PLN(), date, 100, 100, 16.5996, 16.5996);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.RON(), date, 1000, 1000, 0.0263, 0.0263);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.RSD(), date, 100, 100, 1.0224, 1.0224);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.RUB(), date, 100, 100, 2.35, 2.35);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.SAR(), date, 100, 100, 18.2804, 18.2804);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.SBD(), date, 100, 100, 12.6903, 12.6903);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.SEK(), date, 100, 100, 9.8965, 9.8965);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.SGD(), date, 100, 100, 39.5496, 39.5496);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.SZL(), date, 100, 100, 9.4344, 9.4344);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.ZAR(), date, 100, 100, 7.9903, 7.9903);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.THB(), date, 100, 100, 1.5394, 1.5394);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.TND(), date, 100, 100, 63.0111, 63.0111);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.TOP(), date, 1, 1, 0.3412, 0.3412);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.TRY(), date, 100, 100, 53.3395, 53.3395);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.UGX(), date, 100, 100, 0.0496, 0.0496);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.USD(), date, 100, 100, 64.8824, 64.8824);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.WST(), date, 100, 100, 239.5404, 239.5404);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.VUV(), date, 100, 100, 0.48, 0.48);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.XPF(), date, 100, 100, 0.7305, 0.7305);

        date := DMY2Date(2, 1, 2013);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.USD(), date, 100, 100, 65.7023, 65.7023);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.SEK(), date, 100, 100, 10.1674, 10.1674);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.EUR(), date, 100, 100, 87.1351, 87.1351);

        date := DMY2Date(2, 4, 2013);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.USD(), date, 100, 100, 67.8129, 67.8129);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.SEK(), date, 100, 100, 10.477, 10.477);
        ContosoCurrency.InsertCurrencyExchangeRate(Currency.EUR(), date, 100, 100, 87.0721, 87.0721);
    end;
}