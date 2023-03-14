codeunit 1691 "Bank Deposit-Post + Print"
{
    Permissions = TableData "Bank Deposit Header" = r,
                  TableData "Posted Bank Deposit Header" = r;
    TableNo = "Bank Deposit Header";

    trigger OnRun()
    begin
        BankDepositHeader.Copy(Rec);

        if not Confirm(PostPrintBankDepositQst, false) then
            exit;

        BankDepositPost.Run(BankDepositHeader);
        Rec := BankDepositHeader;
        Commit();

        if PostedBankDepositHeader.Get("No.") then begin
            PostedBankDepositHeader.SetRecFilter();
            PrintPostedBankDeposit();
        end;
    end;

    var
        BankDepositHeader: Record "Bank Deposit Header";
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        BankDepositPost: Codeunit "Bank Deposit-Post";
        PostPrintBankDepositQst: Label 'Do you want to post and print the bank deposit?';
        BankDepositReportSelectionErr: Label 'Bank deposit report has not been set up.';

    local procedure PrintPostedBankDeposit()
    var
        ReportSelections: Record "Report Selections";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePrintPostedBankDeposit(PostedBankDepositHeader, IsHandled);
        if IsHandled then
            exit;

        ReportSelections.SetRange(Usage, ReportSelections.Usage::"Bank Deposit");
        ReportSelections.SetRange("Report ID", Report::"Bank Deposit");
        if not ReportSelections.FindFirst() then
            Error(BankDepositReportSelectionErr);

        REPORT.Run(ReportSelections."Report ID", false, false, PostedBankDepositHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintPostedBankDeposit(var PostedBankDepositHeader: Record "Posted Bank Deposit Header"; var IsHandled: Boolean)
    begin
    end;
}

