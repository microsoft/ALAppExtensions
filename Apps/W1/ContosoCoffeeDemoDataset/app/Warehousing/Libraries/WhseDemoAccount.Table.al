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

    procedure Finished(): Code[20]
    begin
        if IsReturnKey then
            exit('992120');
        exit(WhseDemoAccounts.GetAccount('992120'));
    end;

    procedure FinishedInterim(): Code[20]
    begin
        if IsReturnKey then
            exit('992121');
        exit(WhseDemoAccounts.GetAccount('992121'));
    end;

    procedure FinishedWip(): Code[20]
    begin
        if IsReturnKey then
            exit('992140');
        exit(WhseDemoAccounts.GetAccount('992140'));
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

    procedure CostOfRetailSold(): Code[20]
    begin
        if IsReturnKey then
            exit('997190');
        exit(WhseDemoAccounts.GetAccount('997190'));
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