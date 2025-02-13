codeunit 17105 "Create NZ GL Accounts"
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

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.SalesVATStandardName(), '5615');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVATStandardName(), '5625');

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

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.DirectCostAppliedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.OverheadAppliedRetailName(), '');

        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CommonGLAccount.PurchaseVarianceRetailName(), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Svc GL Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyServiceGLAccounts()
    var
        SvcGLAccount: Codeunit "Create Svc GL Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '6700');
        ContosoGLAccount.AddAccountForLocalization(SvcGLAccount.ServiceContractSaleName(), '');
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

        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.WIPAccountFinishedGoodsName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.DirectCostAppliedCapName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.OverheadAppliedCapName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.PurchaseVarianceCapName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MaterialVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapacityVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.SubcontractedVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.CapOverheadVarianceName(), '');
        ContosoGLAccount.AddAccountForLocalization(MfgGLAccount.MfgOverheadVarianceName(), '');
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
        ContosoGLAccount.AddAccountForLocalization(HRGLAccount.EmployeesPayableName(), '5850');
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
    local procedure ModifyGLAccountforNZ()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(SalesVAT15PercName(), '5615');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVAT15PercName(), '5625');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FuelTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NaturalGasTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CoalTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CO2TaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WaterTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailEUName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsEUName(), '');

        CreateGLAccountForLocalization();
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateVatInGLAccount(var Rec: Record "G/L Account")
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateNZVATPostingGroup: Codeunit "Create NZ VAT Posting Group";
    begin
        if Rec."VAT Prod. Posting Group" = CreateVATPostingGroups.Standard() then
            Rec.Validate("VAT Prod. Posting Group", CreateNZVATPostingGroup.VAT15());

        if Rec."VAT Prod. Posting Group" = CreateVATPostingGroups.Reduced() then
            Rec.Validate("VAT Prod. Posting Group", CreateNZVATPostingGroup.VAT9());
    end;

    local procedure CreateGLAccountForLocalization()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateNZVATPostingGroup: Codeunit "Create NZ VAT Posting Group";
    begin
        ContosoGLAccount.InsertGLAccount(SalesVAT15Perc(), SalesVAT15PercName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseVAT15Perc(), PurchaseVAT15PercName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorPrepaymentsVAT10(), VendorPrepaymentsVAT9PercLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', CreateNZVATPostingGroup.VAT9(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorPrepaymentsVAT25(), VendorPrepaymentsVAT15PercLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', CreateNZVATPostingGroup.VAT15(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CustomerPrepaymentsVAT10(), CustomerPrepaymentsVAT9Lbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', CreateNZVATPostingGroup.VAT9(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CustomerPrepaymentsVAT25(), CustomerPrepaymentsVAT15Lbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', CreateNZVATPostingGroup.VAT15(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesVAT25(), SalesVAT15PercPostingLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesVAT10(), SalesVAT9PercLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchaseVAT25EU(), PurchaseVAT15PercPostingLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchaseVAT10EU(), PurchaseVAT9PercLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchaseVAT25(), SalesVAT15PercAssetsLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VATPayable(), TaxPayableLbl, Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DeliveryExpensesRetail(), FreightExpensesRetailLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.VAT15(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DeliveryExpensesRawMat(), FreightExpensesRawMatLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.VAT15(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DeliveryExpenses(), FreightExpensesRawMatPostingLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.VAT15(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VacationCompensation(), AnnualLeaveExpensesLbl, Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailExport(), CreateGLAccount.SalesRetailExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Export(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateNZVATPostingGroup.VAT15(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesExport(), CreateGLAccount.SalesResourcesExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Export(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Export(), CreateNZVATPostingGroup.VAT9(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRetailExport(), CreateGLAccount.PurchRetailExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Export(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Export(), CreateNZVATPostingGroup.VAT9(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRawMaterialsExport(), CreateGLAccount.PurchRawMaterialsExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Export(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Export(), CreateNZVATPostingGroup.VAT15(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Postage(), CreateGLAccount.PostageName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.MISC(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.VAT15(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Travel(), CreateGLAccount.TravelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.MISC(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.VAT15(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RegistrationFees(), CreateGLAccount.RegistrationFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.MISC(), 0, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.VAT15(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinanceChargesfromCustomers(), CreateGLAccount.FinanceChargesfromCustomersName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.MISC(), 0, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.VAT15(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvoiceRounding(), CreateGLAccount.InvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.NoVAT(), 0, '', Enum::"General Posting Type"::" ", CreateVATPostingGroups.Domestic(), CreateNZVATPostingGroup.NoVAT(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorPrepaymentsVAT(), CreateGLAccount.VendorPrepaymentsVATName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting, '', CreateNZVATPostingGroup.NoVat(), 0, '', Enum::"General Posting Type"::" ", '', CreateNZVATPostingGroup.NoVAT(), false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CustomerPrepaymentsVAT0(), CreateGLAccount.CustomerPrepaymentsVAT0Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting, '', CreateNZVATPostingGroup.NoVAT(), 0, '', Enum::"General Posting Type"::" ", '', CreateNZVATPostingGroup.NoVAT(), false, false, false);
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

    procedure AssignCategoryToChartOfAccounts(GLAccountCategory: Record "G/L Account Category")
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case GLAccountCategory."Account Category" of
            GLAccountCategory."Account Category"::Assets:
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Assets(), CreateGLAccount.TotalAssets());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.PurchaseVAT25EU(), CreateGLAccount.PurchaseVAT25());
                end;
            GLAccountCategory."Account Category"::Liabilities:
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.DeferredTaxes(), CreateGLAccount.DeferredTaxes());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Liabilities(), SalesVAT15Perc());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.VATPayable(), CreateGLAccount.TotalLiabilities());
                end;
            GLAccountCategory."Account Category"::Equity:
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Stockholder(), CreateGLAccount.Allowances());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.AllowancesTotal(), CreateGLAccount.AllowancesTotal());
                end;
            GLAccountCategory."Account Category"::Income:
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Revenue(), CreateGLAccount.TotalRevenue());
            GLAccountCategory."Account Category"::"Cost of Goods Sold":
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Cost(), CreateGLAccount.TotalCost());
            GLAccountCategory."Account Category"::Expense:
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.OperatingExpenses(), CreateGLAccount.CorporateTax());
        end;
    end;

    procedure AssignSubcategoryToChartOfAccounts(GLAccountCategory: Record "G/L Account Category")
    var
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case GLAccountCategory.Description of
            GLAccountCategoryMgt.GetCash():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.LiquidAssets(), CreateGLAccount.LiquidAssetsTotal());
            GLAccountCategoryMgt.GetAR():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.AccountsReceivable(), CreateGLAccount.AccountsReceivableTotal());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.PurchaseVAT25EU(), CreateGLAccount.PurchaseVAT25());
                end;
            GLAccountCategoryMgt.GetPrepaidExpenses():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.JobWIP(), CreateGLAccount.JobWIP());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.PurchasePrepayments(), CreateGLAccount.PurchasePrepaymentsTotal());
                end;
            GLAccountCategoryMgt.GetInventory():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Inventory(), CreateGLAccount.InventoryTotal());
            GLAccountCategoryMgt.GetEquipment():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.FixedAssets(), CreateGLAccount.DecreasesduringtheYearBuildings());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.LandandBuildingsTotal(), CreateGLAccount.TangibleFixedAssetsTotal());
                end;
            GLAccountCategoryMgt.GetAccumDeprec():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.AccumDepreciationBuildings(), CreateGLAccount.AccumDepreciationBuildings());
            GLAccountCategoryMgt.GetCurrentLiabilities():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.ShorttermLiabilities(), CreateGLAccount.SalesVAT10());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.DeferredTaxes(), CreateGLAccount.DeferredTaxes());
                end;
            GLAccountCategoryMgt.GetPayrollLiabilities():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.PayrollTaxesPayable(), CreateGLAccount.PayrollTaxesPayable());
            GLAccountCategoryMgt.GetLongTermLiabilities():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.LongtermLiabilities(), CreateGLAccount.LongtermLiabilitiesTotal());
            GLAccountCategoryMgt.GetCommonStock():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.CapitalStock(), CreateGLAccount.CapitalStock());
            GLAccountCategoryMgt.GetRetEarnings():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.RetainedEarnings(), CreateGLAccount.RetainedEarnings());
            GLAccountCategoryMgt.GetDistrToShareholders():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Stockholder(), CreateGLAccount.Stockholder());
            GLAccountCategoryMgt.GetIncomeService():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.SalesResourcesDom(), CreateGLAccount.FeesandChargesRecDom());
            GLAccountCategoryMgt.GetIncomeProdSales():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.SalesofRetail(), CreateGLAccount.TotalSalesofRawMaterials());
            GLAccountCategoryMgt.GetIncomeSalesDiscounts():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted());
            GLAccountCategoryMgt.GetIncomeSalesReturns():
                ;
            GLAccountCategoryMgt.GetCOGSLabor():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.JobCostAppliedResources(), CreateGLAccount.JobCosts());
            GLAccountCategoryMgt.GetCOGSMaterials():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Cost(), CreateGLAccount.TotalCostofRawMaterials());
            GLAccountCategoryMgt.GetRentExpense():
                ;
            GLAccountCategoryMgt.GetAdvertisingExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.Advertising(), CreateGLAccount.EntertainmentandPR());
            GLAccountCategoryMgt.GetInterestExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.InterestExpenses(), CreateGLAccount.TotalInterestExpenses());
            GLAccountCategoryMgt.GetFeesExpense():
                ;
            GLAccountCategoryMgt.GetInsuranceExpense():
                ;
            GLAccountCategoryMgt.GetPayrollExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.PersonnelExpenses(), CreateGLAccount.TotalPersonnelExpenses());
            GLAccountCategoryMgt.GetBenefitsExpense():
                ;
            GLAccountCategoryMgt.GetRepairsExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.RepairsandMaintenanceExpense(), CreateGLAccount.RepairsandMaintenanceExpense());
            GLAccountCategoryMgt.GetUtilitiesExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.BuildingMaintenanceExpenses(), CreateGLAccount.Postage());
            GLAccountCategoryMgt.GetOtherIncomeExpense():
                begin
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.OtherOperatingExpenses(), CreateGLAccount.OtherOperatingExpTotal());
                    UpdateGLAccounts(GLAccountCategory, CreateGLAccount.ExtraordinaryExpenses(), CreateGLAccount.ExtraordinaryExpenses());
                end;
            GLAccountCategoryMgt.GetTaxExpense():
                UpdateGLAccounts(GLAccountCategory, CreateGLAccount.CorporateTax(), CreateGLAccount.CorporateTax());
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

    procedure PurchaseVAT15Perc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVAT15PercName()));
    end;

    procedure PurchaseVAT15PercName(): Text[100]
    begin
        exit(PurchaseVAT15PercTok);
    end;

    procedure SalesVAT15Perc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesVAT15PercName()));
    end;

    procedure SalesVAT15PercName(): Text[100]
    begin
        exit(SalesVAT15PercTok);
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        SalesVAT15PercTok: Label 'Sales VAT 15 %', MaxLength = 100;
        PurchaseVAT15PercTok: Label 'Purchase VAT 15 %', MaxLength = 100;
        VendorPrepaymentsVAT9PercLbl: Label 'Vendor Prepayments VAT 9 %', MaxLength = 100;
        VendorPrepaymentsVAT15PercLbl: Label 'Vendor Prepayments VAT 15 %', MaxLength = 100;
        CustomerPrepaymentsVAT9Lbl: Label 'Customer Prepayments VAT 9 %', MaxLength = 100;
        CustomerPrepaymentsVAT15Lbl: Label 'Customer Prepayments VAT 15 %', MaxLength = 100;
        SalesVAT15PercPostingLbl: Label 'Sales VAT 15 %, Posting', MaxLength = 100;
        SalesVAT15PercAssetsLbl: Label 'Sales VAT 15 %, Assets', MaxLength = 100;
        SalesVAT9PercLbl: Label 'Sales VAT 9 %', MaxLength = 100;
        PurchaseVAT15PercPostingLbl: Label 'Purchase VAT 15 %, Posting', MaxLength = 100;
        PurchaseVAT9PercLbl: Label 'Purchase VAT 9 %', MaxLength = 100;
        TaxPayableLbl: Label 'TAX Payable', MaxLength = 100;
        FreightExpensesRetailLbl: Label 'Freight Expenses, Retail', MaxLength = 100;
        FreightExpensesRawMatLbl: Label 'Freight Expenses, Raw Mat.', MaxLength = 100;
        FreightExpensesRawMatPostingLbl: Label 'Freight Expenses, Raw Mat., Posting', MaxLength = 100;
        AnnualLeaveExpensesLbl: Label 'Annual Leave Expenses', MaxLength = 100;
}