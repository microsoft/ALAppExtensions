codeunit 18921 "TCS Pay Adjustment"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmHandler,MsgHandler')]
    procedure PostAndReverseTCSEntries()
    var
        ConcessionalCode: Record "Concessional Code";
        TCSPostingSetup: Record "TCS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        DocumentNo: Code[20];
    begin
        //[Senerio [355284] [Check If system is allowing to reverse the TCS entry and G/L Entry if entries posted using journals]
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Concessional code
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create & Post General Journal Line
        CreateGenJnlLineForTCS(GenJournalLine, Customer);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        LibraryTCS.VerifyTCSEntry(DocumentNo, GenJournalLine."Document Type"::Invoice, GenJournalLine.Amount);
        LibraryERM.ReverseTransaction(GetTransactionNo(DocumentNo));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,PayTax')]
    procedure PostAndReverseTDSEntriesWhichIsPaidToGovernment()
    var
        ConcessionalCode: Record "Concessional Code";
        TCSPostingSetup: Record "TCS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        DocumentNo: Code[20];
        EntryNo: Integer;
    begin
        //[Senerio [355283] [Check If system is not allowing to reverse the TCS entry and G/L Entry if TCS amount paid to government]
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Concessional code
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create & Post General Journal Line
        CreateGenJnlLineForTCS(GenJournalLine, Customer);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        LibraryTCS.VerifyTCSEntry(DocumentNo, GenJournalLine."Document Type"::Invoice, GenJournalLine.Amount);
        CreateTCSPayment(TCSPostingSetup."TCS Account No.");
        EntryNo := GetEntryNo(DocumentNo);
        asserterror LibraryERM.ReverseTransaction(GetTransactionNo(DocumentNo));
        Assert.ExpectedError(StrSubstNo(PaidReverseErr, EntryNo));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,PayTax')]
    procedure PostAdjustedTCSEntriedWhichIsAlreadyPaidToGovernment()
    var
        ConcessionalCode: Record "Concessional Code";
        TCSPostingSetup: Record "TCS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        DocumentNo: Code[20];
        PaidErr: Label 'TCS Paid must be equal to No before Adjustment';
    begin
        //[Senerio [355277] [Check if system is not allowing to do the adjustment for TCS Entries which has already deducted and paid to government authorities.]
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Concessional code
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create & Post General Journal Line
        CreateGenJnlLineForTCS(GenJournalLine, Customer);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        LibraryTCS.VerifyTCSEntry(DocumentNo, GenJournalLine."Document Type"::Invoice, GenJournalLine.Amount);
        CreateTCSPayment(TCSPostingSetup."TCS Account No.");
        Assert.IsTrue(GetPaidStatus(DocumentNo), PaidErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmHandler,TCSAdjPostHandler')]
    procedure PostTCSEntriesAndAdjustment()
    var
        ConcessionalCode: Record "Concessional Code";
        TCSPostingSetup: Record "TCS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        DocumentNo: Code[20];
    begin
        //[Senerio] [355272] [Check if system is allowing to do the adjustment for TCS Entries which has already deducted but not paid to government authorities.]
        //[GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Concessional code
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create & Post General Journal Line
        CreateGenJnlLineForTCS(GenJournalLine, Customer);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        LibraryTCS.VerifyTCSEntry(DocumentNo, GenJournalLine."Document Type"::Invoice, GenJournalLine.Amount);
        CreateAndPostTCSAdjustment(DocumentNo, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmHandler,TCSAdjPostHandler')]
    procedure PostTCSEntriesAndAdjustmentWithZero()
    var
        ConcessionalCode: Record "Concessional Code";
        TCSPostingSetup: Record "TCS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        DocumentNo: Code[20];
    begin
        //[Senerio] [355273] [Check if system is allowing to do the adjustment with TCS percentage as Zero for TCS Entries which has already deducted but not paid to government authorities.]
        //[GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Concessional code
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create & Post General Journal Line
        CreateGenJnlLineForTCS(GenJournalLine, Customer);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        LibraryTCS.VerifyTCSEntry(DocumentNo, GenJournalLine."Document Type"::Invoice, GenJournalLine.Amount);
        CreateAndPostTCSAdjustmentWithZero(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmHandler,TCSAdjPostHandler')]
    procedure PostAdjustedTCSEntriedWhichIsAlreadyAdjusted()
    var
        ConcessionalCode: Record "Concessional Code";
        TCSPostingSetup: Record "TCS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        DocumentNo: Code[20];
    begin
        // [Senerio] [355275] [Check if system is not allowing to calculate TCS amounts for those transactions that are adjusted from TCS Adjustment Journal]
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Concessional code
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create & Post General Journal Line
        CreateGenJnlLineForTCS(GenJournalLine, Customer);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        LibraryTCS.VerifyTCSEntry(DocumentNo, GenJournalLine."Document Type"::Invoice, GenJournalLine.Amount);
        CreateAndPostTCSAdjustment(DocumentNo, false);
        CreateAndPostTCSAdjustmentWithZero(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,ConfirmHandler,TCSAdjPostHandler')]
    procedure PostAdjustedTCSEntriedWithBaseAmountApplied()
    var
        ConcessionalCode: Record "Concessional Code";
        TCSPostingSetup: Record "TCS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        DocumentNo: Code[20];
    begin
        // [Senerio] [355275] [Check if system is not allowing to calculate TCS amounts for those transactions that are adjusted from TCS Adjustment Journal]
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Concessional code
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create & Post General Journal Line
        CreateGenJnlLineForTCS(GenJournalLine, Customer);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        LibraryTCS.VerifyTCSEntry(DocumentNo, GenJournalLine."Document Type"::Invoice, GenJournalLine.Amount);
        CreateAndPostTCSAdjustment(DocumentNo, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CreateNewTemplateAndBatchForTCSAdjustment()
    var
        ConcessionalCode: Record "Concessional Code";
        TCSPostingSetup: Record "TCS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for NOC, Assessee Code, Customer, TCS Setup and Concessional code
        LibraryTCS.CreateTCSSetup(Customer, TCSPostingSetup, ConcessionalCode);
        LibraryTCS.UpdateCustomerWithPANWithConcessional(Customer, true, true);
        CreateTaxRateSetup(TCSPostingSetup."TCS Nature of Collection", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create & Post General Journal Line
        CreateGenJnlLineForTCS(GenJournalLine, Customer);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] TCS and G/L Entry Created and Verified
        LibraryTCS.VerifyGLEntryCount(DocumentNo, 3);
        LibraryTCS.VerifyGLEntryWithTCS(DocumentNo, TCSPostingSetup."TCS Account No.");
        LibraryTCS.VerifyTCSEntry(DocumentNo, GenJournalLine."Document Type"::Invoice, GenJournalLine.Amount);
        CreateAndPostTCSAdjustmentFromBatch();
    end;

    local procedure CreateAndPostTCSAdjustmentFromBatch()
    var
        SourceCode: Record "Source Code";
        TCSJournalTemplates: TestPage "TCS Journal Templates";
        TemplateName: Code[10];
    begin
        TCSJournalTemplates.OpenEdit();
        TCSJournalTemplates.New();
        TemplateName := CopyStr(LibraryRandom.RandText(10), 1, MaxStrLen(TemplateName));
        TCSJournalTemplates.Name.SetValue(TemplateName);
        Storage.Set(TemplateNameLbl, TemplateName);
        TCSJournalTemplates.Description.SetValue(LibraryRandom.RandText(50));
        if SourceCode.FindFirst() then
            TCSJournalTemplates."Source Code".SetValue(SourceCode.Code);
        TCSJournalTemplates."Bal. Account Type".SetValue("Bal. Account Type"::"G/L Account");
        TCSJournalTemplates."Bal. Account No.".SetValue(LibraryERM.CreateGLAccountNoWithDirectPosting());
        TCSJournalTemplates."No. Series".SetValue(LibraryERM.CreateNoSeriesCode());
        TCSJournalTemplates."Posting No. Series".SetValue(LibraryERM.CreateNoSeriesCode());
        TCSJournalTemplates.Batches.Invoke();
    end;

    local procedure CreateAndPostTCSAdjustment(DocuemntNo: Code[20]; ApplyBaseAmount: Boolean)
    var
        TCSJournalBatch: Record "TCS Journal Batch";
        TCSJournalLine: Record "TCS Journal Line";
        TCSEntry: Record "TCS Entry";
        PostTCSJnlLine: Codeunit "Post-TCS Jnl. Line";
        TCSAdjustmentJournal: TestPage "TCS Adjustment Journal";
    begin
        TCSEntry.SetRange("Document No.", DocuemntNo);
        TCSEntry.FindFirst();

        TCSAdjustmentJournal.OpenEdit();
        TCSAdjustmentJournal.Close();
        TCSJournalBatch.FindFirst();
        TCSJournalBatch.Validate("No. Series", LibraryERM.CreateNoSeriesCode());
        TCSJournalBatch.Modify(true);

        TCSAdjustmentJournal.OpenEdit();
        TCSAdjustmentJournal.New();
        TCSAdjustmentJournal."Transaction No".SetValue(TCSEntry."Entry No.");
        TCSAdjustmentJournal."Posting Date".SetValue(WorkDate());

        TCSJournalLine.SetRange("TCS Transaction No.", TCSEntry."Entry No.");
        TCSJournalLine.FindFirst();
        if ApplyBaseAmount then
            TCSJournalLine.Validate("TCS Base Amount Applied", 0);
        TCSJournalLine.Validate("TCS % Applied", LibraryRandom.RandDec(5, 1));
        TCSJournalLine.Validate("eCESS % Applied", LibraryRandom.RandDec(5, 1));
        TCSJournalLine.Validate("SHE Cess % Applied", LibraryRandom.RandDec(5, 1));
        TCSJournalLine.Validate("Surcharge % Applied", LibraryRandom.RandDec(5, 1));
        TCSJournalLine.Modify(true);
        PostTCSJnlLine.PostTCSJournal(TCSJournalLine);
    end;

    local procedure CreateAndPostTCSAdjustmentWithZero(DocuemntNo: Code[20])
    var
        TCSJournalBatch: Record "TCS Journal Batch";
        TCSJournalLine: Record "TCS Journal Line";
        TCSEntry: Record "TCS Entry";
        PostTCSJnlLine: Codeunit "Post-TCS Jnl. Line";
        TCSAdjustmentJournal: TestPage "TCS Adjustment Journal";
    begin
        TCSEntry.SetRange("Document No.", DocuemntNo);
        TCSEntry.FindFirst();

        TCSAdjustmentJournal.OpenEdit();
        TCSAdjustmentJournal.Close();
        TCSJournalBatch.FindFirst();
        TCSJournalBatch.Validate("No. Series", LibraryERM.CreateNoSeriesCode());
        TCSJournalBatch.Modify(true);

        TCSAdjustmentJournal.OpenEdit();
        TCSAdjustmentJournal."Transaction No".SetValue(TCSEntry."Entry No.");
        TCSAdjustmentJournal."Posting Date".SetValue(WorkDate());

        TCSJournalLine.SetRange("TCS Transaction No.", TCSEntry."Entry No.");
        TCSJournalLine.FindFirst();
        TCSJournalLine.Validate("TCS % Applied", 0);
        TCSJournalLine.Validate("eCESS % Applied", 0);
        TCSJournalLine.Validate("SHE Cess % Applied", 0);
        TCSJournalLine.Validate("Surcharge % Applied", 0);
        TCSJournalLine.Modify(true);
        PostTCSJnlLine.PostTCSJournal(TCSJournalLine);
    end;

    local procedure CreateTCSPayment(TCSAccount: Code[20])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        CompanyInformation: Record "Company Information";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        LibraryJournals: Codeunit "Library - Journals";
        Payment: Codeunit "Pay-TCS";
    begin
        CompanyInformation.Get();
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
        GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::"G/L Account", TCSAccount,
        GenJournalLine."Bal. Account Type"::"Bank Account", LibraryERM.CreateBankAccountNo(), 0);
        GenJournalLine.Validate("Posting Date", WorkDate());
        GenJournalLine.Validate("T.C.A.N. No.", CompanyInformation."T.C.A.N. No.");
        GenJournalLine.Modify(true);
        Payment.PayTCS(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure GetTransactionNo(DocumentNo: Code[20]): Integer
    var
        TCSEntry: Record "TCS Entry";
    begin
        TCSEntry.SetRange("Document No.", DocumentNo);
        if TCSEntry.FindFirst() then
            exit(TCSEntry."Transaction No.")
        else
            exit(0);
    end;

    local procedure GetEntryNo(DocumentNo: Code[20]): Integer
    var
        TCSEntry: Record "TCS Entry";
    begin
        TCSEntry.SetRange("Document No.", DocumentNo);
        if TCSEntry.FindFirst() then
            exit(TCSEntry."Entry No.")
        else
            exit(0);
    end;

    local procedure GetPaidStatus(DocumentNo: Code[20]): Boolean
    var
        TCSEntry: Record "TCS Entry";
    begin
        TCSEntry.SetRange("Document No.", DocumentNo);
        TCSEntry.SetRange("TCS Paid", true);
        if not TCSEntry.IsEmpty then
            exit(true)
        else
            exit(false);
    end;

    local procedure CreateGenJnlLineForTCS(var GenJournalLine: Record "Gen. Journal Line"; var Customer: Record Customer)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
        GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Customer, Customer."No.",
        GenJournalLine."Bal. Account Type"::"G/L Account", LibraryERM.CreateGLAccountNoWithDirectPosting(), LibraryRandom.RandDec(10000, 2));
        GenJournalLine.Validate("Posting Date", WorkDate());
        CalculateTCS(GenJournalLine);
        GenJournalLine.Modify();
    end;

    local procedure CalculateTCS(GeneralJnlLine: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnGenJnlLine(GeneralJnlLine, GeneralJnlLine);
    end;

    local procedure CreateTaxRateSetup(TCSNOC: Code[10]; AssesseeCode: Code[10]; ConcessionalCode: Code[10]; EffectiveDate: Date)
    begin
        Storage.Set(TCSNOCTypeLbl, TCSNOC);
        Storage.Set(TCSAssesseeCodeLbl, AssesseeCode);
        Storage.Set(TCSConcessionalCodeLbl, ConcessionalCode);
        Storage.Set(EffectiveDateLbl, Format(EffectiveDate, 0, 9));
        GenerateTaxComponentsPercentage();
        CreateTaxRate();
    end;

    local procedure GenerateTaxComponentsPercentage()
    begin
        Storage.Set(TCSPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(NonPANTCSPercentageLbl, Format(LibraryRandom.RandIntInRange(6, 10)));
        Storage.Set(SurchargePercentageLbl, Format(LibraryRandom.RandIntInRange(6, 10)));
        Storage.Set(ECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(SHECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(TCSThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(4000, 6000)));
        Storage.Set(SurchargeThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(4000, 6000)));
    end;

    local procedure CreateTaxRate()
    var
        TCSSetup: Record "TCS Setup";
        PageTaxtype: TestPage "Tax Types";
    begin
        if not TCSSetup.Get() then
            exit;
        PageTaxtype.OpenEdit();
        PageTaxtype.Filter.SetFilter(Code, TCSSetup."Tax Type");
        PageTaxtype.TaxRates.Invoke();
    end;

    [PageHandler]
    procedure PayTax(var PayTCS: TestPage "Pay TCS")
    begin
        PayTCS."&Pay".Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text; VAR Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MsgHandler(MsgText: Text)
    begin
        if SuccessMsg <> MsgText then
            Error(NotReversedErr);
    end;

    [MessageHandler]
    procedure TCSAdjPostHandler(MsgText: Text)
    begin
        if PostMsg <> MsgText then
            Error(NotPostedErr);
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRate: TestPage "Tax Rates");
    var
        TCSPercentage: Decimal;
        NonPANTCSPercentage: Decimal;
        SurchargePercentage: Decimal;
        eCessPercentage: Decimal;
        SHECessPercentage: Decimal;
        EffectiveDate: Date;
        TCSThresholdAmount: Decimal;
        SurchargeThresholdAmount: Decimal;
    begin
        Evaluate(EffectiveDate, Storage.Get(EffectiveDateLbl), 9);
        Evaluate(TCSPercentage, Storage.Get(TCSPercentageLbl));
        Evaluate(NonPANTCSPercentage, Storage.Get(NonPANTCSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(ECessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(TCSThresholdAmount, Storage.Get(TCSThresholdAmountLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));

        TaxRate.New();
        TaxRate.AttributeValue1.SetValue(Storage.Get(TCSNOCTypeLbl));
        TaxRate.AttributeValue2.SetValue(Storage.Get(TCSAssesseeCodeLbl));
        TaxRate.AttributeValue3.SetValue(Storage.Get(TCSConcessionalCodeLbl));
        TaxRate.AttributeValue4.SetValue(EffectiveDate);
        TaxRate.AttributeValue5.SetValue(TCSPercentage);
        TaxRate.AttributeValue6.SetValue(SurchargePercentage);
        TaxRate.AttributeValue7.SetValue(NonPANTCSPercentage);
        TaxRate.AttributeValue8.SetValue(eCessPercentage);
        TaxRate.AttributeValue9.SetValue(SHECessPercentage);
        TaxRate.AttributeValue10.SetValue(TCSThresholdAmount);
        TaxRate.AttributeValue11.SetValue(SurchargeThresholdAmount);
        TaxRate.OK().Invoke();
    end;

    var
        LibraryTCS: Codeunit "TCS - Library";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        Storage: Dictionary of [Text, Text];
        TemplateNameLbl: Label 'TemplateName', locked = true;
        EffectiveDateLbl: Label 'EffectiveDate', locked = true;
        TCSNOCTypeLbl: Label 'TCSNOCType', locked = true;
        TCSAssesseeCodeLbl: Label 'TCSAssesseeCode', locked = true;
        TCSConcessionalCodeLbl: Label 'TCSConcessionalCode', locked = true;
        TCSPercentageLbl: Label 'TCSPercentage', locked = true;
        NonPANTCSPercentageLbl: Label 'NonPANTCSPercentage', locked = true;
        SurchargePercentageLbl: Label 'SurchargePercentage', locked = true;
        ECessPercentageLbl: Label 'ECessPercentage', Locked = true;
        SHECessPercentageLbl: Label 'SHECessPercentage', locked = true;
        TCSThresholdAmountLbl: Label 'TCSThresholdAmount', locked = true;
        SurchargeThresholdAmountLbl: Label 'SurchargeThresholdAmount', locked = true;
        PaidReverseErr: Label 'You cannot reverse TCS Entry No. %1 because the entry is closed.', Comment = '%1=Entry No.';
        SuccessMsg: Label 'The entries were successfully reversed.', Locked = true;
        NotReversedErr: Label 'The entries were not reversed.', Locked = true;
        NotPostedErr: Label 'Journal lines Not posted.', Locked = true;
        PostMsg: Label 'Journal lines posted successfully.', Locked = true;
}