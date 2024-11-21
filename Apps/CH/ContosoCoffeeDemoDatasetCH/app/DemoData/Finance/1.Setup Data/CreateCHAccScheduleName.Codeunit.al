codeunit 11584 "Create CH Acc. Schedule Name"
{
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertAccScheduleName(BalanceSheetDetailed(), BalanceSheetDetailedLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(BalanceSheetSummarized(), BalanceSheetSummarizedLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(IncomeStatementDetailed(), IncomeStatementDetailedLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(IncomeStatementSummarized(), IncomeStatementSummarizedLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(TrialBalance(), TrialBalanceLbl, '');
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
        BalanceSheetDetailedTok: Label 'BS DET', MaxLength = 10;
        BalanceSheetSummarizedTok: Label 'BS SUM', MaxLength = 10;
        IncomeStatementDetailedTok: Label 'IS DET', MaxLength = 10;
        IncomeStatementSummarizedTok: Label 'IS SUM', MaxLength = 10;
        TrialBalanceTok: Label 'TB', MaxLength = 10;
        BalanceSheetDetailedLbl: Label 'Balance Sheet Detailed', MaxLength = 80;
        BalanceSheetSummarizedLbl: Label 'Balance Sheet Summarized', MaxLength = 80;
        IncomeStatementDetailedLbl: Label 'Income Statement Detailed', MaxLength = 80;
        IncomeStatementSummarizedLbl: Label 'Income Statement Summarized', MaxLength = 80;
        TrialBalanceLbl: Label 'Trial Balance', MaxLength = 80;
}