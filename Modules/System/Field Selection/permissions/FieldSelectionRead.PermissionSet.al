// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9806 "Field Selection - Read"
{
    Assignable = false;

    IncludedPermissionSets = "Field Selection - Objects";

    Permissions = tabledata "Page Data Personalization" = R, // Page.Run requires this
                  tabledata Field = r;
}