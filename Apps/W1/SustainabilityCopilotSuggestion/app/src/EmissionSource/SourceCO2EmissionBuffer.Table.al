// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

table 6293 "Source CO2 Emission Buffer"
{
    DataClassification = CustomerContent;
    InherentPermissions = X;
    TableType = Temporary;

    fields
    {
        field(1; "Line No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Line No.';
            ToolTip = 'Specifies the sustainability journal line number';
            Editable = false;
        }
        field(2; "Source CO2 Emission Id"; BigInteger)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(3; "Emission Factor CO2"; Decimal)
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the emission factor CO2';
            Caption = 'Emission Factor CO2';
            AutoFormatType = 1;
            AutoFormatExpression = '';
        }
        field(4; Confidence; Enum "Source CO2 Emission Confidence")
        {
            DataClassification = CustomerContent;
            Caption = 'Confidence';
            ToolTip = 'Specifies the confidence level of the CO2 emission factor';
        }
        field(5; "Confidence Value"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Confidence Value';
            ToolTip = 'Specifies the confidence value of the CO2 emission factor';
            Editable = false;
            AutoFormatType = 1;
            AutoFormatExpression = '';

            trigger OnValidate()
            begin
                case true of
                    Rec."Confidence Value" < 0.8:
                        Rec.Confidence := Rec.Confidence::Low;
                    Rec."Confidence Value" in [0.8 .. 0.9]:
                        Rec.Confidence := Rec.Confidence::Medium;
                    Rec."Confidence Value" > 0.9:
                        Rec.Confidence := Rec.Confidence::High;
                end
            end;
        }
        field(6; "Description"; Text[250])
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the description of the account category';
            Caption = 'Description';
        }
        field(7; "Source Description"; Text[250])
        {
            ToolTip = 'Specifies the source description';
            Caption = 'Source Description';
        }
        field(8; "Emission Source ID"; BigInteger)
        {
            DataClassification = SystemMetadata;
            Caption = 'Emission Source ID';
            TableRelation = "Emission Source Setup";
        }
        field(9; "Country/Region Code"; Code[10])
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the country/region code';
            Caption = 'Country/Region Code';
        }
        field(10; "Conversion Factor"; Decimal)
        {
            DecimalPlaces = 6;
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the conversion factor between user input and CO2 emission from file';
            Caption = 'Conversion Factor';
            AutoFormatType = 1;
            AutoFormatExpression = '';
        }
    }

    keys
    {
        key(PK; "Line No.", "Source CO2 Emission Id")
        {
            Clustered = true;
        }
        key(ConfidenceValue; "Confidence Value")
        {
        }
    }
}