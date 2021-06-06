// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4508 "Email - Outlook API Client" implements "Email - Outlook API Client"
{
    var
        OutlookCategoryLbl: Label 'Outlook', Locked = true;
        GraphURLTxt: label 'https://graph.microsoft.com', Locked = true;
        SendEmailErr: Label 'Could not send the email message. Try again later.';
        SendEmailCodeErr: Label 'Failed to send email with status code %1.', Comment = '%1 - Http status code', Locked = true;
        EmailSentTxt: Label 'Email sent.', Locked = true;
        DraftEmailCreatedTxt: Label 'Draft email created.', Locked = true;
        AttachmentAddedTxt: Label 'Attachment added.', Locked = true;
        UploadSessionStartedLbl: Label 'Upload session started.', Locked = true;
        AttachmentRangeUploadedLbl: Label 'Uploaded attachment byte range: %1-%2/%3', Comment = '%1 - From byte, %2 - To byte, %3 - Total bytes', Locked = true;
        AttachmentUploadedLbl: Label 'Uploaded attachment.', Locked = true;
        AttachmentUploadedErr: Label 'Failed to upload attachment.', Locked = true;
        AttachmentPostErr: Label 'Failed to post attachment.', Locked = true;
        AttachmentRangeUploadErr: Label 'Failed to upload attachment byte range: %1-%2/%3', Comment = '%1 - From byte, %2 - To byte, %3 - Total bytes', Locked = true;
        ContentRangeLbl: Label 'bytes %1-%2/%3', Comment = '%1 - From byte, %2 - To byte, %3 - Total bytes', Locked = true;
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
                if Attachment.AsObject().Contains('AttachmentItem') then
                    UploadAttachment(AccessToken, Attachment.AsObject(), MessageId)
                else
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
            Session.LogMessage('0000D1P', SendEmailErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            Error(SendEmailErr);
        end;

        if MailHttpResponseMessage.HttpStatusCode <> 202 then begin
            HttpErrorMessage := GetHttpErrorMessageAsText(MailHttpResponseMessage);
            Session.LogMessage('0000D1Q', HttpErrorMessage, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            ProcessErrorMessageResponse(HttpErrorMessage);
        end else
            Session.LogMessage('0000D1R', EmailSentTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
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
            Session.LogMessage('0000E9Y', SendEmailErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            Error(SendEmailErr);
        end;

        if MailHttpResponseMessage.HttpStatusCode <> 201 then begin
            HttpErrorMessage := GetHttpErrorMessageAsText(MailHttpResponseMessage);
            Session.LogMessage('0000E9Z', HttpErrorMessage, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            Error(HttpErrorMessage);
        end else begin
            MailHttpResponseMessage.Content.ReadAs(ResponseJsonText);
            ResponseJson.ReadFrom(ResponseJsonText);
            ResponseJson.Get('id', JToken);
            MessageId := JToken.AsValue().AsText();
            Session.LogMessage('0000EA0', DraftEmailCreatedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
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
            Session.LogMessage('0000EA1', SendEmailErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            Error(SendEmailErr);
        end;

        if MailHttpResponseMessage.HttpStatusCode <> 202 then begin
            HttpErrorMessage := GetHttpErrorMessageAsText(MailHttpResponseMessage);
            Session.LogMessage('0000EA2', HttpErrorMessage, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            Error(HttpErrorMessage);
        end else
            Session.LogMessage('0000EA3', EmailSentTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
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
            Session.LogMessage('0000EA4', AttachmentPostErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            Error(SendEmailErr);
        end;

        if AttachmentHttpResponseMessage.HttpStatusCode <> 201 then begin
            HttpErrorMessage := GetHttpErrorMessageAsText(AttachmentHttpResponseMessage);
            Session.LogMessage('0000EA5', HttpErrorMessage, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            Error(HttpErrorMessage);
        end else
            Session.LogMessage('0000EA6', AttachmentAddedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
    end;

    [NonDebuggable]
    local procedure UploadAttachment(AccessToken: Text; AttachmentJson: JsonObject; MessageId: Text)
    var
        Base64Convert: Codeunit "Base64 Convert";
        AttachmentTempBlob: Codeunit "Temp Blob";
        AttachmentOutStream: OutStream;
        AttachmentInStream: Instream;
        AttachmentHttpClient: HttpClient;
        AttachmentRequestHeaders: HttpHeaders;
        AttachmentContentHeaders: HttpHeaders;
        AttachmentHttpContent: HttpContent;
        AttachmentHttpResponseMessage: HttpResponseMessage;
        AttachmentHttpRequestMessage: HttpRequestMessage;
        FromByte, ToByte, TotalBytes, Range : Integer;
        RequestJsonText, AttachmentContentInBase64, HttpErrorMessage, UploadUrl, RequestUri : Text;
    begin
        RequestUri := GraphURLTxt + '/v1.0/me/messages/' + MessageId + '/attachments/createUploadSession';

        AttachmentContentInBase64 := GetAttachmentContent(AttachmentJson);
        AttachmentJson.WriteTo(RequestJsonText);

        AttachmentHttpRequestMessage.Method('POST');
        AttachmentHttpRequestMessage.SetRequestUri(RequestUri);
        AttachmentHttpRequestMessage.GetHeaders(AttachmentRequestHeaders);
        AttachmentRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        AttachmentHttpContent.WriteFrom(RequestJsonText);
        AttachmentHttpContent.GetHeaders(AttachmentContentHeaders);
        AttachmentContentHeaders.Clear();
        AttachmentContentHeaders.Add('Content-Type', 'application/json');

        AttachmentHttpRequestMessage.Content := AttachmentHttpContent;

        if not AttachmentHttpClient.Send(AttachmentHttpRequestMessage, AttachmentHttpResponseMessage) then begin
            Session.LogMessage('0000ETN', AttachmentUploadedErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            Error(SendEmailErr);
        end;

        if AttachmentHttpResponseMessage.HttpStatusCode <> 201 then begin
            HttpErrorMessage := GetHttpErrorMessageAsText(AttachmentHttpResponseMessage);
            Session.LogMessage('0000ETO', HttpErrorMessage, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            Error(HttpErrorMessage);
        end else begin
            UploadUrl := GetUploadUrl(AttachmentHttpResponseMessage);
            Session.LogMessage('0000D1R', UploadSessionStartedLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
        end;

        FromByte := 0;
        TotalBytes := GetAttachmentSize(AttachmentJson);
        Range := MaximumAttachmentSizeInBytes();

        AttachmentTempBlob.CreateOutStream(AttachmentOutStream);
        Base64Convert.FromBase64(AttachmentContentInBase64, AttachmentOutStream);
        AttachmentTempBlob.CreateInStream(AttachmentInStream);

        while FromByte < TotalBytes do begin
            ToByte := FromByte + Range - 1;
            if ToByte >= TotalBytes then begin
                ToByte := TotalBytes - 1;
                Range := ToByte - FromByte + 1;
            end;

            UploadAttachmentRange(UploadUrl, AttachmentInStream, FromByte, ToByte, TotalBytes, Range);

            FromByte := ToByte + 1;
        end;
    end;

    [NonDebuggable]
    local procedure UploadAttachmentRange(UploadUrl: Text; AttachmentInStream: InStream; FromByte: Integer; ToByte: Integer; TotalBytes: Integer; Range: Integer)
    var
        AttachmentRangeTempBlob: Codeunit "Temp Blob";
        AttachmentOutStream: OutStream;
        AttachmentRangeInStream: Instream;
        AttachmentHttpClient: HttpClient;
        AttachmentHttpContentHeaders: HttpHeaders;
        AttachmentHttpContent: HttpContent;
        AttachmentHttpResponseMessage: HttpResponseMessage;
        AttachmentHttpRequestMessage: HttpRequestMessage;
        AttachmentHttpRequestHeaders: HttpHeaders;
        ContentLength: Integer;
        HttpErrorMessage: Text;
    begin
        AttachmentRangeTempBlob.CreateOutStream(AttachmentOutStream);
        CopyStream(AttachmentOutStream, AttachmentInStream, Range); // copy range of bytes to upload
        AttachmentRangeTempBlob.CreateInStream(AttachmentRangeInStream);

        AttachmentHttpRequestMessage.Method('PUT');
        AttachmentHttpRequestMessage.SetRequestUri(UploadUrl);

        AttachmentHttpContent.WriteFrom(AttachmentRangeInStream);
        AttachmentHttpContent.GetHeaders(AttachmentHttpContentHeaders);
        AttachmentHttpContentHeaders.Clear();
        ContentLength := ToByte - FromByte + 1;
        AttachmentHttpContentHeaders.Add('Content-Type', 'application/octet-stream');
        AttachmentHttpContentHeaders.Add('Content-Length', Format(ContentLength));
        AttachmentHttpContentHeaders.Add('Content-Range', StrSubstNo(ContentRangeLbl, FromByte, ToByte, TotalBytes));

        AttachmentHttpRequestMessage.Content := AttachmentHttpContent;
        AttachmentHttpRequestMessage.GetHeaders(AttachmentHttpRequestHeaders);
        AttachmentHttpRequestHeaders.Clear();
        AttachmentHttpRequestHeaders.Add('Keep-alive', 'true');

        if not AttachmentHttpClient.Send(AttachmentHttpRequestMessage, AttachmentHttpResponseMessage) then begin
            Session.LogMessage('0000ETP', AttachmentRangeUploadErr, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            Error(SendEmailErr);
        end;

        if AttachmentHttpResponseMessage.HttpStatusCode <> 200 then begin
            if AttachmentHttpResponseMessage.HttpStatusCode = 201 then begin
                Session.LogMessage('0000ETQ', AttachmentUploadedLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
                exit;
            end;
            HttpErrorMessage := GetHttpErrorMessageAsText(AttachmentHttpResponseMessage);
            Session.LogMessage('0000ETR', HttpErrorMessage, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            Error(HttpErrorMessage);
        end else
            Session.LogMessage('0000ETS', StrSubstNo(AttachmentRangeUploadedLbl, FromByte, ToByte, TotalBytes), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
    end;

    [NonDebuggable]
    local procedure GetHttpErrorMessageAsText(MailHttpResponseMessage: HttpResponseMessage): Text
    var
        ErrorMessage: Text;
    begin
        if not TryGetErrorMessage(MailHttpResponseMessage, ErrorMessage) then begin
            ErrorMessage := SendEmailErr;
            Session.LogMessage('0000EZA', StrSubstNo(SendEmailCodeErr, MailHttpResponseMessage.HttpStatusCode), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
        end;

        exit(ErrorMessage);
    end;

    [TryFunction]
    local procedure TryGetErrorMessage(MailHttpResponseMessage: HttpResponseMessage; var ErrorMessage: Text);
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

    [NonDebuggable]
    local procedure GetAttachmentContent(var AttachmentJson: JsonObject): Text
    var
        JToken: JsonToken;
        JTokenContent: JsonToken;
        AttachmentContentInBase64: Text;
    begin
        AttachmentJson.Get('AttachmentItem', JToken);
        JToken.AsObject().Get('contentBytes', JTokenContent);
        AttachmentContentInBase64 := JTokenContent.AsValue().AsText();
        Jtoken.AsObject().Remove('contentBytes');
        exit(AttachmentContentInBase64);
    end;

    [NonDebuggable]
    local procedure GetUploadUrl(AttachmentHttpResponseMessage: HttpResponseMessage): Text
    var
        JToken: JsonToken;
        ResponseJson: JsonObject;
        ResponseJsonText: Text;
    begin
        AttachmentHttpResponseMessage.Content.ReadAs(ResponseJsonText);
        ResponseJson.ReadFrom(ResponseJsonText);
        ResponseJson.Get('uploadUrl', JToken);
        exit(JToken.AsValue().AsText());
    end;

    [NonDebuggable]
    local procedure GetAttachmentSize(AttachmentJson: JsonObject): Integer
    var
        JToken: JsonToken;
    begin
        AttachmentJson.Get('AttachmentItem', JToken);
        JToken.AsObject().Get('size', JToken);
        exit(JToken.AsValue().AsInteger());
    end;

    local procedure MaximumAttachmentSizeInBytes(): Integer
    begin
        exit(3145728); // 3 mb
    end;
}