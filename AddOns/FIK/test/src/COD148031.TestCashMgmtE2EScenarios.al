// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148031 "Cash Mgmt E2E Scenarios"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryPaymentExportDK: Codeunit "Library - Payment Export DK";
        LibraryTextFileValidation: Codeunit "Library - Text File Validation";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        FileLineValueIsWrongErr: Label 'Unexpected file value at position %1, length %2.', Locked = true;
        ImportLineTxt: Label 'CMKV,%1,%2,%3,%4,%5,%6,%7,%8', Locked = true;

    trigger OnRun();
    begin
        // [FEATURE] [FIK]
    end;

    [Test]
    [HandlerFunctions('MsgHandler,TransmitHandler,ConfirmHandlerYes')]
    procedure InvoiceExportImportMatchPostReconcile();
    var
        BankAccRec: Record "Bank Acc. Reconciliation";
        Vendor: Record Vendor;
        InvGenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        PmtGenJournalBatch: Record "Gen. Journal Batch";
        ImpGenJournalLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        PmtGenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        FileName: Text;
    begin
        // Post a purchase invoice for a vendor.
        LibraryPaymentExportDK.CreateVendorWithBankAccount(Vendor);
        LibraryPaymentExportDK.AddPaymentTypeInfoToVendor(Vendor, PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        PostVendorInvoice(Vendor, InvGenJournalLine, GenJournalBatch);

        // Create a payment line for the invoice.
        DataExchDef.SETRANGE("Reading/Writing Codeunit", CODEUNIT::"Export BankData Fixed Width");
        DataExchDef.FINDFIRST();
        DataExchDef."Ext. Data Handling Codeunit" := CODEUNIT::"Save Data Exch. Blob Sample";
        DataExchDef.MODIFY();

        LibraryPaymentExportDK.CreatePaymentExportBatch(PmtGenJournalBatch, DataExchDef, XMLPORT::"Export Generic Fixed Width");
        UpdateBankAccountFormat(PmtGenJournalBatch."Bal. Account No.");
        LibraryPaymentExportDK.CreateVendorPmtJnlLine(PmtGenJournalLine, PmtGenJournalBatch, Vendor."No.");
        PmtGenJournalLine."Message to Recipient" := CREATEGUID();
        IF PmtGenJournalLine."Account Type" = PmtGenJournalLine."Account Type"::"Bank Account" THEN
            PmtGenJournalLine."Bank Payment Type" := PmtGenJournalLine."Bank Payment Type"::"Electronic Payment";
        IF PmtGenJournalLine."Bal. Account Type" = PmtGenJournalLine."Bal. Account Type"::"Bank Account" THEN
            PmtGenJournalLine."Bank Payment Type" := PmtGenJournalLine."Bank Payment Type"::"Electronic Payment";
        PmtGenJournalLine.MODIFY();
        ApplyVendorInvoiceToPmt(InvGenJournalLine, PmtGenJournalLine);

        // Export payment to file format: BankData.
        PmtGenJournalLine.SETRANGE("Journal Template Name", PmtGenJournalBatch."Journal Template Name");
        PmtGenJournalLine.SETRANGE("Journal Batch Name", PmtGenJournalBatch.Name);
        PmtGenJournalLine.ExportPaymentFile();

        // Verify the file content.
        VerifyFileContent(PmtGenJournalLine, DataExchDef);

        // Transmit the exported file
        COMMIT();
        PmtGenJournalLine.TransmitPaymentFile();

        // Post the payment.
        LibraryERM.PostGeneralJnlLine(PmtGenJournalLine);

        // Create additional unapplied payment line.
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        PostVendorInvoice(Vendor, InvGenJournalLine, GenJournalBatch);
        LibraryPaymentExportDK.CreatePaymentExportBatch(PmtGenJournalBatch, DataExchDef, XMLPORT::"Export Generic Fixed Width");
        UpdateBankAccountFormat(PmtGenJournalBatch."Bal. Account No.");
        LibraryPaymentExportDK.CreateVendorPmtJnlLine(PmtGenJournalLine, PmtGenJournalBatch, Vendor."No.");
        PmtGenJournalLine."Message to Recipient" := CREATEGUID();
        PmtGenJournalLine."Applies-to Ext. Doc. No." :=
          LibraryUtility.GenerateRandomCode(PmtGenJournalLine.FIELDNO("Applies-to Ext. Doc. No."), DATABASE::"Gen. Journal Line");
        IF PmtGenJournalLine."Account Type" = PmtGenJournalLine."Account Type"::"Bank Account" THEN
            PmtGenJournalLine."Bank Payment Type" := PmtGenJournalLine."Bank Payment Type"::"Electronic Payment";
        IF PmtGenJournalLine."Bal. Account Type" = PmtGenJournalLine."Bal. Account Type"::"Bank Account" THEN
            PmtGenJournalLine."Bank Payment Type" := PmtGenJournalLine."Bank Payment Type"::"Electronic Payment";
        PmtGenJournalLine.MODIFY();

        // Export it.
        PmtGenJournalLine.SETRANGE("Journal Template Name", PmtGenJournalBatch."Journal Template Name");
        PmtGenJournalLine.SETRANGE("Journal Batch Name", PmtGenJournalBatch.Name);
        PmtGenJournalLine.ExportPaymentFile();

        // Import the exported line into Gen. Journal from format: Danske simple CSV.
        FileName := WriteRecordToFile(PmtGenJournalLine);
        CreateGenJnlLineWithBalBankAcc(ImpGenJournalLine);
        ImportBankStatementFileToGenJnl(ImpGenJournalLine, FileName);

        // Verify imported data.
        VerifyImportedGenJnlLine(ImpGenJournalLine, PmtGenJournalLine);

        // Match against the posted invoice.
        ImpGenJournalLine.MatchSingleLedgerEntry();

        // Verify match.
        VerifyGenJnlLineMatch(ImpGenJournalLine, PmtGenJournalLine."Account No.");

        // Post match.
        LibraryERM.PostGeneralJnlLine(ImpGenJournalLine);

        // Create bank reconciliation and import statement.
        LibraryERM.CreateBankAccReconciliation(BankAccRec, ImpGenJournalLine."Bal. Account No.",
          BankAccRec."Statement Type"::"Bank Reconciliation");
        ImportBankStatementFileToBankRec(BankAccRec, FileName);

        // Verify imported data.
        VerifyImportedBankRec(BankAccRec, PmtGenJournalLine);

        // Match the bank rec.
        BankAccRec.MatchSingle(0);

        // Verify match.
        VerifyBankRecMatch(BankAccRec, -PmtGenJournalLine.Amount);

        // Post reconciliation.
        BankAccRec.VALIDATE("Statement Date", WORKDATE());
        BankAccRec.VALIDATE("Statement Ending Balance", -PmtGenJournalLine.Amount);
        BankAccRec.MODIFY();
        LibraryERM.PostBankAccReconciliation(BankAccRec);
    end;

    [Test]
    [HandlerFunctions('MsgHandler,TransmitHandler,ConfirmHandlerYes')]
    procedure InvoiceExportPostImportNoMatch();
    var
        Vendor: Record Vendor;
        InvGenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        ImpGenJournalLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        PmtGenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
    begin
        // Post a purchase invoice for a vendor.
        LibraryPaymentExportDK.CreateVendorWithBankAccount(Vendor);
        LibraryPaymentExportDK.AddPaymentTypeInfoToVendor(Vendor, PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        PostVendorInvoice(Vendor, InvGenJournalLine, GenJournalBatch);

        // Create a payment line for the invoice.
        DataExchDef.SETRANGE("Reading/Writing Codeunit", CODEUNIT::"Exp. Writing Gen. Jnl.");
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic Fixed Width");
        LibraryPaymentExportDK.CreateVendorPmtJnlLine(PmtGenJournalLine, GenJournalBatch, Vendor."No.");
        PmtGenJournalLine."Message to Recipient" := CREATEGUID();
        IF PmtGenJournalLine."Account Type" = PmtGenJournalLine."Account Type"::"Bank Account" THEN
            PmtGenJournalLine."Bank Payment Type" := PmtGenJournalLine."Bank Payment Type"::"Electronic Payment";
        IF PmtGenJournalLine."Bal. Account Type" = PmtGenJournalLine."Bal. Account Type"::"Bank Account" THEN
            PmtGenJournalLine."Bank Payment Type" := PmtGenJournalLine."Bank Payment Type"::"Electronic Payment";
        PmtGenJournalLine.MODIFY();
        ApplyVendorInvoiceToPmt(InvGenJournalLine, PmtGenJournalLine);

        // Export payment to file format: BANKDATA.
        PmtExportMgtGenJnlLine.EnableExportToServerTempFile(TRUE, 'txt');
        PmtExportMgtGenJnlLine.ExportJournalPaymentFileYN(PmtGenJournalLine);

        // Transmit the exported file
        COMMIT();
        PmtGenJournalLine.TransmitPaymentFile();

        // Post the payment.
        LibraryERM.PostGeneralJnlLine(PmtGenJournalLine);

        // Import the exported line into Gen. Journal from format: Danske simple CSV.
        CreateGenJnlLineWithBalBankAcc(ImpGenJournalLine);
        ImportBankStatementFileToGenJnl(ImpGenJournalLine, WriteRecordToFile(PmtGenJournalLine));

        // Verify imported data.
        VerifyImportedGenJnlLine(ImpGenJournalLine, PmtGenJournalLine);

        // Try to match against the posted invoice.
        ImpGenJournalLine.MatchSingleLedgerEntry();

        // Verify match: No match was made.
        Assert.IsFalse(ImpGenJournalLine.IsApplied(), 'Gen jnl. line should not be applied.');
    end;

    local procedure ApplyVendorInvoiceToPmt(var GenJournalLine: Record "Gen. Journal Line"; var PmtGenJournalLine: Record "Gen. Journal Line");
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice, GenJournalLine."Document No.");
        PmtGenJournalLine.VALIDATE("Applies-to Doc. Type", PmtGenJournalLine."Applies-to Doc. Type"::Invoice);
        PmtGenJournalLine.VALIDATE("Applies-to Doc. No.", VendorLedgerEntry."Document No.");
        PmtGenJournalLine.VALIDATE(Amount, -GenJournalLine.Amount);
        PmtGenJournalLine.MODIFY();
    end;

    local procedure CheckColumnValue(Expected: Text; Line: Text[1024]; StartingPosition: Integer; Length: Integer);
    var
        Actual: Text;
    begin
        Actual := ReadFieldValue(Line, StartingPosition, Length);
        Assert.AreEqual(Expected, Actual, STRSUBSTNO(FileLineValueIsWrongErr, StartingPosition, Length));
    end;

    local procedure CreateBankAccount(): Code[20];
    var
        BankAcc: Record "Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        BankExportImportSetup.INIT();
        BankExportImportSetup.Code :=
          LibraryUtility.GenerateRandomCode(BankExportImportSetup.FIELDNO(Code), DATABASE::"Bank Export/Import Setup");
        BankExportImportSetup.Direction := BankExportImportSetup.Direction::Import;
        BankExportImportSetup."Data Exch. Def. Code" := FindDataExchDef('DANSKEBANK-CMKV');
        BankExportImportSetup.INSERT();

        LibraryERM.CreateBankAccount(BankAcc);
        BankAcc.VALIDATE("Bank Branch No.", FORMAT(LibraryRandom.RandIntInRange(1111, 9999)));
        BankAcc.VALIDATE("Bank Account No.", STRSUBSTNO('%1%2', LibraryRandom.RandIntInRange(11111, 99999),
            LibraryRandom.RandIntInRange(11111, 99999)));
        BankAcc."Bank Statement Import Format" := BankExportImportSetup.Code;
        BankAcc.MODIFY(TRUE);
        EXIT(BankAcc."No.");
    end;

    local procedure CreateGenJnlLineWithBalBankAcc(var GenJournalLine: Record "Gen. Journal Line");
    var
        GenJnlBatch: Record "Gen. Journal Batch";
    begin
        LibraryERM.CreateGenJournalBatch(GenJnlBatch, LibraryERM.SelectGenJnlTemplate());
        GenJnlBatch.VALIDATE("Bal. Account Type", GenJnlBatch."Bal. Account Type"::"Bank Account");
        GenJnlBatch.VALIDATE("Bal. Account No.", CreateBankAccount());
        GenJnlBatch.MODIFY(TRUE);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name,
          GenJournalLine."Document Type"::" ", GenJournalLine."Account Type"::"G/L Account", '', 0);
    end;

    local procedure FindDataExchDef(CodeFilter: Text): Code[20];
    var
        DataExchDef: Record "Data Exch. Def";
    begin
        WITH DataExchDef DO BEGIN
            SETRANGE(Type, Type::"Bank Statement Import");
            SETRANGE(Code, CodeFilter);
            SETRANGE("Header Lines", 0);
            FINDFIRST();
            EXIT(Code);
        END;
    end;

    local procedure GetBankAccountDetails(BankAccountNo: Code[20]): Text[14];
    var
        BankAcc: Record "Bank Account";
        BankAccDetails: Text;
    begin
        BankAcc.GET(BankAccountNo);
        BankAccDetails := BankAcc."Bank Branch No." + BankAcc."Bank Account No.";
        EXIT(PADSTR('', 14 - STRLEN(BankAccDetails), '0') + BankAccDetails);
    end;

    local procedure PostVendorInvoice(Vendor: Record Vendor; var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch");
    begin
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
          GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Vendor, Vendor."No.", -LibraryRandom.RandDec(100, 2));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure ReadFieldValue(Line: Text[1024]; StartingPosition: Integer; Length: Integer): Text[1024];
    begin
        EXIT(CopyStr(LibraryTextFileValidation.ReadValue(Line, StartingPosition, Length), 1, 1024));
    end;

    local procedure UpdateBankAccountFormat(BankAccountNo: Code[20]);
    var
        BankAccount: Record "Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        BankAccount.GET(BankAccountNo);
        BankAccount.GetBankExportImportSetup(BankExportImportSetup);
        BankExportImportSetup."Processing Codeunit ID" := CODEUNIT::"Pmt Export Mgt Gen. Jnl Line";
        BankExportImportSetup.MODIFY();
    end;

    local procedure VerifyFileContent(GenJnlLine: Record "Gen. Journal Line"; DataExchDef: Record "Data Exch. Def");
    var
        DataExch: Record "Data Exch.";
        VendorBankAcc: Record "Vendor Bank Account";
        Line: Text[1024];
    begin
        GenJnlLine.FIND();
        DataExch.SETRANGE("Data Exch. Def Code", DataExchDef.Code);
        DataExch.FINDLAST();

        // Header line.
        Line := CopyStr(LibraryTextFileValidation.ReadLine(DataExch."File Name", 1), 1, MaxStrLen(Line));
        CheckColumnValue('IB000000000000', Line, 2, 14);
        CheckColumnValue(FORMAT(GenJnlLine."Posting Date", 0, '<Year4><Month,2><Day,2>'), Line, 19, 8);
        CheckColumnValue(PADSTR('', 90), Line, 30, 90);

        // Data line.
        Line := CopyStr(LibraryTextFileValidation.ReadLine(DataExch."File Name", 2), 1, MaxStrLen(Line));
        CheckColumnValue('IB030202000005', Line, 2, 14);
        CheckColumnValue('0001', Line, 19, 4);
        CheckColumnValue(FORMAT(GenJnlLine."Posting Date", 0, '<Year4><Month,2><Day,2>'), Line, 26, 8);
        CheckColumnValue(FORMAT(GenJnlLine.Amount * 100, 0, '<Integer,13><Filler Character,0><Sign,1><Filler Character,+>'), Line, 37, 14);
        CheckColumnValue('DKK', Line, 54, 3);
        CheckColumnValue('2', Line, 60, 1);
        CheckColumnValue(GetBankAccountDetails(GenJnlLine."Bal. Account No."), Line, 65, 14);
        CheckColumnValue('2', Line, 82, 1);
        VendorBankAcc.GET(GenJnlLine."Account No.", GenJnlLine."Recipient Bank Account");
        CheckColumnValue(VendorBankAcc."Bank Branch No.", Line, 86, 4);
        CheckColumnValue(VendorBankAcc."Bank Account No.", Line, 93, 10);
        CheckColumnValue('0', Line, 106, 1);
        CheckColumnValue(PADSTR(GenJnlLine."Message to Recipient", 35), Line, 110, 35);

        // Footer line.
        Line := CopyStr(LibraryTextFileValidation.ReadLine(DataExch."File Name", 3), 1, MaxStrLen(Line));
        CheckColumnValue('IB999999999999', Line, 2, 14);
        CheckColumnValue(FORMAT(GenJnlLine."Posting Date", 0, '<Year4><Month,2><Day,2>'), Line, 19, 8);
        CheckColumnValue(FORMAT(1, 0, '<Integer,6><Filler Character,0>'), Line, 30, 6);
        CheckColumnValue(FORMAT(GenJnlLine.Amount * 100, 0, '<Integer,13><Filler Character,0><Sign,1><Filler Character,+>'), Line, 39, 14);
    end;

    local procedure ImportBankStatementFileToGenJnl(var GenJnlLine: Record "Gen. Journal Line"; FileName: Text);
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
    begin
        FileManagement.BlobImportFromServerFile(TempBlob, FileName);
        SetupSourceMock(FindDataExchDef('DANSKEBANK-CMKV'), TempBlob);
        GenJnlLine.ImportBankStatement();
    end;

    local procedure ImportBankStatementFileToBankRec(var BankAccRec: Record "Bank Acc. Reconciliation"; FileName: Text);
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
    begin
        FileManagement.BlobImportFromServerFile(TempBlob, FileName);
        SetupSourceMock(FindDataExchDef('DANSKEBANK-CMKV'), TempBlob);
        BankAccRec.ImportBankStatement();
    end;

    local procedure VerifyImportedGenJnlLine(var ActGenJnlLine: Record "Gen. Journal Line"; ExpGenJournalLine: Record "Gen. Journal Line");
    begin
        ActGenJnlLine.SETRANGE("Journal Template Name", ActGenJnlLine."Journal Template Name");
        ActGenJnlLine.SETRANGE("Journal Batch Name", ActGenJnlLine."Journal Batch Name");
        ActGenJnlLine.FINDLAST();
        ActGenJnlLine.TESTFIELD(Amount, ExpGenJournalLine.Amount);
        ActGenJnlLine.TESTFIELD(Description, ExpGenJournalLine.Description);
        ActGenJnlLine.TESTFIELD("Posting Date", ExpGenJournalLine."Posting Date");
    end;

    local procedure VerifyGenJnlLineMatch(var ActGenJnlLine: Record "Gen. Journal Line"; VendorNo: Code[20]);
    begin
        ActGenJnlLine.GET(ActGenJnlLine."Journal Template Name", ActGenJnlLine."Journal Batch Name", ActGenJnlLine."Line No.");
        ActGenJnlLine.TESTFIELD("Account Type", ActGenJnlLine."Account Type"::Vendor);
        ActGenJnlLine.TESTFIELD("Account No.", VendorNo);
        ActGenJnlLine.TESTFIELD("Applies-to ID", ActGenJnlLine."Document No.");
    end;

    local procedure VerifyImportedBankRec(var BankAccRec: Record "Bank Acc. Reconciliation"; GenJnlLine: Record "Gen. Journal Line");
    var
        BankAccRecLine: Record "Bank Acc. Reconciliation Line";
    begin
        BankAccRecLine.SETRANGE("Bank Account No.", BankAccRec."Bank Account No.");
        BankAccRecLine.SETRANGE("Statement No.", BankAccRec."Statement No.");
        Assert.AreEqual(1, BankAccRecLine.COUNT(), 'Wrong no. of bank rec lines.');
        BankAccRecLine.FINDFIRST();
        BankAccRecLine.TESTFIELD("Transaction Date", GenJnlLine."Posting Date");
        BankAccRecLine.TESTFIELD(Description, GenJnlLine.Description);
        BankAccRecLine.TESTFIELD("Statement Amount", -GenJnlLine.Amount);
    end;

    local procedure VerifyBankRecMatch(var BankAccRec: Record "Bank Acc. Reconciliation"; Amount: Decimal);
    var
        BankAccRecLine: Record "Bank Acc. Reconciliation Line";
        BankAccLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        BankAccRecLine.SETRANGE("Bank Account No.", BankAccRec."Bank Account No.");
        BankAccRecLine.SETRANGE("Statement No.", BankAccRec."Statement No.");
        BankAccRecLine.FINDFIRST();
        BankAccRecLine.TESTFIELD("Applied Entries", 1);
        BankAccRecLine.TESTFIELD("Applied Amount", Amount);

        BankAccLedgerEntry.SETRANGE("Bank Account No.", BankAccRec."Bank Account No.");
        BankAccLedgerEntry.SETRANGE("Statement No.", BankAccRecLine."Statement No.");
        BankAccLedgerEntry.SETRANGE("Statement Line No.", BankAccRecLine."Statement Line No.");
        BankAccLedgerEntry.SETRANGE("Statement Status", BankAccLedgerEntry."Statement Status"::"Bank Acc. Entry Applied");
        Assert.AreEqual(1, BankAccLedgerEntry.COUNT(), 'Wrong application.');
    end;

    local procedure WriteRecordToFile(GenJnlLine: Record "Gen. Journal Line") FileName: Text;
    var
        FileMgt: Codeunit "File Management";
        TempFile: File;
    begin
        FileName := FileMgt.ServerTempFileName('csv');
        TempFile.WRITEMODE := TRUE;
        TempFile.TEXTMODE := TRUE;
        TempFile.CREATE(FileName);
        TempFile.WRITE(
          STRSUBSTNO(ImportLineTxt,
            LibraryRandom.RandIntInRange(111111111, 999999999), LibraryRandom.RandIntInRange(111111111, 999999999),
            LibraryRandom.RandIntInRange(111111111, 999999999), FORMAT(WORKDATE(), 0, '<Day,2><Month,2><Year>'),
            FORMAT(WORKDATE(), 0, '<Day,2><Month,2><Year>'), FORMAT(-GenJnlLine.Amount, 0, 2), GenJnlLine.Description,
            LibraryRandom.RandDecInRange(1111, 9999, 2)));
        TempFile.CLOSE();
    end;

    [MessageHandler]
    procedure MsgHandler(Message: Text[1024]);
    begin
    end;

    local procedure SetupSourceMock(DataExchDefCode: Code[20]; TempBlob: Codeunit "Temp Blob");
    var
        DataExchDef: Record "Data Exch. Def";
        TempBlobList: Codeunit "Temp Blob List";
        ErmPeSourceTestMock: Codeunit "ERM PE Source test mock";
    begin
        TempBlobList.Add(TempBlob);
        ErmPeSourceTestMock.SetTempBlobList(TempBlobList);

        DataExchDef.GET(DataExchDefCode);
        DataExchDef."Ext. Data Handling Codeunit" := CODEUNIT::"ERM PE Source test mock";
        DataExchDef.MODIFY();
    end;

    [RequestPageHandler]
    procedure TransmitHandler(var VoidTransmitElecPmnts: TestRequestPage "Void/Transmit Elec. Pmnts");
    begin
        VoidTransmitElecPmnts.OK().INVOKE();
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean);
    begin
        Reply := TRUE;
    end;
}



