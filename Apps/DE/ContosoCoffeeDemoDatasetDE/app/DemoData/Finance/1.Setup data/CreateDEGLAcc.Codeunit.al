codeunit 11119 "Create DE GL Acc."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        AddGLAccountforDE();
    end;

    local procedure AddGLAccountforDE()
    var
        GLAccountIndent: Codeunit "G/L Account-Indent";
        CreateVATPostingGroup: Codeunit "Create VAT Posting Groups";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.SetOverwriteData(true);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPJobSales(), CreateGLAccount.WIPJobSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPJobCosts(), CreateGLAccount.WIPJobCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCosts(), CreateGLAccount.JobCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Salaries(), CreateGLAccount.SalariesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OfficeSupplies(), CreateGLAccount.OfficeSuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.BalanceSheet(), CreateGLAccount.BalanceSheetName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Heading, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Assets(), CreateGLAccount.AssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSales(), CreateGLAccount.JobSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DevelopmentExpenditure(), DevelopmentExpenditureName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TenancySiteLeaseholdandsimilarrights(), TenancySiteLeaseholdandsimilarrightsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Goodwill(), GoodwillName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancedPaymentsforIntangibleFixedAssets(), AdvancedPaymentsforIntangibleFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Building(), BuildingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostofImprovementstoLeasedProperty(), CostofImprovementstoLeasedPropertyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Land(), LandName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EquipmentsandTools(), EquipmentsandToolsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Computers(), ComputersName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CarsandotherTransportEquipments(), CarsandotherTransportEquipmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LeasedAssets(), LeasedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccumulatedDepreciation(), AccumulatedDepreciationName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LongtermReceivables(), LongtermReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ParticipationinGroupCompanies(), ParticipationinGroupCompaniesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LoanstoPartnersorrelatedParties(), LoanstoPartnersorrelatedPartiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeferredTaxAssets(), DeferredTaxAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InventoriesProductsandworkinProgress(), InventoriesProductsandworkinProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SuppliesandConsumables(), SuppliesandConsumablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProductsinProgress(), ProductsinProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GoodsforResale(), GoodsforResaleName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AdvancedPaymentsforgoodsandservices(), AdvancedPaymentsforgoodsandservicesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherInventoryItems(), OtherInventoryItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WorkinProgress(), WorkinProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WIPAccruedCosts(), WIPAccruedCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WIPInvoicedSales(), WIPInvoicedSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalWorkinProgress(), TotalWorkinProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '1080..1089', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalInventoryProductsandWorkinProgress(), TotalInventoryProductsandWorkinProgressName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '1000..1099', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Receivables(), ReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccountReceivableDomestic(), AccountReceivableDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccountReceivableForeign(), AccountReceivableForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ContractualReceivables(), ContractualReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentReceivablefromEmployees(), CurrentReceivablefromEmployeesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ClearingAccountsforTaxesandcharges(), ClearingAccountsforTaxesandchargesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxAssets(), TaxAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVATReduced(), PurchaseVATReducedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVATNormal(), PurchaseVATNormalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MiscVATReceivables(), MiscVATReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentReceivablesfromgroupcompanies(), CurrentReceivablesfromgroupcompaniesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalReceivables(), TotalReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '1200..1499', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PrepaidRent(), PrepaidRentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Assetsintheformofprepaidexpenses(), AssetsintheformofprepaidexpensesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Convertibledebtinstruments(), ConvertibledebtinstrumentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CashandBank(), CashandBankName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BusinessaccountOperatingDomestic(), BusinessaccountOperatingDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BusinessaccountOperatingForeign(), BusinessaccountOperatingForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Otherbankaccounts(), OtherbankaccountsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CertificateofDeposit(), CertificateofDepositName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCashandBank(), TotalCashandBankName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '1600..1899', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Liability(), LiabilityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BondsandDebentureLoans(), BondsandDebentureLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConvertiblesLoans(), ConvertiblesLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherLongtermLiabilities(), OtherLongtermLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BankoverdraftFacilities(), BankoverdraftFacilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsPayableDomestic(), AccountsPayableDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsPayableForeign(), AccountsPayableForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Advancesfromcustomers(), AdvancesfromcustomersName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalAssets(), CreateGLAccount.TotalAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, '00..1999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Bankoverdraftshortterm(), BankoverdraftshorttermName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherLiabilities(), CreateGLAccount.OtherLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeferredRevenue(), DeferredRevenueName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxesLiable(), TaxesLiableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesVATReduced(), SalesVATReducedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesVATNormal(), SalesVATNormalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MiscVATPayables(), MiscVATPayablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EstimatedIncomeTax(), EstimatedIncomeTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EstimatedPayrolltaxonPensionCosts(), EstimatedPayrolltaxonPensionCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EmployeesWithholdingTaxes(), EmployeesWithholdingTaxesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(StatutorySocialsecurityContributions(), StatutorySocialsecurityContributionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AttachmentsofEarning(), AttachmentsofEarningName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HolidayPayfund(), HolidayPayfundName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentLiabilitiestoEmployees(), CurrentLiabilitiestoEmployeesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentLoans(), CurrentLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalLiabilities(), CreateGLAccount.TotalLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, '3..3999', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Equity(), EquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EquityPartner(), EquityPartnerName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ShareCapital(), ShareCapitalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Profitorlossfromthepreviousyear(), ProfitorlossfromthepreviousyearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DistributionstoShareholders(), DistributionstoShareholdersName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalEquity(), TotalEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"End-Total", '', '', 0, '2..2999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.IncomeStatement(), CreateGLAccount.IncomeStatementName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Heading, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Income(), IncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesofGoods(), SalesofGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SaleofFinishedGoods(), SaleofFinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreateVATPostingGroup.Domestic(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SaleofRawMaterials(), SaleofRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreateVATPostingGroup.Domestic(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ResaleofGoods(), ResaleofGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreateVATPostingGroup.Domestic(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesofGoods(), TotalSalesofGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"End-Total", '', '', 0, '4400..4409', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesofResources(), CreateGLAccount.SalesofResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SaleofResources(), SaleofResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreateVATPostingGroup.Domestic(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SaleofSubcontracting(), SaleofSubcontractingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreateVATPostingGroup.Domestic(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalSalesofResources(), CreateGLAccount.TotalSalesofResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, '4410..4413', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Incomefromsecurities(), IncomefromsecuritiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreateVATPostingGroup.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ManagementFeeRevenue(), ManagementFeeRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InterestIncome(), CreateGLAccount.InterestIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrencyGains(), CurrencyGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherIncidentalRevenue(), OtherIncidentalRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(JobsandServices(), JobsandServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobSalesApplied(), JobSalesAppliedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesofServiceContracts(), SalesofServiceContractsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreateVATPostingGroup.Domestic(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesofServiceWork(), SalesofServiceWorkName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalJobsandServices(), TotalJobsandServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"End-Total", '', '', 0, '4414..4419', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RevenueReductions(), RevenueReductionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesDiscounts(), SalesDiscountsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesInvoiceRounding(), SalesInvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesReturns(), SalesReturnsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRevenueReductions(), TotalRevenueReductionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"End-Total", '', '', 0, '4700..4799', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TOTALINCOME(), TOTALINCOMEName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"End-Total", '', '', 0, '4000..4999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(COSTOFGOODSSOLD(), COSTOFGOODSSOLDName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofGoods(), CostofGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofMaterials(), CostofMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostofMaterialsProjects(), CostofMaterialsProjectsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostofGoods(), TotalCostofGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, '5020..5023', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofResourcesandServices(), CostofResourcesandServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofLabor(), CostofLaborName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostofLaborProjects(), CostofLaborProjectsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CostofLaborWarrantyContract(), CostofLaborWarrantyContractName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostofResources(), TotalCostofResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, '5900..5905', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostsofJobs(), CostsofJobsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobCostsApplied(), JobCostsAppliedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostsofJobs(), TotalCostsofJobsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, '5040..5043', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Subcontractedwork(), SubcontractedworkName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ManufVariances(), ManufVariancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVarianceCap(), PurchaseVarianceCapName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MaterialVariance(), MaterialVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CapacityVariance(), CapacityVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SubcontractedVariance(), SubcontractedVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CapOverheadVariance(), CapOverheadVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MfgOverheadVariance(), MfgOverheadVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalManufVariances(), TotalManufVariancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, '5030..5038', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofVariances(), CostofVariancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TOTALCOSTOFGOODSSOLD(), TOTALCOSTOFGOODSSOLDName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, '5..5999', Enum::"General Posting Type"::" ", '', '', false, false, true);
        ContosoGLAccount.InsertGLAccount(EXPENSES(), EXPENSESName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RentalFacilities(), RentalFacilitiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RentLeases(), RentLeasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ElectricityforRental(), ElectricityforRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HeatingforRental(), HeatingforRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WaterandSewerageforRental(), WaterandSewerageforRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CleaningandWasteforRental(), CleaningandWasteforRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RepairsandMaintenanceforRental(), RepairsandMaintenanceforRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InsurancesRental(), InsurancesRentalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherRentalExpenses(), OtherRentalExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRentalFacilities(), TotalRentalFacilitiesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '6309..6399', Enum::"General Posting Type"::"Purchase", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Hireofmachinery(), HireofmachineryName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Hireofcomputers(), HireofcomputersName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Hireofotherfixedassets(), HireofotherfixedassetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PassengerCarCosts(), PassengerCarCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TruckCosts(), TruckCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othervehicleexpenses(), OthervehicleexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Freightfeesforgoods(), FreightfeesforgoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Customsandforwarding(), CustomsandforwardingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Freightfeesprojects(), FreightfeesprojectsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TravelExpenses(), TravelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Tickets(), TicketsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Rentalvehicles(), RentalvehiclesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Boardandlodging(), BoardandlodgingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Othertravelexpenses(), OthertravelexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalTravelExpenses(), TotalTravelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '6649..6669', Enum::"General Posting Type"::"Purchase", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AdvertisementDevelopment(), AdvertisementDevelopmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OutdoorandTransportationAds(), OutdoorandTransportationAdsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Admatteranddirectmailings(), AdmatteranddirectmailingsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConferenceExhibitionSponsorship(), ConferenceExhibitionSponsorshipName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Samplescontestsgifts(), SamplescontestsgiftsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FilmTVradiointernetads(), FilmTVradiointernetadsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreditCardCharges(), CreditCardChargesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BusinessEntertainingdeductible(), BusinessEntertainingdeductibleName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BusinessEntertainingnondeductible(), BusinessEntertainingnondeductibleName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PhoneServices(), PhoneServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Dataservices(), DataservicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Postalfees(), PostalfeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConsumableExpensiblehardware(), ConsumableExpensiblehardwareName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Softwareandsubscriptionfees(), SoftwareandsubscriptionfeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CorporateInsurance(), CorporateInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BadDebtLosses(), BadDebtLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AnnualinterrimReports(), AnnualinterrimReportsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PayableInvoiceRounding(), PayableInvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccountingServices(), AccountingServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LegalFeesandAttorneyServices(), LegalFeesandAttorneyServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherExternalServices(), OtherExternalServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Miscexternalexpenses(), MiscexternalexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseDiscounts(), PurchaseDiscountsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Personnel(), PersonnelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(HourlyWages(), HourlyWagesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OvertimeWages(), OvertimeWagesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Bonuses(), BonusesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CommissionsPaid(), CommissionsPaidName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Pensionfeesandrecurringcosts(), PensionfeesandrecurringcostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EmployerContributions(), EmployerContributionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(HealthInsurance(), HealthInsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPersonnel(), TotalPersonnelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '6001..6199', Enum::"General Posting Type"::"Purchase", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationLandandProperty(), DepreciationLandandPropertyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationFixedAssets(), DepreciationFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CurrencyLosses(), CurrencyLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TOTALEXPENSES(), TOTALEXPENSESName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Expense", Enum::"G/L Account Type"::"End-Total", '', '', 0, '6..7999', Enum::"General Posting Type"::"Purchase", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.NetIncome(), CreateGLAccount.NetIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.SetOverwriteData(false);
        GLAccountIndent.Indent();
        UpdateGLAccountCatagory();
        UpdateConsolidationGLAccounts();
    end;

    local procedure UpdateGLAccountCatagory()
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
    begin
        case GLAccountCategory."Account Category" of
            GLAccountCategory."Account Category"::Assets:
                UpdateGLAccounts(GLAccountCategory, '00', '1999');
            GLAccountCategory."Account Category"::Liabilities:
                UpdateGLAccounts(GLAccountCategory, '3', '3999');
            GLAccountCategory."Account Category"::Equity:
                UpdateGLAccounts(GLAccountCategory, '2', '2999');
            GLAccountCategory."Account Category"::Income:
                UpdateGLAccounts(GLAccountCategory, '4000', '4999');
            GLAccountCategory."Account Category"::"Cost of Goods Sold":
                UpdateGLAccounts(GLAccountCategory, '5', '5999');
            GLAccountCategory."Account Category"::Expense:
                UpdateGLAccounts(GLAccountCategory, '6', '7999');
        end;
    end;

    local procedure AssignSubcategoryToChartOfAccounts(GLAccountCategory: Record "G/L Account Category")
    var
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
    begin
        case GLAccountCategory.Description of
            GLAccountCategoryMgt.GetCash():
                UpdateGLAccounts(GLAccountCategory, '1600', '1990');
            GLAccountCategoryMgt.GetInventory():
                UpdateGLAccounts(GLAccountCategory, '1000', '1099');
            GLAccountCategoryMgt.GetAR():
                UpdateGLAccounts(GLAccountCategory, '1200', '1499');
            GLAccountCategoryMgt.GetAccumDeprec():
                UpdateGLAccounts(GLAccountCategory, '0490', '0490');
            GLAccountCategoryMgt.GetDistrToShareholders():
                UpdateGLAccounts(GLAccountCategory, '2100', '2100');
            GLAccountCategoryMgt.GetIncomeService():
                UpdateGLAccounts(GLAccountCategory, '4410', '4413');
            GLAccountCategoryMgt.GetIncomeProdSales():
                UpdateGLAccounts(GLAccountCategory, '4400', '4409');
            GLAccountCategoryMgt.GetCOGSLabor():
                UpdateGLAccounts(GLAccountCategory, '5900', '5905');
            GLAccountCategoryMgt.GetCOGSMaterials():
                UpdateGLAccounts(GLAccountCategory, '5020', '5023');
            GLAccountCategoryMgt.GetRentExpense():
                UpdateGLAccounts(GLAccountCategory, '6310', '6310');
            GLAccountCategoryMgt.GetInterestExpense():
                UpdateGLAccounts(GLAccountCategory, '4203', '4203');
            GLAccountCategoryMgt.GetBadDebtExpense():
                UpdateGLAccounts(GLAccountCategory, '6930', '6930');
            GLAccountCategoryMgt.GetRepairsExpense():
                UpdateGLAccounts(GLAccountCategory, '6335', '6335');
            GLAccountCategoryMgt.GetUtilitiesExpense():
                UpdateGLAccounts(GLAccountCategory, '6325', '6330');
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


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccountforDE()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ModifyGLAccountForW1();
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BalanceSheetName(), '0');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AssetsName(), '00');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BondsName(), '0920');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsName(), '1001');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobSalesName(), '1081');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobCostsName(), '1082');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsName(), '1101');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAssetsName(), '1999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesName(), '3500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesName(), '3999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncomeStatementName(), '4');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestIncomeName(), '4203');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofResourcesName(), '4410');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofResourcesName(), '4413');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesName(), '4415');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostsName(), '5041');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalariesName(), '6020');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OfficeSuppliesName(), '6815');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeName(), '8999');
        ContosoGLAccount.AddAccountForLocalization(DevelopmentExpenditureName(), '0148');
        ContosoGLAccount.AddAccountForLocalization(GoodwillName(), '0150');
        ContosoGLAccount.AddAccountForLocalization(AdvancedPaymentsforIntangibleFixedAssetsName(), '0170');
        ContosoGLAccount.AddAccountForLocalization(LandName(), '0200');
        ContosoGLAccount.AddAccountForLocalization(TenancySiteLeaseholdandsimilarrightsName(), '0220');
        ContosoGLAccount.AddAccountForLocalization(BuildingName(), '0260');
        ContosoGLAccount.AddAccountForLocalization(CostofImprovementstoLeasedPropertyName(), '0290');
        ContosoGLAccount.AddAccountForLocalization(EquipmentsandToolsName(), '0400');
        ContosoGLAccount.AddAccountForLocalization(AccumulatedDepreciationName(), '0490');
        ContosoGLAccount.AddAccountForLocalization(LeasedAssetsName(), '0510');
        ContosoGLAccount.AddAccountForLocalization(CarsandotherTransportEquipmentsName(), '0520');
        ContosoGLAccount.AddAccountForLocalization(ComputersName(), '0635');
        ContosoGLAccount.AddAccountForLocalization(PrepaidRentName(), '0750');
        ContosoGLAccount.AddAccountForLocalization(ParticipationinGroupCompaniesName(), '0804');
        ContosoGLAccount.AddAccountForLocalization(LoanstoPartnersorrelatedPartiesName(), '0814');
        ContosoGLAccount.AddAccountForLocalization(ConvertibledebtinstrumentsName(), '0940');
        ContosoGLAccount.AddAccountForLocalization(InventoriesProductsandworkinProgressName(), '1000');
        ContosoGLAccount.AddAccountForLocalization(SuppliesandConsumablesName(), '1002');
        ContosoGLAccount.AddAccountForLocalization(ProductsinProgressName(), '1051');
        ContosoGLAccount.AddAccountForLocalization(WorkinProgressName(), '1080');
        ContosoGLAccount.AddAccountForLocalization(WIPAccruedCostsName(), '1083');
        ContosoGLAccount.AddAccountForLocalization(WIPInvoicedSalesName(), '1084');
        ContosoGLAccount.AddAccountForLocalization(TotalWorkinProgressName(), '1089');
        ContosoGLAccount.AddAccountForLocalization(TotalInventoryProductsandWorkinProgressName(), '1099');
        ContosoGLAccount.AddAccountForLocalization(GoodsforResaleName(), '1102');
        ContosoGLAccount.AddAccountForLocalization(OtherInventoryItemsName(), '1178');
        ContosoGLAccount.AddAccountForLocalization(AdvancedPaymentsforgoodsandservicesName(), '1180');
        ContosoGLAccount.AddAccountForLocalization(ReceivablesName(), '1200');
        ContosoGLAccount.AddAccountForLocalization(AccountReceivableDomesticName(), '1202');
        ContosoGLAccount.AddAccountForLocalization(AccountReceivableForeignName(), '1203');
        ContosoGLAccount.AddAccountForLocalization(LongtermReceivablesName(), '1225');
        ContosoGLAccount.AddAccountForLocalization(CurrentReceivablesfromgroupcompaniesName(), '1260');
        ContosoGLAccount.AddAccountForLocalization(CurrentReceivablefromEmployeesName(), '1340');
        ContosoGLAccount.AddAccountForLocalization(ContractualReceivablesName(), '1375');
        ContosoGLAccount.AddAccountForLocalization(MiscVATReceivablesName(), '1400');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVATReducedName(), '1403');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVATNormalName(), '1406');
        ContosoGLAccount.AddAccountForLocalization(TaxAssetsName(), '1410');
        ContosoGLAccount.AddAccountForLocalization(ClearingAccountsforTaxesandchargesName(), '1480');
        ContosoGLAccount.AddAccountForLocalization(TotalReceivablesName(), '1499');
        ContosoGLAccount.AddAccountForLocalization(CashandBankName(), '1600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashName(), '1610');
        ContosoGLAccount.AddAccountForLocalization(BusinessaccountOperatingDomesticName(), '1810');
        ContosoGLAccount.AddAccountForLocalization(BusinessaccountOperatingForeignName(), '1820');
        ContosoGLAccount.AddAccountForLocalization(OtherbankaccountsName(), '1830');
        ContosoGLAccount.AddAccountForLocalization(TotalCashandBankName(), '1899');
        ContosoGLAccount.AddAccountForLocalization(AssetsintheformofprepaidexpensesName(), '1900');
        ContosoGLAccount.AddAccountForLocalization(DeferredTaxAssetsName(), '1950');
        ContosoGLAccount.AddAccountForLocalization(CertificateofDepositName(), '1990');
        ContosoGLAccount.AddAccountForLocalization(EquityName(), '2');
        ContosoGLAccount.AddAccountForLocalization(EquityPartnerName(), '2000');
        ContosoGLAccount.AddAccountForLocalization(ShareCapitalName(), '2010');
        ContosoGLAccount.AddAccountForLocalization(DistributionstoShareholdersName(), '2100');
        ContosoGLAccount.AddAccountForLocalization(ProfitorlossfromthepreviousyearName(), '2970');
        ContosoGLAccount.AddAccountForLocalization(TotalEquityName(), '2999');
        ContosoGLAccount.AddAccountForLocalization(LiabilityName(), '3');
        ContosoGLAccount.AddAccountForLocalization(EstimatedPayrolltaxonPensionCostsName(), '3011');
        ContosoGLAccount.AddAccountForLocalization(EstimatedIncomeTaxName(), '3040');
        ContosoGLAccount.AddAccountForLocalization(HolidayPayfundName(), '3079');
        ContosoGLAccount.AddAccountForLocalization(BondsandDebentureLoansName(), '3100');
        ContosoGLAccount.AddAccountForLocalization(ConvertiblesLoansName(), '3120');
        ContosoGLAccount.AddAccountForLocalization(OtherLongtermLiabilitiesName(), '3150');
        ContosoGLAccount.AddAccountForLocalization(BankoverdraftFacilitiesName(), '3151');
        ContosoGLAccount.AddAccountForLocalization(BankoverdraftshorttermName(), '3181');
        ContosoGLAccount.AddAccountForLocalization(AdvancesfromcustomersName(), '3250');
        ContosoGLAccount.AddAccountForLocalization(AccountsPayableDomesticName(), '3301');
        ContosoGLAccount.AddAccountForLocalization(AccountsPayableForeignName(), '3302');
        ContosoGLAccount.AddAccountForLocalization(CurrentLoansName(), '3560');
        ContosoGLAccount.AddAccountForLocalization(TaxesLiableName(), '3700');
        ContosoGLAccount.AddAccountForLocalization(EmployeesWithholdingTaxesName(), '3720');
        ContosoGLAccount.AddAccountForLocalization(CurrentLiabilitiestoEmployeesName(), '3721');
        ContosoGLAccount.AddAccountForLocalization(AttachmentsofEarningName(), '3725');
        ContosoGLAccount.AddAccountForLocalization(StatutorySocialsecurityContributionsName(), '3740');
        ContosoGLAccount.AddAccountForLocalization(MiscVATPayablesName(), '3800');
        ContosoGLAccount.AddAccountForLocalization(SalesVATReducedName(), '3801');
        ContosoGLAccount.AddAccountForLocalization(SalesVATNormalName(), '3806');
        ContosoGLAccount.AddAccountForLocalization(DeferredRevenueName(), '3900');
        ContosoGLAccount.AddAccountForLocalization(IncomeName(), '4000');
        ContosoGLAccount.AddAccountForLocalization(IncomefromsecuritiesName(), '4201');
        ContosoGLAccount.AddAccountForLocalization(ManagementFeeRevenueName(), '4202');
        ContosoGLAccount.AddAccountForLocalization(SalesofGoodsName(), '4400');
        ContosoGLAccount.AddAccountForLocalization(SaleofFinishedGoodsName(), '4401');
        ContosoGLAccount.AddAccountForLocalization(SaleofRawMaterialsName(), '4402');
        ContosoGLAccount.AddAccountForLocalization(ResaleofGoodsName(), '4403');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesofGoodsName(), '4409');
        ContosoGLAccount.AddAccountForLocalization(SaleofResourcesName(), '4411');
        ContosoGLAccount.AddAccountForLocalization(SaleofSubcontractingName(), '4412');
        ContosoGLAccount.AddAccountForLocalization(JobsandServicesName(), '4414');
        ContosoGLAccount.AddAccountForLocalization(JobSalesAppliedName(), '4416');
        ContosoGLAccount.AddAccountForLocalization(SalesofServiceContractsName(), '4417');
        ContosoGLAccount.AddAccountForLocalization(SalesofServiceWorkName(), '4418');
        ContosoGLAccount.AddAccountForLocalization(TotalJobsandServicesName(), '4419');
        ContosoGLAccount.AddAccountForLocalization(RevenueReductionsName(), '4700');
        ContosoGLAccount.AddAccountForLocalization(SalesDiscountsName(), '4730');
        ContosoGLAccount.AddAccountForLocalization(SalesReturnsName(), '4770');
        ContosoGLAccount.AddAccountForLocalization(TotalRevenueReductionsName(), '4799');
        ContosoGLAccount.AddAccountForLocalization(OtherIncidentalRevenueName(), '4830');
        ContosoGLAccount.AddAccountForLocalization(CurrencyGainsName(), '4840');
        ContosoGLAccount.AddAccountForLocalization(TOTALINCOMEName(), '4999');
        ContosoGLAccount.AddAccountForLocalization(COSTOFGOODSSOLDName(), '5');
        ContosoGLAccount.AddAccountForLocalization(CostofGoodsName(), '5020');
        ContosoGLAccount.AddAccountForLocalization(CostofMaterialsName(), '5021');
        ContosoGLAccount.AddAccountForLocalization(CostofMaterialsProjectsName(), '5022');
        ContosoGLAccount.AddAccountForLocalization(TotalCostofGoodsName(), '5023');
        ContosoGLAccount.AddAccountForLocalization(ManufVariancesName(), '5030');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVarianceCapName(), '5031');
        ContosoGLAccount.AddAccountForLocalization(MaterialVarianceName(), '5032');
        ContosoGLAccount.AddAccountForLocalization(CapacityVarianceName(), '5033');
        ContosoGLAccount.AddAccountForLocalization(SubcontractedVarianceName(), '5034');
        ContosoGLAccount.AddAccountForLocalization(CapOverheadVarianceName(), '5035');
        ContosoGLAccount.AddAccountForLocalization(MfgOverheadVarianceName(), '5036');
        ContosoGLAccount.AddAccountForLocalization(TotalManufVariancesName(), '5038');
        ContosoGLAccount.AddAccountForLocalization(CostofVariancesName(), '5039');
        ContosoGLAccount.AddAccountForLocalization(CostsofJobsName(), '5040');
        ContosoGLAccount.AddAccountForLocalization(JobCostsAppliedName(), '5042');
        ContosoGLAccount.AddAccountForLocalization(TotalCostsofJobsName(), '5043');
        ContosoGLAccount.AddAccountForLocalization(CostofResourcesandServicesName(), '5900');
        ContosoGLAccount.AddAccountForLocalization(CostofLaborName(), '5901');
        ContosoGLAccount.AddAccountForLocalization(CostofLaborProjectsName(), '5902');
        ContosoGLAccount.AddAccountForLocalization(CostofLaborWarrantyContractName(), '5903');
        ContosoGLAccount.AddAccountForLocalization(SubcontractedworkName(), '5904');
        ContosoGLAccount.AddAccountForLocalization(TotalCostofResourcesName(), '5905');
        ContosoGLAccount.AddAccountForLocalization(TOTALCOSTOFGOODSSOLDName(), '5999');
        ContosoGLAccount.AddAccountForLocalization(EXPENSESName(), '6');
        ContosoGLAccount.AddAccountForLocalization(PersonnelName(), '6001');
        ContosoGLAccount.AddAccountForLocalization(HourlyWagesName(), '6010');
        ContosoGLAccount.AddAccountForLocalization(OvertimeWagesName(), '6011');
        ContosoGLAccount.AddAccountForLocalization(CommissionsPaidName(), '6012');
        ContosoGLAccount.AddAccountForLocalization(BonusesName(), '6029');
        ContosoGLAccount.AddAccountForLocalization(EmployerContributionsName(), '6100');
        ContosoGLAccount.AddAccountForLocalization(PensionfeesandrecurringcostsName(), '6150');
        ContosoGLAccount.AddAccountForLocalization(HealthInsuranceName(), '6160');
        ContosoGLAccount.AddAccountForLocalization(TotalPersonnelName(), '6199');
        ContosoGLAccount.AddAccountForLocalization(DepreciationFixedAssetsName(), '6220');
        ContosoGLAccount.AddAccountForLocalization(DepreciationLandandPropertyName(), '6221');
        ContosoGLAccount.AddAccountForLocalization(MiscexternalexpensesName(), '6300');
        ContosoGLAccount.AddAccountForLocalization(OtherExternalServicesName(), '6303');
        ContosoGLAccount.AddAccountForLocalization(RentalFacilitiesName(), '6309');
        ContosoGLAccount.AddAccountForLocalization(RentLeasesName(), '6310');
        ContosoGLAccount.AddAccountForLocalization(HeatingforRentalName(), '6320');
        ContosoGLAccount.AddAccountForLocalization(ElectricityforRentalName(), '6325');
        ContosoGLAccount.AddAccountForLocalization(WaterandSewerageforRentalName(), '6326');
        ContosoGLAccount.AddAccountForLocalization(CleaningandWasteforRentalName(), '6330');
        ContosoGLAccount.AddAccountForLocalization(RepairsandMaintenanceforRentalName(), '6335');
        ContosoGLAccount.AddAccountForLocalization(InsurancesRentalName(), '6340');
        ContosoGLAccount.AddAccountForLocalization(OtherRentalExpensesName(), '6345');
        ContosoGLAccount.AddAccountForLocalization(TotalRentalFacilitiesName(), '6399');
        ContosoGLAccount.AddAccountForLocalization(CorporateInsuranceName(), '6400');
        ContosoGLAccount.AddAccountForLocalization(PassengerCarCostsName(), '6500');
        ContosoGLAccount.AddAccountForLocalization(TruckCostsName(), '6520');
        ContosoGLAccount.AddAccountForLocalization(OthervehicleexpensesName(), '6595');
        ContosoGLAccount.AddAccountForLocalization(AdvertisementDevelopmentName(), '6600');
        ContosoGLAccount.AddAccountForLocalization(OutdoorandTransportationAdsName(), '6601');
        ContosoGLAccount.AddAccountForLocalization(AdmatteranddirectmailingsName(), '6602');
        ContosoGLAccount.AddAccountForLocalization(ConferenceExhibitionSponsorshipName(), '6603');
        ContosoGLAccount.AddAccountForLocalization(FilmTVradiointernetadsName(), '6604');
        ContosoGLAccount.AddAccountForLocalization(SamplescontestsgiftsName(), '6605');
        ContosoGLAccount.AddAccountForLocalization(BusinessEntertainingdeductibleName(), '6640');
        ContosoGLAccount.AddAccountForLocalization(BusinessEntertainingnondeductibleName(), '6644');
        ContosoGLAccount.AddAccountForLocalization(TravelExpensesName(), '6649');
        ContosoGLAccount.AddAccountForLocalization(OthertravelexpensesName(), '6650');
        ContosoGLAccount.AddAccountForLocalization(BoardandlodgingName(), '6660');
        ContosoGLAccount.AddAccountForLocalization(TicketsName(), '6663');
        ContosoGLAccount.AddAccountForLocalization(RentalvehiclesName(), '6668');
        ContosoGLAccount.AddAccountForLocalization(TotalTravelExpensesName(), '6669');
        ContosoGLAccount.AddAccountForLocalization(CreditCardChargesName(), '6690');
        ContosoGLAccount.AddAccountForLocalization(FreightfeesforgoodsName(), '6740');
        ContosoGLAccount.AddAccountForLocalization(CustomsandforwardingName(), '6760');
        ContosoGLAccount.AddAccountForLocalization(FreightfeesprojectsName(), '6780');
        ContosoGLAccount.AddAccountForLocalization(PostalfeesName(), '6800');
        ContosoGLAccount.AddAccountForLocalization(PhoneServicesName(), '6805');
        ContosoGLAccount.AddAccountForLocalization(DataservicesName(), '6810');
        ContosoGLAccount.AddAccountForLocalization(LegalFeesandAttorneyServicesName(), '6825');
        ContosoGLAccount.AddAccountForLocalization(AnnualinterrimReportsName(), '6827');
        ContosoGLAccount.AddAccountForLocalization(AccountingServicesName(), '6830');
        ContosoGLAccount.AddAccountForLocalization(HireofmachineryName(), '6836');
        ContosoGLAccount.AddAccountForLocalization(SoftwareandsubscriptionfeesName(), '6837');
        ContosoGLAccount.AddAccountForLocalization(HireofcomputersName(), '6840');
        ContosoGLAccount.AddAccountForLocalization(HireofotherfixedassetsName(), '6845');
        ContosoGLAccount.AddAccountForLocalization(ConsumableExpensiblehardwareName(), '6850');
        ContosoGLAccount.AddAccountForLocalization(CurrencyLossesName(), '6880');
        ContosoGLAccount.AddAccountForLocalization(BadDebtLossesName(), '6930');
        ContosoGLAccount.AddAccountForLocalization(PurchaseDiscountsName(), '7130');
        ContosoGLAccount.AddAccountForLocalization(PayableInvoiceRoundingName(), '7400');
        ContosoGLAccount.AddAccountForLocalization(SalesInvoiceRoundingName(), '7500');
        ContosoGLAccount.AddAccountForLocalization(TOTALEXPENSESName(), '7999');
    end;

    local procedure ModifyGLAccountForW1()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDeprOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResaleSoldInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMatSoldInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PrimoInventoryName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWIPName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoicedJobSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPSalesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedJobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPCostsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWIPTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersDomesticName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersForeignName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedInterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherReceivablesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankLCYName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankCurrenciesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GiroAccountName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LIABILITIESANDEQUITYName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.StockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CapitalStockName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetainedEarningsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomefortheYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalStockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeferredTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermBankLoansName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShorttermLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevolvingCreditName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT0Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsDomesticName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsForeignName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimTotalName(), '');
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
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelrelatedItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WithholdingTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SupplementaryTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EmployeesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelrelatedItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DividendsfortheFiscalYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShorttermLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TOTALLIABILITIESANDEQUITYName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevenueName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofJobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOtherJobExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesofJobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultingFeesDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FeesandChargesRecDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscountGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalRevenueName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRetailSoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofRawMaterialsSoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofResourcesUsedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostofResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BuildingMaintenanceExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CleaningName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityandHeatingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalBldgMaintExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdministrativeExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PhoneandFaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PostageName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAdministrativeExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SoftwareName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultantServicesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SellingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdvertisingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EntertainmentandPRName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TravelName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSellingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehicleExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GasolineandMotorOilName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RegistrationFeesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalVehicleExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashDiscrepanciesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BadDebtExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LegalandAccountingServicesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MiscellaneousName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalOperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WagesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetirementPlanContributionsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationofFixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GainsandLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalFixedAssetDepreciationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherCostsofOperationsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetOperatingIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonBankBalancesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargesfromCustomersName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsReceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtDiscReceivedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoiceRoundingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ApplicationRoundingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceReceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolReceivedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonRevolvingCreditName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonBankLoansName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageInterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargestoVendorsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtDiscGrantedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolGrantedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFXGainsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFXLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFXGainsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFXLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NIBEFOREEXTRITEMSTAXESName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NETINCOMEBEFORETAXESName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceExpenseName(), '');
    end;

    local procedure UpdateConsolidationGLAccounts()
    var
        GLAccount: Record "G/L Account";
    begin
        if GLAccount.FindSet() then
            repeat
                GLAccount.Validate("Consol. Debit Acc.", GLAccount."No.");
                GLAccount.Validate("Consol. Credit Acc.", GLAccount."No.");
                GLAccount.Modify(true);
            until GLAccount.Next() = 0;
    end;

    procedure DevelopmentExpenditureName(): Text[100]
    begin
        exit(DevelopmentExpenditureLbl);
    end;

    procedure GoodwillName(): Text[100]
    begin
        exit(GoodwillLbl);
    end;

    procedure AdvancedPaymentsforIntangibleFixedAssetsName(): Text[100]
    begin
        exit(AdvancedPaymentsforIntangibleFixedAssetsLbl);
    end;

    procedure LandName(): Text[100]
    begin
        exit(LandLbl);
    end;

    procedure TenancySiteLeaseholdandsimilarrightsName(): Text[100]
    begin
        exit(TenancySiteLeaseholdandsimilarrightsLbl);
    end;

    procedure BuildingName(): Text[100]
    begin
        exit(BuildingLbl);
    end;

    procedure CostofImprovementstoLeasedPropertyName(): Text[100]
    begin
        exit(CostofImprovementstoLeasedPropertyLbl);
    end;

    procedure EquipmentsandToolsName(): Text[100]
    begin
        exit(EquipmentsandToolsLbl);
    end;

    procedure AccumulatedDepreciationName(): Text[100]
    begin
        exit(AccumulatedDepreciationLbl);
    end;

    procedure LeasedAssetsName(): Text[100]
    begin
        exit(LeasedAssetsLbl);
    end;

    procedure CarsandotherTransportEquipmentsName(): Text[100]
    begin
        exit(CarsandotherTransportEquipmentsLbl);
    end;

    procedure ComputersName(): Text[100]
    begin
        exit(ComputersLbl);
    end;

    procedure PrepaidRentName(): Text[100]
    begin
        exit(PrepaidRentLbl);
    end;

    procedure ParticipationinGroupCompaniesName(): Text[100]
    begin
        exit(ParticipationinGroupCompaniesLbl);
    end;

    procedure LoanstoPartnersorrelatedPartiesName(): Text[100]
    begin
        exit(LoanstoPartnersorrelatedPartiesLbl);
    end;

    procedure ConvertibledebtinstrumentsName(): Text[100]
    begin
        exit(ConvertibledebtinstrumentsLbl);
    end;

    procedure InventoriesProductsandworkinProgressName(): Text[100]
    begin
        exit(InventoriesProductsandworkinProgressLbl);
    end;

    procedure SuppliesandConsumablesName(): Text[100]
    begin
        exit(SuppliesandConsumablesLbl);
    end;

    procedure ProductsinProgressName(): Text[100]
    begin
        exit(ProductsinProgressLbl);
    end;

    procedure WorkinProgressName(): Text[100]
    begin
        exit(WorkinProgressLbl);
    end;

    procedure WIPAccruedCostsName(): Text[100]
    begin
        exit(WIPAccruedCostsLbl);
    end;

    procedure WIPInvoicedSalesName(): Text[100]
    begin
        exit(WIPInvoicedSalesLbl);
    end;

    procedure TotalWorkinProgressName(): Text[100]
    begin
        exit(TotalWorkinProgressLbl);
    end;

    procedure TotalInventoryProductsandWorkinProgressName(): Text[100]
    begin
        exit(TotalInventoryProductsandWorkinProgressLbl);
    end;

    procedure GoodsforResaleName(): Text[100]
    begin
        exit(GoodsforResaleLbl);
    end;

    procedure OtherInventoryItemsName(): Text[100]
    begin
        exit(OtherInventoryItemsLbl);
    end;

    procedure AdvancedPaymentsforgoodsandservicesName(): Text[100]
    begin
        exit(AdvancedPaymentsforgoodsandservicesLbl);
    end;

    procedure ReceivablesName(): Text[100]
    begin
        exit(ReceivablesLbl);
    end;

    procedure AccountReceivableDomesticName(): Text[100]
    begin
        exit(AccountReceivableDomesticLbl);
    end;

    procedure AccountReceivableForeignName(): Text[100]
    begin
        exit(AccountReceivableForeignLbl);
    end;

    procedure LongtermReceivablesName(): Text[100]
    begin
        exit(LongtermReceivablesLbl);
    end;

    procedure CurrentReceivablesfromgroupcompaniesName(): Text[100]
    begin
        exit(CurrentReceivablesfromgroupcompaniesLbl);
    end;

    procedure CurrentReceivablefromEmployeesName(): Text[100]
    begin
        exit(CurrentReceivablefromEmployeesLbl);
    end;

    procedure ContractualReceivablesName(): Text[100]
    begin
        exit(ContractualReceivablesLbl);
    end;

    procedure MiscVATReceivablesName(): Text[100]
    begin
        exit(MiscVATReceivablesLbl);
    end;

    procedure PurchaseVATReducedName(): Text[100]
    begin
        exit(PurchaseVATReducedLbl);
    end;

    procedure PurchaseVATNormalName(): Text[100]
    begin
        exit(PurchaseVATNormalLbl);
    end;

    procedure TaxAssetsName(): Text[100]
    begin
        exit(TaxAssetsLbl);
    end;

    procedure ClearingAccountsforTaxesandchargesName(): Text[100]
    begin
        exit(ClearingAccountsforTaxesandchargesLbl);
    end;

    procedure TotalReceivablesName(): Text[100]
    begin
        exit(TotalReceivablesLbl);
    end;

    procedure CashandBankName(): Text[100]
    begin
        exit(CashandBankLbl);
    end;

    procedure BusinessaccountOperatingDomesticName(): Text[100]
    begin
        exit(BusinessaccountOperatingDomesticLbl);
    end;

    procedure BusinessaccountOperatingForeignName(): Text[100]
    begin
        exit(BusinessaccountOperatingForeignLbl);
    end;

    procedure OtherbankaccountsName(): Text[100]
    begin
        exit(OtherbankaccountsLbl);
    end;

    procedure TotalCashandBankName(): Text[100]
    begin
        exit(TotalCashandBankLbl);
    end;

    procedure AssetsintheformofprepaidexpensesName(): Text[100]
    begin
        exit(AssetsintheformofprepaidexpensesLbl);
    end;

    procedure DeferredTaxAssetsName(): Text[100]
    begin
        exit(DeferredTaxAssetsLbl);
    end;

    procedure CertificateofDepositName(): Text[100]
    begin
        exit(CertificateofDepositLbl);
    end;

    procedure EquityName(): Text[100]
    begin
        exit(EquityLbl);
    end;

    procedure EquityPartnerName(): Text[100]
    begin
        exit(EquityPartnerLbl);
    end;

    procedure ShareCapitalName(): Text[100]
    begin
        exit(ShareCapitalLbl);
    end;

    procedure DistributionstoShareholdersName(): Text[100]
    begin
        exit(DistributionstoShareholdersLbl);
    end;

    procedure ProfitorlossfromthepreviousyearName(): Text[100]
    begin
        exit(ProfitorlossfromthepreviousyearLbl);
    end;

    procedure TotalEquityName(): Text[100]
    begin
        exit(TotalEquityLbl);
    end;

    procedure LiabilityName(): Text[100]
    begin
        exit(LiabilityLbl);
    end;

    procedure EstimatedPayrolltaxonPensionCostsName(): Text[100]
    begin
        exit(EstimatedPayrolltaxonPensionCostsLbl);
    end;

    procedure EstimatedIncomeTaxName(): Text[100]
    begin
        exit(EstimatedIncomeTaxLbl);
    end;

    procedure HolidayPayfundName(): Text[100]
    begin
        exit(HolidayPayfundLbl);
    end;

    procedure BondsandDebentureLoansName(): Text[100]
    begin
        exit(BondsandDebentureLoansLbl);
    end;

    procedure ConvertiblesLoansName(): Text[100]
    begin
        exit(ConvertiblesLoansLbl);
    end;

    procedure OtherLongtermLiabilitiesName(): Text[100]
    begin
        exit(OtherLongtermLiabilitiesLbl);
    end;

    procedure BankoverdraftFacilitiesName(): Text[100]
    begin
        exit(BankoverdraftFacilitiesLbl);
    end;

    procedure BankoverdraftshorttermName(): Text[100]
    begin
        exit(BankoverdraftshorttermLbl);
    end;

    procedure AdvancesfromcustomersName(): Text[100]
    begin
        exit(AdvancesfromcustomersLbl);
    end;

    procedure AccountsPayableDomesticName(): Text[100]
    begin
        exit(AccountsPayableDomesticLbl);
    end;

    procedure AccountsPayableForeignName(): Text[100]
    begin
        exit(AccountsPayableForeignLbl);
    end;

    procedure CurrentLoansName(): Text[100]
    begin
        exit(CurrentLoansLbl);
    end;

    procedure TaxesLiableName(): Text[100]
    begin
        exit(TaxesLiableLbl);
    end;

    procedure EmployeesWithholdingTaxesName(): Text[100]
    begin
        exit(EmployeesWithholdingTaxesLbl);
    end;

    procedure CurrentLiabilitiestoEmployeesName(): Text[100]
    begin
        exit(CurrentLiabilitiestoEmployeesLbl);
    end;

    procedure AttachmentsofEarningName(): Text[100]
    begin
        exit(AttachmentsofEarningLbl);
    end;

    procedure StatutorySocialsecurityContributionsName(): Text[100]
    begin
        exit(StatutorySocialsecurityContributionsLbl);
    end;

    procedure MiscVATPayablesName(): Text[100]
    begin
        exit(MiscVATPayablesLbl);
    end;

    procedure SalesVATReducedName(): Text[100]
    begin
        exit(SalesVATReducedLbl);
    end;

    procedure SalesVATNormalName(): Text[100]
    begin
        exit(SalesVATNormalLbl);
    end;

    procedure DeferredRevenueName(): Text[100]
    begin
        exit(DeferredRevenueLbl);
    end;

    procedure IncomeName(): Text[100]
    begin
        exit(IncomeLbl);
    end;

    procedure IncomefromsecuritiesName(): Text[100]
    begin
        exit(IncomefromsecuritiesLbl);
    end;

    procedure ManagementFeeRevenueName(): Text[100]
    begin
        exit(ManagementFeeRevenueLbl);
    end;

    procedure SalesofGoodsName(): Text[100]
    begin
        exit(SalesofGoodsLbl);
    end;

    procedure SaleofFinishedGoodsName(): Text[100]
    begin
        exit(SaleofFinishedGoodsLbl);
    end;

    procedure SaleofRawMaterialsName(): Text[100]
    begin
        exit(SaleofRawMaterialsLbl);
    end;

    procedure ResaleofGoodsName(): Text[100]
    begin
        exit(ResaleofGoodsLbl);
    end;

    procedure TotalSalesofGoodsName(): Text[100]
    begin
        exit(TotalSalesofGoodsLbl);
    end;

    procedure SaleofResourcesName(): Text[100]
    begin
        exit(SaleofResourcesLbl);
    end;

    procedure SaleofSubcontractingName(): Text[100]
    begin
        exit(SaleofSubcontractingLbl);
    end;

    procedure JobsandServicesName(): Text[100]
    begin
        exit(JobsandServicesLbl);
    end;

    procedure JobSalesAppliedName(): Text[100]
    begin
        exit(JobSalesAppliedLbl);
    end;

    procedure SalesofServiceContractsName(): Text[100]
    begin
        exit(SalesofServiceContractsLbl);
    end;

    procedure SalesofServiceWorkName(): Text[100]
    begin
        exit(SalesofServiceWorkLbl);
    end;

    procedure TotalJobsandServicesName(): Text[100]
    begin
        exit(TotalJobsandServicesLbl);
    end;

    procedure RevenueReductionsName(): Text[100]
    begin
        exit(RevenueReductionsLbl);
    end;

    procedure SalesDiscountsName(): Text[100]
    begin
        exit(SalesDiscountsLbl);
    end;

    procedure SalesReturnsName(): Text[100]
    begin
        exit(SalesReturnsLbl);
    end;

    procedure TotalRevenueReductionsName(): Text[100]
    begin
        exit(TotalRevenueReductionsLbl);
    end;

    procedure OtherIncidentalRevenueName(): Text[100]
    begin
        exit(OtherIncidentalRevenueLbl);
    end;

    procedure CurrencyGainsName(): Text[100]
    begin
        exit(CurrencyGainsLbl);
    end;

    procedure TOTALINCOMEName(): Text[100]
    begin
        exit(TOTALINCOMELbl);
    end;

    procedure COSTOFGOODSSOLDName(): Text[100]
    begin
        exit(COSTOFGOODSSOLDLbl);
    end;

    procedure CostofGoodsName(): Text[100]
    begin
        exit(CostofGoodsLbl);
    end;

    procedure CostofMaterialsName(): Text[100]
    begin
        exit(CostofMaterialsLbl);
    end;

    procedure CostofMaterialsProjectsName(): Text[100]
    begin
        exit(CostofMaterialsProjectsLbl);
    end;

    procedure TotalCostofGoodsName(): Text[100]
    begin
        exit(TotalCostofGoodsLbl);
    end;

    procedure ManufVariancesName(): Text[100]
    begin
        exit(ManufVariancesLbl);
    end;

    procedure PurchaseVarianceCapName(): Text[100]
    begin
        exit(PurchaseVarianceCapLbl);
    end;

    procedure MaterialVarianceName(): Text[100]
    begin
        exit(MaterialVarianceLbl);
    end;

    procedure CapacityVarianceName(): Text[100]
    begin
        exit(CapacityVarianceLbl);
    end;

    procedure SubcontractedVarianceName(): Text[100]
    begin
        exit(SubcontractedVarianceLbl);
    end;

    procedure CapOverheadVarianceName(): Text[100]
    begin
        exit(CapOverheadVarianceLbl);
    end;

    procedure MfgOverheadVarianceName(): Text[100]
    begin
        exit(MfgOverheadVarianceLbl);
    end;

    procedure TotalManufVariancesName(): Text[100]
    begin
        exit(TotalManufVariancesLbl);
    end;

    procedure CostofVariancesName(): Text[100]
    begin
        exit(CostofVariancesLbl);
    end;

    procedure CostsofJobsName(): Text[100]
    begin
        exit(CostsofJobsLbl);
    end;

    procedure JobCostsAppliedName(): Text[100]
    begin
        exit(JobCostsAppliedLbl);
    end;

    procedure TotalCostsofJobsName(): Text[100]
    begin
        exit(TotalCostsofJobsLbl);
    end;

    procedure CostofResourcesandServicesName(): Text[100]
    begin
        exit(CostofResourcesandServicesLbl);
    end;

    procedure CostofLaborName(): Text[100]
    begin
        exit(CostofLaborLbl);
    end;

    procedure CostofLaborProjectsName(): Text[100]
    begin
        exit(CostofLaborProjectsLbl);
    end;

    procedure CostofLaborWarrantyContractName(): Text[100]
    begin
        exit(CostofLaborWarrantyContractLbl);
    end;

    procedure SubcontractedworkName(): Text[100]
    begin
        exit(SubcontractedworkLbl);
    end;

    procedure TotalCostofResourcesName(): Text[100]
    begin
        exit(TotalCostofResourcesLbl);
    end;

    procedure TOTALCOSTOFGOODSSOLDName(): Text[100]
    begin
        exit(TOTALCOSTOFGOODSSOLDLbl);
    end;

    procedure EXPENSESName(): Text[100]
    begin
        exit(EXPENSESLbl);
    end;

    procedure PersonnelName(): Text[100]
    begin
        exit(PersonnelLbl);
    end;

    procedure HourlyWagesName(): Text[100]
    begin
        exit(HourlyWagesLbl);
    end;

    procedure OvertimeWagesName(): Text[100]
    begin
        exit(OvertimeWagesLbl);
    end;

    procedure CommissionsPaidName(): Text[100]
    begin
        exit(CommissionsPaidLbl);
    end;

    procedure BonusesName(): Text[100]
    begin
        exit(BonusesLbl);
    end;

    procedure EmployerContributionsName(): Text[100]
    begin
        exit(EmployerContributionsLbl);
    end;

    procedure PensionfeesandrecurringcostsName(): Text[100]
    begin
        exit(PensionfeesandrecurringcostsLbl);
    end;

    procedure HealthInsuranceName(): Text[100]
    begin
        exit(HealthInsuranceLbl);
    end;

    procedure TotalPersonnelName(): Text[100]
    begin
        exit(TotalPersonnelLbl);
    end;

    procedure DepreciationFixedAssetsName(): Text[100]
    begin
        exit(DepreciationFixedAssetsLbl);
    end;

    procedure DepreciationLandandPropertyName(): Text[100]
    begin
        exit(DepreciationLandandPropertyLbl);
    end;

    procedure MiscexternalexpensesName(): Text[100]
    begin
        exit(MiscexternalexpensesLbl);
    end;

    procedure OtherExternalServicesName(): Text[100]
    begin
        exit(OtherExternalServicesLbl);
    end;

    procedure RentalFacilitiesName(): Text[100]
    begin
        exit(RentalFacilitiesLbl);
    end;

    procedure RentLeasesName(): Text[100]
    begin
        exit(RentLeasesLbl);
    end;

    procedure HeatingforRentalName(): Text[100]
    begin
        exit(HeatingforRentalLbl);
    end;

    procedure ElectricityforRentalName(): Text[100]
    begin
        exit(ElectricityforRentalLbl);
    end;

    procedure WaterandSewerageforRentalName(): Text[100]
    begin
        exit(WaterandSewerageforRentalLbl);
    end;

    procedure CleaningandWasteforRentalName(): Text[100]
    begin
        exit(CleaningandWasteforRentalLbl);
    end;

    procedure RepairsandMaintenanceforRentalName(): Text[100]
    begin
        exit(RepairsandMaintenanceforRentalLbl);
    end;

    procedure InsurancesRentalName(): Text[100]
    begin
        exit(InsurancesRentalLbl);
    end;

    procedure OtherRentalExpensesName(): Text[100]
    begin
        exit(OtherRentalExpensesLbl);
    end;

    procedure TotalRentalFacilitiesName(): Text[100]
    begin
        exit(TotalRentalFacilitiesLbl);
    end;

    procedure CorporateInsuranceName(): Text[100]
    begin
        exit(CorporateInsuranceLbl);
    end;

    procedure PassengerCarCostsName(): Text[100]
    begin
        exit(PassengerCarCostsLbl);
    end;

    procedure TruckCostsName(): Text[100]
    begin
        exit(TruckCostsLbl);
    end;

    procedure OthervehicleexpensesName(): Text[100]
    begin
        exit(OthervehicleexpensesLbl);
    end;

    procedure AdvertisementDevelopmentName(): Text[100]
    begin
        exit(AdvertisementDevelopmentLbl);
    end;

    procedure OutdoorandTransportationAdsName(): Text[100]
    begin
        exit(OutdoorandTransportationAdsLbl);
    end;

    procedure AdmatteranddirectmailingsName(): Text[100]
    begin
        exit(AdmatteranddirectmailingsLbl);
    end;

    procedure ConferenceExhibitionSponsorshipName(): Text[100]
    begin
        exit(ConferenceExhibitionSponsorshipLbl);
    end;

    procedure FilmTVradiointernetadsName(): Text[100]
    begin
        exit(FilmTVradiointernetadsLbl);
    end;

    procedure SamplescontestsgiftsName(): Text[100]
    begin
        exit(SamplescontestsgiftsLbl);
    end;

    procedure BusinessEntertainingdeductibleName(): Text[100]
    begin
        exit(BusinessEntertainingdeductibleLbl);
    end;

    procedure BusinessEntertainingnondeductibleName(): Text[100]
    begin
        exit(BusinessEntertainingnondeductibleLbl);
    end;

    procedure TravelExpensesName(): Text[100]
    begin
        exit(TravelExpensesLbl);
    end;

    procedure OthertravelexpensesName(): Text[100]
    begin
        exit(OthertravelexpensesLbl);
    end;

    procedure BoardandlodgingName(): Text[100]
    begin
        exit(BoardandlodgingLbl);
    end;

    procedure TicketsName(): Text[100]
    begin
        exit(TicketsLbl);
    end;

    procedure RentalvehiclesName(): Text[100]
    begin
        exit(RentalvehiclesLbl);
    end;

    procedure TotalTravelExpensesName(): Text[100]
    begin
        exit(TotalTravelExpensesLbl);
    end;

    procedure CreditCardChargesName(): Text[100]
    begin
        exit(CreditCardChargesLbl);
    end;

    procedure FreightfeesforgoodsName(): Text[100]
    begin
        exit(FreightfeesforgoodsLbl);
    end;

    procedure CustomsandforwardingName(): Text[100]
    begin
        exit(CustomsandforwardingLbl);
    end;

    procedure FreightfeesprojectsName(): Text[100]
    begin
        exit(FreightfeesprojectsLbl);
    end;

    procedure PostalfeesName(): Text[100]
    begin
        exit(PostalfeesLbl);
    end;

    procedure PhoneServicesName(): Text[100]
    begin
        exit(PhoneServicesLbl);
    end;

    procedure DataservicesName(): Text[100]
    begin
        exit(DataservicesLbl);
    end;

    procedure LegalFeesandAttorneyServicesName(): Text[100]
    begin
        exit(LegalFeesandAttorneyServicesLbl);
    end;

    procedure AnnualinterrimReportsName(): Text[100]
    begin
        exit(AnnualinterrimReportsLbl);
    end;

    procedure AccountingServicesName(): Text[100]
    begin
        exit(AccountingServicesLbl);
    end;

    procedure HireofmachineryName(): Text[100]
    begin
        exit(HireofmachineryLbl);
    end;

    procedure SoftwareandsubscriptionfeesName(): Text[100]
    begin
        exit(SoftwareandsubscriptionfeesLbl);
    end;

    procedure HireofcomputersName(): Text[100]
    begin
        exit(HireofcomputersLbl);
    end;

    procedure HireofotherfixedassetsName(): Text[100]
    begin
        exit(HireofotherfixedassetsLbl);
    end;

    procedure ConsumableExpensiblehardwareName(): Text[100]
    begin
        exit(ConsumableExpensiblehardwareLbl);
    end;

    procedure CurrencyLossesName(): Text[100]
    begin
        exit(CurrencyLossesLbl);
    end;

    procedure BadDebtLossesName(): Text[100]
    begin
        exit(BadDebtLossesLbl);
    end;

    procedure PurchaseDiscountsName(): Text[100]
    begin
        exit(PurchaseDiscountsLbl);
    end;

    procedure PayableInvoiceRoundingName(): Text[100]
    begin
        exit(PayableInvoiceRoundingLbl);
    end;

    procedure SalesInvoiceRoundingName(): Text[100]
    begin
        exit(SalesInvoiceRoundingLbl);
    end;

    procedure TOTALEXPENSESName(): Text[100]
    begin
        exit(TOTALEXPENSESLbl);
    end;

    procedure DevelopmentExpenditure(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DevelopmentExpenditureName()));
    end;

    procedure Goodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodwillName()));
    end;

    procedure AdvancedPaymentsforIntangibleFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancedPaymentsforIntangibleFixedAssetsName()));
    end;

    procedure Land(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LandName()));
    end;

    procedure TenancySiteLeaseholdandsimilarrights(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TenancySiteLeaseholdandsimilarrightsName()));
    end;

    procedure Building(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BuildingName()));
    end;

    procedure CostofImprovementstoLeasedProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofImprovementstoLeasedPropertyName()));
    end;

    procedure EquipmentsandTools(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquipmentsandToolsName()));
    end;

    procedure AccumulatedDepreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumulatedDepreciationName()));
    end;

    procedure LeasedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LeasedAssetsName()));
    end;

    procedure CarsandotherTransportEquipments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CarsandotherTransportEquipmentsName()));
    end;

    procedure Computers(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ComputersName()));
    end;

    procedure PrepaidRent(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaidRentName()));
    end;

    procedure ParticipationinGroupCompanies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ParticipationinGroupCompaniesName()));
    end;

    procedure LoanstoPartnersorrelatedParties(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LoanstoPartnersorrelatedPartiesName()));
    end;

    procedure Convertibledebtinstruments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConvertibledebtinstrumentsName()));
    end;

    procedure InventoriesProductsandworkinProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoriesProductsandworkinProgressName()));
    end;

    procedure SuppliesandConsumables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SuppliesandConsumablesName()));
    end;

    procedure ProductsinProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProductsinProgressName()));
    end;

    procedure WorkinProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WorkinProgressName()));
    end;

    procedure WIPAccruedCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPAccruedCostsName()));
    end;

    procedure WIPInvoicedSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPInvoicedSalesName()));
    end;

    procedure TotalWorkinProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalWorkinProgressName()));
    end;

    procedure TotalInventoryProductsandWorkinProgress(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalInventoryProductsandWorkinProgressName()));
    end;

    procedure GoodsforResale(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsforResaleName()));
    end;

    procedure OtherInventoryItems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherInventoryItemsName()));
    end;

    procedure AdvancedPaymentsforgoodsandservices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancedPaymentsforgoodsandservicesName()));
    end;

    procedure Receivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceivablesName()));
    end;

    procedure AccountReceivableDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountReceivableDomesticName()));
    end;

    procedure AccountReceivableForeign(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountReceivableForeignName()));
    end;

    procedure LongtermReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LongtermReceivablesName()));
    end;

    procedure CurrentReceivablesfromgroupcompanies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentReceivablesfromgroupcompaniesName()));
    end;

    procedure CurrentReceivablefromEmployees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentReceivablefromEmployeesName()));
    end;

    procedure ContractualReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ContractualReceivablesName()));
    end;

    procedure MiscVATReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscVATReceivablesName()));
    end;

    procedure PurchaseVATReduced(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVATReducedName()));
    end;

    procedure PurchaseVATNormal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVATNormalName()));
    end;

    procedure TaxAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxAssetsName()));
    end;

    procedure ClearingAccountsforTaxesandcharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ClearingAccountsforTaxesandchargesName()));
    end;

    procedure TotalReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalReceivablesName()));
    end;

    procedure CashandBank(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashandBankName()));
    end;

    procedure BusinessaccountOperatingDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessaccountOperatingDomesticName()));
    end;

    procedure BusinessaccountOperatingForeign(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessaccountOperatingForeignName()));
    end;

    procedure Otherbankaccounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherbankaccountsName()));
    end;

    procedure TotalCashandBank(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCashandBankName()));
    end;

    procedure Assetsintheformofprepaidexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AssetsintheformofprepaidexpensesName()));
    end;

    procedure DeferredTaxAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferredTaxAssetsName()));
    end;

    procedure CertificateofDeposit(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CertificateofDepositName()));
    end;

    procedure Equity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquityName()));
    end;

    procedure EquityPartner(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquityPartnerName()));
    end;

    procedure ShareCapital(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShareCapitalName()));
    end;

    procedure DistributionstoShareholders(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DistributionstoShareholdersName()));
    end;

    procedure Profitorlossfromthepreviousyear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProfitorlossfromthepreviousyearName()));
    end;

    procedure TotalEquity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalEquityName()));
    end;

    procedure Liability(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LiabilityName()));
    end;

    procedure EstimatedPayrolltaxonPensionCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EstimatedPayrolltaxonPensionCostsName()));
    end;

    procedure EstimatedIncomeTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EstimatedIncomeTaxName()));
    end;

    procedure HolidayPayfund(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HolidayPayfundName()));
    end;

    procedure BondsandDebentureLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BondsandDebentureLoansName()));
    end;

    procedure ConvertiblesLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConvertiblesLoansName()));
    end;

    procedure OtherLongtermLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherLongtermLiabilitiesName()));
    end;

    procedure BankoverdraftFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankoverdraftFacilitiesName()));
    end;

    procedure Bankoverdraftshortterm(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankoverdraftshorttermName()));
    end;

    procedure Advancesfromcustomers(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvancesfromcustomersName()));
    end;

    procedure AccountsPayableDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsPayableDomesticName()));
    end;

    procedure AccountsPayableForeign(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsPayableForeignName()));
    end;

    procedure CurrentLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentLoansName()));
    end;

    procedure TaxesLiable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxesLiableName()));
    end;

    procedure EmployeesWithholdingTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployeesWithholdingTaxesName()));
    end;

    procedure CurrentLiabilitiestoEmployees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentLiabilitiestoEmployeesName()));
    end;

    procedure AttachmentsofEarning(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AttachmentsofEarningName()));
    end;

    procedure StatutorySocialsecurityContributions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StatutorySocialsecurityContributionsName()));
    end;

    procedure MiscVATPayables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscVATPayablesName()));
    end;

    procedure SalesVATReduced(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesVATReducedName()));
    end;

    procedure SalesVATNormal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesVATNormalName()));
    end;

    procedure DeferredRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferredRevenueName()));
    end;

    procedure Income(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeName()));
    end;

    procedure Incomefromsecurities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomefromsecuritiesName()));
    end;

    procedure ManagementFeeRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManagementFeeRevenueName()));
    end;

    procedure SalesofGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofGoodsName()));
    end;

    procedure SaleofFinishedGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SaleofFinishedGoodsName()));
    end;

    procedure SaleofRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SaleofRawMaterialsName()));
    end;

    procedure ResaleofGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResaleofGoodsName()));
    end;

    procedure TotalSalesofGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesofGoodsName()));
    end;

    procedure SaleofResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SaleofResourcesName()));
    end;

    procedure SaleofSubcontracting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SaleofSubcontractingName()));
    end;

    procedure JobsandServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobsandServicesName()));
    end;

    procedure JobSalesApplied(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobSalesAppliedName()));
    end;

    procedure SalesofServiceContracts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofServiceContractsName()));
    end;

    procedure SalesofServiceWork(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofServiceWorkName()));
    end;

    procedure TotalJobsandServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalJobsandServicesName()));
    end;

    procedure RevenueReductions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenueReductionsName()));
    end;

    procedure SalesDiscounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesDiscountsName()));
    end;

    procedure SalesReturns(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesReturnsName()));
    end;

    procedure TotalRevenueReductions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRevenueReductionsName()));
    end;

    procedure OtherIncidentalRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherIncidentalRevenueName()));
    end;

    procedure CurrencyGains(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrencyGainsName()));
    end;

    procedure TOTALINCOME(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TOTALINCOMEName()));
    end;

    procedure COSTOFGOODSSOLD(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(COSTOFGOODSSOLDName()));
    end;

    procedure CostofGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofGoodsName()));
    end;

    procedure CostofMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofMaterialsName()));
    end;

    procedure CostofMaterialsProjects(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofMaterialsProjectsName()));
    end;

    procedure TotalCostofGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostofGoodsName()));
    end;

    procedure ManufVariances(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ManufVariancesName()));
    end;

    procedure PurchaseVarianceCap(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVarianceCapName()));
    end;

    procedure MaterialVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaterialVarianceName()));
    end;

    procedure CapacityVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapacityVarianceName()));
    end;

    procedure SubcontractedVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubcontractedVarianceName()));
    end;

    procedure CapOverheadVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapOverheadVarianceName()));
    end;

    procedure MfgOverheadVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MfgOverheadVarianceName()));
    end;

    procedure TotalManufVariances(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalManufVariancesName()));
    end;

    procedure CostofVariances(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofVariancesName()));
    end;

    procedure CostsofJobs(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostsofJobsName()));
    end;

    procedure JobCostsApplied(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostsAppliedName()));
    end;

    procedure TotalCostsofJobs(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostsofJobsName()));
    end;

    procedure CostofResourcesandServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofResourcesandServicesName()));
    end;

    procedure CostofLabor(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofLaborName()));
    end;

    procedure CostofLaborProjects(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofLaborProjectsName()));
    end;

    procedure CostofLaborWarrantyContract(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofLaborWarrantyContractName()));
    end;

    procedure Subcontractedwork(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubcontractedworkName()));
    end;

    procedure TotalCostofResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostofResourcesName()));
    end;

    procedure TOTALCOSTOFGOODSSOLD(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TOTALCOSTOFGOODSSOLDName()));
    end;

    procedure EXPENSES(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EXPENSESName()));
    end;

    procedure Personnel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PersonnelName()));
    end;

    procedure HourlyWages(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HourlyWagesName()));
    end;

    procedure OvertimeWages(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OvertimeWagesName()));
    end;

    procedure CommissionsPaid(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CommissionsPaidName()));
    end;

    procedure Bonuses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BonusesName()));
    end;

    procedure EmployerContributions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployerContributionsName()));
    end;

    procedure Pensionfeesandrecurringcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PensionfeesandrecurringcostsName()));
    end;

    procedure HealthInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HealthInsuranceName()));
    end;

    procedure TotalPersonnel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPersonnelName()));
    end;

    procedure DepreciationFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationFixedAssetsName()));
    end;

    procedure DepreciationLandandProperty(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationLandandPropertyName()));
    end;

    procedure Miscexternalexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscexternalexpensesName()));
    end;

    procedure OtherExternalServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherExternalServicesName()));
    end;

    procedure RentalFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentalFacilitiesName()));
    end;

    procedure RentLeases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentLeasesName()));
    end;

    procedure HeatingforRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HeatingforRentalName()));
    end;

    procedure ElectricityforRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ElectricityforRentalName()));
    end;

    procedure WaterandSewerageforRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WaterandSewerageforRentalName()));
    end;

    procedure CleaningandWasteforRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CleaningandWasteforRentalName()));
    end;

    procedure RepairsandMaintenanceforRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RepairsandMaintenanceforRentalName()));
    end;

    procedure InsurancesRental(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesRentalName()));
    end;

    procedure OtherRentalExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherRentalExpensesName()));
    end;

    procedure TotalRentalFacilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRentalFacilitiesName()));
    end;

    procedure CorporateInsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CorporateInsuranceName()));
    end;

    procedure PassengerCarCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PassengerCarCostsName()));
    end;

    procedure TruckCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TruckCostsName()));
    end;

    procedure Othervehicleexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthervehicleexpensesName()));
    end;

    procedure AdvertisementDevelopment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvertisementDevelopmentName()));
    end;

    procedure OutdoorandTransportationAds(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OutdoorandTransportationAdsName()));
    end;

    procedure Admatteranddirectmailings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdmatteranddirectmailingsName()));
    end;

    procedure ConferenceExhibitionSponsorship(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConferenceExhibitionSponsorshipName()));
    end;

    procedure FilmTVradiointernetads(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FilmTVradiointernetadsName()));
    end;

    procedure Samplescontestsgifts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SamplescontestsgiftsName()));
    end;

    procedure BusinessEntertainingdeductible(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessEntertainingdeductibleName()));
    end;

    procedure BusinessEntertainingnondeductible(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BusinessEntertainingnondeductibleName()));
    end;

    procedure TravelExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TravelExpensesName()));
    end;

    procedure Othertravelexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OthertravelexpensesName()));
    end;

    procedure Boardandlodging(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BoardandlodgingName()));
    end;

    procedure Tickets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TicketsName()));
    end;

    procedure Rentalvehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentalvehiclesName()));
    end;

    procedure TotalTravelExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalTravelExpensesName()));
    end;

    procedure CreditCardCharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CreditCardChargesName()));
    end;

    procedure Freightfeesforgoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightfeesforgoodsName()));
    end;

    procedure Customsandforwarding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomsandforwardingName()));
    end;

    procedure Freightfeesprojects(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightfeesprojectsName()));
    end;

    procedure Postalfees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PostalfeesName()));
    end;

    procedure PhoneServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PhoneServicesName()));
    end;

    procedure Dataservices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DataservicesName()));
    end;

    procedure LegalFeesandAttorneyServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LegalFeesandAttorneyServicesName()));
    end;

    procedure AnnualinterrimReports(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AnnualinterrimReportsName()));
    end;

    procedure AccountingServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountingServicesName()));
    end;

    procedure Hireofmachinery(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HireofmachineryName()));
    end;

    procedure Softwareandsubscriptionfees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SoftwareandsubscriptionfeesName()));
    end;

    procedure Hireofcomputers(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HireofcomputersName()));
    end;

    procedure Hireofotherfixedassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HireofotherfixedassetsName()));
    end;

    procedure ConsumableExpensiblehardware(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsumableExpensiblehardwareName()));
    end;

    procedure CurrencyLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrencyLossesName()));
    end;

    procedure BadDebtLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BadDebtLossesName()));
    end;

    procedure PurchaseDiscounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseDiscountsName()));
    end;

    procedure PayableInvoiceRounding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayableInvoiceRoundingName()));
    end;

    procedure SalesInvoiceRounding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesInvoiceRoundingName()));
    end;

    procedure TOTALEXPENSES(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TOTALEXPENSESName()));
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        DevelopmentExpenditureLbl: Label 'Development Expenditure', MaxLength = 100;
        GoodwillLbl: Label 'Goodwill', MaxLength = 100;
        AdvancedPaymentsforIntangibleFixedAssetsLbl: Label 'Advanced Payments for Intangible Fixed Assets', MaxLength = 100;
        LandLbl: Label 'Land ', MaxLength = 100;
        TenancySiteLeaseholdandsimilarrightsLbl: Label 'Tenancy, Site Leasehold and similar rights', MaxLength = 100;
        BuildingLbl: Label 'Building', MaxLength = 100;
        CostofImprovementstoLeasedPropertyLbl: Label 'Cost of Improvements to Leased Property', MaxLength = 100;
        EquipmentsandToolsLbl: Label 'Equipments and Tools', MaxLength = 100;
        AccumulatedDepreciationLbl: Label 'Accumulated Depreciation', MaxLength = 100;
        LeasedAssetsLbl: Label 'Leased Assets', MaxLength = 100;
        CarsandotherTransportEquipmentsLbl: Label 'Cars and other Transport Equipments', MaxLength = 100;
        ComputersLbl: Label 'Computers', MaxLength = 100;
        PrepaidRentLbl: Label 'Prepaid Rent', MaxLength = 100;
        ParticipationinGroupCompaniesLbl: Label 'Participation in Group Companies', MaxLength = 100;
        LoanstoPartnersorrelatedPartiesLbl: Label 'Loans to Partners or related Parties', MaxLength = 100;
        ConvertibledebtinstrumentsLbl: Label 'Convertible debt instruments', MaxLength = 100;
        InventoriesProductsandworkinProgressLbl: Label 'Inventories, Products and work in Progress', MaxLength = 100;
        SuppliesandConsumablesLbl: Label 'Supplies and Consumables', MaxLength = 100;
        ProductsinProgressLbl: Label 'Products in Progress', MaxLength = 100;
        WorkinProgressLbl: Label 'Work in Progress', MaxLength = 100;
        WIPAccruedCostsLbl: Label 'WIP, Accrued Costs', MaxLength = 100;
        WIPInvoicedSalesLbl: Label 'WIP, Invoiced Sales', MaxLength = 100;
        TotalWorkinProgressLbl: Label 'Total, Work in Progress', MaxLength = 100;
        TotalInventoryProductsandWorkinProgressLbl: Label 'Total, Inventory, Products and Work in Progress', MaxLength = 100;
        GoodsforResaleLbl: Label 'Goods for Resale', MaxLength = 100;
        OtherInventoryItemsLbl: Label 'Other Inventory Items', MaxLength = 100;
        AdvancedPaymentsforgoodsandservicesLbl: Label 'Advanced Payments for goods and services', MaxLength = 100;
        ReceivablesLbl: Label 'Receivables', MaxLength = 100;
        AccountReceivableDomesticLbl: Label 'Account Receivable, Domestic', MaxLength = 100;
        AccountReceivableForeignLbl: Label 'Account Receivable, Foreign', MaxLength = 100;
        LongtermReceivablesLbl: Label 'Long-term Receivables ', MaxLength = 100;
        CurrentReceivablesfromgroupcompaniesLbl: Label 'Current Receivables from group companies', MaxLength = 100;
        CurrentReceivablefromEmployeesLbl: Label 'Current Receivable from Employees', MaxLength = 100;
        ContractualReceivablesLbl: Label 'Contractual Receivables', MaxLength = 100;
        MiscVATReceivablesLbl: Label 'Misc VAT Receivables', MaxLength = 100;
        PurchaseVATReducedLbl: Label 'Purchase VAT Reduced', MaxLength = 100;
        PurchaseVATNormalLbl: Label 'Purchase VAT Normal', MaxLength = 100;
        TaxAssetsLbl: Label 'Tax Assets', MaxLength = 100;
        ClearingAccountsforTaxesandchargesLbl: Label 'Clearing Accounts for Taxes and charges', MaxLength = 100;
        TotalReceivablesLbl: Label 'Total, Receivables', MaxLength = 100;
        CashandBankLbl: Label 'Cash and Bank', MaxLength = 100;
        BusinessaccountOperatingDomesticLbl: Label 'Business account, Operating, Domestic', MaxLength = 100;
        BusinessaccountOperatingForeignLbl: Label 'Business account, Operating, Foreign', MaxLength = 100;
        OtherbankaccountsLbl: Label 'Other bank accounts ', MaxLength = 100;
        TotalCashandBankLbl: Label 'Total, Cash and Bank', MaxLength = 100;
        AssetsintheformofprepaidexpensesLbl: Label 'Assets in the form of prepaid expenses', MaxLength = 100;
        DeferredTaxAssetsLbl: Label 'Deferred Tax Assets', MaxLength = 100;
        CertificateofDepositLbl: Label 'Certificate of Deposit', MaxLength = 100;
        EquityLbl: Label 'Equity', MaxLength = 100;
        EquityPartnerLbl: Label 'Equity Partner ', MaxLength = 100;
        ShareCapitalLbl: Label 'Share Capital ', MaxLength = 100;
        DistributionstoShareholdersLbl: Label 'Distributions to Shareholders', MaxLength = 100;
        ProfitorlossfromthepreviousyearLbl: Label 'Profit or loss from the previous year', MaxLength = 100;
        TotalEquityLbl: Label 'Total, Equity', MaxLength = 100;
        LiabilityLbl: Label 'Liability', MaxLength = 100;
        EstimatedPayrolltaxonPensionCostsLbl: Label 'Estimated Payroll tax on Pension Costs', MaxLength = 100;
        EstimatedIncomeTaxLbl: Label 'Estimated Income Tax', MaxLength = 100;
        HolidayPayfundLbl: Label 'Holiday Pay fund', MaxLength = 100;
        BondsandDebentureLoansLbl: Label 'Bonds and Debenture Loans', MaxLength = 100;
        ConvertiblesLoansLbl: Label 'Convertibles Loans', MaxLength = 100;
        OtherLongtermLiabilitiesLbl: Label 'Other Long-term Liabilities', MaxLength = 100;
        BankoverdraftFacilitiesLbl: Label 'Bank overdraft Facilities', MaxLength = 100;
        BankoverdraftshorttermLbl: Label 'Bank overdraft short-term', MaxLength = 100;
        AdvancesfromcustomersLbl: Label 'Advances from customers', MaxLength = 100;
        AccountsPayableDomesticLbl: Label 'Accounts Payable, Domestic', MaxLength = 100;
        AccountsPayableForeignLbl: Label 'Accounts Payable, Foreign', MaxLength = 100;
        CurrentLoansLbl: Label 'Current Loans', MaxLength = 100;
        TaxesLiableLbl: Label 'Taxes Liable', MaxLength = 100;
        EmployeesWithholdingTaxesLbl: Label 'Employees Withholding Taxes', MaxLength = 100;
        CurrentLiabilitiestoEmployeesLbl: Label 'Current Liabilities to Employees', MaxLength = 100;
        AttachmentsofEarningLbl: Label 'Attachments of Earning', MaxLength = 100;
        StatutorySocialsecurityContributionsLbl: Label 'Statutory Social security Contributions', MaxLength = 100;
        MiscVATPayablesLbl: Label 'Misc VAT Payables', MaxLength = 100;
        SalesVATReducedLbl: Label 'Sales VAT Reduced', MaxLength = 100;
        SalesVATNormalLbl: Label 'Sales VAT Normal', MaxLength = 100;
        DeferredRevenueLbl: Label 'Deferred Revenue', MaxLength = 100;
        IncomeLbl: Label 'Income', MaxLength = 100;
        IncomefromsecuritiesLbl: Label 'Income from securities', MaxLength = 100;
        ManagementFeeRevenueLbl: Label 'Management Fee Revenue', MaxLength = 100;
        SalesofGoodsLbl: Label 'Sales of Goods', MaxLength = 100;
        SaleofFinishedGoodsLbl: Label 'Sale of Finished Goods', MaxLength = 100;
        SaleofRawMaterialsLbl: Label 'Sale of Raw Materials', MaxLength = 100;
        ResaleofGoodsLbl: Label 'Resale of Goods', MaxLength = 100;
        TotalSalesofGoodsLbl: Label 'Total, Sales of Goods', MaxLength = 100;
        SaleofResourcesLbl: Label 'Sale of Resource', MaxLength = 100;
        SaleofSubcontractingLbl: Label 'Sale of Subcontracting', MaxLength = 100;
        JobsandServicesLbl: Label 'Jobs and Services', MaxLength = 100;
        JobSalesAppliedLbl: Label 'Job Sales Applied', MaxLength = 100;
        SalesofServiceContractsLbl: Label 'Sales of Service Contracts', MaxLength = 100;
        SalesofServiceWorkLbl: Label 'Sales of Service Work', MaxLength = 100;
        TotalJobsandServicesLbl: Label 'Total, Jobs and Services', MaxLength = 100;
        RevenueReductionsLbl: Label 'Revenue Reductions', MaxLength = 100;
        SalesDiscountsLbl: Label 'Sales Discounts', MaxLength = 100;
        SalesReturnsLbl: Label 'Sales Returns', MaxLength = 100;
        TotalRevenueReductionsLbl: Label 'Total, Revenue Reductions', MaxLength = 100;
        OtherIncidentalRevenueLbl: Label 'Other Incidental Revenue', MaxLength = 100;
        CurrencyGainsLbl: Label 'Currency Gains', MaxLength = 100;
        TOTALINCOMELbl: Label 'TOTAL INCOME', MaxLength = 100;
        COSTOFGOODSSOLDLbl: Label 'COST OF GOODS SOLD', MaxLength = 100;
        CostofGoodsLbl: Label 'Cost of Goods', MaxLength = 100;
        CostofMaterialsLbl: Label 'Cost of Materials', MaxLength = 100;
        CostofMaterialsProjectsLbl: Label 'Cost of Materials, Projects', MaxLength = 100;
        TotalCostofGoodsLbl: Label 'Total, Cost of Goods', MaxLength = 100;
        ManufVariancesLbl: Label 'Manuf. Variances', MaxLength = 100;
        PurchaseVarianceCapLbl: Label 'Purchase Variance, Cap.', MaxLength = 100;
        MaterialVarianceLbl: Label 'Material Variance', MaxLength = 100;
        CapacityVarianceLbl: Label 'Capacity Variance', MaxLength = 100;
        SubcontractedVarianceLbl: Label 'Subcontracted Variance', MaxLength = 100;
        CapOverheadVarianceLbl: Label 'Cap. Overhead Variance', MaxLength = 100;
        MfgOverheadVarianceLbl: Label 'Mfg. Overhead Variance', MaxLength = 100;
        TotalManufVariancesLbl: Label 'Total, Manuf. Variances', MaxLength = 100;
        CostofVariancesLbl: Label 'Cost of Variances', MaxLength = 100;
        CostsofJobsLbl: Label 'Costs of Jobs', MaxLength = 100;
        JobCostsAppliedLbl: Label 'Job Costs, Applied', MaxLength = 100;
        TotalCostsofJobsLbl: Label 'Total, Costs of Jobs', MaxLength = 100;
        CostofResourcesandServicesLbl: Label 'Cost of Resources and Services', MaxLength = 100;
        CostofLaborLbl: Label 'Cost of Labor', MaxLength = 100;
        CostofLaborProjectsLbl: Label 'Cost of Labor, Projects', MaxLength = 100;
        CostofLaborWarrantyContractLbl: Label 'Cost of Labor, Warranty/Contract', MaxLength = 100;
        SubcontractedworkLbl: Label 'Subcontracted work', MaxLength = 100;
        TotalCostofResourcesLbl: Label 'Total, Cost of Resources', MaxLength = 100;
        TOTALCOSTOFGOODSSOLDLbl: Label 'TOTAL COST OF GOODS SOLD', MaxLength = 100;
        EXPENSESLbl: Label 'EXPENSES', MaxLength = 100;
        PersonnelLbl: Label 'Personnel', MaxLength = 100;
        HourlyWagesLbl: Label 'Hourly Wages', MaxLength = 100;
        OvertimeWagesLbl: Label 'Overtime Wages', MaxLength = 100;
        CommissionsPaidLbl: Label 'Commissions Paid', MaxLength = 100;
        BonusesLbl: Label 'Bonuses', MaxLength = 100;
        EmployerContributionsLbl: Label 'Employer Contributions', MaxLength = 100;
        PensionfeesandrecurringcostsLbl: Label 'Pension fees and recurring costs', MaxLength = 100;
        HealthInsuranceLbl: Label 'Health Insurance', MaxLength = 100;
        TotalPersonnelLbl: Label 'Total, Personnel', MaxLength = 100;
        DepreciationFixedAssetsLbl: Label 'Depreciation, Fixed Assets', MaxLength = 100;
        DepreciationLandandPropertyLbl: Label 'Depreciation, Land and Property', MaxLength = 100;
        MiscexternalexpensesLbl: Label 'Misc. external expenses', MaxLength = 100;
        OtherExternalServicesLbl: Label 'Other External Services', MaxLength = 100;
        RentalFacilitiesLbl: Label 'Rental Facilities', MaxLength = 100;
        RentLeasesLbl: Label 'Rent / Leases', MaxLength = 100;
        HeatingforRentalLbl: Label 'Heating for Rental', MaxLength = 100;
        ElectricityforRentalLbl: Label 'Electricity for Rental', MaxLength = 100;
        WaterandSewerageforRentalLbl: Label 'Water and Sewerage for Rental', MaxLength = 100;
        CleaningandWasteforRentalLbl: Label 'Cleaning and Waste for Rental', MaxLength = 100;
        RepairsandMaintenanceforRentalLbl: Label 'Repairs and Maintenance for Rental', MaxLength = 100;
        InsurancesRentalLbl: Label 'Insurances, Rental', MaxLength = 100;
        OtherRentalExpensesLbl: Label 'Other Rental Expenses', MaxLength = 100;
        TotalRentalFacilitiesLbl: Label 'Total, Rental Facilities', MaxLength = 100;
        CorporateInsuranceLbl: Label 'Corporate Insurance', MaxLength = 100;
        PassengerCarCostsLbl: Label 'Passenger Car Costs', MaxLength = 100;
        TruckCostsLbl: Label 'Truck Costs', MaxLength = 100;
        OthervehicleexpensesLbl: Label 'Other vehicle expenses', MaxLength = 100;
        AdvertisementDevelopmentLbl: Label 'Advertisement Development', MaxLength = 100;
        OutdoorandTransportationAdsLbl: Label 'Outdoor and Transportation Ads', MaxLength = 100;
        AdmatteranddirectmailingsLbl: Label 'Ad matter and direct mailings', MaxLength = 100;
        ConferenceExhibitionSponsorshipLbl: Label 'Conference/Exhibition Sponsorship', MaxLength = 100;
        FilmTVradiointernetadsLbl: Label 'Film, TV, radio, internet ads', MaxLength = 100;
        SamplescontestsgiftsLbl: Label 'Samples, contests, gifts', MaxLength = 100;
        BusinessEntertainingdeductibleLbl: Label 'Business Entertaining, deductible', MaxLength = 100;
        BusinessEntertainingnondeductibleLbl: Label 'Business Entertaining, nondeductible', MaxLength = 100;
        TravelExpensesLbl: Label 'Travel Expenses', MaxLength = 100;
        OthertravelexpensesLbl: Label 'Other travel expenses', MaxLength = 100;
        BoardandlodgingLbl: Label 'Board and lodging', MaxLength = 100;
        TicketsLbl: Label 'Tickets', MaxLength = 100;
        RentalvehiclesLbl: Label 'Rental vehicles', MaxLength = 100;
        TotalTravelExpensesLbl: Label 'Total, Travel Expenses', MaxLength = 100;
        CreditCardChargesLbl: Label 'Credit Card Charges', MaxLength = 100;
        FreightfeesforgoodsLbl: Label 'Freight fees for goods', MaxLength = 100;
        CustomsandforwardingLbl: Label 'Customs and forwarding', MaxLength = 100;
        FreightfeesprojectsLbl: Label 'Freight fees, projects', MaxLength = 100;
        PostalfeesLbl: Label 'Postal fees', MaxLength = 100;
        PhoneServicesLbl: Label 'Phone Services', MaxLength = 100;
        DataservicesLbl: Label 'Data services', MaxLength = 100;
        LegalFeesandAttorneyServicesLbl: Label 'Legal Fees and Attorney Services', MaxLength = 100;
        AnnualinterrimReportsLbl: Label 'Annual/interrim Reports', MaxLength = 100;
        AccountingServicesLbl: Label 'Accounting Services', MaxLength = 100;
        HireofmachineryLbl: Label 'Hire of machinery', MaxLength = 100;
        SoftwareandsubscriptionfeesLbl: Label 'Software and subscription fees', MaxLength = 100;
        HireofcomputersLbl: Label 'Hire of computers', MaxLength = 100;
        HireofotherfixedassetsLbl: Label 'Hire of other fixed assets', MaxLength = 100;
        ConsumableExpensiblehardwareLbl: Label 'Consumable/Expensible hardware', MaxLength = 100;
        CurrencyLossesLbl: Label 'Currency Losses', MaxLength = 100;
        BadDebtLossesLbl: Label 'Bad Debt Losses', MaxLength = 100;
        PurchaseDiscountsLbl: Label 'Purchase Discounts', MaxLength = 100;
        PayableInvoiceRoundingLbl: Label 'Payable Invoice Rounding', MaxLength = 100;
        SalesInvoiceRoundingLbl: Label 'Sales Invoice Rounding', MaxLength = 100;
        TOTALEXPENSESLbl: Label 'TOTAL EXPENSES', MaxLength = 100;
}