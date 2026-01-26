namespace Microsoft.Sustainability.Purchase;

using Microsoft.Foundation.UOM;
using Microsoft.Purchases.History;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Certificate;
using Microsoft.Sustainability.Energy;
using Microsoft.Sustainability.Setup;

tableextension 6213 "Sust. Purch. Cr. Memo Line" extends "Purch. Cr. Memo Line"
{
    fields
    {
        field(6210; "Sust. Account No."; Code[20])
        {
            Caption = 'Sustainability Account No.';
            TableRelation = "Sustainability Account" where("Account Type" = const(Posting), Blocked = const(false));
            DataClassification = CustomerContent;
        }
        field(6211; "Sust. Account Name"; Text[100])
        {
            Caption = 'Sustainability Account Name';
            DataClassification = CustomerContent;
        }
        field(6212; "Sust. Account Category"; Code[20])
        {
            Caption = 'Sustainability Account Category';
            Editable = false;
            TableRelation = "Sustain. Account Category";
            DataClassification = CustomerContent;
        }
        field(6213; "Sust. Account Subcategory"; Code[20])
        {
            Caption = 'Sustainability Account Subcategory';
            Editable = false;
            TableRelation = "Sustain. Account Subcategory".Code where("Category Code" = field("Sust. Account Category"));
            DataClassification = CustomerContent;
        }
        field(6214; "Emission CO2 Per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CO2 Per Unit';
            DataClassification = CustomerContent;
        }
        field(6215; "Emission CH4 Per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CH4 Per Unit';
            DataClassification = CustomerContent;
        }
        field(6216; "Emission N2O Per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission N2O Per Unit';
            DataClassification = CustomerContent;
        }
        field(6217; "Emission CO2"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CO2';
            CaptionClass = '102,6,1';
            DataClassification = CustomerContent;
        }
        field(6218; "Emission CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CH4';
            CaptionClass = '102,6,2';
            DataClassification = CustomerContent;
        }
        field(6219; "Emission N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission N2O';
            CaptionClass = '102,6,3';
            DataClassification = CustomerContent;
        }
        field(6223; "Energy Source Code"; Code[20])
        {
            Caption = 'Energy Source Code';
            TableRelation = "Sustainability Energy Source";
            DataClassification = CustomerContent;
        }
        field(6224; "Renewable Energy"; Boolean)
        {
            Caption = 'Renewable Energy';
            DataClassification = CustomerContent;
        }
        field(6225; "Energy Consumption Per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Energy Consumption Per Unit';
            DataClassification = CustomerContent;
        }
        field(6226; "Energy Consumption"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Energy Consumption';
            CaptionClass = '102,13,4';
            DataClassification = CustomerContent;
        }
        field(6228; "Source of Emission Data"; Enum "Sust. Source of Emission")
        {
            DataClassification = CustomerContent;
            Caption = 'Source of Emission Data';
        }
        field(6229; "Emission Verified"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Emission Verified';
        }
        field(6230; "CBAM Compliance"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'CBAM Compliance';
        }
        field(6231; "Emission Cost per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission Cost per Unit';
            DataClassification = CustomerContent;
        }
        field(6232; "Total Emission Cost"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Total Emission Cost';
            CaptionClass = '102,15,5';
            DataClassification = CustomerContent;
        }
        field(6234; "Unit for Sust. Formulas"; Code[10])
        {
            Caption = 'Unit for Sust. Formulas';
            TableRelation = "Unit of Measure";
            DataClassification = CustomerContent;
        }
        field(6235; "Fuel/Electricity"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Fuel/El. Decimal Places"));
            Caption = 'Fuel/Electricity';
            DataClassification = CustomerContent;
        }
        field(6236; Distance; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Distance Decimal Places"));
            Caption = 'Distance';
            DataClassification = CustomerContent;
        }
        field(6237; "Custom Amount"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Custom Amt. Decimal Places"));
            Caption = 'Custom Amount';
            DataClassification = CustomerContent;
        }
        field(6238; "Installation Multiplier"; Decimal)
        {
            Caption = 'Installation Multiplier';
            DataClassification = CustomerContent;
        }
        field(6239; "Time Factor"; Decimal)
        {
            Caption = 'Time Factor';
            MaxValue = 1;
            DataClassification = CustomerContent;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
}