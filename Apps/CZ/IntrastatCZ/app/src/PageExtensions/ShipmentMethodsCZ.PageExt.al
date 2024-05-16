// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Shipping;

pageextension 31339 "Shipment Methods CZ" extends "Shipment Methods"
{
    layout
    {
        addafter(Description)
        {
            field("Intrastat Deliv. Grp. Code CZ"; Rec."Intrastat Deliv. Grp. Code CZ")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies the Intrastat Delivery Group Code.';
            }
            field("Incl. Item Charges (Amt.) CZ"; Rec."Incl. Item Charges (Amt.) CZ")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies whether additional cost of the item should be included in the Intrastat amount.';
                Visible = false;
            }
        }
    }
}