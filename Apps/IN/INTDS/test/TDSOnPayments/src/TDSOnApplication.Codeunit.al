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

        /// [WHEN] Created and Posted GenJournalLine and Purchase Invoice
        CreateGeneralJournalforTDSPayment(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        PostedInvoiceNo := CreateAndPostPurchaseDocumentWithPartialApplication(
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
        VerifyGLEntryCount(PostedInvoiceNo, 2);
    end;

    local procedure CreateGeneralJournalforTDSPayment(var GenJournalLine: Record "Gen. Journal Line"; var Vendor: Record Vendor; PostingDate: Date)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        LibraryJournal: Codeunit "Library - Journals";
        Amount: Decimal;
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        Amount := LibraryRandom.RandDec(100000, 2);
        LibraryJournal.CreateGenJournalLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
        GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Vendor, Vendor."No.",
        GenJournalLine."Bal. Account Type"::"Bank Account", LibraryERM.CreateBankAccountNo(), Amount);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("TDS Section Code");
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
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Modify(true);
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, LineType, LineDiscount);
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
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInDecimalRange(1000, 1001, 0));
        PurchaseLine.Modify(true);
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
        Storage.Set(SurchargePercentageLbl, Format(LibraryRandom.RandIntInRange(6, 10)));
        Storage.Set(ECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(SHECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(TDSThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(4000, 6000)));
        Storage.Set(SurchargeThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(4000, 6000)));
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
        TaxRate.OK().Invoke();
    end;

    var
        Vendor: Record Vendor;
        LibraryTDS: Codeunit "Library-TDS";
        LibraryERM: Codeunit "Library - ERM";
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
        TDSAssesseeCodeLbl: Label 'TDSAssesseeCode', Locked = true;
        SurchargeThresholdAmountLbl: Label 'SurchargeThresholdAmount', Locked = true;
        TDSConcessionalCodeLbl: Label 'TDSConcessionalCode', Locked = true;
}