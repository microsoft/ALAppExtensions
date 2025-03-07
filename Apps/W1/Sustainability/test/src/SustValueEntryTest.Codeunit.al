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
        LibrarySales: Codeunit "Library - Sales";
        LibraryManufacturing: Codeunit "Library - Manufacturing";
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

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the PurchaseOrderStatistics action. The new action uses RunObject and does not run the action trigger. Use a page extension to modify the behaviour.', '26.0')]
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

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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
#endif

    [Test]
    [HandlerFunctions('PurchOrderStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInPurchOrderStatistics()
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

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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
        OpenPurchOrderStatistics(PurchaseHeader."No.");
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
        OpenPurchOrderStatistics(PurchaseHeader."No.");
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
        OpenPurchOrderStatistics(PurchaseHeader."No.");
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
        OpenPurchOrderStatistics(PurchaseHeader."No.");
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

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

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

    [Test]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenSalesDocumentIsPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        EmissionFee: array[3] of Record "Emission Fee";
        SalesHeader: Record "Sales Header";
        CountryRegion: Record "Country/Region";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability Value entry should be created when the Sales document is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 100);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", CountryRegion.Code);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());
        SalesHeader."Bill-to Country/Region Code" := CountryRegion.Code;
        SalesHeader.Modify();

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Unit Price", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 100));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify();

        // [WHEN] Post a Sales Document.
        PostedInvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [VERIFY] Verify Sustainability Value entry and Sustainability Ledger Entry should be created when the Sales document is posted.
        SustainabilityValueEntry.SetRange("Document No.", PostedInvoiceNo);
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -TotalCO2e,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -TotalCO2e, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", PostedInvoiceNo);
        Assert.RecordCount(SustainabilityLedgerEntry, 0);
    end;

    [Test]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenSalesDocumentIsPartiallyPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        EmissionFee: array[3] of Record "Emission Fee";
        SalesHeader: Record "Sales Header";
        CountryRegion: Record "Country/Region";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability Value entry should be created when the Sales document is partially posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 100);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", CountryRegion.Code);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());
        SalesHeader."Sell-to Country/Region Code" := CountryRegion.Code;
        SalesHeader.Modify();

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Save Quantity.
        Quantity := SalesLine.Quantity / 2;

        // [GIVEN] Update "Unit Price", "Qty. to Ship", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 100));
        SalesLine.Validate("Qty. to Ship", Quantity);
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify();

        // [GIVEN] Save Expected "Total CO2e".
        TotalCO2e := SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * Quantity;

        // [WHEN] Post a Sales Document.
        PostedInvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [VERIFY] Verify Sustainability Value entry and Sustainability Ledger Entry should be created when the Sales document is partially posted.
        SustainabilityValueEntry.SetRange("Document No.", PostedInvoiceNo);
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -TotalCO2e,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -TotalCO2e, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", PostedInvoiceNo);
        Assert.RecordCount(SustainabilityLedgerEntry, 0);
    end;

    [Test]
    procedure VerifySustainabilityValueEntryShouldBeKnockedOffWhenCancelSalesCreditMemoIsPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        EmissionFee: array[3] of Record "Emission Fee";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability Value entry should be Kocked Off when the Cancel Sales Credit Memo is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 100);

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Unit Price", "Qty. to Ship", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 100));
        SalesLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(5, 5));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify();

        // [GIVEN] Update Reason Code in Sales Header.
        UpdateReasonCodeinSalesHeader(SalesHeader);

        // [WHEN] Post a Sales Document.
        PostAndVerifyCancelSalesCreditMemo(SalesHeader);

        // [VERIFY] Verify Sustainability Value Entry and Sustainability ledger Entry should be Kocked Off when the Cancel Sales Credit Memo is posted.
        SustainabilityValueEntry.SetRange("Item No.", SalesLine."No.");
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
    procedure VerifySustainabilityRelatedEntriesWhenSalesDocumentIsPartiallyPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        SustainabilityAccount: Record "Sustainability Account";
        EmissionFee: array[3] of Record "Emission Fee";
        SalesHeader: Record "Sales Header";
        CountryRegion: Record "Country/Region";
        SalesLine: Record "Sales Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        PostedSalesInvoiceSubform: TestPage "Posted Sales Invoice Subform";
        TotalCO2e: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedNo: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability related entries When Sales Document is partially posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 100);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", CountryRegion.Code);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());
        SalesHeader."Bill-to Country/Region Code" := CountryRegion.Code;
        SalesHeader.Modify();

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Save Quantity.
        Quantity := SalesLine.Quantity / 2;

        // [GIVEN] Update "Unit Price", "Qty. to Ship", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 100));
        SalesLine.Validate("Qty. to Ship", Quantity);
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify();

        // [GIVEN] Save Expected "Total CO2e".
        TotalCO2e := SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * Quantity;

        // [WHEN] Post a Sales Document With Shipping.
        PostedNo := LibrarySales.PostSalesDocument(SalesHeader, true, false);

        // [VERIFY] Verify Sustainability Fields In Sales Shipment Line and Sustainability Value Entry should be created when Sales Document is shipped.
        SalesShipmentLine.SetRange("Bill-to Customer No.", SalesLine."Bill-to Customer No.");
        SalesShipmentLine.FindFirst();
        Assert.AreEqual(
            AccountCode,
            SalesShipmentLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, SalesShipmentLine.FieldCaption("Sust. Account No."), AccountCode, SalesShipmentLine.TableCaption()));
        Assert.AreEqual(
            TotalCO2e,
            SalesShipmentLine."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, SalesShipmentLine.FieldCaption("Total CO2e"), TotalCO2e, SalesShipmentLine.TableCaption()));

        SustainabilityValueEntry.SetRange("Document No.", PostedNo);
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -TotalCO2e,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), -TotalCO2e, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), 0, SustainabilityValueEntry.TableCaption()));
        Assert.RecordCount(SustainabilityLedgerEntry, 0);

        // [WHEN] Post a Sales Document With Invoicing.
        PostedNo := LibrarySales.PostSalesDocument(SalesHeader, false, true);

        // [VERIFY] Verify Sustainability Fields In Sales Invoice Line, Sustainability Value Entry and Sustainability Ledger Entry should be created when Sales Document is invoiced.
        PostedSalesInvoiceSubform.OpenEdit();
        PostedSalesInvoiceSubform.FILTER.SetFilter("Document No.", PostedNo);
        PostedSalesInvoiceSubform."Sust. Account No.".AssertEquals(AccountCode);
        PostedSalesInvoiceSubform."Total CO2e".AssertEquals(TotalCO2e);

        SustainabilityValueEntry.SetRange("Document No.", PostedNo);
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -TotalCO2e,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), -TotalCO2e, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            TotalCO2e,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), TotalCO2e, SustainabilityValueEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Document No.", PostedNo);
        Assert.RecordCount(SustainabilityLedgerEntry, 0);
    end;

    [Test]
    procedure VerifyPostedEmissionFieldsInSalesLine()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537481] Verify Posted Emission fields in Sales Line.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Unit Price", "Qty. to Ship", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 100));
        SalesLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(5, 5));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", LibraryRandom.RandInt(20));
        SalesLine.Modify();

        // [GIVEN] Save Expected "Total CO2e".
        TotalCO2e := SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);

        // [WHEN] Post a Sales Document With Shipping.
        LibrarySales.PostSalesDocument(SalesHeader, true, false);

        // [VERIFY] Verify Posted Emission fields in Sales Line When Sales Document is Shipped.
        SalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        Assert.AreEqual(
            0,
            SalesLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, SalesLine.FieldCaption("Posted Total CO2e"), 0, SalesLine.TableCaption()));

        // [WHEN] Post a Sales Document With Invoicing.
        LibrarySales.PostSalesDocument(SalesHeader, false, true);

        // [VERIFY] Verify Posted Emission fields in Sales Line When Sales Document is invoiced.
        SalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        Assert.AreEqual(
            -TotalCO2e,
            SalesLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, SalesLine.FieldCaption("Posted Total CO2e"), -TotalCO2e, SalesLine.TableCaption()));

        // [GIVEN] Update "External Document No." in Sales line.
        SalesHeader.Validate("External Document No.", LibraryUtility.GenerateGUID());
        SalesHeader.Modify();

        // [GIVEN] Update "Qty. to Ship" in Sales line.
        SalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        SalesLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(2, 2));
        SalesLine.Modify();

        // [GIVEN] Save Expected "Total CO2e.
        TotalCO2e := SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(7, 7);

        // [WHEN] Post a Sales Document With Shipping and Invoicing.
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [VERIFY] Verify Posted Emission fields in Sales Line When Sales Document is shipped and invoiced.
        SalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        Assert.AreEqual(
            -TotalCO2e,
            SalesLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, SalesLine.FieldCaption("Posted Total CO2e"), -TotalCO2e, SalesLine.TableCaption()));
    end;

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the SalesStatistics action. The new action uses RunObject and does not run the action trigger.', '26.0')]
    [Test]
    [HandlerFunctions('SalesOrderStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInSalesOrderStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability Fields in Sales Order Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 100);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Unit Price", "Qty. to Ship", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(5, 5));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify();

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);
        LibraryVariableStorage.Enqueue(0);

        // [VERIFY] Verify Sustainability fields in Page "Sales Order Statistics" before posting of Sales order.
        OpenSalesOrderStatistics(SalesHeader."No.");
        LibraryVariableStorage.Clear();

        // [GIVEN] Post a Sales Document with Shipping.
        LibrarySales.PostSalesDocument(SalesHeader, true, false);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);
        LibraryVariableStorage.Enqueue(0);

        // [VERIFY] Verify Sustainability fields in Page "Sales Order Statistics" after partially posting of Sales order with only Shipping.
        OpenSalesOrderStatistics(SalesHeader."No.");
        LibraryVariableStorage.Clear();

        // [GIVEN] Post a Sales Document with Invoicing.
        LibrarySales.PostSalesDocument(SalesHeader, false, true);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);
        LibraryVariableStorage.Enqueue(SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5) * -1);

        // [VERIFY] Verify Sustainability fields in Page "Sales Order Statistics" after partially posting of Sales order with only Invoicing.
        OpenSalesOrderStatistics(SalesHeader."No.");
        LibraryVariableStorage.Clear();

        // [GIVEN] Update "External Document No." in Sales line.
        SalesHeader.Validate("External Document No.", LibraryUtility.GenerateGUID());
        SalesHeader.Modify();

        // [GIVEN] Update "Qty. to Ship" in Sales line.
        SalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        SalesLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(2, 2));
        SalesLine.Modify();

        // [GIVEN] Post a Sales Document with Shipping and Invoicing.
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);
        LibraryVariableStorage.Enqueue(SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(7, 7) * -1);

        // [VERIFY] Verify Sustainability fields in Page "Sales Order Statistics" after partially posting of Sales order with Shipping and Invoicing.
        OpenSalesOrderStatistics(SalesHeader."No.");
        LibraryVariableStorage.Clear();
    end;
#endif
    [Test]
    [HandlerFunctions('SalesOrderStatisticsPageHandlerNM')]
    procedure VerifySustainabilityFieldsInSalesOrderStatisticsNM()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability Fields in Sales Order Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 100);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Unit Price", "Qty. to Ship", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(5, 5));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify();

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);
        LibraryVariableStorage.Enqueue(0);

        // [VERIFY] Verify Sustainability fields in Page "Sales Order Statistics" before posting of Sales order.
        OpenSalesOrderStatisticsNM(SalesHeader."No.");
        LibraryVariableStorage.Clear();

        // [GIVEN] Post a Sales Document with Shipping.
        LibrarySales.PostSalesDocument(SalesHeader, true, false);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);
        LibraryVariableStorage.Enqueue(0);

        // [VERIFY] Verify Sustainability fields in Page "Sales Order Statistics" after partially posting of Sales order with only Shipping.
        OpenSalesOrderStatisticsNM(SalesHeader."No.");
        LibraryVariableStorage.Clear();

        // [GIVEN] Post a Sales Document with Invoicing.
        LibrarySales.PostSalesDocument(SalesHeader, false, true);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);
        LibraryVariableStorage.Enqueue(SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5) * -1);

        // [VERIFY] Verify Sustainability fields in Page "Sales Order Statistics" after partially posting of Sales order with only Invoicing.
        OpenSalesOrderStatisticsNM(SalesHeader."No.");
        LibraryVariableStorage.Clear();

        // [GIVEN] Update "External Document No." in Sales line.
        SalesHeader.Validate("External Document No.", LibraryUtility.GenerateGUID());
        SalesHeader.Modify();

        // [GIVEN] Update "Qty. to Ship" in Sales line.
        SalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        SalesLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(2, 2));
        SalesLine.Modify();

        // [GIVEN] Post a Sales Document with Shipping and Invoicing.
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);
        LibraryVariableStorage.Enqueue(SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(7, 7) * -1);

        // [VERIFY] Verify Sustainability fields in Page "Sales Order Statistics" after partially posting of Sales order with Shipping and Invoicing.
        OpenSalesOrderStatisticsNM(SalesHeader."No.");
        LibraryVariableStorage.Clear();
    end;

    [Test]
    procedure VerifySustainabilityFieldsInPostedSalesInvoiceStatisticsWhenSalesDocumentIsPartiallyPosted()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability Fields in Posted Sales Invoice Statistics When Sales Document is partially posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 100);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Unit Price", "Qty. to Ship", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 100));
        SalesLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(5, 5));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify();

        // [GIVEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5) * -1);

        // [WHEN] Post Sales Document with Shipping and Invoicing.
        PostedInvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [VERIFY] Verify Sustainability fields in Page "Posted Sales Invoice Statistics" When Sales document is partially posted.
        VerifyPostedSalesInvoiceStatistics(PostedInvoiceNo);
        LibraryVariableStorage.Clear();

        // [GIVEN] Update "External Document No." in Sales line.
        SalesHeader.Validate("External Document No.", LibraryUtility.GenerateGUID());
        SalesHeader.Modify();

        // [GIVEN] Update "Qty. to Ship" in Sales line.
        SalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        SalesLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(2, 2));
        SalesLine.Modify();

        // [GIVEN] Post a Sales Document with Shipping and Invoicing.
        PostedInvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(2, 2) * -1);

        // [VERIFY] Verify Sustainability fields in Page "Posted Sales Invoice Statistics" When Sales document is partially posted.
        VerifyPostedSalesInvoiceStatistics(PostedInvoiceNo);
        LibraryVariableStorage.Clear();
    end;

    [Test]
    [HandlerFunctions('GLPostingPreviewHandlerForSales')]
    procedure VerifySustainabilityValueEntryShouldBeCreatedDuringPreviewPostingOfSalesOrder()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability Value Entry should be created during Preview Posting of Sales order.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 100);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update "Unit Price", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 100));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify();

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Post a Sales Document.
        asserterror LibrarySales.PreviewPostSalesDocument(SalesHeader);

        // [VERIFY] No errors occured - preview mode error only.
        Assert.ExpectedError('');
    end;

    [Test]
    [HandlerFunctions('GLPostingPreviewHandlerForOnlyReceived')]
    procedure VerifySustainabilityValueEntryShouldBeCreatedDuringPreviewPostingOfSalesOrderWhenDocumentIsShipped()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability Value Entry should be created during Preview Posting of Sales order When Document is shipped.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 100);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update "Unit Price", "Qty. to Ship", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 100));
        SalesLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(5, 5));
        SalesLine.Validate("Qty. to Invoice", 0);
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify();

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Post a Sales Document.
        asserterror LibrarySales.PreviewPostSalesDocument(SalesHeader);

        // [VERIFY] No errors occured - preview mode error only.
        Assert.ExpectedError('');
    end;

    [Test]
    [HandlerFunctions('NavigateFindEntriesHandlerForSales')]
    procedure VerifySustainabilityValueEntryShouldBeShownWhenNavigatingPostedSalesInvoice()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedPurchInvNo: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability Value Entry should be shown when navigating Posted Sales Invoice through NavigateFindEntriesHandlerForSales handler.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 100);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update "Unit Price", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 100));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify();

        // [WHEN] Post a Sales Document.
        PostedPurchInvNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [VERIFY] Verify Sustainability Value Entry should be shown when navigating Posted Sales Invoice through NavigateFindEntriesHandlerForSales handler.
        SalesInvoiceHeader.Get(PostedPurchInvNo);
        SalesInvoiceHeader.Navigate();
    end;

    [Test]
    [HandlerFunctions('NavigateFindEntriesHandlerForOnlyReceived')]
    procedure VerifySustainabilityValueEntryShouldBeShownWhenNavigatingPostedSalesShipment()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedPurchNo: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability Value Entry should be shown when navigating Posted Sales Shipment through NavigateFindEntriesHandler handler.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandIntInRange(100, 100);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update "Unit Price", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 100));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify();

        // [WHEN] Post a Sales Document.
        PostedPurchNo := LibrarySales.PostSalesDocument(SalesHeader, true, false);

        // [VERIFY] Verify Sustainability Value Entry should be shown when navigating Posted Sales Shipment through NavigateFindEntriesHandler handler.
        SalesShipmentHeader.Get(PostedPurchNo);
        SalesShipmentHeader.Navigate();
    end;

    [Test]
    procedure VerifyCO2ePerUnitShouldBeUpdatedInItemWhenPurchaseDocumentIsPosted()
    var
        Item: Record Item;
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        CountryRegion: Record "Country/Region";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        ExpectedCO2eEmission: Decimal;
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 537481] Verify "CO2e per Unit" must be updated in Item When Purchase Document is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create Item No.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", CountryRegion.Code);

        // [GIVEN] Generate Emission and Quantity.
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission :=
            (EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor") / Quantity;

        // [WHEN] Post Purchase Document.
        CreateAndPostPurchaseDocument(PurchaseHeader, Item."No.", Quantity, EmissionFee[1]."Country/Region Code", AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [THEN] Verify "CO2e per Unit" must be updated When Purchase Document is posted.
        Item.Get(Item."No.");
        Assert.AreEqual(
            ExpectedCO2eEmission,
            Item."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("CO2e per Unit"), ExpectedCO2eEmission, Item.TableCaption()));
    end;

    [Test]
    procedure VerifyCO2ePerUnitShouldBeUpdatedInSalesLine()
    var
        Item: Record Item;
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        CountryRegion: Record "Country/Region";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        ExpectedCO2eEmission: Decimal;
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        Quantity: Decimal;
    begin
        // [SCENARIO 537481] Verify "CO2e per Unit" must be updated from Item in Sales line.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create Item No.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", CountryRegion.Code);

        // [GIVEN] Generate Emission and Quantity.
        EmissionCO2 := LibraryRandom.RandInt(100);
        EmissionCH4 := LibraryRandom.RandInt(100);
        EmissionN2O := LibraryRandom.RandInt(100);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission :=
            (EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor") / Quantity;

        // [GIVEN] Post Purchase Document.
        CreateAndPostPurchaseDocument(PurchaseHeader, Item."No.", Quantity, EmissionFee[1]."Country/Region Code", AccountCode, EmissionCO2, EmissionCH4, EmissionN2O);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            Item."No.",
            LibraryRandom.RandInt(10));

        // [WHEN] Update "Unit Price", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 100));
        SalesLine.Validate("Sust. Account No.", AccountCode);

        // [THEN] Verify "CO2e per Unit" must be updated from Item in Sales Line..
        Item.Get(Item."No.");
        Assert.AreEqual(
            ExpectedCO2eEmission,
            SalesLine."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, SalesLine.FieldCaption("CO2e per Unit"), ExpectedCO2eEmission, SalesLine.TableCaption()));
    end;

    [Test]
    procedure VerifyCO2ePerUnitShouldBeUpdatedBasedOnAverageMethod()
    var
        Item: Record Item;
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilitySetup: Record "Sustainability Setup";
        PurchaseHeader: Record "Purchase Header";
        CountryRegion: Record "Country/Region";
        EmissionFee: array[3] of Record "Emission Fee";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        ExpectedCO2eEmission: Decimal;
        EmissionCO2: array[2] of Decimal;
        EmissionCH4: array[2] of Decimal;
        EmissionN2O: array[2] of Decimal;
        Quantity: array[2] of Decimal;
    begin
        // [SCENARIO 537481] Verify "CO2e per Unit" must be updated based on Average Costing Method in Item.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Get Sustainability Setup.
        SustainabilitySetup.Get();

        // [GIVEN] Create Item No.
        LibraryInventory.CreateItem(Item);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", CountryRegion.Code);

        // [GIVEN] Generate Emission and Quantity.
        EmissionCO2[1] := LibraryRandom.RandInt(100);
        EmissionCH4[1] := LibraryRandom.RandInt(100);
        EmissionN2O[1] := LibraryRandom.RandInt(100);
        EmissionCO2[2] := LibraryRandom.RandInt(1000);
        EmissionCH4[2] := LibraryRandom.RandInt(1000);
        EmissionN2O[2] := LibraryRandom.RandInt(1000);
        Quantity[1] := LibraryRandom.RandIntInRange(10, 10);
        Quantity[2] := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Save Expected CO2e Emission .
        ExpectedCO2eEmission :=
            (EmissionCH4[1] * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2[1] * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O[1] * EmissionFee[3]."Carbon Equivalent Factor");
        ExpectedCO2eEmission +=
            (EmissionCH4[2] * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2[2] * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O[2] * EmissionFee[3]."Carbon Equivalent Factor");
        ExpectedCO2eEmission := ExpectedCO2eEmission / (Quantity[1] + Quantity[2]);

        // [WHEN] Post Purchase Document With Emission A and B.
        CreateAndPostPurchaseDocument(PurchaseHeader, Item."No.", Quantity[1], EmissionFee[1]."Country/Region Code", AccountCode, EmissionCO2[1], EmissionCH4[1], EmissionN2O[1]);
        CreateAndPostPurchaseDocument(PurchaseHeader, Item."No.", Quantity[2], EmissionFee[1]."Country/Region Code", AccountCode, EmissionCO2[2], EmissionCH4[2], EmissionN2O[2]);

        // [THEN] Verify "CO2e per Unit" must be updated using Average Costing Method in Item.
        Item.Get(Item."No.");
        Assert.AreEqual(
            ExpectedCO2eEmission,
            Item."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("CO2e per Unit"), ExpectedCO2eEmission, Item.TableCaption()));
    end;

    [Test]
    procedure VerifyCO2ePerUnitShouldBeUpdatedInRoutingLineFromWorkCenter()
    var
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
        WorkCenter: Record "Work Center";
    begin
        // [SCENARIO 537479] Verify "CO2e per Unit" should be updated in Routing Line from Work Center.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify();

        // [GIVEN] Create Routing Header.
        LibraryManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);

        // [WHEN] Create Routing Line with Work Center.
        LibraryManufacturing.CreateRoutingLine(RoutingHeader, RoutingLine, '', Format(LibraryRandom.RandInt(100)), RoutingLine.Type::"Work Center", WorkCenter."No.");
        RoutingHeader.Validate(Status, RoutingHeader.Status::Certified);
        RoutingHeader.Modify(true);

        // [THEN] Verify "CO2e per Unit" should be updated in Routing Line.
        Assert.AreEqual(
            WorkCenter."CO2e per Unit",
            RoutingLine."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, RoutingLine.FieldCaption("CO2e per Unit"), WorkCenter."CO2e per Unit", RoutingLine.TableCaption()));
    end;

    [Test]
    procedure VerifyCO2ePerUnitShouldBeUpdatedInRoutingLineFromMachineCenter()
    var
        WorkCenter: Record "Work Center";
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
        MachineCenter: Record "Machine Center";
    begin
        // [SCENARIO 537479] Verify "CO2e per Unit" should be updated in Routing Line from Machine Center.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);

        // [GIVEN] Create a Machine Center.
        LibraryManufacturing.CreateMachineCenterWithCalendar(MachineCenter, WorkCenter."No.", LibraryRandom.RandInt(10));
        MachineCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        MachineCenter.Modify();

        // [GIVEN] Create Routing Header.
        LibraryManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);

        // [WHEN] Create Routing Line with Machine Center.
        LibraryManufacturing.CreateRoutingLine(RoutingHeader, RoutingLine, '', Format(LibraryRandom.RandInt(100)), RoutingLine.Type::"Machine Center", MachineCenter."No.");
        RoutingHeader.Validate(Status, RoutingHeader.Status::Certified);
        RoutingHeader.Modify(true);

        // [THEN] Verify "CO2e per Unit" should be updated in Routing Line.
        Assert.AreEqual(
            MachineCenter."CO2e per Unit",
            RoutingLine."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, RoutingLine.FieldCaption("CO2e per Unit"), MachineCenter."CO2e per Unit", RoutingLine.TableCaption()));
    end;

    [Test]
    procedure VerifyCO2ePerUnitShouldBeUpdatedInProdBOMLineFromItem()
    var
        ProdItem: Record Item;
        CompItem: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMLine: Record "Production BOM Line";
    begin
        // [SCENARIO 537479] Verify "CO2e per Unit" should be updated in Production BOM Line from Item.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create Items.
        CreateItems(ProdItem, CompItem);

        // [GIVEN] Update "CO2e per Unit" in Component Item.
        CompItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        CompItem.Modify();

        // [GIVEN] Create Production BOM with Component Item.
        LibraryManufacturing.CreateProductionBOMHeader(ProductionBOMHeader, CompItem."Base Unit of Measure");
        LibraryManufacturing.CreateProductionBOMLine(ProductionBOMHeader, ProductionBOMLine, '', ProductionBOMLine.Type::Item, CompItem."No.", 1);
        LibraryManufacturing.UpdateProductionBOMStatus(ProductionBOMHeader, ProductionBOMHeader.Status::Certified);

        // [THEN] Verify "CO2e per Unit" should be updated in Production BOM Line.
        Assert.AreEqual(
            CompItem."CO2e per Unit",
            ProductionBOMLine."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, ProductionBOMLine.FieldCaption("CO2e per Unit"), CompItem."CO2e per Unit", ProductionBOMLine.TableCaption()));
    end;

    [Test]
    procedure VerifySustFieldsShouldBeUpdatedAfterRefreshProductionOrder()
    var
        ProdItem: Record Item;
        CompItem: Record Item;
        RoutingHeader: Record "Routing Header";
        WorkCenter: Record "Work Center";
        ProductionOrder: Record "Production Order";
        ProductionBOMHeader: Record "Production BOM Header";
        SustainabilityAccount: Record "Sustainability Account";
        ProductionOrderLine: Record "Prod. Order Line";
        ProductionOrderRoutingLine: Record "Prod. Order Routing Line";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        Quanity: Decimal;
        ExpectedCO2ePerUnit: Decimal;
    begin
        // [SCENARIO 537479] Verify "Default Sust. Account","CO2e per Unit","Total CO2e" should be updated after refresh Production Order.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("Default Sust. Account", AccountCode);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify();

        // [GIVEN] Create Routing Header.
        RoutingHeader.Get(CreateRoutingWithWorkCenter(WorkCenter, 0));

        // [GIVEN] Create Production and Component Item.
        CreateItems(ProdItem, CompItem);

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Component Item.
        CompItem.Validate("Default Sust. Account", AccountCode);
        CompItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        CompItem.Modify();

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Production Item.
        ProdItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        ProdItem.Modify();

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, 0);

        // [GIVEN] Update "Production BOM No.","Routing No." in Production Item.
        ProdItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ProdItem.Validate("Routing No.", RoutingHeader."No.");
        ProdItem.Modify();

        // [GIVEN] Generate Quantity for Prod Order Line.
        Quanity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create and Refresh Production Order.
        CreateAndRefreshProductionOrder(ProductionOrder, ProductionOrder.Status::Released, ProdItem."No.", Quanity);

        // [GIVEN] Find Prod Order Routing Line.
        ProductionOrderRoutingLine.SetRange(Status, ProductionOrder.Status);
        ProductionOrderRoutingLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProductionOrderRoutingLine.FindFirst();

        // [GIVEN] Generate Expected CO2e per unit for Prod Order Line.
        ExpectedCO2ePerUnit := (ProductionOrderRoutingLine."CO2e per Unit" * GetTotalTimePerOperation(ProductionOrderRoutingLine) + CompItem."CO2e per Unit" * Quanity) / Quanity;

        // [GIVEN] Find Prod Order Line.
        ProductionOrderLine.SetRange(Status, ProductionOrder.Status);
        ProductionOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProductionOrderLine.FindFirst();

        // [WHEN] Update "Sust. Account No." in Prod Order Line.
        ProductionOrderLine.Validate("Sust. Account No.", AccountCode);
        ProductionOrderLine.Modify();

        // [THEN] Verify "Default Sust. Account","CO2e per Unit","Total CO2e" should be updated after refresh Production Order.
        VerifyProductionOrderLine(ProductionOrder, AccountCode, ExpectedCO2ePerUnit, ExpectedCO2ePerUnit * Quanity, 0);
        VerifyProductionOrderComponent(ProductionOrder, CompItem."Default Sust. Account", CompItem."CO2e per Unit", CompItem."CO2e per Unit" * Quanity, 0);
        VerifyProductionOrderRoutingLine(ProductionOrder, WorkCenter."Default Sust. Account", WorkCenter."CO2e per Unit", WorkCenter."CO2e per Unit" * GetTotalTimePerOperation(ProductionOrderRoutingLine), 0);
    end;

    [Test]
    procedure VerifySustFieldsShouldBeUpdatedAfterRefreshProductionOrderUsingUnitCostCalculation()
    var
        ProdItem: Record Item;
        CompItem: Record Item;
        RoutingHeader: Record "Routing Header";
        WorkCenter: Record "Work Center";
        ProductionOrder: Record "Production Order";
        ProductionBOMHeader: Record "Production BOM Header";
        SustainabilityAccount: Record "Sustainability Account";
        ProductionOrderLine: Record "Prod. Order Line";
        ProductionOrderRoutingLine: Record "Prod. Order Routing Line";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        Quanity: Decimal;
        ExpectedCO2ePerUnit: Decimal;
    begin
        // [SCENARIO 560223] Verify "Default Sust. Account","CO2e per Unit","Total CO2e" should be updated after refresh Production Order using "Unit Cost Calculation" as Units.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("Unit Cost Calculation", WorkCenter."Unit Cost Calculation"::Units);
        WorkCenter.Validate("Default Sust. Account", AccountCode);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify();

        // [GIVEN] Create Routing Header.
        RoutingHeader.Get(CreateRoutingWithWorkCenter(WorkCenter, 0));

        // [GIVEN] Create Production and Component Item.
        CreateItems(ProdItem, CompItem);

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Component Item.
        CompItem.Validate("Default Sust. Account", AccountCode);
        CompItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        CompItem.Modify();

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Production Item.
        ProdItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        ProdItem.Modify();

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, 0);

        // [GIVEN] Update "Production BOM No.","Routing No." in Production Item.
        ProdItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ProdItem.Validate("Routing No.", RoutingHeader."No.");
        ProdItem.Modify();

        // [GIVEN] Generate Quantity for Prod Order Line.
        Quanity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create and Refresh Production Order.
        CreateAndRefreshProductionOrder(ProductionOrder, ProductionOrder.Status::Released, ProdItem."No.", Quanity);

        // [GIVEN] Find Prod Order Routing Line.
        ProductionOrderRoutingLine.SetRange(Status, ProductionOrder.Status);
        ProductionOrderRoutingLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProductionOrderRoutingLine.FindFirst();

        // [GIVEN] Generate Expected CO2e per unit for Prod Order Line.
        ExpectedCO2ePerUnit := (ProductionOrderRoutingLine."CO2e per Unit" * Quanity + CompItem."CO2e per Unit" * Quanity) / Quanity;

        // [GIVEN] Find Prod Order Line.
        ProductionOrderLine.SetRange(Status, ProductionOrder.Status);
        ProductionOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProductionOrderLine.FindFirst();

        // [WHEN] Update "Sust. Account No." in Prod Order Line.
        ProductionOrderLine.Validate("Sust. Account No.", AccountCode);
        ProductionOrderLine.Modify();

        // [THEN] Verify "Default Sust. Account","CO2e per Unit","Total CO2e" should be updated after refresh Production Order using "Unit Cost Calculation" as Units.
        VerifyProductionOrderLine(ProductionOrder, AccountCode, ExpectedCO2ePerUnit, ExpectedCO2ePerUnit * Quanity, 0);
        VerifyProductionOrderComponent(ProductionOrder, CompItem."Default Sust. Account", CompItem."CO2e per Unit", CompItem."CO2e per Unit" * Quanity, 0);
        VerifyProductionOrderRoutingLine(ProductionOrder, WorkCenter."Default Sust. Account", WorkCenter."CO2e per Unit", WorkCenter."CO2e per Unit" * Quanity, 0);
    end;

    [Test]
    procedure VerifySustainabilityFieldsShouldBeUpdatedAfterRefreshProductionOrderFromRoutingLineAndProductionBOM()
    var
        ProdItem: Record Item;
        CompItem: Record Item;
        RoutingHeader: Record "Routing Header";
        WorkCenter: Record "Work Center";
        ProductionOrder: Record "Production Order";
        ProductionBOMHeader: Record "Production BOM Header";
        SustainabilityAccount: Record "Sustainability Account";
        ProductionOrderLine: Record "Prod. Order Line";
        ProductionOrderRoutingLine: Record "Prod. Order Routing Line";
        ExpectedCO2ePerUnit: array[2] of Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        Quanity: Decimal;
        ExpectedCO2ePerUnitForProdOrderLine: Decimal;
    begin
        // [SCENARIO 537479] Verify "Default Sust. Account","CO2e per Unit","Total CO2e" should be updated after refresh Production Order from Routing Line and Production BOM.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("Default Sust. Account", AccountCode);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify();

        // [GIVEN] Save Quantity and Expected "CO2e per Unit" for Routing.
        ExpectedCO2ePerUnit[1] := LibraryRandom.RandInt(100);
        Quanity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create Routing Header.
        RoutingHeader.Get(CreateRoutingWithWorkCenter(WorkCenter, ExpectedCO2ePerUnit[1]));

        // [GIVEN] Create Production and Component Item.
        CreateItems(ProdItem, CompItem);

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Component Item.
        CompItem.Validate("Default Sust. Account", AccountCode);
        CompItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        CompItem.Modify();

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Production Item.
        ProdItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        ProdItem.Modify();

        // [GIVEN] Save Expected "CO2e per Unit" for Production BOM.
        ExpectedCO2ePerUnit[2] := LibraryRandom.RandInt(100);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, ExpectedCO2ePerUnit[2]);

        // [GIVEN] Update "Production BOM No.","Routing No." in Production Item.
        ProdItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ProdItem.Validate("Routing No.", RoutingHeader."No.");
        ProdItem.Modify();

        // [GIVEN] Save Expected "CO2e per Unit" for Prod Order Line.
        ExpectedCO2ePerUnitForProdOrderLine := (ExpectedCO2ePerUnit[1] * Quanity + ExpectedCO2ePerUnit[2] * Quanity) / Quanity;

        // [WHEN] Create and Refresh Production Order.
        CreateAndRefreshProductionOrder(ProductionOrder, ProductionOrder.Status::Released, ProdItem."No.", Quanity);

        // [GIVEN] Find Prod Order Routing Line.
        ProductionOrderRoutingLine.SetRange(Status, ProductionOrder.Status);
        ProductionOrderRoutingLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProductionOrderRoutingLine.FindFirst();

        // [GIVEN] Generate Expected CO2e per unit for Prod Order Line.
        ExpectedCO2ePerUnitForProdOrderLine := (ExpectedCO2ePerUnit[1] * GetTotalTimePerOperation(ProductionOrderRoutingLine) + ExpectedCO2ePerUnit[2] * Quanity) / Quanity;

        // [GIVEN] Find Prod Order Line.
        ProductionOrderLine.SetRange(Status, ProductionOrder.Status);
        ProductionOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProductionOrderLine.FindFirst();

        // [WHEN] Update "Sust. Account No." in Prod Order Line.
        ProductionOrderLine.Validate("Sust. Account No.", AccountCode);
        ProductionOrderLine.Modify();

        // [THEN] Verify "Default Sust. Account","CO2e per Unit","Total CO2e" should be updated after refresh Production Order.
        VerifyProductionOrderLine(ProductionOrder, AccountCode, ExpectedCO2ePerUnitForProdOrderLine, ExpectedCO2ePerUnitForProdOrderLine * Quanity, 0);
        VerifyProductionOrderRoutingLine(ProductionOrder, WorkCenter."Default Sust. Account", ExpectedCO2ePerUnit[1], ExpectedCO2ePerUnit[1] * GetTotalTimePerOperation(ProductionOrderRoutingLine), 0);
        VerifyProductionOrderComponent(ProductionOrder, CompItem."Default Sust. Account", ExpectedCO2ePerUnit[2], ExpectedCO2ePerUnit[2] * Quanity, 0);
    end;

    [Test]
    procedure VerifySustainabilityFieldsShouldBeUpdatedFromItemAndWorkCenter()
    var
        ProdItem: Record Item;
        CompItem: Record Item;
        RoutingHeader: Record "Routing Header";
        WorkCenter: Record "Work Center";
        ProductionOrder: Record "Production Order";
        ProductionOrderComponent: Record "Prod. Order Component";
        ProductionOrderRoutingLine: Record "Prod. Order Routing Line";
        ProductionBOMHeader: Record "Production BOM Header";
        SustainabilityAccount: Record "Sustainability Account";
        ExpectedCO2ePerUnit: array[2] of Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537479] Verify "Default Sust. Account","CO2e per Unit","Total CO2e" should be updated from Item and Work Center.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("Default Sust. Account", AccountCode);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify();

        // [GIVEN] Save Expected "CO2e per Unit" for Routing.
        ExpectedCO2ePerUnit[1] := LibraryRandom.RandInt(100);

        // [GIVEN] Create Routing Header.
        RoutingHeader.Get(CreateRoutingWithWorkCenter(WorkCenter, ExpectedCO2ePerUnit[1]));

        // [GIVEN] Create Production and Component Item.
        CreateItems(ProdItem, CompItem);

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Component Item.
        CompItem.Validate("Default Sust. Account", AccountCode);
        CompItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        CompItem.Modify();

        // [GIVEN] Update "Production BOM No.","Routing No.","Default Sust. Account","CO2e per Unit" in Production Item.
        ProdItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ProdItem.Validate("Routing No.", RoutingHeader."No.");
        ProdItem.Validate("Default Sust. Account", AccountCode);
        ProdItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        ProdItem.Modify();

        // [GIVEN] Save Expected "CO2e per Unit" for Production BOM.
        ExpectedCO2ePerUnit[2] := LibraryRandom.RandInt(100);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, ExpectedCO2ePerUnit[2]);

        // [GIVEN] Create and Refresh Production Order.
        CreateAndRefreshProductionOrder(ProductionOrder, ProductionOrder.Status::Released, ProdItem."No.", LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Delete Prod. Order Component.
        ProductionOrderComponent.SetRange(Status, ProductionOrder.Status);
        ProductionOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProductionOrderComponent.DeleteAll();

        // [WHEN] Create Prod. Order Component.
        LibraryManufacturing.CreateProductionOrderComponent(ProductionOrderComponent, ProductionOrder.Status, ProductionOrder."No.", 10000);
        ProductionOrderComponent.Validate("Item No.", CompItem."No.");
        ProductionOrderComponent.Validate("Quantity per", LibraryRandom.RandIntInRange(1, 1));
        ProductionOrderComponent.Modify();

        // [THEN] Verify "Default Sust. Account","CO2e per Unit","Total CO2e" should be updated from Component Item.
        VerifyProductionOrderComponent(ProductionOrder, CompItem."Default Sust. Account", CompItem."CO2e per Unit", CompItem."CO2e per Unit" * 10, 0);

        // [GIVEN] Find Prod. Order Routing Line.
        ProductionOrderRoutingLine.SetRange(Status, ProductionOrder.Status);
        ProductionOrderRoutingLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProductionOrderRoutingLine.FindFirst();

        // [GIVEN] Update "No." in Prod. Order Routing Line.
        ProductionOrderRoutingLine.Validate("No.", '');
        ProductionOrderRoutingLine.Validate("No.", WorkCenter."No.");
        ProductionOrderRoutingLine.Modify();

        // [THEN] Verify "Default Sust. Account","CO2e per Unit","Total CO2e" should be updated from Work Center.
        VerifyProductionOrderRoutingLine(ProductionOrder, WorkCenter."Default Sust. Account", WorkCenter."CO2e per Unit", WorkCenter."CO2e per Unit" * GetTotalTimePerOperation(ProductionOrderRoutingLine), 0);
    end;

    [Test]
    [HandlerFunctions('ProductionJournalModalPageHandler,ConfirmHandler,MessageHandler')]
    procedure VerifyValueEntryShouldBeUpdatedWhenProductionJournalIsPosted()
    var
        ProdItem: Record Item;
        CompItem: Record Item;
        RoutingHeader: Record "Routing Header";
        WorkCenter: Record "Work Center";
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProductionBOMHeader: Record "Production BOM Header";
        ProdOrderComponent: Record "Prod. Order Component";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        ExpectedCO2ePerUnit: array[2] of Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: array[3] of Code[20];
    begin
        // [SCENARIO 537479] Verify Sustainability Value Entry should be created When Production Journal is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account for Work Center.
        CreateSustainabilityAccount(AccountCode[1], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(1, 1));

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("Default Sust. Account", AccountCode[1]);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify();

        // [GIVEN] Save Expected "CO2e per Unit" for Routing.
        ExpectedCO2ePerUnit[1] := LibraryRandom.RandInt(100);

        // [GIVEN] Create Routing Header.
        RoutingHeader.Get(CreateRoutingWithWorkCenter(WorkCenter, ExpectedCO2ePerUnit[1]));

        // [GIVEN] Create Production and Component Item.
        CreateItems(ProdItem, CompItem);

        // [GIVEN] Create a Sustainability Account for Comp Item.
        CreateSustainabilityAccount(AccountCode[2], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(2, 2));

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Component Item.
        CompItem.Validate("Default Sust. Account", AccountCode[2]);
        CompItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        CompItem.Modify();

        // [GIVEN] Post Inventory for Component Item.
        PostInventoryForItem(CompItem."No.");

        // [GIVEN] Create a Sustainability Account for Production Item.
        CreateSustainabilityAccount(AccountCode[3], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(3, 3));

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Production Item.
        ProdItem.Validate("Default Sust. Account", AccountCode[3]);
        ProdItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        ProdItem.Modify();

        // [GIVEN] Save Expected "CO2e per Unit" for Production BOM.
        ExpectedCO2ePerUnit[2] := LibraryRandom.RandInt(100);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, ExpectedCO2ePerUnit[2]);

        // [GIVEN] Update "Production BOM No.","Routing No." in Production Item.
        ProdItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ProdItem.Validate("Routing No.", RoutingHeader."No.");
        ProdItem.Modify();

        // [GIVEN] Create and Refresh Production Order.
        CreateAndRefreshProductionOrder(ProductionOrder, ProductionOrder.Status::Released, ProdItem."No.", LibraryRandom.RandIntInRange(10, 10));

        // [WHEN] Post Production Journal.
        FindProdOrderLine(ProdOrderLine, ProductionOrder, ProdItem."No.");
        LibraryManufacturing.OpenProductionJournal(ProductionOrder, ProdOrderLine."Line No.");

        // [THEN] Verify Sustainability Ledger Entry should not be created When Production Journal is posted.
        SustainabilityLedgerEntry.SetRange("Document No.", ProductionOrder."No.");
        Assert.RecordCount(SustainabilityLedgerEntry, 0);

        SustainabilityValueEntry.SetRange("Document No.", ProductionOrder."No.");
        Assert.RecordCount(SustainabilityValueEntry, 2);

        // [THEN] Verify Sustainability Value Entry should be created for Production Order Line.
        VerifySustLedgerEntryForProductionOrder(ProductionOrder, ProdOrderLine."Sust. Account No.");
        VerifySustValueEntryForProductionOrder(ProductionOrder, ProdOrderLine."Item No.", ProdOrderLine."Total CO2e");

        // [THEN] Verify Sustainability Value Entry should be created for Production Order Component.
        FindProdOrderComponent(ProdOrderComponent, ProductionOrder, CompItem."No.");
        VerifySustLedgerEntryForProductionOrder(ProductionOrder, ProdOrderComponent."Sust. Account No.");
        VerifySustValueEntryForProductionOrder(ProductionOrder, ProdOrderComponent."Item No.", -ProdOrderComponent."Total CO2e");
    end;

    [Test]
    [HandlerFunctions('ProductionJournalModalPageHandler,ConfirmHandler,MessageHandler')]
    procedure VerifyValueEntryShouldBeUpdatedWhenProductionJournalIsPostedWithUnitCostCalculation()
    var
        ProdItem: Record Item;
        CompItem: Record Item;
        RoutingHeader: Record "Routing Header";
        WorkCenter: Record "Work Center";
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProductionBOMHeader: Record "Production BOM Header";
        ProdOrderComponent: Record "Prod. Order Component";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        ExpectedCO2ePerUnit: array[2] of Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: array[3] of Code[20];
    begin
        // [SCENARIO 560223] Verify Sustainability Value Entry should be created When Production Journal is posted using Unit Cost Calculation as Units.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account for Work Center.
        CreateSustainabilityAccount(AccountCode[1], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(1, 1));

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("Unit Cost Calculation", WorkCenter."Unit Cost Calculation"::Units);
        WorkCenter.Validate("Default Sust. Account", AccountCode[1]);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify();

        // [GIVEN] Save Expected "CO2e per Unit" for Routing.
        ExpectedCO2ePerUnit[1] := LibraryRandom.RandInt(100);

        // [GIVEN] Create Routing Header.
        RoutingHeader.Get(CreateRoutingWithWorkCenter(WorkCenter, ExpectedCO2ePerUnit[1]));

        // [GIVEN] Create Production and Component Item.
        CreateItems(ProdItem, CompItem);

        // [GIVEN] Create a Sustainability Account for Comp Item.
        CreateSustainabilityAccount(AccountCode[2], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(2, 2));

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Component Item.
        CompItem.Validate("Default Sust. Account", AccountCode[2]);
        CompItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        CompItem.Modify();

        // [GIVEN] Post Inventory for Component Item.
        PostInventoryForItem(CompItem."No.");

        // [GIVEN] Create a Sustainability Account for Production Item.
        CreateSustainabilityAccount(AccountCode[3], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(3, 3));

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Production Item.
        ProdItem.Validate("Default Sust. Account", AccountCode[3]);
        ProdItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        ProdItem.Modify();

        // [GIVEN] Save Expected "CO2e per Unit" for Production BOM.
        ExpectedCO2ePerUnit[2] := LibraryRandom.RandInt(100);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, ExpectedCO2ePerUnit[2]);

        // [GIVEN] Update "Production BOM No.","Routing No." in Production Item.
        ProdItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ProdItem.Validate("Routing No.", RoutingHeader."No.");
        ProdItem.Modify();

        // [GIVEN] Create and Refresh Production Order.
        CreateAndRefreshProductionOrder(ProductionOrder, ProductionOrder.Status::Released, ProdItem."No.", LibraryRandom.RandIntInRange(10, 10));

        // [WHEN] Post Production Journal.
        FindProdOrderLine(ProdOrderLine, ProductionOrder, ProdItem."No.");
        LibraryManufacturing.OpenProductionJournal(ProductionOrder, ProdOrderLine."Line No.");

        // [THEN] Verify Sustainability Ledger Entry should be created When Production Journal is posted.
        SustainabilityLedgerEntry.SetRange("Document No.", ProductionOrder."No.");
        Assert.RecordCount(SustainabilityLedgerEntry, 0);

        SustainabilityValueEntry.SetRange("Document No.", ProductionOrder."No.");
        Assert.RecordCount(SustainabilityValueEntry, 3);

        // [THEN] Verify Sustainability Value Entry should be created for Production Order Line.
        VerifySustLedgerEntryForProductionOrder(ProductionOrder, ProdOrderLine."Sust. Account No.");
        VerifySustValueEntryForProductionOrder(ProductionOrder, ProdOrderLine."Item No.", ProdOrderLine."Total CO2e");

        // [THEN] Verify Sustainability Value Entry should be created for Production Order Component.
        FindProdOrderComponent(ProdOrderComponent, ProductionOrder, CompItem."No.");
        VerifySustLedgerEntryForProductionOrder(ProductionOrder, ProdOrderComponent."Sust. Account No.");
        VerifySustValueEntryForProductionOrder(ProductionOrder, ProdOrderComponent."Item No.", -ProdOrderComponent."Total CO2e");

        // [THEN] Verify Sustainability Value Entry should be created for Production Order Routing Line.
        FindProdOrderRoutingLine(ProdOrderRoutingLine, ProductionOrder);
        VerifySustValueEntryForProductionOrder(ProductionOrder, '', ExpectedCO2ePerUnit[1] * ProdOrderLine.Quantity);
    end;

    [Test]
    [HandlerFunctions('ProductionJournalModalPageHandlerForRunAndSetupTime,ConfirmHandler,MessageHandler')]
    procedure VerifyValueEntryShouldBeUpdatedWhenProductionJournalIsPostedWithUnitCostCalculationAsTime()
    var
        ProdItem: Record Item;
        CompItem: Record Item;
        RoutingHeader: Record "Routing Header";
        WorkCenter: Record "Work Center";
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProductionBOMHeader: Record "Production BOM Header";
        ProdOrderComponent: Record "Prod. Order Component";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        ExpectedCO2ePerUnit: array[2] of Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: array[3] of Code[20];
    begin
        // [SCENARIO 560223] Verify Sustainability Value Entry should be created When Production Journal is posted using Unit Cost Calculation as Time.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account for Work Center.
        CreateSustainabilityAccount(AccountCode[1], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(1, 1));

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("Unit Cost Calculation", WorkCenter."Unit Cost Calculation"::Time);
        WorkCenter.Validate("Default Sust. Account", AccountCode[1]);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify();

        // [GIVEN] Save Expected "CO2e per Unit" for Routing.
        ExpectedCO2ePerUnit[1] := LibraryRandom.RandInt(100);

        // [GIVEN] Create Routing Header.
        RoutingHeader.Get(CreateRoutingWithWorkCenter(WorkCenter, ExpectedCO2ePerUnit[1]));

        // [GIVEN] Create Production and Component Item.
        CreateItems(ProdItem, CompItem);

        // [GIVEN] Create a Sustainability Account for Comp Item.
        CreateSustainabilityAccount(AccountCode[2], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(2, 2));

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Component Item.
        CompItem.Validate("Default Sust. Account", AccountCode[2]);
        CompItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        CompItem.Modify();

        // [GIVEN] Post Inventory for Component Item.
        PostInventoryForItem(CompItem."No.");

        // [GIVEN] Create a Sustainability Account for Production Item.
        CreateSustainabilityAccount(AccountCode[3], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(3, 3));

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Production Item.
        ProdItem.Validate("Default Sust. Account", AccountCode[3]);
        ProdItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        ProdItem.Modify();

        // [GIVEN] Save Expected "CO2e per Unit" for Production BOM.
        ExpectedCO2ePerUnit[2] := LibraryRandom.RandInt(100);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, ExpectedCO2ePerUnit[2]);

        // [GIVEN] Update "Production BOM No.","Routing No." in Production Item.
        ProdItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ProdItem.Validate("Routing No.", RoutingHeader."No.");
        ProdItem.Modify();

        // [GIVEN] Create and Refresh Production Order.
        CreateAndRefreshProductionOrder(ProductionOrder, ProductionOrder.Status::Released, ProdItem."No.", LibraryRandom.RandIntInRange(10, 10));

        // [WHEN] Post Production Journal.
        FindProdOrderLine(ProdOrderLine, ProductionOrder, ProdItem."No.");
        LibraryManufacturing.OpenProductionJournal(ProductionOrder, ProdOrderLine."Line No.");

        // [THEN] Verify Sustainability Ledger Entry should be created When Production Journal is posted.
        SustainabilityLedgerEntry.SetRange("Document No.", ProductionOrder."No.");
        Assert.RecordCount(SustainabilityLedgerEntry, 0);

        SustainabilityValueEntry.SetRange("Document No.", ProductionOrder."No.");
        Assert.RecordCount(SustainabilityValueEntry, 3);

        // [THEN] Verify Sustainability Value Entry should be created for Production Order Line.
        VerifySustLedgerEntryForProductionOrder(ProductionOrder, ProdOrderLine."Sust. Account No.");
        VerifySustValueEntryForProductionOrder(ProductionOrder, ProdOrderLine."Item No.", ProdOrderLine."Total CO2e");

        // [THEN] Verify Sustainability Value Entry should be created for Production Order Component.
        FindProdOrderComponent(ProdOrderComponent, ProductionOrder, CompItem."No.");
        VerifySustLedgerEntryForProductionOrder(ProductionOrder, ProdOrderComponent."Sust. Account No.");
        VerifySustValueEntryForProductionOrder(ProductionOrder, ProdOrderComponent."Item No.", -ProdOrderComponent."Total CO2e");

        // [THEN] Verify Sustainability Value Entry should be created for Production Order Routing Line.
        FindProdOrderRoutingLine(ProdOrderRoutingLine, ProductionOrder);
        VerifySustValueEntryForProductionOrder(ProductionOrder, '', ExpectedCO2ePerUnit[1] * 10);
    end;

    [Test]
    [HandlerFunctions('PartiallyPostProductionJournalModalPageHandler,ConfirmHandler,MessageHandler')]
    procedure VerifyValueEntryShouldBeUpdatedWhenProductionJournalIsPartiallyPosted()
    var
        ProdItem: Record Item;
        CompItem: Record Item;
        RoutingHeader: Record "Routing Header";
        WorkCenter: Record "Work Center";
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProductionBOMHeader: Record "Production BOM Header";
        ProdOrderComponent: Record "Prod. Order Component";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        ExpectedCO2ePerUnit: array[2] of Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: array[3] of Code[20];
    begin
        // [SCENARIO 537479] Verify Sustainability Value Entry should be created When Production Journal is partially posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account for Work Center.
        CreateSustainabilityAccount(AccountCode[1], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(1, 1));

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("Default Sust. Account", AccountCode[1]);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify();

        // [GIVEN] Save Expected "CO2e per Unit" for Routing.
        ExpectedCO2ePerUnit[1] := LibraryRandom.RandInt(100);

        // [GIVEN] Create Routing Header.
        RoutingHeader.Get(CreateRoutingWithWorkCenter(WorkCenter, ExpectedCO2ePerUnit[1]));

        // [GIVEN] Create Production and Component Item.
        CreateItems(ProdItem, CompItem);

        // [GIVEN] Create a Sustainability Account for Comp Item.
        CreateSustainabilityAccount(AccountCode[2], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(2, 2));

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Component Item.
        CompItem.Validate("Default Sust. Account", AccountCode[2]);
        CompItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        CompItem.Modify();

        // [GIVEN] Post Inventory for Component Item.
        PostInventoryForItem(CompItem."No.");

        // [GIVEN] Create a Sustainability Account for Production Item.
        CreateSustainabilityAccount(AccountCode[3], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(3, 3));

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Production Item.
        ProdItem.Validate("Default Sust. Account", AccountCode[3]);
        ProdItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        ProdItem.Modify();

        // [GIVEN] Save Expected "CO2e per Unit" for Production BOM.
        ExpectedCO2ePerUnit[2] := LibraryRandom.RandInt(100);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, ExpectedCO2ePerUnit[2]);

        // [GIVEN] Update "Production BOM No.","Routing No." in Production Item.
        ProdItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ProdItem.Validate("Routing No.", RoutingHeader."No.");
        ProdItem.Modify();

        // [GIVEN] Create and Refresh Production Order.
        CreateAndRefreshProductionOrder(ProductionOrder, ProductionOrder.Status::Released, ProdItem."No.", LibraryRandom.RandIntInRange(10, 10));

        // [WHEN] Post Production Journal.
        FindProdOrderLine(ProdOrderLine, ProductionOrder, ProdItem."No.");
        LibraryManufacturing.OpenProductionJournal(ProductionOrder, ProdOrderLine."Line No.");

        // [THEN] Verify Sustainability Ledger Entry should be created When Production Journal is posted.
        SustainabilityLedgerEntry.SetRange("Document No.", ProductionOrder."No.");
        Assert.RecordCount(SustainabilityLedgerEntry, 0);

        SustainabilityValueEntry.SetRange("Document No.", ProductionOrder."No.");
        Assert.RecordCount(SustainabilityValueEntry, 2);

        // [THEN] Verify Sustainability Value Entry should be created for Production Order Line.
        FindProdOrderLine(ProdOrderLine, ProductionOrder, ProdItem."No.");
        VerifySustLedgerEntryForProductionOrder(ProductionOrder, ProdOrderLine."Sust. Account No.");
        VerifySustValueEntryForProductionOrder(ProductionOrder, ProdOrderLine."Item No.", 5 * ProdOrderLine."CO2e per Unit");

        // [THEN] Verify Sustainability Value Entry should be created for Production Order Component.
        FindProdOrderComponent(ProdOrderComponent, ProductionOrder, CompItem."No.");
        VerifySustLedgerEntryForProductionOrder(ProductionOrder, ProdOrderComponent."Sust. Account No.");
        VerifySustValueEntryForProductionOrder(ProductionOrder, ProdOrderComponent."Item No.", -5 * ProdOrderComponent."CO2e per Unit");
    end;

    [Test]
    procedure VerifyTypeAndNoFieldInSustValueEntryForItemWhenPurchaseDocumentIsPosted()
    var
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        AccountCode: Code[20];
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        PostedInvNo: Code[20];
    begin
        // [SCENARIO 563733] Verify Type and No. in Sustainability Value Entry for item When Purchase Document is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Generate Emission.
        EmissionCO2PerUnit := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4PerUnit := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2OPerUnit := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create an item with "Replenishment System" and "Default Sust. Account".
        LibraryInventory.CreateItem(Item);
        Item.Validate("Replenishment System", Item."Replenishment System"::Purchase);
        Item.Validate("Default Sust. Account", AccountCode);
        Item.Modify();

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            Item."No.",
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Emission CO2 Per Unit" ,"Emission CH4 Per Unit" ,"Emission N2O Per Unit" in Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify(true);

        // [WHEN] Post Purchase Document with Receiving and Invoicing.
        PostedInvNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify Type and No. in Sustainability Value Entry for item When Purchase Document is posted.
        SustainabilityValueEntry.SetRange("Document No.", PostedInvNo);
        SustainabilityValueEntry.FindFirst();
        Assert.AreEqual(
            SustainabilityValueEntry.Type::Item,
            SustainabilityValueEntry.Type,
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption(Type), SustainabilityValueEntry.Type::Item, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            Item."No.",
            SustainabilityValueEntry."No.",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("No."), Item."No.", SustainabilityValueEntry.TableCaption()));
    end;

    [Test]
    [HandlerFunctions('ProductionJournalModalPageHandlerForRunAndSetupTime,ConfirmHandler,MessageHandler')]
    procedure VerifyTypeAndNoFieldInSustValueEntryForWorkAndMachineCenterInProductionOrder()
    var
        ProdItem: Record Item;
        CompItem: Record Item;
        RoutingHeader: Record "Routing Header";
        WorkCenter: Record "Work Center";
        MachineCenter: Record "Machine Center";
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProductionBOMHeader: Record "Production BOM Header";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        ExpectedCO2ePerUnit: array[2] of Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: array[3] of Code[20];
    begin
        // [SCENARIO 563733] Verify Type and No. in Sustainability Value Entry for Item, Machine Center and Work Center When Production Journal is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account for Work and Machine Center.
        CreateSustainabilityAccount(AccountCode[1], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(1, 1));

        // [GIVEN] Create a Work Center.
        LibraryManufacturing.CreateWorkCenterWithCalendar(WorkCenter);
        WorkCenter.Validate("Unit Cost Calculation", WorkCenter."Unit Cost Calculation"::Time);
        WorkCenter.Validate("Default Sust. Account", AccountCode[1]);
        WorkCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        WorkCenter.Modify();

        // [GIVEN] Create a Machine Center.
        LibraryManufacturing.CreateMachineCenterWithCalendar(MachineCenter, WorkCenter."No.", LibraryRandom.RandIntInRange(1, 1));
        MachineCenter.Validate("Default Sust. Account", AccountCode[1]);
        MachineCenter.Validate("CO2e per Unit", LibraryRandom.RandInt(10));
        MachineCenter.Modify();

        // [GIVEN] Save Expected "CO2e per Unit" for Routing.
        ExpectedCO2ePerUnit[1] := LibraryRandom.RandInt(100);

        // [GIVEN] Create Routing Header.
        RoutingHeader.Get(CreateRoutingWithWorkAndMachineCenter(WorkCenter, MachineCenter, ExpectedCO2ePerUnit[1]));

        // [GIVEN] Create Production and Component Item.
        CreateItems(ProdItem, CompItem);

        // [GIVEN] Create a Sustainability Account for Comp Item.
        CreateSustainabilityAccount(AccountCode[2], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(2, 2));

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Component Item.
        CompItem.Validate("Default Sust. Account", AccountCode[2]);
        CompItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        CompItem.Modify();

        // [GIVEN] Post Inventory for Component Item.
        PostInventoryForItem(CompItem."No.");

        // [GIVEN] Create a Sustainability Account for Production Item.
        CreateSustainabilityAccount(AccountCode[3], CategoryCode, SubcategoryCode, LibraryRandom.RandIntInRange(3, 3));

        // [GIVEN] Update "Default Sust. Account","CO2e per Unit" in Production Item.
        ProdItem.Validate("Default Sust. Account", AccountCode[3]);
        ProdItem.Validate("CO2e per Unit", LibraryRandom.RandInt(100));
        ProdItem.Modify();

        // [GIVEN] Save Expected "CO2e per Unit" for Production BOM.
        ExpectedCO2ePerUnit[2] := LibraryRandom.RandInt(100);

        // [GIVEN] Create Production BOM.
        CreateProductionBOM(ProductionBOMHeader, CompItem, ExpectedCO2ePerUnit[2]);

        // [GIVEN] Update "Production BOM No.","Routing No." in Production Item.
        ProdItem.Validate("Production BOM No.", ProductionBOMHeader."No.");
        ProdItem.Validate("Routing No.", RoutingHeader."No.");
        ProdItem.Modify();

        // [GIVEN] Create and Refresh Production Order.
        CreateAndRefreshProductionOrder(ProductionOrder, ProductionOrder.Status::Released, ProdItem."No.", LibraryRandom.RandIntInRange(10, 10));

        // [WHEN] Post Production Journal.
        FindProdOrderLine(ProdOrderLine, ProductionOrder, ProdItem."No.");
        LibraryManufacturing.OpenProductionJournal(ProductionOrder, ProdOrderLine."Line No.");

        // [THEN] Verify Type and No. in Sustainability Value Entry for Item, Machine Center and Work Center When Production Journal is posted.
        Assert.RecordCount(SustainabilityValueEntry, 4);

        // [THEN] Verify Type and No. in Sustainability Value Entry for Work Center When Production Journal is posted.
        SustainabilityValueEntry.SetRange("Document No.", ProductionOrder."No.");
        SustainabilityValueEntry.SetRange(Type, SustainabilityValueEntry.Type::"Work Center");
        SustainabilityValueEntry.SetRange("No.", WorkCenter."No.");
        Assert.RecordCount(SustainabilityValueEntry, 1);

        // [THEN] Verify Type and No. in Sustainability Value Entry for Machine Center When Production Journal is posted.
        SustainabilityValueEntry.SetRange(Type, SustainabilityValueEntry.Type::"Machine Center");
        SustainabilityValueEntry.SetRange("No.", MachineCenter."No.");
        Assert.RecordCount(SustainabilityValueEntry, 1);

        // [THEN] Verify Type and No. in Sustainability Value Entry for Production item When Production Journal is posted.
        SustainabilityValueEntry.SetRange(Type, SustainabilityValueEntry.Type::Item);
        SustainabilityValueEntry.SetRange("No.", ProdItem."No.");
        Assert.RecordCount(SustainabilityValueEntry, 1);

        // [THEN] Verify Type and No. in Sustainability Value Entry for Component item When Production Journal is posted.
        SustainabilityValueEntry.SetRange(Type, SustainabilityValueEntry.Type::Item);
        SustainabilityValueEntry.SetRange("No.", CompItem."No.");
        Assert.RecordCount(SustainabilityValueEntry, 1);
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

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the PurchaseOrderStatistics action. The new action uses RunObject and does not run the action trigger. Use a page extension to modify the behaviour.', '26.0')]
    local procedure OpenPurchaseOrderStatistics(No: Code[20])
    var
        PurchaseOrder: TestPage "Purchase Order";
    begin
        PurchaseOrder.OpenEdit();
        PurchaseOrder.FILTER.SetFilter("No.", No);
        PurchaseOrder.Statistics.Invoke();
    end;
#endif

    local procedure OpenPurchOrderStatistics(No: Code[20])
    var
        PurchaseOrder: TestPage "Purchase Order";
    begin
        PurchaseOrder.OpenEdit();
        PurchaseOrder.FILTER.SetFilter("No.", No);
        PurchaseOrder.PurchaseOrderStatistics.Invoke();
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

    local procedure UpdateReasonCodeinSalesHeader(var SalesHeader: Record "Sales Header")
    var
        ReasonCode: Record "Reason Code";
    begin
        LibraryERM.CreateReasonCode(ReasonCode);

        SalesHeader.Validate("Reason Code", ReasonCode.Code);
        SalesHeader.Modify();
    end;

    local procedure PostAndVerifyCancelSalesCreditMemo(SalesHeader: Record "Sales Header")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        PostedDocNumber: Code[20];
    begin
        PostedDocNumber := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocNumber);
        CorrectPostedSalesInvoice.CancelPostedInvoice(SalesInvoiceHeader);
    end;

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the SalesStatistics action. The new action uses RunObject and does not run the action trigger.', '26.0')]
    local procedure OpenSalesOrderStatistics(No: Code[20])
    var
        SalesOrder: TestPage "Sales Order";
    begin
        SalesOrder.OpenEdit();
        SalesOrder.FILTER.SetFilter("No.", No);
        SalesOrder.Statistics.Invoke();
    end;
#endif
    local procedure OpenSalesOrderStatisticsNM(No: Code[20])
    var
        SalesOrder: TestPage "Sales Order";
    begin
        SalesOrder.OpenEdit();
        SalesOrder.FILTER.SetFilter("No.", No);
        SalesOrder.SalesOrderStatistics.Invoke();
    end;

    local procedure VerifyPostedSalesInvoiceStatistics(No: Code[20])
    var
        PostedSalesInvoiceStatisticsPage: TestPage "Sales Invoice Statistics";
        PostedTotalCO2e: Variant;
    begin
        LibraryVariableStorage.Dequeue(PostedTotalCO2e);

        PostedSalesInvoiceStatisticsPage.OpenEdit();
        PostedSalesInvoiceStatisticsPage.FILTER.SetFilter("No.", No);
        PostedSalesInvoiceStatisticsPage."Total CO2e".AssertEquals(PostedTotalCO2e);
    end;

    local procedure CreateAndPostPurchaseDocument(var PurchaseHeader: Record "Purchase Header"; ItemNo: Code[20]; Quantity: Decimal; CountryRegionCode: Code[10]; AccountCode: Code[20]; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal): Code[20]
    var
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader."Buy-from Country/Region Code" := CountryRegionCode;
        PurchaseHeader.Modify();

        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, ItemNo, Quantity);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure PostInventoryForItem(ItemNo: Code[20])
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
    begin
        SelectItemJournalBatch(ItemJournalBatch);
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name, ItemJournalLine."Entry Type"::Purchase, ItemNo, LibraryRandom.RandIntInRange(100, 100));
        LibraryInventory.PostItemJournalBatch(ItemJournalBatch);
    end;

    local procedure SelectItemJournalBatch(var ItemJournalBatch: Record "Item Journal Batch")
    var
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        SelectItemJournalBatchByTemplateType(ItemJournalBatch, ItemJournalTemplate.Type::Item);
    end;

    local procedure SelectItemJournalBatchByTemplateType(var ItemJournalBatch: Record "Item Journal Batch"; TemplateType: Enum "Item Journal Template Type")
    var
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        LibraryInventory.SelectItemJournalTemplateName(ItemJournalTemplate, TemplateType);
        LibraryInventory.SelectItemJournalBatchName(ItemJournalBatch, ItemJournalTemplate.Type, ItemJournalTemplate.Name);
    end;

    local procedure FindProdOrderLine(var ProdOrderLine: Record "Prod. Order Line"; ProductionOrder: Record "Production Order"; ItemNo: Code[20])
    begin
        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderLine.SetRange("Item No.", ItemNo);
        ProdOrderLine.FindFirst();
    end;

    local procedure FindProdOrderComponent(var ProdOrderComponent: Record "Prod. Order Component"; ProductionOrder: Record "Production Order"; ItemNo: Code[20])
    begin
        ProdOrderComponent.SetRange(Status, ProductionOrder.Status);
        ProdOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderComponent.SetRange("Item No.", ItemNo);
        ProdOrderComponent.FindFirst();
    end;

    local procedure FindProdOrderRoutingLine(var ProdOrderRoutingLine: Record "Prod. Order Routing Line"; ProductionOrder: Record "Production Order")
    begin
        ProdOrderRoutingLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderRoutingLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderRoutingLine.FindFirst();
    end;

    local procedure CreateRoutingWithWorkCenter(var WorkCenter: Record "Work Center"; CO2ePerUnit: Decimal): Code[20]
    var
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
    begin
        LibraryManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);
        LibraryManufacturing.CreateRoutingLine(RoutingHeader, RoutingLine, '', Format(LibraryRandom.RandInt(100)), RoutingLine.Type::"Work Center", WorkCenter."No.");
        if CO2ePerUnit <> 0 then begin
            RoutingLine.Validate("CO2e per Unit", CO2ePerUnit);
            RoutingLine.Modify();
        end;

        RoutingHeader.Validate(Status, RoutingHeader.Status::Certified);
        RoutingHeader.Modify(true);

        exit(RoutingHeader."No.");
    end;

    local procedure CreateRoutingWithWorkAndMachineCenter(var WorkCenter: Record "Work Center"; var MachineCenter: Record "Machine Center"; CO2ePerUnit: Decimal): Code[20]
    var
        RoutingHeader: Record "Routing Header";
        RoutingLine1: Record "Routing Line";
        RoutingLine2: Record "Routing Line";
    begin
        LibraryManufacturing.CreateRoutingHeader(RoutingHeader, RoutingHeader.Type::Serial);
        LibraryManufacturing.CreateRoutingLine(RoutingHeader, RoutingLine1, '', Format(LibraryRandom.RandInt(100)), RoutingLine1.Type::"Work Center", WorkCenter."No.");
        if CO2ePerUnit <> 0 then begin
            RoutingLine1.Validate("CO2e per Unit", CO2ePerUnit);
            RoutingLine1.Modify();
        end;

        // Create Routing Line with Machine Center
        LibraryManufacturing.CreateRoutingLine(RoutingHeader, RoutingLine2, '', Format(LibraryRandom.RandInt(100)), RoutingLine2.Type::"Machine Center", MachineCenter."No.");
        if CO2ePerUnit <> 0 then begin
            RoutingLine2.Validate("CO2e per Unit", CO2ePerUnit);
            RoutingLine2.Modify();
        end;

        RoutingHeader.Validate(Status, RoutingHeader.Status::Certified);
        RoutingHeader.Modify(true);

        exit(RoutingHeader."No.");
    end;

    local procedure CreateItems(var ProdItem: Record Item; var CompItem: Record Item)
    begin
        LibraryInventory.CreateItem(CompItem);
        LibraryInventory.CreateItem(ProdItem);
        ProdItem.Validate("Costing Method", ProdItem."Costing Method"::Standard);
        ProdItem.Validate("Replenishment System", ProdItem."Replenishment System"::"Prod. Order");
        ProdItem.Modify(true);
    end;

    local procedure CreateProductionBOM(var ProductionBOMHeader: Record "Production BOM Header"; CompItem: Record Item; CO2ePerUnit: Decimal)
    var
        ProductionBOMLine: Record "Production BOM Line";
    begin
        LibraryManufacturing.CreateProductionBOMHeader(ProductionBOMHeader, CompItem."Base Unit of Measure");
        LibraryManufacturing.CreateProductionBOMLine(ProductionBOMHeader, ProductionBOMLine, '', ProductionBOMLine.Type::Item, CompItem."No.", 1);
        if CO2ePerUnit <> 0 then begin
            ProductionBOMLine.Validate("CO2e per Unit", CO2ePerUnit);
            ProductionBOMLine.Modify();
        end;
        LibraryManufacturing.UpdateProductionBOMStatus(ProductionBOMHeader, ProductionBOMHeader.Status::Certified);
    end;

    local procedure CreateAndRefreshProductionOrder(var ProductionOrder: Record "Production Order"; Status: Enum "Production Order Status"; SourceNo: Code[20]; Quantity: Decimal)
    begin
        LibraryManufacturing.CreateProductionOrder(ProductionOrder, Status, ProductionOrder."Source Type"::Item, SourceNo, Quantity);

        LibraryManufacturing.RefreshProdOrder(ProductionOrder, false, true, true, true, false);
    end;

    local procedure VerifyProductionOrderLine(ProductionOrder: Record "Production Order"; AccountCode: Code[20]; CO2ePerUnit: Decimal; TotalCO2e: Decimal; PostedTotalCO2e: Decimal)
    var
        ProductionOrderLine: Record "Prod. Order Line";
    begin
        ProductionOrderLine.SetRange(Status, ProductionOrder.Status);
        ProductionOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProductionOrderLine.FindFirst();

        Assert.AreEqual(
            AccountCode,
            ProductionOrderLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, ProductionOrderLine.FieldCaption("Sust. Account No."), AccountCode, ProductionOrderLine.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit,
            ProductionOrderLine."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, ProductionOrderLine.FieldCaption("CO2e per Unit"), CO2ePerUnit, ProductionOrderLine.TableCaption()));
        Assert.AreEqual(
            TotalCO2e,
            ProductionOrderLine."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ProductionOrderLine.FieldCaption("Total CO2e"), TotalCO2e, ProductionOrderLine.TableCaption()));
        Assert.AreEqual(
            PostedTotalCO2e,
            ProductionOrderLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ProductionOrderLine.FieldCaption("Posted Total CO2e"), PostedTotalCO2e, ProductionOrderLine.TableCaption()));
    end;

    local procedure VerifyProductionOrderComponent(ProductionOrder: Record "Production Order"; AccountCode: Code[20]; CO2ePerUnit: Decimal; TotalCO2e: Decimal; PostedTotalCO2e: Decimal)
    var
        ProductionOrderComponent: Record "Prod. Order Component";
    begin
        ProductionOrderComponent.SetRange(Status, ProductionOrder.Status);
        ProductionOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProductionOrderComponent.FindFirst();

        Assert.AreEqual(
            AccountCode,
            ProductionOrderComponent."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, ProductionOrderComponent.FieldCaption("Sust. Account No."), AccountCode, ProductionOrderComponent.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit,
            ProductionOrderComponent."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, ProductionOrderComponent.FieldCaption("CO2e per Unit"), CO2ePerUnit, ProductionOrderComponent.TableCaption()));
        Assert.AreEqual(
            TotalCO2e,
            ProductionOrderComponent."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ProductionOrderComponent.FieldCaption("Total CO2e"), TotalCO2e, ProductionOrderComponent.TableCaption()));
        Assert.AreEqual(
            PostedTotalCO2e,
            ProductionOrderComponent."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ProductionOrderComponent.FieldCaption("Posted Total CO2e"), PostedTotalCO2e, ProductionOrderComponent.TableCaption()));
    end;

    local procedure VerifyProductionOrderRoutingLine(ProductionOrder: Record "Production Order"; AccountCode: Code[20]; CO2ePerUnit: Decimal; TotalCO2e: Decimal; PostedTotalCO2e: Decimal)
    var
        ProductionOrderRoutingLine: Record "Prod. Order Routing Line";
    begin
        ProductionOrderRoutingLine.SetRange(Status, ProductionOrder.Status);
        ProductionOrderRoutingLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProductionOrderRoutingLine.FindFirst();

        Assert.AreEqual(
            AccountCode,
            ProductionOrderRoutingLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, ProductionOrderRoutingLine.FieldCaption("Sust. Account No."), AccountCode, ProductionOrderRoutingLine.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit,
            ProductionOrderRoutingLine."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, ProductionOrderRoutingLine.FieldCaption("CO2e per Unit"), CO2ePerUnit, ProductionOrderRoutingLine.TableCaption()));
        Assert.AreEqual(
            TotalCO2e,
            ProductionOrderRoutingLine."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ProductionOrderRoutingLine.FieldCaption("Total CO2e"), TotalCO2e, ProductionOrderRoutingLine.TableCaption()));
        Assert.AreEqual(
            PostedTotalCO2e,
            ProductionOrderRoutingLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, ProductionOrderRoutingLine.FieldCaption("Posted Total CO2e"), PostedTotalCO2e, ProductionOrderRoutingLine.TableCaption()));
    end;

    local procedure VerifySustLedgerEntryForProductionOrder(ProductionOrder: Record "Production Order"; AccountCode: Code[20])
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
    begin
        SustainabilityLedgerEntry.SetRange("Document No.", ProductionOrder."No.");
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        Assert.RecordCount(SustainabilityLedgerEntry, 0);
    end;

    local procedure VerifySustValueEntryForProductionOrder(ProductionOrder: Record "Production Order"; ItemNo: Code[20]; ExpectedCO2eEmission: Decimal)
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
    begin
        SustainabilityValueEntry.SetRange("Document No.", ProductionOrder."No.");
        SustainabilityValueEntry.SetRange("Item No.", ItemNo);
        SustainabilityValueEntry.FindFirst();
        Assert.AreEqual(
            ExpectedCO2eEmission,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), ExpectedCO2eEmission, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));
    end;

    local procedure GetTotalTimePerOperation(var ProdOrderRoutingLine: Record "Prod. Order Routing Line"): Decimal
    var
        CalendarMgt: Codeunit "Shop Calendar Management";
    begin
        exit(
            (ProdOrderRoutingLine."Run Time" * CalendarMgt.QtyperTimeUnitofMeasure(ProdOrderRoutingLine."Work Center No.", ProdOrderRoutingLine."Run Time Unit of Meas. Code")) +
            (ProdOrderRoutingLine."Setup Time" * CalendarMgt.QtyperTimeUnitofMeasure(ProdOrderRoutingLine."Work Center No.", ProdOrderRoutingLine."Setup Time Unit of Meas. Code")) +
            (ProdOrderRoutingLine."Move Time" * CalendarMgt.QtyperTimeUnitofMeasure(ProdOrderRoutingLine."Work Center No.", ProdOrderRoutingLine."Move Time Unit of Meas. Code")) +
            (ProdOrderRoutingLine."Wait Time" * CalendarMgt.QtyperTimeUnitofMeasure(ProdOrderRoutingLine."Work Center No.", ProdOrderRoutingLine."Wait Time Unit of Meas. Code")));
    end;

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the PurchaseOrderStatistics action. The new action uses RunObject and does not run the action trigger. Use a page extension to modify the behaviour.', '26.0')]
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
#endif

    [PageHandler]
    [Scope('OnPrem')]
    procedure PurchOrderStatisticsPageHandler(var PurchaseOrderStatisticsPage: TestPage "Purchase Order Statistics")
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
    procedure GLPostingPreviewHandlerForSales(var GLPostingPreview: TestPage "G/L Posting Preview")
    begin
        GLPostingPreview.Filter.SetFilter("Table ID", Format(Database::"Sustainability Value Entry"));
        GLPostingPreview."No. of Records".AssertEquals(1);

        GLPostingPreview.Filter.SetFilter("Table ID", Format(Database::"Sustainability Ledger Entry"));
        GLPostingPreview."No. of Records".AssertEquals('');
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
    procedure NavigateFindEntriesHandlerForSales(var Navigate: TestPage Navigate)
    begin
        Navigate.Filter.SetFilter("Table ID", Format(Database::"Sustainability Ledger Entry"));
        Navigate."No. of Records".AssertEquals('');

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

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the SalesStatistics action. The new action uses RunObject and does not run the action trigger.', '26.0')]
    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure SalesOrderStatisticsPageHandler(var SalesOrderStatisticsPage: TestPage "Sales Order Statistics")
    var
        TotalCO2e: Variant;
        PostedTotalCO2e: Variant;
    begin
        LibraryVariableStorage.Dequeue(TotalCO2e);
        LibraryVariableStorage.Dequeue(PostedTotalCO2e);

        SalesOrderStatisticsPage."Total CO2e".AssertEquals(TotalCO2e);
        SalesOrderStatisticsPage."Posted Total CO2e".AssertEquals(PostedTotalCO2e);
    end;
#endif
    [PageHandler]
    [Scope('OnPrem')]
    procedure SalesOrderStatisticsPageHandlerNM(var SalesOrderStatisticsPage: TestPage "Sales Order Statistics")
    var
        TotalCO2e: Variant;
        PostedTotalCO2e: Variant;
    begin
        LibraryVariableStorage.Dequeue(TotalCO2e);
        LibraryVariableStorage.Dequeue(PostedTotalCO2e);

        SalesOrderStatisticsPage."Total CO2e".AssertEquals(TotalCO2e);
        SalesOrderStatisticsPage."Posted Total CO2e".AssertEquals(PostedTotalCO2e);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ProductionJournalModalPageHandler(var ProductionJournal: TestPage "Production Journal")
    begin
        ProductionJournal.Post.Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ProductionJournalModalPageHandlerForRunAndSetupTime(var ProductionJournal: TestPage "Production Journal")
    begin
        ProductionJournal.First();
        repeat
            if ProductionJournal."No.".Value <> '' then begin
                ProductionJournal."Run Time".SetValue(LibraryRandom.RandIntInRange(5, 5));
                ProductionJournal."Setup Time".SetValue(LibraryRandom.RandIntInRange(5, 5));
            end;
        until not ProductionJournal.Next();

        ProductionJournal.Post.Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure PartiallyPostProductionJournalModalPageHandler(var ProductionJournal: TestPage "Production Journal")
    begin
        ProductionJournal.First();
        repeat
            ProductionJournal.Quantity.SetValue(LibraryRandom.RandIntInRange(5, 5));
            if ProductionJournal."No.".Value <> '' then
                ProductionJournal."Output Quantity".SetValue(LibraryRandom.RandIntInRange(5, 5));
        until not ProductionJournal.Next();

        ProductionJournal.Post.Invoke();
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;
}