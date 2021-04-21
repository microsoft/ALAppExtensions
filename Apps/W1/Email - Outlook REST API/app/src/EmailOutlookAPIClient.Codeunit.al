// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4508 "Email - Outlook API Client" implements "Email - Outlook API Client"
{
    var
        OutlookCateogryLbl: Label 'Outlook', Locked = true;
        GraphURLTxt: label 'https://graph.microsoft.com', Locked = true;
        SendEmailErr: Label 'Could not send the email message. Try again later.';
        EmailSentTxt: Label 'Email sent.', Locked = true;
        DraftEmailCreatedTxt: Label 'Draft email created.', Locked = true;
        AttachmentAddedTxt: Label 'Attachment added.', Locked = true;
        RestAPINotSupportedErr: Label 'REST API is not yet supported for this mailbox', Locked = true;
        TheMailboxIsNotValidErr: Label 'The mailbox is not valid.\\A likely cause of this error is that the user does not have a valid license for Office 365. To read about other potential causes, visit https://docs.microsoft.com/exchange/troubleshoot/user-and-shared-mailboxes/rest-api-is-not-yet-supported-for-this-mailbox-error.';

    [NonDebuggable]
    procedure GetAccountInformation(AccessToken: Text; var Email: Text[250]; var Name: Text[250]): Boolean
    begin
        exit(TryGetAccountInformation(AccessToken, Email, Name));
    end;

    [NonDebuggable]
    [TryFunction]
    procedure TryGetAccountInformation(AccessToken: Text; var Email: Text[250]; var Name: Text[250])
    var
        AccountHttpClient: HttpClient;
        AccountRequestHeaders: HttpHeaders;
        AccountResponseMessage: HttpResponseMessage;
        ResponseContent: Text;
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        AccountRequestHeaders := AccountHttpClient.DefaultRequestHeaders();
        AccountRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        if not AccountHttpClient.Get(GraphURLTxt + '/v1.0/me', AccountResponseMessage) then
            exit;

        AccountResponseMessage.Content().ReadAs(ResponseContent);
        JObject.ReadFrom(ResponseContent);

        JObject.Get('userPrincipalName', JToken);
        Email := CopyStr(JToken.AsValue().AsText(), 1, 250);

        JObject.Get('displayName', JToken);
        Name := CopyStr(JToken.AsValue().AsText(), 1, 250);
    end;

    /// <summary>
    /// Send email using Outlook API. If the message json parameter is <= 4 mb and wrapped in a message object it is sent in a single request, otherwise it is sent it in multiple requests
    /// </summary>
    /// <param name="AccessToken">Access token of the account.</param>
    /// <param name="MessageJson">The JSON representing the email message.</param>///
    [NonDebuggable]
    procedure SendEmail(AccessToken: Text; MessageJson: JsonObject)
    var
        JToken: JsonToken;
        Attachments: JsonArray;
        Attachment: JsonToken;
        MessageId: Text;
    begin
        if MessageJson.Contains('message') then
            SendMailSingleRequest(AccessToken, MessageJson)
        else begin
            MessageJson.Get('attachments', JToken);
            Attachments := JToken.AsArray();
            MessageJson.Remove('attachments');

            MessageId := CreateDraftMail(AccessToken, MessageJson);

            foreach Attachment in Attachments do
                PostAttachment(AccessToken, Attachment.AsObject(), MessageId);

            SendDraftMail(AccessToken, MessageId);
        end;
    end;

    [NonDebuggable]
    local procedure SendMailSingleRequest(AccessToken: Text; MessageJson: JsonObject)
    var
        MailHttpContent: HttpContent;
        MailHttpRequestMessage: HttpRequestMessage;
        MailHttpResponseMessage: HttpResponseMessage;
        MailRequestHeaders: HttpHeaders;
        MailContentHeaders: HttpHeaders;
        MailHttpClient: HttpClient;
        MessageJsonText: Text;
        HttpErrorMessage: Text;
        RequestUri: Text;
    begin
        MessageJson.WriteTo(MessageJsonText);
        RequestUri := GraphURLTxt + '/v1.0/me/sendMail';

        MailHttpRequestMessage.Method('POST');
        MailHttpRequestMessage.SetRequestUri(RequestUri);
        MailHttpRequestMessage.GetHeaders(MailRequestHeaders);
        MailRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        MailHttpContent.WriteFrom(MessageJsonText);
        MailHttpContent.GetHeaders(MailContentHeaders);
        MailContentHeaders.Clear();
        MailContentHeaders.Add('Content-Type', 'application/json');

        MailHttpRequestMessage.Content := MailHttpContent;

        if not MailHttpClient.Send(MailHttpRequestMessage, MailHttpResponseMessage) then begin
            Session.LogMessage('0000D1P', SendEmailErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCateogryLbl);
            Error(SendEmailErr);
        end;

        if MailHttpResponseMessage.HttpStatusCode <> 202 then begin
            HttpErrorMessage := GetHttpErrorMessageAsText(MailHttpResponseMessage);
            Session.LogMessage('0000D1Q', HttpErrorMessage, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', OutlookCateogryLbl);
            ProcessErrorMessageResponse(HttpErrorMessage);
        end else
            Session.LogMessage('0000D1R', EmailSentTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCateogryLbl);
    end;

    local procedure ProcessErrorMessageResponse(ErrorMessage: Text)
    begin
        if ErrorMessage.Contains(RestAPINotSupportedErr) then
            ErrorMessage := TheMailboxIsNotValidErr;
        Error(ErrorMessage);
    end;

    [NonDebuggable]
    local procedure CreateDraftMail(AccessToken: Text; MessageJson: JsonObject): Text
    var
        MailHttpContent: HttpContent;
        MailHttpRequestMessage: HttpRequestMessage;
        MailHttpResponseMessage: HttpResponseMessage;
        MailRequestHeaders: HttpHeaders;
        MailContentHeaders: HttpHeaders;
        MailHttpClient: HttpClient;
        JToken: JsonToken;
        ResponseJson: JsonObject;
        MessageJsonText: Text;
        ResponseJsonText: Text;
        HttpErrorMessage: Text;
        RequestUri: Text;
        MessageId: Text;
    begin
        MessageJson.WriteTo(MessageJsonText);
        RequestUri := GraphURLTxt + '/v1.0/me/messages';

        MailHttpRequestMessage.Method('POST');
        MailHttpRequestMessage.SetRequestUri(RequestUri);
        MailHttpRequestMessage.GetHeaders(MailRequestHeaders);
        MailRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        MailHttpContent.WriteFrom(MessageJsonText);
        MailHttpContent.GetHeaders(MailContentHeaders);
        MailContentHeaders.Clear();
        MailContentHeaders.Add('Content-Type', 'application/json');

        MailHttpRequestMessage.Content := MailHttpContent;

        if not MailHttpClient.Send(MailHttpRequestMessage, MailHttpResponseMessage) then begin
            Session.LogMessage('0000E9Y', SendEmailErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCateogryLbl);
            Error(SendEmailErr);
        end;

        if MailHttpResponseMessage.HttpStatusCode <> 201 then begin
            HttpErrorMessage := GetHttpErrorMessageAsText(MailHttpResponseMessage);
            Session.LogMessage('0000E9Z', HttpErrorMessage, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', OutlookCateogryLbl);
            Error(HttpErrorMessage);
        end else begin
            MailHttpResponseMessage.Content.ReadAs(ResponseJsonText);
            ResponseJson.ReadFrom(ResponseJsonText);
            ResponseJson.Get('id', JToken);
            MessageId := JToken.AsValue().AsText();
            Session.LogMessage('0000EA0', DraftEmailCreatedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCateogryLbl);
        end;

        exit(MessageId);
    end;

    [NonDebuggable]
    local procedure SendDraftMail(AccessToken: Text; MessageId: Text): Text
    var
        MailHttpContent: HttpContent;
        MailHttpRequestMessage: HttpRequestMessage;
        MailHttpResponseMessage: HttpResponseMessage;
        MailRequestHeaders: HttpHeaders;
        MailContentHeaders: HttpHeaders;
        MailHttpClient: HttpClient;
        HttpErrorMessage: Text;
        RequestUri: Text;
    begin
        RequestUri := GraphURLTxt + '/v1.0/me/messages/' + MessageId + '/send';

        MailHttpRequestMessage.Method('POST');
        MailHttpRequestMessage.SetRequestUri(RequestUri);
        MailHttpRequestMessage.GetHeaders(MailRequestHeaders);
        MailRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        MailHttpContent.GetHeaders(MailContentHeaders);
        MailContentHeaders.Clear();
        MailContentHeaders.Add('Content-Length', '0');

        if not MailHttpClient.Send(MailHttpRequestMessage, MailHttpResponseMessage) then begin
            Session.LogMessage('0000EA1', SendEmailErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCateogryLbl);
            Error(SendEmailErr);
        end;

        if MailHttpResponseMessage.HttpStatusCode <> 202 then begin
            HttpErrorMessage := GetHttpErrorMessageAsText(MailHttpResponseMessage);
            Session.LogMessage('0000EA2', HttpErrorMessage, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', OutlookCateogryLbl);
            Error(HttpErrorMessage);
        end else
            Session.LogMessage('0000EA3', EmailSentTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCateogryLbl);
    end;

    [NonDebuggable]
    local procedure PostAttachment(AccessToken: Text; AttachmentJson: JsonObject; MessageId: Text)
    var
        AttachmentHttpContent: HttpContent;
        AttachmentHttpRequestMessage: HttpRequestMessage;
        AttachmentHttpResponseMessage: HttpResponseMessage;
        AttachmentRequestHeaders: HttpHeaders;
        AttachmentContentHeaders: HttpHeaders;
        AttachmentHttpClient: HttpClient;
        AttachmentRequestJsonText: Text;
        HttpErrorMessage: Text;
        RequestUri: Text;
    begin
        RequestUri := GraphURLTxt + '/v1.0/me/messages/' + MessageId + '/attachments';

        AttachmentHttpRequestMessage.Method('POST');
        AttachmentHttpRequestMessage.SetRequestUri(RequestUri);
        AttachmentHttpRequestMessage.GetHeaders(AttachmentRequestHeaders);
        AttachmentRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        AttachmentJson.WriteTo(AttachmentRequestJsonText);
        AttachmentHttpContent.WriteFrom(AttachmentRequestJsonText);
        AttachmentHttpContent.GetHeaders(AttachmentContentHeaders);
        AttachmentContentHeaders.Clear();
        AttachmentContentHeaders.Add('Content-Type', 'application/json');

        AttachmentHttpRequestMessage.Content := AttachmentHttpContent;

        if not AttachmentHttpClient.Send(AttachmentHttpRequestMessage, AttachmentHttpResponseMessage) then begin
            Session.LogMessage('0000EA4', SendEmailErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCateogryLbl);
            Error(SendEmailErr);
        end;

        if AttachmentHttpResponseMessage.HttpStatusCode <> 201 then begin
            HttpErrorMessage := GetHttpErrorMessageAsText(AttachmentHttpResponseMessage);
            Session.LogMessage('0000EA5', HttpErrorMessage, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', OutlookCateogryLbl);
            Error(HttpErrorMessage);
        end else
            Session.LogMessage('0000EA6', AttachmentAddedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCateogryLbl);
    end;

    [NonDebuggable]
    local procedure GetHttpErrorMessageAsText(MailHttpResponseMessage: HttpResponseMessage): Text
    var
        JToken: JsonToken;
        ResponseJson: JsonObject;
        ResponseJsonText: Text;
    begin
        MailHttpResponseMessage.Content.ReadAs(ResponseJsonText);
        ResponseJson.ReadFrom(ResponseJsonText);
        ResponseJson.Get('error', JToken);
        JToken.AsObject().Get('message', JToken);
        exit(JToken.AsValue().AsText());
    end;
}