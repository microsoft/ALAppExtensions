namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;
using Microsoft.Finance.GeneralLedger.Setup;

/// <summary>
/// Codeunit Shpfy Posted Invoice Export" (ID 30316).
/// </summary>
codeunit 30362 "Shpfy Posted Invoice Export"
{
    Access = Internal;
    TableNo = "Sales Invoice Header";
    Permissions = tabledata "Sales Invoice Header" = m;

    var
        Shop: Record "Shpfy Shop";
        DraftOrdersAPI: Codeunit "Shpfy Draft Orders API";
        FulfillmentAPI: Codeunit "Shpfy Fulfillment API";
        JsonHelper: Codeunit "Shpfy Json Helper";

    trigger OnRun()
    begin
        ExportPostedSalesInvoiceToShopify(Rec);
    end;

    /// <summary> 
    /// Sets a global shopify shop to be used for posted invoice export.
    /// </summary>
    /// <param name="NewShopCode">Shopify shop code to be set.</param>
    internal procedure SetShop(NewShopCode: Code[20])
    begin
        Shop.Get(NewShopCode);
        DraftOrdersAPI.SetShop(Shop.Code);
        FulfillmentAPI.SetShop(Shop.Code);
    end;

    /// <summary>
    /// Exports provided posted sales invoice to shopify.
    /// </summary>
    /// <remarks>
    /// If the posted sales invoice isn't exportable, the shopify order id is set to -2. 
    /// If shopify order creation fails, the id is set to -1.
    /// </remarks>
    /// <param name="SalesInvoiceHeader">Posted sales invoice to be exported.</param>
    internal procedure ExportPostedSalesInvoiceToShopify(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        TempOrderHeader: Record "Shpfy Order Header" temporary;
        TempOrderLine: Record "Shpfy Order Line" temporary;
        DraftOrderId: BigInteger;
        OrderTaxLines: Dictionary of [Text, Decimal];
        FulfillmentOrderIds: List of [BigInteger];
        JResponse: JsonToken;
        OrderId: BigInteger;
        OrderNo: Text;
    begin
        if not IsInvoiceExportable(SalesInvoiceHeader) then begin
            SetSalesInvoiceShopifyOrderInformation(SalesInvoiceHeader, -2, '');
            exit;
        end;

        MapPostedSalesInvoiceData(SalesInvoiceHeader, TempOrderHeader, TempOrderLine, OrderTaxLines);

        DraftOrderId := DraftOrdersAPI.CreateDraftOrder(TempOrderHeader, TempOrderLine, OrderTaxLines);
        if DraftOrderId = 0 then begin
            SetSalesInvoiceShopifyOrderInformation(SalesInvoiceHeader, -1, '');
            exit;
        end;
        JResponse := DraftOrdersAPI.CompleteDraftOrder(DraftOrderId);

        if IsSuccess(JResponse) then begin
            OrderId := JsonHelper.GetValueAsBigInteger(JResponse, 'data.draftOrderComplete.draftOrder.order.legacyResourceId');
            OrderNo := JsonHelper.GetValueAsText(JResponse, 'data.draftOrderComplete.draftOrder.order.name');

            FulfillmentOrderIds := FulfillmentAPI.GetFulfillmentOrderIds(Format(OrderId), GetNumberOfLines(TempOrderLine, OrderTaxLines));
            CreateFulfillmentsForShopifyOrder(FulfillmentOrderIds);
            CreateShopifyInvoiceHeader(OrderId);
            SetSalesInvoiceShopifyOrderInformation(SalesInvoiceHeader, OrderId, Format(OrderNo));
            AddDocumentLinkToBCDocument(SalesInvoiceHeader);
        end else
            SetSalesInvoiceShopifyOrderInformation(SalesInvoiceHeader, -1, '');
    end;

    local procedure CreateFulfillmentsForShopifyOrder(FulfillmentOrderIds: List of [BigInteger])
    var
        FulfillmentOrderId: BigInteger;
    begin
        foreach FulfillmentOrderId in FulfillmentOrderIds do
            FulfillmentAPI.CreateFulfillment(FulfillmentOrderId);
    end;

    local procedure IsInvoiceExportable(SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    var
        ShopifyCompany: Record "Shpfy Company";
        ShopifyCustomer: Record "Shpfy Customer";
    begin
        ShopifyCompany.SetRange("Customer No.", SalesInvoiceHeader."Bill-to Customer No.");
        if ShopifyCompany.IsEmpty() then begin
            ShopifyCustomer.SetRange("Customer No.", SalesInvoiceHeader."Bill-to Customer No.");
            if ShopifyCustomer.IsEmpty() then
                exit(false);
        end;

        if not ShopifyPaymentTermsExists(SalesInvoiceHeader."Payment Terms Code") then
            exit(false);

        if Shop."Default Customer No." = SalesInvoiceHeader."Bill-to Customer No." then
            exit(false);

        if CheckCustomerTemplates(SalesInvoiceHeader."Bill-to Customer No.") then
            exit(false);

        if not CheckSalesInvoiceHeaderLines(SalesInvoiceHeader) then
            exit(false);

        exit(true);
    end;

    local procedure ShopifyPaymentTermsExists(PaymentTermsCode: Code[10]): Boolean
    var
        ShopifyPaymentTerms: Record "Shpfy Payment Terms";
    begin
        ShopifyPaymentTerms.SetRange("Payment Terms Code", PaymentTermsCode);
        ShopifyPaymentTerms.SetRange("Shop Code", Shop.Code);

        if ShopifyPaymentTerms.IsEmpty() then begin
            ShopifyPaymentTerms.SetRange("Payment Terms Code");
            ShopifyPaymentTerms.SetRange("Is Primary", true);

            if ShopifyPaymentTerms.IsEmpty() then
                exit(false);
        end;

        exit(true);
    end;

    local procedure CheckCustomerTemplates(CustomerNo: Code[20]): Boolean
    var
        ShopifyCustomerTemplate: Record "Shpfy Customer Template";
    begin
        ShopifyCustomerTemplate.SetRange("Default Customer No.", CustomerNo);
        ShopifyCustomerTemplate.SetRange("Shop Code", Shop.Code);
        exit(not ShopifyCustomerTemplate.IsEmpty());
    end;

    local procedure CheckSalesInvoiceHeaderLines(SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.SetFilter(Type, '<>%1', SalesInvoiceLine.Type::" ");
        if SalesInvoiceLine.IsEmpty() then
            exit(false);

        SalesInvoiceLine.Reset();

        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        if SalesInvoiceLine.FindSet() then
            repeat
                if (SalesInvoiceLine.Quantity <> 0) and (SalesInvoiceLine.Quantity <> Round(SalesInvoiceLine.Quantity, 1)) then
                    exit(false);

                if (SalesInvoiceLine.Type <> SalesInvoiceLine.Type::" ") and (SalesInvoiceLine."No." = '') then
                    exit(false);
            until SalesInvoiceLine.Next() = 0;

        exit(true);
    end;

    local procedure SetSalesInvoiceShopifyOrderInformation(var SalesInvoiceHeader: Record "Sales Invoice Header"; OrderId: BigInteger; OrderNo: Code[50])
    begin
        SalesInvoiceHeader.Validate("Shpfy Order Id", OrderId);
        SalesInvoiceHeader.Validate("Shpfy Order No.", OrderNo);
        SalesInvoiceHeader.Modify(true);
    end;

    internal procedure MapPostedSalesInvoiceData(
        SalesInvoiceHeader: Record "Sales Invoice Header";
        var TempOrderHeader: Record "Shpfy Order Header" temporary;
        var TempOrderLine: Record "Shpfy Order Line" temporary;
        var OrderTaxLines: Dictionary of [Text, Decimal]
    )
    var
        InvoiceLine: Record "Sales Invoice Line";
    begin
        MapSalesInvoiceHeader(SalesInvoiceHeader, TempOrderHeader);

        InvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        InvoiceLine.SetFilter(Quantity, '>%1', 0);
        if InvoiceLine.FindSet() then
            repeat
                MapSalesInvoiceLine(InvoiceLine, TempOrderHeader, TempOrderLine, OrderTaxLines);
            until InvoiceLine.Next() = 0;
    end;

    local procedure MapSalesInvoiceHeader(
        SalesInvoiceHeader: Record "Sales Invoice Header";
        var TempOrderHeader: Record "Shpfy Order Header" temporary
    )
    begin
        TempOrderHeader.Init();
        TempOrderHeader."Sales Invoice No." := SalesInvoiceHeader."No.";
        TempOrderHeader."Sales Order No." := SalesInvoiceHeader."Order No.";
        TempOrderHeader."Created At" := SalesInvoiceHeader.SystemCreatedAt;
        TempOrderHeader.Confirmed := true;
        TempOrderHeader."Updated At" := SalesInvoiceHeader.SystemModifiedAt;
        TempOrderHeader."Currency Code" := MapCurrencyCode(SalesInvoiceHeader);
        TempOrderHeader."Document Date" := SalesInvoiceHeader."Document Date";
        SalesInvoiceHeader.CalcFields(Amount, "Amount Including VAT", "Invoice Discount Amount");
        TempOrderHeader."VAT Amount" := SalesInvoiceHeader."Amount Including VAT" - SalesInvoiceHeader.Amount;
        TempOrderHeader."Discount Amount" := SalesInvoiceHeader."Invoice Discount Amount";
        TempOrderHeader."Fulfillment Status" := Enum::"Shpfy Order Fulfill. Status"::Fulfilled;
        TempOrderHeader."Shop Code" := Shop.Code;
        TempOrderHeader.Unpaid := IsInvoiceUnpaid(SalesInvoiceHeader);

        MapBillToInformation(TempOrderHeader, SalesInvoiceHeader);
        MapShipToInformation(TempOrderHeader, SalesInvoiceHeader);

        TempOrderHeader.Insert(false);
    end;

    local procedure MapCurrencyCode(SalesInvoiceHeader: Record "Sales Invoice Header"): Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if SalesInvoiceHeader."Currency Code" <> '' then
            exit(SalesInvoiceHeader."Currency Code");

        GeneralLedgerSetup.Get();
        exit(GeneralLedgerSetup."LCY Code");
    end;

    local procedure MapBillToInformation(
        var TempOrderHeader: Record "Shpfy Order Header" temporary;
        SalesInvoiceHeader: Record "Sales Invoice Header"
    )
    var
        ShopifyCustomer: Record "Shpfy Customer";
    begin
        TempOrderHeader."Bill-to Name" := CopyStr(SalesInvoiceHeader."Bill-to Name", 1, MaxStrLen(TempOrderHeader."Bill-to Name"));
        TempOrderHeader."Bill-to Name 2" := SalesInvoiceHeader."Bill-to Name 2";
        TempOrderHeader."Bill-to Address" := SalesInvoiceHeader."Bill-to Address";
        TempOrderHeader."Bill-to Address 2" := SalesInvoiceHeader."Bill-to Address 2";
        TempOrderHeader."Bill-to Post Code" := SalesInvoiceHeader."Bill-to Post Code";
        TempOrderHeader."Bill-to City" := SalesInvoiceHeader."Bill-to City";
        TempOrderHeader."Bill-to County" := SalesInvoiceHeader."Bill-to County";
        TempOrderHeader."Bill-to Country/Region Code" := SalesInvoiceHeader."Bill-to Country/Region Code";
        TempOrderHeader."Bill-to Customer No." := SalesInvoiceHeader."Bill-to Customer No.";

        ShopifyCustomer.SetRange("Customer No.", SalesInvoiceHeader."Bill-to Customer No.");
        if ShopifyCustomer.FindFirst() then begin
            TempOrderHeader.Email := CopyStr(ShopifyCustomer.Email, 1, MaxStrLen(TempOrderHeader.Email));
            TempOrderHeader."Phone No." := ShopifyCustomer."Phone No.";
        end;
    end;

    local procedure MapShipToInformation(
        var TempOrderHeader: Record "Shpfy Order Header" temporary;
        SalesInvoiceHeader: Record "Sales Invoice Header"
    )
    begin
        TempOrderHeader."Ship-to Name" := CopyStr(SalesInvoiceHeader."Ship-to Name", 1, MaxStrLen(TempOrderHeader."Ship-to Name"));
        TempOrderHeader."Ship-to Name 2" := SalesInvoiceHeader."Ship-to Name 2";
        TempOrderHeader."Ship-to Address" := SalesInvoiceHeader."Ship-to Address";
        TempOrderHeader."Ship-to Address 2" := SalesInvoiceHeader."Ship-to Address 2";
        TempOrderHeader."Ship-to Post Code" := SalesInvoiceHeader."Ship-to Post Code";
        TempOrderHeader."Ship-to City" := SalesInvoiceHeader."Ship-to City";
        TempOrderHeader."Ship-to County" := SalesInvoiceHeader."Ship-to County";
        TempOrderHeader."Ship-to Country/Region Code" := SalesInvoiceHeader."Ship-to Country/Region Code";
    end;

    local procedure IsInvoiceUnpaid(SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    begin
        SalesInvoiceHeader.CalcFields("Remaining Amount");
        exit(SalesInvoiceHeader."Remaining Amount" <> 0);
    end;

    local procedure MapSalesInvoiceLine(
    SalesInvoiceLine: Record "Sales Invoice Line";
    var TempOrderHeader: Record "Shpfy Order Header" temporary;
    var TempOrderLine: Record "Shpfy Order Line" temporary;
    var OrderTaxLines: Dictionary of [Text, Decimal]
): BigInteger
    begin
        TempOrderLine.Init();
        TempOrderLine."Line Id" := SalesInvoiceLine."Line No.";
        TempOrderLine.Description := SalesInvoiceLine.Description;
        TempOrderLine.Quantity := SalesInvoiceLine.Quantity;
        TempOrderLine."Item No." := SalesInvoiceLine."No.";
        TempOrderLine."Variant Code" := SalesInvoiceLine."Variant Code";
        TempOrderLine."Gift Card" := false;
        TempOrderLine.Taxable := false;
        TempOrderLine."Unit Price" := SalesInvoiceLine."Unit Price";
        TempOrderHeader."Discount Amount" += SalesInvoiceLine."Line Discount Amount";
        TempOrderHeader.Modify(false);

        MapTaxLine(SalesInvoiceLine, OrderTaxLines);

        TempOrderLine.Insert(false);
    end;

    local procedure MapTaxLine(var SalesInvoiceLine: Record "Sales Invoice Line" temporary; var OrderTaxLines: Dictionary of [Text, Decimal])
    var
        VATAmount: Decimal;
        TaxLineTok: Label '%1 - %2%', Comment = '%1 = VAT Calculation Type, %2 = VAT %', Locked = true;
        TaxTitle: Text;
    begin
        VATAmount := SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine."VAT Base Amount";

        if VATAmount = 0 then
            exit;

        TaxTitle := StrSubstNo(TaxLineTok, Format(SalesInvoiceLine."VAT Calculation Type"), Format(SalesInvoiceLine."VAT %"));
        if OrderTaxLines.ContainsKey(TaxTitle) then
            OrderTaxLines.Set(TaxTitle, OrderTaxLines.Get(TaxTitle) + VATAmount)
        else
            OrderTaxLines.Add(TaxTitle, VATAmount);
    end;

    local procedure IsSuccess(JsonTokenResponse: JsonToken): Boolean
    begin
        exit(JsonHelper.GetJsonArray(JsonTokenResponse, 'data.draftOrderComplete.userErrors').Count() = 0);
    end;

    local procedure CreateShopifyInvoiceHeader(OrderId: BigInteger)
    var
        InvoiceHeader: Record "Shpfy Invoice Header";
    begin
        InvoiceHeader.Init();
        InvoiceHeader.Validate("Shopify Order Id", OrderId);
        InvoiceHeader.Insert(true);
    end;

    local procedure AddDocumentLinkToBCDocument(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        DocLinkToBCDoc: Record "Shpfy Doc. Link To Doc.";
        BCDocumentTypeConvert: Codeunit "Shpfy BC Document Type Convert";
    begin
        DocLinkToBCDoc.Init();
        DocLinkToBCDoc."Shopify Document Type" := "Shpfy Shop Document Type"::"Shopify Shop Order";
        DocLinkToBCDoc."Shopify Document Id" := SalesInvoiceHeader."Shpfy Order Id";
        DocLinkToBCDoc."Document Type" := BCDocumentTypeConvert.Convert(SalesInvoiceHeader);
        DocLinkToBCDoc."Document No." := SalesInvoiceHeader."No.";
        DocLinkToBCDoc.Insert(true);
    end;

    local procedure GetNumberOfLines(var TempOrderLine: Record "Shpfy Order Line" temporary; var OrderTaxLines: Dictionary of [Text, Decimal]): Integer
    begin
        exit(OrderTaxLines.Count() + TempOrderLine.Count());
    end;

    internal procedure ConfigurePaymentTermsMapping(ErrorInfo: ErrorInfo)
    var
        ShopifyShop: Record "Shpfy Shop";
        ShopifyPaymentTerms: Record "Shpfy Payment Terms";
    begin
        if ShopifyShop.Get(ErrorInfo.RecordId) then begin
            ShopifyPaymentTerms.SetRange("Shop Code", ShopifyShop.Code);
            Page.Run(Page::"Shpfy Payment Terms Mapping", ShopifyPaymentTerms);
        end;
    end;
}