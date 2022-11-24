// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132438 "Permission Relation Tests"
{
    // [FEATURE] [Permission Sets] [UT]

    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";
        RoleIdLbl: Label 'TEST SET A', Locked = true;
        RoleIdBLbl: Label 'TEST SET B', Locked = true;
        RoleIdCLbl: Label 'TEST SET C', Locked = true;
        RoleIdDLbl: Label 'TEST SET D', Locked = true;
        NewRoleIdLbl: Label 'TEST SET', Locked = true;
        NewNameLbl: Label 'Test Set', Locked = true;
        AnotherRoleIdLbl: Label 'ANOTHER SET', Locked = true;
        IncludedTok: Label 'Full', Locked = true;
        ExcludedTok: Label 'Excluded', Locked = true;
        PartialTok: Label 'Partial', Locked = true;
        PermissionSetNotfoundLbl: Label '%1 permission set could not be found.', Comment = '%1 - Permission set name', Locked = true;
        EnabledActionErr: Label '%1 control is enabled on %2 page.', Comment = '%1 = Object Type; %2 = Permissions page.';
        DisabledActionErr: Label '%1 control is disabled on %2 page.', Comment = '%1 = Object Type; %2 = Permissions page.';
        Scope: Option System,Tenant;

    [Test]
    [HandlerFunctions('LookupPermissionSetAModalHandler')]
    procedure TestIncludePermissionSet()
    var
        AggregatePermissionSet: Record "Aggregate Permission Set";
        TenantPermissionSet: Record "Tenant Permission Set";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionSetPage: TestPage "Permission Set";
        AppId: Guid;
        NullGuid: Guid;
    begin
        // [SCENARIO] Include a a permission set

        // [GIVEN] A new empty permission set
        TenantPermissionSet.SetRange("Role ID", NewRoleIdLbl);
        TenantPermissionSet.DeleteAll();

        TenantPermissionSet.Init();
        TenantPermissionSet."Role ID" := NewRoleIdLbl;
        TenantPermissionSet.Name := NewNameLbl;
        TenantPermissionSet.Insert();
        VerifyEmptyExpandedPermissions(NewRoleIdLbl, NullGuid);

        // [WHEN] Opening the permission page 
        PermissionSetPage.Trap();
        PermissionSetRelation.OpenPermissionSetPage(NewNameLbl, NewRoleIdLbl, NullGuid, Scope::Tenant);
        LibraryAssert.AreEqual(NewRoleIdLbl, PermissionSetPage."Role ID".Value(), 'Role ID is not as expected.');

        // [WHEN] Including a permission set
        PermissionSetPage.PermissionSets.New();
        PermissionSetPage.PermissionSets."Related Role ID".Drilldown(); // LookupPermissionSetAModalHandler will include set A

        AggregatePermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(AggregatePermissionSet.FindFirst(), 'Permission set not found');
        AppId := AggregatePermissionSet."App ID";

        // [THEN] Permission set a is included
        PermissionSetPage.PermissionSetTree.First();
        LibraryAssert.AreEqual(RoleIdLbl, PermissionSetPage.PermissionSetTree."Related Role ID As Text".Value, 'Role ID of included permission set is not A');
        LibraryAssert.AreEqual(IncludedTok, PermissionSetPage.PermissionSetTree."Inclusion Status".Value, 'Inclusion status is not included');
        PermissionSetPage.PermissionSetTree.Expand(true);

        // [THEN] Permission set b is included
        PermissionSetPage.PermissionSetTree.Next();
        LibraryAssert.AreEqual(RoleIdBLbl, PermissionSetPage.PermissionSetTree."Related Role ID As Text".Value, 'Role ID of included permission set is not B');
        LibraryAssert.AreEqual(IncludedTok, PermissionSetPage.PermissionSetTree."Inclusion Status".Value, 'Inclusion status is not included');

        // [THEN] Permission set c is included
        PermissionSetPage.PermissionSetTree.Next();
        LibraryAssert.AreEqual(RoleIdCLbl, PermissionSetPage.PermissionSetTree."Related Role ID As Text".Value, 'Role ID of included permission set is not C');
        LibraryAssert.AreEqual(IncludedTok, PermissionSetPage.PermissionSetTree."Inclusion Status".Value, 'Inclusion status is not included');
        PermissionSetPage.PermissionSetTree.Expand(true);

        // [THEN] Permission set d is included
        PermissionSetPage.PermissionSetTree.Next();
        LibraryAssert.AreEqual(RoleIdDLbl, PermissionSetPage.PermissionSetTree."Related Role ID As Text".Value, 'Role ID of included permission set is not D');
        LibraryAssert.AreEqual(IncludedTok, PermissionSetPage.PermissionSetTree."Inclusion Status".Value, 'Inclusion status is not included');
    end;

    [Test]
    [HandlerFunctions('LookupPermissionSetAModalHandler')]
    procedure TestExcludePermissionSet()
    var
        AggregatePermissionSet: Record "Aggregate Permission Set";
        TenantPermissionSet: Record "Tenant Permission Set";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionSetPage: TestPage "Permission Set";
        AppId: Guid;
        NullGuid: Guid;
    begin
        // [SCENARIO] Exclude a a permission set

        // [GIVEN] A new empty permission set
        TenantPermissionSet.SetRange("Role ID", NewRoleIdLbl);
        TenantPermissionSet.DeleteAll();

        TenantPermissionSet.Init();
        TenantPermissionSet."Role ID" := NewRoleIdLbl;
        TenantPermissionSet.Name := NewNameLbl;
        TenantPermissionSet.Insert();
        VerifyEmptyExpandedPermissions(NewRoleIdLbl, NullGuid);

        // [WHEN] Opening the permission page 
        PermissionSetPage.Trap();
        PermissionSetRelation.OpenPermissionSetPage(NewNameLbl, NewRoleIdLbl, NullGuid, Scope::Tenant);
        LibraryAssert.AreEqual(NewRoleIdLbl, PermissionSetPage."Role ID".Value(), 'Role ID is not as expected.');

        // [WHEN] Including a permission set
        PermissionSetPage.PermissionSets.New();
        PermissionSetPage.PermissionSets."Related Role ID".Drilldown(); // LookupPermissionSetAModalHandler will include set A

        // [WHEN] Excluding a lower level permission set
        AggregatePermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(AggregatePermissionSet.FindFirst(), 'Permission set not found');
        AppId := AggregatePermissionSet."App ID";

        PermissionSetPage.PermissionSetTree.First(); // Permission Set A
        PermissionSetPage.PermissionSetTree.Expand(true);
        PermissionSetPage.PermissionSetTree.Next(); // Permission Set B
        PermissionSetPage.PermissionSetTree.Expand(true);
        PermissionSetPage.PermissionSetTree.Next(); // Permission Set C
        PermissionSetPage.PermissionSetTree.Expand(true);
        PermissionSetPage.PermissionSetTree.Next(); // Permission Set D
        PermissionSetPage.PermissionSetTree.ExcludeSelectedPermissionSet.Invoke();

        // [THEN] Permission set a is partially included
        PermissionSetPage.PermissionSetTree.First();
        LibraryAssert.AreEqual(RoleIdLbl, PermissionSetPage.PermissionSetTree."Related Role ID As Text".Value, 'Role ID of included permission set is not A');
        LibraryAssert.AreEqual(PartialTok, PermissionSetPage.PermissionSetTree."Inclusion Status".Value, 'Inclusion status is not partial');

        // [THEN] Permission set b is included
        PermissionSetPage.PermissionSetTree.Next();
        LibraryAssert.AreEqual(RoleIdBLbl, PermissionSetPage.PermissionSetTree."Related Role ID As Text".Value, 'Role ID of included permission set is not B');
        LibraryAssert.AreEqual(IncludedTok, PermissionSetPage.PermissionSetTree."Inclusion Status".Value, 'Inclusion status is not included');

        // [THEN] Permission set c is partially included
        PermissionSetPage.PermissionSetTree.Next();
        LibraryAssert.AreEqual(RoleIdCLbl, PermissionSetPage.PermissionSetTree."Related Role ID As Text".Value, 'Role ID of included permission set is not C');
        LibraryAssert.AreEqual(PartialTok, PermissionSetPage.PermissionSetTree."Inclusion Status".Value, 'Inclusion status is not partial');

        // [THEN] Permission set d is excluded
        PermissionSetPage.PermissionSetTree.Next();
        LibraryAssert.AreEqual(RoleIdDLbl, PermissionSetPage.PermissionSetTree."Related Role ID As Text".Value, 'Role ID of included permission set is not D');
        LibraryAssert.AreEqual(ExcludedTok, PermissionSetPage.PermissionSetTree."Inclusion Status".Value, 'Inclusion status is not excluded');
    end;


    [Test]
    [HandlerFunctions('LookupPermissionSetAModalHandler')]
    procedure TestExcludeAndIncludePermissionSetAgain()
    var
        AggregatePermissionSet: Record "Aggregate Permission Set";
        TenantPermissionSet: Record "Tenant Permission Set";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionSetPage: TestPage "Permission Set";
        PermissionSetTypeOption: Option Include,Exclude;
        AppId: Guid;
        NullGuid: Guid;
    begin
        // [SCENARIO] Exclude a a permission set

        // [GIVEN] A new empty permission set
        TenantPermissionSet.SetRange("Role ID", NewRoleIdLbl);
        TenantPermissionSet.DeleteAll();

        TenantPermissionSet.Init();
        TenantPermissionSet."Role ID" := NewRoleIdLbl;
        TenantPermissionSet.Name := NewNameLbl;
        TenantPermissionSet.Insert();
        VerifyEmptyExpandedPermissions(NewRoleIdLbl, NullGuid);

        // [WHEN] Opening the permission page 
        PermissionSetPage.Trap();
        PermissionSetRelation.OpenPermissionSetPage(NewNameLbl, NewRoleIdLbl, NullGuid, Scope::Tenant);
        LibraryAssert.AreEqual(NewRoleIdLbl, PermissionSetPage."Role ID".Value(), 'Role ID is not as expected.');

        // [WHEN] Including a permission set
        PermissionSetPage.PermissionSets.New();
        PermissionSetPage.PermissionSets."Related Role ID".Drilldown(); // LookupPermissionSetAModalHandler will include set A

        // [WHEN] Excluding a lower level permission set
        AggregatePermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(AggregatePermissionSet.FindFirst(), 'Permission set not found');
        AppId := AggregatePermissionSet."App ID";

        PermissionSetPage.PermissionSetTree.First();
        PermissionSetPage.PermissionSetTree.Expand(true);
        PermissionSetPage.PermissionSetTree.Last();
        PermissionSetPage.PermissionSetTree.Expand(true);
        PermissionSetPage.PermissionSetTree.Last();
        PermissionSetPage.PermissionSetTree.ExcludeSelectedPermissionSet.Invoke();

        // [WHEN] Including that permission set again
        PermissionSetPage.PermissionSets.Last();
        PermissionSetPage.PermissionSets.Type.SetValue(PermissionSetTypeOption::Include);

        // [THEN] Permission set a is included
        PermissionSetPage.PermissionSetTree.First();
        LibraryAssert.AreEqual(RoleIdLbl, PermissionSetPage.PermissionSetTree."Related Role ID As Text".Value, 'Role ID of included permission set is not A');
        LibraryAssert.AreEqual(IncludedTok, PermissionSetPage.PermissionSetTree."Inclusion Status".Value, 'Inclusion status is not included');
        PermissionSetPage.PermissionSetTree.Expand(true);

        // [THEN] Permission set b is included
        PermissionSetPage.PermissionSetTree.Next();
        LibraryAssert.AreEqual(RoleIdBLbl, PermissionSetPage.PermissionSetTree."Related Role ID As Text".Value, 'Role ID of included permission set is not B');
        LibraryAssert.AreEqual(IncludedTok, PermissionSetPage.PermissionSetTree."Inclusion Status".Value, 'Inclusion status is not included');

        // [THEN] Permission set c is included
        PermissionSetPage.PermissionSetTree.Next();
        LibraryAssert.AreEqual(RoleIdCLbl, PermissionSetPage.PermissionSetTree."Related Role ID As Text".Value, 'Role ID of included permission set is not C');
        LibraryAssert.AreEqual(IncludedTok, PermissionSetPage.PermissionSetTree."Inclusion Status".Value, 'Inclusion status is not included');
        PermissionSetPage.PermissionSetTree.Expand(true);

        // [THEN] Permission set d is included
        PermissionSetPage.PermissionSetTree.Next();
        LibraryAssert.AreEqual(RoleIdDLbl, PermissionSetPage.PermissionSetTree."Related Role ID As Text".Value, 'Role ID of included permission set is not D');
        LibraryAssert.AreEqual(IncludedTok, PermissionSetPage.PermissionSetTree."Inclusion Status".Value, 'Inclusion status is not included');
    end;

    [Test]
    [HandlerFunctions('LookupPermissionSetAModalHandler')]
    procedure TestIncludeAndDeletePermissionSet()
    var
        AggregatePermissionSet: Record "Aggregate Permission Set";
        TenantPermissionSet: Record "Tenant Permission Set";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionSetRelationImpl: Codeunit "Permission Set Relation Impl.";
        PermissionSetPage: TestPage "Permission Set";
        AppId: Guid;
        NullGuid: Guid;
    begin
        // [SCENARIO] Include a a permission set and then delete

        // [GIVEN] A new empty permission set
        TenantPermissionSet.SetRange("Role ID", NewRoleIdLbl);
        TenantPermissionSet.DeleteAll();

        TenantPermissionSet.Init();
        TenantPermissionSet."Role ID" := NewRoleIdLbl;
        TenantPermissionSet.Name := NewNameLbl;
        TenantPermissionSet.Insert();
        VerifyEmptyExpandedPermissions(NewRoleIdLbl, NullGuid);

        // [WHEN] Opening the permission page 
        PermissionSetPage.Trap();
        PermissionSetRelation.OpenPermissionSetPage(NewNameLbl, NewRoleIdLbl, NullGuid, Scope::Tenant);
        LibraryAssert.AreEqual(NewRoleIdLbl, PermissionSetPage."Role ID".Value(), 'Role ID is not as expected.');

        // [WHEN] Including a permission set
        PermissionSetPage.PermissionSets.New();
        PermissionSetPage.PermissionSets."Related Role ID".Drilldown(); // LookupPermissionSetAModalHandler will include set A

        // [WHEN] Deleting the permission set
        AggregatePermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(AggregatePermissionSet.FindFirst(), 'Permission set not found');
        AppId := AggregatePermissionSet."App ID";
        PermissionSetRelationImpl.RemovePermissionSet(NullGuid, NewRoleIdLbl, AppId, RoleIdLbl); // Delete through impl. codeunit, as testpage does not support page OnDelete trigger
        PermissionSetPage.Close();
        PermissionSetPage.Trap();
        PermissionSetRelation.OpenPermissionSetPage(NewNameLbl, NewRoleIdLbl, NullGuid, Scope::Tenant);

        // [THEN] Permission set is deleted
        PermissionSetPage.PermissionSetTree.First();
        LibraryAssert.AreEqual('', PermissionSetPage.PermissionSetTree."Related Role ID As Text".Value, 'Role ID of included permission set is not A');
        LibraryAssert.AreEqual('', PermissionSetPage.PermissionSetTree."Inclusion Status".Value, 'Inclusion status is not partial');
    end;

    [Test]
    [HandlerFunctions('LookupPermissionSetAModalHandler')]
    procedure TestIncludeAndThenExcludePermissionSet()
    var
        AggregatePermissionSet: Record "Aggregate Permission Set";
        TenantPermissionSet: Record "Tenant Permission Set";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionSetPage: TestPage "Permission Set";
        AppId: Guid;
        NullGuid: Guid;
    begin
        // [SCENARIO] Include a a permission set and then exclude it

        // [GIVEN] A new empty permission set
        TenantPermissionSet.SetRange("Role ID", NewRoleIdLbl);
        TenantPermissionSet.DeleteAll();

        TenantPermissionSet.Init();
        TenantPermissionSet."Role ID" := NewRoleIdLbl;
        TenantPermissionSet.Name := NewNameLbl;
        TenantPermissionSet.Insert();
        VerifyEmptyExpandedPermissions(NewRoleIdLbl, NullGuid);

        // [WHEN] Opening the permission page 
        PermissionSetPage.Trap();
        PermissionSetRelation.OpenPermissionSetPage(NewNameLbl, NewRoleIdLbl, NullGuid, Scope::Tenant);
        LibraryAssert.AreEqual(NewRoleIdLbl, PermissionSetPage."Role ID".Value(), 'Role ID is not as expected.');

        // [WHEN] Including a permission set
        PermissionSetPage.PermissionSets.New();
        PermissionSetPage.PermissionSets."Related Role ID".Drilldown(); // LookupPermissionSetAModalHandler will include set A

        // [WHEN] Excluding the permission set
        AggregatePermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(AggregatePermissionSet.FindFirst(), 'Permission set not found');
        AppId := AggregatePermissionSet."App ID";

        PermissionSetPage.PermissionSetTree.First();
        PermissionSetPage.PermissionSetTree.ExcludeSelectedPermissionSet.Invoke();

        // [THEN] Permission set is excluded
        PermissionSetPage.PermissionSets.First();
        LibraryAssert.AreEqual('', PermissionSetPage.PermissionSetTree."Related Role ID As Text".Value, 'Role ID of included permission set is not A');
        LibraryAssert.AreEqual('', PermissionSetPage.PermissionSetTree."Inclusion Status".Value, 'Inclusion status is not partial');
    end;

    [Test]
    procedure TestIncludePermissionToPermissionSet()
    var
        TenantPermission: Record "Tenant Permission";
        TenantPermissionSet: Record "Tenant Permission Set";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionSetPage: TestPage "Permission Set";
        NullGuid: Guid;
    begin
        // [SCENARIO] Include a permission. Include X for a codeunit.

        // [GIVEN] A new empty permission set
        TenantPermissionSet.SetRange("Role ID", NewRoleIdLbl);
        TenantPermissionSet.DeleteAll();
        TenantPermissionSet.Init();
        TenantPermissionSet."Role ID" := NewRoleIdLbl;
        TenantPermissionSet.Name := NewNameLbl;
        TenantPermissionSet.Insert();
        VerifyEmptyExpandedPermissions(NewRoleIdLbl, NullGuid);

        // [WHEN] Opening the permission page 
        PermissionSetPage.Trap();
        PermissionSetRelation.OpenPermissionSetPage(NewNameLbl, NewRoleIdLbl, NullGuid, Scope::Tenant);
        LibraryAssert.AreEqual(NewRoleIdLbl, PermissionSetPage."Role ID".Value(), 'Role ID is not as expected.');

        // [WHEN] Adding a permission to the set
        PermissionSetPage.Permissions.New();
        PermissionSetPage.Permissions."Object Type".SetValue(TenantPermission."Object Type"::Codeunit);
        PermissionSetPage.Permissions."Object ID".SetValue(Codeunit::"Permission Set Relation");
        PermissionSetPage.Permissions."Execute Permission".SetValue(TenantPermission."Execute Permission"::Yes);
        PermissionSetPage.Close();

        // [THEN] The new set contains the added permission with X
        VerifyContainsExpandedPermission(NewRoleIdLbl, NullGuid, TenantPermission."Object Type"::Codeunit, Codeunit::"Permission Set Relation",
                                         TenantPermission."Read Permission"::" ", TenantPermission."Insert Permission"::" ",
                                         TenantPermission."Modify Permission"::" ", TenantPermission."Delete Permission"::" ",
                                         TenantPermission."Execute Permission"::Yes);

        // [THEN] The new set only contains that permission
        VerifyExpandedPermissionCount(NewRoleIdLbl, NullGuid, 1);
    end;

    [Test]
    procedure TestExcludePermissionFromPermissionSet()
    var
        TenantPermission: Record "Tenant Permission";
        TenantPermissionSet: Record "Tenant Permission Set";
        MetadataPermissionSet: Record "Metadata Permission Set";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionSetPage: TestPage "Permission Set";
        AppId: Guid;
        NullGuid: Guid;
    begin
        // [SCENARIO] Exclude all permissions for an object. Remove RIMDX

        // [GIVEN] A new permission set with other included permission sets
        TenantPermissionSet.SetRange("Role ID", NewRoleIdLbl);
        TenantPermissionSet.DeleteAll();

        MetadataPermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(MetadataPermissionSet.FindFirst(), StrSubstNo(PermissionSetNotfoundLbl, RoleIdLbl));
        AppId := MetadataPermissionSet."App ID";

        PermissionSetRelation.CopyPermissionSet(NewRoleIdLbl, NewNameLbl, RoleIdLbl, AppId, Scope::System, Enum::"Permission Set Copy Type"::Reference);
        VerifyExpandedPermissionCount(NewRoleIdLbl, NullGuid, GetTestPermissionSetCount());

        // [WHEN] Opening the permission page 
        PermissionSetPage.Trap();
        PermissionSetRelation.OpenPermissionSetPage(NewNameLbl, NewRoleIdLbl, NullGuid, Scope::Tenant);
        LibraryAssert.AreEqual(NewRoleIdLbl, PermissionSetPage."Role ID".Value(), 'Role ID is not as expected.');

        // [WHEN] Adding an exclude permission to the set
        PermissionSetPage.Permissions.New();
        PermissionSetPage.Permissions.Type.SetValue(TenantPermission.Type::Exclude);
        PermissionSetPage.Permissions."Object Type".SetValue(TenantPermission."Object Type"::Codeunit);
        PermissionSetPage.Permissions."Object ID".SetValue(Codeunit::"Permission Set Relation");
        PermissionSetPage.Permissions."Execute Permission".SetValue(TenantPermission."Execute Permission"::Yes);
        PermissionSetPage.Close();

        // [THEN] The new set does not contain the added permission
        VerifyNotContainsExpandedPermission(NewRoleIdLbl, NullGuid, TenantPermission."Object Type"::Codeunit, Codeunit::"Permission Set Relation");

        // [THEN] The new set now contains one less permission
        VerifyExpandedPermissionCount(NewRoleIdLbl, NullGuid, GetTestPermissionSetCount() - 1);
    end;

    [Test]
    procedure TestExcludePartialPermissionFromPermissionSet()
    var
        TenantPermission: Record "Tenant Permission";
        TenantPermissionSet: Record "Tenant Permission Set";
        MetadataPermissionSet: Record "Metadata Permission Set";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionSetPage: TestPage "Permission Set";
        AppId: Guid;
        NullGuid: Guid;
    begin
        // [SCENARIO] Exclude part of a permission permission for an object. Change RIMD to RI.

        // [GIVEN] A new permission set with other included permission sets
        TenantPermissionSet.SetRange("Role ID", NewRoleIdLbl);
        TenantPermissionSet.DeleteAll();

        MetadataPermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(MetadataPermissionSet.FindFirst(), StrSubstNo(PermissionSetNotfoundLbl, RoleIdLbl));
        AppId := MetadataPermissionSet."App ID";

        PermissionSetRelation.CopyPermissionSet(NewRoleIdLbl, NewNameLbl, RoleIdLbl, AppId, Scope::System, Enum::"Permission Set Copy Type"::Reference);
        VerifyExpandedPermissionCount(NewRoleIdLbl, NullGuid, GetTestPermissionSetCount());

        // [WHEN] Opening the permission page 
        PermissionSetPage.Trap();
        PermissionSetRelation.OpenPermissionSetPage(NewNameLbl, NewRoleIdLbl, NullGuid, Scope::Tenant);
        LibraryAssert.AreEqual(NewRoleIdLbl, PermissionSetPage."Role ID".Value(), 'Role ID is not as expected.');

        // [WHEN] Adding an exclude for modify and delete permission to the set
        PermissionSetPage.Permissions.New();
        PermissionSetPage.Permissions.Type.SetValue(TenantPermission.Type::Exclude);
        PermissionSetPage.Permissions."Object Type".SetValue(TenantPermission."Object Type"::"Table Data");
        PermissionSetPage.Permissions."Object ID".SetValue(Database::"Test Table A");
        PermissionSetPage.Permissions."Read Permission".SetValue(TenantPermission."Read Permission"::" ");
        PermissionSetPage.Permissions."Insert Permission".SetValue(TenantPermission."Insert Permission"::" ");
        PermissionSetPage.Permissions."Modify Permission".SetValue(TenantPermission."Modify Permission"::Yes);
        PermissionSetPage.Permissions."Delete Permission".SetValue(TenantPermission."Delete Permission"::Yes);
        PermissionSetPage.Close();

        // [THEN] The new set does not contain the modify and delete permission, permission is now RI
        VerifyContainsExpandedPermission(NewRoleIdLbl, NullGuid, TenantPermission."Object Type"::"Table Data", Database::"Test Table A",
                                         TenantPermission."Read Permission"::Yes, TenantPermission."Insert Permission"::Yes,
                                         TenantPermission."Modify Permission"::" ", TenantPermission."Delete Permission"::" ",
                                         TenantPermission."Execute Permission"::" ");

        // [THEN] The new set contains the same number of permissions
        VerifyExpandedPermissionCount(NewRoleIdLbl, NullGuid, GetTestPermissionSetCount());
    end;

    [Test]
    procedure TestExcludePartialIndirectPermissionFromPermissionSet()
    var
        TenantPermission: Record "Tenant Permission";
        TenantPermissionSet: Record "Tenant Permission Set";
        MetadataPermissionSet: Record "Metadata Permission Set";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionSetPage: TestPage "Permission Set";
        AppId: Guid;
        NullGuid: Guid;
    begin
        // [SCENARIO] Exclude an indirect permission for an object. Change Rim to R

        // [GIVEN] A new permission set with other included permission sets
        TenantPermissionSet.SetRange("Role ID", NewRoleIdLbl);
        TenantPermissionSet.DeleteAll();

        MetadataPermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(MetadataPermissionSet.FindFirst(), StrSubstNo(PermissionSetNotfoundLbl, RoleIdLbl));
        AppId := MetadataPermissionSet."App ID";

        PermissionSetRelation.CopyPermissionSet(NewRoleIdLbl, NewNameLbl, RoleIdLbl, AppId, Scope::System, Enum::"Permission Set Copy Type"::Reference);
        VerifyExpandedPermissionCount(NewRoleIdLbl, NullGuid, GetTestPermissionSetCount());

        // [WHEN] Opening the permission page 
        PermissionSetPage.Trap();
        PermissionSetRelation.OpenPermissionSetPage(NewNameLbl, NewRoleIdLbl, NullGuid, Scope::Tenant);
        LibraryAssert.AreEqual(NewRoleIdLbl, PermissionSetPage."Role ID".Value(), 'Role ID is not as expected.');

        // [WHEN] Adding an exclude for modify and delete permission to the set
        PermissionSetPage.Permissions.New();
        PermissionSetPage.Permissions.Type.SetValue(TenantPermission.Type::Exclude);
        PermissionSetPage.Permissions."Object Type".SetValue(TenantPermission."Object Type"::"Table Data");
        PermissionSetPage.Permissions."Object ID".SetValue(Database::"Test Table B");
        PermissionSetPage.Permissions."Read Permission".SetValue(TenantPermission."Read Permission"::" ");
        PermissionSetPage.Permissions."Insert Permission".SetValue(TenantPermission."Insert Permission"::Yes);
        PermissionSetPage.Permissions."Modify Permission".SetValue(TenantPermission."Modify Permission"::Yes);
        PermissionSetPage.Close();

        // [THEN] The new set does not contain the modify and delete permission, permission is now RI
        VerifyContainsExpandedPermission(NewRoleIdLbl, NullGuid, TenantPermission."Object Type"::"Table Data", Database::"Test Table B",
                                         TenantPermission."Read Permission"::Yes, TenantPermission."Insert Permission"::" ",
                                         TenantPermission."Modify Permission"::" ", TenantPermission."Delete Permission"::" ",
                                         TenantPermission."Execute Permission"::" ");

        // [THEN] The new set contains the same number of permissions
        VerifyExpandedPermissionCount(NewRoleIdLbl, NullGuid, GetTestPermissionSetCount());
    end;


    [Test]
    procedure TestReduceToIndirectPermissionFromPermissionSet()
    var
        TenantPermission: Record "Tenant Permission";
        TenantPermissionSet: Record "Tenant Permission Set";
        MetadataPermissionSet: Record "Metadata Permission Set";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionSetPage: TestPage "Permission Set";
        AppId: Guid;
        NullGuid: Guid;
    begin
        // [SCENARIO] Change a direct permission to an indirect permission for an object. Change RIMD to RIm

        // [GIVEN] A new permission set with other included permission sets
        TenantPermissionSet.SetRange("Role ID", NewRoleIdLbl);
        TenantPermissionSet.DeleteAll();

        MetadataPermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(MetadataPermissionSet.FindFirst(), StrSubstNo(PermissionSetNotfoundLbl, RoleIdLbl));
        AppId := MetadataPermissionSet."App ID";

        PermissionSetRelation.CopyPermissionSet(NewRoleIdLbl, NewNameLbl, RoleIdLbl, AppId, Scope::System, Enum::"Permission Set Copy Type"::Reference);
        VerifyExpandedPermissionCount(NewRoleIdLbl, NullGuid, GetTestPermissionSetCount());

        // [WHEN] Opening the permission page 
        PermissionSetPage.Trap();
        PermissionSetRelation.OpenPermissionSetPage(NewNameLbl, NewRoleIdLbl, NullGuid, Scope::Tenant);
        LibraryAssert.AreEqual(NewRoleIdLbl, PermissionSetPage."Role ID".Value(), 'Role ID is not as expected.');

        // [WHEN] Adding an exclude for modify and delete permission to the set
        PermissionSetPage.Permissions.New();
        PermissionSetPage.Permissions.Type.SetValue(TenantPermission.Type::Exclude);
        PermissionSetPage.Permissions."Object Type".SetValue(TenantPermission."Object Type"::"Table Data");
        PermissionSetPage.Permissions."Object ID".SetValue(Database::"Test Table A");
        PermissionSetPage.Permissions."Read Permission".SetValue(TenantPermission."Read Permission"::" ");
        PermissionSetPage.Permissions."Insert Permission".SetValue(TenantPermission."Insert Permission"::" ");
        PermissionSetPage.Permissions."Modify Permission".SetValue(TenantPermission."Modify Permission"::Indirect);
        PermissionSetPage.Permissions."Delete Permission".SetValue(TenantPermission."Delete Permission"::Yes);
        PermissionSetPage.Close();

        // [THEN] The permission is now RIm for the table data.
        VerifyContainsExpandedPermission(NewRoleIdLbl, NullGuid, TenantPermission."Object Type"::"Table Data", Database::"Test Table A",
                                         TenantPermission."Read Permission"::Yes, TenantPermission."Insert Permission"::Yes,
                                         TenantPermission."Modify Permission"::Indirect, TenantPermission."Delete Permission"::" ",
                                         TenantPermission."Execute Permission"::" ");

        // [THEN] The new set contains the same number of permissions
        VerifyExpandedPermissionCount(NewRoleIdLbl, NullGuid, GetTestPermissionSetCount());
    end;

    [Test]
    procedure TestChangePermissionFromPermissionSet()
    var
        TenantPermission: Record "Tenant Permission";
        TenantPermissionSet: Record "Tenant Permission Set";
        MetadataPermissionSet: Record "Metadata Permission Set";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionSetPage: TestPage "Permission Set";
        NewRoleIdTwo: Code[30];
        NewNameTwo: Text;
        AppId: Guid;
        NullGuid: Guid;
    begin
        // [SCENARIO] Exclude all permissions for an object in one permission set. Include that in another an change the permission entirely. Change RIMD to Rim.

        // [GIVEN] A new permission set with other included permission sets
        TenantPermissionSet.SetRange("Role ID", NewRoleIdLbl);
        TenantPermissionSet.DeleteAll();

        MetadataPermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(MetadataPermissionSet.FindFirst(), StrSubstNo(PermissionSetNotfoundLbl, RoleIdLbl));
        AppId := MetadataPermissionSet."App ID";

        PermissionSetRelation.CopyPermissionSet(NewRoleIdLbl, NewNameLbl, RoleIdLbl, AppId, Scope::System, Enum::"Permission Set Copy Type"::Reference);
        VerifyExpandedPermissionCount(NewRoleIdLbl, NullGuid, GetTestPermissionSetCount());

        // [WHEN] Opening the permission page 
        PermissionSetPage.Trap();
        PermissionSetRelation.OpenPermissionSetPage(NewNameLbl, NewRoleIdLbl, NullGuid, Scope::Tenant);

        // [WHEN] Adding an exclude permission to the set
        PermissionSetPage.Permissions.New();
        PermissionSetPage.Permissions.Type.SetValue(TenantPermission.Type::Exclude);
        PermissionSetPage.Permissions."Object Type".SetValue(TenantPermission."Object Type"::"Table Data");
        PermissionSetPage.Permissions."Object ID".SetValue(Database::"Test Table A");
        PermissionSetPage.Permissions."Read Permission".SetValue(TenantPermission."Read Permission"::Yes);
        PermissionSetPage.Permissions."Insert Permission".SetValue(TenantPermission."Insert Permission"::Yes);
        PermissionSetPage.Permissions."Modify Permission".SetValue(TenantPermission."Modify Permission"::Yes);
        PermissionSetPage.Permissions."Delete Permission".SetValue(TenantPermission."Delete Permission"::Yes);
        PermissionSetPage.Permissions.Next();
        PermissionSetPage.Close();

        // [THEN] The new set does not contain the added permission
        VerifyNotContainsExpandedPermission(NewRoleIdLbl, NullGuid, TenantPermission."Object Type"::"Table Data", Database::"Test Table A");

        // [THEN] The new set now contains one less permission
        VerifyExpandedPermissionCount(NewRoleIdLbl, NullGuid, GetTestPermissionSetCount() - 1);

        // [GIVEN] A new permission set that includes the newly created one.
        NewRoleIdTwo := 'Test set two';
        NewNameTwo := 'Test set two';
        PermissionSetRelation.CopyPermissionSet(NewRoleIdTwo, NewNameTwo, NewRoleIdLbl, NullGuid, Scope::Tenant, Enum::"Permission Set Copy Type"::Reference);
        VerifyExpandedPermissionCount(UpperCase(NewRoleIdTwo), NullGuid, GetTestPermissionSetCount() - 1);

        // [WHEN] Opening the permission page 
        PermissionSetPage.Trap();
        PermissionSetRelation.OpenPermissionSetPage(NewNameTwo, NewRoleIdTwo, NullGuid, Scope::Tenant);

        // [WHEN] Adding an include permission to the set
        PermissionSetPage.Permissions.New();
        PermissionSetPage.Permissions."Object Type".SetValue(TenantPermission."Object Type"::"Table Data");
        PermissionSetPage.Permissions."Object ID".SetValue(Database::"Test Table A");
        PermissionSetPage.Permissions."Read Permission".SetValue(TenantPermission."Read Permission"::Yes);
        PermissionSetPage.Permissions."Insert Permission".SetValue(TenantPermission."Insert Permission"::Indirect);
        PermissionSetPage.Permissions."Modify Permission".SetValue(TenantPermission."Modify Permission"::Indirect);
        PermissionSetPage.Permissions."Delete Permission".SetValue(TenantPermission."Delete Permission"::" ");
        PermissionSetPage.Permissions.Next();
        PermissionSetPage.Close();

        // [THEN] The permission is now Rim for the table data.
        VerifyContainsExpandedPermission(NewRoleIdTwo, NullGuid, TenantPermission."Object Type"::"Table Data", Database::"Test Table A",
                                         TenantPermission."Read Permission"::Yes, TenantPermission."Insert Permission"::Indirect,
                                         TenantPermission."Modify Permission"::Indirect, TenantPermission."Delete Permission"::" ",
                                         TenantPermission."Execute Permission"::" ");

        // [THEN] The new set contains the same number of permissions
        VerifyExpandedPermissionCount(UpperCase(NewRoleIdTwo), NullGuid, GetTestPermissionSetCount());
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestPermissionsPageAddRelatedTablesAction()
    var
        TenantPermissionSet: Record "Tenant Permission Set";
        TenantPermission: Record "Tenant Permission";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionSetPage: TestPage "Permission Set";
        NullGuid: Guid;
    begin
        // [GIVEN] An empty tenant permission set
        TenantPermissionSet.SetRange("Role ID", NewRoleIdLbl);
        TenantPermissionSet.DeleteAll();

        TenantPermissionSet."Role ID" := NewRoleIdLbl;
        TenantPermissionSet."App ID" := NullGuid;
        TenantPermissionSet.Name := NewNameLbl;
        TenantPermissionSet.Insert();

        TenantPermission.SetRange("Role ID", TenantPermissionSet."Role ID");
        LibraryAssert.RecordIsEmpty(TenantPermission);

        // [WHEN] AddRelatedTablesAction is invoked
        PermissionSetPage.Trap();
        PermissionSetRelation.OpenPermissionSetPage(NewNameLbl, NewRoleIdLbl, NullGuid, Scope::Tenant);

        PermissionSetPage.Permissions.New();
        PermissionSetPage.Permissions."Object Type".SetValue(TenantPermission."Object Type"::"Table Data");
        PermissionSetPage.Permissions."Object ID".SetValue(Database::"Permission Set Relation Buffer");
        PermissionSetPage.Permissions."Read Permission".SetValue(TenantPermission."Read Permission"::Yes);

        PermissionSetPage.Permissions.AddRelatedTablesAction.Invoke();
        PermissionSetPage.Close();

        // [THEN] The expected number of related records is added to the permission set
        LibraryAssert.AreEqual(4, TenantPermission.Count(), 'Unexpected number of tenant permissions.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('ConfirmHandler')]
    procedure TestStartsAndStopsRecorderOnEditablePermissionSet()
    var
        TenantPermissionSet: Record "Tenant Permission Set";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionSetPage: TestPage "Permission Set";
        NullGuid: Guid;
    begin
        // [GIVEN] An empty tenant permission set
        TenantPermissionSet.SetRange("Role ID", NewRoleIdLbl);
        TenantPermissionSet.DeleteAll();

        TenantPermissionSet."Role ID" := NewRoleIdLbl;
        TenantPermissionSet."App ID" := NullGuid;
        TenantPermissionSet.Name := NewNameLbl;
        TenantPermissionSet.Insert();

        // [WHEN] The permission set page is opened
        PermissionSetPage.Trap();
        PermissionSetRelation.OpenPermissionSetPage(NewNameLbl, NewRoleIdLbl, NullGuid, Scope::Tenant);

        // [THEN] Initial state is that Start is enabled and Stop is not
        LibraryAssert.IsTrue(PermissionSetPage.Start.Enabled(),
          StrSubstNo(DisabledActionErr, 'Start', PermissionSetPage.Caption));
        LibraryAssert.IsFalse(PermissionSetPage.Stop.Enabled(),
          StrSubstNo(EnabledActionErr, 'Stop', PermissionSetPage.Caption));

        // [WHEN] Start is pressed
        PermissionSetPage.Start.Invoke();

        // [THEN] Stop is enabled and Start is not
        LibraryAssert.IsFalse(PermissionSetPage.Start.Enabled(),
          StrSubstNo(EnabledActionErr, 'Start', PermissionSetPage.Caption));
        LibraryAssert.IsTrue(PermissionSetPage.Stop.Enabled(),
          StrSubstNo(DisabledActionErr, 'Stop', PermissionSetPage.Caption));

        // [WHEN] Stop is pressed
        PermissionSetPage.Stop.Invoke();

        // [THEN] Start is enabled and Stop is not
        LibraryAssert.IsTrue(PermissionSetPage.Start.Enabled(),
          StrSubstNo(DisabledActionErr, 'Start', PermissionSetPage.Caption));
        LibraryAssert.IsFalse(PermissionSetPage.Stop.Enabled(),
          StrSubstNo(EnabledActionErr, 'Stop', PermissionSetPage.Caption));

        // Cannot confirm the correct recording while in a test
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure TestRecordPermissions()
    var
        TenantPermissionSet: Record "Tenant Permission Set";
        TempExpandedPermission: Record "Expanded Permission" temporary;
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionSetPage: TestPage "Permission Set";
        NullGuid: Guid;
    begin
        // [GIVEN] An empty tenant permission set
        TenantPermissionSet.SetRange("Role ID", NewRoleIdLbl);
        TenantPermissionSet.DeleteAll();

        TenantPermissionSet."Role ID" := NewRoleIdLbl;
        TenantPermissionSet."App ID" := NullGuid;
        TenantPermissionSet.Name := NewNameLbl;
        TenantPermissionSet.Insert();

        // [WHEN] The permission set page is opened
        PermissionSetPage.Trap();
        PermissionSetRelation.OpenPermissionSetPage(NewNameLbl, NewRoleIdLbl, NullGuid, Scope::Tenant);

        // [THEN] Initial state is that Start is enabled and Stop is not
        LibraryAssert.IsTrue(PermissionSetPage.Start.Enabled(),
          StrSubstNo(DisabledActionErr, 'Start', PermissionSetPage.Caption));
        LibraryAssert.IsFalse(PermissionSetPage.Stop.Enabled(),
          StrSubstNo(EnabledActionErr, 'Stop', PermissionSetPage.Caption));

        // [WHEN] Start is pressed
        TenantPermissionSet.SetRange("Role ID", AnotherRoleIdLbl);
        TenantPermissionSet.DeleteAll();
        PermissionSetPage.Start.Invoke();

        // [WHEN] An action requiring permissions is performed (insert a permission set)
        TenantPermissionSet."Role ID" := AnotherRoleIdLbl;
        TenantPermissionSet."App ID" := NullGuid;
        TenantPermissionSet.Name := NewNameLbl;
        TenantPermissionSet.Insert();

        // [WHEN] Stop is pressed
        PermissionSetPage.Stop.Invoke();

        // [THEN] Insert permission is added
        VerifyContainsExpandedPermission(NewRoleIdLbl, NullGuid, TempExpandedPermission."Object Type"::"Table Data", Database::"Tenant Permission Set",
            TempExpandedPermission."Read Permission"::" ", TempExpandedPermission."Insert Permission"::Yes,
            TempExpandedPermission."Modify Permission"::" ", TempExpandedPermission."Delete Permission"::" ",
            TempExpandedPermission."Execute Permission"::" ");

        // [WHEN] Start is pressed again
        PermissionSetPage.Start.Invoke();

        // [WHEN] An action requiring more permissions is performed (delete a permission set)
        TenantPermissionSet.SetRange("Role ID", AnotherRoleIdLbl);
        TenantPermissionSet.DeleteAll();

        // [WHEN] Stop is pressed
        PermissionSetPage.Stop.Invoke();

        // [THEN] More permissions are added
        VerifyContainsExpandedPermission(NewRoleIdLbl, NullGuid, TempExpandedPermission."Object Type"::"Table Data", Database::"Tenant Permission Set",
            TempExpandedPermission."Read Permission"::Yes, TempExpandedPermission."Insert Permission"::Yes,
            TempExpandedPermission."Modify Permission"::" ", TempExpandedPermission."Delete Permission"::Yes,
            TempExpandedPermission."Execute Permission"::" ");

    end;

    local procedure VerifyContainsExpandedPermission(RoleId: Code[30]; AppId: Guid; ObjType: Option; ObjId: Integer; Read: Option; Insert: Option; Modify: Option; Delete: Option; Execute: Option)
    var
        ExpandedPermission: Record "Expanded Permission";
    begin
        Commit(); // Needs to commit to ensure expanded permission is updated and avoid instabilities
        LibraryAssert.IsTrue(ExpandedPermission.Get(AppId, RoleId, ObjType, ObjId), 'Expanded permission set does not contain the expected permission.');
        LibraryAssert.AreEqual(ExpandedPermission."Read Permission", Read, 'Read permission is not set as expected.');
        LibraryAssert.AreEqual(ExpandedPermission."Insert Permission", Insert, 'Insert permission is not set as expected.');
        LibraryAssert.AreEqual(ExpandedPermission."Modify Permission", Modify, 'Modify permission is not set as expected.');
        LibraryAssert.AreEqual(ExpandedPermission."Delete Permission", Delete, 'Delete permission is not set as expected.');
        LibraryAssert.AreEqual(ExpandedPermission."Execute Permission", Execute, 'Execute permission is not set as expected.');
    end;

    local procedure VerifyNotContainsExpandedPermission(RoleId: Code[30]; AppId: Guid; ObjType: Option; ObjId: Integer)
    var
        ExpandedPermission: Record "Expanded Permission";
    begin
        Commit(); // Needs to commit to ensure expanded permission is updated and avoid instabilities
        LibraryAssert.IsFalse(ExpandedPermission.Get(AppId, RoleId, ObjType, ObjId), 'Expanded permission set contains a permission that should not be included.');
    end;

    local procedure VerifyExpandedPermissionCount(RoleId: Code[30]; AppId: Guid; ExpectedCount: Integer)
    var
        ExpandedPermission: Record "Expanded Permission";
    begin
        Commit(); // Needs to commit to ensure expanded permission is updated and avoid instabilities
        ExpandedPermission.SetRange("App ID", AppId);
        ExpandedPermission.SetRange("Role ID", RoleId);
        LibraryAssert.AreEqual(ExpectedCount, ExpandedPermission.Count(), 'Expanded permissions does not contain the expected number of permissions');
    end;

    local procedure VerifyEmptyExpandedPermissions(RoleId: Code[30]; AppId: Guid)
    var
        ExpandedPermission: Record "Expanded Permission";
    begin
        Commit(); // Needs to commit to ensure expanded permission is updated and avoid instabilities
        ExpandedPermission.SetRange("App ID", AppId);
        ExpandedPermission.SetRange("Role ID", RoleId);
        LibraryAssert.IsTrue(ExpandedPermission.IsEmpty(), 'Expanded permissions is not empty');
    end;

    local procedure GetTestPermissionSetCount(): Integer
    begin
        exit(9);
    end;

    [ModalPageHandler]
    procedure LookupPermissionSetAModalHandler(var LookupPermissionSet: TestPage "Lookup Permission Set")
    var
        AggregatePermissionSet: Record "Aggregate Permission Set";
        MetadataPermissionSet: Record "Metadata Permission Set";
        AppId: Guid;
    begin
        MetadataPermissionSet.SetRange("Role ID", RoleIdLbl);
        if MetadataPermissionSet.FindFirst() then
            AppId := MetadataPermissionSet."App ID";

        AggregatePermissionSet.Scope := AggregatePermissionSet.Scope::System;
        AggregatePermissionSet."App ID" := AppId;
        AggregatePermissionSet."Role ID" := RoleIdLbl;

        LookupPermissionSet.GoToRecord(AggregatePermissionSet);
        LookupPermissionSet.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}