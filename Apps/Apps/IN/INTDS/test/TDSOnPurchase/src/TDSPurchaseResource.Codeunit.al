codeunit 18793 "TDS Purchase Resource"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvwithResourceWithoutTANNo()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [SCENARIO] [376610] Check if the program is allowing the posting of Invoice with Resource using the Purchase Order/Invoice with TDS information where T.A.N No. has not been defined.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithOutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Validated T.A.N. No. Verified
        LibraryTDS.RemoveTANOnCompInfo();

        // [THEN] Assert Error Verified
        asserterror CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Invoice,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            false);
        Assert.ExpectedError(TANNoErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvwithResourceWithoutAccountingPeriod()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [SCENARIO] [376609] Check if the program is allowing the posting of Invoice with Resource using the Purchase Order/Invoice with TDS information where Accounting Period has not been specified.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithOutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Purchase Invoice with Resource without Accounting Period
        asserterror CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Invoice,
            Vendor."No.",
            CalcDate('<-1Y>', LibraryTDS.FindStartDateOnAccountingPeriod()),
            PurchaseLine.Type::Resource,
            false);

        // [WHEN] Expected Error Verified
        Assert.ExpectedError(IncomeTaxAccountingErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrderWithResourceWithPANWithConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376674] Check if the program is calculating TDS on Lower rate/zero rate in case an invoice is raised to the Vendor is having a certificate using Purchase Order with Resource
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Purchase Order with Resource
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            false);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrderWithResourceWithoutPANWithConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376664] Check if the program is calculating TDS on higher rate in case an invoice is raised to the Vendor which is not having PAN No. using Purchase Order with Resource.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Purchase Order with Resource
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            false);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, false, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithResourceWithoutPANWithConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376668] Check if the program is calculating TDS on higher rate in case an invoice is raised to the Vendor which is not having PAN No. using Purchase Invoice with Resource.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Purchase Invoice with Resource
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Invoice,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            false);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, false, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithResourceandLineDiscount()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376680] Check if the program is calculating TDS using Purchase Order in case of Line Discount with Resources.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Purchase Order with Resource with Line Discount
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            true);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithResourceandLineDiscount()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376682] Check if the program is calculating TDS using Purchase Invoice in case of Line Discount with Resources.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Purchase Invoice with Resource with Line Discount
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Invoice,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            true);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithResourceWithPANWithConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376678] Check if the program is calculating TDS on Lower rate/zero rate in case an invoice is raised to the Vendor is having a certificate using Purchase Invoice with Resource.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post Purchase Invoice with Resource
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Invoice,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            false);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,InvoiceDiscountPageHandler')]
    procedure PostFromPurchOrdWithResourceInvDiscount()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        PurchCalcDiscount: Codeunit "Purch.-Calc.Discount";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376684] Check if the program is calculating TDS using Purchase Order in case of Invoice Discount with Resources.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        CreateVendorInvoiceDiscount(Vendor."No.");

        // [WHEN] Create and Post Purchase Order with Invoice Discount
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            false);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindFirst() then begin
            PurchaseLine.Validate("Allow Invoice Disc.", true);
            PurchaseLine.Modify(true);
            PurchCalcDiscount.Run(PurchaseLine);
        end;

        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,InvoiceDiscountPageHandler')]
    procedure PostFromPurchInvWithResourceInvDiscount()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        PurchCalcDiscount: Codeunit "Purch.-Calc.Discount";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376689] Check if the program is calculating TDS using Purchase Invoice in case of Invoice Discount with Resources.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        CreateVendorInvoiceDiscount(Vendor."No.");

        // [WHEN] Create and Post Purchase Invoice with Invoice Discount
        CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Invoice,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            false);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindFirst() then begin
            PurchaseLine.Validate("Allow Invoice Disc.", true);
            PurchaseLine.Modify(true);
            PurchCalcDiscount.Run(PurchaseLine);
        end;

        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithResourceWithMultipleNOD()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376658] Check if the program is calculating TDS while creating Invoice with Resource using the Purchase Order with multiple NOD.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Purchase Order with Resource Multiple Line
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            false);
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Resource, false);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithResourceWithMultipleNOD()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376663] Check if the program is calculating TDS while creating Invoice with Resource using the Purchase Invoice with multiple NOD.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Purchase Invoice with Resource Multiple Line
        CreatePurchaseDocument(PurchaseHeader,
            PurchaseHeader."Document Type"::Invoice,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            false);
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Resource, false);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithResourceWithDifferentEffectiveDates()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376880] Check if the program is calculating TDS while creating Invoice with Resource using the Purchase Order in case of different rates for same NOD with different effective dates.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', CalcDate('<1D>', WorkDate()));
        LibraryTDS.CreateTDSPostingSetupWithDifferentEffectiveDate(
            TDSPostingSetup."TDS Section",
            CalcDate('<1D>', WorkDate()),
            TDSPostingSetup."TDS Account");

        // [WHEN] Create and Post Purchase Order with different effective dates
        CreatePurchaseDocument(PurchaseHeader,
               PurchaseHeader."Document Type"::Order,
               Vendor."No.",
               CalcDate('<1D>', WorkDate()),
               PurchaseLine.Type::Resource,
               false);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithResourceWithDifferentEffectiveDates()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376865] Check if the program is calculating TDS while creating Invoice with Resource using the Purchase Invoice in case of different rates for same NOD with different effective dates.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', CalcDate('<1D>', WorkDate()));
        LibraryTDS.CreateTDSPostingSetupWithDifferentEffectiveDate(
            TDSPostingSetup."TDS Section",
            CalcDate('<1D>', WorkDate()),
            TDSPostingSetup."TDS Account");

        // [WHEN] Create and Post Purchase Invoice with different effective dates
        CreatePurchaseDocument(PurchaseHeader,
               PurchaseHeader."Document Type"::Invoice,
               Vendor."No.",
               CalcDate('<1D>', WorkDate()),
               PurchaseLine.Type::Resource,
               false);
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithResourceWithoutThresholdandSurcharge()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376819] Check if the program is calculating TDS while creating Invoice with Resource using the Purchase Order with no threshold and surcharge overlook for NOD lines of a particular Vendor.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Purchase Order with Resource without threshold and surcharge overlook
        DocumentNo := CreateAndPostPurchaseDocument(
             PurchaseHeader,
             PurchaseHeader."Document Type"::Order,
             Vendor."No.",
             WorkDate(),
             PurchaseLine.Type::Resource,
             false);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithResourceWithoutThresholdandSurcharge()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376837] Check if the program is calculating TDS while creating Invoice with Resource using the Purchase Invoice with no threshold and surcharge overlook for NOD lines of a particular Vendor.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Purchase Invoice with Resource without threshold and surcharge overlook
        DocumentNo := CreateAndPostPurchaseDocument(
             PurchaseHeader,
             PurchaseHeader."Document Type"::Invoice,
             Vendor."No.",
             WorkDate(),
             PurchaseLine.Type::Resource, false);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdofForeignVendorWithResWithPANWithoutConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TDSNatureOfRemittance: Record "TDS Nature of Remittance";
        TDSActApplicable: Record "Act Applicable";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376807] Check if the program is calculating TDS in case an invoice is raised to the foreign Vendor using Purchase Order and Surcharge Overlook is selected with Resources.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        IsForeignVendor := true;
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        LibraryTDS.CreateForeignVendorWithPANNoandWithoutConcessional(Vendor);
        LibraryTDS.CreateNatureOfRemittance(TDSNatureOfRemittance);
        LibraryTDS.CreateActApplicable(TDSActApplicable);
        LibraryTDS.AttachSectionWithForeignVendor(TDSPostingSetup."TDS Section", Vendor."No.", true, true, true, true, TDSNatureOfRemittance.Code, TDSActApplicable.Code);
        Storage.Set(NatureOfRemittanceLbl, TDSNatureOfRemittance.Code);
        Storage.Set(ActApplicableLbl, TDSActApplicable.Code);
        Storage.Set(CountryCodeLbl, Vendor."Country/Region Code");

        // [WHEN] Create and Post Foreign Vendor Purchase Order
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            false);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
        IsForeignVendor := false
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvofForeignVendorWithResWithPANWithoutConCode()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TDSNatureOfRemittance: Record "TDS Nature of Remittance";
        TDSActApplicable: Record "Act Applicable";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376810] Check if the program is calculating TDS in case an invoice is raised to the foreign Vendor using Purchase Invoice and Surcharge Overlook is selected with Resources
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        IsForeignVendor := true;
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        LibraryTDS.CreateForeignVendorWithPANNoandWithoutConcessional(Vendor);
        LibraryTDS.CreateNatureOfRemittance(TDSNatureOfRemittance);
        LibraryTDS.CreateActApplicable(TDSActApplicable);
        LibraryTDS.AttachSectionWithForeignVendor(TDSPostingSetup."TDS Section", Vendor."No.", true, true, true, true, TDSNatureOfRemittance.Code, TDSActApplicable.Code);
        Storage.Set(NatureOfRemittanceLbl, TDSNatureOfRemittance.Code);
        Storage.Set(ActApplicableLbl, TDSActApplicable.Code);
        Storage.Set(CountryCodeLbl, Vendor."Country/Region Code");

        // [WHEN] Create and Post Foreign Vendor Purchase Invoice
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Invoice,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            false);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
        IsForeignVendor := false
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvofForeignVendorWithResWithoutSurchargeOverlook()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TDSNatureOfRemittance: Record "TDS Nature of Remittance";
        TDSActApplicable: Record "Act Applicable";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376784] Check if the program is calculating TDS in case an invoice is raised to the foreign Vendor using Purchase Invoice and Surcharge Overlook is not selected with Resources.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overlook.
        IsForeignVendor := true;
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, false, false);
        LibraryTDS.CreateForeignVendorWithPANNoandWithoutConcessional(Vendor);
        LibraryTDS.CreateNatureOfRemittance(TDSNatureOfRemittance);
        LibraryTDS.CreateActApplicable(TDSActApplicable);
        LibraryTDS.AttachSectionWithForeignVendor(TDSPostingSetup."TDS Section", Vendor."No.", true, false, false, true, TDSNatureOfRemittance.Code, TDSActApplicable.Code);
        Storage.Set(NatureOfRemittanceLbl, TDSNatureOfRemittance.Code);
        Storage.Set(ActApplicableLbl, TDSActApplicable.Code);
        Storage.Set(CountryCodeLbl, Vendor."Country/Region Code");

        // [WHEN] Create and Post Foreign Vendor Purchase Invoice
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Invoice,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            false);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, false, false);
        IsForeignVendor := false
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdofForeignVendorWithResWithoutSurchargeOverlook()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TDSNatureOfRemittance: Record "TDS Nature of Remittance";
        TDSActApplicable: Record "Act Applicable";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376787] Check if the program is calculating TDS in case an invoice is raised to the foreign Vendor using Purchase Order and Surcharge Overlook is not selected with Resources.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode without Threshold and Surcharge Overlook.
        IsForeignVendor := true;
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, false, false);
        LibraryTDS.CreateForeignVendorWithPANNoandWithoutConcessional(Vendor);
        LibraryTDS.CreateNatureOfRemittance(TDSNatureOfRemittance);
        LibraryTDS.CreateActApplicable(TDSActApplicable);
        LibraryTDS.AttachSectionWithForeignVendor(TDSPostingSetup."TDS Section", Vendor."No.", true, false, false, true, TDSNatureOfRemittance.Code, TDSActApplicable.Code);
        Storage.Set(NatureOfRemittanceLbl, TDSNatureOfRemittance.Code);
        Storage.Set(ActApplicableLbl, TDSActApplicable.Code);
        Storage.Set(CountryCodeLbl, Vendor."Country/Region Code");

        // [WHEN] Create and Post Foreign Vendor Purchase Order
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            false);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, false, false);
        IsForeignVendor := false
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithResWithoutPANWithoutConCodeFCY()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TDSNatureOfRemittance: Record "TDS Nature of Remittance";
        TDSActApplicable: Record "Act Applicable";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376815] Check if the program is calculating TDS while creating Invoice with Resource using the Purchase Order in case of Foreign Currency.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        IsForeignVendor := true;
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithoutConcessional(Vendor, true, true);
        LibraryTDS.CreateForeignVendorWithoutPANNoandWithoutConcessional(Vendor);
        LibraryTDS.CreateNatureOfRemittance(TDSNatureOfRemittance);
        LibraryTDS.CreateActApplicable(TDSActApplicable);
        LibraryTDS.AttachSectionWithForeignVendor(TDSPostingSetup."TDS Section", Vendor."No.", true, true, true, true, TDSNatureOfRemittance.Code, TDSActApplicable.Code);
        Storage.Set(NatureOfRemittanceLbl, TDSNatureOfRemittance.Code);
        Storage.Set(ActApplicableLbl, TDSActApplicable.Code);
        Storage.Set(CountryCodeLbl, Vendor."Country/Region Code");

        // [WHEN] Create and Post Foreign Vendor Purchase Order
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        DocumentNo := CreateAndPostPurchaseDocumentwithFCY(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            false);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, false, true, true);
        IsForeignVendor := false
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithResWithoutPANWithoutConCodeFCY()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TDSNatureOfRemittance: Record "TDS Nature of Remittance";
        TDSActApplicable: Record "Act Applicable";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376818] Check if the program is calculating TDS while creating Invoice with Resource using the Purchase Invoice in case of Foreign Currency.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        IsForeignVendor := true;
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithoutPANWithoutConcessional(Vendor, true, true);
        LibraryTDS.CreateForeignVendorWithoutPANNoandWithoutConcessional(Vendor);
        LibraryTDS.CreateNatureOfRemittance(TDSNatureOfRemittance);
        LibraryTDS.CreateActApplicable(TDSActApplicable);
        LibraryTDS.AttachSectionWithForeignVendor(TDSPostingSetup."TDS Section", Vendor."No.", true, true, true, true, TDSNatureOfRemittance.Code, TDSActApplicable.Code);
        Storage.Set(NatureOfRemittanceLbl, TDSNatureOfRemittance.Code);
        Storage.Set(ActApplicableLbl, TDSActApplicable.Code);
        Storage.Set(CountryCodeLbl, Vendor."Country/Region Code");

        // [WHEN] Create and Post Foreign Vendor Purchase Invoice
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());
        DocumentNo := CreateAndPostPurchaseDocumentwithFCY(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Invoice,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            false);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, false, true, true);
        IsForeignVendor := false
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithResourceWithThresholdLimit()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [377624] Check if the program is calculating TDS while creating Invoice with Resource using the Purchase Order with threshold limit.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Purchase Order with Resource with threshold limit
        DocumentNo := CreateAndPostPurchaseDocument(
             PurchaseHeader,
             PurchaseHeader."Document Type"::Order,
             Vendor."No.",
             WorkDate(),
             PurchaseLine.Type::Resource,
             false);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithResourceWithThresholdLimit()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [377624] Check if the program is calculating TDS while creating Invoice with Resource using the Purchase Invoice with threshold limit.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, false, false);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Purchase Invoice with Resource with threshold limit
        DocumentNo := CreateAndPostPurchaseDocument(
             PurchaseHeader,
             PurchaseHeader."Document Type"::Invoice,
             Vendor."No.",
             WorkDate(),
             PurchaseLine.Type::Resource,
             false);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, false, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchOrdWithResourceWithRoundOff()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376624] Check if the program is calculating TDS with rounded figure for each component (TDS amount, surcharge amount, eCess amount, SHE Cess Amount) while preparing Purchase Order with Resource.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Purchase Order with Resource
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Order,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            false);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromPurchInvWithResourceWithRoundOff()
    var
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [376612] Check if the program is calculating TDS with rounded figure for each component (TDS amount, surcharge amount, eCess amount, SHE Cess Amount) while preparing Purchase Invoice with Resource.
        // [GIVEN] Created Setup for AssesseeCode,TDSPostingSetup,TDSSection,ConcessionalCode with Threshold and Surcharge Overlook.
        LibraryTDS.CreateTDSSetup(Vendor, TDSPostingSetup, ConcessionalCode);
        LibraryTDS.UpdateVendorWithPANWithoutConcessional(Vendor, true, true);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Vendor."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Purchase Invoice with Resource
        DocumentNo := CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseHeader."Document Type"::Invoice,
            Vendor."No.",
            WorkDate(),
            PurchaseLine.Type::Resource,
            false);

        // [THEN] G/L Entries and TDS Entries Verified
        LibraryTDS.VerifyGLEntryWithTDS(DocumentNo, TDSPostingSetup."TDS Account");
        VerifyTDSEntry(DocumentNo, true, true, true);
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

    local procedure CreateVendorInvoiceDiscount(VendorNo: Code[20])
    var
        VendorCard: TestPage "Vendor Card";
    begin
        VendorCard.OpenEdit();
        VendorCard.Filter.SetFilter("No.", VendorNo);
        VendorCard."Invoice &Discounts".Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text; VAR Reply: Boolean)
    begin
        Reply := true;
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
        Storage.Set(NonPANTDSPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(SurchargePercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(eCessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(SHECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(TDSThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(1000, 3000)));
        Storage.Set(SurchargeThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(1000, 3000)));
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

    procedure CreateAndPostPurchaseDocumentWithFCY(var PurchaseHeader: Record "Purchase Header";
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
        PurchaseHeader.Validate("Currency Code", LibraryTDS.CreateCurrencyCode());
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

        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInDecimalRange(100000, 200000, 2));
        PurchaseLine.Modify(true);
    end;

    local procedure InsertPurchaseLine(
        var PurchaseLine: Record "Purchase Line";
        PurchaseHeader: record "Purchase Header";
        LineType: enum "Purchase Line Type")
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
        TDSSectionCode := CopyStr(Storage.Get(SectionCodeLbl), 1, 10);
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
            PurchaseLine.Type::Resource:
                exit(CreateResourceNoWithoutVAT());
        end;
    end;

    local procedure CreateResourceNoWithoutVAT(): Code[20]
    var
        Resource: Record Resource;
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryTDS.CreateZeroVATPostingSetup(VATPostingSetup);
        LibraryResource.CreateResourceNew(Resource);
        Resource.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Resource.Modify(true);
        exit(Resource."No.");
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
        Assert.AreNearlyEqual(
            ExpectdTDSAmount + ExpectedSurchargeAmount, TDSEntry."TDS Amount Including Surcharge", LibraryTDS.GetTDSRoundingPrecision(),
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("TDS Amount Including Surcharge"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            SourceCodeSetup.Purchases, TDSEntry."Source Code",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Source Code"), TDSEntry.TableCaption()));
        Assert.AreEqual(
            GLEntry."Transaction No.", TDSEntry."Transaction No.",
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Transaction No."), TDSEntry.TableCaption()));
        Assert.AreNearlyEqual(
            TDSBaseAmount / CurrencyFactor, TDSEntry."Invoice Amount", LibraryTDS.GetTDSRoundingPrecision(),
            StrSubstNo(TDSEntryVerifyErr, TDSEntry.FieldName("Invoice Amount"), TDSEntry.TableCaption()));
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

    [PageHandler]
    procedure InvoiceDiscountPageHandler(var VendInvoiceDiscounts: TestPage "Vend. Invoice Discounts");
    begin
        VendInvoiceDiscounts."Discount %".SetValue(LibraryRandom.RandIntInRange(1, 4));
        VendInvoiceDiscounts.OK().Invoke();
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
        TaxRates.AttributeValue13.SetValue(TDSThresholdAmount);
        TaxRates.AttributeValue14.SetValue(SurchargeThresholdAmount);
        TaxRates.AttributeValue15.SetValue(0.00);
        TaxRates.OK().Invoke();
    end;

    var
        LibraryRandom: Codeunit "Library - Random";
        Assert: codeunit Assert;
        LibraryTDS: Codeunit "Library-TDS";
        LibraryPurchase: codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryResource: Codeunit "Library - Resource";
        Storage: Dictionary of [Text, Text];
        IsForeignVendor: Boolean;
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
        NatureOfRemittanceLbl: Label 'NatureOfRemittance', Locked = true;
        ActApplicableLbl: Label 'ActApplicable', Locked = true;
        CountryCodeLbl: Label 'CountryCode', Locked = true;
        IncomeTaxAccountingErr: Label 'The Posting Date doesn''t lie in Tax Accounting Period', Locked = true;
        TANNoErr: Label 'T.A.N. No. must have a value in Company Information', locked = true;
        TDSEntryVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
}