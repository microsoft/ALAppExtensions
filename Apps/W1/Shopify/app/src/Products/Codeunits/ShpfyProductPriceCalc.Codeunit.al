namespace Microsoft.Integration.Shopify;

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
    SingleInstance = true;
    Permissions =
        tabledata Customer = rmid,
        tabledata Item = r,
        tabledata "Item Unit of Measure" = r,
        tabledata "Sales Header" = rimd,
        tabledata "Sales Line" = rmid,
        tabledata "VAT Posting Setup" = r;

    var
        TempSalesHeader: Record "Sales Header" temporary;
        Shop: Record "Shpfy Shop";
        Catalog: Record "Shpfy Catalog";
        ProductEvents: Codeunit "Shpfy Product Events";
        GenBusPostingGroup: Code[20];
        VATBusPostingGroup: Code[20];
        TaxAreaCode: Code[20];
        TaxLiable: Boolean;
        VATCountryRegionCode: Code[10];
        CustomerPriceGroup: Code[10];
        CustomerNo: Code[20];
        CustomerDiscGroup: Code[20];
        CustomerPostingGroup: Code[20];
        PricesIncludingVAT: Boolean;
        AllowLineDisc: Boolean;


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
        ProductEvents.OnBeforeCalculateUnitPrice(Item, ItemVariant, UnitOfMeasure, Shop, Catalog, UnitCost, Price, ComparePrice, IsHandled);
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
        ProductEvents.OnAfterCalculateUnitPrice(Item, ItemVariant, UnitOfMeasure, Shop, Catalog, UnitCost, Price, ComparePrice);
    end;

    /// <summary> 
    /// Create Temp Sales Header.
    /// </summary>
    local procedure CreateTempSalesHeader()
    var
        Customer: Record Customer;
    begin
        Clear(TempSalesHeader);
        TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::Quote;
        TempSalesHeader."No." := Shop.Code;
        if CustomerNo <> '' then begin
            Customer.Get(CustomerNo);
            TempSalesHeader."Sell-to Customer No." := CustomerNo;
            TempSalesHeader."Bill-to Customer No." := CustomerNo;
            TempSalesHeader."Customer Price Group" := Customer."Customer Price Group";
            TempSalesHeader."Customer Disc. Group" := Customer."Customer Disc. Group";
            TempSalesHeader."Allow Line Disc." := Customer."Allow Line Disc.";
        end
        else begin
            TempSalesHeader."Sell-to Customer No." := Shop.Code;
            TempSalesHeader."Bill-to Customer No." := Shop.Code;
            TempSalesHeader."Customer Price Group" := CustomerPriceGroup;
            TempSalesHeader."Customer Disc. Group" := CustomerDiscGroup;
            TempSalesHeader."Allow Line Disc." := AllowLineDisc;
        end;

        TempSalesHeader."Gen. Bus. Posting Group" := GenBusPostingGroup;
        TempSalesHeader."VAT Bus. Posting Group" := VATBusPostingGroup;
        TempSalesHeader."Tax Area Code" := TaxAreaCode;
        TempSalesHeader."Tax Liable" := TaxLiable;
        TempSalesHeader."VAT Country/Region Code" := VATCountryRegionCode;
        TempSalesHeader."Customer Posting Group" := CustomerPostingGroup;
        TempSalesHeader."Prices Including VAT" := PricesIncludingVAT;
        TempSalesHeader.Validate("Document Date", WorkDate());
        TempSalesHeader.Validate("Order Date", WorkDate());
        TempSalesHeader.Validate("Currency Code", Shop."Currency Code");
        TempSalesHeader.Insert(false);
    end;

    internal procedure DoPricesIncludingVAT(ShopCode: Code[20]): Boolean
    begin
        if Shop.Code <> ShopCode then
            Shop.Get(ShopCode);
        exit(Shop."Prices Including VAT");
    end;

    internal procedure GetCurrencyCode(): Code[10]
    begin
        exit(Shop."Currency Code");
    end;

    internal procedure GetAllowLineDisc(): Boolean
    begin
        exit(AllowLineDisc);
    end;

    internal procedure GetPricesIncludingVAT(): Boolean
    begin
        exit(PricesIncludingVAT);
    end;

    internal procedure GetVATBusPostingGroup(): Code[20]
    begin
        exit(VATBusPostingGroup);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        if (Shop.Code <> ShopifyShop.Code) or (Shop.SystemModifiedAt < ShopifyShop.SystemModifiedAt) then begin
            Shop := ShopifyShop;
            SetParameters(Shop);
            Clear(TempSalesHeader);
            TempSalesHeader.DeleteAll();
            CreateTempSalesHeader();
        end;
    end;

    internal procedure SetShopAndCatalog(ShopifyShop: Record "Shpfy Shop"; ShopifyCatalog: Record "Shpfy Catalog")
    begin
        if (Shop.Code <> ShopifyShop.Code) or (Shop.SystemModifiedAt < ShopifyShop.SystemModifiedAt) then
            Shop := ShopifyShop;

        if (Catalog.Id <> ShopifyCatalog.Id) or (Catalog.SystemModifiedAt < ShopifyCatalog.SystemModifiedAt) then
            Catalog := ShopifyCatalog;

        SetParameters(Catalog);
        Clear(TempSalesHeader);
        TempSalesHeader.DeleteAll();
        CreateTempSalesHeader();
    end;

    local procedure SetParameters(SourceRec: Variant)
    var
        ShopifyShop: Record "Shpfy Shop";
        ShopifyCatalog: Record "Shpfy Catalog";
        SourceRecordRef: RecordRef;
    begin
        if SourceRec.IsRecord() then
            SourceRecordRef.GetTable(SourceRec);

        case SourceRecordRef.Number() of
            Database::"Shpfy Shop":
                begin
                    SourceRecordRef.SetTable(ShopifyShop);
                    GenBusPostingGroup := ShopifyShop."Gen. Bus. Posting Group";
                    VATBusPostingGroup := ShopifyShop."VAT Bus. Posting Group";
                    TaxAreaCode := ShopifyShop."Tax Area Code";
                    TaxLiable := ShopifyShop."Tax Liable";
                    VATCountryRegionCode := ShopifyShop."VAT Country/Region Code";
                    CustomerPriceGroup := ShopifyShop."Customer Price Group";
                    CustomerDiscGroup := ShopifyShop."Customer Discount Group";
                    CustomerPostingGroup := ShopifyShop."Customer Posting Group";
                    PricesIncludingVAT := ShopifyShop."Prices Including VAT";
                    AllowLineDisc := ShopifyShop."Allow Line Disc.";
                end;
            Database::"Shpfy Catalog":
                begin
                    SourceRecordRef.SetTable(ShopifyCatalog);
                    GenBusPostingGroup := ShopifyCatalog."Gen. Bus. Posting Group";
                    VATBusPostingGroup := ShopifyCatalog."VAT Bus. Posting Group";
                    TaxAreaCode := ShopifyCatalog."Tax Area Code";
                    TaxLiable := ShopifyCatalog."Tax Liable";
                    VATCountryRegionCode := ShopifyCatalog."VAT Country/Region Code";
                    CustomerPriceGroup := ShopifyCatalog."Customer Price Group";
                    CustomerDiscGroup := ShopifyCatalog."Customer Discount Group";
                    CustomerPostingGroup := ShopifyCatalog."Customer Posting Group";
                    PricesIncludingVAT := ShopifyCatalog."Prices Including VAT";
                    AllowLineDisc := ShopifyCatalog."Allow Line Disc.";
                    CustomerNo := ShopifyCatalog."Customer No.";
                end;
        end;
    end;
}