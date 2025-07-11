codeunit 139858 "APIV2 Currency Exch. Rate E2E"
{
    Subtype = Test;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        Assert: Codeunit Assert;
        ServiceNameTxt: Label 'currencyExchangeRates', Locked = true;

    [Test]
    procedure TestGetCurrencyExchangeRates()
    var
        Currencies: array[10] of Record Currency;
        CurrencyExchangeRates: array[10] of Record "Currency Exchange Rate";
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create currencies and exchange rates, use a GET method to retrieve the exchange rates.

        // [GIVEN] Currencies and exchange rates are created.
        Initialize();
        CreateCurrencyExchangeRates(Currencies, CurrencyExchangeRates);
        Commit();

        // [WHEN] A GET method is called to retrieve the exchange rates.
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2- Currency Exchange Rates", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The exchange rates are retrieved.
        VerifyCurrencyExchangeRates(ResponseText, CurrencyExchangeRates, 10);
    end;

    [Test]
    procedure TestSingleGetCurrencyExchangeRate()
    var
        Currencies: array[10] of Record Currency;
        CurrencyExchangeRates: array[10] of Record "Currency Exchange Rate";
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create currencies and exchange rates, use a GET method to retrieve the exchange rates.

        // [GIVEN] Currencies and exchange rates are created.
        Initialize();
        CreateCurrencyExchangeRates(Currencies, CurrencyExchangeRates);
        Commit();

        // [WHEN] A GET method is called to retrieve one of these exchange rates.
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURL(CurrencyExchangeRates[3].SystemId, Page::"APIV2- Currency Exchange Rates", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The selected exchange rate is retrieved.
        if GetLastErrorText() <> '' then
            Assert.ExpectedError('Request failed with error: ' + GetLastErrorText());
        Assert.AreNotEqual('', ResponseText, 'Expected a response, but got an empty string.');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        LibraryGraphMgt.VerifyPropertyInJSON(ResponseText, 'id', LowerCase(CurrencyExchangeRates[3].SystemId).Replace('{', '').Replace('}', ''));
    end;

    local procedure VerifyCurrencyExchangeRates(ResponseText: Text; var CurrencyExchangeRates: array[10] of Record "Currency Exchange Rate"; N: Integer)
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        IdJsonToken: JsonToken;
        ListExchangeRates: List of [Text];
        I: Integer;
    begin
        for I := 1 to N do
            ListExchangeRates.Add(LowerCase(CurrencyExchangeRates[I].SystemId).Replace('{', '').Replace('}', ''));

        JsonObject.ReadFrom(ResponseText);
        JsonObject.Get('value', JsonToken);
        JsonArray := JsonToken.AsArray();
        Assert.AreEqual(N, JsonArray.Count(), 'Expected ' + Format(N) + ' exchange rates, but got ' + Format(JsonArray.Count()));
        foreach JsonToken in JsonArray do begin
            JsonToken.AsObject().Get('id', IdJsonToken);
            Assert.IsTrue(ListExchangeRates.Contains(IdJsonToken.AsValue().AsText()), 'Expected exchange rate with id ' + IdJsonToken.AsValue().AsText() + ' to be returned, but it was not.');
            JsonToken.AsObject().Get('currencyCode', IdJsonToken);
            JsonToken.AsObject().Get('startingDate', IdJsonToken);
            JsonToken.AsObject().Get('exchangeRateAmount', IdJsonToken);
            JsonToken.AsObject().Get('relationalCurrencyCode', IdJsonToken);
            JsonToken.AsObject().Get('relationalExchangeRateAmount', IdJsonToken);
        end;
    end;

    local procedure CreateCurrencyExchangeRates(var Currencies: array[10] of Record Currency; var CurrencyExchangeRates: array[10] of Record "Currency Exchange Rate")
    var
        I: Integer;
    begin
        for I := 1 to 10 do begin
            LibraryERM.CreateCurrency(Currencies[I]);
            CurrencyExchangeRates[I].Init();
            CurrencyExchangeRates[I]."Starting Date" := WorkDate();
            CurrencyExchangeRates[I]."Currency Code" := Currencies[I].Code;
            CurrencyExchangeRates[I]."Exchange Rate Amount" := LibraryRandom.RandDecInRange(1, 1000, 2);
            CurrencyExchangeRates[I].Insert();
        end;
    end;

    local procedure Initialize()
    var
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        Currency.DeleteAll();
        CurrencyExchangeRate.DeleteAll();
    end;
}