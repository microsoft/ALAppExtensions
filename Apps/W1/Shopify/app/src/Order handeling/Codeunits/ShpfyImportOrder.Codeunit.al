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
        JHelper: Codeunit "Shpfy Json Helper";
        OrderEvents: Codeunit "Shpfy Order Events";

    /// <summary> 
    /// Description for Import.
    /// </summary>
    /// <param name="OrdersToImport">Parameter of type Record "Shopify Orders To Import".</param>
    local procedure Import(OrdersToImport: Record "Shpfy Orders to Import")
    var
        DataCapture: Record "Shpfy Data Capture";
        OrderHeader: Record "Shpfy Order Header";
        xOrderHeader: Record "Shpfy Order Header";
        FulFillments: Codeunit "Shpfy Order Fulfillments";
        Risks: Codeunit "Shpfy Order Risks";
        ShippingCosts: Codeunit "Shpfy Shipping Charges";
        Transactions: Codeunit "Shpfy Transactions";
        RecRef: RecordRef;
        ImportAction: enum "Shpfy Import Action";
        JArray: JsonArray;
        JAddress: JsonObject;
        JOrder: JsonObject;
        JToken: JsonToken;
        CompanyName: Text;
        FirstName: Text;
        LastName: Text;
        PhoneNo: Text;
        Response: Text;
        Url: Text;
    begin
        if Shop.Get(OrdersToImport."Shop Code") then begin
            CommunicationMgt.SetShop(Shop);
            Url := 'orders/{{OrderId}}.json';
            Url := Url.Replace('{{OrderId}}', Format(OrdersToImport.Id));
            Response := CommunicationMgt.ExecuteWebRequest(CommunicationMgt.CreateWebRequestURL(Url), 'GET', '');
            if JToken.ReadFrom(Response) then
                if JHelper.GetJsonObject(JToken, JOrder, 'order') then begin
                    Clear(OrderHeader);
                    ImportAction := OrdersToImport."Import Action";
                    Case ImportAction of
                        ImportAction::New:
                            begin
                                RecRef.GetTable(OrderHeader);
                                JHelper.GetValueIntoField(JOrder, 'id', RecRef, OrderHeader.FieldNo("Shopify Order Id"));
                                JHelper.GetValueIntoField(JOrder, 'created_at', RecRef, OrderHeader.FieldNo("Created At"));
                                RecRef.Field(OrderHeader.FieldNo("Document Date")).Value := DT2Date(RecRef.Field(OrderHeader.FieldNo("Created At")).Value);
                                //JHelper.GetValueIntoField(JOrder, 'browser_ip', RecRef, OrderHeader.FieldNo("Browser IP"));
                                JHelper.GetValueIntoField(JOrder, 'checkout_id', RecRef, OrderHeader.FieldNo("Checkout Id"));
                                JHelper.GetValueIntoField(JOrder, 'source_name', RecRef, OrderHeader.FieldNo("Source Name"));
                                JHelper.GetValueIntoField(JOrder, 'contact_email', RecRef, OrderHeader.FieldNo("Contact Email"));
                                JHelper.GetValueIntoField(JOrder, 'order_status_url', RecRef, OrderHeader.FieldNo("Order Status URL"));
                                PhoneNo := JHelper.GetValueAsText(JOrder, 'phone');
                                PhoneNo := DelChr(PhoneNo, '=', DelChr(PhoneNo, '=', '1234567890/+ .()'));
                                if JHelper.GetJsonObject(Jorder, JAddress, 'billing_address') then begin
                                    FirstName := JHelper.GetValueAsText(JAddress, 'first_name');
                                    LastName := JHelper.GetValueAsText(JAddress, 'last_name');
                                    CompanyName := JHelper.GetValueAsText(JAddress, 'company');
                                    RecRef.Field(OrderHeader.FieldNo("Bill-to First Name")).Value := CopyStr(FirstName, MaxStrLen(OrderHeader."Bill-to First Name"));
                                    RecRef.Field(OrderHeader.FieldNo("Bill-to Lastname")).Value := CopyStr(LastName, MaxStrLen(OrderHeader."Bill-to Lastname"));
                                    RecRef.Field(OrderHeader.FieldNo("Bill-to Name")).Value := CopyStr(GetName(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Bill-to Name"));
                                    RecRef.Field(OrderHeader.FieldNo(OrderHeader."Bill-to Name 2")).Value := CopyStr(GetName2(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Bill-to Name 2"));
                                    if RecRef.Field(OrderHeader.FieldNo(OrderHeader."Bill-to Name")).Value = RecRef.Field(OrderHeader.FieldNo(OrderHeader."Bill-to Name 2")).Value then
                                        RecRef.Field(OrderHeader.FieldNo(OrderHeader."Bill-to Name 2")).Value := ''
                                    else
                                        if Format(RecRef.Field(OrderHeader.FieldNo(OrderHeader."Bill-to Name")).Value) = '' then begin
                                            RecRef.Field(OrderHeader.FieldNo(OrderHeader."Bill-to Name")).Value := RecRef.Field(OrderHeader.FieldNo(OrderHeader."Bill-to Name 2")).Value;
                                            RecRef.Field(OrderHeader.FieldNo(OrderHeader."Bill-to Name 2")).Value := '';
                                        end;
                                    JHelper.GetValueIntoField(JAddress, 'address1', RecRef, OrderHeader.FieldNo("Bill-to Address"));
                                    JHelper.GetValueIntoField(JAddress, 'address2', RecRef, OrderHeader.FieldNo("Bill-to Address 2"));
                                    JHelper.GetValueIntoField(JAddress, 'zip', RecRef, OrderHeader.FieldNo("Bill-to Post Code"));
                                    JHelper.GetValueIntoField(JAddress, 'city', RecRef, OrderHeader.FieldNo("Bill-to City"));
                                    JHelper.GetValueIntoField(JAddress, 'country_code', RecRef, OrderHeader.FieldNo("Bill-to Country/Region Code"));
                                    JHelper.GetValueIntoField(JAddress, 'country', RecRef, OrderHeader.FieldNo("Bill-to Country/Region Name"));
                                    JHelper.GetValueIntoField(JAddress, 'province', RecRef, OrderHeader.FieldNo("Bill-to County"));
                                    if PhoneNo = '' then begin
                                        PhoneNo := JHelper.GetValueAsText(JAddress, 'phone');
                                        PhoneNo := DelChr(PhoneNo, '=', DelChr(PhoneNo, '=', '1234567890/+ .()'));
                                    end;
                                end else
                                    if JHelper.GetJsonObject(Jorder, JAddress, 'customer.default_address') then begin
                                        FirstName := JHelper.GetValueAsText(JAddress, 'first_name');
                                        LastName := JHelper.GetValueAsText(JAddress, 'last_name');
                                        CompanyName := JHelper.GetValueAsText(JAddress, 'company');
                                        RecRef.Field(OrderHeader.FieldNo("Bill-to First Name")).Value := CopyStr(FirstName, MaxStrLen(OrderHeader."Bill-to First Name"));
                                        RecRef.Field(OrderHeader.FieldNo("Bill-to Lastname")).Value := CopyStr(LastName, MaxStrLen(OrderHeader."Bill-to Lastname"));
                                        RecRef.Field(OrderHeader.FieldNo("Bill-to Name")).Value := CopyStr(GetName(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Bill-to Name"));
                                        RecRef.Field(OrderHeader.FieldNo(OrderHeader."Bill-to Name 2")).Value := CopyStr(GetName2(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Bill-to Name 2"));
                                        if RecRef.Field(OrderHeader.FieldNo(OrderHeader."Bill-to Name")).Value = RecRef.Field(OrderHeader.FieldNo(OrderHeader."Bill-to Name 2")).Value then
                                            RecRef.Field(OrderHeader.FieldNo(OrderHeader."Bill-to Name 2")).Value := ''
                                        else
                                            if Format(RecRef.Field(OrderHeader.FieldNo(OrderHeader."Bill-to Name")).Value) = '' then begin
                                                RecRef.Field(OrderHeader.FieldNo(OrderHeader."Bill-to Name")).Value := RecRef.Field(OrderHeader.FieldNo(OrderHeader."Bill-to Name 2")).Value;
                                                RecRef.Field(OrderHeader.FieldNo(OrderHeader."Bill-to Name 2")).Value := '';
                                            end;
                                        JHelper.GetValueIntoField(JAddress, 'address1', RecRef, OrderHeader.FieldNo("Bill-to Address"));
                                        JHelper.GetValueIntoField(JAddress, 'address2', RecRef, OrderHeader.FieldNo("Bill-to Address 2"));
                                        JHelper.GetValueIntoField(JAddress, 'zip', RecRef, OrderHeader.FieldNo("Bill-to Post Code"));
                                        JHelper.GetValueIntoField(JAddress, 'city', RecRef, OrderHeader.FieldNo("Bill-to City"));
                                        JHelper.GetValueIntoField(JAddress, 'country_code', RecRef, OrderHeader.FieldNo("Bill-to Country/Region Code"));
                                        JHelper.GetValueIntoField(JAddress, 'country', RecRef, OrderHeader.FieldNo("Bill-to Country/Region Name"));
                                        JHelper.GetValueIntoField(JAddress, 'province', RecRef, OrderHeader.FieldNo("Bill-to County"));
                                        if PhoneNo = '' then begin
                                            PhoneNo := JHelper.GetValueAsText(JAddress, 'phone');
                                            PhoneNo := DelChr(PhoneNo, '=', DelChr(PhoneNo, '=', '1234567890/+ .()'));
                                        end;
                                    end;
                                if JHelper.GetJsonObject(Jorder, JAddress, 'shipping_address') then begin
                                    FirstName := JHelper.GetValueAsText(JAddress, 'first_name');
                                    LastName := JHelper.GetValueAsText(JAddress, 'last_name');
                                    CompanyName := JHelper.GetValueAsText(JAddress, 'company');
                                    RecRef.Field(OrderHeader.FieldNo("Ship-to First Name")).Value := CopyStr(FirstName, MaxStrLen(OrderHeader."Ship-to First Name"));
                                    RecRef.Field(OrderHeader.FieldNo("Ship-to Last Name")).Value := CopyStr(LastName, MaxStrLen(OrderHeader."Ship-to Last Name"));
                                    RecRef.Field(OrderHeader.FieldNo(OrderHeader."Ship-to Name")).Value := CopyStr(GetName(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Ship-to Name"));
                                    RecRef.Field(OrderHeader.FieldNo(OrderHeader."Ship-to Name 2")).Value := CopyStr(GetName2(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Ship-to Name 2"));
                                    if RecRef.Field(OrderHeader.FieldNo(OrderHeader."Ship-to Name")).Value = RecRef.Field(OrderHeader.FieldNo(OrderHeader."Ship-to Name 2")).Value then
                                        RecRef.Field(OrderHeader.FieldNo(OrderHeader."Ship-to Name 2")).Value := ''
                                    else
                                        if Format(RecRef.Field(OrderHeader.FieldNo(OrderHeader."Ship-to Name")).Value) = '' then begin
                                            RecRef.Field(OrderHeader.FieldNo(OrderHeader."Ship-to Name")).Value := RecRef.Field(OrderHeader.FieldNo(OrderHeader."Ship-to Name 2")).Value;
                                            RecRef.Field(OrderHeader.FieldNo(OrderHeader."Ship-to Name 2")).Value := '';
                                        end;
                                    JHelper.GetValueIntoField(JAddress, 'address1', RecRef, OrderHeader.FieldNo("Ship-to Address"));
                                    JHelper.GetValueIntoField(JAddress, 'address2', RecRef, OrderHeader.FieldNo("Ship-to Address 2"));
                                    JHelper.GetValueIntoField(JAddress, 'zip', RecRef, OrderHeader.FieldNo("Ship-to Post Code"));
                                    JHelper.GetValueIntoField(JAddress, 'city', RecRef, OrderHeader.FieldNo("Ship-to City"));
                                    JHelper.GetValueIntoField(JAddress, 'country_code', RecRef, OrderHeader.FieldNo("Ship-to Country/Region Code"));
                                    JHelper.GetValueIntoField(JAddress, 'country', RecRef, OrderHeader.FieldNo("Ship-to Country/Region Name"));
                                    JHelper.GetValueIntoField(JAddress, 'province', RecRef, OrderHeader.FieldNo("Ship-to County"));
                                    JHelper.GetValueIntoField(JAddress, 'latitude', RecRef, OrderHeader.FieldNo("Ship-to Latitude"));
                                    JHelper.GetValueIntoField(JAddress, 'longitude', RecRef, OrderHeader.FieldNo("Ship-to Longitude"));
                                    if PhoneNo = '' then begin
                                        PhoneNo := JHelper.GetValueAsText(JAddress, 'phone');
                                        PhoneNo := DelChr(PhoneNo, '=', DelChr(PhoneNo, '=', '1234567890/+ .()'));
                                    end;
                                end;
                                //JHelper.GetValueIntoField(JOrder, 'client_details.browser_ip', RecRef, OrderHeader.FieldNo("Browser IP"));
                                JHelper.GetValueIntoField(JOrder, 'client_details.session_hash', RecRef, OrderHeader.FieldNo("Session Hash"));
                                JHelper.GetValueIntoField(JOrder, 'customer.id', RecRef, OrderHeader.FieldNo("Customer Id"));
                                JHelper.GetValueIntoField(JOrder, 'contact_email', RecRef, OrderHeader.FieldNo("Contact Email"));
                                if JHelper.GetJsonObject(JOrder, JAddress, 'billing_address') then begin
                                    FirstName := JHelper.GetValueAsText(JAddress, 'first_name');
                                    LastName := JHelper.GetValueAsText(JAddress, 'last_name');
                                    CompanyName := JHelper.GetValueAsText(JAddress, 'company');
                                    RecRef.Field(OrderHeader.FieldNo("Sell-to First Name")).Value := CopyStr(FirstName, MaxStrLen(OrderHeader."Sell-to First Name"));
                                    RecRef.Field(OrderHeader.FieldNo("Sell-to Last Name")).Value := CopyStr(LastName, MaxStrLen(OrderHeader."Sell-to Last Name"));
                                    RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name")).Value := CopyStr(GetName(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Sell-to Customer Name"));
                                    RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name 2")).Value := CopyStr(GetName2(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Sell-to Customer Name 2"));
                                    if RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name")).Value = RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name 2")).Value then
                                        RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name 2")).Value := ''
                                    else
                                        if Format(RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name")).Value) = '' then begin
                                            RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name")).Value := RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name 2")).Value;
                                            RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name 2")).Value := '';
                                        end;
                                    JHelper.GetValueIntoField(JAddress, 'address1', RecRef, OrderHeader.FieldNo("Sell-to Address"));
                                    JHelper.GetValueIntoField(JAddress, 'address2', RecRef, OrderHeader.FieldNo("Sell-to Address 2"));
                                    JHelper.GetValueIntoField(JAddress, 'zip', RecRef, OrderHeader.FieldNo("Sell-to Post Code"));
                                    JHelper.GetValueIntoField(JAddress, 'city', RecRef, OrderHeader.FieldNo("Sell-to City"));
                                    JHelper.GetValueIntoField(JAddress, 'country_code', RecRef, OrderHeader.FieldNo("Sell-to Country/Region Code"));
                                    JHelper.GetValueIntoField(JAddress, 'country', RecRef, OrderHeader.FieldNo("Sell-to Country/Region Name"));
                                    JHelper.GetValueIntoField(JAddress, 'province', RecRef, OrderHeader.FieldNo("Sell-to County"));
                                end else begin
                                    FirstName := JHelper.GetValueAsText(JAddress, 'customer.first_name');
                                    LastName := JHelper.GetValueAsText(JAddress, 'customer.last_name');
                                    if JHelper.GetJsonObject(Jorder, JAddress, 'customer.default_address') then begin
                                        FirstName := JHelper.GetValueAsText(JAddress, 'first_name');
                                        LastName := JHelper.GetValueAsText(JAddress, 'last_name');
                                        CompanyName := JHelper.GetValueAsText(JAddress, 'company');
                                        RecRef.Field(OrderHeader.FieldNo("Sell-to First Name")).Value := CopyStr(FirstName, MaxStrLen(OrderHeader."Sell-to First Name"));
                                        RecRef.Field(OrderHeader.FieldNo("Sell-to Last Name")).Value := CopyStr(LastName, MaxStrLen(OrderHeader."Sell-to Last Name"));
                                        RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name")).Value := CopyStr(GetName(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Sell-to Customer Name"));
                                        RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name 2")).Value := CopyStr(GetName2(FirstName, LastName, CompanyName), 1, MaxStrLen(OrderHeader."Sell-to Customer Name 2"));
                                        if RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name")).Value = RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name 2")).Value then
                                            RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name 2")).Value := ''
                                        else
                                            if Format(RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name")).Value) = '' then begin
                                                RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name")).Value := RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name 2")).Value;
                                                RecRef.Field(OrderHeader.FieldNo(OrderHeader."Sell-to Customer Name 2")).Value := '';
                                            end;
                                        JHelper.GetValueIntoField(JAddress, 'address1', RecRef, OrderHeader.FieldNo("Sell-to Address"));
                                        JHelper.GetValueIntoField(JAddress, 'address2', RecRef, OrderHeader.FieldNo("Sell-to Address 2"));
                                        JHelper.GetValueIntoField(JAddress, 'zip', RecRef, OrderHeader.FieldNo("Sell-to Post Code"));
                                        JHelper.GetValueIntoField(JAddress, 'city', RecRef, OrderHeader.FieldNo("Sell-to City"));
                                        JHelper.GetValueIntoField(JAddress, 'country_code', RecRef, OrderHeader.FieldNo("Sell-to Country/Region Code"));
                                        JHelper.GetValueIntoField(JAddress, 'country', RecRef, OrderHeader.FieldNo("Sell-to Country/Region Name"));
                                        JHelper.GetValueIntoField(JAddress, 'province', RecRef, OrderHeader.FieldNo("Sell-to County"));
                                    end;
                                end;
                                if JHelper.GetJsonArray(JOrder, JArray, 'line_items') then
                                    AddLineItems(OrdersToImport.Id, JArray);

                            end;
                        ImportAction::Update:
                            if OrderHeader.Get(OrdersToImport.Id) then begin
                                RecRef.GetTable(OrderHeader);
                                xOrderHeader := OrderHeader;
                            end else
                                exit;
                    end;
                    JHelper.GetValueIntoField(JOrder, 'email', RecRef, OrderHeader.FieldNo(Email));
                    JHelper.GetValueIntoField(JOrder, 'closed_at', RecRef, OrderHeader.FieldNo("Closed At"));
                    JHelper.GetValueIntoField(JOrder, 'updated_at', RecRef, OrderHeader.FieldNo("Updated At"));
                    JHelper.GetValueIntoField(JOrder, 'token', RecRef, OrderHeader.FieldNo(Token));
                    JHelper.GetValueIntoField(JOrder, 'gateway', RecRef, OrderHeader.FieldNo(Gateway));
                    JHelper.GetValueIntoField(JOrder, 'test', RecRef, OrderHeader.FieldNo(Test));
                    JHelper.GetValueIntoField(JOrder, 'total_price', RecRef, OrderHeader.FieldNo("Total Amount"));
                    JHelper.GetValueIntoField(JOrder, 'subtotal_price', RecRef, OrderHeader.FieldNo("Subtotal Amount"));
                    JHelper.GetValueIntoField(JOrder, 'total_weight', RecRef, OrderHeader.FieldNo("Total Weight"));
                    JHelper.GetValueIntoField(JOrder, 'currency', RecRef, OrderHeader.FieldNo(Currency));
                    JHelper.GetValueIntoField(JOrder, 'confirmed', RecRef, OrderHeader.FieldNo(Confirmed));
                    JHelper.GetValueIntoField(JOrder, 'total_discounts', RecRef, OrderHeader.FieldNo("Discount Amount"));
                    JHelper.GetValueIntoField(JOrder, 'total_line_items_price', RecRef, OrderHeader.FieldNo("Total Items Amount"));
                    JHelper.GetValueIntoField(JOrder, 'cart_token', RecRef, OrderHeader.FieldNo("Cart Token"));
                    JHelper.GetValueIntoField(JOrder, 'name', RecRef, OrderHeader.FieldNo("Shopify Order No."));
                    JHelper.GetValueIntoField(JOrder, 'cancelled_at', RecRef, OrderHeader.FieldNo("Cancelled At"));
                    JHelper.GetValueIntoField(JOrder, 'checkout_token', RecRef, OrderHeader.FieldNo("Checkout Token"));
                    JHelper.GetValueIntoField(JOrder, 'reference', RecRef, OrderHeader.FieldNo(Reference));
                    JHelper.GetValueIntoField(JOrder, 'processed_at', RecRef, OrderHeader.FieldNo("Processed At"));
                    JHelper.GetValueIntoField(JOrder, 'total_line_items_price_set.shop_money.amount', RecRef, OrderHeader.FieldNo("Total Items Amount"));
                    JHelper.GetValueIntoField(JOrder, 'total_discounts_set.shop_money.amount', RecRef, OrderHeader.FieldNo("Discount Amount"));
                    JHelper.GetValueIntoField(JOrder, 'total_shipping_price_set.shop_money.amount', RecRef, OrderHeader.FieldNo("Shipping Charges Amount"));
                    JHelper.GetValueIntoField(JOrder, 'subtotal_price_set.shop_money.amount', RecRef, OrderHeader.FieldNo("subtotal Amount"));
                    JHelper.GetValueIntoField(JOrder, 'total_price_set.shop_money.amount', RecRef, OrderHeader.FieldNo("Total Amount"));
                    JHelper.GetValueIntoField(JOrder, 'total_tax_set.shop_money.amount', RecRef, OrderHeader.FieldNo("VAT Amount"));
                    JHelper.GetValueIntoField(JOrder, 'total_tip_received', RecRef, OrderHeader.FieldNo("Total Tip Received"));
                    JHelper.GetValueIntoField(JOrder, 'taxes_included', RecRef, OrderHeader.FieldNo("VAT Included"));
                    RecRef.SetTable(OrderHeader);
                    OrderHeader."Phone No." := CopyStr(PhoneNo, 1, MaxStrLen(OrderHeader."Phone No."));
                    OrderHeader."Financial Status" := ConvertToFinancieleStatus(JHelper.GetValueAsText(JOrder, 'financial_status'));
                    OrderHeader."Cancel Reason" := ConvertToCancelReason(JHelper.GetValueAsText(JOrder, 'cancel_reason'));
                    OrderHeader."Processing Method" := ConvertToProcessingMethod(JHelper.GetValueAsText(JOrder, 'processing_method'));

                    OrderHeader."Fulfillment Status" := OrdersToImport."Fulfillment Status";
                    OrderHeader."Shop Code" := OrdersToImport."Shop Code";
                    OrderHeader."Risk Level" := OrdersToImport."Risk Level";
                    OrderHeader."Fully Paid" := OrdersToImport."Fully Paid";
                    OrderHeader."Shop Code" := Shop.Code;
                    case ImportAction of
                        ImportAction::New:
                            begin
                                if JHelper.GetJsonArray(JOrder, JArray, 'fulfillments') then
                                    GetLocationIds(OrderHeader, JArray)
                                else begin
                                    Clear(JArray);
                                    GetLocationIds(OrderHeader, JArray);
                                end;
                                OrderHeader.Insert();
                                OrderEvents.OnAfterNewShopifyOrder(OrderHeader);
                            end;
                        ImportAction::Update:
                            begin
                                OrderHeader.Modify();
                                OrderEvents.OnAfterModifyShopifyOrder(OrderHeader, xOrderHeader);
                            end;
                    end;
                    OrderHeader.SetWorkDescription(JHelper.GetValueAsText(JOrder, 'note'));
                    RecRef.Close();

                    OrderHeader.UpdateTags(JHelper.GetValueAsText(JOrder, 'tags'));
                    if JHelper.GetJsonArray(JOrder, JArray, 'discount_applications') then
                        AddDiscountApplications(OrderHeader."Shopify Order Id", JArray);
                    if JHelper.GetJsonArray(JOrder, JArray, 'payment_gateway_names') then
                        AddPaymentGatewayNames(OrderHeader."Shopify Order Id", JArray);
                    if JHelper.GetJsonArray(JOrder, JArray, 'tax_lines') then
                        AddTaxLines(OrderHeader."Shopify Order Id", JArray);
                    if JHelper.GetJsonArray(JOrder, JArray, 'fulfillments') then
                        FulFillments.GetFulfillmentInfos(OrderHeader."Shopify Order Id", JArray);
                    if JHelper.GetJsonArray(JOrder, JArray, 'shipping_lines') then
                        ShippingCosts.UpdateShippingCostInfos(OrderHeader, JArray);
                    Transactions.UpdateTransactionInfos(OrderHeader);
                    Risks.UpdateOrderRisks(OrderHeader);

                    OrderHeader.CalcFields("Total Quantity of Items", "Number of Lines");

                    if CheckToCloseOrder(OrderHeader) then
                        CloseOrder(OrderHeader);

                    DataCapture.Add(Database::"Shpfy Order Header", OrderHeader.SystemId, Response);
                    exit;
                end;

            Error('Invalid JsonData: %1', Response);
        end;
    end;

    local procedure GetLocationIds(var OrderHeader: Record "Shpfy Order Header"; JFulfillmentOrders: JsonArray)
    begin
        if not GetLocationIdsByFulfillment(OrderHeader, JFulfillmentOrders) then
            GetLocationIdsByLineItems(OrderHeader);
    end;

    local procedure GetLocationIdsByLineItems(var OrderHeader: Record "Shpfy Order Header")
    var
        OrderLine: Record "Shpfy Order Line";
        LineId: BigInteger;
        LocationId: BigInteger;
        Parameters: Dictionary of [Text, Text];
        QueryType: Enum "Shpfy GraphQL Type";
        JLines: JsonArray;
        JLine: JsonToken;
        JResult: JsonToken;
    begin
        Parameters.Add('OrderId', format(OrderHeader."Shopify Order Id"));
        OrderLine.SetRange("Shopify Order Id", OrderHeader."Shopify Order Id");
        Parameters.Add('OrderLines', format(OrderLine.Count + 5));
        QueryType := QueryType::GetLocationOfOrderLines;
        repeat
            JResult := CommunicationMgt.ExecuteGraphQL(QueryType, Parameters);
            if JHelper.GetJsonArray(JResult, JLines, 'data.order.lineItems.edges') then
                foreach JLine in JLines do begin
                    LineId := CommunicationMgt.GetIdOfGId(JHelper.GetValueAsText(JLine, 'node.id'));
                    LocationId := JHelper.GetValueAsBigInteger(JLine, 'node.fulfillmentService.location.legacyResourceId');
                    if OrderHeader."Location Id" = 0 then
                        OrderHeader."Location Id" := LocationId;
                    if OrderLine.Get(OrderHeader."Shopify Order Id", LineId) and (OrderLine."Location Id" = 0) then begin
                        OrderLine."Location Id" := LocationId;
                        OrderLine.Modify();
                    end;
                end;
        until not JHelper.GetValueAsBoolean(JResult, 'data.order.fulfillmentOrders.pageInfo.hasNextPage');
    end;


    local procedure GetLocationIdsByFulfillment(var OrderHeader: Record "Shpfy Order Header"; JFulfillmentOrders: JsonArray): Boolean
    var
        OrderLine: Record "Shpfy Order Line";
        LineId: BigInteger;
        LocationId: BigInteger;
        JLines: JsonArray;
        JFulfillmentOrder: JsonToken;
        JLine: JsonToken;
    begin
        if JFulfillmentOrders.Count = 0 then
            exit(false);

        foreach JFulfillmentOrder in JFulfillmentOrders do begin
            LocationId := JHelper.GetValueAsBigInteger(JFulfillmentOrder, 'location_id');
            if OrderHeader."Location Id" = 0 then
                OrderHeader."Location Id" := LocationId;
            if JHelper.GetJsonArray(JFulfillmentOrder, JLines, 'line_items') then begin
                foreach JLine in JLines do begin
                    LineId := CommunicationMgt.GetIdOfGId(JHelper.GetValueAsText(JLine, 'id'));
                    if OrderLine.Get(OrderHeader."Shopify Order Id", LineId) and (OrderLine."Location Id" = 0) then begin
                        OrderLine."Location Id" := LocationId;
                        OrderLine.Modify();
                    end;
                end;
                exit(true);
            end;
        end;
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
        if ((OrderHeader."Sales Order No." <> '') AND (OrderHeader."Fulfillment Status" = OrderHeader."Fulfillment Status"::Fulfilled)) then begin
            SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
            SalesLine.SetRange("Document No.", OrderHeader."Sales Order No.");
            SalesLine.SetFilter("Outstanding Quantity", '<>%1', 0);
            exit(SalesLine.IsEmpty());
        end;

        exit((OrderHeader."Sales Invoice No." <> '') AND (OrderHeader."Fulfillment Status" = OrderHeader."Fulfillment Status"::Fulfilled));
    end;

    /// <summary> 
    /// Description for CloseOrder.
    /// </summary>
    /// <param name="OrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure CloseOrder(OrderHeader: Record "Shpfy Order Header")
    var
        Response: Text;
        Url: Text;
        OrdersUrlTxt: Label 'orders/%1/close.json', Locked = true;
    begin
        CommunicationMgt.SetShop(OrderHeader."Shop Code");
        Url := CommunicationMgt.CreateWebRequestURL(StrSubstNo(OrdersUrlTxt, OrderHeader."Shopify Order Id"));
        Response := CommunicationMgt.ExecuteWebRequest(Url, 'POST', '');
        OrderHeader.Validate(Closed, true);
        OrderHeader.Modify();
    end;

    /// <summary> 
    /// Add Payment Gateway Names.
    /// </summary>
    /// <param name="OrderId">Parameter of type BigInteger.</param>
    /// <param name="JNames">Parameter of type JsonArray.</param>
    local procedure AddPaymentGatewayNames(OrderId: BigInteger; JNames: JsonArray)
    var
        OrderPaymentGateway: Record "Shpfy Order Payment Gateway";
        JToken: JsonToken;
        JName: JsonValue;
    begin
        OrderPaymentGateway.SetRange("Order Id", OrderId);
        if not OrderPaymentGateway.IsEmpty then
            OrderPaymentGateway.DeleteAll();
        foreach JToken in JNames do
            if JToken.IsValue then begin
                JName := JToken.AsValue();
                if not (JName.IsNull or JName.IsUndefined) then begin
                    Clear(OrderPaymentGateway);
                    OrderPaymentGateway."Order Id" := OrderId;
                    OrderPaymentGateway.Name := CopyStr(JName.AsCode(), 1, MaxStrLen(OrderPaymentGateway.Name));
                    OrderPaymentGateway.Insert();
                end;
            end;
    end;

    /// <summary> 
    /// Add Discount Applications.
    /// </summary>
    /// <param name="OrderId">Parameter of type BigInteger.</param>
    /// <param name="JDiscountApplications">Parameter of type JsonArray.</param>
    local procedure AddDiscountApplications(OrderId: BigInteger; JDiscountApplications: JsonArray)
    var
        DiscAppl: Record "Shpfy Order Disc.Appl.";
        RecRef: RecordRef;
        LineNo: Integer;
        JToken: JsonToken;
    begin
        DiscAppl.SetRange("Order Id", OrderId);
        if not DiscAppl.IsEmpty then
            DiscAppl.DeleteAll();
        foreach JToken in JDiscountApplications do begin
            LineNo += 10000;
            if JToken.IsObject then begin
                RecRef.Open(Database::"Shpfy Order Disc.Appl.");
                RecRef.Init();
                RecRef.Field(DiscAppl.FieldNo("Order Id")).Value := OrderId;
                JHelper.GetValueIntoField(JToken, 'type', RecRef, DiscAppl.FieldNo(Type));
                JHelper.GetValueIntoField(JToken, 'value', RecRef, DiscAppl.FieldNo(Value));
                JHelper.GetValueIntoField(JToken, 'code', RecRef, DiscAppl.FieldNo(Code));
                RecRef.SetTable(DiscAppl);
                DiscAppl."Line No." := LineNo;
                DiscAppl."Value Type" := ConvertToValueType(JHelper.GetValueAsText(JToken, 'value_type'));
                DiscAppl."Allocation Method" := ConvertToAllocationMethod(JHelper.GetValueAsText(JToken, 'allocation_method'));
                DiscAppl."Target Selection" := ConvertToTargetSelection(JHelper.GetValueAsText(JToken, 'target_selection'));
                DiscAppl."Target Type" := ConvertToTargetType(JHelper.GetValueAsText(JToken, 'target_type'));
                DiscAppl.Insert();
                RecRef.Close();
            end;
        end;
    end;

    /// <summary> 
    /// Description for GetDiscountAmount.
    /// </summary>
    /// <param name="JDiscountAllocation">Parameter of type JsonArray.</param>
    local procedure GetDiscountAmount(JDiscountAllocation: JsonArray) Result: Decimal
    var
        JToken: JsonToken;
    begin
        foreach JToken in JDiscountAllocation do
            Result += JHelper.GetValueAsDecimal(Jtoken, 'amount_set.shop_money.amount');
    end;

    /// <summary> 
    /// Add Tax Lines.
    /// </summary>
    /// <param name="ParentId">Parameter of type BigInteger.</param>
    /// <param name="JTaxLines">Parameter of type JsonArray.</param>
    local procedure AddTaxLines(ParentId: BigInteger; JTaxLines: JsonArray)
    var
        TaxLine: Record "Shpfy Order Tax Line";
        RecRef: RecordRef;
        JToken: JsonToken;
    begin
        TaxLine.SetRange("Parent Id", ParentId);
        if not TaxLine.IsEmpty then
            TaxLine.DeleteAll();
        foreach JToken in JTaxLines do begin
            RecRef.Open(Database::"Shpfy Order Tax Line");
            RecRef.Init();
            RecRef.Field(TaxLine.FieldNo("Parent Id")).Value := ParentId;
            JHelper.GetValueIntoField(JToken, 'title', RecRef, TaxLine.FieldNo(Title));
            JHelper.GetValueIntoField(JToken, 'rate', RecRef, TaxLine.FieldNo(Rate));
            JHelper.GetValueIntoField(JToken, 'price_set.shop_money.amount', RecRef, TaxLine.FieldNo(Amount));
            JHelper.GetValueIntoField(JToken, 'price_set.shop_money.currency_code', RecRef, TaxLine.FieldNo("Currency Code"));
            RecRef.Insert(true);
            RecRef.Close();
        end;
    end;

    /// <summary> 
    /// Description for AddLineItemss.
    /// </summary>
    /// <param name="OrderId">Parameter of type BigInteger.</param>
    /// <param name="JLineItems">Parameter of type JsonArray.</param>
    local procedure AddLineItems(OrderId: BigInteger; JLineItems: JsonArray)
    var
        OrderLine: Record "Shpfy Order Line";
        RecRef: RecordRef;
        JArray: JsonArray;
        JToken: JsonToken;
    begin
        OrderLine.SetRange("Shopify Order Id", OrderId);
        if not OrderLine.IsEmpty then
            OrderLine.DeleteAll(true);

        foreach JToken in JLineItems do begin
            Clear(OrderLine);
            OrderLine."Shopify Order Id" := OrderId;
            RecRef.GetTable(OrderLine);
            JHelper.GetValueIntoField(JToken, 'id', RecRef, OrderLine.FieldNo("Line Id"));
            JHelper.GetValueIntoField(JToken, 'variant_id', RecRef, OrderLine.FieldNo("Shopify Variant Id"));
            JHelper.GetValueIntoField(JToken, 'title', RecRef, OrderLine.FieldNo(Description));
            JHelper.GetValueIntoField(JToken, 'quantity', RecRef, OrderLine.FieldNo(Quantity));
            JHelper.GetValueIntoField(JToken, 'variant_title', RecRef, OrderLine.FieldNo("Variant Description"));
            JHelper.GetValueIntoField(JToken, 'fulfillment_service', RecRef, OrderLine.FieldNo("Fulfillment Service"));
            JHelper.GetValueIntoField(JToken, 'product_id', RecRef, OrderLine.FieldNo("Shopify Product Id"));
            JHelper.GetValueIntoField(JToken, 'taxable', RecRef, OrderLine.FieldNo(Taxable));
            JHelper.GetValueIntoField(JToken, 'gift_card', RecRef, OrderLine.FieldNo("Gift Card"));
            JHelper.GetValueIntoField(JToken, 'product_exists', RecRef, OrderLine.FieldNo("Product Exists"));
            JHelper.GetValueIntoFieldWithValidation(JToken, 'fulfillable_quantity', RecRef, OrderLine.FieldNo("Fulfillable Quantity"));
            JHelper.GetValueIntoField(JToken, 'price', RecRef, OrderLine.FieldNo("Unit Price"));
            RecRef.Field(OrderLine.FieldNo(Tip)).Value := JHelper.ContainsToken(JToken, 'tip');
            if JHelper.GetJsonArray(JToken, JArray, 'discount_allocations') then
                RecRef.Field(OrderLine.FieldNo("Discount Amount")).Value := GetDiscountAmount(JArray);
            if JHelper.GetJsonArray(JToken, JArray, 'tax_lines') then
                AddTaxLines(RecRef.Field(OrderLine.FieldNo("Line Id")).Value, JArray);
            RecRef.Insert(true);
            RecRef.Close();
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

    local procedure ConvertToFinancieleStatus(Value: Text): Enum "Shpfy Financial Status"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Financial Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Financial Status".FromInteger(Enum::"Shpfy Financial Status".Ordinals().Get(Enum::"Shpfy Financial Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Financial Status"::Unknown);
    end;

    local procedure ConvertToCancelReason(Value: Text): Enum "Shpfy Cancel Reason"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Cancel Reason".Names().Contains(Value) then
            exit(Enum::"Shpfy Cancel Reason".FromInteger(Enum::"Shpfy Cancel Reason".Ordinals().Get(Enum::"Shpfy Cancel Reason".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Cancel Reason"::Unknown);
    end;

    local procedure ConvertToProcessingMethod(Value: Text): Enum "Shpfy Processing Method"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Processing Method".Names().Contains(Value) then
            exit(Enum::"Shpfy Processing Method".FromInteger(Enum::"Shpfy Processing Method".Ordinals().Get(Enum::"Shpfy Processing Method".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Processing Method"::Unknown);
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
}