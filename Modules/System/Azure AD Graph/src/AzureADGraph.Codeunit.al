// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

using System;

/// <summary>
/// Exposes functionality to query Microsoft Entra.
/// </summary>
#pragma warning disable AS0018
codeunit 9012 "Azure AD Graph"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        [NonDebuggable]
        AzureADGraphImpl: Codeunit "Azure AD Graph Impl.";

    /// <summary>
    /// Gets the user with the specified user principal name from Microsoft Entra.
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
    /// Gets the current user from Microsoft Entra.
    /// </summary>
    /// <param name="UserInfo">The user to return.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetCurrentUser(var UserInfo: DotNet UserInfo)
    begin
        AzureADGraphImpl.GetCurrentUser(UserInfo);
    end;

    /// <summary>
    /// Gets the user with the specified authorization email from Microsoft Entra.
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
    /// Gets the user with the specified object ID from Microsoft Entra.
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
    /// Tries to return the user with the specified object ID from Microsoft Entra.
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
    /// Gets the assigned plans for the specified user from Microsoft Entra.
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
    /// Gets the roles assigned to the user from Microsoft Entra.
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
    /// Gets the directory roles from Microsoft Entra.
    /// </summary>
    /// <param name="DirectoryRoles">The directory roles to return.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetDirectoryRoles(var DirectoryRoles: DotNet GenericIEnumerable1)
    begin
        AzureADGraphImpl.GetDirectoryRoles(DirectoryRoles);
    end;

    /// <summary>
    /// Gets details about the tenant from Microsoft Entra.
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

#if not CLEAN22
    /// <summary>
    /// Gets the name of the Microsoft Entra security group defined in tenant admin center.
    /// For more info, see https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/tenant-admin-center-environments#manage-access-using-azure-active-directory-groups
    /// </summary>
    /// <returns>The name of the Microsoft Entra security group defined in tenant admin center.</returns>
    [Scope('OnPrem')]
    [NonDebuggable]
    [Obsolete('Renamed to GetEnvironmentSecurityGroupId()', '22.0')]
    procedure GetEnvironmentDirectoryGroup(): Text
    begin
        exit(AzureADGraphImpl.GetEnvironmentSecurityGroupId());
    end;
#endif

    /// <summary>
    /// Gets the name of the Microsoft Entra security group defined in tenant admin center.
    /// For more info, see https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/tenant-admin-center-environments#manage-access-using-azure-active-directory-groups
    /// </summary>
    /// <returns>The name of the Microsoft Entra security group defined in tenant admin center.</returns>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetEnvironmentSecurityGroupId(): Text
    begin
        exit(AzureADGraphImpl.GetEnvironmentSecurityGroupId());
    end;

    /// <summary>
    /// Returns if the Microsoft Entra security group is defined in tenant admin center.
    /// </summary>
    /// <returns>True if defined.</returns>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure IsEnvironmentSecurityGroupDefined(): Boolean
    begin
        exit(GetEnvironmentSecurityGroupId() <> '');
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
    /// <param name="AssignedPlans">The assigned plans (licenses) to filter to.</param>
    /// <param name="NumberOfUsers">The number of users per page to return.</param>
    /// <param name="UserInfoPage">The list of users to return.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetLicensedUsersPage(AssignedPlans: DotNet StringArray; NumberOfUsers: Integer; var UserInfoPage: DotNet UserInfoPage)
    begin
        AzureADGraphImpl.GetLicensedUsersPage(AssignedPlans, NumberOfUsers, UserInfoPage);
    end;

    /// <summary>
    /// Gets a list of users who are members of the specified Microsoft Entra group.
    /// </summary>
    /// <param name="GroupDisplayName">The name of the Microsoft Entra group.</param>
    /// <param name="GroupMembers">A list of UserInfo objects identifying users that are members of the specified group.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetGroupMembers(GroupDisplayName: Text; var GroupMembers: DotNet IEnumerable)
    begin
        AzureADGraphImpl.GetGroupMembers(GroupDisplayName, GroupMembers);
    end;

    /// <summary>
    /// Gets a list of users who are members of the specified Microsoft Entra group.
    /// </summary>
    /// <param name="GroupId">The object ID of the Microsoft Entra security group.</param>
    /// <param name="NumberOfUsers">The number of users per page to return.</param>
    /// <param name="UserInfoPage">A list of UserInfo objects identifying users that are members of the specified group.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetMembersPageForGroupId(GroupId: Text; NumberOfUsers: Integer; var UserInfoPage: DotNet UserInfoPage)
    begin
        AzureADGraphImpl.GetMembersPageForGroupId(GroupId, NumberOfUsers, UserInfoPage);
    end;

    /// <summary>
    /// Gets a list of user IDs of users who are members of the specified Microsoft Entra group.
    /// </summary>
    /// <param name="GroupId">The object ID of the Microsoft Entra security group.</param>
    /// <param name="NumberOfUsers">The number of user IDs per page to return.</param>
    /// <param name="UserInfoPage">A list of User ID objects identifying users that are members of the specified group.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetMemberIdsPageForGroupId(GroupId: Text; NumberOfUsers: Integer; var UserIdsPage: DotNet UserIdsPage)
    begin
        AzureADGraphImpl.GetMemberIdsPageForGroupId(GroupId, NumberOfUsers, UserIdsPage);
    end;

    /// <summary>
    /// Checks if a given user is a member of a Microsoft Entra security group.
    /// </summary>
    /// <param name="GroupDisplayName">The name of the Microsoft Entra security group.</param>
    /// <param name="GraphUserInfo">The user.</param>
    /// <returns>True if the user is member of the Microsoft Entra security group; otherwise - false.</returns>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure IsGroupMember(GroupDisplayName: Text; GraphUserInfo: DotNet UserInfo): Boolean
    begin
        exit(AzureADGraphImpl.IsGroupMember(GroupDisplayName, GraphUserInfo));
    end;

    /// <summary>
    /// Checks if a given user is a member of a Microsoft Entra security group.
    /// </summary>
    /// <param name="GroupId">The object ID of the Microsoft Entra security group.</param>
    /// <param name="GraphUserInfo">The user.</param>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure IsMemberOfGroupWithId(GroupId: Text; GraphUserInfo: DotNet UserInfo): Boolean
    begin
        exit(AzureADGraphImpl.IsMemberOfGroupWithId(GroupId, GraphUserInfo));
    end;

    /// <summary>
    /// Gets the group's display name
    /// </summary>
    /// <param name="GroupId">The object ID of the Microsoft Entra security group.</param>
    /// <returns>The display name of the group.</returns>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetGroupName(GroupId: Text): Text
    begin
        exit(AzureADGraphImpl.GetGroupName(GroupId));
    end;

    /// <summary>
    /// Gets the first Microsoft Entra group object ID that matches the provided display name.
    /// </summary>
    /// <param name="GroupName">The display name of the group.</param>
    /// <returns>The object ID of the Microsoft Entra security group.</returns>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetFirstGroupIdWithName(GroupName: Text): Text
    begin
        exit(AzureADGraphImpl.GetFirstGroupIdWithName(GroupName));
    end;

    /// <summary>
    /// Gets all of the Microsoft Entra security groups.
    /// </summary>
    /// <returns>A dictionary of group object ID and group display name.</returns>
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetGroups(): Dictionary of [Text, Text];
    begin
        exit(AzureADGraphImpl.GetGroups());
    end;

    /// <summary>
    /// Checks if the Microsoft 365 user account for the specified principal name is enabled.
    /// Note: Even if the graph user is enabled, the account may be disabled in Business Central.
    /// </summary>
    /// <param name="UserPrincipalName">The user principal name.</param>
    [Scope('OnPrem')]
    [TryFunction]
    [NonDebuggable]
    procedure IsGraphUserAccountEnabled(UserPrincipalName: Text; var IsEnabled: Boolean)
    begin
        AzureADGraphImpl.IsGraphUserAccountEnabled(UserPrincipalName, IsEnabled);
    end;
}
#pragma warning restore AS0018