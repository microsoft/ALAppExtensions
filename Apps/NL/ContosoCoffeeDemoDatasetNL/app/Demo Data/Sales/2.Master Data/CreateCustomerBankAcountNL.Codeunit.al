codeunit 11523 "Create Customer Bank Acount NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    var
        Customer: Record Customer;
        CreateCustomer: Codeunit "Create Customer";
        ContosoCustomerVendorNL: Codeunit "Contoso Customer/Vendor NL";
        CreateBankAccountNL: Codeunit "Create Bank Account NL";
    begin
        Customer.Get(CreateCustomer.DomesticAdatumCorporation());
        ContosoCustomerVendorNL.InsertCustomerBankAccount(Customer."No.", CreateBankAccountNL.POSTBANK(), DomesticAdatumCorporationBankAccountNoLbl, Customer.Name, Customer.Address, Customer.City, Customer."Post Code");

        Customer.Get(CreateCustomer.DomesticTreyResearch());
        ContosoCustomerVendorNL.InsertCustomerBankAccount(Customer."No.", CreateBankAccountNL.POSTBANK(), DomesticTreyResearchBankAccountNoLbl, Customer.Name, Customer.Address, Customer.City, Customer."Post Code");

        Customer.Get(CreateCustomer.ExportSchoolofArt());
        ContosoCustomerVendorNL.InsertCustomerBankAccount(Customer."No.", CreateBankAccountNL.POSTBANK(), ExportSchoolofArtBankAccountNoLbl, Customer.Name, Customer.Address, Customer.City, Customer."Post Code");

        Customer.Get(CreateCustomer.EUAlpineSkiHouse());
        ContosoCustomerVendorNL.InsertCustomerBankAccount(Customer."No.", CreateBankAccountNL.POSTBANK(), EUAlpineSkiHouseBankAccountNoLbl, Customer.Name, Customer.Address, Customer.City, Customer."Post Code");
    end;

    var
        DomesticAdatumCorporationBankAccountNoLbl: Label 'P1234567', MaxLength = 30;
        DomesticTreyResearchBankAccountNoLbl: Label 'P2234567', MaxLength = 30;
        ExportSchoolofArtBankAccountNoLbl: Label 'P3234567', MaxLength = 30;
        EUAlpineSkiHouseBankAccountNoLbl: Label 'P4234567', MaxLength = 30;
}