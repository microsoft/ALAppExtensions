codeunit 148190 "Sust. Value Entry Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Assert";
        LibrarySustainability: Codeunit "Library - Sustainability";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryERM: Codeunit "Library - ERM";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        ValueMustBeEqualErr: Label '%1 must be equal to %2 in the %3.', Comment = '%1 = Field Caption , %2 = Expected Value, %3 = Table Caption';
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';

    [Test]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenPurchDocumentIsPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        EmissionFee: array[3] of Record "Emission Fee";
        PurchaseHeader: Record "Purchase Header";
        CountryRegion: Record "Country/Region";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 541865] Verify Sustainability Value entry should be created when the purchase document is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", CountryRegion.Code);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader."Buy-from Country/Region Code" := CountryRegion.Code;
        PurchaseHeader.Modify();

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2,Emission CH4,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [GIVEN] Save Expected CO2e Emission and Carbon Fee.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [WHEN] Post a Purchase Document.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability Value entry and Sustainability Ledger Entry should be created when the purchase document is posted.
        SustainabilityValueEntry.SetRange("Document No.", PostedInvoiceNo);
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            ExpectedCO2eEmission,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), ExpectedCO2eEmission, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", PostedInvoiceNo);
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            EmissionCO2,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionCH4,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), EmissionCH4, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionN2O,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), EmissionN2O, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            ExpectedCO2eEmission,
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), ExpectedCO2eEmission, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            ExpectedCarbonFee,
            SustainabilityLedgerEntry."Carbon Fee",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Carbon Fee"), ExpectedCarbonFee, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenPurchDocumentIsPartiallyPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        EmissionFee: array[3] of Record "Emission Fee";
        PurchaseHeader: Record "Purchase Header";
        CountryRegion: Record "Country/Region";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 541865] Verify Sustainability Value entry should be created when the purchase document is partially posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", CountryRegion.Code);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader."Buy-from Country/Region Code" := CountryRegion.Code;
        PurchaseHeader.Modify();

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Save Quanity.
        Quantity := PurchaseLine.Quantity / 2;

        // [GIVEN] Update Sustainability Account No.,Emission CO2,Emission CH4,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Qty. to Receive", Quantity);
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [GIVEN] Save Expected Emission.
        EmissionCO2 := PurchaseLine."Emission CO2 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * Quantity;
        EmissionCH4 := PurchaseLine."Emission CH4 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * Quantity;
        EmissionN2O := PurchaseLine."Emission N2O Per Unit" * PurchaseLine."Qty. per Unit of Measure" * Quantity;

        // [GIVEN] Save Expected CO2e Emission and Carbon Fee.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [WHEN] Post a Purchase Document.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability Value entry and Sustainability Ledger Entry should be created when the purchase document is partially posted.
        SustainabilityValueEntry.SetRange("Document No.", PostedInvoiceNo);
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            ExpectedCO2eEmission,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), ExpectedCO2eEmission, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", PostedInvoiceNo);
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            EmissionCO2,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionCH4,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), EmissionCH4, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionN2O,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), EmissionN2O, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            ExpectedCO2eEmission,
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), ExpectedCO2eEmission, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            ExpectedCarbonFee,
            SustainabilityLedgerEntry."Carbon Fee",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Carbon Fee"), ExpectedCarbonFee, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityValueEntryShouldBeKnockedOffWhenCancelCreditMemoIsPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        EmissionFee: array[3] of Record "Emission Fee";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 541865] Verify Sustainability Value entry should be Kocked Off when the Cancel Credit Memo is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [WHEN] Post a Purchase Document.
        PostAndVerifyCancelCreditMemo(PurchaseHeader);

        // [VERIFY] Verify Sustainability Value Entry and Sustainability ledger Entry should be Kocked Off when the Cancel Credit Memo is posted.
        SustainabilityValueEntry.SetRange("Item No.", PurchaseLine."No.");
        SustainabilityValueEntry.CalcSums("CO2e Amount (Actual)", "CO2e Amount (Expected)");
        Assert.RecordCount(SustainabilityValueEntry, 2);
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), 0, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.CalcSums("Emission CO2", "Emission CH4", "Emission N2O", "CO2e Emission", "Carbon Fee");
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Carbon Fee",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Carbon Fee"), 0, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityRelatedEntriesWhenPurchDocumentIsPartiallyPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        EmissionFee: array[3] of Record "Emission Fee";
        PurchaseHeader: Record "Purchase Header";
        CountryRegion: Record "Country/Region";
        PurchaseLine: Record "Purchase Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PostedPurchInvoiceSubform: TestPage "Posted Purch. Invoice Subform";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedNo: Code[20];
    begin
        // [SCENARIO 541865] Verify Sustainability related entries When Purchase Document Is Partially Posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", CountryRegion.Code);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader."Buy-from Country/Region Code" := CountryRegion.Code;
        PurchaseHeader.Modify();

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Save Quanity.
        Quantity := PurchaseLine.Quantity / 2;

        // [GIVEN] Update Sustainability Account No.,Emission CO2,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Qty. to Receive", Quantity);
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [GIVEN] Save Expected Emission.
        EmissionCO2 := PurchaseLine."Emission CO2 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * Quantity;
        EmissionCH4 := PurchaseLine."Emission CH4 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * Quantity;
        EmissionN2O := PurchaseLine."Emission N2O Per Unit" * PurchaseLine."Qty. per Unit of Measure" * Quantity;

        // [GIVEN] Save Expected CO2e Emission and Carbon Fee.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [WHEN] Post a Purchase Document With Receiving.
        PostedNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        // [VERIFY] Verify Sustainability Fields In Purchase Receipt Line and Sustainability Value Entry should be created when Purchase Document is received.
        PurchRcptLine.SetRange("Buy-from Vendor No.", PurchaseLine."Buy-from Vendor No.");
        PurchRcptLine.FindFirst();
        Assert.AreEqual(
            AccountCode,
            PurchRcptLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Sust. Account No."), AccountCode, PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            EmissionCH4,
            PurchRcptLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Emission CH4"), EmissionCH4, PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            EmissionCO2,
            PurchRcptLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Emission CO2"), EmissionCO2, PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            EmissionN2O,
            PurchRcptLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Emission N2O"), EmissionN2O, PurchRcptLine.TableCaption()));

        SustainabilityValueEntry.SetRange("Document No.", PostedNo);
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            ExpectedCO2eEmission,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), ExpectedCO2eEmission, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), 0, SustainabilityValueEntry.TableCaption()));
        Assert.RecordCount(SustainabilityLedgerEntry, 0);

        // [WHEN] Post a Purchase Document With Invoicing.
        PostedNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        // [VERIFY] Verify Sustainability Fields In Purchase Invoice Line, Sustainability Value Entry and Sustainability Ledger Entry should be created when Purchase Document is invoiced.
        PostedPurchInvoiceSubform.OpenEdit();
        PostedPurchInvoiceSubform.FILTER.SetFilter("Document No.", PostedNo);
        PostedPurchInvoiceSubform."Sust. Account No.".AssertEquals(AccountCode);
        PostedPurchInvoiceSubform."Emission CH4".AssertEquals(EmissionCH4);
        PostedPurchInvoiceSubform."Emission CO2".AssertEquals(EmissionCO2);
        PostedPurchInvoiceSubform."Emission N2O".AssertEquals(EmissionN2O);

        SustainabilityValueEntry.SetRange("Document No.", PostedNo);
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            ExpectedCO2eEmission,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), ExpectedCO2eEmission, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            -ExpectedCO2eEmission,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), -ExpectedCO2eEmission, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", PostedNo);
        SustainabilityLedgerEntry.FindFirst();
        Assert.RecordCount(SustainabilityLedgerEntry, 1);
        Assert.AreEqual(
            ExpectedCO2eEmission,
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), ExpectedCO2eEmission, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            ExpectedCarbonFee,
            SustainabilityLedgerEntry."Carbon Fee",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Carbon Fee"), ExpectedCarbonFee, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifyPostedEmissionFieldsInPurchaseLine()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 541865] Verify Posted Emission fields in Purchase Line.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", LibraryRandom.RandInt(20));
        PurchaseLine.Validate("Emission CH4", LibraryRandom.RandInt(5));
        PurchaseLine.Validate("Emission N2O", LibraryRandom.RandInt(5));
        PurchaseLine.Modify();

        // [GIVEN] Save Expected Emission.
        EmissionCO2 := PurchaseLine."Emission CO2 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);
        EmissionCH4 := PurchaseLine."Emission CH4 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);
        EmissionN2O := PurchaseLine."Emission N2O Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);

        // [WHEN] Post a Purchase Document With Receiving.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        // [VERIFY] Verify Posted Emission fields in Purchase Line When Purchase Document is received.
        PurchaseLine.Get(PurchaseLine."Document Type", PurchaseLine."Document No.", PurchaseLine."Line No.");
        Assert.AreEqual(
            0,
            PurchaseLine."Posted Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Posted Emission CO2"), 0, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            0,
            PurchaseLine."Posted Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Posted Emission CH4"), 0, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            0,
            PurchaseLine."Posted Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Posted Emission N2O"), 0, PurchaseLine.TableCaption()));

        // [WHEN] Post a Purchase Document With Invoicing.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        // [VERIFY] Verify Posted Emission fields in Purchase Line When Purchase Document is invoiced.
        PurchaseLine.Get(PurchaseLine."Document Type", PurchaseLine."Document No.", PurchaseLine."Line No.");
        Assert.AreEqual(
            EmissionCO2,
            PurchaseLine."Posted Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Posted Emission CO2"), EmissionCO2, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            EmissionCH4,
            PurchaseLine."Posted Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Posted Emission CH4"), EmissionCH4, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            EmissionN2O,
            PurchaseLine."Posted Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Posted Emission N2O"), EmissionN2O, PurchaseLine.TableCaption()));

        // [GIVEN] Update "Qty. to Receive" in Purchase line.
        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify();

        // [GIVEN] Update "Qty. to Receive" in Purchase line.
        PurchaseLine.Get(PurchaseLine."Document Type", PurchaseLine."Document No.", PurchaseLine."Line No.");
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(2, 2));
        PurchaseLine.Modify();

        // [GIVEN] Save Expected Emission.
        EmissionCO2 := PurchaseLine."Emission CO2 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(7, 7);
        EmissionCH4 := PurchaseLine."Emission CH4 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(7, 7);
        EmissionN2O := PurchaseLine."Emission N2O Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(7, 7);

        // [WHEN] Post a Purchase Document With Receiving and Invoicing.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Posted Emission fields in Purchase Line When Purchase Document is received and invoiced.
        PurchaseLine.Get(PurchaseLine."Document Type", PurchaseLine."Document No.", PurchaseLine."Line No.");
        Assert.AreEqual(
            EmissionCO2,
            PurchaseLine."Posted Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Posted Emission CO2"), EmissionCO2, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            EmissionCH4,
            PurchaseLine."Posted Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Posted Emission CH4"), EmissionCH4, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            EmissionN2O,
            PurchaseLine."Posted Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Posted Emission N2O"), EmissionN2O, PurchaseLine.TableCaption()));
    end;

    [Test]
    [HandlerFunctions('PurchaseOrderStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInPurchaseOrderStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 541865] Verify Sustainability Fields in Purchase Order Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2);
        LibraryVariableStorage.Enqueue(EmissionCH4);
        LibraryVariableStorage.Enqueue(EmissionN2O);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);

        // [VERIFY] Verify Sustainability fields in Page "Purchase Order Statistics" before posting of Purchase order.
        OpenPurchaseOrderStatistics(PurchaseHeader."No.");
        LibraryVariableStorage.Clear();

        // [GIVEN] Post a Purchase Document with Receiving.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2);
        LibraryVariableStorage.Enqueue(EmissionCH4);
        LibraryVariableStorage.Enqueue(EmissionN2O);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);

        // [VERIFY] Verify Sustainability fields in Page "Purchase Order Statistics" after partially posting of Purchase order with only Receiving.
        OpenPurchaseOrderStatistics(PurchaseHeader."No.");
        LibraryVariableStorage.Clear();

        // [GIVEN] Post a Purchase Document with Invoicing.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2);
        LibraryVariableStorage.Enqueue(EmissionCH4);
        LibraryVariableStorage.Enqueue(EmissionN2O);
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission CO2 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5));
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission CH4 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5));
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission N2O Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5));

        // [VERIFY] Verify Sustainability fields in Page "Purchase Order Statistics" after partially posting of Purchase order with only Invoicing.
        OpenPurchaseOrderStatistics(PurchaseHeader."No.");
        LibraryVariableStorage.Clear();

        // [GIVEN] Update "Qty. to Receive" in Purchase line.
        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify();

        // [GIVEN] Update "Qty. to Receive" in Purchase line.
        PurchaseLine.Get(PurchaseLine."Document Type", PurchaseLine."Document No.", PurchaseLine."Line No.");
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(2, 2));
        PurchaseLine.Modify();

        // [GIVEN] Post a Purchase Document with Receiving and Invoicing.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2);
        LibraryVariableStorage.Enqueue(EmissionCH4);
        LibraryVariableStorage.Enqueue(EmissionN2O);
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission CO2 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(7, 7));
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission CH4 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(7, 7));
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission N2O Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(7, 7));

        // [VERIFY] Verify Sustainability fields in Page "Purchase Order Statistics" after partially posting of Purchase order with Receiving and Invoicing.
        OpenPurchaseOrderStatistics(PurchaseHeader."No.");
        LibraryVariableStorage.Clear();
    end;

    [Test]
    procedure VerifySustainabilityFieldsInPostedPurchaseInvoiceStatisticsWhenPurchaseDocumentIsPartiallyPosted()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 541865] Verify Sustainability Fields in Posted Purchase Invoice Statistics When Purchase Document is partially posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [GIVEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission CO2 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5));
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission CH4 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5));
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission N2O Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5));

        // [WHEN] Post Purchase Document with Receiving and Invoicing.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability fields in Page "Posted Purchase Invoice Statistics" When Purchase document is partially posted.
        VerifyPostedPurchaseInvoiceStatistics(PostedInvoiceNo);
        LibraryVariableStorage.Clear();

        // [GIVEN] Update "Qty. to Receive" in Purchase line.
        PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateGUID());
        PurchaseHeader.Modify();

        // [GIVEN] Update "Qty. to Receive" in Purchase line.
        PurchaseLine.Get(PurchaseLine."Document Type", PurchaseLine."Document No.", PurchaseLine."Line No.");
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(2, 2));
        PurchaseLine.Modify();

        // [GIVEN] Post a Purchase Document with Receiving and Invoicing.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission CO2 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(2, 2));
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission CH4 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(2, 2));
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission N2O Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(2, 2));

        // [VERIFY] Verify Sustainability fields in Page "Posted Purchase Invoice Statistics" When Purchase document is partially posted.
        VerifyPostedPurchaseInvoiceStatistics(PostedInvoiceNo);
        LibraryVariableStorage.Clear();
    end;

    [Test]
    [HandlerFunctions('GLPostingPreviewHandler')]
    procedure VerifySustainabilityValueEntryShouldBeCreatedDuringPreviewPostingOfPurchaseOrder()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 541865] Verify Sustainability Value Entry and Sustainability Ledger Entry should be created during Preview Posting of purchase order.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Post a Purchase Document.
        asserterror LibraryPurchase.PreviewPostPurchaseDocument(PurchaseHeader);

        // [VERIFY] No errors occured - preview mode error only.
        Assert.ExpectedError('');
    end;

    [Test]
    [HandlerFunctions('GLPostingPreviewHandlerForOnlyReceived')]
    procedure VerifySustainabilityValueEntryShouldBeCreatedDuringPreviewPostingOfPurchaseOrderWhenDocumentIsReceived()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 541865] Verify Sustainability Value Entry should be created during Preview Posting of purchase order When Document is received.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Qty. to Invoice", 0);
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Post a Purchase Document.
        asserterror LibraryPurchase.PreviewPostPurchaseDocument(PurchaseHeader);

        // [VERIFY] No errors occured - preview mode error only.
        Assert.ExpectedError('');
    end;

    [Test]
    [HandlerFunctions('NavigateFindEntriesHandler')]
    procedure VerifySustainabilityValueEntryShouldBeShownWhenNavigatingPostedPurchaseInvoice()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseInvHeader: Record "Purch. Inv. Header";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedPurchInvNo: Code[20];
    begin
        // [SCENARIO 541865] Verify Sustainability Value Entry and Sustainability Ledger Entry should be shown when navigating Posted Purchase Invoice through NavigateFindEntriesHandler handler.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        PostedPurchInvNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability Value Entry and Sustainability Ledger Entry should be shown when navigating Posted Purchase Invoice through NavigateFindEntriesHandler handler.
        PurchaseInvHeader.Get(PostedPurchInvNo);
        PurchaseInvHeader.Navigate();
    end;

    [Test]
    [HandlerFunctions('NavigateFindEntriesHandlerForOnlyReceived')]
    procedure VerifySustainabilityValueEntryShouldBeShownWhenNavigatingPostedPurchaseReceipt()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseRcptHeader: Record "Purch. Rcpt. Header";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedPurchNo: Code[20];
    begin
        // [SCENARIO 541865] Verify Sustainability Value Entry should be shown when navigating Posted Purchase Receipt through NavigateFindEntriesHandler handler.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        PostedPurchNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        // [VERIFY] Verify Sustainability Value Entry should be shown when navigating Posted Purchase Receipt through NavigateFindEntriesHandler handler.
        PurchaseRcptHeader.Get(PostedPurchNo);
        PurchaseRcptHeader.Navigate();
    end;

    local procedure CreateSustainabilityAccount(var AccountCode: Code[20]; var CategoryCode: Code[20]; var SubcategoryCode: Code[20]; i: Integer): Record "Sustainability Account"
    begin
        CreateSustainabilitySubcategory(CategoryCode, SubcategoryCode, i);
        AccountCode := StrSubstNo(AccountCodeLbl, i);
        exit(LibrarySustainability.InsertSustainabilityAccount(
          AccountCode, '', CategoryCode, SubcategoryCode, Enum::"Sustainability Account Type"::Posting, '', true));
    end;

    local procedure CreateSustainabilitySubcategory(var CategoryCode: Code[20]; var SubcategoryCode: Code[20]; i: Integer)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        CreateSustainabilityCategory(CategoryCode, i);

        SubcategoryCode := StrSubstNo(SubcategoryCodeLbl, i);
        LibrarySustainability.InsertAccountSubcategory(CategoryCode, SubcategoryCode, SubcategoryCode, 1, 2, 3, false);
    end;

    local procedure CreateSustainabilityCategory(var CategoryCode: Code[20]; i: Integer)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        LibrarySustainability.InsertAccountCategory(
            CategoryCode, CategoryCode, Enum::"Emission Scope"::"Scope 1", Enum::"Calculation Foundation"::"Fuel/Electricity",
            true, true, true, '', false);
    end;

    local procedure UpdateReasonCodeinPurchaseHeader(var PurchaseHeader: Record "Purchase Header")
    var
        ReasonCode: Record "Reason Code";
    begin
        LibraryERM.CreateReasonCode(ReasonCode);

        PurchaseHeader.Validate("Reason Code", ReasonCode.Code);
        PurchaseHeader.Modify();
    end;

    local procedure PostAndVerifyCancelCreditMemo(PurchaseHeader: Record "Purchase Header")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        PostedDocNumber: Code[20];
    begin
        PostedDocNumber := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchInvHeader.Get(PostedDocNumber);
        CorrectPostedPurchInvoice.CancelPostedInvoice(PurchInvHeader);
    end;

    local procedure OpenPurchaseOrderStatistics(No: Code[20])
    var
        PurchaseOrder: TestPage "Purchase Order";
    begin
        PurchaseOrder.OpenEdit();
        PurchaseOrder.FILTER.SetFilter("No.", No);
        PurchaseOrder.Statistics.Invoke();
    end;

    local procedure OpenPurchaseCrMemoStatistics(No: Code[20])
    var
        PurchaseCreditMemo: TestPage "Purchase Credit Memo";
    begin
        PurchaseCreditMemo.OpenEdit();
        PurchaseCreditMemo.FILTER.SetFilter("No.", No);
        PurchaseCreditMemo.Statistics.Invoke();
    end;

    local procedure VerifyPostedPurchaseInvoiceStatistics(No: Code[20])
    var
        PostedPurchaseInvoiceStatisticsPage: TestPage "Purchase Invoice Statistics";
        PostedEmissionCO2: Variant;
        PostedEmissionCH4: Variant;
        PostedEmissionN2O: Variant;
    begin
        LibraryVariableStorage.Dequeue(PostedEmissionCO2);
        LibraryVariableStorage.Dequeue(PostedEmissionCH4);
        LibraryVariableStorage.Dequeue(PostedEmissionN2O);

        PostedPurchaseInvoiceStatisticsPage.OpenEdit();
        PostedPurchaseInvoiceStatisticsPage.FILTER.SetFilter("No.", No);
        PostedPurchaseInvoiceStatisticsPage."Emission C02".AssertEquals(PostedEmissionCO2);
        PostedPurchaseInvoiceStatisticsPage."Emission CH4".AssertEquals(PostedEmissionCH4);
        PostedPurchaseInvoiceStatisticsPage."Emission N2O".AssertEquals(PostedEmissionN2O);
    end;

    local procedure CreateEmissionFeeWithEmissionScope(var EmissionFee: array[3] of Record "Emission Fee"; EmissionScope: Enum "Emission Scope"; CountryRegionCode: Code[10])
    begin
        LibrarySustainability.InsertEmissionFee(
            EmissionFee[1],
            "Emission Type"::CH4,
            EmissionScope,
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegionCode,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));

        LibrarySustainability.InsertEmissionFee(
            EmissionFee[2],
            "Emission Type"::CO2,
            EmissionScope,
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegionCode,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));
        EmissionFee[2].Validate("Carbon Fee", LibraryRandom.RandDecInDecimalRange(0.5, 2, 1));
        EmissionFee[2].Modify();

        LibrarySustainability.InsertEmissionFee(
            EmissionFee[3],
            "Emission Type"::N2O,
            EmissionScope,
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegionCode,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure PurchaseOrderStatisticsPageHandler(var PurchaseOrderStatisticsPage: TestPage "Purchase Order Statistics")
    var
        EmissionCO2: Variant;
        EmissionCH4: Variant;
        EmissionN2O: Variant;
        PostedEmissionCO2: Variant;
        PostedEmissionCH4: Variant;
        PostedEmissionN2O: Variant;
    begin
        LibraryVariableStorage.Dequeue(EmissionCO2);
        LibraryVariableStorage.Dequeue(EmissionCH4);
        LibraryVariableStorage.Dequeue(EmissionN2O);
        LibraryVariableStorage.Dequeue(PostedEmissionCO2);
        LibraryVariableStorage.Dequeue(PostedEmissionCH4);
        LibraryVariableStorage.Dequeue(PostedEmissionN2O);

        PurchaseOrderStatisticsPage."Emission C02".AssertEquals(EmissionCO2);
        PurchaseOrderStatisticsPage."Emission CH4".AssertEquals(EmissionCH4);
        PurchaseOrderStatisticsPage."Emission N2O".AssertEquals(EmissionN2O);
        PurchaseOrderStatisticsPage."Posted Emission C02".AssertEquals(PostedEmissionCO2);
        PurchaseOrderStatisticsPage."Posted Emission CH4".AssertEquals(PostedEmissionCH4);
        PurchaseOrderStatisticsPage."Posted Emission N2O".AssertEquals(PostedEmissionN2O);
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure GLPostingPreviewHandler(var GLPostingPreview: TestPage "G/L Posting Preview")
    begin
        GLPostingPreview.Filter.SetFilter("Table ID", Format(Database::"Sustainability Value Entry"));
        GLPostingPreview."No. of Records".AssertEquals(1);

        GLPostingPreview.Filter.SetFilter("Table ID", Format(Database::"Sustainability Ledger Entry"));
        GLPostingPreview."No. of Records".AssertEquals(1);
        GLPostingPreview.OK().Invoke();
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure GLPostingPreviewHandlerForOnlyReceived(var GLPostingPreview: TestPage "G/L Posting Preview")
    begin
        GLPostingPreview.Filter.SetFilter("Table ID", Format(Database::"Sustainability Value Entry"));
        GLPostingPreview."No. of Records".AssertEquals(1);

        GLPostingPreview.Filter.SetFilter("Table ID", Format(Database::"Sustainability Ledger Entry"));
        GLPostingPreview."Table Name".AssertEquals('');
        GLPostingPreview."No. of Records".AssertEquals('');
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure NavigateFindEntriesHandler(var Navigate: TestPage Navigate)
    begin
        Navigate.Filter.SetFilter("Table ID", Format(Database::"Sustainability Ledger Entry"));
        Navigate."No. of Records".AssertEquals(1);

        Navigate.Filter.SetFilter("Table ID", Format(Database::"Sustainability Value Entry"));
        Navigate."No. of Records".AssertEquals(1);
        Navigate.OK().Invoke();
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure NavigateFindEntriesHandlerForOnlyReceived(var Navigate: TestPage Navigate)
    begin
        Navigate.Filter.SetFilter("Table ID", Format(Database::"Sustainability Value Entry"));
        Navigate."No. of Records".AssertEquals(1);

        Navigate.Filter.SetFilter("Table ID", Format(Database::"Sustainability Ledger Entry"));
        Navigate."Table Name".AssertEquals('');
        Navigate."No. of Records".AssertEquals('');
    end;
}