codeunit 132558 "AMC Banking Credential UT"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [AMC Banking Fundamentals]
    end;

    var
        Assert: Codeunit Assert;
        LibraryPaymentAMC: Codeunit "Library - Payment AMC";
        LibraryAmcWebService: Codeunit "Library - Amc Web Service";
        LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        LocalhostURLTxt: Label 'https://localhost:8080/', Locked = true;
        MissingCredentialsQst: Label 'The %1 is missing the user name or password. Do you want to open the %1 page?', Comment = '%1 = page name';
        MissingCredentialsErr: Label 'The user name and password must be filled in %1 page.', Comment = '%1 = page name';
        NoConnectionErr: Label 'Valid versions is: NAV01 NAV02 NAV03 API02 API04 ';
        SamplePmtXmlFile_EncodUTF8Txt: Label '<paymentExportBank xmlns="http://api04.soap.xml.link.amc.dk/"><amcpaymentreq xmlns=''''><banktransjournal><uniqueid>%1</uniqueid></banktransjournal></amcpaymentreq><bank>Danske DK</bank><language>ENU</language></paymentExportBank>', Locked = true; //V17.5
        CremulPathTxt: Label '/ns:reportExportResponse/return/cremul', Locked = true;
        EndBalanceNodePathTxt: Label '/ns:reportExportResponse/return/finsta/statement/', Locked = true;

    [Test]
    procedure AssistedSetupWithDemoUser();
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        TempOnlineBankAccLink: Record "Online Bank Acc. Link" temporary;
        AMCBankAssistedMgt: Codeunit "AMC Bank Assisted Mgt.";
        BasisSetupRunOK: Boolean;
    begin
        // [SCENARIO 1] Running assisted setup with Demouser in demosolution.
        // [GIVEN] Amcbanking setup with demouser credentials.
        // [WHEN] Run the Assisted setup wizard.
        // [THEN] Banklistname ist updated.
        // [THEN] Data Exchange is setup.
        // [THEN] Correct URLs are setup.

        // Initialize data for test
        Initialize();
        if (not AMCBankingSetup.Get()) then begin
            AMCBankingSetup.Init();
            AMCBankingSetup.Insert(true);
            AMCBankingSetup."AMC Enabled" := true;
            AMCBankingSetup.Modify();
        end;

        // Exercise test
        BasisSetupRunOK := AMCBankAssistedMgt.RunBasisSetupV162(true, true, '', LocalhostURLTxt, '', true, false, '', '',
                                                            true, true, false, true, false, '', '',
                                                            false, false, TempOnlineBankAccLink, false);

        Assert.AreEqual(TRUE, BasisSetupRunOK, '');

        // Verify test
        AMCBankingSetup.Get();
        Assert.AreEqual(AMCBankingSetup."User Name", AMCBankingSetup.GetDemoUserName(), '');
        Assert.AreEqual(AMCBankingSetup."Solution", AMCBankingMgt.GetDemoSolutionCode(), '');
        Assert.AreEqual(AMCBankingSetup."Namespace API Version", AMCBankingMgt.ApiVersion(), '');
        Assert.AreEqual(AMCBankingSetup."Service URL", LocalhostURLTxt, '');
    end;

    [Test]
    procedure AssistedSetupWithLicensedUserNoModule();
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        TempOnlineBankAccLink: Record "Online Bank Acc. Link" temporary;
        AMCBankAssistedMgt: Codeunit "AMC Bank Assisted Mgt.";
        BasisSetupRunOK: Boolean;
    begin
        // [SCENARIO 1] Running assisted setup with real license user in demosolution.
        // [GIVEN] Amcbanking setup with real license credentials, but without any module.
        // [WHEN] Run the Assisted setup wizard.
        // [THEN] Banklistname ist updated.
        // [THEN] Data Exchange is setup.
        // [THEN] Correct URLs are setup.

        // Initialize data for test
        Initialize();
        if (not AMCBankingSetup.Get()) then begin
            AMCBankingSetup.Init();
            AMCBankingSetup.Insert(true);
            AMCBankingSetup."User Name" := AMCBankingMgt.GetLicenseNumber();
            AMCBankingSetup."AMC Enabled" := true;
            AMCBankingSetup.Modify();
        end;

        // Exercise test
        BasisSetupRunOK := AMCBankAssistedMgt.RunBasisSetupV162(true, true, '', LocalhostURLTxt, '', true, false, '', '',
                                                            true, true, false, true, false, '', '',
                                                            false, false, TempOnlineBankAccLink, false);
        Assert.AreEqual(TRUE, BasisSetupRunOK, '');

        // Verify test
        AMCBankingSetup.Get();
        Assert.AreEqual(AMCBankingSetup."User Name", AMCBankingMgt.GetLicenseNumber(), '');
        Assert.AreEqual(AMCBankingSetup.Solution, AMCBankingMgt.GetDemoSolutionCode(), '');
        Assert.AreEqual(AMCBankingSetup."Namespace API Version", AMCBankingMgt.ApiVersion(), '');
        Assert.AreEqual(AMCBankingSetup."Service URL", LocalhostURLTxt, '');
    end;

    [Test]
    procedure AssistedSetupWithLicensedUserWithModule();
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        TempOnlineBankAccLink: Record "Online Bank Acc. Link" temporary;
        AMCBankAssistedMgt: Codeunit "AMC Bank Assisted Mgt.";
        BasisSetupRunOK: Boolean;
    begin
        // [SCENARIO 1] Running assisted setup with real license user with standard solution.
        // [GIVEN] Amcbanking setup with real license credentials, but with standard module.s
        // [WHEN] Run the Assisted setup wizard.
        // [THEN] Banklistname ist updated.
        // [THEN] Data Exchange is setup.
        // [THEN] Correct URLs are setup.

        // Initialize data for test
        Initialize();
        if (not AMCBankingSetup.Get()) then begin
            AMCBankingSetup.Init();
            AMCBankingSetup.Insert(true);
            AMCBankingSetup."User Name" := AMCBankingMgt.GetLicenseNumber();
            AMCBankingSetup.Solution := 'Standard';
            AMCBankingSetup."AMC Enabled" := true;
            AMCBankingSetup.Modify();
        end;

        // Exercise test
        BasisSetupRunOK := AMCBankAssistedMgt.RunBasisSetupV162(true, true, '', LocalhostURLTxt, '', true, false, '', '',
                                                            true, true, false, true, false, '', '',
                                                            false, false, TempOnlineBankAccLink, false);
        Assert.AreEqual(TRUE, BasisSetupRunOK, '');

        // Verify test
        AMCBankingSetup.Get();
        Assert.AreEqual(AMCBankingSetup."User Name", AMCBankingMgt.GetLicenseNumber(), '');
        Assert.AreEqual(AMCBankingSetup.Solution, 'Standard', '');
        Assert.AreEqual(AMCBankingSetup."Namespace API Version", AMCBankingMgt.ApiVersion(), '');
        Assert.AreEqual(AMCBankingSetup."Service URL", LocalhostURLTxt, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DemoUserNamePasswordShouldNotBeSetOnInsertWithFilledUser()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        // [FEATURE] [Password] [Demo Company]
        // [SCENARIO] Setup URLS will always be set to default on insert NO matter what
        // [GIVEN] Company is Demo Company
        Initialize();

        SetDemoCompany(true);
        with AMCBankingSetup do begin
            // [GIVEN] New "AMC Bank Service Setup", where "User Name" is 'X'
            "User Name" := 'X';
            // [GIVEN] The Password and URLs are filled
            SavePassword('P');
            "Sign-up URL" := CopyStr(FieldName("Sign-up URL"), 1, 250);
            "Service URL" := CopyStr(FieldName("Service URL"), 1, 250);
            "Support URL" := CopyStr(FieldName("Support URL"), 1, 250);
            // [WHEN] Insert the record
            Insert(true);
            AMCBankingSetup."AMC Enabled" := true;
            AMCBankingSetup.Modify();

            // [THEN] Setup is not set to default values
            Assert.AreEqual('X', "User Name", FieldCaption("User Name"));
            Assert.AreEqual('P', GetPassword(), FieldCaption("Password Key"));
            Assert.ExpectedMessage(AMCBankingMgt.GetLicenseServerName() + AMCBankingMgt.GetLicenseRegisterTag(), AMCBankingSetup."Sign-up URL");
            Assert.ExpectedMessage('https://amcbanking.com/landing365bc/help/', AMCBankingSetup."Support URL");
            if ((Solution = AMCBankingMgt.GetDemoSolutionCode()) or
                (Solution = '')) then
                Assert.ExpectedMessage(AMCBankingMgt.GetServiceURL('https://demoxtl.amcbanking.com/', AMCBankingMgt.ApiVersion()), AMCBankingSetup."Service URL")
            else
                Assert.ExpectedMessage(AMCBankingMgt.GetServiceURL('https://nav.amcbanking.com/', AMCBankingMgt.ApiVersion()), AMCBankingSetup."Service URL")

        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DemoUserNamePasswordShouldBeSetOnInsertWithEmptyUser()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        AMCBankingSetupPage: TestPage "AMC Banking Setup";
    begin
        // [FEATURE] [Password] [UI]
        // [SCENARIO] Demo user and password should be set on open page if no record exist
        Initialize();

        // [WHEN] Open "AMC Bank Service Setup" page
        AMCBankingSetupPage.OpenEdit();

        // [THEN] "User Name" is 'DemoUser', Password is 'Demo Password'
        AMCBankingSetup.Get();
        Assert.AreEqual(AMCBankingSetup.GetDemoUserName(), AMCBankingSetup."User Name", AMCBankingSetup.FieldCaption("User Name"));
        Assert.AreEqual('Demo Password', AMCBankingSetup.GetPassword(), AMCBankingSetup.FieldCaption("Password Key"));

    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,AMCBankingSetupModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestMissingCredentialsUpdatedPmtExport()
    var
        TempAMCBankingSetup: Record "AMC Banking Setup" temporary;
        TempDataExch: Record "Data Exch." temporary;
    begin
        // [SCENARIO 1] Handle missing username/password in the AMC Bank Service Setup.
        // [GIVEN] Sample data for a sample AMC bank.
        // [GIVEN] AMC test Payment Export Web service URL and incomplete credentials.
        // [WHEN] Run the Web service management functions to handle the request / response.
        // [THEN] Application provides a confirmation message to allow setting the username/password.
        // [THEN] User is able to update the username/password.

        // Setup.
        InitializeDataExchDef(AMCBankingMgt.GetDataExchDef_CT());
        ClearAMCBankingSetup(TempAMCBankingSetup);
        CreateDataExchWithContentCT(TempDataExch, 'CredentialsUpdated');

        // Exercise.
        asserterror CODEUNIT.Run(CODEUNIT::"AMC Bank Exp. CT Hndl", TempDataExch);

        // Verify.
        Assert.ExpectedError(NoConnectionErr);

        // Clean-up
        LibraryPaymentAMC.RestoreServiceSetup(TempAMCBankingSetup, '');
        SetDemoCompany(true);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerFalse')]
    [Scope('OnPrem')]
    procedure TestMissingCredentialsNotUpdatedPmtExport()
    var
        TempAMCBankingSetup: Record "AMC Banking Setup" temporary;
        TempDataExch: Record "Data Exch." temporary;
    begin
        // [SCENARIO 2] Handle missing username/password in the AMC Bank Service Setup.
        // [GIVEN] Sample data for a sample AMC bank.
        // [GIVEN] AMC test Payment Export Web service URL and incomplete credentials.
        // [WHEN] Run the Web service management functions to handle the request / response.
        // [THEN] Application provides a confirmation message to allow setting the username/password.
        // [THEN] User does not update the username/password.
        // [THEN] Process is terminated.
        InitializeDataExchDef(AMCBankingMgt.GetDataExchDef_CT());
        Initialize();

        // Setup.
        ClearAMCBankingSetup(TempAMCBankingSetup);
        CreateDataExchWithContentCT(TempDataExch, 'InvalidCredentials');

        // Exercise.
        asserterror CODEUNIT.Run(CODEUNIT::"AMC Bank Exp. CT Hndl", TempDataExch);

        // Verify.
        Assert.ExpectedError(StrSubstNo(MissingCredentialsErr, TempAMCBankingSetup.TableCaption()));

        // Clean-up
        LibraryPaymentAMC.RestoreServiceSetup(TempAMCBankingSetup, '');
        SetDemoCompany(true);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,AMCBankingSetupModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestMissingCredentialsUpdatedBankStmt()
    var
        TempAMCBankingSetup: Record "AMC Banking Setup" temporary;
        TempDataExch: Record "Data Exch." temporary;
        TempBlob: Codeunit "Temp Blob";
        ResponseBodyTempBlob: Codeunit "Temp Blob";
        AMCBankImpSTMTHndl: Codeunit "AMC Bank Imp.STMT. Hndl";
    begin
        // [SCENARIO 3] Handle missing username/password in the AMC Bank Service Setup.
        // [GIVEN] Sample data for a sample AMC bank.
        // [GIVEN] AMC test Bank Statement Web service URL and incomplete credentials.
        // [WHEN] Run the Web service management functions to handle the request / response.
        // [THEN] Application provides a confirmation message to allow setting the username/password.
        // [THEN] User is able to update the username/password.
        InitializeDataExchDef(AMCBankingMgt.GetDataExchDef_STMT());
        Initialize();

        // Setup.
        ClearAMCBankingSetup(TempAMCBankingSetup);
        CreateDataExchWithContentSTMT(TempDataExch, 'CredentialsUpdated');

        // Exercise.
        TempBlob.FromRecord(TempDataExch, TempDataExch.FieldNo("File Content"));
        AMCBankImpSTMTHndl.ConvertBankStatementToFormat(TempBlob, TempDataExch);

        // Pre-Verify
        ResponseBodyTempBlob.FromRecord(TempDataExch, TempDataExch.FieldNo("File Content"));
        LibraryXPathXMLReader.InitializeWithBlob(ResponseBodyTempBlob, AMCBankingMgt.GetNamespace());
        LibraryXPathXMLReader.SetDefaultNamespaceUsage(false);

        // Verify
        LibraryXPathXMLReader.VerifyNodeValueByXPath(EndBalanceNodePathTxt + '/balanceend', '266787.1200');
        LibraryXPathXMLReader.VerifyNodeAbsence(CremulPathTxt);


        // Clean-up
        LibraryPaymentAMC.RestoreServiceSetup(TempAMCBankingSetup, '');
        SetDemoCompany(true);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerFalse')]
    [Scope('OnPrem')]
    procedure TestMissingCredentialsNotUpdatedBankStmt()
    var
        TempAMCBankingSetup: Record "AMC Banking Setup" temporary;
        TempDataExch: Record "Data Exch." temporary;
        TempBlob: Codeunit "Temp Blob";
        AMCBankImpSTMTHndl: Codeunit "AMC Bank Imp.STMT. Hndl";
    begin
        // [SCENARIO 4] Handle missing username/password in the AMC Bank Service Setup.
        // [GIVEN] Sample data for a sample AMC bank.
        // [GIVEN] AMC test Bank Statement Web service URL and incomplete credentials.
        // [WHEN] Run the Web service management functions to handle the request / response.
        // [THEN] Application provides a confirmation message to allow setting the username/password.
        // [THEN] User does not update the username/password.
        // [THEN] Process is terminated.
        InitializeDataExchDef(AMCBankingMgt.GetDataExchDef_STMT());
        Initialize();

        // Setup.
        ClearAMCBankingSetup(TempAMCBankingSetup);
        CreateDataExchWithContentSTMT(TempDataExch, 'InvalidCredentials');

        // Exercise.
        TempBlob.FromRecord(TempDataExch, TempDataExch.FieldNo("File Content"));
        asserterror AMCBankImpSTMTHndl.ConvertBankStatementToFormat(TempBlob, TempDataExch);

        // Verify.
        Assert.ExpectedError(StrSubstNo(MissingCredentialsErr, TempAMCBankingSetup.TableCaption()));

        // Clean-up
        LibraryPaymentAMC.RestoreServiceSetup(TempAMCBankingSetup, '');
        SetDemoCompany(true);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,AMCBankingSetupNoUserModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestMissingCredentialsUpdatedBankList()
    var
        TempAMCBankingSetup: Record "AMC Banking Setup" temporary;

    begin
        // [SCENARIO 5] Handle missing username/password in the AMC Bank Service Setup.
        // [GIVEN] Sample data for a sample AMC bank.
        // [GIVEN] AMC test Bank List Web service URL and incomplete credentials.
        // [WHEN] Run the Web service management functions to handle the request / response.
        // [THEN] Application provides a confirmation message to allow setting the username/password.
        // [THEN] User is able to update the username/password.
        Initialize();

        // Setup.
        ClearAMCBankingSetup(TempAMCBankingSetup);

        // Exercise.
        asserterror CODEUNIT.Run(CODEUNIT::"AMC Bank Imp.BankList Hndl");

        // Verify.
        Assert.ExpectedError(StrSubstNo(MissingCredentialsErr, TempAMCBankingSetup.TableCaption()));

        // Clean-up
        LibraryPaymentAMC.RestoreServiceSetup(TempAMCBankingSetup, '');
        SetDemoCompany(true);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerFalse')]
    [Scope('OnPrem')]
    procedure TestMissingCredentialsNotUpdatedBankList()
    var
        TempAMCBankingSetup: Record "AMC Banking Setup" temporary;
    begin
        // [SCENARIO 6] Handle missing username/password in the AMC Bank Service Setup.
        // [GIVEN] Sample data for a sample AMC bank.
        // [GIVEN] AMC test Bank List Web service URL and incomplete credentials.
        // [WHEN] Run the Web service management functions to handle the request / response.
        // [THEN] Application provides a confirmation message to allow setting the username/password.
        // [THEN] User does not update the username/password.
        // [THEN] Process is terminated.
        Initialize();

        // Setup.
        ClearAMCBankingSetup(TempAMCBankingSetup);

        // Exercise.
        asserterror CODEUNIT.Run(CODEUNIT::"AMC Bank Imp.BankList Hndl");

        // Verify.
        Assert.ExpectedError(StrSubstNo(MissingCredentialsErr, TempAMCBankingSetup.TableCaption()));

        // Clean-up
        LibraryPaymentAMC.RestoreServiceSetup(TempAMCBankingSetup, '');
        SetDemoCompany(true);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,AMCBankingSetupModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestMissingSetupUpdatedPmtExport()
    var
        TempAMCBankingSetup: Record "AMC Banking Setup" temporary;
        TempDataExch: Record "Data Exch." temporary;
    begin
        // [SCENARIO 7] Handle missing AMC Bank Service Setup record (after upgrade).
        // [GIVEN] Sample data for a sample AMC bank.
        // [GIVEN] AMC test Payment Export Web service URL and no record in TAB1260.
        // [WHEN] Run the Web service management functions to handle the request / response.
        // [THEN] Application provides a confirmation message to allow setting the username/password.
        // [THEN] A record in TAB1260 is created.
        // [THEN] User is able to update the username/password.
        InitializeDataExchDef(AMCBankingMgt.GetDataExchDef_CT());
        Initialize();


        // Setup.
        ClearAMCBankingSetup(TempAMCBankingSetup);
        CreateDataExchWithContentCT(TempDataExch, 'CredentialsUpdated');

        // Exercise.
        asserterror CODEUNIT.Run(CODEUNIT::"AMC Bank Exp. CT Hndl", TempDataExch);

        // Verify.
        Assert.ExpectedError(NoConnectionErr);

        //Cleanup
        LibraryPaymentAMC.RestoreServiceSetup(TempAMCBankingSetup, '');
        SetDemoCompany(true);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerFalse')]
    [Scope('OnPrem')]
    procedure TestMissingSetupNotUpdatedPmtExport()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        TempDataExch: Record "Data Exch." temporary;
    begin
        // [SCENARIO 8] Handle missing AMC Bank Service Setup record (after upgrade).
        // [GIVEN] Sample data for a sample AMC bank.
        // [GIVEN] AMC test Payment Export Web service URL and no record in TAB1260.
        // [WHEN] Run the Web service management functions to handle the request / response.
        // [WHEN] Application provides a confirmation message to allow setting the username/password.
        // [WHEN] User refuses.
        // [THEN] An error is issued.
        // [THEN] TAB1260 stays empty.
        InitializeDataExchDef(AMCBankingMgt.GetDataExchDef_CT());
        Initialize();

        // Setup.
        SetDemoCompany(false);
        CreateDataExchWithContentCT(TempDataExch, 'MissingSetup');

        // Exercise.
        Commit();
        asserterror CODEUNIT.Run(CODEUNIT::"AMC Bank Exp. CT Hndl", TempDataExch);

        // Verify.
        Assert.ExpectedError(StrSubstNo(MissingCredentialsErr, AMCBankingSetup.TableCaption()));
        asserterror AMCBankingSetup.Get();

        // Cleanup.
        SetDemoCompany(true);
    end;

    local procedure Initialize()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        AMCBankingSetup.DeleteAll();
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    local procedure InitializeDataExchDef(DataExchDef: Code[20])
    var
        AMCBankingSetup: Record "AMC Banking Setup";

        WasNotPresent: Boolean;
    begin
        if (NOT AMCBankingSetup.Get()) then begin
            WasNotPresent := true;
            AMCBankingSetup.Init();
            AMCBankingSetup.Insert(true);
            AMCBankingSetup."AMC Enabled" := true;
            AMCBankingSetup.Modify();
        end;
        LibraryAmcWebService.SetupAMCBankingDataExch(DataExchDef);

        if (WasNotPresent) then
            AMCBankingSetup.DeleteAll();
    end;

    local procedure CreateDataExchWithContentCT(var TempDataExch: Record "Data Exch." temporary; testword: text)
    var
        DataExchMapping: Record "Data Exch. Mapping";
        BodyTempBlob: Codeunit "Temp Blob";

        RecordRef: RecordRef;
        BodyOutStream: OutStream;
    begin
        BodyTempBlob.CreateOutStream(BodyOutStream, TEXTENCODING::UTF8);
        BodyOutStream.WriteText(StrSubstNo(SamplePmtXmlFile_EncodUTF8Txt, testword));

        DataExchMapping.SetRange("Mapping Codeunit", CODEUNIT::"AMC Bank Exp. CT Pre-Map");
        DataExchMapping.FindFirst();

        TempDataExch.Init();
        RecordRef.GetTable(TempDataExch);
        BodyTempBlob.ToRecordRef(RecordRef, TempDataExch.FieldNo("File Content"));
        RecordRef.SetTable(TempDataExch);
        TempDataExch."Data Exch. Def Code" := DataExchMapping."Data Exch. Def Code";
        TempDataExch.Insert();
    end;

    local procedure CreateDataExchWithContentSTMT(var TempDataExch: Record "Data Exch." temporary; testword: text)
    var
        DataExchMapping: Record "Data Exch. Mapping";
        BodyTempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        BodyOutStream: OutStream;
    begin
        BodyTempBlob.CreateOutStream(BodyOutStream, TEXTENCODING::Windows);
        BodyOutStream.WriteText(testword);
        DataExchMapping.SetRange("Pre-Mapping Codeunit", CODEUNIT::"AMC Bank Imp.-Pre-Process");
        DataExchMapping.FindFirst();
        TempDataExch.Init();
        RecordRef.GetTable(TempDataExch);
        BodyTempBlob.ToRecordRef(RecordRef, TempDataExch.FieldNo("File Content"));
        RecordRef.SetTable(TempDataExch);
        TempDataExch."Data Exch. Def Code" := DataExchMapping."Data Exch. Def Code";
        TempDataExch.Insert();
    end;

    local procedure ClearAMCBankingSetup(var TempAMCBankingSetup: Record "AMC Banking Setup" temporary)
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        SetDemoCompany(false);
        LibraryAmcWebService.SetupDefaultService();
        AMCBankingSetup.Get();
        TempAMCBankingSetup := AMCBankingSetup;
        AMCBankingSetup."User Name" := '';
        if IsolatedStorage.Contains(AMCBankingSetup."Password Key", DATASCOPE::Company) then
            IsolatedStorage.Delete(AMCBankingSetup."Password Key", DATASCOPE::Company);
        clear(AMCBankingSetup."Password Key");
        AMCBankingSetup."Service URL" := LocalhostURLTxt;
        AMCBankingSetup."AMC Enabled" := true;
        AMCBankingSetup.Modify();
        Commit();
    end;

    local procedure SetDemoCompany(DemoCompany: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Demo Company" := DemoCompany;
        CompanyInformation.Modify();
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandlerTrue(Question: Text[1024]; var Reply: Boolean)
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        if StrPos(StrSubstNo(MissingCredentialsQst, AMCBankingSetup.TableCaption()), Question) > 0 then
            Reply := true
        else
            Reply := false;
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandlerFalse(Question: Text[1024]; var Reply: Boolean)
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        Assert.ExpectedMessage(StrSubstNo(MissingCredentialsQst, AMCBankingSetup.TableCaption()), Question);
        Reply := false;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure AMCBankingSetupModalPageHandler(var AMCBankingSetupPage: TestPage "AMC Banking Setup")
    var
    begin
        AMCBankingSetupPage."User Name".SetValue('demouser');
        AMCBankingSetupPage.Password.SetValue('Demo Password');
        AMCBankingSetupPage."Service URL".SetValue(LocalhostURLTxt);
        AMCBankingSetupPage.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure AMCBankingSetupNoUserModalPageHandler(var AMCBankingSetupPage: TestPage "AMC Banking Setup")
    begin
        AMCBankingSetupPage."Service URL".SetValue(LocalhostURLTxt);
        AMCBankingSetupPage.OK().Invoke();
    end;
}
