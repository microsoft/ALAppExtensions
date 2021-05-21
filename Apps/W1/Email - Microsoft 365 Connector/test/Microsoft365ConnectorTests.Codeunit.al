// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139751 "Microsoft 365 Connector Tests"
{
    Subtype = Test;

    var
        LibraryOutlookRestAPI: Codeunit "Library - Outlook Rest API";
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;
        EmailTxt: Text;
        NameTxt: Text;
        EmailOutlookAPISetupHandlerInvokations: Integer;

    [Test]
    [HandlerFunctions('Microsoft365EmailAccountRegisterHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSendMailPayloadMessage()
    var
        EmailAccount: Record "Email Account";
        EmailMessage: Codeunit "Email Message";
        OutlookAPIClientMock: Codeunit "Outlook API Client Mock";
        OutlookMockInitSubscribers: Codeunit "Outlook Mock Init. Subscribers";
        Microsoft365Connector: Codeunit "Microsoft 365 Connector";
        EmailJson: JsonObject;
    begin
        // [SCENARIO] The json representation of the email message for Microsoft 365 Connector is created correctly
        Initialize();
        LibraryOutlookRestAPI.Initialize();
        BindSubscription(OutlookMockInitSubscribers);

        // [GIVEN] An html formatted email message is created and an account has been registered
        Microsoft365Connector.RegisterAccount(EmailAccount);
        LibraryOutlookRestAPI.CreateEmailMessage(true, EmailMessage);

        // [WHEN] Email message is sent
        Microsoft365Connector.Send(EmailMessage, EmailAccount."Account Id");

        // [THEN] The json output has a specific format
        EmailJson := OutlookAPIClientMock.GetMessage();
        LibraryOutlookRestAPI.VerifyEmailJson(EmailJson, true);

        // [GIVEN] A text email message is created
        LibraryOutlookRestAPI.CreateEmailMessage(false, EmailMessage);

        // [WHEN] Email message is sent
        Microsoft365Connector.Send(EmailMessage, EmailAccount."Account Id");

        // [THEN] The json output has a specific format
        EmailJson := OutlookAPIClientMock.GetMessage();
        LibraryOutlookRestAPI.VerifyEmailJson(EmailJson, false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('Microsoft365EmailAccountRegisterHandler')]
    procedure TestMultipleAccountsCanBeRegisteredAndRetrieved()
    var
        EmailAccount: Record "Email Account";
        OutlookMockInitSubscribers: Codeunit "Outlook Mock Init. Subscribers";
        Microsoft365Connector: Codeunit "Microsoft 365 Connector";
        EmailAccounts: TestPage "Email Accounts";
        AccountIDs: array[3] of guid;
        Emails: array[3] of text[250];
        Names: array[3] of text[250];
        Index: Integer;
    begin
        // [SCENARIO] Multiple accounts can be registered, retrieved and displayed in the "Email Accounts" page
        Initialize();
        LibraryOutlookRestAPI.Initialize();
        BindSubscription(OutlookMockInitSubscribers);

        // [WHEN] Multiple accounts are registered
        for Index := 1 to 3 do begin
            Clear(Microsoft365Connector);
            Emails[Index] := CopyStr(Any.Email(), 1, 250);
            Names[Index] := CopyStr(Any.AlphabeticText(250), 1, 250);
            EmailTxt := Emails[Index];
            NameTxt := Names[Index];
            Microsoft365Connector.RegisterAccount(EmailAccount);
            AccountIDs[Index] := EmailAccount."Account Id";

            // [THEN] Accounts are retrieved from the GetAccounts method
            EmailAccount.DeleteAll();
            Microsoft365Connector.GetAccounts(EmailAccount);
            Assert.RecordCount(EmailAccount, Index);
        end;

        // [THEN] This information is shown on the "Email Accounts" page
        EmailAccounts.OpenView();
        for Index := 1 to 3 do begin
            EmailAccounts.GoToKey(AccountIDs[Index], Enum::"Email Connector"::"Microsoft 365");
            Assert.AreEqual(Emails[Index], EmailAccounts.EmailAddress.Value(), 'A different Email Address was expected.');
            Assert.AreEqual(Names[Index], EmailAccounts.NameField.Value(), 'A different Account Name was expected.');
        end;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('Microsoft365EmailAccountRegisterHandler,Microsoft365ShowEmailAccountHandler')]
    procedure TestShowAccountInformation()
    var
        EmailAccount: Record "Email Account";
        OutlookMockInitSubscribers: Codeunit "Outlook Mock Init. Subscribers";
        Microsoft365Connector: Codeunit "Microsoft 365 Connector";
    begin
        // [SCENARIO] Account Information is displayed in the "Outlook Account" page.
        Initialize();
        LibraryOutlookRestAPI.Initialize();
        BindSubscription(OutlookMockInitSubscribers);

        // [GIVEN] An account has been registered
        Microsoft365Connector.RegisterAccount(EmailAccount);

        // [WHEN] The ShowAccountInformation method is invoked
        Microsoft365Connector.ShowAccountInformation(EmailAccount."Account Id");

        // [THEN] The account page opens and display the information
        // Verify in Microsoft365ShowEmailAccountHandler
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('Microsoft365EmailAccountRegisterHandler,ConfirmHandlerYes,EmailOutlookAPISetupHandler')]
    procedure TestAzureAppRegistrationMissingOnRegisteringAccount()
    var
        EmailOutlookAPISetup: Record "Email - Outlook API Setup";
        EmailAccount: Record "Email Account";
        Microsoft365Connector: Codeunit "Microsoft 365 Connector";
    begin
        // [SCENARIO] The first time an Outlook API based account is added, the Azure App Registration shows up.
        // Once Azure App Registration is set up, the prompt doesn't appear.
        Initialize();
        LibraryOutlookRestAPI.Initialize();

        Clear(Microsoft365Connector);
        EmailTxt := CopyStr(Any.Email(), 1, 250);
        NameTxt := CopyStr(Any.AlphabeticText(250), 1, 250);
        EmailOutlookAPISetup.DeleteAll();
        EmailOutlookAPISetup.Insert();
        EmailOutlookAPISetupHandlerInvokations := 0;

        // [WHEN] The first account is registered
        Microsoft365Connector.RegisterAccount(EmailAccount);

        // [THEN] Email - Outlook API Setup page is opened (confirmed by the presence of the handlers).
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Assert.IsTrue(Question.StartsWith('To connect to your email account you must create an App registration'), 'Expected the App Registration confirm dialog.');
        Reply := true;
    end;

    [ModalPageHandler]
    procedure EmailOutlookAPISetupHandler(var EmailOutlookAPISetup: TestPage "Email - Outlook API Setup")
    begin
        Assert.AreEqual(0, EmailOutlookAPISetupHandlerInvokations, 'The Azure App Registration prompts should appear only once');
        EmailOutlookAPISetupHandlerInvokations += 1;
    end;

    [ModalPageHandler]
    procedure Microsoft365EmailAccountRegisterHandler(var EmailOutlookAccountPage: TestPage "Microsoft 365 Email Wizard")
    begin
        EmailOutlookAccountPage.NameField.Value(NameTxt);
        EmailOutlookAccountPage.EmailAddress.Value(EmailTxt);
        EmailOutlookAccountPage.Next.Invoke();
    end;

    [PageHandler]
    procedure Microsoft365ShowEmailAccountHandler(var EmailOutlookAccountPage: TestPage "Microsoft 365 Email Account")
    begin
        // verify the account was registered successfully

        Assert.AreEqual(NameTxt, EmailOutlookAccountPage.NameField.Value(), 'A different Name was expected.');
        Assert.AreEqual(EmailTxt, EmailOutlookAccountPage.EmailAddress.Value(), 'A different Email was expected.');
    end;

    local procedure Initialize()
    var
        EmailOutlookAccount: Record "Email - Outlook Account";
        EmailOutlookAPISetup: Record "Email - Outlook API Setup";
    begin
        EmailTxt := Any.Email();
        NameTxt := Any.AlphanumericText(20);
        EmailOutlookAccount.DeleteAll();

        EmailOutlookAPISetup.DeleteAll();
        EmailOutlookAPISetup.ClientId := CreateGuid();
        EmailOutlookAPISetup.ClientSecret := CreateGuid();
        EmailOutlookAPISetup.RedirectURL := 'http://localhost:48900/OAuthLanding.htm';
        EmailOutlookAPISetup.Insert();
    end;
}
