codeunit 11357 "Create GL Account BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    local procedure AddGLAccountforBE()
    var
        GLAccountCategory: Record "G/L Account Category";
        GLAccountIndent: Codeunit "G/L Account-Indent";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateVatPostingGroupBE: Codeunit "Create VAT Posting Group BE";
        CreateGLAccount: Codeunit "Create G/L Account";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        SubCategory: Text[80];
    begin
        ContosoGLAccount.SetOverwriteData(true);
        SubCategory := Format(GLAccountCategoryMgt.GetCurrentAssets(), 80);
        ContosoGLAccount.InsertGLAccount(CodaTemporaryAccount(), CodaTemporaryAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InvestmentsLiquidities(), InvestmentsLiquiditiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '50..599999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OwnersStockEquity(), OwnersStockEquityName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Stocks(), StocksName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Securities(), CreateGLAccount.SecuritiesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '520..529999', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(StockBuyIn(), StockBuyInName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TransitAccounts(), TransitAccountsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '490..499999', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCash(), 80);
        ContosoGLAccount.InsertGLAccount(BankLocalCurrency(), BankLocalCurrencyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(BankProcessing(), BankProcessingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(BankForeignCurrency(), BankForeignCurrencyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(PostAccount(), PostAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Cash(), CreateGLAccount.CashName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, true, false);
        ContosoGLAccount.InsertGLAccount(Transfers(), TransfersName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, true);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LiquidAssets(), CreateGLAccount.LiquidAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '550..559999', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetAR(), 80);
        ContosoGLAccount.InsertGLAccount(DebtsCreditsDue1Year(), DebtsCreditsDue1YearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '40..499999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccountsReceivable(), CreateGLAccount.AccountsReceivableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '400..409999', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CustomersDomestic(), CreateGLAccount.CustomersDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CustomersForeign(), CreateGLAccount.CustomersForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreditsReceivable(), CreditsReceivableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesPrepayments(), CreateGLAccount.SalesPrepaymentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '406..406999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherReceivables(), CreateGLAccount.OtherReceivablesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '410..419999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BillsOfExchReceivable(), BillsOfExchReceivableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VatRecoverable(), VatRecoverableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.VAT(), true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherDoubtfulDebtors(), OtherDoubtfulDebtorsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DebtsDueWithin1Year(), DebtsDueWithin1YearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '420..429999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RedemptionOfLoan(), RedemptionOfLoanName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FinancialDebts(), FinancialDebtsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '430..439999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BankAccount(), BankAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DebtsByResultAllocation(), DebtsByResultAllocationName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '470..479999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(DividendsFormerFiscalYrs(), DividendsFormerFiscalYrsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DividendsFiscalYear(), DividendsFiscalYearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MiscellaneousDebts(), MiscellaneousDebtsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '480..489999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CustomerPrepayments(), CustomerPrepaymentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DoubtfulDebtors(), DoubtfulDebtorsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetFixedAssets(), 80);
        ContosoGLAccount.InsertGLAccount(FixedAssetsCredits1Year(), FixedAssetsCredits1YearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '20..299999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PreliminaryExpenses(), PreliminaryExpensesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '200..209999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(FormationIncrOfCapital(), FormationIncrOfCapitalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I0(), true, false, false);
        ContosoGLAccount.InsertGLAccount(IntangibleAssets(), IntangibleAssetsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '210..219999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ResearchDevelopment(), ResearchDevelopmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LandandBuildingsBeginTotal(), CreateGLAccount.LandandBuildingsBeginTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '220..229999', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LandandBuildings(), CreateGLAccount.LandandBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(FurnituresAndRollingStock(), FurnituresAndRollingStockName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '240..249999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Furnitures(), FurnituresName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(OfficeEquipment(), OfficeEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(ComputerEquipment(), ComputerEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(RollingStock(), RollingStockName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(FixedAssetsOnLeasing(), FixedAssetsOnLeasingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '250..259999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Leasings(), LeasingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherTangibleFaTotal(), OtherTangibleFaTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '260..269999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherTangibleFa(), OtherTangibleFaName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I0(), true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetEquipment(), 80);
        ContosoGLAccount.InsertGLAccount(EquipmentTotal(), EquipmentTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '230..239999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Equipment(), EquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCommonStock(), 80);
        ContosoGLAccount.InsertGLAccount(OwnersEquityDebts1Year(), OwnersEquityDebts1YearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '10..199999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Capital(), CapitalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '100..109999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(StockCapital(), StockCapitalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Equity, 80);
        ContosoGLAccount.InsertGLAccount(IssuingPremiums(), IssuingPremiumsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PlusValuesOfReevaluation(), PlusValuesOfReevaluationName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Reserve(), ReserveName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RetainedEarnings(), CreateGLAccount.RetainedEarningsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CapitalSubventions(), CapitalSubventionsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AllowancesForDoubtfulAcc(), AllowancesForDoubtfulAccName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProcessingOfResultTransfer(), ProcessingOfResultTransferName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '690..699999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(LossCarrForwFrPrevFy(), LossCarrForwFrPrevFyName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AddCapitalIssuingPrem(), AddCapitalIssuingPremName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AddReserves(), AddReservesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ProfitToBeCarriedForward(), ProfitToBeCarriedForwardName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ReturnOnCapital(), ReturnOnCapitalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DeferredTaxes(), CreateGLAccount.DeferredTaxesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetSalariesExpense(), 80);
        ContosoGLAccount.InsertGLAccount(SocialSecurity(), SocialSecurityName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '620..629999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Salaries(), CreateGLAccount.SalariesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Wages(), CreateGLAccount.WagesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PayrollTaxes(), CreateGLAccount.PayrollTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RetirementPlanContributions(), CreateGLAccount.RetirementPlanContributionsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherPersonnelExpenses(), OtherPersonnelExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetTaxExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CorporateTaxTotal(), CorporateTaxTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '670..679999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CorporateTax(), CreateGLAccount.CorporateTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 1, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TransferToDutyFreeReserve(), TransferToDutyFreeReserveName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '680..689999', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Income, 80);
        ContosoGLAccount.InsertGLAccount(DirectorsRemuneration(), DirectorsRemunerationName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, true);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.INCOMESTATEMENT(), CreateGLAccount.INCOMESTATEMENTName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '70..799999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Revenue(), CreateGLAccount.RevenueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '700..709999', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetIncomeService(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesofResources(), CreateGLAccount.SalesofResourcesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '7020..702999', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesDom(), CreateGLAccount.SalesResourcesDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesEU(), CreateGLAccount.SalesResourcesEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesResourcesExport(), CreateGLAccount.SalesResourcesExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesofJobs(), CreateGLAccount.SalesofJobsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '7030..703999', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesJobs(), SalesJobsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesOtherJobExpenses(), CreateGLAccount.SalesOtherJobExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ConsultingFees(), ConsultingFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PaymentDiscGranted(), PaymentDiscGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetIncomeProdSales(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesofRetail(), CreateGLAccount.SalesofRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '7000..700999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailDom(), CreateGLAccount.SalesRetailDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailEU(), CreateGLAccount.SalesRetailEUName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesRetailExport(), CreateGLAccount.SalesRetailExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.SalesofRawMaterials(), CreateGLAccount.SalesofRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '7010..701999', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRawMatDom(), SalesRawMatDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRawMatEu(), SalesRawMatEuName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(SalesRawMatExport(), SalesRawMatExportName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetRentExpense(), 80);
        ContosoGLAccount.InsertGLAccount(RentBuildingsRsEquipm(), RentBuildingsRsEquipmName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetAdvertisingExpense(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Advertising(), CreateGLAccount.AdvertisingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Brokerage(), BrokerageName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.EntertainmentandPR(), CreateGLAccount.EntertainmentandPRName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetRetEarnings(), 80);
        ContosoGLAccount.InsertGLAccount(NotCalledUpStockCapital(), NotCalledUpStockCapitalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Equity, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetOtherIncomeExpense(), 80);
        ContosoGLAccount.InsertGLAccount(ServicesAndInvestmentGoods(), ServicesAndInvestmentGoodsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '610..619999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RMBuildingsAndEquipm(), RMBuildingsAndEquipmName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(RMRollingStock(), RMRollingStockName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CleaningProducts(), CleaningProductsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(ElectricityWaterAndHeating(), ElectricityWaterAndHeatingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.GasolineandMotorOil(), CreateGLAccount.GasolineandMotorOilName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PhoneandFax(), CreateGLAccount.PhoneandFaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Postage(), CreateGLAccount.PostageName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OfficeSupplies(), CreateGLAccount.OfficeSuppliesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Software(), CreateGLAccount.SoftwareName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ConsultantServices(), CreateGLAccount.ConsultantServicesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherComputerExpenses(), CreateGLAccount.OtherComputerExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(Mailings(), MailingsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(InsurancesRsFire(), InsurancesRsFireName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, false, false);
        ContosoGLAccount.InsertGLAccount(LawyersAndAccountants(), LawyersAndAccountantsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(LegalContests(), LegalContestsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherServiceCharges(), OtherServiceChargesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Total, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '613390..613399', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseCostsRawMat(), PurchaseCostsRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.G1(), true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseCostsRetail(), PurchaseCostsRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.G3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchaseCostsInterim(), PurchaseCostsInterimName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.G3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Travel(), CreateGLAccount.TravelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(TranspCostsPurchRawMat(), TranspCostsPurchRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.G1(), true, false, false);
        ContosoGLAccount.InsertGLAccount(TranspCostsPurchRetail(), TranspCostsPurchRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.G3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.OtherOperatingExpenses(), CreateGLAccount.OtherOperatingExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '640..649999', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VehicleTaxes(), VehicleTaxesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Fines(), FinesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(MiscCostsOfOperations(), MiscCostsOfOperationsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ExtraordinaryExpensesTotal(), ExtraordinaryExpensesTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '660..669999', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ExtraordinaryExpenses(), CreateGLAccount.ExtraordinaryExpensesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LossesDisposalFixedAssets(), LossesDisposalFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InventoryAdjustmentsDiscount(), InventoryAdjustmentsDiscountName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '710..719999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ProducedFixedAssets(), ProducedFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '720..729999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(OtherOperatingIncome(), OtherOperatingIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '740..749999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(JobCostAdjustmentRetailDisc(), JobCostAdjustmentRetailDiscName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(JobCostAdjustmentRawMatIncome(), JobCostAdjustmentRawMatIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(JobCostAdjustmentResourcesIncome(), JobCostAdjustmentResourcesIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FinancialIncome(), FinancialIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '750..759999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IncomeFromLoans(), IncomeFromLoansName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InterestOnBankAccountsRec(), InterestOnBankAccountsRecName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PaymentDiscReceived(), PaymentDiscReceivedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(UnrealizedExchRateDiffIncome(), UnrealizedExchRateDiffIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RealizedExchRateDiffIncome(), RealizedExchRateDiffIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GainsOnDisposalFixedAssets(), GainsOnDisposalFixedAssetsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InvoiceRounding(), CreateGLAccount.InvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.CashDiscrepancies(), CreateGLAccount.CashDiscrepanciesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinanceChargesfromCustomers(), CreateGLAccount.FinanceChargesfromCustomersName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(ExtraordinaryIncomeTotal(), ExtraordinaryIncomeTotalName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '760..769999', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.ExtraordinaryIncome(), CreateGLAccount.ExtraordinaryIncomeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxesDuePaid(), TaxesDuePaidName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '770..779999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CorporateTaxDue(), CorporateTaxDueName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeferredFromDutyFreeRes(), DeferredFromDutyFreeResName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '780..789999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ProcessingOfResultDeferred(), ProcessingOfResultDeferredName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '790..799999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(BenefitCarrFwFrPrevFy(), BenefitCarrFwFrPrevFyName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(LossToBeCarriedForward(), LossToBeCarriedForwardName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AssociateIntervInLoss(), AssociateIntervInLossName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetLongTermLiabilities(), 80);
        ContosoGLAccount.InsertGLAccount(DebtsDueAt1Year(), DebtsDueAt1YearName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '170..179999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.LongtermBankLoans(), CreateGLAccount.LongtermBankLoansName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BEMortgage(), BEMortgageName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetCurrentLiabilities(), 80);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.AccountsPayable(), CreateGLAccount.AccountsPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '440..449999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorsDomestic(), CreateGLAccount.VendorsDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VendorsForeign(), CreateGLAccount.VendorsForeignName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(EstimatedTaxesPayable(), EstimatedTaxesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BillsOfExchPayable(), BillsOfExchPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VATPayable(), CreateGLAccount.VATPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Sale, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.VAT(), true, false, false);
        ContosoGLAccount.InsertGLAccount(TaxesPayable(), TaxesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetPayrollLiabilities(), 80);
        ContosoGLAccount.InsertGLAccount(TaxesSalariesSocCharges(), TaxesSalariesSocChargesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '450..459999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PersonnelrelatedItems(), CreateGLAccount.PersonnelrelatedItemsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '4530..459999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RetainedDeductionsAtSource(), RetainedDeductionsAtSourceName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, false, false);
        ContosoGLAccount.InsertGLAccount(SocialSecurityTotal(), SocialSecurityTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(WagesAndSalaries(), WagesAndSalariesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.VacationCompensationPayable(), CreateGLAccount.VacationCompensationPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.EmployeesPayable(), CreateGLAccount.EmployeesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherSocialCharges(), OtherSocialChargesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetInterestExpense(), 80);
        ContosoGLAccount.InsertGLAccount(FinancialCharges(), FinancialChargesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '650..659999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InterestOnBankAccount(), InterestOnBankAccountName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.InterestonBankBalances(), CreateGLAccount.InterestonBankBalancesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Mortgage(), CreateGLAccount.MortgageName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentDiscountsGrantedName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(UnrealizedExchRateDiffExpense(), UnrealizedExchRateDiffExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(RealizedExchRateDiffExpense(), RealizedExchRateDiffExpenseName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(BankCharges(), BankChargesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(StockExchangeTurnoverTax(), StockExchangeTurnoverTaxName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CashDiscrepanciesFinancial(), CashDiscrepanciesFinancialName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetAccumDeprec(), 80);
        ContosoGLAccount.InsertGLAccount(DeprecFormIncrOfCapDepreciation(), DeprecFormIncrOfCapDepreciationName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeprResearchDevelopment(), DeprResearchDevelopmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeprecBuildings(), DeprecBuildingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeprecEquipmentDepreciation(), DeprecEquipmentDepreciationName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeprecFurnitures(), DeprecFurnituresName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeprecOfficeEquipment(), DeprecOfficeEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeprecComputerEquipment(), DeprecComputerEquipmentName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeprecRollingStockFurniture(), DeprecRollingStockFurnitureName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeprecLeasings(), DeprecLeasingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeprecOtherTangibleFa(), DeprecOtherTangibleFaName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Depreciations(), DepreciationsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '630..639999', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetInventory(), 80);
        ContosoGLAccount.InsertGLAccount(InventoryAndOrders(), InventoryAndOrdersName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '30..399999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(RawMaterialsTotal(), RawMaterialsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '300..309999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.RawMaterialsInterim(), CreateGLAccount.RawMaterialsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PostedDepreciationsAuxiliary(), PostedDepreciationsAuxiliaryName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AuxiliaryMaterialsTotal(), AuxiliaryMaterialsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '310..319999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(AuxiliaryMaterials(), AuxiliaryMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(AuxiliaryMaterialsInterim(), AuxiliaryMaterialsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PostedDepreciationsRawMaterials(), PostedDepreciationsRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GoodsBeingMadeTotal(), GoodsBeingMadeTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '320..329999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GoodsBeingMade(), GoodsBeingMadeName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GoodsBeingMadeInterim(), GoodsBeingMadeInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PostedDepreciationsGoods(), PostedDepreciationsGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PostedDepreciationsFinishedGoods(), PostedDepreciationsFinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GoodsTotal(), GoodsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '340..349999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(Goods(), GoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(GoodsInterim(), GoodsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(PostedDepreciationsGoodsInterim(), PostedDepreciationsGoodsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(FinishedGoodsTotal(), FinishedGoodsTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '330..339999', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.FinishedGoodsInterim(), CreateGLAccount.FinishedGoodsInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.PurchasePrepayments(), CreateGLAccount.PurchasePrepaymentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '360..369999', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.JobCosts(), CreateGLAccount.JobCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.G3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DiscReceivedRawMaterials(), CreateGLAccount.DiscReceivedRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetailName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(VendorPrepayments(), VendorPrepaymentsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(Expenses(), ExpensesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '60..699999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GoodsRawAuxMaterials(), GoodsRawAuxMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 1, '600..609999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchasesRawMaterials(), PurchasesRawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '6000..600999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchasesRawMatDom(), PurchasesRawMatDomName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.G1(), true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchasesRawMatEu(), PurchasesRawMatEuName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.EUPostingGroup(), CreateVatPostingGroupBE.G1(), true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchasesRawMatExport(), PurchasesRawMatExportName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RawMatPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupBE.IMPEXP(), CreateVatPostingGroupBE.G1(), true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchasesAuxiliaryMaterials(), PurchasesAuxiliaryMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '6010..601999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchasesServices(), PurchasesServicesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '6020..602999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ResourceUsageCosts(), ResourceUsageCostsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(GeneralSubcontractings(), GeneralSubcontractingsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '6030..603999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchasesOfGoods(), PurchasesOfGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '6040..604999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(PurchasesRetailDom(), PurchasesRetailDomName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.G3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchasesRetailEu(), PurchasesRetailEuName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.EUPostingGroup(), CreateVatPostingGroupBE.G3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(PurchasesRetailExport(), PurchasesRetailExportName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RetailPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreateVatPostingGroupBE.IMPEXP(), CreateVatPostingGroupBE.G3(), true, false, false);
        ContosoGLAccount.InsertGLAccount(DiscountsReceived(), DiscountsReceivedName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '6080..608999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InventoryAdjustmentsSales(), InventoryAdjustmentsSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Total, '', '', 0, '6090..609999', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(InventAdjRetail(), InventAdjRetailName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InventAdjRetailInt(), InventAdjRetailIntName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(JobCostAdjustmentRetailSales(), JobCostAdjustmentRetailSalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, false, false);
        ContosoGLAccount.InsertGLAccount(InventAdjRawMat(), InventAdjRawMatName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(InventAdjRawMatInt(), InventAdjRawMatIntName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(JobCostAdjustmentRawMatInventory(), JobCostAdjustmentRawMatInventoryName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, false, false);
        ContosoGLAccount.InsertGLAccount(JobCostAdjustmentResourcesInventory(), JobCostAdjustmentResourcesInventoryName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, SubCategory, Enum::"G/L Account Type"::Posting, CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.MiscPostingGroup(), 0, '', Enum::"General Posting Type"::Purchase, CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, false, false);

        ContosoGLAccount.InsertGLAccount(DeprecFormIncrOfCapPremilary(), DeprecFormIncrOfCapPremilaryName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DeprecLandAndBuildings(), DeprecLandAndBuildingsName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationEquipment(), DepreciationEquipmentName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.InsertGLAccount(DepreciationRollingStock(), DepreciationRollingStockName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::" ", Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', true, false, false);
        ContosoGLAccount.SetOverwriteData(false);

        UpdateGLAccountVatSetup(Formationincrofcapital(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I0(), true, 0);
        UpdateGLAccountVatSetup(ResearchDevelopment(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I3(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.LandandBuildings(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I3(), true, 0);
        UpdateGLAccountVatSetup(Equipment(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I3(), true, 0);
        UpdateGLAccountVatSetup(Furnitures(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I3(), true, 0);
        UpdateGLAccountVatSetup(OfficeEquipment(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I3(), true, 0);
        UpdateGLAccountVatSetup(ComputerEquipment(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I3(), true, 0);
        UpdateGLAccountVatSetup(RollingStock(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I3(), true, 0);
        UpdateGLAccountVatSetup(Leasings(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I3(), true, 0);
        UpdateGLAccountVatSetup(OthertangibleFA(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.I0(), true, 0);
        UpdateGLAccountVatSetup(VATRecoverable(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.VAT(), false, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.VATPayable(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.VAT(), false, 0);
        UpdateGLAccountVatSetup(RetainedDeductionsatSource(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(SocialSecurity(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(PurchasesRawMatDom(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.G1(), true, 0);
        UpdateGLAccountVatSetup(ResourceUsageCosts(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.JobCosts(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(PurchasesRetailDom(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.G3(), true, 0);
        UpdateGLAccountVatSetup(JobCostAdjustmentRetailSales(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(JobCostAdjustmentRawMatInventory(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(JobCostAdjustmentResourcesInventory(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(RentBuildingsRSEquipm(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(RMBuildingsandEquipm(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(RMRollingStock(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(CleaningProducts(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(ElectricityWaterandHeating(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.GasolineandMotorOil(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 50);
        UpdateGLAccountVatSetup(CreateGLAccount.PhoneandFax(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.Postage(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.OfficeSupplies(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.Software(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.ConsultantServices(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.OtherComputerExpenses(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(Mailings(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(InsurancesRSFire(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(LawyersandAccountants(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(LegalContests(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(OtherServiceCharges(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(PurchaseCostsRawMat(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.G1(), true, 0);
        UpdateGLAccountVatSetup(PurchaseCostsRetail(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.G3(), true, 0);
        UpdateGLAccountVatSetup(PurchaseCostsInterim(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.G3(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.Travel(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(TranspCostspurchRawMat(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.G1(), true, 0);
        UpdateGLAccountVatSetup(TranspCostspurchRetail(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.G3(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.Advertising(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.EntertainmentandPR(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.Salaries(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.Wages(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.PayrollTaxes(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(OtherPersonnelExpenses(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.RetirementPlanContributions(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(VehicleTaxes(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(Fines(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(MiscCostsofOperations(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.InterestonBankBalances(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(InterestonBankAccount(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.Mortgage(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.ExtraordinaryExpenses(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.CorporateTax(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.SalesRetailDom(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.G3(), true, 0);
        UpdateGLAccountVatSetup(SalesRawMatDom(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.G1(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.SalesResourcesDom(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(SalesJobs(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.SalesOtherJobExpenses(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(ConsultingFees(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.InvoiceRounding(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.FinanceChargesfromCustomers(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);
        UpdateGLAccountVatSetup(PurchasesRawMatEU(), CreatePostingGroup.EUPostingGroup(), CreateVatPostingGroupBE.G1(), true, 0);
        UpdateGLAccountVatSetup(PurchasesRetailEU(), CreatePostingGroup.EUPostingGroup(), CreateVatPostingGroupBE.G3(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.SalesRetailEU(), CreatePostingGroup.EUPostingGroup(), CreateVatPostingGroupBE.G3(), true, 0);
        UpdateGLAccountVatSetup(SalesRawMatEU(), CreatePostingGroup.EUPostingGroup(), CreateVatPostingGroupBE.G1(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.SalesResourcesEU(), CreatePostingGroup.EUPostingGroup(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(PurchasesRawMatExport(), CreateVatPostingGroupBE.IMPEXP(), CreateVatPostingGroupBE.G1(), true, 0);
        UpdateGLAccountVatSetup(PurchasesRetailExport(), CreateVatPostingGroupBE.IMPEXP(), CreateVatPostingGroupBE.G3(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.SalesRetailExport(), CreateVatPostingGroupBE.IMPEXP(), CreateVatPostingGroupBE.G3(), true, 0);
        UpdateGLAccountVatSetup(SalesRawMatExport(), CreateVatPostingGroupBE.IMPEXP(), CreateVatPostingGroupBE.G1(), true, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.SalesResourcesExport(), CreateVatPostingGroupBE.IMPEXP(), CreateVatPostingGroupBE.S3(), true, 0);
        UpdateGLAccountVatSetup(VendorPrepayments(), '', CreateVatPostingGroupBE.G3(), true, 0);
        UpdateGLAccountVatSetup(CustomerPrepayments(), '', CreateVatPostingGroupBE.G3(), true, 0);
        UpdateGLAccountVatSetup(SocialSecurity(), '', '', true, 0);
        UpdateGLAccountVatSetup(SocialSecurityTotal(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroupBE.S0(), true, 0);

        UpdateGLAccountVatSetup(CreateGLAccount.CustomersDomestic(), '', '', false, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.CustomersForeign(), '', '', false, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.VendorsDomestic(), '', '', false, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.VendorsForeign(), '', '', false, 0);
        UpdateGLAccountVatSetup(BankLocalCurrency(), '', '', false, 0);
        UpdateGLAccountVatSetup(BankProcessing(), '', '', false, 0);
        UpdateGLAccountVatSetup(BankForeignCurrency(), '', '', false, 0);
        UpdateGLAccountVatSetup(PostAccount(), '', '', false, 0);
        UpdateGLAccountVatSetup(CreateGLAccount.Cash(), '', '', false, 0);
        GLAccountIndent.Indent();
    end;

    local procedure UpdateGLAccountVatSetup(GLAccountNo: Code[20]; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; PrintDetails: Boolean; NonDeductibleVAT: Decimal)
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get(GLAccountNo);
        GLAccount.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        GLAccount.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        GLAccount.Validate("Print Details", PrintDetails);
        if NonDeductibleVAT <> 0 then
            GLAccount.Validate("% Non deductible VAT", NonDeductibleVAT);
        GLAccount.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccountforBE()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ModifyGLAccountForW1();
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetainedEarningsName(), '140000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeferredTaxesName(), '168000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongtermBankLoansName(), '170000');
        ContosoGLAccount.AddAccountForLocalization(BEMortgageName(), '174000');
        ContosoGLAccount.AddAccountForLocalization(RawMaterialsTotalName(), '30');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsName(), '300000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RawMaterialsInterimName(), '300010');
        ContosoGLAccount.AddAccountForLocalization(FinishedGoodsTotalName(), '33');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsName(), '330000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinishedGoodsInterimName(), '330010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsName(), '36');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableName(), '40');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersDomesticName(), '400000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomersForeignName(), '400010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsName(), '406');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherReceivablesName(), '41');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableName(), '44');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsDomesticName(), '440000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorsForeignName(), '440010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VATPayableName(), '451000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelrelatedItemsName(), '453');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationPayableName(), '456000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EmployeesPayableName(), '457000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesName(), '52');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsName(), '55');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostsName(), '602010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRawMaterialsName(), '608000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscReceivedRetailName(), '608400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GasolineandMotorOilName(), '612120');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PhoneandFaxName(), '612200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PostageName(), '612400');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OfficeSuppliesName(), '612500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SoftwareName(), '612600');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultantServicesName(), '612610');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherComputerExpensesName(), '612620');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TravelName(), '613900');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdvertisingName(), '614000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.EntertainmentandPRName(), '614500');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalariesName(), '620200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WagesName(), '620300');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesName(), '621000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RetirementPlanContributionsName(), '624000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpensesName(), '64');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestonBankBalancesName(), '650000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageName(), '650020');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsGrantedName(), '653000');
        ContosoGLAccount.AddAccountForLocalization(CashDiscrepanciesFinancialName(), '655000');
        ContosoGLAccount.AddAccountForLocalization(ExtraordinaryExpensesTotalName(), '66');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryExpensesName(), '660000');
        ContosoGLAccount.AddAccountForLocalization(CorporateTaxTotalName(), '67');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxName(), '670000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncomeStatementName(), '7');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevenueName(), '70');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofRetailName(), '700');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailDomName(), '700000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailEUName(), '700010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRetailExportName(), '700020');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofRawMaterialsName(), '701');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofResourcesName(), '702');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesDomName(), '702000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesEUName(), '702010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesResourcesExportName(), '702020');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesofJobsName(), '703');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesOtherJobExpensesName(), '703010');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoiceRoundingName(), '754200');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashDiscrepanciesName(), '755000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargesfromCustomersName(), '756200');
        ContosoGLAccount.AddAccountForLocalization(ExtraordinaryIncomeTotalName(), '76');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ExtraordinaryIncomeName(), '760000');
        ContosoGLAccount.AddAccountForLocalization(CorporateTaxDueName(), '771000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsBeginTotalName(), '22');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandandBuildingsName(), '220000');
        ContosoGLAccount.AddAccountForLocalization(OwnersEquityDebts1YearName(), '1');
        ContosoGLAccount.AddAccountForLocalization(CapitalName(), '10');
        ContosoGLAccount.AddAccountForLocalization(StockCapitalName(), '100000');
        ContosoGLAccount.AddAccountForLocalization(NotCalledUpStockCapitalName(), '101000');
        ContosoGLAccount.AddAccountForLocalization(IssuingPremiumsName(), '110000');
        ContosoGLAccount.AddAccountForLocalization(PlusValuesOfReevaluationName(), '120000');
        ContosoGLAccount.AddAccountForLocalization(ReserveName(), '130000');
        ContosoGLAccount.AddAccountForLocalization(CapitalSubventionsName(), '150000');
        ContosoGLAccount.AddAccountForLocalization(AllowancesForDoubtfulAccName(), '160000');
        ContosoGLAccount.AddAccountForLocalization(DebtsDueAt1YearName(), '17');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetsCredits1YearName(), '2');
        ContosoGLAccount.AddAccountForLocalization(PreliminaryExpensesName(), '20');
        ContosoGLAccount.AddAccountForLocalization(FormationIncrOfCapitalName(), '200000');
        ContosoGLAccount.AddAccountForLocalization(DeprecFormIncrOfCapDepreciationName(), '200009');
        ContosoGLAccount.AddAccountForLocalization(IntangibleAssetsName(), '21');
        ContosoGLAccount.AddAccountForLocalization(ResearchDevelopmentName(), '210000');
        ContosoGLAccount.AddAccountForLocalization(DeprResearchDevelopmentName(), '210009');
        ContosoGLAccount.AddAccountForLocalization(DeprecBuildingsName(), '220009');
        ContosoGLAccount.AddAccountForLocalization(EquipmentTotalName(), '23');
        ContosoGLAccount.AddAccountForLocalization(EquipmentName(), '230000');
        ContosoGLAccount.AddAccountForLocalization(DeprecEquipmentDepreciationName(), '230009');
        ContosoGLAccount.AddAccountForLocalization(FurnituresAndRollingStockName(), '24');
        ContosoGLAccount.AddAccountForLocalization(FurnituresName(), '240000');
        ContosoGLAccount.AddAccountForLocalization(DeprecFurnituresName(), '240009');
        ContosoGLAccount.AddAccountForLocalization(OfficeEquipmentName(), '241000');
        ContosoGLAccount.AddAccountForLocalization(DeprecOfficeEquipmentName(), '241009');
        ContosoGLAccount.AddAccountForLocalization(ComputerEquipmentName(), '242000');
        ContosoGLAccount.AddAccountForLocalization(DeprecComputerEquipmentName(), '242009');
        ContosoGLAccount.AddAccountForLocalization(RollingStockName(), '245000');
        ContosoGLAccount.AddAccountForLocalization(DeprecRollingStockFurnitureName(), '245009');
        ContosoGLAccount.AddAccountForLocalization(FixedAssetsOnLeasingName(), '25');
        ContosoGLAccount.AddAccountForLocalization(LeasingsName(), '250000');
        ContosoGLAccount.AddAccountForLocalization(DeprecLeasingsName(), '250009');
        ContosoGLAccount.AddAccountForLocalization(OtherTangibleFaTotalName(), '26');
        ContosoGLAccount.AddAccountForLocalization(OtherTangibleFaName(), '260000');
        ContosoGLAccount.AddAccountForLocalization(DeprecOtherTangibleFaName(), '260009');
        ContosoGLAccount.AddAccountForLocalization(InventoryAndOrdersName(), '3');
        ContosoGLAccount.AddAccountForLocalization(PostedDepreciationsAuxiliaryName(), '309000');
        ContosoGLAccount.AddAccountForLocalization(AuxiliaryMaterialsTotalName(), '31');
        ContosoGLAccount.AddAccountForLocalization(AuxiliaryMaterialsName(), '310000');
        ContosoGLAccount.AddAccountForLocalization(AuxiliaryMaterialsInterimName(), '310010');
        ContosoGLAccount.AddAccountForLocalization(PostedDepreciationsRawMaterialsName(), '319000');
        ContosoGLAccount.AddAccountForLocalization(GoodsBeingMadeTotalName(), '32');
        ContosoGLAccount.AddAccountForLocalization(GoodsBeingMadeName(), '320000');
        ContosoGLAccount.AddAccountForLocalization(GoodsBeingMadeInterimName(), '320010');
        ContosoGLAccount.AddAccountForLocalization(PostedDepreciationsGoodsName(), '329000');
        ContosoGLAccount.AddAccountForLocalization(PostedDepreciationsFinishedGoodsName(), '339000');
        ContosoGLAccount.AddAccountForLocalization(GoodsTotalName(), '34');
        ContosoGLAccount.AddAccountForLocalization(GoodsName(), '340000');
        ContosoGLAccount.AddAccountForLocalization(GoodsInterimName(), '340010');
        ContosoGLAccount.AddAccountForLocalization(PostedDepreciationsGoodsInterimName(), '349000');
        ContosoGLAccount.AddAccountForLocalization(VendorPrepaymentsName(), '360000');
        ContosoGLAccount.AddAccountForLocalization(DebtsCreditsDue1YearName(), '4');
        ContosoGLAccount.AddAccountForLocalization(BillsOfExchReceivableName(), '401000');
        ContosoGLAccount.AddAccountForLocalization(CreditsReceivableName(), '404000');
        ContosoGLAccount.AddAccountForLocalization(CustomerPrepaymentsName(), '406000');
        ContosoGLAccount.AddAccountForLocalization(DoubtfulDebtorsName(), '407000');
        ContosoGLAccount.AddAccountForLocalization(VatRecoverableName(), '411000');
        ContosoGLAccount.AddAccountForLocalization(OtherDoubtfulDebtorsName(), '417000');
        ContosoGLAccount.AddAccountForLocalization(DebtsDueWithin1YearName(), '42');
        ContosoGLAccount.AddAccountForLocalization(RedemptionOfLoanName(), '420000');
        ContosoGLAccount.AddAccountForLocalization(FinancialDebtsName(), '43');
        ContosoGLAccount.AddAccountForLocalization(BankAccountName(), '433000');
        ContosoGLAccount.AddAccountForLocalization(BillsOfExchPayableName(), '441000');
        ContosoGLAccount.AddAccountForLocalization(TaxesSalariesSocChargesName(), '45');
        ContosoGLAccount.AddAccountForLocalization(EstimatedTaxesPayableName(), '450000');
        ContosoGLAccount.AddAccountForLocalization(TaxesPayableName(), '452000');
        ContosoGLAccount.AddAccountForLocalization(RetainedDeductionsAtSourceName(), '453000');
        ContosoGLAccount.AddAccountForLocalization(SocialSecurityTotalName(), '454000');
        ContosoGLAccount.AddAccountForLocalization(WagesAndSalariesName(), '455000');
        ContosoGLAccount.AddAccountForLocalization(OtherSocialChargesName(), '459000');
        ContosoGLAccount.AddAccountForLocalization(DebtsByResultAllocationName(), '47');
        ContosoGLAccount.AddAccountForLocalization(DividendsFormerFiscalYrsName(), '470000');
        ContosoGLAccount.AddAccountForLocalization(DividendsFiscalYearName(), '471000');
        ContosoGLAccount.AddAccountForLocalization(MiscellaneousDebtsName(), '48');
        ContosoGLAccount.AddAccountForLocalization(TransitAccountsName(), '49');
        ContosoGLAccount.AddAccountForLocalization(CodaTemporaryAccountName(), '499999');
        ContosoGLAccount.AddAccountForLocalization(InvestmentsLiquiditiesName(), '5');
        ContosoGLAccount.AddAccountForLocalization(OwnersStockEquityName(), '500000');
        ContosoGLAccount.AddAccountForLocalization(StocksName(), '510000');
        ContosoGLAccount.AddAccountForLocalization(StockBuyInName(), '520000');
        ContosoGLAccount.AddAccountForLocalization(BankLocalCurrencyName(), '550000');
        ContosoGLAccount.AddAccountForLocalization(BankProcessingName(), '550005');
        ContosoGLAccount.AddAccountForLocalization(BankForeignCurrencyName(), '550010');
        ContosoGLAccount.AddAccountForLocalization(PostAccountName(), '560000');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashName(), '570000');
        ContosoGLAccount.AddAccountForLocalization(TransfersName(), '580000');
        ContosoGLAccount.AddAccountForLocalization(ExpensesName(), '6');
        ContosoGLAccount.AddAccountForLocalization(GoodsRawAuxMaterialsName(), '60');
        ContosoGLAccount.AddAccountForLocalization(PurchasesRawMaterialsName(), '600');
        ContosoGLAccount.AddAccountForLocalization(PurchasesRawMatDomName(), '600000');
        ContosoGLAccount.AddAccountForLocalization(PurchasesRawMatEuName(), '600010');
        ContosoGLAccount.AddAccountForLocalization(PurchasesRawMatExportName(), '600020');
        ContosoGLAccount.AddAccountForLocalization(PurchasesAuxiliaryMaterialsName(), '601');
        ContosoGLAccount.AddAccountForLocalization(PurchasesServicesName(), '602');
        ContosoGLAccount.AddAccountForLocalization(ResourceUsageCostsName(), '602000');
        ContosoGLAccount.AddAccountForLocalization(GeneralSubcontractingsName(), '603');
        ContosoGLAccount.AddAccountForLocalization(PurchasesOfGoodsName(), '604');
        ContosoGLAccount.AddAccountForLocalization(PurchasesRetailDomName(), '604000');
        ContosoGLAccount.AddAccountForLocalization(PurchasesRetailEuName(), '604010');
        ContosoGLAccount.AddAccountForLocalization(PurchasesRetailExportName(), '604020');
        ContosoGLAccount.AddAccountForLocalization(DiscountsReceivedName(), '608');
        ContosoGLAccount.AddAccountForLocalization(InventoryAdjustmentsSalesName(), '609');
        ContosoGLAccount.AddAccountForLocalization(InventAdjRetailName(), '609170');
        ContosoGLAccount.AddAccountForLocalization(InventAdjRetailIntName(), '609171');
        ContosoGLAccount.AddAccountForLocalization(JobCostAdjustmentRetailSalesName(), '609180');
        ContosoGLAccount.AddAccountForLocalization(InventAdjRawMatName(), '609270');
        ContosoGLAccount.AddAccountForLocalization(InventAdjRawMatIntName(), '609271');
        ContosoGLAccount.AddAccountForLocalization(JobCostAdjustmentRawMatInventoryName(), '609280');
        ContosoGLAccount.AddAccountForLocalization(JobCostAdjustmentResourcesInventoryName(), '609480');
        ContosoGLAccount.AddAccountForLocalization(ServicesAndInvestmentGoodsName(), '61');
        ContosoGLAccount.AddAccountForLocalization(RentBuildingsRsEquipmName(), '610000');
        ContosoGLAccount.AddAccountForLocalization(RMBuildingsAndEquipmName(), '611000');
        ContosoGLAccount.AddAccountForLocalization(RMRollingStockName(), '611300');
        ContosoGLAccount.AddAccountForLocalization(CleaningProductsName(), '611400');
        ContosoGLAccount.AddAccountForLocalization(ElectricityWaterAndHeatingName(), '612000');
        ContosoGLAccount.AddAccountForLocalization(MailingsName(), '612800');
        ContosoGLAccount.AddAccountForLocalization(InsurancesRsFireName(), '613100');
        ContosoGLAccount.AddAccountForLocalization(LawyersAndAccountantsName(), '613230');
        ContosoGLAccount.AddAccountForLocalization(LegalContestsName(), '613310');
        ContosoGLAccount.AddAccountForLocalization(OtherServiceChargesName(), '613390');
        ContosoGLAccount.AddAccountForLocalization(PurchaseCostsRawMatName(), '613392');
        ContosoGLAccount.AddAccountForLocalization(PurchaseCostsRetailName(), '613395');
        ContosoGLAccount.AddAccountForLocalization(PurchaseCostsInterimName(), '613399');
        ContosoGLAccount.AddAccountForLocalization(TranspCostsPurchRawMatName(), '613930');
        ContosoGLAccount.AddAccountForLocalization(TranspCostsPurchRetailName(), '613935');
        ContosoGLAccount.AddAccountForLocalization(BrokerageName(), '614200');
        ContosoGLAccount.AddAccountForLocalization(SocialSecurityName(), '62');
        ContosoGLAccount.AddAccountForLocalization(OtherPersonnelExpensesName(), '623000');
        ContosoGLAccount.AddAccountForLocalization(DepreciationsName(), '63');
        ContosoGLAccount.AddAccountForLocalization(DeprecFormIncrOfCapPremilaryName(), '630000');
        ContosoGLAccount.AddAccountForLocalization(DeprecLandAndBuildingsName(), '630200');
        ContosoGLAccount.AddAccountForLocalization(DepreciationEquipmentName(), '630210');
        ContosoGLAccount.AddAccountForLocalization(DepreciationRollingStockName(), '630220');
        ContosoGLAccount.AddAccountForLocalization(VehicleTaxesName(), '640100');
        ContosoGLAccount.AddAccountForLocalization(FinesName(), '640200');
        ContosoGLAccount.AddAccountForLocalization(MiscCostsOfOperationsName(), '643000');
        ContosoGLAccount.AddAccountForLocalization(FinancialChargesName(), '65');
        ContosoGLAccount.AddAccountForLocalization(InterestOnBankAccountName(), '650010');
        ContosoGLAccount.AddAccountForLocalization(UnrealizedExchRateDiffExpenseName(), '654000');
        ContosoGLAccount.AddAccountForLocalization(RealizedExchRateDiffExpenseName(), '654100');
        ContosoGLAccount.AddAccountForLocalization(BankChargesName(), '656000');
        ContosoGLAccount.AddAccountForLocalization(StockExchangeTurnoverTaxName(), '656100');
        ContosoGLAccount.AddAccountForLocalization(LossesDisposalFixedAssetsName(), '663000');
        ContosoGLAccount.AddAccountForLocalization(TransferToDutyFreeReserveName(), '68');
        ContosoGLAccount.AddAccountForLocalization(ProcessingOfResultTransferName(), '69');
        ContosoGLAccount.AddAccountForLocalization(LossCarrForwFrPrevFyName(), '690000');
        ContosoGLAccount.AddAccountForLocalization(AddCapitalIssuingPremName(), '691000');
        ContosoGLAccount.AddAccountForLocalization(AddReservesName(), '692000');
        ContosoGLAccount.AddAccountForLocalization(ProfitToBeCarriedForwardName(), '693000');
        ContosoGLAccount.AddAccountForLocalization(ReturnOnCapitalName(), '694000');
        ContosoGLAccount.AddAccountForLocalization(DirectorsRemunerationName(), '695000');
        ContosoGLAccount.AddAccountForLocalization(SalesRawMatDomName(), '701000');
        ContosoGLAccount.AddAccountForLocalization(SalesRawMatEuName(), '701010');
        ContosoGLAccount.AddAccountForLocalization(SalesRawMatExportName(), '701020');
        ContosoGLAccount.AddAccountForLocalization(SalesJobsName(), '703000');
        ContosoGLAccount.AddAccountForLocalization(ConsultingFeesName(), '704000');
        ContosoGLAccount.AddAccountForLocalization(PaymentDiscGrantedName(), '708000');
        ContosoGLAccount.AddAccountForLocalization(InventoryAdjustmentsDiscountName(), '71');
        ContosoGLAccount.AddAccountForLocalization(ProducedFixedAssetsName(), '72');
        ContosoGLAccount.AddAccountForLocalization(OtherOperatingIncomeName(), '74');
        ContosoGLAccount.AddAccountForLocalization(JobCostAdjustmentRetailDiscName(), '742000');
        ContosoGLAccount.AddAccountForLocalization(JobCostAdjustmentRawMatIncomeName(), '742010');
        ContosoGLAccount.AddAccountForLocalization(JobCostAdjustmentResourcesIncomeName(), '742020');
        ContosoGLAccount.AddAccountForLocalization(FinancialIncomeName(), '75');
        ContosoGLAccount.AddAccountForLocalization(IncomeFromLoansName(), '750000');
        ContosoGLAccount.AddAccountForLocalization(InterestOnBankAccountsRecName(), '750100');
        ContosoGLAccount.AddAccountForLocalization(PaymentDiscReceivedName(), '753000');
        ContosoGLAccount.AddAccountForLocalization(UnrealizedExchRateDiffIncomeName(), '754000');
        ContosoGLAccount.AddAccountForLocalization(RealizedExchRateDiffIncomeName(), '754100');
        ContosoGLAccount.AddAccountForLocalization(GainsOnDisposalFixedAssetsName(), '763000');
        ContosoGLAccount.AddAccountForLocalization(TaxesDuePaidName(), '77');
        ContosoGLAccount.AddAccountForLocalization(DeferredFromDutyFreeResName(), '78');
        ContosoGLAccount.AddAccountForLocalization(ProcessingOfResultDeferredName(), '79');
        ContosoGLAccount.AddAccountForLocalization(BenefitCarrFwFrPrevFyName(), '790000');
        ContosoGLAccount.AddAccountForLocalization(LossToBeCarriedForwardName(), '793000');
        ContosoGLAccount.AddAccountForLocalization(AssociateIntervInLossName(), '794000');
        AddGLAccountforBE();
    end;

    local procedure ModifyGLAccountForW1()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesBeginTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsandMaintenanceExpenseName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BalanceSheetName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LandAndBuildingsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDeprOperEquipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingEquipmentTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.IncreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DecreasesduringtheYearVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccumDepreciationVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehiclesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TangibleFixedAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FixedAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ResaleItemsInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfResaleSoldInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRawMatSoldInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PrimoInventoryName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWipName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipJobSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvoicedJobSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipSalesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipJobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedJobCostsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WipCostsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobWipTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccruedInterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsReceivableTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVATName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVAT10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VendorPrepaymentsVat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchasePrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BondsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SecuritiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CashName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankLcyName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BankCurrenciesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GiroAccountName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiquidAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CurrentAssetsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesAndEquityName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.StockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CapitalStockName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeForTheYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalStockholderName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AllowancesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongTermLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LongTermLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShortTermLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RevolvingCreditName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVat0Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CustomerPrepaymentsVat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesPrepaymentsTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AccountsPayableTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InvAdjmtInterimTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesVat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVat25EuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVat10EuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVat25Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchaseVat10Name(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FuelTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NaturalGasTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CoalTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.Co2TaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WaterTaxName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VatTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.WithholdingTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SupplementaryTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PayrollTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelRelatedItemsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DividendsForTheFiscalYearName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CorporateTaxesPayableName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ShortTermLiabilitiesTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalLiabilitiesAndEquityName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsEuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SalesRawMaterialsExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAppliedResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobSalesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSalesOfJobsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ConsultingFeesDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FeesAndChargesRecDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DiscountGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalRevenueName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailEuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRetailExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRetailSoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostOfRetailName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsDomName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsEuName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PurchRawMaterialsExportName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InventoryAdjmtRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedRawMatName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfRawMaterialsSoldName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostOfRawMaterialsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAppliedResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.JobCostAdjmtResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CostOfResourcesUsedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostOfResourcesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalCostName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BuildingMaintenanceExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.CleaningName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ElectricityAndHeatingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsAndMaintenanceName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalBldgMaintExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.AdministrativeExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalAdministrativeExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalComputerExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.SellingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DeliveryExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalSellingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VehicleExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RegistrationFeesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RepairsAndMaintenanceName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalVehicleExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.BadDebtExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.LegalAndAccountingServicesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MiscellaneousName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherOperatingExpTotalName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalOperatingExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PersonnelExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.VacationCompensationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalPersonnelExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationOfFixedAssetsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationBuildingsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationEquipmentName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.DepreciationVehiclesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.GainsAndLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalFixedAssetDepreciationName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.OtherCostsOfOperationsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetOperatingIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentDiscountsReceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtdiscReceivedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.ApplicationRoundingName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceReceivedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolReceivedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestIncomeName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestOnRevolvingCreditName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.InterestOnBankLoansName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.MortgageInterestName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.FinanceChargesToVendorsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtdiscGrantedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PaymentToleranceGrantedName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.PmtTolGrantedDecreasesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.TotalInterestExpensesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFxGainsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.UnrealizedFxLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFxGainsName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.RealizedFxLossesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NiBeforeExtrItemsTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeBeforeTaxesName(), '');
        ContosoGLAccount.AddAccountForLocalization(CreateGLAccount.NetIncomeName(), '');
    end;

    procedure OwnersEquityDebts1YearName(): Text[100]
    begin
        exit(OwnersEquityDebts1YearLbl);
    end;

    procedure CapitalName(): Text[100]
    begin
        exit(CapitalLbl);
    end;

    procedure StockCapitalName(): Text[100]
    begin
        exit(StockCapitalLbl);
    end;

    procedure NotCalledUpStockCapitalName(): Text[100]
    begin
        exit(NotCalledUpStockCapitalLbl);
    end;

    procedure IssuingPremiumsName(): Text[100]
    begin
        exit(IssuingPremiumsLbl);
    end;

    procedure PlusValuesOfReevaluationName(): Text[100]
    begin
        exit(PlusValuesOfReevaluationLbl);
    end;

    procedure ReserveName(): Text[100]
    begin
        exit(ReserveLbl);
    end;

    procedure CapitalSubventionsName(): Text[100]
    begin
        exit(CapitalSubventionsLbl);
    end;

    procedure AllowancesForDoubtfulAccName(): Text[100]
    begin
        exit(AllowancesForDoubtfulAccLbl);
    end;

    procedure DebtsDueAt1YearName(): Text[100]
    begin
        exit(DebtsDueAt1YearLbl);
    end;

    procedure FixedAssetsCredits1YearName(): Text[100]
    begin
        exit(FixedAssetsCredits1YearLbl);
    end;

    procedure PreliminaryExpensesName(): Text[100]
    begin
        exit(PreliminaryExpensesLbl);
    end;

    procedure FormationIncrOfCapitalName(): Text[100]
    begin
        exit(FormationIncrOfCapitalLbl);
    end;

    procedure DeprecFormIncrOfCapDepreciationName(): Text[100]
    begin
        exit(DeprecFormIncrOfCapDepreciationLbl);
    end;

    procedure IntangibleAssetsName(): Text[100]
    begin
        exit(IntangibleAssetsLbl);
    end;

    procedure ResearchDevelopmentName(): Text[100]
    begin
        exit(ResearchDevelopmentLbl);
    end;

    procedure DeprResearchDevelopmentName(): Text[100]
    begin
        exit(DeprResearchDevelopmentLbl);
    end;

    procedure DeprecBuildingsName(): Text[100]
    begin
        exit(DeprecBuildingsLbl);
    end;

    procedure EquipmentTotalName(): Text[100]
    begin
        exit(EquipmentTotalLbl);
    end;

    procedure EquipmentName(): Text[100]
    begin
        exit(EquipmentLbl);
    end;

    procedure DeprecEquipmentDepreciationName(): Text[100]
    begin
        exit(DeprecEquipmentDepreciationLbl);
    end;

    procedure FurnituresAndRollingStockName(): Text[100]
    begin
        exit(FurnituresAndRollingStockLbl);
    end;

    procedure FurnituresName(): Text[100]
    begin
        exit(FurnituresLbl);
    end;

    procedure DeprecFurnituresName(): Text[100]
    begin
        exit(DeprecFurnituresLbl);
    end;

    procedure OfficeEquipmentName(): Text[100]
    begin
        exit(OfficeEquipmentLbl);
    end;

    procedure DeprecOfficeEquipmentName(): Text[100]
    begin
        exit(DeprecOfficeEquipmentLbl);
    end;

    procedure ComputerEquipmentName(): Text[100]
    begin
        exit(ComputerEquipmentLbl);
    end;

    procedure DeprecComputerEquipmentName(): Text[100]
    begin
        exit(DeprecComputerEquipmentLbl);
    end;

    procedure RollingStockName(): Text[100]
    begin
        exit(RollingStockLbl);
    end;

    procedure DeprecRollingStockFurnitureName(): Text[100]
    begin
        exit(DeprecRollingStockFurnitureLbl);
    end;

    procedure FixedAssetsOnLeasingName(): Text[100]
    begin
        exit(FixedAssetsOnLeasingLbl);
    end;

    procedure LeasingsName(): Text[100]
    begin
        exit(LeasingsLbl);
    end;

    procedure DeprecLeasingsName(): Text[100]
    begin
        exit(DeprecLeasingsLbl);
    end;

    procedure OtherTangibleFaTotalName(): Text[100]
    begin
        exit(OtherTangibleFaTotalLbl);
    end;

    procedure OtherTangibleFaName(): Text[100]
    begin
        exit(OtherTangibleFaLbl);
    end;

    procedure DeprecOtherTangibleFaName(): Text[100]
    begin
        exit(DeprecOtherTangibleFaLbl);
    end;

    procedure InventoryAndOrdersName(): Text[100]
    begin
        exit(InventoryAndOrdersLbl);
    end;

    procedure PostedDepreciationsAuxiliaryName(): Text[100]
    begin
        exit(PostedDepreciationsAuxiliaryLbl);
    end;

    procedure AuxiliaryMaterialsTotalName(): Text[100]
    begin
        exit(AuxiliaryMaterialsTotalLbl);
    end;

    procedure AuxiliaryMaterialsName(): Text[100]
    begin
        exit(AuxiliaryMaterialsLbl);
    end;

    procedure AuxiliaryMaterialsInterimName(): Text[100]
    begin
        exit(AuxiliaryMaterialsInterimLbl);
    end;

    procedure PostedDepreciationsRawMaterialsName(): Text[100]
    begin
        exit(PostedDepreciationsRawMaterialsLbl);
    end;

    procedure GoodsBeingMadeTotalName(): Text[100]
    begin
        exit(GoodsBeingMadeTotalLbl);
    end;

    procedure GoodsBeingMadeName(): Text[100]
    begin
        exit(GoodsBeingMadeLbl);
    end;

    procedure GoodsBeingMadeInterimName(): Text[100]
    begin
        exit(GoodsBeingMadeInterimLbl);
    end;

    procedure PostedDepreciationsGoodsName(): Text[100]
    begin
        exit(PostedDepreciationsGoodsLbl);
    end;

    procedure PostedDepreciationsFinishedGoodsName(): Text[100]
    begin
        exit(PostedDepreciationsFinishedGoodsLbl);
    end;

    procedure GoodsTotalName(): Text[100]
    begin
        exit(GoodsTotalLbl);
    end;

    procedure GoodsName(): Text[100]
    begin
        exit(GoodsLbl);
    end;

    procedure GoodsInterimName(): Text[100]
    begin
        exit(GoodsInterimLbl);
    end;

    procedure PostedDepreciationsGoodsInterimName(): Text[100]
    begin
        exit(PostedDepreciationsGoodsInterimLbl);
    end;

    procedure VendorPrepaymentsName(): Text[100]
    begin
        exit(VendorPrepaymentsLbl);
    end;

    procedure DebtsCreditsDue1YearName(): Text[100]
    begin
        exit(DebtsCreditsDue1YearLbl);
    end;

    procedure BillsOfExchReceivableName(): Text[100]
    begin
        exit(BillsOfExchReceivableLbl);
    end;

    procedure CreditsReceivableName(): Text[100]
    begin
        exit(CreditsReceivableLbl);
    end;

    procedure CustomerPrepaymentsName(): Text[100]
    begin
        exit(CustomerPrepaymentsLbl);
    end;

    procedure DoubtfulDebtorsName(): Text[100]
    begin
        exit(DoubtfulDebtorsLbl);
    end;

    procedure VatRecoverableName(): Text[100]
    begin
        exit(VatRecoverableLbl);
    end;

    procedure OtherDoubtfulDebtorsName(): Text[100]
    begin
        exit(OtherDoubtfulDebtorsLbl);
    end;

    procedure DebtsDueWithin1YearName(): Text[100]
    begin
        exit(DebtsDueWithin1YearLbl);
    end;

    procedure RedemptionOfLoanName(): Text[100]
    begin
        exit(RedemptionOfLoanLbl);
    end;

    procedure FinancialDebtsName(): Text[100]
    begin
        exit(FinancialDebtsLbl);
    end;

    procedure BankAccountName(): Text[100]
    begin
        exit(BankAccountLbl);
    end;

    procedure BillsOfExchPayableName(): Text[100]
    begin
        exit(BillsOfExchPayableLbl);
    end;

    procedure TaxesSalariesSocChargesName(): Text[100]
    begin
        exit(TaxesSalariesSocChargesLbl);
    end;

    procedure EstimatedTaxesPayableName(): Text[100]
    begin
        exit(EstimatedTaxesPayableLbl);
    end;

    procedure TaxesPayableName(): Text[100]
    begin
        exit(TaxesPayableLbl);
    end;

    procedure RetainedDeductionsAtSourceName(): Text[100]
    begin
        exit(RetainedDeductionsAtSourceLbl);
    end;

    procedure SocialSecurityTotalName(): Text[100]
    begin
        exit(SocialSecurityTotalLbl);
    end;

    procedure WagesAndSalariesName(): Text[100]
    begin
        exit(WagesAndSalariesLbl);
    end;

    procedure OtherSocialChargesName(): Text[100]
    begin
        exit(OtherSocialChargesLbl);
    end;

    procedure DebtsByResultAllocationName(): Text[100]
    begin
        exit(DebtsByResultAllocationLbl);
    end;

    procedure DividendsFormerFiscalYrsName(): Text[100]
    begin
        exit(DividendsFormerFiscalYrsLbl);
    end;

    procedure DividendsFiscalYearName(): Text[100]
    begin
        exit(DividendsFiscalYearLbl);
    end;

    procedure MiscellaneousDebtsName(): Text[100]
    begin
        exit(MiscellaneousDebtsLbl);
    end;

    procedure TransitAccountsName(): Text[100]
    begin
        exit(TransitAccountsLbl);
    end;

    procedure CodaTemporaryAccountName(): Text[100]
    begin
        exit(CodaTemporaryAccountLbl);
    end;

    procedure InvestmentsLiquiditiesName(): Text[100]
    begin
        exit(InvestmentsLiquiditiesLbl);
    end;

    procedure OwnersStockEquityName(): Text[100]
    begin
        exit(OwnersStockEquityLbl);
    end;

    procedure StocksName(): Text[100]
    begin
        exit(StocksLbl);
    end;

    procedure StockBuyInName(): Text[100]
    begin
        exit(StockBuyInLbl);
    end;

    procedure BankLocalCurrencyName(): Text[100]
    begin
        exit(BankLocalCurrencyLbl);
    end;

    procedure BankProcessingName(): Text[100]
    begin
        exit(BankProcessingLbl);
    end;

    procedure BankForeignCurrencyName(): Text[100]
    begin
        exit(BankForeignCurrencyLbl);
    end;

    procedure PostAccountName(): Text[100]
    begin
        exit(PostAccountLbl);
    end;

    procedure TransfersName(): Text[100]
    begin
        exit(TransfersLbl);
    end;

    procedure ExpensesName(): Text[100]
    begin
        exit(ExpensesLbl);
    end;

    procedure GoodsRawAuxMaterialsName(): Text[100]
    begin
        exit(GoodsRawAuxMaterialsLbl);
    end;

    procedure PurchasesRawMaterialsName(): Text[100]
    begin
        exit(PurchasesRawMaterialsLbl);
    end;

    procedure PurchasesRawMatDomName(): Text[100]
    begin
        exit(PurchasesRawMatDomLbl);
    end;

    procedure PurchasesRawMatEuName(): Text[100]
    begin
        exit(PurchasesRawMatEuLbl);
    end;

    procedure PurchasesRawMatExportName(): Text[100]
    begin
        exit(PurchasesRawMatExportLbl);
    end;

    procedure PurchasesAuxiliaryMaterialsName(): Text[100]
    begin
        exit(PurchasesAuxiliaryMaterialsLbl);
    end;

    procedure PurchasesServicesName(): Text[100]
    begin
        exit(PurchasesServicesLbl);
    end;

    procedure ResourceUsageCostsName(): Text[100]
    begin
        exit(ResourceUsageCostsLbl);
    end;

    procedure GeneralSubcontractingsName(): Text[100]
    begin
        exit(GeneralSubcontractingsLbl);
    end;

    procedure PurchasesOfGoodsName(): Text[100]
    begin
        exit(PurchasesOfGoodsLbl);
    end;

    procedure PurchasesRetailDomName(): Text[100]
    begin
        exit(PurchasesRetailDomLbl);
    end;

    procedure PurchasesRetailEuName(): Text[100]
    begin
        exit(PurchasesRetailEuLbl);
    end;

    procedure PurchasesRetailExportName(): Text[100]
    begin
        exit(PurchasesRetailExportLbl);
    end;

    procedure DiscountsReceivedName(): Text[100]
    begin
        exit(DiscountsReceivedLbl);
    end;

    procedure InventoryAdjustmentsSalesName(): Text[100]
    begin
        exit(InventoryAdjustmentsSalesLbl);
    end;

    procedure InventAdjRetailName(): Text[100]
    begin
        exit(InventAdjRetailLbl);
    end;

    procedure InventAdjRetailIntName(): Text[100]
    begin
        exit(InventAdjRetailIntLbl);
    end;

    procedure JobCostAdjustmentRetailSalesName(): Text[100]
    begin
        exit(JobCostAdjustmentRetailSalesLbl);
    end;

    procedure InventAdjRawMatName(): Text[100]
    begin
        exit(InventAdjRawMatLbl);
    end;

    procedure InventAdjRawMatIntName(): Text[100]
    begin
        exit(InventAdjRawMatIntLbl);
    end;

    procedure JobCostAdjustmentRawMatInventoryName(): Text[100]
    begin
        exit(JobCostAdjustmentRawMatInventoryLbl);
    end;

    procedure JobCostAdjustmentResourcesInventoryName(): Text[100]
    begin
        exit(JobCostAdjustmentResourcesInventoryLbl);
    end;

    procedure ServicesAndInvestmentGoodsName(): Text[100]
    begin
        exit(ServicesAndInvestmentGoodsLbl);
    end;

    procedure RentBuildingsRsEquipmName(): Text[100]
    begin
        exit(RentBuildingsRsEquipmLbl);
    end;

    procedure RMBuildingsAndEquipmName(): Text[100]
    begin
        exit(RMBuildingsAndEquipmLbl);
    end;

    procedure RMRollingStockName(): Text[100]
    begin
        exit(RMRollingStockLbl);
    end;

    procedure CleaningProductsName(): Text[100]
    begin
        exit(CleaningProductsLbl);
    end;

    procedure ElectricityWaterAndHeatingName(): Text[100]
    begin
        exit(ElectricityWaterAndHeatingLbl);
    end;

    procedure MailingsName(): Text[100]
    begin
        exit(MailingsLbl);
    end;

    procedure InsurancesRsFireName(): Text[100]
    begin
        exit(InsurancesRsFireLbl);
    end;

    procedure LawyersAndAccountantsName(): Text[100]
    begin
        exit(LawyersAndAccountantsLbl);
    end;

    procedure LegalContestsName(): Text[100]
    begin
        exit(LegalContestsLbl);
    end;

    procedure OtherServiceChargesName(): Text[100]
    begin
        exit(OtherServiceChargesLbl);
    end;

    procedure PurchaseCostsRawMatName(): Text[100]
    begin
        exit(PurchaseCostsRawMatLbl);
    end;

    procedure PurchaseCostsRetailName(): Text[100]
    begin
        exit(PurchaseCostsRetailLbl);
    end;

    procedure PurchaseCostsInterimName(): Text[100]
    begin
        exit(PurchaseCostsInterimLbl);
    end;

    procedure TranspCostsPurchRawMatName(): Text[100]
    begin
        exit(TranspCostsPurchRawMatLbl);
    end;

    procedure TranspCostsPurchRetailName(): Text[100]
    begin
        exit(TranspCostsPurchRetailLbl);
    end;

    procedure BrokerageName(): Text[100]
    begin
        exit(BrokerageLbl);
    end;

    procedure SocialSecurityName(): Text[100]
    begin
        exit(SocialSecurityLbl);
    end;

    procedure OtherPersonnelExpensesName(): Text[100]
    begin
        exit(OtherPersonnelExpensesLbl);
    end;

    procedure DepreciationsName(): Text[100]
    begin
        exit(DepreciationsLbl);
    end;

    procedure DeprecFormIncrOfCapPremilaryName(): Text[100]
    begin
        exit(DeprecFormIncrOfCapPremilaryLbl);
    end;

    procedure DeprecLandAndBuildingsName(): Text[100]
    begin
        exit(DeprecLandAndBuildingsLbl);
    end;

    procedure DepreciationEquipmentName(): Text[100]
    begin
        exit(DepreciationEquipmentLbl);
    end;

    procedure DepreciationRollingStockName(): Text[100]
    begin
        exit(DepreciationRollingStockLbl);
    end;

    procedure VehicleTaxesName(): Text[100]
    begin
        exit(VehicleTaxesLbl);
    end;

    procedure FinesName(): Text[100]
    begin
        exit(FinesLbl);
    end;

    procedure MiscCostsOfOperationsName(): Text[100]
    begin
        exit(MiscCostsOfOperationsLbl);
    end;

    procedure FinancialChargesName(): Text[100]
    begin
        exit(FinancialChargesLbl);
    end;

    procedure InterestOnBankAccountName(): Text[100]
    begin
        exit(InterestOnBankAccountLbl);
    end;

    procedure UnrealizedExchRateDiffExpenseName(): Text[100]
    begin
        exit(UnrealizedExchRateDiffExpenseLbl);
    end;

    procedure RealizedExchRateDiffExpenseName(): Text[100]
    begin
        exit(RealizedExchRateDiffExpenseLbl);
    end;

    procedure BankChargesName(): Text[100]
    begin
        exit(BankChargesLbl);
    end;

    procedure StockExchangeTurnoverTaxName(): Text[100]
    begin
        exit(StockExchangeTurnoverTaxLbl);
    end;

    procedure LossesDisposalFixedAssetsName(): Text[100]
    begin
        exit(LossesDisposalFixedAssetsLbl);
    end;

    procedure TransferToDutyFreeReserveName(): Text[100]
    begin
        exit(TransferToDutyFreeReserveLbl);
    end;

    procedure ProcessingOfResultTransferName(): Text[100]
    begin
        exit(ProcessingOfResultTransferLbl);
    end;

    procedure LossCarrForwFrPrevFyName(): Text[100]
    begin
        exit(LossCarrForwFrPrevFyLbl);
    end;

    procedure AddCapitalIssuingPremName(): Text[100]
    begin
        exit(AddCapitalIssuingPremLbl);
    end;

    procedure AddReservesName(): Text[100]
    begin
        exit(AddReservesLbl);
    end;

    procedure ProfitToBeCarriedForwardName(): Text[100]
    begin
        exit(ProfitToBeCarriedForwardLbl);
    end;

    procedure ReturnOnCapitalName(): Text[100]
    begin
        exit(ReturnOnCapitalLbl);
    end;

    procedure DirectorsRemunerationName(): Text[100]
    begin
        exit(DirectorsRemunerationLbl);
    end;

    procedure SalesRawMatDomName(): Text[100]
    begin
        exit(SalesRawMatDomLbl);
    end;

    procedure SalesRawMatEuName(): Text[100]
    begin
        exit(SalesRawMatEuLbl);
    end;

    procedure SalesRawMatExportName(): Text[100]
    begin
        exit(SalesRawMatExportLbl);
    end;

    procedure SalesJobsName(): Text[100]
    begin
        exit(SalesJobsLbl);
    end;

    procedure ConsultingFeesName(): Text[100]
    begin
        exit(ConsultingFeesLbl);
    end;

    procedure PaymentDiscGrantedName(): Text[100]
    begin
        exit(PaymentDiscGrantedLbl);
    end;

    procedure InventoryAdjustmentsDiscountName(): Text[100]
    begin
        exit(InventoryAdjustmentsDiscountLbl);
    end;

    procedure ProducedFixedAssetsName(): Text[100]
    begin
        exit(ProducedFixedAssetsLbl);
    end;

    procedure OtherOperatingIncomeName(): Text[100]
    begin
        exit(OtherOperatingIncomeLbl);
    end;

    procedure JobCostAdjustmentRetailDiscName(): Text[100]
    begin
        exit(JobCostAdjustmentRetailDiscLbl);
    end;

    procedure JobCostAdjustmentRawMatIncomeName(): Text[100]
    begin
        exit(JobCostAdjustmentRawMatIncomeLbl);
    end;

    procedure JobCostAdjustmentResourcesIncomeName(): Text[100]
    begin
        exit(JobCostAdjustmentResourcesIncomeLbl);
    end;

    procedure FinancialIncomeName(): Text[100]
    begin
        exit(FinancialIncomeLbl);
    end;

    procedure IncomeFromLoansName(): Text[100]
    begin
        exit(IncomeFromLoansLbl);
    end;

    procedure InterestOnBankAccountsRecName(): Text[100]
    begin
        exit(InterestOnBankAccountsRecLbl);
    end;

    procedure PaymentDiscReceivedName(): Text[100]
    begin
        exit(PaymentDiscReceivedLbl);
    end;

    procedure UnrealizedExchRateDiffIncomeName(): Text[100]
    begin
        exit(UnrealizedExchRateDiffIncomeLbl);
    end;

    procedure RealizedExchRateDiffIncomeName(): Text[100]
    begin
        exit(RealizedExchRateDiffIncomeLbl);
    end;

    procedure GainsOnDisposalFixedAssetsName(): Text[100]
    begin
        exit(GainsOnDisposalFixedAssetsLbl);
    end;

    procedure TaxesDuePaidName(): Text[100]
    begin
        exit(TaxesDuePaidLbl);
    end;

    procedure DeferredFromDutyFreeResName(): Text[100]
    begin
        exit(DeferredFromDutyFreeResLbl);
    end;

    procedure ProcessingOfResultDeferredName(): Text[100]
    begin
        exit(ProcessingOfResultDeferredLbl);
    end;

    procedure BenefitCarrFwFrPrevFyName(): Text[100]
    begin
        exit(BenefitCarrFwFrPrevFyLbl);
    end;

    procedure LossToBeCarriedForwardName(): Text[100]
    begin
        exit(LossToBeCarriedForwardLbl);
    end;

    procedure AssociateIntervInLossName(): Text[100]
    begin
        exit(AssociateIntervInLossLbl);
    end;

    procedure OwnersEquityDebts1Year(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OwnersEquityDebts1YearName()));
    end;

    procedure Capital(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapitalName()));
    end;

    procedure StockCapital(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StockCapitalName()));
    end;

    procedure NotCalledUpStockCapital(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(NotCalledUpStockCapitalName()));
    end;

    procedure IssuingPremiums(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IssuingPremiumsName()));
    end;

    procedure PlusValuesOfReevaluation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PlusValuesOfReevaluationName()));
    end;

    procedure Reserve(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReserveName()));
    end;

    procedure CapitalSubventions(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapitalSubventionsName()));
    end;

    procedure AllowancesForDoubtfulAcc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AllowancesForDoubtfulAccName()));
    end;

    procedure DebtsDueAt1Year(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DebtsDueAt1YearName()));
    end;

    procedure FixedAssetsCredits1Year(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FixedAssetsCredits1YearName()));
    end;

    procedure PreliminaryExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PreliminaryExpensesName()));
    end;

    procedure FormationIncrOfCapital(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FormationIncrOfCapitalName()));
    end;

    procedure DeprecFormIncrOfCapDepreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeprecFormIncrOfCapDepreciationName()));
    end;

    procedure IntangibleAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IntangibleAssetsName()));
    end;

    procedure ResearchDevelopment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResearchDevelopmentName()));
    end;

    procedure DeprResearchDevelopment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeprResearchDevelopmentName()));
    end;

    procedure DeprecBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeprecBuildingsName()));
    end;

    procedure EquipmentTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquipmentTotalName()));
    end;

    procedure Equipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EquipmentName()));
    end;

    procedure DeprecEquipmentDepreciation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeprecEquipmentDepreciationName()));
    end;

    procedure FurnituresAndRollingStock(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FurnituresAndRollingStockName()));
    end;

    procedure Furnitures(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FurnituresName()));
    end;

    procedure DeprecFurnitures(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeprecFurnituresName()));
    end;

    procedure OfficeEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OfficeEquipmentName()));
    end;

    procedure DeprecOfficeEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeprecOfficeEquipmentName()));
    end;

    procedure ComputerEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ComputerEquipmentName()));
    end;

    procedure DeprecComputerEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeprecComputerEquipmentName()));
    end;

    procedure RollingStock(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RollingStockName()));
    end;

    procedure DeprecRollingStockFurniture(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeprecRollingStockFurnitureName()));
    end;

    procedure FixedAssetsOnLeasing(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FixedAssetsOnLeasingName()));
    end;

    procedure Leasings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LeasingsName()));
    end;

    procedure DeprecLeasings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeprecLeasingsName()));
    end;

    procedure OtherTangibleFaTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherTangibleFaTotalName()));
    end;

    procedure OtherTangibleFa(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherTangibleFaName()));
    end;

    procedure DeprecOtherTangibleFa(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeprecOtherTangibleFaName()));
    end;

    procedure InventoryAndOrders(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryAndOrdersName()));
    end;

    procedure PostedDepreciationsAuxiliary(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PostedDepreciationsAuxiliaryName()));
    end;

    procedure AuxiliaryMaterialsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AuxiliaryMaterialsTotalName()));
    end;

    procedure AuxiliaryMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AuxiliaryMaterialsName()));
    end;

    procedure AuxiliaryMaterialsInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AuxiliaryMaterialsInterimName()));
    end;

    procedure PostedDepreciationsRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PostedDepreciationsRawMaterialsName()));
    end;

    procedure GoodsBeingMadeTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsBeingMadeTotalName()));
    end;

    procedure GoodsBeingMade(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsBeingMadeName()));
    end;

    procedure GoodsBeingMadeInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsBeingMadeInterimName()));
    end;

    procedure PostedDepreciationsGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PostedDepreciationsGoodsName()));
    end;

    procedure PostedDepreciationsFinishedGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PostedDepreciationsFinishedGoodsName()));
    end;

    procedure GoodsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsTotalName()));
    end;

    procedure Goods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsName()));
    end;

    procedure GoodsInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsInterimName()));
    end;

    procedure PostedDepreciationsGoodsInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PostedDepreciationsGoodsInterimName()));
    end;

    procedure VendorPrepayments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorPrepaymentsName()));
    end;

    procedure DebtsCreditsDue1Year(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DebtsCreditsDue1YearName()));
    end;

    procedure BillsOfExchReceivable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BillsOfExchReceivableName()));
    end;

    procedure CreditsReceivable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CreditsReceivableName()));
    end;

    procedure CustomerPrepayments(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerPrepaymentsName()));
    end;

    procedure DoubtfulDebtors(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DoubtfulDebtorsName()));
    end;

    procedure VatRecoverable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VatRecoverableName()));
    end;

    procedure OtherDoubtfulDebtors(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherDoubtfulDebtorsName()));
    end;

    procedure DebtsDueWithin1Year(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DebtsDueWithin1YearName()));
    end;

    procedure RedemptionOfLoan(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RedemptionOfLoanName()));
    end;

    procedure FinancialDebts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialDebtsName()));
    end;

    procedure BankAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankAccountName()));
    end;

    procedure BillsOfExchPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BillsOfExchPayableName()));
    end;

    procedure TaxesSalariesSocCharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxesSalariesSocChargesName()));
    end;

    procedure EstimatedTaxesPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EstimatedTaxesPayableName()));
    end;

    procedure TaxesPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxesPayableName()));
    end;

    procedure RetainedDeductionsAtSource(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RetainedDeductionsAtSourceName()));
    end;

    procedure SocialSecurityTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SocialSecurityTotalName()));
    end;

    procedure WagesAndSalaries(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WagesAndSalariesName()));
    end;

    procedure OtherSocialCharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherSocialChargesName()));
    end;

    procedure DebtsByResultAllocation(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DebtsByResultAllocationName()));
    end;

    procedure DividendsFormerFiscalYrs(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DividendsFormerFiscalYrsName()));
    end;

    procedure DividendsFiscalYear(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DividendsFiscalYearName()));
    end;

    procedure MiscellaneousDebts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscellaneousDebtsName()));
    end;

    procedure TransitAccounts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TransitAccountsName()));
    end;

    procedure CodaTemporaryAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CodaTemporaryAccountName()));
    end;

    procedure InvestmentsLiquidities(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InvestmentsLiquiditiesName()));
    end;

    procedure OwnersStockEquity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OwnersStockEquityName()));
    end;

    procedure Stocks(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StocksName()));
    end;

    procedure StockBuyIn(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StockBuyInName()));
    end;

    procedure BankLocalCurrency(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankLocalCurrencyName()));
    end;

    procedure BankProcessing(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankProcessingName()));
    end;

    procedure BankForeignCurrency(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankForeignCurrencyName()));
    end;

    procedure PostAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PostAccountName()));
    end;

    procedure Transfers(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TransfersName()));
    end;

    procedure Expenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExpensesName()));
    end;

    procedure GoodsRawAuxMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GoodsRawAuxMaterialsName()));
    end;

    procedure PurchasesRawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesRawMaterialsName()));
    end;

    procedure PurchasesRawMatDom(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesRawMatDomName()));
    end;

    procedure PurchasesRawMatEu(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesRawMatEuName()));
    end;

    procedure PurchasesRawMatExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesRawMatExportName()));
    end;

    procedure PurchasesAuxiliaryMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesAuxiliaryMaterialsName()));
    end;

    procedure PurchasesServices(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesServicesName()));
    end;

    procedure ResourceUsageCosts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResourceUsageCostsName()));
    end;

    procedure GeneralSubcontractings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GeneralSubcontractingsName()));
    end;

    procedure PurchasesOfGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesOfGoodsName()));
    end;

    procedure PurchasesRetailDom(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesRetailDomName()));
    end;

    procedure PurchasesRetailEu(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesRetailEuName()));
    end;

    procedure PurchasesRetailExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchasesRetailExportName()));
    end;

    procedure DiscountsReceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DiscountsReceivedName()));
    end;

    procedure InventoryAdjustmentsSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryAdjustmentsSalesName()));
    end;

    procedure InventAdjRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventAdjRetailName()));
    end;

    procedure InventAdjRetailInt(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventAdjRetailIntName()));
    end;

    procedure JobCostAdjustmentRetailSales(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostAdjustmentRetailSalesName()));
    end;

    procedure InventAdjRawMat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventAdjRawMatName()));
    end;

    procedure InventAdjRawMatInt(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventAdjRawMatIntName()));
    end;

    procedure JobCostAdjustmentRawMatInventory(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostAdjustmentRawMatInventoryName()));
    end;

    procedure JobCostAdjustmentResourcesInventory(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostAdjustmentResourcesInventoryName()));
    end;

    procedure ServicesAndInvestmentGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServicesAndInvestmentGoodsName()));
    end;

    procedure RentBuildingsRsEquipm(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RentBuildingsRsEquipmName()));
    end;

    procedure RMBuildingsAndEquipm(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RMBuildingsAndEquipmName()));
    end;

    procedure RMRollingStock(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RMRollingStockName()));
    end;

    procedure CleaningProducts(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CleaningProductsName()));
    end;

    procedure ElectricityWaterAndHeating(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ElectricityWaterAndHeatingName()));
    end;

    procedure Mailings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MailingsName()));
    end;

    procedure InsurancesRsFire(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsurancesRsFireName()));
    end;

    procedure LawyersAndAccountants(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LawyersAndAccountantsName()));
    end;

    procedure LegalContests(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LegalContestsName()));
    end;

    procedure OtherServiceCharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherServiceChargesName()));
    end;

    procedure PurchaseCostsRawMat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseCostsRawMatName()));
    end;

    procedure PurchaseCostsRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseCostsRetailName()));
    end;

    procedure PurchaseCostsInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseCostsInterimName()));
    end;

    procedure TranspCostsPurchRawMat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TranspCostsPurchRawMatName()));
    end;

    procedure TranspCostsPurchRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TranspCostsPurchRetailName()));
    end;

    procedure Brokerage(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BrokerageName()));
    end;

    procedure SocialSecurity(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SocialSecurityName()));
    end;

    procedure OtherPersonnelExpenses(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherPersonnelExpensesName()));
    end;

    procedure Depreciations(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationsName()));
    end;

    procedure DeprecFormIncrOfCapPremilary(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeprecFormIncrOfCapPremilaryName()));
    end;

    procedure DeprecLandAndBuildings(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeprecLandAndBuildingsName()));
    end;

    procedure DepreciationEquipment(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationEquipmentName()));
    end;

    procedure DepreciationRollingStock(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DepreciationRollingStockName()));
    end;

    procedure VehicleTaxes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VehicleTaxesName()));
    end;

    procedure Fines(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinesName()));
    end;

    procedure MiscCostsOfOperations(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MiscCostsOfOperationsName()));
    end;

    procedure FinancialCharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialChargesName()));
    end;

    procedure InterestOnBankAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestOnBankAccountName()));
    end;

    procedure UnrealizedExchRateDiffExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UnrealizedExchRateDiffExpenseName()));
    end;

    procedure RealizedExchRateDiffExpense(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RealizedExchRateDiffExpenseName()));
    end;

    procedure BankCharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BankChargesName()));
    end;

    procedure StockExchangeTurnoverTax(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(StockExchangeTurnoverTaxName()));
    end;

    procedure LossesDisposalFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LossesDisposalFixedAssetsName()));
    end;

    procedure TransferToDutyFreeReserve(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TransferToDutyFreeReserveName()));
    end;

    procedure ProcessingOfResultTransfer(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProcessingOfResultTransferName()));
    end;

    procedure LossCarrForwFrPrevFy(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LossCarrForwFrPrevFyName()));
    end;

    procedure AddCapitalIssuingPrem(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AddCapitalIssuingPremName()));
    end;

    procedure AddReserves(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AddReservesName()));
    end;

    procedure ProfitToBeCarriedForward(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProfitToBeCarriedForwardName()));
    end;

    procedure ReturnOnCapital(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReturnOnCapitalName()));
    end;

    procedure DirectorsRemuneration(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DirectorsRemunerationName()));
    end;

    procedure SalesRawMatDom(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRawMatDomName()));
    end;

    procedure SalesRawMatEu(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRawMatEuName()));
    end;

    procedure SalesRawMatExport(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesRawMatExportName()));
    end;

    procedure SalesJobs(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesJobsName()));
    end;

    procedure ConsultingFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ConsultingFeesName()));
    end;

    procedure PaymentDiscGranted(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymentDiscGrantedName()));
    end;

    procedure InventoryAdjustmentsDiscount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryAdjustmentsDiscountName()));
    end;

    procedure ProducedFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProducedFixedAssetsName()));
    end;

    procedure OtherOperatingIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherOperatingIncomeName()));
    end;

    procedure JobCostAdjustmentRetailDisc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostAdjustmentRetailDiscName()));
    end;

    procedure JobCostAdjustmentRawMatIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostAdjustmentRawMatIncomeName()));
    end;

    procedure JobCostAdjustmentResourcesIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(JobCostAdjustmentResourcesIncomeName()));
    end;

    procedure FinancialIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinancialIncomeName()));
    end;

    procedure IncomeFromLoans(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IncomeFromLoansName()));
    end;

    procedure InterestOnBankAccountsRec(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InterestOnBankAccountsRecName()));
    end;

    procedure PaymentDiscReceived(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PaymentDiscReceivedName()));
    end;

    procedure UnrealizedExchRateDiffIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(UnrealizedExchRateDiffIncomeName()));
    end;

    procedure RealizedExchRateDiffIncome(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RealizedExchRateDiffIncomeName()));
    end;

    procedure GainsOnDisposalFixedAssets(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GainsOnDisposalFixedAssetsName()));
    end;

    procedure TaxesDuePaid(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TaxesDuePaidName()));
    end;

    procedure DeferredFromDutyFreeRes(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DeferredFromDutyFreeResName()));
    end;

    procedure ProcessingOfResultDeferred(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProcessingOfResultDeferredName()));
    end;

    procedure BenefitCarrFwFrPrevFy(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BenefitCarrFwFrPrevFyName()));
    end;

    procedure LossToBeCarriedForward(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LossToBeCarriedForwardName()));
    end;

    procedure AssociateIntervInLoss(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AssociateIntervInLossName()));
    end;

    procedure ExtraordinaryExpensesTotalName(): Text[100]
    begin
        exit(ExtraordinaryExpensesTotalLbl);
    end;

    procedure ExtraordinaryExpensesTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExtraordinaryExpensesTotalName()));
    end;

    procedure CorporateTaxTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CorporateTaxTotalName()));
    end;

    procedure CorporateTaxTotalName(): Text[100]
    begin
        exit(CorporateTaxTotalLbl);
    end;

    procedure CorporateTaxDue(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CorporateTaxDueName()));
    end;

    procedure CorporateTaxDueName(): Text[100]
    begin
        exit(CorporateTaxDueLbl);
    end;

    procedure ExtraordinaryIncomeTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ExtraordinaryIncomeTotalName()));
    end;

    procedure ExtraordinaryIncomeTotalName(): Text[100]
    begin
        exit(ExtraordinaryIncomeTotalLbl);
    end;

    procedure FinishedGoodsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinishedGoodsTotalName()));
    end;

    procedure FinishedGoodsTotalName(): Text[100]
    begin
        exit(FinishedGoodsTotalLbl);
    end;

    procedure RawMaterialsTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RawMaterialsTotalName()));
    end;

    procedure RawMaterialsTotalName(): Text[100]
    begin
        exit(RawMaterialsTotalLbl);
    end;

    procedure CashDiscrepanciesFinancial(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CashDiscrepanciesFinancialName()));
    end;

    procedure CashDiscrepanciesFinancialName(): Text[100]
    begin
        exit(CashDiscrepanciesFinancialLbl);
    end;

    procedure BEMortgage(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(BEMortgageName()));
    end;

    procedure BEMortgageName(): Text[100]
    begin
        exit(BEMortgageNameLbl);
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        OwnersEquityDebts1YearLbl: Label 'OWNER''S EQUITY & DEBTS +1 YEAR', MaxLength = 100;
        CapitalLbl: Label 'Capital', MaxLength = 100;
        CashDiscrepanciesFinancialLbl: Label 'Cash Discrepancies Financial', MaxLength = 100;
        BEMortgageNameLbl: Label 'Mortgage BE', MaxLength = 100;
        StockCapitalLbl: Label 'Stock Capital', MaxLength = 100;
        NotCalledUpStockCapitalLbl: Label 'Not called up Stock Capital', MaxLength = 100;
        IssuingPremiumsLbl: Label 'Issuing premiums', MaxLength = 100;
        PlusValuesOfReevaluationLbl: Label 'Plus values of reevaluation', MaxLength = 100;
        ReserveLbl: Label 'Reserve', MaxLength = 100;
        CapitalSubventionsLbl: Label 'Capital Subventions', MaxLength = 100;
        AllowancesForDoubtfulAccLbl: Label 'Allowances for Doubtful Acc.', MaxLength = 100;
        DebtsDueAt1YearLbl: Label 'Debts, due at +1 Year', MaxLength = 100;
        FixedAssetsCredits1YearLbl: Label 'FIXED ASSETS & CREDITS +1 YEAR', MaxLength = 100;
        PreliminaryExpensesLbl: Label 'Preliminary Expenses', MaxLength = 100;
        FormationIncrOfCapitalLbl: Label 'Formation & incr. of capital', MaxLength = 100;
        DeprecFormIncrOfCapDepreciationLbl: Label 'Deprec., Form. & incr. of cap. - Depreciation', MaxLength = 100;
        IntangibleAssetsLbl: Label 'Intangible Assets', MaxLength = 100;
        ResearchDevelopmentLbl: Label 'Research & Development', MaxLength = 100;
        DeprResearchDevelopmentLbl: Label 'Depr., Research & Development', MaxLength = 100;
        DeprecBuildingsLbl: Label 'Deprec., Buildings', MaxLength = 100;
        EquipmentTotalLbl: Label 'Equipment - Total', MaxLength = 100;
        EquipmentLbl: Label 'Equipment', MaxLength = 100;
        DeprecEquipmentDepreciationLbl: Label 'Deprec., Equipment - Depreciation', MaxLength = 100;
        FurnituresAndRollingStockLbl: Label 'Furnitures and Rolling Stock', MaxLength = 100;
        FurnituresLbl: Label 'Furnitures', MaxLength = 100;
        DeprecFurnituresLbl: Label 'Deprec., Furnitures', MaxLength = 100;
        OfficeEquipmentLbl: Label 'Office Equipment', MaxLength = 100;
        DeprecOfficeEquipmentLbl: Label 'Deprec., Office Equipment', MaxLength = 100;
        ComputerEquipmentLbl: Label 'Computer Equipment', MaxLength = 100;
        DeprecComputerEquipmentLbl: Label 'Deprec., Computer Equipment', MaxLength = 100;
        RollingStockLbl: Label 'Rolling Stock', MaxLength = 100;
        DeprecRollingStockFurnitureLbl: Label 'Deprec., Rolling Stock - Furniture', MaxLength = 100;
        FixedAssetsOnLeasingLbl: Label 'Fixed Assets on leasing', MaxLength = 100;
        LeasingsLbl: Label 'Leasings', MaxLength = 100;
        DeprecLeasingsLbl: Label 'Deprec., Leasings', MaxLength = 100;
        OtherTangibleFaTotalLbl: Label 'Other tangible FA - Total', MaxLength = 100;
        OtherTangibleFaLbl: Label 'Other tangible FA', MaxLength = 100;
        DeprecOtherTangibleFaLbl: Label 'Deprec., Other tangible FA', MaxLength = 100;
        InventoryAndOrdersLbl: Label 'INVENTORY AND ORDERS', MaxLength = 100;
        PostedDepreciationsRawMaterialsLbl: Label 'Posted depreciations - Raw Materials', MaxLength = 100;
        AuxiliaryMaterialsTotalLbl: Label 'Auxiliary Materials - Total', MaxLength = 100;
        AuxiliaryMaterialsLbl: Label 'Auxiliary Materials', MaxLength = 100;
        AuxiliaryMaterialsInterimLbl: Label 'Auxiliary Materials (Interim)', MaxLength = 100;
        PostedDepreciationsAuxiliaryLbl: Label 'Posted depreciations - Auxiliary', MaxLength = 100;
        GoodsBeingMadeTotalLbl: Label 'Goods being made - Total', MaxLength = 100;
        GoodsBeingMadeLbl: Label 'Goods being made', MaxLength = 100;
        GoodsBeingMadeInterimLbl: Label 'Goods being made (Interim)', MaxLength = 100;
        PostedDepreciationsGoodsLbl: Label 'Posted depreciations - Goods', MaxLength = 100;
        PostedDepreciationsFinishedGoodsLbl: Label 'Posted depreciations - Finished Goods', MaxLength = 100;
        GoodsTotalLbl: Label 'Goods - Total', MaxLength = 100;
        GoodsLbl: Label 'Goods', MaxLength = 100;
        GoodsInterimLbl: Label 'Goods (Interim)', MaxLength = 100;
        PostedDepreciationsGoodsInterimLbl: Label 'Posted depreciations - Goods Interim', MaxLength = 100;
        VendorPrepaymentsLbl: Label 'Vendor Prepayments', MaxLength = 100;
        DebtsCreditsDue1YearLbl: Label 'DEBTS/CREDITS DUE -1 YEAR', MaxLength = 100;
        BillsOfExchReceivableLbl: Label 'Bills of Exch. Receivable', MaxLength = 100;
        CreditsReceivableLbl: Label 'Credits Receivable', MaxLength = 100;
        CustomerPrepaymentsLbl: Label 'Customer Prepayments', MaxLength = 100;
        DoubtfulDebtorsLbl: Label 'Doubtful Debtors', MaxLength = 100;
        VatRecoverableLbl: Label 'VAT Recoverable', MaxLength = 100;
        OtherDoubtfulDebtorsLbl: Label 'Other Doubtful Debtors', MaxLength = 100;
        DebtsDueWithin1YearLbl: Label 'Debts, due within +1 Year', MaxLength = 100;
        RedemptionOfLoanLbl: Label 'Redemption of Loan', MaxLength = 100;
        FinancialDebtsLbl: Label 'Financial Debts', MaxLength = 100;
        BankAccountLbl: Label 'Bank Account', MaxLength = 100;
        BillsOfExchPayableLbl: Label 'Bills of Exch. Payable', MaxLength = 100;
        TaxesSalariesSocChargesLbl: Label 'Taxes, Salaries & Soc. Charges', MaxLength = 100;
        EstimatedTaxesPayableLbl: Label 'Estimated Taxes Payable', MaxLength = 100;
        TaxesPayableLbl: Label 'Taxes Payable', MaxLength = 100;
        RetainedDeductionsAtSourceLbl: Label 'Retained Deductions at Source', MaxLength = 100;
        SocialSecurityTotalLbl: Label 'Social Security - Total', MaxLength = 100;
        WagesAndSalariesLbl: Label 'Wages and Salaries', MaxLength = 100;
        OtherSocialChargesLbl: Label 'Other Social Charges', MaxLength = 100;
        DebtsByResultAllocationLbl: Label 'Debts by Result Allocation', MaxLength = 100;
        DividendsFormerFiscalYrsLbl: Label 'Dividends, Former Fiscal Yrs', MaxLength = 100;
        DividendsFiscalYearLbl: Label 'Dividends, Fiscal Year', MaxLength = 100;
        MiscellaneousDebtsLbl: Label 'Miscellaneous Debts', MaxLength = 100;
        TransitAccountsLbl: Label 'Transit Accounts', MaxLength = 100;
        CodaTemporaryAccountLbl: Label 'CODA Temporary Account', MaxLength = 100;
        InvestmentsLiquiditiesLbl: Label 'INVESTMENTS & LIQUIDITIES', MaxLength = 100;
        OwnersStockEquityLbl: Label 'Owner''s Stock Equity', MaxLength = 100;
        StocksLbl: Label 'Stocks', MaxLength = 100;
        StockBuyInLbl: Label 'Stock Buy In', MaxLength = 100;
        BankLocalCurrencyLbl: Label 'Bank, Local Currency', MaxLength = 100;
        BankProcessingLbl: Label 'Bank, Processing', MaxLength = 100;
        BankForeignCurrencyLbl: Label 'Bank, Foreign Currency', MaxLength = 100;
        PostAccountLbl: Label 'Post Account', MaxLength = 100;
        TransfersLbl: Label 'Transfers', MaxLength = 100;
        ExpensesLbl: Label 'EXPENSES', MaxLength = 100;
        GoodsRawAuxMaterialsLbl: Label 'Goods, Raw & Aux. Materials', MaxLength = 100;
        PurchasesRawMaterialsLbl: Label 'Purchases, Raw Materials', MaxLength = 100;
        PurchasesRawMatDomLbl: Label 'Purchases, Raw Mat. - Dom.', MaxLength = 100;
        PurchasesRawMatEuLbl: Label 'Purchases, Raw Mat. - EU', MaxLength = 100;
        PurchasesRawMatExportLbl: Label 'Purchases, Raw Mat. - Export', MaxLength = 100;
        PurchasesAuxiliaryMaterialsLbl: Label 'Purchases, Auxiliary Materials', MaxLength = 100;
        PurchasesServicesLbl: Label 'Purchases, Services', MaxLength = 100;
        ResourceUsageCostsLbl: Label 'Resource Usage Costs', MaxLength = 100;
        GeneralSubcontractingsLbl: Label 'General Subcontractings', MaxLength = 100;
        PurchasesOfGoodsLbl: Label 'Purchases of Goods', MaxLength = 100;
        PurchasesRetailDomLbl: Label 'Purchases, Retail - Dom.', MaxLength = 100;
        PurchasesRetailEuLbl: Label 'Purchases, Retail - EU', MaxLength = 100;
        PurchasesRetailExportLbl: Label 'Purchases, Retail - Export', MaxLength = 100;
        DiscountsReceivedLbl: Label 'Discounts Received', MaxLength = 100;
        InventoryAdjustmentsSalesLbl: Label 'Inventory Adjustments - Sales', MaxLength = 100;
        InventAdjRetailLbl: Label 'Invent. Adj., Retail', MaxLength = 100;
        InventAdjRetailIntLbl: Label 'Invent. Adj., Retail (Int.)', MaxLength = 100;
        JobCostAdjustmentRetailSalesLbl: Label 'Job Cost Adjustment, Retail - Sales', MaxLength = 100;
        InventAdjRawMatLbl: Label 'Invent. Adj., Raw Mat.', MaxLength = 100;
        InventAdjRawMatIntLbl: Label 'Invent. Adj., Raw Mat. (Int.)', MaxLength = 100;
        JobCostAdjustmentRawMatInventoryLbl: Label 'Job Cost Adjustment, Raw Mat. - Inv.', MaxLength = 100;
        JobCostAdjustmentResourcesInventoryLbl: Label 'Job Cost Adjustment, Resources - Inv.', MaxLength = 100;
        ServicesAndInvestmentGoodsLbl: Label 'Services and Investment Goods', MaxLength = 100;
        RentBuildingsRsEquipmLbl: Label 'Rent (Buildings, RS, Equipm.)', MaxLength = 100;
        RMBuildingsAndEquipmLbl: Label 'R & M., Buildings and Equipm.', MaxLength = 100;
        RMRollingStockLbl: Label 'R & M., Rolling Stock', MaxLength = 100;
        CleaningProductsLbl: Label 'Cleaning Products', MaxLength = 100;
        ElectricityWaterAndHeatingLbl: Label 'Electricity, Water and Heating', MaxLength = 100;
        MailingsLbl: Label 'Mailings', MaxLength = 100;
        InsurancesRsFireLbl: Label 'Insurances (RS, Fire, ...)', MaxLength = 100;
        LawyersAndAccountantsLbl: Label 'Lawyers and Accountants', MaxLength = 100;
        LegalContestsLbl: Label 'Legal Contests', MaxLength = 100;
        OtherServiceChargesLbl: Label 'Other Service Charges', MaxLength = 100;
        PurchaseCostsRawMatLbl: Label 'Purchase Costs, Raw Mat.', MaxLength = 100;
        PurchaseCostsRetailLbl: Label 'Purchase Costs, Retail', MaxLength = 100;
        PurchaseCostsInterimLbl: Label 'Purchase Costs (Interim)', MaxLength = 100;
        TranspCostsPurchRawMatLbl: Label 'Transp. Costs purch. Raw Mat.', MaxLength = 100;
        TranspCostsPurchRetailLbl: Label 'Transp. Costs purch. Retail', MaxLength = 100;
        BrokerageLbl: Label 'Brokerage', MaxLength = 100;
        SocialSecurityLbl: Label 'Social Security', MaxLength = 100;
        OtherPersonnelExpensesLbl: Label 'Other Personnel Expenses', MaxLength = 100;
        DepreciationsLbl: Label 'Depreciations', MaxLength = 100;
        DeprecFormIncrOfCapPremilaryLbl: Label 'Deprec., Form. & incr. of cap. - Premilary', MaxLength = 100;
        DeprecLandAndBuildingsLbl: Label 'Deprec., Land and Buildings', MaxLength = 100;
        DepreciationEquipmentLbl: Label 'Depreciation, Equipment', MaxLength = 100;
        DepreciationRollingStockLbl: Label 'Depreciation, Rolling Stock', MaxLength = 100;
        VehicleTaxesLbl: Label 'Vehicle Taxes', MaxLength = 100;
        FinesLbl: Label 'Fines', MaxLength = 100;
        MiscCostsOfOperationsLbl: Label 'Misc. Costs of Operations', MaxLength = 100;
        FinancialChargesLbl: Label 'Financial Charges', MaxLength = 100;
        InterestOnBankAccountLbl: Label 'Interest on Bank Account', MaxLength = 100;
        UnrealizedExchRateDiffExpenseLbl: Label 'Unrealized Exch. Rate Diff. - Expense', MaxLength = 100;
        RealizedExchRateDiffExpenseLbl: Label 'Realized Exch. Rate Diff. - Expense', MaxLength = 100;
        BankChargesLbl: Label 'Bank Charges', MaxLength = 100;
        StockExchangeTurnoverTaxLbl: Label 'Stock Exchange Turnover Tax', MaxLength = 100;
        LossesDisposalFixedAssetsLbl: Label 'Losses/Disposal Fixed Assets', MaxLength = 100;
        TransferToDutyFreeReserveLbl: Label 'Transfer to duty-free reserve', MaxLength = 100;
        ProcessingOfResultTransferLbl: Label 'Processing of Result - Transfer', MaxLength = 100;
        LossCarrForwFrPrevFyLbl: Label 'Loss carr. forw. fr. Prev. FY', MaxLength = 100;
        AddCapitalIssuingPremLbl: Label 'Add. capital & issuing prem.', MaxLength = 100;
        AddReservesLbl: Label 'Add. reserves', MaxLength = 100;
        ProfitToBeCarriedForwardLbl: Label 'Profit to be carried forward', MaxLength = 100;
        ReturnOnCapitalLbl: Label 'Return on Capital', MaxLength = 100;
        DirectorsRemunerationLbl: Label 'Director''s remuneration', MaxLength = 100;
        SalesRawMatDomLbl: Label 'Sales, Raw Mat. - Dom.', MaxLength = 100;
        SalesRawMatEuLbl: Label 'Sales, Raw Mat. - EU', MaxLength = 100;
        SalesRawMatExportLbl: Label 'Sales, Raw Mat. - Export', MaxLength = 100;
        SalesJobsLbl: Label 'Sales, Jobs', MaxLength = 100;
        ConsultingFeesLbl: Label 'Consulting Fees', MaxLength = 100;
        PaymentDiscGrantedLbl: Label 'Payment Disc. Granted', MaxLength = 100;
        InventoryAdjustmentsDiscountLbl: Label 'Inventory Adjustments - Discount', MaxLength = 100;
        ProducedFixedAssetsLbl: Label 'Produced Fixed Assets', MaxLength = 100;
        OtherOperatingIncomeLbl: Label 'Other Operating Income', MaxLength = 100;
        JobCostAdjustmentRetailDiscLbl: Label 'Job Cost Adjustment, Retail - Disc.', MaxLength = 100;
        JobCostAdjustmentRawMatIncomeLbl: Label 'Job Cost Adjustment, Raw Mat. - Income', MaxLength = 100;
        JobCostAdjustmentResourcesIncomeLbl: Label 'Job Cost Adjustment, Resources - Income', MaxLength = 100;
        FinancialIncomeLbl: Label 'Financial Income', MaxLength = 100;
        IncomeFromLoansLbl: Label 'Income from Loans', MaxLength = 100;
        InterestOnBankAccountsRecLbl: Label 'Interest on Bank Accounts Rec.', MaxLength = 100;
        PaymentDiscReceivedLbl: Label 'Payment Disc. Received', MaxLength = 100;
        UnrealizedExchRateDiffIncomeLbl: Label 'Unrealized Exch. Rate Diff. - Income', MaxLength = 100;
        RealizedExchRateDiffIncomeLbl: Label 'Realized Exch. Rate Diff. - Income', MaxLength = 100;
        GainsOnDisposalFixedAssetsLbl: Label 'Gains on Disposal Fixed Assets', MaxLength = 100;
        TaxesDuePaidLbl: Label 'Taxes Due Paid', MaxLength = 100;
        DeferredFromDutyFreeResLbl: Label 'Deferred from Duty-free Res.', MaxLength = 100;
        ProcessingOfResultDeferredLbl: Label 'Processing of Result - Deferred', MaxLength = 100;
        BenefitCarrFwFrPrevFyLbl: Label 'Benefit, carr. fw fr. Prev. FY', MaxLength = 100;
        LossToBeCarriedForwardLbl: Label 'Loss to be carried forward', MaxLength = 100;
        AssociateIntervInLossLbl: Label 'Associate Interv. in Loss', MaxLength = 100;
        ExtraordinaryExpensesTotalLbl: Label 'Extraordinary Expenses - Total', MaxLength = 100;
        CorporateTaxTotalLbl: Label 'Corporate Tax - Total', MaxLength = 100;
        CorporateTaxDueLbl: Label 'Corporate Tax Due', MaxLength = 100;
        ExtraordinaryIncomeTotalLbl: Label 'Extraordinary Income BE', MaxLength = 100;
        FinishedGoodsTotalLbl: Label 'Finished Goods Total', MaxLength = 100;
        RawMaterialsTotalLbl: Label 'Raw Materials - Total', MaxLength = 100;
}