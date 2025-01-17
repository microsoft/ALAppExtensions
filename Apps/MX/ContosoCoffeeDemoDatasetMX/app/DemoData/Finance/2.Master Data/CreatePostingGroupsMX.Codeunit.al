codeunit 14110 "Create Posting Groups MX"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertGenProductPostingGroup();
    end;

    procedure CreateGenPostingSetup()
    var
        CreatePostingGroups: Codeunit "Create Posting Groups";
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateMXGLAccounts: Codeunit "Create MX GL Accounts";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.FreightPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.MiscPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', NOVAT(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.ServicesPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RetailPostingGroup(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), NOVAT(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.FreightPostingGroup(), CreateGLAccount.FeesAndChargesRecDom(), '', CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccount.SalesResourcesDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.FreightPostingGroup(), CreateMXGLAccounts.FeesAndChargesRecEu(), '', CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailEu(), CreateGLAccount.PurchRetailEu(), CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.MiscPostingGroup(), CreateGLAccount.SalesRetailEu(), CreateGLAccount.PurchRetailEu(), CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), NOVAT(), CreateGLAccount.SalesRetailEu(), CreateGLAccount.PurchRetailEu(), CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccount.SalesResourcesEu(), CreateGLAccount.PurchRetailEu(), CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.MiscPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), NOVAT(), CreateGLAccount.SalesRetailExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateGLAccount.SalesResourcesExport(), CreateGLAccount.PurchRetailExport(), CreateGLAccount.InventoryAdjmtRetail(), CreateMXGLAccounts.InventoryPosting(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.SetOverwriteData(false);

        UpdateGenPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateMXGLAccounts.CustomerPrepaymentsVat16Perc(), CreateMXGLAccounts.VendorPrepaymentsVat16Perc());
        UpdateGenPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.MiscPostingGroup(), CreateMXGLAccounts.CustomerPrepaymentsVat16Perc(), CreateMXGLAccounts.VendorPrepaymentsVat16Perc());
        UpdateGenPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateMXGLAccounts.CustomerPrepaymentsVat8Perc(), CreateMXGLAccounts.VendorPrepaymentsVat8Perc());
        UpdateGenPostingSetup(CreatePostingGroups.DomesticPostingGroup(), NOVAT(), CreateGLAccount.CustomerPrepaymentsVAT0(), CreateGLAccount.VendorPrepaymentsVAT());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Product Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVATProductPostingGroup(var Rec: Record "Gen. Product Posting Group")
    var
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateVATPostingGroupsMX: Codeunit "Create VAT Posting Groups MX";
    begin
        case Rec.Code of
            CreatePostingGroups.FreightPostingGroup(),
            CreatePostingGroups.MiscPostingGroup(),
            CreatePostingGroups.RetailPostingGroup():
                Rec.Validate("Def. VAT Prod. Posting Group", CreateVATPostingGroupsMX.VAT16());
            CreatePostingGroups.ServicesPostingGroup():
                Rec.Validate("Def. VAT Prod. Posting Group", CreateVATPostingGroupsMX.VAT8());
        end;
    end;

    local procedure UpdateGenPostingSetup(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; SalesPrepaymentAccount: Code[20]; PurchasePrepaymentAccount: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        GeneralPostingSetup.Get(GenBusPostingGroup, GenProdPostingGroup);

        GeneralPostingSetup.Validate("Sales Prepayments Account", SalesPrepaymentAccount);
        GeneralPostingSetup.Validate("Purch. Prepayments Account", PurchasePrepaymentAccount);
        GeneralPostingSetup.Modify(true);
    end;

    local procedure InsertGenProductPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertGenProductPostingGroup(NOVAT(), MiscellaneousNoVATLbl, NOVAT());
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    procedure NOVAT(): Code[20]
    begin
        exit(NoVATTok);
    end;

    var
        NoVATTok: Label 'NO VAT', MaxLength = 20, Locked = true;
        MiscellaneousNoVATLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
}