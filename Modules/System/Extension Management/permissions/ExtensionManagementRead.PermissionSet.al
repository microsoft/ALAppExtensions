// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Apps;

using System.Environment;
using System.Environment.Configuration;

permissionset 2500 "Extension Management - Read"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Extension Management - Objects";

    Permissions = tabledata "Application Object Metadata" = r,
                  tabledata Media = r,
                  tabledata "NAV App Installed App" = r,
                  tabledata "NAV App Tenant Operation" = r,
                  tabledata "Published Application" = r,
                  tabledata "NAV App Setting" = r;
}