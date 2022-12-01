codeunit 139607 "Shpfy Order Handling Helper"
{
    var
        Any: Codeunit Any;
        ShpfyJsonHelper: codeunit "Shpfy Json Helper";

    internal procedure GetOrdersToImport() JResult: JsonObject
    var
        OrdersToImport: Integer;
        Index: Integer;
        JData: JsonObject;
        JOrders: JsonObject;
        JPageInfo: JsonObject;
        JEdges: JsonArray;
        JExtensions: JsonObject;
        JCost: JsonObject;
        JThrottleStatus: JsonObject;
    begin
        Any.SetDefaultSeed();
        OrdersToImport := Any.IntegerInRange(1, 5);
        JPageInfo.Add('hasNextPage', false);
        JOrders.Add('pageInf', JPageInfo);
        for Index := 1 to OrdersToImport do
            JEdges.Add(OrderToImport());
        JOrders.Add('edges', JEdges);
        JData.Add('orders', JOrders);
        JResult.Add('data', JData);
        JCost.Add('requestedQueryCost', 752);
        JCost.Add('actualQueryCost', 2 + OrdersToImport * 3);
        JThrottleStatus.Add('maximumAvailable', 1000.0);
        JThrottleStatus.Add('currentlyAvailable', 1000 - (2 + OrdersToImport * 3));
        JThrottleStatus.Add('restoreRate', 50.0);
        JCost.Add('throttleStatus', JThrottleStatus);
        JExtensions.Add('cost', JCost);
        JResult.Add('extensions', JExtensions);
    end;

    local procedure OrderToImport() JResult: JsonObject
    var
        JNode: JsonObject;
        JTotalPriceSet: JsonObject;
        JShopMoney: JsonObject;
        JCustomAttributes: JsonArray;
        JTags: JsonArray;
    begin
        JResult.Add('cursor', Any.AlphanumericText(92));
        JNode.Add('legacyResourceId', Any.IntegerInRange(10000, 999999));
        JNode.Add('name', 'WEB' + Format(Any.IntegerInRange(100, 999)));
        JNode.Add('createdAt', Format(CurrentDateTime, 0, 9));
        JNode.Add('updatedAt', Format(CurrentDateTime, 0, 9));
        JNode.Add('test', true);
        JNode.Add('fullyPaid', false);
        JNode.Add('unpaid', false);
        JNode.Add('riskLevel', 'LOW');
        JNode.Add('displayFinancialStatus', 'PENDING');
        JNode.Add('displayFulfillmentStatus', 'UNFULFILLED');
        JNode.Add('subtotalLineItemsQuantity', 1);
        JShopMoney.Add('amount', Any.DecimalInRange(10, 1000, 2));
        JShopMoney.Add('currencyCode', 'USD');
        JTotalPriceSet.Add('shopMoney', JShopMoney);
        JNode.Add('totalPriceSet', JTotalPriceSet);
        JNode.Add('customAttributtes', JCustomAttributes);
        JNode.Add('tags', JTags);
        JResult.Add('node', JNode);
    end;

    internal procedure CountOrdersToImport(JOrdersToImport: JsonObject): Integer
    var
        JOrders: JsonArray;
    begin
        if ShpfyJsonHelper.GetJsonArray(JOrdersToImport, JOrders, 'data.orders.edges') then
            exit(JOrders.Count);
    end;


    internal procedure CreateShopifyOrderAsJson(ShpfyShop: Record "Shpfy Shop"; var ShpfyOrdersToImport: Record "Shpfy Orders to Import") JOrder: JsonObject
    var
        Customer: Record Customer;
        ShpfyOrdersAPI: Codeunit "Shpfy Orders API";
        BrowserIp: Text;
        Cursor: Text;
        JNull: JsonValue;
        JArray: JsonArray;
        Price: Decimal;
        ItemPrice: Decimal;
        TaxPrice: Decimal;
        TaxRate: Decimal;
        DiscountPrice: Decimal;
        ShippingPrice: Decimal;
        OrderNumber: Integer;
    begin
        Clear(ShpfyOrdersToImport);
        if not ShpfyOrdersToImport.IsEmpty then
            ShpfyOrdersToImport.DeleteAll();
        ShpfyOrdersAPI.ExtractShopifyOrdersToImport(ShpfyShop, GetOrdersToImport(), Cursor);
        ShpfyOrdersToImport.FindFirst();
        ShpfyOrdersToImport.SetRecFilter();
        JNull.SetValueToNull();
        Customer := GetCustomer();
        BrowserIp := StrSubstNo('%1.%2.%3.%4', Any.IntegerInRange(1, 255), Any.IntegerInRange(0, 255), Any.IntegerInRange(0, 255), Any.IntegerInRange(0, 255));
        Price := ShpfyOrdersToImport."Order Amount";
        TaxRate := 10;
        TaxPrice := Price - Round(Price / (1 + TaxRate / 100), 0.01);
        DiscountPrice := 0;
        ShippingPrice := Any.DecimalInRange(0, TaxPrice, 2);
        ItemPrice := Price - ShippingPrice;
        if Evaluate(OrderNumber, DelChr(ShpfyOrdersToImport."Order No.", '=', DelChr(ShpfyOrdersToImport."Order No.", '=', '0123456789'))) then;
        JOrder.Add('id', ShpfyOrdersToImport.Id);
        JOrder.Add('admin_graphql_api_id', StrSubstNo('gid:\/\/shopify\/Order\/%1', ShpfyOrdersToImport.Id));
        JOrder.Add('app_id', 129785);
        JOrder.Add('browser_ip', BrowserIp);
        JOrder.Add('buyer_accepts_marketing', Any.IntegerInRange(1, 10) > 5);
        JOrder.Add('cancel_reason', JNull);
        JOrder.Add('cancelled_at', JNull);
        JOrder.Add('cart_token', JNull);
        JOrder.Add('checkout_id', Any.IntegerInRange(10000, 999999));
        JOrder.Add('checkout_token', Any.AlphanumericText(32));
        JOrder.Add('client_details', CreateClientDetails(BrowserIp));
        JOrder.Add('closed_at', JNull);
        JOrder.Add('confirmed', true);
        JOrder.Add('contact_email', Customer."E-Mail");
        JOrder.Add('created_at', ShpfyOrdersToImport."Created At");
        JOrder.Add('currency', ShpfyOrdersToImport."Currency Code");
        JOrder.Add('current_subtotal_price', Format(ItemPrice, 0, 9));
        JOrder.Add('current_subtotal_price_set', AddPriceSet(ItemPrice, ShpfyOrdersToImport."Currency Code"));
        JOrder.Add('current_total_discounts', Format(DiscountPrice, 0, 9));
        JOrder.Add('current_total_discounts_set', AddPriceSet(DiscountPrice, ShpfyOrdersToImport."Currency Code"));
        JOrder.Add('current_total_duties_set', JNull);
        JOrder.Add('current_total_price', Format(Price, 0, 9));
        JOrder.Add('current_total_price_set', AddPriceSet(Price, ShpfyOrdersToImport."Currency Code"));
        JOrder.Add('current_total_tax', Format(TaxPrice, 0, 9));
        JOrder.Add('current_total_tax_set', AddPriceSet(TaxPrice, ShpfyOrdersToImport."Currency Code"));
        JOrder.Add('customer_locale', 'en-US');
        JOrder.Add('device_id', JNull);
        JOrder.Add('discount_codes', JArray);
        JOrder.Add('email', Customer."E-Mail");
        JOrder.Add('estimated_taxes', false);
        JOrder.Add('financial_status', "Shpfy Financial Status".Names().Get(ShpfyOrdersToImport."Financial Status".AsInteger()).ToLower().Replace(' ', '_'));
        JOrder.Add('fulfillment_status', JNull);
        JOrder.Add('gateway', 'bogus');
        JOrder.Add('landing_site', '\/');
        JOrder.Add('landing_site_ref', JNull);
        JOrder.Add('Location_id', JNull);
        JOrder.Add('name', ShpfyOrdersToImport."Order No.");
        JOrder.Add('note', JNull);
        JOrder.Add('note_attributes', JArray);
        JOrder.Add('number', OrderNumber MOD 1000);
        JOrder.Add('order_number', OrderNumber);
        JOrder.Add('order_status_url', 'https://fakeurl.net');
        JOrder.Add('original_total_duties_set', JNull);
        JOrder.Add('payment_gateway_names', GetPaymentGatewayNames());
        JOrder.Add('phone', Customer."Phone No.");
        JOrder.Add('presentment_currency', ShpfyOrdersToImport."Currency Code");
        JOrder.Add('processed_at', ShpfyOrdersToImport."Created At");
        JOrder.Add('processing_method', 'direct');
        JOrder.Add('reference', JNull);
        JOrder.Add('referring_site', '');
        JOrder.Add('source_identifier', JNull);
        JOrder.Add('source_name', 'web');
        JOrder.Add('source_url', JNull);
        JOrder.Add('subtotal_price', Format(ItemPrice, 0, 9));
        JOrder.Add('subtotal_price_set', AddPriceSet(ItemPrice, ShpfyOrdersToImport."Currency Code"));
        JOrder.Add('tags', ShpfyOrdersToImport.Tags);
        JOrder.Add('taxes_included', true);
        JOrder.Add('test', true);
        JOrder.Add('token', Any.AlphanumericText(32));
        JOrder.Add('total_discounts', '0.00');
        JOrder.Add('total_discounts_set', AddPriceSet(0, ShpfyOrdersToImport."Currency Code"));
        JOrder.Add('total_line_items_price', Format(ItemPrice, 0, 9));
        JOrder.Add('total_line_items_price_set', AddPriceSet(ItemPrice, ShpfyOrdersToImport."Currency Code"));
        JOrder.Add('total_outstanding', '0.00');
        JOrder.Add('total_price', Format(Price, 0, 9));
        JOrder.Add('total_price_set', AddPriceSet(Price, ShpfyOrdersToImport."Currency Code"));
        JOrder.Add('total_shipping_price_set', AddPriceSet(ShippingPrice, ShpfyOrdersToImport."Currency Code"));
        JOrder.Add('total_tax', Format(TaxPrice, 0, 9));
        JOrder.Add('total_tax_set', AddPriceSet(TaxPrice, ShpfyOrdersToImport."Currency Code"));
        JOrder.Add('total_tip_received', '0.00');
        JOrder.Add('total_weight', Any.IntegerInRange(0, 1000));
        JOrder.Add('updated_at', ShpfyOrdersToImport."Updated At");
        JOrder.Add('user_id', JNull);
        JOrder.Add('billing_address', CreateAddress(Customer));
        JOrder.Add('customer', CreateCustomer(Customer));
        JOrder.Add('discount_applications', JArray);
        JOrder.Add('fulfillments', JArray);
        JOrder.Add('line_items', CreateLineItem(Price, TaxPrice, TaxRate, DiscountPrice, ShpfyOrdersToImport."Currency Code"));
        JOrder.Add('payment_details', CreatePaymentDetails());
        JOrder.Add('payment_terms', JNull);
        JOrder.Add('refunds', JArray);
        JOrder.Add('shipping_address', CreateAddress(Customer));
        JOrder.Add('shipping_lines', CreateShippingLines(ShippingPrice, TaxRate, ShpfyOrdersToImport."Currency Code"));
        //JResult.Add('order', JOrder);
    end;

    local procedure CreateLineItem(Price: Decimal; TaxPrice: Decimal; TaxRate: Decimal; Discount: Decimal; CurrencyCode: Code[10]) JLines: JsonArray
    var
        Item: Record Item;
        TempShpfyProduct: Record "Shpfy Product" temporary;
        TempShpfyVariant: Record "Shpfy Variant" temporary;
        ShpfyCreateProduct: Codeunit "Shpfy Create Product";
        ShpfyProductInitTest: codeunit "Shpfy Product Init Test";
        Id: BigInteger;
        JLine: JsonObject;
        JNull: JsonValue;
        JArray: JsonArray;
    begin
        Item := ShpfyProductInitTest.CreateItem();
        Item.SetRecFilter();
        ShpfyCreateProduct.CreateTempProduct(Item, TempShpfyProduct, TempShpfyVariant);

        Id := Any.IntegerInRange(10000, 99999);
        JLine.Add('id', id);
        JLine.Add('admin_graphql_api_id', StrSubstNo('gid:\/\/shopify\/LineItem\/%1', Id));
        JLine.Add('fulfillable_quantity', 1);
        JLine.Add('fulfillment_service', 'manual');
        JLine.Add('fulfillment_status', JNull);
        JLine.Add('gift_card', false);
        JLine.Add('grams', Any.IntegerInRange(100, 5000));
        JLine.Add('name', Item.Description);
        JLine.Add('origin_location', CreateOriginLocation());
        JLine.Add('price', Format(price, 0, 9));
        JLine.Add('price_set', AddPriceSet(Price, CurrencyCode));
        JLine.Add('product_exists', true);
        JLine.Add('product_id', TempShpfyProduct.Id);
        JLine.Add('properties', JArray);
        JLine.Add('quantity', 1);
        JLine.Add('requires_shipping', true);
        JLine.Add('sku', TempShpfyVariant.SKU);
        JLine.Add('taxable', true);
        JLine.Add('title', Item.Description);
        JLine.Add('total_discount', Format(Discount, 0, 9));
        JLine.Add('total_discount_set', AddPriceSet(Discount, CurrencyCode));
        JLine.Add('variant_id', TempShpfyVariant.Id);
        JLine.Add('variant_inventory_management', 'shopify');
        JLine.Add('variant_title', '');
        JLine.Add('vendor', TempShpfyProduct.Vendor);
        JLine.Add('tax_lines', CreateTaxLines(TaxPrice, TaxRate, CurrencyCode));
        JLine.Add('dutes', JArray);
        JLine.Add('discount_allocations', JArray);
        JLines.Add(JLine);
    end;

    local procedure CreateOriginLocation() JLocation: JsonObject
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        JLocation.Add('id', Any.IntegerInRange(10000, 99999));
        JLocation.Add('country_code', CompanyInformation.GetCompanyCountryRegionCode());
        JLocation.Add('province_code', '');
        JLocation.Add('name', CompanyInformation.Name);
        JLocation.Add('address1', CompanyInformation.Address);
        JLocation.Add('address2', CompanyInformation."Address 2");
        JLocation.Add('city', CompanyInformation.City);
        JLocation.Add('zip', CompanyInformation."Post Code");
    end;

    local procedure CreateTaxLines(TaxPrice: Decimal; TaxRate: Decimal; CurrencyCode: code[10]) JTaxLines: JsonArray;
    var
        JTaxLine: JsonObject;
    begin
        JTaxLine.Add('channel_liable', false);
        JTaxLine.Add('price', format(TaxPrice, 0, 9));
        JTaxLine.Add('price_set', AddPriceSet(TaxPrice, CurrencyCode));
        JTaxLine.Add('rate', TaxRate);
        JTaxLine.Add('title', 'TVA');
        JTaxLines.Add(JTaxLine);
    end;

    local procedure CreateClientDetails(BrowserId: Text) JCientDetails: JsonObject
    var
        JNull: JsonValue;
    begin
        JNull.SetValueToNull();
        JCientDetails.Add('accept_language', JNull);
        JCientDetails.Add('browser_height', JNull);
        JCientDetails.Add('browser_ip', BrowserId);
        JCientDetails.Add('browser_width', JNull);
        JCientDetails.Add('session_hash', JNull);
        JCientDetails.Add('user_agent', 'Mozilla\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/103.0.5060.114 Safari\/537.36 Edg\/103.0.1264.49');
    end;

    local procedure GetPaymentGatewayNames() JResult: JsonArray
    begin
        JResult.Add('bogus');
    end;

    local procedure AddPriceSet(Price: Decimal; CurrencyCode: Code[10]) JSet: JsonObject
    var
        JShopMoney: JsonObject;
        JPresentManey: JsonObject;
    begin
        JShopMoney.Add('amount', Format(Price, 0, 9));
        JShopMoney.Add('currency_code', CurrencyCode);
        JSet.Add('shop_money', JShopMoney);
        JPresentManey.Add('Amount', Format(Price, 0, 9));
        JPresentManey.Add('currency_code', CurrencyCode);
        JSet.Add('presentment_money', JPresentManey);
    end;

    local procedure GetCustomer(): Record Customer
    var
        ShpfyInitializeTest: codeunit "Shpfy Initialize Test";
    begin
        exit(ShpfyInitializeTest.GetDummyCustomer());
    end;

    local procedure CreateAddress(Customer: Record Customer) JAddress: JsonObject
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
        JNull: JsonValue;
    begin
        JNull.SetValueToNull();
        if Customer."Country/Region Code" = '' then begin
            CompanyInformation.Get();
            Customer."Country/Region Code" := CompanyInformation."Country/Region Code";
        end;
        if not CountryRegion.Get(Customer."Country/Region Code") then
            CountryRegion.Init();
        JAddress.Add('first_name', '');
        JAddress.Add('last_name', '');
        JAddress.Add('address1', Customer.Address);
        JAddress.Add('phone', Customer."Phone No.");
        JAddress.Add('city', Customer.City);
        JAddress.Add('zip', Customer."Post Code");
        JAddress.Add('province', CountryRegion."County Name");
        JAddress.Add('country', CountryRegion.Name);
        JAddress.Add('address2', Customer."Address 2");
        JAddress.Add('Company', '');
        JAddress.Add('latitude', JNull);
        JAddress.Add('longitude', JNull);
        JAddress.Add('name', Customer.Name);
        JAddress.Add('country_code', CountryRegion."ISO Code");
        JAddress.Add('province_code', JNull);
    end;

    local procedure CreateCustomerAddress(Customer: Record Customer; CustomerId: BigInteger) JAddress: JsonObject
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
        JNull: JsonValue;
    begin
        JNull.SetValueToNull();
        if Customer."Country/Region Code" = '' then begin
            CompanyInformation.Get();
            Customer."Country/Region Code" := CompanyInformation."Country/Region Code";
        end;
        if not CountryRegion.Get(Customer."Country/Region Code") then
            CountryRegion.Init();
        JAddress.Add('id', Any.IntegerInRange(100000, 999999));
        JAddress.Add('customer_id', CustomerId);
        JAddress.Add('first_name', '');
        JAddress.Add('last_name', '');
        JAddress.Add('Company', '');
        JAddress.Add('address1', Customer.Address);
        JAddress.Add('address2', Customer."Address 2");
        JAddress.Add('city', Customer.City);
        JAddress.Add('province', CountryRegion."County Name");
        JAddress.Add('country', CountryRegion.Name);
        JAddress.Add('zip', Customer."Post Code");
        JAddress.Add('phone', Customer."Phone No.");
        JAddress.Add('name', Customer.Name);
        JAddress.Add('province_code', JNull);
        JAddress.Add('country_code', CountryRegion."ISO Code");
        JAddress.Add('country_name', CountryRegion.Name);
        JAddress.Add('default', true);
    end;

    local procedure CreateCustomer(Customer: Record Customer) JCustomer: JsonObject
    var
        ShpfyCustomer: Record "Shpfy Customer";
        ShpfyCustomerInitTest: codeunit "Shpfy Customer Init Test";
        JNull: JsonValue;
        JArray: JsonArray;
    begin
        ShpfyCustomerInitTest.CreateShopifyCustomer(ShpfyCustomer);
        ShpfyCustomer."Customer SystemId" := Customer.SystemId;
        ShpfyCustomer.Modify();
        JNull.SetValueToNull();
        JCustomer.Add('id', ShpfyCustomer.Id);
        JCustomer.Add('email', Customer."E-Mail");
        JCustomer.Add('accepts_marketing', false);
        JCustomer.Add('created_at', Format(CurrentDateTime, 0, 9));
        JCustomer.Add('updated_at', Format(CurrentDateTime, 0, 9));
        JCustomer.Add('first_name', '');
        JCustomer.Add('last_name', '');
        JCustomer.Add('orders_count', 0);
        JCustomer.Add('state', 'disabled');
        JCustomer.Add('total_spent', '0.00');
        JCustomer.Add('last_order_id', JNull);
        JCustomer.Add('note', JNull);
        JCustomer.Add('verified_email', true);
        JCustomer.Add('multipass_identifier', JNull);
        JCustomer.Add('tax_exempt', false);
        JCustomer.Add('tags', '');
        JCustomer.Add('last_order_name', JNull);
        JCustomer.Add('currency', 'EUR');
        JCustomer.Add('phone', Customer."Phone No.");
        JCustomer.Add('accepts_marketing_updated_at', Format(CurrentDateTime, 0, 9));
        JCustomer.Add('marketing_opt_in_level', JNull);
        JCustomer.Add('tax_exemptions', JArray);
        JCustomer.Add('sms_marketing_consent', JNull);
        JCustomer.Add('admin_graphql_api_id', StrSubstNo('gid:\/\/shopify\/Customer\/%1', ShpfyCustomer.Id));
        JCustomer.Add('default_address', CreateCustomerAddress(Customer, ShpfyCustomer.Id));
    end;

    local procedure CreatePaymentDetails() JPaymentDetails: JsonObject
    var
        JNull: JsonValue;
    begin
        JPaymentDetails.Add('credit_card_bin', 1);
        JPaymentDetails.Add('avs_result_code', JNull);
        JPaymentDetails.Add('cvv_result_code', JNull);
        JPaymentDetails.Add('credit_card_number', '���� ���� ���� 1');
        JPaymentDetails.Add('credit_card_company', 'Bogus');
    end;

    local procedure CreateShippingLines(ShippingPrice: Decimal; TaxRate: Decimal; CurrencyCode: Code[10]) JShippingLines: JsonArray
    var
        JShippingLine: JsonObject;
        JNull: JsonValue;
    begin
        JShippingLine.Add('id', Any.IntegerInRange(10000, 99999));
        JShippingLine.Add('carrier_identiefier', JNull);
        JShippingLine.Add('code', 'DHL');
        JShippingLine.Add('delivery_category', JNull);
        JShippingLine.Add('discounted_price', Format(ShippingPrice, 0, 9));
        JShippingLine.Add('discounted_price_set', AddPriceSet(ShippingPrice, CurrencyCode));
        JShippingLine.Add('phone', JNull);
        JShippingLine.Add('price', Format(ShippingPrice, 0, 9));
        JShippingLine.Add('price_set', AddPriceSet(ShippingPrice, CurrencyCode));
        JShippingLine.Add('requested_fulfillment_service_id', JNull);
        JShippingLine.Add('source', 'shopify');
        JShippingLine.Add('title', 'DHL');
        JShippingLine.Add('tax_lines', CreateTaxLines(Round(ShippingPrice * (1 - TaxRate / 100), 0.01), TaxRate, CurrencyCode));
        JShippingLine.Add('discount_allocations', JNull);
        JShippingLines.Add(JShippingLine);
    end;
}