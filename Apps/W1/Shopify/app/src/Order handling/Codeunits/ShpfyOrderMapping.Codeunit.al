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
        OrderShippingCharges: Record "Shpfy Order Shipping Charges";
        OrderTransaction: Record "Shpfy Order Transaction";
        ShipmentMethodMapping: Record "Shpfy Shipment Method Mapping";
        CustomerMapping: Codeunit "Shpfy Customer Mapping";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        CustomerTemplateCode: Code[20];
        IsHandled: Boolean;
        Priority: Integer;
        JCustomer: JsonObject;
    begin
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            CustomerTemplateCode := OrderHeader."Customer Template Code"
        else
            CustomerTemplateCode := OrderHeader."Customer Templ. Code";
#else
        CustomerTemplateCode := OrderHeader."Customer Templ. Code";
#endif
        CustomerMapping.SetShop(OrderHeader."Shop Code");
        if OrderHeader."Bill-to Customer No." = '' then begin
            OrderEvents.OnBeforeMapCustomer(OrderHeader, IsHandled);
            if not IsHandled then begin
                JCustomer.Add('Name', OrderHeader."Sell-to Customer Name");
                JCustomer.Add('Name2', OrderHeader."Sell-to Customer Name 2");
                JCustomer.Add('Address', OrderHeader."Sell-to Address");
                JCustomer.Add('Address2', OrderHeader."Sell-to Address 2");
                JCustomer.Add('PostCode', OrderHeader."Sell-to Post Code");
                JCustomer.Add('City', OrderHeader."Sell-to City");
                JCustomer.Add('County', OrderHeader."Sell-to County");
                JCustomer.Add('CountryCode', OrderHeader."Sell-to Country/Region Code");
                OrderHeader."Sell-to Customer No." := CustomerMapping.DoMapping(OrderHeader."Customer Id", JCustomer, OrderHeader."Shop Code", CustomerTemplateCode, AllowCreateCustomer);

                Clear(JCustomer);
                JCustomer.Add('Name', OrderHeader."Bill-to Name");
                JCustomer.Add('Name2', OrderHeader."Bill-to Name 2");
                JCustomer.Add('Address', OrderHeader."Bill-to Address");
                JCustomer.Add('Address2', OrderHeader."Bill-to Address 2");
                JCustomer.Add('PostCode', OrderHeader."Bill-to Post Code");
                JCustomer.Add('City', OrderHeader."Bill-to City");
                JCustomer.Add('County', OrderHeader."Bill-to County");
                JCustomer.Add('CountryCode', OrderHeader."Bill-to Country/Region Code");
                OrderHeader."Bill-to Customer No." := CustomerMapping.DoMapping(OrderHeader."Customer Id", JCustomer, OrderHeader."Shop Code", CustomerTemplateCode, AllowCreateCustomer);
                if (OrderHeader."Bill-to Customer No." = '') and (not Shop."Auto Create Unknown Customers") and (Shop."Default Customer No." <> '') then
                    OrderHeader."Bill-to Customer No." := Shop."Default Customer No.";

                if OrderHeader."Sell-to Customer No." = '' then
                    OrderHeader."Sell-to Customer No." := OrderHeader."Bill-to Customer No.";

                if OrderHeader."Bill-to Customer No." <> Shop."Default Customer No." then
                    OrderHeader."Bill-to Contact No." := FindContactNo(OrderHeader."Bill-to Contact Name", OrderHeader."Bill-to Customer No.");
                if OrderHeader."Sell-to Customer No." <> Shop."Default Customer No." then
                    OrderHeader."Sell-to Contact No." := FindContactNo(OrderHeader."Sell-to Contact Name", OrderHeader."Sell-to Customer No.");
                OrderHeader."Ship-to Contact No." := FindContactNo(OrderHeader."Ship-to Contact Name", OrderHeader."Sell-to Customer No.");

                OrderEvents.OnAfterMapCustomer(OrderHeader);
            end;
        end;

        if OrderHeader."Shipping Method Code" = '' then begin
            Clear(IsHandled);
            OrderEvents.OnBeforeMapShipmentMethod(OrderHeader, IsHandled);
            if not IsHandled then begin
                OrderShippingCharges.SetRange("Shopify Order Id", OrderHeader."Shopify Order Id");
                if OrderShippingCharges.FindFirst() then
                    if ShipmentMethodMapping.Get(OrderHeader."Shop Code", OrderShippingCharges.Title) then
                        OrderHeader."Shipping Method Code" := ShipmentMethodMapping."Shipment Method Code";
                OrderEvents.OnAfterMapShipmentMethod(OrderHeader);
            end;
        end;

        if OrderHeader."Payment Method Code" = '' then begin
            Clear(IsHandled);
            OrderEvents.OnBeforeMapPaymentMethod(OrderHeader, IsHandled);
            if not IsHandled then begin
                OrderTransaction.SetAutoCalcFields("Payment Priority", "Payment Method");
                OrderTransaction.SetRange("Shopify Order Id", OrderHeader."Shopify Order Id");
                OrderTransaction.SetCurrentKey("Shopify Order Id", Amount);
                OrderTransaction.SetRange(Status, "Shpfy Transaction Status"::Success);
                OrderTransaction.SetAscending(Amount, false);
                if OrderTransaction.FindSet(false, false) then begin
                    OrderHeader."Payment Method Code" := OrderTransaction."Payment Method";
                    Priority := OrderTransaction."Payment Priority";
                    repeat
                        if Priority < OrderTransaction."Payment Priority" then begin
                            OrderHeader."Payment Method Code" := OrderTransaction."Payment Method";
                            Priority := OrderTransaction."Payment Priority";
                        end;
                    until OrderTransaction.Next() = 0;
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

    local procedure FindContactNo(ContactName: Text[100]; CustomerNo: Code[20]): Code[20]
    var
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        if ContactName = '' then
            exit('');
        ContactBusinessRelation.SetRange("Link to Table", "Contact Business Relation Link To Table"::Customer);
        ContactBusinessRelation.SetRange("No.", CustomerNo);
        if ContactBusinessRelation.FindFirst() then begin
            Contact.SetRange(Type, "contact Type"::Person);
            Contact.SetRange("Company No.", ContactBusinessRelation."Contact No.");
            Contact.SetFilter(Name, '''@' + ContactName.Replace('''', '''''') + '''');
            if Contact.FindFirst() then
                exit(Contact."No.");
        end;
    end;
}