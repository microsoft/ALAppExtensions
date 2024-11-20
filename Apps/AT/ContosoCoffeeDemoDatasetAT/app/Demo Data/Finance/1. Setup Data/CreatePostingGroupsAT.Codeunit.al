codeunit 11149 "Create Posting Groups AT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
    begin
        InsertGenProdPostingGroup();
    end;

    local procedure InsertGenProdPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateVATPostingGroupAT: codeunit "Create VAT Posting Group AT";
        CreatePostingGroup: Codeunit "Create Posting Groups";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertGenProductPostingGroup(ManufactPostingGroup(), CapacitiesLbl, '');
        ContosoPostingGroup.InsertGenProductPostingGroup(NoVATPostingGroup(), MiscDescriptionLbl, CreateVATPostingGroupAT.NOVAT());
        UpdateGenProdPostingGrp(CreatePostingGroup.FreightPostingGroup(), CreateVATPostingGroupAT.VAT20());
        UpdateGenProdPostingGrp(CreatePostingGroup.RawMatPostingGroup(), CreateVATPostingGroupAT.VAT20());
        UpdateGenProdPostingGrp(CreatePostingGroup.RetailPostingGroup(), CreateVATPostingGroupAT.VAT20());
        UpdateGenProdPostingGrp(CreatePostingGroup.MiscPostingGroup(), CreateVATPostingGroupAT.VAT20());
        UpdateGenProdPostingGrp(CreatePostingGroup.ServicesPostingGroup(), CreateVATPostingGroupAT.VAT10());
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

    procedure UpdateGenPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreateATGLAccount: Codeunit "Create AT GL Account";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreatePostingGroup: Codeunit "Create Posting Groups";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', NoVATPostingGroup(), '', '', CreateATGLAccount.TradeGoodsInventoryAdjustment(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), '', '', '', '', '', '', CreateATGLAccount.TradeGoodsConsumption(), CreateATGLAccount.TradeGoodsPostReceiptInterim(), CreateATGLAccount.PurchaseTradeDomestic());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroup.RetailPostingGroup(), '', '', CreateATGLAccount.TradeGoodsInventoryAdjustment(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), '', '', '', '', '', '', CreateATGLAccount.TradeGoodsConsumption(), CreateATGLAccount.TradeGoodsPostReceiptInterim(), CreateATGLAccount.PurchaseTradeDomestic());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.DomesticPostingGroup(), NoVATPostingGroup(), CreateATGLAccount.SalesRevenuesTradeDomestic(), CreateATGLAccount.PurchaseTradeDomestic(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), '', '', CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentDiscountsGranted(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.TradeGoodsConsumption(), CreateATGLAccount.TradeGoodsPostReceiptInterim(), CreateATGLAccount.PurchaseTradeDomestic());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateATGLAccount.SalesRevenuesTradeDomestic(), CreateATGLAccount.PurchaseTradeDomestic(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), '', '', CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentDiscountsGranted(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.TradeGoodsConsumption(), CreateATGLAccount.TradeGoodsPostReceiptInterim(), CreateATGLAccount.PurchaseTradeDomestic());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.DomesticPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), CreateATGLAccount.SalesRevenuesResourcesDomestic(), CreateATGLAccount.PurchaseTradeDomestic(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), '', '', CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentDiscountsGranted(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.TradeGoodsConsumption(), CreateATGLAccount.TradeGoodsPostReceiptInterim(), CreateATGLAccount.PurchaseTradeDomestic());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.EUPostingGroup(), NoVATPostingGroup(), CreateATGLAccount.SalesRevenuesTradeEU(), CreateATGLAccount.PurchaseTradeEU(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), '', '', CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentDiscountsGranted(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.TradeGoodsConsumption(), CreateATGLAccount.TradeGoodsPostReceiptInterim(), CreateATGLAccount.PurchaseTradeDomestic());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateATGLAccount.SalesRevenuesTradeEU(), CreateATGLAccount.PurchaseTradeEU(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), '', '', CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentDiscountsGranted(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.TradeGoodsConsumption(), CreateATGLAccount.TradeGoodsPostReceiptInterim(), CreateATGLAccount.PurchaseTradeDomestic());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.EUPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), CreateATGLAccount.SalesRevenuesResourcesEU(), CreateATGLAccount.PurchaseTradeEU(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), '', '', CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentDiscountsGranted(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.TradeGoodsConsumption(), CreateATGLAccount.TradeGoodsPostReceiptInterim(), CreateATGLAccount.PurchaseTradeDomestic());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.ExportPostingGroup(), NoVATPostingGroup(), CreateATGLAccount.SalesRevenuesTradeExport(), CreateATGLAccount.PurchaseTradeImport(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), '', '', CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentDiscountsGranted(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.TradeGoodsConsumption(), CreateATGLAccount.TradeGoodsPostReceiptInterim(), CreateATGLAccount.PurchaseTradeDomestic());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.RetailPostingGroup(), CreateATGLAccount.SalesRevenuesTradeExport(), CreateATGLAccount.PurchaseTradeImport(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), '', '', CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentDiscountsGranted(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.TradeGoodsConsumption(), CreateATGLAccount.TradeGoodsPostReceiptInterim(), CreateATGLAccount.PurchaseTradeDomestic());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroup.ExportPostingGroup(), CreatePostingGroup.ServicesPostingGroup(), CreateATGLAccount.SalesRevenuesResourcesExport(), CreateATGLAccount.PurchaseTradeImport(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), '', '', CreateGLAccount.PaymentDiscountsGranted(), CreateGLAccount.PaymentDiscountsGranted(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.DiscountReceivedTrade(), CreateATGLAccount.TradeGoodsConsumption(), CreateATGLAccount.TradeGoodsPostReceiptInterim(), CreateATGLAccount.PurchaseTradeDomestic());
        ContosoGenPostingSetup.SetOverwriteData(false);
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