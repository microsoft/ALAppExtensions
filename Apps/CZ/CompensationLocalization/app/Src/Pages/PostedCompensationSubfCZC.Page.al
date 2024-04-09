// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Foundation.Navigate;

page 31278 "Posted Compensation Subf. CZC"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Posted Compensation Line CZC";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company type in compensation line (customer or vendor).';
                }
                field("Source Entry No."; Rec."Source Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry number of customer or vendor entry that is the subject of the compensation.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number of customer or vendor.';
                }
                field("Posting Group"; Rec."Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting group used on the source customer or vendor entry.';
                    Visible = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the posting date of the original customer or vendor entry that is the subject of the compensation.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the document type of the customer or vendor ledger entry.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the document number of the customer or vendor ledger entry.';
                }
                field("Variable Symbol"; Rec."Variable Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the document number for the payment system.';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the description for compensation.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the currency of amounts on the document.';
                }
                field("Ledg. Entry Original Amount"; Rec."Ledg. Entry Original Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the original amount of the source customer or vendor entry that can be included in the compensation.';
                    Visible = false;
                }
                field("Ledg. Entry Remaining Amount"; Rec."Ledg. Entry Remaining Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the remaining amount of the source customer or vendor entry that can be included in the compensation.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount which will be included in the compensation.';
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount after doing compensation process.';
                }
                field("Ledg. Entry Original Amt.(LCY)"; Rec."Ledg. Entry Original Amt.(LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the original amount of the source customer or vendor entry that can be included in the compensation. The amount is in the local currency.';
                    Visible = false;
                }
                field("Ledg. Entry Rem. Amt. (LCY)"; Rec."Ledg. Entry Rem. Amt. (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the remaining amount of the source customer or vendor entry that can be included in the compensation. The amount is in the local currency.';
                    Visible = false;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount which will be included in the compensation. The amount is in the local currency.';
                }
                field("Remaining Amount (LCY)"; Rec."Remaining Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount after doing compensation process. The amount is in the local currency.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code of the Shortcut Dimension 1, which is defined in the Shortcut Dimension 1 Code field in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code of the Shortcut Dimension 2, which is defined in the Shortcut Dimension 2 Code field in the General Ledger Setup window.';
                    Visible = false;
                }
            }
            group(Totals)
            {
                ShowCaption = false;
                field(CompensationBalanceLCY; CompensationBalanceLCY)
                {
                    Caption = 'Compensation Balance (LCY)';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sum of amount compensation lines. The amount is in the local currency.';
                    Editable = false;
                }
                field(CompensationValueLCY; CompensationValueLCY)
                {
                    Caption = 'Compensation Value (LCY)';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sum of positive amount compensation lines. The amount is in the local currency.';
                    Editable = false;
                }
                field(BalanceLCY; BalanceLCY)
                {
                    Caption = 'Balance (LCY)';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ledger entries remaining amount. The amount is in the local currency.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Line)
            {
                Caption = '&Line';
                action(Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'Specifies compensation line dimensions.';

                    trigger OnAction()
                    begin
                        ShowDim();
                    end;
                }
                action(Navigate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Find Entries';
                    Ellipsis = true;
                    Image = Navigate;
                    ShortcutKey = 'Ctrl+Alt+Q';
                    ToolTip = 'Find all entries and documents that exist for the document number and posting date on the selected entry.';

                    trigger OnAction()
                    var
                        Navigate: Page Navigate;
                    begin
                        Navigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                        Navigate.Run();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CalculatePostedTotals();
    end;

    var
        CompensationBalanceLCY, CompensationValueLCY, BalanceLCY : Decimal;

    local procedure ShowDim()
    begin
        Rec.ShowDimensions();
    end;

    local procedure CalculatePostedTotals();
    var
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
    begin
        if not PostedCompensationHeaderCZC.Get(Rec."Compensation No.") then
            exit;
        PostedCompensationHeaderCZC.CalcFields("Balance (LCY)", "Compensation Balance (LCY)", "Compensation Value (LCY)");
        CompensationBalanceLCY := PostedCompensationHeaderCZC."Compensation Balance (LCY)";
        CompensationValueLCY := PostedCompensationHeaderCZC."Compensation Value (LCY)";
        BalanceLCY := PostedCompensationHeaderCZC."Balance (LCY)";
        CurrPage.Update(false);
    end;
}
