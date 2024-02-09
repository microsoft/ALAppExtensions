codeunit 148182 "Library - Sustainability"
{
    procedure InsertAccountCategory(Code: Code[20]; Description: Text[100]; Scope: Enum "Emission Scope"; CalcFoundation: Enum "Calculation Foundation"; CO2: Boolean; CH4: Boolean; N2O: Boolean; CustomValue: Text[100]; CalcFromGL: Boolean): Record "Sustain. Account Category"
    var
        SustainAccountCategory: Record "Sustain. Account Category";
    begin
        SustainAccountCategory.Validate(Code, Code);
        SustainAccountCategory.Validate(Description, Description);
        SustainAccountCategory.Validate("Emission Scope", Scope);
        SustainAccountCategory.Validate("Calculation Foundation", CalcFoundation);
        SustainAccountCategory.Validate(CO2, CO2);
        SustainAccountCategory.Validate(CH4, CH4);
        SustainAccountCategory.Validate(N2O, N2O);
        SustainAccountCategory.Validate("Custom Value", CustomValue);
        SustainAccountCategory.Validate("Calculate from General Ledger", CalcFromGL);

        SustainAccountCategory.Insert(true);

        exit(SustainAccountCategory);
    end;

    procedure InsertAccountSubcategory(CategoryCode: Code[20]; SubcategoryCode: Code[20]; Description: Text[100]; EFCO2: Decimal; EFCH4: Decimal; EFN2O: Decimal; RenewableEnergy: Boolean): Record "Sustain. Account Subcategory"
    var
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
    begin
        SustainAccountSubcategory.Validate("Category Code", CategoryCode);
        SustainAccountSubcategory.Validate(Code, SubcategoryCode);
        SustainAccountSubcategory.Validate(Description, Description);
        SustainAccountSubcategory.Validate("Emission Factor CO2", EFCO2);
        SustainAccountSubcategory.Validate("Emission Factor CH4", EFCH4);
        SustainAccountSubcategory.Validate("Emission Factor N2O", EFN2O);
        SustainAccountSubcategory.Validate("Renewable Energy", RenewableEnergy);

        SustainAccountSubcategory.Insert(true);

        exit(SustainAccountSubcategory);
    end;

    procedure InsertSustainabilityAccount(AccountNo: Code[20]; Name: Text[100]; CategoryCode: Code[20]; SubcategoryCode: Code[20]; AccountType: Enum "Sustainability Account Type"; Totaling: Text[250]; DirectPosting: Boolean): Record "Sustainability Account"
    var
        SustainabilityAccount: Record "Sustainability Account";
    begin
        SustainabilityAccount.Validate("No.", AccountNo);
        SustainabilityAccount.Validate(Name, Name);
        SustainabilityAccount.Validate(Category, CategoryCode);
        SustainabilityAccount.Validate(Subcategory, SubcategoryCode);
        SustainabilityAccount.Validate("Account Type", AccountType);
        SustainabilityAccount.Validate(Totaling, Totaling);
        SustainabilityAccount.Validate("Direct Posting", DirectPosting);

        SustainabilityAccount.Insert(true);

        exit(SustainabilityAccount);
    end;

    procedure GetAReadyToPostAccount() Account: Record "Sustainability Account"
    var
        CategoryTok, SubcategoryTok, AccountTok : Code[20];
    begin
        CategoryTok := 'Test Category';
        SubcategoryTok := 'Test Subcategory';
        AccountTok := '1001';
        InsertAccountCategory(CategoryTok, '', Enum::"Emission Scope"::"Scope 1", Enum::"Calculation Foundation"::"Fuel/Electricity", true, true, true, '', false);
        InsertAccountSubcategory(CategoryTok, SubcategoryTok, '', 1, 2, 3, false);
        Account := InsertSustainabilityAccount(AccountTok, 'Test Acc', CategoryTok, SubcategoryTok, Enum::"Sustainability Account Type"::Posting, '', true);
    end;

    procedure InsertSustainabilityJournalLine(SustainabilityJnlBatch: Record "Sustainability Jnl. Batch"; SustainabilityAccount: Record "Sustainability Account"; LineNo: Integer) SustainabilityJournalLine: Record "Sustainability Jnl. Line"
    begin
        SustainabilityJournalLine.Validate("Journal Template Name", SustainabilityJnlBatch."Journal Template Name");
        SustainabilityJournalLine.Validate("Journal Batch Name", SustainabilityJnlBatch.Name);
        SustainabilityJournalLine.Validate("Line No.", LineNo);
        SustainabilityJournalLine.Validate("Account No.", SustainabilityAccount."No.");
        SustainabilityJournalLine.Validate("Document No.", 'Test1001');
        SustainabilityJournalLine.Validate("Posting Date", WorkDate());
        SustainabilityJournalLine.Insert(true);
    end;

    procedure CleanUpBeforeTesting()
    var
        SustainabilityJnlTemplate: Record "Sustainability Jnl. Template";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityAccountCategory: Record "Sustain. Account Category";
        SustainabilityAccountSubcategory: Record "Sustain. Account Subcategory";
    begin
        SustainabilityJnlTemplate.DeleteAll();
        SustainabilityJnlBatch.DeleteAll();
        SustainabilityJnlLine.DeleteAll();
        SustainabilityLedgerEntry.DeleteAll();
        SustainabilityAccount.DeleteAll();
        SustainabilityAccountCategory.DeleteAll();
        SustainabilityAccountSubcategory.DeleteAll();
    end;
}