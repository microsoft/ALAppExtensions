// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

using Microsoft.Warehouse.GateEntry;

pageextension 18610 "Posted Gate Entry Return Rcpt." extends "Posted Return Receipt"
{
    actions
    {
        addlast("&Return Rcpt.")
        {
            action("Attached Gate Entry")
            {
                ApplicationArea = Basic, Suite;
                Image = InwardEntry;
                RunObject = Page "Posted Gate Attachment List";
                RunPageLink = "Entry Type" = const(Inward), "Receipt No." = field("No.");
                ToolTip = 'View attached gate entry list.';
            }
        }
    }
}
