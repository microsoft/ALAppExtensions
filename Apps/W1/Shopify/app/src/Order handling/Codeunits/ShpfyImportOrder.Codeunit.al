namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Document;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;

/// <summary>
/// Codeunit Shpfy Import Order (ID 30161).
/// </summary>
codeunit 30161 "Shpfy Import Order"
{
    Access = Internal;
    Permissions = tabledata "Sales Line" = rim;
    TableNo = "Shpfy Orders to Import";

    trigger OnRun()
    begin
        ImportOrderAndCreateOrUpdate(Rec."Shop Code", Rec.Id);
    end;

    internal procedure SetShop(ShopCode: Code[20]): Boolean
    begin
        if Shop.Code = ShopCode then
            exit(true);
        if not Shop.Get(ShopCode) then
            exit(false);
        CommunicationMgt.SetShop(Shop);
        exit(true);
    end;

    internal procedure ReimportExistingOrderConfirmIfConflicting(OrderHeader: Record "Shpfy Order Header")
    var
        OrderMapping: Codeunit "Shpfy Order Mapping";
    begin
        OrderHeader.Get(OrderHeader."Shopify Order Id");
        ImportOrderAndCreateOrUpdate(OrderHeader."Shop Code", OrderHeader."Shopify Order Id");
        OrderHeader.Get(OrderHeader."Shopify Order Id");
        if not OrderHeader."Has Error" then
            if OrderMapping.DoMapping(OrderHeader) then;
    end;

    internal procedure ImportCreateAndUpdateOrderHeaderFromMock(ShopCode: Code[20]; OrderId: BigInteger; MockJOrder: JsonObject)
    var
        OrderHeader: Record "Shpfy Order Header";
        UpdatingOrderHeader: Boolean;
    begin
        UpdatingOrderHeader := EnsureOrderHeaderExists(OrderId, ShopCode, OrderHeader);
        if not SetOrderHeaderValuesFromJson(MockJOrder, UpdatingOrderHeader, OrderHeader) then
            exit;
        SetAndCreateRelatedRecords(MockJOrder, OrderHeader);
        OrderHeader.Modify();
    end;

    internal procedure ImportCreateAndUpdateOrderLinesFromMock(OrderId: BigInteger; MockJOrderLines: JsonArray)
    var
        OrderLine: Record "Shpfy Order Line";
        TempOrderLine: Record "Shpfy Order Line" temporary;
        DataCaptureDict: Dictionary of [BigInteger, JsonToken];
    begin
        SetAndInsertOrderLines(OrderId, MockJOrderLines, TempOrderLine, DataCaptureDict);
        if not TempOrderLine.FindSet() then
            exit;
        repeat
            OrderLine.Copy(TempOrderLine);
            OrderLine.Insert();
        until TempOrderLine.Next() = 0;
    end;

    var
        Shop: record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        OrderEvents: Codeunit "Shpfy Order Events";
        OrderFulfillments: Codeunit "Shpfy Order Fulfillments";
        ProcessedConflictErr: Label 'The order has already been processed in Business Central, but an edition was received from Shopify. Changes were not propagated to the processed order in Business Central. Update the processed documents to match the received data from Shopify.';

    local procedure ImportOrderAndCreateOrUpdate(ShopCode: Code[20]; OrderId: BigInteger)
    var
        OrderHeader: Record "Shpfy Order Header";
        TempOrderLine: Record "Shpfy Order Line" temporary;
        UpdatingOrderHeader: Boolean;
        JOrder: JsonObject;
        DataCaptureDict: Dictionary of [BigInteger, JsonToken];
        Redundancy: Integer;
    begin
        if OrderId = 0 then
            exit;

        if not SetShop(ShopCode) then
            exit;

        UpdatingOrderHeader := EnsureOrderHeaderExists(OrderId, ShopCode, OrderHeader);

        if not RetrieveOrderHeaderJson(OrderId, OrderHeader.SystemId, JOrder) then
            exit;

        RetrieveAndSetOrderLines(OrderId, TempOrderLine, DataCaptureDict);
        if OrderHeader.IsProcessed() then
            if not OrderHeader."Has Order State Error" then
                if IsImportedOrderConflictingExistingOrder(JOrder, OrderHeader, TempOrderLine) then
                    SetOrderAsConflicting(OrderHeader);

        if not SetOrderHeaderValuesFromJson(JOrder, UpdatingOrderHeader, OrderHeader) then
            exit;

        SetAndCreateRelatedRecords(JOrder, OrderHeader);
        OrderHeader.Modify();
        OrderEvents.OnAfterImportShopifyOrderHeader(OrderHeader, not UpdatingOrderHeader);
        InsertOrderLinesAndRelatedRecords(TempOrderLine, DataCaptureDict, Redundancy);
        OrderHeader."Line Items Redundancy Code" := Redundancy;
        OrderHeader.Modify();
        OrderFulfillments.GetFulfillments(Shop, OrderHeader."Shopify Order Id");

        ConsiderRefundsInQuantityAndAmounts(OrderHeader);
        DeleteZeroQuantityLines(OrderHeader);

        if CheckToCloseOrder(OrderHeader) then
            CloseOrder(OrderHeader);

        if ShopifyInvoiceExists(OrderHeader) then
            MarkAsProcessed(OrderHeader);
    end;

    local procedure ShopifyInvoiceExists(OrderHeader: Record "Shpfy Order Header"): Boolean
    var
        ShpfyInvoiceHeader: Record "Shpfy Invoice Header";
    begin
        exit(ShpfyInvoiceHeader.Get(OrderHeader."Shopify Order Id"));
    end;

    local procedure MarkAsProcessed(OrderHeader: Record "Shpfy Order Header")
    begin
        OrderHeader.Validate(Processed, true);
        OrderHeader.Modify()
    end;

    local procedure InsertOrderLinesAndRelatedRecords(var TempOrderLine: Record "Shpfy Order Line" temporary; var DataCaptureDict: Dictionary of [BigInteger, JsonToken]; var Redundancy: Integer)
    var
        OrderLine: Record "Shpfy Order Line";
        DataCapture: Record "Shpfy Data Capture";
        Hash: Codeunit "Shpfy Hash";
        JOrderLine: JsonToken;
        LineIds: Text;
    begin
        TempOrderLine.SetCurrentKey("Line Id");
        TempOrderLine.SetAscending("Line Id", true);
        if not TempOrderLine.FindSet() then
            exit;
        repeat
            LineIds += '|' + Format(TempOrderLine."Line Id");
            JOrderLine := DataCaptureDict.Get(TempOrderLine."Line Id");
            if OrderLine.Get(TempOrderLine."Shopify Order Id", TempOrderLine."Line Id") then begin
                Clear(OrderLine);
                OrderLine.Copy(TempOrderLine);
                UpdateLocationIdAndDeliveryMethodOnOrderLine(OrderLine);
                OrderLine.Modify();
            end else begin
                Clear(OrderLine);
                OrderLine.Copy(TempOrderLine);
                UpdateLocationIdAndDeliveryMethodOnOrderLine(OrderLine);
                OrderLine.Insert();
                AddTaxLines(OrderLine."Line Id", JsonHelper.GetJsonArray(JOrderLine, 'taxLines'));
                ImportCustomAttributtes(OrderLine."Shopify Order Id", OrderLine.SystemId, JsonHelper.GetJsonArray(JOrderLine, 'customAttributes'));
            end;
            DataCapture.Add(Database::"Shpfy Order Line", OrderLine.SystemId, Format(JOrderLine));
        until TempOrderLine.Next() = 0;
        Redundancy := Hash.CalcHash(LineIds);
    end;

    local procedure EnsureOrderHeaderExists(OrderId: BigInteger; ShopCode: Code[20]; var OrderHeader: Record "Shpfy Order Header"): Boolean
    begin
        if OrderHeader.Get(OrderId) then
            exit(true);
        OrderHeader."Shopify Order Id" := OrderId;
        OrderHeader."Shop Code" := ShopCode;
        OrderHeader.Insert();
        exit(false);
    end;

    local procedure DeleteZeroQuantityLines(OrderHeader: Record "Shpfy Order Header")
    var
        OrderLine: Record "Shpfy Order Line";
    begin
        OrderLine.SetRange("Shopify Order Id", OrderHeader."Shopify Order Id");
        OrderLine.SetRange(Quantity, 0);
        OrderLine.DeleteAll();
    end;

    local procedure ConsiderRefundsInQuantityAndAmounts(var OrderHeader: Record "Shpfy Order Header")
    var
        OrderLine: Record "Shpfy Order Line";
        RefundLine: Record "Shpfy Refund Line";
        IReturnRefundProcess: Interface "Shpfy IReturnRefund Process";
    begin
        IReturnRefundProcess := Shop."Return and Refund Process";
        if not IReturnRefundProcess.IsImportNeededFor("Shpfy Source Document Type"::Refund) then
            exit;
        OrderLine.SetRange("Shopify Order Id", OrderHeader."Shopify Order Id");
        if not OrderLine.FindSet() then
            exit;
        repeat
            Clear(RefundLine);
            RefundLine.SetRange("Order Line Id", OrderLine."Line Id");
            if not OrderHeader."Has Order State Error" then
                if OrderHeader."Cancelled At" <> 0DT then
                    if RefundLine.IsEmpty() then
                        if OrderHeader.IsProcessed() then
                            SetOrderAsConflicting(OrderHeader);

            RefundLine.SetRange("Can Create Credit Memo", false);
            if not OrderHeader."Has Order State Error" then
                if not RefundLine.IsEmpty() then
                    if OrderHeader.IsProcessed() then
                        SetOrderAsConflicting(OrderHeader);

            RefundLine.CalcSums("Presentment Amount", Amount, "Subtotal Amount", "Presentment Total Tax Amount", Quantity);
            OrderLine.Quantity -= RefundLine.Quantity;
            OrderLine.Modify();
            OrderHeader."Total Amount" -= RefundLine."Subtotal Amount";
            OrderHeader."Subtotal Amount" -= RefundLine."Subtotal Amount";
            OrderHeader."Presentment Total Amount" -= RefundLine."Presentment Subtotal Amount";
            OrderHeader."Presentment Subtotal Amount" -= RefundLine."Presentment Subtotal Amount";
            OrderHeader."VAT Amount" -= RefundLine."Total Tax Amount";
            OrderHeader."Presentment VAT Amount" -= RefundLine."Presentment Total Tax Amount";
            OrderEvents.OnAfterConsiderRefundsInQuantityAndAmounts(OrderHeader, OrderLine, RefundLine);
        until OrderLine.Next() = 0;
        OrderHeader.Modify();
    end;

    local procedure IsImportedOrderConflictingExistingOrder(JOrder: JsonObject; OrderHeader: Record "Shpfy Order Header"; var TempOrderLine: Record "Shpfy Order Line" temporary): Boolean
    var
        Hash: Codeunit "Shpfy Hash";
        LineIds: Text;
        Redundancy: Integer;
    begin
        if OrderHeader."Current Total Items Quantity" <> 0 then
            if OrderHeader."Current Total Items Quantity" < JsonHelper.GetValueAsDecimal(JOrder, 'currentSubtotalLineItemsQuantity') then
                exit(true);

        if OrderHeader."Line Items Redundancy Code" <> 0 then begin
            TempOrderLine.SetCurrentKey("Line Id");
            TempOrderLine.SetAscending("Line Id", true);
            if TempOrderLine.FindSet() then
                repeat
                    LineIds += '|' + Format(TempOrderLine."Line Id");
                until TempOrderLine.Next() = 0;
            Redundancy := Hash.CalcHash(LineIds);
            if Redundancy <> OrderHeader."Line Items Redundancy Code" then
                exit(true);
        end;

        if OrderHeader."Shipping Charges Amount" <> JsonHelper.GetValueAsDecimal(JOrder, 'totalShippingPriceSet.shopMoney.amount') then
            exit(true);
    end;

    local procedure SetAndCreateRelatedRecords(JOrder: JsonObject; var OrderHeader: Record "Shpfy Order Header")
    var
        FulfillmentOrdersAPI: Codeunit "Shpfy Fulfillment Orders API";
        ShippingCharges: Codeunit "Shpfy Shipping Charges";
        Transactions: Codeunit "Shpfy Transactions";
        ReturnsAPI: Codeunit "Shpfy Returns API";
        RefundsAPI: Codeunit "Shpfy Refunds API";
        IReturnRefundProcess: Interface "Shpfy IReturnRefund Process";
    begin
        AddTaxLines(OrderHeader."Shopify Order Id", JsonHelper.GetJsonArray(JOrder, 'taxLines'));
        OrderHeader.SetWorkDescription(JsonHelper.GetValueAsText(JOrder, 'note'));
        ImportCustomAttributtes(OrderHeader."Shopify Order Id", JsonHelper.GetJsonArray(JOrder, 'customAttributes'));
        OrderHeader.UpdateTags(JsonHelper.GetArrayAsText(JOrder, 'tags'));
        ImportRisks(OrderHeader, JsonHelper.GetJsonArray(JOrder, 'risks'));
        FulfillmentOrdersAPI.GetShopifyFulfillmentOrdersFromShopifyOrder(Shop, OrderHeader."Shopify Order Id");
        ShippingCharges.UpdateShippingCostInfos(OrderHeader);
        Transactions.UpdateTransactionInfos(OrderHeader."Shopify Order Id");
        IReturnRefundProcess := Shop."Return and Refund Process";
        if IReturnRefundProcess.IsImportNeededFor("Shpfy Source Document Type"::Return) then
            ReturnsAPI.GetReturns(OrderHeader."Shopify Order Id", JsonHelper.GetJsonObject(JOrder, 'returns'));
        if IReturnRefundProcess.IsImportNeededFor("Shpfy Source Document Type"::Refund) then
            RefundsAPI.GetRefunds(JsonHelper.GetJsonArray(JOrder, 'refunds'));
    end;

    local procedure SetOrderAsConflicting(var OrderHeader: Record "Shpfy Order Header")
    begin
        OrderHeader."Has Order State Error" := true;
        OrderHeader."Has Error" := true;
        OrderHeader."Error Message" := CopyStr(ProcessedConflictErr, 1, MaxStrLen(OrderHeader."Error Message"));
    end;

    internal procedure MarkOrderConflictAsResolved(var OrderHeader: Record "Shpfy Order Header")
    begin
        OrderHeader."Has Order State Error" := false;
        OrderHeader."Has Error" := false;
        OrderHeader."Error Message" := '';
    end;

    local procedure RetrieveOrderHeaderJson(OrderId: BigInteger; DataCaptureSystemId: Guid; var JOrder: JsonObject): Boolean
    var
        DataCapture: Record "Shpfy Data Capture";
        OrderRetrieved: Boolean;
    begin
        OrderRetrieved := RetrieveOrderHeaderJson(OrderId, JOrder);
        if OrderRetrieved then
            DataCapture.Add(Database::"Shpfy Order Header", DataCaptureSystemId, Format(JOrder));
        exit(OrderRetrieved);
    end;

    local procedure RetrieveOrderHeaderJson(OrderId: BigInteger; var JOrder: JsonObject): Boolean
    var
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
    begin
        Parameters.Add('OrderId', Format(OrderId));
        JResponse := CommunicationMgt.ExecuteGraphQL("Shpfy GraphQL Type"::GetOrderHeader, Parameters);
        exit(JsonHelper.GetJsonObject(JResponse, JOrder, 'data.order'));
    end;

    local procedure RetrieveOrderLinesJson(OrderId: BigInteger; After: Text; var JOrderLines: JsonArray; var HasNextPage: Boolean; var EndCursor: Text): Boolean
    var
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        JPageInfo: JsonObject;
        JResponse: JsonToken;
    begin
        Parameters.Add('OrderId', Format(OrderId));
        GraphQLType := "Shpfy GraphQL Type"::GetOrderLines;
        if After <> '' then begin
            GraphQLType := "Shpfy GraphQL Type"::GetNextOrderLines;
            Parameters.Add('After', After);
        end;

        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
        if JsonHelper.GetJsonObject(JResponse, JPageInfo, 'data.order.lineItems.pageInfo') then begin
            EndCursor := JsonHelper.GetValueAsText(JPageInfo, 'endCursor');
            HasNextPage := JsonHelper.GetValueAsBoolean(JPageInfo, 'hasNextPage');
        end;
        exit(JsonHelper.GetJsonArray(JResponse, JOrderLines, 'data.order.lineItems.nodes'));
    end;

    local procedure SetNewOrderHeaderValuesFromJson(JOrder: JsonObject; var OrderHeader: Record "Shpfy Order Header"): Boolean
    var
        OrderTransaction: Record "Shpfy Order Transaction";
        OrderHeaderRecordRef: RecordRef;
        ICountyFromJson: Interface "Shpfy ICounty From Json";
        OrderId: BigInteger;
        CompanyId: BigInteger;
        MainContactId: BigInteger;
        LocationId: BigInteger;
        CompanyName: Text;
        EMail: Text;
        FirstName: Text;
        LastName: Text;
        Phone: Text;
        JObject: JsonObject;
    begin
        OrderId := JsonHelper.GetValueAsBigInteger(JOrder, 'legacyResourceId');
        if OrderId = 0 then
            exit(false);
        OrderHeader."Shopify Order Id" := OrderId;
        OrderHeader."Shop Code" := Shop.Code;
        ICountyFromJson := Shop."County Source";

        OrderHeaderRecordRef.GetTable(OrderHeader);
        JsonHelper.GetValueIntoField(JOrder, 'name', OrderHeaderRecordRef, OrderHeader.FieldNo("Shopify Order No."));
        JsonHelper.GetValueIntoField(JOrder, 'createdAt', OrderHeaderRecordRef, OrderHeader.FieldNo("Created At"));
        JsonHelper.GetValueIntoField(JOrder, 'createdAt', OrderHeaderRecordRef, OrderHeader.FieldNo("Document Date"));
        EMail := JsonHelper.GetValueAsText(JOrder, 'email');
        if EMail <> '' then
            OrderHeaderRecordRef.Field(OrderHeader.FieldNo(Email)).Value := CopyStr(EMail, 1, MaxStrLen(OrderHeader.Email));
        JsonHelper.GetValueIntoField(JOrder, 'phone', OrderHeaderRecordRef, OrderHeader.FieldNo("Phone No."));
        Phone := JsonHelper.GetValueAsText(JOrder, 'phone');
        if Phone <> '' then
            OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Phone No.")).Value := CopyStr(Phone, 1, MaxStrLen(OrderHeader."Phone No."));
        JsonHelper.GetValueIntoField(JOrder, 'customer.legacyResourceId', OrderHeaderRecordRef, OrderHeader.FieldNo("Customer Id"));
        JsonHelper.GetValueIntoField(JOrder, 'publication.name', OrderHeaderRecordRef, OrderHeader.FieldNo("Channel Name"));
        JsonHelper.GetValueIntoField(JOrder, 'app.name', OrderHeaderRecordRef, OrderHeader.FieldNo("App Name"));
        JsonHelper.GetValueIntoField(JOrder, 'currencyCode', OrderHeaderRecordRef, OrderHeader.FieldNo("Currency Code"));
        JsonHelper.GetValueIntoField(JOrder, 'presentmentCurrencyCode', OrderHeaderRecordRef, OrderHeader.FieldNo("Presentment Currency Code"));
        JsonHelper.GetValueIntoField(JOrder, 'test', OrderHeaderRecordRef, OrderHeader.FieldNo(Test));
        JsonHelper.GetValueIntoField(JOrder, 'edited', OrderHeaderRecordRef, OrderHeader.FieldNo(Edited));
        #region Sell-to Address info
        CompanyName := JsonHelper.GetValueAsText(JOrder, 'displayAddress.company');
        FirstName := JsonHelper.GetValueAsText(JOrder, 'displayAddress.firstName');
        LastName := JsonHelper.GetValueAsText(JOrder, 'displayAddress.lastName');
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Sell-to First Name")).Value := CopyStr(FirstName, 1, MaxStrLen(OrderHeader."Sell-to First Name"));
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Sell-to Last Name")).Value := CopyStr(LastName, 1, MaxStrLen(OrderHeader."Sell-to Last Name"));
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Sell-to Customer Name")).Value := CopyStr(GetName(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Sell-to Customer Name"));
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Sell-to Customer Name 2")).Value := CopyStr(GetName2(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Sell-to Customer Name 2"));
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Sell-to Contact Name")).Value := CopyStr(GetContactName(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Sell-to Contact Name"));
        JsonHelper.GetValueIntoField(JOrder, 'displayAddress.address1', OrderHeaderRecordRef, OrderHeader.FieldNo("Sell-to Address"));
        JsonHelper.GetValueIntoField(JOrder, 'displayAddress.address2', OrderHeaderRecordRef, OrderHeader.FieldNo("Sell-to Address 2"));
        JsonHelper.GetValueIntoField(JOrder, 'displayAddress.city', OrderHeaderRecordRef, OrderHeader.FieldNo("Sell-to City"));
        JsonHelper.GetValueIntoField(JOrder, 'displayAddress.countryCode', OrderHeaderRecordRef, OrderHeader.FieldNo("Sell-to Country/Region Code"));
        JsonHelper.GetValueIntoField(JOrder, 'displayAddress.country', OrderHeaderRecordRef, OrderHeader.FieldNo("Sell-to Country/Region Name"));
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Sell-to County")).Value := ICountyFromJson.County(JsonHelper.GetJsonObject(JOrder, 'displayAddress'));
        JsonHelper.GetValueIntoField(JOrder, 'displayAddress.zip', OrderHeaderRecordRef, OrderHeader.FieldNo("Sell-to Post Code"));
        if EMail = '' then begin
            EMail := JsonHelper.GetValueAsText(JOrder, 'customer.email');
            if EMail <> '' then
                OrderHeaderRecordRef.Field(OrderHeader.FieldNo(Email)).Value := CopyStr(EMail, 1, MaxStrLen(OrderHeader.Email));
        end;
        if Phone = '' then begin
            Phone := JsonHelper.GetValueAsText(JOrder, 'displayAddress.phone');
            if Phone = '' then
                Phone := JsonHelper.GetValueAsText(JOrder, 'customer.phone');
            if Phone = '' then
                Phone := JsonHelper.GetValueAsText(JOrder, 'customer.defaultAddress.phone');
            if Phone <> '' then
                OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Phone No.")).Value := CopyStr(Phone, 1, MaxStrLen(OrderHeader."Phone No."));
        end;
        #endregion
        #region Ship-to Address info
        CompanyName := JsonHelper.GetValueAsText(JOrder, 'shippingAddress.company');
        FirstName := JsonHelper.GetValueAsText(JOrder, 'shippingAddress.firstName');
        LastName := JsonHelper.GetValueAsText(JOrder, 'shippingAddress.lastName');
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Ship-to First Name")).Value := CopyStr(FirstName, 1, MaxStrLen(OrderHeader."Ship-to First Name"));
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Ship-to Last Name")).Value := CopyStr(LastName, 1, MaxStrLen(OrderHeader."Ship-to Last Name"));
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Ship-to Name")).Value := CopyStr(GetName(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Ship-to Name"));
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Ship-to Name 2")).Value := CopyStr(GetName2(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Ship-to Name 2"));
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Ship-to Contact Name")).Value := CopyStr(GetContactName(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Ship-to Contact Name"));
        JsonHelper.GetValueIntoField(JOrder, 'shippingAddress.address1', OrderHeaderRecordRef, OrderHeader.FieldNo("Ship-to Address"));
        JsonHelper.GetValueIntoField(JOrder, 'shippingAddress.address2', OrderHeaderRecordRef, OrderHeader.FieldNo("Ship-to Address 2"));
        JsonHelper.GetValueIntoField(JOrder, 'shippingAddress.city', OrderHeaderRecordRef, OrderHeader.FieldNo("Ship-to City"));
        JsonHelper.GetValueIntoField(JOrder, 'shippingAddress.countryCode', OrderHeaderRecordRef, OrderHeader.FieldNo("Ship-to Country/Region Code"));
        JsonHelper.GetValueIntoField(JOrder, 'shippingAddress.country', OrderHeaderRecordRef, OrderHeader.FieldNo("Ship-to Country/Region Name"));
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Ship-to County")).Value := ICountyFromJson.County(JsonHelper.GetJsonObject(JOrder, 'shippingAddress'));
        JsonHelper.GetValueIntoField(JOrder, 'shippingAddress.zip', OrderHeaderRecordRef, OrderHeader.FieldNo("Ship-to Post Code"));
        JsonHelper.GetValueIntoField(JOrder, 'shippingAddress.latitude', OrderHeaderRecordRef, OrderHeader.FieldNo("Ship-to Latitude"));
        JsonHelper.GetValueIntoField(JOrder, 'shippingAddress.longitude', OrderHeaderRecordRef, OrderHeader.FieldNo("Ship-to Longitude"));
        if Phone = '' then begin
            Phone := JsonHelper.GetValueAsText(JOrder, 'shippingAddress.phone');
            if Phone <> '' then
                OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Phone No.")).Value := CopyStr(Phone, 1, MaxStrLen(OrderHeader."Phone No."));
        end;
        #endregion
        #region Bill-to Address info
        CompanyName := JsonHelper.GetValueAsText(JOrder, 'billingAddress.company');
        FirstName := JsonHelper.GetValueAsText(JOrder, 'billingAddress.firstName');
        LastName := JsonHelper.GetValueAsText(JOrder, 'billingAddress.lastName');
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Bill-to First Name")).Value := CopyStr(FirstName, 1, MaxStrLen(OrderHeader."Bill-to First Name"));
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Bill-to Lastname")).Value := CopyStr(LastName, 1, MaxStrLen(OrderHeader."Bill-to Lastname"));
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Bill-to Name")).Value := CopyStr(GetName(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Bill-to Name"));
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Bill-to Name 2")).Value := CopyStr(GetName2(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Bill-to Name 2"));
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Bill-to Contact Name")).Value := CopyStr(GetContactName(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Bill-to Contact Name"));
        JsonHelper.GetValueIntoField(JOrder, 'billingAddress.address1', OrderHeaderRecordRef, OrderHeader.FieldNo("Bill-to Address"));
        JsonHelper.GetValueIntoField(JOrder, 'billingAddress.address2', OrderHeaderRecordRef, OrderHeader.FieldNo("Bill-to Address 2"));
        JsonHelper.GetValueIntoField(JOrder, 'billingAddress.city', OrderHeaderRecordRef, OrderHeader.FieldNo("Bill-to City"));
        JsonHelper.GetValueIntoField(JOrder, 'billingAddress.countryCode', OrderHeaderRecordRef, OrderHeader.FieldNo("Bill-to Country/Region Code"));
        JsonHelper.GetValueIntoField(JOrder, 'billingAddress.country', OrderHeaderRecordRef, OrderHeader.FieldNo("Bill-to Country/Region Name"));
        OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Bill-to County")).Value := ICountyFromJson.County(JsonHelper.GetJsonObject(JOrder, 'billingAddress'));
        JsonHelper.GetValueIntoField(JOrder, 'billingAddress.zip', OrderHeaderRecordRef, OrderHeader.FieldNo("Bill-to Post Code"));
        if Phone = '' then begin
            Phone := JsonHelper.GetValueAsText(JOrder, 'billingAddress.phone');
            if Phone <> '' then
                OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Phone No.")).Value := CopyStr(Phone, 1, MaxStrLen(OrderHeader."Phone No."));
        end;
        #endregion
        #region B2B
        if JsonHelper.GetJsonObject(JOrder, JObject, 'purchasingEntity') then begin
            if JsonHelper.GetJsonObject(JOrder, JObject, 'purchasingEntity.company') then begin
                CompanyId := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JOrder, 'purchasingEntity.company.id'));
                OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Company Id")).Value := CompanyId;
                MainContactId := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JOrder, 'purchasingEntity.company.mainContact.id'));
                OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Company Main Contact Id")).Value := MainContactId;
                JsonHelper.GetValueIntoField(JOrder, 'purchasingEntity.company.mainContact.customer.legacyResourceId', OrderHeaderRecordRef, OrderHeader.FieldNo("Company Main Contact Cust. Id"));
                JsonHelper.GetValueIntoField(JOrder, 'purchasingEntity.company.mainContact.customer.email', OrderHeaderRecordRef, OrderHeader.FieldNo("Company Main Contact Email"));
                JsonHelper.GetValueIntoField(JOrder, 'purchasingEntity.company.mainContact.customer.phone', OrderHeaderRecordRef, OrderHeader.FieldNo("Company Main Contact Phone No."));
                if Format(OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Sell-to Customer Name")).Value) = '' then
                    JsonHelper.GetValueIntoField(JOrder, 'purchasingEntity.company.name', OrderHeaderRecordRef, OrderHeader.FieldNo("Sell-to Customer Name"));
            end;
            if JsonHelper.GetJsonObject(JOrder, JObject, 'purchasingEntity.location') then begin
                LocationId := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JOrder, 'purchasingEntity.location.id'));
                OrderHeaderRecordRef.Field(OrderHeader.FieldNo("Company Location Id")).Value := LocationId;
            end;
        end;
        #endregion
        OrderHeaderRecordRef.SetTable(OrderHeader);
        OrderHeader."Currency Code" := TranslateCurrencyCode(OrderHeader."Currency Code");
        OrderHeader."Presentment Currency Code" := TranslateCurrencyCode(OrderHeader."Presentment Currency Code");
        OrderTransaction.SetRange("Shopify Order Id", OrderId);
        OrderTransaction.SetFilter(Status, '%1|%2', "Shpfy Transaction Status"::Pending, "Shpfy Transaction Status"::Success);
        OrderTransaction.SetFilter(Type, '%1|%2', "Shpfy Transaction Type"::Sale, "Shpfy Transaction Type"::Capture);
        OrderTransaction.SetCurrentKey(Amount, "Shopify Order Id", Status, Type);
        OrderTransaction.SetAscending(Amount, false);
        if OrderTransaction.FindFirst() then
            OrderHeader.Gateway := OrderTransaction.Gateway;
        exit(true);
    end;

    local procedure SetEditableOrderHeaderValuesFromJson(JOrder: JsonObject; var OrderHeader: Record "Shpfy Order Header")
    var
        OrderHeaderRecordRef: RecordRef;
        JObject: JsonObject;
    begin
        OrderHeaderRecordRef.GetTable(OrderHeader);
        JsonHelper.GetValueIntoField(JOrder, 'confirmed', OrderHeaderRecordRef, OrderHeader.FieldNo(Confirmed));
        JsonHelper.GetValueIntoField(JOrder, 'updatedAt', OrderHeaderRecordRef, OrderHeader.FieldNo("Updated At"));
        JsonHelper.GetValueIntoField(JOrder, 'cancelledAt', OrderHeaderRecordRef, OrderHeader.FieldNo("Cancelled At"));
        JsonHelper.GetValueIntoField(JOrder, 'closed', OrderHeaderRecordRef, OrderHeader.FieldNo(Closed));
        JsonHelper.GetValueIntoField(JOrder, 'closedAt', OrderHeaderRecordRef, OrderHeader.FieldNo("Closed At"));
        JsonHelper.GetValueIntoField(JOrder, 'processedAt', OrderHeaderRecordRef, OrderHeader.FieldNo("Processed At"));
        JsonHelper.GetValueIntoField(JOrder, 'unpaid', OrderHeaderRecordRef, OrderHeader.FieldNo(Unpaid));
        JsonHelper.GetValueIntoField(JOrder, 'fullyPaid', OrderHeaderRecordRef, OrderHeader.FieldNo("Fully Paid"));
        JsonHelper.GetValueIntoField(JOrder, 'discountCode', OrderHeaderRecordRef, OrderHeader.FieldNo("Discount Code"));
        JsonHelper.GetValueIntoField(JOrder, 'discountCodes', OrderHeaderRecordRef, OrderHeader.FieldNo("Discount Codes"));
        JsonHelper.GetValueIntoField(JOrder, 'totalWeight', OrderHeaderRecordRef, OrderHeader.FieldNo("Total Weight"));
        JsonHelper.GetValueIntoField(JOrder, 'refundable', OrderHeaderRecordRef, OrderHeader.FieldNo(Refundable));
        JsonHelper.GetValueIntoField(JOrder, 'taxesIncluded', OrderHeaderRecordRef, OrderHeader.FieldNo("VAT Included"));
        JsonHelper.GetValueIntoField(JOrder, 'totalPriceSet.shopMoney.amount', OrderHeaderRecordRef, OrderHeader.FieldNo("Total Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'totalPriceSet.presentmentMoney.amount', OrderHeaderRecordRef, OrderHeader.FieldNo("Presentment Total Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'subtotalPriceSet.shopMoney.amount', OrderHeaderRecordRef, OrderHeader.FieldNo("Subtotal Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'subtotalPriceSet.presentmentMoney.amount', OrderHeaderRecordRef, OrderHeader.FieldNo("Presentment Subtotal Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'totalTipReceivedSet.shopMoney.amount', OrderHeaderRecordRef, OrderHeader.FieldNo("Total Tip Received"));
        JsonHelper.GetValueIntoField(JOrder, 'totalTipReceivedSet.presentmentMoney.amount', OrderHeaderRecordRef, OrderHeader.FieldNo("Presentment Total Tip Received"));
        JsonHelper.GetValueIntoField(JOrder, 'totalTaxSet.shopMoney.amount', OrderHeaderRecordRef, OrderHeader.FieldNo("VAT Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'totalTaxSet.presentmentMoney.amount', OrderHeaderRecordRef, OrderHeader.FieldNo("Presentment VAT Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'currentTotalDiscountsSet.shopMoney.amount', OrderHeaderRecordRef, OrderHeader.FieldNo("Discount Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'currentTotalDiscountsSet.presentmentMoney.amount', OrderHeaderRecordRef, OrderHeader.FieldNo("Presentment Discount Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'totalShippingPriceSet.shopMoney.amount', OrderHeaderRecordRef, OrderHeader.FieldNo("Shipping Charges Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'totalShippingPriceSet.presentmentMoney.amount', OrderHeaderRecordRef, OrderHeader.FieldNo("Pres. Shipping Charges Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'currentTotalPriceSet.shopMoney.amount', OrderHeaderRecordRef, OrderHeader.FieldNo("Current Total Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'currentSubtotalLineItemsQuantity', OrderHeaderRecordRef, OrderHeader.FieldNo("Current Total Items Quantity"));
        JsonHelper.GetValueIntoField(Jorder, 'poNumber', OrderHeaderRecordRef, OrderHeader.FieldNo("PO Number"));
        JsonHelper.GetValueIntoField(JOrder, 'paymentTerms.paymentTermsType', OrderHeaderRecordRef, OrderHeader.FieldNo("Payment Terms Type"));
        JsonHelper.GetValueIntoField(JOrder, 'paymentTerms.paymentTermsName', OrderHeaderRecordRef, OrderHeader.FieldNo("Payment Terms Name"));
        OrderHeaderRecordRef.SetTable(OrderHeader);
        if JsonHelper.GetJsonObject(JOrder, JObject, 'purchasingEntity') then
            if JsonHelper.GetJsonObject(JOrder, JObject, 'purchasingEntity.company') then
                OrderHeader.B2B := true
            else
                OrderHeader.B2B := false
        else
            OrderHeader.B2B := false;
        OrderHeader."Cancel Reason" := ConvertToCancelReason(JsonHelper.GetValueAsText(JOrder, 'cancelReason'));
        OrderHeader."Financial Status" := ConvertToFinancialStatus(JsonHelper.GetValueAsText(JOrder, 'displayFinancialStatus'));
        OrderHeader."Fulfillment Status" := ConvertToFulfillmentStatus(JsonHelper.GetValueAsText(JOrder, 'displayFulfillmentStatus'));
        OrderHeader."Return Status" := ConvertToOrderReturnStatus(JsonHelper.GetValueAsText(JOrder, 'returnStatus'));
        OrderHeader."Risk Level" := ConvertToRiskLevel(JsonHelper.GetValueAsText(JOrder, 'riskLevel'));
    end;

    local procedure SetOrderHeaderValuesFromJson(JOrder: JsonObject; SetOnlyEditableFields: Boolean; var OrderHeader: Record "Shpfy Order Header"): Boolean
    begin
        if not SetOnlyEditableFields then
            if not SetNewOrderHeaderValuesFromJson(JOrder, OrderHeader) then
                exit(false);
        SetEditableOrderHeaderValuesFromJson(JOrder, OrderHeader);
        exit(true);
    end;

    local procedure SetOrderLineValuesFromJson(JOrderLine: JsonToken; OrderId: BigInteger; var OrderLine: Record "Shpfy Order Line"): Boolean
    var
        LocalOrderLine: Record "Shpfy Order Line";
        OrderLineRecordRef: RecordRef;
        LineId: BigInteger;
    begin
        LineId := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JOrderLine, 'id'));
        OrderLine."Shopify Order Id" := OrderId;
        OrderLine."Line Id" := LineId;
        if LocalOrderLine.Get(OrderId, LineId) then
            OrderLine.Copy(LocalOrderLine);
        OrderLineRecordRef.GetTable(OrderLine);
        if (JsonHelper.GetValueAsText(JOrderLine, 'name') = 'Tip') and JsonHelper.IsNull(JOrderLine, 'product') then
            OrderLineRecordRef.Field(OrderLine.FieldNo(Tip)).Value := true;
        JsonHelper.GetValueIntoField(JOrderLine, 'product.legacyResourceId', OrderLineRecordRef, OrderLine.FieldNo("Shopify Product Id"));
        JsonHelper.GetValueIntoField(JOrderLine, 'title', OrderLineRecordRef, OrderLine.FieldNo(Description));
        JsonHelper.GetValueIntoField(JOrderLine, 'quantity', OrderLineRecordRef, OrderLine.FieldNo(Quantity));
        JsonHelper.GetValueIntoField(JOrderLine, 'variant.legacyResourceId', OrderLineRecordRef, OrderLine.FieldNo("Shopify Variant Id"));
        JsonHelper.GetValueIntoField(JOrderLine, 'variantTitle', OrderLineRecordRef, OrderLine.FieldNo("Variant Description"));
        JsonHelper.GetValueIntoField(JOrderLine, 'fulfillmentService.location.legacyResourceId', OrderLineRecordRef, OrderLine.FieldNo("Location Id"));
        JsonHelper.GetValueIntoField(JOrderLine, 'fulfillableQuantity', OrderLineRecordRef, OrderLine.FieldNo("Fulfillable Quantity"));
        JsonHelper.GetValueIntoField(JOrderLine, 'fulfillmentService.serviceName', OrderLineRecordRef, OrderLine.FieldNo("Fulfillment Service"));
        JsonHelper.GetValueIntoField(JOrderLine, 'product.isGiftCard', OrderLineRecordRef, OrderLine.FieldNo("Gift Card"));
        JsonHelper.GetValueIntoField(JOrderLine, 'taxable', OrderLineRecordRef, OrderLine.FieldNo(Taxable));
        JsonHelper.GetValueIntoField(JOrderLine, 'originalUnitPriceSet.shopMoney.amount', OrderLineRecordRef, OrderLine.FieldNo("Unit Price"));
        JsonHelper.GetValueIntoField(JOrderLine, 'originalUnitPriceSet.presentmentMoney.amount', OrderLineRecordRef, OrderLine.FieldNo("Presentment Unit Price"));
        OrderLineRecordRef.SetTable(OrderLine);
        OrderLine."Discount Amount" := GetTotalLineDiscountAmount(JsonHelper.GetJsonArray(JOrderLine, 'discountAllocations'), 'shopMoney');
        OrderLine."Presentment Discount Amount" := GetTotalLineDiscountAmount(JsonHelper.GetJsonArray(JOrderLine, 'discountAllocations'), 'presentmentMoney');
        exit(true);
    end;

    local procedure RetrieveAndSetOrderLines(OrderId: BigInteger; var OrderLine: Record "Shpfy Order Line" temporary; var DataCaptureDict: Dictionary of [BigInteger, JsonToken])
    var
        JOrderLines: JsonArray;
        After: Text;
        HasNextPage: Boolean;
        EndCursor: Text;
    begin
        repeat
            RetrieveOrderLinesJson(OrderId, After, JOrderLines, HasNextPage, EndCursor);
            SetAndInsertOrderLines(OrderId, JOrderLines, OrderLine, DataCaptureDict);
            After := EndCursor;
        until not HasNextPage;
    end;

    local procedure SetAndInsertOrderLines(OrderId: BigInteger; JOrderLines: JsonArray; var TempOrderLine: Record "Shpfy Order Line" temporary; var DataCaptureDict: Dictionary of [BigInteger, JsonToken])
    var
        JOrderLine: JsonToken;
    begin
        foreach JOrderLine in JOrderLines do
            if SetOrderLineValuesFromJson(JOrderLine, OrderId, TempOrderLine) then begin
                TempOrderLine.Insert();
                DataCaptureDict.Add(TempOrderLine."Line Id", JOrderLine);
            end;
    end;

    local procedure TranslateCurrencyCode(ShopifyCurrencyCode: Text): Code[10]
    var
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencyCode: Code[10];
        IsHandled: Boolean;
    begin
        OrderEvents.OnBeforeTranslateCurrencyCode(ShopifyCurrencyCode, CurrencyCode, IsHandled);
        if not IsHandled then
            Currency.SetLoadFields(Code);
        Currency.SetRange("ISO Code", CopyStr(ShopifyCurrencyCode, 1, 3));
        if Currency.FindFirst() then
            CurrencyCode := Currency.Code;
        GeneralLedgerSetup.Get();
        if CurrencyCode = GeneralLedgerSetup."LCY Code" then
            exit('')
        else
            exit(CurrencyCode);
    end;

    local procedure ImportCustomAttributtes(ShopifyOrderId: BigInteger; JCustomAttributtes: JsonArray)
    var
        OrderAttribute: Record "Shpfy Order Attribute";
        JToken: JsonToken;
    begin
        OrderAttribute.SetRange("Order Id", ShopifyOrderId);
        if not OrderAttribute.IsEmpty() then
            OrderAttribute.DeleteAll();
        foreach JToken in JCustomAttributtes do begin
            Clear(OrderAttribute);
            OrderAttribute."Order Id" := ShopifyOrderId;
            OrderAttribute.Key := CopyStr(JsonHelper.GetValueAsText(JToken, 'key', MaxStrLen(OrderAttribute."Key")), 1, MaxStrLen(OrderAttribute."Key"));
#if not CLEAN24
            if not Shop."Replace Order Attribute Value" then
                OrderAttribute.Value := CopyStr(JsonHelper.GetValueAsText(JToken, 'value', MaxStrLen(OrderAttribute.Value)), 1, MaxStrLen(OrderAttribute.Value))
            else
#endif
            OrderAttribute."Attribute Value" := CopyStr(JsonHelper.GetValueAsText(JToken, 'value', MaxStrLen(OrderAttribute."Attribute Value")), 1, MaxStrLen(OrderAttribute."Attribute Value"));
            OrderAttribute.Insert();
        end;
    end;

    local procedure ImportCustomAttributtes(ShopifyOrderId: BigInteger; OrderLineId: Guid; JCustomAttributtes: JsonArray)
    var
        OrderLineAttribute: Record "Shpfy Order Line Attribute";
        JToken: JsonToken;
    begin
        OrderLineAttribute.SetRange("Order Id", ShopifyOrderId);
        OrderLineAttribute.SetRange("Order Line Id", OrderLineId);
        if not OrderLineAttribute.IsEmpty() then
            OrderLineAttribute.DeleteAll();
        foreach JToken in JCustomAttributtes do begin
            Clear(OrderLineAttribute);
            OrderLineAttribute."Order Id" := ShopifyOrderId;
            OrderLineAttribute."Order Line Id" := OrderLineId;
            OrderLineAttribute.Key := JsonHelper.GetValueAsText(JToken, 'key', MaxStrLen(OrderLineAttribute."Key"));
            OrderLineAttribute.Value := JsonHelper.GetValueAsText(JToken, 'value', MaxStrLen(OrderLineAttribute.Value));
            OrderLineAttribute.Insert();
        end;
    end;

    local procedure ImportRisks(OrderHeader: Record "Shpfy Order Header"; JRisks: JsonArray)
    var
        ShpfyOrderRisks: Codeunit "Shpfy Order Risks";
    begin
        ShpfyOrderRisks.UpdateOrderRisks(OrderHeader, JRisks);
    end;

    /// <summary> 
    /// Description for GetTotalLineDiscountAmount.
    /// </summary>
    /// <param name="JDiscountSets">Parameter of type JsonArray.</param>
    /// <param name="MoneyType">Parameter of type Text.</param>
    /// <returns>Return variable "Decimal".</returns>
    local procedure GetTotalLineDiscountAmount(JDiscountSets: JsonArray; MoneyType: Text) Result: Decimal
    var
        JDiscountSet: JsonToken;
    begin
        foreach JDiscountSet in JDiscountSets do
            Result += JsonHelper.GetValueAsDecimal(JDiscountSet, 'allocatedAmountSet.' + MoneyType + '.amount');
    end;

    /// <summary> 
    /// Description for CheckToCloseOrder.
    /// </summary>
    /// <param name="OrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <returns>Return variable "Boolean".</returns>
    local procedure CheckToCloseOrder(OrderHeader: Record "Shpfy Order Header"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        if ((OrderHeader."Sales Order No." <> '') and (OrderHeader."Fulfillment Status" = OrderHeader."Fulfillment Status"::Fulfilled))
            and (OrderHeader."Fully Paid") then begin
            SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
            SalesLine.SetRange("Document No.", OrderHeader."Sales Order No.");
            SalesLine.SetFilter("Outstanding Quantity", '<>%1', 0);
            exit(SalesLine.IsEmpty());
        end;

        exit((OrderHeader."Sales Invoice No." <> '') and (OrderHeader."Fulfillment Status" = OrderHeader."Fulfillment Status"::Fulfilled));
    end;

    /// <summary> 
    /// Description for CloseOrder.
    /// </summary>
    /// <param name="OrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure CloseOrder(var OrderHeader: Record "Shpfy Order Header")
    var
        OrderHeaderRecordRef: RecordRef;
        JResponse: JsonToken;
        Parameters: Dictionary of [Text, Text];
    begin
        CommunicationMgt.SetShop(OrderHeader."Shop Code");
        Parameters.Add('OrderId', Format(OrderHeader."Shopify Order Id"));
        JResponse := CommunicationMgt.ExecuteGraphQL("Shpfy GraphQL Type"::CloseOrder, Parameters);
        if JsonHelper.GetValueAsBigInteger(JResponse, 'data.orderClose.order.legacyResourceId') = OrderHeader."Shopify Order Id" then begin
            OrderHeaderRecordRef.GetTable(OrderHeader);
            JsonHelper.GetValueIntoField(JResponse, 'data.orderClose.order.closed', OrderHeaderRecordRef, OrderHeader.FieldNo(Closed));
            if OrderHeaderRecordRef.Field(OrderHeader.FieldNo(Closed)).Value then
                JsonHelper.GetValueIntoField(JResponse, 'data.orderClose.order.closedAt', OrderHeaderRecordRef, OrderHeader.FieldNo("Closed At"))
            else
                OrderHeaderRecordRef.Field(OrderHeader.FieldNo(OrderHeader."Closed At")).Value := 0DT;
            OrderHeaderRecordRef.Modify();
        end;
        OrderHeader.Validate(Closed, true);
        OrderHeader.Modify();
    end;

    /// <summary> 
    /// Add Tax Lines.
    /// </summary>
    /// <param name="ParentId">Parameter of type BigInteger.</param>
    /// <param name="JTaxLines">Parameter of type JsonArray.</param>
    local procedure AddTaxLines(ParentId: BigInteger; JTaxLines: JsonArray)
    var
        OrderTaxLine: Record "Shpfy Order Tax Line";
        RecordRef: RecordRef;
        JToken: JsonToken;
    begin
        OrderTaxLine.SetRange("Parent Id", ParentId);
        if not OrderTaxLine.IsEmpty() then
            OrderTaxLine.DeleteAll();
        foreach JToken in JTaxLines do begin
            RecordRef.Open(Database::"Shpfy Order Tax Line");
            RecordRef.Init();
            RecordRef.Field(OrderTaxLine.FieldNo("Parent Id")).Value := ParentId;
            JsonHelper.GetValueIntoField(JToken, 'title', RecordRef, OrderTaxLine.FieldNo(Title));
            JsonHelper.GetValueIntoField(JToken, 'rate', RecordRef, OrderTaxLine.FieldNo(Rate));
            JsonHelper.GetValueIntoField(JToken, 'ratePercentage', RecordRef, OrderTaxLine.FieldNo("Rate %"));
            JsonHelper.GetValueIntoField(JToken, 'priceSet.shopMoney.amount', RecordRef, OrderTaxLine.FieldNo(Amount));
            JsonHelper.GetValueIntoField(JToken, 'priceSet.presentmentMoney.amount', RecordRef, OrderTaxLine.FieldNo("Presentment Amount"));
            RecordRef.Insert(true);
            RecordRef.Close();
        end;
    end;

    /// <summary> 
    /// Description for GetName.
    /// </summary>
    /// <param name="FirstName">Parameter of type Text.</param>
    /// <param name="LastName">Parameter of type Text.</param>
    /// <param name="CompanyName">Parameter of type Text.</param>
    /// <returns>Return variable "Text".</returns>
    local procedure GetName(FirstName: Text; LastName: Text; CompanyName: Text) Result: Text
    var
        IName: Interface "Shpfy ICustomer Name";
    begin
        IName := Shop."Name Source";
        Result := IName.GetName(FirstName, LastName, CompanyName);
        if Result = '' then begin
            IName := Shop."Name 2 Source";
            Result := IName.GetName(FirstName, LastName, CompanyName);
        end;
    end;

    /// <summary> 
    /// Description for GetName2.
    /// </summary>
    /// <param name="FirstName">Parameter of type Text.</param>
    /// <param name="LastName">Parameter of type Text.</param>
    /// <param name="CompanyName">Parameter of type Text.</param>
    /// <returns>Return variable "Text".</returns>
    local procedure GetName2(FirstName: Text; LastName: Text; CompanyName: Text) Result: Text
    var
        IName: Interface "Shpfy ICustomer Name";
    begin
        IName := Shop."Name 2 Source";
        Result := IName.GetName(FirstName, LastName, CompanyName);
        if Result = GetName(FirstName, LastName, CompanyName) then
            Result := '';
    end;

    local procedure GetContactName(FirstName: Text; LastName: Text; CompanyName: Text) Result: Text
    var
        IName: Interface "Shpfy ICustomer Name";
    begin
        IName := Shop."Contact Source";
        Result := IName.GetName(FirstName, LastName, CompanyName);
    end;


    local procedure ConvertToFinancialStatus(Value: Text) FinancialStatus: Enum "Shpfy Financial Status"
    var
        IsHandled: Boolean;
    begin
        OrderEvents.OnBeforeConvertToFinancialStatus(Value, FinancialStatus, IsHandled);
        if IsHandled then
            exit;

        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Financial Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Financial Status".FromInteger(Enum::"Shpfy Financial Status".Ordinals().Get(Enum::"Shpfy Financial Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Financial Status"::Unknown);
    end;

    local procedure ConvertToFulfillmentStatus(Value: Text) OrderFulfillStatus: Enum "Shpfy Order Fulfill. Status"
    var
        IsHandled: Boolean;
    begin
        OrderEvents.OnBeforeConvertToFulfillmentStatus(Value, OrderFulfillStatus, IsHandled);
        if IsHandled then
            exit;

        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Order Fulfill. Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Order Fulfill. Status".FromInteger(Enum::"Shpfy Order Fulfill. Status".Ordinals().Get(Enum::"Shpfy Order Fulfill. Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Order Fulfill. Status"::" ");
    end;

    local procedure ConvertToRiskLevel(Value: Text): Enum "Shpfy Risk Level"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Risk Level".Names().Contains(Value) then
            exit(Enum::"Shpfy Risk Level".FromInteger(Enum::"Shpfy Risk Level".Ordinals().Get(Enum::"Shpfy Risk Level".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Risk Level"::" ");
    end;

    local procedure ConvertToCancelReason(Value: Text): Enum "Shpfy Cancel Reason"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Cancel Reason".Names().Contains(Value) then
            exit(Enum::"Shpfy Cancel Reason".FromInteger(Enum::"Shpfy Cancel Reason".Ordinals().Get(Enum::"Shpfy Cancel Reason".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Cancel Reason"::Unknown);
    end;

    local procedure UpdateLocationIdAndDeliveryMethodOnOrderLine(var OrderLine: Record "Shpfy Order Line")
    var
        FulfillmentOrderLine: Record "Shpfy FulFillment Order Line";
    begin
        FulfillmentOrderLine.Reset();
        FulfillmentOrderLine.SetRange("Shopify Order Id", OrderLine."Shopify Order Id");
        FulfillmentOrderLine.SetRange("Shopify Variant Id", OrderLine."Shopify Variant Id");
        FulfillmentOrderLine.SetFilter("Fulfillment Status", '<>%1', 'CLOSED');
        if FulfillmentOrderLine.FindSet() then
            UpdateLocationIdAndDeliveryMethodOnOrderLines(OrderLine, FulfillmentOrderLine)
        else begin
            FulfillmentOrderLine.SetRange("Fulfillment Status");
            UpdateLocationIdAndDeliveryMethodOnOrderLines(OrderLine, FulfillmentOrderLine);
        end;
    end;

    local procedure UpdateLocationIdAndDeliveryMethodOnOrderLines(var OrderLine: Record "Shpfy Order Line"; var FulfillmentOrderLine: Record "Shpfy FulFillment Order Line")
    var
        TotalQuantity: Integer;
    begin
        if FulfillmentOrderLine.FindSet() then begin
            repeat
                TotalQuantity += FulfillmentOrderLine."Total Quantity";
            until FulfillmentOrderLine.Next() = 0;

            if TotalQuantity = OrderLine.Quantity then begin
                OrderLine."Location Id" := FulfillmentOrderLine."Shopify Location Id";
                OrderLine."Delivery Method Type" := FulfillmentOrderLine."Delivery Method Type";
            end;
        end;
    end;

    local procedure ConvertToOrderReturnStatus(Value: Text) OrderReturnStatus: Enum "Shpfy Order Return Status"
    var
        IsHandled: Boolean;
    begin
        OrderEvents.OnBeforeConvertToOrderReturnStatus(Value, OrderReturnStatus, IsHandled);
        if IsHandled then
            exit;

        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Order Return Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Order Return Status".FromInteger(Enum::"Shpfy Order Return Status".Ordinals().Get(Enum::"Shpfy Order Return Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Order Return Status"::" ");
    end;
}