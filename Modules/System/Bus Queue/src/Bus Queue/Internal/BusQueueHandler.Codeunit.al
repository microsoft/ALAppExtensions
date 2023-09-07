codeunit 51755 "Bus Queue Handler"
{
    Access = Internal;
    TableNo = "Bus Queue";
    InherentEntitlements = X;
    InherentPermissions = X;

    internal procedure Handle(var BusQueue: Record "Bus Queue"): Record "Bus Queue Response"
    var
        BusQueueResponse: Record "Bus Queue Response";
        HttpResponseMessage: HttpResponseMessage;
    begin
        Send(BusQueue, HttpResponseMessage);

        BusQueue."No. Of Tries" += 1;
        BusQueue.UpdateStatus(HttpResponseMessage.IsSuccessStatusCode());
        BusQueueResponse := BusQueue.SaveResponse(HttpResponseMessage, BusQueue.SaveBusQueueDetailed());
        BusQueue.Modify();

        exit(BusQueueResponse);
    end;

    local procedure Send(BusQueue: Record "Bus Queue"; var HttpResponseMessage: HttpResponseMessage)
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpHeaders, HttpContentHeaders: HttpHeaders;
    begin
        HttpRequestMessage.SetRequestUri(BusQueue.URL);
        HttpRequestMessage.Method(Format(BusQueue."HTTP Request Type"));
        SetHttpBody(BusQueue, HttpContent, HttpRequestMessage);
        SetHttpHeaders(BusQueue, HttpHeaders, HttpRequestMessage);
        SetContentHttpHeaders(BusQueue, HttpContentHeaders, HttpRequestMessage);
        //SetCertificate(BusQueue, HttpClient);
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then;
    end;

    local procedure SetHttpBody(BusQueue: Record "Bus Queue"; var HttpContent: HttpContent; var HttpRequestMessage: HttpRequestMessage)
    var
        StreamReader: DotNet StreamReader;
        Encoding: DotNet Encoding;
        InStream: InStream;
    begin
        if not BusQueue.Body.HasValue() then
            exit;

        BusQueue.Body.CreateInStream(InStream);
        StreamReader := StreamReader.StreamReader(InStream, Encoding.GetEncoding(BusQueue.Codepage));
        HttpContent.WriteFrom(InStream);
        HttpRequestMessage.Content(HttpContent);
    end;

    local procedure SetHttpHeaders(BusQueue: Record "Bus Queue"; var HttpHeaders: HttpHeaders; var HttpRequestMessage: HttpRequestMessage)
    var
        JsonHeaders: JsonObject;
    begin
        if BusQueue.Headers = '' then
            exit;
        
        JsonHeaders.ReadFrom(BusQueue.Headers);
        HttpHeaders.Clear();
        HttpRequestMessage.GetHeaders(HttpHeaders);
        SetHeaders(JsonHeaders, HttpHeaders);

        if not HttpHeaders.Contains('User-Agent') then
            HttpHeaders.Add('User-Agent', 'Dynamics 365 Business Central');
    end;

    local procedure SetContentHttpHeaders(BusQueue: Record "Bus Queue"; var HttpContentHeaders: HttpHeaders; var HttpRequestMessage: HttpRequestMessage)
    var
        JsonContentHeaders: JsonObject;
    begin
        if BusQueue."Content Headers" = '' then
            exit;
        
        JsonContentHeaders.ReadFrom(BusQueue."Content Headers");
        HttpContentHeaders.Clear();
        HttpRequestMessage.Content.GetHeaders(HttpContentHeaders);
        SetHeaders(JsonContentHeaders, HttpContentHeaders);
    end;

    local procedure SetHeaders(JsonHeaders: JsonObject; var HttpHeaders: HttpHeaders)
    var
        JsonTok: JsonToken;
        Keys: List of [Text];
        "Key", Value : Text;
    begin
        Keys := JsonHeaders.Keys();

        foreach "Key" in Keys do begin
            JsonHeaders.Get("Key", JsonTok);
            Value := JsonTok.AsValue().AsText();

            if not TryAddHeaderWithValidation(HttpHeaders, "Key", Value) then
                HttpHeaders.TryAddWithoutValidation("Key", Value);
        end;
    end;

    [NonDebuggable]
    local procedure SetCertificate(BusQueue: Record "Bus Queue"; var HttpClient: HttpClient)
    var
        Certificate, Password: Text;
    begin
        if not BusQueue."Use Certificate" then
            exit;

        if IsolatedStorage.Get('Certificate', Certificate) then;
        if IsolatedStorage.Get('Password', Password) then;

        TryAddCertificate(HttpClient, Certificate, Password);
    end;

    [TryFunction]
    local procedure TryAddHeaderWithValidation(var HttpHeaders: HttpHeaders; "Key": Text; Value: Text)
    begin
        HttpHeaders.Add("Key", Value);
    end;

    [TryFunction]
    local procedure TryAddCertificate(var HttpClient: HttpClient; Certificate: Text; Password: Text)
    begin
        if Certificate <> '' then
            if Password <> '' then
                HttpClient.AddCertificate(Certificate, Password)
            else
                HttpClient.AddCertificate(Certificate);
    end;
}