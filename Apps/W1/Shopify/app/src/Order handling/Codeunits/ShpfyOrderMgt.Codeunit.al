/// <summary>
/// Codeunit Shpfy Order Mgt. (ID 30164).
/// </summary>
codeunit 30164 "Shpfy Order Mgt."
{
    Access = Internal;

    /// <summary> 
    /// Find Tax Area.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <param name="ShopTaxArea">Parameter of type Record "Shopify Tax Area".</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure FindTaxArea(ShopifyOrderHeader: Record "Shpfy Order Header"; var ShopTaxArea: Record "Shpfy Tax Area"): Boolean
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.Get(ShopifyOrderHeader."Shop Code") then begin
            case Shop."Tax Area Priority" of
                "Shpfy Tax By"::"No Taxes":
                    exit(false);
                "Shpfy Tax By"::"Ship-to -> Sell-to -> Bill-to":
                    if ShopifyOrderHeader."Ship-to County" = '' then begin
                        if ShopifyOrderHeader."Sell-to County" = '' then begin
                            if ShopifyOrderHeader."Bill-to City" = '' then
                                exit(false)
                            else begin
                                ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Bill-to Country/Region Code");
                                ShopTaxArea.SetRange(County, ShopifyOrderHeader."Bill-to County");
                            end;
                        end else begin
                            ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Sell-to Country/Region Code");
                            ShopTaxArea.SetRange(County, ShopifyOrderHeader."Sell-to County");
                        end;
                    end else begin
                        ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Ship-to Country/Region Code");
                        ShopTaxArea.SetRange(County, ShopifyOrderHeader."Ship-to County");
                    end;
                "Shpfy Tax By"::"Ship-to -> Bill-to -> Sell-to":
                    if ShopifyOrderHeader."Ship-to County" = '' then begin
                        if ShopifyOrderHeader."Bill-to County" = '' then begin
                            if ShopifyOrderHeader."Sell-to City" = '' then
                                exit(false)
                            else begin
                                ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Sell-to Country/Region Code");
                                ShopTaxArea.SetRange(County, ShopifyOrderHeader."Sell-to County");
                            end;
                        end else begin
                            ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Bill-to Country/Region Code");
                            ShopTaxArea.SetRange(County, ShopifyOrderHeader."Bill-to County");
                        end;
                    end else begin
                        ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Ship-to Country/Region Code");
                        ShopTaxArea.SetRange(County, ShopifyOrderHeader."Ship-to County");
                    end;
                "Shpfy Tax By"::"Sell-to -> Ship-to -> Bill-to":
                    if ShopifyOrderHeader."Sell-to County" = '' then begin
                        if ShopifyOrderHeader."Ship-to County" = '' then begin
                            if ShopifyOrderHeader."Bill-to City" = '' then
                                exit(false)
                            else begin
                                ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Bill-to Country/Region Code");
                                ShopTaxArea.SetRange(County, ShopifyOrderHeader."Bill-to County");
                            end;
                        end else begin
                            ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Ship-to Country/Region Code");
                            ShopTaxArea.SetRange(County, ShopifyOrderHeader."Ship-to County");
                        end;
                    end else begin
                        ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Sell-to Country/Region Code");
                        ShopTaxArea.SetRange(County, ShopifyOrderHeader."Sell-to County");
                    end;
                "Shpfy Tax By"::"Sell-to -> Bill-to -> Ship-to":
                    if ShopifyOrderHeader."Sell-to County" = '' then begin
                        if ShopifyOrderHeader."Bill-to County" = '' then begin
                            if ShopifyOrderHeader."Ship-to City" = '' then
                                exit(false)
                            else begin
                                ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Ship-to Country/Region Code");
                                ShopTaxArea.SetRange(County, ShopifyOrderHeader."Ship-to County");
                            end;
                        end else begin
                            ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Bill-to Country/Region Code");
                            ShopTaxArea.SetRange(County, ShopifyOrderHeader."Bill-to County");
                        end;
                    end else begin
                        ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Sell-to Country/Region Code");
                        ShopTaxArea.SetRange(County, ShopifyOrderHeader."Sell-to County");
                    end;
                "Shpfy Tax By"::"Bill-to -> Sell-to -> Ship-to":
                    if ShopifyOrderHeader."Bill-to County" = '' then begin
                        if ShopifyOrderHeader."Sell-to County" = '' then begin
                            if ShopifyOrderHeader."Ship-to City" = '' then
                                exit(false)
                            else begin
                                ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Ship-to Country/Region Code");
                                ShopTaxArea.SetRange(County, ShopifyOrderHeader."Ship-to County");
                            end;
                        end else begin
                            ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Sell-to Country/Region Code");
                            ShopTaxArea.SetRange(County, ShopifyOrderHeader."Sell-to County");
                        end;
                    end else begin
                        ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Bill-to Country/Region Code");
                        ShopTaxArea.SetRange(County, ShopifyOrderHeader."Bill-to County");
                    end;
                "Shpfy Tax By"::"Bill-to Ship-to Sell-to":
                    if ShopifyOrderHeader."Bill-to County" = '' then begin
                        if ShopifyOrderHeader."Ship-to County" = '' then begin
                            if ShopifyOrderHeader."Sell-to City" = '' then
                                exit(false)
                            else begin
                                ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Sell-to Country/Region Code");
                                ShopTaxArea.SetRange(County, ShopifyOrderHeader."Sell-to County");
                            end;
                        end else begin
                            ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Sell-to Country/Region Code");
                            ShopTaxArea.SetRange(County, ShopifyOrderHeader."Sell-to County");
                        end;
                    end else begin
                        ShopTaxArea.SetRange("Country/Region Code", ShopifyOrderHeader."Bill-to Country/Region Code");
                        ShopTaxArea.SetRange(County, ShopifyOrderHeader."Bill-to County");
                    end;
            end;
            exit(ShopTaxArea.FindFirst());
        end;
    end;

    /// <summary> 
    /// Find Tax Area Code.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    /// <returns>Return value of type Text.</returns>
    internal procedure FindTaxAreaCode(ShopifyOrderHeader: Record "Shpfy Order Header"): Text
    var
        ShopTaxArea: Record "Shpfy Tax Area";
    begin
        if FindTaxArea(ShopifyOrderHeader, ShopTaxArea) then
            exit(ShopTaxArea."Tax Area Code");
    end;

    /// <summary> 
    /// Show Shopify Order.
    /// </summary>
    /// <param name="RecAsVariant">Parameter of type Variant.</param>
    internal procedure ShowShopifyOrder(var RecAsVariant: Variant)
    var
        OrderHeader: Record "Shpfy Order Header";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        FieldNumber: Integer;
        OrderNo: Text;
    begin
        if RecAsVariant.IsRecord() then
            RecordRef.GetTable(RecAsVariant)
        else
            if RecAsVariant.IsRecordRef() then
                RecordRef := RecAsVariant
            else
                exit;

        FieldNumber := FieldNo(RecordRef, 'Shopify Order No.');
        if FieldNumber <> 0 then begin
            FieldRef := RecordRef.Field(FieldNumber);
            OrderNo := FieldRef.Value();
            if OrderNo <> '' then begin
                OrderHeader.SetRange("Shopify Order No.", OrderNo);
                if OrderHeader.FindFirst() then
                    Page.Run(Page::"Shpfy Order", OrderHeader);
            end;
        end;
    end;

    /// <summary> 
    /// Field No.
    /// </summary>
    /// <param name="RecordRef">Parameter of type RecordRef.</param>
    /// <param name="FieldName">Parameter of type Text.</param>
    /// <returns>Return value of type Integer.</returns>
    local procedure FieldNo(var RecordRef: RecordRef; FieldName: Text): Integer
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, RecordRef.Number());
        Field.SetRange(FieldName, FieldName);
        if Field.FindFirst() then
            exit(Field."No.");
    end;
}