codeunit 5135 "Create Common GL Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        GLAccountIndent: Codeunit "G/L Account-Indent";
    begin
        AddGLAccountsForLocalization();

        ContosoGLAccount.InsertGLAccount(CustomerDomestic(), CustomerDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(VendorDomestic(), VendorDomesticName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(RawMaterials(), RawMaterialsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(DirectCostAppliedRetail(), DirectCostAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(OverheadAppliedRetail(), OverheadAppliedRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(PurchaseVarianceRetail(), PurchaseVarianceRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(DirectCostAppliedRawMat(), DirectCostAppliedRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(OverheadAppliedRawMat(), OverheadAppliedRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(PurchaseVarianceRawMat(), PurchaseVarianceRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(PurchRawMatDom(), PurchRawMatDomName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(InventoryAdjRawMat(), InventoryAdjRawMatName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(InventoryAdjRetail(), InventoryAdjRetailName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(SalesDomestic(), SalesDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(PurchaseDomestic(), PurchaseDomesticName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(SalesVATStandard(), SalesVATStandardName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(PurchaseVATStandard(), PurchaseVATStandardName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(Resale(), ResalesName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(ResaleInterim(), ResaleInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);

        GLAccountIndent.Indent();
    end;

    local procedure AddGLAccountsForLocalization()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();

        ContosoGLAccount.AddAccountForLocalization(CustomerDomesticName(), '2310');
        ContosoGLAccount.AddAccountForLocalization(VendorDomesticName(), '5410');

        ContosoGLAccount.AddAccountForLocalization(RawMaterialsName(), '2130');

        ContosoGLAccount.AddAccountForLocalization(DirectCostAppliedRetailName(), '7191');
        ContosoGLAccount.AddAccountForLocalization(OverheadAppliedRetailName(), '7192');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVarianceRetailName(), '7193');

        ContosoGLAccount.AddAccountForLocalization(DirectCostAppliedRawMatName(), '7291');
        ContosoGLAccount.AddAccountForLocalization(OverheadAppliedRawMatName(), '7292');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVarianceRawMatName(), '7293');
        ContosoGLAccount.AddAccountForLocalization(PurchRawMatDomName(), '7210');

        ContosoGLAccount.AddAccountForLocalization(InventoryAdjRawMatName(), '7270');
        ContosoGLAccount.AddAccountForLocalization(InventoryAdjRetailName(), '7170');

        ContosoGLAccount.AddAccountForLocalization(SalesDomesticName(), '6110');
        ContosoGLAccount.AddAccountForLocalization(PurchaseDomesticName(), '7110');

        ContosoGLAccount.AddAccountForLocalization(SalesVATStandardName(), '5610');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVATStandardName(), '5630');

        ContosoGLAccount.AddAccountForLocalization(ResalesName(), '2110');

        if InventorySetup."Expected Cost Posting to G/L" then
            ContosoGLAccount.AddAccountForLocalization(ResaleInterimName(), '2111')
        else
            ContosoGLAccount.AddAccountForLocalization(ResaleInterimName(), '');

        OnAfterAddGLAccountsForLocalization();
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        CustomerDomesticLbl: Label 'Customers Domestic', MaxLength = 100;
        VendorDomesticLbl: Label 'Vendors Domestic', MaxLength = 100;
        RawMaterialsLbl: Label 'Raw Materials', MaxLength = 100;
        OverheadAppliedRetailLbl: Label 'Overhead Applied, Retail', MaxLength = 100;
        PurchaseVarianceRetailLbl: Label 'Purchase Variance, Retail', MaxLength = 100;
        DirectCostAppliedRawMatLbl: Label 'Direct Cost Applied, Raw Materials', MaxLength = 100;
        DirectCostAppliedRetailLbl: Label 'Direct Cost Applied, Retail', MaxLength = 100;
        OverheadAppliedRawMatLbl: Label 'Overhead Applied, Raw Materials', MaxLength = 100;
        PurchaseVarianceRawMatLbl: Label 'Overhead Applied, Raw Materials', MaxLength = 100;
        PurchRawMatDomLbl: Label 'Purchase, Raw Materials - Domestic', MaxLength = 100;
        InventoryAdjRawMatLbl: Label 'Inventory Adjustment, Raw Materials', MaxLength = 100;
        InventoryAdjRetailLbl: Label 'Inventory Adjustment, Retail', MaxLength = 100;
        SalesDomesticLbl: Label 'Sales, Retail - Domestic', MaxLength = 100;
        PurchaseDomesticLbl: Label 'Purch., Retail - Domestic', MaxLength = 100;
        SalesVATLbl: Label 'Sales VAT Standard', MaxLength = 100;
        PurchaseVATLbl: Label 'Purchase VAT Standard', MaxLength = 100;
        ResaleLbl: Label 'Resale', MaxLength = 100;
        ResaleInterimLbl: Label 'Resale (Interim)', MaxLength = 100;

    procedure CustomerDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomerDomesticName()));
    end;

    procedure CustomerDomesticName(): Text[100]
    begin
        exit(CustomerDomesticLbl);
    end;

    procedure VendorDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(VendorDomesticName()));
    end;

    procedure VendorDomesticName(): Text[100]
    begin
        exit(VendorDomesticLbl);
    end;

    procedure RawMaterials(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(RawMaterialsName()));
    end;

    procedure RawMaterialsName(): Text[100]
    begin
        exit(RawMaterialsLbl);
    end;

    procedure DirectCostAppliedRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DirectCostAppliedRetailName()));
    end;

    procedure DirectCostAppliedRetailName(): Text[100]
    begin
        exit(DirectCostAppliedRetailLbl);
    end;

    procedure OverheadAppliedRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OverheadAppliedRetailName()));
    end;

    procedure OverheadAppliedRetailName(): Text[100]
    begin
        exit(OverheadAppliedRetailLbl);
    end;

    procedure PurchaseVarianceRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVarianceRetailName()));
    end;

    procedure PurchaseVarianceRetailName(): Text[100]
    begin
        exit(PurchaseVarianceRetailLbl);
    end;

    procedure DirectCostAppliedRawMat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DirectCostAppliedRawMatName()));
    end;

    procedure DirectCostAppliedRawMatName(): Text[100]
    begin
        exit(DirectCostAppliedRawMatLbl);
    end;

    procedure OverheadAppliedRawMat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OverheadAppliedRawMatName()));
    end;

    procedure OverheadAppliedRawMatName(): Text[100]
    begin
        exit(OverheadAppliedRawMatLbl);
    end;

    procedure PurchaseVarianceRawMat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVarianceRawMatName()));
    end;

    procedure PurchaseVarianceRawMatName(): Text[100]
    begin
        exit(PurchaseVarianceRawMatLbl);
    end;

    procedure PurchRawMatDom(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchRawMatDomName()));
    end;

    procedure PurchRawMatDomName(): Text[100]
    begin
        exit(PurchRawMatDomLbl);
    end;

    procedure InventoryAdjRawMat(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryAdjRawMatName()));
    end;

    procedure InventoryAdjRawMatName(): Text[100]
    begin
        exit(InventoryAdjRawMatLbl);
    end;

    procedure InventoryAdjRetail(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InventoryAdjRetailName()));
    end;

    procedure InventoryAdjRetailName(): Text[100]
    begin
        exit(InventoryAdjRetailLbl);
    end;

    procedure SalesDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesDomesticName()));
    end;

    procedure SalesDomesticName(): Text[100]
    begin
        exit(SalesDomesticLbl);
    end;

    procedure PurchaseDomestic(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseDomesticName()));
    end;

    procedure PurchaseDomesticName(): Text[100]
    begin
        exit(PurchaseDomesticLbl);
    end;

    procedure SalesVATStandard(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SalesVATStandardName()));
    end;

    procedure SalesVATStandardName(): Text[100]
    begin
        exit(SalesVATLbl);
    end;

    procedure PurchaseVATStandard(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVATStandardName()));
    end;

    procedure PurchaseVATStandardName(): Text[100]
    begin
        exit(PurchaseVATLbl);
    end;

    procedure Resale(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResalesName()));
    end;

    procedure ResalesName(): Text[100]
    begin
        exit(ResaleLbl);
    end;

    procedure ResaleInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ResaleInterimName()));
    end;

    procedure ResaleInterimName(): Text[100]
    begin
        exit(ResaleInterimLbl);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddGLAccountsForLocalization()
    begin
    end;
}