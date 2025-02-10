codeunit 10863 "Create GL Account FR"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    local procedure AddGLAccountforFR()
    var
        GLAccountCategory: Record "G/L Account Category";
        GLAccountIndent: Codeunit "G/L Account-Indent";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        SubCategory: Text[80];
    begin
        ContosoGLAccount.SetOverwriteData(true);

        SubCategory := Format(GLAccountCategoryMgt.GetEquipment(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FixedAssets(), CreateGLAccount.FixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.IncreasesduringtheYearBuildings(), CreateGLAccount.IncreasesduringtheYearBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DecreasesduringtheYearBuildings(), CreateGLAccount.DecreasesduringtheYearBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SupplementaryTaxesPayable(), CreateGLAccount.SupplementaryTaxesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.IncreasesduringtheYearOperEquip(), CreateGLAccount.IncreasesduringtheYearOperEquipName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DecreasesduringtheYearOperEquip(), CreateGLAccount.DecreasesduringtheYearOperEquipName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.IncreasesduringtheYearVehicles(), CreateGLAccount.IncreasesduringtheYearVehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DecreasesduringtheYearVehicles(), CreateGLAccount.DecreasesduringtheYearVehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LandandBuildings(), CreateGLAccount.LandandBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OperatingEquipment(), CreateGLAccount.OperatingEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Vehicles(), CreateGLAccount.VehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetAccumDeprec(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccumDepreciationBuildings(), CreateGLAccount.AccumDepreciationBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccumDeprOperEquip(), CreateGLAccount.AccumDeprOperEquipName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccumDepreciationVehicles(), CreateGLAccount.AccumDepreciationVehiclesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Liabilities);
        ContosoGLAccount.InsertGLAccount(VendorsBillsPayable(), VendorsBillsPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FixedAssetsVen(), FixedAssetsVenName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccountsPayable(), CreateGLAccount.AccountsPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorsDomestic(), CreateGLAccount.VendorsDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorsForeign(), CreateGLAccount.VendorsForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchasePrepayments(), CreateGLAccount.PurchasePrepaymentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorPrepaymentsVAT(), CreateGLAccount.VendorPrepaymentsVATName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VendorPrepaymentsVatRedueced(), VendorPrepaymentsVatReduecedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(VendorPrepaymentsVatStandard(), VendorPrepaymentsVatStandardName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchasePrepaymentsTotal(), CreateGLAccount.PurchasePrepaymentsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.PurchasePrepayments() + '..' + CreateGLAccount.PurchasePrepaymentsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccountsPayableTotal(), CreateGLAccount.AccountsPayableTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.AccountsPayable() + '..' + CreateGLAccount.AccountsPayableTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherLiabilities(), CreateGLAccount.OtherLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DividendsForTheFiscalYear(), CreateGLAccount.DividendsForTheFiscalYearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherLiabilitiesTotal(), CreateGLAccount.OtherLiabilitiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.OtherLiabilities() + '..' + CreateGLAccount.OtherLiabilitiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DisposalOfFixedAssets(), DisposalOfFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherReceivables(), CreateGLAccount.OtherReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.UnrealizedFxLosses(), CreateGLAccount.UnrealizedFxLossesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.UnrealizedFxGains(), CreateGLAccount.UnrealizedFxGainsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TemporaryAccount(), TemporaryAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RealizedGainAddCurrent(), RealizedGainAddCurrentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RealizedGainAddCurr(), RealizedGainAddCurrName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccruedJobCosts(), CreateGLAccount.AccruedJobCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AllowancesTotal(), CreateGLAccount.AllowancesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 1, CreateGLAccount.Allowances() + '..' + CreateGLAccount.AllowancesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCurrentLiabilities(), 80);
        ContosoGLAccount.InsertGLAccount(StateAndOtherGovernments(), StateAndOtherGovernmentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WithholdingTaxesPayable(), CreateGLAccount.WithholdingTaxesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CorporateTaxesPayable(), CreateGLAccount.CorporateTaxesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VatPayable(), CreateGLAccount.VatPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.NaturalGasTax(), CreateGLAccount.NaturalGasTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CoalTax(), CreateGLAccount.CoalTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(UseTaxGaReversing(), UseTaxGaReversingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(UseTaxFlReversing(), UseTaxFlReversingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(UseTaxGa(), UseTaxGaName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(UseTaxFl(), UseTaxFlName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeductibleVatIntra(), DeductibleVatIntraName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(NormDeducVatInter(), NormDeducVatInterName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ReducDeducVatInter(), ReducDeducVatInterName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesTaxGa(), SalesTaxGaName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesTaxFl(), SalesTaxFlName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VatOnSalesNormOnHold(), VatOnSalesNormOnHoldName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VatOnSalesReducOnHold(), VatOnSalesReducOnHoldName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VatPayableInterim(), VatPayableInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WaterTax(), CreateGLAccount.WaterTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FuelTax(), CreateGLAccount.FuelTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Co2Tax(), CreateGLAccount.Co2TaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ElectricityTax(), CreateGLAccount.ElectricityTaxName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VatTotal(), CreateGLAccount.VatTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, StateAndOtherGovernments() + '..' + CreateGLAccount.VatTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetPayrollLiabilities(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PersonnelRelatedItems(), CreateGLAccount.PersonnelRelatedItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PayrollTaxesPayable(), CreateGLAccount.PayrollTaxesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VacationCompensationPayable(), CreateGLAccount.VacationCompensationPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.EmployeesPayable(), CreateGLAccount.EmployeesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalPersonnelRelatedItems(), CreateGLAccount.TotalPersonnelRelatedItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.PersonnelRelatedItems() + '..' + CreateGLAccount.TotalPersonnelRelatedItems(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Equity);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Stockholder(), CreateGLAccount.StockholderName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CapitalStock(), CreateGLAccount.CapitalStockName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RetainedEarnings(), CreateGLAccount.RetainedEarningsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.NetIncomeForTheYear(), CreateGLAccount.NetIncomeForTheYearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DerogatoryAccount(), DerogatoryAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalStockholder(), CreateGLAccount.TotalStockholderName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Stockholder() + '..' + CreateGLAccount.TotalStockholder(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetIncomeService(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesOfRawMaterials(), CreateGLAccount.SalesOfRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSales(), CreateGLAccount.JobSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAdjmtRetail(), CreateGLAccount.JobSalesAdjmtRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAdjmtRawMat(), CreateGLAccount.JobSalesAdjmtRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAdjmtResources(), CreateGLAccount.JobSalesAdjmtResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesOtherJobExpenses(), CreateGLAccount.SalesOtherJobExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetIncomeProdSales(), 80);
        ContosoGLAccount.InsertGLAccount(SalesRawMat(), SalesRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesOfRetail(), CreateGLAccount.SalesOfRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRawMaterialsDom(), CreateGLAccount.SalesRawMaterialsDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRawMaterialsEu(), CreateGLAccount.SalesRawMaterialsEuName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRawMaterialsExport(), CreateGLAccount.SalesRawMaterialsExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TotalRawMaterialsSales(), TotalRawMaterialsSalesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, SalesRawMat() + '..' + TotalRawMaterialsSales(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAppliedRawMat(), CreateGLAccount.JobSalesAppliedRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAppliedResources(), CreateGLAccount.JobSalesAppliedResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobSalesAppliedRetail(), CreateGLAccount.JobSalesAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ConsultingFeesDom(), CreateGLAccount.ConsultingFeesDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesDom(), CreateGLAccount.SalesResourcesDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesEu(), CreateGLAccount.SalesResourcesEuName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesExport(), CreateGLAccount.SalesResourcesExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailDom(), CreateGLAccount.SalesRetailDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailEu(), CreateGLAccount.SalesRetailEuName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailExport(), CreateGLAccount.SalesRetailExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FeesAndChargesRecDom(), CreateGLAccount.FeesAndChargesRecDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SideActFranceGains(), SideActFranceGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SideActIntraGains(), SideActIntraGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SideActExportGains(), SideActExportGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvoiceRounding(), CreateGLAccount.InvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalSalesOfRetail(), CreateGLAccount.TotalSalesOfRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SalesOfRetail() + '..' + CreateGLAccount.TotalSalesOfRetail(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::"Cost of Goods Sold");
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Cost(), CreateGLAccount.CostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostOfRetail(), CreateGLAccount.CostOfRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRawMaterialsDom(), CreateGLAccount.PurchRawMaterialsDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRawMaterialsEu(), CreateGLAccount.PurchRawMaterialsEuName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRawMaterialsExport(), CreateGLAccount.PurchRawMaterialsExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.GasolineAndMotorOil(), CreateGLAccount.GasolineAndMotorOilName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OfficeSupplies(), CreateGLAccount.OfficeSuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InventoryAdjmtRawMat(), CreateGLAccount.InventoryAdjmtRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvAdjmtInterimRawMat(), CreateGLAccount.InvAdjmtInterimRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostOfRawMaterialsSold(), CreateGLAccount.CostOfRawMaterialsSoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostOfRawMatSoldInterim(), CreateGLAccount.CostOfRawMatSoldInterimName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvAdjmtInterimRetail(), CreateGLAccount.InvAdjmtInterimRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostOfRetailSold(), CreateGLAccount.CostOfRetailSoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostOfResaleSoldInterim(), CreateGLAccount.CostOfResaleSoldInterimName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ElectricityAndHeating(), CreateGLAccount.ElectricityAndHeatingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRetailDom(), CreateGLAccount.PurchRetailDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRetailEu(), CreateGLAccount.PurchRetailEuName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchRetailExport(), CreateGLAccount.PurchRetailExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DeliveryExpensesRawMat(), CreateGLAccount.DeliveryExpensesRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DeliveryExpensesRetail(), CreateGLAccount.DeliveryExpensesRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DiscReceivedRawMaterials(), CreateGLAccount.DiscReceivedRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalCostOfRetail(), CreateGLAccount.TotalCostOfRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.CostOfRetail() + '..' + CreateGLAccount.TotalCostOfRetail(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InventAdjustOverhead(), InventAdjustOverheadName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InventAdjustPurchVar(), InventAdjustPurchVarName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ResourceUsageCosts(), ResourceUsageCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncidentalCost(), IncidentalCostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncidentalCostsIntra(), IncidentalCostsIntraName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(IncidentalCosts(), IncidentalCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalCost(), CreateGLAccount.TotalCostName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 1, CreateGLAccount.Cost() + '..' + CreateGLAccount.TotalCost(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetUtilitiesExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.BuildingMaintenanceExpenses(), CreateGLAccount.BuildingMaintenanceExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Cleaning(), CreateGLAccount.CleaningName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RepairsandMaintenanceExpense(), CreateGLAccount.RepairsandMaintenanceExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RepairsandMaintenance(), CreateGLAccount.RepairsandMaintenanceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherCostsOfOperations(), CreateGLAccount.OtherCostsOfOperationsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Software(), CreateGLAccount.SoftwareName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalBldgMaintExpenses(), CreateGLAccount.TotalBldgMaintExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.BuildingMaintenanceExpenses() + '..' + CreateGLAccount.TotalBldgMaintExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetOtherIncomeExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SellingExpenses(), CreateGLAccount.SellingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ConsultantServices(), CreateGLAccount.ConsultantServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LegalAndAccountingServices(), CreateGLAccount.LegalAndAccountingServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Advertising(), CreateGLAccount.AdvertisingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Travel(), CreateGLAccount.TravelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.EntertainmentAndPr(), CreateGLAccount.EntertainmentAndPrName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Postage(), CreateGLAccount.PostageName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PhoneAndFax(), CreateGLAccount.PhoneAndFaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherComputerExpenses(), CreateGLAccount.OtherComputerExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalSellingExpenses(), CreateGLAccount.TotalSellingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SellingExpenses() + '..' + CreateGLAccount.TotalSellingExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AdministrativeExpenses(), CreateGLAccount.AdministrativeExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DayReleaseParticipation(), DayReleaseParticipationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProfesionalTax(), ProfesionalTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RegistrationFees(), CreateGLAccount.RegistrationFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalAdministrativeExpenses(), CreateGLAccount.TotalAdministrativeExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.AdministrativeExpenses() + '..' + CreateGLAccount.TotalAdministrativeExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Miscellaneous(), CreateGLAccount.MiscellaneousName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 1, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentToleranceGranted(), CreateGLAccount.PaymentToleranceGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ComputerExpenses(), CreateGLAccount.ComputerExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.BadDebtExpenses(), CreateGLAccount.BadDebtExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ExtraordinaryExpenses(), CreateGLAccount.ExtraordinaryExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalComputerExpenses(), CreateGLAccount.TotalComputerExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.ComputerExpenses() + '..' + CreateGLAccount.TotalComputerExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DepreciationOfFixedAssets(), CreateGLAccount.DepreciationOfFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DepreciationBuildings(), CreateGLAccount.DepreciationBuildingsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DepreciationEquipment(), CreateGLAccount.DepreciationEquipmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DepreciationVehicles(), CreateGLAccount.DepreciationVehiclesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TransportsOnPurchases(), TransportsOnPurchasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TransportsOnSells(), TransportsOnSellsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ApplicationRoundDebit(), ApplicationRoundDebitName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BookValueOfAssetsSold(), BookValueOfAssetsSoldName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DerogExpenseAccForDebit(), DerogExpenseAccForDebitName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalFixedAssetDepreciation(), CreateGLAccount.TotalFixedAssetDepreciationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.DepreciationOfFixedAssets() + '..' + CreateGLAccount.TotalFixedAssetDepreciation(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetPayrollExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PersonnelExpenses(), CreateGLAccount.PersonnelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Salaries(), CreateGLAccount.SalariesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Wages(), CreateGLAccount.WagesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VacationCompensation(), CreateGLAccount.VacationCompensationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PayrollTaxes(), CreateGLAccount.PayrollTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RetirementPlanContributions(), CreateGLAccount.RetirementPlanContributionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalPersonnelExpenses(), CreateGLAccount.TotalPersonnelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.PersonnelExpenses() + '..' + CreateGLAccount.TotalPersonnelExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CotisationToMutualCompany(), CotisationToMutualCompanyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CotisationToAssedic(), CotisationToAssedicName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherPersonalCosts(), OtherPersonalCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCOGSLabor(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCosts(), CreateGLAccount.JobCostsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAdjmtRetail(), CreateGLAccount.JobCostAdjmtRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAdjmtRawMaterials(), CreateGLAccount.JobCostAdjmtRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAdjmtResources(), CreateGLAccount.JobCostAdjmtResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAppliedRawMat(), CreateGLAccount.JobCostAppliedRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAppliedRetail(), CreateGLAccount.JobCostAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCostAppliedResources(), CreateGLAccount.JobCostAppliedResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CostOfResourcesUsed(), CreateGLAccount.CostOfResourcesUsedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCash(), 80);
        ContosoGLAccount.InsertGLAccount(FinancialAccounts(), FinancialAccountsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Securities(), CreateGLAccount.SecuritiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Bonds(), CreateGLAccount.BondsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SecuritiesTotal(), CreateGLAccount.SecuritiesTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Securities() + '..' + CreateGLAccount.SecuritiesTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LiquidAssets(), CreateGLAccount.LiquidAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.BankLcy(), CreateGLAccount.BankLcyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RevolvingCredit(), CreateGLAccount.RevolvingCreditName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.BankCurrencies(), CreateGLAccount.BankCurrenciesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.GiroAccount(), CreateGLAccount.GiroAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LiquidAssetsTotal(), CreateGLAccount.LiquidAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.LiquidAssets() + '..' + CreateGLAccount.LiquidAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Cash(), CreateGLAccount.CashName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(CheckToCash(), CheckToCashName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BillsForCollection(), BillsForCollectionName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DiscountedBills(), DiscountedBillsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BankAddCurr(), BankAddCurrName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FinAccountsTotal(), FinAccountsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 1, FinancialAccounts() + '..' + FinAccountsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetInterestExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InterestExpenses(), CreateGLAccount.InterestExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InterestOnBankLoans(), CreateGLAccount.InterestOnBankLoansName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InterestOnRevolvingCredit(), CreateGLAccount.InterestOnRevolvingCreditName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.MortgageInterest(), CreateGLAccount.MortgageInterestName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinanceChargesToVendors(), CreateGLAccount.FinanceChargesToVendorsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentDiscountsGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RealizedFxLosses(), CreateGLAccount.RealizedFxLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CashDiscrepancies(), CreateGLAccount.CashDiscrepanciesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalInterestExpenses(), CreateGLAccount.TotalInterestExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.InterestExpenses() + '..' + CreateGLAccount.TotalInterestExpenses(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EuroConvRoundLosses(), EuroConvRoundLossesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ApplicationRoundingLcy(), ApplicationRoundingLcyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Assets);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Assets(), CreateGLAccount.AssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DeferredTaxes(), CreateGLAccount.DeferredTaxesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Liabilities(), CreateGLAccount.LiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LongTermBankLoans(), CreateGLAccount.LongTermBankLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Mortgage(), CreateGLAccount.MortgageName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalLiabilities(), CreateGLAccount.TotalLiabilitiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Liabilities() + '..' + CreateGLAccount.TotalLiabilities(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalAssets(), CreateGLAccount.TotalAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 1, CreateGLAccount.Assets() + '..' + CreateGLAccount.TotalAssets(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FixedAssetsTotal(), CreateGLAccount.FixedAssetsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.FixedAssets() + '..' + CreateGLAccount.FixedAssetsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ShortTermLoan(), ShortTermLoanName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetInventory(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Inventory(), CreateGLAccount.InventoryName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RawMaterialsInterim(), CreateGLAccount.RawMaterialsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PrimoInventory(), CreateGLAccount.PrimoInventoryName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.WipJobSales(), CreateGLAccount.WipJobSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvoicedJobSales(), CreateGLAccount.InvoicedJobSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinishedGoodsInterim(), CreateGLAccount.FinishedGoodsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ResaleItemsInterim(), CreateGLAccount.ResaleItemsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InventoryTotal(), CreateGLAccount.InventoryTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.Inventory() + '..' + CreateGLAccount.InventoryTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(WipJobCost(), WipJobCostName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetAR(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccountsReceivable(), CreateGLAccount.AccountsReceivableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CustomersDomestic(), CreateGLAccount.CustomersDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CustomersForeign(), CreateGLAccount.CustomersForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccruedInterest(), CreateGLAccount.AccruedInterestName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesPrepayments(), CreateGLAccount.SalesPrepaymentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CustomerPrepaymentsVat0(), CreateGLAccount.CustomerPrepaymentsVat0Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesPrepaymentsTotal(), CreateGLAccount.SalesPrepaymentsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SalesPrepayments() + '..' + CreateGLAccount.SalesPrepaymentsTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CustomerPrepaymentsVatReduced(), CustomerPrepaymentsVatReducedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CustomerPrepaymentsVatStandard(), CustomerPrepaymentsVatStandardName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ClientsBillsReceivable(), ClientsBillsReceivableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccountsReceivableTotal(), CreateGLAccount.AccountsReceivableTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.AccountsReceivable() + '..' + CreateGLAccount.AccountsReceivableTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Income);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Revenue(), CreateGLAccount.RevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalSalesOfRawMaterials(), CreateGLAccount.TotalSalesOfRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.SalesOfRawMaterials() + '..' + CreateGLAccount.TotalSalesOfRawMaterials(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentToleranceReceived(), CreateGLAccount.PaymentToleranceReceivedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PmtTolGrantedDecreases(), CreateGLAccount.PmtTolGrantedDecreasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InterestIncome(), CreateGLAccount.InterestIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinanceChargesFromCustomers(), CreateGLAccount.FinanceChargesFromCustomersName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.PaymentDiscountsReceivedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RealizedFxGains(), CreateGLAccount.RealizedFxGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PmtTolReceivedDecreases(), CreateGLAccount.PmtTolReceivedDecreasesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InterestOnBankBalances(), CreateGLAccount.InterestOnBankBalancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalInterestIncome(), CreateGLAccount.TotalInterestIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, CreateGLAccount.InterestIncome() + '..' + CreateGLAccount.TotalInterestIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ExtraordinaryIncome(), CreateGLAccount.ExtraordinaryIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalRevenue(), CreateGLAccount.TotalRevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::"End-Total", '', '', 1, CreateGLAccount.Revenue() + '..' + CreateGLAccount.TotalRevenue(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ApplicationRoundingDebit(), ApplicationRoundingDebitName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EuroConvRoundGains(), EuroConvRoundGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AssetsSoldGains(), AssetsSoldGainsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DerogExpenseAccForCredit(), DerogExpenseAccForCreditName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        ContosoGLAccount.InsertGLAccount(CreateGLAccount.BalanceSheet(), CreateGLAccount.BalanceSheetName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Heading, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Allowances(), CreateGLAccount.AllowancesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.TotalLiabilitiesAndEquity(), CreateGLAccount.TotalLiabilitiesAndEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Total, '', '', 1, CreateGLAccount.BalanceSheet() + '..' + CreateGLAccount.TotalLiabilitiesAndEquity(), Enum::"General Posting Type"::" ", '', '', false, false, true);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.IncomeStatement(), CreateGLAccount.IncomeStatementName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Heading, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.NetIncome(), CreateGLAccount.NetIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, CreateGLAccount.IncomeStatement() + '..' + CreateGLAccount.NetIncome(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GeneralTotal(), GeneralTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::" ", SubCategory, Enum::"G/L Account Type"::Total, '', '', 2, '1..' + GeneralTotal(), Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.SetOverwriteData(false);
        GLAccountIndent.Indent();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccountforBE()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ModifyGLAccountOfW1();
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BalanceSheetName(), '100000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AssetsName(), '100002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.StockholderName(), '100003');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CapitalStockName(), '101000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetainedEarningsName(), '106000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeForTheYearName(), '120000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalStockholderName(), '149990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeferredTaxesName(), '155000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesName(), '160003');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongTermBankLoansName(), '164100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageName(), '164400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesName(), '169990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAssetsName(), '199990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsName(), '200002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearBuildingsName(), '201000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearBuildingsName(), '203000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SupplementaryTaxesPayableName(), '205000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearOperEquipName(), '206000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearOperEquipName(), '207000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearVehiclesName(), '208000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearVehiclesName(), '211000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsName(), '213100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentName(), '215000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '218200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationBuildingsName(), '281300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDeprOperEquipName(), '281500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationVehiclesName(), '281820');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsTotalName(), '299990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryName(), '300002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsName(), '310000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsInterimName(), '318000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PrimoInventoryName(), '320000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipJobSalesName(), '335100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoicedJobSalesName(), '335900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsName(), '350000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsInterimName(), '358000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsName(), '370000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsInterimName(), '378000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryTotalName(), '399990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesName(), '400002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableName(), '400003');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsDomesticName(), '401100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsForeignName(), '401900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsName(), '409100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVATName(), '409110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsTotalName(), '409199');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableTotalName(), '409990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableName(), '410002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersDomesticName(), '411100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersForeignName(), '411900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedInterestName(), '418800');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsName(), '419100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVat0Name(), '419110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsTotalName(), '419199');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableTotalName(), '419990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelRelatedItemsName(), '420002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesPayableName(), '431000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationPayableName(), '438200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EmployeesPayableName(), '438300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelRelatedItemsName(), '439990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WithholdingTaxesPayableName(), '441000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxesPayableName(), '444000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VatPayableName(), '445510');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NaturalGasTaxName(), '445620');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CoalTaxName(), '445670');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WaterTaxName(), '446100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FuelTaxName(), '447100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Co2TaxName(), '447200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityTaxName(), '448200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VatTotalName(), '449990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesName(), '450002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DividendsForTheFiscalYearName(), '457000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesTotalName(), '459990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherReceivablesName(), '467000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFxLossesName(), '476000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFxGainsName(), '477000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedJobCostsName(), '486100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesTotalName(), '499990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesName(), '500003');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BondsName(), '506000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesTotalName(), '509990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsName(), '511001');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankLcyName(), '512100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevolvingCreditName(), '512200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankCurrenciesName(), '512400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GiroAccountName(), '514000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsTotalName(), '519990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashName(), '531000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesAndEquityName(), '599990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncomeStatementName(), '600000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostName(), '600002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRetailName(), '600003');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsDomName(), '601100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsEuName(), '601200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsExportName(), '601900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GasolineAndMotorOilName(), '602210');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OfficeSuppliesName(), '602250');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRawMatName(), '603110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRawMatName(), '603118');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRawMaterialsSoldName(), '603120');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRawMatSoldInterimName(), '603128');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRetailName(), '603710');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRetailName(), '603718');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRetailSoldName(), '603720');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfResaleSoldInterimName(), '603728');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityAndHeatingName(), '606100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailDomName(), '607100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailEuName(), '607200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailExportName(), '607900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRawMatName(), '608100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRetailName(), '608700');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRawMaterialsName(), '609100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRetailName(), '609700');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostOfRetailName(), '609990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BuildingMaintenanceExpensesName(), '610002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CleaningName(), '613200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceExpenseName(), '615200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceName(), '615500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherCostsOfOperationsName(), '618000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SoftwareName(), '618300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalBldgMaintExpensesName(), '619990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SellingExpensesName(), '620002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultantServicesName(), '622600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LegalAndAccountingServicesName(), '622700');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdvertisingName(), '623000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TravelName(), '625100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EntertainmentAndPrName(), '625700');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PostageName(), '626100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PhoneAndFaxName(), '626200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherComputerExpensesName(), '628100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSellingExpensesName(), '629990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdministrativeExpensesName(), '630002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RegistrationFeesName(), '635400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAdministrativeExpensesName(), '639990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelExpensesName(), '640002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalariesName(), '641110');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WagesName(), '641120');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationName(), '641200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesName(), '645100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetirementPlanContributionsName(), '645300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelExpensesName(), '649990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MiscellaneousName(), '658000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ApplicationRoundingName(), '658600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceGrantedName(), '658700');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestExpensesName(), '660002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestOnBankLoansName(), '661160');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestOnRevolvingCreditName(), '661600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageInterestName(), '661700');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargesToVendorsName(), '661800');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsGrantedName(), '665000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFxLossesName(), '666100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashDiscrepanciesName(), '668000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestExpensesName(), '669990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ComputerExpensesName(), '670002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BadDebtExpensesName(), '671400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryExpensesName(), '678800');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalComputerExpensesName(), '679990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationOfFixedAssetsName(), '680002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationBuildingsName(), '681121');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationEquipmentName(), '681122');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationVehiclesName(), '681123');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalFixedAssetDepreciationName(), '689990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxName(), '695000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostName(), '699990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevenueName(), '700002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOfRetailName(), '700003');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsDomName(), '702100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsEuName(), '702200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsExportName(), '702900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRawMatName(), '704100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedResourcesName(), '704300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRetailName(), '704700');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultingFeesDomName(), '705000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesDomName(), '706100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesEuName(), '706200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesExportName(), '706900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailDomName(), '707100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailEuName(), '707200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailExportName(), '707900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FeesAndChargesRecDomName(), '708000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscountGrantedName(), '709000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoiceRoundingName(), '709100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfRetailName(), '709990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOfRawMaterialsName(), '710002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesName(), '713450');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRetailName(), '713451');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRawMatName(), '713452');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtResourcesName(), '713453');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOtherJobExpensesName(), '713480');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostsName(), '713490');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRetailName(), '713491');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRawMaterialsName(), '713492');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtResourcesName(), '713493');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRawMatName(), '713510');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRetailName(), '713550');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedResourcesName(), '713560');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfResourcesUsedName(), '713590');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfRawMaterialsName(), '719990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceReceivedName(), '758600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolGrantedDecreasesName(), '758700');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestIncomeName(), '760002');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargesFromCustomersName(), '763000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsReceivedName(), '765000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFxGainsName(), '766100');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolReceivedDecreasesName(), '766500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestOnBankBalancesName(), '768000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestIncomeName(), '769990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryIncomeName(), '778800');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalRevenueName(), '799990');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeName(), '889990');
        ContosoGLAccount.AddAccountForLocalization(DerogatoryAccountName(), '145000');
        ContosoGLAccount.AddAccountForLocalization(ShortTermLoanName(), '164800');
        ContosoGLAccount.AddAccountForLocalization(WipJobCostName(), '345200');
        ContosoGLAccount.AddAccountForLocalization(VendorsBillsPayableName(), '403000');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetsVenName(), '404100');
        ContosoGLAccount.AddAccountForLocalization(VendorPrepaymentsVatReduecedName(), '409120');
        ContosoGLAccount.AddAccountForLocalization(VendorPrepaymentsVatStandardName(), '409130');
        ContosoGLAccount.AddAccountForLocalization(ClientsBillsReceivableName(), '413000');
        ContosoGLAccount.AddAccountForLocalization(CustomerPrepaymentsVatReducedName(), '419120');
        ContosoGLAccount.AddAccountForLocalization(CustomerPrepaymentsVatStandardName(), '419130');
        ContosoGLAccount.AddAccountForLocalization(StateAndOtherGovernmentsName(), '440002');
        ContosoGLAccount.AddAccountForLocalization(UseTaxGaReversingName(), '445210');
        ContosoGLAccount.AddAccountForLocalization(UseTaxFlReversingName(), '445220');
        ContosoGLAccount.AddAccountForLocalization(UseTaxGaName(), '445661');
        ContosoGLAccount.AddAccountForLocalization(UseTaxFlName(), '445662');
        ContosoGLAccount.AddAccountForLocalization(DeductibleVatIntraName(), '445665');
        ContosoGLAccount.AddAccountForLocalization(NormDeducVatInterName(), '445681');
        ContosoGLAccount.AddAccountForLocalization(ReducDeducVatInterName(), '445682');
        ContosoGLAccount.AddAccountForLocalization(SalesTaxGaName(), '445711');
        ContosoGLAccount.AddAccountForLocalization(SalesTaxFlName(), '445712');
        ContosoGLAccount.AddAccountForLocalization(VatOnSalesNormOnHoldName(), '445781');
        ContosoGLAccount.AddAccountForLocalization(VatOnSalesReducOnHoldName(), '445782');
        ContosoGLAccount.AddAccountForLocalization(VatPayableInterimName(), '445800');
        ContosoGLAccount.AddAccountForLocalization(DisposalOfFixedAssetsName(), '462000');
        ContosoGLAccount.AddAccountForLocalization(TemporaryAccountName(), '471000');
        ContosoGLAccount.AddAccountForLocalization(RealizedGainAddCurrentName(), '476500');
        ContosoGLAccount.AddAccountForLocalization(RealizedGainAddCurrName(), '477500');
        ContosoGLAccount.AddAccountForLocalization(FinancialAccountsName(), '500002');
        ContosoGLAccount.AddAccountForLocalization(CheckToCashName(), '511200');
        ContosoGLAccount.AddAccountForLocalization(BillsForCollectionName(), '511300');
        ContosoGLAccount.AddAccountForLocalization(DiscountedBillsName(), '511400');
        ContosoGLAccount.AddAccountForLocalization(BankAddCurrName(), '512800');
        ContosoGLAccount.AddAccountForLocalization(FinAccountsTotalName(), '599930');
        ContosoGLAccount.AddAccountForLocalization(InventAdjustOverheadName(), '603711');
        ContosoGLAccount.AddAccountForLocalization(InventAdjustPurchVarName(), '603712');
        ContosoGLAccount.AddAccountForLocalization(ResourceUsageCostsName(), '604000');
        ContosoGLAccount.AddAccountForLocalization(IncidentalCostName(), '608000');
        ContosoGLAccount.AddAccountForLocalization(IncidentalCostsIntraName(), '608200');
        ContosoGLAccount.AddAccountForLocalization(IncidentalCostsName(), '608900');
        ContosoGLAccount.AddAccountForLocalization(TransportsOnPurchasesName(), '624100');
        ContosoGLAccount.AddAccountForLocalization(TransportsOnSellsName(), '624200');
        ContosoGLAccount.AddAccountForLocalization(DayReleaseParticipationName(), '633300');
        ContosoGLAccount.AddAccountForLocalization(ProfesionalTaxName(), '635110');
        ContosoGLAccount.AddAccountForLocalization(CotisationToMutualCompanyName(), '645200');
        ContosoGLAccount.AddAccountForLocalization(CotisationToAssedicName(), '645400');
        ContosoGLAccount.AddAccountForLocalization(OtherPersonalCostsName(), '648000');
        ContosoGLAccount.AddAccountForLocalization(ApplicationRoundDebitName(), '658500');
        ContosoGLAccount.AddAccountForLocalization(ApplicationRoundingLcyName(), '666500');
        ContosoGLAccount.AddAccountForLocalization(EuroConvRoundLossesName(), '668800');
        ContosoGLAccount.AddAccountForLocalization(BookValueOfAssetsSoldName(), '675200');
        ContosoGLAccount.AddAccountForLocalization(DerogExpenseAccForDebitName(), '687250');
        ContosoGLAccount.AddAccountForLocalization(SalesRawMatName(), '702002');
        ContosoGLAccount.AddAccountForLocalization(TotalRawMaterialsSalesName(), '702990');
        ContosoGLAccount.AddAccountForLocalization(SideActFranceGainsName(), '708810');
        ContosoGLAccount.AddAccountForLocalization(SideActIntraGainsName(), '708820');
        ContosoGLAccount.AddAccountForLocalization(SideActExportGainsName(), '708890');
        ContosoGLAccount.AddAccountForLocalization(ApplicationRoundingDebitName(), '758500');
        ContosoGLAccount.AddAccountForLocalization(EuroConvRoundGainsName(), '768800');
        ContosoGLAccount.AddAccountForLocalization(AssetsSoldGainsName(), '775200');
        ContosoGLAccount.AddAccountForLocalization(DerogExpenseAccForCreditName(), '787250');
        ContosoGLAccount.AddAccountForLocalization(GeneralTotalName(), '899999');
        AddGLAccountforFR();
    end;

    local procedure ModifyGLAccountOfW1()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandAndBuildingsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipSalesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipJobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipCostsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWipTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesAndEquityName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongTermLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongTermLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShortTermLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVat25EuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVat10EuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShortTermLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOfResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOfJobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfJobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostOfRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostOfResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehicleExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalVehicleExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalOperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GainsAndLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetOperatingIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtdiscReceivedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtdiscGrantedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NiBeforeExtrItemsTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeBeforeTaxesName(), '');
    end;

    procedure DerogatoryAccountName(): Text[100]
    begin
        exit(DerogatoryAccountLbl);
    end;

    procedure ShortTermLoanName(): Text[100]
    begin
        exit(ShortTermLoanLbl);
    end;

    procedure WipJobCostName(): Text[100]
    begin
        exit(WipJobCostLbl);
    end;

    procedure VendorsBillsPayableName(): Text[100]
    begin
        exit(VendorsBillsPayableLbl);
    end;

    procedure FixedAssetsVenName(): Text[100]
    begin
        exit(FixedAssetsVenLbl);
    end;

    procedure VendorPrepaymentsVatReduecedName(): Text[100]
    begin
        exit(VendorPrepaymentsVatReduecedLbl);
    end;

    procedure VendorPrepaymentsVatStandardName(): Text[100]
    begin
        exit(VendorPrepaymentsVatStandardLbl);
    end;

    procedure ClientsBillsReceivableName(): Text[100]
    begin
        exit(ClientsBillsReceivableLbl);
    end;

    procedure CustomerPrepaymentsVatReducedName(): Text[100]
    begin
        exit(CustomerPrepaymentsVatReducedLbl);
    end;

    procedure CustomerPrepaymentsVatStandardName(): Text[100]
    begin
        exit(CustomerPrepaymentsVatStandardLbl);
    end;

    procedure StateAndOtherGovernmentsName(): Text[100]
    begin
        exit(StateAndOtherGovernmentsLbl);
    end;

    procedure UseTaxGaReversingName(): Text[100]
    begin
        exit(UseTaxGaReversingLbl);
    end;

    procedure UseTaxFlReversingName(): Text[100]
    begin
        exit(UseTaxFlReversingLbl);
    end;

    procedure UseTaxGaName(): Text[100]
    begin
        exit(UseTaxGaLbl);
    end;

    procedure UseTaxFlName(): Text[100]
    begin
        exit(UseTaxFlLbl);
    end;

    procedure DeductibleVatIntraName(): Text[100]
    begin
        exit(DeductibleVatIntraLbl);
    end;

    procedure NormDeducVatInterName(): Text[100]
    begin
        exit(NormDeducVatInterLbl);
    end;

    procedure ReducDeducVatInterName(): Text[100]
    begin
        exit(ReducDeducVatInterLbl);
    end;

    procedure SalesTaxGaName(): Text[100]
    begin
        exit(SalesTaxGaLbl);
    end;

    procedure SalesTaxFlName(): Text[100]
    begin
        exit(SalesTaxFlLbl);
    end;

    procedure VatOnSalesNormOnHoldName(): Text[100]
    begin
        exit(VatOnSalesNormOnHoldLbl);
    end;

    procedure VatOnSalesReducOnHoldName(): Text[100]
    begin
        exit(VatOnSalesReducOnHoldLbl);
    end;

    procedure VatPayableInterimName(): Text[100]
    begin
        exit(VatPayableInterimLbl);
    end;

    procedure DisposalOfFixedAssetsName(): Text[100]
    begin
        exit(DisposalOfFixedAssetsLbl);
    end;

    procedure TemporaryAccountName(): Text[100]
    begin
        exit(TemporaryAccountLbl);
    end;

    procedure RealizedGainAddCurrentName(): Text[100]
    begin
        exit(RealizedGainAddCurrentLbl);
    end;

    procedure RealizedGainAddCurrName(): Text[100]
    begin
        exit(RealizedGainAddCurrLbl);
    end;

    procedure FinancialAccountsName(): Text[100]
    begin
        exit(FinancialAccountsLbl);
    end;

    procedure CheckToCashName(): Text[100]
    begin
        exit(CheckToCashLbl);
    end;

    procedure BillsForCollectionName(): Text[100]
    begin
        exit(BillsForCollectionLbl);
    end;

    procedure DiscountedBillsName(): Text[100]
    begin
        exit(DiscountedBillsLbl);
    end;

    procedure BankAddCurrName(): Text[100]
    begin
        exit(BankAddCurrLbl);
    end;

    procedure FinAccountsTotalName(): Text[100]
    begin
        exit(FinAccountsTotalLbl);
    end;

    procedure InventAdjustOverheadName(): Text[100]
    begin
        exit(InventAdjustOverheadLbl);
    end;

    procedure InventAdjustPurchVarName(): Text[100]
    begin
        exit(InventAdjustPurchVarLbl);
    end;

    procedure ResourceUsageCostsName(): Text[100]
    begin
        exit(ResourceUsageCostsLbl);
    end;

    procedure IncidentalCostName(): Text[100]
    begin
        exit(IncidentalCostLbl);
    end;

    procedure IncidentalCostsIntraName(): Text[100]
    begin
        exit(IncidentalCostsIntraLbl);
    end;

    procedure IncidentalCostsName(): Text[100]
    begin
        exit(IncidentalCostsLbl);
    end;

    procedure TransportsOnPurchasesName(): Text[100]
    begin
        exit(TransportsOnPurchasesLbl);
    end;

    procedure TransportsOnSellsName(): Text[100]
    begin
        exit(TransportsOnSellsLbl);
    end;

    procedure DayReleaseParticipationName(): Text[100]
    begin
        exit(DayReleaseParticipationLbl);
    end;

    procedure ProfesionalTaxName(): Text[100]
    begin
        exit(ProfesionalTaxLbl);
    end;

    procedure CotisationToMutualCompanyName(): Text[100]
    begin
        exit(CotisationToMutualCompanyLbl);
    end;

    procedure CotisationToAssedicName(): Text[100]
    begin
        exit(CotisationToAssedicLbl);
    end;

    procedure OtherPersonalCostsName(): Text[100]
    begin
        exit(OtherPersonalCostsLbl);
    end;

    procedure ApplicationRoundDebitName(): Text[100]
    begin
        exit(ApplicationRoundDebitLbl);
    end;

    procedure ApplicationRoundingLcyName(): Text[100]
    begin
        exit(ApplicationRoundingLcyLbl);
    end;

    procedure EuroConvRoundLossesName(): Text[100]
    begin
        exit(EuroConvRoundLossesLbl);
    end;

    procedure BookValueOfAssetsSoldName(): Text[100]
    begin
        exit(BookValueOfAssetsSoldLbl);
    end;

    procedure DerogExpenseAccForDebitName(): Text[100]
    begin
        exit(DerogExpenseAccForDebitLbl);
    end;

    procedure SalesRawMatName(): Text[100]
    begin
        exit(SalesRawMatLbl);
    end;

    procedure TotalRawMaterialsSalesName(): Text[100]
    begin
        exit(TotalRawMaterialsSalesLbl);
    end;

    procedure SideActFranceGainsName(): Text[100]
    begin
        exit(SideActFranceGainsLbl);
    end;

    procedure SideActIntraGainsName(): Text[100]
    begin
        exit(SideActIntraGainsLbl);
    end;

    procedure SideActExportGainsName(): Text[100]
    begin
        exit(SideActExportGainsLbl);
    end;

    procedure ApplicationRoundingDebitName(): Text[100]
    begin
        exit(ApplicationRoundingDebitLbl);
    end;

    procedure EuroConvRoundGainsName(): Text[100]
    begin
        exit(EuroConvRoundGainsLbl);
    end;

    procedure AssetsSoldGainsName(): Text[100]
    begin
        exit(AssetsSoldGainsLbl);
    end;

    procedure DerogExpenseAccForCreditName(): Text[100]
    begin
        exit(DerogExpenseAccForCreditLbl);
    end;

    procedure GeneralTotalName(): Text[100]
    begin
        exit(GeneralTotalLbl);
    end;

    procedure DerogatoryAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DerogatoryAccountName()));
    end;

    procedure ShortTermLoan(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShortTermLoanName()));
    end;

    procedure WipJobCost(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WipJobCostName()));
    end;

    procedure VendorsBillsPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorsBillsPayableName()));
    end;

    procedure FixedAssetsVen(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FixedAssetsVenName()));
    end;

    procedure VendorPrepaymentsVatRedueced(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorPrepaymentsVatReduecedName()));
    end;

    procedure VendorPrepaymentsVatStandard(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorPrepaymentsVatStandardName()));
    end;

    procedure ClientsBillsReceivable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ClientsBillsReceivableName()));
    end;

    procedure CustomerPrepaymentsVatReduced(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerPrepaymentsVatReducedName()));
    end;

    procedure CustomerPrepaymentsVatStandard(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerPrepaymentsVatStandardName()));
    end;

    procedure StateAndOtherGovernments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StateAndOtherGovernmentsName()));
    end;

    procedure UseTaxGaReversing(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UseTaxGaReversingName()));
    end;

    procedure UseTaxFlReversing(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UseTaxFlReversingName()));
    end;

    procedure UseTaxGa(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UseTaxGaName()));
    end;

    procedure UseTaxFl(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UseTaxFlName()));
    end;

    procedure DeductibleVatIntra(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeductibleVatIntraName()));
    end;

    procedure NormDeducVatInter(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NormDeducVatInterName()));
    end;

    procedure ReducDeducVatInter(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReducDeducVatInterName()));
    end;

    procedure SalesTaxGa(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesTaxGaName()));
    end;

    procedure SalesTaxFl(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesTaxFlName()));
    end;

    procedure VatOnSalesNormOnHold(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VatOnSalesNormOnHoldName()));
    end;

    procedure VatOnSalesReducOnHold(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VatOnSalesReducOnHoldName()));
    end;

    procedure VatPayableInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VatPayableInterimName()));
    end;

    procedure DisposalOfFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DisposalOfFixedAssetsName()));
    end;

    procedure TemporaryAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TemporaryAccountName()));
    end;

    procedure RealizedGainAddCurrent(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RealizedGainAddCurrentName()));
    end;

    procedure RealizedGainAddCurr(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RealizedGainAddCurrName()));
    end;

    procedure FinancialAccounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialAccountsName()));
    end;

    procedure CheckToCash(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CheckToCashName()));
    end;

    procedure BillsForCollection(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BillsForCollectionName()));
    end;

    procedure DiscountedBills(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DiscountedBillsName()));
    end;

    procedure BankAddCurr(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankAddCurrName()));
    end;

    procedure FinAccountsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinAccountsTotalName()));
    end;

    procedure InventAdjustOverhead(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventAdjustOverheadName()));
    end;

    procedure InventAdjustPurchVar(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventAdjustPurchVarName()));
    end;

    procedure ResourceUsageCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResourceUsageCostsName()));
    end;

    procedure IncidentalCost(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncidentalCostName()));
    end;

    procedure IncidentalCostsIntra(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncidentalCostsIntraName()));
    end;

    procedure IncidentalCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncidentalCostsName()));
    end;

    procedure TransportsOnPurchases(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TransportsOnPurchasesName()));
    end;

    procedure TransportsOnSells(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TransportsOnSellsName()));
    end;

    procedure DayReleaseParticipation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DayReleaseParticipationName()));
    end;

    procedure ProfesionalTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProfesionalTaxName()));
    end;

    procedure CotisationToMutualCompany(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CotisationToMutualCompanyName()));
    end;

    procedure CotisationToAssedic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CotisationToAssedicName()));
    end;

    procedure OtherPersonalCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherPersonalCostsName()));
    end;

    procedure ApplicationRoundDebit(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ApplicationRoundDebitName()));
    end;

    procedure ApplicationRoundingLcy(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ApplicationRoundingLcyName()));
    end;

    procedure EuroConvRoundLosses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EuroConvRoundLossesName()));
    end;

    procedure BookValueOfAssetsSold(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BookValueOfAssetsSoldName()));
    end;

    procedure DerogExpenseAccForDebit(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DerogExpenseAccForDebitName()));
    end;

    procedure SalesRawMat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRawMatName()));
    end;

    procedure TotalRawMaterialsSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TotalRawMaterialsSalesName()));
    end;

    procedure SideActFranceGains(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SideActFranceGainsName()));
    end;

    procedure SideActIntraGains(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SideActIntraGainsName()));
    end;

    procedure SideActExportGains(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SideActExportGainsName()));
    end;

    procedure ApplicationRoundingDebit(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ApplicationRoundingDebitName()));
    end;

    procedure EuroConvRoundGains(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EuroConvRoundGainsName()));
    end;

    procedure AssetsSoldGains(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AssetsSoldGainsName()));
    end;

    procedure DerogExpenseAccForCredit(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DerogExpenseAccForCreditName()));
    end;

    procedure GeneralTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GeneralTotalName()));
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        DerogatoryAccountLbl: Label 'Derogatory Account', MaxLength = 100;
        ShortTermLoanLbl: Label 'Short Term Loan', MaxLength = 100;
        WipJobCostLbl: Label 'WIP Job Cost', MaxLength = 100;
        VendorsBillsPayableLbl: Label 'Vendors, Bills Payable', MaxLength = 100;
        FixedAssetsVenLbl: Label 'Fixed Assets Ven', MaxLength = 100;
        VendorPrepaymentsVatReduecedLbl: Label 'Vendor Prepayments VAT 5 %', MaxLength = 100;
        VendorPrepaymentsVatStandardLbl: Label 'Vendor Prepayments VAT 20 %', MaxLength = 100;
        ClientsBillsReceivableLbl: Label 'Clients, Bills Receivable', MaxLength = 100;
        CustomerPrepaymentsVatReducedLbl: Label 'Customer Prepayments VAT 5 %', MaxLength = 100;
        CustomerPrepaymentsVatStandardLbl: Label 'Customer Prepayments VAT 20 %', MaxLength = 100;
        StateAndOtherGovernmentsLbl: Label 'State and Other Governments', MaxLength = 100;
        UseTaxGaReversingLbl: Label 'Use TAX GA Reversing', MaxLength = 100;
        UseTaxFlReversingLbl: Label 'Use TAX FL Reversing', MaxLength = 100;
        UseTaxGaLbl: Label 'Use TAX GA', MaxLength = 100;
        UseTaxFlLbl: Label 'Use TAX FL', MaxLength = 100;
        DeductibleVatIntraLbl: Label 'Deductible VAT (Intra)', MaxLength = 100;
        NormDeducVatInterLbl: Label 'Norm. Deduc. VAT (Inter.)', MaxLength = 100;
        ReducDeducVatInterLbl: Label 'Reduc. Deduc. VAT (Inter.)', MaxLength = 100;
        SalesTaxGaLbl: Label 'Sales TAX GA', MaxLength = 100;
        SalesTaxFlLbl: Label 'Sales TAX FL', MaxLength = 100;
        VatOnSalesNormOnHoldLbl: Label 'VAT On Sales, Norm. (On Hold)', MaxLength = 100;
        VatOnSalesReducOnHoldLbl: Label 'VAT On Sales, Reduc. (On Hold)', MaxLength = 100;
        VatPayableInterimLbl: Label 'VAT Payable (Interim)', MaxLength = 100;
        DisposalOfFixedAssetsLbl: Label 'Disposal of Fixed Assets', MaxLength = 100;
        TemporaryAccountLbl: Label 'Temporary Account', MaxLength = 100;
        RealizedGainAddCurrentLbl: Label 'Realized Gain Add-Curr FR', MaxLength = 100;
        RealizedGainAddCurrLbl: Label 'Realized Gain Add-Curr', MaxLength = 100;
        FinancialAccountsLbl: Label 'FINANCIAL ACCOUNTS', MaxLength = 100;
        CheckToCashLbl: Label 'Check To Cash', MaxLength = 100;
        BillsForCollectionLbl: Label 'Bills For Collection', MaxLength = 100;
        DiscountedBillsLbl: Label 'Discounted Bills', MaxLength = 100;
        BankAddCurrLbl: Label 'Bank, Add-Curr', MaxLength = 100;
        FinAccountsTotalLbl: Label 'FIN. ACCOUNTS TOTAL', MaxLength = 100;
        InventAdjustOverheadLbl: Label 'Invent. Adjust., Overhead', MaxLength = 100;
        InventAdjustPurchVarLbl: Label 'Invent. Adjust., Purch. Var.', MaxLength = 100;
        ResourceUsageCostsLbl: Label 'Resource Usage Costs', MaxLength = 100;
        IncidentalCostLbl: Label 'Incidental Costs FR', MaxLength = 100;
        IncidentalCostsIntraLbl: Label 'Incidental Costs - Intra', MaxLength = 100;
        IncidentalCostsLbl: Label 'Incidental Costs', MaxLength = 100;
        TransportsOnPurchasesLbl: Label 'Transports On Purchases', MaxLength = 100;
        TransportsOnSellsLbl: Label 'Transports On Sells', MaxLength = 100;
        DayReleaseParticipationLbl: Label 'Day Release Participation', MaxLength = 100;
        ProfesionalTaxLbl: Label 'Profesional Tax', MaxLength = 100;
        CotisationToMutualCompanyLbl: Label 'Cotisation To Mutual Company', MaxLength = 100;
        CotisationToAssedicLbl: Label 'Cotisation To ASSEDIC', MaxLength = 100;
        OtherPersonalCostsLbl: Label 'Other Personal Costs', MaxLength = 100;
        ApplicationRoundDebitLbl: Label 'Application Round Debit', MaxLength = 100;
        ApplicationRoundingLcyLbl: Label 'Application Rounding LCY', MaxLength = 100;
        EuroConvRoundLossesLbl: Label 'Euro Conv. Round. (Losses)', MaxLength = 100;
        BookValueOfAssetsSoldLbl: Label 'Book Value of Assets Sold', MaxLength = 100;
        DerogExpenseAccForDebitLbl: Label 'Derog. Expense Acc. for Debit', MaxLength = 100;
        SalesRawMatLbl: Label 'Sales Raw Mat.', MaxLength = 100;
        TotalRawMaterialsSalesLbl: Label 'Total Raw Materials Sales', MaxLength = 100;
        SideActFranceGainsLbl: Label 'Side Act. - France (Gains)', MaxLength = 100;
        SideActIntraGainsLbl: Label 'Side Act. - Intra (Gains)', MaxLength = 100;
        SideActExportGainsLbl: Label 'Side Act. - Export (Gains)', MaxLength = 100;
        ApplicationRoundingDebitLbl: Label 'Application Rounding Debit', MaxLength = 100;
        EuroConvRoundGainsLbl: Label 'Euro Conv. Round. (Gains)', MaxLength = 100;
        AssetsSoldGainsLbl: Label 'Assets Sold (Gains)', MaxLength = 100;
        DerogExpenseAccForCreditLbl: Label 'Derog. Expense Acc. for Credit', MaxLength = 100;
        GeneralTotalLbl: Label 'GENERAL TOTAL', MaxLength = 100;
}