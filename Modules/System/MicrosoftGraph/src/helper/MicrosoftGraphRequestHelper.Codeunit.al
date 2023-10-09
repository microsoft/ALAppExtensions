// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9034 "Microsoft Graph Request Helper"
{
    Access = Internal;

    var
        HttpClient: HttpClient;
        Authorization: Interface "Microsoft Graph Authorization";
        OperationNotSuccessfulErr: Label 'An error has occurred';
        UserAgentLbl: Label 'NONISV|%1|Dynamics 365 Business Central - %2/%3', Locked = true, Comment = '%1 = App Publisher; %2 = App Name; %3 = App Version';

    procedure SetAuthorization(Auth: Interface "Microsoft Graph Authorization")
    begin
        Authorization := Auth;
    end;

    procedure Get(MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder") OperationResponse: Codeunit "Mg Operation Response"
    begin
        OperationResponse := SendRequest(PrepareRequestMsg(Enum::"Http Request Type"::GET, MicrosoftGraphUriBuilder));
    end;

    procedure Post(MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder") OperationResponse: Codeunit "Mg Operation Response"
    var
        MicrosoftGraphHttpContent: Codeunit "Microsoft Graph Http Content";
    begin
        OperationResponse := SendRequest(PrepareRequestMsg(Enum::"Http Request Type"::POST, MicrosoftGraphUriBuilder, MicrosoftGraphHttpContent));
    end;

    procedure Post(MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder"; MicrosoftGraphHttpContent: Codeunit "Microsoft Graph Http Content") OperationResponse: Codeunit "Mg Operation Response"
    begin
        OperationResponse := SendRequest(PrepareRequestMsg(Enum::"Http Request Type"::POST, MicrosoftGraphUriBuilder, MicrosoftGraphHttpContent));
    end;

    [NonDebuggable]
    local procedure PrepareRequestMsg(HttpRequestType: Enum "Http Request Type"; MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder") RequestMessage: HttpRequestMessage
    var
        Headers: HttpHeaders;
    begin
        RequestMessage.Method(Format(HttpRequestType));
        RequestMessage.SetRequestUri(MicrosoftGraphUriBuilder.GetUri());
        RequestMessage.GetHeaders(Headers);
        Headers.Add('Accept', 'application/json');
        Headers.Add('User-Agent', GetUserAgentString());
    end;

    [NonDebuggable]
    local procedure PrepareRequestMsg(HttpRequestType: Enum "Http Request Type"; MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder"; MicrosoftGraphHttpContent: Codeunit "Microsoft Graph Http Content") RequestMessage: HttpRequestMessage
    var
        Headers: HttpHeaders;
        HttpContent: HttpContent;
    begin
        RequestMessage.Method(Format(HttpRequestType));
        RequestMessage.SetRequestUri(MicrosoftGraphUriBuilder.GetUri());

        RequestMessage.GetHeaders(Headers);
        Headers.Add('Accept', 'application/json;odata=verbose');
        Headers.Add('User-Agent', GetUserAgentString());

        if MicrosoftGraphHttpContent.GetContentLength() > 0 then begin
            HttpContent := MicrosoftGraphHttpContent.GetContent();
            HttpContent.GetHeaders(Headers);

            if Headers.Contains('Content-Type') then
                Headers.Remove('Content-Type');

            if MicrosoftGraphHttpContent.GetContentType() <> '' then
                Headers.Add('Content-Type', MicrosoftGraphHttpContent.GetContentType());

            // Headers.Add('X-RequestDigest', MicrosoftGraphHttpContent.GetRequestDigest());
            RequestMessage.Content(HttpContent);
        end;
    end;

    [NonDebuggable]
    local procedure SendRequest(HttpRequestMessage: HttpRequestMessage) OperationResponse: Codeunit "Mg Operation Response"
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
    local procedure OnBeforeSendRequest(HttpRequestMessage: HttpRequestMessage; var SharePointOperationResponse: Codeunit "Mg Operation Response"; var IsHandled: Boolean; Method: Text)
    begin

    end;

}