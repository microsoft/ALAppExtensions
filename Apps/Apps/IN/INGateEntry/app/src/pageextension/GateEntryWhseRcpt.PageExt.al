// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.Document;

using Microsoft.Warehouse.GateEntry;

pageextension 18607 "Gate Entry Whse Rcpt" extends "Whse. Receipt Subform"
{
    actions
    {
        addlast("&Line")
        {
            action("Get Gate Entry Lines")
            {
                ApplicationArea = Basic, Suite;
                Image = GetLines;
                ToolTip = 'View available gate entry lines for attachment.';
                trigger OnAction()
                var
                    GateEntryHandler: Codeunit "Gate Entry Handler";
                begin
                    GateEntryHandler.GetWarehouseGateEntryLines(Rec);
                end;
            }
        }
        addlast("&Line")
        {
            action("Attached Gate Entry")
            {
                ApplicationArea = Basic, Suite;
                Image = InwardEntry;
                RunObject = page "Gate Entry Attachment List";
                RunPageLink = "Entry Type" = const(Inward), "Warehouse Recpt. No." = field("No.");
                ToolTip = 'View attached gate entry list.';
            }
        }
    }
}
