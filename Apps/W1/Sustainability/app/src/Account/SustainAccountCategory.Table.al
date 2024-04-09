namespace Microsoft.Sustainability.Account;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.Dimension;
using Microsoft.Sustainability.Ledger;

table 6211 "Sustain. Account Category"
{
    Caption = 'Sustainability Account Category';
    DataClassification = CustomerContent;
    LookupPageID = "Sustain. Account Categories";
    DrillDownPageId = "Sustain. Account Categories";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Emission Scope"; Enum "Emission Scope")
        {
            Caption = 'Emission Scope';
            NotBlank = true;

            trigger OnValidate()
            begin
                CheckIfChangeIsAllowedForCategory(FieldCaption("Emission Scope"));
            end;
        }
        field(4; CO2; Boolean)
        {
            Caption = 'CO2';

            trigger OnValidate()
            begin
                CheckIfChangeIsAllowedForCategory(FieldCaption(CO2));
            end;
        }
        field(5; CH4; Boolean)
        {
            Caption = 'CH4';

            trigger OnValidate()
            begin
                CheckIfChangeIsAllowedForCategory(FieldCaption(CH4));
            end;
        }
        field(6; N2O; Boolean)
        {
            Caption = 'N2O';

            trigger OnValidate()
            begin
                CheckIfChangeIsAllowedForCategory(FieldCaption(N2O));
            end;
        }
        field(7; "Calculation Foundation"; Enum "Calculation Foundation")
        {
            Caption = 'Calculation Foundation';

            trigger OnValidate()
            begin
                CheckIfChangeIsAllowedForCategory(FieldCaption("Calculation Foundation"));

                if "Calculation Foundation" <> "Calculation Foundation"::Custom then begin
                    Validate("Custom Value", '');
                    Validate("Calculate from General Ledger", false);
                end;
            end;
        }
        field(8; "Custom Value"; Text[100])
        {
            Caption = 'Custom Value';
            trigger OnValidate()
            begin
                if "Custom Value" <> '' then
                    TestField("Calculation Foundation", "Calculation Foundation"::Custom);
            end;
        }
        field(9; "Calculate from General Ledger"; Boolean)
        {
            Caption = 'Calculate from General Ledger';
            trigger OnValidate()
            begin
                if "Calculate from General Ledger" then
                    TestField("Calculation Foundation", "Calculation Foundation"::Custom)
                else begin
                    Validate("G/L Account Filter", '');
                    Validate("Global Dimension 1 Filter", '');
                    Validate("Global Dimension 2 Filter", '');
                end;
            end;
        }
        field(10; "G/L Account Filter"; Text[250])
        {
            Caption = 'G/L Account';
            trigger OnValidate()
            begin
                if "G/L Account Filter" <> '' then
                    TestField("Calculate from General Ledger", true);
            end;

            trigger OnLookup()
            var
                GLAccountList: Page "G/L Account List";
            begin
                GLAccountList.LookupMode(true);
                if GLAccountList.RunModal() = Action::LookupOK then
                    Validate("G/L Account Filter", CopyStr(GLAccountList.GetSelectionFilter(), 1, MaxStrLen("G/L Account Filter")));
            end;
        }
        field(11; "Global Dimension 1 Filter"; Text[250])
        {
            CaptionClass = '1,1,1';
            trigger OnValidate()
            begin
                if "Global Dimension 1 Filter" <> '' then
                    TestField("Calculate from General Ledger", true);
            end;

            trigger OnLookup()
            var
                GLSetup: Record "General Ledger Setup";
                DimensionValue: Record "Dimension Value";
                DimensionValueList: Page "Dimension Value List";
            begin
                GLSetup.Get();
                DimensionValue.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
                DimensionValueList.SetTableView(DimensionValue);
                DimensionValueList.LookupMode(true);

                if DimensionValueList.RunModal() = Action::LookupOK then
                    Validate("Global Dimension 1 Filter", CopyStr(DimensionValueList.GetSelectionFilter(), 1, MaxStrLen("Global Dimension 1 Filter")));
            end;
        }
        field(12; "Global Dimension 2 Filter"; Text[250])
        {
            CaptionClass = '1,1,2';
            trigger OnValidate()
            begin
                if "Global Dimension 2 Filter" <> '' then
                    TestField("Calculate from General Ledger", true);
            end;

            trigger OnLookup()
            var
                GLSetup: Record "General Ledger Setup";
                DimensionValue: Record "Dimension Value";
                DimensionValueList: Page "Dimension Value List";
            begin
                GLSetup.Get();
                DimensionValue.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
                DimensionValueList.SetTableView(DimensionValue);
                DimensionValueList.LookupMode(true);

                if DimensionValueList.RunModal() = Action::LookupOK then
                    Validate("Global Dimension 2 Filter", CopyStr(DimensionValueList.GetSelectionFilter(), 1, MaxStrLen("Global Dimension 2 Filter")));
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        DeleteSubcategories();
        UpdateSustainabilityAccounts();
        UpdateSustainabilityEntries();
    end;

    trigger OnInsert()
    begin
        TestField(Code);
    end;

    trigger OnModify()
    begin
        if "Calculation Foundation" = "Calculation Foundation"::Custom then
            TestField("Custom Value");
    end;

    var
        DeleteSubcategoriesQst: Label 'One or more subcategories belong to category ''''%1''''.\\Do you want to delete category with all the related subcategories? ', Comment = '%1 - category code';

    local procedure DeleteSubcategories(): Boolean
    var
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
    begin
        SustainAccountSubcategory.SetRange("Category Code", Code);
        if not SustainAccountSubcategory.IsEmpty() then
            if Confirm(StrSubstNo(DeleteSubcategoriesQst, Code)) then
                SustainAccountSubcategory.DeleteAll(true)
            else
                Error('');
    end;

    local procedure UpdateSustainabilityAccounts()
    var
        SustainAccount: Record "Sustainability Account";
    begin
        SustainAccount.SetRange(Category, Code);
        if not SustainAccount.IsEmpty() then
            SustainAccount.ModifyAll(Category, '');
    end;

    local procedure UpdateSustainabilityEntries()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
    begin
        SustainabilityLedgerEntry.SetRange("Account Category", Code);
        if not SustainabilityLedgerEntry.IsEmpty() then
            SustainabilityLedgerEntry.ModifyAll("Account Category", '');
    end;

    local procedure CheckIfChangeIsAllowedForCategory(FieldCaption: Text)
    var
        SustainabilityAccountMgt: Codeunit "Sustainability Account Mgt.";
    begin
        SustainabilityAccountMgt.CheckIfChangeAllowedForCategory(Code, FieldCaption);
        SustainabilityAccountMgt.ReCalculateJournalLinesForCategory(Rec);
    end;
}