/// <summary>
/// Codeunit Shpfy Customer Mapping Test (ID 30508).
/// </summary>
codeunit 30508 "Shpfy Customer Mapping Test"
{
    Subtype = Test;

    var

        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
        Assert: Codeunit "Library Assert";

    [Test]
    procedure TestCustomerMapping()
    var
        Customer: Record Customer;
        Shop: Record "Shpfy Shop";
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
        Shop := CommunicationMgt.GetShopRecord();
        ShopCode := Shop.Code;

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
        Assert.AreEqual(Shop."Default Customer No.", ResultCode, 'Mapping to Default Customer');

        // [WHEN] ICustomerMapping = "Shpfy Customer Mapping"::"By EMail/Phone"
        ICustomerMapping := "Shpfy Customer Mapping"::"By EMail/Phone";
        // [THEN] Customer."No."" = ResultCode
        ResultCode := ICustomerMapping.DoMapping(CustomerId, JCustomerInfo, ShopCode);
        Assert.AreEqual(Customer."No.", ResultCode, 'Mapping By EMail/Phone');

        // [WHEN] ICustomerMapping = "Shpfy Customer Mapping"::"By Bill-to Info"
        ICustomerMapping := "Shpfy Customer Mapping"::"By Bill-to Info";
        // [THEN] Customer."No."" = ResultCode
        ResultCode := ICustomerMapping.DoMapping(CustomerId, JCustomerInfo, ShopCode);
        Assert.AreEqual(Customer."No.", ResultCode, 'Mapping By Bill-to Info');
    end;

    local procedure CreateShopifyCustomerAddress(var Customer: Record Customer; var ShpfyCustomer: Record "Shpfy Customer")
    var
        ShpfyCustomerAddress: Record "Shpfy Customer Address";
    begin
        ShpfyCustomerAddress := CustomerInitTest.CreateShopifyCustomerAddress(ShpfyCustomer);

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

        CustomerId := CustomerInitTest.CreateShopifyCustomer(ShpfyCustomer);
        ShpfyCustomer."Customer SystemId" := Customer.SystemId;
        ShpfyCustomer.Modify();
        ShpfyCustomer.CalcFields("Customer No.");
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
