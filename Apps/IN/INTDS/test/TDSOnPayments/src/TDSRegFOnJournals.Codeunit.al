codeunit 18790 "TDS RegF On Journals"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromTDSPaymentInJournalWithPANWithoutConRegF()
    var
        GenJournalLine: Record "Gen. Journal Line";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [400869] Check if system is allowing to calculate TDS on amount that is over & above threshold for Advance Payment using General Journal for PAN Vendors when TDS Over & Above Threshold amount field is selected in the TDS rates.

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithOutConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted General Journal With PAN and Without Concessional Code
        CreateGeneralJournalforTDSPayment(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, GenJournalLine.Amount, true, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromTDSPaymentInJournalWithoutPANWithoutConRegF()
    var
        GenJournalLine: Record "Gen. Journal Line";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [400915] Check if system is allowing to calculate TDS on amount that is over & above threshold on General Journals as document type as Invoice  for Non PAN Vendors when TDS Over & Above Threshold amount field is selected in the TDS rates.

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithOutConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted General Journal Without PAN and Without Concessional Code
        CreateGeneralJournalforTDSPayment(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, GenJournalLine.Amount, false, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromTDSPaymentInJournalWithPANWithConRegF()
    var
        GenJournalLine: Record "Gen. Journal Line";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [400869] Check if system is allowing to calculate TDS on amount that is over & above threshold for Advance Payment using General Journal for PAN Vendors when TDS Over & Above Threshold amount field is selected in the TDS rates.

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Created and Posted General Journal With PAN and With Concessional Code
        CreateGeneralJournalforTDSPayment(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, GenJournalLine.Amount, true, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromTDSPaymentInJournalWithoutPANWithConRegF()
    var
        GenJournalLine: Record "Gen. Journal Line";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [400915] Check if system is allowing to calculate TDS on amount that is over & above threshold on General Journals as document type as Invoice  for Non PAN Vendors when TDS Over & Above Threshold amount field is selected in the TDS rates.

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Created and Posted General Journal Without PAN and With Concessional Code
        CreateGeneralJournalforTDSPayment(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, GenJournalLine.Amount, false, false, false);
    end;

    local procedure CreateGeneralJournalforTDSPayment(var GenJournalLine: Record "Gen. Journal Line"; var Vendor: Record Vendor; PostingDate: Date)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        LibraryJournals: Codeunit "Library - Journals";
        Amount: Decimal;
        TDSSectionCode: Code[10];
        NatureOfRemittance: Code[10];
        ActApplicable: Code[10];
        CountryCode: Code[10];
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        Amount := LibraryRandom.RandDecInRange(3000000, 4000000, 0);

        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
        GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Vendor, Vendor."No.",
        GenJournalLine."Bal. Account Type"::"G/L Account", CreateGLAccountWithDirectPostingNoVAT(), Amount);

        GenJournalLine.Validate("Posting Date", PostingDate);
        TDSSectionCode := CopyStr(Storage.Get(SectionCodeLbl), 1, 10);
        GenJournalLine.Validate("TDS Section Code", TDSSectionCode);

        if IsForeignVendor then begin
            NatureOfRemittance := CopyStr(Storage.Get(NatureOfRemittanceLbl), 1, 10);
            ActApplicable := CopyStr(Storage.Get(ActApplicableLbl), 1, 10);
            CountryCode := CopyStr(Storage.Get(CountryCodeLbl), 1, 10);
            GenJournalLine.Validate("Nature of Remittance", NatureOfRemittance);
            GenJournalLine.Validate("Act Applicable", ActApplicable);
            GenJournalLine.Validate("Country/Region Code", CountryCode);
        end;

        GenJournalLine.Validate(Amount, Amount);
        GenJournalLine.Modify(true);
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
    begin
        DummyGLEntry.SetRange("Document No.", DocumentNo);
        Assert.RecordCount(DummyGLEntry, ExpectedCount);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text; VAR Reply: Boolean)
    begin
        Reply := true;
    end;

    procedure CreateTaxRateSetup(
        TDSSection: Code[10];
        AssesseeCode: Code[10];
        ConcessionlCode: Code[10];
        EffectiveDate: Date)
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
        Storage.Set(NonPANTDSPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(SurchargePercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(ECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(SHECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(SurchargeThresholdAmountLbl, '0.00');
        Storage.Set(TDSThresholdAmountLbl, Format(LibraryRandom.RandDecInRange(100000, 200000, 0)));
    end;

    local procedure CreateTaxRate()
    var
        TDSSetup: Record "TDS Setup";
        TaxTypes: TestPage "Tax Types";
    begin
        if not TDSSetup.Get() then
            exit;

        TaxTypes.OpenEdit();
        TaxTypes.Filter.SetFilter(Code, TDSSetup."Tax Type");
        TaxTypes.TaxRates.Invoke();
    end;

    local procedure VerifyTDSEntry(
        DocumentNo: Code[20];
        LineAmount: Decimal;
        WithPAN: Boolean;
        SurchargeOverlook: Boolean;
        TDSThresholdOverlook: Boolean)
    var
        TDSEntry: Record "TDS Entry";
        GLEntry: Record "G/L Entry";
        SourceCodeSetup: Record "Source Code Setup";
        ExpectdTDSAmount, ExpectedSurchargeAmount, ExpectedEcessAmount, ExpectedSHEcessAmount : Decimal;
        TDSPercentage, NonPANTDSPercentage, SurchargePercentage, eCessPercentage, TDSBaseAmount, SHECessPercentage : Decimal;
        TDSThresholdAmount, SurchargeThresholdAmount, CurrencyFactor : Decimal;
    begin
        Evaluate(TDSPercentage, Storage.Get(TDSPercentageLbl));
        Evaluate(NonPANTDSPercentage, Storage.Get(NonPANTDSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(eCessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(TDSThresholdAmount, Storage.Get(TDSThresholdAmountLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));

        SourceCodeSetup.Get();

        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.FindFirst();

        TDSBaseAmount := LineAmount - TDSThresholdAmount;

        if CurrencyFactor = 0 then
            CurrencyFactor := 1;

        if (TDSBaseAmount < TDSThresholdAmount) and (TDSThresholdOverlook = false) then
            ExpectdTDSAmount := 0
        else
            if WithPAN then
                ExpectdTDSAmount := TDSBaseAmount * TDSPercentage / 100 / CurrencyFactor
            else
                ExpectdTDSAmount := TDSBaseAmount * NonPANTDSPercentage / 100 / CurrencyFactor;

        if (TDSBaseAmount < SurchargeThresholdAmount) and (SurchargeOverlook = false) then
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
            TDSEntry."Document Type"::Payment, TDSEntry."Document Type",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Document Type"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            DocumentNo, TDSEntry."Document No.", StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Document No."), TDSEntry.TableCaption()));
        Assert.AreEqual(
             SourceCodeSetup."General Journal", TDSEntry."Source Code",
             StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Source Code"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            GLEntry."Transaction No.", TDSEntry."Transaction No.",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Transaction No."), TDSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            TDSBaseAmount / CurrencyFactor, TDSEntry."TDS Base Amount", LibraryTDS.GetTDSRoundingPrecision(),
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("TDS Base Amount"), TDSEntry.TableCaption()));

        if WithPAN then
            Assert.AreEqual(TDSPercentage, TDSEntry."TDS %",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("TDS %"), TDSEntry.TableCaption()))
        else
            Assert.AreEqual(NonPANTDSPercentage, TDSEntry."TDS %",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("TDS %"), TDSEntry.TableCaption()));

        Assert.AreNearlyEqual(
            ExpectdTDSAmount, TDSEntry."TDS Amount", LibraryTdS.GetTDSRoundingPrecision(),
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
        Assert.AreNearlyEqual(
            LineAmount, TDSEntry."TDS Line Amount", LibraryTDS.GetTDSRoundingPrecision(),
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("TDS Line Amount"), TDSEntry.TableCaption()));
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates");
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

        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(Storage.Get(SectionCodeLbl));
        TaxRates.AttributeValue2.SetValue(Storage.Get(TDSAssesseeCodeLbl));
        TaxRates.AttributeValue3.SetValue(EffectiveDate);
        TaxRates.AttributeValue4.SetValue(Storage.Get(TDSConcessionalCodeLbl));
        if IsForeignVendor then begin
            TaxRates.AttributeValue5.SetValue(Storage.Get(NatureOfRemittanceLbl));
            TaxRates.AttributeValue6.SetValue(Storage.Get(ActApplicableLbl));
            TaxRates.AttributeValue7.SetValue(Storage.Get(CountryCodeLbl))
        end else begin
            TaxRates.AttributeValue5.SetValue('');
            TaxRates.AttributeValue6.SetValue('');
            TaxRates.AttributeValue7.SetValue('');
        end;
        TaxRates.AttributeValue8.SetValue(TDSPercentage);
        TaxRates.AttributeValue9.SetValue(NonPANTDSPercentage);
        TaxRates.AttributeValue10.SetValue(SurchargePercentage);
        TaxRates.AttributeValue11.SetValue(eCessPercentage);
        TaxRates.AttributeValue12.SetValue(SHECessPercentage);
        TaxRates.AttributeValue13.SetValue(SurchargeThresholdAmount);
        TaxRates.AttributeValue14.SetValue(TDSThresholdAmount);
        TaxRates.AttributeValue15.SetValue(0);
        TaxRates.AttributeValue16.SetValue(true);
        TaxRates.OK().Invoke();
    end;

    var
        Vendor: Record Vendor;
        LibraryTDS: Codeunit "Library-TDS";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        Storage: Dictionary of [Text, Text];
        IsForeignVendor: Boolean;
        EffectiveDateLbl: Label 'EffectiveDate', Locked = true;
        TDSPercentageLbl: Label 'TDSPercentage', Locked = true;
        NonPANTDSPercentageLbl: Label 'NonPANTDSPercentage', Locked = true;
        TDSEntryVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
        SurchargePercentageLbl: Label 'SurchargePercentage', Locked = true;
        ECessPercentageLbl: Label 'ECessPercentage', Locked = true;
        SHECessPercentageLbl: Label 'SHECessPercentage', Locked = true;
        TDSThresholdAmountLbl: Label 'TDSThresholdAmount', Locked = true;
        SectionCodeLbl: Label 'SectionCode', Locked = true;
        TDSAssesseeCodeLbl: Label 'TDSAssesseeCode', Locked = true;
        SurchargeThresholdAmountLbl: Label 'SurchargeThresholdAmount', Locked = true;
        TDSConcessionalCodeLbl: Label 'TDSConcessionalCode', Locked = true;
        NatureOfRemittanceLbl: Label 'NatureOfRemittance', Locked = true;
        ActApplicableLbl: Label 'ActApplicable', Locked = true;
        CountryCodeLbl: Label 'CountryCode', Locked = true;
}