// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Environment;

permissionset 96 "Session - Edit"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Session - Read";

    Permissions = tabledata "Active Session" = IMD,
                  tabledata Session = imd,
                  tabledata "Session Event" = IMD;
}