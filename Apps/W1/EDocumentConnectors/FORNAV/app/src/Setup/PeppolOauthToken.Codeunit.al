namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using System.Text;
using System.Reflection;

codeunit 6423 "ForNAV Peppol Oauth Token"
{
    Access = Internal;

    var
        AccessTokenExpires: DateTime;
        AccessToken: SecretText;
        Roles: List of [Text];

    [NonDebuggable]
    [TryFunction]
    internal procedure AcquireTokenWithClientCredentials(ClientId: Text; ClientSecret: SecretText; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [SecretText])
    var
        Token: Text;
    begin
        GetAccessToken(ClientId, ClientSecret, OAuthAuthorityUrl, RedirectURL, Scopes, Token);
        AccessToken := Format(Token);
        GetAccessTokenProperties(Token);
    end;

    [NonDebuggable]
    local procedure GetAccessToken(ClientId: Text; ClientSecret: SecretText; OAuthAuthorityUrl: Text; RedirectURL: Text; Scopes: List of [SecretText]; var Token: Text)
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        Payload: SecretText;
        Response: Text;
        jObject: JsonObject;
        jToken: JsonToken;
        i: Integer;
        AuthorizationErr: Label 'Cannot get accesstoken\Status: %1\Reason: %2', Comment = '%1= statuscode %2= reasonphrase', Locked = true;
        PayloadLbl: Label 'client_id=%1&client_secret=%2&scope=%3&grant_type=client_credentials', Comment = '%1= client id %2= client secret %3= scope', Locked = true;
        RedirectLbl: Label '%1&redirect_uri=%2', Comment = '%1=payload %2= redirect url', Locked = true;
    begin
        // It may take a while for a rotated secret to be active, therefore 3 tries with a generous sleep time
        // Only loop when the client was invalid
        for i := 1 to 3 do begin
            Payload := SecretStrSubstNo(PayloadLbl, ClientId, ClientSecret, Scopes.Get(1));
            if RedirectURL <> '' then
                Payload := SecretStrSubstNo(RedirectLbl, Payload, RedirectURL);

            HttpContent.WriteFrom(Payload);
            HttpContent.GetHeaders(HttpHeaders);
            HttpHeaders.Remove('Content-Type');
            HttpHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');
            HttpRequestMessage.Content := HttpContent;
            HttpRequestMessage.SetRequestUri(OAuthAuthorityUrl);
            HttpRequestMessage.Method('POST');
            HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
            HttpResponseMessage.Content.ReadAs(Response);
            if HttpResponseMessage.HttpStatusCode = 200 then begin
                if not jObject.ReadFrom(Response) then
                    Error(HttpResponseMessage.ReasonPhrase);

                jObject.Get('access_token', jToken);
                Token := jToken.AsValue().AsText();
                exit;
            end;

            if i > 2 then
                Error(AuthorizationErr, HttpResponseMessage.HttpStatusCode, Response);

            Clear(HttpClient);
            Clear(HttpRequestMessage);
            Clear(HttpResponseMessage);
            Sleep(10000);
        end;
    end;

    [NonDebuggable]
    local procedure GetAccessTokenProperties(Token: Text)
    var
        Base64: Codeunit "Base64 Convert";
        TypeHelper: Codeunit "Type Helper";
        SplitToken: List of [Text];
        jArray: JsonArray;
        jObject: JsonObject;
        jToken: JsonToken;
        Payload: Text;
    begin
        AccessTokenExpires := CurrentDateTime + (3000 * 1000);
        SplitToken := Token.Split('.');
        if SplitToken.Count < 2 then
            exit;

        Payload := SplitToken.Get(2);
        while (StrLen(Payload) mod 4) <> 0 do
            Payload := Payload + '=';

        Payload := Base64.FromBase64(Payload);
        if not jObject.ReadFrom(Payload) then
            exit;

        if jObject.Get('roles', jToken) then begin
            jArray := jToken.AsArray();
            foreach jToken in jArray do
                Roles.Add(jToken.AsValue().AsText());
        end;

        if jObject.Get('exp', jToken) then
            AccessTokenExpires := TypeHelper.EvaluateUnixTimestamp(jToken.AsValue().AsInteger());
    end;

    internal procedure GetAccessToken(var NewAccessToken: SecretText; var NewAccessTokenExpires: DateTime)
    begin
        NewAccessToken := AccessToken;
        NewAccessTokenExpires := AccessTokenExpires;
    end;

    internal procedure GetRoles(): List of [Text]
    begin
        exit(Roles);
    end;
}