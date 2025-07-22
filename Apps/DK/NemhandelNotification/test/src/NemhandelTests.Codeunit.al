codeunit 148012 "Nemhandel Tests"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURE] [Nemhandelsregisteret]
    end;

    var
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        CompanyStatusGlobal: Enum "Nemhandel Company Status";
        IsInitialized: Boolean;
        IncorrectCVRNumberFormatErr: Label 'The CVR number must be 8 digits or "A/S" followed by 3-6 digits.';
        NemhandelNotRegisteredTxt: Label 'Your accounting software is not registered in Nemhandelsregisteret';
        IncorrectCVRNumberFormatTxt: Label 'The Registration No. must be 8 digits or "A/S" followed by 3-6 digits';

    [Test]
    [HandlerFunctions('NotificationHandler')]
    procedure NotificationNotShownWhenCompanyStatusRegistered()
    var
        NemhandelTests: Codeunit "Nemhandel Tests";
        CompanyInformationPage: TestPage "Company Information";
    begin
        // [SCENARIO 464206] Notification about Nemhandel registration when company is registered in Nemhandelsregisteret.
        Initialize();

        // [GIVEN] Company Information with CVR number which is registered in Nemhandelsregisteret.
        NemhandelTests.MockCompanyStatusInPageBackgroundTask(Enum::"Nemhandel Company Status"::Registered);
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::Registered);
        BindSubscription(NemhandelTests);
        Commit();

        // [WHEN] Open Company Information page.
        CompanyInformationPage.OpenEdit();

        // [THEN] No notifications were shown on Company Information page.
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('NotificationHandler')]
    procedure NotificationShownWhenCompanyStatusNotRegistered()
    var
        NemhandelTests: Codeunit "Nemhandel Tests";
        CompanyInformationPage: TestPage "Company Information";
        NotificationText: Text;
    begin
        // [SCENARIO 464206] Notification about Nemhandel registration when company is not registered in Nemhandelsregisteret.
        Initialize();

        // [GIVEN] Company Information with CVR number which is not registered in Nemhandelsregisteret.
        NemhandelTests.MockCompanyStatusInPageBackgroundTask(Enum::"Nemhandel Company Status"::NotRegistered);
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::NotRegistered);
        BindSubscription(NemhandelTests);
        Commit();

        // [WHEN] Open Company Information page.
        CompanyInformationPage.OpenEdit();

        // [THEN] Notification "Your accounting software is not registered in Nemhandelsregisteret" was shown on Company Information page.
        NotificationText := LibraryVariableStorage.DequeueText();
        Assert.ExpectedMessage(NemhandelNotRegisteredTxt, NotificationText);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('NotificationHandler')]
    procedure NotificationShownWhenCompanyStatusUnknown()
    var
        NemhandelTests: Codeunit "Nemhandel Tests";
        CompanyInformationPage: TestPage "Company Information";
        NotificationText: Text;
    begin
        // [SCENARIO 464206] Notification about Nemhandel registration when company registration in Nemhandelsregisteret has not been checked.
        Initialize();

        // [GIVEN] Company Information with CVR number for which check if company is registered in Nemhandelsregisteret has not been made.
        NemhandelTests.MockCompanyStatusInPageBackgroundTask(Enum::"Nemhandel Company Status"::Unknown);
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::Unknown);
        BindSubscription(NemhandelTests);
        Commit();

        // [WHEN] Open Company Information page.
        CompanyInformationPage.OpenEdit();

        // [THEN] Notification "Your accounting software is not registered in Nemhandelsregisteret" was shown on Company Information page.
        NotificationText := LibraryVariableStorage.DequeueText();
        Assert.ExpectedMessage(NemhandelNotRegisteredTxt, NotificationText);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('NotificationHandler')]
    procedure NotificationShownForAccountantWhenCompanyNotRegistered()
    var
        NemhandelTests: Codeunit "Nemhandel Tests";
        AccountantActivities: TestPage "Accountant Activities";
        NotificationText: Text;
    begin
        // [SCENARIO 464206] Notification about Nemhandel registration on Accountant Role Center when company is not registered in Nemhandelsregisteret.
        Initialize();
        DisableForecastNotification();

        // [GIVEN] Company Information with CVR number which is not registered in Nemhandelsregisteret.
        NemhandelTests.MockCompanyStatusInPageBackgroundTask(Enum::"Nemhandel Company Status"::NotRegistered);
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::NotRegistered);
        BindSubscription(NemhandelTests);
        Commit();

        // [WHEN] Open Accountant Activities page which is a part of Accountant Role Center.
        AccountantActivities.OpenEdit();

        // [THEN] Notification "Your accounting software is not registered in Nemhandelsregisteret" was shown on the role center page.
        NotificationText := LibraryVariableStorage.DequeueText();
        Assert.ExpectedMessage(NemhandelNotRegisteredTxt, NotificationText);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('NotificationHandler')]
    procedure NotificationShownForBusinessManagerWhenCompanyNotRegistered()
    var
        NemhandelTests: Codeunit "Nemhandel Tests";
        O365Activities: TestPage "O365 Activities";
        NotificationText: Text;
    begin
        // [SCENARIO 464206] Notification about Nemhandel registration on Business Manager Role Center when company is not registered in Nemhandelsregisteret.
        Initialize();

        // [GIVEN] Company Information with CVR number which is not registered in Nemhandelsregisteret.
        NemhandelTests.MockCompanyStatusInPageBackgroundTask(Enum::"Nemhandel Company Status"::NotRegistered);
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::NotRegistered);
        BindSubscription(NemhandelTests);
        Commit();

        // [WHEN] Open O365 Activities page which is a part of Business Manager Role Center.
        O365Activities.OpenEdit();

        // [THEN] Notification "Your accounting software is not registered in Nemhandelsregisteret" was shown on the role center page.
        NotificationText := LibraryVariableStorage.DequeueText();
        Assert.ExpectedMessage(NemhandelNotRegisteredTxt, NotificationText);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('NotificationHandler')]
    procedure NotificationShownForSalesManagerWhenCompanyNotRegistered()
    var
        NemhandelTests: Codeunit "Nemhandel Tests";
        SalesMgrActivities: TestPage "Sales & Relationship Mgr. Act.";
        NotificationText: Text;
    begin
        // [SCENARIO 464206] Notification about Nemhandel registration on Sales Manager Role Center when company is not registered in Nemhandelsregisteret.
        Initialize();

        // [GIVEN] Company Information with CVR number which is not registered in Nemhandelsregisteret.
        NemhandelTests.MockCompanyStatusInPageBackgroundTask(Enum::"Nemhandel Company Status"::NotRegistered);
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::NotRegistered);
        BindSubscription(NemhandelTests);
        Commit();

        // [WHEN] Open Sales & Relationship Mgr. Act. page which is a part of Sales Manager Role Center.
        SalesMgrActivities.OpenEdit();

        // [THEN] Notification "Your accounting software is not registered in Nemhandelsregisteret" was shown on the role center page.
        NotificationText := LibraryVariableStorage.DequeueText();
        Assert.ExpectedMessage(NemhandelNotRegisteredTxt, NotificationText);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('NotificationHandler')]
    procedure NotificationShownForOrderProcessorWhenCompanyNotRegistered()
    var
        NemhandelTests: Codeunit "Nemhandel Tests";
        SOProcessorActivities: TestPage "SO Processor Activities";
        NotificationText: Text;
    begin
        // [SCENARIO 464206] Notification about Nemhandel registration on Order Processor Role Center when company is not registered in Nemhandelsregisteret.
        Initialize();

        // [GIVEN] Company Information with CVR number which is not registered in Nemhandelsregisteret.
        NemhandelTests.MockCompanyStatusInPageBackgroundTask(Enum::"Nemhandel Company Status"::NotRegistered);
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::NotRegistered);
        BindSubscription(NemhandelTests);
        Commit();

        // [WHEN] Open SO Processor Activities page which is a part of Order Processor Role Center.
        SOProcessorActivities.OpenEdit();

        // [THEN] Notification "Your accounting software is not registered in Nemhandelsregisteret" was shown on the role center page.
        NotificationText := LibraryVariableStorage.DequeueText();
        Assert.ExpectedMessage(NemhandelNotRegisteredTxt, NotificationText);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('NotificationHandler')]
    procedure NotificationShownForSecurityAdminWhenCompanyNotRegistered()
    var
        NemhandelTests: Codeunit "Nemhandel Tests";
        UserSecurityActivities: TestPage "User Security Activities";
        NotificationText: Text;
    begin
        // [SCENARIO 464206] Notification about Nemhandel registration on Security Admin Role Center when company is not registered in Nemhandelsregisteret.
        Initialize();

        // [GIVEN] Company Information with CVR number which is not registered in Nemhandelsregisteret.
        NemhandelTests.MockCompanyStatusInPageBackgroundTask(Enum::"Nemhandel Company Status"::NotRegistered);
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::NotRegistered);
        BindSubscription(NemhandelTests);
        Commit();

        // [WHEN] Open User Security Activities page which is a part of Security Admin Role Center.
        UserSecurityActivities.OpenEdit();

        // [THEN] Notification "Your accounting software is not registered in Nemhandelsregisteret" was shown on the role center page.
        NotificationText := LibraryVariableStorage.DequeueText();
        Assert.ExpectedMessage(NemhandelNotRegisteredTxt, NotificationText);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('NotificationHandler')]
    procedure NotificationShownWhenSetNotRegisteredCVRNumber()
    var
        NemhandelTests: Codeunit "Nemhandel Tests";
        CompanyInformationPage: TestPage "Company Information";
        NotificationText: Text;
    begin
        // [SCENARIO 464206] Notification about Nemhandel registration when set Registration No. when company is not registered in Nemhandelsregisteret.
        Initialize();

        // [GIVEN] Company Information with blank CVR number.
        NemhandelTests.MockCompanyStatusInPageBackgroundTask(Enum::"Nemhandel Company Status"::Unknown);
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::Unknown);
        BindSubscription(NemhandelTests);
        Commit();

        // [GIVEN] Opened Company Information page. Notification non-registered company is shown.
        CompanyInformationPage.OpenEdit();
        LibraryVariableStorage.Clear();

        // [WHEN] Set Registration No. to CVR number which is not registered in Nemhandelsregisteret.
        NemhandelTests.MockCompanyStatusInPageBackgroundTask(Enum::"Nemhandel Company Status"::NotRegistered);
        CompanyInformationPage."Registration No.".SetValue('87654321');

        // [THEN] Notification "Your accounting software is not registered in Nemhandelsregisteret" was shown on Company Information page.
        NotificationText := LibraryVariableStorage.DequeueText();
        Assert.ExpectedMessage(NemhandelNotRegisteredTxt, NotificationText);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure NotificationNotShownWhenChangeCVRNumberFromRegToNotReg()
    var
        NemhandelTests: Codeunit "Nemhandel Tests";
        CompanyInformationPage: TestPage "Company Information";
    begin
        // [SCENARIO 464206] Change Registration No. from registered in Nemhandelsregisteret to not registered.
        Initialize();

        // [GIVEN] Company Information with CVR number which is registered in Nemhandelsregisteret.
        NemhandelTests.MockCompanyStatusInPageBackgroundTask(Enum::"Nemhandel Company Status"::Registered);
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::Registered);
        BindSubscription(NemhandelTests);
        Commit();

        // [GIVEN] Opened Company Information page.
        CompanyInformationPage.OpenEdit();

        // [WHEN] Update Registration No. to another CVR number.
        asserterror CompanyInformationPage."Registration No.".SetValue('87654321');

        // [THEN] Error "Registration No. cannot be changed when CVR number is registered in Nemhandelsregistret" is shown.
        Assert.ExpectedError('Registration No. cannot be changed when CVR number is registered in Nemhandelsregisteret');
        Assert.ExpectedErrorCode('TestValidation');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('NotificationHandler')]
    procedure NotificationNotShownWhenSetRegisteredCVRNumber()
    var
        NemhandelTests: Codeunit "Nemhandel Tests";
        CompanyInformationPage: TestPage "Company Information";
    begin
        // [SCENARIO 464206] Notification about Nemhandel registration when set Registration No. when company is registered in Nemhandelsregisteret.
        Initialize();

        // [GIVEN] Company Information with CVR number which is not registered in Nemhandelsregisteret.
        NemhandelTests.MockCompanyStatusInPageBackgroundTask(Enum::"Nemhandel Company Status"::NotRegistered);
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::NotRegistered);
        BindSubscription(NemhandelTests);
        Commit();

        // [GIVEN] Opened Company Information page.
        CompanyInformationPage.OpenEdit();
        LibraryVariableStorage.DequeueText();   // clear notification about not registered CVR number

        // [WHEN] Set Registration No. to CVR number which is registered in Nemhandelsregisteret.
        NemhandelTests.MockCompanyStatusInPageBackgroundTask(Enum::"Nemhandel Company Status"::Registered);
        CompanyInformationPage."Registration No.".SetValue('87654321');

        // [THEN] No notifications were shown on Company Information page.
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure GetCompanyStatusWhenRegistered()
    var
        NemhandelStatusPageBckgrnd: Codeunit "Nemhandel Status Page Bckgrnd";
        MockHttpClientNemhandel: Codeunit "Mock Http Client Nemhandel";
        CompanyStatus: Enum "Nemhandel Company Status";
        CVRNumber: Text[20];
    begin
        // [SCENARIO 464206] Run NemhandelStatusPageBckgrnd.GetCompanyStatus() function when company is registered in Nemhandelsregisteret.
        Initialize();
        NemhandelStatusPageBckgrnd.SetHttpClient(MockHttpClientNemhandel);

        // [GIVEN] Company Information with CVR number which is registered in Nemhandelsregisteret.
        // [GIVEN] Mocked http client is set to return the same CVR number in response body.
        CVRNumber := GetCompanyCVRNumber();
        MockHttpClientNemhandel.SetRequestResult(true);
        MockHttpClientNemhandel.SetSuccess(200, GetResponseBodyText(CVRNumber));

        // [WHEN] Run GetCompanyStatus() function of "Nemhandel Status Page Bckgrnd" codeunit.
        CompanyStatus := NemhandelStatusPageBckgrnd.GetCompanyStatus(CVRNumber);

        // [THEN] The function returned "Registered" status.
        Assert.AreEqual(Enum::"Nemhandel Company Status"::Registered, CompanyStatus, '');
    end;

    [Test]
    procedure GetCompanyStatusWhenDifferentCVRNumberReturned()
    var
        NemhandelStatusPageBckgrnd: Codeunit "Nemhandel Status Page Bckgrnd";
        MockHttpClientNemhandel: Codeunit "Mock Http Client Nemhandel";
        CompanyStatus: Enum "Nemhandel Company Status";
        CurrCVRNumber: Text[20];
        NewCVRNumber: Text[20];
    begin
        // [SCENARIO 464206] Run NemhandelStatusPageBckgrnd.GetCompanyStatus() function when http request returns different CVR number.
        Initialize();
        NemhandelStatusPageBckgrnd.SetHttpClient(MockHttpClientNemhandel);

        // [GIVEN] Company Information with CVR number A.
        // [GIVEN] Mocked http client is set to return CVR number B <> A.
        CurrCVRNumber := GetCompanyCVRNumber();
        NewCVRNumber := IncStr(CurrCVRNumber);
        MockHttpClientNemhandel.SetRequestResult(true);
        MockHttpClientNemhandel.SetSuccess(200, GetResponseBodyText(NewCVRNumber));

        // [WHEN] Run GetCompanyStatus() function of "Nemhandel Status Page Bckgrnd" codeunit.
        CompanyStatus := NemhandelStatusPageBckgrnd.GetCompanyStatus(CurrCVRNumber);

        // [THEN] The function returned "NotRegistered" status.
        Assert.AreEqual(Enum::"Nemhandel Company Status"::NotRegistered, CompanyStatus, '');
    end;

    [Test]
    procedure GetCompanyStatusWhenBlankCVRNumber()
    var
        NemhandelStatusPageBckgrnd: Codeunit "Nemhandel Status Page Bckgrnd";
        MockHttpClientNemhandel: Codeunit "Mock Http Client Nemhandel";
        CompanyStatus: Enum "Nemhandel Company Status";
    begin
        // [SCENARIO 464206] Run NemhandelStatusPageBckgrnd.GetCompanyStatus() function when Company Information has blank CVR number.
        Initialize();
        NemhandelStatusPageBckgrnd.SetHttpClient(MockHttpClientNemhandel);

        // [GIVEN] Company Information with blank CVR number.
        UpdateCompanyCVRNumber('');
        MockHttpClientNemhandel.SetRequestResult(false);

        // [WHEN] Run GetCompanyStatus() function of "Nemhandel Status Page Bckgrnd" codeunit.
        CompanyStatus := NemhandelStatusPageBckgrnd.GetCompanyStatus('');

        // [THEN] The function returned "NotRegistered" status.
        Assert.AreEqual(Enum::"Nemhandel Company Status"::NotRegistered, CompanyStatus, '');

        // restore CVR number
        UpdateCompanyCVRNumber('12345678');
    end;

    [Test]
    procedure GetCompanyStatusWhenNotRegistered()
    var
        NemhandelStatusPageBckgrnd: Codeunit "Nemhandel Status Page Bckgrnd";
        MockHttpClientNemhandel: Codeunit "Mock Http Client Nemhandel";
        CompanyStatus: Enum "Nemhandel Company Status";
        CVRNumber: Text[20];
    begin
        // [SCENARIO 464206] Run NemhandelStatusPageBckgrnd.GetCompanyStatus() function when company is not registered in Nemhandelsregisteret.
        Initialize();
        NemhandelStatusPageBckgrnd.SetHttpClient(MockHttpClientNemhandel);

        // [GIVEN] Company Information with CVR number which is not registered in Nemhandelsregisteret.
        // [GIVEN] Mocked http client is set to return the 404 error code.
        CVRNumber := GetCompanyCVRNumber();
        MockHttpClientNemhandel.SetRequestResult(true);
        MockHttpClientNemhandel.SetError(404, '');

        // [WHEN] Run GetCompanyStatus() function of "Nemhandel Status Page Bckgrnd" codeunit.
        CompanyStatus := NemhandelStatusPageBckgrnd.GetCompanyStatus(CVRNumber);

        // [THEN] The function returned "NotRegistered" status.
        Assert.AreEqual(Enum::"Nemhandel Company Status"::NotRegistered, CompanyStatus, '');
    end;

    [Test]
    procedure GetCompanyStatusWhenNoConnection()
    var
        NemhandelStatusPageBckgrnd: Codeunit "Nemhandel Status Page Bckgrnd";
        MockHttpClientNemhandel: Codeunit "Mock Http Client Nemhandel";
        CompanyStatus: Enum "Nemhandel Company Status";
        CVRNumber: Text[20];
    begin
        // [SCENARIO 464206] Run NemhandelStatusPageBckgrnd.GetCompanyStatus() function when http URI not available.
        Initialize();
        NemhandelStatusPageBckgrnd.SetHttpClient(MockHttpClientNemhandel);

        // [GIVEN] Mocked http client is set to return false on send http request.
        CVRNumber := GetCompanyCVRNumber();
        MockHttpClientNemhandel.SetRequestResult(false);
        MockHttpClientNemhandel.SetBlockedByEnvironment(false);

        // [WHEN] Run GetCompanyStatus() function of "Nemhandel Status Page Bckgrnd" codeunit.
        CompanyStatus := NemhandelStatusPageBckgrnd.GetCompanyStatus(CVRNumber);

        // [THEN] The function returned "Unknown" status.
        Assert.AreEqual(Enum::"Nemhandel Company Status"::Unknown, CompanyStatus, '');
    end;

    [Test]
    procedure GetCompanyStatusWhenBlockedByEnvironment()
    var
        NemhandelStatusPageBckgrnd: Codeunit "Nemhandel Status Page Bckgrnd";
        MockHttpClientNemhandel: Codeunit "Mock Http Client Nemhandel";
        CompanyStatus: Enum "Nemhandel Company Status";
        CVRNumber: Text[20];
    begin
        // [SCENARIO 464206] Run NemhandelStatusPageBckgrnd.GetCompanyStatus() function when http URI not available.
        Initialize();
        NemhandelStatusPageBckgrnd.SetHttpClient(MockHttpClientNemhandel);

        // [GIVEN] Mocked http client is set to return false on send http request and IsBlockedByEnvironment is set to true.
        CVRNumber := GetCompanyCVRNumber();
        MockHttpClientNemhandel.SetRequestResult(false);
        MockHttpClientNemhandel.SetBlockedByEnvironment(true);

        // [WHEN] Run GetCompanyStatus() function of "Nemhandel Status Page Bckgrnd" codeunit.
        CompanyStatus := NemhandelStatusPageBckgrnd.GetCompanyStatus(CVRNumber);

        // [THEN] The function returned "Unknown" status.
        Assert.AreEqual(Enum::"Nemhandel Company Status"::Unknown, CompanyStatus, '');
    end;

    [Test]
    procedure GetCompanyStatusWhenOtherHttpError()
    var
        NemhandelStatusPageBckgrnd: Codeunit "Nemhandel Status Page Bckgrnd";
        MockHttpClientNemhandel: Codeunit "Mock Http Client Nemhandel";
        CompanyStatus: Enum "Nemhandel Company Status";
        CVRNumber: Text[20];
    begin
        // [SCENARIO 464206] Run NemhandelStatusPageBckgrnd.GetCompanyStatus() function when server returns status code different from 200 (registered) and 404 (not registered).
        Initialize();
        NemhandelStatusPageBckgrnd.SetHttpClient(MockHttpClientNemhandel);

        // [GIVEN] Mocked http client is set to return the 500 error code.
        CVRNumber := GetCompanyCVRNumber();
        MockHttpClientNemhandel.SetRequestResult(true);
        MockHttpClientNemhandel.SetError(500, '');

        // [WHEN] Run GetCompanyStatus() function of "Nemhandel Status Page Bckgrnd" codeunit.
        CompanyStatus := NemhandelStatusPageBckgrnd.GetCompanyStatus(CVRNumber);

        // [THEN] The function returned "Unknown" status.
        Assert.AreEqual(Enum::"Nemhandel Company Status"::Unknown, CompanyStatus, '');
    end;

    [Test]
    procedure NotificationNotShownWhenEvaluationCompanyStatusUnknown()
    var
        NemhandelTests: Codeunit "Nemhandel Tests";
        CompanyInformationPage: TestPage "Company Information";
    begin
        // [SCENARIO 504365] Notification about Nemhandel registration when company registration in Nemhandelsregisteret has not been checked for Evaluation company.
        Initialize();

        // [GIVEN] Current company is evaluation company
        UpdateEvaluationOnCompany(true);

        // [GIVEN] Company Information with CVR number for which check if company is registered in Nemhandelsregisteret has not been made.
        NemhandelTests.MockCompanyStatusInPageBackgroundTask(Enum::"Nemhandel Company Status"::Unknown);
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::Unknown);
        BindSubscription(NemhandelTests);
        Commit();

        // [WHEN] Open Company Information page.
        CompanyInformationPage.OpenEdit();

        // [THEN] No notifications were shown on Company Information page.
        LibraryVariableStorage.AssertEmpty();

        // restore evaluation state
        UpdateEvaluationOnCompany(false);
    end;

    [Test]
    procedure NotificationNotShownWhenEvaluationCompanyStatusNotRegistered()
    var
        NemhandelTests: Codeunit "Nemhandel Tests";
        CompanyInformationPage: TestPage "Company Information";
    begin
        // [SCENARIO 504365] Notification about Nemhandel registration when Evaluation company is not registered in Nemhandelsregisteret.
        Initialize();

        // [GIVEN] Current company is evaluation company
        UpdateEvaluationOnCompany(true);

        // [GIVEN] Company Information with CVR number which is not registered in Nemhandelsregisteret.
        NemhandelTests.MockCompanyStatusInPageBackgroundTask(Enum::"Nemhandel Company Status"::NotRegistered);
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::NotRegistered);
        BindSubscription(NemhandelTests);
        Commit();

        // [WHEN] Open Company Information page.
        CompanyInformationPage.OpenEdit();

        // [THEN] No notifications were shown on Company Information page.
        LibraryVariableStorage.AssertEmpty();

        // restore evaluation state
        UpdateEvaluationOnCompany(false);
    end;

    [Test]
    procedure NotificationNotShownWhenOnPremCompanyStatusUnknown()
    var
        NemhandelTests: Codeunit "Nemhandel Tests";
        CompanyInformationPage: TestPage "Company Information";
    begin
        // [SCENARIO 504365] Notification about Nemhandel registration when company registration in Nemhandelsregisteret has not been checked for OnPrem environment.
        Initialize();

        // [GIVEN] OnPrem environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);

        // [GIVEN] Company Information with CVR number for which check if company is registered in Nemhandelsregisteret has not been made.
        NemhandelTests.MockCompanyStatusInPageBackgroundTask(Enum::"Nemhandel Company Status"::Unknown);
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::Unknown);
        BindSubscription(NemhandelTests);
        Commit();

        // [WHEN] Open Company Information page.
        CompanyInformationPage.OpenEdit();

        // [THEN] No notifications were shown on Company Information page.
        LibraryVariableStorage.AssertEmpty();

        // restore to SaaS environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
    end;

    [Test]
    procedure NotificationNotShownWhenSandboxCompanyStatusUnknown()
    var
        NemhandelTests: Codeunit "Nemhandel Tests";
        CompanyInformationPage: TestPage "Company Information";
    begin
        // [SCENARIO 504365] Notification about Nemhandel registration when company registration in Nemhandelsregisteret has not been checked for Sandbox environment.
        Initialize();

        // [GIVEN] Sandbox environment
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(true);

        // [GIVEN] Company Information with CVR number for which check if company is registered in Nemhandelsregisteret has not been made.
        NemhandelTests.MockCompanyStatusInPageBackgroundTask(Enum::"Nemhandel Company Status"::Unknown);
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::Unknown);
        BindSubscription(NemhandelTests);
        Commit();

        // [WHEN] Open Company Information page.
        CompanyInformationPage.OpenEdit();

        // [THEN] No notifications were shown on Company Information page.
        LibraryVariableStorage.AssertEmpty();

        // restore to production environment
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
    end;

    [Test]
    procedure CVRNumberValidFormat()
    var
        CompanyInformationPage: TestPage "Company Information";
    begin
        // [SCENARIO 523681] Enter CVR number to Registration No. field when it is 8 digits or "A/S" followed by 3-6 digits.
        Initialize();
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::NotRegistered);

        // [GIVEN] Opened Company Information page.
        CompanyInformationPage.OpenEdit();

        // [WHEN] Fill Registration No. with 8 digits.
        // [THEN] The value was set.
        CompanyInformationPage."Registration No.".SetValue('87654321');
        Assert.AreEqual('87654321', CompanyInformationPage."Registration No.".Value(), '');

        // [WHEN] Fill Registration No. with A/S followed by 4 digits.
        // [THEN] The value was set.
        CompanyInformationPage."Registration No.".SetValue('A/S1234');
        Assert.AreEqual('A/S1234', CompanyInformationPage."Registration No.".Value(), '');
    end;

    [Test]
    procedure CVRNumberNotValidFormat()
    var
        CompanyInformationPage: TestPage "Company Information";
    begin
        // [SCENARIO 523681] Enter CVR number to Registration No. field when it is not 8 digits and not "A/S" followed by 3-6 digits.
        Initialize();
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::NotRegistered);

        // [GIVEN] Opened Company Information page.
        CompanyInformationPage.OpenEdit();

        // [WHEN] Fill Registration No. with letters.
        // [THEN] Error "The CVR number must be 8 digits or "A/S" followed by 3-6 digits" is thrown.
        asserterror CompanyInformationPage."Registration No.".SetValue('ABC12345');
        Assert.ExpectedError(IncorrectCVRNumberFormatErr);

        // [WHEN] Fill Registration No. with digits and spaces.
        // [THEN] Error "The CVR number must be 8 digits or "A/S" followed by 3-6 digits" is thrown.
        asserterror CompanyInformationPage."Registration No.".SetValue('12345 678');
        Assert.ExpectedError(IncorrectCVRNumberFormatErr);

        // [WHEN] Fill Registration No. with 5 digits.
        // [THEN] Error "The CVR number must be 8 digits or "A/S" followed by 3-6 digits" is thrown.
        asserterror CompanyInformationPage."Registration No.".SetValue('12345');
        Assert.ExpectedError(IncorrectCVRNumberFormatErr);

        // [WHEN] Fill Registration No. with special chars.
        // [THEN] Error "The CVR number must be 8 digits or "A/S" followed by 3-6 digits" is thrown.
        asserterror CompanyInformationPage."Registration No.".SetValue('123-45$%67');
        Assert.ExpectedError(IncorrectCVRNumberFormatErr);

        // [WHEN] Fill Registration No. with spaces only.
        // [THEN] Error "The CVR number must be 8 digits or "A/S" followed by 3-6 digits" is thrown.
        asserterror CompanyInformationPage."Registration No.".SetValue('   ');
        Assert.ExpectedError(IncorrectCVRNumberFormatErr);
    end;

    [Test]
    [HandlerFunctions('NotificationHandler')]
    procedure CVRFormatNotificationShownWhenNotValidCVRNumberFormat()
    var
        CompanyInformationPage: TestPage "Company Information";
        NotificationText: Text;
    begin
        // [SCENARIO 524541] Notification about CVR number format when CVR number is not 8 digits and not "A/S" followed by 3-6 digits.
        Initialize();

        // [GIVEN] Company Information with CVR number containing letters.
        UpdateCompanyCVRNumber('ABC12345');

        // [WHEN] Open Company Information page.
        CompanyInformationPage.OpenEdit();

        // [THEN] Notification "The Registration No. must be 8 digits or "A/S" followed by 3-6 digits" was shown on Company Information page.
        NotificationText := LibraryVariableStorage.DequeueText();
        Assert.ExpectedMessage(IncorrectCVRNumberFormatTxt, NotificationText);

        // [THEN] Notification "Your accounting software is not registered in Nemhandelsregisteret" was also shown on Company Information page.
        NotificationText := LibraryVariableStorage.DequeueText();
        Assert.ExpectedMessage(NemhandelNotRegisteredTxt, NotificationText);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('NotificationHandler')]
    procedure CVRFormatNotificationNotShownWhenBlankCVRNumber()
    var
        CompanyInformationPage: TestPage "Company Information";
        NotificationText: Text;
    begin
        // [SCENARIO 524541] Notification about CVR number format when CVR number is blank.
        Initialize();

        // [GIVEN] Company Information with blank CVR number.
        UpdateCompanyCVRNumber('');

        // [WHEN] Open Company Information page.
        CompanyInformationPage.OpenEdit();

        // [THEN] Only notification "Your accounting software is not registered in Nemhandelsregisteret" was shown on Company Information page.
        NotificationText := LibraryVariableStorage.DequeueText();
        Assert.ExpectedMessage(NemhandelNotRegisteredTxt, NotificationText);

        // [THEN] No more notifications were shown on Company Information page.
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure CVRFormatNotificationNotShownWhenValidNewCVRNumberFormat()
    var
        CompanyInformationPage: TestPage "Company Information";
    begin
        // [SCENARIO 524541] Notification about CVR number format when CVR number has 8 digits.
        Initialize();

        // [GIVEN] Company Information with CVR number containing 8 digits.
        UpdateCompanyCVRNumber('87654321');

        // [GIVEN] Nemhandel registration status is set to "Registered" to avoid Nemhandel registration notification.
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::Registered);

        // [GIVEN] Opened Company Information page.
        CompanyInformationPage.OpenEdit();

        // [THEN] No notifications were shown on Company Information page.
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure CVRFormatNotificationNotShownWhenValidOldCVRNumberFormat()
    var
        CompanyInformationPage: TestPage "Company Information";
    begin
        // [SCENARIO 524541] Notification about CVR number format when CVR number has "A/S" followed by 4 digits.
        Initialize();

        // [GIVEN] Company Information with CVR number A/S followed by 4 digits.
        UpdateCompanyCVRNumber('A/S1234');

        // [GIVEN] Nemhandel registration status is set to "Registered" to avoid Nemhandel registration notification.
        UpdateRegisteredWithNemhandel(Enum::"Nemhandel Company Status"::Registered);

        // [GIVEN] Opened Company Information page.
        CompanyInformationPage.OpenEdit();

        // [THEN] No notifications were shown on Company Information page.
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure Initialize()
    begin
        UpdateCompanyCVRNumber('12345678');

        if IsInitialized then
            exit;

        // Set SaaS production environment.
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);

        IsInitialized := true;
    end;

    local procedure DisableForecastNotification()
    var
        CashFlowForecastHandler: Codeunit "Cash Flow Forecast Handler";
        DummyNotification: Notification;
    begin
        CashFlowForecastHandler.DeactivateNotification(DummyNotification);
    end;

    local procedure GetCompanyCVRNumber(): Text[20]
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        exit(CompanyInformation."Registration No.");
    end;

    local procedure GetResponseBodyText(CVRNumber: Text): Text
    begin
        exit(
            StrSubstNo('{"cvrNummer":"%1",', CVRNumber) +
            '"virksomhedsForm":"Anpartsselskab","binavne":[],"virksomhedsNavnFormel":"CRONUS International",' +
            '"adresse":{"fritekst":null,"vejnavn":"Fyrrehaven","bogstavTil":null,"conavn":null,"bogstavFra":null,' +
            '"husnummerFra":123,"postboks":null,"postnummer":1234,"etage":null,"husnummerTil":null,"sidedoer":null,' +
            '"landekode":"DK","postdistrikt":"Vig"},"modtagere":null,"kontaktperson":null,"status":"NORMAL"}');
    end;

    local procedure UpdateRegisteredWithNemhandel(NewValue: Enum "Nemhandel Company Status")
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Registered with Nemhandel" := NewValue;
        CompanyInformation.Modify();
    end;

    local procedure UpdateCompanyCVRNumber(CVRNumber: Text[20])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Registration No." := CVRNumber;
        CompanyInformation.Modify();
    end;

    local procedure UpdateEvaluationOnCompany(IsEvaluation: Boolean)
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName());
        Company."Evaluation Company" := IsEvaluation;
        Company.Modify();
    end;

    procedure MockCompanyStatusInPageBackgroundTask(NewStatus: Enum "Nemhandel Company Status")
    begin
        CompanyStatusGlobal := NewStatus;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Company Information", 'OnAfterGetCompanyStatusCompanyInfoBckgrndTask', '', false, false)]
    local procedure MockStatusOnAfterGetCompanyStatusCompanyInfoBckgrndTask(var CompanyStatus: Enum "Nemhandel Company Status")
    begin
        CompanyStatus := CompanyStatusGlobal;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Accountant Activities", 'OnAfterGetCompanyStatusAccountantActivitBckgrndTask', '', false, false)]
    local procedure MockStatusOnAfterGetCompanyStatusAccountantActivitBckgrndTask(var CompanyStatus: Enum "Nemhandel Company Status")
    begin
        CompanyStatus := CompanyStatusGlobal;
    end;

    [EventSubscriber(ObjectType::Page, Page::"O365 Activities", 'OnAfterGetCompanyStatusO365ActivitBckgrndTask', '', false, false)]
    local procedure MockStatusOnAfterGetCompanyStatusO365ActivitBckgrndTask(var CompanyStatus: Enum "Nemhandel Company Status")
    begin
        CompanyStatus := CompanyStatusGlobal;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales & Relationship Mgr. Act.", 'OnAfterGetCompanyStatusSalesMgrActivitBckgrndTask', '', false, false)]
    local procedure MockStatusOnAfterGetCompanyStatusSalesMgrActivitBckgrndTask(var CompanyStatus: Enum "Nemhandel Company Status")
    begin
        CompanyStatus := CompanyStatusGlobal;
    end;

    [EventSubscriber(ObjectType::Page, Page::"SO Processor Activities", 'OnAfterGetCompanyStatusSOProcessorActivitBckgrndTask', '', false, false)]
    local procedure MockStatusOnAfterGetCompanyStatusSOProcessorActivitBckgrndTask(var CompanyStatus: Enum "Nemhandel Company Status")
    begin
        CompanyStatus := CompanyStatusGlobal;
    end;

    [EventSubscriber(ObjectType::Page, Page::"User Security Activities", 'OnAfterGetCompanyStatusUserSecActivitBckgrndTask', '', false, false)]
    local procedure MockStatusOnAfterGetCompanyStatusUserSecActivitBckgrndTask(var CompanyStatus: Enum "Nemhandel Company Status")
    begin
        CompanyStatus := CompanyStatusGlobal;
    end;

    [SendNotificationHandler(true)]
    procedure NotificationHandler(var Notification: Notification): Boolean
    begin
        LibraryVariableStorage.Enqueue(Notification.Message);
    end;
}
