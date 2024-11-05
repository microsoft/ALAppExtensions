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
    MultipleNewLines = true;

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

                    trigger OnValidate()
                    begin
                        FormatLine();
                        CurrPage.Update(true);
                    end;
                }
                field("Name"; Rec."Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Name';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Name field.';

                    trigger OnValidate()
                    begin
                        FormatLine();
                        CurrPage.Update(true);
                    end;
                }
                field("Owner"; Rec."Owner")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Owner';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Owner field.';

                    trigger OnValidate()
                    begin
                        FormatLine();
                        CurrPage.Update(true);
                    end;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Country/Region Code';
                    ToolTip = 'Specifies the value of the Country/Region Code field.';

                    trigger OnValidate()
                    begin
                        FormatLine();
                        CurrPage.Update(true);
                    end;
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Responsibility Center';
                    ToolTip = 'Specifies the value of the Responsibility Center field.';

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
                field("Baseline for CO2"; Rec."Baseline for CO2")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Baseline for CO2';
                    ToolTip = 'Specifies the value of the Baseline for CO2. This value is automatically calculated based on Baseline Start and End Date and Country/Region Code and Responsibility Center. If the Country/Region Code and Responsibility Center fields are empty, field will show all entries.';
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownSustLedgerEntriesForBaseline(Rec);
                    end;
                }
                field("Baseline for CH4"; Rec."Baseline for CH4")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Baseline for CH4';
                    ToolTip = 'Specifies the value of the Baseline for CH4. This value is automatically calculated based on Baseline Start and End Date and Country/Region Code and Responsibility Center. If the Country/Region Code and Responsibility Center fields are empty, field will show all entries.';
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownSustLedgerEntriesForBaseline(Rec);
                    end;
                }
                field("Baseline for N2O"; Rec."Baseline for N2O")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Baseline for N2O';
                    ToolTip = 'Specifies the value of the Baseline for N2O. This value is automatically calculated based on Baseline Start and End Date and Country/Region Code and Responsibility Center. If the Country/Region Code and Responsibility Center fields are empty, field will show all entries.';
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownSustLedgerEntriesForBaseline(Rec);
                    end;
                }
                field("Baseline for Water Intensity"; Rec."Baseline for Water Intensity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Baseline for Water Intensity field.';
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownSustLedgerEntriesForBaseline(Rec);
                    end;
                }
                field("Baseline for Waste Intensity"; Rec."Baseline for Waste Intensity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Baseline for Waste Intensity field.';
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownSustLedgerEntriesForBaseline(Rec);
                    end;
                }
                field("Current Value for CO2"; Rec."Current Value for CO2")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Current Value for CO2';
                    ToolTip = 'Specifies the CO2 emission amount of the for the current period. This value is automatically calculated based on Start and End Date and Country/Region Code and Responsibility Center. If the Country/Region Code and Responsibility Center fields are empty, field will show all entries.';
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
                    ToolTip = 'Specifies the CH4 emission amount of the for the current period. This value is automatically calculated based on Start and End Date and Country/Region Code and Responsibility Center. If the Country/Region Code and Responsibility Center fields are empty, field will show all entries.';
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
                    ToolTip = 'Specifies the N2O emission amount of the for the current period. This value is automatically calculated based on Start and End Date and Country/Region Code and Responsibility Center. If the Country/Region Code and Responsibility Center fields are empty, field will show all entries.';
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownSustLedgerEntries(Rec);
                    end;
                }
                field("Current Value for Water Int."; Rec."Current Value for Water Int.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Current Value for Water Intensity field.';
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownSustLedgerEntries(Rec);
                    end;
                }
                field("Current Value for Waste Int."; Rec."Current Value for Waste Int.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Current Value for Waste Intensity field.';
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

                    trigger OnValidate()
                    begin
                        FormatLine();
                        CurrPage.Update(true);
                    end;
                }
                field("Target Value for CO2"; Rec."Target Value for CO2")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Target Value for CO2';
                    ToolTip = 'Specifies the value of the Target Value for CO2 field.';

                    trigger OnValidate()
                    begin
                        FormatLine();
                        CurrPage.Update(true);
                    end;
                }
                field("Target Value for CH4"; Rec."Target Value for CH4")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Target Value for CH4';
                    ToolTip = 'Specifies the value of the Target Value for CH4 field.';

                    trigger OnValidate()
                    begin
                        FormatLine();
                        CurrPage.Update(true);
                    end;
                }
                field("Target Value for N2O"; Rec."Target Value for N2O")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Target Value for N2O';
                    ToolTip = 'Specifies the value of the Target Value for N2O field.';

                    trigger OnValidate()
                    begin
                        FormatLine();
                        CurrPage.Update(true);
                    end;
                }
                field("Target Value for Water Int."; Rec."Target Value for Water Int.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Target Value for Water Intensity field.';

                    trigger OnValidate()
                    begin
                        FormatLine();
                        CurrPage.Update(true);
                    end;
                }
                field("Target Value for Waste Int."; Rec."Target Value for Waste Int.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Target Value for Waste Intensity field.';

                    trigger OnValidate()
                    begin
                        FormatLine();
                        CurrPage.Update(true);
                    end;
                }
                field("Main Goal"; Rec."Main Goal")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Main Goal';
                    ToolTip = 'Specifies that this sustainability goal is the main goal for the company. You can designate only one goal as the primary goal for the entire company. KPIs related to this primary goal are displayed in the Sustainability Manager role center.';

                    trigger OnValidate()
                    begin
                        FormatLine();
                        CurrPage.Update(true);
                    end;
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
        FormatLine();
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
    begin
        CanEditScorecard := not CalledFromScorecard;
        ShowNotificationIfFlowFiltersAppliedFromPage();
        Rec.UpdateCurrentEmissionValues(Rec);
    end;

    local procedure ShowNotificationIfFlowFiltersAppliedFromPage()
    begin
        if Rec.GetFilter("Current Period Filter") <> '' then begin
            Rec.SetFilter("Current Period Filter", '');
            SendNotification(StrSubstNo(CannotApplyCurrentPeriodFilterFromPageMsg, Rec.FieldCaption("Start Date"), Rec.FieldCaption("End Date")), NotificationScope::LocalScope);
        end;

        if Rec.GetFilter("Baseline Period") <> '' then begin
            Rec.SetFilter("Baseline Period", '');
            SendNotification(StrSubstNo(CannotApplyCurrentPeriodFilterFromPageMsg, Rec.FieldCaption("Baseline Start Date"), Rec.FieldCaption("Baseline End Date")), NotificationScope::LocalScope);
        end;

        if Rec.GetFilter("Responsibility Center Filter") <> '' then begin
            Rec.SetFilter("Responsibility Center Filter", '');
            SendNotification(StrSubstNo(CannotApplyResponsibilityCenterFilterFromPageMsg, Rec.FieldCaption("Responsibility Center")), NotificationScope::LocalScope);
        end;

        if Rec.GetFilter("Country/Region Code Filter") <> '' then begin
            Rec.SetFilter("Country/Region Code Filter", '');
            SendNotification(StrSubstNo(CannotApplyCountryRegionFilterFromPageMsg, Rec.FieldCaption("Country/Region Code")), NotificationScope::LocalScope);
        end;
    end;

    local procedure SendNotification(NotificationMsg: Text; Scope: NotificationScope)
    var
        Notification: Notification;
    begin
        Notification.Id := CreateGuid();
        Notification.Message := NotificationMsg;
        Notification.Scope := Scope;
        Notification.Send();
    end;

    var
        CalledFromScorecard: Boolean;
        CanEditScorecard: Boolean;
        CannotApplyCurrentPeriodFilterFromPageMsg: Label 'You cannot apply current date filter from the page as the field calculation happens based on %1 and %2 for each Goal line(s).', Comment = '%1 - Start Date caption, %2 - End Date Caption';
        CannotApplyCountryRegionFilterFromPageMsg: Label 'You cannot apply Country/Region Code filter from the page as the calculation happens based on field %1 for each Goal line(s).', Comment = '%1 - Country/Region Code';
        CannotApplyResponsibilityCenterFilterFromPageMsg: Label 'You cannot apply Responsibility Center filter from the page as the calculation happens based on field %1 for each Goal line(s).', Comment = '%1 - Responsibility Center';
}