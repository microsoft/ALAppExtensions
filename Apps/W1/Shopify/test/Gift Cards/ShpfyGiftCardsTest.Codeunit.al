// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;

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
        GiftCard: Record "Shpfy Gift Card";
        OrderLine: Record "Shpfy Order Line";
        GiftCards: Codeunit "Shpfy Gift Cards";
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
        OrderLine.Init();
        OrderLine."Shopify Order Id" := Any.IntegerInRange(100000, 999999);
        OrderLine."Line Id" := LineItemId;
        OrderLine."Unit Price" := Amount;
        OrderLine.Insert();

        // [SCENARIO] The function receive a JsonAray with Gift Card information. This will be parsed in the Gift Card record.
        //            For getting the amount of the give card, a Shopify order line must exist with the same line_item_id.

        // [GIVEN] Jarray = GiftCard json structure.
        // [WHEN] Invoke the function AddSoldGiftCards(JArray).
        GiftCards.AddSoldGiftCards(JArray);

        // [THEN] We must find the GiveCard record.
        LibraryAssert.IsTrue(GiftCard.Get(GiftCardId), 'Getting GiftCard record');

        // [THEN] GiftCard.LastCharacters = LastChars and GiftCard.Amount = Amount
        LibraryAssert.AreEqual(LastChars, GiftCard."Last Characters", 'GiftCard.LastCharacters');
        LibraryAssert.AreEqual(Amount, GiftCard.Amount, 'GiftCard.Amount');
    end;
}