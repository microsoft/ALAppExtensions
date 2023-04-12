codeunit 4784 "Manufacturing Demo Accounts"
{
    SingleInstance = true;

    procedure AddAccount(AccountKey: Code[20]; AccountValue: Code[20])
    begin
        AddAccount(AccountKey, AccountValue, '');
    end;

    procedure AddAccount(AccountKey: Code[20]; AccountValue: Code[20]; AccountDescription: Text[50])
    begin
        if ManufacturingDemoAccount.Get(AccountKey) then begin
            ManufacturingDemoAccount."Account Value" := AccountValue;
            if AccountDescription <> '' then
                ManufacturingDemoAccount."Account Description" := AccountDescription;
            ManufacturingDemoAccount.Modify();
        end else begin
            ManufacturingDemoAccount.Init();
            ManufacturingDemoAccount."Account Key" := AccountKey;
            ManufacturingDemoAccount."Account Value" := AccountValue;
            ManufacturingDemoAccount."Account Description" := AccountDescription;
            ManufacturingDemoAccount.Insert();
        end;
    end;

    procedure GetDemoAccount(AccountNo: Code[20]): Record "Manufacturing Demo Account"
    begin
        ManufacturingDemoAccount.Get(AccountNo);
        exit(ManufacturingDemoAccount);
    end;

    procedure GetAccount(AccountNo: Code[20]): Code[20]
    begin
        if ManufacturingDemoAccount.Get(AccountNo) then
            exit(ManufacturingDemoAccount."Account Value");

        exit(AccountNo);
    end;

    var
        ManufacturingDemoAccount: Record "Manufacturing Demo Account";
}