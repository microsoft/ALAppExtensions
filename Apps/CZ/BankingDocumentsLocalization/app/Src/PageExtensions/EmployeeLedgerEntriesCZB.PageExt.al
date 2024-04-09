// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.HumanResources.Payables;

pageextension 31282 "Employee Ledger Entries CZB" extends "Employee Ledger Entries"
{
    layout
    {
        addafter("Remaining Amt. (LCY)")
        {
            field("Amount on Pmt. Order (LCY) CZB"; Rec."Amount on Pmt. Order (LCY) CZB")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the amount on payment order.';
                Visible = false;
            }
        }
    }
}
