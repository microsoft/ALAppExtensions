// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.History;

using Microsoft.Warehouse.GateEntry;

pageextension 18608 "Posted Gate Entry Purch. Rcpt." extends "Posted Purchase Receipt"
{
    layout
    {
        addlast(General)
        {
            field("Vehicle No."; Rec."Vehicle No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the vehicle number.';
            }
            field("Vehicle Type"; Rec."Vehicle Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of vehicle.';
            }
        }
    }

    actions
    {
        addlast("&Receipt")
        {
            action("Attached Gate Entry")
            {
                ApplicationArea = Basic, Suite;
                Image = InwardEntry;
                RunObject = page "Posted Gate Attachment List";
                RunPageLink = "Entry Type" = const(Inward), "Receipt No." = field("No.");
                ToolTip = 'View attached gate entry list.';
            }
        }
    }
}
