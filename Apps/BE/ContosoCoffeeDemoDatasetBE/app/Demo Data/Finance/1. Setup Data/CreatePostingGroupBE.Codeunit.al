codeunit 11364 "Create Posting Group BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
    begin
        InsertGenProdPostingGroup();
        UpdateGenBusinessPostingGroup();
        UpdateGenPostingSetup();
    end;

    local procedure InsertGenProdPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateVATPostingGroupBE: codeunit "Create VAT Posting Group BE";
        CreatePostingGroup: Codeunit "Create Posting Groups";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertGenProductPostingGroup(NoVATPostingGroup(), MiscDescriptionLbl, CreateVATPostingGroupBE.NOVAT());
        UpdateGenProdPostingGrp(CreatePostingGroup.FreightPostingGroup(), CreateVATPostingGroupBE.G3());
        UpdateGenProdPostingGrp(CreatePostingGroup.RawMatPostingGroup(), CreateVATPostingGroupBE.G3());
        UpdateGenProdPostingGrp(CreatePostingGroup.RetailPostingGroup(), CreateVATPostingGroupBE.G3());
        UpdateGenProdPostingGrp(CreatePostingGroup.MiscPostingGroup(), CreateVATPostingGroupBE.G3());
        UpdateGenProdPostingGrp(CreatePostingGroup.ServicesPostingGroup(), CreateVATPostingGroupBE.S3());
        UpdateGenProdPostingGrp(CreatePostingGroup.ExportPostingGroup(), CreateVATPostingGroupBE.IMPEXP());
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    local procedure UpdateGenProdPostingGrp(ProdPostingGroup: COde[20]; DefaultVATProdPostingGroup: Code[20])
    var
        GenProdPostingGroup: Record "Gen. Product Posting Group";
    begin
        if GenProdPostingGroup.Get(ProdPostingGroup) then begin
            GenProdPostingGroup.Validate("Def. VAT Prod. Posting Group", DefaultVATProdPostingGroup);
            GenProdPostingGroup.Modify(true);
        end;
    end;

    local procedure UpdateGenBusinessPostingGroup()
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        CreateVatPostingGroupBE: Codeunit "Create VAT Posting Group BE";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        GenBusinessPostingGroup.Get(CreatePostingGroups.ExportPostingGroup());
        GenBusinessPostingGroup.Validate("Def. VAT Bus. Posting Group", CreateVatPostingGroupBE.IMPEXP());
        GenBusinessPostingGroup.Modify(true);
    end;

    procedure UpdateGenPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreateBEGLAccount: Codeunit "Create GL Account BE";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreatePostingGroup: Codeunit "Create Posting Groups";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', NoVATPostingGroup(), '', '', CreateBEGLAccount.InventAdjRetail(), CreateBEGLAccount.Goods(), '', '', '', '', '', '', CreateBEGLAccount.PurchaseCostsRetail(), CreateBEGLAccount.PurchaseCostsInterim(), CreateGLAccount.VATPayable());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroup.RetailPostingGroup(), '', '', CreateBEGLAccount.InventAdjRetail(), CreateBEGLAccount.Goods(), '', '', '', '', '', '', CreateBEGLAccount.PurchaseCostsRetail(), CreateBEGLAccount.PurchaseCostsInterim(), CreateGLAccount.VATPayable());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.DomesticPostingGroup(), NoVATPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateBEGLAccount.PurchasesRetailDom(), CreateBEGLAccount.InventAdjRetail(), CreateBEGLAccount.Goods(), '', '', CreateBEGLAccount.PaymentDiscReceived(), CreateBEGLAccount.PaymentDiscReceived(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateBEGLAccount.PurchaseCostsRetail(), CreateBEGLAccount.PurchaseCostsInterim(), CreateGLAccount.VATPayable());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateBEGLAccount.PurchasesRetailDom(), CreateBEGLAccount.InventAdjRetail(), CreateBEGLAccount.Goods(), '', '', CreateBEGLAccount.PaymentDiscReceived(), CreateBEGLAccount.PaymentDiscReceived(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateBEGLAccount.PurchaseCostsRetail(), CreateBEGLAccount.PurchaseCostsInterim(), CreateGLAccount.VATPayable());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), CreateGLAccount.SalesResourcesDom(), CreateBEGLAccount.PurchasesRetailDom(), CreateBEGLAccount.InventAdjRetail(), CreateBEGLAccount.Goods(), '', '', CreateBEGLAccount.PaymentDiscReceived(), CreateBEGLAccount.PaymentDiscReceived(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateBEGLAccount.InventAdjRetail(), CreateBEGLAccount.PurchaseCostsInterim(), CreateBEGLAccount.InventAdjRetailInt());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateGLAccount.SalesRetailEU(), CreateBEGLAccount.PurchasesRetailEu(), CreateBEGLAccount.InventAdjRetail(), CreateBEGLAccount.Goods(), '', '', CreateBEGLAccount.PaymentDiscReceived(), CreateBEGLAccount.PaymentDiscReceived(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateBEGLAccount.PurchaseCostsRetail(), CreateBEGLAccount.PurchaseCostsInterim(), CreateGLAccount.VATPayable());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.ExportPostingGroup(), NoVATPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateBEGLAccount.PurchasesRetailExport(), CreateBEGLAccount.InventAdjRetail(), CreateBEGLAccount.Goods(), '', '', CreateBEGLAccount.PaymentDiscReceived(), CreateBEGLAccount.PaymentDiscReceived(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateBEGLAccount.PurchaseCostsRetail(), CreateBEGLAccount.PurchaseCostsInterim(), CreateGLAccount.VATPayable());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateBEGLAccount.PurchasesRetailExport(), CreateBEGLAccount.InventAdjRetail(), CreateBEGLAccount.Goods(), '', '', CreateBEGLAccount.PaymentDiscReceived(), CreateBEGLAccount.PaymentDiscReceived(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateBEGLAccount.PurchaseCostsRetail(), CreateBEGLAccount.PurchaseCostsInterim(), CreateGLAccount.VATPayable());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), CreateGLAccount.SalesResourcesExport(), CreateBEGLAccount.PurchasesRetailExport(), CreateBEGLAccount.InventAdjRetail(), CreateBEGLAccount.Goods(), '', '', CreateBEGLAccount.PaymentDiscReceived(), CreateBEGLAccount.PaymentDiscReceived(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateBEGLAccount.InventAdjRetail(), CreateBEGLAccount.PurchaseCostsInterim(), CreateBEGLAccount.InventAdjRetailInt());
        ContosoGenPostingSetup.SetOverwriteData(false);

        UpdatePmtDiscAccounts(CreatePostingGroup.DomesticPostingGroup(), NoVATPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateBEGLAccount.PurchasesRetailDom());
        UpdatePmtDiscAccounts(CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateBEGLAccount.PurchasesRetailDom());
        UpdatePmtDiscAccounts(CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), CreateGLAccount.SalesResourcesDom(), CreateBEGLAccount.PurchasesRetailDom());
        UpdatePmtDiscAccounts(CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateGLAccount.SalesRetailEU(), CreateBEGLAccount.PurchasesRetailEu());
        UpdatePmtDiscAccounts(CreatePostingGroup.ExportPostingGroup(), NoVATPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateBEGLAccount.PurchasesRetailExport());
        UpdatePmtDiscAccounts(CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateGLAccount.SalesRetailExport(), CreateBEGLAccount.PurchasesRetailExport());
        UpdatePmtDiscAccounts(CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), CreateGLAccount.SalesResourcesExport(), CreateBEGLAccount.PurchasesRetailExport());
    end;

    local procedure UpdatePmtDiscAccounts(GenBusPostinGrp: Code[20]; GenProdPostingGrp: Code[20]; SalesCreditMemoAcc: Code[20]; PurchaseCreditMemo: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if not GeneralPostingSetup.Get(GenBusPostinGrp, GenProdPostingGrp) then
            exit;

        GeneralPostingSetup.Validate("Sales Credit Memo Account", SalesCreditMemoAcc);
        GeneralPostingSetup.Validate("Purch. Credit Memo Account", PurchaseCreditMemo);
        GeneralPostingSetup.Modify(true);
    end;

    procedure NoVATPostingGroup(): Code[20]
    begin
        exit(NoVATTok);
    end;

    var
        MiscDescriptionLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
        NoVATTok: Label 'NO VAT', MaxLength = 20, Locked = true;
}