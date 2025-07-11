// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

using Microsoft.Warehouse.GateEntry;

pageextension 18612 "Posted Gate Entry Transfr Rcpt" extends "Posted Transfer Receipt"
{
    actions
    {
        addlast("&Receipt")
        {
            action("Attached Gate Entry")
            {
                ApplicationArea = Basic, Suite;
                Image = InwardEntry;
                RunObject = page "Posted Gate Attachment List";
                RunPageLink = "Source Type" = const("Transfer Receipt"), "Entry Type" = const(Inward), "Receipt No." = field("No.");
                ToolTip = 'View attached gate entry list.';
            }
        }
    }
}
