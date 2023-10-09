// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

permissionset 5315 "SIE - Edit"
{
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "SIE - Read";

    Permissions = tabledata "Import Buffer SIE" = IMD,
                  tabledata "Dimension SIE" = IMD;
}
