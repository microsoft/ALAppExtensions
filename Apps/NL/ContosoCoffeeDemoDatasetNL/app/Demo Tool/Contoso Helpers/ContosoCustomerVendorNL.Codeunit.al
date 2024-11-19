codeunit 11526 "Contoso Customer/Vendor NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
            tabledata "Customer Bank Account" = rim,
            tabledata "Vendor Bank Account" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertCustomerBankAccount(CustomerNo: Code[20]; Code: Code[20]; BankAccountNo: Text[30]; AccountHolderName: Text[100]; AccountHolderAddress: Text[100]; AccountHolderCity: Text[30]; AccountHolderPostCode: Code[20])
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
        CustomerBankAccount.Validate("Bank Account No.", BankAccountNo);
        CustomerBankAccount.Validate("Account Holder Name", AccountHolderName);
        CustomerBankAccount.Validate("Account Holder Address", AccountHolderAddress);
        CustomerBankAccount.Validate("Account Holder City", AccountHolderCity);
        CustomerBankAccount.Validate("Account Holder Post Code", AccountHolderPostCode);

        if Exists then
            CustomerBankAccount.Modify(true)
        else
            CustomerBankAccount.Insert(true);
    end;

    procedure InsertVendorBankAccount(VendorNo: Code[20]; Code: Code[20]; BankAccountNo: Text[30]; AccountHolderName: Text[100]; AccountHolderAddress: Text[100]; AccountHolderCity: Text[30]; AccountHolderPostCode: Code[20])
    var
        VendorBankAccount: Record "Vendor Bank Account";
        Exists: Boolean;
    begin
        if VendorBankAccount.Get(VendorNo, Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VendorBankAccount.Validate("Vendor No.", VendorNo);
        VendorBankAccount.Validate(Code, Code);
        VendorBankAccount.Validate("Bank Account No.", BankAccountNo);
        VendorBankAccount.Validate("Account Holder Name", AccountHolderName);
        VendorBankAccount.Validate("Account Holder Address", AccountHolderAddress);
        VendorBankAccount.Validate("Account Holder City", AccountHolderCity);
        VendorBankAccount.Validate("Account Holder Post Code", AccountHolderPostCode);

        if Exists then
            VendorBankAccount.Modify(true)
        else
            VendorBankAccount.Insert(true);
    end;
}