// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Azure.Identity;

entitlement "Dynamics 365 Business Central Premium"
{
    Type = PerUserServicePlan;
    Id = '8e9002c0-a1d8-4465-b952-817d2948e6e2';

#pragma warning disable AL0684
    ObjectEntitlements = "Application Objects - Exec",
                         "Azure AD Plan - Admin",
                         "Security Groups - Admin",
                         "System Application - Admin";
#pragma warning restore
}
