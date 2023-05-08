table 4764 "Svc Demo Account"
{
    TableType = Temporary;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Account Key"; Code[20]) { }
        field(2; "Account Value"; Code[20]) { }
        field(3; "Account Description"; text[50]) { }

    }

    keys
    {
        key(Key1; "Account Key")
        {
            Clustered = true;
        }
    }

    var
        SvcDemoAccounts: Codeunit "Svc Demo Accounts";
        IsReturnKey: Boolean;

    procedure ReturnAccountKey(ReturnKey: boolean)
    begin
        IsReturnKey := ReturnKey;
    end;

    procedure Contract(): Code[20]
    begin
        if IsReturnKey then
            exit('996700');
        exit(SvcDemoAccounts.GetAccount('996700'));
    end;
}
