/// <summary>
/// Codeunit Shpfy Order Mapping (ID 30163).
/// </summary>
codeunit 30163 "Shpfy Order Mapping"
{
    Access = Internal;
    Permissions =
        tabledata Item = rim,
        tabledata "Item Variant" = rim;

    var
        OrderEvents: Codeunit "Shpfy Order Events";

    /// <summary> 
    /// Description for DoMapping.
    /// </summary>
    /// <param name="OrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure DoMapping(var OrderHeader: Record "Shpfy Order Header") Result: Boolean
    var
        CustomerTemplate: Record "Shpfy Customer Template";
        OrderLine: Record "Shpfy Order Line";
        Shop: Record "Shpfy Shop";
    begin
        Shop.Get(OrderHeader."Shop Code");

        if CustomerTemplate.Get(OrderHeader."Shop Code", OrderHeader."Ship-to Country/Region Code") then begin
            if CustomerTemplate."Default Customer No." <> '' then begin
                OrderHeader."Bill-to Customer No." := CustomerTemplate."Default Customer No.";
                OrderHeader."Sell-to Customer No." := CustomerTemplate."Default Customer No.";
                OrderHeader.Modify();
            end;
        end else
            if Shop."Customer Import From Shopify" = Shop."Customer Import From Shopify"::None then begin
                if OrderHeader."Bill-to Customer No." = '' then
                    OrderHeader."Bill-to Customer No." := Shop."Default Customer No.";
                if OrderHeader."Sell-to Customer No." = '' then
                    OrderHeader."Sell-to Customer No." := Shop."Default Customer No.";
                OrderHeader.Modify();
            end;

        Result := MapHeaderFields(OrderHeader, Shop, Shop."Auto Create Unknown Customers" and (Shop."Customer Import From Shopify" <> "Shpfy Customer Import Range"::None));

        OrderLine.SetRange("Shopify Order Id", OrderHeader."Shopify Order Id");
        if OrderLine.FindSet(true, false) then
            repeat
                if OrderLine.Tip then
                    Result := Result and (Shop."Tip Account" <> '')
                else
                    if OrderLine."Gift Card" then
                        Result := Result and (Shop."Sold Gift Card Account" <> '')
                    else
                        Result := Result and MapVariant(OrderLine, Shop);
            until OrderLine.Next() = 0;
    end;

    /// <summary> 
    /// Description for MapHeaderFields.
    /// </summary>
    /// <param name="OrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="AllowCreateCustomer">Parameter of type Boolean.</param>
    /// <returns>Return variable "Boolean".</returns>
    internal procedure MapHeaderFields(var OrderHeader: Record "Shpfy Order Header"; Shop: Record "Shpfy Shop"; AllowCreateCustomer: Boolean): Boolean
    var
        ShipmentCost: Record "Shpfy Order Shipping Charges";
        Transaction: Record "Shpfy Order Transaction";
        ShipmentMethod: Record "Shpfy Shipment Method Mapping";
        CustomerMapping: Codeunit "Shpfy Customer Mapping";
        IsHandled: Boolean;
        Priority: Integer;
        JCustomer: JsonObject;
    begin
        CustomerMapping.SetShop(OrderHeader."Shop Code");
        if OrderHeader."Bill-to Customer No." = '' then
            if AllowCreateCustomer then begin
                OrderEvents.OnBeforeMapCustomer(OrderHeader, IsHandled);
                if not IsHandled then begin
                    JCustomer.Add('Name', OrderHeader."Bill-to Name");
                    JCustomer.Add('Name2', OrderHeader."Bill-to Name 2");
                    JCustomer.Add('Address', OrderHeader."Bill-to Address");
                    JCustomer.Add('Address2', OrderHeader."Bill-to Address 2");
                    JCustomer.Add('PostCode', OrderHeader."Bill-to Post Code");
                    JCustomer.Add('City', OrderHeader."Bill-to City");
                    JCustomer.Add('County', OrderHeader."Bill-to County");
                    JCustomer.Add('CountryCode', OrderHeader."Bill-to Country/Region Code");
                    OrderHeader."Bill-to Customer No." := CustomerMapping.DoMapping(OrderHeader."Customer Id", JCustomer, OrderHeader."Shop Code", OrderHeader."Customer Template Code", AllowCreateCustomer);
                    if (OrderHeader."Bill-to Customer No." = '') and (not Shop."Auto Create Unknown Customers") and (Shop."Default Customer No." <> '') then
                        OrderHeader."Bill-to Customer No." := Shop."Default Customer No.";
                    OrderHeader."Sell-to Customer No." := OrderHeader."Bill-to Customer No.";
                    OrderEvents.OnAfterMapCustomer(OrderHeader);
                end;
            end;

        if OrderHeader."Shipping Method Code" = '' then begin
            Clear(IsHandled);
            OrderEvents.OnBeforeMapShipmentMethod(OrderHeader, IsHandled);
            if not IsHandled then begin
                ShipmentCost.SetRange("Shopify Order Id", OrderHeader."Shopify Order Id");
                if ShipmentCost.FindFirst() then
                    if ShipmentMethod.Get(OrderHeader."Shop Code", ShipmentCost.Title) then
                        OrderHeader."Shipping Method Code" := ShipmentMethod."Shipment Method Code";
                OrderEvents.OnAfterMapShipmentMethod(OrderHeader);
            end;
        end;

        if OrderHeader."Payment Method Code" = '' then begin
            Clear(IsHandled);
            OrderEvents.OnBeforeMapPaymentMethod(OrderHeader, IsHandled);
            if not IsHandled then begin
                Transaction.SetAutoCalcFields("Payment Priority", "Payment Method");
                Transaction.SetRange("Shopify Order Id", OrderHeader."Shopify Order Id");
                Transaction.SetCurrentKey("Shopify Order Id", Amount);
                Transaction.SetRange(Status, "Shpfy Transaction Status"::Success);
                Transaction.SetAscending(Amount, false);
                if Transaction.FindSet(false, false) then begin
                    OrderHeader."Payment Method Code" := Transaction."Payment Method";
                    Priority := Transaction."Payment Priority";
                    repeat
                        if Priority < Transaction."Payment Priority" then begin
                            OrderHeader."Payment Method Code" := Transaction."Payment Method";
                            Priority := Transaction."Payment Priority";
                        end;
                    until Transaction.Next() = 0;
                end;
                OrderEvents.OnAfterMapPaymentMethod(OrderHeader);
            end;
        end;

        OrderHeader.Modify();
        exit((OrderHeader."Bill-to Customer No." <> '') and (OrderHeader."Sell-to Customer No." <> ''));
    end;

    /// <summary> 
    /// Description for MapVariant.
    /// </summary>
    /// <param name="ShopifyOrderLine">Parameter of type Record "Shopify Order Line".</param>
    /// <param name="SHop">Parameter of type Record "Shopify Shop".</param>
    /// <returns>Return variable "Boolean".</returns>
    local procedure MapVariant(var ShopifyOrderLine: Record "Shpfy Order Line"; SHop: Record "Shpfy Shop"): Boolean
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ShopifyVariant: Record "Shpfy Variant";
        ProductImport: Codeunit "Shpfy Product Import";
    begin
        if not ShopifyVariant.Get(ShopifyOrderLine."Shopify Variant Id") or IsNullGuid(ShopifyVariant."Item SystemId") then begin
            ProductImport.SetShop(Shop);
            ProductImport.SetProduct(ShopifyOrderLine."Shopify Product Id");
            ProductImport.Run();
        end;

        if ShopifyVariant.Get(ShopifyOrderLine."Shopify Variant Id") then begin
            if (not IsNullGuid(ShopifyVariant."Item SystemId")) and Item.GetBySystemId(ShopifyVariant."Item SystemId") then
                ShopifyOrderLine."Item No." := Item."No.";
            if (not IsNullGuid(ShopifyVariant."Item Variant SystemId")) and ItemVariant.GetBySystemId(ShopifyVariant."Item Variant SystemId") then
                ShopifyOrderLine."Variant Code" := ItemVariant.Code;
            case ShopifyVariant."UoM Option Id" of
                1:
                    if StrLen(ShopifyVariant."Option 1 Value") <= MaxStrLen(ShopifyOrderLine."Unit of Measure Code") then
                        ShopifyOrderLine."Unit of Measure Code" := CopyStr(ShopifyVariant."Option 1 Value", 1, MaxStrLen(ShopifyOrderLine."Unit of Measure Code"));
                2:
                    if StrLen(ShopifyVariant."Option 2 Value") <= MaxStrLen(ShopifyOrderLine."Unit of Measure Code") then
                        ShopifyOrderLine."Unit of Measure Code" := CopyStr(ShopifyVariant."Option 2 Value", 1, MaxStrLen(ShopifyOrderLine."Unit of Measure Code"));
                3:
                    if StrLen(ShopifyVariant."Option 3 Value") <= MaxStrLen(ShopifyOrderLine."Unit of Measure Code") then
                        ShopifyOrderLine."Unit of Measure Code" := CopyStr(ShopifyVariant."Option 3 Value", 1, MaxStrLen(ShopifyOrderLine."Unit of Measure Code"));
            end;
        end;
        if (ShopifyOrderLine."Unit of Measure Code" = '') and (ShopifyOrderLine."Item No." <> '') then
            if Item.Get(ShopifyOrderLine."Item No.") then
                ShopifyOrderLine."Unit of Measure Code" := Item."Sales Unit of Measure";
        ShopifyOrderLine.Modify();
        exit(ShopifyOrderLine."Item No." <> '');
    end;
}