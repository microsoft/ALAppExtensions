codeunit 9109 "SP Request Manager"
{
    Access = Internal;

    var
        HttpClient: HttpClient;
        Authorization: Interface "SP IAuthorization";
        HttpResponseInfoErr: Label '%1.\\Response Code: %2 %3', Comment = '%1 = Default Error Message ; %2 = Status Code; %3 = Reason Phrase';

        OperationNotSuccessfulErr: Label 'An error has occurred';
        BearerTxt: Label 'Bearer %1', Comment = '%1 - Bearer token', Locked = true;

    procedure SetAuthorization(Auth: Interface "SP IAuthorization")
    begin
        Authorization := Auth;
    end;

    procedure Get(UriBuilder: Codeunit "SP Uri Builder") OperationResponse: Codeunit "SP Operation Response"
    var
    begin
        OperationResponse := SendRequest(PrepareRequestMsg("Http Request Type"::GET, UriBuilder));
    end;


    procedure Post(UriBuilder: Codeunit "SP Uri Builder") OperationResponse: Codeunit "SP Operation Response"
    var
        SPHttpContent: Codeunit "SP Http Content";
    begin
        OperationResponse := SendRequest(PrepareRequestMsg("Http Request Type"::POST, UriBuilder, SPHttpContent));
    end;

    procedure Post(UriBuilder: Codeunit "SP Uri Builder"; SPHttpContent: Codeunit "SP Http Content") OperationResponse: Codeunit "SP Operation Response"
    var
        HttpRequestMessage: HttpRequestMessage;
    begin
        HttpRequestMessage := PrepareRequestMsg("Http Request Type"::POST, UriBuilder, SPHttpContent);
        OperationResponse := SendRequest(HttpRequestMessage);
    end;

    [NonDebuggable]
    local procedure PrepareRequestMsg(HttpRequestType: Enum "Http Request Type"; UriBuilder: Codeunit "SP Uri Builder") RequestMessage: HttpRequestMessage
    var
        Headers: HttpHeaders;
    begin
        RequestMessage.Method(Format(HttpRequestType));
        RequestMessage.SetRequestUri(UriBuilder.GetUri());
        RequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', GetAuthenticationHeaderValue());
        Headers.Add('Accept', 'application/json');

    end;



    local procedure PrepareRequestMsg(HttpRequestType: Enum "Http Request Type"; UriBuilder: Codeunit "SP Uri Builder";
                                                           SPHttpContent: Codeunit "SP Http Content") RequestMessage: HttpRequestMessage
    var
        Headers: HttpHeaders;
        HttpContent: HttpContent;
    begin
        RequestMessage.Method(Format(HttpRequestType));
        RequestMessage.SetRequestUri(UriBuilder.GetUri());

        RequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', GetAuthenticationHeaderValue());
        Headers.Add('Accept', 'application/json;odata=verbose');

        if SPHttpContent.GetContentLength() > 0 then begin
            HttpContent := SPHttpContent.GetContent();
            HttpContent.GetHeaders(Headers);

            if Headers.Contains('Content-Length') then
                Headers.Remove('Content-Length');
            Headers.Add('Content-Length', Format(SPHttpContent.GetContentLength()));

            if Headers.Contains('Content-Type') then
                Headers.Remove('Content-Type');

            if SPHttpContent.GetContentType() <> '' then
                Headers.Add('Content-Type', SPHttpContent.GetContentType());

            Headers.Add('X-RequestDigest', SPHttpContent.GetRequestDigest());
            RequestMessage.Content(HttpContent);
        end;

    end;



    [NonDebuggable]
    local procedure SendRequest(HttpRequestMessage: HttpRequestMessage) OperationResponse: Codeunit "SP Operation Response"
    var
        HttpResponseMessage: HttpResponseMessage;
    begin
        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            Error(OperationNotSuccessfulErr);

        if not HttpResponseMessage.IsSuccessStatusCode() then
            OperationResponse.SetError(StrSubstNo(HttpResponseInfoErr, OperationNotSuccessfulErr, HttpResponseMessage.HttpStatusCode, HttpResponseMessage.ReasonPhrase));

        OperationResponse.SetHttpResponse(HttpResponseMessage);

    end;

    local procedure GetAuthenticationHeaderValue() Value: Text;
    begin

        Value := StrSubstNo(BearerTxt, Authorization.GetToken());
    end;


}