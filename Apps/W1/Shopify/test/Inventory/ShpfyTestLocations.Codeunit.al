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
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JData: JsonObject;
        KnownIds: List of [Integer];

    [Test]
    procedure UnitTestImportLocation()
    var
        ShopLocation: Record "Shpfy Shop Location";
        TempShopLocation: Record "Shpfy Shop Location" temporary;
        SyncShopLocations: Codeunit "Shpfy Sync Shop Locations";
        JLocation: JsonObject;
    begin
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        // [SCENARIO] Import/Update Shopify locations from a Json location object into a "Shpfy Shop Location" with 
        // [GIVEN] A Shop
        SyncShopLocations.SetShop(CommunicationMgt.GetShopRecord());
        // [GIVEN] A Shopify Location as an Jsonobject. 
        JLocation := CreateShopifyLocation(false);
        // [GIVEN] TempShopLocation
        // [WHEN] Invode ImportLocation
        SyncShopLocations.ImportLocation(JLocation, TempShopLocation);
        // [THEN] TempShopLocation.Count() = 1 WHERE TempShopLocation."Shop Code) = Shop.Code
        ShopLocation.SetRange("Shop Code", CommunicationMgt.GetShopRecord().Code);
        LibraryAssert.RecordCount(ShopLocation, 1);
    end;

    [Test]
    procedure UnitTestGetShopifyLocations()
    var
        ShopLocation: Record "Shpfy Shop Location";
        SyncShopLocations: Codeunit "Shpfy Sync Shop Locations";
        JsonHelper: Codeunit "Shpfy Json Helper";
        NumberOfLocations: Integer;
        JLocations: JsonObject;
    begin
        ShopLocation.DeleteAll();
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        // [SCENARIO] Invoke a REST API to get the locations from Shopify.
        // For the moking we will choose a random number between 1 and 5 to generate the number of locations that will be in the result set.
        // [GIVEN] A Shop
        SyncShopLocations.SetShop(CommunicationMgt.GetShopRecord());
        // [GIVEN] The number of locations we want to have in the moking data.
        NumberOfLocations := Any.IntegerInRange(1, 5);
        CreateShopifyLocationJson(NumberOfLocations);
        // [GIVEN] Locations as Json object
        JsonHelper.GetJsonObject(JData.AsToken(), JLocations, 'locations');
        // [WHEN] Invoke Sync Locations.
        SyncShopLocations.SyncLocations(JLocations);
        // [THEN] ShpfyShopLocation.Count = NumberOfLocations WHERE (Shop.Code = Field("Shop Code"))
        ShopLocation.SetRange("Shop Code", CommunicationMgt.GetShopRecord().Code);
        LibraryAssert.RecordCount(ShopLocation, NumberOfLocations);
    end;

    [Test]
    procedure TestGetShopifyLocationsFullCycle()
    var
        ShopLocation: Record "Shpfy Shop Location";
        NumberOfLocations: Integer;
    begin
        ShopLocation.DeleteAll();
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
        ShopLocation.SetRange("Shop Code", CommunicationMgt.GetShopRecord().Code);
        LibraryAssert.RecordCount(ShopLocation, NumberOfLocations);
    end;

    local procedure GetShopifyLocations() Result: Boolean
    var
        Shop: Record "Shpfy Shop";
        LocationSubcriber: Codeunit "Shpfy Location Subcriber";
    begin
        Commit();
        LocationSubcriber.InitShopifyLocations(JData);
        BindSubscription(LocationSubcriber);
        Shop := CommunicationMgt.GetShopRecord();
        Result := Codeunit.Run(Codeunit::"Shpfy Sync Shop Locations", Shop);
        UnbindSubscription(LocationSubcriber);
    end;

    local procedure CreateShopifyLocationJson(NumberOfLocations: Integer)
    var
        JLocations: JsonObject;
        JEdges: JsonArray;
        JPageInfo: JsonObject;
        JExtensions: JsonObject;
        JCost: JsonObject;
        JThrottleStatus: JsonObject;
        Index: Integer;
    begin
        Clear(JData);
        Clear(KnownIds);
        for Index := 1 TO NumberOfLocations do
            JEdges.Add(CreateShopifyLocation(Index = 1));
        JLocations.Add('edges', JEdges);
        JPageInfo.Add('hasNextPage', false);
        JLocations.Add('pageInfo', JPageInfo);
        JData.Add('locations', JLocations);
        JThrottleStatus.Add('maximumAvailable', 1000.0);
        JThrottleStatus.Add('currentlyAvailable', 996);
        JThrottleStatus.Add('restoreRate', 50.0);
        JCost.Add('requestedQueryCost', 12);
        JCost.Add('actualQueryCost', 4);
        JCost.Add('throttleStatus', JThrottleStatus);
        JData.Add('extensions', JExtensions);
    end;

    local procedure CreateShopifyLocation(AsPrimary: Boolean): JsonObject
    var
        Id: Integer;
        JLocation: JsonObject;
        JNode: JsonObject;
        LocationIdTxt: Label 'gid:\/\/shopify\/Location\/%1', Comment = '%1 = LocationId', Locked = true;
    begin
        repeat
            Id := Any.IntegerInRange(12354658, 99999999);
        until not KnownIds.Contains(Id);
        KnownIds.Add(Id);
        JNode.Add('id', StrSubstNo(LocationIdTxt, id));
        JNode.Add('isActive', true);
        JNode.Add('isPrimary', AsPrimary);
        JNode.Add('name', Any.AlphabeticText(30));
        JNode.Add('legacyResourceId', Format(Id, 0, 9));
        JLocation.Add('node', JNode);
        JLocation.Add('cursor', Any.AlphabeticText(88));
        exit(JLocation);
    end;
}
