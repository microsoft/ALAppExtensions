namespace Microsoft.Integration.Shopify;

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
        if LocalShop.FindSet(false) then
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
        OrdersToImport: Record "Shpfy Orders to Import";
        LastSyncTime: DateTime;
        Cursor: Text;
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
    begin
        CommunicationMgt.SetShop(ShopifyShop);

        Clear(OrdersToImport);
        LastSyncTime := ShopifyShop.GetLastSyncTime("Shpfy Synchronization Type"::Orders);
        Parameters.Add('Time', Format(LastSyncTime, 0, 9));
        if LastSyncTime = 0DT then
            GraphQLType := "Shpfy GraphQL Type"::GetOpenOrdersToImport
        else
            GraphQLType := "Shpfy GraphQL Type"::GetOrdersToImport;
        LastSyncTime := CurrentDateTime;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JResponse.IsObject() then
                if ExtractShopifyOrdersToImport(ShopifyShop, JResponse.AsObject(), Cursor) then begin
                    if Parameters.ContainsKey('After') then
                        Parameters.Set('After', Cursor)
                    else
                        Parameters.Add('After', Cursor);
                    if LastSyncTime = 0DT then
                        GraphQLType := "Shpfy GraphQL Type"::GetNextOpenOrdersToImport
                    else
                        GraphQLType := "Shpfy GraphQL Type"::GetNextOrdersToImport;
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
        OrderAttribute: Record "Shpfy Order Attribute";
        JItem: JsonToken;
    begin
        OrderAttribute.SetRange("Order Id", OrderId);
        if not OrderAttribute.IsEmpty then
            OrderAttribute.DeleteAll();

        foreach JItem in JAttributes do begin
            Clear(OrderAttribute);
            OrderAttribute."Order Id" := OrderId;
#pragma warning disable AA0139
            OrderAttribute."Key" := JsonHelper.GetValueAsText(JItem, 'key', MaxStrLen(OrderAttribute."Key"));
#pragma warning restore AA0139
            OrderAttribute.Value := CopyStr(JsonHelper.GetValueAsText(JItem, 'value').Replace('\\', '\').Replace('\"', '"'), 1, MaxStrLen(OrderAttribute.Value));
            OrderAttribute.Insert();
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
        OrderAttribute: Record "Shpfy Order Attribute";
        Parameters: Dictionary of [Text, Text];
        JAttributes: JsonArray;
        JAttrib: JsonObject;
    begin
        if CommunicationMgt.GetTestInProgress() then
            exit;
        Clear(OrderAttribute);
        OrderAttribute."Order Id" := OrderHeader."Shopify Order Id";
        OrderAttribute."Key" := CopyStr(KeyName, 1, MaxStrLen(OrderAttribute."Key"));
        OrderAttribute.Value := CopyStr(Value, 1, MaxStrLen(OrderAttribute.Value));
        if not OrderAttribute.Insert() then
            OrderAttribute.Modify();

        Clear(OrderAttribute);
        OrderAttribute.SetRange("Order Id", OrderHeader."Shopify Order Id");
        if OrderAttribute.FindSet(false) then
            repeat
                Clear(JAttrib);
                JAttrib.Add('key', OrderAttribute."Key");
                JAttrib.Add('value', OrderAttribute.Value);
                JAttributes.Add(JAttrib);
            until OrderAttribute.Next() = 0;

        Parameters.Add('OrderId', Format(OrderHeader."Shopify Order Id"));
        Parameters.Add('CustomAttributes', Format(JAttributes).Replace('"key"', 'key').Replace('"value"', 'value').Replace('\', '\\').Replace('"', '\"'));
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

    internal procedure ExtractShopifyOrdersToImport(var ShopifyShop: Record "Shpfy Shop"; JResponse: JsonObject; var Cursor: Text): Boolean
    var
        OrdersToImport: Record "Shpfy Orders to Import";
        OrderHeader: Record "Shpfy Order Header";
        RecordRef: RecordRef;
        Id: BigInteger;
        JArray: JsonArray;
        JOrders: JsonArray;
        JNode: JsonObject;
        JItem: JsonToken;
        JLineItem: JsonToken;
        JValue: JsonValue;
        Tags: TextBuilder;
    begin
        if JsonHelper.GetJsonArray(JResponse, JOrders, 'data.orders.edges') then begin
            foreach JItem in JOrders do begin
                Cursor := JsonHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                    Id := JsonHelper.GetValueAsBigInteger(JNode, 'legacyResourceId');

                    OrdersToImport.SetRange(Id, Id);
                    if not OrdersToImport.FindFirst() then
                        Clear(OrdersToImport);
                    OrdersToImport.Id := Id;
                    OrdersToImport."Shop Id" := ShopifyShop."Shop Id";
                    RecordRef.GetTable(OrdersToImport);
                    JsonHelper.GetValueIntoField(JNode, 'name', RecordRef, OrdersToImport.FieldNo("Order No."));
                    JsonHelper.GetValueIntoField(JNode, 'createdAt', RecordRef, OrdersToImport.FieldNo("Created At"));
                    JsonHelper.GetValueIntoField(JNode, 'updatedAt', RecordRef, OrdersToImport.FieldNo("Updated At"));
                    JsonHelper.GetValueIntoField(JNode, 'test', RecordRef, OrdersToImport.FieldNo(Test));
                    JsonHelper.GetValueIntoField(JNode, 'fullyPaid', RecordRef, OrdersToImport.FieldNo("Fully Paid"));
                    JsonHelper.GetValueIntoField(JNode, 'unpaid', RecordRef, OrdersToImport.FieldNo(Unpaid));
                    JsonHelper.GetValueIntoField(JNode, 'subtotalLineItemsQuantity', RecordRef, OrdersToImport.FieldNo("Total Quantity of Items"));
                    JsonHelper.GetValueIntoField(JNode, 'totalPriceSet.shopMoney.amount', RecordRef, OrdersToImport.FieldNo("Order Amount"));
                    JsonHelper.GetValueIntoField(JNode, 'totalPriceSet.shopMoney.currencyCode', RecordRef, OrdersToImport.FieldNo("Currency Code"));
                    JsonHelper.GetValueIntoField(JNode, 'channel.name', RecordRef, OrdersToImport.FieldNo("Channel Name"));
                    RecordRef.SetTable(OrdersToImport);
                    OrdersToImport."Risk Level" := ConvertToRiskLevel(JsonHelper.GetValueAsText(JNode, 'riskLevel'));
                    OrdersToImport."Financial Status" := ConvertToFinancialStatus(JsonHelper.GetValueAsText(JNode, 'displayFinancialStatus'));
                    OrdersToImport."Fulfillment Status" := ConvertToFulfillmentStatus(JsonHelper.GetValueAsText(JNode, 'displayFulfillmentStatus'));
                    if JsonHelper.GetJsonArray(JNode, JArray, 'customAttributes') then
                        UpdateOrderAttributes(OrdersToImport.Id, JArray);
                    if JsonHelper.GetJsonArray(JNode, JArray, 'tags') then begin
                        Clear(Tags);
                        foreach JLineItem in JArray do begin
                            Tags.Append(' [');
                            JValue := JLineItem.AsValue();
                            Tags.Append(JValue.AsText());
                            Tags.Append(']');
                        end;
                        OrdersToImport.Tags := CopyStr(Tags.ToText(), 2, MaxStrLen(OrdersToImport.Tags));
                    end;
                    OrderHeader.SetRange("Shopify Order Id", Id);
                    if OrderHeader.IsEmpty then
                        OrdersToImport."Import Action" := OrdersToImport."Import Action"::New
                    else
                        OrdersToImport."Import Action" := OrdersToImport."Import Action"::Update;

                    if not OrdersToImport.Insert() then
                        OrdersToImport.Modify();
                end;
            end;
            exit(true);
        end;
    end;
}