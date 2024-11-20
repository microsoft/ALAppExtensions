codeunit 13430 "Create Posting Groups FI"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateGenPostingSetup();
    end;

    procedure UpdateGenPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateFIGLAccount: Codeunit "Create FI GL Accounts";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RetailPostingGroup(), '', '', CreateFIGLAccount.Variationinstocks5(), CreateFIGLAccount.Variationinstocks5(), '', '', '', '', '', '', CreateFIGLAccount.Variationinstocks7(), CreateFIGLAccount.Itemsandsupplies6(), CreateFIGLAccount.Accrualsanddeferredincome2());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.ZeroPostingGroup(), '', '', CreateFIGLAccount.Variationinstocks5(), CreateFIGLAccount.Variationinstocks5(), '', '', '', '', '', '', CreateFIGLAccount.Variationinstocks7(), CreateFIGLAccount.Itemsandsupplies6(), CreateFIGLAccount.Accrualsanddeferredincome2());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateFIGLAccount.Salesofgoodsdom(), CreateFIGLAccount.Reductioninvalue1(), CreateFIGLAccount.Variationinstocks5(), CreateFIGLAccount.Variationinstocks5(), '', '', CreateFIGLAccount.Discounts1(), CreateFIGLAccount.Discounts1(), CreateFIGLAccount.Discounts4(), CreateFIGLAccount.Discounts4(), CreateFIGLAccount.Variationinstocks7(), CreateFIGLAccount.Itemsandsupplies6(), CreateFIGLAccount.Accrualsanddeferredincome2());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateFIGLAccount.Salesofservicesdom(), CreateFIGLAccount.Reductioninvalue1(), CreateFIGLAccount.Variationinstocks5(), CreateFIGLAccount.Variationinstocks5(), '', '', CreateFIGLAccount.Discounts1(), CreateFIGLAccount.Discounts1(), CreateFIGLAccount.Discounts4(), CreateFIGLAccount.Discounts4(), CreateFIGLAccount.Variationinstocks7(), CreateFIGLAccount.Itemsandsupplies6(), CreateFIGLAccount.Accrualsanddeferredincome2());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), CreateFIGLAccount.Salesofgoodsdom(), CreateFIGLAccount.Reductioninvalue1(), CreateFIGLAccount.Variationinstocks5(), CreateFIGLAccount.Variationinstocks5(), '', '', CreateFIGLAccount.Discounts1(), CreateFIGLAccount.Discounts1(), CreateFIGLAccount.Discounts4(), CreateFIGLAccount.Discounts4(), CreateFIGLAccount.Variationinstocks7(), CreateFIGLAccount.Itemsandsupplies6(), CreateFIGLAccount.Accrualsanddeferredincome2());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateFIGLAccount.SalesofgoodsEU(), CreateFIGLAccount.PurchasesofgoodsEU(), CreateFIGLAccount.Variationinstocks5(), CreateFIGLAccount.Variationinstocks5(), '', '', CreateFIGLAccount.Discounts1(), CreateFIGLAccount.Discounts1(), CreateFIGLAccount.Discounts4(), CreateFIGLAccount.Discounts4(), CreateFIGLAccount.Variationinstocks7(), CreateFIGLAccount.Itemsandsupplies6(), CreateFIGLAccount.Accrualsanddeferredincome2());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateFIGLAccount.Salesofgoodsfor(), CreateFIGLAccount.Purchasesofgoodsfor(), CreateFIGLAccount.Variationinstocks5(), CreateFIGLAccount.Variationinstocks5(), '', '', CreateFIGLAccount.Discounts1(), CreateFIGLAccount.Discounts1(), CreateFIGLAccount.Discounts4(), CreateFIGLAccount.Discounts4(), CreateFIGLAccount.Variationinstocks7(), CreateFIGLAccount.Itemsandsupplies6(), CreateFIGLAccount.Accrualsanddeferredincome2());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateFIGLAccount.Salesofservicesfor(), CreateFIGLAccount.Purchasesofgoodsfor(), CreateFIGLAccount.Variationinstocks5(), CreateFIGLAccount.Variationinstocks5(), '', '', CreateFIGLAccount.Discounts1(), CreateFIGLAccount.Discounts1(), CreateFIGLAccount.Discounts4(), CreateFIGLAccount.Discounts4(), CreateFIGLAccount.Variationinstocks7(), CreateFIGLAccount.Itemsandsupplies6(), CreateFIGLAccount.Accrualsanddeferredincome2());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), CreateFIGLAccount.Salesofgoodsfor(), CreateFIGLAccount.Purchasesofgoodsfor(), CreateFIGLAccount.Variationinstocks5(), CreateFIGLAccount.Variationinstocks5(), '', '', CreateFIGLAccount.Discounts1(), CreateFIGLAccount.Discounts1(), CreateFIGLAccount.Discounts4(), CreateFIGLAccount.Discounts4(), CreateFIGLAccount.Variationinstocks7(), CreateFIGLAccount.Itemsandsupplies6(), CreateFIGLAccount.Accrualsanddeferredincome2());
        ContosoGenPostingSetup.SetOverwriteData(false);
    end;
}