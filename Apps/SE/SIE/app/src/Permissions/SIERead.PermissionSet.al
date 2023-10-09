// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

permissionset 5314 "SIE - Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "SIE - Objects";

    Permissions = tabledata "Import Buffer SIE" = R,
                  tabledata "Dimension SIE" = R;
}
