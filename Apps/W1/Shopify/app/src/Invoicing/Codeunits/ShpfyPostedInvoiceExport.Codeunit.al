namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;
using Microsoft.Utilities;
using Microsoft.Sales.Receivables;

/// <summary>
/// Codeunit Shpfy Export Invoice (ID 30105).
/// </summary>
codeunit 30105 "Shpfy Posted Invoice Export"
{
    Access = Internal;
    TableNo = "Sales Invoice Header";

    var
        ShpfyShop: Record "Shpfy Shop";
        ShpfyDraftOrdersAPI: Codeunit "Shpfy Draft Orders API";
        ShpfyJsonHelper: Codeunit "Shpfy Json Helper";

    trigger OnRun()
    begin
        ExportPostedSalesInvoiceToShopify(Rec);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="NewShopCode">Parameter of type Code[20].</param>
    internal procedure SetShop(NewShopCode: Code[20])
    begin
        ShpfyShop.Get(NewShopCode);
    end;

    local procedure ExportPostedSalesInvoiceToShopify(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        TempShpfyOrderHeader: Record "Shpfy Order Header" temporary;
        TempShpfyOrderLine: Record "Shpfy Order Line" temporary;
        ShpfyOrderTaxLines: Dictionary of [Text, Decimal];
        JsonTokenResponse: JsonToken;
    begin
        if not IsInvoiceExportable(SalesInvoiceHeader) then begin
            SetSalesInvoiceShopifyOrderInformation(SalesInvoiceHeader, -2, '');
            exit;
        end;

        MapPostedSalesInvoiceData(SalesInvoiceHeader, TempShpfyOrderHeader, TempShpfyOrderLine, ShpfyOrderTaxLines);

        ShpfyDraftOrdersAPI.SetShop(ShpfyShop.Code);
        JsonTokenResponse := ShpfyDraftOrdersAPI.ExportOrderToShopify(TempShpfyOrderHeader, TempShpfyOrderLine, ShpfyOrderTaxLines);

        if IsSuccess(JsonTokenResponse) then begin
            CreateShpfyInvoiceHeader(JsonTokenResponse, SalesInvoiceHeader."No.");
            SetSalesInvoiceShopifyOrderInformation(
                SalesInvoiceHeader,
                ShpfyDraftOrdersAPI.ParseShopifyResponse(JsonTokenResponse, 'data.draftOrderComplete.draftOrder.order.id'),
                Format(ShpfyJsonHelper.GetValueAsText(JsonTokenResponse, 'data.draftOrderComplete.draftOrder.order.name'))
            );
            AddDocumentLinkToBCDocument(SalesInvoiceHeader);
        end else
            SetSalesInvoiceShopifyOrderInformation(SalesInvoiceHeader, -1, '');
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

        if ShpfyShop."Default Customer No." = SalesInvoiceHeader."Bill-to Customer No." then
            exit(false);

        if not CheckSalesInvoiceHeaderLines(SalesInvoiceHeader) then
            exit(false);

        //TODO: Fractions check?

        exit(true);
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
        if SalesInvoiceLine.FindSet() then
            repeat
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
    var
        DocumentTotals: Codeunit "Document Totals";
    begin
        TempShpfyOrderHeader.Init();
        TempShpfyOrderHeader."Sales Invoice No." := SalesInvoiceHeader."No.";
        TempShpfyOrderHeader."Sales Order No." := SalesInvoiceHeader."Order No.";
        TempShpfyOrderHeader."Created At" := SalesInvoiceHeader.SystemCreatedAt;
        TempShpfyOrderHeader.Confirmed := true;
        TempShpfyOrderHeader."Updated At" := SalesInvoiceHeader.SystemModifiedAt;
        TempShpfyOrderHeader."Currency Code" := SalesInvoiceHeader."Currency Code";
        TempShpfyOrderHeader."Document Date" := SalesInvoiceHeader."Document Date";
        SalesInvoiceHeader.CalcFields(Amount, "Amount Including VAT", "Invoice Discount Amount");
        TempShpfyOrderHeader."VAT Amount" := SalesInvoiceHeader."Amount Including VAT" - SalesInvoiceHeader.Amount;

        MapBillInformation(TempShpfyOrderHeader, SalesInvoiceHeader);
        MapShipToInformation(TempShpfyOrderHeader, SalesInvoiceHeader);
        MapCustomerLedgerEntryInformation(SalesInvoiceHeader, TempShpfyOrderHeader);

        TempShpfyOrderHeader."Fulfillment Status" := Enum::"Shpfy Order Fulfill. Status"::Fulfilled;
        SalesInvoiceHeader.CalcFields("Invoice Discount Amount");
        TempShpfyOrderHeader."Discount Amount" := SalesInvoiceHeader."Invoice Discount Amount";
        TempShpfyOrderHeader."Shop Code" := ShpfyShop.Code;
        TempShpfyOrderHeader.Insert();
    end;

    local procedure MapBillInformation(
        var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary;
        SalesInvoiceHeader: Record "Sales Invoice Header"
    )
    var
        ShpfyCustomer: Record "Shpfy Customer";
    begin
        TempShpfyOrderHeader."Bill-to Name" := SalesInvoiceHeader."Bill-to Name";
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
            TempShpfyOrderHeader.Email := ShpfyCustomer.Email;
            TempShpfyOrderHeader."Phone No." := ShpfyCustomer."Phone No.";
        end;
    end;

    local procedure MapShipToInformation(
        var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary;
        SalesInvoiceHeader: Record "Sales Invoice Header"
    )
    begin
        TempShpfyOrderHeader."Ship-to Name" := SalesInvoiceHeader."Ship-to Name";
        TempShpfyOrderHeader."Ship-to Name 2" := SalesInvoiceHeader."Ship-to Name 2";
        TempShpfyOrderHeader."Ship-to Address" := SalesInvoiceHeader."Ship-to Address";
        TempShpfyOrderHeader."Ship-to Address 2" := SalesInvoiceHeader."Ship-to Address 2";
        TempShpfyOrderHeader."Ship-to Post Code" := SalesInvoiceHeader."Ship-to Post Code";
        TempShpfyOrderHeader."Ship-to City" := SalesInvoiceHeader."Ship-to City";
        TempShpfyOrderHeader."Ship-to County" := SalesInvoiceHeader."Ship-to County";
        TempShpfyOrderHeader."Ship-to Country/Region Code" := SalesInvoiceHeader."Ship-to Country/Region Code";
    end;

    local procedure MapCustomerLedgerEntryInformation(
        SalesInvoiceHeader: Record "Sales Invoice Header";
        var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.Get(SalesInvoiceHeader."Cust. Ledger Entry No.");
        CustLedgerEntry.CalcFields("Remaining Amount");

        if CustLedgerEntry."Remaining Amount" = 0 then
            TempShpfyOrderHeader.Unpaid := false
        else
            TempShpfyOrderHeader.Unpaid := true;
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
        TempShpfyOrderLine."Gift Card" := false;
        TempShpfyOrderLine.Taxable := false;
        TempShpfyOrderLine."Unit Price" := SalesInvoiceLine."Unit Price";
        TempShpfyOrderHeader."Discount Amount" += SalesInvoiceLine."Line Discount Amount";
        TempShpfyOrderHeader.Modify();

        if ShpfyShop."UoM as Variant" then
            MapUOMProductVariants(SalesInvoiceLine, TempShpfyOrderLine)
        else begin
            ShpfyVariant.SetRange("Item No.", SalesInvoiceLine."No.");
            ShpfyVariant.SetRange("Variant Code", SalesInvoiceLine."Variant Code");
            if ShpfyVariant.FindFirst() then begin
                TempShpfyOrderLine."Shopify Product Id" := ShpfyVariant."Product Id";
                TempShpfyOrderLine."Shopify Variant Id" := ShpfyVariant.Id;
            end;
        end;

        MapTaxLine(SalesInvoiceLine, ShpfyOrderTaxLines);

        TempShpfyOrderLine.Insert();
    end;

    local procedure MapUOMProductVariants(SalesInvoiceLine: Record "Sales Invoice Line"; var TempShpfyOrderLine: Record "Shpfy Order Line" temporary)
    var
        ShpfyVariant: Record "Shpfy Variant";
    begin
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

    local procedure MapTaxLine(
        var SalesInvoiceLine: Record "Sales Invoice Line" temporary;
        var ShpfyOrderTaxLines: Dictionary of [Text, Decimal]
    )
    var
        TaxTitle: Text;
    begin
        TaxTitle := Format(SalesInvoiceLine."VAT Calculation Type"); //TODO: Comment that if language is different, then this will also be translated since this is a caption value
        if ShpfyOrderTaxLines.ContainsKey(TaxTitle) then
            ShpfyOrderTaxLines.Set(TaxTitle, ShpfyOrderTaxLines.Get(TaxTitle) + SalesInvoiceLine.GetLineAmountInclVAT() - SalesInvoiceLine.GetLineAmountExclVAT())
        else
            ShpfyOrderTaxLines.Add(TaxTitle, SalesInvoiceLine.GetLineAmountInclVAT() - SalesInvoiceLine.GetLineAmountExclVAT());
    end;

    local procedure IsSuccess(JsonTokenResponse: JsonToken): Boolean
    begin
        exit(ShpfyJsonHelper.GetJsonArray(JsonTokenResponse, 'data.draftOrderComplete.userErrors').Count() = 0);
    end;

    local procedure CreateShpfyInvoiceHeader(JsonTokenResponse: JsonToken; InvoiceNo: Code[20])
    var
        ShpfyInvoiceHeader: Record "Shpfy Invoice Header";
    begin
        ShpfyInvoiceHeader.Init();
        ShpfyInvoiceHeader.Validate("Shopify Order Id", ShpfyDraftOrdersAPI.ParseShopifyResponse(JsonTokenResponse, 'data.draftOrderComplete.draftOrder.order.id'));
        ShpfyInvoiceHeader.Validate("Shopify Order No.", Format(ShpfyJsonHelper.GetValueAsText(JsonTokenResponse, 'data.draftOrderComplete.draftOrder.order.name')));
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
        DocLinkToBCDoc.Insert();
    end;
}