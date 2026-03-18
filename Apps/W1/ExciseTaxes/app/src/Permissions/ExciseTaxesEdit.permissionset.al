// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

permissionset 7452 "ExciseTaxes - Edit"
{
    Caption = 'Excise Taxes - Edit';
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "ExciseTaxes - Read";

    Permissions =
        tabledata "Excise Tax Type" = IMD,
        tabledata "Excise Tax Item/FA Rate" = IMD,
        tabledata "Excise Tax Entry Permission" = IMD;
}