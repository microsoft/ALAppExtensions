codeunit 11385 "Create DE Acc. Schedule Line"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertAccScheduleLine(var Rec: Record "Acc. Schedule Line")
    var
        CreateAccountScheduleName: Codeunit "Create Acc. Schedule Name";
        CreateDEGLAcc: Codeunit "Create DE GL Acc.";
    begin
        if Rec."Schedule Name" = CreateAccountScheduleName.AccountCategoriesOverview() then
            case Rec."Line No." of
                60000:
                    ValidateAccScheduleLine(Rec, '5000', LiabilitiesLbl, '3000..4000', Enum::"Acc. Schedule Line Totaling Type"::Formula, true, false);
                70000:
                    ValidateAccScheduleLine(Rec, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false, false);
                80000:
                    ValidateAccScheduleLine(Rec, '6000', IncomeStatementLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", true, false);
                90000:
                    ValidateAccScheduleLine(Rec, '7000', IncomeLbl, '18', Enum::"Acc. Schedule Line Totaling Type"::"Account Category", false, false);
                100000:
                    ValidateAccScheduleLine(Rec, '8000', CostofGoodsSoldLbl, '26', Enum::"Acc. Schedule Line Totaling Type"::"Account Category", false, false);
                110000:
                    ValidateAccScheduleLine(Rec, '9000', ExpenseLbl, '31', Enum::"Acc. Schedule Line Totaling Type"::"Account Category", false, false);
                120000:
                    ValidateAccScheduleLine(Rec, '9900', NetIncomelbl, '7000..9000', Enum::"Acc. Schedule Line Totaling Type"::Formula, true, false);
                130000:
                    ValidateAccScheduleLine(Rec, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false, false);
            end;
        if Rec."Schedule Name" = CreateAccountScheduleName.CapitalStructure() then
            case Rec."Line No." of
                40000:
                    Rec.Validate(Totaling, '3987');
                50000:
                    Rec.Validate(Totaling, '1499');
                60000:
                    Rec.Validate(Totaling, '1509');
                70000:
                    Rec.Validate(Totaling, '2990');
                110000:
                    Rec.Validate(Totaling, '1290');
                120000:
                    Rec.Validate(Totaling, '1659');
                130000:
                    Rec.Validate(Totaling, '1798');
                140000:
                    Rec.Validate(Totaling, '4198');
                150000:
                    Rec.Validate(Totaling, '5990');
            end;
        if Rec."Schedule Name" = CreateAccountScheduleName.CashCycle() then
            case Rec."Line No." of
                10000:
                    ValidateAccScheduleLine(Rec, '10', TotalRevenueLbl, '8550', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, false);
                20000:
                    ValidateAccScheduleLine(Rec, '20', TotalReceivableslbl, '1499', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, false);
                30000:
                    ValidateAccScheduleLine(Rec, '30', TotalPayablesLbl, '1659', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, false);
                40000:
                    ValidateAccScheduleLine(Rec, '40', TotalInventoryLbl, '3987', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, false);
                50000:
                    ValidateAccScheduleLine(Rec, '100', DaysofSalesOutstandingLbl, '-360*''20''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, false, true);
                60000:
                    ValidateAccScheduleLine(Rec, '110', DaysofPaymentOutstandingLbl, '360*''30''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, false, true);
                70000:
                    ValidateAccScheduleLine(Rec, '120', DaysSalesofInventoryLbl, '-360*''40''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, false, true);
                80000:
                    ValidateAccScheduleLine(Rec, '200', CashCycleDaysLbl, '100+110-120', Enum::"Acc. Schedule Line Totaling Type"::Formula, false, true);
            end;
        if Rec."Schedule Name" = CreateAccountScheduleName.CashFlow() then
            case Rec."Line No." of
                10000:
                    ValidateAccScheduleLine(Rec, '10', TotalReceivablesLbl, '1499', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, false);
                20000:
                    ValidateAccScheduleLine(Rec, '20', TotalPayablesLbl, '1659', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, false);
                30000:
                    ValidateAccScheduleLine(Rec, '30', TotalLiquidFundsLbl, '2990|1290', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, false);
                40000:
                    ValidateAccScheduleLine(Rec, '40', TotalCashFlowLbl, '10..30', Enum::"Acc. Schedule Line Totaling Type"::Formula, false, false);
            end;
        if Rec."Schedule Name" = CreateAccountScheduleName.IncomeExpense() then
            case Rec."Line No." of
                10000:
                    ValidateAccScheduleLine(Rec, '10', TotalRevenueCreditLbl, '8550', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, false);
                30000:
                    ValidateAccScheduleLine(Rec, '20', TotalGoodsSoldLbl, CreateDEGLAcc.TOTALCOSTOFGOODSSOLD(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, false);
                40000:
                    ValidateAccScheduleLine(Rec, '30', TotalExternalCostsLbl, '8695', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, false);
                50000:
                    ValidateAccScheduleLine(Rec, '40', TotalPersonnelCostsLbl, '8790', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, false);
                60000:
                    ValidateAccScheduleLine(Rec, '50', TotalDeprOnFALbl, '8890', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, false);
                70000:
                    ValidateAccScheduleLine(Rec, '60', OtherExpensesLbl, CreateDEGLAcc.MiscVATPayables(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false, false);
            end;
        if Rec."Schedule Name" = CreateAccountScheduleName.ReducedTrialBalance() then
            case Rec."Line No." of
                10000:
                    ValidateAccScheduleLine(Rec, '10', TotalRevenueLbl, '8550', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, false);
                20000:
                    ValidateAccScheduleLine(Rec, '20', TotalCostLbl, '5999', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, false);
                40000:
                    ValidateAccScheduleLine(Rec, '40', GrossMarginPerLbl, '-''30''/''10''*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, false, true);
                50000:
                    ValidateAccScheduleLine(Rec, '50', OperatingExpensesLbl, '8695|8790|8890', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, false);
                70000:
                    ValidateAccScheduleLine(Rec, '70', OperatingMarginPerLbl, '-''60''/''10''*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, false, true);
                80000:
                    ValidateAccScheduleLine(Rec, '80', OtherExpensesLbl, CreateDEGLAcc.MiscVATPayables(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false, false);
                90000:
                    ValidateAccScheduleLine(Rec, '90', IncomeBeforeInterestAndTaxLbl, '8995', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, false);
            end;
        // if Rec."Schedule Name" = CreateAccountScheduleName.BalanceSheet() then
        //     case Rec."Line No." of
        //         10000:
        //             ValidateAccScheduleLine(Rec, '00..0400|0510..0940|1101..1180|1999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         30000:
        //             ValidateAccScheduleLine(Rec, '1600..1990', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         40000:
        //             ValidateAccScheduleLine(Rec, '1200..1499', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         50000:
        //             ValidateAccScheduleLine(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         60000:
        //             ValidateAccScheduleLine(Rec, '1000..1099', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         90000:
        //             ValidateAccScheduleLine(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         100000:
        //             ValidateAccScheduleLine(Rec, '0490', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         140000:
        //             ValidateAccScheduleLine(Rec, '3..3999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         150000:
        //             ValidateAccScheduleLine(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         160000:
        //             ValidateAccScheduleLine(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         170000:
        //             ValidateAccScheduleLine(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         200000:
        //             ValidateAccScheduleLine(Rec, '2..2010|2970..2999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         210000:
        //             ValidateAccScheduleLine(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         220000:
        //             ValidateAccScheduleLine(Rec, '4..8999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         230000:
        //             ValidateAccScheduleLine(Rec, CreateDEGLAcc.DistributionstoShareholders(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //     end;
        // if Rec."Schedule Name" = CreateAccountScheduleName.CashFlowStatement() then
        //     case Rec."Line No." of
        //         20000:
        //             ValidateAccScheduleLine(Rec, '4..8999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         40000:
        //             ValidateAccScheduleLine(Rec, '1200..1499', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         50000:
        //             ValidateAccScheduleLine(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         60000:
        //             ValidateAccScheduleLine(Rec, '1000..1099', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         70000:
        //             ValidateAccScheduleLine(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         80000:
        //             ValidateAccScheduleLine(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         120000:
        //             ValidateAccScheduleLine(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         130000:
        //             ValidateAccScheduleLine(Rec, CreateDEGLAcc.AccumulatedDepreciation(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         170000:
        //             ValidateAccScheduleLine(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         180000:
        //             ValidateAccScheduleLine(Rec, CreateDEGLAcc.DistributionstoShareholders(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         220000:
        //             ValidateAccScheduleLine(Rec, '1600..1990', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //     end;
        // if Rec."Schedule Name" = CreateAccountScheduleName.IncomeStatement() then
        //     case Rec."Line No." of
        //         10000:
        //             ValidateAccScheduleLine(Rec, '4000..4202|4414..4999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         20000:
        //             ValidateAccScheduleLine(Rec, '4410..4413', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         30000:
        //             ValidateAccScheduleLine(Rec, '4400..4409', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         50000:
        //             ValidateAccScheduleLine(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         110000:
        //             ValidateAccScheduleLine(Rec, '5|5030..5043|5999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         120000:
        //             ValidateAccScheduleLine(Rec, '5900..5905', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         130000:
        //             ValidateAccScheduleLine(Rec, '5020..5023', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         200000:
        //             ValidateAccScheduleLine(Rec, '6..6309|6320|6340..6880|7130..7999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         210000:
        //             ValidateAccScheduleLine(Rec, CreateDEGLAcc.RentLeases(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         220000:
        //             ValidateAccScheduleLine(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         230000:
        //             ValidateAccScheduleLine(Rec, CreateGLAcc.InterestIncome(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         260000:
        //             ValidateAccScheduleLine(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         290000:
        //             ValidateAccScheduleLine(Rec, CreateDEGLAcc.RepairsandMaintenanceforRental(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         300000:
        //             ValidateAccScheduleLine(Rec, '6325..6330', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         310000:
        //             ValidateAccScheduleLine(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         320000:
        //             ValidateAccScheduleLine(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         350000:
        //             ValidateAccScheduleLine(Rec, CreateDEGLAcc.BadDebtLosses(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //     end;
        // if Rec."Schedule Name" = CreateAccountScheduleName.RetainedEarnings() then
        //     case Rec."Line No." of
        //         10000:
        //             ValidateAccScheduleLine(Rec, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         20000:
        //             ValidateAccScheduleLine(Rec, '4..8999', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //         50000:
        //             ValidateAccScheduleLine(Rec, CreateDEGLAcc.DistributionstoShareholders(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts");
        //     end;
        if Rec."Schedule Name" = CreateAccountScheduleName.Revenues() then
            case Rec."Line No." of
                40000:
                    ValidateAccScheduleLine(Rec, '11', SalesRetailDomLbl, '8400', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false, false);
                50000:
                    ValidateAccScheduleLine(Rec, '12', SalesRetailEULbl, '8315', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false, false);
                60000:
                    ValidateAccScheduleLine(Rec, '13', SalesRetailExportLbl, '8120', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false, false);
                70000:
                    ValidateAccScheduleLine(Rec, '14', JobSalesAdjmtRetailLbl, '8451', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false, false);
                80000:
                    ValidateAccScheduleLine(Rec, '15', SalesofRetailTotalLbl, '8550', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false, false);
                100000:
                    ValidateAccScheduleLine(Rec, '20', RevenueArea10to30TotalLbl, '8400..8550', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false, false);
                110000:
                    ValidateAccScheduleLine(Rec, '21', RevenueArea40to85TotalLbl, '8400..8550', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false, false);
                120000:
                    ValidateAccScheduleLine(Rec, '22', RevenueNoAreacodeTotalLbl, '8400..8550', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false, false);
                130000:
                    ValidateAccScheduleLine(Rec, '30', RevenueTotalLbl, '20..29', Enum::"Acc. Schedule Line Totaling Type"::Formula, true, false);
            end;
    end;

    local procedure ValidateAccScheduleLine(var AccScheduleLine: Record "Acc. Schedule Line"; RowNo: Code[10]; Description: Text[100]; Totaling: Text[250]; TotalingType: Enum "Acc. Schedule Line Totaling Type"; Bold: Boolean; HideCurrencySymbol: Boolean)
    begin
        AccScheduleLine.Validate("Row No.", RowNo);
        AccScheduleLine.Validate(Description, Description);
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
        AccScheduleLine.Validate(Bold, Bold);
        AccScheduleLine.Validate("Hide Currency Symbol", HideCurrencySymbol);
    end;

    var
        IncomeStatementLbl: Label 'INCOME STATEMENT', MaxLength = 100;
        IncomeLbl: Label 'Income', MaxLength = 100;
        CostOfGoodsSoldLbl: Label 'Cost of Goods Sold', MaxLength = 100;
        ExpenseLbl: Label 'Expense', MaxLength = 100;
        NetIncomeLbl: Label 'NET INCOME', MaxLength = 100;
        OtherExpensesLbl: Label 'Other Expenses', MaxLength = 100;
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
        TotalCostLbl: Label 'Total Cost', MaxLength = 100;
        OperatingExpensesLbl: Label 'Operating Expenses', MaxLength = 100;
        IncomeBeforeInterestAndTaxLbl: Label 'Income before Interest and Tax', MaxLength = 100;
        SalesRetailDomLbl: Label 'Sales, Retail - Dom.', MaxLength = 100;
        SalesRetailEULbl: Label 'Sales, Retail - EU', MaxLength = 100;
        SalesRetailExportLbl: Label 'Sales, Retail - Export', MaxLength = 100;
        JobSalesAdjmtRetailLbl: Label 'Job Sales Adjmt, Retail', MaxLength = 100;
        SalesofRetailTotalLbl: Label 'Sales of Retail, Total', MaxLength = 100;
        RevenueArea10to30TotalLbl: Label 'Revenue Area 10..30, Total', MaxLength = 100;
        RevenueArea40to85TotalLbl: Label 'Revenue Area 40..85, Total', MaxLength = 100;
        RevenueNoAreacodeTotalLbl: Label 'Revenue, no Area code, Total', MaxLength = 100;
        RevenueTotalLbl: Label 'Revenue, Total', MaxLength = 100;
        LiabilitiesLbl: Label 'Liabilities', MaxLength = 100;
        GrossMarginPerLbl: Label 'Gross Margin %', MaxLength = 100;
        OperatingMarginPerLbl: Label 'Operating Margin %', MaxLength = 100;
}
