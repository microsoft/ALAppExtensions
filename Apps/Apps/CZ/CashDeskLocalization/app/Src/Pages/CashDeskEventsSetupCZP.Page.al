// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.Dimension;

page 31158 "Cash Desk Events Setup CZP"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Cash Desk Events Setup';
    PageType = List;
    SourceTable = "Cash Desk Event CZP";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies code of cash desk events.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies description of cash desk events.';
                }
                field("Cash Desk No."; Rec."Cash Desk No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies cash desk events which can the user use for defined cash desk.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the cash desk document represents a cash receipt (Receipt) or a withdrawal (Wirthdrawal)';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account thet the entry will be posted to. To see the options, choose the field.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the account that the entry on the journal line will be posted to.';
                }
                field("Gen. Document Type"; Rec."Gen. Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies general document type for selected cash desk events (payment, refund).';
                }
                field("Gen. Posting Type"; Rec."Gen. Posting Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies general posting type for selected cash desk events (purchase, sales).';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a VAT business posting group code.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a VAT product posting group code for the VAT Statement.';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the dimension value code associated with the cash desk.';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the dimension value code associated with the cash desk.';
                }
                field("EET Transaction"; Rec."EET Transaction")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the value of Yes will automatically be filled when the row meets the conditions for a recorded sale.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }
    actions
    {
        area(navigation)
        {
            group("&Cash Desk Events")
            {
                Caption = '&Cash Desk Events';
                action(Dimensions)
                {
                    ApplicationArea = Suite;
                    Caption = 'Dimensions';
                    Image = DefaultDimension;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = const(11746), "No." = field(Code);
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'Open the page for default dimension of cash desk events setup.';
                }
            }
        }
    }
}
