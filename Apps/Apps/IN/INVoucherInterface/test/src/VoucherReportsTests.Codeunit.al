codeunit 18998 "Voucher Reports Tests"
{
    Subtype = Test;

    [Test]
    procedure VerifyFieldValuesOnDayBookReport()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        Location: Record Location;
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [Verify Fields on Day Book Report]
        // [GIVEN] Created Bank Account and Voucher Setup Using Company Information
        CreateBankAccountWithVoucherAcc(BankAccount,
            VoucherType::"Bank Receipt Voucher",
            GenJournalLine."Account Type"::"Bank Account",
            Location.Code);
        CreatePaymentVoucherTemplate(GenJournalBatch, VoucherType::"Bank Receipt Voucher", Location.Code);

        // [WHEN] Create and Post MultiLine Bank Receipt Voucher                                                 
        CreateMultiLinesinVoucherForCustomer(
            GenJournalLine,
            GenJournalBatch.Name,
            BankAccount."No.",
            GenJournalLine."Account Type"::"Bank Account");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Amount Fields Verified on Day Book Report
        VerifyAmountFieldsOnDayBookReport(GenJournalBatch.Name);
    end;

    [Test]
    procedure VerifyFieldValuesOnVoucherRegisterReport()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        Location: Record Location;
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [Verify Fields on Voucher Register Report]
        // [GIVEN] Create Location,Bank Account with Voucher Setup
        LibraryWarehouse.CreateLocationWMS(Location, false, false, false, false, false);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Payment Voucher",
            GenJournalLine."Account Type"::"Bank Account",
            Location.Code);
        CreatePaymentVoucherTemplate(GenJournalBatch, VoucherType::"Bank Payment Voucher", Location.Code);

        // [WHEN] Craet and Post MultiLne Bank Payment voucher 
        CreateMultiLinesinVoucherForVendor(
            GenJournalLine,
            GenJournalBatch.Name,
            BankAccount."No.",
            GenJournalLine."Account Type"::"Bank Account");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Amount Fields Verified on Voucher Register Report
        VerifyAmountFieldsOnVoucherRegisterReport(GenJournalBatch.Name);
    end;

    [Test]
    [HandlerFunctions('ReverseTransactionConfirmHandler,PostedReversalEntryMessageHandler')]
    procedure VerifyFieldValuesOnBankBookReport()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        Location: Record Location;
        BankAccount: Record "Bank Account";
        Vendor: Record Vendor;
        VoucherType: Enum "Gen. Journal Template Type";
        TransactionNo: Integer;
    begin
        // [SCENARIO] [Verify Fields on Bank Book Report]
        // [GIVEN] Create Vendor,Location,Bank Account with Voucher Setup
        LibraryPurchase.CreateVendor(Vendor);
        LibraryWarehouse.CreateLocationWMS(Location, false, false, false, false, false);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Payment Voucher",
            GenJournalLine."Account Type"::"Bank Account",
            Location.Code);
        CreatePaymentVoucherTemplate(GenJournalBatch, VoucherType::"Bank Payment Voucher", Location.Code);

        // [WHEN] Craet and Post Bank Payment voucher
        CreateandPostGenJnlLine(GenJournalLine, GenJournalBatch, GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Vendor, Vendor."No.", GenJournalLine."Bal. Account Type"::"Bank Account", BankAccount."No.", LibraryRandom.RandDecInDecimalRange(10000, 6000, 2));
        CreateandPostGenJnlLine(GenJournalLine, GenJournalBatch, GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Vendor, Vendor."No.", GenJournalLine."Bal. Account Type"::"Bank Account", BankAccount."No.", LibraryRandom.RandDecInDecimalRange(10000, 6000, 2));

        TransactionNo := GetTransactionNo(GenJournalBatch.Name);
        // [WHEN] Reverse Transaction
        LibraryERM.ReverseTransaction(TransactionNo);

        // [THEN] Amount Fields Verified on Voucher Register Report
        VerifyAmountFieldsOnBankBookReport(BankAccount."No.");
    end;

    local procedure VerifyAmountFieldsOnDayBookReport(JnlBatchName: Code[10])
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Journal Batch Name", JnlBatchName);
        GLEntry.SetRange("Posting Date");
        GLEntry.FindFirst();
        LibraryReportDataSet.RunReportAndLoad(Report::"Day Book", GLEntry, '');
        LibraryReportDataset.AssertElementWithValueExists(GLEntryDocumentNoLbl, GLEntry."Document No.");
        LibraryReportDataset.AssertElementWithValueExists(GLEntryDebitAmountLbl, GLEntry."Debit Amount");
        LibraryReportDataset.AssertElementWithValueExists(GLEntryCreditAmountLbl, GLEntry."Credit Amount");
        LibraryReportDataset.AssertElementWithValueExists(SourceDescLbl, GetSourceDescription(JnlBatchName));
    end;

    local procedure VerifyAmountFieldsOnVoucherRegisterReport(JnlBatchName: Code[10])
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Journal Batch Name", JnlBatchName);
        GLEntry.FindFirst();
        LibraryReportDataSet.RunReportAndLoad(Report::"Voucher Register", GLEntry, '');
        LibraryReportDataset.AssertElementWithValueExists(VoucherRegGLEntryDebitAmtLbl, GLEntry."Debit Amount");
        LibraryReportDataset.AssertElementWithValueExists(VoucherRegGLEntryCreditAmtLbl, GLEntry."Credit Amount");
        LibraryReportDataset.AssertElementWithValueExists(SourceDescLbl, GetSourceDescription(JnlBatchName));
    end;

    local procedure GetSourceDescription(JnlBatchName: Code[10]): Text
    var
        SourceCode: Record "Source Code";
        GLEntry: Record "G/L Entry";
        SourceDesc: Text[100];
    begin
        GLEntry.SetRange("Journal Batch Name", JnlBatchName);
        GLEntry.FindFirst();
        if GLEntry."Source Code" <> '' then begin
            SourceCode.Get(GLEntry."Source Code");
            SourceDesc := SourceCode.Description;
        end;
        exit(SourceDesc);
    end;

    local procedure CreateMultiLinesinVoucherForVendor(VAR GenJournalLine: Record "Gen. Journal Line";
        GenJnlBatchName: Code[10];
        AccountNo: Code[20];
        AccountType: Enum "Gen. Journal Account Type")
    begin
        CreateGenJnlLine(
            GenJournalLine, GenJnlBatchName, AccountType, AccountNo, -LibraryRandom.RandDecInDecimalRange(10000, 6000, 2),
            CalcDate('<-CM>', WorkDate()));
        CreateGenJnlLine(
            GenJournalLine, GenJnlBatchName, GenJournalLine."Account Type"::Vendor, LibraryPurchase.CreateVendorNo(),
            LibraryRandom.RandDecInDecimalRange(10000, 6000, 2), CalcDate('<-CM>', WorkDate()));
    end;

    local procedure CreatePaymentVoucherTemplate(
        var GenJournalBatch: Record "Gen. Journal Batch";
        Type: Enum "Gen. Journal Template Type";
        LocationCode: Code[10])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, Type);
        GenJournalTemplate.Modify();
        Storage.Set(TemplateNameLbl, GenJournalTemplate.Name);

        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Location Code", LocationCode);
        GenJournalBatch.Modify();
    end;

    local procedure CreateBankAccountWithVoucherAcc(
        var BankAccount: Record "Bank Account";
        Type: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
        LocationCode: Code[10])
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        CreateVoucherAccount(BankAccount."No.", AccountType, Type, Format(Type), LocationCode);
    end;

    local procedure CreateVoucherAccount(AccountNo: Code[20];
        AccType: Enum "Gen. Journal Account Type";
        SubType: Enum "Gen. Journal Template Type";
        TaxtType: Text;
        LocationCode: Code[10])
    var
        VoucherPostingCreditAccount: Record "Voucher Posting Credit Account";
        VoucherPostingDebitAccount: Record "Voucher Posting Debit Account";
        CompanyInformationPage: TestPage "Company Information";
        LocationCard: TestPage "Location Card";
        JournalVoucherPostingSetup: TestPage "Journal Voucher Posting Setup";
    begin
        case SubType of
            SubType::"Bank Payment Voucher", SubType::"Cash Payment Voucher":
                begin
                    VoucherPostingCreditAccount.Init();
                    VoucherPostingCreditAccount.Validate("Location code", LocationCode);
                    VoucherPostingCreditAccount.Validate(Type, SubType);
                    VoucherPostingCreditAccount.Validate("Account Type", AccType);
                    VoucherPostingCreditAccount.Validate("Account No.", AccountNo);
                    VoucherPostingCreditAccount.Insert();
                end;
            SubType::"Bank Receipt Voucher", SubType::"Cash Receipt Voucher":
                begin
                    VoucherPostingDebitAccount.Init();
                    VoucherPostingDebitAccount.Validate("Location code", LocationCode);
                    VoucherPostingDebitAccount.Validate(Type, SubType);
                    VoucherPostingDebitAccount.Validate("Account Type", AccType);
                    VoucherPostingDebitAccount.Validate("Account No.", AccountNo);
                    VoucherPostingDebitAccount.Insert();
                end;
            else begin
                VoucherPostingDebitAccount.Init();
                VoucherPostingDebitAccount.Validate("Location code", LocationCode);
                VoucherPostingDebitAccount.Validate(Type, SubType);
                VoucherPostingDebitAccount.Validate("Account Type", AccType);
                VoucherPostingDebitAccount.Validate("Account No.", AccountNo);
                VoucherPostingDebitAccount.Insert();
            end;
        end;
        CreateNoSeries();
        if StorageBoolean.ContainsKey(LocationSetupLbl) then begin
            LocationCard.OpenEdit();
            LocationCard.GoToKey(LocationCode);
            JournalVoucherPostingSetup.Trap();
            LocationCard."Voucher Setup".Invoke();
            JournalVoucherPostingSetup.Filter.SetFilter(Type, TaxtType);
            JournalVoucherPostingSetup.Filter.SetFilter("Location Code", LocationCode);
            JournalVoucherPostingSetup."Posting No. Series".SetValue(Storage.Get(NoseriesLbl));
        end else begin
            CompanyInformationPage.OpenEdit();
            JournalVoucherPostingSetup.Trap();
            CompanyInformationPage."Journal Voucher Posting Setup".Invoke();
            JournalVoucherPostingSetup.Filter.SetFilter(Type, TaxtType);
            JournalVoucherPostingSetup.Filter.SetFilter("Location Code", LocationCode);
            JournalVoucherPostingSetup."Posting No. Series".SetValue(Storage.Get(NoseriesLbl));
        end;
        case SubType of
            SubType::"Bank Payment Voucher", SubType::"Cash Payment Voucher":
                JournalVoucherPostingSetup."Credit Account".Invoke();
            SubType::"Cash Receipt Voucher", SubType::"Bank Receipt Voucher":
                JournalVoucherPostingSetup."Debit Account".Invoke();
        end;
    end;

    local procedure CreateNoSeries(): Code[20]
    var
        Noseries: Code[20];
    begin
        if not Storage.ContainsKey(NoseriesLbl) then begin
            Noseries := LibraryERM.CreateNoSeriesCode();
            Storage.Set(NoseriesLbl, Noseries);
            exit(Noseries);
        end;
    end;

    local procedure CreateMultiLinesinVoucherForCustomer(
        var GenJournalLine: Record "Gen. Journal Line";
        GenJnlBatchName: Code[10];
        AccountNo: Code[20];
        AccountType: Enum "Gen. Journal Account Type")
    begin
        CreateGenJnlLine(
            GenJournalLine, GenJnlBatchName, AccountType, AccountNo, LibraryRandom.RandDecInDecimalRange(10000, 6000, 2),
            CalcDate('<-CM>', WorkDate()));
        CreateGenJnlLine(
            GenJournalLine, GenJnlBatchName, GenJournalLine."Account Type"::Customer, LibrarySales.CreateCustomerNo(),
            -LibraryRandom.RandDecInDecimalRange(10000, 6000, 2), CalcDate('<-CM>', WorkDate()));
    end;

    local procedure CreateGenJnlLine(var GenJournalLine: Record "Gen. Journal Line";
        GenJnlBatchName: Code[10];
        AccountType: Enum "Gen. Journal Account Type";
        AccountNo: Code[20];
        Amount: Decimal;
        PostingDate: Date): Code[20]
    var
        TemplateName: Code[10];
    begin
        TemplateName := CopyStr(Storage.Get(TemplateNameLbl), 1, 10);
        LibraryERM.CreateGeneralJnlLine2(
            GenJournalLine,
            TemplateName,
            GenJnlBatchName, GenJournalLine."Document Type"::Payment,
            AccountType,
            AccountNo, Amount);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Modify();
        exit(GenJournalLine."Document No.");
    end;

    local procedure CreateandPostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch"; DocType: Enum "Gen. Journal Document Type"; AccType: Enum "Gen. Journal Account Type"; AccNo: Code[20]; BalAccType: Enum "Gen. Journal Account Type"; BalAccNo: Code[20]; Amount: Decimal): Code[20]
    var
        DocNo: Code[20];
    begin
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, DocType, AccType,
        AccNo, BalAccType, BalAccNo, Amount);
        DocNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        exit(DocNo);
    end;

    local procedure GetTransactionNo(JnlBatchName: Code[10]): Integer
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        BankAccountLedgerEntry.SetRange("Journal Batch Name", JnlBatchName);
        if BankAccountLedgerEntry.FindFirst() then
            exit(BankAccountLedgerEntry."Transaction No.");
    end;

    local procedure VerifyAmountFieldsOnBankBookReport(BankAccountNo: Code[20])
    var
        BankAccount: Record "Bank Account";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        TransDebitAmount: Decimal;
        TransCreditAmount: Decimal;
    begin
        BankAccount.SetRange("No.", BankAccountNo);
        BankAccount.SetFilter("Date Filter", '%1', WorkDate());
        BankAccount.FindFirst();

        BankAccountLedgerEntry.SetRange("Bank Account No.", BankAccount."No.");
        BankAccountLedgerEntry.SetRange("Posting Date", WorkDate());
        BankAccountLedgerEntry.CalcSums("Debit Amount", "Credit Amount");
        TransDebitAmount := BankAccountLedgerEntry."Debit Amount";
        TransCreditAmount := BankAccountLedgerEntry."Credit Amount";

        LibraryReportDataSet.RunReportAndLoad(Report::"Bank Book", BankAccount, '');
        LibraryReportDataset.AssertElementWithValueExists('TransDebits', TransDebitAmount);
        LibraryReportDataset.AssertElementWithValueExists('TransCredits', TransCreditAmount);
    end;

    [ConfirmHandler]
    procedure ReverseTransactionConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := Question = ReverseTransactionQst;
    end;

    [MessageHandler]
    procedure PostedReversalEntryMessageHandler(Message: Text)
    begin
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryReportDataSet: Codeunit "Library - Report Dataset";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        Storage: Dictionary of [Text, Code[20]];
        StorageBoolean: Dictionary of [Text, Boolean];
        TemplateNameLbl: Label 'TemplateName';
        LocationSetupLbl: Label 'LocationSetup';
        NoseriesLbl: Label 'Noseries';
        SourceDescLbl: Label 'SourceDesc';
        GLEntryDocumentNoLbl: Label 'DocNo';
        GLEntryDebitAmountLbl: Label 'DebitAmount_GLEntry';
        GLEntryCreditAmountLbl: Label 'CreditAmount_GLEntry';
        VoucherRegGLEntryDebitAmtLbl: Label 'DebitAmount_GLEntry';
        VoucherRegGLEntryCreditAmtLbl: Label 'CreditAmount_GLEntry';
        ReverseTransactionQst: Label 'To reverse these entries, correcting entries will be posted.\Do you want to reverse the entries?';
}