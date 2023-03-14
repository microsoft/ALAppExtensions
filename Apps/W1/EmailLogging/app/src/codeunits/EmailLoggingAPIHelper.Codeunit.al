codeunit 1684 "Email Logging API Helper"
{
    Access = Internal;
    Permissions = tabledata "Email Logging Setup" = r;

    var
        EmailLoggingManagement: Codeunit "Email Logging Management";
        OAuthClient: Interface "Email Logging OAuth Client";
        APIClient: Interface "Email Logging API Client";
        Initialized: Boolean;
        CategoryTok: Label 'Email Logging', Locked = true;
        ContextGetMessagesTxt: Label 'Get messages';
        ContextCheckConnectionTxt: Label 'Check connection';
        ReachedBatchSizeTxt: Label 'Many messages are found in the folder. Reached batch size: %1.', Locked = true;
        SetupNotFoundErr: Label 'Email logging is not set up.';
        EmptyEmailAddressErr: Label 'You must provide an email address.';
        DisabledErr: Label 'Email logging is not enabled.';

    [NonDebuggable]
    internal procedure Initialize()
    begin
        if Initialized then
            exit;
        EmailLoggingManagement.InitializeOAuthClient(OAuthClient);
        EmailLoggingManagement.InitializeAPIClient(APIClient);
        Initialized := true;
    end;

    [NonDebuggable]
    internal procedure Initialize(var NewOAuthClient: Interface "Email Logging OAuth Client"; var NewAPIClient: Interface "Email Logging API Client")
    begin
        OAuthClient := NewOAuthClient;
        APIClient := NewAPIClient;
        Initialized := true;
    end;

    internal procedure IsSharedMailboxAvailable(EmailAddress: Text): Boolean
    begin
        if CheckConnection(EmailAddress) then
            exit(true);

        EmailLoggingManagement.LogActivityFailed(ContextCheckConnectionTxt, GetLastErrorText());
        exit(false);
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure CheckConnection(EmailAddress: Text)
    var
        MessagesJsonObject: JsonObject;
        ValueJsonToken: JsonToken;
        AccessToken: Text;
    begin
        AccessToken := GetAccessToken();
        APIClient.GetMessages(AccessToken, EmailAddress, 1, MessagesJsonObject);
        MessagesJsonObject.Get('value', ValueJsonToken);
    end;

    [NonDebuggable]
    internal procedure GetMessages(var MessageList: List of [JsonObject])
    var
        EmailLoggingSetup: Record "Email Logging Setup";
        AccessToken: Text;
        ResponseJsonObject: JsonObject;
        ValueJsonToken: JsonToken;
        ValueJsonArray: JsonArray;
        MessageJsonToken: JsonToken;
        MessageJsonObject: JsonObject;
        MessageCount: Integer;
        MessageIndex: Integer;
        BatchSize: Integer;
    begin
        AccessToken := GetAccessToken();
        GetEmailLoggingSetup(EmailLoggingSetup);
        BatchSize := EmailLoggingSetup.GetEmailBatchSize();
        APIClient.GetMessages(AccessToken, EmailLoggingSetup."Email Address", BatchSize, ResponseJsonObject);
        ResponseJsonObject.Get('value', ValueJsonToken);
        ValueJsonArray := ValueJsonToken.AsArray();
        MessageCount := ValueJsonArray.Count();
        if MessageCount = BatchSize then begin
            Session.LogMessage('0000G24', StrSubstNo(ReachedBatchSizeTxt, BatchSize), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            EmailLoggingManagement.LogActivityFailed(ContextGetMessagesTxt, StrSubstNo(ReachedBatchSizeTxt, BatchSize));
        end;

        for MessageIndex := 0 to MessageCount - 1 do begin
            ValueJsonArray.Get(MessageIndex, MessageJsonToken);
            MessageJsonObject := MessageJsonToken.AsObject();
            MessageList.Add(MessageJsonObject);
        end;
    end;

    [NonDebuggable]
    internal procedure ArchiveMesage(SourceMessageId: Text; var TargetMessageJsonObject: JsonObject)
    var
        EmailLoggingSetup: Record "Email Logging Setup";
        AccessToken: Text;
    begin
        GetEmailLoggingSetup(EmailLoggingSetup);
        AccessToken := GetAccessToken();
        APIClient.ArchiveMessage(AccessToken, EmailLoggingSetup."Email Address", SourceMessageId, TargetMessageJsonObject);
    end;

    [NonDebuggable]
    internal procedure DeleteMesage(MessageId: Text)
    var
        EmailLoggingSetup: Record "Email Logging Setup";
        AccessToken: Text;
    begin
        GetEmailLoggingSetup(EmailLoggingSetup);
        AccessToken := GetAccessToken();
        APIClient.DeleteMessage(AccessToken, EmailLoggingSetup."Email Address", MessageId);
    end;

    [NonDebuggable]
    local procedure GetAccessToken() AccessToken: Text
    var
        ErrorMessage: Text;
    begin
        Initialize();
        if OAuthClient.TryGetAccessToken(AccessToken) then
            exit;
        ErrorMessage := GetLastErrorText();
        Session.LogMessage('0000G25', ErrorMessage, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        Error(ErrorMessage);
    end;

    local procedure GetEmailLoggingSetup(var EmailLoggingSetup: Record "Email Logging Setup")
    begin
        if not EmailLoggingSetup.Get() then
            Error(SetupNotFoundErr);

        if EmailLoggingSetup."Email Address" = '' then
            Error(EmptyEmailAddressErr);

        if not EmailLoggingSetup.Enabled then
            Error(DisabledErr);
    end;

    internal procedure InitializeAPIClient(var APIClient: interface "Email Logging API Client")
    begin
        EmailLoggingManagement.InitializeAPIClient(APIClient);
    end;

    internal procedure InitializeOAuthClient(var OAuthClient: interface "Email Logging OAuth Client")
    begin
        EmailLoggingManagement.InitializeOAuthClient(OAuthClient);
    end;
}
