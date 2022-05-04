codeunit 139868 "APIV2 - Locations E2E"
{
    // version Test,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Api] [Location]
    end;

    var
        Assert: Codeunit Assert;
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryUtility: Codeunit "Library - Utility";
        IsInitialized: Boolean;
        EmptyJSONErr: Label 'JSON should not be empty.';
        ServiceNameTxt: Label 'locations';
        SalesOrderServiceNameTxt: Label 'salesOrders';
        SalesOrderLineServiceNameTxt: Label 'salesOrderLines';

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
    end;

    [Test]
    procedure TestGetLocation()
    var
        Location: Record Location;
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can get a location with a GET request to the service.
        Initialize();

        // [GIVEN] A location exists in the system.
        CreateLocationWithAddress(Location);

        // [WHEN] The user makes a GET request for a given Location.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Location.SystemId, Page::"APIV2 - Locations", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] The response text contains the Location information.
        VerifyProperties(Response, Location);
    end;

    [Test]
    procedure TestCreateLocation()
    var
        Location: Record Location;
        TempLocation: Record Location temporary;
        LocationJSON: Text;
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO] User can create a new Location through a POST method.
        Initialize();

        // [GIVEN] The user has constructed a Location JSON object to send to the service.
        CreateLocationWithAddress(TempLocation);
        LocationJSON := GetLocationJSON(TempLocation);

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Locations", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, LocationJSON, Response);

        // [THEN] The Location has been created in the database with all the details.
        Location.Get(TempLocation.Code);
        VerifyProperties(Response, Location);
    end;

    [Test]
    procedure TestCreateSalesOrderLineWithLocation()
    var
        Location: Record Location;
        TempLocation: Record Location temporary;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        TargetURL: Text;
        Response: Text;
        SalesOrderLineWithLocationJSON: Text;
    begin
        // [SCENARIO] User can post a sales order line with location.
        Initialize();

        // [GIVEN] A sales order and an item.
        LibrarySales.CreateSalesOrder(SalesHeader);
        LibraryInventory.CreateItem(Item);
        CreateLocationWithAddress(TempLocation);
        Commit();
        SalesOrderLineWithLocationJSON := GetSalesOrderLineWithLocationJSON(Item, TempLocation);

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt
          .CreateTargetURLWithSubpage(
            SalesHeader.SystemId,
            Page::"APIV2 - Sales Orders",
            SalesOrderServiceNameTxt,
            SalesOrderLineServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, SalesOrderLineWithLocationJSON, Response);

        // [THEN] Location and sales order line with locationId is created.
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("No.", Item."No.");
        SalesLine.FindFirst();
        Location.Get(TempLocation.Code);
        Assert.AreEqual(SalesLine."Location Code", TempLocation.Code, 'Location codes should be equal.');
        VerifyLocationIdProperty(Response, Location);
    end;

    [Test]
    procedure TestModifyLocationWithAddress()
    var
        Location: Record Location;
        TempLocation: Record Location temporary;
        RequestBody: Text;
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can modify address in a Location through a PATCH request.
        Initialize();

        // [GIVEN] A Location exists with an address.
        CreateLocationWithAddress(Location);
        TempLocation.TransferFields(Location);
        TempLocation.Address := LibraryUtility.GenerateGUID();
        TempLocation.City := LibraryUtility.GenerateGUID();
        RequestBody := GetLocationJSON(TempLocation);

        // [WHEN] The user makes a patch request to the service and specifies address fields.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Location.SystemId, Page::"APIV2 - Locations", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, Response);

        // [THEN] The response contains the new values.
        VerifyProperties(Response, TempLocation);

        // [THEN] The Location in the database contains the updated values.
        Location.Get(Location.Code);
        Assert.AreEqual(Location.Address, TempLocation.Address, 'Addresses should be equal.');
        Assert.AreEqual(Location.City, TempLocation.City, 'Cities should be equal.');
    end;

    [Test]
    procedure TestDeleteLocation()
    var
        Location: Record Location;
        LocationCode: Code[10];
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO] User can delete a Location by making a DELETE request.
        Initialize();

        // [GIVEN] A Location exists.
        CreateLocation(Location);
        LocationCode := Location.Code;

        // [WHEN] The user makes a DELETE request to the endpoint for the Location.
        TargetURL := LibraryGraphMgt.CreateTargetURL(Location.SystemId, Page::"APIV2 - Locations", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', Response);

        // [THEN] The response is empty.
        Assert.AreEqual('', Response, 'DELETE response should be empty.');

        // [THEN] The Location is no longer in the database.
        Location.SetRange(Code, LocationCode);
        Assert.IsTrue(Location.IsEmpty(), 'Location should be deleted.');
    end;

    local procedure CreateLocationWithAddress(var Location: Record Location)
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.FindFirst();
        CreateLocation(Location);
        Location.Address := LibraryUtility.GenerateGUID();
        Location."Address 2" := LibraryUtility.GenerateGUID();
        Location.City := LibraryUtility.GenerateGUID();
        Location.County := LibraryUtility.GenerateGUID();
        Location."Country/Region Code" := CountryRegion.Code;
        Location.Modify(true);
        Commit();
    end;

    local procedure CreateLocation(var Location: Record Location)
    begin
        LibraryWarehouse.CreateLocation(Location);
        Location.Contact := LibraryUtility.GenerateGUID();
        Location.Modify(true);
        Commit();  // Need to commit in order to unlock tables and allow web service to pick up changes.
    end;

    local procedure GetLocationJSON(var Location: Record Location) LocationJSON: Text
    begin
        if Location.Code = '' then
            Location.Code := LibraryUtility.GenerateRandomCodeWithLength(Location.FieldNo(Code), Database::Location, 10);
        if Location.Name = '' then
            Location.Name := LibraryUtility.GenerateGUID();
        LocationJSON := LibraryGraphMgt.AddPropertytoJSON(LocationJSON, 'code', Location.Code);
        LocationJSON := LibraryGraphMgt.AddPropertytoJSON(LocationJSON, 'displayName', Location.Name);
        LocationJSON := LibraryGraphMgt.AddPropertytoJSON(LocationJSON, 'contact', Location.Contact);
        LocationJSON := LibraryGraphMgt.AddPropertytoJSON(LocationJSON, 'addressLine1', Location.Address);
        LocationJSON := LibraryGraphMgt.AddPropertytoJSON(LocationJSON, 'addressLine2', Location."Address 2");
        LocationJSON := LibraryGraphMgt.AddPropertytoJSON(LocationJSON, 'city', Location.City);
        LocationJSON := LibraryGraphMgt.AddPropertytoJSON(LocationJSON, 'state', Location.County);
        LocationJSON := LibraryGraphMgt.AddPropertytoJSON(LocationJSON, 'country', Location."Country/Region Code");
        LocationJSON := LibraryGraphMgt.AddPropertytoJSON(LocationJSON, 'postalCode', Location."Post Code");
        LocationJSON := LibraryGraphMgt.AddPropertytoJSON(LocationJSON, 'phoneNumber', Location."Phone No.");
        LocationJSON := LibraryGraphMgt.AddPropertytoJSON(LocationJSON, 'email', Location."E-Mail");
        LocationJSON := LibraryGraphMgt.AddPropertytoJSON(LocationJSON, 'website', Location."Home Page");
        exit(LocationJSON);
    end;

    local procedure GetSalesOrderLineWithLocationJSON(Item: Record Item; var Location: Record Location) SalesOrderLineJSON: Text
    var
        JSONManagement: Codeunit "JSON Management";
        "Newtonsoft.Json.Linq.JObject": DotNet JObject;
        LocationJSON: Text;
    begin
        SalesOrderLineJSON := LibraryGraphMgt.AddPropertytoJSON(SalesOrderLineJSON, 'itemId', FormatGuid(Item.SystemId));
        SalesOrderLineJSON := LibraryGraphMgt.AddPropertytoJSON(SalesOrderLineJSON, 'quantity', Random(5));
        LocationJSON := GetLocationJSON(Location);
        JSONManagement.InitializeObject(SalesOrderLineJSON);
        JSONManagement.GetJSONObject("Newtonsoft.Json.Linq.JObject");
        JSONManagement.AddJObjectToJObject("Newtonsoft.Json.Linq.JObject", 'location', LocationJSON);
        SalesOrderLineJSON := JSONManagement.WriteObjectToString();
        exit(SalesOrderLineJSON);
    end;

    local procedure VerifyProperties(JSON: Text; Location: Record Location)
    begin
        Assert.AreNotEqual('', JSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJSON(JSON);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'code', Location.Code);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'displayName', Location.Name);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'contact', Location.Contact);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'addressLine1', Location.Address);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'addressLine2', Location."Address 2");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'city', Location.City);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'state', Location.County);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'country', Location."Country/Region Code");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'postalCode', Location."Post Code");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'phoneNumber', Location."Phone No.");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'email', Location."E-Mail");
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'website', Location."Home Page");
    end;

    local procedure VerifyLocationIdProperty(JSON: Text; Location: Record Location)
    begin
        Assert.AreNotEqual('', JSON, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJSON(JSON);
        LibraryGraphMgt.VerifyPropertyInJSON(JSON, 'locationId', FormatGuid(Location.SystemId));
    end;

    local procedure FormatGuid(Value: Guid): Text
    begin
        exit(LowerCase(LibraryGraphMgt.StripBrackets(Format(Value, 0, 9))));
    end;
}
