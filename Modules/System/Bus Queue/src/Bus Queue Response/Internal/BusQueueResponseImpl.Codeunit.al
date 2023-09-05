codeunit 51760 "Bus Queue Response Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Name/Value Buffer" = RI;

    var
        BusQueueResponse: Record "Bus Queue Response";

    internal procedure SetBusQueueResponse(NewBusQueueResponse: Record "Bus Queue Response")
    begin
        BusQueueResponse := NewBusQueueResponse;
    end;

    internal procedure GetHeaders(): InStream
    var
        HeadersInStream: InStream;
    begin
        BusQueueResponse.CalcFields(Headers);
        BusQueueResponse.Headers.CreateInStream(HeadersInStream, TextEncoding::UTF8);

        exit(HeadersInStream);
    end;

    internal procedure GetBody(): InStream
    var
        BodyInStream: InStream;
    begin
        BusQueueResponse.CalcFields(Body);
        BusQueueResponse.Body.CreateInStream(BodyInStream, TextEncoding::UTF8);

        exit(BodyInStream);
    end;

    internal procedure GetHTTPCode(): Integer
    begin
        exit(BusQueueResponse."HTTP Code");
    end;

    internal procedure GetReasonPhrase(): Text
    begin
        exit(BusQueueResponse."Reason Phrase");
    end;

    internal procedure GetRecordId(): RecordId
    begin
        exit(BusQueueResponse.RecordId());
    end;

    internal procedure GetTableNo(): Integer
    begin
        exit(BusQueueResponse."Table No.");
    end;

    internal procedure GetSystemId(): Guid
    begin
        exit(BusQueueResponse."System Id");
    end;

    internal procedure GetHeadersAsJson(HttpHeaders: HttpHeaders; HttpContentHeaders: HttpHeaders): Text
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        JsonObject: JsonObject;
        JsonText: Text;
    begin
        GetHeaders(HttpHeaders, TempNameValueBuffer);
        GetHeaders(HttpContentHeaders, TempNameValueBuffer);

        if not TempNameValueBuffer.FindSet() then
            exit;
        
        repeat
            JsonObject.Add(TempNameValueBuffer.Name, TempNameValueBuffer.GetValue());
        until TempNameValueBuffer.Next() = 0;

        JsonObject.WriteTo(JsonText);
        exit(JsonText);
    end;

    local procedure GetHeaders(HttpHeaders: HttpHeaders; var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    var
        Keys, Values: List of [Text];
        "Key", Value: Text;
    begin
        Keys := HttpHeaders.Keys();

        foreach "Key" in Keys do begin
            Clear(Values);
            if HttpHeaders.GetValues("Key", Values) then
                foreach Value in Values do begin
                    TempNameValueBuffer.SetRange(Name, "Key");
                    if TempNameValueBuffer.FindFirst() then begin
                        TempNameValueBuffer.SetValue(TempNameValueBuffer.GetValue() + ',' + Value);
                        TempNameValueBuffer.Modify();
                    end else
                        TempNameValueBuffer.AddNewEntry(CopyStr("Key", 1, 250), Value);
                end;
        end;
    end;
}