codeunit 11538 "Create Posting Groups NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
    begin
        InsertVATProductPostingGroup();
        UpdateGeneralPostingSetup();
    end;

    local procedure InsertVATProductPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertVATProductPostingGroup(CreateVATPostingGroups.FullNormal(), StrSubstNo(VATOnlyInvoicesDescriptionLbl, '21'));
        ContosoPostingGroup.InsertVATProductPostingGroup(CreateVATPostingGroups.ServNormal(), StrSubstNo(MiscellaneousVATDescriptionLbl, '21'));
        ContosoPostingGroup.InsertVATProductPostingGroup(CreateVATPostingGroups.Standard(), StrSubstNo(NormalVatDescriptionLbl, '21'));
        ContosoPostingGroup.InsertVATProductPostingGroup(CreateVATPostingGroups.FullRed(), StrSubstNo(VATOnlyInvoicesDescriptionLbl, '9'));
        ContosoPostingGroup.InsertVATProductPostingGroup(CreateVATPostingGroups.Reduced(), StrSubstNo(ReducedVatDescriptionLbl, '9'));
        ContosoPostingGroup.InsertVATProductPostingGroup(CreateVATPostingGroups.ServRed(), StrSubstNo(MiscellaneousVATDescriptionLbl, '9'));
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    local procedure UpdateGeneralPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateNLGLAccounts: Codeunit "Create NL GL Accounts";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RetailPostingGroup(), '', '', CreateNLGLAccounts.CostofMaterials(), CreateNLGLAccounts.GoodsforResale(), CreateNLGLAccounts.GoodsforResale(), '', '', '', '', '', CreateNLGLAccounts.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.ZeroPostingGroup(), '', '', CreateNLGLAccounts.CostofMaterials(), CreateNLGLAccounts.GoodsforResale(), CreateNLGLAccounts.GoodsforResale(), '', '', '', '', '', CreateNLGLAccounts.CostofMaterials(), '', '');

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateNLGLAccounts.ResaleofGoods(), CreateNLGLAccounts.GoodsforResale(), CreateNLGLAccounts.CostofMaterials(), CreateNLGLAccounts.GoodsforResale(), CreateNLGLAccounts.GoodsforResale(), '', CreateNLGLAccounts.SalesDiscounts(), CreateNLGLAccounts.SalesDiscounts(), CreateNLGLAccounts.PurchaseDiscounts(), CreateNLGLAccounts.PurchaseDiscounts(), CreateNLGLAccounts.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateNLGLAccounts.SalesofServiceWork(), CreateNLGLAccounts.OtherExternalServices(), CreateNLGLAccounts.CostofLabor(), CreateNLGLAccounts.OtherExternalServices(), CreateNLGLAccounts.OtherExternalServices(), '', CreateNLGLAccounts.SalesDiscounts(), CreateNLGLAccounts.SalesDiscounts(), CreateNLGLAccounts.PurchaseDiscounts(), CreateNLGLAccounts.PurchaseDiscounts(), CreateNLGLAccounts.CostofLabor(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), CreateNLGLAccounts.ResaleofGoods(), CreateNLGLAccounts.GoodsforResale(), CreateNLGLAccounts.CostofMaterials(), CreateNLGLAccounts.GoodsforResale(), CreateNLGLAccounts.GoodsforResale(), '', CreateNLGLAccounts.SalesDiscounts(), CreateNLGLAccounts.SalesDiscounts(), CreateNLGLAccounts.PurchaseDiscounts(), CreateNLGLAccounts.PurchaseDiscounts(), CreateNLGLAccounts.CostofMaterials(), '', '');

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateNLGLAccounts.ResaleofGoods(), CreateNLGLAccounts.GoodsforResale(), CreateNLGLAccounts.CostofMaterials(), CreateNLGLAccounts.GoodsforResale(), CreateNLGLAccounts.GoodsforResale(), '', CreateNLGLAccounts.SalesDiscounts(), CreateNLGLAccounts.SalesDiscounts(), CreateNLGLAccounts.PurchaseDiscounts(), CreateNLGLAccounts.PurchaseDiscounts(), CreateNLGLAccounts.CostofMaterials(), '', '');

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateNLGLAccounts.ResaleofGoods(), CreateNLGLAccounts.GoodsforResale(), CreateNLGLAccounts.CostofMaterials(), CreateNLGLAccounts.GoodsforResale(), CreateNLGLAccounts.GoodsforResale(), '', CreateNLGLAccounts.SalesDiscounts(), CreateNLGLAccounts.SalesDiscounts(), CreateNLGLAccounts.PurchaseDiscounts(), CreateNLGLAccounts.PurchaseDiscounts(), CreateNLGLAccounts.CostofMaterials(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateNLGLAccounts.SalesofServiceWork(), CreateNLGLAccounts.OtherExternalServices(), CreateNLGLAccounts.CostofLabor(), CreateNLGLAccounts.OtherExternalServices(), CreateNLGLAccounts.OtherExternalServices(), '', CreateNLGLAccounts.SalesDiscounts(), CreateNLGLAccounts.SalesDiscounts(), CreateNLGLAccounts.PurchaseDiscounts(), CreateNLGLAccounts.PurchaseDiscounts(), CreateNLGLAccounts.CostofLabor(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), CreateNLGLAccounts.ResaleofGoods(), CreateNLGLAccounts.GoodsforResale(), CreateNLGLAccounts.CostofMaterials(), CreateNLGLAccounts.GoodsforResale(), CreateNLGLAccounts.GoodsforResale(), '', CreateNLGLAccounts.SalesDiscounts(), CreateNLGLAccounts.SalesDiscounts(), CreateNLGLAccounts.PurchaseDiscounts(), CreateNLGLAccounts.PurchaseDiscounts(), CreateNLGLAccounts.CostofMaterials(), '', '');
        ContosoGenPostingSetup.SetOverwriteData(false);
    end;

    var
        VATOnlyInvoicesDescriptionLbl: Label 'VAT Only Invoices %1%', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        MiscellaneousVATDescriptionLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        NormalVatDescriptionLbl: Label 'Standard VAT (%1%)', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        ReducedVatDescriptionLbl: Label 'Reduced VAT (%1%)', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
}