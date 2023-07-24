// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132928 "Azure AD User Sync Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        AzureADGraphTestLibrary: Codeunit "Azure AD Graph Test Library";
        AzureADUserMgtTestLibrary: Codeunit "Azure AD User Mgt Test Library";
        MockGraphQueryTestLibrary: Codeunit "MockGraphQuery Test Library";
        UnexpectedNumberOfUsersErr: Label 'Unexpected number of users after the update.';
        UserWasNotCreatedErr: Label 'The user was not created.';
        UnexpectedContactEmailErr: Label 'Unexpected contact email.';
        UnexpectedFullNameErr: Label 'Unexpected full name.';
        IncorrectPlanErr: Label 'The user does not have the correct plan assigned.';
        UnexpectedNoOfChangesErr: Label 'Unexpected number of successful changes were made.';
#pragma warning disable AA0240
        EssentialEmailTxt: Label 'essential@microsoft.com';
        PremiumEmailTxt: Label 'premium@microsoft.com';
        TeamMemberEmailTxt: Label 'team.member@microsoft.com';
        TeamsUserEmailTxt: Label 'teams.user@microsoft.com';
        InternalAdminEmailTxt: Label 'internal.admin@microsoft.com';
        DeviceEmailTxt: Label 'device@microsoft.com';
        NonBcEmailTxt: Label 'nonbc@microsoft.com';
#pragma warning restore AA0240
        CommonLastNameTxt: Label 'User';
        MixedPlansNonAdminErr: Label 'Before you can update user information, go to your Microsoft 365 admin center and make sure that all users are assigned to the same Business Central license, either Basic, Essential, or Premium. For example, we found that users %1 and %2 are assigned to different licenses, but there may be other mismatches.', Comment = '%1 = %2 = Authentication email.';

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestCreateUsersWithDifferentLicenses()
    var
        User: Record User;
        TempAzureADUserUpdateBuffer: Record "Azure AD User Update Buffer" temporary;
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADUserSyncImpl: Codeunit "Azure AD User Sync Impl.";
        PlanIds: Codeunit "Plan Ids";
    begin
        Initialize();

        // [GIVEN] Users with different licenses are present in Azure AD
        CreateUsers(true);

        // [WHEN] The information from M365 is fetched and applied
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);
        AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);

        // [THEN] Three users are created: Essential, Team Member and Device
        LibraryAssert.AreEqual(3, User.Count(), UnexpectedNumberOfUsersErr);

        // Verify Essential user
        User.SetRange("Authentication Email", EssentialEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.AreEqual(EssentialEmailTxt, User."Contact Email", UnexpectedContactEmailErr);
        LibraryAssert.AreEqual('Essential User', User."Full Name", UnexpectedFullNameErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetEssentialPlanId(), User."User Security ID"), IncorrectPlanErr);

        // Verify Team Member user
        User.SetRange("Authentication Email", TeamMemberEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.AreEqual(TeamMemberEmailTxt, User."Contact Email", UnexpectedContactEmailErr);
        LibraryAssert.AreEqual('Team Member User', User."Full Name", UnexpectedFullNameErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetTeamMemberPlanId(), User."User Security ID"), IncorrectPlanErr);

        // Verify Device user
        User.SetRange("Authentication Email", DeviceEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.AreEqual(DeviceEmailTxt, User."Contact Email", UnexpectedContactEmailErr);
        LibraryAssert.AreEqual('Device User', User."Full Name", UnexpectedFullNameErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetDevicePlanId(), User."User Security ID"), IncorrectPlanErr);

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestUpdateUsersWithDifferentLicenses()
    var
        User: Record User;
        TempAzureADUserUpdateBuffer: Record "Azure AD User Update Buffer" temporary;
        AzureADUserSyncImpl: Codeunit "Azure AD User Sync Impl.";
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
    begin
        Initialize();

        // [GIVEN] Users with different licenses are present in Azure AD and have corresponding users in BC
        CreateUsers(false);

        // [WHEN] All the information in Azure AD and BC is synchronized
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);
        AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);

        // [THEN] The licenses are correctly assigned
        LibraryAssert.AreEqual(5, User.Count(), UnexpectedNumberOfUsersErr);
        // Verify Essential user
        User.SetRange("Authentication Email", EssentialEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetEssentialPlanId(), User."User Security ID"), IncorrectPlanErr);

        // Verify Team Member user
        User.SetRange("Authentication Email", TeamMemberEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetTeamMemberPlanId(), User."User Security ID"), IncorrectPlanErr);

        // Verify Device user
        User.SetRange("Authentication Email", DeviceEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetDevicePlanId(), User."User Security ID"), IncorrectPlanErr);

        // Verify Teams user
        User.SetRange("Authentication Email", TeamsUserEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetMicrosoft365PlanId(), User."User Security ID"), IncorrectPlanErr);

        // Verify Internal admin user
        User.SetRange("Authentication Email", InternalAdminEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetInternalAdminPlanId(), User."User Security ID"), IncorrectPlanErr);

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestTeamsUserIsNotRecognizedAsBcUserWhenTheSwitchIsOff()
    var
        User: Record User;
        TempAzureADUserUpdateBuffer: Record "Azure AD User Update Buffer" temporary;
        AzureADUserSyncImpl: Codeunit "Azure AD User Sync Impl.";
        AzureADPlan: Codeunit "Azure AD Plan";
    begin
        Initialize();

        // [GIVEN] Users with different licenses are present in Azure AD and have corresponding users in BC
        CreateUsers(false);

        // [GIVEN] All the information in Azure AD and BC is synchronized
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);
        AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);

        // [GIVEN] The tenant admin has turned off the M365 collaboration switch
        MockGraphQueryTestLibrary.SetM365CollaborationEnabled(false);

        // [WHEN] All the information in Azure AD and BC is synchronized
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);
        LibraryAssert.AreEqual(1, AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer), UnexpectedNoOfChangesErr);

        // [THEN] The Teams user get all the user plans removed
        User.SetRange("Authentication Email", TeamsUserEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.IsFalse(AzureADPlan.DoesUserHavePlans(User."User Security ID"), IncorrectPlanErr);

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestSyncEnvironmentDirectoryGroupWithNoMembers()
    var
        TempAzureADUserUpdateBuffer: Record "Azure AD User Update Buffer" temporary;
        AzureADUserSyncImpl: Codeunit "Azure AD User Sync Impl.";
    begin
        Initialize();

        // [GIVEN] Users with different licenses are present in Azure AD
        CreateUsers(true);

        // [GIVEN] The environemnt directory group is defined
        MockGraphQueryTestLibrary.SetEnvironmentDirectoryGroup('Group with no members');

        // [WHEN] All the information in Azure AD and BC is synchronized
        // [THEN] There are no updates applied
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);
        LibraryAssert.AreEqual(0, AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer), UnexpectedNoOfChangesErr);

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestSyncEnvironmentDirectoryGroupWithMembers()
    var
        User: Record User;
        TempAzureADUserUpdateBuffer: Record "Azure AD User Update Buffer" temporary;
        AzureADUserSyncImpl: Codeunit "Azure AD User Sync Impl.";
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
        GroupNameTxt: Label 'Group with members';
    begin
        Initialize();

        // [GIVEN] Users with different licenses are present in Azure AD, they are all members of the specified group
        CreateUsers(true, GroupNameTxt);

        // [GIVEN] The environemnt directory group is defined
        MockGraphQueryTestLibrary.SetEnvironmentDirectoryGroup(GroupNameTxt);

        // [WHEN] The information from M365 is fetched and applied
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);
        AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);

        // [THEN] Five users are created: Essential, Team Member, Teams, Internal admin and Device (only non-BC user is skipped)
        // Even though Teams users and Internal admins are normally skipped during sync, here we bring them in
        // because they were explicitly added to the environemnt group by the admin.
        LibraryAssert.AreEqual(5, User.Count(), UnexpectedNumberOfUsersErr);

        // Verify Essential user
        User.SetRange("Authentication Email", EssentialEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.AreEqual(EssentialEmailTxt, User."Contact Email", UnexpectedContactEmailErr);
        LibraryAssert.AreEqual('Essential User', User."Full Name", UnexpectedFullNameErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetEssentialPlanId(), User."User Security ID"), IncorrectPlanErr);

        // Verify Team Member user
        User.SetRange("Authentication Email", TeamMemberEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.AreEqual(TeamMemberEmailTxt, User."Contact Email", UnexpectedContactEmailErr);
        LibraryAssert.AreEqual('Team Member User', User."Full Name", UnexpectedFullNameErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetTeamMemberPlanId(), User."User Security ID"), IncorrectPlanErr);

        // Verify Device user
        User.SetRange("Authentication Email", DeviceEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.AreEqual(DeviceEmailTxt, User."Contact Email", UnexpectedContactEmailErr);
        LibraryAssert.AreEqual('Device User', User."Full Name", UnexpectedFullNameErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetDevicePlanId(), User."User Security ID"), IncorrectPlanErr);

        // Verify Teams user
        User.SetRange("Authentication Email", TeamsUserEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.AreEqual(TeamsUserEmailTxt, User."Contact Email", UnexpectedContactEmailErr);
        LibraryAssert.AreEqual('Teams User', User."Full Name", UnexpectedFullNameErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetMicrosoft365PlanId(), User."User Security ID"), IncorrectPlanErr);

        // Verify Internal admin user
        User.SetRange("Authentication Email", InternalAdminEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.AreEqual(InternalAdminEmailTxt, User."Contact Email", UnexpectedContactEmailErr);
        LibraryAssert.AreEqual('Internal Admin User', User."Full Name", UnexpectedFullNameErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetInternalAdminPlanId(), User."User Security ID"), IncorrectPlanErr);

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestSyncEnvironmentDirectoryGroupWithMembersAndM365CollaborationOff()
    var
        User: Record User;
        TempAzureADUserUpdateBuffer: Record "Azure AD User Update Buffer" temporary;
        AzureADUserSyncImpl: Codeunit "Azure AD User Sync Impl.";
        GroupNameTxt: Label 'Group with members';
    begin
        Initialize();

        // [GIVEN] Users with different licenses are present in Azure AD, they are all members of the specified group
        CreateUsers(true, GroupNameTxt);

        // [GIVEN] The environemnt directory group is defined
        MockGraphQueryTestLibrary.SetEnvironmentDirectoryGroup(GroupNameTxt);

        // [GIVEN] The tenant admin has turned off the M365 collaboration switch
        MockGraphQueryTestLibrary.SetM365CollaborationEnabled(false);

        // [WHEN] The information from M365 is fetched and applied
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);
        AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);

        // [THEN] Four users are created: Essential, Team Member, Internal admin and Device (Teams and non-BC users are skipped)
        LibraryAssert.AreEqual(4, User.Count(), UnexpectedNumberOfUsersErr);

        // Verify Teams user is not created
        User.SetRange("Authentication Email", TeamsUserEmailTxt);
        LibraryAssert.IsTrue(User.IsEmpty(), UserWasNotCreatedErr);

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestUpdateUsersFromEnvironmentDirectoryGroupWithMembers()
    var
        User: Record User;
        TempAzureADUserUpdateBuffer: Record "Azure AD User Update Buffer" temporary;
        AzureADUserSyncImpl: Codeunit "Azure AD User Sync Impl.";
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
        GraphUserEssential: DotNet UserInfo;
        // NullIEnumerable: DotNet GenericList1;
        GroupNameTxt: Label 'Group with members';
    begin
        Initialize();

        // [GIVEN] The environemnt directory group is defined
        MockGraphQueryTestLibrary.SetEnvironmentDirectoryGroup(GroupNameTxt);

        // [GIVEN] A user with Essentials license in Azure AD who has a corresponding user in BC and is a member of the environment security group
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUserEssential, CreateGuid(), 'Essential', CommonLastNameTxt, EssentialEmailTxt);
        MockGraphQueryTestLibrary.AddUserPlan(GraphUserEssential.ObjectId, PlanIds.GetEssentialPlanId(), '', 'Enabled');
        MockGraphQueryTestLibrary.AddGraphUserToGroup(GraphUserEssential, GroupNameTxt);
        AzureADUserMgtTestLibrary.CreateUser(GraphUserEssential);

        // [WHEN] The information from M365 is fetched and applied
        // [THEN] Only one update is applied - the user plan
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);
        LibraryAssert.AreEqual(1, AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer), UnexpectedNoOfChangesErr);

        // Verify Essential user plan
        User.SetRange("Authentication Email", EssentialEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetEssentialPlanId(), User."User Security ID"), IncorrectPlanErr);

        // [WHEN] The admin has changed the security group, so the Essentials user is not a part of the the environment security group
        MockGraphQueryTestLibrary.SetEnvironmentDirectoryGroup('New environment group');

        // [WHEN] The information from M365 is fetched and applied 
        // [THEN] Only one update is applied - removing user plans from the Essentials user
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);
        LibraryAssert.AreEqual(1, AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer), UnexpectedNoOfChangesErr);

        // Verify Essential user has no plans
        User.SetRange("Authentication Email", EssentialEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.IsFalse(AzureADPlan.DoesUserHavePlans(User."User Security ID"), IncorrectPlanErr);

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestUpdateInternalAdminNotMemberOfEnvironmentGroup()
    var
        User: Record User;
        TempAzureADUserUpdateBuffer: Record "Azure AD User Update Buffer" temporary;
        AzureADUserSyncImpl: Codeunit "Azure AD User Sync Impl.";
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan Ids";
        GraphUserInternalAdmin: DotNet UserInfo;
        // NullIEnumerable: DotNet GenericList1;
        GroupNameTxt: Label 'Group with members';
    begin
        Initialize();

        // [GIVEN] The environemnt directory group is defined
        MockGraphQueryTestLibrary.SetEnvironmentDirectoryGroup(GroupNameTxt);

        // [GIVEN] A user who is global admin in Azure AD who has a corresponding user in BC and is not a member of the environment security group
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUserInternalAdmin, CreateGuid(), 'Internal Admin', CommonLastNameTxt, InternalAdminEmailTxt);
        MockGraphQueryTestLibrary.AddUserRole(GraphUserInternalAdmin.ObjectId, PlanIds.GetInternalAdminPlanId(), '', '', true);
        AzureADUserMgtTestLibrary.CreateUser(GraphUserInternalAdmin);

        // [WHEN] The information from M365 is fetched and applied
        // [THEN] Only one update is applied - the user plan
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);
        LibraryAssert.AreEqual(1, AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer), UnexpectedNoOfChangesErr);

        // Verify Internal Admin user plan
        User.SetRange("Authentication Email", InternalAdminEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetInternalAdminPlanId(), User."User Security ID"), IncorrectPlanErr);

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestUpdateLanguage()
    var
        User: Record User;
        UserPersonalization: Record "User Personalization";
        TempAzureADUserUpdateBuffer: Record "Azure AD User Update Buffer" temporary;
        AzureADUserSyncImpl: Codeunit "Azure AD User Sync Impl.";
        AzureADGraph: Codeunit "Azure AD Graph";
        GraphUserInternalAdmin: DotNet UserInfo;
    begin
        Initialize();
        CreateLanguage('ESP', 'Spanish', 1034);

        // [GIVEN] Users with different licenses are present in Azure AD and have corresponding users in BC
        CreateUsers(false);

        // [GIVEN] A user has user personalization defined
        User.SetRange("Authentication Email", InternalAdminEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);

        UserPersonalization."User SID" := User."User Security ID";
        UserPersonalization.Insert();

        // [WHEN] A user updated their preferred language in Azure AD
        AzureADGraph.GetUserByAuthorizationEmail(User."Authentication Email", GraphUserInternalAdmin);
        GraphUserInternalAdmin.PreferredLanguage := 'es';

        // [WHEN] All the information in Azure AD and BC is synchronized
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);
        AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);

        // [THEN] The language code got updated
        UserPersonalization.Get(User."User Security ID");
        LibraryAssert.AreEqual(1034, UserPersonalization."Language ID", 'Expected the language ID to be Spanish.');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestUsersDeletedInM365()
    var
        User: Record User;
        TempAzureADUserUpdateBuffer: Record "Azure AD User Update Buffer" temporary;
        AzureADUserSyncImpl: Codeunit "Azure AD User Sync Impl.";
        AzureADPlan: Codeunit "Azure AD Plan";
    begin
        Initialize();

        // [GIVEN] Users with different licenses are present in Azure AD and have corresponding users in BC
        CreateUsers(false);

        // [GIVEN] All the information in Azure AD and BC is synchronized
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);
        AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);

        // [WHEN] Users are deleted in Azure AD
        Clear(AzureADUserSyncImpl); // Clean the global initialized AzureADPlan variable
        MockGraphQueryTestLibrary.SetupMockGraphQuery(); // Clear all the assignments in MockGraphQuery
        AzureADGraphTestLibrary.SetMockGraphQuery(MockGraphQueryTestLibrary); // Use the cleared MockGraphQuery

        // [WHEN] The information from M365 is fetched and applied
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);
        AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);

        // [THEN] User pans are cleared
        LibraryAssert.AreEqual(5, User.Count(), UnexpectedNumberOfUsersErr);
        User.FindSet();
        repeat
            LibraryAssert.IsFalse(AzureADPlan.DoesUserHavePlans(User."User Security ID"), 'Expected the user to not have any plans assigned.');
        until User.Next() = 0;

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestApplyDifferentTypesOfUpdates()
    var
        User: Record User;
        TempAzureADUserUpdateBuffer: Record "Azure AD User Update Buffer" temporary;
        AzureADUserSyncImpl: Codeunit "Azure AD User Sync Impl.";
        PlanIds: Codeunit "Plan Ids";
        AzureADPlan: Codeunit "Azure AD Plan";
        GraphUserEssentialRemoved, GraphUserEssentialModified, GraphUserEssentialAdded : DotNet UserInfo;
    begin
        Initialize();

        // [GIVEN] A user that is synced, and then removed
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUserEssentialRemoved, CreateGuid(), 'Essential Removed', CommonLastNameTxt, 'Removed' + EssentialEmailTxt);
        MockGraphQueryTestLibrary.AddUserPlan(GraphUserEssentialRemoved.ObjectId, PlanIds.GetEssentialPlanId(), '', 'Enabled');

        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);
        AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);

        Clear(AzureADUserSyncImpl); // Clean the global initialized AzureADPlan variable
        MockGraphQueryTestLibrary.SetupMockGraphQuery(); // Clear all the assignments in MockGraphQuery
        AzureADGraphTestLibrary.SetMockGraphQuery(MockGraphQueryTestLibrary); // Use the cleared MockGraphQuery

        // [GIVEN] A new user in Azure AD
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUserEssentialAdded, CreateGuid(), 'Essential Added', CommonLastNameTxt, 'Added' + EssentialEmailTxt);
        MockGraphQueryTestLibrary.AddUserPlan(GraphUserEssentialAdded.ObjectId, PlanIds.GetEssentialPlanId(), '', 'Enabled');

        // [GIVEN] A modified user (the user exists, but the plan is not synced)
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUserEssentialModified, CreateGuid(), 'Essential Modified', CommonLastNameTxt, 'Modified' + EssentialEmailTxt);
        MockGraphQueryTestLibrary.AddUserPlan(GraphUserEssentialModified.ObjectId, PlanIds.GetEssentialPlanId(), '', 'Enabled');
        AzureADUserMgtTestLibrary.CreateUser(GraphUserEssentialModified);

        // [WHEN] The information from M365 is fetched and applied
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);

        // [THEN] The expected number of updates is performed:
        // - authentication email, contact email, full name and plan for the added user
        // - plan for the modified user
        // - removing the plans for the removed user
        LibraryAssert.AreEqual(6, AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer), UnexpectedNoOfChangesErr);

        // Verify the plans were cleared for the removed user
        User.SetRange("Authentication Email", 'Removed' + EssentialEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.IsFalse(AzureADPlan.DoesUserHavePlans(User."User Security ID"), 'Expected the user to not have any plans assigned.');

        // Verify the plan was assigned for the modified user
        User.SetRange("Authentication Email", 'Modified' + EssentialEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetEssentialPlanId(), User."User Security ID"), IncorrectPlanErr);

        // Verify all the fields for the added user
        User.SetRange("Authentication Email", 'Added' + EssentialEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.AreEqual('Added' + EssentialEmailTxt, User."Contact Email", UnexpectedContactEmailErr);
        LibraryAssert.AreEqual('Essential Added User', User."Full Name", UnexpectedFullNameErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetEssentialPlanId(), User."User Security ID"), IncorrectPlanErr);

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestMixedPlansDetected()
    var
        TempAzureADUserUpdateBuffer: Record "Azure AD User Update Buffer" temporary;
        AzureADUserSyncImpl: Codeunit "Azure AD User Sync Impl.";
        PlanIds: Codeunit "Plan Ids";
        GraphUserEssential, GraphUserPremium : DotNet UserInfo;
    begin
        Initialize();

        // [GIVEN] A user in Azure AD with Essential license
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUserEssential, CreateGuid(), 'Essential', CommonLastNameTxt, EssentialEmailTxt);
        MockGraphQueryTestLibrary.AddUserPlan(GraphUserEssential.ObjectId, PlanIds.GetEssentialPlanId(), '', 'Enabled');

        // [GIVEN] The information from M365 is fetched and applied
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);
        AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);

        // [WHEN] A different user in Azure AD is assigned a Premium license
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUserPremium, CreateGuid(), 'Premium', CommonLastNameTxt, PremiumEmailTxt);
        MockGraphQueryTestLibrary.AddUserPlan(GraphUserPremium.ObjectId, PlanIds.GetPremiumPlanId(), '', 'Enabled');

        // [WHEN] The information from M365 is fetched and applied
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);
        // [THEN] The error happens before any updates are applied stating that the customer cannot mix Essential and Premium plans
        asserterror AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);

        LibraryAssert.ExpectedError(StrSubstNo(MixedPlansNonAdminErr, EssentialEmailTxt, PremiumEmailTxt));

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestLicensedDeviceUser()
    var
        User: Record User;
        TempAzureADUserUpdateBuffer: Record "Azure AD User Update Buffer" temporary;
        AzureAdPlan: Codeunit "Azure AD Plan";
        AzureADUserSyncImpl: Codeunit "Azure AD User Sync Impl.";
        PlanIds: Codeunit "Plan Ids";
        GraphUserEssential: DotNet UserInfo;
    begin
        Initialize();

        // [GIVEN] A user in Azure AD with Essential license who is also a part of the Device group
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUserEssential, CreateGuid(), 'Essential', CommonLastNameTxt, EssentialEmailTxt);
        MockGraphQueryTestLibrary.AddUserPlan(GraphUserEssential.ObjectId, PlanIds.GetEssentialPlanId(), '', 'Enabled');
        MockGraphQueryTestLibrary.AddGraphUserToDevicesGroup(GraphUserEssential);

        // [GIVEN] The information from M365 is fetched and applied
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);
        AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);

        // [THEN] The user has both Essential and Device plans
        User.SetRange("Authentication Email", EssentialEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetEssentialPlanId(), User."User Security ID"), IncorrectPlanErr);
        LibraryAssert.IsFalse(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetDevicePlanId(), User."User Security ID"), 'The device plan should only be added if the user does not have BC plans or roles.');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestSyncWizardUI()
    var
        User: Record User;
        PlanIds: Codeunit "Plan Ids";
        AzureADPlan: Codeunit "Azure AD Plan";
        AzureADUserUpdateWizard: TestPage "Azure AD User Update Wizard";
        GraphUserEssential: DotNet UserInfo;
    begin
        Initialize();

        // [GIVEN] A user in Azure AD with Essential license
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUserEssential, CreateGuid(), 'Essential', CommonLastNameTxt, EssentialEmailTxt);
        MockGraphQueryTestLibrary.AddUserPlan(GraphUserEssential.ObjectId, PlanIds.GetEssentialPlanId(), '', 'Enabled');

        // [WHEN] The sync wizard is started
        AzureADUserUpdateWizard.Trap();
        Page.Run(Page::"Azure AD User Update Wizard");

        // [THEN] The greetings page is shown, click next
        AzureADUserUpdateWizard.Next.Invoke();

        // [THEN] The user is given a choice of either view applicable changes or finish the wizard, click "View changes"
        LibraryAssert.IsTrue(AzureADUserUpdateWizard.ApplyUpdates.Visible(), 'Expected the Finish button to be visible.');
        LibraryAssert.IsTrue(AzureADUserUpdateWizard.ViewChanges.Visible(), 'Expected the View changes button to be visible.');
        AzureADUserUpdateWizard.ViewChanges.Invoke();

        // [THEN] The list of changes is visible and shows expected results
        // Verify first row:
        AzureADUserUpdateWizard.Changes.First();
        LibraryAssert.AreEqual('ESSENTIAL USER', AzureADUserUpdateWizard.Changes."Display Name".Value, 'Unexpected user display name.');
        LibraryAssert.AreEqual(Format(Enum::"Azure AD Update Type"::New), AzureADUserUpdateWizard.Changes."Update Type".Value, 'Unexpected update type.');
        LibraryAssert.AreEqual(Format(Enum::"Azure AD User Update Entity"::"Authentication Email"), AzureADUserUpdateWizard.Changes."Information".Value, 'Unexpected update entity.');
        LibraryAssert.AreEqual('', AzureADUserUpdateWizard.Changes."Current Value".Value, 'Unexpected current value.');
        LibraryAssert.AreEqual(EssentialEmailTxt, AzureADUserUpdateWizard.Changes."New Value".Value, 'Unexpected new value.');

        // Verify second row:
        AzureADUserUpdateWizard.Changes.Next();
        LibraryAssert.AreEqual(Format(Enum::"Azure AD User Update Entity"::"Contact Email"), AzureADUserUpdateWizard.Changes."Information".Value, 'Unexpected update entity.');
        LibraryAssert.AreEqual(EssentialEmailTxt, AzureADUserUpdateWizard.Changes."New Value".Value, 'Unexpected new value.');

        // Verify third row:
        AzureADUserUpdateWizard.Changes.Next();
        LibraryAssert.AreEqual(Format(Enum::"Azure AD User Update Entity"::"Full Name"), AzureADUserUpdateWizard.Changes."Information".Value, 'Unexpected update entity.');
        LibraryAssert.AreEqual('Essential User', AzureADUserUpdateWizard.Changes."New Value".Value, 'Unexpected new value.');

        // Verify fourth row:
        AzureADUserUpdateWizard.Changes.Next();
        LibraryAssert.AreEqual(Format(Enum::"Azure AD User Update Entity"::Plan), AzureADUserUpdateWizard.Changes."Information".Value, 'Unexpected update entity.');
        LibraryAssert.AreEqual('Dynamics 365 Business Central Essential', AzureADUserUpdateWizard.Changes."New Value".Value, 'Unexpected new value.');

        LibraryAssert.IsFalse(AzureADUserUpdateWizard.Changes.Next(), 'Expected to have only 4 rows in the list of changes.');

        // [WHEN] Finish and close are clicked
        AzureADUserUpdateWizard.ApplyUpdates.Invoke();
        AzureADUserUpdateWizard.Close.Invoke();

        // [THEN] The changes are applied
        // Verify Essential user
        User.SetRange("Authentication Email", EssentialEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.AreEqual(EssentialEmailTxt, User."Contact Email", UnexpectedContactEmailErr);
        LibraryAssert.AreEqual('Essential User', User."Full Name", UnexpectedFullNameErr);
        LibraryAssert.IsTrue(AzureADPlan.IsPlanAssignedToUser(PlanIds.GetEssentialPlanId(), User."User Security ID"), IncorrectPlanErr);

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestArePermissionsCustomizedNo()
    var
        User: Record User;
        AzureADUserUpdateBuffer: Record "Azure AD User Update Buffer";
        AzureADPlanTestLibrary: Codeunit "Azure AD Plan Test Library";
        PlanConfiguration: Codeunit "Plan Configuration";
        AzureADUserSyncImpl: Codeunit "Azure AD User Sync Impl.";
        AzureADUserManagement: Codeunit "Azure AD User Management";
        GraphUser: DotNet UserInfo;
        TestPlanId: Guid;
        NullGuid: Guid;
    begin
        Initialize();

        // [GIVEN] A default permission set in a plan exists
        TestPlanId := AzureADPlanTestLibrary.CreatePlan('Test Plan');
        PlanConfiguration.AddDefaultPermissionSetToPlan(TestPlanId, 'Test Role ID', NullGuid, 1);

        // [GIVEN] A user in Azure AD with the test plan exists
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUser, CreateGuid(), 'John', 'Doe', NonBcEmailTxt);
        MockGraphQueryTestLibrary.AddUserPlan(GraphUser.ObjectId, TestPlanId, '', 'Enabled');

        // [WHEN] The information from M365 is fetched and applied
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(AzureADUserUpdateBuffer);
        AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(AzureADUserUpdateBuffer);

        User.SetRange("Authentication Email", NonBcEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);

        // The following line is needed because codeunit "Permission Manager" assigns default permission
        // during user sync, and BaseApp is not installed when running system application tests.
        PlanConfiguration.AssignDefaultPermissionsToUser(TestPlanId, User."User Security ID", '');

        // [THEN] ArePermissionsCustomized returns false for the newly created user
        LibraryAssert.IsFalse(AzureADUserManagement.ArePermissionsCustomized(User."User Security ID"), 'Expected the permissions to not be customized.');

        TearDown();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [CommitBehavior(CommitBehavior::Ignore)]
    procedure TestArePermissionsCustomizedYes()
    var
        User: Record User;
        AzureADUserUpdateBuffer: Record "Azure AD User Update Buffer";
        AccessControl: Record "Access Control";
        AzureADPlanTestLibrary: Codeunit "Azure AD Plan Test Library";
        PlanConfiguration: Codeunit "Plan Configuration";
        AzureADUserSyncImpl: Codeunit "Azure AD User Sync Impl.";
        AzureADUserManagement: Codeunit "Azure AD User Management";
        GraphUser: DotNet UserInfo;
        TestPlanId: Guid;
        NullGuid: Guid;
    begin
        Initialize();

        // [GIVEN] A default permission set in a plan exists
        TestPlanId := AzureADPlanTestLibrary.CreatePlan('Test Plan');
        PlanConfiguration.AddDefaultPermissionSetToPlan(TestPlanId, 'Test Role ID', NullGuid, 1);

        // [GIVEN] A user in Azure AD with the test plan exists
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUser, CreateGuid(), 'John', 'Doe', NonBcEmailTxt);
        MockGraphQueryTestLibrary.AddUserPlan(GraphUser.ObjectId, TestPlanId, '', 'Enabled');

        // [GIVEN] The information from M365 is fetched and applied
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(AzureADUserUpdateBuffer);
        AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(AzureADUserUpdateBuffer);

        User.SetRange("Authentication Email", NonBcEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);

        // The following line is needed because codeunit "Permission Manager" assigns default permission
        // during user sync, and BaseApp is not installed when running system application tests.
        PlanConfiguration.AssignDefaultPermissionsToUser(TestPlanId, User."User Security ID", '');

        // [WHEN] A custom permission set (i. e. one that is not associated with a plan configuration) is assigned to a user
        AccessControl."User Security ID" := User."User Security ID";
        AccessControl."Role ID" := 'CUSTOM';
        AccessControl.Scope := AccessControl.Scope::Tenant;
        AccessControl.Insert();

        // [THEN] ArePermissionsCustomized returns true for the user
        LibraryAssert.IsTrue(AzureADUserManagement.ArePermissionsCustomized(User."User Security ID"), 'Expected the permissions to not be customized.');

        TearDown();
    end;

    [Test]
    procedure TestNotAllChangesAreApplied()
    var
        User: Record User;
        TempAzureADUserUpdateBuffer: Record "Azure AD User Update Buffer" temporary;
        AzureADUserSyncImpl: Codeunit "Azure AD User Sync Impl.";
        AzureADGraph: Codeunit "Azure AD Graph";
        PlanIds: Codeunit "Plan Ids";
        GraphUserEssential, GraphUserSecondEssential : DotNet UserInfo;
    begin
        // Can't have TransactionModel::AutoRollback + CommitBehavior::Ignore, because isolated events only work
        // if at the moment of raising we are not in the write transaction (which is achieved by calling Commit())
        Initialize();

        // [GIVEN] Users with different licenses are present in Azure AD and have corresponding users in BC
        CreateUsers(false);

        // [WHEN] The information from M365 is fetched and applied
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);

        // [THEN] The expected number of successful updates is returned (5 plans are assigned in BC)
        LibraryAssert.AreEqual(5, AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer), UnexpectedNoOfChangesErr);

        // [GIVEN] An error will happen when creating a new user
        UnbindSubscription(AzureADUserMgtTestLibrary);

        // [WHEN] A new user in Azure AD is assigned a BC license
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUserSecondEssential, CreateGuid(), 'Second Essential', CommonLastNameTxt, '2' + EssentialEmailTxt);
        MockGraphQueryTestLibrary.AddUserPlan(GraphUserSecondEssential.ObjectId, PlanIds.GetEssentialPlanId(), '', 'Enabled');
        // And another user had their first name updated
        AzureADGraph.GetUserByAuthorizationEmail(EssentialEmailTxt, GraphUserEssential);
        GraphUserEssential.GivenName := 'First Essential';

        // [WHEN] The information from M365 is fetched and applied
        AzureADUserSyncImpl.FetchUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer);

        // [THEN] The error does not happen. If a user had errors for one of the updates,
        // then all updates for that users are skipped, and it does not affect the updates for other users
        LibraryAssert.AreEqual(1, AzureADUserSyncImpl.ApplyUpdatesFromAzureGraph(TempAzureADUserUpdateBuffer), 'Expected only one update to be applied.');
        // LibraryAssert.ExpectedError(StrSubstNo(MixedPlansNonAdminErr, EssentialEmailTxt, PremiumEmailTxt));

        // Verify the updated user
        User.SetRange("Authentication Email", EssentialEmailTxt);
        LibraryAssert.IsTrue(User.FindFirst(), UserWasNotCreatedErr);
        LibraryAssert.AreEqual('First Essential User', User."Full Name", UnexpectedFullNameErr);

        // Bind the subscription again, as it is unbound in TearDown()
        BindSubscription(AzureADUserMgtTestLibrary);
        TearDown();
    end;

    local procedure CreateUsers(AzureAdOnly: Boolean)
    begin
        CreateUsers(AzureAdOnly, '');
    end;

    local procedure CreateUsers(AzureAdOnly: Boolean; EnvironmentGroup: Text)
    var
        PlanIds: Codeunit "Plan Ids";
        GraphUserEssential, GraphUserTeams, GraphUserTeamMember, GraphUserInternalAdmin, GraphUserDevice, GraphUserNonBC : DotNet UserInfo;
        CapabilityStatusEnabledTxt: Label 'Enabled';
        ServicePlanNameTxt: Label '';
    begin
        MockGraphQueryTestLibrary.SetM365CollaborationEnabled(true);

        // A user with Essential license
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUserEssential, CreateGuid(), 'Essential', CommonLastNameTxt, EssentialEmailTxt);
        MockGraphQueryTestLibrary.AddUserPlan(GraphUserEssential.ObjectId, PlanIds.GetEssentialPlanId(), ServicePlanNameTxt, CapabilityStatusEnabledTxt);

        // A user with Team Member license
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUserTeamMember, CreateGuid(), 'Team Member', CommonLastNameTxt, TeamMemberEmailTxt);
        MockGraphQueryTestLibrary.AddUserPlan(GraphUserTeamMember.ObjectId, PlanIds.GetTeamMemberPlanId(), ServicePlanNameTxt, CapabilityStatusEnabledTxt);

        // A user with Teams license
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUserTeams, CreateGuid(), 'Teams', CommonLastNameTxt, TeamsUserEmailTxt);
        MockGraphQueryTestLibrary.AddUserPlan(GraphUserTeams.ObjectId, PlanIds.GetMicrosoft365PlanId(), ServicePlanNameTxt, CapabilityStatusEnabledTxt);

        // A user who is internal admin
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUserInternalAdmin, CreateGuid(), 'Internal Admin', CommonLastNameTxt, InternalAdminEmailTxt);
        MockGraphQueryTestLibrary.AddUserRole(GraphUserInternalAdmin.ObjectId, PlanIds.GetInternalAdminPlanId(), '', '', true);

        // A user who is a part of the Device group
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUserDevice, CreateGuid(), 'Device', CommonLastNameTxt, DeviceEmailTxt);
        MockGraphQueryTestLibrary.AddGraphUserToDevicesGroup(GraphUserDevice);

        // A user with a license non recognised by BC
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(GraphUserNonBC, CreateGuid(), 'Non BC', CommonLastNameTxt, NonBcEmailTxt);

        if EnvironmentGroup <> '' then begin
            MockGraphQueryTestLibrary.AddGraphUserToGroup(GraphUserEssential, EnvironmentGroup);
            MockGraphQueryTestLibrary.AddGraphUserToGroup(GraphUserTeamMember, EnvironmentGroup);
            MockGraphQueryTestLibrary.AddGraphUserToGroup(GraphUserTeams, EnvironmentGroup);
            MockGraphQueryTestLibrary.AddGraphUserToGroup(GraphUserInternalAdmin, EnvironmentGroup);
            MockGraphQueryTestLibrary.AddGraphUserToGroup(GraphUserDevice, EnvironmentGroup);
            MockGraphQueryTestLibrary.AddGraphUserToGroup(GraphUserNonBC, EnvironmentGroup);
        end;

        if AzureAdOnly then
            exit;

        // Mock corresponding users having logged into BC in the past
        AzureADUserMgtTestLibrary.CreateUser(GraphUserEssential);
        AzureADUserMgtTestLibrary.CreateUser(GraphUserTeams);
        AzureADUserMgtTestLibrary.CreateUser(GraphUserTeamMember);
        AzureADUserMgtTestLibrary.CreateUser(GraphUserInternalAdmin);
        AzureADUserMgtTestLibrary.CreateUser(GraphUserDevice);
    end;

    local procedure CreateLanguage(LanguageCode: Code[10]; LanguageName: Text[50]; LanguageID: Integer)
    var
        Language: Record Language;
    begin
        if not Language.Get(LanguageCode) then begin
            Language.Code := LanguageCode;
            Language.Name := LanguageName;
            Language."Windows Language ID" := LanguageID;
            Language.Insert(true);
        end;
    end;

    local procedure Initialize()
    var
        User: Record User;
        UserProperty: Record "User Property";
    begin
        // Autorollback will not remove records between different tests of one test run
        UserProperty.DeleteAll();
        User.DeleteAll();

        Clear(AzureADGraphTestLibrary);
        Clear(AzureADUserMgtTestLibrary);
        Clear(MockGraphQueryTestLibrary);

        // Intentionally not binding the subscription for AzureADPlanTestLibrary
        // (so that BC and non-BC plans are recognized as expected)
        BindSubscription(AzureADGraphTestLibrary);
        BindSubscription(AzureADUserMgtTestLibrary);

        MockGraphQueryTestLibrary.SetupMockGraphQuery();
        AzureADGraphTestLibrary.SetMockGraphQuery(MockGraphQueryTestLibrary);

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
    end;

    local procedure TearDown()
    begin
        UnbindSubscription(AzureADGraphTestLibrary);
        UnbindSubscription(AzureADUserMgtTestLibrary);

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;
}

