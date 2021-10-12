// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2133 "INVT-POSTED TRANSFER"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read posted transfer orders';

    IncludedPermissionSets = "Inventory Transfer - Read";
}
