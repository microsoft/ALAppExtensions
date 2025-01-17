// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

page 31242 "Search Rule Subform CZB"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Search Rule Line CZB";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description line of the rule.';
                    Width = 100;
                }
                field("Banking Transaction Type"; Rec."Banking Transaction Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Defines restrictions on the type of bank transaction. Values can be + (credit), - (debit), or both (no resolution).';
                }
                field("Search Scope"; Rec."Search Scope")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies which logical part of a row is valid for finding an entry to match.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether to consider a bank account number for automatically applying a payment to an open record.';
                }
                field("Variable Symbol"; Rec."Variable Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether to consider a variable symbol to automatically apply a payment to an open record.';
                }
                field("Constant Symbol"; Rec."Constant Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether to consider a constant symbol to automatically apply a payment to an open record.';
                }
                field("Specific Symbol"; Rec."Specific Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether to consider a specific symbol to automatically apply a payment to an open record.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether to consider the amount (including payment tolerance) for automatically applying a payment to an open record.';
                }
                field("Multiple Result"; Rec."Multiple Result")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'In the case of multiple search results, determines which record to select for automatic payment applying.';
                }
                field("Match Related Party Only"; Rec."Match Related Party Only")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the match related party only';
                }
                field("Description Filter"; Rec."Description Filter")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction description filter from the bank statement. If the system finds a match in the bank statement line based on the specified filters, then the account type and account number from the rule line are entered in the financial journal line.';
                }
                field("Variable Symbol Filter"; Rec."Variable Symbol Filter")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction variable symbol filter from the bank statement. If the system finds a match in the bank statement line based on the specified filters, then the account type and account number from the rule line are entered in the financial journal line.';
                }
                field("Constant Symbol Filter"; Rec."Constant Symbol Filter")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction constant symbol filter from the bank statement. If the system finds a match in the bank statement line based on the specified filters, then the account type and account number from the rule line are entered in the financial journal line.';
                }
                field("Specific Symbol Filter"; Rec."Specific Symbol Filter")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction specific symbol filter from the bank statement. If the system finds a match in the bank statement line based on the specified filters, then the account type and account number from the rule line are entered in the financial journal line.';
                }
                field("Bank Account Filter"; Rec."Bank Account Filter")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction Account No. filter from the bank statement. If the system finds a match in the bank statement line based on the specified filters, then the account type and account number from the rule line are entered in the financial journal line.';
                }
                field("IBAN Filter"; Rec."IBAN Filter")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction IBAN filter from the bank statement. If the system finds a match in the bank statement line based on the specified filters, then the account type and account number from the rule line are entered in the financial journal line.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account to be entered in the financial journal line if the bank statement line matches the specified filters.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account number to be entered in the financial journal line if the bank statement line matches the specified filters.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(MoveUp)
            {
                Caption = 'Move Up';
                Image = MoveUp;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Move the selected line up in the list.';
                ShortcutKey = 'Ctrl+Alt+1';

                trigger OnAction()
                begin
                    Rec.MoveUp();
                    CurrPage.Update(false);
                end;
            }
            action(MoveDown)
            {
                Caption = 'Move Down';
                Image = MoveDown;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Move the selected line down in the list.';
                ShortcutKey = 'Ctrl+Alt+0';

                trigger OnAction()
                begin
                    Rec.MoveDown();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
