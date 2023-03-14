/// <summary>
/// Codeunit Shpfy Create Customer Test (ID 139565).
/// </summary>
codeunit 139565 "Shpfy Create Customer Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        ShpfyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        This: Codeunit "Shpfy Create Customer Test";
        ShpfyCustomerInitTest: Codeunit "Shpfy Customer Init Test";
        OnCreateCustomerEventMsg: Label 'OnCreateCustomer', Locked = true;

    [Test]
    [HandlerFunctions('OnCreateCustomerHandler')]
    procedure UniTestCreateCustomerFromShopifyInfo()
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        Customer: Record Customer;
        ShpfyCustomerAddress: Record "Shpfy Customer Address";
        ShpfyCreateCustomer: Codeunit "Shpfy Create Customer";
    begin
        // Creating Test data. The database must have a Config Template for creating a customer.
        Init();
        ShpfyCreateCustomer.SetShop(ShpfyCommunicationMgt.GetShopRecord());
        ConfigTemplateHeader.SetRange("Table ID", Database::Customer);
        if not ConfigTemplateHeader.FindFirst() then
            exit;

        // [SCENARIO] Create a customer from an new Shopify Customer Address.
        ShpfyCustomerAddress := ShpfyCustomerInitTest.CreateShopifyCustomerAddress();
        ShpfyCustomerAddress.SetRecFilter();

        // [GIVEN] The shop
        ShpfyCreateCustomer.SetShop(ShpfyCommunicationMgt.GetShopRecord());
        // [GIVEN] The customer template code
        ShpfyCreateCustomer.SetTemplateCode(ConfigTemplateHeader.Code);
        // [GIVEN] The Shopify Customer Address record.
        BindSubscription(This);
        ShpfyCreateCustomer.Run(ShpfyCustomerAddress);
        UnbindSubscription(This);
        // [THEN] The customer record can be found by the link of CustomerSystemId.
        ShpfyCustomerAddress.Get(ShpfyCustomerAddress.Id);
        if not Customer.GetBySystemId(ShpfyCustomerAddress.CustomerSystemId) then
            LibraryAssert.AssertRecordNotFound();
    end;

    local procedure Init()
    var
        ShpfyShop: Record "Shpfy Shop";
    begin
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        ShpfyShop := ShpfyCommunicationMgt.GetShopRecord();
        if ShpfyShop."Default Customer No." = '' then begin
            ShpfyShop."Name Source" := "Shpfy Name Source"::CompanyName;
            ShpfyShop."Name 2 Source" := "Shpfy Name Source"::FirstAndLastName;
            if not ShpfyShop.Modify(false) then
                ShpfyShop.Insert();
            ShpfyCommunicationMgt.SetShop(ShpfyShop);
        end;
    end;

    [MessageHandler]
    procedure OnCreateCustomerHandler(Message: Text)
    begin
        LibraryAssert.ExpectedMessage(OnCreateCustomerEventMsg, Message);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Customer Events", 'OnBeforeCreateCustomer', '', true, false)]
    local procedure OnBeforeCreateCustomer()
    begin
        Message(OnCreateCustomerEventMsg);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Customer Events", 'OnAfterCreateCustomer', '', true, false)]
    local procedure OnAfterCreateCustomer()
    begin
        Message(OnCreateCustomerEventMsg);
    end;
}
