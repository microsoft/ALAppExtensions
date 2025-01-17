codeunit 11580 "Create CH GL Accounts"
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

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '1102');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '2002');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '3400');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '4400');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '2200');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '2200');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '7291');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '7191');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '7292');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '7192');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '4199');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '4399');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '1210');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '4000');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '3080');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '3280');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '1200');
        if InventorySetup."Expected Cost Posting to G/L" then
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '1201')
        else
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '3909');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyManufacturingGLAccounts()
    var
        MfgGLAccount: Codeunit "Create Mfg GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '7791');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '7792');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '7793');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '7890');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '7891');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '7892');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '7893');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '4892');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '1260');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '2140');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create FA GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyFixedAssetGLAccounts()
    var
        FAGLAccount: Codeunit "Create FA GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.IncreasesDuringTheYearName(), '1500');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DecreasesDuringTheYearName(), '1500');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.AccumDepreciationBuildingsName(), '1509');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.MiscellaneousName(), '6780');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DepreciationEquipmentName(), '6920');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.GainsAndLossesName(), '7910');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create HR GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyHumanResourcesGLAccounts()
    var
        HRGLAccount: Codeunit "Create HR GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(HRGLAccount.EmployeesPayableName(), '2001');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Job GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyJobGLAccounts()
    var
        JobGLAccount: Codeunit "Create Job GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPInvoicedSalesName(), '4421');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPJobCostsName(), '1280');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobSalesAppliedName(), '3421');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedSalesName(), '3420');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobCostsAppliedName(), '4421');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedCostsName(), '4420');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccount()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ASSETSName(), '1');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsName(), '10');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsName(), '100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashName(), '1000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsName(), '14');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '1530');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesName(), '2');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShorttermLiabilitiesName(), '20');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermLiabilitiesName(), '24');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CapitalStockName(), '2800');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.INCOMESTATEMENTName(), '2999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostsName(), '4420');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpensesName(), '6');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CleaningName(), '6040');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PostageName(), '6512');

        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BalanceSheetName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsBeginTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearBuildingsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearBuildingsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationBuildingsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentBeginTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearOperEquipName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearOperEquipName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDeprOperEquipName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesBeginTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearVehiclesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearVehiclesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationVehiclesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsInterimName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResaleSoldInterimName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsInterimName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsInterimName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMatSoldInterimName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PrimoInventoryName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWIPName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPSalesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobSalesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoicedJobSalesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPSalesTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPCostsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobCostsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedJobCostsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPCostsTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWIPTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersDomesticName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersForeignName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedInterestName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherReceivablesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVATName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT10Name(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT25Name(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BondsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankLCYName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankCurrenciesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GiroAccountName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAssetsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesAndEquityName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.StockholderName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetainedEarningsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomefortheYearName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalStockholderName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeferredTaxesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermBankLoansName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermLiabilitiesTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevolvingCreditName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT0Name(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT10Name(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT25Name(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsDomesticName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsForeignName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRetailName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRawMatName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVAT25Name(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVAT10Name(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT25EUName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT10EUName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT25Name(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT10Name(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FuelTaxName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityTaxName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NaturalGasTaxName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CoalTaxName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CO2TaxName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WaterTaxName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATPayableName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelrelatedItemsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WithholdingTaxesPayableName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SupplementaryTaxesPayableName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesPayableName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationPayableName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EmployeesPayableName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelrelatedItemsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DividendsfortheFiscalYearName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxesPayableName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShorttermLiabilitiesTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesAndEquityName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevenueName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofRetailName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailDomName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailEUName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailExportName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRetailName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRetailName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofRetailName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofRawMaterialsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsDomName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsEUName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsExportName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRawMatName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRawMatName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofRawMaterialsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofResourcesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesDomName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesEUName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesExportName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedResourcesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtResourcesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofResourcesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofJobsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOtherJobExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofJobsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultingFeesDomName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FeesandChargesRecDomName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscountGrantedName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalRevenueName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRetailName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailDomName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailEUName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailExportName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRetailName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRetailName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRetailName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRetailName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRetailName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRetailSoldName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofRetailName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMaterialsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsDomName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsEUName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsExportName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRawMaterialsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRawMatName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRawMatName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRawMatName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRawMaterialsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMaterialsSoldName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofRawMaterialsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResourcesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedResourcesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtResourcesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResourcesUsedName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofResourcesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BuildingMaintenanceExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityandHeatingName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalBldgMaintExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdministrativeExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OfficeSuppliesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PhoneandFaxName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAdministrativeExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ComputerExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SoftwareName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultantServicesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherComputerExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalComputerExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SellingExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdvertisingName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EntertainmentandPRName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TravelName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSellingExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehicleExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GasolineandMotorOilName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RegistrationFeesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceExpenseName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalVehicleExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashDiscrepanciesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BadDebtExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LegalandAccountingServicesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MiscellaneousName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpTotalName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalOperatingExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WagesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalariesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetirementPlanContributionsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationofFixedAssetsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationBuildingsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationEquipmentName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationVehiclesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GainsandLossesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalFixedAssetDepreciationName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherCostsofOperationsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetOperatingIncomeName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestIncomeName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonBankBalancesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargesfromCustomersName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsReceivedName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtDiscReceivedDecreasesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoiceRoundingName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ApplicationRoundingName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceReceivedName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolReceivedDecreasesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestIncomeName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonRevolvingCreditName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonBankLoansName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageInterestName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargestoVendorsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsGrantedName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtDiscGrantedDecreasesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceGrantedName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolGrantedDecreasesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFXGainsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFXLossesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFXGainsName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFXLossesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NIBEFOREEXTRITEMSTAXESName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryIncomeName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryExpensesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeBeforeTaxesName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxName(), ' ');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeName(), ' ');

        ContosoGLAccount.AddAccountForLocalization(PostAccName(), '1010');
        ContosoGLAccount.AddAccountForLocalization(BankCreditName(), '1020');
        ContosoGLAccount.AddAccountForLocalization(BankCreditForeignCurrencyName(), '1022');
        ContosoGLAccount.AddAccountForLocalization(BankCreditEurName(), '1026');
        ContosoGLAccount.AddAccountForLocalization(BankCreditUsdName(), '1028');
        ContosoGLAccount.AddAccountForLocalization(BankCreditDkkName(), '1030');
        ContosoGLAccount.AddAccountForLocalization(FixedTermDepInvName(), '1050');
        ContosoGLAccount.AddAccountForLocalization(MoneyTransAccountName(), '1090');
        ContosoGLAccount.AddAccountForLocalization(TotalLiquidAssetsName(), '1099');
        ContosoGLAccount.AddAccountForLocalization(AcctsReceivableName(), '110');
        ContosoGLAccount.AddAccountForLocalization(ArsFromShipAndServicesName(), '110.0');
        ContosoGLAccount.AddAccountForLocalization(CustomerCreditDomesticName(), '1100');
        ContosoGLAccount.AddAccountForLocalization(CustomerCreditEuName(), '1101');
        ContosoGLAccount.AddAccountForLocalization(CustomerCreditForeignName(), '1102');
        ContosoGLAccount.AddAccountForLocalization(CustomerCreditIcName(), '1105');
        ContosoGLAccount.AddAccountForLocalization(AcctsRecWithShareholdersName(), '1120');
        ContosoGLAccount.AddAccountForLocalization(OtherStAcctsReceivablesName(), '114.0');
        ContosoGLAccount.AddAccountForLocalization(StAcctsReceivablesName(), '1140');
        ContosoGLAccount.AddAccountForLocalization(StLoanShareholderName(), '1160');
        ContosoGLAccount.AddAccountForLocalization(AcctsReceivablesOnGovLocName(), '117.0');
        ContosoGLAccount.AddAccountForLocalization(PurchVatMatDlName(), '1170');
        ContosoGLAccount.AddAccountForLocalization(PurchVatInvOperatingExpName(), '1171');
        ContosoGLAccount.AddAccountForLocalization(PurchVatOnImports100PercentName(), '1174');
        ContosoGLAccount.AddAccountForLocalization(CreditWithholdingTaxName(), '1176');
        ContosoGLAccount.AddAccountForLocalization(RemainStAcctsReceivablesName(), '119.0');
        ContosoGLAccount.AddAccountForLocalization(WirCreditName(), '1190');
        ContosoGLAccount.AddAccountForLocalization(VendorPrepaymentsVat0PercentName(), '1192');
        ContosoGLAccount.AddAccountForLocalization(VendorPrepaymentsVat80PercentName(), '1193');
        ContosoGLAccount.AddAccountForLocalization(TotAcctsReceivablesName(), '1199');
        ContosoGLAccount.AddAccountForLocalization(InventoriesWipName(), '120');
        ContosoGLAccount.AddAccountForLocalization(InvCommercialGoodsName(), '1200');
        ContosoGLAccount.AddAccountForLocalization(InvCommercialGoodsInterimName(), '1201');
        ContosoGLAccount.AddAccountForLocalization(WbInvCommercialGoodsName(), '1209');
        ContosoGLAccount.AddAccountForLocalization(InvRawMaterialsName(), '1210');
        ContosoGLAccount.AddAccountForLocalization(InvRawMaterialsInterimName(), '1211');
        ContosoGLAccount.AddAccountForLocalization(WbInvRawMaterialsName(), '1219');
        ContosoGLAccount.AddAccountForLocalization(InvFinishedProductsName(), '1260');
        ContosoGLAccount.AddAccountForLocalization(InvFinProductsInterimName(), '1261');
        ContosoGLAccount.AddAccountForLocalization(WbInvFinishProductsName(), '1269');
        ContosoGLAccount.AddAccountForLocalization(StartedProjectsName(), '1280');
        ContosoGLAccount.AddAccountForLocalization(WbStartedProjectsName(), '1282');
        ContosoGLAccount.AddAccountForLocalization(StartedProductionOrdersName(), '1285');
        ContosoGLAccount.AddAccountForLocalization(TotalInventoriesWipName(), '1299');
        ContosoGLAccount.AddAccountForLocalization(AccruedIncomeName(), '130');
        ContosoGLAccount.AddAccountForLocalization(PrepaidExpensesName(), '1300');
        ContosoGLAccount.AddAccountForLocalization(EarningsNotYetReceivedName(), '1301');
        ContosoGLAccount.AddAccountForLocalization(TotalActiveDeferredItemsName(), '1398');
        ContosoGLAccount.AddAccountForLocalization(TotalCurrentAssetsName(), '1399');
        ContosoGLAccount.AddAccountForLocalization(FinancialAssetsName(), '140');
        ContosoGLAccount.AddAccountForLocalization(SecuritiesName(), '1400');
        ContosoGLAccount.AddAccountForLocalization(FaAccountName(), '1410');
        ContosoGLAccount.AddAccountForLocalization(InvestmentsName(), '1420');
        ContosoGLAccount.AddAccountForLocalization(LtAcctsReceivablesName(), '1440');
        ContosoGLAccount.AddAccountForLocalization(LoanShareholderName(), '1460');
        ContosoGLAccount.AddAccountForLocalization(TotalFinancialAssetsName(), '1499');
        ContosoGLAccount.AddAccountForLocalization(MobileFixedAssetsName(), '150');
        ContosoGLAccount.AddAccountForLocalization(MachinesAndEquipmentName(), '1500');
        ContosoGLAccount.AddAccountForLocalization(WbMachinesAndEquipmentName(), '1509');
        ContosoGLAccount.AddAccountForLocalization(BusinessFurnitureName(), '1510');
        ContosoGLAccount.AddAccountForLocalization(WbBusinessFurnitureName(), '1519');
        ContosoGLAccount.AddAccountForLocalization(OfficeMachinesName(), '1520');
        ContosoGLAccount.AddAccountForLocalization(ItHardwareAndSoftwareName(), '1521');
        ContosoGLAccount.AddAccountForLocalization(WbOfficeMachinesAndItName(), '1529');
        ContosoGLAccount.AddAccountForLocalization(WbVehiclesName(), '1539');
        ContosoGLAccount.AddAccountForLocalization(VehiclesEquipmentName(), '1540');
        ContosoGLAccount.AddAccountForLocalization(WbVehiclesEquipmentName(), '1549');
        ContosoGLAccount.AddAccountForLocalization(TotalMobileFixedAssetsName(), '1599');
        ContosoGLAccount.AddAccountForLocalization(RealPropertyFaName(), '160');
        ContosoGLAccount.AddAccountForLocalization(RealEstateName(), '1600');
        ContosoGLAccount.AddAccountForLocalization(WbRealEstateName(), '1609');
        ContosoGLAccount.AddAccountForLocalization(TotalRealPropertyFaName(), '1699');
        ContosoGLAccount.AddAccountForLocalization(IntangibleFaName(), '170');
        ContosoGLAccount.AddAccountForLocalization(PatentsKnowledgeRecipesName(), '1700');
        ContosoGLAccount.AddAccountForLocalization(BrandsPrototypesModelsPlansName(), '1710');
        ContosoGLAccount.AddAccountForLocalization(TotalIntangibleFaName(), '1798');
        ContosoGLAccount.AddAccountForLocalization(TotalFixedAssetsName(), '1799');
        ContosoGLAccount.AddAccountForLocalization(ActiveCorrectingEntriesName(), '18');
        ContosoGLAccount.AddAccountForLocalization(StartUpExpensesName(), '1800');
        ContosoGLAccount.AddAccountForLocalization(ExcludedCapitalStockName(), '1850');
        ContosoGLAccount.AddAccountForLocalization(TotalActCorrectingEntriesName(), '1899');
        ContosoGLAccount.AddAccountForLocalization(NonOperationalAssetsHeadingName(), '19');
        ContosoGLAccount.AddAccountForLocalization(NonOperationalAssetsName(), '1900');
        ContosoGLAccount.AddAccountForLocalization(TotalAssetsName(), '1999');
        ContosoGLAccount.AddAccountForLocalization(StLiabShipServName(), '200');
        ContosoGLAccount.AddAccountForLocalization(VendorsDomesticName(), '2000');
        ContosoGLAccount.AddAccountForLocalization(VendorsEuName(), '2001');
        ContosoGLAccount.AddAccountForLocalization(VendorsForeignName(), '2002');
        ContosoGLAccount.AddAccountForLocalization(VendorsIcName(), '2005');
        ContosoGLAccount.AddAccountForLocalization(CustomerPrepaymentsVat0PercentName(), '2030');
        ContosoGLAccount.AddAccountForLocalization(CustomerPrepaymentsVat80PercentName(), '2031');
        ContosoGLAccount.AddAccountForLocalization(BankOverdraftName(), '2100');
        ContosoGLAccount.AddAccountForLocalization(StLoanToShareholdersName(), '2160');
        ContosoGLAccount.AddAccountForLocalization(OtherShortTermLiabilitiesName(), '220');
        ContosoGLAccount.AddAccountForLocalization(VatOwedName(), '2200');
        ContosoGLAccount.AddAccountForLocalization(VendorVatName(), '2210');
        ContosoGLAccount.AddAccountForLocalization(DividendsDueName(), '2230');
        ContosoGLAccount.AddAccountForLocalization(LiabilitiesAccruedExpensesName(), '230');
        ContosoGLAccount.AddAccountForLocalization(UnpaidExpensesName(), '2300');
        ContosoGLAccount.AddAccountForLocalization(EarningsReceivedInAdvanceName(), '2301');
        ContosoGLAccount.AddAccountForLocalization(WarrantyReserveName(), '2330');
        ContosoGLAccount.AddAccountForLocalization(TaxationReserveName(), '2340');
        ContosoGLAccount.AddAccountForLocalization(TotalShortTermLiabilitiesName(), '2399');
        ContosoGLAccount.AddAccountForLocalization(LongTermLoansName(), '240');
        ContosoGLAccount.AddAccountForLocalization(BankLoansName(), '2400');
        ContosoGLAccount.AddAccountForLocalization(MortgageLoansName(), '2440');
        ContosoGLAccount.AddAccountForLocalization(LongTermReservesName(), '260');
        ContosoGLAccount.AddAccountForLocalization(LtReserveRepairsName(), '2600');
        ContosoGLAccount.AddAccountForLocalization(LongTermWarrantyWorkName(), '2630');
        ContosoGLAccount.AddAccountForLocalization(LtReserveDeferredTaxName(), '2640');
        ContosoGLAccount.AddAccountForLocalization(TotalLongTermLiabilitiesName(), '2798');
        ContosoGLAccount.AddAccountForLocalization(TotalLiabilitiesName(), '2799');
        ContosoGLAccount.AddAccountForLocalization(ShareholdersEquityName(), '28');
        ContosoGLAccount.AddAccountForLocalization(CapitalName(), '280');
        ContosoGLAccount.AddAccountForLocalization(ReservesAndRetainedEarningsName(), '290');
        ContosoGLAccount.AddAccountForLocalization(LegalReservesName(), '2900');
        ContosoGLAccount.AddAccountForLocalization(StatutoryReservesName(), '2910');
        ContosoGLAccount.AddAccountForLocalization(FreeReservesName(), '2915');
        ContosoGLAccount.AddAccountForLocalization(RetEarningsLossCarriedFwdName(), '2989');
        ContosoGLAccount.AddAccountForLocalization(RetainedEarningsLossName(), '2990');
        ContosoGLAccount.AddAccountForLocalization(AnnualEarningsLossName(), '2991');
        ContosoGLAccount.AddAccountForLocalization(EarnedCapitalName(), '2995');
        ContosoGLAccount.AddAccountForLocalization(TotalShareholdersEquityName(), '2996');
        ContosoGLAccount.AddAccountForLocalization(TotalLiabilitiesEndTotalName(), '2997');
        ContosoGLAccount.AddAccountForLocalization(GainLossLiabilitiesName(), '2998');
        ContosoGLAccount.AddAccountForLocalization(OpIncomeShipServName(), '3');
        ContosoGLAccount.AddAccountForLocalization(ProdEarningsName(), '30');
        ContosoGLAccount.AddAccountForLocalization(ProdEarningsDomesticName(), '3000');
        ContosoGLAccount.AddAccountForLocalization(ProdEarningsEuropeName(), '3002');
        ContosoGLAccount.AddAccountForLocalization(ProdEarningsInternatName(), '3004');
        ContosoGLAccount.AddAccountForLocalization(InvChangeFinishedProductsName(), '3080');
        ContosoGLAccount.AddAccountForLocalization(InvChgFinishedProdProvName(), '3081');
        ContosoGLAccount.AddAccountForLocalization(TradeEarningName(), '32');
        ContosoGLAccount.AddAccountForLocalization(TradeDomesticName(), '3200');
        ContosoGLAccount.AddAccountForLocalization(TradeEuropeName(), '3202');
        ContosoGLAccount.AddAccountForLocalization(TradeInternatName(), '3204');
        ContosoGLAccount.AddAccountForLocalization(InvChangeCommGoodsName(), '3280');
        ContosoGLAccount.AddAccountForLocalization(InvChangeTradeProvName(), '3281');
        ContosoGLAccount.AddAccountForLocalization(ServiceEarningsName(), '34');
        ContosoGLAccount.AddAccountForLocalization(ServiceEarningsDomesticName(), '3400');
        ContosoGLAccount.AddAccountForLocalization(ServiceEarningsEuropeName(), '3402');
        ContosoGLAccount.AddAccountForLocalization(ServiceEarningsInternatName(), '3404');
        ContosoGLAccount.AddAccountForLocalization(ProjectEarningsName(), '3420');
        ContosoGLAccount.AddAccountForLocalization(JobSalesAppliedAccountName(), '3421');
        ContosoGLAccount.AddAccountForLocalization(ConsultancyEarningsName(), '3430');
        ContosoGLAccount.AddAccountForLocalization(InventoryChangeReqWorkName(), '3480');
        ContosoGLAccount.AddAccountForLocalization(OtherEarningsHeadingName(), '36');
        ContosoGLAccount.AddAccountForLocalization(OtherEarningsName(), '3600');
        ContosoGLAccount.AddAccountForLocalization(OwnContributionOwnUseName(), '3700');
        ContosoGLAccount.AddAccountForLocalization(InventoryChangesName(), '3800');
        ContosoGLAccount.AddAccountForLocalization(DropInEarningsName(), '39');
        ContosoGLAccount.AddAccountForLocalization(CashDiscountsName(), '3900');
        ContosoGLAccount.AddAccountForLocalization(DiscountsName(), '3901');
        ContosoGLAccount.AddAccountForLocalization(LossFromAccountsRecName(), '3905');
        ContosoGLAccount.AddAccountForLocalization(UnrealizedExchRateAdjmtsName(), '3906');
        ContosoGLAccount.AddAccountForLocalization(RealizedExchangeRateAdjmtsName(), '3907');
        ContosoGLAccount.AddAccountForLocalization(RoundingDifferencesSalesName(), '3908');
        ContosoGLAccount.AddAccountForLocalization(TotalOpIncomeShipServName(), '3999');
        ContosoGLAccount.AddAccountForLocalization(CostGoodsMaterialDlName(), '4');
        ContosoGLAccount.AddAccountForLocalization(CostOfMaterialsName(), '40');
        ContosoGLAccount.AddAccountForLocalization(CostOfMaterialDomesticName(), '4000');
        ContosoGLAccount.AddAccountForLocalization(CostOfMaterialsEuropeName(), '4002');
        ContosoGLAccount.AddAccountForLocalization(CostOfMaterialsInternatName(), '4004');
        ContosoGLAccount.AddAccountForLocalization(VariancePurchMaterialsName(), '4050');
        ContosoGLAccount.AddAccountForLocalization(SubcontractingName(), '4060');
        ContosoGLAccount.AddAccountForLocalization(OverheadCostsMatProdName(), '4070');
        ContosoGLAccount.AddAccountForLocalization(CostOfCommercialGoodsName(), '42');
        ContosoGLAccount.AddAccountForLocalization(CostOfCommGoodsDomesticName(), '4200');
        ContosoGLAccount.AddAccountForLocalization(CostOfCommGoodsEuropeName(), '4202');
        ContosoGLAccount.AddAccountForLocalization(CostOfCommGoodsIntlName(), '4204');
        ContosoGLAccount.AddAccountForLocalization(VariancePurchTradeName(), '4250');
        ContosoGLAccount.AddAccountForLocalization(OverheadCostsCommGoodName(), '4270');
        ContosoGLAccount.AddAccountForLocalization(CostOfSubcontractsName(), '44');
        ContosoGLAccount.AddAccountForLocalization(SubcontrOfSpOperationsName(), '4400');
        ContosoGLAccount.AddAccountForLocalization(JobCostsWipName(), '4421');
        ContosoGLAccount.AddAccountForLocalization(OtherCostsName(), '45');
        ContosoGLAccount.AddAccountForLocalization(EnergyCostsCOGSName(), '4500');
        ContosoGLAccount.AddAccountForLocalization(PackagingCostsName(), '4650');
        ContosoGLAccount.AddAccountForLocalization(DirectPurchCostsName(), '4700');
        ContosoGLAccount.AddAccountForLocalization(InvChangeProductionMatName(), '4800');
        ContosoGLAccount.AddAccountForLocalization(InvChangeCommGoodsCOGSName(), '4820');
        ContosoGLAccount.AddAccountForLocalization(InvChangeProjectsName(), '4830');
        ContosoGLAccount.AddAccountForLocalization(MaterialLossName(), '4880');
        ContosoGLAccount.AddAccountForLocalization(GoodsLossName(), '4886');
        ContosoGLAccount.AddAccountForLocalization(MaterialVarianceProductionName(), '4890');
        ContosoGLAccount.AddAccountForLocalization(CapacityVarianceProductionName(), '4891');
        ContosoGLAccount.AddAccountForLocalization(VarianceMatOverheadCostsName(), '4892');
        ContosoGLAccount.AddAccountForLocalization(VarianceCapOverheadCostsName(), '4893');
        ContosoGLAccount.AddAccountForLocalization(VarianceSubcontractingName(), '4894');
        ContosoGLAccount.AddAccountForLocalization(CostReductionsName(), '49');
        ContosoGLAccount.AddAccountForLocalization(PurchaseDiscName(), '4900');
        ContosoGLAccount.AddAccountForLocalization(CostReductionDiscountName(), '4901');
        ContosoGLAccount.AddAccountForLocalization(UnrealExchangeRateAdjmtsName(), '4906');
        ContosoGLAccount.AddAccountForLocalization(RealizedExchangeRateAdjmtsCOGSName(), '4907');
        ContosoGLAccount.AddAccountForLocalization(RoundingDifferencesPurchaseName(), '4908');
        ContosoGLAccount.AddAccountForLocalization(TotalCostsGoodsMatDlName(), '4999');
        ContosoGLAccount.AddAccountForLocalization(PersonnelCostsName(), '5');
        ContosoGLAccount.AddAccountForLocalization(WagesProductionName(), '5000');
        ContosoGLAccount.AddAccountForLocalization(WagesSalesName(), '5200');
        ContosoGLAccount.AddAccountForLocalization(WagesManagementName(), '5600');
        ContosoGLAccount.AddAccountForLocalization(AhvIvEoAlvName(), '5700');
        ContosoGLAccount.AddAccountForLocalization(PensionPlanningName(), '5720');
        ContosoGLAccount.AddAccountForLocalization(CasualtyInsuranceName(), '5730');
        ContosoGLAccount.AddAccountForLocalization(HealthInsuranceName(), '5740');
        ContosoGLAccount.AddAccountForLocalization(IncomeTaxName(), '5790');
        ContosoGLAccount.AddAccountForLocalization(TrngAndContinuingEdName(), '5810');
        ContosoGLAccount.AddAccountForLocalization(ReimbursementOfExpensesName(), '5820');
        ContosoGLAccount.AddAccountForLocalization(OtherPersonnelCostsName(), '5830');
        ContosoGLAccount.AddAccountForLocalization(TotalPersonnelCostsName(), '5999');
        ContosoGLAccount.AddAccountForLocalization(PremisesCostsName(), '60');
        ContosoGLAccount.AddAccountForLocalization(RentName(), '6000');
        ContosoGLAccount.AddAccountForLocalization(RentalValueForUsedPropertyName(), '6010');
        ContosoGLAccount.AddAccountForLocalization(AddCostsName(), '6030');
        ContosoGLAccount.AddAccountForLocalization(MaintOfBusinessPremisesName(), '6050');
        ContosoGLAccount.AddAccountForLocalization(TotalPremisesCostsName(), '6099');
        ContosoGLAccount.AddAccountForLocalization(MaintRepairsName(), '61');
        ContosoGLAccount.AddAccountForLocalization(MaintProductionPlantsName(), '6100');
        ContosoGLAccount.AddAccountForLocalization(MaintSalesEquipmentName(), '6110');
        ContosoGLAccount.AddAccountForLocalization(MaintStorageFacilitiesName(), '6120');
        ContosoGLAccount.AddAccountForLocalization(MaintOfficeEquipmentName(), '6130');
        ContosoGLAccount.AddAccountForLocalization(LeasingMobileFixedAssetsName(), '6160');
        ContosoGLAccount.AddAccountForLocalization(TotalMaintRepairsName(), '6199');
        ContosoGLAccount.AddAccountForLocalization(VehicleAndTransportCostsName(), '62');
        ContosoGLAccount.AddAccountForLocalization(VehicleMaintName(), '6200');
        ContosoGLAccount.AddAccountForLocalization(OpMaterialsName(), '6210');
        ContosoGLAccount.AddAccountForLocalization(AutoInsuranceName(), '6220');
        ContosoGLAccount.AddAccountForLocalization(TransportTaxRatesName(), '6230');
        ContosoGLAccount.AddAccountForLocalization(TransportCostsName(), '6280');
        ContosoGLAccount.AddAccountForLocalization(ShippingChargeCustomerName(), '6290');
        ContosoGLAccount.AddAccountForLocalization(TotalVehicleAndTransportName(), '6299');
        ContosoGLAccount.AddAccountForLocalization(PropertyInsuranceRatesName(), '63');
        ContosoGLAccount.AddAccountForLocalization(PropertyInsuranceName(), '6300');
        ContosoGLAccount.AddAccountForLocalization(OperatingLiabilityName(), '6310');
        ContosoGLAccount.AddAccountForLocalization(DowntimeInsuranceName(), '6320');
        ContosoGLAccount.AddAccountForLocalization(TaxRatesName(), '6360');
        ContosoGLAccount.AddAccountForLocalization(PermitsPatentsName(), '6370');
        ContosoGLAccount.AddAccountForLocalization(TotalInsuranceFeesName(), '6399');
        ContosoGLAccount.AddAccountForLocalization(EnergyWasteCostsName(), '64');
        ContosoGLAccount.AddAccountForLocalization(EnergyCostsName(), '6400');
        ContosoGLAccount.AddAccountForLocalization(WasteCostsName(), '6460');
        ContosoGLAccount.AddAccountForLocalization(TotalEnergyWasteName(), '6499');
        ContosoGLAccount.AddAccountForLocalization(ManagementInformationCostsName(), '65');
        ContosoGLAccount.AddAccountForLocalization(AdministrativeCostsName(), '650');
        ContosoGLAccount.AddAccountForLocalization(OfficeMatPrintSuppliesName(), '6500');
        ContosoGLAccount.AddAccountForLocalization(TechDocName(), '6503');
        ContosoGLAccount.AddAccountForLocalization(CommunicationTelephoneName(), '6510');
        ContosoGLAccount.AddAccountForLocalization(DeductionsName(), '6520');
        ContosoGLAccount.AddAccountForLocalization(AccountingConsultancyName(), '6530');
        ContosoGLAccount.AddAccountForLocalization(BoardOfDirectorsGvRevisionName(), '6540');
        ContosoGLAccount.AddAccountForLocalization(InformationCostsName(), '656');
        ContosoGLAccount.AddAccountForLocalization(ItLeasingName(), '6560');
        ContosoGLAccount.AddAccountForLocalization(ItProgramLicensesMaintName(), '6570');
        ContosoGLAccount.AddAccountForLocalization(ItSuppliesName(), '6573');
        ContosoGLAccount.AddAccountForLocalization(ConsultingAndDevelopmentName(), '6580');
        ContosoGLAccount.AddAccountForLocalization(TotalAdministrationItName(), '6599');
        ContosoGLAccount.AddAccountForLocalization(AdvertisingCostsName(), '66');
        ContosoGLAccount.AddAccountForLocalization(AdvertisementsAndMediaName(), '6600');
        ContosoGLAccount.AddAccountForLocalization(AdMaterialsName(), '6610');
        ContosoGLAccount.AddAccountForLocalization(ExhibitsName(), '6620');
        ContosoGLAccount.AddAccountForLocalization(TravelCostsCustomerServiceName(), '6640');
        ContosoGLAccount.AddAccountForLocalization(AdvertContribSponsoringName(), '6660');
        ContosoGLAccount.AddAccountForLocalization(PublicRelationsPrName(), '6670');
        ContosoGLAccount.AddAccountForLocalization(AdConsultancyMarketAnalyName(), '6680');
        ContosoGLAccount.AddAccountForLocalization(TotalAdvertisingCostsName(), '6699');
        ContosoGLAccount.AddAccountForLocalization(OtherOpExpensesName(), '67');
        ContosoGLAccount.AddAccountForLocalization(EconomicInformationName(), '6700');
        ContosoGLAccount.AddAccountForLocalization(OperReliabilityMonitoringName(), '6710');
        ContosoGLAccount.AddAccountForLocalization(ResearchAndDevelopmentName(), '6720');
        ContosoGLAccount.AddAccountForLocalization(MiscCostsName(), '6780');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherOperatingExpensesName(), '6799');
        ContosoGLAccount.AddAccountForLocalization(FinancialIncomeName(), '68');
        ContosoGLAccount.AddAccountForLocalization(FinancialExpensesName(), '680');
        ContosoGLAccount.AddAccountForLocalization(BankInterestRateCostsName(), '6800');
        ContosoGLAccount.AddAccountForLocalization(MortgageIntRateCostsName(), '6802');
        ContosoGLAccount.AddAccountForLocalization(BankAndPcCostsName(), '6840');
        ContosoGLAccount.AddAccountForLocalization(FinancialProfitName(), '685');
        ContosoGLAccount.AddAccountForLocalization(InterestReceiptBankPostName(), '6850');
        ContosoGLAccount.AddAccountForLocalization(IntReceivedFinAssetsName(), '6860');
        ContosoGLAccount.AddAccountForLocalization(FinChargesRecName(), '6890');
        ContosoGLAccount.AddAccountForLocalization(TotalFinIncomeName(), '6899');
        ContosoGLAccount.AddAccountForLocalization(DepreciationName(), '69');
        ContosoGLAccount.AddAccountForLocalization(DepFinAssetsName(), '6900');
        ContosoGLAccount.AddAccountForLocalization(DepInvestmentName(), '6910');
        ContosoGLAccount.AddAccountForLocalization(DepMobileFixedAssetsName(), '6920');
        ContosoGLAccount.AddAccountForLocalization(DepCommercialPropertyName(), '6930');
        ContosoGLAccount.AddAccountForLocalization(DepIntangibleFixedAssetsName(), '6940');
        ContosoGLAccount.AddAccountForLocalization(DepStartUpExpensesName(), '6950');
        ContosoGLAccount.AddAccountForLocalization(TotalDepreciationsName(), '6998');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherOperatingExpensesEndTotalName(), '6999');
        ContosoGLAccount.AddAccountForLocalization(OtherOperatingIncomeName(), '7');
        ContosoGLAccount.AddAccountForLocalization(SubsidiaryIncomeName(), '7000');
        ContosoGLAccount.AddAccountForLocalization(SubsidiaryExpensesName(), '7010');
        ContosoGLAccount.AddAccountForLocalization(IncomeFromFinAssetsName(), '7400');
        ContosoGLAccount.AddAccountForLocalization(ExpensesFromFinAssetsName(), '7410');
        ContosoGLAccount.AddAccountForLocalization(PropertyIncomeName(), '7500');
        ContosoGLAccount.AddAccountForLocalization(PropertyExpensesName(), '7510');
        ContosoGLAccount.AddAccountForLocalization(GainFromSaleOfFixedAssetsName(), '7900');
        ContosoGLAccount.AddAccountForLocalization(GainLossFromSaleOfAssetsName(), '7910');
        ContosoGLAccount.AddAccountForLocalization(TotalOtherOperatingIncomeName(), '7999');
        ContosoGLAccount.AddAccountForLocalization(NRNonOperatingTaxName(), '8');
        ContosoGLAccount.AddAccountForLocalization(NonRegularIncomeName(), '8000');
        ContosoGLAccount.AddAccountForLocalization(NonRegularExpensesName(), '8010');
        ContosoGLAccount.AddAccountForLocalization(NonOperatingIncomeName(), '8200');
        ContosoGLAccount.AddAccountForLocalization(NonOperatingExpensesName(), '8210');
        ContosoGLAccount.AddAccountForLocalization(GainCapitalTaxName(), '8900');
        ContosoGLAccount.AddAccountForLocalization(TotalNRNOTaxName(), '8998');
        ContosoGLAccount.AddAccountForLocalization(GainLossIncomeName(), '8999');
        ContosoGLAccount.AddAccountForLocalization(ClosingName(), '9');
        ContosoGLAccount.AddAccountForLocalization(IncomeStatementName(), '9000');
        ContosoGLAccount.AddAccountForLocalization(OpeningBalanceName(), '9100');

        CreateGLAccountForLocalization();
    end;

    local procedure CreateGLAccountForLocalization()
    var
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Assets(), CreateGLAccount.AssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CurrentAssets(), CreateGLAccount.CurrentAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LongtermLiabilities(), CreateGLAccount.LongtermLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherOperatingExpenses(), CreateGLAccount.OtherOperatingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Vehicles(), CreateGLAccount.VehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CapitalStock(), CreateGLAccount.CapitalStockName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCosts(), CreateGLAccount.JobCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Cleaning(), CreateGLAccount.CleaningName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Postage(), CreateGLAccount.PostageName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting,  CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(),  '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PostAcc(), PostAccName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(BankCredit(), BankCreditName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(BankCreditForeignCurrency(), BankCreditForeignCurrencyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(BankCreditEur(), BankCreditEurName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(BankCreditUsd(), BankCreditUsdName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(BankCreditDkk(), BankCreditDkkName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(FixedTermDepInv(), FixedTermDepInvName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(MoneyTransAccount(), MoneyTransAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(TotalLiquidAssets(), TotalLiquidAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LiquidAssets() + '..' + TotalLiquidAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AcctsReceivable(), AcctsReceivableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ArsFromShipAndServices(), ArsFromShipAndServicesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CustomerCreditDomestic(), CustomerCreditDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CustomerCreditEu(), CustomerCreditEuName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CustomerCreditForeign(), CustomerCreditForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CustomerCreditIc(), CustomerCreditIcName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AcctsRecWithShareholders(), AcctsRecWithShareholdersName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherStAcctsReceivables(), OtherStAcctsReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(StAcctsReceivables(), StAcctsReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(StLoanShareholder(), StLoanShareholderName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AcctsReceivablesOnGovLoc(), AcctsReceivablesOnGovLocName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchVatMatDl(), PurchVatMatDlName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchVatInvOperatingExp(), PurchVatInvOperatingExpName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchVatOnImports100Percent(), PurchVatOnImports100PercentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreditWithholdingTax(), CreditWithholdingTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RemainStAcctsReceivables(), RemainStAcctsReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WirCredit(), WirCreditName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VendorPrepaymentsVat0Percent(), VendorPrepaymentsVat0PercentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VendorPrepaymentsVat80Percent(), VendorPrepaymentsVat80PercentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotAcctsReceivables(), TotAcctsReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, AcctsReceivable() + '..' + TotAcctsReceivables(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InventoriesWip(), InventoriesWipName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InvCommercialGoods(), InvCommercialGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InvCommercialGoodsInterim(), InvCommercialGoodsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WbInvCommercialGoods(), WbInvCommercialGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InvRawMaterials(), InvRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InvRawMaterialsInterim(), InvRawMaterialsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WbInvRawMaterials(), WbInvRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InvFinishedProducts(), InvFinishedProductsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InvFinProductsInterim(), InvFinProductsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WbInvFinishProducts(), WbInvFinishProductsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(StartedProjects(), StartedProjectsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WbStartedProjects(), WbStartedProjectsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(StartedProductionOrders(), StartedProductionOrdersName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalInventoriesWip(), TotalInventoriesWipName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, InventoriesWip() + '..' + TotalInventoriesWip(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedIncome(), AccruedIncomeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Heading", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PrepaidExpenses(), PrepaidExpensesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EarningsNotYetReceived(), EarningsNotYetReceivedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalActiveDeferredItems(), TotalActiveDeferredItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCurrentAssets(), TotalCurrentAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.CurrentAssets() + '..' + TotalCurrentAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FinancialAssets(), FinancialAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Securities(), SecuritiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FaAccount(), FaAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Investments(), InvestmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LtAcctsReceivables(), LtAcctsReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LoanShareholder(), LoanShareholderName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFinancialAssets(), TotalFinancialAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, FinancialAssets() + '..' + TotalFinancialAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MobileFixedAssets(), MobileFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MachinesAndEquipment(), MachinesAndEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WbMachinesAndEquipment(), WbMachinesAndEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BusinessFurniture(), BusinessFurnitureName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WbBusinessFurniture(), WbBusinessFurnitureName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OfficeMachines(), OfficeMachinesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ItHardwareAndSoftware(), ItHardwareAndSoftwareName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WbOfficeMachinesAndIt(), WbOfficeMachinesAndItName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WbVehicles(), WbVehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VehiclesEquipment(), VehiclesEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WbVehiclesEquipment(), WbVehiclesEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalMobileFixedAssets(), TotalMobileFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, MobileFixedAssets() + '..' + TotalMobileFixedAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RealPropertyFa(), RealPropertyFaName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RealEstate(), RealEstateName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WbRealEstate(), WbRealEstateName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRealPropertyFa(), TotalRealPropertyFaName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, RealPropertyFa() + '..' + TotalRealPropertyFa(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IntangibleFa(), IntangibleFaName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PatentsKnowledgeRecipes(), PatentsKnowledgeRecipesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BrandsPrototypesModelsPlans(), BrandsPrototypesModelsPlansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalIntangibleFa(), TotalIntangibleFaName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, IntangibleFa() + '..' + TotalIntangibleFa(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFixedAssets(), TotalFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 1, CreateGLAccount.FixedAssets() + '..' + TotalFixedAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ActiveCorrectingEntries(), ActiveCorrectingEntriesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(StartUpExpenses(), StartUpExpensesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ExcludedCapitalStock(), ExcludedCapitalStockName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalActCorrectingEntries(), TotalActCorrectingEntriesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, ActiveCorrectingEntries() + '..' + TotalActCorrectingEntries(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(NonOperationalAssetsHeading(), NonOperationalAssetsHeadingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Heading", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(NonOperationalAssets(), NonOperationalAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAssets(), TotalAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.ASSETS() + '..' + TotalAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(StLiabShipServ(), StLiabShipServName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VendorsDomestic(), VendorsDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VendorsEu(), VendorsEuName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VendorsForeign(), VendorsForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VendorsIc(), VendorsIcName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CustomerPrepaymentsVat0Percent(), CustomerPrepaymentsVat0PercentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CustomerPrepaymentsVat80Percent(), CustomerPrepaymentsVat80PercentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BankOverdraft(), BankOverdraftName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(StLoanToShareholders(), StLoanToShareholdersName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherShortTermLiabilities(), OtherShortTermLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VatOwed(), VatOwedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VendorVat(), VendorVatName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DividendsDue(), DividendsDueName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LiabilitiesAccruedExpenses(), LiabilitiesAccruedExpensesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(UnpaidExpenses(), UnpaidExpensesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EarningsReceivedInAdvance(), EarningsReceivedInAdvanceName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WarrantyReserve(), WarrantyReserveName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxationReserve(), TaxationReserveName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalShortTermLiabilities(), TotalShortTermLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.ShorttermLiabilities() + '..' + TotalShortTermLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LongTermLoans(), LongTermLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BankLoans(), BankLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MortgageLoans(), MortgageLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LongTermReserves(), LongTermReservesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LtReserveRepairs(), LtReserveRepairsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LongTermWarrantyWork(), LongTermWarrantyWorkName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LtReserveDeferredTax(), LtReserveDeferredTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalLongTermLiabilities(), TotalLongTermLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LongtermLiabilities() + '..' + TotalLongTermLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalLiabilities(), TotalLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Total", '', '', 1, VendorsDomestic() + '..' + TotalLongTermLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ShareholdersEquity(), ShareholdersEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Capital(), CapitalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ReservesAndRetainedEarnings(), ReservesAndRetainedEarningsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LegalReserves(), LegalReservesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(StatutoryReserves(), StatutoryReservesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FreeReserves(), FreeReservesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RetEarningsLossCarriedFwd(), RetEarningsLossCarriedFwdName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RetainedEarningsLoss(), RetainedEarningsLossName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AnnualEarningsLoss(), AnnualEarningsLossName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EarnedCapital(), EarnedCapitalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Total", '', '', 0, LegalReserves() + '..' + AnnualEarningsLoss(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalShareholdersEquity(), TotalShareholdersEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"End-Total", '', '', 0, ShareholdersEquity() + '..' + TotalShareholdersEquity(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalLiabilitiesEndTotal(), TotalLiabilitiesEndTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 1, CreateGLAccount.Liabilities() + '..' + TotalLiabilitiesEndTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GainLossLiabilities(), GainLossLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Total", '', '', 1, CreateGLAccount.Cash() + '..' + TotalLiabilitiesEndTotal(), Enum::"General Posting Type"::" ", '', '', false, false, true);
        ContosoGLAccount.InsertGLAccount(OpIncomeShipServ(), OpIncomeShipServName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ProdEarnings(), ProdEarningsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ProdEarningsDomestic(), ProdEarningsDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProdEarningsEurope(), ProdEarningsEuropeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProdEarningsInternat(), ProdEarningsInternatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InvChangeFinishedProducts(), InvChangeFinishedProductsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InvChgFinishedProdProv(), InvChgFinishedProdProvName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TradeEarning(), TradeEarningName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TradeDomestic(), TradeDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TradeEurope(), TradeEuropeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TradeInternat(), TradeInternatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InvChangeCommGoods(), InvChangeCommGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InvChangeTradeProv(), InvChangeTradeProvName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ServiceEarnings(), ServiceEarningsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ServiceEarningsDomestic(), ServiceEarningsDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ServiceEarningsEurope(), ServiceEarningsEuropeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ServiceEarningsInternat(), ServiceEarningsInternatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Export(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProjectEarnings(), ProjectEarningsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(JobSalesAppliedAccount(), JobSalesAppliedAccountName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConsultancyEarnings(), ConsultancyEarningsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InventoryChangeReqWork(), InventoryChangeReqWorkName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherEarningsHeading(), OtherEarningsHeadingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherEarnings(), OtherEarningsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OwnContributionOwnUse(), OwnContributionOwnUseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InventoryChanges(), InventoryChangesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DropInEarnings(), DropInEarningsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CashDiscounts(), CashDiscountsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Discounts(), DiscountsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LossFromAccountsRec(), LossFromAccountsRecName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(UnrealizedExchRateAdjmts(), UnrealizedExchRateAdjmtsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RealizedExchangeRateAdjmts(), RealizedExchangeRateAdjmtsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RoundingDifferencesSales(), RoundingDifferencesSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOpIncomeShipServ(), TotalOpIncomeShipServName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, OpIncomeShipServ() + '..' + TotalOpIncomeShipServ(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostGoodsMaterialDl(), CostGoodsMaterialDlName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfMaterials(), CostOfMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfMaterialDomestic(), CostOfMaterialDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfMaterialsEurope(), CostOfMaterialsEuropeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Export(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfMaterialsInternat(), CostOfMaterialsInternatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Export(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VariancePurchMaterials(), VariancePurchMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Subcontracting(), SubcontractingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OverheadCostsMatProd(), OverheadCostsMatProdName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfCommercialGoods(), CostOfCommercialGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfCommGoodsDomestic(), CostOfCommGoodsDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfCommGoodsEurope(), CostOfCommGoodsEuropeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Export(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfCommGoodsIntl(), CostOfCommGoodsIntlName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Export(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VariancePurchTrade(), VariancePurchTradeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OverheadCostsCommGood(), OverheadCostsCommGoodName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostOfSubcontracts(), CostOfSubcontractsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SubcontrOfSpOperations(), SubcontrOfSpOperationsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(JobCostsWip(), JobCostsWipName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherCosts(), OtherCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EnergyCostsCOGS(), EnergyCostsCOGSName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PackagingCosts(), PackagingCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DirectPurchCosts(), DirectPurchCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InvChangeProductionMat(), InvChangeProductionMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InvChangeCommGoodsCOGS(), InvChangeCommGoodsCOGSName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InvChangeProjects(), InvChangeProjectsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MaterialLoss(), MaterialLossName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GoodsLoss(), GoodsLossName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MaterialVarianceProduction(), MaterialVarianceProductionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CapacityVarianceProduction(), CapacityVarianceProductionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VarianceMatOverheadCosts(), VarianceMatOverheadCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VarianceCapOverheadCosts(), VarianceCapOverheadCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VarianceSubcontracting(), VarianceSubcontractingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostReductions(), CostReductionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseDisc(), PurchaseDiscName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostReductionDiscount(), CostReductionDiscountName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(UnrealExchangeRateAdjmts(), UnrealExchangeRateAdjmtsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RealizedExchangeRateAdjmtsCOGS(), RealizedExchangeRateAdjmtsCOGSName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RoundingDifferencesPurchase(), RoundingDifferencesPurchaseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostsGoodsMatDl(), TotalCostsGoodsMatDlName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CostGoodsMaterialDl() + '..' + TotalCostsGoodsMatDl(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PersonnelCosts(), PersonnelCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WagesProduction(), WagesProductionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WagesSales(), WagesSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WagesManagement(), WagesManagementName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AhvIvEoAlv(), AhvIvEoAlvName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PensionPlanning(), PensionPlanningName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CasualtyInsurance(), CasualtyInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HealthInsurance(), HealthInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeTax(), IncomeTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TrngAndContinuingEd(), TrngAndContinuingEdName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ReimbursementOfExpenses(), ReimbursementOfExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherPersonnelCosts(), OtherPersonnelCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPersonnelCosts(), TotalPersonnelCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, PersonnelCosts() + '..' + TotalPersonnelCosts(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PremisesCosts(), PremisesCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Rent(), RentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RentalValueForUsedProperty(), RentalValueForUsedPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AddCosts(), AddCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MaintOfBusinessPremises(), MaintOfBusinessPremisesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPremisesCosts(), TotalPremisesCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, PremisesCosts() + '..' + TotalPremisesCosts(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MaintRepairs(), MaintRepairsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(MaintProductionPlants(), MaintProductionPlantsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MaintSalesEquipment(), MaintSalesEquipmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MaintStorageFacilities(), MaintStorageFacilitiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MaintOfficeEquipment(), MaintOfficeEquipmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LeasingMobileFixedAssets(), LeasingMobileFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalMaintRepairs(), TotalMaintRepairsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, MaintRepairs() + '..' + TotalMaintRepairs(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VehicleAndTransportCosts(), VehicleAndTransportCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VehicleMaint(), VehicleMaintName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OpMaterials(), OpMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AutoInsurance(), AutoInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TransportTaxRates(), TransportTaxRatesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TransportCosts(), TransportCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ShippingChargeCustomer(), ShippingChargeCustomerName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalVehicleAndTransport(), TotalVehicleAndTransportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, VehicleAndTransportCosts() + '..' + TotalVehicleAndTransport(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PropertyInsuranceRates(), PropertyInsuranceRatesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PropertyInsurance(), PropertyInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OperatingLiability(), OperatingLiabilityName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DowntimeInsurance(), DowntimeInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxRates(), TaxRatesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PermitsPatents(), PermitsPatentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalInsuranceFees(), TotalInsuranceFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, PropertyInsuranceRates() + '..' + TotalInsuranceFees(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EnergyWasteCosts(), EnergyWasteCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EnergyCosts(), EnergyCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WasteCosts(), WasteCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalEnergyWaste(), TotalEnergyWasteName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, EnergyWasteCosts() + '..' + TotalEnergyWaste(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ManagementInformationCosts(), ManagementInformationCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AdministrativeCosts(), AdministrativeCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Heading", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OfficeMatPrintSupplies(), OfficeMatPrintSuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TechDoc(), TechDocName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CommunicationTelephone(), CommunicationTelephoneName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Deductions(), DeductionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccountingConsultancy(), AccountingConsultancyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BoardOfDirectorsGvRevision(), BoardOfDirectorsGvRevisionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InformationCosts(), InformationCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Heading", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ItLeasing(), ItLeasingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ItProgramLicensesMaint(), ItProgramLicensesMaintName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ItSupplies(), ItSuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConsultingAndDevelopment(), ConsultingAndDevelopmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAdministrationIt(), TotalAdministrationItName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, ManagementInformationCosts() + '..' + TotalAdministrationIt(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AdvertisingCosts(), AdvertisingCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AdvertisementsAndMedia(), AdvertisementsAndMediaName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdMaterials(), AdMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Exhibits(), ExhibitsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TravelCostsCustomerService(), TravelCostsCustomerServiceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdvertContribSponsoring(), AdvertContribSponsoringName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PublicRelationsPr(), PublicRelationsPrName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdConsultancyMarketAnaly(), AdConsultancyMarketAnalyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAdvertisingCosts(), TotalAdvertisingCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, AdvertisingCosts() + '..' + TotalAdvertisingCosts(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherOpExpenses(), OtherOpExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EconomicInformation(), EconomicInformationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OperReliabilityMonitoring(), OperReliabilityMonitoringName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ResearchAndDevelopment(), ResearchAndDevelopmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MiscCosts(), MiscCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", CreateVATPostingGroups.Domestic(), '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherOperatingExpenses(), TotalOtherOperatingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherOpExpenses() + '..' + TotalOtherOperatingExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FinancialIncome(), FinancialIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FinancialExpenses(), FinancialExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BankInterestRateCosts(), BankInterestRateCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MortgageIntRateCosts(), MortgageIntRateCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BankAndPcCosts(), BankAndPcCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FinancialProfit(), FinancialProfitName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Heading", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InterestReceiptBankPost(), InterestReceiptBankPostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IntReceivedFinAssets(), IntReceivedFinAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FinChargesRec(), FinChargesRecName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFinIncome(), TotalFinIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, FinancialIncome() + '..' + TotalFinIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciation(), DepreciationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DepFinAssets(), DepFinAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepInvestment(), DepInvestmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepMobileFixedAssets(), DepMobileFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepCommercialProperty(), DepCommercialPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepIntangibleFixedAssets(), DepIntangibleFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepStartUpExpenses(), DepStartUpExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalDepreciations(), TotalDepreciationsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Depreciation() + '..' + TotalDepreciations(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherOperatingExpensesEndTotal(), TotalOtherOperatingExpensesEndTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 1, CreateGLAccount.OtherOperatingExpenses() + '..' + TotalOtherOperatingExpensesEndTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherOperatingIncome(), OtherOperatingIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SubsidiaryIncome(), SubsidiaryIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SubsidiaryExpenses(), SubsidiaryExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeFromFinAssets(), IncomeFromFinAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ExpensesFromFinAssets(), ExpensesFromFinAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PropertyIncome(), PropertyIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PropertyExpenses(), PropertyExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GainFromSaleOfFixedAssets(), GainFromSaleOfFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GainLossFromSaleOfAssets(), GainLossFromSaleOfAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalOtherOperatingIncome(), TotalOtherOperatingIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherOperatingIncome() + '..' + TotalOtherOperatingIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(NRNonOperatingTax(), NRNonOperatingTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(NonRegularIncome(), NonRegularIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(NonRegularExpenses(), NonRegularExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(NonOperatingIncome(), NonOperatingIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(NonOperatingExpenses(), NonOperatingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GainCapitalTax(), GainCapitalTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalNRNOTax(), TotalNRNOTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, NRNonOperatingTax() + '..' + TotalNRNOTax(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GainLossIncome(), GainLossIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Total", '', '', 1, ProdEarningsDomestic() + '..' + TotalNRNOTax(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Closing(), ClosingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeStatement(), IncomeStatementName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OpeningBalance(), OpeningBalanceName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::"Posting", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
    end;

    procedure AddCategoriesToGLAccounts()
    var
        GLAccountCategory: Record "G/L Account Category";
    begin
        if GLAccountCategory.IsEmpty() then
            exit;

        GLAccountCategory.SetRange("Parent Entry No.", 0);
        if GLAccountCategory.FindSet() then
            repeat
                AssignCategoryToChartOfAccounts(GLAccountCategory);
            until GLAccountCategory.Next() = 0;

        GLAccountCategory.SetFilter("Parent Entry No.", '<>%1', 0);
        if GLAccountCategory.FindSet() then
            repeat
                AssignSubcategoryToChartOfAccounts(GLAccountCategory);
            until GLAccountCategory.Next() = 0;
    end;

    local procedure AssignCategoryToChartOfAccounts(GLAccountCategory: Record "G/L Account Category")
    var
    //CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case GLAccountCategory."Account Category" of
            GLAccountCategory."Account Category"::Assets:
                UpdateGLAccounts(GLAccountCategory, '1', '1999');
            GLAccountCategory."Account Category"::Liabilities:
                begin
                    UpdateGLAccounts(GLAccountCategory, '2', '2799');
                    UpdateGLAccounts(GLAccountCategory, '2997', '2998');
                end;
            GLAccountCategory."Account Category"::Equity:
                UpdateGLAccounts(GLAccountCategory, '28', '2996');
            GLAccountCategory."Account Category"::Income:
                begin
                    UpdateGLAccounts(GLAccountCategory, '2999', '3480');
                    UpdateGLAccounts(GLAccountCategory, '39', '3999');
                    UpdateGLAccounts(GLAccountCategory, '68', '6899');
                    UpdateGLAccounts(GLAccountCategory, '7900', '8000');
                    UpdateGLAccounts(GLAccountCategory, '8210', '8210');
                    UpdateGLAccounts(GLAccountCategory, '8998', '9');
                end;
            GLAccountCategory."Account Category"::"Cost of Goods Sold":
                UpdateGLAccounts(GLAccountCategory, '4', '4999');
            GLAccountCategory."Account Category"::Expense:
                begin
                    UpdateGLAccounts(GLAccountCategory, '36', '3800');
                    UpdateGLAccounts(GLAccountCategory, '5', '6799');
                    UpdateGLAccounts(GLAccountCategory, '69', '7510');
                    UpdateGLAccounts(GLAccountCategory, '8010', '8200');
                    UpdateGLAccounts(GLAccountCategory, '8900', '8900');
                end;
        end;
    end;

    local procedure AssignSubcategoryToChartOfAccounts(GLAccountCategory: Record "G/L Account Category")
    var
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
    // CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case GLAccountCategory.Description of
            GLAccountCategoryMgt.GetCurrentAssets():
                begin
                    UpdateGLAccounts(GLAccountCategory, '10', '10');
                    UpdateGLAccounts(GLAccountCategory, '1399', '1399');
                end;
            GLAccountCategoryMgt.GetCash():
                UpdateGLAccounts(GLAccountCategory, '100', '1099');
            GLAccountCategoryMgt.GetAR():
                UpdateGLAccounts(GLAccountCategory, '110', '1199');
            GLAccountCategoryMgt.GetPrepaidExpenses():
                UpdateGLAccounts(GLAccountCategory, '130', '1398');
            GLAccountCategoryMgt.GetInventory():
                UpdateGLAccounts(GLAccountCategory, '120', '1299');
            GLAccountCategoryMgt.GetCurrentLiabilities():
                begin
                    UpdateGLAccounts(GLAccountCategory, '1798', '1798');
                    UpdateGLAccounts(GLAccountCategory, '20', '2399');
                end;
            GLAccountCategoryMgt.GetLongTermLiabilities():
                UpdateGLAccounts(GLAccountCategory, '24', '2799');
            GLAccountCategoryMgt.GetIncomeService():
                UpdateGLAccounts(GLAccountCategory, '34', '3480');
            GLAccountCategoryMgt.GetIncomeProdSales():
                UpdateGLAccounts(GLAccountCategory, '2999', '3281');
            GLAccountCategoryMgt.GetIncomeSalesDiscounts():
                UpdateGLAccounts(GLAccountCategory, '39', '3999');
            GLAccountCategoryMgt.GetIncomeInterest():
                UpdateGLAccounts(GLAccountCategory, '68', '6899');
            GLAccountCategoryMgt.GetCOGSMaterials():
                begin
                    UpdateGLAccounts(GLAccountCategory, '4', '4270');
                    UpdateGLAccounts(GLAccountCategory, '49', '4999');
                end;
            GLAccountCategoryMgt.GetJobsCost():
                UpdateGLAccounts(GLAccountCategory, '44', '4894');
            GLAccountCategoryMgt.GetRentExpense():
                UpdateGLAccounts(GLAccountCategory, '6000', '6010');
            GLAccountCategoryMgt.GetAdvertisingExpense():
                UpdateGLAccounts(GLAccountCategory, '66', '6699');
            GLAccountCategoryMgt.GetPayrollExpense():
                UpdateGLAccounts(GLAccountCategory, '5', '5999');
            GLAccountCategoryMgt.GetRepairsExpense():
                begin
                    UpdateGLAccounts(GLAccountCategory, '6050', '6050');
                    UpdateGLAccounts(GLAccountCategory, '61', '6199');
                end;
            GLAccountCategoryMgt.GetUtilitiesExpense():
                begin
                    UpdateGLAccounts(GLAccountCategory, '6', '60');
                    UpdateGLAccounts(GLAccountCategory, '6030', '6040');
                    UpdateGLAccounts(GLAccountCategory, '6099', '6099');
                    UpdateGLAccounts(GLAccountCategory, '62', '6599');
                end;
            GLAccountCategoryMgt.GetOtherIncomeExpense():
                begin
                    UpdateGLAccounts(GLAccountCategory, '36', '3800');
                    UpdateGLAccounts(GLAccountCategory, '67', '6799');
                    UpdateGLAccounts(GLAccountCategory, '7', '7510');
                end;
            GLAccountCategoryMgt.GetTaxExpense():
                UpdateGLAccounts(GLAccountCategory, '8900', '8900');
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

    procedure PostAcc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PostAccName()));
    end;

    procedure PostAccName(): Text[100]
    begin
        exit(PostAccTok);
    end;

    procedure BankCredit(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankCreditName()));
    end;

    procedure BankCreditName(): Text[100]
    begin
        exit(BankCreditTok);
    end;

    procedure BankCreditForeignCurrency(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankCreditForeignCurrencyName()));
    end;

    procedure BankCreditForeignCurrencyName(): Text[100]
    begin
        exit(BankCreditForeignCurrencyTok);
    end;

    procedure BankCreditEur(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankCreditEurName()));
    end;

    procedure BankCreditEurName(): Text[100]
    begin
        exit(BankCreditEurTok);
    end;

    procedure BankCreditUsd(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankCreditUsdName()));
    end;

    procedure BankCreditUsdName(): Text[100]
    begin
        exit(BankCreditUsdTok);
    end;

    procedure BankCreditDkk(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankCreditDkkName()));
    end;

    procedure BankCreditDkkName(): Text[100]
    begin
        exit(BankCreditDkkTok);
    end;

    procedure FixedTermDepInv(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FixedTermDepInvName()));
    end;

    procedure FixedTermDepInvName(): Text[100]
    begin
        exit(FixedTermDepInvTok);
    end;

    procedure MoneyTransAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MoneyTransAccountName()));
    end;

    procedure MoneyTransAccountName(): Text[100]
    begin
        exit(MoneyTransAccountTok);
    end;

    procedure TotalLiquidAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalLiquidAssetsName()));
    end;

    procedure TotalLiquidAssetsName(): Text[100]
    begin
        exit(TotalLiquidAssetsTok);
    end;

    procedure AcctsReceivable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcctsReceivableName()));
    end;

    procedure AcctsReceivableName(): Text[100]
    begin
        exit(AcctsReceivableTok);
    end;

    procedure ArsFromShipAndServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ArsFromShipAndServicesName()));
    end;

    procedure ArsFromShipAndServicesName(): Text[100]
    begin
        exit(ArsFromShipAndServicesTok);
    end;

    procedure CustomerCreditDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerCreditDomesticName()));
    end;

    procedure CustomerCreditDomesticName(): Text[100]
    begin
        exit(CustomerCreditDomesticTok);
    end;

    procedure CustomerCreditEu(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerCreditEuName()));
    end;

    procedure CustomerCreditEuName(): Text[100]
    begin
        exit(CustomerCreditEuTok);
    end;

    procedure CustomerCreditForeign(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerCreditForeignName()));
    end;

    procedure CustomerCreditForeignName(): Text[100]
    begin
        exit(CustomerCreditForeignTok);
    end;

    procedure CustomerCreditIc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerCreditIcName()));
    end;

    procedure CustomerCreditIcName(): Text[100]
    begin
        exit(CustomerCreditIcTok);
    end;

    procedure AcctsRecWithShareholders(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcctsRecWithShareholdersName()));
    end;

    procedure AcctsRecWithShareholdersName(): Text[100]
    begin
        exit(AcctsRecWithShareholdersTok);
    end;

    procedure OtherStAcctsReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherStAcctsReceivablesName()));
    end;

    procedure OtherStAcctsReceivablesName(): Text[100]
    begin
        exit(OtherStAcctsReceivablesTok);
    end;

    procedure StAcctsReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StAcctsReceivablesName()));
    end;

    procedure StAcctsReceivablesName(): Text[100]
    begin
        exit(StAcctsReceivablesTok);
    end;

    procedure StLoanShareholder(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StLoanShareholderName()));
    end;

    procedure StLoanShareholderName(): Text[100]
    begin
        exit(StLoanShareholderTok);
    end;

    procedure AcctsReceivablesOnGovLoc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcctsReceivablesOnGovLocName()));
    end;

    procedure AcctsReceivablesOnGovLocName(): Text[100]
    begin
        exit(AcctsReceivablesOnGovLocTok);
    end;

    procedure PurchVatMatDl(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchVatMatDlName()));
    end;

    procedure PurchVatMatDlName(): Text[100]
    begin
        exit(PurchVatMatDlTok);
    end;

    procedure PurchVatInvOperatingExp(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchVatInvOperatingExpName()));
    end;

    procedure PurchVatInvOperatingExpName(): Text[100]
    begin
        exit(PurchVatInvOperatingExpTok);
    end;

    procedure PurchVatOnImports100Percent(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchVatOnImports100PercentName()));
    end;

    procedure PurchVatOnImports100PercentName(): Text[100]
    begin
        exit(PurchVatOnImports100PercentTok);
    end;

    procedure CreditWithholdingTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CreditWithholdingTaxName()));
    end;

    procedure CreditWithholdingTaxName(): Text[100]
    begin
        exit(CreditWithholdingTaxTok);
    end;

    procedure RemainStAcctsReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RemainStAcctsReceivablesName()));
    end;

    procedure RemainStAcctsReceivablesName(): Text[100]
    begin
        exit(RemainStAcctsReceivablesTok);
    end;

    procedure WirCredit(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WirCreditName()));
    end;

    procedure WirCreditName(): Text[100]
    begin
        exit(WirCreditTok);
    end;

    procedure VendorPrepaymentsVat0Percent(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorPrepaymentsVat0PercentName()));
    end;

    procedure VendorPrepaymentsVat0PercentName(): Text[100]
    begin
        exit(VendorPrepaymentsVat0PercentTok);
    end;

    procedure VendorPrepaymentsVat80Percent(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorPrepaymentsVat80PercentName()));
    end;

    procedure VendorPrepaymentsVat80PercentName(): Text[100]
    begin
        exit(VendorPrepaymentsVat80PercentTok);
    end;

    procedure TotAcctsReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotAcctsReceivablesName()));
    end;

    procedure TotAcctsReceivablesName(): Text[100]
    begin
        exit(TotAcctsReceivablesTok);
    end;

    procedure InventoriesWip(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoriesWipName()));
    end;

    procedure InventoriesWipName(): Text[100]
    begin
        exit(InventoriesWipTok);
    end;

    procedure InvCommercialGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvCommercialGoodsName()));
    end;

    procedure InvCommercialGoodsName(): Text[100]
    begin
        exit(InvCommercialGoodsTok);
    end;

    procedure InvCommercialGoodsInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvCommercialGoodsInterimName()));
    end;

    procedure InvCommercialGoodsInterimName(): Text[100]
    begin
        exit(InvCommercialGoodsInterimTok);
    end;

    procedure WbInvCommercialGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WbInvCommercialGoodsName()));
    end;

    procedure WbInvCommercialGoodsName(): Text[100]
    begin
        exit(WbInvCommercialGoodsTok);
    end;

    procedure InvRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvRawMaterialsName()));
    end;

    procedure InvRawMaterialsName(): Text[100]
    begin
        exit(InvRawMaterialsTok);
    end;

    procedure InvRawMaterialsInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvRawMaterialsInterimName()));
    end;

    procedure InvRawMaterialsInterimName(): Text[100]
    begin
        exit(InvRawMaterialsInterimTok);
    end;

    procedure WbInvRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WbInvRawMaterialsName()));
    end;

    procedure WbInvRawMaterialsName(): Text[100]
    begin
        exit(WbInvRawMaterialsTok);
    end;

    procedure InvFinishedProducts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvFinishedProductsName()));
    end;

    procedure InvFinishedProductsName(): Text[100]
    begin
        exit(InvFinishedProductsTok);
    end;

    procedure InvFinProductsInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvFinProductsInterimName()));
    end;

    procedure InvFinProductsInterimName(): Text[100]
    begin
        exit(InvFinProductsInterimTok);
    end;

    procedure WbInvFinishProducts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WbInvFinishProductsName()));
    end;

    procedure WbInvFinishProductsName(): Text[100]
    begin
        exit(WbInvFinishProductsTok);
    end;

    procedure StartedProjects(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StartedProjectsName()));
    end;

    procedure StartedProjectsName(): Text[100]
    begin
        exit(StartedProjectsTok);
    end;

    procedure WbStartedProjects(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WbStartedProjectsName()));
    end;

    procedure WbStartedProjectsName(): Text[100]
    begin
        exit(WbStartedProjectsTok);
    end;

    procedure StartedProductionOrders(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StartedProductionOrdersName()));
    end;

    procedure StartedProductionOrdersName(): Text[100]
    begin
        exit(StartedProductionOrdersTok);
    end;

    procedure TotalInventoriesWip(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalInventoriesWipName()));
    end;

    procedure TotalInventoriesWipName(): Text[100]
    begin
        exit(TotalInventoriesWipTok);
    end;

    procedure AccruedIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedIncomeName()));
    end;

    procedure AccruedIncomeName(): Text[100]
    begin
        exit(AccruedIncomeTok);
    end;

    procedure PrepaidExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaidExpensesName()));
    end;

    procedure PrepaidExpensesName(): Text[100]
    begin
        exit(PrepaidExpensesTok);
    end;

    procedure EarningsNotYetReceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EarningsNotYetReceivedName()));
    end;

    procedure EarningsNotYetReceivedName(): Text[100]
    begin
        exit(EarningsNotYetReceivedTok);
    end;

    procedure TotalActiveDeferredItems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalActiveDeferredItemsName()));
    end;

    procedure TotalActiveDeferredItemsName(): Text[100]
    begin
        exit(TotalActiveDeferredItemsTok);
    end;

    procedure TotalCurrentAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCurrentAssetsName()));
    end;

    procedure TotalCurrentAssetsName(): Text[100]
    begin
        exit(TotalCurrentAssetsTok);
    end;

    procedure FinancialAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialAssetsName()));
    end;

    procedure FinancialAssetsName(): Text[100]
    begin
        exit(FinancialAssetsTok);
    end;

    procedure Securities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SecuritiesName()));
    end;

    procedure SecuritiesName(): Text[100]
    begin
        exit(SecuritiesTok);
    end;

    procedure FaAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FaAccountName()));
    end;

    procedure FaAccountName(): Text[100]
    begin
        exit(FaAccountTok);
    end;

    procedure Investments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvestmentsName()));
    end;

    procedure InvestmentsName(): Text[100]
    begin
        exit(InvestmentsTok);
    end;

    procedure LtAcctsReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LtAcctsReceivablesName()));
    end;

    procedure LtAcctsReceivablesName(): Text[100]
    begin
        exit(LtAcctsReceivablesTok);
    end;

    procedure LoanShareholder(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LoanShareholderName()));
    end;

    procedure LoanShareholderName(): Text[100]
    begin
        exit(LoanShareholderTok);
    end;

    procedure TotalFinancialAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFinancialAssetsName()));
    end;

    procedure TotalFinancialAssetsName(): Text[100]
    begin
        exit(TotalFinancialAssetsTok);
    end;

    procedure MobileFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MobileFixedAssetsName()));
    end;

    procedure MobileFixedAssetsName(): Text[100]
    begin
        exit(MobileFixedAssetsTok);
    end;

    procedure MachinesAndEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MachinesAndEquipmentName()));
    end;

    procedure MachinesAndEquipmentName(): Text[100]
    begin
        exit(MachinesAndEquipmentTok);
    end;

    procedure WbMachinesAndEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WbMachinesAndEquipmentName()));
    end;

    procedure WbMachinesAndEquipmentName(): Text[100]
    begin
        exit(WbMachinesAndEquipmentTok);
    end;

    procedure BusinessFurniture(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessFurnitureName()));
    end;

    procedure BusinessFurnitureName(): Text[100]
    begin
        exit(BusinessFurnitureTok);
    end;

    procedure WbBusinessFurniture(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WbBusinessFurnitureName()));
    end;

    procedure WbBusinessFurnitureName(): Text[100]
    begin
        exit(WbBusinessFurnitureTok);
    end;

    procedure OfficeMachines(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OfficeMachinesName()));
    end;

    procedure OfficeMachinesName(): Text[100]
    begin
        exit(OfficeMachinesTok);
    end;

    procedure ItHardwareAndSoftware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ItHardwareAndSoftwareName()));
    end;

    procedure ItHardwareAndSoftwareName(): Text[100]
    begin
        exit(ItHardwareAndSoftwareTok);
    end;

    procedure WbOfficeMachinesAndIt(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WbOfficeMachinesAndItName()));
    end;

    procedure WbOfficeMachinesAndItName(): Text[100]
    begin
        exit(WbOfficeMachinesAndItTok);
    end;

    procedure WbVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WbVehiclesName()));
    end;

    procedure WbVehiclesName(): Text[100]
    begin
        exit(WbVehiclesTok);
    end;

    procedure VehiclesEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VehiclesEquipmentName()));
    end;

    procedure VehiclesEquipmentName(): Text[100]
    begin
        exit(VehiclesEquipmentTok);
    end;

    procedure WbVehiclesEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WbVehiclesEquipmentName()));
    end;

    procedure WbVehiclesEquipmentName(): Text[100]
    begin
        exit(WbVehiclesEquipmentTok);
    end;

    procedure TotalMobileFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalMobileFixedAssetsName()));
    end;

    procedure TotalMobileFixedAssetsName(): Text[100]
    begin
        exit(TotalMobileFixedAssetsTok);
    end;

    procedure RealPropertyFa(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RealPropertyFaName()));
    end;

    procedure RealPropertyFaName(): Text[100]
    begin
        exit(RealPropertyFaTok);
    end;

    procedure RealEstate(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RealEstateName()));
    end;

    procedure RealEstateName(): Text[100]
    begin
        exit(RealEstateTok);
    end;

    procedure WbRealEstate(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WbRealEstateName()));
    end;

    procedure WbRealEstateName(): Text[100]
    begin
        exit(WbRealEstateTok);
    end;

    procedure TotalRealPropertyFa(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRealPropertyFaName()));
    end;

    procedure TotalRealPropertyFaName(): Text[100]
    begin
        exit(TotalRealPropertyFaTok);
    end;

    procedure IntangibleFa(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangibleFaName()));
    end;

    procedure IntangibleFaName(): Text[100]
    begin
        exit(IntangibleFaTok);
    end;

    procedure PatentsKnowledgeRecipes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PatentsKnowledgeRecipesName()));
    end;

    procedure PatentsKnowledgeRecipesName(): Text[100]
    begin
        exit(PatentsKnowledgeRecipesTok);
    end;

    procedure BrandsPrototypesModelsPlans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BrandsPrototypesModelsPlansName()));
    end;

    procedure BrandsPrototypesModelsPlansName(): Text[100]
    begin
        exit(BrandsPrototypesModelsPlansTok);
    end;

    procedure TotalIntangibleFa(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalIntangibleFaName()));
    end;

    procedure TotalIntangibleFaName(): Text[100]
    begin
        exit(TotalIntangibleFaTok);
    end;

    procedure TotalFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFixedAssetsName()));
    end;

    procedure TotalFixedAssetsName(): Text[100]
    begin
        exit(TotalFixedAssetsTok);
    end;

    procedure ActiveCorrectingEntries(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ActiveCorrectingEntriesName()));
    end;

    procedure ActiveCorrectingEntriesName(): Text[100]
    begin
        exit(ActiveCorrectingEntriesTok);
    end;

    procedure StartUpExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StartUpExpensesName()));
    end;

    procedure StartUpExpensesName(): Text[100]
    begin
        exit(StartUpExpensesTok);
    end;

    procedure ExcludedCapitalStock(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExcludedCapitalStockName()));
    end;

    procedure ExcludedCapitalStockName(): Text[100]
    begin
        exit(ExcludedCapitalStockTok);
    end;

    procedure TotalActCorrectingEntries(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalActCorrectingEntriesName()));
    end;

    procedure TotalActCorrectingEntriesName(): Text[100]
    begin
        exit(TotalActCorrectingEntriesTok);
    end;

    procedure NonOperationalAssetsHeading(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonOperationalAssetsHeadingName()));
    end;

    procedure NonOperationalAssetsHeadingName(): Text[100]
    begin
        exit(NonOperationalAssetsHeadingTok);
    end;

    procedure NonOperationalAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonOperationalAssetsName()));
    end;

    procedure NonOperationalAssetsName(): Text[100]
    begin
        exit(NonOperationalAssetsTok);
    end;

    procedure TotalAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAssetsName()));
    end;

    procedure TotalAssetsName(): Text[100]
    begin
        exit(TotalAssetsTok);
    end;

    procedure StLiabShipServ(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StLiabShipServName()));
    end;

    procedure StLiabShipServName(): Text[100]
    begin
        exit(StLiabShipServTok);
    end;

    procedure VendorsDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorsDomesticName()));
    end;

    procedure VendorsDomesticName(): Text[100]
    begin
        exit(VendorsDomesticTok);
    end;

    procedure VendorsEu(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorsEuName()));
    end;

    procedure VendorsEuName(): Text[100]
    begin
        exit(VendorsEuTok);
    end;

    procedure VendorsForeign(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorsForeignName()));
    end;

    procedure VendorsForeignName(): Text[100]
    begin
        exit(VendorsForeignTok);
    end;

    procedure VendorsIc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorsIcName()));
    end;

    procedure VendorsIcName(): Text[100]
    begin
        exit(VendorsIcTok);
    end;

    procedure CustomerPrepaymentsVat0Percent(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerPrepaymentsVat0PercentName()));
    end;

    procedure CustomerPrepaymentsVat0PercentName(): Text[100]
    begin
        exit(CustomerPrepaymentsVat0PercentTok);
    end;

    procedure CustomerPrepaymentsVat80Percent(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerPrepaymentsVat80PercentName()));
    end;

    procedure CustomerPrepaymentsVat80PercentName(): Text[100]
    begin
        exit(CustomerPrepaymentsVat80PercentTok);
    end;

    procedure BankOverdraft(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankOverdraftName()));
    end;

    procedure BankOverdraftName(): Text[100]
    begin
        exit(BankOverdraftTok);
    end;

    procedure StLoanToShareholders(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StLoanToShareholdersName()));
    end;

    procedure StLoanToShareholdersName(): Text[100]
    begin
        exit(StLoanToShareholdersTok);
    end;

    procedure OtherShortTermLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherShortTermLiabilitiesName()));
    end;

    procedure OtherShortTermLiabilitiesName(): Text[100]
    begin
        exit(OtherShortTermLiabilitiesTok);
    end;

    procedure VatOwed(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VatOwedName()));
    end;

    procedure VatOwedName(): Text[100]
    begin
        exit(VatOwedTok);
    end;

    procedure VendorVat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorVatName()));
    end;

    procedure VendorVatName(): Text[100]
    begin
        exit(VendorVatTok);
    end;

    procedure DividendsDue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DividendsDueName()));
    end;

    procedure DividendsDueName(): Text[100]
    begin
        exit(DividendsDueTok);
    end;

    procedure LiabilitiesAccruedExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LiabilitiesAccruedExpensesName()));
    end;

    procedure LiabilitiesAccruedExpensesName(): Text[100]
    begin
        exit(LiabilitiesAccruedExpensesTok);
    end;

    procedure UnpaidExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UnpaidExpensesName()));
    end;

    procedure UnpaidExpensesName(): Text[100]
    begin
        exit(UnpaidExpensesTok);
    end;

    procedure EarningsReceivedInAdvance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EarningsReceivedInAdvanceName()));
    end;

    procedure EarningsReceivedInAdvanceName(): Text[100]
    begin
        exit(EarningsReceivedInAdvanceTok);
    end;

    procedure WarrantyReserve(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WarrantyReserveName()));
    end;

    procedure WarrantyReserveName(): Text[100]
    begin
        exit(WarrantyReserveTok);
    end;

    procedure TaxationReserve(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxationReserveName()));
    end;

    procedure TaxationReserveName(): Text[100]
    begin
        exit(TaxationReserveTok);
    end;

    procedure TotalShortTermLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalShortTermLiabilitiesName()));
    end;

    procedure TotalShortTermLiabilitiesName(): Text[100]
    begin
        exit(TotalShortTermLiabilitiesTok);
    end;

    procedure LongTermLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LongTermLoansName()));
    end;

    procedure LongTermLoansName(): Text[100]
    begin
        exit(LongTermLoansTok);
    end;

    procedure BankLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankLoansName()));
    end;

    procedure BankLoansName(): Text[100]
    begin
        exit(BankLoansTok);
    end;

    procedure MortgageLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MortgageLoansName()));
    end;

    procedure MortgageLoansName(): Text[100]
    begin
        exit(MortgageLoansTok);
    end;

    procedure LongTermReserves(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LongTermReservesName()));
    end;

    procedure LongTermReservesName(): Text[100]
    begin
        exit(LongTermReservesTok);
    end;

    procedure LtReserveRepairs(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LtReserveRepairsName()));
    end;

    procedure LtReserveRepairsName(): Text[100]
    begin
        exit(LtReserveRepairsTok);
    end;

    procedure LongTermWarrantyWork(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LongTermWarrantyWorkName()));
    end;

    procedure LongTermWarrantyWorkName(): Text[100]
    begin
        exit(LongTermWarrantyWorkTok);
    end;

    procedure LtReserveDeferredTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LtReserveDeferredTaxName()));
    end;

    procedure LtReserveDeferredTaxName(): Text[100]
    begin
        exit(LtReserveDeferredTaxTok);
    end;

    procedure TotalLongTermLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalLongTermLiabilitiesName()));
    end;

    procedure TotalLongTermLiabilitiesName(): Text[100]
    begin
        exit(TotalLongTermLiabilitiesTok);
    end;

    procedure TotalLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalLiabilitiesName()));
    end;

    procedure TotalLiabilitiesName(): Text[100]
    begin
        exit(TotalLiabilitiesTok);
    end;

    procedure ShareholdersEquity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShareholdersEquityName()));
    end;

    procedure ShareholdersEquityName(): Text[100]
    begin
        exit(ShareholdersEquityTok);
    end;

    procedure Capital(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapitalName()));
    end;

    procedure CapitalName(): Text[100]
    begin
        exit(CapitalTok);
    end;

    procedure ReservesAndRetainedEarnings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReservesAndRetainedEarningsName()));
    end;

    procedure ReservesAndRetainedEarningsName(): Text[100]
    begin
        exit(ReservesAndRetainedEarningsTok);
    end;

    procedure LegalReserves(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LegalReservesName()));
    end;

    procedure LegalReservesName(): Text[100]
    begin
        exit(LegalReservesTok);
    end;

    procedure StatutoryReserves(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StatutoryReservesName()));
    end;

    procedure StatutoryReservesName(): Text[100]
    begin
        exit(StatutoryReservesTok);
    end;

    procedure FreeReserves(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreeReservesName()));
    end;

    procedure FreeReservesName(): Text[100]
    begin
        exit(FreeReservesTok);
    end;

    procedure RetEarningsLossCarriedFwd(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RetEarningsLossCarriedFwdName()));
    end;

    procedure RetEarningsLossCarriedFwdName(): Text[100]
    begin
        exit(RetEarningsLossCarriedFwdTok);
    end;

    procedure RetainedEarningsLoss(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RetainedEarningsLossName()));
    end;

    procedure RetainedEarningsLossName(): Text[100]
    begin
        exit(RetainedEarningsLossTok);
    end;

    procedure AnnualEarningsLoss(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AnnualEarningsLossName()));
    end;

    procedure AnnualEarningsLossName(): Text[100]
    begin
        exit(AnnualEarningsLossTok);
    end;

    procedure EarnedCapital(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EarnedCapitalName()));
    end;

    procedure EarnedCapitalName(): Text[100]
    begin
        exit(EarnedCapitalTok);
    end;

    procedure TotalShareholdersEquity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalShareholdersEquityName()));
    end;

    procedure TotalShareholdersEquityName(): Text[100]
    begin
        exit(TotalShareholdersEquityTok);
    end;

    procedure TotalLiabilitiesEndTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalLiabilitiesEndTotalName()));
    end;

    procedure TotalLiabilitiesEndTotalName(): Text[100]
    begin
        exit(TotalLiabilitiesEndTotalTok);
    end;

    procedure GainLossIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainLossIncomeName()));
    end;

    procedure GainLossIncomeName(): Text[100]
    begin
        exit(GainLossIncomeTok);
    end;

    procedure OpIncomeShipServ(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OpIncomeShipServName()));
    end;

    procedure OpIncomeShipServName(): Text[100]
    begin
        exit(OpIncomeShipServTok);
    end;

    procedure ProdEarnings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProdEarningsName()));
    end;

    procedure ProdEarningsName(): Text[100]
    begin
        exit(ProdEarningsTok);
    end;

    procedure ProdEarningsDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProdEarningsDomesticName()));
    end;

    procedure ProdEarningsDomesticName(): Text[100]
    begin
        exit(ProdEarningsDomesticTok);
    end;

    procedure ProdEarningsEurope(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProdEarningsEuropeName()));
    end;

    procedure ProdEarningsEuropeName(): Text[100]
    begin
        exit(ProdEarningsEuropeTok);
    end;

    procedure ProdEarningsInternat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProdEarningsInternatName()));
    end;

    procedure ProdEarningsInternatName(): Text[100]
    begin
        exit(ProdEarningsInternatTok);
    end;

    procedure InvChangeFinishedProducts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvChangeFinishedProductsName()));
    end;

    procedure InvChangeFinishedProductsName(): Text[100]
    begin
        exit(InvChangeFinishedProductsTok);
    end;

    procedure InvChgFinishedProdProv(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvChgFinishedProdProvName()));
    end;

    procedure InvChgFinishedProdProvName(): Text[100]
    begin
        exit(InvChgFinishedProdProvTok);
    end;

    procedure TradeEarning(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeEarningName()));
    end;

    procedure TradeEarningName(): Text[100]
    begin
        exit(TradeEarningTok);
    end;

    procedure TradeDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeDomesticName()));
    end;

    procedure TradeDomesticName(): Text[100]
    begin
        exit(TradeDomesticTok);
    end;

    procedure TradeEurope(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeEuropeName()));
    end;

    procedure TradeEuropeName(): Text[100]
    begin
        exit(TradeEuropeTok);
    end;

    procedure TradeInternat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TradeInternatName()));
    end;

    procedure TradeInternatName(): Text[100]
    begin
        exit(TradeInternatTok);
    end;

    procedure InvChangeCommGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvChangeCommGoodsName()));
    end;

    procedure InvChangeCommGoodsName(): Text[100]
    begin
        exit(InvChangeCommGoodsTok);
    end;

    procedure InvChangeTradeProv(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvChangeTradeProvName()));
    end;

    procedure InvChangeTradeProvName(): Text[100]
    begin
        exit(InvChangeTradeProvTok);
    end;

    procedure ServiceEarnings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServiceEarningsName()));
    end;

    procedure ServiceEarningsName(): Text[100]
    begin
        exit(ServiceEarningsTok);
    end;

    procedure ServiceEarningsDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServiceEarningsDomesticName()));
    end;

    procedure ServiceEarningsDomesticName(): Text[100]
    begin
        exit(ServiceEarningsDomesticTok);
    end;

    procedure ServiceEarningsEurope(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServiceEarningsEuropeName()));
    end;

    procedure ServiceEarningsEuropeName(): Text[100]
    begin
        exit(ServiceEarningsEuropeTok);
    end;

    procedure ServiceEarningsInternat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServiceEarningsInternatName()));
    end;

    procedure ServiceEarningsInternatName(): Text[100]
    begin
        exit(ServiceEarningsInternatTok);
    end;

    procedure ProjectEarnings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProjectEarningsName()));
    end;

    procedure ProjectEarningsName(): Text[100]
    begin
        exit(ProjectEarningsTok);
    end;

    procedure JobSalesAppliedAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobSalesAppliedAccountName()));
    end;

    procedure JobSalesAppliedAccountName(): Text[100]
    begin
        exit(JobSalesAppliedAccountTok);
    end;

    procedure ConsultancyEarnings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsultancyEarningsName()));
    end;

    procedure ConsultancyEarningsName(): Text[100]
    begin
        exit(ConsultancyEarningsTok);
    end;

    procedure InventoryChangeReqWork(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryChangeReqWorkName()));
    end;

    procedure InventoryChangeReqWorkName(): Text[100]
    begin
        exit(InventoryChangeReqWorkTok);
    end;

    procedure OtherEarningsHeading(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherEarningsHeadingName()));
    end;

    procedure OtherEarningsHeadingName(): Text[100]
    begin
        exit(OtherEarningsHeadingTok);
    end;

    procedure OtherEarnings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherEarningsName()));
    end;

    procedure OtherEarningsName(): Text[100]
    begin
        exit(OtherEarningsTok);
    end;

    procedure OwnContributionOwnUse(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OwnContributionOwnUseName()));
    end;

    procedure OwnContributionOwnUseName(): Text[100]
    begin
        exit(OwnContributionOwnUseTok);
    end;

    procedure InventoryChanges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryChangesName()));
    end;

    procedure InventoryChangesName(): Text[100]
    begin
        exit(InventoryChangesTok);
    end;

    procedure DropInEarnings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DropInEarningsName()));
    end;

    procedure DropInEarningsName(): Text[100]
    begin
        exit(DropInEarningsTok);
    end;

    procedure CashDiscounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashDiscountsName()));
    end;

    procedure CashDiscountsName(): Text[100]
    begin
        exit(CashDiscountsTok);
    end;

    procedure Discounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DiscountsName()));
    end;

    procedure DiscountsName(): Text[100]
    begin
        exit(DiscountsTok);
    end;

    procedure LossFromAccountsRec(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LossFromAccountsRecName()));
    end;

    procedure LossFromAccountsRecName(): Text[100]
    begin
        exit(LossFromAccountsRecTok);
    end;

    procedure UnrealizedExchRateAdjmts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UnrealizedExchRateAdjmtsName()));
    end;

    procedure UnrealizedExchRateAdjmtsName(): Text[100]
    begin
        exit(UnrealizedExchRateAdjmtsTok);
    end;

    procedure RealizedExchangeRateAdjmts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RealizedExchangeRateAdjmtsName()));
    end;

    procedure RealizedExchangeRateAdjmtsName(): Text[100]
    begin
        exit(RealizedExchangeRateAdjmtsTok);
    end;

    procedure RoundingDifferencesSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RoundingDifferencesSalesName()));
    end;

    procedure RoundingDifferencesSalesName(): Text[100]
    begin
        exit(RoundingDifferencesSalesTok);
    end;

    procedure TotalOpIncomeShipServ(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOpIncomeShipServName()));
    end;

    procedure TotalOpIncomeShipServName(): Text[100]
    begin
        exit(TotalOpIncomeShipServTok);
    end;

    procedure CostGoodsMaterialDl(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostGoodsMaterialDlName()));
    end;

    procedure CostGoodsMaterialDlName(): Text[100]
    begin
        exit(CostGoodsMaterialDlTok);
    end;

    procedure CostOfMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfMaterialsName()));
    end;

    procedure CostOfMaterialsName(): Text[100]
    begin
        exit(CostOfMaterialsTok);
    end;

    procedure CostOfMaterialDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfMaterialDomesticName()));
    end;

    procedure CostOfMaterialDomesticName(): Text[100]
    begin
        exit(CostOfMaterialDomesticTok);
    end;

    procedure CostOfMaterialsEurope(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfMaterialsEuropeName()));
    end;

    procedure CostOfMaterialsEuropeName(): Text[100]
    begin
        exit(CostOfMaterialsEuropeTok);
    end;

    procedure CostOfMaterialsInternat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfMaterialsInternatName()));
    end;

    procedure CostOfMaterialsInternatName(): Text[100]
    begin
        exit(CostOfMaterialsInternatTok);
    end;

    procedure VariancePurchMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VariancePurchMaterialsName()));
    end;

    procedure VariancePurchMaterialsName(): Text[100]
    begin
        exit(VariancePurchMaterialsTok);
    end;

    procedure Subcontracting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubcontractingName()));
    end;

    procedure SubcontractingName(): Text[100]
    begin
        exit(SubcontractingTok);
    end;

    procedure OverheadCostsMatProd(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OverheadCostsMatProdName()));
    end;

    procedure OverheadCostsMatProdName(): Text[100]
    begin
        exit(OverheadCostsMatProdTok);
    end;

    procedure CostOfCommercialGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfCommercialGoodsName()));
    end;

    procedure CostOfCommercialGoodsName(): Text[100]
    begin
        exit(CostOfCommercialGoodsTok);
    end;

    procedure CostOfCommGoodsDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfCommGoodsDomesticName()));
    end;

    procedure CostOfCommGoodsDomesticName(): Text[100]
    begin
        exit(CostOfCommGoodsDomesticTok);
    end;

    procedure CostOfCommGoodsEurope(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfCommGoodsEuropeName()));
    end;

    procedure CostOfCommGoodsEuropeName(): Text[100]
    begin
        exit(CostOfCommGoodsEuropeTok);
    end;

    procedure CostOfCommGoodsIntl(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfCommGoodsIntlName()));
    end;

    procedure CostOfCommGoodsIntlName(): Text[100]
    begin
        exit(CostOfCommGoodsIntlTok);
    end;

    procedure VariancePurchTrade(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VariancePurchTradeName()));
    end;

    procedure VariancePurchTradeName(): Text[100]
    begin
        exit(VariancePurchTradeTok);
    end;

    procedure OverheadCostsCommGood(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OverheadCostsCommGoodName()));
    end;

    procedure OverheadCostsCommGoodName(): Text[100]
    begin
        exit(OverheadCostsCommGoodTok);
    end;

    procedure CostOfSubcontracts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostOfSubcontractsName()));
    end;

    procedure CostOfSubcontractsName(): Text[100]
    begin
        exit(CostOfSubcontractsTok);
    end;

    procedure SubcontrOfSpOperations(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubcontrOfSpOperationsName()));
    end;

    procedure SubcontrOfSpOperationsName(): Text[100]
    begin
        exit(SubcontrOfSpOperationsTok);
    end;

    procedure JobCostsWip(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostsWipName()));
    end;

    procedure JobCostsWipName(): Text[100]
    begin
        exit(JobCostsWipTok);
    end;

    procedure OtherCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherCostsName()));
    end;

    procedure OtherCostsName(): Text[100]
    begin
        exit(OtherCostsTok);
    end;

    procedure EnergyCostsCOGS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EnergyCostsCOGSName()));
    end;

    procedure EnergyCostsCOGSName(): Text[100]
    begin
        exit(EnergyCostsCOGSTok);
    end;

    procedure PackagingCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PackagingCostsName()));
    end;

    procedure PackagingCostsName(): Text[100]
    begin
        exit(PackagingCostsTok);
    end;

    procedure DirectPurchCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DirectPurchCostsName()));
    end;

    procedure DirectPurchCostsName(): Text[100]
    begin
        exit(DirectPurchCostsTok);
    end;

    procedure InvChangeProductionMat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvChangeProductionMatName()));
    end;

    procedure InvChangeProductionMatName(): Text[100]
    begin
        exit(InvChangeProductionMatTok);
    end;

    procedure InvChangeCommGoodsCOGS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvChangeCommGoodsCOGSName()));
    end;

    procedure InvChangeCommGoodsCOGSName(): Text[100]
    begin
        exit(InvChangeCommGoodsCOGSTok);
    end;

    procedure InvChangeProjects(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvChangeProjectsName()));
    end;

    procedure InvChangeProjectsName(): Text[100]
    begin
        exit(InvChangeProjectsTok);
    end;

    procedure MaterialLoss(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaterialLossName()));
    end;

    procedure MaterialLossName(): Text[100]
    begin
        exit(MaterialLossTok);
    end;

    procedure GoodsLoss(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsLossName()));
    end;

    procedure GoodsLossName(): Text[100]
    begin
        exit(GoodsLossTok);
    end;

    procedure MaterialVarianceProduction(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaterialVarianceProductionName()));
    end;

    procedure MaterialVarianceProductionName(): Text[100]
    begin
        exit(MaterialVarianceProductionTok);
    end;

    procedure CapacityVarianceProduction(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapacityVarianceProductionName()));
    end;

    procedure CapacityVarianceProductionName(): Text[100]
    begin
        exit(CapacityVarianceProductionTok);
    end;

    procedure VarianceMatOverheadCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VarianceMatOverheadCostsName()));
    end;

    procedure VarianceMatOverheadCostsName(): Text[100]
    begin
        exit(VarianceMatOverheadCostsTok);
    end;

    procedure VarianceCapOverheadCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VarianceCapOverheadCostsName()));
    end;

    procedure VarianceCapOverheadCostsName(): Text[100]
    begin
        exit(VarianceCapOverheadCostsTok);
    end;

    procedure VarianceSubcontracting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VarianceSubcontractingName()));
    end;

    procedure VarianceSubcontractingName(): Text[100]
    begin
        exit(VarianceSubcontractingTok);
    end;

    procedure CostReductions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostReductionsName()));
    end;

    procedure CostReductionsName(): Text[100]
    begin
        exit(CostReductionsTok);
    end;

    procedure PurchaseDisc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseDiscName()));
    end;

    procedure PurchaseDiscName(): Text[100]
    begin
        exit(PurchaseDiscTok);
    end;

    procedure CostReductionDiscount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostReductionDiscountName()));
    end;

    procedure CostReductionDiscountName(): Text[100]
    begin
        exit(CostReductionDiscountTok);
    end;

    procedure UnrealExchangeRateAdjmts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UnrealExchangeRateAdjmtsName()));
    end;

    procedure UnrealExchangeRateAdjmtsName(): Text[100]
    begin
        exit(UnrealExchangeRateAdjmtsTok);
    end;

    procedure RealizedExchangeRateAdjmtsCOGS(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RealizedExchangeRateAdjmtsCOGSName()));
    end;

    procedure RealizedExchangeRateAdjmtsCOGSName(): Text[100]
    begin
        exit(RealizedExchangeRateAdjmtsCOGSTok);
    end;

    procedure RoundingDifferencesPurchase(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RoundingDifferencesPurchaseName()));
    end;

    procedure RoundingDifferencesPurchaseName(): Text[100]
    begin
        exit(RoundingDifferencesPurchaseTok);
    end;

    procedure TotalCostsGoodsMatDl(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostsGoodsMatDlName()));
    end;

    procedure TotalCostsGoodsMatDlName(): Text[100]
    begin
        exit(TotalCostsGoodsMatDlTok);
    end;

    procedure PersonnelCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PersonnelCostsName()));
    end;

    procedure PersonnelCostsName(): Text[100]
    begin
        exit(PersonnelCostsTok);
    end;

    procedure WagesProduction(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WagesProductionName()));
    end;

    procedure WagesProductionName(): Text[100]
    begin
        exit(WagesProductionTok);
    end;

    procedure WagesSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WagesSalesName()));
    end;

    procedure WagesSalesName(): Text[100]
    begin
        exit(WagesSalesTok);
    end;

    procedure WagesManagement(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WagesManagementName()));
    end;

    procedure WagesManagementName(): Text[100]
    begin
        exit(WagesManagementTok);
    end;

    procedure AhvIvEoAlv(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AhvIvEoAlvName()));
    end;

    procedure AhvIvEoAlvName(): Text[100]
    begin
        exit(AhvIvEoAlvTok);
    end;

    procedure PensionPlanning(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PensionPlanningName()));
    end;

    procedure PensionPlanningName(): Text[100]
    begin
        exit(PensionPlanningTok);
    end;

    procedure CasualtyInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CasualtyInsuranceName()));
    end;

    procedure CasualtyInsuranceName(): Text[100]
    begin
        exit(CasualtyInsuranceTok);
    end;

    procedure HealthInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HealthInsuranceName()));
    end;

    procedure HealthInsuranceName(): Text[100]
    begin
        exit(HealthInsuranceTok);
    end;

    procedure IncomeTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeTaxName()));
    end;

    procedure IncomeTaxName(): Text[100]
    begin
        exit(IncomeTaxTok);
    end;

    procedure TrngAndContinuingEd(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TrngAndContinuingEdName()));
    end;

    procedure TrngAndContinuingEdName(): Text[100]
    begin
        exit(TrngAndContinuingEdTok);
    end;

    procedure ReimbursementOfExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReimbursementOfExpensesName()));
    end;

    procedure ReimbursementOfExpensesName(): Text[100]
    begin
        exit(ReimbursementOfExpensesTok);
    end;

    procedure OtherPersonnelCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherPersonnelCostsName()));
    end;

    procedure OtherPersonnelCostsName(): Text[100]
    begin
        exit(OtherPersonnelCostsTok);
    end;

    procedure TotalPersonnelCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPersonnelCostsName()));
    end;

    procedure TotalPersonnelCostsName(): Text[100]
    begin
        exit(TotalPersonnelCostsTok);
    end;

    procedure PremisesCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PremisesCostsName()));
    end;

    procedure PremisesCostsName(): Text[100]
    begin
        exit(PremisesCostsTok);
    end;

    procedure Rent(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentName()));
    end;

    procedure RentName(): Text[100]
    begin
        exit(RentTok);
    end;

    procedure RentalValueForUsedProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentalValueForUsedPropertyName()));
    end;

    procedure RentalValueForUsedPropertyName(): Text[100]
    begin
        exit(RentalValueForUsedPropertyTok);
    end;

    procedure AddCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AddCostsName()));
    end;

    procedure AddCostsName(): Text[100]
    begin
        exit(AddCostsTok);
    end;

    procedure MaintOfBusinessPremises(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaintOfBusinessPremisesName()));
    end;

    procedure MaintOfBusinessPremisesName(): Text[100]
    begin
        exit(MaintOfBusinessPremisesTok);
    end;

    procedure TotalPremisesCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPremisesCostsName()));
    end;

    procedure TotalPremisesCostsName(): Text[100]
    begin
        exit(TotalPremisesCostsTok);
    end;

    procedure MaintRepairs(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaintRepairsName()));
    end;

    procedure MaintRepairsName(): Text[100]
    begin
        exit(MaintRepairsTok);
    end;

    procedure MaintProductionPlants(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaintProductionPlantsName()));
    end;

    procedure MaintProductionPlantsName(): Text[100]
    begin
        exit(MaintProductionPlantsTok);
    end;

    procedure MaintSalesEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaintSalesEquipmentName()));
    end;

    procedure MaintSalesEquipmentName(): Text[100]
    begin
        exit(MaintSalesEquipmentTok);
    end;

    procedure MaintStorageFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaintStorageFacilitiesName()));
    end;

    procedure MaintStorageFacilitiesName(): Text[100]
    begin
        exit(MaintStorageFacilitiesTok);
    end;

    procedure MaintOfficeEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaintOfficeEquipmentName()));
    end;

    procedure MaintOfficeEquipmentName(): Text[100]
    begin
        exit(MaintOfficeEquipmentTok);
    end;

    procedure LeasingMobileFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LeasingMobileFixedAssetsName()));
    end;

    procedure LeasingMobileFixedAssetsName(): Text[100]
    begin
        exit(LeasingMobileFixedAssetsTok);
    end;

    procedure TotalMaintRepairs(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalMaintRepairsName()));
    end;

    procedure TotalMaintRepairsName(): Text[100]
    begin
        exit(TotalMaintRepairsTok);
    end;

    procedure VehicleAndTransportCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VehicleAndTransportCostsName()));
    end;

    procedure VehicleAndTransportCostsName(): Text[100]
    begin
        exit(VehicleAndTransportCostsTok);
    end;

    procedure VehicleMaint(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VehicleMaintName()));
    end;

    procedure VehicleMaintName(): Text[100]
    begin
        exit(VehicleMaintTok);
    end;

    procedure OpMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OpMaterialsName()));
    end;

    procedure OpMaterialsName(): Text[100]
    begin
        exit(OpMaterialsTok);
    end;

    procedure AutoInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AutoInsuranceName()));
    end;

    procedure AutoInsuranceName(): Text[100]
    begin
        exit(AutoInsuranceTok);
    end;

    procedure TransportTaxRates(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TransportTaxRatesName()));
    end;

    procedure TransportTaxRatesName(): Text[100]
    begin
        exit(TransportTaxRatesTok);
    end;

    procedure TransportCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TransportCostsName()));
    end;

    procedure TransportCostsName(): Text[100]
    begin
        exit(TransportCostsTok);
    end;

    procedure ShippingChargeCustomer(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShippingChargeCustomerName()));
    end;

    procedure ShippingChargeCustomerName(): Text[100]
    begin
        exit(ShippingChargeCustomerTok);
    end;

    procedure TotalVehicleAndTransport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalVehicleAndTransportName()));
    end;

    procedure TotalVehicleAndTransportName(): Text[100]
    begin
        exit(TotalVehicleAndTransportTok);
    end;

    procedure PropertyInsuranceRates(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PropertyInsuranceRatesName()));
    end;

    procedure PropertyInsuranceRatesName(): Text[100]
    begin
        exit(PropertyInsuranceRatesTok);
    end;

    procedure PropertyInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PropertyInsuranceName()));
    end;

    procedure PropertyInsuranceName(): Text[100]
    begin
        exit(PropertyInsuranceTok);
    end;

    procedure OperatingLiability(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OperatingLiabilityName()));
    end;

    procedure OperatingLiabilityName(): Text[100]
    begin
        exit(OperatingLiabilityTok);
    end;

    procedure DowntimeInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DowntimeInsuranceName()));
    end;

    procedure DowntimeInsuranceName(): Text[100]
    begin
        exit(DowntimeInsuranceTok);
    end;

    procedure TaxRates(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxRatesName()));
    end;

    procedure TaxRatesName(): Text[100]
    begin
        exit(TaxRatesTok);
    end;

    procedure PermitsPatents(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PermitsPatentsName()));
    end;

    procedure PermitsPatentsName(): Text[100]
    begin
        exit(PermitsPatentsTok);
    end;

    procedure TotalInsuranceFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalInsuranceFeesName()));
    end;

    procedure TotalInsuranceFeesName(): Text[100]
    begin
        exit(TotalInsuranceFeesTok);
    end;

    procedure EnergyWasteCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EnergyWasteCostsName()));
    end;

    procedure EnergyWasteCostsName(): Text[100]
    begin
        exit(EnergyWasteCostsTok);
    end;

    procedure EnergyCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EnergyCostsName()));
    end;

    procedure EnergyCostsName(): Text[100]
    begin
        exit(EnergyCostsTok);
    end;

    procedure WasteCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WasteCostsName()));
    end;

    procedure WasteCostsName(): Text[100]
    begin
        exit(WasteCostsTok);
    end;

    procedure TotalEnergyWaste(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalEnergyWasteName()));
    end;

    procedure TotalEnergyWasteName(): Text[100]
    begin
        exit(TotalEnergyWasteTok);
    end;

    procedure ManagementInformationCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManagementInformationCostsName()));
    end;

    procedure ManagementInformationCostsName(): Text[100]
    begin
        exit(ManagementInformationCostsTok);
    end;

    procedure AdministrativeCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdministrativeCostsName()));
    end;

    procedure AdministrativeCostsName(): Text[100]
    begin
        exit(AdministrativeCostsTok);
    end;

    procedure OfficeMatPrintSupplies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OfficeMatPrintSuppliesName()));
    end;

    procedure OfficeMatPrintSuppliesName(): Text[100]
    begin
        exit(OfficeMatPrintSuppliesTok);
    end;

    procedure TechDoc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TechDocName()));
    end;

    procedure TechDocName(): Text[100]
    begin
        exit(TechDocTok);
    end;

    procedure CommunicationTelephone(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CommunicationTelephoneName()));
    end;

    procedure CommunicationTelephoneName(): Text[100]
    begin
        exit(CommunicationTelephoneTok);
    end;

    procedure Deductions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeductionsName()));
    end;

    procedure DeductionsName(): Text[100]
    begin
        exit(DeductionsTok);
    end;

    procedure AccountingConsultancy(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountingConsultancyName()));
    end;

    procedure AccountingConsultancyName(): Text[100]
    begin
        exit(AccountingConsultancyTok);
    end;

    procedure BoardOfDirectorsGvRevision(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BoardOfDirectorsGvRevisionName()));
    end;

    procedure BoardOfDirectorsGvRevisionName(): Text[100]
    begin
        exit(BoardOfDirectorsGvRevisionTok);
    end;

    procedure InformationCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InformationCostsName()));
    end;

    procedure InformationCostsName(): Text[100]
    begin
        exit(InformationCostsTok);
    end;

    procedure ItLeasing(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ItLeasingName()));
    end;

    procedure ItLeasingName(): Text[100]
    begin
        exit(ItLeasingTok);
    end;

    procedure ItProgramLicensesMaint(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ItProgramLicensesMaintName()));
    end;

    procedure ItProgramLicensesMaintName(): Text[100]
    begin
        exit(ItProgramLicensesMaintTok);
    end;

    procedure ItSupplies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ItSuppliesName()));
    end;

    procedure ItSuppliesName(): Text[100]
    begin
        exit(ItSuppliesTok);
    end;

    procedure ConsultingAndDevelopment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsultingAndDevelopmentName()));
    end;

    procedure ConsultingAndDevelopmentName(): Text[100]
    begin
        exit(ConsultingAndDevelopmentTok);
    end;

    procedure TotalAdministrationIt(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAdministrationItName()));
    end;

    procedure TotalAdministrationItName(): Text[100]
    begin
        exit(TotalAdministrationItTok);
    end;

    procedure AdvertisingCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvertisingCostsName()));
    end;

    procedure AdvertisingCostsName(): Text[100]
    begin
        exit(AdvertisingCostsTok);
    end;

    procedure AdvertisementsAndMedia(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvertisementsAndMediaName()));
    end;

    procedure AdvertisementsAndMediaName(): Text[100]
    begin
        exit(AdvertisementsAndMediaTok);
    end;

    procedure AdMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdMaterialsName()));
    end;

    procedure AdMaterialsName(): Text[100]
    begin
        exit(AdMaterialsTok);
    end;

    procedure Exhibits(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExhibitsName()));
    end;

    procedure ExhibitsName(): Text[100]
    begin
        exit(ExhibitsTok);
    end;

    procedure TravelCostsCustomerService(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TravelCostsCustomerServiceName()));
    end;

    procedure TravelCostsCustomerServiceName(): Text[100]
    begin
        exit(TravelCostsCustomerServiceTok);
    end;

    procedure AdvertContribSponsoring(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvertContribSponsoringName()));
    end;

    procedure AdvertContribSponsoringName(): Text[100]
    begin
        exit(AdvertContribSponsoringTok);
    end;

    procedure PublicRelationsPr(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PublicRelationsPrName()));
    end;

    procedure PublicRelationsPrName(): Text[100]
    begin
        exit(PublicRelationsPrTok);
    end;

    procedure AdConsultancyMarketAnaly(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdConsultancyMarketAnalyName()));
    end;

    procedure AdConsultancyMarketAnalyName(): Text[100]
    begin
        exit(AdConsultancyMarketAnalyTok);
    end;

    procedure TotalAdvertisingCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAdvertisingCostsName()));
    end;

    procedure TotalAdvertisingCostsName(): Text[100]
    begin
        exit(TotalAdvertisingCostsTok);
    end;

    procedure OtherOpExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherOpExpensesName()));
    end;

    procedure OtherOpExpensesName(): Text[100]
    begin
        exit(OtherOpExpensesTok);
    end;

    procedure EconomicInformation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EconomicInformationName()));
    end;

    procedure EconomicInformationName(): Text[100]
    begin
        exit(EconomicInformationTok);
    end;

    procedure OperReliabilityMonitoring(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OperReliabilityMonitoringName()));
    end;

    procedure OperReliabilityMonitoringName(): Text[100]
    begin
        exit(OperReliabilityMonitoringTok);
    end;

    procedure ResearchAndDevelopment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResearchAndDevelopmentName()));
    end;

    procedure ResearchAndDevelopmentName(): Text[100]
    begin
        exit(ResearchAndDevelopmentTok);
    end;

    procedure MiscCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscCostsName()));
    end;

    procedure MiscCostsName(): Text[100]
    begin
        exit(MiscCostsTok);
    end;

    procedure TotalOtherOperatingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherOperatingExpensesName()));
    end;

    procedure TotalOtherOperatingExpensesName(): Text[100]
    begin
        exit(TotalOtherOperatingExpensesTok);
    end;

    procedure FinancialIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialIncomeName()));
    end;

    procedure FinancialIncomeName(): Text[100]
    begin
        exit(FinancialIncomeTok);
    end;

    procedure FinancialExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialExpensesName()));
    end;

    procedure FinancialExpensesName(): Text[100]
    begin
        exit(FinancialExpensesTok);
    end;

    procedure BankInterestRateCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankInterestRateCostsName()));
    end;

    procedure BankInterestRateCostsName(): Text[100]
    begin
        exit(BankInterestRateCostsTok);
    end;

    procedure MortgageIntRateCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MortgageIntRateCostsName()));
    end;

    procedure MortgageIntRateCostsName(): Text[100]
    begin
        exit(MortgageIntRateCostsTok);
    end;

    procedure BankAndPcCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankAndPcCostsName()));
    end;

    procedure BankAndPcCostsName(): Text[100]
    begin
        exit(BankAndPcCostsTok);
    end;

    procedure FinancialProfit(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialProfitName()));
    end;

    procedure FinancialProfitName(): Text[100]
    begin
        exit(FinancialProfitTok);
    end;

    procedure InterestReceiptBankPost(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestReceiptBankPostName()));
    end;

    procedure InterestReceiptBankPostName(): Text[100]
    begin
        exit(InterestReceiptBankPostTok);
    end;

    procedure IntReceivedFinAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntReceivedFinAssetsName()));
    end;

    procedure IntReceivedFinAssetsName(): Text[100]
    begin
        exit(IntReceivedFinAssetsTok);
    end;

    procedure FinChargesRec(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinChargesRecName()));
    end;

    procedure FinChargesRecName(): Text[100]
    begin
        exit(FinChargesRecTok);
    end;

    procedure TotalFinIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFinIncomeName()));
    end;

    procedure TotalFinIncomeName(): Text[100]
    begin
        exit(TotalFinIncomeTok);
    end;

    procedure Depreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationName()));
    end;

    procedure DepreciationName(): Text[100]
    begin
        exit(DepreciationTok);
    end;

    procedure DepFinAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepFinAssetsName()));
    end;

    procedure DepFinAssetsName(): Text[100]
    begin
        exit(DepFinAssetsTok);
    end;

    procedure DepInvestment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepInvestmentName()));
    end;

    procedure DepInvestmentName(): Text[100]
    begin
        exit(DepInvestmentTok);
    end;

    procedure DepMobileFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepMobileFixedAssetsName()));
    end;

    procedure DepMobileFixedAssetsName(): Text[100]
    begin
        exit(DepMobileFixedAssetsTok);
    end;

    procedure DepCommercialProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepCommercialPropertyName()));
    end;

    procedure DepCommercialPropertyName(): Text[100]
    begin
        exit(DepCommercialPropertyTok);
    end;

    procedure DepIntangibleFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepIntangibleFixedAssetsName()));
    end;

    procedure DepIntangibleFixedAssetsName(): Text[100]
    begin
        exit(DepIntangibleFixedAssetsTok);
    end;

    procedure DepStartUpExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepStartUpExpensesName()));
    end;

    procedure DepStartUpExpensesName(): Text[100]
    begin
        exit(DepStartUpExpensesTok);
    end;

    procedure TotalDepreciations(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalDepreciationsName()));
    end;

    procedure TotalDepreciationsName(): Text[100]
    begin
        exit(TotalDepreciationsTok);
    end;

    procedure TotalOtherOperatingExpensesEndTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherOperatingExpensesEndTotalName()));
    end;

    procedure TotalOtherOperatingExpensesEndTotalName(): Text[100]
    begin
        exit(TotalOtherOperatingExpensesEndTotalTok);
    end;

    procedure OtherOperatingIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherOperatingIncomeName()));
    end;

    procedure OtherOperatingIncomeName(): Text[100]
    begin
        exit(OtherOperatingIncomeTok);
    end;

    procedure SubsidiaryIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubsidiaryIncomeName()));
    end;

    procedure SubsidiaryIncomeName(): Text[100]
    begin
        exit(SubsidiaryIncomeTok);
    end;

    procedure SubsidiaryExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubsidiaryExpensesName()));
    end;

    procedure SubsidiaryExpensesName(): Text[100]
    begin
        exit(SubsidiaryExpensesTok);
    end;

    procedure IncomeFromFinAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeFromFinAssetsName()));
    end;

    procedure IncomeFromFinAssetsName(): Text[100]
    begin
        exit(IncomeFromFinAssetsTok);
    end;

    procedure ExpensesFromFinAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExpensesFromFinAssetsName()));
    end;

    procedure ExpensesFromFinAssetsName(): Text[100]
    begin
        exit(ExpensesFromFinAssetsTok);
    end;

    procedure PropertyIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PropertyIncomeName()));
    end;

    procedure PropertyIncomeName(): Text[100]
    begin
        exit(PropertyIncomeTok);
    end;

    procedure PropertyExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PropertyExpensesName()));
    end;

    procedure PropertyExpensesName(): Text[100]
    begin
        exit(PropertyExpensesTok);
    end;

    procedure GainFromSaleOfFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainFromSaleOfFixedAssetsName()));
    end;

    procedure GainFromSaleOfFixedAssetsName(): Text[100]
    begin
        exit(GainFromSaleOfFixedAssetsTok);
    end;

    procedure GainLossFromSaleOfAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainLossFromSaleOfAssetsName()));
    end;

    procedure GainLossFromSaleOfAssetsName(): Text[100]
    begin
        exit(GainLossFromSaleOfAssetsTok);
    end;

    procedure TotalOtherOperatingIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOtherOperatingIncomeName()));
    end;

    procedure TotalOtherOperatingIncomeName(): Text[100]
    begin
        exit(TotalOtherOperatingIncomeTok);
    end;

    procedure NRNonOperatingTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NRNonOperatingTaxName()));
    end;

    procedure NRNonOperatingTaxName(): Text[100]
    begin
        exit(NRNonOperatingTaxTok);
    end;

    procedure NonRegularIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonRegularIncomeName()));
    end;

    procedure NonRegularIncomeName(): Text[100]
    begin
        exit(NonRegularIncomeTok);
    end;

    procedure NonRegularExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonRegularExpensesName()));
    end;

    procedure NonRegularExpensesName(): Text[100]
    begin
        exit(NonRegularExpensesTok);
    end;

    procedure NonOperatingIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonOperatingIncomeName()));
    end;

    procedure NonOperatingIncomeName(): Text[100]
    begin
        exit(NonOperatingIncomeTok);
    end;

    procedure NonOperatingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NonOperatingExpensesName()));
    end;

    procedure NonOperatingExpensesName(): Text[100]
    begin
        exit(NonOperatingExpensesTok);
    end;

    procedure GainCapitalTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainCapitalTaxName()));
    end;

    procedure GainCapitalTaxName(): Text[100]
    begin
        exit(GainCapitalTaxTok);
    end;

    procedure TotalNRNOTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalNRNOTaxName()));
    end;

    procedure TotalNRNOTaxName(): Text[100]
    begin
        exit(TotalNRNOTaxTok);
    end;

    procedure GainLossLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainLossLiabilitiesName()));
    end;

    procedure GainLossLiabilitiesName(): Text[100]
    begin
        exit(GainLossLiabilitiesTok);
    end;

    procedure Closing(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ClosingName()));
    end;

    procedure ClosingName(): Text[100]
    begin
        exit(ClosingTok);
    end;

    procedure IncomeStatement(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeStatementName()));
    end;

    procedure IncomeStatementName(): Text[100]
    begin
        exit(IncomeStatementTok);
    end;

    procedure OpeningBalance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OpeningBalanceName()));
    end;

    procedure OpeningBalanceName(): Text[100]
    begin
        exit(OpeningBalanceTok);
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        PostAccTok: Label 'Post Acc.', MaxLength = 100;
        BankCreditTok: Label 'Bank Credit', MaxLength = 100;
        BankCreditForeignCurrencyTok: Label 'Bank Credit Foreign Currency', MaxLength = 100;
        BankCreditEurTok: Label 'Bank Credit EUR', MaxLength = 100;
        BankCreditUsdTok: Label 'Bank Credit USD', MaxLength = 100;
        BankCreditDkkTok: Label 'Bank Credit DKK', MaxLength = 100;
        FixedTermDepInvTok: Label 'Fixed-term Dep. Inv.', MaxLength = 100;
        MoneyTransAccountTok: Label 'Money Trans. Account', MaxLength = 100;
        TotalLiquidAssetsTok: Label 'Total Liquid Assets', MaxLength = 100;
        AcctsReceivableTok: Label 'Accts Receivable', MaxLength = 100;
        ArsFromShipAndServicesTok: Label 'ARs from Ship. and Services', MaxLength = 100;
        CustomerCreditDomesticTok: Label 'Customer Credit Domestic', MaxLength = 100;
        CustomerCreditEuTok: Label 'Customer Credit EU', MaxLength = 100;
        CustomerCreditForeignTok: Label 'Customer Credit Foreign', MaxLength = 100;
        CustomerCreditIcTok: Label 'Customer Credit IC', MaxLength = 100;
        AcctsRecWithShareholdersTok: Label 'Accts Rec. with Shareholders', MaxLength = 100;
        OtherStAcctsReceivablesTok: Label 'Other ST Accts Receivables', MaxLength = 100;
        StAcctsReceivablesTok: Label 'ST Accts Receivables', MaxLength = 100;
        StLoanShareholderTok: Label 'ST Loan Shareholder', MaxLength = 100;
        AcctsReceivablesOnGovLocTok: Label 'Accts Receivables on Gov. Loc.', MaxLength = 100;
        PurchVatMatDlTok: Label 'Purch. VAT Mat./DL', MaxLength = 100;
        PurchVatInvOperatingExpTok: Label 'Purch.VAT Inv./Operating Exp.', MaxLength = 100;
        PurchVatOnImports100PercentTok: Label '100% Purch. VAT on Imports', MaxLength = 100;
        CreditWithholdingTaxTok: Label 'Credit withholding Tax', MaxLength = 100;
        RemainStAcctsReceivablesTok: Label 'Remain. ST Accts Receivables', MaxLength = 100;
        WirCreditTok: Label 'WIR Credit', MaxLength = 100;
        VendorPrepaymentsVat0PercentTok: Label 'Vendor Prepayments VAT 0%', MaxLength = 100;
        VendorPrepaymentsVat80PercentTok: Label 'Vendor Prepayments VAT 8.0%', MaxLength = 100;
        TotAcctsReceivablesTok: Label 'Tot. Accts Receivables', MaxLength = 100;
        InventoriesWipTok: Label 'Inventories, WIP', MaxLength = 100;
        InvCommercialGoodsTok: Label 'Inv. Commercial Goods', MaxLength = 100;
        InvCommercialGoodsInterimTok: Label 'Inv. Commercial Goods(Interim)', MaxLength = 100;
        WbInvCommercialGoodsTok: Label 'WB Inv. Commercial Goods', MaxLength = 100;
        InvRawMaterialsTok: Label 'Inv. Raw Materials', MaxLength = 100;
        InvRawMaterialsInterimTok: Label 'Inv. Raw Materials (Interim)', MaxLength = 100;
        WbInvRawMaterialsTok: Label 'WB Inv. Raw Materials', MaxLength = 100;
        InvFinishedProductsTok: Label 'Inv. Finished Products', MaxLength = 100;
        InvFinProductsInterimTok: Label 'Inv. Fin. Products (Interim)', MaxLength = 100;
        WbInvFinishProductsTok: Label 'WB Inv. Finish Products', MaxLength = 100;
        StartedProjectsTok: Label 'Started Projects', MaxLength = 100;
        WbStartedProjectsTok: Label 'WB Started Projects', MaxLength = 100;
        StartedProductionOrdersTok: Label 'Started Production Orders', MaxLength = 100;
        TotalInventoriesWipTok: Label 'Total Inventories, WIP', MaxLength = 100;
        AccruedIncomeTok: Label 'Accrued Income', MaxLength = 100;
        PrepaidExpensesTok: Label 'Prepaid Expenses', MaxLength = 100;
        EarningsNotYetReceivedTok: Label 'Earnings not yet received', MaxLength = 100;
        TotalActiveDeferredItemsTok: Label 'Total Active Deferred Items', MaxLength = 100;
        TotalCurrentAssetsTok: Label 'Total Current Assets', MaxLength = 100;
        FinancialAssetsTok: Label 'Financial Assets', MaxLength = 100;
        SecuritiesTok: Label 'Securities', MaxLength = 100;
        FaAccountTok: Label 'FA Account', MaxLength = 100;
        InvestmentsTok: Label 'Investments', MaxLength = 100;
        LtAcctsReceivablesTok: Label 'LT Accts Receivables', MaxLength = 100;
        LoanShareholderTok: Label 'Loan Shareholder', MaxLength = 100;
        TotalFinancialAssetsTok: Label 'Total Financial Assets', MaxLength = 100;
        MobileFixedAssetsTok: Label 'Mobile Fixed Assets', MaxLength = 100;
        MachinesAndEquipmentTok: Label 'Machines and Equipment', MaxLength = 100;
        WbMachinesAndEquipmentTok: Label 'WB Machines and Equipment', MaxLength = 100;
        BusinessFurnitureTok: Label 'Business Furniture', MaxLength = 100;
        WbBusinessFurnitureTok: Label 'WB Business Furniture', MaxLength = 100;
        OfficeMachinesTok: Label 'Office Machines', MaxLength = 100;
        ItHardwareAndSoftwareTok: Label 'IT Hardware and Software', MaxLength = 100;
        WbOfficeMachinesAndItTok: Label 'WB Office Machines and IT', MaxLength = 100;
        WbVehiclesTok: Label 'WB Vehicles', MaxLength = 100;
        VehiclesEquipmentTok: Label 'Vehicles, Equipment', MaxLength = 100;
        WbVehiclesEquipmentTok: Label 'WB Vehicles, Equipment', MaxLength = 100;
        TotalMobileFixedAssetsTok: Label 'Total Mobile Fixed Assets', MaxLength = 100;
        RealPropertyFaTok: Label 'Real Property FA', MaxLength = 100;
        RealEstateTok: Label 'Real Estate', MaxLength = 100;
        WbRealEstateTok: Label 'WB Real Estate', MaxLength = 100;
        TotalRealPropertyFaTok: Label 'Total Real Property FA', MaxLength = 100;
        IntangibleFaTok: Label 'Intangible FA', MaxLength = 100;
        PatentsKnowledgeRecipesTok: Label 'Patents, Knowledge, Recipes', MaxLength = 100;
        BrandsPrototypesModelsPlansTok: Label 'Brands,Prototypes,Models,Plans', MaxLength = 100;
        TotalIntangibleFaTok: Label 'Total Intangible FA', MaxLength = 100;
        TotalFixedAssetsTok: Label 'Total Fixed Assets', MaxLength = 100;
        ActiveCorrectingEntriesTok: Label 'Active Correcting Entries', MaxLength = 100;
        StartUpExpensesTok: Label 'Start-up Expenses', MaxLength = 100;
        ExcludedCapitalStockTok: Label 'Excluded Capital Stock', MaxLength = 100;
        TotalActCorrectingEntriesTok: Label 'Total Act. Correcting Entries', MaxLength = 100;
        NonOperationalAssetsHeadingTok: Label 'Non-operational Assets, Heading', MaxLength = 100;
        NonOperationalAssetsTok: Label 'Non-operational Assets', MaxLength = 100;
        TotalAssetsTok: Label 'Total Assets', MaxLength = 100;
        StLiabShipServTok: Label 'ST Liab. Ship/Serv.', MaxLength = 100;
        VendorsDomesticTok: Label 'Vendors Domestic', MaxLength = 100;
        VendorsEuTok: Label 'Vendors EU', MaxLength = 100;
        VendorsForeignTok: Label 'Vendors Foreign', MaxLength = 100;
        VendorsIcTok: Label 'Vendors IC', MaxLength = 100;
        CustomerPrepaymentsVat0PercentTok: Label 'Customer Prepayments VAT 0%', MaxLength = 100;
        CustomerPrepaymentsVat80PercentTok: Label 'Customer Prepayments VAT 8.0%', MaxLength = 100;
        BankOverdraftTok: Label 'Bank Overdraft', MaxLength = 100;
        StLoanToShareholdersTok: Label 'ST Loan to Shareholders', MaxLength = 100;
        OtherShortTermLiabilitiesTok: Label 'Other Short-term Liabilities', MaxLength = 100;
        VatOwedTok: Label 'VAT Owed', MaxLength = 100;
        VendorVatTok: Label 'Vendor VAT', MaxLength = 100;
        DividendsDueTok: Label 'Dividends Due', MaxLength = 100;
        LiabilitiesAccruedExpensesTok: Label 'Liabilities Accrued Expenses', MaxLength = 100;
        UnpaidExpensesTok: Label 'Unpaid Expenses', MaxLength = 100;
        EarningsReceivedInAdvanceTok: Label 'Earnings received in advance', MaxLength = 100;
        WarrantyReserveTok: Label 'Warranty Reserve', MaxLength = 100;
        TaxationReserveTok: Label 'Taxation Reserve', MaxLength = 100;
        TotalShortTermLiabilitiesTok: Label 'Total Short-term Liabilities', MaxLength = 100;
        LongTermLoansTok: Label 'Long-term Loans', MaxLength = 100;
        BankLoansTok: Label 'Bank Loans', MaxLength = 100;
        MortgageLoansTok: Label 'Mortgage Loans', MaxLength = 100;
        LongTermReservesTok: Label 'Long-term Reserves', MaxLength = 100;
        LtReserveRepairsTok: Label 'LT Reserve Repairs', MaxLength = 100;
        LongTermWarrantyWorkTok: Label 'Long-term Warranty Work', MaxLength = 100;
        LtReserveDeferredTaxTok: Label 'LT Reserve Deferred Tax', MaxLength = 100;
        TotalLongTermLiabilitiesTok: Label 'Total Long-term Liabilities', MaxLength = 100;
        TotalLiabilitiesTok: Label 'Total Liabilities', MaxLength = 100;
        ShareholdersEquityTok: Label 'Shareholders Equity', MaxLength = 100;
        CapitalTok: Label 'Capital', MaxLength = 100;
        ReservesAndRetainedEarningsTok: Label 'Reserves and Retained Earnings', MaxLength = 100;
        LegalReservesTok: Label 'Legal Reserves', MaxLength = 100;
        StatutoryReservesTok: Label 'Statutory Reserves', MaxLength = 100;
        FreeReservesTok: Label 'Free Reserves', MaxLength = 100;
        RetEarningsLossCarriedFwdTok: Label 'Ret. Earnings/Loss Carried Fwd', MaxLength = 100;
        RetainedEarningsLossTok: Label 'Retained Earnings/Loss', MaxLength = 100;
        AnnualEarningsLossTok: Label 'Annual Earnings/Loss', MaxLength = 100;
        EarnedCapitalTok: Label 'Earned Capital', MaxLength = 100;
        TotalShareholdersEquityTok: Label 'Total Shareholders Equity', MaxLength = 100;
        TotalLiabilitiesEndTotalTok: Label 'Total Liabilities, End Total', MaxLength = 100;
        GainLossIncomeTok: Label 'Gain/Loss, Income', MaxLength = 100;
        OpIncomeShipServTok: Label 'OP. INCOME SHIP/SERV.', MaxLength = 100;
        ProdEarningsTok: Label 'Prod. Earnings', MaxLength = 100;
        ProdEarningsDomesticTok: Label 'Prod. Earnings Domestic', MaxLength = 100;
        ProdEarningsEuropeTok: Label 'Prod. Earnings Europe', MaxLength = 100;
        ProdEarningsInternatTok: Label 'Prod. Earnings Internat.', MaxLength = 100;
        InvChangeFinishedProductsTok: Label 'Inv. Change Finished Products', MaxLength = 100;
        InvChgFinishedProdProvTok: Label 'Inv. Chg Finished Prod.(Prov.)', MaxLength = 100;
        TradeEarningTok: Label 'Trade Earning', MaxLength = 100;
        TradeDomesticTok: Label 'Trade Domestic', MaxLength = 100;
        TradeEuropeTok: Label 'Trade Europe', MaxLength = 100;
        TradeInternatTok: Label 'Trade Internat.', MaxLength = 100;
        InvChangeCommGoodsTok: Label 'Inv. Change Comm. Goods', MaxLength = 100;
        InvChangeTradeProvTok: Label 'Inv. Change Trade (Prov.)', MaxLength = 100;
        ServiceEarningsTok: Label 'Service Earnings', MaxLength = 100;
        ServiceEarningsDomesticTok: Label 'Service Earnings Domestic', MaxLength = 100;
        ServiceEarningsEuropeTok: Label 'Service Earnings Europe', MaxLength = 100;
        ServiceEarningsInternatTok: Label 'Service Earnings Internat.', MaxLength = 100;
        ProjectEarningsTok: Label 'Project Earnings', MaxLength = 100;
        JobSalesAppliedAccountTok: Label 'Job Sales Applied Account', MaxLength = 100;
        ConsultancyEarningsTok: Label 'Consultancy Earnings', MaxLength = 100;
        InventoryChangeReqWorkTok: Label 'Inventory Change Req. Work', MaxLength = 100;
        OtherEarningsHeadingTok: Label 'Other Earnings, Heading', MaxLength = 100;
        OtherEarningsTok: Label 'Other Earnings', MaxLength = 100;
        OwnContributionOwnUseTok: Label 'Own Contribution, Own Use', MaxLength = 100;
        InventoryChangesTok: Label 'Inventory Changes', MaxLength = 100;
        DropInEarningsTok: Label 'Drop in Earnings', MaxLength = 100;
        CashDiscountsTok: Label 'Cash Discounts', MaxLength = 100;
        DiscountsTok: Label 'Discounts', MaxLength = 100;
        LossFromAccountsRecTok: Label 'Loss from Accounts Rec.', MaxLength = 100;
        UnrealizedExchRateAdjmtsTok: Label 'Unrealized Exch. Rate Adjmts.', MaxLength = 100;
        RealizedExchangeRateAdjmtsTok: Label 'Realized Exchange Rate Adjmts.', MaxLength = 100;
        RoundingDifferencesSalesTok: Label 'Rounding Differences Sales', MaxLength = 100;
        TotalOpIncomeShipServTok: Label 'Total Op. Income Ship/Serv.', MaxLength = 100;
        CostGoodsMaterialDlTok: Label 'COST GOODS, MATERIAL, DL.', MaxLength = 100;
        CostOfMaterialsTok: Label 'Cost of Materials', MaxLength = 100;
        CostOfMaterialDomesticTok: Label 'Cost of Material Domestic', MaxLength = 100;
        CostOfMaterialsEuropeTok: Label 'Cost of Materials Europe', MaxLength = 100;
        CostOfMaterialsInternatTok: Label 'Cost of Materials Internat.', MaxLength = 100;
        VariancePurchMaterialsTok: Label 'Variance Purch. Materials', MaxLength = 100;
        SubcontractingTok: Label 'Subcontracting', MaxLength = 100;
        OverheadCostsMatProdTok: Label 'Overhead Costs Mat./Prod.', MaxLength = 100;
        CostOfCommercialGoodsTok: Label 'Cost of Commercial Goods', MaxLength = 100;
        CostOfCommGoodsDomesticTok: Label 'Cost of Comm. Goods Domestic', MaxLength = 100;
        CostOfCommGoodsEuropeTok: Label 'Cost of Comm. Goods Europe', MaxLength = 100;
        CostOfCommGoodsIntlTok: Label 'Cost of Comm. Goods Intl.', MaxLength = 100;
        VariancePurchTradeTok: Label 'Variance Purch. Trade', MaxLength = 100;
        OverheadCostsCommGoodTok: Label 'Overhead Costs Comm. Good', MaxLength = 100;
        CostOfSubcontractsTok: Label 'Cost of Subcontracts', MaxLength = 100;
        SubcontrOfSpOperationsTok: Label 'Subcontr. of SP Operations', MaxLength = 100;
        JobCostsWipTok: Label 'Job Costs WIP', MaxLength = 100;
        OtherCostsTok: Label 'Other Costs', MaxLength = 100;
        EnergyCostsCOGSTok: Label 'Energy Costs, COGS', MaxLength = 100;
        PackagingCostsTok: Label 'Packaging Costs', MaxLength = 100;
        DirectPurchCostsTok: Label 'Direct Purch. Costs', MaxLength = 100;
        InvChangeProductionMatTok: Label 'Inv. Change Production Mat.', MaxLength = 100;
        InvChangeCommGoodsCOGSTok: Label 'Inv. Change Comm. Goods, COGS', MaxLength = 100;
        InvChangeProjectsTok: Label 'Inv. Change Projects', MaxLength = 100;
        MaterialLossTok: Label 'Material Loss', MaxLength = 100;
        GoodsLossTok: Label 'Goods Loss', MaxLength = 100;
        MaterialVarianceProductionTok: Label 'Material Variance Production', MaxLength = 100;
        CapacityVarianceProductionTok: Label 'Capacity Variance Production', MaxLength = 100;
        VarianceMatOverheadCostsTok: Label 'Variance Mat. Overhead Costs', MaxLength = 100;
        VarianceCapOverheadCostsTok: Label 'Variance Cap. Overhead Costs', MaxLength = 100;
        VarianceSubcontractingTok: Label 'Variance Subcontracting', MaxLength = 100;
        CostReductionsTok: Label 'Cost Reductions', MaxLength = 100;
        PurchaseDiscTok: Label 'Purchase Disc.', MaxLength = 100;
        CostReductionDiscountTok: Label 'Cost Reduction, Discount', MaxLength = 100;
        UnrealExchangeRateAdjmtsTok: Label 'Unreal. Exchange Rate Adjmts.', MaxLength = 100;
        RealizedExchangeRateAdjmtsCOGSTok: Label 'Realized Exchange Rate Adjmts., COGS', MaxLength = 100;
        RoundingDifferencesPurchaseTok: Label 'Rounding Differences Purchase', MaxLength = 100;
        TotalCostsGoodsMatDlTok: Label 'Total Costs Goods, Mat, Dl.', MaxLength = 100;
        PersonnelCostsTok: Label 'PERSONNEL COSTS', MaxLength = 100;
        WagesProductionTok: Label 'Wages Production', MaxLength = 100;
        WagesSalesTok: Label 'Wages Sales', MaxLength = 100;
        WagesManagementTok: Label 'Wages Management', MaxLength = 100;
        AhvIvEoAlvTok: Label 'AHV, IV, EO, ALV', MaxLength = 100;
        PensionPlanningTok: Label 'Pension Planning', MaxLength = 100;
        CasualtyInsuranceTok: Label 'Casualty Insurance', MaxLength = 100;
        HealthInsuranceTok: Label 'Health Insurance', MaxLength = 100;
        IncomeTaxTok: Label 'Income tax', MaxLength = 100;
        TrngAndContinuingEdTok: Label 'Trng and Continuing Ed.', MaxLength = 100;
        ReimbursementOfExpensesTok: Label 'Reimbursement of Expenses', MaxLength = 100;
        OtherPersonnelCostsTok: Label 'Other Personnel Costs', MaxLength = 100;
        TotalPersonnelCostsTok: Label 'Total Personnel Costs', MaxLength = 100;
        PremisesCostsTok: Label 'Premises Costs', MaxLength = 100;
        RentTok: Label 'Rent', MaxLength = 100;
        RentalValueForUsedPropertyTok: Label 'Rental Value for Used Property', MaxLength = 100;
        AddCostsTok: Label 'Add. Costs', MaxLength = 100;
        MaintOfBusinessPremisesTok: Label 'Maint. of Business Premises', MaxLength = 100;
        TotalPremisesCostsTok: Label 'Total Premises Costs', MaxLength = 100;
        MaintRepairsTok: Label 'Maint., Repairs', MaxLength = 100;
        MaintProductionPlantsTok: Label 'Maint. Production Plants', MaxLength = 100;
        MaintSalesEquipmentTok: Label 'Maint. Sales Equipment', MaxLength = 100;
        MaintStorageFacilitiesTok: Label 'Maint. Storage Facilities', MaxLength = 100;
        MaintOfficeEquipmentTok: Label 'Maint. Office Equipment', MaxLength = 100;
        LeasingMobileFixedAssetsTok: Label 'Leasing Mobile Fixed Assets', MaxLength = 100;
        TotalMaintRepairsTok: Label 'Total Maint., Repairs', MaxLength = 100;
        VehicleAndTransportCostsTok: Label 'Vehicle and Transport Costs', MaxLength = 100;
        VehicleMaintTok: Label 'Vehicle Maint.', MaxLength = 100;
        OpMaterialsTok: Label 'Op. Materials', MaxLength = 100;
        AutoInsuranceTok: Label 'Auto Insurance', MaxLength = 100;
        TransportTaxRatesTok: Label 'Transport Tax, Rates', MaxLength = 100;
        TransportCostsTok: Label 'Transport Costs', MaxLength = 100;
        ShippingChargeCustomerTok: Label 'Shipping Charge Customer', MaxLength = 100;
        TotalVehicleAndTransportTok: Label 'Total Vehicle and Transport', MaxLength = 100;
        PropertyInsuranceRatesTok: Label 'Property Insurance, Rates', MaxLength = 100;
        PropertyInsuranceTok: Label 'Property Insurance', MaxLength = 100;
        OperatingLiabilityTok: Label 'Operating Liability', MaxLength = 100;
        DowntimeInsuranceTok: Label 'Downtime Insurance.', MaxLength = 100;
        TaxRatesTok: Label 'Tax, Rates', MaxLength = 100;
        PermitsPatentsTok: Label 'Permits, Patents', MaxLength = 100;
        TotalInsuranceFeesTok: Label 'Total Insurance, Fees', MaxLength = 100;
        EnergyWasteCostsTok: Label 'Energy, Waste Costs', MaxLength = 100;
        EnergyCostsTok: Label 'Energy Costs', MaxLength = 100;
        WasteCostsTok: Label 'Waste Costs', MaxLength = 100;
        TotalEnergyWasteTok: Label 'Total Energy, Waste', MaxLength = 100;
        ManagementInformationCostsTok: Label 'Management, Information Costs', MaxLength = 100;
        AdministrativeCostsTok: Label 'Administrative Costs', MaxLength = 100;
        OfficeMatPrintSuppliesTok: Label 'Office Mat., Print Supplies', MaxLength = 100;
        TechDocTok: Label 'Tech. Doc.', MaxLength = 100;
        CommunicationTelephoneTok: Label 'Communication, Telephone', MaxLength = 100;
        DeductionsTok: Label 'Deductions', MaxLength = 100;
        AccountingConsultancyTok: Label 'Accounting, Consultancy', MaxLength = 100;
        BoardOfDirectorsGvRevisionTok: Label 'Board of Directors,GV,Revision', MaxLength = 100;
        InformationCostsTok: Label 'Information Costs', MaxLength = 100;
        ItLeasingTok: Label 'IT Leasing', MaxLength = 100;
        ItProgramLicensesMaintTok: Label 'IT Program Licenses, Maint.', MaxLength = 100;
        ItSuppliesTok: Label 'IT Supplies', MaxLength = 100;
        ConsultingAndDevelopmentTok: Label 'Consulting and Development', MaxLength = 100;
        TotalAdministrationItTok: Label 'Total Administration, IT', MaxLength = 100;
        AdvertisingCostsTok: Label 'Advertising Costs', MaxLength = 100;
        AdvertisementsAndMediaTok: Label 'Advertisements and Media', MaxLength = 100;
        AdMaterialsTok: Label 'Ad. Materials', MaxLength = 100;
        ExhibitsTok: Label 'Exhibits', MaxLength = 100;
        TravelCostsCustomerServiceTok: Label 'Travel Costs, Customer Service', MaxLength = 100;
        AdvertContribSponsoringTok: Label 'Advert. Contrib., Sponsoring', MaxLength = 100;
        PublicRelationsPrTok: Label 'Public Relations / PR', MaxLength = 100;
        AdConsultancyMarketAnalyTok: Label 'Ad. Consultancy, Market Analy.', MaxLength = 100;
        TotalAdvertisingCostsTok: Label 'Total Advertising Costs', MaxLength = 100;
        OtherOpExpensesTok: Label 'Other Op. Expenses', MaxLength = 100;
        EconomicInformationTok: Label 'Economic Information', MaxLength = 100;
        OperReliabilityMonitoringTok: Label 'Oper. Reliability, Monitoring', MaxLength = 100;
        ResearchAndDevelopmentTok: Label 'Research and Development', MaxLength = 100;
        MiscCostsTok: Label 'Misc. Costs', MaxLength = 100;
        TotalOtherOperatingExpensesTok: Label 'Total Other Operating Expenses', MaxLength = 100;
        FinancialIncomeTok: Label 'Financial Income', MaxLength = 100;
        FinancialExpensesTok: Label 'Financial Expenses', MaxLength = 100;
        BankInterestRateCostsTok: Label 'Bank Interest Rate Costs', MaxLength = 100;
        MortgageIntRateCostsTok: Label 'Mortgage Int. Rate Costs', MaxLength = 100;
        BankAndPcCostsTok: Label 'Bank and PC Costs', MaxLength = 100;
        FinancialProfitTok: Label 'Financial Profit', MaxLength = 100;
        InterestReceiptBankPostTok: Label 'Interest Receipt Bank/Post', MaxLength = 100;
        IntReceivedFinAssetsTok: Label 'Int. Received Fin. Assets', MaxLength = 100;
        FinChargesRecTok: Label 'Fin. Charges Rec.', MaxLength = 100;
        TotalFinIncomeTok: Label 'Total Fin. Income', MaxLength = 100;
        DepreciationTok: Label 'Depreciation', MaxLength = 100;
        DepFinAssetsTok: Label 'Dep. Fin. Assets', MaxLength = 100;
        DepInvestmentTok: Label 'Dep. Investment', MaxLength = 100;
        DepMobileFixedAssetsTok: Label 'Dep. Mobile Fixed Assets', MaxLength = 100;
        DepCommercialPropertyTok: Label 'Dep. Commercial Property', MaxLength = 100;
        DepIntangibleFixedAssetsTok: Label 'Dep. Intangible Fixed Assets', MaxLength = 100;
        DepStartUpExpensesTok: Label 'Dep. Start-up Expenses', MaxLength = 100;
        TotalDepreciationsTok: Label 'Total Depreciations', MaxLength = 100;
        TotalOtherOperatingExpensesEndTotalTok: Label 'Total Other Operating Expenses, End Total', MaxLength = 100;
        OtherOperatingIncomeTok: Label 'OTHER OPERATING INCOME', MaxLength = 100;
        SubsidiaryIncomeTok: Label 'Subsidiary Income', MaxLength = 100;
        SubsidiaryExpensesTok: Label 'Subsidiary Expenses', MaxLength = 100;
        IncomeFromFinAssetsTok: Label 'Income from Fin. Assets', MaxLength = 100;
        ExpensesFromFinAssetsTok: Label 'Expenses from Fin. Assets', MaxLength = 100;
        PropertyIncomeTok: Label 'Property Income', MaxLength = 100;
        PropertyExpensesTok: Label 'Property Expenses', MaxLength = 100;
        GainFromSaleOfFixedAssetsTok: Label 'Gain from Sale of Fixed Assets', MaxLength = 100;
        GainLossFromSaleOfAssetsTok: Label 'Gain/Loss from Sale of Assets', MaxLength = 100;
        TotalOtherOperatingIncomeTok: Label 'Total Other Operating Income', MaxLength = 100;
        NRNonOperatingTaxTok: Label 'N.R.., NON-OPERATING, TAX', MaxLength = 100;
        NonRegularIncomeTok: Label 'Non-regular Income', MaxLength = 100;
        NonRegularExpensesTok: Label 'Non-regular Expenses', MaxLength = 100;
        NonOperatingIncomeTok: Label 'Non-operating Income', MaxLength = 100;
        NonOperatingExpensesTok: Label 'Non-operating Expenses', MaxLength = 100;
        GainCapitalTaxTok: Label 'Gain/Capital Tax', MaxLength = 100;
        TotalNRNOTaxTok: Label 'Total N.R. N.O., Tax', MaxLength = 100;
        GainLossLiabilitiesTok: Label 'Gain/Loss', MaxLength = 100;
        ClosingTok: Label 'CLOSING', MaxLength = 100;
        IncomeStatementTok: Label 'Income Statement', MaxLength = 100;
        OpeningBalanceTok: Label 'Opening Balance', MaxLength = 100;
}