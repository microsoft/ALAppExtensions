namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;
using Microsoft.Finance.GeneralLedger.Setup;

/// <summary>
/// Codeunit Shpfy Posted Invoice Export" (ID 30362).
/// </summary>
codeunit 30362 "Shpfy Posted Invoice Export"
{
    Access = Internal;
    TableNo = "Sales Invoice Header";
    Permissions = tabledata "Sales Invoice Header" = m;

    var
        ShpfyShop: Record "Shpfy Shop";
        ShpfyDraftOrdersAPI: Codeunit "Shpfy Draft Orders API";
        ShpfyFulfillmentAPI: Codeunit "Shpfy Fulfillment API";
        ShpfyJsonHelper: Codeunit "Shpfy Json Helper";

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
        ShpfyShop.Get(NewShopCode);
        ShpfyDraftOrdersAPI.SetShop(ShpfyShop.Code);
        ShpfyFulfillmentAPI.SetShop(ShpfyShop.Code);
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
        TempShpfyOrderHeader: Record "Shpfy Order Header" temporary;
        TempShpfyOrderLine: Record "Shpfy Order Line" temporary;
        DraftOrderId: BigInteger;
        ShpfyOrderTaxLines: Dictionary of [Text, Decimal];
        FulfillmentOrderIds: List of [BigInteger];
        JResponse: JsonToken;
        OrderId: BigInteger;
        OrderNo: Text;
    begin
        if not IsInvoiceExportable(SalesInvoiceHeader) then begin
            SetSalesInvoiceShopifyOrderInformation(SalesInvoiceHeader, -2, '');
            exit;
        end;

        MapPostedSalesInvoiceData(SalesInvoiceHeader, TempShpfyOrderHeader, TempShpfyOrderLine, ShpfyOrderTaxLines);

        DraftOrderId := ShpfyDraftOrdersAPI.CreateDraftOrder(TempShpfyOrderHeader, TempShpfyOrderLine, ShpfyOrderTaxLines);
        JResponse := ShpfyDraftOrdersAPI.CompleteDraftOrder(DraftOrderId);

        if IsSuccess(JResponse) then begin
            OrderId := ShpfyJsonHelper.GetValueAsBigInteger(JResponse, 'data.draftOrderComplete.draftOrder.order.legacyResourceId');
            OrderNo := ShpfyJsonHelper.GetValueAsText(JResponse, 'data.draftOrderComplete.draftOrder.order.name');

            FulfillmentOrderIds := ShpfyFulfillmentAPI.GetFulfillmentOrderIds(Format(OrderId), GetNumberOfLines(TempShpfyOrderLine, ShpfyOrderTaxLines));
            CreateFulfillmentsForShopifyOrder(FulfillmentOrderIds);
            CreateShpfyInvoiceHeader(OrderId);
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
            ShpfyFulfillmentAPI.CreateFulfillment(FulfillmentOrderId);
    end;

    local procedure IsInvoiceExportable(SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    var
        ShpfyCompany: Record "Shpfy Company";
        ShpfyCustomer: Record "Shpfy Customer";
    begin
        ShpfyCompany.SetRange("Customer No.", SalesInvoiceHeader."Bill-to Customer No.");
        if ShpfyCompany.IsEmpty() then begin
            ShpfyCustomer.SetRange("Customer No.", SalesInvoiceHeader."Bill-to Customer No.");
            if ShpfyCustomer.IsEmpty() then
                exit(false);
        end;

        if not CurrencyCodeMatch(SalesInvoiceHeader) then
            exit(false);

        if not ShopifyPaymentTermsExists(SalesInvoiceHeader."Payment Terms Code") then
            exit(false);

        if ShpfyShop."Default Customer No." = SalesInvoiceHeader."Bill-to Customer No." then
            exit(false);

        if CheckCustomerTemplates(SalesInvoiceHeader."Bill-to Customer No.") then
            exit(false);

        if not CheckSalesInvoiceHeaderLines(SalesInvoiceHeader) then
            exit(false);

        exit(true);
    end;

    local procedure CurrencyCodeMatch(SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ShopifyLocalCurrencyCode: Code[10];
    begin
        GeneralLedgerSetup.Get();

        if ShpfyShop."Currency Code" = '' then
            ShopifyLocalCurrencyCode := GeneralLedgerSetup."LCY Code"
        else
            ShopifyLocalCurrencyCode := ShpfyShop."Currency Code";

        if SalesInvoiceHeader."Currency Code" = '' then
            exit(ShopifyLocalCurrencyCode = GeneralLedgerSetup."LCY Code")
        else
            exit(ShopifyLocalCurrencyCode = SalesInvoiceHeader."Currency Code");
    end;

    local procedure ShopifyPaymentTermsExists(PaymentTermsCode: Code[10]): Boolean
    var
        ShpfyPaymentTerms: Record "Shpfy Payment Terms";
    begin
        ShpfyPaymentTerms.SetRange("Payment Terms Code", PaymentTermsCode);
        ShpfyPaymentTerms.SetRange("Shop Code", ShpfyShop.Code);

        if not ShpfyPaymentTerms.FindFirst() then begin
            ShpfyPaymentTerms.SetRange("Payment Terms Code");
            ShpfyPaymentTerms.SetRange("Is Primary", true);

            if not ShpfyPaymentTerms.FindFirst() then
                exit(false);
        end;

        exit(true);
    end;

    local procedure CheckCustomerTemplates(CustomerNo: Code[20]): Boolean
    var
        ShpfyCustomerTemplate: Record "Shpfy Customer Template";
    begin
        ShpfyCustomerTemplate.SetRange("Default Customer No.", CustomerNo);
        ShpfyCustomerTemplate.SetRange("Shop Code", ShpfyShop.Code);
        exit(not ShpfyCustomerTemplate.IsEmpty());
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

                if ShpfyShop."Items Mapped to Products" then
                    if not ItemIsMappedToShopifyProduct(SalesInvoiceLine) then
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

    local procedure ItemIsMappedToShopifyProduct(SalesInvoiceLine: Record "Sales Invoice Line"): Boolean
    var
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
    begin
        ShpfyProduct.SetRange("Item No.", SalesInvoiceLine."No.");
        if ShpfyProduct.IsEmpty() then
            exit(false);

        if ShpfyShop."UoM as Variant" then begin
            if not ProductVariantExists(SalesInvoiceLine."Unit of Measure Code", SalesInvoiceLine) then
                exit(false);
        end else begin
            ShpfyVariant.SetRange("Item No.", SalesInvoiceLine."No.");
            ShpfyVariant.SetRange("Variant Code", SalesInvoiceLine."Variant Code");
            ShpfyVariant.SetRange("Shop Code", ShpfyShop.Code);
            if ShpfyVariant.IsEmpty() then
                exit(false);
        end;

        exit(true);
    end;

    local procedure ProductVariantExists(UnitOfMeasure: Code[10]; SalesInvoiceLine: Record "Sales Invoice Line"): Boolean
    var
        ShpfyVariant: Record "Shpfy Variant";
    begin
        ShpfyVariant.SetRange("Item No.", SalesInvoiceLine."No.");
        ShpfyVariant.SetRange("Shop Code", ShpfyShop.Code);
        ShpfyVariant.SetRange("Variant Code", SalesInvoiceLine."Variant Code");
        if ShpfyVariant.FindSet() then
            repeat
                case ShpfyVariant."UoM Option Id" of
                    1:
                        if ShpfyVariant."Option 1 Value" = UnitOfMeasure then
                            exit(true);
                    2:
                        if ShpfyVariant."Option 2 Value" = UnitOfMeasure then
                            exit(true);
                    3:
                        if ShpfyVariant."Option 3 Value" = UnitOfMeasure then
                            exit(true);
                end;
            until ShpfyVariant.Next() = 0;
    end;

    local procedure MapPostedSalesInvoiceData(
        SalesInvoiceHeader: Record "Sales Invoice Header";
        var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary;
        var TempShpfyOrderLine: Record "Shpfy Order Line" temporary;
        var ShpfyOrderTaxLines: Dictionary of [Text, Decimal]
    )
    var
        InvoiceLine: Record "Sales Invoice Line";
    begin
        MapSalesInvoiceHeader(SalesInvoiceHeader, TempShpfyOrderHeader);

        InvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        if InvoiceLine.FindSet() then
            repeat
                MapSalesInvoiceLine(InvoiceLine, TempShpfyOrderHeader, TempShpfyOrderLine, ShpfyOrderTaxLines);
            until InvoiceLine.Next() = 0;
    end;

    local procedure MapSalesInvoiceHeader(
        SalesInvoiceHeader: Record "Sales Invoice Header";
        var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary
    )
    begin
        TempShpfyOrderHeader.Init();
        TempShpfyOrderHeader."Sales Invoice No." := SalesInvoiceHeader."No.";
        TempShpfyOrderHeader."Sales Order No." := SalesInvoiceHeader."Order No.";
        TempShpfyOrderHeader."Created At" := SalesInvoiceHeader.SystemCreatedAt;
        TempShpfyOrderHeader.Confirmed := true;
        TempShpfyOrderHeader."Updated At" := SalesInvoiceHeader.SystemModifiedAt;
        TempShpfyOrderHeader."Currency Code" := MapCurrencyCode(SalesInvoiceHeader);
        TempShpfyOrderHeader."Document Date" := SalesInvoiceHeader."Document Date";
        SalesInvoiceHeader.CalcFields(Amount, "Amount Including VAT", "Invoice Discount Amount");
        TempShpfyOrderHeader."VAT Amount" := SalesInvoiceHeader."Amount Including VAT" - SalesInvoiceHeader.Amount;
        TempShpfyOrderHeader."Discount Amount" := SalesInvoiceHeader."Invoice Discount Amount";
        TempShpfyOrderHeader."Fulfillment Status" := Enum::"Shpfy Order Fulfill. Status"::Fulfilled;
        TempShpfyOrderHeader."Shop Code" := ShpfyShop.Code;
        TempShpfyOrderHeader.Unpaid := IsInvoiceUnpaid(SalesInvoiceHeader);

        MapBillToInformation(TempShpfyOrderHeader, SalesInvoiceHeader);
        MapShipToInformation(TempShpfyOrderHeader, SalesInvoiceHeader);

        TempShpfyOrderHeader.Insert(false);
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
        var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary;
        SalesInvoiceHeader: Record "Sales Invoice Header"
    )
    var
        ShpfyCustomer: Record "Shpfy Customer";
    begin
        TempShpfyOrderHeader."Bill-to Name" := CopyStr(SalesInvoiceHeader."Bill-to Name", 1, MaxStrLen(TempShpfyOrderHeader."Bill-to Name"));
        TempShpfyOrderHeader."Bill-to Name 2" := SalesInvoiceHeader."Bill-to Name 2";
        TempShpfyOrderHeader."Bill-to Address" := SalesInvoiceHeader."Bill-to Address";
        TempShpfyOrderHeader."Bill-to Address 2" := SalesInvoiceHeader."Bill-to Address 2";
        TempShpfyOrderHeader."Bill-to Post Code" := SalesInvoiceHeader."Bill-to Post Code";
        TempShpfyOrderHeader."Bill-to City" := SalesInvoiceHeader."Bill-to City";
        TempShpfyOrderHeader."Bill-to County" := SalesInvoiceHeader."Bill-to County";
        TempShpfyOrderHeader."Bill-to Country/Region Code" := SalesInvoiceHeader."Bill-to Country/Region Code";
        TempShpfyOrderHeader."Bill-to Customer No." := SalesInvoiceHeader."Bill-to Customer No.";

        ShpfyCustomer.SetRange("Customer No.", SalesInvoiceHeader."Bill-to Customer No.");
        if ShpfyCustomer.FindFirst() then begin
            TempShpfyOrderHeader.Email := CopyStr(ShpfyCustomer.Email, 1, MaxStrLen(TempShpfyOrderHeader.Email));
            TempShpfyOrderHeader."Phone No." := ShpfyCustomer."Phone No.";
        end;
    end;

    local procedure MapShipToInformation(
        var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary;
        SalesInvoiceHeader: Record "Sales Invoice Header"
    )
    begin
        TempShpfyOrderHeader."Ship-to Name" := CopyStr(SalesInvoiceHeader."Ship-to Name", 1, MaxStrLen(TempShpfyOrderHeader."Ship-to Name"));
        TempShpfyOrderHeader."Ship-to Name 2" := SalesInvoiceHeader."Ship-to Name 2";
        TempShpfyOrderHeader."Ship-to Address" := SalesInvoiceHeader."Ship-to Address";
        TempShpfyOrderHeader."Ship-to Address 2" := SalesInvoiceHeader."Ship-to Address 2";
        TempShpfyOrderHeader."Ship-to Post Code" := SalesInvoiceHeader."Ship-to Post Code";
        TempShpfyOrderHeader."Ship-to City" := SalesInvoiceHeader."Ship-to City";
        TempShpfyOrderHeader."Ship-to County" := SalesInvoiceHeader."Ship-to County";
        TempShpfyOrderHeader."Ship-to Country/Region Code" := SalesInvoiceHeader."Ship-to Country/Region Code";
    end;

    local procedure IsInvoiceUnpaid(SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    begin
        SalesInvoiceHeader.CalcFields("Remaining Amount");
        exit(SalesInvoiceHeader."Remaining Amount" <> 0);
    end;

    local procedure MapSalesInvoiceLine(
    SalesInvoiceLine: Record "Sales Invoice Line";
    var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary;
    var TempShpfyOrderLine: Record "Shpfy Order Line" temporary;
    var ShpfyOrderTaxLines: Dictionary of [Text, Decimal]
): BigInteger
    var
        ShpfyVariant: Record "Shpfy Variant";
    begin
        TempShpfyOrderLine.Init();
        TempShpfyOrderLine."Line Id" := SalesInvoiceLine."Line No.";
        TempShpfyOrderLine.Description := SalesInvoiceLine.Description;
        TempShpfyOrderLine.Quantity := SalesInvoiceLine.Quantity;
        TempShpfyOrderLine."Item No." := SalesInvoiceLine."No.";
        TempShpfyOrderLine."Variant Code" := SalesInvoiceLine."Variant Code";
        TempShpfyOrderLine."Gift Card" := false;
        TempShpfyOrderLine.Taxable := false;
        TempShpfyOrderLine."Unit Price" := SalesInvoiceLine."Unit Price";
        TempShpfyOrderHeader."Discount Amount" += SalesInvoiceLine."Line Discount Amount";
        TempShpfyOrderHeader.Modify(false);

        if ShpfyShop."UoM as Variant" then
            MapUOMProductVariants(SalesInvoiceLine, TempShpfyOrderLine)
        else begin
            ShpfyVariant.SetRange("Shop Code", ShpfyShop.Code);
            ShpfyVariant.SetRange("Item No.", SalesInvoiceLine."No.");
            ShpfyVariant.SetRange("Variant Code", SalesInvoiceLine."Variant Code");
            if ShpfyVariant.FindFirst() then begin
                TempShpfyOrderLine."Shopify Product Id" := ShpfyVariant."Product Id";
                TempShpfyOrderLine."Shopify Variant Id" := ShpfyVariant.Id;
            end;
        end;

        MapTaxLine(SalesInvoiceLine, ShpfyOrderTaxLines);

        TempShpfyOrderLine.Insert(false);
    end;

    local procedure MapUOMProductVariants(SalesInvoiceLine: Record "Sales Invoice Line"; var TempShpfyOrderLine: Record "Shpfy Order Line" temporary)
    var
        ShpfyVariant: Record "Shpfy Variant";
    begin
        ShpfyVariant.SetRange("Shop Code", ShpfyShop.Code);
        ShpfyVariant.SetRange("Item No.", SalesInvoiceLine."No.");
        ShpfyVariant.SetRange("Variant Code", SalesInvoiceLine."Variant Code");
        if ShpfyVariant.FindSet() then
            repeat
                case ShpfyVariant."UoM Option Id" of
                    1:
                        if ShpfyVariant."Option 1 Value" = SalesInvoiceLine."Unit of Measure Code" then begin
                            TempShpfyOrderLine."Shopify Product Id" := ShpfyVariant."Product Id";
                            TempShpfyOrderLine."Shopify Variant Id" := ShpfyVariant.Id;
                            exit;
                        end;
                    2:
                        if ShpfyVariant."Option 2 Value" = SalesInvoiceLine."Unit of Measure Code" then begin
                            TempShpfyOrderLine."Shopify Product Id" := ShpfyVariant."Product Id";
                            TempShpfyOrderLine."Shopify Variant Id" := ShpfyVariant.Id;
                            exit;
                        end;
                    3:
                        if ShpfyVariant."Option 3 Value" = SalesInvoiceLine."Unit of Measure Code" then begin
                            TempShpfyOrderLine."Shopify Product Id" := ShpfyVariant."Product Id";
                            TempShpfyOrderLine."Shopify Variant Id" := ShpfyVariant.Id;
                            exit;
                        end;
                end;
            until ShpfyVariant.Next() = 0;
    end;

    local procedure MapTaxLine(var SalesInvoiceLine: Record "Sales Invoice Line" temporary; var ShpfyOrderTaxLines: Dictionary of [Text, Decimal])
    var
        VATAmount: Decimal;
        TaxLineTok: Label '%1 - %2%', Comment = '%1 = VAT Calculation Type, %2 = VAT %', Locked = true;
        TaxTitle: Text;
    begin
        VATAmount := SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine."VAT Base Amount";

        TaxTitle := StrSubstNo(TaxLineTok, Format(SalesInvoiceLine."VAT Calculation Type"), Format(SalesInvoiceLine."VAT %"));
        if ShpfyOrderTaxLines.ContainsKey(TaxTitle) then
            ShpfyOrderTaxLines.Set(TaxTitle, ShpfyOrderTaxLines.Get(TaxTitle) + VATAmount)
        else
            ShpfyOrderTaxLines.Add(TaxTitle, VATAmount);
    end;

    local procedure IsSuccess(JsonTokenResponse: JsonToken): Boolean
    begin
        exit(ShpfyJsonHelper.GetJsonArray(JsonTokenResponse, 'data.draftOrderComplete.userErrors').Count() = 0);
    end;

    local procedure CreateShpfyInvoiceHeader(OrderId: BigInteger)
    var
        ShpfyInvoiceHeader: Record "Shpfy Invoice Header";
    begin
        ShpfyInvoiceHeader.Init();
        ShpfyInvoiceHeader.Validate("Shopify Order Id", OrderId);
        ShpfyInvoiceHeader.Insert(true);
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

    local procedure GetNumberOfLines(var TempShpfyOrderLine: Record "Shpfy Order Line" temporary; var ShpfyOrderTaxLines: Dictionary of [Text, Decimal]): Integer
    begin
        exit(ShpfyOrderTaxLines.Count() + TempShpfyOrderLine.Count());
    end;
}