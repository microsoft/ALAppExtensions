// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using System.Reflection;
using Microsoft.Utilities;
using System.Integration;

codeunit 6385 HelpersImpl
{
    Access = Internal;

    var
        ClaimTypeTxt: Label 'exp', Locked = true;

    #region public methods

    [NonDebuggable]
    procedure ParseJsonString(HttpContent: HttpContent): Text
    var
        JsonObject: JsonObject;
        Content: Text;
    begin
        if not HttpContent.ReadAs(Content) then
            exit;

        if JsonObject.ReadFrom(Content) then
            exit(Content);
    end;

    [NonDebuggable]
    procedure GetJsonValueFromText(JsonText: Text; Path: Text): Text
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if JsonObject.ReadFrom(JsonText) then
            if JsonObject.SelectToken(Path, JsonToken) then
                exit(this.GetJsonValue(JsonToken.AsValue()));
    end;

    procedure IsTokenValid(InToken: SecretText): Boolean
    begin
        exit(this.GetTokenDateTimeValue(InToken, this.ClaimTypeTxt) > CurrentDateTime());
    end;

    #endregion

    #region local methods

    local procedure GetTokenDateTimeValue(InToken: SecretText; ClaimType: Text): DateTime
    var
        TypeHelper: Codeunit "Type Helper";
        Timestamp: Decimal;
    begin
        if Evaluate(Timestamp, this.GetValueFromToken(InToken, ClaimType)) then
            exit(TypeHelper.EvaluateUnixTimestamp(Timestamp));
    end;

    [NonDebuggable]
    local procedure GetValueFromToken(InToken: SecretText; ClaimType: Text): Text
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        SOAPWebServiceRequestMgt: Codeunit "SOAP Web Service Request Mgt.";
    begin
        if InToken.IsEmpty() then
            exit;

        TempNameValueBuffer.DeleteAll();
        SOAPWebServiceRequestMgt.GetTokenDetailsAsNameBuffer(InToken, TempNameValueBuffer);
        TempNameValueBuffer.Reset();
        TempNameValueBuffer.SetRange(Name, ClaimType);
        if TempNameValueBuffer.FindFirst() then
            exit(TempNameValueBuffer.Value);
    end;

    [NonDebuggable]
    local procedure GetJsonValue(JsonValue: JsonValue): Text
    begin
        if JsonValue.IsNull() then
            exit;

        if JsonValue.IsUndefined() then
            exit;

        exit(JsonValue.AsText());
    end;

    #endregion
}