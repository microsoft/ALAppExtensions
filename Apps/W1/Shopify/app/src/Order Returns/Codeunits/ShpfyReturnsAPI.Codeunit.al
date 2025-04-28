namespace Microsoft.Integration.Shopify;

codeunit 30250 "Shpfy Returns API"
{
    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        ReturnEnumConvertor: Codeunit "Shpfy Return Enum Convertor";
        Parameters: Dictionary of [Text, Text];
        CategoryTok: Label 'Shopify Integration', Locked = true;
        OrderLineMultipleLocMsg: Label 'Order line %1 has multiple locations %2 and %3', Locked = true;

    internal procedure GetReturns(OrderId: BigInteger; JReturns: JsonObject)
    var
        JNodes: JsonArray;
        JNode: JsonToken;
        JResult: JsonToken;
    begin
        if JsonHelper.GetJsonArray(JReturns, JNodes, 'nodes') then
            foreach JNode in JNodes do
                GetReturn(CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JNode, 'id')));
        Parameters.Add('OrderId', Format(OrderId));
        if JsonHelper.GetValueAsBoolean(JReturns, 'pageInfo.hasNextPage') then begin
            if Parameters.ContainsKey('After') then
                Parameters.Set('After', JsonHelper.GetValueAsText(JReturns, 'pageInfo.endCursor'))
            else
                Parameters.Add('After', JsonHelper.GetValueAsText(JReturns, 'pageInfo.endCursor'));
            JResult := CommunicationMgt.ExecuteGraphQL("Shpfy GraphQL Type"::NextOrderReturns);
            GetReturns(OrderId, JsonHelper.GetJsonObject(JResult, 'data.order.returns'));
        end;
    end;

    local procedure GetReturn(ReturnId: BigInteger)
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        LineParameters: Dictionary of [text, Text];
        ReturnLocations: Dictionary of [BigInteger, BigInteger];
        JResponse: JsonToken;
        JLines: JsonArray;
        JLine: JsonToken;
    begin
        GetReturnHeader(ReturnId);
        ReturnLocations := GetReturnLocations(ReturnId);

        LineParameters.Add('ReturnId', Format(ReturnId));
        GraphQLType := "Shpfy GraphQL Type"::GetReturnLines;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, LineParameters);
            GraphQLType := "Shpfy GraphQL Type"::GetNextReturnLines;
            JLines := JsonHelper.GetJsonArray(JResponse, 'data.return.returnLineItems.nodes');
            if LineParameters.ContainsKey('After') then
                LineParameters.Set('After', JsonHelper.GetValueAsText(JResponse, 'data.return.returnLineItems.pageInfo.endCursor'))
            else
                LineParameters.Add('After', JsonHelper.GetValueAsText(JResponse, 'data.return.returnLineItems.pageInfo.endCursor'));
            foreach JLine in JLines do
                FillInReturnLine(ReturnId, JLine.AsObject(), ReturnLocations);
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.return.returnLineItems.pageInfo.hasNextPage');
    end;

    local procedure GetReturnHeader(ReturnId: BigInteger)
    var
        DataCapture: Record "Shpfy Data Capture";
        ReturnHeader: Record "Shpfy Return Header";
        ReturnHeaderRecordRef: RecordRef;
        HeaderParameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
        JReturn: JsonObject;
    begin
        HeaderParameters.Add('ReturnId', Format(ReturnId));
        JResponse := CommunicationMgt.ExecuteGraphQL("Shpfy GraphQL Type"::GetReturnHeader, HeaderParameters);
        JReturn := JsonHelper.GetJsonObject(JResponse, 'data.return');
        if not ReturnHeader.Get(ReturnId) then begin
            ReturnHeader."Return Id" := ReturnId;
            ReturnHeader."Order Id" := JsonHelper.GetValueAsBigInteger(JReturn, 'order.legacyResourceId');
            ReturnHeader."Shop Code" := CommunicationMgt.GetShopRecord().Code;
            ReturnHeader.Insert();
        end;
        ReturnHeader.Status := ReturnEnumConvertor.ConvertToReturnStatus(JsonHelper.GetValueAsText(JReturn, 'status'));
        ReturnHeader."Decline Reason" := ReturnEnumConvertor.ConvertToReturnDeclineReason(JsonHelper.GetValueAsText(JReturn, 'decilne.reason'));
        ReturnHeader.SetDeclineNote(JsonHelper.GetValueAsText(JReturn, 'decilne.note'));
        ReturnHeaderRecordRef.GetTable(ReturnHeader);
        JsonHelper.GetValueIntoField(JReturn, 'name', ReturnHeaderRecordRef, ReturnHeader.FieldNo("Return No."));
        JsonHelper.GetValueIntoField(JReturn, 'totalQuantity', ReturnHeaderRecordRef, ReturnHeader.FieldNo("Total Quantity"));
        ReturnHeaderRecordRef.Modify();
        ReturnHeaderRecordRef.Close();
        DataCapture.Add(Database::"Shpfy Return Header", ReturnHeader.SystemId, JResponse);
    end;

    /// <summary>
    /// Get the return locations for return lines.
    /// </summary>
    /// <param name="ReturnId">Id of the return.</param>
    /// <remarks>
    /// If item was restocked to multiple locations, we cannot determine the return location for the return line,
    /// and the order line id will not be included in the return locations.
    /// </remarks>
    /// <returns>Dictionary of Order Line Id and Location Id.</returns>
    internal procedure GetReturnLocations(ReturnId: BigInteger) ReturnLocations: Dictionary of [BigInteger, BigInteger]
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        LineParameters: Dictionary of [text, Text];
        JResponse: JsonToken;
        JOrders: JsonArray;
        JOrder: JsonToken;
    begin
        LineParameters.Add('ReturnId', Format(ReturnId));
        GraphQLType := "Shpfy GraphQL Type"::GetReverseFulfillmentOrders;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, LineParameters);

            GraphQLType := "Shpfy GraphQL Type"::GetNextReverseFulfillmentOrders;
            JOrders := JsonHelper.GetJsonArray(JResponse, 'data.return.reverseFulfillmentOrders.nodes');
            if Parameters.ContainsKey('After') then
                Parameters.Set('After', JsonHelper.GetValueAsText(JResponse, 'data.return.reverseFulfillmentOrders.pageInfo.endCursor'))
            else
                Parameters.Add('After', JsonHelper.GetValueAsText(JResponse, 'data.return.reverseFulfillmentOrders.pageInfo.endCursor'));

            foreach JOrder in JOrders do
                GetReturnLocationsFromReturnFulfillOrder(JsonHelper.GetValueAsText(JOrder, 'id'), ReturnLocations);
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.return.reverseFulfillmentOrders.pageInfo.hasNextPage');
    end;

    local procedure GetReturnLocationsFromReturnFulfillOrder(FulfillOrderId: Text; var ReturnLocations: Dictionary of [BigInteger, BigInteger])
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        LineParameters: Dictionary of [text, Text];
        JResponse: JsonToken;
        JLines: JsonArray;
        JLine: JsonToken;
    begin
        LineParameters.Add('FulfillOrderId', FulfillOrderId);
        GraphQLType := "Shpfy GraphQL Type"::GetReverseFulfillmentOrderLines;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, LineParameters);

            GraphQLType := "Shpfy GraphQL Type"::GetNextReverseFulfillmentOrders;
            JLines := JsonHelper.GetJsonArray(JResponse, 'data.reverseFulfillmentOrder.lineItems.nodes');
            if Parameters.ContainsKey('After') then
                Parameters.Set('After', JsonHelper.GetValueAsText(JResponse, 'data.reverseFulfillmentOrder.lineItems.pageInfo.endCursor'))
            else
                Parameters.Add('After', JsonHelper.GetValueAsText(JResponse, 'data.reverseFulfillmentOrder.lineItems.pageInfo.endCursor'));

            foreach JLine in JLines do
                CollectLocationsFromLineDispositions(JLine, ReturnLocations);
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.reverseFulfillmentOrder.lineItems.pageInfo.hasNextPage');
    end;

    local procedure CollectLocationsFromLineDispositions(JLine: JsonToken; var ReturnLocations: Dictionary of [BigInteger, BigInteger])
    var
        OrderLineId: BigInteger;
        LocationId: BigInteger;
        Dispositions: JsonArray;
        Disposition: JsonToken;
    begin
        OrderLineId := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JLine, 'fulfillmentLineItem.lineItem.id'));

        Dispositions := JsonHelper.GetJsonArray(JLine, 'dispositions');
        if Dispositions.Count = 0 then
            exit;

        // If dispositions have different locations (Item was restocked to multiple locations), 
        // we cannot determine the return location for the line
        Dispositions.Get(0, Disposition);
        LocationId := JsonHelper.GetValueAsBigInteger(Disposition, 'location.legacyResourceId');
        foreach Disposition in Dispositions do
            if LocationId <> JsonHelper.GetValueAsBigInteger(Disposition, 'location.legacyResourceId') then
                exit;

        if ReturnLocations.ContainsKey(OrderLineId) then begin
            if LocationId <> ReturnLocations.Get(OrderLineId) then begin
                Session.LogMessage('0000P74', StrSubstNo(OrderLineMultipleLocMsg, OrderLineId, LocationId, ReturnLocations.Get(OrderLineId)), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                // If the location is different, we cannot determine the return location for the line (same item from different return lines stocked to different locations)
                ReturnLocations.Remove(OrderLineId);
            end;
            exit;
        end;

        ReturnLocations.Add(OrderLineId, LocationId);
    end;

    local procedure FillInReturnLine(ReturnId: BigInteger; JLine: JsonObject; ReturnLocations: Dictionary of [BigInteger, BigInteger])
    var
        DataCapture: Record "Shpfy Data Capture";
        ReturnLine: Record "Shpfy Return Line";
        ReturnLineRecordRef: RecordRef;
        Id: BigInteger;
        ReturnLocation: BigInteger;
    begin
        Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JLine, 'id'));
        if not ReturnLine.Get(Id) then begin
            ReturnLine."Return Line Id" := Id;
            ReturnLine."Return Id" := ReturnId;
            ReturnLine."Fulfillment Line Id" := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JLine, 'fulfillmentLineItem.id'));
            ReturnLine."Order Line Id" := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JLine, 'fulfillmentLineItem.lineItem.id'));
            ReturnLine.Insert();
        end;
        ReturnLine."Return Reason" := ReturnEnumConvertor.ConvertToReturnReason(JsonHelper.GetValueAsText(JLine, 'returnReason'));
        // If item was restocked to multiple locations, we cannot determine the return location for the line
        if ReturnLocations.Get(ReturnLine."Order Line Id", ReturnLocation) then
            ReturnLine."Location Id" := ReturnLocation;

        ReturnLine.SetReturnReasonNote(JsonHelper.GetValueAsText(JLine, 'returnReasonNote'));
        ReturnLine.SetCustomerNote(JsonHelper.GetValueAsText(JLine, 'customerNote'));

        ReturnLineRecordRef.GetTable(ReturnLine);
        JsonHelper.GetValueIntoField(JLine, 'quantity', ReturnLineRecordRef, ReturnLine.FieldNo(Quantity));
        JsonHelper.GetValueIntoField(JLine, 'refundableQuantity', ReturnLineRecordRef, ReturnLine.FieldNo("Refundable Quantity"));
        JsonHelper.GetValueIntoField(JLine, 'refundedQuantity', ReturnLineRecordRef, ReturnLine.FieldNo("Refunded Quantity"));
        JsonHelper.GetValueIntoField(JLine, 'totalWeight.unit', ReturnLineRecordRef, ReturnLine.FieldNo("Weight Unit"));
        JsonHelper.GetValueIntoField(JLine, 'totalWeight.value', ReturnLineRecordRef, ReturnLine.FieldNo(Weight));
        JsonHelper.GetValueIntoField(JLine, 'withCodeDiscountedTotalPriceSet.shopMoney.amount', ReturnLineRecordRef, ReturnLine.FieldNo("Discounted Total Amount"));
        JsonHelper.GetValueIntoField(JLine, 'withCodeDiscountedTotalPriceSet.presentmentMoney.amount', ReturnLineRecordRef, ReturnLine.FieldNo("Presentment Disc. Total Amt."));
        ReturnLineRecordRef.Modify();
        ReturnLineRecordRef.Close();
        DataCapture.Add(Database::"Shpfy Return Line", ReturnLine.SystemId, JLine);
    end;
}