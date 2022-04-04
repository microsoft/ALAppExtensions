// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 9004 "Azure AD Plan - Admin"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Azure AD Plan - View";

    Permissions = tabledata "Access Control" = ri,
                  tabledata "Custom Permission Set In Plan" = imd,
                  tabledata "Plan Configuration" = imd;
}
