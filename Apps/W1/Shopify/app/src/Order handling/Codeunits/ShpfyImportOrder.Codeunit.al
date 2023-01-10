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
        Import(Rec);
    end;

    var
        Shop: record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        OrderEvents: Codeunit "Shpfy Order Events";
        IsTestInProgress: Boolean;

    local procedure Import(OrdersToImport: Record "Shpfy Orders to Import")
    var
        ShpfyDataCapture: Record "Shpfy Data Capture";
        ShpfyOrderHeader: Record "Shpfy Order Header";
        ShpfyOrderLine: Record "Shpfy Order Line";
        Paramters: Dictionary of [Text, Text];
        ShpfyGraphQLType: Enum "Shpfy GraphQL Type";
        JOrderLines: JsonArray;
        JOrder: JsonObject;
        JPageInfo: JsonObject;
        JOrderLine: JsonToken;
        JResponse: JsonToken;
    begin
        if Shop.Get(OrdersToImport."Shop Code") then begin
            CommunicationMgt.SetShop(Shop);
            Paramters.Add('OrderId', Format(OrdersToImport.Id));
            ShpfyGraphQLType := "Shpfy GraphQL Type"::GetOrderHeader;
            JResponse := CommunicationMgt.ExecuteGraphQL(ShpfyGraphQLType, Paramters);
            if JsonHelper.GetJsonObject(JResponse, JOrder, 'data.order') then begin
                ImportOrderHeader(OrdersToImport, ShpfyOrderHeader, JOrder);
                ShpfyDataCapture.Add(Database::"Shpfy Order Header", ShpfyOrderHeader.SystemId, Format(JOrder));
                ShpfyGraphQLType := "Shpfy GraphQL Type"::GetOrderLines;
                repeat
                    JResponse := CommunicationMgt.ExecuteGraphQL(ShpfyGraphQLType, Paramters);
                    if JsonHelper.GetJsonObject(JResponse, JPageInfo, 'data.order.lineItems.pageInfo') then
                        Paramters.Add('After', JsonHelper.GetValueAsText(JPageInfo, 'endCursor'));
                    if JsonHelper.GetJsonArray(JResponse, JOrderLines, 'data.order.lineItems.nodes') then
                        foreach JOrderLine in JOrderLines do begin
                            ImportOrderLine(ShpfyOrderHeader, ShpfyOrderLine, JOrderLine);
                            ShpfyDataCapture.Add(Database::"Shpfy Order Line", ShpfyOrderLine.SystemId, Format(JOrderLine));
                        end;
                    ShpfyGraphQLType := "Shpfy GraphQL Type"::GetNextOrderLines;
                until not JsonHelper.GetValueAsBoolean(JPageInfo, 'hasNextPage');
                if CheckToCloseOrder(ShpfyOrderHeader) then
                    CloseOrder(ShpfyOrderHeader);
            end;
        end;
    end;

    [NonDebuggable]
    internal procedure ImportOrderHeader(OrdersToImport: Record "Shpfy Orders to Import"; var ShpfyOrderHeader: Record "Shpfy Order Header"; JOrder: JsonObject)
    var
        ShpfyOrderTransaction: Record "Shpfy Order Transaction";
        ShpfyOrderFulfillments: Codeunit "Shpfy Order Fulfillments";
        ShpfyShippingCharges: Codeunit "Shpfy Shipping Charges";
        ShpfyTransactions: Codeunit "Shpfy Transactions";
        ShpfyOrderHeaderRecordRef: RecordRef;
        OrderId: BigInteger;
        IsNew: Boolean;
        CompanyName: Text;
        EMail: Text;
        FirstName: Text;
        LastName: Text;
        Phone: Text;
    begin
        OrderId := JsonHelper.GetValueAsBigInteger(JOrder, 'legacyResourceId');
        if OrderId = 0 then exit;

        if not ShpfyOrderHeader.Get(OrderId) then begin
            Clear(ShpfyOrderHeader);
            ShpfyOrderHeader."Shopify Order Id" := OrderId;
            ShpfyOrderHeader."Shop Code" := OrdersToImport."Shop Code";
            ShpfyOrderHeader.Insert();
            IsNew := true;
        end;

        ShpfyOrderHeaderRecordRef.GetTable(ShpfyOrderHeader);

        if IsNew then begin
            JsonHelper.GetValueIntoField(JOrder, 'name', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Shopify Order No."));
            JsonHelper.GetValueIntoField(JOrder, 'createdAt', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Created At"));
            JsonHelper.GetValueIntoField(JOrder, 'createdAt', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Document Date"));
            EMail := JsonHelper.GetValueAsText(JOrder, 'email');
            if EMail <> '' then
                ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo(Email)).Value := CopyStr(EMail, 1, MaxStrLen(ShpfyOrderHeader.Email));
            JsonHelper.GetValueIntoField(JOrder, 'phone', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Phone No."));
            Phone := JsonHelper.GetValueAsText(JOrder, 'phone');
            if Phone <> '' then
                ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Phone No.")).Value := CopyStr(Phone, 1, MaxStrLen(ShpfyOrderHeader."Phone No."));
            JsonHelper.GetValueIntoField(JOrder, 'customer.legacyResourceId', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Customer Id"));
            JsonHelper.GetValueIntoField(JOrder, 'publication.name', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Channel Name"));
            JsonHelper.GetValueIntoField(JOrder, 'app.name', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("App Name"));
            JsonHelper.GetValueIntoField(JOrder, 'currencyCode', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Currency Code"));
            JsonHelper.GetValueIntoField(JOrder, 'presentmentCurrencyCode', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Presentment Currency Code"));
            JsonHelper.GetValueIntoField(JOrder, 'test', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo(Test));
            #region Sell-to Address info
            CompanyName := JsonHelper.GetValueAsText(JOrder, 'displayAddress.company');
            FirstName := JsonHelper.GetValueAsText(JOrder, 'displayAddress.firstName');
            LastName := JsonHelper.GetValueAsText(JOrder, 'displayAddress.lastName');
            ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Sell-to First Name")).Value := CopyStr(FirstName, 1, MaxStrLen(ShpfyOrderHeader."Sell-to First Name"));
            ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Sell-to Last Name")).Value := CopyStr(LastName, 1, MaxStrLen(ShpfyOrderHeader."Sell-to Last Name"));
            ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Sell-to Customer Name")).Value := CopyStr(GetName(FirstName, LastName, CompanyName), 1, MaxStrLen(ShpfyOrderHeader."Sell-to Customer Name"));
            ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Sell-to Customer Name 2")).Value := CopyStr(GetName2(FirstName, LastName, CompanyName), 1, MaxStrLen(ShpfyOrderHeader."Sell-to Customer Name 2"));
            ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Sell-to Contact Name")).Value := CopyStr(GetContactName(FirstName, LastName, CompanyName), 1, MaxStrLen(ShpfyOrderHeader."Sell-to Contact Name"));
            JsonHelper.GetValueIntoField(JOrder, 'displayAddress.address1', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Sell-to Address"));
            JsonHelper.GetValueIntoField(JOrder, 'displayAddress.address2', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Sell-to Address 2"));
            JsonHelper.GetValueIntoField(JOrder, 'displayAddress.city', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Sell-to City"));
            JsonHelper.GetValueIntoField(JOrder, 'displayAddress.countryCode', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Sell-to Country/Region Code"));
            JsonHelper.GetValueIntoField(JOrder, 'displayAddress.country', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Sell-to Country/Region Name"));
            JsonHelper.GetValueIntoField(JOrder, 'displayAddress.province', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Sell-to County"));
            JsonHelper.GetValueIntoField(JOrder, 'displayAddress.zip', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Sell-to Post Code"));
            if EMail = '' then begin
                EMail := JsonHelper.GetValueAsText(JOrder, 'customer.email');
                if EMail <> '' then
                    ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo(Email)).Value := CopyStr(EMail, 1, MaxStrLen(ShpfyOrderHeader.Email));
            end;
            if Phone = '' then begin
                Phone := JsonHelper.GetValueAsText(JOrder, 'displayAddress.phone');
                if Phone = '' then
                    Phone := JsonHelper.GetValueAsText(JOrder, 'customer.phone');
                if Phone = '' then
                    Phone := JsonHelper.GetValueAsText(JOrder, 'customer.defaultAddress.phone');
                if Phone <> '' then
                    ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Phone No.")).Value := CopyStr(Phone, 1, MaxStrLen(ShpfyOrderHeader."Phone No."));
            end;
            #endregion
            #region Ship-to Address info
            CompanyName := JsonHelper.GetValueAsText(JOrder, 'shippingAddress.company');
            FirstName := JsonHelper.GetValueAsText(JOrder, 'shippingAddress.firstName');
            LastName := JsonHelper.GetValueAsText(JOrder, 'shippingAddress.lastName');
            ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Ship-to First Name")).Value := CopyStr(FirstName, 1, MaxStrLen(ShpfyOrderHeader."Ship-to First Name"));
            ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Ship-to Last Name")).Value := CopyStr(LastName, 1, MaxStrLen(ShpfyOrderHeader."Ship-to Last Name"));
            ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Ship-to Name")).Value := CopyStr(GetName(FirstName, LastName, CompanyName), 1, MaxStrLen(ShpfyOrderHeader."Ship-to Name"));
            ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Ship-to Name 2")).Value := CopyStr(GetName2(FirstName, LastName, CompanyName), 1, MaxStrLen(ShpfyOrderHeader."Ship-to Name 2"));
            ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Ship-to Contact Name")).Value := CopyStr(GetContactName(FirstName, LastName, CompanyName), 1, MaxStrLen(ShpfyOrderHeader."Ship-to Contact Name"));
            JsonHelper.GetValueIntoField(JOrder, 'shippingAddress.address1', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Ship-to Address"));
            JsonHelper.GetValueIntoField(JOrder, 'shippingAddress.address2', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Ship-to Address 2"));
            JsonHelper.GetValueIntoField(JOrder, 'shippingAddress.city', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Ship-to City"));
            JsonHelper.GetValueIntoField(JOrder, 'shippingAddress.countryCode', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Ship-to Country/Region Code"));
            JsonHelper.GetValueIntoField(JOrder, 'shippingAddress.country', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Ship-to Country/Region Name"));
            JsonHelper.GetValueIntoField(JOrder, 'shippingAddress.province', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Ship-to County"));
            JsonHelper.GetValueIntoField(JOrder, 'shippingAddress.zip', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Ship-to Post Code"));
            JsonHelper.GetValueIntoField(JOrder, 'shippingAddress.latitude', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Ship-to Latitude"));
            JsonHelper.GetValueIntoField(JOrder, 'shippingAddress.longitude', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Ship-to Longitude"));
            if Phone = '' then begin
                Phone := JsonHelper.GetValueAsText(JOrder, 'shippingAddress.phone');
                if Phone <> '' then
                    ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Phone No.")).Value := CopyStr(Phone, 1, MaxStrLen(ShpfyOrderHeader."Phone No."));
            end;
            #endregion
            #region Bill-to Address info
            CompanyName := JsonHelper.GetValueAsText(JOrder, 'billingAddress.company');
            FirstName := JsonHelper.GetValueAsText(JOrder, 'billingAddress.firstName');
            LastName := JsonHelper.GetValueAsText(JOrder, 'billingAddress.lastName');
            ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Bill-to First Name")).Value := CopyStr(FirstName, 1, MaxStrLen(ShpfyOrderHeader."Bill-to First Name"));
            ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Bill-to Lastname")).Value := CopyStr(LastName, 1, MaxStrLen(ShpfyOrderHeader."Bill-to Lastname"));
            ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Bill-to Name")).Value := CopyStr(GetName(FirstName, LastName, CompanyName), 1, MaxStrLen(ShpfyOrderHeader."Bill-to Name"));
            ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Bill-to Name 2")).Value := CopyStr(GetName2(FirstName, LastName, CompanyName), 1, MaxStrLen(ShpfyOrderHeader."Bill-to Name 2"));
            ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Bill-to Contact Name")).Value := CopyStr(GetContactName(FirstName, LastName, CompanyName), 1, MaxStrLen(ShpfyOrderHeader."Bill-to Contact Name"));
            JsonHelper.GetValueIntoField(JOrder, 'billingAddress.address1', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Bill-to Address"));
            JsonHelper.GetValueIntoField(JOrder, 'billingAddress.address2', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Bill-to Address 2"));
            JsonHelper.GetValueIntoField(JOrder, 'billingAddress.city', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Bill-to City"));
            JsonHelper.GetValueIntoField(JOrder, 'billingAddress.countryCode', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Bill-to Country/Region Code"));
            JsonHelper.GetValueIntoField(JOrder, 'billingAddress.country', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Bill-to Country/Region Name"));
            JsonHelper.GetValueIntoField(JOrder, 'billingAddress.province', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Bill-to County"));
            JsonHelper.GetValueIntoField(JOrder, 'billingAddress.zip', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Bill-to Post Code"));
            if Phone = '' then begin
                Phone := JsonHelper.GetValueAsText(JOrder, 'billingAddress.phone');
                if Phone <> '' then
                    ShpfyOrderHeaderRecordRef.Field(ShpfyOrderHeader.FieldNo("Phone No.")).Value := CopyStr(Phone, 1, MaxStrLen(ShpfyOrderHeader."Phone No."));
            end;
            #endregion
        end;

        JsonHelper.GetValueIntoField(JOrder, 'confirmed', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo(Confirmed));
        JsonHelper.GetValueIntoField(JOrder, 'updatedAt', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Updated At"));
        JsonHelper.GetValueIntoField(JOrder, 'cancelledAt', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Cancelled At"));
        JsonHelper.GetValueIntoField(JOrder, 'closed', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo(Closed));
        JsonHelper.GetValueIntoField(JOrder, 'closedAt', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Closed At"));
        JsonHelper.GetValueIntoField(JOrder, 'processedAt', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Processed At"));
        JsonHelper.GetValueIntoField(JOrder, 'unpaid', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo(Unpaid));
        JsonHelper.GetValueIntoField(JOrder, 'discountCode', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Discount Code"));
        JsonHelper.GetValueIntoField(JOrder, 'discountCodes', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Discount Codes"));
        JsonHelper.GetValueIntoField(JOrder, 'totalWeight', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Total Weight"));
        JsonHelper.GetValueIntoField(JOrder, 'refundable', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo(Refundable));
        JsonHelper.GetValueIntoField(JOrder, 'taxesIncluded', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("VAT Included"));
        JsonHelper.GetValueIntoField(JOrder, 'totalPriceSet.shopMoney.amount', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Total Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'totalPriceSet.presentmentMoney.amount', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Presentment Total Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'subtotalPriceSet.shopMoney.amount', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Subtotal Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'subtotalPriceSet.presentmentMoney.amount', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Presentment Subtotal Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'totalTipReceivedSet.shopMoney.amount', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Total Tip Received"));
        JsonHelper.GetValueIntoField(JOrder, 'totalTipReceivedSet.presentmentMoney.amount', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Presentment Total Tip Received"));
        JsonHelper.GetValueIntoField(JOrder, 'totalTaxSet.shopMoney.amount', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("VAT Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'totalTaxSet.presentmentMoney.amount', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Presentment VAT Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'totalDiscountsSet.shopMoney.amount', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Discount Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'totalDiscountsSet.presentmentMoney.amount', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Presentment Discount Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'totalShippingPriceSet.shopMoney.amount', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Shipping Charges Amount"));
        JsonHelper.GetValueIntoField(JOrder, 'totalShippingPriceSet.presentmentMoney.amount', ShpfyOrderHeaderRecordRef, ShpfyOrderHeader.FieldNo("Pres. Shipping Charges Amount"));

        ShpfyOrderHeaderRecordRef.SetTable(ShpfyOrderHeader);
        if IsNew then begin
            ShpfyOrderHeader."Currency Code" := TranslateCurrencyCode(ShpfyOrderHeader."Currency Code");
            ShpfyOrderHeader."Presentment Currency Code" := TranslateCurrencyCode(ShpfyOrderHeader."Presentment Currency Code");
        end;
        ShpfyOrderHeader."Fully Paid" := not ShpfyOrderHeader.Unpaid;
        ShpfyOrderHeader."Cancel Reason" := ConvertToCancelReason(JsonHelper.GetValueAsText(JOrder, 'cancelReason'));
        ShpfyOrderHeader."Financial Status" := ConvertToFinancielStatus(JsonHelper.GetValueAsText(JOrder, 'displayFinancialStatus'));
        ShpfyOrderHeader."Fulfillment Status" := ConvertToFulfillmentStatus(JsonHelper.GetValueAsText(JOrder, 'displayFulfillmentStatus'));
        ShpfyOrderHeader."Risk Level" := ConvertToRiskLevel(JsonHelper.GetValueAsText(JOrder, 'riskLevel'));
        AddTaxLines(ShpfyOrderHeader."Shopify Order Id", JsonHelper.GetJsonArray(JOrder, 'taxLines'));
        ShpfyOrderHeader.SetWorkDescription(JsonHelper.GetValueAsText(JOrder, 'note'));

        ImportCustomAttributtes(ShpfyOrderHeader."Shopify Order Id", JsonHelper.GetJsonArray(JOrder, 'customAttributes'));
        ShpfyOrderHeader.UpdateTags(JsonHelper.GetArrayAsText(JOrder, 'tags'));
        ImportRisks(ShpfyOrderHeader, JsonHelper.GetJsonArray(JOrder, 'risks'));
        ShpfyOrderFulfillments.GetFulfillments(Shop, ShpfyOrderHeader."Shopify Order Id");
        ShpfyShippingCharges.UpdateShippingCostInfos(ShpfyOrderHeader);
        ShpfyTransactions.UpdateTransactionInfos(ShpfyOrderHeader."Shopify Order Id");
        if IsNew then begin
            ShpfyOrderTransaction.SetRange("Shopify Order Id", OrderId);
            ShpfyOrderTransaction.SetFilter(Status, '%1|%2', "Shpfy Transaction Status"::Pending, "Shpfy Transaction Status"::Success);
            ShpfyOrderTransaction.SetFilter(Type, '%1|%2', "Shpfy Transaction Type"::Sale, "Shpfy Transaction Type"::Capture);
            ShpfyOrderTransaction.SetCurrentKey(Amount, "Shopify Order Id", Status, Type);
            ShpfyOrderTransaction.SetAscending(Amount, false);
            if ShpfyOrderTransaction.FindFirst() then
                ShpfyOrderHeader.Gateway := ShpfyOrderTransaction.Gateway;
        end;
    end;

    [NonDebuggable]
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

    [NonDebuggable]
    local procedure ImportCustomAttributtes(ShopifyOrderId: BigInteger; JCustomAttributtes: JsonArray)
    var
        ShpfyOrderAttribute: Record "Shpfy Order Attribute";
        JToken: JsonToken;
    begin
        ShpfyOrderAttribute.SetRange("Order Id", ShopifyOrderId);
        if not ShpfyOrderAttribute.IsEmpty then
            ShpfyOrderAttribute.DeleteAll();
        foreach JToken in JCustomAttributtes do begin
            Clear(ShpfyOrderAttribute);
            ShpfyOrderAttribute."Order Id" := ShopifyOrderId;
            ShpfyOrderAttribute.Key := JsonHelper.GetValueAsText(JToken, 'key', MaxStrLen(ShpfyOrderAttribute."Key"));
            ShpfyOrderAttribute.Value := JsonHelper.GetValueAsText(JToken, 'value', MaxStrLen(ShpfyOrderAttribute.Value));
            ShpfyOrderAttribute.Insert();
        end;
    end;

    [NonDebuggable]
    local procedure ImportRisks(ShpfyOrderHeader: Record "Shpfy Order Header"; JRisks: JsonArray)
    var
        ShpfyOrderRisks: Codeunit "Shpfy Order Risks";
    begin
        ShpfyOrderRisks.UpdateOrderRisks(ShpfyOrderHeader, JRisks);
    end;

    [NonDebuggable]
    internal procedure ImportOrderLine(ShpfyOrderHeader: Record "Shpfy Order Header"; var ShpfyOrderLine: Record "Shpfy Order Line"; JOrderLine: JsonToken)
    var
        ShpfyOrderLineRecordRef: RecordRef;
        LineId: BigInteger;
        IsNew: Boolean;
    begin
        LineId := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JOrderLine, 'id'));
        if not ShpfyOrderLine.Get(ShpfyOrderHeader."Shopify Order Id", LineId) then begin
            ShpfyOrderLine.Init();
            ShpfyOrderLine."Shopify Order Id" := ShpfyOrderHeader."Shopify Order Id";
            ShpfyOrderLine."Line Id" := LineId;
            ShpfyOrderLine.Insert();
            IsNew := true;
        end;
        ShpfyOrderLineRecordRef.GetTable(ShpfyOrderLine);

        if IsNew then begin
            if (JsonHelper.GetValueAsText(JOrderLine, 'name') = 'Tip') and JsonHelper.IsNull(JOrderLine, 'product') then
                ShpfyOrderLineRecordRef.Field(ShpfyOrderLine.FieldNo(Tip)).Value := true;
            JsonHelper.GetValueIntoField(JOrderLine, 'product.legacyResourceId', ShpfyOrderLineRecordRef, ShpfyOrderLine.FieldNo("Shopify Product Id"));
            JsonHelper.GetValueIntoField(JOrderLine, 'title', ShpfyOrderLineRecordRef, ShpfyOrderLine.FieldNo(Description));
            JsonHelper.GetValueIntoField(JOrderLine, 'quantity', ShpfyOrderLineRecordRef, ShpfyOrderLine.FieldNo(Quantity));
            JsonHelper.GetValueIntoField(JOrderLine, 'variant.legacyResourceId', ShpfyOrderLineRecordRef, ShpfyOrderLine.FieldNo("Shopify Variant Id"));
            JsonHelper.GetValueIntoField(JOrderLine, 'variantTitle', ShpfyOrderLineRecordRef, ShpfyOrderLine.FieldNo("Variant Description"));
            JsonHelper.GetValueIntoField(JOrderLine, 'fulfillmentService.location.legacyResourceId', ShpfyOrderLineRecordRef, ShpfyOrderLine.FieldNo("Location Id"));
            JsonHelper.GetValueIntoField(JOrderLine, 'fulfillableQuantity', ShpfyOrderLineRecordRef, ShpfyOrderLine.FieldNo("Fulfillable Quantity"));
            JsonHelper.GetValueIntoField(JOrderLine, 'fulfillmentService.serviceName', ShpfyOrderLineRecordRef, ShpfyOrderLine.FieldNo("Fulfillment Service"));
            JsonHelper.GetValueIntoField(JOrderLine, 'product.isGiftCard', ShpfyOrderLineRecordRef, ShpfyOrderLine.FieldNo("Gift Card"));
            JsonHelper.GetValueIntoField(JOrderLine, 'taxable', ShpfyOrderLineRecordRef, ShpfyOrderLine.FieldNo(Taxable));
            JsonHelper.GetValueIntoField(JOrderLine, 'originalUnitPriceSet.shopMoney.amount', ShpfyOrderLineRecordRef, ShpfyOrderLine.FieldNo("Unit Price"));
            JsonHelper.GetValueIntoField(JOrderLine, 'originalUnitPriceSet.presentmentMoney.amount', ShpfyOrderLineRecordRef, ShpfyOrderLine.FieldNo("Presentment Unit Price"));
            JsonHelper.GetValueIntoField(JOrderLine, 'totalDiscountSet.shopMoney.amount', ShpfyOrderLineRecordRef, ShpfyOrderLine.FieldNo("Discount Amount"));
            JsonHelper.GetValueIntoField(JOrderLine, 'totalDiscountSet.presentmentMoney.amount', ShpfyOrderLineRecordRef, ShpfyOrderLine.FieldNo("Presentment Discount Amount"));
            ShpfyOrderLineRecordRef.SetTable(ShpfyOrderLine);
            ShpfyOrderLine.Modify();
            ShpfyOrderLineRecordRef.Close();
            AddTaxLines(ShpfyOrderLine."Line Id", JsonHelper.GetJsonArray(JOrderLine, 'taxLines'));
        end;
    end;

    /// <summary>
    /// SetTestInProgress.
    /// </summary>
    /// <param name="TestInProgress">Boolean.</param>
    [NonDebuggable]
    internal procedure SetTestInProgress(TestInProgress: Boolean)
    begin
        IsTestInProgress := TestInProgress;
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
    internal procedure CloseOrder(OrderHeader: Record "Shpfy Order Header")
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
    [NonDebuggable]
    local procedure AddTaxLines(ParentId: BigInteger; JTaxLines: JsonArray)
    var
        OrderTaxLine: Record "Shpfy Order Tax Line";
        RecordRef: RecordRef;
        JToken: JsonToken;
    begin
        OrderTaxLine.SetRange("Parent Id", ParentId);
        if not OrderTaxLine.IsEmpty then
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


    local procedure ConvertToFinancielStatus(Value: Text) ShpfyFinancialStatus: Enum "Shpfy Financial Status"
    var
        IsHandled: Boolean;
    begin
        OrderEvents.OnBeforeConvertToFinancielStatus(Value, ShpfyFinancialStatus, IsHandled);
        if IsHandled then
            exit;

        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Financial Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Financial Status".FromInteger(Enum::"Shpfy Financial Status".Ordinals().Get(Enum::"Shpfy Financial Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Financial Status"::Unknown);
    end;

    local procedure ConvertToFulfillmentStatus(Value: Text) ShpfyOrderFulfillStatus: Enum "Shpfy Order Fulfill. Status"
    var
        IsHandled: Boolean;
    begin
        OrderEvents.OnBeforeConvertToFulfillmentStatus(Value, ShpfyOrderFulfillStatus, IsHandled);
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

    local procedure ConvertToValueType(Value: Text): Enum "Shpfy Value Type"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Value Type".Names().Contains(Value) then
            exit(Enum::"Shpfy Value Type".FromInteger(Enum::"Shpfy Value Type".Ordinals().Get(Enum::"Shpfy Value Type".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Value Type"::Unknown);
    end;

    local procedure ConvertToAllocationMethod(Value: Text): Enum "Shpfy Allocation Method"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Allocation Method".Names().Contains(Value) then
            exit(Enum::"Shpfy Allocation Method".FromInteger(Enum::"Shpfy Allocation Method".Ordinals().Get(Enum::"Shpfy Allocation Method".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Allocation Method"::Unknown);
    end;

    local procedure ConvertToTargetSelection(Value: Text): Enum "Shpfy Target Selection"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Target Selection".Names().Contains(Value) then
            exit(Enum::"Shpfy Target Selection".FromInteger(Enum::"Shpfy Target Selection".Ordinals().Get(Enum::"Shpfy Target Selection".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Target Selection"::Unknown);
    end;

    local procedure ConvertToTargetType(Value: Text): Enum "Shpfy Target Type"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Target Type".Names().Contains(Value) then
            exit(Enum::"Shpfy Target Type".FromInteger(Enum::"Shpfy Target Type".Ordinals().Get(Enum::"Shpfy Target Type".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Target Type"::Unknown);
    end;

    [NonDebuggable]
    internal procedure SetShop(var Shpfyshop: Record "Shpfy Shop")
    begin
        Shop := Shpfyshop;
        CommunicationMgt.SetShop(Shop);
    end;
}