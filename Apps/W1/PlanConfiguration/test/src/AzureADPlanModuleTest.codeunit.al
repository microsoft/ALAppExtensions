codeunit 132913 "Azure AD Plan Module Test"
{
    Subtype = Test;
    TestPermissions = Restrictive;

    trigger OnRun()
    begin
        // [FEATURE] [SaaS] [Azure AD Plan]
    end;

    var
        Assert: Codeunit Assert;
        LibraryAzureADUserMgmt: Codeunit "Library - Azure AD User Mgmt.";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        LibraryPermissions: Codeunit "Library - Permissions";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        InformationWorkerUserGroupTxt: Label 'Information Worker';
        MixedPlansNonAdminErr: Label 'All users must be assigned to the same license, either Basic, Essential, or Premium. %1 and %2 are assigned to different licenses, for example, but there may be other mismatches. Your system administrator or Microsoft partner can verify license assignments in your Microsoft 365 admin portal.\\We will sign you out when you choose the OK button.';
        MixedPlansMsg: Label 'One or more users are not assigned to the same Business Central license. For example, we found that users %1 and %2 are assigned to different licenses, but there may be other mismatches. In your Microsoft 365 admin center, make sure that all users are assigned to the same Business Central license, either Basic, Essential, or Premium.  Afterward, update Business Central by opening the Users page and using the ''Update Users from Office 365'' action.', Comment = '%1 = %2 = Authnetication email.';
        FirstUserAuthenticationEmail: Text;
        SecondUserAuthenticationEmail: Text;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestEssentialUserIsNotSuperIfSuperExistsInFirstLoginFlow()
    var
        User: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        // [SCENARIO] User should get SUPER revoked if there is another SUPER in the system
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] A super user
        CreateUserWithPlan(User, PlanIds.GetEssentialPlanId());

        // [WHEN] First login flow is executed
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddSecurity();
        AzureADPlan.RefreshUserPlanAssignments(User."User Security ID");

        // [THEN] User is not SUPER
        Assert.IsFalse(IsUserInPermissionSet(User."User Security ID", 'SUPER'), '');

        // Rollback SaaS test
        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestEssentialUsersSuperIsNotRevokedInGetUserFromO365Flow()
    var
        User: Record User;
        UsersCreateSuperUser: Codeunit "Users - Create Super User";
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        // [SCENARIO] SUPER on the User should not be revoked if user pulled from non first login flow
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [WHEN] A SUPER user with an essential plan is created
        CreateUserWithPlan(User, PlanIds.GetEssentialPlanId());
        LibraryPermissions.AddUserToPlan(User."User Security ID", PlanIds.GetEssentialPlanId());
        UsersCreateSuperUser.AddUserAsSuper(User);

        // [WHEN] RefreshUserPlanAssignments is invoked
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddSecurity();
        AzureADPlan.RefreshUserPlanAssignments(User."User Security ID");

        // [THEN] User is SUPER
        Assert.IsTrue(IsUserInPermissionSet(User."User Security ID", 'SUPER'), '');

        // Rollback SaaS test
        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetAzureUserPlanDisabledRoleCenterId()
    var
        User: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        Plan: Query Plan;
        RoleCenterID: Integer;
    begin
        // [SCENARIO] When singning in, if the plan is disabled, no role center is returned from Azure AD management
        Initialize();
        AzureADPlan.SetTestInProgress(true);

        LibraryLowerPermissions.SetOutsideO365Scope();

        Plan.Open();
        while Plan.Read() do begin
            // [GIVEN] A user with a plan exists, plan status = disabled
            CreateUserWithSubscriptionPlan(User, Plan.Plan_ID, Plan.Plan_Name, 'Disabled');
            // [WHEN] GetAzureUserPlanRoleCenterId invoked (at first userlogin)
            // [THEN] Rolecenter ID 0 is returned
            LibraryLowerPermissions.SetO365Basic();

            AzureADPlan.TryGetAzureUserPlanRoleCenterId(RoleCenterID, User."User Security ID");
            Assert.AreEqual(0, RoleCenterID, 'Invalid Role Center Id');
            LibraryLowerPermissions.SetOutsideO365Scope();
        end;

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetAzureUserPlanEnabledRoleCenterId()
    var
        User: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        Plan: Query Plan;
        RoleCenterID: Integer;
    begin
        // [SCENARIO] When singning in you get the role center matching your plan, if the plan is enabled
        Initialize();
        AzureADPlan.SetTestInProgress(true);

        Plan.Open();
        while Plan.Read() do begin
            // [GIVEN] A user with a plan exists, plan status = enabled
            LibraryLowerPermissions.SetOutsideO365Scope();
            CreateUserWithSubscriptionPlan(User, Plan.Plan_ID, Plan.Plan_Name, 'Enabled');
            // [WHEN] GetAzureUserPlanRoleCenterId invoked (at first userlogin)
            // [THEN] Rolecenter for the plan is returned, only if the plan is enabled
            LibraryLowerPermissions.SetO365Basic();

            AzureADPlan.TryGetAzureUserPlanRoleCenterId(RoleCenterID, User."User Security ID");
            Assert.AreEqual(9022, RoleCenterID, 'Invalid Role Center Id');
        end;

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestGetAzureUserPlanNoRoleCenter()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
        RoleCenterID: Integer;
    begin
        // [SCENARIO] No users yet in the system, when signing in, no role center is returned from Azure AD management
        Initialize();
        AzureADPlan.SetTestInProgress(true);

        // [GIVEN] No users in the system
        // [WHEN] GetAzureUserPlanRoleCenterId invoked (at first userlogin)
        // [THEN] No role center return from Azure AD management
        LibraryLowerPermissions.SetO365Basic();
        ;

        AzureADPlan.TryGetAzureUserPlanRoleCenterId(RoleCenterID, CreateGuid());
        Assert.AreEqual(0, RoleCenterID, 'User does not exist');

        // Rollback SaaS testability parameters
        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCodeunitRunUserNotFoundInAzureADGetRoleCenterID()
    var
        User: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        RoleCenterID: Integer;
    begin
        // [SCENARIO] Codeunit AzureADPlan.TryGetAzureUserPlanRoleCenterId exits immediatelly if the user is not found in azure
        Initialize();
        AzureADPlan.SetTestInProgress(true);

        // [GIVEN] Running in SaaS
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] A user that does not exist in azure AD
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();
        LibraryPermissions.CreateAzureActiveDirectoryUser(User, '');

        // [WHEN] running Azure AD User Management on the user
        LibraryLowerPermissions.SetBanking();
        AzureADPlan.TryGetAzureUserPlanRoleCenterId(RoleCenterID, User."User Security ID");

        // [THEN] no error is thrown, the codeunit silently exists

        // Cleanup
        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestRefreshUserPlanAssignments()
    var
        User: Record User;
        UserGroupPlan: Record "User Group Plan";
        AzureADPlan: Codeunit "Azure AD Plan";
    begin
        // [SCENARIO] User should get the User Grops of the plan
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] A user with a plan that contains user groups
        CreateUserWithPlanAndUserGroups(User, UserGroupPlan, 'Test User');

        // [WHEN] RefreshUserPlanAssignments is invoked
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddSecurity();
        AzureADPlan.RefreshUserPlanAssignments(User."User Security ID");

        // Rollback SaaS test
        TearDown();

        // [THEN] User gets the User Groups of the plan
        ValidateUserGetsTheUserGroupsOfThePlan(User, UserGroupPlan);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestRefreshUserPlanAssignmentsInternalAdmin()
    var
        User: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
    begin
        // [SCENARIO] The User shoudl be able to invoke Refresh user on the internal admin without getting an error
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();

        // [GIVEN] A admin user with no plan
        LibraryPermissions.CreateAzureActiveDirectoryUser(User, '');

        // [WHEN] RefreshUserPlanAssignments is invoked
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddSecurity();
        AzureADPlan.RefreshUserPlanAssignments(User."User Security ID");

        // [THEN] No error is thrown

        // Rollback SaaS test
        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestRefreshUserPlanAssignmentsNoUser()
    var
        AzureADPlan: Codeunit "Azure AD Plan";
    begin
        // [SCENARIO] Calling Refresh User Plan Assignments for non-existing user doesn't throw err
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetO365BusFull();
        // [GIVEN] Non-existing user security ID
        // [WHEN] RefreshUserPlanAssignments is called with non-existing user security ID
        AzureADPlan.RefreshUserPlanAssignments(CreateGuid());
        // [THEN] No error is thrown

        // Rollback SaaS test
        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestRemovePlanFromUserAtRefresh()
    var
        User: Record User;
        UserGroupPlan: Record "User Group Plan";
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADPlanTestLibrary: Codeunit "Azure AD Plan Test Library";
        PlanID: Guid;
        PlanName: Text[50];
    begin
        // [SCENARIO] When user plans are updated in the Azure Graph, old plans are removed from the user
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] A user with a plan that contains user groups
        CreateUserWithPlanAndUserGroups(User, UserGroupPlan, 'Test User');

        // [GIVEN] Only in NAV, the user has an additional plan assigned
        PlanName := 'TestPlan';
        PlanID := AzureADPlanTestLibrary.CreatePlan(PlanName);
        LibraryPermissions.AddUserToPlan(User."User Security ID", PlanID);
        Assert.IsTrue(
            AzureADPlan.IsPlanAssignedToUser(PlanID, User."User Security ID"), 'Test prerequisite failed.');

        // [WHEN] RefreshUserPlanAssignments invoked
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddSecurity();
        AzureADPlan.RefreshUserPlanAssignments(User."User Security ID");

        // Rollback SaaS test
        TearDown();

        // [THEN] The additional plan is removed from the user
        Assert.IsFalse(
            AzureADPlan.IsPlanAssignedToUser(PlanID, User."User Security ID"),
            StrSubstNo('Plan %1 should not be assigned to the user.', PlanName));
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestRemoveUserGroupsFromUserAtRefresh()
    var
        User: Record User;
        UserGroupPlan: Record "User Group Plan";
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADPlanTestLibrary: Codeunit "Azure AD Plan Test Library";
        PlanID: Guid;
    begin
        // [SCENARIO] When users are updated from the Azure Graph,
        // [SCENARIO] Only the user groups allowed by the plan remain assigned to the user
        // [SCENARIO] i.e. the user groups from old plans are removed from the user
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] A user with a plan that contains user groups
        CreateUserWithPlanAndUserGroups(User, UserGroupPlan, 'Test User');

        // [GIVEN] Only in NAV, the user has an additional plan assigned
        PlanID := AzureADPlanTestLibrary.CreatePlan('TestPlan');
        LibraryPermissions.AddUserToPlan(User."User Security ID", PlanID);
        Assert.IsTrue(
            AzureADPlan.IsPlanAssignedToUser(PlanID, User."User Security ID"), 'Test prerequisite failed.');

        // [GIVEN] The user is also assigned some user groups
        AddUserToUserGroupNAVOnly(User, InformationWorkerUserGroupTxt, PlanID);

        // [WHEN] RefreshUserPlanAssignments invoked
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddSecurity();
        AzureADPlan.RefreshUserPlanAssignments(User."User Security ID");

        // Rollback SaaS test
        TearDown();

        // [THEN] The user should be removed from InformationWorker user group. Only the user groups allowed by the plan remain
        Assert.IsFalse(
          IsUserInUserGroup(User."User Security ID", InformationWorkerUserGroupTxt),
          StrSubstNo('User Group %1 should not be assigned to the user.', InformationWorkerUserGroupTxt));
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestRemoveExtraUserGroupsFromUserAtRefresh()
    var
        User: Record User;
        UserGroupPlan: Record "User Group Plan";
        AzureADPlan: Codeunit "Azure AD Plan";
    begin
        // [SCENARIO] When users are updated from the Azure Graph,
        // [SCENARIO] The manually assigned user groups remain assigned to the user
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] A user with a plan that contains user groups
        CreateUserWithPlanAndUserGroups(User, UserGroupPlan, 'Test User');

        // [GIVEN] The user is also assigned some user groups, but those user groups are not part of any plan
        AddUserToUserGroupNAVOnly(User, InformationWorkerUserGroupTxt, CreateGuid());

        // [WHEN] RefreshUserPlanAssignments invoked
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddSecurity();
        AzureADPlan.RefreshUserPlanAssignments(User."User Security ID");

        // Rollback SaaS test
        TearDown();

        // [THEN] The user should not be removed from InformationWorker user group
        Assert.IsTrue(
          IsUserInUserGroup(User."User Security ID", InformationWorkerUserGroupTxt),
          StrSubstNo('User Group %1 should be assigned to the user.', InformationWorkerUserGroupTxt));
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestUpdateUserPlansAllUsers()
    var
        UserCassie: Record User;
        UserAdmin: Record User;
        UserDebra: Record User;
        UserGroupPlan: Record "User Group Plan";
        AzureADPlan: Codeunit "Azure AD Plan";
        Plan: Query Plan;
    begin
        // [SCENARIO] Multiple users get the User Grops of the plan when created
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] SUPER User
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [GIVEN] Two users with a plan that contains user groups
        UserGroupPlan.FindFirst();
        Plan.SetRange(Plan_ID, UserGroupPlan."Plan ID");
        Plan.Open();
        Plan.Read();

        UserCassie."User Name" := 'Test User 1 - Cassie';
        CreateUserWithSubscriptionPlan(UserCassie, Plan.Plan_ID, Plan.Plan_Name, 'Enabled');
        UserDebra."User Name" := 'Test User 2 - Debra';
        CreateUserWithSubscriptionPlan(UserDebra, Plan.Plan_ID, Plan.Plan_Name, 'Enabled');
        LibraryPermissions.CreateAzureActiveDirectoryUser(UserAdmin, '');
        UserDebra."User Name" := 'Test User 3 - Admin';

        // [WHEN] UpdateUserPlans for all users is invoked
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddSecurity();
        AzureADPlan.UpdateUserPlans();

        // Rollback SaaS test
        TearDown();

        // [THEN] Both users get the User Groups of the plan
        ValidateUserGetsTheUserGroupsOfThePlan(UserCassie, UserGroupPlan);
        ValidateUserGetsTheUserGroupsOfThePlan(UserDebra, UserGroupPlan);
    end;

    [Test]
    [HandlerFunctions('HandleAndVerifyChangedPlanMessageOK')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCheckMixedPlansWhenUserHasAccessToEditUserPlanAndGroupsBasicAndEssentials()
    var
        BasicUser: Record User;
        EssentialUser: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        // [SCENARIO] CheckMixedPlans show a message when user has access to the user management tables
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] SUPER User
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [GIVEN] A user with basic and a user with essential plans are added
        LibraryPermissions.CreateAzureActiveDirectoryUser(BasicUser, '');
        LibraryPermissions.CreateAzureActiveDirectoryUser(EssentialUser, '');
        LibraryPermissions.AddUserToPlan(BasicUser."User Security ID", PlanIds.GetBasicPlanId());
        LibraryPermissions.AddUserToPlan(EssentialUser."User Security ID", PlanIds.GetEssentialPlanId());

        // [WHEN] CheckMixedPlans invoked
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddSecurity();
        FirstUserAuthenticationEmail := BasicUser."Authentication Email";
        SecondUserAuthenticationEmail := EssentialUser."Authentication Email";
        AzureADPlan.CheckMixedPlans();

        // Rollback SaaS test
        TearDown();

        // [THEN] Verification is done in the message that is shown
    end;

    [Test]
    [HandlerFunctions('HandleAndVerifyChangedPlanMessageOK')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCheckMixedPlansWhenUserHasAccessToEditUserPlanAndGroupsBasicAndPremium()
    var
        BasicUser: Record User;
        PremiumUser: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        // [SCENARIO] CheckMixedPlans show a message when user has access to the user management tables
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] SUPER User
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [GIVEN] A user with basic and a user with premuim plans are added
        LibraryPermissions.CreateAzureActiveDirectoryUser(BasicUser, '');
        LibraryPermissions.CreateAzureActiveDirectoryUser(PremiumUser, '');
        LibraryPermissions.AddUserToPlan(BasicUser."User Security ID", PlanIds.GetBasicPlanId());
        LibraryPermissions.AddUserToPlan(PremiumUser."User Security ID", PlanIds.GetPremiumPlanId());

        // [WHEN] CheckMixedPlans invoked
        LibraryLowerPermissions.SetO365Basic();
        ;
        LibraryLowerPermissions.AddSecurity();
        FirstUserAuthenticationEmail := BasicUser."Authentication Email";
        SecondUserAuthenticationEmail := PremiumUser."Authentication Email";
        AzureADPlan.CheckMixedPlans();

        // Rollback SaaS test
        TearDown();

        // [THEN] Verification is done in the message that is shown
    end;

    [Test]
    [HandlerFunctions('HandleAndVerifyChangedPlanMessageOK')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCheckMixedPlansWhenUserHasAccessToEditUserPlanAndGroupsEssentialAndPremium()
    var
        PremiumUser: Record User;
        EssentialUser: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        // [SCENARIO] CheckMixedPlans show a message when user has access to the user management tables
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] SUPER User
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [GIVEN] A user with premium and a user with essential plans are added
        LibraryPermissions.CreateAzureActiveDirectoryUser(PremiumUser, '');
        LibraryPermissions.CreateAzureActiveDirectoryUser(EssentialUser, '');
        LibraryPermissions.AddUserToPlan(PremiumUser."User Security ID", PlanIds.GetPremiumPlanId());
        LibraryPermissions.AddUserToPlan(EssentialUser."User Security ID", PlanIds.GetEssentialPlanId());

        // [WHEN] CheckMixedPlans invoked
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddSecurity();
        FirstUserAuthenticationEmail := EssentialUser."Authentication Email";
        SecondUserAuthenticationEmail := PremiumUser."Authentication Email";
        AzureADPlan.CheckMixedPlans();

        // Rollback SaaS test
        TearDown();

        // [THEN] Verification is done in the message that is shown
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCheckMixedPlansWhenUserHasNoAccessToEditUserPlanAndGroupsEssentialAndPremium()
    var
        PremiumUser: Record User;
        EssentialUser: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        // [SCENARIO] CheckMixedPlans throws an error when user has no access to the user management tables
        if not LibraryLowerPermissions.CanLowerPermission() then
            exit;
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] SUPER User
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [GIVEN] A user with basic and a user with essential plan are added
        LibraryPermissions.CreateAzureActiveDirectoryUser(PremiumUser, '');
        LibraryPermissions.CreateAzureActiveDirectoryUser(EssentialUser, '');
        LibraryPermissions.AddUserToPlan(PremiumUser."User Security ID", PlanIds.GetPremiumPlanId());
        LibraryPermissions.AddUserToPlan(EssentialUser."User Security ID", PlanIds.GetEssentialPlanId());

        // [WHEN] CheckMixedPlans invoked
        LibraryLowerPermissions.SetO365Basic();
        ;
        asserterror AzureADPlan.CheckMixedPlans();

        // Rollback SaaS test
        TearDown();

        // [THEN] Error is thrown
        Assert.ExpectedError(StrSubstNo(MixedPlansNonAdminErr, EssentialUser."Authentication Email", PremiumUser."Authentication Email"));
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCheckMixedPlansWhenUserHasNoAccessToEditUserPlanAndGroupsEssentialISVAndPremiumISV()
    var
        PremiumUser: Record User;
        EssentialUser: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        // [SCENARIO] CheckMixedPlans throws an error when user has no access to the user management tables
        if not LibraryLowerPermissions.CanLowerPermission() then
            exit;
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] SUPER User
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [GIVEN] A user with basic and a user with essential plan are added
        LibraryPermissions.CreateAzureActiveDirectoryUser(PremiumUser, '');
        LibraryPermissions.CreateAzureActiveDirectoryUser(EssentialUser, '');
        LibraryPermissions.AddUserToPlan(PremiumUser."User Security ID", PlanIds.GetPremiumISVPlanId());
        LibraryPermissions.AddUserToPlan(EssentialUser."User Security ID", PlanIds.GetEssentialISVPlanId());

        // [WHEN] CheckMixedPlans invoked
        LibraryLowerPermissions.SetO365Basic();
        ;
        AzureADPlan.CheckMixedPlans();

        // Rollback SaaS test
        TearDown();

        // [THEN] Verification is that no error or message is thrown
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCheckMixedPlansWhenUserHasNoAccessToEditUserPlanAndGroupsPremiumAndPremiumISV()
    var
        PremiumUser: Record User;
        PremiumISVUser: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        // [SCENARIO] CheckMixedPlans throws an error when user has no access to the user management tables
        if not LibraryLowerPermissions.CanLowerPermission() then
            exit;
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] SUPER User
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [GIVEN] A user with basic and a user with essential plan are added
        LibraryPermissions.CreateAzureActiveDirectoryUser(PremiumUser, '');
        LibraryPermissions.CreateAzureActiveDirectoryUser(PremiumISVUser, '');
        LibraryPermissions.AddUserToPlan(PremiumUser."User Security ID", PlanIds.GetPremiumPlanId());
        LibraryPermissions.AddUserToPlan(PremiumISVUser."User Security ID", PlanIds.GetPremiumISVPlanId());

        // [WHEN] CheckMixedPlans invoked
        LibraryLowerPermissions.SetO365Basic();
        ;
        AzureADPlan.CheckMixedPlans();

        // Rollback SaaS test
        TearDown();

        // [THEN] Verification is that no error or message is thrown
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCheckMixedPlansWhenUserHasNoAccessToEditUserPlanAndGroupsBasicAndPremium()
    var
        PremiumUser: Record User;
        BasicUser: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        // [SCENARIO] CheckMixedPlans throws an error when user has no access to the user management tables
        if not LibraryLowerPermissions.CanLowerPermission() then
            exit;
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] SUPER User
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [GIVEN] A user with basic and a user with essential plan are added
        LibraryPermissions.CreateAzureActiveDirectoryUser(PremiumUser, '');
        LibraryPermissions.CreateAzureActiveDirectoryUser(BasicUser, '');
        LibraryPermissions.AddUserToPlan(PremiumUser."User Security ID", PlanIds.GetPremiumPlanId());
        LibraryPermissions.AddUserToPlan(BasicUser."User Security ID", PlanIds.GetBasicPlanId());

        // [WHEN] CheckMixedPlans invoked
        LibraryLowerPermissions.SetO365Basic();
        ;
        asserterror AzureADPlan.CheckMixedPlans();

        // Rollback SaaS test
        TearDown();

        // [THEN] Error is thrown
        Assert.ExpectedError(StrSubstNo(MixedPlansNonAdminErr, BasicUser."Authentication Email", PremiumUser."Authentication Email"));
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCheckMixedPlans_EssentialAndIncomingPremium()
    var
        PremiumUser: Record User;
        EssentialUser: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
        AzureADGraphUser: Codeunit "Azure AD Graph User";
        IncomingPlansPerUser: Dictionary of [Text, List of [Text]];
        PlansForUser: List of [Text];
    begin
        // [SCENARIO] CheckMixedPlans
        if not LibraryLowerPermissions.CanLowerPermission() then
            exit;
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] SUPER User
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [GIVEN] A user with essential plan is added
        LibraryPermissions.CreateAzureActiveDirectoryUser(EssentialUser, '');
        LibraryPermissions.AddUserToPlan(EssentialUser."User Security ID", PlanIds.GetEssentialPlanId());

        // [GIVEN] Another user got a premium license assigned in the Office portal
        LibraryPermissions.CreateAzureActiveDirectoryUser(PremiumUser, '');
        PlansForUser.Add('Dynamics 365 Business Central Premium');
        IncomingPlansPerUser.Add(AzureADGraphUser.GetUserAuthenticationObjectId(PremiumUser."User Security ID"), PlansForUser);

        // [WHEN] CheckMixedPlans invoked
        LibraryLowerPermissions.SetO365Basic();
        ;
        asserterror AzureADPlan.CheckMixedPlans(IncomingPlansPerUser, true);

        // Rollback SaaS test
        TearDown();

        // [THEN] Error is thrown
        Assert.ExpectedError(StrSubstNo(MixedPlansNonAdminErr, EssentialUser."Authentication Email", PremiumUser."Authentication Email"));
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCheckMixedPlans_EssentialAndEssentialUpgradedToPremium()
    var
        EssentialUser1: Record User;
        EssentialUser2: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
        AzureADGraphUser: Codeunit "Azure AD Graph User";
        IncomingPlansPerUser: Dictionary of [Text, List of [Text]];
        PlansForUser: List of [Text];
    begin
        // [SCENARIO] CheckMixedPlans
        if not LibraryLowerPermissions.CanLowerPermission() then
            exit;
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] SUPER User
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [GIVEN] Two users with essential plan are added
        LibraryPermissions.CreateAzureActiveDirectoryUser(EssentialUser1, '');
        LibraryPermissions.CreateAzureActiveDirectoryUser(EssentialUser2, '');
        LibraryPermissions.AddUserToPlan(EssentialUser1."User Security ID", PlanIds.GetEssentialPlanId());
        LibraryPermissions.AddUserToPlan(EssentialUser2."User Security ID", PlanIds.GetEssentialPlanId());

        // [GIVEN] One of the users got their licence changed to premium in the office portal
        PlansForUser.Add('Dynamics 365 Business Central Premium');
        IncomingPlansPerUser.Add(AzureADGraphUser.GetUserAuthenticationObjectId(EssentialUser2."User Security ID"), PlansForUser);

        // [WHEN] CheckMixedPlans invoked
        LibraryLowerPermissions.SetO365Basic();
        ;
        asserterror AzureADPlan.CheckMixedPlans(IncomingPlansPerUser, true);

        // Rollback SaaS test
        TearDown();

        // [THEN] Error is thrown
        Assert.ExpectedError(StrSubstNo(MixedPlansNonAdminErr, EssentialUser1."Authentication Email", EssentialUser2."Authentication Email"));
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCheckMixedPlans_NewEssentialAndPremiumUsers()
    var
        EssentialUser: Record User;
        PlanIds: Codeunit "Plan Ids";
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADGraphUser: Codeunit "Azure AD Graph User";
        IncomingPlansPerUser: Dictionary of [Text, List of [Text]];
        PlansForPremiumUser: List of [Text];
        PlansForEssentialUser: List of [Text];
        EssentialUserAADObjectID: Guid;
        PremiumUserAADObjectID: Guid;
    begin
        // [SCENARIO] CheckMixedPlans
        if not LibraryLowerPermissions.CanLowerPermission() then
            exit;
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] SUPER User
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        LibraryPermissions.CreateAzureActiveDirectoryUser(EssentialUser, '');
        LibraryPermissions.AddUserToPlan(EssentialUser."User Security ID", PlanIds.GetEssentialPlanId());

        // [GIVEN] One of the users got their licence changed to premium in the office portal
        EssentialUserAADObjectID := AzureADGraphUser.GetUserAuthenticationObjectId(EssentialUser."User Security ID");
        PremiumUserAADObjectID := CreateGuid();
        PlansForPremiumUser.Add('Dynamics 365 Business Central Premium');
        PlansForEssentialUser.Add('Dynamics 365 Business Central Essential');
        IncomingPlansPerUser.Add(EssentialUserAADObjectID, PlansForPremiumUser);
        IncomingPlansPerUser.Add(PremiumUserAADObjectID, PlansForEssentialUser);

        LibraryLowerPermissions.SetO365Basic();
        ;
        LibraryAzureADUserMgmt.AddGraphUserWithoutPlan(PremiumUserAADObjectID, 'Incoming', 'User', 'user@test.com');

        // [WHEN] CheckMixedPlans invoked
        asserterror AzureADPlan.CheckMixedPlans(IncomingPlansPerUser, true);

        // Rollback SaaS test
        TearDown();

        // [THEN] Error is thrown
        Assert.ExpectedError(StrSubstNo(MixedPlansNonAdminErr, 'user@test.com', EssentialUser."Authentication Email"));
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCheckMixedPlansWhenAllUsersArePremium()
    var
        PremiumUser1: Record User;
        PremiumUser2: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        // [SCENARIO] CheckMixedPlans does not show a message nor error if all users are on same SKU
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] SUPER User
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [GIVEN] Two users with premium plan are added
        LibraryPermissions.CreateAzureActiveDirectoryUser(PremiumUser1, '');
        LibraryPermissions.CreateAzureActiveDirectoryUser(PremiumUser2, '');
        LibraryPermissions.AddUserToPlan(PremiumUser1."User Security ID", PlanIds.GetPremiumPlanId());
        LibraryPermissions.AddUserToPlan(PremiumUser2."User Security ID", PlanIds.GetPremiumPlanId());

        // [WHEN] CheckMixedPlans invoked
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddSecurity();
        AzureADPlan.CheckMixedPlans();

        // Rollback SaaS test
        TearDown();

        // [THEN] No error happens
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCheckMixedPlansWhenAllUsersArePremiumISV()
    var
        PremiumUser1: Record User;
        PremiumUser2: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        // [SCENARIO] CheckMixedPlans does not show a message nor error if all users are on same SKU
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] SUPER User
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [GIVEN] Two users with premium plan are added
        LibraryPermissions.CreateAzureActiveDirectoryUser(PremiumUser1, '');
        LibraryPermissions.CreateAzureActiveDirectoryUser(PremiumUser2, '');
        LibraryPermissions.AddUserToPlan(PremiumUser1."User Security ID", PlanIds.GetPremiumISVPlanId());
        LibraryPermissions.AddUserToPlan(PremiumUser2."User Security ID", PlanIds.GetPremiumISVPlanId());

        // [WHEN] CheckMixedPlans invoked
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddSecurity();
        AzureADPlan.CheckMixedPlans();

        // Rollback SaaS test
        TearDown();

        // [THEN] No error happens
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCheckMixedPlansWhenOneUserIsOnPremiumAndOthersAreOnNonBasicNorEssential()
    var
        PremiumUser: Record User;
        User: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
        Plan: Query Plan;
    begin
        // [SCENARIO] CheckMixedPlans does not show a message nor error if all users are on same SKU
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] SUPER User
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [GIVEN] Two users with premium plan are added
        Plan.SetFilter(Plan_ID, '<>%1|%2|%3', PlanIds.GetBasicPlanId(), PlanIds.GetEssentialPlanId(), PlanIds.GetPremiumPlanId());
        Plan.Open();
        Plan.Read();

        LibraryPermissions.CreateAzureActiveDirectoryUser(PremiumUser, '');
        LibraryPermissions.CreateAzureActiveDirectoryUser(User, '');
        LibraryPermissions.AddUserToPlan(PremiumUser."User Security ID", PlanIds.GetPremiumPlanId());
        LibraryPermissions.AddUserToPlan(User."User Security ID", Plan.Plan_ID);

        // [WHEN] CheckMixedPlans invoked
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddSecurity();
        AzureADPlan.CheckMixedPlans();

        // Rollback SaaS test
        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestCheckMixedPlansWhenNoUsersAreOnOnPremiumNorBasicNorEssential()
    var
        User1: Record User;
        User2: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
        Plan: Query Plan;
    begin
        // [SCENARIO] CheckMixedPlans does not show a message nor error if all users are on same SKU
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] SUPER User
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [GIVEN] Two users with premium plan are added
        Plan.SetFilter(Plan_ID, '<>%1|%2|%3', PlanIds.GetBasicPlanId(), PlanIds.GetEssentialPlanId(), PlanIds.GetPremiumPlanId());
        Plan.Open();
        Plan.Read();

        LibraryPermissions.CreateAzureActiveDirectoryUser(User1, '');
        LibraryPermissions.CreateAzureActiveDirectoryUser(User2, '');
        LibraryPermissions.AddUserToPlan(User1."User Security ID", Plan.Plan_ID);

        Plan.Read();
        LibraryPermissions.AddUserToPlan(User2."User Security ID", Plan.Plan_ID);

        // [WHEN] CheckMixedPlans invoked
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddSecurity();
        AzureADPlan.CheckMixedPlans();

        // Rollback SaaS test
        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestMixedPlansExistWhenEssentialAndPremiumAreMixed()
    var
        PremiumUser: Record User;
        EssentialUser: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        // [SCENARIO] Test MixedPlansExist user's plans are mixed
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] SUPER User
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [GIVEN] A user with premium and a user with essential plan are added
        LibraryPermissions.CreateAzureActiveDirectoryUser(PremiumUser, '');
        LibraryPermissions.CreateAzureActiveDirectoryUser(EssentialUser, '');
        LibraryPermissions.AddUserToPlan(PremiumUser."User Security ID", PlanIds.GetPremiumPlanId());
        LibraryPermissions.AddUserToPlan(EssentialUser."User Security ID", PlanIds.GetEssentialPlanId());

        // [WHEN] MixedPlansExist invoked
        LibraryLowerPermissions.SetO365Basic();
        ;
        Assert.IsTrue(AzureADPlan.MixedPLansExist(), 'Mixed plans are not recognized');

        // Rollback SaaS test
        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestMixedPlansExistWhenPlansAreNotMixed()
    var
        PremiumUser1: Record User;
        PremiumUser2: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        // [SCENARIO] Test MixedPlansExist user's plans are not mixed
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] SUPER User
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [GIVEN] All users are on premium
        LibraryPermissions.CreateAzureActiveDirectoryUser(PremiumUser1, '');
        LibraryPermissions.CreateAzureActiveDirectoryUser(PremiumUser2, '');
        LibraryPermissions.AddUserToPlan(PremiumUser1."User Security ID", PlanIds.GetPremiumPlanId());
        LibraryPermissions.AddUserToPlan(PremiumUser2."User Security ID", PlanIds.GetPremiumPlanId());

        // [WHEN] CheckMixedPlans invoked
        LibraryLowerPermissions.SetO365Basic();
        ;
        Assert.IsFalse(AzureADPlan.MixedPLansExist(), 'Mixed plans are found wrongly');

        // Rollback SaaS test
        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestDelegatedAdminIsSuperIfSuperExists()
    var
        User: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        // [SCENARIO] User should get the User Grops of the plan
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] A super user
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [WHEN] A user with a delegated admin plan is created
        CreateUserWithPlan(User, PlanIds.GetDelegatedAdminPlanId());

        // [WHEN] RefreshUserPlanAssignments is invoked
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddSecurity();
        AzureADPlan.RefreshUserPlanAssignments(User."User Security ID");

        Assert.IsTrue(IsUserInPermissionSet(User."User Security ID", 'SUPER'), '');

        // Rollback SaaS test
        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestInternalAdminIsSuperIfSuperExists()
    var
        User: Record User;
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        // [SCENARIO] User should get the User Grops of the plan
        Initialize();
        AzureADPlan.SetTestInProgress(true);
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryLowerPermissions.AddSecurity();

        // [GIVEN] A super user
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");

        // [WHEN] A user with an internal admin plan is created
        CreateUserWithPlan(User, PlanIds.GetInternalAdminPlanId());

        // [WHEN] RefreshUserPlanAssignments is invoked
        LibraryLowerPermissions.SetO365BusFull();
        LibraryLowerPermissions.AddSecurity();
        AzureADPlan.RefreshUserPlanAssignments(User."User Security ID");

        Assert.IsTrue(IsUserInPermissionSet(User."User Security ID", 'SUPER'), '');

        // Rollback SaaS test
        TearDown();
    end;

    local procedure Initialize()
    begin
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService := true;

        Clear(LibraryAzureADUserMgmt);
        LibraryAzureADUserMgmt.SetupMockGraphQuery();
        BindSubscription(LibraryAzureADUserMgmt);
        SetupAzureADMockPlans();

        FirstUserAuthenticationEmail := '';
        SecondUserAuthenticationEmail := '';
    end;

    local procedure TearDown()
    begin
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService := false;
        UnbindSubscription(LibraryAzureADUserMgmt);
    end;

    local procedure CreateUserWithSubscriptionPlan(var User: Record User; PlanID: Guid; PlanName: Text; PlanStatus: Text)
    begin
        LibraryPermissions.CreateAzureActiveDirectoryUser(User, '');
        LibraryAzureADUserMgmt.AddGraphUser(GetUserAuthenticationId(User), User."User Name", '', '', PlanID, PlanName, PlanStatus);
    end;

    local procedure GetUserAuthenticationId(User: Record User): Guid
    var
        UserProperty: Record "User Property";
    begin
        UserProperty.Get(User."User Security ID");
        exit(UserProperty."Authentication Object ID");
    end;

    local procedure SetupAzureADMockPlans()
    var
        Plan: Query Plan;
    begin
        Plan.Open();
        while Plan.Read() do
            LibraryAzureADUserMgmt.AddSubscribedSkuWithServicePlan(CreateGuid(), Plan.Plan_ID, Plan.Plan_Name);
    end;

    local procedure ValidateUserGetsTheUserGroupsOfThePlan(User: Record User; UserGroupPlan: Record "User Group Plan")
    var
        UserGroupMember: Record "User Group Member";
    begin
        UserGroupMember.SetRange("User Security ID", User."User Security ID");
        UserGroupMember.FindSet();
        UserGroupPlan.SetRange("Plan ID", UserGroupPlan."Plan ID");
        UserGroupPlan.FindSet();

        Assert.RecordCount(UserGroupMember, UserGroupPlan.Count);
        repeat
            Assert.AreEqual(UserGroupPlan."User Group Code", UserGroupMember."User Group Code", 'Only the enabled plan should be returned');
            UserGroupMember.Next();
        until UserGroupPlan.Next() = 0;
    end;

    local procedure CreateUserWithPlanAndUserGroups(var User: Record User; var UserGroupPlan: Record "User Group Plan"; UserName: Text[50])
    begin
        LibraryPermissions.CreateAzureActiveDirectoryUser(User, UserName);
        UserGroupPlan.FindFirst();
        LibraryAzureADUserMgmt.AddGraphUser(GetUserAuthenticationId(User), User."User Name", '', '', UserGroupPlan."Plan ID", '', 'Enabled');
    end;

    local procedure CreateUserWithPlan(var User: Record User; PlanID: Guid)
    var
        UsersCreateSuperUser: Codeunit "Users - Create Super User";
        Plan: Query Plan;
    begin
        CODEUNIT.Run(CODEUNIT::"Users - Create Super User");
        LibraryPermissions.CreateAzureActiveDirectoryUser(User, 'Test User');
        UsersCreateSuperUser.AddUserAsSuper(User);

        Plan.SetRange(Plan_ID, PlanID);
        Plan.Open();
        Plan.Read();

        LibraryAzureADUserMgmt.AddGraphUser(GetUserAuthenticationId(User), User."User Name", '', '', Plan.Plan_ID, Plan.Plan_Name, 'Enabled');
    end;

    local procedure IsUserInUserGroup(UserID: Guid; UserGroupCode: Text): Boolean
    var
        UserGroupMember: Record "User Group Member";
    begin
        UserGroupMember.SetRange("User Group Code", UserGroupCode);
        UserGroupMember.SetRange("User Security ID", UserID);
        exit(not UserGroupMember.IsEmpty());
    end;

    local procedure IsUserInPermissionSet(UserID: Guid; PermissionSetCode: Text): Boolean
    var
        AccessControl: Record "Access Control";
    begin
        AccessControl.SetRange("Role ID", PermissionSetCode);
        AccessControl.SetRange("User Security ID", UserID);
        exit(not AccessControl.IsEmpty());
    end;

    local procedure AddUserToUserGroupNAVOnly(User: Record User; UserGroupCode: Code[20]; PlanId: Guid)
    begin
        LibraryPermissions.CreateUserGroupInPlan(UserGroupCode, PlanId);
        LibraryPermissions.AddUserToUserGroupByCode(User."User Security ID", UserGroupCode);
        Assert.IsTrue(
          IsUserInUserGroup(User."User Security ID", UserGroupCode), 'Test prerequisite failed.');
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure HandleAndVerifyChangedPlanMessageOK(Message: Text[1024])
    begin
        Assert.ExpectedMessage(Message, StrSubstNo(MixedPlansMsg, FirstUserAuthenticationEmail, SecondUserAuthenticationEmail));
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(MessageText: Text)
    begin
    end;
}

