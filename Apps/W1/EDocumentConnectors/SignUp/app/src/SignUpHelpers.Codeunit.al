// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.Utilities;
using System.DateTime;
using System.Integration;
using Microsoft.eServices.EDocument;

codeunit 6444 "SignUp Helpers"
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

    procedure IsExFlowEInvoicing(EDocumentServiceCodeFilter: Text): Boolean
    var
        EDocumentService: Record "E-Document Service";
    begin
        if EDocumentServiceCodeFilter = '' then
            exit;


        EDocumentService.SetFilter(Code, EDocumentServiceCodeFilter);
        EDocumentService.SetRange("Service Integration V2", EDocumentService."Service Integration V2"::"ExFlow E-Invoicing");
        exit(not EDocumentService.IsEmpty());
    end;

    #endregion

    #region local methods

    local procedure GetTokenDateTimeValue(InToken: SecretText; ClaimType: Text): DateTime
    var
        UnixTimestamp: Codeunit "Unix Timestamp";
        Timestamp: Decimal;
    begin
        if Evaluate(Timestamp, this.GetValueFromToken(InToken, ClaimType)) then
            exit(UnixTimestamp.EvaluateTimestamp(Timestamp));
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