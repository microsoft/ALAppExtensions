// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Environment;
using System.Diagnostics;

permissionset 95 "Session - Read"
{
    Access = Public;
    Assignable = false;

    Permissions = tabledata "Active Session" = R,
                  tabledata "Database Locks" = R,
                  tabledata "Server Instance" = R,
                  tabledata Session = R,
                  tabledata "Session Event" = R;
}