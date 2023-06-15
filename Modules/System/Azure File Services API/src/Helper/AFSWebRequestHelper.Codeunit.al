// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8954 "AFS Web Request Helper"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        ReadResponseFailedErr: Label 'Could not read response.';
        HttpResponseInfoErr: Label '%1.\\Response Code: %2 %3', Comment = '%1 = Default Error Message ; %2 = Status Code; %3 = Reason Phrase';

    [NonDebuggable]
    procedure GetOperationAsText(var AFSOperationPayload: Codeunit "AFS Operation Payload"; var ResponseText: Text; OperationNotSuccessfulErr: Text): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
    begin
        AFSOperationResponse := GetOperation(AFSOperationPayload, OperationNotSuccessfulErr);


        if not AFSOperationResponse.GetResultAsText(ResponseText) then
            Error(ReadResponseFailedErr);

        exit(AFSOperationResponse);
    end;

    [NonDebuggable]
    procedure GetOperationAsStream(var AFSOperationPayload: Codeunit "AFS Operation Payload"; var InStream: InStream; OperationNotSuccessfulErr: Text): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
    begin
        AFSOperationResponse := GetOperation(AFSOperationPayload, OperationNotSuccessfulErr);

        if not AFSOperationResponse.GetResultAsStream(InStream) then
            Error(ReadResponseFailedErr);

        exit(AFSOperationResponse);
    end;

    [NonDebuggable]
    local procedure GetOperation(var AFSOperationPayload: Codeunit "AFS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
    begin
        PrepareRequestMsg(HttpRequestMessage, AFSOperationPayload, Enum::"Http Request Type"::GET);

        AFSOperationResponse := SendRequest(HttpClient, HttpRequestMessage, OperationNotSuccessfulErr);
        exit(AFSOperationResponse);
    end;

    [NonDebuggable]
    procedure HeadOperation(var AFSOperationPayload: Codeunit "AFS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
    begin
        PrepareRequestMsg(HttpRequestMessage, AFSOperationPayload, Enum::"Http Request Type"::HEAD);

        AFSOperationResponse := SendRequest(HttpClient, HttpRequestMessage, OperationNotSuccessfulErr);
        exit(AFSOperationResponse);
    end;

    [NonDebuggable]
    procedure PutOperation(var AFSOperationPayload: Codeunit "AFS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        HttpContent: HttpContent;
    begin
        AFSOperationResponse := PutOperation(AFSOperationPayload, HttpContent, OperationNotSuccessfulErr);
        exit(AFSOperationResponse);
    end;

    [NonDebuggable]
    procedure PutOperation(var AFSOperationPayload: Codeunit "AFS Operation Payload"; HttpContent: HttpContent; OperationNotSuccessfulErr: Text): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
    begin
        PrepareRequestMsg(HttpRequestMessage, AFSOperationPayload, Enum::"Http Request Type"::PUT, HttpContent);

        AFSOperationResponse := SendRequest(HttpClient, HttpRequestMessage, OperationNotSuccessfulErr);
        exit(AFSOperationResponse);
    end;

    [NonDebuggable]
    procedure DeleteOperation(var AFSOperationPayload: Codeunit "AFS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
    begin
        PrepareRequestMsg(HttpRequestMessage, AFSOperationPayload, Enum::"Http Request Type"::DELETE);

        AFSOperationResponse := SendRequest(HttpClient, HttpRequestMessage, OperationNotSuccessfulErr);
        exit(AFSOperationResponse);
    end;

    [NonDebuggable]
    procedure PostOperation(var AFSOperationPayload: Codeunit "AFS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        HttpContent: HttpContent;
    begin
        AFSOperationResponse := PostOperation(AFSOperationPayload, HttpContent, OperationNotSuccessfulErr);
        exit(AFSOperationResponse);
    end;

    [NonDebuggable]
    procedure PostOperation(var AFSOperationPayload: Codeunit "AFS Operation Payload"; HttpContent: HttpContent; OperationNotSuccessfulErr: Text): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
    begin
        PrepareRequestMsg(HttpRequestMessage, AFSOperationPayload, Enum::"Http Request Type"::POST, HttpContent);

        AFSOperationResponse := SendRequest(HttpClient, HttpRequestMessage, OperationNotSuccessfulErr);
        exit(AFSOperationResponse);
    end;

    [NonDebuggable]
    procedure OptionsOperation(var AFSOperationPayload: Codeunit "AFS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
    begin
        PrepareRequestMsg(HttpRequestMessage, AFSOperationPayload, Enum::"Http Request Type"::OPTIONS);

        AFSOperationResponse := SendRequest(HttpClient, HttpRequestMessage, OperationNotSuccessfulErr);
        exit(AFSOperationResponse);
    end;

    [NonDebuggable]
    local procedure PrepareRequestMsg(var HttpRequestMessage: HttpRequestMessage; var AFSOperationPayload: Codeunit "AFS Operation Payload"; HttpRequestType: Enum "Http Request Type")
    var
        AFSHttpHeaderHelper: Codeunit "AFS HttpHeader Helper";
        Authorization: Interface "Storage Service Authorization";
    begin
        HttpRequestMessage.Method(Format(HttpRequestType));
        HttpRequestMessage.SetRequestUri(AFSOperationPayload.ConstructUri());
        AFSHttpHeaderHelper.HandleRequestHeaders(HttpRequestType, HttpRequestMessage, AFSOperationPayload);

        Authorization := AFSOperationPayload.GetAuthorization();
        Authorization.Authorize(HttpRequestMessage, AFSOperationPayload.GetStorageAccountName());
    end;

    [NonDebuggable]
    local procedure PrepareRequestMsg(var HttpRequestMessage: HttpRequestMessage; var AFSOperationPayload: Codeunit "AFS Operation Payload"; HttpRequestType: Enum "Http Request Type"; HttpContent: HttpContent)
    var
        AFSHttpContentHelper: Codeunit "AFS HttpContent Helper";
        AFSHttpHeaderHelper: Codeunit "AFS HttpHeader Helper";
    begin
        if AFSHttpContentHelper.ContentSet(HttpContent) or AFSHttpHeaderHelper.HandleContentHeaders(HttpContent, AFSOperationPayload) then
            HttpRequestMessage.Content := HttpContent;

        PrepareRequestMsg(HttpRequestMessage, AFSOperationPayload, HttpRequestType);
    end;

    [NonDebuggable]
    local procedure SendRequest(var HttpClient: HttpClient; HttpRequestMessage: HttpRequestMessage; OperationNotSuccessfulErr: Text): Codeunit "AFS Operation Response"
    var
        AFSOperationResponse: Codeunit "AFS Operation Response";
        HttpResponseMessage: HttpResponseMessage;
    begin
        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            Error(OperationNotSuccessfulErr);

        if not HttpResponseMessage.IsSuccessStatusCode() then
            AFSOperationResponse.SetError(StrSubstNo(HttpResponseInfoErr, OperationNotSuccessfulErr, HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase));

        AFSOperationResponse.SetHttpResponse(HttpResponseMessage);
        exit(AFSOperationResponse);
    end;
}