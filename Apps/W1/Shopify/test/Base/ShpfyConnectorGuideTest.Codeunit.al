codeunit 139588 "Shpfy Connector Guide Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        LibrarySignupContext: Codeunit "Library - Signup Context";
        DummyShopUrlTxt: Label 'dummyshop.myshopify.com', Locked = true;
        IsInitialized: Boolean;

    [HandlerFunctions('SetupNotCompleteConfirmHandler')]
    [Test]
    procedure ConnectorGuideConsentTest()
    var
        ShpfyConnectorGuide: TestPage "Shpfy Connector Guide";
    begin
        // Init
        Initialize();

        // Setup
        ShpfyConnectorGuide.OpenEdit();
        ShpfyConnectorGuide.ActionNext.Invoke();
        LibraryAssert.IsTrue(ShpfyConnectorGuide.Consent.Visible(), 'Consent dialog must be visible.');
        LibraryAssert.AreEqual('No', ShpfyConnectorGuide.Consent.Value(), 'Consent should be disabled.');
        LibraryAssert.IsFalse(ShpfyConnectorGuide.ActionNext.Enabled(), 'Next action should not be Enabled.');

        //Exercise
        ShpfyConnectorGuide.Consent.Value(format(true));

        // Verify
        LibraryAssert.AreEqual('Yes', ShpfyConnectorGuide.Consent.Value(), 'Consent should be enabled.');
        LibraryAssert.IsTrue(ShpfyConnectorGuide.ActionNext.Enabled(), 'Next action should be Enabled.');
    end;

    [HandlerFunctions('SetupNotCompleteConfirmHandler')]
    [Test]
    procedure ConnectorGuideUrlAutoFillTest()
    var
        ShpfyConnectorGuide: TestPage "Shpfy Connector Guide";
    begin
        // Init
        Initialize();

        // Setup
        MockShopifySignupContext();
        ShpfyConnectorGuide.OpenEdit();
        ShpfyConnectorGuide.ActionNext.Invoke();
        ShpfyConnectorGuide.Consent.Value(format(true));

        //Exercise
        ShpfyConnectorGuide.ActionNext.Invoke();

        // Verify
        LibraryAssert.AreEqual('https://' + DummyShopUrlTxt, ShpfyConnectorGuide.ShopUrl.Value(), 'Shop url should be filled in automatically.')
    end;

    [Test]
    procedure ConnectorGuideInvalidUrlTest()
    var
        ShpfyConnectorGuide: TestPage "Shpfy Connector Guide";
    begin
        // Init
        Initialize();

        // Setup
        ShpfyConnectorGuide.OpenEdit();
        ShpfyConnectorGuide.ActionNext.Invoke();
        ShpfyConnectorGuide.Consent.Value(format(true));
        ShpfyConnectorGuide.ActionNext.Invoke();

        //Exercise
        AssertError ShpfyConnectorGuide.ShopUrl.SetValue('https://NotAValidShopifyUrl.OurShopify.com');

        // Verify
        LibraryAssert.ExpectedError('The URL must refer to the internal shop location at myshopify.com');
    end;


    [ConfirmHandler]
    procedure SetupNotCompleteConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryAssert.AreEqual('The setup is not complete.\\Are you sure you want to exit?', Question, 'Wrong confirmation dialog.');
        Reply := true;

    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
    end;

    local procedure MockShopifySignupContext()
    var
        CompanyTriggers: Codeunit "Company Triggers";
    begin
        LibrarySignupContext.DeleteSignupContext();
        LibrarySignupContext.SetDisableSystemUserCheck();
        LibrarySignupContext.SetSignupContext('name', 'shopify');
        LibrarySignupContext.SetSignupContext('shop', DummyShopUrlTxt);

#pragma warning disable AL0432
        CompanyTriggers.OnCompanyOpen();
#pragma warning restore AL0432
    end;
}