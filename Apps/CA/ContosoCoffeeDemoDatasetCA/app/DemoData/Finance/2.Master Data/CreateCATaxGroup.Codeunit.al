codeunit 27011 "Create CA Tax Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        ContosoCATax: Codeunit "Contoso CA Tax";
        CreateResource: Codeunit "Create Resource";
    begin
        ContosoCATax.SetOverwriteData(true);
        ContosoCATax.InsertTaxGroup(Labor(), LaborLbl);
        ContosoCATax.InsertTaxGroup(NonTaxable(), NonTaxableLbl);
        ContosoCATax.InsertTaxGroup(Taxable(), TaxableLbl);
        ContosoCATax.SetOverwriteData(false);

        UpdateTaxGroupOnResource(CreateResource.Katherine(), Labor());
        UpdateTaxGroupOnResource(CreateResource.Lina(), Labor());
        UpdateTaxGroupOnResource(CreateResource.Marty(), Labor());
        UpdateTaxGroupOnResource(CreateResource.Terry(), Labor());
    end;

    procedure UpdateTaxGroupOnGL()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateCAGLAccounts: Codeunit "Create CA GL Accounts";
    begin
        UpdateTaxGroupOnGLAccount(CreateGLAccount.Cash(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.Bonds(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.ResaleItems(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.ResaleItemsInterim(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.CostofResaleSoldInterim(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.FinishedGoods(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.FinishedGoodsInterim(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.RawMaterials(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.RawMaterialsInterim(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.CostofRawMatSoldInterim(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.PrimoInventory(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.WIPJobSales(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.InvoicedJobSales(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.WIPJobCosts(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.AccruedJobCosts(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.Vehicles(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.AccumDepreciationVehicles(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.OperatingEquipment(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.AccumDeprOperEquip(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.LandandBuildings(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.RevolvingCredit(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.VendorsDomestic(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.VendorsForeign(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.InvAdjmtInterimRawMat(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.InvAdjmtInterimRetail(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.PayrollTaxesPayable(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.VacationCompensationPayable(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.DividendsfortheFiscalYear(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.CorporateTaxesPayable(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.LongTermBankLoans(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.Mortgage(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.DeferredTaxes(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.CapitalStock(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.RetainedEarnings(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.SalesRetailDom(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.SalesRetailExport(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.JobSalesAppliedRetail(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.JobSalesAdjmtRetail(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.SalesRawMaterialsDom(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.SalesRawMaterialsExport(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.JobSalesAdjmtRawMat(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.SalesResourcesDom(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.SalesResourcesExport(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.JobSalesAdjmtResources(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.SalesOtherJobExpenses(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.JobSales(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.CustomersDomestic(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.InterestonBankBalances(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.FinanceChargesfromCustomers(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.PmtDiscReceivedDecreases(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.PaymentDiscountsReceived(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.InvoiceRounding(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.ApplicationRounding(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.PaymentToleranceReceived(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.PmtTolReceivedDecreases(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.ConsultingFeesDom(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.FeesandChargesRecDom(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.DiscountGranted(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.JobCosts(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.CostofResourcesUsed(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.JobCostAdjmtResources(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.JobCostAppliedResources(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.PurchRawMaterialsDom(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.PurchRawMaterialsExport(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.DiscReceivedRawMaterials(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.DeliveryExpensesRawMat(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.InventoryAdjmtRawMat(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.JobCostAdjmtRawMaterials(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.CostofRawMaterialsSold(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.PurchRetailDom(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.PurchRetailExport(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.DiscReceivedRetail(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.InventoryAdjmtRetail(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.DeliveryExpensesRetail(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.JobCostAppliedRetail(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.JobCostAdjmtRetail(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.CostofRetailSold(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.PaymentDiscountsGranted(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.Advertising(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.EntertainmentandPR(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.Travel(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.DeliveryExpenses(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.Wages(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.Salaries(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.RetirementPlanContributions(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.VacationCompensation(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.PayrollTaxes(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.GasolineandMotorOil(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.RegistrationFees(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.RepairsandMaintenance(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.Software(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.ConsultantServices(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.OtherComputerExpenses(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.Cleaning(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.ElectricityandHeating(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.RepairsandMaintenance(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.OfficeSupplies(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.PhoneandFax(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.Postage(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.CashDiscrepancies(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.BadDebtExpenses(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.LegalandAccountingServices(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.OtherCostsofOperations(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.DepreciationBuildings(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.DepreciationEquipment(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.DepreciationVehicles(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.InterestonRevolvingCredit(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.InterestonBankLoans(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.MortgageInterest(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.FinanceChargestoVendors(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.PmtDiscGrantedDecreases(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.PaymentToleranceGranted(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.PaymentDiscountsGranted(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.PmtTolGrantedDecreases(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.UnrealizedFXGains(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.UnrealizedFXLosses(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.RealizedFXGains(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.RealizedFXLosses(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.GAINSANDLOSSES(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.CorporateTax(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.ExtraordinaryIncome(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.ExtraordinaryExpenses(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.BankChecking(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.BankCurrenciesLCY(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.BankCurrenciesFCYUSD(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.BankOperationsCash(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.ShortTermInvestments(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.CanadianTermDeposits(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.OtherMarketableSecurities(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.InterestAccruedOnInvestment(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateGLAccount.CustomersForeign(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.OtherReceivables(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.VendorPrepaymentsServices(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.VendorPrepaymentsRetail(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.AllowanceForFinishedGoodsWriteOffs(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.WipAccountFinishedGoods(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.IntangibleAssets(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.AccAmortnOnIntangibles(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.DeferredRevenue(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.CustomerPrepaymentsServices(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.CustomerPrepaymentsRetail(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.PrepaidServiceContracts(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.AccountsPayableEmployees(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.AccruedPayables(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.IncomeTaxPayable(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.ProvincialSalesTax(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.QSTSalesTaxCollected(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.PurchaseTax(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.GSTHSTSalesTax(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.GSTHSTInputCredits(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.IncomeTaxAccrued(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.QuebecBeerTaxesAccrued(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.AccruedSalariesWages(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.FederalIncomeTaxExpense(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.ProvincialWithholdingPayable(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.FICAPayable(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.MedicarePayable(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.FUTAPayable(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.SUTAPayable(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.EmployeeBenefitsPayable(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.EmploymentInsuranceEmployeeContrib(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.EmploymentInsuranceEmployerContrib(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.CanadaPensionFundEmployeeContrib(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.CanadaPensionFundEmployerContrib(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.QuebecPipPayableEmployee(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.GarnishmentPayable(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.DeferralRevenue(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.ServiceContractSale(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.CostOfCapacities(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.DirectCostAppliedCap(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.OverheadAppliedCap(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.PurchaseVarianceCap(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.JobCostAppliedRawMaterials(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.OverheadAppliedRetail(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.PurchaseVarianceRetail(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.MaterialVariance(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.CapacityVariance(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.SubcontractedVariance(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.CapOverheadVariance(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.MfgOverheadVariance(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.HealthInsurance(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.GroupLifeInsurance(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.WorkersCompensation(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.FourHounderedOneKContributions(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.Taxes(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.StateIncomeTax(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.RevaluationSurplusAdjustments(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.PaymentDiscountsGrantedCOGS(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.RepairsandMaintenanceExpense(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.AccumDepreciationBuildings(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.EmployeesPayable(), Taxable());
        UpdateTaxGroupOnGLAccount(CreateCAGLAccounts.Miscellaneous(), Taxable());
    end;

    local procedure UpdateTaxGroupOnResource(ResourceNo: Code[20]; TaxGroupCode: Code[20])
    var
        Resource: Record Resource;
    begin
        Resource.Get(ResourceNo);

        Resource.Validate("Tax Group Code", TaxGroupCode);
        Resource.Modify(true);
    end;

    local procedure UpdateTaxGroupOnGLAccount(GLAccountNo: Code[20]; TaxGroupCode: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        GlAccount.Get(GLAccountNo);

        GLAccount.Validate("Tax Group Code", TaxGroupCode);
        GLAccount.Modify(true);
    end;

    procedure Labor(): Code[20]
    begin
        exit(LaborTok);
    end;

    procedure NonTaxable(): Code[20]
    begin
        exit(NonTaxableTok);
    end;

    procedure Taxable(): Code[20]
    begin
        exit(TaxableTok);
    end;

    var
        LaborTok: Label 'LABOR', MaxLength = 20, Locked = true;
        NonTaxableTok: Label 'NONTAXABLE', MaxLength = 20, Locked = true;
        TaxableTok: Label 'TAXABLE', MaxLength = 20, Locked = true;
        LaborLbl: Label 'Labor on Job', MaxLength = 100;
        NonTaxableLbl: Label 'Non-taxable Goods and Services', MaxLength = 100;
        TaxableLbl: Label 'Taxable Goods and Services', MaxLength = 100;
}