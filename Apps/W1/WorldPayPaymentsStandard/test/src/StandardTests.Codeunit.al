codeunit 139505 "MS - WorldPay Standard Tests"
{
    // version Test,ERM,W1,AT,AU,BE,CA,CH,DE,DK,ES,FI,FR,GB,IS,IT,MX,NL,NO,NZ,SE,US

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit "Assert";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        ActiveDirectoryMockEvents: Codeunit "Active Directory Mock Events";
        MSWorldPayStdMockEvents: Codeunit "MS - WorldPay Std Mock Events";
        DatasetFileName: Text;
        Initialized: Boolean;
        UpdateOpenInvoicesManuallyTxt: Label 'A link for the WorldPay payment service will be included for new sales documents. To add it to existing sales documents, you must manually select it in the Payment Service field on the sales document.';
        ServiceNotSetupErr: Label 'You must specify an account ID for this payment service.';
        WorldPayStandardNameTxt: Label 'WorldPay Payments Standard';
        WorldPayStandardDescriptionTxt: Label 'Use the WorldPay Payments Standard service';
        NewTargetURLTxt: Label 'https://localhost:999/test?', Locked = true;
        NewLogoURLTxt: Label 'https://localhost:999/logo', Locked = true;
        SetToDefaultMsg: Label 'Settings have been set to default.';
        WorldPayAccountPrefixTxt: Label 'WorldPay';
        ThirdPartyNoticeMsg: Label 'This extension uses the WorldPay, a third-party provider.';

    local procedure Initialize()
    var
        CompanyInfo: Record "Company Information";
        MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
        MSWorldPayTransaction: Record "MS - WorldPay Transaction";
        DummySalesHeader: Record "Sales Header";
        DummyPaymentMethod: Record "Payment Method";
    begin
        BindActiveDirectoryMockEvents();

        CompanyInfo.GET();
        CompanyInfo."Allow Blank Payment Info." := TRUE;
        CompanyInfo.MODIFY();
        CLEAR(LibraryVariableStorage);

        MSWorldPayStandardAccount.DELETEALL();
        MSWorldPayTransaction.DELETEALL();
        CreateDefaultTemplate();

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(FALSE);

        IF Initialized THEN
            EXIT;

        CreateSalesInvoice(DummySalesHeader, DummyPaymentMethod);
        SetupReportSelections();
        COMMIT();

        BINDSUBSCRIPTION(MSWorldPayStdMockEvents);

        Initialized := TRUE;
    end;

    [Test]
    [HandlerFunctions('AccountSetupPageModalPageHandler,ConfirmHandler,SelectPaymentServiceTypeHandler')]
    procedure TestCreateNewPaymentService()
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
        LibraryVariableStorage.Enqueue(WorldPayStandardNameTxt);
        SetParametersToUpdateSetupPage(ChangeValuesOnSetupPage, '', '', Enabled, AlwaysInclude, '', '');
        LibraryVariableStorage.Enqueue(EnableServiceWhenClosingCard);

        PaymentServices.NewAction.INVOKE();

        // Verify
        ExpectedPaymentServiceSetup.INIT();
        ExpectedPaymentServiceSetup.Name := WorldPayStandardNameTxt;
        ExpectedPaymentServiceSetup.Description := WorldPayStandardDescriptionTxt;
        ExpectedPaymentServiceSetup.Enabled := Enabled;
        ExpectedPaymentServiceSetup."Always Include on Documents" := AlwaysInclude;

        PaymentServices.Filter.SetFilter(Name, ExpectedPaymentServiceSetup.Name);
        PaymentServices.First();

        VerifyPaymentServicePage(PaymentServices, ExpectedPaymentServiceSetup);
    end;

    [Test]
    procedure TestExistingPaymentServicesAreShownInTheList()
    var
        MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
        ExpectedPaymentServiceSetup: Record "Payment Service Setup";
        PaymentServices: TestPage "Payment Services";
    begin
        // Setup
        Initialize();
        CreateWorldPayStandardAccount(MSWorldPayStandardAccount);

        // Execute
        PaymentServices.OPENEDIT();

        // Verify
        ExpectedPaymentServiceSetup.INIT();
        ExpectedPaymentServiceSetup.Name := MSWorldPayStandardAccount.Name;
        ExpectedPaymentServiceSetup.Description := MSWorldPayStandardAccount.Description;
        ExpectedPaymentServiceSetup.Enabled := FALSE;
        ExpectedPaymentServiceSetup."Always Include on Documents" := FALSE;

        PaymentServices.FILTER.SETFILTER(Name, ExpectedPaymentServiceSetup.Name);
        PaymentServices.FIRST();

        VerifyPaymentServicePage(PaymentServices, ExpectedPaymentServiceSetup);
    end;

    [Test]
    [HandlerFunctions('AccountSetupPageModalPageHandler,MessageHandler')]
    procedure TestSetupPaymentService()
    var
        MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
        ExpectedMSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
        PaymentServices: TestPage "Payment Services";
        ChangeValuesOnSetupPage: Boolean;
    begin
        // Setup
        Initialize();
        CreateWorldPayStandardAccount(MSWorldPayStandardAccount);

        // Execute
        PaymentServices.OPENEDIT();
        PaymentServices.FILTER.SETFILTER(Name, WorldPayAccountPrefixTxt + '*');
        ChangeValuesOnSetupPage := TRUE;
        ExpectedMSWorldPayStandardAccount.COPY(MSWorldPayStandardAccount);
        ExpectedMSWorldPayStandardAccount.Enabled := TRUE;
        ExpectedMSWorldPayStandardAccount."Always Include on Documents" := TRUE;
        ExpectedMSWorldPayStandardAccount.Name := COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(20, 0),
            1, MAXSTRLEN(ExpectedMSWorldPayStandardAccount.Name));
        ExpectedMSWorldPayStandardAccount.Description :=
          COPYSTR(LibraryUtility.GenerateRandomText(MAXSTRLEN(MSWorldPayStandardAccount.Description)),
            1, MAXSTRLEN(ExpectedMSWorldPayStandardAccount.Name));
        ExpectedMSWorldPayStandardAccount."Account ID" := COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(20, 0),
            1, MAXSTRLEN(ExpectedMSWorldPayStandardAccount."Account ID"));
        ExpectedMSWorldPayStandardAccount.SetTargetURL(NewTargetURLTxt);

        SetParametersToUpdateSetupPage(ChangeValuesOnSetupPage, ExpectedMSWorldPayStandardAccount.Name,
          ExpectedMSWorldPayStandardAccount.Description, ExpectedMSWorldPayStandardAccount.Enabled,
          ExpectedMSWorldPayStandardAccount."Always Include on Documents",
          ExpectedMSWorldPayStandardAccount."Account ID", NewTargetURLTxt);
        PaymentServices.Setup.INVOKE();

        // Verify
        MSWorldPayStandardAccount.GET(MSWorldPayStandardAccount."Primary Key");
        VerifyWorldPayAccountRecord(MSWorldPayStandardAccount, ExpectedMSWorldPayStandardAccount);
    end;

    [Test]
    [HandlerFunctions('AccountSetupPageModalPageHandler,ConfirmHandler')]
    procedure TestEnablingWhenClosingSetupPage()
    var
        MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
        ExpectedMSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
        PaymentServices: TestPage "Payment Services";
        ChangeValuesOnSetupPage: Boolean;
        EnableServiceWhenClosingCard: Boolean;
    begin
        // Setup
        Initialize();
        CreateWorldPayStandardAccount(MSWorldPayStandardAccount);

        // Execute
        PaymentServices.OPENEDIT();
        PaymentServices.FILTER.SETFILTER(Name, WorldPayAccountPrefixTxt + '*');
        ChangeValuesOnSetupPage := TRUE;
        EnableServiceWhenClosingCard := TRUE;

        ExpectedMSWorldPayStandardAccount.INIT();
        ExpectedMSWorldPayStandardAccount.COPY(MSWorldPayStandardAccount);
        ExpectedMSWorldPayStandardAccount.Enabled := FALSE;
        ExpectedMSWorldPayStandardAccount."Account ID" := COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(20, 0),
            1, MAXSTRLEN(ExpectedMSWorldPayStandardAccount."Account ID"));

        SetParametersToUpdateSetupPage(ChangeValuesOnSetupPage, ExpectedMSWorldPayStandardAccount.Name,
          ExpectedMSWorldPayStandardAccount.Description, ExpectedMSWorldPayStandardAccount.Enabled,
          ExpectedMSWorldPayStandardAccount."Always Include on Documents",
          ExpectedMSWorldPayStandardAccount."Account ID", NewTargetURLTxt);

        LibraryVariableStorage.Enqueue(EnableServiceWhenClosingCard);

        PaymentServices.Setup.INVOKE();

        // Verify
        ExpectedMSWorldPayStandardAccount.Enabled := FALSE;
        MSWorldPayStandardAccount.GET(MSWorldPayStandardAccount."Primary Key");
        VerifyWorldPayAccountRecord(MSWorldPayStandardAccount, ExpectedMSWorldPayStandardAccount);
    end;

    [Test]
    procedure TestCannotEnableWithoutAccountID()
    var
        MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
    begin
        // Setup
        Initialize();
        CreateWorldPayStandardAccount(MSWorldPayStandardAccount);
        MSWorldPayStandardAccount."Account ID" := '';

        // Verify
        ASSERTERROR MSWorldPayStandardAccount.VALIDATE(Enabled, TRUE);
        Assert.ExpectedError(ServiceNotSetupErr);
    end;

    [Test]
    procedure TestCannotBlankAccountIDWhenEnabled()
    var
        MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
    begin
        // Setup
        Initialize();
        CreateWorldPayStandardAccount(MSWorldPayStandardAccount);
        EnableWorldPayStandardAccount(MSWorldPayStandardAccount);

        // Verify
        ASSERTERROR MSWorldPayStandardAccount.VALIDATE("Account ID", '');
        Assert.ExpectedError(ServiceNotSetupErr);
    end;

    [Test]
    [HandlerFunctions('AccountSetupPageModalPageHandler,ConfirmHandler,SelectPaymentServiceTypeHandler')]
    procedure TestEditWorldPayTemplate()
    var
        MSWorldPayStdTemplate: Record "MS - WorldPay Std. Template";
        ExpectedPaymentServiceSetup: Record "Payment Service Setup";
        MSWorldPayStandardMgt: Codeunit "MS - WorldPay Standard Mgt.";
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
        ModifyWorldPayTemplate(NewName, NewDescription);

        MSWorldPayStandardMgt.GetTemplate(MSWorldPayStdTemplate);

        // Verify new template
        VerifyWorldPayTemplate(MSWorldPayStdTemplate, NewName, NewDescription, NewTargetURLTxt, NewLogoURLTxt);

        // Verify template gets applied
        ChangeValuesOnSetupPage := FALSE;
        AlwaysInclude := FALSE;
        Enabled := FALSE;
        EnableServiceWhenClosingCard := true;
        LibraryVariableStorage.Enqueue(NewName);
        SetParametersToUpdateSetupPage(ChangeValuesOnSetupPage, '', '', Enabled, AlwaysInclude, '', '');
        LibraryVariableStorage.Enqueue(EnableServiceWhenClosingCard);

        PaymentServices.OPENEDIT();
        PaymentServices.NewAction.INVOKE();
        PaymentServices.FILTER.SETFILTER(Name, NewName + '*');

        // Verify
        ExpectedPaymentServiceSetup.INIT();
        ExpectedPaymentServiceSetup.Name := MSWorldPayStdTemplate.Name;
        ExpectedPaymentServiceSetup.Enabled := Enabled;
        ExpectedPaymentServiceSetup.Description := MSWorldPayStdTemplate.Description;
        ExpectedPaymentServiceSetup."Always Include on Documents" := AlwaysInclude;

        VerifyPaymentServicePage(PaymentServices, ExpectedPaymentServiceSetup);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmHandler')]
    procedure TestResetToDefaultWorldPayTemplate()
    var
        MSWorldPayStdTemplate: Record "MS - WorldPay Std. Template";
        NewMSWorldPayStdTemplate: Record "MS - WorldPay Std. Template";
        MSWorldPayStandardMgt: Codeunit "MS - WorldPay Standard Mgt.";
        MSWorldPayStdTemplateSetupPage: TestPage "MS - WorldPay Std. Template";
        NewName: Text;
        NewDescription: Text;
        ExpectedTargetURL: Text;
        ExpectedLogoURL: Text;
    begin
        // Setup
        Initialize();
        MSWorldPayStandardMgt.GetTemplate(MSWorldPayStdTemplate);
        ModifyWorldPayTemplate(NewName, NewDescription);

        // Execute
        MSWorldPayStdTemplateSetupPage.OPENEDIT();
        LibraryVariableStorage.Enqueue(SetToDefaultMsg);
        MSWorldPayStdTemplateSetupPage.ResetToDefault.INVOKE();

        // Verify new template
        MSWorldPayStandardMgt.GetTemplate(NewMSWorldPayStdTemplate);
        ExpectedTargetURL := MSWorldPayStdTemplate.GetTargetURL();
        ExpectedLogoURL := MSWorldPayStdTemplate.GetLogoURL();
        VerifyWorldPayTemplate(
          NewMSWorldPayStdTemplate, MSWorldPayStdTemplate.Name, MSWorldPayStdTemplate.Description,
          ExpectedTargetURL, ExpectedLogoURL);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmHandler')]
    procedure TestResetToDefaultWorldPayTemplateInDemoCompany()
    var
        MSWorldPayStdTemplate: Record "MS - WorldPay Std. Template";
        NewMSWorldPayStdTemplate: Record "MS - WorldPay Std. Template";
        CompanyInformation: Record "Company Information";
        MSWorldPayStandardMgt: Codeunit "MS - WorldPay Standard Mgt.";
        MSWorldPayStdTemplateSetupPage: TestPage "MS - WorldPay Std. Template";
        NewName: Text;
        NewDescription: Text;
        ExpectedTargetURL: Text;
        ExpectedLogoURL: Text;
    begin
        // Setup
        Initialize();

        MSWorldPayStandardMgt.GetTemplate(MSWorldPayStdTemplate);
        ModifyWorldPayTemplate(NewName, NewDescription);

        CompanyInformation.GET();
        CompanyInformation."Demo Company" := TRUE;
        CompanyInformation.MODIFY();

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(TRUE);

        // Execute
        MSWorldPayStdTemplateSetupPage.OPENEDIT();
        LibraryVariableStorage.Enqueue(SetToDefaultMsg);
        MSWorldPayStdTemplateSetupPage.ResetToDefault.INVOKE();

        // Verify new template
        MSWorldPayStandardMgt.GetTemplate(NewMSWorldPayStdTemplate);
        ExpectedTargetURL := MSWorldPayStdTemplate.GetTargetURL();
        ExpectedLogoURL := MSWorldPayStdTemplate.GetLogoURL();

        Assert.AreEqual(1, STRPOS(ExpectedTargetURL, MSWorldPayStandardMgt.GetSandboxURL()), 'Wrong position for the target URL');
        VerifyWorldPayTemplate(
          NewMSWorldPayStdTemplate, MSWorldPayStdTemplate.Name, MSWorldPayStdTemplate.Description,
          ExpectedTargetURL, ExpectedLogoURL);
    end;

    [Test]
    procedure TestServiceConnectionListShowsDisabledPaymentServices()
    var
        MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
        ServiceConnections: TestPage "Service Connections";
    begin
        Initialize();

        // Setup
        CreateWorldPayStandardAccount(MSWorldPayStandardAccount);

        // Execute
        ServiceConnections.OPENEDIT();

        // Verify
        VerifyPaymentServiceIsShownOnServiceConnectionsPage(ServiceConnections, MSWorldPayStandardAccount);
    end;

    [Test]
    procedure TestServiceConnectionListShowsEnabledPaymentServices()
    var
        MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
        ServiceConnections: TestPage "Service Connections";
    begin
        Initialize();

        // Setup
        CreateWorldPayStandardAccount(MSWorldPayStandardAccount);
        EnableWorldPayStandardAccount(MSWorldPayStandardAccount);

        // Execute
        ServiceConnections.OPENEDIT();

        // Verify
        VerifyPaymentServiceIsShownOnServiceConnectionsPage(ServiceConnections, MSWorldPayStandardAccount);
    end;

    [Test]
    [HandlerFunctions('AccountSetupPageModalPageHandler,MessageHandler')]
    procedure TestServiceConnectionListOpensPaymentServicesSetupCard()
    var
        MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
        ServiceConnections: TestPage "Service Connections";
    begin
        Initialize();

        // Setup
        CreateWorldPayStandardAccount(MSWorldPayStandardAccount);
        ServiceConnections.OPENEDIT();
        ServiceConnections.FILTER.SETFILTER(Name, MSWorldPayStandardAccount.Description);
        SetParametersToUpdateSetupPage(
          TRUE, MSWorldPayStandardAccount.Name, MSWorldPayStandardAccount.Description, TRUE, TRUE, MSWorldPayStandardAccount."Account ID",
          NewTargetURLTxt);

        // Execute
        ServiceConnections.Setup.INVOKE();

        // Verify
        MSWorldPayStandardAccount.Enabled := TRUE;
        MSWorldPayStandardAccount."Always Include on Documents" := TRUE;
        VerifyPaymentServiceIsShownOnServiceConnectionsPage(ServiceConnections, MSWorldPayStandardAccount);
    end;

    [Test]
    [HandlerFunctions('SelectPaymentServiceModalPageHandler')]
    procedure TestSelectingStandardWorldPayService()
    var
        MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
        SalesHeader: Record "Sales Header";
        DummyPaymentMethod: Record "Payment Method";
        SalesInvoice: TestPage "Sales Invoice";
        NewAvailable: Boolean;
    begin
        // Setup
        Initialize();
        CreateWorldPayStandardAccount(MSWorldPayStandardAccount);
        EnableWorldPayStandardAccount(MSWorldPayStandardAccount);

        CreateSalesInvoice(SalesHeader, DummyPaymentMethod);

        // Execute
        SalesInvoice.OPENEDIT();
        SalesInvoice.GOTORECORD(SalesHeader);

        NewAvailable := TRUE;
        SetParametersToSelectPaymentService(
          FALSE, MSWorldPayStandardAccount.Name, MSWorldPayStandardAccount."Always Include on Documents", NewAvailable);
        SalesInvoice.SelectedPayments.ASSISTEDIT();

        // Verify
        Assert.AreEqual(MSWorldPayStandardAccount.Name, SalesInvoice.SelectedPayments.VALUE(), 'Wrong value was set');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestOnlyOneAlwaysIncludedStandardWorldPayService()
    var
        MSWorldPayStandardAccount1: Record "MS - WorldPay Standard Account";
        MSWorldPayStandardAccount2: Record "MS - WorldPay Standard Account";
        MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
    begin
        // Setup
        Initialize();
        CreateWorldPayStandardAccount(MSWorldPayStandardAccount1);
        EnableWorldPayStandardAccount(MSWorldPayStandardAccount1);

        CreateWorldPayStandardAccount(MSWorldPayStandardAccount2);
        EnableWorldPayStandardAccount(MSWorldPayStandardAccount2);

        // Execute
        LibraryVariableStorage.Enqueue(UpdateOpenInvoicesManuallyTxt);
        MSWorldPayStandardAccount1.VALIDATE("Always Include on Documents", TRUE);
        MSWorldPayStandardAccount1.MODIFY(TRUE);

        // Verify this is the one
        LibraryVariableStorage.Enqueue(UpdateOpenInvoicesManuallyTxt);
        MSWorldPayStandardAccount.SETRANGE("Always Include on Documents", TRUE);
        MSWorldPayStandardAccount.FINDFIRST();
        Assert.AreEqual(1, MSWorldPayStandardAccount.COUNT(), '');

        MSWorldPayStandardAccount2.FIND();
        MSWorldPayStandardAccount1.FIND();
        Assert.IsFalse(MSWorldPayStandardAccount2."Always Include on Documents", 'First Verify');
        Assert.IsTrue(MSWorldPayStandardAccount1."Always Include on Documents", 'First Verify');

        // Execute
        MSWorldPayStandardAccount2.VALIDATE("Always Include on Documents", TRUE);
        MSWorldPayStandardAccount2.MODIFY(TRUE);

        // Verify 2 is now the only one
        MSWorldPayStandardAccount.SETRANGE("Always Include on Documents", TRUE);
        MSWorldPayStandardAccount.FINDFIRST();
        Assert.AreEqual(1, MSWorldPayStandardAccount.COUNT(), '');

        MSWorldPayStandardAccount1.FIND();
        MSWorldPayStandardAccount2.FIND();
        Assert.IsTrue(MSWorldPayStandardAccount2."Always Include on Documents", 'Final Verify');
        Assert.IsFalse(MSWorldPayStandardAccount1."Always Include on Documents", 'Final Verify');
    end;

    [Test]
    [HandlerFunctions('EmailEditorHandler,MessageHandler,CloseEmailEditorHandler')]
    procedure TestCoverLetterPaymentLink();
    begin
        TestCoverLetterPaymentLinkInternal();
    end;

    procedure TestCoverLetterPaymentLinkInternal()
    var
        TempPaymentServiceSetup: Record "Payment Service Setup" temporary;
        MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
        DummyPaymentMethod: Record "Payment Method";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempPaymentReportingArgument: Record "Payment Reporting Argument" temporary;
        LibraryWorkflow: Codeunit "Library - Workflow";
        PostedSalesInvoice: TestPage "Posted Sales Invoice";
    begin
        Initialize();

        // Setup
        CreateDefaultWorldPayStandardAccount(MSWorldPayStandardAccount);
        MSWorldPayStandardAccount.SetTargetURL(NewTargetURLTxt);
        CreatePaymentMethod(DummyPaymentMethod, FALSE);
        CreateAndPostSalesInvoice(SalesInvoiceHeader, DummyPaymentMethod);
        TempPaymentServiceSetup.CreateReportingArgs(TempPaymentReportingArgument, SalesInvoiceHeader);

        TempPaymentReportingArgument.SetRange("Payment Service ID", TempPaymentReportingArgument.GetWorldPayServiceID());
        TempPaymentReportingArgument.FindFirst();

        PostedSalesInvoice.OPENEDIT();
        PostedSalesInvoice.GOTORECORD(SalesInvoiceHeader);

        LibraryWorkflow.SetUpEmailAccount();

        // Exercise
        PostedSalesInvoice.Email.INVOKE();

        // Verify
        TempPaymentReportingArgument.FINDFIRST();
        VerifyBodyText(MSWorldPayStandardAccount, SalesInvoiceHeader);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestYourReferenceIsIncludedInTheLink()
    var
        TempPaymentServiceSetup: Record "Payment Service Setup" temporary;
        MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
        DummyPaymentMethod: Record "Payment Method";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        TempPaymentReportingArgument: Record "Payment Reporting Argument" temporary;
        YourReference: Text[20];
        TargetURL: Text;
    begin
        Initialize();

        // Setup
        CreateDefaultWorldPayStandardAccount(MSWorldPayStandardAccount);
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
    procedure TestTermsOfService()
    var
        MSWorldPayStdTemplate: Record "MS - WorldPay Std. Template";
        PaymentServices: TestPage "Payment Services";
        EnableServiceWhenClosingCard: Boolean;
    begin
        // Setup
        Initialize();

        // Execute
        PaymentServices.OPENEDIT();
        LibraryVariableStorage.Enqueue(WorldPayStandardNameTxt);

        SetParametersToUpdateSetupPage(FALSE, '', '', FALSE, FALSE, '', '');
        EnableServiceWhenClosingCard := FALSE;
        LibraryVariableStorage.Enqueue(EnableServiceWhenClosingCard);

        PaymentServices.NewAction.INVOKE();
        PaymentServices.FILTER.SETFILTER(Name, WorldPayAccountPrefixTxt + '*');

        // Verify
        MSWorldPayStdTemplate.FINDFIRST();
        Assert.AreNotEqual('', MSWorldPayStdTemplate."Terms of Service", 'Terms of service are not set on the template');
        Assert.AreEqual(
          MSWorldPayStdTemplate."Terms of Service", PaymentServices."Terms of Service".VALUE(),
          'Terms of service are not set on the page');
    end;

    [Test]
    procedure TestInsertDemoWorldPayAccount()
    var
        MSWorldPayStdTemplate: Record "MS - WorldPay Std. Template";
        MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
        CompanyInformation: Record "Company Information";
        MSWorldPayCreateDemoData: Codeunit "MS - WorldPay Create Demo Data";
    begin
        // Setup
        Initialize();
        MSWorldPayStdTemplate.DELETEALL();

        CompanyInformation.GET();
        CompanyInformation."Demo Company" := true;
        CompanyInformation.MODIFY();

        // Execute
        MSWorldPayCreateDemoData.InsertDemoDataAndUpgradeBurntIn();

        // Verify
        MSWorldPayStdTemplate.GET();
        MSWorldPayStdTemplate.CALCFIELDS("Target URL");
        Assert.IsTrue(
        STRPOS(LOWERCASE(MSWorldPayStdTemplate.GetTargetURL()), 'secure-test') > 0, 'URL should be pointing to SandBox account');

        Assert.AreEqual(1, MSWorldPayStandardAccount.COUNT(), 'There should be one account present');
        MSWorldPayStandardAccount.FINDFIRST();
        Assert.IsTrue(STRPOS(LOWERCASE(MSWorldPayStandardAccount.Name), 'sandbox') > 0, 'Name should contain SandBox in the name');
        Assert.AreEqual(TRUE, MSWorldPayStandardAccount."Always Include on Documents",
        'Always include on documents should be set to true');
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestInsertDemoWorldPayAccountDoesNothingIfTheAccountExist()
    var
        MSWorldPayStdTemplate: Record "MS - WorldPay Std. Template";
        MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
        CompanyInformation: Record "Company Information";
    begin
        Initialize();

        CompanyInformation.GET();
        CompanyInformation."Demo Company" := FALSE;
        CompanyInformation.MODIFY();

        // Setup
        CreateDefaultTemplate();
        CreateDefaultWorldPayStandardAccount(MSWorldPayStandardAccount);

        // Execute
        CODEUNIT.RUN(CODEUNIT::"MS - WorldPay Create Demo Data");

        // Verify
        MSWorldPayStdTemplate.GET();
        MSWorldPayStdTemplate.CALCFIELDS("Target URL");
        Assert.AreEqual(1, MSWorldPayStandardAccount.COUNT(), 'There should be one account present');
        Assert.IsTrue(
          STRPOS(LOWERCASE(MSWorldPayStdTemplate.GetTargetURL()), 'sandbox') = 0, 'URL should not be pointing to SandBox account');

        MSWorldPayStandardAccount.FINDFIRST();
        Assert.IsTrue(STRPOS(LOWERCASE(MSWorldPayStandardAccount.Name), 'sandbox') = 0, 'Name should not contain SandBox in the name');
    end;

    local procedure ModifyWorldPayTemplate(var NewName: Text; var NewDescription: Text)
    var
        MSWorldPayStandardSetup: TestPage "MS - WorldPay Standard Setup";
        MSWorldPayStdTemplate: TestPage "MS - WorldPay Std. Template";
        EnableServiceWhenClosingCard: Boolean;
    begin

        MSWorldPayStandardSetup.OPENEDIT();
        MSWorldPayStdTemplate.TRAP();
        MSWorldPayStandardSetup.SetupTemplate.INVOKE();
        EnableServiceWhenClosingCard := true;
        LibraryVariableStorage.Enqueue(EnableServiceWhenClosingCard);

        NewName := LibraryUtility.GenerateRandomAlphabeticText(20, 0);
        NewDescription := LibraryUtility.GenerateRandomAlphabeticText(20, 0);

        MSWorldPayStdTemplate.Name.SETVALUE(NewName);
        MSWorldPayStdTemplate.Description.SETVALUE(NewDescription);
        MSWorldPayStdTemplate.TargetURL.SETVALUE(NewTargetURLTxt);
        MSWorldPayStdTemplate.LogoURL.SETVALUE(NewLogoURLTxt);
        MSWorldPayStdTemplate.OK().INVOKE();

        MSWorldPayStandardSetup.CLOSE();
    end;

    local procedure SetParametersToUpdateSetupPage(UpdatePage: Boolean; NewName: Text; NewDescription: Text; Enabled: Boolean; AlwaysIncludeOnDocument: Boolean; AccountID: Text; TargetURL: Text)
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

        IF AlwaysIncludeOnDocument THEN
            LibraryVariableStorage.Enqueue(UpdateOpenInvoicesManuallyTxt);

        IF Enabled THEN
            LibraryVariableStorage.Enqueue(ThirdPartyNoticeMsg);
    end;

    local procedure SetParametersToSelectPaymentService(CancelDialog: Boolean; PaymentServiceName: Text; Available: Boolean; NewAvailable: Boolean)
    begin
        LibraryVariableStorage.Enqueue(CancelDialog);
        IF CancelDialog THEN
            EXIT;

        LibraryVariableStorage.Enqueue(PaymentServiceName);
        LibraryVariableStorage.Enqueue(Available);
        LibraryVariableStorage.Enqueue(NewAvailable);
    end;

    local procedure CreateWorldPayStandardAccount(var MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account")
    var
        MSWorldPayStdTemplate: Record "MS - WorldPay Std. Template";
        MSWorldPayStandardMgt: Codeunit "MS - WorldPay Standard Mgt.";
    begin
        MSWorldPayStandardMgt.GetTemplate(MSWorldPayStdTemplate);
        MSWorldPayStandardAccount.INIT();
        MSWorldPayStandardAccount.TRANSFERFIELDS(MSWorldPayStdTemplate, FALSE);
        MSWorldPayStandardAccount.Name := COPYSTR(WorldPayAccountPrefixTxt + LibraryUtility.GenerateRandomAlphabeticText(30, 1),
            1, MAXSTRLEN(MSWorldPayStandardAccount.Name));
        MSWorldPayStandardAccount.Description := COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(30, 0),
            1, MAXSTRLEN(MSWorldPayStandardAccount.Description));
        MSWorldPayStandardAccount."Account ID" := COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(30, 0),
            1, MAXSTRLEN(MSWorldPayStandardAccount."Account ID"));
        MSWorldPayStandardAccount.INSERT();
    end;

    local procedure EnableWorldPayStandardAccount(var MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account")
    begin
        MSWorldPayStandardAccount.VALIDATE(Enabled, TRUE);
        MSWorldPayStandardAccount.MODIFY(TRUE);
    end;

    local procedure CreateDefaultWorldPayStandardAccount(var DefaultMSWorldPayStandardAccount: Record "MS - WorldPay Standard Account")
    begin
        CreateWorldPayStandardAccount(DefaultMSWorldPayStandardAccount);
        EnableWorldPayStandardAccount(DefaultMSWorldPayStandardAccount);
        LibraryVariableStorage.Enqueue(UpdateOpenInvoicesManuallyTxt);
        DefaultMSWorldPayStandardAccount.VALIDATE("Always Include on Documents", TRUE);
        DefaultMSWorldPayStandardAccount.MODIFY(TRUE);
    end;

    local procedure CreateAndPostSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header"; PaymentMethod: Record "Payment Method")
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesInvoice(SalesHeader, PaymentMethod);
        PostSalesInvoice(SalesHeader, SalesInvoiceHeader);
    end;

    local procedure PostSalesInvoice(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        SalesInvoiceHeader.SETAUTOCALCFIELDS(Closed);
        SalesInvoiceHeader.GET(LibrarySales.PostSalesDocument(SalesHeader, TRUE, TRUE));
    end;

    local procedure SetupReportSelections()
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

    local procedure CreateDefaultReportSelection()
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.INIT();
        ReportSelections.Usage := ReportSelections.Usage::"S.Invoice";
        ReportSelections.Sequence := '1';
        ReportSelections."Report ID" := REPORT::"Standard Sales - Invoice";
        ReportSelections.INSERT();
    end;

    local procedure GetReportID(): Integer
    begin
        EXIT(REPORT::"Standard Sales - Invoice");
    end;

    local procedure GetCustomBodyLayout(var CustomReportLayout: Record "Custom Report Layout")
    begin
        CustomReportLayout.SETRANGE("Report ID", GetReportID());
        CustomReportLayout.SETRANGE(Type, CustomReportLayout.Type::Word);
        CustomReportLayout.SETFILTER(Description, '''@*Email Body*''');
        CustomReportLayout.FINDLAST();
    end;

    local procedure CreateSalesInvoice(var SalesHeader: Record "Sales Header"; PaymentMethod: Record "Payment Method")
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
          SalesLine,
          SalesHeader, SalesLine.Type::Item,
          CreateItem(VATPostingSetup."VAT Prod. Posting Group"),
          1);
    end;

    local procedure CreateCustomer(VATBusPostingGroup: Code[20]): Code[20]
    var
        Customer: Record "Customer";
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.VALIDATE("VAT Bus. Posting Group", VATBusPostingGroup);
        Customer.MODIFY(TRUE);
        EXIT(Customer."No.");
    end;

    local procedure CreateItem(VATProdPostingGroup: Code[20]): Code[20]
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

    local procedure CreatePaymentMethod(var PaymentMethod: Record "Payment Method"; SetBalancingAccount: Boolean)
    begin
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        IF SetBalancingAccount THEN BEGIN
            PaymentMethod."Bal. Account Type" := PaymentMethod."Bal. Account Type"::"G/L Account";
            PaymentMethod."Bal. Account No." := LibraryERM.CreateGLAccountNo();
            PaymentMethod.MODIFY(TRUE);
        END;
    end;

    local procedure CreateDefaultTemplate()
    var
        MSWorldPayStdTemplate: Record "MS - WorldPay Std. Template";
        MSWorldPayStandardMgt: Codeunit "MS - WorldPay Standard Mgt.";
    begin
        MSWorldPayStdTemplate.DELETEALL();

        MSWorldPayStdTemplate.INIT();
        MSWorldPayStdTemplate.INSERT();
        MSWorldPayStandardMgt.TemplateAssignDefaultValues(MSWorldPayStdTemplate);
        CLEAR(MSWorldPayStdTemplate."Logo URL");
        MSWorldPayStdTemplate.MODIFY();
    end;

    local procedure VerifyPaymentServicePage(PaymentServices: TestPage "Payment Services"; ExpectedPaymentServiceSetup: Record "Payment Service Setup")
    begin
        Assert.AreEqual(ExpectedPaymentServiceSetup.Name, PaymentServices.Name.VALUE(), 'Wrong value set for Name');
        Assert.AreEqual(ExpectedPaymentServiceSetup.Description, PaymentServices.Description.VALUE(), 'Wrong value set for Description');
        Assert.AreEqual(ExpectedPaymentServiceSetup.Enabled, PaymentServices.Enabled.ASBOOLEAN(), 'Wrong value set for Enabled');
        Assert.AreEqual(
          ExpectedPaymentServiceSetup."Always Include on Documents", PaymentServices."Always Include on Documents".ASBOOLEAN(),
          'Wrong value set for Always Include on Documents');
    end;

    local procedure VerifyWorldPayAccountRecord(MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account"; ExpectedMSWorldPayStandardAccount: Record "MS - WorldPay Standard Account")
    var
        ExpectedTargetURL: Text;
        ActualTargetURL: Text;
    begin
        Assert.AreEqual(ExpectedMSWorldPayStandardAccount.Name, MSWorldPayStandardAccount.Name, 'Wrong value set for Name');
        Assert.AreEqual(
          ExpectedMSWorldPayStandardAccount.Description, MSWorldPayStandardAccount.Description, 'Wrong value set for Description');
        Assert.AreEqual(ExpectedMSWorldPayStandardAccount.Enabled, MSWorldPayStandardAccount.Enabled, 'Wrong value set for Enabled');
        Assert.AreEqual(
          ExpectedMSWorldPayStandardAccount."Always Include on Documents", MSWorldPayStandardAccount."Always Include on Documents",
          'Wrong value set for Always Include on Documents');
        Assert.AreEqual(
          ExpectedMSWorldPayStandardAccount."Account ID", MSWorldPayStandardAccount."Account ID", 'Wrong value set for Account ID');

        ExpectedTargetURL := ExpectedMSWorldPayStandardAccount.GetTargetURL();
        ActualTargetURL := MSWorldPayStandardAccount.GetTargetURL();
        Assert.AreEqual(ExpectedTargetURL, ActualTargetURL, 'Wrong value set for Always Include on Documents');
    end;

    local procedure VerifyWorldPayTemplate(MSWorldPayStdTemplate: Record "MS - WorldPay Std. Template"; NewName: Text; NewDescription: Text; ExpectedTargetURL: Text; ExpectedLogoURL: Text)
    var
        ActualTargetURL: Text;
        ActualLogoURL: Text;
    begin
        Assert.AreEqual(NewName, MSWorldPayStdTemplate.Name, 'Wrong value set for Name');
        Assert.AreEqual(NewDescription, MSWorldPayStdTemplate.Description, 'Wrong value set for Description');

        ActualTargetURL := MSWorldPayStdTemplate.GetTargetURL();
        Assert.AreEqual(ExpectedTargetURL, ActualTargetURL, 'Wrong value set for target URL');

        ActualLogoURL := MSWorldPayStdTemplate.GetLogoURL();
        Assert.AreEqual(ExpectedLogoURL, ActualLogoURL, 'Wrong value set for Logo URL Txt');
    end;

    local procedure VerifyPaymentServiceIsShownOnServiceConnectionsPage(var ServiceConnections: TestPage "Service Connections"; MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account")
    var
        ServiceConnection: Record "Service Connection";
    begin
        ServiceConnections.FILTER.SETFILTER(Name, MSWorldPayStandardAccount.Description);

        Assert.AreEqual(
          MSWorldPayStandardAccount.Description, ServiceConnections.Name.VALUE(),
          'Description was not set correctly on Service Connections page');

        IF MSWorldPayStandardAccount.Enabled THEN
            Assert.AreEqual(
              FORMAT(ServiceConnection.Status::Enabled), ServiceConnections.Status.VALUE(),
              'Status was not set correctly on Service Connections page')
        ELSE
            Assert.AreEqual(
              FORMAT(ServiceConnection.Status::Disabled), ServiceConnections.Status.VALUE(),
              'Status was not set correctly on Service Connections page');
    end;

    local procedure VerifyPaymentServiceIsInReportDataset(var PaymentReportingArgument: Record "Payment Reporting Argument")
    var
        XMLBuffer: Record "XML Buffer";
        ValueFound: Boolean;
    begin
        ValueFound := FALSE;
        XMLBuffer.Load(DatasetFileName);
        XMLBuffer.SETRANGE(Name, 'PaymentServiceURL');
        XMLBuffer.SetRange(Value, PaymentReportingArgument.GetTargetURL());

        ValueFound := XMLBuffer.FindFirst();

        Assert.IsTrue(ValueFound, 'Cound not find target URL');
        XMLBuffer.SETRANGE("Parent Entry No.", XMLBuffer."Parent Entry No.");
        XMLBuffer.SetRange(Name, 'PaymentServiceURLText');
        XMLBuffer.SetRange(Value);
        XMLBuffer.FindFirst();
        Assert.AreEqual(PaymentReportingArgument."URL Caption", XMLBuffer.Value, '');
    end;

    local procedure VerifyWorldPayURL(var PaymentReportingArgument: Record "Payment Reporting Argument"; MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account"; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        TargetURL: Text;
        BaseURL: Text;
    begin
        TargetURL := PaymentReportingArgument.GetTargetURL();
        BaseURL := MSWorldPayStandardAccount.GetTargetURL();

        SalesInvoiceHeader.CALCFIELDS("Amount Including VAT");
        Assert.IsTrue(STRPOS(TargetURL, BaseURL) > 0, 'Base url was not set correctly');
        Assert.IsTrue(STRPOS(TargetURL, SalesInvoiceHeader."No.") > 0, 'Document No. was not set correctly');
        Assert.IsTrue(STRPOS(TargetURL, MSWorldPayStandardAccount."Account ID") > 0, 'Account ID was not set correctly');
        Assert.IsTrue(STRPOS(TargetURL, FORMAT(SalesInvoiceHeader."Amount Including VAT", 0, 9)) > 0, 'Total amount was not set correctly');

        GeneralLedgerSetup.GET();
        Assert.IsTrue(
          STRPOS(TargetURL, GeneralLedgerSetup.GetCurrencyCode(SalesInvoiceHeader."Currency Code")) > 0,
          'Currency Code was not set correctly');
    end;

    local procedure VerifyBodyText(MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account"; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        BaseURL: Text;
        BodyHTMLText: Text;
    begin
        BaseURL := MSWorldPayStandardAccount.GetTargetURL();
        SalesInvoiceHeader.CALCFIELDS("Amount Including VAT");
        BodyHTMLText := LibraryVariableStorage.DequeueText();
        Assert.IsTrue(STRPOS(BodyHTMLText, BaseURL) > 0, 'Base url was not set correctly');
        Assert.IsTrue(STRPOS(BodyHTMLText, SalesInvoiceHeader."No.") > 0, 'Document No. was not set correctly');
        Assert.IsTrue(STRPOS(BodyHTMLText, MSWorldPayStandardAccount."Account ID") > 0, 'Account ID was not set correctly');
        Assert.IsTrue(
          STRPOS(BodyHTMLText, FORMAT(SalesInvoiceHeader."Amount Including VAT", 0, 9)) > 0, 'Total amount was not set correctly');

        GeneralLedgerSetup.GET();
        Assert.IsTrue(
          STRPOS(BodyHTMLText, GeneralLedgerSetup.GetCurrencyCode(SalesInvoiceHeader."Currency Code")) > 0,
          'Currency Code was not set correctly');
    end;

    [ModalPageHandler]
    procedure AccountSetupPageModalPageHandler(var WorldPayStandardSetup: TestPage "MS - WorldPay Standard Setup")
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

        WorldPayStandardSetup.Name.SETVALUE(NewName);
        WorldPayStandardSetup.Description.SETVALUE(NewDescription);
        WorldPayStandardSetup."Account ID".SETVALUE(AccountID);
        WorldPayStandardSetup."Always Include on Documents".SETVALUE(AlwaysIncludeOnDocument);
        WorldPayStandardSetup.Enabled.SETVALUE(Enabled);
        WorldPayStandardSetup.TargetURL.SETVALUE(TargetURL);
        WorldPayStandardSetup.OK().INVOKE();
    end;

    [ModalPageHandler]
    procedure SelectPaymentServiceModalPageHandler(var SelectPaymentService: TestPage 1061)
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

        PaymentServiceName := LibraryVariableStorage.DequeueText();
        ExpectedAvailable := LibraryVariableStorage.DequeueBoolean();
        NewAvailable := LibraryVariableStorage.DequeueBoolean();

        SelectPaymentService.First();
        RowFound := FALSE;

        REPEAT
            IF SelectPaymentService.Name.VALUE() = PaymentServiceName THEN BEGIN
                RowFound := TRUE;
                Assert.AreEqual(ExpectedAvailable, SelectPaymentService.Available.ASBOOLEAN(), 'Available was not set correctly');
                SelectPaymentService.Available.SETVALUE(NewAvailable);
            END ELSE
                SelectPaymentService.Available.SETVALUE(NOT NewAvailable);
        UNTIL (NOT SelectPaymentService.Next() OR RowFound);

        Assert.IsTrue(RowFound, 'Row was not found on the page');

        SelectPaymentService.OK().INVOKE();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := LibraryVariableStorage.DequeueBoolean();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
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
    procedure SelectPaymentServiceTypeHandler(var SelectPaymentServiceType: TestPage 1062)
    var
        ServiceName: Text;
    begin
        ServiceName := LibraryVariableStorage.DequeueText();
        SelectPaymentServiceType.FILTER.SETFILTER(Name, ServiceName);
        SelectPaymentServiceType.FIRST();
        SelectPaymentServiceType.OK().INVOKE();
    end;

    local procedure BindActiveDirectoryMockEvents()
    begin
        IF ActiveDirectoryMockEvents.Enabled() THEN
            EXIT;
        BINDSUBSCRIPTION(ActiveDirectoryMockEvents);
        ActiveDirectoryMockEvents.Enable();
    end;
}

