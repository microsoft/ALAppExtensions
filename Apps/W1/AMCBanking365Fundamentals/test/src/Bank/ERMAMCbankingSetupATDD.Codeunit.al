codeunit 134410 "ERM AMC banking Setup ATDD"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [AMC Banking Fundamentals]
    end;

    var
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryUtility: Codeunit "Library - Utility";
        IsolatedStorageManagement: Codeunit "Isolated Storage Management";
        UnsecureUriErr: Label 'The URI is not secure.';
        InvalidUriErr: Label 'The URI is not valid.';
        PasswordDoesNotMatchErr: Label 'The password from the database does not match the one that was introduced.';
        EncryptionIsNotActiveErr: Label 'The encryption was not activated.';
        EncryptionIsActiveErr: Label 'The encryption is activated and it should not be.';
        HandlerResponse: Boolean;
        MissingCredentialsErr: Label 'The user name and password must be filled';

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,BlankAMCBankingSetupModalHandler,DataEncryprtionHandler')]
    [Scope('OnPrem')]
    procedure CheckCredentialsShouldOpenSetupPageInRealCompany()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
    begin
        Initialize();

        // [GIVEN] "AMC Bank Service Setup" table is empty
        AMCBankingSetup.DeleteAll();
        // [GIVEN] The Company is NOT Demo Company
        SetDemoCompany(false);
        // [GIVEN] Run CheckCredentials()()
        AMCBankingMgt.CheckCredentials();

        // [WHEN] Answer 'Yes' to the confirmation 'Do you want to open the Setup page?'
        // answer Yes by ConfirmHandlerYes

        // [THEN] "AMC Bank Service Setup" page is open,
        // [THEN] Where User/Password are empty, the links are filled
        // verify by BlankAMCBankingSetupModalHandler
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,AMCBankingSetupModalHandlerBlankPassword')]
    [Scope('OnPrem')]
    procedure CheckCredentialsShouldFailIfPasswordIsBlank()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
    begin
        Initialize();

        // [GIVEN] AMC Bank Service Setup table is empty
        AMCBankingSetup.DeleteAll(true);
        // [GIVEN] The Company is NOT a Demo Company
        SetDemoCompany(false);
        // [GIVEN] Run CheckCredentials()()
        asserterror AMCBankingMgt.CheckCredentials();

        // [GIVEN] Answer 'Yes' to the confirmation 'Do you want to open the Setup page?'
        // answer Yes by ConfirmHandlerYes

        // [WHEN] Keep the blank Password on the "AMC Bank Service Setup" page and close page
        // handled by AMCBankingSetupModalHandlerBlankPassword

        // [THEN] Error message: 'The user name and password must be filled'
        Assert.ExpectedError(MissingCredentialsErr);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerNo')]
    [Scope('OnPrem')]
    procedure CheckCredentialsShouldFailIfUserCancelConfirmation()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
    begin
        Initialize();

        // [GIVEN] AMC Bank Service Setup table is empty
        AMCBankingSetup.DeleteAll();
        // [GIVEN] The Company is NOT a Demo Company
        SetDemoCompany(false);
        // [GIVEN] Run CheckCredentials()
        asserterror AMCBankingMgt.CheckCredentials();

        // [GIVEN] Answer 'No' to the confirmation 'Do you want to open the Setup page?'
        // answer No by ConfirmHandlerNo

        // [THEN] Error message: 'The user name and password must be filled'
        Assert.ExpectedError(MissingCredentialsErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UserCanStoreHisAMCSetupInformation()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        PasswordAMC: Text;
        UserNameAMC: Text[50];
    begin
        // [FEATURE] [Password]
        // [SCENARIO 1] As a an Administrator I will store the User ID and Password obtained from the AMC Service site into Dynamics Nav,
        // this is used to enable bank data file conversion to happen from DynamicsNav.
        // [GIVEN] A User ID and password obtained from the AMC service site.
        // [WHEN] Username and Password is entered into the AMC Bank Service Setup
        // [THEN] The AMC Integration would be able to obtain User ID and Password to make use of the AMC Service, the Service URL was
        // automaticaly prepopulated
        Initialize();

        // Setup: Clear the existing setup
        if AMCBankingSetup.Get() then
            AMCBankingSetup.Delete();

        // Setup: Optain username and password
        UserNameAMC :=
          LibraryUtility.GenerateRandomCode(AMCBankingSetup.FieldNo("User Name"), DATABASE::"AMC Banking Setup");
        PasswordAMC := GenerateRandomPassword();

        // Execute: Save username and password in service setup
        AMCBankingSetup.Init();
        AMCBankingSetup.Validate("User Name", UserNameAMC);
        AMCBankingSetup.SavePassword(PasswordAMC);
        AMCBankingSetup."AMC Enabled" := true;
        AMCBankingSetup.Insert();
        AMCBankingSetup.SetURLsToDefault();

        // Validate
        ValidateSetup(UserNameAMC, PasswordAMC);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UserCanChangeHisAMCPassword()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        PasswordAMC: Text;
        UserNameAMC: Text[50];
    begin
        // [FEATURE] [Password]
        // [SCENARIO 2] As a an Administrator I will update the User ID and Password obtained from the AMC Service site into Dynamics Nav,
        // this is used to enable bank data file conversion to happen from DynamicsNav.
        // [GIVEN] A new User ID and password obtained from the AMC service site and an existing AMC Bank Service Setup.
        // [WHEN] The new Username and Password is entered into the existing AMC Bank Service Setup
        // [THEN] The AMC Integration would be able to obtain the updated User ID and Password to make use of the AMC Service, the
        // Service URL will remain unchanged.
        Initialize();

        // Setup: Optain username and password
        UserNameAMC :=
          LibraryUtility.GenerateRandomCode(AMCBankingSetup.FieldNo("User Name"), DATABASE::"AMC Banking Setup");
        PasswordAMC := GenerateRandomPassword();

        // Execute: Save username and password in service setup
        AMCBankingSetup.Get();
        AMCBankingSetup.Validate("User Name", UserNameAMC);
        AMCBankingSetup.SavePassword(PasswordAMC);
        AMCBankingSetup.Modify();

        // Validate
        ValidateSetup(UserNameAMC, PasswordAMC);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UserCanChangeTheAMCSetupURL()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        PasswordAMC: Text;
        SignupAMC: Text[250];
    begin
        // [FEATURE] [URL]
        // [SCENARIO 3] As a an Administrator I will be able to update the Sign-up URL for the AMC service,
        // this is used to enable bank data file conversion to happen from DynamicsNav.
        // [GIVEN] A Sign-up URL and an existing AMC Bank Service Setup.
        // [WHEN] The Sign-up URL is entered into the existing AMC Bank Service Setup
        // [THEN] The Sign-up URL is save to make it simple to do the AMC Sign-up, User ID and Password
        // will remain unchanged.
        Initialize();

        // Setup: Optain username and SignupURL
        AMCBankingSetup.Get();
        PasswordAMC := AMCBankingSetup.GetPassword();
        SignupAMC :=
          LibraryUtility.GenerateRandomCode(AMCBankingSetup.FieldNo("Sign-up URL"), DATABASE::"AMC Banking Setup");

        // Execute: Save username and password in service setup
        AMCBankingSetup.Get();
        AMCBankingSetup.Validate("Sign-up URL", SignupAMC);
        AMCBankingSetup.Modify();

        // Validate
        AMCBankingSetup.Get();
        Assert.AreEqual(PasswordAMC, AMCBankingSetup.GetPassword(), 'Password invalid');
        Assert.AreEqual(SignupAMC, AMCBankingSetup."Sign-up URL", 'Sign-up invalid');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UserCanChangeTheAMCServiceURL()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        LibraryRandom: Codeunit "Library - Random";
        PasswordAMC: Text;
        ServiceURLAMC: Text[250];
        UserNameAMC: Text[50];
    begin
        // [FEATURE] [URL]
        // [SCENARIO 4] As a an Administrator I will be able to update the Service URL for the AMC service,
        // this is used to enable bank data file conversion to happen from DynamicsNav.
        // [GIVEN] A Service URL and an existing AMC Bank Service Setup.
        // [WHEN] The Service URL is entered into the existing AMC Bank Service Setup
        // [THEN] The AMC Integration would be able to get the changed Service URL and use it to connect to the AMC service, User ID and Password
        // will be reset.
        Initialize();

        // Setup: Optain password and Service URL
        AMCBankingSetup.Get();
        AMCBankingSetup."User Name" := CopyStr(LibraryRandom.RandText(50), 1, MaxStrLen(AMCBankingSetup."User Name"));
        AMCBankingSetup.SavePassword(LibraryRandom.RandText(50));
        AMCBankingSetup.Modify();

        PasswordAMC := AMCBankingSetup.GetPassword();
        UserNameAMC := AMCBankingSetup.GetUserName();

        ServiceURLAMC := GenerateRandomUrl(true);

        // Execute: Save username and password in service setup
        AMCBankingSetup.Get();
        AMCBankingSetup.Validate("Service URL", ServiceURLAMC);
        AMCBankingSetup.Modify();

        // Validate
        AMCBankingSetup.Get();
        Assert.AreNotEqual(PasswordAMC, AMCBankingSetup.GetPassword(), 'Password must be reset when changing service URL');
        Assert.AreNotEqual(UserNameAMC, AMCBankingSetup.GetUserName(), 'Username must be reset when changing service URL');
        Assert.AreEqual(ServiceURLAMC, AMCBankingSetup."Service URL", 'Service URL invalid');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UserCanChangeTheAMCServiceURLToBeBlank()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        ServiceURLAMC: Text[250];
    begin
        // [FEATURE] [URL]
        // [SCENARIO 8] As an Administrator I will be able to update the Service URL for the AMC service as BLANK.
        // [GIVEN] An existing AMC Bank Service Setup.
        // [WHEN] The existng Service URL is deleted
        // [THEN] The field validation does not fail on a BLANK value in the Service URL field.
        Initialize();

        // Setup: Create a valid AMC Banking Setup record
        ServiceURLAMC := GenerateRandomUrl(true);
        AMCBankingSetup.Get();
        AMCBankingSetup.Validate("Service URL", ServiceURLAMC);
        AMCBankingSetup.Modify();

        // Execute: Reset the Service URL to a BLANK
        AMCBankingSetup.Validate("Service URL", '');
        AMCBankingSetup.Modify();

        // Validate: That the BLANK is saved
        AMCBankingSetup.Get();
        Assert.AreEqual('', AMCBankingSetup."Service URL", 'Service URL is not set to empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UserCanEnterOnlySecureURLAsTheAMCServiceURL()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        ServiceURLAMC: Text[250];
    begin
        // [FEATURE] [URL]
        // [SCENARIO 9] As an Administrator I will only be able to create and update the Service URL for the AMC service that is secure.
        // [GIVEN] A new AMC Bank Service Setup.
        // [WHEN] A unsecure URL is entered in the Service URL field of the AMC Bank Service Setup
        // [THEN] Error is thrown.
        Initialize();
        // Setup: Generate a random unsecure URL
        ServiceURLAMC := GenerateRandomUrl(false);

        // Execute: Set the Service URL to the generated unsecure URL
        AMCBankingSetup.Get();
        asserterror AMCBankingSetup.Validate("Service URL", ServiceURLAMC);

        // Validate: Exception is thrown
        Assert.ExpectedError(UnsecureUriErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UserCanEnterOnlyValidURLAsTheAMCServiceURL()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        ServiceURLAMC: Text[250];
    begin
        // [FEATURE] [URL]
        // [SCENARIO 10] As an Administrator I will be able to update the Service URL for the AMC service as BLANK.
        // [GIVEN] An new AMC Bank Service Setup.
        // [WHEN] An invalid URL is entered in the Service URL field of the AMC Bank Service Setup
        // [THEN] Error is thrown.
        Initialize();

        // Setup: Generate a random text URL
        ServiceURLAMC := CopyStr(LibraryUtility.GenerateRandomText(5), 1, 5);

        // Execute: Set the Service URL to the generated text which will result in an invalid URL
        AMCBankingSetup.Get();
        asserterror AMCBankingSetup.Validate("Service URL", ServiceURLAMC);

        // Validate: Exception is thrown
        Assert.ExpectedError(InvalidUriErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UserCanChangeTheAMCSupportURL()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        PasswordAMC: Text;
        SupportURLAMC: Text[250];
    begin
        // [FEATURE] [URL]
        // [SCENARIO 5] As an Administrator I will be able to update the Support URL for the AMC service,
        // this is used to enable bank data file conversion to show contact information in case of connection issues.
        // [GIVEN] A Support URL and an existing AMC Bank Service Setup.
        // [WHEN] The Support URL is entered into the existing AMC Bank Service Setup
        // [THEN] The AMC Integration would be able to get the changed Support URL and use it to connect to the AMC service error
        // information, User ID and Password will remain unchanged.
        Initialize();

        // Setup: Optain username and Support URL
        AMCBankingSetup.Get();
        PasswordAMC := AMCBankingSetup.GetPassword();
        SupportURLAMC :=
          LibraryUtility.GenerateRandomCode(AMCBankingSetup.FieldNo("Service URL"), DATABASE::"AMC Banking Setup");

        // Execute: Save username and password in service setup
        AMCBankingSetup.Get();
        AMCBankingSetup.Validate("Support URL", SupportURLAMC);
        AMCBankingSetup.Modify();

        // Validate
        AMCBankingSetup.Get();
        Assert.AreEqual(PasswordAMC, AMCBankingSetup.GetPassword(), 'Password invalid');
        Assert.AreEqual(SupportURLAMC, AMCBankingSetup."Support URL", 'Support URL invalid');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UserCanDeleteTheAMCSetupInformation()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        PasswordKey: Guid;
    begin
        // [FEATURE] [Password]
        // [SCENARIO 6] As a an Administrator I will remove the service setup to prevent use of hte AMC serive
        // [GIVEN] An existing AMC Bank Service Setup.
        // [WHEN] Delete of existing AMC Bank Service Setup
        // [THEN] The AMC Integration would NOT be able to obtain the updated User ID and Password to make use of the AMC Service
        Initialize();

        // Execute: Save username and password in service setup
        AMCBankingSetup.Get();
        PasswordKey := AMCBankingSetup."Password Key";
        AMCBankingSetup.Delete(true);

        // Validate
        Assert.IsFalse(AMCBankingSetup.Get(), 'Setup should not exist');
        Assert.IsFalse(IsolatedStorageManagement.Contains(PasswordKey, DATASCOPE::Company), 'Password should not exist');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UserCanSeeThatAPasswordExist()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        // [FEATURE] [Password]
        // [SCENARIO 7] As a an Administrator I can see that a password exist
        // [GIVEN] An existing AMC Bank Service Setup.
        // [WHEN] Open AMC Bank Service Setup
        // [THEN] Password should show ******
        Initialize();

        // Execute: Save username and password in service setup
        AMCBankingSetup.Get();

        // Validate: The HasPassword used by UI
        Assert.IsTrue(AMCBankingSetup.HasPassword(), 'Password should exist');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerNo')]
    [Scope('OnPrem')]
    procedure StorePasswordWithoutEncryption()
    var
        AMCBankingSetupRec: Record "AMC Banking Setup";
        CryptographyManagement: Codeunit "Cryptography Management";
        AMCBankingSetup: TestPage "AMC Banking Setup";
    begin
        // [FEATURE] [Password]
        // [SCENARIO 11] The user enters a new password.
        // [GIVEN] There is no password set for the conversion service.
        // [WHEN] The user enters a new password.
        // [THEN] The password will be stored in clear text.
        Initialize();

        // Setup
        if CryptographyManagement.IsEncryptionEnabled() then
            CryptographyManagement.DisableEncryption(true);

        AMCBankingSetup.OpenEdit();
        AMCBankingSetup.Password.SetValue('');

        // Execute
        AMCBankingSetup.Password.SetValue('Random Words');
        AMCBankingSetup.OK().Invoke();

        // Verify
        Assert.IsFalse(EncryptionEnabled(), EncryptionIsActiveErr);

        AMCBankingSetupRec.Get();
        Assert.AreEqual('Random Words', AMCBankingSetupRec.GetPassword(), PasswordDoesNotMatchErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure StorePasswordWithEncryption()
    var
        AMCBankingSetupRec: Record "AMC Banking Setup";
        CryptographyManagement: Codeunit "Cryptography Management";
        AMCBankingSetup: TestPage "AMC Banking Setup";
    begin
        // [FEATURE] [Password]
        // [SCENARIO 12] The user enters a new password.
        // [GIVEN] There is no password set for the conversion service.
        // [WHEN] The user enters a new password.
        // [THEN] The password will be stored encrypted.
        Initialize();

        // Setup
        if CryptographyManagement.IsEncryptionEnabled() then
            CryptographyManagement.DisableEncryption(true);

        AMCBankingSetup.OpenEdit();
        AMCBankingSetup.Password.SetValue('');
        CryptographyManagement.EnableEncryption(true);

        // Execute
        AMCBankingSetup.Password.SetValue('Random Words 2');
        AMCBankingSetup.OK().Invoke();

        // Verify
        AMCBankingSetupRec.Get();

        Assert.AreEqual('Random Words 2', AMCBankingSetupRec.GetPassword(), PasswordDoesNotMatchErr);
        Assert.IsTrue(EncryptionEnabled(), EncryptionIsNotActiveErr);

        // Clean-up
        CryptographyManagement.DisableEncryption(true);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYesNo')]
    [Scope('OnPrem')]
    procedure StorePasswordWithoutEncryptionAndCheckConfirmDialog()
    var
        AMCBankingSetupRec: Record "AMC Banking Setup";
        CryptographyManagement: Codeunit "Cryptography Management";
        AMCBankingSetup: TestPage "AMC Banking Setup";
        DataEncryptionManagement: TestPage "Data Encryption Management";
    begin
        // [FEATURE] [Password]
        // [SCENARIO 13] The user enters a new password and a confirmation dialog appears.
        // [GIVEN] There is no password set for the conversion service.
        // [WHEN] The user enters a new password.
        // [THEN] The password will be stored in clear text and a confirmation dialog appears.
        Initialize();

        // Setup
        HandlerResponse := true;
        if CryptographyManagement.IsEncryptionEnabled() then
            CryptographyManagement.DisableEncryption(true);

        DataEncryptionManagement.Trap();
        AMCBankingSetup.OpenEdit();
        AMCBankingSetup.Password.SetValue('');

        // Execute
        AMCBankingSetup.Password.SetValue('Random Words 3');

        AMCBankingSetup.OK().Invoke();

        DataEncryptionManagement.OK().Invoke();

        // Verify
        Assert.IsFalse(EncryptionEnabled(), EncryptionIsActiveErr);

        AMCBankingSetupRec.Get();
        Assert.AreEqual('Random Words 3', AMCBankingSetupRec.GetPassword(), PasswordDoesNotMatchErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AMCBankingSetupIsCreatedIfItDoesNotExist()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        AMCBankingSetupPage: TestPage "AMC Banking Setup";
    begin
        // [FEATURE] [URL] [Demo Company]
        // [SCENARIO 14] As an admin, when I open the conv setup page I can see the default URLs.
        Initialize();

        SetDemoCompany(true);
        // [GIVEN] There is no conversion setup record.
        AMCBankingSetup.DeleteAll();

        // [WHEN] The user opens the conversion setup page.
        AMCBankingSetupPage.OpenEdit();
        AMCBankingSetupPage.Password.SetValue(''); // to avoid encryption confirmation
        AMCBankingSetupPage.OK().Invoke();

        // [THEN] The defaul URLs are in place.
        AMCBankingSetup.Get();
        ValidateDefaultURLs(AMCBankingSetup);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PageInEditAllFieldsEditable()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        AMCBankingSetupTestPage: TestPage "AMC Banking Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 16] As an admin, when open AMC Banking Setup in edit all fields should be editable.
        Initialize();

        // [GIVEN] There is a default conversion setup record.
        // [WHEN] The user opens the conversion setup page in edit mode.
        AMCBankingSetupTestPage.OpenEdit();

        // [THEN] All fields editable.
        Assert.IsTrue(AMCBankingSetupTestPage."User Name".Editable(), 'User Name field should be editable');
        Assert.IsTrue(AMCBankingSetupTestPage.Password.Editable(), 'Password field should be editable');
        if (AMCBankingSetup.get()) then
            if (AMCBankingMgt.IsSolutionSandbox(AMCBankingSetup)) then
                Assert.IsFalse(AMCBankingSetupTestPage."Service URL".Editable(), 'Service URL field should not be editable')
            else
                Assert.IsTrue(AMCBankingSetupTestPage."Service URL".Editable(), 'Service URL field should be editable');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PageInViewAllFieldsReadOnly()
    var
        AMCBankingSetup: TestPage "AMC Banking Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 17] As an admin, when open AMC Banking Setup in view all fields should be read only.
        Initialize();

        // [GIVEN] There is a default conversion setup record.
        // [WHEN] The user opens the conversion setup page in view mode.
        AMCBankingSetup.OpenView();

        // [THEN] All fields read only.
        Assert.IsFalse(AMCBankingSetup."User Name".Editable(), 'User Name field should not be editable');
        Assert.IsFalse(AMCBankingSetup.Password.Editable(), 'Password field should not be editable');
        Assert.IsFalse(AMCBankingSetup."Service URL".Editable(), 'Service URL field should not be editable');
    end;

    local procedure Initialize()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"ERM AMC banking Setup ATDD");
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        AMCBankingSetup.DeleteAll();
        AMCBankingSetup.Init();
        AMCBankingSetup.Validate("User Name",
          LibraryUtility.GenerateRandomCode(AMCBankingSetup.FieldNo("User Name"), DATABASE::"AMC Banking Setup"));
        AMCBankingSetup.SavePassword(GenerateRandomPassword());
        AMCBankingSetup."AMC Enabled" := true;
        AMCBankingSetup.Insert(true);
    end;

    local procedure SetDemoCompany(DemoCompany: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Demo Company" := DemoCompany;
        CompanyInformation.Modify();
    end;

    local procedure ValidateSetup(ExpectedUserName: Text[50]; ExpectedPassword: Text)
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        AMCBankingSetup.Get();
        Assert.AreEqual(ExpectedUserName, AMCBankingSetup."User Name", 'User Name invalid');
        Assert.AreEqual(ExpectedPassword, AMCBankingSetup.GetPassword(), 'Password invalid');
        ValidateDefaultURLs(AMCBankingSetup);
    end;

    local procedure ValidateDefaultURLs(AMCBankingSetup: Record "AMC Banking Setup")
    var
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
    begin
        Assert.AreEqual(AMCBankingMgt.GetLicenseServerName() + AMCBankingMgt.GetLicenseRegisterTag(), AMCBankingSetup."Sign-up URL", 'Sign-up invalid');
        if ((AMCBankingSetup.Solution = AMCBankingMgt.GetDemoSolutionCode()) or
           (AMCBankingSetup.Solution = '')) then
            Assert.AreEqual('https://demoxtl.amcbanking.com/api04', AMCBankingSetup."Service URL", 'Service URL invalid') //V17.5
        else
            Assert.AreEqual('https://nav.amcbanking.com/api04', AMCBankingSetup."Service URL", 'Service URL invalid'); //V17.5
        Assert.AreEqual('https://amcbanking.com/landing365bc/help/', AMCBankingSetup."Support URL", 'Service URL invalid');
    end;

    local procedure GenerateRandomUrl(Secure: Boolean): Text[250]
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        RandomCode: Code[250];
        Prefix: Text[8];
    begin
        if Secure then
            Prefix := 'https://'
        else
            Prefix := 'http://';

        RandomCode :=
          LibraryUtility.GenerateRandomCode(AMCBankingSetup.FieldNo("Service URL"), DATABASE::"AMC Banking Setup");

        RandomCode := CopyStr(Prefix + RandomCode, 1, 250);
        exit(RandomCode);
    end;

    local procedure GenerateRandomPassword(): Text
    begin
        exit(LibraryUtility.GenerateRandomText(251));
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandlerNo(Question: Text; var Reply: Boolean)
    begin
        Reply := false;
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandlerYes(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandlerYesNo(Question: Text; var Reply: Boolean)
    begin
        Reply := HandlerResponse;
        HandlerResponse := not HandlerResponse;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure BlankAMCBankingSetupModalHandler(var AMCBankingSetupPage: TestPage "AMC Banking Setup")
    begin
        AMCBankingSetupPage."User Name".AssertEquals('demouser');
        Assert.ExpectedMessage('amc', AMCBankingSetupPage."Service URL".Value());
        // Set not blank Password to avoid an error
        AMCBankingSetupPage.Password.SetValue('P');
        AMCBankingSetupPage.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure AMCBankingSetupModalHandlerBlankPassword(var AMCBankingSetupPage: TestPage "AMC Banking Setup")
    begin
        // Password is blank
        AMCBankingSetupPage."User Name".SetValue('newuser');
        AMCBankingSetupPage.Password.SetValue('');
        AMCBankingSetupPage.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure AMCBankingSetupModalHandler(var AMCBankingSetupPage: TestPage "AMC Banking Setup")
    begin
        // Password is blank
        AMCBankingSetupPage.OK().Invoke();
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure DataEncryprtionHandler(var DataEncryptionManagement: TestPage "Data Encryption Management")
    begin
        DataEncryptionManagement.Close();
    end;
}
