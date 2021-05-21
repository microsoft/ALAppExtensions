codeunit 139839 "APIV2 - Item Variants E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Item] [Variant]
    end;

    [Test]
    procedure TestCreateItemVariantWithItemId()
    var
        Item: Record Item;
        ItemVariantCode: Text;
        ItemVariantJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create an item variant through a POST method and check if it was created
        // [GIVEN] a JSON text with an item variant with itemId
        CreateItem(Item);
        Commit();
        ItemVariantJSON := CreateItemVariantJsonWithItemId(Item.SystemId, ItemVariantCode);

        // [WHEN] POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Item Variants", '');
        LibraryGraphMgt.PostToWebService(TargetURL, ItemVariantJSON, ResponseText);

        // [THEN] the response text should contain the item variant information
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        VerifyItemVariantInJson(ResponseText, ItemVariantCode, Item."No.", Item.SystemId);
    end;

    [Test]
    procedure TestCreateItemVariantWithNonExistingItemId()
    var
        ItemId: Text;
        ItemVariantCode: Text;
        ItemVariantJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Cannot create an Item Variant with non-existing itemId
        // [GIVEN] a JSON text with an item variant with non-existing itemId
        ItemId := CreateGuid();
        ItemVariantJSON := CreateItemVariantJsonWithItemId(ItemId, ItemVariantCode);

        // [WHEN] POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Item Variants", '');

        // [THEN] the request should fail
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, ItemVariantJSON, ResponseText);
    end;

    [Test]
    procedure TestCreateItemVariantWithItemNumber()
    var
        Item: Record Item;
        ItemVariantCode: Text;
        ItemVariantJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create an item variant through a POST method and check if it was created
        // [GIVEN] a JSON text with an item variant with itemNumber
        CreateItem(Item);
        Commit();
        ItemVariantJSON := CreateItemVariantJsonWithItemNo(Item."No.", ItemVariantCode);

        // [WHEN] POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Item Variants", '');
        LibraryGraphMgt.PostToWebService(TargetURL, ItemVariantJSON, ResponseText);

        // [THEN] the response text should contain the item variant information
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        VerifyItemVariantInJson(ResponseText, ItemVariantCode, Item."No.", Item.SystemId);
    end;

    [Test]
    procedure TestCreateItemVariantWithNonExistingItemNumber()
    var
        ItemVariant: Record "Item Variant";
        ItemNo: Text;
        ItemVariantCode: Text;
        ItemVariantJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Cannot create an Item Variant with non-existing itemNumber
        // [GIVEN] a JSON text with an item variant with non-existing itemNumber
        ItemNo := LibraryUtility.GenerateRandomCode(ItemVariant.FieldNo(Code), Database::"Item Variant");
        ItemVariantJSON := CreateItemVariantJsonWithItemNo(ItemNo, ItemVariantCode);

        // [WHEN] POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Item Variants", '');

        // [THEN] the request should fail
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, ItemVariantJSON, ResponseText);
    end;

    [Test]
    procedure TestCreateItemVariantWithItemNumberAndItemId()
    var
        Item: Record Item;
        ItemVariantCode: Text;
        ItemVariantJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create an item variant through a POST method and check if it was created
        // [GIVEN] a JSON text with an item variant with itemNumber and itemId
        CreateItem(Item);
        Commit();
        ItemVariantJSON := CreateItemVariantJsonWithItemNoAndItemId(Item."No.", Item.SystemId, ItemVariantCode);

        // [WHEN] POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Item Variants", '');
        LibraryGraphMgt.PostToWebService(TargetURL, ItemVariantJSON, ResponseText);

        // [THEN] the response text should contain the item variant information
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        VerifyItemVariantInJson(ResponseText, ItemVariantCode, Item."No.", Item.SystemId);
    end;

    [Test]
    procedure TestCreateItemVariantWithMismatchingItemNumberAndItemId()
    var
        Item1: Record Item;
        Item2: Record Item;
        ItemVariantCode: Text;
        ItemVariantJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Cannot create an Item Variant with mismatching itemNumber and itemId
        // [GIVEN] a JSON text with an item variant with mismatching itemNumber and itemId
        CreateItem(Item1);
        CreateItem(Item2);
        Commit();
        ItemVariantJSON := CreateItemVariantJsonWithItemNoAndItemId(Item1."No.", item2.SystemId, ItemVariantCode);

        // [WHEN] POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Item Variants", '');

        // [THEN] the request should fail
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, ItemVariantJSON, ResponseText);
    end;

    [Test]
    procedure TestCreateItemVariantWithExistingItemNumberAndCode()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemVariantJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Cannot create an Item Variant if there is an item variant with same itemNumber and code
        // [GIVEN] a JSON text with an item variant with same itemNumber and code
        CreateItem(Item);
        LibraryInventory.CreateItemVariant(ItemVariant, Item."No.");
        Commit();
        ItemVariantJSON := CreateItemVariantJsonWithItemNoAndCode(Item."No.", ItemVariant.Code);

        // [WHEN] POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Item Variants", '');

        // [THEN] the request should fail
        asserterror LibraryGraphMgt.PostToWebService(TargetURL, ItemVariantJSON, ResponseText);
    end;

    [Test]
    procedure TestGetItemVariant()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Get a simple customer with a GET request to the service.
        // [GIVEN] An item variant exists in the system
        CreateItem(Item);
        LibraryInventory.CreateItemVariant(ItemVariant, Item."No.");
        Commit();

        // [WHEN] GET request for a given Item Variant
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemVariant.SystemId, Page::"APIV2 - Item Variants", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the response text should contain the item variant information
        VerifyItemVariantInJson(ResponseText, ItemVariant.Code, ItemVariant."Item No.", ItemVariant."Item Id");
    end;

    [Test]
    procedure TestModifyItemVariant()
    var
        Item: Record "Item";
        ItemVariant: Record "Item Variant";
        PropertyName: Text;
        PropertyValue: Text;
        ItemVariantJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create an item variant, use a PATCH method to change it and then verify the changes
        // [GIVEN] an item variant exists in the system
        CreateItem(Item);
        LibraryInventory.CreateItemVariant(ItemVariant, Item."No.");
        Commit();

        // [GIVEN] a JSON text with a description property and random value
        PropertyName := 'description';
        PropertyValue := LibraryRandom.RandText(50);
        ItemVariantJSON := LibraryGraphMgt.AddPropertytoJSON('', PropertyName, PropertyValue);

        // [WHEN] PATCH the JSON to the web service, with the unique ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemVariant.SystemId, Page::"APIV2 - Item Variants", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemVariantJSON, ResponseText);

        // [THEN] the item variant in the table should have the description that was given
        ItemVariant.GetBySystemId(ItemVariant.SystemId);
        Assert.AreEqual(ItemVariant.Description, PropertyValue, 'Item variant property value should be changed');
    end;

    [Test]
    procedure TestModifyItemVariantItemId()
    var
        Item1: Record "Item";
        Item2: Record "Item";
        ItemVariant: Record "Item Variant";
        PropertyName: Text;
        PropertyValue: Text;
        ItemVariantJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create an item variant, use a PATCH method to change it and then verify the changes
        // [GIVEN] an item variant exists in the system
        CreateItem(Item1);
        CreateItem(Item2);
        LibraryInventory.CreateItemVariant(ItemVariant, Item1."No.");
        Commit();

        // [GIVEN] a JSON text with a itemId property and a value
        PropertyName := 'itemId';
        PropertyValue := Item2.SystemId;
        ItemVariantJSON := LibraryGraphMgt.AddPropertytoJSON('', PropertyName, PropertyValue);

        // [WHEN] PATCH the JSON to the web service, with the unique ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemVariant.SystemId, Page::"APIV2 - Item Variants", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemVariantJSON, ResponseText);

        // [THEN] the item variant in the table should have the item id that was given
        ItemVariant.GetBySystemId(ItemVariant.SystemId);
        Assert.AreEqual(Format(ItemVariant."Item Id"), PropertyValue, 'Item variant property value should be changed');
    end;

    [Test]
    procedure TestModifyItemVariantItemNumber()
    var
        Item1: Record "Item";
        Item2: Record "Item";
        ItemVariant: Record "Item Variant";
        PropertyName: Text;
        PropertyValue: Text;
        ItemVariantJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create an item variant, use a PATCH method to change it and then verify the changes
        // [GIVEN] an item variant exists in the system
        CreateItem(Item1);
        CreateItem(Item2);
        LibraryInventory.CreateItemVariant(ItemVariant, Item1."No.");
        Commit();

        // [GIVEN] a JSON text with a itemNumber property and a value
        PropertyName := 'itemNumber';
        PropertyValue := Item2."No.";
        ItemVariantJSON := LibraryGraphMgt.AddPropertytoJSON('', PropertyName, PropertyValue);

        // [WHEN] PATCH the JSON to the web service, with the unique ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemVariant.SystemId, Page::"APIV2 - Item Variants", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, ItemVariantJSON, ResponseText);

        // [THEN] the item variant in the table should have the item number that was given
        ItemVariant.GetBySystemId(ItemVariant.SystemId);
        Assert.AreEqual(ItemVariant."Item No.", PropertyValue, 'Item variant property value should be changed');
    end;

    [Test]
    procedure TestDeleteItemVariant()
    var
        Item: Record "Item";
        ItemVariant: Record "Item Variant";
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create an item variant, use a DELETE method to remove it and then verify the deletion
        // [GIVEN] an item variant in the system
        CreateItem(Item);
        LibraryInventory.CreateItemVariant(ItemVariant, Item."No.");
        Commit();

        // [WHEN] we DELETE the item variant from the web service, with the item variant's unique ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemVariant.SystemId, Page::"APIV2 - Item Variants", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the item varint shouldn't exist in the table
        ItemVariant.Reset();
        ItemVariant.SetRange(Code, ItemVariant.Code);
        ItemVariant.SetRange("Item No.", Item."No.");
        Assert.IsTrue(ItemVariant.IsEmpty(), 'Item variant should not exist');
    end;

    [Test]
    procedure TestDeleteInUse()
    var
        Item: Record "Item";
        ItemVariant: Record "Item Variant";
        SalesHeader: Record "Sales Header";
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Cannot delete an item variant in use
        // [GIVEN] an item variant in the system and used in a sales order line
        LibraryInventory.CreateItem(Item);
        LibraryInventory.CreateItemVariant(ItemVariant, Item."No.");
        CreateSalesOrderAndLineWithVariant(SalesHeader, Item, ItemVariant);
        Commit();

        // [WHEN] we DELETE the item variant from the web service, with the item's unique ID
        TargetURL := LibraryGraphMgt.CreateTargetURL(ItemVariant.SystemId, Page::"APIV2 - Item Variants", ServiceNameTxt);

        // [THEN] the request should fail
        asserterror LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);
    end;

    var
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        Assert: Codeunit "Assert";
        ServiceNameTxt: Label 'itemVariants';


    local procedure CreateItem(var Item: Record Item)
    begin
        Item.Init();
        Item."No." := GetNextItemNo();
        Item.Insert(true);
    end;

    local procedure CreateItemVariantJsonWithItemId(ItemId: Text; var ItemVariantCode: Text): Text
    var
        ItemVariant: Record "Item Variant";
        ItemVariantJson: Text;
    begin
        ItemVariantCode := LibraryUtility.GenerateRandomCode(ItemVariant.FieldNo(Code), Database::"Item Variant");
        ItemVariantJson := LibraryGraphMgt.AddPropertytoJSON('', 'code', ItemVariantCode);
        ItemVariantJson := LibraryGraphMgt.AddPropertytoJSON(ItemVariantJson, 'itemId', ItemId);
        exit(ItemVariantJson);
    end;

    local procedure CreateItemVariantJsonWithItemNo(ItemNo: Text; var ItemVariantCode: Text): Text
    var
        ItemVariant: Record "Item Variant";
        ItemVariantJson: Text;
    begin
        ItemVariantCode := LibraryUtility.GenerateRandomCode(ItemVariant.FieldNo(Code), Database::"Item Variant");
        ItemVariantJson := LibraryGraphMgt.AddPropertytoJSON('', 'code', ItemVariantCode);
        ItemVariantJson := LibraryGraphMgt.AddPropertytoJSON(ItemVariantJson, 'itemNumber', ItemNo);
        exit(ItemVariantJson);
    end;

    local procedure CreateItemVariantJsonWithItemNoAndItemId(ItemNo: Text; ItemId: Text; var ItemVariantCode: Text): Text
    var
        ItemVariant: Record "Item Variant";
        ItemVariantJson: Text;
    begin
        ItemVariantCode := LibraryUtility.GenerateRandomCode(ItemVariant.FieldNo(Code), Database::"Item Variant");
        ItemVariantJson := LibraryGraphMgt.AddPropertytoJSON('', 'code', ItemVariantCode);
        ItemVariantJson := LibraryGraphMgt.AddPropertytoJSON(ItemVariantJson, 'itemNumber', ItemNo);
        ItemVariantJson := LibraryGraphMgt.AddPropertytoJSON(ItemVariantJson, 'itemId', ItemId);
        exit(ItemVariantJson);
    end;

    local procedure CreateItemVariantJsonWithItemNoAndCode(ItemNo: Text; ItemVariantCode: Text): Text
    var
        ItemVariantJson: Text;
    begin
        ItemVariantJson := LibraryGraphMgt.AddPropertytoJSON('', 'code', ItemVariantCode);
        ItemVariantJson := LibraryGraphMgt.AddPropertytoJSON(ItemVariantJson, 'itemNumber', ItemNo);
        exit(ItemVariantJson);
    end;

    local procedure VerifyItemVariantInJson(JsonTxt: Text; ExpectedCode: Text; ExpectedItemNo: Text; ExpectedItemId: Text)
    var
        ItemVariant: Record "Item Variant";
        IntegrationManagement: Codeunit "Integration Management";
        ItemVariantCode: Text;
        ItemNo: Text;
        ItemId: Text;
    begin
        ExpectedItemId := LowerCase(IntegrationManagement.GetIdWithoutBrackets(ExpectedItemId));
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(JsonTxt, 'code', ItemVariantCode), 'Could not find code');
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(JsonTxt, 'itemNumber', ItemNo), 'Could not find itemNumber');
        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(JsonTxt, 'itemId', ItemId), 'Could not find itemId');
        Assert.AreEqual(ExpectedCode, ItemVariantCode, 'code does not match');
        Assert.AreEqual(ExpectedItemNo, ItemNo, 'itemNumber does not match');
        Assert.AreEqual(ExpectedItemId, ItemId, 'itemId does not match');
        ItemVariant.SetRange(Code, ItemVariantCode);
        ItemVariant.SetRange("Item No.", ItemNo);
        ItemVariant.SetRange("Item Id", ItemId);
        Assert.IsFalse(ItemVariant.IsEmpty(), 'Item Variant does not exist');
    end;

    local procedure CreateSalesOrderAndLineWithVariant(var SalesHeader: Record "Sales Header"; Item: Record Item; ItemVariant: Record "Item Variant")
    var
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateSalesOrder(SalesHeader);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 2);
        SalesLine."Variant Code" := ItemVariant.Code;
        SalesLine.Modify();
    end;

    local procedure GetNextItemNo(): Text[20]
    var
        Item: Record "Item";
    begin
        Item.SetFilter("No.", StrSubstNo('%1*', 'GRAPHITEM'));
        if Item.FindLast() then
            exit(IncStr(Item."No."));

        exit(CopyStr('GRAPHITEM' + '00001', 1, 20));
    end;
}