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
        NewSyncTime: DateTime;
        Cursor: Text;
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
    begin
        CommunicationMgt.SetShop(ShopifyShop);

        Clear(OrdersToImport);
        LastSyncTime := ShopifyShop.GetLastSyncTime("Shpfy Synchronization Type"::Orders);
        Parameters.Add('Time', Format(LastSyncTime, 0, 9));
        if LastSyncTime = Shop.GetEmptySyncTime() then
            GraphQLType := "Shpfy GraphQL Type"::GetOpenOrdersToImport
        else
            GraphQLType := "Shpfy GraphQL Type"::GetOrdersToImport;
        NewSyncTime := CurrentDateTime;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JResponse.IsObject() then
                if ExtractShopifyOrdersToImport(ShopifyShop, JResponse.AsObject(), Cursor) then begin
                    if Parameters.ContainsKey('After') then
                        Parameters.Set('After', Cursor)
                    else
                        Parameters.Add('After', Cursor);
                    if LastSyncTime = Shop.GetEmptySyncTime() then
                        GraphQLType := "Shpfy GraphQL Type"::GetNextOpenOrdersToImport
                    else
                        GraphQLType := "Shpfy GraphQL Type"::GetNextOrdersToImport;
                end else
                    break;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.orders.pageInfo.hasNextPage');
        ShopifyShop.SetLastSyncTime("Shpfy Synchronization Type"::Orders, NewSyncTime);
        Commit();
    end;

    /// <summary> 
    /// Description for UpdateOrderAttributes.
    /// </summary>
    /// <param name="OrderId">Parameter of type BigInteger.</param>
    /// <param name="JAttributes">Parameter of type JsonArray.</param>
#if not CLEAN24
    /// <param name="ShopifyShop">Parameter of type Record "Shpfy Shop".</param>
    local procedure UpdateOrderAttributes(OrderId: BigInteger; JAttributes: JsonArray; ShopifyShop: Record "Shpfy Shop")
#else
    local procedure UpdateOrderAttributes(OrderId: BigInteger; JAttributes: JsonArray)
#endif
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
#if not CLEAN24
            if not ShopifyShop."Replace Order Attribute Value" then
                OrderAttribute.Value := CopyStr(JsonHelper.GetValueAsText(JItem, 'value').Replace('\\', '\').Replace('\"', '"'), 1, MaxStrLen(OrderAttribute.Value))
            else
#endif
                OrderAttribute."Attribute Value" := CopyStr(JsonHelper.GetValueAsText(JItem, 'value').Replace('\\', '\').Replace('\"', '"'), 1, MaxStrLen(OrderAttribute."Attribute Value"));

            if not OrderAttribute.Insert() then
                OrderAttribute.Modify();
        end;
    end;


    /// <summary> 
    /// Description for AddOrderAttribute.
    /// </summary>
    /// <param name="OrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="KeyName">Parameter of type Text.</param>
    /// <param name="Value">Parameter of type Text.</param>
#if not CLEAN24
    /// <param name="ShopifyShop">Parameter of type Record "Shpfy Shop".</param>
    internal procedure AddOrderAttribute(OrderHeader: Record "Shpfy Order Header"; KeyName: Text; Value: Text; ShopifyShop: Record "Shpfy Shop")
#else
    internal procedure AddOrderAttribute(OrderHeader: Record "Shpfy Order Header"; KeyName: Text; Value: Text; ShopifyShop: Record "Shpfy Shop")
#endif
    var
        OrderAttribute: Record "Shpfy Order Attribute";
        Parameters: Dictionary of [Text, Text];
        JAttributes: JsonArray;
        JAttrib: JsonObject;
    begin
        CommunicationMgt.SetShop(ShopifyShop);
        if CommunicationMgt.GetTestInProgress() then
            exit;
        Clear(OrderAttribute);
        OrderAttribute."Order Id" := OrderHeader."Shopify Order Id";
        OrderAttribute."Key" := CopyStr(KeyName, 1, MaxStrLen(OrderAttribute."Key"));
#if not CLEAN24
        if not ShopifyShop."Replace Order Attribute Value" then
            OrderAttribute.Value := CopyStr(Value, 1, MaxStrLen(OrderAttribute.Value))
        else
#endif
            OrderAttribute."Attribute Value" := CopyStr(Value, 1, MaxStrLen(OrderAttribute."Attribute Value"));
        if not OrderAttribute.Insert() then
            OrderAttribute.Modify();

        Clear(OrderAttribute);
        OrderAttribute.SetRange("Order Id", OrderHeader."Shopify Order Id");
        if OrderAttribute.FindSet(false) then
            repeat
                Clear(JAttrib);
                JAttrib.Add('key', OrderAttribute."Key");
#if not CLEAN24
                if not ShopifyShop."Replace Order Attribute Value" then
                    JAttrib.Add('value', OrderAttribute.Value)
                else
#endif
                    JAttrib.Add('value', OrderAttribute."Attribute Value");
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

    internal procedure ExtractShopifyOrdersToImport(var ShopifyShop: Record "Shpfy Shop"; JResponse: JsonObject; var Cursor: Text): Boolean
    var
        OrdersToImport: Record "Shpfy Orders to Import";
        OrderHeader: Record "Shpfy Order Header";
        RecordRef: RecordRef;
        Id: BigInteger;
        JArray: JsonArray;
        JOrders: JsonArray;
        JObject: JsonObject;
        JNode: JsonObject;
        JItem: JsonToken;
        JLineItem: JsonToken;
        JValue: JsonValue;
        Tags: TextBuilder;
        Closed: Boolean;
    begin
        if JsonHelper.GetJsonArray(JResponse, JOrders, 'data.orders.edges') then begin
            foreach JItem in JOrders do begin
                Cursor := JsonHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                    Id := JsonHelper.GetValueAsBigInteger(JNode, 'legacyResourceId');
                    Closed := JsonHelper.GetValueAsBoolean(JNode, 'closed');
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
                    JsonHelper.GetValueIntoField(JNode, 'displayAddress.countryCode', RecordRef, OrdersToImport.FieldNo("Sell-to Country/Region Code"));
                    JsonHelper.GetValueIntoField(JNode, 'shippingAddress.countryCode', RecordRef, OrdersToImport.FieldNo("Ship-to Country/Region Code"));
                    JsonHelper.GetValueIntoField(JNode, 'billingAddress.countryCode', RecordRef, OrdersToImport.FieldNo("Bill-to Country/Region Code"));
                    JsonHelper.GetValueIntoField(JNode, 'totalTaxSet.shopMoney.amount', RecordRef, OrdersToImport.FieldNo("VAT Amount"));
                    JsonHelper.GetValueIntoField(JNode, 'totalTaxSet.presentmentMoney.amount', RecordRef, OrdersToImport.FieldNo("Presentment VAT Amount"));
                    RecordRef.SetTable(OrdersToImport);
                    OrdersToImport."Financial Status" := ConvertToFinancialStatus(JsonHelper.GetValueAsText(JNode, 'displayFinancialStatus'));
                    OrdersToImport."Fulfillment Status" := ConvertToFulfillmentStatus(JsonHelper.GetValueAsText(JNode, 'displayFulfillmentStatus'));
                    if JsonHelper.GetJsonObject(JNode, JObject, 'purchasingEntity') then
                        if JsonHelper.GetJsonObject(JNode, JObject, 'purchasingEntity.company') then
                            OrdersToImport."Purchasing Entity" := OrdersToImport."Purchasing Entity"::Company
                        else
                            OrdersToImport."Purchasing Entity" := OrdersToImport."Purchasing Entity"::Customer;
                    if JsonHelper.GetJsonArray(JNode, JArray, 'customAttributes') then
#if not CLEAN24
                        UpdateOrderAttributes(OrdersToImport.Id, JArray, ShopifyShop);
#else
                        UpdateOrderAttributes(OrdersToImport.Id, JArray);
#endif
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
                    OrdersToImport."High Risk" := IsHighRiskOrder(JNode);
                    OrderHeader.SetRange("Shopify Order Id", Id);
                    if OrderHeader.IsEmpty then
                        OrdersToImport."Import Action" := OrdersToImport."Import Action"::New
                    else
                        OrdersToImport."Import Action" := OrdersToImport."Import Action"::Update;

                    if (OrdersToImport."Import Action" = OrdersToImport."Import Action"::Update) or ((OrdersToImport."Import Action" = OrdersToImport."Import Action"::New) and not Closed) then
                        if not OrdersToImport.Insert() then
                            OrdersToImport.Modify();
                end;
            end;
            exit(true);
        end;
    end;

    internal procedure MarkAsPaid(OrderId: BigInteger; ShopCode: Code[20]): Boolean
    var
        ShopifyShop: Record "Shpfy Shop";
        JResponse: JsonToken;
        Parameters: Dictionary of [Text, Text];
    begin
        ShopifyShop.Get(ShopCode);
        CommunicationMgt.SetShop(ShopifyShop);
        GraphQLType := "Shpfy GraphQL Type"::MarkOrderAsPaid;
        Parameters.Add('OrderId', Format(OrderId));
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
        exit(JsonHelper.GetValueAsBoolean(JResponse, 'data.orderMarkAsPaid.order.fullyPaid'));
    end;

    internal procedure CancelOrder(OrderId: BigInteger; ShopCode: Code[20]; NotifyCustomer: Boolean; CancelReason: Enum "Shpfy Cancel Reason"; Refund: Boolean; Restock: Boolean): Boolean
    var
        ShopifyShop: Record "Shpfy Shop";
        JResponse: JsonToken;
        Parameters: Dictionary of [Text, Text];
    begin
        ShopifyShop.Get(ShopCode);
        CommunicationMgt.SetShop(ShopifyShop);
        GraphQLType := "Shpfy GraphQL Type"::OrderCancel;
        Parameters.Add('OrderId', Format(OrderId));
        if CancelReason in [CancelReason::" ", CancelReason::Unknown] then
            CancelReason := CancelReason::Other;
        Parameters.Add('CancelReason', CancelReason.Names().Get(CancelReason.Ordinals().IndexOf(CancelReason.AsInteger())).ToUpper());
        Parameters.Add('NotifyCustomer', CommunicationMgt.ConvertBooleanToText(NotifyCustomer));
        Parameters.Add('Refund', CommunicationMgt.ConvertBooleanToText(Refund));
        Parameters.Add('Restock', CommunicationMgt.ConvertBooleanToText(Restock));
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
        exit(JsonHelper.GetJsonArray(JResponse, 'data.orderCancel.orderCancelUserErrors').Count() = 0);
    end;

    local procedure IsHighRiskOrder(JOrder: JsonObject): Boolean
    var
        OrderRisks: Codeunit "Shpfy Order Risks";
        RiskLevel: Enum "Shpfy Risk Level";
        JRiskAssessments: JsonArray;
        JRiskAssessment: JsonToken;
    begin
        if JsonHelper.GetJsonArray(JOrder, JRiskAssessments, 'risk.assessments') then
            foreach JRiskAssessment in JRiskAssessments do begin
                RiskLevel := OrderRisks.ConvertToRiskLevel(JsonHelper.GetValueAsText(JRiskAssessment, 'riskLevel'));
                if RiskLevel = RiskLevel::High then
                    exit(true);
            end;
    end;
}