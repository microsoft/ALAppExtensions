// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.StockTransfer;

using Microsoft.Inventory.Transfer;

pageextension 18394 "GST Posted Trans. Shipment Ext" extends "Posted Transfer Shipment"
{
    layout
    {
        addafter("Entry/Exit Point")
        {
            Field("Time of Removal"; Rec."Time of Removal")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the time of removal.';
            }
            field("Mode of Transport"; Rec."Mode of Transport")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the mode of transport used for transfer.';
            }
            field("Vehicle No."; Rec."Vehicle No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the vehicle no used for transfer.';
            }
            field("Vehicle Type"; Rec."Vehicle Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of vehicle used for transfer.';
            }
            field("LR/RR No."; Rec."LR/RR No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the lorry receipt number.';
            }
            field("LR/RR Date"; Rec."LR/RR Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the lorry receipt date.';
            }
            field("Distance (Km)"; Rec."Distance (Km)")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the distance of the the transfer route.';
            }
        }
    }
}
