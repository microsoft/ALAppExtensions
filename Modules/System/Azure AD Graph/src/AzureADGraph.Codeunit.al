// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to query Azure AD.
/// </summary>
#pragma warning disable AS0018
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
    /// Gets the value of whether M365 collaboration is enabled.
    /// </summary>
    /// <returns>True, if M365 collaboration is enabled, false otherwise.</returns>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure IsM365CollaborationEnabled(): Boolean
    begin
        exit(AzureADGraphImpl.IsM365CollaborationEnabled());
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
    /// Gets a list of licensed users.
    /// </summary>
    /// <param name="AssingedPlans">The assigned plans (licenses) to filter to.</param>
    /// <param name="NumberOfUsers">The number of users to return.</param>
    /// <param name="UserInfoPage">The list of users to return.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetLicensedUsersPage(AssingedPlans: DotNet StringArray; NumberOfUsers: Integer; var UserInfoPage: DotNet UserInfoPage)
    begin
        AzureADGraphImpl.GetLicensedUsersPage(AssingedPlans, NumberOfUsers, UserInfoPage);
    end;

    /// <summary>
    /// Gets a list of users who are members of the specified AAD group.
    /// </summary>
    /// <param name="GroupDisplayName">The name of the AAD group.</param>
    /// <param name="GroupMembers">A list of UserInfo objects identifying users that are members of the specified group.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetGroupMembers(GroupDisplayName: Text; var GroupMembers: DotNet IEnumerable)
    begin
        AzureADGraphImpl.GetGroupMembers(GroupDisplayName, GroupMembers);
    end;
}
#pragma warning restore AS0018