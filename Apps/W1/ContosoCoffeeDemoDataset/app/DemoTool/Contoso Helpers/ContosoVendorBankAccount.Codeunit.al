codeunit 5660 "Contoso Vendor Bank Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Vendor Bank Account" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertVendorBankAccount(VendorNo: Code[20]; Code: Code[20]; Name: Text[100]; Address: Text[100]; Contact: Text[100]; PhoneNo: Text[30]; BankBranchNo: Text[20]; BankAccountNo: Text[30]; FaxNo: Text[30]; LanguageCode: Code[10]; IBAN: Code[50])
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
        VendorBankAccount.Validate(Name, Name);
        VendorBankAccount.Validate(Address, Address);
        VendorBankAccount.Validate(Contact, Contact);
        VendorBankAccount.Validate("Phone No.", PhoneNo);
        VendorBankAccount.Validate("Bank Branch No.", BankBranchNo);
        VendorBankAccount."Bank Account No." := BankAccountNo;
        VendorBankAccount.Validate("Fax No.", FaxNo);
        VendorBankAccount.Validate("Language Code", LanguageCode);
        VendorBankAccount.Validate(IBAN, IBAN);

        if Exists then
            VendorBankAccount.Modify(true)
        else
            VendorBankAccount.Insert(true);
    end;
}
