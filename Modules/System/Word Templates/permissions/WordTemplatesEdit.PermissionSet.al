// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9987 "Word Templates - Edit"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Word Templates - Read";

    Permissions = tabledata "Word Template" = IMD,
                  tabledata "Word Templates Table" = imd,
                  tabledata "Word Templates Related Table" = imd;
}