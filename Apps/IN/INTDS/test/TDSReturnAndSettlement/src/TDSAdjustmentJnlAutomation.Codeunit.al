codeunit 18797 "TDS Adjustment Jnl Automation"
{
    Subtype = Test;

    var
        LibraryTDS: Codeunit "Library-TDS";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        LibraryJournals: Codeunit "Library - Journals";
        LibraryRandom: Codeunit "Library - Random";
        Storage: Dictionary of [Text, Text];
        TDSNotPaidMsg: Label 'Not paid', Locked = true;
        EffectiveDateLbl: Label 'EffectiveDate', Locked = true;
        TDSPercentageLbl: Label 'TDSPercentage', Locked = true;
        NonPANTDSPercentageLbl: Label 'NonPANTDSPercentage', Locked = true;
        SurchargePercentageLbl: Label 'SurchargePercentage', Locked = true;
        ECessPercentageLbl: Label 'ECessPercentage', Locked = true;
        SHECessPercentageLbl: Label 'SHECessPercentage', Locked = true;
        TDSThresholdAmountLbl: Label 'TDSThresholdAmount', Locked = true;
        SectionCodeLbl: Label 'SectionCode', Locked = true;
        TDSAssesseeCodeLbl: Label 'TDSAssesseeCode', Locked = true;
        SurchargeThresholdAmountLbl: Label 'SurchargeThresholdAmount', Locked = true;
        TDSConcessionalCodeLbl: Label 'TDSConcessionalCode', Locked = true;
        SuccessMsg: Label 'Journal lines posted successfully.';
        ReverseMsg: Label 'The entries were successfully reversed.';
        AmountErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = TDS Amount and TDS field Caption';
        NotPostedErr: Label 'The journal lines were not posted.', Locked = true;
        AccountNoLbl: Label 'VendorNo', Locked = true;
        DocumentNoLbl: Label 'DocumentNo', Locked = true;

    // [SCENARIO] [354001] Check If system is allowing to reverse the TDS entry and G/L Entry if entries posted using journals.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmHandler,ReverseSuccessHandler')]
    procedure PostFromGenJournalandVerifyTDSEntryandGLEntryReversal()
    var
        GenJournalLine: Record "Gen. Journal Line";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithOutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted GenJournalLine TDS Invoice
        CreateGeneralJournalforTDSInvoice(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";

        // [THEN] G/L Entries Verified and Reversed
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, Round(-GenJournalLine.Amount, 1, '='), true, true, true);
        LibraryERM.ReverseTransaction(GetTransactionNo(DocumentNo));
    end;

    // [SCENARIO] [354003-Check if system is allowing to pay TDS amount to government which is already deducted using Payment Journal.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,PayTDS')]
    procedure PostPayTDSEntriesUsingPaymentJournalAlreadyDeducted()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        Vendor: Record Vendor;
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post TDS Invoice 
        CreateGeneralJournalforTDSInvoice(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/L Entries Verified and Created Payment Journal For Pay TDS
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, Round(-GenJournalLine.Amount, 1, '='), true, true, true);
        CreatePaymentJournalForPayTDS(GenJournalLine, TDSPostingSetup."TDS Account", LibraryTDS.GetTDSAmount(DocumentNo));
    end;

    // [SCENARIO] [354006] Check if system is marking TDS entries as paid which have been paid  to government using Payment Journal.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,PayTDS')]
    procedure PostPayTDSEntriesUsingPaymentJournalAlreadyPaid()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        Vendor: Record Vendor;
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post TDS Invoice 
        CreateGeneralJournalforTDSInvoice(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/L Entries Verified and Created Payment Journal For Pay TDS
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, Round(-GenJournalLine.Amount, 1, '='), true, true, true);
        CreatePaymentJournalForPayTDS(GenJournalLine, TDSPostingSetup."TDS Account", LibraryTDS.GetTDSAmount(DocumentNo));
        Assert.IsTrue(VerifyTDSPaid(DocumentNo), TDSNotPaidMsg);
    end;

    // [SCENARIO] [354010] Check if system is allowing to pay TDS amount to government which is already deducted using General Journal.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,PayTDS')]
    procedure PostPayTDSEntriesInGenJournalAlreadyDeducted()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        Vendor: Record Vendor;
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post TDS Invoice 
        CreateGeneralJournalforTDSInvoice(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/L Entries Verified and Created Payment Journal For Pay TDS
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, Round(-GenJournalLine.Amount, 1, '='), true, true, true);
        CreatePaymentJournalForPayTDS(GenJournalLine, TDSPostingSetup."TDS Account", LibraryTDS.GetTDSAmount(DocumentNo));
    end;

    // [SCENARIO] [353921] Check if system is allowing to do the adjustment increase for TDS Entries which has already deducted but paid to government authorities.
    [Test]
    [HandlerFunctions('TaxRatePageHandler,PayTDS')]
    procedure PostTDSAdjustmentForTDSEntriesAlreadyDeductedandPaid()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        Vendor: Record Vendor;
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
        PaidErr: Label 'TDS Paid must be equal to No before Adjustment';
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post TDS Invoice 
        CreateGeneralJournalforTDSInvoice(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/L Entries Verified and Created Payment Journal For Pay TDS
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, Round(-GenJournalLine.Amount, 1, '='), true, true, true);
        CreatePaymentJournalForPayTDS(GenJournalLine, TDSPostingSetup."TDS Account", LibraryTDS.GetTDSAmount(DocumentNo));
        Assert.IsTrue(GetPaidStatus(DocumentNo), PaidErr);
    end;

    // [SCENARIO] [355525] [Check if the system is allowing to pay TDS amount to government authorities through Cash Payment Voucher]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,PayTDS')]
    procedure PayTDSEntriesUsingBankPaymentVoucher()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        Vendor: Record Vendor;
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post TDS Invoice 
        CreateGeneralJournalforTDSInvoice(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/L Entries Verified and Created Bank Payment Voucher For Pay TDS
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, Round(-GenJournalLine.Amount, 1, '='), true, true, true);
        CreateAndPostTDSPayment(TDSPostingSetup."TDS Account", VoucherType::"Bank Payment Voucher");
    end;

    // [SCENARIO] [355452] [Check if the entries that are affecting only the Cash Accounts can be entered through the Cash Payment voucher.]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,PayTDS')]
    procedure PayTDSEntriesUsingCashPaymentVoucher()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        Vendor: Record Vendor;
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post TDS Invoice 
        CreateGeneralJournalforTDSInvoice(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/L Entries Verified and Created Bank Payment Voucher For Pay TDS
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, Round(-GenJournalLine.Amount, 1, '='), true, true, true);
        CreateAndPostTDSPayment(TDSPostingSetup."TDS Account", VoucherType::"Cash Payment Voucher");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmHandler,MsgHandler')]
    procedure PostTDSEntriesAndAdjustment()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        //[SCENARIO] [353998] [Check if system is allowing to do the adjustment increase for TDS Entries which has already deducted but not paid to government authorities.]
        //[GIVEN] Created Setup for TDS Section, Assessee Code, Vendor, TDS Setup and Concessional code

        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create & Post General Journal Line
        CreateGeneralJournalforTDSInvoice(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify GL Entry, create and post TDS Adjsutment journal
        VerifyGLEntryCount(DocumentNo, 3);
        CreateAndPostTDSAdjustment(DocumentNo, false, false, true, true, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmHandler,MsgHandler')]
    procedure PostTDSEntriesAndAdjustmentWithTDSSurchargeIsZero()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        //[SCENARIO] [Check if system is allowing to do the adjustment increase with TDS and Surcharge % is Zero for TDS Entries which has already deducted but not paid to government authorities.]
        //[GIVEN] Created Setup for TDS Section, Assessee Code, Vendor, TDS Setup and Concessional code

        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create & Post General Journal Line with
        CreateGeneralJournalforTDSInvoice(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify GL Entry, create and post TDS Adjsutment journal with TDS and Surcharge % is Zero
        VerifyGLEntryCount(DocumentNo, 3);
        CreateAndPostTDSAdjustment(DocumentNo, true, true, false, false, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,PaySelectedTDS')]
    procedure PaySelectedTDSEntriesUsingBankPaymentVoucher()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        Vendor: Record Vendor;
        GenJournalLine: array[10] of Record "Gen. Journal Line";
        NoOfEntries: Integer;
        I: Integer;
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [574373] [Check if the system is allowing to pay selected TDS amount to government authorities through Cash Payment Voucher]

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post TDS Invoice 
        NoOfEntries := 5;
        CreateMultipleGeneralJournalforTDSInvoice(GenJournalLine, Vendor, WorkDate(), NoOfEntries);
        for I := 1 to NoOfEntries do begin
            if I mod 3 = 0 then
                DocumentNo := GenJournalLine[I]."Document No.";
            LibraryERM.PostGeneralJnlLine(GenJournalLine[I]);
        end;

        Storage.Set(AccountNoLbl, TDSPostingSetup."TDS Account");
        Storage.Set(DocumentNoLbl, DocumentNo);

        // [WHEN] Create and Post TDS Payment
        CreateAndPostTDSPayment(TDSPostingSetup."TDS Account", VoucherType::"Bank Payment Voucher");

        // [THEN] Created Bank Payment Voucher For Pay TDS for selected entries
        VerifyTDSEntryCount(Vendor."No.", 1);
    end;

    local procedure CreateAndPostTDSAdjustment(DocuemntNo: Code[20]; TDSZero: Boolean; SurchargeZero: Boolean; eCessZero: Boolean; SheCessZero: Boolean; BaseApplied: Boolean)
    var
        TDSJournalBatch: Record "TDS Journal Batch";
        TDSJournalLine: Record "TDS Journal Line";
        TDSEntry: Record "TDS Entry";
        TDSAdjustmentPost: Codeunit "TDS Adjustment Post";
        TDSAdjustmentJournal: TestPage "TDS Adjustment Journal";
    begin
        TDSEntry.SetRange("Document No.", DocuemntNo);
        TDSEntry.FindFirst();

        TDSJournalBatch.FindFirst();
        TDSJournalBatch.Validate("No. Series", LibraryERM.CreateNoSeriesCode());
        TDSJournalBatch.Validate("Posting No. Series", LibraryERM.CreateNoSeriesCode());
        TDSJournalBatch.Modify(true);

        TDSAdjustmentJournal.OpenEdit();
        TDSAdjustmentJournal.New();
        TDSAdjustmentJournal."Transaction No".SetValue(TDSEntry."Entry No.");
        TDSAdjustmentJournal."Posting Date".SetValue(WorkDate());

        TDSJournalLine.SetRange("TDS Transaction No.", TDSEntry."Entry No.");
        TDSJournalLine.FindFirst();

        if BaseApplied then
            TDSJournalLine.Validate("TDS Base Amount Applied", 0);

        if TDSZero then
            TDSJournalLine.Validate("TDS % Applied", 0)
        else
            TDSJournalLine.Validate("TDS % Applied", LibraryRandom.RandDec(5, 1));

        if eCessZero then
            TDSJournalLine.Validate("eCESS % Applied", 0)
        else
            TDSJournalLine.Validate("eCESS % Applied", LibraryRandom.RandDec(5, 1));

        if SheCessZero then
            TDSJournalLine.Validate("SHE Cess % Applied", 0)
        else
            TDSJournalLine.Validate("SHE Cess % Applied", LibraryRandom.RandDec(5, 1));

        if SurchargeZero then
            TDSJournalLine.Validate("Surcharge % Applied", 0)
        else
            TDSJournalLine.Validate("Surcharge % Applied", LibraryRandom.RandDec(5, 1));

        TDSJournalLine.Modify(true);
        TDSAdjustmentPost.PostTaxJournal(TDSJournalLine);
    end;

    local procedure CreatePaymentJournalForPayTDS(
        var GenJournalLine: Record "Gen. Journal Line";
        TDSAccount: Code[20];
        TDSAmount: Decimal)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        CompanyInfo: Record "Company Information";
        Payment: Codeunit "TDS Pay";
        TDSSectionCode: Code[10];
    begin
        CompanyInfo.Get();
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryJournals.CreateGenJournalLine(GenJournalLine,
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::"G/L Account",
            TDSAccount,
            GenJournalLine."Bal. Account Type"::"Bank Account",
            LibraryERM.CreateBankAccountNo(), TDSAmount);
        GenJournalLine.Validate("Posting Date", WorkDate());
        TDSSectionCode := CopyStr(Storage.Get(SectionCodeLbl), 1, 10);
        GenJournalLine.Validate("TDS Section Code", TDSSectionCode);
        GenJournalLine.Validate("T.A.N. No.", CompanyInfo."T.A.N. No.");
        GenJournalLine.Modify(true);
        Payment.PayTDS(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    procedure VerifyTDSPaid(DocumentNo: Code[20]): Boolean
    var
        TDSEntry: Record "TDS Entry";
    begin
        TDSEntry.SetRange("Document No.", DocumentNo);
        TDSEntry.SetRange("TDS Paid", true);
        if not TDSEntry.IsEmpty() then
            exit(true);
    end;

    procedure GetPaidStatus(DocumentNo: Code[20]): Boolean
    var
        TDSEntry: Record "TDS Entry";
    begin
        TDSEntry.SetRange("Document No.", DocumentNo);
        TDSEntry.SetRange("TDS Paid", true);
        if not TDSEntry.IsEmpty then
            exit(true)
        else
            exit(false);
    end;

    local procedure CreateAndPostTDSPayment(
        TDSAccount: Code[20];
        VoucherType: Enum "Gen. Journal Template Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        CompanyInformation: Record "Company Information";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        TDSPay: Codeunit "TDS Pay";
        BalAccountType: Enum "Gen. Journal Account Type";
        BalAccountNo: Code[20];
        TDSSectionCode: Code[10];
    begin
        CompanyInformation.Get();
        if VoucherType in [VoucherType::"Bank Payment Voucher", VoucherType::"Bank Receipt Voucher"] then begin
            BalAccountType := BalAccountType::"Bank Account";
            BalAccountNo := CreateGenJournalTemplateAndDefineVoucherAccount(GenJournalTemplate, VoucherType);
        end else
            if VoucherType in [VoucherType::"Cash Payment Voucher", VoucherType::"Bank Receipt Voucher"] then begin
                BalAccountType := BalAccountType::"G/L Account";
                BalAccountNo := CreateGenJournalTemplateAndDefineVoucherAccount(GenJournalTemplate, VoucherType);
            end
            else begin
                BalAccountType := BalAccountType::"G/L Account";
                BalAccountNo := LibraryERM.CreateGLAccountNo();
                LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
            end;
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
        GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::"G/L Account", TDSAccount,
        BalAccountType, BalAccountNo, 0);
        GenJournalLine.Validate("Posting Date", WorkDate());
        TDSSectionCode := CopyStr(Storage.Get(SectionCodeLbl), 1, 10);
        GenJournalLine.Validate("TDS Section Code", TDSSectionCode);
        GenJournalLine.Validate("T.A.N. No.", CompanyInformation."T.A.N. No.");
        GenJournalLine.Modify(true);
        TDSPay.PayTDS(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateGenJournalTemplateAndDefineVoucherAccount(
        var GenJournalTemplate: Record "Gen. Journal Template";
        VoucherType: Enum "Gen. Journal Template Type"): Code[20]
    var
        TaxBasePublishers: Codeunit "Tax Base Test Publishers";
        TransactionDirection: Option " ",Debit,Credit,Both;
        AccountNo: Code[20];
    begin
        AccountNo := '';
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, VoucherType);
        GenJournalTemplate.Modify(true);

        TaxBasePublishers.InsertJournalVoucherPostingSetup(VoucherType, TransactionDirection::Credit);
        TaxBasePublishers.InsertVoucherCreditAccountNo(VoucherType, AccountNo);
        exit(AccountNo);
    end;

    local procedure CreateGeneralJournalforTDSInvoice(
        var GenJournalLine: Record "Gen. Journal Line";
        var Vendor: Record Vendor;
        PostingDate: Date)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        Amount: Decimal;
        TDSSectionCode: Code[10];
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        Amount := LibraryRandom.RandDecInRange(1000, 10000, 0);
        LibraryJournals.CreateGenJournalLine(GenJournalLine,
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::Vendor,
            Vendor."No.",
            GenJournalLine."Bal. Account Type"::"G/L Account",
            LibraryERM.CreateGLAccountNoWithDirectPosting(),
            -Amount);
        GenJournalLine.Validate("Posting Date", PostingDate);
        TDSSectionCode := CopyStr(Storage.Get(SectionCodeLbl), 1, 10);
        GenJournalLine.Validate("TDS Section Code", TDSSectionCode);
        GenJournalLine.Validate(Amount, -Amount);
        GenJournalLine.Modify(true);
    end;

    local procedure GetTransactionNo(DocumentNo: Code[20]): Integer
    var
        TDSEntry: Record "TDS Entry";
    begin
        TDSEntry.SetRange("Document No.", DocumentNo);
        if TDSEntry.FindFirst() then
            exit(TDSEntry."Transaction No.")
        else
            exit(0);
    end;

    local procedure VerifyTDSEntry(
        DocumentNo: Code[20];
        TDSBaseAmount: Decimal;
        WithPAN: Boolean;
        SurchargeOverlook: Boolean;
        TDSThresholdOverlook: Boolean)
    var
        TDSEntry: Record "TDS Entry";
        ExpectdTDSAmount: Decimal;
        ExpectedSurchargeAmount: Decimal;
        ExpectedEcessAmount: Decimal;
        ExpectedSHEcessAmount: Decimal;
        TDSPercentage: Decimal;
        NonPANTDSPercentage: Decimal;
        SurchargePercentage: Decimal;
        eCessPercentage: Decimal;
        SHECessPercentage: Decimal;
        TDSThresholdAmount: Decimal;
        SurchargeThresholdAmount: Decimal;
    begin
        Evaluate(TDSPercentage, Storage.Get(TDSPercentageLbl));
        Evaluate(NonPANTDSPercentage, Storage.Get(NonPANTDSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(ECessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(TDSThresholdAmount, Storage.Get(TDSThresholdAmountLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));

        if (TDSBaseAmount < TDSThresholdAmount) and (TDSThresholdOverlook = false) then
            ExpectdTDSAmount := 0
        else
            if WithPAN then
                ExpectdTDSAmount := TDSBaseAmount * TDSPercentage / 100
            else
                ExpectdTDSAmount := TDSBaseAmount * NonPANTDSPercentage / 100;

        if (TDSBaseAmount < SurchargeThresholdAmount) and (SurchargeOverlook = false) then
            ExpectedSurchargeAmount := 0
        else
            ExpectedSurchargeAmount := ExpectdTDSAmount * SurchargePercentage / 100;
        ExpectedEcessAmount := (ExpectdTDSAmount + ExpectedSurchargeAmount) * eCessPercentage / 100;
        ExpectedSHEcessAmount := (ExpectdTDSAmount + ExpectedSurchargeAmount) * SHECessPercentage / 100;
        TDSEntry.SetRange("Document No.", DocumentNo);
        TDSEntry.FindFirst();
        Assert.AreNearlyEqual(
            TDSBaseAmount, TDSEntry."TDS Base Amount", LibraryTDS.GetTDSRoundingPrecision(),
            StrSubstNo(AmountErr, TDSEntry.FieldName("TDS Base Amount"), TDSEntry.TableCaption()));
        if WithPAN then
            Assert.AreEqual(
                TDSPercentage, TDSEntry."TDS %",
                StrSubstNo(AmountErr, TDSEntry.FieldName("TDS %"), TDSEntry.TableCaption()))
        else
            Assert.AreEqual(
                NonPANTDSPercentage, TDSEntry."TDS %",
                StrSubstNo(AmountErr, TDSEntry.FieldName("TDS %"), TDSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectdTDSAmount, TDSEntry."TdS Amount", LibraryTdS.GetTDSRoundingPrecision(),
            StrSubstNo(AmountErr, TDSEntry.FieldName("TDS Amount"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            SurchargePercentage, TDSEntry."Surcharge %",
            StrSubstNo(AmountErr, TDSEntry.FieldName("Surcharge %"), TDSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectedSurchargeAmount, TDSEntry."Surcharge Amount", LibraryTDS.GetTDSRoundingPrecision(),
            StrSubstNo(AmountErr, TDSEntry.FieldName("Surcharge Amount"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            eCessPercentage, TDSEntry."eCESS %",
            StrSubstNo(AmountErr, TDSEntry.FieldName("eCESS %"), TDSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectedEcessAmount, TDSEntry."eCESS Amount", LibraryTDS.GetTDSRoundingPrecision(),
            StrSubstNo(AmountErr, TDSEntry.FieldName("eCESS Amount"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            SHECessPercentage, TDSEntry."SHE Cess %",
            StrSubstNo(AmountErr, TDSEntry.FieldName("SHE Cess %"), TDSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectedSHEcessAmount, TDSEntry."SHE Cess Amount", LibraryTDS.GetTDSRoundingPrecision(),
            StrSubstNo(AmountErr, TDSEntry.FieldName("SHE Cess Amount"), TDSEntry.TableCaption()));
    end;

    local procedure CreateTaxRateSetup(
        TDSSection: Code[10];
        AssesseeCode: Code[10];
        ConcessionlCode: Code[10];
        EffectiveDate: Date)
    begin
        Storage.Set(SectionCodeLbl, TDSSection);
        Storage.Set(TDSAssesseeCodeLbl, AssesseeCode);
        Storage.Set(TDSConcessionalCodeLbl, ConcessionlCode);
        Storage.Set(EffectiveDateLbl, Format(EffectiveDate, 0, 9));
        GenerateTaxComponentsPercentage();
        CreateTaxRate();
    end;

    local procedure GenerateTaxComponentsPercentage()
    begin
        Storage.Set(TDSPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(NonPANTDSPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(SurchargePercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(ECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(SHECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(TDSThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(SurchargeThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
    end;

    local procedure VerifyGLEntryCount(DocumentNo: Code[20]; ExpectedCount: Integer)
    var
        DummyGLEntry: Record "G/L Entry";
    begin
        DummyGLEntry.SetRange("Document No.", DocumentNo);
        Assert.RecordCount(DummyGLEntry, ExpectedCount);
    end;

    local procedure CreateTaxRate()
    var
        TDSSetup: Record "TDS Setup";
        PageTaxtype: TestPage "Tax Types";
    begin
        if not TDSSetup.Get() then
            exit;

        PageTaxtype.OpenEdit();
        PageTaxtype.Filter.SetFilter(Code, TDSSetup."Tax Type");
        PageTaxtype.TaxRates.Invoke();
    end;

    local procedure CreateMultipleGeneralJournalforTDSInvoice(
    var GenJournalLine: array[10] of Record "Gen. Journal Line";
    var Vendor: Record Vendor;
    PostingDate: Date;
    NoOfEntries: Integer)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        Amount: Decimal;
        I: Integer;
        TDSSectionCode: Code[10];
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        Amount := LibraryRandom.RandDecInRange(1000, 10000, 0);
        for I := 1 to NoOfEntries do begin
            LibraryJournals.CreateGenJournalLine(GenJournalLine[I],
                GenJournalBatch."Journal Template Name",
                GenJournalBatch.Name,
                GenJournalLine[I]."Document Type"::Invoice,
                GenJournalLine[I]."Account Type"::Vendor,
                Vendor."No.",
                GenJournalLine[I]."Bal. Account Type"::"G/L Account",
                LibraryERM.CreateGLAccountNoWithDirectPosting(),
                -Amount);
            GenJournalLine[I].Validate("Posting Date", PostingDate);
            TDSSectionCode := CopyStr(Storage.Get(SectionCodeLbl), 1, 10);
            GenJournalLine[I].Validate("TDS Section Code", TDSSectionCode);
            GenJournalLine[I].Validate(Amount, -Amount);
            GenJournalLine[I].Modify(true);
        end;
    end;

    local procedure VerifyTDSEntryCount(VendorNo: Code[20]; ExpectedCount: Integer)
    var
        DummyTDSEntry: Record "TDS Entry";
    begin
        DummyTDSEntry.SetRange("Vendor No.", VendorNo);
        DummyTDSEntry.SetRange("TDS Paid", true);
        Assert.RecordCount(DummyTDSEntry, ExpectedCount);
    end;

    [MessageHandler]
    procedure MsgHandler(MsgText: Text)
    begin
        if MsgText <> SuccessMsg then
            Error(NotPostedErr);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure SuccessHandler(SuccessMessage: Text[1024])
    begin
        if SuccessMessage <> SuccessMsg then
            Error(NotPostedErr);
    end;

    [MessageHandler]
    procedure ReverseSuccessHandler(ReverseMessage: Text[1024])
    begin
        if ReverseMsg <> ReverseMessage then
            Error(NotPostedErr);
    end;

    [PageHandler]
    procedure PayTDS(var PayTDSPage: TestPage "Pay TDS")
    begin
        PayTDSPage."&Pay".Invoke();
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRate: TestPage "Tax Rates")
    var
        EffectiveDate: Date;
        TDSPercentage: Decimal;
        NonPANTDSPercentage: Decimal;
        SurchargePercentage: Decimal;
        eCessPercentage: Decimal;
        SHECessPercentage: Decimal;
        TDSThresholdAmount: Decimal;
        SurchargeThresholdAmount: Decimal;
    begin
        Evaluate(EffectiveDate, Storage.Get(EffectiveDateLbl), 9);
        Evaluate(TDSPercentage, Storage.Get(TDSPercentageLbl));
        Evaluate(NonPANTDSPercentage, Storage.Get(NonPANTDSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(ECessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(TDSThresholdAmount, Storage.Get(TDSThresholdAmountLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));

        TaxRate.New();
        TaxRate.AttributeValue1.SetValue(Storage.Get(SectionCodeLbl));
        TaxRate.AttributeValue2.SetValue(Storage.Get(TDSAssesseeCodeLbl));
        TaxRate.AttributeValue3.SetValue(EffectiveDate);
        TaxRate.AttributeValue4.SetValue(Storage.Get(TDSConcessionalCodeLbl));
        TaxRate.AttributeValue5.SetValue('');
        TaxRate.AttributeValue6.SetValue('');
        TaxRate.AttributeValue7.SetValue('');
        TaxRate.AttributeValue8.SetValue(TDSPercentage);
        TaxRate.AttributeValue9.SetValue(NonPANTDSPercentage);
        TaxRate.AttributeValue10.SetValue(SurchargePercentage);
        TaxRate.AttributeValue11.SetValue(eCessPercentage);
        TaxRate.AttributeValue12.SetValue(SHECessPercentage);
        TaxRate.AttributeValue13.SetValue(TDSThresholdAmount);
        TaxRate.AttributeValue14.SetValue(SurchargeThresholdAmount);
        TaxRate.AttributeValue15.SetValue(0.00);
        TaxRate.OK().Invoke();
    end;

    [PageHandler]
    procedure PaySelectedTDS(var PayTDSPage: TestPage "Pay TDS")
    var
        DocumentNo: Text;
        AccountNo: Code[20];
    begin
        DocumentNo := Storage.Get(DocumentNoLbl);
        AccountNo := Storage.Get(AccountNoLbl);
        PayTDSPage.Filter.SetFilter("Document No.", DocumentNo);
        PayTDSPage.Filter.SetFilter("Account No.", AccountNo);
        PayTDSPage."&Pay".Invoke();
    end;
}