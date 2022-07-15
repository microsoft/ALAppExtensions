codeunit 9109 "SharePoint Request Manager"
{
    Access = Internal;

    var
        HttpClient: HttpClient;
        Authorization: Interface "SharePoint Authorization";
        HttpResponseInfoErr: Label '%1.\\Response Code: %2 %3', Comment = '%1 = Default Error Message ; %2 = Status Code; %3 = Reason Phrase';
        OperationNotSuccessfulErr: Label 'An error has occurred';

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

        if IsHandled then
            exit(OperationResponse);

        Authorization.Authorize(HttpRequestMessage);
        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            Error(OperationNotSuccessfulErr);
        if not HttpResponseMessage.IsSuccessStatusCode() then
            OperationResponse.SetError(StrSubstNo(HttpResponseInfoErr, OperationNotSuccessfulErr, HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase));

        OperationResponse.SetHttpResponse(HttpResponseMessage);

        HttpResponseMessage.Content().ReadAs(Content);
    end;

    local procedure GetUserAgentString() UserAgentString: Text
    var
        ModuleInfo: ModuleInfo;
    begin
        if NavApp.GetCurrentModuleInfo(ModuleInfo) then
            UserAgentString := StrSubstNo('NONISV|%1|Dynamics 365 Business Central - %2/%3', ModuleInfo.Publisher(), ModuleInfo.Name(), ModuleInfo.AppVersion());
    end;

    [InternalEvent(false, true)]
    local procedure OnBeforeSendRequest(HttpRequestMessage: HttpRequestMessage; var SharePointOperationResponse: Codeunit "SharePoint Operation Response"; var IsHandled: Boolean; Method: Text)
    begin

    end;

}