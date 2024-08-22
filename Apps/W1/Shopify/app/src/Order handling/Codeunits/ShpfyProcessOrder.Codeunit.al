namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;
using Microsoft.Finance.Currency;
using Microsoft.Sales.Document;
using Microsoft.Foundation.Address;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;

/// <summary>
/// Codeunit Shpfy Process Order (ID 30166).
/// </summary>
codeunit 30166 "Shpfy Process Order"
{
    Access = Internal;
    Permissions =
        tabledata Item = rim,
        tabledata "Item Variant" = rim;

    TableNo = "Shpfy Order Header";

    var
        ShopifyShop: Record "Shpfy Shop";
        OrderEvents: Codeunit "Shpfy Order Events";
        OrderMgt: Codeunit "Shpfy Order Mgt.";
        LastCreatedDocumentId: Guid;

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        OrderHeader: Record "Shpfy Order Header";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        OrderMapping: Codeunit "Shpfy Order Mapping";
        MappingErr: Label 'Not everything can be mapped.';
    begin
        OrderHeader.Get(Rec."Shopify Order Id");
        OrderEvents.OnBeforeProcessSalesDocument(OrderHeader);
        if not OrderMapping.DoMapping(OrderHeader) then
            Error(MappingErr);

        ShopifyShop.Get(OrderHeader."Shop Code");
        CreateHeaderFromShopifyOrder(SalesHeader, OrderHeader);
        CreateLinesFromShopifyOrder(SalesHeader, OrderHeader);
        ApplyGlobalDiscounts(OrderHeader, SalesHeader);

        if ShopifyShop."Auto Release Sales Orders" then
            ReleaseSalesDocument.Run(SalesHeader);

        OrderHeader.Get(OrderHeader."Shopify Order Id");
        OrderEvents.OnAfterProcessSalesDocument(SalesHeader, OrderHeader);

        Rec.Get(OrderHeader."Shopify Order Id");
    end;

    /// <summary> 
    /// Create Header From Shopify Order.
    /// </summary>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    local procedure CreateHeaderFromShopifyOrder(var SalesHeader: Record "Sales Header"; ShopifyOrderHeader: Record "Shpfy Order Header")
    var
        ShopifyTaxArea: Record "Shpfy Tax Area";
        DocLinkToBCDoc: Record "Shpfy Doc. Link To Doc.";
        OrdersAPI: Codeunit "Shpfy Orders API";
        ProductPriceCalc: Codeunit "Shpfy Product Price Calc.";
        BCDocumentTypeConvert: Codeunit "Shpfy BC Document Type Convert";
        IsHandled: Boolean;
    begin
        OrderEvents.OnBeforeCreateSalesHeader(ShopifyOrderHeader, SalesHeader, LastCreatedDocumentId, IsHandled);
        if not IsHandled then begin
            ShopifyOrderHeader.TestField("Sell-to Customer No.");
            SalesHeader.Init();
            SalesHeader.SetHideValidationDialog(true);
            if ShopifyOrderHeader."Fulfillment Status" = ShopifyOrderHeader."Fulfillment Status"::Fulfilled then
                SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Invoice)
            else
                SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Order);
            SalesHeader.Insert(true);
            LastCreatedDocumentId := SalesHeader.SystemId;
            SalesHeader.Validate("Sell-to Customer No.", ShopifyOrderHeader."Sell-to Customer No.");
            SalesHeader."Sell-to Customer Name" := CopyStr(ShopifyOrderHeader."Sell-to Customer Name", 1, MaxStrLen(SalesHeader."Sell-to Customer Name"));
            SalesHeader."Sell-to Customer Name 2" := CopyStr(ShopifyOrderHeader."Sell-to Customer Name 2", 1, MaxStrLen(SalesHeader."Sell-to Customer Name 2"));
            SalesHeader."Sell-to Address" := CopyStr(ShopifyOrderHeader."Sell-to Address", 1, MaxStrLen(SalesHeader."Sell-to Address"));
            SalesHeader."Sell-to Address 2" := CopyStr(ShopifyOrderHeader."Sell-to Address 2", 1, MaxStrLen(SalesHeader."Sell-to Address 2"));
            SalesHeader."Sell-to City" := CopyStr(ShopifyOrderHeader."Sell-to City", 1, MaxStrLen(SalesHeader."Sell-to City"));
            SalesHeader."Sell-to Country/Region Code" := GetCountryCode(CopyStr(ShopifyOrderHeader."Sell-to Country/Region Code", 1, 10));
            SalesHeader."Sell-to Post Code" := CopyStr(ShopifyOrderHeader."Sell-to Post Code", 1, MaxStrLen(SalesHeader."Sell-to Post Code"));
            SalesHeader."Sell-to County" := ShopifyOrderHeader."Sell-to County";
            SalesHeader."Sell-to Phone No." := CopyStr(DelChr(ShopifyOrderHeader."Phone No.", '=', DelChr(ShopifyOrderHeader."Phone No.", '=', '0123456789 +()/.')), 1, MaxStrLen(SalesHeader."Sell-to Phone No."));
            SalesHeader."Sell-to E-Mail" := CopyStr(ShopifyOrderHeader.Email, 1, MaxStrLen(SalesHeader."Sell-to E-Mail"));
            SalesHeader.Validate("Sell-to Contact No.", ShopifyOrderHeader."Sell-to Contact No.");
            SalesHeader.Validate("Bill-to Customer No.", ShopifyOrderHeader."Bill-to Customer No.");
            SalesHeader."Bill-to Name" := CopyStr(ShopifyOrderHeader."Bill-to Name", 1, MaxStrLen(SalesHeader."Bill-to Name"));
            SalesHeader."Bill-to Name 2" := CopyStr(ShopifyOrderHeader."Bill-to Name 2", 1, MaxStrLen(SalesHeader."Bill-to Name 2"));
            SalesHeader."Bill-to Address" := CopyStr(ShopifyOrderHeader."Bill-to Address", 1, MaxStrLen(SalesHeader."Bill-to Address"));
            SalesHeader."Bill-to Address 2" := CopyStr(ShopifyOrderHeader."Bill-to Address 2", 1, MaxStrLen(SalesHeader."Bill-to Address 2"));
            SalesHeader."Bill-to City" := CopyStr(ShopifyOrderHeader."Bill-to City", 1, MaxStrLen(SalesHeader."Bill-to City"));
            SalesHeader."Bill-to Country/Region Code" := GetCountryCode(CopyStr(ShopifyOrderHeader."Bill-to Country/Region Code", 1, 10));
            SalesHeader."Bill-to Post Code" := CopyStr(ShopifyOrderHeader."Bill-to Post Code", 1, MaxStrLen(SalesHeader."Bill-to Post Code"));
            SalesHeader."Bill-to County" := CopyStr(ShopifyOrderHeader."Bill-to County", 1, MaxStrLen(SalesHeader."Bill-to County"));
            SalesHeader.Validate("Bill-to Contact No.", ShopifyOrderHeader."Bill-to Contact No.");
            SalesHeader.Validate("Ship-to Code", '');
            SalesHeader."Ship-to Name" := CopyStr(ShopifyOrderHeader."Ship-to Name", 1, MaxStrLen(SalesHeader."Ship-to Name"));
            SalesHeader."Ship-to Name 2" := CopyStr(ShopifyOrderHeader."Ship-to Name 2", 1, MaxStrLen(SalesHeader."Ship-to Name 2"));
            SalesHeader."Ship-to Address" := copyStr(ShopifyOrderHeader."Ship-to Address", 1, MaxStrLen(SalesHeader."Ship-to Address"));
            SalesHeader."Ship-to Address 2" := CopyStr(ShopifyOrderHeader."Ship-to Address 2", 1, MaxStrLen(SalesHeader."Ship-to Address 2"));
            SalesHeader."Ship-to City" := CopyStr(ShopifyOrderHeader."Ship-to City", 1, MaxStrLen(SalesHeader."Ship-to City"));
            SalesHeader."Ship-to Country/Region Code" := GetCountryCode(CopyStr(ShopifyOrderHeader."Ship-to Country/Region Code", 1, 10));
            SalesHeader."Ship-to Post Code" := CopyStr(ShopifyOrderHeader."Ship-to Post Code", 1, MaxStrLen(SalesHeader."Ship-to Post Code"));
            SalesHeader."Ship-to County" := CopyStr(ShopifyOrderHeader."Ship-to County", 1, MaxStrLen(SalesHeader."Ship-to County"));
            SalesHeader."Ship-to Contact" := ShopifyOrderHeader."Ship-to Contact Name";
            SalesHeader.Validate("Prices Including VAT", ShopifyOrderHeader."VAT Included" and ProductPriceCalc.DoPricesIncludingVAT(ShopifyOrderHeader."Shop Code"));
            SalesHeader.Validate("Currency Code", ShopifyShop."Currency Code");
            SalesHeader."Shpfy Order Id" := ShopifyOrderHeader."Shopify Order Id";
            SalesHeader."Shpfy Order No." := ShopifyOrderHeader."Shopify Order No.";
            SalesHeader.Validate("Document Date", ShopifyOrderHeader."Document Date");
            SalesHeader.Validate("External Document No.", ShopifyOrderHeader."PO Number");
            if OrderMgt.FindTaxArea(ShopifyOrderHeader, ShopifyTaxArea) and (ShopifyTaxArea."Tax Area Code" <> '') then
                SalesHeader.Validate("Tax Area Code", ShopifyTaxArea."Tax Area Code");
            if ShopifyOrderHeader."Shipping Method Code" <> '' then
                SalesHeader.Validate("Shipment Method Code", ShopifyOrderHeader."Shipping Method Code");
            if ShopifyOrderHeader."Shipping Agent Code" <> '' then begin
                SalesHeader.Validate("Shipping Agent Code", ShopifyOrderHeader."Shipping Agent Code");
                SalesHeader.Validate("Shipping Agent Service Code", ShopifyOrderHeader."Shipping Agent Service Code");
            end;
            if ShopifyOrderHeader."Payment Method Code" <> '' then
                SalesHeader.Validate("Payment Method Code", ShopifyOrderHeader."Payment Method Code");
            if ShopifyOrderHeader."Payment Terms Type" <> '' then
                UpdatePaymentTerms(SalesHeader, ShopifyOrderHeader."Payment Terms Type", ShopifyOrderHeader."Payment Terms Name");

            SalesHeader.Modify(true);

            if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
                ShopifyOrderHeader."Sales Order No." := SalesHeader."No."
            else
                ShopifyOrderHeader."Sales Invoice No." := SalesHeader."No.";

            ShopifyOrderHeader.Modify();
            ShopifyOrderHeader.CalcFields("Work Description");
            if ShopifyOrderHeader."Work Description".HasValue then
                SalesHeader.SetWorkDescription(ShopifyOrderHeader.GetWorkDescription());
        end;
        OrdersAPI.AddOrderAttribute(ShopifyOrderHeader, 'BC Doc. No.', SalesHeader."No.", ShopifyShop);
        DocLinkToBCDoc.Init();
        DocLinkToBCDoc."Shopify Document Type" := "Shpfy Shop Document Type"::"Shopify Shop Order";
        DocLinkToBCDoc."Shopify Document Id" := ShopifyOrderHeader."Shopify Order Id";
        DocLinkToBCDoc."Document Type" := BCDocumentTypeConvert.Convert(SalesHeader);
        DocLinkToBCDoc."Document No." := SalesHeader."No.";
        DocLinkToBCDoc.Insert();
        OrderEvents.OnAfterCreateSalesHeader(ShopifyOrderHeader, SalesHeader);
    end;

    local procedure UpdatePaymentTerms(var SalesHeader: Record "Sales Header"; PaymentTermsType: Code[20]; PaymentTermsName: Text[50])
    var
        ShpfyPaymentTerms: Record "Shpfy Payment Terms";
    begin
        ShpfyPaymentTerms.SetRange(Type, PaymentTermsType);
        ShpfyPaymentTerms.SetRange("Shop Code", ShopifyShop.Code);
        ShpfyPaymentTerms.SetRange(Name, PaymentTermsName);
        if ShpfyPaymentTerms.FindFirst() then
            SalesHeader.Validate("Payment Terms Code", ShpfyPaymentTerms."Payment Terms Code");
    end;

    local procedure ApplyGlobalDiscounts(OrderHeader: Record "Shpfy Order Header"; var SalesHeader: Record "Sales Header")
    var
        OrderLine: Record "Shpfy Order Line";
        OrderShippingCharges: Record "Shpfy Order Shipping Charges";
        SalesCalcDiscountByType: Codeunit "Sales - Calc Discount By Type";
        Discount: Decimal;
    begin
        OrderLine.SetRange("Shopify Order Id", OrderHeader."Shopify Order Id");
        OrderLine.CalcSums("Discount Amount");
        OrderShippingCharges.SetRange("Shopify Order Id", OrderHeader."Shopify Order Id");
        OrderShippingCharges.CalcSums("Discount Amount");
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        Discount := OrderHeader."Discount Amount" - OrderLine."Discount Amount" - OrderShippingCharges."Discount Amount";
        if Discount > 0 then
            SalesCalcDiscountByType.ApplyInvDiscBasedOnAmt(Discount, SalesHeader);
    end;


    /// <summary> 
    /// Create Lines From Shopify Order.
    /// </summary>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    local procedure CreateLinesFromShopifyOrder(var SalesHeader: Record "Sales Header"; ShopifyOrderHeader: Record "Shpfy Order Header")
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        ShopifyOrderLine: Record "Shpfy Order Line";
        OrderShippingCharges: Record "Shpfy Order Shipping Charges";
        ShopLocation: Record "Shpfy Shop Location";
        ShipmentMethodMapping: Record "Shpfy Shipment Method Mapping";
        SuppressAsmWarning: Codeunit "Shpfy Suppress Asm Warning";
        IsHandled: Boolean;
        ShipmentChargeType: Boolean;
        ShopfyOrderNoLbl: Label 'Shopify Order No.: %1', Comment = '%1 = Order No.';
    begin
        BindSubscription(SuppressAsmWarning);
        if ShopifyShop."Shopify Order No. on Doc. Line" then begin
            SalesLine.Init();
            SalesLine.SetHideValidationDialog(true);
            SalesLine.Validate("Document Type", SalesHeader."Document Type");
            SalesLine.Validate("Document No.", SalesHeader."No.");
            SalesLine.Validate("Line No.", GetNextLineNo(SalesHeader));
            SalesLine.Validate(Type, SalesLine.Type::" ");
            SalesLine.Validate(Description, StrSubstNo(ShopfyOrderNoLbl, ShopifyOrderHeader."Shopify Order No."));
            SalesLine.Insert(true);
        end;
        ShopifyOrderLine.SetRange("Shopify Order Id", ShopifyOrderHeader."Shopify Order Id");
        if ShopifyOrderLine.FindSet() then
            repeat
                OrderEvents.OnBeforeCreateItemSalesLine(ShopifyOrderHeader, ShopifyOrderLine, SalesHeader, SalesLine, IsHandled);
                if not IsHandled then begin
                    SalesLine.Init();
                    SalesLine.SetHideValidationDialog(true);
                    SalesLine.Validate("Document Type", SalesHeader."Document Type");
                    SalesLine.Validate("Document No.", SalesHeader."No.");
                    SalesLine.Validate("Line No.", GetNextLineNo(SalesHeader));
                    SalesLine.Insert(true);

                    if ShopifyOrderLine.Tip then begin
                        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
                        SalesLine.Validate("No.", ShopifyShop."Tip Account");
                    end else
                        if ShopifyOrderLine."Gift Card" then begin
                            SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
                            SalesLine.Validate("No.", ShopifyShop."Sold Gift Card Account");
                        end else begin
                            SalesLine.Validate(Type, SalesLine.Type::Item);
                            SalesLine.Validate("No.", ShopifyOrderLine."Item No.");
                            if Item.Get(SalesLine."No.") then
                                if (ShopifyOrderLine."Location Id" <> 0) then
                                    if ShopLocation.Get(ShopifyOrderHeader."Shop Code", ShopifyOrderLine."Location Id") and (ShopLocation."Default Location Code" <> '') then
                                        SalesLine.Validate("Location Code", ShopLocation."Default Location Code");
                        end;
                    SalesLine.Validate("Unit of Measure Code", ShopifyOrderLine."Unit of Measure Code");
                    SalesLine.Validate("Variant Code", ShopifyOrderLine."Variant Code");
                    SalesLine.Validate(Quantity, ShopifyOrderLine.Quantity);
                    SalesLine.Validate("Unit Price", ShopifyOrderLine."Unit Price");
                    SalesLine.Validate("Line Discount Amount", ShopifyOrderLine."Discount Amount");
                    SalesLine."Shpfy Order Line Id" := ShopifyOrderLine."Line Id";
                    SalesLine."Shpfy Order No." := ShopifyOrderHeader."Shopify Order No.";
                    SalesLine.Modify(true);
                end;
                OrderEvents.OnAfterCreateItemSalesLine(ShopifyOrderHeader, ShopifyOrderLine, SalesHeader, SalesLine);
            until ShopifyOrderLine.Next() = 0;

        OrderShippingCharges.Reset();
        OrderShippingCharges.SetRange("Shopify Order Id", ShopifyOrderHeader."Shopify Order Id");
        OrderShippingCharges.SetFilter(Amount, '>0');
        if OrderShippingCharges.FindSet() then
            repeat
                IsHandled := false;
                OrderEvents.OnBeforeCreateShippingCostSalesLine(ShopifyOrderHeader, OrderShippingCharges, SalesHeader, SalesLine, IsHandled);
                if not IsHandled then begin

                    if ShipmentMethodMapping.Get(ShopifyShop.Code, OrderShippingCharges.Title) then
                        if ShipmentMethodMapping."Shipping Charges Type" <> ShipmentMethodMapping."Shipping Charges Type"::" " then begin
                            ShipmentMethodMapping.TestField("Shipping Charges No.");
                            ShipmentChargeType := true;
                        end;

                    if not ShipmentChargeType then
                        ShopifyShop.TestField("Shipping Charges Account");

                    SalesLine.Init();
                    SalesLine.SetHideValidationDialog(true);
                    SalesLine.Validate("Document Type", SalesHeader."Document Type");
                    SalesLine.Validate("Document No.", SalesHeader."No.");
                    SalesLine.Validate("Line No.", GetNextLineNo(SalesHeader));
                    SalesLine.Insert(true);

                    if ShipmentChargeType then begin
                        SalesLine.Validate(Type, ShipmentMethodMapping."Shipping Charges Type");
                        SalesLine.Validate("No.", ShipmentMethodMapping."Shipping Charges No.");
                    end else begin
                        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
                        SalesLine.Validate("No.", ShopifyShop."Shipping Charges Account");
                    end;

                    SalesLine.Validate("Shipping Agent Code", ShipmentMethodMapping."Shipping Agent Code");
                    SalesLine.Validate("Shipping Agent Service Code", ShipmentMethodMapping."Shipping Agent Service Code");
                    SalesLine.Validate(Quantity, 1);
                    SalesLine.Validate(Description, OrderShippingCharges.Title);
                    SalesLine.Validate("Unit Price", OrderShippingCharges.Amount);
                    SalesLine.Validate("Line Discount Amount", OrderShippingCharges."Discount Amount");
                    SalesLine."Shpfy Order No." := ShopifyOrderHeader."Shopify Order No.";
                    SalesLine.Modify(true);

                    if SalesLine.Type = SalesLine.Type::"Charge (Item)" then
                        AssignItemCharges(SalesHeader, SalesLine);
                end;
                OrderEvents.OnAfterCreateShippingCostSalesLine(ShopifyOrderHeader, OrderShippingCharges, SalesHeader, SalesLine);
            until OrderShippingCharges.Next() = 0;
    end;

    local procedure AssignItemCharges(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    var
        AssignItemChargeSales: Codeunit "Item Charge Assgnt. (Sales)";
        ItemChargeAssgntLineAmt: Decimal;
        AssignableQty: Decimal;
    begin
        SalesLine.TestField("No.");
        SalesLine.TestField(Quantity);

        PrepareAssignItemChargesLines(SalesHeader, SalesLine, AssignableQty, ItemChargeAssgntLineAmt);
        AssignItemChargeSales.AssignItemCharges(SalesLine, AssignableQty, ItemChargeAssgntLineAmt, AssignableQty, ItemChargeAssgntLineAmt, AssignItemChargeSales.AssignEquallyMenuText());
    end;

    local procedure PrepareAssignItemChargesLines(
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        var AssignableQty: Decimal;
        var ItemChargeAssgntLineAmt: Decimal
    )
    var
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
    begin
        GetItemChargeAssgntLineAmt(SalesHeader, SalesLine, ItemChargeAssgntSales, ItemChargeAssgntLineAmt);
        GetAssignableQty(SalesLine, ItemChargeAssgntSales, AssignableQty);
    end;

    local procedure GetItemChargeAssgntLineAmt(
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        var ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
        var ItemChargeAssgntLineAmt: Decimal
    )
    var
        Currency: Record Currency;
    begin
        SalesHeader := SalesLine.GetSalesHeader();
        Currency.Initialize(SalesHeader."Currency Code");
        if (SalesLine."Inv. Discount Amount" = 0) and (SalesLine."Line Discount Amount" = 0) and
            (not SalesHeader."Prices Including VAT")
        then
            ItemChargeAssgntLineAmt := SalesLine."Line Amount"
        else
            if SalesHeader."Prices Including VAT" then
                ItemChargeAssgntLineAmt :=
                    Round(SalesLine.CalcLineAmount() / (1 + SalesLine."VAT %" / 100), Currency."Amount Rounding Precision")
            else
                ItemChargeAssgntLineAmt := SalesLine.CalcLineAmount();

        ItemChargeAssgntSales.Reset();
        ItemChargeAssgntSales.SetRange("Document Type", SalesLine."Document Type");
        ItemChargeAssgntSales.SetRange("Document No.", SalesLine."Document No.");
        ItemChargeAssgntSales.SetRange("Document Line No.", SalesLine."Line No.");
        ItemChargeAssgntSales.SetRange("Item Charge No.", SalesLine."No.");
        if not ItemChargeAssgntSales.FindLast() then begin
            ItemChargeAssgntSales."Document Type" := SalesLine."Document Type";
            ItemChargeAssgntSales."Document No." := SalesLine."Document No.";
            ItemChargeAssgntSales."Document Line No." := SalesLine."Line No.";
            ItemChargeAssgntSales."Item Charge No." := SalesLine."No.";
            ItemChargeAssgntSales."Unit Cost" :=
                Round(ItemChargeAssgntLineAmt / SalesLine.Quantity, Currency."Unit-Amount Rounding Precision");
        end;

        ItemChargeAssgntLineAmt :=
          Round(ItemChargeAssgntLineAmt * (SalesLine."Qty. to Invoice" / SalesLine.Quantity), Currency."Amount Rounding Precision");
    end;

    local procedure GetAssignableQty(
        SalesLine: Record "Sales Line";
        ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)";
        var AssignableQty: Decimal
    )
    var
        AssignItemChargeSales: Codeunit "Item Charge Assgnt. (Sales)";
    begin
        if SalesLine.IsCreditDocType() then
            AssignItemChargeSales.CreateDocChargeAssgn(ItemChargeAssgntSales, SalesLine."Return Receipt No.")
        else
            AssignItemChargeSales.CreateDocChargeAssgn(ItemChargeAssgntSales, SalesLine."Shipment No.");

        SalesLine.CalcFields("Qty. to Assign", "Item Charge Qty. to Handle", "Qty. Assigned");
        AssignableQty := SalesLine."Qty. to Invoice" + SalesLine."Quantity Invoiced" - SalesLine."Qty. Assigned";
    end;

    /// <summary> 
    /// Get Country Code.
    /// </summary>
    /// <param name="ISOCode">Parameter of type Code[10].</param>
    /// <returns>Return value of type Code[10].</returns>
    internal procedure GetCountryCode(ISOCode: Code[10]): Code[10]
    var
        CountryRegion: Record "Country/Region";
    begin
        if ISOCode = '' then
            exit(ISOCode);

        if CountryRegion.Get(ISOCode) then
            exit(ISOCode)
        else begin
            Clear(CountryRegion);
            CountryRegion.SetRange("ISO Code", ISOCode);
            if CountryRegion.FindFirst() then
                exit(CountryRegion.Code);
        end;
    end;

    /// <summary> 
    /// Get Next Line No.
    /// </summary>
    /// <param name="SalesHeader">Parameter of type Record "Sales Header".</param>
    /// <returns>Return value of type Integer.</returns>
    local procedure GetNextLineNo(SalesHeader: Record "Sales Header"): Integer
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.IsEmpty() then
            exit(10000)
        else
            if SalesLine.FindLast() then
                exit(10000 + SalesLine."Line No.");
    end;

    /// <summary> 
    /// Description for CleanUpLastCreatedDocument.
    /// </summary>
    internal procedure CleanUpLastCreatedDocument()
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.GetBySystemId(LastCreatedDocumentId) then
            SalesHeader.Delete(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnInsertShipmentHeaderOnAfterTransferfieldsToSalesShptHeader', '', false, false)]
    local procedure TransferShopifyOrderNoToShipmentHeader(SalesHeader: Record "Sales Header"; var SalesShptHeader: Record "Sales Shipment Header")
    begin
        SalesShptHeader."Shpfy Order No." := SalesHeader."Shpfy Order No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeSalesLineInsert', '', false, false)]
    local procedure TransferShopifyValuesOnBeforeSalesLineInsert(var SalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line" temporary; SalesHeader: Record "Sales Header")
    begin
        SalesLine."Shpfy Order No." := TempSalesLine."Shpfy Order No.";
        SalesLine."Shpfy Order Line Id" := TempSalesLine."Shpfy Order Line Id";
        SalesLine."Shpfy Refund Id" := TempSalesLine."Shpfy Refund Id";
        SalesLine."Shpfy Refund Line Id" := TempSalesLine."Shpfy Refund Line Id";
    end;
}



