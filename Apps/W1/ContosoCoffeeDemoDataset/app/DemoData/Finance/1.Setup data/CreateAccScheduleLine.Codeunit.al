codeunit 5224 "Create Acc. Schedule Line"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    // TODO: MS
    // 3. Investigate 5 digit G/L Account could not be found e.g. 10990

    trigger OnRun()
    var
        CreateAccountScheduleName: Codeunit "Create Acc. Schedule Name";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
        CreateGLAccount: Codeunit "Create G/L Account";
        AccountScheduleName: Code[10];
    begin
        ContosoAccountSchedule.InsertAccScheduleLine('', 10000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine('', 20000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine('', 30000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine('', 40000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine('', 50000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine('', 60000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine('', 70000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine('', 80000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine('', 90000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);

        AccountScheduleName := CreateAccountScheduleName.AccountCategoriesOverview();
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 10000, '1000', BalanceSheetLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 20000, '1010', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 30000, '2000', AssessLbl, '1', Enum::"Acc. Schedule Line Totaling Type"::"Account Category", Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 40000, '3000', LiabilityLbl, '10', Enum::"Acc. Schedule Line Totaling Type"::"Account Category", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 50000, '4000', EquityLbl, '14', Enum::"Acc. Schedule Line Totaling Type"::"Account Category", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 60000, '4010', IncomeThisYearLbl, CreateGLAccount.NetIncome(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 70000, '5000', UpperCase(LiabilityLbl), '3000..4010', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 80000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 90000, '6000', IncomeStatementLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 100000, '7000', IncomeLbl, '18', Enum::"Acc. Schedule Line Totaling Type"::"Account Category", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 110000, '8000', CostOfGoodsSoldLbl, '26', Enum::"Acc. Schedule Line Totaling Type"::"Account Category", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 120000, '9000', ExpenseLbl, '31', Enum::"Acc. Schedule Line Totaling Type"::"Account Category", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 130000, '9900', NetIncomeLbl, '7000..9000', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);

        AccountScheduleName := CreateAccountScheduleName.CapitalStructure();
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 10000, '', ACIDTestAnalysisLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 20000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 30000, '', CurrentAssetsLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 40000, '101', InventoryLbl, CreateGLAccount.InventoryTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 50000, '102', AccountsReceivableLbl, CreateGLAccount.AccountsReceivableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 60000, '103', SecuritiesLbl, CreateGLAccount.SecuritiesTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 70000, '104', LiquidAssetsLbl, CreateGLAccount.LiquidAssetsTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 80000, '105', CurrentAssetsTotalLbl, '101..104', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 90000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 100000, '', ShortTermLiabilitiesLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 110000, '111', RevolvingCreditLbl, CreateGLAccount.RevolvingCredit(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 120000, '112', AccountsPayableLbl, CreateGLAccount.AccountsPayableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 130000, '113', VATLbl, CreateGLAccount.VATTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 140000, '114', PersonnelRelatedItemsLbl, CreateGLAccount.TotalPersonnelrelatedItems(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 150000, '115', OtherLiabilitiesLbl, CreateGLAccount.OtherLiabilitiesTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 160000, '116', ShortTermLiabilitiesTotalLbl, '111..115', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 170000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 180000, '', CAMinusShortTermLiabLbl, '105|116', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);

        AccountScheduleName := CreateAccountScheduleName.CashFlowCalculation();
        // '1-RECEIVABLES' is inserted somewhere, semi hardcode string
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 10000, 'R10', ReceivablesLbl, '1-RECEIVABLES', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 20000, 'R10', OpenSalesOrdersLbl, '6-SALES ORDERS', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 30000, 'R10', OpenServiceOrdersLbl, '10-SERVICE ORDERS', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 40000, 'R10', RentalsLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 50000, 'R10', FinancialAssetsLbl, '8-FIXED ASSETS BUDGE', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 60000, 'R10', FixedAssetsDisposalsLbl, '9-FIXED ASSETS DISPO', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 70000, 'R10', PrivateInvestmentsLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 80000, 'R10', MiscellaneousReceiptsLbl, '5-CASH FLOW MANUAL R', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 90000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 100000, 'R20', TotalofCashReceiptsLbl, 'R10', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 110000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 120000, 'R30', PayablesLbl, '2-PAYABLES', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 130000, 'R30', OpenPurchaseOrdersLbl, '7-PURCHASE ORDERS', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 140000, 'R30', PersonnelCostsLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 150000, 'R30', RunningCostsLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 160000, 'R30', FinanceCostsLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 170000, 'R30', MiscellaneousCostsLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 180000, 'R30', InvestmentsLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 190000, 'R30', EncashmentofBillsLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 200000, 'R30', PrivateConsumptionsLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 210000, 'R30', VATDueLbl, '15-TAX', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 220000, 'R30', OtherExpensesLbl, '4-CASH FLOW MANUAL E', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 230000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 240000, 'R40', TotalofCashDisbursementsLbl, 'R30', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 250000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 260000, 'R50', SurplusLbl, 'R10|R40', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 270000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 280000, 'R60', CashFlowFundsLbl, '3-LIQUID FUNDS', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, true, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 290000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Cash Flow Entry Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 300000, 'R70', TotalCashFlowLbl, 'R50|R60', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);

        AccountScheduleName := CreateAccountScheduleName.CashCycle();
        // ToDo: MS 10990 G/L Account could not be found
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 10000, '10', TotalRevenueLbl, '10990', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 20000, '20', TotalReceivablesLbl, '40400|46100..46330', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 30000, '30', TotalPayablesLbl, '50100|52000..56130', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 40000, '40', TotalInventoryLbl, '40700', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 50000, '100', DaysofSalesOutstandingLbl, '-360*''20''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 60000, '110', DaysofPaymentOutstandingLbl, '360*''30''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 70000, '120', DaysSalesofInventoryLbl, '-360*''40''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 80000, '200', CashCycleDaysLbl, '100+110-120', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);

        AccountScheduleName := CreateAccountScheduleName.CashFlow();
        // ranges like this are a problem. e.g. Localizations. Some can be bigger or smaller. Discuss later
        // Consider replace with Account Categories or discontinue.
        // Account Category won't need localization
        // 40400 is not found in W1
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 10000, '10', TotalReceivablesLbl, '40400|46100..46330', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 20000, '20', TotalPayablesLbl, '50100|52000..56130', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 30000, '30', TotalLiquidFundsLbl, '40100..40300', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 40000, '40', TotalCashFlowLbl, '40..60', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 1);

        AccountScheduleName := CreateAccountScheduleName.IncomeExpense();
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 10000, '10', TotalRevenueCreditLbl, '10990', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 20000, '11', TotalRevenueLbl, '-10', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 30000, '20', TotalGoodsSoldLbl, '20990', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 40000, '30', TotalExternalCostsLbl, '30100|30200|30400|30500|31300|31400', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 50000, '40', TotalPersonnelCostsLbl, '30700|30800|30900|31000|31100', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 60000, '50', TotalDeprOnFALbl, '31600', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 70000, '60', OtherExpensesLbl, '31500', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 80000, '70', TotalExpenditureLbl, '-20..60', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 90000, '80', EarningsBeforeInterestLbl, '11+70', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);

        AccountScheduleName := CreateAccountScheduleName.ReducedTrialBalance();
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 10000, '10', TotalIncomeLbl, '10990', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, true, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 20000, '20', TotalCostLbl, '20990', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, true, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 30000, '30', GrossMarginLbl, '-10-20', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 40000, '40', GrossMarginPerLbl, '-''30''/''10''*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 50000, '50', OperatingExpensesLbl, '30100..30200|30400..30500|30700..31100|31300..31400|31600', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 60000, '60', OperatingMarginLbl, '30 - 50', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 70000, '70', OperatingMarginPerLbl, '-''60''/''10''*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 80000, '80', OtherExpensesLbl, '30300|30600|31200|31500|31900', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 90000, '90', IncomeBeforeInterestAndTaxLbl, '31995', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, true, 0);

        AccountScheduleName := CreateAccountScheduleName.Revenues();
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 10000, '', REVENUELbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 20000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 30000, '', SalesofRetailLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 40000, '11', SalesRetailDomLbl, CreateGLAccount.SalesRetailDom(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 50000, '12', SalesRetailEULbl, CreateGLAccount.SalesRetailEU(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 60000, '13', SalesRetailExportLbl, CreateGLAccount.SalesRetailExport(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 70000, '14', JobSalesAdjmtRetailLbl, CreateGLAccount.JobSalesAppliedRetail(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 80000, '15', SalesofRetailTotalLbl, CreateGLAccount.TotalSalesofRetail(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 90000, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 100000, '', RevenueArea10to30TotalLbl, CreateGLAccount.SalesRetailDom() + '..' + CreateGLAccount.TotalSalesofRetail(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '10..30', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 110000, '', RevenueArea40to85TotalLbl, CreateGLAccount.SalesRetailDom() + '..' + CreateGLAccount.TotalSalesofRetail(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '40..85', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 120000, '', RevenueNoAreacodeTotalLbl, CreateGLAccount.SalesRetailDom() + '..' + CreateGLAccount.TotalSalesofRetail(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false, false, false, 0);
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 130000, '', RevenueTotalLbl, CreateGLAccount.SalesRetailDom() + '..' + CreateGLAccount.TotalSalesofRetail(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false, false, false, 0);
    end;

    var
        BalanceSheetLbl: Label 'BALANCE SHEET', MaxLength = 100;
        AssessLbl: Label 'ASSETS', MaxLength = 100;
        LiabilityLbl: Label 'Liabilities', MaxLength = 100;
        EquityLbl: Label 'Equity', MaxLength = 100;
        IncomeThisYearLbl: Label 'Income This Year', MaxLength = 100;
        IncomeStatementLbl: Label 'INCOME STATEMENT', MaxLength = 100;
        IncomeLbl: Label 'Income', MaxLength = 100;
        CostOfGoodsSoldLbl: Label 'Cost of Goods Sold', MaxLength = 100;
        ExpenseLbl: Label 'Expense', MaxLength = 100;
        NetIncomeLbl: Label 'NET INCOME', MaxLength = 100;
        ACIDTestAnalysisLbl: Label 'ACID-TEST ANALYSIS', MaxLength = 100;
        CurrentAssetsLbl: Label 'Current Assets', MaxLength = 100;
        InventoryLbl: Label 'Inventory', MaxLength = 100;
        AccountsReceivableLbl: Label 'Accounts Receivable', MaxLength = 100;
        SecuritiesLbl: Label 'Securities', MaxLength = 100;
        LiquidAssetsLbl: Label 'Liquid Assets', MaxLength = 100;
        CurrentAssetsTotalLbl: Label 'Current Assets, Total', MaxLength = 100;
        ShortTermLiabilitiesLbl: Label 'Short-term Liabilities', MaxLength = 100;
        RevolvingCreditLbl: Label 'Revolving Credit', MaxLength = 100;
        AccountsPayableLbl: Label 'Accounts Payable', MaxLength = 100;
        VATLbl: Label 'VAT', MaxLength = 100;
        PersonnelRelatedItemsLbl: Label 'Personnel-related Items', MaxLength = 100;
        OtherLiabilitiesLbl: Label 'Other Liabilities', MaxLength = 100;
        ShortTermLiabilitiesTotalLbl: Label 'Short-term Liabilities, Total', MaxLength = 100;
        CAMinusShortTermLiabLbl: Label 'Current Assets minus Short-term Liabilities', MaxLength = 100;
        ReceivablesLbl: Label 'Receivables', MaxLength = 100;
        OpenSalesOrdersLbl: Label 'Open Sales Orders', MaxLength = 100;
        OpenServiceOrdersLbl: Label 'Open service orders', MaxLength = 100;
        RentalsLbl: Label 'Rentals', MaxLength = 100;
        FinancialAssetsLbl: Label 'Financial Assets', MaxLength = 100;
        FixedAssetsDisposalsLbl: Label 'Fixed Assets Disposals', MaxLength = 100;
        PrivateInvestmentsLbl: Label 'Private Investments', MaxLength = 100;
        MiscellaneousReceiptsLbl: Label 'Miscellaneous receipts', MaxLength = 100;
        TotalofCashReceiptsLbl: Label 'Total of Cash Receipts', MaxLength = 100;
        PayablesLbl: Label 'Payables', MaxLength = 100;
        OpenPurchaseOrdersLbl: Label 'Open Purchase Orders', MaxLength = 100;
        PersonnelCostsLbl: Label 'Personnel costs', MaxLength = 100;
        RunningCostsLbl: Label 'Running costs', MaxLength = 100;
        FinanceCostsLbl: Label 'Finance Costs', MaxLength = 100;
        MiscellaneousCostsLbl: Label 'Miscellaneous costs', MaxLength = 100;
        InvestmentsLbl: Label 'Investments', MaxLength = 100;
        EncashmentofBillsLbl: Label 'Encashment of Bills', MaxLength = 100;
        PrivateConsumptionsLbl: Label 'Private Consumptions', MaxLength = 100;
        VATDueLbl: Label 'VAT Due', MaxLength = 100;
        OtherExpensesLbl: Label 'Other expenses', MaxLength = 100;
        TotalofCashDisbursementsLbl: Label 'Total of Cash Disbursements', MaxLength = 100;
        SurplusLbl: Label 'Surplus', MaxLength = 100;
        CashFlowFundsLbl: Label 'CashFlow Funds', MaxLength = 100;
        TotalCashFlowLbl: Label 'Total Cash Flow', MaxLength = 100;
        TotalRevenueLbl: Label 'Total Revenue', MaxLength = 100;
        TotalReceivablesLbl: Label 'Total Receivables', MaxLength = 100;
        TotalPayablesLbl: Label 'Total Payables', MaxLength = 100;
        TotalInventoryLbl: Label 'Total Inventory', MaxLength = 100;
        DaysofSalesOutstandingLbl: Label 'Days of Sales Outstanding', MaxLength = 100;
        DaysofPaymentOutstandingLbl: Label 'Days of Payment Outstanding', MaxLength = 100;
        DaysSalesofInventoryLbl: Label 'Days Sales of Inventory', MaxLength = 100;
        CashCycleDaysLbl: Label 'Cash Cycle (Days)', MaxLength = 100;
        TotalLiquidFundsLbl: Label 'Total Liquid Funds', MaxLength = 100;
        TotalRevenueCreditLbl: Label 'Total Revenue (Credit)', MaxLength = 100;
        TotalGoodsSoldLbl: Label 'Total Goods Sold', MaxLength = 100;
        TotalExternalCostsLbl: Label 'Total External Costs ', MaxLength = 100;
        TotalPersonnelCostsLbl: Label 'Total Personnel Costs', MaxLength = 100;
        TotalDeprOnFALbl: Label 'Total Depr. on Fixed Assets', MaxLength = 100;
        TotalExpenditureLbl: Label 'Total Expenditure', MaxLength = 100;
        EarningsBeforeInterestLbl: Label 'Earnings Before Interest', MaxLength = 100;
        TotalIncomeLbl: Label 'Total Income', MaxLength = 100;
        TotalCostLbl: Label 'Total Cost', MaxLength = 100;
        GrossMarginLbl: Label 'Gross Margin', MaxLength = 100;
        GrossMarginPerLbl: Label 'Gross Margin %', MaxLength = 100;
        OperatingExpensesLbl: Label 'Operating Expenses', MaxLength = 100;
        OperatingMarginLbl: Label 'Operating Margin', MaxLength = 100;
        OperatingMarginPerLbl: Label 'Operating Margin %', MaxLength = 100;
        IncomeBeforeInterestAndTaxLbl: Label 'Income before Interest and Tax', MaxLength = 100;
        REVENUELbl: Label 'REVENUE', MaxLength = 100;
        SalesofRetailLbl: Label 'Sales of Retail', MaxLength = 100;
        SalesRetailDomLbl: Label 'Sales, Retail - Dom.', MaxLength = 100;
        SalesRetailEULbl: Label 'Sales, Retail - EU', MaxLength = 100;
        SalesRetailExportLbl: Label 'Sales, Retail - Export', MaxLength = 100;
        JobSalesAdjmtRetailLbl: Label 'Job Sales Adjmt, Retail', MaxLength = 100;
        SalesofRetailTotalLbl: Label 'Sales of Retail, Total', MaxLength = 100;
        RevenueArea10to30TotalLbl: Label 'Revenue Area 10..30, Total', MaxLength = 100;
        RevenueArea40to85TotalLbl: Label 'Revenue Area 40..85, Total', MaxLength = 100;
        RevenueNoAreacodeTotalLbl: Label 'Revenue, no Area code, Total', MaxLength = 100;
        RevenueTotalLbl: Label 'Revenue, Total', MaxLength = 100;
}