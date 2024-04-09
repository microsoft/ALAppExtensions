// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#if not CLEAN24
#pragma warning disable AL0432
codeunit 139754 "Outlook API Client Mock" implements "Email - Outlook API Client", "Email - Outlook API Client v2"
#pragma warning restore AL0432
#else
codeunit 139754 "Outlook API Client Mock" implements "Email - Outlook API Client v2"
#endif
{
    SingleInstance = true;
#if not CLEAN24
    ObsoleteReason = 'Email - OAuth API Client interface is obsolete and being removed.';
    ObsoleteState = Pending;
    ObsoleteTag = '24.0';
#endif

    var
        Message: JsonObject;
        EmailAddress: Text[250];
        AccountName: Text[250];

#if not CLEAN24
    [Obsolete('Replaced by GetAccountInformation with SecretText data type for AccessToken parameter.', '24.0')]
    internal procedure GetAccountInformation(AccessToken: Text; var Email: Text[250]; var Name: Text[250]): Boolean
    begin
        Email := EmailAddress;
        Name := AccountName;
        exit(true);
    end;

    [Obsolete('Replaced by SendEmail with SecretText data type for AccessToken parameter.', '24.0')]
    internal procedure SendEmail(AccessToken: Text; MessageJson: JsonObject)
    begin
        Message := MessageJson;
    end;
#endif

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
}