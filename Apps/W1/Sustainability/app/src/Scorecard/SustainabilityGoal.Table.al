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
            end;
        }
        field(9; "End Date"; Date)
        {
            Caption = 'End Date';

            trigger OnValidate()
            begin
                Rec.Validate("Start Date");
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
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CO2" where("Posting Date" = field("Baseline Period")));
            Editable = false;
        }
        field(13; "Baseline for CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Baseline for CH4';
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CH4" where("Posting Date" = field("Baseline Period")));
            Editable = false;
        }
        field(14; "Baseline for N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Baseline for N2O';
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission N2O" where("Posting Date" = field("Baseline Period")));
            Editable = false;
        }
        field(15; "Current Value for CO2"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CO2" where("Posting Date" = field("Current Period Filter")));
            Editable = false;
            Caption = 'Current Value for CO2';
        }
        field(16; "Current Value for CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission CH4" where("Posting Date" = field("Current Period Filter")));
            Editable = false;
            Caption = 'Current Value for CH4';
        }
        field(17; "Current Value for N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            FieldClass = FlowField;
            CalcFormula = sum("Sustainability Ledger Entry"."Emission N2O" where("Posting Date" = field("Current Period Filter")));
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
            end;
        }
        field(24; "Baseline End Date"; Date)
        {
            Caption = 'Baseline End Date';

            trigger OnValidate()
            begin
                Rec.Validate("Baseline Start Date");
            end;
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
        SustainabilityGoal.SetRange("Scorecard No.", Rec."Scorecard No.");
        SustainabilityGoal.SetFilter("Line No.", '<>%1', Rec."Line No.");
        SustainabilityGoal.SetFilter("No.", '<>%1', Rec."No.");
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

    procedure UpdateCurrentDateFilter(StartDate: Date; EndDate: Date)
    begin
        Rec.SetFilter("Current Period Filter", '%1..%2', StartDate, EndDate);
    end;

    procedure UpdateBaselineDateFilter(StartDate: Date; EndDate: Date)
    begin
        Rec.SetFilter("Baseline Period", '%1..%2', StartDate, EndDate);
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

    procedure UpdateCurrentEmissionValues(var SustainabilityGoals: Record "Sustainability Goal")
    var
        SustainabilityGoals2: Record "Sustainability Goal";
    begin
        SustainabilityGoals."Current Value for CO2" := 0;
        SustainabilityGoals."Current Value for CH4" := 0;
        SustainabilityGoals."Current Value for N2O" := 0;

        SustainabilityGoals."Baseline for CO2" := 0;
        SustainabilityGoals."Baseline for CH4" := 0;
        SustainabilityGoals."Baseline for N2O" := 0;

        if not SustainabilityGoals2.Get(SustainabilityGoals."Scorecard No.", SustainabilityGoals."No.", SustainabilityGoals."Line No.") then
            exit;

        SustainabilityGoals2.UpdateCurrentDateFilter(SustainabilityGoals."Start Date", SustainabilityGoals."End Date");
        SustainabilityGoals2.UpdateBaselineDateFilter(SustainabilityGoals."Baseline Start Date", SustainabilityGoals."Baseline End Date");
        SustainabilityGoals2.CalcFields("Current Value for CO2", "Current Value for CH4", "Current Value for N2O");
        SustainabilityGoals2.CalcFields("Baseline for CO2", "Baseline for CH4", "Baseline for N2O");

        SustainabilityGoals."Current Value for CO2" := SustainabilityGoals2."Current Value for CO2";
        SustainabilityGoals."Current Value for CH4" := SustainabilityGoals2."Current Value for CH4";
        SustainabilityGoals."Current Value for N2O" := SustainabilityGoals2."Current Value for N2O";

        SustainabilityGoals."Baseline for CO2" := SustainabilityGoals2."Baseline for CO2";
        SustainabilityGoals."Baseline for CH4" := SustainabilityGoals2."Baseline for CH4";
        SustainabilityGoals."Baseline for N2O" := SustainabilityGoals2."Baseline for N2O";
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        CanOnlyHaveOneMainGoalErr: Label 'Main is already selected for Scorecard No.: %1 and Owner: %2.', Comment = '%1 - Scorecard No., %2 - Owner';
        InvalidStartAndEndDateErr: Label '%1 cannot be after %2', Comment = '%1 - Start Date, %2 - End Date';
}