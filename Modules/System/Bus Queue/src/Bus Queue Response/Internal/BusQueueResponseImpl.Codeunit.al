codeunit 51760 "Bus Queue Response Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

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
        HttpHeadersTxt, HttpContentHeadersTxt: Text;
    begin
        HttpHeadersTxt := Convert(HttpHeaders);
        HttpContentHeadersTxt := Convert(HttpContentHeaders);
        
        HttpHeadersTxt := HttpHeadersTxt.TrimEnd('}');
        HttpHeadersTxt += ',';
        HttpContentHeadersTxt := HttpContentHeadersTxt.TrimStart('{');

        exit(HttpHeadersTxt + HttpContentHeadersTxt);
    end;

    local procedure Convert(HttpHeaders: HttpHeaders): Text
    var
        JsonConvert: DotNet JsonConvert;
        Keys, Values : List of [Text];
        "Key", Value, Val, JsonText : Text;
        Tb: TextBuilder;
    begin
        Keys := HttpHeaders.Keys();
        if Keys.Count() = 0 then
            exit;

        Tb.Append('{');

        foreach "Key" in Keys do begin
            Clear(Values);
            if HttpHeaders.GetValues("Key", Values) then begin
                Val := '';
                foreach Value in Values do
                    Val += Value + ',';

                Val := Val.TrimEnd(',');
                Tb.Append('"' + "Key" + '": ' + JsonConvert.SerializeObject(Val) + ',');
            end;
        end;

        JsonText := Tb.ToText().TrimEnd(',') + '}';
        
        exit(JsonText);
    end;
}