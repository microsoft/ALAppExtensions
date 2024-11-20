codeunit 17119 "Create NZ Acc Schedule Name"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.SetOverwriteData(true);
        ContosoAccountSchedule.InsertAccScheduleName(BalanceSheetDetail(), BalanceSheetDetailedLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(BalanceSheetSummarized(), BalanceSheetSummarizedLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(IncomeStatementDetail(), IncomeStatementDetailedLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(IncomeStatementSummarized(), IncomeStatementSummarizedLbl, '');
        ContosoAccountSchedule.InsertAccScheduleName(TrialBalance(), TrialBalanceLbl, '');
        ContosoAccountSchedule.SetOverwriteData(false);
    end;

    procedure BalanceSheetDetail(): Code[10]
    begin
        exit(BalanceSheetDetailTok);
    end;

    procedure BalanceSheetSummarized(): Code[10]
    begin
        exit(BalanceSheetSummarizedTok);
    end;

    procedure IncomeStatementDetail(): Code[10]
    begin
        exit(IncomeStatementDetailTok);
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
        BalanceSheetDetailTok: Label 'BS DET', MaxLength = 10;
        BalanceSheetSummarizedTok: Label 'BS SUM', MaxLength = 10;
        IncomeStatementDetailTok: Label 'IS DET', MaxLength = 10;
        IncomeStatementSummarizedTok: Label 'IS SUM', MaxLength = 10;
        TrialBalanceTok: Label 'TB', MaxLength = 10;
        BalanceSheetDetailedLbl: Label 'Balance Sheet Detailed', MaxLength = 80;
        BalanceSheetSummarizedLbl: Label 'Balance Sheet Summarized', MaxLength = 80;
        IncomeStatementDetailedLbl: Label 'Income Statement Detailed', MaxLength = 80;
        IncomeStatementSummarizedLbl: Label 'Income Statement Summarized', MaxLength = 80;
        TrialBalanceLbl: Label 'Trial Balance', MaxLength = 80;
}