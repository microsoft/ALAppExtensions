codeunit 18792 "TDS On Purchase Order"
{
    Subtype = Test;

    [Test]
    // [SCENARIO] Check if the program is copying purchase document with multiple TDS lines
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CopyFromPurchOrdWithItemWithMultipleline()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        ToPurchHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentType: Enum "Purchase Document Type";
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created Purchase Order with Multple Line
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Item,
            false);
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, false);

        // [THEN] Create new Purchase Document using copy document
        CreatePurchaseOrderFromCopyDocument(PurchaseHeader."No.", DocumentType::Order, Vendor."No.", ToPurchHeader);

        // [THEN] Validate No. of Purchase Line Count in both documents
        VerifyPurchaseLines(PurchaseHeader, ToPurchHeader);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353920] Check if the program is allowing the posting of Invoice with Item using the Purchase Order/Invoice with TDS information where T.A.N No. has not been defined.
    procedure PostFromPurchOrdwithItemWithoutTANNo()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithOutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Purchase Order with Item
        LibraryTDS.RemoveTANOnCompInfo();
        asserterror CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Item, false);

        // [THEN] Assert Error Verified
        Assert.ExpectedError(TANNoErr);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353919] Check if the program is allowing the posting of Invoice with Item using the Purchase Order/Invoice with TDS information where Accounting Period has not been specified.
    procedure PostFromPurchOrdwithItemWithoutAccountingPeriod()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithOutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order with G/L Account
        asserterror CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            CalcDate('<-1Y>', LibraryTDS.FindStartDateOnAccountingPeriod()),
            PurchaseLine.Type::Item,
            false);

        // [THEN] Assert Error Verified
        Assert.ExpectedError(IncomeTaxAccountingErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353754] Check if the program is calculating TDS in case an invoice is raised to the Vendor using Purchase Order.
    // [SCENARIO] [353923] Check if the program is calculating TDS on Lower rate/zero rate in case an invoice is raised to the Vendor is having a certificate using Purchase Order with Item & Fixed Assets
    procedure PostFromPurchOrdWithItemWithPANWithConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Craeted and Post Purchase Order with Item
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Item,
            false);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353995] Check if the program is calculating TDS while creating Invoice with Item using the Purchase Order/Invoice in case of different rates for same NOD with different effective dates.    
    procedure PostFromPurchOrdWithItemWithPANWithoutConCodeWithDifferentEffectiveDates()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overllok.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', CalcDate('<1M>', WorkDate()));
        LibraryTDS.CreateTDSPostingSetupWithDifferentEffectiveDate(TDSPostingSetup."TDS Section", CalcDate('<1M>', WorkDate()), TDSPostingSetup."TDS Account");

        // [WHEN] Created and Posted Purchase Order with Item 
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            CalcDate('<1M>', WorkDate()),
            PurchaseLine.Type::Item,
            false);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353994] Check if the program is calculating TDS while creating Invoice with G/L Account using the Purchase Order/Invoice in case of different rates for same NOD with different effective dates.    
    procedure PostFromPurchOrdWithGLAccWithPANWithoutConCodeWithDifferentEffectiveDates()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overllok.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', CalcDate('<1M>', WorkDate()));
        LibraryTDS.CreateTDSPostingSetupWithDifferentEffectiveDate(TDSPostingSetup."TDS Section", CalcDate('<1M>', WorkDate()), TDSPostingSetup."TDS Account");

        // [WHEN] Created and Posted Purchase Order with G/L Account
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            CalcDate('<1M>', WorkDate()),
            PurchaseLine.Type::"G/L Account",
            false);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353996] Check if the program is calculating TDS while creating Invoice with Fixed Asset using the Purchase Order/Invoice in case of different rates for same NOD with different effective dates.    
    procedure PostFromPurchOrdWithFAWithPANWithoutConCodeWithDifferentEffectiveDates()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overllok.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', CalcDate('<1M>', WorkDate()));
        LibraryTDS.CreateTDSPostingSetupWithDifferentEffectiveDate(TDSPostingSetup."TDS Section", CalcDate('<1M>', WorkDate()), TDSPostingSetup."TDS Account");

        // [WHEN] Created and Posted Purchase Order with Fixed Asset
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            CalcDate('<1M>', WorkDate()),
            PurchaseLine.Type::"Fixed Asset",
            false);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353997] Check if the program is calculating TDS while creating Invoice with Charge(Item) using the Purchase Order/Invoice in case of different rates for same NOD with different effective dates.    
    procedure PostFromPurchOrdWithChargeItemWithPANWithoutConCodeWithDifferentEffectiveDates()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overllok.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, CalcDate('<1M>', WorkDate()));
        LibraryTDS.CreateTDSPostingSetupWithDifferentEffectiveDate(TDSPostingSetup."TDS Section", CalcDate('<1M>', WorkDate()), TDSPostingSetup."TDS Account");

        // [WHEN] Create and and Post Purchase Invoice
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, Vendor."No.");
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, Purchaseline.Type::"Charge (Item)", false);
        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, PurchaseLine."No."));
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353995] Check if the program is calculating TDS while creating Invoice with Item using the Purchase Order/Invoice in case of different rates for same NOD with different effective dates.
    procedure PostFromPurchOrdWithItemWithPANWithConCodeWithDifferentEffectiveDates()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overllok.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Craeted and Posted Purchase Order
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Item,
            false);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353754] Check if the program is calculating TDS in case an invoice is raised to the Vendor using Purchase Order.
    procedure PostFromPurchOrdWithGLAccWithPANWithoutConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [THEN] Created and Posted purchase Order
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"G/L Account", false);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353964] Check if the program is calculating TDS in case an invoice is raised to the foreign Vendor using Purchase Order/Invoice and Threshold and Surcharge Overlook is selected with G/L Account.
    procedure PostFromPurchOrdofForeignVendorWithGLAccWithPANWithoutConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"G/L Account", false);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353962] Check if the program is calculating TDS in case an invoice is raised to the foreign Vendor using Purchase Order/Invoice and Threshold and Surcharge Overlook is selected with Item.
    procedure PostFromPurchOrdofForeignVendorWithItemIncludingSurchargeandThresholdOverlook()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order.
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Item, false);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified.
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353965] Check if the program is calculating TDS in case an invoice is raised to the foreign Vendor using Purchase Order/Invoice and Threshold and Surcharge Overlook is not selected with G/L Account.
    procedure PostFromPurchOrdWithGLAccWithoutThresholdandSurchargeOverlook()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order.
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"G/L Account", false);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified.
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, false, false);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353911] Check if the program is calculating TDS on higher rate in case an invoice is raised to the Vendor which is not having PAN No. using Purchase Order with G/L Account.
    procedure PostFromPurchOrdWithGLAccWithoutPANWithoutConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order.
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"G/L Account", false);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified.
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, false, true, true);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353911] Check if the program is calculating TDS on higher rate in case an invoice is raised to the Vendor which is not having PAN No. using Purchase Order with G/L Account
    // [SCENARIO] [353912] Check if the program is calculating TDS on Lower rate/zero rate in case an invoice is raised to the Vendor is having a certificate using Purchase Order with G/L Account.
    procedure PostFromPurchOrdWithGLAccWithoutPANWithConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Created and Posted Purchase Order
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"G/L Account", false);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, false, true, true);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353912] Check if the program is calculating TDS on Lower rate/zero rate in case an invoice is raised to the Vendor is having a certificate using Purchase Order with G/L Account.
    procedure PostFromPurchOrdWithGLAccWithPANWithConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Created and Posted Purchase Order.
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"G/L Account", false);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353902] Check if the program is allowing the posting of Invoice with G/L Account using the Purchase Order/Invoice with TDS information where T.A.N No. has not been defined.
    procedure PostFromPurchOrdWithGLAccWithoutTANNo()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Validated T.A.N. No. Verified
        LibraryTDS.RemoveTANOnCompInfo();

        // [THEN] Assert Error Verified
        asserterror CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"G/L Account", false);
        Assert.ExpectedError(TANNoErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353901] Check if the program is allowing the posting of Invoice with G/L Account using the Purchase Order/Invoice with TDS information where Accounting Period has not been specified.
    procedure PostFromPurchOrdWithGLAccWithoutAccountingPeriod()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and posted Purchase Invoice with G/L Account
        asserterror CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            CalcDate('<-1Y>', LibraryTDS.FindStartDateOnAccountingPeriod()),
            PurchaseLine.Type::"G/L Account",
            false);

        // [WHEN] Assert Error Verified
        Assert.ExpectedError(IncomeTaxAccountingErr);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353796] Check if the program is calculating TDS in case an invoice is raised to the Vendor using Purchase Order with Item.
    procedure PostFromPurchOrdwithItemWithPANWithoutConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order.
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Item, false);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353793] Check if the program is calculating TDS in case an invoice is raised to the Vendor using Purchase Order with Fixed Assets.
    procedure PostFromPurchOrdWithFAWithPANWithoutConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"Fixed Asset", false);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353931] Check if the program is calculating TDS on higher rate in case an invoice with Fixed Asset is raised to the Vendor which is not having PAN No. using Purchase Order.
    procedure PostFromPurchOrdWithFAithoutPANWithoutConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"Fixed Asset", false);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, false, true, true);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353931] Check if the program is calculating TDS on higher rate in case an invoice with Fixed Asset is raised to the Vendor which is not having PAN No. using Purchase Order.
    procedure PostFromPurchOrdWithFAWithoutPANWithConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Created and Posted Purchase
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"Fixed Asset", false);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, false, true, true);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353923] Check if the program is calculating TDS on Lower rate/zero rate in case an invoice is raised to the Vendor is having a certificate using Purchase Order with Item & Fixed Assets.
    procedure PostFromPurchOrdWithFAWithPANWithConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN]Created and Posted Purchase Order
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"Fixed Asset", false);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353928] Check if the program is allowing the posting of Invoice with Fixed Assets using the Purchase Order/Invoice with TDS information where T.A.N No. has not been defined.
    procedure PostFromPurchOrdWithFAWithoutTANNo()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Validated T.A.N. No. Verified
        LibraryTDS.RemoveTANOnCompInfo();

        // [THEN] Assert Error Verified
        asserterror CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"Fixed Asset", false);
        Assert.ExpectedError(TANNoErr);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353927] Check if the program is allowing the posting of Invoice with Fixed Assets using the Purchase Order/Invoice with TDS information where Accounting Period has not been specified.
    procedure PostFromPurchOrdWithFAWithoutAccountingPeriod()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Created and posted Purchase Invoice with G/L Account
        asserterror CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            CalcDate('<-1Y>', LibraryTDS.FindStartDateOnAccountingPeriod()),
            PurchaseLine.Type::"Fixed Asset",
            false);

        // [WHEN] Assert Error Verified
        Assert.ExpectedError(IncomeTaxAccountingErr);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353922] Check if the program is calculating TDS on higher rate in case an invoice is raised to the Vendor which is not having PAN No. using Purchase Order with Item.
    procedure PostFromPurchOrdwithItemWithoutPANWithoutConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Item, false);

        // [THEN]// [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, false, true, true);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353938] Check if the program is calculating TDS on higher rate in case an invoice is raised to the Vendor which is not having PAN No. using Purchase Order with Charge (Item)
    procedure PostFromPurchOrdwithChargeItemWithoutPANWithConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [GIVEN] Created Setup for Section, Assessee Code, Vendor, TDS Setup, Tax Accounting Period and TDS Rates.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and and Post Purchase Order with Charge Item
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, Vendor."No.");
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, Purchaseline.Type::"Charge (Item)", false);
        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, PurchaseLine."No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353939] Check if the program is calculating TDS on Lower rate/zero rate in case an invoice is raised to the Vendor is having a certificate using Purchase Order/Invoice with Charge (Item).
    procedure PostFromPurchOrdwithChargeItemWithPANWithConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [GIVEN] Created Setup for Section, Assessee Code, Vendor, TDS Setup, Tax Accounting Period and TDS Rates.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and and Post Purchase Order with Charge Item
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, Vendor."No.");
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, Purchaseline.Type::"Charge (Item)", false);
        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, PurchaseLine."No."));
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353935] Check if the program is allowing the posting of Invoice with Charge (Item) using the Purchase Order/Invoice with TDS information where T.A.N No. has not been defined.
    procedure PostFromPurchOrdwithChargeItemWithoutTANNo()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        /// [WHEN] Validated T.A.N. No. Verified
        LibraryTDS.RemoveTANOnCompInfo();

        // [THEN] Assert Error Verified
        asserterror CreateAndPostPurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"Charge (Item)", false);
        Assert.ExpectedError(TANNoErr);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353934] Check if the program is allowing the posting of Order with Charge (Item) using the Purchase Order/Invoice with TDS information where Accounting Period has been specified but Quarter for the period is not specified.
    procedure PostFromPurchOrdwithChargeItemWithoutAccountingPeriod()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and and Post Purchase Invoice with Multi Line
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, Vendor."No.");
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, Purchaseline.Type::"Charge (Item)", false);
        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Expected Error Verified
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, PurchaseLine."No."));
        ;
    end;

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the PurchaseOrderStatistics action. The new action uses RunObject and does not run the action trigger. Use a page extension to modify the behaviour.', '26.0')]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,PurchaseOrderStatsHandler')]
    procedure VerifyPurchaseOrderStatisticsWithItem()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [SCENARIO] [354032] Check if the program is showing TDS amount should be shown in Statistics while creating Purchase Order.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Item,
            false);

        // [THEN] Statistics Verified
        VerifyStatisticsForTDS(PurchaseHeader);
    end;
#endif

    [Test]
    [HandlerFunctions('TaxRatePageHandler,PurchOrderStatsHandler')]
    procedure VerifyPurchOrderStatisticsWithItem()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [SCENARIO] [354032] Check if the program is showing TDS amount should be shown in Statistics while creating Purchase Order.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Item,
            false);

        // [THEN] Statistics Verified
        VerifyStatsForTDS(PurchaseHeader);
    end;

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the PurchaseOrderStatistics action. The new action uses RunObject and does not run the action trigger. Use a page extension to modify the behaviour.', '26.0')]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,PurchaseOrderStatsHandler')]
    procedure VerifyPurchaseOrderStatisticsWithGLAccount()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [SCENARIO] [354032] Check if the program is showing TDS amount should be shown in Statistics while creating Purchase Order.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"G/L Account",
            false);

        // [THEN] Statistics Verified
        VerifyStatisticsForTDS(PurchaseHeader);
    end;
#endif

    [Test]
    [HandlerFunctions('TaxRatePageHandler,PurchOrderStatsHandler')]
    procedure VerifyPurchOrderStatisticsWithGLAccount()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [SCENARIO] [354032] Check if the program is showing TDS amount should be shown in Statistics while creating Purchase Order.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"G/L Account",
            false);

        // [THEN] Statistics Verified
        VerifyStatsForTDS(PurchaseHeader);
    end;

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the PurchaseOrderStatistics action. The new action uses RunObject and does not run the action trigger. Use a page extension to modify the behaviour.', '26.0')]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,PurchaseOrderStatsHandler')]
    procedure VerifyPurchaseOrderStatisticsWithFixedAsset()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [SCENARIO] [354032] Check if the program is showing TDS amount should be shown in Statistics while creating Purchase Order.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created  Purchase Order
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"Fixed Asset",
            false);

        // [THEN] StatistiCS Verified
        VerifyStatisticsForTDS(PurchaseHeader);
    end;
#endif

    [Test]
    [HandlerFunctions('TaxRatePageHandler,PurchOrderStatsHandler')]
    procedure VerifyPurchOrderStatisticsWithFixedAsset()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [SCENARIO] [354032] Check if the program is showing TDS amount should be shown in Statistics while creating Purchase Order.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created  Purchase Order
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"Fixed Asset",
            false);

        // [THEN] StatistiCS Verified
        VerifyStatsForTDS(PurchaseHeader);
    end;

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the PurchaseOrderStatistics action. The new action uses RunObject and does not run the action trigger. Use a page extension to modify the behaviour.', '26.0')]
    [Test]
    [HandlerFunctions('TaxRatePageHandler,PurchaseOrderStatsHandler')]
    procedure VerifyPurchaseOrderStatisticsWithChargeItem()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [SCENARIO] [354032] Check if the program is showing TDS amount should be shown in Statistics while creating Purchase Order.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Purchase Order Created
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"Charge (Item)",
            false);

        // [THEN] Statistics Verified
        VerifyStatisticsForTDS(PurchaseHeader);
    end;
#endif

    [Test]
    [HandlerFunctions('TaxRatePageHandler,PurchOrderStatsHandler')]
    procedure VerifyPurchOrderStatisticsWithChargeItem()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [SCENARIO] [354032] Check if the program is showing TDS amount should be shown in Statistics while creating Purchase Order.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Purchase Order Created
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"Charge (Item)",
            false);

        // [THEN] Statistics Verified
        VerifyStatsForTDS(PurchaseHeader);
    end;

    [Test]
    // [SCENARIO] [354242] Check if the program is calculating TDS in case an invoice is raised to the foreign Vendor using Purchase Order/Invoice and Surcharge Overlook is selected with Item.
    // [SCENARIO] [353962] Check if the program is calculating TDS in case an invoice is raised to the foreign Vendor using Purchase Order/Invoice and Threshold and Surcharge Overlook is selected with Item.
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromForeignVendorPurchOrdwithItemWithPANWithoutConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        TDSNatureOfRemittance: Record "TDS Nature of Remittance";
        TDSActApplicable: Record "Act Applicable";
        DocumentNo: Code[20];
    begin
        IsForeignVendor := true;
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        LibraryTDS.CreateForeignVendorWithPANNoandWithoutConcessional(Vendor);
        LibraryTDS.CreateNatureOfRemittance(TDSNatureOfRemittance);
        LibraryTDS.CreateActApplicable(TDSActApplicable);
        LibraryTDS.AttachSectionWithForeignVendor(TDSPostingSetup."TDS Section", Vendor."No.", true, true, true, true, TDSNatureOfRemittance.Code, TDSActApplicable.Code);
        Storage.Set(NatureOfRemittanceLbl, TDSNatureOfRemittance.Code);
        Storage.Set(ActApplicableLbl, TDSActApplicable.Code);
        Storage.Set(CountryCodeLbl, Vendor."Country/Region Code");

        // [WHEN] Created and Posted Foreign Vendor Purchase Invoice
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Item, false);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
        IsForeignVendor := false;
        ;
    end;

    [Test]
    // [SCENARIO] [354240] Check if the program is calculating TDS in case an invoice with Fixed Asset is raised to the foreign Vendor using Purchase Order and Surcharge Overlook is selected.

    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromForeignVendorPurchOrdWithFAWithPANWithoutConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        TDSNatureOfRemittance: Record "TDS Nature of Remittance";
        TDSActApplicable: Record "Act Applicable";
        DocumentNo: Code[20];
    begin
        IsForeignVendor := true;
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        LibraryTDS.CreateForeignVendorWithPANNoandWithoutConcessional(Vendor);
        LibraryTDS.CreateNatureOfRemittance(TDSNatureOfRemittance);
        LibraryTDS.CreateActApplicable(TDSActApplicable);
        LibraryTDS.AttachSectionWithForeignVendor(TDSPostingSetup."TDS Section", Vendor."No.", true, true, true, true, TDSNatureOfRemittance.Code, TDSActApplicable.Code);
        Storage.Set(NatureOfRemittanceLbl, TDSNatureOfRemittance.Code);
        Storage.Set(ActApplicableLbl, TDSActApplicable.Code);
        Storage.Set(CountryCodeLbl, Vendor."Country/Region Code");

        // [WHEN] Created and Posted Foreign Vendor Purchase Invoice
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"Fixed Asset", false);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
        IsForeignVendor := false;
    end;

    [Test]
    // [SCENARIO] [353950] Check if the program is calculating TDS while creating Invoice with G/L Account using the Purchase Order in case of Foreign Vendor.

    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromForeignVendorPurchOrdWithGLAccWithPANWithoutConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        TDSNatureOfRemittance: Record "TDS Nature of Remittance";
        TDSActApplicable: Record "Act Applicable";
        DocumentNo: Code[20];
    begin
        IsForeignVendor := true;
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        LibraryTDS.CreateForeignVendorWithPANNoandWithoutConcessional(Vendor);
        LibraryTDS.CreateNatureOfRemittance(TDSNatureOfRemittance);
        LibraryTDS.CreateActApplicable(TDSActApplicable);
        LibraryTDS.AttachSectionWithForeignVendor(TDSPostingSetup."TDS Section", Vendor."No.", true, true, true, true, TDSNatureOfRemittance.Code, TDSActApplicable.Code);
        Storage.Set(NatureOfRemittanceLbl, TDSNatureOfRemittance.Code);
        Storage.Set(ActApplicableLbl, TDSActApplicable.Code);
        Storage.Set(CountryCodeLbl, Vendor."Country/Region Code");

        // [WHEN] Created and Posted Foreign Vendor Purchase Order
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"G/L Account", false);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
        IsForeignVendor := false;
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [354030] Check if the program is calculating TDS using Purchase Order where TDS is applicable only on selected lines.
    procedure PostFromPurchOrdWithTDSApplicableOnSelectedLines()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        TDSSection2: Record "TDS Section";
        TDSPostingSetup2: Record "TDS Posting Setup";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.CreateTDSPostingSetupForMultipleSection(TDSPostingSetup2, TDSSection2);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        CreateTaxRateSetup(TDSPostingSetup2."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Invoice with Multple Line
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"G/L Account",
            false);
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, false);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 5);
    end;

    [Test]
    // [SCENARIO] [353906] Check if the program is calculating TDS while creating Invoice with G/L Account using the Purchase Order/Invoice with multiple NOD.

    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithGLAccWithMultipleline()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Invoice with Multple Line
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"G/L Account",
            false);
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::"G/L Account", false);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 4);
    end;

    [Test]
    // [SCENARIO] [354040] Check if the program is calculating TDS while creating Invoice with Item using the Purchase Order/Invoice with multiple NOD.
    // [SCENARIO] [353940] Check if the program is calculating TDS while creating Invoice with Item using the Purchase Invoice with multiple NOD..
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithItemWithMultipleline()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Invoice with Multple Line
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Item,
            false);
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, false);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353937] Check if the program is calculating TDS while creating Invoice with Charge(Item) using the Purchase Order/Invoice with multiple NOD.
    procedure PostFromPurchOrdWithChargeItemWithMultipleline()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and and Post Purchase Invoice with Multi Line
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, Vendor."No.");
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, Purchaseline.Type::"Charge (Item)", false);
        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, PurchaseLine."No."));
    end;

    [Test]
    // [SCENARIO] [353941] Check if the program is calculating TDS while creating Invoice with Fixed Asset using the Purchase Order/Invoice with multiple NOD.

    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithFAWithMultipleline()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Invoice with Multple Line
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"Fixed Asset",
            false);
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::"Fixed Asset", false);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 4);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [354021] Check if the program is calculating TDS using Purchase Order in case of Line Discount.
    procedure PostFromPurchOrdWithGLandLineDiscount()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [THEN] Created and Posted purchase Invoice
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"G/L Account",
            true);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 4);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorInvoiceDiscountPageHandler')]
    // [SCENARIO] [354024] Check if the program is calculating TDS using Purchase Order in case of Invoice Discount.
    procedure PostFromPurchOrdWithGLandInvoiceDiscount()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        CreateVendorInvoiceDiscount(Vendor."No.");

        // [THEN] Created and Posted Purchase Invoice with Invoice Discount
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"G/L Account",
            false);
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindFirst() then begin
            PurchaseLine.Validate("Allow Invoice Disc.", true);
            PurchaseLine.Modify(true);
            PurchaseCalcDiscount.Run(PurchaseLine);
            PurchaseLine.Validate("Direct Unit Cost");
        end;
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 4);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler,VendorInvoiceDiscountPageHandler')]
    // [SCENARIO] [354024] Check if the program is calculating TDS using Purchase Order in case of Invoice Discount.
    procedure PostFromPurchOrdWithItemAndInvoiceDiscount()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        CreateVendorInvoiceDiscount(Vendor."No.");

        // [THEN] Created and Posted Purchase Invoice with Invoice Discount
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Item,
            false);
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindFirst() then begin
            PurchaseLine.Validate("Allow Invoice Disc.", true);
            PurchaseLine.Modify(true);
            PurchaseCalcDiscount.Run(PurchaseLine);
            PurchaseLine.Validate("Direct Unit Cost");
        end;
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 4);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler,VendorInvoiceDiscountPageHandler')]
    // [SCENARIO] [354024] Check if the program is calculating TDS using Purchase Order in case of Invoice Discount.
    procedure PostFromPurchOrdWithFAAndInvoiceDiscount()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        CreateVendorInvoiceDiscount(Vendor."No.");

        // [THEN] Created and Posted Purchase Invoice with Invoice Discount
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"Fixed Asset",
            false);
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindFirst() then begin
            PurchaseLine.Validate("Allow Invoice Disc.", true);
            PurchaseLine.Modify(true);
            PurchaseCalcDiscount.Run(PurchaseLine);
            PurchaseLine.Validate("Direct Unit Cost");
        end;
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 4);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler,VendorInvoiceDiscountPageHandler')]
    // [SCENARIO] [354024] Check if the program is calculating TDS using Purchase Order in case of Invoice Discount.
    procedure PostFromPurchOrdWithChargeItemAndInvoiceDiscount()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        CreateVendorInvoiceDiscount(Vendor."No.");

        // [THEN] Created and Purchase Invoice with Invoice Discount
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, Vendor."No.");
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, Purchaseline.Type::"Charge (Item)", false);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindFirst() then begin
            PurchaseLine.Validate("Allow Invoice Disc.", true);
            PurchaseLine.Modify(true);
            PurchaseCalcDiscount.Run(PurchaseLine);
            PurchaseLine.Validate("Direct Unit Cost");
        end;
        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Expected Error Verified
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, PurchaseLine."No."));
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353953] Check if the program is calculating TDS in Purchase Order/Invoice with no threshold and surcharge overlook for NOD lines of a particular Vendor with G/L Account.
    procedure PostFromPurchOrdWithGLWithoutThresholdandSurchargeOverlook()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithOutConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order with G/L Account
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"G/L Account",
            false);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, false, false);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353966] Check if the program is calculating TDS while creating Invoice with Item using the Purchase Order/Invoice with no threshold and surcharge overlook for NOD lines of a particular Vendor.
    procedure PostFromPurchOrdWithItemWithoutThresholdandandSurchargeOverlook()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithOutConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order with Item
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Item,
            false);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, false, false);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353953] Check if the program is calculating TDS in Purchase Order/Invoice with no threshold and surcharge overlook for NOD lines of a particular Vendor with G/L Account.
    procedure PostFromPurchOrdWithFAWithoutThresholdandSurchargeOverlook()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithOutConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Created and Posted Purchase Order with Fixed Asset
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::"Fixed Asset",
            false);

        // [THEN] // [THEN] G/L Entries and TDS Entries Verified
        VerifyGLEntryCount(DocumentNo, 3);
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, false, false);
    end;

    [Test]

    [HandlerFunctions('TaxRatePageHandler')]
    // [SCENARIO] [353956] Check if the program is calculating TDS while creating Invoice with Charge (Item) using the Purchase Order/Invoice with no threshold and surcharge overlook for NOD lines of a particular Vendor.
    procedure PostFromPurchOrdwithChargeItemWithoutSurchargeandThresholdOverlook()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [GIVEN] Created Setup for Section, Assessee Code, Vendor, TDS Setup, Tax Accounting Period and TDS Rates.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and and Post Purchase Order with Charge Item
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, Vendor."No.");
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, Purchaseline.Type::"Charge (Item)", false);
        asserterror LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Expected Error: Charge Item not Assigned
        Assert.ExpectedError(StrSubstNo(ChargeItemErr, PurchaseLine."No."));
    end;

    local procedure CreateVendorInvoiceDiscount(VendorNo: Code[20])
    var
        VendorTestPage: TestPage "Vendor Card";
    begin
        VendorTestPage.OpenEdit();
        VendorTestPage.Filter.SetFilter("No.", VendorNo);
        VendorTestPage."Invoice &Discounts".Invoke();
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

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the PurchaseOrderStatistics action. The new action uses RunObject and does not run the action trigger. Use a page extension to modify the behaviour.', '26.0')]
    local procedure VerifyStatisticsForTDS(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        TaxTransactionValue: Record "Tax Transaction Value";
        TDSSetup: Record "TDS Setup";
        PurchaseOrderStatistics: TestPage "Purchase Order Statistics";
        PurchaseOrder: TestPage "Purchase Order List";
        RecordIDList: List of [RecordID];
        i: Integer;
        ActualAmount: Decimal;
    begin
        Clear(ExpectedTDSAmount);
        if not TDSSetup.Get() then
            exit;
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document no.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                RecordIDList.Add(PurchaseLine.RecordId());
            until PurchaseLine.Next() = 0;

        for i := 1 to RecordIDList.Count() do begin
            TaxTransactionValue.SetRange("Tax Record ID", RecordIDList.Get(i));
            TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
            TaxTransactionValue.SetRange("Tax Type", TDSSetup."Tax Type");
            TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
            if not TaxTransactionValue.IsEmpty() then
                TaxTransactionValue.CalcSums(Amount);
            ExpectedTDSAmount += TaxTransactionValue.Amount;
        end;
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchaseHeader);
        PurchaseOrderStatistics.OpenEdit();
        PurchaseOrder.Statistics.Invoke();
        PurchaseOrder.Statistics.Invoke();
        Evaluate(ActualAmount, Storage.Get(TDSAmountLbl));
        Assert.AreNearlyEqual(Round(ExpectedTDSAmount, 0.01, '='), ActualAmount, LibraryTDS.GetTDSRoundingPrecision(),
        StrSubstNo(AmountErr, ActualAmount, PurchaseOrderStatistics."TDS Amount".Caption()));
    end;
#endif

    local procedure VerifyStatsForTDS(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        TaxTransactionValue: Record "Tax Transaction Value";
        TDSSetup: Record "TDS Setup";
        PurchaseOrderStatistics: TestPage "Purchase Order Statistics";
        PurchaseOrder: TestPage "Purchase Order List";
        RecordIDList: List of [RecordID];
        i: Integer;
        ActualAmount: Decimal;
    begin
        Clear(ExpectedTDSAmount);
        if not TDSSetup.Get() then
            exit;
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document no.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                RecordIDList.Add(PurchaseLine.RecordId());
            until PurchaseLine.Next() = 0;

        for i := 1 to RecordIDList.Count() do begin
            TaxTransactionValue.SetRange("Tax Record ID", RecordIDList.Get(i));
            TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
            TaxTransactionValue.SetRange("Tax Type", TDSSetup."Tax Type");
            TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
            if not TaxTransactionValue.IsEmpty() then
                TaxTransactionValue.CalcSums(Amount);
            ExpectedTDSAmount += TaxTransactionValue.Amount;
        end;
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchaseHeader);
        PurchaseOrderStatistics.OpenEdit();
        PurchaseOrder.PurchaseOrderStatistics.Invoke();
        PurchaseOrder.PurchaseOrderStatistics.Invoke();
        Evaluate(ActualAmount, Storage.Get(TDSAmountLbl));
        Assert.AreNearlyEqual(Round(ExpectedTDSAmount, 0.01, '='), ActualAmount, LibraryTDS.GetTDSRoundingPrecision(),
        StrSubstNo(AmountErr, ActualAmount, PurchaseOrderStatistics."TDS Amount".Caption()));
    end;

    local procedure CreatePurchaseDocument(
        var PurchaseHeader: Record "Purchase Header";
        DocumentType: enum "Purchase Document Type";
        VendorNo: Code[20];
        PostingDate: Date;
        LineType: enum "Purchase Line Type";
        LineDiscount: Boolean)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Modify(true);
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, LineType, LineDiscount);
    end;

    procedure CreateAndPostPurchaseDocument(var PurchaseHeader: Record "Purchase Header";
        DocumentType: enum "Purchase Document Type";
        VendorNo: Code[20];
        PostingDate: Date;
        LineType: enum "Purchase Line Type"; LineDiscount: Boolean): Code[20]
    var
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Modify(true);
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, LineType, LineDiscount);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true))
    end;

    local procedure CreatePurchaseLine(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line";
    Type: enum "Purchase Line Type"; LineDiscount: Boolean)
    begin
        InsertPurchaseLine(PurchaseLine, PurchaseHeader, Type);
        if LineDiscount then
            PurchaseLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));

        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInDecimalRange(1000, 1001, 0));
        PurchaseLine.Modify(true);
    end;

    local procedure InsertPurchaseLine(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: record "Purchase Header"; LineType: enum "Purchase Line Type")
    var
        RecRef: RecordRef;
        TDSSectionCode: Code[10];
    begin
        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
        RecRef.GetTable(PurchaseLine);
        PurchaseLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, PurchaseLine.FieldNo("Line No.")));
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

    local procedure GetLineTypeNo(Type: enum "Purchase Line Type"): Code[20]
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
        item.GET(LibraryInventory.CreateItemNoWithoutVAT());
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
        ItemCharge: Record "Item Charge";
        VATPostingSetup: Record "VAT Posting Setup";
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
        PurchaseInvoiceLine: Record "Purch. Inv. Line";
    begin
        PurchaseInvoiceLine.SetRange("Document No.", DocumentNo);
        PurchaseInvoiceLine.CalcSums(Amount);
        exit(PurchaseInvoiceLine.Amount);
    end;

    local procedure GetCurrencyFactorForPurchase(DocumentNo: Code[20]): Decimal
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        PurchInvHeader.SetRange("No.", DocumentNo);
        if PurchInvHeader.FindFirst() then
            exit(PurchInvHeader."Currency Factor");
    end;

    local procedure VerifyTDSEntry(DocumentNo: Code[20]; WithPAN: Boolean; SurchargeOverlook: Boolean; TDSThresholdOverlook: Boolean)
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
        CurrencyFactor: Decimal;
        TDSBaseAmount: Decimal;
        SurchargeThresholdAmount: Decimal;
    begin
        Evaluate(TDSPercentage, Storage.Get(TDSPercentageLbl));
        Evaluate(NonPANTDSPercentage, Storage.Get(NonPANTDSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(ECessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(TDSThresholdAmount, Storage.Get(TDSThresholdAmountLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));

        TDSBaseAmount := GetBaseAmountForPurchase(DocumentNo);
        CurrencyFactor := GetCurrencyFactorForPurchase(DocumentNo);

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

    local procedure CreatePurchaseOrderFromCopyDocument(FromDocNo: Code[20]; DocumentType: Enum "Purchase Document Type"; VendorNo: Code[20]; var ToPurchHeader: Record "Purchase Header")
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
        FromDocType: Enum "Purchase Document Type From";
    begin
        LibraryPurchase.CreatePurchHeader(ToPurchHeader, DocumentType, VendorNo);
        ToPurchHeader.Validate("Posting Date", WorkDate());
        ToPurchHeader.Modify(true);

        CopyDocumentMgt.SetProperties(true, false, false, false, true, false, false);
        CopyDocumentMgt.CopyPurchDoc(FromDocType::Order, FromDocNo, ToPurchHeader);
    end;

    local procedure VerifyPurchaseLines(FromPurchaseHeader: Record "Purchase Header"; ToPurchaseHeader: Record "Purchase Header")
    var
        FromPurchaseLine: Record "Purchase Line";
        ToPurchaseLine: Record "Purchase Line";
        ExpectedCount: Integer;
    begin
        FromPurchaseLine.SetRange("Document Type", FromPurchaseHeader."Document Type");
        FromPurchaseLine.SetRange("Document No.", FromPurchaseHeader."No.");
        if FromPurchaseLine.FindSet() then
            ExpectedCount := FromPurchaseLine.Count;

        ToPurchaseLine.SetRange("Document Type", ToPurchaseHeader."Document Type");
        ToPurchaseLine.SetRange("Document No.", ToPurchaseHeader."No.");
        Assert.RecordCount(ToPurchaseLine, ExpectedCount);
    end;

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the PurchaseOrderStatistics action. The new action uses RunObject and does not run the action trigger. Use a page extension to modify the behaviour.', '26.0')]
    [ModalPageHandler]
    procedure PurchaseOrderStatsHandler(var PurchaseOrderStatistics: TestPage "Purchase Order Statistics")
    var
        Amt: Text;
    begin
        Amt := PurchaseOrderStatistics."TDS Amount".Value;
        Storage.Set(TDSAmountLbl, Amt);
    end;
#endif

    [PageHandler]
    procedure PurchOrderStatsHandler(var PurchaseOrderStatistics: TestPage "Purchase Order Statistics")
    var
        Amt: Text;
    begin
        Amt := PurchaseOrderStatistics."TDS Amount".Value;
        Storage.Set(TDSAmountLbl, Amt);
    end;

    [PageHandler]
    procedure VendorInvoiceDiscountPageHandler(var VendInvDisc: TestPage "Vend. Invoice Discounts");
    begin
        VendInvDisc."Discount %".SetValue(LibraryRandom.RandIntInRange(1, 4));
        VendInvDisc.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text; VAR Reply: Boolean)
    begin
        Reply := true;
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
        TaxRate.AttributeValue1.SetValue(Storage.Get(TDSSectionLbl));
        TaxRate.AttributeValue2.SetValue(Storage.Get(TDSAssesseeCodeLbl));
        TaxRate.AttributeValue3.SetValue(EffectiveDate);
        TaxRate.AttributeValue4.SetValue(Storage.Get(TDSConcessionalCodeLbl));
        if IsForeignVendor then begin
            TaxRate.AttributeValue5.SetValue(Storage.Get(NatureOfRemittanceLbl));
            TaxRate.AttributeValue6.SetValue(Storage.Get(ActApplicableLbl));
            TaxRate.AttributeValue7.SetValue(Storage.Get(CountryCodeLbl))
        end else begin
            TaxRate.AttributeValue5.SetValue('');
            TaxRate.AttributeValue6.SetValue('');
            TaxRate.AttributeValue7.SetValue('');
        end;
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
        LibraryERM: codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryTDS: Codeunit "Library-TDS";
        Assert: Codeunit Assert;
        LibraryPurchase: Codeunit "Library - Purchase";
        PurchaseCalcDiscount: Codeunit "Purch.-Calc.Discount";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        Storage: Dictionary of [Text, Text];
        ExpectedTDSAmount: Decimal;
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
        CountryCodeLbl: Label 'CountryCode', Locked = true;
        TDSAmountLbl: Label 'TDSAmount', locked = true;
        TANNoErr: Label 'T.A.N. No. must have a value in Company Information', locked = true;
        IncomeTaxAccountingErr: Label 'The Posting Date doesn''t lie in Tax Accounting Period', Locked = true;
        ChargeItemErr: Label 'You must assign item charge %1 if you want to invoice it.', Comment = '%1= No.';
        AmountErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = TCS Amount and TCS field Caption';
}