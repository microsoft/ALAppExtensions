/// <summary>
/// Codeunit Shpfy Order Fulfillments Test (ID 139578).
/// </summary>
codeunit 139578 "Shpfy Order Fulfillments Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestImportFulfillment()
    var
        Orderfulfillment: Record "Shpfy Order Fulfillment";
        OrderFulfillments: Codeunit "Shpfy Order Fulfillments";
        Id: BigInteger;
        OrderId: BigInteger;
        JFulfillment: JsonToken;
        TrackingNo: Text[20];
    begin
        // [SCENARIO] Extract the data out json token that contains a fulfillment info into the "Shpfy Order Fulfillment" record.
        // [GIVEN] A random Generated Fufilment
        Id := Any.IntegerInRange(10000, 99999);
        OrderId := Any.IntegerInRange(10000, 99999);
        TrackingNo := Any.AlphabeticText(MaxStrLen(TrackingNo));
        JFulfillment := GetRandomFullFilmentAsJsonToken(Id, TrackingNo);

        // [WHEN] Invoke the function ImportFulfillment(JFulfillment)
        OrderFulfillments.ImportFulfillment(OrderId, JFulfillment);

        // [THEN] We must find the "Shpfy Order Fufillment" record with the same id
        LibraryAssert.IsTrue(Orderfulfillment.Get(Id), 'Get "Shpfy Order Fufillment" record');

        // [THEN] TrackingNo = ShpfyOrderfulfillment."Tracking Number"
        LibraryAssert.AreEqual(TrackingNo, Orderfulfillment."Tracking Number", 'Tracking number check');
    end;

    local procedure GetRandomFullFilmentAsJsonToken(id: BigInteger; TrackingNo: Text): JsonToken
    var
        JFulfillment: JsonObject;
        JLocation: JsonObject;
        JService: JsonObject;
        JTrackingInfo: JsonObject;
        JTrackingInfos: JsonArray;
        JArray: JsonArray;
        JNull: JsonValue;
        TrackingUrlTxt: Label 'https://www.trackingcompany.com?no=%1', Comment = '%1 = TrackingNo', Locked = true;
    begin
        JNull.SetValueToNull();
        JLocation.Add('legacyResourceId', Any.IntegerInRange(1000000, 9999999));
        JService.Add('serviceName', 'Manual');
        JService.Add('type', 'MANUAL');
        JService.Add('shippingMethods', JArray);
        JTrackingInfo.Add('number', TrackingNo);
        JTrackingInfo.Add('url', StrSubstNo(TrackingUrlTxt, TrackingNo));
        JTrackingInfo.Add('company', 'TrackingCompany');
        JTrackingInfos.Add(JTrackingInfo);

        JFulfillment.Add('legacyResourceId', id);
        JFulfillment.Add('name', Any.AlphabeticText(5));
        JFulfillment.Add('createdAt', Format(CurrentDateTime - 1, 0, 9));
        JFulfillment.Add('updatedAt', CurrentDateTime);
        JFulfillment.Add('deliveredAt', JNull);
        JFulfillment.Add('displayStatus', 'FULFILLED');
        JFulfillment.Add('estimatedDeliveryAt', JNull);
        JFulfillment.Add('status', 'SUCCESS');
        JFulfillment.Add('totalQuantity', 1);
        JFulfillment.Add('trackingInfo', JTrackingInfos);
        JFulfillment.Add('service', JService);
        JFulfillment.Add('fulfillmentLineItems', GetFulfillmentLineItems());
        exit(JFulfillment.AsToken());
    end;

    local procedure ConvertToJsonArray(List: List of [Text]): JsonArray
    var
        JShopMoney: JsonObject;
        JPresentManey: JsonObject;
    begin
        JShopMoney.Add('amount', Format(Price, 0, 9));
        JSet.Add('shopMoney', JShopMoney);
        JPresentManey.Add('amount', Format(Price, 0, 9));
        JSet.Add('presentmentMoney', JPresentManey);
    end;
}
