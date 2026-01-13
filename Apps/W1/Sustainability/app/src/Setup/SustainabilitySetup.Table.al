namespace Microsoft.Sustainability.Setup;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.UOM;
using Microsoft.Integration.Dataverse;
using Microsoft.Integration.SyncEngine;
using Microsoft.Sustainability.CRM;
using Microsoft.Sustainability.Emission;
using Microsoft.Sustainability.ESGReporting;
using Microsoft.Sustainability.Ledger;
using Microsoft.Utilities;
using System.Telemetry;
using System.Threading;
using System.Utilities;

table 6217 "Sustainability Setup"
{
    Caption = 'Sustainability Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Emission Unit of Measure Code"; Code[10])
        {
            Caption = 'Emission Unit of Measure Code';
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            begin
                ValidateEmissionUnitOfMeasure();
            end;
        }
        field(3; "Emission Reporting UOM Code"; Code[10])
        {
            Caption = 'Emission Reporting Unit of Measure Code';
            TableRelation = "Unit of Measure";
        }
        field(4; "Reporting UOM Factor"; Decimal)
        {
            InitValue = 1;
            Caption = 'Reporting UOM Factor';
            DecimalPlaces = 0 : 10;
        }
        field(5; "Emission Decimal Places"; Text[5])
        {
            Caption = 'Emission Decimal Places';
            InitValue = '2:5';
            trigger OnValidate()
            begin
                GLSetup.CheckDecimalPlacesFormat("Emission Decimal Places");
            end;
        }
        field(6; "Emission Rounding Precision"; Decimal)
        {
            Caption = 'Emission Rounding Precision';
            DecimalPlaces = 0 : 10;
            InitValue = 0.01;
            NotBlank = true;
            MinValue = 0;
        }
        field(7; "Emission Rounding Type"; Enum "Rounding Type")
        {
            Caption = 'Emission Rounding Type';
        }
        field(8; "Fuel/El. Decimal Places"; Text[5])
        {
            Caption = 'Fuel/Electricity Decimal Places';
            InitValue = '2:5';
            trigger OnValidate()
            begin
                GLSetup.CheckDecimalPlacesFormat("Fuel/El. Decimal Places");
            end;
        }
        field(9; "Distance Decimal Places"; Text[5])
        {
            Caption = 'Distance Decimal Places';
            InitValue = '2:5';
            trigger OnValidate()
            begin
                GLSetup.CheckDecimalPlacesFormat("Distance Decimal Places");
            end;
        }
        field(10; "Custom Amt. Decimal Places"; Text[5])
        {
            Caption = 'Custom Amount Decimal Places';
            InitValue = '2:5';
            trigger OnValidate()
            begin
                GLSetup.CheckDecimalPlacesFormat("Custom Amt. Decimal Places");
            end;
        }
        field(11; "CSRD Reporting Link"; Text[250])
        {
            Caption = 'CSRD Reporting Link';
        }
        field(12; "Country/Region Mandatory"; Boolean)
        {
            Caption = 'Country/Region Mandatory';
        }
        field(13; "Resp. Center Mandatory"; Boolean)
        {
            Caption = 'Responsibility Center Mandatory';
        }
        field(14; "Block Change If Entry Exists"; Boolean)
        {
            Caption = 'Block Calculation Foundation Change If Ledger Entries Exist';
            InitValue = true;
        }
        field(15; "Enable Background Error Check"; Boolean)
        {
            Caption = 'Enable Background Error Check';
            InitValue = true;
        }
        field(16; "Use Emissions In Purch. Doc."; Boolean)
        {
            Caption = 'Use Emissions In Purchase Documents';
            trigger OnValidate()
            var
                FeatureTelemetry: Codeunit "Feature Telemetry";
                SustainabilityLbl: Label 'Sustainability', Locked = true;
            begin
                if Rec."Use Emissions In Purch. Doc." then
                    FeatureTelemetry.LogUptake('0000PGZ', SustainabilityLbl, Enum::"Feature Uptake Status"::"Set up");

                if not Rec."Use Emissions In Purch. Doc." then
                    Rec.TestField("Use Formulas In Purch. Docs", false);
            end;
        }
        field(17; "Waste Unit of Measure Code"; Code[10])
        {
            Caption = 'Waste Unit of Measure Code';
            TableRelation = "Unit of Measure";
        }
        field(18; "Water Unit of Measure Code"; Code[10])
        {
            Caption = 'Water Unit of Measure Code';
            TableRelation = "Unit of Measure";
        }
        field(19; "Disch. Into Water Unit of Meas"; Code[10])
        {
            Caption = 'Discharged Into Water Unit of Measure Code';
            TableRelation = "Unit of Measure";
        }
        field(20; "G/L Account Emissions"; Boolean)
        {
            Caption = 'G/L Account Emissions';
        }
        field(21; "Item Emissions"; Boolean)
        {
            Caption = 'Item Emissions';
        }
        field(22; "Item Charge Emissions"; Boolean)
        {
            Caption = 'Item Charge Emissions';
        }
        field(23; "Resource Emissions"; Boolean)
        {
            Caption = 'Resource Emissions';
        }
        field(24; "Work/Machine Center Emissions"; Boolean)
        {
            Caption = 'Work/Machine Center Emissions';
        }
        field(25; "Enable Value Chain Tracking"; Boolean)
        {
            Caption = 'Enable Value Chain Tracking';

            trigger OnValidate()
            begin
                if Rec."Enable Value Chain Tracking" then
                    if not ConfirmManagement.GetResponseOrDefault(ConfirmEnableValueChainTrackingQst, false) then
                        Error('');

                EnableEmissionsWhenValueChainTrackingIsEnabled();
            end;
        }
        field(26; "Energy Unit of Measure Code"; Code[10])
        {
            Caption = 'Energy Unit of Measure Code';
            TableRelation = "Unit of Measure";
        }
        field(27; "Energy Reporting UOM Code"; Code[10])
        {
            Caption = 'Energy Reporting Unit of Measure Code';
            TableRelation = "Unit of Measure";
        }
        field(28; "Energy Reporting UOM Factor"; Decimal)
        {
            InitValue = 1;
            Caption = 'Energy Reporting UOM Factor';
            DecimalPlaces = 0 : 10;
        }
        field(29; "Use All Gases As CO2e"; Boolean)
        {
            Caption = 'Use All Gases As CO2e';
            ToolTip = 'Specifies that you want to enable recording all gases as CO2 equivalent values. When this field is selected, the captions for gases will change from their names to their CO2e equivalents. The values you are expected to enter will correspond to their carbon equivalent values, not the original gas values. Additionally, the Carbon Equivalent Factor in the Emission Fees will be set to 1 for all three gases.';

            trigger OnValidate()
            begin
                if Rec."Use All Gases As CO2e" then
                    UpdateCarbonEquivalentFactorInEmissionFee();
            end;
        }
        field(30; "Posted ESG Reporting Nos."; Code[20])
        {
            Caption = 'Posted ESG Reporting Nos.';
            TableRelation = "No. Series";
            ToolTip = 'Specifies the code for the number series that will be used to assign numbers to posted ESG Reporting nos.';
        }
        field(31; "Item Material Composition Nos."; Code[20])
        {
            Caption = 'Item Material Composition Nos.';
            TableRelation = "No. Series";
            ToolTip = 'Specifies the code for the number series that will be used to assign numbers to Item Material Composition Nos.';
        }
        field(32; "ESG Standard Reporting Nos."; Code[20])
        {
            Caption = 'ESG Standard Reporting Nos.';
            TableRelation = "No. Series";
            ToolTip = 'Specifies the code for the number series that will be used to assign numbers for standard records created by dataverse to ESG Standard Reporting.';
        }
        field(40; "Is Dataverse Int. Enabled"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Enable Dataverse Integration';

            trigger OnValidate()
            var
                SustSetupDefaults: Codeunit "Sust. Setup Defaults";
            begin
                if Rec."Is Dataverse Int. Enabled" then begin
                    Rec.TestField("ESG Standard Reporting Nos.");
                    SustSetupDefaults.ResetConfiguration(Rec);
                end else
                    UpdateSustJobQueueEntriesStatus();
            end;
        }
        field(41; "Use Formulas In Purch. Docs"; Boolean)
        {
            Caption = 'Use Formulas in Purchase Documents';

            trigger OnValidate()
            begin
                if Rec."Use Formulas In Purch. Docs" then
                    Rec.TestField("Use Emissions In Purch. Doc.", true);
            end;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        GLSetup: Record "General Ledger Setup";
        SustainabilitySetup: Record "Sustainability Setup";
        ConfirmManagement: Codeunit "Confirm Management";
        SustainabilitySetupRetrieved: Boolean;
        RecordHasBeenRead: Boolean;
        AutoFormatExprLbl: Label '<Precision,%1><Standard Format,0>', Locked = true;
        ConfirmEnableValueChainTrackingQst: Label 'Value Chain Tracking feature is currently in preview. We strongly recommend that you first enable and test this feature on a sandbox environment that has a copy of production data before doing this on a production environment.\\Are you sure you want to enable this feature?';
        EmissionUOMCannotBeChangedErr: Label 'The value for %1 cannot be modified because there are existing sustainability ledger entries that use the unit of measure %2.', Comment = '%1 = Field Caption, %2 = Unit of Measure Code', Locked = true;

    procedure GetRecordOnce()
    begin
        if RecordHasBeenRead then
            exit;
        if not Get() then
            exit;
        RecordHasBeenRead := true;
    end;

    procedure IsValueChainTrackingEnabled(): Boolean
    begin
        SetLoadFields("Enable Value Chain Tracking");
        GetRecordOnce();

        exit("Enable Value Chain Tracking");
    end;

    local procedure EnableEmissionsWhenValueChainTrackingIsEnabled()
    begin
        if not Rec."Enable Value Chain Tracking" then
            exit;

        Rec.Validate("Use Emissions In Purch. Doc.", true);
        Rec.Validate("Item Emissions", true);
        Rec.Validate("Resource Emissions", true);
        Rec.Validate("Work/Machine Center Emissions", true);
    end;

    internal procedure GetFormat(FieldNo: Integer): Text
    begin
        GetSustainabilitySetup();

        case FieldNo of
            SustainabilitySetup.FieldNo("Fuel/El. Decimal Places"):
                exit(StrSubstNo(AutoFormatExprLbl, SustainabilitySetup."Fuel/El. Decimal Places"));
            SustainabilitySetup.FieldNo("Distance Decimal Places"):
                exit(StrSubstNo(AutoFormatExprLbl, SustainabilitySetup."Distance Decimal Places"));
            SustainabilitySetup.FieldNo("Custom Amt. Decimal Places"):
                exit(StrSubstNo(AutoFormatExprLbl, SustainabilitySetup."Custom Amt. Decimal Places"));
            SustainabilitySetup.FieldNo("Emission Decimal Places"):
                exit(StrSubstNo(AutoFormatExprLbl, SustainabilitySetup."Emission Decimal Places"));
        end;
    end;

    internal procedure GetReportingParameters(var UOMCode: Code[10]; var UseUOMReportingFactor: Boolean; var UOMFactor: Decimal; var Direction: Text; var Precision: Decimal)
    begin
        GetSustainabilitySetup();

        if SustainabilitySetup."Emission Reporting UOM Code" <> '' then begin
            UOMCode := SustainabilitySetup."Emission Reporting UOM Code";
            case SustainabilitySetup."Emission Rounding Type" of
                SustainabilitySetup."Emission Rounding Type"::Down:
                    Direction := '<';
                SustainabilitySetup."Emission Rounding Type"::Nearest:
                    Direction := '=';
                SustainabilitySetup."Emission Rounding Type"::Up:
                    Direction := '>';
            end;
            UseUOMReportingFactor := true;
            UOMFactor := SustainabilitySetup."Reporting UOM Factor";
            Precision := SustainabilitySetup."Emission Rounding Precision";
        end else begin
            UOMCode := SustainabilitySetup."Emission Unit of Measure Code";
            UseUOMReportingFactor := false;
        end;
    end;

    internal procedure IsDataverseIntegrationEnabled(): Boolean
    begin
        if not Get() then
            exit(false);

        exit("Is Dataverse Int. Enabled");
    end;

    internal procedure ExistSustainabilityLedgerEntryWithUnitOfMeasure(UnitOfMeasure: Code[10]): Boolean
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
    begin
        SustainabilityLedgerEntry.SetRange("Unit of Measure", UnitOfMeasure);

        exit(not SustainabilityLedgerEntry.IsEmpty());
    end;

    internal procedure GetIntegrationTableIDFilter(): Text
    begin
        exit(
          StrSubstNo(
            '%1|%2|%3|%4|%5|%6|%7|%8|%9',
            Database::"Sust. ESG Reporting Unit",
            Database::"Sust. ESG Standard",
            Database::"Sust. ESG Reporting Name",
            Database::"Sust. ESG Reporting Line",
            Database::"Sust. ESG Range Period",
            Database::"Sust. ESG Standard Requirement",
            Database::"Sust. ESG Requirement Concept",
            Database::"Sust. ESG Concept",
            Database::"Sust. Posted ESG Report Line"));
    end;

    local procedure GetSustainabilitySetup()
    begin
        if not SustainabilitySetupRetrieved then begin
            if not SustainabilitySetup.Get() then
                exit;

            SustainabilitySetupRetrieved := true;
        end;
    end;

    local procedure UpdateCarbonEquivalentFactorInEmissionFee()
    var
        EmissionFee: Record "Emission Fee";
    begin
        EmissionFee.SetFilter("Emission Type", '<>%1', EmissionFee."Emission Type"::" ");
        EmissionFee.ModifyAll("Carbon Equivalent Factor", 1);
    end;

    local procedure UpdateSustJobQueueEntriesStatus()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        JobQueueEntry: Record "Job Queue Entry";
        NewStatus: Option;
    begin
        NewStatus := JobQueueEntry.Status::"On Hold";
        IntegrationTableMapping.SetRange(Type, IntegrationTableMapping.Type::Dataverse);
        IntegrationTableMapping.SetRange("Synch. Codeunit ID", Codeunit::"CRM Integration Table Synch.");
        IntegrationTableMapping.SetRange("Delete After Synchronization", false);
        IntegrationTableMapping.SetFilter("Table ID", GetIntegrationTableIDFilter());
        if IntegrationTableMapping.FindSet() then
            repeat
                JobQueueEntry.SetRange("Record ID to Process", IntegrationTableMapping.RecordId());
                if JobQueueEntry.FindSet() then
                    repeat
                        JobQueueEntry.SetStatus(NewStatus);
                    until JobQueueEntry.Next() = 0;
            until IntegrationTableMapping.Next() = 0;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"Sustainability Setup", 'I')]
    internal procedure InitRecord()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SustainabilityLbl: Label 'Sustainability', Locked = true;
        SustainabilitySetupInitLbl: Label 'Sustainability initialized', Locked = true;
    begin
        if not Get() then begin
            Rec.Insert();
            FeatureTelemetry.LogUptake('0000PH0', SustainabilityLbl, Enum::"Feature Uptake Status"::"Set up");
            FeatureTelemetry.LogUsage('0000PH1', SustainabilityLbl, SustainabilitySetupInitLbl);
        end;
    end;

    local procedure ValidateEmissionUnitOfMeasure()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
    begin
        if Rec."Emission Unit of Measure Code" = xRec."Emission Unit of Measure Code" then
            exit;

        SustainabilityLedgerEntry.SetFilter("Unit of Measure", '%1', xRec."Emission Unit of Measure Code");
        if not SustainabilityLedgerEntry.IsEmpty() then
            Error(EmissionUOMCannotBeChangedErr, Rec.FieldCaption("Emission Unit of Measure Code"), xRec."Emission Unit of Measure Code");
    end;
}