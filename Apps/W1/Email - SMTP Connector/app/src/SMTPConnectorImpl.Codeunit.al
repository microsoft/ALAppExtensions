// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4513 "SMTP Connector Impl." implements "Email Connector"
{
    Access = Internal;
    Permissions = tabledata "SMTP Account" = rimd;

    var
        SMTPAccount: Record "SMTP Account";
        SMTPMessage: Codeunit "SMTP Message";
        SMTPClient: Codeunit "SMTP Client";
        SmtpCategoryLbl: Label 'Email SMTP', Locked = true;
        ConnectorDescriptionTxt: Label 'Use SMTP to send emails.';

        SmtpConnectTelemetryErrorMsg: Label 'Unable to connect to SMTP server. Smtp server: %1, server port: %2, authentication: %3, error code: %4', Comment = '%1=the smtp server, %2=the server port, %3=authentication, %4=error code', Locked = true;
        SmtpAuthenticateTelemetryErrorMsg: Label 'Unable to connect to SMTP server. Authentication email from: %1, smtp server: %2, server port: %3, authentication: %4 error code: %5', Comment = '%1=the from address, %2=the smtp server, %3=the server port, %4=authentication, %5=error code', Locked = true;
        SmtpSendTelemetryErrorMsg: Label 'Unable to send email. Authentication: %1. Error code: %2', Comment = '%1=authentication, %2=error code', Locked = true;
        SmtpConnectedTelemetryMsg: Label 'Connected to SMTP server %1 on server port %2, authentication: %3', Comment = '%1=the smtp server, %2=the server port, %3=authentication', Locked = true;
        SmtpAuthenticateTelemetryMsg: Label 'Authenticated to SMTP server.  Authentication email from: %1, smtp server: %2, server port: %3, authentication: %4', Comment = '%1=the from address, %2=the smtp server, %3=the server port, %4=authentication', Locked = true;

        ConnectionFailureErr: Label 'Cannot connect to server %1.', Comment = '%1 = The SMTP server address';
        AuthenticationFailureErr: Label 'Cannot authenticate the credentials on server %1.', Comment = '%1 = The SMTP server address';
        SendingFailureErr: Label 'Cannot send the email.';

        SmtpSendTelemetryMsg: Label 'Email sent.';
        TestEmailBodyTxt: Label '<p style="font-family:Verdana,Arial;font-size:10pt"><b>The user %1 sent this message to test their email settings. You do not need to reply to this message.</b></p><p style="font-family:Verdana,Arial;font-size:9pt"><b>Sent through SMTP Server:</b> %2<BR><b>SMTP Port:</b> %3<BR><b>Authentication:</b> %4<BR><b>Using Secure Connection:</b> %5<br/></p>', Comment = '%1 is an email address, such as user@domain.com; %2 is the name of a mail server, such as mail.live.com; %3 is the TCP port number, such as 25; %4 is the authentication method, such as Basic Authentication; %5 is a boolean value, such as True;', Locked = true;
        NotRegisteredAccountErr: Label 'We could not find the account. Typically, this is because the account has been deleted.';
        SMTPConnectorBase64LogoTxt: Label 'iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAABYlAAAWJQFJUiTwAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAExSURBVHgB7ZiBbYMwEEXPKANkg2IWaztBu0HTDdoN6GT2CNmAfrc5yaAEmtiuY+k/CVkgc/xnyzIgQgghhDSMsdZO0jCdNE7zArvFuZ+m6eC9/5I7o+/7fdd1r8j3gtO9Xr+0Bu5G5FJwZWsRVxPZCq7M1gA6P6PxcR1jzAhJh4KP8g+E4MMwHPBchzxvMg9/DAMa95/NgHPOnIo8oUC4uV/ULzYjGyMegn+g/cSzj3HmswJR0eIi1wTXi38WkIIitwS/WUAyiqQETxaQBJEcwbMJyBUiOYNnF1DWROQ3dJbgSnYBZUVESQquxJmzvswh1IhBsGc2xJ8NCIdFn/eU8Et2UoAggmYMM4L2QRJHfI0iAspJpCj8oKkNBWpDgdpQoDbNC/DXYm2aFyCEEEKa5htkbSOpWa7j1QAAAABJRU5ErkJggg==', Locked = true;
        ObfuscateLbl: Label '%1*%2@%3', Comment = '%1 = First character of username , %2 = Last character of username, %3 = Host', Locked = true;

    /// <summary>
    /// Gets the registered accounts for the SMTP connector.
    /// </summary>
    /// <param name="Accounts">Out parameter holding all the registered accounts for the SMTP connector.</param>
    procedure GetAccounts(var Accounts: Record "Email Account")
    var
        Account: Record "SMTP Account";
    begin
        if Account.FindSet() then
            repeat
                Accounts."Account Id" := Account.Id;
                Accounts."Email Address" := Account."Email Address";
                Accounts.Name := Account.Name;
                Accounts.Connector := Enum::"Email Connector"::SMTP;

                Accounts.Insert();
            until Account.Next() = 0;
    end;

    /// <summary>
    /// Shows accounts information.
    /// </summary>
    /// <param name="AccountId">The ID of the account to show.</param>
    procedure ShowAccountInformation(AccountId: Guid)
    var
        SMTPAccountLocal: Record "SMTP Account";
    begin
        if not SMTPAccountLocal.Get(AccountId) then
            Error(NotRegisteredAccountErr);

        Page.Run(Page::"SMTP Account", SMTPAccountLocal);
    end;

    /// <summary>
    /// Register an e-mail account for the SMTP connector.
    /// </summary>
    /// <param name="Account">Out parameter holding details of the registered account.</param>
    /// <returns>True if the registration was successful; false - otherwise.</returns>
    procedure RegisterAccount(var Account: Record "Email Account"): Boolean
    var
        SMTPAccountWizard: Page "SMTP Account Wizard";
    begin
        SMTPAccountWizard.RunModal();

        exit(SMTPAccountWizard.GetAccount(Account));
    end;

    /// <summary>
    /// Deletes an e-mail account for the SMTP connector.
    /// </summary>
    /// <param name="AccountId">The ID of the e-mail account</param>
    /// <returns>True if an account was deleted.</returns>
    procedure DeleteAccount(AccountId: Guid): Boolean
    var
        SMTPAccountLocal: Record "SMTP Account";
    begin
        if SMTPAccountLocal.Get(AccountId) then
            exit(SMTPAccountLocal.Delete());

        exit(false);
    end;

    /// <summary>
    /// Sends an e-mail via the SMTP connector.
    /// </summary>
    /// <param name="Message">The e-mail message to send.</param>
    /// <param name="AccountId">The ID of the account to be used for sending.</param>
    /// <error>SMTP connector failed to connect to server.</error>
    /// <error>SMTP connector failed to authenticate against server.</error>
    /// <error>SMTP connector failed to send the email.</error>
    [NonDebuggable]
    procedure Send(Message: Codeunit "Email Message"; AccountId: Guid)
    var
        Account: Record "SMTP Account";
        SMTPAuthentication: Codeunit "SMTP Authentication";
        Result: Boolean;
        SMTPErrorCode: Text;
    begin
        if not Account.Get(AccountId) then
            Error(NotRegisteredAccountErr);

        Initialize(Account);

        ClearLastError();
        Result := SMTPClient.Connect(Account.Server, Account."Server Port", Account."Secure Connection");

        if not Result then begin
            SMTPErrorCode := GetSmtpErrorCodeFromResponse(GetLastErrorText());

            Session.LogMessage('00009UB', StrSubstNo(SmtpConnectTelemetryErrorMsg,
                    SMTPAccount.Server,
                    SMTPAccount."Server Port",
                    SMTPAccount."Authentication Type",
                    SMTPErrorCode), Verbosity::Error, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);

            Error(ConnectionFailureErr, SMTPAccount.Server);
        end;

        Session.LogMessage('00009UV', StrSubstNo(SmtpConnectedTelemetryMsg,
                SMTPAccount.Server,
                SMTPAccount."Server Port",
                SMTPAccount."Authentication Type"), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);

        if SMTPAccount."Authentication Type" <> SMTPAccount."Authentication Type"::Anonymous then begin
            ClearLastError();
            SMTPAuthentication.SetBasicAuthInfo(Account."User Name", CopyStr(Account.GetPassword(Account."Password Key"), 1, 250));
            SMTPAuthentication.SetServer(Account.Server);
            Result := SMTPClient.Authenticate(Account."Authentication Type", SMTPAuthentication);

            if not Result then begin
                SMTPClient.Disconnect();
                SMTPErrorCode := GetSmtpErrorCodeFromResponse(GetLastErrorText());

                Session.LogMessage('00009XD', StrSubstNo(SmtpAuthenticateTelemetryErrorMsg,
                        ObsfuscateEmailAddress(SMTPAccount."User Name"),
                        SMTPAccount.Server,
                        SMTPAccount."Server Port",
                        SMTPAccount."Authentication Type",
                        SMTPErrorCode), Verbosity::Error, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);

                Error(AuthenticationFailureErr, SMTPAccount.Server);
            end;

            Session.LogMessage('00009XF', StrSubstNo(SmtpAuthenticateTelemetryMsg,
                    ObsfuscateEmailAddress(SMTPAccount."User Name"),
                    SMTPAccount.Server,
                    SMTPAccount."Server Port",
                    SMTPAccount."Authentication Type"), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);
        end;

        BuildSMTPMessage(Message, SMTPAccount, SMTPMessage);

        ClearLastError();
        Result := SMTPClient.Send(SMTPMessage);

        if not Result then begin
            SMTPClient.Disconnect();

            SMTPErrorCode := GetSmtpErrorCodeFromResponse(GetLastErrorText());
            Session.LogMessage('00009UZ', StrSubstNo(SmtpSendTelemetryErrorMsg, SMTPAccount."Authentication Type", SMTPErrorCode), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);

            Error(SendingFailureErr);
        end;

        Session.LogMessage('00009UX', SmtpSendTelemetryMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);
    end;

    local procedure BuildSMTPMessage(EmailMessage: Codeunit "Email Message"; SMTPAccount: Record "SMTP Account"; var SMTPMessage: Codeunit "SMTP Message")
    var
        Recipients: List of [Text];
        AttachmentInStream: InStream;
    begin
        // From name/email address
        SMTPMessage.AddFrom(SMTPAccount."Sender Name", SMTPAccount."Email Address");

        // To, Cc and Bcc Recipients
        EmailMessage.GetRecipients("Email Recipient Type"::"To", Recipients);
        SMTPMessage.SetToRecipients(Recipients);
        EmailMessage.GetRecipients("Email Recipient Type"::"Cc", Recipients);
        SMTPMessage.SetCcRecipients(Recipients);
        EmailMessage.GetRecipients("Email Recipient Type"::"Bcc", Recipients);
        SMTPMessage.SetBccRecipients(Recipients);

        // Subject
        SMTPMessage.SetSubject(EmailMessage.GetSubject());

        // Body
        SMTPMessage.SetBody(EmailMessage.GetBody(), EmailMessage.IsBodyHTMLFormatted());

        // Attachments
        if EmailMessage.Attachments_First() then
            repeat
                EmailMessage.Attachments_GetContent(AttachmentInStream);
                SMTPMessage.AddAttachment(AttachmentInStream, EmailMessage.Attachments_GetName());
            until EmailMessage.Attachments_Next() = 0;
    end;

    /// <summary>
    /// Gets a description of the SMTP connector.
    /// </summary>
    /// <returns>A short description of the SMTP connector.</returns>
    procedure GetDescription(): Text[250]
    begin
        exit(ConnectorDescriptionTxt);
    end;

    /// <summary>
    /// Gets the SMTP connector logo.
    /// </summary>
    /// <returns>A base64-formatted image to be used as logo.</returns>
    procedure GetLogoAsBase64(): Text
    begin
        exit(SMTPConnectorBase64LogoTxt);
    end;

    /// <summary>
    /// Initializes variables for creating an SMTP email.
    /// </summary>
    procedure Initialize(Account: Record "SMTP Account")
    begin
        SMTPAccount := Account;
    end;

    procedure ApplyOffice365Smtp(var SMTPAccountConfig: Record "SMTP Account")
    begin
        // This might be changed by the Microsoft Office 365 team.
        // Current source: http://technet.microsoft.com/library/dn554323.aspx
        SMTPAccountConfig.Server := CopyStr(GetO365SmtpServer(), 1, MaxStrLen(SMTPAccountConfig.Server));
        SMTPAccountConfig."Server Port" := 587;
        SMTPAccountConfig."Authentication Type" := SMTPAccountConfig."Authentication Type"::Basic;
        SMTPAccountConfig."Secure Connection" := true;
    end;

    procedure GetSmtpErrorCodeFromResponse(ErrorResponse: Text): Text
    var
        TextPosition: Integer;
    begin
        TextPosition := StrPos(ErrorResponse, 'failed with this message:');

        if TextPosition = 0 then
            exit('');

        ErrorResponse := CopyStr(ErrorResponse, TextPosition + StrLen('failed with this message:'));
        ErrorResponse := DelChr(ErrorResponse, '<', ' ');

        TextPosition := StrPos(ErrorResponse, ' ');
        if TextPosition <> 0 then
            ErrorResponse := CopyStr(ErrorResponse, 1, TextPosition - 1);

        exit(ErrorResponse);
    end;

    internal procedure IsAccountValid(SMTPAccount: Record "SMTP Account" temporary): Boolean
    begin
        // Name is a mandatory field
        if SMTPAccount.Name = '' then
            exit(false);

        // Email Address is a mandatory field
        if SMTPAccount."Email Address" = '' then
            exit(false);

        // Server is a mandatory field
        if SMTPAccount.Server = '' then
            exit(false);

        // User Name is a mandatory field if the authentication type is Basic
        if (SMTPAccount."Authentication Type" = SMTPAccount."Authentication Type"::Basic) and (SMTPAccount."User Name" = '') then
            exit(false);

        // User Name is a mandatory field if the authentication type is NTLM
        if (SMTPAccount."Authentication Type" = SMTPAccount."Authentication Type"::NTLM) and (SMTPAccount."User Name" = '') then
            exit(false);

        exit(true);
    end;

    [NonDebuggable]
    internal procedure CreateAccount(var SMTPAccount: Record "SMTP Account"; Password: Text; var EmailAccount: Record "Email Account")
    var
        NewSMTPAccount: Record "SMTP Account";
    begin
        NewSMTPAccount.TransferFields(SMTPAccount);

        NewSMTPAccount.Id := CreateGuid();
        NewSMTPAccount.SetPassword(Password);

        NewSMTPAccount.Insert();

        EmailAccount."Account Id" := NewSMTPAccount.Id;
        EmailAccount."Email Address" := NewSMTPAccount."Email Address";
        EmailAccount.Name := NewSMTPAccount.Name;
        EmailAccount.Connector := Enum::"Email Connector"::SMTP;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Email, 'OnGetBodyForTestEmail', '', false, false)]
    local procedure SetTestEmailBody(Connector: Enum "Email Connector"; AccountId: Guid; var Body: Text)
    var
        SMTPAccountForTestEmail: Record "SMTP Account";
    begin
        if Connector <> Connector::SMTP then
            exit;

        if not SMTPAccountForTestEmail.Get(AccountId) then
            exit;

        Body := StrSubstNo(TestEmailBodyTxt,
                           UserId(),
                           SMTPAccountForTestEmail.Server,
                           Format(SMTPAccountForTestEmail."Server Port"),
                           SMTPAccountForTestEmail."Authentication Type",
                           SMTPAccountForTestEmail."Secure Connection");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure ClearCompanyConfigGeneral(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        SMTPAccounts: Record "SMTP Account";
    begin
        SMTPAccounts.ModifyAll(Server, '');
    end;

    internal procedure GetO365SmtpServer(): Text
    begin
        exit('smtp.office365.com');
    end;

    internal procedure ObsfuscateEmailAddress(Email: Text) ObfuscatedEmail: Text
    var
        Username: Text;
        Domain: Text;
        Position: Integer;
    begin
        Position := StrPos(Email, '@');
        if Position > 0 then begin
            Username := DelStr(Email, Position, StrLen(Email) - Position);
            Domain := DelStr(Email, 1, Position);

            ObfuscatedEmail := StrSubstNo(ObfuscateLbl, Username.Substring(1, 1), Username.Substring(Position - 1, 1), Domain);
        end
        else begin
            if StrLen(Email) > 0 then
                ObfuscatedEmail := Email.Substring(1, 1);

            ObfuscatedEmail += '* (Not a valid email)';
        end;
    end;
}