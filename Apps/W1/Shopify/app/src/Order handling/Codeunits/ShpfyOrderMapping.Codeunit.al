namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;
using Microsoft.CRM.Contact;
using Microsoft.CRM.BusinessRelation;

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

        if not OrderHeader.B2B then begin
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
                end
        end else
            if Shop."Company Import From Shopify" = Shop."Company Import From Shopify"::None then begin
                if OrderHeader."Bill-to Customer No." = '' then
                    OrderHeader."Bill-to Customer No." := Shop."Default Company No.";
                if OrderHeader."Sell-to Customer No." = '' then
                    OrderHeader."Sell-to Customer No." := Shop."Default Company No.";
                OrderHeader.Modify();
            end;

        if not OrderHeader.B2B then
            Result := MapHeaderFields(OrderHeader, Shop, Shop."Auto Create Unknown Customers" and (Shop."Customer Import From Shopify" <> "Shpfy Customer Import Range"::None))
        else
            Result := MapB2BHeaderFields(OrderHeader, Shop, Shop."Auto Create Unknown Companies" and (Shop."Company Import From Shopify" <> "Shpfy Company Import Range"::None));

        OrderLine.SetRange("Shopify Order Id", OrderHeader."Shopify Order Id");
        if OrderLine.FindSet(true) then
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
        CustomerMapping: Codeunit "Shpfy Customer Mapping";
        CustomerTemplateCode: Code[20];
        IsHandled: Boolean;
        JCustomer: JsonObject;
    begin
        CustomerTemplateCode := OrderHeader."Customer Templ. Code";
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

        MapShippingMethodCode(OrderHeader);
        MapShippingAgent(OrderHeader);
        MapPaymentMethodCode(OrderHeader);
        OrderHeader.Modify();
        exit((OrderHeader."Bill-to Customer No." <> '') and (OrderHeader."Sell-to Customer No." <> ''));
    end;

    internal procedure MapB2BHeaderFields(var OrderHeader: Record "Shpfy Order Header"; Shop: Record "Shpfy Shop"; AllowCreateCompany: Boolean): Boolean
    var
        CompanyMapping: Codeunit "Shpfy Company Mapping";
        CustomerTemplateCode: Code[20];
        IsHandled: Boolean;
    begin
        CustomerTemplateCode := OrderHeader."Customer Templ. Code";

        CompanyMapping.SetShop(OrderHeader."Shop Code");
        if OrderHeader."Bill-to Customer No." = '' then begin
            OrderEvents.OnBeforeMapCompany(OrderHeader, IsHandled);
            if not IsHandled then begin
                OrderHeader."Sell-to Customer No." := CompanyMapping.DoMapping(OrderHeader."Company Id", CustomerTemplateCode, AllowCreateCompany);
                OrderHeader."Bill-to Customer No." := OrderHeader."Sell-to Customer No.";

                if (OrderHeader."Bill-to Customer No." = '') and (not Shop."Auto Create Unknown Customers") and (Shop."Default Company No." <> '') then
                    OrderHeader."Bill-to Customer No." := Shop."Default Company No.";
                if OrderHeader."Sell-to Customer No." = '' then
                    OrderHeader."Sell-to Customer No." := OrderHeader."Bill-to Customer No.";

                if OrderHeader."Bill-to Customer No." <> Shop."Default Company No." then
                    OrderHeader."Bill-to Contact No." := FindContactNo(OrderHeader."Bill-to Contact Name", OrderHeader."Bill-to Customer No.");
                if OrderHeader."Sell-to Customer No." <> Shop."Default Company No." then
                    OrderHeader."Sell-to Contact No." := FindContactNo(OrderHeader."Sell-to Contact Name", OrderHeader."Sell-to Customer No.");

                OrderHeader."Ship-to Contact No." := FindContactNo(OrderHeader."Ship-to Contact Name", OrderHeader."Sell-to Customer No.");
                OrderEvents.OnAfterMapCompany(OrderHeader);
            end;
        end;

        MapShippingMethodCode(OrderHeader);
        MapShippingAgent(OrderHeader);
        MapPaymentMethodCode(OrderHeader);
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

    local procedure MapShippingMethodCode(var OrderHeader: Record "Shpfy Order Header")
    var
        OrderShippingCharges: Record "Shpfy Order Shipping Charges";
        ShipmentMethodMapping: Record "Shpfy Shipment Method Mapping";
        IsHandled: Boolean;
    begin
        if OrderHeader."Shipping Method Code" = '' then begin
            OrderEvents.OnBeforeMapShipmentMethod(OrderHeader, IsHandled);
            if not IsHandled then begin
                OrderShippingCharges.SetRange("Shopify Order Id", OrderHeader."Shopify Order Id");
                if OrderShippingCharges.FindFirst() then
                    if ShipmentMethodMapping.Get(OrderHeader."Shop Code", OrderShippingCharges.Title) then
                        OrderHeader."Shipping Method Code" := ShipmentMethodMapping."Shipment Method Code";
                OrderEvents.OnAfterMapShipmentMethod(OrderHeader);
            end;
        end;
    end;

    local procedure MapShippingAgent(var OrderHeader: Record "Shpfy Order Header")
    var
        OrderShippingCharges: Record "Shpfy Order Shipping Charges";
        ShipmentMethodMapping: Record "Shpfy Shipment Method Mapping";
        IsHandled: Boolean;
    begin
        if OrderHeader."Shipping Agent Code" = '' then begin
            OrderEvents.OnBeforeMapShipmentAgent(OrderHeader, IsHandled);
            if not IsHandled then begin
                OrderShippingCharges.SetRange("Shopify Order Id", OrderHeader."Shopify Order Id");
                if OrderShippingCharges.FindFirst() then
                    if ShipmentMethodMapping.Get(OrderHeader."Shop Code", OrderShippingCharges.Title) then begin
                        OrderHeader."Shipping Agent Code" := ShipmentMethodMapping."Shipping Agent Code";
                        OrderHeader."Shipping Agent Service Code" := ShipmentMethodMapping."Shipping Agent Service Code";
                    end;
                OrderEvents.OnAfterMapShipmentAgent(OrderHeader);
            end;
        end;
    end;

    local procedure MapPaymentMethodCode(var OrderHeader: Record "Shpfy Order Header")
    var
        OrderTransaction: Record "Shpfy Order Transaction";
        IsHandled: Boolean;
        PaymentMethods: List of [Code[10]];
    begin
        if OrderHeader."Payment Method Code" = '' then begin
            OrderEvents.OnBeforeMapPaymentMethod(OrderHeader, IsHandled);
            if not IsHandled then begin
                OrderTransaction.SetAutoCalcFields("Payment Method");
                OrderTransaction.SetRange("Shopify Order Id", OrderHeader."Shopify Order Id");
                OrderTransaction.SetRange(Status, "Shpfy Transaction Status"::Success);
                if OrderTransaction.FindSet() then begin
                    repeat
                        if not PaymentMethods.Contains(OrderTransaction."Payment Method") then
                            PaymentMethods.Add(OrderTransaction."Payment Method");

                        if PaymentMethods.Count > 1 then begin
                            OrderEvents.OnAfterMapPaymentMethod(OrderHeader);
                            exit;
                        end;
                    until OrderTransaction.Next() = 0;
                    OrderHeader."Payment Method Code" := PaymentMethods.Get(1);
                end;
            end;
            OrderEvents.OnAfterMapPaymentMethod(OrderHeader);
        end;
    end;
}