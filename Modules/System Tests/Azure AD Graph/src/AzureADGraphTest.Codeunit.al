// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Azure.ActiveDirectory;

using System.TestLibraries.Azure.ActiveDirectory;
using System.TestLibraries.Mocking;
using System.Azure.Identity;
using System.TestLibraries.Environment;
using System;
using System.TestLibraries.Utilities;

codeunit 139087 "Azure AD Graph Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        AzureADGraphTestLibrary: Codeunit "Azure AD Graph Test Library";
        MockGraphQueryTestLibrary: Codeunit "MockGraphQuery Test Library";
        AzureADGraph: Codeunit "Azure AD Graph";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";

    [Test]
    [Scope('OnPrem')]
    procedure TestGetUser()
    var
        UserInfo: DotNet UserInfo;
        UserId: Guid;
        UserPrincipalName: Text;
    begin
        Initialize();

        // [GIVEN] A user id and a principal name
        UserId := CreateGuid();
        UserPrincipalName := 'random_user_principal_name@microsoft.com';

        // [WHEN] Trying to get the user with the given user principal name from the Azure AD Graph
        // [THEN] An error should be thrown, as the user has not been inserted yet
        asserterror AzureADGraph.GetUser(UserPrincipalName, UserInfo);

        // [THEN] The user should be null
        LibraryAssert.IsTrue(IsNull(UserInfo),
           'The user should be null, as no user with this principal name has been inserted yet');

        // [GIVEN] A graph user with the given user id and principal name is inserted in the Azure AD Graph
        MockGraphQueryTestLibrary.AddGraphUser(UserId, '', '', UserPrincipalName);

        // [WHEN] Getting the user from the Azure AD Graph
        AzureADGraph.GetUser(UserPrincipalName, UserInfo);

        // [THEN] The user's principal name and object id should coincide with the ones
        // it was initialized with
        LibraryAssert.AreEqual(UserPrincipalName, UserInfo.UserPrincipalName(),
            'The user principal name is incorrect');
        LibraryAssert.AreEqual(Format(UserId), UserInfo.ObjectId(), 'The user object id is incorrect');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetCurrentUser()
    var
        UserInfo: DotNet UserInfo;
        UserGivenName: Text;
        UserPrincipalName: Text;
    begin
        Initialize();

        // [GIVEN] The Azure AD graph does not contain a user corresponding to the current user
        // [WHEN] Trying to get the current user
        AzureADGraph.GetCurrentUser(UserInfo);

        // [THEN] The user should be null
        LibraryAssert.IsTrue(IsNull(UserInfo), 'The user should be null');

        // [GIVEN] The Azure AD Graph contains a user corresponding to the current user
        UserGivenName := 'given name - random';
        UserPrincipalName := 'blah_blah@blah.com';

        MockGraphQueryTestLibrary.SetCurrentUser(UserGivenName, UserPrincipalName);

        // [WHEN] Getting the current user from the Azure AD Graph
        AzureADGraph.GetCurrentUser(UserInfo);

        // [THEN] The user properties should be set correctly
        LibraryAssert.AreEqual(Format(UserSecurityId()), UserInfo.ObjectId(), 'The object id is incorrect');
        LibraryAssert.AreEqual(UserGivenName, UserInfo.GivenName(), 'The given name is incorrect');
        LibraryAssert.AreEqual(UserPrincipalName, UserInfo.UserPrincipalName(),
            'The user principal name is incorrect');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetUserByAuthorizationEmail()
    var
        UserInfo: DotNet UserInfo;
        UserId: Guid;
        AuthorizationEmail: Text;
    begin
        Initialize();

        // [GIVEN] A user id and an authorization email
        UserId := CreateGuid();
        AuthorizationEmail := 'random_authorization_email@microsoft.com';

        // [WHEN] Trying to get the user with this authorization email
        AzureADGraph.GetUserByAuthorizationEmail(AuthorizationEmail, UserInfo);

        // [THEN] The user should be null, as it has not been inserted yet
        LibraryAssert.IsTrue(IsNull(UserInfo), 'The user should be null');

        // [GIVEN] A graph user with the given user id and authorization email is inserted in the Azure AD graph    
        MockGraphQueryTestLibrary.AddGraphUser(UserId, '', '', AuthorizationEmail);

        // [WHEN] Getting the user from the Azure AD Graph
        AzureADGraph.GetUserByAuthorizationEmail(AuthorizationEmail, UserInfo);

        // [THEN] The user's properties should be set correctly
        LibraryAssert.AreEqual(AuthorizationEmail, UserInfo.UserPrincipalName(),
            'The user principal name is incorrect');
        LibraryAssert.AreEqual(Format(UserId), UserInfo.ObjectId(), 'The user object id is incorrect');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetUserByObjectId()
    var
        UserInfo: DotNet UserInfo;
        UserId: Guid;
        UserGivenName: Text;
        UserPrincipalName: Text;
    begin
        Initialize();

        // [GIVEN] A user id, given name and principal name
        UserId := CreateGuid();
        UserGivenName := 'given name';
        UserPrincipalName := 'meh@blah.com';

        // [WHEN] Trying to get the user with the given id
        // [THEN] An error will be thrown, as the user has not been inserted yet
        asserterror AzureADGraph.GetUserByObjectId(UserId, UserInfo);

        // [THEN] The user should be null
        LibraryAssert.IsTrue(IsNull(UserInfo), 'The user should be null');

        // [GIVEN] A graph user with the given user id and authorization email is inserted in the Azure AD graph
        MockGraphQueryTestLibrary.AddGraphUser(UserId, UserGivenName, '', UserPrincipalName);

        // [WHEN] Getting the user from the Azure AD Graph
        AzureADGraph.GetUserByObjectId(UserId, UserInfo);

        // [THEN] The user's properties should be set correctly
        LibraryAssert.AreEqual(UserGivenName, UserInfo.GivenName(), 'The given name is incorrect');
        LibraryAssert.AreEqual(UserPrincipalName, UserInfo.UserPrincipalName(),
            'The user principal name is incorrect');
        LibraryAssert.AreEqual(Format(UserId), UserInfo.ObjectId(), 'The user object id is incorrect');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestTryGetUserByObjectId()
    var
        UserInfo: DotNet UserInfo;
        UserId: Guid;
        UserGivenName: Text;
        UserPrincipalName: Text;
        IsUserRetrieved: Boolean;
    begin
        Initialize();

        // [GIVEN] A user id, given name and principal name
        UserId := CreateGuid();
        UserGivenName := 'given name 2';
        UserPrincipalName := 'meh_blah@blah.com';

        // [WHEN] Trying to get the user with the given id
        IsUserRetrieved := AzureADGraph.TryGetUserByObjectId(UserId, UserInfo);

        // [THEN] The user should be null
        LibraryAssert.IsTrue(IsNull(UserInfo), 'The user should be null');

        // [THEN] IsUserRetrieved should be false
        LibraryAssert.IsFalse(IsUserRetrieved, 'The user should not have been retrieved');

        // [GIVEN] A graph user with the given user id and authorization email is inserted in the Azure AD graph
        MockGraphQueryTestLibrary.AddGraphUser(UserId, UserGivenName, '', UserPrincipalName);

        // [WHEN] Getting the user from the Azure AD Graph
        IsUserRetrieved := AzureADGraph.TryGetUserByObjectId(UserId, UserInfo);

        // [THEN] IsUserRetrieved should be true
        LibraryAssert.IsTrue(IsUserRetrieved, 'The user should have been retrieved');

        // [THEN] The user's properties should be set correctly
        LibraryAssert.AreEqual(UserGivenName, UserInfo.GivenName(), 'The given name is incorrect');
        LibraryAssert.AreEqual(UserPrincipalName, UserInfo.UserPrincipalName(),
            'The user principal name is incorrect');
        LibraryAssert.AreEqual(Format(UserId), UserInfo.ObjectId(), 'The user object id is incorrect');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetUserAssignedPlansNullUserInfo()
    var
        NullUserInfo: DotNet UserInfo;
        UserAssignedPlans: DotNet GenericList1;
    begin
        // [WHEN] Trying to get the assigned plans, providing a null as UserInfo
        AzureADGraph.GetUserAssignedPlans(NullUserInfo, UserAssignedPlans);

        // [THEN] The assigned plans are null
        LibraryAssert.IsTrue(IsNull(UserAssignedPlans), 'The assigned plans should not have been initialized');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetUserAssignedPlans()
    var
        UserInfo: DotNet UserInfo;
        UserAssignedPlans: DotNet GenericList1;
        AssignedPlan: DotNet ServicePlanInfo;
        UserId: Guid;
        UserPrincipalName: Text;
        AssignedPlanId: Guid;
        AssignedPlanService: Text;
        CapabilityStatus: Text;
    begin
        Initialize();

        // [GIVEN] A user in the Azure AD graph
        UserId := CreateGuid();
        UserPrincipalName := 'meh_blah@blahblah.com';
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(UserInfo, UserId, '', '', UserPrincipalName);

        // [WHEN] Trying to get the user's assigned plans
        AzureADGraph.GetUserAssignedPlans(UserInfo, UserAssignedPlans);

        // [THEN] The user should not have any assigned plans, as none have been inserted yet
        LibraryAssert.AreEqual(0, UserAssignedPlans.Count(), 'There should not be any user assigned plans');

        // [GIVEN] A plan is inserted for the given user
        AssignedPlanId := CreateGuid();
        AssignedPlanService := 'service';
        CapabilityStatus := 'status';
        MockGraphQueryTestLibrary.AddUserPlan(UserId, AssignedPlanId, AssignedPlanService, CapabilityStatus);

        // [WHEN] Getting the user's assigned plans
        AzureADGraph.GetUserAssignedPlans(UserInfo, UserAssignedPlans);

        // [THEN] There should only be one user assigned plan
        LibraryAssert.AreEqual(1, UserAssignedPlans.Count(), 'There should be exactly one user assigned plan');

        // [THEN] The assigned plan's properties are set correctly
        foreach AssignedPlan in UserAssignedPlans do begin
            LibraryAssert.AreEqual(AssignedPlanId, AssignedPlan.ServicePlanId(), 'The assigned plan id is incorrect');
            LibraryAssert.AreEqual(AssignedPlanService, AssignedPlan.ServicePlanName(),
                'The service plan name is incorrect');
            LibraryAssert.AreEqual(CapabilityStatus, AssignedPlan.CapabilityStatus(),
                'The capability status is incorrect');
        end;

        // [GIVEN] Two more plans are inserted
        MockGraphQueryTestLibrary.AddUserPlan(UserId, CreateGuid(), '', '');
        MockGraphQueryTestLibrary.AddUserPlan(UserId, CreateGuid(), '', '');

        // [WHEN] Getting the user's assigned plans
        AzureADGraph.GetUserAssignedPlans(UserInfo, UserAssignedPlans);

        // [THEN] The user should have three assigned plans
        LibraryAssert.AreEqual(3, UserAssignedPlans.Count(), 'There should be exactly three user assigned plans');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetUserRolesNullUserInfo()
    var
        NullUserInfo: DotNet UserInfo;
        UserRoles: DotNet GenericList1;
    begin
        // [WHEN] Trying to get the assigned plans, providing a null as UserInfo
        AzureADGraph.GetUserRoles(NullUserInfo, UserRoles);

        // [THEN] The assigned plans are null
        LibraryAssert.IsTrue(IsNull(UserRoles), 'The user roles should not have been initialized');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetUserRoles()
    var
        UserInfo: DotNet UserInfo;
        UserRoles: DotNet GenericList1;
        Role: DotNet RoleInfo;
        UserId: Guid;
        UserPrincipalName: Text;
        RoleTemplateId: Text;
        RoleDescription: Text;
        RoleDisplayName: Text;
        RoleIsSystem: Boolean;
    begin
        Initialize();

        // [GIVEN] A user in the Azure AD graph
        UserId := CreateGuid();
        UserPrincipalName := 'meh_blah@blahblah.com';
        MockGraphQueryTestLibrary.AddAndReturnGraphUser(UserInfo, UserId, '', '', UserPrincipalName);

        // [WHEN] Trying to get the user's roles
        if not IsNull(UserInfo.Roles()) then begin
            UserRoles := UserInfo.Roles();

            // [THEN] The user should not have any roles, as none have been inserted yet
            LibraryAssert.AreEqual(0, UserRoles.Count(), 'There should not be any roles');
        end;

        // [GIVEN] A role is inserted for the given user
        RoleTemplateId := 'template id';
        RoleDescription := 'description';
        RoleDisplayName := 'role name';
        RoleIsSystem := true;
        MockGraphQueryTestLibrary.AddUserRole(UserId, RoleTemplateId, RoleDescription, RoleDisplayName, RoleIsSystem);

        // [WHEN] Getting the user's roles
        UserRoles := UserInfo.Roles();

        // [THEN] There should only be one role
        LibraryAssert.AreEqual(1, UserRoles.Count(), 'There should be exactly one role assigned to this user');

        // [THEN] The role's properties are set correctly
        foreach Role in UserRoles do begin
            LibraryAssert.AreEqual(RoleTemplateId, Role.RoleTemplateId(), 'The template id is incorrect');
            LibraryAssert.AreEqual(RoleDescription, Role.Description(), 'The description is incorrect');
            LibraryAssert.AreEqual(RoleDisplayName, Role.DisplayName(), 'The display name is incorrect');
            LibraryAssert.AreEqual(RoleIsSystem, Role.IsSystem(), 'The Is System flag is incorrect');
        end;

        // [GIVEN] Two more roles are inserted
        MockGraphQueryTestLibrary.AddUserRole(UserId, 'template id 2', '', '', true);
        MockGraphQueryTestLibrary.AddUserRole(UserId, 'template id 3', '', '', true);

        // [WHEN] Getting the user's roles
        UserRoles := UserInfo.Roles();

        // [THEN] The user should have three roles
        LibraryAssert.AreEqual(3, UserRoles.Count(), 'There should be exactly three roles');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetDirectorySubscribedSkus()
    var
        DirectorySubscribedSkus: DotNet GenericList1;
        Sku: DotNet SkuInfo;
        Plan: DotNet ServicePlanInfo;
        SkuId: Guid;
        PlanId: Guid;
        PlanName: Text;
    begin
        Initialize();

        // [WHEN] Trying to retrieve the directory subscribed SKUs
        AzureADGraph.GetDirectorySubscribedSkus(DirectorySubscribedSkus);

        // [THEN] The DirectorySubscribedSkus should be empty, as no SKUs have been inserted it
        LibraryAssert.AreEqual(0, DirectorySubscribedSkus.Count(),
            'There should not be any directory subscribed SKUs');

        // [GIVEN] A directory subscribed SKU is inserted
        SkuId := CreateGuid();
        PlanId := CreateGuid();
        PlanName := 'plan name';
        MockGraphQueryTestLibrary.AddSubscribedSkuWithServicePlan(SkuId, PlanId, PlanName);

        // [WHEN] Getting the directory subscribed SKUs
        AzureADGraph.GetDirectorySubscribedSkus(DirectorySubscribedSkus);

        // [THEN] There should only be one directory subscribed SKU
        LibraryAssert.AreEqual(1, DirectorySubscribedSkus.Count(),
            'There should be exactly one directory subscribed SKU');

        // [THEN] The directory subscribed SKU's properties are set correctly
        foreach Sku in DirectorySubscribedSkus do begin
            LibraryAssert.AreEqual(SkuId, Sku.SkuId(), 'The template id is incorrect');
            LibraryAssert.AreEqual(1, Sku.ServicePlans().Count(), 'The SKU should only have one plan');
            foreach Plan in Sku.ServicePlans() do begin
                LibraryAssert.AreEqual(PlanId, Plan.ServicePlanId(), 'The plan id is incorrect');
                LibraryAssert.AreEqual(PlanName, Plan.ServicePlanName(), 'The plan name is incorrect');
            end;
        end;

        // [GIVEN] Two more SKUs are inserted
        MockGraphQueryTestLibrary.AddSubscribedSkuWithServicePlan(CreateGuid(), CreateGuid(), 'name 1');
        MockGraphQueryTestLibrary.AddSubscribedSkuWithServicePlan(CreateGuid(), CreateGuid(), 'name 2');

        // [WHEN] Getting the directory subscribed SKUs
        AzureADGraph.GetDirectorySubscribedSkus(DirectorySubscribedSkus);

        // [THEN] The user should have three directory subscribed SKUs
        LibraryAssert.AreEqual(3, DirectorySubscribedSkus.Count(),
            'There should be exactly three directory subscribed SKUs');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetDirectoryRoles()
    var
        DirectoryRoles: DotNet GenericList1;
        Role: DotNet RoleInfo;
        RoleTemplateId: Text;
        RoleDescription: Text;
        RoleDisplayName: Text;
        RoleIsSystem: Boolean;
    begin
        Initialize();

        // [WHEN] Trying to retrieve the directory roles
        AzureADGraph.GetDirectoryRoles(DirectoryRoles);

        // [THEN] The DirectoryRoles should be empty, as no roles have been inserted it
        LibraryAssert.AreEqual(0, DirectoryRoles.Count(), 'There should not be any directory roles');

        // [GIVEN] A directory role is inserted
        RoleTemplateId := 'template id 100';
        RoleDescription := 'description 100';
        RoleDisplayName := 'role name 100';
        RoleIsSystem := true;
        MockGraphQueryTestLibrary.AddDirectoryRole(Role, RoleTemplateId, RoleDescription,
            RoleDisplayName, RoleIsSystem);

        // [WHEN] Getting the directory roles
        AzureADGraph.GetDirectoryRoles(DirectoryRoles);

        // [THEN] There should only be one directory role
        LibraryAssert.AreEqual(1, DirectoryRoles.Count(), 'There should be exactly one directory role');

        // [THEN] The directory roles are set correctly
        foreach Role in DirectoryRoles do begin
            LibraryAssert.AreEqual(RoleTemplateId, Role.RoleTemplateId(), 'The template id is incorrect');
            LibraryAssert.AreEqual(RoleDescription, Role.Description(), 'The description plan id is incorrect');
            LibraryAssert.AreEqual(RoleDisplayName, Role.DisplayName(), 'The display name is incorrect');
            LibraryAssert.AreEqual(RoleIsSystem, Role.IsSystem(), 'The IsSystem flag is incorrect');
        end;

        // [GIVEN] Two more roles are inserted
        MockGraphQueryTestLibrary.AddDirectoryRole(Role, 'template id 200', 'description 2', 'role name 2', true);
        MockGraphQueryTestLibrary.AddDirectoryRole(Role, 'template id 300', 'description 3', 'role name 3', true);

        // [WHEN] Getting the directory roles
        AzureADGraph.GetDirectoryRoles(DirectoryRoles);

        // [THEN] The user should have three directory roles
        LibraryAssert.AreEqual(3, DirectoryRoles.Count(), 'There should be exactly three directory roles');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetTenantDetail()
    var
        TenantInfo: DotNet TenantInfo;
    begin
        Initialize();

        // [WHEN] Trying to retrieve the tenant info
        AzureADGraph.GetTenantDetail(TenantInfo);

        // [THEN] The properties that are retrieved should be the ones that are set on the mocked 
        // tenant detail in the platform
        LibraryAssert.AreEqual('Mock Company', TenantInfo.DisplayName(), 'The display name is incorrect');
        LibraryAssert.AreEqual('On Mock Way 1', TenantInfo.Street(), 'The street is incorrect');
        LibraryAssert.AreEqual('12345', TenantInfo.PostalCode(), 'The postal code is incorrect');
        LibraryAssert.AreEqual('Mock City', TenantInfo.City(), 'The city is incorrect');
        LibraryAssert.AreEqual('WA', TenantInfo.State(), 'The state is incorrect');
        LibraryAssert.AreEqual('Mock Country', TenantInfo.Country(), 'The country is incorrect');
        LibraryAssert.AreEqual('US', TenantInfo.CountryLetterCode(), 'The country letter code is incorrect');
        LibraryAssert.AreEqual('da-DK', TenantInfo.PreferredLanguage(), 'The preferred language is incorrect');
        LibraryAssert.AreEqual('112-112-1123', TenantInfo.TelephoneNumber(), 'The telephone number is incorrect');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetUsersPage()
    var
        UserInfoPage: DotNet UserInfoPage;
        UserInfo: DotNet UserInfo;
        NumberOfUsers: Integer;
        UserId: Guid;
        UserPrincipalName: Text;
    begin
        Initialize();

        // [WHEN] Retrieving the users page with the first 100 users
        NumberOfUsers := 100;
        AzureADGraph.GetUsersPage(NumberOfUsers, UserInfoPage);

        // [THEN] The page should be empty
        LibraryAssert.AreEqual(0, UserInfoPage.CurrentPage().Count(), 'There should not be any users');

        // [GIVEN] The Azure graph contains a user
        UserId := CreateGuid();
        UserPrincipalName := 'principal@principal.com';
        MockGraphQueryTestLibrary.AddGraphUser(UserId, '', '', UserPrincipalName);

        // [WHEN] Retrieving the users page with the first 100 users
        AzureADGraph.GetUsersPage(NumberOfUsers, UserInfoPage);

        // [THEN] There should be exactly one user on the page
        LibraryAssert.AreEqual(1, UserInfoPage.CurrentPage().Count(),
            'There should be exactly one user on the page');

        // [THEN] The user's properties should be identical to the ones set above
        foreach UserInfo in UserInfoPage.CurrentPage() do begin
            LibraryAssert.AreEqual(Format(UserId), UserInfo.ObjectId(), 'The user id is incorrect');
            LibraryAssert.AreEqual(UserPrincipalName, UserInfo.UserPrincipalName(),
                'The user principal name is incorrect');
        end;

        // [GIVEN] Two more users are added to the graph
        MockGraphQueryTestLibrary.AddGraphUser(CreateGuid(), '', '', 'name@email.com');
        MockGraphQueryTestLibrary.AddGraphUser(CreateGuid(), '', '', 'email@email.com');

        // [WHEN] Retrieving the users page with the first 100 users
        AzureADGraph.GetUsersPage(NumberOfUsers, UserInfoPage);

        // [THEN] There should be exactly three users on the page
        LibraryAssert.AreEqual(3, UserInfoPage.CurrentPage().Count(),
            'There should be exactly three users on the page');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestIsGraphUserAccountEnabledTrue()
    var
        UserId: Guid;
        UserPrincipalName: Text;
        IsEnabled: Boolean;
    begin
        Initialize();

        // [GIVEN] A user id and a principal name
        UserId := CreateGuid();
        UserPrincipalName := 'random_user_principal_name@microsoft.com';

        // [WHEN] Trying to get user is enabled in Azure AD with the given user principal name from the Azure AD Graph
        // [THEN] An error should be thrown, as the user has not been inserted yet
        LibraryAssert.IsFalse(AzureADGraph.IsGraphUserAccountEnabled(UserPrincipalName, IsEnabled), 'User account should not exist');

        // [THEN] The user is not enabled
        LibraryAssert.IsFalse(IsEnabled, 'The user should not be enabled, as no user with this principal name has been inserted yet');

        // [GIVEN] A graph user that is enabled
        MockGraphQueryTestLibrary.AddGraphUser(UserId, '', '', UserPrincipalName, true);

        // [WHEN] Getting whether the user is enabled
        AzureADGraph.IsGraphUserAccountEnabled(UserPrincipalName, IsEnabled);

        // [THEN] The user is enabled
        LibraryAssert.IsTrue(IsEnabled, 'The user should be enabled');

        TearDown();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestIsGraphUserAccountEnabledFalse()
    var
        UserId: Guid;
        UserPrincipalName: Text;
        IsEnabled: Boolean;
    begin
        Initialize();

        // [GIVEN] A user id and a principal name
        UserId := CreateGuid();
        UserPrincipalName := 'random_user_principal_name@microsoft.com';

        // [GIVEN] A graph user that is not enabled
        MockGraphQueryTestLibrary.AddGraphUser(UserId, '', '', UserPrincipalName, false);

        // [WHEN] Getting whether the user is enabled
        AzureADGraph.IsGraphUserAccountEnabled(UserPrincipalName, IsEnabled);

        // [THEN] The user is not enabled
        LibraryAssert.IsFalse(IsEnabled, 'The user should not be enabled');

        TearDown();
    end;

    local procedure Initialize()
    begin
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService := true;

        Clear(AzureADGraph);
        Clear(AzureADGraphTestLibrary);
        Clear(MockGraphQueryTestLibrary);
        MockGraphQueryTestLibrary.SetupMockGraphQuery();
        AzureADGraphTestLibrary.SetMockGraphQuery(MockGraphQueryTestLibrary);
        BindSubscription(AzureADGraphTestLibrary);
    end;

    local procedure TearDown()
    begin
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService := false;
        UnbindSubscription(AzureADGraphTestLibrary);
    end;
}
