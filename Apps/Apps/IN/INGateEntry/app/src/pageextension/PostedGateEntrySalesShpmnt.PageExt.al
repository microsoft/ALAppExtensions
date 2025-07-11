// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

using Microsoft.Warehouse.GateEntry;

pageextension 18611 "Posted Gate Entry Sales Shpmnt" extends "Posted Sales Shipment"
{
    layout
    {
        addlast(Shipping)
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
        addlast("&Shipment")
        {
            action("Attached Gate Entry")
            {
                ApplicationArea = Basic, Suite;
                Image = InwardEntry;
                RunObject = page "Outward Gate Entry Line List";
                RunPageLink = "Entry Type" = const(Outward), "Source Type" = const("Sales Shipment"), "Source No." = field("No.");
                ToolTip = 'View attached gate entry list.';
            }
        }
    }
}
