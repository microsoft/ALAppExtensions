// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4513 "SMTP Connector Impl."
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

        SmtpConnectTelemetryErrorMsg: Label 'Unable to connect to SMTP server. Smtp server: %1, server port: %2, error code: %3', Comment = '%1=the smtp server, %2=the server port, %3=error code', Locked = true;
        SmtpAuthenticateTelemetryErrorMsg: Label 'Unable to connect to SMTP server. Authentication email from: %1, smtp server: %2, server port: %3, error code: %4', Comment = '%1=the from address, %2=the smtp server, %3=the server port, %4=error code', Locked = true;
        SmtpSendTelemetryErrorMsg: Label 'Unable to send email. Error code: %1', Comment = '%1=error code', Locked = true;
        SmtpConnectedTelemetryMsg: Label 'Connected to SMTP server %1 on server port %2', Comment = '%1=the smtp server, %2=the server port', Locked = true;
        SmtpAuthenticateTelemetryMsg: Label 'Authenticated to SMTP server.  Authentication email from: %1, smtp server: %2, server port: %3', Comment = '%1=the from address, %2=the smtp server, %3=the server port', Locked = true;

        ConnectionFailureErr: Label 'Cannot connect to server %1.', Comment = '%1 = The SMTP server address';
        AuthenticationFailureErr: Label 'Cannot authenticate the credentials on server %1.', Comment = '%1 = The SMTP server address';
        SendingFailureErr: Label 'Cannot send the email.';

        SmtpSendTelemetryMsg: Label 'Email sent.';
        TestEmailBodyTxt: Label '<p style="font-family:Verdana,Arial;font-size:10pt"><b>The user %1 sent this message to test their email settings. You do not need to reply to this message.</b></p><p style="font-family:Verdana,Arial;font-size:9pt"><b>Sent through SMTP Server:</b> %2<BR><b>SMTP Port:</b> %3<BR><b>Authentication:</b> %4<BR><b>Using Secure Connection:</b> %5<br/></p>', Comment = '%1 is an email address, such as user@domain.com; %2 is the name of a mail server, such as mail.live.com; %3 is the TCP port number, such as 25; %4 is the authentication method, such as Basic Authentication; %5 is a boolean value, such as True;', Locked = true;
        NotRegisteredAccountErr: Label 'We could not find the account. Typically, this is because the account has been deleted.';
        SMTPConnectorBase64LogoTxt: Label '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', Locked = true;
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

    procedure ShowAccountInformation(AccountId: Guid)
    var
        SMTPAccount: Record "SMTP Account";
    begin
        if not SMTPAccount.Get(AccountId) then
            Error(NotRegisteredAccountErr);

        Page.Run(Page::"SMTP Account", SMTPAccount);
    end;

    procedure RegisterAccount(var Account: Record "Email Account"): Boolean
    var
        SMTPAccountWizard: Page "SMTP Account Wizard";
    begin
        SMTPAccountWizard.RunModal();

        exit(SMTPAccountWizard.GetAccount(Account));
    end;

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

            Session.LogMessage('00009UM', StrSubstNo(SmtpConnectTelemetryErrorMsg,
                    SMTPAccount.Server,
                    SMTPAccount."Server Port",
                    SMTPErrorCode), Verbosity::Error, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);

            Error(ConnectionFailureErr, SMTPAccount.Server);
        end;

        Session.LogMessage('00009UN', StrSubstNo(SmtpConnectedTelemetryMsg,
                SMTPAccount.Server,
                SMTPAccount."Server Port"), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);

        if SMTPAccount.Authentication <> SMTPAccount.Authentication::Anonymous then begin // TODO how does NTLM authentication works?
            ClearLastError();
            Result := SMTPClient.Authenticate();

            if not Result then begin
                Disconnect();
                SMTPErrorCode := GetSmtpErrorCodeFromResponse(GetLastErrorText());

                Session.LogMessage('00009XS', StrSubstNo(SmtpAuthenticateTelemetryErrorMsg,
                        SMTPAccount."User Name",
                        SMTPAccount.Server,
                        SMTPAccount."Server Port",
                        SMTPErrorCode), Verbosity::Error, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);

                Error(AuthenticationFailureErr, SMTPAccount.Server);
            end;

            Session.LogMessage('00009XT', StrSubstNo(SmtpAuthenticateTelemetryMsg,
                    SMTPAccount."User Name",
                    SMTPAccount.Server,
                    SMTPAccount."Server Port"), Verbosity::Normal, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);
        end;

        SMTPMessage.BuildMessage(Message, SMTPAccount);

        ClearLastError();
        Result := SMTPClient.SendMessage();

        if not Result then begin
            Disconnect();

            SMTPErrorCode := GetSmtpErrorCodeFromResponse(GetLastErrorText());
            Session.LogMessage('00009UO', StrSubstNo(SmtpSendTelemetryErrorMsg, SMTPErrorCode), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);

            Error(SendingFailureErr);
        end;

        Session.LogMessage('00009UP', SmtpSendTelemetryMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);
    end;

    procedure GetDescription(): Text[250]
    begin
        exit(ConnectorDescriptionTxt);
    end;

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
        SMTPAccountConfig.Server := 'smtp.office365.com';
        SMTPAccountConfig."Server Port" := 587;
        SMTPAccountConfig.Authentication := SMTPAccountConfig.Authentication::Basic;
        SMTPAccountConfig."Secure Connection" := true;
    end;

    /// <summary>
    /// Transfers the addresses from InternetAddressList to into a List of [Text]
    /// </summary>
    procedure InternetAddressListToList(IAList: DotNet InternetAddressList;

    var
        Addresses: List of [Text])
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

        exit(true);
    end;

    internal procedure CreateAccount(var SMTPAccount: Record "SMTP Account"; Password: Text; var EmailAccount: Record "Email Account")
    var
        NewSMTPAccount: Record "SMTP Account";
    begin
        NewSMTPAccount.TransferFields(SMTPAccount);

        NewSMTPAccount.Id := CreateGuid();
        NewSMTPAccount.SetPassword(Password);
        NewSMTPAccount."Created By" := CopyStr(UserId(), 1, MaxStrLen(NewSMTPAccount."Created By"));

        NewSMTPAccount.Insert();

        EmailAccount."Account Id" := NewSMTPAccount.Id;
        EmailAccount."Email Address" := NewSMTPAccount."Email Address";
        EmailAccount.Name := NewSMTPAccount.Name;
        EmailAccount.Connector := Enum::"Email Connector"::SMTP;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Email, 'OnGetTestEmailBody', '', false, false)]
    local procedure SetTestEmailBody(Connector: Enum "Email Connector"; var Body: Text)
    begin
        if Connector = Connector::SMTP then
            Body := StrSubstNo(TestEmailBodyTxt,
                               UserId(),
                               SMTPAccount.Server,
                               Format(SMTPAccount."Server Port"),
                               SMTPAccount.Authentication,
                               SMTPAccount."Secure Connection");
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sandbox Cleanup", 'OnClearCompanyConfiguration', '', false, false)]
    local procedure DisableAccountsForSandbox(CompanyName: Text)
    var
        SMTPAccounts: Record "SMTP Account";
    begin
        SMTPAccounts.ChangeCompany(CompanyName);
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
    [Scope('OnPrem')]
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
}