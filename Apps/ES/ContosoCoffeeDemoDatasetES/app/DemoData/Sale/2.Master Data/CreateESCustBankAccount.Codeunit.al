codeunit 10820 "Create ES Cust Bank Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCustomerVendor: Codeunit "Contoso Customer/Vendor";
        CreateCustomer: Codeunit "Create Customer";
    begin
        ContosoCustomerVendor.SetOverwriteData(true);
        ContosoCustomerVendor.InsertCustomerBankAccount(CreateCustomer.EUAlpineSkiHouse(), BEE(), BancoExteriorEspanaLbl, AlamedaRecaldeLbl, FernandoBarrioLbl, '93-2 33 41 45', '', '', '', '', '');
        UpdateCustomerCounty(CreateCustomer.EUAlpineSkiHouse(), BEE(), BankCountyLbl);
        ContosoCustomerVendor.SetOverwriteData(false);
    end;

    local procedure UpdateCustomerCounty(CustomerNo: Code[20]; BankCode: Code[20]; BankCounty: Text[30])
    var
        CustomerBankAccount: Record "Customer Bank Account";
    begin
        if not CustomerBankAccount.Get(CustomerNo, BankCode) then
            exit;

        CustomerBankAccount.Validate(County, BankCounty);
        CustomerBankAccount.Modify(true);
    end;

    procedure BEE(): Code[20]
    begin
        exit(BEETok);
    end;

    var
        BEETok: Label 'BEE', MaxLength = 20;
        BancoExteriorEspanaLbl: Label 'Banco Exterior España', MaxLength = 100;
        AlamedaRecaldeLbl: Label 'Alameda Recalde 25', MaxLength = 100;
        FernandoBarrioLbl: Label 'Fernando Barrio', MaxLength = 100;
        BankCountyLbl: Label 'Barcelona', MaxLength = 30;
}