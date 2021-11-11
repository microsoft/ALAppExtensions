// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9216 "Time Zone Selection - Read"
{
    Assignable = false;

    IncludedPermissionSets = "Time Zone Selection - Objects";

    Permissions = tabledata "Page Data Personalization" = r,
                  tabledata "Time Zone" = r;
}