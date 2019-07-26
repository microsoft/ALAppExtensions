codeunit 132911 "Azure AD Graph User Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        AzureADGraphUser: Codeunit "Azure AD Graph User";
        AzureADGraphUserTest: Codeunit "Azure AD Graph User Test";
        LibraryAssert: Codeunit "Library Assert";
        EnvironmentInfo: Codeunit "Environment Information";
        MockGraphQuery: DotNet MockGraphQuery;

        NewAADUserIdLbl: Label '6D59EA6C-BD8c-4694-A839-FE5C70089021';
        AADUserIdWithEmptyObjectIdLbl: Label '28E0F872-F014-4EA4-B47D-6AF6F13B3FE1';
        AADUserWithEmptySurnameUserIdLbl: Label 'A0F61055-D58F-4D6D-B96B-7A147B0D131A';

        NewAADUserObjectIdLbl: Label 'New AAD User Object Id';
        CurrentUserObjectIdLbl: Label 'Current User Object Id';
        AADUserWithEmptySurnameObjectIdLbl: Label 'Empty Surname User Object Id';

        CurrentUserSurnameLbl: Label 'Current User Surname';
        NewAADUserSurnameLbl: Label 'New User Surname';

        CurrentUserDisplayNameLbl: Label 'Current User Display Name';
        NewAADUserDisplayNameLbl: Label 'New User Display Name';

        CurrentUserEmailLbl: Label 'Current User Email';
        NewAADUserEmailLbl: Label 'newemail@microsoft.com';

        CurrentUserPrincipalNameLbl: Label 'Current User Principal Name';
        NewAADUserPrincipalNameLbl: Label 'principal@microsoft.com';

        CurrentUserGivenNameLbl: Label 'Current User Given Name';
        NewAADUserGivenNameLbl: Label 'New User Given Name';
        AADUserGivenNameForUserWithEmptySurnameLbl: Label 'Empty Surname User Given Name';

        CurrentUserPreferredLanguageLbl: Label 'Current User Preferred Language';
        NewAADUserPreferredLanguageLbl: Label 'New User Preferred Language';

    [Normal]
    local procedure Initialize()
    var
        UserProperty: Record "User Property";
    begin
        Clear(AzureADGraphUser);
        UserProperty.DeleteAll();

        AzureADGraphUser.SetTestInProgress(true);
        EnvironmentInfo.SetTestabilitySoftwareAsAService(true);

        AzureADGraphUserTest.SetupMockGraphQuery();

        BindSubscription(AzureADGraphUserTest);
    end;

    local procedure TearDown()
    begin
        AzureADGraphUser.SetTestInProgress(false);
        EnvironmentInfo.SetTestabilitySoftwareAsAService(false);

        UnbindSubscription(AzureADGraphUserTest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 9012, 'OnInitialize', '', false, false)]
    local procedure OnGraphInitialization(var GraphQuery: DotNet GraphQuery)
    begin
        GraphQuery := GraphQuery.GraphQuery(MockGraphQuery);
    end;

    procedure SetupMockGraphQuery()
    var
        UserInfo: DotNet UserInfo;
    begin
        MockGraphQuery := MockGraphQuery.MockGraphQuery();

        CreateAzureADUser(UserInfo, UserSecurityId(), CurrentUserObjectIdLbl, CurrentUserSurnameLbl, CurrentUserDisplayNameLbl,
            CurrentUserEmailLbl, CurrentUserPrincipalNameLbl, CurrentUserGivenNameLbl, CurrentUserPreferredLanguageLbl, false);
        MockGraphQuery.CurrentUserUserObject := UserInfo;

        CreateAzureADUser(UserInfo, NewAADUserIdLbl, NewAADUserObjectIdLbl, NewAADUserSurnameLbl, NewAADUserDisplayNameLbl,
            NewAADUserEmailLbl, NewAADUserPrincipalNameLbl, NewAADUserGivenNameLbl, NewAADUserPreferredLanguageLbl, true);
        CreateAzureADUser(UserInfo, AADUserIdWithEmptyObjectIdLbl, '', '', '', '', '', '', '', false);
        CreateAzureADUser(UserInfo, AADUserWithEmptySurnameUserIdLbl, AADUserWithEmptySurnameObjectIdLbl, '', '', '', '',
            AADUserGivenNameForUserWithEmptySurnameLbl, '', false);
    end;

    [Normal]
    local procedure CreateAzureADUser(var UserInfo: DotNet UserInfo; UserSecurityId: Guid; ObjectId: Text; Surname: Text; DisplayName: Text; Email: Text; PrincipalName: Text; GivenName: Text; PreferredLanguage: Text; AccountEnabled: Boolean)
    begin
        CreateUserProperty(UserSecurityId, ObjectId);

        CreateUserInfo(UserInfo, ObjectId, Surname, DisplayName, Email, PrincipalName,
            GivenName, PreferredLanguage, AccountEnabled);

        MockGraphQuery.AddUser(UserInfo);
    end;

    local procedure CreateUserProperty(UserSecurityId: Guid; AuthenticationObjectId: Text)
    var
        UserProperty: Record "User Property";
    begin
        UserProperty.Init();

        UserProperty."User Security ID" := UserSecurityId;
        UserProperty."Authentication Object ID" := CopyStr(AuthenticationObjectId, 1, 80);

        UserProperty.Insert();
    end;

    local procedure CreateUserInfo(var UserInfo: DotNet UserInfo; ObjectId: Text; Surname: Text; DisplayName: Text; Email: Text; PrincipalName: Text; GivenName: Text; PreferredLanguage: Text; AccountEnabled: Boolean)
    begin
        UserInfo := UserInfo.UserInfo();

        UserInfo.ObjectId := ObjectId;
        UserInfo.Surname := Surname;
        UserInfo.DisplayName := DisplayName;
        UserInfo.Mail := Email;
        UserInfo.UserPrincipalName := PrincipalName;
        UserInfo.GivenName := GivenName;
        UserInfo.PreferredLanguage := PreferredLanguage;
        UserInfo.AccountEnabled := AccountEnabled;
    end;

    [Normal]
    local procedure InsertUser(var User: Record User; UserSecurityId: Guid; Enabled: Boolean; FullName: Text; ContactEmail: Text; AuthenticationEmail: Text; UserName: Text)
    begin
        User.Init();

        User."User Security ID" := UserSecurityId;
        User."Full Name" := CopyStr(FullName, 1, 80);
        User."Contact Email" := CopyStr(ContactEmail, 1, 80);
        User."Authentication Email" := CopyStr(AuthenticationEmail, 1, 80);
        User."User Name" := CopyStr(UserName, 1, 50);

        if Enabled then
            User.State := User.State::Enabled
        else
            User.State := User.State::Disabled;

        User.Insert();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestSetGraphUserForTheCurrentUser()
    var
        IsGraphUserNull: Boolean;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the current user
        AzureADGraphUser.SetGraphUser(UserSecurityId());

        // [WHEN] Checking whether the graph user is null
        IsGraphUserNull := AzureADGraphUser.IsGraphUserNull();

        // [THEN] The result should be false
        LibraryAssert.IsFalse(IsGraphUserNull, 'The graph user should not be null');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestSetGraphUserrForAnInexistentUser()
    var
        IsGraphUserNull: Boolean;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as an inexistent user
        // [THEN] An error should occur, as the user does not exist
        asserterror AzureADGraphUser.SetGraphUser(CreateGuid());

        // [WHEN] Checking whether the graph user is null
        IsGraphUserNull := AzureADGraphUser.IsGraphUserNull();

        // [THEN] The result should be true
        LibraryAssert.IsTrue(IsGraphUserNull, 'The graph user should be null');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestSetGraphUserForANewUserWithNonEmptyObjectId()
    var
        IsGraphUserNull: Boolean;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the newly created user
        AzureADGraphUser.SetGraphUser(NewAADUserIdLbl);

        // [WHEN] Checking whether the graph user is null
        IsGraphUserNull := AzureADGraphUser.IsGraphUserNull();

        // [THEN] The result should be false
        LibraryAssert.IsFalse(IsGraphUserNull, 'The graph user should not be null');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestSetGraphUserForANewUserWithEmptyObjectId()
    var
        IsGraphUserNull: Boolean;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as a user with an empty object id
        // [THEN] An error should occur
        asserterror AzureADGraphUser.SetGraphUser(AADUserIdWithEmptyObjectIdLbl);

        // [WHEN] Checking whether the graph user is null
        IsGraphUserNull := AzureADGraphUser.IsGraphUserNull();

        // [THEN] The result should be true
        LibraryAssert.IsTrue(IsGraphUserNull, 'The graph user should be null');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetObjectIdForCurrentUser()
    var
        GraphUserObjectId: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the current user
        AzureADGraphUser.SetGraphUser(UserSecurityId());

        // [WHEN] Getting the object id of the graph user
        GraphUserObjectId := AzureADGraphUser.GetObjectId();

        // [THEN] The object id should not be the empty string
        LibraryAssert.AreEqual(CurrentUserObjectIdLbl, GraphUserObjectId, 'The object id is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetObjectIdForAnInexistentUser()
    var
        ObjectId: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as an inexistent user
        // [THEN] An error should occur, as the user does not exist
        asserterror AzureADGraphUser.SetGraphUser(CreateGuid());

        // [WHEN] Getting the object id of the graph user
        ObjectId := AzureADGraphUser.GetObjectId();

        // [THEN] The object id should be the empty string
        LibraryAssert.AreEqual('', ObjectId, 'The object id is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetObjectIdForANewUser()
    var
        GraphObjectId: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the new user
        AzureADGraphUser.SetGraphUser(NewAADUserIdLbl);

        // [WHEN] Getting the object id of the graph user
        GraphObjectId := AzureADGraphUser.GetObjectId();

        // [THEN] The object id should be the id of the new user
        LibraryAssert.AreEqual(NewAADUserObjectIdLbl, GraphObjectId, 'The object id is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsAccountDisabledForCurrentUser()
    var
        IsAccountDisabled: Boolean;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the current user
        AzureADGraphUser.SetGraphUser(UserSecurityId());

        // [WHEN] Checking whether the account is disabled for the user
        IsAccountDisabled := AzureADGraphUser.IsAccountDisabled();

        // [THEN] The result should be true
        LibraryAssert.IsTrue(IsAccountDisabled, 'The account should be disabled');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsAccountDisabledForAnInexistentUser()
    var
        IsAccountDisabled: Boolean;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as an inexistent user
        // [THEN] An error should occur, as the user does not exist
        asserterror AzureADGraphUser.SetGraphUser(CreateGuid());

        // [WHEN] Checking whether the account is disabled for the user
        IsAccountDisabled := AzureADGraphUser.IsAccountDisabled();

        // [THEN] The result should be false, as the user does not exist
        LibraryAssert.IsFalse(IsAccountDisabled, 'The user does not exist');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsAccountDisabledForANewUser()
    var
        IsAccountDisabled: Boolean;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the new user
        AzureADGraphUser.SetGraphUser(NewAADUserIdLbl);

        // [WHEN] Checking whether the account is disabled for the user
        IsAccountDisabled := AzureADGraphUser.IsAccountDisabled();

        // [THEN] The result should be false
        LibraryAssert.IsFalse(IsAccountDisabled, 'The account should not be disabled');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsAccountEnabledForCurrentUser()
    var
        IsAccountEnabled: Boolean;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the current user
        AzureADGraphUser.SetGraphUser(UserSecurityId());

        // [WHEN] Checking whether the account is enabled for the user
        IsAccountEnabled := AzureADGraphUser.IsAccountEnabled();

        // [THEN] The result should be false
        LibraryAssert.IsFalse(IsAccountEnabled, 'The account should not be enabled');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsAccountEnabledForAnInexistentUser()
    var
        IsAccountEnabled: Boolean;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as an inexistent user
        // [THEN] An error should occur, as the user does not exist
        asserterror AzureADGraphUser.SetGraphUser(CreateGuid());

        // [WHEN] Checking whether the account is enabled for the user
        IsAccountEnabled := AzureADGraphUser.IsAccountEnabled();

        // [THEN] The result should be false, as the user does not exist
        LibraryAssert.IsFalse(IsAccountEnabled, 'The user does not exist');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsAccountEnabledForANewUser()
    var
        IsAccountEnabled: Boolean;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the new user
        AzureADGraphUser.SetGraphUser(NewAADUserIdLbl);

        // [WHEN] Checking whether the account is enabled for the user
        IsAccountEnabled := AzureADGraphUser.IsAccountEnabled();

        // [THEN] The result should be true
        LibraryAssert.IsTrue(IsAccountEnabled, 'The account should be enabled');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetSurnameForCurrentUser()
    var
        Surname: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the current user
        AzureADGraphUser.SetGraphUser(UserSecurityId());

        // [WHEN] Getting the surname for the user
        Surname := AzureADGraphUser.GetSurname();

        // [THEN] The result should be the current user's surname
        LibraryAssert.AreEqual(CurrentUserSurnameLbl, Surname, 'The surname is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetSurnameForAnInexistentUser()
    var
        Surname: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as an inexistent user
        // [THEN] An error should occur, as the user does not exist
        asserterror AzureADGraphUser.SetGraphUser(CreateGuid());

        // [WHEN] Getting the surname for the user
        Surname := AzureADGraphUser.GetSurname();

        // [THEN] The result should be the empty string
        LibraryAssert.AreEqual('', Surname, 'The surname is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetSurnameForANewUser()
    var
        Surname: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the new user
        AzureADGraphUser.SetGraphUser(NewAADUserIdLbl);

        // [WHEN] Getting the surname for the user
        Surname := AzureADGraphUser.GetSurname();

        // [THEN] The result should be the new user's surname
        LibraryAssert.AreEqual(NewAADUserSurnameLbl, Surname, 'The surname is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetDisplayNameForCurrentUser()
    var
        DisplayName: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the current user
        AzureADGraphUser.SetGraphUser(UserSecurityId());

        // [WHEN] Getting the display name for the user
        DisplayName := AzureADGraphUser.GetDisplayName();

        // [THEN] The result should be the current user's display name
        LibraryAssert.AreEqual(CurrentUserDisplayNameLbl, DisplayName, 'The display name is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetDisplayNameForAnInexistentUser()
    var
        DisplayName: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as an inexistent user
        // [THEN] An error should occur, as the user does not exist
        asserterror AzureADGraphUser.SetGraphUser(CreateGuid());

        // [WHEN] Getting the display name for the user
        DisplayName := AzureADGraphUser.GetDisplayName();

        // [THEN] The result should be the empty string
        LibraryAssert.AreEqual('', DisplayName, 'The display name is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetDisplayNameForANewUser()
    var
        DisplayName: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the new user
        AzureADGraphUser.SetGraphUser(NewAADUserIdLbl);

        // [WHEN] Getting the display name for the user
        DisplayName := AzureADGraphUser.GetDisplayName();

        // [THEN] The result should be the display name of the new user
        LibraryAssert.AreEqual(NewAADUserDisplayNameLbl, DisplayName, 'The display name is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetEmailForCurrentUser()
    var
        Email: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the current user
        AzureADGraphUser.SetGraphUser(UserSecurityId());

        // [WHEN] Getting the email for the user
        Email := AzureADGraphUser.GetEmail();

        // [THEN] The result should be the current user's email
        LibraryAssert.AreEqual(CurrentUserEmailLbl, Email, 'The email is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetEmailForAnInexistentUser()
    var
        Email: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as an inexistent user
        // [THEN] An error should occur, as the user does not exist
        asserterror AzureADGraphUser.SetGraphUser(CreateGuid());

        // [WHEN] Getting the email for the user
        Email := AzureADGraphUser.GetEmail();

        // [THEN] The result should be the empty string
        LibraryAssert.AreEqual('', Email, 'The email is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetEmailForANewUser()
    var
        Email: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the new user
        AzureADGraphUser.SetGraphUser(NewAADUserIdLbl);

        // [WHEN] Getting the email for the user
        Email := AzureADGraphUser.GetEmail();

        // [THEN] The result should be the new user's email
        LibraryAssert.AreEqual(NewAADUserEmailLbl, Email, 'The email is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetUserPrincipalNameForCurrentUser()
    var
        UserPrincipalName: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the current user
        AzureADGraphUser.SetGraphUser(UserSecurityId());

        // [WHEN] Getting the user principal name for the user
        UserPrincipalName := AzureADGraphUser.GetUserPrincipalName();

        // [THEN] The result should be the current user's user principal name
        LibraryAssert.AreEqual(CurrentUserPrincipalNameLbl, UserPrincipalName,
            'The user principal name is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetUserPrincipalNameForAnInexistentUser()
    var
        UserPrincipalName: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as an inexistent user
        // [THEN] An error should occur, as the user does not exist
        asserterror AzureADGraphUser.SetGraphUser(CreateGuid());

        // [WHEN] Getting the user principal name for the user
        UserPrincipalName := AzureADGraphUser.GetUserPrincipalName();

        // [THEN] The result should be the empty string
        LibraryAssert.AreEqual('', UserPrincipalName, 'The user principal name is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetUserPrincipalNameForANewUser()
    var
        UserPrincipalName: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the new user
        AzureADGraphUser.SetGraphUser(NewAADUserIdLbl);

        // [WHEN] Getting the user principal name for the user
        UserPrincipalName := AzureADGraphUser.GetUserPrincipalName();

        // [THEN] The result should be the new user's user principal name
        LibraryAssert.AreEqual(NewAADUserPrincipalNameLbl, UserPrincipalName,
            'The user principal name is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetUserGivenNameForCurrentUser()
    var
        UserGivenName: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the current user
        AzureADGraphUser.SetGraphUser(UserSecurityId());

        // [WHEN] Getting the given name for the user
        UserGivenName := AzureADGraphUser.GetGivenName();

        // [THEN] The result should be the current user's given name
        LibraryAssert.AreEqual(CurrentUserGivenNameLbl, UserGivenName, 'The given name is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetUserGivenNameForAnInexistentUser()
    var
        UserGivenName: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as an inexistent user
        // [THEN] An error should occur, as the user does not exist
        asserterror AzureADGraphUser.SetGraphUser(CreateGuid());

        // [WHEN] Getting the given name for the user
        UserGivenName := AzureADGraphUser.GetGivenName();

        // [THEN] The result should be the empty string
        LibraryAssert.AreEqual('', UserGivenName, 'The given name is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetUserGivenNameForANewUser()
    var
        UserGivenName: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the new user
        AzureADGraphUser.SetGraphUser(NewAADUserIdLbl);

        // [WHEN] Getting the given name for the user
        UserGivenName := AzureADGraphUser.GetGivenName();

        // [THEN] The result should be the new user's given name
        LibraryAssert.AreEqual(NewAADUserGivenNameLbl, UserGivenName, 'The given name is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetPreferredLanguageForCurrentUser()
    var
        PreferredLanguage: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the current user
        AzureADGraphUser.SetGraphUser(UserSecurityId());

        // [WHEN] Getting the preferred language for the user
        PreferredLanguage := AzureADGraphUser.GetPreferredLanguage();

        // [THEN] The result should be the current user's preferred language
        LibraryAssert.AreEqual(CurrentUserPreferredLanguageLbl, PreferredLanguage,
            'The preferred language is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetPreferredLanguageForAnInexistentUser()
    var
        PreferredLanguage: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as an inexistent user
        // [THEN] An error should occur, as the user does not exist
        asserterror AzureADGraphUser.SetGraphUser(CreateGuid());

        // [WHEN] Getting the preferred language for the user
        PreferredLanguage := AzureADGraphUser.GetPreferredLanguage();

        // [THEN] The result should be the empty string
        LibraryAssert.AreEqual('', PreferredLanguage, 'The preferred language is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetPreferredLanguageForANewUser()
    var
        PreferredLanguage: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the new user
        AzureADGraphUser.SetGraphUser(NewAADUserIdLbl);

        // [WHEN] Getting the preferred language for the user
        PreferredLanguage := AzureADGraphUser.GetPreferredLanguage();

        // [THEN] The result should be the new user's preferred language
        LibraryAssert.AreEqual(NewAADUserPreferredLanguageLbl, PreferredLanguage,
            'The preferred language is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetUserFullNameForCurrentUser()
    var
        UserFullName: Text;
        AzureADFullName: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the current user
        AzureADGraphUser.SetGraphUser(UserSecurityId());

        // [WHEN] Getting the full name for the user
        UserFullName := AzureADGraphUser.GetUserFullName();

        // [THEN] The result should be the current user's full name
        AzureADFullName := StrSubstNo('%1 %2', CurrentUserGivenNameLbl, CurrentUserSurnameLbl);
        LibraryAssert.AreEqual(AzureADFullName, UserFullName, 'The full name is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetUserFullNameForAnInexistentUser()
    var
        UserFullName: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as an inexistent user
        // [THEN] An error should occur, as the user does not exist
        asserterror AzureADGraphUser.SetGraphUser(CreateGuid());

        // [WHEN] Getting the full name for the user
        UserFullName := AzureADGraphUser.GetUserFullName();

        // [THEN] The result should be the empty string
        LibraryAssert.AreEqual('', UserFullName, 'The full name is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetUserFullNameForANewUser()
    var
        UserFullName: Text;
        AzureADFullName: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the new user
        AzureADGraphUser.SetGraphUser(NewAADUserIdLbl);

        // [WHEN] Getting the full name for the user
        UserFullName := AzureADGraphUser.GetUserFullName();

        // [THEN] The result should be the new user's full name
        AzureADFullName := StrSubstNo('%1 %2', NewAADUserGivenNameLbl, NewAADUserSurnameLbl);
        LibraryAssert.AreEqual(AzureADFullName, UserFullName, 'The full name is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetUserFullNameForAUserWithEmptySurname()
    var
        UserFullName: Text;
    begin
        Initialize();

        // [WHEN] Trying to set the graph user as the user with empty surname
        AzureADGraphUser.SetGraphUser(AADUserWithEmptySurnameUserIdLbl);

        // [WHEN] Getting the full name for the user
        UserFullName := AzureADGraphUser.GetUserFullName();

        // [THEN] The result should be the new user's full name
        LibraryAssert.AreEqual(AADUserGivenNameForUserWithEmptySurnameLbl, UserFullName, 'The full name is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestUpdateUserFromAzureGraphForAnInexistentAADUser()
    var
        User: Record User;
        UserSecurityId: Guid;
        UserFullName: Text;
        UserContactEmail: Text;
        UserAuthenticationEmail: Text;
        UserName: Text;
        IsUserModified: Boolean;
    begin
        Initialize();

        // [GIVEN] A user security id, full name, contact email and authentication email
        UserSecurityId := CreateGuid();
        UserFullName := 'user full name 123';
        UserContactEmail := 'contact_email@microsoft.com';
        UserAuthenticationEmail := 'authentication_email@microsoft.com';
        UserName := 'username';

        // [GIVEN] A new user
        User.DeleteAll();
        InsertUser(User, UserSecurityId, true, UserFullName, UserContactEmail,
            UserAuthenticationEmail, UserName);

        // [WHEN] Trying to set the graph user as an inexistent AAD user
        // [THEN] An error should occur, as the user does not exist
        asserterror AzureADGraphUser.SetGraphUser(UserSecurityId);

        // [WHEN] Updating the user from the Azure Graph
        IsUserModified := AzureADGraphUser.UpdateUserFromAzureGraph(User);

        // [THEN] IsUserModified should be false, as the user does not exist in the Azure Graph
        LibraryAssert.IsFalse(IsUserModified, 'The user should not exist in the Azure Graph');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestUpdateUserFromAzureGraphForAValidUserWithoutUpdates()
    var
        User: Record User;
        UserSecurityId: Guid;
        UserFullName: Text;
        UserName: Text;
        IsUserModified: Boolean;
    begin
        Initialize();

        // [GIVEN] A user security id, full name, contact email and authentication email
        UserSecurityId := CreateGuid();
        UserFullName := StrSubstNo('%1 %2', NewAADUserGivenNameLbl, NewAADUserSurnameLbl);
        UserName := 'username';

        // [WHEN] Trying to set the graph user as the new user
        AzureADGraphUser.SetGraphUser(NewAADUserIdLbl);

        // [GIVEN] A new user
        User.DeleteAll();
        InsertUser(User, NewAADUserIdLbl, true, UserFullName, NewAADUserEmailLbl, NewAADUserPrincipalNameLbl, UserName);

        // [WHEN] Updating the user from the Azure Graph
        IsUserModified := AzureADGraphUser.UpdateUserFromAzureGraph(User);

        // [THEN] IsUserModified should be false, as the user does not require updates
        LibraryAssert.IsFalse(IsUserModified, 'The user does not require any updates');

        // [THEN] The returned user should remain unchanged, as it does not require updates
        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(UserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserPrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        // [THEN] The database user should remain unchanged, as it does not require updates
        if User.Get(UserSecurityId) then;

        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(UserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserPrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        TearDown();
    end;

    [Test]
    // [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestUpdateUserFromAzureGraphForAValidUserWithUpdatedState()
    var
        User: Record User;
        UserSecurityId: Guid;
        UserFullName: Text;
        UserName: Text;
        ContactEmail: Text;
        AuthenticationEmail: Text;
        AADUserFullName: Text;
        IsUserModified: Boolean;
    begin
        Initialize();

        // [GIVEN] A user security id, full name, contact email and authentication email
        UserSecurityId := CreateGuid();
        UserFullName := 'full name 123';
        UserName := 'username';
        ContactEmail := 'contact_email1@microsoft.com';
        AuthenticationEmail := 'authentication_email@microsoft.com';

        // [WHEN] Trying to set the graph user as the new user
        AzureADGraphUser.SetGraphUser(NewAADUserIdLbl);

        // [GIVEN] A new user
        User.DeleteAll();
        InsertUser(User, NewAADUserIdLbl, false, UserFullName, ContactEmail, AuthenticationEmail, UserName);

        // [WHEN] Updating the user from the Azure Graph
        IsUserModified := AzureADGraphUser.UpdateUserFromAzureGraph(User);

        // [THEN] IsUserModified should be true, as the user requires updates
        LibraryAssert.IsTrue(IsUserModified, 'The user requires updates');

        // [THEN] The returned user should be updated
        AADUserFullName := StrSubstNo('%1 %2', NewAADUserGivenNameLbl, NewAADUserSurnameLbl);

        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(AADUserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserPrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        // [THEN] The database user should be updated
        if User.Get(UserSecurityId) then;

        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(AADUserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserPrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        TearDown();
    end;

    [Test]
    // [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestUpdateUserFromAzureGraphForAValidUserWithUpdatedFullName()
    var
        User: Record User;
        UserSecurityId: Guid;
        UserFullName: Text;
        UserName: Text;
        ContactEmail: Text;
        AuthenticationEmail: Text;
        AADUserFullName: Text;
        IsUserModified: Boolean;
    begin
        Initialize();

        // [GIVEN] A user security id, full name, contact email and authentication email
        UserSecurityId := CreateGuid();
        UserFullName := 'full name 123';
        UserName := 'username';
        ContactEmail := 'contact_email1@microsoft.com';
        AuthenticationEmail := 'authentication_email@microsoft.com';

        // [WHEN] Trying to set the graph user as the new user
        AzureADGraphUser.SetGraphUser(NewAADUserIdLbl);

        // [GIVEN] A new user
        User.DeleteAll();
        InsertUser(User, NewAADUserIdLbl, true, UserFullName, ContactEmail, AuthenticationEmail, UserName);

        // [WHEN] Updating the user from the Azure Graph
        IsUserModified := AzureADGraphUser.UpdateUserFromAzureGraph(User);

        // [THEN] IsUserModified should be true, as the user requires updates
        LibraryAssert.IsTrue(IsUserModified, 'The user requires updates');

        // [THEN] The returned user should be updated
        AADUserFullName := StrSubstNo('%1 %2', NewAADUserGivenNameLbl, NewAADUserSurnameLbl);

        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(AADUserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserPrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        // [THEN] The database user should be updated
        if User.Get(UserSecurityId) then;

        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(AADUserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserPrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        TearDown();
    end;

    [Test]
    // [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestUpdateUserFromAzureGraphForAValidUserWithUpdatedContactEmail()
    var
        User: Record User;
        UserSecurityId: Guid;
        UserFullName: Text;
        UserName: Text;
        ContactEmail: Text;
        AuthenticationEmail: Text;
        IsUserModified: Boolean;
    begin
        Initialize();

        // [GIVEN] A user security id, full name, contact email and authentication email
        UserSecurityId := CreateGuid();
        UserFullName := StrSubstNo('%1 %2', NewAADUserGivenNameLbl, NewAADUserSurnameLbl);
        UserName := 'username';
        ContactEmail := 'contact_email1@microsoft.com';
        AuthenticationEmail := 'authentication_email@microsoft.com';

        // [WHEN] Trying to set the graph user as the new user
        AzureADGraphUser.SetGraphUser(NewAADUserIdLbl);

        // [GIVEN] A new user
        User.DeleteAll();
        InsertUser(User, NewAADUserIdLbl, true, UserFullName, ContactEmail, AuthenticationEmail, UserName);

        // [WHEN] Updating the user from the Azure Graph
        IsUserModified := AzureADGraphUser.UpdateUserFromAzureGraph(User);

        // [THEN] IsUserModified should be true, as the user requires updates
        LibraryAssert.IsTrue(IsUserModified, 'The user requires updates');

        // [THEN] The returned user should be updated

        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(UserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserPrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        // [THEN] The database user should be updated
        if User.Get(UserSecurityId) then;

        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(UserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserPrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        TearDown();
    end;

    [Test]
    // [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestUpdateUserFromAzureGraphForAValidUserWithUpdatedAuthenticationEmail()
    var
        User: Record User;
        UserSecurityId: Guid;
        UserFullName: Text;
        UserName: Text;
        AuthenticationEmail: Text;
        IsUserModified: Boolean;
    begin
        Initialize();

        // [GIVEN] A user security id, full name, contact email and authentication email
        UserSecurityId := CreateGuid();
        UserFullName := StrSubstNo('%1 %2', NewAADUserGivenNameLbl, NewAADUserSurnameLbl);
        UserName := 'username';
        AuthenticationEmail := 'authentication_email@microsoft.com';

        // [WHEN] Trying to set the graph user as the new user
        AzureADGraphUser.SetGraphUser(NewAADUserIdLbl);

        // [GIVEN] A new user
        User.DeleteAll();
        InsertUser(User, NewAADUserIdLbl, true, UserFullName, NewAADUserEmailLbl, AuthenticationEmail, UserName);

        // [WHEN] Updating the user from the Azure Graph
        IsUserModified := AzureADGraphUser.UpdateUserFromAzureGraph(User);

        // [THEN] IsUserModified should be true, as the user requires updates
        LibraryAssert.IsTrue(IsUserModified, 'The user requires updates');

        // [THEN] The returned user should be updated

        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(UserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserPrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        // [THEN] The database user should be updated
        if User.Get(UserSecurityId) then;

        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(UserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserPrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestSetAndGetGraphUser()
    var
        UserInfo: DotNet UserInfo;
        UserInfo2: DotNet UserInfo;
        ObjectId: Text;
        Surname: Text;
        DisplayName: Text;
        Email: Text;
        PrincipalName: Text;
        GivenName: Text;
        PreferredLanguage: Text;
        AccountEnabled: Boolean;
        AreUsersIdentical: Boolean;
    begin
        Initialize();

        // [GIVEN] A UserInfo object
        ObjectId := CreateGuid();
        Surname := 'surname 123';
        DisplayName := 'display name 123abc';
        Email := 'abc@gmail.com';
        PrincipalName := 'principal principal';
        GivenName := 'given name abc';
        PreferredLanguage := 'language 123';
        AccountEnabled := true;

        CreateUserInfo(UserInfo, ObjectId, Surname, DisplayName, Email, PrincipalName,
            GivenName, PreferredLanguage, AccountEnabled);

        // [WHEN] Setting the Graph User to UserInfo
        AzureADGraphUser.SetGraphUser(UserInfo);

        // [WHEN] Getting the Graph User
        AzureADGraphUser.GetGraphUser(UserInfo2);

        // [THEN] UserInfo and UserInfo2 should be identical
        AreUsersIdentical := UserInfo.Equals(UserInfo2);
        LibraryAssert.IsTrue(AreUsersIdentical, 'The users should be identical');

        TearDown();
    end;
}

