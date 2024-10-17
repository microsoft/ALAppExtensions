/// <summary>
/// Codeunit Shpfy Sales Channel Test (ID 139581).        
/// </summary>
codeunit 139581 "Shpfy Sales Channel Test"
{
    Subtype = Test;

    var
        Shop: Record "Shpfy Shop";
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        SalesChannelHelper: Codeunit "Shpfy Sales Channel Helper";
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        IsInitialized := false;
    end;

    [Test]
    procedure UnitTestImportSalesChannelTest()
    var
        SalesChannel: Record "Shpfy Sales Channel";
        SalesChannelAPI: Codeunit "Shpfy Sales Channel API";
        JPublications: JsonArray;
    begin
        // [SCENARIO] Importing sales channel from Shopify to Business Central.
        Initialize();

        // [GIVEN] Shopify response with sales channel data.
        JPublications := SalesChannelHelper.GetDefaultShopifySalesChannelRespone();

        // [WHEN] Invoking the procedure: SalesChannelAPI.ProcessPublications(JPublications, Shop.Code)
        SalesChannelAPI.ProcessPublications(JPublications, Shop.Code);

        // [THEN] The sales channels are imported to Business Central.
        SalesChannel.SetRange("Shop Code", Shop.Code);
        LibraryAssert.IsFalse(SalesChannel.IsEmpty(), 'Sales Channel not created');
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;
        Any.SetDefaultSeed();
        Shop := ShpfyInitializeTest.CreateShop();
        IsInitialized := true;
        Commit();
    end;


}
