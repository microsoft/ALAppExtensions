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
    procedure GetOperationAsText(var OperationPayload: Codeunit "ABS Operation Payload"; var ResponseText: Text; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
    begin
        OperationResponse := GetOperation(OperationPayload, OperationNotSuccessfulErr);


        if not OperationResponse.GetResultAsText(ResponseText) then
            Error(ReadResponseFailedErr);

        exit(OperationResponse);
    end;

    [NonDebuggable]
    procedure GetOperationAsStream(var OperationPayload: Codeunit "ABS Operation Payload"; var Stream: InStream; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
    begin
        OperationResponse := GetOperation(OperationPayload, OperationNotSuccessfulErr);

        if not OperationResponse.GetResultAsStream(Stream) then
            Error(ReadResponseFailedErr);

        exit(OperationResponse);
    end;

    [NonDebuggable]
    local procedure GetOperation(var OperationPayload: Codeunit "ABS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
    begin
        PrepareRequestMsg(RequestMsg, OperationPayload, Enum::"Http Request Type"::GET);

        OperationResponse := SendRequest(Client, RequestMsg, OperationNotSuccessfulErr);
        exit(OperationResponse);
    end;
    #endregion

    #region HEAD-Request
    [NonDebuggable]
    procedure HeadOperation(var OperationPayload: Codeunit "ABS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
    begin
        PrepareRequestMsg(RequestMsg, OperationPayload, Enum::"Http Request Type"::HEAD);

        OperationResponse := SendRequest(Client, RequestMsg, OperationNotSuccessfulErr);
        exit(OperationResponse);
    end;
    #endregion HEAD-Request

    #region PUT-Request
    [NonDebuggable]
    procedure PutOperation(var OperationPayload: Codeunit "ABS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Content: HttpContent;
    begin
        OperationResponse := PutOperation(OperationPayload, Content, OperationNotSuccessfulErr);
        exit(OperationResponse);
    end;

    [NonDebuggable]
    procedure PutOperation(var OperationPayload: Codeunit "ABS Operation Payload"; Content: HttpContent; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
    begin
        PrepareRequestMsg(RequestMsg, OperationPayload, Enum::"Http Request Type"::PUT, Content);

        OperationResponse := SendRequest(Client, RequestMsg, OperationNotSuccessfulErr);
        exit(OperationResponse);
    end;
    #endregion

    #region DELETE-Request
    [NonDebuggable]
    procedure DeleteOperation(var OperationPayload: Codeunit "ABS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
    begin
        PrepareRequestMsg(RequestMsg, OperationPayload, Enum::"Http Request Type"::DELETE);

        OperationResponse := SendRequest(Client, RequestMsg, OperationNotSuccessfulErr);
        exit(OperationResponse);
    end;
    #endregion

    #region POST-Request
    [NonDebuggable]
    procedure PostOperation(var OperationPayload: Codeunit "ABS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Content: HttpContent;
    begin
        OperationResponse := PostOperation(OperationPayload, Content, OperationNotSuccessfulErr);
        exit(OperationResponse);
    end;

    [NonDebuggable]
    procedure PostOperation(var OperationPayload: Codeunit "ABS Operation Payload"; Content: HttpContent; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
    begin
        PrepareRequestMsg(RequestMsg, OperationPayload, Enum::"Http Request Type"::POST, Content);

        OperationResponse := SendRequest(Client, RequestMsg, OperationNotSuccessfulErr);
        exit(OperationResponse);
    end;
    #endregion

    #region OPTIONS-Request
    [NonDebuggable]
    procedure OptionsOperation(var OperationPayload: Codeunit "ABS Operation Payload"; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
    begin
        PrepareRequestMsg(RequestMsg, OperationPayload, Enum::"Http Request Type"::OPTIONS);

        OperationResponse := SendRequest(Client, RequestMsg, OperationNotSuccessfulErr);
        exit(OperationResponse);
    end;
    #endregion

    #region Helper functions
    [NonDebuggable]
    local procedure PrepareRequestMsg(var RequestMsg: HttpRequestMessage; OperationPayload: Codeunit "ABS Operation Payload"; HttpRequestType: Enum "Http Request Type")
    var
        BlobAPIHttpHeaderHelper: Codeunit "ABS HttpHeader Helper";
        Authorization: Interface "Storage Service Authorization";
    begin
        RequestMsg.Method(Format(HttpRequestType));
        RequestMsg.SetRequestUri(OperationPayload.ConstructUri());
        BlobAPIHttpHeaderHelper.HandleRequestHeaders(HttpRequestType, RequestMsg, OperationPayload);

        Authorization := OperationPayload.GetAuthorization();
        Authorization.Authorize(RequestMsg, OperationPayload.GetStorageAccountName());
    end;

    [NonDebuggable]
    local procedure PrepareRequestMsg(var RequestMsg: HttpRequestMessage; var OperationPayload: Codeunit "ABS Operation Payload"; HttpRequestType: Enum "Http Request Type"; Content: HttpContent)
    var
        BlobAPIHttpContentHelper: Codeunit "ABS HttpContent Helper";
        BlobAPIHttpHeaderHelper: Codeunit "ABS HttpHeader Helper";
    begin
        if BlobAPIHttpContentHelper.ContentSet(Content) or BlobAPIHttpHeaderHelper.HandleContentHeaders(Content, OperationPayload) then
            RequestMsg.Content := Content;

        PrepareRequestMsg(RequestMsg, OperationPayload, HttpRequestType);
    end;

    [NonDebuggable]
    local procedure SendRequest(var Client: HttpClient; RequestMsg: HttpRequestMessage; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Response: HttpResponseMessage;
    begin
        if not Client.Send(RequestMsg, Response) then
            Error(OperationNotSuccessfulErr);

        if not Response.IsSuccessStatusCode() then
            OperationResponse.SetError(StrSubstNo(HttpResponseInfoErr, OperationNotSuccessfulErr, Response.HttpStatusCode, Response.ReasonPhrase));

        OperationResponse.SetHttpResponse(Response);
        exit(OperationResponse);
    end;
    #endregion
}