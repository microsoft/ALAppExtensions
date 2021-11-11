// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1470 "Video - Read"
{
    Assignable = false;

    IncludedPermissionSets = "Video - Objects";

    Permissions = tabledata "Page Data Personalization" = R, // Page.Run requires this
                  tabledata "Product Video Buffer" = r;
}