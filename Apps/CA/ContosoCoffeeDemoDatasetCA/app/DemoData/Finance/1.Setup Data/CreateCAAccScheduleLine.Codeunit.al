codeunit 27043 "Create CA Acc. Schedule Line"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    // ToDo: Could not find out G/L Accounts 99999, 11700, 22790, 66400, 69999

    trigger OnRun()
    var
        CreateAccountScheduleName: Codeunit "Create Acc. Schedule Name";
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
        AccountScheduleName: Code[10];
    begin
        AccountScheduleName := CreateAccountScheduleName.CapitalStructure();
        ContosoAccountSchedule.InsertAccScheduleLine(AccountScheduleName, 190000, '', CAMinusShortTermLiabLbl, '06|16', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', true, false, false, false, 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Acc. Schedule Line")
    var
        CreateAccScheduleName: Codeunit "Create Acc. Schedule Name";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateCAGLAccounts: Codeunit "Create CA GL Accounts";
    begin
        if (Rec."Schedule Name" = CreateAccScheduleName.AccountCategoriesOverview()) and (Rec."Line No." = 60000) then
            ValidateRecordFields(Rec, '4010', IncomeThisYearLbl, '99999', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);

        if Rec."Schedule Name" = CreateAccScheduleName.CapitalStructure() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '', AcidTestAnalysisLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false);
                30000:
                    ValidateRecordFields(Rec, '', CurrentAssetsLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false);
                40000:
                    ValidateRecordFields(Rec, '01', LiquidAssetsLbl, '11700', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
                50000:
                    ValidateRecordFields(Rec, '02', SecuritiesLbl, CreateGLAccount.Bonds(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
                60000:
                    ValidateRecordFields(Rec, '03', AccountsReceivableLbl, CreateCAGLAccounts.AccountsReceivableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
                70000:
                    ValidateRecordFields(Rec, '04', InventoryLbl, CreateCAGLAccounts.WipAccountFinishedGoods(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
                80000:
                    ValidateRecordFields(Rec, '05', WIPLbl, CreateCAGLAccounts.JobWIPTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, false);
                90000:
                    ValidateRecordFields(Rec, '06', CurrentAssetsTotalLbl, '01..05', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', true, false);
                100000:
                    ValidateRecordFields(Rec, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                110000:
                    ValidateRecordFields(Rec, '', ShortTermLiabilitiesLbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, false);
                120000:
                    ValidateRecordFields(Rec, '11', RevolvingCreditLbl, CreateGLAccount.RevolvingCredit(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true);
                130000:
                    ValidateRecordFields(Rec, '12', AccountsPayableLbl, CreateCAGLAccounts.AccountsPayableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true);
                140000:
                    ValidateRecordFields(Rec, '13', SalesTaxesPayableLbl, '22790', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true);
                150000:
                    ValidateRecordFields(Rec, '14', PersonnelRelatedItemsLbl, CreateCAGLAccounts.TotalPersonnelRelatedItems(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true);
                160000:
                    ValidateRecordFields(Rec, '15', OtherLiabilitiesLbl, CreateCAGLAccounts.OtherLiabilitiesTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', false, true);
                170000:
                    ValidateRecordFields(Rec, '16', ShortTermLiabilitiesTotalLbl, '11..15', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::"If Any Column Not Zero", '', true, true);
                180000:
                    ValidateRecordFields(Rec, '', '', '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.CashCycle() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '10', TotalRevenueLbl, CreateCAGLAccounts.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                20000:
                    ValidateRecordFields(Rec, '20', TotalReceivablesLbl, CreateCAGLAccounts.AccountsReceivableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                30000:
                    ValidateRecordFields(Rec, '30', TotalPayablesLbl, CreateCAGLAccounts.AccountsPayableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                40000:
                    ValidateRecordFields(Rec, '40', TotalInventoryLbl, CreateCAGLAccounts.WipAccountFinishedGoods(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                50000,
                60000,
                70000,
                80000:
                    Rec.Validate("Hide Currency Symbol", true);
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.CashFlow() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '10', TotalReceivablesLbl, CreateCAGLAccounts.AccountsReceivableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                20000:
                    ValidateRecordFields(Rec, '20', TotalPayablesLbl, CreateCAGLAccounts.AccountsPayableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                30000:
                    ValidateRecordFields(Rec, '30', TotalLiquidFundsLbl, '11700|' + CreateGLAccount.RevolvingCredit(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                40000:
                    ValidateRecordFields(Rec, '40', TotalCashFlowLbl, '10..30', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.IncomeExpense() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '10', TotalRevenueCreditLbl, CreateCAGLAccounts.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                30000:
                    ValidateRecordFields(Rec, '20', TotalGoodsSoldLbl, CreateCAGLAccounts.TotalCost(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                40000:
                    ValidateRecordFields(Rec, '30', TotalExternalCostsLbl, CreateCAGLAccounts.TotalOperatingExpenses(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                50000:
                    ValidateRecordFields(Rec, '40', TotalPersonnelCostsLbl, CreateCAGLAccounts.TotalPersonnelExpenses(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                60000:
                    ValidateRecordFields(Rec, '50', TotalDeprOnFALbl, '66400', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                70000:
                    ValidateRecordFields(Rec, '60', OtherExpensesLbl, CreateGLAccount.OtherCostsofOperations(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.ReducedTrialBalance() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, '10', TotalRevenueLbl, CreateCAGLAccounts.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true);
                20000:
                    ValidateRecordFields(Rec, '20', TotalCostLbl, CreateCAGLAccounts.TotalCost(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true);
                50000:
                    ValidateRecordFields(Rec, '50', OperatingExpensesLbl, CreateCAGLAccounts.TotalOperatingExpenses(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                80000:
                    ValidateRecordFields(Rec, '80', OtherExpensesLbl, CreateGLAccount.OtherCostsofOperations(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, false);
                90000:
                    ValidateRecordFields(Rec, '90', IncomeBeforeInterestAndTaxLbl, '69999', Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true);
                40000,
                70000:
                    Rec.Validate("Hide Currency Symbol", true);
            end;

        if Rec."Schedule Name" = CreateAccScheduleName.Revenues() then
            case Rec."Line No." of
                30000:
                    Rec.Validate(Bold, true);
                40000:
                    ValidateRecordFields(Rec, '11', SalesRetailDomLbl, CreateGLAccount.JobSales(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true);
                50000:
                    ValidateRecordFields(Rec, '12', SalesRetailEULbl, '', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true);
                60000:
                    ValidateRecordFields(Rec, '13', SalesRetailExportLbl, CreateCAGLAccounts.TotalSalesOfJobs(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true);
                70000:
                    ValidateRecordFields(Rec, '14', JobSalesAdjmtRetailLbl, '40250|40450', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true);
                80000:
                    ValidateRecordFields(Rec, '15', SalesofRetailTotalLbl, '11..14', Enum::"Acc. Schedule Line Totaling Type"::Formula, Enum::"Acc. Schedule Line Show"::Yes, '', true, true);
                100000:
                    ValidateRecordFields(Rec, '21', RevenueArea10to55TotalLbl, CreateGLAccount.JobSales() + '|' + CreateCAGLAccounts.TotalSalesOfJobs() + '|40250|40450', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '10..55', false, true);
                110000:
                    ValidateRecordFields(Rec, '22', RevenueArea60to85TotalLbl, CreateGLAccount.JobSales() + '|' + CreateCAGLAccounts.TotalSalesOfJobs() + '|40250|40450', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '60..85', false, true);
                120000:
                    ValidateRecordFields(Rec, '23', RevenueNoAreacodeTotalLbl, CreateGLAccount.JobSales() + '|' + CreateCAGLAccounts.TotalSalesOfJobs() + '|40250|40450', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', false, true);
                130000:
                    ValidateRecordFields(Rec, '24', RevenueTotalLbl, '21..23', Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", Enum::"Acc. Schedule Line Show"::Yes, '', true, true);
            end;
    end;

    local procedure ValidateRecordFields(var AccScheduleLine: Record "Acc. Schedule Line"; RowNo: Code[10]; Description: Text[100]; Totaling: Text[250]; TotalingType: Enum "Acc. Schedule Line Totaling Type"; Show: Enum "Acc. Schedule Line Show"; Dimension1Totaling: Text[250]; Bold: Boolean; ShowOppositeSign: Boolean)
    begin
        AccScheduleLine.Validate("Row No.", RowNo);
        AccScheduleLine.Validate(Description, Description);
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
        AccScheduleLine.Validate(Show, Show);
        AccScheduleLine.Validate("Dimension 1 Totaling", Dimension1Totaling);
        AccScheduleLine.Validate(Bold, Bold);
        AccScheduleLine.Validate("Show Opposite Sign", ShowOppositeSign);
    end;

    var
        IncomeThisYearLbl: Label 'Income This Year', MaxLength = 100;
        AcidTestAnalysisLbl: Label 'ACID-TEST ANALYSIS', MaxLength = 100;
        CurrentAssetsLbl: Label 'Current Assets', MaxLength = 100;
        InventoryLbl: Label 'Inventory', MaxLength = 100;
        AccountsReceivableLbl: Label 'Accounts Receivable', MaxLength = 100;
        SecuritiesLbl: Label 'Securities', MaxLength = 100;
        LiquidAssetsLbl: Label 'Liquid Assets', MaxLength = 100;
        CurrentAssetsTotalLbl: Label 'Current Assets, Total', MaxLength = 100;
        ShortTermLiabilitiesLbl: Label 'Short-term Liabilities', MaxLength = 100;
        ShortTermLiabilitiesTotalLbl: Label 'Short-term Liabilities, Total', MaxLength = 100;
        RevolvingCreditLbl: Label 'Revolving Credit', MaxLength = 100;
        AccountsPayableLbl: Label 'Accounts Payable', MaxLength = 100;
        PersonnelRelatedItemsLbl: Label 'Personnel-related Items', MaxLength = 100;
        OtherLiabilitiesLbl: Label 'Other Liabilities', MaxLength = 100;
        OtherExpensesLbl: Label 'Other Expenses', MaxLength = 100;
        TotalCashFlowLbl: Label 'Total Cash Flow', MaxLength = 100;
        TotalRevenueLbl: Label 'Total Revenue', MaxLength = 100;
        TotalReceivablesLbl: Label 'Total Receivables', MaxLength = 100;
        TotalPayablesLbl: Label 'Total Payables', MaxLength = 100;
        TotalInventoryLbl: Label 'Total Inventory', MaxLength = 100;
        TotalLiquidFundsLbl: Label 'Total Liquid Funds', MaxLength = 100;
        TotalRevenueCreditLbl: Label 'Total Revenue (Credit)', MaxLength = 100;
        TotalGoodsSoldLbl: Label 'Total Goods Sold', MaxLength = 100;
        TotalExternalCostsLbl: Label 'Total External Costs ', MaxLength = 100;
        TotalPersonnelCostsLbl: Label 'Total Personnel Costs', MaxLength = 100;
        TotalDeprOnFALbl: Label 'Total Depr. on Fixed Assets', MaxLength = 100;
        TotalCostLbl: Label 'Total Cost', MaxLength = 100;
        OperatingExpensesLbl: Label 'Operating Expenses', MaxLength = 100;
        IncomeBeforeInterestAndTaxLbl: Label 'Income before Interest and Tax', MaxLength = 100;
        SalesofRetailTotalLbl: Label 'Sales of Retail, Total', MaxLength = 100;
        RevenueArea10to55TotalLbl: Label 'Revenue Area 10..55, Total', MaxLength = 100;
        RevenueArea60to85TotalLbl: Label 'Revenue Area 60..85, Total', MaxLength = 100;
        RevenueNoAreacodeTotalLbl: Label 'Revenue, no Area code, Total', MaxLength = 100;
        RevenueTotalLbl: Label 'Revenue, Total', MaxLength = 100;
        SalesTaxesPayableLbl: Label 'Sales Taxes Payable', MaxLength = 100;
        WIPLbl: Label 'WIP', MaxLength = 100;
        CAMinusShortTermLiabLbl: Label 'Current Assets minus Short-term Liabilities', MaxLength = 100;
        SalesRetailDomLbl: Label 'Sales, Retail - Dom.', MaxLength = 100;
        SalesRetailEULbl: Label 'Sales, Retail - EU', MaxLength = 100;
        SalesRetailExportLbl: Label 'Sales, Retail - Export', MaxLength = 100;
        JobSalesAdjmtRetailLbl: Label 'Job Sales Adjmt, Retail', MaxLength = 100;
}