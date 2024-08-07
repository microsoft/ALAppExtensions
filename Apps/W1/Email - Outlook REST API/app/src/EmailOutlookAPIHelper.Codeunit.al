// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

using System.Environment;
using System.DataAdministration;

codeunit 4509 "Email - Outlook API Helper"
{
    Permissions = tabledata "Email Inbox" = ri,
                    tabledata "Email - Outlook Account" = rimd;

    var
        CannotConnectToMailServerErr: Label 'Client ID or Client secret is not set up on the Email Microsoft Entra application registration page.';
        SetupOutlookAPIQst: Label 'To connect to your email account you must create an App registration in Microsoft Entra and then enter information about the registration on the Email Microsoft Entra application registration page in Business Central. Do you want to do that now?';
        OnPremOnlyErr: Label 'Authentication using the Client ID and secret should only be used for Business Central on-premises.';
        AccountNotFoundErr: Label 'We could not find the account. Typically, this is because the account has been deleted.';
        EmailBodyTooLargeErr: Label 'The email is too large to send. The size limit is 4 MB, not including attachments.', Locked = true;

    procedure GetAccounts(Connector: Enum "Email Connector"; var Accounts: Record "Email Account")
    var
        Account: Record "Email - Outlook Account";
    begin
        Account.SetRange("Outlook API Email Connector", Connector);

        if Account.FindSet() then
            repeat
                Accounts."Account Id" := Account.Id;
                Accounts."Email Address" := Account."Email Address";
                Accounts.Name := Account.Name;
                Accounts.Connector := Connector;

                Accounts.Insert();
            until Account.Next() = 0;
    end;

    procedure DeleteAccount(AccountId: Guid): Boolean
    var
        OutlookAccount: Record "Email - Outlook Account";
    begin
        if OutlookAccount.Get(AccountId) then
            if OutlookAccount.WritePermission() then
                exit(OutlookAccount.Delete());
        exit(false);
    end;

    procedure EmailMessageToJson(EmailMessage: Codeunit "Email Message"; Account: Record "Email - Outlook Account"): JsonObject
    var
        EmailMessageJson: JsonObject;
        EmailAddressJson: JsonObject;
        FromJson: JsonObject;
    begin
        EmailAddressJson.Add('address', Account."Email Address");
        EmailAddressJson.Add('name', Account."Name");

        FromJson.Add('emailAddress', EmailAddressJson);
        EmailMessageJson.Add('from', FromJson);

        exit(EmailMessageToJson(EmailMessage, EmailMessageJson))
    end;

    procedure EmailMessageToReplyJson(EmailMessage: Codeunit "Email Message"; ReplyBody: Text; AsHtml: Boolean): JsonObject
    var
        EmailMessageJson: JsonObject;
        MessageText: Text;
        EmailBody: JsonObject;
        Recipients: JsonArray;
    begin
        EmailBody.add('content', ReplyBody);
        if AsHtml then
            EmailBody.add('contentType', 'html')
        else
            EmailBody.add('contentType', 'text');
        EmailMessageJson.Add('body', EmailBody);

        Recipients := GetEmailRecipients(EmailMessage, Enum::"Email Recipient Type"::"To");
        if Recipients.Count > 0 then
            EmailMessageJson.Add('toRecipients', Recipients);
        Recipients := GetEmailRecipients(EmailMessage, Enum::"Email Recipient Type"::Cc);
        if Recipients.Count > 0 then
            EmailMessageJson.Add('ccRecipients', Recipients);
        Recipients := GetEmailRecipients(EmailMessage, Enum::"Email Recipient Type"::Bcc);
        if Recipients.Count > 0 then
            EmailMessageJson.Add('bccRecipients', Recipients);

        // If message json > max request size, then error as the email body is too large.
        EmailMessageJson.WriteTo(MessageText);
        if StrLen(MessageText) > MaximumRequestSizeInBytes() then
            Error(EmailBodyTooLargeErr);

        AddEmailAttachments(EmailMessage, EmailMessageJson);

        exit(EmailMessageJson);
    end;

    procedure EmailMessageToJson(EmailMessage: Codeunit "Email Message"): JsonObject
    var
        EmailMessageJson: JsonObject;
    begin
        exit(EmailMessageToJson(EmailMessage, EmailMessageJson));
    end;

    procedure AddEmailAttachments(EmailMessage: Codeunit "Email Message"; var MessageJson: JsonObject)
    var
        AttachmentItemJson: JsonObject;
        AttachmentJson: JsonObject;
        AttachmentsArray: JsonArray;
    begin
        if not EmailMessage.Attachments_First() then
            exit;

        repeat
            Clear(AttachmentJson);
            Clear(AttachmentItemJson);
            AttachmentJson.Add('name', EmailMessage.Attachments_GetName());
            AttachmentJson.Add('contentType', EmailMessage.Attachments_GetContentType());
            AttachmentJson.Add('isInline', EmailMessage.Attachments_IsInline());

            if EmailMessage.Attachments_GetLength() <= MaximumAttachmentSizeInBytes() then begin
                AttachmentJson.Add('@odata.type', '#microsoft.graph.fileAttachment');
                AttachmentJson.Add('contentBytes', EmailMessage.Attachments_GetContentBase64());
                AttachmentsArray.Add(AttachmentJson);
            end else begin
                AttachmentJson.Add('attachmentType', 'file');
                AttachmentJson.Add('size', EmailMessage.Attachments_GetLength());
                AttachmentJson.Add('contentBytes', EmailMessage.Attachments_GetContentBase64());
                AttachmentItemJson.Add('AttachmentItem', AttachmentJson);
                AttachmentsArray.Add(AttachmentItemJson);
            end;
        until EmailMessage.Attachments_Next() = 0;

        MessageJson.Add('attachments', AttachmentsArray);
    end;

    local procedure EmailMessageToJson(EmailMessage: Codeunit "Email Message"; EmailMessageJson: JsonObject): JsonObject
    var
        MessageJson: JsonObject;
        MessageText: Text;
        EmailBody: JsonObject;
    begin
        if EmailMessage.IsBodyHTMLFormatted() then
            EmailBody.Add('contentType', 'HTML')
        else
            EmailBody.Add('contentType', 'text');

        EmailBody.Add('content', EmailMessage.GetBody());

        EmailMessageJson.Add('subject', EmailMessage.GetSubject());
        EmailMessageJson.Add('body', EmailBody);
        EmailMessageJson.Add('toRecipients', GetEmailRecipients(EmailMessage, Enum::"Email Recipient Type"::"To"));
        EmailMessageJson.Add('ccRecipients', GetEmailRecipients(EmailMessage, Enum::"Email Recipient Type"::Cc));
        EmailMessageJson.Add('bccRecipients', GetEmailRecipients(EmailMessage, Enum::"Email Recipient Type"::Bcc));

        // If message json > max request size, then error as the email body is too large.
        EmailMessageJson.WriteTo(MessageText);
        if StrLen(MessageText) > MaximumRequestSizeInBytes() then
            Error(EmailBodyTooLargeErr);

        AddEmailAttachments(EmailMessage, EmailMessageJson);

        // If message json <= max request size, wrap it in message object to send in a single request.
        EmailMessageJson.WriteTo(MessageText);
        if StrLen(MessageText) > MaximumRequestSizeInBytes() then
            MessageJson := EmailMessageJson
        else begin
            MessageJson.Add('message', EmailMessageJson);
            MessageJson.Add('saveToSentItems', true);
        end;

        exit(MessageJson);
    end;

    local procedure GetEmailRecipients(EmailMessage: Codeunit "Email Message"; EmailRecipientType: enum "Email Recipient Type"): JsonArray
    var
        Address: JsonObject;
        Recipients: List of [Text];
        RecipientsJson: JsonArray;
        EmailAddress: JsonObject;
        Value: Text;
    begin
#pragma warning disable AA0205
        EmailMessage.GetRecipients(EmailRecipientType, Recipients);
#pragma warning restore AA0205
        foreach value in Recipients do begin
            clear(Address);
            clear(EmailAddress);
            Address.Add('address', value);
            EmailAddress.Add('emailAddress', Address);
            RecipientsJson.Add(EmailAddress);
        end;
        exit(RecipientsJson);
    end;

#if not CLEAN25
    [NonDebuggable]
    [Obsolete('Replaced by an overload that takes in SecretText data type for ClientSecret', '25.0')]
    procedure GetClientIDAndSecret(var ClientId: Text; var ClientSecret: Text)
    var
        Secret: SecretText;
    begin
        GetClientIDAndSecret(ClientId, Secret);
        ClientSecret := Secret.Unwrap();
    end;
#endif

    procedure GetClientIDAndSecret(var ClientId: Text; var ClientSecret: SecretText)
    var
        Setup: Record "Email - Outlook API Setup";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSaaSInfrastructure() then
            Error(OnPremOnlyErr);

        if not IsAzureAppRegistrationSetup() then
            Error(CannotConnectToMailServerErr);

        Setup.Get();
        if not IsolatedStorage.Get(Setup.ClientId, DataScope::Module, ClientId) then
            Error(CannotConnectToMailServerErr);
        if not IsolatedStorage.Get(Setup.ClientSecret, DataScope::Module, ClientSecret) then
            Error(CannotConnectToMailServerErr);
    end;

    procedure SetupAzureAppRegistration()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSaaSInfrastructure() then // The setup is needed only for OnPrem
            exit;

        if IsAzureAppRegistrationSetup() then // The setup already exists
            exit;

        if not Confirm(SetupOutlookAPIQst) then // The user doesn't want to setup the app registration
            exit;

        Page.RunModal(Page::"Email - Outlook API Setup");
    end;

    procedure GetRedirectURL(): Text
    var
        Setup: Record "Email - Outlook API Setup";
    begin
        if Setup.Get() then
            exit(Setup.RedirectURL);
    end;

    procedure IsAzureAppRegistrationSetup(): Boolean
    var
        Setup: Record "Email - Outlook API Setup";
    begin
        exit(Setup.Get() and
            (not IsNullGuid(Setup.ClientId)) and
            (not IsNullGuid(Setup.ClientSecret)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Email - Outlook API Setup", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnDeleteOutlookAPIAccount(var Rec: Record "Email - Outlook API Setup")
    begin
        if Rec.IsTemporary() then
            exit;

        if IsolatedStorage.Contains(Rec.ClientId, DataScope::Module) then
            IsolatedStorage.Delete(Rec.ClientId, DataScope::Module);

        if IsolatedStorage.Contains(Rec.ClientSecret, DataScope::Module) then
            IsolatedStorage.Delete(Rec.ClientSecret, DataScope::Module);
    end;

#if not CLEAN24
    [Obsolete('Replaced by InitializeClients with v2 interfaces.', '24.0')]
    procedure InitializeClients(var OutlookAPIClient: interface "Email - Outlook API Client"; var OAuthClient: interface "Email - OAuth Client")
    var
        DefaultAPIClient: Codeunit "Email - Outlook API Client";
        DefaultOAuthClient: Codeunit "Email - OAuth Client";
    begin
        OutlookAPIClient := DefaultAPIClient;
        OAuthClient := DefaultOAuthClient;
        OnAfterInitializeClients(OutlookAPIClient, OAuthClient);
    end;
#endif
    procedure InitializeClients(var OutlookAPIClient: interface "Email - Outlook API Client v2"; var OAuthClient: interface "Email - OAuth Client v2")
    var
        DefaultAPIClient: Codeunit "Email - Outlook API Client";
        DefaultOAuthClient: Codeunit "Email - OAuth Client";
    begin
        OutlookAPIClient := DefaultAPIClient;
        OAuthClient := DefaultOAuthClient;
        OnAfterInitializeClientsV2(OutlookAPIClient, OAuthClient);
    end;

    procedure InitializeClients(var OutlookAPIClient: interface "Email - Outlook API Client v3"; var OAuthClient: interface "Email - OAuth Client v2")
    var
        DefaultAPIClient: Codeunit "Email - Outlook API Client";
        DefaultOAuthClient: Codeunit "Email - OAuth Client";
    begin
        OutlookAPIClient := DefaultAPIClient;
        OAuthClient := DefaultOAuthClient;
        OnAfterInitializeClientsV3(OutlookAPIClient, OAuthClient);
    end;

    procedure Send(EmailMessage: Codeunit "Email Message"; AccountId: Guid)
    var
        EmailOutlookAccount: Record "Email - Outlook Account";
        APIClient: interface "Email - Outlook API Client v2";
        OAuthClient: interface "Email - OAuth Client v2";
        AccessToken: SecretText;
    begin
        InitializeClients(APIClient, OAuthClient);
        if not EmailOutlookAccount.Get(AccountId) then
            Error(AccountNotFoundErr);

        OAuthClient.GetAccessToken(AccessToken);
        APIClient.SendEmail(AccessToken, EmailMessageToJson(EmailMessage, EmailOutlookAccount));
    end;

    procedure Send(EmailMessage: Codeunit "Email Message")
    var
        APIClient: interface "Email - Outlook API Client v2";
        OAuthClient: interface "Email - OAuth Client v2";
        AccessToken: SecretText;
    begin
        InitializeClients(APIClient, OAuthClient);

        OAuthClient.GetAccessToken(AccessToken);
        APIClient.SendEmail(AccessToken, EmailMessageToJson(EmailMessage));
    end;

    procedure RetrieveEmails(AccountId: Guid; MarkEmailsAsRead: Boolean; var EmailInbox: Record "Email Inbox")
    var
        EmailOutlookAccount: Record "Email - Outlook Account";
        APIClient: interface "Email - Outlook API Client v3";
        OAuthClient: interface "Email - OAuth Client v2";
        AccessToken: SecretText;
        EmailsArray: JsonArray;
        EmailObject: JsonObject;
        JsonToken: JsonToken;
        Counter: Integer;
    begin
        InitializeClients(APIClient, OAuthClient);
        if not EmailOutlookAccount.Get(AccountId) then
            Error(AccountNotFoundErr);

        OAuthClient.GetAccessToken(AccessToken);

        EmailsArray := APIClient.RetrieveEmails(AccessToken, MarkEmailsAsRead, EmailOutlookAccount);

        for Counter := 0 to EmailsArray.Count() - 1 do begin
            EmailsArray.Get(Counter, JsonToken);
            EmailObject := JsonToken.AsObject();
            CreateEmailInboxFromJsonObject(EmailInbox, EmailOutlookAccount, EmailObject);
            if MarkEmailsAsRead then
                MarkEmailAsRead(EmailOutlookAccount.Id, EmailInbox."External Message Id");
        end;
    end;

    local procedure CreateEmailInboxFromJsonObject(var EmailInbox: Record "Email Inbox"; OutlookAccount: Record "Email - Outlook Account"; EmailJsonObject: JsonObject)
    var
        EmailInboxDelete: Record "Email Inbox";
        EmailMessage: Codeunit "Email Message";
        BodyObject: JsonObject;
        SenderObject: JsonObject;
        ReceivedDateTime: DateTime;
        SentDateTime: DateTime;
        ExternalMessageId: Text;
        ConversationId: Text;
        Subject: Text;
        Body: Text;
        SenderName: Text;
        SenderEmail: Text;
        HasAttachments: Boolean;
    begin
        ReceivedDateTime := GetDateTimeFromJsonObject(EmailJsonObject, 'receivedDateTime');
        SentDateTime := GetDateTimeFromJsonObject(EmailJsonObject, 'sentDateTime');
        ExternalMessageId := GetTextFromJsonObject(EmailJsonObject, 'id');
        ConversationId := GetTextFromJsonObject(EmailJsonObject, 'conversationId');
        Subject := GetTextFromJsonObject(EmailJsonObject, 'subject');
        HasAttachments := GetBooleanFromJsonObject(EmailJsonObject, 'hasAttachments');

        BodyObject := GetJsonObjectFromJsonObject(EmailJsonObject, 'body');
        Body := GetTextFromJsonObject(BodyObject, 'content');

        SenderObject := GetJsonObjectFromJsonObject(EmailJsonObject, 'sender');
        SenderObject := GetJsonObjectFromJsonObject(SenderObject, 'emailAddress');
        SenderName := GetTextFromJsonObject(SenderObject, 'name');
        SenderEmail := GetTextFromJsonObject(SenderObject, 'address');

        if DoesExternalMessageIdExist(ExternalMessageId) then begin
            EmailInboxDelete.SetRange("External Message Id", ExternalMessageId);
            EmailInboxDelete.DeleteAll();
        end;

        EmailMessage.Create('', Subject, Body, false);

        if HasAttachments then
            AddAttachmentsToMessage(EmailJsonObject, EmailMessage);

        EmailInbox.Init();
        EmailInbox.Id := 0;
        EmailInbox."External Message Id" := CopyStr(ExternalMessageId, 1, MaxStrLen(EmailInbox."External Message Id"));
        EmailInbox."Conversation Id" := CopyStr(ConversationId, 1, MaxStrLen(EmailInbox."Conversation Id"));
        EmailInbox.Description := CopyStr(Subject, 1, MaxStrLen(EmailInbox.Description));
        EmailInbox."Message Id" := EmailMessage.GetId();
        EmailInbox."Account Id" := OutlookAccount.Id;
        EmailInbox.Connector := OutlookAccount."Outlook API Email Connector";
        EmailInbox."Received DateTime" := ReceivedDateTime;
        EmailInbox."Sent DateTime" := SentDateTime;
        EmailInbox."Sender Name" := CopyStr(SenderName, 1, MaxStrLen(EmailInbox."Sender Name"));
        EmailInbox."Sender Address" := CopyStr(SenderEmail, 1, MaxStrLen(EmailInbox."Sender Address"));
        EmailInbox.Insert();
        EmailInbox.Mark(true);
    end;

    local procedure DoesExternalMessageIdExist(ExternalMessageId: Text): Boolean
    var
        EmailInbox: Record "Email Inbox";
    begin
        EmailInbox.SetRange("External Message Id", ExternalMessageId);
        exit(not EmailInbox.IsEmpty());
    end;

    local procedure AddAttachmentsToMessage(EmailJsonObject: JsonObject; var EmailMessage: Codeunit "Email Message")
    var
        AttachmentsArray: JsonArray;
        AttachmentObject: JsonObject;
        JsonToken: JsonToken;
        Counter: Integer;
        AttachmentName: Text[250];
        ContentType: Text[250];
        ContentBytesBase64: Text;
    begin
        EmailJsonObject.Get('attachments', JsonToken);
        AttachmentsArray := JsonToken.AsArray();

        for Counter := 0 to AttachmentsArray.Count() - 1 do begin
            AttachmentsArray.Get(Counter, JsonToken);
            AttachmentObject := JsonToken.AsObject();

            AttachmentName := CopyStr(GetTextFromJsonObject(AttachmentObject, 'name'), 1, MaxStrLen(AttachmentName));
            ContentType := CopyStr(GetTextFromJsonObject(AttachmentObject, 'contentType'), 1, MaxStrLen(ContentType));
            ContentBytesBase64 := GetTextFromJsonObject(AttachmentObject, 'contentBytes');

            EmailMessage.AddAttachment(AttachmentName, ContentType, ContentBytesBase64);
        end;
    end;

    local procedure GetTextFromJsonObject(JsonObject: JsonObject; KeyName: Text): Text
    var
        JsonToken: JsonToken;
    begin
        JsonObject.Get(KeyName, JsonToken);
        exit(JsonToken.AsValue().AsText());
    end;

    local procedure GetJsonObjectFromJsonObject(JsonObject: JsonObject; KeyName: Text): JsonObject
    var
        JsonToken: JsonToken;
    begin
        JsonObject.Get(KeyName, JsonToken);
        exit(JsonToken.AsObject());
    end;

    local procedure GetBooleanFromJsonObject(JsonObject: JsonObject; KeyName: Text): Boolean
    var
        JsonToken: JsonToken;
    begin
        JsonObject.Get(KeyName, JsonToken);
        exit(JsonToken.AsValue().AsBoolean());
    end;

    local procedure GetDateTimeFromJsonObject(JsonObject: JsonObject; KeyName: Text): DateTime
    var
        JsonToken: JsonToken;
    begin
        JsonObject.Get(KeyName, JsonToken);
        exit(JsonToken.AsValue().AsDateTime());
    end;

    procedure MarkEmailAsRead(AccountId: Guid; ExternalMessageId: Text)
    var
        EmailOutlookAccount: Record "Email - Outlook Account";
        APIClient: interface "Email - Outlook API Client v3";
        OAuthClient: interface "Email - OAuth Client v2";
        AccessToken: SecretText;
    begin
        InitializeClients(APIClient, OAuthClient);
        if not EmailOutlookAccount.Get(AccountId) then
            Error(AccountNotFoundErr);

        OAuthClient.GetAccessToken(AccessToken);
        APIClient.MarkEmailAsRead(AccessToken, EmailOutlookAccount."Email Address", ExternalMessageId);
    end;

    procedure ReplyEmail(AccountId: Guid; var EmailMessage: Codeunit "Email Message")
    var
        EmailOutlookAccount: Record "Email - Outlook Account";
        APIClient: interface "Email - Outlook API Client v3";
        OAuthClient: interface "Email - OAuth Client v2";
        AccessToken: SecretText;
        DraftMessageId: Text;
        DraftMessageBody: Text;
        DraftMessageJson: JsonObject;
        DraftMessageJsonText: Text;
        Position: Integer;
        NewLine: Char;
    begin
        InitializeClients(APIClient, OAuthClient);
        if not EmailOutlookAccount.Get(AccountId) then
            Error(AccountNotFoundErr);

        OAuthClient.GetAccessToken(AccessToken);

        DraftMessageId := APIClient.CreateDraftReply(AccessToken, EmailOutlookAccount."Email Address", EmailMessage.GetExternalId());
        DraftMessageJson := APIClient.RetrieveEmail(AccessToken, EmailOutlookAccount."Email Address", DraftMessageId, EmailMessage.IsBodyHTMLFormatted());
        if EmailMessage.IsBodyHTMLFormatted() then begin
            DraftMessageBody := GetMessageBody(DraftMessageJson);
            Position := DraftMessageBody.IndexOf('<body', 1);
            Position := DraftMessageBody.IndexOf('>', Position);
            DraftMessageBody := CopyStr(DraftMessageBody, 1, Position) + EmailMessage.GetBody() + CopyStr(DraftMessageBody, Position + 1);
            EmailMessageToReplyJson(EmailMessage, DraftMessageBody, EmailMessage.IsBodyHTMLFormatted()).WriteTo(DraftMessageJsonText);
        end else begin
            NewLine := 10;
            DraftMessageBody := EmailMessage.GetBody() + NewLine + GetMessageBody(DraftMessageJson);
            EmailMessageToReplyJson(EmailMessage, DraftMessageBody, EmailMessage.IsBodyHTMLFormatted()).WriteTo(DraftMessageJsonText);
        end;

        APIClient.ReplyEmail(AccessToken, EmailOutlookAccount."Email Address", DraftMessageId, DraftMessageJsonText);
    end;

    local procedure GetMessageBody(MessageJson: JsonObject): Text
    var
        JToken: JsonToken;
        BodyJson: JsonObject;
    begin
        MessageJson.Get('body', JToken);
        BodyJson := JToken.AsObject();
        BodyJson.Get('content', JToken);
        exit(JToken.AsValue().AsText());
    end;

#if not CLEAN24
    [InternalEvent(false)]
    local procedure OnAfterInitializeClients(var OutlookAPIClient: interface "Email - Outlook API Client"; var OAuthClient: interface "Email - OAuth Client")
    begin
    end;
#endif

    [InternalEvent(false)]
    local procedure OnAfterInitializeClientsV2(var OutlookAPIClient: interface "Email - Outlook API Client v2"; var OAuthClient: interface "Email - OAuth Client v2")
    begin
    end;

    [InternalEvent(false)]
    local procedure OnAfterInitializeClientsV3(var OutlookAPIClient: interface "Email - Outlook API Client v3"; var OAuthClient: interface "Email - OAuth Client v2")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure ClearCompanyConfigGeneral(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        OutlookAccounts: Record "Email - Outlook Account";
    begin
        OutlookAccounts.DeleteAll();
    end;

    local procedure MaximumRequestSizeInBytes(): Integer
    begin
        exit(4194304); // 4 mb
    end;

    local procedure MaximumAttachmentSizeInBytes(): Integer
    begin
        exit(3145728); // 3 mb
    end;

    procedure DefaultEmailRateLimit(): Integer
    begin
        exit(30);
    end;
}