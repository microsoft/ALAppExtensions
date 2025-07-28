// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

codeunit 30228 "Shpfy Refunds API"
{
    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        RefundEnumConvertor: Codeunit "Shpfy Refund Enum Convertor";
        RefundCantCreateCreditMemoErr: Label 'The refund imported from Shopify can''t be used to create a credit memo. Only refunds for paid items can be used to create credit memos.';

    internal procedure GetRefunds(JRefunds: JsonArray)
    var
        JRefund: JsonToken;
    begin
        foreach JRefund in JRefunds do
            GetRefund(JsonHelper.GetValueAsBigInteger(JRefund, 'legacyResourceId'), JsonHelper.GetValueAsDateTime(JRefund, 'updatedAt'));
    end;

    internal procedure VerifyRefundCanCreateCreditMemo(RefundId: BigInteger)
    var
        RefundLine: Record "Shpfy Refund Line";
    begin
        RefundLine.SetRange("Refund Id", RefundId);
        RefundLine.SetRange("Can Create Credit Memo", false);
        if not RefundLine.IsEmpty() then
            Error(RefundCantCreateCreditMemoErr);
    end;

    local procedure GetRefund(RefundId: BigInteger; UpdatedAt: DateTime)
    var
        RefundHeader: Record "Shpfy Refund Header";
        ReturnLocations: Dictionary of [BigInteger, BigInteger];
    begin
        GetRefundHeader(RefundId, UpdatedAt, RefundHeader);
        ReturnLocations := CollectReturnLocations(RefundHeader."Return Id");
        GetRefundLines(RefundId, RefundHeader, ReturnLocations);
        GetRefundShippingLines(RefundId);
    end;

    local procedure GetRefundHeader(RefundId: BigInteger; UpdatedAt: DateTime; var RefundHeader: Record "Shpfy Refund Header")
    var
        DataCapture: Record "Shpfy Data Capture";
        RefundHeaderRecordRef: RecordRef;
        IsNew: Boolean;
        Parameters: Dictionary of [Text, Text];
        JRefund: JsonObject;
        JResponse: JsonToken;
    begin
        if not RefundHeader.Get(RefundId) then
            IsNew := true
        else
            if RefundHeader."Updated At" >= UpdatedAt then
                exit;
        Parameters.Add('RefundId', Format(RefundId));
        JResponse := CommunicationMgt.ExecuteGraphQL("Shpfy GraphQL Type"::GetRefundHeader, Parameters);
        JRefund := JsonHelper.GetJsonObject(JResponse, 'data.refund');
        if IsNew then begin
            Clear(RefundHeader);
            RefundHeader."Refund Id" := RefundId;
            RefundHeader."Order Id" := JsonHelper.GetValueAsBigInteger(JRefund, 'order.legacyResourceId');
            RefundHeader."Return Id" := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JRefund, 'return.id'));
            RefundHeader."Created At" := JsonHelper.GetValueAsDateTime(JRefund, 'createdAt');
            RefundHeader."Shop Code" := CommunicationMgt.GetShopRecord().Code;
            RefundHeader.Insert();
        end;
        RefundHeader.SetNote(JsonHelper.GetValueAsText(JRefund, 'note'));
        RefundHeaderRecordRef.GetTable(RefundHeader);
        JsonHelper.GetValueIntoField(JRefund, 'updatedAt', RefundHeaderRecordRef, RefundHeader.FieldNo("Updated At"));
        JsonHelper.GetValueIntoField(JRefund, 'totalRefundedSet.shopMoney.amount', RefundHeaderRecordRef, RefundHeader.FieldNo("Total Refunded Amount"));
        JsonHelper.GetValueIntoField(JRefund, 'totalRefundedSet.presentmentMoney.amount', RefundHeaderRecordRef, RefundHeader.FieldNo("Pres. Tot. Refunded Amount"));
        RefundHeaderRecordRef.Modify();
        RefundHeaderRecordRef.SetTable(RefundHeader);
        RefundHeaderRecordRef.Close();
        DataCapture.Add(Database::"Shpfy Refund Header", RefundHeader.SystemId, JResponse);
    end;

    local procedure GetRefundLines(RefundId: BigInteger; RefundHeader: Record "Shpfy Refund Header"; ReturnLocations: Dictionary of [BigInteger, BigInteger])
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
        JLines: JsonArray;
        JLine: JsonToken;
    begin
        Parameters.Add('RefundId', Format(RefundId));
        GraphQLType := "Shpfy GraphQL Type"::GetRefundLines;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            GraphQLType := "Shpfy GraphQL Type"::GetNextRefundLines;
            JLines := JsonHelper.GetJsonArray(JResponse, 'data.refund.refundLineItems.nodes');
            if Parameters.ContainsKey('After') then
                Parameters.Set('After', JsonHelper.GetValueAsText(JResponse, 'data.refund.refundLineItems.pageInfo.endCursor'))
            else
                Parameters.Add('After', JsonHelper.GetValueAsText(JResponse, 'data.refund.refundLineItems.pageInfo.endCursor'));

            foreach JLine in JLines do
                FillInRefundLine(RefundId, JLine.AsObject(), IsNonZeroOrReturnRefund(RefundHeader), ReturnLocations);
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.refund.refundLineItems.pageInfo.hasNextPage');
    end;

    local procedure GetRefundShippingLines(RefundId: BigInteger)
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
        JLines: JsonArray;
        JLine: JsonToken;
    begin
        Parameters.Add('RefundId', Format(RefundId));
        GraphQLType := "Shpfy GraphQL Type"::GetRefundShippingLines;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            GraphQLType := "Shpfy GraphQL Type"::GetNextRefundShippingLines;
            JLines := JsonHelper.GetJsonArray(JResponse, 'data.refund.refundShippingLines.nodes');
            if Parameters.ContainsKey('After') then
                Parameters.Set('After', JsonHelper.GetValueAsText(JResponse, 'data.refund.refundShippingLines.pageInfo.endCursor'))
            else
                Parameters.Add('After', JsonHelper.GetValueAsText(JResponse, 'data.refund.refundShippingLines.pageInfo.endCursor'));

            foreach JLine in JLines do
                FillInRefundShippingLine(RefundId, JLine.AsObject());
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.refund.refundShippingLines.pageInfo.hasNextPage');
    end;

    local procedure CollectReturnLocations(ReturnId: BigInteger): Dictionary of [BigInteger, BigInteger]
    var
        ReturnsAPI: Codeunit "Shpfy Returns API";
    begin
        if ReturnId <> 0 then
            exit(ReturnsAPI.GetReturnLocations(ReturnId));
    end;

    internal procedure FillInRefundLine(RefundId: BigInteger; JLine: JsonObject; NonZeroOrReturnRefund: Boolean; ReturnLocations: Dictionary of [BigInteger, BigInteger])
    var
        DataCapture: Record "Shpfy Data Capture";
        RefundLine: Record "Shpfy Refund Line";
        RefundLineRecordRef: RecordRef;
        Id: BigInteger;
        ReturnLocation: BigInteger;
    begin
        Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JLine, 'lineItem.id'));

        if not RefundLine.Get(RefundId, Id) then begin
            RefundLine."Refund Line Id" := Id;
            RefundLine."Refund Id" := RefundId;
            RefundLine."Order Line Id" := Id;
            RefundLine.Insert();
        end;

        RefundLine."Restock Type" := RefundEnumConvertor.ConvertToReStockType(JsonHelper.GetValueAsText(JLine, 'restockType'));

        RefundLineRecordRef.GetTable(RefundLine);
        JsonHelper.GetValueIntoField(JLine, 'quantity', RefundLineRecordRef, RefundLine.FieldNo(Quantity));
        JsonHelper.GetValueIntoField(JLine, 'restocked', RefundLineRecordRef, RefundLine.FieldNo(Restocked));
        JsonHelper.GetValueIntoField(JLine, 'priceSet.shopMoney.amount', RefundLineRecordRef, RefundLine.FieldNo(Amount));
        JsonHelper.GetValueIntoField(JLine, 'priceSet.presentmentMoney.amount', RefundLineRecordRef, RefundLine.FieldNo("Presentment Amount"));
        JsonHelper.GetValueIntoField(JLine, 'subtotalSet.shopMoney.amount', RefundLineRecordRef, RefundLine.FieldNo("Subtotal Amount"));
        JsonHelper.GetValueIntoField(JLine, 'subtotalSet.presentmentMoney.amount', RefundLineRecordRef, RefundLine.FieldNo("Presentment Subtotal Amount"));
        JsonHelper.GetValueIntoField(JLine, 'totalTaxSet.shopMoney.amount', RefundLineRecordRef, RefundLine.FieldNo("Total Tax Amount"));
        JsonHelper.GetValueIntoField(JLine, 'totalTaxSet.presentmentMoney.amount', RefundLineRecordRef, RefundLine.FieldNo("Presentment Total Tax Amount"));
        RefundLineRecordRef.SetTable(RefundLine);

        RefundLine."Can Create Credit Memo" := NonZeroOrReturnRefund;
        RefundLine."Location Id" := JsonHelper.GetValueAsBigInteger(JLine, 'location.legacyResourceId');

        // If refund was created from a return, the location needs to come from the return
        // If Item was restocked to multiple locations, the return location is not known
        if (RefundLine."Location Id" = 0) and (ReturnLocations.Get(RefundLine."Order Line Id", ReturnLocation)) then
            RefundLine."Location Id" := ReturnLocation;

        RefundLine.Modify();

        RefundLineRecordRef.Close();
        DataCapture.Add(Database::"Shpfy Refund Line", RefundLine.SystemId, JLine);
    end;

    internal procedure FillInRefundShippingLine(RefundId: BigInteger; JLine: JsonObject)
    var
        DataCapture: Record "Shpfy Data Capture";
        RefundShippingLine: Record "Shpfy Refund Shipping Line";
        RefundShippingLineRecordRef: RecordRef;
        Id: BigInteger;
    begin
        Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JLine, 'id'));

        if not RefundShippingLine.Get(RefundId, Id) then begin
            RefundShippingLine."Refund Shipping Line Id" := Id;
            RefundShippingLine."Refund Id" := RefundId;
            RefundShippingLine.Insert();
        end;

        RefundShippingLineRecordRef.GetTable(RefundShippingLine);
        JsonHelper.GetValueIntoField(JLine, 'shippingLine.title', RefundShippingLineRecordRef, RefundShippingLine.FieldNo(Title));
        JsonHelper.GetValueIntoField(JLine, 'subtotalAmountSet.shopMoney.amount', RefundShippingLineRecordRef, RefundShippingLine.FieldNo("Subtotal Amount"));
        JsonHelper.GetValueIntoField(JLine, 'subtotalAmountSet.presentmentMoney.amount', RefundShippingLineRecordRef, RefundShippingLine.FieldNo("Presentment Subtotal Amount"));
        JsonHelper.GetValueIntoField(JLine, 'taxAmountSet.shopMoney.amount', RefundShippingLineRecordRef, RefundShippingLine.FieldNo("Tax Amount"));
        JsonHelper.GetValueIntoField(JLine, 'taxAmountSet.presentmentMoney.amount', RefundShippingLineRecordRef, RefundShippingLine.FieldNo("Presentment Tax Amount"));
        RefundShippingLineRecordRef.SetTable(RefundShippingLine);

        RefundShippingLine.Modify();

        RefundShippingLineRecordRef.Close();
        DataCapture.Add(Database::"Shpfy Refund Shipping Line", RefundShippingLine.SystemId, JLine);
    end;

    internal procedure IsNonZeroOrReturnRefund(RefundHeader: Record "Shpfy Refund Header"): Boolean
    begin
        exit((RefundHeader."Return Id" > 0) or (RefundHeader."Total Refunded Amount" > 0));
    end;
}