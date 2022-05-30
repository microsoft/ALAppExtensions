/// <summary>
/// Codeunit Shpfy Product Price Calc. (ID 30182).
/// </summary>
codeunit 30182 "Shpfy Product Price Calc."
{
    Access = Internal;
    EventSubscriberInstance = Manual;
    Permissions =
        tabledata "Config. Template Header" = r,
        tabledata Customer = rmid,
        tabledata Item = r,
        tabledata "Item Unit of Measure" = r,
        tabledata "Sales Header" = rimd,
        tabledata "Sales Line" = rmid,
        tabledata "VAT Posting Setup" = r;
    SingleInstance = true;

    var
        TempCustomer: Record Customer temporary;
        TempSalesHeader: Record "Sales Header" temporary;
        Shop: Record "Shpfy Shop";
        Events: Codeunit "Shpfy Product Events";


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
        Customer: Record Customer;
        ItemUOM: Record "Item Unit of Measure";
        TempSalesLine: Record "Sales Line" temporary;
        PriceCalc: Codeunit "Shpfy Product Price Calc.";
        IsHandled: Boolean;
    begin
        Events.OnBeforeCalculateUnitPrice(Item, ItemVariant, UnitOfMeasure, Shop, UnitCost, Price, ComparePrice, IsHandled);
        if not IsHandled then begin
            if TempSalesHeader.FindFirst() then begin
                if BindSubscription(PriceCalc) then;
                Customer := TempCustomer;
                Customer.Insert(false);
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
                Customer.Delete(false);
                if UnbindSubscription(PriceCalc) then;
            end else begin
                UnitCost := Item."Unit Cost";
                Price := Item."Unit Price";
                if (UnitOfMeasure <> '') and ItemUOM.Get(Item."No.", UnitOfMeasure) then begin
                    UnitCost := UnitCost * ItemUOM."Qty. per Unit of Measure";
                    Price := Price * ItemUOM."Qty. per Unit of Measure";
                end;
                ComparePrice := Price;
            end;
            if ComparePrice <= Price then
                ComparePrice := 0;
            Events.OnAfterCalculateUnitPrice(Item, ItemVariant, UnitOfMeasure, Shop, UnitCost, Price, ComparePrice);
        end;
    end;

    /// <summary> 
    /// Create Temp Sales Header.
    /// </summary>
    local procedure CreateTempSalesHeader()
    var
        PostingSetupMgt: Codeunit PostingSetupManagement;
    begin
        CreateTempCustomer(Shop.Code);
        if Shop."Customer Price Group" <> '' then
            TempCustomer."Customer Price Group" := Shop."Customer Price Group";
        if Shop."Customer Discount Group" <> '' then
            TempCustomer."Customer Disc. Group" := Shop."Customer Discount Group";
        Clear(TempSalesHeader);
        TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::Quote;
        TempSalesHeader."No." := Shop.Code;
        TempSalesHeader."Sell-to Customer No." := Shop.Code;
        TempCustomer.TestField("Gen. Bus. Posting Group");
        TempSalesHeader."Gen. Bus. Posting Group" := TempCustomer."Gen. Bus. Posting Group";
        TempSalesHeader."VAT Bus. Posting Group" := TempCustomer."VAT Bus. Posting Group";
        TempSalesHeader."Tax Area Code" := TempCustomer."Tax Area Code";
        TempSalesHeader."Tax Liable" := TempCustomer."Tax Liable";
        TempSalesHeader."VAT Country/Region Code" := TempCustomer."Country/Region Code";
        TempSalesHeader."Shipping Advice" := TempCustomer."Shipping Advice";
        TempSalesHeader."Customer Price Group" := TempCustomer."Customer Price Group";
        TempSalesHeader."Customer Disc. Group" := TempCustomer."Customer Disc. Group";
        TempSalesHeader."Bill-to Customer No." := Shop.Code;
        PostingSetupMgt.CheckCustPostingGroupReceivablesAccount(TempCustomer."Customer Posting Group");
        TempSalesHeader."Customer Posting Group" := TempCustomer."Customer Posting Group";
        TempSalesHeader."Payment Terms Code" := TempCustomer."Payment Terms Code";
        TempSalesHeader."Prices Including VAT" := TempCustomer."Prices Including VAT";
        TempSalesHeader."Allow Line Disc." := TempCustomer."Allow Line Disc.";
        TempSalesHeader."Tax Area Code" := TempCustomer."Tax Area Code";
        TempSalesHeader."Tax Liable" := TempCustomer."Tax Liable";
        TempSalesHeader."Responsibility Center" := TempCustomer."Responsibility Center";
        TempSalesHeader."Shipping Agent Code" := TempCustomer."Shipping Agent Code";
        TempSalesHeader."Shipping Agent Service Code" := TempCustomer."Shipping Agent Service Code";
        TempSalesHeader.Validate("Document Date", WorkDate());
        TempSalesHeader.Validate("Order Date", WorkDate());
        TempSalesHeader.Validate("Currency Code", Shop."Currency Code");
        TempSalesHeader.Insert(false);
    end;

    local procedure CreateTempCustomer(ShopCode: code[20])
    var
        ShopifyShop: REcord "Shpfy Shop";
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        RecRef: RecordRef;
    begin
        if TempCustomer."No." <> ShopCode then begin
            Clear(TempCustomer);
            if not TempCustomer.Get(ShopCode) then begin
                ShopifyShop.Get(ShopCode);
                if (ShopifyShop."Customer Template Code" <> '') and ConfigTemplateHeader.Get(ShopifyShop."Customer Template Code") then begin
                    TempCustomer."No." := ShopCode;
                    TempCustomer.Insert();
                    RecRef.GetTable(TempCustomer);
                    ConfigTemplateManagement.ApplyTemplateLinesWithoutValidation(ConfigTemplateHeader, RecRef);
                    RecRef.SetTable(TempCustomer);
                    TempCustomer.Modify();
                end;
            end;
        end;
    end;

    internal procedure PricesIncludingVAT(ShopCode: Code[20]): Boolean
    begin
        CreateTempCustomer(ShopCode);
        exit(TempCustomer."Prices Including VAT");
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    internal procedure SetShop(Code: Code[20])
    var
        ShpfyShop: Record "Shpfy Shop";
    begin
        ShpfyShop.Get(Code);
        if (Shop.Code <> ShpfyShop.Code) or (Shop.SystemModifiedAt < ShpfyShop.SystemModifiedAt) then begin
            Shop := ShpfyShop;
            Clear(TempSalesHeader);
            TempSalesHeader.DeleteAll();
            Clear(TempCustomer);
            TempCustomer.DeleteAll();
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