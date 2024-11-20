codeunit 5319 "Create Vendor Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoVendorTempl: Codeunit "Contoso Vendor Templ";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateVatPostingGroup: Codeunit "Create VAT Posting Groups";
        CreateVendorPostingGroup: Codeunit "Create Vendor Posting Group";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreatePaymentMethod: Codeunit "Create Payment Method";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        ContosoVendorTempl.InsertVendorTempl(VendorCompany(), B2BVendorLbl, CreateVendorPostingGroup.Domestic(), CreatePaymentTerms.PaymentTermsM8D(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreatePaymentMethod.Bank(), false, CreatePostingGroups.DomesticPostingGroup(), CreateVatPostingGroup.Domestic(), false, Enum::"Contact Type"::Company);
        ContosoVendorTempl.InsertVendorTempl(VendorEUCompany(), EUVendorLbl, CreateVendorPostingGroup.EU(), CreatePaymentTerms.PaymentTermsDAYS14(), '', CreatePaymentMethod.Bank(), false, CreatePostingGroups.EUPostingGroup(), CreateVatPostingGroup.EU(), true, Enum::"Contact Type"::Company);
        ContosoVendorTempl.InsertVendorTempl(VendorPerson(), CashPaymentLbl, CreateVendorPostingGroup.Domestic(), CreatePaymentTerms.PaymentTermsCOD(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreatePaymentMethod.Cash(), true, CreatePostingGroups.DomesticPostingGroup(), CreateVatPostingGroup.Domestic(), false, Enum::"Contact Type"::Person);
    end;

    procedure VendorCompany(): code[20]
    begin
        exit(VendorCompanyTok);
    end;

    procedure VendorEUCompany(): code[20]
    begin
        exit(VendorEUCompanyTok);
    end;

    procedure VendorPerson(): code[20]
    begin
        exit(VendorPersonTok);
    end;

    var
        VendorCompanyTok: Label 'VENDOR COMPANY', MaxLength = 20;
        VendorEUCompanyTok: Label 'VENDOR EU COMPANY', MaxLength = 20;
        VendorPersonTok: Label 'VENDOR PERSON', MaxLength = 20;
        B2BVendorLbl: Label 'Business-to-Business Vendor (Bank)', MaxLength = 100;
        EUVendorLbl: Label 'EU Vendor (Bank)', MaxLength = 100;
        CashPaymentLbl: Label 'Cash-Payment Vendor (Cash)', MaxLength = 100;
}