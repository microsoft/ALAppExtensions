// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

using Microsoft.Inventory.Item;

pageextension 7415 "Excise Item Card Ext" extends "Item Card"
{
    layout
    {
        addafter(Sustainability)
        {
            group("Excise Tax")
            {
                Caption = 'Excise Tax';
                field("Excise Tax Type"; Rec."Excise Tax Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which excise tax type applies to this item.';
                }
                field("Quantity for Excise Tax"; Rec."Quantity for Excise Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount per unit based on tax basis.';
                }
                field("Excise Unit of Measure Code"; Rec."Excise Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure for tax basis.';
                }
            }
        }
    }
}