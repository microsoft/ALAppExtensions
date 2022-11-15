codeunit 139563 "Shpfy Test Shopify"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        ShpfyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";


    [Test]
    procedure UnitTestConfigureShop()
    var
        ShpfyShop: Record "Shpfy Shop";
        ShopMissingUrlErr: Label 'The Shop is missing the Shopify URL.';
    begin
        // [SCENARIO] A random Shop is created and assignd to the codeunit "Shpfy Communication Mgt."
        // [WHEN] The Shop is created.
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        // [THEN] The Shop must have a code.
        LibraryAssert.RecordIsNotEmpty(ShpfyShop);
        // [THEN] The Shop must have a Shopify URL.
        LibraryAssert.IsFalse(ShpfyShop."Shopify URL" = '', ShopMissingUrlErr);
        // [THEN] The Shop record in the codeunit "Shpfy Communication Mgt." must be equal to the retrieved Shop.
        LibraryAssert.AreEqual(ShpfyShop.SystemId, ShpfyCommunicationMgt.GetShopRecord().SystemId, '');
    end;
}
