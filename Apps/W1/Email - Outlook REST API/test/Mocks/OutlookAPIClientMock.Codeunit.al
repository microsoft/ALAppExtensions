// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139754 "Outlook API Client Mock" implements "Email - Outlook API Client v5"
{
    SingleInstance = true;

    var
        Message: JsonObject;
        EmailAddress: Text[250];
        AccountName: Text[250];


    internal procedure GetAccountInformation(AccessToken: SecretText; var Email: Text[250]; var Name: Text[250]): Boolean
    begin
        Email := EmailAddress;
        Name := AccountName;
        exit(true);
    end;

    internal procedure SendEmail(AccessToken: SecretText; MessageJson: JsonObject)
    begin
        Message := MessageJson;
    end;

    procedure GetMessage(): JsonObject
    begin
        exit(Message);
    end;

    procedure SetAccountInformation(Email: Text[250]; Name: Text[250])
    begin
        EmailAddress := Email;
        AccountName := Name;
    end;

    procedure RetrieveEmails(AccessToken: SecretText; OutlookAccount: Record "Email - Outlook Account"; var Filters: Record "Email Retrieval Filters" temporary): JsonArray
    begin
        Error('Not implemented in mock');
    end;

    procedure RetrieveEmail(AccessToken: SecretText; EmailAddress: Text[250]; ExternalMessageId: Text; var Filters: Record "Email Retrieval Filters" temporary): JsonObject
    begin
        Error('Not implemented in mock');
    end;

    procedure CreateDraftReply(AccessToken: SecretText; EmailAddress: Text[250]; ExternalMessageId: Text): Text
    begin
        Error('Not implemented in mock');
    end;

    procedure ReplyEmail(AccessToken: SecretText; EmailAddress: Text[250]; ExternalMessageId: Text; MessageJsonText: Text)
    begin
        Error('Not implemented in mock');
    end;

    procedure MarkEmailAsRead(AccessToken: SecretText; EmailAddress: Text[250]; ExternalMessageId: Text)
    begin
        Error('Not implemented in mock');
    end;

    procedure GetMailboxFolders(AccessToken: SecretText; OutlookAccount: Record "Email - Outlook Account"): JsonArray
    begin
        Error('Not implemented in mock');
    end;

    procedure GetChildMailboxFolders(AccessToken: SecretText; OutlookAccount: Record "Email - Outlook Account"; ParentFolderId: Text): JsonArray
    begin
        Error('Not implemented in mock');
    end;
}