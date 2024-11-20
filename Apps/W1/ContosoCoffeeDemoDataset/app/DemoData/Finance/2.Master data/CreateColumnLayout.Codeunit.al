codeunit 5395 "Create Column Layout"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateColumnLayoutName: Codeunit "Create Column Layout Name";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
        ColumnLayoutName: Code[10];
    begin
        ContosoAccountSchedule.InsertColumnLayout('', 10000, '', '', Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout('', 20000, '', '', Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout('', 30000, '', '', Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);

        ColumnLayoutName := CreateColumnLayoutName.ActualBudgetComparison();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, 'A', NetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, 'B', BudgetLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 30000, 'C', VarianceLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, 'A-B', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 40000, 'D', ABLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, 'A / B * 100', false, Enum::"Column Layout Show"::Always, '', true);

        ColumnLayoutName := CreateColumnLayoutName.BalanceOnly();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, '', BalanceLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);

        ColumnLayoutName := CreateColumnLayoutName.BudgetAnalysis();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, 'N', NetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, 'B', BudgetLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 30000, '', VariancePercentageLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, '100*(N/B-1)', false, Enum::"Column Layout Show"::Always, '', true);

        ColumnLayoutName := CreateColumnLayoutName.CashFlowComparison();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, 'S10', AmountLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, 'S20', AmountUntilDateLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 30000, 'S30', EntireFiscalYearLbl, Enum::"Column Layout Type"::"Entire Fiscal Year", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);

        ColumnLayoutName := CreateColumnLayoutName.DefaultLayout();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, '', NetChangeDebitLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::"When Positive", '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, '', NetChangeCreditLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', true, Enum::"Column Layout Show"::"When Negative", '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 30000, '', BalanceAtDateDebitLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::"When Positive", '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 40000, '', BalanceAtDateCreditLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', true, Enum::"Column Layout Show"::"When Negative", '', false);

        ColumnLayoutName := CreateColumnLayoutName.KeyCashFlowRatio();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, 'S10', KeyFigureLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);

        ColumnLayoutName := CreateColumnLayoutName.PeriodsDefinition();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, '10', CurrentPeriodLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, '10', CurrentPeriodMinus1Lbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '-1P', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 30000, '10', CurrentPeriodMinus2Lbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '-2P', false);

        ColumnLayoutName := CreateColumnLayoutName.BeginningBalanceDebitsCreditsEndingBalance();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, '1', BeginningBalanceLbl, Enum::"Column Layout Type"::"Beginning Balance", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, '2', DebitsLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Debit Amount", '', false, Enum::"Column Layout Show"::Always, 'P', false, 1033);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 30000, '3', CreditsLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, Enum::"Account Schedule Amount Type"::"Credit Amount", '', false, Enum::"Column Layout Show"::Always, 'P', false, 1033);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 40000, '4', EndingBalanceLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, '1+2-3', false, Enum::"Column Layout Show"::Always, '', false);

        ColumnLayoutName := CreateColumnLayoutName.BalanceSheetTrend();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, '1', JanuaryLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[1]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, '2', FebruaryLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[2]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 30000, '3', MarchLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[3]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 40000, '4', AprilLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[4]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 50000, '5', MayLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[5]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 60000, '6', JuneLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[6]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 70000, '7', JulyLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[7]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 80000, '8', AugustLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[8]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 90000, '9', SeptemberLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[9]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 100000, '10', OctoberLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[10]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 110000, '11', NovemberLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[11]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 120000, '12', DecemberLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[12]', false);

        ColumnLayoutName := CreateColumnLayoutName.CurrentMonthBalance();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, '1', CurrentMonthBalanceLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);

        ColumnLayoutName := CreateColumnLayoutName.CurrentMonthBalanceVPriorMonth();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, '1', CurrentMonthBalanceLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, '2', PriorMonthBalanceLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '-1P', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 30000, '3', DifferenceLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, '1-2', false, Enum::"Column Layout Show"::Always, '', false);

        ColumnLayoutName := CreateColumnLayoutName.CurrentMonthBalanceVSameMonthPriorYear();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, '1', CurrentMonthBalanceLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, '2', XSameMonthPriorYearBalanceTxt, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '-1FY', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 30000, '3', DifferenceLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, '1-2', false, Enum::"Column Layout Show"::Always, '', false);

        ColumnLayoutName := CreateColumnLayoutName.CurrentMonthNetChange();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, '1', CurrentMonthNetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);

        ColumnLayoutName := CreateColumnLayoutName.CurrentMonthNetChangeBudget();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, '1', JanuaryLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[1]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, '2', FebruaryLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[2]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 30000, '3', MarchLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[3]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 40000, '4', AprilLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[4]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 50000, '5', MayLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[5]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 60000, '6', JuneLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[6]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 70000, '7', JulyLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[7]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 80000, '8', AugustLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[8]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 90000, '9', SeptemberLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[9]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 100000, '10', OctoberLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[10]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 110000, '11', NovemberLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[11]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 120000, '12', DecemberLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[12]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 130000, '13', TotalLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::"Budget Entries", '1..12', false, Enum::"Column Layout Show"::Always, '', false);

        ColumnLayoutName := CreateColumnLayoutName.CurrentMonthNetChangeVPriorMonth();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, '1', CurrentMonthNetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, '2', PriorMonthNetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '-1P', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 30000, '3', DifferenceLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, '1-2', false, Enum::"Column Layout Show"::Always, '', false);

        ColumnLayoutName := CreateColumnLayoutName.CurrentMonthNetChangeVSameMonthPriorYear();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, '1', CurrentMonthNetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, '2', SameMonthPriorYearNetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '-1FY', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 30000, '3', DifferenceLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, '1-2', false, Enum::"Column Layout Show"::Always, '', false);

        ColumnLayoutName := CreateColumnLayoutName.CurrentMonthVPriorMonthCY();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, '1', CurrentMonthNetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, '2', PriorMonthNetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '-1P', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 30000, '3', DifferenceLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, '1-2', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 40000, '4', '', Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 50000, '5', CurrentMonthNetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 60000, '6', SameMonthPriorYearNetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '-1FY', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 70000, '7', DifferenceLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, '5-6', false, Enum::"Column Layout Show"::Always, '', false);

        ColumnLayoutName := CreateColumnLayoutName.CurrentMonthVBudgetYearToDate();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, '1', CurrentMonthActualLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, '2', CurrentMonthBudgetLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 30000, '3', DifferenceLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, '1-2', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 40000, '4', '', Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 50000, '5', YearToDateActualLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[1..CP]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 60000, '6', YearToDateBudgetLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[1..CP]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 70000, '7', DifferenceLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, '5-6', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 80000, '8', '', Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 90000, '9', TotalBudgetPlannedLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[1..12]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 100000, '10', TotalBudgetRemainingLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::"Budget Entries", '9-5', false, Enum::"Column Layout Show"::Always, '', false);

        ColumnLayoutName := CreateColumnLayoutName.IncomeStatementTrend();
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 10000, 'A', JanuaryLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[1]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 20000, 'A', FebruaryLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[2]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 30000, 'A', MarchLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[3]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 40000, 'A', AprilLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[4]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 50000, 'A', MayLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[5]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 60000, 'A', JuneLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[6]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 70000, 'A', JulyLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[7]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 80000, 'A', AugustLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[8]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 90000, 'A', SeptemberLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[9]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 100000, 'A', OctoberLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[10]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 110000, 'A', NovemberLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[11]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 120000, 'A', DecemberLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[12]', false);
        ContosoAccountSchedule.InsertColumnLayout(ColumnLayoutName, 130000, '', TotalLbl, Enum::"Column Layout Type"::Formula, Enum::"Column Layout Entry Type"::Entries, 'A', false, Enum::"Column Layout Show"::Always, '', false);
    end;

    var
        NetChangeLbl: Label 'Net Change', MaxLength = 30;
        BudgetLbl: Label 'Budget', MaxLength = 30;
        VarianceLbl: Label 'Variance', MaxLength = 30;
        VariancePercentageLbl: Label 'Variance%', MaxLength = 30;
        ABLbl: Label 'A-B', MaxLength = 30;
        NetChangeDebitLbl: Label 'Net Change Debit', MaxLength = 30;
        NetChangeCreditLbl: Label 'Net Change Credit', MaxLength = 30;
        BalanceAtDateDebitLbl: Label 'Balance at Date Debit', MaxLength = 30;
        BalanceAtDateCreditLbl: Label 'Balance at Date Credit', MaxLength = 30;
        KeyFigureLbl: Label 'Key Figure', MaxLength = 30;
        BalanceLbl: Label 'Balance', MaxLength = 30;
        CurrentPeriodLbl: Label 'CURRENT PERIOD', MaxLength = 30;
        CurrentPeriodMinus1Lbl: Label 'CURRENT PERIOD - 1', MaxLength = 30;
        CurrentPeriodMinus2Lbl: Label 'CURRENT PERIOD - 2', MaxLength = 30;
        AmountLbl: Label 'Amount', MaxLength = 30;
        AmountUntilDateLbl: Label 'Amount until date', MaxLength = 30;
        EntireFiscalYearLbl: Label 'Entire Fiscal Year', MaxLength = 30;
        BeginningBalanceLbl: Label 'Beginning Balance', MaxLength = 30;
        DebitsLbl: Label 'Debits', MaxLength = 30;
        CreditsLbl: Label 'Credits', MaxLength = 30;
        EndingBalanceLbl: Label 'Ending Balance', MaxLength = 30;
        JanuaryLbl: Label 'January', MaxLength = 30;
        FebruaryLbl: Label 'February', MaxLength = 30;
        MarchLbl: Label 'March', MaxLength = 30;
        AprilLbl: Label 'April', MaxLength = 30;
        MayLbl: Label 'May', MaxLength = 30;
        JuneLbl: Label 'June', MaxLength = 30;
        JulyLbl: Label 'July', MaxLength = 30;
        AugustLbl: Label 'August', MaxLength = 30;
        SeptemberLbl: Label 'September', MaxLength = 30;
        OctoberLbl: Label 'October', MaxLength = 30;
        NovemberLbl: Label 'November', MaxLength = 30;
        DecemberLbl: Label 'December', MaxLength = 30;
        CurrentMonthBalanceLbl: Label 'Current Month Balance', MaxLength = 30;
        PriorMonthBalanceLbl: Label 'Prior Month Balance', MaxLength = 30;
        DifferenceLbl: Label 'Difference', MaxLength = 30;
        XSameMonthPriorYearBalanceTxt: Label 'Same Month Prior Year Balance', MaxLength = 30;
        CurrentMonthNetChangeLbl: Label 'Current Month Net Change', MaxLength = 30;
        PriorMonthNetChangeLbl: Label 'Prior Month Net Change', MaxLength = 30;
        TotalLbl: Label 'Total', MaxLength = 30;
        SameMonthPriorYearNetChangeLbl: Label 'Same Month Prior Year Net Chan', MaxLength = 30;
        CurrentMonthActualLbl: Label 'Current Month Actual', MaxLength = 30;
        CurrentMonthBudgetLbl: Label 'Current Month Budget', MaxLength = 30;
        YearToDateActualLbl: Label 'Year to Date Actual', MaxLength = 30;
        YearToDateBudgetLbl: Label 'Year to Date Budget', MaxLength = 30;
        TotalBudgetPlannedLbl: Label 'Total Budget Planned', MaxLength = 30;
        TotalBudgetRemainingLbl: Label 'Total Budget Remaining', MaxLength = 30;
}
