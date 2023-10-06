// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.History;

using Microsoft.Warehouse.GateEntry;

pageextension 18613 "Posted Gate Entry Whse Rcpt" extends "Posted Whse. Receipt"
{
    actions
    {
        addlast("&Receipt")
        {
            action("Attached Gate Entry")
            {
                ApplicationArea = Basic, Suite;
                Image = InwardEntry;
                RunObject = Page "Posted Gate Attachment List";
                RunPageLink = "Entry Type" = const(Inward), "Warehouse Recpt. No." = field("Whse. Receipt No.");
                ToolTip = 'View attached gate entry list.';
            }
        }
    }
}
