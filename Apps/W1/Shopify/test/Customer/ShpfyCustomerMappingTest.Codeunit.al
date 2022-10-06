/// <summary>
/// Codeunit Shpfy Customer Mapping Test (ID 139569).
/// </summary>
codeunit 139569 "Shpfy Customer Mapping Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var

        LibraryAssert: Codeunit "Library Assert";
        ShpfyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ShpfyCustomerInitTest: Codeunit "Shpfy Customer Init Test";

    [Test]
    procedure TestCustomerMapping()
    var
        Customer: Record Customer;
        ShpfyShop: Record "Shpfy Shop";
        ShpfyCustomer: Record "Shpfy Customer";
        CustomerId: BigInteger;
        ResultCode: Code[20];
        ShopCode: Code[20];
        ICustomerMapping: Interface "Shpfy ICustomer Mapping";
        JCustomerInfo: JsonObject;
    begin
        Init(Customer);

        // Creating Test data.
        JCustomerInfo := CreateJsonCustomerInfo();
        ShpfyShop := ShpfyCommunicationMgt.GetShopRecord();
        ShopCode := ShpfyShop.Code;

        CustomerId := CreateShopifyCustomer(Customer, ShpfyCustomer);
        CreateShopifyCustomerAddress(Customer, ShpfyCustomer);

        // [SCENARIO] Map the received customer data to an existing customer.

        // [GIVEN] CustomerId
        // [GIVEN] JCustomerInfo
        // [GIVEN] ShopCode

        // [WHEN] ICustomerMapping = "Shpfy Customer Mapping"::DefaultCustomer
        ICustomerMapping := "Shpfy Customer Mapping"::DefaultCustomer;
        // [THEN] Shop."Default Customer" = ResultCode
        ResultCode := ICustomerMapping.DoMapping(CustomerId, JCustomerInfo, ShopCode);
        LibraryAssert.AreEqual(ShpfyShop."Default Customer No.", ResultCode, 'Mapping to Default Customer');

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

    local procedure CreateShopifyCustomerAddress(var Customer: Record Customer; var ShpfyCustomer: Record "Shpfy Customer")
    var
        ShpfyCustomerAddress: Record "Shpfy Customer Address";
    begin
        ShpfyCustomerAddress := ShpfyCustomerInitTest.CreateShopifyCustomerAddress(ShpfyCustomer);

        ShpfyCustomerAddress.CustomerSystemId := Customer.SystemId;
        ShpfyCustomerAddress.Modify();
    end;

    local procedure CreateShopifyCustomer(var Customer: Record Customer; var ShpfyCustomer: Record "Shpfy Customer"): BigInteger
    var
        CustomerId: BigInteger;
    begin
        Customer.Init();
        Customer."No." := 'YYYY';
        Customer.Insert(false);

        CustomerId := ShpfyCustomerInitTest.CreateShopifyCustomer(ShpfyCustomer);
        ShpfyCustomer."Customer SystemId" := Customer.SystemId;
        ShpfyCustomer.Modify();
        ShpfyCustomer.CalcFields("Customer No.");
        exit(CustomerId);
    end;

    local procedure CreateJsonCustomerInfo(): JsonObject
    var
        ShpfyShop: Record "Shpfy Shop";
    begin

        ShpfyShop := ShpfyCommunicationMgt.GetShopRecord();
        exit(ShpfyCustomerInitTest.CreateJsonCustomerInfo(ShpfyShop."Name Source", ShpfyShop."Name 2 Source"));
    end;

    local procedure Init(var Customer: Record Customer)
    var
        ShpfyShop: Record "Shpfy Shop";
    begin
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        ShpfyShop := ShpfyCommunicationMgt.GetShopRecord();
        if ShpfyShop."Default Customer No." = '' then begin
            if Customer.FindFirst() then
                ShpfyShop."Default Customer No." := Customer."No."
            else
                ShpfyShop."Default Customer No." := 'XXXX';
            ShpfyShop."Name Source" := "Shpfy Name Source"::CompanyName;
            ShpfyShop."Name 2 Source" := "Shpfy Name Source"::FirstAndLastName;
            if not ShpfyShop.Modify(false) then
                ShpfyShop.Insert();
            ShpfyCommunicationMgt.SetShop(ShpfyShop);
        end;
    end;
}
