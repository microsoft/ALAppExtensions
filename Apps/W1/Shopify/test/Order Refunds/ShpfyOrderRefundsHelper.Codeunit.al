codeunit 139564 "Shpfy Order Refunds Helper"
{
    var
        Shop: Record "Shpfy Shop";
        Any: Codeunit Any;


    internal procedure CreateShopifyDocuments() ShopifyIds: Dictionary of [Text, List of [BigInteger]]
    var
        DocLink: Record "Shpfy Doc. Link To Doc.";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        OrderId: BigInteger;
        ProductId: BigInteger;
        VariantId: BigInteger;
        ReturnId: BigInteger;
        RefundId: BigInteger;
    begin
        Any.SetDefaultSeed();
        Shop := CommunicationMgt.GetShopRecord();
        ProductId := Any.IntegerInRange(100000, 999999);
        VariantId := Any.IntegerInRange(100000, 999999);
        ShopifyIds.Add('Order', ListOfIds());
        ShopifyIds.Add('OrderLine', ListOfIds());
        ShopifyIds.Add('Return', ListOfIds());
        ShopifyIds.Add('Refund', ListOfIds());

        OrderId := CreateShopifyOrder();
        ShopifyIds.Get('Order').Add(OrderId);
        ShopifyIds.Get('OrderLine').Add(CreateOrderLine(OrderId, 1, ProductId, VariantId));
        ShopifyIds.Get('OrderLine').Add(CreateOrderLine(OrderId, 2, ProductId, VariantId));
        DocLink."Shopify Document Type" := Enum::"Shpfy shop Document Type"::"Shopify shop Order";
        DocLink."Shopify Document Id" := OrderId;
        DocLink."Document Type" := Enum::"Shpfy Document Type"::"Sales Order";
        DocLink."Document No." := Any.AlphabeticText(10);
        DocLink.Insert();

        ReturnId := CreateReturn(OrderId);
        CreateReturnLine(ReturnId, ShopifyIds.Get('OrderLine').Get(1), 'DEFECTIVE');
        ShopifyIds.Get('Return').Add(ReturnId);

        ReturnId := CreateReturn(OrderId);
        CreateReturnLine(ReturnId, ShopifyIds.Get('OrderLine').Get(2), 'NOT_AS_DESCRIBED');
        ShopifyIds.Get('Return').Add(ReturnId);

        RefundId := CreateRefundHeader(OrderId, ShopifyIds.Get('Return').Get(1), 156.38);
        CreateRefundLine(RefundId, ShopifyIds.Get('OrderLine').Get(1));
        ShopifyIds.Get('Refund').Add(RefundId);

        RefundId := CreateRefundHeader(OrderId, 0, 5);
        ShopifyIds.Get('Refund').Add(RefundId);

        RefundId := CreateRefundHeader(OrderId, ShopifyIds.Get('Return').Get(2), 0);
        CreateRefundLine(RefundId, ShopifyIds.Get('OrderLine').Get(2));
        ShopifyIds.Get('Refund').Add(RefundId);

        RefundId := CreateRefundHeader(OrderId, Any.IntegerInRange(100000, 999999), 0);
        CreateRefundLine(RefundId, Any.IntegerInRange(100000, 999999));
        ShopifyIds.Get('Refund').Add(RefundId); // 4th refund - linked zero

        RefundId := CreateRefundHeader(OrderId, 0, 150);
        CreateRefundLine(RefundId, Any.IntegerInRange(100000, 999999));
        ShopifyIds.Get('Refund').Add(RefundId); // 5th refund - non linked non zero

        RefundId := CreateRefundHeader(OrderId, 0, 0);
        CreateRefundLine(RefundId, Any.IntegerInRange(100000, 999999));
        ShopifyIds.Get('Refund').Add(RefundId); // 6th refund - not linked zero

        Commit();
    end;

    local procedure ListOfIds(): List of [BigInteger]
    var
        Ids: List of [BigInteger];
    begin
        exit(Ids);
    end;

    local procedure CreateShopifyOrder(): BigInteger
    var
        OrderHeader: Record "Shpfy Order Header";
        Customer: Record Customer;
    begin
        Customer := GetCustomer();
        OrderHeader."Shopify Order Id" := Any.IntegerInRange(100000, 999999);
        OrderHeader."Sales Order No." := Any.AlphabeticText(10);
        OrderHeader."Created At" := CurrentDateTime;
        OrderHeader.Confirmed := true;
        OrderHeader."Updated At" := CurrentDateTime;
        OrderHeader.Test := true;
        OrderHeader.Email := Customer."E-Mail";
        OrderHeader."Phone No." := Customer."Phone No.";
        OrderHeader."Customer Id" := Any.IntegerInRange(100000, 999999);
        OrderHeader."Sell-to First Name" := Customer.Name;
        OrderHeader."Sell-to Last Name" := Customer."Name 2";
        OrderHeader."Sell-to Address" := Customer.Address;
        OrderHeader."Sell-to Address 2" := Customer."Address 2";
        OrderHeader."Sell-to Post Code" := Customer."Post Code";
        OrderHeader."Sell-to City" := Customer.City;
        OrderHeader."Sell-to County" := Customer.County;
        OrderHeader."Sell-to Country/Region Code" := Customer."Country/Region Code";
        OrderHeader."Sell-to Customer No." := Customer."No.";
        OrderHeader."Bill-to First Name" := Customer.Name;
        OrderHeader."Bill-to Lastname" := Customer."Name 2";
        OrderHeader."Bill-to Address" := Customer.Address;
        OrderHeader."Bill-to Address 2" := Customer."Address 2";
        OrderHeader."Bill-to Post Code" := Customer."Post Code";
        OrderHeader."Bill-to City" := Customer.City;
        OrderHeader."Bill-to County" := Customer.County;
        OrderHeader."Bill-to Country/Region Code" := Customer."Country/Region Code";
        OrderHeader."Bill-to Customer No." := Customer."No.";
        OrderHeader."Ship-to First Name" := Customer.Name;
        OrderHeader."Ship-to Last Name" := Customer."Name 2";
        OrderHeader."Ship-to Address" := Customer.Address;
        OrderHeader."Ship-to Address 2" := Customer."Address 2";
        OrderHeader."Ship-to Post Code" := Customer."Post Code";
        OrderHeader."Ship-to City" := Customer.City;
        OrderHeader."Ship-to County" := Customer.County;
        OrderHeader."Ship-to Country/Region Code" := Customer."Country/Region Code";
        OrderHeader."App Name" := 'Online Store';
        OrderHeader."Currency Code" := '';
        OrderHeader."Presentment Currency Code" := '';
        OrderHeader.Unpaid := false;
        OrderHeader."Financial Status" := Enum::"Shpfy Financial Status"::Refunded;
        OrderHeader."Fulfillment Status" := Enum::"Shpfy Order Fulfill. Status"::Fulfilled;
        OrderHeader."Total Weight" := Any.DecimalInRange(1000, 2);
        OrderHeader.Refundable := false;
        OrderHeader."Processed At" := CurrentDateTime;
        OrderHeader.Gateway := 'bogus';
        OrderHeader."Total Amount" := 317.76;
        OrderHeader."Subtotal Amount" := 312.76;
        OrderHeader."Shipping Charges Amount" := 5;
        OrderHeader."VAT Amount" := 55.15;
        OrderHeader."VAT Included" := true;
        OrderHeader."Shop Code" := Shop.Code;
        OrderHeader.Insert();
        exit(OrderHeader."Shopify Order Id");
    end;

    local procedure CreateOrderLine(OrderId: BigInteger; LineNo: Integer; ProductId: BigInteger; VariantId: BigInteger): BigInteger
    var
        Item: Record Item;
        OrderLine: Record "Shpfy Order Line";
    begin
        Item := GetItem();
        LineNo := LineNo * 100000;
        OrderLine."Shopify Order Id" := OrderId;
        OrderLine."Line Id" := Any.IntegerInRange(LineNo, LineNo + 99999);
        OrderLine.Description := Item.Description;
        OrderLine.Quantity := 1;
        OrderLine."Shopify Product Id" := ProductId;
        OrderLine."Shopify Variant Id" := VariantId;
        OrderLine."Item No." := Item."No.";
        OrderLine."Gift Card" := false;
        OrderLine.Taxable := false;
        OrderLine."Discount Amount" := 0;
        OrderLine."Unit Price" := 156.38;
        OrderLine.Insert();
        exit(OrderLine."Line Id");
    end;

    local procedure CreateReturn(OrderId: BigInteger): BigInteger
    var
        ReturnHeader: Record "Shpfy Return Header";
    begin
        ReturnHeader."Return Id" := Any.IntegerInRange(100000, 999999);
        ReturnHeader."Order Id" := OrderId;
        ReturnHeader."Return No." := Any.AlphabeticText(10);
        ReturnHeader.Status := Enum::"Shpfy Return Status"::Closed;
        ReturnHeader."Total Quantity" := 1;
        ReturnHeader."Shop Code" := Shop.Code;
        ReturnHeader.Insert();
        exit(ReturnHeader."Return Id");
    end;

    local procedure CreateReturnLine(ReturnOrderId: BigInteger; OrderLineId: BigInteger; ReturnReason: Text)
    var
        ReturnLine: Record "Shpfy Return Line";
        ReturnEnumConvertor: Codeunit "Shpfy Return Enum Convertor";
    begin
        ReturnLine."Return Line Id" := Any.IntegerInRange(100000, 999999);
        ReturnLine."Return Id" := ReturnOrderId;
        ReturnLine."Fulfillment Line Id" := Any.IntegerInRange(100000, 999999);
        ReturnLine."Order Line Id" := OrderLineId;
        ReturnLine."Return Reason" := ReturnEnumConvertor.ConvertToReturnReason(ReturnReason);
        ReturnLine.Quantity := 1;
        ReturnLine."Refundable Quantity" := 0;
        ReturnLine."Refunded Quantity" := 1;
        ReturnLine.Weight := 9.55;
        ReturnLine."Weight Unit" := 'KILOGRAMS';
        ReturnLine."Discounted Total Amount" := 156.38;
        ReturnLine.Insert();
    end;

    local procedure CreateRefundHeader(OrderId: BigInteger; ReturnId: BigInteger; Amount: Decimal): BigInteger
    var
        RefundHeader: Record "Shpfy Refund Header";
    begin
        RefundHeader."Refund Id" := Any.IntegerInRange(100000, 9999999);
        RefundHeader."Order Id" := OrderId;
        RefundHeader."Return Id" := ReturnId;
        RefundHeader."Created At" := CurrentDateTime;
        RefundHeader."Shop Code" := Shop.Code;
        RefundHeader."Updated At" := CurrentDateTime;
        RefundHeader."Total Refunded Amount" := Amount;
        RefundHeader.Insert();
        exit(RefundHeader."Refund Id");
    end;

    local procedure CreateRefundLine(RefundId: BigInteger; OrderLineId: BigInteger)
    var
        RefundLine: Record "Shpfy Refund Line";
        RefundHeader: Record "Shpfy Refund Header";
        RefundsAPI: Codeunit "Shpfy Refunds API";
        RefundEnumConvertor: Codeunit "Shpfy Refund Enum Convertor";
    begin
        RefundHeader.Get(RefundId);
        RefundLine."Refund Line Id" := Any.IntegerInRange(100000, 999999);
        RefundLine."Refund Id" := RefundId;
        RefundLine."Order Line Id" := OrderLineId;
        RefundLine."Restock Type" := RefundEnumConvertor.ConvertToReStockType('RETURN');
        RefundLine.Quantity := 1;
        RefundLine.Restocked := true;
        RefundLine.Amount := 156.38;
        RefundLine."Subtotal Amount" := 156.38;
        RefundLine."Can Create Credit Memo" := RefundsAPI.IsNonZeroOrReturnRefund(RefundHeader);
        RefundLine.Insert();
    end;

    local procedure GetItem(): Record Item
    var
        InitializeTest: Codeunit "Shpfy Initialize Test";
    begin
        exit(InitializeTest.GetDummyItem());
    end;

    local procedure GetCustomer(): Record Customer
    var
        InitializeTest: Codeunit "Shpfy Initialize Test";
    begin
        exit(InitializeTest.GetDummyCustomer());
    end;
}