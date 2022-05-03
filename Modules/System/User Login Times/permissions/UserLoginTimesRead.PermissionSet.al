// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 9008 "User Login Times - Read"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "User Login Times - Objects";

    Permissions = tabledata "User Environment Login" = r,
                  tabledata "User Login" = r;
}
