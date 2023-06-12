table 4766 "Jobs Demo Account"
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
        key(Key1; "Account Key") { }
    }

    var
        JobsDemoAccounts: Codeunit "Jobs Demo Accounts";
        IsReturnKey: Boolean;

    procedure ReturnAccountKey(ReturnKey: boolean)
    begin
        IsReturnKey := ReturnKey;
    end;

    procedure WIPCosts(): Code[20]
    begin
        if IsReturnKey then
            exit('992231');
        exit(JobsDemoAccounts.GetAccount('992231'));
    end;

    procedure WIPAccruedCosts(): Code[20]
    begin
        if IsReturnKey then
            exit('992232');
        exit(JobsDemoAccounts.GetAccount('992232'));
    end;

    procedure JobCostsApplied(): Code[20]
    begin
        if IsReturnKey then
            exit('997180');
        exit(JobsDemoAccounts.GetAccount('997180'));
    end;

    procedure ItemCostsApplied(): Code[20]
    begin
        if IsReturnKey then
            exit('997180');
        exit(JobsDemoAccounts.GetAccount('997180'));
    end;

    procedure ResourceCostsApplied(): Code[20]
    begin
        if IsReturnKey then
            exit('997480');
        exit(JobsDemoAccounts.GetAccount('997480'));
    end;

    procedure GLCostsApplied(): Code[20]
    begin
        if IsReturnKey then
            exit('997280');
        exit(JobsDemoAccounts.GetAccount('997280'));
    end;

    procedure JobCostsAdjustment(): Code[20]
    begin
        if IsReturnKey then
            exit('997181');
        exit(JobsDemoAccounts.GetAccount('997181'));
    end;

    procedure GLExpense(): Code[20]
    begin
        if IsReturnKey then
            exit('996610');
        exit(JobsDemoAccounts.GetAccount('996610'));
    end;

    procedure WIPAccruedSales(): Code[20]
    begin
        if IsReturnKey then
            exit('992211');
        exit(JobsDemoAccounts.GetAccount('992211'));
    end;

    procedure WIPInvoicedSales(): Code[20]
    begin
        if IsReturnKey then
            exit('992212');
        exit(JobsDemoAccounts.GetAccount('992212'));
    end;

    procedure JobSalesApplied(): Code[20]
    begin
        if IsReturnKey then
            exit('996190');
        exit(JobsDemoAccounts.GetAccount('996190'));
    end;

    procedure JobSalesAdjustment(): Code[20]
    begin
        if IsReturnKey then
            exit('996191');
        exit(JobsDemoAccounts.GetAccount('996191'));
    end;

    procedure RecognizedCosts(): Code[20]
    begin
        if IsReturnKey then
            exit('997620');
        exit(JobsDemoAccounts.GetAccount('997620'));
    end;

    procedure RecognizedSales(): Code[20]
    begin
        if IsReturnKey then
            exit('996620');
        exit(JobsDemoAccounts.GetAccount('996620'));
    end;

}
