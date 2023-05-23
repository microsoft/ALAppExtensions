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
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        CreateCustomerTest: Codeunit "Shpfy Create Customer Test";
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
        OnCreateCustomerEventMsg: Label 'OnCreateCustomer', Locked = true;

    [Test]
    [HandlerFunctions('OnCreateCustomerHandler')]
    procedure UniTestCreateCustomerFromShopifyInfo()
    var
#if not CLEAN22
        ConfigTemplateHeader: Record "Config. Template Header";
#endif
        Customer: Record Customer;
<<<<<<< HEAD
        CustomerAddress: Record "Shpfy Customer Address";
        CreateCustomer: Codeunit "Shpfy Create Customer";
    begin
        // Creating Test data. The database must have a Config Template for creating a customer.
        Init();
        CreateCustomer.SetShop(CommunicationMgt.GetShopRecord());
        ConfigTemplateHeader.SetRange("Table ID", Database::Customer);
        if not ConfigTemplateHeader.FindFirst() then
=======
        CustomerTempl: Record "Customer Templ.";
        ShpfyCustomerAddress: Record "Shpfy Customer Address";
        ShpfyCreateCustomer: Codeunit "Shpfy Create Customer";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
    begin
        // Creating Test data. The database must have a Config Template for creating a customer.
        Init();
        ShpfyCreateCustomer.SetShop(CommunicationMgt.GetShopRecord());
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then begin
            ConfigTemplateHeader.SetRange("Table ID", Database::Customer);
            if not ConfigTemplateHeader.FindFirst() then
                exit;
        end
        else
            if not CustomerTempl.FindFirst() then
                exit;
#else
        if not CustomerTempl.FindFirst() then
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
            exit;
#endif

        // [SCENARIO] Create a customer from an new Shopify Customer Address.
<<<<<<< HEAD
        CustomerAddress := CustomerInitTest.CreateShopifyCustomerAddress();
        CustomerAddress.SetRecFilter();

        // [GIVEN] The shop
        CreateCustomer.SetShop(CommunicationMgt.GetShopRecord());
        // [GIVEN] The customer template code
        CreateCustomer.SetTemplateCode(ConfigTemplateHeader.Code);
        // [GIVEN] The Shopify Customer Address record.
        BindSubscription(CreateCustomerTest);
        CreateCustomer.Run(CustomerAddress);
=======
        ShpfyCustomerAddress := CustomerInitTest.CreateShopifyCustomerAddress();
        ShpfyCustomerAddress.SetRecFilter();

        // [GIVEN] The shop
        ShpfyCreateCustomer.SetShop(CommunicationMgt.GetShopRecord());
        // [GIVEN] The customer template code
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ShpfyCreateCustomer.SetTemplateCode(ConfigTemplateHeader.Code)
        else
            ShpfyCreateCustomer.SetTemplateCode(CustomerTempl.Code);
#else
        ShpfyCreateCustomer.SetTemplateCode(CustomerTempl.Code);
#endif
        // [GIVEN] The Shopify Customer Address record.
        BindSubscription(CreateCustomerTest);
        ShpfyCreateCustomer.Run(ShpfyCustomerAddress);
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        UnbindSubscription(CreateCustomerTest);
        // [THEN] The customer record can be found by the link of CustomerSystemId.
        CustomerAddress.Get(CustomerAddress.Id);
        if not Customer.GetBySystemId(CustomerAddress.CustomerSystemId) then
            LibraryAssert.AssertRecordNotFound();
    end;

    local procedure Init()
    var
        Shop: Record "Shpfy Shop";
    begin
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        Shop := CommunicationMgt.GetShopRecord();
        if Shop."Default Customer No." = '' then begin
            Shop."Name Source" := "Shpfy Name Source"::CompanyName;
            Shop."Name 2 Source" := "Shpfy Name Source"::FirstAndLastName;
            if not Shop.Modify(false) then
                Shop.Insert();
            CommunicationMgt.SetShop(Shop);
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
