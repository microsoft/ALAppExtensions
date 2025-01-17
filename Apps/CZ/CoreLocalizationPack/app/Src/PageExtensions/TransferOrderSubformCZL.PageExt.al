// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

pageextension 31129 "Transfer Order Subform CZL" extends "Transfer Order Subform"
{
    layout
    {
        addafter("Reserved Quantity Outbnd.")
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
