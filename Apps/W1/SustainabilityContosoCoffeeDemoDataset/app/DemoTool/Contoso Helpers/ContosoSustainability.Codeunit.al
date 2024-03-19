codeunit 5216 "Contoso Sustainability"
{
    InherentPermissions = X;
    InherentEntitlements = X;
    Permissions =
        tabledata "Sustain. Account Category" = rim,
        tabledata "Sustain. Account Subcategory" = rim,
        tabledata "Sustainability Account" = rim,
        tabledata "Sustainability Jnl. Template" = rim,
        tabledata "Sustainability Jnl. Batch" = rim,
        tabledata "Sustainability Jnl. Line" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertAccountCategory(Code: Code[20]; Description: Text[100]; Scope: Enum "Emission Scope"; CalcFoundation: Enum "Calculation Foundation"; CO2: Boolean; CH4: Boolean; N2O: Boolean; CustomValue: Text[100]; CalcFromGL: Boolean)
    var
        SustainAccountCategory: Record "Sustain. Account Category";
        Exists: Boolean;
    begin
        if SustainAccountCategory.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        SustainAccountCategory.Validate(Code, Code);
        SustainAccountCategory.Validate(Description, Description);
        SustainAccountCategory.Validate("Emission Scope", Scope);
        SustainAccountCategory.Validate("Calculation Foundation", CalcFoundation);
        SustainAccountCategory.Validate(CO2, CO2);
        SustainAccountCategory.Validate(CH4, CH4);
        SustainAccountCategory.Validate(N2O, N2O);
        SustainAccountCategory.Validate("Custom Value", CustomValue);
        SustainAccountCategory.Validate("Calculate from General Ledger", CalcFromGL);

        if Exists then
            SustainAccountCategory.Modify(true)
        else
            SustainAccountCategory.Insert(true);
    end;

    procedure InsertAccountSubcategory(CategoryCode: Code[20]; SubcategoryCode: Code[20]; Description: Text[100]; EFCO2: Decimal; EFCH4: Decimal; EFN2O: Decimal; RenewableEnergy: Boolean)
    var
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        Exists: Boolean;
    begin
        if SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        SustainAccountSubcategory.Validate("Category Code", CategoryCode);
        SustainAccountSubcategory.Validate(Code, SubcategoryCode);
        SustainAccountSubcategory.Validate(Description, Description);
        SustainAccountSubcategory.Validate("Emission Factor CO2", EFCO2);
        SustainAccountSubcategory.Validate("Emission Factor CH4", EFCH4);
        SustainAccountSubcategory.Validate("Emission Factor N2O", EFN2O);
        SustainAccountSubcategory.Validate("Renewable Energy", RenewableEnergy);

        if Exists then
            SustainAccountSubcategory.Modify(true)
        else
            SustainAccountSubcategory.Insert(true);
    end;

    procedure InsertSustainabilityAccount(AccountNo: Code[20]; Name: Text[100]; CategoryCode: Code[20]; SubcategoryCode: Code[20]; AccountType: Enum "Sustainability Account Type"; Totaling: Text[250]; DirectPosting: Boolean)
    var
        SustainabilityAccount: Record "Sustainability Account";
        Exists: Boolean;
    begin
        if SustainabilityAccount.Get(AccountNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        SustainabilityAccount.Validate("No.", AccountNo);
        SustainabilityAccount.Validate(Name, Name);
        SustainabilityAccount.Validate(Category, CategoryCode);
        SustainabilityAccount.Validate(Subcategory, SubcategoryCode);
        SustainabilityAccount.Validate("Account Type", AccountType);
        SustainabilityAccount.Validate(Totaling, Totaling);
        SustainabilityAccount.Validate("Direct Posting", DirectPosting);

        if Exists then
            SustainabilityAccount.Modify(true)
        else
            SustainabilityAccount.Insert(true);
    end;

    procedure InsertSustainabilityJournalTemplate(Name: Code[10]; Description: Text[80]; Recurring: Boolean)
    var
        SustainabilityJnlTemplate: Record "Sustainability Jnl. Template";
        Exists: Boolean;
    begin
        if SustainabilityJnlTemplate.Get(Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        SustainabilityJnlTemplate.Validate(Name, Name);
        SustainabilityJnlTemplate.Validate(Description, Description);
        SustainabilityJnlTemplate.Validate(Recurring, Recurring);

        if Exists then
            SustainabilityJnlTemplate.Modify(true)
        else
            SustainabilityJnlTemplate.Insert(true);
    end;

    procedure InsertSustainabilityJournalBatch(TemplateName: Code[10]; BatchName: Code[10]; Description: Text[100]; NoSeries: Code[20]; EmissionScope: Enum "Emission Scope"; SourceCode: Code[10])
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        Exists: Boolean;
    begin
        if SustainabilityJnlBatch.Get(TemplateName, BatchName) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        SustainabilityJnlBatch.Validate("Journal Template Name", TemplateName);
        SustainabilityJnlBatch.Validate(Name, BatchName);
        SustainabilityJnlBatch.Validate(Description, Description);
        SustainabilityJnlBatch.Validate("No Series", NoSeries);
        SustainabilityJnlBatch.Validate("Emission Scope", EmissionScope);
        SustainabilityJnlBatch.Validate("Source Code", SourceCode);

        if Exists then
            SustainabilityJnlBatch.Modify(true)
        else
            SustainabilityJnlBatch.Insert(true);
    end;

    procedure InsertSustainabilityJournalLine(TemplateName: Code[10]; BatchName: Code[10]; PostingDate: Date; DocumentNo: Code[20]; AccountNo: Code[20]; ManualInput: Boolean; UoM: Code[10]; FuelElectricity: Decimal; Distance: Decimal; CustomAmount: Decimal; Installation: Decimal; TimeFactor: Decimal; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal; CountryOrRegion: Code[10]; ResponsibilityCenter: Code[10])
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
    begin
        SustainabilityJnlLine.Validate("Journal Template Name", TemplateName);
        SustainabilityJnlLine.Validate("Journal Batch Name", BatchName);
        SustainabilityJnlLine.Validate("Line No.", GetNextSustainabilityJournalLineNo(TemplateName, BatchName));
        SustainabilityJnlLine.Validate("Posting Date", PostingDate);
        SustainabilityJnlLine.Validate("Document No.", DocumentNo);
        SustainabilityJnlLine.Validate("Account No.", AccountNo);
        SustainabilityJnlLine.Validate("Manual Input", ManualInput);
        SustainabilityJnlLine.Validate("Country/Region Code", CountryOrRegion);
        SustainabilityJnlLine.Validate("Responsibility Center", ResponsibilityCenter);

        if ManualInput then begin
            SustainabilityJnlLine.Validate("Emission CO2", EmissionCO2);
            SustainabilityJnlLine.Validate("Emission CH4", EmissionCH4);
            SustainabilityJnlLine.Validate("Emission N2O", EmissionN2O);
        end else begin
            SustainabilityJnlLine.Validate("Unit of Measure", UoM);
            SustainabilityJnlLine.Validate("Fuel/Electricity", FuelElectricity);
            SustainabilityJnlLine.Validate(Distance, Distance);
            SustainabilityJnlLine.Validate("Custom Amount", CustomAmount);
            SustainabilityJnlLine.Validate("Installation Multiplier", Installation);
            SustainabilityJnlLine.Validate("Time Factor", TimeFactor);
        end;

        SustainabilityJnlLine.Insert(true);
    end;

    procedure InsertSustainabilityJournalLine(TemplateName: Code[10]; BatchName: Code[10]; PostingDate: Date; DocumentNo: Code[20]; AccountNo: Code[20]; UoM: Code[10]; FuelElectricity: Decimal; Distance: Decimal; CustomAmount: Decimal; Installation: Decimal; TimeFactor: Decimal; CountryOrRegion: Code[10]; ResponsibilityCenter: Code[10])
    begin
        InsertSustainabilityJournalLine(TemplateName, BatchName, PostingDate, DocumentNo, AccountNo, false, UoM, FuelElectricity, Distance, CustomAmount, Installation, TimeFactor, 0, 0, 0, CountryOrRegion, ResponsibilityCenter);
    end;

    procedure InsertSustainabilityJournalLine(TemplateName: Code[10]; BatchName: Code[10]; PostingDate: Date; DocumentNo: Code[20]; AccountNo: Code[20]; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal; CountryOrRegion: Code[10]; ResponsibilityCenter: Code[10])
    begin
        InsertSustainabilityJournalLine(TemplateName, BatchName, PostingDate, DocumentNo, AccountNo, true, '', 0, 0, 0, 1, 0, EmissionCO2, EmissionCH4, EmissionN2O, CountryOrRegion, ResponsibilityCenter);
    end;

    local procedure GetNextSustainabilityJournalLineNo(TemplateName: Code[10]; BatchName: Code[10]): Integer
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
    begin
        SustainabilityJnlLine.SetRange("Journal Template Name", TemplateName);
        SustainabilityJnlLine.SetRange("Journal Batch Name", BatchName);
        SustainabilityJnlLine.SetCurrentKey("Line No.");

        if SustainabilityJnlLine.FindLast() then
            exit(SustainabilityJnlLine."Line No." + 10000)
        else
            exit(10000);
    end;
}