codeunit 27009 "Create CA GL Accounts"
{
    InherentPermissions = X;
    InherentEntitlements = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Common GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyCommonGLAccounts()
    var
        InventorySetup: Record "Inventory Setup";
        CommonGLAccount: Codeunit "Create Common GL Account";
    begin
        InventorySetup.Get();

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '13100');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '22300');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '41100');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '54100');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '53700');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '54710');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '53800');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '54702');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '53850');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '54703');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '14300');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '53100');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '53400');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '54500');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '14100');
        if InventorySetup."Expected Cost Posting to G/L" then
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '14101')
        else
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '44400');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyManufacturingGLAccounts()
    var
        MfgGLAccount: Codeunit "Create Mfg GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '52450');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '52460');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '52475');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '57100');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '57200');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '57210');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '57300');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '57400');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '14200');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '14600');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create FA GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyFixedAssetGLAccounts()
    var
        FAGLAccount: Codeunit "Create FA GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.IncreasesDuringTheYearName(), '18100');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DecreasesDuringTheYearName(), '18100');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.AccumDepreciationBuildingsName(), '17200');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.MiscellaneousName(), '65300');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DepreciationEquipmentName(), '71200');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.GainsAndLossesName(), '72900');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create HR GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyHumanResourcesGLAccounts()
    var
        HRGLAccount: Codeunit "Create HR GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(HRGLAccount.EmployeesPayableName(), '23850');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Job GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyJobGLAccounts()
    var
        JobGLAccount: Codeunit "Create Job GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPInvoicedSalesName(), '15011');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPJobCostsName(), '15231');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobSalesAppliedName(), '41300');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedSalesName(), '44100');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobCostsAppliedName(), '54599');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedCostsName(), '51000');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccount()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ASSETSName(), '10000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsName(), '11000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsName(), '11100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashName(), '11110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesName(), '12000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BondsName(), '12300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableName(), '13000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersDomesticName(), '13100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersForeignName(), '13200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsName(), '13500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryName(), '14000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsName(), '14100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsInterimName(), '14101');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResaleSoldInterimName(), '14102');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsName(), '14200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsInterimName(), '14201');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsName(), '14300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsInterimName(), '14301');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMatSoldInterimName(), '14302');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PrimoInventoryName(), '14400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWIPName(), '15000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPSalesName(), '15010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobSalesName(), '15011');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoicedJobSalesName(), '15012');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPCostsName(), '15230');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobCostsName(), '15231');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedJobCostsName(), '15232');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsName(), '16000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsName(), '16100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesBeginTotalName(), '16200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '16210');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationVehiclesName(), '16300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentBeginTotalName(), '17000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentName(), '17100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDeprOperEquipName(), '17200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsBeginTotalName(), '18000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsName(), '18100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LIABILITIESANDEQUITYName(), '20000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesName(), '21000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShortTermLiabilitiesName(), '22000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevolvingCreditName(), '22100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsName(), '22150');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableName(), '22200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsDomesticName(), '22300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsForeignName(), '22400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimName(), '22510');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRawMatName(), '22530');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRetailName(), '22550');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelRelatedItemsName(), '23000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesPayableName(), '23300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationPayableName(), '23850');
        ContosoGLAccount.AddAccountForLocalization(EmployeesPayableName(), '23890');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesName(), '24000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DividendsfortheFiscalYearName(), '24200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxesPayableName(), '24300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongTermLiabilitiesName(), '25000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongTermBankLoansName(), '25100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageName(), '25200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeferredTaxesName(), '25300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CapitalStockName(), '30100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetainedEarningsName(), '30200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.INCOMESTATEMENTName(), '40000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevenueName(), '40100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofRetailName(), '41000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailDomName(), '41100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailExportName(), '41200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRetailName(), '41300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRetailName(), '41400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofRawMaterialsName(), '41500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsDomName(), '42000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsExportName(), '42100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRawMatName(), '42300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofResourcesName(), '42500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesDomName(), '43000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesExportName(), '43100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtResourcesName(), '43300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofJobsName(), '43500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOtherJobExpensesName(), '44000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesName(), '44100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestIncomeName(), '47000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonBankBalancesName(), '47100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargesfromCustomersName(), '47200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtDiscReceivedDecreasesName(), '47260');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsReceivedName(), '47300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoiceRoundingName(), '47400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ApplicationRoundingName(), '47500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceReceivedName(), '47510');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolReceivedDecreasesName(), '47520');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultingFeesDomName(), '48000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FeesandChargesRecDomName(), '48100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscountGrantedName(), '48200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostName(), '50000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostsName(), '51000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResourcesName(), '52000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResourcesUsedName(), '52200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtResourcesName(), '52210');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedResourcesName(), '52211');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMaterialsName(), '53000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsDomName(), '53100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsExportName(), '53200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRawMaterialsName(), '53300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRawMatName(), '53350');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRawMatName(), '53400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRawMaterialsName(), '53499');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMaterialsSoldName(), '53600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRetailName(), '54000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailDomName(), '54100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailExportName(), '54300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRetailName(), '54400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRetailName(), '54500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRetailName(), '54550');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRetailName(), '54599');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRetailName(), '54600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRetailSoldName(), '54700');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingExpensesName(), '60000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SellingExpensesName(), '61000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdvertisingName(), '61100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EntertainmentandPRName(), '61200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TravelName(), '61300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesName(), '61350');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelExpensesName(), '62000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WagesName(), '62100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalariesName(), '62200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetirementPlanContributionsName(), '62300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationName(), '62400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesName(), '62500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehicleExpensesName(), '63000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GasolineandMotorOilName(), '63100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RegistrationFeesName(), '63200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceName(), '63300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ComputerExpensesName(), '64000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SoftwareName(), '64100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultantServicesName(), '64200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherComputerExpensesName(), '64300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BuildingMaintenanceExpensesName(), '65000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CleaningName(), '65100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityandHeatingName(), '65200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdministrativeExpensesName(), '65500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OfficeSuppliesName(), '65600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PhoneandFaxName(), '65700');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PostageName(), '65800');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpensesName(), '67000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashDiscrepanciesName(), '67100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BadDebtExpensesName(), '67200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LegalandAccountingServicesName(), '67300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherCostsofOperationsName(), '67500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationofFixedAssetsName(), '71000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationBuildingsName(), '71100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationEquipmentName(), '71200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationVehiclesName(), '71300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestExpensesName(), '71500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonRevolvingCreditName(), '71600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonBankLoansName(), '71700');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageInterestName(), '71800');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargestoVendorsName(), '71900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtDiscGrantedDecreasesName(), '72000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceGrantedName(), '72100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsGrantedName(), '72101');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolGrantedDecreasesName(), '72200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFXGainsName(), '72500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFXLossesName(), '72600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFXGainsName(), '72700');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFXLossesName(), '72800');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GAINSANDLOSSESName(), '72900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxName(), '76000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryIncomeName(), '81100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryExpensesName(), '81300');

        //BlankGL
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BALANCESHEETName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EmployeesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedInterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankLCYName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankCurrenciesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GiroAccountName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.StockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalStockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT0Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT25EUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT10EUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FuelTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NaturalGasTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CoalTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CO2TaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WaterTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WithholdingTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SupplementaryTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceExpenseName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetOperatingIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NETINCOMEBEFORETAXESName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NETINCOMEName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MiscellaneousName(), '');

        // New GL
        ContosoGLAccount.AddAccountForLocalization(BankCheckingName(), '11120');
        ContosoGLAccount.AddAccountForLocalization(BankCurrenciesLCYName(), '11130');
        ContosoGLAccount.AddAccountForLocalization(BankCurrenciesFCYUSDName(), '11140');
        ContosoGLAccount.AddAccountForLocalization(BankOperationsCashName(), '11150');
        ContosoGLAccount.AddAccountForLocalization(LiquidAssetsTotalName(), '11199');
        ContosoGLAccount.AddAccountForLocalization(ShortTermInvestmentsName(), '12100');
        ContosoGLAccount.AddAccountForLocalization(CanadianTermDepositsName(), '12200');
        ContosoGLAccount.AddAccountForLocalization(OtherMarketableSecuritiesName(), '12400');
        ContosoGLAccount.AddAccountForLocalization(InterestAccruedOnInvestmentName(), '12500');
        ContosoGLAccount.AddAccountForLocalization(SecuritiesTotalName(), '12599');
        ContosoGLAccount.AddAccountForLocalization(OtherReceivablesName(), '13300');
        ContosoGLAccount.AddAccountForLocalization(AccountsReceivableTotalName(), '13400');
        ContosoGLAccount.AddAccountForLocalization(VendorPrepaymentsServicesName(), '13520');
        ContosoGLAccount.AddAccountForLocalization(VendorPrepaymentsRetailName(), '13530');
        ContosoGLAccount.AddAccountForLocalization(PurchasePrepaymentsTotalName(), '13540');
        ContosoGLAccount.AddAccountForLocalization(AllowanceForFinishedGoodsWriteOffsName(), '14450');
        ContosoGLAccount.AddAccountForLocalization(WipAccountFinishedGoodsName(), '14500');
        ContosoGLAccount.AddAccountForLocalization(InventoryTotalName(), '14600');
        ContosoGLAccount.AddAccountForLocalization(WipSalesTotalName(), '15100');
        ContosoGLAccount.AddAccountForLocalization(WipCostsTotalName(), '15240');
        ContosoGLAccount.AddAccountForLocalization(JobWIPTotalName(), '15300');
        ContosoGLAccount.AddAccountForLocalization(CurrentAssetsTotalName(), '15950');
        ContosoGLAccount.AddAccountForLocalization(VehiclesTotalName(), '16400');
        ContosoGLAccount.AddAccountForLocalization(OperatingEquipmentTotalName(), '17300');
        ContosoGLAccount.AddAccountForLocalization(AccumDepreciationBuildingsName(), '18200');
        ContosoGLAccount.AddAccountForLocalization(LandAndBuildingsTotalName(), '18300');
        ContosoGLAccount.AddAccountForLocalization(TangibleFixedAssetsTotalName(), '18400');
        ContosoGLAccount.AddAccountForLocalization(IntangibleAssetsBeginTotalName(), '18500');
        ContosoGLAccount.AddAccountForLocalization(IntangibleAssetsName(), '18510');
        ContosoGLAccount.AddAccountForLocalization(AccAmortnOnIntangiblesName(), '18550');
        ContosoGLAccount.AddAccountForLocalization(IntangibleAssetsTotalName(), '18700');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetsTotalName(), '18950');
        ContosoGLAccount.AddAccountForLocalization(TotalAssetsName(), '19950');
        ContosoGLAccount.AddAccountForLocalization(DeferredRevenueName(), '22140');
        ContosoGLAccount.AddAccountForLocalization(CustomerPrepaymentsServicesName(), '22170');
        ContosoGLAccount.AddAccountForLocalization(CustomerPrepaymentsRetailName(), '22180');
        ContosoGLAccount.AddAccountForLocalization(PrepaidServiceContractsName(), '22181');
        ContosoGLAccount.AddAccountForLocalization(SalesPrepaymentsTotalName(), '22190');
        ContosoGLAccount.AddAccountForLocalization(AccountsPayableEmployeesName(), '22420');
        ContosoGLAccount.AddAccountForLocalization(AccruedPayablesName(), '22450');
        ContosoGLAccount.AddAccountForLocalization(AccountsPayableTotalName(), '22500');
        ContosoGLAccount.AddAccountForLocalization(InvAdjmtInterimTotalName(), '22590');
        ContosoGLAccount.AddAccountForLocalization(TaxesPayablesName(), '22600');
        ContosoGLAccount.AddAccountForLocalization(IncomeTaxPayableName(), '22610');
        ContosoGLAccount.AddAccountForLocalization(ProvincialSalesTaxName(), '22700');
        ContosoGLAccount.AddAccountForLocalization(QSTSalesTaxCollectedName(), '22740');
        ContosoGLAccount.AddAccountForLocalization(PurchaseTaxName(), '22750');
        ContosoGLAccount.AddAccountForLocalization(GSTHSTSalesTaxName(), '22780');
        ContosoGLAccount.AddAccountForLocalization(GSTHSTInputCreditsName(), '22800');
        ContosoGLAccount.AddAccountForLocalization(IncomeTaxAccruedName(), '22810');
        ContosoGLAccount.AddAccountForLocalization(QuebecBeerTaxesAccruedName(), '22850');
        ContosoGLAccount.AddAccountForLocalization(TaxesPayablesTotalName(), '22899');
        ContosoGLAccount.AddAccountForLocalization(AccruedSalariesWagesName(), '23050');
        ContosoGLAccount.AddAccountForLocalization(FederalIncomeTaxExpenseName(), '23100');
        ContosoGLAccount.AddAccountForLocalization(ProvincialWithholdingPayableName(), '23200');
        ContosoGLAccount.AddAccountForLocalization(FICAPayableName(), '23400');
        ContosoGLAccount.AddAccountForLocalization(MedicarePayableName(), '23500');
        ContosoGLAccount.AddAccountForLocalization(FUTAPayableName(), '23600');
        ContosoGLAccount.AddAccountForLocalization(SUTAPayableName(), '23700');
        ContosoGLAccount.AddAccountForLocalization(EmployeeBenefitsPayableName(), '23750');
        ContosoGLAccount.AddAccountForLocalization(EmploymentInsuranceEmployeeContribName(), '23760');
        ContosoGLAccount.AddAccountForLocalization(EmploymentInsuranceEmployerContribName(), '23770');
        ContosoGLAccount.AddAccountForLocalization(CanadaPensionFundEmployeeContribName(), '23780');
        ContosoGLAccount.AddAccountForLocalization(CanadaPensionFundEmployerContribName(), '23790');
        ContosoGLAccount.AddAccountForLocalization(QuebecPipPayableEmployeeName(), '23795');
        ContosoGLAccount.AddAccountForLocalization(GarnishmentPayableName(), '23800');
        ContosoGLAccount.AddAccountForLocalization(TotalPersonnelRelatedItemsName(), '23900');
        ContosoGLAccount.AddAccountForLocalization(OtherLiabilitiesTotalName(), '24400');
        ContosoGLAccount.AddAccountForLocalization(ShortTermLiabilitiesTotalName(), '24500');
        ContosoGLAccount.AddAccountForLocalization(DeferralRevenueName(), '25301');
        ContosoGLAccount.AddAccountForLocalization(LongTermLiabilitiesTotalName(), '25400');
        ContosoGLAccount.AddAccountForLocalization(TotalLiabilitiesName(), '25995');
        ContosoGLAccount.AddAccountForLocalization(EquityName(), '30000');
        ContosoGLAccount.AddAccountForLocalization(NetIncomeForTheYearName(), '30400');
        ContosoGLAccount.AddAccountForLocalization(TotalStockholdersEquityName(), '30500');
        ContosoGLAccount.AddAccountForLocalization(TotalLiabilitiesAndEquityName(), '39950');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesOfRetailName(), '41450');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesOfRawMaterialsName(), '42400');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesOfResourcesName(), '43400');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesOfJobsName(), '44300');
        ContosoGLAccount.AddAccountForLocalization(SalesOfServiceContractsName(), '44399');
        ContosoGLAccount.AddAccountForLocalization(ServiceContractSaleName(), '44400');
        ContosoGLAccount.AddAccountForLocalization(TotalSaleOfServContractsName(), '44500');
        ContosoGLAccount.AddAccountForLocalization(TotalInterestIncomeName(), '48500');
        ContosoGLAccount.AddAccountForLocalization(TotalRevenueName(), '49950');
        ContosoGLAccount.AddAccountForLocalization(TotalCostOfResourcesName(), '52300');
        ContosoGLAccount.AddAccountForLocalization(CostOfCapacitiesBeginTotalName(), '52400');
        ContosoGLAccount.AddAccountForLocalization(CostOfCapacitiesName(), '52410');
        ContosoGLAccount.AddAccountForLocalization(DirectCostAppliedCapName(), '52450');
        ContosoGLAccount.AddAccountForLocalization(OverheadAppliedCapName(), '52460');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVarianceCapName(), '52475');
        ContosoGLAccount.AddAccountForLocalization(TotalCostOfCapacitiesName(), '52500');
        ContosoGLAccount.AddAccountForLocalization(JobCostAppliedRawMaterialsName(), '53500');
        ContosoGLAccount.AddAccountForLocalization(DirectCostAppliedRawmatName(), '53700');
        ContosoGLAccount.AddAccountForLocalization(OverheadAppliedRawmatName(), '53800');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVarianceRawmatName(), '53850');
        ContosoGLAccount.AddAccountForLocalization(TotalCostOfRawMaterialsName(), '53900');
        ContosoGLAccount.AddAccountForLocalization(OverheadAppliedRetailName(), '54702');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVarianceRetailName(), '54703');
        ContosoGLAccount.AddAccountForLocalization(DirectCostAppliedRetailName(), '54710');
        ContosoGLAccount.AddAccountForLocalization(PaymentDiscountsGrantedCOGSName(), '54800');
        ContosoGLAccount.AddAccountForLocalization(TotalCostOfRetailName(), '54900');
        ContosoGLAccount.AddAccountForLocalization(VarianceName(), '57000');
        ContosoGLAccount.AddAccountForLocalization(MaterialVarianceName(), '57100');
        ContosoGLAccount.AddAccountForLocalization(CapacityVarianceName(), '57200');
        ContosoGLAccount.AddAccountForLocalization(SubcontractedVarianceName(), '57210');
        ContosoGLAccount.AddAccountForLocalization(CapOverheadVarianceName(), '57300');
        ContosoGLAccount.AddAccountForLocalization(MfgOverheadVarianceName(), '57400');
        ContosoGLAccount.AddAccountForLocalization(TotalVarianceName(), '57900');
        ContosoGLAccount.AddAccountForLocalization(TotalCostName(), '59950');
        ContosoGLAccount.AddAccountForLocalization(TotalSellingExpensesName(), '61400');
        ContosoGLAccount.AddAccountForLocalization(HealthInsuranceName(), '62600');
        ContosoGLAccount.AddAccountForLocalization(GroupLifeInsuranceName(), '62700');
        ContosoGLAccount.AddAccountForLocalization(WorkersCompensationName(), '62800');
        ContosoGLAccount.AddAccountForLocalization(FourHounderedOneKContributionsName(), '62900');
        ContosoGLAccount.AddAccountForLocalization(TotalPersonnelExpensesName(), '62950');
        ContosoGLAccount.AddAccountForLocalization(TaxesName(), '63450');
        ContosoGLAccount.AddAccountForLocalization(TotalVehicleExpensesName(), '63500');
        ContosoGLAccount.AddAccountForLocalization(TotalComputerExpensesName(), '64400');
        ContosoGLAccount.AddAccountForLocalization(RepairsandMaintenanceExpenseName(), '65300');
        ContosoGLAccount.AddAccountForLocalization(TotalBldgMaintExpensesName(), '65400');
        ContosoGLAccount.AddAccountForLocalization(TotalAdministrativeExpensesName(), '65900');
        ContosoGLAccount.AddAccountForLocalization(MiscellaneousName(), '67400');
        ContosoGLAccount.AddAccountForLocalization(OtherOperatingExpTotalName(), '67600');
        ContosoGLAccount.AddAccountForLocalization(TotalOperatingExpensesName(), '69950');
        ContosoGLAccount.AddAccountForLocalization(EBITDAName(), '70000');
        ContosoGLAccount.AddAccountForLocalization(TotalFixedAssetDepreciationName(), '71400');
        ContosoGLAccount.AddAccountForLocalization(TotalInterestExpensesName(), '72300');
        ContosoGLAccount.AddAccountForLocalization(GainsandLossesBeginTotalName(), '72400');
        ContosoGLAccount.AddAccountForLocalization(TotalGainsAndLossesName(), '73000');
        ContosoGLAccount.AddAccountForLocalization(NiBeforeExtrItemsTaxesName(), '74000');
        ContosoGLAccount.AddAccountForLocalization(IncomeTaxesName(), '75000');
        ContosoGLAccount.AddAccountForLocalization(StateIncomeTaxName(), '76100');
        ContosoGLAccount.AddAccountForLocalization(TotalIncomeTaxesName(), '76200');
        ContosoGLAccount.AddAccountForLocalization(NetIncomeBeforeExtrItemsName(), '80000');
        ContosoGLAccount.AddAccountForLocalization(ExtraordinaryItemsName(), '81000');
        ContosoGLAccount.AddAccountForLocalization(RevaluationSurplusAdjustmentsName(), '81200');
        ContosoGLAccount.AddAccountForLocalization(ExtraordinaryItemsTotalName(), '81400');
        // New GL
        CreateGLAccountForLocalization();
    end;

    local procedure CreateGLAccountForLocalization()
    var
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        SubCategory: Text[80];
    begin
        ContosoGLAccount.InsertGLAccount(BankChecking(), BankCheckingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BankCurrenciesLCY(), BankCurrenciesLCYName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BankCurrenciesFCYUSD(), BankCurrenciesFCYUSDName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BankOperationsCash(), BankOperationsCashName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LandandBuildings(), CreateGLAccount.LandandBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LiabilitiesAndEquity(), CreateGLAccount.LiabilitiesAndEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Heading, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.IncomeStatement(), CreateGLAccount.IncomeStatementName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Heading, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvoiceRounding(), CreateGLAccount.InvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentToleranceReceived(), CreateGLAccount.PaymentToleranceReceivedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PmtTolReceivedDecreases(), CreateGLAccount.PmtTolReceivedDecreasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FeesandChargesRecDom(), CreateGLAccount.FeesandChargesRecDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.UnrealizedFXGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.UnrealizedFXLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RealizedFXGains(), CreateGLAccount.RealizedFXGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RealizedFXLosses(), CreateGLAccount.RealizedFXLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ExtraordinaryIncome(), CreateGLAccount.ExtraordinaryIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CustomersDomestic(), CreateGLAccount.CustomersDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CustomersForeign(), CreateGLAccount.CustomersForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ResaleItemsInterim(), CreateGLAccount.ResaleItemsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.CostofResaleSoldInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinishedGoodsInterim(), CreateGLAccount.FinishedGoodsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RawMaterialsInterim(), CreateGLAccount.RawMaterialsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostofRawMatSoldInterim(), CreateGLAccount.CostofRawMatSoldInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PrimoInventory(), CreateGLAccount.PrimoInventoryName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPJobSales(), CreateGLAccount.WIPJobSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvoicedJobSales(), CreateGLAccount.InvoicedJobSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPJobCosts(), CreateGLAccount.WIPJobCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccruedJobCosts(), CreateGLAccount.AccruedJobCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Vehicles(), CreateGLAccount.VehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccumDepreciationVehicles(), CreateGLAccount.AccumDepreciationVehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OperatingEquipment(), CreateGLAccount.OperatingEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccumDeprOperEquip(), CreateGLAccount.AccumDeprOperEquipName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccumDepreciationBuildings(), AccumDepreciationBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RevolvingCredit(), CreateGLAccount.RevolvingCreditName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorsDomestic(), CreateGLAccount.VendorsDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorsForeign(), CreateGLAccount.VendorsForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvAdjmtInterimRetail(), CreateGLAccount.InvAdjmtInterimRetailName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvAdjmtInterimRawMat(), CreateGLAccount.InvAdjmtInterimRawMatName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DeferredTaxes(), CreateGLAccount.DeferredTaxesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CapitalStock(), CreateGLAccount.CapitalStockName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RetainedEarnings(), CreateGLAccount.RetainedEarningsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.GainsandLosses(), CreateGLAccount.GainsandLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailDom(), CreateGLAccount.SalesRetailDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailExport(), CreateGLAccount.SalesRetailExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAppliedRetail(), CreateGLAccount.JobSalesAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAdjmtRetail(), CreateGLAccount.JobSalesAdjmtRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRawMaterialsDom(), CreateGLAccount.SalesRawMaterialsDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRawMaterialsExport(), CreateGLAccount.SalesRawMaterialsExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAdjmtRawMat(), CreateGLAccount.JobSalesAdjmtRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesDom(), CreateGLAccount.SalesResourcesDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesExport(), CreateGLAccount.SalesResourcesExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAdjmtResources(), CreateGLAccount.JobSalesAdjmtResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.PaymentDiscountsReceivedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PmtDiscReceivedDecreases(), CreateGLAccount.PmtDiscReceivedDecreasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAdjmtResources(), CreateGLAccount.JobCostAdjmtResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAppliedResources(), CreateGLAccount.JobCostAppliedResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRawMaterialsDom(), CreateGLAccount.PurchRawMaterialsDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRawMaterialsExport(), CreateGLAccount.PurchRawMaterialsExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DiscReceivedRawMaterials(), CreateGLAccount.DiscReceivedRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InventoryAdjmtRawMat(), CreateGLAccount.InventoryAdjmtRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAdjmtRawMaterials(), CreateGLAccount.JobCostAdjmtRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostofRawMaterialsSold(), CreateGLAccount.CostofRawMaterialsSoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRetailDom(), CreateGLAccount.PurchRetailDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRetailExport(), CreateGLAccount.PurchRetailExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAppliedRetail(), CreateGLAccount.JobCostAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAdjmtRetail(), CreateGLAccount.JobCostAdjmtRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofRetailSoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentDiscountsGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PmtDiscGrantedDecreases(), CreateGLAccount.PmtDiscGrantedDecreasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentToleranceGranted(), CreateGLAccount.PaymentToleranceGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PmtTolGrantedDecreases(), CreateGLAccount.PmtTolGrantedDecreasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LiquidAssetsTotal(), LiquidAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LiquidAssets() + '..' + LiquidAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ShortTermInvestments(), ShortTermInvestmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CanadianTermDeposits(), CanadianTermDepositsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherMarketableSecurities(), OtherMarketableSecuritiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InterestAccruedOnInvestment(), InterestAccruedOnInvestmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SecuritiesTotal(), SecuritiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Securities() + '..' + SecuritiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherReceivables(), OtherReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsReceivableTotal(), AccountsReceivableTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.AccountsReceivable() + '..' + AccountsReceivableTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VendorPrepaymentsServices(), VendorPrepaymentsServicesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VendorPrepaymentsRetail(), VendorPrepaymentsRetailName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchasePrepaymentsTotal(), PurchasePrepaymentsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.PurchasePrepayments() + '..' + PurchasePrepaymentsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AllowanceForFinishedGoodsWriteOffs(), AllowanceForFinishedGoodsWriteOffsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WipAccountFinishedGoods(), WipAccountFinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InventoryTotal(), InventoryTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Inventory() + '..' + InventoryTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WipSalesTotal(), WipSalesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.WIPSales() + '..' + WIPSalesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WipCostsTotal(), WipCostsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.WIPCosts() + '..' + WIPCostsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobWIPTotal(), JobWIPTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.JobWIP() + '..' + JobWIPTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentAssetsTotal(), CurrentAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.CurrentAssets() + '..' + CurrentAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VehiclesTotal(), VehiclesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.VehiclesBeginTotal() + '..' + VehiclesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OperatingEquipmentTotal(), OperatingEquipmentTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.OperatingEquipmentBeginTotal() + '..' + OperatingEquipmentTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LandAndBuildingsTotal(), LandAndBuildingsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LandandBuildingsBeginTotal() + '..' + LandandBuildingsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TangibleFixedAssetsTotal(), TangibleFixedAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.TangibleFixedAssets() + '..' + TangibleFixedAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IntangibleAssetsBeginTotal(), IntangibleAssetsBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IntangibleAssets(), IntangibleAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccAmortnOnIntangibles(), AccAmortnOnIntangiblesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IntangibleAssetsTotal(), IntangibleAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, IntangibleAssetsBeginTotal() + '..' + IntangibleAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FixedAssetsTotal(), FixedAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.FixedAssets() + '..' + FixedAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAssets(), TotalAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 1, CreateGLAccount.ASSETS() + '..' + TOTALASSETS(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DeferredRevenue(), DeferredRevenueName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CustomerPrepaymentsServices(), CustomerPrepaymentsServicesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CustomerPrepaymentsRetail(), CustomerPrepaymentsRetailName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PrepaidServiceContracts(), PrepaidServiceContractsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesPrepaymentsTotal(), SalesPrepaymentsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SalesPrepayments() + '..' + SalesPrepaymentsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsPayableEmployees(), AccountsPayableEmployeesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedPayables(), AccruedPayablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsPayableTotal(), AccountsPayableTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.AccountsPayable() + '..' + AccountsPayableTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InvAdjmtInterimTotal(), InvAdjmtInterimTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.InvAdjmtInterim() + '..' + InvAdjmtInterimTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TaxesPayables(), TaxesPayablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeTaxPayable(), IncomeTaxPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProvincialSalesTax(), ProvincialSalesTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(QSTSalesTaxCollected(), QSTSalesTaxCollectedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseTax(), PurchaseTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GSTHSTSalesTax(), GSTHSTSalesTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GSTHSTInputCredits(), GSTHSTInputCreditsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeTaxAccrued(), IncomeTaxAccruedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(QuebecBeerTaxesAccrued(), QuebecBeerTaxesAccruedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxesPayablesTotal(), TaxesPayablesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, TaxesPayables() + '..' + TaxesPayablesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedSalariesWages(), AccruedSalariesWagesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FederalIncomeTaxExpense(), FederalIncomeTaxExpenseName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProvincialWithholdingPayable(), ProvincialWithholdingPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FICAPayable(), FICAPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MedicarePayable(), MedicarePayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FUTAPayable(), FUTAPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SUTAPayable(), SUTAPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EmployeeBenefitsPayable(), EmployeeBenefitsPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EmploymentInsuranceEmployeeContrib(), EmploymentInsuranceEmployeeContribName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EmploymentInsuranceEmployerContrib(), EmploymentInsuranceEmployerContribName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CanadaPensionFundEmployeeContrib(), CanadaPensionFundEmployeeContribName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CanadaPensionFundEmployerContrib(), CanadaPensionFundEmployerContribName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(QuebecPipPayableEmployee(), QuebecPipPayableEmployeeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GarnishmentPayable(), GarnishmentPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPersonnelRelatedItems(), TotalPersonnelRelatedItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.PersonnelRelatedItems() + '..' + TotalPersonnelRelatedItems(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherLiabilitiesTotal(), OtherLiabilitiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.OtherLiabilities() + '..' + OtherLiabilitiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ShortTermLiabilitiesTotal(), ShortTermLiabilitiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.ShortTermLiabilities() + '..' + ShortTermLiabilitiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DeferralRevenue(), DeferralRevenueName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LongTermLiabilitiesTotal(), LongTermLiabilitiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LongTermLiabilities() + '..' + LongTermLiabilitiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalLiabilities(), TotalLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Liabilities() + '..' + TotalLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Equity(), EquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Heading", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(NetIncomeForTheYear(), NetIncomeForTheYearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalStockholdersEquity(), TotalStockholdersEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalLiabilitiesAndEquity(), TotalLiabilitiesAndEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesOfRetail(), TotalSalesOfRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SalesofRetail() + '..' + TotalSalesofRetail(), Enum::"General Posting Type"::Sale, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesOfRawMaterials(), TotalSalesOfRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SalesofRawMaterials() + '..' + TotalSalesofRawMaterials(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesOfResources(), TotalSalesOfResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SalesofResources() + '..' + TotalSalesofResources(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesOfJobs(), TotalSalesOfJobsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SalesofJobs() + '..' + TotalSalesofJobs(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesOfServiceContracts(), SalesOfServiceContractsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ServiceContractSale(), ServiceContractSaleName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSaleOfServContracts(), TotalSaleOfServContractsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, SalesofServiceContracts() + '..' + TotalSaleofServContracts(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalInterestIncome(), TotalInterestIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.InterestIncome() + '..' + TotalInterestIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRevenue(), TotalRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Revenue() + '..' + TotalRevenue(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostOfResources(), TotalCostOfResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.CostofResources() + '..' + TotalCostofResources(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfCapacitiesBeginTotal(), CostOfCapacitiesBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfCapacities(), CostOfCapacitiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DirectCostAppliedCap(), DirectCostAppliedCapName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OverheadAppliedCap(), OverheadAppliedCapName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVarianceCap(), PurchaseVarianceCapName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostOfCapacities(), TotalCostOfCapacitiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CostofCapacities() + '..' + TotalCostofCapacities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobCostAppliedRawMaterials(), JobCostAppliedRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DirectCostAppliedRawmat(), DirectCostAppliedRawmatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OverheadAppliedRawmat(), OverheadAppliedRawmatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVarianceRawmat(), PurchaseVarianceRawmatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostOfRawMaterials(), TotalCostOfRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.CostofRawMaterials() + '..' + TotalCostofRawMaterials(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OverheadAppliedRetail(), OverheadAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVarianceRetail(), PurchaseVarianceRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DirectCostAppliedRetail(), DirectCostAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PaymentDiscountsGrantedCOGS(), PaymentDiscountsGrantedCOGSName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostOfRetail(), TotalCostOfRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.CostofRetail() + '..' + TotalCostofRetail(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Variance(), VarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MaterialVariance(), MaterialVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CapacityVariance(), CapacityVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SubcontractedVariance(), SubcontractedVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CapOverheadVariance(), CapOverheadVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MfgOverheadVariance(), MfgOverheadVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalVariance(), TotalVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, Variance() + '..' + TotalVariance(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCost(), TotalCostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Cost() + '..' + TotalCost(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSellingExpenses(), TotalSellingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SellingExpenses() + '..' + TotalSellingExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(HealthInsurance(), HealthInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GroupLifeInsurance(), GroupLifeInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WorkersCompensation(), WorkersCompensationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FourHounderedOneKContributions(), FourHounderedOneKContributionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPersonnelExpenses(), TotalPersonnelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.PersonnelExpenses() + '..' + TotalPersonnelExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Taxes(), TaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalVehicleExpenses(), TotalVehicleExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.VehicleExpenses() + '..' + TotalVehicleExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalComputerExpenses(), TotalComputerExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.ComputerExpenses() + '..' + TotalComputerExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RepairsandMaintenanceExpense(), RepairsandMaintenanceExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalBldgMaintExpenses(), TotalBldgMaintExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.BuildingMaintenanceExpenses() + '..' + TotalBldgMaintExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAdministrativeExpenses(), TotalAdministrativeExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.AdministrativeExpenses() + '..' + TotalAdministrativeExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherOperatingExpTotal(), OtherOperatingExpTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.OtherOperatingExpenses() + '..' + OtherOperatingExpTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOperatingExpenses(), TotalOperatingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.OperatingExpenses() + '..' + TotalOperatingExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EBITDA(), EBITDAName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFixedAssetDepreciation(), TotalFixedAssetDepreciationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.DepreciationofFixedAssets() + '..' + TotalFixedAssetDepreciation(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalInterestExpenses(), TotalInterestExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.InterestExpenses() + '..' + TotalInterestExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GainsandLossesBeginTotal(), GainsandLossesBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalGainsAndLosses(), TotalGainsAndLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, GainsandLossesBeginTotal() + '..' + TOTALGAINSANDLOSSES(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(NiBeforeExtrItemsTaxes(), NiBeforeExtrItemsTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeTaxes(), IncomeTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(StateIncomeTax(), StateIncomeTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalIncomeTaxes(), TotalIncomeTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, IncomeTaxes() + '..' + TotalIncomeTaxes(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(NetIncomeBeforeExtrItems(), NetIncomeBeforeExtrItemsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ExtraordinaryItems(), ExtraordinaryItemsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RevaluationSurplusAdjustments(), RevaluationSurplusAdjustmentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ExtraordinaryItemsTotal(), ExtraordinaryItemsTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, ExtraordinaryItems() + '..' + ExtraordinaryItemsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EmployeesPayable(), EmployeesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetEquipment(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VehiclesBeginTotal(), CreateGLAccount.VehiclesBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinanceChargesfromCustomers(), CreateGLAccount.FinanceChargesfromCustomersName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetIncomeService(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ConsultingFeesDom(), CreateGLAccount.ConsultingFeesDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetCOGSMaterials(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Cost(), CreateGLAccount.CostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCosts(), CreateGLAccount.JobCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostofResources(), CreateGLAccount.CostofResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetCash(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Cash(), CreateGLAccount.CashName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        SubCategory := Format(GLAccountCategoryMgt.GetCOGSMaterials(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DeliveryExpensesRawMat(), CreateGLAccount.DeliveryExpensesRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DeliveryExpensesRetail(), CreateGLAccount.DeliveryExpensesRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetAdvertisingExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Advertising(), CreateGLAccount.AdvertisingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.EntertainmentandPR(), CreateGLAccount.EntertainmentandPRName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Travel(), CreateGLAccount.TravelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DeliveryExpenses(), CreateGLAccount.DeliveryExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.GasolineandMotorOil(), CreateGLAccount.GasolineandMotorOilName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RegistrationFees(), CreateGLAccount.RegistrationFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetUtilitiesExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RepairsandMaintenance(), CreateGLAccount.RepairsandMaintenanceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Software(), CreateGLAccount.SoftwareName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ConsultantServices(), CreateGLAccount.ConsultantServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherComputerExpenses(), CreateGLAccount.OtherComputerExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetUtilitiesExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Cleaning(), CreateGLAccount.CleaningName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ElectricityandHeating(), CreateGLAccount.ElectricityandHeatingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetUtilitiesExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OfficeSupplies(), CreateGLAccount.OfficeSuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PhoneandFax(), CreateGLAccount.PhoneandFaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Postage(), CreateGLAccount.PostageName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetOtherIncomeExpense(), 80);
        ContosoGLAccount.InsertGLAccount(Miscellaneous(), MiscellaneousName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LegalandAccountingServices(), CreateGLAccount.LegalandAccountingServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherCostsofOperations(), CreateGLAccount.OtherCostsofOperationsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', CreatePostingGroups.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
    end;

    procedure AddCategoriesToGLAccountsForMini()
    var
        GLAccountCategory: Record "G/L Account Category";
    begin
        if GLAccountCategory.IsEmpty() then
            exit;

        GLAccountCategory.SetRange("Parent Entry No.", 0);
        if GLAccountCategory.FindSet() then
            repeat
                AssignCategoryToChartOfAccountsForMini(GLAccountCategory);
            until GLAccountCategory.Next() = 0;

        GLAccountCategory.SetFilter("Parent Entry No.", '<>%1', 0);
        if GLAccountCategory.FindSet() then
            repeat
                AssignSubcategoryToChartOfAccountsForMini(GLAccountCategory);
            until GLAccountCategory.Next() = 0;
    end;

    local procedure AssignCategoryToChartOfAccountsForMini(GLAccountCategory: Record "G/L Account Category")
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case GLAccountCategory."Account Category" of
            GLAccountCategory."Account Category"::Assets:
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.ASSETS(), TotalAssets());
            GLAccountCategory."Account Category"::Liabilities:
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.LIABILITIESANDEQUITY(), TotalLiabilities());
            GLAccountCategory."Account Category"::Equity:
                UpdateGLAccounts(GLAccountCategory, Equity(), TotalLiabilitiesAndEquity());
            GLAccountCategory."Account Category"::Income:
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.INCOMESTATEMENT(), TotalRevenue());
                    UpdateGLAccounts(GLAccountCategory, GainsandLossesBeginTotal(), TotalGainsAndLosses());
                end;
            GLAccountCategory."Account Category"::"Cost of Goods Sold":
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Cost(), TotalCost());
            GLAccountCategory."Account Category"::Expense:
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.OperatingExpenses(), TotalOperatingExpenses());
                    UpdateGLAccounts(GLAccountCategory, EBITDA(), TotalIncomeTaxes());
                    UpdateGLAccounts(GLAccountCategory, NetIncomeBeforeExtrItems(), ExtraordinaryItemsTotal());
                end;
        end;
    end;

    local procedure AssignSubcategoryToChartOfAccountsForMini(GLAccountCategory: Record "G/L Account Category")
    var
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case GLAccountCategory.Description of
            GLAccountCategoryMgt.GetAR():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.CustomersDomestic(), '13350');
            GLAccountCategoryMgt.GetPrepaidExpenses():
                UpdateGLAccounts(GLAccountCategory, '13510', VendorPrepaymentsRetail());
            GLAccountCategoryMgt.GetInventory():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.ResaleItems(), CreateGLAccount.RawMaterials());
            GLAccountCategoryMgt.GetEquipment():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.VehiclesBeginTotal(), '16220');
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.OperatingEquipment(), '17120');
                end;
            GLAccountCategoryMgt.GetAccumDeprec():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.AccumDepreciationVehicles(), CreateGLAccount.AccumDepreciationVehicles());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.AccumDeprOperEquip(), CreateGLAccount.AccumDeprOperEquip());
                    UpdateGLAccounts(GLAccountCategory, AccumDepreciationBuildings(), AccumDepreciationBuildings());
                end;
            GLAccountCategoryMgt.GetCurrentLiabilities():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.RevolvingCredit(), CreateGLAccount.RevolvingCredit());
                    UpdateGLAccounts(GLAccountCategory, '22160', CustomerPrepaymentsRetail());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.VendorsDomestic(), AccruedPayables());
                    UpdateGLAccounts(GLAccountCategory, ProvincialSalesTax(), GSTHSTSalesTax());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.CorporateTaxesPayable(), CreateGLAccount.CorporateTaxesPayable());
                end;
            GLAccountCategoryMgt.GetPayrollLiabilities():
                UpdateGLAccounts(GLAccountCategory, AccruedSalariesWages(), CreateGLAccount.PayrollTaxesPayable());
            GLAccountCategoryMgt.GetLongTermLiabilities():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.LongTermBankLoans(), CreateGLAccount.DeferredTaxes());
            GLAccountCategoryMgt.GetCommonStock():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.CapitalStock(), CreateGLAccount.CapitalStock());
            GLAccountCategoryMgt.GetRetEarnings():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.RetainedEarnings(), CreateGLAccount.RetainedEarnings());
            GLAccountCategoryMgt.GetIncomeService():
                begin
                    UpdateGLAccounts(GLAccountCategory, TotalSalesOfRetail(), TotalSalesOfRetail());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.SalesRawMaterialsExport(), CreateGLAccount.JobSalesAdjmtRawMat());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.SalesResourcesExport(), CreateGLAccount.JobSalesAdjmtResources());
                end;
            GLAccountCategoryMgt.GetIncomeProdSales():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.JobSales(), TotalSalesOfJobs());
            GLAccountCategoryMgt.GetCOGSLabor():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.JobCosts(), CreateGLAccount.JobCosts());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.CostofResourcesUsed(), CreateGLAccount.CostofResourcesUsed());
                end;
            GLAccountCategoryMgt.GetCOGSMaterials():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.PurchRawMaterialsDom(), CreateGLAccount.PurchRawMaterialsExport());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Cost(), TotalCostOfRawMaterials());
                end;
            CostofGoodsSold():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.PurchRetailDom(), CreateGLAccount.DeliveryExpensesRetail());
                    UpdateGLAccounts(GLAccountCategory, PaymentDiscountsGrantedCOGS(), PaymentDiscountsGrantedCOGS());
                end;
            GLAccountCategoryMgt.GetAdvertisingExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Advertising(), CreateGLAccount.EntertainmentandPR());
            GLAccountCategoryMgt.GetTravelExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Travel(), CreateGLAccount.Travel());
            GLAccountCategoryMgt.GetFeesExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.RegistrationFees(), CreateGLAccount.RegistrationFees());
            GLAccountCategoryMgt.GetPayrollExpense():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Wages(), CreateGLAccount.Wages());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.RetirementPlanContributions(), WorkersCompensation());
                end;
            GLAccountCategoryMgt.GetSalariesExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Salaries(), CreateGLAccount.Salaries());
            GLAccountCategoryMgt.GetVehicleExpenses():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.GasolineandMotorOil(), CreateGLAccount.GasolineandMotorOil());
            GLAccountCategoryMgt.GetRepairsExpense():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.RepairsandMaintenance(), CreateGLAccount.RepairsandMaintenance());
                    UpdateGLAccounts(GLAccountCategory, RepairsandMaintenanceExpense(), RepairsandMaintenanceExpense());
                end;
            GLAccountCategoryMgt.GetUtilitiesExpense():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Cleaning(), CreateGLAccount.ElectricityandHeating());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.OfficeSupplies(), CreateGLAccount.Postage());
                end;
            GLAccountCategoryMgt.GetOtherIncomeExpense():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.FeesandChargesRecDom(), TotalInterestIncome());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Software(), CreateGLAccount.OtherComputerExpenses());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.CashDiscrepancies(), CreateGLAccount.CashDiscrepancies());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.LegalandAccountingServices(), CreateGLAccount.OtherCostsofOperations());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.InvoiceRounding(), CreateGLAccount.PmtTolReceivedDecreases());
                end;
            GLAccountCategoryMgt.GetBadDebtExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.BadDebtExpenses(), CreateGLAccount.BadDebtExpenses());
        end;
    end;

    local procedure UpdateGLAccounts(GLAccountCategory: Record "G/L Account Category"; FromGLAccountNo: Code[20]; ToGLAccountNo: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetRange("No.", FromGLAccountNo, ToGLAccountNo);
        if GLAccount.FindSet() then begin
            GLAccount.ModifyAll("Account Category", GLAccountCategory."Account Category", false);
            GLAccount.ModifyAll("Account Subcategory Entry No.", GLAccountCategory."Entry No.", false);
        end;
    end;

    procedure BankChecking(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankCheckingName()));
    end;

    procedure BankCheckingName(): Text[100]
    begin
        exit(BankCheckingTok);
    end;

    procedure BankCurrenciesLCY(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankCurrenciesLCYName()));
    end;

    procedure BankCurrenciesLCYName(): Text[100]
    begin
        exit(BankCurrenciesLCYTok);
    end;

    procedure BankCurrenciesFCYUSD(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankCurrenciesFCYUSDName()));
    end;

    procedure BankCurrenciesFCYUSDName(): Text[100]
    begin
        exit(BankCurrenciesFCYUSDTok);
    end;

    procedure BankOperationsCash(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankOperationsCashName()));
    end;

    procedure BankOperationsCashName(): Text[100]
    begin
        exit(BankOperationsCashTok);
    end;

    procedure LiquidAssetsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LiquidAssetsTotalName()));
    end;

    procedure LiquidAssetsTotalName(): Text[100]
    begin
        exit(LiquidAssetsTotalTok);
    end;

    procedure ShortTermInvestments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShortTermInvestmentsName()));
    end;

    procedure ShortTermInvestmentsName(): Text[100]
    begin
        exit(ShortTermInvestmentsTok);
    end;

    procedure CanadianTermDeposits(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CanadianTermDepositsName()));
    end;

    procedure CanadianTermDepositsName(): Text[100]
    begin
        exit(CanadianTermDepositsTok);
    end;

    procedure OtherMarketableSecurities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherMarketableSecuritiesName()));
    end;

    procedure OtherMarketableSecuritiesName(): Text[100]
    begin
        exit(OtherMarketableSecuritiesTok);
    end;

    procedure InterestAccruedOnInvestment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestAccruedOnInvestmentName()));
    end;

    procedure InterestAccruedOnInvestmentName(): Text[100]
    begin
        exit(InterestAccruedOnInvestmentTok);
    end;

    procedure SecuritiesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SecuritiesTotalName()));
    end;

    procedure SecuritiesTotalName(): Text[100]
    begin
        exit(SecuritiesTotalTok);
    end;

    procedure OtherReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherReceivablesName()));
    end;

    procedure OtherReceivablesName(): Text[100]
    begin
        exit(OtherReceivablesTok);
    end;

    procedure AccountsReceivableTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsReceivableTotalName()));
    end;

    procedure AccountsReceivableTotalName(): Text[100]
    begin
        exit(AccountsReceivableTotalTok);
    end;

    procedure VendorPrepaymentsServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorPrepaymentsServicesName()));
    end;

    procedure VendorPrepaymentsServicesName(): Text[100]
    begin
        exit(VendorPrepaymentsServicesTok);
    end;

    procedure VendorPrepaymentsRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorPrepaymentsRetailName()));
    end;

    procedure VendorPrepaymentsRetailName(): Text[100]
    begin
        exit(VendorPrepaymentsRetailTok);
    end;

    procedure PurchasePrepaymentsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasePrepaymentsTotalName()));
    end;

    procedure PurchasePrepaymentsTotalName(): Text[100]
    begin
        exit(PurchasePrepaymentsTotalTok);
    end;

    procedure AllowanceForFinishedGoodsWriteOffs(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AllowanceForFinishedGoodsWriteOffsName()));
    end;

    procedure AllowanceForFinishedGoodsWriteOffsName(): Text[100]
    begin
        exit(AllowanceForFinishedGoodsWriteOffsTok);
    end;

    procedure WipAccountFinishedGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WipAccountFinishedGoodsName()));
    end;

    procedure WipAccountFinishedGoodsName(): Text[100]
    begin
        exit(WipAccountFinishedGoodsTok);
    end;

    procedure InventoryTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryTotalName()));
    end;

    procedure InventoryTotalName(): Text[100]
    begin
        exit(InventoryTotalTok);
    end;

    procedure WipSalesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WipSalesTotalName()));
    end;

    procedure WipSalesTotalName(): Text[100]
    begin
        exit(WipSalesTotalTok);
    end;

    procedure WipCostsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WipCostsTotalName()));
    end;

    procedure WipCostsTotalName(): Text[100]
    begin
        exit(WipCostsTotalTok);
    end;

    procedure JobWIPTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobWIPTotalName()));
    end;

    procedure JobWIPTotalName(): Text[100]
    begin
        exit(JobWIPTotalTok);
    end;

    procedure CurrentAssetsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentAssetsTotalName()));
    end;

    procedure CurrentAssetsTotalName(): Text[100]
    begin
        exit(CurrentAssetsTotalTok);
    end;

    procedure VehiclesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VehiclesTotalName()));
    end;

    procedure VehiclesTotalName(): Text[100]
    begin
        exit(VehiclesTotalTok);
    end;

    procedure OperatingEquipmentTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OperatingEquipmentTotalName()));
    end;

    procedure OperatingEquipmentTotalName(): Text[100]
    begin
        exit(OperatingEquipmentTotalTok);
    end;

    procedure LandAndBuildingsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LandAndBuildingsTotalName()));
    end;

    procedure LandAndBuildingsTotalName(): Text[100]
    begin
        exit(LandAndBuildingsTotalTok);
    end;

    procedure TangibleFixedAssetsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TangibleFixedAssetsTotalName()));
    end;

    procedure TangibleFixedAssetsTotalName(): Text[100]
    begin
        exit(TangibleFixedAssetsTotalTok);
    end;

    procedure IntangibleAssetsBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangibleAssetsBeginTotalName()));
    end;

    procedure IntangibleAssetsBeginTotalName(): Text[100]
    begin
        exit(IntangibleAssetsBeginTotalTok);
    end;

    procedure IntangibleAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangibleAssetsName()));
    end;

    procedure IntangibleAssetsName(): Text[100]
    begin
        exit(IntangibleAssetsTok);
    end;

    procedure AccAmortnOnIntangibles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccAmortnOnIntangiblesName()));
    end;

    procedure AccAmortnOnIntangiblesName(): Text[100]
    begin
        exit(AccAmortnOnIntangiblesTok);
    end;

    procedure IntangibleAssetsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangibleAssetsTotalName()));
    end;

    procedure IntangibleAssetsTotalName(): Text[100]
    begin
        exit(IntangibleAssetsTotalTok);
    end;

    procedure FixedAssetsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FixedAssetsTotalName()));
    end;

    procedure FixedAssetsTotalName(): Text[100]
    begin
        exit(FixedAssetsTotalTok);
    end;

    procedure TotalAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAssetsName()));
    end;

    procedure TotalAssetsName(): Text[100]
    begin
        exit(TotalAssetsTok);
    end;

    procedure DeferredRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferredRevenueName()));
    end;

    procedure DeferredRevenueName(): Text[100]
    begin
        exit(DeferredRevenueTok);
    end;

    procedure CustomerPrepaymentsServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerPrepaymentsServicesName()));
    end;

    procedure CustomerPrepaymentsServicesName(): Text[100]
    begin
        exit(CustomerPrepaymentsServicesTok);
    end;

    procedure CustomerPrepaymentsRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerPrepaymentsRetailName()));
    end;

    procedure CustomerPrepaymentsRetailName(): Text[100]
    begin
        exit(CustomerPrepaymentsRetailTok);
    end;

    procedure PrepaidServiceContracts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaidServiceContractsName()));
    end;

    procedure PrepaidServiceContractsName(): Text[100]
    begin
        exit(PrepaidServiceContractsTok);
    end;

    procedure SalesPrepaymentsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesPrepaymentsTotalName()));
    end;

    procedure SalesPrepaymentsTotalName(): Text[100]
    begin
        exit(SalesPrepaymentsTotalTok);
    end;

    procedure AccountsPayableEmployees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsPayableEmployeesName()));
    end;

    procedure AccountsPayableEmployeesName(): Text[100]
    begin
        exit(AccountsPayableEmployeesTok);
    end;

    procedure AccruedPayables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedPayablesName()));
    end;

    procedure AccruedPayablesName(): Text[100]
    begin
        exit(AccruedPayablesTok);
    end;

    procedure AccountsPayableTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsPayableTotalName()));
    end;

    procedure AccountsPayableTotalName(): Text[100]
    begin
        exit(AccountsPayableTotalTok);
    end;

    procedure InvAdjmtInterimTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvAdjmtInterimTotalName()));
    end;

    procedure InvAdjmtInterimTotalName(): Text[100]
    begin
        exit(InvAdjmtInterimTotalTok);
    end;

    procedure TaxesPayables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxesPayablesName()));
    end;

    procedure TaxesPayablesName(): Text[100]
    begin
        exit(TaxesPayablesTok);
    end;

    procedure IncomeTaxPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeTaxPayableName()));
    end;

    procedure IncomeTaxPayableName(): Text[100]
    begin
        exit(IncomeTaxPayableTok);
    end;

    procedure ProvincialSalesTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProvincialSalesTaxName()));
    end;

    procedure ProvincialSalesTaxName(): Text[100]
    begin
        exit(ProvincialSalesTaxTok);
    end;

    procedure QSTSalesTaxCollected(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(QSTSalesTaxCollectedName()));
    end;

    procedure QSTSalesTaxCollectedName(): Text[100]
    begin
        exit(QSTSalesTaxCollectedTok);
    end;

    procedure PurchaseTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseTaxName()));
    end;

    procedure PurchaseTaxName(): Text[100]
    begin
        exit(PurchaseTaxTok);
    end;

    procedure GSTHSTSalesTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GSTHSTSalesTaxName()));
    end;

    procedure GSTHSTSalesTaxName(): Text[100]
    begin
        exit(GSTHSTSalesTaxTok);
    end;

    procedure GSTHSTInputCredits(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GSTHSTInputCreditsName()));
    end;

    procedure GSTHSTInputCreditsName(): Text[100]
    begin
        exit(GSTHSTInputCreditsTok);
    end;

    procedure IncomeTaxAccrued(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeTaxAccruedName()));
    end;

    procedure IncomeTaxAccruedName(): Text[100]
    begin
        exit(IncomeTaxAccruedTok);
    end;

    procedure QuebecBeerTaxesAccrued(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(QuebecBeerTaxesAccruedName()));
    end;

    procedure QuebecBeerTaxesAccruedName(): Text[100]
    begin
        exit(QuebecBeerTaxesAccruedTok);
    end;

    procedure TaxesPayablesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxesPayablesTotalName()));
    end;

    procedure TaxesPayablesTotalName(): Text[100]
    begin
        exit(TaxesPayablesTotalTok);
    end;

    procedure AccruedSalariesWages(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedSalariesWagesName()));
    end;

    procedure AccruedSalariesWagesName(): Text[100]
    begin
        exit(AccruedSalariesWagesTok);
    end;

    procedure FederalIncomeTaxExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FederalIncomeTaxExpenseName()));
    end;

    procedure FederalIncomeTaxExpenseName(): Text[100]
    begin
        exit(FederalIncomeTaxExpenseTok);
    end;

    procedure ProvincialWithholdingPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProvincialWithholdingPayableName()));
    end;

    procedure ProvincialWithholdingPayableName(): Text[100]
    begin
        exit(ProvincialWithholdingPayableTok);
    end;

    procedure FICAPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FICAPayableName()));
    end;

    procedure FICAPayableName(): Text[100]
    begin
        exit(FICAPayableTok);
    end;

    procedure MedicarePayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MedicarePayableName()));
    end;

    procedure MedicarePayableName(): Text[100]
    begin
        exit(MedicarePayableTok);
    end;

    procedure FUTAPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FUTAPayableName()));
    end;

    procedure FUTAPayableName(): Text[100]
    begin
        exit(FUTAPayableTok);
    end;

    procedure SUTAPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SUTAPayableName()));
    end;

    procedure SUTAPayableName(): Text[100]
    begin
        exit(SUTAPayableTok);
    end;

    procedure EmployeeBenefitsPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployeeBenefitsPayableName()));
    end;

    procedure EmployeeBenefitsPayableName(): Text[100]
    begin
        exit(EmployeeBenefitsPayableTok);
    end;

    procedure EmploymentInsuranceEmployeeContrib(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmploymentInsuranceEmployeeContribName()));
    end;

    procedure EmploymentInsuranceEmployeeContribName(): Text[100]
    begin
        exit(EmploymentInsuranceEmployeeContribTok);
    end;

    procedure EmploymentInsuranceEmployerContrib(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmploymentInsuranceEmployerContribName()));
    end;

    procedure EmploymentInsuranceEmployerContribName(): Text[100]
    begin
        exit(EmploymentInsuranceEmployerContribTok);
    end;

    procedure CanadaPensionFundEmployeeContrib(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CanadaPensionFundEmployeeContribName()));
    end;

    procedure CanadaPensionFundEmployeeContribName(): Text[100]
    begin
        exit(CanadaPensionFundEmployeeContribTok);
    end;

    procedure CanadaPensionFundEmployerContrib(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CanadaPensionFundEmployerContribName()));
    end;

    procedure CanadaPensionFundEmployerContribName(): Text[100]
    begin
        exit(CanadaPensionFundEmployerContribTok);
    end;

    procedure QuebecPipPayableEmployee(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(QuebecPipPayableEmployeeName()));
    end;

    procedure QuebecPipPayableEmployeeName(): Text[100]
    begin
        exit(QuebecPipPayableEmployeeTok);
    end;

    procedure GarnishmentPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GarnishmentPayableName()));
    end;

    procedure GarnishmentPayableName(): Text[100]
    begin
        exit(GarnishmentPayableTok);
    end;

    procedure TotalPersonnelRelatedItems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPersonnelRelatedItemsName()));
    end;

    procedure TotalPersonnelRelatedItemsName(): Text[100]
    begin
        exit(TotalPersonnelRelatedItemsTok);
    end;

    procedure OtherLiabilitiesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherLiabilitiesTotalName()));
    end;

    procedure OtherLiabilitiesTotalName(): Text[100]
    begin
        exit(OtherLiabilitiesTotalTok);
    end;

    procedure ShortTermLiabilitiesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShortTermLiabilitiesTotalName()));
    end;

    procedure ShortTermLiabilitiesTotalName(): Text[100]
    begin
        exit(ShortTermLiabilitiesTotalTok);
    end;

    procedure DeferralRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferralRevenueName()));
    end;

    procedure DeferralRevenueName(): Text[100]
    begin
        exit(DeferralRevenueTok);
    end;

    procedure LongTermLiabilitiesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LongTermLiabilitiesTotalName()));
    end;

    procedure LongTermLiabilitiesTotalName(): Text[100]
    begin
        exit(LongTermLiabilitiesTotalTok);
    end;

    procedure TotalLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalLiabilitiesName()));
    end;

    procedure TotalLiabilitiesName(): Text[100]
    begin
        exit(TotalLiabilitiesTok);
    end;

    procedure Equity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquityName()));
    end;

    procedure EquityName(): Text[100]
    begin
        exit(EquityTok);
    end;

    procedure NetIncomeForTheYear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NetIncomeForTheYearName()));
    end;

    procedure NetIncomeForTheYearName(): Text[100]
    begin
        exit(NetIncomeForTheYearTok);
    end;

    procedure TotalStockholdersEquity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalStockholdersEquityName()));
    end;

    procedure TotalStockholdersEquityName(): Text[100]
    begin
        exit(TotalStockholdersEquityTok);
    end;

    procedure TotalLiabilitiesAndEquity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalLiabilitiesAndEquityName()));
    end;

    procedure TotalLiabilitiesAndEquityName(): Text[100]
    begin
        exit(TotalLiabilitiesAndEquityTok);
    end;

    procedure TotalSalesOfRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesOfRetailName()));
    end;

    procedure TotalSalesOfRetailName(): Text[100]
    begin
        exit(TotalSalesOfRetailTok);
    end;

    procedure TotalSalesOfRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesOfRawMaterialsName()));
    end;

    procedure TotalSalesOfRawMaterialsName(): Text[100]
    begin
        exit(TotalSalesOfRawMaterialsTok);
    end;

    procedure TotalSalesOfResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesOfResourcesName()));
    end;

    procedure TotalSalesOfResourcesName(): Text[100]
    begin
        exit(TotalSalesOfResourcesTok);
    end;

    procedure TotalSalesOfJobs(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesOfJobsName()));
    end;

    procedure TotalSalesOfJobsName(): Text[100]
    begin
        exit(TotalSalesOfJobsTok);
    end;

    procedure SalesOfServiceContracts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesOfServiceContractsName()));
    end;

    procedure SalesOfServiceContractsName(): Text[100]
    begin
        exit(SalesOfServiceContractsTok);
    end;

    procedure ServiceContractSale(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServiceContractSaleName()));
    end;

    procedure ServiceContractSaleName(): Text[100]
    begin
        exit(ServiceContractSaleTok);
    end;

    procedure TotalSaleOfServContracts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSaleOfServContractsName()));
    end;

    procedure TotalSaleOfServContractsName(): Text[100]
    begin
        exit(TotalSaleOfServContractsTok);
    end;

    procedure TotalInterestIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalInterestIncomeName()));
    end;

    procedure TotalInterestIncomeName(): Text[100]
    begin
        exit(TotalInterestIncomeTok);
    end;

    procedure TotalRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRevenueName()));
    end;

    procedure TotalRevenueName(): Text[100]
    begin
        exit(TotalRevenueTok);
    end;

    procedure TotalCostOfResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostOfResourcesName()));
    end;

    procedure TotalCostOfResourcesName(): Text[100]
    begin
        exit(TotalCostOfResourcesTok);
    end;

    procedure CostOfCapacitiesBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfCapacitiesBeginTotalName()));
    end;

    procedure CostOfCapacitiesBeginTotalName(): Text[100]
    begin
        exit(CostOfCapacitiesBeginTotalTok);
    end;

    procedure CostOfCapacities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfCapacitiesName()));
    end;

    procedure CostOfCapacitiesName(): Text[100]
    begin
        exit(CostOfCapacitiesTok);
    end;

    procedure DirectCostAppliedCap(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DirectCostAppliedCapName()));
    end;

    procedure DirectCostAppliedCapName(): Text[100]
    begin
        exit(DirectCostAppliedCapTok);
    end;

    procedure OverheadAppliedCap(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OverheadAppliedCapName()));
    end;

    procedure OverheadAppliedCapName(): Text[100]
    begin
        exit(OverheadAppliedCapTok);
    end;

    procedure PurchaseVarianceCap(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVarianceCapName()));
    end;

    procedure PurchaseVarianceCapName(): Text[100]
    begin
        exit(PurchaseVarianceCapTok);
    end;

    procedure TotalCostOfCapacities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostOfCapacitiesName()));
    end;

    procedure TotalCostOfCapacitiesName(): Text[100]
    begin
        exit(TotalCostOfCapacitiesTok);
    end;

    procedure JobCostAppliedRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostAppliedRawMaterialsName()));
    end;

    procedure JobCostAppliedRawMaterialsName(): Text[100]
    begin
        exit(JobCostAppliedRawMaterialsTok);
    end;

    procedure DirectCostAppliedRawmat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DirectCostAppliedRawmatName()));
    end;

    procedure DirectCostAppliedRawmatName(): Text[100]
    begin
        exit(DirectCostAppliedRawmatTok);
    end;

    procedure OverheadAppliedRawmat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OverheadAppliedRawmatName()));
    end;

    procedure OverheadAppliedRawmatName(): Text[100]
    begin
        exit(OverheadAppliedRawmatTok);
    end;

    procedure PurchaseVarianceRawmat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVarianceRawmatName()));
    end;

    procedure PurchaseVarianceRawmatName(): Text[100]
    begin
        exit(PurchaseVarianceRawmatTok);
    end;

    procedure TotalCostOfRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostOfRawMaterialsName()));
    end;

    procedure TotalCostOfRawMaterialsName(): Text[100]
    begin
        exit(TotalCostOfRawMaterialsTok);
    end;

    procedure OverheadAppliedRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OverheadAppliedRetailName()));
    end;

    procedure OverheadAppliedRetailName(): Text[100]
    begin
        exit(OverheadAppliedRetailTok);
    end;

    procedure PurchaseVarianceRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVarianceRetailName()));
    end;

    procedure PurchaseVarianceRetailName(): Text[100]
    begin
        exit(PurchaseVarianceRetailTok);
    end;

    procedure DirectCostAppliedRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DirectCostAppliedRetailName()));
    end;

    procedure DirectCostAppliedRetailName(): Text[100]
    begin
        exit(DirectCostAppliedRetailTok);
    end;

    procedure TotalCostOfRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostOfRetailName()));
    end;

    procedure TotalCostOfRetailName(): Text[100]
    begin
        exit(TotalCostOfRetailTok);
    end;

    procedure Variance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VarianceName()));
    end;

    procedure VarianceName(): Text[100]
    begin
        exit(VarianceTok);
    end;

    procedure MaterialVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaterialVarianceName()));
    end;

    procedure MaterialVarianceName(): Text[100]
    begin
        exit(MaterialVarianceTok);
    end;

    procedure CapacityVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapacityVarianceName()));
    end;

    procedure CapacityVarianceName(): Text[100]
    begin
        exit(CapacityVarianceTok);
    end;

    procedure SubcontractedVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubcontractedVarianceName()));
    end;

    procedure SubcontractedVarianceName(): Text[100]
    begin
        exit(SubcontractedVarianceTok);
    end;

    procedure CapOverheadVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapOverheadVarianceName()));
    end;

    procedure CapOverheadVarianceName(): Text[100]
    begin
        exit(CapOverheadVarianceTok);
    end;

    procedure MfgOverheadVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MfgOverheadVarianceName()));
    end;

    procedure MfgOverheadVarianceName(): Text[100]
    begin
        exit(MfgOverheadVarianceTok);
    end;

    procedure TotalVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalVarianceName()));
    end;

    procedure TotalVarianceName(): Text[100]
    begin
        exit(TotalVarianceTok);
    end;

    procedure TotalCost(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostName()));
    end;

    procedure TotalCostName(): Text[100]
    begin
        exit(TotalCostTok);
    end;

    procedure TotalSellingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSellingExpensesName()));
    end;

    procedure TotalSellingExpensesName(): Text[100]
    begin
        exit(TotalSellingExpensesTok);
    end;

    procedure HealthInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HealthInsuranceName()));
    end;

    procedure HealthInsuranceName(): Text[100]
    begin
        exit(HealthInsuranceTok);
    end;

    procedure GroupLifeInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GroupLifeInsuranceName()));
    end;

    procedure GroupLifeInsuranceName(): Text[100]
    begin
        exit(GroupLifeInsuranceTok);
    end;

    procedure WorkersCompensation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WorkersCompensationName()));
    end;

    procedure WorkersCompensationName(): Text[100]
    begin
        exit(WorkersCompensationTok);
    end;

    procedure FourHounderedOneKContributions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FourHounderedOneKContributionsName()));
    end;

    procedure FourHounderedOneKContributionsName(): Text[100]
    begin
        exit(FourHounderedOneKContributionsTok);
    end;

    procedure TotalPersonnelExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPersonnelExpensesName()));
    end;

    procedure TotalPersonnelExpensesName(): Text[100]
    begin
        exit(TotalPersonnelExpensesTok);
    end;

    procedure Taxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxesName()));
    end;

    procedure TaxesName(): Text[100]
    begin
        exit(TaxesTok);
    end;

    procedure TotalVehicleExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalVehicleExpensesName()));
    end;

    procedure TotalVehicleExpensesName(): Text[100]
    begin
        exit(TotalVehicleExpensesTok);
    end;

    procedure TotalComputerExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalComputerExpensesName()));
    end;

    procedure TotalComputerExpensesName(): Text[100]
    begin
        exit(TotalComputerExpensesTok);
    end;

    procedure TotalBldgMaintExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalBldgMaintExpensesName()));
    end;

    procedure TotalBldgMaintExpensesName(): Text[100]
    begin
        exit(TotalBldgMaintExpensesTok);
    end;

    procedure TotalAdministrativeExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAdministrativeExpensesName()));
    end;

    procedure TotalAdministrativeExpensesName(): Text[100]
    begin
        exit(TotalAdministrativeExpensesTok);
    end;

    procedure OtherOperatingExpTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherOperatingExpTotalName()));
    end;

    procedure OtherOperatingExpTotalName(): Text[100]
    begin
        exit(OtherOperatingExpTotalTok);
    end;

    procedure TotalOperatingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOperatingExpensesName()));
    end;

    procedure TotalOperatingExpensesName(): Text[100]
    begin
        exit(TotalOperatingExpensesTok);
    end;

    procedure EBITDA(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EBITDAName()));
    end;

    procedure EBITDAName(): Text[100]
    begin
        exit(EBITDATok);
    end;

    procedure TotalFixedAssetDepreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFixedAssetDepreciationName()));
    end;

    procedure TotalFixedAssetDepreciationName(): Text[100]
    begin
        exit(TotalFixedAssetDepreciationTok);
    end;

    procedure TotalInterestExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalInterestExpensesName()));
    end;

    procedure TotalInterestExpensesName(): Text[100]
    begin
        exit(TotalInterestExpensesTok);
    end;

    procedure GainsandLossesBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainsandLossesBeginTotalName()));
    end;

    procedure GainsandLossesBeginTotalName(): Text[100]
    begin
        exit(GainsandLossesBeginTotalTok);
    end;

    procedure TotalGainsAndLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalGainsAndLossesName()));
    end;

    procedure TotalGainsAndLossesName(): Text[100]
    begin
        exit(TotalGainsAndLossesTok);
    end;

    procedure NiBeforeExtrItemsTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NiBeforeExtrItemsTaxesName()));
    end;

    procedure NiBeforeExtrItemsTaxesName(): Text[100]
    begin
        exit(NiBeforeExtrItemsTaxesTok);
    end;

    procedure IncomeTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeTaxesName()));
    end;

    procedure IncomeTaxesName(): Text[100]
    begin
        exit(IncomeTaxesTok);
    end;

    procedure StateIncomeTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StateIncomeTaxName()));
    end;

    procedure StateIncomeTaxName(): Text[100]
    begin
        exit(StateIncomeTaxTok);
    end;

    procedure TotalIncomeTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalIncomeTaxesName()));
    end;

    procedure TotalIncomeTaxesName(): Text[100]
    begin
        exit(TotalIncomeTaxesTok);
    end;

    procedure NetIncomeBeforeExtrItems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NetIncomeBeforeExtrItemsName()));
    end;

    procedure NetIncomeBeforeExtrItemsName(): Text[100]
    begin
        exit(NetIncomeBeforeExtrItemsTok);
    end;

    procedure ExtraordinaryItems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExtraordinaryItemsName()));
    end;

    procedure ExtraordinaryItemsName(): Text[100]
    begin
        exit(ExtraordinaryItemsTok);
    end;

    procedure RevaluationSurplusAdjustments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevaluationSurplusAdjustmentsName()));
    end;

    procedure RevaluationSurplusAdjustmentsName(): Text[100]
    begin
        exit(RevaluationSurplusAdjustmentsTok);
    end;

    procedure ExtraordinaryItemsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExtraordinaryItemsTotalName()));
    end;

    procedure ExtraordinaryItemsTotalName(): Text[100]
    begin
        exit(ExtraordinaryItemsTotalTok);
    end;

    procedure PaymentDiscountsGrantedCOGS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymentDiscountsGrantedCOGSName()));
    end;

    procedure PaymentDiscountsGrantedCOGSName(): Text[100]
    begin
        exit(PaymentDiscountsGrantedCOGSTok);
    end;

    procedure RepairsandMaintenanceExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RepairsandMaintenanceExpenseName()));
    end;

    procedure RepairsandMaintenanceExpenseName(): Text[100]
    begin
        exit(RepairsandMaintenanceExpensesTok);
    end;

    procedure AccumDepreciationBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDepreciationBuildingsName()));
    end;

    procedure AccumDepreciationBuildingsName(): Text[100]
    begin
        exit(AccumDepreciationBuildingsTok);
    end;

    procedure EmployeesPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployeesPayableName()));
    end;

    procedure EmployeesPayableName(): Text[100]
    begin
        exit(EmployeesPayableTok);
    end;

    procedure CostofGoodsSold(): Text[80]
    begin
        exit(CostofGoodsSoldTok);
    end;

    procedure Miscellaneous(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscellaneousName()));
    end;

    procedure MiscellaneousName(): Text[100]
    begin
        exit(MiscellaneousTok);
    end;

    var
        ContosoGLAccount: codeunit "Contoso GL Account";
        BankCheckingTok: Label 'Bank, Checking', MaxLength = 100;
        BankCurrenciesLCYTok: Label 'Bank Currencies LCY', MaxLength = 100;
        BankCurrenciesFCYUSDTok: Label 'Bank Currencies FCY - USD ', MaxLength = 100;
        BankOperationsCashTok: Label 'Bank Operations Cash', MaxLength = 100;
        LiquidAssetsTotalTok: Label 'Liquid Assets, Total', MaxLength = 100;
        ShortTermInvestmentsTok: Label 'Short Term Investments', MaxLength = 100;
        CanadianTermDepositsTok: Label 'Canadian Term Deposits', MaxLength = 100;
        OtherMarketableSecuritiesTok: Label 'Other Marketable Securities', MaxLength = 100;
        InterestAccruedOnInvestmentTok: Label 'Interest Accrued on investment', MaxLength = 100;
        SecuritiesTotalTok: Label 'Securities, Total', MaxLength = 100;
        OtherReceivablesTok: Label 'Other Receivables ', MaxLength = 100;
        AccountsReceivableTotalTok: Label 'Accounts Receivable, Total', MaxLength = 100;
        VendorPrepaymentsServicesTok: Label 'Vendor Prepayments SERVICES', MaxLength = 100;
        VendorPrepaymentsRetailTok: Label 'Vendor Prepayments RETAIL', MaxLength = 100;
        PurchasePrepaymentsTotalTok: Label 'Purchase Prepayments, Total', MaxLength = 100;
        AllowanceForFinishedGoodsWriteOffsTok: Label 'Allowance for Finished Goods Write-Offs', MaxLength = 100;
        WipAccountFinishedGoodsTok: Label 'WIP Account, Finished goods', MaxLength = 100;
        InventoryTotalTok: Label 'Inventory, Total', MaxLength = 100;
        WipSalesTotalTok: Label 'WIP Sales, Total', MaxLength = 100;
        WipCostsTotalTok: Label 'WIP Costs, Total', MaxLength = 100;
        JobWIPTotalTok: Label 'Job WIP, Total', MaxLength = 100;
        CurrentAssetsTotalTok: Label 'Current Assets, Total', MaxLength = 100;
        VehiclesTotalTok: Label 'Vehicles, Total', MaxLength = 100;
        OperatingEquipmentTotalTok: Label 'Operating Equipment, Total', MaxLength = 100;
        LandAndBuildingsTotalTok: Label 'Land and Buildings, Total', MaxLength = 100;
        TangibleFixedAssetsTotalTok: Label 'Tangible Fixed Assets, Total', MaxLength = 100;
        IntangibleAssetsBeginTotalTok: Label 'Intangible Assets, Begin Total', MaxLength = 100;
        IntangibleAssetsTok: Label 'Intangible Assets', MaxLength = 100;
        AccAmortnOnIntangiblesTok: Label 'Acc. Amortn on Intangibles', MaxLength = 100;
        IntangibleAssetsTotalTok: Label 'Intangible Assets, Total', MaxLength = 100;
        FixedAssetsTotalTok: Label 'Fixed Assets, Total', MaxLength = 100;
        TotalAssetsTok: Label 'TOTAL ASSETS', MaxLength = 100;
        DeferredRevenueTok: Label 'Deferred Revenue', MaxLength = 100;
        CustomerPrepaymentsServicesTok: Label 'Customer Prepayments SERVICES', MaxLength = 100;
        CustomerPrepaymentsRetailTok: Label 'Customer Prepayments RETAIL', MaxLength = 100;
        PrepaidServiceContractsTok: Label 'Prepaid Service Contracts', MaxLength = 100;
        SalesPrepaymentsTotalTok: Label 'Sales Prepayments, Total', MaxLength = 100;
        AccountsPayableEmployeesTok: Label 'Accounts Payable - Employees', MaxLength = 100;
        AccruedPayablesTok: Label 'Accrued Payables', MaxLength = 100;
        AccountsPayableTotalTok: Label 'Accounts Payable, Total', MaxLength = 100;
        InvAdjmtInterimTotalTok: Label 'Inv. Adjmt. (Interim), Total', MaxLength = 100;
        TaxesPayablesTok: Label 'Taxes Payables', MaxLength = 100;
        IncomeTaxPayableTok: Label 'Income Tax Payable ', MaxLength = 100;
        ProvincialSalesTaxTok: Label 'Provincial Sales Tax', MaxLength = 100;
        QSTSalesTaxCollectedTok: Label 'QST - Sales Tax Collected', MaxLength = 100;
        PurchaseTaxTok: Label 'Purchase Tax', MaxLength = 100;
        GSTHSTSalesTaxTok: Label 'GST/HST - Sales Tax', MaxLength = 100;
        GSTHSTInputCreditsTok: Label 'GST/HST -Input Credits', MaxLength = 100;
        IncomeTaxAccruedTok: Label 'Income Tax Accrued ', MaxLength = 100;
        QuebecBeerTaxesAccruedTok: Label 'Quebec Beer Taxes Accrued', MaxLength = 100;
        TaxesPayablesTotalTok: Label 'Taxes Payables, Total', MaxLength = 100;
        AccruedSalariesWagesTok: Label 'Accrued Salaries & Wages', MaxLength = 100;
        FederalIncomeTaxExpenseTok: Label 'Federal Income Tax Expense', MaxLength = 100;
        ProvincialWithholdingPayableTok: Label 'Provincial Withholding Payable', MaxLength = 100;
        FICAPayableTok: Label 'FICA Payable', MaxLength = 100;
        MedicarePayableTok: Label 'Medicare Payable', MaxLength = 100;
        FUTAPayableTok: Label 'FUTA Payable', MaxLength = 100;
        SUTAPayableTok: Label 'SUTA Payable', MaxLength = 100;
        EmployeeBenefitsPayableTok: Label 'Employee Benefits Payable', MaxLength = 100;
        EmploymentInsuranceEmployeeContribTok: Label 'Employment Insurance - Employee Contrib', MaxLength = 100;
        EmploymentInsuranceEmployerContribTok: Label 'Employment Insurance - Employer Contrib', MaxLength = 100;
        CanadaPensionFundEmployeeContribTok: Label 'Canada Pension Fund - Employee Contrib', MaxLength = 100;
        CanadaPensionFundEmployerContribTok: Label 'Canada Pension Fund - Employer Contrib', MaxLength = 100;
        QuebecPipPayableEmployeeTok: Label 'Quebec PIP Payable - Employee ', MaxLength = 100;
        GarnishmentPayableTok: Label 'Garnishment Payable', MaxLength = 100;
        TotalPersonnelRelatedItemsTok: Label 'Total Personnel-related Items', MaxLength = 100;
        OtherLiabilitiesTotalTok: Label 'Other Liabilities, Total', MaxLength = 100;
        ShortTermLiabilitiesTotalTok: Label 'Short-term Liabilities, Total', MaxLength = 100;
        DeferralRevenueTok: Label 'Deferral Revenue', MaxLength = 100;
        LongTermLiabilitiesTotalTok: Label 'Long-term Liabilities, Total', MaxLength = 100;
        TotalLiabilitiesTok: Label 'Total Liabilities', MaxLength = 100;
        EquityTok: Label 'EQUITY', MaxLength = 100;
        NetIncomeForTheYearTok: Label 'Net Income for the Year', MaxLength = 100;
        TotalStockholdersEquityTok: Label 'Total Stockholders Equity', MaxLength = 100;
        TotalLiabilitiesAndEquityTok: Label 'TOTAL LIABILITIES AND EQUITY', MaxLength = 100;
        TotalSalesOfRetailTok: Label 'Total Sales of Retail', MaxLength = 100;
        TotalSalesOfRawMaterialsTok: Label 'Total Sales of Raw Materials', MaxLength = 100;
        TotalSalesOfResourcesTok: Label 'Total Sales of Resources', MaxLength = 100;
        TotalSalesOfJobsTok: Label 'Total Sales of Jobs', MaxLength = 100;
        SalesOfServiceContractsTok: Label 'Sales of Service Contracts', MaxLength = 100;
        ServiceContractSaleTok: Label 'Service Contract Sale', MaxLength = 100;
        TotalSaleOfServContractsTok: Label 'Total Sale of Serv. Contracts', MaxLength = 100;
        TotalInterestIncomeTok: Label 'Total Interest Income', MaxLength = 100;
        TotalRevenueTok: Label 'Total Revenue', MaxLength = 100;
        TotalCostOfResourcesTok: Label 'Total Cost of Resources', MaxLength = 100;
        CostOfCapacitiesBeginTotalTok: Label 'Cost of Capacities, Begin Total', MaxLength = 100;
        CostOfCapacitiesTok: Label 'Cost of Capacities', MaxLength = 100;
        DirectCostAppliedCapTok: Label 'Direct Cost Applied, Cap.', MaxLength = 100;
        OverheadAppliedCapTok: Label 'Overhead Applied, Cap.', MaxLength = 100;
        PurchaseVarianceCapTok: Label 'Purchase Variance, Cap.', MaxLength = 100;
        TotalCostOfCapacitiesTok: Label 'Total Cost of Capacities', MaxLength = 100;
        JobCostAppliedRawMaterialsTok: Label 'Job Cost Applied, Raw Materials', MaxLength = 100;
        DirectCostAppliedRawmatTok: Label 'Direct Cost Applied, Rawmat.', MaxLength = 100;
        OverheadAppliedRawmatTok: Label 'Overhead Applied, Rawmat.', MaxLength = 100;
        PurchaseVarianceRawmatTok: Label 'Purchase Variance, Rawmat.', MaxLength = 100;
        TotalCostOfRawMaterialsTok: Label 'Total Cost of Raw Materials', MaxLength = 100;
        OverheadAppliedRetailTok: Label 'Overhead Applied, Retail', MaxLength = 100;
        PurchaseVarianceRetailTok: Label 'Purchase Variance, Retail', MaxLength = 100;
        DirectCostAppliedRetailTok: Label 'Direct Cost Applied, Retail', MaxLength = 100;
        TotalCostOfRetailTok: Label 'Total Cost of Retail', MaxLength = 100;
        VarianceTok: Label 'Variance', MaxLength = 100;
        MaterialVarianceTok: Label 'Material Variance', MaxLength = 100;
        CapacityVarianceTok: Label 'Capacity Variance', MaxLength = 100;
        SubcontractedVarianceTok: Label 'Subcontracted Variance', MaxLength = 100;
        CapOverheadVarianceTok: Label 'Cap. Overhead Variance', MaxLength = 100;
        MfgOverheadVarianceTok: Label 'Mfg. Overhead Variance', MaxLength = 100;
        TotalVarianceTok: Label 'Total Variance', MaxLength = 100;
        TotalCostTok: Label 'Total Cost', MaxLength = 100;
        TotalSellingExpensesTok: Label 'Total Selling Expenses', MaxLength = 100;
        HealthInsuranceTok: Label 'Health Insurance', MaxLength = 100;
        GroupLifeInsuranceTok: Label 'Group Life Insurance', MaxLength = 100;
        WorkersCompensationTok: Label 'Workers Compensation', MaxLength = 100;
        FourHounderedOneKContributionsTok: Label '401K Contributions', MaxLength = 100;
        TotalPersonnelExpensesTok: Label 'Total Personnel Expenses', MaxLength = 100;
        TaxesTok: Label 'Taxes', MaxLength = 100;
        TotalVehicleExpensesTok: Label 'Total Vehicle Expenses', MaxLength = 100;
        TotalComputerExpensesTok: Label 'Total Computer Expenses', MaxLength = 100;
        TotalBldgMaintExpensesTok: Label 'Total Bldg. Maint. Expenses', MaxLength = 100;
        TotalAdministrativeExpensesTok: Label 'Total Administrative Expenses', MaxLength = 100;
        OtherOperatingExpTotalTok: Label 'Other Operating Exp., Total', MaxLength = 100;
        TotalOperatingExpensesTok: Label 'Total Operating Expenses', MaxLength = 100;
        EBITDATok: Label 'EBITDA', MaxLength = 100;
        TotalFixedAssetDepreciationTok: Label 'Total Fixed Asset Depreciation', MaxLength = 100;
        TotalInterestExpensesTok: Label 'Total Interest Expenses', MaxLength = 100;
        GainsandLossesBeginTotalTok: Label 'Gains and Losses, Begin Total', MaxLength = 100;
        TotalGainsAndLossesTok: Label 'TOTAL GAINS AND LOSSES', MaxLength = 100;
        NiBeforeExtrItemsTaxesTok: Label 'NI BEFORE EXTR. ITEMS & TAXES', MaxLength = 100;
        IncomeTaxesTok: Label 'Income Taxes', MaxLength = 100;
        StateIncomeTaxTok: Label 'State Income Tax', MaxLength = 100;
        TotalIncomeTaxesTok: Label 'Total Income Taxes', MaxLength = 100;
        NetIncomeBeforeExtrItemsTok: Label 'NET INCOME BEFORE EXTR. ITEMS', MaxLength = 100;
        ExtraordinaryItemsTok: Label 'Extraordinary Items', MaxLength = 100;
        RevaluationSurplusAdjustmentsTok: Label 'Revaluation Surplus adjustments ', MaxLength = 100;
        ExtraordinaryItemsTotalTok: Label 'Extraordinary Items, Total', MaxLength = 100;
        PaymentDiscountsGrantedCOGSTok: Label 'Payment Discounts Granted, COGS', MaxLength = 100;
        RepairsandMaintenanceExpensesTok: Label 'Repairs and Maintenance, Expenses', MaxLength = 100;
        AccumDepreciationBuildingsTok: Label 'Accum. Depreciation, Building', MaxLength = 100;
        EmployeesPayableTok: Label 'Employee Payable', MaxLength = 100;
        CostofGoodsSoldTok: Label 'Cost of Goods Sold', MaxLength = 80;
        MiscellaneousTok: Label 'Miscellaneous.', MaxLength = 100;
}