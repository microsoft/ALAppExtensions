codeunit 30250 "Shpfy Returns API"
{
    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        ReturnEnumConvertor: Codeunit "Shpfy Return Enum Convertor";
        Parameters: Dictionary of [Text, Text];

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
        JResponse: JsonToken;
        JLines: JsonArray;
        JLine: JsonToken;
    begin
        GetReturnHeader(ReturnId);
        LineParameters.Add('ReturnId', Format(ReturnId));
        GraphQLType := "Shpfy GraphQL Type"::GetReturnLines;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, LineParameters);
            GraphQLType := "Shpfy GraphQL Type"::GetNextReturnLines;
            JLines := JsonHelper.GetJsonArray(JResponse, 'data.return.returnLineItems.nodes');
            if Parameters.ContainsKey('After') then
                Parameters.Set('After', JsonHelper.GetValueAsText(JResponse, 'data.return.returnLineItems.pageInfo.endCursor'))
            else
                Parameters.Add('After', JsonHelper.GetValueAsText(JResponse, 'data.return.returnLineItems.pageInfo.endCursor'));
            foreach JLine in JLines do
                FillInReturnLine(ReturnId, JLine.AsObject());
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

    local procedure FillInReturnLine(ReturnId: BigInteger; JLine: JsonObject)
    var
        DataCapture: Record "Shpfy Data Capture";
        ReturnLine: Record "Shpfy Return Line";
        ReturnLineRecordRef: RecordRef;
        Id: BigInteger;
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