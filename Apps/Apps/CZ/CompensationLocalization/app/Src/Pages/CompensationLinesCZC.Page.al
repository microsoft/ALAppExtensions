// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

page 31275 "Compensation Lines CZC"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Compensation Lines';
    PageType = List;
    SourceTable = "Compensation Line CZC";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                Editable = false;
                ShowCaption = false;
                field("Compensation No."; Rec."Compensation No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies number of Compensation card.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company type in compensation line (customer or vendor).';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of customer or vendor.';
                }
                field("Source Entry No."; Rec."Source Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry number of customer or vendor entry that is the subject of the compensation.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the original customer or vendor entry that is the subject of the compensation.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type of the customer or vendor ledger entry.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the customer or vendor ledger entry.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description for compensation.';
                }
                field("Variable Symbol"; Rec."Variable Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number for the payment system.';
                }
                field("Ledg. Entry Original Amount"; Rec."Ledg. Entry Original Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the original amount of the source customer or vendor entry that can be included in the compensation.';
                    Visible = false;
                }
                field("Ledg. Entry Remaining Amount"; Rec."Ledg. Entry Remaining Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the remaining amount of the source customer or vendor entry that can be included in the compensation.';
                }
                field("Ledg. Entry Original Amt.(LCY)"; Rec."Ledg. Entry Original Amt.(LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the original amount of the source customer or vendor entry that can be included in the compensation. The amount is in the local currency.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Dimensions)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Dimensions';
                Image = Dimensions;
                ShortCutKey = 'Alt+D';
                ToolTip = 'Specifies compensation line dimensions.';

                trigger OnAction()
                begin
                    Rec.ShowDimensions();
                end;
            }
        }
        area(Navigation)
        {
            action(Document)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Document';
                ToolTip = 'Shows compensation card.';
                Image = View;
                ShortCutKey = 'Shift+F7';
                RunObject = page "Compensation Card CZC";
                RunPageLink = "No." = field("Compensation No.");
                RunPageMode = View;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Show Document_Promoted"; Document)
                {
                }
                actionref(Dimensions_Promoted; Dimensions)
                {
                }
            }
        }
    }
}
