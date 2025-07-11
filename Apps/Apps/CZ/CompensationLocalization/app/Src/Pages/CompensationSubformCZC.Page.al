// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.Navigate;

page 31273 "Compensation Subform CZC"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Compensation Line CZC";

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
                    BlankZero = true;
                    ShowMandatory = true;
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
                    ToolTip = 'Specifies description for compensation.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the currency of amounts on the document.';

                    trigger OnAssistEdit()
                    var
                        CompensationHeaderCZC: Record "Compensation Header CZC";
                        ChangeExchangeRate: Page "Change Exchange Rate";
                    begin
                        CompensationHeaderCZC.Get(Rec."Compensation No.");
                        ChangeExchangeRate.SetParameter(Rec."Currency Code", Rec."Currency Factor", CompensationHeaderCZC."Posting Date");
                        if ChangeExchangeRate.RunModal() = Action::OK then
                            Rec.Validate("Currency Factor", ChangeExchangeRate.GetParameter());
                    end;
                }
                field("Ledg. Entry Original Amount"; Rec."Ledg. Entry Original Amount")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the original amount of the source customer or vendor entry that can be included in the compensation.';
                    Visible = false;
                }
                field("Ledg. Entry Remaining Amount"; Rec."Ledg. Entry Remaining Amount")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the remaining amount of the source customer or vendor entry that can be included in the compensation.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the amount which will be included in the compensation.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the amount after doing compensation process.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Ledg. Entry Original Amt.(LCY)"; Rec."Ledg. Entry Original Amt.(LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the original amount of the source customer or vendor entry that can be included in the compensation. The amount is in the local currency.';
                    Visible = false;
                }
                field("Ledg. Entry Rem. Amt. (LCY)"; Rec."Ledg. Entry Rem. Amt. (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the remaining amount of the source customer or vendor entry that can be included in the compensation. The amount is in the local currency.';
                    Visible = false;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the amount which will be included in the compensation. The amount is in the local currency.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Remaining Amount (LCY)"; Rec."Remaining Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the amount after doing compensation process. The amount is in the local currency.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(RelatedAmountToApply; Rec.CalcRelatedAmountToApply())
                {
                    Caption = 'Related Amount to Apply (LCY)';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the total Amount (LCY) related suggestions to apply.';
                    BlankZero = true;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownRelatedAmountToApply();
                    end;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code of the Shortcut Dimension 1, which is defined in the Shortcut Dimension 1 Code field in the General Ledger Setup window.';
                    Visible = DimVisible1;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(1, Rec."Shortcut Dimension 1 Code");
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(1, Rec."Shortcut Dimension 1 Code");
                    end;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code of the Shortcut Dimension 2, which is defined in the Shortcut Dimension 2 Code field in the General Ledger Setup window.';
                    Visible = DimVisible2;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupShortcutDimCode(2, Rec."Shortcut Dimension 2 Code");
                    end;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(2, Rec."Shortcut Dimension 2 Code");
                    end;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(3),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    ToolTip = 'Specifies shortcut dimension code No. 3 of line';
                    Visible = DimVisible3;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(4),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    ToolTip = 'Specifies shortcut dimension code No. 4 of line';
                    Visible = DimVisible4;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(5),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    ToolTip = 'Specifies shortcut dimension code No. 5 of line';
                    Visible = DimVisible5;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(6),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    ToolTip = 'Specifies shortcut dimension code No. 6 of line';
                    Visible = DimVisible6;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(7),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    ToolTip = 'Specifies shortcut dimension code No. 7 of line';
                    Visible = DimVisible7;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(8),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    ToolTip = 'Specifies shortcut dimension code No. 8 of line';
                    Visible = DimVisible8;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("Manual Change Only"; Rec."Manual Change Only")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'The amount on the marked lines will not be automatically reduced when the Adjust Compensation Balance function is started.';
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

    trigger OnOpenPage()
    begin
        SetDimensionsVisibility();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CalculateTotals();
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalculateTotals();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ShortcutDimCode);
    end;

    var
        ShortcutDimCode: array[8] of Code[20];
        DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8 : Boolean;
        CompensationBalanceLCY, CompensationValueLCY, BalanceLCY : Decimal;

    local procedure ShowDim()
    begin
        CurrPage.Activate(true);
        Rec.ShowDimensions();
    end;

    local procedure SetDimensionsVisibility()
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimVisible1 := false;
        DimVisible2 := false;
        DimVisible3 := false;
        DimVisible4 := false;
        DimVisible5 := false;
        DimVisible6 := false;
        DimVisible7 := false;
        DimVisible8 := false;
        DimensionManagement.UseShortcutDims(DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);
        Clear(DimensionManagement);
    end;

    local procedure CalculateTotals();
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        if not CompensationHeaderCZC.Get(Rec."Compensation No.") then
            exit;
        CompensationHeaderCZC.CalcFields("Balance (LCY)", "Compensation Balance (LCY)", "Compensation Value (LCY)");
        CompensationBalanceLCY := CompensationHeaderCZC."Compensation Balance (LCY)";
        CompensationValueLCY := CompensationHeaderCZC."Compensation Value (LCY)";
        BalanceLCY := CompensationHeaderCZC."Balance (LCY)";
        CurrPage.Update(false);
    end;
}
