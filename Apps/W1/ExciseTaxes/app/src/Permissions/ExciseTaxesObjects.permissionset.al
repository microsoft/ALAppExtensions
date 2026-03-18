// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

permissionset 7450 "ExciseTaxes - Objects"
{
    Caption = 'Excise Taxes - Objects';
    Access = Internal;
    Assignable = false;

    Permissions =
        table "Excise Tax Type" = X,
        table "Excise Tax Item/FA Rate" = X,
        table "Excise Tax Entry Permission" = X,
        page "Excise Tax Types" = X,
        page "Excise Tax Type Card" = X,
        page "Excise Tax Item/FA Rates" = X,
        page "Excise Tax Entry Permissions" = X,
        report "Create Excise Tax Jnl. Entries" = X;
}