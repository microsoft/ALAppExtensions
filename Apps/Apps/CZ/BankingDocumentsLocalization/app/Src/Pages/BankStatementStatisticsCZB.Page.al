// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;

page 31290 "Bank Statement Statistics CZB"
{
    Caption = 'Bank Statement Statistics';
    Editable = false;
    PageType = Card;
    SourceTable = "Bank Statement Header CZB";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Statistics)
                {
                    ShowCaption = false;
                    field(StartingBalance; BankAccount."Balance at Date")
                    {
                        Caption = 'Starting Balance';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the starting balance of banking document.';
                    }
                    field(Amount; -Rec.Amount)
                    {
                        Caption = 'Amount';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the total amount for banking document lines.';
                    }
                    field(EndingBalance; BankAccount."Balance at Date" + Rec.Amount)
                    {
                        Caption = 'Ending Balance';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the ending balance of banking document.';
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetAutoCalcFields(Amount);
    end;

    trigger OnAfterGetRecord()
    begin
        BankAccount.Get(Rec."Bank Account No.");
        BankAccount.SetFilter("Date Filter", '..%1', CalcDate('<-1D>', Rec."Document Date"));
        BankAccount.CalcFields("Balance at Date");
    end;

    var
        BankAccount: Record "Bank Account";
}
