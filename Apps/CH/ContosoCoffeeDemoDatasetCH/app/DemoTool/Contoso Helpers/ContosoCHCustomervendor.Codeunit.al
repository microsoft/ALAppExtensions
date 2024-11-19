codeunit 11592 "Contoso CH Customer Vendor"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Customer Bank Account" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertCustomerBankAccount(CustomerNo: Code[20]; Code: Code[20]; Name: Text[100]; Address: Text[100]; City: Text[30]; PostCode: Code[20]; BankBranchNo: Code[5]; BankAccountNo: Text[30]; GiroAccountNo: Code[11])
    var
        CustomerBankAccount: Record "Customer Bank Account";
        Exists: Boolean;
    begin
        if CustomerBankAccount.Get(CustomerNo, Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CustomerBankAccount.Validate("Customer No.", CustomerNo);
        CustomerBankAccount.Validate(Code, Code);
        CustomerBankAccount.Validate(Name, Name);
        CustomerBankAccount.Validate(Address, Address);
        CustomerBankAccount.Validate("Post Code", PostCode);
        CustomerBankAccount.Validate(City, City);
        CustomerBankAccount."Bank Branch No." := BankBranchNo;
        CustomerBankAccount.Validate("Bank Account No.", BankAccountNo);
        CustomerBankAccount.Validate("Giro Account No.", GiroAccountNo);

        if Exists then
            CustomerBankAccount.Modify(true)
        else
            CustomerBankAccount.Insert(true);
    end;
}