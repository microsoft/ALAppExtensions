namespace Microsoft.Sustainability.Setup;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.UOM;
using Microsoft.Utilities;

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
        field(6; "Emission Rounding Precission"; Decimal)
        {
            Caption = 'Emission Rounding Precission';
            DecimalPlaces = 0 : 10;
            InitValue = 0.01;
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
        field(14; "Block Sustain. Accs. Deletion"; Boolean)
        {
            Caption = 'Block Sustainability Accounts Deletion';
        }
        field(15; "Block Change If Entry Exists"; Boolean)
        {
            Caption = 'Block Calculation Foundation Change If Ledger Entries Exist';
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
        SustainabilitySetupRetreived: Boolean;
        AutoFormatExprLbl: Label '<Precision,%1><Standard Format,0>', Locked = true;

    internal procedure GetFormat(FieldNo: Integer): Text
    begin
        if not SustainabilitySetupRetreived then
            SustainabilitySetupRetreived := SustainabilitySetup.Get();

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

    [InherentPermissions(PermissionObjectType::TableData, Database::"Sustainability Setup", 'I')]
    internal procedure InitRecord()
    begin
        if not Get() then
            Insert();
    end;
}