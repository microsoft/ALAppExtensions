// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Purchases.History;

pageextension 31368 "Pstd. P. Cr.Memo - Update CZ" extends "Pstd. Purch. Cr.Memo - Update"
{
    layout
    {
        addafter("Cr. Memo Details")
        {
            group(Shipping)
            {
                Caption = 'Shipping';
                field("Physical Transfer CZ"; Rec."Physical Transfer CZ")
                {
                    ApplicationArea = Suite;
                    Editable = true;
                    ToolTip = 'Specifies if there is physical transfer of the item.';
                }
            }
        }
    }
}