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
        SMTPClient: Interface "SMTP Client";
        SMTPClientInitialized: Boolean;
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
        FeatureNotificationMsg: Label 'Enhanced email capabilities are available as a replacement for this legacy feature.';
        FeatureNotificationWithOldSmtpMsg: Label 'Enhanced email capabilities are enabled, and your legacy SMTP settings are copied to an account on the Email Accounts page. You can use both, but there is no synchronization between the two.';
        SmtpNotificationMsg: Label 'SMTP settings for the %1 account were copied from your legacy SMTP setup.', Comment = '%1 = The name of the account that was copied.';
        SmtpOnEditingNotificationMsg: Label 'If you have a legacy SMTP email setup that uses this account, you might also need to change those settings. Otherwise, that account or extensions that use it might stop working.';
        GetStartedTxt: Label 'Get started';
        LearnMoreTxt: Label 'Learn more';
        GoThereNowTxt: Label 'Go there now';
        LearnMoreUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2135107', Locked = true;
        SmtpNotificationNameTxt: Label 'Notify that legacy SMTP email setup was copied';
        SmtpNotificationDescTxt: Label 'The first time that the Email Accounts page is opened, show a notification saying that legacy SMTP settings has been copied to the new email setup.';
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
        SMTPAccount: Record "SMTP Account";
    begin
        if not SMTPAccount.Get(AccountId) then
            Error(NotRegisteredAccountErr);

        Page.Run(Page::"SMTP Account", SMTPAccount);
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
        SMTPAccount: Record "SMTP Account";
    begin
        if SMTPAccount.Get(AccountId) then
            exit(SMTPAccount.Delete());

        exit(false);
    end;

    internal procedure SetClient(Client: Interface "SMTP Client")
    begin
        SMTPClient := Client;
        SMTPClientInitialized := true;
    end;

    /// <summary>
    /// Sends an e-mail via the SMTP connector.
    /// </summary>
    /// <param name="Message">The e-mail message to send.</param>
    /// <param name="AccountId">The ID of the account to be used for sending.</param>
    /// <error>SMTP connector failed to connect to server.</error>
    /// <error>SMTP connector failed to authenticate against server.</error>
    /// <error>SMTP connector failed to send the email.</error>
    procedure Send(Message: Codeunit "Email Message"; AccountId: Guid)
    var
        Account: Record "SMTP Account";
        Result: Boolean;
        SMTPErrorCode: Text;
    begin
        if not Account.Get(AccountId) then
            Error(NotRegisteredAccountErr);

        Initialize(Account);

        ClearLastError();
        Result := SMTPClient.Connect();

        if not Result then begin
            SMTPErrorCode := GetSmtpErrorCodeFromResponse(GetLastErrorText());

            Session.LogMessage('00009UB', StrSubstNo(SmtpConnectTelemetryErrorMsg,
                    SMTPAccount.Server,
                    SMTPAccount."Server Port",
                    SMTPAccount.Authentication,
                    SMTPErrorCode), Verbosity::Error, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);

            Error(ConnectionFailureErr, SMTPAccount.Server);
        end;

        Session.LogMessage('00009UV', StrSubstNo(SmtpConnectedTelemetryMsg,
                SMTPAccount.Server,
                SMTPAccount."Server Port",
                SMTPAccount.Authentication), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);

        if SMTPAccount.Authentication <> SMTPAccount.Authentication::Anonymous then begin
            ClearLastError();
            Result := SMTPClient.Authenticate();

            if not Result then begin
                Disconnect();
                SMTPErrorCode := GetSmtpErrorCodeFromResponse(GetLastErrorText());

                Session.LogMessage('00009XD', StrSubstNo(SmtpAuthenticateTelemetryErrorMsg,
                        ObsfuscateEmailAddress(SMTPAccount."User Name"),
                        SMTPAccount.Server,
                        SMTPAccount."Server Port",
                        SMTPAccount.Authentication,
                        SMTPErrorCode), Verbosity::Error, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);

                Error(AuthenticationFailureErr, SMTPAccount.Server);
            end;

            Session.LogMessage('00009XF', StrSubstNo(SmtpAuthenticateTelemetryMsg,
                    ObsfuscateEmailAddress(SMTPAccount."User Name"),
                    SMTPAccount.Server,
                    SMTPAccount."Server Port",
                    SMTPAccount.Authentication), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);
        end;

        SMTPMessage.BuildMessage(Message, SMTPAccount);

        ClearLastError();
        Result := SMTPClient.SendMessage();

        if not Result then begin
            Disconnect();

            SMTPErrorCode := GetSmtpErrorCodeFromResponse(GetLastErrorText());
            Session.LogMessage('00009UZ', StrSubstNo(SmtpSendTelemetryErrorMsg, SMTPAccount.Authentication, SMTPErrorCode), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);

            Error(SendingFailureErr);
        end;

        Session.LogMessage('00009UX', SmtpSendTelemetryMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);
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
    var
        Client: Codeunit "SMTP Client";
    begin
        SMTPAccount := Account;
        SMTPMessage.Initialize();

        if not SMTPClientInitialized then
            SMTPClient := Client;
        SMTPClient.Initialize(Account, SMTPMessage);
    end;

    procedure Disconnect()
    begin
        SMTPClient.Disconnect();
    end;

    procedure ApplyOffice365Smtp(var SMTPAccountConfig: Record "SMTP Account")
    begin
        // This might be changed by the Microsoft Office 365 team.
        // Current source: http://technet.microsoft.com/library/dn554323.aspx
        SMTPAccountConfig.Server := CopyStr(GetO365SmtpServer(), 1, MaxStrLen(SMTPAccountConfig.Server));
        SMTPAccountConfig."Server Port" := 587;
        SMTPAccountConfig.Authentication := SMTPAccountConfig.Authentication::Basic;
        SMTPAccountConfig."Secure Connection" := true;
    end;

    /// <summary>
    /// Transfers the addresses from InternetAddressList to into a List of [Text]
    /// </summary>
    procedure InternetAddressListToList(IAList: DotNet InternetAddressList; var Addresses: List of [Text])
    var
        Mailbox: DotNet MimeMailboxAddress;
    begin
        foreach Mailbox in IAList do
            Addresses.Add(Mailbox.Address);
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
        if (SMTPAccount.Authentication = SMTPAccount.Authentication::Basic) and (SMTPAccount."User Name" = '') then
            exit(false);

        // User Name is a mandatory field if the authentication type is NTLM
        if (SMTPAccount.Authentication = SMTPAccount.Authentication::NTLM) and (SMTPAccount."User Name" = '') then
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
#if not CLEAN17
        NewSMTPAccount."Created By" := CopyStr(UserId(), 1, MaxStrLen(NewSMTPAccount."Created By"));
#endif

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
                           SMTPAccountForTestEmail.Authentication,
                           SMTPAccountForTestEmail."Secure Connection");
    end;

    [EventSubscriber(ObjectType::Page, Page::"SMTP Account", 'OnOpenPageEvent', '', false, false)]
    local procedure ShowWarningOnOpenEmailAccounts()
    begin
        ShowNotificationOnEditingNewSMTPAccount();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Email Accounts", 'OnOpenPageEvent', '', false, false)]
    local procedure ShowNotificationOnOpenEmailAccounts()
    begin
        ShowNotificationForOldSmtp();
    end;

    [EventSubscriber(ObjectType::Page, Page::"SMTP Mail Setup", 'OnOpenPageEvent', '', false, false)]
    local procedure ShowNotificationOnOpenSmtpMailSetup()
    begin
        ShowNotificationForNewEmailFeature();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure ClearCompanyConfigGeneral(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        SMTPAccounts: Record "SMTP Account";
    begin
        SMTPAccounts.ModifyAll(Server, '');
    end;

    local procedure ShowNotificationOnEditingNewSMTPAccount()
    var
        OldSMTPMail: Codeunit "SMTP Mail";
        EmailFeature: Codeunit "Email Feature";
        SmtpNotification: Notification;
    begin
        if not EmailFeature.IsEnabled() or not OldSMTPMail.IsEnabled() then
            exit; // The email feature or the old smtp is not enabled, no need to show anything.

        SmtpNotification.Id := GetSmtpEditingNotificationId();
        SmtpNotification.Message := SmtpOnEditingNotificationMsg;
        SmtpNotification.Scope := NotificationScope::LocalScope;
        SmtpNotification.AddAction(GoThereNowTxt, Codeunit::"SMTP Connector Impl.", 'OpenSmtpMailSetup');
        SmtpNotification.Send();
    end;

    local procedure ShowNotificationForOldSMTP()
    var
        OldSMTPMailSetup: Record "SMTP Mail Setup";
        NewSMTPAccount: Record "SMTP Account";
        SmtpNotification: Notification;
    begin
        if not IsSmtpNotificationEnabled() then
            exit;

        DisableSmtpNotification(); // show only notification once

        if not OldSMTPMailSetup.FindFirst() then
            exit;

        // Filter on account settings that was copied
        NewSMTPAccount.SetRange(Name, OldSMTPMailSetup."User ID");
        NewSMTPAccount.SetRange("Email Address", OldSMTPMailSetup."User ID");
        NewSMTPAccount.SetRange(Server, OldSMTPMailSetup."SMTP Server");
        NewSMTPAccount.SetRange("Server Port", OldSMTPMailSetup."SMTP Server Port");
        NewSMTPAccount.SetRange("User Name", OldSMTPMailSetup."User ID");

        // Check if account is still there and no new accounts with same details were added
        if not (NewSMTPAccount.Count() = 1) then
            exit;

        if not NewSMTPAccount.FindFirst() then
            exit;

        SmtpNotification.Id := GetSmtpNotificationId();
        SmtpNotification.Message := StrSubstNo(SmtpNotificationMsg, NewSMTPAccount.Name);
        SmtpNotification.Scope := NotificationScope::LocalScope;
        SmtpNotification.Send();
    end;

    internal procedure ShowNotificationForNewEmailFeature()
    var
        SMTPMail: Codeunit "SMTP Mail";
        EmailFeature: Codeunit "Email Feature";
        FeatureNotification: Notification;
    begin
        if not EmailFeature.IsEnabled() then
            exit; // The email feature is not enabled, no need to show anything.

        FeatureNotification.Id := GetFeatureNotificationId();
        FeatureNotification.AddAction(LearnMoreTxt, Codeunit::"SMTP Connector Impl.", 'OpenLearnMore');
        FeatureNotification.AddAction(GetStartedTxt, Codeunit::"SMTP Connector Impl.", 'OpenEmailAccounts');

        if SMTPMail.IsEnabled() then
            FeatureNotification.Message := FeatureNotificationWithOldSmtpMsg
        else
            FeatureNotification.Message := FeatureNotificationMsg;

        FeatureNotification.Scope := NotificationScope::LocalScope;
        FeatureNotification.Send();
    end;

    local procedure IsSmtpNotificationEnabled(): Boolean
    var
        MyNotifications: Record "My Notifications";
        SMTPMail: Codeunit "SMTP Mail";
        EmailFeature: Codeunit "Email Feature";
        UserPermissions: Codeunit "User Permissions";
        NotificationIsEnabled: Boolean;
    begin
        if not UserPermissions.IsSuper(UserSecurityId()) then
            exit(false);

        // Only show notification if no user has seen it
        MyNotifications.SetRange("Notification Id", GetSmtpNotificationId());
        MyNotifications.SetRange(Enabled, false);
        NotificationIsEnabled := MyNotifications.IsEmpty();

        exit(NotificationIsEnabled and EmailFeature.IsEnabled() and SMTPMail.IsEnabled());
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefault(GetSmtpNotificationId(), SmtpNotificationNameTxt, SmtpNotificationDescTxt, true);
    end;

    local procedure DisableSmtpNotification()
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.Disable(GetSmtpNotificationId()) then
            MyNotifications.InsertDefault(GetSmtpNotificationId(), SmtpNotificationNameTxt, SmtpNotificationDescTxt, false);
    end;

    local procedure GetSmtpEditingNotificationId(): Guid
    begin
        exit('1e59d329-6a94-4f10-b47e-e1ee579fecbc');
    end;

    local procedure GetFeatureNotificationId(): Guid
    begin
        exit('32827ee4-0781-4a36-90c6-08d35e088491');
    end;

    local procedure GetSmtpNotificationId(): Guid
    begin
        exit('51522fbd-1664-4839-b236-baa60c72d8b5');
    end;

    internal procedure OpenLearnMore(Notification: Notification)
    begin
        Hyperlink(LearnMoreUrlTxt);
    end;

    internal procedure OpenEmailAccounts(Notification: Notification)
    begin
        Page.Run(Page::"Email Accounts");
    end;

    internal procedure OpenSmtpMailSetup(Notification: Notification)
    begin
        Page.Run(Page::"SMTP Mail Setup");
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