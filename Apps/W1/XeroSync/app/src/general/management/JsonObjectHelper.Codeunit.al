codeunit 2412 "XS Json Object Helper"
{
    var
        JObject: JsonObject;

    procedure GetJsonValue(Property: Text) JValue: JsonValue
    var
        JToken: JsonToken;
    begin
        if not JObject.Get(Property, JToken) then
            exit;
        JValue := JToken.AsValue();
    end;

    procedure GetJsonValueAsText(Property: Text) JValueAsText: Text
    var
        JToken: JsonToken;
    begin
        if not JObject.Get(Property, JToken) then
            exit;
        JValueAsText := JToken.AsValue().AsText();
    end;

    procedure GetJsonValueAsDecimal(Property: Text) JValueAsDecimal: Decimal
    var
        JToken: JsonToken;
    begin
        if not JObject.Get(Property, JToken) then
            exit;
        JValueAsDecimal := JToken.AsValue().AsDecimal();
    end;

    procedure GetJsonToken(Property: Text): JsonToken
    var
        JToken: JsonToken;
    begin
        if not JObject.Get(Property, JToken) then
            exit;
        exit(JToken);
    end;

    procedure IsNullValue(Property: Text) Result: Boolean
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if not JObject.Get(Property, JToken) then
            exit;

        JValue := JToken.AsValue();
        Result := JValue.IsNull() or JValue.IsUndefined();
    end;

    procedure ReadFromText(Data: Text)
    begin
        Clear(JObject);
        JObject.ReadFrom(Data);
    end;

    procedure SetJsonObject(var Value: JsonObject)
    begin
        JObject := Value;
    end;

    procedure SetJsonObject(var Value: JsonToken)
    begin
        if Value.IsObject() then
            JObject := Value.AsObject();
    end;

    local procedure GetBlobData(var RecRef: RecordRef; BLOBFieldNo: Integer) XeroJsonText: Text
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
    begin
        TempBlob.FromRecordRef(RecRef, BLOBFieldNo);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        InStream.Read(XeroJsonText);
    end;

    procedure GetBLOBDataAsJsonObject(var RecRef: RecordRef; BLOBFieldNo: Integer) ReturnedJsonObject: JsonObject
    var
        XeroJsonText: Text;
    begin
        XeroJsonText := GetBlobData(RecRef, BLOBFieldNo);
        ReturnedJsonObject.ReadFrom(XeroJsonText);
    end;

    procedure GetBLOBDataAsJsonToken(var RecRef: RecordRef; BLOBFieldNo: Integer) ReturnedJsonToken: JsonToken
    var
        XeroJsonText: Text;
    begin
        XeroJsonText := GetBlobData(RecRef, BLOBFieldNo);
        ReturnedJsonToken.ReadFrom(XeroJsonText);
    end;

    procedure GetBLOBDataAsText(var RecRef: RecordRef; BLOBFieldNo: Integer) ReturnedJsonText: Text
    begin
        ReturnedJsonText := GetBlobData(RecRef, BLOBFieldNo);
    end;

    procedure GetExternalIDFromBLOB(NAVEntityID: Integer; var SyncMapping: Record "Sync Mapping") ExternalID: Text
    var
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
        RecRef: RecordRef;
        JObject: JsonObject;
        ExternalIDTag: Text;
    begin
        case NAVEntityID of
            Database::Item:
                ExternalIDTag := XeroSyncManagement.GetJsonTagForItemID();
            Database::Customer:
                ExternalIDTag := XeroSyncManagement.GetJsonTagForCustomerID();
        end;

        RecRef.GetTable(SyncMapping);
        JObject := GetBLOBDataAsJsonObject(RecRef, SyncMapping.FieldNo(SyncMapping."XS Xero Json Response"));
        SetJsonObject(JObject);
        ExternalID := GetJsonValueAsText(ExternalIDTag);
    end;

    procedure AddValueToJObject(var Jobject: JsonObject; KeyData: Text; Value: Text)
    begin
        Jobject.Add(KeyData, Value);
    end;

    procedure AddValueToJObject(var Jobject: JsonObject; KeyData: Text; Value: Decimal)
    begin
        Jobject.Add(KeyData, Value);
    end;

    procedure AddValueToJObject(var Jobject: JsonObject; KeyData: Text; Value: DateTime)
    begin
        Jobject.Add(KeyData, Value);
    end;

    procedure AddValueToJObject(var Jobject: JsonObject; KeyData: Text; Value: Date)
    begin
        Jobject.Add(KeyData, Value);
    end;

    procedure AddArrayAsValueToJObject(var Jobject: JsonObject; KeyData: Text; Value: JsonArray)
    begin
        Jobject.Add(KeyData, Value);
    end;

    procedure AddObjectAsValueToJObject(var Jobject: JsonObject; KeyData: Text; Value: JsonObject)
    begin
        Jobject.Add(KeyData, Value);
    end;

    procedure AddDataToJArray(var Jarray: JsonArray; JObject: JsonObject)
    begin
        Jarray.Add(JObject);
    end;

    procedure CleanJsonObject(var JObject: Jsonobject)
    var
        EmptyJObject: JsonObject;
    begin
        JObject := EmptyJObject;
    end;

    procedure CleanJsonArray(var JArray: JsonArray)
    var
        EmptyJArray: JsonArray;
    begin
        JArray := EmptyJArray;
    end;
}