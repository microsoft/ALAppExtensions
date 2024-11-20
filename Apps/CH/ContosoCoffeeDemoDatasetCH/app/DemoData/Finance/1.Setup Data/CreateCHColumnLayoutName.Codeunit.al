codeunit 11588 "Create CH Column Layout Name"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertColumnLayoutName(BeginningBalanceDebitsCreditsEndingBalance(), TBBeginningBalanceDebitsCreditsEndingBalanceLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(BalanceSheetTrend(), BS12MonthsBalanceTrendingCurrentFiscalYearLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthBalance(), BSCurrentMonthBalanceLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthBalancePriorMonthBalance(), BSCurrentMonthBalancevPriorMonthBalanceLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthBalancevSameMonthPriorYearBalance(), BSCurrentMonthBalancevSameMonthPriorYearBalanceLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthNetChange(), ISCurrentMonthNetChangeLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthsNetChangeBudget(), IS12MonthsNetChangeBudgetOnlyLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthNetChangePriorMonthNetChange(), ISCurrentMonthNetChangevPriorMonthNetChangeLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthNetChangeSameMonthPriorYearNetChange(), ISCurrentMonthNetChangevSameMonthPriorYearNetChangeLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthNetChangePriorMonthNetChangeForCYandCurrentMonthPriorMonthForPY(), ISCurrentMonthvPriorMonthforCYandCurrentMonthvPriorMonthforPYLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CurrentMonthBudgetYearToDateBudgetAndBudgetTotalAndBudgetRemaining(), ISCurrentMonthvBudgetYeartoDatevBudgetandBudTotalandBudRemainingLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(IncomeStatementTrend(), IS12MonthsNetChangeTrendingCurrentFiscalYearLbl);
    end;

    procedure BeginningBalanceDebitsCreditsEndingBalance(): Code[10]
    begin
        exit(BeginningBalanceDebitsCreditsEndingBalanceTok);
    end;

    procedure BalanceSheetTrend(): Code[10]
    begin
        exit(BalanceSheetTok);
    end;

    procedure CurrentMonthBalance(): Code[10]
    begin
        exit(CurrentMonthBalanceTok);
    end;

    procedure CurrentMonthBalancePriorMonthBalance(): Code[10]
    begin
        exit(CurrentMonthBalancePriorMonthBalanceTok);
    end;

    procedure CurrentMonthBalancevSameMonthPriorYearBalance(): Code[10]
    begin
        exit(CurrentMonthBalancevSameMonthPriorYearBalanceTok);
    end;

    procedure CurrentMonthNetChange(): Code[10]
    begin
        exit(CurrentMonthNetChangeTok);
    end;

    procedure CurrentMonthsNetChangeBudget(): Code[10]
    begin
        exit(CurrentMonthsNetChangeBudgetTok);
    end;

    procedure CurrentMonthNetChangePriorMonthNetChange(): Code[10]
    begin
        exit(CurrentMonthNetChangePriorMonthNetChangeTok);
    end;

    procedure CurrentMonthNetChangeSameMonthPriorYearNetChange(): Code[10]
    begin
        exit(CurrentMonthNetChangeSameMonthPriorYearNetChangeTok);
    end;

    procedure CurrentMonthNetChangePriorMonthNetChangeForCYandCurrentMonthPriorMonthForPY(): Code[10]
    begin
        exit(CurrentMonthNetChangePriorMonthNetChangeForCYandCurrentMonthPriorMonthForPYTok);
    end;

    procedure CurrentMonthBudgetYearToDateBudgetAndBudgetTotalAndBudgetRemaining(): Code[10]
    begin
        exit(CurrentMonthBudgetYearToDateBudgetAndBudgetTotalAndBudgetRemainingTok);
    end;

    procedure IncomeStatementTrend(): Code[10]
    begin
        exit(IncomeStatementTrendTok);
    end;

    var
        BeginningBalanceDebitsCreditsEndingBalanceTok: Label 'BBDRCREB', MaxLength = 10;
        BalanceSheetTok: Label 'BSTREND', MaxLength = 10;
        CurrentMonthBalanceTok: Label 'CB', MaxLength = 10;
        CurrentMonthBalancePriorMonthBalanceTok: Label 'CB V PB', MaxLength = 10;
        CurrentMonthBalancevSameMonthPriorYearBalanceTok: Label 'CB V SPYB', MaxLength = 10;
        CurrentMonthNetChangeTok: Label 'CNC', MaxLength = 10;
        CurrentMonthsNetChangeBudgetTok: Label 'CNC BUD', MaxLength = 10;
        CurrentMonthNetChangePriorMonthNetChangeTok: Label 'CNC V PNC', MaxLength = 10;
        CurrentMonthNetChangeSameMonthPriorYearNetChangeTok: Label 'CNC VSPYNC', MaxLength = 10;
        CurrentMonthNetChangePriorMonthNetChangeForCYandCurrentMonthPriorMonthForPYTok: Label 'CNCVPNCYOY', MaxLength = 10;
        CurrentMonthBudgetYearToDateBudgetAndBudgetTotalAndBudgetRemainingTok: Label 'CVC YTDBUD', MaxLength = 10;
        IncomeStatementTrendTok: Label 'ISTREND', MaxLength = 10;
        TBBeginningBalanceDebitsCreditsEndingBalanceLbl: Label 'TB Beginning Balance Debits Credits Ending Balance', MaxLength = 80;
        BS12MonthsBalanceTrendingCurrentFiscalYearLbl: Label 'BS 12 Months Balance Trending Current Fiscal Year', MaxLength = 80;
        BSCurrentMonthBalanceLbl: Label 'BS Current Month Balance', MaxLength = 80;
        BSCurrentMonthBalancevPriorMonthBalanceLbl: Label 'BS Current Month Balance v Prior Month Balance', MaxLength = 80;
        BSCurrentMonthBalancevSameMonthPriorYearBalanceLbl: Label 'BS Current Month Balance v Same Month Prior Year Balance', MaxLength = 80;
        ISCurrentMonthNetChangeLbl: Label 'IS Current Month Net Change', MaxLength = 80;
        IS12MonthsNetChangeBudgetOnlyLbl: Label 'IS 12 Months Net Change Budget Only', MaxLength = 80;
        ISCurrentMonthNetChangevPriorMonthNetChangeLbl: Label 'IS Current Month Net Change v Prior Month Net Change', MaxLength = 80;
        ISCurrentMonthNetChangevSameMonthPriorYearNetChangeLbl: Label 'IS Current Month Net Change v Same Month Prior Year Net Change', MaxLength = 80;
        ISCurrentMonthvPriorMonthforCYandCurrentMonthvPriorMonthforPYLbl: Label 'IS Current Month v Prior Month for CY and Current Month v Prior Month for PY', MaxLength = 80;
        ISCurrentMonthvBudgetYeartoDatevBudgetandBudTotalandBudRemainingLbl: Label 'IS Current Month v Budget Year to Date v Budget and Bud Total and Bud Remaining ', MaxLength = 80;
        IS12MonthsNetChangeTrendingCurrentFiscalYearLbl: Label 'IS 12 Months Net Change Trending Current Fiscal Year', MaxLength = 80;
}