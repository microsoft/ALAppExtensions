#pragma warning disable AA0247
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
    begin
        InsertAccountCategory(Code, Description, Scope, CalcFoundation, CO2, CH4, N2O, false, false, false, CustomValue, CalcFromGL);
    end;

    procedure InsertAccountCategory(Code: Code[20]; Description: Text[100]; Scope: Enum "Emission Scope"; CalcFoundation: Enum "Calculation Foundation"; CO2: Boolean; CH4: Boolean; N2O: Boolean; WaterIntensity: Boolean; WasteIntensity: Boolean; DischargedIntoWater: Boolean; CustomValue: Text[100]; CalcFromGL: Boolean)
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
        SustainAccountCategory.Validate("Water Intensity", WaterIntensity);
        SustainAccountCategory.Validate("Waste Intensity", WasteIntensity);
        SustainAccountCategory.Validate("Discharged Into Water", DischargedIntoWater);
        SustainAccountCategory.Validate("Custom Value", CustomValue);
        SustainAccountCategory.Validate("Calculate from General Ledger", CalcFromGL);

        if Exists then
            SustainAccountCategory.Modify(true)
        else
            SustainAccountCategory.Insert(true);
    end;

    procedure InsertAccountSubcategory(CategoryCode: Code[20]; SubcategoryCode: Code[20]; Description: Text[100]; EFCO2: Decimal; EFCH4: Decimal; EFN2O: Decimal; RenewableEnergy: Boolean)
    begin
        InsertAccountSubcategory(CategoryCode, SubcategoryCode, Description, EFCO2, EFCH4, EFN2O, 0, 0, 0, RenewableEnergy);
    end;

    procedure InsertAccountSubcategory(CategoryCode: Code[20]; SubcategoryCode: Code[20]; Description: Text[100]; EFCO2: Decimal; EFCH4: Decimal; EFN2O: Decimal; WaterIntensityFactor: Decimal; WasteIntensityFactor: Decimal; DischargedIntoWaterFactor: Decimal; RenewableEnergy: Boolean)
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
        SustainAccountSubcategory.Validate("Water Intensity Factor", WaterIntensityFactor);
        SustainAccountSubcategory.Validate("Waste Intensity Factor", WasteIntensityFactor);
        SustainAccountSubcategory.Validate("Discharged Into Water Factor", DischargedIntoWaterFactor);
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

    procedure InsertSustainabilityJournalLine(TemplateName: Code[10]; BatchName: Code[10]; PostingDate: Date; DocumentNo: Code[20]; AccountNo: Code[20]; ManualInput: Boolean; UoM: Code[10]; FuelElectricity: Decimal; Distance: Decimal; CustomAmount: Decimal; Installation: Decimal; TimeFactor: Decimal; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal; WaterIntensity: Decimal; WasteIntensity: Decimal; DischargedIntoWater: Decimal; WaterWasteIntensityType: Enum "Water/Waste Intensity Type"; WaterType: Enum "Water Type"; CountryOrRegion: Code[10]; ResponsibilityCenter: Code[10])
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
        SustainabilityJnlLine.Validate("Unit of Measure", UoM);
        SustainabilityJnlLine.Validate("Water/Waste Intensity Type", WaterWasteIntensityType);
        SustainabilityJnlLine.Validate("Water Type", WaterType);

        if ManualInput then begin
            SustainabilityJnlLine.Validate("Emission CO2", EmissionCO2);
            SustainabilityJnlLine.Validate("Emission CH4", EmissionCH4);
            SustainabilityJnlLine.Validate("Emission N2O", EmissionN2O);
            SustainabilityJnlLine.Validate("Water Intensity", WaterIntensity);
            SustainabilityJnlLine.Validate("Waste Intensity", WasteIntensity);
            SustainabilityJnlLine.Validate("Discharged Into Water", DischargedIntoWater);
        end else begin
            SustainabilityJnlLine.Validate("Fuel/Electricity", FuelElectricity);
            SustainabilityJnlLine.Validate(Distance, Distance);
            SustainabilityJnlLine.Validate("Custom Amount", CustomAmount);
            SustainabilityJnlLine.Validate("Installation Multiplier", Installation);
            SustainabilityJnlLine.Validate("Time Factor", TimeFactor);
        end;

        SustainabilityJnlLine.Insert(true);
    end;

    procedure InsertSustainabilityJournalLine(TemplateName: Code[10]; BatchName: Code[10]; PostingDate: Date; DocumentNo: Code[20]; AccountNo: Code[20]; ManualInput: Boolean; UoM: Code[10]; FuelElectricity: Decimal; Distance: Decimal; CustomAmount: Decimal; Installation: Decimal; TimeFactor: Decimal; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal; CountryOrRegion: Code[10]; ResponsibilityCenter: Code[10])
    begin
        InsertSustainabilityJournalLine(TemplateName, BatchName, PostingDate, DocumentNo, AccountNo, ManualInput, UoM, FuelElectricity, Distance, CustomAmount, Installation, TimeFactor, EmissionCO2, EmissionCH4, EmissionN2O, 0, 0, 0, "Water/Waste Intensity Type"::" ", "Water Type"::" ", CountryOrRegion, ResponsibilityCenter);
    end;

    procedure InsertSustainabilityJournalLine(TemplateName: Code[10]; BatchName: Code[10]; PostingDate: Date; DocumentNo: Code[20]; AccountNo: Code[20]; UoM: Code[10]; FuelElectricity: Decimal; Distance: Decimal; CustomAmount: Decimal; Installation: Decimal; TimeFactor: Decimal; CountryOrRegion: Code[10]; ResponsibilityCenter: Code[10])
    begin
        InsertSustainabilityJournalLine(TemplateName, BatchName, PostingDate, DocumentNo, AccountNo, false, UoM, FuelElectricity, Distance, CustomAmount, Installation, TimeFactor, 0, 0, 0, CountryOrRegion, ResponsibilityCenter);
    end;

    procedure InsertSustainabilityJournalLine(TemplateName: Code[10]; BatchName: Code[10]; PostingDate: Date; DocumentNo: Code[20]; AccountNo: Code[20]; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal; CountryOrRegion: Code[10]; ResponsibilityCenter: Code[10])
    begin
        InsertSustainabilityJournalLine(TemplateName, BatchName, PostingDate, DocumentNo, AccountNo, true, '', 0, 0, 0, 1, 0, EmissionCO2, EmissionCH4, EmissionN2O, CountryOrRegion, ResponsibilityCenter);
    end;

    procedure InsertEmissionFee(EmissionType: Enum "Emission Type"; ScopeType: Enum "Emission Scope"; StartingDate: Date; EndingDate: Date; CountryRegionCode: Code[10]; ResponsibilityCenter: Code[10]; CarbonFee: Decimal; CarbonEquivalentFactor: Decimal)
    var
        EmissionFee: Record "Emission Fee";
        Exists: Boolean;
    begin
        if EmissionFee.Get(EmissionType, ScopeType, StartingDate, EndingDate, CountryRegionCode, ResponsibilityCenter) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        EmissionFee.Validate("Emission Type", EmissionType);
        EmissionFee.Validate("Scope Type", ScopeType);
        EmissionFee.Validate("Starting Date", StartingDate);
        EmissionFee.Validate("Ending Date", EndingDate);
        EmissionFee.Validate("Country/Region Code", CountryRegionCode);
        EmissionFee.Validate("Responsibility Center", ResponsibilityCenter);
        EmissionFee.Validate("Carbon Fee", CarbonFee);
        EmissionFee.Validate("Carbon Equivalent Factor", CarbonEquivalentFactor);

        if Exists then
            EmissionFee.Modify(true)
        else
            EmissionFee.Insert(true);
    end;

    procedure UpdateSustainabilityItem(ItemNo: Code[20]; GHGCredit: Boolean; CarbonCrPerUOM: Decimal)
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Item.Validate("GHG Credit", GHGCredit);
        Item.Validate("Carbon Credit Per UOM", CarbonCrPerUOM);
        Item.Modify(true);
    end;

    procedure UpdateSustainabilityPurchLine(PurchaseHeader: Record "Purchase Header"; SustAccNo: Code[20]; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal; TaxGroupCode: Code[20])
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        PurchaseLine: Record "Purchase Line";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        PurchaseLine.SetLoadFields();
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindLast();

        PurchaseLine.Validate("Sust. Account No.", SustAccNo);
        if EmissionCO2 <> 0 then
            PurchaseLine.Validate("Emission CO2", EmissionCO2);

        if EmissionCH4 <> 0 then
            PurchaseLine.Validate("Emission CH4", EmissionCH4);

        if EmissionN2O <> 0 then
            PurchaseLine.Validate("Emission N2O", EmissionN2O);

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            PurchaseLine.Validate("Tax Group Code", TaxGroupCode);

        PurchaseLine.Modify(true);
    end;

    procedure InsertScorecard(ScorecardNo: Code[20]; ScorecardName: Text[100]; Owner: Code[50])
    var
        SustainabilityScorecard: Record "Sustainability Scorecard";
        Exists: Boolean;
    begin
        if SustainabilityScorecard.Get(ScorecardNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        SustainabilityScorecard.Validate("No.", ScorecardNo);
        SustainabilityScorecard.Validate(Name, ScorecardName);
        SustainabilityScorecard.Validate(Owner, Owner);

        if Exists then
            SustainabilityScorecard.Modify(true)
        else
            SustainabilityScorecard.Insert(true);
    end;

    procedure InsertGoal(ScorecardNo: Code[20]; GoalNo: Code[20]; GoalName: Text[100]; BaseLinePeriodStartDate: Date; BaseLinePeriodEndDate: Date; CurrentPeriodStartDate: Date; CurrentPeriodEndDate: Date; UOM: Code[10]; CountryRegion: Code[10]; RespobislityCenter: Code[10]; TargetValueCO2: Decimal; TargetValueCH4: Decimal; TargetValueN2O: Decimal; MailGoal: Boolean)
    begin
        InsertGoal(ScorecardNo, GoalNo, GoalName, BaseLinePeriodStartDate, BaseLinePeriodEndDate, CurrentPeriodStartDate, CurrentPeriodEndDate, UOM, CountryRegion, RespobislityCenter, TargetValueCO2, TargetValueCH4, TargetValueN2O, 0, 0, MailGoal);
    end;

    procedure InsertGoal(ScorecardNo: Code[20]; GoalNo: Code[20]; GoalName: Text[100]; BaseLinePeriodStartDate: Date; BaseLinePeriodEndDate: Date; CurrentPeriodStartDate: Date; CurrentPeriodEndDate: Date; UOM: Code[10]; CountryRegion: Code[10]; RespobislityCenter: Code[10]; TargetValueCO2: Decimal; TargetValueCH4: Decimal; TargetValueN2O: Decimal; TargetValueWater: Decimal; TargetValueWaste: Decimal; MailGoal: Boolean)
    var
        SustainabilityGoal: Record "Sustainability Goal";
    begin
        SustainabilityGoal.Validate("Scorecard No.", ScorecardNo);
        SustainabilityGoal.Validate("No.", GoalNo);
        SustainabilityGoal.Validate("Line No.", GetNextSustainabilityGoalLineNo(ScorecardNo, GoalNo));
        SustainabilityGoal.Validate(Name, GoalName);
        SustainabilityGoal.Validate("Baseline Start Date", BaseLinePeriodStartDate);
        SustainabilityGoal.Validate("Baseline End Date", BaseLinePeriodEndDate);
        SustainabilityGoal.Validate("Start Date", CurrentPeriodStartDate);
        SustainabilityGoal.Validate("End Date", CurrentPeriodEndDate);
        SustainabilityGoal.Validate("Unit of Measure", UOM);
        SustainabilityGoal.Validate("Country/Region Code", CountryRegion);
        SustainabilityGoal.Validate("Responsibility Center", RespobislityCenter);
        SustainabilityGoal.Validate("Target Value for CO2", TargetValueCO2);
        SustainabilityGoal.Validate("Target Value for CH4", TargetValueCH4);
        SustainabilityGoal.Validate("Target Value for N2O", TargetValueN2O);
        SustainabilityGoal.Validate("Target Value for Water Int.", TargetValueWater);
        SustainabilityGoal.Validate("Target Value for Waste Int.", TargetValueWaste);
        SustainabilityGoal.Validate("Main Goal", MailGoal);
        SustainabilityGoal.Insert(true);
    end;

    procedure UpdateSustainabilityResponsibilityCenter(ResponsibilityCenterCode: Code[20]; WaterCapacityQuantity: Decimal; WaterCapacityUnit: Code[10])
    var
        ResponsibilityCenter: Record "Responsibility Center";
    begin
        ResponsibilityCenter.Get(ResponsibilityCenterCode);
        ResponsibilityCenter.Validate("Water Capacity Quantity(Month)", WaterCapacityQuantity);
        ResponsibilityCenter.Validate("Water Capacity Unit", WaterCapacityUnit);
        ResponsibilityCenter.Modify(true);
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

    local procedure GetNextSustainabilityGoalLineNo(ScorecardNo: Code[20]; GoalNo: Code[20]): Integer
    var
        SustainabilityGoal: Record "Sustainability Goal";
    begin
        SustainabilityGoal.SetRange("Scorecard No.", ScorecardNo);
        SustainabilityGoal.SetRange("No.", GoalNo);
        SustainabilityGoal.SetCurrentKey("Line No.");

        if SustainabilityGoal.FindLast() then
            exit(SustainabilityGoal."Line No." + 10000)
        else
            exit(10000);
    end;
}
