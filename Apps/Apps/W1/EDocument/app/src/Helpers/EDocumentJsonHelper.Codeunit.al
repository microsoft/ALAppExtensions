// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Helpers;

codeunit 6121 "EDocument Json Helper"
{
    Access = Internal;

    internal procedure GetHeaderFields(SourceJsonObject: JsonObject): JsonObject
    var
        JsonToken: JsonToken;
        ContentObject: JsonObject;
    begin
        ContentObject := GetInnerObject(SourceJsonObject);
        ContentObject.Get('fields', JsonToken);
        exit(JsonToken.AsObject());
    end;

    internal procedure GetLinesArray(SourceJsonObject: JsonObject): JsonArray
    var
        JsonToken: JsonToken;
        ContentObject: JsonObject;
    begin
        ContentObject := GetInnerObject(SourceJsonObject);
        if ContentObject.Get('items', JsonToken) then
            exit(JsonToken.AsArray());
    end;

    internal procedure GetInnerObject(SourceJsonObject: JsonObject): JsonObject
    var
        JsonToken: JsonToken;
        OutputsObject, InnerObject : JsonObject;
    begin
        SourceJsonObject.Get('outputs', JsonToken);
        OutputsObject := JsonToken.AsObject();
        OutputsObject.Get('1', JsonToken);
        InnerObject := JsonToken.AsObject();
        InnerObject.Get('result', JsonToken);
        exit(JsonToken.AsObject());
    end;

    internal procedure SetStringValueInField(FieldName: Text; MaxStrLen: Integer; var FieldsJsonObject: JsonObject; var Field: Text)
    var
        JsonValue: JsonValue;
    begin
        if not TryGetJsonFieldValue(FieldName, FieldsJsonObject, 'value_text', JsonValue) then
            exit;
        if TryAssignToText(JsonValue, MaxStrLen, Field) then;
    end;

    internal procedure SetDateValueInField(FieldName: Text; var FieldsJsonObject: JsonObject; var Field: Date)
    var
        JsonValue: JsonValue;
    begin
        if not TryGetJsonFieldValue(FieldName, FieldsJsonObject, 'value_date', JsonValue) then
            exit;

        if TryAssignToDate(JsonValue, Field) then;
    end;

    internal procedure SetNumberValueInField(FieldName: Text; var FieldsJsonObject: JsonObject; var DecimalValue: Decimal)
    var
        JsonValue: JsonValue;
    begin
        if not TryGetJsonFieldValue(FieldName, FieldsJsonObject, 'value_number', JsonValue) then
            exit;
        if TryAssignToDecimal(JsonValue, DecimalValue) then;
    end;

    internal procedure SetCurrencyValueInField(FieldName: Text; var FieldsJsonObject: JsonObject; var Amount: Decimal; var CurrencyCode: Code[10])
    var
        CurrencyValueAsJson: JsonValue;
        FoundCurrency: Text;
    begin
        // 1. Read the number value from the JSON object
        SetNumberValueInField(FieldName, FieldsJsonObject, Amount);

        // 2. Try to read the currency code from the JSON object
        if not TryGetJsonFieldValue(FieldName, FieldsJsonObject, 'currency_code', CurrencyValueAsJson) then
            exit;
        if TryAssignToText(CurrencyValueAsJson, MaxStrLen(CurrencyCode), FoundCurrency) then;

        if FoundCurrency = '' then
            exit;
        if CurrencyCode = '' then begin
            CurrencyCode := CopyStr(FoundCurrency, 1, MaxStrLen(CurrencyCode));
            exit;
        end;
    end;

    local procedure TryGetJsonFieldValue(FieldName: Text; FieldsJsonObject: JsonObject; ValueKey: Text; var JsonValue: JsonValue): Boolean
    var
        JsonToken: JsonToken;
    begin
        if not FieldsJsonObject.Contains(FieldName) then
            exit(false);
        // CAPI returns all parameters, even if they are null. This avoid errors when trying to access a null object
        FieldsJsonObject.Get(FieldName, JsonToken);
        if not JsonToken.IsObject() then
            exit(false);

        JsonToken.AsObject().Get(ValueKey, JsonToken);
        if not JsonToken.IsValue() then
            exit(false);

        JsonValue := JsonToken.AsValue();
        exit(true);
    end;

    [TryFunction]
    internal procedure TryAssignToText(JsonValue: JsonValue; MaxStrLen: Integer; var TextValue: Text)
    begin
        TextValue := CopyStr(JsonValue.AsText(), 1, MaxStrLen);
    end;


    [TryFunction]
    internal procedure TryAssignToDecimal(JsonValue: JsonValue; var DecimalField: Decimal)
    begin
        DecimalField := JsonValue.AsDecimal();
    end;

    [TryFunction]
    internal procedure TryAssignToDate(JsonValue: JsonValue; var DateValue: Date)
    begin
        DateValue := JsonValue.AsDate();
    end;
}