codeunit 139700 "APIV1 - Items E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Item]
    end;

    var
        LibraryRapidStart: Codeunit "Library - Rapid Start";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit "Assert";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        GraphCollectionMgtItem: Codeunit "Graph Collection Mgt - Item";
        LibraryUtility: Codeunit "Library - Utility";
        IsInitialized: Boolean;
        ConditionTxt: Label 'ENU="<?xml version=""1.0"" encoding=""utf-8"" standalone=""yes""?><ReportParameters><DataItems><DataItem name=""Item"">SORTING(Field1) WHERE(Field1=1(5))</DataItem></DataItems></ReportParameters>"';
        SampleTempCodeTxt: Label 'API000001';
        ServiceNameTxt: Label 'items';
        ItemKeyPrefixTxt: Label 'GRAPHITEM';
        ItemIdentifierTxt: Label 'number';
        ItemInventoryTxt: Label 'inventory';
        UoMIdTxt: Label 'baseUnitOfMeasureId';
        ItemCategoryCodeNotFoundErr: Label '''Could not find item category code in the response''';


    local procedure Initialize()
    begin
        IF IsInitialized THEN
            EXIT;

        IsInitialized := TRUE;
        COMMIT();
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
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Items", '');
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
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Items", '');

        // [THEN] the request should fail because inventory is read only
        ASSERTERROR LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON, ResponseText);
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

        COMMIT();
        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Items", '');
        LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the response text should contain the unit of measure that also exists in the corresponding item table row
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');

        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'itemCategoryId', ItemCategory.SystemId);
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'itemCategoryCode', ItemCategoryCode), ItemCategoryCodeNotFoundErr);
        Assert.AreEqual(FORMAT(ItemCategory.Code), ItemCategoryCode, 'Item category code is wrong');
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

        COMMIT();
        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Items", '');
        LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the response text should contain the unit of measure that also exists in the corresponding item table row
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');

        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'itemCategoryId', ItemCategory.SystemId);
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'itemCategoryCode', ItemCategoryCode), ItemCategoryCodeNotFoundErr);
        Assert.AreEqual(FORMAT(ItemCategory.Code), ItemCategoryCode, 'Item category code is wrong');
    end;

    [Test]
    procedure TestCreateItemWithComplexType()
    var
        UnitOfMeasure: Record "Unit of Measure";
        ItemID: Text;
        ComplexTypeJSON: Text;
        ItemJSON: Text;
        ItemwithUoMJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [FEATURE] [Complex Type]
        // [SCENARIO 184721] Create an item with a complex type through a POST method and check if it was created
        // [GIVEN] a unit of measure
        Initialize();

        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        COMMIT();

        // [GIVEN] a JSON text with an Item that has the Unit of Measure as a property
        ComplexTypeJSON := GetUoMJSON(UnitOfMeasure);
        ItemJSON := CreateMinimalItemJSON(ItemID);
        ItemwithUoMJSON := LibraryGraphMgt.AddComplexTypetoJSON(ItemJSON, 'baseUnitOfMeasure', ComplexTypeJSON);

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Items", '');
        LibraryGraphMgt.PostToWebService(TargetURL, ItemwithUoMJSON, ResponseText);

        // [THEN] the response text should contain the unit of measure that also exists in the corresponding item table row
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        LibraryGraphMgt.VerifyUoMInJson(ResponseText, UnitOfMeasure.Code, ItemIdentifierTxt);
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
          DummyItem.FIELDNO("Unit Cost"), FORMAT(UnitCost), UnitOfMeasure.Code, ConfigTmplSelectionRules);

        COMMIT();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Items", '');
        LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the response text should contain both the category and the unit of measure that should be applied
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        LibraryGraphMgt.VerifyUoMInJson(ResponseText, UnitOfMeasure.Code, ItemIdentifierTxt);
    end;

    [Test]
    procedure TestCreateItemWithTemplateIgnoresFieldsSet()
    var
        DummyItem: Record "Item";
        UnitOfMeasure: Record "Unit of Measure";
        ConfigTmplSelectionRules: Record "Config. Tmpl. Selection Rules";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        Item: Record "Item";
        ExpectedUnitOfMeasureCode: Code[10];
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
          DummyItem.FIELDNO("Unit Cost"), FORMAT(UnitCost), UnitOfMeasure.Code, ConfigTmplSelectionRules);

        ExpectedUnitOfMeasureCode := LibraryUtility.GenerateGUID();

        ItemJSON := CreateMinimalItemJSON(ItemID);
        ItemJSON := LibraryGraphMgt.AddPropertytoJSON(ItemJSON, 'unitCost', UnitCost);
        ItemJSON :=
          LibraryGraphMgt.AddComplexTypetoJSON(ItemJSON, 'baseUnitOfMeasure', STRSUBSTNO('{"code":"%1"}', ExpectedUnitOfMeasureCode));

        // [GIVEN] a Unit of Measure
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Items", '');

        COMMIT();

        // [WHEN] we POST the JSON to the web service
        LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the response text should contain both the category and the unit of measure that was specified
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        LibraryGraphMgt.VerifyUoMInJson(ResponseText, ExpectedUnitOfMeasureCode, ItemIdentifierTxt);

        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'number', ItemNumber), 'Could not find number in the response');
        Assert.IsTrue(Item.GET(ItemNumber), 'Item was not created.');
        ItemUnitOfMeasure.SETRANGE("Item No.", Item."No.");
        Assert.AreEqual(1, ItemUnitOfMeasure.COUNT(), 'Only single unit of measure should be found');
        ItemUnitOfMeasure.FINDFIRST();
        Assert.AreEqual(ExpectedUnitOfMeasureCode, ItemUnitOfMeasure.Code, 'Wrong unit of measure was created');
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
        COMMIT();

        // [WHEN] we GET all the items from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Items", ServiceNameTxt);
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
        CreateSampleTemplate(DATABASE::Item, PAGE::"APIV1 - Items");

        APITemplateApplication.TRAP();
        PAGE.RUN(PAGE::"API Setup");
        APITemplateApplication.NEW();

        // [When] User selects the Page ID for an API
        APITemplateApplication."Page ID".SETVALUE(PAGE::"APIV1 - Items");

        // [Then] Templates in Template code is filtered only for the selected Page ID
        APITemplateApplication."Template Code".SETVALUE(SampleTempCodeTxt);
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
        CreateSampleTemplate(DATABASE::Item, PAGE::"APIV1 - Items");

        ConfigTmplSelectionRules.SETRANGE("Template Code", SampleTempCodeTxt);
        IF ConfigTmplSelectionRules.FINDFIRST() THEN BEGIN
            ConfigTmplSelectionRules."Selection Criteria".CREATEOUTSTREAM(OutStream);
            OutStream.WRITETEXT(ConditionTxt);
            ConfigTmplSelectionRules.MODIFY();
        END;

        APITemplateApplication.TRAP();
        PAGE.RUN(PAGE::"API Setup");
        APITemplateApplication.NEW();

        // [When] User selects the Page ID and  for an API
        APITemplateApplication."Page ID".SETVALUE(PAGE::"APIV1 - Items");

        // [Then] Templates in Template Code only filtered for the selected Page ID
        APITemplateApplication."Template Code".SETVALUE(SampleTempCodeTxt);
    end;

    [Test]
    procedure TestTempcodeCannotbeblankOrInvalidValue()
    var
        APITemplateApplication: TestPage "API Setup";
    begin
        // [SCENARIO] [184719] User can not select the template for a particular API where the Template Code is Blank or Invalid

        // [Given] The template selection page is there to select template for a specific API
        CreateSampleTemplate(DATABASE::Customer, PAGE::"Customer Card");

        // [When] User selects the Page ID for an API and keeps the Template Code blank or put a wrong Template code
        APITemplateApplication.TRAP();
        PAGE.RUN(PAGE::"API Setup");
        APITemplateApplication.NEW();
        APITemplateApplication."Page ID".SETVALUE(PAGE::"APIV1 - Items");

        // [Then] Page returns error message
        ASSERTERROR APITemplateApplication."Template Code".SETVALUE('');
        ASSERTERROR APITemplateApplication."Template Code".SETVALUE(SampleTempCodeTxt);
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
        Item.GET(ItemNo);
        ItemID := Item.SystemId;

        LibraryInventory.CreateItemCategory(ItemCategory);
        Item.VALIDATE("Item Category Code", ItemCategory.Code);
        Item.MODIFY(TRUE);
        COMMIT();

        // [WHEN] we GET the item from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemID, PAGE::"APIV1 - Items", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the response text should contain the unit of measure that also exists in the corresponding item table row
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');

        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'itemCategoryId', ItemCategory.SystemId);
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'itemCategoryCode', ItemCategoryCode), ItemCategoryCodeNotFoundErr);
        Assert.AreEqual(FORMAT(ItemCategory.Code), ItemCategoryCode, 'Item category code is wrong');
    end;

    [Test]
    procedure TestGetItemWithComplexType()
    var
        UnitOfMeasure: Record "Unit of Measure";
        ItemID1: Text;
        ItemID2: Text;
        ItemJSON1: Text;
        ItemJSON2: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [FEATURE] [Complex Type]
        // [SCENARIO 184721] Create items with complex type and use a GET method to retrieve them
        // [GIVEN] a Unit of Measure
        Initialize();
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] 2 items with the Unit of Measure as property
        ItemID1 := CreateItemwithUoM(UnitOfMeasure.Code);
        ItemID2 := CreateItemwithUoM(UnitOfMeasure.Code);
        COMMIT();

        // [WHEN] we GET all the items from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Items", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the items should exist in the response text with their Unit of Measure
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(ResponseText, ItemIdentifierTxt, ItemID1, ItemID2, ItemJSON1, ItemJSON2),
          'Could not find the items in JSON');
        LibraryGraphMgt.VerifyUoMInJson(ItemJSON1, UnitOfMeasure.Code, ItemIdentifierTxt);
        LibraryGraphMgt.VerifyUoMInJson(ItemJSON2, UnitOfMeasure.Code, ItemIdentifierTxt);
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
        COMMIT();

        // [GIVEN] a JSON text with a SellingUnitPrice property and random value
        PropertyName := 'unitPrice';
        PropertyValue := LibraryRandom.RandDecInRange(1, 500, 3);
        ItemJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', PropertyName, FORMAT(PropertyValue, 0, 9));

        // [GIVEN] the item's unique GUID
        Item.RESET();
        Item.SETFILTER("No.", ItemID);
        Item.FINDFIRST();
        ItemGUID := Item.SystemId;
        Assert.AreNotEqual('', ItemGUID, 'ItemGUID should not be empty');

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemGUID, PAGE::"APIV1 - Items", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the item in the table should have the SellingUnitPrice that was given
        Item.GET(ItemID);
        Assert.AreEqual(Item."Unit Price", PropertyValue, 'Item property value should be changed');
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
        COMMIT();

        // [GIVEN] a JSON text with an Inventory property and random value
        PropertyName := 'inventory';
        PropertyValue := LibraryRandom.RandDecInRange(1, 500, 3);
        ItemJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', PropertyName, FORMAT(PropertyValue, 0, 9));

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemGUID, PAGE::"APIV1 - Items", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the item in the table should have the SellingUnitPrice that was given
        Item.Find();
        Item.CalcFields(Inventory);
        Assert.AreEqual(Item.Inventory, PropertyValue, 'Item property value should be changed');
    end;


    [Test]
    procedure TestModifyItemWithComplexType()
    var
        UnitOfMeasure: Record "Unit of Measure";
        Item: Record "Item";
        ItemID: Text;
        ItemGUID: Text;
        ItemJSON: Text;
        ComplexTypeJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [FEATURE] [Complex Type]
        // [SCENARIO 184721] Create an item witha Unit of Measure, use a PATCH method to change it and then verify the changes

        // [GIVEN] a Unit of Measure
        Initialize();
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] an item in the Item Table with the Unit of Measure
        ItemID := CreateItemwithUoM(UnitOfMeasure.Code);
        COMMIT();

        // [GIVEN] the item's unique GUID
        Item.RESET();
        Item.SETFILTER("No.", ItemID);
        Item.FINDFIRST();
        ItemGUID := Item.SystemId;
        Assert.AreNotEqual('', ItemGUID, 'ItemGUID should not be empty');

        // [GIVEN] a JSON text with a BaseUnitOfMeasure property and value the Unit of Measure
        ComplexTypeJSON := GetUoMJSON(UnitOfMeasure);
        ItemJSON := LibraryGraphMgt.AddComplexTypetoJSON('{}', 'baseUnitOfMeasure', ComplexTypeJSON);

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemGUID, PAGE::"APIV1 - Items", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the item should have the Unit of Measure as a value in the table
        Item.GET(ItemID);
        Assert.AreEqual(Item."Base Unit of Measure", UnitOfMeasure.Code, 'Base unit of measure should be changed');
    end;

    [Test]
    procedure TestRemoveComplexTypeFromItemUsingNull()
    var
        Item: Record "Item";
        UnitOfMeasure: Record "Unit of Measure";
        ItemID: Text;
        ItemGUID: Text;
        ItemJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [FEATURE] [Complex Type]
        // [SCENARIO 184721] Create an item with ItemCategory, use a PATCH method to empty it's ItemCategory and then verify the changes

        // [GIVEN] an Item in the table with a ItemCategory
        Initialize();
        ItemID := CreateMinimalItem();
        Item.RESET();
        Item.SETFILTER("No.", ItemID);
        Item.FINDFIRST();
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        Item.VALIDATE("Base Unit of Measure", UnitOfMeasure.Code);
        Item.MODIFY(TRUE);
        COMMIT();

        // [GIVEN] the item's unique GUID
        Item.RESET();
        Item.SETFILTER("No.", ItemID);
        Item.FINDFIRST();
        ItemGUID := Item.SystemId;
        Assert.AreNotEqual('', ItemGUID, 'ItemGUID should not be empty');

        // [GIVEN] a JSON text with an empty value
        ItemJSON := LibraryGraphMgt.AddComplexTypetoJSON(ItemJSON, 'baseUnitOfMeasure', 'null');

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemGUID, PAGE::"APIV1 - Items", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the item shouldn't have a value in the table
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        Item.GET(ItemID);
        Assert.AreEqual(Item."Base Unit of Measure", '', 'The item shouldn''t have a Base Unit Of Measure');
    end;

    [Test]
    procedure TestRemoveComplexTypeFromItemUsingBlankValue()
    var
        Item: Record "Item";
        UnitOfMeasure: Record "Unit of Measure";
        ItemID: Text;
        ItemGUID: Text;
        ItemJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [FEATURE] [Complex Type]
        // [SCENARIO 184721] Create an item with ItemCategory, use a PATCH method to empty it's ItemCategory and then verify the changes

        // [GIVEN] an Item in the table with a ItemCategory
        Initialize();
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        ItemID := CreateMinimalItem();
        Item.RESET();
        Item.SETFILTER("No.", ItemID);
        Item.FINDFIRST();
        Item.VALIDATE("Base Unit of Measure", UnitOfMeasure.Code);
        Item.MODIFY(TRUE);
        ItemGUID := Item.SystemId;
        Assert.AreNotEqual('', ItemGUID, 'ItemGUID should not be empty');

        COMMIT();

        // [GIVEN] a JSON text with an empty value
        ItemJSON := LibraryGraphMgt.AddComplexTypetoJSON(ItemJSON, 'baseUnitOfMeasure', '{}');

        // [WHEN] we PATCH the JSON to the web service, with the unique Item ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemGUID, PAGE::"APIV1 - Items", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the item shouldn't have a value in the table
        Item.GET(ItemID);
        Assert.AreEqual(Item."Base Unit of Measure", '', 'The item shouldn''t have a Base Unit Of Measure');
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
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
        COMMIT();

        // [GIVEN] the item's unique GUID
        Item.RESET();
        Item.SETFILTER("No.", ItemID);
        Item.FINDFIRST();
        ItemGUID := Item.SystemId;
        Assert.AreNotEqual('', ItemGUID, 'ItemGUID should not be empty');

        // [WHEN] we DELETE the item from the web service, with the item's unique ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemGUID, PAGE::"APIV1 - Items", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the item shouldn't exist in the table
        Item.Reset();
        Item.SetRange("No.", ItemID);
        Assert.IsTrue(Item.IsEmpty(), 'Item should not exist');
    end;

    [Test]
    procedure TestPostItemWithUoMIdCreatesItemUoM()
    var
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ItemJSON: Text;
        ItemNo: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO 233459] Create an item through a POST method and check if the Item Unit Of Measure is created
        Initialize();

        // [GIVEN] a unit of measure
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] a JSON text with an item number and the UoM id
        ItemJSON := CreateMinimalItemJSON(ItemNo);
        ItemJSON := LibraryGraphMgt.AddPropertytoJSON(ItemJSON, UoMIdTxt, UnitOfMeasure.SystemId);

        COMMIT();

        // [WHEN] the JSON is posted to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Items", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the corresponding record is created in table Item Unit of Measure
        ItemUnitOfMeasure.SetRange("Item No.", ItemNo);
        ItemUnitOfMeasure.SetRange(Code, UnitOfMeasure.Code);
        Assert.IsFalse(ItemUnitOfMeasure.IsEmpty(), 'Cannot find Item Unit of Measure.');
    end;

    [Test]
    procedure TestPatchItemWithUoMIdCreatesItemUoM()
    var
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        Item: Record "Item";
        ItemJSON: Text;
        ItemNo: Text;
        ResponseText: Text;
        TargetURL: Text;
        ItemId: Text;
    begin
        // [SCENARIO 233459] Update an item through a PATCH method and check if the Item Unit Of Measure is created
        Initialize();

        // [GIVEN] an item
        ItemNo := CreateSimpleItem();
        Item.GET(ItemNo);
        ItemId := Item.SystemId;

        // [GIVEN] a unit of measure
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] a JSON text with the UoM id
        ItemJSON := LibraryGraphMgt.AddPropertytoJSON('', UoMIdTxt, UnitOfMeasure.SystemId);

        COMMIT();

        // [WHEN] the JSON is posted to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemId, PAGE::"APIV1 - Items", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the corresponding record is created in table Item Unit of Measure
        ItemUnitOfMeasure.SetRange("Item No.", ItemNo);
        ItemUnitOfMeasure.SetRange(Code, UnitOfMeasure.Code);
        Assert.IsFalse(ItemUnitOfMeasure.IsEmpty(), 'Cannot find Item Unit of Measure.');
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
        Item.GET(ItemNo);
        ItemID := Item.SystemId;

        LibraryInventory.CreateItemCategory(ItemCategory);

        ItemJSON := LibraryGraphMgt.AddPropertytoJSON('', 'itemCategoryCode', ItemCategory.Code);

        COMMIT();
        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemID, PAGE::"APIV1 - Items", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemJSON, ResponseText);

        Item.GET(ItemNo);
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
        Item.GET(ItemNo);
        ItemID := Item.SystemId;

        LibraryInventory.CreateItemCategory(ItemCategory);

        ItemJSON := LibraryGraphMgt.AddPropertytoJSON('', 'itemCategoryId', ItemCategory.SystemId);

        COMMIT();
        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemID, PAGE::"APIV1 - Items", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemJSON, ResponseText);

        Item.GET(ItemNo);
        Assert.AreEqual(FORMAT(ItemCategory.Code), Item."Item Category Code", 'Item category code is wrong');
    end;

    [Test]
    procedure TestPostItemWithUoMComplexTypeCreatesItemUoM()
    var
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ItemJSON: Text;
        ItemNo: Text;
        ResponseText: Text;
        TargetURL: Text;
        UoMJSON: Text;
    begin
        // [SCENARIO 233459] Create an item through a POST method and check if the Item Unit Of Measure is created
        Initialize();

        // [GIVEN] a unit of measure
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] a JSON text with the UoM complex type
        UoMJSON := GetUoMJSON(UnitOfMeasure);
        ItemJSON := CreateMinimalItemJSON(ItemNo);
        ItemJSON := LibraryGraphMgt.AddComplexTypetoJSON(ItemJSON, 'baseUnitOfMeasure', UoMJSON);

        COMMIT();

        // [WHEN] the JSON is posted to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Items", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the corresponding record is created in table Item Unit of Measure
        ItemUnitOfMeasure.SetRange("Item No.", ItemNo);
        ItemUnitOfMeasure.SetRange(Code, UnitOfMeasure.Code);
        Assert.IsFalse(ItemUnitOfMeasure.IsEmpty(), 'Cannot find Item Unit of Measure.');
    end;

    [Test]
    procedure TestPatchItemWithUoMComplexTypeCreatesItemUoM()
    var
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        Item: Record "Item";
        ItemJSON: Text;
        ItemNo: Text;
        ResponseText: Text;
        TargetURL: Text;
        ItemId: Text;
        UoMJSON: Text;
    begin
        // [SCENARIO 233459] Update an item through a PATCH method and check if the Item Unit Of Measure is created
        Initialize();

        // [GIVEN] an item
        ItemNo := CreateSimpleItem();
        Item.GET(ItemNo);
        ItemId := Item.SystemId;

        // [GIVEN] a unit of measure
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] a JSON text with the UoM complex type
        UoMJSON := GetUoMJSON(UnitOfMeasure);
        ItemJSON := LibraryGraphMgt.AddComplexTypetoJSON(ItemJSON, 'baseUnitOfMeasure', UoMJSON);

        COMMIT();

        // [WHEN] the JSON is posted to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemId, PAGE::"APIV1 - Items", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemJSON, ResponseText);

        // [THEN] the corresponding record is created in table Item Unit of Measure
        ItemUnitOfMeasure.SetRange("Item No.", ItemNo);
        ItemUnitOfMeasure.SetRange(Code, UnitOfMeasure.Code);
        Assert.IsFalse(ItemUnitOfMeasure.IsEmpty(), 'Cannot find Item Unit of Measure.');
    end;

    [Test]
    procedure TestUoMSync()
    var
        UnitOfMeasure: Record "Unit of Measure";
        UoMJSON: Text;
        ItemJSON: array[2] of Text;
        ItemID: array[2] of Text;
        ResponseText: array[2] of Text;
        TargetURL: Text;
    begin
        // [FEATURE] [Complex Type]
        // [SCENARIO] Create an item through a POST method and check if the Unit Of Measure Code and the Unit Of Measure Id Sync correctly
        // [GIVEN] a unit of measure
        Initialize();

        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        COMMIT();

        // [GIVEN] a JSON text with an Item that has the Unit of Measure as a property and the Id
        UoMJSON := GetUoMJSON(UnitOfMeasure);

        // [GIVEN] a JSON text with an item and the UoM complex type and id
        ItemJSON[1] := CreateMinimalItemJSON(ItemID[1]);
        ItemJSON[1] := LibraryGraphMgt.AddComplexTypetoJSON(ItemJSON[1], 'baseUnitOfMeasure', UoMJSON);
        ItemJSON[1] := LibraryGraphMgt.AddPropertytoJSON(ItemJSON[1], UoMIdTxt, UnitOfMeasure.SystemId);

        COMMIT();

        // [GIVEN] the first JSON is posted to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Items", '');
        LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON[1], ResponseText[1]);

        // [GIVEN] a JSON text with an item and the UoM id
        ItemJSON[2] := CreateMinimalItemJSON(ItemID[2]);
        ItemJSON[2] := LibraryGraphMgt.AddPropertytoJSON(ItemJSON[2], UoMIdTxt, UnitOfMeasure.SystemId);

        // [WHEN] we POST the second JSON to the web service
        LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON[2], ResponseText[2]);

        // [THEN] the response text should contain the unit of measure that also exists in the corresponding item table row
        Assert.AreNotEqual('', ResponseText[1], 'JSON Should not be blank');
        LibraryGraphMgt.VerifyUoMInJson(ResponseText[1], UnitOfMeasure.Code, ItemIdentifierTxt);
        Assert.AreNotEqual('', ResponseText[2], 'JSON Should not be blank');
        LibraryGraphMgt.VerifyUoMInJson(ResponseText[2], UnitOfMeasure.Code, ItemIdentifierTxt);
    end;

    [Test]
    procedure TestUoMSyncErrors()
    var
        UnitOfMeasure: array[3] of Record "Unit of Measure";
        UnitOfMeasureGUID: Guid;
        UoMJSON: Text;
        ItemJSON: array[2] of Text;
        ItemID: array[2] of Text;
        ResponseText: array[2] of Text;
        TargetURL: Text;
    begin
        // [FEATURE] [Complex Type]
        // [SCENARIO] Create an item through a POST method with unit of measure and id and check if the Sync throws the errors
        // [GIVEN] a unit of measure
        Initialize();

        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure[1]);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure[2]);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure[3]);
        UnitOfMeasureGUID := UnitOfMeasure[3].SystemId;
        UnitOfMeasure[3].DELETE();
        COMMIT();

        // [GIVEN] a JSON text with an Item that has the Unit of Measure as a property and the Id
        UoMJSON := GetUoMJSON(UnitOfMeasure[1]);

        // [GIVEN] a JSON text with an item and the UoM complex type and id
        ItemJSON[1] := CreateMinimalItemJSON(ItemID[1]);
        ItemJSON[1] := LibraryGraphMgt.AddComplexTypetoJSON(ItemJSON[1], 'baseUnitOfMeasure', UoMJSON);
        ItemJSON[1] := LibraryGraphMgt.AddPropertytoJSON(ItemJSON[1], UoMIdTxt, UnitOfMeasure[2].SystemId);

        COMMIT();

        // [GIVEN] the first JSON is posted to the web service with an error
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Items", '');
        ASSERTERROR LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON[1], ResponseText[1]);

        // [GIVEN] a JSON text with an item and the UoM id
        ItemJSON[2] := CreateMinimalItemJSON(ItemID[2]);
        ItemJSON[2] := LibraryGraphMgt.AddPropertytoJSON(ItemJSON[2], UoMIdTxt, UnitOfMeasure[3].SystemId);

        // [WHEN] we POST the second JSON to the web service
        // [THEN] the 2nd POST should throw an error as well
        ASSERTERROR LibraryGraphMgt.PostToWebService(TargetURL, ItemJSON[2], ResponseText[2]);
    end;

    local procedure CreateSimpleItem(): Code[20]
    var
        Item: Record "Item";
    begin
        Item.INIT();
        Item."No." := GetNextItemID();
        Item.INSERT(TRUE);
        EXIT(Item."No.");
    end;

    [Normal]
    local procedure CreateSampleTemplate(TableID: Integer; PageID: Integer)
    var
        ConfigTmplSelectionRules: Record "Config. Tmpl. Selection Rules";
        ConfigTemplateHeader: Record "Config. Template Header";
    begin
        ConfigTemplateHeader.SETRANGE(Code, SampleTempCodeTxt);
        IF ConfigTemplateHeader.FINDFIRST() THEN
            ConfigTemplateHeader.DELETE();

        ConfigTemplateHeader.INIT();
        ConfigTemplateHeader.Code := SampleTempCodeTxt;
        ConfigTemplateHeader."Table ID" := TableID;
        ConfigTemplateHeader.Enabled := TRUE;
        ConfigTemplateHeader.INSERT(TRUE);

        ConfigTmplSelectionRules.SETRANGE("Template Code", SampleTempCodeTxt);
        ConfigTmplSelectionRules.DELETEALL();

        ConfigTmplSelectionRules.INIT();
        ConfigTmplSelectionRules."Table ID" := ConfigTemplateHeader."Table ID";
        ConfigTmplSelectionRules."Page ID" := PageID;
        ConfigTmplSelectionRules."Template Code" := ConfigTemplateHeader.Code;
        ConfigTmplSelectionRules.INSERT(TRUE);

        COMMIT();
    end;

    local procedure CreateItemwithUoM(UnitOfMeasureCode: Code[10]): Code[20]
    var
        Item: Record "Item";
    begin
        Item.INIT();
        Item."No." := GetNextItemID();
        Item.INSERT(TRUE);
        Item.VALIDATE("Base Unit of Measure", UnitOfMeasureCode);
        Item.MODIFY(TRUE);
        EXIT(Item."No.");
    end;

    local procedure CreateMinimalItem(): Code[20]
    var
        Item: Record "Item";
    begin
        Item.INIT();
        Item."No." := GetNextItemID();
        Item.INSERT(TRUE);

        EXIT(Item."No.");
    end;

    local procedure CreateTemplateSelectionRulewithUoM(ItemCategoryCodeFieldNo: Integer; ItemCategoryCodeValue: Text; UomValue: Text; var ConfigTmplSelectionRules: Record "Config. Tmpl. Selection Rules")
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
        Item: Record "Item";
    begin
        LibraryRapidStart.CreateConfigTemplateHeader(ConfigTemplateHeader);
        ConfigTemplateHeader."Table ID" := DATABASE::Item;
        ConfigTemplateHeader.MODIFY();

        LibraryRapidStart.CreateConfigTemplateLine(ConfigTemplateLine, ConfigTemplateHeader.Code);
        ConfigTemplateLine."Field ID" := ItemCategoryCodeFieldNo;
        ConfigTemplateLine."Default Value" := COPYSTR(ItemCategoryCodeValue, 1, MAXSTRLEN(ConfigTemplateLine."Default Value"));
        ConfigTemplateLine.MODIFY(TRUE);

        LibraryRapidStart.CreateConfigTemplateLine(ConfigTemplateLine, ConfigTemplateHeader.Code);
        ConfigTemplateLine."Field ID" := Item.FIELDNO("Base Unit of Measure");
        ConfigTemplateLine."Default Value" := COPYSTR(UomValue, 1, MAXSTRLEN(ConfigTemplateLine."Default Value"));
        ConfigTemplateLine.MODIFY(TRUE);

        ConfigTmplSelectionRules.SETRANGE("Table ID", DATABASE::Item);
        ConfigTmplSelectionRules.DELETEALL();
        ConfigTmplSelectionRules.RESET();

        LibraryRapidStart.CreateTemplateSelectionRule(
          ConfigTmplSelectionRules, ItemCategoryCodeFieldNo, ItemCategoryCodeValue, 1, PAGE::"APIV1 - Items", ConfigTemplateHeader);
    end;

    local procedure CreateMinimalItemJSON(var ItemID: Text): Text
    var
        ItemJson: Text;
    begin
        ItemID := GetNextItemID();
        ItemJson := LibraryGraphMgt.AddPropertytoJSON('', ItemIdentifierTxt, ItemID);

        EXIT(ItemJson);
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
        Item.SETFILTER("No.", STRSUBSTNO('%1*', ItemKeyPrefixTxt));
        IF Item.FINDLAST() THEN
            EXIT(INCSTR(Item."No."));

        EXIT(COPYSTR(ItemKeyPrefixTxt + '00001', 1, 20));
    end;

    local procedure GetUoMJSON(var UnitOfMeasure: Record "Unit of Measure"): Text
    var
        UoMJSON: Text;
    begin
        UoMJSON := LibraryGraphMgt.AddPropertytoJSON('{}', GraphCollectionMgtItem.UOMComplexTypeUnitCode(), UnitOfMeasure.Code);
        UoMJSON := LibraryGraphMgt.AddPropertytoJSON(UoMJSON, GraphCollectionMgtItem.UOMComplexTypeUnitName(), UnitOfMeasure.Description);
        UoMJSON := LibraryGraphMgt.AddPropertytoJSON(UoMJSON, GraphCollectionMgtItem.UOMComplexTypeSymbol(), UnitOfMeasure.Symbol);
        EXIT(UoMJSON);
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





























































