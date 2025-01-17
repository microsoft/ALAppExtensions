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
                CheckSustAccountCategoryByField(Rec, Rec.FieldNo("Emission Scope"));
                CheckIfChangeIsAllowedForCategory(FieldCaption("Emission Scope"));
            end;
        }
        field(4; CO2; Boolean)
        {
            Caption = 'CO2';

            trigger OnValidate()
            begin
                if Rec.CO2 then
                    CheckSustAccountCategoryByField(Rec, Rec.FieldNo(CO2))
                else
                    CheckSustAccountSubcategoryFactorByField(Rec, Rec.FieldNo(CO2));

                CheckIfChangeIsAllowedForCategory(FieldCaption(CO2));
            end;
        }
        field(5; CH4; Boolean)
        {
            Caption = 'CH4';

            trigger OnValidate()
            begin
                if Rec.CH4 then
                    CheckSustAccountCategoryByField(Rec, Rec.FieldNo(CH4))
                else
                    CheckSustAccountSubcategoryFactorByField(Rec, Rec.FieldNo(CH4));

                CheckIfChangeIsAllowedForCategory(FieldCaption(CH4));
            end;
        }
        field(6; N2O; Boolean)
        {
            Caption = 'N2O';

            trigger OnValidate()
            begin
                if Rec.N2O then
                    CheckSustAccountCategoryByField(Rec, Rec.FieldNo(N2O))
                else
                    CheckSustAccountSubcategoryFactorByField(Rec, Rec.FieldNo(N2O));

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
        field(13; "Water Intensity"; Boolean)
        {
            Caption = 'Water Intensity';

            trigger OnValidate()
            begin
                if Rec."Water Intensity" then
                    CheckSustAccountCategoryByField(Rec, Rec.FieldNo("Water Intensity"))
                else
                    CheckSustAccountSubcategoryFactorByField(Rec, Rec.FieldNo("Water Intensity"));

                CheckIfChangeIsAllowedForCategory(FieldCaption("Water Intensity"));
            end;
        }
        field(14; "Discharged Into Water"; Boolean)
        {
            Caption = 'Discharged Into Water';

            trigger OnValidate()
            begin
                if Rec."Discharged Into Water" then
                    CheckSustAccountCategoryByField(Rec, Rec.FieldNo("Discharged Into Water"))
                else
                    CheckSustAccountSubcategoryFactorByField(Rec, Rec.FieldNo("Discharged Into Water"));

                CheckIfChangeIsAllowedForCategory(FieldCaption("Discharged Into Water"));
            end;
        }
        field(15; "Waste Intensity"; Boolean)
        {
            Caption = 'Waste Intensity';

            trigger OnValidate()
            begin
                if Rec."Waste Intensity" then
                    CheckSustAccountCategoryByField(Rec, Rec.FieldNo("Waste Intensity"))
                else
                    CheckSustAccountSubcategoryFactorByField(Rec, Rec.FieldNo("Waste Intensity"));

                CheckIfChangeIsAllowedForCategory(FieldCaption("Waste Intensity"));
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
        EmissionScopeNotSupportedErr: Label 'Emission Scope %1 is not supported With CO2,N2O,CH4.', Comment = '%1 = Emission Scope';
        ValueMustBeEqualErr: Label '%1 must be equal to %2 in the %3 Category Code %4, Code %5.', Comment = '%1 = Field Caption , %2 = Expected Value, %3 = Table Caption, %4 = Category Code, %5 = Code';

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

    local procedure CheckSustAccountCategoryByField(SustAccountCategory: Record "Sustain. Account Category"; CurrentFieldNo: Integer)
    begin
        case CurrentFieldNo of
            SustAccountCategory.FieldNo("Water Intensity"),
            SustAccountCategory.FieldNo("Discharged Into Water"):
                begin
                    SustAccountCategory.TestField("Emission Scope", "Emission Scope"::"Water/Waste");
                    SustAccountCategory.TestField(CO2, false);
                    SustAccountCategory.TestField(CH4, false);
                    SustAccountCategory.TestField(N2O, false);
                    SustAccountCategory.TestField("Waste Intensity", false);
                end;
            SustAccountCategory.FieldNo("Waste Intensity"):
                begin
                    SustAccountCategory.TestField("Emission Scope", "Emission Scope"::"Water/Waste");
                    SustAccountCategory.TestField(CO2, false);
                    SustAccountCategory.TestField(CH4, false);
                    SustAccountCategory.TestField(N2O, false);
                    SustAccountCategory.TestField("Water Intensity", false);
                    SustAccountCategory.TestField("Discharged Into Water", false);
                end;
            SustAccountCategory.FieldNo(CO2),
            SustAccountCategory.FieldNo(CH4),
            SustAccountCategory.FieldNo(N2O):
                begin
                    if SustAccountCategory."Emission Scope" = SustAccountCategory."Emission Scope"::"Water/Waste" then
                        Error(EmissionScopeNotSupportedErr, SustAccountCategory."Emission Scope");

                    SustAccountCategory.TestField("Water Intensity", false);
                    SustAccountCategory.TestField("Discharged Into Water", false);
                    SustAccountCategory.TestField("Waste Intensity", false);
                end;
            SustAccountCategory.FieldNo("Emission Scope"):
                if SustAccountCategory."Emission Scope" = SustAccountCategory."Emission Scope"::"Water/Waste" then begin
                    SustAccountCategory.TestField(CO2, false);
                    SustAccountCategory.TestField(CH4, false);
                    SustAccountCategory.TestField(N2O, false);
                end else begin
                    SustAccountCategory.TestField("Water Intensity", false);
                    SustAccountCategory.TestField("Discharged Into Water", false);
                    SustAccountCategory.TestField("Waste Intensity", false);
                end;
        end;
    end;

    local procedure CheckSustAccountSubcategoryFactorByField(SustAccountCategory: Record "Sustain. Account Category"; CurrentFieldNo: Integer)
    var
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
    begin
        SustainAccountSubcategory.SetRange("Category Code", SustAccountCategory.Code);

        case CurrentFieldNo of
            SustAccountCategory.FieldNo(CO2):
                begin
                    SustainAccountSubcategory.SetFilter("Emission Factor CO2", '<>%1', 0);
                    if SustainAccountSubcategory.FindFirst() then
                        Error(ValueMustBeEqualErr, SustainAccountSubcategory.FieldCaption("Emission Factor CO2"), 0, SustainAccountSubcategory.TableCaption(), SustainAccountSubcategory."Category Code", SustainAccountSubcategory.Code);
                end;
            SustAccountCategory.FieldNo(CH4):
                begin
                    SustainAccountSubcategory.SetFilter("Emission Factor CH4", '<>%1', 0);
                    if SustainAccountSubcategory.FindFirst() then
                        Error(ValueMustBeEqualErr, SustainAccountSubcategory.FieldCaption("Emission Factor CH4"), 0, SustainAccountSubcategory.TableCaption(), SustainAccountSubcategory."Category Code", SustainAccountSubcategory.Code);
                end;
            SustAccountCategory.FieldNo(N2O):
                begin
                    SustainAccountSubcategory.SetFilter("Emission Factor N2O", '<>%1', 0);
                    if SustainAccountSubcategory.FindFirst() then
                        Error(ValueMustBeEqualErr, SustainAccountSubcategory.FieldCaption("Emission Factor N2O"), 0, SustainAccountSubcategory.TableCaption(), SustainAccountSubcategory."Category Code", SustainAccountSubcategory.Code);
                end;
            SustAccountCategory.FieldNo("Water Intensity"):
                begin
                    SustainAccountSubcategory.SetFilter("Water Intensity Factor", '<>%1', 0);
                    if SustainAccountSubcategory.FindFirst() then
                        Error(ValueMustBeEqualErr, SustainAccountSubcategory.FieldCaption("Water Intensity Factor"), 0, SustainAccountSubcategory.TableCaption(), SustainAccountSubcategory."Category Code", SustainAccountSubcategory.Code);
                end;
            SustAccountCategory.FieldNo("Waste Intensity"):
                begin
                    SustainAccountSubcategory.SetFilter("Waste Intensity Factor", '<>%1', 0);
                    if SustainAccountSubcategory.FindFirst() then
                        Error(ValueMustBeEqualErr, SustainAccountSubcategory.FieldCaption("Waste Intensity Factor"), 0, SustainAccountSubcategory.TableCaption(), SustainAccountSubcategory."Category Code", SustainAccountSubcategory.Code);
                end;
            SustAccountCategory.FieldNo("Discharged Into Water"):
                begin
                    SustainAccountSubcategory.SetFilter("Discharged Into Water Factor", '<>%1', 0);
                    if SustainAccountSubcategory.FindFirst() then
                        Error(ValueMustBeEqualErr, SustainAccountSubcategory.FieldCaption("Discharged Into Water Factor"), 0, SustainAccountSubcategory.TableCaption(), SustainAccountSubcategory."Category Code", SustainAccountSubcategory.Code);
                end;
        end;
    end;
}