namespace Microsoft.EServices.EDocumentConnector.Continia;

using System.Utilities;

codeunit 148201 "Continia Mock Http Handler"
{
    Access = Internal;

    var
        ResponseStatusCodes: Dictionary of [Text, Integer];
        ResponseContents: Dictionary of [Text, Text];
        ResponseHeaders: Dictionary of [Text, Dictionary of [Text, Text]];
        DefaultRequest: Boolean;

    internal procedure AddResponse(Method: HttpRequestType; RequestPath: Text; StatusCode: Integer; ResponseContent: Text; Headers: Dictionary of [Text, Text])
    begin
        if StrPos(RequestPath, '?') > 0 then
            RequestPath := CopyStr(RequestPath, 1, StrPos(RequestPath, '?') - 1);

        IncludeResponse(Method, RequestPath, StatusCode, ResponseContent, Headers);
    end;

    internal procedure AddResponseWithParameters(Method: HttpRequestType; RequestPath: Text; StatusCode: Integer; ResponseContent: Text; Headers: Dictionary of [Text, Text])
    begin
        IncludeResponse(Method, RequestPath, StatusCode, ResponseContent, Headers);
    end;

    internal procedure AddResponse(Method: HttpRequestType; RequestPath: Text; StatusCode: Integer; ResponseContent: Text)
    var
        Headers: Dictionary of [Text, Text];
    begin
        AddResponse(Method, RequestPath, StatusCode, ResponseContent, Headers);
    end;

    internal procedure AddResponse(Method: HttpRequestType; RequestPath: Text; StatusCode: Integer)
    begin
        AddResponse(Method, RequestPath, StatusCode, '');
    end;

    internal procedure AddResponse(StatusCode: Integer; ResponseContent: Text)
    begin
        AddResponse(HttpRequestType::Unknown, '', StatusCode, ResponseContent);
    end;

    internal procedure GetResponse(Request: TestHttpRequestMessage) HttpResponseMessage: TestHttpResponseMessage
    var
        DictionaryKey: Text;
    begin
        if DefaultRequest then
            DictionaryKey := ''
        else
            DictionaryKey := GetDictionaryKey(Request.Path, Request.RequestType);
        HttpResponseMessage := GetResponse(Request, DictionaryKey);
    end;

    internal procedure GetResponseWithParameters(Request: TestHttpRequestMessage) HttpResponseMessage: TestHttpResponseMessage
    var
        DictionaryKey: Text;
    begin
        if DefaultRequest then
            DictionaryKey := ''
        else
            DictionaryKey := GetDictionaryKeyWithParameters(Request);
        HttpResponseMessage := GetResponse(Request, DictionaryKey);
    end;

    internal procedure HandleAuthorization(Request: TestHttpRequestMessage; var HttpResponseMessage: TestHttpResponseMessage): Boolean
    var
        ContiniaApiUrlMgt: Codeunit "Continia Api Url";
    begin
        if Request.Path = ContiniaApiUrlMgt.ClientAccessTokenUrl() then begin
            HttpResponseMessage.HttpStatusCode := 200;
            HttpResponseMessage.Content.WriteFrom(NavApp.GetResourceAsText('OauthToken200.txt', TextEncoding::UTF8));
            exit(true);
        end;
    end;

    internal procedure ClearHandler();
    begin
        Clear(ResponseStatusCodes);
        Clear(ResponseContents);
    end;

    local procedure ReplaceContentPlaceholders(OriginalContent: Text; Uri: Text): Text
    var
        Regex: Codeunit Regex;
        UriSegments: List of [Text];
        ParticipationProfileId: Text;
        DownloadUriPatternTok: Label '%1/download', Comment = '%1 = Uri', Locked = true;
    begin
        if OriginalContent.Contains('{random.guid}') then
            OriginalContent := Regex.Replace(OriginalContent, '{random.guid}', Format(CreateGuid(), 0, 9));

        if OriginalContent.Contains('{fileDownloadUrl}') then
            OriginalContent := Regex.Replace(OriginalContent, '{fileDownloadUrl}', StrSubstNo(DownloadUriPatternTok, Uri));

        if OriginalContent.Contains('{participationProfileId.ToLower}') then begin
            UriSegments := Uri.Split('/');
            ParticipationProfileId := UriSegments.Get(UriSegments.IndexOf('profiles') + 1);
            if ParticipationProfileId.EndsWith('.xml') then
                ParticipationProfileId := ParticipationProfileId.Substring(1, StrLen(ParticipationProfileId) - 4);
            OriginalContent := Regex.Replace(OriginalContent, '{participationProfileId.ToLower}', ParticipationProfileId.ToLower());
        end;
        exit(OriginalContent);
    end;

    local procedure GetDictionaryKey(RequestPath: Text; Method: HttpRequestType) returnValue: Text
    var
        KeyPatternTok: Label '%1;%2', Comment = '%1 = Method, %2 = RequestPath', Locked = true;
    begin
        returnValue := StrSubstNo(KeyPatternTok, Format(Method), RequestPath).ToLower();
    end;

    local procedure GetDictionaryKeyWithParameters(Request: TestHttpRequestMessage) returnValue: Text
    var
        KeyPatternTok: Label '%1;%2?%3', Comment = '%1 = Method, %2 = RequestPath, %3 = Parameters', Locked = true;
        Parameters: Dictionary of [Text, Text];
        Parameter: Text;
        QueryParameters: TextBuilder;
    begin
        Parameters := Request.QueryParameters();
        foreach Parameter in Parameters.Keys() do begin
            if QueryParameters.Length() > 0 then
                QueryParameters.Append('&');
            if Parameters.Get(Parameter) = '' then
                QueryParameters.Append(Parameter)
            else
                QueryParameters.Append(Parameter + '=' + Parameters.Get(Parameter));
        end;
        returnValue := StrSubstNo(KeyPatternTok, Format(Request.RequestType), Request.Path, QueryParameters.ToText()).ToLower();
    end;

    local procedure IncludeResponse(Method: HttpRequestType; RequestPath: Text; StatusCode: Integer; ResponseContent: Text; Headers: Dictionary of [Text, Text])
    var
        DictionaryKey: Text;
    begin
        if (Method = Method::Unknown) and (RequestPath = '') then begin
            DefaultRequest := true;
            DictionaryKey := '';
        end else
            DictionaryKey := GetDictionaryKey(RequestPath, Method);

        ResponseStatusCodes.Add(DictionaryKey, StatusCode);
        ResponseContents.Add(DictionaryKey, ResponseContent);
        if Headers.Count() > 0 then
            ResponseHeaders.Add(DictionaryKey, Headers);
    end;

    local procedure GetResponse(var Request: TestHttpRequestMessage; DictionaryKey: Text) HttpResponseMessage: TestHttpResponseMessage
    var
        Headers: Dictionary of [Text, Text];
        HeaderName: Text;
    begin
        HttpResponseMessage.HttpStatusCode := ResponseStatusCodes.Get(DictionaryKey);
        HttpResponseMessage.Content().WriteFrom(ReplaceContentPlaceholders(ResponseContents.Get(DictionaryKey), Request.Path));

        if ResponseHeaders.ContainsKey(DictionaryKey) then begin
            Headers := ResponseHeaders.Get(DictionaryKey);
            foreach HeaderName in Headers.Keys() do
                HttpResponseMessage.Headers.Add(HeaderName, Headers.Get(HeaderName));
        end;
        Clear(DefaultRequest);
    end;
}