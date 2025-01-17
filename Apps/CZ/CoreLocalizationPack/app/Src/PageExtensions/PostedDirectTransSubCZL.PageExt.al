// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

pageextension 31226 "Posted Direct Trans. Sub. CZL" extends "Posted Direct Transfer Subform"
{
    layout
    {
        addafter(Quantity)
        {
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
            }
            field("Net Weight CZL"; Rec."Net Weight")
            {
                ApplicationArea = Location;
                ToolTip = 'Specifies the net weight of the item.';
                Visible = false;
            }
        }
    }
}
