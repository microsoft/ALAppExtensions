codeunit 139616 "Shpfy Customer Metafields Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Shop: Record "Shpfy Shop";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        LibraryAssert: Codeunit "Library Assert";
        Any: Codeunit Any;

        IsInitialized: Boolean;

    trigger OnRun()
    begin
        IsInitialized := false;
    end;

    [Test]
    procedure UnitTestGetMetafieldOwnerTypeFromCustomerMetafield()
    var
        ShpfyMetafield: Record "Shpfy Metafield";
        ShpfyMetafieldOwnerType: Enum "Shpfy Metafield Owner Type";
    begin
        // [SCENARIO] Get Metafield Owner Type from Customer Metafield.

        // [GIVEN] Shopify Metafield created for Customer.
        CreateShopifyMetafield(ShpfyMetafield, Database::"Shpfy Customer", Any.IntegerInRange(10000, 99999));

        // [WHEN] Invoke Metafield.GetOwnerType();
        ShpfyMetafieldOwnerType := ShpfyMetafield.GetOwnerType(Database::"Shpfy Customer");

        // [THEN] ShpfyMetafieldOwnerType = Enum::"Shpfy Metafield Owner Type"::Customer;
        LibraryAssert.AreEqual(ShpfyMetafieldOwnerType, Enum::"Shpfy Metafield Owner Type"::Customer, 'Metafield Owner Type is different than Customer');
    end;

    [Test]
    procedure UnitTestGetMetafieldOwnerValuesFromMetafieldOwnerCustomer()
    var
        ShpfyMetafield: Record "Shpfy Metafield";
        IMetagieldOwnerType: Interface "Shpfy IMetafield Owner Type";
        TableId: Integer;
    begin
        // [SCENARIO] Get Metafield Owner Values from Metafield Owner Company codeunit
        Initialize();

        // [GIVEN] Shopify Metafield created for Customer.
        CreateMetafield(ShpfyMetafield, Any.IntegerInRange(100000, 99999), Database::"Shpfy Customer");
        // [GIVEN] IMetafieldOwnerType
        IMetagieldOwnerType := ShpfyMetafield.GetOwnerType(Database::"Shpfy Customer");

        // [WHEN] Invoke IMetafieldOwnerType.GetTableId
        TableId := IMetagieldOwnerType.GetTableId();

        // [THEN] TableId = Database::"Shpfy Customer";
        LibraryAssert.AreEqual(TableId, Database::"Shpfy Customer", 'Table Id is different than Customer');
    end;

    [Test]
    procedure UnitTestGetShopCodeFromMetafieldOwnerCustomer()
    var
        ShpfyMetafield: Record "Shpfy Metafield";
        ShpfyCustomer: Record "Shpfy Customer";
        IMetagieldOwnerType: Interface "Shpfy IMetafield Owner Type";
        ShopCode: Code[20];
    begin
        // [SCENARIO] Get Shop Code from Metafield Owner Customer codeunit
        Initialize();

        // [GIVEN] Shopify Customer
        CreateShopifyCustomer(ShpfyCustomer, Shop."Shop Id");
        // [GIVEN] Shopify Metafield created for Customer.
        CreateMetafield(ShpfyMetafield, Any.IntegerInRange(100000, 99999), Database::"Shpfy Customer");
        // [GIVEN] IMetafieldOwnerType
        IMetagieldOwnerType := ShpfyMetafield.GetOwnerType(Database::"Shpfy Customer");

        // [WHEN] Invoke IMetafieldOwnerType.GetShopCode
        ShopCode := IMetagieldOwnerType.GetShopCode(ShpfyMetafield."Owner Id");

        // [THEN] ShopCode = Shop.Code;
        LibraryAssert.AreEqual(ShopCode, Shop.Code, 'Shop Code is different than Shop');
    end;

    [Test]
    procedure UnitTestExportMetafieldsToShopify()
    var
        Customer: Record Customer;
        ShopifyCustomer: Record "Shpfy Customer";
        CustomerAddress: Record "Shpfy Customer Address";
        Shop: Record "Shpfy Shop";
        ShpfyMetafield: Record "Shpfy Metafield";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        Result: Boolean;
    begin
        // [SCENARIO] Export Customer metafields to Shopify.
        Initialize();

        // [GIVEN] Shopify Customer
        CreateShopifyCustomer(ShopifyCustomer, Shop."Shop Id");
        // [GIVEN] Customer metafields





        // [WHEN] Invoke MetafieldAPI.CreateOrUpdateMetafieldsInShopify(Database::"Shpfy Customer", CustomerId);

        // [THEN]
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;
        Shop := ShpfyInitializeTest.CreateShop();
        Any.SetDefaultSeed();
    end;

    local procedure CreateShopifyCustomer(var ShopifyCustomer: Record "Shpfy Customer"; ShopId: BigInteger)
    begin
        ShopifyCustomer.Init();
        ShopifyCustomer.Id := Any.IntegerInRange(100000, 999999);
        ShopifyCustomer."Shop Id" := ShopId;
        ShopifyCustomer.Insert(true);
    end;

    local procedure CreateShopifyMetafield(var ShpfyMetafield: Record "Shpfy Metafield"; OwnerId: BigInteger; ParentTableId: Integer)
    begin
        ShpfyMetafield.Init();
        ShpfyMetafield."Owner Id" := OwnerId;
        ShpfyMetafield.Validate("Parent Table No.", ParentTableId);
        ShpfyMetafield.Insert(true);
    end;

    local procedure CreateMetafield(var ShpfyMetafield: Record "Shpfy Metafield"; OwnerId: BigInteger; ParentTableId: Integer)
    begin
        ShpfyMetafield.Init();
        ShpfyMetafield."Owner Id" := OwnerId;
        ShpfyMetafield."Parent Table No." := OwnerId;
        ShpfyMetafield.Insert(true);
    end;

}
