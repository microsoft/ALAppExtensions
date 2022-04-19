/// <summary>
/// Codeunit Shpfy Orders API (ID 30165).
/// </summary>
codeunit 30165 "Shpfy Orders API"
{
    Access = Internal;

    trigger OnRun()
    var
        LocalShop: Record "Shpfy Shop";
    begin
        LocalShop.SetFilter("Shopify URL", '<>%1', '');
        if LocalShop.FindSet(false, false) then
            repeat
                SetShop(LocalShop);
                GetOrdersToImport(LocalShop);
            until LocalShop.Next() = 0;
    end;

    var
        Shop: Record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        GraphQLType: Enum "Shpfy GraphQL Type";

    /// <summary> 
    /// Get Orders To Import.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure GetOrdersToImport(ShopifyShop: Record "Shpfy Shop")
    var
        Orders: Record "Shpfy Order Header";
        OrderToImport: Record "Shpfy Orders to Import";
        RecRef: RecordRef;
        Id: BigInteger;
        LastSyncTime: DateTime;
        Parameters: Dictionary of [Text, Text];
        JArray: JsonArray;
        JOrders: JsonArray;
        JNode: JsonObject;
        JItem: JsonToken;
        JLineItem: JsonToken;
        JResponse: JsonToken;
        JValue: JsonValue;
        Cursor: Text;
        Tags: TextBuilder;
    begin
        CommunicationMgt.SetShop(ShopifyShop);

        Clear(OrderToImport);
        LastSyncTime := ShopifyShop.GetLastSyncTime("Shpfy Synchronization Type"::Orders);
        Parameters.Add('Time', Format(LastSyncTime, 0, 9));
        GraphQLType := GraphQLType::GetOrdersToImport;
        LastSyncTime := CurrentDateTime;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JsonHelper.GetJsonArray(JResponse, JOrders, 'data.orders.edges') then begin
                foreach JItem in JOrders do begin
                    Cursor := JsonHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                    if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                        Id := JsonHelper.GetValueAsBigInteger(JNode, 'legacyResourceId');
                        OrderToImport.SetCurrentKey(Id, "Shop Id");
                        OrderToImport.SetRange(Id, Id);
                        OrderToImport.SetRange("Shop Id", ShopifyShop."Shop Id");

                        if not OrderToImport.IsEmpty then
                            OrderToImport.DeleteAll();

                        Clear(OrderToImport);
                        OrderToImport.Id := Id;
                        OrderToImport."Shop Id" := ShopifyShop."Shop Id";
                        OrderToImport."Shop Code" := ShopifyShop.Code;
                        RecRef.GetTable(OrderToImport);
                        JsonHelper.GetValueIntoField(JNode, 'name', RecRef, OrderToImport.FieldNo("Order No."));
                        JsonHelper.GetValueIntoField(JNode, 'createdAt', RecRef, OrderToImport.FieldNo("Created At"));
                        JsonHelper.GetValueIntoField(JNode, 'updatedAt', RecRef, OrderToImport.FieldNo("Updated At"));
                        JsonHelper.GetValueIntoField(JNode, 'test', RecRef, OrderToImport.FieldNo(Test));
                        JsonHelper.GetValueIntoField(JNode, 'fullyPaid', RecRef, OrderToImport.FieldNo("Fully Paid"));
                        JsonHelper.GetValueIntoField(JNode, 'unpaid', RecRef, OrderToImport.FieldNo(Unpaid));
                        JsonHelper.GetValueIntoField(JNode, 'subtotalLineItemsQuantity', RecRef, OrderToImport.FieldNo("Total Quantity of Items"));
                        JsonHelper.GetValueIntoField(JNode, 'totalPriceSet.shopMoney.amount', RecRef, OrderToImport.FieldNo("Order Amount"));
                        JsonHelper.GetValueIntoField(JNode, 'totalPriceSet.shopMoney.currencyCode', RecRef, OrderToImport.FieldNo("Currency Code"));
                        RecRef.SetTable(OrderToImport);
                        OrderToImport."Risk Level" := ConvertToRiskLevel(JsonHelper.GetValueAsText(JNode, 'riskLevel'));
                        //Evaluate(OrderToImport."Risk Level", CommunicationMgt.ConvertToCleanOptionValue(JHelper.GetValueAsText(JNode, 'riskLevel')));
                        OrderToImport."Financial Status" := ConvertToFinancialStatus(JsonHelper.GetValueAsText(JNode, 'displayFinancialStatus'));
                        //Evaluate(OrderToImport."Financial Status", CommunicationMgt.ConvertToCleanOptionValue(JHelper.GetValueAsText(JNode, 'displayFinancialStatus')));
                        OrderToImport."Fulfillment Status" := ConvertToFulfillmentStatus(JsonHelper.GetValueAsText(JNode, 'displayFulfillmentStatus'));
                        //Evaluate(OrderToImport."Fulfillment Status", CommunicationMgt.ConvertToCleanOptionValue(JHelper.GetValueAsText(JNode, 'displayFulfillmentStatus')));
                        if JsonHelper.GetJsonArray(JNode, JArray, 'customAttributes') then
                            UpdateOrderAttributes(OrderToImport.Id, JArray);
                        if JsonHelper.GetJsonArray(JNode, JArray, 'tags') then begin
                            Clear(Tags);
                            foreach JLineItem in JArray do begin
                                Tags.Append(' [');
                                JValue := JLineItem.AsValue();
                                Tags.Append(JValue.AsText());
                                Tags.Append(']');
                            end;
                            OrderToImport.Tags := CopyStr(Tags.ToText(), 2, MaxStrLen(OrderToImport.Tags));
                        end;
                        Orders.SetRange("Shopify Order Id", Id);
                        if Orders.IsEmpty then
                            OrderToImport."Import Action" := OrderToImport."Import Action"::New
                        else
                            OrderToImport."Import Action" := OrderToImport."Import Action"::Update;

                        if not OrderToImport.Insert() then
                            OrderToImport.Modify();

                    end;
                end;
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', Cursor)
                else
                    Parameters.Add('After', Cursor);

                GraphQLType := GraphQLType::GetNextOrdersToImport;
            end else
                break;

        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.orders.pageInfo.hasNextPage');
        ShopifyShop.SetLastSyncTime("Shpfy Synchronization Type"::Orders, LastSyncTime);
        Commit();
    end;

    /// <summary> 
    /// Description for UpdateOrderAttributes.
    /// </summary>
    /// <param name="OrderId">Parameter of type BigInteger.</param>
    /// <param name="JAttributes">Parameter of type JsonArray.</param>
    local procedure UpdateOrderAttributes(OrderId: BigInteger; JAttributes: JsonArray)
    var
        OrderAttributte: Record "Shpfy Order Attribute";
        JItem: JsonToken;
    begin
        OrderAttributte.SetRange("Order Id", OrderId);
        if not OrderAttributte.IsEmpty then
            OrderAttributte.DeleteAll();

        foreach JItem in JAttributes do begin
            Clear(OrderAttributte);
            OrderAttributte."Order Id" := OrderId;
#pragma warning disable AA0139
            OrderAttributte."Key" := JsonHelper.GetValueAsText(JItem, 'key', MaxStrLen(OrderAttributte."Key"));
            OrderAttributte.Value := JsonHelper.GetValueAsText(JItem, 'value', MaxStrLen(OrderAttributte.Value));
#pragma warning restore AA0139
            OrderAttributte.Insert();
        end;
    end;


    /// <summary> 
    /// Description for AddOrderAttribute.
    /// </summary>
    /// <param name="OrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="KeyName">Parameter of type Text.</param>
    /// <param name="Value">Parameter of type Text.</param>
    internal procedure AddOrderAttribute(OrderHeader: Record "Shpfy Order Header"; KeyName: Text; Value: Text)
    var
        OrderAttributte: Record "Shpfy Order Attribute";
        Parameters: Dictionary of [Text, Text];
        JAttributes: JsonArray;
        JAttrib: JsonObject;
    begin
        Clear(OrderAttributte);
        OrderAttributte."Order Id" := OrderHeader."Shopify Order Id";
        OrderAttributte."Key" := CopyStr(KeyName, 1, MaxStrLen(OrderAttributte."Key"));
        OrderAttributte.Value := CopyStr(Value, 1, MaxStrLen(OrderAttributte.Value));
        if not OrderAttributte.Insert() then
            OrderAttributte.Modify();

        Clear(OrderAttributte);
        OrderAttributte.SetRange("Order Id", OrderHeader."Shopify Order Id");
        if OrderAttributte.FindSet(false, false) then
            repeat
                Clear(JAttrib);
                JAttrib.Add('key', OrderAttributte."Key");
                JAttrib.Add('value', OrderAttributte.Value.Replace('\', '\\').Replace('"', '\"'));
                JAttributes.Add(JAttrib);
            until OrderAttributte.Next() = 0;

        Parameters.Add('OrderId', Format(OrderHeader."Shopify Order Id"));
        Parameters.add('CustomAttributes', Format(JAttributes).Replace('"key"', 'key').Replace('"value"', 'value').Replace('\', '\\').Replace('"', '\"'));
        CommunicationMgt.ExecuteGraphQL(GraphQLType::UpdateOrderAttributes, Parameters);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    internal procedure SetShop(Code: Code[20])
    begin
        Clear(Shop);
        Shop.SetFilter(Code, Code);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        if ShopifyShop.GetFilters = '' then
            SetShop(ShopifyShop.Code)
        else begin
            Clear(Shop);
            Shop.CopyFilters(Shop);
        end;
    end;

    local procedure ConvertToFulfillmentStatus(Value: Text): Enum "Shpfy Order Fulfill. Status"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Order Fulfill. Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Order Fulfill. Status".FromInteger(Enum::"Shpfy Order Fulfill. Status".Ordinals().Get(Enum::"Shpfy Order Fulfill. Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Order Fulfill. Status"::" ");
    end;

    local procedure ConvertToFinancialStatus(Value: Text): Enum "Shpfy Financial Status"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Financial Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Financial Status".FromInteger(Enum::"Shpfy Financial Status".Ordinals().Get(Enum::"Shpfy Financial Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Financial Status"::" ");
    end;

    local procedure ConvertToRiskLevel(Value: Text): Enum "Shpfy Risk Level"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Risk Level".Names().Contains(Value) then
            exit(Enum::"Shpfy Risk Level".FromInteger(Enum::"Shpfy Risk Level".Ordinals().Get(Enum::"Shpfy Risk Level".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Risk Level"::" ");
    end;
}