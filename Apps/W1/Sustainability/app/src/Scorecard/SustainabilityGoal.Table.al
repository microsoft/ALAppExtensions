namespace Microsoft.Sustainability.Scorecard;

using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Inventory.Location;
using Microsoft.Foundation.UOM;
using System.Security.User;

table 6219 "Sustainability Goal"
{
    Caption = 'Sustainability Goal';
    DataClassification = CustomerContent;
    DrillDownPageId = "Sustainability Goals";
    LookupPageId = "Sustainability Goals";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if Rec."No." <> xRec."No." then begin
                    Rec.TestField("Scorecard No.");
                    UpdateScorecardInformation(Rec."Scorecard No.");
                end;
            end;
        }
        field(2; "Scorecard No."; Code[20])
        {
            Caption = 'Scorecard No.';
            TableRelation = "Sustainability Scorecard"."No.";
            NotBlank = true;

            trigger OnValidate()
            begin
                if Rec."Scorecard No." <> xRec."Scorecard No." then
                    UpdateScorecardInformation(Rec."Scorecard No.");
            end;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Name"; Text[100])
        {
            Caption = 'Name';
        }
        field(5; "Owner"; Code[50])
        {
            Caption = 'Owner';
            TableRelation = "User Setup"."User ID" where("Sustainability Manager" = const(true));
        }
        field(6; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(7; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
        }
        field(8; "Start Date"; Date)
        {
            Caption = 'Start Date';

            trigger OnValidate()
            begin
                if (Rec."Start Date" > Rec."End Date") and (Rec."End Date" <> 0D) then
                    Error(InvalidStartAndEndDateErr, Rec.FieldCaption("Start Date"), Rec.FieldCaption("End Date"));

                if Rec."Start Date" <> 0D then begin
                    Rec.TestField("Baseline Start Date");
                    Rec.TestField("Baseline End Date");
                end;

                ValidateBaselineWithCurrentDateFilter(Rec."Start Date", Rec."End Date");
            end;
        }
        field(9; "End Date"; Date)
        {
            Caption = 'End Date';

            trigger OnValidate()
            begin
                Rec.Validate("Start Date");

                if Rec."End Date" <> 0D then begin
                    Rec.TestField("Start Date");
                    Rec.TestField("Baseline Start Date");
                    Rec.TestField("Baseline End Date");
                end;

                ValidateBaselineWithCurrentDateFilter(Rec."Start Date", Rec."End Date");
            end;
        }
        field(10; "Baseline Period"; Date)
        {
            Caption = 'Baseline Period';
            FieldClass = FlowFilter;
            Editable = false;
        }
        field(11; "Current Period Filter"; Date)
        {
            Caption = 'Current Period Filter';
            FieldClass = FlowFilter;
            Editable = false;
        }
        field(12; "Baseline for CO2"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Baseline for CO2';
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CO2" where("Posting Date" = field("Baseline Period"), "Country/Region Code" = field("Country/Region Code Filter"), "Responsibility Center" = field("Responsibility Center Filter")));
            Editable = false;
        }
        field(13; "Baseline for CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Baseline for CH4';
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CH4" where("Posting Date" = field("Baseline Period"), "Country/Region Code" = field("Country/Region Code Filter"), "Responsibility Center" = field("Responsibility Center Filter")));
            Editable = false;
        }
        field(14; "Baseline for N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Baseline for N2O';
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission N2O" where("Posting Date" = field("Baseline Period"), "Country/Region Code" = field("Country/Region Code Filter"), "Responsibility Center" = field("Responsibility Center Filter")));
            Editable = false;
        }
        field(15; "Current Value for CO2"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CO2" where("Posting Date" = field("Current Period Filter"), "Country/Region Code" = field("Country/Region Code Filter"), "Responsibility Center" = field("Responsibility Center Filter")));
            Editable = false;
            Caption = 'Current Value for CO2';
        }
        field(16; "Current Value for CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CH4" where("Posting Date" = field("Current Period Filter"), "Country/Region Code" = field("Country/Region Code Filter"), "Responsibility Center" = field("Responsibility Center Filter")));
            Editable = false;
            Caption = 'Current Value for CH4';
        }
        field(17; "Current Value for N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission N2O" where("Posting Date" = field("Current Period Filter"), "Country/Region Code" = field("Country/Region Code Filter"), "Responsibility Center" = field("Responsibility Center Filter")));
            Editable = false;
            Caption = 'Current Value for N2O';
        }
        field(18; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Unit of Measure";
        }
        field(19; "Target Value for CO2"; Decimal)
        {
            Caption = 'Target Value for CO2';
        }
        field(20; "Target Value for CH4"; Decimal)
        {
            Caption = 'Target Value for CH4';
        }
        field(21; "Target Value for N2O"; Decimal)
        {
            Caption = 'Target Value for N2O';
        }
        field(22; "Main Goal"; Boolean)
        {
            Caption = 'Main Goal';

            trigger OnValidate()
            begin
                if Rec."Main Goal" then
                    ValidateIfMainGoalIsAlreadyMarked();
            end;
        }
        field(23; "Baseline Start Date"; Date)
        {
            Caption = 'Baseline Start Date';

            trigger OnValidate()
            begin
                if (Rec."Baseline Start Date" > Rec."Baseline End Date") and (Rec."Baseline End Date" <> 0D) then
                    Error(InvalidStartAndEndDateErr, Rec.FieldCaption("Baseline Start Date"), Rec.FieldCaption("Baseline End Date"));

                ValidateBaselineWithCurrentDateFilter(Rec."Start Date", Rec."End Date");
            end;
        }
        field(24; "Baseline End Date"; Date)
        {
            Caption = 'Baseline End Date';

            trigger OnValidate()
            begin
                Rec.Validate("Baseline Start Date");
                ValidateBaselineWithCurrentDateFilter(Rec."Start Date", Rec."End Date");
            end;
        }
        field(25; "Country/Region Code Filter"; Code[10])
        {
            Caption = 'Country/Region Code Filter';
            FieldClass = FlowFilter;
            TableRelation = "Country/Region";
        }
        field(26; "Responsibility Center Filter"; Code[10])
        {
            Caption = 'Responsibility Center Filter';
            FieldClass = FlowFilter;
            TableRelation = "Responsibility Center";
        }
        field(27; "Baseline for Water Intensity"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Baseline for Water Intensity';
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Water Intensity" where("Posting Date" = field("Baseline Period"), "Country/Region Code" = field("Country/Region Code Filter"), "Responsibility Center" = field("Responsibility Center Filter")));
            Editable = false;
        }
        field(28; "Baseline for Waste Intensity"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Baseline for Waste Intensity';
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Waste Intensity" where("Posting Date" = field("Baseline Period"), "Country/Region Code" = field("Country/Region Code Filter"), "Responsibility Center" = field("Responsibility Center Filter")));
            Editable = false;
        }
        field(29; "Current Value for Water Int."; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Water Intensity" where("Posting Date" = field("Current Period Filter"), "Country/Region Code" = field("Country/Region Code Filter"), "Responsibility Center" = field("Responsibility Center Filter")));
            Editable = false;
            Caption = 'Current Value for Water Intensity';
        }
        field(30; "Current Value for Waste Int."; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Waste Intensity" where("Posting Date" = field("Current Period Filter"), "Country/Region Code" = field("Country/Region Code Filter"), "Responsibility Center" = field("Responsibility Center Filter")));
            Editable = false;
            Caption = 'Current Value for Waste Intensity';
        }
        field(31; "Target Value for Water Int."; Decimal)
        {
            Caption = 'Target Value for Water Intensity';
        }
        field(32; "Target Value for Waste Int."; Decimal)
        {
            Caption = 'Target Value for Waste Intensity';
        }
    }

    keys
    {
        key(Key1; "Scorecard No.", "No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.Get();
        Rec.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
    end;

    local procedure ValidateIfMainGoalIsAlreadyMarked()
    var
        SustainabilityGoal: Record "Sustainability Goal";
    begin
        SustainabilityGoal.SetRange("Main Goal", true);
        if SustainabilityGoal.FindFirst() then
            Error(CanOnlyHaveOneMainGoalErr, SustainabilityGoal."Scorecard No.", SustainabilityGoal.Owner);
    end;

    local procedure UpdateScorecardInformation(ScorecardNo: Code[20])
    var
        SustainabilityScorecard: Record "Sustainability Scorecard";
    begin
        if ScorecardNo <> '' then begin
            SustainabilityScorecard.Get(ScorecardNo);
            Rec.Validate(Owner, SustainabilityScorecard.Owner);
        end else
            Rec.Validate(Owner, '');
    end;

    local procedure ValidateBaselineWithCurrentDateFilter(CurrentPeriodStartDate: Date; CurrentPeriodEndDate: Date)
    begin
        if (CurrentPeriodStartDate = 0D) or (CurrentPeriodEndDate = 0D) then
            exit;

        if (CurrentPeriodStartDate >= Rec."Baseline Start Date") and (CurrentPeriodStartDate <= Rec."Baseline End Date") then
            Error(StartDateErr, CurrentPeriodStartDate, Rec."Baseline Start Date", Rec."Baseline End Date");

        if (CurrentPeriodEndDate >= Rec."Baseline Start Date") and (CurrentPeriodEndDate <= Rec."Baseline End Date") then
            Error(EndDateErr, CurrentPeriodStartDate, Rec."Baseline Start Date", Rec."Baseline End Date");

        if (Rec."Baseline Start Date" >= CurrentPeriodStartDate) and (Rec."Baseline Start Date" <= CurrentPeriodEndDate) then
            Error(StartDateErr, CurrentPeriodStartDate, Rec."Baseline Start Date", Rec."Baseline End Date");

        if (Rec."Baseline End Date" >= CurrentPeriodStartDate) and (Rec."Baseline End Date" <= CurrentPeriodEndDate) then
            Error(EndDateErr, CurrentPeriodStartDate, Rec."Baseline Start Date", Rec."Baseline End Date");
    end;

    procedure UpdateCurrentDateFilter(StartDate: Date; EndDate: Date)
    begin
        case true of
            (StartDate = 0D) and (EndDate <> 0D):
                Rec.SetFilter("Current Period Filter", '..%1', EndDate);
            (StartDate <> 0D) and (EndDate = 0D):
                Rec.SetFilter("Current Period Filter", '%1..', StartDate);
            else
                Rec.SetFilter("Current Period Filter", '%1..%2', StartDate, EndDate);
        end;
    end;

    procedure UpdateBaselineDateFilter(StartDate: Date; EndDate: Date)
    begin
        case true of
            (StartDate = 0D) and (EndDate <> 0D):
                Rec.SetFilter("Baseline Period", '..%1', EndDate);
            (StartDate <> 0D) and (EndDate = 0D):
                Rec.SetFilter("Baseline Period", '%1..', StartDate);
            else
                Rec.SetFilter("Baseline Period", '%1..%2', StartDate, EndDate);
        end;
    end;

    procedure UpdateFlowFiltersOnRecord()
    begin
        Rec.SetRange("Country/Region Code Filter");
        Rec.SetRange("Responsibility Center Filter");

        if Rec."Country/Region Code" <> '' then
            Rec.SetRange("Country/Region Code Filter", Rec."Country/Region Code");

        if Rec."Responsibility Center" <> '' then
            Rec.SetRange("Country/Region Code Filter", Rec."Responsibility Center");
    end;

    procedure ApplyOwnerFilter(var SustainabilityGoal: Record "Sustainability Goal")
    begin
        SustainabilityGoal.SetRange(Owner, UserId());
        if SustainabilityGoal.FindSet() then;
    end;

    procedure RemoveOwnerFilter(var SustainabilityGoal: Record "Sustainability Goal")
    begin
        SustainabilityGoal.SetRange(Owner);
        if SustainabilityGoal.FindSet() then;
    end;

    procedure RunSustainabilityGoalsFromScorecard(SustainabilityScore: Record "Sustainability Scorecard")
    var
        SustainabilityGoal: Record "Sustainability Goal";
        SustainabilityGoals: Page "Sustainability Goals";
    begin
        SustainabilityGoal.SetRange("Scorecard No.", SustainabilityScore."No.");

        SustainabilityGoals.SetCalledFromScorecard(true);
        SustainabilityGoals.SetTableView(SustainabilityGoal);
        SustainabilityGoals.Run();
    end;

    procedure DrillDownSustLedgerEntries(SustainabilityGoal: Record "Sustainability Goal")
    var
        SustainabilityLedgEntry: Record "Sustainability Ledger Entry";
    begin
        SustainabilityLedgEntry.SetRange("Posting Date", SustainabilityGoal."Start Date", SustainabilityGoal."End Date");
        Page.Run(Page::"Sustainability Ledger Entries", SustainabilityLedgEntry);
    end;

    procedure DrillDownSustLedgerEntriesForBaseline(SustainabilityGoal: Record "Sustainability Goal")
    var
        SustainabilityLedgEntry: Record "Sustainability Ledger Entry";
    begin
        if SustainabilityGoal."Country/Region Code" <> '' then
            SustainabilityLedgEntry.SetRange("Country/Region Code", SustainabilityGoal."Country/Region Code");

        if SustainabilityGoal."Responsibility Center" <> '' then
            SustainabilityLedgEntry.SetRange("Responsibility Center", SustainabilityGoal."Responsibility Center");

        case true of
            (SustainabilityGoal."Baseline Start Date" = 0D) and (SustainabilityGoal."Baseline End Date" <> 0D):
                SustainabilityLedgEntry.SetFilter("Posting Date", '..%1', SustainabilityGoal."Baseline End Date");
            (SustainabilityGoal."Baseline Start Date" <> 0D) and (SustainabilityGoal."Baseline End Date" = 0D):
                SustainabilityLedgEntry.SetFilter("Posting Date", '%1..', SustainabilityGoal."Baseline Start Date");
            else
                SustainabilityLedgEntry.SetFilter("Posting Date", '%1..%2', SustainabilityGoal."Baseline Start Date", SustainabilityGoal."Baseline End Date");
        end;

        Page.Run(Page::"Sustainability Ledger Entries", SustainabilityLedgEntry);
    end;

    procedure UpdateCurrentEmissionValues(var SustainabilityGoals: Record "Sustainability Goal")
    var
        SustainabilityGoals2: Record "Sustainability Goal";
    begin
        SustainabilityGoals."Current Value for CO2" := 0;
        SustainabilityGoals."Current Value for CH4" := 0;
        SustainabilityGoals."Current Value for N2O" := 0;
        SustainabilityGoals."Current Value for Water Int." := 0;
        SustainabilityGoals."Current Value for Waste Int." := 0;

        SustainabilityGoals."Baseline for CO2" := 0;
        SustainabilityGoals."Baseline for CH4" := 0;
        SustainabilityGoals."Baseline for N2O" := 0;
        SustainabilityGoals."Baseline for Water Intensity" := 0;
        SustainabilityGoals."Baseline for Waste Intensity" := 0;

        if not SustainabilityGoals2.Get(SustainabilityGoals."Scorecard No.", SustainabilityGoals."No.", SustainabilityGoals."Line No.") then
            exit;

        SustainabilityGoals2.UpdateCurrentDateFilter(SustainabilityGoals."Start Date", SustainabilityGoals."End Date");
        SustainabilityGoals2.UpdateBaselineDateFilter(SustainabilityGoals."Baseline Start Date", SustainabilityGoals."Baseline End Date");
        SustainabilityGoals2.UpdateFlowFiltersOnRecord();

        SustainabilityGoals2.CalcFields("Current Value for CO2", "Current Value for CH4", "Current Value for N2O", "Current Value for Water Int.", "Current Value for Waste Int.");
        SustainabilityGoals2.CalcFields("Baseline for CO2", "Baseline for CH4", "Baseline for N2O", "Baseline for Water Intensity", "Baseline for Waste Intensity");

        SustainabilityGoals."Current Value for CO2" := SustainabilityGoals2."Current Value for CO2";
        SustainabilityGoals."Current Value for CH4" := SustainabilityGoals2."Current Value for CH4";
        SustainabilityGoals."Current Value for N2O" := SustainabilityGoals2."Current Value for N2O";
        SustainabilityGoals."Current Value for Water Int." := SustainabilityGoals2."Current Value for Water Int.";
        SustainabilityGoals."Current Value for Waste Int." := SustainabilityGoals2."Current Value for Waste Int.";

        SustainabilityGoals."Baseline for CO2" := SustainabilityGoals2."Baseline for CO2";
        SustainabilityGoals."Baseline for CH4" := SustainabilityGoals2."Baseline for CH4";
        SustainabilityGoals."Baseline for N2O" := SustainabilityGoals2."Baseline for N2O";
        SustainabilityGoals."Baseline for Water Intensity" := SustainabilityGoals2."Baseline for Water Intensity";
        SustainabilityGoals."Baseline for Waste Intensity" := SustainabilityGoals2."Baseline for Waste Intensity";
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        CanOnlyHaveOneMainGoalErr: Label 'Main is already selected for Scorecard No.: %1 and Owner: %2.', Comment = '%1 - Scorecard No., %2 - Owner';
        InvalidStartAndEndDateErr: Label '%1 cannot be after %2', Comment = '%1 - Start Date, %2 - End Date';
        StartDateErr: Label 'Start Date : %1 of Current Period cannot overlap with Baseline Period : %2..%3', Comment = '%1 - Start Date of Current Period, %2 - Baseline Period Start Date, %3 - Baseline Period End Date';
        EndDateErr: Label 'End Date : %1 of Current Period cannot overlap with Baseline Period : %2..%3', Comment = '%1 - End Date of Current Period, %2 - Baseline Period Start Date, %3 - Baseline Period End Date';
}