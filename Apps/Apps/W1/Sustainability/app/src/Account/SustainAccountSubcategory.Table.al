namespace Microsoft.Sustainability.Account;

using Microsoft.Sustainability.Energy;
using Microsoft.Sustainability.Setup;
using Microsoft.Sustainability.Ledger;

table 6212 "Sustain. Account Subcategory"
{
    Caption = 'Sustainability Account Subcategory';
    DataClassification = CustomerContent;
    LookupPageID = "Sustain. Account Subcategories";
    DrillDownPageId = "Sustain. Account Subcategories";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Category Code"; Code[20])
        {
            Caption = 'Category Code';
            TableRelation = "Sustain. Account Category";
            NotBlank = true;
        }
        field(4; "Emission Factor CO2"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission Factor CO2';
            CaptionClass = '102,5,1';

            trigger OnValidate()
            begin
                if Rec."Emission Factor CO2" <> 0 then
                    CheckSustAccountSubCategoryByField(Rec, Rec.FieldNo("Emission Factor CO2"));

                CheckIfChangeAllowedAndRecalculateJournalLines(FieldCaption("Emission Factor CO2"));
            end;
        }
        field(5; "Emission Factor CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission Factor CH4';
            CaptionClass = '102,5,2';

            trigger OnValidate()
            begin
                if Rec."Emission Factor CH4" <> 0 then
                    CheckSustAccountSubCategoryByField(Rec, Rec.FieldNo("Emission Factor CH4"));

                CheckIfChangeAllowedAndRecalculateJournalLines(FieldCaption("Emission Factor CH4"));
            end;
        }
        field(6; "Emission Factor N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission Factor N2O';
            CaptionClass = '102,5,3';

            trigger OnValidate()
            begin
                if Rec."Emission Factor N2O" <> 0 then
                    CheckSustAccountSubCategoryByField(Rec, Rec.FieldNo("Emission Factor N2O"));

                CheckIfChangeAllowedAndRecalculateJournalLines(FieldCaption("Emission Factor N2O"));
            end;
        }
        field(7; "Import Data"; Boolean)
        {
            Caption = 'Import Data';
        }
        field(8; "Import From"; Text[250])
        {
            Caption = 'Import From';
        }
        field(9; "Renewable Energy"; Boolean)
        {
            Caption = 'Renewable Energy';

            trigger OnValidate()
            begin
                if Rec."Renewable Energy" then begin
                    Rec.TestField("Water Intensity Factor", 0);
                    Rec.TestField("Waste Intensity Factor", 0);
                    Rec.TestField("Discharged Into Water Factor", 0);
                end;
            end;
        }
        field(10; "Water Intensity Factor"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Water Intensity Factor';

            trigger OnValidate()
            begin
                if Rec."Water Intensity Factor" <> 0 then
                    CheckSustAccountSubCategoryByField(Rec, Rec.FieldNo("Water Intensity Factor"));

                CheckIfChangeAllowedAndRecalculateJournalLines(FieldCaption("Water Intensity Factor"));
            end;
        }
        field(11; "Discharged Into Water Factor"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Discharged Into Water Factor';

            trigger OnValidate()
            begin
                if Rec."Discharged Into Water Factor" <> 0 then
                    CheckSustAccountSubCategoryByField(Rec, Rec.FieldNo("Discharged Into Water Factor"));

                CheckIfChangeAllowedAndRecalculateJournalLines(FieldCaption("Discharged Into Water Factor"));
            end;
        }
        field(12; "Waste Intensity Factor"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Waste Intensity Factor';

            trigger OnValidate()
            begin
                if Rec."Waste Intensity Factor" <> 0 then
                    CheckSustAccountSubCategoryByField(Rec, Rec.FieldNo("Waste Intensity Factor"));

                CheckIfChangeAllowedAndRecalculateJournalLines(FieldCaption("Waste Intensity Factor"));
            end;
        }
        field(13; "Energy Source Code"; Code[20])
        {
            Caption = 'Energy Source Code';
            TableRelation = "Sustainability Energy Source";
            ToolTip = 'Specifies the code assigned to the energy source you want to add.';
        }
        field(14; "Energy Value Required"; Boolean)
        {
            Caption = 'Energy Value Required';
        }
        field(15; "Energy Onsite"; Boolean)
        {
            Caption = 'Energy Onsite';
            ToolTip = 'Specifies the energy source used for generation is onsite or not.';
        }
    }

    keys
    {
        key(Key1; "Category Code", "Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
    begin
        SustainabilityAccount.SetRange(Category, "Category Code");
        SustainabilityAccount.SetRange(Subcategory, Code);
        if not SustainabilityAccount.IsEmpty() then
            SustainabilityAccount.ModifyAll(Subcategory, '');

        SustainabilityLedgerEntry.SetRange("Account Category", "Category Code");
        SustainabilityLedgerEntry.SetRange("Account Subcategory", Code);
        if not SustainabilityLedgerEntry.IsEmpty() then
            SustainabilityLedgerEntry.ModifyAll("Account Subcategory", '');
    end;

    trigger OnInsert()
    begin
        TestField("Category Code");
        TestField(Code);
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";

    local procedure CheckIfChangeAllowedAndRecalculateJournalLines(FieldCaption: Text)
    var
        SustainabilityAccountMgt: Codeunit "Sustainability Account Mgt.";
    begin
        SustainabilityAccountMgt.CheckIfChangeAllowedForSubcategory(Code, FieldCaption);
        SustainabilityAccountMgt.ReCalculateJournalLinesForSubcategory(Rec);
    end;

    local procedure CheckSustAccountSubCategoryByField(SustAccountSubCategory: Record "Sustain. Account Subcategory"; CurrentFieldNo: Integer)
    var
        SustAccountCategory: Record "Sustain. Account Category";
    begin
        case CurrentFieldNo of
            SustAccountSubCategory.FieldNo("Water Intensity Factor"),
            SustAccountSubCategory.FieldNo("Waste Intensity Factor"),
            SustAccountSubCategory.FieldNo("Discharged Into Water Factor"):
                begin
                    SustAccountCategory.Get(SustAccountSubCategory."Category Code");
                    SustAccountSubCategory.TestField("Renewable Energy", false);

                    if SustAccountSubCategory."Water Intensity Factor" <> 0 then
                        SustAccountCategory.TestField("Water Intensity", true);

                    if SustAccountSubCategory."Discharged Into Water Factor" <> 0 then
                        SustAccountCategory.TestField("Discharged Into Water", true);

                    if SustAccountSubCategory."Waste Intensity Factor" <> 0 then
                        SustAccountCategory.TestField("Waste Intensity", true);
                end;
            SustAccountSubCategory.FieldNo("Emission Factor CO2"),
            SustAccountSubCategory.FieldNo("Emission Factor CH4"),
            SustAccountSubCategory.FieldNo("Emission Factor N2O"):
                begin
                    SustAccountCategory.Get(SustAccountSubCategory."Category Code");
                    SustAccountCategory.TestField("Water Intensity", false);
                    SustAccountCategory.TestField("Waste Intensity", false);
                    SustAccountCategory.TestField("Discharged Into Water", false);
                end;
        end;
    end;
}