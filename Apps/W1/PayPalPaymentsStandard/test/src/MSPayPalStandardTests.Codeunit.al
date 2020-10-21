codeunit 139500 "MS - PayPal Standard Tests"
{
    // version Test,ERM,W1,AT,AU,BE,CA,CH,DE,DK,ES,FI,FR,GB,IS,IT,MX,NL,NO,NZ,SE,US

    Subtype = Test;

    TestPermissions = Disabled;

    var
        Assert: Codeunit 130000;
        LibraryUtility: Codeunit 131000;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibrarySales: Codeunit 130509;
        LibraryInventory: Codeunit 132201;
        LibraryERM: Codeunit 131300;
        LibraryRandom: Codeunit 130440;
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        MSPayPalStdMockEvents: Codeunit 139503;
        ActiveDirectoryMockEvents: Codeunit 131033;
        DatasetFileName: Text;
        Initialized: Boolean;
        UpdateOpenInvoicesManuallyTxt: Label 'A link for the PayPal payment service will be included for new sales documents. To add it to existing sales documents, you must manually select it in the Payment Service field on the sales document.';
        ExchangeWithExternalServicesMsg: Label 'This extension uses the Paypal service, a third-party provider.';
        ServiceNotSetupErr: Label 'You must specify an account ID for this payment service.';
        PayPalStandardNameTxt: Label 'PayPal Payments Standard';
        PayPalStandardDescriptionTxt: Label 'PayPal Payments Standard - Fee % of Amount';
        NewTargetURLTxt: Label 'https://localhost:999/test?', Locked = true;
        NewLogoURLTxt: Label 'https://localhost:999/logo', Locked = true;
        NotifyUrlParamTxt: Label '&notify_url=%1', Locked = true;
        NotifyUrlErr: Label 'Could not find the notify_url in the Target URL.';
        NotificationTemplateTxt: Label '{"invoice":"%1","mc_currency":"%2","mc_gross":"%3","receiver_email":"%4","payment_status":"%5","txn_id":"%6"}', Locked = true;
        PaymentReportArgumentErrorTxt: Label 'Could not find payment reporting argument.';
        PaymentStatusCompletedTxt: Label 'Completed', Locked = true;
        PaymentStatusPendingTxt: Label 'Pending', Locked = true;
        MissingInvoiceNumberTxt: Label 'Missing', Locked = true;
        PaymentTok: Label 'payment', Locked = true;
        OverpaymentTok: Label 'overpayment', Locked = true;
        IncorrectRemainingAmountErr: Label 'Incorrect remaining amount.';
        IncorrectPaymentStatusErr: Label 'Incorrect payment status.';
        IncorrectPaymentDetailsErr: Label 'Incorrect payment details.';
        SetToDefaultMsg: Label 'Settings have been set to default.';
        PayPalAccountPrefixTxt: Label 'PayPal';
        PayPalCreatedByTok: Label 'PAYPAL.COM', Locked = true;
        WebhookCreateSubscriptionErrorTxt: Label 'Error Expecting Webhook to be created for Account %1', Locked = true;
        WebhookUpdateSubscriptionErrorTxt: Label 'Error Expecting Webhook to be updated to have one for Account %1', Locked = true;
        WebhookDeleteSubscriptionErrorTxt: Label 'Error Expecting Webhook to be deleted for Account %1', Locked = true;

    local procedure Initialize();
    var
        CompanyInfo: Record 79;
        MSPayPalStandardAccount: Record 1070;
        MSPayPalTransaction: Record 1077;
        DummySalesHeader: Record 36;
        DummyPaymentMethod: Record 289;
        WebhookSubscription: Record 2000000199;
        WebhookNotification: Record 2000000194;
    begin
        BindActiveDirectoryMockEvents();

        CompanyInfo.GET();
        CompanyInfo."Allow Blank Payment Info." := TRUE;
        CompanyInfo.MODIFY();
        LibraryVariableStorage.AssertEmpty();

        MSPayPalStandardAccount.DELETEALL();
        MSPayPalTransaction.DELETEALL();
        WebhookSubscription.DELETEALL();
        WebhookNotification.DELETEALL();
        CreateDefaultTemplate();
        SetPaymentRegistrationSetup();

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(FALSE);

        IF Initialized THEN
            EXIT;

        CreateSalesInvoice(DummySalesHeader, DummyPaymentMethod);
        SetupReportSelections();
        COMMIT();

        BINDSUBSCRIPTION(MSPayPalStdMockEvents);

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
        LibraryVariableStorage.Enqueue(PayPalStandardNameTxt);
        SetParametersToUpdateSetupPage(ChangeValuesOnSetupPage, '', '', Enabled, AlwaysInclude, '', '');
        LibraryVariableStorage.Enqueue(EnableServiceWhenClosingCard);

        PaymentServices.NewAction.INVOKE();

        // Verify
        ExpectedPaymentServiceSetup.INIT();
        ExpectedPaymentServiceSetup.Name := PayPalStandardNameTxt;
        ExpectedPaymentServiceSetup.Description := PayPalStandardDescriptionTxt;
        ExpectedPaymentServiceSetup.Enabled := Enabled;
        ExpectedPaymentServiceSetup."Always Include on Documents" := AlwaysInclude;

        PaymentServices.Filter.SetFilter(Name, ExpectedPaymentServiceSetup.Name);
        PaymentServices.First();

        VerifyPaymentServicePage(PaymentServices, ExpectedPaymentServiceSetup);
    end;

    [Test]
    procedure TestExistingPaymentServicesAreShownInTheList();
    var
        MSPayPalStandardAccount: Record 1070;
        ExpectedPaymentServiceSetup: Record 1060;
        PaymentServices: TestPage 1060;
    begin
        // Setup
        Initialize();
        CreatePayPalStandardAccount(MSPayPalStandardAccount);

        // Execute
        PaymentServices.OPENEDIT();

        // Verify
        ExpectedPaymentServiceSetup.INIT();
        ExpectedPaymentServiceSetup.Name := MSPayPalStandardAccount.Name;
        ExpectedPaymentServiceSetup.Description := MSPayPalStandardAccount.Description;
        ExpectedPaymentServiceSetup.Enabled := FALSE;
        ExpectedPaymentServiceSetup."Always Include on Documents" := FALSE;

        PaymentServices.Filter.SetFilter(Name, ExpectedPaymentServiceSetup.Name);
        PaymentServices.First();

        VerifyPaymentServicePage(PaymentServices, ExpectedPaymentServiceSetup);
    end;

    [Test]
    [HandlerFunctions('AccountSetupPageModalPageHandler,MessageHandler')]
    procedure TestSetupPaymentService();
    var
        MSPayPalStandardAccount: Record 1070;
        ExpectedMSPayPalStandardAccount: Record 1070;
        PaymentServices: TestPage 1060;
        ChangeValuesOnSetupPage: Boolean;
    begin
        // Setup
        Initialize();
        CreatePayPalStandardAccount(MSPayPalStandardAccount);

        // Execute
        PaymentServices.OPENEDIT();
        PaymentServices.FILTER.SETFILTER(Name, PayPalAccountPrefixTxt + '*');
        ChangeValuesOnSetupPage := TRUE;
        ExpectedMSPayPalStandardAccount.COPY(MSPayPalStandardAccount);
        ExpectedMSPayPalStandardAccount.Enabled := TRUE;
        ExpectedMSPayPalStandardAccount."Always Include on Documents" := TRUE;
        ExpectedMSPayPalStandardAccount.Name := COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(20, 0),
            1, MAXSTRLEN(ExpectedMSPayPalStandardAccount.Name));
        ExpectedMSPayPalStandardAccount.Description :=
          COPYSTR(LibraryUtility.GenerateRandomText(MAXSTRLEN(MSPayPalStandardAccount.Description)),
            1, MAXSTRLEN(ExpectedMSPayPalStandardAccount.Name));
        ExpectedMSPayPalStandardAccount."Account ID" := COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(20, 0),
            1, MAXSTRLEN(ExpectedMSPayPalStandardAccount."Account ID"));
        ExpectedMSPayPalStandardAccount.SetTargetURL(NewTargetURLTxt);

        SetParametersToUpdateSetupPage(ChangeValuesOnSetupPage, ExpectedMSPayPalStandardAccount.Name,
          ExpectedMSPayPalStandardAccount.Description, ExpectedMSPayPalStandardAccount.Enabled,
          ExpectedMSPayPalStandardAccount."Always Include on Documents", ExpectedMSPayPalStandardAccount."Account ID", NewTargetURLTxt);
        PaymentServices.Setup.INVOKE();

        // Verify
        MSPayPalStandardAccount.GET(MSPayPalStandardAccount."Primary Key");
        VerifyPayPalAccountRecord(MSPayPalStandardAccount, ExpectedMSPayPalStandardAccount);
    end;

    [Test]
    [HandlerFunctions('AccountSetupPageModalPageHandler,ConfirmHandler')]
    procedure TestEnablingWhenClosingSetupPage();
    var
        MSPayPalStandardAccount: Record 1070;
        ExpectedMSPayPalStandardAccount: Record 1070;
        PaymentServices: TestPage 1060;
        ChangeValuesOnSetupPage: Boolean;
        EnableServiceWhenClosingCard: Boolean;
    begin
        // Setup
        Initialize();
        CreatePayPalStandardAccount(MSPayPalStandardAccount);

        // Execute
        PaymentServices.OPENEDIT();
        PaymentServices.FILTER.SETFILTER(Name, PayPalAccountPrefixTxt + '*');
        ChangeValuesOnSetupPage := TRUE;
        EnableServiceWhenClosingCard := TRUE;

        ExpectedMSPayPalStandardAccount.INIT();
        ExpectedMSPayPalStandardAccount.COPY(MSPayPalStandardAccount);
        ExpectedMSPayPalStandardAccount.Enabled := FALSE;
        ExpectedMSPayPalStandardAccount."Account ID" := COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(20, 0),
            1, MAXSTRLEN(ExpectedMSPayPalStandardAccount."Account ID"));

        SetParametersToUpdateSetupPage(ChangeValuesOnSetupPage, ExpectedMSPayPalStandardAccount.Name,
          ExpectedMSPayPalStandardAccount.Description, ExpectedMSPayPalStandardAccount.Enabled,
          ExpectedMSPayPalStandardAccount."Always Include on Documents", ExpectedMSPayPalStandardAccount."Account ID", NewTargetURLTxt);

        LibraryVariableStorage.Enqueue(EnableServiceWhenClosingCard);

        PaymentServices.Setup.INVOKE();

        // Verify
        ExpectedMSPayPalStandardAccount.Enabled := FALSE;
        MSPayPalStandardAccount.GET(MSPayPalStandardAccount."Primary Key");
        VerifyPayPalAccountRecord(MSPayPalStandardAccount, ExpectedMSPayPalStandardAccount);
    end;

    [Test]
    procedure TestCannotEnableWithoutAccountID();
    var
        MSPayPalStandardAccount: Record 1070;
    begin
        // Setup
        Initialize();
        CreatePayPalStandardAccount(MSPayPalStandardAccount);
        MSPayPalStandardAccount."Account ID" := '';

        // Verify
        ASSERTERROR MSPayPalStandardAccount.VALIDATE(Enabled, TRUE);
        Assert.ExpectedError(ServiceNotSetupErr);
    end;

    [Test]
    procedure TestCannotBlankAccountIDWhenEnabled();
    var
        MSPayPalStandardAccount: Record 1070;
    begin
        // Setup
        Initialize();
        CreatePayPalStandardAccount(MSPayPalStandardAccount);
        EnablePayPalStandardAccount(MSPayPalStandardAccount);

        // Verify
        ASSERTERROR MSPayPalStandardAccount.VALIDATE("Account ID", '');
        Assert.ExpectedError(ServiceNotSetupErr);
    end;

    [Test]
    [HandlerFunctions('AccountSetupPageModalPageHandler,ConfirmHandler,SelectPaymentServiceTypeHandler')]
    procedure TestEditPayPalTemplate();
    var
        MSPayPalStandardTemplate: Record 1071;
        ExpectedPaymentServiceSetup: Record 1060;
        MSPayPalStandardMgt: Codeunit 1070;
        PaymentServices: TestPage 1060;
        ChangeValuesOnSetupPage: Boolean;
        Enabled: Boolean;
        AlwaysInclude: Boolean;
        EnableServiceWhenClosingCard: Boolean;
        NewName: Text;
        NewDescription: Text;
    begin
        // Setup
        Initialize();

        // Execute
        ModifyPayPalTemplate(NewName, NewDescription);

        MSPayPalStandardMgt.GetTemplate(MSPayPalStandardTemplate);

        // Verify new template
        VerifyPayPalTemplate(MSPayPalStandardTemplate, NewName, NewDescription, NewTargetURLTxt, NewLogoURLTxt);

        // Verify template gets applied
        ChangeValuesOnSetupPage := FALSE;
        Enabled := FALSE;
        AlwaysInclude := FALSE;
        EnableServiceWhenClosingCard := FALSE;
        LibraryVariableStorage.Enqueue(NewName);
        SetParametersToUpdateSetupPage(ChangeValuesOnSetupPage, '', '', Enabled, AlwaysInclude, '', '');
        LibraryVariableStorage.Enqueue(EnableServiceWhenClosingCard);

        PaymentServices.OPENEDIT();
        PaymentServices.NewAction.INVOKE();
        PaymentServices.FILTER.SETFILTER(Name, NewName + '*');

        // Verify
        ExpectedPaymentServiceSetup.INIT();
        ExpectedPaymentServiceSetup.Name := MSPayPalStandardTemplate.Name;
        ExpectedPaymentServiceSetup.Description := MSPayPalStandardTemplate.Description;
        ExpectedPaymentServiceSetup.Enabled := Enabled;
        ExpectedPaymentServiceSetup."Always Include on Documents" := AlwaysInclude;

        VerifyPaymentServicePage(PaymentServices, ExpectedPaymentServiceSetup);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmHandler')]
    procedure TestResetToDefaultPayPalTemplate();
    var
        MSPayPalStandardTemplate: Record 1071;
        NewMSPayPalStandardTemplate: Record 1071;
        MSPayPalStandardMgt: Codeunit 1070;
        MSPayPalStandardTemplateSetupPage: TestPage 1071;
        NewName: Text;
        NewDescription: Text;
        ExpectedTargetURL: Text;
        ExpectedLogoURL: Text;
    begin
        // Setup
        Initialize();
        MSPayPalStandardMgt.GetTemplate(MSPayPalStandardTemplate);
        ModifyPayPalTemplate(NewName, NewDescription);

        // Execute
        MSPayPalStandardTemplateSetupPage.OPENEDIT();
        LibraryVariableStorage.Enqueue(SetToDefaultMsg);
        MSPayPalStandardTemplateSetupPage.ResetToDefault.INVOKE();

        // Verify new template
        MSPayPalStandardMgt.GetTemplate(NewMSPayPalStandardTemplate);
        ExpectedTargetURL := MSPayPalStandardTemplate.GetTargetURL();
        ExpectedLogoURL := MSPayPalStandardTemplate.GetLogoURL();
        VerifyPayPalTemplate(
          NewMSPayPalStandardTemplate, MSPayPalStandardTemplate.Name, MSPayPalStandardTemplate.Description,
          ExpectedTargetURL, ExpectedLogoURL);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmHandler')]
    procedure TestResetToDefaultPayPalTemplateInDemoCompany();
    var
        MSPayPalStandardTemplate: Record 1071;
        NewMSPayPalStandardTemplate: Record 1071;
        CompanyInformation: Record 79;
        MSPayPalStandardMgt: Codeunit 1070;
        MSPayPalStandardTemplateSetupPage: TestPage 1071;
        NewName: Text;
        NewDescription: Text;
        ExpectedTargetURL: Text;
        ExpectedLogoURL: Text;
    begin
        // Setup
        Initialize();

        MSPayPalStandardMgt.GetTemplate(MSPayPalStandardTemplate);
        ModifyPayPalTemplate(NewName, NewDescription);

        CompanyInformation.GET();
        CompanyInformation."Demo Company" := TRUE;
        CompanyInformation.MODIFY();

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(TRUE);

        // Execute
        MSPayPalStandardTemplateSetupPage.OPENEDIT();
        LibraryVariableStorage.Enqueue(SetToDefaultMsg);
        MSPayPalStandardTemplateSetupPage.ResetToDefault.INVOKE();

        // Verify new template
        MSPayPalStandardMgt.GetTemplate(NewMSPayPalStandardTemplate);
        ExpectedTargetURL := MSPayPalStandardTemplate.GetTargetURL();
        ExpectedLogoURL := MSPayPalStandardTemplate.GetLogoURL();

        Assert.AreEqual(1, STRPOS(ExpectedTargetURL, MSPayPalStandardMgt.GetSandboxURL()), 'Wrong position for the target URL');
        VerifyPayPalTemplate(
          NewMSPayPalStandardTemplate, MSPayPalStandardTemplate.Name, MSPayPalStandardTemplate.Description,
          ExpectedTargetURL, ExpectedLogoURL);
    end;

    [Test]
    procedure TestServiceConnectionListShowsDisabledPaymentServices();
    var
        MSPayPalStandardAccount: Record 1070;
    begin
        Initialize();

        // Setup
        CreatePayPalStandardAccount(MSPayPalStandardAccount);

        // Verify
        VerifyPaymentServiceIsShownOnServiceConnectionsPage(MSPayPalStandardAccount);
    end;

    [Test]
    procedure TestServiceConnectionListShowsEnabledPaymentServices();
    var
        MSPayPalStandardAccount: Record 1070;
    begin
        Initialize();

        // Setup
        CreatePayPalStandardAccount(MSPayPalStandardAccount);
        EnablePayPalStandardAccount(MSPayPalStandardAccount);

        // Verify
        VerifyPaymentServiceIsShownOnServiceConnectionsPage(MSPayPalStandardAccount);
    end;

    [Test]
    [HandlerFunctions('AccountSetupPageModalPageHandler,MessageHandler')]
    procedure TestServiceConnectionListOpensPaymentServicesSetupCard();
    var
        MSPayPalStandardAccount: Record 1070;
        ServiceConnections: TestPage 1279;
    begin
        Initialize();

        // Setup
        CreatePayPalStandardAccount(MSPayPalStandardAccount);
        ServiceConnections.OPENEDIT();
        ServiceConnections.FILTER.SETFILTER(Name, MSPayPalStandardAccount.Description);
        SetParametersToUpdateSetupPage(
          TRUE, MSPayPalStandardAccount.Name, MSPayPalStandardAccount.Description, TRUE, TRUE, MSPayPalStandardAccount."Account ID",
          NewTargetURLTxt);

        // Execute
        ServiceConnections.Setup.INVOKE();

        // Verify
        MSPayPalStandardAccount.Enabled := TRUE;
        MSPayPalStandardAccount."Always Include on Documents" := TRUE;
        VerifyPaymentServiceIsShownOnServiceConnectionsPage(MSPayPalStandardAccount);
    end;

    [Test]
    [HandlerFunctions('SelectPaymentServiceModalPageHandler')]
    procedure TestSelectingStandardPayPalService();
    var
        MSPayPalStandardAccount: Record 1070;
        SalesHeader: Record 36;
        DummyPaymentMethod: Record 289;
        SalesInvoice: TestPage 43;
        NewAvailable: Boolean;
    begin
        // Setup
        Initialize();
        CreatePayPalStandardAccount(MSPayPalStandardAccount);
        EnablePayPalStandardAccount(MSPayPalStandardAccount);

        CreateSalesInvoice(SalesHeader, DummyPaymentMethod);

        // Execute
        SalesInvoice.OPENEDIT();
        SalesInvoice.GOTORECORD(SalesHeader);

        NewAvailable := TRUE;
        SetParametersToSelectPaymentService(
          FALSE, MSPayPalStandardAccount.Name, MSPayPalStandardAccount."Always Include on Documents", NewAvailable);
        SalesInvoice.SelectedPayments.ASSISTEDIT();

        // Verify
        Assert.AreEqual(MSPayPalStandardAccount.Name, SalesInvoice.SelectedPayments.VALUE(), 'Wrong value was set');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestOnlyOneAlwaysIncludedStandardPayPalService();
    var
        MSPayPalStandardAccount1: Record 1070;
        MSPayPalStandardAccount2: Record 1070;
        MSPayPalStandardAccount: Record 1070;
    begin
        // Setup
        Initialize();
        CreatePayPalStandardAccount(MSPayPalStandardAccount1);
        EnablePayPalStandardAccount(MSPayPalStandardAccount1);

        CreatePayPalStandardAccount(MSPayPalStandardAccount2);
        EnablePayPalStandardAccount(MSPayPalStandardAccount2);

        // Execute
        LibraryVariableStorage.Enqueue(UpdateOpenInvoicesManuallyTxt);
        MSPayPalStandardAccount1.VALIDATE("Always Include on Documents", TRUE);
        MSPayPalStandardAccount1.MODIFY(TRUE);

        // Verify this is the one
        LibraryVariableStorage.Enqueue(UpdateOpenInvoicesManuallyTxt);
        MSPayPalStandardAccount.SETRANGE("Always Include on Documents", TRUE);
        MSPayPalStandardAccount.FINDFIRST();
        Assert.AreEqual(1, MSPayPalStandardAccount.COUNT(), '');

        MSPayPalStandardAccount2.FIND();
        MSPayPalStandardAccount1.FIND();
        Assert.IsFalse(MSPayPalStandardAccount2."Always Include on Documents", 'First Verify');
        Assert.IsTrue(MSPayPalStandardAccount1."Always Include on Documents", 'First Verify');

        // Execute
        MSPayPalStandardAccount2.VALIDATE("Always Include on Documents", TRUE);
        MSPayPalStandardAccount2.MODIFY(TRUE);

        // Verify 2 is now the only one
        MSPayPalStandardAccount.SETRANGE("Always Include on Documents", TRUE);
        MSPayPalStandardAccount.FINDFIRST();
        Assert.AreEqual(1, MSPayPalStandardAccount.COUNT(), '');

        MSPayPalStandardAccount1.FIND();
        MSPayPalStandardAccount2.FIND();
        Assert.IsTrue(MSPayPalStandardAccount2."Always Include on Documents", 'Final Verify');
        Assert.IsFalse(MSPayPalStandardAccount1."Always Include on Documents", 'Final Verify');
        MSPayPalStandardAccount1.NEXT();
        MSPayPalStandardAccount2.NEXT();
    end;

    [Test]
    [HandlerFunctions('SalesInvoiceReportRequestPageHandler,MessageHandler')]
    procedure TestSalesInvoiceReportSingleInvoice();
    var
        TempPaymentServiceSetup: Record 1060 temporary;
        MSPayPalStandardAccount: Record 1070;
        DummyPaymentMethod: Record 289;
        SalesInvoiceHeader: Record 112;
        TempPaymentReportingArgument: Record 1062 temporary;
    begin
        Initialize();

        // Setup
        CreateDefaultPayPalStandardAccount(MSPayPalStandardAccount);
        CreatePaymentMethod(DummyPaymentMethod, FALSE);
        CreateAndPostSalesInvoice(SalesInvoiceHeader, DummyPaymentMethod);
        TempPaymentServiceSetup.CreateReportingArgs(TempPaymentReportingArgument, SalesInvoiceHeader);

        TempPaymentReportingArgument.SetRange("Payment Service ID", TempPaymentReportingArgument.GetPayPalServiceID());
        TempPaymentReportingArgument.FindFirst();

        // Exercise
        SalesInvoiceHeader.SETRECFILTER();
        COMMIT();
        REPORT.RUN(REPORT::"Sales - Invoice", TRUE, FALSE, SalesInvoiceHeader);

        // Verify
        VerifyPaymentServiceIsInReportDataset(TempPaymentReportingArgument);
        VerifyPayPalURL(TempPaymentReportingArgument, MSPayPalStandardAccount, SalesInvoiceHeader);
    end;

    [Test]
    [HandlerFunctions('SalesInvoiceReportRequestPageHandler,MessageHandler')]
    procedure TestSalesInvoiceReportMultipleInvoices();
    var
        TempPaymentServiceSetup: Record 1060 temporary;
        MSPayPalStandardAccount: Record 1070;
        DummyPaymentMethod: Record 289;
        SalesInvoiceHeader: Record 112;
        SalesInvoiceHeader2: Record 112;
        TempPaymentReportingArgument: Record 1062 temporary;
        TempPaymentReportingArgument2: Record 1062 temporary;
    begin
        Initialize();
        SalesInvoiceHeader.DELETEALL();

        // Setup
        CreateDefaultPayPalStandardAccount(MSPayPalStandardAccount);
        CreatePaymentMethod(DummyPaymentMethod, FALSE);
        CreateAndPostSalesInvoice(SalesInvoiceHeader, DummyPaymentMethod);
        CreateAndPostSalesInvoice(SalesInvoiceHeader2, DummyPaymentMethod);
        TempPaymentServiceSetup.CreateReportingArgs(TempPaymentReportingArgument, SalesInvoiceHeader);
        TempPaymentServiceSetup.CreateReportingArgs(TempPaymentReportingArgument2, SalesInvoiceHeader2);

        TempPaymentReportingArgument.SetRange("Payment Service ID", TempPaymentReportingArgument.GetPayPalServiceID());
        TempPaymentReportingArgument.FindFirst();

        TempPaymentReportingArgument2.SetRange("Payment Service ID", TempPaymentReportingArgument2.GetPayPalServiceID());
        TempPaymentReportingArgument2.FindFirst();

        // Exercise
        SalesInvoiceHeader.SETFILTER("No.", '%1..%2', SalesInvoiceHeader."No.", SalesInvoiceHeader2."No.");
        COMMIT();
        REPORT.RUN(REPORT::"Sales - Invoice", TRUE, FALSE, SalesInvoiceHeader);

        // Verify
        VerifyPaymentServiceIsInReportDataset(TempPaymentReportingArgument);
        VerifyPaymentServiceIsInReportDataset(TempPaymentReportingArgument2);

        VerifyPayPalURL(TempPaymentReportingArgument, MSPayPalStandardAccount, SalesInvoiceHeader);
        VerifyPayPalURL(TempPaymentReportingArgument2, MSPayPalStandardAccount, SalesInvoiceHeader2);
    end;

    [Test]
    [HandlerFunctions('SalesInvoiceReportRequestPageHandler,MessageHandler')]
    procedure TestSalesInvoiceReportChangeTargetURL();
    var
        TempPaymentServiceSetup: Record 1060 temporary;
        MSPayPalStandardAccount: Record 1070;
        DummyPaymentMethod: Record 289;
        SalesInvoiceHeader: Record 112;
        TempPaymentReportingArgument: Record 1062 temporary;
    begin
        Initialize();

        // Setup
        CreateDefaultPayPalStandardAccount(MSPayPalStandardAccount);
        MSPayPalStandardAccount.SetTargetURL(NewTargetURLTxt);
        CreatePaymentMethod(DummyPaymentMethod, FALSE);
        CreateAndPostSalesInvoice(SalesInvoiceHeader, DummyPaymentMethod);
        TempPaymentServiceSetup.CreateReportingArgs(TempPaymentReportingArgument, SalesInvoiceHeader);

        // Exercise
        COMMIT();
        SalesInvoiceHeader.SETRECFILTER();
        REPORT.RUN(REPORT::"Sales - Invoice", TRUE, FALSE, SalesInvoiceHeader);

        // Verify
        VerifyPaymentServiceIsInReportDataset(TempPaymentReportingArgument);
        TempPaymentReportingArgument.FINDFIRST();
        VerifyPayPalURL(TempPaymentReportingArgument, MSPayPalStandardAccount, SalesInvoiceHeader);
    end;

    [Test]
    [HandlerFunctions('EMailDialogHandler,MessageHandler')]
    procedure TestCoverLetterPaymentLinkSMTPSetup(); // To be removed together with deprecated SMTP objects
    var
        LibraryEmailFeature: Codeunit "Library - Email Feature";
    begin
        LibraryEmailFeature.SetEmailFeatureEnabled(false);
        TestCoverLetterPaymentLinkInternal();
    end;

    [Test]
    [HandlerFunctions('EmailEditorHandler,MessageHandler,CloseEmailEditorHandler')]
    procedure TestCoverLetterPaymentLink();
    var
        LibraryEmailFeature: Codeunit "Library - Email Feature";
    begin
        LibraryEmailFeature.SetEmailFeatureEnabled(true);
        TestCoverLetterPaymentLinkInternal();
    end;

    procedure TestCoverLetterPaymentLinkInternal();
    var
        TempPaymentServiceSetup: Record 1060 temporary;
        MSPayPalStandardAccount: Record 1070;
        DummyPaymentMethod: Record 289;
        SalesInvoiceHeader: Record 112;
        TempPaymentReportingArgument: Record 1062 temporary;
        LibraryInvoicingApp: Codeunit "Library - Invoicing App";
        LibraryWorkflow: Codeunit "Library - Workflow";
        EmailFeature: Codeunit "Email Feature";
        PostedSalesInvoice: TestPage 132;
    begin
        Initialize();

        // Setup
        CreateDefaultPayPalStandardAccount(MSPayPalStandardAccount);
        MSPayPalStandardAccount.SetTargetURL(NewTargetURLTxt);
        CreatePaymentMethod(DummyPaymentMethod, FALSE);
        CreateAndPostSalesInvoice(SalesInvoiceHeader, DummyPaymentMethod);
        TempPaymentServiceSetup.CreateReportingArgs(TempPaymentReportingArgument, SalesInvoiceHeader);
        PostedSalesInvoice.OPENEDIT();
        PostedSalesInvoice.GOTORECORD(SalesInvoiceHeader);
        if EmailFeature.IsEnabled() then
            LibraryWorkflow.SetUpEmailAccount()
        else
            LibraryInvoicingApp.SetupEmailTable();

        // Exercise
        PostedSalesInvoice.Email.INVOKE();

        // Verify
        if TempPaymentReportingArgument.IsEmpty() then
            Error(PaymentReportArgumentErrorTxt);
        VerifyBodyText(MSPayPalStandardAccount, SalesInvoiceHeader);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestYourReferenceIsIncludedInTheLink();
    var
        TempPaymentServiceSetup: Record 1060 temporary;
        MSPayPalStandardAccount: Record 1070;
        DummyPaymentMethod: Record 289;
        SalesInvoiceHeader: Record 112;
        SalesHeader: Record 36;
        TempPaymentReportingArgument: Record 1062 temporary;
        YourReference: Text[20];
        TargetURL: Text;
    begin
        Initialize();

        // Setup
        CreateDefaultPayPalStandardAccount(MSPayPalStandardAccount);
        CreatePaymentMethod(DummyPaymentMethod, FALSE);
        CreateSalesInvoice(SalesHeader, DummyPaymentMethod);
        YourReference := COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(10, 1), 1, 10);
        SalesHeader.VALIDATE("Your Reference", YourReference);
        SalesHeader.MODIFY();
        PostSalesInvoice(SalesHeader, SalesInvoiceHeader);

        // Exercise
        TempPaymentServiceSetup.CreateReportingArgs(TempPaymentReportingArgument, SalesInvoiceHeader);

        // Verify
        TargetURL := TempPaymentReportingArgument.GetTargetURL();
        Assert.IsTrue(STRPOS(TargetURL, YourReference) > 0, 'Could not find the Your reference in the Target URL');
    end;

    [Test]
    [HandlerFunctions('AccountSetupPageModalPageHandler,ConfirmHandler,SelectPaymentServiceTypeHandler')]
    procedure TestTermsOfService();
    var
        MSPayPalStandardTemplate: Record 1071;
        PaymentServices: TestPage 1060;
        EnableServiceWhenClosingCard: Boolean;
    begin
        // Setup
        Initialize();

        // Execute
        PaymentServices.OPENEDIT();
        LibraryVariableStorage.Enqueue(PayPalStandardNameTxt);
        SetParametersToUpdateSetupPage(FALSE, '', '', FALSE, FALSE, '', '');
        EnableServiceWhenClosingCard := FALSE;
        LibraryVariableStorage.Enqueue(EnableServiceWhenClosingCard);

        PaymentServices.NewAction.INVOKE();
        PaymentServices.FILTER.SETFILTER(Name, PayPalAccountPrefixTxt + '*');

        // Verify
        MSPayPalStandardTemplate.FINDFIRST();
        Assert.AreNotEqual('', MSPayPalStandardTemplate."Terms of Service", 'Terms of service are not set on the template');
        Assert.AreEqual(
          MSPayPalStandardTemplate."Terms of Service", PaymentServices."Terms of Service".VALUE(),
          'Terms of service are not set on the page');
    end;

    [Test]
    procedure TestInsertDemoPayPalAccount();
    var
        MSPayPalStandardTemplate: Record 1071;
        MSPayPalStandardAccount: Record 1070;
        MSPayPalCreateDemoData: Codeunit 1072;
    begin
        // Setup
        Initialize();
        MSPayPalStandardTemplate.DELETEALL();

        // Execute
        MSPayPalCreateDemoData.InsertDemoData();

        // Verify
        MSPayPalStandardTemplate.GET();
        MSPayPalStandardTemplate.CALCFIELDS("Target URL");
        Assert.IsTrue(
          STRPOS(LOWERCASE(MSPayPalStandardTemplate.GetTargetURL()), 'sandbox') > 0, 'URL should be pointing to SandBox account');

        Assert.AreEqual(1, MSPayPalStandardAccount.COUNT(), 'There should be one account present');
        MSPayPalStandardAccount.FINDFIRST();
        Assert.IsTrue(STRPOS(LOWERCASE(MSPayPalStandardAccount.Name), 'sandbox') > 0, 'Name should contain SandBox in the name');
        Assert.AreEqual(TRUE, MSPayPalStandardAccount."Always Include on Documents", 'Always include on documents should be set to true');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestInsertDemoPayPalAccountDoesNothingIfTheAccountExist();
    var
        MSPayPalStandardTemplate: Record 1071;
        MSPayPalStandardAccount: Record 1070;
        CompanyInformation: Record 79;
        MSPayPalCreateDemoData: Codeunit 1072;
    begin
        Initialize();

        CompanyInformation.GET();
        CompanyInformation."Demo Company" := FALSE;
        CompanyInformation.MODIFY();

        // Setup
        CreateDefaultTemplate();
        CreateDefaultPayPalStandardAccount(MSPayPalStandardAccount);

        // Execute
        MSPayPalCreateDemoData.InsertDemoData();

        // Verify
        MSPayPalStandardTemplate.GET();
        MSPayPalStandardTemplate.CALCFIELDS("Target URL");
        Assert.IsTrue(
          STRPOS(LOWERCASE(MSPayPalStandardTemplate.GetTargetURL()), 'sandbox') = 0, 'URL should not be pointing to SandBox account');

        Assert.AreEqual(1, MSPayPalStandardAccount.COUNT(), 'There should be one account present');
        MSPayPalStandardAccount.FINDFIRST();
        Assert.IsTrue(STRPOS(LOWERCASE(MSPayPalStandardAccount.Name), 'sandbox') = 0, 'Name should not contain SandBox in the name');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestWebhookIsCreatedWhenSettingupAccount();
    var
        MSPayPalStandardAccount: Record 1070;
        WebhookSubscription: Record 2000000199;
        PayPalStandardSetup: TestPage 1070;
    begin
        Initialize();
        CreatePayPalStandardAccount(MSPayPalStandardAccount);

        PayPalStandardSetup.OPENEDIT();
        LibraryVariableStorage.Enqueue(ExchangeWithExternalServicesMsg);
        PayPalStandardSetup.Enabled.SETVALUE(TRUE);
        PayPalStandardSetup.CLOSE();

        WebhookSubscription.SETRANGE("Subscription ID", MSPayPalStandardAccount."Account ID");
        WebhookSubscription.SETFILTER("Created By", StrSubstNo('*%1*', PayPalCreatedByTok));

        Assert.IsTrue(
          NOT WebhookSubscription.IsEmpty(),
          STRSUBSTNO(WebhookUpdateSubscriptionErrorTxt, MSPayPalStandardAccount."Account ID"));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestWebhookIsUpdatedAfterModifyingAccount();
    var
        MSPayPalStandardAccount: Record 1070;
        WebhookSubscription: Record 2000000199;
        PayPalStandardSetup: TestPage 1070;
        newAcountId: Text[250];
    begin
        Initialize();
        CreateDefaultPayPalStandardAccount(MSPayPalStandardAccount);

        newAcountId := CopyStr(MSPayPalStandardAccount."Account ID" + '1', 1, 250);

        PayPalStandardSetup.OPENEDIT();
        PayPalStandardSetup."Account ID".SETVALUE(newAcountId);
        PayPalStandardSetup.CLOSE();

        WebhookSubscription.SETRANGE("Subscription ID", newAcountId);
        WebhookSubscription.SETFILTER("Created By", StrSubstNo('*%1*', PayPalCreatedByTok));

        Assert.IsTrue(
          NOT WebhookSubscription.IsEmpty(),
          STRSUBSTNO(WebhookCreateSubscriptionErrorTxt, newAcountId));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure TestWebhookIsDeletedAfterModifyingAccountToEmpty();
    var
        MSPayPalStandardAccount: Record 1070;
        WebhookSubscription: Record 2000000199;
        PayPalStandardSetup: TestPage 1070;
    begin
        Initialize();
        CreateDefaultPayPalStandardAccount(MSPayPalStandardAccount);

        LibraryVariableStorage.Enqueue(TRUE);

        PayPalStandardSetup.OPENEDIT();
        PayPalStandardSetup.Enabled.SETVALUE(FALSE);
        PayPalStandardSetup."Account ID".SETVALUE('');
        PayPalStandardSetup.CLOSE();

        WebhookSubscription.SETRANGE("Subscription ID", MSPayPalStandardAccount."Account ID");
        WebhookSubscription.SETFILTER("Created By", '*%1*', PayPalCreatedByTok);

        Assert.IsFalse(
          NOT WebhookSubscription.IsEmpty(),
          STRSUBSTNO(WebhookDeleteSubscriptionErrorTxt, MSPayPalStandardAccount."Account ID"));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestPaymentNotificationUrlIsIncludedInTheLink();
    var
        TempPaymentServiceSetup: Record 1060 temporary;
        MSPayPalStandardAccount: Record 1070;
        SalesInvoiceHeader: Record 112;
        TempPaymentReportingArgument: Record 1062 temporary;
        TypeHelper: Codeunit "Type Helper";
        NotifyUri: Text;
        TargetURL: Text;
        NotifyURL: Text;
    begin
        Initialize();

        SetupPaymentNotification(MSPayPalStandardAccount, SalesInvoiceHeader);

        // Exercise
        TempPaymentServiceSetup.CreateReportingArgs(TempPaymentReportingArgument, SalesInvoiceHeader);

        TempPaymentReportingArgument.SetRange("Payment Service ID", TempPaymentReportingArgument.GetPayPalServiceID());
        TempPaymentReportingArgument.FindFirst();

        // Verify
        TargetURL := TempPaymentReportingArgument.GetTargetURL();
        NotifyUri := GetPaymentNotificationURL();
        NotifyURL := STRSUBSTNO(NotifyUrlParamTxt, TypeHelper.UriEscapeDataString(NotifyUri));
        Assert.IsTrue(STRPOS(TargetURL, NotifyURL) > 0, NotifyUrlErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestPaymentNotificationDoesNothingIfPendingStatus();
    var
        MSPayPalStandardAccount: Record 1070;
        SalesInvoiceHeader: Record 112;
        TempPaymentRegistrationBuffer: Record 981 temporary;
        O365SalesInvoicePayment: Codeunit 2105;
    begin
        Initialize();

        SetupPaymentNotification(MSPayPalStandardAccount, SalesInvoiceHeader);

        // Exercise
        SendPaymentNotification(MSPayPalStandardAccount."Account ID", PaymentStatusPendingTxt, SalesInvoiceHeader."No.",
          SalesInvoiceHeader."Currency Code", SalesInvoiceHeader."Amount Including VAT");
        O365SalesInvoicePayment.CollectRemainingPayments(SalesInvoiceHeader."No.", TempPaymentRegistrationBuffer);

        // Verify
        VerifyRemainingAmount(TempPaymentRegistrationBuffer, SalesInvoiceHeader."Amount Including VAT");
        VerifyNoPaymentEvent();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestPaymentNotificationDoesNothingIfMissingInvoice();
    var
        MSPayPalStandardAccount: Record 1070;
        SalesInvoiceHeader: Record 112;
        TempPaymentRegistrationBuffer: Record 981 temporary;
        O365SalesInvoicePayment: Codeunit 2105;
    begin
        Initialize();

        SetupPaymentNotification(MSPayPalStandardAccount, SalesInvoiceHeader);

        // Exercise
        ASSERTERROR SendPaymentNotification(
            MSPayPalStandardAccount."Account ID", PaymentStatusCompletedTxt, MissingInvoiceNumberTxt,
            SalesInvoiceHeader."Currency Code", SalesInvoiceHeader."Amount Including VAT");
        O365SalesInvoicePayment.CollectRemainingPayments(SalesInvoiceHeader."No.", TempPaymentRegistrationBuffer);

        // Verify
        VerifyRemainingAmount(TempPaymentRegistrationBuffer, SalesInvoiceHeader."Amount Including VAT");
        VerifyNoPaymentEvent();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestPaymentNotificationMarksInvoiceAsPartlyPaid();
    var
        MSPayPalStandardAccount: Record 1070;
        SalesInvoiceHeader: Record 112;
        TempPaymentRegistrationBuffer: Record 981 temporary;
        O365SalesInvoicePayment: Codeunit 2105;
        RemainingAmount: Decimal;
        ReceivedAmount: Decimal;
    begin
        Initialize();

        SetupPaymentNotification(MSPayPalStandardAccount, SalesInvoiceHeader);

        // Exercise
        RemainingAmount := 0.01;
        ReceivedAmount := SalesInvoiceHeader."Amount Including VAT" - RemainingAmount;
        SendPaymentNotification(MSPayPalStandardAccount."Account ID", PaymentStatusCompletedTxt, SalesInvoiceHeader."No.",
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
        MSPayPalStandardAccount: Record 1070;
        SalesInvoiceHeader: Record 112;
        TempPaymentRegistrationBuffer: Record 981 temporary;
        O365SalesInvoicePayment: Codeunit 2105;
    begin
        Initialize();

        SetupPaymentNotification(MSPayPalStandardAccount, SalesInvoiceHeader);

        // Exercise
        SendPaymentNotification(MSPayPalStandardAccount."Account ID", PaymentStatusCompletedTxt, SalesInvoiceHeader."No.",
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
        MSPayPalStandardAccount: Record 1070;
        SalesInvoiceHeader: Record 112;
        TempPaymentRegistrationBuffer: Record 981 temporary;
        O365SalesInvoicePayment: Codeunit 2105;
        ReceivedAmount: Decimal;
    begin
        Initialize();

        SetupPaymentNotification(MSPayPalStandardAccount, SalesInvoiceHeader);

        // Exercise
        ReceivedAmount := SalesInvoiceHeader."Amount Including VAT" + 100;
        SendPaymentNotification(MSPayPalStandardAccount."Account ID", PaymentStatusCompletedTxt, SalesInvoiceHeader."No.",
          SalesInvoiceHeader."Currency Code", ReceivedAmount);
        O365SalesInvoicePayment.CollectRemainingPayments(SalesInvoiceHeader."No.", TempPaymentRegistrationBuffer);

        // Verify
        VerifyRemainingAmount(TempPaymentRegistrationBuffer, SalesInvoiceHeader."Amount Including VAT");
        VerifyPaymentEvent(OverpaymentTok, SalesInvoiceHeader."No.", ReceivedAmount);
    end;

    local procedure SetupPaymentNotification(var MSPayPalStandardAccount: Record 1070; var SalesInvoiceHeader: Record 112);
    var
        SalesHeader: Record 36;
        DummyPaymentMethod: Record 289;
    begin
        CreateDefaultPayPalStandardAccount(MSPayPalStandardAccount);
        SetupWebhookSubscription(MSPayPalStandardAccount."Account ID");
        CreatePaymentMethod(DummyPaymentMethod, FALSE);
        CreateSalesInvoice(SalesHeader, DummyPaymentMethod);
        SalesHeader.CALCFIELDS("Amount Including VAT");
        SalesHeader.MODIFY(FALSE);
        PostSalesInvoice(SalesHeader, SalesInvoiceHeader);
        SalesInvoiceHeader.CALCFIELDS("Amount Including VAT");
        SalesInvoiceHeader.MODIFY(FALSE);
    end;

    local procedure SetupWebhookSubscription(AccountID: Text);
    var
        WebhookSubscription: Record 2000000199;
        WebhookManagement: Codeunit 5377;
        WebHooksAdapterUri: Text[250];
    begin
        WebHooksAdapterUri := WebhookManagement.GetNotificationUrl();
        IF WebhookSubscription.GET(AccountID, WebHooksAdapterUri) THEN
            EXIT;
        WebhookSubscription.INIT();
        WebhookSubscription.VALIDATE("Subscription ID", COPYSTR(AccountID, 1, MAXSTRLEN(WebhookSubscription."Subscription ID")));
        WebhookSubscription.VALIDATE(Endpoint, WebHooksAdapterUri);
        WebhookSubscription.VALIDATE("Created By", PayPalCreatedByTok);
        WebhookSubscription.INSERT();
    end;

    local procedure GetPaymentNotificationURL(): Text;
    var
        WebhookManagement: Codeunit 5377;
        NotifyURL: Text;
    begin
        NotifyURL := WebhookManagement.GetNotificationUrl();
        EXIT(NotifyURL);
    end;

    local procedure GetPaymentNotificationData(Receiver: Text; PaymentStatus: Text; InvoiceNo: Code[20]; Currency: Code[10]; Amount: Decimal): Text;
    var
        Notification: Text;
        TransactionId: Text;
    begin
        TransactionId := COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(13, 1), 1, 13);
        IF Currency = '' THEN
            Currency := GetDefaultCurrencyCode();
        Notification := STRSUBSTNO(NotificationTemplateTxt, InvoiceNo, Currency, FORMAT(Amount, 0, 9), Receiver, PaymentStatus, TransactionId);
        EXIT(Notification);
    end;

    local procedure SendPaymentNotification(Receiver: Text; PaymentStatus: Text; InvoiceNo: Code[20]; Currency: Code[10]; Amount: Decimal);
    var
        WebhookNotification: Record 2000000194;
        OutStream: OutStream;
        NotificationJson: Text;
    begin
        NotificationJson := GetPaymentNotificationData(Receiver, PaymentStatus, InvoiceNo, Currency, Amount);
        WebhookNotification.INIT();
        WebhookNotification.VALIDATE(ID, CREATEGUID());
        WebhookNotification.VALIDATE("Subscription ID", COPYSTR(Receiver, 1, MAXSTRLEN(WebhookNotification."Subscription ID")));
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

    local procedure VerifyNoPaymentEvent();
    begin
        MSPayPalStdMockEvents.AssertEmpty();
    end;

    local procedure VerifyPaymentEvent(ExpectedEventType: Code[20]; ExpectedInvoiceNo: Code[20]; ExpectedAmountReceived: Decimal);
    var
        ActualEventType: Code[20];
        ActualInvoiceNo: Code[20];
        ActualAmountReceived: Decimal;
    begin
        MSPayPalStdMockEvents.DequeueEvent(ActualEventType, ActualInvoiceNo, ActualAmountReceived);
        Assert.AreEqual(ExpectedEventType, ActualEventType, IncorrectPaymentDetailsErr);
        Assert.AreEqual(ExpectedInvoiceNo, ActualInvoiceNo, IncorrectPaymentDetailsErr);
        Assert.AreEqual(ExpectedAmountReceived, ActualAmountReceived, IncorrectPaymentDetailsErr);
        MSPayPalStdMockEvents.AssertEmpty();
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

    local procedure ModifyPayPalTemplate(var NewName: Text; var NewDescription: Text);
    var
        MSPayPalStandardSetup: TestPage 1070;
        MSPayPalStandardTemplate: TestPage 1071;
        EnableServiceWhenClosingCard: Boolean;
    begin
        MSPayPalStandardSetup.OPENEDIT();
        MSPayPalStandardTemplate.TRAP();
        MSPayPalStandardSetup.SetupTemplate.INVOKE();
        EnableServiceWhenClosingCard := FALSE;
        LibraryVariableStorage.Enqueue(EnableServiceWhenClosingCard);

        NewName := LibraryUtility.GenerateRandomAlphabeticText(20, 0);
        NewDescription := LibraryUtility.GenerateRandomAlphabeticText(20, 0);

        MSPayPalStandardTemplate.Name.SETVALUE(NewName);
        MSPayPalStandardTemplate.Description.SETVALUE(NewDescription);
        MSPayPalStandardTemplate.TargetURL.SETVALUE(NewTargetURLTxt);
        MSPayPalStandardTemplate.LogoURL.SETVALUE(NewLogoURLTxt);
        MSPayPalStandardTemplate.OK().INVOKE();

        MSPayPalStandardSetup.CLOSE();
    end;

    local procedure SetParametersToUpdateSetupPage(UpdatePage: Boolean; NewName: Text; NewDescription: Text; Enabled: Boolean; AlwaysIncludeOnDocument: Boolean; AccountID: Text; TargetURL: Text);
    begin
        LibraryVariableStorage.Enqueue(UpdatePage);

        IF NOT UpdatePage THEN
            EXIT;

        LibraryVariableStorage.Enqueue(NewName);
        LibraryVariableStorage.Enqueue(NewDescription);
        LibraryVariableStorage.Enqueue(Enabled);
        LibraryVariableStorage.Enqueue(AlwaysIncludeOnDocument);
        LibraryVariableStorage.Enqueue(AccountID);
        LibraryVariableStorage.Enqueue(TargetURL);

        IF Enabled then
            LibraryVariableStorage.Enqueue(ExchangeWithExternalServicesMsg);

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

    local procedure CreatePayPalStandardAccount(var MSPayPalStandardAccount: Record 1070);
    var
        MSPayPalStandardTemplate: Record 1071;
        MSPayPalStandardMgt: Codeunit 1070;
    begin
        MSPayPalStandardMgt.GetTemplate(MSPayPalStandardTemplate);
        MSPayPalStandardAccount.INIT();
        MSPayPalStandardAccount.TRANSFERFIELDS(MSPayPalStandardTemplate, FALSE);
        MSPayPalStandardAccount.VALIDATE(Name, COPYSTR(PayPalAccountPrefixTxt + LibraryUtility.GenerateRandomAlphabeticText(30, 1),
            1, MAXSTRLEN(MSPayPalStandardAccount.Name)));
        MSPayPalStandardAccount.VALIDATE(Description, COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(30, 0),
            1, MAXSTRLEN(MSPayPalStandardAccount.Description)));
        MSPayPalStandardAccount.VALIDATE("Account ID", COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(30, 0),
            1, MAXSTRLEN(MSPayPalStandardAccount."Account ID")));
        MSPayPalStandardAccount.INSERT(TRUE);
    end;

    local procedure EnablePayPalStandardAccount(var MSPayPalStandardAccount: Record 1070);
    begin
        MSPayPalStandardAccount.VALIDATE(Enabled, TRUE);
        MSPayPalStandardAccount.MODIFY(TRUE);
    end;

    local procedure CreateDefaultPayPalStandardAccount(var DefaultMSPayPalStandardAccount: Record 1070);
    begin
        CreatePayPalStandardAccount(DefaultMSPayPalStandardAccount);
        EnablePayPalStandardAccount(DefaultMSPayPalStandardAccount);
        LibraryVariableStorage.Enqueue(UpdateOpenInvoicesManuallyTxt);
        DefaultMSPayPalStandardAccount.VALIDATE("Always Include on Documents", TRUE);
        DefaultMSPayPalStandardAccount.MODIFY(TRUE);
    end;

    local procedure CreateAndPostSalesInvoice(var SalesInvoiceHeader: Record 112; PaymentMethod: Record 289);
    var
        SalesHeader: Record 36;
    begin
        CreateSalesInvoice(SalesHeader, PaymentMethod);
        PostSalesInvoice(SalesHeader, SalesInvoiceHeader);
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

    local procedure CreateDefaultTemplate();
    var
        MSPayPalStandardTemplate: Record 1071;
        MSPayPalStandardMgt: Codeunit 1070;
    begin
        MSPayPalStandardTemplate.DELETEALL();

        MSPayPalStandardTemplate.INIT();
        MSPayPalStandardTemplate.INSERT();
        MSPayPalStandardMgt.TemplateAssignDefaultValues(MSPayPalStandardTemplate);
        CLEAR(MSPayPalStandardTemplate."Logo URL");
        MSPayPalStandardTemplate.MODIFY();
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

    local procedure VerifyPayPalAccountRecord(MSPayPalStandardAccount: Record 1070; ExpectedMSPayPalStandardAccount: Record 1070);
    var
        ExpectedTargetURL: Text;
        ActualTargetURL: Text;
    begin
        Assert.AreEqual(ExpectedMSPayPalStandardAccount.Name, MSPayPalStandardAccount.Name, 'Wrong value set for Name');
        Assert.AreEqual(
          ExpectedMSPayPalStandardAccount.Description, MSPayPalStandardAccount.Description, 'Wrong value set for Description');
        Assert.AreEqual(ExpectedMSPayPalStandardAccount.Enabled, MSPayPalStandardAccount.Enabled, 'Wrong value set for Enabled');
        Assert.AreEqual(
          ExpectedMSPayPalStandardAccount."Always Include on Documents", MSPayPalStandardAccount."Always Include on Documents",
          'Wrong value set for Always Include on Documents');
        Assert.AreEqual(
          LOWERCASE(ExpectedMSPayPalStandardAccount."Account ID"), LOWERCASE(MSPayPalStandardAccount."Account ID"),
          'Wrong value set for Account ID');

        ExpectedTargetURL := ExpectedMSPayPalStandardAccount.GetTargetURL();
        ActualTargetURL := MSPayPalStandardAccount.GetTargetURL();
        Assert.AreEqual(ExpectedTargetURL, ActualTargetURL, 'Wrong value set for Always Include on Documents');
    end;

    local procedure VerifyPayPalTemplate(MSPayPalStandardTemplate: Record 1071; NewName: Text; NewDescription: Text; ExpectedTargetURL: Text; ExpectedLogoURL: Text);
    var
        ActualTargetURL: Text;
        ActualLogoURL: Text;
    begin
        Assert.AreEqual(NewName, MSPayPalStandardTemplate.Name, 'Wrong value set for Name');
        Assert.AreEqual(NewDescription, MSPayPalStandardTemplate.Description, 'Wrong value set for Description');

        ActualTargetURL := MSPayPalStandardTemplate.GetTargetURL();
        Assert.AreEqual(ExpectedTargetURL, ActualTargetURL, 'Wrong value set for target URL');

        ActualLogoURL := MSPayPalStandardTemplate.GetLogoURL();
        Assert.AreEqual(ExpectedLogoURL, ActualLogoURL, 'Wrong value set for Logo URL Txt');
    end;

    local procedure VerifyPaymentServiceIsShownOnServiceConnectionsPage(MSPayPalStandardAccount: Record 1070);
    var
        ServiceConnection: Record 1400;
        ServiceConnections: TestPage 1279;
    begin
        ServiceConnections.OPENEDIT();
        ServiceConnections.FILTER.SETFILTER(Name, MSPayPalStandardAccount.Description);

        Assert.AreEqual(
          MSPayPalStandardAccount.Description, ServiceConnections.Name.VALUE(),
          'Description was not set correctly on Service Connections page');

        IF MSPayPalStandardAccount.Enabled THEN
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
            ValueFound := COPYSTR(PaymentReportingArgument.GetTargetURL(), 1, 250) = XMLBuffer.Value;
            if ValueFound then
                break;
        UNTIL XMLBuffer.NEXT() = 0;
        Assert.IsTrue(ValueFound, 'Cound not find target URL');
        XMLBuffer.SETRANGE("Parent Entry No.", XMLBuffer."Parent Entry No.");
        XMLBuffer.SETRANGE(Name, 'PaymentServiceURLText');
        XMLBuffer.FIND('-');
        Assert.AreEqual(PaymentReportingArgument."URL Caption", XMLBuffer.Value, '');
        XMLBuffer.NEXT();
    end;

    local procedure VerifyPayPalURL(var PaymentReportingArgument: Record 1062; MSPayPalStandardAccount: Record 1070; SalesInvoiceHeader: Record 112);
    var
        GeneralLedgerSetup: Record 98;
        TargetURL: Text;
        BaseURL: Text;
    begin
        TargetURL := PaymentReportingArgument.GetTargetURL();
        BaseURL := MSPayPalStandardAccount.GetTargetURL();

        SalesInvoiceHeader.CALCFIELDS("Amount Including VAT");
        Assert.IsTrue(STRPOS(TargetURL, BaseURL) > 0, 'Base url was not set correctly');
        Assert.IsTrue(STRPOS(TargetURL, SalesInvoiceHeader."No.") > 0, 'Document No. was not set correctly');
        Assert.IsTrue(STRPOS(TargetURL, MSPayPalStandardAccount."Account ID") > 0, 'Account ID was not set correctly');
        Assert.IsTrue(STRPOS(TargetURL, FORMAT(SalesInvoiceHeader."Amount Including VAT", 0, 9)) > 0, 'Total amount was not set correctly');

        GeneralLedgerSetup.GET();
        Assert.IsTrue(
          STRPOS(TargetURL, GeneralLedgerSetup.GetCurrencyCode(SalesInvoiceHeader."Currency Code")) > 0,
          'Currency Code was not set correctly');
    end;

    local procedure VerifyBodyText(MSPayPalStandardAccount: Record 1070; SalesInvoiceHeader: Record 112);
    var
        GeneralLedgerSetup: Record 98;
        BaseURL: Text;
        BodyHTMLText: Text;
    begin
        BaseURL := MSPayPalStandardAccount.GetTargetURL();
        SalesInvoiceHeader.CALCFIELDS("Amount Including VAT");
        BodyHTMLText := LibraryVariableStorage.DequeueText();
        Assert.IsTrue(STRPOS(BodyHTMLText, BaseURL) > 0, 'Base url was not set correctly');
        Assert.IsTrue(STRPOS(BodyHTMLText, SalesInvoiceHeader."No.") > 0, 'Document No. was not set correctly');
        Assert.IsTrue(STRPOS(BodyHTMLText, MSPayPalStandardAccount."Account ID") > 0, 'Account ID was not set correctly');
        Assert.IsTrue(
          STRPOS(BodyHTMLText, FORMAT(SalesInvoiceHeader."Amount Including VAT", 0, 9)) > 0, 'Total amount was not set correctly');

        GeneralLedgerSetup.GET();
        Assert.IsTrue(
          STRPOS(BodyHTMLText, GeneralLedgerSetup.GetCurrencyCode(SalesInvoiceHeader."Currency Code")) > 0,
          'Currency Code was not set correctly');
    end;

    [ModalPageHandler]
    procedure AccountSetupPageModalPageHandler(var PayPalStandardSetup: TestPage 1070);
    var
        NewName: Text;
        NewDescription: Text;
        AccountID: Text;
        TargetURL: Text;
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
        TargetURL := LibraryVariableStorage.DequeueText();

        PayPalStandardSetup.Name.SETVALUE(NewName);
        PayPalStandardSetup.Description.SETVALUE(NewDescription);
        PayPalStandardSetup."Account ID".SETVALUE(AccountID);

        PayPalStandardSetup.Enabled.SETVALUE(Enabled);
        PayPalStandardSetup."Always Include on Documents".SETVALUE(AlwaysIncludeOnDocument);
        PayPalStandardSetup.TargetURL.SETVALUE(TargetURL);
        PayPalStandardSetup.OK().INVOKE();
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
            END else
                SelectPaymentService.Available.SETVALUE(NOT NewAvailable);
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
    procedure MessageHandler(Message: Text[1024]);
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Message);
    end;

    [ModalPageHandler]
    procedure EMailDialogHandler(var EMailDialog: TestPage "Email Dialog");
    begin
        LibraryVariableStorage.Enqueue(EMailDialog.BodyText.VALUE());
    end;

    [ModalPageHandler]
    procedure EmailEditorHandler(var EmailEditor: TestPage "Email Editor");
    begin
        LibraryVariableStorage.Enqueue(EmailEditor.BodyField.Value());
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure CloseEmailEditorHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 1;
    end;

    local procedure BindActiveDirectoryMockEvents();
    begin
        IF ActiveDirectoryMockEvents.Enabled() THEN
            EXIT;
        BINDSUBSCRIPTION(ActiveDirectoryMockEvents);
        ActiveDirectoryMockEvents.Enable();
    end;

    LOCAL PROCEDURE SetPaymentRegistrationSetup();
    VAR
        PaymentRegistrationSetup: Record 980;
    BEGIN
        WITH PaymentRegistrationSetup DO BEGIN
            DeleteAll();
            INIT();
            "User ID" := CopyStr(USERID(), 1, MaxStrLen("User ID"));
            "Bal. Account No." := LibraryERM.CreateGLAccountNo();
            "Bal. Account Type" := "Bal. Account Type"::"G/L Account";
            "Journal Template Name" := CreateGenJournalTemplate();
            "Journal Batch Name" := CreateGenJournalBatch("Journal Template Name");
            "Auto Fill Date Received" := FALSE;
            "Use this Account as Def." := TRUE;
            INSERT();
        END;
    END;

    LOCAL PROCEDURE CreateGenJournalTemplate(): Code[10];
    VAR
        GenJournalTemplate: Record 80;
    BEGIN
        GenJournalTemplate.INIT();
        GenJournalTemplate.Name := LibraryUtility.GenerateRandomCode(GenJournalTemplate.FIELDNO(Name), DATABASE::"Gen. Journal Template");
        GenJournalTemplate."Source Code" := LibraryERM.FindGeneralJournalSourceCode();
        GenJournalTemplate.INSERT();
        EXIT(GenJournalTemplate.Name);
    END;

    LOCAL PROCEDURE CreateGenJournalBatch(TemplateName: Code[10]): Code[10];
    VAR
        GenJournalBatch: Record 232;
    BEGIN
        GenJournalBatch.INIT();
        GenJournalBatch."Journal Template Name" := TemplateName;
        GenJournalBatch.Name := LibraryUtility.GenerateRandomCode(GenJournalBatch.FIELDNO(Name), DATABASE::"Gen. Journal Batch");
        GenJournalBatch."No. Series" := LibraryERM.CreateNoSeriesCode();
        GenJournalBatch.INSERT();
        EXIT(GenJournalBatch.Name);
    END;

    [ModalPageHandler]
    PROCEDURE SelectPaymentServiceTypeHandler(VAR SelectPaymentServiceType: TestPage 1062);
    VAR
        ServiceName: Text;
    BEGIN
        ServiceName := LibraryVariableStorage.DequeueText();
        SelectPaymentServiceType.FILTER.SETFILTER(Name, ServiceName);
        SelectPaymentServiceType.FIRST();
        SelectPaymentServiceType.OK().INVOKE();
    END;

}

