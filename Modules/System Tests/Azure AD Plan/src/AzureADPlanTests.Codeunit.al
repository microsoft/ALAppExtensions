// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132912 "Azure AD Plan Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";

    [Test]
    [Scope('OnPrem')]
    procedure CheckPlansNumber()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
    begin
        // [SCENARIO] There should be 17 Plans

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD Plan View');

        LibraryAssert.AreEqual(17, AzureADPlan.GetAvailablePlansCount(),
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
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
        GraphUserInfo: DotNet UserInfo;
        UserID: Guid;
        PlanID: Guid;
    begin
        DeleteAllFromTablePlanAndUserPlan();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD Plan View');

        // [GIVEN] a service plan and a user who is entitled to a plan 
        UserId := CreateGuid();
        CreateGraphUser(GraphUserInfo, UserId);
        PlanID := AzureADPlanTestLibraries.CreatePlan('TestPlan');
        PopulateMockGraph(GraphUserInfo, PlanID, 'TestPlan');

        // [WHEN] checking if the user is entitled to a service plan
        // [THEN] the result should be true
        LibraryAssert.AreEqual(true, AzureADPlan.IsGraphUserEntitledFromServicePlan(GraphUserInfo), 'The user should be entitled from the service Plan');

        // [GIVEN] a user who is NOT entitled to any plan
        CreateGraphUser(GraphUserInfo, UserSecurityId());

        // [WHEN] checking if the user is entitled to a plan
        // [THEN] the result should be false
        LibraryAssert.AreEqual(false, AzureADPlan.IsGraphUserEntitledFromServicePlan(GraphUserInfo), 'The user should not be entitled from the service Plan');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestUpdateUserPlans()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        GraphUserInfo: DotNet UserInfo;
        UserID: Guid;
        PlanID: Guid;
    begin
        DeleteAllFromTablePlanAndUserPlan();
        AzureADPlan.SetTestInProgress(true);

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD Plan View');

        // [GIVEN] a User and a GraphUser with a Plan which is not in the table Plan and a user
        UserId := CreateGuid();
        CreateGraphUser(GraphUserInfo, UserId);
        PlanID := CreateGuid();
        PopulateMockGraph(GraphUserInfo, PlanID, 'TestPlan');

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

    local procedure PopulateMockGraph(GraphUserInfo: DotNet UserInfo; PlanId: Guid; PlanName: Text)
    var
        MockGraphQuery: DotNet MockGraphQuery;
    begin
        MockGraphQuery := MockGraphQuery.MockGraphQuery();
        MockGraphQuery.AddUser(GraphUserInfo);
        AddUserPlan(MockGraphQuery, GraphUserInfo, PlanId, PlanName);
    end;

    local procedure CreateGraphUser(var GraphUserInfo: DotNet UserInfo; UserId: Guid)
    begin
        GraphUserInfo := GraphUserInfo.UserInfo();
        GraphUserInfo.ObjectId := UserId;
    end;

    local procedure AddUserPlan(var MockGraphQuery: DotNet MockGraphQuery; GraphUserInfo: DotNet UserInfo; PlanId: Guid; PlanName: Text)
    var
        AssignedPlan: DotNet ServicePlanInfo;
    begin
        AssignedPlan := AssignedPlan.ServicePlanInfo();
        AssignedPlan.ServicePlanId := PlanId;
        AssignedPlan.ServicePlanName := PlanName;
        AssignedPlan.CapabilityStatus := 'Enabled';

        MockGraphQuery.AddAssignedPlanToUser(GraphUserInfo, AssignedPlan);
    end;

    local procedure DeleteAllFromTablePlanAndUserPlan()
    var
        AzureADPlanTestLibraries: Codeunit "Azure AD Plan Test Library";
    begin
        AzureADPlanTestLibraries.DeleteAllPlans();
        AzureADPlanTestLibraries.DeleteAllUserPlan();
    end;
}