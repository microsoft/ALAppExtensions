codeunit 11602 "Create CH Posting Groups"
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
        ContosoPostingGroup.InsertGenProductPostingGroup(ManufactPostingGroup(), CapacitiesLbl, '');
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
        CreateCHGLAccounts: Codeunit "Create CH GL Accounts";
        CreatePostingGroup: Codeunit "Create Posting Groups";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroup.RetailPostingGroup(), '', '', CreateCHGLAccounts.InvChangeCommGoods(), '', '', '', '', '', '', '', CreateCHGLAccounts.InvChangeCommGoods(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroup.ServicesPostingGroup(), '', '', '', '', '', '', '', '', '', '', '', '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateCHGLAccounts.TradeDomestic(), CreateCHGLAccounts.CostOfCommGoodsDomestic(), CreateCHGLAccounts.InvChangeCommGoods(), CreateCHGLAccounts.InvChangeCommGoods(), '', '', CreateCHGLAccounts.TradeDomestic(), CreateCHGLAccounts.Discounts(), CreateCHGLAccounts.CostOfCommGoodsDomestic(), CreateCHGLAccounts.CostReductionDiscount(), CreateCHGLAccounts.InvChangeCommGoods(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), CreateCHGLAccounts.ServiceEarningsDomestic(), CreateCHGLAccounts.SubcontrOfSpOperations(), CreateCHGLAccounts.InvChangeFinishedProducts(), '', '', '', CreateCHGLAccounts.ServiceEarningsDomestic(), CreateCHGLAccounts.Discounts(), CreateCHGLAccounts.SubcontrOfSpOperations(), CreateCHGLAccounts.CostReductionDiscount(), CreateCHGLAccounts.InvChangeFinishedProducts(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateCHGLAccounts.TradeEurope(), CreateCHGLAccounts.CostOfCommGoodsEurope(), CreateCHGLAccounts.InvChangeCommGoods(), CreateCHGLAccounts.InvChangeCommGoods(), '', '', CreateCHGLAccounts.TradeEurope(), CreateCHGLAccounts.Discounts(), CreateCHGLAccounts.CostOfCommGoodsEurope(), CreateCHGLAccounts.CostReductionDiscount(), CreateCHGLAccounts.InvChangeCommGoods(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), CreateCHGLAccounts.ProdEarningsEurope(), CreateCHGLAccounts.CostOfMaterialsEurope(), CreateCHGLAccounts.InvChangeFinishedProducts(), '', '', '', CreateCHGLAccounts.ProdEarningsEurope(), CreateCHGLAccounts.Discounts(), CreateCHGLAccounts.CostOfMaterialsEurope(), CreateCHGLAccounts.CostReductionDiscount(), CreateCHGLAccounts.InvChangeFinishedProducts(), '', '');
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateCHGLAccounts.TradeInternat(), CreateCHGLAccounts.CostOfCommGoodsIntl(), CreateCHGLAccounts.InvChangeCommGoods(), CreateCHGLAccounts.InvChangeCommGoods(), '', '', CreateCHGLAccounts.TradeInternat(), CreateCHGLAccounts.Discounts(), CreateCHGLAccounts.CostOfCommGoodsIntl(), CreateCHGLAccounts.CostReductionDiscount(), CreateCHGLAccounts.InvChangeCommGoods(), '', '');
        ContosoGenPostingSetup.SetOverwriteData(false);

        UpdateGeneralPostingSetup('', CreatePostingGroup.RetailPostingGroup(), '', '', CreateCHGLAccounts.VendorPrepaymentsVat0Percent(), CreateCHGLAccounts.CustomerPrepaymentsVat0Percent());
        UpdateGeneralPostingSetup('', CreatePostingGroup.ServicesPostingGroup(), '', '', CreateCHGLAccounts.VendorPrepaymentsVat0Percent(), CreateCHGLAccounts.CustomerPrepaymentsVat0Percent());
        UpdateGeneralPostingSetup(CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateCHGLAccounts.TradeDomestic(), CreateCHGLAccounts.CostOfCommGoodsDomestic(), CreateCHGLAccounts.VendorPrepaymentsVat80Percent(), CreateCHGLAccounts.CustomerPrepaymentsVat80Percent());
        UpdateGeneralPostingSetup(CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), CreateCHGLAccounts.ServiceEarningsDomestic(), CreateCHGLAccounts.SubcontrOfSpOperations(), CreateCHGLAccounts.VendorPrepaymentsVat80Percent(), CreateCHGLAccounts.CustomerPrepaymentsVat80Percent());
        UpdateGeneralPostingSetup(CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateCHGLAccounts.TradeEurope(), CreateCHGLAccounts.CostOfCommGoodsEurope(), CreateCHGLAccounts.VendorPrepaymentsVat0Percent(), CreateCHGLAccounts.CustomerPrepaymentsVat0Percent());
        UpdateGeneralPostingSetup(CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), CreateCHGLAccounts.ProdEarningsEurope(), CreateCHGLAccounts.CostOfMaterialsEurope(), CreateCHGLAccounts.VendorPrepaymentsVat0Percent(), CreateCHGLAccounts.CustomerPrepaymentsVat0Percent());
        UpdateGeneralPostingSetup(CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateCHGLAccounts.TradeInternat(), CreateCHGLAccounts.CostOfCommGoodsIntl(), CreateCHGLAccounts.VendorPrepaymentsVat0Percent(), CreateCHGLAccounts.CustomerPrepaymentsVat0Percent());
    end;

    local procedure UpdateGeneralPostingSetup(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; SalesCreditMemoAccount: Code[20]; PurchCreditMemoAccount: Code[20]; SalesPrepaymentsAccount: Code[20]; PurchPrepaymentsAccount: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if not GeneralPostingSetup.Get(GenBusPostingGroup, GenProdPostingGroup) then
            exit;

        GeneralPostingSetup.Validate("Sales Credit Memo Account", SalesCreditMemoAccount);
        GeneralPostingSetup.Validate("Purch. Credit Memo Account", PurchCreditMemoAccount);
        GeneralPostingSetup.Validate("Sales Prepayments Account", SalesPrepaymentsAccount);
        GeneralPostingSetup.Validate("Purch. Prepayments Account", PurchPrepaymentsAccount);
        GeneralPostingSetup.Modify(true);
    end;

    procedure NoVATPostingGroup(): Code[20]
    begin
        exit(NoVATTok);
    end;

    procedure ManufactPostingGroup(): Code[20]
    begin
        exit(ManufactTok);
    end;

    var
        CapacitiesLbl: Label 'Capacities', MaxLength = 100;
        MiscDescriptionLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
        NoVATTok: Label 'NO VAT', MaxLength = 20;
        ManufactTok: Label 'MANUFACT', MaxLength = 20;
}