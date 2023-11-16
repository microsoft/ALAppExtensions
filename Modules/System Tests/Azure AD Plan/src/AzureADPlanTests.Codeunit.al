// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Azure.ActiveDirectory;

using System.TestLibraries.Environment;
using System.Azure.Identity;
using System.TestLibraries.Azure.ActiveDirectory;
using System.TestLibraries.Mocking;
using System;
using System.Security.User;
using System.TestLibraries.Security.AccessControl;
using System.TestLibraries.Utilities;

codeunit 132912 "Azure AD Plan Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var
        LibraryAssert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        EnvironmentInformationTestLibrary: Codeunit "Environment Info Test Library";

    [Test]
    [Scope('OnPrem')]
    procedure CheckPlansNumber()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
    begin
        // [SCENARIO] There should be 20 Plans

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD Plan View');

        LibraryAssert.AreEqual(20, AzureADPlan.GetAvailablePlansCount(),
            'The number of available plans has changed. Make sure that you have added or removed tests on these changes in Plan-Based tests and then update the number of plans in this test.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsPlanAssigned()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
        PlanID: Guid;
    begin
        DeleteAllFromTablePlanAndUserPlan();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD Plan View');

        //[GIVEN] A specific plan with at least one user assigned to it
        PlanID := AzureADPlanTestLibraries.CreatePlan('TestPlanAssigned');
        AzureADPlanTestLibraries.AssignUserToPlan(CreateGuid(), PlanID);

        //[WHEN] checking if the plan is assigned to at least one user
        //[THEN] the result should be true
        LibraryAssert.AreEqual(true, AzureADPlan.IsPlanAssigned(PlanID), 'The Plan should be assigned to at least one user');

        // //[GIVEN] A specific plan with no user assigned to it
        PlanID := AzureADPlanTestLibraries.CreatePlan('TestPlanNotAssigned');

        //[WHEN] checking if the plan is assigned to at least one user
        //[THEN] the result should be false
        LibraryAssert.AreEqual(false, AzureADPlan.IsPlanAssigned(PlanID), 'The Plan should not be assigned to any user');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsPlanAssignedToUser()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
        PlanID: Guid;
    begin
        DeleteAllFromTablePlanAndUserPlan();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD Plan View');

        //[GIVEN] A specific plan which is assigned to the current user
        PlanID := AzureADPlanTestLibraries.CreatePlan('TestPlanAssigned');
        AzureADPlanTestLibraries.AssignUserToPlan(UserSecurityId(), PlanID);

        // [WHEN] checking if the plan is assigned to the current user
        // [THEN] the result should be true
        LibraryAssert.AreEqual(true, AzureADPlan.IsPlanAssigned(PlanID), 'The Plan should be assigned to the current user');

        //[GIVEN] A specific plan which is NOT assigned to the current user
        PlanID := AzureADPlanTestLibraries.CreatePlan('TestPlanNotAssigned');

        // [WHEN] checking if the plan is assigned to the current user
        // [THEN] the result should be false
        LibraryAssert.AreEqual(false, AzureADPlan.IsPlanAssignedToUser(PlanID), 'The Plan should not be assigned to the current user');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsGraphUserEntitledFromServicePlan()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADPlanTestLibrary: Codeunit "Azure AD Plan Test Library";
        MockGraphQueryTestLibrary: Codeunit "MockGraphQuery Test Library";
        GraphUserInfo: DotNet UserInfo;
        UserID: Guid;
        PlanID: Guid;
    begin
        DeleteAllFromTablePlanAndUserPlan();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD Plan View');

        // [GIVEN] a service plan and a user who is entitled to a plan 
        UserId := CreateGuid();
        PlanID := AzureADPlanTestLibrary.CreatePlan('TestPlan');
        MockGraphQueryTestLibrary.CreateGraphUser(GraphUserInfo, UserId, '', '', '');
        MockGraphQueryTestLibrary.PopulateMockGraph(GraphUserInfo, PlanID, 'TestPlan');

        // [WHEN] checking if the user is entitled to a service plan
        // [THEN] the result should be true
        LibraryAssert.AreEqual(true, AzureADPlan.IsGraphUserEntitledFromServicePlan(GraphUserInfo), 'The user should be entitled from the service Plan');

        // [GIVEN] a user who is NOT entitled to any plan
        MockGraphQueryTestLibrary.CreateGraphUser(GraphUserInfo, UserSecurityId(), '', '', '');

        // [WHEN] checking if the user is entitled to a plan
        // [THEN] the result should be false
        LibraryAssert.AreEqual(false, AzureADPlan.IsGraphUserEntitledFromServicePlan(GraphUserInfo), 'The user should not be entitled from the service Plan');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    [Scope('OnPrem')]
    procedure TestUpdateUserPlans()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADGraphTestLibrary: Codeunit "Azure AD Graph Test Library";
        AzureADPlanTestLibrary: Codeunit "Azure AD Plan Test Library";
        MockGraphQueryTestLibrary: Codeunit "MockGraphQuery Test Library";
        GraphUserInfo: DotNet UserInfo;
        UserID: Guid;
        PlanID: Guid;
    begin
        DeleteAllFromTablePlanAndUserPlan();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD Plan View');

        BindSubscription(AzureADGraphTestLibrary);
        BindSubscription(AzureADPlanTestLibrary);

        // [GIVEN] a User and a GraphUser with a Plan which is not in the table Plan and a user
        UserId := CreateGuid();
        PlanID := CreateGuid();
        AzureADGraphTestLibrary.SetMockGraphQuery(MockGraphQueryTestLibrary);
        MockGraphQueryTestLibrary.CreateGraphUser(GraphUserInfo, UserId, '', '', '');
        MockGraphQueryTestLibrary.PopulateMockGraph(GraphUserInfo, PlanID, 'TestPlan');

        LibraryAssert.AreEqual(false, AzureADPlan.DoesPlanExist(PlanID), 'The new Plan should not exist in the table Plan');
        LibraryAssert.AreEqual(false, AzureADPlan.IsPlanAssignedToUser(PlanID, UserID), 'The new Plan should not be assigned to the user');

        // [WHEN] updating the User Plans from the GraphUser
        AzureADPlan.UpdateUserPlans(UserID, GraphUserInfo);

        // [THEN] the new Plan should exist and the User should have the new Plan assigned to him
        LibraryAssert.AreEqual(true, AzureADPlan.DoesPlanExist(PlanID), 'The new Plan should exist in the table Plan');
        LibraryAssert.AreEqual(true, AzureADPlan.IsPlanAssignedToUser(PlanID, UserID), 'The new Plan should be assigned to the user');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsPlanAssignedToSpecificUser()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
        PlanID: Guid;
        UserID: Guid;
    begin
        //[GIVEN] A specific plan which is assigned to a specific user
        DeleteAllFromTablePlanAndUserPlan();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD Plan View');

        //[GIVEN] A specific plan which is assigned to the current user
        UserID := CreateGuid();
        PlanID := AzureADPlanTestLibraries.CreatePlan('TestPlan');
        AzureADPlanTestLibraries.AssignUserToPlan(UserID, PlanID);

        // [WHEN] checking if the plan is assigned to the current user
        // [THEN] the result should be true
        LibraryAssert.AreEqual(true, AzureADPlan.IsPlanAssignedToUser(PlanID, UserID), 'The Plan should be assigned to a user');

        //[GIVEN] A specific plan which is NOT assigned to a specific user
        // [WHEN] checking if the plan is assigned to the user
        // [THEN] the result should be false
        LibraryAssert.AreEqual(false, AzureADPlan.IsPlanAssignedToUser(PlanID, CreateGuid()), 'The Plan should not be assigned to a user');

        //[GIVEN] A specific user who doesn't have the specific plan
        // [WHEN] checking if the specific user has the plan assigned
        // [THEN] the result should be false
        LibraryAssert.AreEqual(false, AzureADPlan.IsPlanAssignedToUser(CreateGuid(), UserID), 'The Plan should not be assigned to a user');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestDoPlansExist()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
    begin
        DeleteAllFromTablePlanAndUserPlan();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD Plan View');

        // [GIVEN] no Plans in the table Plan
        // [WHEN] invoking DoPlansExist
        // [THEN] The table Plan should be empty
        LibraryAssert.AreEqual(false, AzureADPlan.DoPlansExist(), 'The table Plan should be empty');

        // [GIVEN] Plans inside the table Plan
        AzureADPlanTestLibraries.CreatePlan('TestPlan');
        // [WHEN] invoking DoPlansExist
        // [THEN] The table Plan should not be empty
        LibraryAssert.AreEqual(true, AzureADPlan.DoPlansExist(), 'The table Plan should not be empty');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestDoUserPlansExist()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
    begin
        DeleteAllFromTablePlanAndUserPlan();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD Plan View');

        // [GIVEN] Users who doesnt have any Plans assigned
        // [WHEN] invoking DoUserPlansExist
        // [THEN] The table User Plan should be empty
        LibraryAssert.AreEqual(false, AzureADPlan.DoUserPlansExist(), 'The table User Plan should be empty');

        // [GIVEN] Users who have Plans assigned
        AzureADPlanTestLibraries.AssignUserToPlan(CreateGuid(), CreateGuid());
        // [WHEN] invoking DoUserPlansExist
        // [THEN] The table User Plan should not be empty
        LibraryAssert.AreEqual(true, AzureADPlan.DoUserPlansExist(), 'The table User Plan should not be empty');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestDoesPlanExist()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
        PlanID: Guid;
    begin
        DeleteAllFromTablePlanAndUserPlan();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD Plan View');

        // [GIVEN] A Plan which doesnt exist
        // [WHEN] invoking DoesPlanExist
        // [THEN] The result should be false
        LibraryAssert.AreEqual(false, AzureADPlan.DoesPlanExist(CreateGuid()), 'The given Plan should not exist');

        // [GIVEN] A Plan which exists
        PlanID := AzureADPlanTestLibraries.CreatePlan('TestPlan');
        // [WHEN] invoking DoesPlanExist
        // [THEN] The result should be true
        LibraryAssert.AreEqual(true, AzureADPlan.DoesPlanExist(PlanID), 'The given Plan should exist');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestDoesUserHavePlans()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
        UserID: Guid;
        PlanID: Guid;
    begin
        DeleteAllFromTablePlanAndUserPlan();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD Plan View');

        // [GIVEN] A User with  no Plan assigned
        // [WHEN] invoking DoesUserHavePlans
        // [THEN] The result should be false
        UserID := CreateGuid();
        LibraryAssert.AreEqual(false, AzureADPlan.DoesUserHavePlans(UserID), 'The user should not have any Plan assigned');

        // [GIVEN] A User with at least one Plan assigned
        PlanID := AzureADPlanTestLibraries.CreatePlan('TestPlan');
        AzureADPlanTestLibraries.AssignUserToPlan(UserID, PlanID);
        // [WHEN] invoking DoesUserHavePlans
        // [THEN] The result should be true
        LibraryAssert.AreEqual(true, AzureADPlan.DoesUserHavePlans(UserID), 'The user should have at least one Plan assigned');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure AssignPlansToUserDelegatedAdmin()
    var
        UserPlan: Record "User Plan";
        AzureADPlan: Codeunit "Azure AD Plan";
        UserPermissions: Codeunit "User Permissions";
        PlanConfiguration: Codeunit "Plan Configuration";
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
        AzureADUserTestLibrary: Codeunit "Azure AD User Test Library";
        PlanConfigurationLibrary: Codeunit "Plan Configuration Library";
        UserPermissionsLibrary: Codeunit "User Permissions Library";
        AzureAdPlanTest: Codeunit "Azure AD Plan Tests";
        PlanIds: Codeunit "Plan Ids";
        UserSID: Guid;
    begin
        // [Scenario] Delegated admin plan is assigned to a user who is a delegated admin

        DeleteAllFromTablePlanAndUserPlan();
        PlanConfigurationLibrary.ClearPlanConfigurations();
        BindSubscription(AzureAdPlanTest);
        EnvironmentInformationTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [Given] Two SUPER users (need to have at least two users because if it's only one, the SUPER role will not be removed) 
        UserSID := UserPermissionsLibrary.CreateSuperUser('NEWUSER');
        UserPermissionsLibrary.CreateSuperUser('ANOTHERUSER');

        // [Given] The Delegated Admin agent - Partner plan exists
        AzureADPlanTestLibraries.CreatePlan(PlanIds.GetDelegatedAdminPlanId(), 'Delegated Admin agent - Partner', 9022, '7584DDCA-27B8-E911-BB26-000D3A2B005C');

        // [Given] The plan is not assigned to the current user
        LibraryAssert.IsFalse(UserPlan.Get(PlanIds.GetDelegatedAdminPlanId(), UserSID), 'Plan should not be assigned to user');

        // [Given] The current user is a delegated admin
        BindSubscription(AzureADUserTestLibrary);
        AzureADUserTestLibrary.SetIsUserDelegatedAdmin(true);

        // [Given] The plan configuration for the plan is not customized
        LibraryAssert.IsFalse(PlanConfiguration.IsCustomized(PlanIds.GetDelegatedAdminPlanId()), 'Plan configuration should not be customized');

        // [When] The plan is assigned per delegated role
        AzureADPlan.AssignPlanToUserWithDelegatedRole(UserSID);

        // [Then] There is an entry in the User Plan table
        LibraryAssert.AreEqual(1, UserPlan.Count(), 'There should be only one plan assignments');
        LibraryAssert.IsTrue(UserPlan.FindFirst(), 'The should be a plan assigned');
        LibraryAssert.AreEqual(UserSID, UserPlan."User Security ID", 'Wrong user was assigned a plan');
        LibraryAssert.AreEqual(PlanIds.GetDelegatedAdminPlanId(), UserPlan."Plan ID", 'Wrong plan was assigned');

        // [Then] SUPER was not removed from the user
        LibraryAssert.IsTrue(UserPermissions.IsSuper(UserSID), 'User should be SUPER');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure AssignPlansToUserNoDelegatedAdmin()
    var
        UserPlan: Record "User Plan";
        AzureADPlan: Codeunit "Azure AD Plan";
        UserPermissions: Codeunit "User Permissions";
        PlanConfiguration: Codeunit "Plan Configuration";
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
        AzureADUserTestLibrary: Codeunit "Azure AD User Test Library";
        PlanConfigurationLibrary: Codeunit "Plan Configuration Library";
        UserPermissionsLibrary: Codeunit "User Permissions Library";
        AzureAdPlanTest: Codeunit "Azure AD Plan Tests";
        PlanIds: Codeunit "Plan Ids";
        UserSID: Guid;
    begin
        // [Scenario] Delegated admin plan is not assigned to a user if they are not delegated admin

        DeleteAllFromTablePlanAndUserPlan();
        PlanConfigurationLibrary.ClearPlanConfigurations();
        BindSubscription(AzureAdPlanTest);
        EnvironmentInformationTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [Given] Two SUPER users (need to have at least two users because if it's only one, the SUPER role will not be removed) 
        UserSID := UserPermissionsLibrary.CreateSuperUser('NEWUSER');
        UserPermissionsLibrary.CreateSuperUser('ANOTHERUSER');

        // [Given] The Delegated Admin agent - Partner plan exists
        AzureADPlanTestLibraries.CreatePlan(PlanIds.GetDelegatedAdminPlanId(), 'Delegated Admin agent - Partner', 9022, '7584DDCA-27B8-E911-BB26-000D3A2B005C');

        // [Given] The plan is not assigned to the current user
        LibraryAssert.IsFalse(UserPlan.Get(PlanIds.GetDelegatedAdminPlanId(), UserSID), 'Plan should not be assigned to user');

        // [Given] The current user is not a delegated admin
        BindSubscription(AzureADUserTestLibrary);
        AzureADUserTestLibrary.SetIsUserDelegatedAdmin(false);

        // [Given] The plan configuration for the plan is not customized
        LibraryAssert.IsFalse(PlanConfiguration.IsCustomized(PlanIds.GetDelegatedAdminPlanId()), 'Plan configuration should not be customized');

        // [When] The plan is assigned per delegated role
        AzureADPlan.AssignPlanToUserWithDelegatedRole(UserSID);

        // [Then] There is no entry in the User Plan table
        LibraryAssert.AreEqual(0, UserPlan.Count(), 'There should not be any plan assignments');

        // [Then] SUPER was not removed from the user
        LibraryAssert.IsTrue(UserPermissions.IsSuper(UserSID), 'User should be SUPER');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure AssignPlansToUserDelegatedAdminKeepSuper()
    var
        UserPlan: Record "User Plan";
        AzureADPlan: Codeunit "Azure AD Plan";
        UserPermissions: Codeunit "User Permissions";
        PlanConfiguration: Codeunit "Plan Configuration";
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
        AzureADUserTestLibrary: Codeunit "Azure AD User Test Library";
        PlanConfigurationLibrary: Codeunit "Plan Configuration Library";
        UserPermissionsLibrary: Codeunit "User Permissions Library";
        AzureAdPlanTest: Codeunit "Azure AD Plan Tests";
        PlanIds: Codeunit "Plan Ids";
        UserSID, NullGuid : Guid;
    begin
        // [Scenario] Delegated admin plan is assigned to a user and their SUPER role is not removed if the plan configuration contains SUPER

        DeleteAllFromTablePlanAndUserPlan();
        PlanConfigurationLibrary.ClearPlanConfigurations();
        BindSubscription(AzureAdPlanTest);
        EnvironmentInformationTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [Given] Two SUPER users (need to have at least two users because if it's only one, the SUPER role will not be removed) 
        UserSID := UserPermissionsLibrary.CreateSuperUser('NEWUSER');
        UserPermissionsLibrary.CreateSuperUser('ANOTHERUSER');

        // [Given] The Delegated Admin agent - Partner plan exists
        AzureADPlanTestLibraries.CreatePlan(PlanIds.GetDelegatedAdminPlanId(), 'Delegated Admin agent - Partner', 9022, '7584DDCA-27B8-E911-BB26-000D3A2B005C');

        // [Given] The plan is not assigned to the current user
        LibraryAssert.IsFalse(UserPlan.Get(PlanIds.GetDelegatedAdminPlanId(), UserSID), 'Plan should not be assigned to user');

        // [Given] The current user is a delegated admin
        BindSubscription(AzureADUserTestLibrary);
        AzureADUserTestLibrary.SetIsUserDelegatedAdmin(true);

        // [Given] The plan configuration for the plan is customized and contains SUPER
        PlanConfigurationLibrary.AddConfiguration(PlanIds.GetDelegatedAdminPlanId(), true);
        PlanConfiguration.AddCustomPermissionSetToPlan(PlanIds.GetDelegatedAdminPlanId(), 'SUPER', NullGuid, 0, '');

        // [When] The plan is assigned per delegated role
        AzureADPlan.AssignPlanToUserWithDelegatedRole(UserSID);

        // [Then] There is an entry in the User Plan table
        LibraryAssert.AreEqual(1, UserPlan.Count(), 'There should be only one plan assignments');
        LibraryAssert.IsTrue(UserPlan.FindFirst(), 'The should be a plan assigned');
        LibraryAssert.AreEqual(UserSID, UserPlan."User Security ID", 'Wrong user was assigned a plan');
        LibraryAssert.AreEqual(PlanIds.GetDelegatedAdminPlanId(), UserPlan."Plan ID", 'Wrong plan was assigned');

        // [Then] SUPER was not removed from the user
        LibraryAssert.IsTrue(UserPermissions.IsSuper(UserSID), 'User should be SUPER');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure AssignPlansToUserDelegatedHelpdesk()
    var
        UserPlan: Record "User Plan";
        AzureADPlan: Codeunit "Azure AD Plan";
        UserPermissions: Codeunit "User Permissions";
        PlanConfiguration: Codeunit "Plan Configuration";
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
        AzureADUserTestLibrary: Codeunit "Azure AD User Test Library";
        PlanConfigurationLibrary: Codeunit "Plan Configuration Library";
        UserPermissionsLibrary: Codeunit "User Permissions Library";
        AzureAdPlanTest: Codeunit "Azure AD Plan Tests";
        PlanIds: Codeunit "Plan Ids";
        UserSID: Guid;
    begin
        // [Scenario] Delegated helpdesk plan is assigned to a delegated helpdesk user

        DeleteAllFromTablePlanAndUserPlan();
        PlanConfigurationLibrary.ClearPlanConfigurations();
        BindSubscription(AzureAdPlanTest);
        EnvironmentInformationTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [Given]Two SUPER users (need to have at least two users because if it's only one, the SUPER role will not be removed) 
        UserSID := UserPermissionsLibrary.CreateSuperUser('NEWUSER');
        UserPermissionsLibrary.CreateSuperUser('ANOTHERUSER');

        // [Given] The Delegated Helpdesk agent - Partner plan exists
        AzureADPlanTestLibraries.CreatePlan(PlanIds.GetHelpDeskPlanId(), 'Delegated Helpdesk agent - Partner', 9022, '8884DDCA-27B8-E911-BB26-000D3A2B005C');

        // [Given] The plan is not assigned to the current user
        LibraryAssert.IsFalse(UserPlan.Get(PlanIds.GetHelpDeskPlanId(), UserSID), 'Plan should not be assigned to user');

        // [Given] The current user is a delegated admin
        BindSubscription(AzureADUserTestLibrary);
        AzureADUserTestLibrary.SetIsUserDelegatedHelpdesk(true);

        // [Given] The plan configuration for the plan is not customized
        LibraryAssert.IsFalse(PlanConfiguration.IsCustomized(PlanIds.GetHelpDeskPlanId()), 'Plan configuration should not be customized');

        // [When] The plan is assigned per delegated role
        AzureADPlan.AssignPlanToUserWithDelegatedRole(UserSID);

        // [Then] There is an entry in the User Plan table
        LibraryAssert.AreEqual(1, UserPlan.Count(), 'There should be only one plan assignments');
        LibraryAssert.IsTrue(UserPlan.FindFirst(), 'The should be a plan assigned');
        LibraryAssert.AreEqual(UserSID, UserPlan."User Security ID", 'Wrong user was assigned a plan');
        LibraryAssert.AreEqual(PlanIds.GetHelpDeskPlanId(), UserPlan."Plan ID", 'Wrong plan was assigned');

        // [Then] SUPER was not removed from the user
        LibraryAssert.IsTrue(UserPermissions.IsSuper(UserSID), 'User should be SUPER');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure AssignPlansToUserNoDelegatedHelpdesk()
    var
        UserPlan: Record "User Plan";
        AzureADPlan: Codeunit "Azure AD Plan";
        UserPermissions: Codeunit "User Permissions";
        PlanConfiguration: Codeunit "Plan Configuration";
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
        AzureADUserTestLibrary: Codeunit "Azure AD User Test Library";
        PlanConfigurationLibrary: Codeunit "Plan Configuration Library";
        UserPermissionsLibrary: Codeunit "User Permissions Library";
        AzureAdPlanTest: Codeunit "Azure AD Plan Tests";
        PlanIds: Codeunit "Plan Ids";
        UserSID: Guid;
    begin
        // [Scenario] Delegated helpdesk plan is not assigned to a user if they are not delegated helpdesk agent

        DeleteAllFromTablePlanAndUserPlan();
        PlanConfigurationLibrary.ClearPlanConfigurations();
        BindSubscription(AzureAdPlanTest);
        EnvironmentInformationTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [Given] Two SUPER users (need to have at least two users because if it's only one, the SUPER role will not be removed) 
        UserSID := UserPermissionsLibrary.CreateSuperUser('NEWUSER');
        UserPermissionsLibrary.CreateSuperUser('ANOTHERUSER');

        // [Given] The Delegated Helpdesk agent - Partner plan exists
        AzureADPlanTestLibraries.CreatePlan(PlanIds.GetHelpDeskPlanId(), 'Delegated Helpdesk agent - Partner', 9022, '8884DDCA-27B8-E911-BB26-000D3A2B005C');

        // [Given] The plan is not assigned to the current user
        LibraryAssert.IsFalse(UserPlan.Get(PlanIds.GetHelpDeskPlanId(), UserSID), 'Plan should not be assigned to user');

        // [Given] The current user is not a delegated helpdesk
        BindSubscription(AzureADUserTestLibrary);
        AzureADUserTestLibrary.SetIsUserDelegatedHelpdesk(false);

        // [Given] The plan configuration for the plan is not customized
        LibraryAssert.IsFalse(PlanConfiguration.IsCustomized(PlanIds.GetHelpDeskPlanId()), 'Plan configuration should not be customized');

        // [When] The plan is assigned per delegated role
        AzureADPlan.AssignPlanToUserWithDelegatedRole(UserSID);

        // [Then] There is no entry in the User Plan table
        LibraryAssert.AreEqual(0, UserPlan.Count(), 'There should not be any plan assignments');

        // [Then] SUPER was not removed from the user
        LibraryAssert.IsTrue(UserPermissions.IsSuper(UserSID), 'User should be SUPER');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure AssignPlansToUserDelegatedHelpdeskKeepSuper()
    var
        UserPlan: Record "User Plan";
        AzureADPlan: Codeunit "Azure AD Plan";
        UserPermissions: Codeunit "User Permissions";
        PlanConfiguration: Codeunit "Plan Configuration";
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
        AzureADUserTestLibrary: Codeunit "Azure AD User Test Library";
        PlanConfigurationLibrary: Codeunit "Plan Configuration Library";
        UserPermissionsLibrary: Codeunit "User Permissions Library";
        AzureAdPlanTest: Codeunit "Azure AD Plan Tests";
        PlanIds: Codeunit "Plan Ids";
        UserSID, NullGuid : Guid;
    begin
        // [Scenario] Delegated helpdesk plan is assigned to a user and their SUPER role is not removed if the plan configuration contains SUPER

        DeleteAllFromTablePlanAndUserPlan();
        PlanConfigurationLibrary.ClearPlanConfigurations();
        BindSubscription(AzureAdPlanTest);
        EnvironmentInformationTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [Given] Two SUPER users (need to have at least two users because if it's only one, the SUPER role will not be removed)  
        UserSID := UserPermissionsLibrary.CreateSuperUser('NEWUSER');
        UserPermissionsLibrary.CreateSuperUser('ANOTHERUSER');

        // [Given] The Delegated Helpdesk agent - Partner plan exists
        AzureADPlanTestLibraries.CreatePlan(PlanIds.GetHelpDeskPlanId(), 'Delegated Heldesk agent - Partner', 9022, '8884DDCA-27B8-E911-BB26-000D3A2B005C');

        // [Given] The plan is not assigned to the current user
        LibraryAssert.IsFalse(UserPlan.Get(PlanIds.GetHelpDeskPlanId(), UserSID), 'Plan should not be assigned to user');

        // [Given] The current user is a delegated helpdesk
        BindSubscription(AzureADUserTestLibrary);
        AzureADUserTestLibrary.SetIsUserDelegatedHelpdesk(true);

        // [Given] The plan configuration for the plan is customized and contains SUPER
        PlanConfigurationLibrary.AddConfiguration(PlanIds.GetHelpDeskPlanId(), true);
        PlanConfiguration.AddCustomPermissionSetToPlan(PlanIds.GetHelpDeskPlanId(), 'SUPER', NullGuid, 0, '');

        // [When] The plan is assigned per delegated role
        AzureADPlan.AssignPlanToUserWithDelegatedRole(UserSID);

        // [Then] There is an entry in the User Plan table
        LibraryAssert.AreEqual(1, UserPlan.Count(), 'There should be only one plan assignments');
        LibraryAssert.IsTrue(UserPlan.FindFirst(), 'The should be a plan assigned');
        LibraryAssert.AreEqual(UserSID, UserPlan."User Security ID", 'Wrong user was assigned a plan');
        LibraryAssert.AreEqual(PlanIds.GetHelpDeskPlanId(), UserPlan."Plan ID", 'Wrong plan was assigned');

        // [Then] SUPER was not removed from the user
        LibraryAssert.IsTrue(UserPermissions.IsSuper(UserSID), 'User should be SUPER');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure GetAvailablePlansCount()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
    begin
        DeleteAllFromTablePlanAndUserPlan();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD Plan View');

        // [GIVEN] An empty Plan table
        // [WHEN] invoking GetAvailablePlansCount
        // [THEN] The result should be 0
        LibraryAssert.AreEqual(0, AzureADPlan.GetAvailablePlansCount(), 'The Plan table should be empty');

        // [GIVEN] An the Plan table with 1 Plan
        AzureADPlanTestLibraries.CreatePlan('TestPlanAssigned');
        // [WHEN] invoking GetAvailablePlansCount
        // [THEN] The result should be 1
        LibraryAssert.AreEqual(1, AzureADPlan.GetAvailablePlansCount(), 'The Plan table should have only 1 Plan');
    end;

    [Test]
    [HandlerFunctions('ModalHandler')]
    [Scope('OnPrem')]
    procedure AddPlanConfigurationLicense()
    var
        PlanConfiguration: Record "Plan Configuration";
        PlanConfigurationLibrary: Codeunit "Plan Configuration Library";
        PlanConfigurationList: TestPage "Plan Configuration List";
    begin
        // [SCENARIO] Inserting a new License on Plan Configuration page using custom 'New' action.
        // [GIVEN] An empty list of plan configurations
        PlanConfigurationLibrary.ClearPlanConfigurations();

        // [WHEN] User opens Plan Configuration page and presses the custom 'New'' action
        PlanConfigurationList.OpenView();
        PlanConfigurationList.New.Invoke();

        // [WHEN] User selects a Plan in modal and clicks OK
        // [THEN] License is added to Plan Configuration table ("Null" record in test)
        LibraryAssert.RecordCount(PlanConfiguration, 1);
    end;

    local procedure DeleteAllFromTablePlanAndUserPlan()
    var
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
    begin
        AzureADPlanTestLibraries.DeleteAllPlans();
        AzureADPlanTestLibraries.DeleteAllUserPlan();
    end;

    [ModalPageHandler]
    procedure ModalHandler(var Plans: TestPage "Plans")
    var
    begin
        Plans.OK().Invoke();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Azure AD Plan", 'OnUpdateUserAccessForSaaS', '', false, false)]
    local procedure MockUserGroupsAdded(UserSecurityID: Guid; var UserGroupsAdded: Boolean)
    begin
        UserGroupsAdded := true;
    end;
}