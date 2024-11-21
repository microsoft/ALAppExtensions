codeunit 10792 "Create ES Financial Report"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
        CreateESAccountScheduleName: Codeunit "Create ES Acc Schedule Name";
    begin
        ContosoAccountSchedule.SetOverwriteData(true);
        ContosoAccountSchedule.InsertFinancialReport(CreateESAccountScheduleName.BalanceSheetDetail(), BalanceSheetDetailedLbl, CreateESAccountScheduleName.BalanceSheetDetail(), BalanceSheetTrendLbl);
        ContosoAccountSchedule.InsertFinancialReport(CreateESAccountScheduleName.BalanceSheetSummarized(), BalanceSheetSummarizedLbl, CreateESAccountScheduleName.BalanceSheetSummarized(), BalanceSheetTrendLbl);
        ContosoAccountSchedule.InsertFinancialReport(CreateESAccountScheduleName.IncomeStatementDetail(), IncomeStatementDetailedLbl, CreateESAccountScheduleName.IncomeStatementDetail(), IncomeStatementTrendLbl);
        ContosoAccountSchedule.InsertFinancialReport(CreateESAccountScheduleName.IncomeStatementSummarized(), IncomeStatementSummarizedLbl, CreateESAccountScheduleName.IncomeStatementSummarized(), IncomeStatementTrendLbl);
        ContosoAccountSchedule.InsertFinancialReport(CreateESAccountScheduleName.TrialBalance(), TrialBalanceLbl, CreateESAccountScheduleName.TrialBalance(), BeginningBalanceDebitsCreditsEndingBalanceLbl);
        ContosoAccountSchedule.SetOverwriteData(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Financial Report", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertFinancialReport(var Rec: Record "Financial Report")
    var
        CreateFinancialReport: Codeunit "Create Financial Report";
    begin
        case Rec.Name of
            CreateFinancialReport.CapitalStructure():
                Rec.Validate("Financial Report Column Group", 'DEFAULT');
        end;
    end;

    var
        BalanceSheetDetailedLbl: Label 'Balance Sheet Detailed', MaxLength = 80;
        BalanceSheetSummarizedLbl: Label 'Balance Sheet Summarized', MaxLength = 80;
        IncomeStatementDetailedLbl: Label 'Income Statement Detailed', MaxLength = 80;
        IncomeStatementSummarizedLbl: Label 'Income Statement Summarized', MaxLength = 80;
        TrialBalanceLbl: Label 'Trial Balance', MaxLength = 80;
        BalanceSheetTrendLbl: Label 'BSTREND', MaxLength = 10;
        IncomeStatementTrendLbl: Label 'ISTREND', MaxLength = 10;
        BeginningBalanceDebitsCreditsEndingBalanceLbl: Label 'BBDRCREB', MaxLength = 10;
}