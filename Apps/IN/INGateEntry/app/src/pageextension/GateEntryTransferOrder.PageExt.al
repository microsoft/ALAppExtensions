// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

using Microsoft.Warehouse.GateEntry;

pageextension 18606 "Gate Entry Transfer Order" extends "Transfer Order"
{
    actions
    {
        addlast("F&unctions")
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
                    GateEntryHandler.GetTransferGateEntryLines(Rec);
                end;
            }
        }
        addlast(Warehouse)
        {
            action("Attached Gate Entry")
            {
                ApplicationArea = Basic, Suite;
                Image = InwardEntry;
                RunObject = page "Gate Entry Attachment List";
                RunPageLink = "Source Type" = const("Transfer Receipt"), "Entry Type" = const(Inward), "Source No." = field("No.");
                ToolTip = 'View attached gate entry list.';
            }
        }
    }
}
