codeunit 139713 "APIV1 - Currencies E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Currency]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        IsInitialized: Boolean;
        ServiceNameTxt: Label 'currencies';
        CurrencyPrefixTxt: Label 'GRAPH';
        EmptyJSONErr: Label 'The JSON must not be blank.';
        WrongPropertyValueErr: Label 'Incorrect property value for %1.', Comment = '%1=Property name';

    [Test]
    procedure TestVerifyIDandLastModifiedDateTime()
    var
        Currency: Record "Currency";
        CurrencyCode: Text;
        CurrencyId: Guid;
    begin
        // [SCENARIO] Create a currency and verify it has Id and LastDateTimeModified.
        Initialize();

        // [GIVEN] a modified currency record
        CurrencyCode := CreateCurrency();

        // [WHEN] we retrieve the currency from the database
        Currency.GET(CurrencyCode);
        CurrencyId := Currency.SystemId;

        // [THEN] the currency should have last date time modified
        Currency.TESTFIELD("Last Modified Date Time");
    end;

    [Test]
    procedure TestGetCurrencies()
    var
        CurrencyCode: array[2] of Text;
        CurrencyJSON: array[2] of Text;
        ResponseText: Text;
        TargetURL: Text;
        "Count": Integer;
    begin
        // [SCENARIO] User can retrieve all Currency records from the Currencies API.
        Initialize();

        // [GIVEN] 2 currencies in the Currency Table
        FOR Count := 1 TO 2 DO
            CurrencyCode[Count] := CreateCurrency();

        // [WHEN] A GET request is made to the Currencies API.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Currencies", ServiceNameTxt);

        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 2 item categories should exist in the response
        FOR Count := 1 TO 2 DO
            GetAndVerifyIDFromJSON(ResponseText, CurrencyCode[Count], CurrencyJSON[Count]);
    end;

    [Test]
    procedure TestCreateCurrency()
    var
        Currency: Record "Currency";
        TempCurrency: Record "Currency" temporary;
        CurrencyJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create a Currency through a POST method and check if it was created
        Initialize();

        // [GIVEN] The user has constructed a Currency JSON object to send to the service.
        CurrencyJSON := GetCurrencyJSON(TempCurrency);

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Currencies", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, CurrencyJSON, ResponseText);

        // [THEN] The response text contains the Currency information.
        VerifyCurrencyProperties(ResponseText, TempCurrency);

        // [THEN] The Currency has been created in the database.
        Currency.GET(TempCurrency.Code);
        VerifyCurrencyProperties(ResponseText, Currency);
    end;

    [Test]
    procedure TestModifyCurrency()
    var
        Currency: Record "Currency";
        RequestBody: Text;
        ResponseText: Text;
        TargetURL: Text;
        CurrencyCode: Text;
    begin
        // [SCENARIO] User can modify a currency through a PATCH request.
        Initialize();

        // [GIVEN] A currency exists.
        CurrencyCode := CreateCurrency();
        Currency.GET(CurrencyCode);
        Currency.Description := LibraryUtility.GenerateGUID();
        RequestBody := GetCurrencyJSON(Currency);

        // [WHEN] The user makes a patch request to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Currency.SystemId, PAGE::"APIV1 - Currencies", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, ResponseText);

        // [THEN] The response text contains the new values.
        VerifyCurrencyProperties(ResponseText, Currency);

        // [THEN] The record in the database contains the new values.
        Currency.GET(Currency.Code);
        VerifyCurrencyProperties(ResponseText, Currency);
    end;

    [Test]
    procedure TestDeleteCurrency()
    var
        Currency: Record "Currency";
        CurrencyCode: Text;
        TargetURL: Text;
        Responsetext: Text;
    begin
        // [SCENARIO] User can delete a currency by making a DELETE request.
        Initialize();

        // [GIVEN] A currency exists.
        CurrencyCode := CreateCurrency();
        Currency.GET(CurrencyCode);

        // [WHEN] The user makes a DELETE request to the endpoint for the currency.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Currency.SystemId, PAGE::"APIV1 - Currencies", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', Responsetext);

        // [THEN] The response is empty.
        Assert.AreEqual('', Responsetext, 'DELETE response must be empty.');

        // [THEN] The currency is no longer in the database.
        Currency.SetRange(Code, CurrencyCode);
        Assert.IsTrue(Currency.IsEmpty(), 'Currency must be deleted.');
    end;

    local procedure Initialize()
    begin
        IF IsInitialized THEN
            EXIT;

        IsInitialized := TRUE;
    end;

    local procedure CreateCurrency(): Text
    var
        Currency: Record "Currency";
    begin
        LibraryERM.CreateCurrency(Currency);
        COMMIT();

        EXIT(Currency.Code);
    end;

    local procedure GetAndVerifyIDFromJSON(ResponseText: Text; CurrencyCode: Text; CurrencyJSON: Text)
    begin
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(ResponseText, 'code', CurrencyCode, CurrencyCode,
            CurrencyJSON, CurrencyJSON), 'Could not find the currency in JSON');
        LibraryGraphMgt.VerifyIDInJson(CurrencyJSON);
    end;

    local procedure GetNextCurrencyID(): Code[10]
    var
        Currency: Record "Currency";
    begin
        Currency.SETFILTER(Code, STRSUBSTNO('%1*', CurrencyPrefixTxt));
        IF Currency.FINDLAST() THEN
            EXIT(INCSTR(Currency.Code));

        EXIT(COPYSTR(CurrencyPrefixTxt + '00001', 1, 10));
    end;

    local procedure GetCurrencyJSON(var Currency: Record "Currency") CurrencyJSON: Text
    begin
        IF Currency.Code = '' THEN
            Currency.Code := GetNextCurrencyID();
        IF Currency.Description = '' THEN
            Currency.Description := LibraryUtility.GenerateGUID();

        CurrencyJSON := LibraryGraphMgt.AddPropertytoJSON('', 'code', Currency.Code);
        CurrencyJSON := LibraryGraphMgt.AddPropertytoJSON(CurrencyJSON, 'displayName', Currency.Description);
    end;

    local procedure VerifyPropertyInJSON(JSON: Text; PropertyName: Text; ExpectedValue: Text)
    var
        PropertyValue: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(JSON, PropertyName, PropertyValue);
        Assert.AreEqual(ExpectedValue, PropertyValue, STRSUBSTNO(WrongPropertyValueErr, PropertyName));
    end;

    local procedure VerifyCurrencyProperties(CurrencyJSON: Text; Currency: Record "Currency")
    begin
        Assert.AreNotEqual('', CurrencyJSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJson(CurrencyJSON);
        VerifyPropertyInJSON(CurrencyJSON, 'code', Currency.Code);
        VerifyPropertyInJSON(CurrencyJSON, 'displayName', Currency.Description);
    end;
}
















