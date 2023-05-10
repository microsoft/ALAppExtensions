// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9109 "SharePoint Request Helper"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        HttpClient: HttpClient;
        Authorization: Interface "SharePoint Authorization";
        OperationNotSuccessfulErr: Label 'An error has occurred';
        UserAgentLbl: Label 'NONISV|%1|Dynamics 365 Business Central - %2/%3', Locked = true, Comment = '%1 = App Publisher; %2 = App Name; %3 = App Version';

    procedure SetAuthorization(Auth: Interface "SharePoint Authorization")
    begin
        Authorization := Auth;
    end;

    procedure Get(SharePointUriBuilder: Codeunit "SharePoint Uri Builder") OperationResponse: Codeunit "SharePoint Operation Response"
    begin
        OperationResponse := SendRequest(PrepareRequestMsg("Http Request Type"::GET, SharePointUriBuilder));
    end;

    procedure Post(SharePointUriBuilder: Codeunit "SharePoint Uri Builder") OperationResponse: Codeunit "SharePoint Operation Response"
    var
        SharePointHttpContent: Codeunit "SharePoint Http Content";
    begin
        OperationResponse := SendRequest(PrepareRequestMsg("Http Request Type"::POST, SharePointUriBuilder, SharePointHttpContent));
    end;

    procedure Post(SharePointUriBuilder: Codeunit "SharePoint Uri Builder"; SharePointHttpContent: Codeunit "SharePoint Http Content") OperationResponse: Codeunit "SharePoint Operation Response"
    begin
        OperationResponse := SendRequest(PrepareRequestMsg("Http Request Type"::POST, SharePointUriBuilder, SharePointHttpContent));
    end;

    procedure Delete(SharePointUriBuilder: Codeunit "SharePoint Uri Builder") OperationResponse: Codeunit "SharePoint Operation Response"
    begin
        OperationResponse := SendRequest(PrepareRequestMsg("Http Request Type"::DELETE, SharePointUriBuilder));
    end;

    [NonDebuggable]
    local procedure PrepareRequestMsg(HttpRequestType: Enum "Http Request Type"; SharePointUriBuilder: Codeunit "SharePoint Uri Builder") RequestMessage: HttpRequestMessage
    var
        Headers: HttpHeaders;
    begin
        RequestMessage.Method(Format(HttpRequestType));
        RequestMessage.SetRequestUri(SharePointUriBuilder.GetUri());
        RequestMessage.GetHeaders(Headers);
        Headers.Add('Accept', 'application/json');
        Headers.Add('User-Agent', GetUserAgentString());
    end;

    [NonDebuggable]
    local procedure PrepareRequestMsg(HttpRequestType: Enum "Http Request Type"; SharePointUriBuilder: Codeunit "SharePoint Uri Builder"; SharePointHttpContent: Codeunit "SharePoint Http Content") RequestMessage: HttpRequestMessage
    var
        Headers: HttpHeaders;
        HttpContent: HttpContent;
    begin
        RequestMessage.Method(Format(HttpRequestType));
        RequestMessage.SetRequestUri(SharePointUriBuilder.GetUri());

        RequestMessage.GetHeaders(Headers);
        Headers.Add('Accept', 'application/json;odata=verbose');
        Headers.Add('User-Agent', GetUserAgentString());

        if SharePointHttpContent.GetContentLength() > 0 then begin
            HttpContent := SharePointHttpContent.GetContent();
            HttpContent.GetHeaders(Headers);

            if Headers.Contains('Content-Type') then
                Headers.Remove('Content-Type');

            if SharePointHttpContent.GetContentType() <> '' then
                Headers.Add('Content-Type', SharePointHttpContent.GetContentType());

            Headers.Add('X-RequestDigest', SharePointHttpContent.GetRequestDigest());
            RequestMessage.Content(HttpContent);
        end;
    end;

    [NonDebuggable]
    local procedure SendRequest(HttpRequestMessage: HttpRequestMessage) OperationResponse: Codeunit "SharePoint Operation Response"
    var
        HttpResponseMessage: HttpResponseMessage;
        IsHandled: Boolean;
        Content: Text;
    begin
        OnBeforeSendRequest(HttpRequestMessage, OperationResponse, IsHandled, HttpRequestMessage.Method());

        if not IsHandled then begin
            Authorization.Authorize(HttpRequestMessage);
            if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
                Error(OperationNotSuccessfulErr);

            HttpResponseMessage.Content.ReadAs(Content);

            OperationResponse.SetHttpResponse(HttpResponseMessage);
        end;
    end;

    local procedure GetUserAgentString() UserAgentString: Text
    var
        ModuleInfo: ModuleInfo;
    begin
        if NavApp.GetCurrentModuleInfo(ModuleInfo) then
            UserAgentString := StrSubstNo(UserAgentLbl, ModuleInfo.Publisher(), ModuleInfo.Name(), ModuleInfo.AppVersion());
    end;

    [InternalEvent(false, true)]
    local procedure OnBeforeSendRequest(HttpRequestMessage: HttpRequestMessage; var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; var IsHandled: Boolean; Method: Text)
    begin

    end;

}