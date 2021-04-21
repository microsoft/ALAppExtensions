codeunit 139523 "VAT Group Setup Guide Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    // Workaround description: the error, if the test fails, is thrown both in the failing test BUT ALSO in the procedure ConfirmHandlerYes (when present)
    // because otherwise the first error will be caught in the procedure OnQueryClosePage from the page "VAT Group Setup Guide".
    // If a test fails with the error message "Unhandled UI: Confirm The setup for the VAT Group is not finished.\\Are you sure you want to exit?"
    // it's probably because an error was thrown in a procedure where there is no ConfirmHandlerYes handler but the real error message has not been displayed
    // because it has been caught in the procedure OnQueryClosePage from the page "VAT Group Setup Guide".

    var
        Assert: Codeunit Assert;
        LibraryVATGroup: Codeunit "Library - VAT Group";
        LibraryERM: Codeunit "Library - ERM";

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure TestWelcomePageSection()
    var
        TestPageVATGroupSetupGuide: TestPage "VAT Group Setup Guide";
    begin
        // [SCENARIO 374187] Welcome Page Section

        // [WHEN] The environment is OnPrem
        EnableSaaS(false);

        // [WHEN] The user opens the Welcome page section
        TestPageVATGroupSetupGuide.OpenView();

        // [THEN] The Back button should be disabled, the Next button should be enabled and the Finish button should be disabled
        CheckButtons(TestPageVATGroupSetupGuide, false, true, false);

        TestPageVATGroupSetupGuide.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure TestSelectTypePageSection()
    var
        TestPageVATGroupSetupGuide: TestPage "VAT Group Setup Guide";
    begin
        // [SCENARIO 374187] Select Type Page Section

        // [WHEN] The environment is OnPrem
        EnableSaaS(false);

        // Welcome page section
        // [WHEN] When the user clicks Next to open the SelectType page section
        TestPageVATGroupSetupGuide.OpenEdit();
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // Select Type page section
        // [THEN] The Back button should be disabled, the Next button should be disabled and the Finish button should be enabled
        CheckButtons(TestPageVATGroupSetupGuide, false, false, true);
        // [THEN] The Field VATGroupRole should be visible
        Assert.IsTrue(TestPageVATGroupSetupGuide.VATGroupRole.Visible(), 'The Field VATGroupRole should be visible');

        // [WHEN] The user chooses the Representative VAT Group Role
        TestPageVATGroupSetupGuide.VATGroupRole.SetValue(1);
        // [THEN] The Back button should be enabled, the Next button should be enabled and the Finish button should be disabled
        CheckButtons(TestPageVATGroupSetupGuide, true, true, false);

        // [WHEN] The user chooses the empty VAT Group Role
        TestPageVATGroupSetupGuide.VATGroupRole.SetValue(0);
        // [THEN] The Back button should be disabled, the Next button should be disabled and the Finish button should be enabled
        CheckButtons(TestPageVATGroupSetupGuide, false, false, true);

        // [WHEN] The user chooses the Member VAT Group Role
        TestPageVATGroupSetupGuide.VATGroupRole.SetValue(2);
        // [THEN] The Back button should be enabled, the Next button should be enabled and the Finish button should be disabled
        CheckButtons(TestPageVATGroupSetupGuide, true, true, false);

        TestPageVATGroupSetupGuide.Close();
    end;

    [Test]
    [HandlerFunctions('VATGroupApprovedMemberListHandler')]
    procedure TestRepresentativeSetup()
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        TestPageVATGroupSetupGuide: TestPage "VAT Group Setup Guide";
    begin
        // [SCENARIO 374187] Representative Setup

        // [WHEN] The environment is OnPrem
        EnableSaaS(false);

        // Clear the table and populate it with a new approved member
        LibraryVATGroup.ClearApprovedMembers();
        LibraryVATGroup.MockVATGroupApprovedMember();

        // Welcome page section
        // [WHEN] The user clicks Next to open the SelectType page section
        TestPageVATGroupSetupGuide.OpenEdit();
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // Select Type page section
        // [WHEN] The user chooses the Representative VAT Group Role and clicks Next to open the Approved Members page section
        TestPageVATGroupSetupGuide.VATGroupRole.SetValue(1);
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // Approved Members page section
        // [THEN] The Back button should be enabled, the Next button should be enabled and the Finish button should be disabled
        // CheckButtons(TestPageVATGroupSetupGuide, true, true, false);
        CheckButtons(TestPageVATGroupSetupGuide, true, false, false);
        // [THEN] The ApprovedMembers link should be visible
        Assert.IsTrue(TestPageVATGroupSetupGuide.ApprovedMembers.Visible(), 'Approved Members button should be visible');

        // [THEN] Only one approved member should be present
        TestPageVATGroupSetupGuide.ApprovedMembers.AssertEquals(1);

        // [WHEN] The user clicks the link the Page "VAT Group Approved Member List" opens
        // [WHEN] The user add a new approved member in the page (handler function)
        TestPageVATGroupSetupGuide.ApprovedMembers.Drilldown();
        // [THEN] Two approved members should be present
        TestPageVATGroupSetupGuide.ApprovedMembers.AssertEquals(2);

        // [WHEN] The user fills in the other required fields
        TestPageVATGroupSetupGuide.GroupSettlementAccount.SetValue(LibraryERM.CreateGLAccountNo());
        TestPageVATGroupSetupGuide.VATSettlementAccount.SetValue(LibraryERM.CreateGLAccountNo());
        TestPageVATGroupSetupGuide.VATDueBoxNo.SetValue(Random(100));
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        TestPageVATGroupSetupGuide.GroupSettlementGenJnlTempl.SetValue(GenJournalTemplate.Name);

        // [WHEN] The user clicks Next to open the Finish page section
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // Finish page section
        // [THEN] The Back button should be enabled, the Next button should be disabled and the Finish button should be enabled
        CheckButtons(TestPageVATGroupSetupGuide, true, false, true);
        // [THEN] The TestConnection button should not be visible
        Assert.IsFalse(TestPageVATGroupSetupGuide.TestConnection.Visible(), 'TestConnection button should not be visible');
        // [THEN] The ActionFinish button should be visible
        Assert.IsTrue(TestPageVATGroupSetupGuide.ActionFinish.Visible(), 'ActionFinish button should be visible');
        // [THEN] The "Enable JobQueue" button should not be visible
        Assert.IsFalse(TestPageVATGroupSetupGuide."Enable JobQueue".Visible(), '"Enable JobQueue" button should not be visible');

        // [WHEN] The user clicks the Finish button
        // [THEN] Setup is completed without errors
        TestPageVATGroupSetupGuide.ActionFinish.Invoke();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure TestMemberSetupPageSection()
    var
        TestPageVATGroupSetupGuide: TestPage "VAT Group Setup Guide";
    begin
        // [SCENARIO 374187] Member Setup Page Section

        // [WHEN] The environment is OnPrem
        EnableSaaS(false);

        // Welcome page section
        // [WHEN] The user clicks Next to open the SelectType page section
        TestPageVATGroupSetupGuide.OpenEdit();
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // SelectType page section
        // [WHEN] The user chooses the Member VAT Group Role
        TestPageVATGroupSetupGuide.VATGroupRole.SetValue(2);
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // [THEN] The Back button should be enabled, the Next button should be disabled and the Finish button should be disabled
        CheckButtons(TestPageVATGroupSetupGuide, true, false, false);

        // [THEN] The Back buttons MemberGuid,APIURL,GroupRepresentativeCompany,VATGroupAuthenticationType should be visible
        Assert.IsTrue(TestPageVATGroupSetupGuide.MemberGuid.Visible(), 'MemberGuid Field should be visible');
        Assert.IsTrue(
          TestPageVATGroupSetupGuide.GroupRepresentativeBCVersion.Visible(),
          'GroupRepresentativeBCVersion Field should be visible');
        Assert.IsTrue(TestPageVATGroupSetupGuide.APIURL.Visible(), 'APIURL Field should be visible');
        Assert.IsTrue(
          TestPageVATGroupSetupGuide.GroupRepresentativeCompany.Visible(), 'GroupRepresentativeCompany Field should be visible');
        Assert.IsTrue(
          TestPageVATGroupSetupGuide.VATGroupAuthenticationType.Visible(), 'VATGroupAuthenticationType Field should be visible');

        // [THEN] Default "Group Representative Product Version" = "Business Central"
        TestPageVATGroupSetupGuide.GroupRepresentativeBCVersion.AssertEquals('Business Central');

        // [THEN] The user can change the authentication type
        TestPageVATGroupSetupGuide.VATGroupAuthenticationType.SetValue(0); // Web Service Access key
        TestPageVATGroupSetupGuide.VATGroupAuthenticationType.SetValue(1); // OAuth2
        TestPageVATGroupSetupGuide.VATGroupAuthenticationType.SetValue(2); // Windows Authentication

        // [WHEN] The user types the required info
        TestPageVATGroupSetupGuide.APIURL.SetValue('TestValue');
        TestPageVATGroupSetupGuide.GroupRepresentativeCompany.SetValue('TestValue');
        // [THEN] The Back button should be enabled, the Next button should be enabled and the Finish button should be disabled
        CheckButtons(TestPageVATGroupSetupGuide, true, true, false);

        TestPageVATGroupSetupGuide.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure TestMemberSetupPageSectionSaas()
    var
        TestPageVATGroupSetupGuide: TestPage "VAT Group Setup Guide";
    begin
        // [SCENARIO 374187] Member Setup Page Section SaaS

        // [WHEN] The environment is OnPrem
        EnableSaaS(true);

        // Welcome page section
        // [WHEN] The user clicks Next to open the SelectType page section
        TestPageVATGroupSetupGuide.OpenEdit();
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // SelectType page section
        // [WHEN] The user chooses the Member VAT Group Role
        TestPageVATGroupSetupGuide.VATGroupRole.SetValue(2);
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // [THEN] The Back button should be enabled, the Next button should be disabled and the Finish button should be disabled
        CheckButtons(TestPageVATGroupSetupGuide, true, false, false);

        // [THEN] The Back buttons MemberGuid, APIURL, GroupRepresentativeCompany, VATGroupAuthenticationType should be visible
        Assert.IsTrue(TestPageVATGroupSetupGuide.MemberGuid.Visible(), 'MemberGuid Field should be visible');
        Assert.IsTrue(
          TestPageVATGroupSetupGuide.GroupRepresentativeBCVersion.Visible(), 'GroupRepresentativeBCVersion Field should be visible');
        Assert.IsTrue(TestPageVATGroupSetupGuide.APIURL.Visible(), 'APIURL Field should be visible');
        Assert.IsTrue(TestPageVATGroupSetupGuide.GroupRepresentativeCompany.Visible(), 'GroupRepresentativeCompany Field should be visible');
        Assert.IsTrue(TestPageVATGroupSetupGuide.VATGroupAuthenticationTypeSaas.Visible(), 'VATGroupAuthenticationTypeSaas Field should be visible');
        Assert.IsFalse(TestPageVATGroupSetupGuide.VATGroupAuthenticationType.Visible(), 'VATGroupAuthenticationType Field should not be visible');

        // [THEN] The user can change the authentication type
        asserterror TestPageVATGroupSetupGuide.VATGroupAuthenticationTypeSaas.SetValue(2); // Windows Authentication should not be visible
        ClearLastError(); // remove last error (expected error) otherwise test will fail when the handler ConfirmHandlerYes is called
        TestPageVATGroupSetupGuide.VATGroupAuthenticationTypeSaas.SetValue(0); // Web Service Access key
        TestPageVATGroupSetupGuide.VATGroupAuthenticationTypeSaas.SetValue(1); // OAuth2

        // [WHEN] The user types the required info
        TestPageVATGroupSetupGuide.APIURL.SetValue('TestValue');
        TestPageVATGroupSetupGuide.GroupRepresentativeCompany.SetValue('TestValue');
        // [THEN] The Back button should be enabled, the Next button should be enabled and the Finish button should be disabled
        CheckButtons(TestPageVATGroupSetupGuide, true, true, false);

        TestPageVATGroupSetupGuide.Close();
    end;

    [Test]
    procedure TestMemberWebServiceAccessKeyAuthenticationUntilFinishStep()
    var
        TestPageVATGroupSetupGuide: TestPage "VAT Group Setup Guide";
    begin
        // [SCENARIO 374187] Member Web Service Access Key Authentication Until Finish Step

        // [WHEN] The environment is OnPrem
        EnableSaaS(false);

        // Welcome page
        // [WHEN] The user clicks Next to open the SelectType page section
        TestPageVATGroupSetupGuide.OpenEdit();
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // SelectType page
        // [WHEN] The user chooses the Member VAT Group Role and clicks Next to open the Authentication section page
        TestPageVATGroupSetupGuide.VATGroupRole.SetValue(2);
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // Authentication section page
        // [WHEN] The user types the required info
        TestPageVATGroupSetupGuide.APIURL.SetValue('TestValue');
        TestPageVATGroupSetupGuide.GroupRepresentativeCompany.SetValue('TestValue');
        // [WHEN] The user set the authentication type to Web Service Access Key
        TestPageVATGroupSetupGuide.VATGroupAuthenticationType.SetValue(0);
        // [WHEN] The user clicks Next to open the Web Service Access Key Authentication page section
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // Web Service Access Key Authentication page section
        // [THEN] The Back button should be enabled, the Next button should be disabled and the Finish button should be disabled
        CheckButtons(TestPageVATGroupSetupGuide, true, false, false);
        // [THEN] The Username and WebServiceAccessKey fields should be visible
        Assert.IsTrue(TestPageVATGroupSetupGuide.Username.Visible(), 'The Username field should be visible');
        Assert.IsTrue(TestPageVATGroupSetupGuide.WebServiceAccessKey.Visible(), 'The WebServiceAccessKey field should be visible');

        // [WHEN] The user inserts the configuration values
        TestPageVATGroupSetupGuide.Username.SetValue('TestValue');
        TestPageVATGroupSetupGuide.WebServiceAccessKey.SetValue('TestValue');
        // [THEN] The Back button should be enabled, the Next button should be enabled and the Finish button should be disabled
        CheckButtons(TestPageVATGroupSetupGuide, true, true, false);
        // [WHEN] The user clicks Next to open the VAT Report Configuration page section
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // VAT Report Configuration page section
        // [THEN] The Back button should be enabled, the Next button should be enabled and the Finish button should be disabled
        CheckButtons(TestPageVATGroupSetupGuide, true, true, false);
        // [WHEN] The user clicks Next to open the Finish page section
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // Finish page section
        // [THEN] The Back button should be enabled, the Next button should be disabled and the Finish button should be enabled
        CheckButtons(TestPageVATGroupSetupGuide, true, false, true);
        // [THEN] The TestConnection button should be visible
        Assert.IsTrue(TestPageVATGroupSetupGuide.TestConnection.Visible(), 'The button TestConnection should be visible');
        // [THEN] The "Enable JobQueue" button should not be visible
        Assert.IsFalse(TestPageVATGroupSetupGuide."Enable JobQueue".Visible(), 'The button "Enable JobQueue" should not be visible');

        // [WHEN] The User click the TestConnection button
        // [THEN] A error is expected because the connection has wrong configuration values
        asserterror TestPageVATGroupSetupGuide.TestConnection.Invoke();

        // [THEN] The "Enable JobQueue" button should not be visible (it gets visible only when the TestConnection is successfully executed)
        Assert.IsFalse(TestPageVATGroupSetupGuide."Enable JobQueue".Visible(), 'The button "Enable JobQueue" should not be visible');

        // [WHEN] The user click the Finish button
        // [THEN] Setup is completed without errors
        TestPageVATGroupSetupGuide.ActionFinish.Invoke();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure TestMemberOAuth2UntilFinishStep()
    var
        TestPageVATGroupSetupGuide: TestPage "VAT Group Setup Guide";
    begin
        // [SCENARIO 374187] Member OAuth2 Until Finish Step

        // [WHEN] The environment is OnPrem
        EnableSaaS(false);

        // Welcome page
        // [WHEN] The user clicks Next to open the SelectType page section
        TestPageVATGroupSetupGuide.OpenEdit();
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // SelectType page
        // [WHEN] The user chooses the Member VAT Group Role and clicks Next to open the Authentication section page
        TestPageVATGroupSetupGuide.VATGroupRole.SetValue(2);
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // Authentication section page
        // [WHEN] The user types the required info
        TestPageVATGroupSetupGuide.APIURL.SetValue('TestValue');
        TestPageVATGroupSetupGuide.GroupRepresentativeCompany.SetValue('TestValue');
        // [WHEN] The user set the authentication type to OAuth2
        TestPageVATGroupSetupGuide.VATGroupAuthenticationType.SetValue(1);
        // [WHEN] The user clicks Next to open the OAuth2 page section
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // OAuth2 page section
        // [THEN] The Back button should be enabled, the Next button should be disabled and the Finish button should be disabled
        CheckButtons(TestPageVATGroupSetupGuide, true, false, false);
        // [THEN] The ClientID,Client Secret,OAuth 2.0 Authority Endpoint,OAuth 2.0 Resource URL and OAuth 2.0 Redirect URL fields should be visible
        Assert.IsTrue(TestPageVATGroupSetupGuide.ClientId.Visible(), 'ClientID field should be visible');
        Assert.IsTrue(TestPageVATGroupSetupGuide.ClientSecret.Visible(), 'Client Secret field should be visible');
        Assert.IsTrue(TestPageVATGroupSetupGuide.OAuthAuthorityUrl.Visible(), 'OAuth 2.0 Authority Endpoint field should be visible');
        Assert.IsTrue(TestPageVATGroupSetupGuide.ResourceURL.Visible(), 'OAuth 2.0 Resource URL field should be visible');
        Assert.IsTrue(TestPageVATGroupSetupGuide.RedirectURL.Visible(), 'OAuth 2.0 Redirect URL field should be visible');

        // [WHEN] The user add the required information to set up the OAuth
        TestPageVATGroupSetupGuide.ClientId.SetValue('TestValue');
        TestPageVATGroupSetupGuide.ClientSecret.SetValue('TestValue');
        TestPageVATGroupSetupGuide.OAuthAuthorityUrl.SetValue('http://OAuth-test-URL.com');
        TestPageVATGroupSetupGuide.ResourceURL.SetValue('http://OAuth-test-URL.com');
        TestPageVATGroupSetupGuide.RedirectURL.SetValue('http://OAuth-test-URL.com');
        // [THEN] The Back button should be enabled, the Next button should be enabled and the Finish button should be disabled
        CheckButtons(TestPageVATGroupSetupGuide, true, true, false);

        // [WHEN] The user clicks the Next button to test the OAuth connection
        // [THEN] A error is expected because from the test we cannot verify the authentication
        asserterror TestPageVATGroupSetupGuide.ActionNext.Invoke();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestMemberWindowsAuthentication()
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
        TestPageVATGroupSetupGuide: TestPage "VAT Group Setup Guide";
    begin
        // [SCENARIO 374187] Member Windows Authentication
        VATReportsConfiguration.DeleteAll();

        // [WHEN] The environment is OnPrem
        EnableSaaS(false);

        // Welcome page
        // [WHEN] The user clicks Next to open the SelectType page section
        TestPageVATGroupSetupGuide.OpenEdit();
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // SelectType page
        // [WHEN] The user chooses the Member VAT Group Role and clicks Next to open the Authentication section page
        TestPageVATGroupSetupGuide.VATGroupRole.SetValue(2);
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // Authentication section page
        // [WHEN] The user types the required info
        TestPageVATGroupSetupGuide.APIURL.SetValue(LibraryVATGroup.GetRepresentativeURL());
        TestPageVATGroupSetupGuide.GroupRepresentativeCompany.SetValue(CompanyName());
        // [WHEN] The user set the authentication type to Windows Authentication
        TestPageVATGroupSetupGuide.VATGroupAuthenticationType.SetValue(2);
        // [WHEN] The user clicks Next to open the VAT Report Configuration page section
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // VAT Report Configuration page section
        // [THEN] The Back button should be enabled, the Next button should be enabled and the Finish button should be disabled
        CheckButtons(TestPageVATGroupSetupGuide, true, true, false);
        // [WHEN] The user clicks Next to open the Finish page section
        TestPageVATGroupSetupGuide.ActionNext.Invoke();

        // Finish page section
        // [THEN] The Back button should be enabled, the Next button should be disabled and the Finish button should be enabled
        CheckButtons(TestPageVATGroupSetupGuide, true, false, true);
        Assert.IsTrue(TestPageVATGroupSetupGuide.TestConnection.Visible(), 'The button TestConnection should be visible');
        Assert.IsFalse(TestPageVATGroupSetupGuide."Enable JobQueue".Visible(), 'The button "Enable JobQueue" should not be visible');

        // [WHEN] The User click the TestConnection button
        // [THEN] The connection is successfully working
        TestPageVATGroupSetupGuide.TestConnection.Invoke();

        // Re-enable when batch request is fixed
        // [THEN] The "Enable JobQueue" button should be visible (it gets visible only when the TestConnection is successfully executed)
        // Assert.IsTrue(TestPageVATGroupSetupGuide."Enable JobQueue".Visible(), 'The button "Enable JobQueue" should be visible');

        // [WHEN] The user click the Finish button
        // [THEN] Setup is completed without errors
        TestPageVATGroupSetupGuide.ActionFinish.Invoke();

        // [WHEN] The setup is completed
        // [THEN] A VATGROUP record is inserted in the table "VAT Reports Configuration"
        VATReportsConfiguration.SetFilter("Submission Codeunit ID", Format(Codeunit::"VAT Group Submit To Represent."));
        VATReportsConfiguration.SetFilter("VAT Report Version", 'VATGROUP');
        Assert.RecordCount(VATReportsConfiguration, 1);
    end;

    local procedure EnableSaaS(IsSaaS: Boolean)
    var
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(IsSaaS);
    end;

    local procedure CheckButtons(var TestPageVATGroupSetupGuide: TestPage "VAT Group Setup Guide"; ActionBack: Boolean; ActionNext: Boolean; ActionFinish: Boolean);
    begin
        Assert.AreEqual(
          ActionBack, TestPageVATGroupSetupGuide.ActionBack.Enabled(), 'TestPageVATGroupSetupGuide.ActionBack.Enabled()');
        Assert.AreEqual(
          ActionNext, TestPageVATGroupSetupGuide.ActionNext.Enabled(), 'TestPageVATGroupSetupGuide.ActionNext.Enabled()');
        Assert.AreEqual(
          ActionFinish, TestPageVATGroupSetupGuide.ActionFinish.Enabled(), 'TestPageVATGroupSetupGuide.ActionFinish.Enabled()');
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;

        Assert.AreEqual('', GetLastErrorText(), GetLastErrorText());
    end;

    [ModalPageHandler]
    procedure VATGroupApprovedMemberListHandler(var VATGroupApprovedMemberList: TestPage "VAT Group Approved Member List")
    begin
        VATGroupApprovedMemberList.New();
        VATGroupApprovedMemberList.ID.SetValue(CreateGuid());
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;
}
