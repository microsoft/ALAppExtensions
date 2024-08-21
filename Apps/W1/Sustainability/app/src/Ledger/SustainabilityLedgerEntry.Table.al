namespace Microsoft.Sustainability.Ledger;

using Microsoft.Sustainability.Journal;
using Microsoft.Foundation.UOM;
using Microsoft.Sustainability.Account;
using Microsoft.Foundation.Address;
using Microsoft.Inventory.Location;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.AuditCodes;
using System.Security.AccessControl;
using Microsoft.Sustainability.Setup;

table 6216 "Sustainability Ledger Entry"
{
    Access = Public;
    Caption = 'Sustainability Ledger Entry';
    DataClassification = CustomerContent;
    DataPerCompany = true;
    DrillDownPageId = "Sustainability Ledger Entries";

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Sustainability Jnl. Template";
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Sustainability Jnl. Batch".Name where("Journal Template Name" = field("Journal Template Name"));
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(6; "Document Type"; Enum "Sustainability Jnl. Doc. Type")
        {
            Caption = 'Document Type';
        }
        field(7; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = "Sustainability Account" where("Account Type" = const(Posting));
        }
        field(8; "Account Name"; Text[100])
        {
            Caption = 'Account Name';
        }
        field(9; "Account Category"; Code[20])
        {
            Caption = 'Account Category';
            TableRelation = "Sustain. Account Category";
        }
        field(10; "Account Subcategory"; Code[20])
        {
            Caption = 'Account Subcategory';
            TableRelation = "Sustain. Account Subcategory".Code where("Category Code" = field("Account Category"));
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(12; "Manual Input"; Boolean)
        {
            Caption = 'Manual Input';
        }
        field(13; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Unit of Measure";
        }
        field(14; "Fuel/Electricity"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Fuel/El. Decimal Places"));
            Caption = 'Fuel/Electricity';
        }
        field(15; Distance; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Distance Decimal Places"));
            Caption = 'Distance';
        }
        field(16; "Custom Amount"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Custom Amt. Decimal Places"));
            Caption = 'Custom Amount';
        }
        field(17; "Installation Multiplier"; Decimal)
        {
            Caption = 'Installation Multiplier';
        }
        field(18; "Time Factor"; Decimal)
        {
            Caption = 'Time Factor';
            MaxValue = 1;
        }
        field(19; "Emission CO2"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CO2';
        }
        field(20; "Emission CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CH4';
        }
        field(21; "Emission N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission N2O';
        }
        field(22; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(23; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
        }
        field(24; "Recurring Method"; Enum "Sustain. Jnl. Recur. Method")
        {
            Caption = 'Recurring Method';
            BlankZero = true;
        }
        field(25; "Recurring Frequency"; DateFormula)
        {
            Caption = 'Recurring Frequency';
        }
        field(26; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
        field(28; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1), Blocked = const(false));
        }
        field(29; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2), Blocked = const(false));
        }
        field(30; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(31; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(32; "CO2e Emission"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'CO2e Emission';
            DecimalPlaces = 2 : 5;
        }
        field(33; "Carbon Fee"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Carbon Fee';
            DecimalPlaces = 2 : 5;
        }
        field(5146; "Emission Scope"; Enum "Emission Scope")
        {
            Caption = 'Emission Scope';
        }
        field(5147; CO2; Boolean)
        {
            Caption = 'CO2';
        }
        field(5148; CH4; Boolean)
        {
            Caption = 'CH4';
        }
        field(5149; N2O; Boolean)
        {
            Caption = 'N2O';
        }
        field(5150; "Calculation Foundation"; Enum "Calculation Foundation")
        {
            Caption = 'Calculation Foundation';
        }
        field(5151; "Emission Factor CO2"; Decimal)
        {
            Caption = 'Emission Factor CO2';
        }
        field(5152; "Emission Factor CH4"; Decimal)
        {
            Caption = 'Emission Factor CH4';
        }
        field(5153; "Emission Factor N2O"; Decimal)
        {
            Caption = 'Emission Factor N2O';
        }
        field(5154; "Renewable Energy"; Boolean)
        {
            Caption = 'Renewable Energy';
        }
        field(5155; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(5156; "Shortcut Dimension 3 Code"; Code[20])
        {
            CaptionClass = '1,2,3';
            Caption = 'Shortcut Dimension 3 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(3)));
        }
        field(5157; "Shortcut Dimension 4 Code"; Code[20])
        {
            CaptionClass = '1,2,4';
            Caption = 'Shortcut Dimension 4 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(4)));
        }
        field(5158; "Shortcut Dimension 5 Code"; Code[20])
        {
            CaptionClass = '1,2,5';
            Caption = 'Shortcut Dimension 5 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(5)));
        }
        field(5159; "Shortcut Dimension 6 Code"; Code[20])
        {
            CaptionClass = '1,2,6';
            Caption = 'Shortcut Dimension 6 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(6)));
        }
        field(5160; "Shortcut Dimension 7 Code"; Code[20])
        {
            CaptionClass = '1,2,7';
            Caption = 'Shortcut Dimension 7 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(7)));
        }
        field(5161; "Shortcut Dimension 8 Code"; Code[20])
        {
            CaptionClass = '1,2,8';
            Caption = 'Shortcut Dimension 8 Code';
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"), "Global Dimension No." = const(8)));
        }
        field(5162; "User ID"; Code[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";
            DataClassification = EndUserIdentifiableInformation;
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SummaryOnChartPage; "Account No.", "Posting Date", "Dimension Set ID", "Global Dimension 1 Code", "Global Dimension 2 Code", "Responsibility Center")
        {
            SumIndexFields = "Emission CO2", "Emission CH4", "Emission N2O";
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
        EntryRecIDLbl: Label '%1 %2', Locked = true;

    local procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo(EntryRecIDLbl, TableCaption(), "Entry No."));
    end;
}