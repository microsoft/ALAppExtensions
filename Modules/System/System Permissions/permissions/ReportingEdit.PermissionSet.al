// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Reflection;
using System.Environment.Configuration;

permissionset 99 "Reporting - Edit"
{
    Access = Public;
    Assignable = false;

#pragma warning disable AL0432 // Disabling deprecation warning since these tables are being moved on prem and hence still need permissions
    Permissions = tabledata "Report Layout" = RIMD,
#pragma warning restore AL0432
                  tabledata "Report Layout Definition" = R,
                  tabledata "Tenant Report Layout" = RIMD,
                  tabledata "Tenant Report Layout Selection" = RIMD;
}
