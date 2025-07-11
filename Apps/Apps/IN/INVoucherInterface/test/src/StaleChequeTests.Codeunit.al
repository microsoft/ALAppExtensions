codeunit 18999 "Stale Cheque Tests"
{
    Subtype = Test;

    var
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        LibraryJournals: Codeunit "Library - Journals";
        LibraryERM: Codeunit "Library - ERM";
        StaleChequeStipulatedPeriod: DateFormula;
        Storage: Dictionary of [Text, Text];
        StorageDate: Dictionary of [Text, Date];
        AccountNoLbl: Label 'Account No', Locked = true;
        TemplateNameLbl: Label 'TemplateName', Locked = true;
        ChequeNoLbl: Label 'ChequeNo', Locked = true;
        ChequeDateLbl: Label 'ChequeDate', Locked = true;
        WorkDateLbl: Label 'WorkDate', Locked = true;
        TDSSectionLbl: Label 'TDSSection', locked = true;
        AssesseeCodeLbl: Label 'AssesseeCode', locked = true;
        NotVerifiedErr: Label 'Check Ledger Entries Not Verified', Locked = true;
        CheckMarkedStaleErr: Label 'The cheque has already been marked stale.', Locked = true;
        StaleChequeExpiryDateErr: Label 'Bank Ledger Entry can be marked as stale only after %1.', Comment = '%1 = Stale Cheque Expiry Date', Locked = true;

    [Test]
    procedure VerifyCheckLedgerEntriesWithChequeNo()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ChequeNo: Code[20];
    begin
        // [SCENARIO] [391033] Check if the system is populating the cheque number field in the check ledger entry mentioned in the last check no. field on the bank card if bank payment type is “Computer Check” in Bank Payment Voucher.
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        ActivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Computer Check
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::"Bank Payment Voucher",
            Enum::"Bank Payment Type"::"Computer Check");
        ChequeNo := RunPrintCheckReport(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Check Ledger Etries are Verified with Check No.,Cheque Date and Entry Status
        VerifyCheckLedgerEntriesWithEntryStatus(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    procedure VerifyCheckLedgerEntriesWithChequeDateOnBankPaymentVoucher()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ChequeNo: Code[20];
    begin
        // [SCENARIO] [391022] Check if the system is populating the cheque date as posting date in the check ledger entry if the cheque date is not mentioned in Bank Payment Voucher if bank payment type is “Computer Check”. 
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        ActivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Computer Check
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::"Bank Payment Voucher",
            Enum::"Bank Payment Type"::"Computer Check");
        ChequeNo := RunPrintCheckReport(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Check Ledger Etries are Verified with Check No.,Cheque Date and Entry Status
        VerifyCheckLedgerEntriesWithEntryStatus(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    procedure VerifyCheckLedgerEntriesWithChequeDateOnPaymentJournal()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ChequeNo: Code[20];
    begin
        // [SCENARIO] [391010] Check if the system is populating the cheque date as posting date in the check ledger entry if the cheque date is not mentioned in Payment Journal if bank payment type is “Computer Check”. 
        // [GIVEN] Create Voucher Setup For Voucher Type Payment Journal
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        ActivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Payment Voucher with Bank Payment Type Computer Check
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::Payments,
            Enum::"Bank Payment Type"::"Computer Check");
        ChequeNo := RunPrintCheckReport(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Check Ledger Etries are Verified with Check No.,Cheque Date and Entry Status
        VerifyCheckLedgerEntriesWithEntryStatus(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    procedure VerifyCheckLedgerEntriesWithBankPaymentTypeManualCheck()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ChequeNo: Code[20];
    begin
        // [SCENARIO] [391126] Check if the system is changing the entry status as “Financially voided” in the check ledger entry if the bank payment type is “Computer Check”.
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        ActivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Manual Check
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::"Bank Payment Voucher",
            Enum::"Bank Payment Type"::"Manual Check");
        UpdateChequeNoandChequeDate(GenJournalLine, true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        ChequeNo := GetChequeNoFromCheckLedgerEntry(GenJournalLine."Document No.", GenJournalLine."Bal. Account No.");

        // [THEN] Check Ledger Etries are Verified with Entry Status,Cheque No and Date
        VerifyCheckLedgerEntriesWithEntryStatus(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure VerifyStaleChequeExpiryDateErrorOnBankLedgerEntry()
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO] [391263] Check if the system allows to mark the cheque as stale before its expiry period in the bank ledger entry.
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        ActivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Blank
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::"Bank Payment Voucher",
            Enum::"Bank Payment Type"::" ");
        UpdateChequeNoandChequeDate(GenJournalLine, true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        asserterror InvokeStaleCheckOnBankAccLedgerEntry((Storage.Get(ChequeNoLbl)));

        // [THEN] Stale Cheque Expiry Date Error Verified On Bank Ledger Entry
        Assert.ExpectedError(StrSubstNo(StaleChequeExpiryDateErr, GetStaleChequeStipulatedDate((Storage.Get(ChequeNoLbl)))));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure VerifyCheckMarkedStaleErrorOnBankLedgerEntry()
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO] [391263] Check if the system allows to mark the cheque as stale before its expiry period in the bank ledger entry.
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        ActivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Blank
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::"Bank Payment Voucher",
            Enum::"Bank Payment Type"::" ");
        UpdateChequeNoandChequeDate(GenJournalLine, false);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        InvokeStaleCheckOnBankAccLedgerEntry((Storage.Get(ChequeNoLbl)));
        asserterror InvokeStaleCheckOnBankAccLedgerEntry((Storage.Get(ChequeNoLbl)));

        // [THEN] Stale Cheque Expiry Date Error Verified On Bank Ledger Entry
        Assert.ExpectedError(CheckMarkedStaleErr);
    end;

    [Test]
    [HandlerFunctions('ConfirmFinancialVoid')]
    procedure VerifyVoidCheckOnCheckLedgerEntries()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ChequeNo: Code[20];
    begin
        // [SCENARIO] [391126] Check if the system is changing the entry status as “Financially voided” in the check ledger entry if the bank payment type is “Computer Check”.
        // [SCENARIO] [391124] Check if the system is populating the cheque stale date field as soon as a check mark appears in the stale cheque field in the check ledger entry if bank payment type is “Computer Check”.
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        ActivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Computer Check
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::"Bank Payment Voucher",
            Enum::"Bank Payment Type"::"Computer Check");
        ChequeNo := RunPrintCheckReport(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        InvokeVoidCheck(ChequeNo);

        // [THEN] Check Ledger Entries are Verified with Entry Status,Cheque No and Date
        VerifyCheckLedgerEntriesAfterVoidCheck(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure VerifyStaleCheckOnBankAccLedgerEntriesWithActivateChequeNo()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ChequeNo: Code[20];
    begin
        // [SCENARIO] [391144] Check if the system is populating the cheque stale date field as soon as a check mark appears in the stale cheque field in the bank ledger entry if the bank payment type is “Blank”.
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        ActivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Blank
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::"Bank Payment Voucher",
            Enum::"Bank Payment Type"::" ");
        UpdateChequeNoandChequeDate(GenJournalLine, true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        ChequeNo := GetChequeNoFromBankLedgerEntry(GenJournalLine."Document No.", GenJournalLine."Bal. Account No.");
        SetWorkDate();
        InvokeStaleCheckOnBankAccLedgerEntry(ChequeNo);
        WorkDate(StorageDate.Get(WorkDateLbl));

        // [THEN] Bank Acc Ledger Entries are Verified with Entry Status,Cheque No and Date
        VerifyBankAccLedgerEntriesAfterStaleCheck(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmFinancialStale')]
    procedure VerifyStaleCheckOnCheckLedgerEntriesWithActivateChequeNo()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ChequeNo: Code[20];
    begin
        // [SCENARIO] [391135] Check if the system allows the stale cheque functionality in the check ledger entry if the bank payment type is ‘Manual Check”.
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        ActivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Manual Check
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::"Bank Payment Voucher",
            Enum::"Bank Payment Type"::"Manual Check");
        UpdateChequeNoandChequeDate(GenJournalLine, true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        ChequeNo := GetChequeNoFromBankLedgerEntry(GenJournalLine."Document No.", GenJournalLine."Bal. Account No.");
        SetWorkDate();
        InvokeStaleCheckOnCheckLedgerEntry(ChequeNo);
        WorkDate(StorageDate.Get(WorkDateLbl));

        // [THEN] Bank Acc Ledger Entries are Verified with Entry Status,Cheque No and Date
        VerifyCheckLedgerEntriesAfterStaleCheck(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    procedure VerifyCheckLedgerEntriesWithChequeDateThrougBankPaymentVoucher()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ChequeNo: Code[20];
    begin
        // [SCENARIO] [390702] Check if the system is populating the cheque date in the check ledger entry entered through Payment journal and Bank Payment Voucher if bank payment type is “Computer Check”.
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        ActivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Computer Check
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::"Bank Payment Voucher",
            Enum::"Bank Payment Type"::"Computer Check");
        ChequeNo := RunPrintCheckReport(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Check Ledger Entries are Verified with Check No.,Cheque Date and Entry Status
        VerifyCheckLedgerEntriesWithEntryStatus(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    procedure VerifyCheckLedgerEntriesWithChequeNoThrougBankPaymentVoucher()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ChequeNo: Code[20];
    begin
        // [SCENARIO] [391031] Check if the system is populating the cheque number field in the check ledger entry mentioned in the last check no. field on the bank card if bank payment type is “Computer Check” in Bank Payment Voucher.
        // [SCENARIO] [391025] Check if the system is populating the stale cheque expiry date by taking into consideration the stale cheque stipulated period and cheque date in the check ledger entry if bank payment type is “Computer Check” using Bank Payment Voucher
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        ActivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Computer Check
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::"Bank Payment Voucher",
            Enum::"Bank Payment Type"::"Computer Check");
        ChequeNo := RunPrintCheckReport(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Check Ledger Entries are Verified with Check No.,Cheque Date and Entry Status
        VerifyCheckLedgerEntriesWithEntryStatus(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    procedure VerifyCheckLedgerEntriesWithChequeNoThrougPaymentJournal()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ChequeNo: Code[20];
    begin
        // [SCENARIO] [391023] Check if the system is populating the stale cheque expiry date by taking into consideration the stale cheque stipulated period and cheque date in the check ledger entry if bank payment type is “Computer Check” using Payment Journal
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        ActivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Payment Journal with Bank Payment Type Computer Check
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::Payments,
            Enum::"Bank Payment Type"::"Computer Check");
        ChequeNo := RunPrintCheckReport(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Check Ledger Entries are Verified with Check No.,Cheque Date and Entry Status
        VerifyCheckLedgerEntriesWithEntryStatus(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmFinancialStale')]
    procedure VerifyStaleCheckOnCheckLedgerEntries()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ChequeNo: Code[20];
    begin
        // [SCENARIO] [391126] Check if the system is changing the entry status as “Financially voided” in the check ledger entry if the bank payment type is “Computer Check”.
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        ActivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Computer Check
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::"Bank Payment Voucher",
            Enum::"Bank Payment Type"::"Computer Check");
        ChequeNo := RunPrintCheckReport(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        SetWorkDate();
        InvokeStaleCheckOnCheckLedgerEntry(ChequeNo);
        WorkDate(StorageDate.Get(WorkDateLbl));

        // [THEN] Check Ledger Entries are Verified with Entry Status,Cheque No and Date
        VerifyCheckLedgerEntriesAfterStaleCheck(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmFinancialStale')]
    procedure VerifyStaleCheckOnCheckLedgerEntriesWithoutActivateChequeNo()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ChequeNo: Code[20];
    begin
        // [SCENARIO] [391255] Check if the system is allowing the stale cheque functionality in the check ledger entry if the activate cheque field is “False” and bank payment type is “Manual Check”in Bank Payment Voucher.
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        DeactivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Manual Check
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::"Bank Payment Voucher",
            Enum::"Bank Payment Type"::"Manual Check");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        ChequeNo := GetChequeNoFromCheckLedgerEntry(GenJournalLine."Document No.", GenJournalLine."Bal. Account No.");
        SetWorkDate();
        InvokeStaleCheckOnCheckLedgerEntry(ChequeNo);
        WorkDate(StorageDate.Get(WorkDateLbl));

        // [THEN] Check Ledger Entries are Verified with Entry Status,Cheque No and Date
        VerifyCheckLedgerEntriesAfterStaleCheck(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure VerifyStaleCheckOnBankLedgerEntriesNotActiveThroughBankPaymnt()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ChequeNo: Code[20];
    begin
        // [SCENARIO] [391254] Check if the system is allowing the stale cheque functionality in the bank ledger entry if the activate cheque no. field is “False” and bank payment type is “Blank” in Bank Payment Voucher.
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        DeactivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Blank
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::"Bank Payment Voucher",
            Enum::"Bank Payment Type"::" ");
        UpdateChequeNoandChequeDate(GenJournalLine, false);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        ChequeNo := GetChequeNoFromBankLedgerEntry(GenJournalLine."Document No.", GenJournalLine."Bal. Account No.");
        SetWorkDate();
        InvokeStaleCheckOnBankAccLedgerEntry(ChequeNo);
        WorkDate(StorageDate.Get(WorkDateLbl));

        // [THEN] Check Ledger Entries are Verified with Entry Status,Cheque No and Date
        VerifyBankAccLedgerEntriesAfterStaleCheck(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure VerifyStaleCheckOnBankLedgerEntriesNotActiveThroughPaymntJnl()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ChequeNo: Code[20];
    begin
        // [SCENARIO] [391183] Check if the system is allowing the stale cheque functionality in the bank ledger entry if the activate cheque no. field is “False” and bank payment type is “Blank” in Payment Journal.
        // [GIVEN] Create Voucher Setup For Voucher Type Payment Journal
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        DeactivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Payment Journal with Bank Payment Type Blank
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::Payments,
            Enum::"Bank Payment Type"::" ");
        UpdateChequeNoandChequeDate(GenJournalLine, false);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        ChequeNo := GetChequeNoFromBankLedgerEntry(GenJournalLine."Document No.", GenJournalLine."Bal. Account No.");
        SetWorkDate();
        InvokeStaleCheckOnBankAccLedgerEntry(ChequeNo);
        WorkDate(StorageDate.Get(WorkDateLbl));

        // [THEN] Check Ledger Entries are Verified with Entry Status,Cheque No and Date
        VerifyBankAccLedgerEntriesAfterStaleCheck(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmFinancialVoid')]
    procedure VerifyVoidCheckOnCheckLedgerEntriesCheckNotActiveThroughBankPaymentVoucher()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ChequeNo: Code[20];
    begin
        // [SCENARIO] [391256] Check if the system is allowing the stale cheque functionality in the check ledger entry if the activate cheque no. field is “False” and bank payment type is “Computer Check” in Bank Payment Voucher.
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        DeactivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Computer Check
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::"Bank Payment Voucher",
            Enum::"Bank Payment Type"::"Computer Check");
        ChequeNo := RunPrintCheckReport(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        InvokeVoidCheck(ChequeNo);

        // [THEN] Check Ledger Entries are Verified with Entry Status,Cheque No and Date
        VerifyCheckLedgerEntriesAfterVoidCheck(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmFinancialVoid')]
    procedure VerifyVoidCheckOnCheckLedgerEntriesCheckNotActiveThroughPaymentJournal()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ChequeNo: Code[20];
    begin
        // [SCENARIO] [391178] Check if the system is allowing the stale cheque functionality in the check ledger entry if the activate cheque no. field is “False” and bank payment type is “Computer Check” in Payment Journal.
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        DeactivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Computer Check
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::Payments,
            Enum::"Bank Payment Type"::"Computer Check");
        ChequeNo := RunPrintCheckReport(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        InvokeVoidCheck(ChequeNo);

        // [THEN] Check Ledger Entries are Verified with Entry Status,Cheque No and Date
        VerifyCheckLedgerEntriesAfterVoidCheck(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmFinancialStale')]
    procedure VerifyVoidCheckOnCheckLedgerEntriesCheckNotActiveThroughPaymentJnlManual()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ChequeNo: Code[20];
    begin
        // [SCENARIO] [391178] Check if the system is allowing the stale cheque functionality in the check ledger entry if the activate cheque no. field is “False” and bank payment type is “Computer Check” in Payment Journal.
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher
        CreateVoucherSetup(Enum::"Gen. Journal Template Type"::"Bank Payment Voucher");
        DeactivateChequeNoOnGeneralLedgerSetup();

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Manual Check
        CreateGenJnlLineWithVoucherType(
            GenJournalLine,
            Enum::"Gen. Journal Document Type"::Payment,
            Enum::"Gen. Journal Template Type"::Payments,
            Enum::"Bank Payment Type"::"Manual Check");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        ChequeNo := GetChequeNoFromCheckLedgerEntry(GenJournalLine."Document No.", GenJournalLine."Bal. Account No.");
        SetWorkDate();
        InvokeStaleCheckOnCheckLedgerEntry(ChequeNo);
        WorkDate(StorageDate.Get(WorkDateLbl));

        // [THEN] Check Ledger Entries are Verified with Entry Status,Cheque No and Date
        VerifyCheckLedgerEntriesAfterStaleCheck(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmFinancialStale,TaxRatePageHandler')]
    procedure VerifyStaleCheckOnCheckLedgerEntriesWithTDS()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        TaxBaseTestPublishers: Codeunit "Tax Base Test Publishers";
        TDSSection: Code[10];
        ChequeNo: Code[10];
    begin
        TDSSection := '';

        // [SCENARIO] Check if the system is reversing TDS transactions if check stale is used in bank ledger entry when bank payment type is “Manual Check”.
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher, Create TDS Setup, TDS Section Assessee Code and Concessional Code
        ActivateChequeNoOnGeneralLedgerSetup();
        TaxBaseTestPublishers.CreateTDSSetupStale(TDSSection, Vendor);
        Storage.Set(TDSSectionLbl, TDSSection);
        Storage.Set(AssesseeCodeLbl, Vendor."Assessee Code");

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Manual Check
        TaxBaseTestPublishers.CreateGenJournalLineWithTDSStale(GenJournalLine, Vendor, TDSSection);
        UpdateChequeDetails(GenJournalLine, ChequeNo);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        SetWorkDate();
        InvokeStaleCheckOnCheckLedgerEntry(ChequeNo);
        WorkDate(StorageDate.Get(WorkDateLbl));

        // [THEN] Check Ledger Entries are Verified with Entry Status,Cheque No and Date
        VerifyCheckLedgerEntriesAfterStaleCheck(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmFinancialStale,TaxRatePageHandler')]
    procedure VerifyStaleCheckOnCheckLedgerEntriesWithTDSComputerCheque()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        BankAccount: Record "Bank Account";
        TaxBaseTestPublishers: Codeunit "Tax Base Test Publishers";
        TDSSection: Code[10];
        ChequeNo: Code[10];
    begin
        TDSSection := '';

        // [SCENARIO] [391270] Check if the system is reversing TDS transactions if check stale is used in bank ledger entry when bank payment type is “Computer Check”.
        // [GIVEN] Create Voucher Setup For Voucher Type Bank Payment Voucher, Create TDS Setup, TDS Section Assessee Code and Concessional Code
        ActivateChequeNoOnGeneralLedgerSetup();
        TaxBaseTestPublishers.CreateTDSSetupStale(TDSSection, Vendor);
        Storage.Set(TDSSectionLbl, TDSSection);
        Storage.Set(AssesseeCodeLbl, Vendor."Assessee Code");

        // [WHEN] Create and Post Bank Payment Voucher with Bank Payment Type Computer Check
        TaxBaseTestPublishers.CreateGenJournalLineWithTDSStale(GenJournalLine, Vendor, TDSSection);
        Storage.Set(AccountNoLbl, GenJournalLine."Bal. Account No.");
        GenJournalLine.Validate("Bank Payment Type", GenJournalLine."Bank Payment Type"::"Computer Check");
        GenJournalLine.Modify();
        BankAccount.Get(GenJournalLine."Bal. Account No.");
        UpdateBankAccLastCheckWithStalePeriod(BankAccount);
        ChequeNo := CopyStr(RunPrintCheckReport(GenJournalLine), 1, MaxStrLen(ChequeNo));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        SetWorkDate();
        InvokeStaleCheckOnCheckLedgerEntry(ChequeNo);
        WorkDate(StorageDate.Get(WorkDateLbl));

        // [THEN] Check Ledger Entries are Verified with Entry Status,Cheque No and Date
        VerifyCheckLedgerEntriesAfterStaleCheck(ChequeNo, GenJournalLine."Bal. Account No.");
    end;

    local procedure UpdateChequeDetails(var GenJournalLine: Record "Gen. Journal Line"; var ChequeNo: Code[10])
    begin
        Storage.Set(AccountNoLbl, GenJournalLine."Bal. Account No.");
        ChequeNo := CopyStr(LibraryRandom.RandText(10), 1, MaxStrLen(ChequeNo));
        GenJournalLine.Validate("Bank Payment Type", GenJournalLine."Bank Payment Type"::"Manual Check");
        GenJournalLine."Cheque No." := ChequeNo;
        GenJournalLine."Cheque Date" := WorkDate();
        GenJournalLine.Modify();
    end;

    local procedure ActivateChequeNoOnGeneralLedgerSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Activate Cheque No.", true);
        GeneralLedgerSetup.Modify(true);
    end;

    local procedure DeactivateChequeNoOnGeneralLedgerSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Activate Cheque No.", false);
        GeneralLedgerSetup.Modify(true);
    end;

    local procedure VerifyBankAccLedgerEntriesAfterStaleCheck(ChequeNo: Code[20]; BankAccNo: Code[20])
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        BankAccountLedgerEntry.SetRange(BankAccountLedgerEntry."Bank Account No.", BankAccNo);
        BankAccountLedgerEntry.SetRange(BankAccountLedgerEntry."Cheque No.", ChequeNo);
        BankAccountLedgerEntry.FindFirst();
        Assert.AreEqual(ChequeNo, BankAccountLedgerEntry."Cheque No.", NotVerifiedErr);
        Assert.AreEqual(WorkDate(), BankAccountLedgerEntry."Cheque Date", NotVerifiedErr);
        Assert.AreEqual(true, BankAccountLedgerEntry."Stale Cheque", NotVerifiedErr);
        Assert.AreEqual(CalcDate('<3M+1D>', WorkDate()), BankAccountLedgerEntry."Cheque Stale Date", NotVerifiedErr);
        Assert.RecordIsNotEmpty(BankAccountLedgerEntry);
    end;

    local procedure InvokeVoidCheck(ChequeNo: Code[20])
    var
        CheckLedgerEntries: TestPage "Check Ledger Entries";
    begin
        CheckLedgerEntries.OpenEdit();
        CheckLedgerEntries.Filter.SetFilter("Check No.", ChequeNo);
        CheckLedgerEntries."Void Check".Invoke();
    end;

    local procedure InvokeStaleCheckOnBankAccLedgerEntry(ChequeNo: Code[20])
    var
        BankAccountLedgerEntries: TestPage "Bank Account Ledger Entries";
    begin
        BankAccountLedgerEntries.OpenEdit();
        BankAccountLedgerEntries.Filter.SetFilter("Cheque No.", ChequeNo);
        BankAccountLedgerEntries.Stale_Check.Invoke();
    end;

    local procedure InvokeStaleCheckOnCheckLedgerEntry(ChequeNo: Code[20])
    var
        CheckLedgerEntries: TestPage "Check Ledger Entries";
    begin
        CheckLedgerEntries.OpenEdit();
        CheckLedgerEntries.Filter.SetFilter("Check No.", ChequeNo);
        CheckLedgerEntries."Stale Check".Invoke();
    end;

    local procedure GetChequeNoFromCheckLedgerEntry(DocNo: Code[20]; BankAccNo: Code[20]): Code[20];
    var
        CheckLedgerEntry: Record "Check Ledger Entry";
    begin
        CheckLedgerEntry.SetRange("Document No.", DocNo);
        CheckLedgerEntry.SetRange("Bank Account No.", BankAccNo);
        if CheckLedgerEntry.FindFirst() then
            exit(CheckLedgerEntry."Check No.");
    end;

    local procedure GetChequeNoFromBankLedgerEntry(DocNo: Code[20]; BankAccNo: Code[20]): Code[20];
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        BankAccountLedgerEntry.SetRange("Document No.", DocNo);
        BankAccountLedgerEntry.SetRange("Bank Account No.", BankAccNo);
        if BankAccountLedgerEntry.FindFirst() then
            exit(BankAccountLedgerEntry."Cheque No.");
    end;

    local procedure UpdateChequeNoandChequeDate(var GenJournalLine: Record "Gen. Journal Line"; SetWorkDateAsCheckDate: Boolean)
    begin
        GenJournalLine.Validate("Cheque No.", LibraryUtility.GenerateRandomCode(GenJournalLine.FieldNo("Cheque No."), DATABASE::"Gen. Journal Line"));
        if SetWorkDateAsCheckDate then
            GenJournalLine.Validate("Cheque Date", WorkDate())
        else
            GenJournalLine.Validate("Cheque Date", CalcDate('<-3M-1D>', WorkDate()));
        GenJournalLine.Modify(true);
        Storage.Set(ChequeNoLbl, GenJournalLine."Cheque No.");
        StorageDate.Set(ChequeDateLbl, GenJournalLine."Cheque Date");
    end;

    local procedure GetStaleChequeStipulatedDate(ChequeNo: Code[20]): Date
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        BankAccountLedgerEntry.SetRange("Cheque No.", ChequeNo);
        BankAccountLedgerEntry.FindFirst();
        exit(BankAccountLedgerEntry."Stale Cheque Expiry Date");
    end;

    local procedure RunPrintCheckReport(GenJournalLine: Record "Gen. Journal Line"): Code[20]
    var
        BankAccount: Record "Bank Account";
        CheckReport: Report "Check Report";
    begin
        BankAccount.Get(Storage.Get(AccountNoLbl));
        CheckReport.SetTableView(GenJournalLine);
        CheckReport.InitializeRequest(BankAccount."No.", BankAccount."Last Check No.", false, false, false, false);
        CheckReport.UseRequestPage(false);
        CheckReport.Run();
        exit(IncStr(BankAccount."Last Check No."));
    end;

    local procedure VerifyCheckLedgerEntriesWithEntryStatus(ChequeNo: Code[20]; BankAccNo: Code[20])
    var
        CheckLedgerEntry: Record "Check Ledger Entry";
    begin
        CheckLedgerEntry.SetRange(CheckLedgerEntry."Bank Account No.", BankAccNo);
        CheckLedgerEntry.SetRange(CheckLedgerEntry."Check No.", ChequeNo);
        CheckLedgerEntry.FindFirst();
        Assert.AreEqual(CheckLedgerEntry."Entry Status"::Posted, CheckLedgerEntry."Entry Status", NotVerifiedErr);
        Assert.AreEqual(ChequeNo, CheckLedgerEntry."Check No.", NotVerifiedErr);
        Assert.AreEqual(WorkDate(), CheckLedgerEntry."Check Date", NotVerifiedErr);
        Assert.RecordIsNotEmpty(CheckLedgerEntry);
    end;

    local procedure VerifyCheckLedgerEntriesAfterVoidCheck(ChequeNo: Code[20]; BankAccNo: Code[20])
    var
        CheckLedgerEntry: Record "Check Ledger Entry";
    begin
        CheckLedgerEntry.SetRange("Bank Account No.", BankAccNo);
        CheckLedgerEntry.SetRange(CheckLedgerEntry."Check No.", ChequeNo);
        CheckLedgerEntry.FindFirst();
        Assert.AreEqual(CheckLedgerEntry."Entry Status"::"Financially Voided", CheckLedgerEntry."Entry Status", NotVerifiedErr);
        Assert.AreEqual(ChequeNo, CheckLedgerEntry."Check No.", NotVerifiedErr);
        Assert.AreEqual(WorkDate(), CheckLedgerEntry."Check Date", NotVerifiedErr);
        Assert.RecordIsNotEmpty(CheckLedgerEntry);
    end;

    local procedure VerifyCheckLedgerEntriesAfterStaleCheck(ChequeNo: Code[20]; BankAccNo: Code[20])
    var
        CheckLedgerEntry: Record "Check Ledger Entry";
    begin
        CheckLedgerEntry.SetRange(CheckLedgerEntry."Bank Account No.", BankAccNo);
        CheckLedgerEntry.SetRange(CheckLedgerEntry."Check No.", ChequeNo);
        CheckLedgerEntry.FindFirst();
        Assert.AreEqual(CheckLedgerEntry."Entry Status"::"Financially Voided", CheckLedgerEntry."Entry Status", NotVerifiedErr);
        Assert.AreEqual(ChequeNo, CheckLedgerEntry."Check No.", NotVerifiedErr);
        Assert.AreEqual(WorkDate(), CheckLedgerEntry."Check Date", NotVerifiedErr);
        Assert.AreEqual(true, CheckLedgerEntry."Stale Cheque", NotVerifiedErr);
        Assert.AreEqual(CalcDate('<3M+1D>', WorkDate()), CheckLedgerEntry."Cheque Stale Date", NotVerifiedErr);
        Assert.RecordIsNotEmpty(CheckLedgerEntry);
    end;

    local procedure CreateGenJnlLineWithVoucherType(
        var GenJournalLine: Record "Gen. Journal Line";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        VoucherType: Enum "Gen. Journal Template Type";
        BankPaymentType: Enum "Bank Payment Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, VoucherType);
        Storage.Set(TemplateNameLbl, GenJournalTemplate.Name);
        LibraryJournals.CreateGenJournalLine(
            GenJournalLine,
            GenJournalTemplate.Name,
            GenJournalBatch.Name,
            GenJournalDocumentType,
            GenJournalLine."Account Type"::Vendor, LibraryPurchase.CreateVendorNo(),
            GenJournalLine."Bal. Account Type"::"Bank Account",
            (Storage.Get(AccountNoLbl)),
            LibraryRandom.RandDecInRange(10000, 20000, 2));
        GenJournalLine.Validate("Bank Payment Type", BankPaymentType);
        GenJournalLine.Modify(true);
    end;

    local procedure CreateGenJournalTemplateBatch(
        var GenJournalTemplate: Record "Gen. Journal Template";
        var GenJournalBatch: Record "Gen. Journal Batch"; VoucherType:
        Enum "Gen. Journal Template Type")
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, VoucherType);
        GenJournalTemplate.Modify(true);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    local procedure CreateVoucherSetup(Type: Enum "Gen. Journal Template Type"): Code[20]
    var
        BankAccount: Record "Bank Account";
        GLAccount: Record "G/L Account";
    begin
        case Type of
            Type::"Bank Payment Voucher", Type::"Bank Receipt Voucher":
                begin
                    LibraryERM.CreateBankAccount(BankAccount);
                    Storage.Set(AccountNoLbl, BankAccount."No.");
                    CreateVoucherAccountSetup(Type, '');
                    UpdateBankAccLastCheckWithStalePeriod(BankAccount);
                end;
            Type::"Contra Voucher", Type::"Cash Receipt Voucher":
                begin
                    LibraryERM.CreateGLAccount(GLAccount);
                    Storage.Set(AccountNoLbl, GLAccount."No.");
                    CreateVoucherAccountSetup(Type, '');
                end;
        end;
    end;

    local procedure UpdateBankAccLastCheckWithStalePeriod(var BankAccount: Record "Bank Account")
    var
        LastCheckNo: Code[20];
    begin
        Evaluate(StaleChequeStipulatedPeriod, '<3M>');
        Evaluate(LastCheckNo, Format(LibraryRandom.RandIntInRange(10000, 999999)));
        BankAccount."Last Check No." := LastCheckNo;
        BankAccount."Stale Cheque Stipulated Period" := StaleChequeStipulatedPeriod;
        BankAccount.Modify();
    end;

    local procedure SetWorkDate()
    begin
        StorageDate.Set(WorkDateLbl, WorkDate());
        WorkDate(CalcDate('<3M+1D>', StorageDate.Get(WorkDateLbl)));
    end;

    local procedure CreateVoucherAccountSetup(
        SubType: Enum "Gen. Journal Template Type";
        LocationCode: Code[10])
    var
        TaxBaseTestPublishers: Codeunit "Tax Base Test Publishers";
        TransactionDirection: Option " ",Debit,Credit,Both;
        AccountNo: Code[20];
    begin
        AccountNo := CopyStr(Storage.Get(AccountNoLbl), 1, MaxStrLen(AccountNo));
        case SubType of
            SubType::"Bank Payment Voucher", SubType::"Cash Payment Voucher", SubType::"Contra Voucher":
                begin
                    TaxBaseTestPublishers.InsertJournalVoucherPostingSetupWithLocationCode(SubType, LocationCode, TransactionDirection::Credit);
                    GetVoucherCreditAccountNoWithLocationCode(SubType, LocationCode, AccountNo);
                    Storage.Set(AccountNoLbl, AccountNo);
                end;
            SubType::"Cash Receipt Voucher", SubType::"Bank Receipt Voucher", SubType::"Journal Voucher":
                begin
                    TaxBaseTestPublishers.InsertJournalVoucherPostingSetupWithLocationCode(SubType, LocationCode, TransactionDirection::Debit);
                    TaxBaseTestPublishers.InsertVoucherDebitAccountNoWithLocationCode(SubType, LocationCode, AccountNo);
                    Storage.Set(AccountNoLbl, AccountNo);
                end;
        end;
    end;

    local procedure GetVoucherCreditAccountNoWithLocationCode(
        VoucherType: Enum "Gen. Journal Template Type";
        LocationCode: Code[20];
        var AccountNo: Code[20])
    var
        VoucherPostingCreditAccount: Record "Voucher Posting Credit Account";
    begin
        VoucherPostingCreditAccount.SetRange(Type, VoucherType);
        VoucherPostingCreditAccount.SetRange("Location code", LocationCode);
        VoucherPostingCreditAccount.SetRange("Account No.", AccountNo);
        if VoucherPostingCreditAccount.FindFirst() then
            exit
        else begin
            VoucherPostingCreditAccount.Init();
            VoucherPostingCreditAccount.Validate(Type, VoucherType);
            VoucherPostingCreditAccount.Validate("Location code", LocationCode);
            case VoucherType of
                VoucherType::"Bank Payment Voucher":
                    begin
                        if AccountNo = '' then
                            AccountNo := LibraryERM.CreateBankAccountNo();
                        VoucherPostingCreditAccount.Validate("Account Type", VoucherPostingCreditAccount."Account Type"::"Bank Account");
                        VoucherPostingCreditAccount.Validate("Account No.", AccountNo);
                    end;
                VoucherType::"Cash Payment Voucher":
                    begin
                        if AccountNo = '' then
                            AccountNo := LibraryERM.CreateGLAccountNo();
                        VoucherPostingCreditAccount.Validate("Account Type", VoucherPostingCreditAccount."Account Type"::"G/L Account");
                        VoucherPostingCreditAccount.Validate("Account No.", AccountNo);
                    end;
            end;
            VoucherPostingCreditAccount.Insert();
        end;
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ModalPageHandler]
    procedure ConfirmFinancialVoid(var ConfirmFinancialVoid: TestPage "Confirm Financial Void")
    begin
        ConfirmFinancialVoid.VoidType.SetValue(1);
        ConfirmFinancialVoid.Yes().Invoke();
    end;

    [ModalPageHandler]
    procedure ConfirmFinancialStale(var ConfirmFinancialStale: TestPage "Confirm Financial Stale")
    begin
        ConfirmFinancialStale.VoidType.SetValue(1);
        ConfirmFinancialStale.Yes().Invoke();
    end;

    [ModalPageHandler]
    procedure JournalTemplateHandler(var GeneralJournalTemplateList: TestPage "General Journal Template List")
    begin
        GeneralJournalTemplateList.Filter.SetFilter(Name, Storage.Get(TemplateNameLbl));
        GeneralJournalTemplateList.OK().Invoke();
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates");
    begin
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(Storage.Get(TDSSectionLbl));
        TaxRates.AttributeValue2.SetValue(Storage.Get(AssesseeCodeLbl));
        TaxRates.AttributeValue3.SetValue(CalcDate('<-5Y>', WorkDate()));
        TaxRates.AttributeValue4.SetValue('');
        TaxRates.AttributeValue5.SetValue('');
        TaxRates.AttributeValue6.SetValue('');
        TaxRates.AttributeValue7.SetValue('');
        TaxRates.AttributeValue8.SetValue(1);
        TaxRates.AttributeValue9.SetValue(0);
        TaxRates.AttributeValue10.SetValue(0);
        TaxRates.AttributeValue11.SetValue(0);
        TaxRates.AttributeValue12.SetValue(0);
        TaxRates.AttributeValue13.SetValue(0);
        TaxRates.AttributeValue14.SetValue(0);
        TaxRates.AttributeValue15.SetValue(0);
        TaxRates.OK().Invoke();
    end;
}