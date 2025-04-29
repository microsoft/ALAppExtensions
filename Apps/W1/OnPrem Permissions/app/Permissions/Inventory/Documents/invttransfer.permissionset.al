// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 9715 "INVT-TRANSFER"
{
    Access = Public;
    Assignable = true;
    Caption = 'Create transfer orders';

    IncludedPermissionSets = "Inventory Transfer - Edit";
}
