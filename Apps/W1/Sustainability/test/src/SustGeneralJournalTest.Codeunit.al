codeunit 148188 "Sust. General Journal Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySustainability: Codeunit "Library - Sustainability";
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';
        ValueMustBeEqualErr: Label '%1 must be equal to %2 in the %3.', Comment = '%1 = Field Caption , %2 = Expected Value, %3 = Table Caption';

    [Test]
    procedure VerifySustainabilityLedgerEntryShouldBeCreatedWhenGenJournalLineIsPostedWithInvoice()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        Vendor: Record Vendor;
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496545] Verify Sustainability Ledger entry should be created when the General Journal Line is posted with Document Type "Invoice".
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Bank Account.
        LibraryERM.CreateBankAccount(BankAccount);

        // [GIVEN] Create a Vendor.
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] Create a Gen Journal Template.
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);

        // [GIVEN] Create a Gen Journal Batch.
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        // [GIVEN] Create a General Journal Line.
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine,
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::Vendor,
            Vendor."No.",
            -LibraryRandom.RandIntInRange(100, 200));

        // [GIVEN] Update Sustainability Account No.,Total Emission CO2,Total Emission CH4,Total Emission N2O.
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
        GenJournalLine.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalLine.Validate("Sust. Account No.", SustainabilityAccount."No.");
        GenJournalLine.Validate("Total Emission CH4", EmissionCH4);
        GenJournalLine.Validate("Total Emission N2O", EmissionN2O);
        GenJournalLine.Validate("Total Emission CO2", EmissionCO2);
        GenJournalLine.Modify(true);

        // [WHEN] Post General Jnl Line.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [VERIFY] Verify Sustainability Ledger entry should be created when the General Journal Line is posted.
        SustainabilityLedgerEntry.SetRange("Document No.", GenJournalLine."Document No.");
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            EmissionCO2,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionCH4,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionN2O,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), EmissionN2O, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityLedgerEntryShouldBeCreatedWhenGenJournalLineIsPostedWithBalancingForInvoice()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: array[2] of Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        Vendor: Record Vendor;
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496545] Verify Sustainability Ledger entry should be created when the General Journal Line is posted with Balancing for Document Type "Invoice".
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Bank Account.
        LibraryERM.CreateBankAccount(BankAccount);

        // [GIVEN] Create a Vendor.
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] Create a Gen Journal Template.
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);

        // [GIVEN] Create a Gen Journal Batch.
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        // [GIVEN] Create a General Journal Line.
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine[1],
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine[1]."Document Type"::Invoice,
            GenJournalLine[1]."Account Type"::Vendor,
            Vendor."No.",
            -LibraryRandom.RandIntInRange(100, 200));

        // [GIVEN] Update Sustainability Account No.,Total Emission CO2,Total Emission CH4,Total Emission N2O.
        GenJournalLine[1].Validate("Sust. Account No.", SustainabilityAccount."No.");
        GenJournalLine[1].Validate("Total Emission CH4", EmissionCH4);
        GenJournalLine[1].Validate("Total Emission N2O", EmissionN2O);
        GenJournalLine[1].Validate("Total Emission CO2", EmissionCO2);
        GenJournalLine[1].Modify(true);

        // [GIVEN] Create another Balancing General Journal Line.
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine[2],
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine[2]."Document Type"::Invoice,
            GenJournalLine[2]."Account Type"::"Bank Account",
            BankAccount."No.",
           -GenJournalLine[1].Amount);
        GenJournalLine[2].Validate("Document No.", GenJournalLine[1]."Document No.");
        GenJournalLine[2].Modify(true);

        // [WHEN] Post General Jnl Line.
        GenJournalLine[1].SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine[1].SetRange("Journal Batch Name", GenJournalBatch.Name);
        LibraryERM.PostGeneralJnlLine(GenJournalLine[1]);

        // [VERIFY] Verify Sustainability Ledger entry should be created when the General Journal Line is posted.
        SustainabilityLedgerEntry.SetRange("Document No.", GenJournalLine[1]."Document No.");
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            EmissionCO2,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionCH4,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionN2O,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), EmissionN2O, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityLedgerEntryShouldBeCreatedWhenGenJournalLineIsPostedWithCreditMemo()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        Vendor: Record Vendor;
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496545] Verify Sustainability Ledger entry should be created when the General Journal Line is posted with Document Type "Credit Memo".
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Bank Account.
        LibraryERM.CreateBankAccount(BankAccount);

        // [GIVEN] Create a Vendor.
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] Create a Gen Journal Template.
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);

        // [GIVEN] Create a Gen Journal Batch.
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        // [GIVEN] Create a General Journal Line.
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine,
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::"Credit Memo",
            GenJournalLine."Account Type"::Vendor,
            Vendor."No.",
            LibraryRandom.RandIntInRange(100, 200));

        // [GIVEN] Update Sustainability Account No.,Total Emission CO2,Total Emission CH4,Total Emission N2O.
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
        GenJournalLine.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalLine.Validate("Sust. Account No.", SustainabilityAccount."No.");
        GenJournalLine.Validate("Total Emission CH4", EmissionCH4);
        GenJournalLine.Validate("Total Emission N2O", EmissionN2O);
        GenJournalLine.Validate("Total Emission CO2", EmissionCO2);
        GenJournalLine.Modify(true);

        // [WHEN] Post General Jnl Line.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [VERIFY] Verify Sustainability Ledger entry should be created when the General Journal Line is posted.
        SustainabilityLedgerEntry.SetRange("Document No.", GenJournalLine."Document No.");
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            -EmissionCO2,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            -EmissionCH4,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            -EmissionN2O,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), EmissionN2O, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityLedgerEntryShouldBeCreatedWhenGenJournalLineIsPostedWithBalancingForCreditMemo()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: array[2] of Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        Vendor: Record Vendor;
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496545] Verify Sustainability Ledger entry should be created when the General Journal Line is posted with Balancing for Document Type "Credit Memo".
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Bank Account.
        LibraryERM.CreateBankAccount(BankAccount);

        // [GIVEN] Create a Vendor.
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] Create a Gen Journal Template.
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);

        // [GIVEN] Create a Gen Journal Batch.
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        // [GIVEN] Create a General Journal Line.
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine[1],
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine[1]."Document Type"::"Credit Memo",
            GenJournalLine[1]."Account Type"::Vendor,
            Vendor."No.",
            LibraryRandom.RandIntInRange(100, 200));

        // [GIVEN] Update Sustainability Account No.,Total Emission CO2,Total Emission CH4,Total Emission N2O.
        GenJournalLine[1].Validate("Sust. Account No.", SustainabilityAccount."No.");
        GenJournalLine[1].Validate("Total Emission CH4", EmissionCH4);
        GenJournalLine[1].Validate("Total Emission N2O", EmissionN2O);
        GenJournalLine[1].Validate("Total Emission CO2", EmissionCO2);
        GenJournalLine[1].Modify(true);

        // [GIVEN] Create another Balancing General Journal Line.
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine[2],
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine[2]."Document Type"::"Credit Memo",
            GenJournalLine[2]."Account Type"::"Bank Account",
            BankAccount."No.",
           -GenJournalLine[1].Amount);
        GenJournalLine[2].Validate("Document No.", GenJournalLine[1]."Document No.");
        GenJournalLine[2].Modify(true);

        // [WHEN] Post General Jnl Line.
        GenJournalLine[1].SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine[1].SetRange("Journal Batch Name", GenJournalBatch.Name);
        LibraryERM.PostGeneralJnlLine(GenJournalLine[1]);

        // [VERIFY] Verify Sustainability Ledger entry should be created when the General Journal Line is posted.
        SustainabilityLedgerEntry.SetRange("Document No.", GenJournalLine[1]."Document No.");
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            -EmissionCO2,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            -EmissionCH4,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), EmissionCO2, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            -EmissionN2O,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), EmissionN2O, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure TestDocumentTypeCannotBeChangeWhenGenJournalLineContainSustAccNo()
    var
        SustainabilityAccount: Record "Sustainability Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        Vendor: Record Vendor;
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496545] Verify Document Type cannot be change except invoice,Credit Memo When Gen Jnl Line contains "Sust. Account No.".
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Bank Account.
        LibraryERM.CreateBankAccount(BankAccount);

        // [GIVEN] Create a Vendor.
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] Create a Gen Journal Template.
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);

        // [GIVEN] Create a Gen Journal Batch.
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        // [GIVEN] Create a General Journal Line.
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine,
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::Vendor,
            Vendor."No.",
            -LibraryRandom.RandIntInRange(100, 200));

        // [GIVEN] Update Sustainability Account No.,Total Emission CO2,Total Emission CH4,Total Emission N2O.
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
        GenJournalLine.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalLine.Validate("Sust. Account No.", SustainabilityAccount."No.");
        GenJournalLine.Validate("Total Emission CH4", EmissionCH4);
        GenJournalLine.Validate("Total Emission N2O", EmissionN2O);
        GenJournalLine.Validate("Total Emission CO2", EmissionCO2);
        GenJournalLine.Modify(true);

        // [WHEN] Change Document Type.
        asserterror GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Payment);

        // [VERIFY] Verify Document Type cannot be change except invoice,Credit Memo When Gen Jnl Line contains "Sust. Account No.".
        Assert.ExpectedTestFieldError(GenJournalLine.FieldCaption("Sust. Account No."), '');
    end;

    [Test]
    procedure VerifyPostedGenJournalLineShouldBeCreatedWhenGenJournalLineIsPostedWithInvoice()
    var
        PostedGenJournalLine: Record "Posted Gen. Journal Line";
        SustainabilityAccount: Record "Sustainability Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        Vendor: Record Vendor;
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496545] Verify Posted General Line should be created when the General Journal Line is posted with Document Type "Invoice".
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Bank Account.
        LibraryERM.CreateBankAccount(BankAccount);

        // [GIVEN] Create a Vendor.
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] Create a Gen Journal Template with "Copy to Posted Jnl. Lines".
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate("Copy to Posted Jnl. Lines", true);
        GenJournalTemplate.Modify(true);

        // [GIVEN] Create a Gen Journal Batch with "Copy to Posted Jnl. Lines".
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Copy to Posted Jnl. Lines", true);
        GenJournalBatch.Modify(true);

        // [GIVEN] Create a General Journal Line.
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine,
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::Vendor,
            Vendor."No.",
            -LibraryRandom.RandIntInRange(100, 200));

        // [GIVEN] Update Sustainability Account No.,Total Emission CO2,Total Emission CH4,Total Emission N2O.
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
        GenJournalLine.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalLine.Validate("Sust. Account No.", SustainabilityAccount."No.");
        GenJournalLine.Validate("Total Emission CH4", EmissionCH4);
        GenJournalLine.Validate("Total Emission N2O", EmissionN2O);
        GenJournalLine.Validate("Total Emission CO2", EmissionCO2);
        GenJournalLine.Modify(true);

        // [WHEN] Post General Jnl Line.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [VERIFY] Verify Posted General Line should be created when the General Journal Line is posted with Document Type "Invoice".
        PostedGenJournalLine.SetRange("Document No.", GenJournalLine."Document No.");
        PostedGenJournalLine.FindFirst();
        Assert.AreEqual(
            SustainabilityAccount."No.",
            PostedGenJournalLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, PostedGenJournalLine.FieldCaption("Sust. Account No."), SustainabilityAccount."No.", PostedGenJournalLine.TableCaption()));
        Assert.AreEqual(
            EmissionCO2,
            PostedGenJournalLine."Total Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PostedGenJournalLine.FieldCaption("Total Emission CO2"), EmissionCO2, PostedGenJournalLine.TableCaption()));
        Assert.AreEqual(
            EmissionCH4,
            PostedGenJournalLine."Total Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PostedGenJournalLine.FieldCaption("Total Emission CH4"), EmissionCO2, PostedGenJournalLine.TableCaption()));
        Assert.AreEqual(
            EmissionN2O,
            PostedGenJournalLine."Total Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PostedGenJournalLine.FieldCaption("Total Emission N2O"), EmissionN2O, PostedGenJournalLine.TableCaption()));
    end;

    [Test]
    procedure VerifyPostedGenJournalLineShouldBeCreatedWhenGenJournalLineIsPostedWithCreditMemo()
    var
        PostedGenJournalLine: Record "Posted Gen. Journal Line";
        SustainabilityAccount: Record "Sustainability Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        Vendor: Record Vendor;
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496545] Verify Posted General Line should be created when the General Journal Line is posted with Document Type "Credit Memo".
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Bank Account.
        LibraryERM.CreateBankAccount(BankAccount);

        // [GIVEN] Create a Vendor.
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] Create a Gen Journal Template with "Copy to Posted Jnl. Lines".
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate("Copy to Posted Jnl. Lines", true);
        GenJournalTemplate.Modify(true);

        // [GIVEN] Create a Gen Journal Batch with "Copy to Posted Jnl. Lines".
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Copy to Posted Jnl. Lines", true);
        GenJournalBatch.Modify(true);

        // [GIVEN] Create a General Journal Line.
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine,
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::"Credit Memo",
            GenJournalLine."Account Type"::Vendor,
            Vendor."No.",
            LibraryRandom.RandIntInRange(100, 200));

        // [GIVEN] Update Sustainability Account No.,Total Emission CO2,Total Emission CH4,Total Emission N2O.
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
        GenJournalLine.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalLine.Validate("Sust. Account No.", SustainabilityAccount."No.");
        GenJournalLine.Validate("Total Emission CH4", EmissionCH4);
        GenJournalLine.Validate("Total Emission N2O", EmissionN2O);
        GenJournalLine.Validate("Total Emission CO2", EmissionCO2);
        GenJournalLine.Modify(true);

        // [WHEN] Post General Jnl Line.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [VERIFY] Verify Posted General Line should be created when the General Journal Line is posted with Document Type "Credit Memo".
        PostedGenJournalLine.SetRange("Document No.", GenJournalLine."Document No.");
        PostedGenJournalLine.FindFirst();
        Assert.AreEqual(
            SustainabilityAccount."No.",
            PostedGenJournalLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, PostedGenJournalLine.FieldCaption("Sust. Account No."), SustainabilityAccount."No.", PostedGenJournalLine.TableCaption()));
        Assert.AreEqual(
            EmissionCO2,
            PostedGenJournalLine."Total Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PostedGenJournalLine.FieldCaption("Total Emission CO2"), EmissionCO2, PostedGenJournalLine.TableCaption()));
        Assert.AreEqual(
            EmissionCH4,
            PostedGenJournalLine."Total Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PostedGenJournalLine.FieldCaption("Total Emission CH4"), EmissionCO2, PostedGenJournalLine.TableCaption()));
        Assert.AreEqual(
            EmissionN2O,
            PostedGenJournalLine."Total Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PostedGenJournalLine.FieldCaption("Total Emission N2O"), EmissionN2O, PostedGenJournalLine.TableCaption()));
    end;

    [Test]
    procedure VerifyMultipleSustainabilityLedgerEntryShouldBeCreatedWhenGenJournalLineIsPostedWithInvoice()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: array[2] of Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        Vendor: Record Vendor;
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496545] Verify multiple Sustainability Ledger entry should be created when the General Journal Line is posted with Document Type "Invoice".
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Bank Account.
        LibraryERM.CreateBankAccount(BankAccount);

        // [GIVEN] Create a Vendor.
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] Create a Gen Journal Template.
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);

        // [GIVEN] Create a Gen Journal Batch.
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        // [GIVEN] Create a General Journal Line.
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine[1],
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine[1]."Document Type"::Invoice,
            GenJournalLine[1]."Account Type"::Vendor,
            Vendor."No.",
            -LibraryRandom.RandIntInRange(100, 200));

        // [GIVEN] Update Sustainability Account No.,Total Emission CO2,Total Emission CH4,Total Emission N2O.
        GenJournalLine[1].Validate("Bal. Account Type", GenJournalLine[1]."Bal. Account Type"::"Bank Account");
        GenJournalLine[1].Validate("Bal. Account No.", BankAccount."No.");
        GenJournalLine[1].Validate("Sust. Account No.", SustainabilityAccount."No.");
        GenJournalLine[1].Validate("Total Emission CH4", EmissionCH4);
        GenJournalLine[1].Validate("Total Emission N2O", EmissionN2O);
        GenJournalLine[1].Validate("Total Emission CO2", EmissionCO2);
        GenJournalLine[1].Modify(true);

        // [GIVEN] Create another General Journal Line.
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine[2],
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine[2]."Document Type"::Invoice,
            GenJournalLine[2]."Account Type"::Vendor,
            Vendor."No.",
            -LibraryRandom.RandIntInRange(100, 200));

        // [GIVEN] Update Sustainability Account No.,Total Emission CO2,Total Emission CH4,Total Emission N2O.
        GenJournalLine[2].Validate("Bal. Account Type", GenJournalLine[1]."Bal. Account Type"::"Bank Account");
        GenJournalLine[2].Validate("Bal. Account No.", BankAccount."No.");
        GenJournalLine[2].Validate("Sust. Account No.", SustainabilityAccount."No.");
        GenJournalLine[2].Validate("Total Emission CH4", EmissionCH4);
        GenJournalLine[2].Validate("Total Emission N2O", EmissionN2O);
        GenJournalLine[2].Validate("Total Emission CO2", EmissionCO2);
        GenJournalLine[2].Modify(true);

        // [WHEN] Post General Jnl Line.
        GenJournalLine[1].SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine[1].SetRange("Journal Batch Name", GenJournalBatch.Name);
        LibraryERM.PostGeneralJnlLine(GenJournalLine[1]);

        // [VERIFY] Verify multiple Sustainability Ledger entry should be created when the General Journal Line is posted.
        SustainabilityLedgerEntry.SetRange("Document No.", GenJournalLine[1]."Document No.", GenJournalLine[2]."Document No.");
        Assert.RecordCount(SustainabilityLedgerEntry, 2);
    end;

    [Test]
    [HandlerFunctions('GLPostingPreviewHandler')]
    procedure VerifySustainabilityLedgerEntryShouldBeCreatedDuringPreviewPostingOfGenJournal()
    var
        SustainabilityAccount: Record "Sustainability Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: array[2] of Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        Vendor: Record Vendor;
        GenJnlPost: Codeunit "Gen. Jnl.-Post";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496545] Verify Sustainability Ledger Entry should be created during Preview Posting of Gen Journal.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Bank Account.
        LibraryERM.CreateBankAccount(BankAccount);

        // [GIVEN] Create a Vendor.
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] Create a Gen Journal Template.
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);

        // [GIVEN] Create a Gen Journal Batch.
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        // [GIVEN] Create a General Journal Line.
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine[1],
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine[1]."Document Type"::Invoice,
            GenJournalLine[1]."Account Type"::Vendor,
            Vendor."No.",
            -LibraryRandom.RandIntInRange(100, 200));

        // [GIVEN] Update Sustainability Account No.,Total Emission CO2,Total Emission CH4,Total Emission N2O.
        GenJournalLine[1].Validate("Bal. Account Type", GenJournalLine[1]."Bal. Account Type"::"Bank Account");
        GenJournalLine[1].Validate("Bal. Account No.", BankAccount."No.");
        GenJournalLine[1].Validate("Sust. Account No.", SustainabilityAccount."No.");
        GenJournalLine[1].Validate("Total Emission CH4", EmissionCH4);
        GenJournalLine[1].Validate("Total Emission N2O", EmissionN2O);
        GenJournalLine[1].Validate("Total Emission CO2", EmissionCO2);
        GenJournalLine[1].Modify(true);

        // [GIVEN] Create another General Journal Line.
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine[2],
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine[2]."Document Type"::Invoice,
            GenJournalLine[2]."Account Type"::Vendor,
            Vendor."No.",
            -LibraryRandom.RandIntInRange(100, 200));

        // [GIVEN] Update Sustainability Account No.,Total Emission CO2,Total Emission CH4,Total Emission N2O.
        GenJournalLine[2].Validate("Bal. Account Type", GenJournalLine[1]."Bal. Account Type"::"Bank Account");
        GenJournalLine[2].Validate("Bal. Account No.", BankAccount."No.");
        GenJournalLine[2].Validate("Sust. Account No.", SustainabilityAccount."No.");
        GenJournalLine[2].Validate("Total Emission CH4", EmissionCH4);
        GenJournalLine[2].Validate("Total Emission N2O", EmissionN2O);
        GenJournalLine[2].Validate("Total Emission CO2", EmissionCO2);
        GenJournalLine[2].Modify(true);

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Preview General Jnl Line.
        GenJournalLine[1].SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine[1].SetRange("Journal Batch Name", GenJournalBatch.Name);
        asserterror GenJnlPost.Preview(GenJournalLine[1]);

        // [VERIFY] No errors occured - preview mode error only.
        Assert.ExpectedError('');
    end;

    [Test]
    [HandlerFunctions('NavigateFindEntriesHandler')]
    procedure VerifySustainabilityLedgerEntryShouldBeShownWhenNavigating()
    var
        SustainabilityAccount: Record "Sustainability Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        Vendor: Record Vendor;
        Navigate: Page Navigate;
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496545] Verify Sustainability Ledger Entry should be shown when navigating through NavigateFindEntriesHandler handler.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Bank Account.
        LibraryERM.CreateBankAccount(BankAccount);

        // [GIVEN] Create a Vendor.
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] Create a Gen Journal Template with "Copy to Posted Jnl. Lines".
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate("Copy to Posted Jnl. Lines", true);
        GenJournalTemplate.Modify(true);

        // [GIVEN] Create a Gen Journal Batch with "Copy to Posted Jnl. Lines".
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Copy to Posted Jnl. Lines", true);
        GenJournalBatch.Modify(true);

        // [GIVEN] Create a General Journal Line.
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine,
            GenJournalBatch."Journal Template Name",
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::Vendor,
            Vendor."No.",
            -LibraryRandom.RandIntInRange(100, 200));

        // [GIVEN] Update Sustainability Account No.,Total Emission CO2,Total Emission CH4,Total Emission N2O.
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
        GenJournalLine.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalLine.Validate("Sust. Account No.", SustainabilityAccount."No.");
        GenJournalLine.Validate("Total Emission CH4", EmissionCH4);
        GenJournalLine.Validate("Total Emission N2O", EmissionN2O);
        GenJournalLine.Validate("Total Emission CO2", EmissionCO2);
        GenJournalLine.Modify(true);

        // [WHEN] Preview General Jnl Line.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [VERIFY] Verify Sustainability Ledger Entry should be shown when navigating through NavigateFindEntriesHandler handler.
        Navigate.SetDoc(GenJournalLine."Posting Date", GenJournalLine."Document No.");
        Navigate.Run();
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

    [PageHandler]
    [Scope('OnPrem')]
    procedure GLPostingPreviewHandler(var GLPostingPreview: TestPage "G/L Posting Preview")
    begin
        GLPostingPreview.Filter.SetFilter("Table ID", Format(Database::"Sustainability Ledger Entry"));
        GLPostingPreview."No. of Records".AssertEquals(2);
        GLPostingPreview.OK().Invoke();
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure NavigateFindEntriesHandler(var Navigate: TestPage Navigate)
    begin
        Navigate.Filter.SetFilter("Table ID", Format(Database::"Sustainability Ledger Entry"));
        Navigate."No. of Records".AssertEquals(1);
        Navigate.OK().Invoke();
    end;
}