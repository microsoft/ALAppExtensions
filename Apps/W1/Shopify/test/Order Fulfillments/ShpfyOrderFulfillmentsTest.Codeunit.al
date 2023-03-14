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
        ShpfyOrderfulfillment: Record "Shpfy Order Fulfillment";
        ShpfyOrderFulfillments: Codeunit "Shpfy Order Fulfillments";
        Id: BigInteger;
        JFulfillment: JsonToken;
        TrackingNo: Text[20];
    begin
        // [SCENARIO] Extract the data out json token that contains a fulfillment info into the "Shpfy Order Fulfillment" record.
        // [GIVEN] A random Generated Fufilment
        Id := Any.IntegerInRange(10000, 99999);
        TrackingNo := Any.AlphabeticText(MaxStrLen(TrackingNo));
        JFulfillment := GetRandomFullFilmentAsJsonToken(Id, TrackingNo);

        // [WHEN] Invoke the function ImportFulfillment(JFulfillment)
        ShpfyOrderFulfillments.ImportFulfillment(JFulfillment);

        // [THEN] We must find the "Shpfy Order Fufillment" record with the same id
        LibraryAssert.IsTrue(ShpfyOrderfulfillment.Get(Id), 'Get "Shpfy Order Fufillment" record');

        // [THEN] TrackingNo = ShpfyOrderfulfillment."Tracking Number"
        LibraryAssert.AreEqual(TrackingNo, ShpfyOrderfulfillment."Tracking Number", 'Tracking number check');
    end;

    local procedure GetRandomFullFilmentAsJsonToken(id: BigInteger; TrackingNo: Text): JsonToken
    var
        JFulfillment: JsonObject;
        List: List of [Text];
        JValue: JsonValue;
        FulfillentGidTxt: Label 'gid://shopify/Fulfillment/%1', Comment = '%1 = id', Locked = true;
        TrackingUrlTxt: Label 'https://www.trackingcompany.com?no=%1', Comment = '%1 = TrackingNo', Locked = true;
    begin
        JFulfillment.Add('id', id);
        JFulfillment.Add('admin_graphql_api_id', StrSubstNo(FulfillentGidTxt, id));
        JFulfillment.Add('created_at', Format(CurrentDateTime - 1, 0, 9));
        JFulfillment.Add('location_id', Any.IntegerInRange(10000, 99999));
        JFulfillment.Add('name', Any.AlphabeticText(5));
        JFulfillment.Add('order_id', Any.IntegerInRange(10000, 99999));
        JFulfillment.Add('service', 'manual');
        JValue.SetValueToNull();
        JFulfillment.Add('ShipmentStatus', JValue);
        JFulfillment.Add('status', 'success');
        JFulfillment.Add('tracking_Company', 'TrackingCompany');
        JFulfillment.Add('tracking_number', TrackingNo);
        List.Add(TrackingNo);
        JFulfillment.Add('tracking_Numbers', ConvertToJsonArray(List));
        JFulfillment.Add('tracking_url', StrSubstNo(TrackingUrlTxt, TrackingNo));
        Clear(List);
        List.Add(StrSubstNo(TrackingUrlTxt, TrackingNo));
        JFulfillment.Add('tracking_urls', ConvertToJsonArray(List));
        JFulfillment.Add('Updated_at', CurrentDateTime);
        exit(JFulfillment.AsToken());
    end;

    local procedure ConvertToJsonArray(List: List of [Text]): JsonArray
    var
        JArray: JsonArray;
        Item: Text;
    begin
        foreach Item in List do
            JArray.Add(Item);
        exit(JArray);
    end;
}
