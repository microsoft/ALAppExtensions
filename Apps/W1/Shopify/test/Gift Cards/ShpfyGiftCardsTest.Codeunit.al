codeunit 139570 "Shpfy Gift Cards Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        Any: Codeunit Any;

    [Test]
    procedure UnitTestAddSoldGiftCards()
    var
        ShpfyGiftCard: Record "Shpfy Gift Card";
        ShpfyOrderLine: Record "Shpfy Order Line";
        ShpfyGiftCards: Codeunit "Shpfy Gift Cards";
        GiftCardId: BigInteger;
        LineItemId: BigInteger;
        Amount: Decimal;
        JArray: JsonArray;
        GiftCardsJsonTxt: Label '[{"id": %1, "line_item_id": %2, "masked_code": "•••• •••• •••• %3"}]', Comment = '%1 = GiftCardId, %2 = LineItemId, %3 = LastChars', Locked = true;
        LastChars: Text[4];
    begin
        // Creating Test data. The database must have a Config Template for creating a customer.
        GiftCardId := Any.IntegerInRange(100000, 999999);
        LineItemId := Any.IntegerInRange(100000, 999999);
        LastChars := Format(Any.IntegerInRange(1000, 9999));
        Amount := Any.IntegerInRange(100000, 999999) / 100.0;
        JArray.ReadFrom(StrSubstNo(GiftCardsJsonTxt, GiftCardId, LineItemId, LastChars));
        ShpfyOrderLine.Init();
        ShpfyOrderLine."Shopify Order Id" := Any.IntegerInRange(100000, 999999);
        ShpfyOrderLine."Line Id" := LineItemId;
        ShpfyOrderLine."Unit Price" := Amount;
        ShpfyOrderLine.Insert();

        // [SCENARIO] The function receive a JsonAray with Gift Card information. This will be parsed in the Gift Card record.
        //            For getting the amount of the give card, a Shopify order line must exist with the same line_item_id.

        // [GIVEN] Jarray = GiftCard json structure.
        // [WHEN] Invoke the function AddSoldGiftCards(JArray).
        ShpfyGiftCards.AddSoldGiftCards(JArray);

        // [THEN] We must find the GiveCard record.
        LibraryAssert.IsTrue(ShpfyGiftCard.Get(GiftCardId), 'Getting GiftCard record');

        // [THEN] GiftCard.LastCharacters = LastChars and GiftCard.Amount = Amount
        LibraryAssert.AreEqual(LastChars, ShpfyGiftCard."Last Characters", 'GiftCard.LastCharacters');
        LibraryAssert.AreEqual(Amount, ShpfyGiftCard.Amount, 'GiftCard.Amount');
    end;
}