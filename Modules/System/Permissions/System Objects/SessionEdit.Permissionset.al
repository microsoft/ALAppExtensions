// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 96 "Session - Edit"
{
    Access = Public;
    Assignable = False;

    IncludedPermissionSets = "Session - Read";

    Permissions = tabledata "Active Session" = IMD,
                  tabledata Session = imd,
                  tabledata "Session Event" = IMD;
}