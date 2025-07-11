// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139534 "Connect. Apps Visibility Tests"
{
    Subtype = Test;
    TestPermissions = Restrictive;

    var
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        ConnectToBanksMsg: Label 'Automatically import bank transactions and transfer payments by installing a bank app. The options are available here.';


    [Test]
    [Scope('OnPrem')]
    procedure TestBankAccountCardActionVisible()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        BankAccountCard: TestPage "Bank Account Card";
    begin
        // [GIVEN] Banking Apps exist
        Initialize();

        // [GIVEN] Country Code on Company Information is set to NL
        CompanyInformation."Country/Region Code" := 'NL';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Bank Account Card is opened 
        BankAccountCard.OpenView();

        // [THEN] The action "Connect to Banks" should be visible
        Assert.AreEqual(BankAccountCard."Connect to Banks".Visible(), true, 'The action "Connect to Banks" should be visible');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestBankAccountCardActionNotVisible()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        BankAccountCard: TestPage "Bank Account Card";
    begin
        // [GIVEN] Banking Apps does not exist
        Initialize();

        // [GIVEN] Country Code on Company Information is set to GB
        CompanyInformation."Country/Region Code" := 'GB';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Bank Account Card is opened 
        BankAccountCard.OpenView();

        // [THEN] The action "Connect to Banks" shouldn't be visible
        Assert.AreEqual(BankAccountCard."Connect to Banks".Visible(), false, 'The action "Connect to Banks" should not be visible');
    end;

    [Test]
    [HandlerFunctions('NotificationBankingAppsHandler')]
    [Scope('OnPrem')]
    procedure TestBankAccountCardNotificationVisible()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        BankAccountCard: TestPage "Bank Account Card";
    begin
        // [GIVEN] Banking Apps exist
        Initialize();

        // [GIVEN] Country Code on Company Information is set to NL
        CompanyInformation."Country/Region Code" := 'NL';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Bank Account Card is opened 
        BankAccountCard.OpenView();

        // [THEN] The notification is sent and captured by the handler function
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestBankAccountListActionVisible()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        BankAccountList: TestPage "Bank Account List";
    begin
        // [GIVEN] Banking Apps exist
        Initialize();

        // [GIVEN] Country Code on Company Information is set to NL
        CompanyInformation."Country/Region Code" := 'NL';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Bank Account List is opened 
        BankAccountList.OpenView();

        // [THEN] The action "Connect to Banks" should be visible
        Assert.AreEqual(BankAccountList."Connect to Banks".Visible(), true, 'The action "Connect to Banks" should be visible');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestBankAccountListActionNotVisible()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        BankAccountList: TestPage "Bank Account List";
    begin
        // [GIVEN] Banking Apps does not exist
        Initialize();

        // [GIVEN] Country Code on Company Information is set to GB
        CompanyInformation."Country/Region Code" := 'GB';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Bank Account List is opened 
        BankAccountList.OpenView();

        // [THEN] The action "Connect to Banks" shouldn't be visible
        Assert.AreEqual(BankAccountList."Connect to Banks".Visible(), false, 'The action "Connect to Banks" should not be visible');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestBankAccountReconciliationActionVisible()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        BankAccReconciliation: TestPage "Bank Acc. Reconciliation";
    begin
        // [GIVEN] Banking Apps exist
        Initialize();

        // [GIVEN] Country Code on Company Information is set to NL
        CompanyInformation."Country/Region Code" := 'NL';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Bank Account Reconciliation is opened 
        BankAccReconciliation.OpenView();

        // [THEN] The action "Connect to Banks" should be visible
        Assert.AreEqual(BankAccReconciliation."Connect to Banks".Visible(), true, 'The action "Connect to Banks" should be visible');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestBankAccountReconciliationActionNotVisible()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        BankAccReconciliation: TestPage "Bank Acc. Reconciliation";
    begin
        // [GIVEN] Banking Apps does not exist
        Initialize();

        // [GIVEN] Country Code on Company Information is set to GB
        CompanyInformation."Country/Region Code" := 'GB';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Bank Account Reconciliation is opened 
        BankAccReconciliation.OpenView();

        // [THEN] The action "Connect to Banks" shouldn't be visible
        Assert.AreEqual(BankAccReconciliation."Connect to Banks".Visible(), false, 'The action "Connect to Banks" should not be visible');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPaymentJournalActionVisible()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        PaymentJournal: TestPage "Payment Journal";
    begin
        // [GIVEN] Banking Apps exist
        Initialize();

        // [GIVEN] Country Code on Company Information is set to NL
        CompanyInformation."Country/Region Code" := 'NL';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Payment Journal is opened 
        PaymentJournal.OpenView();

        // [THEN] The action "Connect to Banks" should be visible
        Assert.AreEqual(PaymentJournal."Connect to Banks".Visible(), true, 'The action "Connect to Banks" should be visible');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPaymentJournalActionNotVisible()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        PaymentJournal: TestPage "Payment Journal";
    begin
        // [GIVEN] Banking Apps does not exist
        Initialize();

        // [GIVEN] Country Code on Company Information is set to GB
        CompanyInformation."Country/Region Code" := 'GB';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Payment Journal is opened 
        PaymentJournal.OpenView();

        // [THEN] The action "Connect to Banks" shouldn't be visible
        Assert.AreEqual(PaymentJournal."Connect to Banks".Visible(), false, 'The action "Connect to Banks" should not be visible');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPaymentReconJournalActionVisible()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        PmtReconciliationJournals: TestPage "Pmt. Reconciliation Journals";
    begin
        // [GIVEN] Banking Apps exist
        Initialize();

        // [GIVEN] Country Code on Company Information is set to NL
        CompanyInformation."Country/Region Code" := 'NL';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Pmt. Reconciliation Journals is opened 
        PmtReconciliationJournals.OpenView();

        // [THEN] The action "Connect to Banks" should be visible
        Assert.AreEqual(PmtReconciliationJournals."Connect to Banks".Visible(), true, 'The action "Connect to Banks" should be visible');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPaymentReconJournalActionNotVisible()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        PmtReconciliationJournals: TestPage "Pmt. Reconciliation Journals";
    begin
        // [GIVEN] Banking Apps does not exist
        Initialize();

        // [GIVEN] Country Code on Company Information is set to GB
        CompanyInformation."Country/Region Code" := 'GB';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Pmt. Reconciliation Journals is opened 
        PmtReconciliationJournals.OpenView();

        // [THEN] The action "Connect to Banks" shouldn't be visible
        Assert.AreEqual(PmtReconciliationJournals."Connect to Banks".Visible(), false, 'The action "Connect to Banks" should not be visible');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestExtensionManagementActionVisible()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        ExtensionManagement: TestPage "Extension Management";
    begin
        // [GIVEN] Banking Apps exist
        Initialize();

        // [GIVEN] Country Code on Company Information is set to NL
        CompanyInformation."Country/Region Code" := 'NL';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Pmt. Reconciliation Journals is opened 
        ExtensionManagement.OpenView();

        // [THEN] The action "Connectivity Apps" should be visible
        Assert.AreEqual(ExtensionManagement."Connectivity Apps".Visible(), true, 'The action "Connectivity Apps" should be visible');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestExtensionManagementActionNotVisible()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        ExtensionManagement: TestPage "Extension Management";
    begin
        // [GIVEN] Banking Apps does not exist
        Initialize();

        // [GIVEN] Country Code on Company Information is set to GB
        CompanyInformation."Country/Region Code" := 'GB';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Pmt. Reconciliation Journals is opened 
        ExtensionManagement.OpenView();

        // [THEN] The action "Connectivity Apps" shouldn't be visible
        Assert.AreEqual(ExtensionManagement."Connectivity Apps".Visible(), false, 'The action "Connectivity Apps" should not be visible');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestAccountantHeadlineVisible()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        HeadlineRCAccountant: TestPage "Headline RC Accountant";
    begin
        // [GIVEN] Banking Apps exist
        Initialize();

        // [GIVEN] The company type is evaluation
        SetEvaluationPropertyForCompany(true);

        // [GIVEN] Country Code on Company Information is set to NL
        CompanyInformation."Country/Region Code" := 'NL';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Headline RC Accountant is opened 
        HeadlineRCAccountant.OpenView();

        // [THEN] The field BankingAppsText should be visible
        Assert.AreEqual(HeadlineRCAccountant.BankingAppsText.Visible(), true, 'The field BankingAppsText should be visible');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestAccountantHeadlineNotVisible()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        HeadlineRCAccountant: TestPage "Headline RC Accountant";
    begin
        // [GIVEN] Banking Apps does not exist
        Initialize();

        // [GIVEN] The company type is evaluation
        SetEvaluationPropertyForCompany(true);

        // [GIVEN] Country Code on Company Information is set to GB
        CompanyInformation."Country/Region Code" := 'GB';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Headline RC Accountant is opened 
        HeadlineRCAccountant.OpenView();

        // [THEN] The field BankingAppsText shouldn't be visible
        Assert.AreEqual(HeadlineRCAccountant.BankingAppsText.Visible(), false, 'The field BankingAppsText should not be visible');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestAccountantHeadlineNotVisibleNonEval()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        HeadlineRCAccountant: TestPage "Headline RC Accountant";
    begin
        // [GIVEN] Banking Apps does not exist
        Initialize();

        // [GIVEN] The company type is non-evaluation
        SetEvaluationPropertyForCompany(false);

        // [GIVEN] Country Code on Company Information is set to GB
        CompanyInformation."Country/Region Code" := 'NL';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Headline RC Accountant is opened 
        HeadlineRCAccountant.OpenView();

        // [THEN] The field BankingAppsText shouldn't be visible
        Assert.AreEqual(HeadlineRCAccountant.BankingAppsText.Visible(), false, 'The field BankingAppsText should not be visible in non-evaluation company');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestBusinessManagerHeadlineVisible()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        HeadlineRCBusinessManager: TestPage "Headline RC Business Manager";
    begin
        // [GIVEN] Banking Apps exist
        Initialize();

        // [GIVEN] The company type is evaluation
        SetEvaluationPropertyForCompany(true);

        // [GIVEN] Country Code on Company Information is set to NL
        CompanyInformation."Country/Region Code" := 'NL';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN]Headline RC Business Manager is opened 
        HeadlineRCBusinessManager.OpenView();

        // [THEN] The field BankingAppsText should be visible
        Assert.AreEqual(HeadlineRCBusinessManager.BankingAppsText.Visible(), true, 'The field BankingAppsText should be visible');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestBusinessManagerHeadlineNotVisible()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        HeadlineRCBusinessManager: TestPage "Headline RC Business Manager";
    begin
        // [GIVEN] Banking Apps does not exist
        Initialize();

        // [GIVEN] The company type is evaluation
        SetEvaluationPropertyForCompany(true);

        // [GIVEN] Country Code on Company Information is set to GB
        CompanyInformation."Country/Region Code" := 'GB';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Headline RC Business Manager is opened 
        HeadlineRCBusinessManager.OpenView();

        // [THEN] The field BankingAppsText shouldn't be visible
        Assert.AreEqual(HeadlineRCBusinessManager.BankingAppsText.Visible(), false, 'The field BankingAppsText should not be visible');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestBusinessManagerHeadlineNotVisibleNonEval()
    var
        CompanyInformation: Record "Company Information";
        ConnectivityAppsLocationMock: Codeunit "Connectivity Apps Loc. Mock";
        HeadlineRCBusinessManager: TestPage "Headline RC Business Manager";
    begin
        // [GIVEN] Banking Apps does not exist
        Initialize();

        // [GIVEN] The company type is non-evaluation
        SetEvaluationPropertyForCompany(false);

        // [GIVEN] Country Code on Company Information is set to GB
        CompanyInformation."Country/Region Code" := 'NL';
        CompanyInformation.Modify();

        BindSubscription(ConnectivityAppsLocationMock);

        // [WHEN] Headline RC Business Manager is opened 
        HeadlineRCBusinessManager.OpenView();

        // [THEN] The field BankingAppsText shouldn't be visible
        Assert.AreEqual(HeadlineRCBusinessManager.BankingAppsText.Visible(), false, 'The field BankingAppsText should not be visible in non-evaluation company');
    end;

    local procedure Initialize()
    var
        ConnectivityAppsTests: Codeunit "Connectivity Apps Tests";
    begin
        if IsInitialized then
            exit;

        ConnectivityAppsTests.SetupTestData();
        IsInitialized := true;
    end;

    local procedure SetEvaluationPropertyForCompany(IsEvaluationCompany: Boolean)
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName());

        Company."Evaluation Company" := IsEvaluationCompany;
        Company.Modify();
    end;

    [SendNotificationHandler]
    [Scope('OnPrem')]
    procedure NotificationBankingAppsHandler(var Notification: Notification): Boolean
    begin
        Assert.AreEqual(ConnectToBanksMsg, Notification.Message, 'Unexpected notification');
    end;
}