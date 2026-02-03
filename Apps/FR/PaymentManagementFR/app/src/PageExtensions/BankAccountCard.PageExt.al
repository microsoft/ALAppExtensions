// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.BankAccount;
#if not CLEAN28
using Microsoft.Bank.Payment;
#endif

pageextension 10834 "Bank Account Card" extends "Bank Account Card"
{
    layout
    {
#if not CLEAN28
#pragma warning disable AL0432
        modify(" R.I.B")
        {
            Visible = not FeatureEnabled;
        }
#pragma warning restore AL0432
#endif
        addafter(Transfer)
        {
            group("R.I.B FR")
            {
                Caption = ' R.I.B';
#if not CLEAN28
                Visible = FeatureEnabled;
#endif
                field("Bank Branch No.3 FR"; Rec."Bank Branch No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the branch number of your bank.';
#if not CLEAN28
                    Visible = FeatureEnabled;
#endif
                }
                field("Agency Code FR"; Rec."Agency Code FR")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the five-number code of the agency of the bank, for example, 00300.';
#if not CLEAN28
                    Visible = FeatureEnabled;
#endif
                }
                field("Bank Account No.3 FR"; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account number.';
#if not CLEAN28
                    Visible = FeatureEnabled;
#endif
                }
                field("RIB Key FR"; Rec."RIB Key FR")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the two-digit RIB key associated with the Bank Account No. RIB key value in range from 01 to 09 is represented in the single-digit form, without leading zero digit.';
#if not CLEAN28
                    Visible = FeatureEnabled;
#endif
                }
                field("RIB Checked FR"; Rec."RIB Checked FR")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Bank Account No. has been verified against the RIB Key.';
#if not CLEAN28
                    Visible = FeatureEnabled;
#endif
                }
            }
        }
#if CLEAN28
        moveafter("RIB Checked FR"; "Bank Statement Import Format", "Payment Export Format", CheckTransmitted, "Positive Pay Export Code")
#endif
    }

#if not CLEAN28
    trigger OnOpenPage()
    var
        PaymentFeatureFR: Codeunit "Payment Management Feature FR";
    begin
        FeatureEnabled := PaymentFeatureFR.IsEnabled();
    end;

    var
        FeatureEnabled: Boolean;
#endif
}