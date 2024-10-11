codeunit 139581 "Shpfy Customer Metafields Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestExportMetafieldsToShopify()
    var
        Customer: Record Customer;
        ShopifyCustomer: Record "Shpfy Customer";
        CustomerAddress: Record "Shpfy Customer Address";
        Shop: Record "Shpfy Shop";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        Result: boolean;
    begin
        // [SCENARIO] Export Customer metafields to Shopify.
        // [GIVEN] Customer Id With metafields created in BC.

        // [WHEN] Invoke MetafieldAPI.CreateOrUpdateMetafieldsInShopify(Database::"Shpfy Customer", CustomerId);

        // [THEN]
    end;

}
