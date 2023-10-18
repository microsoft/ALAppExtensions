// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Azure.Identity;

entitlement "Dynamics 365 Business Central Essential - Embedded"
{
    Type = PerUserServicePlan;
    Id = '8bb56cea-3f11-4647-854a-212e2b05306a';

#pragma warning disable AL0684
    ObjectEntitlements = "Application Objects - Exec",
                         "Azure AD Plan - Admin",
                         "Security Groups - Admin",
                         "System Application - Admin";
#pragma warning restore
}
