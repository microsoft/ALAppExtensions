// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 5683 "WebDAV Request Helper"
{
    Access = Internal;

    var
        Authorization: Interface "WebDAV Authorization";
        OperationNotSuccessfulErr: Label 'An error has occurred';

    procedure SetAuthorization(InitAuthorization: Interface "WebDAV Authorization")
    begin
        Authorization := InitAuthorization;
    end;

    [NonDebuggable]
    procedure MkCol(Uri: Text; CollectionName: Text) WebDAVOperationResponse: Codeunit "WebDAV Operation Response";
    begin
        WebDAVOperationResponse := SendRequest(PrepareRequestMsg('MKCOL', NormalizeUri(Uri) + CollectionName))
    end;

    [NonDebuggable]
    procedure Put(Uri: Text; HttpContent: HttpContent) WebDAVOperationResponse: Codeunit "WebDAV Operation Response";
    var
        RequestMessage: HttpRequestMessage;
    begin
        RequestMessage := PrepareRequestMsg(Enum::"Http Request Type"::PUT, Uri);
        RequestMessage.Content := HttpContent;
        WebDAVOperationResponse := SendRequest(RequestMessage);
    end;

    [NonDebuggable]
    procedure Get(Uri: Text) WebDAVOperationResponse: Codeunit "WebDAV Operation Response";
    begin
        WebDAVOperationResponse := SendRequest(PrepareRequestMsg(Enum::"Http Request Type"::GET, Uri))
    end;

    [NonDebuggable]
    procedure Delete(Uri: Text; MemberName: Text) WebDAVOperationResponse: Codeunit "WebDAV Operation Response";
    begin
        WebDAVOperationResponse := SendRequest(PrepareRequestMsg(Enum::"Http Request Type"::DELETE, NormalizeUri(Uri) + MemberName));
    end;

    [NonDebuggable]
    procedure Move(Uri: Text; DestinationUri: Text) WebDAVOperationResponse: Codeunit "WebDAV Operation Response";
    var
        RequestMessage: HttpRequestMessage;
        Headers: HttpHeaders;
    begin
        RequestMessage := PrepareRequestMsg('MOVE', Uri);
        RequestMessage.GetHeaders(Headers);

        Headers.Add('Destination', DestinationUri);
        WebDAVOperationResponse := SendRequest(RequestMessage);
    end;

    [NonDebuggable]
    procedure Copy(Uri: Text; DestinationUri: Text) WebDAVOperationResponse: Codeunit "WebDAV Operation Response";
    var
        RequestMessage: HttpRequestMessage;
        Headers: HttpHeaders;
    begin
        RequestMessage := PrepareRequestMsg('COPY', Uri);
        RequestMessage.GetHeaders(Headers);

        Headers.Add('Destination', DestinationUri);
        WebDAVOperationResponse := SendRequest(RequestMessage);
    end;

    [NonDebuggable]
    procedure Propfind(Uri: Text; Recursive: Boolean) WebDAVOperationResponse: Codeunit "WebDAV Operation Response";
    var
        WebDAVHttpContent: Codeunit "WebDAV Http Content";
        RequestMessage: HttpRequestMessage;
        Headers: HttpHeaders;
    begin
        WebDAVHttpContent.FromXML(PreparePropfindRequest());
        RequestMessage := PrepareRequestMsg('PROPFIND', Uri, WebDAVHttpContent);
        RequestMessage.GetHeaders(Headers);

        // TODO Depth = 0?
        // Recursive
        if Headers.Contains(GetDepth()) then
            Headers.Remove(GetDepth());
        if Recursive then
            Headers.Add(GetDepth(), 'infinity')
        else
            Headers.Add(GetDepth(), '1');

        WebDAVOperationResponse := SendRequest(RequestMessage);
    end;

    local procedure PrepareRequestMsg(HttpRequestType: Enum "Http Request Type"; Uri: Text): HttpRequestMessage
    begin
        exit(PrepareRequestMsg(Format(HttpRequestType), Uri));
    end;

    local procedure PrepareRequestMsg(HttpRequestType: Text; Uri: Text) RequestMessage: HttpRequestMessage
    begin
        RequestMessage.Method(HttpRequestType);
        RequestMessage.SetRequestUri(Uri);
    end;

    local procedure PrepareRequestMsg(HttpRequestType: Enum "Http Request Type"; Uri: Text; WebDAVHttpContent: Codeunit "WebDAV Http Content") RequestMessage: HttpRequestMessage
    begin
        exit(PrepareRequestMsg(Format(HttpRequestType), Uri, WebDAVHttpContent));
    end;

    local procedure PrepareRequestMsg(HttpRequestType: Text; Uri: Text; var WebDAVHttpContent: Codeunit "WebDAV Http Content") RequestMessage: HttpRequestMessage
    var
        Headers: HttpHeaders;
        HttpContent: HttpContent;
    begin
        RequestMessage.Method(HttpRequestType);
        RequestMessage.SetRequestUri(Uri);
        RequestMessage.GetHeaders(Headers);

        if WebDAVHttpContent.GetContentLength() = 0 then
            exit;

        HttpContent := WebDAVHttpContent.GetContent();
        HttpContent.GetHeaders(Headers);

        if Headers.Contains(GetContentType) then
            Headers.Remove(GetContentType);

        if WebDAVHttpContent.GetContentType() <> '' then
            Headers.Add(GetContentType, WebDAVHttpContent.GetContentType());

        RequestMessage.Content(HttpContent);
    end;

    local procedure SendRequest(HttpRequestMessage: HttpRequestMessage) OperationResponse: Codeunit "WebDAV Operation Response"
    var
        HttpResponseMessage: HttpResponseMessage;
        HttpClient: HttpClient;
        IsHandled: Boolean;
    begin
        OnBeforeSendRequest(HttpRequestMessage, OperationResponse, IsHandled, HttpRequestMessage.Method());
        if IsHandled then
            exit;

        Authorization.Authorize(HttpRequestMessage);
        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            Error(OperationNotSuccessfulErr);

        OperationResponse.SetHttpResponse(HttpResponseMessage);
    end;

    local procedure PreparePropfindRequest() XMLDoc: XmlDocument
    var
        Propfind: XmlElement;
        Prop: XmlElement;
        NameSpaceManager: XmlNamespaceManager;
    begin
        XMlDoc := XmlDocument.Create();
        XmlDoc.SetDeclaration(XmlDeclaration.Create('1.0', 'utf-8', 'yes'));

        Propfind := XmlElement.Create('propfind', 'DAV:');
        Propfind.Add(XmlAttribute.CreateNamespaceDeclaration('d', 'DAV:'));

        Prop := XmlElement.Create('prop', 'DAV:');
        Prop.Add(XmlElement.Create('displayname', 'DAV:'));
        Prop.Add(XmlElement.Create('resourcetype', 'DAV:'));
        Prop.Add(XmlElement.Create('getcontenttype', 'DAV:'));
        Prop.Add(XmlElement.Create('getcontentlength', 'DAV:'));
        Prop.Add(XmlElement.Create('creationdate', 'DAV:'));
        Prop.Add(XmlElement.Create('getlastmodified', 'DAV:'));

        Propfind.Add(Prop);
        XMlDoc.Add(Propfind);
    end;

    local procedure NormalizeUri(Uri: Text) NewUri: Text
    begin
        NewUri := Uri;
        if not Uri.EndsWith('/') then
            NewUri += '/';
        if NewUri = '/' then
            NewUri := '';
    end;

    local procedure GetContentType(): Text
    begin
        exit('Content-Type');
    end;

    local procedure GetDepth(): Text
    begin
        exit('Depth');
    end;

    [InternalEvent(false, true)]
    local procedure OnBeforeSendRequest(HttpRequestMessage: HttpRequestMessage; var WebDAVOperationResponse: Codeunit "WebDAV Operation Response"; var IsHandled: Boolean; Method: Text)
    begin
    end;
}