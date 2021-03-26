codeunit 18806 "TDS Validations Tests"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure VerifyForeignVendorValidationOnGeneralJournal()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        TDSNatureOfRemittance: Record "TDS Nature of Remittance";
        TDSActApplicable: Record "Act Applicable";
    begin
        // [SCENARIO] Verify Foreign Vendor Validations On General Journal

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode 
        IsForeignVendor := true;
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        LibraryTDS.CreateForeignVendorWithPANNoandWithoutConcessional(Vendor);
        LibraryTDS.CreateNatureOfRemittance(TDSNatureOfRemittance);
        LibraryTDS.CreateActApplicable(TDSActApplicable);
        LibraryTDS.AttachSectionWithForeignVendor(TDSPostingSetup."TDS Section", Vendor."No.", true, true, true, false, TDSNatureOfRemittance.Code, TDSActApplicable.Code);
        Storage.Set(NatureOfRemittanceLbl, TDSNatureOfRemittance.Code);
        Storage.Set(ActApplicableLbl, TDSActApplicable.Code);
        Storage.Set(CountryCodeLbl, Vendor."Country/Region Code");
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create General Journal with Foreign Vendor
        asserterror CreateGeneralJournalforTDSInvoice(GenJournalLine, Vendor, WorkDate());

        // [THEN] Assert Error Verified For Foreign Vendor Validation On Nature of Remittance
        Assert.ExpectedError(StrSubstNo(NonResidentPaymentsSelectionErr, GenJournalLine."Account No."));
        IsForeignVendor := false;
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,TemplatePageHandler,OpenTDSSectionsPage')]
    procedure PostFromGeneralJournalWithTDSSectionLookUp()
    var
        GenJournalLine: Record "Gen. Journal Line";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] Verify TDS Section Lookup on General Journal Page

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithOutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post GenJournalLine with PAN and Without Concessional with TDS Section Lookup
        CreateGeneralJournalWithTDSSectionLookup(GenJournalLine, Vendor, WorkDate());
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, -Round(GenJournalLine.Amount, 1, '='), GenJournalLine."Currency Factor", true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,OpenTDSSectionsPage')]
    procedure PostFromGeneralJournalWithTDSCustomerSectionLookup()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
    begin
        // [SCENARIO] Verify TDS Customer Section Lookup on General Journal Page

        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post General Journal with TDS Customer Section LookUp
        CreateGenJournalLineWithTDSCertificateReceivable(
            GenJournalLine,
            Customer."No.",
            TDSPostingSetup."TDS Section");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Customer Ledger Entry Verified
        VerifyCustomerLedgerEntry(Customer);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,TemplatePageHandler,OpenTDSSectionsPage')]
    procedure PostFromGeneralJournalWithTDSOnCustomerSection()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
    begin
        // [SCENARIO] Verify TDS Customer Section on General Journal

        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post General Journal with TDS Customer Section LookUp
        CreateGenJournalLineWithTDSCustomerSection(
            GenJournalLine,
            Customer."No.",
            TDSPostingSetup."TDS Section");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Customer Ledger Entry Verified
        VerifyCustomerLedgerEntry(Customer);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure VerifyIncludeGSTInTDSBaseValidationOnGeneralJnlForTDS()
    var
        GenJournalLine: Record "Gen. Journal Line";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
    begin
        // [SCENARIO] Verify IncludeGSTInTDSBase Validation On General Journal

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithOutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create GenJournalLine with PAN and Without Concessional
        CreateGeneralJournalforTDSInvoice(GenJournalLine, Vendor, WorkDate());
        asserterror GenJournalLine.Validate("Include GST in TDS Base", true);

        // [THEN] Assert Error Verified
        Assert.ExpectedError(GSTTDSIncErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure VerifyLocationCodeValidationOnGeneralJnlForTDS()
    var
        GenJournalLine: Record "Gen. Journal Line";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        Location: Record Location;
        LibraryWarehouse: Codeunit "Library - Warehouse";
    begin
        // [SCENARIO] Verify Location Code Validation For TDS On General Journal

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithOutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create GenJournalLine with PAN and Without Concessional
        CreateGeneralJournalforTDSInvoice(GenJournalLine, Vendor, WorkDate());
        GenJournalLine.Validate("Location Code", LibraryWarehouse.CreateLocation(Location));
        GenJournalLine.Modify(true);

        // [THEN] TANNo Verified on Company Information
        VerifyTANNoOnCompanyInformation();
    end;

    local procedure CreateGenJournalLineWithTDSCertificateReceivable(
        var GenJournalLine: Record "Gen. Journal Line";
        CustomerNo: Code[20];
        TDSSection: Code[10])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        LibraryJournals: Codeunit "Library - Journals";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        Storage.Set(TemplateLbl, GenJournalTemplate.Name);

        LibraryJournals.CreateGenJournalLine(GenJournalLine,
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::Customer,
            CustomerNo,
            GenJournalLine."Bal. Account Type"::"Bank Account",
            LibraryERM.CreateBankAccountNo(), 0.00);
        GenJournalLine.Validate("TDS Certificate Receivable", true);
        GenJournalLine.Validate("TDS Section Code", TDSSection);
        GenJournalLine.Modify(true);

        TDSForCustomerSubscribers.TDSSectionCodeLookupGenLineForCustomer(GenJournalLine, CustomerNo, true);

        GenJournalLine.Validate(Amount, -LibraryRandom.RandDec(100000, 2));
        GenJournalLine.Modify(true);
    end;

    local procedure CreateGenJournalLineWithTDSCustomerSection(
        var GenJournalLine: Record "Gen. Journal Line";
        CustomerNo: Code[20];
        TDSSection: Code[10])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        LibraryJournals: Codeunit "Library - Journals";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        Storage.Set(TemplateLbl, GenJournalTemplate.Name);

        LibraryJournals.CreateGenJournalLine(GenJournalLine,
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::Customer,
            CustomerNo,
            GenJournalLine."Bal. Account Type"::"Bank Account",
            LibraryERM.CreateBankAccountNo(), 0.00);
        GenJournalLine.Validate("TDS Certificate Receivable", true);
        GenJournalLine.Validate("TDS Section Code", TDSSection);
        GenJournalLine.Modify(true);

        TDSSectionLookUp(GenJournalLine."Document No.");

        GenJournalLine.Validate(Amount, -LibraryRandom.RandDec(100000, 2));
        GenJournalLine.Modify(true);
    end;

    local procedure VerifyTANNoOnCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        CompanyInformation.SetFilter(CompanyInformation."T.A.N. No.", '<>%1', '');
        if CompanyInformation.IsEmpty then
            Error(LocationCodeErr);
    end;

    local procedure CreateGeneralJournalWithTDSSectionLookup(
        var GenJournalLine: Record "Gen. Journal Line";
        var Vendor: Record Vendor; PostingDate: Date)
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
        Storage.Set(TemplateLbl, GenJournalTemplate.Name);

        Amount := LibraryRandom.RandDec(100000, 2);
        LibraryJournals.CreateGenJournalLine(GenJournalLine,
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::Vendor,
            Vendor."No.",
            GenJournalLine."Bal. Account Type"::"G/L Account",
            CreateGLAccountWithDirectPostingNoVAT(), -Amount);
        GenJournalLine.Validate("Posting Date", PostingDate);
        TDSSectionCode := (Storage.Get(SectionCodeLbl));
        GenJournalLine.Validate("TDS Section Code", TDSSectionCode);

        TDSSectionLookUp(GenJournalLine."Document No.");

        if IsForeignVendor then begin
            NatureOfRemittance := (Storage.Get(NatureOfRemittanceLbl));
            ActApplicable := (Storage.Get(ActApplicableLbl));
            CountryCode := (Storage.Get(CountryCodeLbl));
            GenJournalLine.Validate("Nature of Remittance", NatureOfRemittance);
            GenJournalLine."Country/Region Code" := CountryCode;
            GenJournalLine.Validate("Act Applicable", ActApplicable);
        end;

        GenJournalLine.Validate(Amount, -Amount);
        GenJournalLine.Modify(true);
    end;

    local procedure CreateGeneralJournalforTDSInvoice(
        var GenJournalLine: Record "Gen. Journal Line";
        var Vendor: Record Vendor; PostingDate: Date)
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

        Amount := LibraryRandom.RandDec(100000, 2);
        LibraryJournals.CreateGenJournalLine(GenJournalLine,
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::Vendor,
            Vendor."No.",
            GenJournalLine."Bal. Account Type"::"G/L Account",
            CreateGLAccountWithDirectPostingNoVAT(), -Amount);
        GenJournalLine.Validate("Posting Date", PostingDate);
        TDSSectionCode := (Storage.Get(SectionCodeLbl));
        GenJournalLine.Validate("TDS Section Code", TDSSectionCode);

        if IsForeignVendor then begin
            NatureOfRemittance := (Storage.Get(NatureOfRemittanceLbl));
            ActApplicable := (Storage.Get(ActApplicableLbl));
            CountryCode := (Storage.Get(CountryCodeLbl));
            GenJournalLine.Validate("Nature of Remittance", NatureOfRemittance);
            GenJournalLine."Country/Region Code" := CountryCode;
            GenJournalLine.Validate("Act Applicable", ActApplicable);
        end;

        GenJournalLine.Validate(Amount, -Amount);
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

    local procedure VerifyCustomerLedgerEntry(Customer: Record Customer)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Customer No.", Customer."No.");
        CustLedgerEntry.SetRange("TDS Certificate Receivable", true);
        CustLedgerEntry.FindFirst();
        Assert.RecordIsNotEmpty(CustLedgerEntry);
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
        Storage.Set(eCessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(SHECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(TDSThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(4000, 6000)));
        Storage.Set(SurchargeThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(4000, 6000)));
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

    local procedure VerifyTDSEntry(DocumentNo: Code[20]; TDSBaseAmount: Decimal; CurrencyFactor: Decimal; WithPAN: Boolean; SurchargeOverlook: Boolean; TDSThresholdOverlook: Boolean)
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
        AmountErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = TCS Amount and TCS field Caption';
    begin
        Evaluate(TDSPercentage, Storage.Get(TDSPercentageLbl));
        Evaluate(NonPANTDSPercentage, Storage.Get(NonPANTDSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(eCessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(TDSThresholdAmount, Storage.Get(TDSThresholdAmountLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));

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

        Assert.AreNearlyEqual(
            TDSBaseAmount / CurrencyFactor, TDSEntry."TDS Base Amount", LibraryTDS.GetTDSRoundingPrecision(),
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

    local procedure TDSSectionLookUp(DocumentNo: Code[20])
    var
        GeneralJournalTestPage: TestPage "General Journal";
    begin
        GeneralJournalTestPage.OpenEdit();
        GeneralJournalTestPage.Filter.SetFilter("Document No.", DocumentNo);
        GeneralJournalTestPage."TDS Section Code".Lookup();
        GeneralJournalTestPage.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure TemplatePageHandler(var GeneralJournalTemplateList: TestPage "General Journal Template List")
    begin
        GeneralJournalTemplateList.Filter.SetFilter(Name, Storage.Get(TemplateLbl));
        GeneralJournalTemplateList.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure OpenTDSSectionsPage(var TDSSections: TestPage "TDS Sections")
    begin
        TDSSections.Filter.SetFilter(Code, Storage.Get(SectionCodeLbl));
        TDSSections.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text; VAR Reply: Boolean)
    begin
        Reply := true;
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
        Evaluate(eCessPercentage, Storage.Get(eCessPercentageLbl));
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
        TaxRates.AttributeValue13.SetValue(TDSThresholdAmount);
        TaxRates.AttributeValue14.SetValue(SurchargeThresholdAmount);
        TaxRates.AttributeValue15.SetValue(0.00);
        TaxRates.OK().Invoke();
    end;

    var
        Vendor: Record Vendor;
        LibraryTDS: Codeunit "Library-TDS";
        LibraryTDSOnCustomer: Codeunit "Library TDS On Customer";
        Assert: Codeunit Assert;
        TDSForCustomerSubscribers: Codeunit "TDS For Customer Subscribers";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        Storage: Dictionary of [Text, Text];
        IsForeignVendor: Boolean;
        NatureOfRemittanceLbl: Label 'NatureOfRemittance';
        ActApplicableLbl: Label 'ActApplicable';
        TemplateLbl: Label 'TemplateName';
        CountryCodeLbl: Label 'CountryCode';
        TDSPercentageLbl: Label 'TDSPercentage';
        SurchargePercentageLbl: Label 'SurchargePercentage';
        eCessPercentageLbl: Label 'eCessPercentage';
        NonPANTDSPercentageLbl: Label 'NonPANTDSPercentage';
        SHECessPercentageLbl: Label 'SHECessPercentage';
        TDSThresholdAmountLbl: Label 'TDSThresholdAmount';
        TDSAssesseeCodeLbl: Label 'TDSAssesseeCode';
        EffectiveDateLbl: Label 'EffectiveDate';
        TDSConcessionalCodeLbl: Label 'TDSConcessionalCode';
        SurchargeThresholdAmountLbl: Label 'SurchargeThresholdAmount';
        LocationCodeErr: Label 'T.A.N. No. must have a value in Company Information';
        SectionCodeLbl: Label 'SectionCode';
        GSTTDSIncErr: Label 'Please make TDS Section Code blank before selecting Include GST in TDS Base.';
        NonResidentPaymentsSelectionErr: Label 'Non Resident Payments is not selected for Vendor No. %1', Comment = '%1 is Vendor No.';
}