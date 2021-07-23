// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139146 "User Permissions Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        SUPERTok: Label 'SUPER', Locked = true;
        NotSUPERTok: Label 'NOTSUPER', Locked = true;
        SUPERPermissionErr: Label 'There should be at least one enabled ''SUPER'' user.', Locked = true;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure IsSuperWhenUserIsSuperTest()
    var
        UserPermissions: Codeunit "User Permissions";
        Any: Codeunit Any;
        FirstUserId: Guid;
        SecondUserId: Guid;
        IsUserSuper: Boolean;
    begin
        // [Given] two users - one SUPER and the other - non-SUPER
        DeleteAllUsersAndPermissions();
        FirstUserId := AddUser(Any.AlphabeticText(10), true, false);
        SecondUserId := AddUser(Any.AlphabeticText(10), true, true);

        AddPermissions(FirstUserId, SUPERTok, '');
        AddPermissions(SecondUserId, NotSUPERTok, '');
        PermissionsMock.Set('User Permission View');

        // [When] checking if the first super user is SUPER
        IsUserSuper := UserPermissions.IsSuper(FirstUserId);

        // [Then] the correct value is returned
        Assert.IsTrue(IsUserSuper, 'The first user should be SUPER.');

        // [When] checking if the second super user is SUPER
        IsUserSuper := UserPermissions.IsSuper(SecondUserId);

        // [Then] the correct value is returned
        Assert.IsFalse(IsUserSuper, 'The second user should not be SUPER.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure IsSuperWhenUserIsNotSuperTest()
    var
        UserPermissions: Codeunit "User Permissions";
        Any: Codeunit Any;
        FirstUserId: Guid;
        SecondUserId: Guid;
        IsUserSuper: Boolean;
    begin
        // [Given] two users - one SUPER and the other - non-SUPER
        DeleteAllUsersAndPermissions();
        FirstUserId := AddUser(Any.AlphabeticText(10), true, false);
        SecondUserId := AddUser(Any.AlphabeticText(10), true, true);

        AddPermissions(FirstUserId, SUPERTok, '');
        AddPermissions(SecondUserId, NotSUPERTok, '');

        PermissionsMock.Set('User Permission View');

        // [When] checking if the non-super user is SUPER
        IsUserSuper := UserPermissions.IsSuper(SecondUserId);

        // [Then] the correct value is returned
        Assert.IsFalse(IsUserSuper, 'User should not be SUPER.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure IsSuperWhenUserIsSuperForSpecificCompanyTest()
    var
        UserPermissions: Codeunit "User Permissions";
        Any: Codeunit Any;
        UserId: Guid;
        IsUserSuper: Boolean;
        RandomCompanyName: Text[30];
    begin
        // [Given] a user who is SUPER for a specific company
        DeleteAllUsersAndPermissions();
        RandomCompanyName := CopyStr(Any.AlphabeticText(10), 1, MaxStrLen(RandomCompanyName));
        UserId := AddUser(Any.AlphabeticText(10), true, false);
        AddPermissions(UserId, SUPERTok, RandomCompanyName);

        PermissionsMock.Set('User Permission View');

        // [When] checking if the user is SUPER for all companies
        IsUserSuper := UserPermissions.IsSuper(UserId);

        // [Then] the correct value is returned
        Assert.IsFalse(IsUserSuper, 'User should not be SUPER for all companies if they are SUPER only for a specific company.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure IsSuperWhenUserIsNotSuperForSpecificCompanyTest()
    var
        UserPermissions: Codeunit "User Permissions";
        Any: Codeunit Any;
        UserId: Guid;
        IsUserSuper: Boolean;
        RandomCompanyName: Text[30];
    begin
        // [Given] a user who is not SUPER for a specific company
        DeleteAllUsersAndPermissions();
        RandomCompanyName := CopyStr(Any.AlphabeticText(10), 1, MaxStrLen(RandomCompanyName));
        UserId := AddUser(Any.AlphabeticText(10), true, false);
        AddPermissions(UserId, NotSUPERTok, RandomCompanyName);

        PermissionsMock.Set('User Permission View');

        // [When] checking if the user is SUPER for all companies
        IsUserSuper := UserPermissions.IsSuper(UserId);

        // [Then] the correct value is returned
        Assert.IsFalse(IsUserSuper, 'User should not be SUPER for all companies.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure RemoveSuperPermissionsFromOnlySuperUserTest()
    var
        UserPermissions: Codeunit "User Permissions";
        Any: Codeunit Any;
        UserId: Guid;
        IsUserSuper: Boolean;
    begin
        // [Given] a SUPER user
        DeleteAllUsersAndPermissions();
        UserId := AddUser(Any.AlphabeticText(10), true, false);

        AddPermissions(UserId, SUPERTok, '');

        PermissionsMock.Set('User Permission View');

        // [When] checking if the user is SUPER
        IsUserSuper := UserPermissions.IsSuper(UserId);

        // [Then] the user is SUPER (the only one)
        Assert.IsTrue(IsUserSuper, 'User should be super.');

        // [When] remove the SUPER permissions from the user
        UserPermissions.RemoveSuperPermissions(UserId);

        // [Then] the user is still SUPER
        Assert.IsTrue(UserPermissions.IsSuper(UserId), 'The user should still be SUPER as no one else is SUPER.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure RemoveSuperPermissionsFromSuperUserTest()
    var
        UserPermissions: Codeunit "User Permissions";
        Any: Codeunit Any;
        FirstUserId: Guid;
        SecondUserId: Guid;
    begin
        // [Given] two SUPER users
        PermissionsMock.Stop();
        DeleteAllUsersAndPermissions();
        FirstUserId := AddUser(Any.AlphabeticText(10), true, false);
        SecondUserId := AddUser(Any.AlphabeticText(10), true, false);

        AddPermissions(FirstUserId, SUPERTok, '');
        AddPermissions(SecondUserId, SUPERTok, '');

        // The first user is SUPER
        Assert.IsTrue(UserPermissions.IsSuper(FirstUserId), 'The first user should be SUPER.');

        // [When] remove the SUPER permissions from the first user
        UserPermissions.RemoveSuperPermissions(FirstUserId);

        // [Then] the first user is not SUPER anymore
        Assert.IsFalse(UserPermissions.IsSuper(FirstUserId), 'The first user should not be SUPER anymore.');

        // [Then] the second user is still SUPER
        Assert.IsTrue(UserPermissions.IsSuper(SecondUserId), 'The second user should be SUPER.');

        // [When] add SUPER permissions to the first user
        AddPermissions(FirstUserId, SUPERTok, '');

        // [Then] the first user is SUPER again
        Assert.IsTrue(UserPermissions.IsSuper(FirstUserId), 'The first user should be super again.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DeleteAccessControlSuperUserTest()
    var
        AccessControl: Record "Access Control";
        UserPermissions: Codeunit "User Permissions";
        UserPermissionsTest: Codeunit "User Permissions Test";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        Any: Codeunit Any;
        UserId: Guid;
    begin
        // [Given] a SUPER user
        DeleteAllUsersAndPermissions();
        UserId := AddUser(Any.AlphabeticText(10), true, false);
        AddPermissions(UserId, SUPERTok, '');

        PermissionsMock.Set('User Permission View');

        BindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        AccessControl.SetRange("User Security ID", UserId);

        // [When] try to delete the Access Control record
        asserterror AccessControl.DeleteAll(true);

        // [Then] an error occurs
        Assert.ExpectedError(SUPERPermissionErr);

        // [Then] the user is still SUPER
        Assert.IsTrue(UserPermissions.IsSuper(UserId), 'The user should still be SUPER.');

        UnbindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DeleteNonSuperAccessControlTest()
    var
        AccessControl: Record "Access Control";
        UserPermissionsTest: Codeunit "User Permissions Test";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        Any: Codeunit Any;
        UserId: Guid;
    begin
        // [Given] a SUPER user that has also a non-SUPER role
        DeleteAllUsersAndPermissions();
        UserId := AddUser(Any.AlphabeticText(10), true, false);
        AddPermissions(UserId, SUPERTok, '');
        AddPermissions(UserId, NotSUPERTok, '');

        BindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        AccessControl.SetRange("User Security ID", UserId);
        AccessControl.SetRange("Role ID", NotSUPERTok);

        // [When] trying to delete the non-SUPER Access Control record
        AccessControl.DeleteAll(true);

        // [Then] no error occurs
        Assert.AreEqual('', GetLastErrorText(), 'It should be possible to delete non-SUPER permissions from a SUPER user.');

        UnbindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DeleteAccessControlNotSaasTest()
    var
        AccessControl: Record "Access Control";
        UserPermissionsTest: Codeunit "User Permissions Test";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        Any: Codeunit Any;
        UserId: Guid;
    begin
        // [Given] a SUPER user
        DeleteAllUsersAndPermissions();
        UserId := AddUser(Any.AlphabeticText(10), true, false);
        AddPermissions(UserId, SUPERTok, '');

        BindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        AccessControl.SetRange("User Security ID", UserId);

        // [When] try to delete the Access Control record when not on SaaS
        AccessControl.DeleteAll(true);

        // [Then] no error occurs
        Assert.AreEqual('', GetLastErrorText(), 'It should be possible to delete permissions when not on SaaS.');

        UnbindSubscription(UserPermissionsTest);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DeleteAccessControlFromNonSuperUserTest()
    var
        AccessControl: Record "Access Control";
        UserPermissionsTest: Codeunit "User Permissions Test";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        Any: Codeunit Any;
        UserId: Guid;
    begin
        // [Given] a non-SUPER user
        DeleteAllUsersAndPermissions();
        UserId := AddUser(Any.AlphabeticText(10), true, false);
        AddPermissions(UserId, NotSUPERTok, '');

        BindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        AccessControl.SetRange("User Security ID", UserId);

        // [When] trying to delete the Access Control record
        AccessControl.DeleteAll(true);

        // [Then] no error occurs
        Assert.AreEqual('', GetLastErrorText(), 'It should be possible to delete permissions from non-SUPER user.');

        UnbindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DisableNonSuperUserTest()
    var
        User: Record User;
        UserPermissionsTest: Codeunit "User Permissions Test";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        Any: Codeunit Any;
        UserId: Guid;
    begin
        // [Given] a non-SUPER user
        DeleteAllUsersAndPermissions();
        UserId := AddUser(Any.AlphabeticText(10), true, false);
        AddPermissions(UserId, NotSUPERTok, '');

        BindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        User.Get(UserId);

        // [When] try to delete the Access Control record
        User.Validate(State, User.State::Disabled);
        User.Modify(true);

        // [Then] no error occurs
        Assert.AreEqual('', GetLastErrorText(), 'It should be possible to disable a non-SUPER user.');

        UnbindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DisableSuperUserWhenAnotherIsSuperTest()
    var
        User: Record User;
        UserPermissionsTest: Codeunit "User Permissions Test";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        Any: Codeunit Any;
        FirstUserId: Guid;
        SecondUserId: Guid;
    begin
        // [Given] two SUPER users
        DeleteAllUsersAndPermissions();
        FirstUserId := AddUser(Any.AlphabeticText(10), true, false);
        SecondUserId := AddUser(Any.AlphabeticText(10), true, false);

        AddPermissions(FirstUserId, SUPERTok, '');
        AddPermissions(SecondUserId, SUPERTok, '');

        BindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        User.Get(FirstUserId);

        // [When] try to disable the first user
        User.Validate(State, User.State::Disabled);
        User.Modify(true);

        // [Then] no error occurs
        Assert.AreEqual('', GetLastErrorText(), 'It should be possible to disable a SUPER user when there is another SUPER user.');

        UnbindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DisableSuperUserWhenAnotherNonSuperUserTest()
    var
        User: Record User;
        UserPermissionsTest: Codeunit "User Permissions Test";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        Any: Codeunit Any;
        FirstUserId: Guid;
        SecondUserId: Guid;
    begin
        // [Given] a SUPER user and a non-SUPER user
        DeleteAllUsersAndPermissions();
        FirstUserId := AddUser(Any.AlphabeticText(10), true, false);
        SecondUserId := AddUser(Any.AlphabeticText(10), true, false);

        AddPermissions(FirstUserId, SUPERTok, '');
        AddPermissions(SecondUserId, NotSUPERTok, '');

        BindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        User.Get(FirstUserId);

        // [When] try to disable the SUPER user
        User.Validate(State, User.State::Disabled);
        asserterror User.Modify(true);

        // [Then] an error occurs
        Assert.AreEqual(SUPERPermissionErr, GetLastErrorText(), 'It should not be possible to disable the only SUPER user.');

        UnbindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure EnableSuperUserTest()
    var
        User: Record User;
        UserPermissionsTest: Codeunit "User Permissions Test";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        Any: Codeunit Any;
        UserId: Guid;
    begin
        // [Given] a disabled SUPER user
        DeleteAllUsersAndPermissions();
        UserId := AddUser(Any.AlphabeticText(10), false, false);

        AddPermissions(UserId, SUPERTok, '');

        BindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        User.Get(UserId);

        // [When] try to enable the first user
        User.Validate(State, User.State::Enabled);
        User.Modify(true);

        // [Then] no error occurs
        Assert.AreEqual('', GetLastErrorText(), 'It should be possible to enable a SUPER user.');

        UnbindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DisableSuperUserFailsTest()
    var
        User: Record User;
        UserPermissionsTest: Codeunit "User Permissions Test";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        Any: Codeunit Any;
        UserId: Guid;
    begin
        // [Given] an enabled SUPER user
        DeleteAllUsersAndPermissions();
        UserId := AddUser(Any.AlphabeticText(10), true, false);
        AddPermissions(UserId, SUPERTok, '');

        User.Get(UserId);

        BindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        Assert.AreEqual(User.State::Enabled, User.State, 'User should be enabled.');

        // [When] try to disable the user
        User.State := User.State::Disabled;

        // [Then] an error occurs
        asserterror User.Modify(true);
        Assert.AreEqual(SUPERPermissionErr, GetLastErrorText(), 'It should not be possible to disable the only SUPER user.');

        UnbindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DeleteNonSuperUserTest()
    var
        User: Record User;
        UserPermissionsTest: Codeunit "User Permissions Test";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        Any: Codeunit Any;
        UserId: Guid;
    begin
        // [Given] a non-SUPER user
        DeleteAllUsersAndPermissions();
        UserId := AddUser(Any.AlphabeticText(10), true, false);
        AddPermissions(UserId, NotSUPERTok, '');

        User.Get(UserId);

        BindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [When] try to delete the user
        User.Delete(true);

        // [Then] no error occurs 
        Assert.AreEqual('', GetLastErrorText(), 'It should be possible to delete a non-SUPER user.');

        UnbindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DeleteSuperUserFailsTest()
    var
        User: Record User;
        UserPermissionsTest: Codeunit "User Permissions Test";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        Any: Codeunit Any;
        UserId: Guid;
    begin
        // [Given] a SUPER user
        DeleteAllUsersAndPermissions();
        UserId := AddUser(Any.AlphabeticText(10), true, false);

        AddPermissions(UserId, SUPERTok, '');
        User.Get(UserId);

        BindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [When] try to delete the only SUPER user
        asserterror User.Delete(true);

        // [Then] an error occurs 
        Assert.AreEqual(SUPERPermissionErr, GetLastErrorText(), 'It should not be possible to delete the only SUPER user.');

        UnbindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DeleteSuperUserWhenAnotherUserIsSuperTest()
    var
        User: Record User;
        UserPermissionsTest: Codeunit "User Permissions Test";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        Any: Codeunit Any;
        FirstUserId: Guid;
        SecondUserId: Guid;
    begin
        // [Given] two SUPER users
        DeleteAllUsersAndPermissions();
        FirstUserId := AddUser(Any.AlphabeticText(10), true, false);
        SecondUserId := AddUser(Any.AlphabeticText(10), true, false);

        AddPermissions(FirstUserId, SUPERTok, '');
        AddPermissions(SecondUserId, SUPERTok, '');

        User.Get(FirstUserId);

        BindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [When] try to delete the first user
        User.Delete(true);

        // [Then] no error occurs 
        Assert.AreEqual('', GetLastErrorText(), 'It should not be possible to delete a SUPER user when there is another SUPER user.');

        UnbindSubscription(UserPermissionsTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    local procedure DeleteAllUsersAndPermissions()
    var
        AccessControl: Record "Access Control";
        User: Record User;
    begin
        AccessControl.DeleteAll();
        User.DeleteAll();
    end;

    local procedure AddUser(UserName: Text; Enabled: Boolean; isExternalUser: Boolean): Guid
    var
        User: Record User;
    begin
        User.Init();

        User."User Security ID" := System.CreateGuid();
        User."User Name" := CopyStr(UserName, 1, MaxStrLen(User."User Name"));

        if (Enabled) then
            User.State := User.State::Enabled
        else
            User.State := User.State::Disabled;

        if (isExternalUser) then
            User."License Type" := User."License Type"::"External User"
        else
            User."License Type" := User."License Type"::"Full User";

        User.Insert();

        exit(User."User Security ID");
    end;

    local procedure AddPermissions(UserId: Guid; Role: Code[20]; CompanyName: Text[30])
    var
        AccessControl: Record "Access Control";
    begin
        AccessControl.Init();
        AccessControl."User Security ID" := UserId;
        AccessControl."Role ID" := Role;
        AccessControl."Company Name" := CompanyName;
        AccessControl.Insert();
    end;
}
