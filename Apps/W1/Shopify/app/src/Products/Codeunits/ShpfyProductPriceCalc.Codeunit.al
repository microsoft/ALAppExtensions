namespace Microsoft.Integration.Shopify;

using System.IO;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Document;
using Microsoft.Sales.Customer;
using Microsoft.Finance.VAT.Setup;

/// <summary>
/// Codeunit Shpfy Product Price Calc. (ID 30182).
/// </summary>
codeunit 30182 "Shpfy Product Price Calc."
{
    Access = Internal;
    EventSubscriberInstance = Manual;
    Permissions =
#if not CLEAN22
        tabledata "Config. Template Header" = r,
#endif
        tabledata Customer = rmid,
        tabledata Item = r,
        tabledata "Item Unit of Measure" = r,
        tabledata "Sales Header" = rimd,
        tabledata "Sales Line" = rmid,
        tabledata "VAT Posting Setup" = r;
    SingleInstance = true;

    var
        TempSalesHeader: Record "Sales Header" temporary;
        Shop: Record "Shpfy Shop";
        ProductEvents: Codeunit "Shpfy Product Events";


    /// <summary> 
    /// Calc Price.
    /// </summary>
    /// <param name="Item">Parameter of type Record Item.</param>
    /// <param name="ItemVariant">Parameter of type Code[20].</param>
    /// <param name="UnitOfMeasure">Parameter of type Code[20].</param>
    /// <param name="UnitCost">Parameter of type Decimal.</param>
    /// <param name="Price">Parameter of type Decimal.</param>
    /// <param name="ComparePrice">Parameter of type Decimal.</param>
    internal procedure CalcPrice(Item: Record Item; ItemVariant: Code[20]; UnitOfMeasure: Code[20]; var UnitCost: Decimal; var Price: Decimal; var ComparePrice: Decimal)
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
        TempSalesLine: Record "Sales Line" temporary;
        ShpfyUpdatePriceSouce: codeunit "Shpfy Update Price Source";
        IsHandled: Boolean;
    begin
        ProductEvents.OnBeforeCalculateUnitPrice(Item, ItemVariant, UnitOfMeasure, Shop, UnitCost, Price, ComparePrice, IsHandled);
        if not IsHandled then begin
            BindSubscription(ShpfyUpdatePriceSouce);
            if TempSalesHeader.FindFirst() then begin
                Clear(TempSalesLine);
                TempSalesLine."Document Type" := TempSalesHeader."Document Type";
                TempSalesLine."Document No." := TempSalesHeader."No.";
                TempSalesLine."System-Created Entry" := true;
                TempSalesLine.SetSalesHeader(TempSalesHeader);
                TempSalesLine.Validate(Type, TempSalesLine.Type::Item);
                TempSalesLine.Validate("No.", Item."No.");
                TempSalesLine.Validate("Variant Code", ItemVariant);
                TempSalesLine.Validate(Quantity, 1);
                if TempSalesLine."Unit of Measure Code" <> '' then
                    TempSalesLine.Validate("Unit of Measure Code", UnitOfMeasure);
                UnitCost := TempSalesLine."Unit Cost";
                ComparePrice := TempSalesLine."Unit Price";
                Price := TempSalesLine."Line Amount";
            end else begin
                UnitCost := Item."Unit Cost";
                Price := Item."Unit Price";
                if (UnitOfMeasure <> '') and ItemUnitofMeasure.Get(Item."No.", UnitOfMeasure) then begin
                    UnitCost := UnitCost * ItemUnitofMeasure."Qty. per Unit of Measure";
                    Price := Price * ItemUnitofMeasure."Qty. per Unit of Measure";
                end;
                ComparePrice := Price;
            end;
            UnbindSubscription(ShpfyUpdatePriceSouce);
            if ComparePrice <= Price then
                ComparePrice := 0;
        end;
        ProductEvents.OnAfterCalculateUnitPrice(Item, ItemVariant, UnitOfMeasure, Shop, UnitCost, Price, ComparePrice);
    end;

    /// <summary> 
    /// Create Temp Sales Header.
    /// </summary>
    local procedure CreateTempSalesHeader()
    begin
        Clear(TempSalesHeader);
        TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::Quote;
        TempSalesHeader."No." := Shop.Code;
        TempSalesHeader."Sell-to Customer No." := Shop.Code;
        TempSalesHeader."Bill-to Customer No." := Shop.Code;
        TempSalesHeader."Gen. Bus. Posting Group" := Shop."Gen. Bus. Posting Group";
        TempSalesHeader."VAT Bus. Posting Group" := Shop."VAT Bus. Posting Group";
        TempSalesHeader."Tax Area Code" := Shop."Tax Area Code";
        TempSalesHeader."Tax Liable" := Shop."Tax Liable";
        TempSalesHeader."VAT Country/Region Code" := Shop."VAT Country/Region Code";
        TempSalesHeader."Customer Price Group" := Shop."Customer Price Group";
        TempSalesHeader."Customer Disc. Group" := Shop."Customer Discount Group";
        TempSalesHeader."Customer Posting Group" := Shop."Customer Posting Group";
        TempSalesHeader."Prices Including VAT" := Shop."Prices Including VAT";
        TempSalesHeader."Allow Line Disc." := Shop."Allow Line Disc.";
        TempSalesHeader.Validate("Document Date", WorkDate());
        TempSalesHeader.Validate("Order Date", WorkDate());
        TempSalesHeader.Validate("Currency Code", Shop."Currency Code");
        TempSalesHeader.Insert(false);
    end;

    internal procedure PricesIncludingVAT(ShopCode: Code[20]): Boolean
    begin
        if Shop.Code <> ShopCode then
            Shop.Get(ShopCode);
        exit(Shop."Prices Including VAT");
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    internal procedure SetShop(Code: Code[20])
    var
        ShopifyShop: Record "Shpfy Shop";
    begin
        ShopifyShop.Get(Code);
        if (Shop.Code <> ShopifyShop.Code) or (Shop.SystemModifiedAt < ShopifyShop.SystemModifiedAt) then begin
            Shop := ShopifyShop;
            Clear(TempSalesHeader);
            TempSalesHeader.DeleteAll();
            CreateTempSalesHeader();
        end;
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        SetShop(ShopifyShop.Code);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure GetShop(Var ShopifyShopCode: Code[20])
    begin
        ShopifyShopCode := Shop.Code;
    end;


    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeGetSalesHeader', '', true, false)]
    local procedure GetHeader(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var IsHanded: Boolean)
    var
        CustomerNo: Code[20];
    begin
        if SalesLine."System-Created Entry" and (SalesLine."Document Type" = SalesLine."Document Type"::Quote) then begin
            CustomerNo := SalesLine."Sell-to Customer No.";
            if CustomerNo = '' then
                CustomerNo := SalesHeader."Sell-to Customer No.";
            SalesHeader := TempSalesHeader;
            IsHanded := true;
        end;
    end;
}