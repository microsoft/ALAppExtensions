namespace Microsoft.Integration.Shopify;

using System.Text;
using System.Utilities;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using System.DateTime;

/// <summary>
/// Codeunit Shpfy Json Helper (ID 30157).
/// </summary>
codeunit 30157 "Shpfy Json Helper"
{
    Access = Internal;
    SingleInstance = true;

    #region ContainsToken
    /// <summary> 
    /// Description for ContainsToken.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return variable "Boolean".</returns>
    internal procedure ContainsToken(JToken: JsonToken; TokenPath: Text): Boolean
    var
        TokenPaths: List of [Text];
    begin
        TokenPaths := TokenPath.Split('.');
        foreach TokenPath in TokenPaths do
            if JToken.AsObject().Get(TokenPath, JToken) then
                if TokenPaths.IndexOf(TokenPath) = TokenPaths.Count then
                    exit(true);
    end;

    /// <summary> 
    /// Description for ContainsToken.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return variable "Boolean".</returns>
    internal procedure ContainsToken(JObject: JsonObject; TokenPath: Text): Boolean
    begin
        exit(ContainsToken(JObject.AsToken(), TokenPath));
    end;
    #endregion ContainsToken

    #region GetArrayAsText
    /// <summary> 
    /// Description for GetArrayAsText.
    /// </summary>
    /// <param name="JArray">Parameter of type JsonArray.</param>
    /// <returns>Return variable "Text".</returns>
    internal procedure GetArrayAsText(JArray: JsonArray): Text
    var
        JToken: JsonToken;
        Value: Text;
        Builder: TextBuilder;
    begin
        foreach JToken in JArray do
            if JToken.IsValue then begin
                Value := JToken.AsValue().AsText();
                if Value.Contains(',') then begin
                    Builder.Append(', "');
                    Builder.Append(Value);
                    Builder.Append('"');
                end else begin
                    Builder.Append(', ');
                    Builder.Append(Value);
                end;
            end else begin
                Builder.Append(', ');
                Builder.Append(Format(JToken));
            end;
        if Builder.Length > 2 then
            exit(Builder.ToText().Remove(1, 2));
    end;

    /// <summary> 
    /// Description for GetArrayAsText.
    /// </summary>
    /// <param name="JArray">Parameter of type JsonArray.</param>
    /// <param name="MaxLength">Parameter of type Integer.</param>
    /// <returns>Return variable "Text".</returns>
    internal procedure GetArrayAsText(JArray: JsonArray; MaxLength: Integer): Text
    begin
        exit(CopyStr(GetArrayAsText(JArray), 1, MaxLength));
    end;

    /// <summary> 
    /// Description for GetArrayAsText.
    /// </summary>
    /// <param name="JObject">Parameter of type JSonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return variable "Text".</returns>
    internal procedure GetArrayAsText(JObject: JsonObject; TokenPath: Text): Text
    var
        JArray: JsonArray;
    begin
        if GetJsonArray(JObject, JArray, TokenPath) then
            exit(GetArrayAsText(JArray));
    end;

    /// <summary> 
    /// Description for GetArrayAsText.
    /// </summary>
    /// <param name="JObject">Parameter of type JSonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <param name="MaxLength">Parameter of type Integer.</param>
    /// <returns>Return variable "Text".</returns>
    internal procedure GetArrayAsText(JObject: JsonObject; TokenPath: Text; MaxLength: Integer): Text
    begin
        exit(CopyStr(GetArrayAsText(JObject, TokenPath), 1, MaxLength));
    end;

    /// <summary> 
    /// Description for GetArrayAsText.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return variable "Text".</returns>
    internal procedure GetArrayAsText(JToken: JsonToken; TokenPath: Text): Text
    var
        JArray: JsonArray;
    begin
        if GetJsonArray(JToken, JArray, TokenPath) then
            exit(GetArrayAsText(JArray));
    end;

    /// <summary> 
    /// Description for GetArrayAsText.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <param name="MaxLength">Parameter of type Integer.</param>
    /// <returns>Return variable "Text".</returns>
    internal procedure GetArrayAsText(JToken: JsonToken; TokenPath: Text; MaxLength: Integer): Text
    begin
        exit(CopyStr(GetArrayAsText(JToken, TokenPath), 1, MaxLength));
    end;
    #endregion GetArrayAsText

    #region GetJsonArray
    internal procedure GetJsonArray(JToken: JsonToken; TokenPath: Text): JsonArray
    var
        JResult: JsonArray;
    begin
        if GetJsonArray(JToken, JResult, TokenPath) then
            exit(JResult);
    end;

    internal procedure GetJsonArray(JObject: JsonObject; TokenPath: Text): JsonArray
    begin
        exit(GetJsonArray(JObject.AsToken(), TokenPath));
    end;

    /// <summary> 
    /// Get Json Array.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="JResult">Parameter of type JsonArray.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure GetJsonArray(JToken: JsonToken; var JResult: JsonArray; TokenPath: Text): Boolean
    var
        TokenPaths: List of [Text];
    begin
        if JToken.IsValue then
            exit(false);

        Clear(JResult);
        if JToken.IsArray and (TokenPath = '') then begin
            JResult := JToken.AsArray();
            exit(true);
        end;

        TokenPaths := TokenPath.Split('.');
        foreach TokenPath in TokenPaths do
            if JToken.AsObject().Get(TokenPath, JToken) then
                if TokenPaths.IndexOf(TokenPath) = TokenPaths.Count then
                    if JToken.IsArray then begin
                        JResult := JToken.AsArray();
                        exit(true);
                    end;
    end;

    /// <summary> 
    /// Get Json Array.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="JResult">Parameter of type JsonArray.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure GetJsonArray(JObject: JsonObject; var JResult: JsonArray; TokenPath: text): Boolean
    begin
        exit(GetJsonArray(JObject.AsToken(), JResult, TokenPath));
    end;
    #endregion GetJsonArray

    #region GetJsonObject
    internal procedure GetJsonObject(JToken: JsonToken; TokenPath: Text): JsonObject
    var
        JResult: JsonObject;
    begin
        if GetJsonObject(JToken, JResult, TokenPath) then
            exit(JResult);
    end;

    internal procedure GetJsonObject(JObject: JsonObject; TokenPath: Text): JsonObject
    begin
        exit(GetJsonObject(JObject.AsToken(), TokenPath));
    end;

    /// <summary> 
    /// Get Json Object.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="JResult">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure GetJsonObject(JToken: JsonToken; var JResult: JsonObject; TokenPath: Text): Boolean
    var
        TokenPaths: List of [Text];
    begin
        Clear(JResult);
        if JToken.IsObject and (TokenPath = '') then begin
            JResult := JToken.AsObject();
            exit(true);
        end;

        TokenPaths := TokenPath.Split('.');
        foreach TokenPath in TokenPaths do
            if JToken.AsObject().Get(TokenPath, JToken) then
                if TokenPaths.IndexOf(TokenPath) = TokenPaths.Count then
                    if JToken.IsObject then begin
                        JResult := JToken.AsObject();
                        exit(true);
                    end;
    end;

    /// <summary> 
    /// Get Json Object.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="JResult">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure GetJsonObject(JObject: JsonObject; var JResult: JsonObject; TokenPath: text): Boolean
    begin
        exit(GetJsonObject(JObject.AsToken(), JResult, TokenPath));
    end;
    #endregion GetJsonObject

    #region GetJsonToken
    /// <summary> 
    /// Get Json Token.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type JsonToken.</returns>
    internal procedure GetJsonToken(JToken: JsonToken; TokenPath: Text): JsonToken
    var
        TokenPaths: List of [Text];
    begin
        TokenPaths := TokenPath.Split('.');
        foreach TokenPath in TokenPaths do
            if JToken.AsObject().Get(TokenPath, JToken) then
                if TokenPaths.IndexOf(TokenPath) = TokenPaths.Count then
                    exit(JToken);
    end;
    #endregion GetJsonToken

    #region IsNull
    internal procedure IsNull(JToken: JsonToken; TokenPath: Text): boolean
    var
        TokenPaths: List of [Text];
    begin
        TokenPaths := TokenPath.Split('.');
        foreach TokenPath in TokenPaths do
            if JToken.AsObject().Get(TokenPath, JToken) then
                if TokenPaths.IndexOf(TokenPath) = TokenPaths.Count then
                    if JToken.IsValue then
                        exit(JToken.AsValue().IsNull);
    end;

    internal procedure IsNull(JObject: JsonObject; TokenPath: Text): boolean
    begin
        exit(IsNull(JObject.AsToken(), TokenPath))
    end;
    #endregion IsNull

    #region GetJsonValue
    /// <summary> 
    /// Get Json Value.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="JResult">Parameter of type JsonValue.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure GetJsonValue(JToken: JsonToken; var JResult: JsonValue; TokenPath: Text): Boolean
    var
        TokenPaths: List of [Text];
    begin
        Clear(JResult);
        if JToken.IsValue then begin
            if (TokenPath = '') then begin
                JResult := JToken.AsValue();
                exit(true);
            end;
            exit(false);
        end;

        TokenPaths := TokenPath.Split('.');
        foreach TokenPath in TokenPaths do
            if JToken.IsObject then
                if JToken.AsObject().Get(TokenPath, JToken) then begin
                    if TokenPaths.IndexOf(TokenPath) = TokenPaths.Count then
                        if JToken.IsValue then begin
                            JResult := JToken.AsValue();
                            exit(not (JResult.IsNull or JResult.IsUndefined));
                        end;
                end
                else
                    if TokenPaths.IndexOf(TokenPath) = TokenPaths.Count then
                        if JToken.IsValue then begin
                            JResult := JToken.AsValue();
                            exit(not (JResult.IsNull or JResult.IsUndefined));
                        end;
    end;

    /// <summary> 
    /// Get Json Value.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="JResult">Parameter of type JsonValue.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure GetJsonValue(JObject: JsonObject; var JResult: JsonValue; TokenPath: Text): Boolean
    begin
        exit(GetJsonValue(JObject.AsToken(), JResult, TokenPath));
    end;
    #endregion GetJsonValue

    #region GetValueAsBigInteger
    /// <summary> 
    /// Get Value As Big Integer.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type BigInteger.</returns>
    internal procedure GetValueAsBigInteger(JToken: JsonToken; TokenPath: Text): BigInteger
    var
        JValue: JsonValue;
    begin
        if JToken.IsObject then
            exit(GetValueAsBigInteger(JToken.AsObject(), TokenPath))
        else
            if JToken.IsValue then begin
                JValue := JToken.AsValue();
                if not (JValue.IsNull or JValue.IsUndefined) then
                    exit(JValue.AsBigInteger());
            end;
    end;

    /// <summary> 
    /// Get Value As Big Integer.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type BigInteger.</returns>
    internal procedure GetValueAsBigInteger(JObject: JsonObject; TokenPath: Text): BigInteger
    var
        JValue: JsonValue;
    begin
        if GetJsonValue(JObject, JValue, TokenPath) then
            exit(JValue.AsBigInteger());
    end;
    #endregion GetValueAsBigInteger

    #region GetValueAsBoolean
    /// <summary> 
    /// Get Value As Boolean.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure GetValueAsBoolean(JToken: JsonToken; TokenPath: Text): Boolean
    var
        JValue: JsonValue;
    begin
        if JToken.IsObject then
            exit(GetValueAsBoolean(JToken.AsObject(), TokenPath))
        else
            if JToken.IsValue then begin
                JValue := JToken.AsValue();
                if not (JValue.IsNull or JValue.IsUndefined) then
                    exit(JValue.AsBoolean());
            end;
    end;

    /// <summary> 
    /// Get Value As Boolean.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure GetValueAsBoolean(JObject: JsonObject; TokenPath: Text): Boolean
    var
        JValue: JsonValue;
    begin
        if GetJsonValue(JObject, JValue, TokenPath) then
            exit(JValue.AsBoolean());
    end;
    #endregion GetValueAsBoolean

    #region GetValueAsByte
    /// <summary> 
    /// Get Value As Byte.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Byte.</returns>
    internal procedure GetValueAsByte(JToken: JsonToken; TokenPath: Text): Byte
    var
        JValue: JsonValue;
    begin
        if JToken.IsObject then
            exit(GetValueAsByte(JToken.AsObject(), TokenPath))
        else
            if JToken.IsValue then begin
                JValue := JToken.AsValue();
                if not (JValue.IsNull or JValue.IsUndefined) then
                    exit(JValue.AsByte());
            end;
    end;

    /// <summary> 
    /// Get Value As Byte.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Byte.</returns>
    internal procedure GetValueAsByte(JObject: JsonObject; TokenPath: Text): Byte
    var
        JValue: JsonValue;
    begin
        if GetJsonValue(JObject, JValue, TokenPath) then
            exit(JValue.AsByte());
    end;
    #endregion GetValueAsByte

    #region GetValueAsChar
    /// <summary> 
    /// Get Value As Char.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Char.</returns>
    internal procedure GetValueAsChar(JToken: JsonToken; TokenPath: Text): Char
    var
        JValue: JsonValue;
    begin
        if JToken.IsObject then
            exit(GetValueAsChar(JToken.AsObject(), TokenPath))
        else
            if JToken.IsValue then begin
                JValue := JToken.AsValue();
                if not (JValue.IsNull or JValue.IsUndefined) then
                    exit(JValue.AsChar());
            end;
    end;

    /// <summary> 
    /// Get Value As Char.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Char.</returns>
    internal procedure GetValueAsChar(JObject: JsonObject; TokenPath: Text): Char
    var
        JValue: JsonValue;
    begin
        if GetJsonValue(JObject, JValue, TokenPath) then
            exit(JValue.AsChar());
    end;
    #endregion GetValueAsChar

    #region GetValueAsCode
    /// <summary> 
    /// Get Value As Code.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetValueAsCode(JToken: JsonToken; TokenPath: Text): Text
    var
        JValue: JsonValue;
    begin
        if JToken.IsObject then
            exit(GetValueAsCode(JToken.AsObject(), TokenPath))
        else
            if JToken.IsValue then begin
                JValue := JToken.AsValue();
                if not (JValue.IsNull or JValue.IsUndefined) then
                    exit(JValue.AsCode());
            end;
    end;

    /// <summary> 
    /// Get Value As Code.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetValueAsCode(JObject: JsonObject; TokenPath: Text): Text
    var
        JValue: JsonValue;
    begin
        if GetJsonValue(JObject, JValue, TokenPath) then
            exit(JValue.AsCode());
    end;

    /// <summary> 
    /// Get Value As Code.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <param name="MaxLength">Parameter of type Integer.</param>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetValueAsCode(JToken: JsonToken; TokenPath: Text; MaxLength: Integer): Text
    begin
        if JToken.IsObject then
            exit(GetValueAsCode(JToken.AsObject(), TokenPath, MaxLength))
        else
            if JToken.IsValue then
                exit(CopyStr(JToken.AsValue().AsCode(), 1, MaxLength));
    end;

    /// <summary> 
    /// Get Value As Code.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <param name="MaxLength">Parameter of type Integer.</param>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetValueAsCode(JObject: JsonObject; TokenPath: Text; MaxLength: Integer): Text
    begin
        exit(CopyStr(GetValueAsCode(JObject, TokenPath), 1, MaxLength));
    end;
    #endregion GetValueAsCode

    #region GetValueAsDate
    /// <summary> 
    /// Get Value As Date.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Date.</returns>
    internal procedure GetValueAsDate(JToken: JsonToken; TokenPath: Text): Date
    var
        JValue: JsonValue;
    begin
        if JToken.IsObject then
            exit(GetValueAsDate(JToken.AsObject(), TokenPath))
        else
            if JToken.IsValue then begin
                JValue := JToken.AsValue();
                if not (JValue.IsNull or JValue.IsUndefined) then
                    exit(JValue.AsDate());
            end;
    end;

    /// <summary> 
    /// Get Value As Date.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Date.</returns>
    internal procedure GetValueAsDate(JObject: JsonObject; TokenPath: Text): Date
    var
        CompanyInformation: Record "Company Information";
        PostCode: Record "Post Code";
        JValue: JsonValue;
        Result: Date;
        UTC: DateTime;
        OffSet: Duration;
    begin
        if GetJsonValue(JObject, JValue, TokenPath) then
            if TryAsDate(JValue, Result) then
                exit(Result)
            else begin
                if TryGetUTC(JValue.AsDateTime(), UTC) then begin
                    if CompanyInformation.Get() then
                        if PostCode.Get(CompanyInformation."Post Code", CompanyInformation.City) then
                            if PostCode."Time Zone" <> '' then
                                if TryGetTimezoneOffset(UTC, PostCode."Time Zone", OffSet) then
                                    exit(DT2Date(UTC - OffSet));
                    exit(DT2Date(UTC));
                end;
                exit(DT2Date(JValue.AsDateTime()));
            end;
    end;

    [TryFunction]
    local procedure TryGetTimezoneOffset(DateTime: DateTime; TimeZoneCode: Text; var OffSet: Duration)
    var
        TimeZone: Codeunit "Time Zone";
    begin
        OffSet := TimeZone.GetTimezoneOffset(DateTime, TimeZoneCode);
    end;

    [TryFunction]
    local procedure TryGetUTC(DateTime: DateTime; var UTC: DateTime)
    var
        TimeZone: Codeunit "Time Zone";
    begin
        UTC := DateTime - TimeZone.GetTimezoneOffset(DateTime);
    end;

    [TryFunction]
    local procedure TryAsDate(JValue: JsonValue; var ResultDate: Date)
    begin
        ResultDate := JValue.AsDate();
    end;
    #endregion GetValueAsDate

    #region GetValueAsDateTime
    /// <summary> 
    /// Get Value As DateTime.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type DateTime.</returns>
    internal procedure GetValueAsDateTime(JToken: JsonToken; TokenPath: Text): DateTime
    var
        JValue: JsonValue;
    begin
        if JToken.IsObject then
            exit(GetValueAsDateTime(JToken.AsObject(), TokenPath))
        else
            if JToken.IsValue then begin
                JValue := JToken.AsValue();
                if not (JValue.IsNull or JValue.IsUndefined) then
                    exit(JValue.AsDateTime());
            end;
    end;

    /// <summary> 
    /// Get Value As DateTime.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type DateTime.</returns>
    internal procedure GetValueAsDateTime(JObject: JsonObject; TokenPath: Text): DateTime
    var
        JValue: JsonValue;
    begin
        if GetJsonValue(JObject, JValue, TokenPath) then
            exit(JValue.AsDateTime());
    end;
    #endregion GetValueAsDateTime

    #region GetValueAsDecimal
    /// <summary> 
    /// Get Value As Decimal.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Decimal.</returns>
    internal procedure GetValueAsDecimal(JToken: JsonToken; TokenPath: Text): Decimal
    var
        JValue: JsonValue;
    begin
        if JToken.IsObject then
            exit(GetValueAsDecimal(JToken.AsObject(), TokenPath))
        else
            if JToken.IsValue then begin
                JValue := JToken.AsValue();
                if not (JValue.IsNull or JValue.IsUndefined) then
                    exit(JValue.AsDecimal());
            end;
    end;

    /// <summary> 
    /// Get Value As Decimal.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Decimal.</returns>
    internal procedure GetValueAsDecimal(JObject: JsonObject; TokenPath: Text): Decimal
    var
        JValue: JsonValue;
    begin
        if GetJsonValue(JObject, JValue, TokenPath) then
            exit(JValue.AsDecimal());
    end;
    #endregion GetValueAsDecimal

    #region GetValueAsDuration
    /// <summary> 
    /// Get Value As Duration.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Duration.</returns>
    internal procedure GetValueAsDuration(JToken: JsonToken; TokenPath: Text): Duration
    var
        JValue: JsonValue;
    begin
        if JToken.IsObject then
            exit(GetValueAsDuration(JToken.AsObject(), TokenPath))
        else
            if JToken.IsValue then begin
                JValue := JToken.AsValue();
                if not (JValue.IsNull or JValue.IsUndefined) then
                    exit(JValue.AsDuration());
            end;
    end;

    /// <summary> 
    /// Get Value As Duration.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Duration.</returns>
    internal procedure GetValueAsDuration(JObject: JsonObject; TokenPath: Text): Duration
    var
        JValue: JsonValue;
    begin
        if GetJsonValue(JObject, JValue, TokenPath) then
            exit(JValue.AsDuration());
    end;
    #endregion GetValueAsDuration

    #region GetValueAsInteger
    /// <summary> 
    /// Get Value As Integer.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetValueAsInteger(JToken: JsonToken; TokenPath: Text): Integer
    var
        JValue: JsonValue;
    begin
        if JToken.IsObject then
            exit(GetValueAsInteger(JToken.AsObject(), TokenPath))
        else
            if JToken.IsValue then begin
                JValue := JToken.AsValue();
                if not (JValue.IsNull or JValue.IsUndefined) then
                    exit(JValue.AsInteger());
            end;
    end;

    /// <summary> 
    /// Get Value As Integer.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Integer.</returns>
    internal procedure GetValueAsInteger(JObject: JsonObject; TokenPath: Text): Integer
    var
        JValue: JsonValue;
    begin
        if GetJsonValue(JObject, JValue, TokenPath) then
            exit(JValue.AsInteger());
    end;
    #endregion GetValueAsInteger

    #region GetValueAsOption
    /// <summary> 
    /// Get Value As Option.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Option.</returns>
    internal procedure GetValueAsOption(JToken: JsonToken; TokenPath: Text): Option
    var
        JValue: JsonValue;
    begin
        if JToken.IsObject then
            exit(GetValueAsOption(JToken.AsObject(), TokenPath))
        else
            if JToken.IsValue then begin
                JValue := JToken.AsValue();
                if not (JValue.IsNull or JValue.IsUndefined) then
                    exit(JValue.AsOption());
            end;
    end;

    /// <summary> 
    /// Get Value As Option.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Option.</returns>
    internal procedure GetValueAsOption(JObject: JsonObject; TokenPath: Text): Option
    var
        JValue: JsonValue;
    begin
        if GetJsonValue(JObject, JValue, TokenPath) then
            exit(JValue.AsOption());
    end;
    #endregion GetValueAsOption

    #region GetValueAsText
    /// <summary> 
    /// Get Value As Text.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetValueAsText(JToken: JsonToken; TokenPath: Text): Text
    var
        JValue: JsonValue;
    begin
        if JToken.IsObject then
            exit(GetValueAsText(JToken.AsObject(), TokenPath))
        else
            if JToken.IsValue then begin
                JValue := JToken.AsValue();
                if not (JValue.IsNull or JValue.IsUndefined) then
                    exit(JValue.AsText());
            end;
    end;

    /// <summary> 
    /// Get Value As Text.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetValueAsText(JObject: JsonObject; TokenPath: Text): Text
    var
        JValue: JsonValue;
    begin
        if GetJsonValue(JObject, JValue, TokenPath) then
            exit(JValue.AsText());
    end;

    /// <summary> 
    /// Get Value As Text.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <param name="MaxLength">Parameter of type Integer.</param>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetValueAsText(JToken: JsonToken; TokenPath: Text; MaxLength: Integer): Text
    begin
        exit(CopyStr(GetValueAsText(JToken, TokenPath), 1, MaxLength));
    end;

    /// <summary> 
    /// Get Value As Text.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <param name="MaxLength">Parameter of type Integer.</param>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetValueAsText(JObject: JsonObject; TokenPath: Text; MaxLength: Integer): Text
    begin
        exit(CopyStr(GetValueAsText(JObject, TokenPath), 1, MaxLength));
    end;
    #endregion GetValueAsText

    #region GetValueAsTime
    /// <summary> 
    /// Get Value As Time.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Time.</returns>
    internal procedure GetValueAsTime(JToken: JsonToken; TokenPath: Text): Time
    var
        JValue: JsonValue;
    begin
        if JToken.IsObject then
            exit(GetValueAsTime(JToken.AsObject(), TokenPath))
        else
            if JToken.IsValue then begin
                JValue := JToken.AsValue();
                if not (JValue.IsNull or JValue.IsUndefined) then
                    exit(JValue.AsTime());
            end;
    end;

    /// <summary> 
    /// Get Value As Time.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <returns>Return value of type Time.</returns>
    internal procedure GetValueAsTime(JObject: JsonObject; TokenPath: Text): Time
    var
        JValue: JsonValue;
    begin
        if GetJsonValue(JObject, JValue, TokenPath) then
            exit(JValue.AsTime());
    end;
    #endregion GetValueAsTime

    #region GetValueIntoField
    /// <summary> 
    /// Get Value Into Field.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <param name="RecordRef">Parameter of type RecordRef.</param>
    /// <param name="FieldNo">Parameter of type Integer.</param>
    internal procedure GetValueIntoField(JToken: JsonToken; TokenPath: Text; var RecordRef: RecordRef; FieldNo: Integer)
    var
        Base64Convert: Codeunit "Base64 Convert";
        Base64: Codeunit "Shpfy Base64";
        TempBlob: Codeunit "Temp Blob";
        FieldRef: FieldRef;
        FieldType: FieldType;
        NotImplementedErr: Label 'No implementation for fieldtype: "%1".', Comment = '%1 = Field type';
        OutStream: OutStream;
        Data: Text;
    begin

        FieldRef := RecordRef.Field(FieldNo);
        case FieldRef.Type of
            FieldType::BigInteger:
                FieldRef.Value := GetValueAsBigInteger(JToken, TokenPath);
            FieldType::Blob:
                begin
                    Data := GetValueAsText(JToken, TokenPath);
                    if Base64.IsBase64String(Data) then begin
                        TempBlob.CreateOutStream(OutStream);
                        Data := Base64Convert.FromBase64(Data);
                        OutStream.Write(Data);
                    end else begin
                        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
                        OutStream.WriteText(Data);
                    end;
                    TempBlob.ToRecordRef(RecordRef, FieldNo);
                end;
            FieldType::Boolean:
                FieldRef.Value := GetValueAsBoolean(JToken, TokenPath);
            FieldType::Code,
            FieldType::Text:
                FieldRef.Value := GetValueAsText(JToken, TokenPath, FieldRef.Length);
            FieldType::Date:
                FieldRef.Value := GetValueAsDate(JToken, TokenPath);
            FieldType::DateTime:
                FieldRef.Value := GetValueAsDateTime(JToken, TokenPath);
            FieldType::Decimal:
                FieldRef.Value := GetValueAsDecimal(JToken, TokenPath);
            FieldType::Duration:
                FieldRef.Value := GetValueAsDuration(JToken, TokenPath);
            FieldType::Guid:
                FieldRef.Value := GetValueAsText(JToken, TokenPath);
            FieldType::Integer:
                FieldRef.Value := GetValueAsInteger(JToken, TokenPath);
            FieldType::Option:
                FieldRef.Value := GetValueAsOption(JToken, TokenPath);
            FieldType::Time:
                FieldRef.Value := GetValueAsTime(JToken, TokenPath);
            else
                Error(NotImplementedErr, FieldRef.Type);
        end;
    end;

    /// <summary> 
    /// Get Value Into Field.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <param name="RecordRef">Parameter of type RecordRef.</param>
    /// <param name="FieldNo">Parameter of type Integer.</param>
    internal procedure GetValueIntoField(JObject: JsonObject; TokenPath: Text; var RecordRef: RecordRef; FieldNo: Integer)
    begin
        GetValueIntoField(JObject.AsToken(), TokenPath, RecordRef, FieldNo);
    end;
    #endregion GetValueIntoField

    #region GetValueIntoFieldWithValidation
    /// <summary> 
    /// Get Value Into Field With Validation.
    /// </summary>
    /// <param name="JToken">Parameter of type JsonToken.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <param name="RecordRef">Parameter of type RecordRef.</param>
    /// <param name="FieldNo">Parameter of type Integer.</param>
    internal procedure GetValueIntoFieldWithValidation(JToken: JsonToken; TokenPath: Text; var RecordRef: RecordRef; FieldNo: Integer)
    var
        TempBlob: Codeunit "Temp Blob";
        FieldRef: FieldRef;
        FieldType: FieldType;
        NotImplementedErr: Label 'No implementation for fieldtype: "%1".', Comment = '%1 = TokenPath';
        OutStream: OutStream;
    begin

        FieldRef := RecordRef.Field(FieldNo);
        case FieldRef.Type of
            FieldType::BigInteger:
                FieldRef.Validate(GetValueAsBigInteger(JToken, TokenPath));
            FieldType::Blob:
                begin
                    TempBlob.CreateOutStream(OutStream);
                    OutStream.Write(GetValueAsText(JToken, TokenPath));
                    TempBlob.ToRecordRef(RecordRef, FieldNo);
                end;
            FieldType::Boolean:
                FieldRef.Validate(GetValueAsBoolean(JToken, TokenPath));
            FieldType::Code,
            FieldType::Text:
                FieldRef.Validate(GetValueAsText(JToken, TokenPath, FieldRef.Length));
            FieldType::Date:
                FieldRef.Validate(GetValueAsDate(JToken, TokenPath));
            FieldType::DateTime:
                FieldRef.Validate(GetValueAsDateTime(JToken, TokenPath));
            FieldType::Decimal:
                FieldRef.Validate(GetValueAsDecimal(JToken, TokenPath));
            FieldType::Duration:
                FieldRef.Validate(GetValueAsDuration(JToken, TokenPath));
            FieldType::Guid:
                FieldRef.Validate(GetValueAsText(JToken, TokenPath));
            FieldType::Integer:
                FieldRef.Validate(GetValueAsInteger(JToken, TokenPath));
            FieldType::Option:
                FieldRef.Validate(GetValueAsOption(JToken, TokenPath));
            FieldType::Time:
                FieldRef.Validate(GetValueAsTime(JToken, TokenPath));
            else
                Error(NotImplementedErr, FieldRef.Type);
        end;
    end;

    /// <summary> 
    /// Description for GetValueIntoFieldWithValidation.
    /// </summary>
    /// <param name="JObject">Parameter of type JsonObject.</param>
    /// <param name="TokenPath">Parameter of type Text contains the path members combined with the .-char.</param>
    /// <param name="RecordRef">Parameter of type RecordRef.</param>
    /// <param name="FieldNo">Parameter of type Integer.</param>
    internal procedure GetValueIntoFieldWithValidation(JObject: JsonObject; TokenPath: Text; var RecordRef: RecordRef; FieldNo: Integer)
    begin
        GetValueIntoFieldWithValidation(JObject.AsToken(), TokenPath, RecordRef, FieldNo);
    end;
    #endregion GetValueIntoFieldWithValidation
}