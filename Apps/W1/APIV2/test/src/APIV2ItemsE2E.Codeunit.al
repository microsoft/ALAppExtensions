codeunit 139800 "APIV2 - Items E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Item]
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryRapidStart: Codeunit "Library - Rapid Start";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit "Assert";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        IsInitialized: Boolean;
        ConditionTxt: Label 'ENU="<?xml version=""1.0"" encoding=""utf-8"" standalone=""yes""?><ReportParameters><DataItems><DataItem name=""Item"">SORTING(Field1) WHERE(Field1=1(5))</DataItem></DataItems></ReportParameters>"';
        SampleTempCodeTxt: Label 'API000001';
        ServiceNameTxt: Label 'items';
        ItemKeyPrefixTxt: Label 'GRAPHITEM';
        ItemIdentifierTxt: Label 'number';
        ItemInventoryTxt: Label 'inventory';
        ItemCategoryCodeNotFoundErr: Label '''Could not find item category code in the response''';
        ItemBaseUoMNotFoundErr: Label 'Could not find item bsae unit of measure code in the response';

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
    end;

    [Test]
    procedure TestCreateSimpleItem()
    var
        ItemID: Text;
        ItemJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 184721] Create an item through a POST method and check if it was created
        // [GIVEN] a JSON text with an Item only with a ItemID property
        Initialize();
        ItemJSON := CreateMinimalItemJSON(ItemID);

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Items", '');
        LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the response text should contain the item information and the integration record table should map the ItemID with the ID
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        VerifyItemIDInJson(ResponseText, ItemID);
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
    end;

    [Test]
    procedure TestCreateItemWithInventoryAmount()
    var
        ItemID: Text;
        ItemJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 218727] Cannot create an item when inventory is > 0
        // [GIVEN] a JSON text with an Item with a ItemID property and inventory amount
        Initialize();

        ItemJSON := CreateMinimalItemJSON(ItemID);
        AddItemInventoryAmountJSON(ItemJSON);

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Items", '');

        // [THEN] the request should fail because inventory is read only
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON, ResponseText);
    end;

    [Test]
    procedure TestCreateItemWithCategoryId()
    var
        ItemCategory: Record "Item Category";
        ItemJSON: Text;
        ItemID: Text;
        TargetURL: Text;
        ResponseText: Text;
        ItemCategoryCode: Text;
    begin
        Initialize();

        LibraryInventory.CreateItemCategory(ItemCategory);

        ItemJSON := CreateMinimalItemJSON(ItemID);
        ItemJSON := LibraryGraphMgt.AddPropertytoJSON(ItemJSON, 'itemCategoryId', ItemCategory.SystemId);

        Commit();
        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Items", '');
        LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the response text should contain the unit of measure that also exists in the corresponding item table row
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');

        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'itemCategoryId', ItemCategory.SystemId);
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'itemCategoryCode', ItemCategoryCode), ItemCategoryCodeNotFoundErr);
        Assert.AreEqual(Format(ItemCategory.Code), ItemCategoryCode, 'Item category code is wrong');
    end;

    [Test]
    procedure TestCreateItemWithCategoryCode()
    var
        ItemCategory: Record "Item Category";
        ItemJSON: Text;
        ItemID: Text;
        TargetURL: Text;
        ResponseText: Text;
        ItemCategoryCode: Text;
    begin
        Initialize();

        LibraryInventory.CreateItemCategory(ItemCategory);

        ItemJSON := CreateMinimalItemJSON(ItemID);
        ItemJSON := LibraryGraphMgt.AddPropertytoJSON(ItemJSON, 'itemCategoryCode', ItemCategory.Code);

        Commit();
        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Items", '');
        LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the response text should contain the unit of measure that also exists in the corresponding item table row
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');

        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'itemCategoryId', ItemCategory.SystemId);
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'itemCategoryCode', ItemCategoryCode), ItemCategoryCodeNotFoundErr);
        Assert.AreEqual(Format(ItemCategory.Code), ItemCategoryCode, 'Item category code is wrong');
    end;

    [Test]
    procedure TestCreateItemWithUoMId()
    var
        UnitOfMeasure: Record "Unit of Measure";
        ItemID: Text;
        ItemJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
        UnitofMeasureCode: Text;
    begin
        // [FEATURE] [Complex Type]
        // [SCENARIO 184721] Create an item with a unit of measure through a POST method and check if it was created
        // [GIVEN] a unit of measure
        Initialize();

        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        Commit();

        // [GIVEN] a JSON text with an Item that has the Unit of Measure as a property
        ItemJSON := CreateMinimalItemJSON(ItemID);
        ItemJSON := LibraryGraphMgt.AddPropertytoJSON(ItemJSON, 'baseUnitOfMeasureId', UnitOfMeasure.SystemId);

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Items", '');
        LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the response text should contain the unit of measure that also exists in the corresponding item table row
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'baseUnitOfMeasureCode', UnitofMeasureCode), ItemBaseUoMNotFoundErr);
        Assert.AreEqual(Format(UnitOfMeasure.Code), UnitofMeasureCode, 'Base unit of measure code is wrong');
    end;

    [Test]
    procedure TestCreateItemWithUoMCode()
    var
        UnitOfMeasure: Record "Unit of Measure";
        ItemID: Text;
        ItemJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
        UnitofMeasureCode: Text;
    begin
        // [FEATURE] [Complex Type]
        // [SCENARIO 184721] Create an item with a unit of measure through a POST method and check if it was created
        // [GIVEN] a unit of measure
        Initialize();

        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        Commit();

        // [GIVEN] a JSON text with an Item that has the Unit of Measure as a property
        ItemJSON := CreateMinimalItemJSON(ItemID);
        ItemJSON := LibraryGraphMgt.AddPropertytoJSON(ItemJSON, 'baseUnitOfMeasureCode', UnitOfMeasure.Code);

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Items", '');
        LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the response text should contain the unit of measure that also exists in the corresponding item table row
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'baseUnitOfMeasureCode', UnitofMeasureCode), ItemBaseUoMNotFoundErr);
        Assert.AreEqual(Format(UnitOfMeasure.Code), UnitofMeasureCode, 'Base unit of measure code is wrong');
    end;

    [Test]
    procedure TestCreateItemWithTemplate()
    var
        DummyItem: Record "Item";
        UnitOfMeasure: Record "Unit of Measure";
        ConfigTmplSelectionRules: Record "Config. Tmpl. Selection Rules";
        ItemID: Text;
        ItemJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
        UnitCost: Integer;
        UnitofMeasureCode: Text;
    begin
        // [FEATURE] [Template]
        // [SCENARIO 184721] Create an item with a template through a POST method and check if it was created
        // [GIVEN] a field to bese template on
        Initialize();

        ItemJSON := CreateMinimalItemJSON(ItemID);

        UnitCost := LibraryRandom.RandIntInRange(1100, 1200);
        ItemJSON := LibraryGraphMgt.AddPropertytoJSON(ItemJSON, 'unitCost', UnitCost);

        // [GIVEN] a Unit of Measure
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] a template selection rules that adds the Unit of Measure if an item has the specific inventory
        CreateTemplateSelectionRulewithUoM(
          DummyItem.FieldNo("Unit Cost"), Format(UnitCost), UnitOfMeasure.Code, ConfigTmplSelectionRules);

        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Items", '');
        LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the response text should contain both the category and the unit of measure that should be applied
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'baseUnitOfMeasureCode', UnitofMeasureCode), ItemBaseUoMNotFoundErr);
        Assert.AreEqual(Format(UnitOfMeasure.Code), UnitofMeasureCode, 'Base unit of measure code is wrong');
    end;

    [Test]
    procedure TestCreateItemWithTemplateIgnoresFieldsSet()
    var
        DummyItem: Record "Item";
        UnitOfMeasure: Record "Unit of Measure";
        ConfigTmplSelectionRules: Record "Config. Tmpl. Selection Rules";
        Item: Record "Item";
        ItemID: Text;
        ItemJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
        ItemNumber: Text;
        UnitCost: Integer;
    begin
        // [FEATURE] [Template]
        // [SCENARIO 184721] Create an item with a template through a POST method
        // [GIVEN] a field to base template on
        Initialize();
        UnitCost := LibraryRandom.RandIntInRange(1100, 1200);

        // [GIVEN] a template selection rules that adds the Unit of Measure if an item has the specific inventory
        CreateTemplateSelectionRulewithUoM(
          DummyItem.FieldNo("Unit Cost"), Format(UnitCost), UnitOfMeasure.Code, ConfigTmplSelectionRules);

        ItemJSON := CreateMinimalItemJSON(ItemID);
        ItemJSON := LibraryGraphMgt.AddPropertytoJSON(ItemJSON, 'unitCost', UnitCost);

        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Items", '');
        Commit();

        // [WHEN] we POST the JSON to the web service
        LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the response text should contain the category was specified
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');

        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', ItemNumber), 'Could not find number in the response');
        Assert.IsTrue(Item.Get(ItemNumber), 'Item was not created.');
    end;

    [Test]
    procedure TestGetSimpleItem()
    var
        ItemID1: Text;
        ItemID2: Text;
        ItemJSON1: Text;
        ItemJSON2: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 184721] Create items and use a GET method to retrieve them
        // [GIVEN] 2 items in the Item Table
        Initialize();
        ItemID1 := CreateSimpleItem();
        ItemID2 := CreateSimpleItem();
        Commit();

        // [WHEN] we GET all the items from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Items", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 2 items should exist in the response
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(ResponseText, ItemIdentifierTxt, ItemID1, ItemID2, ItemJSON1, ItemJSON2),
          'Could not find the items in JSON');
        LibraryGraphMgt.VerifyIDInJson(ItemJSON1);
        LibraryGraphMgt.VerifyIDInJson(ItemJSON2);
    end;

    [Test]
    procedure TestSuccessfulTemplateSelection()
    var
        APITemplateApplication: TestPage "API Setup";
    begin
        // [SCENARIO] [184719] User can select the template for a particular API

        // [Given] The template selection page for selecting template for a specific API
        CreateSampleTemplate(Database::Item, Page::"APIV2 - Items");

        APITemplateApplication.TRAP();
        Page.RUN(Page::"API Setup");
        APITemplateApplication.NEW();

        // [When] User selects the Page ID for an API
        APITemplateApplication."Page ID".SetValue(Page::"APIV2 - Items");

        // [Then] Templates in Template code is filtered only for the selected Page ID
        APITemplateApplication."Template Code".SetValue(SampleTempCodeTxt);
    end;

    [Test]
    procedure TestSuccessfulTemplateSelectionWithSelectionCriteria()
    var
        ConfigTmplSelectionRules: Record "Config. Tmpl. Selection Rules";
        APITemplateApplication: TestPage "API Setup";
        OutStream: OutStream;
    begin
        // [SCENARIO] [184719] User can select the template for a particular API with Selection Criteria

        // [Given] A record in Config Template Selection Rules Table with Selection Criteria and Template selection page
        CreateSampleTemplate(Database::Item, Page::"APIV2 - Items");

        ConfigTmplSelectionRules.SetRange("Template Code", SampleTempCodeTxt);
        if ConfigTmplSelectionRules.FindFirst() then begin
            ConfigTmplSelectionRules."Selection Criteria".CREATEOUTSTREAM(OutStream);
            OutStream.WriteText(ConditionTxt);
            ConfigTmplSelectionRules.Modify();
        end;

        APITemplateApplication.TRAP();
        Page.RUN(Page::"API Setup");
        APITemplateApplication.NEW();

        // [When] User selects the Page ID and  for an API
        APITemplateApplication."Page ID".SetValue(Page::"APIV2 - Items");

        // [Then] Templates in Template Code only filtered for the selected Page ID
        APITemplateApplication."Template Code".SetValue(SampleTempCodeTxt);
    end;

    [Test]
    procedure TestTempcodeCannotbeblankOrInvalidValue()
    var
        APITemplateApplication: TestPage "API Setup";
    begin
        // [SCENARIO] [184719] User can not select the template for a particular API where the Template Code is Blank or Invalid

        // [Given] The template selection page is there to select template for a specific API
        CreateSampleTemplate(Database::Customer, Page::"Customer Card");

        // [When] User selects the Page ID for an API and keeps the Template Code blank or put a wrong Template code
        APITemplateApplication.TRAP();
        Page.RUN(Page::"API Setup");
        APITemplateApplication.NEW();
        APITemplateApplication."Page ID".SetValue(Page::"APIV2 - Items");

        // [Then] Page returns error message
        asserterror APITemplateApplication."Template Code".SetValue('');
        asserterror APITemplateApplication."Template Code".SetValue(SampleTempCodeTxt);
    end;

    [Test]
    procedure TestGetItemWithCategory()
    var
        Item: Record "Item";
        ItemCategory: Record "Item Category";
        ItemID: Text;
        TargetURL: Text;
        ResponseText: Text;
        ItemCategoryCode: Text;
        ItemNo: Code[20];
    begin
        Initialize();

        // [GIVEN] an item
        ItemNo := CreateSimpleItem();
        Item.Get(ItemNo);
        ItemID := Item.SystemId;

        LibraryInventory.CreateItemCategory(ItemCategory);
        Item.Validate("Item Category Code", ItemCategory.Code);
        Item.Modify(true);
        Commit();

        // [WHEN] we GET the item from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemID, Page::"APIV2 - Items", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the response text should contain the unit of measure that also exists in the corresponding item table row
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');

        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'itemCategoryId', ItemCategory.SystemId);
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'itemCategoryCode', ItemCategoryCode), ItemCategoryCodeNotFoundErr);
        Assert.AreEqual(Format(ItemCategory.Code), ItemCategoryCode, 'Item category code is wrong');
    end;

    [Test]
    procedure TestModifyItem()
    var
        Item: Record "Item";
        ItemGUID: Text;
        ItemID: Text;
        ItemJSON: Text;
        ResponseText: Text;
        PropertyName: Text;
        PropertyValue: Decimal;
        TargetURL: Text;
    begin
        // [SCENARIO 184721] Create an item, use a PATCH method to change it and then verify the changes
        // [GIVEN] an item in the Item Table
        Initialize();
        ItemID := CreateSimpleItem();
        Commit();

        // [GIVEN] a JSON text with a SellingUnitPrice property and random value
        PropertyName := 'unitPrice';
        PropertyValue := LibraryRandom.RandDecInRange(1, 500, 3);
        ItemJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', PropertyName, Format(PropertyValue, 0, 9));

        // [GIVEN] the item's unique GUID
        Item.Reset();
        Item.SetFilter("No.", ItemID);
        Item.FindFirst();
        ItemGUID := Item.SystemId;
        Assert.AreNotEqual('', ItemGUID, 'ItemGUID should not be empty');

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemGUID, Page::"APIV2 - Items", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the item in the table should have the SellingUnitPrice that was given
        Item.Get(ItemID);
        Assert.AreEqual(Item."Unit Price", PropertyValue, 'Item property value should be changed');
    end;

    [Test]
    procedure TestPatchItemWithGenProdPostingGroup()
    var
        Item: Record "Item";
        NewGenProductPostingGroup: Record "Gen. Product Posting Group";
        ItemGUID: Guid;
        TargetURL: Text;
        ItemJSON: Text;
        Response: Text;
    begin
        // [SCENARIO] An item gets reassigned to a different GenProdPostingGroup via a PATCH request
        // [GIVEN] an item with a Gen. Prod. Post. Group
        Initialize();

        LibraryInventory.CreateItemWithoutVAT(Item);
        ItemGUID := Item.SystemId;
        Commit();
        Assert.AreNotEqual('', Item."Gen. Prod. Posting Group", 'A gen. product posting group was not assigned to the new item.');
        Assert.AreNotEqual('', ItemGUID, 'The item was not created.');

        // [GIVEN] a new Gen. Prod. Post. Group
        LibraryERM.CreateGenProdPostingGroup(NewGenProductPostingGroup);
        Assert.AreNotEqual(Item."Gen. Prod. Posting Group", NewGenProductPostingGroup."Code", 'The new gen. prod posting group has the same id as the previous.');
        Commit();

        // [WHEN] reassigning via PATCH to this new group
        ItemJSON := LibraryGraphMgt.AddPropertytoJSON('', 'generalProductPostingGroupCode', NewGenProductPostingGroup."Code");
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemGUID, Page::"APIV2 - Items", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemJSON, Response);

        // [THEN] the change should be propagated
        Item.GetBySystemId(ItemGUID);
        Assert.AreEqual(Item."Gen. Prod. Posting Group Id", NewGenProductPostingGroup.SystemId, 'The item is not reassigned to the created gen. prod. post. group.');
    end;

    [Test]
    procedure TestPatchItemWithInventoryPostingGroup()
    var
        Item: Record "Item";
        NewInventoryPostingGroup: Record "Inventory Posting Group";
        ItemGUID: Guid;
        TargetURL: Text;
        ItemJSON: Text;
        Response: Text;
    begin
        // [SCENARIO] An item gets reassigned to a different InventoryPostingGroup via a PATCH request
        // [GIVEN] an item with an Inventory Post. Group
        Initialize();

        LibraryInventory.CreateItemWithoutVAT(Item);
        ItemGUID := Item.SystemId;
        Commit();
        Assert.AreNotEqual('', Item."Inventory Posting Group", 'An inventory posting group was not assigned to the new item.');
        Assert.AreNotEqual('', ItemGUID, 'The item was not created.');

        // [GIVEN] a new Inventory Post. Group
        LibraryInventory.CreateInventoryPostingGroup(NewInventoryPostingGroup);
        Assert.AreNotEqual(Item."Inventory Posting Group", NewInventoryPostingGroup."Code", 'The new inventory posting group has the same id as the previous.');
        Commit();

        // [WHEN] reassigning via PATCH to this new group
        ItemJSON := LibraryGraphMgt.AddPropertytoJSON('', 'inventoryPostingGroupCode', NewInventoryPostingGroup."Code");
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemGUID, Page::"APIV2 - Items", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemJSON, Response);

        // [THEN] the change should be propagated
        Item.GetBySystemId(ItemGUID);
        Assert.AreEqual(Item."Inventory Posting Group Id", NewInventoryPostingGroup.SystemId, 'The item is not reassigned to the created inventory post. group.');
    end;

    [Test]
    procedure TestUnassignGenProdPostingGroup()
    var
        Item: Record "Item";
        ItemJSON: Text;
        TargetURL: Text;
        ItemGUID: Guid;
        Response: Text;
    begin
        // [SCENARIO] An item with a gen. prod. posting group is removed from that group via a PATCH request
        // [GIVEN] an item with a gen. prod. posting group
        Initialize();
        LibraryInventory.CreateItemWithoutVAT(Item);
        ItemGUID := Item.SystemId;
        Commit();
        Assert.IsFalse(IsNullGuid(Item."Gen. Prod. Posting Group Id"), 'Item should be assigned to a gen. prod. posting group.');

        // [WHEN] removing it from the group via a PATCH request
        ItemJSON := LibraryGraphMgt.AddPropertytoJSON('', 'generalProductPostingGroupCode', '');
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemGUID, Page::"APIV2 - Items", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemJSON, Response);

        // [THEN] it should have gen. prod. posting group id and code unassigned
        Item.GetBySystemId(ItemGUID);
        Assert.IsTrue(IsNullGuid(Item."Gen. Prod. Posting Group Id"), 'General product posting group id should be null after being unassigned.');
        Assert.AreEqual('', Item."Gen. Prod. Posting Group", 'General product posting group code should be empty after being unassigned.');
    end;

    [Test]
    procedure TestUnassignInventoryPostingGroup()
    var
        Item: Record "Item";
        ItemJSON: Text;
        TargetURL: Text;
        ItemGUID: Guid;
        Response: Text;
    begin
        // [SCENARIO] An item with an inventory posting group is removed from that group via a PATCH request
        // [GIVEN] an item with an inventory posting group
        Initialize();
        LibraryInventory.CreateItemWithoutVAT(Item);
        ItemGUID := Item.SystemId;
        Commit();
        Assert.IsFalse(IsNullGuid(Item."Inventory Posting Group Id"), 'Item should be assigned to an inventory posting group.');

        // [WHEN] removing it from the group via a PATCH request
        ItemJSON := LibraryGraphMgt.AddPropertytoJSON('', 'inventoryPostingGroupCode', '');
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemGUID, Page::"APIV2 - Items", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemJSON, Response);

        // [THEN] it should have inventory posting group id and code unassigned
        Item.GetBySystemId(ItemGUID);
        Assert.IsTrue(IsNullGuid(Item."Inventory Posting Group Id"), 'Inventory posting group id should be null after being unassigned.');
        Assert.AreEqual('', Item."Inventory Posting Group", 'Inventory posting group code should be empty after being unassigned.');
    end;

    [Test]
    procedure TestGetRelatedEntities()
    var
        Item: Record "Item";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        InventoryPostingGroup: Record "Inventory Posting Group";
        JSONManagement: Codeunit "JSON Management";
        ItemGUID: Guid;
        GenProdPostGroupId: Text;
        InventoryPostGroupId: Text;
        TargetURL: Text;
        Response: Text;
        ResponseId: Text;
        JObject: Dotnet JObject;
    begin
        // [SCENARIO] Create an item with Gen. Prod. Post. Group and Inventory Post. Group. Verify they can be read from the response when expanding them.
        // [GIVEN] an Item, with a Gen. Prod. Post. Group and with and Inventory Post. Group
        Initialize();
        LibraryInventory.CreateItemWithoutVAT(Item);

        // [GIVEN] Item's GUID
        ItemGUID := Item.SystemId;
        Assert.AreNotEqual('', ItemGUID, 'ItemGUID should not be empty');
        Commit();

        // [GIVEN] it's Gen. Prod. Post. Group
        GenProductPostingGroup.Get(Item."Gen. Prod. Posting Group");
        GenProdPostGroupId := FormatGuid(GenProductPostingGroup.SystemId);

        // [GIVEN] and it's Inventory Post. Group
        InventoryPostingGroup.Get(Item."Inventory Posting Group");
        InventoryPostGroupId := FormatGuid(InventoryPostingGroup.SystemId);

        // [WHEN] GETting the item with this relations expanded
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemGUID, Page::"APIV2 - Items", ServiceNameTxt);
        TargetURL += '?$expand=generalProductPostingGroup,inventoryPostingGroup';
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] the response should include them as properties
        LibraryGraphMgt.GetComplexPropertyFromJSON(Response, 'generalProductPostingGroup', JObject);
        JSONManagement.GetStringPropertyValueFromJObjectByName(JObject, 'id', ResponseId);
        Assert.AreEqual(GenProdPostGroupId, LowerCase(ResponseId), 'The id of the gen. prod. post. group is not the one on the response.');

        LibraryGraphMgt.GetComplexPropertyFromJSON(Response, 'inventoryPostingGroup', JObject);
        JSONManagement.GetStringPropertyValueFromJObjectByName(JObject, 'id', ResponseId);
        Assert.AreEqual(InventoryPostGroupId, LowerCase(ResponseId), 'The id of the inventory post. group is not the one on the response.');
    end;

    [Test]
    procedure TestModifyItemInventory()
    var
        Item: Record "Item";
        ItemGUID: Text;
        ItemJSON: Text;
        ResponseText: Text;
        PropertyName: Text;
        PropertyValue: Decimal;
        TargetURL: Text;
    begin
        // [SCENARIO 184721] Create an item, use a PATCH method to change it and then verify the changes
        // [GIVEN] an item in the Item Table, with Gen Product posting group and Unit of Measure
        Initialize();
        LibraryInventory.CreateItemWithoutVAT(Item);

        // [GIVEN] the item's unique GUID
        Item.Find();
        ItemGUID := Item.SystemId;
        Assert.AreNotEqual('', ItemGUID, 'ItemGUID should not be empty');
        Commit();

        // [GIVEN] a JSON text with an Inventory property and random value
        PropertyName := 'inventory';
        PropertyValue := LibraryRandom.RandDecInRange(1, 500, 3);
        ItemJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', PropertyName, Format(PropertyValue, 0, 9));

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemGUID, Page::"APIV2 - Items", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the item in the table should have the SellingUnitPrice that was given
        Item.Find();
        Item.CalcFields(Inventory);
        Assert.AreEqual(Item.Inventory, PropertyValue, 'Item property value should be changed');
    end;

    [Test]
    procedure TestDeleteItem()
    var
        Item: Record "Item";
        ItemID: Text;
        ItemGUID: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 184721] Create an item, use a DELETE method to remove it and then verify the deletion
        // [GIVEN] an item in the table
        Initialize();
        ItemID := CreateSimpleItem();
        Commit();

        // [GIVEN] the item's unique GUID
        Item.Reset();
        Item.SetFilter("No.", ItemID);
        Item.FindFirst();
        ItemGUID := Item.SystemId;
        Assert.AreNotEqual('', ItemGUID, 'ItemGUID should not be empty');

        // [WHEN] we DELETE the item from the web service, with the item's unique ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemGUID, Page::"APIV2 - Items", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the item shouldn't exist in the table
        Item.Reset();
        Item.SetRange("No.", ItemID);
        Assert.IsTrue(Item.IsEmpty(), 'Item should not exist');
    end;

    [Test]
    procedure TestPatchItemWithCategoryCode()
    var
        Item: Record "Item";
        ItemCategory: Record "Item Category";
        ItemJSON: Text;
        ItemID: Text;
        TargetURL: Text;
        ResponseText: Text;
        ItemNo: Code[20];
    begin
        Initialize();

        // [GIVEN] an item
        ItemNo := CreateSimpleItem();
        Item.Get(ItemNo);
        ItemID := Item.SystemId;

        LibraryInventory.CreateItemCategory(ItemCategory);

        ItemJSON := LibraryGraphMgt.AddPropertytoJSON('', 'itemCategoryCode', ItemCategory.Code);

        Commit();
        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemID, Page::"APIV2 - Items", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemJSON, ResponseText);

        Item.Get(ItemNo);
        Assert.AreEqual(ItemCategory.SystemId, Item."Item Category Id", 'Item category id is wrong');
    end;

    [Test]
    procedure TestPatchItemWithCategoryId()
    var
        Item: Record "Item";
        ItemCategory: Record "Item Category";
        ItemJSON: Text;
        ItemID: Text;
        TargetURL: Text;
        ResponseText: Text;
        ItemNo: Code[20];
    begin
        Initialize();

        // [GIVEN] an item
        ItemNo := CreateSimpleItem();
        Item.Get(ItemNo);
        ItemID := Item.SystemId;

        LibraryInventory.CreateItemCategory(ItemCategory);

        ItemJSON := LibraryGraphMgt.AddPropertytoJSON('', 'itemCategoryId', ItemCategory.SystemId);

        Commit();
        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemID, Page::"APIV2 - Items", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemJSON, ResponseText);

        Item.Get(ItemNo);
        Assert.AreEqual(Format(ItemCategory.Code), Item."Item Category Code", 'Item category code is wrong');
    end;

    local procedure FormatGuid(Value: Guid): Text
    begin
        exit(LowerCase(LibraryGraphMgt.StripBrackets(Format(Value, 0, 9))));
    end;

    local procedure CreateSimpleItem(): Code[20]
    var
        Item: Record "Item";
    begin
        Item.Init();
        Item."No." := GetNextItemID();
        Item.Insert(true);
        exit(Item."No.");
    end;

    [Normal]
    local procedure CreateSampleTemplate(TableID: Integer; PageID: Integer)
    var
        ConfigTmplSelectionRules: Record "Config. Tmpl. Selection Rules";
        ConfigTemplateHeader: Record "Config. Template Header";
    begin
        ConfigTemplateHeader.SetRange(Code, SampleTempCodeTxt);
        if ConfigTemplateHeader.FindFirst() then
            ConfigTemplateHeader.DELETE();

        ConfigTemplateHeader.Init();
        ConfigTemplateHeader.Code := SampleTempCodeTxt;
        ConfigTemplateHeader."Table ID" := TableID;
        ConfigTemplateHeader.Enabled := true;
        ConfigTemplateHeader.Insert(true);

        ConfigTmplSelectionRules.SetRange("Template Code", SampleTempCodeTxt);
        ConfigTmplSelectionRules.DELETEALL();

        ConfigTmplSelectionRules.Init();
        ConfigTmplSelectionRules."Table ID" := ConfigTemplateHeader."Table ID";
        ConfigTmplSelectionRules."Page ID" := PageID;
        ConfigTmplSelectionRules."Template Code" := ConfigTemplateHeader.Code;
        ConfigTmplSelectionRules.Insert(true);

        Commit();
    end;

    local procedure CreateTemplateSelectionRulewithUoM(ItemCategoryCodeFieldNo: Integer; ItemCategoryCodeValue: Text; UomValue: Text; var ConfigTmplSelectionRules: Record "Config. Tmpl. Selection Rules")
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
        Item: Record "Item";
    begin
        LibraryRapidStart.CreateConfigTemplateHeader(ConfigTemplateHeader);
        ConfigTemplateHeader."Table ID" := Database::Item;
        ConfigTemplateHeader.Modify();

        LibraryRapidStart.CreateConfigTemplateLine(ConfigTemplateLine, ConfigTemplateHeader.Code);
        ConfigTemplateLine."Field ID" := ItemCategoryCodeFieldNo;
        ConfigTemplateLine."Default Value" := CopyStr(ItemCategoryCodeValue, 1, MaxStrLen(ConfigTemplateLine."Default Value"));
        ConfigTemplateLine.Modify(true);

        LibraryRapidStart.CreateConfigTemplateLine(ConfigTemplateLine, ConfigTemplateHeader.Code);
        ConfigTemplateLine."Field ID" := Item.FieldNo("Base Unit of Measure");
        ConfigTemplateLine."Default Value" := CopyStr(UomValue, 1, MaxStrLen(ConfigTemplateLine."Default Value"));
        ConfigTemplateLine.Modify(true);

        ConfigTmplSelectionRules.SetRange("Table ID", Database::Item);
        ConfigTmplSelectionRules.DELETEALL();
        ConfigTmplSelectionRules.Reset();

        LibraryRapidStart.CreateTemplateSelectionRule(
          ConfigTmplSelectionRules, ItemCategoryCodeFieldNo, ItemCategoryCodeValue, 1, Page::"APIV2 - Items", ConfigTemplateHeader);
    end;

    local procedure CreateMinimalItemJSON(var ItemID: Text): Text
    var
        ItemJson: Text;
    begin
        ItemID := GetNextItemID();
        ItemJson := LibraryGraphMgt.AddPropertytoJSON('', ItemIdentifierTxt, ItemID);

        exit(ItemJson);
    end;

    local procedure AddItemInventoryAmountJSON(var ItemJson: Text)
    var
        InventoryAmount: Integer;
    begin
        InventoryAmount := LibraryRandom.RandIntInRange(1, 100);
        ItemJson := LibraryGraphMgt.AddPropertytoJSON(ItemJson, ItemInventoryTxt, InventoryAmount);
    end;

    local procedure GetNextItemID(): Text[20]
    var
        Item: Record "Item";
    begin
        Item.SetFilter("No.", StrSubstNo('%1*', ItemKeyPrefixTxt));
        if Item.FindLast() then
            exit(IncStr(Item."No."));

        exit(CopyStr(ItemKeyPrefixTxt + '00001', 1, 20));
    end;

    local procedure VerifyItemIDInJson(JSONTxt: Text; ExpectedID: Text)
    var
        Item: Record "Item";
        ItemIDValue: Text;
    begin
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(JSONTxt, ItemIdentifierTxt, ItemIDValue), 'Could not find ItemId');
        Assert.AreEqual(ExpectedID, ItemIDValue, 'ItemId does not match');
        Item.SetRange("No.", ItemIDValue);
        Assert.IsFalse(Item.IsEmpty(), 'Item does not exist');
    end;
}





























































