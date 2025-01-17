codeunit 5297 "Create Acc. Schedule Chart"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateAccScheduleName: Codeunit "Create Acc. Schedule Name";
        CreateColumnLayoutName: Codeunit "Create Column Layout Name";
        ContosoUtilities: Codeunit "Contoso Utilities";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
        DummyUserID: Text[132];
        date: Date;
    begin
        DummyUserID := '';
        date := ContosoUtilities.AdjustDate(19030401D);

        ContosoAccountSchedule.InsertAccountSchedulesChartSetup(DummyUserID, CashCycle(), CashCycleLbl, CreateAccScheduleName.CashCycle(), CreateColumnLayoutName.PeriodsDefinition(), date, 2, 12, false);
        ContosoAccountSchedule.InsertAccountSchedulesChartSetup(DummyUserID, CashFlow(), CashFlowLbl, CreateAccScheduleName.CashFlow(), CreateColumnLayoutName.PeriodsDefinition(), date, 2, 3, true);
        ContosoAccountSchedule.InsertAccountSchedulesChartSetup(DummyUserID, IncomeAndExpense(), IncomeAndExpenseLbl, CreateAccScheduleName.IncomeExpense(), CreateColumnLayoutName.PeriodsDefinition(), date, 2, 3, false);
    end;

    procedure CashCycle(): Text[30]
    begin
        exit(CashCycleTok)
    end;

    procedure CashFlow(): Text[30]
    begin
        exit(CashFlowTok)
    end;

    procedure IncomeAndExpense(): Text[30]
    begin
        exit(IncomeAndExpenseTok)
    end;

    var
        CashCycleTok: Label 'Cash Cycle', MaxLength = 30;
        CashFlowTok: Label 'Cash Flow', MaxLength = 30;
        IncomeAndExpenseTok: Label 'Income & Expense', MaxLength = 30;
        CashCycleLbl: Label 'Shows how many days money is tied up from the day you purchase inventory to the day you receive payment from customers.\\A cash cycle is calculated as: Days Sales in Inventory (DSI) + Days Sales Outstanding (DSO) - Days Payable Outstanding (DPO).', MaxLength = 250;
        CashFlowLbl: Label 'Shows the movement of money into or out of your company. You can select to view both future revenue and expenses not yet registered.\\Cash flow is calculated as follows: Receivables + Liquid Funds - Payables.', MaxLength = 250;
        IncomeAndExpenseLbl: Label 'Shows the company''s trends in income over expenses. By comparing figures for different periods, you can detect periods that need further investigation.', MaxLength = 250;
}