namespace Microsoft.Sustainability.Scorecard;

using System.Security.User;

page 6234 "Sustainability Goals"
{
    PageType = List;
    Caption = 'Sustainability Goals';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Sustainability Goal";
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Scorecard No."; Rec."Scorecard No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Scorecard No.';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Scorecard No. field.';
                    Editable = CanEditScorecard;
                    Enabled = CanEditScorecard;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'No.';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field("Name"; Rec."Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Name';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Owner"; Rec."Owner")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Owner';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Owner field.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Country/Region Code';
                    ToolTip = 'Specifies the value of the Country/Region Code field.';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Responsibility Center';
                    ToolTip = 'Specifies the value of the Responsibility Center field.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Start Date';
                    ToolTip = 'Specifies the value of the Start Date field.';

                    trigger OnValidate()
                    begin
                        FormatLine();
                        CurrPage.Update(true);
                    end;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'End Date';
                    ToolTip = 'Specifies the value of the End Date field.';

                    trigger OnValidate()
                    begin
                        FormatLine();
                        CurrPage.Update(true);
                    end;
                }
                field("Baseline Start Date"; Rec."Baseline Start Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Baseline Start Date';
                    ToolTip = 'Specifies the value of the Baseline Start Date field.';

                    trigger OnValidate()
                    begin
                        FormatLine();
                        CurrPage.Update(true);
                    end;
                }
                field("Baseline End Date"; Rec."Baseline End Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Baseline End Date';
                    ToolTip = 'Specifies the value of the Baseline End Date field.';

                    trigger OnValidate()
                    begin
                        FormatLine();
                        CurrPage.Update(true);
                    end;
                }
                field("Baseline for CO2"; Rec."Baseline for CO2")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Baseline for CO2';
                    ToolTip = 'Specifies the value of the Baseline for CO2 field.';
                }
                field("Baseline for CH4"; Rec."Baseline for CH4")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Baseline for CH4';
                    ToolTip = 'Specifies the value of the Baseline for CH4 field.';
                }
                field("Baseline for N2O"; Rec."Baseline for N2O")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Baseline for N2O';
                    ToolTip = 'Specifies the value of the Baseline for N2O field.';
                }
                field("Current Value for CO2"; Rec."Current Value for CO2")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Current Value for CO2';
                    ToolTip = 'Specifies the value of the Current Value for CO2 field.';
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownSustLedgerEntries(Rec);
                    end;
                }
                field("Current Value for CH4"; Rec."Current Value for CH4")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Current Value for CH4';
                    ToolTip = 'Specifies the value of the Current Value for CH4 field.';
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownSustLedgerEntries(Rec);
                    end;
                }
                field("Current Value for N2O"; Rec."Current Value for N2O")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Current Value for N2O';
                    ToolTip = 'Specifies the value of the Current Value for N2O field.';
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownSustLedgerEntries(Rec);
                    end;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Unit of Measure';
                    ToolTip = 'Specifies the value of the Unit of Measure field.';
                }
                field("Target Value for CO2"; Rec."Target Value for CO2")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Target Value for CO2';
                    ToolTip = 'Specifies the value of the Target Value for CO2 field.';
                }
                field("Target Value for CH4"; Rec."Target Value for CH4")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Target Value for CH4';
                    ToolTip = 'Specifies the value of the Target Value for CH4 field.';
                }
                field("Target Value for N2O"; Rec."Target Value for N2O")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Target Value for N2O';
                    ToolTip = 'Specifies the value of the Target Value for N2O field.';
                }
                field("Main Goal"; Rec."Main Goal")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Main Goal';
                    ToolTip = 'Specifies the value of the Main Goal field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Show My Goals")
            {
                ApplicationArea = Basic, Suite;
                Image = FilterLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Caption = 'Show My Goals';
                ToolTip = 'Executes the Show My Goals action.';

                trigger OnAction()
                begin
                    Rec.ApplyOwnerFilter(Rec);
                    CurrPage.Update(false);
                end;
            }
            action("Show All Goals")
            {
                ApplicationArea = Basic, Suite;
                Image = ShowList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Caption = 'Show All Goals';
                ToolTip = 'Executes the Show All Goals action.';

                trigger OnAction()
                begin
                    Rec.RemoveOwnerFilter(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        UserMgt: Codeunit "User Setup Management";
    begin
        Rec."Responsibility Center" := UserMgt.GetSalesFilter();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        FormatLine();
    end;

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    procedure SetCalledFromScorecard(NewCalledFromScorecard: Boolean)
    begin
        CalledFromScorecard := NewCalledFromScorecard;
    end;

    local procedure FormatLine()
    var
        CurrentPeriodDateNotification: Notification;
        BaselinePeriodDateNotification: Notification;
    begin
        CanEditScorecard := not CalledFromScorecard;

        if Rec.GetFilter("Current Period Filter") <> '' then begin
            Rec.SetFilter("Current Period Filter", '');
            CurrentPeriodDateNotification.Id := CreateGuid();
            CurrentPeriodDateNotification.Message := StrSubstNo(CannotApplyCurrentPeriodFilterFromPageMsg, Rec.FieldCaption("Start Date"), Rec.FieldCaption("End Date"));
            CurrentPeriodDateNotification.Scope := NotificationScope::LocalScope;
            CurrentPeriodDateNotification.Send();
        end;

        if Rec.GetFilter("Baseline Period") <> '' then begin
            Rec.SetFilter("Baseline Period", '');
            BaselinePeriodDateNotification.Id := CreateGuid();
            BaselinePeriodDateNotification.Message := StrSubstNo(CannotApplyCurrentPeriodFilterFromPageMsg, Rec.FieldCaption("Baseline Start Date"), Rec.FieldCaption("Baseline End Date"));
            BaselinePeriodDateNotification.Scope := NotificationScope::LocalScope;
            BaselinePeriodDateNotification.Send();
        end;

        Rec.UpdateCurrentEmissionValues(Rec);
    end;

    var
        CalledFromScorecard: Boolean;
        CanEditScorecard: Boolean;
        CannotApplyCurrentPeriodFilterFromPageMsg: Label 'You cannot apply current date filter from the page as the field calculation happens based on %1 and %2 for each Goal line(s).', Comment = '%1 - Start Date caption, %2 - End Date Caption';
}