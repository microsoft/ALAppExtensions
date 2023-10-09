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
        ConnectorGuide: TestPage "Shpfy Connector Guide";
    begin
        // Init
        Initialize();

        // Setup
        ConnectorGuide.OpenEdit();
        ConnectorGuide.ActionNext.Invoke();
        LibraryAssert.IsTrue(ConnectorGuide.Consent.Visible(), 'Consent dialog must be visible.');
        LibraryAssert.AreEqual('No', ConnectorGuide.Consent.Value(), 'Consent should be disabled.');
        LibraryAssert.IsFalse(ConnectorGuide.ActionNext.Enabled(), 'Next action should not be Enabled.');

        //Exercise
        ConnectorGuide.Consent.Value(format(true));

        // Verify
        LibraryAssert.AreEqual('Yes', ConnectorGuide.Consent.Value(), 'Consent should be enabled.');
        LibraryAssert.IsTrue(ConnectorGuide.ActionNext.Enabled(), 'Next action should be Enabled.');
    end;

    [HandlerFunctions('SetupNotCompleteConfirmHandler')]
    [Test]
    procedure ConnectorGuideUrlAutoFillTest()
    var
        ConnectorGuide: TestPage "Shpfy Connector Guide";
    begin
        // Init
        Initialize();

        // Setup
        MockShopifySignupContext();
        ConnectorGuide.OpenEdit();
        ConnectorGuide.ActionNext.Invoke();
        ConnectorGuide.Consent.Value(format(true));

        //Exercise
        ConnectorGuide.ActionNext.Invoke();

        // Verify
        LibraryAssert.AreEqual('https://' + DummyShopUrlTxt, ConnectorGuide.ShopUrl.Value(), 'Shop url should be filled in automatically.')
    end;

    [Test]
    procedure ConnectorGuideInvalidUrlTest()
    var
        ConnectorGuide: TestPage "Shpfy Connector Guide";
    begin
        // Init
        Initialize();

        // Setup
        ConnectorGuide.OpenEdit();
        ConnectorGuide.ActionNext.Invoke();
        ConnectorGuide.Consent.Value(format(true));
        ConnectorGuide.ActionNext.Invoke();

        //Exercise
        AssertError ConnectorGuide.ShopUrl.SetValue('https://NotAValidShopifyUrl.OurShopify.com');

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