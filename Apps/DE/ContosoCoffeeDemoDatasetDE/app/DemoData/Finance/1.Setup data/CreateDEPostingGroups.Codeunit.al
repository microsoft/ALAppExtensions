codeunit 11380 "Create DE Posting Groups"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
    begin
        InsertGenProdPostingGroup();
        UpdateGenPostingSetup();
    end;

    local procedure InsertGenProdPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertGenProductPostingGroup(NoVATPostingGroup(), MiscDescriptionLbl, '');
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    procedure UpdateVATProdPostingGroup(Code: Code[20]; VATProductPostingGroup: Code[20])
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
    begin
        if not GenProductPostingGroup.Get(Code) then
            exit;

        GenProductPostingGroup.Validate("Def. VAT Prod. Posting Group", VATProductPostingGroup);
        GenProductPostingGroup.Modify(true);
    end;

    procedure UpdateGenPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreateDEGLAccount: Codeunit "Create DE GL Acc.";
        CreatePostingGroup: Codeunit "Create Posting Groups";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', NoVATPostingGroup(), '', '', CreateDEGLAccount.CostofMaterials(), CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.GoodsforResale(), '', '', '', '', '', CreateDEGLAccount.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroup.RetailPostingGroup(), '', '', CreateDEGLAccount.CostofMaterials(), CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.GoodsforResale(), '', '', '', '', '', CreateDEGLAccount.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.DomesticPostingGroup(), NoVATPostingGroup(), CreateDEGLAccount.ResaleofGoods(), CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.CostofMaterials(), CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.GoodsforResale(), '', CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateDEGLAccount.ResaleofGoods(), CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.CostofMaterials(), CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.GoodsforResale(), '', CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), CreateDEGLAccount.SalesofServiceWork(), CreateDEGLAccount.OtherExternalServices(), CreateDEGLAccount.CostofLabor(), CreateDEGLAccount.OtherExternalServices(), CreateDEGLAccount.OtherExternalServices(), '', CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.CostofLabor(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.EUPostingGroup(), NoVATPostingGroup(), CreateDEGLAccount.ResaleofGoods(), CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.CostofMaterials(), CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.GoodsforResale(), '', CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateDEGLAccount.ResaleofGoods(), CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.CostofMaterials(), CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.GoodsforResale(), '', CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), CreateDEGLAccount.SalesofServiceWork(), CreateDEGLAccount.OtherExternalServices(), CreateDEGLAccount.CostofLabor(), CreateDEGLAccount.OtherExternalServices(), CreateDEGLAccount.OtherExternalServices(), '', CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.CostofLabor(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.ExportPostingGroup(), NoVATPostingGroup(), CreateDEGLAccount.ResaleofGoods(), CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.CostofMaterials(), CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.GoodsforResale(), '', CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateDEGLAccount.ResaleofGoods(), CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.CostofMaterials(), CreateDEGLAccount.GoodsforResale(), CreateDEGLAccount.GoodsforResale(), '', CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), CreateDEGLAccount.SalesofServiceWork(), CreateDEGLAccount.OtherExternalServices(), CreateDEGLAccount.CostofLabor(), CreateDEGLAccount.OtherExternalServices(), CreateDEGLAccount.OtherExternalServices(), '', CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.SalesDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.PurchaseDiscounts(), CreateDEGLAccount.CostofLabor(), '', '');
        ContosoGenPostingSetup.SetOverwriteData(false);
    end;

    procedure NoVATPostingGroup(): Code[20]
    begin
        exit(NoVATTok);
    end;

    var
        MiscDescriptionLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
        NoVATTok: Label 'NO VAT', MaxLength = 20;
}