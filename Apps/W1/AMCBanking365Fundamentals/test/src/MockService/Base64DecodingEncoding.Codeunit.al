codeunit 135081 "Base64 Decoding / Encoding"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [Data Exchange] [Base64]
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryAMCWebService: Codeunit "Library - Amc Web Service";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        NordeaCorporate_EncodWinTxt: Label '"NDEADKKKXXX","1888","9999940560","DKK","Encoding","","20030221","20030221","15757.25","+","15757.25","","68","","Order 12345","4","500","MEDDELNR 2001æ¹å","0","99999999999903","501","","502","KON konto 0979999035","0","","0","","0","","","","","","","266787.12","+","266787.12","","","Driftskonto","DK3420009999940560","N","Test Testsen","Testvej 10","9999 Testrup","","","","Ordrenr. 65656","99999999999903","1170200109040120000018","7","Betaling af f¹lgende fakturaer:","Fakturanr. Bel¹b:","12345 2500,35","22345 1265,66","32345 5825,00","42345 3635,88","52345 2530,36","","","","","","","","","","","","","","","","","","","","","","","",""', Locked = true;
        IsInitialized: Boolean;
        BankAccMismatchQst: Label 'as specified in the bank statement file.\\Do you want to continue?';
        SubstringNotFoundErr: Label 'Char %1 is not found in string %2', Comment = '%1 = character, %2=content';


    [Test]
    [Scope('OnPrem')]
    procedure DecodePaymentExportFileUsingBase64()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExch: Record "Data Exch.";
        Vendor: Record Vendor;
        CompanyInformation: Record "Company Information";
        InStream: InStream;
        PaymentExportFormat: Code[20];
        Content: Text;
        SpecialChars: Text[3];
        CompanyName: Text[100];
    begin
        // [FEATURE] [Payment Export]
        // [SCENARIO 1] Export Gen. Journal Lines to a payment file with non-ASCII Characters (e.g. "æ¹å").
        // [GIVEN] One or more Gen. Journal Lines, applied to Vendor Ledger Entries.
        // [WHEN] Click the Export to File action on the Payment Journal.
        // [THEN] The payment file is created and saved to disk and non-ASCII characters are preserved.

        if not CompanyInformation.Get() then
            exit;

        // this test is not compatible with these localizations
        if CompanyInformation."Country/Region Code" in ['FI', 'ES', 'NL'] then
            exit;

        Initialize();
        LibraryAMCWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Pre-Setup
        CreateVendorForPaymentExport(Vendor);
        PaymentExportFormat := UpdateExportFormatDefToUseMockExtHandler();
        CreatePaymentExportBatch(GenJournalBatch, PaymentExportFormat);
        CompanyName := CompanyInformation.Name;

        // Setup
        SpecialChars := 'æ¹å';
        CompanyInformation.Name := 'Decoding ' + SpecialChars;
        CompanyInformation.Modify();
        CreatePaymentJournalLine(GenJournalLine, GenJournalBatch, Vendor."No.", 'Decoding ' + SpecialChars);
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account" then
            GenJournalLine."Bank Payment Type" := GenJournalLine."Bank Payment Type"::"Electronic Payment";
        if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account" then
            GenJournalLine."Bank Payment Type" := GenJournalLine."Bank Payment Type"::"Electronic Payment";
        GenJournalLine.Modify();

        // Pre-Exercise
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);

        // Exercise
        GenJournalLine.ExportPaymentFile();

        // Pre-Verify
        DataExch.SetRange("Data Exch. Def Code", PaymentExportFormat);
        DataExch.FindLast();
        DataExch.CalcFields("File Content");
        DataExch."File Content".CreateInStream(InStream, TEXTENCODING::Windows);
        InStream.ReadText(Content);

        // Verify
        Assert.AreNotEqual(0, StrPos(Content, 'æ'), StrSubstNo(SubstringNotFoundErr, 'æ', Content));
        Assert.AreNotEqual(0, StrPos(Content, 'å'), StrSubstNo(SubstringNotFoundErr, 'å', Content));

        // Cleanup
        RestoreExportFormatDefToUseOriginalExtHandler(PaymentExportFormat);
        CompanyInformation.Name := CompanyName;
        CompanyInformation.Modify();
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

    local procedure CreateVendorForPaymentExport(var Vendor: Record Vendor)
    var
        PaymentMethod: Record "Payment Method";
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        LibraryPurchase.CreateVendor(Vendor);

        PaymentMethod.SetRange("AMC Bank Pmt. Type", 'DomAcc2Acc');
        LibraryERM.FindPaymentMethod(PaymentMethod);

        LibraryPurchase.CreateVendorBankAccount(VendorBankAccount, Vendor."No.");
        VendorBankAccount.Validate("Bank Account No.", GetRandomDanishBankAccoutNumber());
        VendorBankAccount.Modify(true);

        Vendor.Validate("Payment Method Code", PaymentMethod.Code);
        Vendor.Validate("Preferred Bank Account Code", VendorBankAccount.Code);
        Vendor.Modify(true);
    end;

    local procedure GetRandomDanishBankAccoutNumber(): Text[30]
    begin
        exit(Format(LibraryRandom.RandIntInRange(1111111, 9999999)) +
          Format(LibraryRandom.RandIntInRange(1111111, 9999999)));
    end;

    local procedure UpdateExportFormatDefToUseMockExtHandler(): Code[20]
    var
        DataExchDef: Record "Data Exch. Def";
    begin
        DataExchDef.SetRange("Ext. Data Handling Codeunit", CODEUNIT::"AMC Bank Exp. CT Hndl");
        DataExchDef.FindFirst();
        DataExchDef.Validate("Ext. Data Handling Codeunit", CODEUNIT::"Generate Payment Data Sample");
        DataExchDef.Modify(true);
        exit(DataExchDef.Code);
    end;

    local procedure CreatePaymentExportBatch(var GenJournalBatch: Record "Gen. Journal Batch"; PaymentExportFormat: Code[20])
    var
        BankAccount: Record "Bank Account";
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate("Bank Account No.", GetRandomDanishBankAccoutNumber());
        BankAccount.Validate("Payment Export Format", PaymentExportFormat);
        BankAccount.Validate("Credit Transfer Msg. Nos.", LibraryERM.CreateNoSeriesCode());
        BankAccount.Validate("AMC Bank Name", 'Danske DK');
        BankAccount.Modify(true);

        LibraryERM.CreateGenJournalBatch(GenJournalBatch, LibraryPurchase.SelectPmtJnlTemplate());
        GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"Bank Account");
        GenJournalBatch.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalBatch.Validate("Allow Payment Export", true);
        GenJournalBatch.Modify(true);
    end;

    local procedure CreatePaymentJournalLine(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch"; VendorNo: Code[20]; MessageToRecipient: Text[70])
    begin
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));
        GenJournalLine.Validate("Posting Date", Today());
        GenJournalLine.Validate("Message to Recipient", MessageToRecipient);
        GenJournalLine.Modify(true);
    end;

    local procedure RestoreExportFormatDefToUseOriginalExtHandler(PaymentExportFormat: Code[20])
    var
        DataExchDef: Record "Data Exch. Def";
    begin
        DataExchDef.Get(PaymentExportFormat);
        DataExchDef.Validate("Ext. Data Handling Codeunit", CODEUNIT::"AMC Bank Exp. CT Hndl");
        DataExchDef.Modify(true);
    end;


    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandlerTrue')]
    procedure EncodeNordeaCorpBankStatementFileUsingBase64()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        CompanyInformation: Record "Company Information";
        TempBlob: Codeunit "Temp Blob";
        BankStatementImportFormat: Code[20];
        LCYCode: Code[10];
        DummyBool: Boolean;
    begin
        // [FEATURE] [Import Bank Statement]
        // [SCENARIO 3] Import a bank statement file with non-ASCII Characters (e.g. "æ¹å").
        // [GIVEN] Nordea Corporate bank statement file with non-ASCII characters.
        // [WHEN] Click the Import Bank Statement action on the Bank Account Reconciliation card.
        // [THEN] The bank statment is imported and non-ASCII characters are preserved.

        // this test is not compatible with these localizations
        if not CompanyInformation.Get() then
            exit;
        if CompanyInformation."Country/Region Code" in ['FI', 'ES', 'NL'] then begin
            DummyBool := Confirm(BankAccMismatchQst, true);
            Clear(DummyBool);
            exit;
        end;

        Initialize();
        LibraryAMCWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_STMT());

        // Setup
        GeneralLedgerSetup.Get();
        LCYCode := GeneralLedgerSetup."LCY Code";
        GeneralLedgerSetup."LCY Code" := 'DKK';
        GeneralLedgerSetup.Modify();
        ReadNordeaCorpBankStatmentFile(TempBlob);
        BankStatementImportFormat := UpdateImportFormatDefToUseMockExtHandler();
        CreateBankAccountReconciliation(BankAccReconciliation, BankStatementImportFormat);

        // Exercise
        BankAccReconciliation.ImportBankStatement();

        // Verify
        BankAccReconciliationLine.SetRange("Statement Type", BankAccReconciliation."Statement Type");
        BankAccReconciliationLine.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        Assert.AreEqual(1, BankAccReconciliationLine.Count(), 'Only one line should have been imported.');

        BankAccReconciliationLine.FindFirst();
        // Assert.AreEqual('MEDDELNR 2001æ¹å',BankAccReconciliationLine.Description,'Description was not imported correctly.');
        Assert.AreNotEqual(0, StrPos(BankAccReconciliationLine.Description, 'MEDDELNR 2001æ'),
          StrSubstNo(SubstringNotFoundErr, 'MEDDELNR 2001æ', BankAccReconciliationLine.Description));
        Assert.AreNotEqual(0, StrPos(BankAccReconciliationLine.Description, 'å'),
          StrSubstNo(SubstringNotFoundErr, 'å', BankAccReconciliationLine.Description));

        // Cleanup
        RestoreImportFormatDefToUseOriginalExtHandler(BankStatementImportFormat);
        GeneralLedgerSetup."LCY Code" := LCYCode;
        GeneralLedgerSetup.Modify();
    end;


    local procedure ReadNordeaCorpBankStatmentFile(var TempBlob: Codeunit "Temp Blob")
    var
        ErmPeSourceTestMock: Codeunit "ERM PE Source Test Mock";
        TempBlobList: Codeunit "Temp Blob List";
        OutputStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutputStream, TEXTENCODING::Windows);
        OutputStream.WriteText(NordeaCorporate_EncodWinTxt);

        TempBlobList.Add(TempBlob);
        ErmPeSourceTestMock.SetTempBlobList(TempBlobList);
    end;

    local procedure UpdateImportFormatDefToUseMockExtHandler(): Code[20]
    var
        DataExchDef: Record "Data Exch. Def";
    begin
        DataExchDef.SetRange("Ext. Data Handling Codeunit", CODEUNIT::"AMC Bank Imp.STMT. Hndl");
        DataExchDef.FindFirst();
        DataExchDef.Validate("Ext. Data Handling Codeunit", CODEUNIT::"Generate Bank Stmt. Sample");
        DataExchDef.Modify(true);
        exit(DataExchDef.Code);
    end;

    local procedure CreateBankAccountReconciliation(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; BankStatementImportFormat: Code[20])
    var
        BankAccount: Record "Bank Account";
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate("Bank Branch No.", '1888');
        BankAccount.Validate("Bank Account No.", '9999940560');
        BankAccount.Validate("Bank Statement Import Format", BankStatementImportFormat);
        BankAccount.Modify(true);

        LibraryERM.CreateBankAccReconciliation(BankAccReconciliation,
          BankAccount."No.", BankAccReconciliation."Statement Type"::"Bank Reconciliation");
    end;

    local procedure RestoreImportFormatDefToUseOriginalExtHandler(BankStatementImportFormat: Code[20])
    var
        DataExchDef: Record "Data Exch. Def";
    begin
        DataExchDef.Get(BankStatementImportFormat);
        DataExchDef.Validate("Ext. Data Handling Codeunit", CODEUNIT::"AMC Bank Imp.STMT. Hndl");
        DataExchDef.Modify(true);
    end;


    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandlerTrue(Question: Text[1024]; var Reply: Boolean)
    var
    begin
        if StrPos(Question, BankAccMismatchQst) > 0 then
            Reply := true
        else
            Reply := false;
    end;
}

