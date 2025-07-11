// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

pageextension 18096 "GST Order Address" extends "Order Address"
{
    layout
    {
        addafter("Last Date Modified")
        {
            field(State; Rec.State)
            {
                ToolTip = 'Specifies the state code of Order Address';
                ApplicationArea = Basic, Suite;
            }
            field("GST Registration No."; Rec."GST Registration No.")
            {
                ToolTip = 'Specifies the Vendor GST Reg. No. issues by Authorized body for Order Address.';
                ApplicationArea = Basic, Suite;
            }
            field("ARN No."; Rec."ARN No.")
            {
                ToolTip = 'Specifies the ARN No. of the Order Address until the GST Registration No. is not assigned.';
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
