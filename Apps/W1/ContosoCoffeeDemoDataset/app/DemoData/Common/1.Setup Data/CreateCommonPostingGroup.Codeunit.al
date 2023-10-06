codeunit 5134 "Create Common Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CommonGLAccount: Codeunit "Create Common GL Account";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::VAT then begin
            ContosoPostingGroup.InsertVATBusinessPostingGroup(Domestic(), DomesticCustomerVendorLbl);
            ContosoPostingGroup.InsertVATBusinessPostingGroup(EU(), EUCustomerVendorLbl);
            ContosoPostingGroup.InsertVATBusinessPostingGroup(Export(), ExportCustomerVendorLbl);

            ContosoPostingGroup.InsertVATProductPostingGroup(ZeroVAT(), ZeroVATDescriptionLbl);
            ContosoPostingGroup.InsertVATProductPostingGroup(ReducedVAT(), ReducedVATDescriptionLbl);
            ContosoPostingGroup.InsertVATProductPostingGroup(StandardVAT(), StandardVATDescriptionLbl);
        end else
            ContosoPostingGroup.InsertTaxGroup(NonTaxable(), NoTaxableLbl);

        ContosoPostingGroup.InsertGenBusinessPostingGroup(Domestic(), DomesticCustomerVendorLbl, Domestic());
        ContosoPostingGroup.InsertGenBusinessPostingGroup(EU(), EUCustomerVendorLbl, EU());
        ContosoPostingGroup.InsertGenBusinessPostingGroup(Export(), ExportCustomerVendorLbl, Export());

        ContosoPostingGroup.InsertGenProductPostingGroup(Retail(), RetailLbl, StandardVAT());
        ContosoPostingGroup.InsertGenProductPostingGroup(RawMaterial(), RawMaterialsLbl, StandardVAT());
        ContosoPostingGroup.InsertGenProductPostingGroup(Service(), ServiceLbl, StandardVAT());

        ContosoPostingGroup.InsertInventoryPostingGroup(Resale(), ResaleLbl);
        ContosoPostingGroup.InsertInventoryPostingGroup(RawMaterial(), RawMaterialsLbl);

        ContosoPostingGroup.InsertCustomerPostingGroup(Domestic(), DomesticCustomerVendorLbl, CommonGLAccount.CustomerDomestic());

        ContosoPostingGroup.InsertVendorPostingGroup(Domestic(), DomesticCustomerVendorLbl, CommonGLAccount.VendorDomestic());
    end;


    var
        DomesticTok: Label 'DOMESTIC', MaxLength = 20;
        EUTok: Label 'EU', MaxLength = 20;
        ExportTok: Label 'EXPORT', MaxLength = 20;
        DomesticCustomerVendorLbl: Label 'Domestic customers and vendors', MaxLength = 100;
        EUCustomerVendorLbl: Label 'Customers and vendors in EU', MaxLength = 100;
        ExportCustomerVendorLbl: Label 'Other customers and vendors (not EU)', MaxLength = 100;
        ZeroVATCodeLbl: Label 'No VAT', MaxLength = 20;
        ReducedVATCodeLbl: Label 'VAT Reduced', MaxLength = 20;
        StandardVATCodeLbl: Label 'VAT Standard', MaxLength = 20;
        ZeroVATDescriptionLbl: Label 'No VAT', MaxLength = 100;
        ReducedVATDescriptionLbl: Label 'Reduced VAT', MaxLength = 100;
        StandardVATDescriptionLbl: Label 'Standard VAT', MaxLength = 100;
        RetailTok: Label 'RETAIL', MaxLength = 20;
        RetailLbl: Label 'Retail';
        RawMaterialTok: Label 'RAW MAT', MaxLength = 20;
        RawMaterialsLbl: Label 'Raw Materials', MaxLength = 100;
        ServiceTok: Label 'SERVICES', MaxLength = 20;
        ServiceLbl: Label 'Services', MaxLength = 100;
        ResaleTok: Label 'RESALE', MaxLength = 20;
        ResaleLbl: Label 'Resale', MaxLength = 100;
        NoTaxableTok: Label 'NONTAXABLE', MaxLength = 20;
        NoTaxableLbl: Label 'Nontaxable', MaxLength = 100;

    procedure Service(): Code[20]
    begin
        exit(ServiceTok);
    end;

    procedure Resale(): Code[20]
    begin
        exit(ResaleTok);
    end;

    procedure RawMaterial(): Code[20]
    begin
        exit(RawMaterialTok);
    end;

    procedure Domestic(): Code[20]
    begin
        exit(DomesticTok);
    end;

    procedure EU(): Code[20]
    begin
        exit(EUTok);
    end;

    procedure Export(): Code[20]
    begin
        exit(ExportTok);
    end;

    procedure ZeroVAT(): Code[20]
    begin
        exit(ZeroVATCodeLbl);
    end;

    procedure ReducedVAT(): Code[20]
    begin
        exit(ReducedVATCodeLbl);
    end;

    procedure StandardVAT(): Code[20]
    begin
        exit(StandardVATCodeLbl);
    end;

    procedure Retail(): Code[20]
    begin
        exit(RetailTok);
    end;

    procedure NonTaxable(): Code[20]
    begin
        exit(NoTaxableTok);
    end;
}