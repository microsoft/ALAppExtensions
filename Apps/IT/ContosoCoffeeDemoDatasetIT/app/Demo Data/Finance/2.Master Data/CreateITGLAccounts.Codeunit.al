codeunit 12164 "Create IT GL Accounts"
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
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseDomesticName(), '7110');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '5610');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '5630');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '7291');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '7191');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRawMatName(), '7292');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '7192');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '7293');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '7193');

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
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '7791');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '7792');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '7793');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '7890');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '7891');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '7892');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '7893');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '7894');

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.FinishedGoodsName(), '2120');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '2140');
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
        ContosoGLAccount.AddAccountForLocalization(HRGLAccount.EmployeesPayableName(), '5730');
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
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPInvoicedSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.WIPJobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(JobGLAccount.RecognizedCostsName(), '');

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccountforIT()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SummaryAccountName(), '010000');
        ContosoGLAccount.AddAccountForLocalization(BalanceName(), '010010');
        ContosoGLAccount.AddAccountForLocalization(OpeningBalanceName(), '010011');
        ContosoGLAccount.AddAccountForLocalization(ClosingBalanceName(), '010012');
        ContosoGLAccount.AddAccountForLocalization(BalanceSheetTotalName(), '010099');
        ContosoGLAccount.AddAccountForLocalization(GainLossName(), '010111');
        ContosoGLAccount.AddAccountForLocalization(IncomeStatementTotalName(), '010199');
        ContosoGLAccount.AddAccountForLocalization(SummaryAccountTotalName(), '010999');
        ContosoGLAccount.AddAccountForLocalization(VendorPrepaymentsVat20PercName(), '2430');
        ContosoGLAccount.AddAccountForLocalization(WIPJobSalesAssetsName(), '2211');
        ContosoGLAccount.AddAccountForLocalization(BillsName(), '2450');
        ContosoGLAccount.AddAccountForLocalization(BillsForCollectionName(), '2460');
        ContosoGLAccount.AddAccountForLocalization(BillsForDiscountName(), '2470');
        ContosoGLAccount.AddAccountForLocalization(BillsSubjToCollName(), '2480');
        ContosoGLAccount.AddAccountForLocalization(ExpenseBillsName(), '2490');
        ContosoGLAccount.AddAccountForLocalization(BillsTotalName(), '2499');
        ContosoGLAccount.AddAccountForLocalization(GainForTheYearName(), '3130');
        ContosoGLAccount.AddAccountForLocalization(LossForTheYearName(), '3140');
        ContosoGLAccount.AddAccountForLocalization(JobSalesAppliedName(), '40450');
        ContosoGLAccount.AddAccountForLocalization(JobCostsAppliedName(), '50399');
        ContosoGLAccount.AddAccountForLocalization(CustomerPrepaymentsVat20PercName(), '5380');
        ContosoGLAccount.AddAccountForLocalization(SalesVat20PercName(), '5610');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVat20PercEuName(), '5620');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVat20PercName(), '5630');
        ContosoGLAccount.AddAccountForLocalization(IncomeStatementBeginTotalName(), '010100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncomeStatementName(), '6000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WIPJobSalesName(), '10910');
        ContosoGLAccount.AddAccountForLocalization(InvoicedJobSalesAssetsName(), '10920');
        ContosoGLAccount.AddAccountForLocalization(AccruedJobCostsAssetsName(), '10940');
        ContosoGLAccount.AddAccountForLocalization(WIPJobCostsAssetsName(), '10950');
        ContosoGLAccount.AddAccountForLocalization(JobSalesIncomeName(), '40250');
        ContosoGLAccount.AddAccountForLocalization(JobCostsIncomeName(), '50300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVAT25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT25EUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT25Name(), '');

        CreateGLAccountForLocalization();
    end;

    local procedure CreateGLAccountForLocalization()
    var
        GLAccountCategory: Record "G/L Account Category";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        CreateGLAccount: Codeunit "Create G/L Account";
        SubCategory: Text[80];
    begin
        ContosoGLAccount.SetOverwriteData(true);
        ContosoGLAccount.InsertGLAccount(SummaryAccount(), SummaryAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Balance(), BalanceName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetRetEarnings(), 80);
        ContosoGLAccount.InsertGLAccount(OpeningBalance(), OpeningBalanceName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ClosingBalance(), ClosingBalanceName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BalanceSheetTotal(), BalanceSheetTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::"End-Total", '', '', 0, '010010..010099', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GainLoss(), GainLossName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeStatementTotal(), IncomeStatementTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::"End-Total", '', '', 0, '010100..010199', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SummaryAccountTotal(), SummaryAccountTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::"End-Total", '', '', 0, '010000..010999', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetPrepaidExpenses(), 80);
        ContosoGLAccount.InsertGLAccount(VendorPrepaymentsVat20Perc(), VendorPrepaymentsVat20PercName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', CreateVATPostingGroups.Standard(), false, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetCurrentAssets(), 80);
        ContosoGLAccount.InsertGLAccount(Bills(), BillsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BillsForCollection(), BillsForCollectionName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BillsForDiscount(), BillsForDiscountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BillsSubjToColl(), BillsSubjToCollName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ExpenseBills(), ExpenseBillsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BillsTotal(), BillsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, '2450..2499', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetRetEarnings(), 80);
        ContosoGLAccount.InsertGLAccount(GainForTheYear(), GainForTheYearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LossForTheYear(), LossForTheYearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetJobSalesContra(), 80);
        ContosoGLAccount.InsertGLAccount(JobSalesApplied(), JobSalesAppliedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetOtherIncomeExpense(), 80);
        ContosoGLAccount.InsertGLAccount(JobCostsApplied(), JobCostsAppliedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetCurrentLiabilities(), 80);
        ContosoGLAccount.InsertGLAccount(CustomerPrepaymentsVat20Perc(), CustomerPrepaymentsVat20PercName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', CreateVATPostingGroups.Standard(), false, false, false);
        ContosoGLAccount.InsertGLAccount(SalesVat20Perc(), SalesVat20PercName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetAR(), 80);
        ContosoGLAccount.InsertGLAccount(PurchaseVat20PercEu(), PurchaseVat20PercEuName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVat20Perc(), PurchaseVat20PercName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeStatementBeginTotal(), IncomeStatementBeginTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Assets);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WIPJobSales(), CreateGLAccount.WIPJobSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InvoicedJobSalesAssets(), InvoicedJobSalesAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AccruedJobCostsAssets(), AccruedJobCostsAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WIPJobCostsAssets(), WIPJobCostsAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WIPJobSalesAssets(), WIPJobSalesAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetPrepaidExpenses(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchasePrepaymentsTotal(), CreateGLAccount.PurchasePrepaymentsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.PurchasePrepayments() + '..' + CreateGLAccount.PurchasePrepaymentsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetIncomeJobs(), 80);
        ContosoGLAccount.InsertGLAccount(JobSalesIncome(), JobSalesIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        SubCategory := Format(GLAccountCategoryMgt.GetJobsCost(), 80);
        ContosoGLAccount.InsertGLAccount(JobCostsIncome(), JobCostsIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        ContosoGLAccount.SetOverwriteData(false);

        UpdateAPIAccountTypeAndDirectPostingOnGL();
        UpdateDebitCreditOnGL();
    end;

    procedure IncomeStatementBeginTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeStatementBeginTotalName()));
    end;

    procedure IncomeStatementBeginTotalName(): Text[100]
    begin
        exit(IncomeStatementBeginTotalLbl);
    end;

    procedure SummaryAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SummaryAccountName()));
    end;

    procedure SummaryAccountName(): Text[100]
    begin
        exit(SummaryAccountTok);
    end;

    procedure Balance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BalanceName()));
    end;

    procedure BalanceName(): Text[100]
    begin
        exit(BalanceTok);
    end;

    procedure OpeningBalance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OpeningBalanceName()));
    end;

    procedure OpeningBalanceName(): Text[100]
    begin
        exit(OpeningBalanceTok);
    end;

    procedure ClosingBalance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ClosingBalanceName()));
    end;

    procedure ClosingBalanceName(): Text[100]
    begin
        exit(ClosingBalanceTok);
    end;

    procedure BalanceSheetTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BalanceSheetTotalName()));
    end;

    procedure BalanceSheetTotalName(): Text[100]
    begin
        exit(BalanceSheetTotalTok);
    end;

    procedure GainLoss(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainLossName()));
    end;

    procedure GainLossName(): Text[100]
    begin
        exit(GainLossTok);
    end;

    procedure IncomeStatementTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeStatementTotalName()));
    end;

    procedure IncomeStatementTotalName(): Text[100]
    begin
        exit(IncomeStatementTotalTok);
    end;

    procedure SummaryAccountTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SummaryAccountTotalName()));
    end;

    procedure SummaryAccountTotalName(): Text[100]
    begin
        exit(SummaryAccountTotalTok);
    end;

    procedure VendorPrepaymentsVat20Perc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorPrepaymentsVat20PercName()));
    end;

    procedure VendorPrepaymentsVat20PercName(): Text[100]
    begin
        exit(VendorPrepaymentsVat20PercTok);
    end;

    procedure Bills(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BillsName()));
    end;

    procedure BillsName(): Text[100]
    begin
        exit(BillsTok);
    end;

    procedure BillsForCollection(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BillsForCollectionName()));
    end;

    procedure BillsForCollectionName(): Text[100]
    begin
        exit(BillsForCollectionTok);
    end;

    procedure BillsForDiscount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BillsForDiscountName()));
    end;

    procedure BillsForDiscountName(): Text[100]
    begin
        exit(BillsForDiscountTok);
    end;

    procedure BillsSubjToColl(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BillsSubjToCollName()));
    end;

    procedure BillsSubjToCollName(): Text[100]
    begin
        exit(BillsSubjToCollTok);
    end;

    procedure ExpenseBills(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExpenseBillsName()));
    end;

    procedure ExpenseBillsName(): Text[100]
    begin
        exit(ExpenseBillsTok);
    end;

    procedure BillsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BillsTotalName()));
    end;

    procedure BillsTotalName(): Text[100]
    begin
        exit(BillsTotalTok);
    end;

    procedure GainForTheYear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainForTheYearName()));
    end;

    procedure GainForTheYearName(): Text[100]
    begin
        exit(GainForTheYearTok);
    end;

    procedure LossForTheYear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LossForTheYearName()));
    end;

    procedure LossForTheYearName(): Text[100]
    begin
        exit(LossForTheYearTok);
    end;

    procedure JobSalesApplied(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobSalesAppliedName()));
    end;

    procedure JobSalesAppliedName(): Text[100]
    begin
        exit(JobSalesAppliedTok);
    end;

    procedure JobCostsApplied(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostsAppliedName()));
    end;

    procedure JobCostsAppliedName(): Text[100]
    begin
        exit(JobCostsAppliedTok);
    end;

    procedure CustomerPrepaymentsVat20Perc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerPrepaymentsVat20PercName()));
    end;

    procedure CustomerPrepaymentsVat20PercName(): Text[100]
    begin
        exit(CustomerPrepaymentsVat20PercTok);
    end;

    procedure SalesVat20Perc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesVat20PercName()));
    end;

    procedure SalesVat20PercName(): Text[100]
    begin
        exit(SalesVat20PercTok);
    end;

    procedure PurchaseVat20PercEu(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVat20PercEuName()));
    end;

    procedure PurchaseVat20PercEuName(): Text[100]
    begin
        exit(PurchaseVat20PercEuTok);
    end;

    procedure PurchaseVat20Perc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVat20PercName()));
    end;

    procedure PurchaseVat20PercName(): Text[100]
    begin
        exit(PurchaseVat20PercTok);
    end;

    procedure WIPJobSalesAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPJobSalesAssetsName()));
    end;

    procedure WIPJobSalesAssetsName(): Text[100]
    begin
        exit(WIPJobSalesAssetsTok);
    end;

    procedure AccruedJobCostsAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AccruedJobCostsAssetsName()));
    end;

    procedure AccruedJobCostsAssetsName(): Text[100]
    begin
        exit(AccruedJobCostsAssetsTok);
    end;

    procedure InvoicedJobSalesAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvoicedJobSalesAssetsName()));
    end;

    procedure InvoicedJobSalesAssetsName(): Text[100]
    begin
        exit(InvoicedJobSalesAssetsTok);
    end;

    procedure WIPJobCostsAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPJobCostsAssetsName()));
    end;

    procedure WIPJobCostsAssetsName(): Text[100]
    begin
        exit(WIPJobCostsAssetsTok);
    end;

    procedure JobSalesIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobSalesIncomeName()));
    end;

    procedure JobSalesIncomeName(): Text[100]
    begin
        exit(JobSalesIncomeTok);
    end;

    procedure JobCostsIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostsIncomeName()));
    end;

    procedure JobCostsIncomeName(): Text[100]
    begin
        exit(JobCostsIncomeTok);
    end;

    local procedure UpdateDebitCreditOnGL()
    var
        GLAccount: Record "G/L Account";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        UpdateDebitCreditOnGLAccount(CreateGLAccount.WIPJobSales(), GLAccount."Debit/Credit"::Debit);
        UpdateDebitCreditOnGLAccount(InvoicedJobSalesAssets(), GLAccount."Debit/Credit"::Debit);
        UpdateDebitCreditOnGLAccount(AccruedJobCostsAssets(), GLAccount."Debit/Credit"::Debit);
        UpdateDebitCreditOnGLAccount(JobSalesIncome(), GLAccount."Debit/Credit"::Credit);
        UpdateDebitCreditOnGLAccount(JobSalesApplied(), GLAccount."Debit/Credit"::Debit);
        UpdateDebitCreditOnGLAccount(JobCostsIncome(), GLAccount."Debit/Credit"::Debit);
        UpdateDebitCreditOnGLAccount(JobCostsApplied(), GLAccount."Debit/Credit"::Credit);
        UpdateDebitCreditOnGLAccount(WIPJobCostsAssets(), GLAccount."Debit/Credit"::Debit);
    end;

    local procedure UpdateDebitCreditOnGLAccount(GLAccountNo: Code[20]; DebitCredit: Option)
    var
        GLAccount: Record "G/L Account";
    begin
        GlAccount.Get(GLAccountNo);

        GLAccount.Validate("Debit/Credit", DebitCredit);
        GLAccount.Modify(true);
    end;

    local procedure UpdateAPIAccountTypeAndDirectPostingOnGL()
    begin
        UpdateAPIAccountTypeAndDirectPostingOnGLAccount(SummaryAccount(), Enum::"G/L Account Type"::Posting, true);
        UpdateAPIAccountTypeAndDirectPostingOnGLAccount(Balance(), Enum::"G/L Account Type"::Posting, true);
        UpdateAPIAccountTypeAndDirectPostingOnGLAccount(BalanceSheetTotal(), Enum::"G/L Account Type"::Posting, true);
        UpdateAPIAccountTypeAndDirectPostingOnGLAccount(IncomeStatementBeginTotal(), Enum::"G/L Account Type"::Posting, true);
        UpdateAPIAccountTypeAndDirectPostingOnGLAccount(IncomeStatementTotal(), Enum::"G/L Account Type"::Posting, true);
        UpdateAPIAccountTypeAndDirectPostingOnGLAccount(SummaryAccountTotal(), Enum::"G/L Account Type"::Posting, true);
        UpdateAPIAccountTypeAndDirectPostingOnGLAccount(Bills(), Enum::"G/L Account Type"::Posting, true);
        UpdateAPIAccountTypeAndDirectPostingOnGLAccount(BillsTotal(), Enum::"G/L Account Type"::Posting, true);
    end;

    local procedure UpdateAPIAccountTypeAndDirectPostingOnGLAccount(GLAccountNo: Code[20]; APIAccountType: Enum "G/L Account Type"; DirectPosting: Boolean)
    var
        GLAccount: Record "G/L Account";
    begin
        GlAccount.Get(GLAccountNo);

        GLAccount.Validate("API Account Type", APIAccountType);
        GLAccount.Validate("Direct Posting", DirectPosting);
        GLAccount.Modify(true);
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        SummaryAccountTok: Label 'Summary Account', MaxLength = 100;
        BalanceTok: Label 'Balance', MaxLength = 100;
        OpeningBalanceTok: Label 'Opening Balance', MaxLength = 100;
        ClosingBalanceTok: Label 'Closing Balance', MaxLength = 100;
        BalanceSheetTotalTok: Label 'Balance Sheet Total', MaxLength = 100;
        GainLossTok: Label 'Gain/Loss', MaxLength = 100;
        IncomeStatementTotalTok: Label 'Income Statement Total', MaxLength = 100;
        SummaryAccountTotalTok: Label 'Summary Account Total', MaxLength = 100;
        VendorPrepaymentsVat20PercTok: Label 'Vendor Prepayments VAT 20 %', MaxLength = 100;
        BillsTok: Label 'Bills', MaxLength = 100;
        BillsForCollectionTok: Label 'Bills for Collection', MaxLength = 100;
        BillsForDiscountTok: Label 'Bills for Discount', MaxLength = 100;
        BillsSubjToCollTok: Label 'Bills Subj. to Coll.', MaxLength = 100;
        ExpenseBillsTok: Label 'Expense Bills', MaxLength = 100;
        BillsTotalTok: Label 'Bills Total', MaxLength = 100;
        GainForTheYearTok: Label 'Gain for the Year', MaxLength = 100;
        LossForTheYearTok: Label 'Loss for the Year', MaxLength = 100;
        JobSalesAppliedTok: Label 'Job Sales Applied', MaxLength = 100;
        JobCostsAppliedTok: Label 'Job Costs Applied', MaxLength = 100;
        CustomerPrepaymentsVat20PercTok: Label 'Customer Prepayments VAT 20 %', MaxLength = 100;
        SalesVat20PercTok: Label 'Sales VAT 20 %', MaxLength = 100;
        PurchaseVat20PercEuTok: Label 'Purchase VAT 20 % EU', MaxLength = 100;
        PurchaseVat20PercTok: Label 'Purchase VAT 20 %', MaxLength = 100;
        IncomeStatementBeginTotalLbl: Label 'Income Statement, Begin Total', MaxLength = 100;
        WIPJobSalesAssetsTok: Label 'WIP Job Sales, Assets', MaxLength = 100;
        AccruedJobCostsAssetsTok: Label 'Accrued Job Costs, Assets', MaxLength = 100;
        InvoicedJobSalesAssetsTok: Label 'Invoiced Job Sales, Assets', MaxLength = 100;
        WIPJobCostsAssetsTok: Label 'WIP Job Costs, Assets', MaxLength = 100;
        JobSalesIncomeTok: Label 'Job Sales, Income', MaxLength = 100;
        JobCostsIncomeTok: Label 'Job Costs, Income', MaxLength = 100;
}