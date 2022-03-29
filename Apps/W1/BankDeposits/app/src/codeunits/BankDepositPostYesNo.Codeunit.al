codeunit 1692 "Bank Deposit-Post (Yes/No)"
{
    Permissions = TableData "Bank Deposit Header" = r;
    TableNo = "Bank Deposit Header";

    trigger OnRun()
    begin
        BankDepositHeader.Copy(Rec);

        if not Confirm(PostBankDepositQst, false) then
            exit;

        BankDepositPost.Run(BankDepositHeader);
        Rec := BankDepositHeader;
    end;

    var
        BankDepositHeader: Record "Bank Deposit Header";
        BankDepositPost: Codeunit "Bank Deposit-Post";
        PostBankDepositQst: Label 'Do you want to post the bank deposit?';
}

