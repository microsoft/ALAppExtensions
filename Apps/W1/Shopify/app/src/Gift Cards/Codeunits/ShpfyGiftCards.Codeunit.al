namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Gift Cards (ID 30125).
/// </summary>
codeunit 30125 "Shpfy Gift Cards"
{
    Access = Internal;

    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

    internal procedure GetGiftCardsFromFulfillment(OrderId: BigInteger; FulfillmentId: BigInteger)
    var
        Response: Text;
        UrlLbl: Label 'orders/%1/fulfillments/%2.json?fields=id,receipt', Locked = true;
        JToken: JsonToken;
    begin
        Response := CommunicationMgt.ExecuteWebRequest(CommunicationMgt.CreateWebRequestURL(StrSubstNo(UrlLbl, OrderId, FulfillmentId)), 'GET', '');
        if JToken.ReadFrom(Response) then
            AddSoldGiftCards(JsonHelper.GetJsonArray(JToken, 'fulfillment.receipt.gift_cards'));
    end;

    /// <summary> 
    /// Add Sold Gift Cards.
    /// </summary>
    /// <param name="JGiftCards">Parameter of type JsonArray.</param>
    internal procedure AddSoldGiftCards(JGiftCards: JsonArray)
    var
        GiftCard: Record "Shpfy Gift Card";
        OrderLine: Record "Shpfy Order Line";
        Id: BigInteger;
        JToken: JsonToken;
        IsNew: Boolean;
        Mask: Text;
    begin
        foreach JToken in JGiftCards do begin
            Id := JsonHelper.GetValueAsBigInteger(JToken, 'id');
            IsNew := not GiftCard.Get(Id);
            if IsNew then begin
                Clear(GiftCard);
                GiftCard.Id := Id;
            end;
            Id := JsonHelper.GetValueAsBigInteger(JToken, 'line_item_id');
            GiftCard."Order Line Id" := Id;
            if (Id > 0) then begin
                OrderLine.SetRange("Line Id", Id);
                if OrderLine.FindFirst() then
                    GiftCard.Amount := OrderLine."Unit Price";
            end;
            Mask := JsonHelper.GetValueAsText(JToken, 'masked_code');
            GiftCard."Last Characters" := CopyStr(CopyStr(Mask, StrLen(Mask) - (MaxStrLen(GiftCard."Last Characters") - 1)), 1, MaxStrLen(GiftCard."Last Characters"));
            if IsNew then
                GiftCard.Insert()
            else
                GiftCard.Modify();
        end;
    end;
}