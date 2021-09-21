codeunit 79100 "LGS Guest User Connector Tests"
{
    Subtype = Test;

    var
        LibraryOutlookRestAPI: Codeunit "LGS Library - Outlook Rest API";
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        CurrentUserTok: Label 'Current User', MaxLength = 250;

    [Test]
    [HandlerFunctions('GuestUserCreateModalPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestSendMailPayloadMessage()
    var
        EmailAccount: Record "Email Account";
        EmailMessage: Codeunit "Email Message";
        EmailOutlookAPISetup: Record "LGS Guest Outlook - API Setup";
        OutlookAPIClientMock: Codeunit "LGS Outlook API Client Mock";
        OutlookMockInitSubscribers: Codeunit "Outlook Mock Init. Subscribers";
        GuestUserConnector: Codeunit "LGS Guest User Connector";
        EmailJson: JsonObject;
        EmailId: guid;
    begin
        Initialize();
        // [SCENARIO] The json representation of the email message is created correctly
        LibraryOutlookRestAPI.Initialize();
        BindSubscription(OutlookMockInitSubscribers);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] Outlook API Setup is defined
        EmailOutlookAPISetup.DeleteAll();
        EmailOutlookAPISetup.ClientId := CreateGuid();
        EmailOutlookAPISetup.ClientSecret := CreateGuid();
        EmailOutlookAPISetup.Insert();

        // [GIVEN] A text email message is created and an account is created
        GuestUserConnector.RegisterAccount(EmailAccount);
        LibraryOutlookRestAPI.CreateEmailMessage(true, EmailMessage);
        EmailId := EmailMessage.GetId();

        // [WHEN] Email message is sent and 
        GuestUserConnector.Send(EmailMessage, EmailAccount."Account Id");

        // [THEN] The json output has a specific format
        EmailJson := OutlookAPIClientMock.GetMessage();
        LibraryOutlookRestAPI.VerifyEmailJson(EmailJson, true);

        // [GIVEN] A text email message is created
        LibraryOutlookRestAPI.CreateEmailMessage(false, EmailMessage);

        // [WHEN] Email message is sent
        GuestUserConnector.Send(EmailMessage, EmailAccount."Account Id");

        // [THEN] The json output has a specific format
        EmailJson := OutlookAPIClientMock.GetMessage();
        LibraryOutlookRestAPI.VerifyEmailJson(EmailJson, false);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('GuestUserCreateModalPageHandler')]
    procedure TestOnlyASingleAccountCanBeRegistered()
    var
        EmailAccount: Record "Email Account";
        EmailOutlookAPISetup: Record "LGS Guest Outlook - API Setup";
        GuestUserConnector: Codeunit "LGS Guest User Connector";
        OutlookMockInitSubscribers: Codeunit "Outlook Mock Init. Subscribers";
        EmailAccounts: TestPage "Email Accounts";
    begin
        // [SCENARIO] Only a single account can be registered
        Initialize();
        LibraryOutlookRestAPI.Initialize();
        BindSubscription(OutlookMockInitSubscribers);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] Outlook API Setup is defined
        EmailOutlookAPISetup.DeleteAll();
        EmailOutlookAPISetup.ClientId := CreateGuid();
        EmailOutlookAPISetup.ClientSecret := CreateGuid();
        EmailOutlookAPISetup.Insert();

        // [WHEN] The first is registered
        GuestUserConnector.RegisterAccount(EmailAccount);

        // [THEN] The Account is shown on the "Email Accounts" page
        EmailAccounts.OpenView();
        EmailAccounts.GoToKey(EmailAccount."Account Id", Enum::"Email Connector"::"LGS Guest User");

        // [WHEN] A second Account is Registered
        // [THEN] The Next Action is not visible
        asserterror GuestUserConnector.RegisterAccount(EmailAccount);
        Assert.ExpectedError('Next button was not visible.');
    end;


    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('GuestUserViewModalPageHandler')]
    procedure TestShowAccountInformation()
    var
        GuestUserConnector: Codeunit "LGS Guest User Connector";
        OutlookMockInitSubscribers: Codeunit "Outlook Mock Init. Subscribers";
        AccountID: guid;
    begin
        // [SCENARIO] Account Information is displayed in the "Outlook Account" page.
        Initialize();
        LibraryOutlookRestAPI.Initialize();
        BindSubscription(OutlookMockInitSubscribers);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] An account has been registered
        AccountID := CreateGuestUserAccount();

        // [WHEN] The ShowAccountInformation method is invoked
        GuestUserConnector.ShowAccountInformation(AccountID);

        // [THEN] The account page opens and display the information
        // Verify in GuestUserViewModalPageHandler
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('GuestUserCreateModalPageHandler,TestEmailOptionsHandler')]
    procedure TestSendTestEmailCorrectAddressOnPrem()
    var
        EmailAccount: Record "Email Account";
        EmailOutlookAPISetup: Record "LGS Guest Outlook - API Setup";
        OutlookMockInitSubscribers: Codeunit "Outlook Mock Init. Subscribers";
        GuestUserConnector: Codeunit "LGS Guest User Connector";
        OutlookAPIClientMock: codeunit "LGS Outlook API Client Mock";
        EmailAccounts: TestPage "Email Accounts";
    begin
        // [SCENARIO] In SaaS we substitute the guest user email address using the access token if Guest Outlook API Setup is defined
        Initialize();
        OutlookAPIClientMock.SetAccountInformation('testemail@test.com', 'testemail');
        BindSubscription(OutlookMockInitSubscribers);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] Outlook API Setup is defined
        EmailOutlookAPISetup.DeleteAll();
        EmailOutlookAPISetup.ClientId := CreateGuid();
        EmailOutlookAPISetup.ClientSecret := CreateGuid();
        EmailOutlookAPISetup.Insert();

        // [GIVEN] The current user account is registered
        GuestUserConnector.RegisterAccount(EmailAccount);

        Assert.AreEqual('testemail@test.com', EmailAccount."Email Address", 'Wrong email address on the created account');
        Assert.AreEqual(CurrentUserTok, EmailAccount.Name, 'Wrong name on the created account');

        // [GIVEN] Send test email is invoked on the guest user account
        EmailAccounts.OpenView();
        EmailAccounts.GoToKey(EmailAccount."Account Id", Enum::"Email Connector"::"LGS Guest User");
        EmailAccounts.SendTestMail.Invoke();

        // [THEN] The first option in the list is the actual email address of the guest user
        // verified in the handler
    end;

    [StrMenuHandler]
    procedure TestEmailOptionsHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Assert.IsTrue(Options.StartsWith('testemail@test.com,'), 'Current user''s email address should be substituted.');
        Choice := 0;
    end;

    [ModalPageHandler]
    procedure GuestUserViewModalPageHandler(var GuestUserAccountPage: testpage "LGS Guest User Email Account")
    begin
        Assert.IsFalse(GuestUserAccountPage.Next.Visible(), 'Next button was visible.');
        Assert.IsFalse(GuestUserAccountPage.Back.Visible(), 'Back button was visible.');
        Assert.IsTrue(GuestUserAccountPage.Ok.Visible(), 'Ok button was not visible.');
    end;

    [ModalPageHandler]
    procedure GuestUserCreateModalPageHandler(var GuestUserAccountPage: testpage "LGS Guest User Email Account")
    begin
        Assert.IsTrue(GuestUserAccountPage.Next.Visible(), 'Next button was not visible.');
        Assert.IsTrue(GuestUserAccountPage.Back.Visible(), 'Back button was not visible.');
        Assert.IsFalse(GuestUserAccountPage.Ok.Visible(), 'Ok button was visible.');
        GuestUserAccountPage.Next.Invoke();
    end;

    local procedure CreateGuestUserAccount(): guid
    var
        EmailOutlookAccount: Record "LGS Email Guest Outlook Acc.";
    begin
        EmailOutlookAccount.Id := Any.GuidValue();
        EmailOutlookAccount."Outlook API Email Connector" := Enum::"Email Connector"::"LGS Guest User";
        EmailOutlookAccount.Insert();
    end;

    local procedure Initialize()
    var
        EmailOutlookAccount: Record "LGS Email Guest Outlook Acc.";
    begin
        EmailOutlookAccount.DeleteAll();
    end;
}