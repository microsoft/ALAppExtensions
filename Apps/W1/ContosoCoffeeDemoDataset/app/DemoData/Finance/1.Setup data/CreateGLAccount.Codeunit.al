codeunit 5208 "Create G/L Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        GLAccountCategory: Record "G/L Account Category";
        GLAccountIndent: Codeunit "G/L Account-Indent";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        SubCategory: Text[80];
    begin
        AddGLAccountsForLocalization();

        ContosoGLAccount.InsertGLAccount(BalanceSheet(), BalanceSheetName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Heading, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(Assets(), AssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetEquipment(), 80);
        ContosoGLAccount.InsertGLAccount(FixedAssets(), FixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TangibleFixedAssets(), TangibleFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LandandBuildingsBeginTotal(), LandandBuildingsBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LandandBuildings(), LandandBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IncreasesduringtheYearBuildings(), IncreasesduringtheYearBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), false, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesduringtheYearBuildings(), DecreasesduringtheYearBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetAccumDeprec(), 80);
        ContosoGLAccount.InsertGLAccount(AccumDepreciationBuildings(), AccumDepreciationBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetEquipment(), 80);
        ContosoGLAccount.InsertGLAccount(LandandBuildingsTotal(), LandandBuildingsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, LandandBuildingsBeginTotal() + '..' + LandandBuildingsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OperatingEquipmentBeginTotal(), OperatingEquipmentBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OperatingEquipment(), OperatingEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IncreasesduringtheYearOperEquip(), IncreasesduringtheYearOperEquipName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesduringtheYearOperEquip(), DecreasesduringtheYearOperEquipName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), false, false, false);
        ContosoGLAccount.InsertGLAccount(AccumDeprOperEquip(), AccumDeprOperEquipName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OperatingEquipmentTotal(), OperatingEquipmentTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, OperatingEquipmentBeginTotal() + '..' + OperatingEquipmentTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VehiclesBeginTotal(), VehiclesBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Vehicles(), VehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IncreasesduringtheYearVehicles(), IncreasesduringtheYearVehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(DecreasesduringtheYearVehicles(), DecreasesduringtheYearVehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), false, false, false);
        ContosoGLAccount.InsertGLAccount(AccumDepreciationVehicles(), AccumDepreciationVehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VehiclesTotal(), VehiclesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, VehiclesBeginTotal() + '..' + VehiclesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TangibleFixedAssetsTotal(), TangibleFixedAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, TangibleFixedAssets() + '..' + TangibleFixedAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(FixedAssetsTotal(), FixedAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, FixedAssets() + '..' + FixedAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CurrentAssets(), CurrentAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetInventory(), 80);
        ContosoGLAccount.InsertGLAccount(Inventory(), InventoryName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ResaleItems(), ResaleItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ResaleItemsInterim(), ResaleItemsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofResaleSoldInterim(), CostofResaleSoldInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FinishedGoods(), FinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FinishedGoodsInterim(), FinishedGoodsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RawMaterials(), RawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RawMaterialsInterim(), RawMaterialsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofRawMatSoldInterim(), CostofRawMatSoldInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PrimoInventory(), PrimoInventoryName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InventoryTotal(), InventoryTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Inventory() + '..' + InventoryTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetPrepaidExpenses(), 80);
        ContosoGLAccount.InsertGLAccount(JobWIP(), JobWIPName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(WIPSales(), WIPSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WIPJobSales(), WIPJobSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InvoicedJobSales(), InvoicedJobSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WIPSalesTotal(), WIPSalesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, WIPSales() + '..' + WIPSalesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WIPCosts(), WIPCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WIPJobCosts(), WIPJobCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedJobCosts(), AccruedJobCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WIPCostsTotal(), WIPCostsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, WIPCosts() + '..' + WIPCostsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobWIPTotal(), JobWIPTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, JobWIP() + '..' + JobWIPTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetAR(), 80);
        ContosoGLAccount.InsertGLAccount(AccountsReceivable(), AccountsReceivableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CustomersDomestic(), CustomersDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CustomersForeign(), CustomersForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedInterest(), AccruedInterestName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherReceivables(), OtherReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsReceivableTotal(), AccountsReceivableTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, AccountsReceivable() + '..' + AccountsReceivableTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetPrepaidExpenses(), 80);
        ContosoGLAccount.InsertGLAccount(PurchasePrepayments(), PurchasePrepaymentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VendorPrepaymentsVAT(), VendorPrepaymentsVATName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::" ", '', CreateVATPostingGroups.Zero(), false, false, false);
        ContosoGLAccount.InsertGLAccount(VendorPrepaymentsVAT10(), VendorPrepaymentsVAT10Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', CreateVATPostingGroups.Reduced(), false, false, false);
        ContosoGLAccount.InsertGLAccount(VendorPrepaymentsVAT25(), VendorPrepaymentsVAT25Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', CreateVATPostingGroups.Standard(), false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchasePrepaymentsTotal(), PurchasePrepaymentsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, PurchasePrepayments() + '..' + PurchasePrepaymentsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(Securities(), SecuritiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Bonds(), BondsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SecuritiesTotal(), SecuritiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Securities() + '..' + SecuritiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCash(), 80);
        ContosoGLAccount.InsertGLAccount(LiquidAssets(), LiquidAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Cash(), CashName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(BankLCY(), BankLCYName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, true, false);
        ContosoGLAccount.InsertGLAccount(BankCurrencies(), BankCurrenciesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, true, false);
        ContosoGLAccount.InsertGLAccount(GiroAccount(), GiroAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, true, false);
        ContosoGLAccount.InsertGLAccount(LiquidAssetsTotal(), LiquidAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, LiquidAssets() + '..' + LiquidAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(CurrentAssetsTotal(), CurrentAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CurrentAssets() + '..' + CurrentAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalAssets(), TotalAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 1, Assets() + '..' + TotalAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(LiabilitiesAndEquity(), LiabilitiesAndEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Heading, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetDistrToShareholders(), 80);
        ContosoGLAccount.InsertGLAccount(Stockholder(), StockholderName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Heading, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCommonStock(), 80);
        ContosoGLAccount.InsertGLAccount(CapitalStock(), CapitalStockName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetRetEarnings(), 80);
        ContosoGLAccount.InsertGLAccount(RetainedEarnings(), RetainedEarningsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Equity, 80);
        ContosoGLAccount.InsertGLAccount(NetIncomefortheYear(), NetIncomefortheYearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, IncomeStatement() + '..' + NetIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalStockholder(), TotalStockholderName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, Stockholder() + '..' + TotalStockholder() + '|' + IncomeStatement() + '..' + NetIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Allowances(), AllowancesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCurrentLiabilities(), 80);
        ContosoGLAccount.InsertGLAccount(DeferredTaxes(), DeferredTaxesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Equity, 80);
        ContosoGLAccount.InsertGLAccount(AllowancesTotal(), AllowancesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Allowances() + '..' + AllowancesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Liabilities, 80);
        ContosoGLAccount.InsertGLAccount(Liabilities(), LiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetLongTermLiabilities(), 80);
        ContosoGLAccount.InsertGLAccount(LongtermLiabilities(), LongtermLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LongtermBankLoans(), LongtermBankLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Mortgage(), MortgageName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LongtermLiabilitiesTotal(), LongtermLiabilitiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, LongtermLiabilities() + '..' + LongtermLiabilitiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCurrentLiabilities(), 80);
        ContosoGLAccount.InsertGLAccount(ShorttermLiabilities(), ShorttermLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RevolvingCredit(), RevolvingCreditName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, true, false);
        ContosoGLAccount.InsertGLAccount(SalesPrepayments(), SalesPrepaymentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CustomerPrepaymentsVAT0(), CustomerPrepaymentsVAT0Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::" ", '', CreateVATPostingGroups.Zero(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CustomerPrepaymentsVAT10(), CustomerPrepaymentsVAT10Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', CreateVATPostingGroups.Reduced(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CustomerPrepaymentsVAT25(), CustomerPrepaymentsVAT25Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', CreateVATPostingGroups.Standard(), false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesPrepaymentsTotal(), SalesPrepaymentsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, SalesPrepayments() + '..' + SalesPrepaymentsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsPayable(), AccountsPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VendorsDomestic(), VendorsDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VendorsForeign(), VendorsForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AccountsPayableTotal(), AccountsPayableTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, AccountsPayable() + '..' + AccountsPayableTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InvAdjmtInterim(), InvAdjmtInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InvAdjmtInterimRetail(), InvAdjmtInterimRetailName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InvAdjmtInterimRawMat(), InvAdjmtInterimRawMatName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InvAdjmtInterimTotal(), InvAdjmtInterimTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, InvAdjmtInterim() + '..' + InvAdjmtInterimTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VAT(), VATName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesVAT25(), SalesVAT25Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesVAT10(), SalesVAT10Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetAR(), 80);
        ContosoGLAccount.InsertGLAccount(PurchaseVAT25EU(), PurchaseVAT25EUName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVAT10EU(), PurchaseVAT10EUName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVAT25(), PurchaseVAT25Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVAT10(), PurchaseVAT10Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Liabilities, 80);
        ContosoGLAccount.InsertGLAccount(FuelTax(), FuelTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ElectricityTax(), ElectricityTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(NaturalGasTax(), NaturalGasTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CoalTax(), CoalTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CO2Tax(), CO2TaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WaterTax(), WaterTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VATPayable(), VATPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VATTotal(), VATTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, VAT() + '..' + VATTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PersonnelrelatedItems(), PersonnelrelatedItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WithholdingTaxesPayable(), WithholdingTaxesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SupplementaryTaxesPayable(), SupplementaryTaxesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetPayrollLiabilities(), 80);
        ContosoGLAccount.InsertGLAccount(PayrollTaxesPayable(), PayrollTaxesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Liabilities, 80);
        ContosoGLAccount.InsertGLAccount(VacationCompensationPayable(), VacationCompensationPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(EmployeesPayable(), EmployeesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPersonnelrelatedItems(), TotalPersonnelrelatedItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, PersonnelrelatedItems() + '..' + TotalPersonnelrelatedItems(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherLiabilities(), OtherLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DividendsfortheFiscalYear(), DividendsfortheFiscalYearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CorporateTaxesPayable(), CorporateTaxesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherLiabilitiesTotal(), OtherLiabilitiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherLiabilities() + '..' + OtherLiabilitiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ShorttermLiabilitiesTotal(), ShorttermLiabilitiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, ShorttermLiabilities() + '..' + ShorttermLiabilitiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalLiabilities(), TotalLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Liabilities() + '..' + TotalLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(TotalLiabilitiesAndEquity(), TotalLiabilitiesAndEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 1, LiabilitiesAndEquity() + '..' + TotalLiabilitiesAndEquity() + '|' + IncomeStatement() + '..' + NetIncome(), Enum::"General Posting Type"::" ", '', '', false, false, true);
        ContosoGLAccount.InsertGLAccount(IncomeStatement(), IncomeStatementName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Heading, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Income, 80);
        ContosoGLAccount.InsertGLAccount(Revenue(), RevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetIncomeProdSales(), 80);
        ContosoGLAccount.InsertGLAccount(SalesofRetail(), SalesofRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRetailDom(), SalesRetailDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRetailEU(), SalesRetailEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.EU(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRetailExport(), SalesRetailExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Export(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateVATPostingGroups.Standard(), false, false, false);
        ContosoGLAccount.InsertGLAccount(JobSalesAppliedRetail(), JobSalesAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobSalesAdjmtRetail(), JobSalesAdjmtRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesofRetail(), TotalSalesofRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, SalesofRetail() + '..' + TotalSalesofRetail(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesofRawMaterials(), SalesofRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRawMaterialsDom(), SalesRawMaterialsDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRawMaterialsEU(), SalesRawMaterialsEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.EU(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRawMaterialsExport(), SalesRawMaterialsExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Export(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateVATPostingGroups.Standard(), false, false, false);
        ContosoGLAccount.InsertGLAccount(JobSalesAppliedRawMat(), JobSalesAppliedRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobSalesAdjmtRawMat(), JobSalesAdjmtRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesofRawMaterials(), TotalSalesofRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, SalesofRawMaterials() + '..' + TotalSalesofRawMaterials(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Income, 80);
        ContosoGLAccount.InsertGLAccount(SalesofResources(), SalesofResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetIncomeService(), 80);
        ContosoGLAccount.InsertGLAccount(SalesResourcesDom(), SalesResourcesDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesResourcesEU(), SalesResourcesEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.EU(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Reduced(), false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesResourcesExport(), SalesResourcesExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Export(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateVATPostingGroups.Reduced(), false, false, false);
        ContosoGLAccount.InsertGLAccount(JobSalesAppliedResources(), JobSalesAppliedResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobSalesAdjmtResources(), JobSalesAdjmtResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesofResources(), TotalSalesofResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, SalesofResources() + '..' + TotalSalesofResources(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesofJobs(), SalesofJobsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesOtherJobExpenses(), SalesOtherJobExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(JobSales(), JobSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSalesofJobs(), TotalSalesofJobsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, SalesofJobs() + '..' + TotalSalesofJobs(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ConsultingFeesDom(), ConsultingFeesDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), true, false, false);
        ContosoGLAccount.InsertGLAccount(FeesandChargesRecDom(), FeesandChargesRecDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetIncomeSalesDiscounts(), 80);
        ContosoGLAccount.InsertGLAccount(DiscountGranted(), DiscountGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Income, 80);
        ContosoGLAccount.InsertGLAccount(TotalRevenue(), TotalRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Revenue() + '..' + TotalRevenue(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCOGSMaterials(), 80);
        ContosoGLAccount.InsertGLAccount(Cost(), CostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofRetail(), CostofRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchRetailDom(), PurchRetailDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchRetailEU(), PurchRetailEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.EU(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchRetailExport(), PurchRetailExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Export(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Export(), CreateVATPostingGroups.Standard(), false, false, false);
        ContosoGLAccount.InsertGLAccount(DiscReceivedRetail(), DiscReceivedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DeliveryExpensesRetail(), DeliveryExpensesRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(InventoryAdjmtRetail(), InventoryAdjmtRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobCostAppliedRetail(), JobCostAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobCostAdjmtRetail(), JobCostAdjmtRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofRetailSold(), CostofRetailSoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostofRetail(), TotalCostofRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CostofRetail() + '..' + TotalCostofRetail(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofRawMaterials(), CostofRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchRawMaterialsDom(), PurchRawMaterialsDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchRawMaterialsEU(), PurchRawMaterialsEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.EU(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchRawMaterialsExport(), PurchRawMaterialsExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Export(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Export(), CreateVATPostingGroups.Standard(), false, false, false);
        ContosoGLAccount.InsertGLAccount(DiscReceivedRawMaterials(), DiscReceivedRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DeliveryExpensesRawMat(), DeliveryExpensesRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(InventoryAdjmtRawMat(), InventoryAdjmtRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobCostAppliedRawMat(), JobCostAppliedRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobCostAdjmtRawMaterials(), JobCostAdjmtRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofRawMaterialsSold(), CostofRawMaterialsSoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostofRawMaterials(), TotalCostofRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CostofRawMaterials() + '..' + TotalCostofRawMaterials(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::"Cost of Goods Sold", 80);
        ContosoGLAccount.InsertGLAccount(CostofResources(), CostofResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCOGSLabor(), 80);
        ContosoGLAccount.InsertGLAccount(JobCostAppliedResources(), JobCostAppliedResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobCostAdjmtResources(), JobCostAdjmtResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CostofResourcesUsed(), CostofResourcesUsedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalCostofResources(), TotalCostofResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CostofResources() + '..' + TotalCostofResources(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobCosts(), JobCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::"Cost of Goods Sold", 80);
        ContosoGLAccount.InsertGLAccount(TotalCost(), TotalCostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, Cost() + '..' + TotalCost(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Expense, 80);
        ContosoGLAccount.InsertGLAccount(OperatingExpenses(), OperatingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetUtilitiesExpense(), 80);
        ContosoGLAccount.InsertGLAccount(BuildingMaintenanceExpenses(), BuildingMaintenanceExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Cleaning(), CleaningName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(ElectricityandHeating(), ElectricityandHeatingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(RepairsandMaintenance(), RepairsandMaintenanceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalBldgMaintExpenses(), TotalBldgMaintExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, BuildingMaintenanceExpenses() + '..' + TotalBldgMaintExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AdministrativeExpenses(), AdministrativeExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OfficeSupplies(), OfficeSuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(PhoneandFax(), PhoneandFaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(Postage(), PostageName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Expense, 80);
        ContosoGLAccount.InsertGLAccount(TotalAdministrativeExpenses(), TotalAdministrativeExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, AdministrativeExpenses() + '..' + TotalAdministrativeExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ComputerExpenses(), ComputerExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Software(), SoftwareName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(ConsultantServices(), ConsultantServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherComputerExpenses(), OtherComputerExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalComputerExpenses(), TotalComputerExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, ComputerExpenses() + '..' + TotalComputerExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SellingExpenses(), SellingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetAdvertisingExpense(), 80);
        ContosoGLAccount.InsertGLAccount(Advertising(), AdvertisingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(EntertainmentandPR(), EntertainmentandPRName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Expense, 80);
        ContosoGLAccount.InsertGLAccount(Travel(), TravelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);
        ContosoGLAccount.InsertGLAccount(DeliveryExpenses(), DeliveryExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalSellingExpenses(), TotalSellingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, SellingExpenses() + '..' + TotalSellingExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VehicleExpenses(), VehicleExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GasolineandMotorOil(), GasolineandMotorOilName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(RegistrationFees(), RegistrationFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetRepairsExpense(), 80);
        ContosoGLAccount.InsertGLAccount(RepairsandMaintenanceExpense(), RepairsandMaintenanceExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Expense, 80);
        ContosoGLAccount.InsertGLAccount(TotalVehicleExpenses(), TotalVehicleExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, VehicleExpenses() + '..' + TotalVehicleExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetOtherIncomeExpense(), 80);
        ContosoGLAccount.InsertGLAccount(OtherOperatingExpenses(), OtherOperatingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CashDiscrepancies(), CashDiscrepanciesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BadDebtExpenses(), BadDebtExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LegalandAccountingServices(), LegalandAccountingServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(Miscellaneous(), MiscellaneousName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherOperatingExpTotal(), OtherOperatingExpTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, OtherOperatingExpenses() + '..' + OtherOperatingExpTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Expense, 80);
        ContosoGLAccount.InsertGLAccount(TotalOperatingExpenses(), TotalOperatingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, OperatingExpenses() + '..' + TotalOperatingExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetPayrollExpense(), 80);
        ContosoGLAccount.InsertGLAccount(PersonnelExpenses(), PersonnelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Wages(), WagesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Salaries(), SalariesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RetirementPlanContributions(), RetirementPlanContributionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VacationCompensation(), VacationCompensationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PayrollTaxes(), PayrollTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalPersonnelExpenses(), TotalPersonnelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, PersonnelExpenses() + '..' + TotalPersonnelExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Expense, 80);
        ContosoGLAccount.InsertGLAccount(DepreciationofFixedAssets(), DepreciationofFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationBuildings(), DepreciationBuildingsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationEquipment(), DepreciationEquipmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationVehicles(), DepreciationVehiclesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GainsandLosses(), GainsandLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalFixedAssetDepreciation(), TotalFixedAssetDepreciationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, DepreciationofFixedAssets() + '..' + TotalFixedAssetDepreciation(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherCostsofOperations(), OtherCostsofOperationsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), true, false, false);

        ContosoGLAccount.InsertGLAccount(NetOperatingIncome(), NetOperatingIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 1, IncomeStatement() + '..' + NetOperatingIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Income, 80);
        ContosoGLAccount.InsertGLAccount(InterestIncome(), InterestIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InterestonBankBalances(), InterestonBankBalancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FinanceChargesfromCustomers(), FinanceChargesfromCustomersName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);
        ContosoGLAccount.InsertGLAccount(PaymentDiscountsReceived(), PaymentDiscountsReceivedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PmtDiscReceivedDecreases(), PmtDiscReceivedDecreasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InvoiceRounding(), InvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::" ", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), false, false, false);
        ContosoGLAccount.InsertGLAccount(ApplicationRounding(), ApplicationRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PaymentToleranceReceived(), PaymentToleranceReceivedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PmtTolReceivedDecreases(), PmtTolReceivedDecreasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalInterestIncome(), TotalInterestIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, InterestIncome() + '..' + TotalInterestIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetInterestExpense(), 80);
        ContosoGLAccount.InsertGLAccount(InterestExpenses(), InterestExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InterestonRevolvingCredit(), InterestonRevolvingCreditName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InterestonBankLoans(), InterestonBankLoansName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MortgageInterest(), MortgageInterestName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FinanceChargestoVendors(), FinanceChargestoVendorsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PaymentDiscountsGranted(), PaymentDiscountsGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PmtDiscGrantedDecreases(), PmtDiscGrantedDecreasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PaymentToleranceGranted(), PaymentToleranceGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PmtTolGrantedDecreases(), PmtTolGrantedDecreasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TotalInterestExpenses(), TotalInterestExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, InterestExpenses() + '..' + TotalInterestExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Income, 80);
        ContosoGLAccount.InsertGLAccount(UnrealizedFXGains(), UnrealizedFXGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Expense, 80);
        ContosoGLAccount.InsertGLAccount(UnrealizedFXLosses(), UnrealizedFXLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Income, 80);
        ContosoGLAccount.InsertGLAccount(RealizedFXGains(), RealizedFXGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Expense, 80);
        ContosoGLAccount.InsertGLAccount(RealizedFXLosses(), RealizedFXLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        ContosoGLAccount.InsertGLAccount(NIBEFOREEXTRITEMSTAXES(), NIBEFOREEXTRITEMSTAXESName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 1, IncomeStatement() + '..' + NIBEFOREEXTRITEMSTAXES(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Income, 80);
        ContosoGLAccount.InsertGLAccount(ExtraordinaryIncome(), ExtraordinaryIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetOtherIncomeExpense(), 80);
        ContosoGLAccount.InsertGLAccount(ExtraordinaryExpenses(), ExtraordinaryExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        ContosoGLAccount.InsertGLAccount(NetIncomeBeforeTaxes(), NetIncomeBeforeTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 0, IncomeStatement() + '..' + NetIncomeBeforeTaxes(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetTaxExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CorporateTax(), CorporateTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        ContosoGLAccount.InsertGLAccount(NetIncome(), NetIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 1, IncomeStatement() + '..' + NetIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        GLAccountIndent.Indent();
    end;

    procedure AddGLAccountsForLocalization()
    begin
        ContosoGLAccount.AddAccountForLocalization(BalanceSheetName(), '1000');
        ContosoGLAccount.AddAccountForLocalization(AssetsName(), '1002');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetsName(), '1003');
        ContosoGLAccount.AddAccountForLocalization(TangibleFixedAssetsName(), '1005');
        ContosoGLAccount.AddAccountForLocalization(LandandBuildingsBeginTotalName(), '1100');
        ContosoGLAccount.AddAccountForLocalization(LandandBuildingsName(), '1110');
        ContosoGLAccount.AddAccountForLocalization(IncreasesduringtheYearBuildingsName(), '1120');
        ContosoGLAccount.AddAccountForLocalization(DecreasesduringtheYearBuildingsName(), '1130');
        ContosoGLAccount.AddAccountForLocalization(AccumDepreciationBuildingsName(), '1140');
        ContosoGLAccount.AddAccountForLocalization(LandandBuildingsTotalName(), '1190');
        ContosoGLAccount.AddAccountForLocalization(OperatingEquipmentBeginTotalName(), '1200');
        ContosoGLAccount.AddAccountForLocalization(OperatingEquipmentName(), '1210');
        ContosoGLAccount.AddAccountForLocalization(IncreasesduringtheYearOperEquipName(), '1220');
        ContosoGLAccount.AddAccountForLocalization(DecreasesduringtheYearOperEquipName(), '1230');
        ContosoGLAccount.AddAccountForLocalization(AccumDeprOperEquipName(), '1240');
        ContosoGLAccount.AddAccountForLocalization(OperatingEquipmentTotalName(), '1290');
        ContosoGLAccount.AddAccountForLocalization(VehiclesBeginTotalName(), '1300');
        ContosoGLAccount.AddAccountForLocalization(VehiclesName(), '1310');
        ContosoGLAccount.AddAccountForLocalization(IncreasesduringtheYearVehiclesName(), '1320');
        ContosoGLAccount.AddAccountForLocalization(DecreasesduringtheYearVehiclesName(), '1330');
        ContosoGLAccount.AddAccountForLocalization(AccumDepreciationVehiclesName(), '1340');
        ContosoGLAccount.AddAccountForLocalization(VehiclesTotalName(), '1390');
        ContosoGLAccount.AddAccountForLocalization(TangibleFixedAssetsTotalName(), '1395');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetsTotalName(), '1999');
        ContosoGLAccount.AddAccountForLocalization(CurrentAssetsName(), '2000');
        ContosoGLAccount.AddAccountForLocalization(InventoryName(), '2100');
        ContosoGLAccount.AddAccountForLocalization(ResaleItemsName(), '2110');
        ContosoGLAccount.AddAccountForLocalization(ResaleItemsInterimName(), '2111');
        ContosoGLAccount.AddAccountForLocalization(CostofResaleSoldInterimName(), '2112');
        ContosoGLAccount.AddAccountForLocalization(FinishedGoodsName(), '2120');
        ContosoGLAccount.AddAccountForLocalization(FinishedGoodsInterimName(), '2121');
        ContosoGLAccount.AddAccountForLocalization(RawMaterialsName(), '2130');
        ContosoGLAccount.AddAccountForLocalization(RawMaterialsInterimName(), '2131');
        ContosoGLAccount.AddAccountForLocalization(CostofRawMatSoldInterimName(), '2132');
        ContosoGLAccount.AddAccountForLocalization(PrimoInventoryName(), '2180');
        ContosoGLAccount.AddAccountForLocalization(InventoryTotalName(), '2190');
        ContosoGLAccount.AddAccountForLocalization(JobWIPName(), '2200');
        ContosoGLAccount.AddAccountForLocalization(WIPSalesName(), '2210');
        ContosoGLAccount.AddAccountForLocalization(WIPJobSalesName(), '2211');
        ContosoGLAccount.AddAccountForLocalization(InvoicedJobSalesName(), '2212');
        ContosoGLAccount.AddAccountForLocalization(WIPSalesTotalName(), '2220');
        ContosoGLAccount.AddAccountForLocalization(WIPCostsName(), '2230');
        ContosoGLAccount.AddAccountForLocalization(WIPJobCostsName(), '2231');
        ContosoGLAccount.AddAccountForLocalization(AccruedJobCostsName(), '2232');
        ContosoGLAccount.AddAccountForLocalization(WIPCostsTotalName(), '2240');
        ContosoGLAccount.AddAccountForLocalization(JobWIPTotalName(), '2290');
        ContosoGLAccount.AddAccountForLocalization(AccountsReceivableName(), '2300');
        ContosoGLAccount.AddAccountForLocalization(CustomersDomesticName(), '2310');
        ContosoGLAccount.AddAccountForLocalization(CustomersForeignName(), '2320');
        ContosoGLAccount.AddAccountForLocalization(AccruedInterestName(), '2330');
        ContosoGLAccount.AddAccountForLocalization(OtherReceivablesName(), '2340');
        ContosoGLAccount.AddAccountForLocalization(AccountsReceivableTotalName(), '2390');
        ContosoGLAccount.AddAccountForLocalization(PurchasePrepaymentsName(), '2400');
        ContosoGLAccount.AddAccountForLocalization(VendorPrepaymentsVATName(), '2410');
        ContosoGLAccount.AddAccountForLocalization(VendorPrepaymentsVAT10Name(), '2420');
        ContosoGLAccount.AddAccountForLocalization(VendorPrepaymentsVAT25Name(), '2430');
        ContosoGLAccount.AddAccountForLocalization(PurchasePrepaymentsTotalName(), '2440');
        ContosoGLAccount.AddAccountForLocalization(SecuritiesName(), '2800');
        ContosoGLAccount.AddAccountForLocalization(BondsName(), '2810');
        ContosoGLAccount.AddAccountForLocalization(SecuritiesTotalName(), '2890');
        ContosoGLAccount.AddAccountForLocalization(LiquidAssetsName(), '2900');
        ContosoGLAccount.AddAccountForLocalization(CashName(), '2910');
        ContosoGLAccount.AddAccountForLocalization(BankLCYName(), '2920');
        ContosoGLAccount.AddAccountForLocalization(BankCurrenciesName(), '2930');
        ContosoGLAccount.AddAccountForLocalization(GiroAccountName(), '2940');
        ContosoGLAccount.AddAccountForLocalization(LiquidAssetsTotalName(), '2990');
        ContosoGLAccount.AddAccountForLocalization(CurrentAssetsTotalName(), '2995');
        ContosoGLAccount.AddAccountForLocalization(TotalAssetsName(), '2999');
        ContosoGLAccount.AddAccountForLocalization(LiabilitiesAndEquityName(), '3000');
        ContosoGLAccount.AddAccountForLocalization(StockholderName(), '3100');
        ContosoGLAccount.AddAccountForLocalization(CapitalStockName(), '3110');
        ContosoGLAccount.AddAccountForLocalization(RetainedEarningsName(), '3120');
        ContosoGLAccount.AddAccountForLocalization(NetIncomefortheYearName(), '3195');
        ContosoGLAccount.AddAccountForLocalization(TotalStockholderName(), '3199');
        ContosoGLAccount.AddAccountForLocalization(AllowancesName(), '4000');
        ContosoGLAccount.AddAccountForLocalization(DeferredTaxesName(), '4010');
        ContosoGLAccount.AddAccountForLocalization(AllowancesTotalName(), '4999');
        ContosoGLAccount.AddAccountForLocalization(LiabilitiesName(), '5000');
        ContosoGLAccount.AddAccountForLocalization(LongtermLiabilitiesName(), '5100');
        ContosoGLAccount.AddAccountForLocalization(LongtermBankLoansName(), '5110');
        ContosoGLAccount.AddAccountForLocalization(MortgageName(), '5120');
        ContosoGLAccount.AddAccountForLocalization(LongtermLiabilitiesTotalName(), '5290');
        ContosoGLAccount.AddAccountForLocalization(ShorttermLiabilitiesName(), '5300');
        ContosoGLAccount.AddAccountForLocalization(RevolvingCreditName(), '5310');
        ContosoGLAccount.AddAccountForLocalization(SalesPrepaymentsName(), '5350');
        ContosoGLAccount.AddAccountForLocalization(CustomerPrepaymentsVAT0Name(), '5360');
        ContosoGLAccount.AddAccountForLocalization(CustomerPrepaymentsVAT10Name(), '5370');
        ContosoGLAccount.AddAccountForLocalization(CustomerPrepaymentsVAT25Name(), '5380');
        ContosoGLAccount.AddAccountForLocalization(SalesPrepaymentsTotalName(), '5390');
        ContosoGLAccount.AddAccountForLocalization(AccountsPayableName(), '5400');
        ContosoGLAccount.AddAccountForLocalization(VendorsDomesticName(), '5410');
        ContosoGLAccount.AddAccountForLocalization(VendorsForeignName(), '5420');
        ContosoGLAccount.AddAccountForLocalization(AccountsPayableTotalName(), '5490');
        ContosoGLAccount.AddAccountForLocalization(InvAdjmtInterimName(), '5500');
        ContosoGLAccount.AddAccountForLocalization(InvAdjmtInterimRetailName(), '5510');
        ContosoGLAccount.AddAccountForLocalization(InvAdjmtInterimRawMatName(), '5530');
        ContosoGLAccount.AddAccountForLocalization(InvAdjmtInterimTotalName(), '5590');
        ContosoGLAccount.AddAccountForLocalization(VATName(), '5600');
        ContosoGLAccount.AddAccountForLocalization(SalesVAT25Name(), '5610');
        ContosoGLAccount.AddAccountForLocalization(SalesVAT10Name(), '5611');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVAT25EUName(), '5620');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVAT10EUName(), '5621');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVAT25Name(), '5630');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVAT10Name(), '5631');
        ContosoGLAccount.AddAccountForLocalization(FuelTaxName(), '5710');
        ContosoGLAccount.AddAccountForLocalization(ElectricityTaxName(), '5720');
        ContosoGLAccount.AddAccountForLocalization(NaturalGasTaxName(), '5730');
        ContosoGLAccount.AddAccountForLocalization(CoalTaxName(), '5740');
        ContosoGLAccount.AddAccountForLocalization(CO2TaxName(), '5750');
        ContosoGLAccount.AddAccountForLocalization(WaterTaxName(), '5760');
        ContosoGLAccount.AddAccountForLocalization(VATPayableName(), '5780');
        ContosoGLAccount.AddAccountForLocalization(VATTotalName(), '5790');
        ContosoGLAccount.AddAccountForLocalization(PersonnelrelatedItemsName(), '5800');
        ContosoGLAccount.AddAccountForLocalization(WithholdingTaxesPayableName(), '5810');
        ContosoGLAccount.AddAccountForLocalization(SupplementaryTaxesPayableName(), '5820');
        ContosoGLAccount.AddAccountForLocalization(PayrollTaxesPayableName(), '5830');
        ContosoGLAccount.AddAccountForLocalization(VacationCompensationPayableName(), '5840');
        ContosoGLAccount.AddAccountForLocalization(EmployeesPayableName(), '5850');
        ContosoGLAccount.AddAccountForLocalization(TotalPersonnelrelatedItemsName(), '5890');
        ContosoGLAccount.AddAccountForLocalization(OtherLiabilitiesName(), '5900');
        ContosoGLAccount.AddAccountForLocalization(DividendsfortheFiscalYearName(), '5910');
        ContosoGLAccount.AddAccountForLocalization(CorporateTaxesPayableName(), '5920');
        ContosoGLAccount.AddAccountForLocalization(OtherLiabilitiesTotalName(), '5990');
        ContosoGLAccount.AddAccountForLocalization(ShorttermLiabilitiesTotalName(), '5995');
        ContosoGLAccount.AddAccountForLocalization(TotalLiabilitiesName(), '5997');
        ContosoGLAccount.AddAccountForLocalization(TotalLiabilitiesAndEquityName(), '5999');
        ContosoGLAccount.AddAccountForLocalization(IncomeStatementName(), '6000');
        ContosoGLAccount.AddAccountForLocalization(RevenueName(), '6100');
        ContosoGLAccount.AddAccountForLocalization(SalesofRetailName(), '6105');
        ContosoGLAccount.AddAccountForLocalization(SalesRetailDomName(), '6110');
        ContosoGLAccount.AddAccountForLocalization(SalesRetailEUName(), '6120');
        ContosoGLAccount.AddAccountForLocalization(SalesRetailExportName(), '6130');
        ContosoGLAccount.AddAccountForLocalization(JobSalesAppliedRetailName(), '6190');
        ContosoGLAccount.AddAccountForLocalization(JobSalesAdjmtRetailName(), '6191');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesofRetailName(), '6195');
        ContosoGLAccount.AddAccountForLocalization(SalesofRawMaterialsName(), '6205');
        ContosoGLAccount.AddAccountForLocalization(SalesRawMaterialsDomName(), '6210');
        ContosoGLAccount.AddAccountForLocalization(SalesRawMaterialsEUName(), '6220');
        ContosoGLAccount.AddAccountForLocalization(SalesRawMaterialsExportName(), '6230');
        ContosoGLAccount.AddAccountForLocalization(JobSalesAppliedRawMatName(), '6290');
        ContosoGLAccount.AddAccountForLocalization(JobSalesAdjmtRawMatName(), '6291');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesofRawMaterialsName(), '6295');
        ContosoGLAccount.AddAccountForLocalization(SalesofResourcesName(), '6405');
        ContosoGLAccount.AddAccountForLocalization(SalesResourcesDomName(), '6410');
        ContosoGLAccount.AddAccountForLocalization(SalesResourcesEUName(), '6420');
        ContosoGLAccount.AddAccountForLocalization(SalesResourcesExportName(), '6430');
        ContosoGLAccount.AddAccountForLocalization(JobSalesAppliedResourcesName(), '6490');
        ContosoGLAccount.AddAccountForLocalization(JobSalesAdjmtResourcesName(), '6491');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesofResourcesName(), '6495');
        ContosoGLAccount.AddAccountForLocalization(SalesofJobsName(), '6605');
        ContosoGLAccount.AddAccountForLocalization(SalesOtherJobExpensesName(), '6610');
        ContosoGLAccount.AddAccountForLocalization(JobSalesName(), '6620');
        ContosoGLAccount.AddAccountForLocalization(TotalSalesofJobsName(), '6695');
        ContosoGLAccount.AddAccountForLocalization(ConsultingFeesDomName(), '6710');
        ContosoGLAccount.AddAccountForLocalization(FeesandChargesRecDomName(), '6810');
        ContosoGLAccount.AddAccountForLocalization(DiscountGrantedName(), '6910');
        ContosoGLAccount.AddAccountForLocalization(TotalRevenueName(), '6995');
        ContosoGLAccount.AddAccountForLocalization(CostName(), '7100');
        ContosoGLAccount.AddAccountForLocalization(CostofRetailName(), '7105');
        ContosoGLAccount.AddAccountForLocalization(PurchRetailDomName(), '7110');
        ContosoGLAccount.AddAccountForLocalization(PurchRetailEUName(), '7120');
        ContosoGLAccount.AddAccountForLocalization(PurchRetailExportName(), '7130');
        ContosoGLAccount.AddAccountForLocalization(DiscReceivedRetailName(), '7140');
        ContosoGLAccount.AddAccountForLocalization(DeliveryExpensesRetailName(), '7150');
        ContosoGLAccount.AddAccountForLocalization(InventoryAdjmtRetailName(), '7170');
        ContosoGLAccount.AddAccountForLocalization(JobCostAppliedRetailName(), '7180');
        ContosoGLAccount.AddAccountForLocalization(JobCostAdjmtRetailName(), '7181');
        ContosoGLAccount.AddAccountForLocalization(CostofRetailSoldName(), '7190');
        ContosoGLAccount.AddAccountForLocalization(TotalCostofRetailName(), '7195');
        ContosoGLAccount.AddAccountForLocalization(CostofRawMaterialsName(), '7205');
        ContosoGLAccount.AddAccountForLocalization(PurchRawMaterialsDomName(), '7210');
        ContosoGLAccount.AddAccountForLocalization(PurchRawMaterialsEUName(), '7220');
        ContosoGLAccount.AddAccountForLocalization(PurchRawMaterialsExportName(), '7230');
        ContosoGLAccount.AddAccountForLocalization(DiscReceivedRawMaterialsName(), '7240');
        ContosoGLAccount.AddAccountForLocalization(DeliveryExpensesRawMatName(), '7250');
        ContosoGLAccount.AddAccountForLocalization(InventoryAdjmtRawMatName(), '7270');
        ContosoGLAccount.AddAccountForLocalization(JobCostAppliedRawMatName(), '7280');
        ContosoGLAccount.AddAccountForLocalization(JobCostAdjmtRawMaterialsName(), '7281');
        ContosoGLAccount.AddAccountForLocalization(CostofRawMaterialsSoldName(), '7290');
        ContosoGLAccount.AddAccountForLocalization(TotalCostofRawMaterialsName(), '7295');
        ContosoGLAccount.AddAccountForLocalization(CostofResourcesName(), '7405');
        ContosoGLAccount.AddAccountForLocalization(JobCostAppliedResourcesName(), '7480');
        ContosoGLAccount.AddAccountForLocalization(JobCostAdjmtResourcesName(), '7481');
        ContosoGLAccount.AddAccountForLocalization(CostofResourcesUsedName(), '7490');
        ContosoGLAccount.AddAccountForLocalization(TotalCostofResourcesName(), '7495');
        ContosoGLAccount.AddAccountForLocalization(JobCostsName(), '7620');
        ContosoGLAccount.AddAccountForLocalization(TotalCostName(), '7995');
        ContosoGLAccount.AddAccountForLocalization(OperatingExpensesName(), '8000');
        ContosoGLAccount.AddAccountForLocalization(BuildingMaintenanceExpensesName(), '8100');
        ContosoGLAccount.AddAccountForLocalization(CleaningName(), '8110');
        ContosoGLAccount.AddAccountForLocalization(ElectricityandHeatingName(), '8120');
        ContosoGLAccount.AddAccountForLocalization(RepairsandMaintenanceName(), '8130');
        ContosoGLAccount.AddAccountForLocalization(TotalBldgMaintExpensesName(), '8190');
        ContosoGLAccount.AddAccountForLocalization(AdministrativeExpensesName(), '8200');
        ContosoGLAccount.AddAccountForLocalization(OfficeSuppliesName(), '8210');
        ContosoGLAccount.AddAccountForLocalization(PhoneandFaxName(), '8230');
        ContosoGLAccount.AddAccountForLocalization(PostageName(), '8240');
        ContosoGLAccount.AddAccountForLocalization(TotalAdministrativeExpensesName(), '8290');
        ContosoGLAccount.AddAccountForLocalization(ComputerExpensesName(), '8300');
        ContosoGLAccount.AddAccountForLocalization(SoftwareName(), '8310');
        ContosoGLAccount.AddAccountForLocalization(ConsultantServicesName(), '8320');
        ContosoGLAccount.AddAccountForLocalization(OtherComputerExpensesName(), '8330');
        ContosoGLAccount.AddAccountForLocalization(TotalComputerExpensesName(), '8390');
        ContosoGLAccount.AddAccountForLocalization(SellingExpensesName(), '8400');
        ContosoGLAccount.AddAccountForLocalization(AdvertisingName(), '8410');
        ContosoGLAccount.AddAccountForLocalization(EntertainmentandPRName(), '8420');
        ContosoGLAccount.AddAccountForLocalization(TravelName(), '8430');
        ContosoGLAccount.AddAccountForLocalization(DeliveryExpensesName(), '8450');
        ContosoGLAccount.AddAccountForLocalization(TotalSellingExpensesName(), '8490');
        ContosoGLAccount.AddAccountForLocalization(VehicleExpensesName(), '8500');
        ContosoGLAccount.AddAccountForLocalization(GasolineandMotorOilName(), '8510');
        ContosoGLAccount.AddAccountForLocalization(RegistrationFeesName(), '8520');
        ContosoGLAccount.AddAccountForLocalization(RepairsandMaintenanceExpenseName(), '8530');
        ContosoGLAccount.AddAccountForLocalization(TotalVehicleExpensesName(), '8590');
        ContosoGLAccount.AddAccountForLocalization(OtherOperatingExpensesName(), '8600');
        ContosoGLAccount.AddAccountForLocalization(CashDiscrepanciesName(), '8610');
        ContosoGLAccount.AddAccountForLocalization(BadDebtExpensesName(), '8620');
        ContosoGLAccount.AddAccountForLocalization(LegalandAccountingServicesName(), '8630');
        ContosoGLAccount.AddAccountForLocalization(MiscellaneousName(), '8640');
        ContosoGLAccount.AddAccountForLocalization(OtherOperatingExpTotalName(), '8690');
        ContosoGLAccount.AddAccountForLocalization(TotalOperatingExpensesName(), '8695');
        ContosoGLAccount.AddAccountForLocalization(PersonnelExpensesName(), '8700');
        ContosoGLAccount.AddAccountForLocalization(WagesName(), '8710');
        ContosoGLAccount.AddAccountForLocalization(SalariesName(), '8720');
        ContosoGLAccount.AddAccountForLocalization(RetirementPlanContributionsName(), '8730');
        ContosoGLAccount.AddAccountForLocalization(VacationCompensationName(), '8740');
        ContosoGLAccount.AddAccountForLocalization(PayrollTaxesName(), '8750');
        ContosoGLAccount.AddAccountForLocalization(TotalPersonnelExpensesName(), '8790');
        ContosoGLAccount.AddAccountForLocalization(DepreciationofFixedAssetsName(), '8800');
        ContosoGLAccount.AddAccountForLocalization(DepreciationBuildingsName(), '8810');
        ContosoGLAccount.AddAccountForLocalization(DepreciationEquipmentName(), '8820');
        ContosoGLAccount.AddAccountForLocalization(DepreciationVehiclesName(), '8830');
        ContosoGLAccount.AddAccountForLocalization(GainsandLossesName(), '8840');
        ContosoGLAccount.AddAccountForLocalization(TotalFixedAssetDepreciationName(), '8890');
        ContosoGLAccount.AddAccountForLocalization(OtherCostsofOperationsName(), '8910');
        ContosoGLAccount.AddAccountForLocalization(NetOperatingIncomeName(), '8995');
        ContosoGLAccount.AddAccountForLocalization(InterestIncomeName(), '9100');
        ContosoGLAccount.AddAccountForLocalization(InterestonBankBalancesName(), '9110');
        ContosoGLAccount.AddAccountForLocalization(FinanceChargesfromCustomersName(), '9120');
        ContosoGLAccount.AddAccountForLocalization(PaymentDiscountsReceivedName(), '9130');
        ContosoGLAccount.AddAccountForLocalization(PmtDiscReceivedDecreasesName(), '9135');
        ContosoGLAccount.AddAccountForLocalization(InvoiceRoundingName(), '9140');
        ContosoGLAccount.AddAccountForLocalization(ApplicationRoundingName(), '9150');
        ContosoGLAccount.AddAccountForLocalization(PaymentToleranceReceivedName(), '9160');
        ContosoGLAccount.AddAccountForLocalization(PmtTolReceivedDecreasesName(), '9170');
        ContosoGLAccount.AddAccountForLocalization(TotalInterestIncomeName(), '9190');
        ContosoGLAccount.AddAccountForLocalization(InterestExpensesName(), '9200');
        ContosoGLAccount.AddAccountForLocalization(InterestonRevolvingCreditName(), '9210');
        ContosoGLAccount.AddAccountForLocalization(InterestonBankLoansName(), '9220');
        ContosoGLAccount.AddAccountForLocalization(MortgageInterestName(), '9230');
        ContosoGLAccount.AddAccountForLocalization(FinanceChargestoVendorsName(), '9240');
        ContosoGLAccount.AddAccountForLocalization(PaymentDiscountsGrantedName(), '9250');
        ContosoGLAccount.AddAccountForLocalization(PmtDiscGrantedDecreasesName(), '9255');
        ContosoGLAccount.AddAccountForLocalization(PaymentToleranceGrantedName(), '9260');
        ContosoGLAccount.AddAccountForLocalization(PmtTolGrantedDecreasesName(), '9270');
        ContosoGLAccount.AddAccountForLocalization(TotalInterestExpensesName(), '9290');
        ContosoGLAccount.AddAccountForLocalization(UnrealizedFXGainsName(), '9310');
        ContosoGLAccount.AddAccountForLocalization(UnrealizedFXLossesName(), '9320');
        ContosoGLAccount.AddAccountForLocalization(RealizedFXGainsName(), '9330');
        ContosoGLAccount.AddAccountForLocalization(RealizedFXLossesName(), '9340');
        ContosoGLAccount.AddAccountForLocalization(NIBEFOREEXTRITEMSTAXESName(), '9395');
        ContosoGLAccount.AddAccountForLocalization(ExtraordinaryIncomeName(), '9410');
        ContosoGLAccount.AddAccountForLocalization(ExtraordinaryExpensesName(), '9420');
        ContosoGLAccount.AddAccountForLocalization(NetIncomeBeforeTaxesName(), '9495');
        ContosoGLAccount.AddAccountForLocalization(CorporateTaxName(), '9510');
        ContosoGLAccount.AddAccountForLocalization(NetIncomeName(), '9999');

        OnAfterAddGLAccountsForLocalization();
    end;

    procedure BalanceSheet(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BalanceSheetName()));
    end;

    procedure BalanceSheetName(): Text[100]
    begin
        exit(BalanceSheetLbl);
    end;

    procedure Assets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AssetsName()));
    end;

    procedure AssetsName(): Text[100]
    begin
        exit(AssetsLbl);
    end;

    procedure FixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FixedAssetsName()));
    end;

    procedure FixedAssetsName(): Text[100]
    begin
        exit(FixedAssetsLbl);
    end;

    procedure TangibleFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TangibleFixedAssetsName()));
    end;

    procedure TangibleFixedAssetsName(): Text[100]
    begin
        exit(TangibleFixedAssetsLbl);
    end;

    procedure LandandBuildingsBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LandandBuildingsBeginTotalName()));
    end;

    procedure LandandBuildingsBeginTotalName(): Text[100]
    begin
        exit(LandandBuildingsBeginTotalLbl);
    end;


    procedure LandandBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LandandBuildingsName()));
    end;

    procedure LandandBuildingsName(): Text[100]
    begin
        exit(LandandBuildingsLbl);
    end;

    procedure IncreasesduringtheYearBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncreasesduringtheYearBuildingsName()));
    end;

    procedure IncreasesduringtheYearBuildingsName(): Text[100]
    begin
        exit(IncreasesduringtheYearBuildingsLbl);
    end;

    procedure DecreasesduringtheYearBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesduringtheYearBuildingsName()));
    end;

    procedure DecreasesduringtheYearBuildingsName(): Text[100]
    begin
        exit(DecreasesduringtheYearBuildingsLbl);
    end;

    procedure AccumDepreciationBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDepreciationBuildingsName()));
    end;

    procedure AccumDepreciationBuildingsName(): Text[100]
    begin
        exit(AccumDepreciationBuildingsLbl);
    end;

    procedure LandandBuildingsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LandandBuildingsTotalName()));
    end;

    procedure LandandBuildingsTotalName(): Text[100]
    begin
        exit(LandandBuildingsTotalLbl);
    end;

    procedure OperatingEquipmentBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OperatingEquipmentBeginTotalName()));
    end;

    procedure OperatingEquipmentBeginTotalName(): Text[100]
    begin
        exit(OperatingEquipmentBeginTotalLbl);
    end;

    procedure OperatingEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OperatingEquipmentName()));
    end;

    procedure OperatingEquipmentName(): Text[100]
    begin
        exit(OperatingEquipmentLbl);
    end;

    procedure IncreasesduringtheYearOperEquip(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncreasesduringtheYearOperEquipName()));
    end;

    procedure IncreasesduringtheYearOperEquipName(): Text[100]
    begin
        exit(IncreasesduringtheYearLbl);
    end;

    procedure DecreasesduringtheYearOperEquip(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesduringtheYearOperEquipName()));
    end;

    procedure DecreasesduringtheYearOperEquipName(): Text[100]
    begin
        exit(DecreasesduringtheYearLbl);
    end;

    procedure AccumDeprOperEquip(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDeprOperEquipName()));
    end;

    procedure AccumDeprOperEquipName(): Text[100]
    begin
        exit(AccumDeprOperEquipLbl);
    end;

    procedure OperatingEquipmentTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OperatingEquipmentTotalName()));
    end;

    procedure OperatingEquipmentTotalName(): Text[100]
    begin
        exit(OperatingEquipmentTotalLbl);
    end;

    procedure VehiclesBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VehiclesBeginTotalName()));
    end;

    procedure VehiclesBeginTotalName(): Text[100]
    begin
        exit(VehiclesBeginTotalLbl);
    end;

    procedure Vehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VehiclesName()));
    end;

    procedure VehiclesName(): Text[100]
    begin
        exit(VehiclesLbl);
    end;

    procedure IncreasesduringtheYearVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncreasesduringtheYearVehiclesName()));
    end;

    procedure IncreasesduringtheYearVehiclesName(): Text[100]
    begin
        exit(IncreasesduringtheYearVehiclesLbl);
    end;

    procedure DecreasesduringtheYearVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecreasesduringtheYearVehiclesName()));
    end;

    procedure DecreasesduringtheYearVehiclesName(): Text[100]
    begin
        exit(DecreasesduringtheYearVehiclesLbl);
    end;

    procedure AccumDepreciationVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccumDepreciationVehiclesName()));
    end;

    procedure AccumDepreciationVehiclesName(): Text[100]
    begin
        exit(AccumDepreciationVehiclesLbl);
    end;

    procedure VehiclesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VehiclesTotalName()));
    end;

    procedure VehiclesTotalName(): Text[100]
    begin
        exit(VehiclesTotalLbl);
    end;

    procedure TangibleFixedAssetsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TangibleFixedAssetsTotalName()));
    end;

    procedure TangibleFixedAssetsTotalName(): Text[100]
    begin
        exit(TangibleFixedAssetsTotalLbl);
    end;

    procedure FixedAssetsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FixedAssetsTotalName()));
    end;

    procedure FixedAssetsTotalName(): Text[100]
    begin
        exit(FixedAssetsTotalLbl);
    end;

    procedure CurrentAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentAssetsName()));
    end;

    procedure CurrentAssetsName(): Text[100]
    begin
        exit(CurrentAssetsLbl);
    end;

    procedure Inventory(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryName()));
    end;

    procedure InventoryName(): Text[100]
    begin
        exit(InventoryLbl);
    end;

    procedure ResaleItems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResaleItemsName()));
    end;

    procedure ResaleItemsName(): Text[100]
    begin
        exit(ResaleItemsLbl);
    end;

    procedure ResaleItemsInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResaleItemsInterimName()));
    end;

    procedure ResaleItemsInterimName(): Text[100]
    begin
        exit(ResaleItemsInterimLbl);
    end;

    procedure CostofResaleSoldInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofResaleSoldInterimName()));
    end;

    procedure CostofResaleSoldInterimName(): Text[100]
    begin
        exit(CostofResaleSoldInterimLbl);
    end;

    procedure FinishedGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinishedGoodsName()));
    end;

    procedure FinishedGoodsName(): Text[100]
    begin
        exit(FinishedGoodsLbl);
    end;

    procedure FinishedGoodsInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinishedGoodsInterimName()));
    end;

    procedure FinishedGoodsInterimName(): Text[100]
    begin
        exit(FinishedGoodsInterimLbl);
    end;

    procedure RawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RawMaterialsName()));
    end;

    procedure RawMaterialsName(): Text[100]
    begin
        exit(RawMaterialsLbl);
    end;

    procedure RawMaterialsInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RawMaterialsInterimName()));
    end;

    procedure RawMaterialsInterimName(): Text[100]
    begin
        exit(RawMaterialsInterimLbl);
    end;

    procedure CostofRawMatSoldInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofRawMatSoldInterimName()));
    end;

    procedure CostofRawMatSoldInterimName(): Text[100]
    begin
        exit(CostofRawMatSoldInterimLbl);
    end;

    procedure PrimoInventory(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrimoInventoryName()));
    end;

    procedure PrimoInventoryName(): Text[100]
    begin
        exit(PrimoInventoryLbl);
    end;

    procedure InventoryTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryTotalName()));
    end;

    procedure InventoryTotalName(): Text[100]
    begin
        exit(InventoryTotalLbl);
    end;

    procedure JobWIP(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobWIPName()));
    end;

    procedure JobWIPName(): Text[100]
    begin
        exit(JobWIPLbl);
    end;

    procedure WIPSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPSalesName()));
    end;

    procedure WIPSalesName(): Text[100]
    begin
        exit(WIPSalesLbl);
    end;

    procedure WIPJobSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPJobSalesName()));
    end;

    procedure WIPJobSalesName(): Text[100]
    begin
        exit(WIPJobSalesLbl);
    end;

    procedure InvoicedJobSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvoicedJobSalesName()));
    end;

    procedure InvoicedJobSalesName(): Text[100]
    begin
        exit(InvoicedJobSalesLbl);
    end;

    procedure WIPSalesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPSalesTotalName()));
    end;

    procedure WIPSalesTotalName(): Text[100]
    begin
        exit(WIPSalesTotalLbl);
    end;

    procedure WIPCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPCostsName()));
    end;

    procedure WIPCostsName(): Text[100]
    begin
        exit(WIPCostsLbl);
    end;

    procedure WIPJobCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPJobCostsName()));
    end;

    procedure WIPJobCostsName(): Text[100]
    begin
        exit(WIPJobCostsLbl);
    end;

    procedure AccruedJobCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedJobCostsName()));
    end;

    procedure AccruedJobCostsName(): Text[100]
    begin
        exit(AccruedJobCostsLbl);
    end;

    procedure WIPCostsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPCostsTotalName()));
    end;

    procedure WIPCostsTotalName(): Text[100]
    begin
        exit(WIPCostsTotalLbl);
    end;

    procedure JobWIPTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobWIPTotalName()));
    end;

    procedure JobWIPTotalName(): Text[100]
    begin
        exit(JobWIPTotalLbl);
    end;

    procedure AccountsReceivable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsReceivableName()));
    end;

    procedure AccountsReceivableName(): Text[100]
    begin
        exit(AccountsReceivableLbl);
    end;

    procedure CustomersDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomersDomesticName()));
    end;

    procedure CustomersDomesticName(): Text[100]
    begin
        exit(CustomersDomesticLbl);
    end;

    procedure CustomersForeign(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomersForeignName()));
    end;

    procedure CustomersForeignName(): Text[100]
    begin
        exit(CustomersForeignLbl);
    end;

    procedure AccruedInterest(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedInterestName()));
    end;

    procedure AccruedInterestName(): Text[100]
    begin
        exit(AccruedInterestLbl);
    end;

    procedure OtherReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherReceivablesName()));
    end;

    procedure OtherReceivablesName(): Text[100]
    begin
        exit(OtherReceivablesLbl);
    end;

    procedure AccountsReceivableTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsReceivableTotalName()));
    end;

    procedure AccountsReceivableTotalName(): Text[100]
    begin
        exit(AccountsReceivableTotalLbl);
    end;

    procedure PurchasePrepayments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasePrepaymentsName()));
    end;

    procedure PurchasePrepaymentsName(): Text[100]
    begin
        exit(PurchasePrepaymentsLbl);
    end;

    procedure VendorPrepaymentsVAT(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorPrepaymentsVATName()));
    end;

    procedure VendorPrepaymentsVATName(): Text[100]
    begin
        exit(VendorPrepaymentsVATLbl);
    end;

    procedure VendorPrepaymentsVAT10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorPrepaymentsVAT10Name()));
    end;

    procedure VendorPrepaymentsVAT10Name(): Text[100]
    begin
        exit(VendorPrepaymentsVAT10Lbl);
    end;

    procedure VendorPrepaymentsVAT25(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorPrepaymentsVAT25Name()));
    end;

    procedure VendorPrepaymentsVAT25Name(): Text[100]
    begin
        exit(VendorPrepaymentsVAT25Lbl);
    end;

    procedure PurchasePrepaymentsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasePrepaymentsTotalName()));
    end;

    procedure PurchasePrepaymentsTotalName(): Text[100]
    begin
        exit(PurchasePrepaymentsTotalLbl);
    end;

    procedure Securities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SecuritiesName()));
    end;

    procedure SecuritiesName(): Text[100]
    begin
        exit(SecuritiesLbl);
    end;

    procedure Bonds(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BondsName()));
    end;

    procedure BondsName(): Text[100]
    begin
        exit(BondsLbl);
    end;

    procedure SecuritiesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SecuritiesTotalName()));
    end;

    procedure SecuritiesTotalName(): Text[100]
    begin
        exit(SecuritiesTotalLbl);
    end;

    procedure LiquidAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LiquidAssetsName()));
    end;

    procedure LiquidAssetsName(): Text[100]
    begin
        exit(LiquidAssetsLbl);
    end;

    procedure Cash(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashName()));
    end;

    procedure CashName(): Text[100]
    begin
        exit(CashLbl);
    end;

    procedure BankLCY(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankLCYName()));
    end;

    procedure BankLCYName(): Text[100]
    begin
        exit(BankLCYLbl);
    end;

    procedure BankCurrencies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankCurrenciesName()));
    end;

    procedure BankCurrenciesName(): Text[100]
    begin
        exit(BankCurrenciesLbl);
    end;

    procedure GiroAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GiroAccountName()));
    end;

    procedure GiroAccountName(): Text[100]
    begin
        exit(GiroAccountLbl);
    end;

    procedure LiquidAssetsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LiquidAssetsTotalName()));
    end;

    procedure LiquidAssetsTotalName(): Text[100]
    begin
        exit(LiquidAssetsTotalLbl);
    end;

    procedure CurrentAssetsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CurrentAssetsTotalName()));
    end;

    procedure CurrentAssetsTotalName(): Text[100]
    begin
        exit(CurrentAssetsTotalLbl);
    end;

    procedure TotalAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAssetsName()));
    end;

    procedure TotalAssetsName(): Text[100]
    begin
        exit(TotalAssetsLbl);
    end;

    procedure LiabilitiesAndEquity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LiabilitiesAndEquityName()));
    end;

    procedure LiabilitiesAndEquityName(): Text[100]
    begin
        exit(LiabilitiesAndEquityLbl);
    end;

    procedure Stockholder(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StockholderName()));
    end;

    procedure StockholderName(): Text[100]
    begin
        exit(StockholderLbl);
    end;

    procedure CapitalStock(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapitalStockName()));
    end;

    procedure CapitalStockName(): Text[100]
    begin
        exit(CapitalStockLbl);
    end;

    procedure RetainedEarnings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RetainedEarningsName()));
    end;

    procedure RetainedEarningsName(): Text[100]
    begin
        exit(RetainedEarningsLbl);
    end;

    procedure NetIncomefortheYear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NetIncomefortheYearName()));
    end;

    procedure NetIncomefortheYearName(): Text[100]
    begin
        exit(NetIncomefortheYearLbl);
    end;

    procedure TotalStockholder(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalStockholderName()));
    end;

    procedure TotalStockholderName(): Text[100]
    begin
        exit(TotalStockholderLbl);
    end;

    procedure Allowances(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AllowancesName()));
    end;

    procedure AllowancesName(): Text[100]
    begin
        exit(AllowancesLbl);
    end;

    procedure DeferredTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferredTaxesName()));
    end;

    procedure DeferredTaxesName(): Text[100]
    begin
        exit(DeferredTaxesLbl);
    end;

    procedure AllowancesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AllowancesTotalName()));
    end;

    procedure AllowancesTotalName(): Text[100]
    begin
        exit(AllowancesTotalLbl);
    end;

    procedure Liabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LiabilitiesName()));
    end;

    procedure LiabilitiesName(): Text[100]
    begin
        exit(LiabilitiesLbl);
    end;

    procedure LongtermLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LongtermLiabilitiesName()));
    end;

    procedure LongtermLiabilitiesName(): Text[100]
    begin
        exit(LongtermLiabilitiesLbl);
    end;

    procedure LongtermBankLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LongtermBankLoansName()));
    end;

    procedure LongtermBankLoansName(): Text[100]
    begin
        exit(LongtermBankLoansLbl);
    end;

    procedure Mortgage(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MortgageName()));
    end;

    procedure MortgageName(): Text[100]
    begin
        exit(MortgageLbl);
    end;

    procedure LongtermLiabilitiesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LongtermLiabilitiesTotalName()));
    end;

    procedure LongtermLiabilitiesTotalName(): Text[100]
    begin
        exit(LongtermLiabilitiesTotalLbl);
    end;

    procedure ShorttermLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShorttermLiabilitiesName()));
    end;

    procedure ShorttermLiabilitiesName(): Text[100]
    begin
        exit(ShorttermLiabilitiesLbl);
    end;

    procedure RevolvingCredit(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevolvingCreditName()));
    end;

    procedure RevolvingCreditName(): Text[100]
    begin
        exit(RevolvingCreditLbl);
    end;

    procedure SalesPrepayments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesPrepaymentsName()));
    end;

    procedure SalesPrepaymentsName(): Text[100]
    begin
        exit(SalesPrepaymentsLbl);
    end;

    procedure CustomerPrepaymentsVAT0(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerPrepaymentsVAT0Name()));
    end;

    procedure CustomerPrepaymentsVAT0Name(): Text[100]
    begin
        exit(CustomerPrepaymentsVAT0Lbl);
    end;

    procedure CustomerPrepaymentsVAT10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerPrepaymentsVAT10Name()));
    end;

    procedure CustomerPrepaymentsVAT10Name(): Text[100]
    begin
        exit(CustomerPrepaymentsVAT10Lbl);
    end;

    procedure CustomerPrepaymentsVAT25(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerPrepaymentsVAT25Name()));
    end;

    procedure CustomerPrepaymentsVAT25Name(): Text[100]
    begin
        exit(CustomerPrepaymentsVAT25Lbl);
    end;

    procedure SalesPrepaymentsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesPrepaymentsTotalName()));
    end;

    procedure SalesPrepaymentsTotalName(): Text[100]
    begin
        exit(SalesPrepaymentsTotalLbl);
    end;

    procedure AccountsPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsPayableName()));
    end;

    procedure AccountsPayableName(): Text[100]
    begin
        exit(AccountsPayableLbl);
    end;

    procedure VendorsDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorsDomesticName()));
    end;

    procedure VendorsDomesticName(): Text[100]
    begin
        exit(VendorsDomesticLbl);
    end;

    procedure VendorsForeign(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorsForeignName()));
    end;

    procedure VendorsForeignName(): Text[100]
    begin
        exit(VendorsForeignLbl);
    end;

    procedure AccountsPayableTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsPayableTotalName()));
    end;

    procedure AccountsPayableTotalName(): Text[100]
    begin
        exit(AccountsPayableTotalLbl);
    end;

    procedure InvAdjmtInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvAdjmtInterimName()));
    end;

    procedure InvAdjmtInterimName(): Text[100]
    begin
        exit(InvAdjmtInterimLbl);
    end;

    procedure InvAdjmtInterimRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvAdjmtInterimRetailName()));
    end;

    procedure InvAdjmtInterimRetailName(): Text[100]
    begin
        exit(InvAdjmtInterimRetailLbl);
    end;

    procedure InvAdjmtInterimRawMat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvAdjmtInterimRawMatName()));
    end;

    procedure InvAdjmtInterimRawMatName(): Text[100]
    begin
        exit(InvAdjmtInterimRawMatLbl);
    end;

    procedure InvAdjmtInterimTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvAdjmtInterimTotalName()));
    end;

    procedure InvAdjmtInterimTotalName(): Text[100]
    begin
        exit(InvAdjmtInterimTotalLbl);
    end;

    procedure VAT(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VATName()));
    end;

    procedure VATName(): Text[100]
    begin
        exit(VATLbl);
    end;

    procedure SalesVAT25(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesVAT25Name()));
    end;

    procedure SalesVAT25Name(): Text[100]
    begin
        exit(SalesVAT25Lbl);
    end;

    procedure SalesVAT10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesVAT10Name()));
    end;

    procedure SalesVAT10Name(): Text[100]
    begin
        exit(SalesVAT10Lbl);
    end;

    procedure PurchaseVAT25EU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVAT25EUName()));
    end;

    procedure PurchaseVAT25EUName(): Text[100]
    begin
        exit(PurchaseVAT25EULbl);
    end;

    procedure PurchaseVAT10EU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVAT10EUName()));
    end;

    procedure PurchaseVAT10EUName(): Text[100]
    begin
        exit(PurchaseVAT10EULbl);
    end;

    procedure PurchaseVAT25(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVAT25Name()));
    end;

    procedure PurchaseVAT25Name(): Text[100]
    begin
        exit(PurchaseVAT25Lbl);
    end;

    procedure PurchaseVAT10(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVAT10Name()));
    end;

    procedure PurchaseVAT10Name(): Text[100]
    begin
        exit(PurchaseVAT10Lbl);
    end;

    procedure FuelTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FuelTaxName()));
    end;

    procedure FuelTaxName(): Text[100]
    begin
        exit(FuelTaxLbl);
    end;

    procedure ElectricityTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ElectricityTaxName()));
    end;

    procedure ElectricityTaxName(): Text[100]
    begin
        exit(ElectricityTaxLbl);
    end;

    procedure NaturalGasTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NaturalGasTaxName()));
    end;

    procedure NaturalGasTaxName(): Text[100]
    begin
        exit(NaturalGasTaxLbl);
    end;

    procedure CoalTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CoalTaxName()));
    end;

    procedure CoalTaxName(): Text[100]
    begin
        exit(CoalTaxLbl);
    end;

    procedure CO2Tax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CO2TaxName()));
    end;

    procedure CO2TaxName(): Text[100]
    begin
        exit(CO2TaxLbl);
    end;

    procedure WaterTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WaterTaxName()));
    end;

    procedure WaterTaxName(): Text[100]
    begin
        exit(WaterTaxLbl);
    end;

    procedure VATPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VATPayableName()));
    end;

    procedure VATPayableName(): Text[100]
    begin
        exit(VATPayableLbl);
    end;

    procedure VATTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VATTotalName()));
    end;

    procedure VATTotalName(): Text[100]
    begin
        exit(VATTotalLbl);
    end;

    procedure PersonnelrelatedItems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PersonnelrelatedItemsName()));
    end;

    procedure PersonnelrelatedItemsName(): Text[100]
    begin
        exit(PersonnelrelatedItemsLbl);
    end;

    procedure WithholdingTaxesPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WithholdingTaxesPayableName()));
    end;

    procedure WithholdingTaxesPayableName(): Text[100]
    begin
        exit(WithholdingTaxesPayableLbl);
    end;

    procedure SupplementaryTaxesPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SupplementaryTaxesPayableName()));
    end;

    procedure SupplementaryTaxesPayableName(): Text[100]
    begin
        exit(SupplementaryTaxesPayableLbl);
    end;

    procedure PayrollTaxesPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayrollTaxesPayableName()));
    end;

    procedure PayrollTaxesPayableName(): Text[100]
    begin
        exit(PayrollTaxesPayableLbl);
    end;

    procedure VacationCompensationPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VacationCompensationPayableName()));
    end;

    procedure VacationCompensationPayableName(): Text[100]
    begin
        exit(VacationCompensationPayableLbl);
    end;

    procedure EmployeesPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployeesPayableName()));
    end;

    procedure EmployeesPayableName(): Text[100]
    begin
        exit(EmployeesPayableLbl);
    end;

    procedure TotalPersonnelrelatedItems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPersonnelrelatedItemsName()));
    end;

    procedure TotalPersonnelrelatedItemsName(): Text[100]
    begin
        exit(TotalPersonnelrelatedItemsLbl);
    end;

    procedure OtherLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherLiabilitiesName()));
    end;

    procedure OtherLiabilitiesName(): Text[100]
    begin
        exit(OtherLiabilitiesLbl);
    end;

    procedure DividendsfortheFiscalYear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DividendsfortheFiscalYearName()));
    end;

    procedure DividendsfortheFiscalYearName(): Text[100]
    begin
        exit(DividendsfortheFiscalYearLbl);
    end;

    procedure CorporateTaxesPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CorporateTaxesPayableName()));
    end;

    procedure CorporateTaxesPayableName(): Text[100]
    begin
        exit(CorporateTaxesPayableLbl);
    end;

    procedure OtherLiabilitiesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherLiabilitiesTotalName()));
    end;

    procedure OtherLiabilitiesTotalName(): Text[100]
    begin
        exit(OtherLiabilitiesTotalLbl);
    end;

    procedure ShorttermLiabilitiesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShorttermLiabilitiesTotalName()));
    end;

    procedure ShorttermLiabilitiesTotalName(): Text[100]
    begin
        exit(ShorttermLiabilitiesTotalLbl);
    end;

    procedure TotalLiabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalLiabilitiesName()));
    end;

    procedure TotalLiabilitiesName(): Text[100]
    begin
        exit(TotalLiabilitiesLbl);
    end;

    procedure TotalLiabilitiesAndEquity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalLiabilitiesAndEquityName()));
    end;

    procedure TotalLiabilitiesAndEquityName(): Text[100]
    begin
        exit(TotalLiabilitiesAndEquityLbl);
    end;

    procedure IncomeStatement(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeStatementName()));
    end;

    procedure IncomeStatementName(): Text[100]
    begin
        exit(IncomeStatementLbl);
    end;

    procedure Revenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RevenueName()));
    end;

    procedure RevenueName(): Text[100]
    begin
        exit(RevenueLbl);
    end;

    procedure SalesofRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofRetailName()));
    end;

    procedure SalesofRetailName(): Text[100]
    begin
        exit(SalesofRetailLbl);
    end;

    procedure SalesRetailDom(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRetailDomName()));
    end;

    procedure SalesRetailDomName(): Text[100]
    begin
        exit(SalesRetailDomLbl);
    end;

    procedure SalesRetailEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRetailEUName()));
    end;

    procedure SalesRetailEUName(): Text[100]
    begin
        exit(SalesRetailEULbl);
    end;

    procedure SalesRetailExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRetailExportName()));
    end;

    procedure SalesRetailExportName(): Text[100]
    begin
        exit(SalesRetailExportLbl);
    end;

    procedure JobSalesAppliedRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobSalesAppliedRetailName()));
    end;

    procedure JobSalesAppliedRetailName(): Text[100]
    begin
        exit(JobSalesAppliedRetailLbl);
    end;

    procedure JobSalesAdjmtRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobSalesAdjmtRetailName()));
    end;

    procedure JobSalesAdjmtRetailName(): Text[100]
    begin
        exit(JobSalesAdjmtRetailLbl);
    end;

    procedure TotalSalesofRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesofRetailName()));
    end;

    procedure TotalSalesofRetailName(): Text[100]
    begin
        exit(TotalSalesofRetailLbl);
    end;

    procedure SalesofRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofRawMaterialsName()));
    end;

    procedure SalesofRawMaterialsName(): Text[100]
    begin
        exit(SalesofRawMaterialsLbl);
    end;

    procedure SalesRawMaterialsDom(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRawMaterialsDomName()));
    end;

    procedure SalesRawMaterialsDomName(): Text[100]
    begin
        exit(SalesRawMaterialsDomLbl);
    end;

    procedure SalesRawMaterialsEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRawMaterialsEUName()));
    end;

    procedure SalesRawMaterialsEUName(): Text[100]
    begin
        exit(SalesRawMaterialsEULbl);
    end;

    procedure SalesRawMaterialsExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRawMaterialsExportName()));
    end;

    procedure SalesRawMaterialsExportName(): Text[100]
    begin
        exit(SalesRawMaterialsExportLbl);
    end;

    procedure JobSalesAppliedRawMat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobSalesAppliedRawMatName()));
    end;

    procedure JobSalesAppliedRawMatName(): Text[100]
    begin
        exit(JobSalesAppliedRawMatLbl);
    end;

    procedure JobSalesAdjmtRawMat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobSalesAdjmtRawMatName()));
    end;

    procedure JobSalesAdjmtRawMatName(): Text[100]
    begin
        exit(JobSalesAdjmtRawMatLbl);
    end;

    procedure TotalSalesofRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesofRawMaterialsName()));
    end;

    procedure TotalSalesofRawMaterialsName(): Text[100]
    begin
        exit(TotalSalesofRawMaterialsLbl);
    end;

    procedure SalesofResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofResourcesName()));
    end;

    procedure SalesofResourcesName(): Text[100]
    begin
        exit(SalesofResourcesLbl);
    end;

    procedure SalesResourcesDom(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesResourcesDomName()));
    end;

    procedure SalesResourcesDomName(): Text[100]
    begin
        exit(SalesResourcesDomLbl);
    end;

    procedure SalesResourcesEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesResourcesEUName()));
    end;

    procedure SalesResourcesEUName(): Text[100]
    begin
        exit(SalesResourcesEULbl);
    end;

    procedure SalesResourcesExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesResourcesExportName()));
    end;

    procedure SalesResourcesExportName(): Text[100]
    begin
        exit(SalesResourcesExportLbl);
    end;

    procedure JobSalesAppliedResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobSalesAppliedResourcesName()));
    end;

    procedure JobSalesAppliedResourcesName(): Text[100]
    begin
        exit(JobSalesAppliedResourcesLbl);
    end;

    procedure JobSalesAdjmtResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobSalesAdjmtResourcesName()));
    end;

    procedure JobSalesAdjmtResourcesName(): Text[100]
    begin
        exit(JobSalesAdjmtResourcesLbl);
    end;

    procedure TotalSalesofResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesofResourcesName()));
    end;

    procedure TotalSalesofResourcesName(): Text[100]
    begin
        exit(TotalSalesofResourcesLbl);
    end;

    procedure SalesofJobs(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofJobsName()));
    end;

    procedure SalesofJobsName(): Text[100]
    begin
        exit(SalesofJobsLbl);
    end;

    procedure SalesOtherJobExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesOtherJobExpensesName()));
    end;

    procedure SalesOtherJobExpensesName(): Text[100]
    begin
        exit(SalesOtherJobExpensesLbl);
    end;

    procedure JobSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobSalesName()));
    end;

    procedure JobSalesName(): Text[100]
    begin
        exit(JobSalesLbl);
    end;

    procedure TotalSalesofJobs(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSalesofJobsName()));
    end;

    procedure TotalSalesofJobsName(): Text[100]
    begin
        exit(TotalSalesofJobsLbl);
    end;

    procedure ConsultingFeesDom(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsultingFeesDomName()));
    end;

    procedure ConsultingFeesDomName(): Text[100]
    begin
        exit(ConsultingFeesDomLbl);
    end;

    procedure FeesandChargesRecDom(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FeesandChargesRecDomName()));
    end;

    procedure FeesandChargesRecDomName(): Text[100]
    begin
        exit(FeesandChargesRecDomLbl);
    end;

    procedure DiscountGranted(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DiscountGrantedName()));
    end;

    procedure DiscountGrantedName(): Text[100]
    begin
        exit(DiscountGrantedLbl);
    end;

    procedure TotalRevenue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRevenueName()));
    end;

    procedure TotalRevenueName(): Text[100]
    begin
        exit(TotalRevenueLbl);
    end;

    procedure Cost(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostName()));
    end;

    procedure CostName(): Text[100]
    begin
        exit(CostLbl);
    end;

    procedure CostofRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofRetailName()));
    end;

    procedure CostofRetailName(): Text[100]
    begin
        exit(CostofRetailLbl);
    end;

    procedure PurchRetailDom(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchRetailDomName()));
    end;

    procedure PurchRetailDomName(): Text[100]
    begin
        exit(PurchRetailDomLbl);
    end;

    procedure PurchRetailEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchRetailEUName()));
    end;

    procedure PurchRetailEUName(): Text[100]
    begin
        exit(PurchRetailEULbl);
    end;

    procedure PurchRetailExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchRetailExportName()));
    end;

    procedure PurchRetailExportName(): Text[100]
    begin
        exit(PurchRetailExportLbl);
    end;

    procedure DiscReceivedRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DiscReceivedRetailName()));
    end;

    procedure DiscReceivedRetailName(): Text[100]
    begin
        exit(DiscReceivedRetailLbl);
    end;

    procedure DeliveryExpensesRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeliveryExpensesRetailName()));
    end;

    procedure DeliveryExpensesRetailName(): Text[100]
    begin
        exit(DeliveryExpensesRetailLbl);
    end;

    procedure InventoryAdjmtRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryAdjmtRetailName()));
    end;

    procedure InventoryAdjmtRetailName(): Text[100]
    begin
        exit(InventoryAdjmtRetailLbl);
    end;

    procedure JobCostAppliedRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostAppliedRetailName()));
    end;

    procedure JobCostAppliedRetailName(): Text[100]
    begin
        exit(JobCostAppliedRetailLbl);
    end;

    procedure JobCostAdjmtRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostAdjmtRetailName()));
    end;

    procedure JobCostAdjmtRetailName(): Text[100]
    begin
        exit(JobCostAdjmtRetailLbl);
    end;

    procedure CostofRetailSold(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofRetailSoldName()));
    end;

    procedure CostofRetailSoldName(): Text[100]
    begin
        exit(CostofRetailSoldLbl);
    end;

    procedure TotalCostofRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostofRetailName()));
    end;

    procedure TotalCostofRetailName(): Text[100]
    begin
        exit(TotalCostofRetailLbl);
    end;

    procedure CostofRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofRawMaterialsName()));
    end;

    procedure CostofRawMaterialsName(): Text[100]
    begin
        exit(CostofRawMaterialsLbl);
    end;

    procedure PurchRawMaterialsDom(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchRawMaterialsDomName()));
    end;

    procedure PurchRawMaterialsDomName(): Text[100]
    begin
        exit(PurchRawMaterialsDomLbl);
    end;

    procedure PurchRawMaterialsEU(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchRawMaterialsEUName()));
    end;

    procedure PurchRawMaterialsEUName(): Text[100]
    begin
        exit(PurchRawMaterialsEULbl);
    end;

    procedure PurchRawMaterialsExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchRawMaterialsExportName()));
    end;

    procedure PurchRawMaterialsExportName(): Text[100]
    begin
        exit(PurchRawMaterialsExportLbl);
    end;

    procedure DiscReceivedRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DiscReceivedRawMaterialsName()));
    end;

    procedure DiscReceivedRawMaterialsName(): Text[100]
    begin
        exit(DiscReceivedRawMaterialsLbl);
    end;

    procedure DeliveryExpensesRawMat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeliveryExpensesRawMatName()));
    end;

    procedure DeliveryExpensesRawMatName(): Text[100]
    begin
        exit(DeliveryExpensesRawMatLbl);
    end;

    procedure InventoryAdjmtRawMat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryAdjmtRawMatName()));
    end;

    procedure InventoryAdjmtRawMatName(): Text[100]
    begin
        exit(InventoryAdjmtRawMatLbl);
    end;

    procedure JobCostAppliedRawMat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostAppliedRawMatName()));
    end;

    procedure JobCostAppliedRawMatName(): Text[100]
    begin
        exit(JobCostAppliedRawMatLbl);
    end;

    procedure JobCostAdjmtRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostAdjmtRawMaterialsName()));
    end;

    procedure JobCostAdjmtRawMaterialsName(): Text[100]
    begin
        exit(JobCostAdjmtRawMaterialsLbl);
    end;

    procedure CostofRawMaterialsSold(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofRawMaterialsSoldName()));
    end;

    procedure CostofRawMaterialsSoldName(): Text[100]
    begin
        exit(CostofRawMaterialsSoldLbl);
    end;

    procedure TotalCostofRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostofRawMaterialsName()));
    end;

    procedure TotalCostofRawMaterialsName(): Text[100]
    begin
        exit(TotalCostofRawMaterialsLbl);
    end;

    procedure CostofResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofResourcesName()));
    end;

    procedure CostofResourcesName(): Text[100]
    begin
        exit(CostofResourcesLbl);
    end;

    procedure JobCostAppliedResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostAppliedResourcesName()));
    end;

    procedure JobCostAppliedResourcesName(): Text[100]
    begin
        exit(JobCostAppliedResourcesLbl);
    end;

    procedure JobCostAdjmtResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostAdjmtResourcesName()));
    end;

    procedure JobCostAdjmtResourcesName(): Text[100]
    begin
        exit(JobCostAdjmtResourcesLbl);
    end;

    procedure CostofResourcesUsed(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofResourcesUsedName()));
    end;

    procedure CostofResourcesUsedName(): Text[100]
    begin
        exit(CostofResourcesUsedLbl);
    end;

    procedure TotalCostofResources(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostofResourcesName()));
    end;

    procedure TotalCostofResourcesName(): Text[100]
    begin
        exit(TotalCostofResourcesLbl);
    end;

    procedure JobCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostsName()));
    end;

    procedure JobCostsName(): Text[100]
    begin
        exit(JobCostsLbl);
    end;

    procedure TotalCost(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalCostName()));
    end;

    procedure TotalCostName(): Text[100]
    begin
        exit(TotalCostLbl);
    end;

    procedure OperatingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OperatingExpensesName()));
    end;

    procedure OperatingExpensesName(): Text[100]
    begin
        exit(OperatingExpensesLbl);
    end;

    procedure BuildingMaintenanceExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BuildingMaintenanceExpensesName()));
    end;

    procedure BuildingMaintenanceExpensesName(): Text[100]
    begin
        exit(BuildingMaintenanceExpensesLbl);
    end;

    procedure Cleaning(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CleaningName()));
    end;

    procedure CleaningName(): Text[100]
    begin
        exit(CleaningLbl);
    end;

    procedure ElectricityandHeating(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ElectricityandHeatingName()));
    end;

    procedure ElectricityandHeatingName(): Text[100]
    begin
        exit(ElectricityandHeatingLbl);
    end;

    procedure RepairsandMaintenance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RepairsandMaintenanceName()));
    end;

    procedure RepairsandMaintenanceName(): Text[100]
    begin
        exit(RepairsandMaintenanceLbl);
    end;

    procedure TotalBldgMaintExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalBldgMaintExpensesName()));
    end;

    procedure TotalBldgMaintExpensesName(): Text[100]
    begin
        exit(TotalBldgMaintExpensesLbl);
    end;

    procedure AdministrativeExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdministrativeExpensesName()));
    end;

    procedure AdministrativeExpensesName(): Text[100]
    begin
        exit(AdministrativeExpensesLbl);
    end;

    procedure OfficeSupplies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OfficeSuppliesName()));
    end;

    procedure OfficeSuppliesName(): Text[100]
    begin
        exit(OfficeSuppliesLbl);
    end;

    procedure PhoneandFax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PhoneandFaxName()));
    end;

    procedure PhoneandFaxName(): Text[100]
    begin
        exit(PhoneandFaxLbl);
    end;

    procedure Postage(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PostageName()));
    end;

    procedure PostageName(): Text[100]
    begin
        exit(PostageLbl);
    end;

    procedure TotalAdministrativeExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalAdministrativeExpensesName()));
    end;

    procedure TotalAdministrativeExpensesName(): Text[100]
    begin
        exit(TotalAdministrativeExpensesLbl);
    end;

    procedure ComputerExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ComputerExpensesName()));
    end;

    procedure ComputerExpensesName(): Text[100]
    begin
        exit(ComputerExpensesLbl);
    end;

    procedure Software(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SoftwareName()));
    end;

    procedure SoftwareName(): Text[100]
    begin
        exit(SoftwareLbl);
    end;

    procedure ConsultantServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsultantServicesName()));
    end;

    procedure ConsultantServicesName(): Text[100]
    begin
        exit(ConsultantServicesLbl);
    end;

    procedure OtherComputerExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherComputerExpensesName()));
    end;

    procedure OtherComputerExpensesName(): Text[100]
    begin
        exit(OtherComputerExpensesLbl);
    end;

    procedure TotalComputerExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalComputerExpensesName()));
    end;

    procedure TotalComputerExpensesName(): Text[100]
    begin
        exit(TotalComputerExpensesLbl);
    end;

    procedure SellingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SellingExpensesName()));
    end;

    procedure SellingExpensesName(): Text[100]
    begin
        exit(SellingExpensesLbl);
    end;

    procedure Advertising(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvertisingName()));
    end;

    procedure AdvertisingName(): Text[100]
    begin
        exit(AdvertisingLbl);
    end;

    procedure EntertainmentandPR(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EntertainmentandPRName()));
    end;

    procedure EntertainmentandPRName(): Text[100]
    begin
        exit(EntertainmentandPRLbl);
    end;

    procedure Travel(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TravelName()));
    end;

    procedure TravelName(): Text[100]
    begin
        exit(TravelLbl);
    end;

    procedure DeliveryExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeliveryExpensesName()));
    end;

    procedure DeliveryExpensesName(): Text[100]
    begin
        exit(DeliveryExpensesLbl);
    end;

    procedure TotalSellingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalSellingExpensesName()));
    end;

    procedure TotalSellingExpensesName(): Text[100]
    begin
        exit(TotalSellingExpensesLbl);
    end;

    procedure VehicleExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VehicleExpensesName()));
    end;

    procedure VehicleExpensesName(): Text[100]
    begin
        exit(VehicleExpensesLbl);
    end;

    procedure GasolineandMotorOil(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GasolineandMotorOilName()));
    end;

    procedure GasolineandMotorOilName(): Text[100]
    begin
        exit(GasolineandMotorOilLbl);
    end;

    procedure RegistrationFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RegistrationFeesName()));
    end;

    procedure RegistrationFeesName(): Text[100]
    begin
        exit(RegistrationFeesLbl);
    end;

    procedure RepairsandMaintenanceExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RepairsandMaintenanceExpenseName()));
    end;

    procedure RepairsandMaintenanceExpenseName(): Text[100]
    begin
        exit(RepairsandMaintenanceExpensesLbl);
    end;

    procedure TotalVehicleExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalVehicleExpensesName()));
    end;

    procedure TotalVehicleExpensesName(): Text[100]
    begin
        exit(TotalVehicleExpensesLbl);
    end;

    procedure OtherOperatingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherOperatingExpensesName()));
    end;

    procedure OtherOperatingExpensesName(): Text[100]
    begin
        exit(OtherOperatingExpensesLbl);
    end;

    procedure CashDiscrepancies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashDiscrepanciesName()));
    end;

    procedure CashDiscrepanciesName(): Text[100]
    begin
        exit(CashDiscrepanciesLbl);
    end;

    procedure BadDebtExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BadDebtExpensesName()));
    end;

    procedure BadDebtExpensesName(): Text[100]
    begin
        exit(BadDebtExpensesLbl);
    end;

    procedure LegalandAccountingServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LegalandAccountingServicesName()));
    end;

    procedure LegalandAccountingServicesName(): Text[100]
    begin
        exit(LegalandAccountingServicesLbl);
    end;

    procedure Miscellaneous(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscellaneousName()));
    end;

    procedure MiscellaneousName(): Text[100]
    begin
        exit(MiscellaneousLbl);
    end;

    procedure OtherOperatingExpTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherOperatingExpTotalName()));
    end;

    procedure OtherOperatingExpTotalName(): Text[100]
    begin
        exit(OtherOperatingExpTotalLbl);
    end;

    procedure TotalOperatingExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalOperatingExpensesName()));
    end;

    procedure TotalOperatingExpensesName(): Text[100]
    begin
        exit(TotalOperatingExpensesLbl);
    end;

    procedure PersonnelExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PersonnelExpensesName()));
    end;

    procedure PersonnelExpensesName(): Text[100]
    begin
        exit(PersonnelExpensesLbl);
    end;

    procedure Wages(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WagesName()));
    end;

    procedure WagesName(): Text[100]
    begin
        exit(WagesLbl);
    end;

    procedure Salaries(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalariesName()));
    end;

    procedure SalariesName(): Text[100]
    begin
        exit(SalariesLbl);
    end;

    procedure RetirementPlanContributions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RetirementPlanContributionsName()));
    end;

    procedure RetirementPlanContributionsName(): Text[100]
    begin
        exit(RetirementPlanContributionsLbl);
    end;

    procedure VacationCompensation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VacationCompensationName()));
    end;

    procedure VacationCompensationName(): Text[100]
    begin
        exit(VacationCompensationLbl);
    end;

    procedure PayrollTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayrollTaxesName()));
    end;

    procedure PayrollTaxesName(): Text[100]
    begin
        exit(PayrollTaxesLbl);
    end;

    procedure TotalPersonnelExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalPersonnelExpensesName()));
    end;

    procedure TotalPersonnelExpensesName(): Text[100]
    begin
        exit(TotalPersonnelExpensesLbl);
    end;

    procedure DepreciationofFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationofFixedAssetsName()));
    end;

    procedure DepreciationofFixedAssetsName(): Text[100]
    begin
        exit(DepreciationofFixedAssetsLbl);
    end;

    procedure DepreciationBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationBuildingsName()));
    end;

    procedure DepreciationBuildingsName(): Text[100]
    begin
        exit(DepreciationBuildingsLbl);
    end;

    procedure DepreciationEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationEquipmentName()));
    end;

    procedure DepreciationEquipmentName(): Text[100]
    begin
        exit(DepreciationEquipmentLbl);
    end;

    procedure DepreciationVehicles(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationVehiclesName()));
    end;

    procedure DepreciationVehiclesName(): Text[100]
    begin
        exit(DepreciationVehiclesLbl);
    end;

    procedure GainsandLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainsandLossesName()));
    end;

    procedure GainsandLossesName(): Text[100]
    begin
        exit(GainsandLossesLbl);
    end;

    procedure TotalFixedAssetDepreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalFixedAssetDepreciationName()));
    end;

    procedure TotalFixedAssetDepreciationName(): Text[100]
    begin
        exit(TotalFixedAssetDepreciationLbl);
    end;

    procedure OtherCostsofOperations(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherCostsofOperationsName()));
    end;

    procedure OtherCostsofOperationsName(): Text[100]
    begin
        exit(OtherCostsofOperationsLbl);
    end;

    procedure NetOperatingIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NetOperatingIncomeName()));
    end;

    procedure NetOperatingIncomeName(): Text[100]
    begin
        exit(NetOperatingIncomeLbl);
    end;

    procedure InterestIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestIncomeName()));
    end;

    procedure InterestIncomeName(): Text[100]
    begin
        exit(InterestIncomeLbl);
    end;

    procedure InterestonBankBalances(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestonBankBalancesName()));
    end;

    procedure InterestonBankBalancesName(): Text[100]
    begin
        exit(InterestonBankBalancesLbl);
    end;

    procedure FinanceChargesfromCustomers(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinanceChargesfromCustomersName()));
    end;

    procedure FinanceChargesfromCustomersName(): Text[100]
    begin
        exit(FinanceChargesfromCustomersLbl);
    end;

    procedure PaymentDiscountsReceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymentDiscountsReceivedName()));
    end;

    procedure PaymentDiscountsReceivedName(): Text[100]
    begin
        exit(PaymentDiscountsReceivedLbl);
    end;

    procedure PmtDiscReceivedDecreases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PmtDiscReceivedDecreasesName()));
    end;

    procedure PmtDiscReceivedDecreasesName(): Text[100]
    begin
        exit(PmtDiscReceivedDecreasesLbl);
    end;

    procedure InvoiceRounding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvoiceRoundingName()));
    end;

    procedure InvoiceRoundingName(): Text[100]
    begin
        exit(InvoiceRoundingLbl);
    end;

    procedure ApplicationRounding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ApplicationRoundingName()));
    end;

    procedure ApplicationRoundingName(): Text[100]
    begin
        exit(ApplicationRoundingLbl);
    end;

    procedure PaymentToleranceReceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymentToleranceReceivedName()));
    end;

    procedure PaymentToleranceReceivedName(): Text[100]
    begin
        exit(PaymentToleranceReceivedLbl);
    end;

    procedure PmtTolReceivedDecreases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PmtTolReceivedDecreasesName()));
    end;

    procedure PmtTolReceivedDecreasesName(): Text[100]
    begin
        exit(PmtTolReceivedDecreasesLbl);
    end;

    procedure TotalInterestIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalInterestIncomeName()));
    end;

    procedure TotalInterestIncomeName(): Text[100]
    begin
        exit(TotalInterestIncomeLbl);
    end;

    procedure InterestExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestExpensesName()));
    end;

    procedure InterestExpensesName(): Text[100]
    begin
        exit(InterestExpensesLbl);
    end;

    procedure InterestonRevolvingCredit(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestonRevolvingCreditName()));
    end;

    procedure InterestonRevolvingCreditName(): Text[100]
    begin
        exit(InterestonRevolvingCreditLbl);
    end;

    procedure InterestonBankLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestonBankLoansName()));
    end;

    procedure InterestonBankLoansName(): Text[100]
    begin
        exit(InterestonBankLoansLbl);
    end;

    procedure MortgageInterest(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MortgageInterestName()));
    end;

    procedure MortgageInterestName(): Text[100]
    begin
        exit(MortgageInterestLbl);
    end;

    procedure FinanceChargestoVendors(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinanceChargestoVendorsName()));
    end;

    procedure FinanceChargestoVendorsName(): Text[100]
    begin
        exit(FinanceChargestoVendorsLbl);
    end;

    procedure PaymentDiscountsGranted(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymentDiscountsGrantedName()));
    end;

    procedure PaymentDiscountsGrantedName(): Text[100]
    begin
        exit(PaymentDiscountsGrantedLbl);
    end;

    procedure PmtDiscGrantedDecreases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PmtDiscGrantedDecreasesName()));
    end;

    procedure PmtDiscGrantedDecreasesName(): Text[100]
    begin
        exit(PmtDiscGrantedDecreasesLbl);
    end;

    procedure PaymentToleranceGranted(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymentToleranceGrantedName()));
    end;

    procedure PaymentToleranceGrantedName(): Text[100]
    begin
        exit(PaymentToleranceGrantedLbl);
    end;

    procedure PmtTolGrantedDecreases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PmtTolGrantedDecreasesName()));
    end;

    procedure PmtTolGrantedDecreasesName(): Text[100]
    begin
        exit(PmtTolGrantedDecreasesLbl);
    end;

    procedure TotalInterestExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalInterestExpensesName()));
    end;

    procedure TotalInterestExpensesName(): Text[100]
    begin
        exit(TotalInterestExpensesLbl);
    end;

    procedure UnrealizedFXGains(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UnrealizedFXGainsName()));
    end;

    procedure UnrealizedFXGainsName(): Text[100]
    begin
        exit(UnrealizedFXGainsLbl);
    end;

    procedure UnrealizedFXLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UnrealizedFXLossesName()));
    end;

    procedure UnrealizedFXLossesName(): Text[100]
    begin
        exit(UnrealizedFXLossesLbl);
    end;

    procedure RealizedFXGains(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RealizedFXGainsName()));
    end;

    procedure RealizedFXGainsName(): Text[100]
    begin
        exit(RealizedFXGainsLbl);
    end;

    procedure RealizedFXLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RealizedFXLossesName()));
    end;

    procedure RealizedFXLossesName(): Text[100]
    begin
        exit(RealizedFXLossesLbl);
    end;

    procedure NIBEFOREEXTRITEMSTAXES(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NIBEFOREEXTRITEMSTAXESName()));
    end;

    procedure NIBEFOREEXTRITEMSTAXESName(): Text[100]
    begin
        exit(NIBEFOREEXTRITEMSTAXESLbl);
    end;

    procedure ExtraordinaryIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExtraordinaryIncomeName()));
    end;

    procedure ExtraordinaryIncomeName(): Text[100]
    begin
        exit(ExtraordinaryIncomeLbl);
    end;

    procedure ExtraordinaryExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExtraordinaryExpensesName()));
    end;

    procedure ExtraordinaryExpensesName(): Text[100]
    begin
        exit(ExtraordinaryExpensesLbl);
    end;

    procedure NetIncomeBeforeTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NetIncomeBeforeTaxesName()));
    end;

    procedure NetIncomeBeforeTaxesName(): Text[100]
    begin
        exit(NetIncomeBeforeTaxesLbl);
    end;

    procedure CorporateTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CorporateTaxName()));
    end;

    procedure CorporateTaxName(): Text[100]
    begin
        exit(CorporateTaxLbl);
    end;

    procedure NetIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NetIncomeName()));
    end;

    procedure NetIncomeName(): Text[100]
    begin
        exit(NetIncomeLbl);
    end;



    [IntegrationEvent(false, false)]
    local procedure OnAfterAddGLAccountsForLocalization()
    begin
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        BalanceSheetLbl: Label 'BALANCE SHEET', MaxLength = 100;
        AssetsLbl: Label 'ASSETS', MaxLength = 100;
        FixedAssetsLbl: Label 'Fixed Assets', MaxLength = 100;
        TangibleFixedAssetsLbl: Label 'Tangible Fixed Assets', MaxLength = 100;
        LandandBuildingsBeginTotalLbl: Label 'Land and Buildings, Begin Total', MaxLength = 100;
        LandandBuildingsLbl: Label 'Land and Buildings', MaxLength = 100;
        IncreasesduringtheYearBuildingsLbl: Label 'Increases during the Year - Buildings', MaxLength = 100;
        IncreasesduringtheYearVehiclesLbl: Label 'Increases during the Year - Vehicles', MaxLength = 100;
        IncreasesduringtheYearLbl: Label 'Increases during the Year', MaxLength = 100;
        DecreasesduringtheYearBuildingsLbl: Label 'Decreases during the Year - Buildings', MaxLength = 100;
        DecreasesduringtheYearVehiclesLbl: Label 'Decreases during the Year - Vehicles', MaxLength = 100;
        DecreasesduringtheYearLbl: Label 'Decreases during the Year', MaxLength = 100;
        AccumDepreciationBuildingsLbl: Label 'Accum. Depreciation, Buildings', MaxLength = 100;
        LandandBuildingsTotalLbl: Label 'Land and Buildings, Total', MaxLength = 100;
        OperatingEquipmentBeginTotalLbl: Label 'Operating Equipment, Begin Total', MaxLength = 100;
        OperatingEquipmentLbl: Label 'Operating Equipment', MaxLength = 100;
        AccumDeprOperEquipLbl: Label 'Accum. Depr., Oper. Equip.', MaxLength = 100;
        OperatingEquipmentTotalLbl: Label 'Operating Equipment, Total', MaxLength = 100;
        VehiclesBeginTotalLbl: Label 'Vehicles, Begin Total', MaxLength = 100;
        VehiclesLbl: Label 'Vehicles', MaxLength = 100;
        AccumDepreciationVehiclesLbl: Label 'Accum. Depreciation, Vehicles', MaxLength = 100;
        VehiclesTotalLbl: Label 'Vehicles, Total', MaxLength = 100;
        TangibleFixedAssetsTotalLbl: Label 'Tangible Fixed Assets, Total', MaxLength = 100;
        FixedAssetsTotalLbl: Label 'Fixed Assets, Total', MaxLength = 100;
        CurrentAssetsLbl: Label 'Current Assets', MaxLength = 100;
        InventoryLbl: Label 'Inventory', MaxLength = 100;
        ResaleItemsLbl: Label 'Resale Items', MaxLength = 100;
        ResaleItemsInterimLbl: Label 'Resale Items (Interim)', MaxLength = 100;
        CostofResaleSoldInterimLbl: Label 'Cost of Resale Sold (Interim)', MaxLength = 100;
        FinishedGoodsLbl: Label 'Finished Goods', MaxLength = 100;
        FinishedGoodsInterimLbl: Label 'Finished Goods (Interim)', MaxLength = 100;
        RawMaterialsLbl: Label 'Raw Materials', MaxLength = 100;
        RawMaterialsInterimLbl: Label 'Raw Materials (Interim)', MaxLength = 100;
        CostofRawMatSoldInterimLbl: Label 'Cost of Raw Mat.Sold (Interim)', MaxLength = 100;
        PrimoInventoryLbl: Label 'Primo Inventory', MaxLength = 100;
        InventoryTotalLbl: Label 'Inventory, Total', MaxLength = 100;
        JobWIPLbl: Label 'Job WIP', MaxLength = 100;
        WIPSalesLbl: Label 'WIP Sales', MaxLength = 100;
        WIPJobSalesLbl: Label 'WIP Job Sales', MaxLength = 100;
        InvoicedJobSalesLbl: Label 'Invoiced Job Sales', MaxLength = 100;
        WIPSalesTotalLbl: Label 'WIP Sales, Total', MaxLength = 100;
        WIPCostsLbl: Label 'WIP Costs', MaxLength = 100;
        WIPJobCostsLbl: Label 'WIP Job Costs', MaxLength = 100;
        AccruedJobCostsLbl: Label 'Accrued Job Costs', MaxLength = 100;
        WIPCostsTotalLbl: Label 'WIP Costs, Total', MaxLength = 100;
        JobWIPTotalLbl: Label 'Job WIP, Total', MaxLength = 100;
        AccountsReceivableLbl: Label 'Accounts Receivable', MaxLength = 100;
        CustomersDomesticLbl: Label 'Customers Domestic', MaxLength = 100;
        CustomersForeignLbl: Label 'Customers, Foreign', MaxLength = 100;
        AccruedInterestLbl: Label 'Accrued Interest', MaxLength = 100;
        OtherReceivablesLbl: Label 'Other Receivables', MaxLength = 100;
        AccountsReceivableTotalLbl: Label 'Accounts Receivable, Total', MaxLength = 100;
        PurchasePrepaymentsLbl: Label 'Purchase Prepayments', MaxLength = 100;
        VendorPrepaymentsVATLbl: Label 'Vendor Prepayments VAT 0 %', MaxLength = 100;
        VendorPrepaymentsVAT10Lbl: Label 'Vendor Prepayments VAT 10 %', MaxLength = 100;
        VendorPrepaymentsVAT25Lbl: Label 'Vendor Prepayments VAT 25 %', MaxLength = 100;
        PurchasePrepaymentsTotalLbl: Label 'Purchase Prepayments, Total', MaxLength = 100;
        SecuritiesLbl: Label 'Securities', MaxLength = 100;
        BondsLbl: Label 'Bonds', MaxLength = 100;
        SecuritiesTotalLbl: Label 'Securities, Total', MaxLength = 100;
        LiquidAssetsLbl: Label 'Liquid Assets', MaxLength = 100;
        CashLbl: Label 'Cash', MaxLength = 100;
        BankLCYLbl: Label 'Bank, LCY', MaxLength = 100;
        BankCurrenciesLbl: Label 'Bank Currencies', MaxLength = 100;
        GiroAccountLbl: Label 'Giro Account', MaxLength = 100;
        LiquidAssetsTotalLbl: Label 'Liquid Assets, Total', MaxLength = 100;
        CurrentAssetsTotalLbl: Label 'Current Assets, Total', MaxLength = 100;
        TotalAssetsLbl: Label 'TOTAL ASSETS', MaxLength = 100;
        LiabilitiesAndEquityLbl: Label 'LIABILITIES AND EQUITY', MaxLength = 100;
        StockholderLbl: Label 'Stockholder''s Equity', MaxLength = 100;
        CapitalStockLbl: Label 'Capital Stock', MaxLength = 100;
        RetainedEarningsLbl: Label 'Retained Earnings', MaxLength = 100;
        NetIncomefortheYearLbl: Label 'Net Income for the Year', MaxLength = 100;
        TotalStockholderLbl: Label 'Total Stockholder''s Equity', MaxLength = 100;
        AllowancesLbl: Label 'Allowances', MaxLength = 100;
        DeferredTaxesLbl: Label 'Deferred Taxes', MaxLength = 100;
        AllowancesTotalLbl: Label 'Allowances, Total', MaxLength = 100;
        LiabilitiesLbl: Label 'Liabilities', MaxLength = 100;
        LongtermLiabilitiesLbl: Label 'Long-term Liabilities', MaxLength = 100;
        LongtermBankLoansLbl: Label 'Long-term Bank Loans', MaxLength = 100;
        MortgageLbl: Label 'Mortgage', MaxLength = 100;
        LongtermLiabilitiesTotalLbl: Label 'Long-term Liabilities, Total', MaxLength = 100;
        ShorttermLiabilitiesLbl: Label 'Short-term Liabilities', MaxLength = 100;
        RevolvingCreditLbl: Label 'Revolving Credit', MaxLength = 100;
        SalesPrepaymentsLbl: Label 'Sales Prepayments', MaxLength = 100;
        CustomerPrepaymentsVAT0Lbl: Label 'Customer Prepayments VAT 0 %', MaxLength = 100;
        CustomerPrepaymentsVAT10Lbl: Label 'Customer Prepayments VAT 10 %', MaxLength = 100;
        CustomerPrepaymentsVAT25Lbl: Label 'Customer Prepayments VAT 25 %', MaxLength = 100;
        SalesPrepaymentsTotalLbl: Label 'Sales Prepayments, Total', MaxLength = 100;
        AccountsPayableLbl: Label 'Accounts Payable', MaxLength = 100;
        VendorsDomesticLbl: Label 'Vendors, Domestic', MaxLength = 100;
        VendorsForeignLbl: Label 'Vendors, Foreign', MaxLength = 100;
        AccountsPayableTotalLbl: Label 'Accounts Payable, Total', MaxLength = 100;
        InvAdjmtInterimLbl: Label 'Inv. Adjmt. (Interim)', MaxLength = 100;
        InvAdjmtInterimRetailLbl: Label 'Inv. Adjmt. (Interim), Retail', MaxLength = 100;
        InvAdjmtInterimRawMatLbl: Label 'Inv. Adjmt. (Interim), Raw Mat', MaxLength = 100;
        InvAdjmtInterimTotalLbl: Label 'Inv. Adjmt. (Interim), Total', MaxLength = 100;
        VATLbl: Label 'VAT', MaxLength = 100;
        SalesVAT25Lbl: Label 'Sales VAT 25 %', MaxLength = 100;
        SalesVAT10Lbl: Label 'Sales VAT 10 %', MaxLength = 100;
        PurchaseVAT25EULbl: Label 'Purchase VAT 25 % EU', MaxLength = 100;
        PurchaseVAT10EULbl: Label 'Purchase VAT 10 % EU', MaxLength = 100;
        PurchaseVAT25Lbl: Label 'Purchase VAT 25 %', MaxLength = 100;
        PurchaseVAT10Lbl: Label 'Purchase VAT 10 %', MaxLength = 100;
        FuelTaxLbl: Label 'Fuel Tax', MaxLength = 100;
        ElectricityTaxLbl: Label 'Electricity Tax', MaxLength = 100;
        NaturalGasTaxLbl: Label 'Natural Gas Tax', MaxLength = 100;
        CoalTaxLbl: Label 'Coal Tax', MaxLength = 100;
        CO2TaxLbl: Label 'CO2 Tax', MaxLength = 100;
        WaterTaxLbl: Label 'Water Tax', MaxLength = 100;
        VATPayableLbl: Label 'VAT Payable', MaxLength = 100;
        VATTotalLbl: Label 'VAT, Total', MaxLength = 100;
        PersonnelrelatedItemsLbl: Label 'Personnel-related Items', MaxLength = 100;
        WithholdingTaxesPayableLbl: Label 'Withholding Taxes Payable', MaxLength = 100;
        SupplementaryTaxesPayableLbl: Label 'Supplementary Taxes Payable', MaxLength = 100;
        PayrollTaxesPayableLbl: Label 'Payroll Taxes Payable', MaxLength = 100;
        VacationCompensationPayableLbl: Label 'Vacation Compensation Payable', MaxLength = 100;
        EmployeesPayableLbl: Label 'Employees Payable', MaxLength = 100;
        TotalPersonnelrelatedItemsLbl: Label 'Total Personnel-related Items', MaxLength = 100;
        OtherLiabilitiesLbl: Label 'Other Liabilities', MaxLength = 100;
        DividendsfortheFiscalYearLbl: Label 'Dividends for the Fiscal Year', MaxLength = 100;
        CorporateTaxesPayableLbl: Label 'Corporate Taxes Payable', MaxLength = 100;
        OtherLiabilitiesTotalLbl: Label 'Other Liabilities, Total', MaxLength = 100;
        ShorttermLiabilitiesTotalLbl: Label 'Short-term Liabilities, Total', MaxLength = 100;
        TotalLiabilitiesLbl: Label 'Total Liabilities', MaxLength = 100;
        TotalLiabilitiesAndEquityLbl: Label 'TOTAL LIABILITIES AND EQUITY', MaxLength = 100;
        IncomeStatementLbl: Label 'INCOME STATEMENT', MaxLength = 100;
        RevenueLbl: Label 'Revenue', MaxLength = 100;
        SalesofRetailLbl: Label 'Sales of Retail', MaxLength = 100;
        SalesRetailDomLbl: Label 'Sales, Retail - Dom.', MaxLength = 100;
        SalesRetailEULbl: Label 'Sales, Retail - EU', MaxLength = 100;
        SalesRetailExportLbl: Label 'Sales, Retail - Export', MaxLength = 100;
        JobSalesAppliedRetailLbl: Label 'Job Sales Applied, Retail', MaxLength = 100;
        JobSalesAdjmtRetailLbl: Label 'Job Sales Adjmt., Retail', MaxLength = 100;
        TotalSalesofRetailLbl: Label 'Total Sales of Retail', MaxLength = 100;
        SalesofRawMaterialsLbl: Label 'Sales of Raw Materials', MaxLength = 100;
        SalesRawMaterialsDomLbl: Label 'Sales, Raw Materials - Dom.', MaxLength = 100;
        SalesRawMaterialsEULbl: Label 'Sales, Raw Materials - EU', MaxLength = 100;
        SalesRawMaterialsExportLbl: Label 'Sales, Raw Materials - Export', MaxLength = 100;
        JobSalesAppliedRawMatLbl: Label 'Job Sales Applied, Raw Mat.', MaxLength = 100;
        JobSalesAdjmtRawMatLbl: Label 'Job Sales Adjmt., Raw Mat.', MaxLength = 100;
        TotalSalesofRawMaterialsLbl: Label 'Total Sales of Raw Materials', MaxLength = 100;
        SalesofResourcesLbl: Label 'Sales of Resources', MaxLength = 100;
        SalesResourcesDomLbl: Label 'Sales, Resources - Dom.', MaxLength = 100;
        SalesResourcesEULbl: Label 'Sales, Resources - EU', MaxLength = 100;
        SalesResourcesExportLbl: Label 'Sales, Resources - Export', MaxLength = 100;
        JobSalesAppliedResourcesLbl: Label 'Job Sales Applied, Resources', MaxLength = 100;
        JobSalesAdjmtResourcesLbl: Label 'Job Sales Adjmt., Resources', MaxLength = 100;
        TotalSalesofResourcesLbl: Label 'Total Sales of Resources', MaxLength = 100;
        SalesofJobsLbl: Label 'Sales of Jobs', MaxLength = 100;
        SalesOtherJobExpensesLbl: Label 'Sales, Other Job Expenses', MaxLength = 100;
        JobSalesLbl: Label 'Job Sales', MaxLength = 100;
        TotalSalesofJobsLbl: Label 'Total Sales of Jobs', MaxLength = 100;
        ConsultingFeesDomLbl: Label 'Consulting Fees - Dom.', MaxLength = 100;
        FeesandChargesRecDomLbl: Label 'Fees and Charges Rec. - Dom.', MaxLength = 100;
        DiscountGrantedLbl: Label 'Discount Granted', MaxLength = 100;
        TotalRevenueLbl: Label 'Total Revenue', MaxLength = 100;
        CostLbl: Label 'Cost', MaxLength = 100;
        CostofRetailLbl: Label 'Cost of Retail', MaxLength = 100;
        PurchRetailDomLbl: Label 'Purch., Retail - Dom.', MaxLength = 100;
        PurchRetailEULbl: Label 'Purch., Retail - EU', MaxLength = 100;
        PurchRetailExportLbl: Label 'Purch., Retail - Export', MaxLength = 100;
        DiscReceivedRetailLbl: Label 'Disc. Received, Retail', MaxLength = 100;
        DeliveryExpensesRetailLbl: Label 'Delivery Expenses, Retail', MaxLength = 100;
        InventoryAdjmtRetailLbl: Label 'Inventory Adjmt., Retail', MaxLength = 100;
        JobCostAppliedRetailLbl: Label 'Job Cost Applied, Retail', MaxLength = 100;
        JobCostAdjmtRetailLbl: Label 'Job Cost Adjmt., Retail', MaxLength = 100;
        CostofRetailSoldLbl: Label 'Cost of Retail Sold', MaxLength = 100;
        TotalCostofRetailLbl: Label 'Total Cost of Retail', MaxLength = 100;
        CostofRawMaterialsLbl: Label 'Cost of Raw Materials', MaxLength = 100;
        PurchRawMaterialsDomLbl: Label 'Purch., Raw Materials - Dom.', MaxLength = 100;
        PurchRawMaterialsEULbl: Label 'Purch., Raw Materials - EU', MaxLength = 100;
        PurchRawMaterialsExportLbl: Label 'Purch., Raw Materials - Export', MaxLength = 100;
        DiscReceivedRawMaterialsLbl: Label 'Disc. Received, Raw Materials', MaxLength = 100;
        DeliveryExpensesRawMatLbl: Label 'Delivery Expenses, Raw Mat.', MaxLength = 100;
        InventoryAdjmtRawMatLbl: Label 'Inventory Adjmt., Raw Mat.', MaxLength = 100;
        JobCostAppliedRawMatLbl: Label 'Job Cost Applied, Raw Mat.', MaxLength = 100;
        JobCostAdjmtRawMaterialsLbl: Label 'Job Cost Adjmt., Raw Materials', MaxLength = 100;
        CostofRawMaterialsSoldLbl: Label 'Cost of Raw Materials Sold', MaxLength = 100;
        TotalCostofRawMaterialsLbl: Label 'Total Cost of Raw Materials', MaxLength = 100;
        CostofResourcesLbl: Label 'Cost of Resources', MaxLength = 100;
        JobCostAppliedResourcesLbl: Label 'Job Cost Applied, Resources', MaxLength = 100;
        JobCostAdjmtResourcesLbl: Label 'Job Cost Adjmt., Resources', MaxLength = 100;
        CostofResourcesUsedLbl: Label 'Cost of Resources Used', MaxLength = 100;
        TotalCostofResourcesLbl: Label 'Total Cost of Resources', MaxLength = 100;
        JobCostsLbl: Label 'Job Costs', MaxLength = 100;
        TotalCostLbl: Label 'Total Cost', MaxLength = 100;
        OperatingExpensesLbl: Label 'Operating Expenses', MaxLength = 100;
        BuildingMaintenanceExpensesLbl: Label 'Building Maintenance Expenses', MaxLength = 100;
        CleaningLbl: Label 'Cleaning', MaxLength = 100;
        ElectricityandHeatingLbl: Label 'Electricity and Heating', MaxLength = 100;
        RepairsandMaintenanceLbl: Label 'Repairs and Maintenance', MaxLength = 100;
        RepairsandMaintenanceExpensesLbl: Label 'Repairs and Maintenance Expenses', MaxLength = 100;
        TotalBldgMaintExpensesLbl: Label 'Total Bldg. Maint. Expenses', MaxLength = 100;
        AdministrativeExpensesLbl: Label 'Administrative Expenses', MaxLength = 100;
        OfficeSuppliesLbl: Label 'Office Supplies', MaxLength = 100;
        PhoneandFaxLbl: Label 'Phone and Fax', MaxLength = 100;
        PostageLbl: Label 'Postage', MaxLength = 100;
        TotalAdministrativeExpensesLbl: Label 'Total Administrative Expenses', MaxLength = 100;
        ComputerExpensesLbl: Label 'Computer Expenses', MaxLength = 100;
        SoftwareLbl: Label 'Software', MaxLength = 100;
        ConsultantServicesLbl: Label 'Consultant Services', MaxLength = 100;
        OtherComputerExpensesLbl: Label 'Other Computer Expenses', MaxLength = 100;
        TotalComputerExpensesLbl: Label 'Total Computer Expenses', MaxLength = 100;
        SellingExpensesLbl: Label 'Selling Expenses', MaxLength = 100;
        AdvertisingLbl: Label 'Advertising', MaxLength = 100;
        EntertainmentandPRLbl: Label 'Entertainment and PR', MaxLength = 100;
        TravelLbl: Label 'Travel', MaxLength = 100;
        DeliveryExpensesLbl: Label 'Delivery Expenses', MaxLength = 100;
        TotalSellingExpensesLbl: Label 'Total Selling Expenses', MaxLength = 100;
        VehicleExpensesLbl: Label 'Vehicle Expenses', MaxLength = 100;
        GasolineandMotorOilLbl: Label 'Gasoline and Motor Oil', MaxLength = 100;
        RegistrationFeesLbl: Label 'Registration Fees', MaxLength = 100;
        TotalVehicleExpensesLbl: Label 'Total Vehicle Expenses', MaxLength = 100;
        OtherOperatingExpensesLbl: Label 'Other Operating Expenses', MaxLength = 100;
        CashDiscrepanciesLbl: Label 'Cash Discrepancies', MaxLength = 100;
        BadDebtExpensesLbl: Label 'Bad Debt Expenses', MaxLength = 100;
        LegalandAccountingServicesLbl: Label 'Legal and Accounting Services', MaxLength = 100;
        MiscellaneousLbl: Label 'Miscellaneous', MaxLength = 100;
        OtherOperatingExpTotalLbl: Label 'Other Operating Exp., Total', MaxLength = 100;
        TotalOperatingExpensesLbl: Label 'Total Operating Expenses', MaxLength = 100;
        PersonnelExpensesLbl: Label 'Personnel Expenses', MaxLength = 100;
        WagesLbl: Label 'Wages', MaxLength = 100;
        SalariesLbl: Label 'Salaries', MaxLength = 100;
        RetirementPlanContributionsLbl: Label 'Retirement Plan Contributions', MaxLength = 100;
        VacationCompensationLbl: Label 'Vacation Compensation', MaxLength = 100;
        PayrollTaxesLbl: Label 'Payroll Taxes', MaxLength = 100;
        TotalPersonnelExpensesLbl: Label 'Total Personnel Expenses', MaxLength = 100;
        DepreciationofFixedAssetsLbl: Label 'Depreciation of Fixed Assets', MaxLength = 100;
        DepreciationBuildingsLbl: Label 'Depreciation, Buildings', MaxLength = 100;
        DepreciationEquipmentLbl: Label 'Depreciation, Equipment', MaxLength = 100;
        DepreciationVehiclesLbl: Label 'Depreciation, Vehicles', MaxLength = 100;
        GainsandLossesLbl: Label 'Gains and Losses', MaxLength = 100;
        TotalFixedAssetDepreciationLbl: Label 'Total Fixed Asset Depreciation', MaxLength = 100;
        OtherCostsofOperationsLbl: Label 'Other Costs of Operations', MaxLength = 100;
        NetOperatingIncomeLbl: Label 'Net Operating Income', MaxLength = 100;
        InterestIncomeLbl: Label 'Interest Income', MaxLength = 100;
        InterestonBankBalancesLbl: Label 'Interest on Bank Balances', MaxLength = 100;
        FinanceChargesfromCustomersLbl: Label 'Finance Charges from Customers', MaxLength = 100;
        PaymentDiscountsReceivedLbl: Label 'Payment Discounts Received', MaxLength = 100;
        PmtDiscReceivedDecreasesLbl: Label 'PmtDisc. Received - Decreases', MaxLength = 100;
        InvoiceRoundingLbl: Label 'Invoice Rounding', MaxLength = 100;
        ApplicationRoundingLbl: Label 'Application Rounding', MaxLength = 100;
        PaymentToleranceReceivedLbl: Label 'Payment Tolerance Received', MaxLength = 100;
        PmtTolReceivedDecreasesLbl: Label 'Pmt. Tol. Received Decreases', MaxLength = 100;
        TotalInterestIncomeLbl: Label 'Total Interest Income', MaxLength = 100;
        InterestExpensesLbl: Label 'Interest Expenses', MaxLength = 100;
        InterestonRevolvingCreditLbl: Label 'Interest on Revolving Credit', MaxLength = 100;
        InterestonBankLoansLbl: Label 'Interest on Bank Loans', MaxLength = 100;
        MortgageInterestLbl: Label 'Mortgage Interest', MaxLength = 100;
        FinanceChargestoVendorsLbl: Label 'Finance Charges to Vendors', MaxLength = 100;
        PaymentDiscountsGrantedLbl: Label 'Payment Discounts Granted', MaxLength = 100;
        PmtDiscGrantedDecreasesLbl: Label 'PmtDisc. Granted - Decreases', MaxLength = 100;
        PaymentToleranceGrantedLbl: Label 'Payment Tolerance Granted', MaxLength = 100;
        PmtTolGrantedDecreasesLbl: Label 'Pmt. Tol. Granted Decreases', MaxLength = 100;
        TotalInterestExpensesLbl: Label 'Total Interest Expenses', MaxLength = 100;
        UnrealizedFXGainsLbl: Label 'Unrealized FX Gains', MaxLength = 100;
        UnrealizedFXLossesLbl: Label 'Unrealized FX Losses', MaxLength = 100;
        RealizedFXGainsLbl: Label 'Realized FX Gains', MaxLength = 100;
        RealizedFXLossesLbl: Label 'Realized FX Losses', MaxLength = 100;
        NIBEFOREEXTRITEMSTAXESLbl: Label 'NI BEFORE EXTR. ITEMS & TAXES', MaxLength = 100;
        ExtraordinaryIncomeLbl: Label 'Extraordinary Income', MaxLength = 100;
        ExtraordinaryExpensesLbl: Label 'Extraordinary Expenses', MaxLength = 100;
        NetIncomeBeforeTaxesLbl: Label 'NET INCOME BEFORE TAXES', MaxLength = 100;
        CorporateTaxLbl: Label 'Corporate Tax', MaxLength = 100;
        NetIncomeLbl: Label 'NET INCOME', MaxLength = 100;
}