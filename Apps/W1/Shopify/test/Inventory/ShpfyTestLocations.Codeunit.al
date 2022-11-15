/// <summary>
/// Codeunit Shpfy Test Locations (ID 139577).
/// </summary>
codeunit 139577 "Shpfy Test Locations"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";
        ShpfyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JLocations: JsonObject;
        KnownIds: List of [Integer];

    [Test]
    procedure UnitTestImportLocation()
    var
        ShpfyShopLocation: Record "Shpfy Shop Location";
        TempShpfyShopLocation: Record "Shpfy Shop Location" temporary;
        ShpfySyncShopLocations: Codeunit "Shpfy Sync Shop Locations";
        JLocation: JsonObject;
    begin
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        // [SCENARIO] Import/Update Shopify locations from a Json location object into a "Shpfy Shop Location" with 
        // [GIVEN] A Shop
        ShpfySyncShopLocations.SetShop(ShpfyCommunicationMgt.GetShopRecord());
        // [GIVEN] A Shopify Location as an Jsonobject. 
        JLocation := CreateShopifyLocation();
        // [GIVEN] TempShopLocation
        // [WHEN] Invode ImportLocation
        ShpfySyncShopLocations.ImportLocation(JLocation, TempShpfyShopLocation);
        // [THEN] TempShopLocation.Count() = 1 WHERE TempShopLocation."Shop Code) = Shop.Code
        ShpfyShopLocation.SetRange("Shop Code", ShpfyCommunicationMgt.GetShopRecord().Code);
        LibraryAssert.RecordCount(ShpfyShopLocation, 1);
    end;

    [Test]
    procedure UnitTestGetShopifyLocations()
    var
        ShpfyShopLocation: Record "Shpfy Shop Location";
        ShpfySyncShopLocations: Codeunit "Shpfy Sync Shop Locations";
        NumberOfLocations: Integer;
    begin
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        // [SCENARIO] Invoke a REST API to get the locations from Shopify.
        // For the moking we will choose a random number between 1 and 5 to generate the number of locations that will be in the result set.
        // [GIVEN] A Shop
        ShpfySyncShopLocations.SetShop(ShpfyCommunicationMgt.GetShopRecord());
        // [GIVEN] The number of locations we want to have in the moking data.
        NumberOfLocations := Any.IntegerInRange(1, 5);
        CreateShopifyLocationJson(NumberOfLocations);
        // [WHEN] Invoke Sync Locations.
        ShpfySyncShopLocations.SyncLocations(JLocations.AsToken());
        // [THEN] ShpfyShopLocation.Count = NumberOfLocations WHERE (Shop.Code = Field("Shop Code"))
        ShpfyShopLocation.SetRange("Shop Code", ShpfyCommunicationMgt.GetShopRecord().Code);
        LibraryAssert.RecordCount(ShpfyShopLocation, NumberOfLocations);
    end;

    [Test]
    procedure TestGetShopifyLocationsFullCycle()
    var
        ShpfyShopLocation: Record "Shpfy Shop Location";
        NumberOfLocations: Integer;
    begin
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        // [SCENARIO] Invoke a REST API to get the locations from Shopify.
        // For the moking we will choose a random number between 1 and 5 to generate the number of locations that will be in the result set.
        // [GIVEN] The number of locations we want to have in the moking data.
        NumberOfLocations := Any.IntegerInRange(1, 5);
        CreateShopifyLocationJson(NumberOfLocations);
        // [WHEN] Invoke the request.

        // [THEN] The function return true if it was succesfull.
        LibraryAssert.IsTrue(GetShopifyLocations(), GetLastErrorText());
        // [THEN] ShpfyShopLocation.Count = NumberOfLocations WHERE (Shop.Code = Field("Shop Code"))
        ShpfyShopLocation.SetRange("Shop Code", ShpfyCommunicationMgt.GetShopRecord().Code);
        LibraryAssert.RecordCount(ShpfyShopLocation, NumberOfLocations);
    end;

    local procedure GetShopifyLocations() Result: Boolean
    var
        ShpfyShop: Record "Shpfy Shop";
        ShpfyLocationSubcriber: Codeunit "Shpfy Location Subcriber";
    begin
        ShpfyLocationSubcriber.InitShopiyLocations(JLocations);
        BindSubscription(ShpfyLocationSubcriber);
        ShpfyShop := ShpfyCommunicationMgt.GetShopRecord();
        Result := Codeunit.Run(Codeunit::"Shpfy Sync Shop Locations", ShpfyShop);
        UnbindSubscription(ShpfyLocationSubcriber);
    end;

    local procedure CreateShopifyLocationJson(NumberOfLocations: Integer)
    var
        JArray: JsonArray;
        Index: Integer;
    begin
        Clear(JLocations);
        Clear(KnownIds);
        for Index := 1 TO NumberOfLocations do
            JArray.Add(CreateShopifyLocation());
        JLocations.Add('locations', JArray);
    end;

    local procedure CreateShopifyLocation(): JsonObject
    var
        Id: Integer;
        JLocation: JsonObject;
        JValue: JsonValue;
        CreateDate: Date;
        LocationIdTxt: Label 'gid:\/\/shopify\/Location\/%1', Comment = '%1 = LocationId', Locked = true;
    begin
        repeat
            Id := Any.IntegerInRange(12354658, 99999999);
        until not KnownIds.Contains(Id);
        KnownIds.Add(Id);
        JLocation.Add('id', Id);
        JLocation.Add('name', Any.AlphabeticText(30));
        JLocation.Add('address1', Any.AlphabeticText(30));
        JLocation.Add('address2', '');
        JLocation.Add('city', Any.AlphabeticText(30));
        JLocation.Add('zip', Format(Any.IntegerInRange(1000, 9999)));
        JLocation.Add('province', '');
        JLocation.Add('country', '');
        JLocation.Add('phone', '');
        CreateDate := Any.DateInRange(20200101D, 100);
        JLocation.Add('created_at', CreateDateTime(CreateDate, 0T));
        JLocation.Add('updated_at', CreateDateTime(Any.DateInRange(CreateDate, 0, 100), 0T));
        JLocation.Add('country_code', '');
        JLocation.Add('country_name', '');
        JValue.SetValueToNull();
        JLocation.Add('province_code', JValue);
        JLocation.Add('legacy', false);
        JLocation.Add('active', true);
        JLocation.Add('admin_graphql_api_id', StrSubstNo(LocationIdTxt, id));
        JLocation.Add('localized_country_name', '');
        JLocation.Add('localized_province_name', JValue);
        exit(JLocation);
    end;
}
