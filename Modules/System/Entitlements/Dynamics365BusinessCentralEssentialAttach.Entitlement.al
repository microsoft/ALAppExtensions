// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Azure.Identity;

entitlement "Dynamics 365 Business Central Essential - Attach"
{
    Type = PerUserServicePlan;
    Id = '17ca446c-d7a4-4d29-8dec-8e241592164b';

#pragma warning disable AL0684
    ObjectEntitlements = "Application Objects - Exec",
                         "Azure AD Plan - Admin",
                         "Security Groups - Admin",
                         "System Application - Admin";
#pragma warning restore
}
