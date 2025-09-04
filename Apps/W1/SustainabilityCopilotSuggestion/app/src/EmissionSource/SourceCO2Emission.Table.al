// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using Microsoft.Foundation.Address;
using Microsoft.Sustainability.Setup;

table 6292 "Source CO2 Emission"
{
    Caption = 'Source CO2 Emission';
    DataClassification = CustomerContent;
    InherentPermissions = X;
    InherentEntitlements = X;
    Access = Internal;

    fields
    {
        field(1; Id; BigInteger)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Description"; Text[250])
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the description of the account category';
            Caption = 'Description';
            Editable = false;
        }
        field(3; "Emission Factor CO2"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 11;
            AutoFormatExpression = GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            ToolTip = 'Specifies the emission factor CO2';
            Caption = 'Emission Factor CO2';
            Editable = false;
        }
        field(4; "Emission Source ID"; BigInteger)
        {
            DataClassification = SystemMetadata;
            Caption = 'Emission Source ID';
            TableRelation = "Emission Source Setup";
            Editable = false;
        }
        field(5; "Country/Region Code"; Code[10])
        {
            Editable = false;
            ToolTip = 'Specifies the country/region code';
            Caption = 'Country/Region Code';
        }
        field(6; "Country Name"; Text[50])
        {
            ToolTip = 'Specifies the country name';
            Caption = 'Country Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Country/Region".Name where(Code = field("Country/Region Code")));
        }
        field(7; "Source Description"; Text[250])
        {
            ToolTip = 'Specifies the source description';
            Caption = 'Source Description';
            FieldClass = FlowField;
            CalcFormula = lookup("Emission Source Setup".Description where(Id = field("Emission Source ID")));
            Editable = false;
        }
        field(8; "Line No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Line No.';
            ToolTip = 'Specifies the sustainability journal line number';
            Editable = false;
        }
        field(19; "Emission CO2"; Decimal)
        {
            DataClassification = CustomerContent;
            BlankZero = true;
            Caption = 'Emission CO2';
            Editable = false;
            ToolTip = 'Specifies the CO2 emission';
            AutoFormatType = 1;
            AutoFormatExpression = '';
        }
        field(20; "Starting Date"; Date)
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the starting date for the emission source';
            Caption = 'Starting Date';
        }
        field(21; "Ending Date"; Date)
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the ending date for the emission source';
            Caption = 'Ending Date';
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(key2; Description, "Country/Region Code")
        {
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilitySetupRetrieved: Boolean;
        AutoFormatExprLbl: Label '<Precision,%1><Standard Format,0>', Locked = true;

    procedure GetFormat(FieldNo: Integer): Text
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

    local procedure GetSustainabilitySetup()
    begin
        if SustainabilitySetupRetrieved then
            exit;

        SustainabilitySetup.Get();
        SustainabilitySetupRetrieved := true;
    end;
}