table 2406 "XS REST Web Service Parameters"
{
    Caption = 'REST Web Service Parameters';
    DataClassification = SystemMetadata;
    ReplicateData = false;

    fields
    {
        field(1; "PrimaryKey"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "RestMethod"; Option)
        {
            OptionMembers = get,post,delete,patch,put;
            DataClassification = SystemMetadata;
        }
        field(3; "URL"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Accept"; Text[30])
        {
            DataClassification = SystemMetadata;
        }
        field(5; "ETag"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(6; "IfModifiedSince"; DateTime)
        {
            DataClassification = SystemMetadata;
        }
        field(10; "AuthenticationType"; Option)
        {
            OptionMembers = Anonymous,Basic,OAuth;
            DataClassification = SystemMetadata;
        }
        field(11; "UserName"; Text[50])
        {
            DataClassification = SystemMetadata;
        }
        field(12; "Password"; Text[50])
        {
            DataClassification = SystemMetadata;
        }
        field(13; "ConsumerKey"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(14; "ConsumerSecret"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(15; "AccessKey"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(16; "AccessSecret"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(50; "Blob"; Blob)
        {
            DataClassification = SystemMetadata;
        }
        field(100; "HttpStatusCode"; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; PrimaryKey)
        {
            Clustered = true;
        }
    }

    var
        _requestContent: HttpContent;
        _requestContentSet: Boolean;
        _responseHeaders: HttpHeaders;
        _responseReasonPhrase: Text;

    procedure SetRequestContent(Value: HttpContent)
    begin
        _requestContent := Value;
        _requestContentSet := true;
    end;

    procedure HasRequestContent(): Boolean
    begin
        exit(_requestContentSet);
    end;

    procedure RequestContent(var ReturnValue: HttpContent)
    begin
        ReturnValue := _RequestContent;
    end;

    procedure SetResponseContent(Value: HttpContent)
    var
        InStr: InStream;
        OutStr: OutStream;
    begin
        Blob.CreateInStream(InStr);
        Value.ReadAs(InStr);

        Blob.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
    end;

    procedure HasResponseContent(): Boolean
    begin
        exit(Blob.HasValue());
    end;

    procedure ResponseContent(var Content: HttpContent)
    var
        InStr: InStream;
    begin
        if not HasResponseContent() then
            exit;

        Blob.CreateInStream(InStr);
        Content.WriteFrom(InStr);
    end;

    procedure SetResponseHeaders(Value: HttpHeaders)
    begin
        _responseHeaders := Value;
    end;

    procedure ResponseHeaders(): HttpHeaders
    begin
        exit(_ResponseHeaders);
    end;

    procedure SetResponseReasonPhrase(Value: Text)
    begin
        _responseReasonPhrase := Value;
    end;

    procedure ResponseReasonPhrase(): Text
    begin
        exit(_responseReasonPhrase);
    end;

    procedure InitializeRequestMessage(var RequestMessage: HttpRequestMessage)
    var
        Headers: HttpHeaders;
        Content: HttpContent;
    begin
        RequestMessage.Method := Format(RestMethod);
        RequestMessage.SetRequestUri(URL);

        RequestMessage.GetHeaders(Headers);

        if Accept <> '' then
            Headers.Add('Accept', Accept);

        if AuthenticationType <> AuthenticationType::Anonymous then
            Headers.Add('Authorization', GetAuthorizationHeader());

        if ETag <> '' then
            Headers.Add('if-Match', ETag);

        if Format(IfModifiedSince) <> '' then
            Headers.Add('if-Modified-Since', GetIfModifiedSinceHeader());

        if HasRequestContent() then begin
            RequestContent(Content);
            RequestMessage.Content := Content;
        end;
    end;

    procedure GetAuthorizationHeader() ReturnValue: Text
    begin
        case AuthenticationType of
            AuthenticationType::Basic:
                ReturnValue := GetBasicAuthorizationHeader();
            AuthenticationType::OAuth:
                ReturnValue := GetOAuthAuthorizationHeader();
        end;
    end;

    local procedure GetBasicAuthorizationHeader() ReturnValue: Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        AuthText: Text;
    begin
        AuthText := StrSubstNo('%1:%2', UserName, Password);
        ReturnValue := StrSubstNo('Basic %1', Base64Convert.ToBase64(AuthText));
    end;

    local procedure GetOAuthAuthorizationHeader() ReturnValue: Text
    var
        OAuth: Codeunit OAuth;
        HttpRequestType: Enum "Http Request Type";
    begin

        case Format(RestMethod).ToUpper() of
            'GET':
                OAuth.GetAuthorizationHeader(ConsumerKey, ConsumerSecret, AccessKey, AccessSecret, URL, HttpRequestType::GET, ReturnValue);
            'POST':
                OAuth.GetAuthorizationHeader(ConsumerKey, ConsumerSecret, AccessKey, AccessSecret, URL, HttpRequestType::POST, ReturnValue);
            'PATCH':
                OAuth.GetAuthorizationHeader(ConsumerKey, ConsumerSecret, AccessKey, AccessSecret, URL, HttpRequestType::PATCH, ReturnValue);
            'PUT':
                OAuth.GetAuthorizationHeader(ConsumerKey, ConsumerSecret, AccessKey, AccessSecret, URL, HttpRequestType::PUT, ReturnValue);
            'DELETE':
                OAuth.GetAuthorizationHeader(ConsumerKey, ConsumerSecret, AccessKey, AccessSecret, URL, HttpRequestType::DELETE, ReturnValue);
        end;
    end;

    local procedure GetIfModifiedSinceHeader() ReturnValue: Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        ReturnValue := TypeHelper.FormatDateTime(IfModifiedSince, 'R', '');
    end;

    procedure CommunicateWithXero(var SyncChange: Record "Sync Change"; NAVEntityID: Integer; XeroID: Text; SyncChangeDirection: Option Incoming,Outgoing; ChangeType: Option Create,Update,Delete," "; ModifiedSince: DateTime; UseModifiedSince: Boolean; EntityDataJsonTxt: Text; var JsonEntities: JsonArray; ListOfAdditionalParametersForReports: List of [Text]) IsSuccessStatusCode: Boolean
    var
        CommunicateWithXero: Codeunit "XS Communicate With Xero";
    begin
        IsSuccessStatusCode := CommunicateWithXero.CommunicateWithXero(Rec,
                                                                       SyncChange,
                                                                       NAVEntityID,
                                                                       XeroID,
                                                                       SyncChangeDirection,
                                                                       ChangeType, ModifiedSince,
                                                                       UseModifiedSince,
                                                                       EntityDataJsonTxt,
                                                                       JsonEntities,
                                                                       ListOfAdditionalParametersForReports);
    end;


}