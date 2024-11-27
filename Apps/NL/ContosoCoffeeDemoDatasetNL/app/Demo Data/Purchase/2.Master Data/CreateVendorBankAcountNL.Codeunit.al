codeunit 11524 "Create Vendor Bank Acount NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        Vendor: Record Vendor;
        CreateVendor: Codeunit "Create Vendor";
        ContosoCustomerVendorNL: Codeunit "Contoso Customer/Vendor NL";
        CreateBankAccountNL: Codeunit "Create Bank Account NL";
    begin
        Vendor.Get(CreateVendor.ExportFabrikam());
        ContosoCustomerVendorNL.InsertVendorBankAccount(Vendor."No.", CreateBankAccountNL.POSTBANK(), ExportFabrikamBankAccountNoLbl, Vendor.Name, Vendor.Address, Vendor.City, Vendor."Post Code");

        Vendor.Get(CreateVendor.DomesticFirstUp());
        ContosoCustomerVendorNL.InsertVendorBankAccount(Vendor."No.", CreateBankAccountNL.POSTBANK(), DomesticFirstUpBankAccountNoLbl, Vendor.Name, Vendor.Address, Vendor.City, Vendor."Post Code");

        Vendor.Get(CreateVendor.EUGraphicDesign());
        ContosoCustomerVendorNL.InsertVendorBankAccount(Vendor."No.", CreateBankAccountNL.POSTBANK(), EUGraphicDesignBankAccountNoLbl, Vendor.Name, Vendor.Address, Vendor.City, Vendor."Post Code");

        Vendor.Get(CreateVendor.DomesticWorldImporter());
        ContosoCustomerVendorNL.InsertVendorBankAccount(Vendor."No.", CreateBankAccountNL.POSTBANK(), DomesticWorldImporterBankAccountNoLbl, Vendor.Name, Vendor.Address, Vendor.City, Vendor."Post Code");
    end;

    var
        ExportFabrikamBankAccountNoLbl: Label 'P5234567', MaxLength = 30;
        DomesticFirstUpBankAccountNoLbl: Label 'P6234567', MaxLength = 30;
        EUGraphicDesignBankAccountNoLbl: Label 'P7234567', MaxLength = 30;
        DomesticWorldImporterBankAccountNoLbl: Label 'P8234567', MaxLength = 30;
}