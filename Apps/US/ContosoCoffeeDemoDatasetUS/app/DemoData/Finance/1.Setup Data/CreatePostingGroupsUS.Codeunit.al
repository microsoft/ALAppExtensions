codeunit 11480 "Create Posting Groups US"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
    begin
        InsertGenProdPostingGroup();
        InsertGeneralPostingSetup();
        UpdateGeneralPostingSetup();
    end;

    local procedure InsertGenProdPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertGenProductPostingGroup(NoTaxPostingGroup(), NoTaxDescriptionLbl, '');
    end;

    local procedure InsertGeneralPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
    begin
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', NoTaxPostingGroup(), '', '', CreateUSGLAccounts.CostofMaterials(), CreateUSGLAccounts.GoodsforResale(), CreateUSGLAccounts.GoodsforResale(), '', '', '', '', '', CreateUSGLAccounts.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), NoTaxPostingGroup(), CreateUSGLAccounts.ResaleofGoods(), CreateUSGLAccounts.GoodsforResale(), CreateUSGLAccounts.CostofMaterials(), CreateUSGLAccounts.GoodsforResale(), CreateUSGLAccounts.GoodsforResale(), '', CreateUSGLAccounts.DiscountsandAllowances(), CreateUSGLAccounts.DiscountsandAllowances(), CreateUSGLAccounts.PurchaseDiscounts(), CreateUSGLAccounts.PurchaseDiscounts(), CreateUSGLAccounts.CostofMaterials(), '', '');
    end;

    local procedure UpdateGeneralPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RetailPostingGroup(), '', '', CreateUSGLAccounts.CostofMaterials(), CreateUSGLAccounts.GoodsforResale(), CreateUSGLAccounts.GoodsforResale(), '', '', '', '', '', CreateUSGLAccounts.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateUSGLAccounts.ResaleofGoods(), CreateUSGLAccounts.GoodsforResale(), CreateUSGLAccounts.CostofMaterials(), CreateUSGLAccounts.GoodsforResale(), CreateUSGLAccounts.GoodsforResale(), '', CreateUSGLAccounts.DiscountsandAllowances(), CreateUSGLAccounts.DiscountsandAllowances(), CreateUSGLAccounts.PurchaseDiscounts(), CreateUSGLAccounts.PurchaseDiscounts(), CreateUSGLAccounts.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateUSGLAccounts.SalesofServiceWork(), CreateUSGLAccounts.OtherExternalServices(), CreateUSGLAccounts.CostofLabor(), CreateUSGLAccounts.OtherExternalServices(), CreateUSGLAccounts.OtherExternalServices(), '', CreateUSGLAccounts.DiscountsandAllowances(), CreateUSGLAccounts.DiscountsandAllowances(), CreateUSGLAccounts.PurchaseDiscounts(), CreateUSGLAccounts.PurchaseDiscounts(), CreateUSGLAccounts.CostofLabor(), '', '');
        ContosoGenPostingSetup.SetOverwriteData(false);
    end;

    procedure NoTaxPostingGroup(): Code[20]
    begin
        exit(NoTaxTok);
    end;

    var
        NoTaxTok: Label 'NO TAX', MaxLength = 20;
        NoTaxDescriptionLbl: Label 'Miscellaneous without tax', MaxLength = 100;
}