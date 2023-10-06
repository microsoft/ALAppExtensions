// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.History;

pageextension 18446 "GST Posted Service Ship Lines" extends "Posted Service Shipment Lines"
{
    layout
    {
        addafter("Shortcut Dimension 2 Code")
        {
            field("GST Group Code"; Rec."GST Group Code")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies an identifier for the GST Group  used to calculate and post GST.';
            }

            field("HSN/SAC Code"; Rec."HSN/SAC Code")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies an unique identifier for the type of HSN or SAC that is used to calculate and post GST.';
            }

            field("Non-GST Line"; Rec."Non-GST Line")
            {
                ApplicationArea = Basic, Suite;
                ToolTIp = 'Specifies whether the line item is applicable for GST or not.';
            }
        }
    }
}
