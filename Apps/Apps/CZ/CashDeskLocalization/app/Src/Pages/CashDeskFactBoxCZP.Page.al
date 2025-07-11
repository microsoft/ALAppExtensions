// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using System.Security.User;

page 31153 "Cash Desk FactBox CZP"
{
    Caption = 'Cash Desk';
    PageType = CardPart;
    SourceTable = "Cash Desk CZP";

    layout
    {
        area(content)
        {
            field("No."; Rec."No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of the cash desk.';
            }
            field(CalcBalance; Rec.CalcBalance())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Statistics';
                ToolTip = 'Specifies the total receipts and withdrawals in cash desk.';
            }
            field(Balance; Rec.Balance)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cash desk card''s current balance denominated in the applicable foreign currency.';
            }
            field("Debit Amount"; Rec."Debit Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the total amount that the cash desk consists of, if it is a debit amount.';
            }
            field("Credit Amount"; Rec."Credit Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cash desk card''s current balance denominated in the applicable foreign currency.';
            }
            field("Balance (LCY)"; Rec."Balance (LCY)")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cash desk card''s current balance. The amount is in the local currency.';
            }
            field("Debit Amount (LCY)"; Rec."Debit Amount (LCY)")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the total amount that the cash desk consists of, if it is a debit amount. The amount is in the local currency.';
            }
            field("Credit Amount (LCY)"; Rec."Credit Amount (LCY)")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the total amount that the cash desk consists of, if it is a credit amount. The amount is in the local currency.';
            }
            field("Cashier No."; Rec."Cashier No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cashier number from employee list.';
            }
            field("Responsibility ID (Release)"; Rec."Responsibility ID (Release)")
            {
                ApplicationArea = Basic, Suite;
                LookupPageID = "User Lookup";
                ToolTip = 'Specifies the responsibility ID for release from employee list.';
            }
            field("Responsibility ID (Post)"; Rec."Responsibility ID (Post)")
            {
                ApplicationArea = Basic, Suite;
                LookupPageID = "User Lookup";
                ToolTip = 'Specifies the responsibility ID for posting from employee list.';
            }
        }
    }
}
