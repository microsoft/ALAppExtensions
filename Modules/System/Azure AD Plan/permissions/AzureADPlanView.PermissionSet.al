// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 9018 "Azure AD Plan - View"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Azure AD Plan - Read",
                             "Upgrade Tags - View",
                             "Telemetry - Exec";

    Permissions = tabledata Plan = imd,
                  tabledata "User Plan" = imd;
}
