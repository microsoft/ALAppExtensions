codeunit 139580 "MS - Wallet Tests"
{
    // version Test,W1,AT,AU,BE,CA,CH,DE,DK,ES,FI,FR,GB,IS,IT,MX,NL,NO,NZ,SE,US

    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit 130000;
        LibraryUtility: Codeunit 131000;
        LibraryVariableStorage: Codeunit 131004;
        LibrarySales: Codeunit 130509;
        LibraryInventory: Codeunit 132201;
        LibraryERM: Codeunit 131300;
        LibraryRandom: Codeunit 130440;
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        MSWalletMockEvents: Codeunit 139583;
        DatasetFileName: Text;
        Initialized: Boolean;
        UpdateOpenInvoicesManuallyTxt: Label 'A link for the Microsoft Pay Payments payment service will be included on new sales documents. To add it to existing sales documents, you must manually select it in the Payment Service field on the sales document.';
        ServiceNotSetupErr: Label 'You must set up your merchant account before enabling this payment service.';
        MSWalletNameTxt: Label 'Microsoft Pay Payments';
        MSWalletDescriptionTxt: Label 'Microsoft Pay Payments - Enables credit cards and PayPal payments';
        NewPaymentRequestURLTxt: Label 'https://localhost:8080/MSWallet', Locked = true;
        WalletMerchantAccountPrefixTxt: Label 'Microsoft Pay Payments';
        MSWalletTargetUrlTxt: Label 'https://localhost:8080/preview/?requestId=test', Locked = true;
        MSWalletTargetUrlStartTxt: Label 'https://secure-test.worldpay.com/wcc/purchase?testMode=100', Locked = true;
        WalletCreatedByTok: Label 'https://PAY.MICROSOFT.COM', Locked = true;
        NotifyUrlErr: Label 'Could not find target URL.';
        IncorrectRemainingAmountErr: Label 'Incorrect remaining amount.';
        IncorrectPaymentStatusErr: Label 'Incorrect payment status.';
        IncorrectPaymentDetailsErr: Label 'Incorrect payment details.';
        PaymentTok: Label 'payment', Locked = true;
        NotificationTemplateTxt: Label '{"id":null,"paymentRequest":{"id":null,"methodData":[{"supportedMethods":["https://pay.microsoft.com/microsoftpay"],"data":{"merchantId":"%1","supportedNetworks":["visa","mastercard"],"supportedTypes":["credit"]}}],"details":{"total":{"label":"%2","amount":{"currency":"%3","value":"%4","currencySystem":"urn:iso:std:iso:4217"}},"displayItems": null,"shippingOptions":null},"options": null},"paymentResponse":{"methodName":"https://pay.microsoft.com/microsoftpay","details":{"paymentToken":"TESTTOKEN"}}}', Locked = true;
        MSWalletSingeltonErr: Label 'You can only have one Microsoft Pay Payments setup. To add more payment accounts to your merchant profile, edit the existing Microsoft Pay Payments setup.';
        CannotMakePaymentWarningTxt: Label 'You may not be able to accept payments throught Microsoft Pay Payments. The user that was used to set up Microsoft Pay Payments has been deleted or disabled.';
        ExchangeWithExternalServicesMsg: Label 'This extension uses the Microsoft Pay Payments service.';

        DeprecationOfMsPayMsg: Label 'Effective the 8th';

    local procedure Initialize();
    var
        CompanyInfo: Record 79;
        MSWalletMerchantAccount: Record 1080;
        MSWalletPayment: Record 1085;
        MSWalletCharge: Record 1086;
        DummySalesHeader: Record 36;
        DummyPaymentMethod: Record 289;
        WebhookSubscription: Record 2000000199;
        WebhookNotification: Record 2000000194;
        // TODO: Remove
        //User: Record 2000000120;
        LibraryAzureKVMockMgmt: Codeunit 131021;
    begin
        CompanyInfo.GET();
        CompanyInfo."Allow Blank Payment Info." := TRUE;
        CompanyInfo.MODIFY();
        LibraryVariableStorage.AssertEmpty();

        LibraryAzureKVMockMgmt.InitMockAzureKeyvaultSecretProvider();
        LibraryAzureKVMockMgmt.AddMockAzureKeyvaultSecretProviderMapping('AllowedApplicationSecrets', 'walletpaymentrequesturl,MSWalletAADAppID,MSWalletAADAppKey,MSWalletAADIdentityService' +
          ',MSWalletSignUpUrl,MSWalletMerchantAPI,MSWalletMerchantAPIResource,SmtpSetup');
        LibraryAzureKVMockMgmt.AddMockAzureKeyvaultSecretProviderMapping('walletpaymentrequesturl', WalletCreatedByTok);
        LibraryAzureKVMockMgmt.AddMockAzureKeyvaultSecretProviderMapping('MSWalletAADAppID', '15449ffa-556b-40a6-b60e-739eb8224baf');
        LibraryAzureKVMockMgmt.AddMockAzureKeyvaultSecretProviderMapping('MSWalletAADAppKey', 'iucODGPOViXfKT32XASn0vq36M8sGW9V0GI2uZii+SI=');
        LibraryAzureKVMockMgmt.AddMockAzureKeyvaultSecretProviderMapping('MSWalletAADIdentityService', 'https://login.microsoftonline.com/microsoft.com');
        LibraryAzureKVMockMgmt.AddMockAzureKeyvaultSecretProviderMapping('MSWalletSignUpUrl', 'https://manage.pay.microsoft-ppe.com/mmx');
        LibraryAzureKVMockMgmt.AddMockAzureKeyvaultSecretProviderMapping('MSWalletMerchantAPI', NewPaymentRequestURLTxt + '/merchantId');
        LibraryAzureKVMockMgmt.UseAzureKeyvaultSecretProvider();

        MSWalletPayment.DELETEALL();
        MSWalletCharge.DELETEALL();
        MSWalletMerchantAccount.DELETEALL();
        WebhookSubscription.DELETEALL();
        WebhookNotification.DELETEALL();
        // TODO: Remove
        //User.DeleteAll();
        CreateDefaultTemplate();

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(FALSE);

        IF Initialized THEN
            EXIT;

        CreateSalesInvoice(DummySalesHeader, DummyPaymentMethod);
        SetupReportSelections();
        COMMIT();

        BINDSUBSCRIPTION(MSWalletMockEvents);

        Initialized := TRUE;
    end;

    [Test]
    [HandlerFunctions('AccountSetupPageModalPageHandler,ConfirmHandler,SelectPaymentServiceTypeHandler')]
    procedure TestCreateNewPaymentService();
    var
        ExpectedPaymentServiceSetup: Record 1060;
        PaymentServices: TestPage 1060;
        ChangeValuesOnSetupPage: Boolean;
        Enabled: Boolean;
        AlwaysInclude: Boolean;
        EnableServiceWhenClosingCard: Boolean;
    begin
        // Setup
        Initialize();

        // Execute
        PaymentServices.OPENEDIT();

        ChangeValuesOnSetupPage := FALSE;
        Enabled := FALSE;
        AlwaysInclude := FALSE;
        EnableServiceWhenClosingCard := FALSE;
        LibraryVariableStorage.Enqueue(MSWalletNameTxt);
        SetParametersToUpdateSetupPage(ChangeValuesOnSetupPage, '', '', Enabled, AlwaysInclude, '');
        LibraryVariableStorage.Enqueue(EnableServiceWhenClosingCard);

        PaymentServices.NewAction.INVOKE();

        // Verify
        ExpectedPaymentServiceSetup.INIT();
        ExpectedPaymentServiceSetup.Name := MSWalletNameTxt;
        ExpectedPaymentServiceSetup.Description := MSWalletDescriptionTxt;
        ExpectedPaymentServiceSetup.Enabled := Enabled;
        ExpectedPaymentServiceSetup."Always Include on Documents" := AlwaysInclude;

        VerifyPaymentServicePage(PaymentServices, ExpectedPaymentServiceSetup);
    end;

    [Test]
    procedure TestExistingPaymentServicesAreShownInTheList();
    var
        MSWalletMerchantAccount: Record 1080;
        ExpectedPaymentServiceSetup: Record 1060;
        PaymentServices: TestPage 1060;
    begin
        // Setup
        Initialize();
        CreateWalletMerchantAccount(MSWalletMerchantAccount);

        // Execute
        PaymentServices.OPENEDIT();

        // Verify
        ExpectedPaymentServiceSetup.INIT();
        ExpectedPaymentServiceSetup.Name := MSWalletMerchantAccount.Name;
        ExpectedPaymentServiceSetup.Description := MSWalletMerchantAccount.Description;
        ExpectedPaymentServiceSetup.Enabled := FALSE;
        ExpectedPaymentServiceSetup."Always Include on Documents" := FALSE;

        VerifyPaymentServicePage(PaymentServices, ExpectedPaymentServiceSetup);
    end;

    [Test]
    [HandlerFunctions('AccountSetupPageModalPageHandler,MessageHandler')]
    procedure TestSetupPaymentService();
    var
        MSWalletMerchantAccount: Record 1080;
        ExpectedMSWalletMerchantAccount: Record 1080;
        PaymentServices: TestPage 1060;
        ChangeValuesOnSetupPage: Boolean;
    begin
        // Setup
        Initialize();
        CreateWalletMerchantAccount(MSWalletMerchantAccount);

        // Execute
        PaymentServices.OPENEDIT();
        PaymentServices.FILTER.SETFILTER(Name, WalletMerchantAccountPrefixTxt + '*');
        ChangeValuesOnSetupPage := TRUE;
        ExpectedMSWalletMerchantAccount.COPY(MSWalletMerchantAccount);
        ExpectedMSWalletMerchantAccount.Enabled := TRUE;
        ExpectedMSWalletMerchantAccount."Always Include on Documents" := TRUE;
        ExpectedMSWalletMerchantAccount.Name := COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(20, 0),
            1, MAXSTRLEN(ExpectedMSWalletMerchantAccount.Name));
        ExpectedMSWalletMerchantAccount.Description :=
          COPYSTR(LibraryUtility.GenerateRandomText(MAXSTRLEN(MSWalletMerchantAccount.Description)),
            1, MAXSTRLEN(ExpectedMSWalletMerchantAccount.Name));
        ExpectedMSWalletMerchantAccount.Validate("Merchant ID", COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(20, 0),
            1, MAXSTRLEN(ExpectedMSWalletMerchantAccount."Merchant ID")));
        ExpectedMSWalletMerchantAccount.SetPaymentRequestURL(NewPaymentRequestURLTxt);

        SetParametersToUpdateSetupPage(ChangeValuesOnSetupPage, ExpectedMSWalletMerchantAccount.Name,
          ExpectedMSWalletMerchantAccount.Description, ExpectedMSWalletMerchantAccount.Enabled,
          ExpectedMSWalletMerchantAccount."Always Include on Documents", ExpectedMSWalletMerchantAccount."Merchant ID");
        PaymentServices.Setup.INVOKE();

        // Verify
        MSWalletMerchantAccount.GET(MSWalletMerchantAccount."Primary Key");
        VerifyWalletMerchantAccountRecord(MSWalletMerchantAccount, ExpectedMSWalletMerchantAccount);
    end;

    [Test]
    [HandlerFunctions('AccountSetupPageModalPageHandler,ConfirmHandler')]
    procedure TestEnablingWhenClosingSetupPage();
    var
        MSWalletMerchantAccount: Record 1080;
        ExpectedMSWalletMerchantAccount: Record 1080;
        PaymentServices: TestPage 1060;
        ChangeValuesOnSetupPage: Boolean;
        EnableServiceWhenClosingCard: Boolean;
    begin
        // Setup
        Initialize();
        CreateWalletMerchantAccount(MSWalletMerchantAccount);

        // Execute
        PaymentServices.OPENEDIT();
        PaymentServices.FILTER.SETFILTER(Name, WalletMerchantAccountPrefixTxt + '*');
        ChangeValuesOnSetupPage := TRUE;
        EnableServiceWhenClosingCard := TRUE;

        ExpectedMSWalletMerchantAccount.INIT();
        ExpectedMSWalletMerchantAccount.COPY(MSWalletMerchantAccount);
        ExpectedMSWalletMerchantAccount.Enabled := FALSE;
        ExpectedMSWalletMerchantAccount.Validate("Merchant ID", COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(20, 0),
            1, MAXSTRLEN(ExpectedMSWalletMerchantAccount."Merchant ID")));

        SetParametersToUpdateSetupPage(ChangeValuesOnSetupPage, ExpectedMSWalletMerchantAccount.Name,
          ExpectedMSWalletMerchantAccount.Description, ExpectedMSWalletMerchantAccount.Enabled,
          ExpectedMSWalletMerchantAccount."Always Include on Documents", ExpectedMSWalletMerchantAccount."Merchant ID");

        LibraryVariableStorage.Enqueue(EnableServiceWhenClosingCard);

        PaymentServices.Setup.INVOKE();

        // Verify
        ExpectedMSWalletMerchantAccount.Enabled := FALSE;
        MSWalletMerchantAccount.GET(MSWalletMerchantAccount."Primary Key");
        VerifyWalletMerchantAccountRecord(MSWalletMerchantAccount, ExpectedMSWalletMerchantAccount);
    end;

    [Test]
    procedure TestCannotEnableWithoutAccountID();
    var
        MSWalletMerchantAccount: Record 1080;
    begin
        // Setup
        Initialize();
        CreateWalletMerchantAccount(MSWalletMerchantAccount);
        MSWalletMerchantAccount."Merchant ID" := '';

        // Verify
        ASSERTERROR MSWalletMerchantAccount.VALIDATE(Enabled, TRUE);
        Assert.ExpectedError(ServiceNotSetupErr);
    end;

    [Test]
    procedure TestCannotBlankAccountIDWhenEnabled();
    var
        MSWalletMerchantAccount: Record 1080;
    begin
        // Setup
        Initialize();
        CreateWalletMerchantAccount(MSWalletMerchantAccount);
        EnableWalletMerchantAccount(MSWalletMerchantAccount);

        // Verify
        ASSERTERROR MSWalletMerchantAccount.VALIDATE("Merchant ID", '');
        Assert.ExpectedError(ServiceNotSetupErr);
    end;

    [Test]
    procedure TestServiceConnectionListShowsDisabledPaymentServices();
    var
        MSWalletMerchantAccount: Record 1080;
        ServiceConnections: TestPage 1279;
    begin
        Initialize();

        // Setup
        CreateWalletMerchantAccount(MSWalletMerchantAccount);

        // Execute
        ServiceConnections.OPENEDIT();

        // Verify
        VerifyPaymentServiceIsShownOnServiceConnectionsPage(ServiceConnections, MSWalletMerchantAccount);
    end;

    [Test]
    procedure TestServiceConnectionListShowsEnabledPaymentServices();
    var
        MSWalletMerchantAccount: Record 1080;
        ServiceConnections: TestPage 1279;
    begin
        Initialize();

        // Setup
        CreateWalletMerchantAccount(MSWalletMerchantAccount);
        EnableWalletMerchantAccount(MSWalletMerchantAccount);

        // Execute
        ServiceConnections.OPENEDIT();

        // Verify
        VerifyPaymentServiceIsShownOnServiceConnectionsPage(ServiceConnections, MSWalletMerchantAccount);
    end;

    [Test]
    [HandlerFunctions('AccountSetupPageModalPageHandler,MessageHandler')]
    procedure TestServiceConnectionListOpensPaymentServicesSetupCard();
    var
        MSWalletMerchantAccount: Record 1080;
        ServiceConnections: TestPage 1279;
    begin
        Initialize();

        // Setup
        CreateWalletMerchantAccount(MSWalletMerchantAccount);
        ServiceConnections.OPENEDIT();
        ServiceConnections.FILTER.SETFILTER(Name, MSWalletMerchantAccount.Description);
        SetParametersToUpdateSetupPage(
          TRUE, MSWalletMerchantAccount.Name, MSWalletMerchantAccount.Description, TRUE, TRUE, MSWalletMerchantAccount."Merchant ID");

        // Execute
        ServiceConnections.Setup.INVOKE();

        // Verify
        MSWalletMerchantAccount.Enabled := TRUE;
        MSWalletMerchantAccount."Always Include on Documents" := TRUE;
        VerifyPaymentServiceIsShownOnServiceConnectionsPage(ServiceConnections, MSWalletMerchantAccount);
    end;

    [Test]
    [HandlerFunctions('SelectPaymentServiceModalPageHandler')]
    procedure TestSelectingMSWalletService();
    var
        MSWalletMerchantAccount: Record 1080;
        SalesHeader: Record 36;
        DummyPaymentMethod: Record 289;
        SalesInvoice: TestPage 43;
        NewAvailable: Boolean;
    begin
        // Setup
        Initialize();
        CreateWalletMerchantAccount(MSWalletMerchantAccount);
        EnableWalletMerchantAccount(MSWalletMerchantAccount);

        CreateSalesInvoice(SalesHeader, DummyPaymentMethod);

        // Execute
        SalesInvoice.OPENEDIT();
        SalesInvoice.GOTORECORD(SalesHeader);

        NewAvailable := TRUE;
        SetParametersToSelectPaymentService(
          FALSE, MSWalletMerchantAccount.Name, MSWalletMerchantAccount."Always Include on Documents", NewAvailable);
        SalesInvoice.SelectedPayments.ASSISTEDIT();

        // Verify
        Assert.IsTrue(SalesInvoice.SelectedPayments.Value().Contains(MSWalletMerchantAccount.Name), 'Wrong value was set');
    end;

    [Test]
    procedure TestOnlyOneMSWalletService();
    var
        MSWalletMerchantAccount1: Record 1080;
        MSWalletMerchantAccount2: Record 1080;
    begin
        // Setup
        Initialize();
        CreateWalletMerchantAccount(MSWalletMerchantAccount1);
        EnableWalletMerchantAccount(MSWalletMerchantAccount1);

        ASSERTERROR CreateWalletMerchantAccount(MSWalletMerchantAccount2);
        Assert.ExpectedError(MSWalletSingeltonErr);
    end;

    [Test]
    procedure TestMSWalletAccountInTestModeForDemoCompany();
    var
        MSWalletMerchantAccount: Record 1080;
    begin
        // Setup
        Initialize();
        CreateWalletMerchantAccount(MSWalletMerchantAccount);

        Assert.IsTrue(MSWalletMerchantAccount."Test Mode", 'Merchant Account should be in test mode for demo company');
    end;

    [Test]
    procedure TestMSWalletAccountInLiveModeForNonDemoCompany();
    var
        MSWalletMerchantAccount: Record 1080;
        CompanyInformation: Record 79;
    begin
        // Setup
        Initialize();

        CompanyInformation.GET();
        CompanyInformation."Demo Company" := FALSE;
        CompanyInformation.MODIFY();

        CreateWalletMerchantAccount(MSWalletMerchantAccount);

        Assert.IsFalse(MSWalletMerchantAccount."Test Mode", 'Merchant Account should be in live mode for non demo company');
    end;

    [Test]
    [HandlerFunctions('SalesInvoiceReportRequestPageHandler,MessageHandler')]
    procedure TestSalesInvoiceReportSingleInvoice();
    var
        TempPaymentServiceSetup: Record 1060 temporary;
        MSWalletMerchantAccount: Record 1080;
        DummyPaymentMethod: Record 289;
        SalesInvoiceHeader: Record 112;
        TempPaymentReportingArgument: Record 1062 temporary;
    begin
        Initialize();

        // Setup
        CreateDefaultWalletMerchantAccount(MSWalletMerchantAccount);
        MSWalletMerchantAccount.SetPaymentRequestURL(NewPaymentRequestURLTxt + '/payment_request');
        CreatePaymentMethod(DummyPaymentMethod, FALSE);
        CreateAndPostSalesInvoice(SalesInvoiceHeader, DummyPaymentMethod, true);
        CreateMSPaymentLink(SalesInvoiceHeader);

        TempPaymentServiceSetup.CreateReportingArgs(TempPaymentReportingArgument, SalesInvoiceHeader);

        // Exercise
        SalesInvoiceHeader.SETRECFILTER();
        COMMIT();
        REPORT.RUN(REPORT::"Sales - Invoice", TRUE, FALSE, SalesInvoiceHeader);

        // Verify
        VerifyPaymentServiceIsInReportDataset(TempPaymentReportingArgument);
        VerifyWalletURL(TempPaymentReportingArgument);
    end;

    [Test]
    [HandlerFunctions('EMailDialogHandler,MessageHandler')]
    procedure TestCoverLetterPaymentLink();
    var
        TempPaymentServiceSetup: Record 1060 temporary;
        MSWalletMerchantAccount: Record 1080;
        DummyPaymentMethod: Record 289;
        SalesInvoiceHeader: Record 112;
        TempPaymentReportingArgument: Record 1062 temporary;
        LibraryInvoicingApp: Codeunit "Library - Invoicing App";
        PostedSalesInvoice: TestPage 132;
        BodyHTMLText: Text;
    begin
        Initialize();

        // Setup
        CreateDefaultWalletMerchantAccount(MSWalletMerchantAccount);
        MSWalletMerchantAccount.SetPaymentRequestURL(NewPaymentRequestURLTxt + '/payment_request');
        CreatePaymentMethod(DummyPaymentMethod, FALSE);
        CreateAndPostSalesInvoice(SalesInvoiceHeader, DummyPaymentMethod, true);
        CreateMSPaymentLink(SalesInvoiceHeader);

        TempPaymentServiceSetup.CreateReportingArgs(TempPaymentReportingArgument, SalesInvoiceHeader);

        PostedSalesInvoice.OPENEDIT();
        PostedSalesInvoice.GOTORECORD(SalesInvoiceHeader);
        LibraryInvoicingApp.SetupEmailTable();

        // Exercise
        PostedSalesInvoice.Email.INVOKE();

        // Verify
        TempPaymentReportingArgument.FINDFIRST();

        BodyHTMLText := LibraryVariableStorage.DequeueText();
        Assert.IsTrue(STRPOS(BodyHTMLText, MSWalletTargetUrlTxt) > 0, 'Target URL was not set correctly');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestSalesInvoiceReportErrorCreatingWalletLink();
    var
        TempPaymentServiceSetup: Record 1060 temporary;
        MSWalletMerchantAccount: Record 1080;
        DummyPaymentMethod: Record 289;
        SalesInvoiceHeader: Record 112;
        TempPaymentReportingArgument: Record 1062 temporary;
    begin
        Initialize();

        // Setup
        CreateDefaultWalletMerchantAccount(MSWalletMerchantAccount);
        MSWalletMerchantAccount.SetPaymentRequestURL(NewPaymentRequestURLTxt + '/status500');
        CreatePaymentMethod(DummyPaymentMethod, FALSE);
        CreateAndPostSalesInvoice(SalesInvoiceHeader, DummyPaymentMethod, true);

        // Verify
        ASSERTERROR TempPaymentServiceSetup.CreateReportingArgs(TempPaymentReportingArgument, SalesInvoiceHeader);
    end;

    [Test]
    [HandlerFunctions('AccountSetupPageModalPageHandler,ConfirmHandler,SelectPaymentServiceTypeHandler')]
    procedure TestTermsOfService();
    var
        MSWalletMerchantTemplate: Record 1081;
        PaymentServices: TestPage 1060;
        EnableServiceWhenClosingCard: Boolean;
    begin
        // Setup
        Initialize();

        // Execute
        PaymentServices.OPENEDIT();
        LibraryVariableStorage.Enqueue(MSWalletNameTxt);
        SetParametersToUpdateSetupPage(FALSE, '', '', FALSE, FALSE, '');
        EnableServiceWhenClosingCard := FALSE;
        LibraryVariableStorage.Enqueue(EnableServiceWhenClosingCard);

        PaymentServices.NewAction.INVOKE();
        PaymentServices.FILTER.SETFILTER(Name, WalletMerchantAccountPrefixTxt + '*');

        // Verify
        MSWalletMerchantTemplate.FINDFIRST();
        Assert.AreNotEqual('', MSWalletMerchantTemplate."Terms of Service", 'Terms of service are not set on the template');
        Assert.AreEqual(
          MSWalletMerchantTemplate."Terms of Service", PaymentServices."Terms of Service".VALUE(),
          'Terms of service are not set on the page');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestWebhookIsCreatedWhenSettingupAccount();
    var
        MSWalletMerchantAccount: Record 1080;
        WebhookSubscription: Record 2000000199;
        MSWalletWebhookManagement: Codeunit 1083;
        MSWalletMerchantSetup: TestPage 1080;
        SubscriptionID: Text[250];
    begin
        Initialize();
        CreateWalletMerchantAccount(MSWalletMerchantAccount);

        MSWalletMerchantSetup.OPENEDIT();
        LibraryVariableStorage.Enqueue(DeprecationOfMsPayMsg);
        LibraryVariableStorage.Enqueue(ExchangeWithExternalServicesMsg);
        MSWalletMerchantSetup.Enabled.SETVALUE(TRUE);
        MSWalletMerchantSetup.CLOSE();

        SubscriptionID := MSWalletWebhookManagement.GetWebhookSubscriptionID(MSWalletMerchantAccount."Merchant ID");
        WebhookSubscription.SETRANGE("Subscription ID", SubscriptionID);
        WebhookSubscription.SETFILTER("Created By", STRSUBSTNO('*%1*', WalletCreatedByTok));

        Assert.IsTrue(
          WebhookSubscription.FINDFIRST(),
          STRSUBSTNO('Error Expecting Webhook to be created for Merchant %1', SubscriptionID));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestWebhookIsUpdatedAfterModifyingAccount();
    var
        MSWalletMerchantAccount: Record 1080;
        WebhookSubscription: Record 2000000199;
        MSWalletWebhookManagement: Codeunit 1083;
        MSWalletMerchantSetup: TestPage 1080;
        SubscriptionID: Text[250];
        newAcountId: Text[250];
    begin
        Initialize();
        CreateWalletMerchantAccount(MSWalletMerchantAccount);

        newAcountId := 'MSWallet1';
        SubscriptionID := MSWalletWebhookManagement.GetWebhookSubscriptionID(newAcountId);

        MSWalletMerchantSetup.OPENEDIT();
        MSWalletMerchantSetup."Merchant ID".SETVALUE(newAcountId);
        LibraryVariableStorage.Enqueue(DeprecationOfMsPayMsg);
        LibraryVariableStorage.Enqueue(ExchangeWithExternalServicesMsg);
        MSWalletMerchantSetup.Enabled.SETVALUE(TRUE);
        MSWalletMerchantSetup.CLOSE();

        WebhookSubscription.SETRANGE("Subscription ID", SubscriptionID);
        WebhookSubscription.SETFILTER("Created By", STRSUBSTNO('*%1*', WalletCreatedByTok));

        Assert.IsTrue(
          WebhookSubscription.FINDFIRST(),
          STRSUBSTNO('Error Expecting Webhook to be updated to have one for Merchant %1', SubscriptionID));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure TestWebhookIsDeletedAfterModifyingAccountToEmpty();
    var
        MSWalletMerchantAccount: Record 1080;
        WebhookSubscription: Record 2000000199;
        MSWalletWebhookManagement: Codeunit 1083;
        MSWalletMerchantSetup: TestPage 1080;
        SubscriptionID: Text[250];
    begin
        Initialize();
        CreateDefaultWalletMerchantAccount(MSWalletMerchantAccount);

        LibraryVariableStorage.Enqueue(TRUE);

        MSWalletMerchantSetup.OPENEDIT();
        MSWalletMerchantSetup.Enabled.SETVALUE(FALSE);
        MSWalletMerchantSetup."Merchant ID".SETVALUE('');
        MSWalletMerchantSetup.CLOSE();

        SubscriptionID := MSWalletWebhookManagement.GetWebhookSubscriptionID(MSWalletMerchantAccount."Merchant ID");

        WebhookSubscription.SETRANGE("Subscription ID", SubscriptionID);
        WebhookSubscription.SETFILTER("Created By", STRSUBSTNO('*%1*', WalletCreatedByTok));

        Assert.IsFalse(
          WebhookSubscription.FINDFIRST(),
          STRSUBSTNO('Error Expecting Webhook to be deleted for Merchant %1', SubscriptionID));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestPaymentNotificationUrlIsIncludedInTheLink();
    var
        TempPaymentServiceSetup: Record 1060 temporary;
        MSWalletMerchantAccount: Record 1080;
        SalesInvoiceHeader: Record 112;
        TempPaymentReportingArgument: Record 1062 temporary;
        TargetURL: Text;
    begin
        Initialize();

        SetupPaymentNotification(MSWalletMerchantAccount, SalesInvoiceHeader);
        SetPaymentServicesOnPostedSalesInvoice(SalesInvoiceHeader);
        CreateMSPaymentLink(SalesInvoiceHeader);

        // Exercise
        TempPaymentServiceSetup.CreateReportingArgs(TempPaymentReportingArgument, SalesInvoiceHeader);

        // Verify
        TargetURL := TempPaymentReportingArgument.GetTargetURL();
        Assert.AreNotEqual(TargetURL, '', NotifyUrlErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestPaymentNotificationMarksInvoiceAsPartlyPaid();
    var
        MSWalletMerchantAccount: Record 1080;
        SalesInvoiceHeader: Record 112;
        TempPaymentRegistrationBuffer: Record 981 temporary;
        O365SalesInvoicePayment: Codeunit 2105;
        RemainingAmount: Decimal;
        ReceivedAmount: Decimal;
    begin
        Initialize();

        SetupPaymentNotification(MSWalletMerchantAccount, SalesInvoiceHeader);

        // Exercise
        RemainingAmount := 0.01;
        ReceivedAmount := SalesInvoiceHeader."Amount Including VAT" - RemainingAmount;
        SendPaymentNotification(MSWalletMerchantAccount."Merchant ID", SalesInvoiceHeader."No.",
          SalesInvoiceHeader."Currency Code", ReceivedAmount);
        O365SalesInvoicePayment.CollectRemainingPayments(SalesInvoiceHeader."No.", TempPaymentRegistrationBuffer);

        // Verify
        VerifyRemainingAmount(TempPaymentRegistrationBuffer, RemainingAmount);
        VerifyPaymentEvent(PaymentTok, SalesInvoiceHeader."No.", ReceivedAmount);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestPaymentNotificationMarksInvoiceAsFullyPaid();
    var
        MSWalletMerchantAccount: Record 1080;
        SalesInvoiceHeader: Record 112;
        TempPaymentRegistrationBuffer: Record 981 temporary;
        O365SalesInvoicePayment: Codeunit 2105;
    begin
        Initialize();

        SetupPaymentNotification(MSWalletMerchantAccount, SalesInvoiceHeader);

        // Exercise
        SendPaymentNotification(MSWalletMerchantAccount."Merchant ID", SalesInvoiceHeader."No.",
          SalesInvoiceHeader."Currency Code", SalesInvoiceHeader."Amount Including VAT");
        O365SalesInvoicePayment.CollectRemainingPayments(SalesInvoiceHeader."No.", TempPaymentRegistrationBuffer);

        // Verify
        VerifyRemainingAmount(TempPaymentRegistrationBuffer, 0);
        VerifyPaymentEvent(PaymentTok, SalesInvoiceHeader."No.", SalesInvoiceHeader."Amount Including VAT");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestPaymentNotificationMarksInvoiceAsOverPaid();
    var
        MSWalletMerchantAccount: Record 1080;
        SalesInvoiceHeader: Record 112;
        ReceivedAmount: Decimal;
    begin
        Initialize();

        SetupPaymentNotification(MSWalletMerchantAccount, SalesInvoiceHeader);

        // Exercise
        ReceivedAmount := SalesInvoiceHeader."Amount Including VAT" + 100;
        Asserterror SendPaymentNotification(MSWalletMerchantAccount."Merchant ID", SalesInvoiceHeader."No.",
          SalesInvoiceHeader."Currency Code", ReceivedAmount);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestCannotMakePaymentWarningForDisabledUser();
    var
        TempPaymentServiceSetup: Record 1060 temporary;
        MSWalletMerchantAccount: Record 1080;
        DummyPaymentMethod: Record 289;
        SalesInvoiceHeader: Record 112;
        TempPaymentReportingArgument: Record 1062 temporary;
        User: Record 2000000120;
        WebhookSubscription: Record 2000000199;
        MSWalletWebhookMgt: Codeunit 1083;
    begin
        Initialize();

        // Setup
        CreateDefaultWalletMerchantAccount(MSWalletMerchantAccount);
        MSWalletMerchantAccount.SetPaymentRequestURL(NewPaymentRequestURLTxt + '/payment_request');
        CreatePaymentMethod(DummyPaymentMethod, FALSE);
        CreateAndPostSalesInvoice(SalesInvoiceHeader, DummyPaymentMethod, true);
        LibraryVariableStorage.Enqueue(CannotMakePaymentWarningTxt);

        // Exercise
        // disable the user used to setup mspay
        WebhookSubscription.SetRange("Subscription ID", MSWalletWebhookMgt.GetWebhookSubscriptionID(MSWalletMerchantAccount."Merchant ID"));
        WebhookSubscription.FindFirst();
        User.Get(WebhookSubscription."Run Notification As");
        User.Validate(State, User.State::Disabled);
        User.Modify();
        CreateMSPaymentLink(SalesInvoiceHeader);

        // try to send email should get a warning
        TempPaymentServiceSetup.CreateReportingArgs(TempPaymentReportingArgument, SalesInvoiceHeader);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmHandler')]
    procedure TestShowWarningBeforeDeletingMSPayAccountWithOpenInvoices();
    var
        TempPaymentServiceSetup: Record 1060 temporary;
        MSWalletMerchantAccount: Record 1080;
        DummyPaymentMethod: Record 289;
        SalesInvoiceHeader: Record 112;
        TempPaymentReportingArgument: Record 1062 temporary;
    begin
        Initialize();

        // Setup
        CreateDefaultWalletMerchantAccount(MSWalletMerchantAccount);
        MSWalletMerchantAccount.SetPaymentRequestURL(NewPaymentRequestURLTxt + '/payment_request');
        CreatePaymentMethod(DummyPaymentMethod, FALSE);
        CreateAndPostSalesInvoice(SalesInvoiceHeader, DummyPaymentMethod, true);
        CreateMSPaymentLink(SalesInvoiceHeader);

        // Exercise
        // make a payment link for invoice
        TempPaymentServiceSetup.CreateReportingArgs(TempPaymentReportingArgument, SalesInvoiceHeader);
        // delete MSWalletMerchantAccount 
        LibraryVariableStorage.Enqueue(true);
        MSWalletMerchantAccount.Delete();

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmHandler')]
    procedure TestShowWarningBeforeDisableMSPayAccountWithOpenInvoices();
    var
        TempPaymentServiceSetup: Record 1060 temporary;
        MSWalletMerchantAccount: Record 1080;
        DummyPaymentMethod: Record 289;
        SalesInvoiceHeader: Record 112;
        TempPaymentReportingArgument: Record 1062 temporary;
    begin
        Initialize();

        // Setup
        CreateDefaultWalletMerchantAccount(MSWalletMerchantAccount);
        MSWalletMerchantAccount.SetPaymentRequestURL(NewPaymentRequestURLTxt + '/payment_request');
        CreatePaymentMethod(DummyPaymentMethod, FALSE);
        CreateAndPostSalesInvoice(SalesInvoiceHeader, DummyPaymentMethod, true);
        CreateMSPaymentLink(SalesInvoiceHeader);

        // Exercise
        // make a payment link for invoice
        TempPaymentServiceSetup.CreateReportingArgs(TempPaymentReportingArgument, SalesInvoiceHeader);
        // delete MSWalletMerchantAccount 
        LibraryVariableStorage.Enqueue(true);
        MSWalletMerchantAccount.Validate(Enabled, false);

        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure SetupPaymentNotification(var MSWalletMerchantAccount: Record 1080; var SalesInvoiceHeader: Record 112);
    var
        SalesHeader: Record 36;
        DummyPaymentMethod: Record 289;
    begin
        CreateDefaultWalletMerchantAccount(MSWalletMerchantAccount);

        MSWalletMerchantAccount.VALIDATE("Merchant ID", 'MSWallet');
        MSWalletMerchantAccount.MODIFY(TRUE);

        MSWalletMerchantAccount.SetPaymentRequestURL(NewPaymentRequestURLTxt + '/payment_request');

        SetupWebhookSubscription(MSWalletMerchantAccount."Merchant ID");
        SetupMSWalletAccountUser(MSWalletMerchantAccount);
        CreatePaymentMethod(DummyPaymentMethod, FALSE);
        CreateSalesInvoice(SalesHeader, DummyPaymentMethod);
        SalesHeader.CALCFIELDS("Amount Including VAT");
        SalesHeader.MODIFY(FALSE);
        PostSalesInvoice(SalesHeader, SalesInvoiceHeader);
        SalesInvoiceHeader.CALCFIELDS("Amount Including VAT");
        SalesInvoiceHeader.MODIFY(FALSE);
    end;

    local procedure SetupWebhookSubscription(AccountID: Text[250]);
    var
        WebhookSubscription: Record 2000000199;
        MSWalletWebhookManagement: Codeunit 1083;
        WebHooksAdapterUri: Text[250];
        SubscriptionID: Text[250];
    begin
        WebHooksAdapterUri := MSWalletWebhookManagement.GetNotificationUrl();
        SubscriptionID := MSWalletWebhookManagement.GetWebhookSubscriptionID(AccountID);
        IF WebhookSubscription.GET(SubscriptionID, WebHooksAdapterUri) THEN
            EXIT;
        WebhookSubscription.INIT();
        WebhookSubscription.VALIDATE("Subscription ID", SubscriptionID);
        WebhookSubscription.VALIDATE(Endpoint, WebHooksAdapterUri);
        WebhookSubscription.VALIDATE("Created By", WalletCreatedByTok);
        WebhookSubscription.INSERT();
    end;

    local procedure GetPaymentNotificationData(Receiver: Text; InvoiceNo: Code[20]; Currency: Code[10]; Amount: Decimal): Text;
    var
        Notification: Text;
    begin
        IF Currency = '' THEN
            Currency := GetDefaultCurrencyCode();
        Notification := STRSUBSTNO(NotificationTemplateTxt, Receiver, InvoiceNo, Currency, FORMAT(Amount, 0, 9));
        EXIT(Notification);
    end;

    local procedure SendPaymentNotification(Receiver: Text[250]; InvoiceNo: Code[20]; Currency: Code[10]; Amount: Decimal);
    var
        WebhookNotification: Record 2000000194;
        MSWalletWebhookManagement: Codeunit 1083;
        OutStream: OutStream;
        NotificationJson: Text;
    begin
        NotificationJson := GetPaymentNotificationData(Receiver, InvoiceNo, Currency, Amount);
        WebhookNotification.INIT();
        WebhookNotification.VALIDATE(ID, CREATEGUID());
        WebhookNotification.VALIDATE("Subscription ID", MSWalletWebhookManagement.GetWebhookSubscriptionID(Receiver));
        WebhookNotification.Notification.CREATEOUTSTREAM(OutStream);
        OutStream.WRITETEXT(NotificationJson);
        WebhookNotification.INSERT();
    end;

    local procedure VerifyRemainingAmount(var TempPaymentRegistrationBuffer: Record 981 temporary; RemainingAmount: Decimal);
    var
        Paid: Boolean;
    begin
        Paid := NOT TempPaymentRegistrationBuffer.FINDFIRST();
        IF RemainingAmount > 0 THEN BEGIN
            Assert.IsFalse(Paid, IncorrectPaymentStatusErr);
            Assert.AreEqual(TempPaymentRegistrationBuffer."Remaining Amount", RemainingAmount, IncorrectRemainingAmountErr);
            EXIT;
        END;
        Assert.IsTrue(Paid, IncorrectPaymentStatusErr);
    end;

    local procedure VerifyPaymentEvent(ExpectedEventType: Code[20]; ExpectedInvoiceNo: Code[20]; ExpectedAmountReceived: Decimal);
    var
        ActualEventType: Code[20];
        ActualInvoiceNo: Code[20];
        ActualAmountReceived: Decimal;
    begin
        MSWalletMockEvents.DequeueEvent(ActualEventType, ActualInvoiceNo, ActualAmountReceived);
        Assert.AreEqual(ExpectedEventType, ActualEventType, IncorrectPaymentDetailsErr);
        Assert.AreEqual(ExpectedInvoiceNo, ActualInvoiceNo, IncorrectPaymentDetailsErr);
        Assert.AreEqual(ExpectedAmountReceived, ActualAmountReceived, IncorrectPaymentDetailsErr);
        MSWalletMockEvents.AssertEmpty();
    end;

    local procedure GetDefaultCurrencyCode(): Code[10];
    var
        GeneralLedgerSetup: Record 98;
        CurrencyCode: Code[10];
    begin
        GeneralLedgerSetup.GET();
        CurrencyCode := GeneralLedgerSetup.GetCurrencyCode(CurrencyCode);
        EXIT(CurrencyCode);
    end;

    local procedure SetParametersToUpdateSetupPage(UpdatePage: Boolean; NewName: Text; NewDescription: Text; Enabled: Boolean; AlwaysIncludeOnDocument: Boolean; AccountID: Text);
    begin
        LibraryVariableStorage.Enqueue(UpdatePage);

        IF NOT UpdatePage THEN
            EXIT;

        LibraryVariableStorage.Enqueue(NewName);
        LibraryVariableStorage.Enqueue(NewDescription);
        LibraryVariableStorage.Enqueue(Enabled);
        LibraryVariableStorage.Enqueue(AlwaysIncludeOnDocument);
        LibraryVariableStorage.Enqueue(AccountID);

        if Enabled then begin
            LibraryVariableStorage.Enqueue(DeprecationOfMsPayMsg);
            LibraryVariableStorage.Enqueue(ExchangeWithExternalServicesMsg);
        end;

        IF AlwaysIncludeOnDocument THEN
            LibraryVariableStorage.Enqueue(UpdateOpenInvoicesManuallyTxt);
    end;

    local procedure SetParametersToSelectPaymentService(CancelDialog: Boolean; PaymentServiceName: Text; Available: Boolean; NewAvailable: Boolean);
    begin
        LibraryVariableStorage.Enqueue(CancelDialog);
        IF CancelDialog THEN
            EXIT;

        LibraryVariableStorage.Enqueue(PaymentServiceName);
        LibraryVariableStorage.Enqueue(Available);
        LibraryVariableStorage.Enqueue(NewAvailable);
    end;

    local procedure CreateWalletMerchantAccount(var MSWalletMerchantAccount: Record 1080);
    var
        MSWalletMerchantTemplate: Record 1081;
        MSWalletMgt: Codeunit 1080;
    begin
        MSWalletMgt.GetTemplate(MSWalletMerchantTemplate);
        MSWalletMerchantAccount.INIT();
        MSWalletMerchantAccount.TRANSFERFIELDS(MSWalletMerchantTemplate, FALSE);
        MSWalletMerchantAccount.VALIDATE(Name, COPYSTR(WalletMerchantAccountPrefixTxt + LibraryUtility.GenerateRandomAlphabeticText(30, 1),
            1, MAXSTRLEN(MSWalletMerchantAccount.Name)));
        MSWalletMerchantAccount.VALIDATE(Description, COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(30, 0),
            1, MAXSTRLEN(MSWalletMerchantAccount.Description)));
        MSWalletMerchantAccount.VALIDATE("Merchant ID", COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(30, 0),
            1, MAXSTRLEN(MSWalletMerchantAccount."Merchant ID")));
        MSWalletMerchantAccount.INSERT(TRUE);
    end;

    local procedure EnableWalletMerchantAccount(var MSWalletMerchantAccount: Record 1080);
    begin
        MSWalletMerchantAccount.VALIDATE(Enabled, TRUE);
        MSWalletMerchantAccount.MODIFY(TRUE);
    end;

    local procedure CreateDefaultWalletMerchantAccount(var DefaultMSWalletMerchantAccount: Record 1080);
    begin
        CreateWalletMerchantAccount(DefaultMSWalletMerchantAccount);
        EnableWalletMerchantAccount(DefaultMSWalletMerchantAccount);
        LibraryVariableStorage.Enqueue(UpdateOpenInvoicesManuallyTxt);
        DefaultMSWalletMerchantAccount.VALIDATE("Always Include on Documents", TRUE);
        DefaultMSWalletMerchantAccount.MODIFY(TRUE);
        SetupMSWalletAccountUser(DefaultMSWalletMerchantAccount);
    end;


    local procedure SetupMSWalletAccountUser(var DefaultMSWalletMerchantAccount: Record 1080)
    var
        User: Record 2000000120;
        WebhookSubscription: Record 2000000199;
        MSWalletWebhookMgt: Codeunit 1083;
        LibraryPermissions: Codeunit 132214;
    begin
        LibraryPermissions.CreateUser(User, CreateGuid(), false);
        WebhookSubscription.SetRange("Subscription ID", MSWalletWebhookMgt.GetWebhookSubscriptionID(DefaultMSWalletMerchantAccount."Merchant ID"));
        WebhookSubscription.FindFirst();
        WebhookSubscription.Validate("Run Notification As", User."User Security ID");
        WebhookSubscription.Modify();
        CreatePaymentRegistrationSetupForUser(User);
    end;

    local procedure CreatePaymentRegistrationSetupForUser(var User: Record 2000000120);
    var
        PaymentRegistrationSetup: Record 980;
    begin
        IF PaymentRegistrationSetup.GET(User."User Name") THEN
            EXIT;
        IF PaymentRegistrationSetup.GET() THEN BEGIN
            PaymentRegistrationSetup."User ID" := User."User Name";
            IF PaymentRegistrationSetup.INSERT(TRUE) THEN;
        END;
    end;

    local procedure CreateAndPostSalesInvoice(var SalesInvoiceHeader: Record 112; PaymentMethod: Record 289; IncludeMsPay: Boolean);
    var
        SalesHeader: Record 36;
        TempPaymentServiceSetup: Record "Payment Service Setup" temporary;
    begin
        CreateSalesInvoice(SalesHeader, PaymentMethod);

        if IncludeMsPay then begin
            TempPaymentServiceSetup.OnRegisterPaymentServices(TempPaymentServiceSetup);
            SalesHeader.Validate("Payment Service Set ID", TempPaymentServiceSetup.SaveSet(TempPaymentServiceSetup));
            SalesHeader.Modify();
        end;
        PostSalesInvoice(SalesHeader, SalesInvoiceHeader);
    end;

    local procedure SetPaymentServicesOnPostedSalesInvoice(var SalesInvoiceHeader: Record 112);
    var
        TempPaymentServiceSetup: Record "Payment Service Setup" temporary;
    begin
        TempPaymentServiceSetup.OnRegisterPaymentServices(TempPaymentServiceSetup);
        SalesInvoiceHeader.Validate("Payment Service Set ID", TempPaymentServiceSetup.SaveSet(TempPaymentServiceSetup));
        SalesInvoiceHeader.Modify();
    end;

    local procedure PostSalesInvoice(var SalesHeader: Record 36; var SalesInvoiceHeader: Record 112);
    begin
        SalesInvoiceHeader.SETAUTOCALCFIELDS(Closed);
        SalesInvoiceHeader.GET(LibrarySales.PostSalesDocument(SalesHeader, TRUE, TRUE));
    end;

    local procedure SetupReportSelections();
    var
        CustomReportLayout: Record 9650;
        ReportSelections: Record 77;
        NativeReports: Codeunit 2822;
    begin
        ReportSelections.DELETEALL();
        CreateDefaultReportSelection();

        GetCustomBodyLayout(CustomReportLayout);

        ReportSelections.FilterPrintUsage(NativeReports.PostedSalesInvoiceReportId());
        ReportSelections.FINDFIRST();
        ReportSelections.VALIDATE("Use for Email Attachment", TRUE);
        ReportSelections.VALIDATE("Use for Email Body", TRUE);
        ReportSelections.VALIDATE("Email Body Layout Code", CustomReportLayout.Code);
        ReportSelections.MODIFY(TRUE);
    end;

    local procedure CreateDefaultReportSelection();
    var
        ReportSelections: Record 77;
        NativeReports: Codeunit 2822;
    begin
        ReportSelections.INIT();
        ReportSelections.Usage := NativeReports.PostedSalesInvoiceReportId();
        ReportSelections.Sequence := '1';
        ReportSelections."Report ID" := REPORT::"Standard Sales - Invoice";
        ReportSelections.INSERT();
    end;

    local procedure GetReportID(): Integer;
    begin
        EXIT(REPORT::"Standard Sales - Invoice");
    end;

    local procedure GetCustomBodyLayout(var CustomReportLayout: Record 9650);
    begin
        CustomReportLayout.SETRANGE("Report ID", GetReportID());
        CustomReportLayout.SETRANGE(Type, CustomReportLayout.Type::Word);
        CustomReportLayout.SETFILTER(Description, '''@*Email Body*''');
        CustomReportLayout.FINDLAST();
    end;

    local procedure CreateSalesInvoice(var SalesHeader: Record 36; PaymentMethod: Record 289);
    var
        SalesLine: Record 37;
        VATPostingSetup: Record 325;
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        LibrarySales.CreateSalesHeader(
          SalesHeader, SalesHeader."Document Type"::Invoice, CreateCustomer(VATPostingSetup."VAT Bus. Posting Group"));
        SalesHeader.VALIDATE("Payment Method Code", PaymentMethod.Code);
        SalesHeader.SetDefaultPaymentServices();
        SalesHeader.MODIFY(TRUE);

        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::Item, CreateItem(VATPostingSetup."VAT Prod. Posting Group"),
          1);
    end;

    local procedure CreateCustomer(VATBusPostingGroup: Code[20]): Code[20];
    var
        Customer: Record 18;
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.VALIDATE("VAT Bus. Posting Group", VATBusPostingGroup);
        Customer.MODIFY(TRUE);
        EXIT(Customer."No.");
    end;

    local procedure CreateItem(VATProdPostingGroup: Code[20]): Code[20];
    var
        Item: Record 27;
    begin
        LibraryInventory.CreateItem(Item);
        Item.VALIDATE("VAT Prod. Posting Group", VATProdPostingGroup);
        Item.VALIDATE("Unit Price", 1000 + LibraryRandom.RandDec(100, 2));
        Item.VALIDATE("Last Direct Cost", Item."Unit Price");
        Item.MODIFY(TRUE);
        EXIT(Item."No.");
    end;

    local procedure CreatePaymentMethod(var PaymentMethod: Record 289; SetBalancingAccount: Boolean);
    begin
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        IF SetBalancingAccount THEN BEGIN
            PaymentMethod."Bal. Account Type" := PaymentMethod."Bal. Account Type"::"G/L Account";
            PaymentMethod."Bal. Account No." := LibraryERM.CreateGLAccountNo();
            PaymentMethod.MODIFY(TRUE);
        END;
    end;

    local procedure CreateMSPaymentLink(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        MSWalletPayment: Record "MS - Wallet Payment";
        URLOutStream: OutStream;
    begin
        MSWalletPayment."Invoice No" := SalesInvoiceHeader."No.";
        MSWalletPayment."Payment URL".CreateOutStream(URLOutStream);
        URLOutStream.WriteText(MSWalletTargetUrlTxt);
        MSWalletPayment.Insert();
    end;

    local procedure CreateDefaultTemplate();
    var
        MSWalletMerchantTemplate: Record 1081;
        MSWalletMgt: Codeunit 1080;
    begin
        MSWalletMerchantTemplate.DELETEALL();

        MSWalletMerchantTemplate.INIT();
        MSWalletMerchantTemplate.INSERT();
        MSWalletMgt.TemplateAssignDefaultValues(MSWalletMerchantTemplate);
        MSWalletMerchantTemplate.MODIFY();
    end;

    local procedure VerifyPaymentServicePage(PaymentServices: TestPage 1060; ExpectedPaymentServiceSetup: Record 1060);
    begin
        Assert.AreEqual(ExpectedPaymentServiceSetup.Name, PaymentServices.Name.VALUE(), 'Wrong value set for Name');
        Assert.AreEqual(ExpectedPaymentServiceSetup.Description, PaymentServices.Description.VALUE(), 'Wrong value set for Description');
        Assert.AreEqual(ExpectedPaymentServiceSetup.Enabled, PaymentServices.Enabled.ASBOOLEAN(), 'Wrong value set for Enabled');
        Assert.AreEqual(
          ExpectedPaymentServiceSetup."Always Include on Documents", PaymentServices."Always Include on Documents".ASBOOLEAN(),
          'Wrong value set for Always Include on Documents');
    end;

    local procedure VerifyWalletMerchantAccountRecord(MSWalletMerchantAccount: Record 1080; ExpectedMSWalletMerchantAccount: Record 1080);
    var
        ExpectedTargetURL: Text;
        ActualTargetURL: Text;
    begin
        Assert.AreEqual(ExpectedMSWalletMerchantAccount.Name, MSWalletMerchantAccount.Name, 'Wrong value set for Name');
        Assert.AreEqual(
          ExpectedMSWalletMerchantAccount.Description, MSWalletMerchantAccount.Description, 'Wrong value set for Description');
        Assert.AreEqual(ExpectedMSWalletMerchantAccount.Enabled, MSWalletMerchantAccount.Enabled, 'Wrong value set for Enabled');
        Assert.AreEqual(
          ExpectedMSWalletMerchantAccount."Always Include on Documents", MSWalletMerchantAccount."Always Include on Documents",
          'Wrong value set for Always Include on Documents');
        Assert.AreEqual(
          ExpectedMSWalletMerchantAccount."Merchant ID", MSWalletMerchantAccount."Merchant ID",
          'Wrong value set for Account ID');

        ExpectedTargetURL := ExpectedMSWalletMerchantAccount.GetPaymentRequestURL();
        ActualTargetURL := MSWalletMerchantAccount.GetPaymentRequestURL();
        Assert.AreEqual(ExpectedTargetURL, ActualTargetURL, 'Wrong value set for Always Include on Documents');
    end;

    local procedure VerifyPaymentServiceIsShownOnServiceConnectionsPage(var ServiceConnections: TestPage 1279; MSWalletMerchantAccount: Record 1080);
    var
        ServiceConnection: Record 1400;
    begin
        ServiceConnections.FILTER.SETFILTER(Name, MSWalletMerchantAccount.Description);

        Assert.AreEqual(
          MSWalletMerchantAccount.Description, ServiceConnections.Name.VALUE(),
          'Description was not set correctly on Service Connections page');

        IF MSWalletMerchantAccount.Enabled THEN
            Assert.AreEqual(
              FORMAT(ServiceConnection.Status::Enabled), ServiceConnections.Status.VALUE(),
              'Status was not set correctly on Service Connections page')
        ELSE
            Assert.AreEqual(
              FORMAT(ServiceConnection.Status::Disabled), ServiceConnections.Status.VALUE(),
              'Status was not set correctly on Service Connections page');
    end;

    local procedure VerifyPaymentServiceIsInReportDataset(var PaymentReportingArgument: Record 1062);
    var
        XMLBuffer: Record 1235;
        ValueFound: Boolean;
    begin
        XMLBuffer.Load(DatasetFileName);
        XMLBuffer.SETRANGE(Name, 'PaymentServiceURL');
        XMLBuffer.FIND('-');

        ValueFound := FALSE;
        REPEAT
            ValueFound := COPYSTR(PaymentReportingArgument.GetTargetURL(), 1, 250) = XMLBuffer.Value
        UNTIL (XMLBuffer.NEXT() = 0) OR ValueFound;
        Assert.IsTrue(ValueFound, 'Cound not find target URL');
        XMLBuffer.SETRANGE("Parent Entry No.", XMLBuffer."Parent Entry No.");
        XMLBuffer.SETRANGE(Name, 'PaymentServiceURLText');
        XMLBuffer.FIND('-');
        Assert.AreEqual(PaymentReportingArgument."URL Caption", XMLBuffer.Value, '');
    end;

    local procedure VerifyWalletURL(var PaymentReportingArgument: Record 1062);
    var
        TargetURL: Text;
    begin
        TargetURL := PaymentReportingArgument.GetTargetURL();
        Assert.IsTrue((Assert.Equal(MSWalletTargetUrlTxt, TargetURL) or TargetURL.StartsWith(MSWalletTargetUrlStartTxt)), 'Wrong target URL!');
    end;

    [ModalPageHandler]
    procedure AccountSetupPageModalPageHandler(var MSWalletMerchantSetup: TestPage 1080);
    var
        NewName: Text;
        NewDescription: Text;
        AccountID: Text;
        Enabled: Boolean;
        AlwaysIncludeOnDocument: Boolean;
        UpdatePage: Boolean;
    begin
        UpdatePage := LibraryVariableStorage.DequeueBoolean();

        IF NOT UpdatePage THEN
            EXIT;

        NewName := LibraryVariableStorage.DequeueText();
        NewDescription := LibraryVariableStorage.DequeueText();
        Enabled := LibraryVariableStorage.DequeueBoolean();
        AlwaysIncludeOnDocument := LibraryVariableStorage.DequeueBoolean();
        AccountID := LibraryVariableStorage.DequeueText();

        MSWalletMerchantSetup.Name.SETVALUE(NewName);
        MSWalletMerchantSetup.Description.SETVALUE(NewDescription);
        MSWalletMerchantSetup."Merchant ID".SETVALUE(AccountID);
        MSWalletMerchantSetup.Enabled.SETVALUE(Enabled);
        MSWalletMerchantSetup."Always Include on Documents".SETVALUE(AlwaysIncludeOnDocument);
        MSWalletMerchantSetup.OK().INVOKE();
    end;

    [ModalPageHandler]
    procedure SelectPaymentServiceModalPageHandler(var SelectPaymentService: TestPage 1061);
    var
        CancelDialog: Boolean;
        RowFound: Boolean;
        PaymentServiceName: Text;
        ExpectedAvailable: Boolean;
        NewAvailable: Boolean;
    begin
        CancelDialog := LibraryVariableStorage.DequeueBoolean();

        IF CancelDialog THEN BEGIN
            SelectPaymentService.Cancel().INVOKE();
            EXIT;
        END;

        SelectPaymentService.LAST();
        RowFound := FALSE;

        PaymentServiceName := LibraryVariableStorage.DequeueText();
        ExpectedAvailable := LibraryVariableStorage.DequeueBoolean();
        NewAvailable := LibraryVariableStorage.DequeueBoolean();

        REPEAT
            IF SelectPaymentService.Name.VALUE() = PaymentServiceName THEN BEGIN
                RowFound := TRUE;
                Assert.AreEqual(ExpectedAvailable, SelectPaymentService.Available.ASBOOLEAN(), 'Available was not set correctly');
                SelectPaymentService.Available.SETVALUE(NewAvailable);
            END;
        UNTIL (NOT SelectPaymentService.PREVIOUS()) OR RowFound;

        Assert.IsTrue(RowFound, 'Row was not found on the page');

        SelectPaymentService.OK().INVOKE();
    end;

    [RequestPageHandler]
    procedure SalesInvoiceReportRequestPageHandler(var SalesInvoice: TestRequestPage 206);
    var
        LibraryReportDataset: Codeunit 131007;
    begin
        DatasetFileName := LibraryReportDataset.GetFileName();
        SalesInvoice.SAVEASXML(LibraryReportDataset.GetParametersFileName(), DatasetFileName);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean);
    begin
        Reply := LibraryVariableStorage.DequeueBoolean();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text);
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Message);
    end;

    [ModalPageHandler]
    procedure EMailDialogHandler(var EMailDialog: TestPage 9700);
    begin
        LibraryVariableStorage.Enqueue(EMailDialog.BodyText.VALUE());
    end;

    [ModalPageHandler]
    procedure SelectPaymentServiceTypeHandler(var SelectPaymentServiceType: TestPage 1062);
    var
        ServiceName: Text;
    begin
        ServiceName := LibraryVariableStorage.DequeueText();
        SelectPaymentServiceType.FILTER.SETFILTER(Name, ServiceName);
        SelectPaymentServiceType.FIRST();
        SelectPaymentServiceType.OK().INVOKE();
    end;
}

