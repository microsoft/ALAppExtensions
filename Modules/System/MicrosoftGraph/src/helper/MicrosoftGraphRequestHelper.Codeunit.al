// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9354 "Microsoft Graph Request Helper"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        IHttpClient: Interface IHttpClient;
        Authorization: Interface "Microsoft Graph Authorization";
        OperationNotSuccessfulErr: Label 'An error has occurred';
        UserAgentLbl: Label 'NONISV|%1|Dynamics 365 Business Central - %2/%3', Comment = '%1 = App Publisher; %2 = App Name; %3 = App Version', Locked = true;

    procedure SetHttpClient(NewHttpClient: Interface IHttpClient)
    begin
        IHttpClient := NewHttpClient;
    end;

    procedure SetAuthorization(Auth: Interface "Microsoft Graph Authorization")
    begin
        Authorization := Auth;
    end;

    procedure Get(MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder"; MgOptionalParameters: Codeunit "Mg Optional Parameters") OperationResponse: Codeunit "Mg Operation Response"
    begin
        OperationResponse := SendRequest(PrepareRequestMsg(Enum::"Http Request Type"::GET, MicrosoftGraphUriBuilder, MgOptionalParameters));
    end;

    procedure Post(MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder"; MgOptionalParameters: Codeunit "Mg Optional Parameters") OperationResponse: Codeunit "Mg Operation Response"
    var
        MicrosoftGraphHttpContent: Codeunit "Microsoft Graph Http Content";
    begin
        OperationResponse := SendRequest(PrepareRequestMsg(Enum::"Http Request Type"::POST, MicrosoftGraphUriBuilder, MgOptionalParameters, MicrosoftGraphHttpContent));
    end;

    procedure Post(MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder"; MgOptionalParameters: Codeunit "Mg Optional Parameters"; MicrosoftGraphHttpContent: Codeunit "Microsoft Graph Http Content") OperationResponse: Codeunit "Mg Operation Response"
    begin
        OperationResponse := SendRequest(PrepareRequestMsg(Enum::"Http Request Type"::POST, MicrosoftGraphUriBuilder, MgOptionalParameters, MicrosoftGraphHttpContent));
    end;

    procedure Delete(MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder") OperationResponse: Codeunit "Mg Operation Response"
    begin
        OperationResponse := SendRequest(PrepareRequestMsg(Enum::"Http Request Type"::DELETE, MicrosoftGraphUriBuilder));
    end;

    local procedure PrepareRequestMsg(HttpRequestType: Enum "Http Request Type"; MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder"): HttpRequestMessage
    var
        MgOptionalParameters: Codeunit "Mg Optional Parameters";
    begin
        exit(PrepareRequestMsg(HttpRequestType, MicrosoftGraphUriBuilder, MgOptionalParameters));
    end;

    local procedure PrepareRequestMsg(HttpRequestType: Enum "Http Request Type"; MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder"; MgOptionalParameters: Codeunit "Mg Optional Parameters"): HttpRequestMessage
    var
        MicrosoftGraphHttpContent: Codeunit "Microsoft Graph Http Content";
    begin
        exit(PrepareRequestMsg(HttpRequestType, MicrosoftGraphUriBuilder, MgOptionalParameters, MicrosoftGraphHttpContent));
    end;

    [NonDebuggable]
    local procedure PrepareRequestMsg(HttpRequestType: Enum "Http Request Type"; MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder"; MgOptionalParameters: Codeunit "Mg Optional Parameters"; MicrosoftGraphHttpContent: Codeunit "Microsoft Graph Http Content") RequestMessage: HttpRequestMessage
    var
        RequestHeaders: Dictionary of [Text, Text];
        HttpContent: HttpContent;
        Headers: HttpHeaders;
        RequestHeaderName: Text;
    begin
        RequestMessage.Method(Format(HttpRequestType));
        RequestMessage.SetRequestUri(MicrosoftGraphUriBuilder.GetUri());

        RequestMessage.GetHeaders(Headers);
        Headers.Add('Accept', 'application/json');
        Headers.Add('User-Agent', GetUserAgentString());
        RequestHeaders := MgOptionalParameters.GetRequestHeaders();
        foreach RequestHeaderName in RequestHeaders.Keys() do begin
            if Headers.Contains(RequestHeaderName) then
                Headers.Remove(RequestHeaderName);
            Headers.Add(RequestHeaderName, RequestHeaders.Get(RequestHeaderName));
        end;

        if MicrosoftGraphHttpContent.GetContentLength() > 0 then begin
            HttpContent := MicrosoftGraphHttpContent.GetContent();
            HttpContent.GetHeaders(Headers);

            if Headers.Contains('Content-Type') then
                Headers.Remove('Content-Type');

            if MicrosoftGraphHttpContent.GetContentType() <> '' then
                Headers.Add('Content-Type', MicrosoftGraphHttpContent.GetContentType());
            RequestMessage.Content(HttpContent);
        end;
    end;

    [NonDebuggable]
    local procedure SendRequest(HttpRequestMessage: HttpRequestMessage) OperationResponse: Codeunit "Mg Operation Response"
    var
        IHttpResponseMessage: Interface IHttpResponseMessage;
        Content: Text;
    begin

        Authorization.Authorize(HttpRequestMessage);
        if not IHttpClient.Send(HttpRequestMessage, IHttpResponseMessage) then
            Error(OperationNotSuccessfulErr);

        IHttpResponseMessage.Content().ReadAs(Content);

        OperationResponse.SetHttpResponse(IHttpResponseMessage);
    end;

    local procedure GetUserAgentString() UserAgentString: Text
    var
        ModuleInfo: ModuleInfo;
    begin
        if NavApp.GetCurrentModuleInfo(ModuleInfo) then
            UserAgentString := StrSubstNo(UserAgentLbl, ModuleInfo.Publisher(), ModuleInfo.Name(), ModuleInfo.AppVersion());
    end;
}