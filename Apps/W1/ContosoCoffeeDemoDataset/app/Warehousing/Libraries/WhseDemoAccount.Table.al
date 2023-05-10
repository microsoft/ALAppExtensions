table 4762 "Whse. Demo Account"
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
        WhseDemoAccounts: Codeunit "Whse. Demo Accounts";
        IsReturnKey: Boolean;

    procedure ReturnAccountKey(ReturnKey: boolean)
    begin
        IsReturnKey := ReturnKey;
    end;

    procedure Resale(): Code[20]
    begin
        if IsReturnKey then
            exit('992110');
        exit(WhseDemoAccounts.GetAccount('992110'));
    end;

    procedure ResaleInterim(): Code[20]
    begin
        if IsReturnKey then
            exit('992111');
        exit(WhseDemoAccounts.GetAccount('992111'));
    end;

    procedure CustDomestic(): Code[20]
    begin
        if IsReturnKey then
            exit('992310');
        exit(WhseDemoAccounts.GetAccount('992310'));
    end;

    procedure VendDomestic(): Code[20]
    begin
        if IsReturnKey then
            exit('995410');
        exit(WhseDemoAccounts.GetAccount('995410'));
    end;

    procedure SalesDomestic(): Code[20]
    begin
        if IsReturnKey then
            exit('996110');
        exit(WhseDemoAccounts.GetAccount('996110'));
    end;

    procedure PurchDomestic(): Code[20]
    begin
        if IsReturnKey then
            exit('997110');
        exit(WhseDemoAccounts.GetAccount('997110'));
    end;

    procedure SalesVAT(): Code[20]
    begin
        if IsReturnKey then
            exit('995610');
        exit(WhseDemoAccounts.GetAccount('995610'));
    end;

    procedure PurchaseVAT(): Code[20]
    begin
        if IsReturnKey then
            exit('995630');
        exit(WhseDemoAccounts.GetAccount('995630'));
    end;
}