codeunit 10660 "Create NO GL Accounts"
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

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.CustomerDomesticName(), '2310');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.VendorDomesticName(), '5410');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesDomesticName(), '6110');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '7140');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '5611');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '5631');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '7270');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '7170');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '7270');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '7170');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.RawMaterialsName(), '2130');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchRawMatDomName(), '7210');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRawMatName(), '7270');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.InventoryAdjRetailName(), '7170');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResalesName(), '2110');
        if InventorySetup."Expected Cost Posting to G/L" then
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '2111')
        else
            ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.ResaleInterimName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '6700');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Mfg GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyManufacturingGLAccounts()
    var
        MfgGLAccount: Codeunit "Create Mfg GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '7700');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '7700');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '7820');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '7821');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '7822');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '7823');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '7824');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '2120');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '2150');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create FA GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyFixedAssetGLAccounts()
    var
        FAGLAccount: Codeunit "Create FA GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.IncreasesDuringTheYearName(), '1220');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DecreasesDuringTheYearName(), '1230');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.AccumDepreciationBuildingsName(), '1240');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.MiscellaneousName(), '8640');

        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.DepreciationEquipmentName(), '8820');
        ContosoGLAccount.AddAccountForLocalization(FAGLAccount.GainsAndLossesName(), '8840');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create HR GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyHumanResourcesGLAccounts()
    var
        HRGLAccount: Codeunit "Create HR GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(HRGLAccount.EmployeesPayableName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Job GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyJobGLAccounts()
    var
        JobGLAccount: Codeunit "Create Job GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPInvoicedSalesName(), '2212');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPJobCostsName(), '2231');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobSalesAppliedName(), '6190');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedSalesName(), '6620');

        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.JobCostsAppliedName(), '7180');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedCostsName(), '7620');
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccountforNO()
    begin
        ContosoGLAccount.AddAccountForLocalization(PersonnelExpensesNOName(), '4995');
        ModifyGLAccountForW1();
    end;

    local procedure ModifyGLAccountForW1()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT0Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EmployeesPayableName(), '');
        CreateGLAccountForLocalization();
    end;

    local procedure CreateGLAccountForLocalization();
    var
        GLAccountCategory: Record "G/L Account Category";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreatePostingGroupsNO: Codeunit "Create Posting Groups NO";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateVatPostingGroupNO: Codeunit "Create Vat Posting Groups NO";
        SubCategory: Text[80];
    begin
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LiabilitiesAndEquity(), CreateGLAccount.LiabilitiesAndEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Heading, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalLiabilitiesAndEquity(), CreateGLAccount.TotalLiabilitiesAndEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 0, CreateGLAccount.LiabilitiesAndEquity() + '..' + CreateGLAccount.TotalLiabilitiesAndEquity() + '|' + CreateGLAccount.IncomeStatement() + '..' + CreateGLAccount.NetIncome(), Enum::"General Posting Type"::" ", '', '', false, false, true);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.NetOperatingIncome(), CreateGLAccount.NetOperatingIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 0, CreateGLAccount.IncomeStatement() + '..' + CreateGLAccount.NetOperatingIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.NIBEFOREEXTRITEMSTAXES(), NetBeforeExtrTaxesExpensLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 0, CreateGLAccount.IncomeStatement() + '..' + CreateGLAccount.NIBEFOREEXTRITEMSTAXES(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.NetIncome(), CreateGLAccount.NetIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 0, CreateGLAccount.IncomeStatement() + '..' + CreateGLAccount.NetIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetPrepaidExpenses(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchasePrepayments(), CreateGLAccount.PurchasePrepaymentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', CreateVatPostingGroupNO.High(), false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCurrentLiabilities(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesPrepayments(), CreateGLAccount.SalesPrepaymentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', CreateVatPostingGroupNO.High(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesVAT25(), SalesVAT24Lbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesVAT10(), SalesVAT12Lbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RevolvingCredit(), OtherRevenueLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, true, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvAdjmtInterimRetail(), InvAdjmtInterimSalesLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Assets(), CreateGLAccount.AssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CurrentAssets(), LiquidAssetsLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalAssets(), CreateGLAccount.TotalAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Assets() + '..' + CreateGLAccount.TotalAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetDistrToShareholders(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Stockholder(), RetainedEarningsLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Heading, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Equity, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Allowances(), DeferredTaxesLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AllowancesTotal(), DeferredTaxesTotalLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Allowances() + '..' + CreateGLAccount.AllowancesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PersonnelExpensesNO(), PersonnelExpensesNOName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Expense, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SellingExpenses(), SellingAndPrExpensesLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalOperatingExpenses(), OtherCostsOfOperationsLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.OperatingExpenses() + '..' + CreateGLAccount.TotalOperatingExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.GainsandLosses(), LossOnClaimsLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OperatingExpenses(), CreateGLAccount.OperatingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Software(), CreateGLAccount.SoftwareName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ConsultantServices(), CreateGLAccount.ConsultantServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.Low(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherComputerExpenses(), CreateGLAccount.OtherComputerExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DeliveryExpenses(), EntertainmentDeductibleLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.GasolineandMotorOil(), ParkingLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherCostsofOperations(), CarAllowanceLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Travel(), CreateGLAccount.TravelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroupsNO.NoVatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RegistrationFees(), InsurancesLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroupsNO.NoVatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Income, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PmtDiscReceivedDecreases(), AdministrativeExpensesLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PmtTolReceivedDecreases(), SubsitenceLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InterestonBankBalances(), InterestIncomeLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Revenue(), CreateGLAccount.RevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinanceChargesfromCustomers(), CreateGLAccount.FinanceChargesfromCustomersName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroupsNO.NoVatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.Without(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvoiceRounding(), CreateGLAccount.InvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroupsNO.NoVatPostingGroup(), 0, '', Enum::"General Posting Type"::" ", CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.Without(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InterestIncome(), FinancialIncomeLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.UnrealizedFXGains(), CreateGLAccount.UnrealizedFXGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ExtraordinaryIncome(), CreateGLAccount.ExtraordinaryIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetEquipment(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FixedAssets(), CreateGLAccount.FixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.IncreasesduringtheYearBuildings(), CreateGLAccount.IncreasesduringtheYearBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DecreasesduringtheYearBuildings(), CreateGLAccount.DecreasesduringtheYearBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.CustDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVatPostingGroupNO.CUSTHIGH(), CreateVatPostingGroupNO.High(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.IncreasesduringtheYearOperEquip(), CreateGLAccount.IncreasesduringtheYearOperEquipName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DecreasesduringtheYearOperEquip(), CreateGLAccount.DecreasesduringtheYearOperEquipName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.CustDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVatPostingGroupNO.CUSTHIGH(), CreateVatPostingGroupNO.High(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.IncreasesduringtheYearVehicles(), CreateGLAccount.IncreasesduringtheYearVehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DecreasesduringtheYearVehicles(), CreateGLAccount.DecreasesduringtheYearVehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.CustDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVatPostingGroupNO.CUSTHIGH(), CreateVatPostingGroupNO.High(), false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetIncomeProdSales(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailDom(), CreateGLAccount.SalesRetailDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.CustDom(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVatPostingGroupNO.CUSTHIGH(), CreateVatPostingGroupNO.High(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailEU(), CreateGLAccount.SalesRetailEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.CustFor(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVatPostingGroupNO.CUSTNOVAT(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailExport(), CreateGLAccount.SalesRetailExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.CustFor(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVatPostingGroupNO.CUSTNOVAT(), CreateVatPostingGroupNO.High(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAppliedRetail(), JobSalesAdjmtRetailLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.CustFor(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVatPostingGroupNO.CUSTNOVAT(), CreateVatPostingGroupNO.High(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRawMaterialsDom(), CreateGLAccount.SalesRawMaterialsDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.CustDom(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVatPostingGroupNO.CUSTHIGH(), CreateVatPostingGroupNO.High(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRawMaterialsEU(), CreateGLAccount.SalesRawMaterialsEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.CustFor(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVatPostingGroupNO.CUSTNOVAT(), CreateVatPostingGroupNO.High(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRawMaterialsExport(), CreateGLAccount.SalesRawMaterialsExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.CustFor(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVatPostingGroupNO.CUSTNOVAT(), CreateVatPostingGroupNO.High(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAppliedRawMat(), JobSalesAdjmtRawMatLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.CustFor(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVatPostingGroupNO.CUSTNOVAT(), CreateVatPostingGroupNO.High(), false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetIncomeService(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAppliedResources(), JobSalesAdjmtResourcesLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesDom(), CreateGLAccount.SalesResourcesDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.CustDom(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVatPostingGroupNO.CUSTHIGH(), CreateVatPostingGroupNO.Low(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesEU(), CreateGLAccount.SalesResourcesEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.CustFor(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVatPostingGroupNO.CUSTNOVAT(), CreateVatPostingGroupNO.Low(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesExport(), CreateGLAccount.SalesResourcesExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.CustFor(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVatPostingGroupNO.CUSTNOVAT(), CreateVatPostingGroupNO.Low(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ConsultingFeesDom(), CreateGLAccount.ConsultingFeesDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.CustDom(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVatPostingGroupNO.CUSTHIGH(), CreateVatPostingGroupNO.Low(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FeesandChargesRecDom(), CreateGLAccount.FeesandChargesRecDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.CustDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVatPostingGroupNO.CUSTHIGH(), CreateVatPostingGroupNO.Low(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesOtherJobExpenses(), CreateGLAccount.SalesOtherJobExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', CreateVatPostingGroupNO.High(), true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCOGSMaterials(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRetailDom(), CreateGLAccount.PurchRetailDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRetailEU(), CreateGLAccount.PurchRetailEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendFor(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDNOVAT(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRetailExport(), CreateGLAccount.PurchRetailExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendFor(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDNOVAT(), CreateVatPostingGroupNO.High(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DeliveryExpensesRetail(), CreateGLAccount.DeliveryExpensesRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendFor(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDNOVAT(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRawMaterialsDom(), CreateGLAccount.PurchRawMaterialsDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRawMaterialsEU(), CreateGLAccount.PurchRawMaterialsEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendFor(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDNOVAT(), CreateVatPostingGroupNO.High(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRawMaterialsExport(), CreateGLAccount.PurchRawMaterialsExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendFor(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDNOVAT(), CreateVatPostingGroupNO.High(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DeliveryExpensesRawMat(), CreateGLAccount.DeliveryExpensesRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetUtilitiesExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Cleaning(), CreateGLAccount.CleaningName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ElectricityandHeating(), CreateGLAccount.ElectricityandHeatingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RepairsandMaintenance(), CreateGLAccount.RepairsandMaintenanceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OfficeSupplies(), CreateGLAccount.OfficeSuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PhoneandFax(), CreateGLAccount.PhoneandFaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Postage(), CreateGLAccount.PostageName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroupsNO.NoVatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.Without(), true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetAdvertisingExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Advertising(), SellingExpensesLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.EntertainmentandPR(), AdvertisingLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetRepairsExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RepairsandMaintenanceExpense(), CreateGLAccount.RepairsandMaintenanceExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetAR(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchaseVAT25EU(), SalesVAT6Lbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchaseVAT10EU(), PurchaseVAT6Lbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchaseVAT25(), PurchaseVAT24Lbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchaseVAT10(), PurchaseVAT12Lbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetInventory(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ResaleItems(), SaleItemsLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ResaleItemsInterim(), SaleItemsInterimLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostofResaleSoldInterim(), CostofGoodsSoldInterimLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCash(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.GiroAccount(), RevolvingCreditLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, true, false);

        SubCategory := Format(GLAccountCategoryMgt.GetRetEarnings(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RetainedEarnings(), StockholderSEquityLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Liabilities, 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Liabilities(), CreateGLAccount.LiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherLiabilitiesTotal(), OtherShortTermLiabTotalLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.OtherLiabilities() + '..' + CreateGLAccount.OtherLiabilitiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FuelTax(), GasolineAndMotorOilLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ElectricityTax(), GoodwillLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.NaturalGasTax(), PayrollTaxesPayableLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CoalTax(), TotalBldgMaintExpensesLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CO2Tax(), RegistrationFeesLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WaterTax(), CountyTaxLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VATPayable(), OtherPublicTaxesLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VATTotal(), OtherPublicTaxesTotalLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.VAT() + '..' + CreateGLAccount.VATTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetPayrollLiabilities(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PayrollTaxesPayable(), WithholdingDependAllowanceLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetIncomeSalesDiscounts(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DiscountGranted(), DiscountGrantedWithVatLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetOtherIncomeExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LegalandAccountingServices(), AuditingServicesLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Miscellaneous(), LegalServicesLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroupsNO.VendDom(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupNO.VENDHIGH(), CreateVatPostingGroupNO.High(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherOperatingExpenses(), ExternalServicesLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CashDiscrepancies(), OtherExternalServicesLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.BadDebtExpenses(), OtherConsultancyServicesLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherOperatingExpTotal(), ExternalServicesTotalLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.OtherOperatingExpenses() + '..' + CreateGLAccount.OtherOperatingExpTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetInterestExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PmtDiscGrantedDecreases(), CashDiscrepanciesLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PmtTolGrantedDecreases(), OperatingMaterialsLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
    end;

    procedure PersonnelExpensesNO(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PersonnelExpensesNOName()));
    end;

    procedure PersonnelExpensesNOName(): Text[100]
    begin
        exit(PersonnelExpensesNOLbl);
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        PersonnelExpensesNOLbl: Label 'Personnel Expenses NO', MaxLength = 100;
        SalesVAT24Lbl: Label 'Sales VAT 24 %', MaxLength = 100;
        SalesVAT12Lbl: Label 'Sales VAT 12 %', MaxLength = 100;
        SalesVAT6Lbl: Label 'Sales VAT 6 %', MaxLength = 100;
        PurchaseVAT6Lbl: Label 'Purchase VAT 6 %', MaxLength = 100;
        PurchaseVAT24Lbl: Label 'Purchase VAT 24 %', MaxLength = 100;
        PurchaseVAT12Lbl: Label 'Purchase VAT 12 %', MaxLength = 100;
        LiquidAssetsLbl: Label 'Liquid Assets', MaxLength = 100;
        SaleItemsLbl: Label 'Sales Items', MaxLength = 100;
        SaleItemsInterimLbl: Label 'Sales Items (Interim)', MaxLength = 100;
        CostofGoodsSoldInterimLbl: Label 'Cost of Goods Sold (Interim)', MaxLength = 100;
        RevolvingCreditLbl: Label 'Revolving Credit', MaxLength = 100;
        RetainedEarningsLbl: Label 'Retained Earnings', MaxLength = 100;
        StockholderSEquityLbl: Label 'Stockholders Equity', MaxLength = 100;
        DeferredTaxesLbl: Label 'Deferred Taxes', MaxLength = 100;
        DeferredTaxesTotalLbl: Label 'Deferred Taxes, Total', MaxLength = 100;
        OtherRevenueLbl: Label 'Other Revenue', MaxLength = 100;
        InvAdjmtInterimSalesLbl: Label 'Inv. Adjmt. (Interim), Sales', MaxLength = 100;
        GasolineAndMotorOilLbl: Label 'Gasoline and Motor Oil', MaxLength = 100;
        GoodwillLbl: Label 'Goodwill', MaxLength = 100;
        PayrollTaxesPayableLbl: Label 'Payroll Taxes Payable', MaxLength = 100;
        TotalBldgMaintExpensesLbl: Label 'Total Bldg. Maint. Expenses', MaxLength = 100;
        RegistrationFeesLbl: Label 'Registration Fees', MaxLength = 100;
        CountyTaxLbl: Label 'County Tax', MaxLength = 100;
        OtherPublicTaxesLbl: Label 'Other Public Taxes', MaxLength = 100;
        OtherPublicTaxesTotalLbl: Label 'Other Public Taxes, Total', MaxLength = 100;
        WithholdingDependAllowanceLbl: Label 'Withholding Depend. Allowance', MaxLength = 100;
        OtherShortTermLiabTotalLbl: Label 'Other Short-term Liab., Total', MaxLength = 100;
        JobSalesAdjmtRetailLbl: Label 'Job Sales Adjmt., Retail', MaxLength = 100;
        JobSalesAdjmtRawMatLbl: Label 'Job Sales Adjmt., Raw Mat.', MaxLength = 100;
        JobSalesAdjmtResourcesLbl: Label 'Job Sales Adjmt., Resources', MaxLength = 100;
        DiscountGrantedWithVatLbl: Label 'Discount granted (with vat)', MaxLength = 100;
        SellingAndPrExpensesLbl: Label 'Selling and PR Expenses', MaxLength = 100;
        SellingExpensesLbl: Label 'Selling Expenses', MaxLength = 100;
        AdvertisingLbl: Label 'Advertising', MaxLength = 100;
        EntertainmentDeductibleLbl: Label 'Entertainment, Deductible', MaxLength = 100;
        ParkingLbl: Label 'Parking', MaxLength = 100;
        InsurancesLbl: Label 'Insurances', MaxLength = 100;
        ExternalServicesLbl: Label 'External Services', MaxLength = 100;
        OtherExternalServicesLbl: Label 'Other External Services', MaxLength = 100;
        OtherConsultancyServicesLbl: Label 'Other Consultancy Services', MaxLength = 100;
        AuditingServicesLbl: Label 'Auditing Services', MaxLength = 100;
        LegalServicesLbl: Label 'Legal Services', MaxLength = 100;
        ExternalServicesTotalLbl: Label 'External Services, Total', MaxLength = 100;
        OtherCostsOfOperationsLbl: Label 'Other Costs of Operations', MaxLength = 100;
        LossOnClaimsLbl: Label 'Loss on Claims', MaxLength = 100;
        CarAllowanceLbl: Label 'Car Allowance', MaxLength = 100;
        FinancialIncomeLbl: Label 'Financial Income', MaxLength = 100;
        InterestIncomeLbl: Label 'Interest Income', MaxLength = 100;
        AdministrativeExpensesLbl: Label 'Administrative Expenses', MaxLength = 100;
        SubsitenceLbl: Label 'Subsitence', MaxLength = 100;
        CashDiscrepanciesLbl: Label 'Cash Discrepancies', MaxLength = 100;
        OperatingMaterialsLbl: Label 'Operating Materials', MaxLength = 100;
        NetBeforeExtrTaxesExpensLbl: Label 'Net Before Extr. Taxes/Expens.', MaxLength = 100;
}