codeunit 5101 "Svc Demo Accounts"
{
    SingleInstance = true;

    procedure AddAccount(AccountKey: Code[20]; AccountValue: Code[20])
    begin
        AddAccount(AccountKey, AccountValue, '');
    end;

    procedure AddAccount(AccountKey: Code[20]; AccountValue: Code[20]; AccountDescription: Text[50])
    begin
        if SvcDemoAccount.Get(AccountKey) then begin
            SvcDemoAccount."Account Value" := AccountValue;
            if AccountDescription <> '' then
                SvcDemoAccount."Account Description" := AccountDescription;
            SvcDemoAccount.Modify();
        end else begin
            SvcDemoAccount.Init();
            SvcDemoAccount."Account Key" := AccountKey;
            SvcDemoAccount."Account Value" := AccountValue;
            SvcDemoAccount."Account Description" := AccountDescription;
            SvcDemoAccount.Insert();
        end;
    end;

    procedure GetDemoAccount(AccountNo: Code[20]): Record "Svc Demo Account"
    begin
        SvcDemoAccount.Get(AccountNo);
        exit(SvcDemoAccount);
    end;

    procedure GetAccount(AccountNo: Code[20]): Code[20]
    begin
        if SvcDemoAccount.Get(AccountNo) then
            exit(SvcDemoAccount."Account Value");

        exit(AccountNo);
    end;

    var
        SvcDemoAccount: Record "Svc Demo Account";
}