codeunit 2351 "Rest Client Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        HttpAuthentication: Interface "Http Authentication";
        HttpClientHandler: Interface "Http Client Handler";
        HttpClientHandler: Interface "Http Client Handler";
        DefaultHttpClientHandler: Codeunit "Http Client Handler";
        HttpClient: HttpClient;
        Initialized: Boolean;
        NotInitializedErr: Label 'The Rest Client has not been initialized';
        EnvironmentBlocksErr: label 'Environment blocks an outgoing HTTP request to ''%1''.', Comment = '%1 = url, e.g. https://microsoft.com';
        ConnectionErr: label 'Connection to the remote service ''%1'' could not be established.', Comment = '%1 = url, e.g. https://microsoft.com';
        RequestFailedErr: label 'The request failed: %1 %2', Comment = '%1 = HTTP status code, %2 = Reason phrase';
        UserAgentLbl: Label 'Dynamics 365 Business Central - |%1| %2/%3', Locked = true, Comment = '%1 = App Publisher; %2 = App Name; %3 = App Version';

    procedure Initialize()
    begin
        Initialize(DefaultHttpClientHandler, HttpAuthenticationAnonymous);
    end;

    procedure Initialize(HttpClientHandler: Interface "Http Client Handler")
    begin
        Initialize(HttpClientHandler, HttpAuthenticationAnonymous);
    end;

    procedure Initialize(HttpAuthentication: Interface "Http Authentication")
    begin
        Initialize(DefaultHttpClientHandler, HttpAuthentication);
    end;
    
    procedure Initialize(HttpClientHandlerInstance: Interface "Http Client Handler"; HttpAuthenticationInstance: Interface "Http Authentication")
    begin
        ClearAll();

        HttpClient.Clear();
        HttpClientHandler := HttpClientHandlerInstance;
        HttpAuthentication := HttpAuthenticationInstance;
        Initialized := true;
        SetDefaultUserAgentHeader();
    end;

    procedure SetBaseAddress(Url: Text)
    begin
        AssertInitialized();
        HttpClient.SetBaseAddress(Url);
    end;

    procedure GetBaseAddress() Url: Text
    begin
        AssertInitialized();
        Url := HttpClient.GetBaseAddress;
    end;

    procedure SetTimeOut(TimeOut: Duration)
    begin
        AssertInitialized();
        HttpClient.Timeout := TimeOut;
    end;

    procedure GetTimeOut() TimeOut: Duration
    begin
        AssertInitialized();
        TimeOut := HttpClient.Timeout;
    end;

    procedure AddCertificate(Certificate: Text)
    begin
        AssertInitialized();
        HttpClient.AddCertificate(Certificate);
    end;

    procedure AddCertificate(Certificate: Text; Password: SecretText)
    begin
        AssertInitialized();
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

    local procedure SetDefaultUserAgentHeader()
    begin
        SetUserAgentHeader(GetUserAgentString());
    end;

    local procedure GetUserAgentString() UserAgentString: Text
    var
        ModuleInfo: ModuleInfo;
    begin
        if NavApp.GetCurrentModuleInfo(ModuleInfo) then
            UserAgentString := StrSubstNo(UserAgentLbl, ModuleInfo.Publisher(), ModuleInfo.Name(), ModuleInfo.AppVersion());
    end;

    procedure SetDefaultRequestHeader(Name: Text; Value: Text)
    begin
        AssertInitialized();
        if HttpClient.DefaultRequestHeaders.Contains(Name) then
            HttpClient.DefaultRequestHeaders.Remove(Name);
        HttpClient.DefaultRequestHeaders.Add(Name, Value);
    end;

    procedure SetDefaultRequestHeader(Name: Text; Value: SecretText)
    begin
        AssertInitialized();
        if HttpClient.DefaultRequestHeaders.Contains(Name) then
            HttpClient.DefaultRequestHeaders.Remove(Name);
        HttpClient.DefaultRequestHeaders.Add(Name, Value);
    end;

    local procedure AssertInitialized()
    begin
        if not Initialized then
            Error(NotInitializedErr);
    end;

    procedure SendRequest(var HttpRequestMessage: Codeunit "Http Request Message"; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    var
        ErrorMessage: Text;
    begin
        AssertInitialized();

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

        if not HttpResponseMessage.GetIsSuccessStatusCode then begin
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
}