// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139762 "SMTP Account Auth Tests"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        Assert: Codeunit "Library Assert";
        TokenFromCacheTxt: Label 'aGVhZGVy.eyJ1bmlxdWVfbmFtZSI6InRlc3R1c2VyQGRvbWFpbi5jb20iLCJ1cG4iOiJ0ZXN0dXNlckBkb21haW4uY29tIn0=.c2lnbmF0dXJl', Comment = 'Access token example (with no secret data)', Locked = true;
        TokenFromCacheUserNameTxt: Label 'testuser@domain.com', Locked = true;
        AuthenticationSuccessfulMsg: Label '%1 was authenticated.';
        AuthenticationFailedMsg: Label 'Could not authenticate.';
        EveryUserShouldPressAuthenticateMsg: Label 'Before people can send email they must authenticate their email account. They can do that by choosing the Authenticate action on the SMTP Account page.';
        TokenFromCache: Text;

    [Test]
    [HandlerFunctions('OAuth2AuthenticationMessageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure SwitchingToOAuth2Authentication()
    var
        SMTPAccount: Record "SMTP Account";
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        SMTPAccountPage: TestPage "SMTP Account";
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
    end;

    [Test]
    procedure GetUserNameTest()
    var
        OAuth2SMTPAuthentication: Codeunit "OAuth2 SMTP Authentication";
        ReturnedUserName: Text;
    begin
        OAuth2SMTPAuthentication.GetUserName(TokenFromCacheTxt, ReturnedUserName);
        Assert.AreEqual(TokenFromCacheUserNameTxt, ReturnedUserName, 'Incorrect returned username.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure GetOAuth2CredentialsTest()
    var
        OAuth2SMTPAuthentication: Codeunit "OAuth2 SMTP Authentication";
        SMTPAccountAuthTests: Codeunit "SMTP Account Auth Tests";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        UserName: Text;
        AuthToken: Text;
    begin
        // [SCENARIO] If the provided server is the O365 SMTP server, and there is available token cache,
        // the access token is acquires from cache and the user name variable is filled.

        // [GIVEN] Environment is on-prem and token from cache with credentials is available.
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        SetAuthFlowProvider(Codeunit::"SMTP Account Auth Tests");
        SMTPAccountAuthTests.SetTokenCache(TokenFromCacheTxt);
        BindSubscription(SMTPAccountAuthTests);

        // [WHEN] AuthenticateWithOAuth2 is called.
        OAuth2SMTPAuthentication.GetOAuth2Credentials(UserName, AuthToken);

        // [THEN] The AuthToken and UserName have the expected values.
        Assert.AreEqual(TokenFromCacheUserNameTxt, UserName, 'UserName should not have been filled.');
        Assert.AreEqual(TokenFromCacheTxt, AuthToken, 'AuthToken should not have been filled.');
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
    begin
        AzureADMgtSetup.Get();
        AzureADMgtSetup."Auth Flow Codeunit ID" := ProviderCodeunit;
        AzureADMgtSetup.Modify();

        if not AzureADAppSetup.Get() then begin
            AzureADAppSetup.Init();
            AzureADAppSetup."Redirect URL" := 'http://dummyurl:1234/Main_Instance1/WebClient/OAuthLanding.htm';
            AzureADAppSetup."App ID" := CreateGuid();
            AzureADAppSetup.SetSecretKeyToIsolatedStorage(CreateGuid());
            AzureADAppSetup.Insert();
        end;
    end;

    internal procedure SetTokenCache(TokenCache: Text)
    begin
        TokenFromCache := TokenCache;
    end;

    [MessageHandler]
    procedure OAuth2AuthenticationMessageHandler(Message: Text[1024])
    begin
        Assert.AreEqual(EveryUserShouldPressAuthenticateMsg, Message, 'Incorrect message is shown.');
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
