codeunit 5562 "Create Customer Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoCustomerVendor: Codeunit "Contoso Customer/Vendor";
        CreateCustomerPostingGroup: Codeunit "Create Customer Posting Group";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreatePaymentMethod: Codeunit "Create Payment Method";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        ContosoCustomerVendor.InsertCustomerTempl(CustomerCompany(), B2BCustomerLbl, CreateCustomerPostingGroup.Domestic(), CreatePaymentTerms.PaymentTermsM8D(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreatePaymentMethod.Bank(), false, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), Enum::"Contact Type"::Company, true, false);
        ContosoCustomerVendor.InsertCustomerTempl(CustomerEUCompany(), EUCustomerLbl, CreateCustomerPostingGroup.EU(), CreatePaymentTerms.PaymentTermsDAYS14(), '', CreatePaymentMethod.Bank(), false, CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.EUPostingGroup(), Enum::"Contact Type"::Company, true, true);
        ContosoCustomerVendor.InsertCustomerTempl(CustomerPerson(), CashPaymentLbl, CreateCustomerPostingGroup.Domestic(), CreatePaymentTerms.PaymentTermsCOD(), ContosoCoffeeDemoDataSetup."Country/Region Code", CreatePaymentMethod.Cash(), true, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), Enum::"Contact Type"::Person, true, false);
    end;

    procedure CustomerCompany(): Code[20]
    begin
        exit(CustomerCompanyTok);
    end;

    procedure CustomerEUCompany(): Code[20]
    begin
        exit(CustomerEUCompanyTok);
    end;

    procedure CustomerPerson(): Code[20]
    begin
        exit(CustomerPersonTok);
    end;

    var
        CustomerCompanyTok: Label 'CUSTOMER COMPANY', MaxLength = 20;
        CustomerEUCompanyTok: Label 'CUSTOMER EU COMPANY', MaxLength = 20;
        CustomerPersonTok: Label 'CUSTOMER PERSON', MaxLength = 20;
        B2BCustomerLbl: Label 'Business-to-Business Customer (Bank)', MaxLength = 100;
        EUCustomerLbl: Label 'EU Customer (Bank)', MaxLength = 100;
        CashPaymentLbl: Label 'Cash-Payment Customer (Cash)', MaxLength = 100;
}