// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Azure.Identity;
using System.Environment.Configuration;
using System.Email;
using System.Apps;

entitlement "Dynamics 365 Admin - Partner"
{
    Type = Role;
    RoleType = Delegated;
    Id = '00000000-0000-0000-0000-000000000009';

#pragma warning disable AL0684
    ObjectEntitlements = "Application Objects - Exec",
                         "System Application - Basic",
                         "Azure AD Plan - Admin",
                         "Security Groups - Admin",
                         "Exten. Mgt. - Admin",
                         "Email - Admin",
                         "Feature Key - Admin";
#pragma warning restore
}
