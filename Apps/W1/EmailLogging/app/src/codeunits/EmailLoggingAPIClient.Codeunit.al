codeunit 1682 "Email Logging API Client" implements "Email Logging API Client"
{
    Access = Internal;

    var
        CategoryTok: Label 'Email Logging', Locked = true;
        GraphUriTxt: Label 'https://graph.microsoft.com/v1.0/users/%1', Locked = true;
        GetMessagesUriTxt: Label '/mailfolders/inbox/messages?$top=%1&$select=%2', Locked = true;
        DeleteMessageUriTxt: Label '/mailfolders/inbox/messages/%1', Locked = true;
        MoveMessageUriTxt: Label '/mailfolders/inbox/messages/%1/move', Locked = true;
        SelectedFieldsTxt: Label 'id,internetMessageId,isDraft,sentDateTime,receivedDateTime,subject,webLink,sender,toRecipients,ccRecipients', Locked = true;
        CannotGetMessagesTxt: Label 'Cannot get the messages. Status code %1. Error: %2.', Locked = true;
        CannotDeleteMessageTxt: Label 'Cannot delete the message. Status code %1. Error: %2.', Locked = true;
        CannotArchiveMessageTxt: Label 'Cannot archive the message. Status code %1. Error: %2.', Locked = true;
        MessageDeletedTxt: Label 'The message is deleted.', Locked = true;
        MessageArchivedTxt: Label 'The message has been moved to the Archive folder.', Locked = true;
        FailedGetRequestErr: Label 'GET request failed with status code %1.', Comment = '%1 - Http status code';
        FailedGetRequestTxt: Label 'GET request failed with status code %1.', Locked = true;
        FailedDeleteRequestErr: Label 'DELETE request failed with status code %1.', Comment = '%1 - Http status code';
        FailedDeleteRequestTxt: Label 'DELETE request failed with status code %1.', Locked = true;
        FailedPostRequestErr: Label 'POST request failed with status code %1.', Comment = '%1 - Http status code';
        FailedPostRequestTxt: Label 'POST request failed with status code %1.', Locked = true;
        FailedRequestErr: Label 'Request failed with status code %1.', Comment = '%1 - Http status code';
        RestAPINotSupportedErr: Label 'REST API is not yet supported for this mailbox', Locked = true;
        TheMailboxIsNotValidErr: Label 'We cannot connect to the shared mailbox in Office 365.\\This might be because the Exchange user does not have a valid license for Office 365.';

    [NonDebuggable]
    internal procedure GetMessages(AccessToken: Text; EmailAddress: Text; MaxCount: Integer; var JsonObject: JsonObject)
    var
        RequestUri: Text;
        ErrorMessage: Text;
        StatusCode: Integer;
    begin
        RequestUri := StrSubstNo(GraphUriTxt, EmailAddress) + StrSubstNo(GetMessagesUriTxt, MaxCount, SelectedFieldsTxt);
        if not TryGet(AccessToken, RequestUri, JsonObject, StatusCode, ErrorMessage) then begin
            if ErrorMessage = '' then
                ErrorMessage := GetLastErrorText();
            Session.LogMessage('0000FXW', StrSubstNo(CannotGetMessagesTxt, StatusCode, ErrorMessage), Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(ErrorMessage);
        end;
    end;

    [NonDebuggable]
    internal procedure DeleteMessage(AccessToken: Text; EmailAddress: Text; MessageId: Text)
    var
        RequestUri: Text;
        ErrorMessage: Text;
        StatusCode: Integer;
    begin
        RequestUri := StrSubstNo(GraphUriTxt, EmailAddress) + StrSubstNo(DeleteMessageUriTxt, MessageId);
        if not TryDelete(AccessToken, RequestUri, StatusCode, ErrorMessage) then begin
            if ErrorMessage = '' then
                ErrorMessage := GetLastErrorText();
            Session.LogMessage('0000FXY', StrSubstNo(CannotDeleteMessageTxt, StatusCode, ErrorMessage), Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(ErrorMessage);
        end;
        Session.LogMessage('0000FXZ', MessageDeletedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    [NonDebuggable]
    internal procedure ArchiveMessage(AccessToken: Text; EmailAddress: Text; SourceMessageId: Text; var TargetMessageJsonObject: JsonObject)
    var
        RequestJsonObject: JsonObject;
        ResponseJsonObject: JsonObject;
        RequestUri: Text;
        ErrorMessage: Text;
        StatusCode: Integer;
    begin
        RequestUri := StrSubstNo(GraphUriTxt, EmailAddress) + StrSubstNo(MoveMessageUriTxt, SourceMessageId);
        RequestJsonObject.Add('destinationId', 'archive');
        if not TryPost(AccessToken, RequestUri, RequestJsonObject, ResponseJsonObject, StatusCode, ErrorMessage) then begin
            if ErrorMessage = '' then
                ErrorMessage := GetLastErrorText();
            Session.LogMessage('0000FY0', StrSubstNo(CannotArchiveMessageTxt, StatusCode, ErrorMessage), Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Error(ErrorMessage);
        end;
        TargetMessageJsonObject := ResponseJsonObject;
        Session.LogMessage('0000FY1', MessageArchivedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryGet(AccessToken: Text; RequestUri: Text; var JsonObject: JsonObject; var StatusCode: Integer; var ErrorMessage: Text)
    begin
        if not Get(AccessToken, RequestUri, JsonObject, StatusCode, ErrorMessage) then
            Error('');
    end;

    [NonDebuggable]
    local procedure Get(AccessToken: Text; RequestUri: Text; var ResponseJsonObject: JsonObject; var StatusCode: Integer; var ErrorMessage: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpResponseMessage: HttpResponseMessage;
        JsonContent: Text;
    begin
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add('Accept', 'application/json');
        HttpHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        if not HttpClient.Get(RequestUri, HttpResponseMessage) then begin
            Session.LogMessage('0000FY2', StrSubstNo(FailedGetRequestTxt, '-'), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            ErrorMessage := StrSubstNo(FailedGetRequestErr, '-');
            exit(false);
        end;

        StatusCode := HttpResponseMessage.HttpStatusCode();
        if StatusCode <> 200 then begin // 200 - OK
            Session.LogMessage('0000FY3', StrSubstNo(FailedGetRequestTxt, StatusCode), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            ErrorMessage := GetHttpErrorMessageAsText(HttpResponseMessage);
            Session.LogMessage('0000FY4', ErrorMessage, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;
        if not HttpResponseMessage.Content.ReadAs(JsonContent) then begin
            Session.LogMessage('0000FY5', StrSubstNo(FailedGetRequestTxt, StatusCode), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            ErrorMessage := StrSubstNo(FailedGetRequestErr, StatusCode);
            exit(false);
        end;
        if not ResponseJsonObject.ReadFrom(JsonContent) then begin
            Session.LogMessage('0000FY6', StrSubstNo(FailedGetRequestTxt, StatusCode), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            ErrorMessage := StrSubstNo(FailedGetRequestErr, StatusCode);
            exit(false);
        end;
        exit(true);
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryDelete(AccessToken: Text; RequestUri: Text; var StatusCode: Integer; var ErrorMessage: Text)
    begin
        if not Delete(AccessToken, RequestUri, StatusCode, ErrorMessage) then
            Error('');
    end;

    [NonDebuggable]
    local procedure Delete(AccessToken: Text; RequestUri: Text; var StatusCode: Integer; var ErrorMessage: Text): Boolean
    var
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HttpHeaders: HttpHeaders;
        HttpClient: HttpClient;
    begin
        HttpRequestMessage.Method('DELETE');
        HttpRequestMessage.SetRequestUri(RequestUri);
        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            Session.LogMessage('0000FY7', StrSubstNo(FailedDeleteRequestTxt, '-'), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            ErrorMessage := StrSubstNo(FailedDeleteRequestErr, '-');
            exit(false);
        end;

        StatusCode := HttpResponseMessage.HttpStatusCode;
        if not (StatusCode in [202, 204]) then begin // 202 - Accepted, 204 - No Content
            Session.LogMessage('0000FY8', StrSubstNo(FailedDeleteRequestTxt, StatusCode), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            ErrorMessage := GetHttpErrorMessageAsText(HttpResponseMessage);
            Session.LogMessage('0000FY9', ErrorMessage, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;
        exit(true);
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryPost(AccessToken: Text; RequestUri: Text; var RequestJsonObject: JsonObject; var ResponseJsonObject: JsonObject; var StatusCode: Integer; var ErrorMessage: Text)
    begin
        if not Post(AccessToken, RequestUri, RequestJsonObject, ResponseJsonObject, StatusCode, ErrorMessage) then
            Error('');
    end;

    [NonDebuggable]
    local procedure Post(AccessToken: Text; RequestUri: Text; var RequestJsonObject: JsonObject; var ResponseJsonObject: JsonObject; var StatusCode: Integer; var ErrorMessage: Text): Boolean
    var
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        RequestHttpHeaders: HttpHeaders;
        ContentHttpHeaders: HttpHeaders;
        HttpClient: HttpClient;
        JsonContent: Text;
    begin
        RequestJsonObject.WriteTo(JsonContent);
        HttpRequestMessage.Method('POST');
        HttpRequestMessage.SetRequestUri(RequestUri);
        HttpRequestMessage.GetHeaders(RequestHttpHeaders);
        RequestHttpHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        HttpContent.WriteFrom(JsonContent);
        HttpContent.GetHeaders(ContentHttpHeaders);
        ContentHttpHeaders.Clear();
        ContentHttpHeaders.Add('Content-Type', 'application/json');

        HttpRequestMessage.Content := HttpContent;

        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            Session.LogMessage('0000FYA', StrSubstNo(FailedPostRequestTxt, '-'), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        StatusCode := HttpResponseMessage.HttpStatusCode();
        if not (StatusCode in [201, 202]) then begin // 201 - Created, 202 - Accepted
            ErrorMessage := GetHttpErrorMessageAsText(HttpResponseMessage);
            Session.LogMessage('0000FYB', ErrorMessage, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        end;
        if not HttpResponseMessage.Content.ReadAs(JsonContent) then begin
            Session.LogMessage('0000FYC', StrSubstNo(FailedGetRequestTxt, StatusCode), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            ErrorMessage := StrSubstNo(FailedPostRequestErr, StatusCode);
            exit(false);
        end;
        if not ResponseJsonObject.ReadFrom(JsonContent) then begin
            Session.LogMessage('0000FYD', StrSubstNo(FailedGetRequestTxt, StatusCode), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            ErrorMessage := StrSubstNo(FailedPostRequestErr, StatusCode);
            exit(false);
        end;
        exit(true);
    end;

    [NonDebuggable]
    local procedure GetHttpErrorMessageAsText(var HttpResponseMessage: HttpResponseMessage): Text
    var
        ErrorMessage: Text;
    begin
        if not TryGetErrorMessage(HttpResponseMessage, ErrorMessage) then
            exit(StrSubstNo(FailedRequestErr, HttpResponseMessage.HttpStatusCode));

        ProcessErrorMessage(ErrorMessage);
        exit(ErrorMessage);
    end;

    [NonDebuggable]
    local procedure ProcessErrorMessage(var ErrorMessage: Text)
    begin
        if ErrorMessage.Contains(RestAPINotSupportedErr) then
            ErrorMessage := TheMailboxIsNotValidErr;
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryGetErrorMessage(var MailHttpResponseMessage: HttpResponseMessage; var ErrorMessage: Text);
    var
        ResponseJsonText: Text;
        JToken: JsonToken;
        ResponseJson: JsonObject;
    begin
        MailHttpResponseMessage.Content.ReadAs(ResponseJsonText);
        ResponseJson.ReadFrom(ResponseJsonText);
        ResponseJson.Get('error', JToken);
        JToken.AsObject().Get('message', JToken);
        ErrorMessage := JToken.AsValue().AsText();
    end;
}