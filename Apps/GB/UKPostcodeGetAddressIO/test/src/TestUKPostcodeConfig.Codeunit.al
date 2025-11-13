#if CLEAN28
codeunit 148000 "Test UK Postcode Config"
{
    Subtype = Test;

    trigger OnRun()
    begin
    end;

    var
        PostcodeDummyService: Codeunit "Postcode Dummy Service";
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        DummyServiceTok: Label 'Dummy Service';
        DisabledTok: Label 'Disabled';
        Initialized: Boolean;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [Scope('OnPrem')]
    procedure TestOnCancelConfigurationThenRevertToOriginal()
    var
        PostcodeConfigurationPage: TestPage "Postcode Configuration Page GB";
    begin
        // [GIVEN]
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] we open a page, change a value and cancel
        PostcodeConfigurationPage.OpenEdit();
        PostcodeConfigurationPage.SelectedService.Value(DummyServiceTok);
        PostcodeConfigurationPage.Cancel().Invoke();

        // [THEN] old value should remain
        PostcodeConfigurationPage.OpenEdit(); // In order to retrieve the value
        Assert.AreEqual(DisabledTok, PostcodeConfigurationPage.SelectedService.Value, 'Value should be reverted to original');
    end;

    [Test]
    [HandlerFunctions('ServiceLookupHandler,ConfirmHandler')]
    [Scope('OnPrem')]
    procedure TestOnCancelProviderSelectionNothingHappens()
    var
        PostcodeConfigurationPage: TestPage "Postcode Configuration Page GB";
    begin
        // [GIVEN] we have a config page open and invoke lookup page
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();
        LibraryVariableStorage.Enqueue('CANCEL'); // Action for lookup page, what to do
        PostcodeConfigurationPage.OpenEdit();
        PostcodeConfigurationPage.SelectedService.Value(DisabledTok); // ensure which value we have
        PostcodeConfigurationPage.SelectedService.Lookup();

        // [WHEN] when we open a selection and cancel it
        // ServiceLookupHandler takes over

        // [THEN] value should remain the same
        Assert.AreEqual(DisabledTok, PostcodeConfigurationPage.SelectedService.Value, 'Value should be reverted to original');
    end;

    [Test]
    [HandlerFunctions('ServiceLookupHandler')]
    [Scope('OnPrem')]
    procedure TestOnConfirmConfigurationThenSave()
    var
        PostcodeConfigurationPage: TestPage "Postcode Configuration Page GB";
    begin
        // [GIVEN] we have a config page open and invoke lookup page
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();
        LibraryVariableStorage.Enqueue('SELECT'); // Action for lookup page, what to do
        LibraryVariableStorage.Enqueue(2); // Which record id lookup page should select
        PostcodeConfigurationPage.OpenEdit();
        PostcodeConfigurationPage.SelectedService.Lookup();

        // [WHEN] when we open a selection and cancel it
        // ServiceLookupHandler takes over

        // [THEN] value should remain the same
        Assert.AreEqual(DummyServiceTok, PostcodeConfigurationPage.SelectedService.Value, 'Value should be updated to new one');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRegularUserHasNoWriteAccess()
    var
        PostcodeServiceConfig: Record "Postcode Service Config";
    begin
        // [GIVEN] we have a basic user
        Initialize();
        LibraryLowerPermissions.SetO365Basic();

        // [WHEN] a user tries to create a config entry
        PostcodeServiceConfig.Init();
        asserterror PostcodeServiceConfig.Insert();

        // [THEN] he should get an error
        Assert.ExpectedError(
            StrSubstno('Sorry, the current permissions prevented the action. (TableData 9091 %1 Insert:', PostcodeServiceConfig.TableCaption()));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRegularuserHasReadAccess()
    var
        PostcodeServiceConfig: Record "Postcode Service Config";
    begin
        // [GIVEN] we have a postcode config entry
        Initialize();
        LibraryLowerPermissions.SetO365BusFull();
        PostcodeServiceConfig.Init();
        PostcodeServiceConfig.Insert();

        // we have a regular user who tries to access it
        LibraryLowerPermissions.SetO365Basic();

        // [WHEN] we try to access it
        PostcodeServiceConfig.FindFirst();

        // [THEN] everything is ok
    end;

    [Scope('OnPrem')]
    procedure Initialize()
    var
        PostcodeServiceConfig: Record "Postcode Service Config";
    begin
        PostcodeServiceConfig.DeleteAll();
        Commit();

        if not Initialized then begin
            BindSubscription(PostcodeDummyService);
            Initialized := true;
        end;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ServiceLookupHandler(var PostcodeServiceLookup: TestPage "Postcode Service Lookup GB")
    var
        "Action": Text;
    begin
        Action := LibraryVariableStorage.DequeueText();
        if Action = 'CANCEL' then
            PostcodeServiceLookup.Cancel().Invoke()
        else
            if Action = 'SELECT' then begin
                PostcodeServiceLookup.GotoKey(LibraryVariableStorage.DequeueInteger());
                PostcodeServiceLookup.OK().Invoke();
            end
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;
}
#endif

