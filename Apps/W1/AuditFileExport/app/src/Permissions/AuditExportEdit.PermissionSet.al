// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

permissionset 5261 "Audit Export - Edit"
{
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "Audit Export - Read";

    Permissions = tabledata "Audit File Export Setup" = IMD,
                  tabledata "Audit File Export Format Setup" = IMD,
                  tabledata "Audit Export Data Type Setup" = IMD,
                  tabledata "Audit File Export Header" = IMD,
                  tabledata "Audit File Export Line" = IMD,
                  tabledata "Audit File" = IMD,
                  tabledata "Standard Account" = IMD,
                  tabledata "Standard Account Category" = IMD,
                  tabledata "G/L Account Mapping Header" = IMD,
                  tabledata "G/L Account Mapping Line" = IMD;
}
