// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using System.Text;

codeunit 6385 SignUpHelpers
{
    Access = Internal;

    [NonDebuggable]
    procedure ParseJsonString(HttpContentResponse: HttpContent): Text
    var
        ResponseJObject: JsonObject;
        ResponseJson: Text;
        Result: Text;
        IsJsonResponse: Boolean;
    begin
        HttpContentResponse.ReadAs(Result);
        IsJsonResponse := ResponseJObject.ReadFrom(Result);
        if IsJsonResponse then
            ResponseJObject.WriteTo(ResponseJson)
        else
            exit('');

        if not TryInitJson(ResponseJson) then
            exit('');

        exit(Result);
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryInitJson(JsonTxt: Text)
    var
        JsonManagement: Codeunit "JSON Management";
    begin
        JSONManagement.InitializeObject(JsonTxt);
    end;

    [NonDebuggable]
    procedure GetJsonValueFromText(JsonText: Text; Path: Text) return: Text
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        if JObject.ReadFrom(JsonText) then
            if JObject.SelectToken(Path, JToken) then
                return := GetJsonValue(JToken.AsValue());
    end;

    [NonDebuggable]
    procedure GetJsonValue(JValue: JsonValue): Text
    begin
        if JValue.IsNull then
            exit('');
        if JValue.IsUndefined then
            exit('');
        exit(JValue.AsText());
    end;
}