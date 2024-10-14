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
        Shop: Record "Shpfy Shop";
        ShpfyCustomer: Record "Shpfy Customer";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShpfyMetafieldOwnerType: Enum "Shpfy Metafield Owner Type";
        IMetagieldOwnerType: Interface "Shpfy IMetafield Owner Type";
    begin
        // [SCENARIO] Get Metafield Owner Values from Metafield Owner Company codeunit
        Initialize();

        // [GIVEN] Shopify Metafield created for Customer.
        // [GIVEN] Shopify Metafield created for Company.
        ShpfyMetafield.Init();
        ShpfyMetafield."Owner Id" := Any.IntegerInRange(10000, 99999);



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
        // [GIVEN] Customer



        // [WHEN] Invoke MetafieldAPI.CreateOrUpdateMetafieldsInShopify(Database::"Shpfy Customer", CustomerId);

        // [THEN]
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;
        Shop := ShpfyInitializeTest.CreateShop();
    end;

    local procedure CreateShopifyCustomer(var ShopifyCustomer: Record "Shpfy Customer"; ShopId: BigInteger)
    begin
        ShopifyCustomer.Init();

    end;

    local procedure CreateShopifyMetafield(var ShpfyMetafield: Record "Shpfy Metafield"; OwnerId: BigInteger; ParentTableId: Integer)
    begin
        ShpfyMetafield.Init();
        ShpfyMetafield."Owner Id" := OwnerId;
        ShpfyMetafield.Validate("Parent Table No.", ParentTableId);
        ShpfyMetafield.Insert(true);
    end;

}
