// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132909 "Azure AD User Management Test"
{
    Permissions = TableData "User Property" = rimd,
                  TableData "User" = r;
    Subtype = Test;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURE] [SaaS] [Azure AD User Management]
    end;

    var
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        PermissionsMock: Codeunit "Permissions Mock";
        AzureADUserManagementImpl: Codeunit "Azure AD User Mgmt. Impl.";
        AzureADGraphUser: Codeunit "Azure AD Graph User";
        LibraryAssert: Codeunit "Library Assert";
        MockGraphQuery: DotNet MockGraphQuery;
        DeviceGroupNameTxt: Label 'Dynamics 365 Business Central Device Users', Locked = true;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCodeunitRunNoSaaS()
    var
        User: Record User;
        AzureADUserManagementTest: Codeunit "Azure AD User Management Test";
        AzureADPlanTestLibrary: Codeunit "Azure AD Plan Test Library";
        AzureADPlan: Codeunit "Azure AD Plan";
        UserSecurityId: Guid;
    begin
        // [SCENARIO] Codeunit AzureADUserManagement exits immediately if not running in SaaS

        Initialize(AzureADUserManagementTest);
        AzureADPlanTestLibrary.DeleteAllUserPlan();

        // [GIVEN] Not running in SaaS
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);

        // [GIVEN] The Azure AD Graph contains a user with the AccountEnabled flag set to true
        UserSecurityId := CreateGuid();
        AzureADUserManagementTest.AddGraphUser(UserSecurityId);
        AzureADPlanTestLibrary.AssignUserToPlan(UserSecurityId, CreateGuid());

        // [GIVEN] The user record's state is disabled
        DisableUserAccount(UserSecurityId);

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('AAD User Mgt Exec');

        // [WHEN] Running Azure AD User Management
        AzureADUserManagementImpl.Run(UserSecurityId);

        // [THEN] no error is thrown, the codeunit silently exits

        // [THEN] The user record is not updated
        User.Get(UserSecurityId);
        LibraryAssert.AreEqual(User.State::Disabled, User.State, 'The User record should not have been updated');

        // [THEN] The unassigned user plans are not removed
        LibraryAssert.AreNotEqual(false, AzureADPlan.DoesUserHavePlans(UserSecurityId),
            'The User Plan table should not be empty for this user');

        UnbindSubscription(AzureADUserManagementTest);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCodeunitRunNoUserProperty()
    var
        User: Record User;
        UserProperty: Record "User Property";
        AzureADPlanTestLibrary: Codeunit "Azure AD Plan Test Library";
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADUserManagementTest: Codeunit "Azure AD User Management Test";
        UserLoginTestLibrary: Codeunit "User Login Test Library";
        UserId: Guid;
        PlanId: Guid;
    begin
        // [SCENARIO] Codeunit AzureADUserManagement exits immediately if the User 
        // Property for the user does not exist 

        Initialize(AzureADUserManagementTest);
        AzureADPlanTestLibrary.DeleteAllUserPlan();

        // [GIVEN] Running in SaaS
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] The User Property and User Plan tables are empty      
        UserProperty.DeleteAll();
        AzureADPlanTestLibrary.DeleteAllUserPlan();

        // [GIVEN] The Azure AD Graph contains a user 
        UserId := CreateGuid();
        AzureADUserManagementTest.AddGraphUser(UserId);

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
        AzureADUserManagementTest.RunAzureADUserManagement(UserId);

        // [THEN] The user record is not updated
        User.Get(UserId);
        LibraryAssert.AreEqual(User.State::Disabled, User.State,
            'The User record should not have not been updated');

        // [THEN] The User Plan that exists in the database, but not in the Azure AD Graph is not deleted
        LibraryAssert.AreEqual(true, AzureADPlan.IsPlanAssignedToUser(PlanId, UserId),
            'The User Plan table should contain the unassigned user plan');

        UnbindSubscription(AzureADUserManagementTest);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCodeunitRunUserNotFirstLogin()
    var
        UserProperty: Record "User Property";
        AzureADPlanTestLibrary: Codeunit "Azure AD Plan Test Library";
        AzureADPlan: Codeunit "Azure AD Plan";
        UserLoginTestLibrary: Codeunit "User Login Test Library";
        AzureADUserManagementTest: Codeunit "Azure AD User Management Test";
        PlanId: Guid;
    begin
        // [SCENARIO] Codeunit AzureADUserManagement exits immediately if the user has logged in before

        UserLoginTestLibrary.DeleteAllLoginInformation(UserSecurityId());

        // [GIVEN] Running in SaaS
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        Initialize(AzureADUserManagementTest);

        // [GIVEN] The User Property and User Plan tables are empty      
        UserProperty.DeleteAll();
        AzureADPlanTestLibrary.DeleteAllUserPlan();

        // [GIVEN] The Azure AD Graph contains a user 
        AzureADUserManagementTest.AddGraphUser(UserSecurityId());

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
        AzureADUserManagementTest.RunAzureADUserManagement(UserSecurityId());

        // [THEN] The User Plan that exists in the database, but not in the Azure AD Graph is not deleted
        LibraryAssert.AreEqual(true, AzureADPlan.IsPlanAssignedToUser(PlanId, UserSecurityId()),
            'The User Plan table should contain the unassigned user plan');

        UnbindSubscription(AzureADUserManagementTest);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCodeunitRunUserHasNoUserAuthenticationId()
    var
        User: Record User;
        UserProperty: Record "User Property";
        AzureADPlanTestLibrary: Codeunit "Azure AD Plan Test Library";
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADUserManagementTest: Codeunit "Azure AD User Management Test";
        UserLoginTestLibrary: Codeunit "User Login Test Library";
        UserId: Guid;
        PlanId: Guid;
    begin
        // [SCENARIO] Codeunit AzureADUserManagement exits immediately if the user has no graph authentication ID

        // [GIVEN] Running in SaaS
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        Initialize(AzureADUserManagementTest);

        // [GIVEN] The User Property and User Plan tables are empty      
        UserProperty.DeleteAll();
        AzureADPlanTestLibrary.DeleteAllUserPlan();

        // [GIVEN] The Azure AD Graph contains a user 
        UserId := CreateGuid();
        AzureADUserManagementTest.AddGraphUser(UserId);

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
        AzureADUserManagementTest.RunAzureADUserManagement(UserId);

        // [THEN] The user record is not updated
        User.Get(UserId);
        LibraryAssert.AreEqual(User.State::Disabled, User.State,
            'The User record should not have not been updated');

        // [THEN] The User Plan that exists in the database, but not in the Azure AD Graph is not deleted
        LibraryAssert.AreEqual(true, AzureADPlan.IsPlanAssignedToUser(PlanId, UserId),
            'The User Plan table should contain the unassigned user plan');

        UnbindSubscription(AzureADUserManagementTest);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCodeunitRunUserHasAssignedPlans()
    var
        User: Record User;
        UserProperty: Record "User Property";
        AzureADUserManagementTest: Codeunit "Azure AD User Management Test";
        AzureADPlanTestLibrary: Codeunit "Azure AD Plan Test Library";
        UserLoginTestLibrary: Codeunit "User Login Test Library";
        UserId: Guid;
        AssignedUserPlanId: Guid;
        UnassignedUserPlanRecordId: Guid;
        UnassignedUserPlanId: Guid;
    begin
        Initialize(AzureADUserManagementTest);

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
        AzureADUserManagementTest.AddGraphUser(UserId);

        // [GIVEN] There is a User Plan entry corresponding to the user, 
        // but the plan is not assigned to the user in the Azure AD Graph        
        AzureADPlanTestLibrary.AssignUserToPlan(UserId, UnassignedUserPlanRecordId);

        // [GIVEN] Both the Azure AD Graph and the database contain a User Plan for the user
        AzureADUserManagementTest.AddGraphUserPlan(UserId, AssignedUserPlanId, '', 'Enabled');
        AzureADPlanTestLibrary.AssignUserToPlan(UserId, AssignedUserPlanId);

        // [GIVEN] The Azure AD Graph contains a User Plan that the database does not
        AzureADUserManagementTest.AddGraphUserPlan(UserId, UnassignedUserPlanId, '', 'Enabled');

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
        AzureADUserManagementTest.RunAzureADUserManagement(UserId);

        // [THEN] The user record is not updated
        User.Get(UserId);
        LibraryAssert.AreEqual(User.State::Disabled, User.State,
            'The User record should not have not been updated');

        UnbindSubscription(AzureADUserManagementTest);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCodeunitRunPlansAreRefreshed()
    var
        User: Record User;
        UserProperty: Record "User Property";
        AzureADUserManagementTest: Codeunit "Azure AD User Management Test";
        AzureADPlanTestLibrary: Codeunit "Azure AD Plan Test Library";
        AzureADPlan: Codeunit "Azure AD Plan";
        UserLoginTestLibrary: Codeunit "User Login Test Library";
        UserId: Guid;
        AssignedUserPlanId: Guid;
    begin
        Initialize(AzureADUserManagementTest);

        AssignedUserPlanId := CreateGuid();

        // [GIVEN] The User Property and User Plan tables are empty      
        UserProperty.DeleteAll();
        AzureADPlanTestLibrary.DeleteAllUserPlan();

        // [GIVEN] Running in SaaS
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] The Azure AD Graph contains a user 
        UserId := CreateGuid();
        AzureADUserManagementTest.AddGraphUser(UserId);

        // [GIVEN] The Azure AD Graph contains a User Plan that the database does not
        AzureADUserManagementTest.AddGraphUserPlan(UserId, AssignedUserPlanId, '', 'Enabled');

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
        AzureADUserManagementTest.RunAzureADUserManagement(UserId);

        // [THEN] The user record is updated
        User.Get(UserId);
        LibraryAssert.AreEqual(User.State::Enabled, User.State, 'The User record should have been updated');

        // [THEN] A new entry should be inserted in the User Plan table for the plan that is assigned to 
        // the user in the Azure AD Graph
        LibraryAssert.AreEqual(true, AzureADPlan.IsPlanAssigned(AssignedUserPlanId),
            'There should be an entry corresponding to the unassigned plan in the User Plan table');

        UnbindSubscription(AzureADUserManagementTest);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestOfficeSyncWizard()
    var
        User: Record User;
        TempAzureADUserUpdate: Record "Azure AD User Update Buffer" temporary;
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADUserManagementTest: Codeunit "Azure AD User Management Test";
        AzureADUserMgmtImpl: Codeunit "Azure AD User Mgmt. Impl.";
        PlanIds: Codeunit "Plan Ids";
        GraphUserNonBC: DotNet UserInfo;
        GraphUserDevice: DotNet UserInfo;
        GraphUserEssential: DotNet UserInfo;
    begin
        Initialize(AzureADUserManagementTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        AzureADUserMgmtImpl.SetTestInProgress(true);

        // create office users
        AzureADUserManagementTest.AddGraphUser(GraphUserDevice);
        SetValuesOnGraphUser(GraphUserDevice, 'device@microsoft.com', 'emailDevice@microsoft.com', 'Device', 'Guy');
        AzureADUserManagementTest.AssignDeviceGroup(GraphUserDevice);

        AzureADUserManagementTest.AddGraphUser(GraphUserEssential);
        SetValuesOnGraphUser(GraphUserEssential, 'essential@microsoft.com', 'emailEssential@microsoft.com', 'Essential', 'Guy');
        AzureADUserManagementTest.AssignPlan(GraphUserEssential, PlanIds.GetEssentialPlanId(), 'service', 'status');

        AzureADUserManagementTest.AddGraphUser(GraphUserNonBC);
        SetValuesOnGraphUser(GraphUserNonBC, 'office@microsoft.com', 'emailNonBC@microsoft.com', 'No', 'BC');

        // run the wizard to sync them
        AzureADUserMgmtImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdate);
        AzureADUserMgmtImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdate);

        // verify users
        User.SetRange("User Name", 'device');
        LibraryAssert.IsTrue(User.FindFirst(), 'User not created');
        LibraryAssert.AreEqual(GraphUserDevice.UserPrincipalName(), User."Authentication Email", 'mismatch');
        LibraryAssert.AreEqual(GraphUserDevice.Mail(), User."Contact Email", 'mismatch');
        LibraryAssert.AreEqual('Device Guy', User."Full Name", 'mismatch');

        User.SetRange("User Name", 'essential');
        LibraryAssert.IsTrue(User.FindFirst(), 'User not created');
        LibraryAssert.AreEqual(GraphUserEssential.UserPrincipalName(), User."Authentication Email", 'mismatch');
        LibraryAssert.AreEqual(GraphUserEssential.Mail(), User."Contact Email", 'mismatch');
        LibraryAssert.AreEqual('Essential Guy', User."Full Name", 'mismatch');
        LibraryAssert.IsTrue(AzureADPlan.DoesUserHavePlans(User."User Security ID"), 'User plan not created');
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetEssentialPlanId(), User."User Security ID"), 'wrong plan assigned');

        User.SetRange("User Name", 'office');
        LibraryAssert.IsTrue(User.IsEmpty(), 'User got created');

        UnbindSubscription(AzureADUserManagementTest);
        // create new users + modify some of the old ones + remove some old ones

        // run the wizard to sync and verify changes
    end;


    local procedure Initialize(AzureADUserManagementTest: Codeunit "Azure AD User Management Test")
    begin
        Clear(AzureADUserManagementImpl);
        AzureADUserManagementTest.SetupMockGraphQuery();
        BindSubscription(AzureADUserManagementTest);
    end;

    procedure SetupMockGraphQuery()
    begin
        MockGraphQuery := MockGraphQuery.MockGraphQuery();
    end;

    procedure AddGraphUser(UserId: Text)
    var
        GraphUserInfo: DotNet UserInfo;
    begin
        CreateGraphUser(GraphUserInfo, UserId);
        MockGraphQuery.AddUser(GraphUserInfo);
    end;

    procedure AddGraphUser(var GraphUserInfo: DotNet UserInfo)
    begin
        CreateGraphUser(GraphUserInfo, CreateGuid());
        MockGraphQuery.AddUser(GraphUserInfo);
    end;

    local procedure CreateGraphUser(var GraphUserInfo: DotNet UserInfo; UserId: Text)
    begin
        GraphUserInfo := GraphUserInfo.UserInfo();
        GraphUserInfo.ObjectId := UserId;
        GraphUserInfo.UserPrincipalName := 'email@microsoft.com';
        GraphUserInfo.Mail := 'email@microsoft.com';
        GraphUserInfo.AccountEnabled := true;
    end;

    procedure AssignPlan(var GraphUserInfo: DotNet UserInfo; AssignedPlanId: Guid; AssignedPlanService: Text; CapabilityStatus: Text)
    var
        AssignedServicePlanInfo: DotNet ServicePlanInfo;
        GuidVariant: Variant;
    begin
        AssignedServicePlanInfo := AssignedServicePlanInfo.ServicePlanInfo();
        GuidVariant := AssignedPlanId;
        AssignedServicePlanInfo.ServicePlanId := GuidVariant;
        AssignedServicePlanInfo.ServicePlanName := AssignedPlanService;
        AssignedServicePlanInfo.CapabilityStatus := CapabilityStatus;

        MockGraphQuery.AddAssignedPlanToUser(GraphUserInfo, AssignedServicePlanInfo);
    end;

    procedure AssignDeviceGroup(var GraphUserInfo: DotNet UserInfo)
    var
        AssignedGroup: DotNet GroupInfo;
    begin
        AssignedGroup := AssignedGroup.GroupInfo();
        AssignedGroup.DisplayName := DeviceGroupNameTxt;

        MockGraphQuery.AddUserGroup(GraphUserInfo, AssignedGroup);
    end;

    local procedure SetValuesOnGraphUser(var GraphUserInfo: DotNet UserInfo; PrincipalName: Text; ContactMail: Text; FirstName: Text; Surname: Text)
    begin
        GraphUserInfo.UserPrincipalName := PrincipalName;
        GraphUserInfo.Mail := ContactMail;
        GraphUserInfo.GivenName := FirstName;
        GraphUserInfo.Surname := Surname;
    end;

    procedure AddGraphUserPlan(UserId: Text; AssignedPlanId: Guid; AssignedPlanService: Text; CapabilityStatus: Text)
    var
        GraphUserInfo: DotNet UserInfo;
        AssignedServicePlanInfo: DotNet ServicePlanInfo;
        GuidVariant: Variant;
    begin
        AssignedServicePlanInfo := AssignedServicePlanInfo.ServicePlanInfo();
        GuidVariant := AssignedPlanId;
        AssignedServicePlanInfo.ServicePlanId := GuidVariant;
        AssignedServicePlanInfo.ServicePlanName := AssignedPlanService;
        AssignedServicePlanInfo.CapabilityStatus := CapabilityStatus;

        GraphUserInfo := MockGraphQuery.GetUserByObjectId(UserId);
        MockGraphQuery.AddAssignedPlanToUser(GraphUserInfo, AssignedServicePlanInfo);
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

    procedure RunAzureADUserManagement(UserId: Guid)
    begin
        AzureADUserManagementImpl.SetTestInProgress(true);
        AzureADUserManagementImpl.Run(UserId);
    end;

    procedure GetGraphUserAssignedPlans(var AssignedPlans: DotNet IEnumerable; UserId: Guid)
    var
        GraphUserInfo: DotNet UserInfo;
    begin
        AzureADGraphUser.SetTestInProgress(true);
        AzureADGraphUser.GetGraphUser(UserId, GraphUserInfo);
        AssignedPlans := GraphUserInfo.AssignedPlans();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Azure AD Graph", 'OnInitialize', '', false, false)]
    local procedure OnGraphInitialization(var GraphQuery: DotNet GraphQuery)
    begin
        GraphQuery := GraphQuery.GraphQuery(MockGraphQuery);
    end;
}

