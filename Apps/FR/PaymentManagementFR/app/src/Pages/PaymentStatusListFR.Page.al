// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

page 10850 "Payment Status List FR"
{
    AutoSplitKey = true;
    Caption = 'Payment Status List';
    PageType = List;
    SourceTable = "Payment Status FR";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies text to describe the payment status.';
                }
                field(Look; Rec.Look)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that lines of payment documents with this status may be looked up and edited through the View/Edit Payment Line window.';
                }
                field(ReportMenu; Rec.ReportMenu)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that documents with this status may be printed.';
                }
                field(RIB; Rec.RIB)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies all information involving the bank identifier (RIB) statement of the customer or vendor be displayed on the payment lines.';
                }
                field("Acceptation Code"; Rec."Acceptation Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the acceptation code will displayed on the payment lines.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the amount will displayed on the payment lines.';
                }
                field(Debit; Rec.Debit)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the debit amount will displayed on the payment lines.';
                }
                field(Credit; Rec.Credit)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the credit amount will displayed on the payment lines.';
                }
                field("Payment in Progress"; Rec."Payment in Progress")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if you want to take into account all billing and payment lines with this status, when calculating the payments in progress.';
                }
            }
        }
    }

    actions
    {
    }
}

