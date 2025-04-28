// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 20351 "Connectivity Apps - Read"
{
    Assignable = false;
    Access = Internal;
    Caption = 'Connectivity Apps - Read';

    IncludedPermissionSets = "Connectivity Apps - Objects";

    Permissions = tabledata "Connectivity App" = r,
                tabledata "Conn. App Country/Region" = r,
                tabledata "Connectivity App Description" = r,
                tabledata "Connectivity App Logo" = r;
}
