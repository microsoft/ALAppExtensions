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

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsPlanAssigned()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        GraphUser: DotNet UserInfo;
        PlanId: Guid;
    begin
        //[GIVEN] A specific plan with at least one user assigned to it
        PlanId := CreateGuid();
        PopulateTablesPlanAndUserPlan(PlanId, 'TestPlan', CreateGuid());

        //[WHEN] checking if the plan is assigned to at least one user
        //[THEN] the result should be true
        LibraryAssert.AreEqual(true, AzureADPlan.IsPlanAssigned(PlanID), 'The Plan should be assigned to at least one user');

        // //[GIVEN] A specific plan with no user assigned to it
        PlanId := CreateGuid();

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
        GraphUser: DotNet UserInfo;
        PlanId: Guid;
    begin
        //[GIVEN] A specific plan which is assigned to the current user
        PlanId := CreateGuid();
        PopulateTablesPlanAndUserPlan(PlanId, 'TestPlan', UserSecurityId());

        // [WHEN] checking if the plan is assigned to the current user
        // [THEN] the result should be true
        LibraryAssert.AreEqual(true, AzureADPlan.IsPlanAssigned(PlanId), 'The Plan should be assigned to the current user');

        //[GIVEN] A specific plan which is NOT assigned to the current user
        PlanID := CreateGuid();

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
        GraphUser: DotNet UserInfo;
        UserId: Guid;
    begin
        AzureADPlan.SetTestInProgress(true);

        // [GIVEN] a service plan and a user who is entitled to this plan 
        UserId := CreateGuid();
        CreateGraphUser(GraphUser, UserId);
        PopulateTablePlanUsingMockGraph(GraphUser, CreateGuid(), 'TestPlan', UserId);

        // [WHEN] checking if the user is entitled to a service plan
        // [THEN] the result should be true
        LibraryAssert.AreEqual(true, AzureADPlan.IsGraphUserEntitledFromServicePlan(GraphUser), 'The user should be entitled from the service Plan');

        // [GIVEN] a user who is NOT entitled to any plan
        CreateGraphUser(GraphUser, UserSecurityId());

        // [WHEN] checking if the user is entitled to a plan
        // [THEN] the result should be false
        LibraryAssert.AreEqual(false, AzureADPlan.IsGraphUserEntitledFromServicePlan(GraphUser), 'The user should not be entitled from the service Plan');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestIsPlanAssignedToSpecificUser()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        GraphUser: DotNet UserInfo;
        PlanId: Guid;
        UserId: Guid;
    begin
        //[GIVEN] A specific plan which is assigned to a specific user
        PlanId := CreateGuid();
        UserId := CreateGuid();
        PopulateTablesPlanAndUserPlan(PlanId, 'TestPlan', UserId);

        // [WHEN] checking if the plan is assigned to the current user
        // [THEN] the result should be true
        LibraryAssert.AreEqual(true, AzureADPlan.IsPlanAssignedToUser(PlanId, UserId), 'The Plan should be assigned to a user');

        //[GIVEN] A specific plan which is NOT assigned to a specific user
        // [WHEN] checking if the plan is assigned to the user
        // [THEN] the result should be false
        LibraryAssert.AreEqual(false, AzureADPlan.IsPlanAssignedToUser(PlanId, CreateGuid()), 'The Plan should not be assigned to a user');

        //[GIVEN] A specific user who doesn't have the specific plan
        // [WHEN] checking if the specific user has the plan assigned
        // [THEN] the result should be false
        LibraryAssert.AreEqual(false, AzureADPlan.IsPlanAssignedToUser(CreateGuid(), UserId), 'The Plan should not be assigned to a user');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestDoPlansExist()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
    begin
        PopulateTablesPlanAndUserPlan(CreateGuid(), 'TestPlan', CreateGuid());

        LibraryAssert.AreEqual(false, AzureADPlan.DoPlansExist(), 'The table Plan should not be empty');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestDoUserPlansExist()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
    begin
        PopulateTablesPlanAndUserPlan(CreateGuid(), 'TestPlan', CreateGuid());

        LibraryAssert.AreEqual(false, AzureADPlan.DoUserPlansExist(), 'The table User Plan should not be empty');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestDoesPlanExist()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanId: Guid;
    begin
        LibraryAssert.AreEqual(false, AzureADPlan.DoesPlanExist(CreateGuid()), 'The given Plan should exist');

        PlanId := CreateGuid();
        PopulateTablesPlanAndUserPlan(PlanId, 'TestPlan', CreateGuid());

        LibraryAssert.AreEqual(true, AzureADPlan.DoesPlanExist(PlanId), 'The given Plan should not exist');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestDoesUserHavePlans()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        UserId: Guid;
    begin
        UserId := CreateGuid();

        LibraryAssert.AreEqual(false, AzureADPlan.DoesUserHavePlans(UserId), 'The user should not have any Plan assigned');

        PopulateTablesPlanAndUserPlan(CreateGuid(), 'TestPlan', UserId);

        LibraryAssert.AreEqual(true, AzureADPlan.DoesUserHavePlans(UserId), 'The user should have at least one Plan assigned');
    end;

    procedure PopulateTablesPlanAndUserPlan(PlanId: Guid; PlanName: Text; UserId: Guid)
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        GraphUser: DotNet UserInfo;
    begin
        CreateGraphUser(GraphUser, UserId);
        PopulateTablePlanUsingMockGraph(GraphUser, PlanId, PlanName, UserId);
    end;

    local procedure PopulateTablePlanUsingMockGraph(GraphUser: DotNet UserInfo; PlanId: Guid;
                                                                   PlanName: Text;
                                                                   UserId: Guid)
    var
        AzureADPlan: Codeunit "Azure AD Plan";
    begin
        AddGraphUser(GraphUser, PlanId, PlanName);

        AzureADPlan.SetTestInProgress(true);
        AzureADPlan.UpdateUserPlans(UserId, GraphUser);
    end;

    local procedure CreateGraphUser(var GraphUser: DotNet UserInfo; UserId: Guid)
    begin
        GraphUser := GraphUser.UserInfo();
        GraphUser.ObjectId := UserId;
    end;

    local procedure AddGraphUser(var GraphUser: DotNet UserInfo; PlanId: Guid;
                                                    PlanName: Text)
    var
        MockGraphQuery: DotNet MockGraphQuery;
    begin
        MockGraphQuery := MockGraphQuery.MockGraphQuery();
        MockGraphQuery.AddUser(GraphUser);
        AddUserPlan(MockGraphQuery, GraphUser, PlanId, PlanName);
    end;

    local procedure AddUserPlan(var MockGraphQuery: DotNet MockGraphQuery; GraphUser: DotNet UserInfo;
                                                        PlanId: Guid;
                                                        PlanName: Text)
    var
        AssignedPlan: DotNet ServicePlanInfo;
    begin
        AssignedPlan := AssignedPlan.ServicePlanInfo();
        AssignedPlan.ServicePlanId := PlanId;
        AssignedPlan.ServicePlanName := PlanName;
        AssignedPlan.CapabilityStatus := 'Enabled';

        MockGraphQuery.AddAssignedPlanToUser(GraphUser, AssignedPlan);
    end;
}