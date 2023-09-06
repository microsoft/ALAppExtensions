table 51750 "Bus Queue"
{
    Access = Internal;
    Caption = 'Bus Queue';
    DrillDownPageId = "Bus Queues";
    LookupPageId = "Bus Queues";
    InherentEntitlements = RIMD;
    InherentPermissions = RIMD;
    Extensible = false;
    Permissions = tabledata "Job Queue Entry" = RM,
                  tabledata "Name/Value Buffer" = R;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(2; "HTTP Request Type"; Enum "Http Request Type")
        {
            Caption = 'HTTP Verb';
            DataClassification = CustomerContent;
        }
        field(3; URL; Text[2048])
        {
            Caption = 'URL';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Regex: Codeunit Regex;
                RegexURLTok: Label '[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)';
            begin
                if not Regex.IsMatch(URL, RegexURLTok, 0) then
                    Error(InvalidUriErr);
            end;
        }
        field(4; Headers; Text[2048])
        {
            Caption = 'Headers';
            DataClassification = CustomerContent;
        }
        field(5; "Content Headers"; Text[2048])
        {
            Caption = 'Content Headers';
            DataClassification = CustomerContent;
        }
        field(6; Body; Blob)
        {
            Caption = 'Body';
            DataClassification = CustomerContent;
        }
        field(7; Status; Enum "Bus Queue Status")
        {
            InitValue = Pending;
            Caption = 'Status';
            DataClassification = SystemMetadata;
        }
        field(8; "No. Of Tries"; Integer)
        {
            Caption = 'No. Of Tries';
            DataClassification = SystemMetadata;
        }
        field(9; "Max. No. Of Tries"; Integer)
        {
            InitValue = 3;
            Caption = 'Max. No. Of Tries';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Max. No. Of Tries" > 10 then
                    "Max. No. Of Tries" := 10;
                if "Max. No. Of Tries" < 1 then
                    "Max. No. Of Tries" := 1;
            end;
        }
        field(10; "Seconds Between Retries"; Integer)
        {
            InitValue = 60;
            Caption = 'Seconds Between Retries';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Seconds Between Retries" > 3600 then
                    "Seconds Between Retries" := 3600;
                if "Seconds Between Retries" < 1 then
                    "Seconds Between Retries" := 1;
            end;
        }
        field(11; "Category Code"; Code[10])
        {
            Caption = 'Category Code';
            DataClassification = CustomerContent;
        }
        field(12; "RecordId"; RecordId)
        {
            Caption = 'RecordId';
            DataClassification = CustomerContent;
        }
        field(13; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" where("Object Type" = const(Table));
            DataClassification = CustomerContent;
        }
        field(14; "System Id"; Guid)
        {
            Caption = 'System Id';
            DataClassification = SystemMetadata;
        }
        field(15; Codepage; Integer)
        {
            Caption = 'Codepage';
            DataClassification = CustomerContent;
        }
        field(16; "Use Task Scheduler"; Boolean)
        {
            InitValue = true;
            Editable = false;
            Caption = 'Use Task Scheduler';
            DataClassification = SystemMetadata;
        }
        field(17; "Raise Response Event"; Boolean)
        {
            InitValue = true;
            Editable = false;
            Caption = 'Raise Response Event';
            DataClassification = SystemMetadata;
        }
        field(18; "Use Certificate"; Boolean)
        {
            Caption = 'Use Certificate';
            DataClassification = CustomerContent;
        }
        field(19; "Is Text"; Boolean)
        {
            Caption = 'Is Text';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; Status)
        {
        }
    }

    var
        InvalidUriErr: Label 'The URI is not valid.';
        HeadersTooLongErr: Label 'Headers are too long. Maximum length is %1.', Comment = '%1 is field size';

    trigger OnInsert()
    var
        BusQueue: Record "Bus Queue";
    begin
        BusQueue.ReadIsolation := IsolationLevel::UpdLock;
        BusQueue.SetLoadFields("Entry No.");
        if BusQueue.FindLast() then
            "Entry No." := BusQueue."Entry No." + 1
        else
            "Entry No." := 1;
    end;

    internal procedure SaveHeaders(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    var
        JsonTextReaderWriterHeaders, JsonTextReaderWriterContentHeaders : Codeunit "Json Text Reader/Writer";
        Name, Value, HeadersTxt, ContentHeadersTxt : Text;
    begin
        if not TempNameValueBuffer.FindSet() then
            exit;

        JsonTextReaderWriterHeaders.WriteStartObject('');
        JsonTextReaderWriterContentHeaders.WriteStartObject('');
        repeat
            Name := TempNameValueBuffer.Name.Trim();
            Value := TempNameValueBuffer.GetValue();

            if IsContentHeader(Name) then
                JsonTextReaderWriterContentHeaders.WriteStringProperty(Name, Value)
            else
                JsonTextReaderWriterHeaders.WriteStringProperty(Name, Value);
        until TempNameValueBuffer.Next() = 0;
        JsonTextReaderWriterHeaders.WriteEndObject();
        JsonTextReaderWriterContentHeaders.WriteEndObject();

        HeadersTxt := JsonTextReaderWriterHeaders.GetJSonAsText();
        if StrLen(HeadersTxt) > MaxStrLen(Headers) then
            Error(HeadersTooLongErr, MaxStrLen(Headers))
        else
            Headers := CopyStr(HeadersTxt, 1, StrLen(HeadersTxt));

        ContentHeadersTxt := JsonTextReaderWriterContentHeaders.GetJSonAsText();
        if StrLen(ContentHeadersTxt) > MaxStrLen("Content Headers") then
            Error(HeadersTooLongErr, MaxStrLen("Content Headers"))
        else
            "Content Headers" := CopyStr(ContentHeadersTxt, 1, StrLen(ContentHeadersTxt));
    end;

    internal procedure UpdateStatus(IsSuccessStatusCode: Boolean)
    begin
        if IsSuccessStatusCode and ("No. Of Tries" <= "Max. No. Of Tries") then
            Status := Status::Processed;

        if (not IsSuccessStatusCode) and ("No. Of Tries" < "Max. No. Of Tries") then
            Status := Status::Retry;

        if (not IsSuccessStatusCode) and ("No. Of Tries" = "Max. No. Of Tries") then
            Status := Status::Error;
    end;

    internal procedure SaveBusQueueDetailed(): Integer
    var
        BusQueueDetailed: Record "Bus Queue Detailed";
    begin
        BusQueueDetailed."Parent Entry No." := "Entry No.";
        BusQueueDetailed.Status := Status;
        BusQueueDetailed."No. Of Try" := "No. Of Tries";
        BusQueueDetailed.Insert(true);

        exit(BusQueueDetailed."Entry No.");
    end;

    internal procedure SaveResponse(HttpResponseMessage: HttpResponseMessage; DetailedRequestID: Integer): Record "Bus Queue Response"
    var
        BusQueueResponse: Record "Bus Queue Response";
        BusQueueResponseImpl: Codeunit "Bus Queue Response Impl.";
        OutStreamBody, OutStreamHeaders : OutStream;
        InStreamBody: InStream;
        ContentHeaders: HttpHeaders;
    begin
        HttpResponseMessage.Content.ReadAs(InStreamBody);

        BusQueueResponse."HTTP Code" := HttpResponseMessage.HttpStatusCode();
        BusQueueResponse."Reason Phrase" := CopyStr(HttpResponseMessage.ReasonPhrase(), 1, MaxStrLen(BusQueueResponse."Reason Phrase"));
        HttpResponseMessage.Content.GetHeaders(ContentHeaders);
        BusQueueResponse.Headers.CreateOutStream(OutStreamHeaders, TextEncoding::UTF8);
        OutStreamHeaders.WriteText(BusQueueResponseImpl.GetHeadersAsJson(HttpResponseMessage.Headers(), ContentHeaders));
        BusQueueResponse.Body.CreateOutStream(OutStreamBody, TextEncoding::UTF8);
        if HttpResponseMessage.HttpStatusCode() = 0 then
            OutStreamBody.WriteText('No such host is known')
        else
            CopyStream(OutStreamBody, InStreamBody);
        BusQueueResponse."Bus Queue Entry No." := "Entry No.";
        BusQueueResponse."Bus Queue Detailed Entry No." := DetailedRequestID;
        BusQueueResponse."RecordId" := "RecordId";
        BusQueueResponse."Table No." := "Table No.";
        BusQueueResponse."System Id" := "System Id";
        BusQueueResponse.Insert(true);

        exit(BusQueueResponse);
    end;

    local procedure IsContentHeader(Header: Text): Boolean
    begin
        exit(Header in ['Allow', 'Content-Disposition', 'Content-Encoding', 'Content-Language', 'Content-Length', 'Content-Location',
            'Content-MD5', 'Content-Range', 'Content-Type', 'Expires', 'Last-Modified']);
    end;
}
