// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9045 "ABS Web Request Helper"
{
    Access = Internal;

    var
        ReadResponseFailedErr: Label 'Could not read response.';
        HttpResponseInfoErr: Label '%1.\\Response Code: %2 %3', Comment = '%1 = Default Error Message ; %2 = Status Code; %3 = Reason Phrase';

    #region GET Request
    [NonDebuggable]
    procedure GetOperationAsText(var ABSOperationPayload: Codeunit "ABS Operation Payload"; var ResponseText: Text; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
    begin
        ABSOperationResponse := GetOperation(ABSOperationPayload, OperationNotSuccessfulErr);


        if not ABSOperationResponse.GetResultAsText(ResponseText) then
            Error(ReadResponseFailedErr);

        exit(ABSOperationResponse);
    end;

    [NonDebuggable]
    procedure GetOperationAsStream(var ABSOperationPayload: Codeunit "ABS Operation Payload"; var InStream: InStream; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
    begin
        ABSOperationResponse := GetOperation(ABSOperationPayload, OperationNotSuccessfulErr);

        if not ABSOperationResponse.GetResultAsStream(InStream) then
            Error(ReadResponseFailedErr);

        exit(ABSOperationResponse);
    end;

    [NonDebuggable]
    local procedure GetOperation(var ABSOperationPayload: Codeunit "ABS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
    begin
        PrepareRequestMsg(HttpRequestMessage, ABSOperationPayload, Enum::"Http Request Type"::GET);

        ABSOperationResponse := SendRequest(HttpClient, HttpRequestMessage, OperationNotSuccessfulErr);
        exit(ABSOperationResponse);
    end;
    #endregion

    #region HEAD-Request
    [NonDebuggable]
    procedure HeadOperation(var ABSOperationPayload: Codeunit "ABS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
    begin
        PrepareRequestMsg(HttpRequestMessage, ABSOperationPayload, Enum::"Http Request Type"::HEAD);

        ABSOperationResponse := SendRequest(HttpClient, HttpRequestMessage, OperationNotSuccessfulErr);
        exit(ABSOperationResponse);
    end;
    #endregion HEAD-Request

    #region PUT-Request
    [NonDebuggable]
    procedure PutOperation(var ABSOperationPayload: Codeunit "ABS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        HttpContent: HttpContent;
    begin
        ABSOperationResponse := PutOperation(ABSOperationPayload, HttpContent, OperationNotSuccessfulErr);
        exit(ABSOperationResponse);
    end;

    [NonDebuggable]
    procedure PutOperation(var ABSOperationPayload: Codeunit "ABS Operation Payload"; HttpContent: HttpContent; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
    begin
        PrepareRequestMsg(HttpRequestMessage, ABSOperationPayload, Enum::"Http Request Type"::PUT, HttpContent);

        ABSOperationResponse := SendRequest(HttpClient, HttpRequestMessage, OperationNotSuccessfulErr);
        exit(ABSOperationResponse);
    end;
    #endregion

    #region DELETE-Request
    [NonDebuggable]
    procedure DeleteOperation(var ABSOperationPayload: Codeunit "ABS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
    begin
        PrepareRequestMsg(HttpRequestMessage, ABSOperationPayload, Enum::"Http Request Type"::DELETE);

        ABSOperationResponse := SendRequest(HttpClient, HttpRequestMessage, OperationNotSuccessfulErr);
        exit(ABSOperationResponse);
    end;
    #endregion

    #region POST-Request
    [NonDebuggable]
    procedure PostOperation(var ABSOperationPayload: Codeunit "ABS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        HttpContent: HttpContent;
    begin
        ABSOperationResponse := PostOperation(ABSOperationPayload, HttpContent, OperationNotSuccessfulErr);
        exit(ABSOperationResponse);
    end;

    [NonDebuggable]
    procedure PostOperation(var ABSOperationPayload: Codeunit "ABS Operation Payload"; HttpContent: HttpContent; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
    begin
        PrepareRequestMsg(HttpRequestMessage, ABSOperationPayload, Enum::"Http Request Type"::POST, HttpContent);

        ABSOperationResponse := SendRequest(HttpClient, HttpRequestMessage, OperationNotSuccessfulErr);
        exit(ABSOperationResponse);
    end;
    #endregion

    #region OPTIONS-Request
    [NonDebuggable]
    procedure OptionsOperation(var ABSOperationPayload: Codeunit "ABS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
    begin
        PrepareRequestMsg(HttpRequestMessage, ABSOperationPayload, Enum::"Http Request Type"::OPTIONS);

        ABSOperationResponse := SendRequest(HttpClient, HttpRequestMessage, OperationNotSuccessfulErr);
        exit(ABSOperationResponse);
    end;
    #endregion

    #region Helper functions
    [NonDebuggable]
    local procedure PrepareRequestMsg(var HttpRequestMessage: HttpRequestMessage; ABSOperationPayload: Codeunit "ABS Operation Payload"; HttpRequestType: Enum "Http Request Type")
    var
        ABSHttpHeaderHelper: Codeunit "ABS HttpHeader Helper";
        Authorization: Interface "Storage Service Authorization";
    begin
        HttpRequestMessage.Method(Format(HttpRequestType));
        HttpRequestMessage.SetRequestUri(ABSOperationPayload.ConstructUri());
        ABSHttpHeaderHelper.HandleRequestHeaders(HttpRequestType, HttpRequestMessage, ABSOperationPayload);

        Authorization := ABSOperationPayload.GetAuthorization();
        Authorization.Authorize(HttpRequestMessage, ABSOperationPayload.GetStorageAccountName());
    end;

    [NonDebuggable]
    local procedure PrepareRequestMsg(var HttpRequestMessage: HttpRequestMessage; var ABSOperationPayload: Codeunit "ABS Operation Payload"; HttpRequestType: Enum "Http Request Type"; HttpContent: HttpContent)
    var
        ABSHttpContentHelper: Codeunit "ABS HttpContent Helper";
        ABSHttpHeaderHelper: Codeunit "ABS HttpHeader Helper";
    begin
        if ABSHttpContentHelper.ContentSet(HttpContent) or ABSHttpHeaderHelper.HandleContentHeaders(HttpContent, ABSOperationPayload) then
            HttpRequestMessage.Content := HttpContent;

        PrepareRequestMsg(HttpRequestMessage, ABSOperationPayload, HttpRequestType);
    end;

    [NonDebuggable]
    local procedure SendRequest(var HttpClient: HttpClient; HttpRequestMessage: HttpRequestMessage; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        HttpResponseMessage: HttpResponseMessage;
    begin
        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            Error(OperationNotSuccessfulErr);

        if not HttpResponseMessage.IsSuccessStatusCode() then
            ABSOperationResponse.SetError(StrSubstNo(HttpResponseInfoErr, OperationNotSuccessfulErr, HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase));

        ABSOperationResponse.SetHttpResponse(HttpResponseMessage);
        exit(ABSOperationResponse);
    end;
    #endregion
}