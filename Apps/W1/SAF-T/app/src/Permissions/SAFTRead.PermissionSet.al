// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

permissionset 5281 "SAF-T - Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "SAF-T Objects";

    Permissions = tabledata "Source Code SAF-T" = R,
                  tabledata "Missing Field SAF-T" = R;
}
