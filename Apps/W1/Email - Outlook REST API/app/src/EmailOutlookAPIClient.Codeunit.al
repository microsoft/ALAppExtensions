// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

using System.Azure.Identity;
using System.Text;
using System.Utilities;

#if not CLEAN26
codeunit 4508 "Email - Outlook API Client" implements "Email - Outlook API Client v2", "Email - Outlook API Client v3", "Email - Outlook API Client v4"
#else
codeunit 4508 "Email - Outlook API Client" implements "Email - Outlook API Client v2", "Email - Outlook API Client v4"
#endif
{
    var
        OutlookCategoryLbl: Label 'Outlook', Locked = true;
        GraphURLTxt: label 'https://graph.microsoft.com', Locked = true;
        SendEmailErr: Label 'Could not send the email message. Try again later.';
        SendEmailCodeErr: Label 'Failed to send email with status code %1.', Comment = '%1 - Http status code', Locked = true;
        SendEmailMessageErr: Label 'Failed to send email. Error:\\%1', Comment = '%1 = Error message';
        SendEmailExternalUserErr: Label 'Could not send the email, because the user is delegated or external.';
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
        ErrorWithStatusCodeErr: Label '%1%2Status code: %3', Comment = '%1 - Error message, %2 - New line, %3 - Status code', Locked = true;
        TokenExpiredErr: Label 'token is expired', Locked = true;
        AccessTokenExpiredErr: Label 'The access token used has expired.', Locked = true;
        TheMailboxIsNotValidErr: Label 'The mailbox is not valid.\\A likely cause is that the user does not have a valid license for Office 365. To read about other potential causes, visit https://go.microsoft.com/fwlink/?linkid=2206177';
        ExternalSecurityChallengeNotSatisfiedMsg: Label 'Multi-Factor Authentication is enabled on this account but the user did not complete the setup. Please sign in to the account and try again.';
        EnvironmentBlocksErr: Label 'The request to send email has been blocked. To resolve the problem, enable outgoing HTTP requests for the Email - Outlook REST API app on the Extension Management page.';
        ConnectionErr: Label 'Could not establish the connection to the remote service for sending email. Try again later.';
        RetrieveEmailSelectedFieldsTxt: Label 'id,conversationId,sentDateTime,receivedDateTime,subject,webLink,sender,toRecipients,ccRecipients,body,hasAttachments,isRead,isDraft', Locked = true;
        RetrieveEmailsUriTxt: Label '/v1.0/users/%1/messages', Locked = true;
        RetrieveEmailsMessageErr: Label 'Failed to retrieve emails. Error:\\%1', Comment = '%1 = Error message';
        MarkAsReadUriTxt: Label '/v1.0/users/%1/messages/%2', Locked = true;
        RetrieveEmailUriTxt: Label '/v1.0/users/%1/messages/%2', Locked = true;
        UpdateDraftUriTxt: Label '/v1.0/users/%1/messages/%2', Locked = true;
        CreateDraftReplyAllUriTxt: Label '/v1.0/users/%1/messages/%2/createReplyAll', Locked = true;
        SendDraftUriTxt: Label '/v1.0/users/%1/messages/%2/send', Locked = true;
        UploadAttachmentUriTxt: Label '/v1.0/users/%1/messages/%2/attachments/createUploadSession', Locked = true;
        UploadAttachmentMeUriTxt: Label '/v1.0/me/messages/%1/attachments/createUploadSession', Locked = true;
        PostAttachmentUriTxt: Label '/v1.0/users/%1/messages/%2/attachments', Locked = true;
        PostAttachmentMeUriTxt: Label '/v1.0/me/messages/%1/attachments', Locked = true;
        EmailsRetrievedTxt: Label 'Emails retrieved.';
        FailedToReadResponseContentErr: Label 'Failed to read the response content.';
        FailedToRetrieveEmailBodyErr: Label 'Failed to retrieve message body.';
        FailedToUpdateDraftMessageErr: Label 'Failed to update draft message.';
        FailedToRetrieveEmailsErr: Label 'Failed to retrieve emails.';
        TelemetryRetrievedNoEmailsTxt: Label 'No emails retrieved.', Locked = true;
        TelemetryRetrievingEmailsTxt: Label 'Retrieving emails.', Locked = true;
        TelemetryRetrievingAnEmailTxt: Label 'Retrieving an email.', Locked = true;
        TelemetryReplyingToEmailTxt: Label 'Replying to email.', Locked = true;
        TelemetryMarkingEmailAsReadTxt: Label 'Marking email as read.', Locked = true;
        TelemetryFailedStatusCodeTxt: Label 'Failed with status code %1.', Comment = '%1 - Http status code', Locked = true;


    [NonDebuggable]
    procedure GetAccountInformation(AccessToken: SecretText; var Email: Text[250]; var Name: Text[250]): Boolean
    begin
        exit(TryGetAccountInformation(AccessToken, Email, Name));
    end;


    [NonDebuggable]
    [TryFunction]
    procedure TryGetAccountInformation(AccessToken: SecretText; var Email: Text[250]; var Name: Text[250])
    var
        AccountHttpClient: HttpClient;
        AccountRequestHeaders: HttpHeaders;
        AccountResponseMessage: HttpResponseMessage;
        ResponseContent: Text;
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        AccountRequestHeaders := AccountHttpClient.DefaultRequestHeaders();
        AccountRequestHeaders.Add('Authorization', SecretStrSubstNo('Bearer %1', AccessToken));

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
    /// Send email using Outlook API. If the message json parameter &lt;= 4 mb and wrapped in a message object it is sent in a single request, otherwise it is sent it in multiple requests.
    /// </summary>
    /// <error>User is external and cannot authenticate to the exchange server.</error>
    /// <param name="AccessToken">Access token of the account.</param>
    /// <param name="MessageJson">The JSON representing the email message.</param>
    [NonDebuggable]
    procedure SendEmail(AccessToken: SecretText; MessageJson: JsonObject)
    var
        AzureADUserManagement: Codeunit "Azure AD User Management";
        AzureADPlan: Codeunit "Azure AD Plan";
        PlanIds: Codeunit "Plan IDs";
        JToken: JsonToken;
        Attachments: JsonArray;
        Attachment: JsonToken;
        MessageId: Text;
    begin
        if AzureADUserManagement.IsUserDelegated(UserSecurityId()) or AzureADPlan.IsPlanAssignedToUser(PlanIds.GetExternalAccountantPlanId()) then
            Error(SendEmailExternalUserErr);

        if MessageJson.Contains('message') then
            SendMailSingleRequest(AccessToken, MessageJson)
        else begin
            MessageJson.Get('attachments', JToken);
            Attachments := JToken.AsArray();
            MessageJson.Remove('attachments');
            MessageId := CreateDraftMail(AccessToken, MessageJson);

            foreach Attachment in Attachments do
                if Attachment.AsObject().Contains('AttachmentItem') then
                    UploadAttachment(AccessToken, '', Attachment.AsObject(), MessageId)
                else
                    PostAttachment(AccessToken, '', Attachment.AsObject(), MessageId);

            SendDraftMail(AccessToken, MessageId);
        end;
    end;

#if not CLEAN26
    [Obsolete('Replaced by RetrieveEmails with an additional parameter for filters.', '26.0')]
    procedure RetrieveEmails(AccessToken: SecretText; MarkAsRead: Boolean; OutlookAccount: Record "Email - Outlook Account"): JsonArray
    var
        TempFilters: Record "Email Retrieval Filters" temporary;
    begin
        exit(RetrieveEmails(AccessToken, OutlookAccount, TempFilters));
    end;
#endif

    procedure RetrieveEmails(AccessToken: SecretText; OutlookAccount: Record "Email - Outlook Account"; var Filters: Record "Email Retrieval Filters" temporary): JsonArray
    var
        EmailsObject: JsonObject;
        EmailsArray: JsonArray;
        JsonToken: JsonToken;
        EmailsCount: Integer;
    begin
        Session.LogMessage('0000NCA', TelemetryRetrievingEmailsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);

        SendRetrieveEmailsRequest(AccessToken, OutlookAccount."Email Address", Filters, EmailsObject);

        if not EmailsObject.Get('@odata.count', JsonToken) then begin
            Session.LogMessage('0000NCB', FailedToRetrieveEmailsErr, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            exit;
        end;
        EmailsCount := JsonToken.AsValue().AsInteger();

        if EmailsCount = 0 then begin
            Session.LogMessage('0000NCC', TelemetryRetrievedNoEmailsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            exit;
        end;

        EmailsObject.Get('value', JsonToken);
        EmailsArray := JsonToken.AsArray();

        exit(EmailsArray);
    end;

    procedure ReplyEmail(AccessToken: SecretText; EmailAddress: Text[250]; ExternalMessageId: Text; MessageJsonText: Text)
    begin
        Session.LogMessage('0000NCD', TelemetryReplyingToEmailTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
        SendReplyEmailRequest(AccessToken, EmailAddress, ExternalMessageId, MessageJsonText);
    end;

    procedure RetrieveEmail(AccessToken: SecretText; EmailAddress: Text[250]; ExternalMessageId: Text; AsHtml: Boolean): JsonObject
    var
        Filters: Record "Email Retrieval Filters";
    begin
        if AsHtml then
            Filters."Body Type" := Filters."Body Type"::HTML
        else
            Filters."Body Type" := Filters."Body Type"::Text;
        exit(RetrieveEmail(AccessToken, EmailAddress, ExternalMessageId, Filters));
    end;

    procedure RetrieveEmail(AccessToken: SecretText; EmailAddress: Text[250]; ExternalMessageId: Text; var Filters: Record "Email Retrieval Filters" temporary): JsonObject
    var
        MailHttpRequestMessage: HttpRequestMessage;
        MailHttpResponseMessage: HttpResponseMessage;
        MailRequestHeaders: HttpHeaders;
        ResponseJson: JsonObject;
        ResponseJsonText: Text;
        RequestUri: Text;
    begin
        Session.LogMessage('0000NCE', TelemetryRetrievingAnEmailTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);

        RequestUri := GraphURLTxt + StrSubstNo(RetrieveEmailUriTxt, EmailAddress, ExternalMessageId);
        CreateRequest('GET', RequestUri, AccessToken, MailHttpRequestMessage);
        MailHttpRequestMessage.GetHeaders(MailRequestHeaders);
        if Filters."Body Type" = Filters."Body Type"::Text then
            MailRequestHeaders.Add('Prefer', 'outlook.body-content-type="text"');
        SendRequest(MailHttpRequestMessage, MailHttpResponseMessage);

        if MailHttpResponseMessage.HttpStatusCode <> 200 then
            Session.LogMessage('0000NBH', FailedToRetrieveEmailBodyErr, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);

        if not MailHttpResponseMessage.Content.ReadAs(ResponseJsonText) then
            Error(FailedToReadResponseContentErr);

        if not ResponseJson.ReadFrom(ResponseJsonText) then
            Error(FailedToReadResponseContentErr);

        exit(ResponseJson);
    end;

    procedure MarkEmailAsRead(AccessToken: SecretText; EmailAddress: Text[250]; ExternalMessageId: Text)
    begin
        Session.LogMessage('0000NCF', TelemetryMarkingEmailAsReadTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
        SendMarkEmailAsReadRequest(AccessToken, EmailAddress, ExternalMessageId)
    end;

    local procedure CreateRequest(Method: Text; RequestUri: Text; AccessToken: SecretText; var MailHttpRequestMessage: HttpRequestMessage)
    var
        MailRequestHeaders: HttpHeaders;
    begin
        MailHttpRequestMessage.Method(Method);
        MailHttpRequestMessage.SetRequestUri(RequestUri);
        MailHttpRequestMessage.GetHeaders(MailRequestHeaders);
        MailRequestHeaders.Add('Authorization', SecretStrSubstNo('Bearer %1', AccessToken));
    end;

    local procedure SendRequest(var MailHttpRequestMessage: HttpRequestMessage; var MailHttpResponseMessage: HttpResponseMessage)
    var
        MailHttpClient: HttpClient;
    begin
        if not MailHttpClient.Send(MailHttpRequestMessage, MailHttpResponseMessage) then
            if MailHttpResponseMessage.IsBlockedByEnvironment() then
                Error(EnvironmentBlocksErr)
            else
                Error(ConnectionErr);
    end;

    local procedure SendRetrieveEmailsRequest(AccessToken: SecretText; EmailAddress: Text; var Filters: Record "Email Retrieval Filters" temporary; var ResponseJsonObject: JsonObject): Boolean
    var
        MailHttpRequestMessage: HttpRequestMessage;
        MailHttpResponseMessage: HttpResponseMessage;
        MailRequestHeaders: HttpHeaders;
        HttpErrorMessage: Text;
        RequestUri: Text;
        JsonContent: Text;
        QueryParameters: Text;
        FilterParameters: Text;
    begin
        RequestUri := GraphURLTxt + StrSubstNo(RetrieveEmailsUriTxt, EmailAddress) + '?';

        if Filters."Load Attachments" then
            QueryParameters := QueryParameters + '$expand=attachments&';

        QueryParameters := QueryParameters + '$top=' + Format(Filters."Max No. of Emails") + '&';
        QueryParameters := QueryParameters + '$select=' + RetrieveEmailSelectedFieldsTxt + '&';
        QueryParameters := QueryParameters + '$count=true&';
        QueryParameters := QueryParameters + '$orderby=receivedDateTime asc&';

        FilterParameters := '$filter=';
        if Filters."Unread Emails" then
            FilterParameters := FilterParameters + 'isRead ne true and ';
        if Filters."Draft Emails" then
            FilterParameters := FilterParameters + 'isDraft eq true and '
        else
            FilterParameters := FilterParameters + 'isDraft ne true and ';
        if Filters."Earliest Email" <> 0DT then
            FilterParameters := FilterParameters + 'receivedDateTime ge ' + Format(Filters."Earliest Email", 0, 9) + ' and ';

        if FilterParameters <> '$filter=' then begin
            QueryParameters := QueryParameters + FilterParameters;
            QueryParameters := CopyStr(QueryParameters, 1, StrLen(QueryParameters) - 5);
        end;

        RequestUri := RequestUri + QueryParameters;

        CreateRequest('GET', RequestUri, AccessToken, MailHttpRequestMessage);

        MailHttpRequestMessage.GetHeaders(MailRequestHeaders);
        if Filters."Body Type" = Filters."Body Type"::HTML then
            MailRequestHeaders.Add('Prefer', 'outlook.body-content-type="html"')
        else
            MailRequestHeaders.Add('Prefer', 'outlook.body-content-type="text"');

        SendRequest(MailHttpRequestMessage, MailHttpResponseMessage);

        if MailHttpResponseMessage.HttpStatusCode <> 200 then begin
            HttpErrorMessage := GetHttpErrorMessageAsText(MailHttpResponseMessage);
            Session.LogMessage('0000NBB', StrSubstNo(TelemetryFailedStatusCodeTxt, Format(MailHttpResponseMessage.HttpStatusCode)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            ProcessRetrieveErrorMessageResponse(HttpErrorMessage, Format(MailHttpResponseMessage.HttpStatusCode));
        end else
            Session.LogMessage('0000NBC', EmailsRetrievedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);

        if not MailHttpResponseMessage.Content.ReadAs(JsonContent) then begin
            Session.LogMessage('0000NBD', FailedToReadResponseContentErr, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            exit(false);
        end;

        if not ResponseJsonObject.ReadFrom(JsonContent) then begin
            Session.LogMessage('0000NBE', FailedToReadResponseContentErr, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            exit(false);
        end;

        exit(true);
    end;

    local procedure SendReplyEmailRequest(AccessToken: SecretText; EmailAddress: Text[250]; ExternalMessageId: Text; MessageJsonText: Text): Boolean
    var
        MessageJson: JsonObject;
        AttachmentsJsonArray: JsonArray;
        JToken: JsonToken;
    begin
        MessageJson.ReadFrom(MessageJsonText);

        if MessageJson.Contains('attachments') then begin
            MessageJson.Get('attachments', JToken);
            AttachmentsJsonArray := JToken.AsArray();
            MessageJson.Remove('attachments');
            AddAttachmentsToDraft(AccessToken, EmailAddress, ExternalMessageId, AttachmentsJsonArray);
        end;

        UpdateDraftMessage(AccessToken, EmailAddress, ExternalMessageId, MessageJsonText);
        SendDraftMail(AccessToken, EmailAddress, ExternalMessageId);
    end;

    local procedure AddAttachmentsToDraft(AccessToken: SecretText; EmailAddress: Text[250]; ExternalMessageId: Text; Attachments: JsonArray)
    var
        Attachment: JsonToken;
    begin
        foreach Attachment in Attachments do
            if Attachment.AsObject().Contains('AttachmentItem') then
                UploadAttachment(AccessToken, EmailAddress, Attachment.AsObject(), ExternalMessageId)
            else
                PostAttachment(AccessToken, EmailAddress, Attachment.AsObject(), ExternalMessageId);
    end;

    procedure CreateDraftReply(AccessToken: SecretText; EmailAddress: Text[250]; MessageId: Text): Text
    var
        MailHttpContent: HttpContent;
        MailHttpRequestMessage: HttpRequestMessage;
        MailHttpResponseMessage: HttpResponseMessage;
        MailContentHeaders: HttpHeaders;
        JToken: JsonToken;
        ResponseJson: JsonObject;
        ResponseJsonText: Text;
        HttpErrorMessage: Text;
        RequestUri: Text;
    begin
        RequestUri := GraphURLTxt + StrSubstNo(CreateDraftReplyAllUriTxt, EmailAddress, MessageId);
        CreateRequest('POST', RequestUri, AccessToken, MailHttpRequestMessage);

        MailHttpContent.GetHeaders(MailContentHeaders);
        MailContentHeaders.Clear();
        MailContentHeaders.Add('Content-Type', 'application/json');
        MailHttpRequestMessage.Content := MailHttpContent;

        SendRequest(MailHttpRequestMessage, MailHttpResponseMessage);

        if MailHttpResponseMessage.HttpStatusCode <> 201 then begin
            HttpErrorMessage := GetHttpErrorMessageAsText(MailHttpResponseMessage);
            Session.LogMessage('0000NBF', HttpErrorMessage, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            Error(HttpErrorMessage);
        end else begin
            MailHttpResponseMessage.Content.ReadAs(ResponseJsonText);
            ResponseJson.ReadFrom(ResponseJsonText);
            ResponseJson.Get('id', JToken);
            MessageId := JToken.AsValue().AsText();
            Session.LogMessage('0000NBG', DraftEmailCreatedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
        end;

        exit(MessageId);
    end;

    local procedure UpdateDraftMessage(AccessToken: SecretText; EmailAddress: Text[250]; MessageId: Text; MessageJsonText: Text): Boolean
    var
        MailHttpContent: HttpContent;
        MailHttpRequestMessage: HttpRequestMessage;
        MailHttpResponseMessage: HttpResponseMessage;
        MailContentHeaders: HttpHeaders;
        RequestUri: Text;
    begin
        RequestUri := GraphURLTxt + StrSubstNo(UpdateDraftUriTxt, EmailAddress, MessageId);
        CreateRequest('PATCH', RequestUri, AccessToken, MailHttpRequestMessage);

        MailHttpContent.WriteFrom(MessageJsonText);
        MailHttpContent.GetHeaders(MailContentHeaders);
        MailContentHeaders.Clear();
        MailContentHeaders.Add('Content-Type', 'application/json');

        MailHttpRequestMessage.Content := MailHttpContent;

        SendRequest(MailHttpRequestMessage, MailHttpResponseMessage);

        if MailHttpResponseMessage.HttpStatusCode <> 200 then begin
            Session.LogMessage('0000NBI', FailedToUpdateDraftMessageErr, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            Error(FailedToUpdateDraftMessageErr);
        end;

        exit(true);
    end;

    [NonDebuggable]
    local procedure SendDraftMail(AccessToken: SecretText; EmailAddress: Text[250]; MessageId: Text): Text
    var
        MailHttpContent: HttpContent;
        MailHttpRequestMessage: HttpRequestMessage;
        MailHttpResponseMessage: HttpResponseMessage;
        MailContentHeaders: HttpHeaders;
        MailHttpClient: HttpClient;
        HttpErrorMessage: Text;
        RequestUri: Text;
    begin
        RequestUri := GraphURLTxt + StrSubstNo(SendDraftUriTxt, EmailAddress, MessageId);
        CreateRequest('POST', RequestUri, AccessToken, MailHttpRequestMessage);

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
    local procedure SendMarkEmailAsReadRequest(AccessToken: SecretText; EmailAddress: Text[250]; ExternalMessageId: Text): Boolean
    var
        MailHttpContent: HttpContent;
        MailHttpRequestMessage: HttpRequestMessage;
        MailHttpResponseMessage: HttpResponseMessage;
        MailContentHeaders: HttpHeaders;
        RequestUri: Text;
        MessageJsonContent: Text;
        JsonContent: JsonObject;
    begin
        JsonContent.Add('isRead', true);
        JsonContent.WriteTo(MessageJsonContent);

        RequestUri := GraphURLTxt + StrSubstNo(MarkAsReadUriTxt, EmailAddress, ExternalMessageId);
        CreateRequest('PATCH', RequestUri, AccessToken, MailHttpRequestMessage);

        MailHttpContent.WriteFrom(MessageJsonContent);
        MailHttpContent.GetHeaders(MailContentHeaders);
        MailContentHeaders.Clear();
        MailContentHeaders.Add('Content-Type', 'application/json');

        MailHttpRequestMessage.Content := MailHttpContent;

        SendRequest(MailHttpRequestMessage, MailHttpResponseMessage);
        exit(true);
    end;

    [NonDebuggable]
    local procedure SendMailSingleRequest(AccessToken: SecretText; MessageJson: JsonObject)
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
        MailRequestHeaders.Add('Authorization', SecretStrSubstNo('Bearer %1', AccessToken));

        MailHttpContent.WriteFrom(MessageJsonText);
        MailHttpContent.GetHeaders(MailContentHeaders);
        MailContentHeaders.Clear();
        MailContentHeaders.Add('Content-Type', 'application/json');

        MailHttpRequestMessage.Content := MailHttpContent;

        if not MailHttpClient.Send(MailHttpRequestMessage, MailHttpResponseMessage) then
            if MailHttpResponseMessage.IsBlockedByEnvironment() then
                Error(EnvironmentBlocksErr)
            else
                Error(ConnectionErr);

        if MailHttpResponseMessage.HttpStatusCode <> 202 then begin
            HttpErrorMessage := GetHttpErrorMessageAsText(MailHttpResponseMessage);
            Session.LogMessage('0000D1Q', StrSubstNo(TelemetryFailedStatusCodeTxt, Format(MailHttpResponseMessage.HttpStatusCode)), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
            ProcessSendErrorMessageResponse(HttpErrorMessage, Format(MailHttpResponseMessage.HttpStatusCode));
        end else
            Session.LogMessage('0000D1R', EmailSentTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
    end;

    local procedure ProcessRetrieveErrorMessageResponse(ErrorMessage: Text; StatusCode: Text)
    begin
        ProcessGenericErrorMessageResponse(ErrorMessage, StatusCode);
        Error(RetrieveEmailsMessageErr, ErrorMessage);
    end;

    local procedure ProcessSendErrorMessageResponse(ErrorMessage: Text; StatusCode: Text)
    begin
        ProcessGenericErrorMessageResponse(ErrorMessage, StatusCode);
        Error(SendEmailMessageErr, ErrorMessage);
    end;

    local procedure ProcessGenericErrorMessageResponse(ErrorMessage: Text; StatusCode: Text)
    var
        NewLine: Char;
    begin
        NewLine := 10;
        if ErrorMessage.Contains(RestAPINotSupportedErr) then
            Error(ErrorWithStatusCodeErr, TheMailboxIsNotValidErr, NewLine, StatusCode);

        // AADSTS50158 - External security challenge not satisfied. MFA was enabled for tenant but user did not enable it yet.
        // https://learn.microsoft.com/azure/active-directory/develop/reference-aadsts-error-codes
        if ErrorMessage.Contains('AADSTS50158') then
            Error(ErrorWithStatusCodeErr, ExternalSecurityChallengeNotSatisfiedMsg, NewLine, StatusCode);

        if ErrorMessage.Contains(TokenExpiredErr) then
            Error(ErrorWithStatusCodeErr, AccessTokenExpiredErr, NewLine, StatusCode);
    end;

    [NonDebuggable]
    local procedure CreateDraftMail(AccessToken: SecretText; MessageJson: JsonObject): Text
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
        MailRequestHeaders.Add('Authorization', SecretStrSubstNo('Bearer %1', AccessToken));

        MailHttpContent.WriteFrom(MessageJsonText);
        MailHttpContent.GetHeaders(MailContentHeaders);
        MailContentHeaders.Clear();
        MailContentHeaders.Add('Content-Type', 'application/json');

        MailHttpRequestMessage.Content := MailHttpContent;

        if not MailHttpClient.Send(MailHttpRequestMessage, MailHttpResponseMessage) then
            if MailHttpResponseMessage.IsBlockedByEnvironment() then
                Error(EnvironmentBlocksErr)
            else
                Error(ConnectionErr);

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
    local procedure SendDraftMail(AccessToken: SecretText; MessageId: Text): Text
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
        MailRequestHeaders.Add('Authorization', SecretStrSubstNo('Bearer %1', AccessToken));

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
    local procedure PostAttachment(AccessToken: SecretText; EmailAddress: Text[250]; AttachmentJson: JsonObject; MessageId: Text)
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
        if EmailAddress = '' then
            RequestUri := GraphURLTxt + StrSubstNo(PostAttachmentMeUriTxt, MessageId)
        else
            RequestUri := GraphURLTxt + StrSubstNo(PostAttachmentUriTxt, EmailAddress, MessageId);

        AttachmentHttpRequestMessage.Method('POST');
        AttachmentHttpRequestMessage.SetRequestUri(RequestUri);
        AttachmentHttpRequestMessage.GetHeaders(AttachmentRequestHeaders);
        AttachmentRequestHeaders.Add('Authorization', SecretStrSubstNo('Bearer %1', AccessToken));

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
    local procedure UploadAttachment(AccessToken: SecretText; EmailAddress: Text[250]; AttachmentJson: JsonObject; MessageId: Text)
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
        if EmailAddress = '' then
            RequestUri := GraphURLTxt + StrSubstNo(UploadAttachmentMeUriTxt, MessageId)
        else
            RequestUri := GraphURLTxt + StrSubstNo(UploadAttachmentUriTxt, EmailAddress, MessageId);

        AttachmentContentInBase64 := GetAttachmentContent(AttachmentJson);
        AttachmentJson.WriteTo(RequestJsonText);

        AttachmentHttpRequestMessage.Method('POST');
        AttachmentHttpRequestMessage.SetRequestUri(RequestUri);
        AttachmentHttpRequestMessage.GetHeaders(AttachmentRequestHeaders);
        AttachmentRequestHeaders.Add('Authorization', SecretStrSubstNo('Bearer %1', AccessToken));

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
        NewLine: Char;
    begin
        if not TryGetErrorMessage(MailHttpResponseMessage, ErrorMessage) then begin
            ErrorMessage := SendEmailErr;
            Session.LogMessage('0000EZA', StrSubstNo(SendEmailCodeErr, MailHttpResponseMessage.HttpStatusCode), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', OutlookCategoryLbl);
        end;

        NewLine := 10;
        ErrorMessage := StrSubstNo(ErrorWithStatusCodeErr, ErrorMessage, NewLine, Format(MailHttpResponseMessage.HttpStatusCode));

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