// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

permissionset 5260 "Audit Export - Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Audit Export - Objects";

    Permissions = tabledata "Audit File Export Setup" = R,
                  tabledata "Audit File Export Format Setup" = R,
                  tabledata "Audit Export Data Type Setup" = R,
                  tabledata "Audit File Export Header" = R,
                  tabledata "Audit File Export Line" = R,
                  tabledata "Audit File" = R,
                  tabledata "Standard Account" = R,
                  tabledata "Standard Account Category" = R,
                  tabledata "G/L Account Mapping Header" = R,
                  tabledata "G/L Account Mapping Line" = R;
}
