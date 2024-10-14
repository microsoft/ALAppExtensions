codeunit 139617 "Shpfy Company Metafields Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Shop: Record "Shpfy Shop";
        ShpfyCompany: Record "Shpfy Company";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        LibraryAssert: Codeunit "Library Assert";
        Any: Codeunit Any;
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        IsInitialized := false;
    end;

    [Test]
    procedure UnitTestGetMetafieldOwnerTypeFromCompanyMetafield()
    var
        ShpfyMetafield: Record "Shpfy Metafield";
        ShpfyMetafieldsHelper: Codeunit "Shpfy Metafields Helper";
        ShpfyMetafieldOwnerType: Enum "Shpfy Metafield Owner Type";
    begin
        // [SCENARIO] Get Metafield Owner Type from Company Metafield.

        // [GIVEN] Shopify Metafield created for Company.
        ShpfyMetafieldsHelper.CreateMetafield(ShpfyMetafield, Database::"Shpfy Company", Any.IntegerInRange(10000, 99999));

        // [WHEN] Invoke Metafield.GetOwnerType();
        ShpfyMetafieldOwnerType := ShpfyMetafield.GetOwnerType(Database::"Shpfy Company");

        // [THEN] ShpfyMetafieldOwnerType = Enum::"Shpfy Metafield Owner Type"::Company;
        LibraryAssert.AreEqual(ShpfyMetafieldOwnerType, Enum::"Shpfy Metafield Owner Type"::Company, 'Metafield Owner Type is different than Company');
    end;

    [Test]
    procedure UnitTestGetMetafieldOwnerTableId()
    var
        ShpfyMetafield: Record "Shpfy Metafield";
        ShpfyMetafieldsHelper: Codeunit "Shpfy Metafields Helper";
        IMetafieldOwnerType: Interface "Shpfy IMetafield Owner Type";
        TableId: Integer;
    begin
        // [SCENARIO] Get Metafield Owner Values from Metafield Owner Company codeunit
        Initialize();

        // [GIVEN] Shopify Metafield created for Company.
        ShpfyMetafieldsHelper.CreateMetafield(ShpfyMetafield, Any.IntegerInRange(100000, 99999), Database::"Shpfy Company");
        // [GIVEN] IMetafieldOwnerType
        IMetafieldOwnerType := ShpfyMetafield.GetOwnerType(Database::"Shpfy Company");

        // [WHEN] Invoke IMetafieldOwnerType.GetTableId
        TableId := IMetafieldOwnerType.GetTableId();

        // [THEN] TableId = Database::"Shpfy Company";
        LibraryAssert.AreEqual(TableId, Database::"Shpfy Company", 'Table Id is different than Company');
    end;

    [Test]
    procedure UnitTestImportCompanyMetafieldFromShopify()
    var
        ShpfyMetafield: Record "Shpfy Metafield";
        MetafieldAPI: Codeunit "Shpfy Metafield API";
        MetafieldId: BigInteger;
        Namespace: Text;
        MetafieldKey: Text;
        MetafieldValue: Text;
        JMetafields: JsonArray;
    begin
        // [SCENARIO] Import Metafield from Shopify to Business Central
        Initialize();

        // [GIVEN] Response Json with metafield
        JMetafields := CreateCompanyMetafieldsResponse(MetafieldId, Namespace, MetafieldKey, MetafieldValue);

        // [WHEN] Invoke MetafieldAPI.UpdateMetafieldsFromShopify
        MetafieldAPI.UpdateMetafieldsFromShopify(JMetafields, Database::"Shpfy Company", ShpfyCompany.Id);

        // [THEN] Metafield with MetafieldId, Namespace, MetafieldKey, MetafieldValue is imported to Business Central
        ShpfyMetafield.Reset();
        ShpfyMetafield.SetRange("Owner Id", ShpfyCompany.Id);
        ShpfyMetafield.SetRange("Parent Table No.", Database::"Shpfy Company");

        LibraryAssert.IsTrue(ShpfyMetafield.FindFirst(), 'Metafield is not imported to Business Central');

        LibraryAssert.AreEqual(ShpfyMetafield.Id, MetafieldId, 'Metafield Id is different than imported');
        LibraryAssert.AreEqual(ShpfyMetafield.Namespace, Namespace, 'Namespace is different than imported');
        LibraryAssert.AreEqual(ShpfyMetafield.Name, MetafieldKey, 'Metafield Key is different than imported');
        LibraryAssert.AreEqual(ShpfyMetafield.Value, MetafieldValue, 'Metafield Value is different than imported');
    end;

    [Test]
    procedure UnitTestUpdateRemovedCompanyMetafieldFromShopify()
    var
        ShpfyMetafield: Record "Shpfy Metafield";
        MetafieldAPI: Codeunit "Shpfy Metafield API";
        ShpfyMetafieldsHelper: Codeunit "Shpfy Metafields Helper";
        MetafieldId: BigInteger;
        JMetafields: JsonArray;
    begin
        // [SCENARIO] Update Removed Metafield from Shopify to Business Central
        Initialize();

        // [GIVEN] Shopify Metafield created for Company.
        MetafieldId := ShpfyMetafieldsHelper.CreateMetafield(ShpfyMetafield, ShpfyCompany.Id, Database::"Shpfy Company");

        // [WHEN] Invoke MetafieldAPI.UpdateMetafieldsFromShopify with empty JMetafields
        MetafieldAPI.UpdateMetafieldsFromShopify(JMetafields, Database::"Shpfy Company", ShpfyCompany.Id);

        // [THEN] Metafield is removed from Business Central
        ShpfyMetafield.Reset();
        ShpfyMetafield.SetRange(Id, MetafieldId);
        ShpfyMetafield.SetRange("Owner Id", ShpfyCompany.Id);
        ShpfyMetafield.SetRange("Parent Table No.", Database::"Shpfy Company");
        LibraryAssert.IsTrue(ShpfyMetafield.IsEmpty(), 'Metafield is not removed from Business Central');
    end;

    [Test]
    procedure UnitTestUpdateCompanyMetafieldFromShopify()
    var
        ShpfyMetafield: Record "Shpfy Metafield";
        ShpfyMetafieldsHelper: Codeunit "Shpfy Metafields Helper";
        MetafieldAPI: Codeunit "Shpfy Metafield API";
        MetafieldId: BigInteger;
        Namespace: Text;
        MetafieldKey: Text;
        MetafieldValue: Text;
        JMetafields: JsonArray;
    begin
        // [SCENARIO] Update Metafield from Shopify to Business Central
        Initialize();

        // [GIVEN] Shopify Metafield with values created for Company.
        Namespace := Any.AlphabeticText(10);
        MetafieldKey := Any.AlphabeticText(10);
        MetafieldValue := Any.AlphabeticText(10);
        MetafieldId := ShpfyMetafieldsHelper.CreateMetafield(ShpfyMetafield, ShpfyCompany.Id, Database::"Shpfy Company", Namespace, MetafieldKey, MetafieldValue);
        // [GIVEN] Response Json with metafield updated value
        JMetafields := ShpfyMetafieldsHelper.CreateMetafieldsResult(MetafieldId, Namespace, 'COMPANY', MetafieldKey, Any.AlphabeticText(10));

        // [WHEN] Invoke MetafieldAPI.UpdateMetafieldsFromShopify
        MetafieldAPI.UpdateMetafieldsFromShopify(JMetafields, Database::"Shpfy Company", ShpfyCompany.Id);

        // [THEN] Metafield with MetafieldId, Namespace, MetafieldKey, MetafieldValue is updated in Business Central
        ShpfyMetafield.Reset();
        ShpfyMetafield.SetRange(Id, MetafieldId);
        ShpfyMetafield.SetRange("Owner Id", ShpfyCompany.Id);
        ShpfyMetafield.SetRange("Parent Table No.", Database::"Shpfy Company");
        LibraryAssert.IsTrue(ShpfyMetafield.FindFirst(), 'Metafield is not updated in Business Central');
        LibraryAssert.AreEqual(ShpfyMetafield.Id, MetafieldId, 'Metafield Id is different than updated');
        LibraryAssert.AreEqual(ShpfyMetafield.Namespace, Namespace, 'Namespace is different than updated');
        LibraryAssert.AreEqual(ShpfyMetafield.Name, MetafieldKey, 'Metafield Key is different than updated');
        LibraryAssert.AreNotEqual(ShpfyMetafield.Value, MetafieldValue, 'Metafield Value is different than updated');
    end;

    local procedure Initialize()
    begin
        Any.SetDefaultSeed();

        if IsInitialized then
            exit;
        Shop := ShpfyInitializeTest.CreateShop();
        CreateShopifyCompany(ShpfyCompany, Shop."Shop Id", Shop.Code);

        Commit();

        IsInitialized := true;
    end;

    local procedure CreateCompanyMetafieldsResponse(var MetafieldId: BigInteger; var Namespace: Text; var MetafieldKey: Text; var MetafieldValue: Text): JsonArray
    var
        ShpfyMetafieldsHelper: Codeunit "Shpfy Metafields Helper";
    begin
        MetafieldId := Any.IntegerInRange(100000, 999999);
        Namespace := Any.AlphabeticText(10);
        MetafieldKey := Any.AlphabeticText(10);
        MetafieldValue := Any.AlphabeticText(10);
        exit(ShpfyMetafieldsHelper.CreateMetafieldsResult(MetafieldId, Namespace, 'COMPANY', MetafieldKey, MetafieldValue));
    end;

    local procedure CreateShopifyCompany(var ShopifyCompany: Record "Shpfy Company"; ShopId: BigInteger; ShopCode: Code[20])
    begin
        ShopifyCompany.Init();
        ShopifyCompany."Shop Id" := ShopId;
        ShopifyCompany."Shop Code" := ShopCode;
        ShopifyCompany.Name := Any.AlphabeticText(10);
        ShopifyCompany.Insert(false);
    end;
}
