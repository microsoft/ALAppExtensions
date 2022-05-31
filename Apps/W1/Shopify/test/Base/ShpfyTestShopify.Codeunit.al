codeunit 135603 "Shpfy Test Shopify"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit "Library Assert";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        InitializeTest: Codeunit "Shpfy Initialize Test";
    // LibrarySetupStorage: Codeunit "Library - Setup Storage";
    // LibraryTestInitialize: Codeunit "Library - Test Initialize";
    // LibraryVariableStorage: Codeunit "Library - Variable Storage";
    // IsInitialized: Boolean;


    [Test]
    procedure UnitTestConfigureShop()
    var
        Shop: Record "Shpfy Shop";
        ShopMissingUrlErr: Label 'The Shop is missing the Shopify URL.';
    begin
        // [SCENARIO] A random Shop is created and assignd to the codeunit "Shpfy Communication Mgt."
        // [WHEN] The Shop is created.
        Shop := InitializeTest.CreateShop();
        // [THEN] The Shop must have a code.
        Assert.RecordIsNotEmpty(Shop);
        // [THEN] The Shop must have a Shopify URL.
        Assert.IsFalse(Shop."Shopify URL" = '', ShopMissingUrlErr);
        // [THEN] The Shop record in the codeunit "Shpfy Communication Mgt." must be equal to the retrieved Shop.
        Assert.AreEqual(Shop.SystemId, CommunicationMgt.GetShopRecord().SystemId, '');
    end;
}
