codeunit 4797 "Whse. Demo Accounts"
{
    SingleInstance = true;

    procedure AddAccount(AccountKey: Code[20]; AccountValue: Code[20])
    begin
        AddAccount(AccountKey, AccountValue, '');
    end;

    procedure AddAccount(AccountKey: Code[20]; AccountValue: Code[20]; AccountDescription: Text[50])
    begin
        if WhseDemoAccount.Get(AccountKey) then begin
            WhseDemoAccount."Account Value" := AccountValue;
            if AccountDescription <> '' then
                WhseDemoAccount."Account Description" := AccountDescription;
            WhseDemoAccount.Modify();
        end else begin
            WhseDemoAccount.Init();
            WhseDemoAccount."Account Key" := AccountKey;
            WhseDemoAccount."Account Value" := AccountValue;
            WhseDemoAccount."Account Description" := AccountDescription;
            WhseDemoAccount.Insert();
        end;
    end;

    procedure GetDemoAccount(AccountNo: Code[20]): Record "Whse. Demo Account"
    begin
        WhseDemoAccount.Get(AccountNo);
        exit(WhseDemoAccount);
    end;

    procedure GetAccount(AccountNo: Code[20]): Code[20]
    begin
        if WhseDemoAccount.Get(AccountNo) then
            exit(WhseDemoAccount."Account Value");

        exit(AccountNo);
    end;

    var
        WhseDemoAccount: Record "Whse. Demo Account";
}