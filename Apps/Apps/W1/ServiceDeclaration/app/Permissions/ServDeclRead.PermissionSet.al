// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

permissionset 5010 "Serv. Decl. - Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Serv. Decl. - Objects";

    Permissions = tabledata "Service Declaration Setup" = R,
                  tabledata "Service Transaction Type" = R,
                  tabledata "Service Declaration Header" = R,
                  tabledata "Service Declaration Line" = R,
                  tabledata "Service Declaration Buffer" = R;
}
