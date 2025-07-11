/// <summary>
/// Codeunit Shpfy Customer Mapping Test (ID 139569).
/// </summary>
codeunit 139569 "Shpfy Customer Mapping Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var

        LibraryAssert: Codeunit "Library Assert";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";

    [Test]
    procedure TestCustomerMapping()
    var
        Customer: Record Customer;
        Shop: Record "Shpfy Shop";
        ShopifyCustomer: Record "Shpfy Customer";
        CustomerId: BigInteger;
        ResultCode: Code[20];
        ShopCode: Code[20];
        ICustomerMapping: Interface "Shpfy ICustomer Mapping";
        JCustomerInfo: JsonObject;
    begin
        Init(Customer);

        // Creating Test data.
        JCustomerInfo := CreateJsonCustomerInfo();
        Shop := CommunicationMgt.GetShopRecord();
        ShopCode := Shop.Code;

        CustomerId := CreateShopifyCustomer(Customer, ShopifyCustomer);
        CreateShopifyCustomerAddress(Customer, ShopifyCustomer);

        // [SCENARIO] Map the received customer data to an existing customer.

        // [GIVEN] CustomerId
        // [GIVEN] JCustomerInfo
        // [GIVEN] ShopCode

        // [WHEN] ICustomerMapping = "Shpfy Customer Mapping"::DefaultCustomer
        ICustomerMapping := "Shpfy Customer Mapping"::DefaultCustomer;
        // [THEN] Shop."Default Customer" = ResultCode
        ResultCode := ICustomerMapping.DoMapping(CustomerId, JCustomerInfo, ShopCode);
        LibraryAssert.AreEqual(Shop."Default Customer No.", ResultCode, 'Mapping to Default Customer');

        // [WHEN] ICustomerMapping = "Shpfy Customer Mapping"::"By EMail/Phone"
        ICustomerMapping := "Shpfy Customer Mapping"::"By EMail/Phone";
        // [THEN] Customer."No."" = ResultCode
        ResultCode := ICustomerMapping.DoMapping(CustomerId, JCustomerInfo, ShopCode);
        LibraryAssert.AreEqual(Customer."No.", ResultCode, 'Mapping By EMail/Phone');

        // [WHEN] ICustomerMapping = "Shpfy Customer Mapping"::"By Bill-to Info"
        ICustomerMapping := "Shpfy Customer Mapping"::"By Bill-to Info";
        // [THEN] Customer."No."" = ResultCode
        ResultCode := ICustomerMapping.DoMapping(CustomerId, JCustomerInfo, ShopCode);
        LibraryAssert.AreEqual(Customer."No.", ResultCode, 'Mapping By Bill-to Info');
    end;

    local procedure CreateShopifyCustomerAddress(var Customer: Record Customer; var ShopifyCustomer: Record "Shpfy Customer")
    var
        CustomerAddress: Record "Shpfy Customer Address";
    begin
        CustomerAddress := CustomerInitTest.CreateShopifyCustomerAddress(ShopifyCustomer);

        CustomerAddress.CustomerSystemId := Customer.SystemId;
        CustomerAddress.Modify();
    end;

    local procedure CreateShopifyCustomer(var Customer: Record Customer; var ShopifyCustomer: Record "Shpfy Customer"): BigInteger
    var
        CustomerId: BigInteger;
    begin
        Customer.Init();
        Customer."No." := 'YYYY';
        Customer.Insert(false);

        CustomerId := CustomerInitTest.CreateShopifyCustomer(ShopifyCustomer);
        ShopifyCustomer."Customer SystemId" := Customer.SystemId;
        ShopifyCustomer.Modify();
        ShopifyCustomer.CalcFields("Customer No.");
        exit(CustomerId);
    end;

    local procedure CreateJsonCustomerInfo(): JsonObject
    var
        Shop: Record "Shpfy Shop";
    begin

        Shop := CommunicationMgt.GetShopRecord();
        exit(CustomerInitTest.CreateJsonCustomerInfo(Shop."Name Source", Shop."Name 2 Source"));
    end;

    local procedure Init(var Customer: Record Customer)
    var
        Shop: Record "Shpfy Shop";
    begin
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        Shop := CommunicationMgt.GetShopRecord();
        if Shop."Default Customer No." = '' then begin
            if Customer.FindFirst() then
                Shop."Default Customer No." := Customer."No."
            else
                Shop."Default Customer No." := 'XXXX';
            Shop."Name Source" := "Shpfy Name Source"::CompanyName;
            Shop."Name 2 Source" := "Shpfy Name Source"::FirstAndLastName;
            if not Shop.Modify(false) then
                Shop.Insert();
            CommunicationMgt.SetShop(Shop);
        end;
    end;
}
