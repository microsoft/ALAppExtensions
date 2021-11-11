// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2715 "Page Summary Provider - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Page Summary Provider - Obj.";

    Permissions = tabledata "Page Metadata" = r,
                  tabledata "Tenant Media Thumbnails" = r,
                  tabledata "Page Data Personalization" = R, // DotNet NavPageSummaryALFunctions requires this
                  tabledata "Tenant Media Set" = r;
}