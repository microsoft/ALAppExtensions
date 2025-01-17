// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Ledger;

pageextension 31257 "Item Ledger Entries CZA" extends "Item Ledger Entries"
{
    layout
    {
        addbefore("Entry No.")
        {
            field("Source No. CZA"; Rec."Source No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies where the entry originated.';
                Visible = false;
            }
            field("Invoice-to Source No. CZA"; Rec."Invoice-to Source No. CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies where the entry originated';
                Visible = false;
            }
            field("Delivery-to Source No. CZA"; Rec."Delivery-to Source No. CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies where the entry originated';
                Visible = false;
            }
        }
    }
}
