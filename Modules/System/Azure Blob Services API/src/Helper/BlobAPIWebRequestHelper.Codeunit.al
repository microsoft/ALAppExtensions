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
    procedure GetOperationAsText(var OperationObject: Codeunit "Blob API Operation Object"; var ResponseText: Text; OperationNotSuccessfulErr: Text)
    var
        Response: HttpResponseMessage;
    begin
        GetOperation(OperationObject, Response, OperationNotSuccessfulErr);

        if not Response.Content.ReadAs(ResponseText) then
            Error(ReadResponseFailedErr);
    end;

    procedure GetOperationAsStream(var OperationObject: Codeunit "Blob API Operation Object"; var Stream: InStream; OperationNotSuccessfulErr: Text)
    var
        Response: HttpResponseMessage;
    begin
        GetOperation(OperationObject, Response, OperationNotSuccessfulErr);

        if not Response.Content.ReadAs(Stream) then
            Error(ReadResponseFailedErr);
    end;

    local procedure GetOperation(var OperationObject: Codeunit "Blob API Operation Object"; var Response: HttpResponseMessage; OperationNotSuccessfulErr: Text)
    var
        Client: HttpClient;
        HttpRequestType: Enum "Http Request Type";
        RequestMsg: HttpRequestMessage;
    begin
        HandleHeaders(HttpRequestType::GET, Client, OperationObject);

        PrepareRequestMsg(OperationObject, HttpRequestType::GET, RequestMsg);

        SendRequest(Client, Response, OperationObject, RequestMsg, OperationNotSuccessfulErr);
    end;
    // #endregion GET-Request

    // #region HEAD-Request
    procedure HeadOperation(var OperationObject: Codeunit "Blob API Operation Object"; var Response: HttpResponseMessage; OperationNotSuccessfulErr: Text)
    var
        Client: HttpClient;
        HttpRequestType: Enum "Http Request Type";
        RequestMsg: HttpRequestMessage;
    begin
        HandleHeaders(HttpRequestType::HEAD, Client, OperationObject);

        PrepareRequestMsg(OperationObject, HttpRequestType::HEAD, RequestMsg);

        SendRequest(Client, Response, OperationObject, RequestMsg, OperationNotSuccessfulErr);
    end;
    // #endregion HEAD-Request

    // #region PUT-Request
    procedure PutOperation(var OperationObject: Codeunit "Blob API Operation Object"; OperationNotSuccessfulErr: Text)
    var
        Content: HttpContent;
    begin
        PutOperation(OperationObject, Content, OperationNotSuccessfulErr);
    end;

    procedure PutOperation(var OperationObject: Codeunit "Blob API Operation Object"; Content: HttpContent; OperationNotSuccessfulErr: Text)
    var
        Response: HttpResponseMessage;
    begin
        PutOperation(OperationObject, Content, Response, OperationNotSuccessfulErr);
    end;

    local procedure PutOperation(var OperationObject: Codeunit "Blob API Operation Object"; Content: HttpContent; var Response: HttpResponseMessage; OperationNotSuccessfulErr: Text)
    var
        Client: HttpClient;
        HttpRequestType: Enum "Http Request Type";
        RequestMsg: HttpRequestMessage;
    begin
        HandleHeaders(HttpRequestType::PUT, Client, OperationObject);

        PrepareRequestMsg(OperationObject, HttpRequestType::PUT, Content, RequestMsg);

        SendRequest(Client, Response, OperationObject, RequestMsg, OperationNotSuccessfulErr);
    end;
    // #endregion PUT-Request

    // #region DELETE-Request
    procedure DeleteOperation(var OperationObject: Codeunit "Blob API Operation Object"; OperationNotSuccessfulErr: Text)
    var
        Response: HttpResponseMessage;
    begin
        DeleteOperation(OperationObject, Response, OperationNotSuccessfulErr);
    end;

    procedure DeleteOperation(var OperationObject: Codeunit "Blob API Operation Object"; var Response: HttpResponseMessage; OperationNotSuccessfulErr: Text)
    var
        Client: HttpClient;
        HttpRequestType: Enum "Http Request Type";
        RequestMsg: HttpRequestMessage;
    begin
        HandleHeaders(HttpRequestType::DELETE, Client, OperationObject);

        PrepareRequestMsg(OperationObject, HttpRequestType::DELETE, RequestMsg);

        SendRequest(Client, Response, OperationObject, RequestMsg, OperationNotSuccessfulErr);
    end;
    // #endregion DELETE-Request

    // #region POST-Request
    procedure PostOperation(var OperationObject: Codeunit "Blob API Operation Object"; OperationNotSuccessfulErr: Text)
    var
        Content: HttpContent;
    begin
        PostOperation(OperationObject, Content, OperationNotSuccessfulErr);
    end;

    procedure PostOperation(var OperationObject: Codeunit "Blob API Operation Object"; Content: HttpContent; OperationNotSuccessfulErr: Text)
    var
        Response: HttpResponseMessage;
    begin
        PostOperation(OperationObject, Content, Response, OperationNotSuccessfulErr);
    end;

    procedure PostOperation(var OperationObject: Codeunit "Blob API Operation Object"; Content: HttpContent; var Response: HttpResponseMessage; OperationNotSuccessfulErr: Text)
    var
        Client: HttpClient;
        HttpRequestType: Enum "Http Request Type";
        RequestMsg: HttpRequestMessage;
    begin
        HandleHeaders(HttpRequestType::POST, Client, OperationObject);

        PrepareRequestMsg(OperationObject, HttpRequestType::POST, Content, RequestMsg);

        SendRequest(Client, Response, OperationObject, RequestMsg, OperationNotSuccessfulErr);
    end;
    // #endregion POST-Request

    // #region OPTIONS-Request
    procedure OptionsOperation(var OperationObject: Codeunit "Blob API Operation Object"; OperationNotSuccessfulErr: Text)
    var
        Response: HttpResponseMessage;
    begin
        OptionsOperation(OperationObject, Response, OperationNotSuccessfulErr);
    end;

    procedure OptionsOperation(var OperationObject: Codeunit "Blob API Operation Object"; var Response: HttpResponseMessage; OperationNotSuccessfulErr: Text)
    var
        Client: HttpClient;
        HttpRequestType: Enum "Http Request Type";
        RequestMsg: HttpRequestMessage;
    begin
        HandleHeaders(HttpRequestType::OPTIONS, Client, OperationObject);

        PrepareRequestMsg(OperationObject, HttpRequestType::OPTIONS, RequestMsg);

        SendRequest(Client, Response, OperationObject, RequestMsg, OperationNotSuccessfulErr);
    end;
    // #endregion OPTIONS-Request

    // #region Helper functions
    local procedure HandleHeaders(HttpRequestType: Enum "Http Request Type"; var Client: HttpClient; var OperationObject: Codeunit "Blob API Operation Object")
    var
        BlobAPIHttpHeaderHelper: Codeunit "Blob API HttpHeader Helper";
    begin
        BlobAPIHttpHeaderHelper.HandleHeaders(HttpRequestType, Client, OperationObject);
    end;

    local procedure PrepareRequestMsg(var OperationObject: Codeunit "Blob API Operation Object"; HttpRequestType: Enum "Http Request Type"; var RequestMsg: HttpRequestMessage)
    begin
        // Prepare HttpRequestMessage
        RequestMsg.Method(Format(HttpRequestType));
        RequestMsg.SetRequestUri(OperationObject.ConstructUri());
    end;

    local procedure PrepareRequestMsg(var OperationObject: Codeunit "Blob API Operation Object"; HttpRequestType: Enum "Http Request Type"; Content: HttpContent; var RequestMsg: HttpRequestMessage)
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

    local procedure SendRequest(var Client: HttpClient; var Response: HttpResponseMessage; var OperationObject: Codeunit "Blob API Operation Object"; RequestMsg: HttpRequestMessage; OperationNotSuccessfulErr: Text)
    var
        DebugText: Text;
    begin
        // Send Request    
        Client.Send(RequestMsg, Response);
        OperationObject.SetHttpResponse(Response);
        Response.Content.ReadAs(DebugText);
        if not Response.IsSuccessStatusCode then
            Error(HttpResponseInfoErr, OperationNotSuccessfulErr, Response.HttpStatusCode, Response.ReasonPhrase);
    end;
    // #endregion Helper functions
}