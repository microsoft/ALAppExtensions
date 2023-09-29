// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.RestClient;

codeunit 2351 "Rest Client Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        DefaultHttpClientHandler: Codeunit "Http Client Handler";
        HttpAuthenticationAnonymous: Codeunit "Http Authentication Anonymous";
        HttpAuthentication: Interface "Http Authentication";
        HttpClientHandler: Interface "Http Client Handler";
        HttpClient: HttpClient;
        IsInitialized: Boolean;
        EnvironmentBlocksErr: label 'Environment blocks an outgoing HTTP request to ''%1''.', Comment = '%1 = url, e.g. https://microsoft.com';
        ConnectionErr: label 'Connection to the remote service ''%1'' could not be established.', Comment = '%1 = url, e.g. https://microsoft.com';
        RequestFailedErr: label 'The request failed: %1 %2', Comment = '%1 = HTTP status code, %2 = Reason phrase';
        UserAgentLbl: Label 'Dynamics 365 Business Central - |%1| %2/%3', Locked = true, Comment = '%1 = App Publisher; %2 = App Name; %3 = App Version';

    #region Initialization
    procedure Initialize()
    begin
        Initialize(DefaultHttpClientHandler, HttpAuthenticationAnonymous);
    end;

    #pragma warning disable AA0244
    procedure Initialize(HttpClientHandler: Interface "Http Client Handler")
    begin
        Initialize(HttpClientHandler, HttpAuthenticationAnonymous);
    end;

    procedure Initialize(HttpAuthentication: Interface "Http Authentication")
    begin
        Initialize(DefaultHttpClientHandler, HttpAuthentication);
    end;
    #pragma warning restore AA0244

    procedure Initialize(HttpClientHandlerInstance: Interface "Http Client Handler"; HttpAuthenticationInstance: Interface "Http Authentication")
    begin
        ClearAll();

        HttpClient.Clear();
        HttpClientHandler := HttpClientHandlerInstance;
        HttpAuthentication := HttpAuthenticationInstance;
        IsInitialized := true;
        SetDefaultUserAgentHeader();
    end;

    procedure SetDefaultRequestHeader(Name: Text; Value: Text)
    begin
        CheckInitialized();
        if HttpClient.DefaultRequestHeaders.Contains(Name) then
            HttpClient.DefaultRequestHeaders.Remove(Name);
        HttpClient.DefaultRequestHeaders.Add(Name, Value);
    end;

    procedure SetDefaultRequestHeader(Name: Text; Value: SecretText)
    begin
        CheckInitialized();
        if HttpClient.DefaultRequestHeaders.Contains(Name) then
            HttpClient.DefaultRequestHeaders.Remove(Name);
        HttpClient.DefaultRequestHeaders.Add(Name, Value);
    end;

    procedure SetBaseAddress(Url: Text)
    begin
        CheckInitialized();
        HttpClient.SetBaseAddress(Url);
    end;

    procedure GetBaseAddress() Url: Text
    begin
        CheckInitialized();
        Url := HttpClient.GetBaseAddress;
    end;

    procedure SetTimeOut(TimeOut: Duration)
    begin
        CheckInitialized();
        HttpClient.Timeout := TimeOut;
    end;

    procedure GetTimeOut() TimeOut: Duration
    begin
        CheckInitialized();
        TimeOut := HttpClient.Timeout;
    end;

    procedure AddCertificate(Certificate: Text)
    begin
        CheckInitialized();
        HttpClient.AddCertificate(Certificate);
    end;

    procedure AddCertificate(Certificate: Text; Password: SecretText)
    begin
        CheckInitialized();
        HttpClient.AddCertificate(Certificate, Password);
    end;

    procedure SetAuthorizationHeader(Value: SecretText)
    begin
        SetDefaultRequestHeader('Authorization', Value);
    end;

    procedure SetUserAgentHeader(Value: Text)
    begin
        SetDefaultRequestHeader('User-Agent', Value);
    end;
    #endregion


    #region BasicMethodsAsJson
    procedure GetAsJson(RequestUri: Text) JsonToken: JsonToken
    var
        HttpResponseMessage: Codeunit "Http Response Message";
    begin
        HttpResponseMessage := Send(Enum::"Http Method"::GET, RequestUri);
        if not HttpResponseMessage.GetIsSuccessStatusCode() then
            Error(HttpResponseMessage.GetErrorMessage());

        JsonToken := HttpResponseMessage.GetContent().AsJson();
    end;

    procedure PostAsJson(RequestUri: Text; Content: JsonToken) Response: JsonToken
    var
        HttpResponseMessage: Codeunit "Http Response Message";
        HttpContent: Codeunit "Http Content";
    begin
        HttpResponseMessage := Send(Enum::"Http Method"::POST, RequestUri, HttpContent.Create(Content));

        if not HttpResponseMessage.GetIsSuccessStatusCode() then
            Error(HttpResponseMessage.GetErrorMessage());

        Response := HttpResponseMessage.GetContent().AsJson();
    end;

    procedure PatchAsJson(RequestUri: Text; Content: JSonToken) Response: JsonToken
    var
        HttpResponseMessage: Codeunit "Http Response Message";
        HttpContent: Codeunit "Http Content";
    begin
        HttpResponseMessage := Send(Enum::"Http Method"::PATCH, RequestUri, HttpContent.Create(Content));

        if not HttpResponseMessage.GetIsSuccessStatusCode() then
            Error(HttpResponseMessage.GetErrorMessage());

        Response := HttpResponseMessage.GetContent().AsJson();
    end;

    procedure PutAsJson(RequestUri: Text; Content: JSonToken) Response: JsonToken
    var
        HttpResponseMessage: Codeunit "Http Response Message";
        HttpContent: Codeunit "Http Content";
    begin
        HttpResponseMessage := Send(Enum::"Http Method"::PUT, RequestUri, HttpContent.Create(Content));

        if not HttpResponseMessage.GetIsSuccessStatusCode() then
            Error(HttpResponseMessage.GetErrorMessage());

        Response := HttpResponseMessage.GetContent().AsJson();
    end;
    #endregion

    #region GenericSendMethods
    procedure Send(Method: Enum "Http Method"; RequestUri: Text) HttpResponseMessage: Codeunit "Http Response Message"
    var
        EmptyHttpContent: Codeunit "Http Content";
    begin
        HttpResponseMessage := Send(Method, RequestUri, EmptyHttpContent);
    end;

    procedure Send(Method: Enum "Http Method"; RequestUri: Text; Content: Codeunit "Http Content") HttpResponseMessage: Codeunit "Http Response Message"
    var
        HttpRequestMessage: Codeunit "Http Request Message";
    begin
        CheckInitialized();

        HttpRequestMessage.SetHttpMethod(Method);
        if RequestUri.StartsWith('http://') or RequestUri.StartsWith('https://') then
            HttpRequestMessage.SetRequestUri(RequestUri)
        else
            HttpRequestMessage.SetRequestUri(GetBaseAddress() + RequestUri);
        HttpRequestMessage.SetContent(Content);

        HttpResponseMessage := Send(HttpRequestMessage);
    end;

    procedure Send(var HttpRequestMessage: Codeunit "Http Request Message") HttpResponseMessage: Codeunit "Http Response Message"
    begin
        CheckInitialized();

        if not SendRequest(HttpRequestMessage, HttpResponseMessage) then
            Error(HttpResponseMessage.GetErrorMessage());
    end;
    #endregion

    #region Local Methods
    local procedure CheckInitialized()
    begin
        if not IsInitialized then
            Initialize();
    end;

    local procedure SetDefaultUserAgentHeader()
    var
        ModuleInfo: ModuleInfo;
        UserAgentString: Text;
    begin
        if NavApp.GetCurrentModuleInfo(ModuleInfo) then
            UserAgentString := StrSubstNo(UserAgentLbl, ModuleInfo.Publisher(), ModuleInfo.Name(), ModuleInfo.AppVersion());

        SetUserAgentHeader(UserAgentString);
    end;

    local procedure SendRequest(var HttpRequestMessage: Codeunit "Http Request Message"; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    var
        ErrorMessage: Text;
    begin
        Clear(HttpResponseMessage);

        if HttpAuthentication.IsAuthenticationRequired() then
            Authorize(HttpRequestMessage);

        if not HttpClientHandler.Send(HttpClient, HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.GetIsBlockedByEnvironment() then
                ErrorMessage := StrSubstNo(EnvironmentBlocksErr, HttpRequestMessage.GetRequestUri())
            else
                ErrorMessage := StrSubstNo(ConnectionErr, HttpRequestMessage.GetRequestUri());
            exit(false);
        end;

        if not HttpResponseMessage.GetIsSuccessStatusCode() then begin
            ErrorMessage := StrSubstNo(RequestFailedErr, HttpResponseMessage.GetHttpStatusCode(), HttpResponseMessage.GetReasonPhrase());
            HttpResponseMessage.SetErrorMessage(ErrorMessage);
        end;

        exit(true);
    end;

    local procedure Authorize(HttpRequestMessage: Codeunit "Http Request Message")
    var
        AuthorizationHeaders: Dictionary of [Text, SecretText];
        HeaderName: Text;
        HeaderValue: SecretText;
    begin
        AuthorizationHeaders := HttpAuthentication.GetAuthorizationHeaders();
        foreach HeaderName in AuthorizationHeaders.Keys do begin
            HeaderValue := AuthorizationHeaders.Get(HeaderName);
            HttpRequestMessage.SetHeader(HeaderName, HeaderValue);
        end;
    end;
    #endregion
}