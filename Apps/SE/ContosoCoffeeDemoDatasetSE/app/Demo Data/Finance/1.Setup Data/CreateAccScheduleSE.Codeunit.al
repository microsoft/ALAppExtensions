codeunit 11212 "Create Acc. Schedule SE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateAccScheduleName();
        CreateFinancialReport();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertAccScheduleLine(var Rec: Record "Acc. Schedule Line")
    var
        CreateAccountScheduleName: Codeunit "Create Acc. Schedule Name";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        if Rec."Schedule Name" = CreateAccountScheduleName.AccountCategoriesOverview() then
            case Rec."Line No." of
                60000:
                    ValidateRecordFields(Rec, CreateGLAccount.NETINCOME(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CapitalStructure() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, CreateGLAccount.InventoryTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsReceivableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                60000:
                    ValidateRecordFields(Rec, CreateGLAccount.SecuritiesTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                70000:
                    ValidateRecordFields(Rec, CreateGLAccount.LiquidAssetsTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                110000:
                    ValidateRecordFields(Rec, CreateGLAccount.RevolvingCredit(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                120000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsPayableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                130000:
                    ValidateRecordFields(Rec, CreateGLAccount.VATTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                140000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalPersonnelrelatedItems(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                150000:
                    ValidateRecordFields(Rec, CreateGLAccount.OtherLiabilitiesTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CashCycle() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                20000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsReceivableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                30000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsPayableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, CreateGLAccount.InventoryTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                50000:
                    ValidateRecordFields(Rec, '-360*''20''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                60000:
                    ValidateRecordFields(Rec, '360*''30''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                70000:
                    ValidateRecordFields(Rec, '-360*''40''/''10''', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                80000:
                    ValidateRecordFields(Rec, '100+110-120', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.CashFlow() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsReceivableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                20000:
                    ValidateRecordFields(Rec, CreateGLAccount.AccountsPayableTotal(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                30000:
                    ValidateRecordFields(Rec, CreateGLAccount.LiquidAssetsTotal() + '|' + CreateGLAccount.RevolvingCredit(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, '10' + '..' + '30', Enum::"Acc. Schedule Line Totaling Type"::Formula, false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.IncomeExpense() then
            case Rec."Line No." of
                10000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                30000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalCost(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, CreateGLAccount.BalanceSheet(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalPersonnelExpenses(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                60000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalFixedAssetDepreciation(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                70000:
                    ValidateRecordFields(Rec, CreateGLAccount.OtherCostsofOperations(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.ReducedTrialBalance() then
            case Rec."Line No." of
                10000:
                    begin
                        ValidateRecordFields(Rec, CreateGLAccount.TotalRevenue(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                        Rec.Validate(Description, TotalRevenueLbl);
                    end;
                20000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalCost(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                40000:
                    ValidateRecordFields(Rec, '-''30''/''10''*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.BalanceSheet() + '|' + CreateGLAccount.TotalPersonnelExpenses() + '|' + CreateGLAccount.TotalFixedAssetDepreciation(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
                70000:
                    ValidateRecordFields(Rec, '-''60''/''10''*100', Enum::"Acc. Schedule Line Totaling Type"::Formula, true);
                80000:
                    ValidateRecordFields(Rec, CreateGLAccount.OtherCostsofOperations(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                90000:
                    ValidateRecordFields(Rec, CreateGLAccount.NETINCOMEBEFORETAXES(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
            end;

        if Rec."Schedule Name" = CreateAccountScheduleName.Revenues() then
            case Rec."Line No." of
                40000:
                    ValidateRecordFields(Rec, CreateGLAccount.SalesRetailDom(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                50000:
                    ValidateRecordFields(Rec, CreateGLAccount.SalesRetailEU(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                60000:
                    ValidateRecordFields(Rec, CreateGLAccount.SalesRetailExport(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                70000:
                    ValidateRecordFields(Rec, CreateGLAccount.JobSalesAppliedRetail(), Enum::"Acc. Schedule Line Totaling Type"::"Posting Accounts", false);
                80000:
                    ValidateRecordFields(Rec, CreateGLAccount.TotalSalesofRetail(), Enum::"Acc. Schedule Line Totaling Type"::"Total Accounts", false);
            end;
    end;

    local procedure ValidateRecordFields(var AccScheduleLine: Record "Acc. Schedule Line"; Totaling: Text; TotalingType: Enum "Acc. Schedule Line Totaling Type"; HideCurrencySymbol: Boolean)
    begin
        AccScheduleLine.Validate(Totaling, Totaling);
        AccScheduleLine.Validate("Totaling Type", TotalingType);
        if HideCurrencySymbol then
            AccScheduleLine.Validate("Hide Currency Symbol", HideCurrencySymbol);
    end;

    local procedure CreateAccScheduleName()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertAccScheduleName(BalanceSheetDetailed(), BalanceSheetDetailedLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(BalanceSheetSummarized(), BalanceSheetSummarizedLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(IncomeStatementDetailed(), IncomeStatementDetailedLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(IncomeStatementSummarized(), IncomeStatementSummarizedLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(TrialBalance(), TrialBalanceLbl, '');
    end;

    local procedure CreateFinancialReport()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.SetOverwriteData(true);
        ContosoAccountSchedule.InsertFinancialReport(BalanceSheetDetailed(), BalanceSheetDetailedLbl, BalanceSheetDetailed(), BalanceSheetTrendLbl);
        ContosoAccountSchedule.InsertFinancialReport(BalanceSheetSummarized(), BalanceSheetSummarizedLbl, BalanceSheetSummarized(), BalanceSheetTrendLbl);
        ContosoAccountSchedule.InsertFinancialReport(IncomeStatementDetailed(), IncomeStatementDetailedLbl, IncomeStatementDetailed(), IncomeStatementTrendLbl);
        ContosoAccountSchedule.InsertFinancialReport(IncomeStatementSummarized(), IncomeStatementSummarizedLbl, IncomeStatementSummarized(), IncomeStatementTrendLbl);
        ContosoAccountSchedule.InsertFinancialReport(TrialBalance(), TrialBalanceLbl, TrialBalance(), BeginningBalanceDebitsCreditsEndingBalanceLbl);
        ContosoAccountSchedule.SetOverwriteData(false);
    end;

    procedure BalanceSheetDetailed(): Code[10]
    begin
        exit(BalanceSheetDetailedTok);
    end;

    procedure BalanceSheetSummarized(): Code[10]
    begin
        exit(BalanceSheetSummarizedTok);
    end;

    procedure IncomeStatementDetailed(): Code[10]
    begin
        exit(IncomeStatementDetailedTok);
    end;

    procedure IncomeStatementSummarized(): Code[10]
    begin
        exit(IncomeStatementSummarizedTok);
    end;

    procedure TrialBalance(): Code[10]
    begin
        exit(TrialBalanceTok);
    end;

    var
        BalanceSheetDetailedTok: Label 'BS DET', MaxLength = 10, Locked = true;
        BalanceSheetTrendLbl: Label 'BSTREND', MaxLength = 10, Locked = true;
        IncomeStatementTrendLbl: Label 'ISTREND', MaxLength = 10, Locked = true;
        TrialBalanceTok: Label 'TB', MaxLength = 10, Locked = true;
        BalanceSheetSummarizedTok: Label 'BS SUM', MaxLength = 10, Locked = true;
        BeginningBalanceDebitsCreditsEndingBalanceLbl: Label 'BBDRCREB', MaxLength = 10, Locked = true;
        IncomeStatementSummarizedTok: Label 'IS SUM', MaxLength = 10, Locked = true;
        IncomeStatementDetailedTok: Label 'IS DET', MaxLength = 10, Locked = true;
        BalanceSheetDetailedLbl: Label 'Balance Sheet Detailed', MaxLength = 80;
        BalanceSheetSummarizedLbl: Label 'Balance Sheet Summarized', MaxLength = 80;
        IncomeStatementDetailedLbl: Label 'Income Statement Detailed', MaxLength = 80;
        IncomeStatementSummarizedLbl: Label 'Income Statement Summarized', MaxLength = 80;
        TrialBalanceLbl: Label 'Trial Balance', MaxLength = 80;
        TotalRevenueLbl: Label 'Total Revenue', MaxLength = 100;
}