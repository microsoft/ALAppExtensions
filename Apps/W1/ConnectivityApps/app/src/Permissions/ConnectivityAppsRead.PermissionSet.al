// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 20351 "Connectivity Apps - Read"
{
    Assignable = false;
    Access = Internal;
    Caption = 'Connectivity Apps - Read';

    IncludedPermissionSets = "Connectivity Apps - Objects";

    Permissions = tabledata "Connectivity App" = r,
                tabledata "Connectivity App Country" = r,
                tabledata "Connectivity App Description" = r,
                tabledata "Connectivity App Logo" = r;
}
