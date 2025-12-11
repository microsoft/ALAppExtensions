// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139762 "SMTP Account Auth Tests"
{
    Subtype = Test;
    RequiredTestIsolation = Disabled;
    EventSubscriberInstance = Manual;
    TestPermissions = Disabled;

    var
        SMTPAccount: Record "SMTP Account";
        Assert: Codeunit "Library Assert";
        SMTPAccountPage: TestPage "SMTP Account";
        SMTPAccountWizardPage: TestPage "SMTP Account Wizard";
        TokenFromCacheTxt: Label 'aGVhZGVy.eyJ1bmlxdWVfbmFtZSI6InRlc3R1c2VyQGRvbWFpbi5jb20iLCJ1cG4iOiJ0ZXN0dXNlckBkb21haW4uY29tIn0=.c2lnbmF0dXJl', Comment = 'Access token example (with no secret data)', Locked = true;
#pragma warning disable AA0240
        TokenFromCacheUserNameTxt: Label 'testuser@domain.com', Locked = true;
#pragma warning restore AA0240
        AuthenticationSuccessfulMsg: Label '%1 was authenticated.', Comment = '%1 = username';
        AuthenticationFailedMsg: Label 'Could not authenticate.';
        TokenFromCache: Text;
        NotificationIsSent: Boolean;

    [Test]
    [HandlerFunctions('OAuth2AuthenticationMessageHandler1')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SwitchingToOAuth2Authentication()
    var
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        // [GIVEN] SMTP account with basic authentication.
        SMTPAccount.DeleteAll();
        SMTPAccount.Id := CreateGuid();
        SMTPAccount."Authentication Type" := SMTPAccount."Authentication Type"::Basic;
        SMTPAccount.Insert();

        // [GIVEN] OnPrem
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);

        // [WHEN] The SMTP Setup page is opened.
        SMTPAccountPage.OpenEdit();

        // [THEN] The actions related to OAuth 2.0 are invisible.
        Assert.IsFalse(SMTPAccountPage."Authenticate with OAuth 2.0".Visible(), 'OAuth 2.0 actions should not be visible if the authentication is not OAuth 2.0 in SMTP setup');
        Assert.IsFalse(SMTPAccountPage."Check OAuth 2.0 authentication".Visible(), 'OAuth 2.0 actions should not be visible if the authentication is not OAuth 2.0 in SMTP setup');

        // [WHEN] The authentication is changed to OAuth 2.0.
        // [THEN] A message is shown that all users need to authenticate (verified in the handler).
        SMTPAccountPage.Authentication.Value := Format(SMTPAccount."Authentication Type"::"OAuth 2.0");

        // [THEN] The actions related to OAuth 2.0 are still invisible (as server is not an O365 server).
        Assert.IsFalse(SMTPAccountPage."Authenticate with OAuth 2.0".Visible(), 'OAuth 2.0 actions should not be visible if the authentication is not OAuth 2.0 in SMTP setup');
        Assert.IsFalse(SMTPAccountPage."Check OAuth 2.0 authentication".Visible(), 'OAuth 2.0 actions should not be visible if the authentication is not OAuth 2.0 in SMTP setup');

        // [WHEN] The server is changed to O365 SMTP server (and authentication is set to OAuth 2.0).
        SMTPAccountPage.ServerUrl.Value := SMTPConnectorImpl.GetO365SmtpServer();

        // [THEN] The actions related to OAuth 2.0 are visible.
        Assert.IsTrue(SMTPAccountPage."Authenticate with OAuth 2.0".Visible(), 'OAuth 2.0 actions should be visible if the authentication is OAuth 2.0 in SMTP setup');
        Assert.IsTrue(SMTPAccountPage."Check OAuth 2.0 authentication".Visible(), 'OAuth 2.0 actions should be visible if the authentication is OAuth 2.0 in SMTP setup');
        SMTPAccountPage.Close();
    end;

    [Test]
    [HandlerFunctions('BasicAuthNotificationHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SMTPBasicAuthenticationObsoleteNotificationTest()
    var
        SMTPAccount: Record "SMTP Account";
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        EmailOutboxPage: TestPage "Email Outbox";
    begin
        // [SCENARIO]
        // Verifies that when an SMTP account uses Basic authentication, a deprecation notification
        // is displayed on the Email Outbox page. Once the user switches the authentication method
        // to OAuth 2.0, the notification should no longer appear.

        // [GIVEN] An SMTP account configured with Basic authentication.
        SMTPAccount.DeleteAll();
        SMTPAccount.Id := CreateGuid();
        SMTPAccount."Authentication Type" := SMTPAccount."Authentication Type"::Basic;
        SMTPAccount.Server := SMTPConnectorImpl.GetO365SmtpServer();
        SMTPAccount.Insert();

        // Reset the notification tracking flag before test execution.
        NotificationIsSent := false;

        // [GIVEN] Simulate OnPrem environment (not SaaS) so that the local SMTP implementation is used.
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);

        // [WHEN] The Email Outbox page is opened while Basic Auth is still in use.
        EmailOutboxPage.OpenView();

        // [THEN] A notification should be triggered warning about Basic Auth deprecation.
        Assert.IsTrue(NotificationIsSent, 'Notification about basic authentication being obsolete was not shown.');
        EmailOutboxPage.Close();

        // [WHEN] The SMTP account authentication is changed to OAuth 2.0.
        SMTPAccount."Authentication Type" := SMTPAccount."Authentication Type"::"OAuth 2.0";
        SMTPAccount.Modify();

        // Reset the notification tracking flag to verify that no new notification is triggered.
        NotificationIsSent := false;

        // [WHEN] The Email Outbox page is opened again (after switching to OAuth 2.0).
        EmailOutboxPage.OpenView();

        // [THEN] No notification should appear, as Basic Auth is no longer used.
        Assert.IsFalse(NotificationIsSent, 'Notification about basic authentication being obsolete is shown.');
        EmailOutboxPage.Close();
    end;

    [SendNotificationHandler]
    procedure BasicAuthNotificationHandler(var Notification: Notification): Boolean
    begin
        if StrPos(Notification.Message(), 'Basic authentication') > 0 then begin
            NotificationIsSent := true;
            exit(true);
        end;
    end;

    [Test]
    procedure GetUserNameTest()
    var
        OAuth2SMTPAuthentication: Codeunit "OAuth2 SMTP Authentication";
        ReturnedUserName: Text;
        Token: Text;
    begin
        Token := TokenFromCacheTxt;
        OAuth2SMTPAuthentication.GetUserName(Token, ReturnedUserName);
        Assert.AreEqual(TokenFromCacheUserNameTxt, ReturnedUserName, 'Incorrect returned username.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [NonDebuggable]
    procedure GetOAuth2CredentialsTest()
    var
        OAuth2SMTPAuthentication: Codeunit "OAuth2 SMTP Authentication";
        SMTPAccountAuthTests: Codeunit "SMTP Account Auth Tests";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        UserName: Text;
        AuthToken: SecretText;
        Token: Text;
    begin
        // [SCENARIO] If the provided server is the O365 SMTP server, and there is available token cache,
        // the access token is acquires from cache and the user name variable is filled.

        // [GIVEN] Environment is on-prem and token from cache with credentials is available.
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        SetAuthFlowProvider(Codeunit::"SMTP Account Auth Tests");
        Token := TokenFromCacheTxt;
        SMTPAccountAuthTests.SetTokenCache(Token);
        BindSubscription(SMTPAccountAuthTests);

        // [WHEN] AuthenticateWithOAuth2 is called.
        OAuth2SMTPAuthentication.GetOAuth2Credentials(UserName, AuthToken);

        // [THEN] The AuthToken and UserName have the expected values.
        Assert.AreEqual(TokenFromCacheUserNameTxt, UserName, 'UserName should not have been filled.');
        Assert.AreEqual(TokenFromCacheTxt, AuthToken.Unwrap(), 'AuthToken should not have been filled.');
    end;

    [Test]
    [HandlerFunctions('VerifyAuthenticationSuccessMessageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CheckAuthenticationSuccessTest()
    var
        OAuth2SMTPAuthentication: Codeunit "OAuth2 SMTP Authentication";
        SMTPAccountAuthTests: Codeunit "SMTP Account Auth Tests";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        // [SCENARIO] If the provided server is the O365 SMTP server, and there is available token cache,
        // CheckAuthentication shows a message that authentication was successful.

        // [GIVEN] Environment is on-prem and token from cache with credentials is available.
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        SetAuthFlowProvider(Codeunit::"SMTP Account Auth Tests");
        SMTPAccountAuthTests.SetTokenCache(TokenFromCacheTxt);
        BindSubscription(SMTPAccountAuthTests);

        // [WHEN] CheckAuthentication is called.
        OAuth2SMTPAuthentication.CheckOAuth2Authentication();

        // [THEN] The message handler verifies that message is about successful authentication.
    end;

    [Test]
    [HandlerFunctions('VerifyAuthenticationFailMessageHandler,AzureADAccessDialogModalPageHandler')]
    procedure CheckAuthenticationFailTest()
    var
        OAuth2SMTPAuthentication: Codeunit "OAuth2 SMTP Authentication";
        SMTPAccountAuthTests: Codeunit "SMTP Account Auth Tests";
    begin
        // [SCENARIO] If the provided server is the O365 SMTP server, but there is no available token cache,
        // CheckAuthentication shows a message that authentication failed.

        // [GIVEN] There is no available token cache
        SetAuthFlowProvider(Codeunit::"SMTP Account Auth Tests");
        SMTPAccountAuthTests.SetTokenCache('');
        BindSubscription(SMTPAccountAuthTests);

        // [WHEN] CheckAuthentication is called.
        OAuth2SMTPAuthentication.CheckOAuth2Authentication();

        // [THEN] The message handler verifies that message is about failed authentication.
    end;


    #region SMTP Account page tests
    [Test]
    procedure TestOpenSMTPAccountPage()
    begin
        // [SCENARIO] SMTP Account page can be opened successfully

        // [GIVEN] A new SMTP Account record
        CreateSMTPAccount();

        // [WHEN] Opening the SMTP Account page
        SMTPAccountPage.OpenEdit();
        SMTPAccountPage.GoToRecord(SMTPAccount);

        // [THEN] The page opens without errors and is editable
        Assert.IsTrue(SMTPAccountPage.Editable(), 'Page should be editable');

        SMTPAccountPage.Close();
    end;

    [Test]
    procedure TestAccountNameFieldValidation()
    begin
        // [SCENARIO] Account Name field validation works correctly

        // [GIVEN] A new SMTP Account record
        CreateSMTPAccount();

        // [WHEN] Opening the page and setting account name
        SMTPAccountPage.OpenEdit();
        SMTPAccountPage.GoToRecord(SMTPAccount);
        SMTPAccountPage.NameField.SetValue('Test SMTP Account');

        // [THEN] The name is set correctly
        Assert.AreEqual('Test SMTP Account', SMTPAccountPage.NameField.Value(), 'Account name should be set correctly');
        SMTPAccountPage.Close();
    end;

    [Test]
    procedure TestSenderTypeFieldChanges()
    begin
        // [SCENARIO] Sender Type field changes affect field editability

        // [GIVEN] A new SMTP Account record
        CreateSMTPAccount();

        // [WHEN] Opening the page and changing sender type to Specific User
        SMTPAccountPage.OpenEdit();
        SMTPAccountPage.GoToRecord(SMTPAccount);
        SMTPAccountPage.SenderTypeField.SetValue(SMTPAccount."Sender Type"::"Specific User");

        // [THEN] Sender fields become editable
        Assert.IsTrue(SMTPAccountPage.SenderNameField.Editable(), 'Sender Name should be editable for Specific User');
        Assert.IsTrue(SMTPAccountPage.EmailAddress.Editable(), 'Email Address should be editable for Specific User');

        // [WHEN] Changing to Current User
        SMTPAccountPage.SenderTypeField.SetValue(SMTPAccount."Sender Type"::"Current User");

        // [THEN] Sender fields become non-editable
        Assert.IsFalse(SMTPAccountPage.SenderNameField.Editable(), 'Sender Name should not be editable for Current User');
        Assert.IsFalse(SMTPAccountPage.EmailAddress.Editable(), 'Email Address should not be editable for Current User');

        SMTPAccountPage.Close();
    end;

    [Test]
    procedure TestEmailAddressValidation()
    begin
        // [SCENARIO] Email Address validation auto-fills User Name

        // [GIVEN] A new SMTP Account record with Specific User sender type
        CreateSMTPAccount();
        SMTPAccount."Sender Type" := SMTPAccount."Sender Type"::"Specific User";
        SMTPAccount.Modify();

        // [WHEN] Setting email address on the page
        SMTPAccountPage.OpenEdit();
        SMTPAccountPage.GoToRecord(SMTPAccount);
        SMTPAccountPage.EmailAddress.SetValue('test@example.com');

        // [THEN] User Name is automatically set to the email address
        Assert.AreEqual('test@example.com', SMTPAccountPage.UserName.Value(), 'User Name should be auto-filled with email address');

        SMTPAccountPage.Close();
    end;

    [Test]
    procedure TestServerUrlValidation()
    begin
        // [SCENARIO] Server URL field validation works correctly

        // [GIVEN] A new SMTP Account record
        CreateSMTPAccount();

        // [WHEN] Setting server URL
        SMTPAccountPage.OpenEdit();
        SMTPAccountPage.GoToRecord(SMTPAccount);
        SMTPAccountPage.ServerUrl.SetValue('smtp.office365.com');

        // [THEN] Server URL is set correctly
        Assert.AreEqual('smtp.office365.com', SMTPAccountPage.ServerUrl.Value(), 'Server URL should be set correctly');

        SMTPAccountPage.Close();
    end;

    [Test]
    procedure TestServerPortValidation()
    begin
        // [SCENARIO] Server Port field accepts valid port numbers

        // [GIVEN] A new SMTP Account record
        CreateSMTPAccount();

        // [WHEN] Setting server port
        SMTPAccountPage.OpenEdit();
        SMTPAccountPage.GoToRecord(SMTPAccount);
        SMTPAccountPage.ServerPort.SetValue(587);

        // [THEN] Server port is set correctly
        Assert.AreEqual('587', SMTPAccountPage.ServerPort.Value(), 'Server port should be set correctly');

        SMTPAccountPage.Close();
    end;

    [Test]
    procedure TestAuthenticationTypeChanges()
    begin
        // [SCENARIO] Authentication Type changes affect field editability

        // [GIVEN] A new SMTP Account record
        CreateSMTPAccount();

        // [WHEN] Setting authentication to Basic
        SMTPAccountPage.OpenEdit();
        SMTPAccountPage.GoToRecord(SMTPAccount);
        SMTPAccountPage.Authentication.SetValue(SMTPAccount."Authentication Type"::Basic);

        // [THEN] Username and Password fields are editable
        Assert.IsTrue(SMTPAccountPage.UserName.Editable(), 'User Name should be editable for Basic auth');
        Assert.IsTrue(SMTPAccountPage.Password.Editable(), 'Password should be editable for Basic auth');

        // [WHEN] Setting authentication to Anonymous
        SMTPAccountPage.Authentication.SetValue(SMTPAccount."Authentication Type"::Anonymous);

        // [THEN] Username and Password fields are not editable
        Assert.IsFalse(SMTPAccountPage.UserName.Editable(), 'User Name should not be editable for Anonymous auth');
        Assert.IsFalse(SMTPAccountPage.Password.Editable(), 'Password should not be editable for Anonymous auth');

        SMTPAccountPage.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure TestApplyOffice365Action()
    begin
        // [SCENARIO] Apply Office 365 Server Settings action works correctly

        // [GIVEN] A new SMTP Account record
        CreateSMTPAccount();

        // [WHEN] Opening the page and applying Office 365 settings
        SMTPAccountPage.OpenEdit();
        SMTPAccountPage.GoToRecord(SMTPAccount);
        SMTPAccountPage.ApplyOffice365.Invoke();

        // [THEN] Office 365 settings are applied
        Assert.AreEqual('smtp.office365.com', SMTPAccountPage.ServerUrl.Value(), 'Server should be set to Office 365 SMTP');
        Assert.AreEqual('587', SMTPAccountPage.ServerPort.Value(), 'Port should be set to 587');
        Assert.IsTrue(SMTPAccountPage.SecureConnection.AsBoolean(), 'Secure connection should be enabled');

        SMTPAccountPage.Close();
    end;

    [Test]
    procedure TestSecureConnectionField()
    begin
        // [SCENARIO] Secure Connection field can be toggled

        // [GIVEN] A new SMTP Account record
        CreateSMTPAccount();

        // [WHEN] Opening the page and setting secure connection
        SMTPAccountPage.OpenEdit();
        SMTPAccountPage.GoToRecord(SMTPAccount);
        SMTPAccountPage.SecureConnection.SetValue(true);

        // [THEN] Secure connection is enabled
        Assert.IsTrue(SMTPAccountPage.SecureConnection.AsBoolean(), 'Secure connection should be enabled');

        // [WHEN] Disabling secure connection
        SMTPAccountPage.SecureConnection.SetValue(false);

        // [THEN] Secure connection is disabled
        Assert.IsFalse(SMTPAccountPage.SecureConnection.AsBoolean(), 'Secure connection should be disabled');

        SMTPAccountPage.Close();
    end;

    [Test]
    procedure TestEmailAddressDoesNotOverwriteExistingUserName()
    begin
        // [SCENARIO] Email Address OnValidate does not override User Name if it is already set.

        // [GIVEN] A new SMTP Account record with a pre-set User Name
        CreateSMTPAccount();
        SMTPAccount."Sender Type" := SMTPAccount."Sender Type"::"Specific User";
        SMTPAccount."User Name" := 'existing-user@example.com';
        SMTPAccount.Modify();

        // [WHEN] Opening the page and changing Email Address
        SMTPAccountPage.OpenEdit();
        SMTPAccountPage.GoToRecord(SMTPAccount);
        SMTPAccountPage.EmailAddress.SetValue('new-mail@example.com');

        // [THEN] User Name remains unchanged
        Assert.AreEqual('existing-user@example.com', SMTPAccountPage.UserName.Value(), 'User Name should not be overwritten by Email Address if already set');

        SMTPAccountPage.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmCloseCustomOAuthHandler')]
    procedure TestCustomOAuth2ActionsVisibility()
    var
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        // [SCENARIO] When Client Id Storage Id is set (custom OAuth),
        // the custom authenticate action is visible and standard OAuth actions are hidden.

        // [GIVEN] OnPrem + an SMTP account
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        CreateSMTPAccount();

        // [WHEN] Open the SMTP Account page and configure OAuth 2.0 with O365 via the UI
        SMTPAccountPage.OpenEdit();
        SMTPAccountPage.GoToRecord(SMTPAccount);

        // Set Authentication to OAuth 2.0 (fires OnValidate(Authentication) -> SetProperties())
        SMTPAccountPage.Authentication.SetValue(SMTPAccount."Authentication Type"::"OAuth 2.0");

        // Set server to O365 SMTP (fires OnValidate(ServerUrl) -> SetProperties())
        SMTPAccountPage.ServerUrl.SetValue(SMTPConnectorImpl.GetO365SmtpServer());

        // At this point, standard OAuth 2.0 actions are visible (already covered by SwitchingToOAuth2Authentication test)
        SMTPAccountPage.Close();

        // [GIVEN] Custom OAuth is considered "enabled" when Client Id Storage Id is not null
        SMTPAccount.Get(SMTPAccount.Id);
        SMTPAccount."Client Id Storage Id" := CreateGuid();
        SMTPAccount.Modify();

        // [WHEN] Reopen the page (OnOpenPage -> SetProperties() sees Client Id Storage Id <> GUID_EMPTY)
        SMTPAccountPage.OpenEdit();
        SMTPAccountPage.GoToRecord(SMTPAccount);
        SMTPAccountPage.Authentication.SetValue(SMTPAccount."Authentication Type"::"OAuth 2.0");

        // [THEN] Custom OAuth authenticate action is visible
        Assert.IsTrue(SMTPAccountPage."Authenticate with Customized OAuth 2.0".Visible(), 'Custom OAuth 2.0 authenticate action should be visible when Client Id Storage Id is set');

        // [THEN] Standard OAuth 2.0 actions are hidden
        Assert.IsFalse(SMTPAccountPage."Authenticate with OAuth 2.0".Visible(), 'Standard OAuth 2.0 authenticate action should be hidden when custom OAuth is enabled');
        Assert.IsFalse(SMTPAccountPage."Check OAuth 2.0 authentication".Visible(), 'Check OAuth 2.0 authentication action should be hidden when custom OAuth is enabled');
        SMTPAccountPage.Close();
    end;

    [Test]
    procedure TestCustomOAuth2ToggleClearsSecrets()
    begin
        // [SCENARIO] Turning off Custom OAuth 2.0 clears secret-related fields.

        // [GIVEN] An SMTP account with custom OAuth 2.0 GUIDs filled
        CreateSMTPAccount();
        SMTPAccount."Authentication Type" := SMTPAccount."Authentication Type"::"OAuth 2.0";
        SMTPAccount."Client Id Storage Id" := CreateGuid();
        SMTPAccount."Client Secret Storage Id" := CreateGuid();
        SMTPAccount."Tenant Id" := CreateGuid();
        SMTPAccount."Redirect Uri" := 'https://example.com/redirect';
        SMTPAccount.Modify();

        // [WHEN] Opening the page and setting CustomOAuth2Settings to false
        SMTPAccountPage.OpenEdit();
        SMTPAccountPage.GoToRecord(SMTPAccount);
        SMTPAccountPage.CustomOAuth2Settings.SetValue(false);

        SMTPAccountPage.Close();

        // [THEN] All related GUIDs and redirect URI are cleared
        SMTPAccount.Get(SMTPAccount.Id);
        Assert.IsTrue(IsNullGuid(SMTPAccount."Client Id Storage Id"), 'Client Id Storage Id should be cleared when disabling Custom OAuth 2.0');
        Assert.IsTrue(IsNullGuid(SMTPAccount."Client Secret Storage Id"), 'Client Secret Storage Id should be cleared when disabling Custom OAuth 2.0');
        Assert.IsTrue(IsNullGuid(SMTPAccount."Tenant Id"), 'Tenant Id should be cleared when disabling Custom OAuth 2.0');
        Assert.AreEqual('', SMTPAccount."Redirect Uri", 'Redirect URI should be cleared when disabling Custom OAuth 2.0');
    end;

    [Test]
    [HandlerFunctions('ConfirmCloseCustomOAuthHandler')]
    procedure TestCustomOAuth2AuthenticateRequiresClientIdAndSecret()
    begin
        // [SCENARIO] "Authenticate with Customized OAuth 2.0" errors when Client Id or Secret is missing.

        // [GIVEN] OAuth 2.0 account using O365 server and Custom OAuth toggled on, but without ClientId/Secret
        CreateSMTPAccount();
        SMTPAccount."Authentication Type" := SMTPAccount."Authentication Type"::"OAuth 2.0";
        SMTPAccount.Server := 'smtp.office365.com';
        SMTPAccount."Client Id Storage Id" := CreateGuid(); // Only ClientId is present to force partial configuration
        SMTPAccount.Modify();

        SMTPAccountPage.OpenEdit();
        SMTPAccountPage.GoToRecord(SMTPAccount);

        // Turn on Custom OAuth 2.0 (in case it isn't already)
        if not SMTPAccountPage.CustomOAuth2Settings.AsBoolean() then
            SMTPAccountPage.CustomOAuth2Settings.SetValue(true);

        // [THEN] Invoking authenticate should raise an error because Client Secret is missing
        asserterror SMTPAccountPage."Authenticate with Customized OAuth 2.0".Invoke();
        Assert.ExpectedError('To use customized OAuth 2.0 settings, the Client ID, Client Secret and Tenant ID must be provided.');

        SMTPAccountPage.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmCloseCustomOAuthHandler')]
    procedure TestClosePageWithIncompleteCustomOAuthRequiresConfirm()
    begin
        // [SCENARIO] When Custom OAuth 2.0 is enabled but required fields are missing, closing page asks for confirmation.

        // [GIVEN] OAuth 2.0 account with Custom OAuth enabled and incomplete configuration
        CreateSMTPAccount();
        SMTPAccount."Authentication Type" := SMTPAccount."Authentication Type"::"OAuth 2.0";
        SMTPAccount."Client Id Storage Id" := CreateGuid(); // Only ClientId present
        SMTPAccount.Modify();

        SMTPAccountPage.OpenEdit();
        SMTPAccountPage.GoToRecord(SMTPAccount);

        // Ensure Custom OAuth 2.0 setting is true
        if not SMTPAccountPage.CustomOAuth2Settings.AsBoolean() then
            SMTPAccountPage.CustomOAuth2Settings.SetValue(true);

        // [WHEN] Closing the page
        SMTPAccountPage.Close();

        // [THEN] The ConfirmCloseCustomOAuthHandler confirms that the right question was asked
    end;

    [ConfirmHandler]
    procedure ConfirmCloseCustomOAuthHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Assert.AreEqual('To use customized OAuth 2.0 settings, the Client ID, Client Secret and Tenant ID must be provided. Do you want to exit without these information?', Question, 'Unexpected confirmation question when closing page with incomplete Custom OAuth settings.');
        Reply := true;
    end;

    #endregion

    #region Wizard page tests 
    [Test]
    procedure TestOpenSMTPAccountWizard()
    begin
        // [SCENARIO] SMTP Account Wizard page can be opened successfully

        // [WHEN] Opening the SMTP Account Wizard page
        SMTPAccountWizardPage.OpenNew();

        // [THEN] The page opens without errors and is editable
        Assert.IsTrue(SMTPAccountWizardPage.Editable(), 'Page should be editable');

        SMTPAccountWizardPage.Close();
    end;

    [Test]
    procedure TestAccountNameValidation()
    begin
        // [SCENARIO] Account Name field validation works correctly in wizard

        // [WHEN] Opening the wizard and setting account name
        SMTPAccountWizardPage.OpenNew();
        SMTPAccountWizardPage.NameField.SetValue('Test Wizard Account');

        // [THEN] The name is set correctly
        Assert.AreEqual('Test Wizard Account', SMTPAccountWizardPage.NameField.Value(), 'Account name should be set correctly');

        SMTPAccountWizardPage.Close();
    end;

    [Test]
    procedure TestSenderTypeFieldInWizard()
    begin
        // [SCENARIO] Sender Type field changes affect field editability in wizard

        // [WHEN] Opening the wizard and setting sender type
        SMTPAccountWizardPage.OpenNew();
        SMTPAccountWizardPage.SenderTypeField.SetValue("SMTP Connector Sender Type"::"Specific User");

        // [THEN] Sender fields become enabled
        Assert.IsTrue(SMTPAccountWizardPage.SenderNameField.Enabled(), 'Sender Name should be enabled for Specific User');
        Assert.IsTrue(SMTPAccountWizardPage.EmailAddress.Enabled(), 'Email Address should be enabled for Specific User');

        // [WHEN] Changing to Current User
        SMTPAccountWizardPage.SenderTypeField.SetValue("SMTP Connector Sender Type"::"Current User");

        // [THEN] Sender fields become disabled
        Assert.IsFalse(SMTPAccountWizardPage.SenderNameField.Enabled(), 'Sender Name should not be enabled for Current User');
        Assert.IsFalse(SMTPAccountWizardPage.EmailAddress.Enabled(), 'Email Address should not be enabled for Current User');

        SMTPAccountWizardPage.Close();
    end;

    [Test]
    procedure TestEmailAddressInWizard()
    begin
        // [SCENARIO] Email Address field works correctly in wizard

        // [WHEN] Opening the wizard and setting up specific user
        SMTPAccountWizardPage.OpenNew();
        SMTPAccountWizardPage.NameField.SetValue('Test Account');
        SMTPAccountWizardPage.SenderTypeField.SetValue("SMTP Connector Sender Type"::"Specific User");
        SMTPAccountWizardPage.EmailAddress.SetValue('wizard@example.com');

        // [THEN] Email address is set correctly
        Assert.AreEqual('wizard@example.com', SMTPAccountWizardPage.EmailAddress.Value(), 'Email address should be set correctly');

        SMTPAccountWizardPage.Close();
    end;

    [Test]
    procedure TestServerConfigurationInWizard()
    begin
        // [SCENARIO] Server configuration works correctly in wizard

        // [WHEN] Opening the wizard and setting server details
        SMTPAccountWizardPage.OpenNew();
        SMTPAccountWizardPage.NameField.SetValue('Test Server Account');
        SMTPAccountWizardPage.ServerUrl.SetValue('smtp.gmail.com');
        SMTPAccountWizardPage.ServerPort.SetValue(587);

        // [THEN] Server details are set correctly
        Assert.AreEqual('smtp.gmail.com', SMTPAccountWizardPage.ServerUrl.Value(), 'Server URL should be set correctly');
        Assert.AreEqual('587', SMTPAccountWizardPage.ServerPort.Value(), 'Server port should be set correctly');

        SMTPAccountWizardPage.Close();
    end;

    [Test]
    procedure TestAuthenticationTypesInWizard()
    begin
        // [SCENARIO] Authentication type selection works correctly in wizard

        // [WHEN] Opening the wizard and setting authentication type
        SMTPAccountWizardPage.OpenNew();
        SMTPAccountWizardPage.Authentication.SetValue("SMTP Authentication"::Basic);

        // [THEN] Authentication type is set correctly
        Assert.AreEqual(Format("SMTP Authentication"::Basic), SMTPAccountWizardPage.Authentication.Value(), 'Authentication should be set to Basic');

        // [WHEN] Setting to OAuth 2.0
        SMTPAccountWizardPage.Authentication.SetValue("SMTP Authentication"::"OAuth 2.0");

        // [THEN] OAuth authentication is set
        Assert.AreEqual(Format("SMTP Authentication"::"OAuth 2.0"), SMTPAccountWizardPage.Authentication.Value(), 'Authentication should be set to OAuth 2.0');

        SMTPAccountWizardPage.Close();
    end;

    [Test]
    procedure TestApplyOffice365InWizard()
    begin
        // [SCENARIO] Apply Office 365 settings action works in wizard

        // [WHEN] Opening the wizard and applying Office 365 settings
        SMTPAccountWizardPage.OpenNew();
        SMTPAccountWizardPage.NameField.SetValue('Office 365 Test');
        SMTPAccountWizardPage.ApplyOffice365.Invoke();

        // [THEN] Office 365 settings are applied
        Assert.AreEqual('smtp.office365.com', SMTPAccountWizardPage.ServerUrl.Value(), 'Server should be set to Office 365 SMTP');
        Assert.AreEqual('587', SMTPAccountWizardPage.ServerPort.Value(), 'Port should be set to 587');
        Assert.IsTrue(SMTPAccountWizardPage.SecureConnection.AsBoolean(), 'Secure connection should be enabled');

        SMTPAccountWizardPage.Close();
    end;

    [Test]
    procedure TestUserNameFieldInWizard()
    begin
        // [SCENARIO] User Name field editability changes based on authentication type

        // [WHEN] Opening the wizard and setting Basic authentication
        SMTPAccountWizardPage.OpenNew();
        SMTPAccountWizardPage.Authentication.SetValue("SMTP Authentication"::Basic);

        // [THEN] User Name field is editable
        Assert.IsTrue(SMTPAccountWizardPage.UserName.Editable(), 'User Name should be editable for Basic authentication');

        // [WHEN] Setting to Anonymous authentication
        SMTPAccountWizardPage.Authentication.SetValue("SMTP Authentication"::Anonymous);

        // [THEN] User Name field is not editable
        Assert.IsFalse(SMTPAccountWizardPage.UserName.Editable(), 'User Name should not be editable for Anonymous authentication');

        SMTPAccountWizardPage.Close();
    end;

    [Test]
    procedure TestPasswordFieldInWizard()
    begin
        // [SCENARIO] Password field editability changes based on authentication type

        // [WHEN] Opening the wizard and setting Basic authentication
        SMTPAccountWizardPage.OpenNew();
        SMTPAccountWizardPage.Authentication.SetValue("SMTP Authentication"::Basic);

        // [THEN] Password field is editable
        Assert.IsTrue(SMTPAccountWizardPage.Password.Editable(), 'Password should be editable for Basic authentication');

        // [WHEN] Setting to Anonymous authentication
        SMTPAccountWizardPage.Authentication.SetValue("SMTP Authentication"::Anonymous);

        // [THEN] Password field is not editable
        Assert.IsFalse(SMTPAccountWizardPage.Password.Editable(), 'Password should not be editable for Anonymous authentication');

        SMTPAccountWizardPage.Close();
    end;

    [Test]
    procedure TestSecureConnectionInWizard()
    begin
        // [SCENARIO] Secure Connection field can be toggled in wizard

        // [WHEN] Opening the wizard and enabling secure connection
        SMTPAccountWizardPage.OpenNew();
        SMTPAccountWizardPage.SecureConnection.SetValue(true);

        // [THEN] Secure connection is enabled
        Assert.IsTrue(SMTPAccountWizardPage.SecureConnection.AsBoolean(), 'Secure connection should be enabled');

        // [WHEN] Disabling secure connection
        SMTPAccountWizardPage.SecureConnection.SetValue(false);

        // [THEN] Secure connection is disabled
        Assert.IsFalse(SMTPAccountWizardPage.SecureConnection.AsBoolean(), 'Secure connection should be disabled');

        SMTPAccountWizardPage.Close();
    end;

    [Test]
    procedure TestWizardNavigation()
    begin
        // [SCENARIO] Wizard navigation works correctly

        // [WHEN] Opening the wizard with valid data
        SMTPAccountWizardPage.OpenNew();
        SMTPAccountWizardPage.NameField.SetValue('Navigation Test');
        SMTPAccountWizardPage.ServerUrl.SetValue('smtp.test.com');
        SMTPAccountWizardPage.SenderTypeField.SetValue("SMTP Connector Sender Type"::"Specific User");
        SMTPAccountWizardPage.EmailAddress.SetValue('test@example.com');

        // [THEN] Next button should be enabled
        Assert.IsTrue(SMTPAccountWizardPage.Next.Enabled(), 'Next button should be enabled with valid data');

        SMTPAccountWizardPage.Close();
    end;

    [Test]
    procedure TestWizardNextDisabledUntilBasicFieldsValid()
    begin
        // [SCENARIO] In Step 1, Next is disabled until account is considered valid.

        // [WHEN] Opening the wizard
        SMTPAccountWizardPage.OpenNew();

        // [THEN] Next is initially disabled
        Assert.IsFalse(SMTPAccountWizardPage.Next.Enabled(), 'Next should be disabled when required fields are empty');

        // [WHEN] Filling the required fields (same pattern as in existing tests for a valid account)
        SMTPAccountWizardPage.NameField.SetValue('Validation Test');
        SMTPAccountWizardPage.ServerUrl.SetValue('smtp.test.com');
        SMTPAccountWizardPage.SenderTypeField.SetValue("SMTP Connector Sender Type"::"Specific User");
        SMTPAccountWizardPage.EmailAddress.SetValue('valid@example.com');

        // [THEN] Next becomes enabled
        Assert.IsTrue(SMTPAccountWizardPage.Next.Enabled(), 'Next should be enabled when required fields are filled');

        SMTPAccountWizardPage.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestWizardOAuth2ShowsStep2()
    var
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        // [SCENARIO] When Authentication is OAuth 2.0, Next from Step 1 goes to Step 2 (custom OAuth question).

        // [GIVEN] Force SaaS environment so no "authenticate" message is shown
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [WHEN] Opening wizard and filling basic valid data
        SMTPAccountWizardPage.OpenNew();
        SMTPAccountWizardPage.NameField.SetValue('OAuth Step Test');
        SMTPAccountWizardPage.ServerUrl.SetValue('smtp.office365.com');
        SMTPAccountWizardPage.SenderTypeField.SetValue("SMTP Connector Sender Type"::"Specific User");
        SMTPAccountWizardPage.EmailAddress.SetValue('test@example.com');

        // Set authentication to OAuth 2.0 (this is where the message would be shown in OnPrem)
        SMTPAccountWizardPage.Authentication.SetValue("SMTP Authentication"::"OAuth 2.0");

        // Move to Step 2
        SMTPAccountWizardPage.Next.Invoke();

        // [THEN] Step 2 (Custom app registration question) is visible
        Assert.IsTrue(
            SMTPAccountWizardPage.Custom.Visible(),
            'Custom OAuth question should be visible in Step 2 for OAuth 2.0 flow'
        );

        SMTPAccountWizardPage.Close();
    end;

    [Test]
    procedure TestWizardBackFromStep2ToStep1()
    begin
        // [SCENARIO] Back action navigates from Step 2 to Step 1.

        // [GIVEN] We are in Step 2 (OAuth 2.0 flow)
        SMTPAccountWizardPage.OpenNew();
        SMTPAccountWizardPage.NameField.SetValue('Back Nav Test');
        SMTPAccountWizardPage.ServerUrl.SetValue('smtp.office365.com');
        SMTPAccountWizardPage.SenderTypeField.SetValue("SMTP Connector Sender Type"::"Specific User");
        SMTPAccountWizardPage.EmailAddress.SetValue('test@example.com');
        SMTPAccountWizardPage.Authentication.SetValue("SMTP Authentication"::"OAuth 2.0");
        SMTPAccountWizardPage.Next.Invoke();
        Assert.IsTrue(SMTPAccountWizardPage.Custom.Visible(), 'Custom OAuth question should be visible before pressing Back');

        // [WHEN] Pressing Back
        SMTPAccountWizardPage.Back.Invoke();

        // [THEN] We are back on Step 1 (Name field is visible and Custom is not)
        Assert.IsTrue(SMTPAccountWizardPage.NameField.Visible(), 'Name field should be visible again on Step 1');
        Assert.IsFalse(SMTPAccountWizardPage.Custom.Visible(), 'Custom OAuth question should not be visible on Step 1');

        SMTPAccountWizardPage.Close();
    end;

    [Test]
    procedure TestWizardCustomOAuthDisablesNextUntilOAuthFieldsValid()
    begin
        // [SCENARIO] When using Custom OAuth in the wizard, Next on Step 3 is disabled
        // until Client Id, Client Secret, and Tenant ID are filled.

        // [GIVEN] OAuth 2.0 flow and Step 2 = Custom OAuth enabled
        SMTPAccountWizardPage.OpenNew();
        SMTPAccountWizardPage.NameField.SetValue('Custom OAuth Wizard');
        SMTPAccountWizardPage.ServerUrl.SetValue('smtp.office365.com');
        SMTPAccountWizardPage.SenderTypeField.SetValue("SMTP Connector Sender Type"::"Specific User");
        SMTPAccountWizardPage.EmailAddress.SetValue('test@example.com');
        SMTPAccountWizardPage.Authentication.SetValue("SMTP Authentication"::"OAuth 2.0");

        // Step 1 -> Step 2
        SMTPAccountWizardPage.Next.Invoke();

        // Enable Custom OAuth
        SMTPAccountWizardPage.Custom.SetValue(true);

        // Step 2 -> Step 3
        SMTPAccountWizardPage.Next.Invoke();

        // [THEN] In Step 3, Next should be disabled because OAuth fields are not filled yet
        Assert.IsFalse(SMTPAccountWizardPage.Next.Enabled(), 'Next should be disabled on Step 3 when OAuth fields are empty for Custom OAuth');

        // [WHEN] Filling OAuth fields
        SMTPAccountWizardPage.ClientId.SetValue('client-id-value');
        SMTPAccountWizardPage.ClientSecret.SetValue('client-secret-value');
        SMTPAccountWizardPage."Tenant Id".SetValue(Format(CreateGuid())); // valid GUID string

        // [THEN] Next is enabled after all OAuth fields are valid
        Assert.IsTrue(SMTPAccountWizardPage.Next.Enabled(), 'Next should be enabled once all Custom OAuth fields are filled');

        SMTPAccountWizardPage.Close();
    end;

    [Test]
    procedure TestWizardEmailAddressAutoFillsUserName()
    begin
        // [SCENARIO] In the wizard, setting Email Address when User Name is empty fills User Name.

        SMTPAccountWizardPage.OpenNew();
        SMTPAccountWizardPage.NameField.SetValue('UserName AutoFill');
        SMTPAccountWizardPage.SenderTypeField.SetValue("SMTP Connector Sender Type"::"Specific User");
        SMTPAccountWizardPage.EmailAddress.SetValue('wizard-user@example.com');

        // [THEN] User Name is auto-filled (same as page 4512 behavior)
        Assert.AreEqual('wizard-user@example.com', SMTPAccountWizardPage.UserName.Value(), 'User Name should be auto-filled in wizard');

        SMTPAccountWizardPage.Close();
    end;

    [Test]
    [HandlerFunctions('OAuth2AuthenticationMessageHandler2')]
    procedure TestWizardShowsAuthenticateMessageWhenSwitchingToO365WithOAuth()
    var
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        // [SCENARIO] When Authentication = OAuth 2.0 and Server is set to O365 on-prem,
        // the wizard shows the "every user should authenticate" message.

        // [GIVEN] OnPrem environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);

        SMTPAccountWizardPage.OpenNew();
        SMTPAccountWizardPage.NameField.SetValue('Auth Msg Wizard');
        SMTPAccountWizardPage.SenderTypeField.SetValue("SMTP Connector Sender Type"::"Specific User");
        SMTPAccountWizardPage.EmailAddress.SetValue('user@example.com');

        SMTPAccountWizardPage.Authentication.SetValue("SMTP Authentication"::"OAuth 2.0");

        // [WHEN] Setting server to O365 SMTP server triggers message in OnValidate(ServerUrl)
        SMTPAccountWizardPage.ServerUrl.SetValue('smtp.office365.com');

        // [THEN] OAuth2AuthenticationMessageHandler verifies the message text

        SMTPAccountWizardPage.Close();
    end;

    #endregion

    local procedure CreateSMTPAccount()
    var
        RandomText: Text;
    begin
        SMTPAccount.Init();
        SMTPAccount.Id := CreateGuid();
        RandomText := Format(CreateGuid());
        SMTPAccount.Name := 'Test Account ' + CopyStr(RandomText, 1, 10);
        SMTPAccount.Server := 'smtp.test.com';
        SMTPAccount."Server Port" := 25;
        SMTPAccount."Authentication Type" := SMTPAccount."Authentication Type"::Basic;
        SMTPAccount."Sender Type" := SMTPAccount."Sender Type"::"Current User";
        SMTPAccount.Insert();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        // Handle any messages that might appear during testing
    end;


    [MessageHandler]
    procedure VerifyAuthenticationSuccessMessageHandler(Message: Text[1024])
    begin
        Assert.AreEqual(StrSubstNo(AuthenticationSuccessfulMsg, TokenFromCacheUserNameTxt), Message, 'Incorrect message is shown.');
    end;

    [MessageHandler]
    procedure VerifyAuthenticationFailMessageHandler(Message: Text[1024])
    begin
        Assert.AreEqual(AuthenticationFailedMsg, Message, 'Incorrect message is shown.');
    end;

    [ModalPageHandler]
    procedure AzureADAccessDialogModalPageHandler(var AzureADAccessDialog: TestPage "Azure AD Access Dialog")
    begin
    end;

    local procedure SetAuthFlowProvider(ProviderCodeunit: Integer)
    var
        AzureADMgtSetup: Record "Azure AD Mgt. Setup";
        AzureADAppSetup: Record "Azure AD App Setup";
        DummyKey: Text;
    begin
        AzureADMgtSetup.Get();
        AzureADMgtSetup."Auth Flow Codeunit ID" := ProviderCodeunit;
        AzureADMgtSetup.Modify();

        if not AzureADAppSetup.Get() then begin
            AzureADAppSetup.Init();
            AzureADAppSetup."Redirect URL" := 'http://dummyurl:1234/Main_Instance1/WebClient/OAuthLanding.htm';
            AzureADAppSetup."App ID" := CreateGuid();
            DummyKey := CreateGuid();
            AzureADAppSetup.SetSecretKeyToIsolatedStorage(DummyKey);
            AzureADAppSetup.Insert();
        end;
    end;

    internal procedure SetTokenCache(TokenCache: Text)
    begin
        TokenFromCache := TokenCache;
    end;

    [MessageHandler]
    procedure OAuth2AuthenticationMessageHandler1(Message: Text[1024])
    begin
        Assert.ExpectedMessage('Before people can send email they must authenticate their email account. They can do that by choosing the Authenticate action on the SMTP Account page.', Message);
    end;

    [MessageHandler]
    procedure OAuth2AuthenticationMessageHandler2(Message: Text[1024])
    begin
        Assert.ExpectedMessage('Before people can send email they must authenticate their account.', Message);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Azure AD Auth Flow", 'OnAcquireTokenFromCacheWithCredentials', '', false, false)]
    local procedure OnAcquireTokenFromCacheWithCredentials(ClientID: Text; AppKey: Text; ResourceName: Text; var AccessToken: Text)
    begin
        AccessToken := TokenFromCache;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Azure AD Auth Flow", 'OnCheckProvider', '', false, false)]
    local procedure OnCheckProvider(var Result: Boolean)
    begin
        Result := true;
    end;
}
