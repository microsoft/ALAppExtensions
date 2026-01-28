namespace Microsoft.Test.Sustainability;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Posting;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.Document;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Emission;
using Microsoft.Sustainability.Ledger;

codeunit 148219 "Sust. Value Chain Fixed Asset"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Assert";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibrarySustainability: Codeunit "Library - Sustainability";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        IsInitialized: Boolean;
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';
        ValueMustBeEqualErr: Label '%1 must be equal to %2 in the %3.', Comment = '%1 = Field Caption , %2 = Expected Value, %3 = Table Caption';
        FAPostingTypeErr: Label '%1 must be equal to ''Acquisition Cost''', Comment = '%1 = FA Posting Type Field Caption';
        CO2eMustNotBeZeroErr: Label 'The CO2e fields must have a value that is not 0.';

    [Test]
    procedure TestSustValueChainFixedAssetForPurchaseInvoicePosting()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SustainabilityAccount: Record "Sustainability Account";
        DepreciationBook: Record "Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        EmissionFee: array[3] of Record "Emission Fee";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
        PostedDocumentNo: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580142] [Sustainability] - Value Chain: Fixed Assets (🌱)
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee";

        // [GIVEN] Create a Fixed Asset.
        CreateFixedAssetSetup(DepreciationBook);
        LibraryFixedAsset.CreateFAWithPostingGroup(FixedAsset);
        CreateFADepreciationBook(FixedAsset."No.", DepreciationBook.Code, FixedAsset."FA Posting Group");
        UpdateIntegrationInBook(DepreciationBook, true, true, true, true, true, true, true);

        // [GIVEN] Update "Default Sust. Account", "Default CO2 Emission", "Default CH4 Emission", "Default N2O Emission" in a Fixed Asset.
        FixedAsset.Validate("Default Sust. Account", SustainabilityAccount."No.");
        FixedAsset.Validate("Default CO2 Emission", EmissionCO2);
        FixedAsset.Validate("Default CH4 Emission", EmissionCH4);
        FixedAsset.Validate("Default N2O Emission", EmissionN2O);
        FixedAsset.Modify(true);

        // [GIVEN] Create a Purchase Invoice with Fixed Asset Line.
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"Fixed Asset", FixedAsset."No.", LibraryRandom.RandIntInRange(10, 10));

        // [WHEN] Post the Purchase Invoice.
        PostedDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify Sustainability Ledger Entries and Sustainability Value Entries.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.CalcSums("Emission CO2", "Emission CH4", "Emission N2O", "CO2e Emission", "Carbon Fee");
        Assert.AreEqual(
            PurchaseLine.Quantity * EmissionCO2,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            PurchaseLine.Quantity * EmissionCH4,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            PurchaseLine.Quantity * EmissionN2O,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            ExpectedCO2eEmission * PurchaseLine.Quantity,
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            ExpectedCO2eEmission * PurchaseLine.Quantity * ExpectedCarbonFee,
            SustainabilityLedgerEntry."Carbon Fee",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Carbon Fee"), 0, SustainabilityLedgerEntry.TableCaption()));

        SustainabilityValueEntry.SetRange("Document No.", PostedDocumentNo);
        SustainabilityValueEntry.CalcSums("CO2e Amount (Actual)", "CO2e Amount (Expected)");
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            ExpectedCO2eEmission * PurchaseLine.Quantity,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), 0, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));
    end;

    [Test]
    procedure TestSustValueChainFixedAssetForPurchaseCrMemoPosting()
    var
        PurchaseHeader: Record "Purchase Header";
        CopiedPurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        SustainabilityAccount: Record "Sustainability Account";
        DepreciationBook: Record "Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        EmissionFee: array[3] of Record "Emission Fee";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        ExpectedCO2eEmission: Decimal;
        ExpectedCarbonFee: Decimal;
        PostedCreditMemoNo: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580142] [Sustainability] - Value Chain: Fixed Assets (🌱)
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee";

        // [GIVEN] Create a Fixed Asset.
        CreateFixedAssetSetup(DepreciationBook);
        LibraryFixedAsset.CreateFAWithPostingGroup(FixedAsset);
        CreateFADepreciationBook(FixedAsset."No.", DepreciationBook.Code, FixedAsset."FA Posting Group");
        UpdateIntegrationInBook(DepreciationBook, true, true, true, true, true, true, true);

        // [GIVEN] Update "Default Sust. Account", "Default CO2 Emission", "Default CH4 Emission", "Default N2O Emission" in a Fixed Asset.
        FixedAsset.Validate("Default Sust. Account", SustainabilityAccount."No.");
        FixedAsset.Validate("Default CO2 Emission", EmissionCO2);
        FixedAsset.Validate("Default CH4 Emission", EmissionCH4);
        FixedAsset.Validate("Default N2O Emission", EmissionN2O);
        FixedAsset.Modify(true);

        // [GIVEN] Create a Purchase Invoice with Fixed Asset Line.
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"Fixed Asset", FixedAsset."No.", LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Post the Purchase Invoice.
        PurchInvHeader.Get(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));

        // [GIVEN] Invoke "Create Corrective Credit Memo" from posted purchase invoice.
        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvHeader, PurchaseHeader);
        CopiedPurchaseHeader.SetRange("Document Type", CopiedPurchaseHeader."Document Type"::"Credit Memo");
        CopiedPurchaseHeader.SetRange("Buy-from Vendor No.", PurchInvHeader."Buy-from Vendor No.");
        CopiedPurchaseHeader.FindFirst();

        // [GIVEN] Update the Vendor Credit Memo No. in the copied purchase header.
        CopiedPurchaseHeader.Validate("Vendor Cr. Memo No.", CopiedPurchaseHeader."No.");
        CopiedPurchaseHeader.Modify(true);

        // [WHEN] Post the Purchase Credit Memo.
        PostedCreditMemoNo := LibraryPurchase.PostPurchaseDocument(CopiedPurchaseHeader, true, true);

        // [THEN] Verify Sustainability Ledger Entries and Sustainability Value Entries.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedCreditMemoNo);
        SustainabilityLedgerEntry.CalcSums("Emission CO2", "Emission CH4", "Emission N2O", "CO2e Emission", "Carbon Fee");
        Assert.AreEqual(
            -(PurchaseLine.Quantity * EmissionCO2),
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            -(PurchaseLine.Quantity * EmissionCH4),
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            -(PurchaseLine.Quantity * EmissionN2O),
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            -(ExpectedCO2eEmission * PurchaseLine.Quantity),
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            -(ExpectedCO2eEmission * PurchaseLine.Quantity * ExpectedCarbonFee),
            SustainabilityLedgerEntry."Carbon Fee",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Carbon Fee"), 0, SustainabilityLedgerEntry.TableCaption()));

        SustainabilityValueEntry.SetRange("Document No.", PostedCreditMemoNo);
        SustainabilityValueEntry.CalcSums("CO2e Amount (Actual)", "CO2e Amount (Expected)");
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            -(ExpectedCO2eEmission * PurchaseLine.Quantity),
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), 0, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), 0, SustainabilityValueEntry.TableCaption()));
    end;

    [Test]
    procedure TestSustValueChainFixedAssetForFAJournalLineInvoicePosting()
    var
        FAJournalLine: Record "FA Journal Line";
        SustainabilityAccount: Record "Sustainability Account";
        DepreciationBook: Record "Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        EmissionFee: array[3] of Record "Emission Fee";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580142] [Sustainability] - Value Chain: Fixed Assets (🌱)
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := LibraryRandom.RandDecInRange(1, 2, 2);

        // [GIVEN] Create a Fixed Asset.
        CreateFixedAssetSetup(DepreciationBook);
        LibraryFixedAsset.CreateFAWithPostingGroup(FixedAsset);
        CreateFADepreciationBook(FixedAsset."No.", DepreciationBook.Code, FixedAsset."FA Posting Group");
        UpdateIntegrationInBook(DepreciationBook, false, false, false, false, false, false, false);

        // [GIVEN] Update "Default Sust. Account", "Default CO2 Emission", "Default CH4 Emission", "Default N2O Emission" in a Fixed Asset.
        FixedAsset.Validate("Default Sust. Account", SustainabilityAccount."No.");
        FixedAsset.Validate("Default CO2 Emission", EmissionCO2);
        FixedAsset.Validate("Default CH4 Emission", EmissionCH4);
        FixedAsset.Validate("Default N2O Emission", EmissionN2O);
        FixedAsset.Modify(true);

        // [GIVEN] Create a Fixed Asset Journal Line.
        CreateFAJournalLine(FAJournalLine, FixedAsset."No.", DepreciationBook.Code);
        FAJournalLine.Validate("Sust. Account No.", SustainabilityAccount."No.");
        FAJournalLine.Validate("Total CO2e", ExpectedCO2eEmission);
        FAJournalLine.Modify(true);

        // [WHEN] Post the FA Journal Line.
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);

        // [THEN] Verify Sustainability Ledger Entries.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.CalcSums("Emission Factor CO2", "Emission Factor CH4", "Emission Factor N2O", "CO2e Emission", "Carbon Fee");
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
            ExpectedCO2eEmission,
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Carbon Fee",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Carbon Fee"), 0, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure TestSustValueChainFixedAssetForFAGLJournalLineInvoicePosting()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        SustainabilityAccount: Record "Sustainability Account";
        DepreciationBook: Record "Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        EmissionFee: array[3] of Record "Emission Fee";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580142] [Sustainability] - Value Chain: Fixed Assets (🌱)
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := LibraryRandom.RandDecInRange(1, 2, 2);

        // [GIVEN] Create a Fixed Asset.
        CreateFixedAssetSetup(DepreciationBook);
        LibraryFixedAsset.CreateFAWithPostingGroup(FixedAsset);
        CreateFADepreciationBook(FixedAsset."No.", DepreciationBook.Code, FixedAsset."FA Posting Group");
        UpdateIntegrationInBook(DepreciationBook, true, true, true, true, true, true, true);

        // [GIVEN] Create a Fixed Asset G/L Journal Line.
        CreateGenJournalBatch(GenJournalBatch);
        CreateAndModifyFAGLJournalLine(GenJournalLine, FixedAsset."No.", DepreciationBook, GenJournalBatch, GenJournalLine."FA Posting Type"::"Acquisition Cost", LibraryRandom.RandIntInRange(10000, 20000), SustainabilityAccount."No.", ExpectedCO2eEmission);

        // [WHEN] Post the FA G/L Journal Line.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify Sustainability Ledger Entries.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.CalcSums("Emission Factor CO2", "Emission Factor CH4", "Emission Factor N2O", "CO2e Emission", "Carbon Fee");
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
            ExpectedCO2eEmission,
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Carbon Fee",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Carbon Fee"), 0, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure TestSustValueChainFixedAssetForFAJournalLineWithoutAcqCost()
    var
        FAJournalLine: Record "FA Journal Line";
        SustainabilityAccount: Record "Sustainability Account";
        DepreciationBook: Record "Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580142] [Sustainability] - Value Chain: Fixed Assets (🌱)
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Fixed Asset.
        CreateFixedAssetSetup(DepreciationBook);
        LibraryFixedAsset.CreateFAWithPostingGroup(FixedAsset);
        CreateFADepreciationBook(FixedAsset."No.", DepreciationBook.Code, FixedAsset."FA Posting Group");
        UpdateIntegrationInBook(DepreciationBook, false, false, false, false, false, false, false);

        // [GIVEN] Update "Default Sust. Account", "Default CO2 Emission", "Default CH4 Emission", "Default N2O Emission" in a Fixed Asset.
        FixedAsset.Validate("Default Sust. Account", SustainabilityAccount."No.");
        FixedAsset.Validate("Default CO2 Emission", EmissionCO2);
        FixedAsset.Validate("Default CH4 Emission", EmissionCH4);
        FixedAsset.Validate("Default N2O Emission", EmissionN2O);
        FixedAsset.Modify(true);

        // [GIVEN] Create a Fixed Asset Journal Line.
        CreateFAJournalLine(FAJournalLine, FixedAsset."No.", DepreciationBook.Code);
        FAJournalLine.Validate("FA Posting Type", FAJournalLine."FA Posting Type"::Depreciation);
        FAJournalLine.Modify(true);

        // [WHEN] Update "Sust. Account No." in FA Journal Line.
        asserterror FAJournalLine.Validate("Sust. Account No.", SustainabilityAccount."No.");

        // [THEN] Veify that system throws error message.
        Assert.ExpectedError(StrSubstNo(FAPostingTypeErr, FAJournalLine.FieldCaption("FA Posting Type")));
    end;

    [Test]
    procedure TestSustValueChainFixedAssetForFAJournalLineWithoutTotalCO2e()
    var
        FAJournalLine: Record "FA Journal Line";
        SustainabilityAccount: Record "Sustainability Account";
        DepreciationBook: Record "Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        EmissionFee: array[3] of Record "Emission Fee";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580142] [Sustainability] - Value Chain: Fixed Assets (🌱)
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Create a Fixed Asset.
        CreateFixedAssetSetup(DepreciationBook);
        LibraryFixedAsset.CreateFAWithPostingGroup(FixedAsset);
        CreateFADepreciationBook(FixedAsset."No.", DepreciationBook.Code, FixedAsset."FA Posting Group");
        UpdateIntegrationInBook(DepreciationBook, false, false, false, false, false, false, false);

        // [GIVEN] Update "Default Sust. Account", "Default CO2 Emission", "Default CH4 Emission", "Default N2O Emission" in a Fixed Asset.
        FixedAsset.Validate("Default Sust. Account", SustainabilityAccount."No.");
        FixedAsset.Validate("Default CO2 Emission", EmissionCO2);
        FixedAsset.Validate("Default CH4 Emission", EmissionCH4);
        FixedAsset.Validate("Default N2O Emission", EmissionN2O);
        FixedAsset.Modify(true);

        // [GIVEN] Create a Fixed Asset Journal Line.
        CreateFAJournalLine(FAJournalLine, FixedAsset."No.", DepreciationBook.Code);
        FAJournalLine.Validate("Sust. Account No.", SustainabilityAccount."No.");
        FAJournalLine.Modify(true);

        // [WHEN] Post the FA Journal Line.
        asserterror LibraryFixedAsset.PostFAJournalLine(FAJournalLine);

        // [THEN] Verify that system throws error message.
        Assert.ExpectedError(CO2eMustNotBeZeroErr);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure TestFAReclassJournalLineWithFAJournalLine()
    var
        FAJournalLine: Record "FA Journal Line";
        SustainabilityAccount: array[2] of Record "Sustainability Account";
        DepreciationBook: Record "Depreciation Book";
        FixedAsset: array[2] of Record "Fixed Asset";
        EmissionFee: array[3] of Record "Emission Fee";
        FAReclassJournalLine: Record "FA Reclass. Journal Line";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        ExpectedCO2eEmission: Decimal;
        ReclassifyAcqCostPercent: Decimal;
        CategoryCode, CategoryCode1 : Code[20];
        SubcategoryCode, SubcategoryCode1 : Code[20];
        DocumentNo: Code[20];
        AccountCode, AccountCode1 : Code[20];
    begin
        // [SCENARIO 580142] [Sustainability] - Value Chain: Fixed Assets (🌱)
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount[1].Get(AccountCode);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount[1]."Emission Scope", '');

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := LibraryRandom.RandDecInRange(1, 2, 2);

        // [GIVEN] Create a Fixed Asset.
        CreateFixedAssetSetup(DepreciationBook);
        LibraryFixedAsset.CreateFAWithPostingGroup(FixedAsset[1]);
        CreateFADepreciationBook(FixedAsset[1]."No.", DepreciationBook.Code, FixedAsset[1]."FA Posting Group");
        UpdateIntegrationInBook(DepreciationBook, false, false, false, false, false, false, false);

        // [GIVEN] Create a Fixed Asset Journal Line.
        CreateFAJournalLine(FAJournalLine, FixedAsset[1]."No.", DepreciationBook.Code);
        FAJournalLine.Validate("Sust. Account No.", SustainabilityAccount[1]."No.");
        FAJournalLine.Validate("Total CO2e", ExpectedCO2eEmission);
        FAJournalLine.Modify(true);

        // [GIVEN] Post the FA Journal Line.
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);

        // [GIVEN] Create another Fixed Assets with same depreciation book.
        LibraryFixedAsset.CreateFAWithPostingGroup(FixedAsset[2]);
        CreateFADepreciationBook(FixedAsset[2]."No.", DepreciationBook.Code, FixedAsset[2]."FA Posting Group");

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode1, CategoryCode1, SubcategoryCode1, LibraryRandom.RandInt(10));
        SustainabilityAccount[2].Get(AccountCode1);

        // [GIVEN] Create a Fixed Asset Reclassification Journal Line.
        CreateFAReclassJournalLine(FAReclassJournalLine);
        UpdateFAReclassJournal(FAReclassJournalLine, FixedAsset[1]."No.", FixedAsset[2]."No.", SustainabilityAccount[1]."No.", SustainabilityAccount[2]."No.");

        // [GIVEN] Reclassify FA Reclassification Journal Line.
        DocumentNo := FAReclassJournalLine."Document No.";
        ReclassifyAcqCostPercent := FAReclassJournalLine."Reclassify Acq. Cost %";
        Codeunit.Run(Codeunit::"FA Reclass. Jnl.-Transfer", FAReclassJournalLine);

        // [WHEN] Find and Post the FA Journal Line.
        FindAndPostFAJournalLineAfterReclass(DocumentNo);

        // [THEN] Verify Sustainability Ledger Entries.
        SustainabilityLedgerEntry.SetRange("Account No.", SustainabilityAccount[2]."No.");
        SustainabilityLedgerEntry.CalcSums("CO2e Emission");
        Assert.AreEqual(
            ExpectedCO2eEmission * ReclassifyAcqCostPercent / 100,
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), 0, SustainabilityLedgerEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Account No.", SustainabilityAccount[1]."No.");
        SustainabilityLedgerEntry.CalcSums("CO2e Emission");
        Assert.AreEqual(
            ExpectedCO2eEmission * ReclassifyAcqCostPercent / 100,
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), 0, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure TestFAReclassJournalLineWithFAGLJournalLine()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        SustainabilityAccount: array[2] of Record "Sustainability Account";
        DepreciationBook: Record "Depreciation Book";
        FixedAsset: array[2] of Record "Fixed Asset";
        EmissionFee: array[3] of Record "Emission Fee";
        FAReclassJournalLine: Record "FA Reclass. Journal Line";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        ExpectedCO2eEmission: Decimal;
        ReclassifyAcqCostPercent: Decimal;
        CategoryCode, CategoryCode1 : Code[20];
        SubcategoryCode, SubcategoryCode1 : Code[20];
        DocumentNo: Code[20];
        AccountCode, AccountCode1 : Code[20];
    begin
        // [SCENARIO 580142] [Sustainability] - Value Chain: Fixed Assets (🌱)
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount[1].Get(AccountCode);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount[1]."Emission Scope", '');

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := LibraryRandom.RandDecInRange(1, 2, 2);

        // [GIVEN] Create a Fixed Asset.
        CreateFixedAssetSetup(DepreciationBook);
        LibraryFixedAsset.CreateFAWithPostingGroup(FixedAsset[1]);
        CreateFADepreciationBook(FixedAsset[1]."No.", DepreciationBook.Code, FixedAsset[1]."FA Posting Group");
        UpdateIntegrationInBook(DepreciationBook, true, true, true, true, true, true, true);

        // [GIVEN] Create a Fixed Asset G/L Journal Line.
        CreateGenJournalBatch(GenJournalBatch);
        CreateAndModifyFAGLJournalLine(GenJournalLine, FixedAsset[1]."No.", DepreciationBook, GenJournalBatch, GenJournalLine."FA Posting Type"::"Acquisition Cost", LibraryRandom.RandIntInRange(10000, 20000), SustainabilityAccount[1]."No.", ExpectedCO2eEmission);

        // [GIVEN] Post the FA G/L Journal Line.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [GIVEN] Create another Fixed Assets with same depreciation book.
        LibraryFixedAsset.CreateFAWithPostingGroup(FixedAsset[2]);
        CreateFADepreciationBook(FixedAsset[2]."No.", DepreciationBook.Code, FixedAsset[2]."FA Posting Group");

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode1, CategoryCode1, SubcategoryCode1, LibraryRandom.RandInt(10));
        SustainabilityAccount[2].Get(AccountCode1);

        // [GIVEN] Create a Fixed Asset Reclassification Journal Line.
        CreateFAReclassJournalLine(FAReclassJournalLine);
        UpdateFAReclassJournal(FAReclassJournalLine, FixedAsset[1]."No.", FixedAsset[2]."No.", SustainabilityAccount[1]."No.", SustainabilityAccount[2]."No.");

        // [GIVEN] Reclassify FA Reclassification Journal Line.
        DocumentNo := FAReclassJournalLine."Document No.";
        ReclassifyAcqCostPercent := FAReclassJournalLine."Reclassify Acq. Cost %";
        CODEUNIT.Run(CODEUNIT::"FA Reclass. Jnl.-Transfer", FAReclassJournalLine);

        // [WHEN] Find and Post the FA Journal Line.
        FindAndPostGenJournalLineAfterReclass(DocumentNo);

        // [THEN] Verify Sustainability Ledger Entries.
        SustainabilityLedgerEntry.SetRange("Account No.", SustainabilityAccount[2]."No.");
        SustainabilityLedgerEntry.CalcSums("CO2e Emission");
        Assert.AreEqual(
            ExpectedCO2eEmission * ReclassifyAcqCostPercent / 100,
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), 0, SustainabilityLedgerEntry.TableCaption()));

        SustainabilityLedgerEntry.SetRange("Account No.", SustainabilityAccount[1]."No.");
        SustainabilityLedgerEntry.CalcSums("CO2e Emission");
        Assert.AreEqual(
            ExpectedCO2eEmission * ReclassifyAcqCostPercent / 100,
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), 0, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure TestSustValueChainWithCO2CalculationOnSalesOrder()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SustainabilityAccount: Record "Sustainability Account";
        DepreciationBook: Record "Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        EmissionFee: array[3] of Record "Emission Fee";
        ExpectedCO2eEmission: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580142] [Sustainability] - Value Chain: Fixed Assets (🌱)
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := LibraryRandom.RandDecInRange(1, 2, 2);

        // [GIVEN] Create a Fixed Asset.
        CreateFixedAssetSetup(DepreciationBook);
        LibraryFixedAsset.CreateFAWithPostingGroup(FixedAsset);
        CreateFADepreciationBook(FixedAsset."No.", DepreciationBook.Code, FixedAsset."FA Posting Group");
        UpdateIntegrationInBook(DepreciationBook, true, true, true, true, true, true, true);

        // [GIVEN] Update "Default Sust. Account" in a Fixed Asset.
        FixedAsset.Validate("Default Sust. Account", SustainabilityAccount."No.");
        FixedAsset.Modify(true);

        // [GIVEN] Create a Fixed Asset G/L Journal Line.
        CreateGenJournalBatch(GenJournalBatch);
        CreateAndModifyFAGLJournalLine(GenJournalLine, FixedAsset."No.", DepreciationBook, GenJournalBatch, GenJournalLine."FA Posting Type"::"Acquisition Cost", LibraryRandom.RandIntInRange(10000, 20000), SustainabilityAccount."No.", ExpectedCO2eEmission);

        // [GIVEN] Post the FA G/L Journal Line.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Create a Sales Order with Fixed Asset Line
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, LibrarySales.CreateCustomerNo());
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"Fixed Asset", FixedAsset."No.", 1);

        // [THEN] Verify Sustainability Account No. and Total CO2e in sales line.
        Assert.AreEqual(
            ExpectedCO2eEmission,
            SalesLine."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, SalesLine.FieldCaption("Total CO2e"), 0, SalesLine.TableCaption()));
        Assert.AreEqual(
            SustainabilityAccount."No.",
            SalesLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, SalesLine.FieldCaption("Sust. Account No."), 0, SalesLine.TableCaption()));
    end;

    [Test]
    procedure TestSustValueChainWithFAOnSalesOrderPosting()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SustainabilityAccount: Record "Sustainability Account";
        DepreciationBook: Record "Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        FALedgerEntry: Record "FA Ledger Entry";
        EmissionFee: array[3] of Record "Emission Fee";
        FAAmount, SalesLineAmount, TotalCO2eAmount : Decimal;
        ExpectedCO2eEmission: Decimal;
        PostedDocumentNo: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 580142] [Sustainability] - Value Chain: Fixed Assets (🌱)
        Initialize();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Create Emission Fee With Emission Scope and Country/Region.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := LibraryRandom.RandDecInRange(1, 2, 2);

        // [GIVEN] Create a Fixed Asset.
        CreateFixedAssetSetup(DepreciationBook);
        LibraryFixedAsset.CreateFAWithPostingGroup(FixedAsset);
        CreateFADepreciationBook(FixedAsset."No.", DepreciationBook.Code, FixedAsset."FA Posting Group");
        UpdateIntegrationInBook(DepreciationBook, true, true, true, true, true, true, true);

        // [GIVEN] Update "Default Sust. Account" in a Fixed Asset.
        FixedAsset.Validate("Default Sust. Account", SustainabilityAccount."No.");
        FixedAsset.Modify(true);

        // [GIVEN] Create a Fixed Asset G/L Journal Line.
        FAAmount := LibraryRandom.RandIntInRange(1000, 2000);
        CreateGenJournalBatch(GenJournalBatch);
        CreateAndModifyFAGLJournalLine(GenJournalLine, FixedAsset."No.", DepreciationBook, GenJournalBatch, GenJournalLine."FA Posting Type"::"Acquisition Cost", FAAmount, SustainabilityAccount."No.", ExpectedCO2eEmission);

        // [GIVEN] Post the FA G/L Journal Line.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [GIVEN] Create a Sales Order with Fixed Asset Line.
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, LibrarySales.CreateCustomerNo());
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"Fixed Asset", FixedAsset."No.", 1);

        // [GIVEN] Update the Unit Price and Total CO2e in sales line.
        TotalCO2eAmount := ExpectedCO2eEmission + LibraryRandom.RandIntInRange(1, 2);
        SalesLineAmount := FAAmount + LibraryRandom.RandIntInRange(100, 200);
        SalesLine.Validate("Unit Price", SalesLineAmount);
        SalesLine.Validate("Total CO2e", TotalCO2eAmount);
        SalesLine.Modify(true);

        // [WHEN] Post the Sales Order.
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Verify FA Ledger Entries.
        FALedgerEntry.SetRange("Document No.", PostedDocumentNo);
        FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Proceeds on Disposal");
        FALedgerEntry.CalcSums(Amount, "Total CO2e");
        Assert.AreEqual(
            -TotalCO2eAmount,
            FALedgerEntry."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, FALedgerEntry.FieldCaption("Total CO2e"), 0, FALedgerEntry.TableCaption()));
        Assert.AreEqual(
            -SalesLineAmount,
            FALedgerEntry."Amount",
            StrSubstNo(ValueMustBeEqualErr, FALedgerEntry.FieldCaption(Amount), 0, FALedgerEntry.TableCaption()));

        FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Gain/Loss");
        FALedgerEntry.CalcSums(Amount, "Total CO2e");
        Assert.AreEqual(
            -(TotalCO2eAmount - ExpectedCO2eEmission),
            FALedgerEntry."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, FALedgerEntry.FieldCaption("Total CO2e"), 0, FALedgerEntry.TableCaption()));
        Assert.AreEqual(
            -(SalesLineAmount - FAAmount),
            FALedgerEntry."Amount",
            StrSubstNo(ValueMustBeEqualErr, FALedgerEntry.FieldCaption(Amount), 0, FALedgerEntry.TableCaption()));

        FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Acquisition Cost");
        FALedgerEntry.CalcSums(Amount, "Total CO2e");
        Assert.AreEqual(
            -ExpectedCO2eEmission,
            FALedgerEntry."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, FALedgerEntry.FieldCaption("Total CO2e"), 0, FALedgerEntry.TableCaption()));
        Assert.AreEqual(
            -FAAmount,
            FALedgerEntry."Amount",
            StrSubstNo(ValueMustBeEqualErr, FALedgerEntry.FieldCaption(Amount), 0, FALedgerEntry.TableCaption()));
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Sust. Value Chain Fixed Asset");
        LibrarySustainability.CleanUpBeforeTesting();
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Sust. Value Chain Fixed Asset");

        LibrarySales.SetCreditWarningsToNoWarnings();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.CreateGeneralPostingSetupData();
        LibraryERMCountryData.UpdateVATPostingSetup();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.UpdateLocalData();
        LibrarySales.SetExtDocNo(false);
        IsInitialized := true;

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Sust. Value Chain Fixed Asset");
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

    local procedure CreateFixedAssetSetup(var DepreciationBook: Record "Depreciation Book")
    var
        FAJournalSetup: Record "FA Journal Setup";
    begin
        LibraryFixedAsset.CreateDepreciationBook(DepreciationBook);
        LibraryFixedAsset.CreateFAJournalSetup(FAJournalSetup, DepreciationBook.Code, '');
        UpdateFAJournalSetup(FAJournalSetup);
        UpdateFAPostingTypeSetup(DepreciationBook.Code);
    end;

    local procedure UpdateFAJournalSetup(var FAJournalSetup: Record "FA Journal Setup")
    var
        FAJournalSetup2: Record "FA Journal Setup";
    begin
        FAJournalSetup2.SetRange("Depreciation Book Code", LibraryFixedAsset.GetDefaultDeprBook());
        FAJournalSetup2.FindFirst();
        FAJournalSetup.TransferFields(FAJournalSetup2, false);
        FAJournalSetup.Modify(true);
    end;

    local procedure UpdateFAPostingTypeSetup(DepreciationBookCode: Code[10])
    var
        FAPostingTypeSetup: Record "FA Posting Type Setup";
    begin
        FAPostingTypeSetup.SetRange("Depreciation Book Code", DepreciationBookCode);
        FAPostingTypeSetup.ModifyAll("Include in Gain/Loss Calc.", true);
    end;

    local procedure CreateFADepreciationBook(FANo: Code[20]; DepreciationBookCode: Code[10]; FAPostingGroup: Code[20])
    var
        FADepreciationBook: Record "FA Depreciation Book";
    begin
        LibraryFixedAsset.CreateFADepreciationBook(FADepreciationBook, FANo, DepreciationBookCode);
        FADepreciationBook.Validate("Depreciation Book Code", DepreciationBookCode);
        FADepreciationBook.Validate("Depreciation Starting Date", WorkDate());

        // Random Number Generator for Ending date.
        FADepreciationBook.Validate("Depreciation Ending Date", CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate()));
        FADepreciationBook.Validate("FA Posting Group", FAPostingGroup);
        FADepreciationBook.Modify(true);
    end;

    local procedure UpdateIntegrationInBook(var DepreciationBook: Record "Depreciation Book"; AcqCost: Boolean; Depreciation: Boolean; WriteDown: Boolean; Appreciation: Boolean; Disposal: Boolean; Maintenance: Boolean; VATOnNetDisposalEntries: Boolean)
    begin
        DepreciationBook.Validate("G/L Integration - Acq. Cost", AcqCost);
        DepreciationBook.Validate("G/L Integration - Depreciation", Depreciation);
        DepreciationBook.Validate("G/L Integration - Write-Down", WriteDown);
        DepreciationBook.Validate("G/L Integration - Appreciation", Appreciation);
        DepreciationBook.Validate("G/L Integration - Disposal", Disposal);
        DepreciationBook.Validate("G/L Integration - Custom 1", false);
        DepreciationBook.Validate("G/L Integration - Custom 2", false);
        DepreciationBook.Validate("G/L Integration - Maintenance", Maintenance);
        DepreciationBook.Validate("VAT on Net Disposal Entries", VATOnNetDisposalEntries);
        DepreciationBook.Modify(true);
    end;

    local procedure CreatePurchaseHeader(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type"; BuyFromVendorNo: Code[20])
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, BuyFromVendorNo);
        PurchaseHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
        PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
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

    local procedure CreateFAJournalLine(var FAJournalLine: Record "FA Journal Line"; FANo: Code[20]; DepreciationBookCode: Code[10])
    var
        FAJournalBatch: Record "FA Journal Batch";
    begin
        // Using Random Number Generator for Amount.
        CreateFAJournalBatch(FAJournalBatch);
        CreateFAJournalLine(
          FAJournalLine, FAJournalBatch, FAJournalLine."FA Posting Type"::"Acquisition Cost",
          FANo, DepreciationBookCode, LibraryRandom.RandIntInRange(1000, 2000));
    end;

    local procedure CreateFAJournalLine(var FAJournalLine: Record "FA Journal Line"; FAJournalBatch: Record "FA Journal Batch"; FAPostingType: Enum "FA Journal Line FA Posting Type"; FANo: Code[20]; DepreciationBookCode: Code[10]; Amount: Decimal)
    begin
        LibraryFixedAsset.CreateFAJournalLine(FAJournalLine, FAJournalBatch."Journal Template Name", FAJournalBatch.Name);
        FAJournalLine.Validate("Document Type", FAJournalLine."Document Type"::" ");
        FAJournalLine.Validate("Document No.", FAJournalLine."Journal Batch Name" + Format(FAJournalLine."Line No."));
        FAJournalLine.Validate("Posting Date", WorkDate());
        FAJournalLine.Validate("FA Posting Date", WorkDate());
        FAJournalLine.Validate("FA Posting Type", FAPostingType);
        FAJournalLine.Validate("FA No.", FANo);
        FAJournalLine.Validate(Amount, Amount);
        FAJournalLine.Validate("Depreciation Book Code", DepreciationBookCode);
        FAJournalLine.Modify(true);
    end;

    local procedure CreateFAJournalBatch(var FAJournalBatch: Record "FA Journal Batch")
    var
        FAJournalTemplate: Record "FA Journal Template";
    begin
        FAJournalTemplate.SetRange(Recurring, false);
        LibraryFixedAsset.FindFAJournalTemplate(FAJournalTemplate);
        LibraryFixedAsset.CreateFAJournalBatch(FAJournalBatch, FAJournalTemplate.Name);
        FAJournalBatch.Validate("No. Series", '');
        FAJournalBatch.Modify(true);
    end;

    local procedure CreateFAReclassJournalLine(var FAReclassJournalLine: Record "FA Reclass. Journal Line")
    var
        FAReclassJournalBatch: Record "FA Reclass. Journal Batch";
    begin
        CreateFAReclassJournalBatch(FAReclassJournalBatch);
        LibraryFixedAsset.CreateFAReclassJournal(
          FAReclassJournalLine, FAReclassJournalBatch."Journal Template Name", FAReclassJournalBatch.Name);
    end;

    local procedure CreateFAReclassJournalBatch(var FAReclassJournalBatch: Record "FA Reclass. Journal Batch")
    var
        FAReclassJournalTemplate: Record "FA Reclass. Journal Template";
    begin
        FAReclassJournalTemplate.FindFirst();
        LibraryFixedAsset.CreateFAReclassJournalBatch(FAReclassJournalBatch, FAReclassJournalTemplate.Name);
    end;

    local procedure UpdateFAReclassJournal(var FAReclassJournalLine: Record "FA Reclass. Journal Line"; FANo: Code[20]; NewFANo: Code[20]; SustainabilityAccountNo: Code[20]; NewSustainabilityAccountNo: Code[20])
    begin
        FAReclassJournalLine.Validate("FA Posting Date", WorkDate());
        FAReclassJournalLine.Validate("Document No.", FANo);
        FAReclassJournalLine.Validate("FA No.", FANo);
        FAReclassJournalLine.Validate("New FA No.", NewFANo);
        FAReclassJournalLine.Validate("Sust. Account No.", SustainabilityAccountNo);
        FAReclassJournalLine.Validate("New Sust. Account No.", NewSustainabilityAccountNo);
        FAReclassJournalLine.Validate("Reclassify Acq. Cost %", LibraryRandom.RandIntInRange(50, 50));  // Using Ranodm Reclassify Acq. Cost.
        FAReclassJournalLine.Validate("Reclassify Acquisition Cost", true);
        FAReclassJournalLine.Modify(true);
    end;

    local procedure FindAndPostFAJournalLineAfterReclass(DocumentNo: Code[20])
    var
        FAJournalLine: Record "FA Journal Line";
    begin
        FAJournalLine.SetRange("Document No.", DocumentNo);
        FAJournalLine.FindSet();
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);
    end;

    local procedure CreateGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Recurring, false);
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Assets);
        LibraryERM.FindGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    local procedure CreateAndModifyFAGLJournalLine(var GenJournalLine: Record "Gen. Journal Line"; FANo: Code[20]; DepreciationBook: Record "Depreciation Book"; GenJournalBatch: Record "Gen. Journal Batch"; FAPostingType: Enum "Gen. Journal Line FA Posting Type"; Amount: Decimal; SustainabilityAccountNo: Code[20]; ExpectedCO2eEmission: Decimal)
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        CreateGenJournalLine(GenJournalLine, FANo, DepreciationBook, GenJournalBatch, FAPostingType, Amount, GLAccount, SustainabilityAccountNo, ExpectedCO2eEmission);
    end;

    local procedure CreateGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; FANO: Code[20]; DepreciationBook: Record "Depreciation Book"; GenJournalBatch: Record "Gen. Journal Batch"; FAPostingType: Enum "Gen. Journal Line FA Posting Type"; Amount: Decimal; GLAccount: Record "G/L Account"; SustainabilityAccountNo: Code[20]; ExpectedCO2eEmission: Decimal)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.Get(GenJournalBatch."Journal Template Name");
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::" ",
          GenJournalLine."Account Type"::"Fixed Asset", FANo, Amount);
        GenJournalLine.Validate("Source Code", GenJournalTemplate."Source Code");
        GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Invoice);
        GenJournalLine.Validate("Depreciation Book Code", DepreciationBook."Code");
        GenJournalLine.Validate("FA Posting Type", FAPostingType);
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.Validate("Bal. Account No.", GLAccount."No.");
        GenJournalLine.Validate("Sust. Account No.", SustainabilityAccountNo);
        GenJournalLine.Validate("Total CO2e", ExpectedCO2eEmission);
        GenJournalLine.Modify(true);
    end;

    local procedure FindAndPostGenJournalLineAfterReclass(DocumentNo: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Document No.", DocumentNo);
        GenJournalLine.FindSet();
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;
}