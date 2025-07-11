codeunit 139810 "APIV2 - Countries/Regions E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Country/Region]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryERM: Codeunit "Library - ERM";
        IsInitialized: Boolean;
        ServiceNameTxt: Label 'countriesRegions';
        CountryRegionPrefixTxt: Label 'GRAPH';
        EmptyJSONErr: Label 'The JSON should not be blank.';
        WrongPropertyValueErr: Label 'Incorrect property value for %1.', Comment = '%1=Property name';

    [Test]
    procedure TestVerifyIDandLastModifiedDateTime()
    var
        CountryRegion: Record "Country/Region";
        CountryRegionCode: Text;
        CountryRegionId: Guid;
    begin
        // [SCENARIO] Create a Country/Region and verify it has Id and LastDateTimeModified.
        Initialize();

        // [GIVEN] a modified Country/Region record
        CountryRegionCode := CreateCountryRegion();

        // [WHEN] we retrieve the Country/Region from the database
        CountryRegion.Get(CountryRegionCode);
        CountryRegionId := CountryRegion.SystemId;

        // [THEN] the Country/Region should have last date time modified
        CountryRegion.TestField("Last Modified Date Time");
    end;

    [Test]
    procedure TestGetCountriesRegions()
    var
        CountryRegionCode: array[2] of Text;
        CountryRegionJSON: array[2] of Text;
        ResponseText: Text;
        TargetURL: Text;
        "Count": Integer;
    begin
        // [SCENARIO] User can retrieve all Country/Region records from the countriesRegions API.
        Initialize();

        // [GIVEN] 2 item categories in the Country/Region Table
        for Count := 1 to 2 do
            CountryRegionCode[Count] := CreateCountryRegion();

        // [WHEN] A GET request is made to the Country/Region API.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Countries/Regions", ServiceNameTxt);

        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 2 Country/Region should exist in the response
        for Count := 1 to 2 do
            GetAndVerifyIDFromJSON(ResponseText, CountryRegionCode[Count], CountryRegionJSON[Count]);
    end;

    [Test]
    procedure TestCreateCountriesRegions()
    var
        CountryRegion: Record "Country/Region";
        TempCountryRegion: Record "Country/Region" temporary;
        CountryRegionJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create a Country/Region through a POST method and check if it was created
        Initialize();

        // [GIVEN] The user has constructed a Country/Region JSON object to send to the service.
        CountryRegionJSON := GetCountryRegionJSON(TempCountryRegion);

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Countries/Regions", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, CountryRegionJSON, ResponseText);

        // [THEN] The response text contains the Country/Region information.
        VerifyCountryRegionProperties(ResponseText, TempCountryRegion);

        // [THEN] The Country/Region has been created in the database.
        CountryRegion.Get(TempCountryRegion.Code);
        VerifyCountryRegionProperties(ResponseText, CountryRegion);
    end;

    [Test]
    procedure TestModifyCountriesRegions()
    var
        CountryRegion: Record "Country/Region";
        RequestBody: Text;
        ResponseText: Text;
        TargetURL: Text;
        CountryRegionCode: Text;
    begin
        // [SCENARIO] User can modify a Country/Region through a PATCH request.
        Initialize();

        // [GIVEN] A Country/Region exists.
        CountryRegionCode := CreateCountryRegion();
        CountryRegion.Get(CountryRegionCode);
        CountryRegion.Name := LibraryUtility.GenerateGUID();
        RequestBody := GetCountryRegionJSON(CountryRegion);

        // [WHEN] The user makes a patch request to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL(CountryRegion.SystemId, Page::"APIV2 - Countries/Regions", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, ResponseText);

        // [THEN] The response text contains the new values.
        VerifyCountryRegionProperties(ResponseText, CountryRegion);

        // [THEN] The record in the database contains the new values.
        CountryRegion.Get(CountryRegion.Code);
        VerifyCountryRegionProperties(ResponseText, CountryRegion);
    end;

    [Test]
    procedure TestDeleteCountriesRegions()
    var
        CountryRegion: Record "Country/Region";
        CountryRegionCode: Text;
        TargetURL: Text;
        Responsetext: Text;
    begin
        // [SCENARIO] User can delete a Country/Region by making a DELETE request.
        Initialize();

        // [GIVEN] An Country/Region exists.
        CountryRegionCode := CreateCountryRegion();
        CountryRegion.Get(CountryRegionCode);

        // [WHEN] The user makes a DELETE request to the endpoint for the Country/Region.
        TargetURL := LibraryGraphMgt.CreateTargetURL(CountryRegion.SystemId, Page::"APIV2 - Countries/Regions", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', Responsetext);

        // [THEN] The response is empty.
        Assert.AreEqual('', Responsetext, 'DELETE response should be empty.');

        // [THEN] The Country/Region is no longer in the database.
        CountryRegion.SetRange(Code, CountryRegionCode);
        Assert.IsTrue(CountryRegion.IsEmpty(), 'Country/Region should be deleted.');
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
    end;

    local procedure CreateCountryRegion(): Text
    var
        CountryRegion: Record "Country/Region";
    begin
        LibraryERM.CreateCountryRegion(CountryRegion);
        Commit();

        exit(CountryRegion.Code);
    end;

    local procedure GetAndVerifyIDFromJSON(ResponseText: Text; CountryRegionCode: Text; CountryRegionJSON: Text)
    begin
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(ResponseText, 'code', CountryRegionCode, CountryRegionCode,
            CountryRegionJSON, CountryRegionJSON), 'Could not find the Country/Region in JSON');
        LibraryGraphMgt.VerifyIDInJson(CountryRegionJSON);
    end;

    local procedure GetNextCountryRegionID(): Code[10]
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.SetFilter(Code, StrSubstNo('%1*', CountryRegionPrefixTxt));
        if CountryRegion.FindLast() then
            exit(IncStr(CountryRegion.Code));

        exit(CopyStr(CountryRegionPrefixTxt + '00001', 1, 10));
    end;

    local procedure GetCountryRegionJSON(var CountryRegion: Record "Country/Region") CountryRegionJSON: Text
    begin
        if CountryRegion.Code = '' then
            CountryRegion.Code := GetNextCountryRegionID();
        if CountryRegion.Name = '' then
            CountryRegion.Name := LibraryUtility.GenerateGUID();
        CountryRegionJSON := LibraryGraphMgt.AddPropertytoJSON('', 'code', CountryRegion.Code);
        CountryRegionJSON := LibraryGraphMgt.AddPropertytoJSON(CountryRegionJSON, 'displayName', CountryRegion.Name);
        CountryRegionJSON := LibraryGraphMgt.AddPropertytoJSON(CountryRegionJSON, 'addressFormat', Format(CountryRegion."Address Format"));
    end;

    local procedure VerifyPropertyInJSON(JSON: Text; PropertyName: Text; ExpectedValue: Text)
    var
        PropertyValue: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(JSON, PropertyName, PropertyValue);
        Assert.AreEqual(ExpectedValue, PropertyValue, StrSubstNo(WrongPropertyValueErr, PropertyName));
    end;

    local procedure VerifyCountryRegionProperties(CountryRegionJSON: Text; CountryRegion: Record "Country/Region")
    begin
        Assert.AreNotEqual('', CountryRegionJSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJson(CountryRegionJSON);
        VerifyPropertyInJSON(CountryRegionJSON, 'code', CountryRegion.Code);
        VerifyPropertyInJSON(CountryRegionJSON, 'displayName', CountryRegion.Name);
        // VerifyPropertyInJSON(CountryRegionJSON, 'addressFormat', Format(CountryRegion."Address Format"));
    end;
}
















