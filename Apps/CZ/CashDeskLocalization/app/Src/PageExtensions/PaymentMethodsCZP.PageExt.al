// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.BankAccount;

pageextension 31154 "Payment Methods CZP" extends "Payment Methods"
{
    layout
    {
        addlast(Control1)
        {
            field("Cash Desk Code CZP"; Rec."Cash Desk Code CZP")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies cash desk code for automatically cash document creation.';
            }
            field("Cash Document Action CZP"; Rec."Cash Document Action CZP")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies which cash document action will be performed automatically after cash document creation.';
            }

        }
    }
}
