namespace Microsoft.Test.Sustainability;

using Microsoft.Integration.D365Sales;
using Microsoft.Integration.Dataverse;
using Microsoft.Inventory.Location;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.CBAM;
using Microsoft.Sustainability.Certificate;
using Microsoft.Sustainability.CRM;
using Microsoft.Sustainability.Emission;
using Microsoft.Sustainability.Energy;
using Microsoft.Sustainability.ESGReporting;
using Microsoft.Sustainability.ExciseTax;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Scorecard;
using Microsoft.Sustainability.Setup;

codeunit 148182 "Library - Sustainability"
{
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";

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

    procedure InsertSustainabilityScorecard(var SustainabilityScorecard: Record "Sustainability Scorecard"; ScorecardCode: Code[20]; Name: Text[100])
    begin
        SustainabilityScorecard.Init();
        SustainabilityScorecard.Validate("No.", ScorecardCode);
        SustainabilityScorecard.Validate(Name, Name);
        SustainabilityScorecard.Insert(true);
    end;

    procedure InsertSustainabilityGoal(var SustainabilityGoal: Record "Sustainability Goal"; GoalCode: Code[20]; ScorecardCode: Code[20]; LineNo: Integer; Name: Text[100])
    begin
        SustainabilityGoal.Init();
        SustainabilityGoal.Validate("Scorecard No.", ScorecardCode);
        SustainabilityGoal.Validate("No.", GoalCode);
        SustainabilityGoal.Validate("Line No.", LineNo);
        SustainabilityGoal.Validate(Name, Name);
        SustainabilityGoal.Insert(true);
    end;

    procedure InsertSustainabilityCertificateArea(var SustCertificateArea: Record "Sust. Certificate Area")
    begin
        SustCertificateArea.Init();
        SustCertificateArea.Validate("No.", LibraryUtility.GenerateRandomCode(SustCertificateArea.FieldNo("No."), Database::"Sust. Certificate Area"));
        SustCertificateArea.Validate(Name, LibraryUtility.GenerateGUID());
        SustCertificateArea.Insert(true);
    end;

    procedure InsertSustainabilityCertificateStandard(var SustCertificateStandard: Record "Sust. Certificate Standard")
    begin
        SustCertificateStandard.Init();
        SustCertificateStandard.Validate("No.", LibraryUtility.GenerateRandomCode(SustCertificateStandard.FieldNo("No."), Database::"Sust. Certificate Standard"));
        SustCertificateStandard.Validate(Name, LibraryUtility.GenerateGUID());
        SustCertificateStandard.Insert(true);
    end;

    procedure InsertSustainabilityCertificate(var SustainabilityCertificate: Record "Sustainability Certificate"; SustCertAreaCode: Code[20]; SustCertStandardCode: Code[20]; SustCertType: Enum "Sust. Certificate Type")
    begin
        SustainabilityCertificate.Init();
        SustainabilityCertificate.Validate("No.", LibraryUtility.GenerateRandomCode(SustainabilityCertificate.FieldNo("No."), Database::"Sustainability Certificate"));
        SustainabilityCertificate.Validate(Name, LibraryUtility.GenerateGUID());
        SustainabilityCertificate.Validate("Area", SustCertAreaCode);
        SustainabilityCertificate.Validate(Standard, SustCertStandardCode);
        SustainabilityCertificate.Validate(Type, SustCertType);
        SustainabilityCertificate.Insert(true);
    end;

    procedure InsertSustainabilityResponsibilityCenter(var ResponsibilityCenter: Record "Responsibility Center"; CapacityQuantity: Decimal; CapacityUnit: Code[10]; CapacityDimension: Text[20])
    begin
        ResponsibilityCenter.Init();
        ResponsibilityCenter.Validate(Code, LibraryUtility.GenerateRandomCode(ResponsibilityCenter.FieldNo(Code), Database::"Responsibility Center"));
        ResponsibilityCenter.Validate(Name, LibraryUtility.GenerateGUID());
        ResponsibilityCenter.Validate("Water Capacity Quantity(Month)", CapacityQuantity);
        ResponsibilityCenter.Validate("Water Capacity Unit", CapacityUnit);
        ResponsibilityCenter.Validate("Water Capacity Dimension", CapacityDimension);
        ResponsibilityCenter.Insert(true);
    end;

    procedure InsertEmissionFee(var EmissionFee: Record "Emission Fee"; EmissionType: Enum "Emission Type"; ScopeType: Enum "Emission Scope"; StartingDate: Date; EndingDate: Date; CountryRegionCode: Code[10]; CarbonEquivalentFactor: Decimal)
    begin
        EmissionFee.Init();
        EmissionFee.Validate("Emission Type", EmissionType);
        EmissionFee.Validate("Scope Type", ScopeType);
        EmissionFee.Validate("Starting Date", StartingDate);
        EmissionFee.Validate("Ending Date", EndingDate);
        EmissionFee.Validate("Country/Region Code", CountryRegionCode);
        if EmissionType <> EmissionType::CO2 then
            EmissionFee.Validate("Carbon Equivalent Factor", CarbonEquivalentFactor);
        EmissionFee.Insert();
    end;

    procedure UpdateValueChainTrackingInSustainabilitySetup(EnableValueChainTracking: Boolean)
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.Get();
        SustainabilitySetup."Enable Value Chain Tracking" := EnableValueChainTracking;
        SustainabilitySetup.Modify();
    end;

    procedure InsertSustainabilityEnergySource(var EnergySource: Record "Sustainability Energy Source")
    begin
        EnergySource.Init();
        EnergySource.Validate("No.", LibraryUtility.GenerateRandomCode(EnergySource.FieldNo("No."), Database::"Sustainability Energy Source"));
        EnergySource.Validate(Description, LibraryUtility.GenerateGUID());
        EnergySource.Insert(true);
    end;

    procedure CreateESGReportingTemplate(var ESGReportingTemplate: Record "Sust. ESG Reporting Template")
    begin
        ESGReportingTemplate.Init();
        ESGReportingTemplate.Validate(Name, LibraryUtility.GenerateRandomCode(ESGReportingTemplate.FieldNo(Name), Database::"Sust. ESG Reporting Template"));
        ESGReportingTemplate.Validate(Description, LibraryUtility.GenerateGUID());
        ESGReportingTemplate.Validate("Page ID");
        ESGReportingTemplate.Insert();
    end;

    procedure CreateESGReportingName(var ESGReportingName: Record "Sust. ESG Reporting Name"; ESGReportingTemplate: Record "Sust. ESG Reporting Template")
    begin
        ESGReportingName.Init();
        ESGReportingName.Validate("ESG Reporting Template Name", ESGReportingTemplate.Name);
        ESGReportingName.Validate(Name, LibraryUtility.GenerateRandomCode(ESGReportingName.FieldNo(Name), Database::"Sust. ESG Reporting Name"));
        ESGReportingName.Validate(Description, LibraryUtility.GenerateGUID());
        ESGReportingName.Insert();
    end;

    procedure CreateESGReportingLine(
        var ESGReportingLines: Record "Sust. ESG Reporting Line";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        LineNo: Integer;
        Grouping: Code[10];
        RowNo: Code[10];
        FieldType: Enum "Sust. ESG Reporting Field Type";
        TableNo: Integer;
        FieldNo: Integer;
        ValueSettings: Enum "Sust. ESG Value Settings";
        AccountFilter: Text[250];
        RowType: Option "Net Change","Balance at Date","Year to Date","Beginning Balance";
        RowTotaling: Text[50];
        CalculateWith: Option Sign,"Opposite Sign";
        Show: Boolean;
        ShowWith: Option Sign,"Opposite Sign")
    begin
        ESGReportingLines.Init();
        ESGReportingLines.Validate("ESG Reporting Template Name", ESGReportingName."ESG Reporting Template Name");
        ESGReportingLines.Validate("ESG Reporting Name", ESGReportingName.Name);
        ESGReportingLines.Validate("Line No.", LineNo);
        ESGReportingLines.Validate(Grouping, Grouping);
        ESGReportingLines.Validate("Row No.", RowNo);
        ESGReportingLines.Insert();

        ESGReportingLines.Validate("Field Type", FieldType);
        ESGReportingLines.Validate("Table No.", TableNo);
        ESGReportingLines.Validate("Field No.", FieldNo);
        ESGReportingLines.Validate("Value Settings", ValueSettings);
        ESGReportingLines.Validate("Account Filter", AccountFilter);
        ESGReportingLines.Validate("Row Type", RowType);
        if RowTotaling <> '' then
            ESGReportingLines.Validate("Row Totaling", RowTotaling);

        ESGReportingLines.Validate("Calculate With", CalculateWith);
        ESGReportingLines.Validate(Show, Show);
        ESGReportingLines.Validate("Show With", ShowWith);
        ESGReportingLines.Modify();
    end;

    procedure UpdatePostedESGReportingNoInSustainabilitySetup()
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.Get();
        SustainabilitySetup.Validate("Posted ESG Reporting Nos.", LibraryERM.CreateNoSeriesCode());
        SustainabilitySetup.Modify();
    end;

    procedure UpdateESGStandardReportingNoInSustainabilitySetup()
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.Get();
        SustainabilitySetup.Validate("ESG Standard Reporting Nos.", LibraryERM.CreateNoSeriesCode());
        SustainabilitySetup.Modify();
    end;

    procedure UpdateDataverseIntegrationInSustainabilitySetup(DataverseIntegration: Boolean)
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.Get();
        SustainabilitySetup.Validate("Is Dataverse Int. Enabled", DataverseIntegration);
        SustainabilitySetup.Modify();
    end;

    procedure EnableFormulaInPurchDocsInSustainabilitySetup()
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.Get();
        SustainabilitySetup.Validate("Use Emissions In Purch. Doc.", true);
        SustainabilitySetup.Validate("Use Formulas In Purch. Docs", true);
        SustainabilitySetup.Modify();
    end;

    procedure CreateReportingUnit(var ReportingUnit: Record "Sust. ESG Reporting Unit")
    begin
        ReportingUnit.Init();
        ReportingUnit.Code := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(20, 0), 1, MaxStrLen(ReportingUnit.Code));
        ReportingUnit.Description := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(20, 0), 1, MaxStrLen(ReportingUnit.Description));
        ReportingUnit.Insert();
    end;

    procedure CreateStandard(var Standard: Record "Sust. ESG Standard")
    begin
        Standard.Init();
        Standard."No." := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(20, 0), 1, MaxStrLen(Standard."No."));
        Standard.Description := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(20, 0), 1, MaxStrLen(Standard.Description));
        Standard.Insert();
    end;

    procedure CreateESGReportingName(var ESGReportingName: Record "Sust. ESG Reporting Name")
    begin
        ESGReportingName.Init();
        ESGReportingName."ESG Reporting Template Name" := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(10, 0), 1, MaxStrLen(ESGReportingName."ESG Reporting Template Name"));
        ESGReportingName.Name := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(10, 0), 1, MaxStrLen(ESGReportingName.Name));
        ESGReportingName.Description := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(20, 0), 1, MaxStrLen(ESGReportingName.Description));
        ESGReportingName.Insert();
    end;

    procedure CreateCRMUnit(var CRMUnit: Record "Sust. Unit")
    var
        CRMSystemUser: Record "CRM Systemuser";
    begin
        EnsureCDSSystemUser();
        CRMSystemUser.SetFilter(FirstName, '<>Integration');
        CRMSystemUser.FindFirst();

        CRMUnit.Init();
        CRMUnit.Name := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(20, 0), 1, MaxStrLen(CRMUnit.Name));
        CRMUnit.StateCode := CRMUnit.StateCode::Active;
        CRMUnit.StatusCode := CRMUnit.StatusCode::Active;
        CRMUnit.CreatedBy := CRMSystemUser.SystemUserId;
        CRMUnit.ModifiedBy := CRMSystemUser.SystemUserId;
        CRMUnit.CreatedOn := CurrentDateTime();
        CRMUnit.ModifiedOn := CRMUnit.CreatedOn;
        CRMUnit.Insert();
    end;

    procedure CreateCRMStandard(var CRMStandard: Record "Sust. Standard")
    var
        CRMSystemUser: Record "CRM Systemuser";
    begin
        EnsureCDSSystemUser();
        CRMSystemUser.SetFilter(FirstName, '<>Integration');
        CRMSystemUser.FindFirst();

        CRMStandard.Init();
        CRMStandard.Name := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(20, 0), 1, MaxStrLen(CRMStandard.Name));
        CRMStandard.StateCode := CRMStandard.StateCode::Active;
        CRMStandard.StatusCode := CRMStandard.StatusCode::Active;
        CRMStandard.CreatedBy := CRMSystemUser.SystemUserId;
        CRMStandard.ModifiedBy := CRMSystemUser.SystemUserId;
        CRMStandard.CreatedOn := CurrentDateTime();
        CRMStandard.ModifiedOn := CRMStandard.CreatedOn;
        CRMStandard.Insert();
    end;

    procedure CreateCRMAssessment(var CRMAssessment: Record "Sust. Assessment")
    var
        CRMSystemUser: Record "CRM Systemuser";
    begin
        EnsureCDSSystemUser();
        CRMSystemUser.SetFilter(FirstName, '<>Integration');
        CRMSystemUser.FindFirst();

        CRMAssessment.Init();
        CRMAssessment.Name := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(10, 0), 1, MaxStrLen(CRMAssessment.Name));
        CRMAssessment.StateCode := CRMAssessment.StateCode::Active;
        CRMAssessment.StatusCode := CRMAssessment.StatusCode::Active;
        CRMAssessment.CreatedBy := CRMSystemUser.SystemUserId;
        CRMAssessment.ModifiedBy := CRMSystemUser.SystemUserId;
        CRMAssessment.CreatedOn := CurrentDateTime();
        CRMAssessment.ModifiedOn := CRMAssessment.CreatedOn;
        CRMAssessment.Insert();
    end;

    procedure CreateCRMAssessmentRequirement(var CRMAssessmentRequirement: Record "Sust. Assessment Requirement")
    var
        CRMSystemUser: Record "CRM Systemuser";
    begin
        EnsureCDSSystemUser();
        CRMSystemUser.SetFilter(FirstName, '<>Integration');
        CRMSystemUser.FindFirst();

        CRMAssessmentRequirement.Init();
        CRMAssessmentRequirement.Name := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(10, 0), 1, MaxStrLen(CRMAssessmentRequirement.Name));
        CRMAssessmentRequirement.StateCode := CRMAssessmentRequirement.StateCode::Active;
        CRMAssessmentRequirement.StatusCode := CRMAssessmentRequirement.StatusCode::Active;
        CRMAssessmentRequirement.CreatedBy := CRMSystemUser.SystemUserId;
        CRMAssessmentRequirement.ModifiedBy := CRMSystemUser.SystemUserId;
        CRMAssessmentRequirement.CreatedOn := CurrentDateTime();
        CRMAssessmentRequirement.ModifiedOn := CRMAssessmentRequirement.CreatedOn;
        CRMAssessmentRequirement.Insert();
    end;

    procedure EnsureCDSSystemUser(): Guid
    var
        CRMSystemUser: Record "CRM Systemuser";
        CDSConnectionSetup: Record "CDS Connection Setup";
    begin
        CDSConnectionSetup.Get();
        if not FindIntegrationSystemUser(CDSConnectionSetup, CRMSystemUser) then begin
            CreateCRMSystemUser(CRMSystemUser);
            CRMSystemUser.FirstName := 'Integration';
            CRMSystemUser.LastName := 'User';
            case CDSConnectionSetup."Authentication Type" of
                CDSConnectionSetup."Authentication Type"::Office365, CDSConnectionSetup."Authentication Type"::OAuth:
                    CRMSystemUser.InternalEMailAddress :=
                      CopyStr(CDSConnectionSetup."User Name", 1, MaxStrLen(CRMSystemUser.InternalEMailAddress));
                CDSConnectionSetup."Authentication Type"::AD, CDSConnectionSetup."Authentication Type"::IFD:
                    CRMSystemUser.DomainName :=
                      CopyStr(CDSConnectionSetup."User Name", 1, MaxStrLen(CRMSystemUser.DomainName));
            end;
            CRMSystemUser.Modify();
        end;
        CRMSystemUser.Reset();
        CRMSystemUser.SetFilter(SystemUserId, '<>%1', CRMSystemUser.SystemUserId);
        if not CRMSystemUser.FindFirst() then begin
            Clear(CRMSystemUser);
            CreateCRMSystemUser(CRMSystemUser);
        end;
        exit(CRMSystemUser.SystemUserId);
    end;

    local procedure CreateCRMSystemUser(var CRMSystemUser: Record "CRM Systemuser")
    begin
        Clear(CRMSystemUser);
        CRMSystemUser.Init();
        CRMSystemUser.FullName := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(20, 0), 1, MaxStrLen(CRMSystemUser.FullName));
        CRMSystemUser.CreatedOn := CurrentDateTime();
        CRMSystemUser.ModifiedOn := CRMSystemUser.CreatedOn;
        CRMSystemUser.InternalEMailAddress := CopyStr(CRMSystemUser.FullName + '@ORG.INT', 1, MaxStrLen(CRMSystemUser.InternalEMailAddress));
        CRMSystemUser.IsLicensed := true;
        CRMSystemUser.IsIntegrationUser := false;
        CRMSystemUser.IsDisabled := false;
        CRMSystemUser.Insert();
    end;

    local procedure FindIntegrationSystemUser(CDSConnectionSetup: Record "CDS Connection Setup"; var CRMSystemUser: Record "CRM Systemuser"): Boolean
    begin
        case CDSConnectionSetup."Authentication Type" of
            CDSConnectionSetup."Authentication Type"::Office365, CDSConnectionSetup."Authentication Type"::OAuth:
                CRMSystemUser.SetRange(InternalEMailAddress, CDSConnectionSetup."User Name");
            CDSConnectionSetup."Authentication Type"::AD, CDSConnectionSetup."Authentication Type"::IFD:
                CRMSystemUser.SetRange(DomainName, CDSConnectionSetup."User Name");
        end;
        exit(CRMSystemUser.FindFirst());
    end;

    procedure CreateCarbonPricing(var CarbonPricing: Record "Sustainability Carbon Pricing"; CountryRegion: Code[10]; StartingDate: Date; EndingDate: Date; UOM: Code[10]; ThresholdQty: Decimal; CarbonPrice: Decimal)
    begin
        CarbonPricing.Init();
        CarbonPricing.Validate("Country/Region of Origin", CountryRegion);
        CarbonPricing.Validate("Starting Date", StartingDate);
        CarbonPricing.Validate("Ending Date", EndingDate);
        CarbonPricing.Validate("Unit of Measure Code", UOM);
        CarbonPricing.Validate("Threshold Quantity", ThresholdQty);
        CarbonPricing.Validate("Carbon Price", CarbonPrice);
        CarbonPricing.Insert();
    end;

    procedure CleanUpBeforeTesting()
    var
        SustainabilityJnlTemplate: Record "Sustainability Jnl. Template";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityAccountCategory: Record "Sustain. Account Category";
        SustainabilityAccountSubcategory: Record "Sustain. Account Subcategory";
        SustainabilityGoal: Record "Sustainability Goal";
        SustainabilityScorecard: Record "Sustainability Scorecard";
        EmissionFee: Record "Emission Fee";
        EnergySource: Record "Sustainability Energy Source";
        ReportingUnit: Record "Sust. ESG Reporting Unit";
        Standard: Record "Sust. ESG Standard";
        ESGReportingName: Record "Sust. ESG Reporting Name";
        ESGReportingLine: Record "Sust. ESG Reporting Line";
        PostedESGReportingHeader: Record "Sust. Posted ESG Report Header";
        PostedESGReportingLine: Record "Sust. Posted ESG Report Line";
        SustainabilityExciseJnlTemplate: Record "Sust. Excise Journal Template";
        SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch";
        SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line";
        SustExciseTransactionLog: Record "Sust. Excise Taxes Trans. Log";
        SustainabilityDisclaimer: Record "Sustainability Disclaimer";
    begin
        SustainabilityJnlTemplate.DeleteAll();
        SustainabilityJnlBatch.DeleteAll();
        SustainabilityJnlLine.DeleteAll();
        SustainabilityLedgerEntry.DeleteAll();
        SustainabilityValueEntry.DeleteAll();
        SustainabilityAccount.DeleteAll();
        SustainabilityAccountCategory.DeleteAll();
        SustainabilityAccountSubcategory.DeleteAll();
        SustainabilityGoal.DeleteAll();
        SustainabilityScorecard.DeleteAll();
        EmissionFee.DeleteAll();
        EnergySource.DeleteAll();
        ReportingUnit.DeleteAll();
        Standard.DeleteAll();
        ESGReportingName.DeleteAll();
        ESGReportingLine.DeleteAll();
        PostedESGReportingHeader.DeleteAll();
        PostedESGReportingLine.DeleteAll();
        SustainabilityExciseJnlTemplate.DeleteAll();
        SustainabilityExciseJnlBatch.DeleteAll();
        SustainabilityExciseJnlLine.DeleteAll();
        SustExciseTransactionLog.DeleteAll();
        SustainabilityDisclaimer.DeleteAll();
    end;
}