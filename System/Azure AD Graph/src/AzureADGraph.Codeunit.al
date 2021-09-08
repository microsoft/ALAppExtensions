// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to query Azure AD.
/// </summary>
codeunit 9012 "Azure AD Graph"
{
    Access = Public;

    var
        [NonDebuggable]
        AzureADGraphImpl: Codeunit "Azure AD Graph Impl.";

    /// <summary>
    /// Gets the user with the specified user principal name from Azure AD.
    /// </summary>
    /// <param name="UserPrincipalName">The user principal name.</param>
    /// <param name="UserInfo">The user to return.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetUser(UserPrincipalName: Text; var UserInfo: DotNet UserInfo)
    begin
        AzureADGraphImpl.GetUser(UserPrincipalName, UserInfo);
    end;

    /// <summary>
    /// Gets the current user from Azure AD.
    /// </summary>
    /// <param name="UserInfo">The user to return.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetCurrentUser(var UserInfo: DotNet UserInfo)
    begin
        AzureADGraphImpl.GetCurrentUser(UserInfo);
    end;

    /// <summary>
    /// Gets the user with the specified authorization email from Azure AD.
    /// </summary>
    /// <param name="AuthorizationEmail">The user's authorization email.</param>
    /// <param name="UserInfo">The user to return.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetUserByAuthorizationEmail(AuthorizationEmail: Text; var UserInfo: DotNet UserInfo)
    begin
        AzureADGraphImpl.GetUserByAuthorizationEmail(AuthorizationEmail, UserInfo);
    end;

    /// <summary>
    /// Gets the user with the specified object ID from Azure AD.
    /// </summary>
    /// <param name="ObjectId">The object ID assigned to the user.</param>
    /// <param name="UserInfo">The user to return.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetUserByObjectId(ObjectId: Text; var UserInfo: DotNet UserInfo)
    begin
        AzureADGraphImpl.GetUserByObjectId(ObjectId, UserInfo);
    end;

    /// <summary>
    /// Tries to return the user with the specified object ID from Azure AD.
    /// </summary>
    /// <param name="ObjectId">The object ID assigned to the user.</param>
    /// <param name="UserInfo">The user to return.</param>
    /// <returns>A boolean that indicates whether the user was retrieved.</returns>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure TryGetUserByObjectId(ObjectId: Text; var UserInfo: DotNet UserInfo): Boolean
    begin
        exit(AzureADGraphImpl.TryGetUserByObjectId(ObjectId, UserInfo));
    end;

    /// <summary>
    /// Gets the assigned plans for the specified user from Azure AD.
    /// </summary>
    /// <param name="UserInfo">The user.</param>
    /// <param name="UserAssignedPlans">The assigned plans for the user.</param>
    /// <remarks>If the provided user is null, the output parameter holding the assigned plans remains unchanged.</remarks> 
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetUserAssignedPlans(UserInfo: DotNet UserInfo; var UserAssignedPlans: DotNet GenericList1)
    begin
        AzureADGraphImpl.GetUserAssignedPlans(UserInfo, UserAssignedPlans);
    end;

    /// <summary>
    /// Gets the roles assigned to the user from Azure AD.
    /// </summary>
    /// <param name="UserInfo">The user for whom to retrieve the roles.</param>
    /// <param name="UserRoles">The user's roles.</param>
    /// <remarks>If the provided user is null, the output parameter holding the user roles remains unchanged.</remarks>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetUserRoles(UserInfo: DotNet UserInfo; var UserRoles: DotNet GenericIEnumerable1)
    begin
        AzureADGraphImpl.GetUserRoles(UserInfo, UserRoles);
    end;

    /// <summary>
    /// Gets the list of subscriptions owned by the tenant.
    /// </summary>
    /// <param name="DirectorySubscribedSkus">The list of subscriptions to return.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetDirectorySubscribedSkus(var DirectorySubscribedSkus: DotNet GenericIEnumerable1)
    begin
        AzureADGraphImpl.GetDirectorySubscribedSkus(DirectorySubscribedSkus);
    end;

    /// <summary>
    /// Gets the directory roles from Azure AD.
    /// </summary>
    /// <param name="DirectoryRoles">The directory roles to return.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetDirectoryRoles(var DirectoryRoles: DotNet GenericIEnumerable1)
    begin
        AzureADGraphImpl.GetDirectoryRoles(DirectoryRoles);
    end;

    /// <summary>
    /// Gets details about the tenant from Azure AD.
    /// </summary>
    /// <param name="TenantInfo">The tenant details to return.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetTenantDetail(var TenantInfo: DotNet TenantInfo)
    begin
        AzureADGraphImpl.GetTenantDetail(TenantInfo);
    end;

    /// <summary>
    /// Gets a list of users.
    /// </summary>
    /// <param name="NumberOfUsers">The number of users to return.</param>
    /// <param name="UserInfoPage">The list of users to return.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetUsersPage(NumberOfUsers: Integer; var UserInfoPage: DotNet UserInfoPage)
    begin
        AzureADGraphImpl.GetUsersPage(NumberOfUsers, UserInfoPage);
    end;

    /// <summary>
    /// Sets a flag that is used to determine whether a test is in progress or not.
    /// </summary>
    /// <param name="TestInProgress">The value to be set to the flag.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure SetTestInProgress(TestInProgress: Boolean)
    begin
        AzureADGraphImpl.SetTestInProgress(TestInProgress);
    end;

    /// <summary>
    /// Publishes an event that is used to initialize the Azure AD Graph.
    /// </summary>
    /// <param name="GraphQuery">The graph that the Azure AD Graph will be initialized with.</param>
    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    [NonDebuggable]
    internal procedure OnInitialize(var GraphQuery: DotNet GraphQuery)
    begin

    end;

}

