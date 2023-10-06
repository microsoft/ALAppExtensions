// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Pricing;

pageextension 18012 "GST Service Costs Ext" extends "Service Costs"
{
    layout
    {
        addlast(Control1)
        {
            field("GST Group Code"; Rec."GST Group Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies an unique identifier for the GST group code used to calculate and post GST.';
            }
            field("GST Credit Availment"; Rec."GST Credit Availment")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the GST credit has to be availed or not.';
            }
            field("HSN/SAC Code"; Rec."HSN/SAC Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies an unique identifier for the type of HSN or SAC that is used to calculate and post GST.';
            }
            field(Exempted; Rec.Exempted)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the service cost is exempted from GST or not.';
            }
        }
    }
}
