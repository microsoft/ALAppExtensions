codeunit 27028 "Create CA Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertGenBusinessPostingGroup();
        InsertGenPostingGroup();
    end;

    procedure UpdateGenPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateCAGLAccounts: Codeunit "Create CA GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', Manufact(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateCAGLAccounts.DirectCostAppliedRetail(), CreateCAGLAccounts.OverheadAppliedRetail(), CreateCAGLAccounts.PurchaseVarianceRetail(), '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', RawMat(), '', '', CreateGLAccount.InventoryAdjmtRawMat(), CreateCAGLAccounts.DirectCostAppliedRawmat(), CreateCAGLAccounts.OverheadAppliedRawmat(), CreateCAGLAccounts.PurchaseVarianceRawmat(), '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofRawMatSoldInterim(), CreateGLAccount.InvAdjmtInterimRawMat());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RetailPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateCAGLAccounts.DirectCostAppliedRetail(), CreateCAGLAccounts.OverheadAppliedRetail(), CreateCAGLAccounts.PurchaseVarianceRetail(), '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.ServicesPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateCAGLAccounts.DirectCostAppliedRetail(), CreateCAGLAccounts.OverheadAppliedRetail(), CreateCAGLAccounts.PurchaseVarianceRetail(), '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.ZeroPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateCAGLAccounts.DirectCostAppliedRetail(), CreateCAGLAccounts.OverheadAppliedRetail(), CreateCAGLAccounts.PurchaseVarianceRetail(), '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), Manufact(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateCAGLAccounts.DirectCostAppliedRetail(), CreateCAGLAccounts.OverheadAppliedRetail(), CreateCAGLAccounts.PurchaseVarianceRetail(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), RawMat(), CreateGLAccount.SalesRawMaterialsDom(), CreateGLAccount.PurchRawMaterialsDom(), CreateGLAccount.InventoryAdjmtRawMat(), CreateCAGLAccounts.DirectCostAppliedRawmat(), CreateCAGLAccounts.OverheadAppliedRawmat(), CreateCAGLAccounts.PurchaseVarianceRawmat(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRawMaterials(), CreateGLAccount.DiscReceivedRawMaterials(), CreateGLAccount.CostofRawMaterialsSold(), CreateGLAccount.CostofRawMatSoldInterim(), CreateGLAccount.InvAdjmtInterimRawMat());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateCAGLAccounts.DirectCostAppliedRetail(), CreateCAGLAccounts.OverheadAppliedRetail(), CreateCAGLAccounts.PurchaseVarianceRetail(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccount.SalesResourcesDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateCAGLAccounts.DirectCostAppliedRetail(), CreateCAGLAccounts.OverheadAppliedRetail(), CreateCAGLAccounts.PurchaseVarianceRetail(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateCAGLAccounts.DirectCostAppliedRetail(), CreateCAGLAccounts.OverheadAppliedRetail(), CreateCAGLAccounts.PurchaseVarianceRetail(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), Manufact(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateCAGLAccounts.DirectCostAppliedRetail(), CreateCAGLAccounts.OverheadAppliedRetail(), CreateCAGLAccounts.PurchaseVarianceRetail(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), RawMat(), CreateGLAccount.SalesRawMaterialsExport(), CreateGLAccount.PurchRawMaterialsExport(), CreateGLAccount.InventoryAdjmtRawMat(), CreateCAGLAccounts.DirectCostAppliedRawmat(), CreateCAGLAccounts.OverheadAppliedRawmat(), CreateCAGLAccounts.PurchaseVarianceRawmat(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRawMaterials(), CreateGLAccount.DiscReceivedRawMaterials(), CreateGLAccount.CostofRawMaterialsSold(), CreateGLAccount.CostofRawMatSoldInterim(), CreateGLAccount.InvAdjmtInterimRawMat());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateCAGLAccounts.DirectCostAppliedRetail(), CreateCAGLAccounts.OverheadAppliedRetail(), CreateCAGLAccounts.PurchaseVarianceRetail(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccount.SalesResourcesExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateCAGLAccounts.DirectCostAppliedRetail(), CreateCAGLAccounts.OverheadAppliedRetail(), CreateCAGLAccounts.PurchaseVarianceRetail(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateCAGLAccounts.DirectCostAppliedRetail(), CreateCAGLAccounts.OverheadAppliedRetail(), CreateCAGLAccounts.PurchaseVarianceRetail(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.SetOverwriteData(false);

        UpdateSalesAndPurchasePrepaymentAccount(CreatePostingGroups.DomesticPostingGroup(), Manufact(), CreateCAGLAccounts.CustomerPrepaymentsRetail(), CreateCAGLAccounts.VendorPrepaymentsRetail());
        UpdateSalesAndPurchasePrepaymentAccount(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateCAGLAccounts.CustomerPrepaymentsRetail(), CreateCAGLAccounts.VendorPrepaymentsRetail());
        UpdateSalesAndPurchasePrepaymentAccount(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateCAGLAccounts.CustomerPrepaymentsServices(), CreateCAGLAccounts.VendorPrepaymentsServices());
        UpdateSalesAndPurchasePrepaymentAccount(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), CreateCAGLAccounts.CustomerPrepaymentsRetail(), CreateCAGLAccounts.VendorPrepaymentsRetail());
    end;

    local procedure InsertGenBusinessPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertGenBusinessPostingGroup(IntercompanyPostingGroup(), IntercompanyLbl, '');
    end;

    local procedure InsertGenPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertGenProductPostingGroup(Manufact(), CapacitiesLbl, '');
    end;

    local procedure UpdateSalesAndPurchasePrepaymentAccount(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; SalesPrepaymentsAccount: Code[20]; PurchasePrepaymentsAccount: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        GeneralPostingSetup.Get(GenBusPostingGroup, GenProdPostingGroup);

        GeneralPostingSetup.Validate("Sales Prepayments Account", SalesPrepaymentsAccount);
        GeneralPostingSetup.Validate("Purch. Prepayments Account", PurchasePrepaymentsAccount);
        GeneralPostingSetup.Modify(true);
    end;

    procedure IntercompanyPostingGroup(): Code[20]
    begin
        exit(IntercompanyTok);
    end;

    procedure Manufact(): Code[20]
    begin
        exit(ManufactTok);
    end;

    procedure RawMat(): Code[20]
    begin
        exit(RawMatTok);
    end;

    var
        IntercompanyTok: Label 'INTERCOMP', MaxLength = 20;
        IntercompanyLbl: Label 'Intercompany', MaxLength = 100;
        ManufactTok: Label 'MANUFACT', MaxLength = 20, Locked = true;
        RawMatTok: Label 'RAW MAT', MaxLength = 20, Locked = true;
        CapacitiesLbl: Label 'Capacities', MaxLength = 100;
}