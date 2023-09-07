codeunit 2351 "AL Rest Client Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        HttpAuthentication: Interface "Http Authentication";
        HttpClient: HttpClient;
        ConnectionError: Boolean;
        Initialized: Boolean;
        NotInitializedErr: Label 'The AL Rest Client has not been initialized';
        EnvironmentBlocksErr: Label 'Environment blocks an outgoing HTTP request to ''%1''.', Comment = '%1 = url, e.g. https://microsoft.com';
        ConnectionErr: Label 'Connection to the remote service ''%1'' could not be established.', Comment = '%1 = url, e.g. https://microsoft.com';
        RequestFailedErr: Label 'The request failed: %1 %2', Comment = '%1 = HTTP status code, %2 = Reason phrase';
        UserAgentLbl: Label 'Dynamics 365 Business Central - |%1| %2/%3', Locked = true, Comment = '%1 = App Publisher; %2 = App Name; %3 = App Version';

    procedure Initialize()
    begin
        ClearAll();

        HttpClient.Clear();
        HttpClient.Timeout := 60000;
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

    [NonDebuggable]
    procedure SetAuthorizationHeader(Value: Text)
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

    [NonDebuggable]
    procedure SetAuthentication(HttpAuthenticationInstance: Interface "Http Authentication")
    begin
        HttpAuthentication := HttpAuthenticationInstance;
    end;

    procedure HasConnectionError(): Boolean
    begin
        exit(ConnectionError);
    end;

    local procedure AssertInitialized()
    begin
        if not Initialized then
            Error(NotInitializedErr);
    end;

    procedure SendRequest(var ALHttpRequestMessage: Codeunit "AL Http Request Message") ALHttpResponseMessage: Codeunit "AL Http Response Message"
    begin
        if not TrySendRequest(ALHttpRequestMessage, ALHttpResponseMessage) then;
    end;

    [TryFunction]
    local procedure TrySendRequest(var ALHttpRequestMessage: Codeunit "AL Http Request Message"; var ALHttpResponseMessage: Codeunit "AL Http Response Message")
    var
        ErrorMessage: Text;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
    begin
        AssertInitialized();

        ALHttpResponseMessage.Initialize();
        ConnectionError := false;

        if HttpAuthentication.IsAuthenticationRequired() then
            if not Authorize(ALHttpRequestMessage) then begin
                ErrorMessage := GetLastErrorText();
                ALHttpResponseMessage.SetErrorMessage(ErrorMessage);
                Error(ErrorMessage);
            end;

        HttpRequestMessage := ALHttpRequestMessage.GetRequestMessage();

        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.IsBlockedByEnvironment() then
                ErrorMessage := StrSubstNo(EnvironmentBlocksErr, HttpRequestMessage.GetRequestUri())
            else
                ErrorMessage := StrSubstNo(ConnectionErr, HttpRequestMessage.GetRequestUri());
            ConnectionError := true;
            Error(ErrorMessage);
        end;

        ALHttpResponseMessage.SetResponseMessage(HttpResponseMessage);

        if not HttpResponseMessage.IsSuccessStatusCode then begin
            ErrorMessage := StrSubstNo(RequestFailedErr, HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase);
            ALHttpResponseMessage.SetErrorMessage(ErrorMessage);
            Error(ErrorMessage);
        end;
    end;

    [NonDebuggable]
    [TryFunction]
    local procedure Authorize(ALHttpRequestMessage: Codeunit "AL Http Request Message")
    var
        AuthorizationHeaders: Dictionary of [Text, Text];
        HeaderName: Text;
        HeaderValue: Text;
    begin
        AuthorizationHeaders := HttpAuthentication.GetAuthorizationHeaders();
        foreach HeaderName in AuthorizationHeaders.Keys do begin
            HeaderValue := AuthorizationHeaders.Get(HeaderName);
            ALHttpRequestMessage.AddRequestHeader(HeaderName, HeaderValue);
        end;
    end;
}