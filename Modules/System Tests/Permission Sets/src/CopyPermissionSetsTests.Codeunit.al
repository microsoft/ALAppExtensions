// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Security.AccessControl;

using System.Security.AccessControl;
using System.TestLibraries.Reflection;
using System.TestLibraries.Utilities;

codeunit 132439 "Copy Permission Sets Tests"
{
    // [FEATURE] [Permission Sets] [UT]

    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";
        RoleIdLbl: Label 'Test Set A', Locked = true;
        PermissionSetNotfoundLbl: Label '%1 permission set could not be found.', Comment = '%1 - Permission set name', Locked = true;
        Scope: Option System,Tenant;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestCopySystemPermissionSetByFlatten()
    var
        MetadataPermissionSet: Record "Metadata Permission Set";
        TenantPermissionSet: Record "Tenant Permission Set";
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        NewRoleId: Code[30];
        NewName: Text;
        AppId: Guid;
        NullGuid: Guid;
    begin
        // [SCENARIO] Copying a system permission set creates a new tenant permission set with a flat list of all permissions

        // [GIVEN] An existing permission set and a new role ID and name
        NewRoleId := 'Flat';
        NewName := 'Flat';

        MetadataPermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(MetadataPermissionSet.FindFirst(), StrSubstNo(PermissionSetNotfoundLbl, RoleIdLbl));
        AppId := MetadataPermissionSet."App ID";

        // [WHEN] Copying permission sets by flattening
        PermissionSetRelation.CopyPermissionSet(NewRoleId, NewName, RoleIdLbl, AppId, Scope::System, Enum::"Permission Set Copy Type"::Flat);

        // [THEN] A new tenant permission set is created with the specified name
        Clear(TenantPermissionSet);
        TenantPermissionSet.SetRange("Role ID", NewRoleId);
        TenantPermissionSet.SetRange("App ID", NullGuid);

        LibraryAssert.IsTrue(TenantPermissionSet.FindFirst(), 'No new tenant permission set was created.');
        LibraryAssert.AreEqual(TenantPermissionSet.Name, NewName, 'Tenant permission set name should be as specified.');

        // [THEN] The new set contains no inclusions of other sets
        TenantPermissionSetRel.SetRange("Role ID", NewRoleId);
        TenantPermissionSetRel.SetRange("App ID", NullGuid);

        LibraryAssert.IsFalse(TenantPermissionSet.IsEmpty(), 'Tenant permission set relations exists.');

        // [THEN] The new set defines the tenant permissions
        VerifyTenantPermissions(NewRoleId, NullGuid);

        // [THEN] The new set contains the expanded permissions
        VerifyExpandedPermissions(NewRoleId, NullGuid);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestCopySystemPermissionSetByClone()
    var
        MetadataPermissionSet: Record "Metadata Permission Set";
        TenantPermissionSet: Record "Tenant Permission Set";
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        NewRoleId: Code[30];
        NewName: Text;
        AppId: Guid;
        NullGuid: Guid;
    begin
        // [SCENARIO] Copying a system permission set by clone creates a new tenant permission set with the same permissions and inclusions as the original.

        // [GIVEN] An existing permission set and a new role ID and name
        NewRoleId := 'Clone';
        NewName := 'Clone';

        MetadataPermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(MetadataPermissionSet.FindFirst(), StrSubstNo(PermissionSetNotfoundLbl, RoleIdLbl));
        AppId := MetadataPermissionSet."App ID";

        // [WHEN] Copying permission sets by clone
        PermissionSetRelation.CopyPermissionSet(NewRoleId, NewName, RoleIdLbl, AppId, Scope::System, Enum::"Permission Set Copy Type"::Clone);

        // [THEN] A new tenant permission set is created with the specified name
        TenantPermissionSet.SetRange("Role ID", NewRoleId);
        TenantPermissionSet.SetRange("App ID", NullGuid);

        LibraryAssert.IsTrue(TenantPermissionSet.FindFirst(), 'No new tenant permission set was created.');
        LibraryAssert.AreEqual(TenantPermissionSet.Name, NewName, 'Tenant permission set name should be as specified.');

        // [THEN] The new set contains the same inclusions as the cloned permission set
        LibraryAssert.IsTrue(TenantPermissionSetRel.Get(NullGuid, NewRoleId, AppId, 'Test Set B'), 'Tenant permission set rel does not contain the expected relation.');
        LibraryAssert.IsTrue(TenantPermissionSetRel.Get(NullGuid, NewRoleId, AppId, 'Test Set C'), 'Tenant permission set rel does not contain the expected relation.');

        TenantPermissionSetRel.SetRange("Role ID", NewRoleId);
        TenantPermissionSetRel.SetRange("App ID", NullGuid);
        LibraryAssert.AreEqual(2, TenantPermissionSetRel.Count(), 'Tenant permission set rel does not contain the expected number of relations.');

        // [THEN] The new set defines the same permissions as the cloned permission set
        VerifyTopLevelTenantPermissions(NewRoleId, NullGuid);

        // [THEN] The new set contains the expanded permissions
        VerifyExpandedPermissions(NewRoleId, NullGuid);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestCopySystemPermissionSetByReference()
    var
        MetadataPermissionSet: Record "Metadata Permission Set";
        TenantPermissionSet: Record "Tenant Permission Set";
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
        TenantPermission: Record "Tenant Permission";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        NewRoleId: Code[30];
        NewName: Text;
        AppId: Guid;
        NullGuid: Guid;
    begin
        // [SCENARIO] Copying a system permission set by reference creates a new set that includes the copied permission set

        // [GIVEN] An existing permission set and a new role ID and name
        NewRoleId := 'Reference';
        NewName := 'Reference';

        MetadataPermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(MetadataPermissionSet.FindFirst(), StrSubstNo(PermissionSetNotfoundLbl, RoleIdLbl));
        AppId := MetadataPermissionSet."App ID";

        // [WHEN] Copying permission sets by clone
        PermissionSetRelation.CopyPermissionSet(NewRoleId, NewName, RoleIdLbl, AppId, Scope::System, Enum::"Permission Set Copy Type"::Reference);

        // [THEN] A new tenant permission set is created with the specified name
        TenantPermissionSet.SetRange("Role ID", NewRoleId);
        TenantPermissionSet.SetRange("App ID", NullGuid);

        LibraryAssert.IsTrue(TenantPermissionSet.FindFirst(), 'No new tenant permission set was created.');
        LibraryAssert.AreEqual(TenantPermissionSet.Name, NewName, 'Tenant permission set name should be as specified.');

        // [THEN] The new set includes the copied permission set
        LibraryAssert.IsTrue(TenantPermissionSetRel.Get(NullGuid, NewRoleId, AppId, RoleIdLbl), 'Tenant permission set rel does not contain the expected relation.');

        TenantPermissionSetRel.SetRange("Role ID", NewRoleId);
        TenantPermissionSetRel.SetRange("App ID", NullGuid);
        LibraryAssert.AreEqual(1, TenantPermissionSetRel.Count(), 'Tenant permission set rel does not contain the expected number of relations.');

        // [THEN] The new set defines no permissions itself
        TenantPermission.SetRange("App ID", AppId);
        TenantPermission.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(TenantPermission.IsEmpty(), 'Tenant permissions should not be defined.');

        // [THEN] The new set contains the expanded permissions
        VerifyExpandedPermissions(NewRoleId, NullGuid);
    end;

    local procedure VerifyTopLevelTenantPermissions(RoleId: Code[30]; AppId: Guid)
    var
        TenantPermission: Record "Tenant Permission";
    begin
        LibraryAssert.IsTrue(TenantPermission.Get(AppId, RoleId, ObjectType::Codeunit, Codeunit::"Permission Set Relation"), 'Tenant permission set does not contain the expected permission.');
        LibraryAssert.IsTrue(TenantPermission.Get(AppId, RoleId, ObjectType::Page, Page::"Tenant Permission Subform"), 'Tenant permission set does not contain the expected permission.');

        TenantPermission.SetRange("App ID", AppId);
        TenantPermission.SetRange("Role ID", RoleId);
        LibraryAssert.AreEqual(2, TenantPermission.Count(), 'Tenant permissions does not contain the expected number of permissions');
    end;

    local procedure VerifyTenantPermissions(RoleId: Code[30]; AppId: Guid)
    var
        TenantPermission: Record "Tenant Permission";
    begin
        LibraryAssert.IsTrue(TenantPermission.Get(AppId, RoleId, ObjectType::Codeunit, Codeunit::"Permission Set Relation"), 'Tenant permission set does not contain the expected permission.');
        LibraryAssert.IsTrue(TenantPermission.Get(AppId, RoleId, ObjectType::Page, Page::"Tenant Permission Subform"), 'Tenant permission set does not contain the expected permission.');
        LibraryAssert.IsTrue(TenantPermission.Get(AppId, RoleId, ObjectType::Page, Page::"Expanded Permissions"), 'Tenant permission set does not contain the expected permission.');
        LibraryAssert.IsTrue(TenantPermission.Get(AppId, RoleId, ObjectType::Page, Page::"Permission Set Tree"), 'Tenant permission set does not contain the expected permission.');
        LibraryAssert.IsTrue(TenantPermission.Get(AppId, RoleId, ObjectType::Page, Page::"Permission Set"), 'Tenant permission set does not contain the expected permission.');
        LibraryAssert.IsTrue(TenantPermission.Get(AppId, RoleId, ObjectType::Page, Page::"Permission Set Subform"), 'Tenant permission set does not contain the expected permission.');
        LibraryAssert.IsTrue(TenantPermission.Get(AppId, RoleId, ObjectType::Page, Page::"Metadata Permission Subform"), 'Tenant permission set does not contain the expected permission.');
        LibraryAssert.IsTrue(TenantPermission.Get(AppId, RoleId, TenantPermission."Object Type"::"Table Data", Database::"Test Table A"), 'Tenant permission set does not contain the expected permission.');
        LibraryAssert.IsTrue(TenantPermission.Get(AppId, RoleId, TenantPermission."Object Type"::"Table Data", Database::"Test Table B"), 'Tenant permission set does not contain the expected permission.');

        TenantPermission.SetRange("App ID", AppId);
        TenantPermission.SetRange("Role ID", RoleId);
        LibraryAssert.AreEqual(9, TenantPermission.Count(), 'Tenant permissions does not contain the expected number of permissions');
    end;

    local procedure VerifyExpandedPermissions(RoleId: Code[30]; AppId: Guid)
    var
        ExpandedPermission: Record "Expanded Permission";
    begin
        LibraryAssert.IsTrue(ExpandedPermission.Get(AppId, RoleId, ObjectType::Codeunit, Codeunit::"Permission Set Relation"), 'Expanded permission set does not contain the expected permission.');
        LibraryAssert.IsTrue(ExpandedPermission.Get(AppId, RoleId, ObjectType::Page, Page::"Tenant Permission Subform"), 'Expanded permission set does not contain the expected permission.');
        LibraryAssert.IsTrue(ExpandedPermission.Get(AppId, RoleId, ObjectType::Page, Page::"Expanded Permissions"), 'Expanded permission set does not contain the expected permission.');
        LibraryAssert.IsTrue(ExpandedPermission.Get(AppId, RoleId, ObjectType::Page, Page::"Permission Set Tree"), 'Expanded permission set does not contain the expected permission.');
        LibraryAssert.IsTrue(ExpandedPermission.Get(AppId, RoleId, ObjectType::Page, Page::"Permission Set"), 'Expanded permission set does not contain the expected permission.');
        LibraryAssert.IsTrue(ExpandedPermission.Get(AppId, RoleId, ObjectType::Page, Page::"Permission Set Subform"), 'Expanded permission set does not contain the expected permission.');
        LibraryAssert.IsTrue(ExpandedPermission.Get(AppId, RoleId, ObjectType::Page, Page::"Metadata Permission Subform"), 'Expanded permission set does not contain the expected permission.');
        LibraryAssert.IsTrue(ExpandedPermission.Get(AppId, RoleId, ExpandedPermission."Object Type"::"Table Data", Database::"Test Table A"), 'Tenant permission set does not contain the expected permission.');
        LibraryAssert.IsTrue(ExpandedPermission.Get(AppId, RoleId, ExpandedPermission."Object Type"::"Table Data", Database::"Test Table B"), 'Tenant permission set does not contain the expected permission.');

        ExpandedPermission.SetRange("App ID", AppId);
        ExpandedPermission.SetRange("Role ID", RoleId);
        LibraryAssert.AreEqual(9, ExpandedPermission.Count(), 'Expanded permissions does not contain the expected number of permissions');
    end;
}