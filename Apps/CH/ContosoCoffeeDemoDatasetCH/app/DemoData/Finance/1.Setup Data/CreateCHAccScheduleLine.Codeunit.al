codeunit 11583 "Create CH Acc Schedule Line"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record "Acc. Schedule Line"; RunTrigger: Boolean)
    var
        CreateAccScheduleName: Codeunit "Create Acc. Schedule Name";
        CreateCHGLAccounts: Codeunit "Create CH GL Accounts";
    begin
        if (Rec."Schedule Name" = CreateAccScheduleName.AccountCategoriesOverview()) and (Rec."Line No." = 60000) then
            ValidateRecordFields(Rec, '4010', IncomeThisYearLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);

        if Rec."Schedule Name" = CreateAccScheduleName.CapitalStructure() then
            case
                Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, '101', InventoryLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                50000:
                    ValidateRecordFields(Rec, '102', AccountsReceivableLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                60000:
                    ValidateRecordFields(Rec, '103', SecuritiesLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                70000:
                    ValidateRecordFields(Rec, '104', LiquidAssetsLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                110000:
                    ValidateRecordFields(Rec, '111', RevolvingCreditLbl, CreateCHGLAccounts.BankOverdraft(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                120000:
                    ValidateRecordFields(Rec, '112', AccountsPayableLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                130000:
                    ValidateRecordFields(Rec, '113', VATLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                140000:
                    ValidateRecordFields(Rec, '114', PersonnelRelatedItemsLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                150000:
                    ValidateRecordFields(Rec, '115', OtherLiabilitiesLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.CashCycle() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '10', TotalRevenueLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                20000:
                    ValidateRecordFields(Rec, '20', TotalReceivablesLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                30000:
                    ValidateRecordFields(Rec, '30', TotalPayablesLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                40000:
                    ValidateRecordFields(Rec, '40', TotalInventoryLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                50000:
                    ValidateRecordFields(Rec, '100', DaysofSalesOutstandingLbl, '-360*''20''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true);
                60000:
                    ValidateRecordFields(Rec, '110', DaysofPaymentOutstandingLbl, '360*''30''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true);
                70000:
                    ValidateRecordFields(Rec, '120', DaysSalesofInventoryLbl, '-360*''40''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true);
                80000:
                    ValidateRecordFields(Rec, '200', CashCycleDaysLbl, '100+110-120', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true);
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.CashFlow() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '10', TotalReceivablesLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                20000:
                    ValidateRecordFields(Rec, '20', TotalPayablesLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                30000:
                    ValidateRecordFields(Rec, '30', TotalLiquidFundsLbl, 'XXXX' + '|' + CreateCHGLAccounts.BankOverdraft(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                40000:
                    ValidateRecordFields(Rec, '40', TotalCashFlowLbl, '10..30', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false);
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.IncomeExpense() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '10', TotalRevenueCreditLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                30000:
                    ValidateRecordFields(Rec, '20', TotalGoodsSoldLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                40000:
                    ValidateRecordFields(Rec, '30', TotalExternalCostsLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                50000:
                    ValidateRecordFields(Rec, '40', TotalPersonnelCostsLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                60000:
                    ValidateRecordFields(Rec, '50', TotalDeprOnFALbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                70000:
                    ValidateRecordFields(Rec, '60', OtherExpensesLbl, CreateCHGLAccounts.MiscCosts(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.ReducedTrialBalance() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '10', TotalRevenueLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                20000:
                    ValidateRecordFields(Rec, '20', TotalCostLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                40000:
                    ValidateRecordFields(Rec, '40', GrossMarginPerLbl, '-''30''/''10''*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true);
                50000:
                    ValidateRecordFields(Rec, '50', OperatingExpensesLbl, 'XXXX|XXXX|XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                70000:
                    ValidateRecordFields(Rec, '70', OperatingMarginPerLbl, '-''60''/''10''*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true);
                80000:
                    ValidateRecordFields(Rec, '80', OtherExpensesLbl, CreateCHGLAccounts.MiscCosts(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                90000:
                    ValidateRecordFields(Rec, '90', IncomeBeforeInterestAndTaxLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.Revenues() then
            case
                Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, '11', SalesRetailDomLbl, CreateCHGLAccounts.TradeDomestic(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                50000:
                    ValidateRecordFields(Rec, '12', SalesRetailEULbl, CreateCHGLAccounts.TradeEurope(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                60000:
                    ValidateRecordFields(Rec, '13', SalesRetailExportLbl, CreateCHGLAccounts.TradeInternat(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                70000:
                    ValidateRecordFields(Rec, '14', JobSalesAdjmtRetailLbl, CreateCHGLAccounts.JobSalesAppliedAccount(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                80000:
                    ValidateRecordFields(Rec, '15', SalesofRetailTotalLbl, 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                100000:
                    ValidateRecordFields(Rec, '', RevenueArea10to30TotalLbl, CreateCHGLAccounts.TradeDomestic() + '..' + 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '10..30', false);
                110000:
                    ValidateRecordFields(Rec, '', RevenueArea40to85TotalLbl, CreateCHGLAccounts.TradeDomestic() + '..' + 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '40..85', false);
                120000:
                    ValidateRecordFields(Rec, '', RevenueNoAreacodeTotalLbl, CreateCHGLAccounts.TradeDomestic() + '..' + 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
                130000:
                    ValidateRecordFields(Rec, '', RevenueTotalLbl, CreateCHGLAccounts.TradeDomestic() + '..' + 'XXXX', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false);
            end;
    end;

    local procedure ValidateRecordFields(var AccScheduleLine: Record "Acc. Schedule Line"; RowNo: Code[10]; Description: Text[100]; Totaling: Text[250]; TotalingType: Enum "Acc. Schedule Line Totaling Type"; Show: Enum "Acc. Schedule Line Show"; Dimension1Totaling: Text[250]; HideCurrencySymbol: Boolean)
    begin
        AccScheduleLine.Validate("Row No.", RowNo);
        AccScheduleLine.Validate(Description, Description);
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
        AccScheduleLine.Validate(Show, Show);
        AccScheduleLine.Validate("Dimension 1 Totaling", Dimension1Totaling);
        AccScheduleLine.Validate("Hide Currency Symbol", HideCurrencySymbol);
    end;

    var
        IncomeThisYearLbl: Label 'Income This Year', MaxLength = 100;
        InventoryLbl: Label 'Inventory', MaxLength = 100;
        AccountsReceivableLbl: Label 'Accounts Receivable', MaxLength = 100;
        SecuritiesLbl: Label 'Securities', MaxLength = 100;
        LiquidAssetsLbl: Label 'Liquid Assets', MaxLength = 100;
        RevolvingCreditLbl: Label 'Revolving Credit', MaxLength = 100;
        AccountsPayableLbl: Label 'Accounts Payable', MaxLength = 100;
        VATLbl: Label 'VAT', MaxLength = 100;
        PersonnelRelatedItemsLbl: Label 'Personnel-related Items', MaxLength = 100;
        OtherLiabilitiesLbl: Label 'Other Liabilities', MaxLength = 100;
        SalesofRetailTotalLbl: Label 'Sales of Retail, Total', MaxLength = 100;
        RevenueNoAreacodeTotalLbl: Label 'Revenue, no Area code, Total', MaxLength = 100;
        RevenueTotalLbl: Label 'Revenue, Total', MaxLength = 100;
        TotalRevenueLbl: Label 'Total Revenue', MaxLength = 100;
        TotalReceivablesLbl: Label 'Total Receivables', MaxLength = 100;
        TotalPayablesLbl: Label 'Total Payables', MaxLength = 100;
        TotalInventoryLbl: Label 'Total Inventory', MaxLength = 100;
        DaysofSalesOutstandingLbl: Label 'Days of Sales Outstanding', MaxLength = 100;
        DaysofPaymentOutstandingLbl: Label 'Days of Payment Outstanding', MaxLength = 100;
        DaysSalesofInventoryLbl: Label 'Days Sales of Inventory', MaxLength = 100;
        CashCycleDaysLbl: Label 'Cash Cycle (Days)', MaxLength = 100;
        SalesRetailDomLbl: Label 'Sales, Retail - Dom.', MaxLength = 100;
        SalesRetailEULbl: Label 'Sales, Retail - EU', MaxLength = 100;
        SalesRetailExportLbl: Label 'Sales, Retail - Export', MaxLength = 100;
        JobSalesAdjmtRetailLbl: Label 'Job Sales Adjmt, Retail', MaxLength = 100;
        RevenueArea10to30TotalLbl: Label 'Revenue Area 10..30, Total', MaxLength = 100;
        RevenueArea40to85TotalLbl: Label 'Revenue Area 40..85, Total', MaxLength = 100;
        OtherExpensesLbl: Label 'Other Expenses', MaxLength = 100;
        TotalCashFlowLbl: Label 'Total Cash Flow', MaxLength = 100;
        TotalLiquidFundsLbl: Label 'Total Liquid Funds', MaxLength = 100;
        TotalRevenueCreditLbl: Label 'Total Revenue (Credit)', MaxLength = 100;
        TotalGoodsSoldLbl: Label 'Total Goods Sold', MaxLength = 100;
        TotalExternalCostsLbl: Label 'Total External Costs ', MaxLength = 100;
        TotalPersonnelCostsLbl: Label 'Total Personnel Costs', MaxLength = 100;
        TotalDeprOnFALbl: Label 'Total Depr. on Fixed Assets', MaxLength = 100;
        TotalCostLbl: Label 'Total Cost', MaxLength = 100;
        GrossMarginPerLbl: Label 'Gross Margin %', MaxLength = 100;
        OperatingExpensesLbl: Label 'Operating Expenses', MaxLength = 100;
        OperatingMarginPerLbl: Label 'Operating Margin %', MaxLength = 100;
        IncomeBeforeInterestAndTaxLbl: Label 'Income before Interest and Tax', MaxLength = 100;
}