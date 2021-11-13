codeunit 89000 "Guest Outlook - API Helper"
{
    Permissions = tabledata "Email - Outlook Account" = rimd;

    var
        AccountNotFoundErr: Label 'We could not find the account. Typically, this is because the account has been deleted.';
        SetupOutlookAPIQst: Label 'To connect to your email account you must create an App registration in guest Azure Active Directory and then enter information about the registration on the Guest Outlook Application AAD Registration Page in Business Central. Do you want to do that now?';
        CommonOAuthAuthorityUrlLbl: Label 'https://login.microsoftonline.com/common/adminconsent', Locked = true;
        CannotConnectToMailServerErr: Label 'Client ID or Client secret is not set up on the Guest Outlook Application AAD Registration Page.';
        GuestOutlookAADAppDescriptionTxt: Label 'Guest Outlook Integration';

    procedure GetAccounts(Connector: Enum "Email Connector"; var Accounts: Record "Email Account")
    var
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
    begin
        EmailOutlookAPIHelper.GetAccounts(Connector, Accounts);
    end;

    procedure ShowAccountInformation(AccountId: Guid; PageId: Integer; Connector: Enum "Email Connector");
    var
        EmailOutlookAccount: Record "Email - Outlook Account";
        GuestOutlookAccount: Record "Email Guest Outlook Acc.";
    begin
        EmailOutlookAccount.SetRange("Outlook API Email Connector", Connector);

        if not EmailOutlookAccount.FindFirst() then
            exit;

        GetAccountInformation(GuestOutlookAccount, EmailOutlookAccount);
        Page.Run(PageId, GuestOutlookAccount);
    end;

    local procedure GetAccountInformation(var GuestOutlookAccount: Record "Email Guest Outlook Acc."; EmailOutlookAccount: Record "Email - Outlook Account")
    begin
        GuestOutlookAccount.TransferFields(EmailOutlookAccount);
        GuestOutlookAccount.Insert();
    end;

    procedure DeleteAccount(AccountId: Guid): Boolean
    var
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
    begin
        exit(EmailOutlookAPIHelper.DeleteAccount(AccountId));
    end;

    [NonDebuggable]
    procedure GetClientIDAndSecret(var ClientId: Text; var ClientSecret: Text)
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not IsAzureAppRegistrationSetup() then
            Error(CannotConnectToMailServerErr);

        if not GetClientId(ClientId) then
            Error(CannotConnectToMailServerErr);
        if not GetClientSecret(ClientSecret) then
            Error(CannotConnectToMailServerErr);
    end;

    local procedure GetClientId(var ClientId: Text): Boolean
    var
        Setup: Record "Guest Outlook - API Setup";
    begin
        Setup.Get();
        exit(IsolatedStorage.Get(Setup.ClientId, DataScope::Module, ClientId));
    end;

    [NonDebuggable]
    local procedure GetClientSecret(var ClientSecret: Text): Boolean
    var
        Setup: Record "Guest Outlook - API Setup";
    begin
        Setup.Get();
        exit(IsolatedStorage.Get(Setup.ClientSecret, DataScope::Module, ClientSecret));
    end;

    procedure SetupAzureAppRegistration()
    begin
        if IsAzureAppRegistrationSetup() then // The setup already exists
            exit;

        if not Confirm(SetupOutlookAPIQst) then // The user doesn't want to setup the app registration
            exit;

        Page.RunModal(Page::"Guest Outlook - API Setup");
    end;

    procedure IsAzureAppRegistrationSetup(): Boolean
    var
        Setup: Record "Guest Outlook - API Setup";
        AADApplication: Record "AAD Application";
    begin
        if not Setup.Get() then
            exit(false);

        if IsNullGuid(Setup.ClientId) then
            exit(false);

        if not CheckIfAADApplicationExists(AADApplication) then
            exit(false);

        if AADApplication.State <> AADApplication.State::Enabled then
            exit(false);

        if not AADApplication."Permission Granted" then
            exit(false);

        exit(not IsNullGuid(Setup.ClientSecret));
    end;

    procedure InitializeClients(var OutlookAPIClient: interface "Email - Outlook API Client"; var OAuthClient: interface "Email - OAuth Client")
    var
        DefaultAPIClient: Codeunit "Email - Outlook API Client";
        DefaultOAuthClient: Codeunit "Guest Outlook-OAuthClient";
    begin
        OutlookAPIClient := DefaultAPIClient;
        OAuthClient := DefaultOAuthClient;
        OnAfterInitializeClients(OutlookAPIClient, OAuthClient);
    end;

    procedure Send(EmailMessage: Codeunit "Email Message"; AccountId: Guid)
    var
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
        EmailOutlookAccount: Record "Email - Outlook Account";
        APIClient: interface "Email - Outlook API Client";
        OAuthClient: interface "Email - OAuth Client";

        [NonDebuggable]
        AccessToken: Text;
    begin
        InitializeClients(APIClient, OAuthClient);
        if not EmailOutlookAccount.Get(AccountId) then
            Error(AccountNotFoundErr);

        OAuthClient.GetAccessToken(AccessToken);
        APIClient.SendEmail(AccessToken, EmailOutlookAPIHelper.EmailMessageToJson(EmailMessage, EmailOutlookAccount));
    end;

    procedure Send(EmailMessage: Codeunit "Email Message")
    var
        EmailOutlookAPIHelper: Codeunit "Email - Outlook API Helper";
        APIClient: interface "Email - Outlook API Client";
        OAuthClient: interface "Email - OAuth Client";

        [NonDebuggable]
        AccessToken: Text;
    begin
        InitializeClients(APIClient, OAuthClient);

        OAuthClient.GetAccessToken(AccessToken);
        APIClient.SendEmail(AccessToken, EmailOutlookAPIHelper.EmailMessageToJson(EmailMessage));
    end;


    procedure CreateAzureAppRegistrationAndGrantConsent(): Boolean
    begin
        CreateAzureAppRegistration();
        exit(GrantConsent());
    end;

    procedure GetGrantConsentStatus(): Boolean
    var
        AADApplication: Record "AAD Application";
    begin
        if not CheckIfAADApplicationExists(AADApplication) then
            exit(false);

        exit(AADApplication."Permission Granted");
    end;

    procedure AddAccount(var GuestOutlookAccount: Record "Email Guest Outlook Acc."; EmailConnector: Enum "Email Connector"; AccountEmailAddress: Text[250]; AccountName: Text[250]) AccountAdded: Boolean
    var
        EmailOutlookAccount: Record "Email - Outlook Account";
    begin
        EmailOutlookAccount.Id := CreateGuid();
        EmailOutlookAccount."Outlook API Email Connector" := EmailConnector;
        EmailOutlookAccount."Email Address" := AccountEmailAddress;
        EmailOutlookAccount.Name := AccountName;

        AccountAdded := EmailOutlookAccount.Insert();

        GuestOutlookAccount.Id := EmailOutlookAccount.Id;
        GuestOutlookAccount.TransferFields(EmailOutlookAccount);
    end;

    procedure UpdateEmailAccount(GuestOutlookAccount: Record "Email Guest Outlook Acc.")
    var
        EmailOutlookAccount: Record "Email - Outlook Account";
    begin
        if not EmailOutlookAccount.Get(GuestOutlookAccount.Id) then
            exit;

        EmailOutlookAccount.Name := GuestOutlookAccount.Name;
        EmailOutlookAccount."Email Address" := GuestOutlookAccount."Email Address";
        EmailOutlookAccount.Modify();
    end;


    local procedure CreateAzureAppRegistration()
    var
        Setup: Record "Guest Outlook - API Setup";
        AppInfo: ModuleInfo;
        ClientDescription: Text[50];
        ContactInformation: Text[50];
        AADApplication: Record "AAD Application";
    begin
        if not Setup.Get() then
            exit;

        if IsNullGuid(Setup.ClientId) then
            exit;

        NavApp.GetCurrentModuleInfo(AppInfo);
        ClientDescription := CopyStr(GuestOutlookAADAppDescriptionTxt, 1, MaxStrLen(ClientDescription));
        ContactInformation := CopyStr(AppInfo.Publisher, 1, MaxStrLen(ContactInformation));

        CreateAzureApp(AADApplication, GuestOutlookAADAppDescriptionTxt, ContactInformation, true);

        AADApplication."App ID" := AppInfo.PackageId;
        AADApplication."App Name" := AppInfo.Name;
        AADApplication.Modify();
    end;

    local procedure GrantConsent() Success: Boolean;
    var
        Setup: Record "Guest Outlook - API Setup";
        AADApplication: Record "AAD Application";
        OAuth2: Codeunit OAuth2;
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        ErrorMsgTxt: Text;
    begin
        if not Setup.Get() then
            exit;

        if IsNullGuid(Setup.ClientId) then
            exit;

        Commit();
        GetAzureApp(AADApplication);
        OAuth2.RequestClientCredentialsAdminPermissions(GraphMgtGeneralTools.StripBrackets(Format(AADApplication."Client Id")), CommonOAuthAuthorityUrlLbl, '', Success, ErrorMsgTxt);

        AADApplication."Permission Granted" := Success;
        AADApplication.Modify();
    end;

    local procedure CheckIfAADApplicationExists(var AADApplication: Record "AAD Application"): Boolean
    var
        ClientId: Text;
    begin
        if not GetClientId(ClientId) then
            exit(false);

        exit(AADApplication.Get(ClientId))
    end;

    local procedure CreateAzureApp(var AADApplication: Record "AAD Application"; GuestOutlookAADAppDescriptionTxt: Text; ContactInformation: Text[50]; arg: Boolean)
    var
        ClientId: Text;
        AADApplicationInterface: Codeunit "AAD Application Interface";
    begin
        if not GetClientId(ClientId) then
            exit;

        AADApplicationInterface.CreateAADApplication(ClientId, GuestOutlookAADAppDescriptionTxt, ContactInformation, true);
        AADApplication.Get(ClientId);
    end;

    local procedure GetAzureApp(var AADApplication: Record "AAD Application")
    var
        ClientId: Text;
    begin
        if not GetClientId(ClientId) then
            exit;

        AADApplication.Get(ClientId);
    end;

    [InternalEvent(false)]
    local procedure OnAfterInitializeClients(var OutlookAPIClient: interface "Email - Outlook API Client"; var OAuthClient: interface "Email - OAuth Client")
    begin
    end;



}