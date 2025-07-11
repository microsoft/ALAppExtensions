// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Finance.Dimension;
using Microsoft.Utilities;

page 31193 "Posted Compensation Lines CZC"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Posted Compensation Lines';
    PageType = List;
    SourceTable = "Posted Compensation Line CZC";
    Editable = false;
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount which will be included in the compensation.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount which will be included in the compensation. The amount is in the local currency.';
                }
                field("Compensation No."; Rec."Compensation No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Compensation No. field.';
                }
                field("Compensation Posting Date"; Rec."Compensation Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Compensation Posting Date field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency of amounts on the document.';
                }
                field("Currency Factor"; Rec."Currency Factor")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Currency Factor field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description for compensation.';
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Dimension Set ID field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the customer or vendor ledger entry.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type of the customer or vendor ledger entry.';
                }
                field("Ledg. Entry Original Amount"; Rec."Ledg. Entry Original Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the original amount of the source customer or vendor entry that can be included in the compensation.';
                }
                field("Ledg. Entry Original Amt.(LCY)"; Rec."Ledg. Entry Original Amt.(LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the original amount of the source customer or vendor entry that can be included in the compensation. The amount is in the local currency.';
                }
                field("Ledg. Entry Rem. Amt. (LCY)"; Rec."Ledg. Entry Rem. Amt. (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the remaining amount of the source customer or vendor entry that can be included in the compensation. The amount is in the local currency.';
                }
                field("Ledg. Entry Remaining Amount"; Rec."Ledg. Entry Remaining Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the remaining amount of the source customer or vendor entry that can be included in the compensation.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Line No. field.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the original customer or vendor entry that is the subject of the compensation.';
                }
                field("Posting Group"; Rec."Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting group used on the source customer or vendor entry.';
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount after doing compensation process.';
                }
                field("Remaining Amount (LCY)"; Rec."Remaining Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount after doing compensation process. The amount is in the local currency.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the Shortcut Dimension 1, which is defined in the Shortcut Dimension 1 Code field in the General Ledger Setup window.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the Shortcut Dimension 2, which is defined in the Shortcut Dimension 2 Code field in the General Ledger Setup window.';
                }
                field("Source Entry No."; Rec."Source Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry number of customer or vendor entry that is the subject of the compensation.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of customer or vendor.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company type in compensation line (customer or vendor).';
                }
                field("Variable Symbol"; Rec."Variable Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number for the payment system.';
                }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action("Show Document")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Document';
                    Image = View;
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'Open the document that the selected line exists on.';

                    trigger OnAction()
                    var
                        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
                        PageManagement: Codeunit "Page Management";
                    begin
                        PostedCompensationHeaderCZC.Get(Rec."Compensation No.");
                        PageManagement.PageRun(PostedCompensationHeaderCZC);
                    end;
                }
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Show Document_Promoted"; "Show Document")
                {
                }
                actionref(Dimensions_Promoted; Dimensions)
                {
                }
            }
        }
    }
}
