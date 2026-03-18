// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

permissionset 7453 "ExciseTaxes - Admin"
{
    Caption = 'Excise Taxes - Admin';
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "ExciseTaxes - Edit";
}