// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139750 "Current User Connector Tests"
{
    Subtype = Test;

    var
        LibraryOutlookRestAPI: Codeunit "Library - Outlook Rest API";
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        CurrentUserTok: Label 'Current User', MaxLength = 250;

    [Test]
    [HandlerFunctions('CurrentUserCreateModalPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSendMailPayloadMessage()
    var
        EmailAccount: Record "Email Account";
        EmailMessage: Codeunit "Email Message";
        OutlookAPIClientMock: Codeunit "Outlook API Client Mock";
        OutlookMockInitSubscribers: Codeunit "Outlook Mock Init. Subscribers";
        CurrentUserConnector: Codeunit "Current User Connector";
        EmailJson: JsonObject;
        EmailId: guid;
    begin
        Initialize();
        // [SCENARIO] The json representation of the email message is created correctly
        LibraryOutlookRestAPI.Initialize();
        BindSubscription(OutlookMockInitSubscribers);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] A text email message is created and an account is created
        CurrentUserConnector.RegisterAccount(EmailAccount);
        LibraryOutlookRestAPI.CreateEmailMessage(true, EmailMessage);
        EmailId := EmailMessage.GetId();

        // [WHEN] Email message is sent and 
        CurrentUserConnector.Send(EmailMessage, EmailAccount."Account Id");

        // [THEN] The json output has a specific format
        EmailJson := OutlookAPIClientMock.GetMessage();
        LibraryOutlookRestAPI.VerifyEmailJson(EmailJson, true);

        // [GIVEN] A text email message is created
        LibraryOutlookRestAPI.CreateEmailMessage(false, EmailMessage);

        // [WHEN] Email message is sent
        CurrentUserConnector.Send(EmailMessage, EmailAccount."Account Id");

        // [THEN] The json output has a specific format
        EmailJson := OutlookAPIClientMock.GetMessage();
        LibraryOutlookRestAPI.VerifyEmailJson(EmailJson, false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('CurrentUserCreateModalPageHandler')]
    procedure TestOnlyASingleAccountCanBeRegistered()
    var
        EmailAccount: Record "Email Account";
        CurrentUserConnector: Codeunit "Current User Connector";
        OutlookMockInitSubscribers: Codeunit "Outlook Mock Init. Subscribers";
        EmailAccounts: TestPage "Email Accounts";
    begin
        // [SCENARIO] Only a single account can be registered
        Initialize();
        LibraryOutlookRestAPI.Initialize();
        BindSubscription(OutlookMockInitSubscribers);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [WHEN] The first is registered
        CurrentUserConnector.RegisterAccount(EmailAccount);

        // [THEN] The Account is shown on the "Email Accounts" page
        EmailAccounts.OpenView();
        EmailAccounts.GoToKey(EmailAccount."Account Id", Enum::"Email Connector"::"Current User");

        // [WHEN] A second Account is Registered
        // [THEN] The Next Action is not visible
        asserterror CurrentUserConnector.RegisterAccount(EmailAccount);
        Assert.ExpectedError('Next button was not visible.');
    end;


    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('CurrentUserViewModalPageHandler')]
    procedure TestShowAccountInformation()
    var
        CurrentUserConnector: Codeunit "Current User Connector";
        OutlookMockInitSubscribers: Codeunit "Outlook Mock Init. Subscribers";
        AccountID: guid;
    begin
        // [SCENARIO] Account Information is displayed in the "Outlook Account" page.
        Initialize();
        LibraryOutlookRestAPI.Initialize();
        BindSubscription(OutlookMockInitSubscribers);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] An account has been registered
        AccountID := CreateCurrentUserAccount();

        // [WHEN] The ShowAccountInformation method is invoked
        CurrentUserConnector.ShowAccountInformation(AccountID);

        // [THEN] The account page opens and display the information
        // Verify in CurrentUserViewModalPageHandler
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('CurrentUserCreateModalPageHandler,TestEmailOptionsHandler')]
    procedure TestSendTestEmailCorrectAddressOnPrem()
    var
        EmailAccount: Record "Email Account";
        EmailOutlookAPISetup: Record "Email - Outlook API Setup";
        OutlookMockInitSubscribers: Codeunit "Outlook Mock Init. Subscribers";
        CurrentUserConnector: Codeunit "Current User Connector";
        OutlookAPIClientMock: codeunit "Outlook API Client Mock";
        EmailAccounts: TestPage "Email Accounts";
    begin
        // [SCENARIO] OnPrem we substitute the current user email address using the access token if Outlook API Setup is defined
        Initialize();
        OutlookAPIClientMock.SetAccountInformation('testemail@test.com', 'testemail');
        BindSubscription(OutlookMockInitSubscribers);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);

        // [GIVEN] Outlook API Setup is defined
        EmailOutlookAPISetup.DeleteAll();
        EmailOutlookAPISetup.ClientId := CreateGuid();
        EmailOutlookAPISetup.ClientSecret := CreateGuid();
        EmailOutlookAPISetup.Insert();

        // [GIVEN] The current user account is registered
        CurrentUserConnector.RegisterAccount(EmailAccount);

        Assert.AreEqual('testemail@test.com', EmailAccount."Email Address", 'Wrong email address on the created account');
        Assert.AreEqual(CurrentUserTok, EmailAccount.Name, 'Wrong name on the created account');

        // [GIVEN] Send test email is invoked on the current user account
        EmailAccounts.OpenView();
        EmailAccounts.GoToKey(EmailAccount."Account Id", Enum::"Email Connector"::"Current User");
        EmailAccounts.SendTestMail.Invoke();

        // [THEN] The first option in the list is the actual email address of the current user
        // verified in the handler
    end;

    [StrMenuHandler]
    procedure TestEmailOptionsHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Assert.IsTrue(Options.StartsWith('testemail@test.com,'), 'Current user''s email address should be substituted.');
        Choice := 0;
    end;

    [ModalPageHandler]
    procedure CurrentUserViewModalPageHandler(var CurrentUserAccountPage: testpage "Current User Email Account")
    begin
        Assert.IsFalse(CurrentUserAccountPage.Next.Visible(), 'Next button was visible.');
        Assert.IsFalse(CurrentUserAccountPage.Back.Visible(), 'Back button was visible.');
        Assert.IsTrue(CurrentUserAccountPage.Ok.Visible(), 'Ok button was not visible.');
    end;

    [ModalPageHandler]
    procedure CurrentUserCreateModalPageHandler(var CurrentUserAccountPage: testpage "Current User Email Account")
    begin
        Assert.IsTrue(CurrentUserAccountPage.Next.Visible(), 'Next button was not visible.');
        Assert.IsTrue(CurrentUserAccountPage.Back.Visible(), 'Back button was not visible.');
        Assert.IsFalse(CurrentUserAccountPage.Ok.Visible(), 'Ok button was visible.');
        CurrentUserAccountPage.Next.Invoke();
    end;

    local procedure CreateCurrentUserAccount(): guid
    var
        EmailOutlookAccount: Record "Email - Outlook Account";
    begin
        EmailOutlookAccount.Id := Any.GuidValue();
        EmailOutlookAccount."Outlook API Email Connector" := Enum::"Email Connector"::"Current User";
        EmailOutlookAccount.Insert();
    end;

    local procedure Initialize()
    var
        EmailOutlookAccount: Record "Email - Outlook Account";
    begin
        EmailOutlookAccount.DeleteAll();
    end;
}