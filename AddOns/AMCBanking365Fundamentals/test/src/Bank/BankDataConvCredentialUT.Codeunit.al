codeunit 132558 "Bank Data Conv. Credential UT"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Bank Data Conversion]
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        LibraryPaymentAMC: Codeunit "Library - Payment AMC";
        LibraryWebService: Codeunit "Library - Amc Web Service";
        EnvironmentInfo: Codeunit "Environment Information";
        LocalhostURLTxt: Label 'https://localhost:8080', Locked = true;
        MissingCredentialsQst: Label 'The %1 is missing the user name or password. Do you want to open the %1 page?';
        MissingCredentialsErr: Label 'The user name and password must be filled in %1 page.';
        NoConnectionErr: Label 'No connection could be made because the target machine actively refused it 127.0.0.1:8080';
        SamplePmtXmlFileTxt: Label '<paymentExportBank xmlns="http://nav02.soap.xml.link.amc.dk/"><amcpaymentreq xmlns=''''><banktransjournal></banktransjournal></amcpaymentreq><bank>Danske DK</bank><language>ENU</language></paymentExportBank>', Locked = true;

    [Test]
    [Scope('OnPrem')]
    procedure DemoUserNamePasswordShouldNotBeSetOnInsertWithFilledUser()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        // [FEATURE] [Password] [Demo Company]
        // [SCENARIO] Setup should not be set to default on insert if "User Name" is not blank
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

            // [THEN] Setup is not set to default values
            Assert.AreEqual('X', "User Name", FieldCaption("User Name"));
            Assert.AreEqual('P', GetPassword(), FieldCaption("Password Key"));
            Assert.ExpectedMessage(FieldName("Sign-up URL"), "Sign-up URL");
            Assert.ExpectedMessage(FieldName("Service URL"), "Service URL");
            Assert.ExpectedMessage(FieldName("Support URL"), "Support URL");
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DemoUserNamePasswordShouldNotBeSetInNormalCompany()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        AMCBankingSetupPage: TestPage "AMC Banking Setup";
    begin
        // [FEATURE] [Password] [UI]
        // [SCENARIO] Demo user and password should NOT be set on open page if Company is not Demo Company
        Initialize();

        // [GIVEN] Company is not Demo Company
        SetDemoCompany(false);

        // [WHEN] Open "AMC Bank Service Setup" page
        AMCBankingSetupPage.OpenEdit();

        // [THEN] "User Name" is '', Password is ''
        AMCBankingSetup.Get();
        Assert.AreEqual('', AMCBankingSetup.GetUserName(), AMCBankingSetup.FieldCaption("User Name"));
        Assert.IsFalse(AMCBankingSetup.HasPassword(), AMCBankingSetup.FieldCaption("Password Key"));
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
        ClearAMCBankingSetup(TempAMCBankingSetup);
        CreateDataExchWithContent(TempDataExch);

        // Exercise.
        asserterror CODEUNIT.Run(CODEUNIT::"AMC Bank Exp. CT Hndl", TempDataExch);

        // Verify.
        Assert.ExpectedError(NoConnectionErr);

        // Clean-up
        LibraryPaymentAMC.RestoreServiceSetup(TempAMCBankingSetup, '');
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
        Initialize();

        // Setup.
        ClearAMCBankingSetup(TempAMCBankingSetup);
        CreateDataExchWithContent(TempDataExch);

        // Exercise.
        asserterror CODEUNIT.Run(CODEUNIT::"AMC Bank Exp. CT Hndl", TempDataExch);

        // Verify.
        Assert.ExpectedError(StrSubstNo(MissingCredentialsErr, TempAMCBankingSetup.TableCaption()));

        // Clean-up
        LibraryPaymentAMC.RestoreServiceSetup(TempAMCBankingSetup, '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,AMCBankingSetupModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestMissingCredentialsUpdatedBankStmt()
    var
        TempAMCBankingSetup: Record "AMC Banking Setup" temporary;
        TempDataExch: Record "Data Exch." temporary;
        TempBlob: Codeunit "Temp Blob";
        ImpBankConvExtDataHndl: Codeunit "AMC Bank Imp.STMT. Hndl";
    begin
        // [SCENARIO 3] Handle missing username/password in the AMC Bank Service Setup.
        // [GIVEN] Sample data for a sample AMC bank.
        // [GIVEN] AMC test Bank Statement Web service URL and incomplete credentials.
        // [WHEN] Run the Web service management functions to handle the request / response.
        // [THEN] Application provides a confirmation message to allow setting the username/password.
        // [THEN] User is able to update the username/password.
        Initialize();

        // Setup.
        ClearAMCBankingSetup(TempAMCBankingSetup);
        CreateDataExchWithContent(TempDataExch);

        // Exercise.
        TempBlob.FromRecord(TempDataExch, TempDataExch.FieldNo("File Content"));
        asserterror ImpBankConvExtDataHndl.ConvertBankStatementToFormat(TempBlob, TempDataExch);

        // Verify.
        Assert.ExpectedError(NoConnectionErr);

        // Clean-up
        LibraryPaymentAMC.RestoreServiceSetup(TempAMCBankingSetup, '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerFalse')]
    [Scope('OnPrem')]
    procedure TestMissingCredentialsNotUpdatedBankStmt()
    var
        TempAMCBankingSetup: Record "AMC Banking Setup" temporary;
        TempDataExch: Record "Data Exch." temporary;
        TempBlob: Codeunit "Temp Blob";
        ImpBankConvExtDataHndl: Codeunit "AMC Bank Imp.STMT. Hndl";
    begin
        // [SCENARIO 4] Handle missing username/password in the AMC Bank Service Setup.
        // [GIVEN] Sample data for a sample AMC bank.
        // [GIVEN] AMC test Bank Statement Web service URL and incomplete credentials.
        // [WHEN] Run the Web service management functions to handle the request / response.
        // [THEN] Application provides a confirmation message to allow setting the username/password.
        // [THEN] User does not update the username/password.
        // [THEN] Process is terminated.
        Initialize();

        // Setup.
        ClearAMCBankingSetup(TempAMCBankingSetup);
        CreateDataExchWithContent(TempDataExch);

        // Exercise.
        TempBlob.FromRecord(TempDataExch, TempDataExch.FieldNo("File Content"));
        asserterror ImpBankConvExtDataHndl.ConvertBankStatementToFormat(TempBlob, TempDataExch);

        // Verify.
        Assert.ExpectedError(StrSubstNo(MissingCredentialsErr, TempAMCBankingSetup.TableCaption()));

        // Clean-up
        LibraryPaymentAMC.RestoreServiceSetup(TempAMCBankingSetup, '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,AMCBankingSetupModalPageHandler')]
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
        Assert.ExpectedError(NoConnectionErr);

        // Clean-up
        LibraryPaymentAMC.RestoreServiceSetup(TempAMCBankingSetup, '');
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
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,AMCBankingSetupModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestMissingSetupUpdatedPmtExport()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        TempDataExch: Record "Data Exch." temporary;
    begin
        // [SCENARIO 7] Handle missing AMC Bank Service Setup record (after upgrade).
        // [GIVEN] Sample data for a sample AMC bank.
        // [GIVEN] AMC test Payment Export Web service URL and no record in TAB1260.
        // [WHEN] Run the Web service management functions to handle the request / response.
        // [THEN] Application provides a confirmation message to allow setting the username/password.
        // [THEN] A record in TAB1260 is created.
        // [THEN] User is able to update the username/password.
        Initialize();

        SetDemoCompany(false);
        // Setup.
        AMCBankingSetup.DeleteAll(true);
        CreateDataExchWithContent(TempDataExch);

        // Exercise.
        asserterror CODEUNIT.Run(CODEUNIT::"AMC Bank Exp. CT Hndl", TempDataExch);

        // Verify.
        Assert.ExpectedError(NoConnectionErr);
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
        Initialize();

        // Setup.
        CreateDataExchWithContent(TempDataExch);

        // Exercise.
        Commit();
        asserterror CODEUNIT.Run(CODEUNIT::"AMC Bank Exp. CT Hndl", TempDataExch);

        // Verify.
        Assert.ExpectedError(StrSubstNo(MissingCredentialsErr, AMCBankingSetup.TableCaption()));
        asserterror AMCBankingSetup.Get();
    end;

    local procedure Initialize()
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        AMCBankingSetup.DeleteAll();
        EnvironmentInfo.SetTestabilitySoftwareAsAService(false);
    end;

    local procedure CreateDataExchWithContent(var TempDataExch: Record "Data Exch." temporary)
    var
        DataExchMapping: Record "Data Exch. Mapping";
        BodyTempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        BodyOutputStream: OutStream;
    begin
        BodyTempBlob.CreateOutStream(BodyOutputStream, TEXTENCODING::UTF8);
        BodyOutputStream.WriteText(SamplePmtXmlFileTxt);

        DataExchMapping.SetRange("Pre-Mapping Codeunit", CODEUNIT::"AMC Bank Exp. CT Pre-Map");
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
        LibraryWebService.SetupDefaultService();
        AMCBankingSetup.Get();
        TempAMCBankingSetup := AMCBankingSetup;
        AMCBankingSetup."User Name" := '';
        if IsolatedStorage.Contains(AMCBankingSetup."Password Key", DATASCOPE::Company) then
            IsolatedStorage.Delete(AMCBankingSetup."Password Key", DATASCOPE::Company);
        AMCBankingSetup."Service URL" := LocalhostURLTxt;
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
    begin
        AMCBankingSetupPage."User Name".SetValue(LibraryUtility.GenerateGUID());
        AMCBankingSetupPage.Password.SetValue(LibraryUtility.GenerateGUID());
        AMCBankingSetupPage."Service URL".SetValue(LocalhostURLTxt);
        AMCBankingSetupPage.OK().Invoke();
    end;
}
