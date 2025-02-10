codeunit 13721 "Create GL Acc. DK"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    local procedure AddGLAccountforDK()
    var
        GLAccountCategory: Record "G/L Account Category";
        ContosoGLAccountDK: Codeunit "Contoso GL Account DK";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreatePostingGroupsDK: Codeunit "Create Posting Groups DK";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        SubCategory: Text[80];
    begin
        SubCategory := Format(GLAccountCategoryMgt.GetCurrentAssets(), 80);
        ContosoGLAccountDK.InsertGLAccount(Totalcurrentassets(), TotalcurrentassetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.CurrentAssets() + '..' + Totalcurrentassets(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetCash(), 80);
        ContosoGLAccountDK.InsertGLAccount(Cashflowfunds(), CashflowfundsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Checkout(), CheckoutName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Bank(), BankName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Bankaccountcurrencies(), BankaccountcurrenciesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalcashflowfunds(), TotalcashflowfundsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, Cashflowfunds() + '..' + Totalcashflowfunds(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetAR(), 80);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.AccountsReceivable(), CreateGLAccount.AccountsReceivableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Deferred(), DeferredName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(PrepaymentsReceivables(), PrepaymentsReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Deposits(), DepositsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetInventory(), 80);
        ContosoGLAccountDK.InsertGLAccount(InventoryPosting(), InventoryPostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Inventoryadjustment(), InventoryadjustmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Itemreceived(), ItemreceivedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Itemshipped(), ItemshippedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalinventory(), TotalinventoryName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, InventoryBeginTotal() + '..' + Totalinventory(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Receivables(), ReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetFixedAssets(), 80);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.LandandBuildingsBeginTotal(), CreateGLAccount.LandandBuildingsBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AcquisitioncostLandBuildings(), AcquisitioncostLandBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AdditionFurniture(), AdditionFurnitureName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(OutputLandBuildings(), OutputLandBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AccdepreciationLandBuildings(), AccdepreciationLandBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CarsBeginTotal(), CarsBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AcquisitioncostCars(), AcquisitioncostCarsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AdditionLandBuildings(), AdditionLandBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(OutputCars(), OutputCarsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AccdepreciationOperating(), AccdepreciationOperatingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(VansBeginTotalAssets(), VansBeginTotalAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AcquisitioncostVans(), AcquisitioncostVansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AdditionCars(), AdditionCarsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(OutputVans(), OutputVansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AccdepreciationCars(), AccdepreciationCarsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.OperatingEquipmentBeginTotal(), CreateGLAccount.OperatingEquipmentBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AcquisitioncostOperatingEquipment(), AcquisitioncostOperatingEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AdditionVans(), AdditionVansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(OutputOperatingEquipments(), OutputOperatingEquipmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AccdepreciationVans(), AccdepreciationVansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(FurnitureequipmentBeginTotal(), FurnitureequipmentBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AcquisitioncostFurniture(), AcquisitioncostFurnitureName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AdditionOperatingEquipment(), AdditionOperatingEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(OutputFurniture(), OutputFurnitureName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AccdepreciationFurniture(), AccdepreciationFurnitureName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totaltangiblefixedassets(), TotaltangiblefixedassetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.TangibleFixedAssets() + '..' + Totaltangiblefixedassets(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetAccumDeprec(), 80);
        ContosoGLAccountDK.InsertGLAccount(DepreciationfortheyearLandBuildings(), DepreciationfortheyearLandBuilingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totallandandbuildings(), TotallandandbuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LandandBuildingsBeginTotal() + '..' + Totallandandbuildings(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(DepreciationfortheyearCars(), DepreciationfortheyearCarsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Carstotal(), CarstotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CarsBeginTotal() + '..' + Carstotal(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(DepreciationfortheyearVans(), DepreciationfortheyearVansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(VanstotalAssets(), VanstotalAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, VansBeginTotalAssets() + '..' + VanstotalAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(DepreciationfortheyearFurniture(), DepreciationfortheyearFurnitureName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totaloperatingequipment(), TotaloperatingequipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.OperatingEquipmentBeginTotal() + '..' + Totaloperatingequipment(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(DepreciationfortheyearOperating(), DepreciationfortheyearOperatingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalfurnitureequipment(), TotalfurnitureequipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, FurnitureequipmentBeginTotal() + '..' + Totalfurnitureequipment(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetCurrentLiabilities(), 80);
        ContosoGLAccountDK.InsertGLAccount(Debttofinancialinstitution(), DebttofinancialinstitutionName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.RevolvingCredit(), CreateGLAccount.RevolvingCreditName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totaldebttofinancialinstitution(), TotaldebttofinancialinstitutionName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, Debttofinancialinstitution() + '..' + Totaldebttofinancialinstitution(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Salestaxandothertaxes(), SalestaxandothertaxesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(SalestaxpayableSalesTax(), SalestaxpayableSalesTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(SalestaxreceivableInputTax(), SalestaxreceivableInputTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Salestaxonoverseaspurchases(), SalestaxonoverseaspurchasesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Euacquisitiontax(), EuacquisitiontaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Oiltax(), OiltaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.ElectricityTax(), CreateGLAccount.ElectricityTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.CO2Tax(), CreateGLAccount.CO2TaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.NaturalGasTax(), CreateGLAccount.NaturalGasTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.WaterTax(), CreateGLAccount.WaterTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Salestaxsettlementaccount(), SalestaxsettlementaccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalsalestax(), TotalsalestaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, Salestaxandothertaxes() + '..' + Totalsalestax(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AccountsPayableBeginTotal(), AccountsPayableBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AccountsPayablePosting(), AccountsPayablePostingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Accruedtax(), AccruedtaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Additionalcosts(), AdditionalcostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(PrepaymentsAccountsPayable(), PrepaymentsAccountsPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalshorttermliabilities(), TotalshorttermliabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, AccountsPayableBeginTotal() + '..' + Totalshorttermliabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalaccountspayable(), TotalaccountspayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', CreatePostingGroup.RetailPostingGroup(), 0, CreateGLAccount.SHORTTERMLIABILITIES() + '..' + Totalaccountspayable(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(AccruedcostsBeginTotal(), AccruedcostsBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Accruedcosts(), AccruedcostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Deferrals(), DeferralsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(PrepaymentsAccruedCosts(), PrepaymentsAccruedCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalaccruedcosts(), TotalaccruedcostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', CreatePostingGroup.RetailPostingGroup(), 0, AccruedcostsBeginTotal() + '..' + Totalaccruedcosts(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(PayrollliabilitiesBeginTotal(), PayrollliabilitiesBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.TotalLiabilitiesAndEquity(), CreateGLAccount.TotalLiabilitiesAndEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LiabilitiesAndEquity() + '..' + CreateGLAccount.TotalLiabilitiesAndEquity(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.WithholdingTaxesPayable(), CreateGLAccount.WithholdingTaxesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.PayrollTaxesPayable(), CreateGLAccount.PayrollTaxesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Labormarketcontributionpayable(), LabormarketcontributionpayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Retirementplancontributionspayable(), RetirementplancontributionspayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Payrollliabilities(), PayrollliabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalpayrollliabilities(), TotalpayrollliabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, PayrollliabilitiesBeginTotal() + '..' + Totalpayrollliabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetPayrollLiabilities(), 80);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.VacationCompensationPayable(), CreateGLAccount.VacationCompensationPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetLongTermLiabilities(), 80);
        ContosoGLAccountDK.InsertGLAccount(Mortgagedebt(), MortgagedebtName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Bankdebt(), BankdebtName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.ShorttermLiabilities(), CreateGLAccount.ShorttermLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totallongtermliabilities(), TotallongtermliabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LONGTERMLIABILITIES() + '..' + Totallongtermliabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategory."Account Category"::Equity, 80);
        ContosoGLAccountDK.InsertGLAccount(Openingequity(), OpeningequityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Paidbtaxeslabormarketcontribution(), PaidbtaxeslabormarketcontributionName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Privatephoneusage(), PrivatephoneusageName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Withdrawalforpersonaluse(), WithdrawalforpersonaluseName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalprivatewithdrawals(), TotalprivatewithdrawalsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"End-Total", '', '', 0, Privatewithdrawalsetc() + '..' + Totalprivatewithdrawals(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Equityatendofyear(), EquityatendofyearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"End-Total", '', '', 0, Equity() + '..' + Equityatendofyear(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.LongtermLiabilities(), CreateGLAccount.LongtermLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetCommonStock(), 80);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.CapitalStock(), CreateGLAccount.CapitalStockName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Retainedearningsfortheyear(), RetainedearningsfortheyearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetRetEarnings(), 80);
        ContosoGLAccountDK.InsertGLAccount(Privatewithdrawalsetc(), PrivatewithdrawalsetcName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategory."Account Category"::Income, 80);
        ContosoGLAccountDK.InsertGLAccount(Profitandlossstatement(), ProfitandlossstatementName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Heading, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Domesticsalesofgoodsandservices(), DomesticsalesofgoodsandservicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Eusalesofgoodsandservices(), EusalesofgoodsandservicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Salesofgoodsandservicestoothercountries(), SalesofgoodsandservicestoothercountriesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(FreightIncome(), FreightIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.FreightPostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Onaccountinvoicing(), OnaccountinvoicingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Chargeexsalestax(), ChargeexsalestaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroupsDK.ServicePostingGroup(), 0, '', Enum::"General Posting Type"::"Sale", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Chargeinclsalestax(), ChargeinclsalestaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.Revenue(), CreateGLAccount.RevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.TotalRevenue(), CreateGLAccount.TotalRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Revenue() + '..' + CreateGLAccount.TotalRevenue(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Operatingincome(), OperatingincomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totaloperatingincome(), TotaloperatingincomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::"End-Total", '', '', 0, Operatingincome() + '..' + Totaloperatingincome(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetIncomeSalesDiscounts(), 80);
        ContosoGLAccountDK.InsertGLAccount(Discountsgranted(), DiscountsgrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetIncomeInterest(), 80);
        ContosoGLAccountDK.InsertGLAccount(BankinterestFinancalExpesnse(), BankinterestFinancalExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Accountsreceivableinterest(), AccountsreceivableinterestName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Income", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategory."Account Category"::"Cost of Goods Sold", 80);
        ContosoGLAccountDK.InsertGLAccount(CostofGoodSoldBeginTotal(), CostofGoodsSoldBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Costofgoodssold(), CostofgoodssoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Itempurchases(), ItempurchasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Miscconsumption(), MiscconsumptionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Foreignlabor(), ForeignlaborName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(FreightCostOfGoods(), FreightCostOfGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Profitlossinventory(), ProfitlossinventoryName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Chargebeforesalestax(), ChargebeforesalestaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Chargeaftersalestax(), ChargeaftersalestaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Discountsreceived(), DiscountsreceivedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Purchasevariance(), PurchasevarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalcostofgoodssold(), TotalcostofgoodssoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, CostofGoodSoldBeginTotal() + '..' + Totalcostofgoodssold(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetCOGSDiscountsGranted(), 80);
        ContosoGLAccountDK.InsertGLAccount(Iteminventoryadjustment(), IteminventoryadjustmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetJobsCost(), 80);
        ContosoGLAccountDK.InsertGLAccount(Projectcosts(), ProjectcostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Travelfee(), TravelfeeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Materialcosts(), MaterialcostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Projecthours(), ProjecthoursName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Adjustmentofwip(), AdjustmentofwipName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalprojectcosts(), TotalprojectcostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::"End-Total", '', '', 0, Projectcosts() + '..' + Totalprojectcosts(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetRentExpense(), 80);
        ContosoGLAccountDK.InsertGLAccount(Rent(), RentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(MachineryRentalLeasingFee(), MachineryRentalLeasingFeeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetAdvertisingExpense(), 80);
        ContosoGLAccountDK.InsertGLAccount(Advertisementsandcommercials(), AdvertisementsandcommercialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetInterestExpense(), 80);
        ContosoGLAccountDK.InsertGLAccount(BankinterestFinancalItems(), BankinterestFinancalItemsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Accountspayableinterest(), AccountspayableinterestName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Additionalinterestexpenses(), AdditionalinterestexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Disallowedinterestdeductions(), DisallowedinterestdeductionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetInsuranceExpense(), 80);
        ContosoGLAccountDK.InsertGLAccount(InsuranceAutoMobile(), InsuranceAutoMobileName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(InsurancesVans(), InsurancesVansName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetPayrollExpense(), 80);
        ContosoGLAccountDK.InsertGLAccount(Personnelcosts(), PersonnelcostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Salariesvacationcompensation(), SalariesvacationcompensationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Salariesproduction(), SalariesproductionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Directorsfee(), DirectorsfeeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Anniversarygift(), AnniversarygiftName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Severancepay(), SeverancepayName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Pensioncompany(), PensioncompanyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Labormarketpensioncompany(), LabormarketpensioncompanyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Optionalpayaccountsavings(), OptionalpayaccountsavingsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Employeeartclub(), EmployeeartclubName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Giftfund(), GiftfundName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Lunch(), LunchName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Damaternitypaternityleavepremium(), DamaternitypaternityleavepremiumName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Atpemployee(), AtpemployeeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Mileagerate(), MileagerateName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Refunds(), RefundsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Atpemployer(), AtpemployerName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Projecthoursspent(), ProjecthoursspentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Projecthoursallocatedtooperatingresult(), ProjecthoursallocatedtooperatingresultName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Consumptionforownproduction(), ConsumptionforownproductionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Socialsecbenefitsalloctooperatingresult(), SocialsecbenefitsalloctooperatingresultName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Transferredssbstoproduction(), TransferredssbstoproductionName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Trainingexpenses(), TrainingexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Otherpersonnelcosts(), OtherpersonnelcostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalpersonnelcosts(), TotalpersonnelcostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Personnelcosts() + '..' + Totalpersonnelcosts(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetRepairsExpense(), 80);
        ContosoGLAccountDK.InsertGLAccount(Decoration(), DecorationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.Cleaning(), CreateGLAccount.CleaningName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.RepairsandMaintenance(), CreateGLAccount.RepairsandMaintenanceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetUtilitiesExpense(), 80);
        ContosoGLAccountDK.InsertGLAccount(Electricity(), ElectricityName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Water(), WaterName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Heating(), HeatingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Naturalgas(), NaturalgasName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetTaxExpense(), 80);
        ContosoGLAccountDK.InsertGLAccount(Taxes(), TaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetTravelExpense(), 80);
        ContosoGLAccountDK.InsertGLAccount(Travelingtradefairsetc(), TravelingtradefairsetcName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetVehicleExpenses(), 80);
        ContosoGLAccountDK.InsertGLAccount(Automobileoperationscars(), AutomobileoperationscarsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(RentalLeasingFeeMachine(), RentalLeasingFeeMachineName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(GasVans(), GasVansName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(GasconsumptiontaxVans(), GasconsumptiontaxVansName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(RepmaintenanceVans(), RepmaintenanceVansName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(FerryticketsbridgetollsAutoMobile(), FerryticketsbridgetollsAutoMobileName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalvehicleoperations(), TotalvehicleoperationsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Automobileoperationscars() + '..' + Automobileoperationscars(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(RentalLeasingFeeAutoMobile(), RentalLeasingFeeAutoMobileName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(GasAutoMobile(), GasAutoMobileName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(GasconsumptiontaxAutoMobile(), GasconsumptiontaxAutoMobileName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(RepmaintenanceAutoMobile(), RepmaintenanceAutoMobileName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(FerryticketsbridgetollsVans(), FerryticketsbridgetollsVansName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(VanstotalExpense(), VanstotalExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, VansBeginTotalExpense() + '..' + VanstotalExpense(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Machines(), MachinesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(RentalLeasingFeeVans(), RentalLeasingFeeVansName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Machineoperatingcosts(), MachineoperatingcostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Machrepairsandmaintenance(), MachrepairsandmaintenanceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Machineryinsurance(), MachineryinsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Machinestotal(), MachinestotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Machines() + '..' + Machinestotal(), Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(InsurancesAdminCost(), InsurancesAdminCostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(InsuranceCostOfWorkSpace(), InsuranceCostOfWorkSpaceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(VansBeginTotalExpense(), VansBeginTotalExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategoryMgt.GetOtherIncomeExpense(), 80);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.UnrealizedFXGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.RealizedFXGains(), CreateGLAccount.RealizedFXGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Accountspayablecharges(), AccountspayablechargesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Centdiscrepancies(), CentdiscrepanciesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.UnrealizedFXLosses(), CreateGLAccount.UnrealizedFXLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.RealizedFXLosses(), CreateGLAccount.RealizedFXLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategory."Account Category"::Expense, 80);
        ContosoGLAccountDK.InsertGLAccount(Marketingcosts(), MarketingcostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Entwinetobaccospirits(), EntwinetobaccospiritsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Entgiftsandflowers(), EntgiftsandflowersName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Restaurantdining(), RestaurantdiningName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalmarketingcosts(), TotalmarketingcostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Marketingcosts() + '..' + Totalmarketingcosts(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Marketingcontributions(), MarketingcontributionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Costofofficeworkshopspace(), CostofofficeworkshopspaceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);

        ContosoGLAccountDK.InsertGLAccount(Newacquisitions(), NewacquisitionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalcostofofficeworkshopspace(), TotalcostofofficeworkshopspaceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Costofofficeworkshopspace() + '..' + Totalcostofofficeworkshopspace(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Administrativecosts(), AdministrativecostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Phonescellphones(), PhonescellphonesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Internetwebsite(), InternetwebsiteName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Newspapersmagazines(), NewspapersmagazinesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Subscriptionsmembershipfees(), SubscriptionsmembershipfeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Officestationary(), OfficestationaryName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Postagefees(), PostagefeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ZeroPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Minoracquisitions(), MinoracquisitionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Conferenceexpenses(), ConferenceexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Accountingcosts(), AccountingcostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Auditingaccountingassistance(), AuditingaccountingassistanceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Lawyer(), LawyerName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Legalaid(), LegalaidName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Repairsandmaintenancefurnitureequipment(), RepairsandmaintenancefurnitureequipmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Itexpenses(), ItexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Salarycosts(), SalarycostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(FreightExpense(), FreightExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Charges(), ChargesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::"Purchase", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totaladministrativecosts(), TotaladministrativecostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Administrativecosts() + '..' + Totaladministrativecosts(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalcosts(), TotalcostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Total, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Resbeforedepreciation(), ResbeforedepreciationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Total, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(DepreciationBeginTotal(), DepreciationBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.LandandBuildings(), CreateGLAccount.LandandBuildingsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.OperatingEquipment(), CreateGLAccount.OperatingEquipmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Vans(), VansName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Cars(), CarsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Furnitureequipment(), FurnitureequipmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Goodwill(), GoodwillName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totaldepreciation(), TotaldepreciationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, DepreciationBeginTotal() + '..' + Totaldepreciation(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Financialexpenses(), FinancialexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalfinancialexpenses(), TotalfinancialexpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, Financialexpenses() + '..' + Totalfinancialexpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(TaxesBeginTotal(), TaxesBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totaltaxes(), TotaltaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::"End-Total", '', '', 0, TaxesBeginTotal() + '..' + Totaltaxes(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(TaxesCostOfWorkSpace(), TaxesCostOfWorkSpaceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.CashDiscrepancies(), CreateGLAccount.CashDiscrepanciesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.FixedAssets(), CreateGLAccount.FixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(GoodwillBeginTotal(), GoodwillBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Openingbalance(), OpeningbalanceName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Depreciation(), DepreciationName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalgoodwill(), TotalgoodwillName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, GoodwillBeginTotal() + '..' + Totalgoodwill(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalintangiblefixedassets(), TotalintangiblefixedassetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.FixedAssets() + '..' + Totalintangiblefixedassets(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Financialfixedassets(), FinancialfixedassetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.Securities(), CreateGLAccount.SecuritiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Commonstock(), CommonstockName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.Bonds(), CreateGLAccount.BondsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalsecurities(), TotalsecuritiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Securities() + '..' + Totalsecurities(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalfinancialfixedassets(), TotalfinancialfixedassetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, Financialfixedassets() + '..' + Totalfinancialfixedassets(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.TangibleFixedAssets(), CreateGLAccount.TangibleFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.CurrentAssets(), CreateGLAccount.CurrentAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(InventoryBeginTotal(), InventoryBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Depositstenancy(), DepositstenancyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totaldeposits(), TotaldepositsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, Deposits() + '..' + Totaldeposits(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(WorkinprocessBeginTotal(), WorkinprocessBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Workinprocess(), WorkinprocessName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Invoicedonaccount(), InvoicedonaccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalworkinprocess(), TotalworkinprocessName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, WorkinprocessBeginTotal() + '..' + Totalworkinprocess(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Totalreceivables(), TotalreceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, Receivables() + '..' + Totalreceivables(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.TotalAssets(), CreateGLAccount.TotalAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Assets() + '..' + CreateGLAccount.TOTALASSETS(), Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.LiabilitiesAndEquity(), CreateGLAccount.LiabilitiesAndEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);

        SubCategory := Format(GLAccountCategory."Account Category"::Liabilities, 80);
        ContosoGLAccountDK.InsertGLAccount(Allnull(), AllnullName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Total, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false, 0, SubCategory);

        SubCategory := '';
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.JobSales(), CreateGLAccount.JobSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 2, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.JobCosts(), CreateGLAccount.JobCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 1, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.WIPJobSales(), CreateGLAccount.WIPJobSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 1, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.InvoicedJobSales(), CreateGLAccount.InvoicedJobSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 1, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.AccruedJobCosts(), CreateGLAccount.AccruedJobCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 1, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(CreateGLAccount.WIPJobCosts(), CreateGLAccount.WIPJobCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 1, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Jobsalesapplied(), JobsalesappliedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 1, SubCategory);
        ContosoGLAccountDK.InsertGLAccount(Jobcostsapplied(), JobcostsappliedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false, 2, SubCategory);

        ContosoGLAccount.InsertGLAccount(Equity(), EquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, '', Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Assets(), CreateGLAccount.AssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, '', Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Resbeforefinancialitems(), ResbeforefinancialitemsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Financialitems(), FinancialitemsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Totalfinancialitems(), TotalfinancialitemsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::"End-Total", '', '', 0, Financialitems() + '..' + Totalfinancialitems(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Resultbeforetax(), ResultbeforetaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Periodearnings(), PeriodearningsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Balance(), BalanceName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Heading, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccountforDK()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ModifyGLAccountForW1();
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevenueName(), '01000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesName(), '01880');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalRevenueName(), '01997');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostsName(), '02980');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalariesName(), '03010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationName(), '03020');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceName(), '05020');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CleaningName(), '05030');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashDiscrepanciesName(), '05740');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsName(), '06100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentName(), '06200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFXGainsName(), '07310');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFXGainsName(), '07330');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageInterestName(), '07550');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFXLossesName(), '07720');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFXLossesName(), '07740');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AssetsName(), '10100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsName(), '10200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesName(), '10850');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BondsName(), '10870');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsName(), '11000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsBeginTotalName(), '12000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentBeginTotalName(), '13700');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsName(), '16000');
        ContosoGLAccount.AddAccountForLocalization(InventoryBeginTotalName(), '16100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsName(), '16300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsName(), '16400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableName(), '17100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherReceivablesName(), '17200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobSalesName(), '17810');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoicedJobSalesName(), '17820');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedJobCostsName(), '17830');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobCostsName(), '17840');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TOTALASSETSName(), '19999');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesAndEquityName(), '20000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CapitalStockName(), '20300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LONGTERMLIABILITIESName(), '21000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SHORTTERMLIABILITIESName(), '22000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevolvingCreditName(), '23100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityTaxName(), '24220');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CO2TaxName(), '24230');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NaturalGasTaxName(), '24240');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WaterTaxName(), '24250');
        ContosoGLAccount.AddAccountForLocalization(AccountsPayableBeginTotalName(), '25000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WithholdingTaxesPayableName(), '27100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesPayableName(), '27300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationPayableName(), '27600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesAndEquityName(), '29997');
        ContosoGLAccount.AddAccountForLocalization(ProfitandlossstatementName(), '00001');
        ContosoGLAccount.AddAccountForLocalization(DomesticsalesofgoodsandservicesName(), '01010');
        ContosoGLAccount.AddAccountForLocalization(EusalesofgoodsandservicesName(), '01020');
        ContosoGLAccount.AddAccountForLocalization(SalesofgoodsandservicestoothercountriesName(), '01030');
        ContosoGLAccount.AddAccountForLocalization(FreightIncomeName(), '01200');
        ContosoGLAccount.AddAccountForLocalization(OnaccountinvoicingName(), '01500');
        ContosoGLAccount.AddAccountForLocalization(ChargeexsalestaxName(), '01600');
        ContosoGLAccount.AddAccountForLocalization(ChargeinclsalestaxName(), '01610');
        ContosoGLAccount.AddAccountForLocalization(DiscountsgrantedName(), '01700');
        ContosoGLAccount.AddAccountForLocalization(JobsalesappliedName(), '01890');
        ContosoGLAccount.AddAccountForLocalization(CostofGoodsSoldBeginTotalName(), '02000');
        ContosoGLAccount.AddAccountForLocalization(CostofgoodssoldName(), '02010');
        ContosoGLAccount.AddAccountForLocalization(ItempurchasesName(), '02020');
        ContosoGLAccount.AddAccountForLocalization(MiscconsumptionName(), '02030');
        ContosoGLAccount.AddAccountForLocalization(ForeignlaborName(), '02100');
        ContosoGLAccount.AddAccountForLocalization(FreightCostOfGoodsName(), '02200');
        ContosoGLAccount.AddAccountForLocalization(ProfitlossinventoryName(), '02300');
        ContosoGLAccount.AddAccountForLocalization(ChargebeforesalestaxName(), '02600');
        ContosoGLAccount.AddAccountForLocalization(ChargeaftersalestaxName(), '02610');
        ContosoGLAccount.AddAccountForLocalization(DiscountsreceivedName(), '02700');
        ContosoGLAccount.AddAccountForLocalization(IteminventoryadjustmentName(), '02800');
        ContosoGLAccount.AddAccountForLocalization(PurchasevarianceName(), '02820');
        ContosoGLAccount.AddAccountForLocalization(TotalcostofgoodssoldName(), '02897');
        ContosoGLAccount.AddAccountForLocalization(ProjectcostsName(), '02900');
        ContosoGLAccount.AddAccountForLocalization(TravelfeeName(), '02910');
        ContosoGLAccount.AddAccountForLocalization(MaterialcostsName(), '02920');
        ContosoGLAccount.AddAccountForLocalization(ProjecthoursName(), '02930');
        ContosoGLAccount.AddAccountForLocalization(AdjustmentofwipName(), '02950');
        ContosoGLAccount.AddAccountForLocalization(JobcostsappliedName(), '02990');
        ContosoGLAccount.AddAccountForLocalization(TotalprojectcostsName(), '02997');
        ContosoGLAccount.AddAccountForLocalization(PersonnelcostsName(), '03000');
        ContosoGLAccount.AddAccountForLocalization(SalariesvacationcompensationName(), '03040');
        ContosoGLAccount.AddAccountForLocalization(SalariesproductionName(), '03050');
        ContosoGLAccount.AddAccountForLocalization(DirectorsfeeName(), '03060');
        ContosoGLAccount.AddAccountForLocalization(AnniversarygiftName(), '03070');
        ContosoGLAccount.AddAccountForLocalization(SeverancepayName(), '03080');
        ContosoGLAccount.AddAccountForLocalization(PensioncompanyName(), '03090');
        ContosoGLAccount.AddAccountForLocalization(LabormarketpensioncompanyName(), '03100');
        ContosoGLAccount.AddAccountForLocalization(OptionalpayaccountsavingsName(), '03120');
        ContosoGLAccount.AddAccountForLocalization(EmployeeartclubName(), '03130');
        ContosoGLAccount.AddAccountForLocalization(GiftfundName(), '03140');
        ContosoGLAccount.AddAccountForLocalization(LunchName(), '03150');
        ContosoGLAccount.AddAccountForLocalization(DamaternitypaternityleavepremiumName(), '03160');
        ContosoGLAccount.AddAccountForLocalization(AtpemployeeName(), '03170');
        ContosoGLAccount.AddAccountForLocalization(MileagerateName(), '03180');
        ContosoGLAccount.AddAccountForLocalization(RefundsName(), '03190');
        ContosoGLAccount.AddAccountForLocalization(AtpemployerName(), '03200');
        ContosoGLAccount.AddAccountForLocalization(ProjecthoursspentName(), '03210');
        ContosoGLAccount.AddAccountForLocalization(ProjecthoursallocatedtooperatingresultName(), '03220');
        ContosoGLAccount.AddAccountForLocalization(ConsumptionforownproductionName(), '03230');
        ContosoGLAccount.AddAccountForLocalization(SocialsecbenefitsalloctooperatingresultName(), '03240');
        ContosoGLAccount.AddAccountForLocalization(TransferredssbstoproductionName(), '03250');
        ContosoGLAccount.AddAccountForLocalization(TrainingexpensesName(), '03260');
        ContosoGLAccount.AddAccountForLocalization(OtherpersonnelcostsName(), '03270');
        ContosoGLAccount.AddAccountForLocalization(TotalpersonnelcostsName(), '03297');
        ContosoGLAccount.AddAccountForLocalization(MarketingcostsName(), '03600');
        ContosoGLAccount.AddAccountForLocalization(AdvertisementsandcommercialsName(), '03610');
        ContosoGLAccount.AddAccountForLocalization(EntwinetobaccospiritsName(), '03630');
        ContosoGLAccount.AddAccountForLocalization(EntgiftsandflowersName(), '03640');
        ContosoGLAccount.AddAccountForLocalization(TravelingtradefairsetcName(), '03650');
        ContosoGLAccount.AddAccountForLocalization(RestaurantdiningName(), '03660');
        ContosoGLAccount.AddAccountForLocalization(DecorationName(), '03670');
        ContosoGLAccount.AddAccountForLocalization(TotalmarketingcostsName(), '03997');
        ContosoGLAccount.AddAccountForLocalization(MarketingcontributionsName(), '03999');
        ContosoGLAccount.AddAccountForLocalization(AutomobileoperationscarsName(), '04000');
        ContosoGLAccount.AddAccountForLocalization(RentalLeasingFeeMachineName(), '04010');
        ContosoGLAccount.AddAccountForLocalization(GasVansName(), '04020');
        ContosoGLAccount.AddAccountForLocalization(InsuranceCostOfWorkSpaceName(), '04030');
        ContosoGLAccount.AddAccountForLocalization(GasconsumptiontaxVansName(), '04040');
        ContosoGLAccount.AddAccountForLocalization(RepmaintenanceVansName(), '04050');
        ContosoGLAccount.AddAccountForLocalization(FerryticketsbridgetollsAutoMobileName(), '04060');
        ContosoGLAccount.AddAccountForLocalization(TotalvehicleoperationsName(), '04097');
        ContosoGLAccount.AddAccountForLocalization(VansBeginTotalExpenseName(), '04200');
        ContosoGLAccount.AddAccountForLocalization(RentalLeasingFeeAutoMobileName(), '04210');
        ContosoGLAccount.AddAccountForLocalization(GasAutoMobileName(), '04220');
        ContosoGLAccount.AddAccountForLocalization(GasconsumptiontaxAutoMobileName(), '04230');
        ContosoGLAccount.AddAccountForLocalization(InsurancesAdminCostName(), '04240');
        ContosoGLAccount.AddAccountForLocalization(RepmaintenanceAutoMobileName(), '04250');
        ContosoGLAccount.AddAccountForLocalization(FerryticketsbridgetollsVansName(), '04260');
        ContosoGLAccount.AddAccountForLocalization(VanstotalExpenseName(), '04297');
        ContosoGLAccount.AddAccountForLocalization(MachinesName(), '04400');
        ContosoGLAccount.AddAccountForLocalization(RentalLeasingFeeVansName(), '04410');
        ContosoGLAccount.AddAccountForLocalization(MachineoperatingcostsName(), '04420');
        ContosoGLAccount.AddAccountForLocalization(MachrepairsandmaintenanceName(), '04430');
        ContosoGLAccount.AddAccountForLocalization(MachineryinsuranceName(), '04440');
        ContosoGLAccount.AddAccountForLocalization(MachinestotalName(), '04997');
        ContosoGLAccount.AddAccountForLocalization(CostofofficeworkshopspaceName(), '05000');
        ContosoGLAccount.AddAccountForLocalization(RentName(), '05010');
        ContosoGLAccount.AddAccountForLocalization(InsuranceAutoMobileName(), '05040');
        ContosoGLAccount.AddAccountForLocalization(ElectricityName(), '05110');
        ContosoGLAccount.AddAccountForLocalization(WaterName(), '05120');
        ContosoGLAccount.AddAccountForLocalization(HeatingName(), '05130');
        ContosoGLAccount.AddAccountForLocalization(NaturalgasName(), '05140');
        ContosoGLAccount.AddAccountForLocalization(TaxesCostOfWorkSpaceName(), '05150');
        ContosoGLAccount.AddAccountForLocalization(NewacquisitionsName(), '05200');
        ContosoGLAccount.AddAccountForLocalization(TotalcostofofficeworkshopspaceName(), '05297');
        ContosoGLAccount.AddAccountForLocalization(AdministrativecostsName(), '05600');
        ContosoGLAccount.AddAccountForLocalization(PhonescellphonesName(), '05610');
        ContosoGLAccount.AddAccountForLocalization(InternetwebsiteName(), '05620');
        ContosoGLAccount.AddAccountForLocalization(NewspapersmagazinesName(), '05630');
        ContosoGLAccount.AddAccountForLocalization(SubscriptionsmembershipfeesName(), '05640');
        ContosoGLAccount.AddAccountForLocalization(OfficestationaryName(), '05650');
        ContosoGLAccount.AddAccountForLocalization(PostagefeesName(), '05660');
        ContosoGLAccount.AddAccountForLocalization(InsurancesVansName(), '05670');
        ContosoGLAccount.AddAccountForLocalization(MinoracquisitionsName(), '05680');
        ContosoGLAccount.AddAccountForLocalization(ConferenceexpensesName(), '05690');
        ContosoGLAccount.AddAccountForLocalization(AccountingcostsName(), '05720');
        ContosoGLAccount.AddAccountForLocalization(AuditingaccountingassistanceName(), '05730');
        ContosoGLAccount.AddAccountForLocalization(LawyerName(), '05750');
        ContosoGLAccount.AddAccountForLocalization(LegalaidName(), '05760');
        ContosoGLAccount.AddAccountForLocalization(RepairsandmaintenancefurnitureequipmentName(), '05800');
        ContosoGLAccount.AddAccountForLocalization(ItexpensesName(), '05810');
        ContosoGLAccount.AddAccountForLocalization(SalarycostsName(), '05820');
        ContosoGLAccount.AddAccountForLocalization(FreightExpenseName(), '05830');
        ContosoGLAccount.AddAccountForLocalization(ChargesName(), '05840');
        ContosoGLAccount.AddAccountForLocalization(MachineryRentalLeasingFeeName(), '05850');
        ContosoGLAccount.AddAccountForLocalization(TotaladministrativecostsName(), '05997');
        ContosoGLAccount.AddAccountForLocalization(TotalcostsName(), '05998');
        ContosoGLAccount.AddAccountForLocalization(ResbeforedepreciationName(), '05999');
        ContosoGLAccount.AddAccountForLocalization(DepreciationBeginTotalName(), '06000');
        ContosoGLAccount.AddAccountForLocalization(VansName(), '06300');
        ContosoGLAccount.AddAccountForLocalization(CarsName(), '06400');
        ContosoGLAccount.AddAccountForLocalization(FurnitureequipmentName(), '06500');
        ContosoGLAccount.AddAccountForLocalization(GoodwillName(), '06900');
        ContosoGLAccount.AddAccountForLocalization(TotaldepreciationName(), '06997');
        ContosoGLAccount.AddAccountForLocalization(ResbeforefinancialitemsName(), '06999');
        ContosoGLAccount.AddAccountForLocalization(FinancialitemsName(), '07000');
        ContosoGLAccount.AddAccountForLocalization(OperatingincomeName(), '07100');
        ContosoGLAccount.AddAccountForLocalization(BankinterestFinancalExpenseName(), '07110');
        ContosoGLAccount.AddAccountForLocalization(AccountsreceivableinterestName(), '07120');
        ContosoGLAccount.AddAccountForLocalization(TotaloperatingincomeName(), '07497');
        ContosoGLAccount.AddAccountForLocalization(FinancialexpensesName(), '07500');
        ContosoGLAccount.AddAccountForLocalization(BankinterestFinancalItemsName(), '07510');
        ContosoGLAccount.AddAccountForLocalization(AccountspayableinterestName(), '07520');
        ContosoGLAccount.AddAccountForLocalization(AccountspayablechargesName(), '07530');
        ContosoGLAccount.AddAccountForLocalization(AdditionalinterestexpensesName(), '07540');
        ContosoGLAccount.AddAccountForLocalization(CentdiscrepanciesName(), '07570');
        ContosoGLAccount.AddAccountForLocalization(DisallowedinterestdeductionsName(), '07580');
        ContosoGLAccount.AddAccountForLocalization(TotalfinancialexpensesName(), '07997');
        ContosoGLAccount.AddAccountForLocalization(TotalfinancialitemsName(), '07998');
        ContosoGLAccount.AddAccountForLocalization(ResultbeforetaxName(), '07999');
        ContosoGLAccount.AddAccountForLocalization(TaxesBeginTotalName(), '09000');
        ContosoGLAccount.AddAccountForLocalization(TaxesName(), '09100');
        ContosoGLAccount.AddAccountForLocalization(TotaltaxesName(), '09997');
        ContosoGLAccount.AddAccountForLocalization(PeriodearningsName(), '09999');
        ContosoGLAccount.AddAccountForLocalization(BalanceName(), '10000');
        ContosoGLAccount.AddAccountForLocalization(GoodwillBeginTotalName(), '10500');
        ContosoGLAccount.AddAccountForLocalization(OpeningbalanceName(), '10510');
        ContosoGLAccount.AddAccountForLocalization(DepreciationName(), '10520');
        ContosoGLAccount.AddAccountForLocalization(TotalgoodwillName(), '10597');
        ContosoGLAccount.AddAccountForLocalization(TotalintangiblefixedassetsName(), '10699');
        ContosoGLAccount.AddAccountForLocalization(FinancialfixedassetsName(), '10800');
        ContosoGLAccount.AddAccountForLocalization(CommonstockName(), '10860');
        ContosoGLAccount.AddAccountForLocalization(TotalsecuritiesName(), '10998');
        ContosoGLAccount.AddAccountForLocalization(TotalfinancialfixedassetsName(), '10999');
        ContosoGLAccount.AddAccountForLocalization(AcquisitioncostLandBuildingsName(), '12100');
        ContosoGLAccount.AddAccountForLocalization(AdditionFurnitureName(), '12200');
        ContosoGLAccount.AddAccountForLocalization(OutputLandBuildingsName(), '12300');
        ContosoGLAccount.AddAccountForLocalization(AccdepreciationLandBuildingsName(), '12400');
        ContosoGLAccount.AddAccountForLocalization(DepreciationfortheyearLandBuilingsName(), '12500');
        ContosoGLAccount.AddAccountForLocalization(TotallandandbuildingsName(), '12997');
        ContosoGLAccount.AddAccountForLocalization(CarsBeginTotalName(), '13000');
        ContosoGLAccount.AddAccountForLocalization(AcquisitioncostCarsName(), '13010');
        ContosoGLAccount.AddAccountForLocalization(AdditionLandBuildingsName(), '13020');
        ContosoGLAccount.AddAccountForLocalization(OutputCarsName(), '13030');
        ContosoGLAccount.AddAccountForLocalization(AccdepreciationOperatingName(), '13050');
        ContosoGLAccount.AddAccountForLocalization(DepreciationfortheyearCarsName(), '13060');
        ContosoGLAccount.AddAccountForLocalization(CarstotalName(), '13297');
        ContosoGLAccount.AddAccountForLocalization(VansBeginTotalAssetsName(), '13400');
        ContosoGLAccount.AddAccountForLocalization(AcquisitioncostVansName(), '13410');
        ContosoGLAccount.AddAccountForLocalization(AdditionCarsName(), '13420');
        ContosoGLAccount.AddAccountForLocalization(OutputVansName(), '13430');
        ContosoGLAccount.AddAccountForLocalization(AccdepreciationCarsName(), '13440');
        ContosoGLAccount.AddAccountForLocalization(DepreciationfortheyearVansName(), '13450');
        ContosoGLAccount.AddAccountForLocalization(VanstotalAssetsName(), '13597');
        ContosoGLAccount.AddAccountForLocalization(AcquisitioncostOperatingEquipmentName(), '13710');
        ContosoGLAccount.AddAccountForLocalization(AdditionVansName(), '13720');
        ContosoGLAccount.AddAccountForLocalization(OutputOperatingEquipmentsName(), '13730');
        ContosoGLAccount.AddAccountForLocalization(AccdepreciationVansName(), '13740');
        ContosoGLAccount.AddAccountForLocalization(DepreciationfortheyearFurnitureName(), '13750');
        ContosoGLAccount.AddAccountForLocalization(TotaloperatingequipmentName(), '13997');
        ContosoGLAccount.AddAccountForLocalization(FurnitureequipmentBeginTotalName(), '14000');
        ContosoGLAccount.AddAccountForLocalization(AcquisitioncostFurnitureName(), '14100');
        ContosoGLAccount.AddAccountForLocalization(AdditionOperatingEquipmentName(), '14200');
        ContosoGLAccount.AddAccountForLocalization(OutputFurnitureName(), '14300');
        ContosoGLAccount.AddAccountForLocalization(AccdepreciationFurnitureName(), '14400');
        ContosoGLAccount.AddAccountForLocalization(DepreciationfortheyearOperatingName(), '14500');
        ContosoGLAccount.AddAccountForLocalization(TotalfurnitureequipmentName(), '14997');
        ContosoGLAccount.AddAccountForLocalization(TotaltangiblefixedassetsName(), '15998');
        ContosoGLAccount.AddAccountForLocalization(InventoryPostingName(), '16200');
        ContosoGLAccount.AddAccountForLocalization(InventoryadjustmentName(), '16500');
        ContosoGLAccount.AddAccountForLocalization(ItemreceivedName(), '16600');
        ContosoGLAccount.AddAccountForLocalization(ItemshippedName(), '16700');
        ContosoGLAccount.AddAccountForLocalization(TotalinventoryName(), '16997');
        ContosoGLAccount.AddAccountForLocalization(ReceivablesName(), '17000');
        ContosoGLAccount.AddAccountForLocalization(DeferredName(), '17300');
        ContosoGLAccount.AddAccountForLocalization(PrepaymentsReceivablesName(), '17400');
        ContosoGLAccount.AddAccountForLocalization(DepositsName(), '17500');
        ContosoGLAccount.AddAccountForLocalization(DepositstenancyName(), '17510');
        ContosoGLAccount.AddAccountForLocalization(TotaldepositsName(), '17597');
        ContosoGLAccount.AddAccountForLocalization(WorkinprocessBeginTotalName(), '17700');
        ContosoGLAccount.AddAccountForLocalization(WorkinprocessName(), '17710');
        ContosoGLAccount.AddAccountForLocalization(InvoicedonaccountName(), '17720');
        ContosoGLAccount.AddAccountForLocalization(TotalworkinprocessName(), '17997');
        ContosoGLAccount.AddAccountForLocalization(TotalreceivablesName(), '17999');
        ContosoGLAccount.AddAccountForLocalization(CashflowfundsName(), '18000');
        ContosoGLAccount.AddAccountForLocalization(CheckoutName(), '18100');
        ContosoGLAccount.AddAccountForLocalization(BankName(), '18200');
        ContosoGLAccount.AddAccountForLocalization(BankaccountcurrenciesName(), '18400');
        ContosoGLAccount.AddAccountForLocalization(TotalcashflowfundsName(), '18997');
        ContosoGLAccount.AddAccountForLocalization(TotalcurrentassetsName(), '18998');
        ContosoGLAccount.AddAccountForLocalization(EquityName(), '20100');
        ContosoGLAccount.AddAccountForLocalization(OpeningequityName(), '20200');
        ContosoGLAccount.AddAccountForLocalization(RetainedearningsfortheyearName(), '20400');
        ContosoGLAccount.AddAccountForLocalization(PrivatewithdrawalsetcName(), '20500');
        ContosoGLAccount.AddAccountForLocalization(PaidbtaxeslabormarketcontributionName(), '20600');
        ContosoGLAccount.AddAccountForLocalization(PrivatephoneusageName(), '20700');
        ContosoGLAccount.AddAccountForLocalization(WithdrawalforpersonaluseName(), '20800');
        ContosoGLAccount.AddAccountForLocalization(TotalprivatewithdrawalsName(), '20997');
        ContosoGLAccount.AddAccountForLocalization(EquityatendofyearName(), '20998');
        ContosoGLAccount.AddAccountForLocalization(MortgagedebtName(), '21100');
        ContosoGLAccount.AddAccountForLocalization(BankdebtName(), '21200');
        ContosoGLAccount.AddAccountForLocalization(TotallongtermliabilitiesName(), '21999');
        ContosoGLAccount.AddAccountForLocalization(DebttofinancialinstitutionName(), '23000');
        ContosoGLAccount.AddAccountForLocalization(TotaldebttofinancialinstitutionName(), '23997');
        ContosoGLAccount.AddAccountForLocalization(SalestaxandothertaxesName(), '24000');
        ContosoGLAccount.AddAccountForLocalization(SalestaxpayableSalesTaxName(), '24010');
        ContosoGLAccount.AddAccountForLocalization(SalestaxreceivableInputTaxName(), '24020');
        ContosoGLAccount.AddAccountForLocalization(SalestaxonoverseaspurchasesName(), '24030');
        ContosoGLAccount.AddAccountForLocalization(EuacquisitiontaxName(), '24040');
        ContosoGLAccount.AddAccountForLocalization(OiltaxName(), '24210');
        ContosoGLAccount.AddAccountForLocalization(SalestaxsettlementaccountName(), '24300');
        ContosoGLAccount.AddAccountForLocalization(TotalsalestaxName(), '24997');
        ContosoGLAccount.AddAccountForLocalization(AccountsPayablePostingName(), '25100');
        ContosoGLAccount.AddAccountForLocalization(AccruedtaxName(), '25200');
        ContosoGLAccount.AddAccountForLocalization(AdditionalcostsName(), '25300');
        ContosoGLAccount.AddAccountForLocalization(PrepaymentsAccountsPayableName(), '25400');
        ContosoGLAccount.AddAccountForLocalization(TotalshorttermliabilitiesName(), '25799');
        ContosoGLAccount.AddAccountForLocalization(TotalaccountspayableName(), '25997');
        ContosoGLAccount.AddAccountForLocalization(AccruedcostsBeginTotalName(), '26000');
        ContosoGLAccount.AddAccountForLocalization(AccruedcostsName(), '26200');
        ContosoGLAccount.AddAccountForLocalization(DeferralsName(), '26300');
        ContosoGLAccount.AddAccountForLocalization(PrepaymentsAccruedCostsName(), '26400');
        ContosoGLAccount.AddAccountForLocalization(TotalaccruedcostsName(), '26997');
        ContosoGLAccount.AddAccountForLocalization(PayrollliabilitiesBeginTotalName(), '27000');
        ContosoGLAccount.AddAccountForLocalization(LabormarketcontributionpayableName(), '27200');
        ContosoGLAccount.AddAccountForLocalization(RetirementplancontributionspayableName(), '27400');
        ContosoGLAccount.AddAccountForLocalization(PayrollliabilitiesName(), '27500');
        ContosoGLAccount.AddAccountForLocalization(TotalpayrollliabilitiesName(), '27997');
        ContosoGLAccount.AddAccountForLocalization(AllnullName(), '29999');
        AddGLAccountforDK();
    end;

    local procedure ModifyGLAccountForW1()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BalancesheetName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumdepreciationbuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandbuildingstotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumdeproperequipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingequipmenttotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumdepreciationvehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclestotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangiblefixedassetstotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedassetstotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleitemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleitemsinterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofresalesoldinterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedgoodsinterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawmaterialsinterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofrawmatsoldinterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PrimoinventoryName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventorytotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobwipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipsalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipsalestotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipcostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipcoststotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobwiptotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersdomesticName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersforeignName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedinterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsreceivabletotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseprepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Vendorprepaymentsvat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Vendorprepaymentsvat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseprepaymentstotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiestotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidassetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BanklcyName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankcurrenciesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GiroaccountName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidassetstotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentassetstotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.StockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetainedearningsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetincomefortheyearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalStockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeferredtaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancestotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermbankloansName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermliabilitiestotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesprepaymentsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Customerprepaymentsvat0Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Customerprepaymentsvat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Customerprepaymentsvat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesprepaymentstotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsdomesticName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsforeignName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountspayabletotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvadjmtinterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvadjmtinterimretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvadjmtinterimrawmatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvadjmtinterimtotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Salesvat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Salesvat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Purchasevat25euName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Purchasevat10euName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Purchasevat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Purchasevat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FueltaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CoaltaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VatpayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VattotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelrelateditemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SupplementarytaxespayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EmployeespayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalpersonnelrelateditemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherliabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DividendsforthefiscalyearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporatetaxespayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherliabilitiestotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShorttermliabilitiestotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalliabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncomestatementName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesretaildomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesretaileuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesretailexportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobsalesappliedretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobsalesadjmtretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalsalesofretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofrawmaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesrawmaterialsdomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesrawmaterialseuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesrawmaterialsexportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobsalesappliedrawmatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobsalesadjmtrawmatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalsalesofrawmaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofresourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesresourcesdomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesresourceseuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesresourcesexportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobsalesappliedresourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobsalesadjmtresourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalsalesofresourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofjobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesotherjobexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalsalesofjobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultingfeesdomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FeesandchargesrecdomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscountgrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchretaildomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchretaileuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchretailexportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscreceivedretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryexpensesretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryadjmtretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobcostappliedretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobcostadjmtretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofretailsoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalcostofretailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofrawmaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchrawmaterialsdomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchrawmaterialseuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchrawmaterialsexportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscreceivedrawmaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryexpensesrawmatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryadjmtrawmatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobcostappliedrawmatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobcostadjmtrawmaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofrawmaterialssoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalcostofrawmaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofresourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobcostappliedresourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobcostadjmtresourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostofresourcesusedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalcostofresourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalcostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BuildingmaintenanceexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityandheatingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalbldgmaintexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdministrativeexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OfficesuppliesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PhoneandfaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PostageName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotaladministrativeexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ComputerexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SoftwareName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultantservicesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OthercomputerexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalcomputerexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SellingexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdvertisingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EntertainmentandprName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TravelName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalsellingexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehicleexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GasolineandmotoroilName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RegistrationfeesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalvehicleexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtheroperatingexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BaddebtexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LegalandaccountingservicesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MiscellaneousName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtheroperatingexptotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotaloperatingexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WagesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetirementplancontributionsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrolltaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalpersonnelexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationoffixedassetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationbuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationequipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationvehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GainsandlossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalfixedassetdepreciationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OthercostsofoperationsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetoperatingincomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestincomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonbankbalancesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinancechargesfromcustomersName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentdiscountsreceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtdiscreceiveddecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoiceroundingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ApplicationroundingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymenttolerancereceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmttolreceiveddecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalinterestincomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonrevolvingcreditName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonbankloansName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinancechargestovendorsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentdiscountsgrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtdiscgranteddecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymenttolerancegrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmttolgranteddecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalinterestexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NibeforeextritemsTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryincomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryexpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetincomebeforetaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporatetaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetincomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceExpenseName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryName(), '');
    end;

    procedure ProfitandlossstatementName(): Text[100]
    begin
        exit(ProfitandlossstatementLbl);
    end;

    procedure DomesticsalesofgoodsandservicesName(): Text[100]
    begin
        exit(DomesticsalesofgoodsandservicesLbl);
    end;

    procedure EusalesofgoodsandservicesName(): Text[100]
    begin
        exit(EusalesofgoodsandservicesLbl);
    end;

    procedure SalesofgoodsandservicestoothercountriesName(): Text[100]
    begin
        exit(SalesofgoodsandservicestoothercountriesLbl);
    end;

    procedure FreightIncomeName(): Text[100]
    begin
        exit(FreightIncomeLbl);
    end;

    procedure OnaccountinvoicingName(): Text[100]
    begin
        exit(OnaccountinvoicingLbl);
    end;

    procedure ChargeexsalestaxName(): Text[100]
    begin
        exit(ChargeexsalestaxLbl);
    end;

    procedure ChargeinclsalestaxName(): Text[100]
    begin
        exit(ChargeinclsalestaxLbl);
    end;

    procedure DiscountsgrantedName(): Text[100]
    begin
        exit(DiscountsgrantedLbl);
    end;

    procedure JobsalesappliedName(): Text[100]
    begin
        exit(JobsalesappliedLbl);
    end;

    procedure CostofGoodsSoldBeginTotalName(): Text[100]
    begin
        exit(CostofgoodssoldBeginTotalLbl);
    end;

    procedure CostofgoodssoldName(): Text[100]
    begin
        exit(CostofgoodssoldLbl);
    end;

    procedure ItempurchasesName(): Text[100]
    begin
        exit(ItempurchasesLbl);
    end;

    procedure MiscconsumptionName(): Text[100]
    begin
        exit(MiscconsumptionLbl);
    end;

    procedure ForeignlaborName(): Text[100]
    begin
        exit(ForeignlaborLbl);
    end;

    procedure FreightCostOfGoodsName(): Text[100]
    begin
        exit(FreightCostofGoodsLbl);
    end;

    procedure ProfitlossinventoryName(): Text[100]
    begin
        exit(ProfitlossinventoryLbl);
    end;

    procedure ChargebeforesalestaxName(): Text[100]
    begin
        exit(ChargebeforesalestaxLbl);
    end;

    procedure ChargeaftersalestaxName(): Text[100]
    begin
        exit(ChargeaftersalestaxLbl);
    end;

    procedure DiscountsreceivedName(): Text[100]
    begin
        exit(DiscountsreceivedLbl);
    end;

    procedure IteminventoryadjustmentName(): Text[100]
    begin
        exit(IteminventoryadjustmentLbl);
    end;

    procedure PurchasevarianceName(): Text[100]
    begin
        exit(PurchasevarianceLbl);
    end;

    procedure TotalcostofgoodssoldName(): Text[100]
    begin
        exit(TotalcostofgoodssoldLbl);
    end;

    procedure ProjectcostsName(): Text[100]
    begin
        exit(ProjectcostsLbl);
    end;

    procedure MachineryRentalLeasingFeeName(): Text[100]
    begin
        exit(MachineryRentalLeasingFeeLbl);
    end;

    procedure TravelfeeName(): Text[100]
    begin
        exit(TravelfeeLbl);
    end;

    procedure MaterialcostsName(): Text[100]
    begin
        exit(MaterialcostsLbl);
    end;

    procedure ProjecthoursName(): Text[100]
    begin
        exit(ProjecthoursLbl);
    end;

    procedure AdjustmentofwipName(): Text[100]
    begin
        exit(AdjustmentofwipLbl);
    end;

    procedure JobcostsappliedName(): Text[100]
    begin
        exit(JobcostsappliedLbl);
    end;

    procedure TotalprojectcostsName(): Text[100]
    begin
        exit(TotalprojectcostsLbl);
    end;

    procedure PersonnelcostsName(): Text[100]
    begin
        exit(PersonnelcostsLbl);
    end;

    procedure SalariesvacationcompensationName(): Text[100]
    begin
        exit(SalariesvacationcompensationLbl);
    end;

    procedure SalariesproductionName(): Text[100]
    begin
        exit(SalariesproductionLbl);
    end;

    procedure DirectorsfeeName(): Text[100]
    begin
        exit(DirectorsfeeLbl);
    end;

    procedure AnniversarygiftName(): Text[100]
    begin
        exit(AnniversarygiftLbl);
    end;

    procedure SeverancepayName(): Text[100]
    begin
        exit(SeverancepayLbl);
    end;

    procedure PensioncompanyName(): Text[100]
    begin
        exit(PensioncompanyLbl);
    end;

    procedure LabormarketpensioncompanyName(): Text[100]
    begin
        exit(LabormarketpensioncompanyLbl);
    end;

    procedure OptionalpayaccountsavingsName(): Text[100]
    begin
        exit(OptionalpayaccountsavingsLbl);
    end;

    procedure EmployeeartclubName(): Text[100]
    begin
        exit(EmployeeartclubLbl);
    end;

    procedure GiftfundName(): Text[100]
    begin
        exit(GiftfundLbl);
    end;

    procedure LunchName(): Text[100]
    begin
        exit(LunchLbl);
    end;

    procedure DamaternitypaternityleavepremiumName(): Text[100]
    begin
        exit(DamaternitypaternityleavepremiumLbl);
    end;

    procedure AtpemployeeName(): Text[100]
    begin
        exit(AtpemployeeLbl);
    end;

    procedure MileagerateName(): Text[100]
    begin
        exit(MileagerateLbl);
    end;

    procedure RefundsName(): Text[100]
    begin
        exit(RefundsLbl);
    end;

    procedure AtpemployerName(): Text[100]
    begin
        exit(AtpemployerLbl);
    end;

    procedure ProjecthoursspentName(): Text[100]
    begin
        exit(ProjecthoursspentLbl);
    end;

    procedure ProjecthoursallocatedtooperatingresultName(): Text[100]
    begin
        exit(ProjecthoursallocatedtooperatingresultLbl);
    end;

    procedure ConsumptionforownproductionName(): Text[100]
    begin
        exit(ConsumptionforownproductionLbl);
    end;

    procedure SocialsecbenefitsalloctooperatingresultName(): Text[100]
    begin
        exit(SocialsecbenefitsalloctooperatingresultLbl);
    end;

    procedure TransferredssbstoproductionName(): Text[100]
    begin
        exit(TransferredssbstoproductionLbl);
    end;

    procedure TrainingexpensesName(): Text[100]
    begin
        exit(TrainingexpensesLbl);
    end;

    procedure OtherpersonnelcostsName(): Text[100]
    begin
        exit(OtherpersonnelcostsLbl);
    end;

    procedure TotalpersonnelcostsName(): Text[100]
    begin
        exit(TotalpersonnelcostsLbl);
    end;

    procedure MarketingcostsName(): Text[100]
    begin
        exit(MarketingcostsLbl);
    end;

    procedure AdvertisementsandcommercialsName(): Text[100]
    begin
        exit(AdvertisementsandcommercialsLbl);
    end;

    procedure EntwinetobaccospiritsName(): Text[100]
    begin
        exit(EntwinetobaccospiritsLbl);
    end;

    procedure EntgiftsandflowersName(): Text[100]
    begin
        exit(EntgiftsandflowersLbl);
    end;

    procedure TravelingtradefairsetcName(): Text[100]
    begin
        exit(TravelingtradefairsetcLbl);
    end;

    procedure RestaurantdiningName(): Text[100]
    begin
        exit(RestaurantdiningLbl);
    end;

    procedure DecorationName(): Text[100]
    begin
        exit(DecorationLbl);
    end;

    procedure TotalmarketingcostsName(): Text[100]
    begin
        exit(TotalmarketingcostsLbl);
    end;

    procedure MarketingcontributionsName(): Text[100]
    begin
        exit(MarketingcontributionsLbl);
    end;

    procedure AutomobileoperationscarsName(): Text[100]
    begin
        exit(AutomobileoperationscarsLbl);
    end;

    procedure RentalLeasingFeeMachineName(): Text[100]
    begin
        exit(RentalLeasingFeeMachineLbl);
    end;

    procedure GasVansName(): Text[100]
    begin
        exit(GasVansLbl);
    end;

    procedure InsuranceCostOfWorkSpaceName(): Text[100]
    begin
        exit(InsuranceCostOfWorkSpaceLbl);
    end;

    procedure GasconsumptiontaxVansName(): Text[100]
    begin
        exit(GasconsumptiontaxVansLbl);
    end;

    procedure RepmaintenanceVansName(): Text[100]
    begin
        exit(RepmaintenanceVansLbl);
    end;

    procedure FerryticketsbridgetollsAutoMobileName(): Text[100]
    begin
        exit(FerryticketsbridgetollsAutoMobileLbl);
    end;

    procedure TotalvehicleoperationsName(): Text[100]
    begin
        exit(TotalvehicleoperationsLbl);
    end;

    procedure VansName(): Text[100]
    begin
        exit(VansLbl);
    end;

    procedure RentalLeasingFeeAutoMobileName(): Text[100]
    begin
        exit(RentalLeasingFeeAutoMobileLbl);
    end;

    procedure GasAutoMobileName(): Text[100]
    begin
        exit(GasAutoMobileLbl);
    end;

    procedure GasconsumptiontaxAutoMobileName(): Text[100]
    begin
        exit(GasconsumptiontaxAutoMobileLbl);
    end;

    procedure InsurancesAdminCostName(): Text[100]
    begin
        exit(InsurancesAdminCostLbl);
    end;

    procedure RepmaintenanceAutoMobileName(): Text[100]
    begin
        exit(RepmaintenanceAutoMobileLbl);
    end;

    procedure FerryticketsbridgetollsVansName(): Text[100]
    begin
        exit(FerryticketsbridgetollsVansLbl);
    end;

    procedure VanstotalExpenseName(): Text[100]
    begin
        exit(VanstotalExpenseLbl);
    end;

    procedure MachinesName(): Text[100]
    begin
        exit(MachinesLbl);
    end;

    procedure RentalLeasingFeeVansName(): Text[100]
    begin
        exit(RentalLeasingFeeVansLbl);
    end;

    procedure MachineoperatingcostsName(): Text[100]
    begin
        exit(MachineoperatingcostsLbl);
    end;

    procedure MachrepairsandmaintenanceName(): Text[100]
    begin
        exit(MachrepairsandmaintenanceLbl);
    end;

    procedure MachineryinsuranceName(): Text[100]
    begin
        exit(MachineryinsuranceLbl);
    end;

    procedure MachinestotalName(): Text[100]
    begin
        exit(MachinestotalLbl);
    end;

    procedure CostofofficeworkshopspaceName(): Text[100]
    begin
        exit(CostofofficeworkshopspaceLbl);
    end;

    procedure RentName(): Text[100]
    begin
        exit(RentLbl);
    end;

    procedure InsuranceAutoMobileName(): Text[100]
    begin
        exit(InsuranceAutoMobileLbl);
    end;

    procedure ElectricityName(): Text[100]
    begin
        exit(ElectricityLbl);
    end;

    procedure WaterName(): Text[100]
    begin
        exit(WaterLbl);
    end;

    procedure HeatingName(): Text[100]
    begin
        exit(HeatingLbl);
    end;

    procedure NaturalgasName(): Text[100]
    begin
        exit(NaturalgasLbl);
    end;

    procedure TaxesBeginTotalName(): Text[100]
    begin
        exit(TaxesBeginTotalLbl);
    end;

    procedure NewacquisitionsName(): Text[100]
    begin
        exit(NewacquisitionsLbl);
    end;

    procedure TotalcostofofficeworkshopspaceName(): Text[100]
    begin
        exit(TotalcostofofficeworkshopspaceLbl);
    end;

    procedure AdministrativecostsName(): Text[100]
    begin
        exit(AdministrativecostsLbl);
    end;

    procedure PhonescellphonesName(): Text[100]
    begin
        exit(PhonescellphonesLbl);
    end;

    procedure InternetwebsiteName(): Text[100]
    begin
        exit(InternetwebsiteLbl);
    end;

    procedure NewspapersmagazinesName(): Text[100]
    begin
        exit(NewspapersmagazinesLbl);
    end;

    procedure SubscriptionsmembershipfeesName(): Text[100]
    begin
        exit(SubscriptionsmembershipfeesLbl);
    end;

    procedure OfficestationaryName(): Text[100]
    begin
        exit(OfficestationaryLbl);
    end;

    procedure PostagefeesName(): Text[100]
    begin
        exit(PostagefeesLbl);
    end;

    procedure InsurancesVansName(): Text[100]
    begin
        exit(InsurancesVansLbl);
    end;

    procedure MinoracquisitionsName(): Text[100]
    begin
        exit(MinoracquisitionsLbl);
    end;

    procedure ConferenceexpensesName(): Text[100]
    begin
        exit(ConferenceexpensesLbl);
    end;

    procedure AccountingcostsName(): Text[100]
    begin
        exit(AccountingcostsLbl);
    end;

    procedure AuditingaccountingassistanceName(): Text[100]
    begin
        exit(AuditingaccountingassistanceLbl);
    end;

    procedure LawyerName(): Text[100]
    begin
        exit(LawyerLbl);
    end;

    procedure LegalaidName(): Text[100]
    begin
        exit(LegalaidLbl);
    end;

    procedure RepairsandmaintenancefurnitureequipmentName(): Text[100]
    begin
        exit(RepairsandmaintenancefurnitureequipmentLbl);
    end;

    procedure ItexpensesName(): Text[100]
    begin
        exit(ItexpensesLbl);
    end;

    procedure SalarycostsName(): Text[100]
    begin
        exit(SalarycostsLbl);
    end;

    procedure FreightExpenseName(): Text[100]
    begin
        exit(FreightExpenseLbl);
    end;

    procedure ChargesName(): Text[100]
    begin
        exit(ChargesLbl);
    end;

    procedure TotaladministrativecostsName(): Text[100]
    begin
        exit(TotaladministrativecostsLbl);
    end;

    procedure TotalcostsName(): Text[100]
    begin
        exit(TotalcostsLbl);
    end;

    procedure ResbeforedepreciationName(): Text[100]
    begin
        exit(ResbeforedepreciationLbl);
    end;

    procedure DepreciationBeginTotalName(): Text[100]
    begin
        exit(DepreciationBeginTotalLbl);
    end;

    procedure VansBeginTotalExpenseName(): Text[100]
    begin
        exit(VansBeginTotalExpenseLbl);
    end;

    procedure CarsBeginTotalName(): Text[100]
    begin
        exit(CarsBeginTotalLbl);
    end;

    procedure FurnitureequipmentName(): Text[100]
    begin
        exit(FurnitureequipmentLbl);
    end;

    procedure GoodwillName(): Text[100]
    begin
        exit(GoodwillLbl);
    end;

    procedure TotaldepreciationName(): Text[100]
    begin
        exit(TotaldepreciationLbl);
    end;

    procedure InventoryPostingName(): Text[100]
    begin
        exit(InventoryLbl);
    end;

    procedure InventoryBeginTotalName(): Text[100]
    begin
        exit(InventoryBeginTotalLbl);
    end;

    procedure AccountsPayablePostingName(): Text[100]
    begin
        exit(AccountsPayableLbl);
    end;

    procedure ResbeforefinancialitemsName(): Text[100]
    begin
        exit(ResbeforefinancialitemsLbl);
    end;

    procedure FinancialitemsName(): Text[100]
    begin
        exit(FinancialitemsLbl);
    end;

    procedure OperatingincomeName(): Text[100]
    begin
        exit(OperatingincomeLbl);
    end;

    procedure BankinterestFinancalExpenseName(): Text[100]
    begin
        exit(BankinterestFinancalExpenseLbl);
    end;

    procedure AccountsreceivableinterestName(): Text[100]
    begin
        exit(AccountsreceivableinterestLbl);
    end;

    procedure TotaloperatingincomeName(): Text[100]
    begin
        exit(TotaloperatingincomeLbl);
    end;

    procedure FinancialexpensesName(): Text[100]
    begin
        exit(FinancialexpensesLbl);
    end;

    procedure BankinterestFinancalItemsName(): Text[100]
    begin
        exit(BankinterestFInancalItemsLbl);
    end;

    procedure AccountspayableinterestName(): Text[100]
    begin
        exit(AccountspayableinterestLbl);
    end;

    procedure AccountspayablechargesName(): Text[100]
    begin
        exit(AccountspayablechargesLbl);
    end;

    procedure AdditionalinterestexpensesName(): Text[100]
    begin
        exit(AdditionalinterestexpensesLbl);
    end;

    procedure CentdiscrepanciesName(): Text[100]
    begin
        exit(CentdiscrepanciesLbl);
    end;

    procedure DisallowedinterestdeductionsName(): Text[100]
    begin
        exit(DisallowedinterestdeductionsLbl);
    end;

    procedure TotalfinancialexpensesName(): Text[100]
    begin
        exit(TotalfinancialexpensesLbl);
    end;

    procedure TotalfinancialitemsName(): Text[100]
    begin
        exit(TotalfinancialitemsLbl);
    end;

    procedure ResultbeforetaxName(): Text[100]
    begin
        exit(ResultbeforetaxLbl);
    end;

    procedure TaxesCostOfWorkSpaceName(): Text[100]
    begin
        exit(TaxesCostOfWorkSpaceLbl);
    end;

    procedure TaxesName(): Text[100]
    begin
        exit(TaxesLbl);
    end;

    procedure TotaltaxesName(): Text[100]
    begin
        exit(TotaltaxesLbl);
    end;

    procedure PeriodearningsName(): Text[100]
    begin
        exit(PeriodearningsLbl);
    end;

    procedure BalanceName(): Text[100]
    begin
        exit(BalanceLbl);
    end;

    procedure GoodwillBeginTotalName(): Text[100]
    begin
        exit(GoodwillBeginTotalLbl);
    end;

    procedure OpeningbalanceName(): Text[100]
    begin
        exit(OpeningbalanceLbl);
    end;

    procedure DepreciationName(): Text[100]
    begin
        exit(DepreciationLbl);
    end;

    procedure TotalgoodwillName(): Text[100]
    begin
        exit(TotalgoodwillLbl);
    end;

    procedure TotalintangiblefixedassetsName(): Text[100]
    begin
        exit(TotalintangiblefixedassetsLbl);
    end;

    procedure FinancialfixedassetsName(): Text[100]
    begin
        exit(FinancialfixedassetsLbl);
    end;

    procedure CommonstockName(): Text[100]
    begin
        exit(CommonstockLbl);
    end;

    procedure TotalsecuritiesName(): Text[100]
    begin
        exit(TotalsecuritiesLbl);
    end;

    procedure TotalfinancialfixedassetsName(): Text[100]
    begin
        exit(TotalfinancialfixedassetsLbl);
    end;

    procedure AcquisitioncostLandBuildingsName(): Text[100]
    begin
        exit(AcquisitioncostLandBuildingsLbl);
    end;

    procedure AdditionFurnitureName(): Text[100]
    begin
        exit(AdditionFurnitureLbl);
    end;

    procedure OutputLandBuildingsName(): Text[100]
    begin
        exit(OutputLandBuildingsLbl);
    end;

    procedure AccdepreciationLandBuildingsName(): Text[100]
    begin
        exit(AccdepreciationLandBuildingsLbl);
    end;

    procedure DepreciationfortheyearLandBuilingsName(): Text[100]
    begin
        exit(DepreciationfortheyearLandBuildingsLbl);
    end;

    procedure TotallandandbuildingsName(): Text[100]
    begin
        exit(TotallandandbuildingsLbl);
    end;

    procedure CarsName(): Text[100]
    begin
        exit(CarsLbl);
    end;

    procedure AcquisitioncostCarsName(): Text[100]
    begin
        exit(AcquisitioncostCarsLbl);
    end;

    procedure AdditionLandBuildingsName(): Text[100]
    begin
        exit(AdditionLandBuildingsLbl);
    end;

    procedure OutputCarsName(): Text[100]
    begin
        exit(OutputCarsLbl);
    end;

    procedure AccdepreciationOperatingName(): Text[100]
    begin
        exit(AccdepreciationOperatingLbl);
    end;

    procedure DepreciationfortheyearCarsName(): Text[100]
    begin
        exit(DepreciationfortheyearCarsLbl);
    end;

    procedure CarstotalName(): Text[100]
    begin
        exit(CarstotalLbl);
    end;

    procedure VansBeginTotalAssetsName(): Text[100]
    begin
        exit(VansBeginTotalAssetsLbl);
    end;

    procedure AcquisitioncostVansName(): Text[100]
    begin
        exit(AcquisitioncostVansLbl);
    end;

    procedure AdditionCarsName(): Text[100]
    begin
        exit(AdditionCarsLbl);
    end;

    procedure OutputVansName(): Text[100]
    begin
        exit(OutputVansLbl);
    end;

    procedure AccdepreciationCarsName(): Text[100]
    begin
        exit(AccdepreciationCarsLbl);
    end;

    procedure DepreciationfortheyearVansName(): Text[100]
    begin
        exit(DepreciationfortheyearVansLbl);
    end;

    procedure VanstotalAssetsName(): Text[100]
    begin
        exit(VanstotalAssetsLbl);
    end;

    procedure AcquisitioncostOperatingEquipmentName(): Text[100]
    begin
        exit(AcquisitioncostOperatingEquipmentLbl);
    end;

    procedure AdditionVansName(): Text[100]
    begin
        exit(AdditionVansLbl);
    end;

    procedure OutputOperatingEquipmentsName(): Text[100]
    begin
        exit(OutputOperatingEquipmentsLbl);
    end;

    procedure AccdepreciationVansName(): Text[100]
    begin
        exit(AccdepreciationVansLbl);
    end;

    procedure DepreciationfortheyearFurnitureName(): Text[100]
    begin
        exit(DepreciationfortheyearFurnitureLbl);
    end;

    procedure TotaloperatingequipmentName(): Text[100]
    begin
        exit(TotaloperatingequipmentLbl);
    end;

    procedure FurnitureequipmentBeginTotalName(): Text[100]
    begin
        exit(FurnitureequipmentBeginTotalLbl);
    end;

    procedure AcquisitioncostFurnitureName(): Text[100]
    begin
        exit(AcquisitioncostFurnitureLbl);
    end;

    procedure AdditionOperatingEquipmentName(): Text[100]
    begin
        exit(AdditionOperatingEquipmentLbl);
    end;

    procedure OutputFurnitureName(): Text[100]
    begin
        exit(OutputFurnitureLbl);
    end;

    procedure AccdepreciationFurnitureName(): Text[100]
    begin
        exit(AccdepreciationFurnitureLbl);
    end;

    procedure DepreciationfortheyearOperatingName(): Text[100]
    begin
        exit(DepreciationfortheyearOperatingLbl);
    end;

    procedure TotalfurnitureequipmentName(): Text[100]
    begin
        exit(TotalfurnitureequipmentLbl);
    end;

    procedure TotaltangiblefixedassetsName(): Text[100]
    begin
        exit(TotaltangiblefixedassetsLbl);
    end;

    procedure InventoryadjustmentName(): Text[100]
    begin
        exit(InventoryadjustmentLbl);
    end;

    procedure ItemreceivedName(): Text[100]
    begin
        exit(ItemreceivedLbl);
    end;

    procedure ItemshippedName(): Text[100]
    begin
        exit(ItemshippedLbl);
    end;

    procedure TotalinventoryName(): Text[100]
    begin
        exit(TotalinventoryLbl);
    end;

    procedure ReceivablesName(): Text[100]
    begin
        exit(ReceivablesLbl);
    end;

    procedure DeferredName(): Text[100]
    begin
        exit(DeferredLbl);
    end;

    procedure PrepaymentsReceivablesName(): Text[100]
    begin
        exit(PrepaymentsReceivablesLbl);
    end;

    procedure DepositsName(): Text[100]
    begin
        exit(DepositsLbl);
    end;

    procedure DepositstenancyName(): Text[100]
    begin
        exit(DepositstenancyLbl);
    end;

    procedure TotaldepositsName(): Text[100]
    begin
        exit(TotaldepositsLbl);
    end;

    procedure WorkinprocessBeginTotalName(): Text[100]
    begin
        exit(WorkinprocessBeginTotalLbl);
    end;

    procedure WorkinprocessName(): Text[100]
    begin
        exit(WorkinprocessLbl);
    end;

    procedure InvoicedonaccountName(): Text[100]
    begin
        exit(InvoicedonaccountLbl);
    end;

    procedure TotalworkinprocessName(): Text[100]
    begin
        exit(TotalworkinprocessLbl);
    end;

    procedure TotalreceivablesName(): Text[100]
    begin
        exit(TotalreceivablesLbl);
    end;

    procedure CashflowfundsName(): Text[100]
    begin
        exit(CashflowfundsLbl);
    end;

    procedure CheckoutName(): Text[100]
    begin
        exit(CheckoutLbl);
    end;

    procedure BankName(): Text[100]
    begin
        exit(BankLbl);
    end;

    procedure BankaccountcurrenciesName(): Text[100]
    begin
        exit(BankaccountcurrenciesLbl);
    end;

    procedure TotalcashflowfundsName(): Text[100]
    begin
        exit(TotalcashflowfundsLbl);
    end;

    procedure TotalcurrentassetsName(): Text[100]
    begin
        exit(TotalcurrentassetsLbl);
    end;

    procedure EquityName(): Text[100]
    begin
        exit(EquityLbl);
    end;

    procedure OpeningequityName(): Text[100]
    begin
        exit(OpeningequityLbl);
    end;

    procedure RetainedearningsfortheyearName(): Text[100]
    begin
        exit(RetainedearningsfortheyearLbl);
    end;

    procedure PrivatewithdrawalsetcName(): Text[100]
    begin
        exit(PrivatewithdrawalsetcLbl);
    end;

    procedure PaidbtaxeslabormarketcontributionName(): Text[100]
    begin
        exit(PaidbtaxeslabormarketcontributionLbl);
    end;

    procedure PrivatephoneusageName(): Text[100]
    begin
        exit(PrivatephoneusageLbl);
    end;

    procedure WithdrawalforpersonaluseName(): Text[100]
    begin
        exit(WithdrawalforpersonaluseLbl);
    end;

    procedure TotalprivatewithdrawalsName(): Text[100]
    begin
        exit(TotalprivatewithdrawalsLbl);
    end;

    procedure EquityatendofyearName(): Text[100]
    begin
        exit(EquityatendofyearLbl);
    end;

    procedure MortgagedebtName(): Text[100]
    begin
        exit(MortgagedebtLbl);
    end;

    procedure BankdebtName(): Text[100]
    begin
        exit(BankdebtLbl);
    end;

    procedure TotallongtermliabilitiesName(): Text[100]
    begin
        exit(TotallongtermliabilitiesLbl);
    end;

    procedure DebttofinancialinstitutionName(): Text[100]
    begin
        exit(DebttofinancialinstitutionLbl);
    end;

    procedure TotaldebttofinancialinstitutionName(): Text[100]
    begin
        exit(TotaldebttofinancialinstitutionLbl);
    end;

    procedure SalestaxandothertaxesName(): Text[100]
    begin
        exit(SalestaxandothertaxesLbl);
    end;

    procedure SalestaxpayableSalesTaxName(): Text[100]
    begin
        exit(SalestaxpayableSalesTaxLbl);
    end;

    procedure SalestaxreceivableInputTaxName(): Text[100]
    begin
        exit(SalestaxreceivableInputTaxLbl);
    end;

    procedure SalestaxonoverseaspurchasesName(): Text[100]
    begin
        exit(SalestaxonoverseaspurchasesLbl);
    end;

    procedure EuacquisitiontaxName(): Text[100]
    begin
        exit(EuacquisitiontaxLbl);
    end;

    procedure OiltaxName(): Text[100]
    begin
        exit(OiltaxLbl);
    end;

    procedure SalestaxsettlementaccountName(): Text[100]
    begin
        exit(SalestaxsettlementaccountLbl);
    end;

    procedure TotalsalestaxName(): Text[100]
    begin
        exit(TotalsalestaxLbl);
    end;

    procedure AccruedtaxName(): Text[100]
    begin
        exit(AccruedtaxLbl);
    end;

    procedure AdditionalcostsName(): Text[100]
    begin
        exit(AdditionalcostsLbl);
    end;

    procedure PrepaymentsAccountsPayableName(): Text[100]
    begin
        exit(PrepaymentsAccountsPayableLbl);
    end;

    procedure TotalshorttermliabilitiesName(): Text[100]
    begin
        exit(TotalshorttermliabilitiesLbl);
    end;

    procedure TotalaccountspayableName(): Text[100]
    begin
        exit(TotalaccountspayableLbl);
    end;

    procedure AccruedcostsBeginTotalName(): Text[100]
    begin
        exit(AccruedcostsBeginTotalLbl);
    end;

    procedure AccruedcostsName(): Text[100]
    begin
        exit(AccruedcostsLbl);
    end;

    procedure DeferralsName(): Text[100]
    begin
        exit(DeferralsLbl);
    end;

    procedure PrepaymentsAccruedCostsName(): Text[100]
    begin
        exit(PrepaymentsAccruedCostsLbl);
    end;

    procedure TotalaccruedcostsName(): Text[100]
    begin
        exit(TotalaccruedcostsLbl);
    end;

    procedure PayrollliabilitiesBeginTotalName(): Text[100]
    begin
        exit(PayrollliabilitiesBeginTotalLbl);
    end;

    procedure LabormarketcontributionpayableName(): Text[100]
    begin
        exit(LabormarketcontributionpayableLbl);
    end;

    procedure RetirementplancontributionspayableName(): Text[100]
    begin
        exit(RetirementplancontributionspayableLbl);
    end;

    procedure PayrollliabilitiesName(): Text[100]
    begin
        exit(PayrollliabilitiesLbl);
    end;

    procedure TotalpayrollliabilitiesName(): Text[100]
    begin
        exit(TotalpayrollliabilitiesLbl);
    end;

    procedure AllnullName(): Text[100]
    begin
        exit(AllnullLbl);
    end;

    procedure Profitandlossstatement(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProfitandlossstatementName()));
    end;

    procedure Domesticsalesofgoodsandservices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DomesticsalesofgoodsandservicesName()));
    end;

    procedure Eusalesofgoodsandservices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EusalesofgoodsandservicesName()));
    end;

    procedure Salesofgoodsandservicestoothercountries(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesofgoodsandservicestoothercountriesName()));
    end;

    procedure FreightIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightIncomeName()));
    end;

    procedure Onaccountinvoicing(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OnaccountinvoicingName()));
    end;

    procedure Chargeexsalestax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChargeexsalestaxName()));
    end;

    procedure Chargeinclsalestax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChargeinclsalestaxName()));
    end;

    procedure Discountsgranted(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DiscountsgrantedName()));
    end;

    procedure Jobsalesapplied(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobsalesappliedName()));
    end;

    procedure CostofGoodSoldBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofGoodsSoldBeginTotalName()));
    end;

    procedure Costofgoodssold(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofgoodssoldName()));
    end;

    procedure Itempurchases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ItempurchasesName()));
    end;

    procedure Miscconsumption(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscconsumptionName()));
    end;

    procedure Foreignlabor(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ForeignlaborName()));
    end;

    procedure FreightCostOfGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightCostOfGoodsName()));
    end;

    procedure Profitlossinventory(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProfitlossinventoryName()));
    end;

    procedure Chargebeforesalestax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChargebeforesalestaxName()));
    end;

    procedure Chargeaftersalestax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChargeaftersalestaxName()));
    end;

    procedure Discountsreceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DiscountsreceivedName()));
    end;

    procedure Iteminventoryadjustment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IteminventoryadjustmentName()));
    end;

    procedure Purchasevariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasevarianceName()));
    end;

    procedure Totalcostofgoodssold(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalcostofgoodssoldName()));
    end;

    procedure Projectcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProjectcostsName()));
    end;

    procedure Travelfee(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TravelfeeName()));
    end;

    procedure Materialcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaterialcostsName()));
    end;

    procedure Projecthours(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProjecthoursName()));
    end;

    procedure Adjustmentofwip(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdjustmentofwipName()));
    end;

    procedure MachineryRentalLeasingFee(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MachineryRentalLeasingFeeName()));
    end;

    procedure Jobcostsapplied(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobcostsappliedName()));
    end;

    procedure Totalprojectcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalprojectcostsName()));
    end;

    procedure Personnelcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PersonnelcostsName()));
    end;

    procedure Salariesvacationcompensation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalariesvacationcompensationName()));
    end;

    procedure Salariesproduction(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalariesproductionName()));
    end;

    procedure Directorsfee(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DirectorsfeeName()));
    end;

    procedure Anniversarygift(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AnniversarygiftName()));
    end;

    procedure Severancepay(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SeverancepayName()));
    end;

    procedure Pensioncompany(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PensioncompanyName()));
    end;

    procedure Labormarketpensioncompany(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LabormarketpensioncompanyName()));
    end;

    procedure Optionalpayaccountsavings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OptionalpayaccountsavingsName()));
    end;

    procedure Employeeartclub(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployeeartclubName()));
    end;

    procedure Giftfund(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GiftfundName()));
    end;

    procedure Lunch(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LunchName()));
    end;

    procedure Damaternitypaternityleavepremium(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DamaternitypaternityleavepremiumName()));
    end;

    procedure Atpemployee(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AtpemployeeName()));
    end;

    procedure Mileagerate(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MileagerateName()));
    end;

    procedure Refunds(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RefundsName()));
    end;

    procedure Atpemployer(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AtpemployerName()));
    end;

    procedure Projecthoursspent(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProjecthoursspentName()));
    end;

    procedure Projecthoursallocatedtooperatingresult(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProjecthoursallocatedtooperatingresultName()));
    end;

    procedure Consumptionforownproduction(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsumptionforownproductionName()));
    end;

    procedure Socialsecbenefitsalloctooperatingresult(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SocialsecbenefitsalloctooperatingresultName()));
    end;

    procedure Transferredssbstoproduction(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TransferredssbstoproductionName()));
    end;

    procedure Trainingexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TrainingexpensesName()));
    end;

    procedure Otherpersonnelcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherpersonnelcostsName()));
    end;

    procedure Totalpersonnelcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalpersonnelcostsName()));
    end;

    procedure Marketingcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MarketingcostsName()));
    end;

    procedure Advertisementsandcommercials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvertisementsandcommercialsName()));
    end;

    procedure Entwinetobaccospirits(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EntwinetobaccospiritsName()));
    end;

    procedure Entgiftsandflowers(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EntgiftsandflowersName()));
    end;

    procedure Travelingtradefairsetc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TravelingtradefairsetcName()));
    end;

    procedure Restaurantdining(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RestaurantdiningName()));
    end;

    procedure Decoration(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DecorationName()));
    end;

    procedure Totalmarketingcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalmarketingcostsName()));
    end;

    procedure Marketingcontributions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MarketingcontributionsName()));
    end;

    procedure Automobileoperationscars(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AutomobileoperationscarsName()));
    end;

    procedure RentalLeasingFeeMachine(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentalLeasingFeeMachineName()));
    end;

    procedure GasAutoMobile(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GasAutoMobileName()));
    end;

    procedure InsuranceCostOfWorkSpace(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsuranceCostOfWorkSpaceName()));
    end;

    procedure GasconsumptiontaxAutoMobile(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GasconsumptiontaxAutoMobileName()));
    end;

    procedure RepmaintenanceVans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RepmaintenanceVansName()));
    end;

    procedure FerryticketsbridgetollsAutoMobile(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FerryticketsbridgetollsAutoMobileName()));
    end;

    procedure Totalvehicleoperations(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalvehicleoperationsName()));
    end;

    procedure VansBeginTotalExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VansBeginTotalExpenseName()));
    end;

    procedure RentalLeasingFeeAutoMobile(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentalLeasingFeeAutoMobileName()));
    end;

    procedure GasVans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GasVansName()));
    end;

    procedure GasconsumptiontaxVans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GasconsumptiontaxVansName()));
    end;

    procedure InsurancesVans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesVansName()));
    end;

    procedure RepmaintenanceAutoMobile(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RepmaintenanceAutoMobileName()));
    end;

    procedure FerryticketsbridgetollsVans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FerryticketsbridgetollsVansName()));
    end;

    procedure VanstotalAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VanstotalAssetsName()));
    end;

    procedure Machines(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MachinesName()));
    end;

    procedure RentalLeasingFeeVans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentalLeasingFeeVansName()));
    end;

    procedure Machineoperatingcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MachineoperatingcostsName()));
    end;

    procedure Machrepairsandmaintenance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MachrepairsandmaintenanceName()));
    end;

    procedure Machineryinsurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MachineryinsuranceName()));
    end;

    procedure Machinestotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MachinestotalName()));
    end;

    procedure Costofofficeworkshopspace(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CostofofficeworkshopspaceName()));
    end;

    procedure Rent(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentName()));
    end;

    procedure InsuranceAutoMobile(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsuranceAutoMobileName()));
    end;

    procedure Electricity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ElectricityName()));
    end;

    procedure Water(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WaterName()));
    end;

    procedure Heating(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(HeatingName()));
    end;

    procedure Naturalgas(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NaturalgasName()));
    end;

    procedure TaxesBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxesBeginTotalName()));
    end;

    procedure Newacquisitions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NewacquisitionsName()));
    end;

    procedure Totalcostofofficeworkshopspace(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalcostofofficeworkshopspaceName()));
    end;

    procedure Administrativecosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdministrativecostsName()));
    end;

    procedure Phonescellphones(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PhonescellphonesName()));
    end;

    procedure Internetwebsite(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InternetwebsiteName()));
    end;

    procedure Newspapersmagazines(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NewspapersmagazinesName()));
    end;

    procedure Subscriptionsmembershipfees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubscriptionsmembershipfeesName()));
    end;

    procedure Officestationary(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OfficestationaryName()));
    end;

    procedure Postagefees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PostagefeesName()));
    end;

    procedure InsurancesAdminCost(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesAdminCostName()));
    end;

    procedure Minoracquisitions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MinoracquisitionsName()));
    end;

    procedure Conferenceexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConferenceexpensesName()));
    end;

    procedure Accountingcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountingcostsName()));
    end;

    procedure Auditingaccountingassistance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AuditingaccountingassistanceName()));
    end;

    procedure Lawyer(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LawyerName()));
    end;

    procedure Legalaid(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LegalaidName()));
    end;

    procedure Repairsandmaintenancefurnitureequipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RepairsandmaintenancefurnitureequipmentName()));
    end;

    procedure Itexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ItexpensesName()));
    end;

    procedure Salarycosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalarycostsName()));
    end;

    procedure FreightExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightExpenseName()));
    end;

    procedure Charges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ChargesName()));
    end;

    procedure Totaladministrativecosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotaladministrativecostsName()));
    end;

    procedure Totalcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalcostsName()));
    end;

    procedure Resbeforedepreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResbeforedepreciationName()));
    end;

    procedure DepreciationBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationBeginTotalName()));
    end;

    procedure VansBeginTotalAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VansBeginTotalAssetsName()));
    end;

    procedure CarsBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CarsBeginTotalName()));
    end;

    procedure Furnitureequipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FurnitureequipmentName()));
    end;

    procedure GoodwillBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodwillBeginTotalName()));
    end;

    procedure Totaldepreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotaldepreciationName()));
    end;

    procedure Resbeforefinancialitems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResbeforefinancialitemsName()));
    end;

    procedure Financialitems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialitemsName()));
    end;

    procedure Operatingincome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OperatingincomeName()));
    end;

    procedure BankinterestFinancalItems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankinterestFinancalItemsName()));
    end;

    procedure Accountsreceivableinterest(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsreceivableinterestName()));
    end;

    procedure Totaloperatingincome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotaloperatingincomeName()));
    end;

    procedure Financialexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialexpensesName()));
    end;

    procedure BankinterestFinancalExpesnse(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankinterestFinancalExpenseName()));
    end;

    procedure Accountspayableinterest(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountspayableinterestName()));
    end;

    procedure Accountspayablecharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountspayablechargesName()));
    end;

    procedure Additionalinterestexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdditionalinterestexpensesName()));
    end;

    procedure Centdiscrepancies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CentdiscrepanciesName()));
    end;

    procedure Disallowedinterestdeductions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DisallowedinterestdeductionsName()));
    end;

    procedure Totalfinancialexpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalfinancialexpensesName()));
    end;

    procedure Totalfinancialitems(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalfinancialitemsName()));
    end;

    procedure Resultbeforetax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResultbeforetaxName()));
    end;

    procedure TaxesCostOfWorkSpace(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxesCostOfWorkSpaceName()));
    end;

    procedure Taxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxesName()));
    end;

    procedure Totaltaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotaltaxesName()));
    end;

    procedure Periodearnings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PeriodearningsName()));
    end;

    procedure Balance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BalanceName()));
    end;

    procedure Goodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodwillName()));
    end;

    procedure Openingbalance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OpeningbalanceName()));
    end;

    procedure Depreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationName()));
    end;

    procedure Totalgoodwill(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalgoodwillName()));
    end;

    procedure Totalintangiblefixedassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalintangiblefixedassetsName()));
    end;

    procedure Financialfixedassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialfixedassetsName()));
    end;

    procedure Commonstock(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CommonstockName()));
    end;

    procedure Totalsecurities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalsecuritiesName()));
    end;

    procedure Totalfinancialfixedassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalfinancialfixedassetsName()));
    end;

    procedure AcquisitioncostLandBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitioncostLandBuildingsName()));
    end;

    procedure AdditionLandBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdditionLandBuildingsName()));
    end;

    procedure OutputLandBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OutputLandBuildingsName()));
    end;

    procedure AccdepreciationLandBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccdepreciationLandBuildingsName()));
    end;

    procedure DepreciationfortheyearLandBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationfortheyearLandBuilingsName()));
    end;

    procedure Totallandandbuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotallandandbuildingsName()));
    end;

    procedure Cars(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CarsName()));
    end;

    procedure AcquisitioncostCars(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitioncostCarsName()));
    end;

    procedure AdditionCars(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdditionCarsName()));
    end;

    procedure OutputCars(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OutputCarsName()));
    end;

    procedure AccdepreciationCars(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccdepreciationCarsName()));
    end;

    procedure DepreciationfortheyearCars(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationfortheyearCarsName()));
    end;

    procedure Carstotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CarstotalName()));
    end;

    procedure Vans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VansName()));
    end;

    procedure AcquisitioncostFurniture(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitioncostFurnitureName()));
    end;

    procedure AdditionVans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdditionVansName()));
    end;

    procedure OutputFurniture(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OutputFurnitureName()));
    end;

    procedure AccdepreciationVans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccdepreciationVansName()));
    end;

    procedure DepreciationfortheyearVans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationfortheyearVansName()));
    end;

    procedure VanstotalExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VanstotalExpenseName()));
    end;

    procedure AcquisitioncostOperatingEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitioncostOperatingEquipmentName()));
    end;

    procedure AdditionFurniture(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdditionFurnitureName()));
    end;

    procedure OutputVans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OutputVansName()));
    end;

    procedure AccdepreciationFurniture(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccdepreciationFurnitureName()));
    end;

    procedure DepreciationfortheyearFurniture(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationfortheyearFurnitureName()));
    end;

    procedure Totaloperatingequipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotaloperatingequipmentName()));
    end;

    procedure FurnitureequipmentBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FurnitureequipmentBeginTotalName()));
    end;

    procedure AcquisitioncostVans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AcquisitioncostVansName()));
    end;

    procedure AdditionOperatingEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdditionOperatingEquipmentName()));
    end;

    procedure OutputOperatingEquipments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OutputOperatingEquipmentsName()));
    end;

    procedure AccdepreciationOperating(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccdepreciationOperatingName()));
    end;

    procedure DepreciationfortheyearOperating(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationfortheyearOperatingName()));
    end;

    procedure Totalfurnitureequipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalfurnitureequipmentName()));
    end;

    procedure Totaltangiblefixedassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotaltangiblefixedassetsName()));
    end;

    procedure Inventoryadjustment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryadjustmentName()));
    end;

    procedure Itemreceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ItemreceivedName()));
    end;

    procedure Itemshipped(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ItemshippedName()));
    end;

    procedure InventoryPosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryPostingName()));
    end;

    procedure InventoryBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryBeginTotalName()));
    end;

    procedure AccountsPayablePosting(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsPayablePostingName()));
    end;

    procedure Totalinventory(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalinventoryName()));
    end;

    procedure Receivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceivablesName()));
    end;

    procedure Deferred(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferredName()));
    end;

    procedure PrepaymentsAccruedCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaymentsAccruedCostsName()));
    end;

    procedure Deposits(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepositsName()));
    end;

    procedure Depositstenancy(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepositstenancyName()));
    end;

    procedure Totaldeposits(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotaldepositsName()));
    end;

    procedure WorkinprocessBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WorkinprocessBeginTotalName()));
    end;

    procedure Workinprocess(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WorkinprocessName()));
    end;

    procedure Invoicedonaccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvoicedonaccountName()));
    end;

    procedure Totalworkinprocess(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalworkinprocessName()));
    end;

    procedure Totalreceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalreceivablesName()));
    end;

    procedure Cashflowfunds(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashflowfundsName()));
    end;

    procedure Checkout(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CheckoutName()));
    end;

    procedure Bank(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankName()));
    end;

    procedure Bankaccountcurrencies(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankaccountcurrenciesName()));
    end;

    procedure Totalcashflowfunds(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalcashflowfundsName()));
    end;

    procedure Totalcurrentassets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalcurrentassetsName()));
    end;

    procedure Equity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquityName()));
    end;

    procedure Openingequity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OpeningequityName()));
    end;

    procedure Retainedearningsfortheyear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RetainedearningsfortheyearName()));
    end;

    procedure Privatewithdrawalsetc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrivatewithdrawalsetcName()));
    end;

    procedure Paidbtaxeslabormarketcontribution(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaidbtaxeslabormarketcontributionName()));
    end;

    procedure Privatephoneusage(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrivatephoneusageName()));
    end;

    procedure Withdrawalforpersonaluse(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WithdrawalforpersonaluseName()));
    end;

    procedure Totalprivatewithdrawals(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalprivatewithdrawalsName()));
    end;

    procedure Equityatendofyear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquityatendofyearName()));
    end;

    procedure Mortgagedebt(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MortgagedebtName()));
    end;

    procedure Bankdebt(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankdebtName()));
    end;

    procedure Totallongtermliabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotallongtermliabilitiesName()));
    end;

    procedure Debttofinancialinstitution(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DebttofinancialinstitutionName()));
    end;

    procedure Totaldebttofinancialinstitution(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotaldebttofinancialinstitutionName()));
    end;

    procedure Salestaxandothertaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalestaxandothertaxesName()));
    end;

    procedure SalestaxpayableSalesTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalestaxpayableSalesTaxName()));
    end;

    procedure SalestaxreceivableInputTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalestaxreceivableInputTaxName()));
    end;

    procedure Salestaxonoverseaspurchases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalestaxonoverseaspurchasesName()));
    end;

    procedure Euacquisitiontax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EuacquisitiontaxName()));
    end;

    procedure Oiltax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OiltaxName()));
    end;

    procedure Salestaxsettlementaccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalestaxsettlementaccountName()));
    end;

    procedure Totalsalestax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalsalestaxName()));
    end;

    procedure Accruedtax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedtaxName()));
    end;

    procedure Additionalcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdditionalcostsName()));
    end;

    procedure PrepaymentsAccountsPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaymentsAccountsPayableName()));
    end;

    procedure Totalshorttermliabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalshorttermliabilitiesName()));
    end;

    procedure Totalaccountspayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalaccountspayableName()));
    end;

    procedure AccruedcostsBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedcostsBeginTotalName()));
    end;

    procedure Accruedcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedcostsName()));
    end;

    procedure Deferrals(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferralsName()));
    end;

    procedure PrepaymentsReceivables(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PrepaymentsReceivablesName()));
    end;

    procedure Totalaccruedcosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalaccruedcostsName()));
    end;

    procedure PayrollliabilitiesBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayrollliabilitiesBeginTotalName()));
    end;

    procedure Labormarketcontributionpayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LabormarketcontributionpayableName()));
    end;

    procedure Retirementplancontributionspayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RetirementplancontributionspayableName()));
    end;

    procedure Payrollliabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PayrollliabilitiesName()));
    end;

    procedure Totalpayrollliabilities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalpayrollliabilitiesName()));
    end;

    procedure Allnull(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AllnullName()));
    end;

    procedure AccountsPayableBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccountsPayableBeginTotalName()));
    end;

    procedure AccountsPayableBeginTotalName(): Text[100]
    begin
        exit(AccountsPayableBeginTotalLbl);
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        ProfitandlossstatementLbl: Label 'PROFIT AND LOSS STATEMENT', MaxLength = 100;
        DomesticsalesofgoodsandservicesLbl: Label 'Domestic Sales of Goods and Services', MaxLength = 100;
        EusalesofgoodsandservicesLbl: Label 'EU Sales of Goods and Services', MaxLength = 100;
        SalesofgoodsandservicestoothercountriesLbl: Label 'Sales of Goods and Services to other Countries', MaxLength = 100;
        FreightIncomeLbl: Label 'Freight-Income', MaxLength = 100;
        OnaccountinvoicingLbl: Label 'On-Account Invoicing', MaxLength = 100;
        ChargeexsalestaxLbl: Label 'Charge ex. Sales Tax', MaxLength = 100;
        ChargeinclsalestaxLbl: Label 'Charge incl. Sales Tax', MaxLength = 100;
        DiscountsgrantedLbl: Label 'Discounts Granted', MaxLength = 100;
        JobsalesappliedLbl: Label 'Job Sales Applied', MaxLength = 100;
        CostofgoodssoldBeginTotalLbl: Label 'COST OF GOODS SOLD BeginTotal', MaxLength = 100;
        CostofgoodssoldLbl: Label 'Cost of Goods Sold', MaxLength = 100;
        ItempurchasesLbl: Label 'Item Purchases', MaxLength = 100;
        MiscconsumptionLbl: Label 'Misc. Consumption', MaxLength = 100;
        ForeignlaborLbl: Label 'Foreign Labor', MaxLength = 100;
        FreightCostOfGoodsLbl: Label 'Freight-Cost Of Goods', MaxLength = 100;
        ProfitlossinventoryLbl: Label 'Profit & Loss Inventory', MaxLength = 100;
        ChargebeforesalestaxLbl: Label 'Charge before Sales Tax', MaxLength = 100;
        ChargeaftersalestaxLbl: Label 'Charge after Sales Tax', MaxLength = 100;
        DiscountsreceivedLbl: Label 'Discounts Received', MaxLength = 100;
        IteminventoryadjustmentLbl: Label 'Item Inventory Adjustment', MaxLength = 100;
        PurchasevarianceLbl: Label 'Purchase Variance', MaxLength = 100;
        TotalcostofgoodssoldLbl: Label 'TOTAL COST OF GOODS SOLD', MaxLength = 100;
        ProjectcostsLbl: Label 'PROJECT COSTS', MaxLength = 100;
        TravelfeeLbl: Label 'Travel Fee', MaxLength = 100;
        MaterialcostsLbl: Label 'Material Costs', MaxLength = 100;
        ProjecthoursLbl: Label 'Project Hours', MaxLength = 100;
        AdjustmentofwipLbl: Label 'Adjustment of WIP', MaxLength = 100;
        JobcostsappliedLbl: Label 'Job Costs Applied', MaxLength = 100;
        TotalprojectcostsLbl: Label 'TOTAL PROJECT COSTS', MaxLength = 100;
        PersonnelcostsLbl: Label 'PERSONNEL COSTS', MaxLength = 100;
        SalariesvacationcompensationLbl: Label 'Salaries, Vacation Compensation', MaxLength = 100;
        SalariesproductionLbl: Label 'Salaries, Production', MaxLength = 100;
        DirectorsfeeLbl: Label 'Director''s Fee', MaxLength = 100;
        AnniversarygiftLbl: Label 'Anniversary Gift', MaxLength = 100;
        SeverancepayLbl: Label 'Severance Pay', MaxLength = 100;
        PensioncompanyLbl: Label 'Pension, Company', MaxLength = 100;
        LabormarketpensioncompanyLbl: Label 'Labor Market Pension, Company', MaxLength = 100;
        OptionalpayaccountsavingsLbl: Label 'Optional Pay Account Savings', MaxLength = 100;
        EmployeeartclubLbl: Label 'Employee art club', MaxLength = 100;
        GiftfundLbl: Label 'Gift Fund', MaxLength = 100;
        LunchLbl: Label 'Lunch', MaxLength = 100;
        DamaternitypaternityleavepremiumLbl: Label 'DA - Maternity/Paternity Leave Premium', MaxLength = 100;
        AtpemployeeLbl: Label 'ATP, Employee', MaxLength = 100;
        MileagerateLbl: Label 'Mileage Rate', MaxLength = 100;
        RefundsLbl: Label 'Refunds', MaxLength = 100;
        AtpemployerLbl: Label 'ATP, Employer', MaxLength = 100;
        ProjecthoursspentLbl: Label 'Project Hours Spent', MaxLength = 100;
        ProjecthoursallocatedtooperatingresultLbl: Label 'Project Hours Allocated to Operating Result', MaxLength = 100;
        ConsumptionforownproductionLbl: Label 'Consumption for Own Production', MaxLength = 100;
        SocialsecbenefitsalloctooperatingresultLbl: Label 'Social Sec. Benefits Alloc. to Operating Result', MaxLength = 100;
        TransferredssbstoproductionLbl: Label 'Transferred SSBs to Production', MaxLength = 100;
        TrainingexpensesLbl: Label 'Training Expenses', MaxLength = 100;
        OtherpersonnelcostsLbl: Label 'Other Personnel Costs', MaxLength = 100;
        TotalpersonnelcostsLbl: Label 'TOTAL PERSONNEL COSTS', MaxLength = 100;
        MarketingcostsLbl: Label 'MARKETING COSTS', MaxLength = 100;
        AdvertisementsandcommercialsLbl: Label 'Advertisements and Commercials', MaxLength = 100;
        EntwinetobaccospiritsLbl: Label 'Ent., Wine / Tobacco / Spirits', MaxLength = 100;
        EntgiftsandflowersLbl: Label 'Ent., gifts and flowers', MaxLength = 100;
        TravelingtradefairsetcLbl: Label 'Traveling, Trade Fairs etc.', MaxLength = 100;
        RestaurantdiningLbl: Label 'Restaurant Dining', MaxLength = 100;
        DecorationLbl: Label 'Decoration', MaxLength = 100;
        TotalmarketingcostsLbl: Label 'TOTAL MARKETING COSTS', MaxLength = 100;
        MarketingcontributionsLbl: Label 'MARKETING CONTRIBUTIONS', MaxLength = 100;
        AutomobileoperationscarsLbl: Label 'AUTOMOBILE OPERATIONS, CARS', MaxLength = 100;
        RentalLeasingFeeAutoMobileLbl: Label 'Rental & Leasing Fee Auto Mobile', MaxLength = 100;
        GasAutoMobileLbl: Label 'Gas-Auto Mobile', MaxLength = 100;
        InsuranceAutoMobileLbl: Label 'Insurance Auto Mobile', MaxLength = 100;
        GasconsumptiontaxVansLbl: Label 'Gas Consumption Tax Vans', MaxLength = 100;
        RepmaintenanceVansLbl: Label 'Rep. & Maintenance Vans', MaxLength = 100;
        FerryticketsbridgetollsAutoMobileLbl: Label 'Ferry Tickets & Bridge Tolls Auto Mobile', MaxLength = 100;
        TotalvehicleoperationsLbl: Label 'TOTAL VEHICLE OPERATIONS', MaxLength = 100;
        VansLbl: Label 'VANS', MaxLength = 100;
        RentalLeasingFeeVansLbl: Label 'Rental & Leasing Fee Vans', MaxLength = 100;
        GasVansLbl: Label 'Gas - Vans', MaxLength = 100;
        GasconsumptiontaxAutoMobileLbl: Label 'Gas Consumption Tax - Auto Mobile', MaxLength = 100;
        InsurancesVansLbl: Label 'Insurances Vans', MaxLength = 100;
        RepmaintenanceAutoMobileLbl: Label 'Rep. & Maintenance Auto Mobile', MaxLength = 100;
        FerryticketsbridgetollsVansLbl: Label 'Ferry Tickets & Bridge Tolls Vans', MaxLength = 100;
        VanstotalExpenseLbl: Label 'VANS, TOTAL Expense', MaxLength = 100;
        MachinesLbl: Label 'MACHINES', MaxLength = 100;
        RentalLeasingFeeMachineLbl: Label 'Rental & Leasing Fee Machine', MaxLength = 100;
        MachineoperatingcostsLbl: Label 'Machine Operating Costs', MaxLength = 100;
        MachrepairsandmaintenanceLbl: Label 'Mach. Repairs and Maintenance', MaxLength = 100;
        MachineryinsuranceLbl: Label 'Machinery Insurance', MaxLength = 100;
        MachinestotalLbl: Label 'MACHINES, TOTAL', MaxLength = 100;
        CostofofficeworkshopspaceLbl: Label 'COST OF OFFICE & WORKSHOP SPACE', MaxLength = 100;
        RentLbl: Label 'Rent', MaxLength = 100;
        InsuranceCostOfWorkSpaceLbl: Label 'Insurance Cost Of WorkSpace', MaxLength = 100;
        ElectricityLbl: Label 'Electricity ', MaxLength = 100;
        WaterLbl: Label 'Water', MaxLength = 100;
        HeatingLbl: Label 'Heating', MaxLength = 100;
        NaturalgasLbl: Label 'Natural Gas', MaxLength = 100;
        TaxesCostOfWorkSpaceLbl: Label 'Taxes Cost Of WorkSpace', MaxLength = 100;
        NewacquisitionsLbl: Label 'New Acquisitions', MaxLength = 100;
        TotalcostofofficeworkshopspaceLbl: Label 'TOTAL COST OF OFFICE & WORKSHOP SPACE', MaxLength = 100;
        AdministrativecostsLbl: Label 'ADMINISTRATIVE COSTS', MaxLength = 100;
        PhonescellphonesLbl: Label 'Phones & Cell Phones', MaxLength = 100;
        InternetwebsiteLbl: Label 'Internet & Website', MaxLength = 100;
        NewspapersmagazinesLbl: Label 'Newspapers & Magazines', MaxLength = 100;
        SubscriptionsmembershipfeesLbl: Label 'Subscriptions & Membership Fees', MaxLength = 100;
        OfficestationaryLbl: Label 'Office Stationary', MaxLength = 100;
        PostagefeesLbl: Label 'Postage & Fees', MaxLength = 100;
        InsurancesAdminCostLbl: Label 'Insurances Administration Cost', MaxLength = 100;
        MinoracquisitionsLbl: Label 'Minor Acquisitions', MaxLength = 100;
        ConferenceexpensesLbl: Label 'Conference Expenses', MaxLength = 100;
        AccountingcostsLbl: Label 'Accounting Costs', MaxLength = 100;
        AuditingaccountingassistanceLbl: Label 'Auditing & Accounting Assistance', MaxLength = 100;
        LawyerLbl: Label 'Lawyer', MaxLength = 100;
        LegalaidLbl: Label 'Legal Aid', MaxLength = 100;
        RepairsandmaintenancefurnitureequipmentLbl: Label 'Repairs and Maintenance, Furniture & Equipment', MaxLength = 100;
        ItexpensesLbl: Label 'IT Expenses', MaxLength = 100;
        SalarycostsLbl: Label 'Salary Costs', MaxLength = 100;
        FreightExpenseLbl: Label 'Freight-Expense', MaxLength = 100;
        ChargesLbl: Label 'Charges', MaxLength = 100;
        TotaladministrativecostsLbl: Label 'TOTAL ADMINISTRATIVE COSTS', MaxLength = 100;
        TotalcostsLbl: Label 'TOTAL COSTS', MaxLength = 100;
        ResbeforedepreciationLbl: Label 'RES. BEFORE DEPRECIATION', MaxLength = 100;
        DepreciationBeginTotalLbl: Label 'DEPRECIATION - Begin Total', MaxLength = 100;
        VansBeginTotalExpenseLbl: Label 'Vans - Begin Total Expense ', MaxLength = 100;
        CarsLbl: Label 'Cars', MaxLength = 100;
        FurnitureequipmentLbl: Label 'Furniture & Equipment', MaxLength = 100;
        GoodwillLbl: Label 'Goodwill', MaxLength = 100;
        TotaldepreciationLbl: Label 'TOTAL DEPRECIATION', MaxLength = 100;
        ResbeforefinancialitemsLbl: Label 'RES. BEFORE FINANCIAL ITEMS', MaxLength = 100;
        FinancialitemsLbl: Label 'FINANCIAL ITEMS', MaxLength = 100;
        OperatingincomeLbl: Label 'OPERATING INCOME', MaxLength = 100;
        BankinterestFinancalItemsLbl: Label 'Bank Interest Financal Items', MaxLength = 100;
        AccountsreceivableinterestLbl: Label 'Accounts Receivable, Interest', MaxLength = 100;
        TotaloperatingincomeLbl: Label 'TOTAL OPERATING INCOME', MaxLength = 100;
        FinancialexpensesLbl: Label 'FINANCIAL EXPENSES', MaxLength = 100;
        BankinterestFinancalExpenseLbl: Label 'Bank Interest Financal Expense', MaxLength = 100;
        AccountspayableinterestLbl: Label 'Accounts Payable, Interest', MaxLength = 100;
        AccountspayablechargesLbl: Label 'Accounts Payable, Charges', MaxLength = 100;
        AdditionalinterestexpensesLbl: Label 'Additional Interest Expenses', MaxLength = 100;
        CentdiscrepanciesLbl: Label 'Cent Discrepancies', MaxLength = 100;
        DisallowedinterestdeductionsLbl: Label 'Disallowed Interest Deductions', MaxLength = 100;
        TotalfinancialexpensesLbl: Label 'TOTAL FINANCIAL EXPENSES', MaxLength = 100;
        TotalfinancialitemsLbl: Label 'TOTAL FINANCIAL ITEMS', MaxLength = 100;
        ResultbeforetaxLbl: Label 'RESULT BEFORE TAX', MaxLength = 100;
        TaxesBeginTotalLbl: Label 'TAXES Begin-Total', MaxLength = 100;
        TaxesLbl: Label 'Taxes', MaxLength = 100;
        TotaltaxesLbl: Label 'TOTAL TAXES', MaxLength = 100;
        PeriodearningsLbl: Label 'PERIOD EARNINGS', MaxLength = 100;
        BalanceLbl: Label 'BALANCE', MaxLength = 100;
        GoodwillBeginTotalLbl: Label 'GOODWILL - Begin Total', MaxLength = 100;
        OpeningbalanceLbl: Label 'Opening Balance', MaxLength = 100;
        DepreciationLbl: Label 'Depreciation', MaxLength = 100;
        TotalgoodwillLbl: Label 'TOTAL GOODWILL', MaxLength = 100;
        TotalintangiblefixedassetsLbl: Label 'TOTAL INTANGIBLE FIXED ASSETS', MaxLength = 100;
        FinancialfixedassetsLbl: Label 'FINANCIAL FIXED ASSETS', MaxLength = 100;
        CommonstockLbl: Label 'Common Stock', MaxLength = 100;
        TotalsecuritiesLbl: Label 'TOTAL SECURITIES', MaxLength = 100;
        TotalfinancialfixedassetsLbl: Label 'TOTAL FINANCIAL FIXED ASSETS', MaxLength = 100;
        AcquisitioncostLandBuildingsLbl: Label 'Acquisition Cost - LandBuildings', MaxLength = 100;
        AdditionLandBuildingsLbl: Label 'Addition - Land & Buildings', MaxLength = 100;
        OutputLandBuildingsLbl: Label 'Output - Land Buildings', MaxLength = 100;
        AccdepreciationLandBuildingsLbl: Label 'Acc. Depreciation - Land Buildings', MaxLength = 100;
        DepreciationfortheyearLandBuildingsLbl: Label 'Depreciation for the Year - Land Buildings', MaxLength = 100;
        TotallandandbuildingsLbl: Label 'TOTAL LAND AND BUILDINGS', MaxLength = 100;
        CarsBeginTotalLbl: Label 'CARS - Begin Total', MaxLength = 100;
        AcquisitioncostFurnitureLbl: Label 'Acquisition Cost - Furniture', MaxLength = 100;
        AdditionCarsLbl: Label 'Addition - Cars', MaxLength = 100;
        OutputFurnitureLbl: Label 'Output - Furniture', MaxLength = 100;
        AccdepreciationCarsLbl: Label 'Acc. Depreciation - Cars', MaxLength = 100;
        DepreciationfortheyearCarsLbl: Label 'Depreciation for the Year - Cars', MaxLength = 100;
        CarstotalLbl: Label 'CARS, TOTAL', MaxLength = 100;
        VansBeginTotalAssetsLbl: Label 'VANS - Begin Total Assets', MaxLength = 100;
        AcquisitioncostOperatingEquipmentLbl: Label 'Acquisition Cost - Operating Equipment', MaxLength = 100;
        AdditionVansLbl: Label 'Addition-Vans', MaxLength = 100;
        OutputOperatingEquipmentsLbl: Label 'Output - Operating Equipments', MaxLength = 100;
        AccdepreciationVansLbl: Label 'Acc. Depreciation - Vans', MaxLength = 100;
        DepreciationfortheyearVansLbl: Label 'Depreciation for the Year - Vans', MaxLength = 100;
        VanstotalAssetsLbl: Label 'VANS, TOTAL Assets', MaxLength = 100;
        AcquisitioncostVansLbl: Label 'Acquisition Cost Vans', MaxLength = 100;
        AdditionFurnitureLbl: Label 'Addition - Furniture', MaxLength = 100;
        OutputCarsLbl: Label 'Output - Cars', MaxLength = 100;
        AccdepreciationOperatingLbl: Label 'Acc. Depreciation - Operating', MaxLength = 100;
        DepreciationfortheyearFurnitureLbl: Label 'Depreciation for the Year - Furniture', MaxLength = 100;
        TotaloperatingequipmentLbl: Label 'TOTAL OPERATING EQUIPMENT', MaxLength = 100;
        FurnitureequipmentBeginTotalLbl: Label 'FURNITURE & EQUIPMENT Begin Total', MaxLength = 100;
        AcquisitioncostCarsLbl: Label 'Acquisition Cost Cars', MaxLength = 100;
        AdditionOperatingEquipmentLbl: Label 'Addition - Operating Equipments', MaxLength = 100;
        OutputVansLbl: Label 'Output - Vans', MaxLength = 100;
        AccdepreciationFurnitureLbl: Label 'Acc. Depreciation - Furniture', MaxLength = 100;
        DepreciationfortheyearOperatingLbl: Label 'Depreciation for the Year - Operating', MaxLength = 100;
        TotalfurnitureequipmentLbl: Label 'TOTAL FURNITURE & EQUIPMENT', MaxLength = 100;
        TotaltangiblefixedassetsLbl: Label 'TOTAL TANGIBLE FIXED ASSETS', MaxLength = 100;
        InventoryadjustmentLbl: Label 'Inventory Adjustment', MaxLength = 100;
        ItemreceivedLbl: Label 'Item Received', MaxLength = 100;
        ItemshippedLbl: Label 'Item Shipped', MaxLength = 100;
        TotalinventoryLbl: Label 'TOTAL INVENTORY', MaxLength = 100;
        ReceivablesLbl: Label 'RECEIVABLES', MaxLength = 100;
        DeferredLbl: Label 'Deferred', MaxLength = 100;
        PrepaymentsReceivablesLbl: Label 'Prepayments - Receivables', MaxLength = 100;
        DepositsLbl: Label 'DEPOSITS', MaxLength = 100;
        DepositstenancyLbl: Label 'Deposits, Tenancy', MaxLength = 100;
        TotaldepositsLbl: Label 'TOTAL DEPOSITS', MaxLength = 100;
        WorkinprocessBeginTotalLbl: Label 'WORK IN PROCESS', MaxLength = 100;
        WorkinprocessLbl: Label 'Work in Process', MaxLength = 100;
        InvoicedonaccountLbl: Label 'Invoiced On-Account', MaxLength = 100;
        TotalworkinprocessLbl: Label 'TOTAL WORK IN PROCESS', MaxLength = 100;
        TotalreceivablesLbl: Label 'TOTAL RECEIVABLES', MaxLength = 100;
        CashflowfundsLbl: Label 'CASHFLOW FUNDS', MaxLength = 100;
        CheckoutLbl: Label 'Checkout', MaxLength = 100;
        BankLbl: Label 'Bank', MaxLength = 100;
        BankaccountcurrenciesLbl: Label 'Bank Account CURRENCIES', MaxLength = 100;
        TotalcashflowfundsLbl: Label 'TOTAL CASHFLOW FUNDS', MaxLength = 100;
        TotalcurrentassetsLbl: Label 'TOTAL CURRENT ASSETS', MaxLength = 100;
        EquityLbl: Label 'EQUITY', MaxLength = 100;
        OpeningequityLbl: Label 'Opening Equity', MaxLength = 100;
        RetainedearningsfortheyearLbl: Label 'Retained Earnings for the Year', MaxLength = 100;
        PrivatewithdrawalsetcLbl: Label 'PRIVATE WITHDRAWALS ETC.', MaxLength = 100;
        PaidbtaxeslabormarketcontributionLbl: Label 'Paid B Taxes/Labor Market Contribution', MaxLength = 100;
        PrivatephoneusageLbl: Label 'Private Phone Usage', MaxLength = 100;
        WithdrawalforpersonaluseLbl: Label 'Withdrawal for Personal Use', MaxLength = 100;
        TotalprivatewithdrawalsLbl: Label 'TOTAL PRIVATE WITHDRAWALS', MaxLength = 100;
        EquityatendofyearLbl: Label 'EQUITY AT END OF YEAR', MaxLength = 100;
        MortgagedebtLbl: Label 'Mortgage Debt', MaxLength = 100;
        BankdebtLbl: Label 'Bank Debt', MaxLength = 100;
        InventoryLbl: Label 'Inventory', MaxLength = 100;
        InventoryBeginTotalLbl: Label 'Inventory - BeginTotal', MaxLength = 100;
        AccountsPayableLbl: Label 'Accounts Payables', MaxLength = 100;
        AccountsPayableBeginTotalLbl: Label 'Accounts Payable _ Begin Total', MaxLength = 100;
        TotallongtermliabilitiesLbl: Label 'TOTAL LONG-TERM LIABILITIES', MaxLength = 100;
        DebttofinancialinstitutionLbl: Label 'DEBT TO FINANCIAL INSTITUTION', MaxLength = 100;
        TotaldebttofinancialinstitutionLbl: Label 'TOTAL DEBT TO FINANCIAL INSTITUTION', MaxLength = 100;
        SalestaxandothertaxesLbl: Label 'SALES TAX AND OTHER TAXES', MaxLength = 100;
        SalestaxpayableSalesTaxLbl: Label 'Sales Tax Payable (Sales Tax)', MaxLength = 100;
        SalestaxreceivableInputTaxLbl: Label 'Sales Tax Receivable (Input Tax)', MaxLength = 100;
        SalestaxonoverseaspurchasesLbl: Label 'Sales Tax on Overseas Purchases', MaxLength = 100;
        EuacquisitiontaxLbl: Label 'EU Acquisition Tax', MaxLength = 100;
        OiltaxLbl: Label 'Oil Tax', MaxLength = 100;
        MachineryRentalLeasingFeeLbl: Label 'Machinery Rental & Leasing Fee', MaxLength = 100;
        SalestaxsettlementaccountLbl: Label 'Sales Tax Settlement Account', MaxLength = 100;
        TotalsalestaxLbl: Label 'TOTAL SALES TAX', MaxLength = 100;
        AccruedtaxLbl: Label 'Accrued Tax', MaxLength = 100;
        AdditionalcostsLbl: Label 'Additional Costs', MaxLength = 100;
        PrepaymentsAccountsPayableLbl: Label 'Prepayments - Accounts Payable', MaxLength = 100;
        TotalshorttermliabilitiesLbl: Label 'TOTAL SHORT-TERM LIABILITIES', MaxLength = 100;
        TotalaccountspayableLbl: Label 'TOTAL ACCOUNTS PAYABLE', MaxLength = 100;
        AccruedcostsBeginTotalLbl: Label 'ACCRUED COSTS', MaxLength = 100;
        AccruedcostsLbl: Label 'Accrued Costs', MaxLength = 100;
        DeferralsLbl: Label 'Deferrals', MaxLength = 100;
        PrepaymentsAccruedCostsLbl: Label 'Prepayments - Accrued Costs', MaxLength = 100;
        TotalaccruedcostsLbl: Label 'TOTAL ACCRUED COSTS', MaxLength = 100;
        PayrollliabilitiesBeginTotalLbl: Label 'PAYROLL LIABILITIES', MaxLength = 100;
        LabormarketcontributionpayableLbl: Label 'Labor Market Contribution Payable', MaxLength = 100;
        RetirementplancontributionspayableLbl: Label 'Retirement Plan Contributions Payable', MaxLength = 100;
        PayrollliabilitiesLbl: Label 'Payroll Liabilities', MaxLength = 100;
        TotalpayrollliabilitiesLbl: Label 'TOTAL PAYROLL LIABILITIES', MaxLength = 100;
        AllnullLbl: Label '***** ALL NULL *****', MaxLength = 100;
}