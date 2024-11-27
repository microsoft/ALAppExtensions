codeunit 11213 "Create Posting Groups SE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertGenPostingGroup();
    end;

    local procedure InsertGenPostingGroup()
    var
        CreateVATPostingGroupsSE: Codeunit "Create VAT Posting Groups SE";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        ContosoPostingGroup.InsertGenProductPostingGroup(NoVatPostingGroup(), NoVatDescriptionLbl, CreateVATPostingGroupsSE.NoVat());
        ContosoPostingGroup.InsertGenProductPostingGroup(OnlyPostingGroup(), OnlyDescriptionLbl, CreateVATPostingGroupsSE.Only());

        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertGenProductPostingGroup(CreatePostingGroups.FreightPostingGroup(), FreightDescriptionLbl, CreateVATPostingGroupsSE.VAT25());
        ContosoPostingGroup.InsertGenProductPostingGroup(CreatePostingGroups.MiscPostingGroup(), MiscDescriptionLbl, CreateVATPostingGroupsSE.VAT25());
        ContosoPostingGroup.InsertGenProductPostingGroup(CreatePostingGroups.RawMatPostingGroup(), RawMatDescriptionLbl, CreateVATPostingGroupsSE.VAT25());
        ContosoPostingGroup.InsertGenProductPostingGroup(CreatePostingGroups.RetailPostingGroup(), RetailDescriptionLbl, CreateVATPostingGroupsSE.VAT25());
        ContosoPostingGroup.InsertGenProductPostingGroup(CreatePostingGroups.ServicesPostingGroup(), ServicesDescriptionLbl, CreateVATPostingGroupsSE.VAT12());
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    procedure UpdateGenPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateSEGLAccounts: Codeunit "Create SE GL Accounts";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', NoVatPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RetailPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), NoVatPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccount.SalesResourcesDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailEU(), CreateGLAccount.PurchRetailEU(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), NoVatPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccount.SalesResourcesExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateSEGLAccounts.Shipmentsnotinvoiced(), CreateSEGLAccounts.Receiptsnotinvoiced());
        ContosoGenPostingSetup.SetOverwriteData(false);
    end;

    procedure NoVatPostingGroup(): Code[20]
    begin
        exit(NoVatTok);
    end;

    procedure OnlyPostingGroup(): Code[20]
    begin
        exit(OnlyTok);
    end;

    var
        NoVatTok: Label 'NO VAT', Locked = true, MaxLength = 20;
        NoVatDescriptionLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
        OnlyTok: Label 'ONLY', Locked = true, MaxLength = 20;
        OnlyDescriptionLbl: Label 'Manually Posted VAT', MaxLength = 100;
        FreightDescriptionLbl: Label 'Freight, etc.', MaxLength = 100;
        MiscDescriptionLbl: Label 'Miscellaneous with VAT', MaxLength = 100;
        RawMatDescriptionLbl: Label 'Raw Materials', MaxLength = 100;
        RetailDescriptionLbl: Label 'Retail', MaxLength = 100;
        ServicesDescriptionLbl: Label 'Resources, etc.', MaxLength = 100;
}