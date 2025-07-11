#if CLEAN27
codeunit 139500 "Test UK Postcode"
{
    Subtype = Test;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        PostcodeBusinessLogic: Codeunit "Postcode Business Logic GB";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        PostcodeDummyService: Codeunit "Postcode Dummy Service";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        Initialized: Boolean;
        Bound: Boolean;

    [Test]
    [HandlerFunctions('PostcodeSearchInputCancelPageHandler')]
    [Scope('OnPrem')]
    procedure TestOpenPostcodeLookupPage()
    var
        CustomerCard: TestPage "Customer Card";
    begin
        // [GIVEN] postcode service is configured
        Initialize();
        LibraryLowerPermissions.SetCustomerEdit();

        // [WHEN] on postcode lookup field drilldown, a page with results should open
        CustomerCard.OpenEdit();
        CustomerCard.LookupAddress_GB.DrillDown();

        // [THEN] error is raised if not because of unsued page handlers
        DeleteConfiguration();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPostcodeIsCreatedWhenFlagIsFalse()
    begin
        Initialize();
        LibraryLowerPermissions.SetO365Basic();
        GeneralTestCreatePostcodeOnPostcodeSelect(false, 0);
        DeleteConfiguration();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPostcodeIsCreatedWhenFlagIsTrue()
    begin
        Initialize();
        LibraryLowerPermissions.SetO365Basic();
        GeneralTestCreatePostcodeOnPostcodeSelect(true, 1);
        DeleteConfiguration();
    end;

    [Test]
    [HandlerFunctions('PostcodeAddressSelectPageHandler')]
    [Scope('OnPrem')]
    procedure TestAutocompleteAddressIsFilledWhenAddressIsSelected()
    var
        TempAutocompleteAddress: Record "Autocomplete Address" temporary;
        TempEnteredAutocompleteAddress: Record "Autocomplete Address" temporary;
    begin
        // [GIVEN]
        // - Service is configured, use GetAddress.io to retrieve an
        // actual list from mock service
        // - Select the first item on the list
        Initialize();
        LibraryLowerPermissions.SetCustomerEdit();

        // This is what we'd like to get
        TempAutocompleteAddress.Address := 'ADDRESS';
        TempAutocompleteAddress.Postcode := 'POSTCODE';

        // This is our query
        TempEnteredAutocompleteAddress.Init();
        TempEnteredAutocompleteAddress.Postcode := 'POSTCODE';

        // Which address should be selected in address select window
        LibraryVariableStorage.Enqueue(1);

        // [WHEN] postcode selection process starts and postcode is selected
        PostcodeBusinessLogic.ShowLookupWindow(TempEnteredAutocompleteAddress, false, TempAutocompleteAddress);
        // PageHandler for Postcode Address Select takes over and selects address with specific index

        // [THEN] we should get our data
        Assert.AreEqual('ADDRESS', TempAutocompleteAddress.Address, 'Retrieved selected value is incorrect.');
        Assert.AreEqual('POSTCODE', TempAutocompleteAddress.Postcode, 'Retrieved selected value is incorrect.');
        LibraryLowerPermissions.SetO365BusFull(); // for the cleanup
        DeleteConfiguration();
    end;

    [Test]
    [HandlerFunctions('PostcodeSearchInputEnterPostcodeAndOKPageHandler')]
    [Scope('OnPrem')]
    procedure TestFieldsAreRetrievedFromPostcodeSearchPage()
    var
        PostcodeSearch: Page "Postcode Search";
        Postcode: Text;
        DeliveryPoint: Text;
    begin
        // [GIVEN]
        LibraryLowerPermissions.SetO365Basic();
        // - Set values that should be inputed
        LibraryVariableStorage.Enqueue('POSTCODE');
        LibraryVariableStorage.Enqueue('DELIVERYPOINT');

        // [WHEN]
        // - Run the window
        // - retireve the values
        PostcodeSearch.RunModal();
        PostcodeSearch.GetValues(Postcode, DeliveryPoint);

        // [THEN]
        Assert.AreEqual('POSTCODE', Postcode, 'Retrived postcode is not correct.');
        Assert.AreEqual('DELIVERYPOINT', DeliveryPoint, 'Retrived delivery point is not correct.');
        DeleteConfiguration();
    end;

    [Test]
    [HandlerFunctions('PostcodeIsAutocompletedOnPostcodeSearchIfProvided')]
    [Scope('OnPrem')]
    procedure TestPostcodeValuesAreSetForPostcodeSearchPageWhenOpened()
    var
        PostcodeSearch: Page "Postcode Search";
    begin
        // Check that values are correctly passed into a page
        // [GIVEN]
        LibraryLowerPermissions.SetO365Basic();
        PostcodeSearch.SetValues('POSTCODE', 'DELIVERYPOINT');

        // [WHEN]
        Assert.IsTrue(PostcodeSearch.RunModal() = ACTION::Cancel, 'Because of precal');

        // [THEN] assertion is done in the handler
        DeleteConfiguration();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPostcodeIsAutomaticallyRetrievedIfOnlyOneResult()
    var
        TempAutocompleteAddress: Record "Autocomplete Address" temporary;
        TempEnteredAutocompleteAddress: Record "Autocomplete Address" temporary;
        PostcodeBusinessLogic: Codeunit "Postcode Business Logic GB";
    begin
        // [GIVEN]
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();
        TempEnteredAutocompleteAddress.Init();
        TempAutocompleteAddress.Address := 'ADDRESS'; // This is what we want to get back
        TempEnteredAutocompleteAddress.Postcode := 'ONE';

        // [WHEN]
        PostcodeBusinessLogic.ShowLookupWindow(TempEnteredAutocompleteAddress, false, TempAutocompleteAddress);

        // [THEN] no window opens, values are retrieved
        Assert.AreEqual('ADDRESS', TempAutocompleteAddress.Address, 'Value was not retrieved correctly');
        DeleteConfiguration();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestNotificationDontShowAgain()
    var
        PostcodeNotificationMemory: Record "Postcode Notification Memory";
        PostcodeBusinessLogic: Codeunit "Postcode Business Logic GB";
        DummyNotification: Notification;
    begin
        // [GIVEN] basic user, that hasn't had any interaction with postcode notificaitons
        LibraryLowerPermissions.SetO365Basic();
        Assert.RecordIsEmpty(PostcodeNotificationMemory);

        // [WHEN] user clicks "don't show again"
        PostcodeBusinessLogic.NotificationOnDontShowAgain(DummyNotification);

        // [THEN] no window opens, record is present NOT to show notification again
        Assert.RecordCount(PostcodeNotificationMemory, 1);

        PostcodeNotificationMemory.DeleteAll(); // Cleanup
    end;

    [Test]
    [HandlerFunctions('PostcodeConfigurationPageHandler')]
    [Scope('OnPrem')]
    procedure TestNotificationConfigure()
    var
        PostcodeNotificationMemory: Record "Postcode Notification Memory";
        PostcodeBusinessLogic: Codeunit "Postcode Business Logic GB";
        DummyNotification: Notification;
    begin
        // [GIVEN] basic user, that hasn't had any interaction with postcode notificaitons
        LibraryLowerPermissions.SetO365BusFull();
        Assert.RecordIsEmpty(PostcodeNotificationMemory);

        // [WHEN] User clicks configure
        PostcodeBusinessLogic.NotificationOnConfigure(DummyNotification);

        // [THEN] service config window opens, record is present NOT to show notification again
        Assert.RecordCount(PostcodeNotificationMemory, 1);

        PostcodeNotificationMemory.DeleteAll(); // Cleanup
    end;

    local procedure Initialize()
    var
        PostcodeServiceConfig: Record "Postcode Service Config";
    begin
        Clear(PostcodeBusinessLogic);
        LibraryVariableStorage.Clear();

        if not Bound then begin
            BindSubscription(PostcodeDummyService);
            Bound := true;
        end;

        if not Initialized then begin
            PostcodeServiceConfig.DeleteAll();
            PostcodeServiceConfig.Init();
            PostcodeServiceConfig.Insert();
            PostcodeServiceConfig.SaveServiceKey('Dummy Service');
            Commit();
            Initialized := true;
        end;
    end;

    [Scope('OnPrem')]
    procedure DeleteConfiguration()
    begin
        if Bound then
            UnbindSubscription(PostcodeDummyService);

        Commit();
        Bound := false;
        Initialized := false;
    end;

    local procedure GeneralTestCreatePostcodeOnPostcodeSelect(IsCreateFlagEnabled: Boolean; ExpectedMoreRecCount: Integer)
    var
        PostCode: Record "Post Code";
        TempAutocompleteAddress: Record "Autocomplete Address" temporary;
        PrevCount: Integer;
    begin
        // Initialize
        // - Create config, use GetAddress.io service
        // - Set save more accordingly
        // - Store current record count
        PostcodeBusinessLogic.SetSavePostcode(IsCreateFlagEnabled);
        PrevCount := PostCode.Count();

        // [WHEN] Get results, set ONE to skip all UI things
        // Also set city otherwise postcode can't be created (Postcode + City = Primary Key)
        TempAutocompleteAddress.Postcode := 'ONE';
        TempAutocompleteAddress.City := 'CITY';
        PostcodeBusinessLogic.ShowLookupWindow(TempAutocompleteAddress, false, TempAutocompleteAddress);

        // [THEN] there should be on postcode more
        Assert.RecordCount(PostCode, PrevCount + ExpectedMoreRecCount);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure PostcodeSearchInputCancelPageHandler(var PostcodeSearchPage: TestPage "Postcode Search")
    begin
        PostcodeSearchPage.Cancel().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure PostcodeSearchInputEnterPostcodeAndOKPageHandler(var PostcodeSearchPage: TestPage "Postcode Search")
    begin
        PostcodeSearchPage.PostcodeField.Value(LibraryVariableStorage.DequeueText());
        PostcodeSearchPage.DeliveryPoint.Value(LibraryVariableStorage.DequeueText());
        PostcodeSearchPage.OK().Invoke();
    end;

    [ModalPageHandler]
    [HandlerFunctions('PostcodeAddressSelectPageHandler')]
    [Scope('OnPrem')]
    procedure PostcodeAddressSelectPageHandler(var PostcodeSelectAddress: TestPage "Postcode Select Address")
    begin
        PostcodeSelectAddress.GotoKey(LibraryVariableStorage.DequeueInteger());
        PostcodeSelectAddress.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure PostcodeIsAutocompletedOnPostcodeSearchIfProvided(var PostcodeSearch: TestPage "Postcode Search")
    begin
        Assert.AreEqual('POSTCODE', PostcodeSearch.PostcodeField.Value, 'Postcode is not correctly passed into a page.');
        Assert.AreEqual('DELIVERYPOINT', PostcodeSearch.DeliveryPoint.Value, 'Delivery point is not correctly passed into a page.');
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure PostcodeConfigurationPageHandler(var PostcodeConfigurationPage: TestPage "Postcode Configuration Page")
    begin
        PostcodeConfigurationPage.Cancel().Invoke();
    end;
}
#endif