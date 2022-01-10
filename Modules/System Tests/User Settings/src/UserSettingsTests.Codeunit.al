codeunit 132905 "User Settings Tests"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;
    Permissions = tabledata "Tenant Profile" = rm,
                  tabledata "User Personalization" = rim,
                  tabledata "Windows Language" = r;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        CompanyDisplayNameTxt: Label 'Company display name';

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CorrectLanguageLoaded()
    var
        UserSettingsPage: TestPage "User Settings";
    begin
        PermissionsMock.Set('User Settings View');

        SetLanguageInUserPersonalization(1082);

        UserSettingsPage.OpenView();
        Assert.AreEqual('Maltese (Malta)',
          UserSettingsPage.LanguageName.Value(),
          'My Settings did not load correct language from User Personalization.');
        UserSettingsPage.Close();
    end;

    [Test]
    [HandlerFunctions('HandleSelectAvailableLanguages,StandardSessionSettingsHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ModifyLanguageOK()
    var
        WindowsLanguage: Record "Windows Language";
        UserSettingsPage: TestPage "User Settings";
    begin
        PermissionsMock.Set('User Settings View');

        SetLanguageInUserPersonalization(1082);
        WindowsLanguage.Get(GlobalLanguage);

        UserSettingsPage.OpenEdit();
        UserSettingsPage.LanguageName.AssistEdit();
        Assert.AreEqual(WindowsLanguage.Name,
          UserSettingsPage.LanguageName.Value(),
          'The Language field should change after selecting in the Lookup.');
        UserSettingsPage.OK().Invoke();
        Assert.AreEqual(WindowsLanguage.Name,
          GetLanguageFromUserPersonalization(),
          'The user''s Language should be updated in the User Personalization table after closing My Settings.');
    end;

    [Test]
    [HandlerFunctions('HandleCancelAvailableLanguages')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ModifyLanguageCancel()
    var
        UserSettingsPage: TestPage "User Settings";
    begin
        PermissionsMock.Set('User Settings View');

        SetLanguageInUserPersonalization(1082);

        UserSettingsPage.OpenEdit();
        UserSettingsPage.LanguageName.AssistEdit();
        Assert.AreEqual('Maltese (Malta)',
          UserSettingsPage.LanguageName.Value(),
          'Canceling the lookup should not modify the user''s language.');
        UserSettingsPage.Close();
        Assert.AreEqual('Maltese (Malta)',
          GetLanguageFromUserPersonalization(),
          'Closing My Settings should not modify user''s language.');
    end;

    [Test]
    [HandlerFunctions('AccessibleCompaniesReturnsDisplayNameModalHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AccessibleCompaniesDisplayName()
    var
        UserSettings: TestPage "User Settings";
        ActualName: Text;
    begin
        // [GIVEN] The current company, where "Name" is 'A', "Display Name" is 'X'
        SetDisplayName(CompanyDisplayNameTxt);

        PermissionsMock.Set('User Settings View');

        // [GIVEN] "My Settings" page is open
        UserSettings.OpenView();
        // [WHEN] Click on "Company" control
        UserSettings.Company.AssistEdit();
        // [THEN] Page "Accessible Companies" is open, where "Name" is 'X'
        ActualName := LibraryVariableStorage.DequeueText(); // sent by AccessibleCompaniesReturnsDisplayNameModalHandler
        Assert.AreEqual(CompanyDisplayNameTxt, ActualName, 'Wrong Name on Accessible Companies page');
    end;

    [Test]
    [HandlerFunctions('AccessibleCompaniesReturnsDisplayNameModalHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AccessibleCompaniesBlankDisplayName()
    var
        UserSettings: TestPage "User Settings";
        ActualName: Text;
    begin
        // [GIVEN] The current company, where "Name" is 'A', "Display Name" is <blank>
        SetDisplayName('');
        PermissionsMock.Set('User Settings View');
        // [GIVEN] "My Settings" page is open
        UserSettings.OpenView();
        // [WHEN] Click on "Company" control
        UserSettings.Company.AssistEdit();
        // [THEN] Page "Accessible Companies" is open, where "Name" is CompanyName
        ActualName := LibraryVariableStorage.DequeueText(); // sent by AccessibleCompaniesReturnsDisplayNameModalHandler
        Assert.AreEqual(CompanyName(), ActualName, 'Wrong Name on Accessible Companies page');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestDefaultSettingsPageId()
    var
        UserSettings: Codeunit "User Settings";
    begin
        // [SCENARIO] The default settings page is User Settings
        PermissionsMock.Set('User Settings View');
        Assert.AreEqual(Page::"User Settings", UserSettings.GetPageId(), 'A different page id was expected');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSettingsPageIdCanBeChanged()
    var
        UserSettings: Codeunit "User Settings";
        UserSettingsTests: Codeunit "User Settings Tests";
    begin
        // [SCENARIO] The settings page can be changed
        BindSubscription(UserSettingsTests);

        PermissionsMock.Set('User Settings View');

        Assert.AreEqual(Page::"User Settings List", UserSettings.GetPageId(), 'A different page id was expected');
        UnBindSubscription(UserSettingsTests);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestDefaultSettings()
    var
        UserSettingsRec: Record "User Settings";
        TenantProfileSettings: Record "Tenant Profile Setting";
        LibraryUserSettings: Codeunit "Library - User Settings";
        UserSettings: Codeunit "User Settings";
    begin
        // [SCENARIO] The Default settings for a user have a certain value.

        // [GIVEN] There is no default profile selected.
        TenantProfileSettings.ModifyAll("Default Role Center", false);

        // [GIVEN] There are no settings for the User.
        LibraryUserSettings.ClearCurrentUserSettings();

        PermissionsMock.Set('User Settings View');

        // [WHEN] GetUSerSettings is called
        UserSettings.GetUserSettings(UserSecurityId(), UserSettingsRec);

        // [THEN] The default user Settings are populated
        Assert.AreEqual(UserSecurityId(), UserSettingsRec."User Security ID", 'The current user''s id was expected.');
        Assert.IsTrue(UserSettingsRec.Initialized, 'The settings should have been initialized.');
        Assert.AreEqual(0, UserSettingsRec."Language ID", 'No language was expected.');
        Assert.AreEqual(CompanyName(), UserSettingsRec.Company, 'Company should match CompanyName (<Blank Company>).');
        Assert.AreEqual(0, UserSettingsRec."Locale ID", 'No region was expected.');
        Assert.AreEqual('', UserSettingsRec."Time Zone", 'A different time zone was expected.');
        Assert.AreEqual(WorkDate(), UserSettingsRec."Work Date", 'A different work date was expected.');
        Assert.IsTrue(UserSettingsRec."Teaching Tips", 'Teaching tips should be enabled.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestDefaultProfileSettings()
    var
        TenantProfileSetting: Record "Tenant Profile Setting";
        UserSettingsRec: Record "User Settings";
        LibraryUserSettings: Codeunit "Library - User Settings";
        UserSettings: Codeunit "User Settings";
        AppId: Guid;
    begin
        // [SCENARIO] Default Profile is shown when No Profile is Selected

        // [GIVEN] There are no settings for the User.
        LibraryUserSettings.ClearCurrentUserSettings();
        // [GIVEN] The Test Profile is selected as default
        TenantProfileSetting.DeleteAll();
        TenantProfileSetting."App ID" := '23de40a6-dfe8-4f80-80db-d70f83ce8caf';
        TenantProfileSetting."Profile ID" := 'TestRoleCenter';
        TenantProfileSetting."Default Role Center" := true;
        TenantProfileSetting.Insert();

        PermissionsMock.Set('User Settings View');

        // [WHEN] GetUSerSettings is called
        UserSettings.GetUserSettings(UserSecurityId(), UserSettingsRec);

        // [THEN] The blank profile shows
        Assert.AreEqual('TESTROLECENTER', UserSettingsRec."Profile ID", 'A different profile was expected');
        AppId := '23de40a6-dfe8-4f80-80db-d70f83ce8caf';
        Assert.AreEqual(AppId, UserSettingsRec."App ID", 'A different app id was expected');
        Assert.AreEqual(UserSettingsRec.Scope::Tenant, UserSettingsRec.Scope, 'A different profile was expected');
    end;

    [Test]
    procedure TestEnableTeachingTips()
    var
        UserSettingsRec: Record "User Settings";
        UserSettings: Codeunit "User Settings";
    begin
        // exercise
        UserSettings.EnableTeachingTips(UserSecurityId());

        // validate
        UserSettings.GetUserSettings(UserSecurityId(), UserSettingsRec);
        Assert.IsTrue(UserSettingsRec."Teaching Tips", 'Teaching Tips should have been enabled.');
    end;

    [Test]
    procedure TestDisableTeachingTips()
    var
        UserSettingsRec: Record "User Settings";
        UserSettings: Codeunit "User Settings";
    begin
        // exercise
        UserSettings.DisableTeachingTips(UserSecurityId());

        // validate
        UserSettings.GetUserSettings(UserSecurityId(), UserSettingsRec);
        Assert.IsFalse(UserSettingsRec."Teaching Tips", 'Teaching Tips should have been disabled.');
    end;

    [Test]
    procedure TestUpdateSettingsOK()
    var
        UserSettingsTests: Codeunit "User Settings Tests";
        UserSettings: TestPage "User Settings";
    begin
        // [SCENARIO] When user clicks OK in user settings page then the OnUpdateSettings Event fires.
        BindSubscription(UserSettingsTests);
        PermissionsMock.Set('User Settings View');

        UserSettings.OpenView();
        UserSettings.Ok().Invoke();

        asserterror UserSettingsTests.AssertEmptyStorage();
        UnBindSubscription(UserSettingsTests);
    end;

    [Test]
    procedure TestUpdateSettingsCancel()
    var
        UserSettingsTests: Codeunit "User Settings Tests";
        UserSettings: TestPage "User Settings";
    begin
        // [SCENARIO] When user clicks Cancel in user settings page then the OnUpdateSettings Event does not fire.
        BindSubscription(UserSettingsTests);
        PermissionsMock.Set('User Settings View');

        UserSettings.OpenView();
        UserSettings.Cancel().Invoke();

        UserSettingsTests.AssertEmptyStorage();
        UnBindSubscription(UserSettingsTests);
    end;

    procedure AssertEmptyStorage()
    begin
        LibraryVariableStorage.AssertEmpty();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"User Settings", 'OnUpdateUserSettings', '', true, true)]
    local procedure OnUpdateUserSettings(OldSettings: Record "User Settings"; NewSettings: Record "User Settings")
    begin
        LibraryVariableStorage.Enqueue('Dummy');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"User Settings", 'OnGetSettingsPageID', '', true, true)]
    local procedure OnGetSettingsPageID(var SettingsPageID: Integer)
    begin
        SettingsPageID := Page::"User Settings List";
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure HandleSelectAvailableLanguages(var WindowsLanguages: Page "Windows Languages"; var Response: Action)
    var
        WindowsLanguage: Record "Windows Language";
    begin
        WindowsLanguage.Get(GlobalLanguage);
        WindowsLanguages.SetRecord(WindowsLanguage);
        Response := ACTION::LookupOK;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure HandleCancelAvailableLanguages(var WindowsLanguages: Page "Windows Languages"; var Response: Action)
    begin
        Response := ACTION::LookupCancel;
    end;

    local procedure GetLanguageFromUserPersonalization(): Text
    var
        UserPersonalization: Record "User Personalization";
        WindowsLanguage: Record "Windows Language";
    begin
        UserPersonalization.Get(UserSecurityId());
        WindowsLanguage.Get(UserPersonalization."Language ID");
        exit(WindowsLanguage.Name);
    end;

    local procedure SetLanguageInUserPersonalization(ID: Integer)
    var
        UserPersonalization: Record "User Personalization";
    begin
        UserPersonalization.Get(UserSecurityId());
        UserPersonalization."Language ID" := ID;
        UserPersonalization.Modify();
    end;

    [SessionSettingsHandler]
    procedure StandardSessionSettingsHandler(var TestSessionSettings: SessionSettings): Boolean
    begin
        exit(false);
    end;

    local procedure SetDisplayName(DisplayName: Text[250])
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName);
        Company."Display Name" := DisplayName;
        Company.Modify();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure AccessibleCompaniesReturnsDisplayNameModalHandler(var AccessibleCompanies: TestPage "Accessible Companies")
    begin
        LibraryVariableStorage.Enqueue(AccessibleCompanies.CompanyDisplayName.Value);
        AccessibleCompanies.Cancel().Invoke();
    end;

}

