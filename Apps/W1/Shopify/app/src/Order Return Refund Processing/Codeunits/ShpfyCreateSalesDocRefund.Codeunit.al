namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Document;

codeunit 30246 "Shpfy Create Sales Doc. Refund"
{

    var
        SalesHeader: Record "Sales Header";
        Shop: Record "Shpfy Shop";
        RefundProcessEvents: Codeunit "Shpfy Refund Process Events";
        RefundId: BigInteger;
        SalesDocumentType: Enum "Sales Document Type";

    trigger OnRun()
    begin
        CreateSalesDocument();
    end;

    internal procedure SetSource(SourceDocumentId: BigInteger)
    begin
        RefundId := SourceDocumentId;
    end;

    internal procedure SetTargetDocumentType(SalesDocType: Enum "Sales Document Type")
    begin
        SalesDocumentType := SalesDocType;
    end;

    internal procedure GetSalesHeader(): Record "Sales Header";
    begin
        exit(SalesHeader);
    end;

    local procedure CreateSalesDocument()
    var
        RefundHeader: Record "Shpfy Refund Header";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
    begin
        if RefundHeader.Get(RefundId) then begin
            Shop.Get(RefundHeader."Shop Code");
            if DoCreateSalesHeader(RefundHeader, SalesDocumentType, SalesHeader) then begin
                CreateSalesLines(RefundHeader, SalesHeader);
                RefundHeader.Get(RefundHeader."Refund Id");
                ReleaseSalesDocument.Run(SalesHeader);
                RefundProcessEvents.OnAfterProcessSalesDocument(RefundHeader, SalesHeader);
            end;
        end;
    end;

    local procedure DoCreateSalesHeader(var RefundHeader: Record "Shpfy Refund Header"; SalesDocType: Enum "Sales Document Type"; var SalesHeader: Record "Sales Header"): Boolean
    var
        OrderHeader: Record "Shpfy Order Header";
        ShopifyTaxArea: Record "Shpfy Tax Area";
        DocLinkToBCDoc: Record "Shpfy Doc. Link To Doc.";
        BCDocumentTypeConvert: Codeunit "Shpfy BC Document Type Convert";
        OrderMgt: Codeunit "Shpfy Order Mgt.";
        ProcessOrder: Codeunit "Shpfy Process Order";
        IsHandled: Boolean;
    begin
        Clear(SalesHeader);

        DocLinkToBCDoc.SetRange("Shopify Document Type", "Shpfy Shop Document Type"::"Shopify Shop Refund");
        DocLinkToBCDoc.SetRange("Shopify Document Id", RefundHeader."Refund Id");
        DocLinkToBCDoc.SetCurrentKey("Shopify Document Type", "Shopify Document Id");
        if not DocLinkToBCDoc.IsEmpty then
            exit;

        if OrderHeader.Get(RefundHeader."Order Id") then begin
            RefundProcessEvents.OnBeforeCreateSalesHeader(RefundHeader, SalesHeader, IsHandled);
            if not IsHandled then begin
                SalesHeader.Init();
                SalesHeader.SetHideValidationDialog(true);
                SalesHeader.Validate("Document Type", SalesDocType);
                SalesHeader.Insert(true);

                SalesHeader.Validate("Sell-to Customer No.", OrderHeader."Sell-to Customer No.");
                SalesHeader."Sell-to Customer Name" := CopyStr(OrderHeader."Sell-to Customer Name", 1, MaxStrLen(SalesHeader."Sell-to Customer Name"));
                SalesHeader."Sell-to Customer Name 2" := CopyStr(OrderHeader."Sell-to Customer Name 2", 1, MaxStrLen(SalesHeader."Sell-to Customer Name 2"));
                SalesHeader."Sell-to Address" := CopyStr(OrderHeader."Sell-to Address", 1, MaxStrLen(SalesHeader."Sell-to Address"));
                SalesHeader."Sell-to Address 2" := CopyStr(OrderHeader."Sell-to Address 2", 1, MaxStrLen(SalesHeader."Sell-to Address 2"));
                SalesHeader."Sell-to City" := CopyStr(OrderHeader."Sell-to City", 1, MaxStrLen(SalesHeader."Sell-to City"));
                SalesHeader."Sell-to Country/Region Code" := ProcessOrder.GetCountryCode(CopyStr(OrderHeader."Sell-to Country/Region Code", 1, 10));
                SalesHeader."Sell-to Post Code" := CopyStr(OrderHeader."Sell-to Post Code", 1, MaxStrLen(SalesHeader."Sell-to Post Code"));
                SalesHeader."Sell-to County" := OrderHeader."Sell-to County";
                SalesHeader."Sell-to Phone No." := CopyStr(DelChr(OrderHeader."Phone No.", '=', DelChr(OrderHeader."Phone No.", '=', '0123456789 +()/.')), 1, MaxStrLen(SalesHeader."Sell-to Phone No."));
                SalesHeader."Sell-to E-Mail" := CopyStr(OrderHeader.Email, 1, MaxStrLen(SalesHeader."Sell-to E-Mail"));
                SalesHeader.Validate("Sell-to Contact No.", OrderHeader."Sell-to Contact No.");
                SalesHeader.Validate("Bill-to Customer No.", OrderHeader."Bill-to Customer No.");
                SalesHeader."Bill-to Name" := CopyStr(OrderHeader."Bill-to Name", 1, MaxStrLen(SalesHeader."Bill-to Name"));
                SalesHeader."Bill-to Name 2" := CopyStr(OrderHeader."Bill-to Name 2", 1, MaxStrLen(SalesHeader."Bill-to Name 2"));
                SalesHeader."Bill-to Address" := CopyStr(OrderHeader."Bill-to Address", 1, MaxStrLen(SalesHeader."Bill-to Address"));
                SalesHeader."Bill-to Address 2" := CopyStr(OrderHeader."Bill-to Address 2", 1, MaxStrLen(SalesHeader."Bill-to Address 2"));
                SalesHeader."Bill-to City" := CopyStr(OrderHeader."Bill-to City", 1, MaxStrLen(SalesHeader."Bill-to City"));
                SalesHeader."Bill-to Country/Region Code" := ProcessOrder.GetCountryCode(CopyStr(OrderHeader."Bill-to Country/Region Code", 1, 10));
                SalesHeader."Bill-to Post Code" := CopyStr(OrderHeader."Bill-to Post Code", 1, MaxStrLen(SalesHeader."Bill-to Post Code"));
                SalesHeader."Bill-to County" := CopyStr(OrderHeader."Bill-to County", 1, MaxStrLen(SalesHeader."Bill-to County"));
                SalesHeader.Validate("Bill-to Contact No.", OrderHeader."Bill-to Contact No.");
                SalesHeader.Validate("Ship-to Code", '');
                SalesHeader."Ship-to Name" := CopyStr(OrderHeader."Ship-to Name", 1, MaxStrLen(SalesHeader."Ship-to Name"));
                SalesHeader."Ship-to Name 2" := CopyStr(OrderHeader."Ship-to Name 2", 1, MaxStrLen(SalesHeader."Ship-to Name 2"));
                SalesHeader."Ship-to Address" := copyStr(OrderHeader."Ship-to Address", 1, MaxStrLen(SalesHeader."Ship-to Address"));
                SalesHeader."Ship-to Address 2" := CopyStr(OrderHeader."Ship-to Address 2", 1, MaxStrLen(SalesHeader."Ship-to Address 2"));
                SalesHeader."Ship-to City" := CopyStr(OrderHeader."Ship-to City", 1, MaxStrLen(SalesHeader."Ship-to City"));
                SalesHeader."Ship-to Country/Region Code" := ProcessOrder.GetCountryCode(CopyStr(OrderHeader."Ship-to Country/Region Code", 1, 10));
                SalesHeader."Ship-to Post Code" := CopyStr(OrderHeader."Ship-to Post Code", 1, MaxStrLen(SalesHeader."Ship-to Post Code"));
                SalesHeader."Ship-to County" := CopyStr(OrderHeader."Ship-to County", 1, MaxStrLen(SalesHeader."Ship-to County"));
                SalesHeader."Ship-to Contact" := OrderHeader."Ship-to Contact Name";
                SalesHeader.Validate("Currency Code", Shop."Currency Code");
                SalesHeader.Validate("Document Date", DT2Date(RefundHeader."Created At"));
                if OrderMgt.FindTaxArea(OrderHeader, ShopifyTaxArea) and (ShopifyTaxArea."Tax Area Code" <> '') then
                    SalesHeader.Validate("Tax Area Code", ShopifyTaxArea."Tax Area Code");
            end;
            SalesHeader."Shpfy Refund Id" := RefundHeader."Refund Id";
            SalesHeader.Modify(true);
            Clear(DocLinkToBCDoc);
            DocLinkToBCDoc."Document Type" := BCDocumentTypeConvert.Convert(SalesHeader."Document Type");
            DocLinkToBCDoc."Document No." := SalesHeader."No.";
            DocLinkToBCDoc."Shopify Document Type" := "Shpfy Shop Document Type"::"Shopify Shop Refund";
            DocLinkToBCDoc."Shopify Document Id" := RefundHeader."Refund Id";
            DocLinkToBCDoc.Insert();
            RefundProcessEvents.OnAfterCreateSalesHeader(RefundHeader, SalesHeader);
            exit(true);
        end;
    end;

    local procedure GetLastLineNo(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]): Integer
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", DocumentType);
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.LoadFields("Line No.");
        if SalesLine.FindLast() then
            exit(SalesLine."Line No.");
    end;

    local procedure CreateSalesLines(RefundHeader: Record "Shpfy Refund Header"; SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        RefundLine: Record "Shpfy Refund Line";
        ReturnLine: Record "Shpfy Return Line";
        GiftCard: Record "Shpfy Gift Card";
        ShopLocation: Record "Shpfy Shop Location";
        LineNo: Integer;
        OpenAmount: Decimal;
        IsHandled: Boolean;
    begin
        RefundLine.SetRange("Refund Id", RefundHeader."Refund Id");
        RefundLine.SetAutoCalcFields("Item No.", "Variant Code", Description, "Gift Card");
        LineNo := GetLastLineNo(SalesHeader."Document Type", SalesHeader."No.");
        if RefundLine.FindSet(false) then
            repeat
                case RefundLine."Restock Type" of
                    "Shpfy Restock Type"::"Legacy Restock",
                    "Shpfy Restock Type"::Return,
                    "Shpfy Restock Type"::"No Restock":
                        begin
                            LineNo += 10000;

                            RefundProcessEvents.OnBeforeCreateItemSalesLine(RefundHeader, RefundLine, SalesHeader, SalesLine, LineNo, IsHandled);
                            if not IsHandled then begin
                                SalesLine.Init();
                                SalesLine.SetHideValidationDialog(true);
                                SalesLine.Validate("Document Type", SalesHeader."Document Type");
                                SalesLine.Validate("Document No.", SalesHeader."No.");
                                SalesLine.Validate("Line No.", LineNo);
                                SalesLine.Insert(true);

                                if RefundLine."Gift Card" then begin
                                    SalesLine.Validate(Type, "Sales Line Type"::"G/L Account");
                                    SalesLine.Validate("No.", Shop."Sold Gift Card Account");
                                end else
                                    if RefundLine."Restock Type" = "Shpfy restock Type"::"No Restock" then begin
                                        SalesLine.Validate(Type, "Sales Line Type"::"G/L Account");
                                        SalesLine.Validate("No.", Shop."Refund Acc. non-restock Items");
                                        SalesLine.Description := RefundLine.Description;
                                    end else begin
                                        SalesLine.Validate(Type, "Sales Line Type"::Item);
                                        SalesLine.Validate("No.", RefundLine."Item No.");
                                        if RefundLine."Variant Code" <> '' then
                                            SalesLine.Validate("Variant Code", RefundLine."Variant Code");

                                        if ShopLocation.Get(Shop.Code, RefundLine."Location Id") then
                                            SalesLine.Validate("Location Code", ShopLocation."Default Location Code");

                                        If (Shop."Return Location Priority" = "Shpfy Return Location Priority"::"Default Return Location") or (SalesLine."Location Code" = '') then
                                            SalesLine.Validate("Location Code", Shop."Return Location");

                                    end;
                                SalesLine.Validate(Quantity, RefundLine.Quantity);
                                SalesLine.Validate("Unit Price", RefundLine.Amount);
                                SalesLine.Validate("Line Discount Amount", (SalesLine."Unit Price" * SalesLine.Quantity) - RefundLine."Subtotal Amount");
                            end;
                            SalesLine."Shpfy Refund Id" := RefundHeader."Refund Id";
                            SalesLine."Shpfy Refund Line Id" := RefundLine."Refund Line Id";
                            SalesLine.Modify();
                            if RefundLine."Gift Card" then begin
                                GiftCard.SetRange("Order Line Id", RefundLine."Order Line Id");
                                GiftCard.SetAutoCalcFields("Known Used Amount");
                                OpenAmount := SalesLine.GetLineAmountInclVAT();
                                if GiftCard.FindSet(true) then
                                    repeat
                                        if GiftCard.Amount - GiftCard."Known Used Amount" > 0 then
                                            if OpenAmount <= GiftCard.Amount - GiftCard."Known Used Amount" then begin
                                                GiftCard.Amount -= OpenAmount;
                                                OpenAmount := 0;
                                            end else begin
                                                OpenAmount := GiftCard.Amount - GiftCard."Known Used Amount";
                                                GiftCard.Amount := GiftCard."Known Used Amount";
                                            end;
                                        GiftCard.Modify();
                                    until (OpenAmount = 0) or (GiftCard.Next() = 0);
                            end;
                            RefundProcessEvents.OnAfterCreateItemSalesLine(RefundHeader, RefundLine, SalesHeader, SalesLine);
                        end;
                end;
            until RefundLine.Next() = 0
        else
            if RefundHeader."Return Id" > 0 then begin
                ReturnLine.SetRange("Return Id", RefundHeader."Return Id");
                ReturnLine.SetAutoCalcFields("Item No.", "Variant Code", Description);

                if ReturnLine.FindSet(false) then
                    repeat
                        LineNo += 10000;

                        RefundProcessEvents.OnBeforeCreateItemSalesLineFromReturnLine(RefundHeader, ReturnLine, SalesHeader, SalesLine, LineNo, IsHandled);
                        if not IsHandled then begin
                            SalesLine.Init();
                            SalesLine.SetHideValidationDialog(true);
                            SalesLine.Validate("Document Type", SalesHeader."Document Type");
                            SalesLine.Validate("Document No.", SalesHeader."No.");
                            SalesLine.Validate("Line No.", LineNo);
                            SalesLine.Insert(true);

                            SalesLine.Validate(Type, "Sales Line Type"::Item);
                            SalesLine.Validate("No.", ReturnLine."Item No.");
                            if ReturnLine."Variant Code" <> '' then
                                SalesLine.Validate("Variant Code", ReturnLine."Variant Code");

                            if ShopLocation.Get(Shop.Code, ReturnLine."Location Id") then
                                SalesLine.Validate("Location Code", ShopLocation."Default Location Code");

                            If (Shop."Return Location Priority" = "Shpfy Return Location Priority"::"Default Return Location") or (SalesLine."Location Code" = '') then
                                SalesLine.Validate("Location Code", Shop."Return Location");

                            SalesLine.Validate(Quantity, ReturnLine.Quantity);
                            SalesLine.Validate("Unit Price", ReturnLine."Discounted Total Amount" / ReturnLine.Quantity);
                        end;
                        SalesLine."Shpfy Refund Id" := RefundHeader."Refund Id";
                        SalesLine."Shpfy Refund Line Id" := RefundLine."Refund Line Id";
                        SalesLine.Modify();
                        RefundProcessEvents.OnAfterCreateItemSalesLineFromReturnLine(RefundHeader, ReturnLine, SalesHeader, SalesLine);
                    until ReturnLine.Next() = 0;
            end;

        SalesHeader.CalcFields(Amount, "Amount Including VAT");
        if SalesHeader."Amount Including VAT" <> RefundHeader."Total Refunded Amount" then begin
            LineNo += 10000;
            SalesLine.Init();
            SalesLine.SetHideValidationDialog(true);
            SalesLine.Validate("Document Type", SalesHeader."Document Type");
            SalesLine.Validate("Document No.", SalesHeader."No.");
            SalesLine.Validate("Line No.", LineNo);
            SalesLine.Insert(true);
            SalesLine.Validate(Type, "Sales Line Type"::"G/L Account");
            Shop.TestField("Refund Account");
            SalesLine.Validate("No.", Shop."Refund Account");
            SalesLine.Validate(Quantity, 1);
            if SalesHeader."Prices Including VAT" then
                SalesLine.Validate("Unit Price", RefundHeader."Total Refunded Amount" - SalesHeader."Amount Including VAT")
            else
                SalesLine.Validate("Unit Price", (RefundHeader."Total Refunded Amount" - SalesHeader."Amount Including VAT") / (1 + SalesLine."VAT %" / 100));
            SalesLine."Shpfy Refund Id" := RefundHeader."Refund Id";
            SalesLine.Modify();
        end;
    end;
}