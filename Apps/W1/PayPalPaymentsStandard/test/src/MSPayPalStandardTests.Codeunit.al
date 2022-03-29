codeunit 139500 "MS - PayPal Standard Tests"
{
    // version Test,ERM,W1,AT,AU,BE,CA,CH,DE,DK,ES,FI,FR,GB,IS,IT,MX,NL,NO,NZ,SE,US

    Subtype = Test;

    TestPermissions = Disabled;

    var
        Assert: Codeunit "Assert";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        MSPayPalStdMockEvents: Codeunit "MS - PayPal Std Mock Events";
        ActiveDirectoryMockEvents: Codeunit "Active Directory Mock Events";
        Initialized: Boolean;
        UpdateOpenInvoicesManuallyTxt: Label 'A link for the PayPal payment service will be included for new sales documents. To add it to existing sales documents, you must manually select it in the Payment Service field on the sales document.';
        ExchangeWithExternalServicesMsg: Label 'This extension uses a third-party payment service from PayPal.';
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
        CompanyInformation: Record "Company Information";
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        MSPayPalTransaction: Record "MS - PayPal Transaction";
        DummySalesHeader: Record "Sales Header";
        DummyPaymentMethod: Record "Payment Method";
        WebhookSubscription: Record "Webhook Subscription";
        WebhookNotification: Record "Webhook Notification";
    begin
        BindActiveDirectoryMockEvents();

        CompanyInformation.GET();
        CompanyInformation."Allow Blank Payment Info." := TRUE;
        CompanyInformation.MODIFY();
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
    [HandlerFunctions('ConsentConfirmYes,MessageHandler')]
    procedure TestWebhookIsCreatedWhenSettingupAccount();
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        WebhookSubscription: Record "Webhook Subscription";
        MSPayPalStandardSetup: TestPage "MS - PayPal Standard Setup";
    begin
        Initialize();
        CreatePayPalStandardAccount(MSPayPalStandardAccount);

        MSPayPalStandardSetup.OPENEDIT();
        LibraryVariableStorage.Enqueue(ExchangeWithExternalServicesMsg);
        MSPayPalStandardSetup.Enabled.SETVALUE(TRUE);
        MSPayPalStandardSetup.CLOSE();

        WebhookSubscription.SETRANGE("Subscription ID", MSPayPalStandardAccount."Account ID");
        WebhookSubscription.SETFILTER("Created By", StrSubstNo('*%1*', PayPalCreatedByTok));

        Assert.IsTrue(
          NOT WebhookSubscription.IsEmpty(),
          STRSUBSTNO(WebhookUpdateSubscriptionErrorTxt, MSPayPalStandardAccount."Account ID"));
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConsentConfirmYes')]
    procedure TestWebhookIsUpdatedAfterModifyingAccount();
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        WebhookSubscription: Record "Webhook Subscription";
        MSPayPalStandardSetup: TestPage "MS - PayPal Standard Setup";
        newAcountId: Text[250];
    begin
        Initialize();
        CreateDefaultPayPalStandardAccount(MSPayPalStandardAccount);

        newAcountId := CopyStr(MSPayPalStandardAccount."Account ID" + '1', 1, 250);

        MSPayPalStandardSetup.OPENEDIT();
        MSPayPalStandardSetup."Account ID".SETVALUE(newAcountId);
        MSPayPalStandardSetup.CLOSE();

        WebhookSubscription.SETRANGE("Subscription ID", newAcountId);
        WebhookSubscription.SETFILTER("Created By", StrSubstNo('*%1*', PayPalCreatedByTok));

        Assert.IsTrue(
          NOT WebhookSubscription.IsEmpty(),
          STRSUBSTNO(WebhookCreateSubscriptionErrorTxt, newAcountId));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler,ConsentConfirmYes')]
    procedure TestWebhookIsDeletedAfterModifyingAccountToEmpty();
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        WebhookSubscription: Record "Webhook Subscription";
        MSPayPalStandardSetup: TestPage "MS - PayPal Standard Setup";
    begin
        Initialize();
        CreateDefaultPayPalStandardAccount(MSPayPalStandardAccount);

        LibraryVariableStorage.Enqueue(TRUE);

        MSPayPalStandardSetup.OPENEDIT();
        MSPayPalStandardSetup.Enabled.SETVALUE(FALSE);
        MSPayPalStandardSetup."Account ID".SETVALUE('');
        MSPayPalStandardSetup.CLOSE();

        WebhookSubscription.SETRANGE("Subscription ID", MSPayPalStandardAccount."Account ID");
        WebhookSubscription.SETFILTER("Created By", '*%1*', PayPalCreatedByTok);

        Assert.IsFalse(
          NOT WebhookSubscription.IsEmpty(),
          STRSUBSTNO(WebhookDeleteSubscriptionErrorTxt, MSPayPalStandardAccount."Account ID"));
    end;

    [Test]
    [HandlerFunctions('AccountSetupPageModalPageHandler,ConfirmHandler,SelectPaymentServiceTypeHandler')]
    procedure TestCreateNewPaymentService();
    var
        ExpectedPaymentServiceSetup: Record "Payment Service Setup";
        PaymentServices: TestPage "Payment Services";
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
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        ExpectedPaymentServiceSetup: Record "Payment Service Setup";
        PaymentServices: TestPage "Payment Services";
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
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        ExpectedMSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        PaymentServices: TestPage "Payment Services";
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
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        ExpectedMSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        PaymentServices: TestPage "Payment Services";
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
    [HandlerFunctions('ConsentConfirmYes')]
    procedure TestCannotEnableWithoutAccountID();
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
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
    [HandlerFunctions('ConsentConfirmYes')]
    procedure TestCannotBlankAccountIDWhenEnabled();
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
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
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        ExpectedPaymentServiceSetup: Record "Payment Service Setup";
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
        PaymentServices: TestPage "Payment Services";
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
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        NewMSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
        MSPayPalStandardTemplateSetupPage: TestPage "MS - PayPal Standard Template";
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
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        NewMSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        CompanyInformation: Record "Company Information";
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
        MSPayPalStandardTemplateSetupPage: TestPage "MS - PayPal Standard Template";
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
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
    begin
        Initialize();

        // Setup
        CreatePayPalStandardAccount(MSPayPalStandardAccount);

        // Verify
        VerifyPaymentServiceIsShownOnServiceConnectionsPage(MSPayPalStandardAccount);
    end;

    [Test]
    [HandlerFunctions('ConsentConfirmYes')]
    procedure TestServiceConnectionListShowsEnabledPaymentServices();
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
    begin
        Initialize();

        // Setup
        CreatePayPalStandardAccount(MSPayPalStandardAccount);
        EnablePayPalStandardAccount(MSPayPalStandardAccount);

        // Verify
        VerifyPaymentServiceIsShownOnServiceConnectionsPage(MSPayPalStandardAccount);
    end;

    [Test]
    [HandlerFunctions('AccountSetupPageModalPageHandler,MessageHandler,ConsentConfirmYes')]
    procedure TestServiceConnectionListOpensPaymentServicesSetupCard();
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        ServiceConnections: TestPage "Service Connections";
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
    [HandlerFunctions('SelectPaymentServiceModalPageHandler,ConsentConfirmYes')]
    procedure TestSelectingStandardPayPalService();
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        SalesHeader: Record "Sales Header";
        DummyPaymentMethod: Record "Payment Method";
        SalesInvoice: TestPage "Sales Invoice";
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
    [HandlerFunctions('MessageHandler,ConsentConfirmYes')]
    procedure TestOnlyOneAlwaysIncludedStandardPayPalService();
    var
        MSPayPalStandardAccount1: Record "MS - PayPal Standard Account";
        MSPayPalStandardAccount2: Record "MS - PayPal Standard Account";
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
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
#pragma warning disable AA0210
        MSPayPalStandardAccount.SETRANGE("Always Include on Documents", TRUE);
#pragma warning restore
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
#pragma warning disable AA0210
        MSPayPalStandardAccount.SETRANGE("Always Include on Documents", TRUE);
#pragma warning restore
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
    [HandlerFunctions('EmailEditorHandler,MessageHandler,CloseEmailEditorHandler,ConsentConfirmYes')]
    procedure TestCoverLetterPaymentLink();
    begin
        TestCoverLetterPaymentLinkInternal();
    end;

    procedure TestCoverLetterPaymentLinkInternal();
    var
        TempPaymentServiceSetup: Record "Payment Service Setup" temporary;
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        DummyPaymentMethod: Record "Payment Method";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempPaymentReportingArgument: Record "Payment Reporting Argument" temporary;
        LibraryWorkflow: Codeunit "Library - Workflow";
        PostedSalesInvoice: TestPage "Posted Sales Invoice";
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
        LibraryWorkflow.SetUpEmailAccount();

        // Exercise
        PostedSalesInvoice.Email.INVOKE();

        // Verify
        if TempPaymentReportingArgument.IsEmpty() then
            Error(PaymentReportArgumentErrorTxt);
        VerifyBodyText(MSPayPalStandardAccount, SalesInvoiceHeader);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConsentConfirmYes')]
    procedure TestYourReferenceIsIncludedInTheLink();
    var
        TempPaymentServiceSetup: Record "Payment Service Setup" temporary;
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        DummyPaymentMethod: Record "Payment Method";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        TempPaymentReportingArgument: Record "Payment Reporting Argument" temporary;
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
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        PaymentServices: TestPage "Payment Services";
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
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        MSPayPalCreateDemoData: Codeunit "MS - PayPal Create Demo Data";
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
    [HandlerFunctions('MessageHandler,ConsentConfirmYes')]
    procedure TestInsertDemoPayPalAccountDoesNothingIfTheAccountExist();
    var
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        CompanyInformation: Record "Company Information";
        MSPayPalCreateDemoData: Codeunit "MS - PayPal Create Demo Data";
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
    [HandlerFunctions('MessageHandler,ConsentConfirmYes')]
    procedure TestPaymentNotificationUrlIsIncludedInTheLink();
    var
        TempPaymentServiceSetup: Record "Payment Service Setup" temporary;
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempPaymentReportingArgument: Record "Payment Reporting Argument" temporary;
        TypeHelper: Codeunit "Type Helper";
        NotifyUri: Text;
        TargetURL: Text;
        NotifyURL: Text;
    begin
        Initialize();

        SetupPaymentNotification(MSPayPalStandardAccount, SalesInvoiceHeader);

        // Exercise
        TempPaymentServiceSetup.CreateReportingArgs(TempPaymentReportingArgument, SalesInvoiceHeader);

#pragma warning disable AA0210
        TempPaymentReportingArgument.SetRange("Payment Service ID", TempPaymentReportingArgument.GetPayPalServiceID());
#pragma warning restore
        TempPaymentReportingArgument.FindFirst();

        // Verify
        TargetURL := TempPaymentReportingArgument.GetTargetURL();
        NotifyUri := GetPaymentNotificationURL();
        NotifyURL := STRSUBSTNO(NotifyUrlParamTxt, TypeHelper.UriEscapeDataString(NotifyUri));
        Assert.IsTrue(STRPOS(TargetURL, NotifyURL) > 0, NotifyUrlErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConsentConfirmYes')]
    procedure TestPaymentNotificationDoesNothingIfPendingStatus();
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempPaymentRegistrationBuffer: Record "Payment Registration Buffer" temporary;
        O365SalesInvoicePayment: Codeunit "O365 Sales Invoice Payment";
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
    [HandlerFunctions('MessageHandler,ConsentConfirmYes')]
    procedure TestPaymentNotificationDoesNothingIfMissingInvoice();
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempPaymentRegistrationBuffer: Record "Payment Registration Buffer" temporary;
        O365SalesInvoicePayment: Codeunit "O365 Sales Invoice Payment";
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
    [HandlerFunctions('MessageHandler,ConsentConfirmYes')]
    procedure TestPaymentNotificationMarksInvoiceAsPartlyPaid();
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempPaymentRegistrationBuffer: Record "Payment Registration Buffer" temporary;
        O365SalesInvoicePayment: Codeunit "O365 Sales Invoice Payment";
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
    [HandlerFunctions('MessageHandler,ConsentConfirmYes')]
    procedure TestPaymentNotificationMarksInvoiceAsFullyPaid();
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempPaymentRegistrationBuffer: Record "Payment Registration Buffer" temporary;
        O365SalesInvoicePayment: Codeunit "O365 Sales Invoice Payment";
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
    [HandlerFunctions('MessageHandler,ConsentConfirmYes')]
    procedure TestPaymentNotificationMarksInvoiceAsOverPaid();
    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempPaymentRegistrationBuffer: Record "Payment Registration Buffer" temporary;
        O365SalesInvoicePayment: Codeunit "O365 Sales Invoice Payment";
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

    local procedure SetupPaymentNotification(var MSPayPalStandardAccount: Record "MS - PayPal Standard Account"; var SalesInvoiceHeader: Record "Sales Invoice Header");
    var
        SalesHeader: Record "Sales Header";
        DummyPaymentMethod: Record "Payment Method";
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
        WebhookSubscription: Record "Webhook Subscription";
        WebhookManagement: Codeunit "Webhook Management";
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
        WebhookManagement: Codeunit "Webhook Management";
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
        WebhookNotification: Record "Webhook Notification";
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

    local procedure VerifyRemainingAmount(var TempPaymentRegistrationBuffer: Record "Payment Registration Buffer" temporary; RemainingAmount: Decimal);
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
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencyCode: Code[10];
    begin
        GeneralLedgerSetup.GET();
        CurrencyCode := GeneralLedgerSetup.GetCurrencyCode(CurrencyCode);
        EXIT(CurrencyCode);
    end;

    local procedure ModifyPayPalTemplate(var NewName: Text; var NewDescription: Text);
    var
        MSPayPalStandardSetup: TestPage "MS - PayPal Standard Setup";
        MSPayPalStandardTemplate: TestPage "MS - PayPal Standard Template";
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

    local procedure CreatePayPalStandardAccount(var MSPayPalStandardAccount: Record "MS - PayPal Standard Account");
    var
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
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

    local procedure EnablePayPalStandardAccount(var MSPayPalStandardAccount: Record "MS - PayPal Standard Account");
    begin
        MSPayPalStandardAccount.VALIDATE(Enabled, TRUE);
        MSPayPalStandardAccount.MODIFY(TRUE);
    end;

    local procedure CreateDefaultPayPalStandardAccount(var DefaultMSPayPalStandardAccount: Record "MS - PayPal Standard Account");
    begin
        CreatePayPalStandardAccount(DefaultMSPayPalStandardAccount);
        EnablePayPalStandardAccount(DefaultMSPayPalStandardAccount);
        LibraryVariableStorage.Enqueue(UpdateOpenInvoicesManuallyTxt);
        DefaultMSPayPalStandardAccount.VALIDATE("Always Include on Documents", TRUE);
        DefaultMSPayPalStandardAccount.MODIFY(TRUE);
    end;

    local procedure CreateAndPostSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header"; PaymentMethod: Record "Payment Method");
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesInvoice(SalesHeader, PaymentMethod);
        PostSalesInvoice(SalesHeader, SalesInvoiceHeader);
    end;

    local procedure PostSalesInvoice(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header");
    begin
        SalesInvoiceHeader.SETAUTOCALCFIELDS(Closed);
        SalesInvoiceHeader.GET(LibrarySales.PostSalesDocument(SalesHeader, TRUE, TRUE));
    end;

    local procedure SetupReportSelections();
    var
        CustomReportLayout: Record "Custom Report Layout";
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.DELETEALL();
        CreateDefaultReportSelection();

        GetCustomBodyLayout(CustomReportLayout);

        ReportSelections.Reset();
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Invoice");
        ReportSelections.FINDFIRST();
        ReportSelections.VALIDATE("Use for Email Attachment", TRUE);
        ReportSelections.VALIDATE("Use for Email Body", TRUE);
        ReportSelections.VALIDATE("Email Body Layout Code", CustomReportLayout.Code);
        ReportSelections.MODIFY(TRUE);
    end;

    local procedure CreateDefaultReportSelection();
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.INIT();
        ReportSelections.Usage := ReportSelections.Usage::"S.Invoice";
        ReportSelections.Sequence := '1';
        ReportSelections."Report ID" := GetReportID();
        ReportSelections.INSERT();
    end;

    local procedure GetReportID(): Integer;
    begin
        EXIT(REPORT::"Standard Sales - Invoice");
    end;

    local procedure GetCustomBodyLayout(var CustomReportLayout: Record "Custom Report Layout");
    begin
        CustomReportLayout.SETRANGE("Report ID", GetReportID());
        CustomReportLayout.SETRANGE(Type, CustomReportLayout.Type::Word);
        CustomReportLayout.SETFILTER(Description, '''@*Email Body*''');
        CustomReportLayout.FINDLAST();
    end;

    local procedure CreateSalesInvoice(var SalesHeader: Record "Sales Header"; PaymentMethod: Record "Payment Method");
    var
        SalesLine: Record "Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
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
        Customer: Record "Customer";
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.VALIDATE("VAT Bus. Posting Group", VATBusPostingGroup);
        Customer.MODIFY(TRUE);
        EXIT(Customer."No.");
    end;

    local procedure CreateItem(VATProdPostingGroup: Code[20]): Code[20];
    var
        Item: Record "Item";
    begin
        LibraryInventory.CreateItem(Item);
        Item.VALIDATE("VAT Prod. Posting Group", VATProdPostingGroup);
        Item.VALIDATE("Unit Price", 1000 + LibraryRandom.RandDec(100, 2));
        Item.VALIDATE("Last Direct Cost", Item."Unit Price");
        Item.MODIFY(TRUE);
        EXIT(Item."No.");
    end;

    local procedure CreatePaymentMethod(var PaymentMethod: Record "Payment Method"; SetBalancingAccount: Boolean);
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
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
    begin
        MSPayPalStandardTemplate.DELETEALL();

        MSPayPalStandardTemplate.INIT();
        MSPayPalStandardTemplate.INSERT();
        MSPayPalStandardMgt.TemplateAssignDefaultValues(MSPayPalStandardTemplate);
        CLEAR(MSPayPalStandardTemplate."Logo URL");
        MSPayPalStandardTemplate.MODIFY();
    end;

    local procedure VerifyPaymentServicePage(PaymentServices: TestPage "Payment Services"; ExpectedPaymentServiceSetup: Record "Payment Service Setup");
    begin
        Assert.AreEqual(ExpectedPaymentServiceSetup.Name, PaymentServices.Name.VALUE(), 'Wrong value set for Name');
        Assert.AreEqual(ExpectedPaymentServiceSetup.Description, PaymentServices.Description.VALUE(), 'Wrong value set for Description');
        Assert.AreEqual(ExpectedPaymentServiceSetup.Enabled, PaymentServices.Enabled.ASBOOLEAN(), 'Wrong value set for Enabled');
        Assert.AreEqual(
          ExpectedPaymentServiceSetup."Always Include on Documents", PaymentServices."Always Include on Documents".ASBOOLEAN(),
          'Wrong value set for Always Include on Documents');
    end;

    local procedure VerifyPayPalAccountRecord(MSPayPalStandardAccount: Record "MS - PayPal Standard Account"; ExpectedMSPayPalStandardAccount: Record "MS - PayPal Standard Account");
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

    local procedure VerifyPayPalTemplate(MSPayPalStandardTemplate: Record "MS - PayPal Standard Template"; NewName: Text; NewDescription: Text; ExpectedTargetURL: Text; ExpectedLogoURL: Text);
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

    local procedure VerifyPaymentServiceIsShownOnServiceConnectionsPage(MSPayPalStandardAccount: Record "MS - PayPal Standard Account");
    var
        ServiceConnection: Record "Service Connection";
        ServiceConnections: TestPage "Service Connections";
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

    local procedure VerifyBodyText(MSPayPalStandardAccount: Record "MS - PayPal Standard Account"; SalesInvoiceHeader: Record "Sales Invoice Header");
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
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
    procedure AccountSetupPageModalPageHandler(var MSPayPalStandardSetup: TestPage "MS - PayPal Standard Setup");
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

        MSPayPalStandardSetup.Name.SETVALUE(NewName);
        MSPayPalStandardSetup.Description.SETVALUE(NewDescription);
        MSPayPalStandardSetup."Account ID".SETVALUE(AccountID);

        MSPayPalStandardSetup.Enabled.SETVALUE(Enabled);
        MSPayPalStandardSetup."Always Include on Documents".SETVALUE(AlwaysIncludeOnDocument);
        MSPayPalStandardSetup.TargetURL.SETVALUE(TargetURL);
        MSPayPalStandardSetup.OK().INVOKE();
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

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ConsentConfirmYes(var CustConsentConfirmation: TestPage "Cust. Consent Confirmation")
    begin
        CustConsentConfirmation.Accept.Invoke();
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
        PaymentRegistrationSetup: Record "Payment Registration Setup";
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
        GenJournalTemplate: Record "Gen. Journal Template";
    BEGIN
        GenJournalTemplate.INIT();
        GenJournalTemplate.Name := LibraryUtility.GenerateRandomCode(GenJournalTemplate.FIELDNO(Name), DATABASE::"Gen. Journal Template");
        GenJournalTemplate."Source Code" := LibraryERM.FindGeneralJournalSourceCode();
        GenJournalTemplate.INSERT();
        EXIT(GenJournalTemplate.Name);
    END;

    LOCAL PROCEDURE CreateGenJournalBatch(TemplateName: Code[10]): Code[10];
    VAR
        GenJournalBatch: Record "Gen. Journal Batch";
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

