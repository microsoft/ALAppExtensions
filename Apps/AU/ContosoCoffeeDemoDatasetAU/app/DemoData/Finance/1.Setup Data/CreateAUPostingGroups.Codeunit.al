codeunit 17138 "Create AU Posting Groups"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertGenPostingGroup();
        UpdateGenProductPostingGroup();
        InsertGenBusinessPostingGroup();
        UpdateGenBusinessPostingGroup();
        InsertGenPostingSetupWithoutGLAccounts();
    end;

    local procedure InsertGenPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertGenProductPostingGroup(NonGst(), NonGstPostingGroupDescriptionLbl, '');
        ContosoPostingGroup.InsertGenProductPostingGroup(Manufact(), CapacitiesPostingGroupDescriptionLbl, '');
        ContosoPostingGroup.InsertGenProductPostingGroup(CreatePostingGroups.MiscPostingGroup(), 'Miscellaneous with Tax', '');
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    local procedure UpdateGenProductPostingGroup()
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateAUVATPostingGroups: Codeunit "Create AU VAT Posting Groups";
    begin
        GenProductPostingGroup.Get(CreatePostingGroups.ServicesPostingGroup());
        GenProductPostingGroup.Validate("Def. VAT Prod. Posting Group", CreateAUVATPostingGroups.Vat10());
        GenProductPostingGroup.Modify(true);
        UpdateVATProdPostingGroupOnGLAccount(CreatePostingGroups.ServicesPostingGroup(), CreateAUVATPostingGroups.Vat10());

        GenProductPostingGroup.Get(CreatePostingGroups.RawMatPostingGroup());
        GenProductPostingGroup.Validate("Def. VAT Prod. Posting Group", '');
        GenProductPostingGroup.Modify(true);
        UpdateVATProdPostingGroupOnGLAccount(CreatePostingGroups.RawMatPostingGroup(), '');

        GenProductPostingGroup.Get(CreatePostingGroups.RetailPostingGroup());
        GenProductPostingGroup.Validate("Def. VAT Prod. Posting Group", '');
        GenProductPostingGroup.Modify(true);
        UpdateVATProdPostingGroupOnGLAccount(CreatePostingGroups.RetailPostingGroup(), '');

        GenProductPostingGroup.Get(CreatePostingGroups.MiscPostingGroup());
        GenProductPostingGroup.Validate("Def. VAT Prod. Posting Group", '');
        GenProductPostingGroup.Modify(true);
        UpdateVATProdPostingGroupOnGLAccount(CreatePostingGroups.MiscPostingGroup(), '');

        UpdateVATProdPostingGroupOnGLAccount(CreatePostingGroups.ZeroPostingGroup(), '');

        UpdateVATProdPostingGroupOnGLAccount(CreatePostingGroups.FreightPostingGroup(), '');
    end;

    local procedure UpdateGenBusinessPostingGroup()
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        GenBusinessPostingGroup.Get(CreatePostingGroups.DomesticPostingGroup());
        GenBusinessPostingGroup.Validate("Def. VAT Bus. Posting Group", '');
        GenBusinessPostingGroup.Modify(true);
        GenBusinessPostingGroup.Get(CreatePostingGroups.ExportPostingGroup());
        GenBusinessPostingGroup.Validate("Def. VAT Bus. Posting Group", '');
        GenBusinessPostingGroup.Modify(true);
    end;

    local procedure InsertGenBusinessPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertGenBusinessPostingGroup(IntercompanyPostingGroup(), IntercompanyPostingGroupDescriptionLbl, '');
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    local procedure InsertGenPostingSetupWithoutGLAccounts()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', Manufact(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.MiscPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', NonGst(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RawMatPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.ServicesPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), Manufact(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), NonGst(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), Manufact(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.MiscPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), NonGst(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(IntercompanyPostingGroup(), Manufact(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(IntercompanyPostingGroup(), CreatePostingGroups.MiscPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(IntercompanyPostingGroup(), NonGst(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(IntercompanyPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(IntercompanyPostingGroup(), CreatePostingGroups.RetailPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(IntercompanyPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.SetOverwriteData(false);
    end;

    procedure UpdateGenPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateAUGLAccounts: Codeunit "Create AU GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RetailPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), '', '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', Manufact(), '', '', CreateGLAccount.InventoryAdjmtRetail(), '', '', '', '', '', '', '', CreateGLAccount.CostOfRetailSold(), CreateGLAccount.CostOfResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.MiscPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), '', '', '', '', '', '', '', CreateGLAccount.CostOfRetailSold(), CreateGLAccount.CostOfResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', NonGst(), '', '', CreateGLAccount.InventoryAdjmtRetail(), '', '', '', '', '', '', '', CreateGLAccount.CostOfRetailSold(), CreateGLAccount.CostOfResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.ServicesPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), '', '', '', '', '', '', '', CreateGLAccount.CostOfRetailSold(), CreateGLAccount.CostOfResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RawMatPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRawMat(), '', '', '', '', '', '', '', CreateGLAccount.CostOfRetailSold(), CreateGLAccount.CostOfRawMatSoldInterim(), CreateGLAccount.InvAdjmtInterimRawMat());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), Manufact(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateAUGLAccounts.DirectCostAppliedRetail(), CreateAUGLAccounts.OverheadAppliedCap(), CreateAUGLAccounts.PurchaseVarianceCap(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostOfRetailSold(), CreateGLAccount.CostOfResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateAUGLAccounts.DirectCostAppliedRetail(), CreateAUGLAccounts.OverheadAppliedRetail(), CreateAUGLAccounts.PurchaseVarianceRetail(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostOfRetailSold(), CreateGLAccount.CostOfResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), NonGst(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateAUGLAccounts.DirectCostAppliedRetail(), CreateAUGLAccounts.OverheadAppliedRetail(), CreateAUGLAccounts.PurchaseVarianceRetail(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostOfRetailSold(), CreateGLAccount.CostOfResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), CreateGLAccount.SalesRawMaterialsDom(), CreateGLAccount.PurchRawMaterialsDom(), CreateGLAccount.InventoryAdjmtRawMat(), CreateAUGLAccounts.DirectCostAppliedRawmat(), CreateAUGLAccounts.OverheadAppliedRawmat(), CreateAUGLAccounts.PurchaseVarianceRawmat(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRawMaterials(), CreateGLAccount.DiscReceivedRawMaterials(), CreateGLAccount.CostOfRawMaterialsSold(), CreateGLAccount.CostOfRawMatSoldInterim(), CreateGLAccount.InvAdjmtInterimRawMat());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateAUGLAccounts.DirectCostAppliedRetail(), CreateAUGLAccounts.OverheadAppliedRetail(), CreateAUGLAccounts.PurchaseVarianceRetail(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccount.SalesResourcesDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateAUGLAccounts.DirectCostAppliedCap(), CreateAUGLAccounts.OverheadAppliedCap(), CreateAUGLAccounts.PurchaseVarianceCap(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), Manufact(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateAUGLAccounts.DirectCostAppliedRetail(), CreateAUGLAccounts.OverheadAppliedCap(), CreateAUGLAccounts.PurchaseVarianceCap(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostOfRetailSold(), CreateGLAccount.CostOfResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.MiscPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateAUGLAccounts.DirectCostAppliedRetail(), CreateAUGLAccounts.OverheadAppliedRetail(), CreateAUGLAccounts.PurchaseVarianceRetail(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostOfRetailSold(), CreateGLAccount.CostOfResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), NonGst(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateAUGLAccounts.DirectCostAppliedRawmat(), CreateAUGLAccounts.OverheadAppliedRawmat(), CreateAUGLAccounts.PurchaseVarianceRawmat(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostOfRetailSold(), CreateGLAccount.CostOfResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), CreateGLAccount.SalesRawMaterialsExport(), CreateGLAccount.PurchRawMaterialsExport(), CreateGLAccount.InventoryAdjmtRawMat(), CreateAUGLAccounts.DirectCostAppliedRetail(), CreateAUGLAccounts.OverheadAppliedRetail(), CreateAUGLAccounts.PurchaseVarianceRetail(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRawMaterials(), CreateGLAccount.DiscReceivedRawMaterials(), CreateGLAccount.CostOfRawMaterialsSold(), CreateGLAccount.CostOfRawMatSoldInterim(), CreateGLAccount.InvAdjmtInterimRawMat());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateAUGLAccounts.DirectCostAppliedCap(), CreateAUGLAccounts.OverheadAppliedCap(), CreateAUGLAccounts.PurchaseVarianceCap(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccount.SalesResourcesExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateAUGLAccounts.DirectCostAppliedRetail(), CreateAUGLAccounts.OverheadAppliedRetail(), CreateAUGLAccounts.PurchaseVarianceRetail(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(IntercompanyPostingGroup(), Manufact(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateAUGLAccounts.DirectCostAppliedCap(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostOfRetailSold(), CreateGLAccount.CostOfResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(IntercompanyPostingGroup(), CreatePostingGroups.MiscPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateAUGLAccounts.DirectCostAppliedRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostOfRetailSold(), CreateGLAccount.CostOfResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(IntercompanyPostingGroup(), NonGst(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateAUGLAccounts.DirectCostAppliedRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostOfRetailSold(), CreateGLAccount.CostOfResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(IntercompanyPostingGroup(), CreatePostingGroups.RawMatPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRawMat(), CreateAUGLAccounts.OverheadAppliedRawmat(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRawMaterials(), CreateGLAccount.DiscReceivedRawMaterials(), CreateGLAccount.CostOfRawMaterialsSold(), CreateGLAccount.CostOfRawMatSoldInterim(), CreateGLAccount.InvAdjmtInterimRawMat());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(IntercompanyPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateAUGLAccounts.DirectCostAppliedRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostOfRetailSold(), CreateGLAccount.CostOfResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(IntercompanyPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateAUGLAccounts.DirectCostAppliedCap(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostOfRetailSold(), CreateGLAccount.CostOfResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.SetOverwriteData(false);

        UpdateGenPostingSetupPrepaymentsAccounts(CreatePostingGroups.DomesticPostingGroup(), Manufact(), CreateGLAccount.SalesPrepayments(), CreateGLAccount.PurchasePrepayments());
        UpdateGenPostingSetupPrepaymentsAccounts(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), CreateGLAccount.SalesPrepayments(), CreateGLAccount.PurchasePrepayments());
        UpdateGenPostingSetupPrepaymentsAccounts(CreatePostingGroups.DomesticPostingGroup(), NonGst(), CreateGLAccount.SalesPrepayments(), CreateGLAccount.PurchasePrepayments());
        UpdateGenPostingSetupPrepaymentsAccounts(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesPrepayments(), CreateGLAccount.PurchasePrepayments());
        UpdateGenPostingSetupPrepaymentsAccounts(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccount.SalesPrepayments(), CreateGLAccount.PurchasePrepayments());
    end;

    local procedure UpdateGenPostingSetupPrepaymentsAccounts(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; SalesPrepaymentAcc: Code[20]; PurchPrepaymentAcc: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        GeneralPostingSetup.Get(GenBusPostingGroup, GenProdPostingGroup);
        GeneralPostingSetup.Validate("Sales Prepayments Account", SalesPrepaymentAcc);
        GeneralPostingSetup.Validate("Purch. Prepayments Account", PurchPrepaymentAcc);
        GeneralPostingSetup.Modify(true);
    end;

    local procedure UpdateVATProdPostingGroupOnGLAccount(GenProdPostingGroup: Code[20]; VATProdPostingGroup: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetRange("Gen. Prod. Posting Group", GenProdPostingGroup);
        if GLAccount.FindSet() then
            repeat
                GLAccount.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
                GLAccount.Modify(true);
            until GLAccount.Next() = 0;
    end;

    procedure IntercompanyPostingGroup(): Code[20]
    begin
        exit(IntercompanyTok);
    end;

    procedure Manufact(): Code[20]
    begin
        exit(ManufactTok);
    end;

    procedure NonGst(): Code[20]
    begin
        exit(NonGstTok);
    end;

    var
        IntercompanyTok: Label 'INTERCOMP', MaxLength = 20, Locked = true;
        ManufactTok: Label 'MANUFACT', MaxLength = 20, Locked = true;
        NonGstTok: Label 'NON GST', MaxLength = 20, Locked = true;
        IntercompanyPostingGroupDescriptionLbl: Label 'Intercompany', MaxLength = 100, Locked = true;
        CapacitiesPostingGroupDescriptionLbl: Label 'Capacities', MaxLength = 100, Locked = true;
        NonGstPostingGroupDescriptionLbl: Label 'NON GST', MaxLength = 100, Locked = true;
}