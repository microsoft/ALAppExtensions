codeunit 5111 "Jobs Demo Accounts"
{
    SingleInstance = true;

    procedure AddAccount(AccountKey: Code[20]; AccountValue: Code[20])
    begin
        AddAccount(AccountKey, AccountValue, '');
    end;

    procedure AddAccount(AccountKey: Code[20]; AccountValue: Code[20]; AccountDescription: Text[50])
    begin
        if JobsDemoAccount.Get(AccountKey) then begin
            JobsDemoAccount."Account Value" := AccountValue;
            if AccountDescription <> '' then
                JobsDemoAccount."Account Description" := AccountDescription;
            JobsDemoAccount.Modify();
        end else begin
            JobsDemoAccount.Init();
            JobsDemoAccount."Account Key" := AccountKey;
            JobsDemoAccount."Account Value" := AccountValue;
            JobsDemoAccount."Account Description" := AccountDescription;
            JobsDemoAccount.Insert();
        end;
    end;

    procedure GetDemoAccount(AccountNo: Code[20]): Record "Jobs Demo Account"
    begin
        JobsDemoAccount.Get(AccountNo);
        exit(JobsDemoAccount);
    end;

    procedure GetAccount(AccountNo: Code[20]): Code[20]
    begin
        if JobsDemoAccount.Get(AccountNo) then
            exit(JobsDemoAccount."Account Value");

        exit(AccountNo);
    end;

    var
        JobsDemoAccount: Record "Jobs Demo Account";
}