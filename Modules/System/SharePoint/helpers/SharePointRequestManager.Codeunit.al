codeunit 9109 "SharePoint Request Manager"
{
    Access = Internal;

    var
        HttpClient: HttpClient;
        Authorization: Interface "I SharePoint Authorization";
        HttpResponseInfoErr: Label '%1.\\Response Code: %2 %3', Comment = '%1 = Default Error Message ; %2 = Status Code; %3 = Reason Phrase';

        OperationNotSuccessfulErr: Label 'An error has occurred';
        BearerTxt: Label 'Bearer %1', Comment = '%1 - Bearer token', Locked = true;

    procedure SetAuthorization(Auth: Interface "I SharePoint Authorization")
    begin
        Authorization := Auth;
    end;

    procedure Get(SharePointUriBuilder: Codeunit "SharePoint Uri Builder") OperationResponse: Codeunit "SharePoint Operation Response"
    var
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
    var
        HttpRequestMessage: HttpRequestMessage;
    begin
        HttpRequestMessage := PrepareRequestMsg("Http Request Type"::POST, SharePointUriBuilder, SharePointHttpContent);
        OperationResponse := SendRequest(HttpRequestMessage);
    end;

    [NonDebuggable]
    local procedure PrepareRequestMsg(HttpRequestType: Enum "Http Request Type"; SharePointUriBuilder: Codeunit "SharePoint Uri Builder") RequestMessage: HttpRequestMessage
    var
        Headers: HttpHeaders;
    begin
        RequestMessage.Method(Format(HttpRequestType));
        RequestMessage.SetRequestUri(SharePointUriBuilder.GetUri());
        RequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', GetAuthenticationHeaderValue());
        Headers.Add('Accept', 'application/json');

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
        Headers.Add('Authorization', GetAuthenticationHeaderValue());
        Headers.Add('Accept', 'application/json;odata=verbose');

        if SharePointHttpContent.GetContentLength() > 0 then begin
            HttpContent := SharePointHttpContent.GetContent();
            HttpContent.GetHeaders(Headers);

            if Headers.Contains('Content-Length') then
                Headers.Remove('Content-Length');
            Headers.Add('Content-Length', Format(SharePointHttpContent.GetContentLength()));

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
    begin
        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            Error(OperationNotSuccessfulErr);

        if not HttpResponseMessage.IsSuccessStatusCode() then
            OperationResponse.SetError(StrSubstNo(HttpResponseInfoErr, OperationNotSuccessfulErr, HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase));

        OperationResponse.SetHttpResponse(HttpResponseMessage);

    end;

    [NonDebuggable]
    local procedure GetAuthenticationHeaderValue() Value: Text;
    begin

        Value := StrSubstNo(BearerTxt, Authorization.GetToken());
    end;


}