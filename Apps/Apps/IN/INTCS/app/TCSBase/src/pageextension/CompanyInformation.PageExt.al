// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Company;

pageextension 18807 "Company Information" extends "Company Information"
{
    layout
    {
        addafter("Ministry Code")
        {
            field("Circle No."; Rec."Circle No.")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Circle No.';
                ToolTip = 'Specifies the TAN Circle Number of the address from where TCS return is filed.';
            }
            field("Assessing Officer"; Rec."Assessing Officer")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Assessing Officer';
                ToolTip = 'Specifies the TAN Assessing Officer under whose jurisdiction the company falls.';
            }
            field("Ward No."; Rec."Ward No.")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Ward No.';
                ToolTip = 'Specifies TAN Ward number which is the identification number of the income tax authority where returns are filed.';
            }
        }
        addlast("Tax Information")
        {
            field("T.C.A.N No."; Rec."T.C.A.N. No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the T.C.A.N No of Company';
            }
        }
    }
}
