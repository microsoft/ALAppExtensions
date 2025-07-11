// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 20350 "Connectivity Apps - Edit"
{
    Assignable = false;
    Access = Internal;
    Caption = 'Connectivity Apps - Edit';

    IncludedPermissionSets = "Connectivity Apps - Read";

    Permissions = tabledata "Connectivity App Logo" = imd;
}
