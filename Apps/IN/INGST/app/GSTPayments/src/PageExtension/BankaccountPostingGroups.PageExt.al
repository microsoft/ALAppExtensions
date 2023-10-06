// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.BankAccount;

pageextension 18257 "Bank Account Posting Groups" extends "Bank Account Posting Groups"
{
    layout
    {
        addlast(Control1)
        {
            field("GST Rounding Account"; Rec."GST Rounding Account")
            {
                ToolTip = 'Specifies the G/L account of rounding, for bank charges';
                ApplicationArea = Basic, Suite;
            }
        }

    }
}
