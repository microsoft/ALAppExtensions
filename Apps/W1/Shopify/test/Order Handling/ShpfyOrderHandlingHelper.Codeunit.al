codeunit 139607 "Shpfy Order Handling Helper"
{
    var
        Any: Codeunit Any;
        JsonHelper: codeunit "Shpfy Json Helper";

    internal procedure GetOrdersToImport(B2B: Boolean) JResult: JsonObject
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
            JEdges.Add(OrderToImport(B2B));
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

    local procedure OrderToImport(B2B: Boolean) JResult: JsonObject
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        JNode: JsonObject;
        JTotalPriceSet: JsonObject;
        JShopMoney: JsonObject;
        JPurchasingEntity: JsonObject;
        JCompany: JsonObject;
        JCustomAttributes: JsonArray;
        JTags: JsonArray;
    begin
        GeneralLedgerSetup.Get();
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
        JShopMoney.Add('currencyCode', GeneralLedgerSetup.GetCurrencyCode(''));
        JTotalPriceSet.Add('shopMoney', JShopMoney);
        JNode.Add('totalPriceSet', JTotalPriceSet);
        JNode.Add('customAttributtes', JCustomAttributes);
        JNode.Add('tags', JTags);
        if B2B then begin
            JCompany.Add('id', 'gid://shopify/Company/1234567890');
            JPurchasingEntity.Add('company', JCompany);
            JNode.Add('purchasingEntity', JPurchasingEntity);
        end else
            JNode.Add('purchasingEntity', JPurchasingEntity);
        JResult.Add('node', JNode);
    end;

    internal procedure CountOrdersToImport(JOrdersToImport: JsonObject): Integer
    var
        JOrders: JsonArray;
    begin
        if JsonHelper.GetJsonArray(JOrdersToImport, JOrders, 'data.orders.edges') then
            exit(JOrders.Count);
    end;


    internal procedure CreateShopifyOrderAsJson(Shop: Record "Shpfy Shop"; var OrdersToImport: Record "Shpfy Orders to Import"; var JShopifyLineItems: JsonArray; B2B: Boolean) JOrder: JsonObject
    var
        Customer: Record Customer;
        ShopifyCustomer: Record "Shpfy Customer";
        OrdersAPI: Codeunit "Shpfy Orders API";
        BrowserIp: Text;
        Cursor: Text;
        JNull: JsonValue;
        JStore: JsonObject;
        JPurchasingEntity: JsonObject;
        JCompany: JsonObject;
        JMainContact: JsonObject;
        JCustomer: JsonObject;
        JArray: JsonArray;
        Price: Decimal;
        ItemPrice: Decimal;
        TaxPrice: Decimal;
        TaxRate: Decimal;
        DiscountPrice: Decimal;
        ShippingPrice: Decimal;
        OrderNumber: Integer;
        AddressId: BigInteger;
    begin
        Clear(OrdersToImport);
        if not OrdersToImport.IsEmpty then
            OrdersToImport.DeleteAll();
        OrdersAPI.ExtractShopifyOrdersToImport(Shop, GetOrdersToImport(B2B), Cursor);
        OrdersToImport.FindFirst();
        OrdersToImport.SetRecFilter();
        JNull.SetValueToNull();
        JStore.Add('name', 'Online Store');
        Customer := GetCustomer();
        AddressId := Any.IntegerInRange(1000000, 9999999);
        BrowserIp := StrSubstNo('%1.%2.%3.%4', Any.IntegerInRange(1, 255), Any.IntegerInRange(0, 255), Any.IntegerInRange(0, 255), Any.IntegerInRange(0, 255));
        Price := OrdersToImport."Order Amount";
        TaxRate := 10;
        TaxPrice := Price - Round(Price / (1 + TaxRate / 100), 0.01);
        DiscountPrice := 0;
        ShippingPrice := Any.DecimalInRange(0, TaxPrice, 2);
        ItemPrice := Price - ShippingPrice;
        if Evaluate(OrderNumber, DelChr(OrdersToImport."Order No.", '=', DelChr(OrdersToImport."Order No.", '=', '0123456789'))) then;
        JOrder.Add('legacyResourceId', OrdersToImport.Id);
        JOrder.Add('name', OrdersToImport."Order No.");
        JOrder.Add('createdAt', OrdersToImport."Created At");
        JOrder.Add('confirmed', true);
        JOrder.Add('updatedAt', OrdersToImport."Updated At");
        JOrder.Add('cancelReason', JNull);
        JOrder.Add('cancelledAt', JNull);
        JOrder.Add('closed', JNull);
        JOrder.Add('closedAt', JNull);
        JOrder.Add('test', true);
        JOrder.Add('email', Customer."E-Mail");
        JOrder.Add('phone', Customer."Phone No.");
        JOrder.Add('customer', CreateCustomer(Customer, ShopifyCustomer));
        JOrder.Add('displayAddress', CreateAddress(Customer, AddressId, false, false));
        JOrder.Add('shippingAddress', CreateAddress(Customer, AddressId, true, true));
        JOrder.Add('billingAddressMatchesShippingAddress', true);
        JOrder.Add('billingAddress', CreateAddress(Customer, AddressId, true, false));
        JOrder.Add('publication', JStore);
        JOrder.Add('app', JStore);
        JOrder.Add('currency', OrdersToImport."Currency Code");
        JOrder.Add('presentmentCurrencyCode', OrdersToImport."Currency Code");
        JOrder.Add('unpaid', false);
        JOrder.Add('location', JNull);
        JOrder.Add('physicalLocation', JNull);
        JOrder.Add('note', Any.AlphabeticText(Any.IntegerInRange(100, 500)));
        JOrder.Add('customAttributes', JArray);
        JOrder.Add('discountCodes', JNull);
        JOrder.Add('displayFinancialStatus', "Shpfy Financial Status".Names().Get(OrdersToImport."Financial Status".AsInteger()).ToUpper().Replace(' ', '_'));
        JOrder.Add('displayFulfillmentStatus', Format(OrdersToImport."Fulfillment Status").ToUpper());
        JOrder.Add('total_weight', Any.IntegerInRange(0, 1000));
        JOrder.Add('refundable', false);
        JOrder.Add('risks', GetRiskLevels());
        JOrder.Add('tags', OrdersToImport.Tags);
        JOrder.Add('paymentGatewayNames', GetPaymentGatewayNames());
        JOrder.Add('processedAt', OrdersToImport."Created At");
        JOrder.Add('requiresShipping', true);
        JOrder.Add('sourceIdentifier', JNull);
        JOrder.Add('paymentTerms', JNull);
        JOrder.Add('taxesIncluded', true);
        JOrder.Add('currentCartDiscountAmountSet', AddPriceSet(0));
        JOrder.Add('currentSubtotalPriceSet', AddPriceSet(ItemPrice));
        JOrder.Add('currentTotalDiscountsSet', AddPriceSet(DiscountPrice));
        JOrder.Add('currentTotalDutiesSet', JNull);
        JOrder.Add('currentTotalPriceSet', AddPriceSet(Price));
        JOrder.Add('currentTotalTaxSet', AddPriceSet(TaxPrice));
        JOrder.Add('netPaymentSet', AddPriceSet(ItemPrice));
        JOrder.Add('originalTotalDutiesSet', JNull);
        JOrder.Add('refundDiscrepancySet', AddPriceSet(ItemPrice));
        JOrder.Add('subtotalPriceSet', AddPriceSet(ItemPrice));
        JOrder.Add('totalCapturableSet', AddPriceSet(0));
        JOrder.Add('totalDiscountsSet', AddPriceSet(DiscountPrice));
        JOrder.Add('totalOutstandingSet', AddPriceSet(0));
        JOrder.Add('totalPriceSet', AddPriceSet(OrdersToImport."Order Amount"));
        JOrder.Add('totalReceivedSet', AddPriceSet(0));
        JOrder.Add('totalRefundedSet', AddPriceSet(0));
        JOrder.Add('totalRefundedShippingSet', AddPriceSet(0));
        JOrder.Add('totalShippingPriceSet', AddPriceSet(ItemPrice));
        JOrder.Add('totalTaxSet', CreateTaxLines(TaxPrice, TaxRate));
        JOrder.Add('totalTipReceivedSet', AddPriceSet(0));
        if B2B then begin
            JCustomer.Add('legacyResourceId', ShopifyCustomer.Id);
            JCustomer.Add('email', ShopifyCustomer.Email);
            JCustomer.Add('phone', ShopifyCustomer."Phone No.");
            JMainContact.Add('id', 'gid://shopify/CompanyContact/1234567890');
            JMainContact.Add('customer', JCustomer);
            JCompany.Add('id', CreateCompany(Customer, ShopifyCustomer));
            JCompany.Add('mainContact', JMainContact);
            JPurchasingEntity.Add('company', JCompany);
            JOrder.Add('purchasingEntity', JPurchasingEntity);
        end else
            JOrder.Add('purchasingEntity', JPurchasingEntity);

        JShopifyLineItems := CreateLineItem(Shop, Price, TaxPrice, TaxRate, DiscountPrice);
    end;

    internal procedure CreateLineItem(Shop: Record "Shpfy Shop"; Price: Decimal; TaxPrice: Decimal; TaxRate: Decimal; Discount: Decimal) JLines: JsonArray
    var
        Item: Record Item;
        Location: Record Location;
        ShopLocation: Record "Shpfy Shop Location";
        ShopifyVariant: Record "Shpfy Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        ProductInitTest: codeunit "Shpfy Product Init Test";
        Id: BigInteger;
        JLine: JsonObject;
        JNull: JsonValue;
        JArray: JsonArray;
        JProduct: JsonObject;
        JVariant: JsonObject;
        JFulfillmentService: JsonObject;
        JLocation: JsonObject;
        GidLbl: Label 'gid://shopify/LineItem/%1', Locked = true, Comment = '%1 = Line Id';
    begin
        Item := ProductInitTest.CreateItem();
        Item.SetRecFilter();
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);
        ShopifyVariant := TempShopifyVariant;
        ShopifyVariant.Id := ProductInitTest.GetShopifyVariantId();
        ShopifyVariant.Insert();

        ShopLocation.Init();
        ShopLocation."Shop Code" := Shop.Code;
        ShopLocation.Id := Any.IntegerInRange(10000, 999999);
        ShopLocation."Stock Calculation" := ShopLocation."Stock Calculation"::Disabled;
        if Location.FindFirst() then begin
            ShopLocation."Default Location Code" := Location.Code;
            ShopLocation.Name := CopyStr(Location.Name, 1, MaxStrLen(ShopLocation.Name));
        end;
        ShopLocation.Insert();
        Id := Any.IntegerInRange(10000, 99999);
        JProduct.Add('legacyResourceId', TempShopifyProduct.Id);
        JProduct.Add('isGiftCard', false);
        JVariant.Add('legacyResourceId', ShopifyVariant.Id);
        JLocation.Add('legacyResourceId', ShopLocation.Id);
        JLocation.Add('name', ShopLocation.Name);
        JFulfillmentService.Add('location', JLocation);
        JFulfillmentService.Add('shippingMethods', JArray);
        JFulfillmentService.Add('serviceName', 'Manual');

        JLine.Add('id', StrSubstNo(GidLbl, Id));
        JLine.Add('name', Item.Description);
        JLine.Add('quantity', 1);
        JLine.Add('currentQuantity', 1);
        JLine.Add('nonFulfillableQuantity', 0);
        JLine.Add('sku', TempShopifyVariant.SKU);
        JLine.Add('title', Item.Description);
        JLine.Add('variantTitle', '');
        JLine.Add('vendor', TempShopifyProduct.Vendor);
        JLine.Add('product', JProduct);
        JLine.Add('variant', JVariant);
        JLine.Add('customAttributes', JArray);
        JLine.Add('refundableQuantity', 0);
        JLine.Add('requiresShipping', true);
        JLine.Add('restockable', true);
        JLine.Add('fulfillmentStatus', JNull);
        JLine.Add('duties', JArray);
        JLine.Add('taxable', true);
        JLine.Add('fulfillableQuantity', 1);
        JLine.Add('fulfillmentService', JFulfillmentService);
        JLine.Add('discountAllocations', JArray);
        JLine.Add('discountedTotalSet', AddPriceSet(Discount));
        JLine.Add('discountedUnitPriceSet', AddPriceSet(Discount));
        JLine.Add('originalTotalSet', Price);
        JLine.Add('originalUnitPriceSet', Price);
        JLine.Add('totalDiscountSet', Discount);
        JLine.Add('unfulfilledDiscountedTotalSet', 0);
        JLine.Add('taxLines', CreateTaxLines(TaxPrice, TaxRate));
        JLines.Add(JLine);
    end;

    local procedure CreateTaxLines(TaxPrice: Decimal; TaxRate: Decimal) JTaxLines: JsonArray;
    var
        JTaxLine: JsonObject;
    begin
        JTaxLine.Add('channelLiable', false);
        JTaxLine.Add('priceSet', AddPriceSet(TaxPrice));
        JTaxLine.Add('rate', TaxRate);
        JTaxLine.Add('title', 'TVA');
        JTaxLines.Add(JTaxLine);
    end;

    local procedure GetPaymentGatewayNames() JResult: JsonArray
    begin
        JResult.Add('bogus');
    end;

    local procedure AddPriceSet(Price: Decimal) JSet: JsonObject
    var
        JShopMoney: JsonObject;
        JPresentManey: JsonObject;
    begin
        JShopMoney.Add('amount', Format(Price, 0, 9));
        JSet.Add('shopMoney', JShopMoney);
        JPresentManey.Add('amount', Format(Price, 0, 9));
        JSet.Add('presentmentMoney', JPresentManey);
    end;

    local procedure GetCustomer(): Record Customer
    var
        InitializeTest: Codeunit "Shpfy Initialize Test";
    begin
        exit(InitializeTest.GetDummyCustomer());
    end;

    local procedure GetRiskLevels() JRisks: JsonArray
    var
        Index: Integer;
    begin
        for Index := 1 to Any.IntegerInRange(5, 10) do
            JRisks.Add(GetRiskLevel());
    end;

    local procedure GetRiskLevel() JRisk: JsonObject
    begin
        JRisk.Add('level', "Shpfy Risk Level".Names().Get(Any.IntegerInRange(1, "Shpfy Risk Level".Names().Count)).ToUpper());
        JRisk.Add('display', Any.Boolean());
        JRisk.Add('message', Any.AlphabeticText(100));
    end;

    local procedure CreateAddress(Customer: Record Customer; AddressId: BigInteger; IncludeFullName: Boolean; IncludeGeoCodes: Boolean) JAddress: JsonObject
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
        JNull: JsonValue;
        GidLbl: Label 'gid://shopify/MailingAddress/%1?model_name=Address', Locked = true, Comment = '%1 = Address Id';
    begin
        JNull.SetValueToNull();
        if Customer."Country/Region Code" = '' then begin
            CompanyInformation.Get();
            Customer."Country/Region Code" := CompanyInformation."Country/Region Code";
        end;
        if not CountryRegion.Get(Customer."Country/Region Code") then
            CountryRegion.Init();
        JAddress.Add('id', StrSubstNo(GidLbl, AddressId));
        if IncludeFullName then
            JAddress.Add('name', Customer.Name + ' ' + Customer."Name 2");
        JAddress.Add('firstName', Customer.Name);
        JAddress.Add('lastName', Customer."Name 2");
        JAddress.Add('Company', JNull);
        JAddress.Add('address1', Customer.Address);
        JAddress.Add('address2', Customer."Address 2");
        JAddress.Add('phone', Customer."Phone No.");
        JAddress.Add('zip', Customer."Post Code");
        JAddress.Add('city', Customer.City);
        JAddress.Add('provinceCode', JNull);
        JAddress.Add('province', CountryRegion."County Name");
        JAddress.Add('country_code', CountryRegion."ISO Code");
        JAddress.Add('country', CountryRegion.Name);
        JAddress.Add('Phone', Customer."Phone No.");
        if IncludeGeoCodes then begin
            JAddress.Add('latitude', JNull);
            JAddress.Add('longitude', JNull);
        end;
    end;

    local procedure CreateCustomerAddress(Customer: Record Customer) JAddress: JsonObject
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
        JNull: JsonValue;
        GidLbl: Label 'gid://shopify/MailingAddress/%1?model_name=CustomerAddress', Locked = true, Comment = '%1 = Address Id';
    begin
        JNull.SetValueToNull();
        if Customer."Country/Region Code" = '' then begin
            CompanyInformation.Get();
            Customer."Country/Region Code" := CompanyInformation."Country/Region Code";
        end;
        if not CountryRegion.Get(Customer."Country/Region Code") then
            CountryRegion.Init();
        JAddress.Add('id', StrSubstNo(GidLbl, Any.IntegerInRange(100000, 999999)));
        JAddress.Add('phone', Customer."Phone No.");
    end;

    local procedure CreateCustomer(Customer: Record Customer; var ShopifyCustomer: Record "Shpfy Customer") JCustomer: JsonObject
    var
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
        JNull: JsonValue;
    begin
        CustomerInitTest.CreateShopifyCustomer(ShopifyCustomer);
        ShopifyCustomer."Customer SystemId" := Customer.SystemId;
        ShopifyCustomer.Modify();
        JNull.SetValueToNull();
        JCustomer.Add('legacyResourceId', ShopifyCustomer.Id);
        JCustomer.Add('email', Customer."E-Mail");
        JCustomer.Add('phone', Customer."Phone No.");
        JCustomer.Add('defaultAddress', CreateCustomerAddress(Customer));
    end;

    local procedure CreateCompany(Customer: Record Customer; ShopifyCustomer: Record "Shpfy Customer"): BigInteger
    var
        ShopifyCompany: Record "Shpfy Company";
        CompanyInitialize: Codeunit "Shpfy Company Initialize";
    begin
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        ShopifyCompany."Customer SystemId" := Customer.SystemId;
        ShopifyCompany."Main Contact Customer Id" := ShopifyCustomer.Id;
        ShopifyCompany.Modify();
        exit(ShopifyCompany.Id);
    end;
}