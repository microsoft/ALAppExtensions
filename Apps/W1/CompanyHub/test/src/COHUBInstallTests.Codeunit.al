codeunit 139774 "COHUB Install Tests"
{
    Subtype = Test;

    [Test]
    procedure UserGroupsTest()
    var
        AllProfile: Record "All Profile";
        UserGroup: Record "User Group";
        UserGroupPermissionSet: Record "User Group Permission Set";
        AggregatePermissionSet: Record "Aggregate Permission Set";
    begin
        // [SCENARIO] Company Hub User Group is created on Install
        Assert.IsTrue(UserGroup.Get('D365 COMPANY HUB'), 'Company Hub User Group was not created.');
        Assert.AreEqual('Dyn. 365 Company Hub', UserGroup.Name, 'A different Name was expected.');

        AllProfile.SetRange("Role Center ID", Page::"Business Manager Role Center");
        AllProfile.FindFirst();

        Assert.IsFalse(UserGroup."Assign to All New Users", 'Assign to new Users was expected to be false.');
        Assert.AreEqual(AllProfile."Profile ID", UserGroup."Default Profile ID", 'A different default profile ID was expected.');
        Assert.AreEqual(AllProfile."App ID", UserGroup."Default Profile App ID", 'A different default profile App ID was expected.');
        Assert.AreEqual(AllProfile.Scope, UserGroup."Default Profile Scope", 'A different default profile scope was expected.');
        
        AggregatePermissionSet.SetRange("Role ID", 'D365 COMPANY HUB');
        AggregatePermissionSet.FindFirst();

        UserGroupPermissionSet.SetRange("Role ID", 'D365 COMPANY HUB');
        UserGroupPermissionSet.SetRange("User Group Code", 'D365 COMPANY HUB');
        UserGroupPermissionSet.SetRange(Scope, UserGroupPermissionSet.Scope::System);
        UserGroupPermissionSet.SetRange("App ID", AggregatePermissionSet."App ID");

        Assert.IsTrue(UserGroupPermissionSet.FindFirst(), 'Company hub Permisison Set was not in User Group');

        AggregatePermissionSet.SetRange("Role ID", 'LOCAL');
        
        UserGroupPermissionSet.SetRange("Role ID", 'LOCAL');
        UserGroupPermissionSet.SetRange("User Group Code", 'D365 COMPANY HUB');
        UserGroupPermissionSet.SetRange(Scope, UserGroupPermissionSet.Scope::System);
        UserGroupPermissionSet.SetRange("App ID");
        Assert.AreEqual(AggregatePermissionSet.FindFirst(), UserGroupPermissionSet.FindFirst(), 'LOCAL Permission Set was missing');
    end;

    [Test]
    procedure PermissionsTest()
    var
        PermissionSet: Record "Permission Set";
        Permission: Record "Permission";
    begin
        // [SCENARIO] Company Hub Permissions are created on Install for Legacy Systems, come with the extension on new systems
        PermissionSet.SetRange("Role ID", 'D365 COMPANY HUB');
        Assert.RecordIsNotEmpty(PermissionSet);

        Permission.SetRange("Role ID", 'D365 COMPANY HUB');
        Permission.SetRange("Object Type", Permission."Object Type"::"Table Data");
        Permission.SetRange("Read Permission", Permission."Read Permission"::Yes);
        Permission.SetRange("Insert Permission", Permission."Insert Permission"::Yes);
        Permission.SetRange("Modify Permission", Permission."Modify Permission"::Yes);
        Permission.SetRange("Delete Permission", Permission."Delete Permission"::Yes);
        Permission.SetRange("Object ID", 1151);
        Assert.RecordIsNotEmpty(Permission);
        Permission.SetRange("Object ID", 1152);
        Assert.RecordIsNotEmpty(Permission);
        Permission.SetRange("Object ID", 1153);
        Assert.RecordIsNotEmpty(Permission);
        Permission.SetRange("Object ID", 1154);
        Assert.RecordIsNotEmpty(Permission);
        Permission.SetRange("Object ID", 1155);
        Assert.RecordIsNotEmpty(Permission);
        Permission.SetRange("Object ID", 1156);
        Assert.RecordIsNotEmpty(Permission);
    end;

    var
        Assert: Codeunit "Library Assert";
}