// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 9258 "INVT-ITEM REGISTER"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read item registers';
    
    IncludedPermissionSets = "Inventory Registers - Read";
}
