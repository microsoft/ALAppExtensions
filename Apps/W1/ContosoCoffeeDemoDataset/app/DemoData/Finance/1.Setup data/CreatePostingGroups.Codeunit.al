codeunit 5252 "Create Posting Groups"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
    begin
        InsertGenPostingGroup();
        InsertGenBusinessPostingGroup();
        InsertGenPostingSetupWithoutGLAccounts();
    end;

    local procedure InsertGenPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        ContosoPostingGroup.InsertGenProductPostingGroup(FreightPostingGroup(), FreightDescriptionLbl, CreateVATPostingGroups.Standard());
        ContosoPostingGroup.InsertGenProductPostingGroup(MiscPostingGroup(), MiscDescriptionLbl, CreateVATPostingGroups.Standard());
        ContosoPostingGroup.InsertGenProductPostingGroup(RawMatPostingGroup(), RawMatDescriptionLbl, CreateVATPostingGroups.Standard());
        ContosoPostingGroup.InsertGenProductPostingGroup(RetailPostingGroup(), RetailDescriptionLbl, CreateVATPostingGroups.Standard());
        ContosoPostingGroup.InsertGenProductPostingGroup(ServicesPostingGroup(), ServicesDescriptionLbl, CreateVATPostingGroups.Reduced());
        ContosoPostingGroup.InsertGenProductPostingGroup(ZeroPostingGroup(), ZeroDescriptionLbl, CreateVATPostingGroups.Zero());
    end;

    local procedure InsertGenBusinessPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertGenBusinessPostingGroup(DomesticPostingGroup(), DomesticPostingGroupDescriptionLbl, DomesticPostingGroup());
        ContosoPostingGroup.InsertGenBusinessPostingGroup(EUPostingGroup(), EUPostingGroupDescriptionLbl, EUPostingGroup());
        ContosoPostingGroup.InsertGenBusinessPostingGroup(ExportPostingGroup(), ExportPostingGroupDescriptionLbl, ExportPostingGroup());
    end;

    local procedure InsertGenPostingSetupWithoutGLAccounts()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
    begin
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', RetailPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', ZeroPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(DomesticPostingGroup(), RetailPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(DomesticPostingGroup(), ServicesPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(DomesticPostingGroup(), ZeroPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(EUPostingGroup(), RetailPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(ExportPostingGroup(), RetailPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(ExportPostingGroup(), ServicesPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(ExportPostingGroup(), ZeroPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
    end;

    procedure UpdateGenPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', RetailPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', ZeroPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(DomesticPostingGroup(), RetailPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(DomesticPostingGroup(), ServicesPostingGroup(), CreateGLAccount.SalesResourcesDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(DomesticPostingGroup(), ZeroPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(EUPostingGroup(), RetailPostingGroup(), CreateGLAccount.SalesRetailEU(), CreateGLAccount.PurchRetailEU(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(ExportPostingGroup(), RetailPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(ExportPostingGroup(), ServicesPostingGroup(), CreateGLAccount.SalesResourcesExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(ExportPostingGroup(), ZeroPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.SetOverwriteData(false);
    end;

    procedure DomesticPostingGroup(): Code[20]
    begin
        exit(DomesticTok);
    end;

    procedure EUPostingGroup(): Code[20]
    begin
        exit(EUTok);
    end;

    procedure ExportPostingGroup(): Code[20]
    begin
        exit(ExportTok);
    end;

    procedure FreightPostingGroup(): Code[20]
    begin
        exit(FreightTok);
    end;

    procedure MiscPostingGroup(): Code[20]
    begin
        exit(MiscTok);
    end;

    procedure RawMatPostingGroup(): Code[20]
    begin
        exit(RawMatTok);
    end;

    procedure RetailPostingGroup(): Code[20]
    begin
        exit(RetailTok);
    end;

    procedure ServicesPostingGroup(): Code[20]
    begin
        exit(ServicesTok);
    end;

    procedure ZeroPostingGroup(): Code[20]
    begin
        exit(ZeroTok);
    end;

    var
        DomesticTok: Label 'DOMESTIC', MaxLength = 20;
        EUTok: Label 'EU', MaxLength = 20;
        ExportTok: Label 'EXPORT', MaxLength = 20;
        DomesticPostingGroupDescriptionLbl: Label 'Domestic customers and vendors', MaxLength = 100;
        EUPostingGroupDescriptionLbl: Label 'Customers and vendors in EU', MaxLength = 100;
        ExportPostingGroupDescriptionLbl: Label 'Other customers and vendors (not EU)', MaxLength = 100;
        FreightTok: Label 'FREIGHT', MaxLength = 20;
        MiscTok: Label 'MISC', MaxLength = 20;
        RawMatTok: Label 'RAW MAT', MaxLength = 20;
        RetailTok: Label 'RETAIL', MaxLength = 20;
        ServicesTok: Label 'SERVICES', MaxLength = 20;
        ZeroTok: Label 'ZERO', MaxLength = 20;
        FreightDescriptionLbl: Label 'Freight, etc.', MaxLength = 100;
        MiscDescriptionLbl: Label 'Miscellaneous with VAT', MaxLength = 100;
        RawMatDescriptionLbl: Label 'Raw Materials', MaxLength = 100;
        RetailDescriptionLbl: Label 'Retail', MaxLength = 100;
        ServicesDescriptionLbl: Label 'Resources, etc.', MaxLength = 100;
        ZeroDescriptionLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
}