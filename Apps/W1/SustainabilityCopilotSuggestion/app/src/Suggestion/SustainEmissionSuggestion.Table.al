// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;
using Microsoft.Sustainability.Journal;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.UOM;
using Microsoft.Sustainability.Setup;
using Microsoft.Sustainability.Account;
using System.Reflection;

table 6290 "Sustain. Emission Suggestion"
{
    Caption = 'Sustainability Emission Suggestion';
    TableType = Temporary;
    DataClassification = CustomerContent;
    Access = Internal;
    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Sustainability Jnl. Template";
            Editable = false;
            NotBlank = true;
            ToolTip = 'Specifies the name of the journal template';
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Sustainability Jnl. Batch".Name where("Journal Template Name" = field("Journal Template Name"));
            Editable = false;
            NotBlank = true;
            ToolTip = 'Specifies the name of the journal batch';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
            NotBlank = true;
            ToolTip = 'Specifies the line number of the journal line';
        }
        field(7; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = "Sustainability Account" where("Account Type" = const(Posting), Blocked = const(false));
            Editable = false;
            ToolTip = 'Specifies the sustainability account number';
        }
        field(8; "Account Name"; Text[100])
        {
            Caption = 'Account Name';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies the sustainability account name';
        }
        field(9; "Account Category"; Code[20])
        {
            Caption = 'Account Category';
            Editable = false;
            TableRelation = "Sustain. Account Category";
            ToolTip = 'Specifies the sustainability account category';
        }
        field(10; "Account Subcategory"; Code[20])
        {
            Caption = 'Account Subcategory';
            Editable = false;
            TableRelation = "Sustain. Account Subcategory".Code where("Category Code" = field("Account Category"));
            ToolTip = 'Specifies the sustainability account subcategory';
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the journal line';
        }
        field(13; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Unit of Measure";
            ToolTip = 'Specifies the unit of measure of the journal line.';
        }
        field(14; "Fuel/Electricity"; Decimal)
        {
            AutoFormatType = 11;
            Caption = 'Fuel/Electricity';
            ToolTip = 'Specifies the amount of fuel or electricity used in the journal line';
        }
        field(15; Distance; Decimal)
        {
            AutoFormatType = 11;
            Caption = 'Distance';
            ToolTip = 'Specifies the distance of the journal line';
        }
        field(16; "Custom Amount"; Decimal)
        {
            AutoFormatType = 11;
            Caption = 'Custom Amount';
            ToolTip = 'Specifies the custom amount of the journal line';
        }
        field(17; "Installation Multiplier"; Decimal)
        {
            Caption = 'Installation Multiplier';
            ToolTip = 'Specifies the installation multiplier of the journal line';
            AutoFormatType = 1;
            AutoFormatExpression = '';
        }
        field(18; "Time Factor"; Decimal)
        {
            Caption = 'Time Factor';
            MaxValue = 1;
            ToolTip = 'Specifies the time factor of the journal line';
            AutoFormatType = 1;
            AutoFormatExpression = '';
        }
        field(19; "Emission CO2"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            BlankZero = true;
            Caption = 'Emission CO2';
            Editable = false;
            ToolTip = 'Specifies the CO2 emission of the journal line';
        }
        field(22; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
            ToolTip = 'Specifies the country/region code of the journal line';
        }
        field(23; "Emission Calc. Explanation"; Blob)
        {
            Caption = 'Emission Calculation Explanation';
            ToolTip = 'Specifies the explanation of the emission calculation';
        }
        field(24; "Emission Formula Json"; Blob)
        {
            Caption = 'Emission Formula';
            ToolTip = 'Specifies the json of the formula';
        }
        field(25; "Emission Factor CO2"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            BlankZero = true;
            Editable = false;
            Caption = 'Emission Factor CO2';
            ToolTip = 'Specifies the CO2 emission factor';
        }
        field(26; "Factor Taken From Source"; Boolean)
        {
            Editable = false;
            Caption = 'Factor Taken From Source';
            ToolTip = 'Specifies whether the emission factor is taken from the source';
        }
        field(28; "Emission Factor Source"; Text[1024])
        {
            Editable = false;
            Caption = 'Source';
            ToolTip = 'Specifies the source of the emission factor';
        }
        field(29; "Calculated by Copilot"; Boolean)
        {
            Editable = false;
            Caption = 'Calculated by Copilot';
            ToolTip = 'Specifies whether the emission factor is calculated by Copilot';
        }
        field(30; "Exclude From Copilot"; Boolean)
        {
            Editable = false;
            Caption = 'Exclude From Copilot';
            ToolTip = 'Specifies if the account category should be excluded from Copilot suggestions.';
        }
        field(31; "No. of Warnings"; Integer)
        {
            MinValue = 0;
            Editable = false;
            Caption = 'No. of Warnings';
            ToolTip = 'Specifies the number of warnings';
        }
        field(32; "Warning Text"; Text[1024])
        {
            Editable = false;
            Caption = 'Warning Text';
            ToolTip = 'Specifies the warning text';
        }
        field(33; "Warning Confidence"; Decimal)
        {
            MinValue = 0;
            Editable = false;
            Caption = 'Warning Confidence';
            ToolTip = 'Specifies the confidence based on the warnings';
            AutoFormatType = 1;
            AutoFormatExpression = '';
        }
        field(34; "Raw Formula"; Text[1024])
        {
            Editable = false;
            Caption = 'Raw Formula';
            ToolTip = 'Specifies the raw formula retrieved by Copilot.';
        }
        field(51; "Accept Emission Factor"; Boolean)
        {
            Editable = false;
            Caption = 'Accept Emission Factor';
            ToolTip = 'Specifies whether the emission factor is accepted and will be updated on sustainability account subcategory';
        }
        field(52; "Exclude From User Message"; Boolean)
        {
            Editable = false;
            Caption = 'Exclude From User Message';
            ToolTip = 'Specifies whether the emission suggestion should be excluded from user message';
        }
    }

    keys
    {
        key(PK; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilitySetupRetrieved: Boolean;
        AutoFormatExprLbl: Label '<Precision,%1><Standard Format,0>', Locked = true;

    local procedure GetSustainabilitySetup()
    begin
        if SustainabilitySetupRetrieved then
            exit;

        SustainabilitySetup.Get();
        SustainabilitySetupRetrieved := true;
    end;

    local procedure CalculateWarningConfidence()
    begin
        case Rec."No. of Warnings" of
            0:
                Rec."Warning Confidence" := 100;
            1:
                Rec."Warning Confidence" := 75;
            2:
                Rec."Warning Confidence" := 50;
            3:
                Rec."Warning Confidence" := 25;
            else
                Rec."Warning Confidence" := 0;
        end;
    end;

    procedure SetStyle(): Text
    begin
        if not Rec."Calculated by Copilot" then
            exit('Standard');

        case "No. of Warnings" of
            0:
                exit('Standard');
            else
                exit('Attention');
        end;
    end;

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

    procedure UpdateSustainabilityJournalLine()
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
    begin
        if Rec."Emission CO2" <= 0 then
            exit;
        if not SustainabilityJnlLine.Get(Rec."Journal Template Name", Rec."Journal Batch Name", Rec."Line No.") then
            exit;

        SustainabilityJnlLine.Validate("Calculated by Copilot", true);
        SustainabilityJnlLine.Validate(Description, Rec."Description");
        SustainabilityJnlLine.Validate(Distance, Rec.Distance);
        SustainabilityJnlLine.Validate("Fuel/Electricity", Rec."Fuel/Electricity");
        SustainabilityJnlLine.Validate("Unit of Measure", Rec."Unit of Measure");
        SustainabilityJnlLine.Validate("Country/Region Code", Rec."Country/Region Code");
        SustainabilityJnlLine.Validate("Installation Multiplier", Rec."Installation Multiplier");
        SustainabilityJnlLine.Validate("Time Factor", Rec."Time Factor");
        SustainabilityJnlLine.Validate("Custom Amount", Rec."Custom Amount");
        SustainabilityJnlLine.Validate("Emission CO2", Rec."Emission CO2");
        SustainabilityJnlLine.Modify(true);
    end;

    procedure UpdateSubcategory()
    var
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
    begin
        if not Rec."Accept Emission Factor" then
            exit;
        if Rec."Emission Factor CO2" <= 0 then
            exit;

        SustainAccountSubcategory.Get(Rec."Account Category", Rec."Account Subcategory");
        if SustainAccountSubcategory."Emission Factor CO2" <> 0 then
            exit;

        SustainAccountSubcategory."Emission Factor CO2" := Rec."Emission Factor CO2";
        SustainAccountSubcategory.Validate("Calculated by Copilot", true);
        SustainAccountSubcategory.Validate("Emission Factor Source", Rec."Emission Factor Source");
        SustainAccountSubcategory.Modify(true);
    end;

    internal procedure GetFormulaText() Result: Text
    var
        TypeHelper: Codeunit "Type Helper";
        FormulaInStream: InStream;
        LineText: Text;
    begin
        Rec.CalcFields("Emission Calc. Explanation");
        if not Rec."Emission Calc. Explanation".HasValue() then
            exit('');

        Rec."Emission Calc. Explanation".CreateInStream(FormulaInStream);
        while not FormulaInStream.EOS do begin
            FormulaInStream.ReadText(LineText);
            if Result <> '' then
                Result += TypeHelper.CRLFSeparator();
            Result += LineText;
        end;
        exit(Result);
    end;

    procedure UpdateWarnings(NewWarningText: Text[1024])
    begin
        if Rec."Warning Text" = '' then
            Rec."Warning Text" := NewWarningText
        else
            Rec."Warning Text" += '\' + NewWarningText;

        Rec."No. of Warnings" += 1;
        CalculateWarningConfidence();
    end;
}