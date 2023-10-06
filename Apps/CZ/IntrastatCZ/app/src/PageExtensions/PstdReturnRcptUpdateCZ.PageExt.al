// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Sales.History;

pageextension 31369 "Pstd. Return Rcpt. - Update CZ" extends "Posted Return Receipt - Update"
{
    layout
    {
        addlast(Shipping)
        {
            field("Physical Transfer CZ"; Rec."Physical Transfer CZ")
            {
                ApplicationArea = Suite;
                Editable = true;
                ToolTip = 'Specifies if there is physical transfer of the item.';
            }
        }
    }
}