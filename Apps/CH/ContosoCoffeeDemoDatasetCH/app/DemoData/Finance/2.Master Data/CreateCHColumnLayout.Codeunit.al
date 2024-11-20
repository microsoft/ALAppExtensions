codeunit 11589 "Create CH Column Layout"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateCHColumnLayoutName: Codeunit "Create CH Column Layout Name";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.BeginningBalanceDebitsCreditsEndingBalance(), 10000, '1', BeginningBalanceLbl, Enum::"Column Layout Type"::"Beginning Balance", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.BeginningBalanceDebitsCreditsEndingBalance(), 20000, '2', DebitsLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.BeginningBalanceDebitsCreditsEndingBalance(), 30000, '3', CreditsLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.BeginningBalanceDebitsCreditsEndingBalance(), 40000, '4', EndingBalanceLbl, Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, '1+2-3', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.BalanceSheetTrend(), 10000, '1', JanuaryLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[1]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.BalanceSheetTrend(), 20000, '2', FebruaryLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[2]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.BalanceSheetTrend(), 30000, '3', MarchLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[3]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.BalanceSheetTrend(), 40000, '4', AprilLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[4]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.BalanceSheetTrend(), 50000, '5', MayLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[5]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.BalanceSheetTrend(), 60000, '6', JuneLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[6]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.BalanceSheetTrend(), 70000, '7', JulyLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[7]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.BalanceSheetTrend(), 80000, '8', AugustLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[8]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.BalanceSheetTrend(), 90000, '9', SeptemberLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[9]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.BalanceSheetTrend(), 100000, '10', OctoberLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[10]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.BalanceSheetTrend(), 110000, '11', NovemberLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[11]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.BalanceSheetTrend(), 120000, '12', DecemberLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[12]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthBalance(), 10000, '1', CurrentMonthBalanceLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthBalancePriorMonthBalance(), 10000, '1', CurrentMonthBalanceLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthBalancePriorMonthBalance(), 20000, '2', PriorMonthBalanceLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '-1P', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthBalancePriorMonthBalance(), 30000, '3', DifferenceLbl, Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, '1-2', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthBalancevSameMonthPriorYearBalance(), 10000, '1', CurrentMonthBalanceLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthBalancevSameMonthPriorYearBalance(), 20000, '2', SameMonthPriorYearBalanceLbl, Enum::"Column Layout Type"::"Balance at Date", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '-1FY', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthBalancevSameMonthPriorYearBalance(), 30000, '3', DifferenceLbl, Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, '1-2', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthNetChange(), 10000, '1', CurrentMonthNetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthsNetChangeBudget(), 10000, '1', JanuaryLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[1]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthsNetChangeBudget(), 20000, '2', FebruaryLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[2]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthsNetChangeBudget(), 30000, '3', MarchLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[3]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthsNetChangeBudget(), 40000, '4', AprilLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[4]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthsNetChangeBudget(), 50000, '5', MayLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[5]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthsNetChangeBudget(), 60000, '6', JuneLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[6]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthsNetChangeBudget(), 70000, '7', JulyLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[7]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthsNetChangeBudget(), 80000, '8', AugustLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[8]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthsNetChangeBudget(), 90000, '9', SeptemberLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[9]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthsNetChangeBudget(), 100000, '10', OctoberLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[10]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthsNetChangeBudget(), 110000, '11', NovemberLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[11]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthsNetChangeBudget(), 120000, '12', DecemberLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[12]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthsNetChangeBudget(), 130000, '13', TotalLbl, Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::"Budget Entries", '1..12', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthNetChangePriorMonthNetChange(), 10000, '1', CurrentMonthNetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthNetChangePriorMonthNetChange(), 20000, '2', PriorMonthNetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '-1P', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthNetChangePriorMonthNetChange(), 30000, '3', DifferenceLbl, Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, '1-2', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthNetChangeSameMonthPriorYearNetChange(), 10000, '1', CurrentMonthNetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthNetChangeSameMonthPriorYearNetChange(), 20000, '2', SameMonthPriorYearNetChanLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '-1FY', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthNetChangeSameMonthPriorYearNetChange(), 30000, '3', DifferenceLbl, Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, '1-2', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthNetChangePriorMonthNetChangeForCYandCurrentMonthPriorMonthForPY(), 10000, '1', CurrentMonthNetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthNetChangePriorMonthNetChangeForCYandCurrentMonthPriorMonthForPY(), 20000, '2', PriorMonthNetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '-1P', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthNetChangePriorMonthNetChangeForCYandCurrentMonthPriorMonthForPY(), 30000, '3', DifferenceLbl, Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, '1-2', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthNetChangePriorMonthNetChangeForCYandCurrentMonthPriorMonthForPY(), 40000, '4', '', Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthNetChangePriorMonthNetChangeForCYandCurrentMonthPriorMonthForPY(), 50000, '5', CurrentMonthNetChangeLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthNetChangePriorMonthNetChangeForCYandCurrentMonthPriorMonthForPY(), 60000, '6', SameMonthPriorYearNetChanLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '-1FY', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthNetChangePriorMonthNetChangeForCYandCurrentMonthPriorMonthForPY(), 70000, '7', DifferenceLbl, Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, '5-6', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthBudgetYearToDateBudgetAndBudgetTotalAndBudgetRemaining(), 10000, '1', CurrentMonthActualLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthBudgetYearToDateBudgetAndBudgetTotalAndBudgetRemaining(), 20000, '2', CurrentMonthBudgetLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'P', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthBudgetYearToDateBudgetAndBudgetTotalAndBudgetRemaining(), 30000, '3', DifferenceLbl, Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, '1-2', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthBudgetYearToDateBudgetAndBudgetTotalAndBudgetRemaining(), 40000, '4', '', Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthBudgetYearToDateBudgetAndBudgetTotalAndBudgetRemaining(), 50000, '5', YeartoDateActualLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[1..CP]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthBudgetYearToDateBudgetAndBudgetTotalAndBudgetRemaining(), 60000, '6', YeartoDateBudgetLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[1..CP]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthBudgetYearToDateBudgetAndBudgetTotalAndBudgetRemaining(), 70000, '7', DifferenceLbl, Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, '5-6', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthBudgetYearToDateBudgetAndBudgetTotalAndBudgetRemaining(), 80000, '8', '', Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthBudgetYearToDateBudgetAndBudgetTotalAndBudgetRemaining(), 90000, '9', TotalBudgetPlannedLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::"Budget Entries", '', false, Enum::"Column Layout Show"::Always, 'FY[1..12]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.CurrentMonthBudgetYearToDateBudgetAndBudgetTotalAndBudgetRemaining(), 100000, '10', TotalBudgetRemainingLbl, Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::"Budget Entries", '9-5', false, Enum::"Column Layout Show"::Always, '', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.IncomeStatementTrend(), 10000, 'A', JanuaryLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[1]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.IncomeStatementTrend(), 20000, 'A', FebruaryLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[2]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.IncomeStatementTrend(), 30000, 'A', MarchLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[3]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.IncomeStatementTrend(), 40000, 'A', AprilLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[4]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.IncomeStatementTrend(), 50000, 'A', MayLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[5]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.IncomeStatementTrend(), 60000, 'A', JuneLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[6]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.IncomeStatementTrend(), 70000, 'A', JulyLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[7]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.IncomeStatementTrend(), 80000, 'A', AugustLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[8]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.IncomeStatementTrend(), 90000, 'A', SeptemberLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[9]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.IncomeStatementTrend(), 100000, 'A', OctoberLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[10]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.IncomeStatementTrend(), 110000, 'A', NovemberLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[11]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.IncomeStatementTrend(), 120000, 'A', DecemberLbl, Enum::"Column Layout Type"::"Net Change", Enum::"Column Layout Entry Type"::Entries, '', false, Enum::"Column Layout Show"::Always, 'FY[12]', false);
        ContosoAccountSchedule.InsertColumnLayout(CreateCHColumnLayoutName.IncomeStatementTrend(), 130000, '', TotalLbl, Enum::"Column Layout Type"::"Formula", Enum::"Column Layout Entry Type"::Entries, 'A', false, Enum::"Column Layout Show"::Always, '', false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Column Layout", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Column Layout")
    var
        CreateCHColumnLayoutName: Codeunit "Create CH Column Layout Name";
    begin
        if Rec."Column Layout Name" = CreateCHColumnLayoutName.BeginningBalanceDebitsCreditsEndingBalance() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, BeginningBalanceLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                20000:
                    ValidateRecordFields(Rec, DebitsLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Debit Amount");
                30000:
                    ValidateRecordFields(Rec, CreditsLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Credit Amount");
            end;

        if Rec."Column Layout Name" = CreateCHColumnLayoutName.BalanceSheetTrend() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, JanuaryLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                20000:
                    ValidateRecordFields(Rec, FebruaryLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                30000:
                    ValidateRecordFields(Rec, MarchLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                40000:
                    ValidateRecordFields(Rec, AprilLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                50000:
                    ValidateRecordFields(Rec, MayLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                60000:
                    ValidateRecordFields(Rec, JuneLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                70000:
                    ValidateRecordFields(Rec, JulyLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                80000:
                    ValidateRecordFields(Rec, AugustLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                90000:
                    ValidateRecordFields(Rec, SeptemberLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                100000:
                    ValidateRecordFields(Rec, OctoberLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                110000:
                    ValidateRecordFields(Rec, NovemberLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                120000:
                    ValidateRecordFields(Rec, DecemberLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
            end;

        if (Rec."Column Layout Name" = CreateCHColumnLayoutName.CurrentMonthBalance()) and (Rec."Line No." = 10000) then
            ValidateRecordFields(Rec, CurrentMonthBalanceLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");

        if Rec."Column Layout Name" = CreateCHColumnLayoutName.CurrentMonthBalancePriorMonthBalance() then
            case
                Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CurrentMonthBalanceLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                20000:
                    ValidateRecordFields(Rec, PriorMonthBalanceLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
            end;

        if Rec."Column Layout Name" = CreateCHColumnLayoutName.CurrentMonthBalancevSameMonthPriorYearBalance() then
            case
                Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CurrentMonthBalanceLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                20000:
                    ValidateRecordFields(Rec, SameMonthPriorYearBalanceLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
            end;

        if (Rec."Column Layout Name" = CreateCHColumnLayoutName.CurrentMonthNetChange()) and (Rec."Line No." = 10000) then
            ValidateRecordFields(Rec, CurrentMonthNetChangeLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");

        if (Rec."Column Layout Name" = CreateCHColumnLayoutName.CurrentMonthsNetChangeBudget()) then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, JanuaryLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                20000:
                    ValidateRecordFields(Rec, FebruaryLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                30000:
                    ValidateRecordFields(Rec, MarchLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                40000:
                    ValidateRecordFields(Rec, AprilLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                50000:
                    ValidateRecordFields(Rec, MayLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                60000:
                    ValidateRecordFields(Rec, JuneLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                70000:
                    ValidateRecordFields(Rec, JulyLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                80000:
                    ValidateRecordFields(Rec, AugustLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                90000:
                    ValidateRecordFields(Rec, SeptemberLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                100000:
                    ValidateRecordFields(Rec, OctoberLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                110000:
                    ValidateRecordFields(Rec, NovemberLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                120000:
                    ValidateRecordFields(Rec, DecemberLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
            end;

        if Rec."Column Layout Name" = CreateCHColumnLayoutName.CurrentMonthNetChangePriorMonthNetChange() then
            case
                Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CurrentMonthNetChangeLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                20000:
                    ValidateRecordFields(Rec, PriorMonthNetChangeLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
            end;

        if Rec."Column Layout Name" = CreateCHColumnLayoutName.CurrentMonthNetChangeSameMonthPriorYearNetChange() then
            case
                Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CurrentMonthNetChangeLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                20000:
                    ValidateRecordFields(Rec, SameMonthPriorYearNetChanLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
            end;

        if Rec."Column Layout Name" = CreateCHColumnLayoutName.CurrentMonthNetChangePriorMonthNetChangeForCYandCurrentMonthPriorMonthForPY() then
            case
                Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CurrentMonthNetChangeLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                20000:
                    ValidateRecordFields(Rec, PriorMonthNetChangeLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                50000:
                    ValidateRecordFields(Rec, CurrentMonthNetChangeLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                60000:
                    ValidateRecordFields(Rec, SameMonthPriorYearNetChanLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
            end;

        if Rec."Column Layout Name" = CreateCHColumnLayoutName.CurrentMonthBudgetYearToDateBudgetAndBudgetTotalAndBudgetRemaining() then
            case
                Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CurrentMonthActualLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                20000:
                    ValidateRecordFields(Rec, CurrentMonthBudgetLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                50000:
                    ValidateRecordFields(Rec, YeartoDateActualLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                60000:
                    ValidateRecordFields(Rec, YeartoDateBudgetLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                90000:
                    ValidateRecordFields(Rec, TotalBudgetPlannedLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
            end;

        if Rec."Column Layout Name" = CreateCHColumnLayoutName.IncomeStatementTrend() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, JanuaryLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                20000:
                    ValidateRecordFields(Rec, FebruaryLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                30000:
                    ValidateRecordFields(Rec, MarchLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                40000:
                    ValidateRecordFields(Rec, AprilLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                50000:
                    ValidateRecordFields(Rec, MayLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                60000:
                    ValidateRecordFields(Rec, JuneLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                70000:
                    ValidateRecordFields(Rec, JulyLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                80000:
                    ValidateRecordFields(Rec, AugustLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                90000:
                    ValidateRecordFields(Rec, SeptemberLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                100000:
                    ValidateRecordFields(Rec, OctoberLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                110000:
                    ValidateRecordFields(Rec, NovemberLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
                120000:
                    ValidateRecordFields(Rec, DecemberLbl, '', Enum::"Analysis Rounding Factor"::None, 1033, Enum::"Account Schedule Amount Type"::"Net Amount");
            end;
    end;

    local procedure ValidateRecordFields(var ColumnLayout: Record "Column Layout"; ColumnHeader: Text[30]; ComparisonDateFormula: Text[10]; RoundingFactor: Enum "Analysis Rounding Factor"; ComparisonPeriodFormulaLCID: Integer; AmountType: Enum "Account Schedule Amount Type")
    begin
        ColumnLayout.Validate("Column Header", ColumnHeader);
        Evaluate(ColumnLayout."Comparison Date Formula", ComparisonDateFormula);
        ColumnLayout.Validate("Comparison Date Formula");
        ColumnLayout.Validate("Amount Type", AmountType);
        ColumnLayout.Validate("Rounding Factor", RoundingFactor);
        ColumnLayout.Validate("Comparison Period Formula LCID", ComparisonPeriodFormulaLCID);
    end;

    var
        BeginningBalanceLbl: Label 'Beginning Balance', MaxLength = 30;
        DebitsLbl: Label 'Debits', MaxLength = 30;
        CreditsLbl: Label 'Credits', MaxLength = 30;
        EndingBalanceLbl: Label 'Ending Balance', MaxLength = 30;
        CurrentMonthBalanceLbl: Label 'Current Month Balance', MaxLength = 30;
        PriorMonthBalanceLbl: Label 'Prior Month Balance', MaxLength = 30;
        SameMonthPriorYearBalanceLbl: Label 'Same Month Prior Year Balance', MaxLength = 30;
        CurrentMonthNetChangeLbl: Label 'Current Month Net Change', MaxLength = 30;
        SameMonthPriorYearNetChanLbl: Label 'Same Month Prior Year Net Chan', MaxLength = 30;
        PriorMonthNetChangeLbl: Label 'Prior Month Net Change', MaxLength = 30;
        DifferenceLbl: Label 'Difference', MaxLength = 30;
        CurrentMonthActualLbl: Label 'Current Month Actual', MaxLength = 30;
        CurrentMonthBudgetLbl: Label 'Current Month Budget', MaxLength = 30;
        YeartoDateActualLbl: Label 'Year to Date Actual', MaxLength = 30;
        YeartoDateBudgetLbl: Label 'Year to Date Budget', MaxLength = 30;
        TotalBudgetPlannedLbl: Label 'Total Budget Planned', MaxLength = 30;
        TotalBudgetRemainingLbl: Label 'Total Budget Remaining', MaxLength = 30;
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
        TotalLbl: Label 'Total', MaxLength = 30;
}