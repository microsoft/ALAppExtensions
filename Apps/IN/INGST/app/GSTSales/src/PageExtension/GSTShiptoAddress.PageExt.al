// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

pageextension 18158 "GST Ship-to Address" extends "Ship-to Address"
{
    layout
    {
        addlast(General)
        {
            field(State; Rec.State)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the state code of Ship to Address';
            }
            field("GST Registration No."; Rec."GST Registration No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Vendors GST Reg. No. issues by Authorized body for Ship to Address.';
            }
            field("ARN No."; Rec."ARN No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the ARN No. of the Ship to Address until the GST Registration No. is not assigned.';
            }
            field(Consignee; Rec.Consignee)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the Ship to Address is defiened as consignee.';
            }
            field("Ship-to GST Customer Type"; Rec."Ship-to GST Customer Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of Ship-to GST Customer Type for the Ship to Address. For example Registered/Sez/Deemed Export';
            }
        }
    }
}
