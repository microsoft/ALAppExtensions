codeunit 10817 "Create ES Vendor Bank Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoVendorBankAccount: Codeunit "Contoso Vendor Bank Account";
        CreateVendor: Codeunit "Create Vendor";
    begin
        ContosoVendorBankAccount.SetOverwriteData(true);
        ContosoVendorBankAccount.InsertVendorBankAccount(CreateVendor.DomesticWorldImporter(), BEE(), BancoExteriorEspanaLbl, AlamedaRecaldeLbl, FernandoBarrioLbl, '93-2 33 41 45', '', '', '', '', '');
        ContosoVendorBankAccount.SetOverwriteData(false);
        UpdateVendorCounty(CreateVendor.DomesticWorldImporter(), BEE(), BankCountyLbl)
    end;

    local procedure UpdateVendorCounty(VendorNo: Code[20]; BankCode: Code[20]; BankCounty: Text[30])
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        if not VendorBankAccount.Get(VendorNo, BankCode) then
            exit;

        VendorBankAccount.Validate(County, BankCounty);
        VendorBankAccount.Modify(true);
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