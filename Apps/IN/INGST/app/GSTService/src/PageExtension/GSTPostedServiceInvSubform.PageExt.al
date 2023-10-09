// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.History;

pageextension 18452 "GST Posted Service Inv Subform" extends "Posted Service Invoice Subform"
{
    layout
    {
        addafter("Appl.-to Item Entry")
        {
            field("GST Place Of Supply"; Rec."GST Place Of Supply")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies on which location state code system should consider for GST calculation in case of sale of product or service.';
            }
            field("GST Group Code"; Rec."GST Group Code")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies an identifier for the GST Group  used to calculate and post GST.';
            }
            field("GST Group Type"; Rec."GST Group Type")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies that the GST Group assigned for goods or service.';
            }
            field("HSN/SAC Code"; Rec."HSN/SAC Code")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies an unique identifier for the type of HSN or SAC that is used to calculate and post GST.';
            }
            field("GST Jurisdiction Type"; Rec."GST Jurisdiction Type")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                Tooltip = 'Specifies the entries related to gst jurisdiction, for example interstate or intrastate.';
            }
            field("Non-GST Line"; Rec."Non-GST Line")
            {
                ApplicationArea = Basic, Suite;
                ToolTIp = 'Specifies whether the line item is applicable for GST or not.';
            }
        }
    }
}
