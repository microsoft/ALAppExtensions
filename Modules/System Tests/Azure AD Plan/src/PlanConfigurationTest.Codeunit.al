// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Azure.ActiveDirectory;

using System.Azure.Identity;
using System.Security.AccessControl;
using System.TestLibraries.Utilities;

codeunit 132931 "Plan Configuration Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        PlanConfiguration: Codeunit "Plan Configuration";
        TestPlanIdTxt: Label '9a4b8e95-834f-4247-9cd4-62e79453d584', Locked = true;
        TestRoleIdTxt: Label 'TEST PS';
        TestCompanyNameTxt: Label 'Test Company';
        NullGuid: Guid;
        Scope: Option System,Tenant;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestAddDefaultPermissionSetToPlan()
    var
        PermissionSetInPlanBuffer: Record "Permission Set In Plan Buffer";
    begin
        // [WHEN] A default permission set is added to a new plan
        PlanConfiguration.AddDefaultPermissionSetToPlan(TestPlanIdTxt, TestRoleIdTxt, NullGuid, Scope::Tenant);

        // [THEN] The permission set can be retrieved by calling GetDefaultPermissions
        PlanConfiguration.GetDefaultPermissions(PermissionSetInPlanBuffer);
        PermissionSetInPlanBuffer.SetRange("Plan ID", TestPlanIdTxt);
        Assert.RecordCount(PermissionSetInPlanBuffer, 1);

        PermissionSetInPlanBuffer.FindFirst();
        Assert.AreEqual(TestRoleIdTxt, PermissionSetInPlanBuffer."Role ID", 'Unexpected permission set name.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestAddCustomPermissionSetToPlan()
    var
        PermissionSetInPlanBuffer: Record "Permission Set In Plan Buffer";
    begin
        // [WHEN] A custom permission set is added to a new plan
        PlanConfiguration.AddCustomPermissionSetToPlan(TestPlanIdTxt, TestRoleIdTxt, NullGuid, Scope::Tenant, TestCompanyNameTxt);

        // [THEN] The permission set can be retrieved by calling GetDefaultPermissions
        PlanConfiguration.GetCustomPermissions(PermissionSetInPlanBuffer);
        PermissionSetInPlanBuffer.SetRange("Plan ID", TestPlanIdTxt);
        Assert.RecordCount(PermissionSetInPlanBuffer, 1);

        PermissionSetInPlanBuffer.FindFirst();
        Assert.AreEqual(TestRoleIdTxt, PermissionSetInPlanBuffer."Role ID", 'Unexpected permission set name.');
        // Custom configurations store the company name. Verify that it is as expected
        Assert.AreEqual(TestCompanyNameTxt, PermissionSetInPlanBuffer."Company Name", 'Unexpected company name.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestRemoveDefaultPermissionSetFromPlan()
    var
        PermissionSetInPlanBuffer: Record "Permission Set In Plan Buffer";
    begin
        // [GIVEN] A default permission set is added to a new plan
        PlanConfiguration.AddDefaultPermissionSetToPlan(TestPlanIdTxt, TestRoleIdTxt, NullGuid, Scope::Tenant);

        // [WHEN] The same default permission set is removed from the plan
        PlanConfiguration.RemoveDefaultPermissionSetFromPlan(TestPlanIdTxt, TestRoleIdTxt, NullGuid, Scope::Tenant);

        // [THEN] The permission set cannot be retrieved by getting default permissions
        PlanConfiguration.GetDefaultPermissions(PermissionSetInPlanBuffer);
        PermissionSetInPlanBuffer.SetRange("Plan ID", TestPlanIdTxt);
        Assert.RecordIsEmpty(PermissionSetInPlanBuffer);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestRemoveCustomPermissionSetFromPlan()
    var
        PermissionSetInPlanBuffer: Record "Permission Set In Plan Buffer";
    begin
        // [GIVEN] A custom permission set is added to a new plan
        PlanConfiguration.AddCustomPermissionSetToPlan(TestPlanIdTxt, TestRoleIdTxt, NullGuid, Scope::Tenant, TestCompanyNameTxt);

        // [WHEN] The same custom permission set is removed from the plan
        PlanConfiguration.RemoveCustomPermissionSetFromPlan(TestPlanIdTxt, TestRoleIdTxt, NullGuid, Scope::Tenant, TestCompanyNameTxt);

        // [THEN] The permission set cannot be retrieved by getting custom permissions
        PlanConfiguration.GetCustomPermissions(PermissionSetInPlanBuffer);
        PermissionSetInPlanBuffer.SetRange("Plan ID", TestPlanIdTxt);
        Assert.RecordIsEmpty(PermissionSetInPlanBuffer);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestAssignDefaultPermissionsToUser()
    var
        AccessControl: Record "Access Control";
    begin
        // [GIVEN] There is a default permission set associated with a plan
        PlanConfiguration.AddDefaultPermissionSetToPlan(TestPlanIdTxt, TestRoleIdTxt, NullGuid, Scope::Tenant);

        // [WHEN] A user is assigned the default permissions associated with the plan
        PlanConfiguration.AssignDefaultPermissionsToUser(TestPlanIdTxt, UserSecurityId(), TestCompanyNameTxt);

        // [THEN] The user permissions have been updated
        AccessControl.SetRange("User Security ID", UserSecurityId());
        AccessControl.SetRange("Role ID", TestRoleIdTxt);
        AccessControl.SetRange("Company Name", TestCompanyNameTxt);
        Assert.RecordIsNotEmpty(AccessControl);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestAssignCustomPermissionsToUser()
    var
        AccessControl: Record "Access Control";
    begin
        // [GIVEN] There is a custom permission set associated with a plan
        PlanConfiguration.AddCustomPermissionSetToPlan(TestPlanIdTxt, TestRoleIdTxt, NullGuid, Scope::Tenant, TestCompanyNameTxt);

        // [WHEN] A user is assigned the default permissions associated with the plan
        PlanConfiguration.AssignCustomPermissionsToUser(TestPlanIdTxt, UserSecurityId());

        // [THEN] The user permissions have been updated
        AccessControl.SetRange("User Security ID", UserSecurityId());
        AccessControl.SetRange("Role ID", TestRoleIdTxt);
        AccessControl.SetRange("Company Name", TestCompanyNameTxt);
        Assert.RecordIsNotEmpty(AccessControl);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestRemoveDefaultPermissionsFromUser()
    var
        AccessControl: Record "Access Control";
    begin
        // [GIVEN] There is a default permission set associated with a plan
        PlanConfiguration.AddDefaultPermissionSetToPlan(TestPlanIdTxt, TestRoleIdTxt, NullGuid, Scope::Tenant);

        // [GIVEN] A user is assigned the default permissions associated with the plan
        PlanConfiguration.AssignDefaultPermissionsToUser(TestPlanIdTxt, UserSecurityId(), TestCompanyNameTxt);

        // [WHEN] The default plan permissions are removed from the user
        PlanConfiguration.RemoveDefaultPermissionsFromUser(TestPlanIdTxt, UserSecurityId());

        // [THEN] The user does not have the default permission associated with the plan
        AccessControl.SetRange("User Security ID", UserSecurityId());
        AccessControl.SetRange("Role ID", TestRoleIdTxt);
        Assert.RecordIsEmpty(AccessControl);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestRemoveCustomPermissionsFromUser()
    var
        AccessControl: Record "Access Control";
    begin
        // [GIVEN] There is a custom permission set associated with a plan
        PlanConfiguration.AddCustomPermissionSetToPlan(TestPlanIdTxt, TestRoleIdTxt, NullGuid, Scope::Tenant, TestCompanyNameTxt);

        // [GIVEN] A user is assigned the custom permissions associated with the plan
        PlanConfiguration.AssignCustomPermissionsToUser(TestPlanIdTxt, UserSecurityId());

        // [WHEN] The custom plan permissions are removed from the user
        PlanConfiguration.RemoveCustomPermissionsFromUser(TestPlanIdTxt, UserSecurityId());

        // [THEN] The user does not have the custom permission associated with the plan
        AccessControl.SetRange("User Security ID", UserSecurityId());
        AccessControl.SetRange("Role ID", TestRoleIdTxt);
        Assert.RecordIsEmpty(AccessControl);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestRemoveDefaultPermissionsWorksForTheAssignedPlan()
    var
        AccessControl: Record "Access Control";
        UserPlan: Record "User Plan";
        AnotherPlan: Guid;
    begin
        // [GIVEN] There is a default permission set associated with a plan
        PlanConfiguration.AddDefaultPermissionSetToPlan(TestPlanIdTxt, TestRoleIdTxt, NullGuid, Scope::Tenant);

        // [GIVEN] The same default permission set associated with another plan
        AnotherPlan := CreateGuid();
        PlanConfiguration.AddDefaultPermissionSetToPlan(AnotherPlan, TestRoleIdTxt, NullGuid, Scope::Tenant);

        // [GIVEN] A user is assigned the test plan
        UserPlan."User Security ID" := UserSecurityId();
        UserPlan."Plan ID" := TestPlanIdTxt;
        UserPlan.Insert();

        // [GIVEN] the user is assigned the default permissions associated with the plan
        PlanConfiguration.AssignDefaultPermissionsToUser(TestPlanIdTxt, UserSecurityId(), TestCompanyNameTxt);

        // [WHEN] The default plan permissions are removed from the user for another plan
        PlanConfiguration.RemoveDefaultPermissionsFromUser(AnotherPlan, UserSecurityId());

        // [THEN] Nothing happens, the user keeps the permission set
        AccessControl.SetRange("User Security ID", UserSecurityId());
        AccessControl.SetRange("Role ID", TestRoleIdTxt);
        Assert.RecordIsNotEmpty(AccessControl);

        // [WHEN] The default plan permissions are removed from the user for the corresponding plan
        PlanConfiguration.RemoveDefaultPermissionsFromUser(TestPlanIdTxt, UserSecurityId());

        // [THEN] The user does not have the default permission associated with the plan
        Assert.RecordIsEmpty(AccessControl);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestRemoveCustomPermissionsWorksForTheAssignedPlan()
    var
        AccessControl: Record "Access Control";
        UserPlan: Record "User Plan";
        AnotherPlan: Guid;
    begin
        // [GIVEN] There is a custom permission set associated with a plan
        PlanConfiguration.AddCustomPermissionSetToPlan(TestPlanIdTxt, TestRoleIdTxt, NullGuid, Scope::Tenant, TestCompanyNameTxt);

        // [GIVEN] The same default permission set associated with another plan
        AnotherPlan := CreateGuid();
        PlanConfiguration.AddCustomPermissionSetToPlan(AnotherPlan, TestRoleIdTxt, NullGuid, Scope::Tenant, TestCompanyNameTxt);

        // [GIVEN] A user is assigned the test plan
        UserPlan."User Security ID" := UserSecurityId();
        UserPlan."Plan ID" := TestPlanIdTxt;
        UserPlan.Insert();

        // [GIVEN] the user is assigned the custom permissions associated with the plan
        PlanConfiguration.AssignCustomPermissionsToUser(TestPlanIdTxt, UserSecurityId());

        // [WHEN] The custom plan permissions are removed from the user for another plan
        PlanConfiguration.RemoveCustomPermissionsFromUser(AnotherPlan, UserSecurityId());

        // [THEN] Nothing happens, the user keeps the permission set
        AccessControl.SetRange("User Security ID", UserSecurityId());
        AccessControl.SetRange("Role ID", TestRoleIdTxt);
        Assert.RecordIsNotEmpty(AccessControl);

        // [WHEN] The custom plan permissions are removed from the user for the corresponding plan
        PlanConfiguration.RemoveCustomPermissionsFromUser(TestPlanIdTxt, UserSecurityId());

        // [THEN] The user does not have the custom permission associated with the plan
        Assert.RecordIsEmpty(AccessControl);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestRemoveDefaultPermissionsFromUserWithOverlappingPermissionSets()
    var
        AccessControl: Record "Access Control";
        UserPlan: Record "User Plan";
        PlanATxt: Label '0d85ee13-bbc3-4f0c-a968-68cf581ad8e9';
        PlanBTxt: Label '59bbdb52-062d-4eaa-ba56-569753015a10';
        RoleId1Txt: Label 'ROLE1';
        RoleId2Txt: Label 'ROLE2';
        RoleId3Txt: Label 'ROLE3';
    begin
        // [GIVEN] Permission sets 1 and 2 are associated with plan A
        PlanConfiguration.AddDefaultPermissionSetToPlan(PlanATxt, RoleId1Txt, NullGuid, Scope::Tenant);
        PlanConfiguration.AddDefaultPermissionSetToPlan(PlanATxt, RoleId2Txt, NullGuid, Scope::Tenant);

        // [GIVEN] Permission sets 2 and 3 are associated with plan B
        PlanConfiguration.AddDefaultPermissionSetToPlan(PlanBTxt, RoleId2Txt, NullGuid, Scope::Tenant);
        PlanConfiguration.AddDefaultPermissionSetToPlan(PlanBTxt, RoleId3Txt, NullGuid, Scope::Tenant);

        // [GIVEN] A user is assigned both plans A and B
        UserPlan."User Security ID" := UserSecurityId();
        UserPlan."Plan ID" := PlanATxt;
        UserPlan.Insert();

        UserPlan."Plan ID" := PlanBTxt;
        UserPlan.Insert();

        // [WHEN] The user is assigned the default permissions associated with plans A and B
        PlanConfiguration.AssignDefaultPermissionsToUser(PlanATxt, UserSecurityId(), TestCompanyNameTxt);
        PlanConfiguration.AssignDefaultPermissionsToUser(PlanBTxt, UserSecurityId(), TestCompanyNameTxt);

        // [THEN] The user gets permission sets 1, 2 and 3
        AccessControl.SetRange("User Security ID", UserSecurityId());

        AccessControl.SetRange("Role ID", RoleId1Txt);
        Assert.RecordIsNotEmpty(AccessControl);

        AccessControl.SetRange("Role ID", RoleId2Txt);
        Assert.RecordIsNotEmpty(AccessControl);

        AccessControl.SetRange("Role ID", RoleId3Txt);
        Assert.RecordIsNotEmpty(AccessControl);

        // [WHEN] The plan and the default plan permissions for plan A are removed from the user
        UserPlan.SetRange("Plan ID", PlanATxt);
        UserPlan.DeleteAll();
        PlanConfiguration.RemoveDefaultPermissionsFromUser(PlanATxt, UserSecurityId());

        // [THEN] The user keeps permission sets 2 and 3, but not 1
        AccessControl.SetRange("User Security ID", UserSecurityId());

        AccessControl.SetRange("Role ID", RoleId1Txt);
        Assert.RecordIsEmpty(AccessControl);

        AccessControl.SetRange("Role ID", RoleId2Txt);
        Assert.RecordIsNotEmpty(AccessControl);

        AccessControl.SetRange("Role ID", RoleId3Txt);
        Assert.RecordIsNotEmpty(AccessControl);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestRemoveCustomPermissionsFromUserWithOverlappingPermissionSets()
    var
        AccessControl: Record "Access Control";
        UserPlan: Record "User Plan";
        PlanATxt: Label '0d85ee13-bbc3-4f0c-a968-68cf581ad8e9';
        PlanBTxt: Label '59bbdb52-062d-4eaa-ba56-569753015a10';
        RoleId1Txt: Label 'ROLE1';
        RoleId2Txt: Label 'ROLE2';
        RoleId3Txt: Label 'ROLE3';
    begin
        // [GIVEN] Permission sets 1 and 2 are associated with plan A
        PlanConfiguration.AddCustomPermissionSetToPlan(PlanATxt, RoleId1Txt, NullGuid, Scope::Tenant, TestCompanyNameTxt);
        PlanConfiguration.AddCustomPermissionSetToPlan(PlanATxt, RoleId2Txt, NullGuid, Scope::Tenant, TestCompanyNameTxt);

        // [GIVEN] Permission sets 2 and 3 are associated with plan B
        PlanConfiguration.AddCustomPermissionSetToPlan(PlanBTxt, RoleId2Txt, NullGuid, Scope::Tenant, TestCompanyNameTxt);
        PlanConfiguration.AddCustomPermissionSetToPlan(PlanBTxt, RoleId3Txt, NullGuid, Scope::Tenant, TestCompanyNameTxt);

        // [GIVEN] A user is assigned both plans A and B
        UserPlan."User Security ID" := UserSecurityId();
        UserPlan."Plan ID" := PlanATxt;
        UserPlan.Insert();

        UserPlan."Plan ID" := PlanBTxt;
        UserPlan.Insert();

        // [WHEN] A user is assigned the custom permissions associated with plans A and B
        PlanConfiguration.AssignCustomPermissionsToUser(PlanATxt, UserSecurityId());
        PlanConfiguration.AssignCustomPermissionsToUser(PlanBTxt, UserSecurityId());

        // [THEN] The user gets permission sets 1, 2 and 3
        AccessControl.SetRange("User Security ID", UserSecurityId());

        AccessControl.SetRange("Role ID", RoleId1Txt);
        Assert.RecordIsNotEmpty(AccessControl);

        AccessControl.SetRange("Role ID", RoleId2Txt);
        Assert.RecordIsNotEmpty(AccessControl);

        AccessControl.SetRange("Role ID", RoleId3Txt);
        Assert.RecordIsNotEmpty(AccessControl);

        // [WHEN] The plan and custom plan permissions for plan A are removed from the user
        UserPlan.SetRange("Plan ID", PlanATxt);
        UserPlan.DeleteAll();
        PlanConfiguration.RemoveCustomPermissionsFromUser(PlanATxt, UserSecurityId());

        // [THEN] The user keeps permission sets 2 and 3, but not 1
        AccessControl.SetRange("User Security ID", UserSecurityId());

        AccessControl.SetRange("Role ID", RoleId1Txt);
        Assert.RecordIsEmpty(AccessControl);

        AccessControl.SetRange("Role ID", RoleId2Txt);
        Assert.RecordIsNotEmpty(AccessControl);

        AccessControl.SetRange("Role ID", RoleId3Txt);
        Assert.RecordIsNotEmpty(AccessControl);
    end;
}