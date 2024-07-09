codeunit 31212 "Create CZ GL Accounts"
{
    InherentPermissions = X;
    InherentEntitlements = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Common GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyCommonGLAccounts()
    var
        InventorySetup: Record "Inventory Setup";
        ContosoGLAccount: Codeunit "Contoso GL Account";
        CommonGLAccount: Codeunit "Create Common GL Account";
    begin
        InventorySetup.Get();

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '311100');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '321100');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '604110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '131050');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '343521');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '343121');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '111100');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '131050');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '501990');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '501990');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '112200');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '132200');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '131950');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '131450');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '112100');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '131500');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '132100');
        if InventorySetup."Expected Cost Posting to G/L" then
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '132110')
        else
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '602220');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyManufacturingGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        MfgGLAccount: Codeunit "Create Mfg GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '518900');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '511200');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '511300');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '581100');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '581200');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '581400');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '581300');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '581300');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '123100');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '121100');
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create FA GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyFixedAssetGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        FAGLAccount: Codeunit "Create FA GL Account";
        FixedAssetModuleCZ: Codeunit "Fixed Asset Module CZ";
    begin
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.IncreasesDuringTheYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DecreasesDuringTheYearName(), '022300');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.AccumDepreciationBuildingsName(), '082300');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.MiscellaneousName(), '511100');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DepreciationEquipmentName(), '551300');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.GainsAndLossesName(), '022300');

        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcquisitionCostBuildingsName(), '021100');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.AcquisitionCostBuildings(), FixedAssetModuleCZ.AcquisitionCostBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.AccumDepreciationBuildingsName(), '081100');
        ContosoGLAccount.InsertGLAccount(FAGLAccount.AccumDepreciationBuildings(), FAGLAccount.AccumDepreciationBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.WriteDownBuildingsName(), '021100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.Custom2BuildingsName(), '042100');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.Custom2Buildings(), FixedAssetModuleCZ.Custom2BuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcqCostonDisposalBuildingsName(), '021100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AccumDepronDisposalBuildingsName(), '081100');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.AccumDepronDisposalBuildings(), FixedAssetModuleCZ.AccumDepronDisposalBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.WriteDownonDisposalBuildingsName(), '021100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.Custom2onDisposalBuildingsName(), '042100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.GainsonDisposalBuildingsName(), '551900');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.GainsonDisposalBuildings(), FixedAssetModuleCZ.GainsonDisposalBuildingsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.LossesonDisposalBuildingsName(), '551900');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValonDispGainBuildingsName(), '541100');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.BookValonDispGainBuildings(), FixedAssetModuleCZ.BookValonDispGainBuildingsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValonDispLossBuildingsName(), '541100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesonDispGainBuildingsName(), '081100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesonDispLossBuildingsName(), '081100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.MaintenanceExpenseBuildingsName(), '511100');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.MaintenanceExpenseBuildings(), FixedAssetModuleCZ.MaintenanceExpenseBuildingsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcquisitionCostBalBuildingsName(), '042100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.DepreciationExpenseBuildingsName(), '551100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcqusitionCostBalonDisposalBuildingsName(), '081100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.ApprecBalonDispBuildingsName(), '081100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationonDisposalBuildingsName(), '021100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationBuildingsName(), '021100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationBalBuildingsName(), '042100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesBalBuildingsName(), '395100');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.SalesBalBuildings(), FixedAssetModuleCZ.SalesBalBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValueBalonDisposalBuildingsName(), '081100');

        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcquisitionCostGoodwillName(), '015100');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.AcquisitionCostGoodwill(), FixedAssetModuleCZ.AcquisitionCostGoodwillName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AccumDepreciationGoodwillName(), '075100');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.AccumDepreciationGoodwill(), FixedAssetModuleCZ.AccumDepreciationGoodwillName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.WriteDownGoodwillName(), '015100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.Custom2GoodwillName(), '041100');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.Custom2Goodwill(), FixedAssetModuleCZ.Custom2GoodwillName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcqCostonDisposalGoodwillName(), '015100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AccumDepronDisposalGoodwillName(), '075100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.WriteDownonDisposalGoodwillName(), '015100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.Custom2onDisposalGoodwillName(), '041100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.GainsonDisposalGoodwillName(), '551900');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.LossesonDisposalGoodwillName(), '551900');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValonDispGainGoodwillName(), '541100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValonDispLossGoodwillName(), '541100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesonDispGainGoodwillName(), '075100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesonDispLossGoodwillName(), '075100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.MaintenanceExpenseGoodwillName(), '511100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcquisitionCostBalGoodwillName(), '041100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.DepreciationExpenseGoodwillName(), '551700');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.DepreciationExpenseGoodwill(), FixedAssetModuleCZ.DepreciationExpenseGoodwillName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcqusitionCostBalonDisposalGoodwillName(), '075100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.ApprecBalonDispGoodwillName(), '075100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationonDisposalGoodwillName(), '015100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationGoodwillName(), '015100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationBalGoodwillName(), '041100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesBalGoodwillName(), '395100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValueBalonDisposalGoodwillName(), '075100');

        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcquisitionCostVehiclesName(), '022300');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.AcquisitionCostVehicles(), FixedAssetModuleCZ.AcquisitionCostVehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AccumDepreciationVehiclesName(), '082300');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.AccumDepreciationVehicles(), FixedAssetModuleCZ.AccumDepreciationVehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.WriteDownVehiclesName(), '022300');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.Custom2VehiclesName(), '042300');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.Custom2Vehicles(), FixedAssetModuleCZ.Custom2VehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcqCostonDisposalVehiclesName(), '022300');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AccumDepronDisposalVehiclesName(), '082300');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.WriteDownonDisposalVehiclesName(), '022300');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.Custom2onDisposalVehiclesName(), '042300');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.GainsonDisposalVehiclesName(), '551900');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.LossesonDisposalVehiclesName(), '551900');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValonDispGainVehiclesName(), '541100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValonDispLossVehiclesName(), '541100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesonDispGainVehiclesName(), '082300');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesonDispLossVehiclesName(), '082300');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.MaintenanceExpenseVehiclesName(), '511100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcquisitionCostBalVehiclesName(), '042300');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.DepreciationExpenseVehiclesName(), '551300');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.DepreciationExpenseVehicles(), FixedAssetModuleCZ.DepreciationExpenseVehiclesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcqusitionCostBalonDisposalVehiclesName(), '082300');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.ApprecBalonDispVehiclesName(), '082300');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationonDisposalVehiclesName(), '022300');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationVehiclesName(), '022300');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationBalVehiclesName(), '042300');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesBalVehiclesName(), '395100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValueBalonDisposalVehiclesName(), '082300');

        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcquisitionCostEquipmentName(), '022100');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.AcquisitionCostEquipment(), FixedAssetModuleCZ.AcquisitionCostEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AccumDepreciationEquipmentName(), '082100');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.AccumDepreciationEquipment(), FixedAssetModuleCZ.AccumDepreciationEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.WriteDownEquipmentName(), '022100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.Custom2EquipmentName(), '042200');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.Custom2Equipment(), FixedAssetModuleCZ.Custom2EquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcqCostonDisposalEquipmentName(), '022100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AccumDepronDisposalEquipmentName(), '082100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.WriteDownonDisposalEquipmentName(), '022100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.Custom2onDisposalEquipmentName(), '042200');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.GainsonDisposalEquipmentName(), '551900');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.LossesonDisposalEquipmentName(), '551900');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValonDispGainEquipmentName(), '541100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValonDispLossEquipmentName(), '541100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesonDispGainEquipmentName(), '082100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesonDispLossEquipmentName(), '082100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.MaintenanceExpenseEquipmentName(), '511100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcquisitionCostBalEquipmentName(), '042200');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.DepreciationExpenseEquipmentName(), '551200');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.DepreciationExpenseEquipment(), FixedAssetModuleCZ.DepreciationExpenseEquipmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcqusitionCostBalonDisposalEquipmentName(), '082100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.ApprecBalonDispEquipmentName(), '082100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationonDisposalEquipmentName(), '022100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationEquipmentName(), '022100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationBalEquipmentName(), '042200');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesBalEquipmentName(), '395100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValueBalonDisposalEquipmentName(), '082100');

        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcquisitionCostPatentsName(), '012100');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.AcquisitionCostPatents(), FixedAssetModuleCZ.AcquisitionCostPatentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AccumDepreciationPatentsName(), '072100');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.AccumDepreciationPatents(), FixedAssetModuleCZ.AccumDepreciationPatentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.WriteDownPatentsName(), '012100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.Custom2PatentsName(), '041100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcqCostonDisposalPatentsName(), '012100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AccumDepronDisposalPatentsName(), '072100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.WriteDownonDisposalPatentsName(), '012100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.Custom2onDisposalPatentsName(), '041100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.GainsonDisposalPatentsName(), '551900');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.LossesonDisposalPatentsName(), '551900');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValonDispGainPatentsName(), '541100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValonDispLossPatentsName(), '541100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesonDispGainPatentsName(), '072100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesonDispLossPatentsName(), '072100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.MaintenanceExpensePatentsName(), '511100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcquisitionCostBalPatentsName(), '041100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.DepreciationExpensePatentsName(), '551400');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.DepreciationExpensePatents(), FixedAssetModuleCZ.DepreciationExpensePatentsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcqusitionCostBalonDisposalPatentsName(), '072100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.ApprecBalonDispPatentsName(), '072100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationonDisposalPatentsName(), '012100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationPatentsName(), '012100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationBalPatentsName(), '041100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesBalPatentsName(), '395100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValueBalonDisposalPatentsName(), '072100');

        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcquisitionCostSoftwareName(), '013100');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.AcquisitionCostSoftware(), FixedAssetModuleCZ.AcquisitionCostSoftwareName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AccumDepreciationSoftwareName(), '073100');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.AccumDepreciationSoftware(), FixedAssetModuleCZ.AccumDepreciationSoftwareName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.WriteDownSoftwareName(), '013100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.Custom2SoftwareName(), '041100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcqCostonDisposalSoftwareName(), '013100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AccumDepronDisposalSoftwareName(), '073100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.WriteDownonDisposalSoftwareName(), '013100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.Custom2onDisposalSoftwareName(), '041100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.GainsonDisposalSoftwareName(), '551900');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.LossesonDisposalSoftwareName(), '551900');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValonDispGainSoftwareName(), '541100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValonDispLossSoftwareName(), '541100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesonDispGainSoftwareName(), '073100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesonDispLossSoftwareName(), '073100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.MaintenanceExpenseSoftwareName(), '511100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcquisitionCostBalSoftwareName(), '041100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.DepreciationExpenseSoftwareName(), '551500');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.DepreciationExpenseSoftware(), FixedAssetModuleCZ.DepreciationExpenseSoftwareName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AcqusitionCostBalonDisposalSoftwareName(), '073100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.ApprecBalonDispSoftwareName(), '073100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationonDisposalSoftwareName(), '013100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationSoftwareName(), '013100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.AppreciationBalSoftwareName(), '041100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesBalSoftwareName(), '395100');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.BookValueBalonDisposalSoftwareName(), '073100');

        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.SalesFixedAssetsName(), '641100');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.SalesFixedAssets(), FixedAssetModuleCZ.SalesFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.AddAccountForLocalization(FixedAssetModuleCZ.ConsumableMaterialsName(), '501100');
        ContosoGLAccount.InsertGLAccount(FixedAssetModuleCZ.ConsumableMaterials(), FixedAssetModuleCZ.ConsumableMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create HR GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyHumanResourcesGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        HRGLAccount: Codeunit "Create HR GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(HRGLAccount.EmployeesPayableName(), '333100');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Job GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyJobGLAccounts()
    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        JobGLAccount: Codeunit "Create Job GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPInvoicedSalesName(), '121100');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPJobCostsName(), '121100');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobSalesAppliedName(), '602500');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedSalesName(), '602500');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobCostsAppliedName(), '581100');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedCostsName(), '581100');
    end;
}