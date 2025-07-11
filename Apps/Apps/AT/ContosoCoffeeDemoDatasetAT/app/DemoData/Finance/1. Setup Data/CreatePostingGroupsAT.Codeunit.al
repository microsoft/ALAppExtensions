// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 11149 "Create Posting Groups AT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertGenProdPostingGroup();
    end;

    local procedure InsertGenProdPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateVATPostingGroupAT: codeunit "Create VAT Posting Group AT";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertGenProductPostingGroup(NoVATPostingGroup(), MiscDescriptionLbl, CreateVATPostingGroupAT.NOVAT());
        ContosoPostingGroup.SetOverwriteData(false);
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
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroup.ServicesPostingGroup(), '', '', CreateATGLAccount.TradeGoodsInventoryAdjustment(), CreateATGLAccount.TradeGoodsInventoryAdjustment(), '', '', '', '', '', '', CreateATGLAccount.TradeGoodsConsumption(), CreateATGLAccount.TradeGoodsPostReceiptInterim(), CreateATGLAccount.PurchaseTradeDomestic());

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

    var
        MiscDescriptionLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
        NoVATTok: Label 'NO VAT', MaxLength = 20;
}
