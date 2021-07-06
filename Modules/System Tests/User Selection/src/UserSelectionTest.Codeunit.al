// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135035 "User Selection Test"
{
    Subtype = Test;
    Permissions = tabledata User = r;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        IsInitialized: Boolean;

    [Test]
    procedure ExistingUserNameTest()
    var
        UserSelection: Codeunit "User Selection";
    begin
        // [SCENARIO] No error is thrown if there is a user with the given username
        // [GIVEN] There are some users in the system
        Initialize();
        PermissionsMock.Set('User Selection Read');
        ClearLastError();

        // [WHEN] A username that exists is entered
        UserSelection.ValidateUserName('A');
        // [THEN] There is no error
        Assert.AreEqual('', GetLastErrorCode(), 'No error was expected');
    end;

    [Test]
    procedure NonExistingUserNameTest()
    var
        UserSelection: Codeunit "User Selection";
    begin
        // [SCENARIO] An error is thrown when there is no User with that Username
        // [GIVEN] There are some users in the system
        Initialize();
        PermissionsMock.Set('User Selection Read');

        // [WHEN] A username that does not exists is entered
        // [THEN] Then an error is thrown
        asserterror UserSelection.ValidateUserName('E');
        Assert.ExpectedError('The user name E does not exist.');
    end;

    [Test]
    [HandlerFunctions('UserLookupFilteredRecordPageHandler')]
    procedure FiltersOnUserTableAreRespectedTest()
    var
        User: Record User;
        UserSelection: Codeunit "User Selection";
    begin
        // [SCENARIO] Filters set on the User record are respected.
        // [GIVEN] Filters have been set on the User Record.
        // [GIVEN] There are some users in the system
        Initialize();
        PermissionsMock.Set('User Selection Read');

        User.SetRange("User Name", 'D');
        // [WHEN] Open function is called
        // [THEN] Only user D is visible.
        UserSelection.Open(User);
    end;

    [Test]
    [HandlerFunctions('UserLookupPageOKHandler')]
    procedure SelectUserOKTest()
    var
        User: Record User;
        UserSelection: Codeunit "User Selection";
    begin
        // [SCENARIO] A single user can be selected.
        // [GIVEN] There are some users in the system
        Initialize();
        PermissionsMock.Set('User Selection Read');

        // [WHEN] User selects a User and Clicks OK
        // [THEN] Open returns True
        Assert.IsTrue(UserSelection.Open(User), 'It was expected for a user to have been selected.');
        // [THEN] The Selected User is returned
        Assert.AreEqual('B', User."User Name", 'User B was expected to be selected.');
        Assert.AreEqual('Full Name B', User."Full Name", 'User B was expected to be selected.');
    end;

    [Test]
    [HandlerFunctions('UserLookupPageOKHandler')]
    procedure SelectUserOKWithTemporaryRecordTest()
    var
        User: Record User temporary;
        UserSelection: Codeunit "User Selection";
    begin
        // [SCENARIO] A single user can be selected and the selected user can be stored in temporary record.
        // [GIVEN] There are some users in the system
        Initialize();
        PermissionsMock.Set('User Selection Read');

        // [WHEN] User selects a User and Clicks OK
        // [THEN] Open returns True
        Assert.IsTrue(UserSelection.Open(User), 'It was expected for a user to have been selected.');
        // [THEN] The Selected User is returned
        Assert.AreEqual('B', User."User Name", 'User B was expected to be selected.');
        Assert.AreEqual('Full Name B', User."Full Name", 'User B was expected to be selected.');
    end;

    [Test]
    [HandlerFunctions('UserLookupPageCancelHandler')]
    procedure SelectUserCancelTest()
    var
        User: Record User;
        UserSelection: Codeunit "User Selection";
    begin
        // [SCENARIO] User variable is not altered if the User cancels the lookup.
        // [GIVEN] There are some users in the system
        Initialize();
        PermissionsMock.Set('User Selection Read');

        // [GIVEN] User Variable has some values
        User."User Name" := 'SOME VALUE';
        // [WHEN] User cancels the lookup
        // [THEN] Open returns false
        Assert.IsFalse(UserSelection.Open(User), 'It was not expected for a user to have been selected.');
        // [THEN] User variable is not mutated
        Assert.AreEqual('SOME VALUE', User."User Name", 'User was not expected to be mutated.');
    end;

    [Test]
    procedure ExternalUsersAreNotVisibleTest()
    var
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        UserLookup: TestPage "User Lookup";
    begin
        // [SCENARIO] External users are not visible on the Lookup page.
        // [GIVEN] There are some users in the system
        Initialize();
        PermissionsMock.Set('User Selection Read');

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [WHEN] User Lookup page opens
        UserLookup.OpenView();
        // [THEN] External users are not visible
        UserLookup.First();
        repeat
            Assert.AreNotEqual(UserLookup."User Name".Value(), 'EXTERNAL', 'External user should have been hidden.');
        until not UserLookup.Next();

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    [ModalPageHandler]
    procedure UserLookupPageOKHandler(var UserLookup: TestPage 9843)
    var
        User: Record User;
    begin
        User.SetRange("User Name", 'B');
        User.FindFirst();
        UserLookup.GoToRecord(User);
        UserLookup.Ok().Invoke();
    end;

    [ModalPageHandler]
    procedure UserLookupPageCancelHandler(var UserLookup: TestPage 9843)
    var
        User: Record User;
    begin
        User.SetRange("User Name", 'B');
        User.FindFirst();
        UserLookup.GoToRecord(User);
        UserLookup.Cancel().Invoke();
    end;

    [ModalPageHandler]
    procedure UserLookupFilteredRecordPageHandler(var UserLookup: TestPage 9843)
    begin
        UserLookup.First();
        Assert.AreEqual('D', UserLookup."User Name".Value(), 'A different User was expected');
        Assert.IsFalse(UserLookup.Next(), 'Only one user was expected to be visible on the page')
    end;

    local procedure Initialize();
    var
        User: Record User;
    begin
        if IsInitialized then
            exit;

        if not User.FindFirst() then begin
            User."User Security ID" := CreateGuid();
            User."User Name" := CopyStr(UserId(), 1, MaxStrLen(User."User Name"));
            User."Full Name" := User."User Name";
            User."Windows Security ID" := CopyStr(Sid(User."User Name"), 1, MaxStrLen(User."Windows Security ID"));
            User.Insert();
        end;

        User.Init();
        User."User Security ID" := CreateGuid();
        User."User Name" := 'A';
        User."Full Name" := 'Full Name A';
        User.Insert();

        User.Init();
        User."User Security ID" := CreateGuid();
        User."User Name" := 'B';
        User."Full Name" := 'Full Name B';
        User.Insert();

        User.Init();
        User."User Security ID" := CreateGuid();
        User."User Name" := 'C';
        User."Full Name" := 'Full Name C';
        User.Insert();

        User.Init();
        User."User Security ID" := CreateGuid();
        User."User Name" := 'D';
        User."Full Name" := 'Full Name D';
        User.Insert();

        User.Init();
        User."User Security ID" := CreateGuid();
        User."User Name" := 'EXTERNAL';
        User."Full Name" := 'External user';
        User."License Type" := User."License Type"::"External User";
        User.Insert();

        IsInitialized := true;
        Commit();
    end;
}
