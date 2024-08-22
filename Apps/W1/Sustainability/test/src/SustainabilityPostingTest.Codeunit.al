codeunit 148184 "Sustainability Posting Test"
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
        InformationTakenToLedgerEntryLbl: Label '%1 on the Ledger Entry should be taken from %2', Locked = true;
        ValueMustBeEqualErr: Label '%1 must be equal to %2 in the %3.', Comment = '%1 = Field Caption , %2 = Expected Value, %3 = Table Caption';
        FilterMustBeEqualErr: Label 'Filter must be equal to %1 in the %2', Comment = '%1 = Expected Value , %2 = Page Caption';
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';
        EmissionShouldNotBeLessThanPostedErr: Label '%1 should not be less than %2 in Purchase Line : Document Type : %3, Document No. : %4, Line No. : %5', Comment = '%1 - Emission Field Name, %2 Emission Value, %3 - Document Type, %4 - Document No., %5 - Line No.';

    [Test]
    procedure TestInformationIsTransferredToLedgerEntry()
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountCategory: Record "Sustain. Account Category";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
    begin
        // [SCENARIO] All information from Journal Line/Account/Category is transferred to the ledger Entry
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] A Sustainability Journal Batch and An Account that's ready to Post 
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        SustainabilityAccount := LibrarySustainability.GetAReadyToPostAccount();

        // [GIVEN] A Sustainability Journal Line is created and all fields are filled out
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine."Unit of Measure" := 'kg';
        SustainabilityJournalLine.Validate("Fuel/Electricity", 123);
        SustainabilityJournalLine.Modify(true);

        // [WHEN] A Ledger Entry is inserted basing on the Journal Line
        SustainabilityPostMgt.InsertLedgerEntry(SustainabilityJournalLine);
        SustainabilityLedgerEntry.FindFirst();

        // [THEN] All information from Journal Line is transferred to the ledger Entry
        Assert.AreEqual(WorkDate(), SustainabilityLedgerEntry."Posting Date", StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("Posting Date"), SustainabilityJournalLine.TableCaption()));
        Assert.AreEqual(SustainabilityAccount."No.", SustainabilityLedgerEntry."Account No.", StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("Account No."), SustainabilityJournalLine.TableCaption()));
        // [THEN] All information from Account is transferred to the ledger Entry
        Assert.AreEqual(SustainabilityAccount.Name, SustainabilityLedgerEntry."Account Name", StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("Account Name"), SustainabilityAccount.TableCaption()));
        Assert.AreEqual(SustainabilityAccount.Category, SustainabilityLedgerEntry."Account Category", StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("Account Category"), SustainabilityAccount.TableCaption()));
        Assert.AreEqual(SustainabilityAccount.Subcategory, SustainabilityLedgerEntry."Account Subcategory", StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("Account Subcategory"), SustainabilityAccount.TableCaption()));
        // [THEN] All information from Category is transferred to the ledger Entry
        SustainAccountCategory.Get(SustainabilityAccount.Category);
        Assert.AreEqual(SustainAccountCategory."Emission Scope", SustainabilityLedgerEntry."Emission Scope", StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("Emission Scope"), SustainAccountCategory.TableCaption()));
        Assert.AreEqual(SustainAccountCategory."Calculation Foundation", SustainabilityLedgerEntry."Calculation Foundation", StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("Calculation Foundation"), SustainAccountCategory.TableCaption()));
        Assert.AreEqual(SustainAccountCategory.CO2, SustainabilityLedgerEntry.CO2, StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("CO2"), SustainAccountCategory.TableCaption()));
        Assert.AreEqual(SustainAccountCategory.CH4, SustainabilityLedgerEntry.CH4, StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("CH4"), SustainAccountCategory.TableCaption()));
        Assert.AreEqual(SustainAccountCategory.N2O, SustainabilityLedgerEntry.N2O, StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("N2O"), SustainAccountCategory.TableCaption()));
        // [THEN] All information from Subcategory is transferred to the ledger Entry
        SustainAccountSubcategory.Get(SustainabilityAccount.Category, SustainabilityAccount.Subcategory);
        Assert.AreEqual(SustainAccountSubcategory."Renewable Energy", SustainabilityLedgerEntry."Renewable Energy", StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("Renewable Energy"), SustainAccountSubcategory.TableCaption()));
        Assert.AreEqual(SustainAccountSubcategory."Emission Factor CO2", SustainabilityLedgerEntry."Emission Factor CO2", StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("Emission Factor CO2"), SustainAccountSubcategory.TableCaption()));
        Assert.AreEqual(SustainAccountSubcategory."Emission Factor CH4", SustainabilityLedgerEntry."Emission Factor CH4", StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("Emission Factor CH4"), SustainAccountSubcategory.TableCaption()));
        Assert.AreEqual(SustainAccountSubcategory."Emission Factor N2O", SustainabilityLedgerEntry."Emission Factor N2O", StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("Emission Factor N2O"), SustainAccountSubcategory.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityGoalsShouldContainFilterOfScorecard()
    var
        SustainabilityGoal: Record "Sustainability Goal";
        SustainabilityScorecard: Record "Sustainability Scorecard";
        SustainabilityScorecards: TestPage "Sustainability Scorecards";
        SustainabilityGoals: TestPage "Sustainability Goals";
        ScorecardCode: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Goals should contain a scorecard filter When it's opened from the Sustainability Scorecard page.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Scorecard.
        ScorecardCode := LibraryUtility.GenerateRandomCode(SustainabilityScorecard.FieldNo("No."), DATABASE::"Sustainability Scorecard");
        LibrarySustainability.InsertSustainabilityScorecard(
            SustainabilityScorecard,
            ScorecardCode,
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Create a Sustainability Goal.
        LibrarySustainability.InsertSustainabilityGoal(
            SustainabilityGoal,
            LibraryUtility.GenerateRandomCode(SustainabilityGoal.FieldNo("No."), DATABASE::"Sustainability Goal"),
            ScorecardCode,
            LibraryRandom.RandInt(1000),
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [WHEN] Open Sustainability Goals page.
        SustainabilityScorecards.OpenView();
        SustainabilityScorecards.GoToRecord(SustainabilityScorecard);
        SustainabilityGoals.Trap();
        SustainabilityScorecards.Goals.Invoke();

        // [VERIFY] Verify Sustainability Goals should contain a scorecard filter When it's opened from the Sustainability Scorecard page.
        SustainabilityGoals."No.".AssertEquals(SustainabilityGoal."No.");
        SustainabilityGoals."Scorecard No.".AssertEquals(SustainabilityGoal."Scorecard No.");
        Assert.AreEqual(
            SustainabilityGoal."Scorecard No.",
            SustainabilityGoals.Filter.GetFilter("Scorecard No."),
            StrSubstNo(FilterMustBeEqualErr, SustainabilityGoal."Scorecard No.", SustainabilityGoals.Caption()));
    end;

    [Test]
    procedure VerifySustainabilityScorecardShouldContainUserIdOfSustainabilityManager()
    var
        UserSetup: Record "User Setup";
        SustainabilityScorecard: Record "Sustainability Scorecard";
        ScorecardCode: Code[20];
    begin
        // [SCENARIO 496561] Verify the Sustainability Scorecard should contain the User ID of the Sustainability Manager.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create User Setup with Sustainability Manager.
        UserSetup.DeleteAll();
        CreateUserSetup(UserSetup, CopyStr(UserId(), 1, 50));
        UserSetup.Validate("Sustainability Manager", true);
        UserSetup.Modify();

        // [GIVEN] Create a Sustainability Scorecard.
        ScorecardCode := LibraryUtility.GenerateRandomCode(SustainabilityScorecard.FieldNo("No."), DATABASE::"Sustainability Scorecard");
        LibrarySustainability.InsertSustainabilityScorecard(
            SustainabilityScorecard,
            ScorecardCode,
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [WHEN] Update owner in Sustainability Scorecard.
        SustainabilityScorecard.Validate(Owner, UserSetup."User ID");
        SustainabilityScorecard.Modify();

        // [VERIFY] Verify the sustainability scorecard should contain the User ID of the Sustainability Manager.
        Assert.AreEqual(
            UserSetup."User ID",
            SustainabilityScorecard.Owner,
            StrSubstNo(ValueMustBeEqualErr, SustainabilityScorecard.FieldCaption(Owner), UserSetup."User ID", SustainabilityScorecard.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityScorecardShouldNotContainUserIdOfNonSustainabilityManager()
    var
        UserSetup: Record "User Setup";
        SustainabilityScorecard: Record "Sustainability Scorecard";
        ScorecardCode: Code[20];
    begin
        // [SCENARIO 496561] Verify that the Sustainability Scorecard does not contain the user ID of the non-sustainability manager.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create User Setup with Sustainability Manager.
        UserSetup.DeleteAll();
        CreateUserSetup(UserSetup, CopyStr(UserId(), 1, 50));
        UserSetup.Validate("Sustainability Manager", false);
        UserSetup.Modify();

        // [GIVEN] Create a Sustainability Scorecard.
        ScorecardCode := LibraryUtility.GenerateRandomCode(SustainabilityScorecard.FieldNo("No."), DATABASE::"Sustainability Scorecard");
        LibrarySustainability.InsertSustainabilityScorecard(
            SustainabilityScorecard,
            ScorecardCode,
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Update owner in Sustainability Scorecard.
        asserterror SustainabilityScorecard.Validate(Owner, UserSetup."User ID");

        // [VERIFY] Verify that the Sustainability Scorecard does not contain the user ID of the Non-Sustainability Manager.
        SustainabilityScorecard.Get(SustainabilityScorecard."No.");
        Assert.AreEqual(
            '',
            SustainabilityScorecard.Owner,
            StrSubstNo(ValueMustBeEqualErr, SustainabilityScorecard.FieldCaption(Owner), '', SustainabilityScorecard.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityGoalsShouldContainOneMailGoalforDiferrentNoAndSameScoreCard()
    var
        SustainabilityGoal: array[2] of Record "Sustainability Goal";
        SustainabilityScorecard: Record "Sustainability Scorecard";
        ScorecardCode: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Goals should contain one Mail Goal for different No. and same Scorecard.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Scorecard.
        ScorecardCode := LibraryUtility.GenerateRandomCode(SustainabilityScorecard.FieldNo("No."), DATABASE::"Sustainability Scorecard");
        LibrarySustainability.InsertSustainabilityScorecard(
            SustainabilityScorecard,
            ScorecardCode,
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Create a Sustainability Goal.
        LibrarySustainability.InsertSustainabilityGoal(
            SustainabilityGoal[1],
            LibraryUtility.GenerateRandomCode(SustainabilityGoal[1].FieldNo("No."), DATABASE::"Sustainability Goal"),
            ScorecardCode,
            LibraryRandom.RandInt(1000),
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Update Main Goal as true in Sustainability Goal.
        SustainabilityGoal[1].Validate("Main Goal", true);
        SustainabilityGoal[1].Modify();

        // [GIVEN] Create another Sustainability Goal with different No. and same Scorecard.
        LibrarySustainability.InsertSustainabilityGoal(
            SustainabilityGoal[2],
            LibraryUtility.GenerateRandomCode(SustainabilityGoal[1].FieldNo("No."), DATABASE::"Sustainability Goal"),
            ScorecardCode,
            LibraryRandom.RandInt(1000),
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Update Main Goal as true in Sustainability Goal.
        asserterror SustainabilityGoal[2].Validate("Main Goal", true);

        // [VERIFY] Verify Sustainability Goals should contain one Mail Goal for different No. and same Scorecard.
        SustainabilityGoal[2].Get(SustainabilityGoal[2]."Scorecard No.", SustainabilityGoal[2]."No.", SustainabilityGoal[2]."Line No.");
        Assert.AreEqual(
            false,
            SustainabilityGoal[2]."Main Goal",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityGoal[2].FieldCaption("Main Goal"), false, SustainabilityGoal[2].TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityGoalsShouldContainMultipleMailGoalforSameNoAndScorecard()
    var
        SustainabilityGoal: array[2] of Record "Sustainability Goal";
        SustainabilityScorecard: Record "Sustainability Scorecard";
        ScorecardCode: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Goals should contain multiple Mail Goal for same No. and Scorecard.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Scorecard.
        ScorecardCode := LibraryUtility.GenerateRandomCode(SustainabilityScorecard.FieldNo("No."), DATABASE::"Sustainability Scorecard");
        LibrarySustainability.InsertSustainabilityScorecard(
            SustainabilityScorecard,
            ScorecardCode,
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Create a Sustainability Goal.
        LibrarySustainability.InsertSustainabilityGoal(
            SustainabilityGoal[1],
            LibraryUtility.GenerateRandomCode(SustainabilityGoal[1].FieldNo("No."), DATABASE::"Sustainability Goal"),
            ScorecardCode,
            LibraryRandom.RandInt(1000),
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Update Main Goal as true in Sustainability Goal.
        SustainabilityGoal[1].Validate("Main Goal", true);
        SustainabilityGoal[1].Modify();

        // [GIVEN] Create another Sustainability Goal with same No. and Scorecard.
        LibrarySustainability.InsertSustainabilityGoal(
            SustainabilityGoal[2],
            SustainabilityGoal[1]."No.",
            ScorecardCode,
            LibraryRandom.RandInt(1000),
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [WHEN] Update Main Goal as true in Sustainability Goal.
        SustainabilityGoal[2].Validate("Main Goal", true);
        SustainabilityGoal[2].Modify();

        // [VERIFY] Verify Sustainability Goals should contain multiple Mail Goal for same No. and Scorecard.
        SustainabilityGoal[2].Get(SustainabilityGoal[2]."Scorecard No.", SustainabilityGoal[2]."No.", SustainabilityGoal[2]."Line No.");
        Assert.AreEqual(
            true,
            SustainabilityGoal[2]."Main Goal",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityGoal[2].FieldCaption("Main Goal"), true, SustainabilityGoal[2].TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityGoalsShouldContainFilterOfOwner()
    var
        UserSetup: Record "User Setup";
        SustainabilityGoal: array[2] of Record "Sustainability Goal";
        SustainabilityScorecard: Record "Sustainability Scorecard";
        SustainabilityGoals: TestPage "Sustainability Goals";
        ScorecardCode: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Goals should contain a owner filter When user clicked on Show My Goals action.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create User Setup with Sustainability Manager.
        UserSetup.DeleteAll();
        CreateUserSetup(UserSetup, CopyStr(UserId(), 1, 50));
        UserSetup.Validate("Sustainability Manager", true);
        UserSetup.Modify();

        // [GIVEN] Create a Sustainability Scorecard.
        ScorecardCode := LibraryUtility.GenerateRandomCode(SustainabilityScorecard.FieldNo("No."), DATABASE::"Sustainability Scorecard");
        LibrarySustainability.InsertSustainabilityScorecard(
            SustainabilityScorecard,
            ScorecardCode,
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Create a Sustainability Goal.
        LibrarySustainability.InsertSustainabilityGoal(
            SustainabilityGoal[1],
            LibraryUtility.GenerateRandomCode(SustainabilityGoal[1].FieldNo("No."), DATABASE::"Sustainability Goal"),
            ScorecardCode,
            LibraryRandom.RandInt(1000),
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Update Owner in the Sustainability Goal.
        SustainabilityGoal[1].Validate(Owner, UserSetup."User ID");
        SustainabilityGoal[1].Modify();

        // [GIVEN] Create another Sustainability Goal.
        LibrarySustainability.InsertSustainabilityGoal(
            SustainabilityGoal[2],
            LibraryUtility.GenerateRandomCode(SustainabilityGoal[1].FieldNo("No."), DATABASE::"Sustainability Goal"),
            ScorecardCode,
            LibraryRandom.RandInt(1000),
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [WHEN] Open Sustainability Goals page.
        SustainabilityGoals.OpenView();
        SustainabilityGoals."Show My Goals".Invoke();

        // [VERIFY] Verify Sustainability Goals should contain a owner filter When user clicked on Show My Goals action.
        Assert.AreEqual(
            UserSetup."User ID",
            SustainabilityGoals.Filter.GetFilter(Owner),
            StrSubstNo(FilterMustBeEqualErr, UserSetup."User ID", SustainabilityGoals.Caption()));
    end;

    [Test]
    procedure VerifySustainabilityGoalsShouldNotContainFilterOfOwner()
    var
        UserSetup: Record "User Setup";
        SustainabilityGoal: array[2] of Record "Sustainability Goal";
        SustainabilityScorecard: Record "Sustainability Scorecard";
        SustainabilityGoals: TestPage "Sustainability Goals";
        ScorecardCode: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Goals should not contain a owner filter When user clicked on Show All Goals action.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create User Setup with Sustainability Manager.
        UserSetup.DeleteAll();
        CreateUserSetup(UserSetup, CopyStr(UserId(), 1, 50));
        UserSetup.Validate("Sustainability Manager", true);
        UserSetup.Modify();

        // [GIVEN] Create a Sustainability Scorecard.
        ScorecardCode := LibraryUtility.GenerateRandomCode(SustainabilityScorecard.FieldNo("No."), DATABASE::"Sustainability Scorecard");
        LibrarySustainability.InsertSustainabilityScorecard(
            SustainabilityScorecard,
            ScorecardCode,
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Create a Sustainability Goal.
        LibrarySustainability.InsertSustainabilityGoal(
            SustainabilityGoal[1],
            LibraryUtility.GenerateRandomCode(SustainabilityGoal[1].FieldNo("No."), DATABASE::"Sustainability Goal"),
            ScorecardCode,
            LibraryRandom.RandInt(1000),
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Update Owner in the Sustainability Goal.
        SustainabilityGoal[1].Validate(Owner, UserSetup."User ID");
        SustainabilityGoal[1].Modify();

        // [GIVEN] Create another Sustainability Goal.
        LibrarySustainability.InsertSustainabilityGoal(
            SustainabilityGoal[2],
            LibraryUtility.GenerateRandomCode(SustainabilityGoal[1].FieldNo("No."), DATABASE::"Sustainability Goal"),
            ScorecardCode,
            LibraryRandom.RandInt(1000),
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [WHEN] Open Sustainability Goals page.
        SustainabilityGoals.OpenView();
        SustainabilityGoals."Show My Goals".Invoke();
        SustainabilityGoals."Show All Goals".Invoke();

        // [VERIFY] Verify Sustainability Goals should not contain a owner filter When user clicked on Show All Goals action.
        Assert.AreEqual(
            '',
            SustainabilityGoals.Filter.GetFilter(Owner),
            StrSubstNo(FilterMustBeEqualErr, '', SustainabilityGoals.Caption()));
    end;

    [Test]
    procedure VerifySustainabilityLedgerEntryShouldBeCreatedWhenPurchDocumentIsPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Ledger entry should be created when the purchase document is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability Ledger entry should be created when the purchase document is posted.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedInvoiceNo);
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            EmissionCO2PerUnit,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), EmissionCO2PerUnit, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionCH4PerUnit,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), EmissionCO2PerUnit, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionN2OPerUnit,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), EmissionN2OPerUnit, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityLedgerEntryShouldBeCreatedWhenPurchDocumentIsPartiallyPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Ledger entry should be created when the purchase document is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability Ledger entry should be created when the purchase document is posted.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedInvoiceNo);
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            EmissionCO2PerUnit,
            SustainabilityLedgerEntry."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CO2"), EmissionCO2PerUnit, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionCH4PerUnit,
            SustainabilityLedgerEntry."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission CH4"), EmissionCO2PerUnit, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            EmissionN2OPerUnit,
            SustainabilityLedgerEntry."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Emission N2O"), EmissionN2OPerUnit, SustainabilityLedgerEntry.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityLedgerEntryShouldBeKnockedOffWhenCancelCreditMemoIsPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Ledger entry should be Kocked Off when the Cancel Credit Memo is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [WHEN] Post a Purchase Document.
        PostAndVerifyCancelCreditMemo(PurchaseHeader);

        // [VERIFY] Verify Sustainability Ledger entry should be Kocked Off when the Cancel Credit Memo is posted.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.CalcSums("Emission CO2", "Emission CH4", "Emission N2O");
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
    end;

    [Test]
    procedure VerifySustainabilityLedgerEntryShouldBeKnockedOffWhenCorrectiveCreditMemoIsPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Ledger entry should be Kocked Off when the Corrective Credit Memo is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [WHEN] Post a Purchase Document.
        PostAndVerifyCorrectiveCreditMemo(PurchaseHeader);

        // [VERIFY] Verify Sustainability Ledger entry should be Kocked Off when the Corrective Credit Memo is posted.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.CalcSums("Emission CO2", "Emission CH4", "Emission N2O");
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
    end;

    [Test]
    procedure VerifySustainabilityFieldsInPurchReceiptLineAndPurchInvoiceLine()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PostedPurchInvoiceSubform: TestPage "Posted Purch. Invoice Subform";
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Fields In Purchase Receipt Line and Purchase Invoice Line.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability Fields In Purchase Receipt Line and Purchase Invoice Line.
        PostedPurchInvoiceSubform.OpenEdit();
        PostedPurchInvoiceSubform.FILTER.SetFilter("Document No.", PostedInvoiceNo);
        PostedPurchInvoiceSubform."Emission CH4".AssertEquals(EmissionCH4PerUnit);
        PostedPurchInvoiceSubform."Emission CO2".AssertEquals(EmissionCO2PerUnit);
        PostedPurchInvoiceSubform."Emission N2O".AssertEquals(EmissionN2OPerUnit);
        PostedPurchInvoiceSubform."Sust. Account No.".AssertEquals(AccountCode);

        PurchRcptLine.SetRange("Buy-from Vendor No.", PurchaseLine."Buy-from Vendor No.");
        PurchRcptLine.FindFirst();
        Assert.AreEqual(
            AccountCode,
            PurchRcptLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Sust. Account No."), AccountCode, PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            EmissionCH4PerUnit,
            PurchRcptLine."Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Emission CH4"), EmissionCH4PerUnit, PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            EmissionCO2PerUnit,
            PurchRcptLine."Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Emission CO2"), EmissionCO2PerUnit, PurchRcptLine.TableCaption()));
        Assert.AreEqual(
            EmissionN2OPerUnit,
            PurchRcptLine."Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchRcptLine.FieldCaption("Emission N2O"), EmissionN2OPerUnit, PurchRcptLine.TableCaption()));
    end;

    [Test]
    procedure VerifyEmissionCO2PerUnitShouldNotBeGreaterThanPostedEmissionCO2InPurchaseLine()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496561] Verify Emission CO2 Per Unit should not be greater than Posted Emission CO2 in Purchase Line.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [GIVEN] Post a Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit += LibraryRandom.RandInt(5);

        // [WHEN] Validate Emission CO2 Per Unit is greater than Posted Emission CO2.
        PurchaseLine.Get(PurchaseLine."Document Type", PurchaseLine."Document No.", PurchaseLine."Line No.");
        asserterror PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);

        // [VERIFY] Verify Emission CO2 Per Unit should not be greater than Posted Emission CO2 in Purchase Line.
        PurchaseLine.Get(PurchaseLine."Document Type", PurchaseLine."Document No.", PurchaseLine."Line No.");
        PurchaseLine."Emission CO2 Per Unit" := EmissionCO2PerUnit;
        Assert.ExpectedError(
            StrSubstNo(
                EmissionShouldNotBeLessThanPostedErr,
                PurchaseLine."Emission CO2 Per Unit",
                PurchaseLine."Posted Emission CO2",
                PurchaseLine."Document Type",
                PurchaseLine."Document No.",
                PurchaseLine."Line No."));
    end;

    [Test]
    procedure VerifyPostedEmissionFieldsInPurchaseLine()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496561] Verify Posted Emission fields in Purchase Line.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Posted Emission fields in Purchase Line.
        PurchaseLine.Get(PurchaseLine."Document Type", PurchaseLine."Document No.", PurchaseLine."Line No.");
        Assert.AreEqual(
            EmissionCO2PerUnit,
            PurchaseLine."Posted Emission CO2",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Posted Emission CO2"), EmissionCO2PerUnit, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            EmissionCH4PerUnit,
            PurchaseLine."Posted Emission CH4",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Posted Emission CH4"), EmissionCH4PerUnit, PurchaseLine.TableCaption()));
        Assert.AreEqual(
            EmissionN2OPerUnit,
            PurchaseLine."Posted Emission N2O",
            StrSubstNo(ValueMustBeEqualErr, PurchaseLine.FieldCaption("Posted Emission N2O"), EmissionN2OPerUnit, PurchaseLine.TableCaption()));
    end;

    [Test]
    [HandlerFunctions('PurchaseOrderStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInPurchaseOrderStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Fields in Purchase Order Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2PerUnit);
        LibraryVariableStorage.Enqueue(EmissionCH4PerUnit);
        LibraryVariableStorage.Enqueue(EmissionN2OPerUnit);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);

        // [VERIFY] Verify Sustainability fields in Page "Purchase Order Statistics" before posting of Purchase order.
        OpenPurchaseOrderStatistics(PurchaseHeader."No.");
        LibraryVariableStorage.Clear();

        // [GIVEN] Post a Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2PerUnit);
        LibraryVariableStorage.Enqueue(EmissionCH4PerUnit);
        LibraryVariableStorage.Enqueue(EmissionN2OPerUnit);
        LibraryVariableStorage.Enqueue(EmissionCO2PerUnit);
        LibraryVariableStorage.Enqueue(EmissionCH4PerUnit);
        LibraryVariableStorage.Enqueue(EmissionN2OPerUnit);

        // [VERIFY] Verify Sustainability fields in Page "Purchase Order Statistics" after partially posting of Purchase order.
        OpenPurchaseOrderStatistics(PurchaseHeader."No.");
        LibraryVariableStorage.Clear();
    end;

    [Test]
    [HandlerFunctions('PurchaseInvoiceStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInPurchaseInvoiceStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Fields in Purchase Invoice Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Invoice, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2PerUnit);
        LibraryVariableStorage.Enqueue(EmissionCH4PerUnit);
        LibraryVariableStorage.Enqueue(EmissionN2OPerUnit);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);

        // [VERIFY] Verify Sustainability fields in Page "Purchase Invoice Statistics" before posting of Purchase Invoice.
        OpenPurchaseInvoiceStatistics(PurchaseHeader."No.");
        LibraryVariableStorage.Clear();
    end;

    [Test]
    procedure VerifySustainabilityFieldsInPostedPurchaseInvoiceStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Fields in Posted Purchase Invoice Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [GIVEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2PerUnit);
        LibraryVariableStorage.Enqueue(EmissionCH4PerUnit);
        LibraryVariableStorage.Enqueue(EmissionN2OPerUnit);

        // [WHEN] Post Purchase Document.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability fields in Page "Posted Purchase Invoice Statistics".
        VerifyPostedPurchaseInvoiceStatistics(PostedInvoiceNo);
        LibraryVariableStorage.Clear();
    end;

    [Test]
    [HandlerFunctions('PurchaseInvoiceStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInPurchaseCrMemoStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        CrMemoNo: Code[20];
        PostedCrMemoNo: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability fields in Posted Purchase Cr Memo Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2PerUnit);
        LibraryVariableStorage.Enqueue(EmissionCH4PerUnit);
        LibraryVariableStorage.Enqueue(EmissionN2OPerUnit);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [VERIFY] Verify Sustainability fields in Page "Purchase Cr Memo Statistics" before posting of Purchase Cr Memo.
        CrMemoNo := CreateCorrectiveCreditMemoAndOpenPurchaseCrMemoStatistics(PurchaseHeader);

        // [GIVEN] Post Corrective Credit Memo.
        PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", CrMemoNo);
        PostedCrMemoNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [GIVEN] Clear Variable Storage.
        LibraryVariableStorage.Clear();

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2PerUnit);
        LibraryVariableStorage.Enqueue(EmissionCH4PerUnit);
        LibraryVariableStorage.Enqueue(EmissionN2OPerUnit);

        // [VERIFY] Verify Sustainability fields in Page "Posted Purchase Cr Memo Statistics" after posting of Purchase Cr Memo.
        VerifyPostedPurchaseCrMemoStatistics(PostedCrMemoNo);
        LibraryVariableStorage.Clear();
    end;

    [Test]
    [HandlerFunctions('GLPostingPreviewHandler')]
    procedure VerifySustainabilityLedgerEntryShouldBeCreatedDuringPreviewPostingOfPurchaseOrder()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Ledger Entry should be created during Preview Posting of purchase order.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
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
    procedure VerifySustainabilityLedgerEntryShouldBeShownWhenNavigatingPostedPurchaseInvoice()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseInvHeader: Record "Purch. Inv. Header";
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedPurchInvNo: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Ledger Entry should be shown when navigating Posted Purchase Invoice through NavigateFindEntriesHandler handler.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        PostedPurchInvNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability Ledger Entry should be shown when navigating Posted Purchase Invoice through NavigateFindEntriesHandler handler.
        PurchaseInvHeader.Get(PostedPurchInvNo);
        PurchaseInvHeader.Navigate();
    end;

    [Test]
    [HandlerFunctions('PurchaseInvoiceStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInPurchaseCrMemoSubFormPage()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchCrMemoSubformPage: TestPage "Purch. Cr. Memo Subform";
        PostedPurchCrMemoSubformPage: TestPage "Posted Purch. Cr. Memo Subform";
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        CrMemoNo: Code[20];
        PostedCrMemoNo: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability fields in Purchase Cr Memo SubForm Page.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2PerUnit);
        LibraryVariableStorage.Enqueue(EmissionCH4PerUnit);
        LibraryVariableStorage.Enqueue(EmissionN2OPerUnit);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [WHEN] Create Corrective Credit Memo.
        CrMemoNo := CreateCorrectiveCreditMemoAndOpenPurchaseCrMemoStatistics(PurchaseHeader);

        // [VERIFY] Verify Sustainability fields before posting of Corrective Credit Memo.
        PurchCrMemoSubformPage.OpenEdit();
        PurchCrMemoSubformPage.Filter.SetFilter("Document No.", CrMemoNo);
        PurchCrMemoSubformPage.Filter.SetFilter("No.", PurchaseLine."No.");
        PurchCrMemoSubformPage."Sust. Account No.".AssertEquals(AccountCode);
        PurchCrMemoSubformPage."Emission CH4 Per Unit".AssertEquals(EmissionCH4PerUnit);
        PurchCrMemoSubformPage."Emission CO2 Per Unit".AssertEquals(EmissionCO2PerUnit);
        PurchCrMemoSubformPage."Emission N2O Per Unit".AssertEquals(EmissionN2OPerUnit);

        // [GIVEN] Post Corrective Credit Memo.
        PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", CrMemoNo);
        PostedCrMemoNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [GIVEN] Clear Variable Storage.
        LibraryVariableStorage.Clear();

        // [VERIFY] Verify Sustainability fields After posting of Corrective Credit Memo.
        PostedPurchCrMemoSubformPage.OpenEdit();
        PostedPurchCrMemoSubformPage.Filter.SetFilter("Document No.", PostedCrMemoNo);
        PostedPurchCrMemoSubformPage.Filter.SetFilter("No.", PurchaseLine."No.");
        PostedPurchCrMemoSubformPage."Sust. Account No.".AssertEquals(AccountCode);
        PostedPurchCrMemoSubformPage."Emission CH4".AssertEquals(EmissionCH4PerUnit);
        PostedPurchCrMemoSubformPage."Emission CO2".AssertEquals(EmissionCO2PerUnit);
        PostedPurchCrMemoSubformPage."Emission N2O".AssertEquals(EmissionN2OPerUnit);
    end;

    [Test]
    procedure VerifySustainabilityBaseLineFieldsShouldBeFilteredBasedOnBaseLinePeriodInSustainabilityGoalsPage()
    var
        UserSetup: Record "User Setup";
        SustainabilityGoal: array[2] of Record "Sustainability Goal";
        SustainabilityScorecard: Record "Sustainability Scorecard";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SustainabilityGoals: TestPage "Sustainability Goals";
        ScorecardCode: Code[20];
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability BaseLine Fields should be filtered based on "Baseline Period" in Sustainability Goals Page.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create User Setup with Sustainability Manager.
        UserSetup.DeleteAll();
        CreateUserSetup(UserSetup, CopyStr(UserId(), 1, 50));
        UserSetup.Validate("Sustainability Manager", true);
        UserSetup.Modify();

        // [GIVEN] Create a Sustainability Scorecard.
        ScorecardCode := LibraryUtility.GenerateRandomCode(SustainabilityScorecard.FieldNo("No."), DATABASE::"Sustainability Scorecard");
        LibrarySustainability.InsertSustainabilityScorecard(
            SustainabilityScorecard,
            ScorecardCode,
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Create a Sustainability Goal.
        LibrarySustainability.InsertSustainabilityGoal(
            SustainabilityGoal[1],
            LibraryUtility.GenerateRandomCode(SustainabilityGoal[1].FieldNo("No."), DATABASE::"Sustainability Goal"),
            ScorecardCode,
            LibraryRandom.RandInt(1000),
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Update Owner in the Sustainability Goal.
        SustainabilityGoal[1].Validate(Owner, UserSetup."User ID");
        SustainabilityGoal[1].Validate("Baseline Start Date", Today());
        SustainabilityGoal[1].Validate("Baseline End Date", Today());
        SustainabilityGoal[1].Modify();

        // [GIVEN] Create another Sustainability Goal.
        LibrarySustainability.InsertSustainabilityGoal(
            SustainabilityGoal[2],
            LibraryUtility.GenerateRandomCode(SustainabilityGoal[1].FieldNo("No."), DATABASE::"Sustainability Goal"),
            ScorecardCode,
            LibraryRandom.RandInt(1000),
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Update Owner in the Sustainability Goal.
        SustainabilityGoal[2].Validate(Owner, UserSetup."User ID");
        SustainabilityGoal[2].Validate("Baseline Start Date", Today() + 1);
        SustainabilityGoal[2].Validate("Baseline End Date", Today() + 1);
        SustainabilityGoal[2].Modify();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Change WorkDate.
        WorkDate(Today);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Document Date", Today);
        PurchaseHeader.Validate("Posting Date", Today);
        PurchaseHeader.Modify();

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [GIVEN] Post Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [GIVEN] Change WorkDate.
        WorkDate(Today + 1);

        // [GIVEN] Create another Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Document Date", Today + 1);
        PurchaseHeader.Validate("Posting Date", Today + 1);
        PurchaseHeader.Modify();

        // [GIVEN] Create another Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit + 1);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit + 1);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit + 1);
        PurchaseLine.Modify();

        // [GIVEN] Post another Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Open and Filter Sustainability Goals page.
        SustainabilityGoals.OpenView();
        SustainabilityGoals.GoToRecord(SustainabilityGoal[1]);

        // [VERIFY] Verify Sustainability BaseLine Fields should be filtered based on "Baseline Period" in Sustainability Goals Page.
        SustainabilityGoals."Baseline for CH4".AssertEquals(EmissionCH4PerUnit);
        SustainabilityGoals."Baseline for CO2".AssertEquals(EmissionCO2PerUnit);
        SustainabilityGoals."Baseline for N2O".AssertEquals(EmissionN2OPerUnit);

        // [WHEN] Open and Filter Sustainability Goals page.
        SustainabilityGoals.GoToRecord(SustainabilityGoal[2]);

        // [VERIFY] Verify Sustainability BaseLine Fields should be filtered based on "Baseline Period" in Sustainability Goals Page.
        SustainabilityGoals."Baseline for CH4".AssertEquals(EmissionCH4PerUnit + 1);
        SustainabilityGoals."Baseline for CO2".AssertEquals(EmissionCO2PerUnit + 1);
        SustainabilityGoals."Baseline for N2O".AssertEquals(EmissionN2OPerUnit + 1);
    end;

    [Test]
    procedure VerifySustainabilityCurrentFieldsShouldBeFilteredBasedOnCurrentPeriodFilterInSustainabilityGoalsPage()
    var
        UserSetup: Record "User Setup";
        SustainabilityGoal: array[2] of Record "Sustainability Goal";
        SustainabilityScorecard: Record "Sustainability Scorecard";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SustainabilityGoals: TestPage "Sustainability Goals";
        ScorecardCode: Code[20];
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Current Fields should be filtered based on "Current Period Filter" in Sustainability Goals Page.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create User Setup with Sustainability Manager.
        UserSetup.DeleteAll();
        CreateUserSetup(UserSetup, CopyStr(UserId(), 1, 50));
        UserSetup.Validate("Sustainability Manager", true);
        UserSetup.Modify();

        // [GIVEN] Create a Sustainability Scorecard.
        ScorecardCode := LibraryUtility.GenerateRandomCode(SustainabilityScorecard.FieldNo("No."), DATABASE::"Sustainability Scorecard");
        LibrarySustainability.InsertSustainabilityScorecard(
            SustainabilityScorecard,
            ScorecardCode,
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Create a Sustainability Goal.
        LibrarySustainability.InsertSustainabilityGoal(
            SustainabilityGoal[1],
            LibraryUtility.GenerateRandomCode(SustainabilityGoal[1].FieldNo("No."), DATABASE::"Sustainability Goal"),
            ScorecardCode,
            LibraryRandom.RandInt(1000),
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Update Owner in the Sustainability Goal.
        SustainabilityGoal[1].Validate(Owner, UserSetup."User ID");
        SustainabilityGoal[1].Modify();

        // [GIVEN] Create another Sustainability Goal.
        LibrarySustainability.InsertSustainabilityGoal(
            SustainabilityGoal[2],
            LibraryUtility.GenerateRandomCode(SustainabilityGoal[1].FieldNo("No."), DATABASE::"Sustainability Goal"),
            ScorecardCode,
            LibraryRandom.RandInt(1000),
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Update Owner in the Sustainability Goal.
        SustainabilityGoal[2].Validate(Owner, UserSetup."User ID");
        SustainabilityGoal[2].Modify();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Change WorkDate.
        WorkDate(Today);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Document Date", Today);
        PurchaseHeader.Validate("Posting Date", Today);
        PurchaseHeader.Modify();

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [GIVEN] Post Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [GIVEN] Change WorkDate.
        WorkDate(Today + 1);

        // [GIVEN] Create another Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Validate("Document Date", Today + 1);
        PurchaseHeader.Validate("Posting Date", Today + 1);
        PurchaseHeader.Modify();

        // [GIVEN] Create another Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit + 1);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit + 1);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit + 1);
        PurchaseLine.Modify();

        // [GIVEN] Post another Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Open and Filter Sustainability Goals page.
        SustainabilityGoals.OpenView();
        SustainabilityGoals.Filter.SetFilter("Current Period Filter", Format(Today));
        SustainabilityGoals.GoToRecord(SustainabilityGoal[1]);

        // [VERIFY] Verify Sustainability Current Value Fields should be filtered based on "Current Period Filter" in Sustainability Goals Page.
        SustainabilityGoals."Current Value for CH4".AssertEquals(0);
        SustainabilityGoals."Current Value for CO2".AssertEquals(0);
        SustainabilityGoals."Current Value for N2O".AssertEquals(0);
        SustainabilityGoals.Close();

        // [WHEN] Update Start Date And End Date in Sustainability Goal.
        SustainabilityGoal[1].Validate("Start Date", Today);
        SustainabilityGoal[1].Validate("End Date", Today);
        SustainabilityGoal[1].Modify();

        // [VERIFY] Verify Sustainability Current Value Fields should be filtered based on Start And End Date in Sustainability Goals Page.
        SustainabilityGoals.OpenView();
        SustainabilityGoals.GoToRecord(SustainabilityGoal[1]);
        SustainabilityGoals."Current Value for CH4".AssertEquals(EmissionCH4PerUnit);
        SustainabilityGoals."Current Value for CO2".AssertEquals(EmissionCO2PerUnit);
        SustainabilityGoals."Current Value for N2O".AssertEquals(EmissionN2OPerUnit);
        SustainabilityGoals.Close();

        // [WHEN] Open and Filter Sustainability Goals page.
        SustainabilityGoals.OpenView();
        SustainabilityGoals.Filter.SetFilter("Current Period Filter", Format(Today + 1));
        SustainabilityGoals.GoToRecord(SustainabilityGoal[2]);

        // [VERIFY] Verify Sustainability Current Value Fields should be filtered based on "Current Period Filter" in Sustainability Goals Page.
        SustainabilityGoals."Current Value for CH4".AssertEquals(0);
        SustainabilityGoals."Current Value for CO2".AssertEquals(0);
        SustainabilityGoals."Current Value for N2O".AssertEquals(0);
        SustainabilityGoals.Close();

        // [WHEN] Update Start Date And End Date in Sustainability Goal.
        SustainabilityGoal[2].Validate("Start Date", Today + 1);
        SustainabilityGoal[2].Validate("End Date", Today + 1);
        SustainabilityGoal[2].Modify();

        // [VERIFY] Verify Sustainability Current Value Fields should be filtered based on "Current Period Filter" in Sustainability Goals Page.
        SustainabilityGoals.OpenView();
        SustainabilityGoals.Filter.SetFilter("Current Period Filter", Format(Today + 1));
        SustainabilityGoals.GoToRecord(SustainabilityGoal[2]);
        SustainabilityGoals."Current Value for CH4".AssertEquals(EmissionCH4PerUnit + 1);
        SustainabilityGoals."Current Value for CO2".AssertEquals(EmissionCO2PerUnit + 1);
        SustainabilityGoals."Current Value for N2O".AssertEquals(EmissionN2OPerUnit + 1);
        SustainabilityGoals.Close();
    end;

    [Test]
    [HandlerFunctions('SustainabilityLedgerEntriesPageHandler')]
    procedure VerifySustainabilityLedgerEntriesShouldContainFilterOfPostingDate()
    var
        SustainabilityGoal: Record "Sustainability Goal";
        SustainabilityScorecard: Record "Sustainability Scorecard";
        SustainabilityScorecards: TestPage "Sustainability Scorecards";
        SustainabilityGoals: TestPage "Sustainability Goals";
        ScorecardCode: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Ledger Entries should contain filter of Posting Date When clicked on DrillDown of "Current Value for ***".
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Scorecard.
        ScorecardCode := LibraryUtility.GenerateRandomCode(SustainabilityScorecard.FieldNo("No."), DATABASE::"Sustainability Scorecard");
        LibrarySustainability.InsertSustainabilityScorecard(
            SustainabilityScorecard,
            ScorecardCode,
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        // [GIVEN] Create a Sustainability Goal.
        LibrarySustainability.InsertSustainabilityGoal(
            SustainabilityGoal,
            LibraryUtility.GenerateRandomCode(SustainabilityGoal.FieldNo("No."), DATABASE::"Sustainability Goal"),
            ScorecardCode,
            LibraryRandom.RandInt(1000),
            CopyStr(LibraryUtility.GenerateRandomText(100), 1, 100));

        SustainabilityGoal.Validate("Start Date", Today);
        SustainabilityGoal.Validate("End Date", Today + 1);
        SustainabilityGoal.Modify();

        // [GIVEN] Open Sustainability Goals page.
        SustainabilityScorecards.OpenView();
        SustainabilityScorecards.GoToRecord(SustainabilityScorecard);
        SustainabilityGoals.Trap();
        SustainabilityScorecards.Goals.Invoke();

        // [GIVEN] Save Start Date And End Date.
        LibraryVariableStorage.Enqueue(SustainabilityGoal."Start Date");
        LibraryVariableStorage.Enqueue(SustainabilityGoal."End Date");

        // [WHEN] Open Sustainability Ledger Entries for CH4.
        SustainabilityGoals."Current Value for CH4".Drilldown();

        // [GIVEN] Save Start Date And End Date.
        LibraryVariableStorage.Enqueue(SustainabilityGoal."Start Date");
        LibraryVariableStorage.Enqueue(SustainabilityGoal."End Date");

        // [WHEN] Open Sustainability Ledger Entries for N2O.
        SustainabilityGoals."Current Value for N2O".Drilldown();

        // [GIVEN] Save Start Date And End Date.
        LibraryVariableStorage.Enqueue(SustainabilityGoal."Start Date");
        LibraryVariableStorage.Enqueue(SustainabilityGoal."End Date");

        // [WHEN] Open Sustainability Ledger Entries for CO2.
        SustainabilityGoals."Current Value for CO2".Drilldown();

        // [VERIFY] Verify Sustainability Ledger Entries should contain filter of Posting Date When clicked on DrillDown of "Current Value for ***" through Handler.
        LibraryVariableStorage.Clear();
    end;

    [Test]
    procedure VerifyCO2eEmissionAndCarbonFeeInSustainabilityLedgerEntryWhenPurchDocumentIsPosted()
    var
        PurchaseLine: Record "Purchase Line";
        CountryRegion: Record "Country/Region";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        PostedInvoiceNo: Code[20];
        ExpectedCO2eEmission: Decimal;
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 538580] Verify CO2e Emission and Carbon Fee in Sustainability Ledger Entry When Purchase Document is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);
        SustainabilityAccount.CalcFields("Emission Scope");

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee for "Emission Type" CH4.
        LibrarySustainability.InsertEmissionFee(
            EmissionFee[1],
            "Emission Type"::CH4,
            SustainabilityAccount."Emission Scope",
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegion.Code,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));

        // [GIVEN] Create Emission Fee for "Emission Type" CO2.
        LibrarySustainability.InsertEmissionFee(
            EmissionFee[2],
            "Emission Type"::CO2,
            SustainabilityAccount."Emission Scope",
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegion.Code,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));
        EmissionFee[2].Validate("Carbon Fee", LibraryRandom.RandDecInDecimalRange(0.5, 2, 1));
        EmissionFee[2].Modify();

        // [GIVEN] Create Emission Fee for "Emission Type" N2O.
        LibrarySustainability.InsertEmissionFee(
            EmissionFee[3],
            "Emission Type"::N2O,
            SustainabilityAccount."Emission Scope",
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegion.Code,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Save Expected CO2e Emission and Carbon Fee.
        ExpectedCO2eEmission := EmissionCH4PerUnit * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2PerUnit * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2OPerUnit * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Update "Buy-from Country/Region Code" in Purchase Header.
        PurchaseHeader."Buy-from Country/Region Code" := CountryRegion.Code;
        PurchaseHeader.Modify();

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify CO2e Emission and Carbon Fee in Sustainability Ledger Entry When Purchase Document is posted.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedInvoiceNo);
        SustainabilityLedgerEntry.FindFirst();
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
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure VerifyCO2eEmissionAndCarbonFeeInSustainabilityLedgerEntryWhenSustJnlLineIsPosted()
    var
        UnitOfMeasure: Record "Unit of Measure";
        CountryRegion: Record "Country/Region";
        EmissionFee: array[3] of Record "Emission Fee";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        ExpectedCO2eEmission: Decimal;
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 538580] Verify CO2e Emission and Carbon Fee in Sustainability Ledger Entry When Sustainability Journal Line is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);
        SustainabilityAccount.CalcFields("Emission Scope");
        SustainAccountSubcategory.Get(CategoryCode, SubcategoryCode);

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Create Emission Fee for "Emission Type" CH4.
        LibrarySustainability.InsertEmissionFee(
            EmissionFee[1],
            "Emission Type"::CH4,
            SustainabilityAccount."Emission Scope",
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegion.Code,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));

        // [GIVEN] Create Emission Fee for "Emission Type" CO2.
        LibrarySustainability.InsertEmissionFee(
            EmissionFee[2],
            "Emission Type"::CO2,
            SustainabilityAccount."Emission Scope",
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegion.Code,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));
        EmissionFee[2].Validate("Carbon Fee", LibraryRandom.RandDecInDecimalRange(0.5, 2, 1));
        EmissionFee[2].Modify();

        // [GIVEN] Create Emission Fee for "Emission Type" N2O.
        LibrarySustainability.InsertEmissionFee(
            EmissionFee[3],
            "Emission Type"::N2O,
            SustainabilityAccount."Emission Scope",
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegion.Code,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandIntInRange(1, 1) * SustainAccountSubcategory."Emission Factor CO2";
        EmissionCH4PerUnit := LibraryRandom.RandIntInRange(1, 1) * SustainAccountSubcategory."Emission Factor CH4";
        EmissionN2OPerUnit := LibraryRandom.RandIntInRange(1, 1) * SustainAccountSubcategory."Emission Factor N2O";

        // [GIVEN] Save Expected CO2e Emission and Carbon Fee.
        ExpectedCO2eEmission := EmissionCH4PerUnit * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2PerUnit * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2OPerUnit * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCarbonFee := ExpectedCO2eEmission * (EmissionFee[1]."Carbon Fee" + EmissionFee[2]."Carbon Fee" + EmissionFee[3]."Carbon Fee");

        // [GIVEN] Get Sustainability Journal Batch
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);

        // [GIVEN] Create a Sustainability Journal Line.
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);

        // [GIVEN] Create Unit of Measure Code.
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        // [GIVEN] Update "Buy-from Country/Region Code" in Sustainability Journal Line.
        SustainabilityJournalLine.Validate("Document No.", SustainabilityJournalMgt.GetDocumentNo(false, SustainabilityJnlBatch, '', SustainabilityJournalLine."Posting Date"));
        SustainabilityJournalLine.Validate(Description, LibraryRandom.RandText(10));
        SustainabilityJournalLine.Validate("Unit of Measure", UnitOfMeasure.Code);
        SustainabilityJournalLine.Validate("Fuel/Electricity", LibraryRandom.RandIntInRange(1, 1));
        SustainabilityJournalLine.Validate("Country/Region Code", CountryRegion.Code);
        SustainabilityJournalLine.Modify();

        // [WHEN] Post a Sustainability Journal Line.
        SustainabilityJournalLine.SetRange("Journal Template Name", SustainabilityJournalLine."Journal Template Name");
        SustainabilityJournalLine.SetRange("Journal Batch Name", SustainabilityJournalLine."Journal Batch Name");
        Codeunit.Run(Codeunit::"Sustainability Jnl.-Post", SustainabilityJournalLine);

        // [VERIFY] Verify "CO2e Emission" and "Carbon Fee" in Sustainability Ledger Entry When Sustainability Journal Line is posted.
        SustainabilityLedgerEntry.SetRange("Journal Template Name", SustainabilityJournalLine."Journal Template Name");
        SustainabilityLedgerEntry.SetRange("Journal Batch Name", SustainabilityJournalLine."Journal Batch Name");
        SustainabilityLedgerEntry.SetRange("Posting Date", SustainabilityJournalLine."Posting Date");
        SustainabilityLedgerEntry.FindFirst();
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
    [HandlerFunctions('MessageHandler')]
    procedure VerifyCO2eEmissionAndCarbonFeeValuesInSustainabilityLedgerEntrythrougReportBatchUpdateCarbonEmission()
    var
        PurchaseLine: Record "Purchase Line";
        CountryRegion: Record "Country/Region";
        PurchaseHeader: Record "Purchase Header";
        EmissionFee: array[3] of Record "Emission Fee";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        BatchUpdateCarbonEmission: Report "Batch Update Carbon Emission";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        PostedInvoiceNo: Code[20];
        ExpectedCO2eEmission: Decimal;
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        ExpectedCarbonFee: Decimal;
    begin
        // [SCENARIO 538580] Verify CO2e Emission and Carbon Fee in Sustainability Ledger Entry throug Report "Batch Update Carbon Emission".
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);
        SustainabilityAccount.CalcFields("Emission Scope");

        // [GIVEN] Create Country/Region.
        LibraryERM.CreateCountryRegion(CountryRegion);

        // [GIVEN] Generate Emission per Unit.
        EmissionCO2PerUnit := LibraryRandom.RandInt(5);
        EmissionCH4PerUnit := LibraryRandom.RandInt(5);
        EmissionN2OPerUnit := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Update "Buy-from Country/Region Code" in Purchase Header.
        PurchaseHeader."Buy-from Country/Region Code" := CountryRegion.Code;
        PurchaseHeader.Modify();

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 Per Unit,Emission CH4 Per Unit,Emission N2O Per Unit.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [GIVEN] Create Emission Fee for "Emission Type" CH4.
        LibrarySustainability.InsertEmissionFee(
            EmissionFee[1],
            "Emission Type"::CH4,
            SustainabilityAccount."Emission Scope",
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegion.Code,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));

        // [GIVEN] Create Emission Fee for "Emission Type" CO2.
        LibrarySustainability.InsertEmissionFee(
            EmissionFee[2],
            "Emission Type"::CO2,
            SustainabilityAccount."Emission Scope",
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegion.Code,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));
        EmissionFee[2].Validate("Carbon Fee", LibraryRandom.RandDecInDecimalRange(0.5, 2, 1));
        EmissionFee[2].Modify();

        // [GIVEN] Create Emission Fee for "Emission Type" N2O.
        LibrarySustainability.InsertEmissionFee(
            EmissionFee[3],
            "Emission Type"::N2O,
            SustainabilityAccount."Emission Scope",
            CalcDate('<-CM>', WorkDate()),
            CalcDate('<CM>', WorkDate()),
            CountryRegion.Code,
            LibraryRandom.RandDecInDecimalRange(0.5, 1, 1));

        // [GIVEN] Save Expected CO2e Emission and Carbon Fee.
        GetCarbonFeeEmissionValues(
            WorkDate(),
            CountryRegion.Code,
            EmissionCO2PerUnit,
            EmissionN2OPerUnit,
            EmissionCH4PerUnit,
            SustainabilityAccount."Emission Scope",
            ExpectedCO2eEmission,
            ExpectedCarbonFee);

        // [GIVEN] Verify CO2e Emission and Carbon Fee field value should be zero in Sustainability Ledger Entry.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedInvoiceNo);
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), 0, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."Carbon Fee",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Carbon Fee"), 0, SustainabilityLedgerEntry.TableCaption()));

        // [WHEN] Run Report "Batch Update Carbon Emission".
        BatchUpdateCarbonEmission.UseRequestPage(false);
        BatchUpdateCarbonEmission.Run();

        // [VERIFY] Verify CO2e Emission and Carbon Fee in Sustainability Ledger Entry throug Report "Batch Update Carbon Emission".
        SustainabilityLedgerEntry.SetRange("Document No.", PostedInvoiceNo);
        SustainabilityLedgerEntry.FindFirst();
        Assert.AreEqual(
            ExpectedCO2eEmission,
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), ExpectedCO2eEmission, SustainabilityLedgerEntry.TableCaption()));
        Assert.AreEqual(
            ExpectedCarbonFee,
            SustainabilityLedgerEntry."Carbon Fee",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("Carbon Fee"), ExpectedCarbonFee, SustainabilityLedgerEntry.TableCaption()));
    end;

    local procedure CreateUserSetup(var UserSetup: Record "User Setup"; UserID: Code[50])
    begin
        UserSetup.Init();
        UserSetup."User ID" := UserID;
        UserSetup.Insert();
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

    local procedure PostAndVerifyCorrectiveCreditMemo(PurchaseHeader: Record "Purchase Header")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        PostedDocNumber: Code[20];
    begin
        PostedDocNumber := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchInvHeader.Get(PostedDocNumber);

        // Create Corrective Credit Memo.
        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvHeader, PurchaseHeader);
        PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryRandom.RandText(10));
        PurchaseHeader.Modify();

        // Post Corrective Credit Memo.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    local procedure OpenPurchaseOrderStatistics(No: Code[20])
    var
        PurchaseOrder: TestPage "Purchase Order";
    begin
        PurchaseOrder.OpenEdit();
        PurchaseOrder.FILTER.SetFilter("No.", No);
        PurchaseOrder.Statistics.Invoke();
    end;

    local procedure OpenPurchaseInvoiceStatistics(No: Code[20])
    var
        PurchaseInvoice: TestPage "Purchase Invoice";
    begin
        PurchaseInvoice.OpenEdit();
        PurchaseInvoice.FILTER.SetFilter("No.", No);
        PurchaseInvoice.Statistics.Invoke();
    end;

    local procedure OpenPurchaseCrMemoStatistics(No: Code[20])
    var
        PurchaseCreditMemo: TestPage "Purchase Credit Memo";
    begin
        PurchaseCreditMemo.OpenEdit();
        PurchaseCreditMemo.FILTER.SetFilter("No.", No);
        PurchaseCreditMemo.Statistics.Invoke();
    end;

    local procedure VerifyPostedPurchaseCrMemoStatistics(No: Code[20])
    var
        PostedPurchaseCreditMemoStatisticsPage: TestPage "Purch. Credit Memo Statistics";
        PostedEmissionCO2: Variant;
        PostedEmissionCH4: Variant;
        PostedEmissionN2O: Variant;
    begin
        LibraryVariableStorage.Dequeue(PostedEmissionCO2);
        LibraryVariableStorage.Dequeue(PostedEmissionCH4);
        LibraryVariableStorage.Dequeue(PostedEmissionN2O);

        PostedPurchaseCreditMemoStatisticsPage.OpenEdit();
        PostedPurchaseCreditMemoStatisticsPage.FILTER.SetFilter("No.", No);
        PostedPurchaseCreditMemoStatisticsPage."Emission C02".AssertEquals(PostedEmissionCO2);
        PostedPurchaseCreditMemoStatisticsPage."Emission CH4".AssertEquals(PostedEmissionCH4);
        PostedPurchaseCreditMemoStatisticsPage."Emission N2O".AssertEquals(PostedEmissionN2O);
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

    local procedure CreateCorrectiveCreditMemoAndOpenPurchaseCrMemoStatistics(PurchaseHeader: Record "Purchase Header"): Code[20]
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        CorrectPostedPurchInvoice: Codeunit "Correct Posted Purch. Invoice";
        PostedDocNumber: Code[20];
    begin
        PostedDocNumber := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchInvHeader.Get(PostedDocNumber);

        // Create Corrective Credit Memo.
        CorrectPostedPurchInvoice.CreateCreditMemoCopyDocument(PurchInvHeader, PurchaseHeader);
        PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryRandom.RandText(10));
        PurchaseHeader.Modify();

        // Open Purchase Cr Memo Statistics.
        OpenPurchaseCrMemoStatistics(PurchaseHeader."No.");

        exit(PurchaseHeader."No.");
    end;

    local procedure GetCarbonFeeEmissionValues(
        PostingDate: Date;
        CountryRegionCode: Code[20];
        EmissionCO2: Decimal;
        EmissionN2O: Decimal;
        EmissionCH4: Decimal;
        ScopeType: Enum "Emission Scope";
        var CO2eEmission: Decimal;
        var CarbonFee: Decimal): Decimal
    var
        EmissionFee: Record "Emission Fee";
        CO2Factor: Decimal;
        N2OFactor: Decimal;
        CH4Factor: Decimal;
        CarbonFeeEmission: Decimal;
    begin
        EmissionFee.SetFilter("Scope Type", '%1|%2', ScopeType, ScopeType::" ");
        EmissionFee.SetFilter("Starting Date", '<=%1|%2', PostingDate, 0D);
        EmissionFee.SetFilter("Ending Date", '>=%1|%2', PostingDate, 0D);
        EmissionFee.SetFilter("Country/Region Code", '%1|%2', CountryRegionCode, '');

        if EmissionCO2 <> 0 then
            if FindEmissionFeeForEmissionType(EmissionFee, Enum::"Emission Type"::CO2) then begin
                CO2Factor := EmissionFee."Carbon Equivalent Factor";
                CarbonFeeEmission := EmissionFee."Carbon Fee";
            end;

        if EmissionN2O <> 0 then
            if FindEmissionFeeForEmissionType(EmissionFee, Enum::"Emission Type"::N2O) then begin
                N2OFactor := EmissionFee."Carbon Equivalent Factor";
                CarbonFeeEmission += EmissionFee."Carbon Fee";
            end;

        if EmissionCH4 <> 0 then
            if FindEmissionFeeForEmissionType(EmissionFee, Enum::"Emission Type"::CH4) then begin
                CH4Factor := EmissionFee."Carbon Equivalent Factor";
                CarbonFeeEmission += EmissionFee."Carbon Fee";
            end;

        CO2eEmission := (EmissionCO2 * CO2Factor) + (EmissionN2O * N2OFactor) + (EmissionCH4 * CH4Factor);
        CarbonFee := CO2eEmission * CarbonFeeEmission;
    end;

    local procedure FindEmissionFeeForEmissionType(var EmissionFee: Record "Emission Fee"; EmissionType: Enum "Emission Type"): Boolean
    begin
        EmissionFee.SetRange("Emission Type", EmissionType);
        if EmissionFee.FindLast() then
            exit(true);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure PurchaseOrderStatisticsPageHandler(var PurchaseOrderStatisticsPage: TestPage "Purchase Order Statistics")
    var
        EmissionCO2PerUnit: Variant;
        EmissionCH4PerUnit: Variant;
        EmissionN2OPerUnit: Variant;
        PostedEmissionCO2: Variant;
        PostedEmissionCH4: Variant;
        PostedEmissionN2O: Variant;
    begin
        LibraryVariableStorage.Dequeue(EmissionCO2PerUnit);
        LibraryVariableStorage.Dequeue(EmissionCH4PerUnit);
        LibraryVariableStorage.Dequeue(EmissionN2OPerUnit);
        LibraryVariableStorage.Dequeue(PostedEmissionCO2);
        LibraryVariableStorage.Dequeue(PostedEmissionCH4);
        LibraryVariableStorage.Dequeue(PostedEmissionN2O);

        PurchaseOrderStatisticsPage."Emission C02".AssertEquals(EmissionCO2PerUnit);
        PurchaseOrderStatisticsPage."Emission CH4".AssertEquals(EmissionCH4PerUnit);
        PurchaseOrderStatisticsPage."Emission N2O".AssertEquals(EmissionN2OPerUnit);
        PurchaseOrderStatisticsPage."Posted Emission C02".AssertEquals(PostedEmissionCO2);
        PurchaseOrderStatisticsPage."Posted Emission CH4".AssertEquals(PostedEmissionCH4);
        PurchaseOrderStatisticsPage."Posted Emission N2O".AssertEquals(PostedEmissionN2O);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure PurchaseInvoiceStatisticsPageHandler(var PurchaseStatisticsPage: TestPage "Purchase Statistics")
    var
        EmissionCO2PerUnit: Variant;
        EmissionCH4PerUnit: Variant;
        EmissionN2OPerUnit: Variant;
        PostedEmissionCO2: Variant;
        PostedEmissionCH4: Variant;
        PostedEmissionN2O: Variant;
    begin
        LibraryVariableStorage.Dequeue(EmissionCO2PerUnit);
        LibraryVariableStorage.Dequeue(EmissionCH4PerUnit);
        LibraryVariableStorage.Dequeue(EmissionN2OPerUnit);
        LibraryVariableStorage.Dequeue(PostedEmissionCO2);
        LibraryVariableStorage.Dequeue(PostedEmissionCH4);
        LibraryVariableStorage.Dequeue(PostedEmissionN2O);

        PurchaseStatisticsPage."Emission C02".AssertEquals(EmissionCO2PerUnit);
        PurchaseStatisticsPage."Emission CH4".AssertEquals(EmissionCH4PerUnit);
        PurchaseStatisticsPage."Emission N2O".AssertEquals(EmissionN2OPerUnit);
        PurchaseStatisticsPage."Posted Emission C02".AssertEquals(PostedEmissionCO2);
        PurchaseStatisticsPage."Posted Emission CH4".AssertEquals(PostedEmissionCH4);
        PurchaseStatisticsPage."Posted Emission N2O".AssertEquals(PostedEmissionN2O);
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure GLPostingPreviewHandler(var GLPostingPreview: TestPage "G/L Posting Preview")
    begin
        GLPostingPreview.Filter.SetFilter("Table ID", Format(Database::"Sustainability Ledger Entry"));
        GLPostingPreview."No. of Records".AssertEquals(1);
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

    [PageHandler]
    [Scope('OnPrem')]
    procedure SustainabilityLedgerEntriesPageHandler(var SustainabilityLedgerEntries: TestPage "Sustainability Ledger Entries")
    var
        ExpectedFilter: Variant;
        StartDate: Variant;
        EndDate: Variant;
    begin
        LibraryVariableStorage.Dequeue(StartDate);
        LibraryVariableStorage.Dequeue(EndDate);

        ExpectedFilter := Format(StartDate) + Format('..') + Format(EndDate);
        Assert.AreEqual(
            ExpectedFilter,
            SustainabilityLedgerEntries.Filter.GetFilter("Posting Date"),
            StrSubstNo(FilterMustBeEqualErr, ExpectedFilter, SustainabilityLedgerEntries.Caption()));
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Msg: Text[1024])
    begin
    end;
}