// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Foundation.Navigate;

page 10842 "Payment Slip Archive FR"
{
    Caption = 'Payment Slip Archive';
    Editable = false;
    PageType = Document;
    SourceTable = "Payment Header Archive FR";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    AssistEdit = false;
                    ToolTip = 'Specifies the number of the payment slip.';
                }
                field("Payment Class"; Rec."Payment Class")
                {
                    ApplicationArea = Basic, Suite;
                    Lookup = false;
                    ToolTip = 'Specifies the payment class used when creating this payment slip.';
                }
                field("Payment Class Name"; Rec."Payment Class Name")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the name of the payment class used.';
                }
                field("Status Name"; Rec."Status Name")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the status of the payment.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code of the payment.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the date when the payment slip was posted.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the payment slip was created.';

                    trigger OnValidate()
                    begin
                        DocumentDateOnAfterValidate();
                    end;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    AutoFormatType = 1;
                    ToolTip = 'Specifies the sum of the amounts in the Amount (LCY) fields on the associated lines.';
                }
            }
            part(Lines; "Payment Slip Subform ArchiveFR")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("No.");
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the source of the entry.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the dimension value code with which the payment is associated.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the dimension value code with which the invoice is associated.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the type of the account that the payments have been transferred to/from.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the account that the payments have been transferred to/from.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Header")
            {
                Caption = '&Header';
                Image = DepositSlip;
                action(Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ToolTip = 'View or change the dimension settings for this payment slip. If you change the dimension, you can update all lines on the payment slip.';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                    end;
                }
                action("Header RIB")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Header RIB';
                    Image = Check;
                    RunObject = Page "Payment Bank Archive FR";
                    RunPageLink = "No." = field("No.");
                    ToolTip = 'View the RIB key that is associated with the bank account.';
                }
            }
            group("&Navigate")
            {
                Caption = '&Navigate';
                action(Header)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Header';
                    Image = DepositSlip;
                    ToolTip = 'View general information about archived payments or collections, for example, to and from customers and vendors. A payment header has one or more payment lines assigned to it. The lines contain information such as the amount, the bank details, and the due date.';

                    trigger OnAction()
                    begin
                        Navigate.SetDoc(Rec."Posting Date", Rec."No.");
                        Navigate.Run();
                    end;
                }
                action(Line)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Line';
                    Image = Line;
                    ToolTip = 'View the ledger entry line information for the archived payment slips.';

                    trigger OnAction()
                    begin
                        CurrPage.Lines.PAGE.NavigateLine(Rec."Posting Date");
                    end;
                }
            }
        }
    }

    var
        Navigate: Page Navigate;

    local procedure DocumentDateOnAfterValidate()
    begin
        CurrPage.Update();
    end;
}

