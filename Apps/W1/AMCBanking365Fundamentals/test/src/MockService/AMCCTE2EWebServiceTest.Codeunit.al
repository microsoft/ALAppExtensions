codeunit 135087 "AMC CT E2E Web Service Test"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [AMC Banking Fundamentals] [Web Service]
    end;

    var
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        Assert: Codeunit Assert;
        LibraryAMCWebService: Codeunit "Library - Amc Web Service";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        IsInitialized: Boolean;
        ErrorsNotFoundErr: Label 'Errors should have been inserted.';
        HasErrorsErr: Label 'The AMC Banking has found one or more errors.';
        SyslogErrorsErr: Label 'The AMC Banking has returned the following error message:';
        StmtNotRecognized1Err: Label 'File not recognized as valid bankfile';
        StmtNotRecognized2Err: Label 'Check your importfile';
        UnexpectedValueErr: Label 'Unexpected value was found. Expected value was: %1.', Comment = '%1 = Test error value';

    [Test]
    [Scope('OnPrem')]
    procedure TestSaveFileConvResponseErrors()
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 1] Create a payment file and handle the line level response errors.
        // [GIVEN] Sample data for a sample AMC bank.
        // [GIVEN] AMC test Web service URL and access credentials.
        // [WHEN] Run the Web service management functions to handle the request / response.
        // [THEN] Line level errors in the response are saved as payment file errors attached to a gen jnl. line.

        Initialize();
        LibraryAMCWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        SetupPaymentDataForExport(GenJournalLine, 'Danske DK', 'WRONGBANKACCNO', Today() + 366);

        // Exercise.
        GenJournalLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account" then
            GenJournalLine."Bank Payment Type" := GenJournalLine."Bank Payment Type"::"Electronic Payment";
        if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account" then
            GenJournalLine."Bank Payment Type" := GenJournalLine."Bank Payment Type"::"Electronic Payment";
        GenJournalLine.Modify();
        asserterror GenJournalLine.ExportPaymentFile();

        // Verify.
        Assert.ExpectedError(HasErrorsErr);

        if not GenJournalLine.HasPaymentFileErrors() then
            Error(ErrorsNotFoundErr);

        VerifyGenJnlLineError(GenJournalLine, 'The payment date is more than 365 days in the future',
                                              'Please adjust the date to less than 365 days from today');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure MyTestSaveFileConvResponseErrors()
    var
        GenJournalLine: Record "Gen. Journal Line";
        CreditTransferRegister: Record "Credit Transfer Register";
    begin
        // [SCENARIO 2] While exporting payments, copy of file is added to Credit Transfer Registers
        // [GIVEN] Sample data for a sample AMC bank.
        // [GIVEN] AMC test Web service URL and access credentials.
        // [WHEN] Run the Web service management functions to handle the request / response.
        // [THEN] Verify that file is created.

        Initialize();
        LibraryAMCWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        SetupPaymentDataForExport(GenJournalLine, 'Demo Bank GB', 'CORRECTFILEEXPORT', Today());

        // Exercise.
        GenJournalLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account" then
            GenJournalLine."Bank Payment Type" := GenJournalLine."Bank Payment Type"::"Electronic Payment";
        if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account" then
            GenJournalLine."Bank Payment Type" := GenJournalLine."Bank Payment Type"::"Electronic Payment";
        GenJournalLine.Modify();
        GenJournalLine.ExportPaymentFile();

        // Verify.
        CreditTransferRegister.FindLast();
        Assert.IsTrue(CreditTransferRegister."Exported File".HasValue(), 'File field is empty.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSyslogResponseErrors()
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 3] Create a payment file and handle the system level response errors.
        // [GIVEN] Sample data for a sample AMC bank.
        // [GIVEN] AMC test Web service URL and access credentials.
        // [WHEN] Run the Export payments to file.
        // [WHEN] The service responds with system errors (i.e. "syslog").
        // [THEN] System level errors in the response are presented in an error  message.
        // [THEN] The error message will note that the errors are provided by AMC.
        // [THEN] The error message will contain the error text, hint text and support URL for the syslog errors.

        Initialize();
        LibraryAMCWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup
        SetupPaymentDataForExport(GenJournalLine, 'WRONGBANKNAME', LibraryUtility.GenerateGUID(), Today());

        // Exercise.
        GenJournalLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account" then
            GenJournalLine."Bank Payment Type" := GenJournalLine."Bank Payment Type"::"Electronic Payment";
        if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account" then
            GenJournalLine."Bank Payment Type" := GenJournalLine."Bank Payment Type"::"Electronic Payment";
        GenJournalLine.Modify();
        asserterror GenJournalLine.ExportPaymentFile();

        // Verify.
        Assert.ExpectedError('Please verify the spelling of this bank. You can see all supported banks at http://amcbanking.com/support/');
        Assert.ExpectedError('Please verify the spelling of this bank.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPaymentRequestWithEncoding()
    var
        TempDataExch: Record "Data Exch." temporary;
    begin
        // [SCENARIO 1] Handle response encoding.
        // [GIVEN] Sample data for a sample AMC bank.
        // [GIVEN] AMC test Web service URL and access credentials.
        // [WHEN] Run the AMC CT external data handling codeunit to handle the request / response.
        // [WHEN] The encoding element is present in the response.
        // [THEN] The encoding element is handled correctly.

        Initialize();
        LibraryAMCWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup
        CreateDataExchWithContent(TempDataExch, 'CORRECTENCODING');

        // Exercise
        CODEUNIT.Run(CODEUNIT::"Generate Payment Data Sample", TempDataExch);

        // Verify
        CheckUniqueTextNotExisting(TempDataExch, 'CORRECTENCODING');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPaymentRequestWithMissingEncoding()
    var
        TempDataExch: Record "Data Exch." temporary;
    begin
        // [SCENARIO 2] Handle response encoding when the encoding element is missing.
        // [GIVEN] Sample data for a sample AMC bank.
        // [GIVEN] AMC test Web service URL and access credentials.
        // [WHEN] Run the AMC CT external data handling codeunit to handle the request / response.
        // [WHEN] The encoding element is not present in the response.
        // [THEN] The encoding element is handled correctly.

        Initialize();
        LibraryAMCWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup
        CreateDataExchWithContent(TempDataExch, 'MISSINGENCODING');

        // Exercise
        CODEUNIT.Run(CODEUNIT::"Generate Payment Data Sample", TempDataExch);

        // Verify
        CheckUniqueTextNotExisting(TempDataExch, 'MISSINGENCODING');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPaymentRequestWithBlankEncoding()
    var
        TempDataExch: Record "Data Exch." temporary;
    begin
        // [SCENARIO 3] Handle response encoding when the encoding name is blank.
        // [GIVEN] Sample data for a sample AMC bank.
        // [GIVEN] AMC test Web service URL and access credentials.
        // [WHEN] Run the AMC CT external data handling codeunit to handle the request / response.
        // [WHEN] The encoding element is blank in the response.
        // [THEN] The encoding element is handled correctly.

        Initialize();
        LibraryAMCWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup
        CreateDataExchWithContent(TempDataExch, 'BLANKENCODING');

        // Exercise
        CODEUNIT.Run(CODEUNIT::"Generate Payment Data Sample", TempDataExch);

        // Verify
        CheckUniqueTextNotExisting(TempDataExch, 'BLANKENCODING');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ReExportExisting()
    var
        CreditTransferRegister: Record "Credit Transfer Register";
    begin
        Initialize();

        // create CrTransf with file in blob
        CreateDummyCreditTransferRegister(CreditTransferRegister, true);

        // re-export
        CreditTransferRegister.Reexport();

        // AC:
        // 1.New line with information when and who exported payments to file is added to history.
        CheckCrTransfRegHist(CreditTransferRegister."No.", 1);
        // 2.Status for the batch in the field Status changes to "File Re-exported".
        CheckCrTransfReg(CreditTransferRegister."No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ReExportLinesMoreThanOneTime()
    var
        CreditTransferRegister: Record "Credit Transfer Register";
    begin
        Initialize();

        // create CrTransf with file in blob
        CreateDummyCreditTransferRegister(CreditTransferRegister, true);

        // re-export
        CreditTransferRegister.Reexport();

        // re-export
        CreditTransferRegister.Reexport();

        // AC:
        // New line with information when and who exported payments to file is added to history.
        CheckCrTransfRegHist(CreditTransferRegister."No.", 2);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SendMissingFinstaBankStmtToWebService()
    var
        DataExch: Record "Data Exch.";
        BankStmtTempBlob: Codeunit "Temp Blob";
        AMCBankImpSTMTHndl: Codeunit "AMC Bank Imp.STMT. Hndl";
        OutputStream: OutStream;
    begin
        // [SCENARIO 3] Import a bank statement file to Bank Account Reconciliation.
        // [GIVEN] Bank statement file.
        // [WHEN] Click the Import Bank Statement action on the Bank Acc. Reconciliation card.
        // [THEN] The received web response does not contain a finsta element.

        // Setup
        Initialize();
        BankStmtTempBlob.CreateOutStream(OutputStream, TEXTENCODING::UTF8);
        OutputStream.WriteText('StmtMissingFinsta');

        // Exercise
        asserterror AMCBankImpSTMTHndl.ConvertBankStatementToFormat(BankStmtTempBlob, DataExch);

        // Verify
        Assert.ExpectedError(SyslogErrorsErr);
        Assert.ExpectedError(StmtNotRecognized1Err);
        Assert.ExpectedError(StmtNotRecognized2Err);
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        LibraryAMCWebService.SetupDefaultService();
        LibraryAMCWebService.SetServiceUrlToTest();
        LibraryAMCWebService.SetServiceCredentialsToTest();

        IsInitialized := true;
    end;

    [Normal]
    local procedure SetupPaymentDataForExport(var GenJournalLine: Record "Gen. Journal Line"; BankName: Text[50]; BankAccNo: Text[30]; PostingDate: Date)
    var
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        BankAccount: Record "Bank Account";
        GenJournalBatch: Record "Gen. Journal Batch";
        PaymentMethod: Record "Payment Method";
    begin
        CreateVendor(Vendor);
        CreateVendorBankAccount(VendorBankAccount, Vendor."No.");
        CreateBankAccountForExport(BankAccount, BankName, BankAccNo);
        CreatePaymentMethod(PaymentMethod, BankAccount);
        CreateGenJournalBatch(GenJournalBatch, CreateGenJournalTemplate(), BankAccount."No.");
        CreateGenJournalLine(GenJournalLine, GenJournalBatch, Vendor."No.",
          BankAccount."No.", PaymentMethod.Code, VendorBankAccount.Code, PostingDate);
    end;

    local procedure CreateBankAccountForExport(var BankAccount: Record "Bank Account"; BankName: Text[50]; BankAccNo: Text[30])
    begin
        BankAccount.Init();
        BankAccount.Validate("No.", CopyStr(CreateGuid(), 1, MaxStrLen(BankAccount."No.")));
        BankAccount.Validate(Name, BankAccount."No.");
        BankAccount."Bank Branch No." := 'WRONGBRANCHNO';
        BankAccount.Insert();

        BankAccount.Validate("Credit Transfer Msg. Nos.", PrepareNoSeriesForFixedLineID());
        BankAccount.Validate("Payment Export Format", SelectAMCCreditTransferFormat());
        BankAccount.Validate("AMC Bank Name", BankName);
        BankAccount."Bank Account No." := BankAccNo;
        BankAccount.Modify(true);
    end;

    local procedure CreatePaymentMethod(var PaymentMethod: Record "Payment Method"; BankAccount: Record "Bank Account")
    var
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchDef: Record "Data Exch. Def";
        BankExportImportSetup: Record "Bank Export/Import Setup";
        AMCBankPmtType: Record "AMC Bank Pmt. Type";
    begin
        BankAccount.GetBankExportImportSetup(BankExportImportSetup);
        DataExchDef.Get(BankExportImportSetup."Data Exch. Def. Code");
        DataExchLineDef.SetRange("Data Exch. Def Code", DataExchDef.Code);
        DataExchLineDef.FindFirst();

        AMCBankPmtType.FindFirst();

        PaymentMethod.Init();
        PaymentMethod.Validate(Code, CopyStr(CreateGuid(), 1, MaxStrLen(PaymentMethod.Code)));
        PaymentMethod.Insert();

        PaymentMethod.Validate("Pmt. Export Line Definition", DataExchLineDef.Code);
        PaymentMethod.Validate("AMC Bank Pmt. Type", AMCBankPmtType.Code);
        PaymentMethod.Modify(true);
    end;

    local procedure CreateGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch"; JournalTemplateName: Code[10]; BankAccountNo: Code[20])
    begin
        GenJournalBatch.Init();
        GenJournalBatch.Validate("Journal Template Name", JournalTemplateName);
        GenJournalBatch.Validate(Name, CopyStr(CreateGuid(), 1, MaxStrLen(GenJournalBatch.Name)));
        GenJournalBatch.Validate(Description, GenJournalBatch.Name);
        GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"Bank Account");
        GenJournalBatch.Validate("Bal. Account No.", BankAccountNo);
        GenJournalBatch.Validate("Allow Payment Export", true);
        GenJournalBatch.Insert();
    end;

    [Normal]
    local procedure CreateGenJournalTemplate(): Code[10]
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.Init();
        GenJournalTemplate.Validate(Name, CopyStr(CreateGuid(), 1, MaxStrLen(GenJournalTemplate.Name)));
        GenJournalTemplate.Validate(Recurring, false);
        GenJournalTemplate.Insert();

        exit(GenJournalTemplate.Name);
    end;

    local procedure CreateGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch"; VendorNo: Code[20]; BankAccountNo: Code[20]; PaymentMethodCode: Code[10]; VendorBankAccountCode: Code[20]; PostingDate: Date)
    begin
        GenJournalLine.Init();
        GenJournalLine.Validate("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.Validate("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.Validate("Line No.", 10000);
        GenJournalLine.Insert();

        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Payment);
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Vendor);
        GenJournalLine."Account No." := VendorNo;
        GenJournalLine.Validate(Amount, LibraryRandom.RandDec(1000, 2));
        GenJournalLine.Validate("Document No.", CopyStr(CreateGuid(), 1, MaxStrLen(GenJournalLine."Document No.")));
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
        GenJournalLine.Validate("Bal. Account No.", BankAccountNo);
        GenJournalLine.Validate("Payment Method Code", PaymentMethodCode);
        GenJournalLine.Validate("Recipient Bank Account", VendorBankAccountCode);

        GenJournalLine.Modify();
    end;

    local procedure CreateVendor(var Vendor: Record Vendor)
    begin
        Vendor.Init();
        Vendor.Insert(true);
        Vendor.Validate(Name, Vendor."No.");
        Vendor.Modify(true);
    end;

    local procedure CreateVendorBankAccount(var VendorBankAccount: Record "Vendor Bank Account"; VendorNo: Code[20])
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        VendorBankAccount.Init();
        VendorBankAccount.Validate("Vendor No.", VendorNo);
        VendorBankAccount.Validate(Code, CopyStr(CreateGuid(), 1, MaxStrLen(VendorBankAccount.Code)));
        VendorBankAccount.Insert(true);
        // Spanish Localization workaround
        // Field 10705 - Use For Electronic Payments must be true
        RecRef.Get(VendorBankAccount.RecordId);
        if RecRef.FieldExist(10705) then begin
            FieldRef := RecRef.Field(10705);
            FieldRef.Value := true;
            RecRef.Modify();
        end;

    end;

    local procedure CreateDataExchWithContent(var TempDataExch: Record "Data Exch." temporary; UniqueText: Text)
    var
        DataExchMapping: Record "Data Exch. Mapping";
        BodyTempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
    begin
        LibraryAMCWebService.PrepareAMCBodyForConversion(BodyTempBlob, UniqueText);
        DataExchMapping.SetRange("Mapping Codeunit", CODEUNIT::"AMC Bank Exp. CT Pre-Map");
        DataExchMapping.FindFirst();

        TempDataExch.Init();
        RecordRef.GetTable(TempDataExch);
        BodyTempBlob.ToRecordRef(RecordRef, TempDataExch.FieldNo("File Content"));
        RecordRef.SetTable(TempDataExch);
        TempDataExch."Data Exch. Def Code" := DataExchMapping."Data Exch. Def Code";
        TempDataExch.Insert();
    end;

    local procedure SelectAMCCreditTransferFormat(): Code[20]
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchMapping: Record "Data Exch. Mapping";
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        DataExchDef.SetRange("File Type", DataExchDef."File Type"::Xml);
        DataExchDef.SetRange(Type, DataExchDef.Type::"Payment Export");
        DataExchDef.FindSet();
        repeat
            DataExchMapping.SetRange("Data Exch. Def Code", DataExchDef.Code);
            DataExchMapping.SetRange("Table ID", DATABASE::"Payment Export Data");
            DataExchMapping.SetRange("Mapping Codeunit", CODEUNIT::"AMC Bank Exp. CT Pre-Map");
            if not DataExchMapping.IsEmpty() then begin
                BankExportImportSetup.SetRange("Data Exch. Def. Code", DataExchDef.Code);
                if BankExportImportSetup.FindFirst() then begin
                    DataExchDef.Validate("Ext. Data Handling Codeunit", CODEUNIT::"Generate Payment Data Sample");
                    DataExchDef.Modify(true);
                    exit(BankExportImportSetup.Code);
                end;
            end;
        until DataExchDef.Next() = 0;
        exit('');
    end;

    local procedure PrepareNoSeriesForFixedLineID(): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeries.Init();
        NoSeries.Validate(Code, CopyStr(CreateGuid(), 1, MaxStrLen(NoSeries.Code)));
        NoSeries.Validate("Default Nos.", true);
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Validate("Date Order", false);
        NoSeries.Insert(true);

        NoSeriesLine.Init();
        NoSeriesLine.Validate("Series Code", NoSeries.Code);
        NoSeriesLine.Validate("Line No.", 10000);
        NoSeriesLine.Validate("Starting No.", '1');
        NoSeriesLine.Validate("Ending No.", '1');
        NoSeriesLine.Insert(true);

        exit(NoSeries.Code);
    end;

    local procedure VerifyGenJnlLineError(GenJnlLine: Record "Gen. Journal Line"; ExpectedError: Text[250]; ExpectedHintText: Text[250])
    var
        PaymentJnlExportErrorText: Record "Payment Jnl. Export Error Text";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        PaymentJnlExportErrorText.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        PaymentJnlExportErrorText.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        PaymentJnlExportErrorText.SetRange("Document No.", GenJnlLine."Document No.");
        PaymentJnlExportErrorText.SetRange("Journal Line No.", GenJnlLine."Line No.");
        PaymentJnlExportErrorText.SetFilter("Error Text", '*' + ExpectedError + '*');
        PaymentJnlExportErrorText.SetFilter("Additional Information", '*' + ExpectedHintText + '*');
        if not PaymentJnlExportErrorText.FindFirst() then
            Error(UnexpectedValueErr, ExpectedError);
        AMCBankingSetup.Get();
        Assert.AreNotEqual(AMCBankingSetup."Support URL", PaymentJnlExportErrorText."Support URL",
          'Support URL should not be the default one.');
    end;

    local procedure CreateDummyCreditTransferRegister(var CreditTransferRegister: Record "Credit Transfer Register"; AddFileToBlob: Boolean)
    var
        Stream: OutStream;
    begin
        if CreditTransferRegister.FindLast() then;
        CreditTransferRegister."No." += 1;
        CreditTransferRegister.Insert();

        if not AddFileToBlob then
            exit;

        CreditTransferRegister."Exported File".CreateOutStream(Stream);
        Stream.WriteText('File content.');
        CreditTransferRegister.Modify();
    end;

    local procedure CheckCrTransfRegHist(CreditTransferRegisterNo: Integer; ExpectedCount: Integer)
    var
        CreditTransReExportHistory: Record "Credit Trans Re-export History";
    begin
        CreditTransReExportHistory.SetRange("Credit Transfer Register No.", CreditTransferRegisterNo);
        Assert.AreEqual(ExpectedCount, CreditTransReExportHistory.Count(), 'Wrong number of lines in History table.');
        CreditTransReExportHistory.FindLast();
        Assert.AreEqual(Today(), DT2Date(CreditTransReExportHistory."Re-export Date"), 'Wrong Re-export Date.');
        Assert.AreEqual(CreditTransReExportHistory."Re-exported By", UserId(), 'Wrong Re-exported By.');
    end;

    local procedure CheckCrTransfReg(CreditTransferRegisterNo: Integer)
    var
        CreditTransferRegister: Record "Credit Transfer Register";
    begin
        CreditTransferRegister.Get(CreditTransferRegisterNo);
        Assert.AreEqual(
          CreditTransferRegister.Status::"File Re-exported",
          CreditTransferRegister.Status,
          'Wrong Status after reexporting.');
    end;

    local procedure CheckUniqueTextNotExisting(DataExch: Record "Data Exch."; UniqueText: Text)
    var
        FileContentInStream: InStream;
        FileContent: Text;
    begin
        DataExch.CalcFields("File Content");
        DataExch."File Content".CreateInStream(FileContentInStream);
        FileContentInStream.ReadText(FileContent);
        Assert.AreEqual(0, StrPos(FileContent, UniqueText), '');
    end;
}

