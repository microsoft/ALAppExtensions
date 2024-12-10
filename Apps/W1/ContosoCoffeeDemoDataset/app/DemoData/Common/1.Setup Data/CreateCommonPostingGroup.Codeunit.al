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

        if ContosoCoffeeDemoDataSetup."Company Type" <> ContosoCoffeeDemoDataSetup."Company Type"::VAT then
            ContosoPostingGroup.InsertTaxGroup(NonTaxable(), NoTaxableLbl);

        ContosoPostingGroup.InsertInventoryPostingGroup(Resale(), ResaleLbl);
        ContosoPostingGroup.InsertInventoryPostingGroup(RawMaterial(), RawMaterialsLbl);

        ContosoPostingGroup.InsertCustomerPostingGroup(Domestic(), DomesticCustomerVendorLbl, CommonGLAccount.CustomerDomestic());

        ContosoPostingGroup.InsertVendorPostingGroup(Domestic(), DomesticCustomerVendorLbl, CommonGLAccount.VendorDomestic());
    end;


    var
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateVATPostingGroup: Codeunit "Create VAT Posting Groups";
        DomesticCustomerVendorLbl: Label 'Domestic customers and vendors', MaxLength = 100;
        RawMaterialsLbl: Label 'Raw Materials', MaxLength = 100;
        ResaleLbl: Label 'Resale', MaxLength = 100;
        NoTaxableTok: Label 'NONTAXABLE', MaxLength = 20;
        NoTaxableLbl: Label 'Nontaxable', MaxLength = 100;

    procedure Service(): Code[20]
    begin
        exit(CreatePostingGroup.ServicesPostingGroup());
    end;

    procedure Resale(): Code[20]
    var
        CreateInventoryPostingGroup: Codeunit "Create Inventory Posting Group";
    begin
        exit(CreateInventoryPostingGroup.Resale());
    end;

    procedure RawMaterial(): Code[20]
    begin
        exit(CreatePostingGroup.RawMatPostingGroup());
    end;

    procedure Domestic(): Code[20]
    begin
        exit(CreatePostingGroup.DomesticPostingGroup());
    end;

    procedure EU(): Code[20]
    begin
        exit(CreatePostingGroup.EUPostingGroup());
    end;

    procedure Export(): Code[20]
    begin
        exit(CreatePostingGroup.ExportPostingGroup());
    end;

    procedure ZeroVAT(): Code[20]
    begin
        exit(CreateVATPostingGroup.Zero());
    end;

    procedure ReducedVAT(): Code[20]
    begin
        exit(CreateVATPostingGroup.Reduced());
    end;

    procedure StandardVAT(): Code[20]
    begin
        exit(CreateVATPostingGroup.Standard());
    end;

    procedure Retail(): Code[20]
    begin
        exit(CreatePostingGroup.RetailPostingGroup());
    end;

    procedure NonTaxable(): Code[20]
    begin
        exit(NoTaxableTok);
    end;
}