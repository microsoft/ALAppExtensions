namespace Microsoft.Sustainability.Account;

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

            trigger OnValidate()
            begin
                CheckIfChangeAllowedAndRecalculateJournalLines(FieldCaption("Emission Factor CO2"));
            end;
        }
        field(5; "Emission Factor CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission Factor CH4';

            trigger OnValidate()
            begin
                CheckIfChangeAllowedAndRecalculateJournalLines(FieldCaption("Emission Factor CH4"));
            end;
        }
        field(6; "Emission Factor N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission Factor N2O';

            trigger OnValidate()
            begin
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
}