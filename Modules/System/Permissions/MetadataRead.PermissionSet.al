// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Reflection;
using System.DataAdministration;
using System.Utilities;
using System.Environment.Configuration;
using System.DateTime;
using System.Globalization;

permissionset 87 "Metadata - Read"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Field Selection - Read",
                             "Object Selection - Read",
                             "Table Information - Read";

    Permissions = tabledata "All Profile" = R,
                  tabledata AllObj = R,
                  tabledata "CodeUnit Metadata" = R,
                  tabledata Date = R,
                  tabledata "Object Metadata" = R,
                  tabledata "Page Documentation" = R,
                  tabledata "Page Metadata" = R,
                  tabledata "Profile Configuration Symbols" = R,
                  tabledata "Query Metadata" = R,
                  tabledata "Report Metadata" = R,
                  tabledata "System Object" = R,
                  tabledata "Table Metadata" = R,
#pragma warning disable AL0432
                  tabledata "Tenant Profile" = R,
#pragma warning restore AL0432
                  tabledata "Tenant Profile Extension" = R,
#pragma warning disable AL0432
                  tabledata "Tenant Profile Page Metadata" = R,
#pragma warning restore AL0432
                  tabledata "Tenant Profile Setting" = R,
                  tabledata "Time Zone" = R,
                  tabledata "Windows Language" = R;
}
