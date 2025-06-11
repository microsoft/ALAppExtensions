codeunit 18794 "TDS RegF On Purchases"
{

    Subtype = Test;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithItemWithPANWithoutConCodeRegF()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [400784] Check if system is allowing to calculate TDS on amount that is over & above threshold on Purchase Invoice for PAN Vendors when TDS Over & Above Threshold amount field is selected in the TDS rates.

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Invoice With PAN and Without Concessional Code
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Invoice,
            Vendor."No.", WorkDate(),
            PurchaseLine.Type::Item, false);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithItemWithPANWithoutConCodeRegF()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [400770] Check if system is allowing to calculate TDS on amount that is over & above threshold on Purchase Order for PAN Vendors when TDS Over & Above Threshold amount field is selected in the TDS rates.

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order With PAN and Without Concessional Code
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.", WorkDate(),
            PurchaseLine.Type::Item, false);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithItemWithoutPANWithoutConCodeRegF()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [400901] Check if system is allowing to calculate TDS on amount that is over & above threshold on Purchase Invoice for Non PAN Vendors when TDS Over & Above Threshold amount field is selected in the TDS rates.

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithoutConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Invoice Without PAN and Without Concessional Code
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Invoice,
            Vendor."No.", WorkDate(),
            PurchaseLine.Type::Item, false);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, false, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithItemWithoutPANWithoutConCodeRegF()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [400896] Check if system is allowing to calculate TDS on amount that is over & above threshold on Purchase Order for Non PAN Vendors when TDS Over & Above Threshold amount field is selected in the TDS rates.

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithoutConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order Without PAN and Without Concessional Code
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.", WorkDate(),
            PurchaseLine.Type::Item, false);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, false, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithItemWithoutPANWithConCodeRegF()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [400901] Check if system is allowing to calculate TDS on amount that is over & above threshold on Purchase Invoice for Non PAN Vendors when TDS Over & Above Threshold amount field is selected in the TDS rates.

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Created and Posted Purchase Invoice Without PAN and With Concessional Code
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Invoice,
            Vendor."No.", WorkDate(),
            PurchaseLine.Type::Item, false);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, false, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithItemWithPANWithConCodeRegF()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [400770] Check if system is allowing to calculate TDS on amount that is over & above threshold on Purchase Invoice for PAN Vendors when TDS Over & Above Threshold amount field is selected in the TDS rates.

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Created and Posted Purchase Invoice With PAN and With Concessional Code
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Invoice,
            Vendor."No.", WorkDate(),
            PurchaseLine.Type::Item, false);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckTDSAmountWhenPurhaseAmtLessThanThresholdAmt()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        Vendor: Record Vendor;
    begin
        // [SCENARIO] [400831] Check if system is calculating correct TDS amount when Purchase value of goods in last quarter is less than the Threshold amount.

        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created TDS Entry through TDS 194Q Opening Report with Threshold Amount greater than the Purchase Amount
        RunTDS194QOpeningReportWithPurchAmtLessThanThresholdAmt(Vendor."No.", Vendor."Assessee Code", TDSPostingSetup."TDS Section");

        // [THEN] TDS Entries Verified
        VerifyTDSEntryFor194QOpening(StorageCode.Get(DocumentNoLbl), TDSPostingSetup."TDS Section", Vendor."No.");
    end;

    local procedure RunTDS194QOpeningReportWithPurchAmtLessThanThresholdAmt(
        VendorNo: Code[20];
        AssesseeCode: Code[10];
        TDSSectionCode: Code[10])
    var
        SourceCodeSetup: Record "Source Code Setup";
        TDS194QOpening: Report "TDS 194Q Opening";
        DocumentNo: Code[20];
        PurchaseAmount: Decimal;
        TDSThresholdAmount: Decimal;
    begin
        SourceCodeSetup.Get();
        SourceCodeSetup."TDS Above Threshold Opening" := LibraryUtility.GenerateRandomCode(SourceCodeSetup.FieldNo("TDS Above Threshold Opening"), Database::"Source Code Setup");
        SourceCodeSetup.Modify(true);

        StorageCode.Set(TDSAboveThresholdOpeningLbl, SourceCodeSetup."TDS Above Threshold Opening");

        DocumentNo := 'OPENING123';
        StorageCode.Set(DocumentNoLbl, DocumentNo);

        PurchaseAmount := LibraryRandom.RandDecInRange(10000, 20000, 0);
        StorageDecimal.Set(PurchaseAmountLbl, PurchaseAmount);

        Evaluate(TDSThresholdAmount, Storage.Get(TDSThresholdAmountLbl));

        TDS194QOpening.InitializeRequest(VendorNo, AssesseeCode, TDSSectionCode, DocumentNo, WorkDate(), PurchaseAmount, TDSThresholdAmount);
        TDS194QOpening.UseRequestPage(false);
        TDS194QOpening.Run();
    end;

    local procedure CreateTaxRateSetup(TDSSection: Code[10]; AssesseeCode: Code[10]; ConcessionlCode: Code[10]; EffectiveDate: Date)
    var
        Section: Code[10];
        TDSAssesseeCode: Code[10];
        TDSConcessionlCode: Code[10];
    begin
        Section := TDSSection;
        Storage.Set(TDSSectionLbl, Section);
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

    procedure CreateAndPostPurchaseDocument(var PurchaseHeader: Record "Purchase Header";
        DocumentType: enum "Purchase Document Type";
        VendorNo: Code[20];
        PostingDate: Date;
        LineType: enum "Purchase Line Type";
        LineDiscount: Boolean): Code[20]
    var
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Modify(true);
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, LineType, LineDiscount);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true))
    end;

    local procedure CreatePurchaseLine(
        var PurchaseHeader: Record "Purchase Header";
        var PurchaseLine: Record "Purchase Line";
        Type: enum "Purchase Line Type"; LineDiscount: Boolean)
    begin
        InsertPurchaseLine(PurchaseLine, PurchaseHeader, Type);
        if LineDiscount then
            PurchaseLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));

        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(3000000, 4000000, 0));
        PurchaseLine.Modify(true);
    end;

    local procedure InsertPurchaseLine(
        var PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        LineType: Enum "Purchase Line Type")
    var
        RecordRef: RecordRef;
        TDSSectionCode: Code[10];
    begin
        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
        RecordRef.GetTable(PurchaseLine);
        PurchaseLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecordRef, PurchaseLine.FieldNo("Line No.")));
        PurchaseLine.Validate(Type, LineType);
        PurchaseLine.Validate("No.", GetLineTypeNo(LineType));
        PurchaseLine.Validate(Quantity, LibraryRandom.RandIntInRange(1, 10));
        TDSSectionCode := CopyStr(Storage.Get(TDSSectionLbl), 1, 10);
        PurchaseLine.Validate("TDS Section Code", TDSSectionCode);

        if IsForeignVendor then begin
            PurchaseLine.Validate("Nature of Remittance", Storage.Get(NatureOfRemittanceLbl));
            PurchaseLine.Validate("Act Applicable", Storage.Get(ActApplicableLbl));
        end;

        PurchaseLine.Insert(true);
    end;

    local procedure GetLineTypeNo(Type: Enum "Purchase Line Type"): Code[20]
    var
        PurchaseLine: Record "Purchase Line";
    begin
        case Type of
            PurchaseLine.Type::"G/L Account":
                exit(CreateGLAccountWithDirectPostingNoVAT());
            PurchaseLine.Type::Item:
                exit(CreateItemNoWithoutVAT());
            PurchaseLine.Type::"Fixed Asset":
                exit(CreateFixedAsset());
            PurchaseLine.Type::"Charge (Item)":
                exit(CreateChargeItemWithNoVAT());
        end;
    end;

    local procedure CreateItemNoWithoutVAT(): Code[20]
    var
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryTDS.CreateZeroVATPostingSetup(VATPostingSetup);
        Item.Get(LibraryInventory.CreateItemNoWithoutVAT());
        Item.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Item.Modify(true);
        exit(Item."No.");
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

    local procedure CreateChargeItemWithNoVAT(): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
        ItemCharge: Record "Item Charge";
    begin
        LibraryTDS.CreateZeroVATPostingSetup(VATPostingSetup);
        LibraryInventory.CreateItemCharge(ItemCharge);
        ItemCharge.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        ItemCharge.Modify(true);
        exit(ItemCharge."No.");
    end;

    local procedure CreateFixedAsset(): Code[20]
    var
        FixedAsset: Record "Fixed Asset";
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        FASetup: Record "FA Setup";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
    begin
        LibraryFixedAsset.CreateFAWithPostingGroup(FixedAsset);
        LibraryFixedAsset.CreateDepreciationBook(DepreciationBook);
        DepreciationBook.Validate("G/L Integration - Disposal", true);
        DepreciationBook.Validate("G/L Integration - Acq. Cost", true);
        DepreciationBook.Modify(true);
        LibraryFixedAsset.CreateFADepreciationBook(FADepreciationBook, FixedAsset."No.", DepreciationBook.Code);
        FADepreciationBook.Validate("FA Posting Group", FixedAsset."FA Posting Group");
        UpdateFAPostingGroupGLAccounts(FixedAsset."FA Posting Group");
        FADepreciationBook.Modify(true);
        FASetup.Get();
        FASetup.Validate("Default Depr. Book", DepreciationBook.Code);
        FASetup.Modify(true);
        exit(FixedAsset."No.")
    end;

    local procedure UpdateFAPostingGroupGLAccounts(FAPostingGroupCode: Code[20])
    var
        FAPostingGroup: Record "FA Posting Group";
    begin
        if FAPostingGroup.Get(FAPostingGroupCode) then begin
            FAPostingGroup.Validate("Acquisition Cost Account", CreateGLAccountWithDirectPostingNoVAT());
            FAPostingGroup.Validate("Acq. Cost Acc. on Disposal", CreateGLAccountWithDirectPostingNoVAT());
            FAPostingGroup.Validate("Accum. Depreciation Account", CreateGLAccountWithDirectPostingNoVAT());
            FAPostingGroup.Validate("Accum. Depr. Acc. on Disposal", CreateGLAccountWithDirectPostingNoVAT());
            FAPostingGroup.Validate("Depreciation Expense Acc.", CreateGLAccountWithDirectPostingNoVAT());
            FAPostingGroup.Validate("Gains Acc. on Disposal", CreateGLAccountWithDirectPostingNoVAT());
            FAPostingGroup.Validate("Losses Acc. on Disposal", CreateGLAccountWithDirectPostingNoVAT());
            FAPostingGroup.Validate("Sales Bal. Acc.", CreateGLAccountWithDirectPostingNoVAT());
            FAPostingGroup.Modify(true);
        end;
    end;

    local procedure GetBaseAmountForPurchase(DocumentNo: Code[20]): Decimal
    var
        PurchInvLine: Record "Purch. Inv. Line";
        TDSThresholdAmount: Decimal;
    begin
        PurchInvLine.SetRange("Document No.", DocumentNo);
        PurchInvLine.CalcSums(Amount);
        Evaluate(TDSThresholdAmount, Storage.Get(TDSThresholdAmountLbl));
        exit(PurchInvLine.Amount - TDSThresholdAmount);
    end;

    local procedure GetCurrencyFactorForPurchase(DocumentNo: Code[20]): Decimal
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        PurchInvHeader.SetRange("No.", DocumentNo);
        if PurchInvHeader.FindFirst() then
            exit(PurchInvHeader."Currency Factor");
    end;

    local procedure VerifyGLEntryCount(DocumentNo: Code[20]; ExpectedCount: Integer)
    var
        DummyGLEntry: Record "G/L Entry";
    begin
        DummyGLEntry.SetRange("Document No.", DocumentNo);
        Assert.RecordCount(DummyGLEntry, ExpectedCount);
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
        TDSPercentage, NonPANTDSPercentage, SurchargePercentage, eCessPercentage, SHECessPercentage, TDSBaseAmount : Decimal;
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
            TDSBaseAmount / CurrencyFactor, TDSEntry."TDS Base Amount", LibraryTDS.GetTDSRoundingPrecision(),
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
        Assert.AreNearlyEqual(
            TDSBaseAmount / CurrencyFactor, TDSEntry."TDS Line Amount", LibraryTDS.GetTDSRoundingPrecision(),
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("TDS Line Amount"), TDSEntry.TableCaption()));
    end;

    local procedure VerifyTDSEntryFor194QOpening(
        DocumentNo: Code[20];
        TDSSectionCode: Code[10];
        VendorNo: Code[20])
    var
        TDSEntry: Record "TDS Entry";
        CompanyInformation: Record "Company Information";
        Vendor: Record Vendor;
        TDSThresholdAmount: Decimal;
        TANNo: Code[10];
    begin
        TDSEntry.SetRange("Document No.", DocumentNo);
        TDSEntry.FindFirst();

        Vendor.Get(VendorNo);

        Evaluate(TDSThresholdAmount, Storage.Get(TDSThresholdAmountLbl));

        CompanyInformation.Get();
        TANNo := CompanyInformation."T.A.N. No.";

        Assert.AreEqual(
            VendorNo, TDSEntry."Vendor No.",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Vendor No."), TDSEntry.TableCaption()));
        Assert.AreEqual(
            TANNo, TDSEntry."T.A.N. No.",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("T.A.N. No."), TDSEntry.TableCaption()));
        Assert.AreEqual(
            UserId, TDSEntry."User ID",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("User ID"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            TDSSectionCode, TDSEntry.Section,
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName(Section), TDSEntry.TableCaption()));
        Assert.AreEqual(
            TDSEntry."Account Type"::Vendor, TDSEntry."Account Type",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Account Type"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            Vendor."Assessee Code", TDSEntry."Assessee Code",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName(Section), TDSEntry.TableCaption()));
        Assert.AreEqual(
            DocumentNo, TDSEntry."Document No.",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Document No."), TDSEntry.TableCaption()));
        Assert.AreEqual(
            StorageCode.Get(TDSAboveThresholdOpeningLbl), TDSEntry."Source Code",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Source Code"), TDSEntry.TableCaption()));
        if StorageDecimal.Get(PurchaseAmountLbl) < TDSThresholdAmount then
            Assert.AreEqual(
                StorageDecimal.Get(PurchaseAmountLbl), TDSEntry."Invoice Amount",
                StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Invoice Amount"), TDSEntry.TableCaption()))
        else
            Assert.AreEqual(
                TDSThresholdAmount, TDSEntry."Invoice Amount",
                StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Invoice Amount"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            Vendor."P.A.N. No.", TDSEntry."Deductee PAN No.",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Deductee PAN No."), TDSEntry.TableCaption()));
        Assert.AreEqual(
            StorageDecimal.Get(PurchaseAmountLbl), TDSEntry."TDS Base Amount",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("TDS Base Amount"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            TDSEntry."Document Type"::Invoice, TDSEntry."Document Type",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Document Type"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            true, TDSEntry."Over & Above Threshold Opening",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Over & Above Threshold Opening"), TDSEntry.TableCaption()));
    end;

    [ModalPageHandler]
    procedure TDSSectionHandler(var TDSSections: TestPage "TDS Sections")
    begin
        TDSSections.Filter.SetFilter(Code, Storage.Get(TDSSectionLbl));
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
        Evaluate(eCessPercentage, Storage.Get(ECessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));
        Evaluate(TDSThresholdAmount, Storage.Get(TDSThresholdAmountLbl));

        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(Storage.Get(TDSSectionLbl));
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

    [ModalPageHandler]
    procedure Statistics(var PurchaseStatistics: TestPage "Purchase Statistics")
    var
        Amt: Text;
    begin
        Amt := (PurchaseStatistics."TDS Amount".Value);
        Storage.Set(TDSAmountLbl, Amt);
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit assert;
        LibraryTDS: Codeunit "Library-TDS";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryInventory: Codeunit "Library - Inventory";
        Storage: Dictionary of [Text, Text];
        StorageCode: Dictionary of [Text, Code[20]];
        StorageDecimal: Dictionary of [Text, Decimal];
        IsForeignVendor: Boolean;
        EffectiveDateLbl: Label 'EffectiveDate', Locked = true;
        TDSPercentageLbl: Label 'TDSPercentage', Locked = true;
        NonPANTDSPercentageLbl: Label 'NonPANTDSPercentage', Locked = true;
        SurchargePercentageLbl: Label 'SurchargePercentage', Locked = true;
        ECessPercentageLbl: Label 'ECessPercentage', Locked = true;
        SHECessPercentageLbl: Label 'SHECessPercentage', Locked = true;
        TDSThresholdAmountLbl: Label 'TDSThresholdAmount', Locked = true;
        TDSSectionLbl: Label 'SectionCode', Locked = true;
        TDSAssesseeCodeLbl: Label 'TDSAssesseeCode', Locked = true;
        SurchargeThresholdAmountLbl: Label 'SurchargeThresholdAmount', Locked = true;
        TDSConcessionalCodeLbl: Label 'TDSConcessionalCode', Locked = true;
        NatureOfRemittanceLbl: Label 'NatureOfRemittance', Locked = true;
        ActApplicableLbl: Label 'ActApplicable', Locked = true;
        TDSAboveThresholdOpeningLbl: Label 'TDS Above Threshold Opening', Locked = true;
        CountryCodeLbl: Label 'CountryCode', Locked = true;
        PurchaseAmountLbl: Label 'PurchaseAmount', Locked = true;
        TDSAmountLbl: Label 'TDSAmount', Locked = true;
        DocumentNoLbl: Label 'DocumentNo', Locked = true;
        TDSEntryVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
}