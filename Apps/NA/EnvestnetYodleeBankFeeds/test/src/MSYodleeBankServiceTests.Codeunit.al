codeunit 139501 "MS - Yodlee Bank Service Tests"
{
    // version Test,W1

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun();
    begin
    end;

    var
        Assert: Codeunit "Assert";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryJobQueue: Codeunit "Library - Job Queue";
        IsInitialized: Boolean;
        DataEncryptionTxt: Label 'Data encryption is not activated. It is recommended that you encrypt data. \Do you want to open the Data Encryption Management window?';
        ForceStatus200Txt: Label '/status200', Locked = true;
        ServiceErr: Label 'The remote server returned an error: %1', Locked = true;
        SetupSuccessfulTxt: Label 'The setup test was successful. The settings are valid.';
        InvalidResponseTxt: Label 'The response was not valid.';
        DataEncryptExportTxt: Label 'The encryption key file must be protected by a password and stored in a safe location.';
        DataEncryptConfirmTxt: Label 'Enabling encryption will generate an encryption key on the server.';
        MissingPasswordTxt: Label 'The password is missing in the Envestnet Yodlee Bank Feeds Service Setup window.';
        CobrandMustBeSpecifiedTxt: Label 'By modifying the Service URL you must specify your own Cobrand credentials.';
        DisableServiceAndRemoveAccTxt: Label 'Disabling the service will unlink all online bank accounts.';
        NoLinkedBankAccountsTxt: Label 'Do you want to clear the online bank login details?';
        LoginOKTxt: Label '/loginOK';
        CannotGetLinkedAccountsErr: Label 'The updated list of linked bank accounts could not be shown.';
        GetAccountsFailedTxt: Label '/getAccountsFailed';
        DetailsFailedTxt: Label '/detailsFailed';
        Error500Txt: Label '(500) Server Error.';
        DetailsOKTxt: Label '/detailsOK';
        DetailsDuplicateAccountIdTxt: Label '/detailsDuplicateAccountId';
        DetailsMFATxt: Label '/detailsMFA';
        TestGetTransactionsTxt: Label '/TestGetTrans';
        LinkingRemovedMsg: Label '1 bank accounts have been unlinked.';
        LinkingInsertedMsg: Label 'has been linked.';
        CurrencyErr: Label 'The bank feed that you are importing contains transactions in currencies other than';
        BankAccountErr: Label 'The bank feed that you are importing contains transactions for a different bank account.';
        MatchSummaryMsg: Label '%1 payment lines out of %2 are applied.', Comment = '%2 is the total of lines, %1 is the ones applied';
        UriNotSecureErr: Label 'The URI is not secure.';
        UriNotValidErr: Label 'The URI is not valid.';
        DisableBankStatementSvcTxt: Label 'Do you want to disable the bank feed service?';
        RefreshMsgTxt: Label 'The value in the To Date field is later than the date of the current bank feed.';
        JobQEntriesCreatedQst: Label 'A job queue entry for import of bank statements has been created.\\Do you want to open the Job Queue Entry window?';
        TransactionImportTimespanMustBePositiveErr: Label 'The value in the Number of Days Included field must be a positive number not greater than 9999.';
        ResetTokenTxt: Label '/resetToken';
        StaleErr: Label 'Your session has expired. Please try the operation again.';
        BankStmtImportFormatEmptyErr: Label 'Bank Feed Import Format must have a value';
        BankAccLinkingURLEmptyErr: Label 'Bank Acc. Linking URL must have a value';
        TestServiceFriendlyNameTxt: Label 'Test Statement Provider Service';
        YodleeServiceNameTxt: Label 'Envestnet Yodlee Bank Feeds Service';
        TermsNotAcceptedTxt: Label 'You must accept the Envestnet Yodlee terms of use before you can use the service.';
        LinkingsUpToDateTxt: Label 'All bank account links are up to date, or no online bank accounts exist.';
        NoNewBankAccountsTxt: Label 'No new bank account is created or linked because all online bank accounts are already linked.';
        NoMoreAccountsMsg: Label 'All non-linked bank accounts have been removed. This page will now close.';
        EnableYodleeQst: Label 'The Envestnet Yodlee Bank Feeds Service has not been enabled. Do you want to enable it?';
        DemoCompanyWithDefaultCredentialMsg: Label 'You cannot use the Envestnet Yodlee Bank Feeds Service on the demonstration company. Open another company and try again.';
        BadCobrandTxt: Label 'The cobrand credentials or the Service URL are not valid.';
        CobrandNameTxt: Label 'CobrandName', Locked = true;
        CobrandPwdTxt: Label 'CobrandPwd', Locked = true;
        ConsumerPwdTxt: Label 'ConsumerPwd', Locked = true;
        TestServiceBaseURLTxt: Label 'https://localhost:8080/BankStatement', Locked = true;
        ForceStatus500Txt: Label '/status500';
        ForceStatus404Txt: Label '/status404', Locked = true;
        ForceStatus403Txt: Label '/status403', Locked = true;
        TransactionNotLoggedTxt: Label 'Expected transaction not logged. Detailed Info: %1 Activity Message: %2', Locked = true;

    local procedure Initialize();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        CryptographyManagement: Codeunit "Cryptography Management";
        DummyBlankRecId: RecordID;
    begin
        LibraryVariableStorage.Clear();
        SetupBankStatementService();

        SetDemoCompanyState(FALSE);

        BankAccount.MODIFYALL("Bank Stmt. Service Record ID", DummyBlankRecId);
        MSYodleeBankAccLink.DELETEALL();

        // Configure encryption key if it does not exist
        IF NOT CryptographyManagement.IsEncryptionEnabled() THEN BEGIN
            EnqueueConfirmMsgAndResponse(DataEncryptConfirmTxt, TRUE);
            EnqueueConfirmMsgAndResponse(DataEncryptExportTxt, FALSE);
            CryptographyManagement.EnableEncryption(FALSE);
        END;

        IF IsInitialized THEN
            EXIT;

        ConfigureVATPostingSetup();

        IsInitialized := TRUE;
    end;

    local procedure InitializeEncryptionTest(var Username: Text; var Password: Text; var ConsumerCredentials: Text; var ServiceUrl: Text);
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        CryptographyManagement: Codeunit "Cryptography Management";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
    begin
        Initialize();

        // Enable SaaS mode
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(TRUE);

        // Configure encryption key if it does not exist
        IF NOT CryptographyManagement.IsEncryptionEnabled() THEN BEGIN
            EnqueueConfirmMsgAndResponse(DataEncryptConfirmTxt, TRUE);
            EnqueueConfirmMsgAndResponse(DataEncryptExportTxt, FALSE);
            CryptographyManagement.EnableEncryption(FALSE);
        END;

        Username := FORMAT(CREATEGUID());
        Password := FORMAT(CREATEGUID());
        ConsumerCredentials := FORMAT(CREATEGUID());
        ServiceUrl := TestServiceBaseURLTxt + LoginOKTxt;

        WITH MSYodleeBankServiceSetup DO
            IF GET() THEN
                DELETE(TRUE);

        MSYodleeBankServiceSetupPage.OPENEDIT();

        MSYodleeBankServiceSetupPage."Consumer Name".VALUE :=
          COPYSTR(ConsumerCredentials, 1, MAXSTRLEN(MSYodleeBankServiceSetup."Consumer Name"));
        MSYodleeBankServiceSetupPage.ConsumerPwd.VALUE := ConsumerCredentials;
        MSYodleeBankServiceSetupPage."Log Web Requests".SETVALUE(TRUE);
        MSYodleeBankServiceSetupPage.CobrandName.SetValue(Username);
        MSYodleeBankServiceSetupPage.CobrandPwd.SetValue(Password);
        MSYodleeBankServiceSetupPage."Service URL".SetValue(ServiceUrl);
        MSYodleeBankServiceSetupPage."Bank Acc. Linking URL".SetValue(ServiceUrl);
        MSYodleeBankServiceSetupPage.CLOSE();

        MSYodleeBankServiceSetup.GET();
        MSYodleeBankServiceSetup."Accept Terms of Use" := TRUE;
        IF MSYodleeBankServiceSetup."Bank Feed Import Format" = '' THEN
            MSYodleeBankServiceSetup."Bank Feed Import Format" := 'YODLEEBANKFEED';
        MSYodleeBankServiceSetup.MODIFY();
    end;

    local procedure SetupBankStatementService();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        CryptographyManagement: Codeunit "Cryptography Management";
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
    begin
        IF CryptographyManagement.IsEncryptionEnabled() THEN
            CryptographyManagement.DisableEncryption(TRUE);

        WITH MSYodleeBankServiceSetup DO BEGIN
            IF GET() THEN
                DELETE(TRUE);

            CLEAR(MSYodleeBankServiceSetup);
        END;

        MSYodleeBankServiceSetupPage.OPENEDIT();
        MSYodleeBankServiceSetupPage.SetDefaults.INVOKE();

        IF MSYodleeBankServiceSetupPage."User Profile Email Address".VALUE() = '' THEN
            MSYodleeBankServiceSetupPage."User Profile Email Address".VALUE :=
              LibraryUtility.GenerateRandomCode(
                MSYodleeBankServiceSetup.FIELDNO("User Profile Email Address"), DATABASE::"MS - Yodlee Bank Service Setup");

        IF MSYodleeBankServiceSetupPage."Bank Feed Import Format".VALUE() = '' THEN
            MSYodleeBankServiceSetupPage."Bank Feed Import Format".VALUE := 'YODLEEBANKFEED';

        MSYodleeBankServiceSetupPage."Service URL".VALUE := TestServiceBaseURLTxt;

        Assert.IsFalse(MSYodleeBankServiceSetupPage.DefaultCredentials.ASBOOLEAN(), 'Preconfigured credentials are present');

        EnqueueConfirmMsgAndResponse(DataEncryptionTxt, FALSE);
        MSYodleeBankServiceSetupPage.ConsumerPwd.VALUE := ConsumerPwdTxt;

        EnqueueConfirmMsgAndResponse(DataEncryptionTxt, FALSE);
        MSYodleeBankServiceSetupPage.CobrandName.VALUE := CobrandNameTxt;

        EnqueueConfirmMsgAndResponse(DataEncryptionTxt, FALSE);
        MSYodleeBankServiceSetupPage.CobrandPwd.VALUE := CobrandPwdTxt;

        Assert.IsFalse(MSYodleeBankServiceSetupPage.DefaultCredentials.ASBOOLEAN(), 'Preconfigured credentials are present');

        MSYodleeBankServiceSetupPage."Log Web Requests".SETVALUE(TRUE);

        MSYodleeBankServiceSetupPage.Enabled.SETVALUE(TRUE);

        MSYodleeBankServiceSetupPage.CLOSE();

        MSYodleeBankServiceSetup.GET();
        MSYodleeBankServiceSetup."Accept Terms of Use" := TRUE;
        MSYodleeBankServiceSetup.MODIFY();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestServiceHandles500();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        // Setup
        Initialize();
        AppendServiceUrl(ForceStatus500Txt);

        // Exercise
        ASSERTERROR MSYodleeBankServiceSetup.CheckSetup();
        Assert.ExpectedError(STRSUBSTNO(ServiceErr, '(500) Server Error.') + '\' + BadCobrandTxt);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestServiceHandles404();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        // Setup
        Initialize();
        AppendServiceUrl(ForceStatus404Txt);

        // Exercise
        ASSERTERROR MSYodleeBankServiceSetup.CheckSetup();
        Assert.ExpectedError(STRSUBSTNO(ServiceErr, '(404) Not Found'));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestServiceHandles403();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        // Setup
        Initialize();
        AppendServiceUrl(ForceStatus403Txt);

        // Exercise
        ASSERTERROR MSYodleeBankServiceSetup.CheckSetup();
        Assert.ExpectedError(STRSUBSTNO(ServiceErr, '(403) Forbidden'));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestServiceInvalidCobrandResponse();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        // Setup
        Initialize();
        AppendServiceUrl(ForceStatus200Txt);

        // Exercise
        ASSERTERROR MSYodleeBankServiceSetup.CheckSetup();
        Assert.ExpectedError(InvalidResponseTxt);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler,ConsentConfirmYes')]
    procedure TestServiceHandles200();
    var
        MSYodleeBankServiceSetup: TestPage "MS - Yodlee Bank Service Setup";
    begin
        // Setup
        Initialize();
        AppendServiceUrl(LoginOKTxt);

        // Expected Message
        LibraryVariableStorage.Enqueue(SetupSuccessfulTxt);

        // Exercise
        MSYodleeBankServiceSetup.OPENEDIT();
        MSYodleeBankServiceSetup.TestSetup.INVOKE();

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestServiceDisabledFromWarning();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
    begin
        // Setup
        Initialize();

        // Verify service is enabled
        MSYodleeBankServiceSetup.GET();
        Assert.IsTrue(MSYodleeBankServiceSetup.Enabled, '');

        EnqueueConfirmMsgAndResponse(DisableBankStatementSvcTxt, TRUE);

        // Exercise
        MSYodleeBankServiceSetupPage.OPENEDIT();
        MSYodleeBankServiceSetupPage.ShowEnableWarning.DRILLDOWN();

        // Assert
        MSYodleeBankServiceSetup.FindFirst();
        Assert.IsFalse(MSYodleeBankServiceSetup.Enabled, '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestServiceEnableWithEmptyBankStmtImportFormat();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        // Setup
        Initialize();

        // Verify service is enabled
        MSYodleeBankServiceSetup.GET();
        MSYodleeBankServiceSetup.VALIDATE(Enabled, FALSE);
        MSYodleeBankServiceSetup."Bank Feed Import Format" := '';
        MSYodleeBankServiceSetup.MODIFY();

        ASSERTERROR MSYodleeBankServiceSetup.VALIDATE(Enabled, TRUE);
        Assert.ExpectedError(BankStmtImportFormatEmptyErr);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestServiceEnableWithEmptyBankAccLinkingURL();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        // Setup
        Initialize();

        // Verify service is enabled
        MSYodleeBankServiceSetup.GET();
        MSYodleeBankServiceSetup.VALIDATE(Enabled, FALSE);
        MSYodleeBankServiceSetup."Bank Acc. Linking URL" := '';
        MSYodleeBankServiceSetup.MODIFY();

        ASSERTERROR MSYodleeBankServiceSetup.VALIDATE(Enabled, TRUE);
        Assert.ExpectedError(BankAccLinkingURLEmptyErr);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestServiceChangingPassword();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
        OldPassword: Text;
        NewPassword: Text;
    begin
        // Setup
        Initialize();

        NewPassword := CREATEGUID();
        OldPassword := CREATEGUID();

        MSYodleeBankServiceSetupPage.OPENEDIT();
        EnqueueConfirmMsgAndResponse(DataEncryptionTxt, FALSE);
        MSYodleeBankServiceSetupPage.CobrandPwd.VALUE := OldPassword + 'cob';

        EnqueueConfirmMsgAndResponse(DataEncryptionTxt, FALSE);
        MSYodleeBankServiceSetupPage.ConsumerPwd.VALUE := OldPassword + 'con';

        // Verify setup
        MSYodleeBankServiceSetup.FINDFIRST();
        Assert.AreEqual(OldPassword + 'cob', MSYodleeBankServiceSetup.GetPassword(MSYodleeBankServiceSetup."Cobrand Password"), '');
        Assert.AreEqual(OldPassword + 'con', MSYodleeBankServiceSetup.GetPassword(MSYodleeBankServiceSetup."Consumer Password"), '');

        // Exercise
        EnqueueConfirmMsgAndResponse(DataEncryptionTxt, FALSE);
        MSYodleeBankServiceSetupPage.CobrandPwd.VALUE := NewPassword + 'cob';

        EnqueueConfirmMsgAndResponse(DataEncryptionTxt, FALSE);
        MSYodleeBankServiceSetupPage.ConsumerPwd.VALUE := NewPassword + 'con';

        // Assert
        MSYodleeBankServiceSetup.FIND();
        Assert.AreEqual(NewPassword + 'cob', MSYodleeBankServiceSetup.GetPassword(MSYodleeBankServiceSetup."Cobrand Password"), '');
        Assert.AreEqual(NewPassword + 'con', MSYodleeBankServiceSetup.GetPassword(MSYodleeBankServiceSetup."Consumer Password"), '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestServiceSetsServiceURLs();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        // Setup
        Initialize();

        // Clear URLs
        MSYodleeBankServiceSetup.FINDFIRST();
        MSYodleeBankServiceSetup."Service URL" := '';
        MSYodleeBankServiceSetup."Bank Acc. Linking URL" := '';
        MSYodleeBankServiceSetup.MODIFY();

        // Exercise
        MSYodleeBankServiceSetup.SetValuesToDefault();
        MSYodleeBankServiceSetup.MODIFY(TRUE);

        // Assert
        MSYodleeBankServiceSetup.FindFirst();
        Assert.AreNotEqual('', MSYodleeBankServiceSetup."Service URL", '');
        Assert.AreNotEqual('', MSYodleeBankServiceSetup."Bank Acc. Linking URL", '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestServiceDisallowsInsecureURLs();
    var
        MSYodleeBankServiceSetup: TestPage "MS - Yodlee Bank Service Setup";
    begin
        // Setup
        Initialize();

        // Exercise & Assert
        MSYodleeBankServiceSetup.OPENEDIT();

        ASSERTERROR MSYodleeBankServiceSetup."Service URL".VALUE := 'http://an.insecure.url';
        Assert.ExpectedError(UriNotSecureErr);

        ASSERTERROR MSYodleeBankServiceSetup."Bank Acc. Linking URL".VALUE := 'http://another.insecure.url';
        Assert.ExpectedError(UriNotSecureErr);

        ASSERTERROR MSYodleeBankServiceSetup."Bank Acc. Linking URL".VALUE := 'file://c:/a/strange/path/somewhere';
        Assert.ExpectedError(UriNotSecureErr);

        ASSERTERROR MSYodleeBankServiceSetup."Service URL".VALUE := 'not a url';
        Assert.ExpectedError(UriNotValidErr);

        ASSERTERROR MSYodleeBankServiceSetup."Bank Acc. Linking URL".VALUE := 'this is also not a url';
        Assert.ExpectedError(UriNotValidErr);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestLogErrorOnConnectionFailure();
    var
        ActivityLog: Record "Activity Log";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        // Setup
        Initialize();
        AppendServiceUrl(ForceStatus500Txt);

        // Clear Activity Log
        ActivityLog.DELETEALL();

        // Exercise
        ASSERTERROR MSYodleeBankServiceSetup.CheckSetup();
        Assert.ExpectedError(STRSUBSTNO(ServiceErr, '(500) Server Error.') + '\' + BadCobrandTxt);

        // Assert Log Entry
        ActivityLog.SETRANGE(Status, ActivityLog.Status::Failed);
        Assert.IsFalse(ActivityLog.IsEmpty(), 'No failed statuses have been logged');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestSetupDoesNotPromptToOpenSetupPageWithMissingCredentials();
    var
        MSYodleeBankServiceSetup: TestPage "MS - Yodlee Bank Service Setup";
    begin
        // Setup
        Initialize();
        MSYodleeBankServiceSetup.OPENEDIT();
        MSYodleeBankServiceSetup.Enabled.SETVALUE(FALSE);
        MSYodleeBankServiceSetup.CobrandName.VALUE('');
        MSYodleeBankServiceSetup.CobrandPwd.VALUE('');
        MSYodleeBankServiceSetup.Enabled.SETVALUE(TRUE);

        // Exercise
        ASSERTERROR MSYodleeBankServiceSetup.TestSetup.INVOKE();

        // Verify
        Assert.ExpectedError(MissingPasswordTxt);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestBankLinkingActionNotVisibleWithMissingCredentials();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        BankAccountListPage: TestPage "Bank Account List";
    begin
        // Setup
        Initialize();

        MSYodleeBankServiceSetup.GET();
        CLEAR(MSYodleeBankServiceSetup."Cobrand Name");
        CLEAR(MSYodleeBankServiceSetup."Cobrand Password");
        MSYodleeBankServiceSetup.VALIDATE(Enabled, TRUE);
        MSYodleeBankServiceSetup.MODIFY();

        // Exercise
        BankAccountListPage.OPENVIEW();
        Assert.IsFalse(BankAccountListPage.CreateNewLinkedBankAccount.VISIBLE(), 'Expected that action is invisible');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler,ConsentConfirmYes')]
    procedure TestSessionTokens();
    var
        MSYodleeBankSession: Record "MS - Yodlee Bank Session";
        MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
    begin
        // Setup
        Initialize();

        AppendServiceUrl(LoginOKTxt);

        LibraryVariableStorage.Enqueue(SetupSuccessfulTxt);

        // exercise & verify
        MSYodleeServiceMgt.CheckSetup();

        Assert.IsTrue(MSYodleeBankSession.GetCobrandSessionToken() <> '', '');
        Assert.IsTrue(MSYodleeBankSession.GeConsumerSessionToken() <> '', '');

        // exercise & verify
        MSYodleeBankSession.VALIDATE("Cons. Token Last Date Updated", CURRENTDATETIME() - 1000 * 60 * 26);
        MSYodleeBankSession.MODIFY(TRUE);
        Assert.IsTrue(MSYodleeBankSession.GeConsumerSessionToken() = '', '');

        // exercise & verify
        LibraryVariableStorage.Enqueue(SetupSuccessfulTxt);
        MSYodleeServiceMgt.CheckSetup();

        Assert.IsTrue(MSYodleeBankSession.GetCobrandSessionToken() <> '', '');
        Assert.IsTrue(MSYodleeBankSession.GeConsumerSessionToken() <> '', '');

        // exercise & verify
        MSYodleeBankSession.GET();
        MSYodleeBankSession.VALIDATE("Cob. Token Last Date Updated", CURRENTDATETIME() - 1000 * 60 * 96);
        MSYodleeBankSession.MODIFY(TRUE);

        Assert.IsTrue(MSYodleeBankSession.GetCobrandSessionToken() = '', '');
        Assert.IsTrue(MSYodleeBankSession.GeConsumerSessionToken() = '', '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestResetSessionTokens();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankSession: Record "MS - Yodlee Bank Session";
        BankAccountList: TestPage "Bank Account List";
    begin
        // Setup
        Initialize();

        AppendServiceUrl(ResetTokenTxt + LoginOKTxt);

        CreateLinkedBankAccount(BankAccount);

        // Exercise
        BankAccountList.OPENVIEW();
        BankAccountList.GOTORECORD(BankAccount);
        ASSERTERROR BankAccountList.UpdateBankAccountLinking.INVOKE();
        Assert.ExpectedError(StaleErr);
        Assert.IsTrue(MSYodleeBankSession.GetCobrandSessionToken() = '', '');
        Assert.IsTrue(MSYodleeBankSession.GeConsumerSessionToken() = '', '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestBankLinkingServiceData();
    var
        BankAccount: Record "Bank Account";
        MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
        TypeHelper: Codeunit "Type Helper";
        XMLRootNode: XmlNode;
        Data: Text;
        ErrorText: Text;
        BankAccountName: Text;
    begin
        // Setup
        Initialize();

        AppendServiceUrl(LoginOKTxt);

        CreateLinkedBankAccount(BankAccount);

        // Exercise
        MSYodleeServiceMgt.GetFastlinkDataForLinking(BankAccount.Name, Data, ErrorText);
        Assert.AreEqual('', ErrorText, ErrorText);

        // Convert to XML for Asserts
        ConvertJsonToXml(Data, XMLRootNode);

        // Assert
        BankAccountName := BankAccount.Name;
        Assert.AreEqual('10003600', MSYodleeServiceMgt.FindNodeText(XMLRootNode, '//root/app'), '');
        Assert.AreEqual('consumertoken', MSYodleeServiceMgt.FindNodeText(XMLRootNode, '//root/rsession'), '');
        Assert.AreEqual('fastlinktoken', MSYodleeServiceMgt.FindNodeText(XMLRootNode, '//root/token'), '');
        Assert.AreEqual('true', MSYodleeServiceMgt.FindNodeText(XMLRootNode, '//root/redirectReq'), '');
        Assert.AreEqual(
          STRSUBSTNO('keyword=%1', TypeHelper.UrlEncode(BankAccountName)),
          MSYodleeServiceMgt.FindNodeText(XMLRootNode, '//root/extraParams'),
          '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestBankLinkingServiceRefreshData();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
        XMLRootNode: XmlNode;
        Data: Text;
        ErrorText: Text;
    begin
        // Setup
        Initialize();

        AppendServiceUrl(LoginOKTxt);

        BankAccount.FINDFIRST();
        MakeMsYodleeBankAccLink(MSYodleeBankAccLink, BankAccount, '10097740', '10171852');

        // Exercise
        MSYodleeServiceMgt.GetFastlinkDataForMfaRefresh(MSYodleeBankAccLink."Online Bank ID", 'callbackurl', Data, ErrorText);
        Assert.AreEqual('', ErrorText, ErrorText);

        // Convert to XML for Asserts
        ConvertJsonToXml(Data, XMLRootNode);

        // Assert
        Assert.AreEqual('10003600', MSYodleeServiceMgt.FindNodeText(XMLRootNode, '//root/app'), '');
        Assert.AreEqual('consumertoken', MSYodleeServiceMgt.FindNodeText(XMLRootNode, '//root/rsession'), '');
        Assert.AreEqual('fastlinktoken', MSYodleeServiceMgt.FindNodeText(XMLRootNode, '//root/token'), '');
        Assert.AreEqual('true', MSYodleeServiceMgt.FindNodeText(XMLRootNode, '//root/redirectReq'), '');
        Assert.AreEqual(
          STRSUBSTNO('siteAccountId=%1&flow=refresh&callback=%2', MSYodleeBankAccLink."Online Bank ID", 'callbackurl'),
          MSYodleeServiceMgt.FindNodeText(XMLRootNode, '//root/extraParams'), '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestBankLinkingServiceRefreshAutomatic();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
    begin
        // Setup
        Initialize();
        BankAccount.FINDFIRST();
        MakeMsYodleeBankAccLink(MSYodleeBankAccLink, BankAccount, '10097740', '10171852');

        AppendServiceUrl(DetailsOKTxt + LoginOKTxt);

        // Exercise
        MSYodleeServiceMgt.LazyBankDataRefresh(MSYodleeBankAccLink."Online Bank ID", MSYodleeBankAccLink."Online Bank Account ID", TODAY());
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler,BankAccountRefreshMFAHandler,ConsentConfirmYes')]
    procedure TestBankLinkingServiceRefreshMFA();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
    begin
        // Setup
        Initialize();

        BankAccount.FINDFIRST();
        MakeMsYodleeBankAccLink(MSYodleeBankAccLink, BankAccount, '10097740', '10171852');

        AppendServiceUrl(DetailsMFATxt + LoginOKTxt);

        // Exercise
        LibraryVariableStorage.Enqueue(RefreshMsgTxt);
        MSYodleeServiceMgt.LazyBankDataRefresh(MSYodleeBankAccLink."Online Bank ID", MSYodleeBankAccLink."Online Bank Account ID", TODAY());

        // Assert in handlers

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestBankLinkingUpdateGetLinkedAccountsFail();
    var
        BankAccount: Record "Bank Account";
        BankAccountList: TestPage "Bank Account List";
    begin
        // Setup
        Initialize();

        AppendServiceUrl(GetAccountsFailedTxt + LoginOKTxt);

        CreateLinkedBankAccount(BankAccount);

        // Exercise
        BankAccountList.OPENVIEW();
        BankAccountList.GOTORECORD(BankAccount);

        ASSERTERROR BankAccountList.UpdateBankAccountLinking.INVOKE();
        Assert.ExpectedError(CannotGetLinkedAccountsErr);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestBankLinkingUpdateGetDetailedLinkedAccountsFail();
    var
        BankAccount: Record "Bank Account";
        BankAccountList: TestPage "Bank Account List";
    begin
        // Setup
        Initialize();

        AppendServiceUrl(DetailsFailedTxt + LoginOKTxt);

        CreateLinkedBankAccount(BankAccount);

        // Exercise
        BankAccountList.OPENVIEW();
        BankAccountList.GOTORECORD(BankAccount);

        ASSERTERROR BankAccountList.UpdateBankAccountLinking.INVOKE();
        Assert.ExpectedError(Error500Txt);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler,ConsentConfirmYes')]
    procedure TestBankLinkingUpdateFindsExistingAccounts();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        BankAccountList: TestPage "Bank Account List";
    begin
        // Setup
        Initialize();

        AppendServiceUrl(DetailsOKTxt + LoginOKTxt);

        BankAccount.FINDFIRST();
        MakeMsYodleeBankAccLink(MSYodleeBankAccLink, BankAccount, '10097740', '10171852');

        // Exercise
        BankAccountList.OPENVIEW();
        LibraryVariableStorage.Enqueue(LinkingsUpToDateTxt);
        BankAccountList.UpdateBankAccountLinking.INVOKE();

        // Assert in Message

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,CloseBankLinkingHandler,ConsentConfirmYes')]
    procedure TestBankLinkingUpdateFindsExistingDuplicateAccount();
    var
        BankAccountList: TestPage "Bank Account List";
    begin
        // Setup
        Initialize();
        AppendServiceUrl(DetailsDuplicateAccountIdTxt + LoginOKTxt);

        // Exercise
        BankAccountList.OPENVIEW();
        BankAccountList.UpdateBankAccountLinking.INVOKE();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler,FastlinkHandler,ConsentConfirmYes')]
    procedure TestBankLinkingCreateWithNoNewAccounts();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        BankAccountList: TestPage "Bank Account List";
    begin
        // Setup
        Initialize();

        AppendServiceUrl(DetailsOKTxt + LoginOKTxt);

        BankAccount.FINDFIRST();
        MakeMsYodleeBankAccLink(MSYodleeBankAccLink, BankAccount, '10097740', '10171852');

        // Exercise
        BankAccountList.OPENVIEW();
        LibraryVariableStorage.Enqueue(NoNewBankAccountsTxt);
        BankAccountList.CreateNewLinkedBankAccount.INVOKE();

        // Assert in Message
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler,ConsentConfirmYes')]
    procedure TestBankLinkingUpdateLaunchFromNonLinkedBankAccount();
    var
        BankAccount: Record "Bank Account";
        NonLinkedBankAccount: Record "Bank Account";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        BankAccountList: TestPage "Bank Account List";
    begin
        // Setup
        Initialize();

        AppendServiceUrl(DetailsOKTxt + LoginOKTxt);

        BankAccount.FINDFIRST();
        MakeMsYodleeBankAccLink(MSYodleeBankAccLink, BankAccount, '10097740', '10171852');

        LibraryERM.CreateBankAccount(NonLinkedBankAccount);

        // Exercise
        BankAccountList.OPENVIEW();
        BankAccountList.GOTORECORD(NonLinkedBankAccount);
        LibraryVariableStorage.Enqueue(LinkingsUpToDateTxt);
        BankAccountList.UpdateBankAccountLinking.INVOKE();

        // Assert in Message

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler,ConsentConfirmYes')]
    procedure TestBankLinkingUpdateRemovesUnlinkedAccounts();
    var
        BankAccount: Record "Bank Account";
        BankAccount2: Record "Bank Account";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        BankAccountList: TestPage "Bank Account List";
    begin
        // Setup
        Initialize();

        AppendServiceUrl(DetailsOKTxt + LoginOKTxt);

        CreateLinkedBankAccount(BankAccount);
        CreateLinkedBankAccount(BankAccount2);
        MakeMsYodleeBankAccLink(MSYodleeBankAccLink, BankAccount, '10097740', '10171852'); // site & account exist in "yodlee"
        MakeMsYodleeBankAccLink(MSYodleeBankAccLink, BankAccount2, '10097741', '10171852'); // site does not exist - to be unlinked

        LibraryVariableStorage.Enqueue(LinkingRemovedMsg);

        // Exercise
        BankAccountList.OPENVIEW();
        BankAccountList.GOTORECORD(BankAccount);
        BankAccountList.UpdateBankAccountLinking.INVOKE();

        // Assert in Message
        BankAccount.FIND();
        BankAccount2.FIND();
        Assert.AreEqual(TRUE, BankAccount.IsLinkedToBankStatementServiceProvider(), '');
        Assert.AreEqual(FALSE, BankAccount2.IsLinkedToBankStatementServiceProvider(), '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmHandler,BankLinkingHandler,ConsentConfirmYes')]
    procedure TestBankLinkingUpdatePromptsMissingLinkings();
    var
        BankAccount: Record "Bank Account";
    begin
        // Setup
        Initialize();

        AppendServiceUrl(DetailsOKTxt + LoginOKTxt);

        // Exercise
        UpdateBankAccountPromptsMissingLink(BankAccount);

        // Assert
        VerifyBankAccountPromptsMissingLink();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmHandler,BankLinkingActionHandler,BankLinkingActionHandlerStepTwo,ConsentConfirmYes')]
    procedure TestBankLinkingUpdatePromptsMissingLinkingsWithAction();
    var
        BankAccount: Record "Bank Account";
    begin
        // Setup
        Initialize();

        AppendServiceUrl(DetailsOKTxt + LoginOKTxt);

        // Exercise
        UpdateBankAccountPromptsMissingLink(BankAccount);

        // Assert
        VerifyBankAccountPromptsMissingLink();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmHandler,BankLinkingCreateNewHandler,BankAccountCardHandler,ConsentConfirmYes')]
    procedure TestBankLinkingUpdateMissLinksCreateNew();
    var
        BankAccount: Record "Bank Account";
        BankAccountNo: Code[20];
        BankAccountNoVariant: Variant;
    begin
        // Setup
        Initialize();

        AppendServiceUrl(DetailsOKTxt + LoginOKTxt);

        LibraryVariableStorage.Enqueue(FALSE);
        LibraryVariableStorage.Enqueue(LinkingInsertedMsg);

        // Exercise
        UpdateBankAccountLink(BankAccount);

        // Assert
        LibraryVariableStorage.Dequeue(BankAccountNoVariant);
        BankAccountNo := BankAccountNoVariant;
        BankAccount.GET(BankAccountNo);
        LibraryVariableStorage.AssertEmpty();
        Assert.AreEqual(TRUE, BankAccount.IsLinkedToBankStatementServiceProvider(), '');
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmHandler,BankLinkingCreateNewHandler,BankAccountCardHandler,ConsentConfirmYes')]
    procedure TestBankLinkingUpdateMissLinksReselect();
    var
        BankAccount: Record "Bank Account";
        BankAccountNo: Code[20];
        BankAccountNoVariant: Variant;
    begin
        // Setup
        Initialize();

        AppendServiceUrl(DetailsOKTxt + LoginOKTxt);

        LibraryVariableStorage.Enqueue(TRUE);
        LibraryVariableStorage.Enqueue(LinkingInsertedMsg);

        // Exercise
        UpdateBankAccountLink(BankAccount);

        // Assert
        LibraryVariableStorage.Dequeue(BankAccountNoVariant); // not needed but added in the create new handler
        LibraryVariableStorage.Dequeue(BankAccountNoVariant); // actual one to be used
        BankAccountNo := BankAccountNoVariant;
        BankAccount.GET(BankAccountNo);
        LibraryVariableStorage.AssertEmpty();
        Assert.AreEqual(TRUE, BankAccount.IsLinkedToBankStatementServiceProvider(), '');
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmHandler,FastlinkHandler,ConsentConfirmYes')]
    procedure TestBankLinkingUpdateAutoLink();
    var
        BankAccount: Record "Bank Account";
        BankAccountList: TestPage "Bank Account List";
        BankAccountNo: Text;
    begin
        // Setup
        Initialize();

        AppendServiceUrl(DetailsOKTxt + LoginOKTxt);

        LibraryVariableStorage.Enqueue(LinkingInsertedMsg);

        // Exercise
        CreateLinkedBankAccount(BankAccount);
        BankAccountList.OPENVIEW();
        BankAccountList.GOTORECORD(BankAccount);
        BankAccountNo := BankAccountList."No.".VALUE();
        BankAccountList.LinkToOnlineBankAccount.INVOKE();

        // Assert
        BankAccount.GET(BankAccountNo);
        LibraryVariableStorage.AssertEmpty();
        Assert.AreEqual(TRUE, BankAccount.IsLinkedToBankStatementServiceProvider(), '');
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmHandler,FastlinkHandler,BankAccountCardHandler,ConsentConfirmYes')]
    procedure TestBankLinkingUpdateCreateNewAndAutoLink();
    var
        BankAccount: Record "Bank Account";
        BankAccountList: TestPage "Bank Account List";
        BankAccountNo: Code[20];
        BankAccountNoVariant: Variant;
    begin
        // Setup
        Initialize();

        AppendServiceUrl(DetailsOKTxt + LoginOKTxt);

        LibraryVariableStorage.Enqueue(LinkingInsertedMsg);

        // Exercise
        CreateLinkedBankAccount(BankAccount);
        BankAccountList.OPENVIEW();
        BankAccountList.GOTORECORD(BankAccount);
        BankAccountList.CreateNewLinkedBankAccount.INVOKE();

        // Assert
        LibraryVariableStorage.Dequeue(BankAccountNoVariant);
        BankAccountNo := BankAccountNoVariant;
        BankAccount.GET(BankAccountNo);
        LibraryVariableStorage.AssertEmpty();
        Assert.AreEqual(TRUE, BankAccount.IsLinkedToBankStatementServiceProvider(), '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestBankLinkingUpdateUnLink();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        BankAccountList: TestPage "Bank Account List";
    begin
        // Setup
        Initialize();

        AppendServiceUrl(DetailsOKTxt + LoginOKTxt);

        BankAccount.FINDFIRST();
        MakeMsYodleeBankAccLink(MSYodleeBankAccLink, BankAccount, '10097740', '10097740');

        // Exercise
        BankAccountList.OPENVIEW();
        BankAccountList.FIRST();
        BankAccountList.UnlinkOnlineBankAccount.INVOKE();

        // Assert
        BankAccount.FIND();
        Assert.AreEqual(FALSE, BankAccount.IsLinkedToBankStatementServiceProvider(), '');
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmHandler,BankLinkingUnlinkHandler,ConsentConfirmYes')]
    procedure TestBankLinkingUpdateUnLinkAction();
    var
        BankAccountList: TestPage "Bank Account List";
    begin
        // Setup
        Initialize();

        AppendServiceUrl(DetailsOKTxt + LoginOKTxt);

        BankAccountList.OPENVIEW();

        // Exercise
        LibraryVariableStorage.Enqueue('NoLink');
        BankAccountList.UpdateBankAccountLinking.INVOKE();

        // Assert
        VerifyBankLinkingUpdate();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmHandler,BankLinkingUnlinkHandler,BankLinkingActionHandlerStepTwo,ConsentConfirmYes')]
    procedure TestBankLinkingUpdateUnLinkActionFromLinkedAccount();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        GeneralLedgerSetup: Record "General Ledger Setup";
        BankAccountList: TestPage "Bank Account List";
    begin
        // Setup
        Initialize();
        GeneralLedgerSetup.GET();

        AppendServiceUrl(DetailsOKTxt + LoginOKTxt);

        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount."Currency Code" := GeneralLedgerSetup.GetCurrencyCode('USD');
        BankAccount.Modify();

        BankAccountList.OPENVIEW();

        // Exercise
        LibraryVariableStorage.Enqueue('Link');
        LibraryVariableStorage.Enqueue(BankAccount."No.");
        BankAccountList.UpdateBankAccountLinking.INVOKE();

        // Assert
        BankAccount.SETFILTER("Bank Stmt. Service Record ID", STRSUBSTNO('<>%1', ''''''));
        Assert.IsTrue(BankAccount.IsEmpty(), 'Linked bank accounts exist');
        Assert.IsTrue(MSYodleeBankAccLink.IsEmpty(), 'Linked Yodlee accounts exist');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmHandler,BankLinkingUnlinkHandler,BankAccountCardHandler,ConsentConfirmYes')]
    procedure TestBankLinkingUpdateUnLinkActionFromNewLinkedAccount();
    var
        BankAccountList: TestPage "Bank Account List";
    begin
        Initialize();

        AppendServiceUrl(DetailsOKTxt + LoginOKTxt);

        BankAccountList.OPENVIEW();

        // Exercise
        LibraryVariableStorage.Enqueue('Create');
        BankAccountList.UpdateBankAccountLinking.INVOKE();

        // Assert
        VerifyBankLinkingUpdate();
    end;

    [Test]
    [HandlerFunctions('BankStatementFilterHandler,ConfirmHandler,ConsentConfirmYes')]
    procedure TestGetTransactions();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        PaymentReconciliationJournal: TestPage "Payment Reconciliation Journal";
    begin
        // Setup
        Initialize();
        SetupForOnlineImportingOfTransactions(MSYodleeBankServiceSetup, BankAccount);

        // Import bank transactions
        LibraryERM.CreateBankAccReconciliation(BankAccReconciliation, BankAccount."No.", BankAccReconciliation."Statement Type"::"Payment Application");
        OpenPmtReconJnl(BankAccReconciliation, PaymentReconciliationJournal);
        PaymentReconciliationJournal.ImportBankTransactions.INVOKE();

        VerifyPmtReconJnlWithOnlineTransactions(PaymentReconciliationJournal);
        BankAccReconciliation.Delete(true);
    end;

    [Test]
    [HandlerFunctions('BankStatementFilterHandler,ConfirmHandler,ConsentConfirmYes')]
    procedure TestGetTransactionsWithActivityLogging();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        ActivityLog: Record "Activity Log";
        PaymentReconciliationJournal: TestPage "Payment Reconciliation Journal";
    begin
        // Setup
        Initialize();
        ActivityLog.DeleteAll();
        SetupForOnlineImportingOfTransactions(MSYodleeBankServiceSetup, BankAccount);

        // turn logging on
        MSYodleeBankServiceSetup.Get();
        MSYodleeBankServiceSetup."Log Web Requests" := true;
        MSYodleeBankServiceSetup.Modify();

        // Import bank transactions
        LibraryERM.CreateBankAccReconciliation(BankAccReconciliation, BankAccount."No.", BankAccReconciliation."Statement Type"::"Payment Application");
        OpenPmtReconJnl(BankAccReconciliation, PaymentReconciliationJournal);
        PaymentReconciliationJournal.ImportBankTransactions.Invoke();

        // turn logging off
        MSYodleeBankServiceSetup."Log Web Requests" := false;
        MSYodleeBankServiceSetup.Modify();

        VerifyActivityLogWithOnlineTransactions(ActivityLog);
    end;

    [Test]
    [HandlerFunctions('BankStatementFilterHandler,ConfirmHandler,PaymentBankAccountListHandler,MessageHandler,ConsentConfirmYes')]
    procedure TestGetTransactionsIntoNewPmtReconJnl();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        PaymentReconciliationJournal: TestPage "Payment Reconciliation Journal";
        PmtReconciliationJournals: TestPage "Pmt. Reconciliation Journals";
    begin
        // Setup
        Initialize();
        SetupForOnlineImportingOfTransactions(MSYodleeBankServiceSetup, BankAccount);

        // Import bank transactions
        LibraryVariableStorage.Enqueue(BankAccount."No.");
        PmtReconciliationJournals.OPENVIEW();
        PaymentReconciliationJournal.TRAP();
        LibraryVariableStorage.Enqueue(STRSUBSTNO(MatchSummaryMsg, 0, 3));
        PmtReconciliationJournals.ImportBankTransactionsToNew.INVOKE();

        VerifyPmtReconJnlWithOnlineTransactions(PaymentReconciliationJournal);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestSetUpJobQueueToGetTransactions();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // Setup
        Initialize();
        SetupForOnlineImportingOfTransactions(MSYodleeBankServiceSetup, BankAccount);
        DoNotEnableJobQueue();

        // enable job queue entry
        EnqueueConfirmMsgAndResponse(JobQEntriesCreatedQst, FALSE);
        BankAccount.VALIDATE("Automatic Stmt. Import Enabled", TRUE);
        JobQueueEntry.SETRANGE("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SETRANGE("Object ID to Run", CODEUNIT::"Automatic Import of Bank Stmt.");
        JobQueueEntry.SETFILTER("Record ID to Process", FORMAT(BankAccount.RECORDID()));
        JobQueueEntry.SETRANGE("Recurring Job", TRUE);
        Assert.AreEqual(1, JobQueueEntry.COUNT(), '');

        // disable job queue entry
        BankAccount.VALIDATE("Automatic Stmt. Import Enabled", FALSE);
        Assert.AreEqual(0, JobQueueEntry.COUNT(), '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestJobQueueRemovedOnAccountDeletion();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // Setup
        Initialize();
        SetupForOnlineImportingOfTransactions(MSYodleeBankServiceSetup, BankAccount);
        DoNotEnableJobQueue();

        // enable job queue entry
        EnqueueConfirmMsgAndResponse(JobQEntriesCreatedQst, FALSE);
        BankAccount.VALIDATE("Automatic Stmt. Import Enabled", TRUE);
        JobQueueEntry.SETRANGE("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SETRANGE("Object ID to Run", CODEUNIT::"Automatic Import of Bank Stmt.");
        JobQueueEntry.SETFILTER("Record ID to Process", FORMAT(BankAccount.RECORDID()));
        JobQueueEntry.SETRANGE("Recurring Job", TRUE);
        Assert.AreEqual(1, JobQueueEntry.COUNT(), '');

        // delete the bank account with no trigger...
        EnqueueConfirmMsgAndResponse(NoLinkedBankAccountsTxt, TRUE);
        BankAccount.DELETE();

        // Assert our job queue has been removed
        Assert.AreEqual(0, JobQueueEntry.COUNT(), '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestUnlinkingRemovesJobQueue();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        JobQueueEntry: Record "Job Queue Entry";
        MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
    begin
        // Setup
        Initialize();
        SetupForOnlineImportingOfTransactions(MSYodleeBankServiceSetup, BankAccount);
        DoNotEnableJobQueue();

        // enable job queue entry
        EnqueueConfirmMsgAndResponse(JobQEntriesCreatedQst, FALSE);
        BankAccount.VALIDATE("Automatic Stmt. Import Enabled", TRUE);

        // unlink bank account
        MSYodleeServiceMgt.MarkBankAccountAsUnlinked(BankAccount."No.");

        // verify
        JobQueueEntry.SETRANGE("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SETRANGE("Object ID to Run", CODEUNIT::"Automatic Import of Bank Stmt.");
        JobQueueEntry.SETFILTER("Record ID to Process", FORMAT(BankAccount.RECORDID()));
        JobQueueEntry.SETRANGE("Recurring Job", TRUE);
        Assert.AreEqual(0, JobQueueEntry.COUNT(), '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestDisablingYodleeRemovesJobQueue();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        JobQueueEntry: Record "Job Queue Entry";
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
    begin
        // Setup
        Initialize();
        SetupForOnlineImportingOfTransactions(MSYodleeBankServiceSetup, BankAccount);
        DoNotEnableJobQueue();

        // enable job queue entry
        EnqueueConfirmMsgAndResponse(JobQEntriesCreatedQst, FALSE);
        BankAccount.VALIDATE("Automatic Stmt. Import Enabled", TRUE);

        // Disable the service
        MSYodleeBankServiceSetupPage.OPENEDIT();
        MSYodleeBankServiceSetupPage.Enabled.SETVALUE(FALSE);

        // verify
        JobQueueEntry.SETRANGE("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SETRANGE("Object ID to Run", CODEUNIT::"Automatic Import of Bank Stmt.");
        JobQueueEntry.SETFILTER("Record ID to Process", FORMAT(BankAccount.RECORDID()));
        JobQueueEntry.SETRANGE("Recurring Job", TRUE);
        Assert.IsTrue(JobQueueEntry.ISEMPTY(), '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestSetUpJobQueueInvalidNumberOfDaysIncluded();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        InvalidHighNumber: Integer;
        InvalidLowNumber: Integer;
    begin
        // Setup
        Initialize();
        SetupForOnlineImportingOfTransactions(MSYodleeBankServiceSetup, BankAccount);
        InvalidHighNumber := LibraryRandom.RandIntInRange(10000, 10000000);
        InvalidLowNumber := LibraryRandom.RandIntInRange(-10000000, -1);

        // enable job queue entry
        BankAccount."Transaction Import Timespan" := InvalidHighNumber;
        ASSERTERROR BankAccount.VALIDATE("Automatic Stmt. Import Enabled", TRUE);
        Assert.ExpectedError(TransactionImportTimespanMustBePositiveErr);

        BankAccount."Transaction Import Timespan" := InvalidLowNumber;
        ASSERTERROR BankAccount.VALIDATE("Automatic Stmt. Import Enabled", TRUE);
        Assert.ExpectedError(TransactionImportTimespanMustBePositiveErr);
    end;

    [Test]
    [HandlerFunctions('BankStatementFilterHandler,ConfirmHandler,MessageHandler,ConsentConfirmYes')]
    procedure TestGetTransactionsViaJobQueue();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        JobQueueEntry: Record "Job Queue Entry";
        PaymentReconciliationJournal: TestPage "Payment Reconciliation Journal";
    begin
        // Setup
        Initialize();
        SetupForOnlineImportingOfTransactions(MSYodleeBankServiceSetup, BankAccount);

        // Import bank transactions
        LibraryVariableStorage.Enqueue(STRSUBSTNO(MatchSummaryMsg, 0, 3));
        JobQueueEntry.INIT();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Record ID to Process" := BankAccount.RECORDID();
        JobQueueEntry."Object ID to Run" := CODEUNIT::"Automatic Import of Bank Stmt.";

        PaymentReconciliationJournal.TRAP();
        CODEUNIT.RUN(CODEUNIT::"Automatic Import of Bank Stmt.", JobQueueEntry);

        VerifyPmtReconJnlWithOnlineTransactions(PaymentReconciliationJournal);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('BankStatementFilterHandler,ConfirmHandler,MessageHandler,ConsentConfirmYes')]
    procedure TestGetTransactionsViaJobQueueTwice();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        JobQueueEntry: Record "Job Queue Entry";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        PaymentReconciliationJournal: TestPage "Payment Reconciliation Journal";
    begin
        // Setup
        Initialize();
        SetupForOnlineImportingOfTransactions(MSYodleeBankServiceSetup, BankAccount);

        // Import bank transactions
        LibraryVariableStorage.Enqueue(STRSUBSTNO(MatchSummaryMsg, 0, 3));
        JobQueueEntry.INIT();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Record ID to Process" := BankAccount.RECORDID();
        JobQueueEntry."Object ID to Run" := CODEUNIT::"Automatic Import of Bank Stmt.";

        PaymentReconciliationJournal.TRAP();
        CODEUNIT.RUN(CODEUNIT::"Automatic Import of Bank Stmt.", JobQueueEntry);
        CODEUNIT.RUN(CODEUNIT::"Automatic Import of Bank Stmt.", JobQueueEntry);

        VerifyPmtReconJnlWithOnlineTransactions(PaymentReconciliationJournal);

        BankAccReconciliation.SETRANGE("Bank Account No.", BankAccount."No.");
        Assert.AreEqual(1, BankAccReconciliation.COUNT(), 'Second import should not create a new Payment Rec Jnl');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('BankStatementFilterHandler,ConfirmHandler,ConsentConfirmYes')]
    procedure TestGetTransactionsCurrencyMissmatch();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        PaymentReconciliationJournal: TestPage "Payment Reconciliation Journal";
    begin
        // Setup
        Initialize();
        SetupForOnlineImportingOfTransactions(MSYodleeBankServiceSetup, BankAccount);

        // set different currency code
        BankAccount."Currency Code" := 'DKK';
        BankAccount.MODIFY();

        // Import bank transactions
        LibraryERM.CreateBankAccReconciliation(BankAccReconciliation, BankAccount."No.", BankAccReconciliation."Statement Type"::"Payment Application");
        OpenPmtReconJnl(BankAccReconciliation, PaymentReconciliationJournal);
        ASSERTERROR PaymentReconciliationJournal.ImportBankTransactions.INVOKE();
        Assert.ExpectedError(CurrencyErr);
    end;

    [Test]
    [HandlerFunctions('BankStatementFilterHandler,ConfirmHandler,ConsentConfirmYes')]
    procedure TestGetTransactionsWrongBankAccountID();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        PaymentReconciliationJournal: TestPage "Payment Reconciliation Journal";
    begin
        // Setup
        Initialize();
        SetupForOnlineImportingOfTransactions(MSYodleeBankServiceSetup, BankAccount);

        // corrupt bank account ID
        MSYodleeBankAccLink.GET(BankAccount."No.");
        MSYodleeBankAccLink."Online Bank Account ID" := LibraryUtility.GenerateGUID();
        MSYodleeBankAccLink.MODIFY();

        // Import bank transactions
        LibraryERM.CreateBankAccReconciliation(BankAccReconciliation, BankAccount."No.", BankAccReconciliation."Statement Type"::"Payment Application");
        OpenPmtReconJnl(BankAccReconciliation, PaymentReconciliationJournal);
        ASSERTERROR PaymentReconciliationJournal.ImportBankTransactions.INVOKE();
        Assert.ExpectedError(BankAccountErr);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestDefaultTransactionImportTimespan();
    var
        BankAccount: Record "Bank Account";
    begin
        // Setup
        Initialize();

        AppendServiceUrl(LoginOKTxt);

        // exercise
        CreateLinkedBankAccount(BankAccount);
        BankAccount.FindFirst();

        // verify
        Assert.AreEqual(7, BankAccount."Transaction Import Timespan", '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler,ConsentConfirmYes')]
    procedure TestServiceSetupFromIsolatedStorage();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
        Username: Text;
        Password: Text;
        ConsumerCredentials: Text;
        ServiceUrl: Text;
    begin
        // Setup
        InitializeEncryptionTest(Username, Password, ConsumerCredentials, ServiceUrl);

        MSYodleeBankServiceSetupPage.OPENEDIT();

        // Exercise
        LibraryVariableStorage.Enqueue(SetupSuccessfulTxt);
        MSYodleeBankServiceSetupPage.TestSetup.INVOKE();

        // Assert
        MSYodleeBankServiceSetup.GET();
        Assert.IsTrue(MSYodleeBankServiceSetup.HasCobrandPassword(MSYodleeBankServiceSetup."Cobrand Password"), 'Cobrand password false');
        Assert.AreEqual(Username, MSYodleeBankServiceSetup.GetCobrandName(MSYodleeBankServiceSetup."Cobrand Name"), 'Cobrand username');
        Assert.AreEqual(
          Password, MSYodleeBankServiceSetup.GetCobrandPassword(MSYodleeBankServiceSetup."Cobrand Password"), 'Cobrand password');
        Assert.AreEqual(ConsumerCredentials, MSYodleeBankServiceSetup."Consumer Name", 'Consumer username');
        Assert.AreEqual(
          ConsumerCredentials, MSYodleeBankServiceSetup.GetPassword(MSYodleeBankServiceSetup."Consumer Password"), 'Consumer password');
        Assert.AreEqual(ServiceUrl, MSYodleeBankServiceSetup."Service URL", 'Service URL');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestServiceSetupFromIsolatedStorageFailsNoEncryption();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        CryptographyManagement: Codeunit "Cryptography Management";
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
        Username: Text;
        Password: Text;
        ConsumerCredentials: Text;
        ServiceUrl: Text;
    begin
        InitializeEncryptionTest(Username, Password, ConsumerCredentials, ServiceUrl);

        // Exercise
        CryptographyManagement.DisableEncryption(TRUE);

        // Test connection should fail as we do not allow use of our cobrand anymore
        MSYodleeBankServiceSetupPage.OPENEDIT();
        ASSERTERROR MSYodleeBankServiceSetupPage.TestSetup.INVOKE();

        // Assert
        Assert.ExpectedError(MissingPasswordTxt);

        MSYodleeBankServiceSetup.GET();
        Assert.IsFalse(MSYodleeBankServiceSetup.HasCobrandPassword(MSYodleeBankServiceSetup."Cobrand Password"), 'Cobrand password true');
        Assert.AreEqual('', MSYodleeBankServiceSetup.GetCobrandName(MSYodleeBankServiceSetup."Cobrand Name"), 'Cobrand username');
        Assert.AreEqual('', MSYodleeBankServiceSetup.GetCobrandPassword(MSYodleeBankServiceSetup."Cobrand Password"), 'Cobrand password');
        Assert.AreEqual(ConsumerCredentials, MSYodleeBankServiceSetup."Consumer Name", 'Consumer username');
        Assert.AreEqual(
          ConsumerCredentials, MSYodleeBankServiceSetup.GetPassword(MSYodleeBankServiceSetup."Consumer Password"), 'Consumer password');
        Assert.AreEqual(ServiceUrl, MSYodleeBankServiceSetup."Service URL", 'Service URL');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestServiceSetupFromIsolatedStorageCustomSetupURL();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
        Username: Text;
        Password: Text;
        ConsumerCredentials: Text;
        ServiceUrl: Text;
    begin
        InitializeEncryptionTest(Username, Password, ConsumerCredentials, ServiceUrl);

        ServiceUrl := TestServiceBaseURLTxt;

        MSYodleeBankServiceSetupPage.OPENEDIT();
        MSYodleeBankServiceSetupPage."Service URL".SetValue(ServiceUrl);
        MSYodleeBankServiceSetupPage.SetDefaults.INVOKE();

        // Exercise
        LibraryVariableStorage.Enqueue(CobrandMustBeSpecifiedTxt);
        MSYodleeBankServiceSetupPage."Service URL".VALUE :=
          COPYSTR(ServiceUrl + LoginOKTxt, 1, MAXSTRLEN(MSYodleeBankServiceSetup."Service URL"));

        ASSERTERROR MSYodleeBankServiceSetupPage.TestSetup.INVOKE();

        // Assert
        Assert.ExpectedError(MissingPasswordTxt);

        Assert.IsFalse(MSYodleeBankServiceSetupPage.DefaultCredentials.ASBOOLEAN(), 'Preconfigured credentials are still in use');

        MSYodleeBankServiceSetup.GET();
        Assert.IsFalse(MSYodleeBankServiceSetup.HasCobrandPassword(MSYodleeBankServiceSetup."Cobrand Password"), 'Cobrand password true');
        Assert.AreEqual('', MSYodleeBankServiceSetup.GetCobrandName(MSYodleeBankServiceSetup."Cobrand Name"), 'Cobrand username');
        Assert.AreEqual('', MSYodleeBankServiceSetup.GetCobrandPassword(MSYodleeBankServiceSetup."Cobrand Password"), 'Cobrand password');
        Assert.AreEqual(ConsumerCredentials, MSYodleeBankServiceSetup."Consumer Name", 'Consumer username');
        Assert.AreEqual(
          ConsumerCredentials, MSYodleeBankServiceSetup.GetPassword(MSYodleeBankServiceSetup."Consumer Password"), 'Consumer password');
        Assert.AreEqual(ServiceUrl + LoginOKTxt, MSYodleeBankServiceSetup."Service URL", 'Service URL');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestBankAccountLinkingActionsVisible();
    var
        BankAccount: Record "Bank Account";
        BankAccountCard: TestPage "Bank Account Card";
        BankAccountList: TestPage "Bank Account List";
    begin
        // Setup
        Initialize();
        LibraryERM.CreateBankAccount(BankAccount);

        // Exercise
        BankAccountCard.OPENVIEW();
        BankAccountCard.GOTORECORD(BankAccount);

        BankAccountList.OPENVIEW();
        BankAccountList.GOTORECORD(BankAccount);

        // Assert
        Assert.IsTrue(BankAccountCard.LinkToOnlineBankAccount.VISIBLE(), 'Card');
        Assert.IsTrue(BankAccountList.LinkToOnlineBankAccount.VISIBLE(), 'List');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,StrMenuHandler,ConsentConfirmYes')]
    procedure TestBankAccountLinkingActionsMultipleProviders();
    var
        BankAccount: Record "Bank Account";
        BankAccLinkingMockEvents: Codeunit "Bank Acc. Linking Mock Events";
        BankAccountCard: TestPage "Bank Account Card";
    begin
        // Setup
        Initialize();
        BINDSUBSCRIPTION(BankAccLinkingMockEvents);

        LibraryERM.CreateBankAccount(BankAccount);
        BankAccountCard.OPENVIEW();
        BankAccountCard.GOTORECORD(BankAccount);

        // Exercise
        EnqueueStrMenuOptionsAndResponse(TestServiceFriendlyNameTxt, YodleeServiceNameTxt, 'Cancel', TestServiceFriendlyNameTxt);
        BankAccountCard.LinkToOnlineBankAccount.INVOKE();

        // Asserts in handlers

        // Cleanup
        UNBINDSUBSCRIPTION(BankAccLinkingMockEvents);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler,ConsentConfirmYes')]
    procedure TestCreateConsumerOnAuthenticate();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
        Username: Text;
        Password: Text;
        ConsumerCredentials: Text;
        ServiceUrl: Text;
    begin
        // Setup
        InitializeEncryptionTest(Username, Password, ConsumerCredentials, ServiceUrl);

        MSYodleeBankServiceSetupPage.OPENEDIT();
        MSYodleeBankServiceSetupPage."Consumer Name".VALUE('');
        MSYodleeBankServiceSetupPage.ConsumerPwd.VALUE('');
        MSYodleeBankServiceSetupPage.Enabled.SETVALUE(TRUE);
        MSYodleeBankServiceSetupPage.CLOSE();

        // Execute
        LibraryVariableStorage.Enqueue(SetupSuccessfulTxt);
        MSYodleeServiceMgt.CheckSetup();

        // Verify
        MSYodleeBankServiceSetup.GET();
        Assert.AreNotEqual('', MSYodleeBankServiceSetup."Consumer Name", 'Name');
        Assert.IsFalse(ISNULLGUID(MSYodleeBankServiceSetup."Consumer Password"), 'Password');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler,ConsentConfirmYes')]
    procedure TestCreateConsumerSuccessWithNoTenantId();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
        Username: Text;
        Password: Text;
        ConsumerCredentials: Text;
        ServiceUrl: Text;
    begin
        // Setup
        InitializeEncryptionTest(Username, Password, ConsumerCredentials, ServiceUrl);

        MSYodleeBankServiceSetupPage.OPENEDIT();
        MSYodleeBankServiceSetupPage."Consumer Name".VALUE('');
        MSYodleeBankServiceSetupPage.ConsumerPwd.VALUE('');
        MSYodleeBankServiceSetupPage.Enabled.SETVALUE(TRUE);
        MSYodleeBankServiceSetupPage.CLOSE();

        // Execute
        LibraryVariableStorage.Enqueue(SetupSuccessfulTxt);
        MSYodleeServiceMgt.CheckSetup();

        // Verify
        MSYodleeBankServiceSetup.GET();
        Assert.AreNotEqual('', MSYodleeBankServiceSetup."Consumer Name", 'Consumer has not been generated');
        Assert.IsTrue(
          MSYodleeBankServiceSetup.HasPassword(MSYodleeBankServiceSetup."Consumer Password"), 'Password has not been generated');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestRemoveConsumerOnDisable();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
        Username: Text;
        Password: Text;
        ConsumerCredentials: Text;
        ServiceUrl: Text;
    begin
        // Setup
        InitializeEncryptionTest(Username, Password, ConsumerCredentials, ServiceUrl);

        MSYodleeBankServiceSetupPage.OPENEDIT();
        MSYodleeBankServiceSetupPage.Enabled.SETVALUE(TRUE);
        MSYodleeBankServiceSetupPage.CLOSE();

        // Execute
        MSYodleeBankServiceSetupPage.OPENEDIT();
        EnqueueConfirmMsgAndResponse(DisableServiceAndRemoveAccTxt, TRUE);
        MSYodleeBankServiceSetupPage.Enabled.SETVALUE(FALSE);

        // Verify
        MSYodleeBankServiceSetup.GET();
        Assert.AreEqual('', MSYodleeBankServiceSetup."Consumer Name", 'Name');
        Assert.IsTrue(ISNULLGUID(MSYodleeBankServiceSetup."Consumer Password"), 'Password');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestPreserveValidConsumerOnDisableWithError();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
        Username: Text;
        Password: Text;
        ConsumerCredentials: Text;
        ServiceUrl: Text;
    begin
        // Setup
        InitializeEncryptionTest(Username, Password, ConsumerCredentials, ServiceUrl);

        MSYodleeBankServiceSetupPage.OPENEDIT();
        MSYodleeBankServiceSetupPage.SetDefaults.INVOKE();
        MSYodleeBankServiceSetupPage.Enabled.SETVALUE(TRUE);
        MSYodleeBankServiceSetupPage.CLOSE();

        // Execute
        MSYodleeBankServiceSetupPage.OPENEDIT();
        EnqueueConfirmMsgAndResponse(DisableServiceAndRemoveAccTxt, TRUE);
        ASSERTERROR MSYodleeBankServiceSetupPage.Enabled.SETVALUE(FALSE);

        // Verify
        MSYodleeBankServiceSetup.GET();
        Assert.AreNotEqual('', MSYodleeBankServiceSetup."Consumer Name", 'Name');
        Assert.IsFalse(ISNULLGUID(MSYodleeBankServiceSetup."Consumer Password"), 'Password');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestRemoveConsumerOnNoLinkedBankAccounts();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        BankAccount1: Record "Bank Account";
        BankAccount2: Record "Bank Account";
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
        Username: Text;
        Password: Text;
        ConsumerCredentials: Text;
        ServiceUrl: Text;
    begin
        // Setup
        InitializeEncryptionTest(Username, Password, ConsumerCredentials, ServiceUrl);

        MSYodleeBankServiceSetupPage.OPENEDIT();
        MSYodleeBankServiceSetupPage.Enabled.SETVALUE(TRUE);
        MSYodleeBankServiceSetupPage.CLOSE();

        // Create link some bank accounts
        CreateLinkedBankAccount(BankAccount1);
        CreateLinkedBankAccount(BankAccount2);

        // Execute - delete a linked bank account
        BankAccount1.DELETE(TRUE);

        // Assert account credentials still present
        MSYodleeBankServiceSetup.GET();
        Assert.AreEqual(ConsumerCredentials, MSYodleeBankServiceSetup."Consumer Name", 'Username removed prematurely');
        Assert.AreEqual(
          ConsumerCredentials, MSYodleeBankServiceSetup.GetPassword(MSYodleeBankServiceSetup."Consumer Password"),
          'Password removed prematurely');

        // Execute - delete last linked bank account
        EnqueueConfirmMsgAndResponse(NoLinkedBankAccountsTxt, TRUE);
        BankAccount2.DELETE(TRUE);

        // Verify - credentials should be removed now
        MSYodleeBankServiceSetup.GET();
        Assert.AreEqual('', MSYodleeBankServiceSetup."Consumer Name", 'Name');
        Assert.IsTrue(ISNULLGUID(MSYodleeBankServiceSetup."Consumer Password"), 'Password');
    end;

    [Test]
    [HandlerFunctions('AcceptTermsOfUseHandler,ConfirmHandler,ConsentConfirmYes')]
    procedure TestTermsOfUseAccepted();
    var
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
    begin
        // Setup
        Initialize();
        MSYodleeBankServiceSetupPage.OPENEDIT();
        MSYodleeBankServiceSetupPage."Accept Terms of Use".SETVALUE(FALSE);

        LibraryVariableStorage.Enqueue('Accept');

        // Execute
        MSYodleeBankServiceSetupPage."Accept Terms of Use".SETVALUE(TRUE);

        // Verify
        Assert.IsTrue(MSYodleeBankServiceSetupPage."Accept Terms of Use".ASBOOLEAN(), 'Terms were not accepted');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('AcceptTermsOfUseHandler,ConfirmHandler,ConsentConfirmYes')]
    procedure TestTermsOfUseRejected();
    var
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
    begin
        // Setup
        Initialize();

        MSYodleeBankServiceSetupPage.OPENEDIT();
        MSYodleeBankServiceSetupPage."Accept Terms of Use".SETVALUE(FALSE);

        LibraryVariableStorage.Enqueue('Reject');

        // Execute
        MSYodleeBankServiceSetupPage."Accept Terms of Use".SETVALUE(TRUE);

        // Verify
        Assert.IsFalse(MSYodleeBankServiceSetupPage."Accept Terms of Use".ASBOOLEAN(), 'Terms were accepted');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('AcceptTermsOfUseHandler,ConfirmHandler,ConsentConfirmYes')]
    procedure TestSetupFailsWithRejectedTermsOfUse();
    var
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
    begin
        // Setup
        Initialize();

        MSYodleeBankServiceSetupPage.OPENEDIT();
        MSYodleeBankServiceSetupPage."Accept Terms of Use".SETVALUE(FALSE);

        LibraryVariableStorage.Enqueue('Reject');

        // Execute
        ASSERTERROR MSYodleeBankServiceSetupPage.TestSetup.INVOKE();

        // Verify
        Assert.ExpectedError(TermsNotAcceptedTxt);
        Assert.IsFalse(MSYodleeBankServiceSetupPage."Accept Terms of Use".ASBOOLEAN(), 'Terms were accepted');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestRegisterConsumerShouldGenerateUserNameIfNotExist();
    var
        MSYodleeBankServiceSetupRec: Record "MS - Yodlee Bank Service Setup";
        MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
        UserName: Text[250];
        Password: Text;
        ErrorText: Text;
    begin
        Initialize();

        MSYodleeBankServiceSetupPage.OPENEDIT();
        MSYodleeBankServiceSetupPage."Consumer Name".VALUE('');
        MSYodleeBankServiceSetupPage.ConsumerPwd.VALUE('');
        MSYodleeBankServiceSetupPage.Enabled.SETVALUE(TRUE);
        MSYodleeBankServiceSetupPage.CLOSE();
        UserName := '';
        Password := '';

        // Execute
        EnqueueConfirmMsgAndResponse(DataEncryptionTxt, FALSE);
        MSYodleeServiceMgt.RegisterConsumer(UserName, Password, ErrorText, '');
        Assert.AreEqual('', ErrorText, ErrorText);

        // Verify
        MSYodleeBankServiceSetupRec.GET();

        Assert.AreNotEqual('', UserName, 'Expected that user name is filled');
        Assert.AreNotEqual('', Password, 'Expected that Password is filled');

        Assert.AreEqual(UserName, MSYodleeBankServiceSetupRec."Consumer Name", 'Expected that Consumer Name is persisted');
        Assert.IsTrue(STRPOS(UserName, COMPANYNAME()) = 0, 'Expected that a new user name is generated and starts with company name');

        Assert.IsFalse(ISNULLGUID(MSYodleeBankServiceSetupRec."Consumer Password"), 'Password');
        Assert.AreEqual(
          Password, MSYodleeBankServiceSetupRec.GetPassword(MSYodleeBankServiceSetupRec."Consumer Password"),
          'Expected that passwords are equal');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ActivityLogHandler,ConsentConfirmYes')]
    procedure TestActivityLogShouldShowRecordsInBasicApplicationArea();
    var
        ApplicationAreaSetupRecord: Record "Application Area Setup";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        MSYodleeBankServiceSetupPage: TestPage "MS - Yodlee Bank Service Setup";
    begin
        LibraryApplicationArea.EnableBasicSetup();

        Initialize();
        MSYodleeBankServiceSetupPage.OPENEDIT();

        // Execute
        MSYodleeBankServiceSetupPage.ActivityLog.INVOKE();

        // Assert
        Assert.IsTrue(ApplicationAreaSetupRecord.GET(COMPANYNAME()), 'Expected that Application Area is set');
        Assert.IsTrue(ApplicationAreaSetupRecord.Basic, 'Expected that Application Area is set to Basic');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler,ConsentConfirmYes')]
    procedure TestDemoCompanyWarnsUserOnAction();
    var
        BankAccountList: TestPage "Bank Account List";
        BankAccountCard: TestPage "Bank Account Card";
    begin
        // Setup
        Initialize();
        SetDemoCompanyState(TRUE);
        BankAccountCard.OPENVIEW();
        BankAccountList.OPENVIEW();

        // Execute
        LibraryVariableStorage.Enqueue(DemoCompanyWithDefaultCredentialMsg);
        BankAccountList.CreateNewLinkedBankAccount.INVOKE();

        LibraryVariableStorage.Enqueue(DemoCompanyWithDefaultCredentialMsg);
        BankAccountList.LinkToOnlineBankAccount.INVOKE();

        LibraryVariableStorage.Enqueue(DemoCompanyWithDefaultCredentialMsg);
        BankAccountList.UpdateBankAccountLinking.INVOKE();

        LibraryVariableStorage.Enqueue(DemoCompanyWithDefaultCredentialMsg);
        BankAccountCard.LinkToOnlineBankAccount.INVOKE();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,ConsentConfirmYes')]
    procedure TestOffThePageSetup();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        BankAccountList: TestPage "Bank Account List";
        Username: Text;
        Password: Text;
        ConsumerCredentials: Text;
        ServiceUrl: Text;
    begin
        // Setup
        InitializeEncryptionTest(Username, Password, ConsumerCredentials, ServiceUrl);
        MSYodleeBankServiceSetup.DELETE();

        // Exercise
        BankAccountList.OPENVIEW();
        EnqueueConfirmMsgAndResponse(EnableYodleeQst, FALSE);
        BankAccountList.CreateNewLinkedBankAccount.INVOKE();

        // Assert
        asserterror MSYodleeBankServiceSetup.GET();
        Assert.ExpectedError('The MS - Yodlee Bank Service Setup does not exist');
    end;

    [Test]
    procedure TestYodleeUserPassword();
    var
        PasswordHelper: Codeunit "Password Helper";
        Password: Text[50];
    begin
        Password := CopyStr(PasswordHelper.GeneratePassword(MaxStrLen(Password)), 1, 50);
        Assert.IsFalse(PasswordHelper.WeakYodleePassword(Password), 'The generated password does not conform with Yodlee standard for a strong password.')
    end;

    local procedure SetupForOnlineImportingOfTransactions(var MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup"; var BankAccount: Record "Bank Account");
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        // set up magic word for the mock service response
        AppendServiceUrl(TestGetTransactionsTxt + DetailsOKTxt + LoginOKTxt);

        // set the online bank account ID from the mock file
        LibraryERM.CreateBankAccount(BankAccount);
        IF GeneralLedgerSetup.GET() THEN
            IF GeneralLedgerSetup."LCY Code" <> 'USD' THEN
                BankAccount."Currency Code" := 'USD';
        BankAccount."Bank Stmt. Service Record ID" := MSYodleeBankServiceSetup.RECORDID();
        BankAccount."Automatic Stmt. Import Enabled" := TRUE;
        BankAccount."Bank Statement Import Format" := 'YODLEEBANKFEED';
        BankAccount.MODIFY();
        MakeMsYodleeBankAccLink(MSYodleeBankAccLink, BankAccount, '10177990', '10177990');
        MSYodleeBankAccLink."Currency Code" := BankAccount."Currency Code";
        MSYodleeBankAccLink."Automatic Logon Possible" := TRUE;
        MSYodleeBankAccLink.MODIFY();
    end;

    local procedure MakeMsYodleeBankAccLink(var MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link"; BankAccount: Record "Bank Account"; OnlineBankID: Text[250]; OnlineBankAccountID: Text[250]);
    begin
        MSYodleeBankAccLink.INIT();
        MSYodleeBankAccLink."No." := BankAccount."No.";
        MSYodleeBankAccLink.VALIDATE("Online Bank Account ID", OnlineBankAccountID);
        MSYodleeBankAccLink.VALIDATE("Online Bank ID", OnlineBankID);
        IF NOT MSYodleeBankAccLink.INSERT() THEN
            MSYodleeBankAccLink.MODIFY();
    end;

    local procedure VerifyPmtReconJnlWithOnlineTransactions(PaymentReconciliationJournal: TestPage "Payment Reconciliation Journal");
    begin
        // verify that the transaction lines from the mock file are imported
        PaymentReconciliationJournal.FIRST();
        Assert.AreEqual(3465, PaymentReconciliationJournal."Statement Amount".ASDECIMAL(), '');
        Assert.AreEqual('DESC1', PaymentReconciliationJournal."Transaction Text".VALUE(), '');
        Assert.AreEqual(DMY2DATE(16, 1, 2013), PaymentReconciliationJournal."Transaction Date".ASDATE(), '');
        PaymentReconciliationJournal.NEXT();
        Assert.AreEqual(-3103, PaymentReconciliationJournal."Statement Amount".ASDECIMAL(), '');
        Assert.AreEqual('DESC2', PaymentReconciliationJournal."Transaction Text".VALUE(), '');
        Assert.AreEqual(DMY2DATE(14, 1, 2013), PaymentReconciliationJournal."Transaction Date".ASDATE(), '');
        PaymentReconciliationJournal.NEXT();
        Assert.AreEqual(5646, PaymentReconciliationJournal."Statement Amount".ASDECIMAL(), '');
        Assert.AreEqual('DESC3', PaymentReconciliationJournal."Transaction Text".VALUE(), '');
        Assert.AreEqual(DMY2DATE(10, 1, 2013), PaymentReconciliationJournal."Transaction Date".ASDATE(), '');
    end;

    local procedure VerifyActivityLogWithOnlineTransactions(var ActivityLog: Record "Activity Log");
    var
        BankFeedInstream: InStream;
        BankFeedDetailedInfo: Text;
        BankFeedTxt: Text;
        BankFeedLine: Text;
    begin
        ActivityLog.SetRange(Description, 'gettransactions');
        ActivityLog.FindFirst();

        ActivityLog.CalcFields("Detailed Info");
        ActivityLog."Detailed Info".CreateInStream(BankFeedInstream);
        BankFeedInstream.ReadText(BankFeedDetailedInfo);
        while not BankFeedInStream.EOS() do begin
            Clear(BankFeedLine);
            BankFeedInstream.ReadText(BankFeedLine);
            BankFeedDetailedInfo += BankFeedLine;
        end;
        BankFeedTxt := ActivityLog."Activity Message";
        ActivityLog.DeleteAll();

        // verify that the transaction lines from the mock file are logged      
        Assert.IsTrue((StrPos(BankFeedDetailedInfo, '3465') > 0) or (StrPos(BankFeedTxt, '3465') > 0), StrSubstNo(TransactionNotLoggedTxt, BankFeedDetailedInfo, BankFeedTxt));
        Assert.IsTrue((StrPos(BankFeedDetailedInfo, 'DESC1') > 0) or (StrPos(BankFeedTxt, 'DESC1') > 0), StrSubstNo(TransactionNotLoggedTxt, BankFeedDetailedInfo, BankFeedTxt));
        Assert.IsTrue((StrPos(BankFeedDetailedInfo, '3103') > 0) or (StrPos(BankFeedTxt, '3103') > 0), StrSubstNo(TransactionNotLoggedTxt, BankFeedDetailedInfo, BankFeedTxt));
        Assert.IsTrue((StrPos(BankFeedDetailedInfo, 'DESC2') > 0) or (StrPos(BankFeedTxt, 'DESC2') > 0), StrSubstNo(TransactionNotLoggedTxt, BankFeedDetailedInfo, BankFeedTxt));
        Assert.IsTrue((StrPos(BankFeedDetailedInfo, '5646') > 0) or (StrPos(BankFeedTxt, '5646') > 0), StrSubstNo(TransactionNotLoggedTxt, BankFeedDetailedInfo, BankFeedTxt));
        Assert.IsTrue((StrPos(BankFeedDetailedInfo, 'DESC3') > 0) or (StrPos(BankFeedTxt, 'DESC3') > 0), StrSubstNo(TransactionNotLoggedTxt, BankFeedDetailedInfo, BankFeedTxt));
    end;

    local procedure CreateLinkedBankAccount(var BankAccount: Record "Bank Account");
    var
        TempMSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link" temporary;
        GeneralLedgerSetup: Record "General Ledger Setup";
        MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
    begin
        GeneralLedgerSetup.GET();
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount."Currency Code" := GeneralLedgerSetup.GetCurrencyCode('USD');
        BankAccount.Modify();
        TempMSYodleeBankAccLink.INIT();
        TempMSYodleeBankAccLink."Currency Code" := 'USD';
        TempMSYodleeBankAccLink.INSERT();

        MSYodleeServiceMgt.MarkBankAccountAsLinked(BankAccount."No.", TempMSYodleeBankAccLink);
    end;

    local procedure UpdateBankAccountLink(var BankAccount: Record "Bank Account");
    var
        BankAccountList: TestPage "Bank Account List";
    begin
        CreateLinkedBankAccount(BankAccount);
        BankAccountList.OPENVIEW();
        BankAccountList.GOTORECORD(BankAccount);
        BankAccountList.UpdateBankAccountLinking.INVOKE();
    end;

    local procedure UpdateBankAccountPromptsMissingLink(var BankAccount: Record "Bank Account");
    var
        BankAccountList: TestPage "Bank Account List";
    begin
        CreateLinkedBankAccount(BankAccount);
        BankAccountList.OPENVIEW();
        BankAccountList.GOTORECORD(BankAccount);
        LibraryVariableStorage.Enqueue(BankAccountList."No.".VALUE());
        LibraryVariableStorage.Enqueue(LinkingInsertedMsg);
        BankAccountList.UpdateBankAccountLinking.INVOKE();
    end;

    local procedure VerifyBankLinkingUpdate();
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        BankAccount.SETFILTER("Bank Stmt. Service Record ID", STRSUBSTNO('<>%1', ''''''));
        Assert.IsTrue(BankAccount.IsEmpty(), 'Linked bank accounts exist');
        Assert.IsTrue(MSYodleeBankAccLink.IsEmpty(), 'Linked Yodlee accounts exist');

        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure VerifyBankAccountPromptsMissingLink();
    var
        BankAccount: Record "Bank Account";
        BankAccountNo: Code[20];
        BankAccountNoVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(BankAccountNoVariant);
        BankAccountNo := BankAccountNoVariant;
        BankAccount.GET(BankAccountNo);
        LibraryVariableStorage.AssertEmpty();
        Assert.AreEqual(TRUE, BankAccount.IsLinkedToBankStatementServiceProvider(), '');
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean);
    var
        ResponseVariant: Variant;
        MsgVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(MsgVariant);
        Assert.IsTrue(STRPOS(Question, MsgVariant) > 0, Question);
        LibraryVariableStorage.Dequeue(ResponseVariant);
        Reply := ResponseVariant;
    end;

    [StrMenuHandler]
    procedure StrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024]);
    var
        SelectedVariant: Variant;
        Option1Variant: Variant;
        Option2Variant: Variant;
        Option3Variant: Variant;
        Pos1: Integer;
        Pos2: Integer;
        Pos3: Integer;
        Pos: Integer;
    begin
        LibraryVariableStorage.Dequeue(Option1Variant);
        LibraryVariableStorage.Dequeue(Option2Variant);
        LibraryVariableStorage.Dequeue(Option3Variant);
        LibraryVariableStorage.Dequeue(SelectedVariant);

        Pos1 := STRPOS(Options, Option1Variant);
        Pos2 := STRPOS(Options, Option2Variant);
        Pos3 := STRPOS(Options, Option3Variant);
        Pos := STRPOS(Options, SelectedVariant);

        Assert.IsTrue(Pos1 > 0, Options);
        Assert.IsTrue(Pos2 > 0, Options);
        Assert.IsTrue(Pos3 > 0, Options);
        Assert.AreEqual(STRLEN(Options), STRLEN(Option1Variant) + STRLEN(Option2Variant) + STRLEN(Option3Variant) + 2, Options);

        CASE Pos OF
            Pos1:
                Choice := 1;
            Pos2:
                Choice := 2;
            ELSE
                Choice := 3;
        END
    end;

    [ModalPageHandler]
    procedure BankLinkingHandler(var MSYodleeNonLinkedAccounts: TestPage 1453);
    var
        BankAccountNoVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(BankAccountNoVariant);

        MSYodleeNonLinkedAccounts.LinkedBankAccount.VALUE := BankAccountNoVariant;
        LibraryVariableStorage.Enqueue(BankAccountNoVariant);
        MSYodleeNonLinkedAccounts.OK().INVOKE();
    end;

    [ModalPageHandler]
    procedure CloseBankLinkingHandler(var MSYodleeNonLinkedAccounts: TestPage 1453);
    begin
        MSYodleeNonLinkedAccounts.OK().INVOKE();
    end;

    [ModalPageHandler]
    procedure BankLinkingActionHandler(var MSYodleeNonLinkedAccounts: TestPage 1453);
    begin
        MSYodleeNonLinkedAccounts.LinkToExistingBankAccount.INVOKE();
        MSYodleeNonLinkedAccounts.OK().INVOKE();
    end;

    [ModalPageHandler]
    procedure BankLinkingActionHandlerStepTwo(var BankAccountList: TestPage "Bank Account List");
    var
        BankAccountNoVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(BankAccountNoVariant);
        BankAccountList.GOTOKEY(BankAccountNoVariant);

        LibraryVariableStorage.Enqueue(BankAccountNoVariant);
        BankAccountList.OK().INVOKE();
    end;

    [ModalPageHandler]
    procedure BankLinkingCreateNewHandler(var MSYodleeNonLinkedAccounts: TestPage 1453);
    var
        TempBankAccount: Record "Bank Account" temporary;
        AnswerVariant: Variant;
        Reselect: Boolean;
    begin
        LibraryVariableStorage.Dequeue(AnswerVariant);
        Reselect := AnswerVariant;

        MSYodleeNonLinkedAccounts.LinkToNewBankAccount.INVOKE();
        IF Reselect THEN BEGIN
            TempBankAccount.GetUnlinkedBankAccounts(TempBankAccount);
            TempBankAccount.FINDFIRST();
            LibraryVariableStorage.Enqueue(TempBankAccount."No.");
            MSYodleeNonLinkedAccounts.LinkedBankAccount.VALUE := TempBankAccount."No.";
        END;

        MSYodleeNonLinkedAccounts.OK().INVOKE();
    end;

    [ModalPageHandler]
    procedure BankLinkingUnlinkHandler(var MSYodleeNonLinkedAccounts: TestPage 1453);
    var
        "Action": Text;
        LinkedBankAccountNo: Text;
    begin
        Action := LibraryVariableStorage.DequeueText();
        MSYodleeNonLinkedAccounts.FIRST();

        CASE Action OF
            'Link': // link to existing account
                BEGIN
                    MSYodleeNonLinkedAccounts.LinkToExistingBankAccount.INVOKE();
                    LinkedBankAccountNo := LibraryVariableStorage.DequeueText();
                    Assert.AreNotEqual('', LinkedBankAccountNo, 'Linked bank account no was empty');
                END;
            'Create': // link to new account
                BEGIN
                    MSYodleeNonLinkedAccounts.LinkToNewBankAccount.INVOKE();
                    LinkedBankAccountNo := LibraryVariableStorage.DequeueText();
                    Assert.AreNotEqual('', LinkedBankAccountNo, 'Linked bank account no was empty');
                END;
        END;

        // unlink account
        LibraryVariableStorage.Enqueue(NoMoreAccountsMsg);
        MSYodleeNonLinkedAccounts.UnlinkOnlineBankAccount.INVOKE();
    end;

    [ModalPageHandler]
    procedure AcceptTermsOfUseHandler(var MSYodleeTermsOfUsePage: TestPage 1454);
    var
        Response: Text;
    begin
        Response := LibraryVariableStorage.DequeueText();

        IF Response = 'Accept' THEN
            MSYodleeTermsOfUsePage."Accept Terms of Use".SETVALUE(TRUE)
        ELSE
            MSYodleeTermsOfUsePage."Accept Terms of Use".SETVALUE(FALSE);

        MSYodleeTermsOfUsePage.OK().INVOKE();
    end;

    [ModalPageHandler]
    procedure BankAccountCardHandler(var BankAccountCard: TestPage "Bank Account Card");
    begin
        LibraryVariableStorage.Enqueue(BankAccountCard."No.".VALUE());
        BankAccountCard.OK().INVOKE();
    end;

    [ModalPageHandler]
    procedure FastlinkHandler(var MSYodleeAccountLinking: TestPage 1451);
    begin
        MSYodleeAccountLinking.OK().INVOKE();
    end;

    local procedure EnqueueConfirmMsgAndResponse(Msg: Text; Response: Boolean);
    begin
        LibraryVariableStorage.Enqueue(Msg);
        LibraryVariableStorage.Enqueue(Response);
    end;

    local procedure EnqueueStrMenuOptionsAndResponse(Option1: Text; Option2: Text; Option3: Text; SelectedOption: Text);
    begin
        LibraryVariableStorage.Enqueue(Option1);
        LibraryVariableStorage.Enqueue(Option2);
        LibraryVariableStorage.Enqueue(Option3);
        LibraryVariableStorage.Enqueue(SelectedOption);
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024]);
    var
        MsgVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(MsgVariant);
        Assert.IsTrue(STRPOS(Message, MsgVariant) > 0, Message);
    end;

    local procedure ConfigureVATPostingSetup();
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SETRANGE("Tax Category", '');
        VATPostingSetup.MODIFYALL("Tax Category", 'AA');
    end;

    local procedure ConvertJsonToXml(JsonInput: Text; var XMLRootNode: XmlNode);
    var
        TempBlob: Codeunit "Temp Blob";
        GetJsonStructure: Codeunit "Get Json Structure";
        InStream: InStream;
        OutStream: OutStream;
        XmlDoc: XmlDocument;
        RootElement: XmlElement;
    begin
        TempBlob.CreateOutStream(OutStream);
        OutStream.WRITETEXT(JsonInput);

        TempBlob.CreateInStream(InStream);
        TempBlob.CreateOutStream(OutStream);

        GetJsonStructure.JsonToXMLCreateDefaultRoot(InStream, OutStream);

        TempBlob.CreateInStream(InStream);
        XmlDocument.ReadFrom(InStream, XmlDoc);
        XmlDoc.GetRoot(RootElement);
        XMLRootNode := RootElement.AsXmlNode();
    end;

    local procedure OpenPmtReconJnl(BankAccReconciliation: Record "Bank Acc. Reconciliation"; var PaymentReconciliationJournal: TestPage "Payment Reconciliation Journal");
    var
        PmtReconciliationJournals: TestPage "Pmt. Reconciliation Journals";
    begin
        PmtReconciliationJournals.OPENVIEW();
        PmtReconciliationJournals.GOTORECORD(BankAccReconciliation);
        PaymentReconciliationJournal.TRAP();
        PmtReconciliationJournals.EditJournal.INVOKE();
    end;

    [ModalPageHandler]
    procedure BankStatementFilterHandler(var BankStatementFilter: TestPage 1298);
    begin
        BankStatementFilter.FromDate.SETVALUE(FORMAT(DMY2DATE(1, 1, 2015)));
        BankStatementFilter.ToDate.SETVALUE(FORMAT(DMY2DATE(10, 10, 2015)));
        BankStatementFilter.OK().INVOKE();
    end;

    [ModalPageHandler]
    procedure BankAccountRefreshMFAHandler(var MSYodleeGetLatestStmt: TestPage 1452);
    begin
        MSYodleeGetLatestStmt.OK().INVOKE();
    end;

    [ModalPageHandler]
    procedure PaymentBankAccountListHandler(var PaymentBankAccountList: TestPage 1282);
    var
        BankAccountNoVariant: Variant;
        BankAccountNo: Code[20];
    begin
        LibraryVariableStorage.Dequeue(BankAccountNoVariant);
        BankAccountNo := BankAccountNoVariant;
        PaymentBankAccountList.FINDFIRSTFIELD("No.", BankAccountNo);
        PaymentBankAccountList.OK().INVOKE();
    end;

    [ModalPageHandler]
    procedure ActivityLogHandler(var ActivityLog: TestPage 710);
    begin
        Assert.IsTrue(ActivityLog."Activity Date".VISIBLE(), 'Expected that Activity Date is visible');
        Assert.IsTrue(ActivityLog."Activity Message".VISIBLE(), 'Expected that Activity Message is visible');
        Assert.IsTrue(ActivityLog.Description.VISIBLE(), 'Expected that Description is visible');
        Assert.IsTrue(ActivityLog."User ID".VISIBLE(), 'Expected that User ID is visible');
        Assert.IsTrue(ActivityLog.Context.VISIBLE(), 'Expected that Context is visible');
        Assert.IsTrue(ActivityLog.Status.VISIBLE(), 'Expected that Status is visible');
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ConsentConfirmYes(var CustConsentConfirmation: TestPage "Cust. Consent Confirmation")
    begin
        CustConsentConfirmation.Accept.Invoke();
    end;

    local procedure DoNotEnableJobQueue();
    begin
        IF BINDSUBSCRIPTION(LibraryJobQueue) THEN;
    end;

    local procedure SetDemoCompanyState(IsDemoCompany: Boolean);
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.GET();
        CompanyInformation."Demo Company" := IsDemoCompany;
        CompanyInformation.MODIFY();
    end;

    local procedure AppendServiceUrl(Path: Text);
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        MSYodleeBankServiceSetup.GET();
        MSYodleeBankServiceSetup."Service URL" :=
          COPYSTR(MSYodleeBankServiceSetup."Service URL" + Path, 1, MAXSTRLEN(MSYodleeBankServiceSetup."Service URL"));
        MSYodleeBankServiceSetup.MODIFY();
    end;
}

