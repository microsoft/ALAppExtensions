codeunit 139563 "Shpfy Test Shopify"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";

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
        LibraryAssert.RecordIsNotEmpty(Shop);
        // [THEN] The Shop must have a Shopify URL.
        LibraryAssert.IsFalse(Shop."Shopify URL" = '', ShopMissingUrlErr);
        // [THEN] The Shop record in the codeunit "Shpfy Communication Mgt." must be equal to the retrieved Shop.
        LibraryAssert.AreEqual(Shop.SystemId, CommunicationMgt.GetShopRecord().SystemId, '');
    end;

    [Test]
    procedure UnitTestBlockOutOfSupportAPI()
    var
        Shop: Record "Shpfy Shop";
    begin
        // [SCENARIO] If a version is out of support then the API must be blocked.
        // [WHEN] The Shop is created.
        Shop := InitializeTest.CreateShop();
        CommunicationMgt.SetTestInProgress(false);
        SetupKeyVaultExpiryDate(CommunicationMgt.GetApiVersion());
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [THEN] Test connection action should fail when invoked to call Shopify API.
        asserterror Shop.TestConnection();
        LibraryAssert.ExpectedError('The Shopify Admin API used by your current Shopify connector is no longer supported. To continue using the Shopify connector, please upgrade the Shopify connector and your Business Central environment.');
    end;

    local procedure SetupKeyVaultExpiryDate(ApiVersion: Text)
    var
        AzureKeyVaultTestLibrary: Codeunit "Azure Key Vault Test Library";
        MockAzureKeyvaultSecretProvider: DotNet MockAzureKeyVaultSecretProvider;
    begin
        MockAzureKeyvaultSecretProvider := MockAzureKeyvaultSecretProvider.MockAzureKeyVaultSecretProvider();
        MockAzureKeyvaultSecretProvider.AddSecretMapping('ShopifyApiVersionExpiryDate', '{"' + ApiVersion + '": "' + Format(CurrentDateTime().Date().Year, 0, 9) + '-' + Format(CurrentDateTime().Date().Month, 0, 9) + '-' + Format(CurrentDateTime().Date().Day, 0, 9) + '"}');
        AzureKeyVaultTestLibrary.SetAzureKeyVaultSecretProvider(MockAzureKeyvaultSecretProvider);
    end;
}
