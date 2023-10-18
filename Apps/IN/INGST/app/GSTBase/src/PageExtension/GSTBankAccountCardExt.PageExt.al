// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.BankAccount;

pageextension 18001 "GST Bank Account Card Ext" extends "Bank Account Card"
{
    layout
    {
        addlast(Posting)
        {
            group("GST")
            {
                field("State Code"; Rec."State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the state code of the bank.';
                }
                field("GST Registration Status"; Rec."GST Registration Status")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Registration Status of the bank.';
                }
                field("GST Registration No."; Rec."GST Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Registration number of the bank.';
                }
                field("IFSC Code"; Rec."IFSC Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the IFSC Code of the bank.';
                }
            }
        }
    }
}
