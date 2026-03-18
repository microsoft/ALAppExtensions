// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

page 10839 "Payment Lines Archive List FR"
{
    Caption = 'Payment Lines Archive List';
    Editable = false;
    PageType = List;
    SourceTable = "Payment Line Archive FR";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the archived payment.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the archived payment line''s entry number.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the archived payment line.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code of the archived payment line.';
                    Visible = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    ToolTip = 'Specifies the amount (including VAT) of the archived payment line.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    ToolTip = 'Specifies the amount in LCY of the archived payment line.';
                    Visible = false;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account type of the archived payment line.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account number of the archived payment line.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the due date of the archived payment line.';
                }
                field("Payment Class"; Rec."Payment Class")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the payment class of the archived payment line.';
                }
                field("Status Name"; Rec."Status Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the archived payment.';
                }
                field("Status No."; Rec."Status No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the archived status line entry number.';
                    Visible = false;
                }
                field("Acceptation Code"; Rec."Acceptation Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the acception code of the archived payment.';
                }
                field("Drawee Reference"; Rec."Drawee Reference")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the file reference which has been used in the electronic payment (ETEBAC) file.';
                }
                field("Bank Account Name"; Rec."Bank Account Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the bank account, as entered in the Bank Account field.';
                    Visible = false;
                }
                field("Bank Branch No."; Rec."Bank Branch No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the branch number of the bank account as entered in the Bank Account field.';
                    Visible = false;
                }
                field("Agency Code"; Rec."Agency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the agency code of the bank account as entered in the Bank Account field.';
                    Visible = false;
                }
                field("SWIFT Code"; Rec."SWIFT Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the international bank identification code for the payment slip.';
                }
                field(IBAN; Rec.IBAN)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the international bank account number (IBAN) for the payment slip.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the customer or vendor bank account of the archived payment.';
                    Visible = false;
                }
                field("RIB Key"; Rec."RIB Key")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the two-digit RIB key associated with the Bank Account No. RIB key value in range from 01 to 09 is represented in the single-digit form, without leading zero digit.';
                    Visible = false;
                }
                field("Payment in Progress"; Rec."Payment in Progress")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the payment line was taken into account for the customer or vendor payments in progress.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Functions)
            {
                Caption = '&Payment';
                action(Card)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Card';
                    Image = EditLines;
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'Open the card for the entity on the selected line to view more details.';

                    trigger OnAction()
                    var
                        Statement: Record "Payment Header Archive FR";
                        StatementForm: Page "Payment Slip Archive FR";
                    begin
                        if Statement.Get(Rec."No.") then begin
                            Statement.SetRange("No.", Rec."No.");
                            StatementForm.SetTableView(Statement);
                            StatementForm.Run();
                        end;
                    end;
                }
            }
        }
    }
}

