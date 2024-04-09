// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

permissionset 5011 "Serv. Decl. - Edit"
{
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "Serv. Decl. - Read";

    Permissions = tabledata "Service Declaration Setup" = IMD,
                  tabledata "Service Transaction Type" = IMD,
                  tabledata "Service Declaration Header" = IMD,
                  tabledata "Service Declaration Line" = IMD,
                  tabledata "Service Declaration Buffer" = IMD;
}
