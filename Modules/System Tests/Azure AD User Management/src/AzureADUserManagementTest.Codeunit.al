// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132909 "Azure AD User Management Test"
{
    Permissions = TableData "User Property" = rimd,
                  TableData "User" = r;
    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] [SaaS] [Azure AD User Management]
    end;

    var
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        PermissionsMock: Codeunit "Permissions Mock";
        LibraryAssert: Codeunit "Library Assert";
        AzureADGraphTestLibrary: Codeunit "Azure AD Graph Test Library";
        AzureADPlanTestLibrary: Codeunit "Azure AD Plan Test Library";
        AzureADUserMgtTestLibrary: Codeunit "Azure AD User Mgt Test Library";
        MockGraphQueryTestLibrary: Codeunit "MockGraphQuery Test Library";

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCodeunitRunNoSaaS()
    var
        User: Record User;
        AzureADUserMgmtImpl: Codeunit "Azure AD User Mgmt. Impl.";
        AzureADPlan: Codeunit "Azure AD Plan";
        UserSecurityId: Guid;
    begin
        // [SCENARIO] Codeunit AzureADUserManagement exits immediately if not running in SaaS

        Initialize();
        AzureADPlanTestLibrary.DeleteAllUserPlan();

        // [GIVEN] Not running in SaaS
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);

        // [GIVEN] The Azure AD Graph contains a user with the AccountEnabled flag set to true
        UserSecurityId := CreateGuid();
        AddGraphUser(UserSecurityId);
        AzureADPlanTestLibrary.AssignUserToPlan(UserSecurityId, CreateGuid());

        // [GIVEN] The user record's state is disabled
        DisableUserAccount(UserSecurityId);

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD User Mgt Exec');

        // [WHEN] Running Azure AD User Management
        AzureADUserMgmtImpl.Run(UserSecurityId);

        // [THEN] no error is thrown, the codeunit silently exits

        // [THEN] The user record is not updated
        User.Get(UserSecurityId);
        LibraryAssert.AreEqual(User.State::Disabled, User.State, 'The User record should not have been updated');

        // [THEN] The unassigned user plans are not removed
        LibraryAssert.AreNotEqual(false, AzureADPlan.DoesUserHavePlans(UserSecurityId),
            'The User Plan table should not be empty for this user');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCodeunitRunNoUserProperty()
    var
        User: Record User;
        UserProperty: Record "User Property";
        AzureADPlan: Codeunit "Azure AD Plan";
        UserLoginTestLibrary: Codeunit "User Login Test Library";
        UserId: Guid;
        PlanId: Guid;
    begin
        // [SCENARIO] Codeunit AzureADUserManagement exits immediately if the User 
        // Property for the user does not exist 

        Initialize();
        AzureADPlanTestLibrary.DeleteAllUserPlan();

        // [GIVEN] Running in SaaS
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] The User Property and User Plan tables are empty      
        UserProperty.DeleteAll();
        AzureADPlanTestLibrary.DeleteAllUserPlan();

        // [GIVEN] The Azure AD Graph contains a user 
        UserId := CreateGuid();
        AddGraphUser(UserId);

        // [GIVEN] There is a User Plan entry corresponding to the user, 
        // but the plan is not assigned to the user in the Azure AD Graph     
        PlanId := CreateGuid();
        AzureADPlanTestLibrary.AssignUserToPlan(UserId, PlanId);

        // [GIVEN] The user record's state is disabled
        DisableUserAccount(UserId);

        // [GIVEN] It is the first time that the test user logs in
        UserLoginTestLibrary.DeleteAllLoginInformation(UserId);

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD User Mgt Exec');

        // [WHEN] Running Azure AD User Management on the user
        AzureADUserMgtTestLibrary.Run(UserId);

        // [THEN] The user record is not updated
        User.Get(UserId);
        LibraryAssert.AreEqual(User.State::Disabled, User.State,
            'The User record should not have not been updated');

        // [THEN] The User Plan that exists in the database, but not in the Azure AD Graph is not deleted
        LibraryAssert.AreEqual(true, AzureADPlan.IsPlanAssignedToUser(PlanId, UserId),
            'The User Plan table should contain the unassigned user plan');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCodeunitRunUserNotFirstLogin()
    var
        UserProperty: Record "User Property";
        AzureADPlan: Codeunit "Azure AD Plan";
        UserLoginTestLibrary: Codeunit "User Login Test Library";
        PlanId: Guid;
    begin
        // [SCENARIO] Codeunit AzureADUserManagement exits immediately if the user has logged in before

        UserLoginTestLibrary.DeleteAllLoginInformation(UserSecurityId());

        // [GIVEN] Running in SaaS
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        Initialize();

        // [GIVEN] The User Property and User Plan tables are empty      
        UserProperty.DeleteAll();
        AzureADPlanTestLibrary.DeleteAllUserPlan();

        // [GIVEN] The Azure AD Graph contains a user 
        AddGraphUser(UserSecurityId());

        // [GIVEN] There is a User Plan entry corresponding to the user, 
        // but the plan is not assigned to the user in the Azure AD Graph        
        AzureADPlanTestLibrary.AssignUserToPlan(UserSecurityId(), PlanId);

        // [GIVEN] There is an entry in the User Property table for the test user 
        // [GIVEN] The User Authentication Object Id for the test user is not empty
        UserProperty.Init();
        UserProperty."User Security ID" := UserSecurityId();
        UserProperty."Authentication Object ID" := UserSecurityId();
        UserProperty.Insert();

        // [GIVEN] It is not the first time that the test user logs in
        UserLoginTestLibrary.InsertUserLogin(UserSecurityId(), 0D, CurrentDateTime(), 0DT);

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD User Mgt Exec');

        // [WHEN] Running Azure AD User Management on the user
        AzureADUserMgtTestLibrary.Run(UserSecurityId());

        // [THEN] The User Plan that exists in the database, but not in the Azure AD Graph is not deleted
        LibraryAssert.AreEqual(true, AzureADPlan.IsPlanAssignedToUser(PlanId, UserSecurityId()),
            'The User Plan table should contain the unassigned user plan');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCodeunitRunUserHasNoUserAuthenticationId()
    var
        User: Record User;
        UserProperty: Record "User Property";
        AzureADPlan: Codeunit "Azure AD Plan";
        UserLoginTestLibrary: Codeunit "User Login Test Library";
        UserId: Guid;
        PlanId: Guid;
    begin
        // [SCENARIO] Codeunit AzureADUserManagement exits immediately if the user has no graph authentication ID

        // [GIVEN] Running in SaaS
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        Initialize();

        // [GIVEN] The User Property and User Plan tables are empty      
        UserProperty.DeleteAll();
        AzureADPlanTestLibrary.DeleteAllUserPlan();

        // [GIVEN] The Azure AD Graph contains a user 
        UserId := CreateGuid();
        AddGraphUser(UserId);

        // [GIVEN] There is a User Plan entry corresponding to the user, 
        // but the plan is not assigned to the user in the Azure AD Graph     
        PlanId := CreateGuid();
        AzureADPlanTestLibrary.AssignUserToPlan(UserId, PlanId);

        // [GIVEN] The user record's state is disabled
        DisableUserAccount(UserId);

        // [GIVEN] There is an entry in the User Property table for the test user 
        // [GIVEN] The User Authentication Object Id for the test user is empty  
        UserProperty.Get(UserId);
        UserProperty."Authentication Object ID" := '';
        UserProperty.Modify();

        // [GIVEN] It is the first time that the test user logs in
        UserLoginTestLibrary.DeleteAllLoginInformation(UserId);

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD User Mgt Exec');

        // [WHEN] Running Azure AD User Management on the user
        AzureADUserMgtTestLibrary.Run(UserId);

        // [THEN] The user record is not updated
        User.Get(UserId);
        LibraryAssert.AreEqual(User.State::Disabled, User.State,
            'The User record should not have not been updated');

        // [THEN] The User Plan that exists in the database, but not in the Azure AD Graph is not deleted
        LibraryAssert.AreEqual(true, AzureADPlan.IsPlanAssignedToUser(PlanId, UserId),
            'The User Plan table should contain the unassigned user plan');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCodeunitRunUserHasAssignedPlans()
    var
        User: Record User;
        UserProperty: Record "User Property";
        UserLoginTestLibrary: Codeunit "User Login Test Library";
        UserId: Guid;
        AssignedUserPlanId: Guid;
        UnassignedUserPlanRecordId: Guid;
        UnassignedUserPlanId: Guid;
    begin
        Initialize();

        AssignedUserPlanId := CreateGuid();
        UnassignedUserPlanRecordId := CreateGuid();
        UnassignedUserPlanId := CreateGuid();

        // [GIVEN] The User Property and User Plan tables are empty      
        UserProperty.DeleteAll();
        AzureADPlanTestLibrary.DeleteAllUserPlan();

        // [GIVEN] Running in SaaS
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] The Azure AD Graph contains a user 
        UserId := CreateGuid();
        AddGraphUser(UserId);

        // [GIVEN] There is a User Plan entry corresponding to the user, 
        // but the plan is not assigned to the user in the Azure AD Graph        
        AzureADPlanTestLibrary.AssignUserToPlan(UserId, UnassignedUserPlanRecordId);

        // [GIVEN] Both the Azure AD Graph and the database contain a User Plan for the user
        MockGraphQueryTestLibrary.AddUserPlan(UserId, AssignedUserPlanId, '', 'Enabled');
        AzureADPlanTestLibrary.AssignUserToPlan(UserId, AssignedUserPlanId);

        // [GIVEN] The Azure AD Graph contains a User Plan that the database does not
        MockGraphQueryTestLibrary.AddUserPlan(UserId, UnassignedUserPlanId, '', 'Enabled');

        // [GIVEN] The user record's state is disabled
        DisableUserAccount(UserId);

        // [GIVEN] There is an entry in the User Property table for the test user 
        // [GIVEN] The User Authentication Object Id for the test user is not empty  
        UserProperty.Get(UserId);
        UserProperty."Authentication Object ID" := UserId;
        UserProperty.Modify();

        // [GIVEN] It is the first time that the test user logs in
        UserLoginTestLibrary.DeleteAllLoginInformation(UserId);

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD User Mgt Exec');

        // [WHEN] Running Azure AD User Management on the user
        AzureADUserMgtTestLibrary.Run(UserId);

        // [THEN] The user record is not updated
        User.Get(UserId);
        LibraryAssert.AreEqual(User.State::Disabled, User.State,
            'The User record should not have not been updated');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCodeunitRunPlansAreRefreshed()
    var
        User: Record User;
        UserProperty: Record "User Property";
        AzureADPlan: Codeunit "Azure AD Plan";
        UserLoginTestLibrary: Codeunit "User Login Test Library";
        UserId: Guid;
        AssignedUserPlanId: Guid;
    begin
        Initialize();

        AssignedUserPlanId := CreateGuid();

        // [GIVEN] The User Property and User Plan tables are empty      
        UserProperty.DeleteAll();
        AzureADPlanTestLibrary.DeleteAllUserPlan();

        // [GIVEN] Running in SaaS
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] The Azure AD Graph contains a user 
        UserId := CreateGuid();
        AddGraphUser(UserId);

        // [GIVEN] The Azure AD Graph contains a User Plan that the database does not
        MockGraphQueryTestLibrary.AddUserPlan(UserId, AssignedUserPlanId, '', 'Enabled');

        // [GIVEN] The user record's state is disabled
        DisableUserAccount(UserId);

        // [GIVEN] There is an entry in the User Property table for the test user 
        // [GIVEN] The User Authentication Object Id for the test user is not empty  
        UserProperty.Get(UserId);
        UserProperty."Authentication Object ID" := UserId;
        UserProperty.Modify();

        // [GIVEN] It is the first time that the test user logs in
        UserLoginTestLibrary.DeleteAllLoginInformation(UserId);

        // [WHEN] Running Azure AD User Management on the user
        AzureADUserMgtTestLibrary.Run(UserId);

        // [THEN] The user record is updated
        User.Get(UserId);
        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The User record should have been updated');

        // [THEN] A new entry should be inserted in the User Plan table for the plan that is assigned to 
        // the user in the Azure AD Graph
        LibraryAssert.AreEqual(true, AzureADPlan.IsPlanAssigned(AssignedUserPlanId),
            'There should be an entry corresponding to the unassigned plan in the User Plan table');

        TearDown();
    end;

    local procedure Initialize()
    begin
        Clear(AzureADGraphTestLibrary);
        Clear(AzureADPlanTestLibrary);
        Clear(AzureADUserMgtTestLibrary);
        Clear(MockGraphQueryTestLibrary);

        BindSubscription(AzureADGraphTestLibrary);
        BindSubscription(AzureADPlanTestLibrary);
        BindSubscription(AzureADUserMgtTestLibrary);

        MockGraphQueryTestLibrary.SetupMockGraphQuery();
        AzureADGraphTestLibrary.SetMockGraphQuery(MockGraphQueryTestLibrary);
    end;

    local procedure TearDown()
    begin
        UnbindSubscription(AzureADGraphTestLibrary);
        UnbindSubscription(AzureADPlanTestLibrary);
        UnbindSubscription(AzureADUserMgtTestLibrary);
    end;

    local procedure AddGraphUser(UserId: Text)
    var
        NullGuid: Guid;
    begin
        MockGraphQueryTestLibrary.AddGraphUser(UserId, 'John', 'Doe', 'email@microsoft.com', NullGuid, '', '');
    end;

    local procedure DisableUserAccount(UserSecurityId: Guid)
    var
        User: Record User;
    begin
        User.Init();
        User."User Security ID" := UserSecurityId;
        User.State := User.State::Disabled;
        User.Insert();
    end;
}

