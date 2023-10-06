// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

permissionset 5280 "SAF-T - Edit"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "SAF-T - Read";

    Permissions = tabledata "Source Code SAF-T" = IMD,
                  tabledata "Missing Field SAF-T" = IMD;
}
