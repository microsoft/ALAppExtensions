// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Warehouse.GateEntry;

pageextension 18605 "Gate Entry Sales Return Order" extends "Sales Return Order"
{
    layout
    {
        addlast("Foreign Trade")
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
            field("LR/RR No."; Rec."LR/RR No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the lorry receipt number of the document.';
            }
            field("LR/RR Date"; Rec."LR/RR Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the lorry receipt date.';
            }
        }
    }

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
                    GateEntryHandler.GetSalesGateEntryLines(Rec);
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
                RunPageLink = "Source Type" = const("Sales Return Order"), "Source No." = field("No.");
                ToolTip = 'View attached gate entry list.';
            }
        }
    }
}
