// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 9016 "Azure AD Plan - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Azure AD Plan - Objects",
                             "User Login Times - Read",
                             "Azure AD User - View",
                             "Upgrade Tags - Read";

    Permissions = tabledata Company = r,
                  tabledata Plan = r,
                  tabledata User = r,
                  tabledata "User Plan" = r,
                  tabledata "Access Control" = r,
                  tabledata "Custom Permission Set In Plan" = r,
                  tabledata "Plan Configuration" = r;
}
