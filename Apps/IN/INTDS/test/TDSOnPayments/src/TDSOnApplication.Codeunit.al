codeunit 18805 "TDS On Application"
{
    Subtype = Test;

    [Test]
    // [SCENARIO] [353847] Check if the program is calculating TDS in case of creating Purchase Invoice against an full advance payment
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithFullAdvancePayemnt()
    var
        GenJournalLine: Record "Gen. Journal Line";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Purchase Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithOutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted GenJournalLine and Purchase Invoice
        CreateGeneralJournalforTDSPayment(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        PostedInvoiceNo := CreateAndPostPurchaseDocumentWithFullApplication(
            Vendor."No.",
            DocumentNo,
            DocumentType::Invoice,
            LineType::"G/L Account");

        // [THEN] G/L Entries Verified
        VerifyGLEntryCount(PostedInvoiceNo, 2);
    end;

    [Test]
    // [SCENARIO] [353848] Check if the program is calculating TDS in case of creating Purchase Invoice against an partial advance payment
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithPartialAdvancePayment()
    var
        GenJournalLine: Record "Gen. Journal Line";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Purchase Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithOutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted GenJournalLine and Purchase Invoice
        CreateGeneralJournalforTDSPayment(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        PostedInvoiceNo := CreateAndPostPurchaseDocumentWithPartialApplication(
            Vendor."No.",
            DocumentNo,
            DocumentType::Invoice,
            LineType::"G/L Account");

        // [THEN] G/L Entries Verified
        VerifyGLEntryCount(PostedInvoiceNo, 3);
    end;

    [Test]
    // [SCENARIO] [353848] Check if the program is calculating TDS in case of creating Purchase Invoice against an partial advance payment
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithExceedAdvancePaymentt()
    var
        GenJournalLine: Record "Gen. Journal Line";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Purchase Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithOutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted GenJournalLine and Purchase Invoice
        CreateGeneralJournalforTDSPayment(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        PostedInvoiceNo := CreateAndPostPurchaseDocumentWithExceedApplication(
            Vendor."No.",
            DocumentNo,
            DocumentType::Invoice,
            LineType::"G/L Account");

        // [THEN] G/L Entries Verified
        VerifyGLEntryCount(PostedInvoiceNo, 3);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPaymntAppAgnstPurInvForPanVend()
    var
        GenJournalLine: Record "Gen. Journal Line";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Purchase Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO] [401675] [Check if system is allowing to calculate TDS amount on Payment application against Purchase Invoice for PAN Vendors TDS Over & Above Threshold amount field is selected]

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithOutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Invoice applied against General Journal
        CreateGeneralJournalforTDSPayment(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        Storage.Set(GLDocNoLbl, DocumentNo);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        PostedInvoiceNo := CreateAndPostPurchaseDocumentWithPartialApplication(
            Vendor."No.",
            DocumentNo,
            DocumentType::Invoice,
            LineType::"G/L Account");

        // [THEN] TDS Entries Verified
        VerifyTDSEntry(PostedInvoiceNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPaymntAppAgnstPurInvForNonPanVend()
    var
        GenJournalLine: Record "Gen. Journal Line";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Purchase Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO] [401684] [Check if system is allowing to calculate TDS amount on Payment application against Purchase Invoice for Non PAN vendors TDS Over & Above Threshold amount field is selected]

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithOutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Invoice applied against General Journal
        CreateGeneralJournalforTDSPayment(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        Storage.Set(GLDocNoLbl, DocumentNo);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        PostedInvoiceNo := CreateAndPostPurchaseDocumentWithPartialApplication(
            Vendor."No.",
            DocumentNo,
            DocumentType::Invoice,
            LineType::"G/L Account");

        // [THEN] TDS Entries Verified
        VerifyTDSEntry(PostedInvoiceNo, false, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvAgnstPaymentForPanVend()
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchaseHeader: Record "Purchase Header";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Purchase Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO] [401622] [Check if system is allowing to calculate TDS amount on Purchase Invoice application against payment for PAN Vendors TDS Over & Above Threshold amount field is selected]

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithOutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted General Journal applied against Purchase Invoice
        PostedInvoiceNo := CreateandPostPurchaseDocument(PurchaseHeader, DocumentType::Invoice, Vendor."No.", WorkDate(), LineType::"G/L Account");
        Storage.Set(GLDocNoLbl, PostedInvoiceNo);
        CreateGeneralJournalforTDSPaymentWithApplication(GenJournalLine, Vendor, WorkDate(), PostedInvoiceNo);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/L Entries Verified
        VerifyGLEntryCount(PostedInvoiceNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvAgnstPaymentForNonPanVend()
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchaseHeader: Record "Purchase Header";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Purchase Line Type";
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO] [401687] [Check if system is allowing to calculate TDS amount on Purchase Invoice application against payment for Non PAN Vendors TDS Over & Above Threshold amount field is selected]

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithOutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted General Journal applied against Purchase Invoice
        PostedInvoiceNo := CreateandPostPurchaseDocument(PurchaseHeader, DocumentType::Invoice, Vendor."No.", WorkDate(), LineType::"G/L Account");
        Storage.Set(GLDocNoLbl, PostedInvoiceNo);
        CreateGeneralJournalforTDSPaymentWithApplication(GenJournalLine, Vendor, WorkDate(), PostedInvoiceNo);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/L Entries Verified
        VerifyGLEntryCount(PostedInvoiceNo, 2);
    end;

    local procedure CreateGeneralJournalforTDSPayment(var GenJournalLine: Record "Gen. Journal Line"; var Vendor: Record Vendor; PostingDate: Date)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        LibraryJournals: Codeunit "Library - Journals";
        Amount: Decimal;
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        Amount := LibraryRandom.RandDec(100000, 2);
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Vendor, Vendor."No.",
            GenJournalLine."Bal. Account Type"::"Bank Account", LibraryERM.CreateBankAccountNo(), Amount);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("TDS Section Code");
        GenJournalLine.Validate(Amount, Amount);
        GenJournalLine.Modify(true);
    end;

    local procedure CreateGeneralJournalforTDSPaymentWithApplication(var GenJournalLine: Record "Gen. Journal Line"; var Vendor: Record Vendor; PostingDate: Date; PurchInvNo: Code[20])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        LibraryJournals: Codeunit "Library - Journals";
        Amount: Decimal;
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        Amount := LibraryRandom.RandDec(100000, 2);
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Vendor, Vendor."No.",
            GenJournalLine."Bal. Account Type"::"Bank Account", LibraryERM.CreateBankAccountNo(), Amount);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("TDS Section Code", Storage.Get(SectionCodeLbl));
        GenJournalLine.Validate("Applies-to Doc. Type", GenJournalLine."Applies-to Doc. Type"::Invoice);
        GenJournalLine.Validate("Applies-to Doc. No.", PurchInvNo);
        GenJournalLine.Validate(Amount, Amount);
        GenJournalLine.Modify(true);
    end;

    local procedure CreateAndPostPurchaseDocumentWithFullApplication(vendorNo: code[20];
        GLDocNo: code[20];
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Purchase Line Type"): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LibraryPurchase: Codeunit "Library - Purchase";
        DocumentNo: Code[20];
    begin
        CreatePurchaseDocument(
            PurchaseHeader,
            DocumentType,
            VendorNo,
            WorkDate(), LineType,
            false);
        PurchaseHeader.Validate("Pay-to Vendor No.", VendorNo);
        PurchaseHeader.Validate("Applies-to Doc. Type", PurchaseHeader."Applies-to Doc. Type"::Payment);
        PurchaseHeader.Validate("Applies-to Doc. No.", GLDocNo);
        PurchaseHeader.Modify(true);
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        PurchaseLine.Validate("Direct Unit Cost", GetGLEntryAmounttoApply(GLDocNo));
        PurchaseLine.Modify(true);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        exit(DocumentNo);
    end;

    local procedure CreateAndPostPurchaseDocumentWithPartialApplication(vendorNo: code[20];
        GLDocNo: code[20];
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Purchase Line Type"): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        LibraryPurchase: Codeunit "Library - Purchase";
        DocumentNo: Code[20];
    begin
        CreatePurchaseDocument(
            PurchaseHeader,
            DocumentType,
            VendorNo,
            WorkDate(), LineType,
            false);
        PurchaseHeader.Validate("Applies-to Doc. Type", PurchaseHeader."Applies-to Doc. Type"::Payment);
        PurchaseHeader.Validate("Applies-to Doc. No.", GLDocNo);
        PurchaseHeader.Modify(true);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        exit(DocumentNo);
    end;

    local procedure CreateAndPostPurchaseDocumentWithExceedApplication(vendorNo: code[20];
        GLDocNo: code[20];
        DocumentType: Enum "Purchase Document Type";
        LineType: Enum "Purchase Line Type"): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LibraryPurchase: Codeunit "Library - Purchase";
        DocumentNo: Code[20];
    begin
        CreatePurchaseDocument(
            PurchaseHeader,
            DocumentType,
            VendorNo,
            WorkDate(), LineType,
            false);
        PurchaseHeader.Validate("Applies-to Doc. Type", PurchaseHeader."Applies-to Doc. Type"::Payment);
        PurchaseHeader.Validate("Applies-to Doc. No.", GLDocNo);
        PurchaseHeader.Modify(true);
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        PurchaseLine.Validate("Direct Unit Cost", GetGLEntryAmounttoApply(GLDocNo) + 10000);
        PurchaseLine.Modify(true);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        exit(DocumentNo);
    end;

    local procedure GetGLEntryAmounttoApply(DocNo: code[20]): Decimal
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Document No.", DocNo);
        GLEntry.SetRange("Bal. Account Type", GLEntry."Bal. Account Type"::Vendor);
        GLEntry.FindFirst();
        exit(-GLEntry.Amount);
    end;

    local procedure GetGLEntryAmount(DocNo: code[20]): Decimal
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Document No.", DocNo);
        GLEntry.SetRange("Bal. Account Type", GLEntry."Bal. Account Type"::"Bank Account");
        GLEntry.FindFirst();
        exit(Round(GLEntry.Amount, LibraryTDS.GetTDSRoundingPrecision()));
    end;

    local procedure CreatePurchaseDocument(
        var PurchaseHeader: Record "Purchase Header";
        DocumentType: Enum "Purchase Document Type";
        VendorNo: Code[20];
        PostingDate: Date;
        LineType: enum "Purchase Line Type";
        LineDiscount: Boolean)
    var
        PurchaseLine: Record "Purchase Line";
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        PurchaseHeader.Validate("Pay-to Vendor No.", VendorNo);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Modify(true);
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, LineType, LineDiscount);
    end;

    local procedure CreateandPostPurchaseDocument(
        var PurchaseHeader: Record "Purchase Header";
        DocumentType: Enum "Purchase Document Type";
        VendorNo: Code[20];
        PostingDate: Date;
        LineType: enum "Purchase Line Type"): Code[20]
    var
        PurchaseLine: Record "Purchase Line";
        LibraryPurchase: Codeunit "Library - Purchase";
        LineDiscount: Boolean;
        DocumentNo: Code[20];
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        PurchaseHeader.Validate("Pay-to Vendor No.", VendorNo);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Modify(true);
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, LineType, LineDiscount);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        exit(DocumentNo);
    end;

    local procedure CreatePurchaseLine(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line";
    Type: enum "Purchase Line Type"; LineDiscount: Boolean)
    var
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, Type, GetLineTypeNo(Type), LibraryRandom.RandDec(1, 2));

        PurchaseLine.Validate(Quantity, LibraryRandom.RandIntInRange(1, 1));
        if LineDiscount then
            PurchaseLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2))
        else
            PurchaseLine.Validate("Line Discount %", 0);

        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInDecimalRange(200000, 300000, 0));
        PurchaseLine.Validate("TDS Section Code", Storage.Get(SectionCodeLbl));
        PurchaseLine.Modify(true);
    end;

    local procedure GetLineTypeNo(Type: enum "Purchase Line Type"): Code[20]
    begin
        if Type = Type::"G/L Account" then
            exit(CreateGLAccountWithDirectPostingNoVAT());
    end;

    local procedure CreateGLAccountWithDirectPostingNoVAT(): Code[20]
    var
        GLAccount: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryTDS.CreateZeroVATPostingSetup(VATPostingSetup);
        GLAccount.Get(LibraryERM.CreateGLAccountWithPurchSetup());
        GLAccount.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        GLAccount.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        GLAccount.Modify();
        exit(GLAccount."No.");
    end;

    local procedure VerifyGLEntryCount(DocumentNo: Code[20]; ExpectedCount: Integer)
    var
        DummyGLEntry: Record "G/L Entry";
        Assert: Codeunit Assert;
    begin
        DummyGLEntry.SetRange("Document No.", DocumentNo);
        Assert.RecordCount(DummyGLEntry, ExpectedCount);
    end;

    local procedure CreateTaxRateSetup(TDSSection: Code[10]; AssesseeCode: Code[10]; ConcessionlCode: Code[10]; EffectiveDate: Date)
    var
        Section: Code[10];
        TDSAssesseeCode: Code[10];
        TDSConcessionlCode: Code[10];
    begin
        Section := TDSSection;
        Storage.Set(SectionCodeLbl, Section);
        TDSAssesseeCode := AssesseeCode;
        Storage.Set(TDSAssesseeCodeLbl, TDSAssesseeCode);
        TDSConcessionlCode := ConcessionlCode;
        Storage.Set(TDSConcessionalCodeLbl, TDSConcessionlCode);
        Storage.Set(EffectiveDateLbl, Format(EffectiveDate, 0, 9));
        CreateTaxRate();
    end;

    local procedure GenerateTaxComponentsPercentage()
    begin
        Storage.Set(TDSPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(NonPANTDSPercentageLbl, Format(LibraryRandom.RandIntInRange(6, 10)));
        Storage.Set(SurchargePercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(ECessPercentageLbl, Format(LibraryRandom.RandIntInRange(4, 6)));
        Storage.Set(SHECessPercentageLbl, Format(LibraryRandom.RandIntInRange(4, 8)));
        Storage.Set(TDSThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(0, 0)));
        Storage.Set(SurchargeThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(0, 0)));
    end;

    local procedure CreateTaxRate()
    var
        TDSSetup: Record "TDS Setup";
        PageTaxtype: TestPage "Tax Types";
    begin
        TDSSetup.Get();
        PageTaxtype.OpenEdit();
        PageTaxtype.Filter.SetFilter(Code, TDSSetup."Tax Type");
        PageTaxtype.TaxRates.Invoke();
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRate: TestPage "Tax Rates");
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
        GenerateTaxComponentsPercentage();
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
        TaxRate.AttributeValue16.SetValue(false);
        TaxRate.OK().Invoke();
    end;

    local procedure VerifyTDSEntry(
        DocumentNo: Code[20];
        WithPAN: Boolean;
        SurchargeOverlook: Boolean;
        TDSThresholdOverlook: Boolean)
    var
        TDSEntry: Record "TDS Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        GLEntry: Record "G/L Entry";
        TDSPostingSetup: Record "TDS Posting Setup";
        CompanyInformation: Record "Company Information";
        Location: Record Location;
        Vendor: Record Vendor;
        SourceCodeSetup: Record "Source Code Setup";
        ExpectdTDSAmount, ExpectedSurchargeAmount, ExpectedEcessAmount, ExpectedSHEcessAmount : Decimal;
        TDSPercentage, NonPANTDSPercentage, SurchargePercentage, eCessPercentage, SHECessPercentage, TDSBaseAmount, TotalTDSBaseAmt : Decimal;
        TDSThresholdAmount, SurchargeThresholdAmount, CurrencyFactor : Decimal;
        TANNo: Code[10];
    begin
        Evaluate(TDSPercentage, Storage.Get(TDSPercentageLbl));
        Evaluate(NonPANTDSPercentage, Storage.Get(NonPANTDSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(eCessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(TDSThresholdAmount, Storage.Get(TDSThresholdAmountLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));

        TDSBaseAmount := GetBaseAmountForPurchase(DocumentNo);
        CurrencyFactor := GetCurrencyFactorForPurchase(DocumentNo);

        PurchInvHeader.Get(DocumentNo);

        PurchInvLine.SetRange("Document No.", DocumentNo);
        PurchInvLine.SetFilter("No.", '<>%1', '');
        PurchInvLine.FindFirst();

        if PurchInvHeader."Applies-to Doc. No." <> '' then
            TotalTDSBaseAmt := TDSBaseAmount - GetGLEntryAmount(Storage.Get(GLDocNoLbl))
        else
            TotalTDSBaseAmt := GetBaseAmountForPurchase(DocumentNo);

        Vendor.Get(PurchInvHeader."Buy-from Vendor No.");
        SourceCodeSetup.Get();

        if PurchInvLine."Location Code" = '' then begin
            CompanyInformation.Get();
            TANNo := CompanyInformation."T.A.N. No.";
        end else begin
            Location.Get(PurchInvLine."Location Code");
            TANNo := Location."T.A.N. No.";
        end;

        TDSPostingSetup.SetRange("TDS Section", PurchInvLine."TDS Section Code");
        TDSPostingSetup.FindFirst();

        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.FindFirst();

        if CurrencyFactor = 0 then
            CurrencyFactor := 1;

        if (TotalTDSBaseAmt < TDSThresholdAmount) and (TDSThresholdOverlook = false) then
            ExpectdTDSAmount := 0
        else
            if WithPAN then
                ExpectdTDSAmount := TotalTDSBaseAmt * TDSPercentage / 100 / CurrencyFactor
            else
                ExpectdTDSAmount := TotalTDSBaseAmt * NonPANTDSPercentage / 100 / CurrencyFactor;

        if (TotalTDSBaseAmt < SurchargeThresholdAmount) and (SurchargeOverlook = false) then
            ExpectedSurchargeAmount := 0
        else
            ExpectedSurchargeAmount := ExpectdTDSAmount * SurchargePercentage / 100;

        ExpectedEcessAmount := (ExpectdTDSAmount + ExpectedSurchargeAmount) * eCessPercentage / 100;
        ExpectedSHEcessAmount := (ExpectdTDSAmount + ExpectedSurchargeAmount) * SHECessPercentage / 100;

        TDSEntry.SetRange("Document No.", DocumentNo);
        TDSEntry.FindFirst();

        Assert.AreEqual(
            TDSEntry."Account Type"::"G/L Account", TDSEntry."Account Type",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Account Type"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            TDSPostingSetup."TDS Account", TDSEntry."Account No.",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Account No."), TDSEntry.TableCaption()));
        Assert.AreEqual(
            PurchInvHeader."Posting Date", TDSEntry."Posting Date",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Posting Date"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            TDSEntry."Document Type"::Invoice, TDSEntry."Document Type",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Document Type"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            PurchInvHeader."No.", TDSEntry."Document No.", StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Document No."), TDSEntry.TableCaption()));
        Assert.AreEqual(
            Vendor."Assessee Code", TDSEntry."Assessee Code",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName(Section), TDSEntry.TableCaption()));
        Assert.AreEqual(
            PurchInvLine."Nature of Remittance", TDSEntry."Nature of Remittance",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Nature of Remittance"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            PurchInvLine."Act Applicable", TDSEntry."Act Applicable",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Act Applicable"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            PurchInvLine."TDS Section Code", TDSEntry.Section,
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Assessee Code"), TDSEntry.TableCaption()));
        Assert.AreEqual(
          SourceCodeSetup.Purchases, TDSEntry."Source Code",
          StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Source Code"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            GLEntry."Transaction No.", TDSEntry."Transaction No.",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Transaction No."), TDSEntry.TableCaption()));
        Assert.AreNearlyEqual(
           TotalTDSBaseAmt, TDSEntry."TDS Base Amount", LibraryTDS.GetTDSRoundingPrecision(),
           StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("TDS Base Amount"), TDSEntry.TableCaption()));

        if WithPAN then
            Assert.AreEqual(TDSPercentage, TDSEntry."TDS %",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("TDS %"), TDSEntry.TableCaption()))
        else
            Assert.AreEqual(NonPANTDSPercentage, TDSEntry."TDS %",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("TDS %"), TDSEntry.TableCaption()));

        Assert.AreNearlyEqual(
            ExpectdTDSAmount, TDSEntry."TdS Amount", LibraryTdS.GetTDSRoundingPrecision(),
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("TDS Amount"), TDSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectdTDSAmount, TDSEntry."Remaining TDS Amount", LibraryTdS.GetTDSRoundingPrecision(),
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Remaining TDS Amount"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            SurchargePercentage, TDSEntry."Surcharge %",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Surcharge %"), TDSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectedSurchargeAmount, TDSEntry."Surcharge Amount", LibraryTDS.GetTDSRoundingPrecision(),
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Surcharge Amount"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            eCessPercentage, TDSEntry."eCESS %",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("eCESS %"), TDSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectedEcessAmount, TDSEntry."eCESS Amount", LibraryTDS.GetTDSRoundingPrecision(),
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("eCESS Amount"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            SHECessPercentage, TDSEntry."SHE Cess %",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("SHE Cess %"), TDSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            ExpectedSHEcessAmount, TDSEntry."SHE Cess Amount", LibraryTDS.GetTDSRoundingPrecision(),
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("SHE Cess Amount"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            Vendor."P.A.N. No.", TDSEntry."Deductee PAN No.",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Deductee PAN No."), TDSEntry.TableCaption()));
        Assert.AreEqual(
            TANNo, TDSEntry."T.A.N. No.",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("T.A.N. No."), TDSEntry.TableCaption()));
        Assert.AreEqual(
            TDSPostingSetup."TDS Account", TDSEntry."Party Account No.",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Party Account No."), TDSEntry.TableCaption()));
    end;

    local procedure GetBaseAmountForPurchase(DocumentNo: Code[20]): Decimal
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        PurchInvLine.SetRange("Document No.", DocumentNo);
        PurchInvLine.CalcSums(Amount);
        exit(PurchInvLine.Amount);
    end;

    local procedure GetCurrencyFactorForPurchase(DocumentNo: Code[20]): Decimal
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        PurchInvHeader.SetRange("No.", DocumentNo);
        if PurchInvHeader.FindFirst() then
            exit(PurchInvHeader."Currency Factor");
    end;

    var
        Vendor: Record Vendor;
        LibraryTDS: Codeunit "Library-TDS";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        Storage: Dictionary of [Text, Text];
        EffectiveDateLbl: Label 'EffectiveDate', Locked = true;
        TDSPercentageLbl: Label 'TDSPercentage', Locked = true;
        NonPANTDSPercentageLbl: Label 'NonPANTDSPercentage', Locked = true;
        SurchargePercentageLbl: Label 'SurchargePercentage', Locked = true;
        ECessPercentageLbl: Label 'ECessPercentage', Locked = true;
        SHECessPercentageLbl: Label 'SHECessPercentage', Locked = true;
        TDSThresholdAmountLbl: Label 'TDSThresholdAmount', Locked = true;
        SectionCodeLbl: Label 'SectionCode', Locked = true;
        GLDocNoLbl: Label 'GLDocNo', Locked = true;
        TDSAssesseeCodeLbl: Label 'TDSAssesseeCode', Locked = true;
        SurchargeThresholdAmountLbl: Label 'SurchargeThresholdAmount', Locked = true;
        TDSConcessionalCodeLbl: Label 'TDSConcessionalCode', Locked = true;
        TDSEntryVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
}