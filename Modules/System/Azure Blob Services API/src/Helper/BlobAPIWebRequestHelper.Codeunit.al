// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9045 "Blob API Web Request Helper"
{
    Access = Internal;

    var
        ReadResponseFailedErr: Label 'Could not read response.';
        HttpResponseInfoErr: Label '%1.\\Response Code: %2 %3', Comment = '%1 = Default Error Message ; %2 = Status Code; %3 = Reason Phrase';

    // #region GET-Request
    procedure GetOperationAsText(var OperationObject: Codeunit "Blob API Operation Object"; var ResponseText: Text; OperationNotSuccessfulErr: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Response: HttpResponseMessage;
    begin
        OperationResponse := GetOperation(OperationObject, OperationNotSuccessfulErr);

        Response := OperationResponse.GetHttpResponse();

        if not Response.Content.ReadAs(ResponseText) then
            Error(ReadResponseFailedErr);
    end;

    procedure GetOperationAsStream(var OperationObject: Codeunit "Blob API Operation Object"; var Stream: InStream; OperationNotSuccessfulErr: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Response: HttpResponseMessage;
    begin
        OperationResponse := GetOperation(OperationObject, OperationNotSuccessfulErr);

        Response := OperationResponse.GetHttpResponse();

        if not Response.Content.ReadAs(Stream) then
            Error(ReadResponseFailedErr);
    end;

    local procedure GetOperation(var OperationObject: Codeunit "Blob API Operation Object"; OperationNotSuccessfulErr: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
    begin
        HandleHeaders(Enum::"Http Request Type"::GET, Client, OperationObject);

        RequestMsg := PrepareRequestMsg(OperationObject, Enum::"Http Request Type"::GET);

        OperationResponse := SendRequest(Client, RequestMsg, OperationNotSuccessfulErr);
    end;
    // #endregion GET-Request

    // #region HEAD-Request
    procedure HeadOperation(var OperationObject: Codeunit "Blob API Operation Object"; OperationNotSuccessfulErr: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
    begin
        HandleHeaders(Enum::"Http Request Type"::HEAD, Client, OperationObject);

        RequestMsg := PrepareRequestMsg(OperationObject, Enum::"Http Request Type"::HEAD);

        OperationResponse := SendRequest(Client, RequestMsg, OperationNotSuccessfulErr);
    end;
    // #endregion HEAD-Request

    // #region PUT-Request
    procedure PutOperation(var OperationObject: Codeunit "Blob API Operation Object"; OperationNotSuccessfulErr: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Content: HttpContent;
    begin
        OperationResponse := PutOperation(OperationObject, Content, OperationNotSuccessfulErr);
    end;

    procedure PutOperation(var OperationObject: Codeunit "Blob API Operation Object"; Content: HttpContent; OperationNotSuccessfulErr: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
    begin
        HandleHeaders(Enum::"Http Request Type"::PUT, Client, OperationObject);

        RequestMsg := PrepareRequestMsg(OperationObject, Enum::"Http Request Type"::PUT, Content);

        OperationResponse := SendRequest(Client, RequestMsg, OperationNotSuccessfulErr);
    end;
    // #endregion PUT-Request

    // #region DELETE-Request
    procedure DeleteOperation(var OperationObject: Codeunit "Blob API Operation Object"; OperationNotSuccessfulErr: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
    begin
        HandleHeaders(Enum::"Http Request Type"::DELETE, Client, OperationObject);

        RequestMsg := PrepareRequestMsg(OperationObject, Enum::"Http Request Type"::DELETE);

        OperationResponse := SendRequest(Client, RequestMsg, OperationNotSuccessfulErr);
    end;
    // #endregion DELETE-Request

    // #region POST-Request
    procedure PostOperation(var OperationObject: Codeunit "Blob API Operation Object"; OperationNotSuccessfulErr: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Content: HttpContent;
    begin
        OperationResponse := PostOperation(OperationObject, Content, OperationNotSuccessfulErr);
    end;

    procedure PostOperation(var OperationObject: Codeunit "Blob API Operation Object"; Content: HttpContent; OperationNotSuccessfulErr: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
    begin
        HandleHeaders(Enum::"Http Request Type"::POST, Client, OperationObject);

        RequestMsg := PrepareRequestMsg(OperationObject, Enum::"Http Request Type"::POST, Content);

        OperationResponse := SendRequest(Client, RequestMsg, OperationNotSuccessfulErr);
    end;
    // #endregion POST-Request

    // #region OPTIONS-Request

    procedure OptionsOperation(var OperationObject: Codeunit "Blob API Operation Object"; OperationNotSuccessfulErr: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
    begin
        HandleHeaders(Enum::"Http Request Type"::OPTIONS, Client, OperationObject);

        RequestMsg := PrepareRequestMsg(OperationObject, Enum::"Http Request Type"::OPTIONS);

        OperationResponse := SendRequest(Client, RequestMsg, OperationNotSuccessfulErr);
    end;
    // #endregion OPTIONS-Request

    // #region Helper functions
    local procedure HandleHeaders(HttpRequestType: Enum "Http Request Type"; var Client: HttpClient; var OperationObject: Codeunit "Blob API Operation Object")
    var
        BlobAPIHttpHeaderHelper: Codeunit "Blob API HttpHeader Helper";
    begin
        BlobAPIHttpHeaderHelper.HandleHeaders(HttpRequestType, Client, OperationObject);
    end;

    local procedure PrepareRequestMsg(var OperationObject: Codeunit "Blob API Operation Object"; HttpRequestType: Enum "Http Request Type") RequestMsg: HttpRequestMessage
    begin
        // Prepare HttpRequestMessage
        RequestMsg.Method(Format(HttpRequestType));
        RequestMsg.SetRequestUri(OperationObject.ConstructUri());
    end;

    local procedure PrepareRequestMsg(var OperationObject: Codeunit "Blob API Operation Object"; HttpRequestType: Enum "Http Request Type"; Content: HttpContent) RequestMsg: HttpRequestMessage
    var
        BlobAPIHttpContentHelper: Codeunit "Blob API HttpContent Helper";
        BlobAPIHttpHeaderHelper: Codeunit "Blob API HttpHeader Helper";
    begin
        // Prepare HttpRequestMessage
        RequestMsg.Method(Format(HttpRequestType));
        if BlobAPIHttpContentHelper.ContentSet(Content) or BlobAPIHttpHeaderHelper.HandleContentHeaders(Content, OperationObject) then
            RequestMsg.Content := Content;
        RequestMsg.SetRequestUri(OperationObject.ConstructUri());
    end;

    local procedure SendRequest(var Client: HttpClient; RequestMsg: HttpRequestMessage; OperationNotSuccessfulErr: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        DebugText: Text;
        Response: HttpResponseMessage;
    begin
        // Send Request    
        Client.Send(RequestMsg, Response);
        Response.Content.ReadAs(DebugText);
        if not Response.IsSuccessStatusCode then
            Error(HttpResponseInfoErr, OperationNotSuccessfulErr, Response.HttpStatusCode, Response.ReasonPhrase);
        OperationResponse.SetHttpResponse(Response);
    end;
    // #endregion Helper functions
}