codeunit 5298 "Create Acc. Sched. Chart Line"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateAccScheduleChart: Codeunit "Create Acc. Schedule Chart";
        CreateAccScheduleName: Codeunit "Create Acc. Schedule Name";
        CreateColumnLayoutName: Codeunit "Create Column Layout Name";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
        DummyUserID: Text[132];
    begin
        DummyUserID := '';

        ContosoAccountSchedule.InsertAccSchedChartSetupLine(DummyUserID, CreateAccScheduleChart.CashCycle(), 50000, 10000, CreateAccScheduleName.CashCycle(), CreateColumnLayoutName.PeriodsDefinition(), DaysOfSalesOutstandingLbl, Enum::"Account Schedule Chart Type"::Line);
        ContosoAccountSchedule.InsertAccSchedChartSetupLine(DummyUserID, CreateAccScheduleChart.CashCycle(), 60000, 10000, CreateAccScheduleName.CashCycle(), CreateColumnLayoutName.PeriodsDefinition(), DaysOfPaymentOutstandingLbl, Enum::"Account Schedule Chart Type"::Line);
        ContosoAccountSchedule.InsertAccSchedChartSetupLine(DummyUserID, CreateAccScheduleChart.CashCycle(), 70000, 10000, CreateAccScheduleName.CashCycle(), CreateColumnLayoutName.PeriodsDefinition(), DaysSalesOfInventoryLbl, Enum::"Account Schedule Chart Type"::Line);
        ContosoAccountSchedule.InsertAccSchedChartSetupLine(DummyUserID, CreateAccScheduleChart.CashCycle(), 80000, 10000, CreateAccScheduleName.CashCycle(), CreateColumnLayoutName.PeriodsDefinition(), CashCycleDaysLbl, Enum::"Account Schedule Chart Type"::Line);

        ContosoAccountSchedule.InsertAccSchedChartSetupLine(DummyUserID, CreateAccScheduleChart.CashFlow(), 10000, 10000, CreateAccScheduleName.CashFlow(), CreateColumnLayoutName.PeriodsDefinition(), TotalReceivablesLbl, Enum::"Account Schedule Chart Type"::Column);
        ContosoAccountSchedule.InsertAccSchedChartSetupLine(DummyUserID, CreateAccScheduleChart.CashFlow(), 20000, 10000, CreateAccScheduleName.CashFlow(), CreateColumnLayoutName.PeriodsDefinition(), TotalPayablesLbl, Enum::"Account Schedule Chart Type"::Column);
        ContosoAccountSchedule.InsertAccSchedChartSetupLine(DummyUserID, CreateAccScheduleChart.CashFlow(), 30000, 10000, CreateAccScheduleName.CashFlow(), CreateColumnLayoutName.PeriodsDefinition(), TotalLiquidFundsLbl, Enum::"Account Schedule Chart Type"::Column);
        ContosoAccountSchedule.InsertAccSchedChartSetupLine(DummyUserID, CreateAccScheduleChart.CashFlow(), 40000, 10000, CreateAccScheduleName.CashFlow(), CreateColumnLayoutName.PeriodsDefinition(), TotalCashFlowLbl, Enum::"Account Schedule Chart Type"::StepLine);

        ContosoAccountSchedule.InsertAccSchedChartSetupLine(DummyUserID, CreateAccScheduleChart.IncomeAndExpense(), 20000, 10000, CreateAccScheduleName.IncomeExpense(), CreateColumnLayoutName.PeriodsDefinition(), TotalRevenueLbl, Enum::"Account Schedule Chart Type"::Column);
        ContosoAccountSchedule.InsertAccSchedChartSetupLine(DummyUserID, CreateAccScheduleChart.IncomeAndExpense(), 80000, 10000, CreateAccScheduleName.IncomeExpense(), CreateColumnLayoutName.PeriodsDefinition(), TotalExpenditureLbl, Enum::"Account Schedule Chart Type"::Column);
        ContosoAccountSchedule.InsertAccSchedChartSetupLine(DummyUserID, CreateAccScheduleChart.IncomeAndExpense(), 90000, 10000, CreateAccScheduleName.IncomeExpense(), CreateColumnLayoutName.PeriodsDefinition(), EarningsBeforeInterestLbl, Enum::"Account Schedule Chart Type"::Column);
    end;



    var
        DaysOfSalesOutstandingLbl: Label 'Days of Sales Outstanding', MaxLength = 111;
        DaysOfPaymentOutstandingLbl: Label 'Days of Payment Outstanding', MaxLength = 111;
        DaysSalesOfInventoryLbl: Label 'Days Sales of Inventory', MaxLength = 111;
        CashCycleDaysLbl: Label 'Cash Cycle (Days)', MaxLength = 111;
        TotalReceivablesLbl: Label 'Total Receivables', MaxLength = 111;
        TotalPayablesLbl: Label 'Total Payables', MaxLength = 111;
        TotalLiquidFundsLbl: Label 'Total Liquid Funds', MaxLength = 111;
        TotalCashFlowLbl: Label 'Total Cash Flow', MaxLength = 111;
        TotalRevenueLbl: Label 'Total Revenue', MaxLength = 111;
        TotalExpenditureLbl: Label 'Total Expenditure', MaxLength = 111;
        EarningsBeforeInterestLbl: Label 'Earnings Before Interest', MaxLength = 111;
}