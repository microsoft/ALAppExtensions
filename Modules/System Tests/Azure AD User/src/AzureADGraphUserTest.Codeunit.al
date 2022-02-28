// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132911 "Azure AD Graph User Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        AzureADGraphUser: Codeunit "Azure AD Graph User";
        AzureADGraphUserTest: Codeunit "Azure AD Graph User Test";
        LibraryAssert: Codeunit "Library Assert";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        PermissionsMock: Codeunit "Permissions Mock";
        MockGraphQuery: DotNet MockGraphQuery;

        NewAADUserIdLbl: Label '6D59EA6C-BD8c-4694-A839-FE5C70089021';
        AADUserIdWithEmptyObjectIdLbl: Label '28E0F872-F014-4EA4-B47D-6AF6F13B3FE1';
        AADUserWithEmptySurnameUserIdLbl: Label 'A0F61055-D58F-4D6D-B96B-7A147B0D131A';
        UserToUpdate1IdLbl: Label '6D59EA6C-BD8c-4694-A839-FE5C70089022';
        UserToUpdate2IdLbl: Label '6D59EA6C-BD8c-4694-A839-FE5C70089023';
        UserToUpdate3IdLbl: Label '6D59EA6C-BD8c-4694-A839-FE5C70089024';
        UserToUpdate4IdLbl: Label '6D59EA6C-BD8c-4694-A839-FE5C70089025';
        UserToUpdate5IdLbl: Label '6D59EA6C-BD8c-4694-A839-FE5C70089026';
        UserToUpdate6IdLbl: Label '6D59EA6C-BD8c-4694-A839-FE5C70089027';
        UserToUpdate7IdLbl: Label '6D59EA6C-BD8c-4694-A839-FE5C70089028';

        NewAADUserObjectIdLbl: Label 'New AAD User Object Id';
        CurrentUserObjectIdLbl: Label 'Current User Object Id';
        AADUserWithEmptySurnameObjectIdLbl: Label 'Empty Surname User Object Id';
        UpdatedUser1ObjectIdLbl: Label 'New AAD User Object Id 1';
        UpdatedUser2ObjectIdLbl: Label 'New AAD User Object Id 2';
        UpdatedUser3ObjectIdLbl: Label 'New AAD User Object Id 3';
        UpdatedUser4ObjectIdLbl: Label 'New AAD User Object Id 4';
        UpdatedUser5ObjectIdLbl: Label 'New AAD User Object Id 5';
        UpdatedUser6ObjectIdLbl: Label 'New AAD User Object Id 6';
        UpdatedUser7ObjectIdLbl: Label 'New AAD User Object Id 7';

        CurrentUserSurnameLbl: Label 'Current User Surname';
        NewAADUserSurnameLbl: Label 'New User Surname';

        CurrentUserDisplayNameLbl: Label 'Current User Display Name';
        NewAADUserDisplayNameLbl: Label 'New User Display Name';

        CurrentUserEmailLbl: Label 'Current User Email';
        NewAADUserEmailLbl: Label 'newemail@microsoft.com';

        CurrentUserPrincipalNameLbl: Label 'Current User Principal Name';
        NewAADUserPrincipalNameLbl: Label 'principal@microsoft.com';
        UpdatedUser1PrincipalNameLbl: Label 'principal1@microsoft.com';
        UpdatedUser2PrincipalNameLbl: Label 'principal2@microsoft.com';
        UpdatedUser3PrincipalNameLbl: Label 'principal3@microsoft.com';
        UpdatedUser4PrincipalNameLbl: Label 'principal4@microsoft.com';
        UpdatedUser5PrincipalNameLbl: Label 'principal5@microsoft.com';
        UpdatedUser6PrincipalNameLbl: Label 'principal6@microsoft.com';
        UpdatedUser7PrincipalNameLbl: Label 'principal7@microsoft.com';

        CurrentUserGivenNameLbl: Label 'Current User Given Name';
        NewAADUserGivenNameLbl: Label 'New User Given Name';
        AADUserGivenNameForUserWithEmptySurnameLbl: Label 'Empty Surname User Given Name';

        CurrentUserPreferredLanguageLbl: Label 'Current User Preferred Language';
        NewAADUserPreferredLanguageLbl: Label 'New User Preferred Language';

    local procedure Initialize()
    var
        UserProperty: Record "User Property";
    begin
        Clear(AzureADGraphUser);
        UserProperty.DeleteAll();

        AzureADGraphUser.SetTestInProgress(true);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        AzureADGraphUserTest.SetupMockGraphQuery();

        BindSubscription(AzureADGraphUserTest);
    end;

    local procedure TearDown()
    begin
        AzureADGraphUser.SetTestInProgress(false);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);

        UnbindSubscription(AzureADGraphUserTest);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Azure AD Graph", 'OnInitialize', '', false, false)]
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

        CreateAzureADUser(UserInfo, UserToUpdate1IdLbl, UpdatedUser1ObjectIdLbl, NewAADUserSurnameLbl, NewAADUserDisplayNameLbl,
            NewAADUserEmailLbl, UpdatedUser1PrincipalNameLbl, NewAADUserGivenNameLbl, NewAADUserPreferredLanguageLbl, true);
        CreateAzureADUser(UserInfo, UserToUpdate2IdLbl, UpdatedUser2ObjectIdLbl, NewAADUserSurnameLbl, NewAADUserDisplayNameLbl,
            NewAADUserEmailLbl, UpdatedUser2PrincipalNameLbl, NewAADUserGivenNameLbl, NewAADUserPreferredLanguageLbl, true);
        CreateAzureADUser(UserInfo, UserToUpdate3IdLbl, UpdatedUser3ObjectIdLbl, NewAADUserSurnameLbl, NewAADUserDisplayNameLbl,
            NewAADUserEmailLbl, UpdatedUser3PrincipalNameLbl, NewAADUserGivenNameLbl, NewAADUserPreferredLanguageLbl, true);
        CreateAzureADUser(UserInfo, UserToUpdate4IdLbl, UpdatedUser4ObjectIdLbl, NewAADUserSurnameLbl, NewAADUserDisplayNameLbl,
            NewAADUserEmailLbl, UpdatedUser4PrincipalNameLbl, NewAADUserGivenNameLbl, NewAADUserPreferredLanguageLbl, true);
        CreateAzureADUser(UserInfo, UserToUpdate5IdLbl, UpdatedUser5ObjectIdLbl, NewAADUserSurnameLbl, NewAADUserDisplayNameLbl,
            NewAADUserEmailLbl, UpdatedUser5PrincipalNameLbl, NewAADUserGivenNameLbl, NewAADUserPreferredLanguageLbl, true);
        CreateAzureADUser(UserInfo, UserToUpdate6IdLbl, UpdatedUser6ObjectIdLbl, NewAADUserSurnameLbl, NewAADUserDisplayNameLbl,
            NewAADUserEmailLbl, UpdatedUser6PrincipalNameLbl, NewAADUserGivenNameLbl, NewAADUserPreferredLanguageLbl, true);
        CreateAzureADUser(UserInfo, UserToUpdate7IdLbl, UpdatedUser7ObjectIdLbl, NewAADUserSurnameLbl, NewAADUserDisplayNameLbl,
            NewAADUserEmailLbl, UpdatedUser7PrincipalNameLbl, NewAADUserGivenNameLbl, NewAADUserPreferredLanguageLbl, true);
    end;

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
    procedure TestGetGraphUserForTheCurrentUser()
    var
        GraphUserInfo: DotNet UserInfo;
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD User View');

        // [WHEN] Retrieving the graph user for the current user's security id
        AzureADGraphUser.GetGraphUser(UserSecurityId(), GraphUserInfo);

        // [THEN] The graph user should not be null
        LibraryAssert.IsFalse(IsNull(GraphUserInfo), 'The graph user should not be null');

        // [THEN] The graph user's properties are assigned correctly
        LibraryAssert.AreEqual(CurrentUserObjectIdLbl, GraphUserInfo.ObjectId(),
            'The object id of the graph user is incorect');
        LibraryAssert.AreEqual(CurrentUserSurnameLbl, GraphUserInfo.Surname(),
            'The surname of the graph user is incorect');
        LibraryAssert.AreEqual(CurrentUserDisplayNameLbl, GraphUserInfo.DisplayName(),
            'The display name of the graph user is incorect');
        LibraryAssert.AreEqual(CurrentUserEmailLbl, GraphUserInfo.Mail(),
            'The email of the graph user is incorect');
        LibraryAssert.AreEqual(CurrentUserPrincipalNameLbl, GraphUserInfo.UserPrincipalName(),
            'The user principal name of the graph user is incorect');
        LibraryAssert.AreEqual(CurrentUserGivenNameLbl, GraphUserInfo.GivenName(),
            'The given name of the graph user is incorect');
        LibraryAssert.AreEqual(CurrentUserPreferredLanguageLbl, GraphUserInfo.PreferredLanguage(),
            'The preferred language of the graph user is incorect');
        LibraryAssert.AreEqual(false, GraphUserInfo.AccountEnabled(),
            'The account enabled flag of the graph user is set incorectly');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetGraphUserForAnInexistentUser()
    var
        GraphUserInfo: DotNet UserInfo;
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD User View');

        // [WHEN] Retrieving the graph user for an inexistent user
        // [THEN] An error should occur, as the user does not exist
        asserterror AzureADGraphUser.GetGraphUser(CreateGuid(), GraphUserInfo);
        LibraryAssert.ExpectedError('The user with the security ID');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetGraphUserForANewUserWithValidObjectId()
    var
        GraphUserInfo: DotNet UserInfo;
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD User View');

        // [WHEN] Retrieving the graph user for a newly inserted Azure AD Graph user with a valid object id
        AzureADGraphUser.GetGraphUser(NewAADUserIdLbl, GraphUserInfo);

        // [THEN] The user should not be null
        LibraryAssert.IsFalse(IsNull(GraphUserInfo), 'The graph user should not be null');

        // [THEN] The graph user's properties are assigned correctly
        LibraryAssert.AreEqual(NewAADUserObjectIdLbl, GraphUserInfo.ObjectId(),
            'The object id of the graph user is incorect');
        LibraryAssert.AreEqual(NewAADUserSurnameLbl, GraphUserInfo.Surname(),
            'The surname of the graph user is incorect');
        LibraryAssert.AreEqual(NewAADUserDisplayNameLbl, GraphUserInfo.DisplayName(),
            'The display name of the graph user is incorect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, GraphUserInfo.Mail(),
            'The email of the graph user is incorect');
        LibraryAssert.AreEqual(NewAADUserPrincipalNameLbl, GraphUserInfo.UserPrincipalName(),
            'The user principal name of the graph user is incorect');
        LibraryAssert.AreEqual(NewAADUserGivenNameLbl, GraphUserInfo.GivenName(),
            'The given name of the graph user is incorect');
        LibraryAssert.AreEqual(NewAADUserPreferredLanguageLbl, GraphUserInfo.PreferredLanguage(),
            'The preferred language of the graph user is incorect');
        LibraryAssert.AreEqual(true, GraphUserInfo.AccountEnabled(),
            'The account enabled flag of the graph user is set incorectly');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetGraphUserForANewUserWithInvalidObjectId()
    var
        GraphUserInfo: DotNet UserInfo;
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD User View');

        // [WHEN] Retrieving the graph user for a newly inserted Azure AD Graph user with an invalid object id
        // [THEN] An error should occur
        asserterror AzureADGraphUser.GetGraphUser(AADUserIdWithEmptyObjectIdLbl, GraphUserInfo);
        LibraryAssert.ExpectedError('An Azure Active Directory user');

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

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD User View');

        // [WHEN] Getting the object id of the graph user
        GraphUserObjectId := AzureADGraphUser.GetObjectId(UserSecurityId());

        // [THEN] The object id should not be the empty string
        LibraryAssert.AreEqual(CurrentUserObjectIdLbl, GraphUserObjectId, 'The object id is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetObjectIdForAnInexistentUser()
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD User View');

        // [WHEN] Getting the object id of the graph user
        // [THEN] An error should occur, as the user does not exist
        asserterror AzureADGraphUser.GetObjectId(CreateGuid());
        LibraryAssert.ExpectedError('The user with the security ID');

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

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD User View');

        // [WHEN] Getting the object id of the graph user
        GraphObjectId := AzureADGraphUser.GetObjectId(NewAADUserIdLbl);

        // [THEN] The object id should be the id of the new user
        LibraryAssert.AreEqual(NewAADUserObjectIdLbl, GraphObjectId, 'The object id is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetUserAuthenticationObjectIdForAnInexistentUser()
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD User View');

        // [WHEN] Trying to get the user authentication object ID for an inexistent user
        // [THEN] An error should occur
        asserterror AzureADGraphUser.GetUserAuthenticationObjectId(CreateGuid());
        LibraryAssert.ExpectedError('The user with the security ID');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetUserAuthenticationObjectIdForAnInexistentUserProperty()
    var
        User: Record User;
        UserId: Guid;
        UserAuthenticationObjectId: Text;
    begin
        Initialize();

        // [GIVEN] A user
        UserId := CreateGuid();
        InsertUser(User, UserId, false, '', '', 'email@email.com', 'username');

        // [WHEN] Trying to get the user authentication object ID for the user
        UserAuthenticationObjectId := AzureADGraphUser.GetUserAuthenticationObjectId(UserId);

        // [THEN] The authentication object id should be the empty string
        LibraryAssert.AreEqual('', UserAuthenticationObjectId, 'The user authentication object id is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetUserAuthenticationObjectIdForTheCurrentUser()
    var
        UserAuthenticationObjectId: Text;
    begin
        Initialize();

        // [WHEN] Trying to get the user authentication object ID for the current user
        UserAuthenticationObjectId := AzureADGraphUser.GetUserAuthenticationObjectId(UserSecurityId());

        // [THEN] The authentication object id should be the empty string
        LibraryAssert.AreEqual(CurrentUserObjectIdLbl, UserAuthenticationObjectId, 'The user authentication object id is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetUserAuthenticationObjectIdForANewUser()
    var
        UserAuthenticationObjectId: Text;
    begin
        Initialize();

        // [WHEN] Trying to get the user authentication object ID for a new user
        UserAuthenticationObjectId := AzureADGraphUser.GetUserAuthenticationObjectId(NewAADUserIdLbl);

        // [THEN] The authentication object id should be the empty string
        LibraryAssert.AreEqual(NewAADUserObjectIdLbl, UserAuthenticationObjectId, 'The user authentication object id is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestTryGetUserAuthenticationObjectIdForAnInexistentUser()
    var
        AuthenticationObjectID: Text;
        RandomGUID: Guid;
        Result: Boolean;
    begin
        Initialize();
        RandomGUID := CreateGuid();

        // [WHEN] Trying to get the user authentication object ID for an inexistent user
        Result := AzureADGraphUser.TryGetUserAuthenticationObjectId(RandomGUID, AuthenticationObjectID);

        // [THEN] The call should fail
        LibraryAssert.IsFalse(Result, 'The call to TryGetUserAuthenticationObjectId should fail');

        // [THEN] The var parameter should be unchanged
        LibraryAssert.AreEqual('', AuthenticationObjectID, 'Authentication Object ID should not be set');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestTryGetUserAuthenticationObjectIdForAnInexistentUserProperty()
    var
        User: Record User;
        UserId: Guid;
        UserAuthenticationObjectId: Text;
        Result: Boolean;
    begin
        Initialize();

        // [GIVEN] A user
        UserId := CreateGuid();
        InsertUser(User, UserId, false, '', '', 'email@email.com', 'username');

        // [WHEN] Trying to get the user authentication object ID for the user
        Result := AzureADGraphUser.TryGetUserAuthenticationObjectId(UserId, UserAuthenticationObjectId);

        // [THEN] The call should be successful
        LibraryAssert.IsTrue(Result, 'The call to TryGetUserAuthenticationObjectId should be successful');

        // [THEN] The authentication object id should be the empty string
        LibraryAssert.AreEqual('', UserAuthenticationObjectId, 'The user authentication object ID is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestTryGetUserAuthenticationObjectIdForTheCurrentUser()
    var
        UserAuthenticationObjectId: Text;
        Result: Boolean;
    begin
        Initialize();

        // [WHEN] Trying to get the user authentication object ID for the current user
        Result := AzureADGraphUser.TryGetUserAuthenticationObjectId(UserSecurityId(), UserAuthenticationObjectId);

        // [THEN] The call is successful
        LibraryAssert.IsTrue(Result, 'The call to TryGetUserAuthenticationObjectId should be successful');

        // [THEN] The authentication object ID should be as expected
        LibraryAssert.AreEqual(CurrentUserObjectIdLbl, UserAuthenticationObjectId, 'The user authentication object ID is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestTryGetUserAuthenticationObjectIdForANewUser()
    var
        UserAuthenticationObjectId: Text;
        Result: Boolean;
    begin
        Initialize();

        // [WHEN] Trying to get the user authentication object ID for a new user
        Result := AzureADGraphUser.TryGetUserAuthenticationObjectId(NewAADUserIdLbl, UserAuthenticationObjectId);

        // [THEN] The call is successful
        LibraryAssert.IsTrue(Result, 'The call to TryGetUserAuthenticationObjectId should be successful');

        // [THEN] The authentication object ID should as expected
        LibraryAssert.AreEqual(NewAADUserObjectIdLbl, UserAuthenticationObjectId, 'The user authentication object ID is incorrect');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestUpdateUserFromAzureGraphForAValidUserWithoutUpdates()
    var
        User: Record User;
        GraphUserInfo: DotNet UserInfo;
        UserFullName: Text;
        UserName: Text;
        IsUserModified: Boolean;
    begin
        Initialize();

        // [GIVEN] A user's full name, contact email and authentication email
#pragma warning disable AA0217
        UserFullName := StrSubstNo('%1 %2', NewAADUserGivenNameLbl, NewAADUserSurnameLbl);
#pragma warning restore
        UserName := 'username';

        // [GIVEN] A new user
        InsertUser(User, NewAADUserIdLbl, true, UserFullName, NewAADUserEmailLbl, NewAADUserPrincipalNameLbl, UserName);

        // [WHEN] Updating the user from the Azure Graph
        AzureADGraphUser.GetGraphUser(NewAADUserIdLbl, GraphUserInfo);
        IsUserModified := AzureADGraphUser.UpdateUserFromAzureGraph(User, GraphUserInfo);

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
        if User.Get(NewAADUserIdLbl) then;

        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(UserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserPrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpdateUserFromAzureGraphForAValidUserWithUpdatedState()
    var
        User: Record User;
        GraphUserInfo: DotNet UserInfo;
        UserFullName: Text;
        UserName: Text;
        ContactEmail: Text;
        AuthenticationEmail: Text;
        AADUserFullName: Text;
        IsUserModified: Boolean;
    begin
        Initialize();

        // [GIVEN] A user's full name, contact email and authentication email
        UserFullName := 'full name1 123';
        UserName := 'username1';
        ContactEmail := 'contact_email1@microsoft.com';
        AuthenticationEmail := 'authentication_email1@microsoft.com';

        // [GIVEN] A new user
        InsertUser(User, NewAADUserIdLbl, false, UserFullName, ContactEmail, AuthenticationEmail, UserName);

        // [WHEN] Updating the user from the Azure Graph
        AzureADGraphUser.GetGraphUser(NewAADUserIdLbl, GraphUserInfo);
        IsUserModified := AzureADGraphUser.UpdateUserFromAzureGraph(User, GraphUserInfo);

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
        if User.Get(NewAADUserIdLbl) then;

        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(AADUserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserPrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpdateUserFromAzureGraphForAValidUserWithUpdatedFullName()
    var
        User: Record User;
        GraphUserInfo: DotNet UserInfo;
        UserFullName: Text;
        UserName: Text;
        ContactEmail: Text;
        AuthenticationEmail: Text;
        AADUserFullName: Text;
        IsUserModified: Boolean;
    begin
        Initialize();

        // [GIVEN] A user's full name, contact email and authentication email
        UserFullName := 'full name2 123';
        UserName := 'username2';
        ContactEmail := 'contact_email2@microsoft.com';
        AuthenticationEmail := 'authentication_email2@microsoft.com';

        // [GIVEN] A new user
        InsertUser(User, UserToUpdate1IdLbl, true, UserFullName, ContactEmail, AuthenticationEmail, UserName);

        // [WHEN] Updating the user from the Azure Graph
        AzureADGraphUser.GetGraphUser(UserToUpdate1IdLbl, GraphUserInfo);
        IsUserModified := AzureADGraphUser.UpdateUserFromAzureGraph(User, GraphUserInfo);

        // [THEN] IsUserModified should be true, as the user requires updates
        LibraryAssert.IsTrue(IsUserModified, 'The user requires updates');

        // [THEN] The returned user should be updated
        AADUserFullName := StrSubstNo('%1 %2', NewAADUserGivenNameLbl, NewAADUserSurnameLbl);

        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(AADUserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(UpdatedUser1PrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        // [THEN] The database user should be updated
        if User.Get(UserToUpdate3IdLbl) then;

        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(AADUserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(UpdatedUser1PrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpdateUserFromAzureGraphForAValidUserWithUpdatedContactEmail()
    var
        User: Record User;
        GraphUserInfo: DotNet UserInfo;
        UserFullName: Text;
        UserName: Text;
        ContactEmail: Text;
        AuthenticationEmail: Text;
        IsUserModified: Boolean;
    begin
        Initialize();

        // [GIVEN] A user's full name, contact email and authentication email
        UserFullName := StrSubstNo('%1 %2', NewAADUserGivenNameLbl, NewAADUserSurnameLbl);
        UserName := 'username3';
        ContactEmail := 'contact_email3@microsoft.com';
        AuthenticationEmail := 'authentication_email3@microsoft.com';

        // [GIVEN] A new user
        InsertUser(User, UserToUpdate2IdLbl, true, UserFullName, ContactEmail, AuthenticationEmail, UserName);

        // [WHEN] Updating the user from the Azure Graph
        AzureADGraphUser.GetGraphUser(UserToUpdate2IdLbl, GraphUserInfo);
        IsUserModified := AzureADGraphUser.UpdateUserFromAzureGraph(User, GraphUserInfo);

        // [THEN] IsUserModified should be true, as the user requires updates
        LibraryAssert.IsTrue(IsUserModified, 'The user requires updates');

        // [THEN] The returned user should be updated

        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(UserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(UpdatedUser2PrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        // [THEN] The database user should be updated
        if User.Get(UserToUpdate2IdLbl) then;

        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(UserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(UpdatedUser2PrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpdateUserFromAzureGraphForAValidUserWithUpdatedAuthenticationEmail()
    var
        User: Record User;
        GraphUserInfo: DotNet UserInfo;
        UserFullName: Text;
        UserName: Text;
        AuthenticationEmail: Text;
        IsUserModified: Boolean;
    begin
        Initialize();

        // [GIVEN] A user's full name, contact email and authentication email
        UserFullName := StrSubstNo('%1 %2', NewAADUserGivenNameLbl, NewAADUserSurnameLbl);
        UserName := 'username4';
        AuthenticationEmail := 'authentication_email4@microsoft.com';

        // [GIVEN] A new user
        InsertUser(User, UserToUpdate3IdLbl, true, UserFullName, NewAADUserEmailLbl, AuthenticationEmail, UserName);

        // [WHEN] Updating the user from the Azure Graph
        AzureADGraphUser.GetGraphUser(UserToUpdate3IdLbl, GraphUserInfo);
        IsUserModified := AzureADGraphUser.UpdateUserFromAzureGraph(User, GraphUserInfo);

        // [THEN] IsUserModified should be true, as the user requires updates
        LibraryAssert.IsTrue(IsUserModified, 'The user requires updates');

        // [THEN] The returned user should be updated

        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(UserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(UpdatedUser3PrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        // [THEN] The database user should be updated
        if User.Get(UserToUpdate3IdLbl) then;

        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The state of the user is incorrect');
        LibraryAssert.AreEqual(UserFullName, User."Full Name", 'The full name of the user is incorrect');
        LibraryAssert.AreEqual(NewAADUserEmailLbl, User."Contact Email",
            'The contact email of the user is incorrect');
        LibraryAssert.AreEqual(UpdatedUser3PrincipalNameLbl, User."Authentication Email",
            'The authentication email of the user is incorrect');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestEnsureAuthenticationEmailIsNotInUse()
    var
        User: Record User;
        GraphUserInfo: DotNet UserInfo;
    begin
        Initialize();

        // [GIVEN] 4 new users - all of them have corresponding users in the Azure AD Graph API, 
        // but their addresses don't correspond to the ones in the graph 
        InsertUser(User, UserToUpdate4IdLbl, true, '', 'email1@microsoft.com', UpdatedUser5PrincipalNameLbl, 'username10');
        InsertUser(User, UserToUpdate5IdLbl, true, '', 'email2@microsoft.com', UpdatedUser7PrincipalNameLbl, 'username20');
        InsertUser(User, UserToUpdate6IdLbl, true, '', 'email3@microsoft.com', UpdatedUser4PrincipalNameLbl, 'username30');
        InsertUser(User, UserToUpdate7IdLbl, true, '', 'email4@microsoft.com', UpdatedUser6PrincipalNameLbl, 'username40');

        // [WHEN] Calling EnsureAuthenticationEmailIsNotInUse on one of the email addresses
        AzureADGraphUser.EnsureAuthenticationEmailIsNotInUse(UserToUpdate4IdLbl);

        // [THEN] None of the 4 users' authentication emails are updated
        if User.Get(UserToUpdate4IdLbl) then;
        LibraryAssert.AreEqual(UpdatedUser5PrincipalNameLbl, User."Authentication Email",
            'The authentication email should not have been updated');

        if User.Get(UserToUpdate5IdLbl) then;
        LibraryAssert.AreEqual(UpdatedUser7PrincipalNameLbl, User."Authentication Email",
            'The authentication email should not have been updated');

        if User.Get(UserToUpdate6IdLbl) then;
        LibraryAssert.AreEqual(UpdatedUser4PrincipalNameLbl, User."Authentication Email",
            'The authentication email should not have been updated');

        if User.Get(UserToUpdate7IdLbl) then;
        LibraryAssert.AreEqual(UpdatedUser6PrincipalNameLbl, User."Authentication Email",
            'The authentication email should not have been updated');

        // [WHEN] Calling UpdateUserFromAzureGraph on the first user 
        if User.Get(UserToUpdate4IdLbl) then;
        AzureADGraphUser.GetGraphUser(User."User Security ID", GraphUserInfo);
        AzureADGraphUser.UpdateUserFromAzureGraph(User, GraphUserInfo);

        // [THEN] The email addresses should be updated according to the ones in the graph
        if User.Get(UserToUpdate4IdLbl) then;
        LibraryAssert.AreEqual(UpdatedUser4PrincipalNameLbl, User."Authentication Email",
            'The authentication email should have been updated');

        if User.Get(UserToUpdate5IdLbl) then;
        LibraryAssert.AreEqual(UpdatedUser5PrincipalNameLbl, User."Authentication Email",
            'The authentication email should have been updated');

        if User.Get(UserToUpdate6IdLbl) then;
        LibraryAssert.AreEqual(UpdatedUser6PrincipalNameLbl, User."Authentication Email",
            'The authentication email should have been updated');

        if User.Get(UserToUpdate7IdLbl) then;
        LibraryAssert.AreEqual(UpdatedUser7PrincipalNameLbl, User."Authentication Email",
            'The authentication email should have been updated');

        TearDown();
    end;
}

