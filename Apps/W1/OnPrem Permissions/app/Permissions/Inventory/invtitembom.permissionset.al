// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 9347 "INVT-ITEM/BOM"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read items/BOMs/SKUs/entries';

    IncludedPermissionSets = "Inventory - View";
}
