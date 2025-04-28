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
        LibrarySales: Codeunit "Library - Sales";
        LibraryAssembly: Codeunit "Library - Assembly";
        LibraryResource: Codeunit "Library - Resource";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        InformationTakenToLedgerEntryLbl: Label '%1 on the Ledger Entry should be taken from %2', Locked = true;
        ValueMustBeEqualErr: Label '%1 must be equal to %2 in the %3.', Comment = '%1 = Field Caption , %2 = Expected Value, %3 = Table Caption';
        FilterMustBeEqualErr: Label 'Filter must be equal to %1 in the %2', Comment = '%1 = Expected Value , %2 = Page Caption';
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';
        SustLedgerEntryShouldNotBeFoundErr: Label 'Sustainability Ledger Entry should not be found';
        SustValueEntryShouldNotBeFoundErr: Label 'Sustainability Value Entry should not be found';
        FieldShouldNotBeEditableErr: Label '%1 should not be editable in Page %2.', Comment = '%1 = Field Caption , %2 = Page Caption';
        FieldShouldBeEditableErr: Label '%1 should be editable in Page %2.', Comment = '%1 = Field Caption , %2 = Page Caption';

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
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
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

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2,Emission CH4,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability Ledger entry should be created when the purchase document is posted.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedInvoiceNo);
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
    procedure VerifySustainabilityLedgerEntryShouldBeCreatedWhenPurchDocumentIsPartiallyPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
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
        // [SCENARIO 496561] Verify Sustainability Ledger entry should be created when the purchase document is posted.
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
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
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

        // [WHEN] Post a Purchase Document.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability Ledger entry should be created when the purchase document is posted.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedInvoiceNo);
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
    procedure VerifySustainabilityLedgerEntryShouldBeKnockedOffWhenCancelCreditMemoIsPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
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
        // [SCENARIO 496561] Verify Sustainability Ledger entry should be Kocked Off when the Cancel Credit Memo is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

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
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
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
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Ledger entry should be Kocked Off when the Corrective Credit Memo is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

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
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
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
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
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

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability Fields In Purchase Receipt Line and Purchase Invoice Line.
        PostedPurchInvoiceSubform.OpenEdit();
        PostedPurchInvoiceSubform.FILTER.SetFilter("Document No.", PostedInvoiceNo);
        PostedPurchInvoiceSubform."Emission CH4".AssertEquals(EmissionCH4);
        PostedPurchInvoiceSubform."Emission CO2".AssertEquals(EmissionCO2);
        PostedPurchInvoiceSubform."Emission N2O".AssertEquals(EmissionN2O);
        PostedPurchInvoiceSubform."Sust. Account No.".AssertEquals(AccountCode);

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
        // [SCENARIO 496561] Verify Posted Emission fields in Purchase Line.
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
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
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

        // [WHEN] Post a Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Posted Emission fields in Purchase Line.
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
        // [SCENARIO 496561] Verify Sustainability Fields in Purchase Order Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

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
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
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

        // [GIVEN] Post a Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2);
        LibraryVariableStorage.Enqueue(EmissionCH4);
        LibraryVariableStorage.Enqueue(EmissionN2O);
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission CO2 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5));
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission CH4 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5));
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission N2O Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5));

        // [VERIFY] Verify Sustainability fields in Page "Purchase Order Statistics" after partially posting of Purchase order.
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
        // [SCENARIO 496561] Verify Sustainability Fields in Purchase Order Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

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
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
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

        // [GIVEN] Post a Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2);
        LibraryVariableStorage.Enqueue(EmissionCH4);
        LibraryVariableStorage.Enqueue(EmissionN2O);
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission CO2 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5));
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission CH4 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5));
        LibraryVariableStorage.Enqueue(PurchaseLine."Emission N2O Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5));

        // [VERIFY] Verify Sustainability fields in Page "Purchase Order Statistics" after partially posting of Purchase order.
        OpenPurchOrderStatistics(PurchaseHeader."No.");
        LibraryVariableStorage.Clear();
    end;

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the PurchaseStatistics action. The new action uses RunObject and does not run the action trigger', '26.0')]
    [Test]
    [HandlerFunctions('PurchaseInvoiceStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInPurchaseInvoiceStatistics()
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
        // [SCENARIO 496561] Verify Sustainability Fields in Purchase Invoice Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Invoice, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
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

        // [VERIFY] Verify Sustainability fields in Page "Purchase Invoice Statistics" before posting of Purchase Invoice.
        OpenPurchaseInvoiceStatistics(PurchaseHeader."No.");
        LibraryVariableStorage.Clear();
    end;
#endif

    [Test]
    [HandlerFunctions('PurchInvoiceStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInPurchInvoiceStatistics()
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
        // [SCENARIO 496561] Verify Sustainability Fields in Purchase Invoice Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Invoice, LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
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

        // [VERIFY] Verify Sustainability fields in Page "Purchase Invoice Statistics" before posting of Purchase Invoice.
        OpenPurchInvoiceStatistics(PurchaseHeader."No.");
        LibraryVariableStorage.Clear();
    end;

    [Test]
    procedure VerifySustainabilityFieldsInPostedPurchaseInvoiceStatistics()
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
        // [SCENARIO 496561] Verify Sustainability Fields in Posted Purchase Invoice Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

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
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [GIVEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2);
        LibraryVariableStorage.Enqueue(EmissionCH4);
        LibraryVariableStorage.Enqueue(EmissionN2O);

        // [WHEN] Post Purchase Document.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability fields in Page "Posted Purchase Invoice Statistics".
        VerifyPostedPurchaseInvoiceStatistics(PostedInvoiceNo);
        LibraryVariableStorage.Clear();
    end;

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the PurchaseStatistics action. The new action uses RunObject and does not run the action trigger', '26.0')]
    [Test]
    [HandlerFunctions('PurchaseInvoiceStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInPurchaseCrMemoStatistics()
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
        CrMemoNo: Code[20];
        PostedCrMemoNo: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability fields in Posted Purchase Cr Memo Statistics.
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
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
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

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2);
        LibraryVariableStorage.Enqueue(EmissionCH4);
        LibraryVariableStorage.Enqueue(EmissionN2O);
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
        LibraryVariableStorage.Enqueue(-EmissionCO2);
        LibraryVariableStorage.Enqueue(-EmissionCH4);
        LibraryVariableStorage.Enqueue(-EmissionN2O);

        // [VERIFY] Verify Sustainability fields in Page "Posted Purchase Cr Memo Statistics" after posting of Purchase Cr Memo.
        VerifyPostedPurchaseCrMemoStatistics(PostedCrMemoNo);
        LibraryVariableStorage.Clear();
    end;
#endif

    [Test]
    [HandlerFunctions('PurchInvoiceStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInPurchCrMemoStatistics()
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
        CrMemoNo: Code[20];
        PostedCrMemoNo: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability fields in Posted Purchase Cr Memo Statistics.
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
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
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

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2);
        LibraryVariableStorage.Enqueue(EmissionCH4);
        LibraryVariableStorage.Enqueue(EmissionN2O);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [VERIFY] Verify Sustainability fields in Page "Purchase Cr Memo Statistics" before posting of Purchase Cr Memo.
        CrMemoNo := CreateCorrectiveCreditMemoAndOpenPurchCrMemoStatistics(PurchaseHeader);

        // [GIVEN] Post Corrective Credit Memo.
        PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", CrMemoNo);
        PostedCrMemoNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [GIVEN] Clear Variable Storage.
        LibraryVariableStorage.Clear();

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(-EmissionCO2);
        LibraryVariableStorage.Enqueue(-EmissionCH4);
        LibraryVariableStorage.Enqueue(-EmissionN2O);

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
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 496561] Verify Sustainability Ledger Entry should be created during Preview Posting of purchase order.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

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
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
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
    procedure VerifySustainabilityLedgerEntryShouldBeShownWhenNavigatingPostedPurchaseInvoice()
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
        // [SCENARIO 496561] Verify Sustainability Ledger Entry should be shown when navigating Posted Purchase Invoice through NavigateFindEntriesHandler handler.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

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
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify();

        // [WHEN] Post a Purchase Document.
        PostedPurchInvNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [VERIFY] Verify Sustainability Ledger Entry should be shown when navigating Posted Purchase Invoice through NavigateFindEntriesHandler handler.
        PurchaseInvHeader.Get(PostedPurchInvNo);
        PurchaseInvHeader.Navigate();
    end;

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the PurchaseStatistics action. The new action uses RunObject and does not run the action trigger', '26.0')]
    [Test]
    [HandlerFunctions('PurchaseInvoiceStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInPurchaseCrMemoSubFormPage()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchCrMemoSubformPage: TestPage "Purch. Cr. Memo Subform";
        PostedPurchCrMemoSubformPage: TestPage "Posted Purch. Cr. Memo Subform";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
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
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
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

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2);
        LibraryVariableStorage.Enqueue(EmissionCH4);
        LibraryVariableStorage.Enqueue(EmissionN2O);
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
        PurchCrMemoSubformPage."Emission CH4".AssertEquals(EmissionCH4);
        PurchCrMemoSubformPage."Emission CO2".AssertEquals(EmissionCO2);
        PurchCrMemoSubformPage."Emission N2O".AssertEquals(EmissionN2O);

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
        PostedPurchCrMemoSubformPage."Emission CH4".AssertEquals(EmissionCH4);
        PostedPurchCrMemoSubformPage."Emission CO2".AssertEquals(EmissionCO2);
        PostedPurchCrMemoSubformPage."Emission N2O".AssertEquals(EmissionN2O);
    end;
#endif

    [Test]
    [HandlerFunctions('PurchInvoiceStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInPurchCrMemoSubFormPage()
    var
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchCrMemoSubformPage: TestPage "Purch. Cr. Memo Subform";
        PostedPurchCrMemoSubformPage: TestPage "Posted Purch. Cr. Memo Subform";
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
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
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
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

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2);
        LibraryVariableStorage.Enqueue(EmissionCH4);
        LibraryVariableStorage.Enqueue(EmissionN2O);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [WHEN] Create Corrective Credit Memo.
        CrMemoNo := CreateCorrectiveCreditMemoAndOpenPurchCrMemoStatistics(PurchaseHeader);

        // [VERIFY] Verify Sustainability fields before posting of Corrective Credit Memo.
        PurchCrMemoSubformPage.OpenEdit();
        PurchCrMemoSubformPage.Filter.SetFilter("Document No.", CrMemoNo);
        PurchCrMemoSubformPage.Filter.SetFilter("No.", PurchaseLine."No.");
        PurchCrMemoSubformPage."Sust. Account No.".AssertEquals(AccountCode);
        PurchCrMemoSubformPage."Emission CH4".AssertEquals(EmissionCH4);
        PurchCrMemoSubformPage."Emission CO2".AssertEquals(EmissionCO2);
        PurchCrMemoSubformPage."Emission N2O".AssertEquals(EmissionN2O);

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
        PostedPurchCrMemoSubformPage."Emission CH4".AssertEquals(EmissionCH4);
        PostedPurchCrMemoSubformPage."Emission CO2".AssertEquals(EmissionCO2);
        PostedPurchCrMemoSubformPage."Emission N2O".AssertEquals(EmissionN2O);
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
        EmissionCO2: array[2] of Decimal;
        EmissionCH4: array[2] of Decimal;
        EmissionN2O: array[2] of Decimal;
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

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", LibraryRandom.RandInt(20));
        PurchaseLine.Validate("Emission CH4", LibraryRandom.RandInt(5));
        PurchaseLine.Validate("Emission N2O", LibraryRandom.RandInt(5));
        PurchaseLine.Modify();

        // [GIVEN] Save Expected Emission.
        EmissionCO2[1] := PurchaseLine."Emission CO2 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);
        EmissionCH4[1] := PurchaseLine."Emission CH4 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);
        EmissionN2O[1] := PurchaseLine."Emission N2O Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);

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

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", LibraryRandom.RandInt(30));
        PurchaseLine.Validate("Emission CH4", LibraryRandom.RandInt(100));
        PurchaseLine.Validate("Emission N2O", LibraryRandom.RandInt(300));
        PurchaseLine.Modify();

        // [GIVEN] Save Expected Emission.
        EmissionCO2[2] := PurchaseLine."Emission CO2 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);
        EmissionCH4[2] := PurchaseLine."Emission CH4 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);
        EmissionN2O[2] := PurchaseLine."Emission N2O Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);

        // [GIVEN] Post another Purchase Document.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Open and Filter Sustainability Goals page.
        SustainabilityGoals.OpenView();
        SustainabilityGoals.GoToRecord(SustainabilityGoal[1]);

        // [VERIFY] Verify Sustainability BaseLine Fields should be filtered based on "Baseline Period" in Sustainability Goals Page.
        SustainabilityGoals."Baseline for CH4".AssertEquals(EmissionCH4[1]);
        SustainabilityGoals."Baseline for CO2".AssertEquals(EmissionCO2[1]);
        SustainabilityGoals."Baseline for N2O".AssertEquals(EmissionN2O[1]);

        // [WHEN] Open and Filter Sustainability Goals page.
        SustainabilityGoals.GoToRecord(SustainabilityGoal[2]);

        // [VERIFY] Verify Sustainability BaseLine Fields should be filtered based on "Baseline Period" in Sustainability Goals Page.
        SustainabilityGoals."Baseline for CH4".AssertEquals(EmissionCH4[2]);
        SustainabilityGoals."Baseline for CO2".AssertEquals(EmissionCO2[2]);
        SustainabilityGoals."Baseline for N2O".AssertEquals(EmissionN2O[2]);
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
        EmissionCO2: array[2] of Decimal;
        EmissionCH4: array[2] of Decimal;
        EmissionN2O: array[2] of Decimal;
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

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", LibraryRandom.RandInt(100));
        PurchaseLine.Validate("Emission CH4", LibraryRandom.RandInt(200));
        PurchaseLine.Validate("Emission N2O", LibraryRandom.RandInt(300));
        PurchaseLine.Modify();

        // [GIVEN] Save Expected Emission.
        EmissionCO2[1] := PurchaseLine."Emission CO2 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);
        EmissionCH4[1] := PurchaseLine."Emission CH4 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);
        EmissionN2O[1] := PurchaseLine."Emission N2O Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);

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

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", LibraryRandom.RandInt(500));
        PurchaseLine.Validate("Emission CH4", LibraryRandom.RandInt(600));
        PurchaseLine.Validate("Emission N2O", LibraryRandom.RandInt(700));
        PurchaseLine.Modify();

        // [GIVEN] Save Expected Emission.
        EmissionCO2[2] := PurchaseLine."Emission CO2 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);
        EmissionCH4[2] := PurchaseLine."Emission CH4 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);
        EmissionN2O[2] := PurchaseLine."Emission N2O Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);

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
        SustainabilityGoal[1].Validate("Baseline Start Date", Today - 1);
        SustainabilityGoal[1].Validate("Baseline End Date", Today - 1);
        SustainabilityGoal[1].Validate("Start Date", Today);
        SustainabilityGoal[1].Validate("End Date", Today);
        SustainabilityGoal[1].Modify();

        // [VERIFY] Verify Sustainability Current Value Fields should be filtered based on Start And End Date in Sustainability Goals Page.
        SustainabilityGoals.OpenView();
        SustainabilityGoals.GoToRecord(SustainabilityGoal[1]);
        SustainabilityGoals."Current Value for CH4".AssertEquals(EmissionCH4[1]);
        SustainabilityGoals."Current Value for CO2".AssertEquals(EmissionCO2[1]);
        SustainabilityGoals."Current Value for N2O".AssertEquals(EmissionN2O[1]);
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
        SustainabilityGoal[2].Validate("Baseline Start Date", Today);
        SustainabilityGoal[2].Validate("Baseline End Date", Today);
        SustainabilityGoal[2].Validate("Start Date", Today + 1);
        SustainabilityGoal[2].Validate("End Date", Today + 1);
        SustainabilityGoal[2].Modify();

        // [VERIFY] Verify Sustainability Current Value Fields should be filtered based on "Current Period Filter" in Sustainability Goals Page.
        SustainabilityGoals.OpenView();
        SustainabilityGoals.Filter.SetFilter("Current Period Filter", Format(Today + 1));
        SustainabilityGoals.GoToRecord(SustainabilityGoal[2]);
        SustainabilityGoals."Current Value for CH4".AssertEquals(EmissionCH4[2]);
        SustainabilityGoals."Current Value for CO2".AssertEquals(EmissionCO2[2]);
        SustainabilityGoals."Current Value for N2O".AssertEquals(EmissionN2O[2]);
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

        SustainabilityGoal.Validate("Baseline Start Date", Today - 1);
        SustainabilityGoal.Validate("Baseline End Date", Today - 1);
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
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
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

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(20);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

        // [GIVEN] Save Expected CO2e Emission and Carbon Fee.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";
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

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
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
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
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

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(1, 1) * SustainAccountSubcategory."Emission Factor CO2";
        EmissionCH4 := LibraryRandom.RandIntInRange(1, 1) * SustainAccountSubcategory."Emission Factor CH4";
        EmissionN2O := LibraryRandom.RandIntInRange(1, 1) * SustainAccountSubcategory."Emission Factor N2O";

        // [GIVEN] Save Expected CO2e Emission and Carbon Fee.
        ExpectedCO2eEmission := EmissionCH4 * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2 * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2O * EmissionFee[3]."Carbon Equivalent Factor";
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
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
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

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandInt(10);
        EmissionCH4 := LibraryRandom.RandInt(5);
        EmissionN2O := LibraryRandom.RandInt(5);

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

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
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
            EmissionCO2,
            EmissionN2O,
            EmissionCH4,
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

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure TestSustainabilityJournalPostedWithZeroEmissionWhenRenewableEnergyEnabled()
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        NoSeries: Record "No. Series";
        SustainabilityAccount: Record "Sustainability Account";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        SustainabilityJournal: TestPage "Sustainability Journal";
    begin
        // [SCENARIO 541991] Impossible to post an emission records in the Sustainability Ledger Entry with Emissions that are equal to zero even with the flag "Renewable Energy" set to true
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] A Sustainability Journal Batch and update No. Series so Manual No. allowed while posting the Sustainability Journal
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        NoSeries.Get(SustainabilityJnlBatch."No Series");
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);

        // [GIVEN] Create a Sustainability Account that's ready to Post 
        SustainabilityAccount := GetAReadyToPostSustainabilityAccount(
            Enum::"Emission Scope"::"Scope 2",
            Enum::"Calculation Foundation"::"Fuel/Electricity",
            true, false, false, '', false, 0, 0, 0, true);

        // [GIVEN] A Sustainability Journal Line is created and all fields are filled out
        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, 1000);
        SustainabilityJournalLine."Unit of Measure" := 'kg';
        SustainabilityJournalLine.Validate("Fuel/Electricity", 123);
        SustainabilityJournalLine.Modify(true);

        // [WHEN] Post Sustainability Journal without any Error
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal.GoToRecord(SustainabilityJournalLine);
        SustainabilityJournal.Post.Invoke();

        // [THEN] Verify Renewable Energy is true and Emissions are zero on posted Sustainability Ledger Entry
        SustainabilityLedgerEntry.FindFirst();
        SustainAccountSubcategory.Get(SustainabilityAccount.Category, SustainabilityAccount.Subcategory);
        Assert.AreEqual(
            SustainAccountSubcategory."Renewable Energy", SustainabilityLedgerEntry."Renewable Energy",
            StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("Renewable Energy"), SustainAccountSubcategory.TableCaption()));
        Assert.AreEqual(
            SustainAccountSubcategory."Emission Factor CO2", SustainabilityLedgerEntry."Emission Factor CO2",
            StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("Emission Factor CO2"), SustainAccountSubcategory.TableCaption()));
        Assert.AreEqual(
            SustainAccountSubcategory."Emission Factor CH4", SustainabilityLedgerEntry."Emission Factor CH4",
            StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("Emission Factor CH4"), SustainAccountSubcategory.TableCaption()));
        Assert.AreEqual(
            SustainAccountSubcategory."Emission Factor N2O", SustainabilityLedgerEntry."Emission Factor N2O",
            StrSubstNo(InformationTakenToLedgerEntryLbl, SustainabilityLedgerEntry.FieldCaption("Emission Factor N2O"), SustainAccountSubcategory.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityLedgerEntryShouldNotBeCreatedWhenSalesDocumentIsPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 563829] Verify Sustainability Ledger entry should not be created when the sales document is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate CO2e.
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

        // [GIVEN] Update "Unit Price", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify();

        // [WHEN] Post a Sales Document.
        PostedInvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [VERIFY] Verify Sustainability Ledger entry should not be created when the sales document is posted.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedInvoiceNo);
        Assert.RecordCount(SustainabilityLedgerEntry, 0);
    end;

    [Test]
    procedure VerifySustainabilityLedgerEntryShouldBeKnockedOffWhenCancelSalesCreditMemoIsPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability Ledger entry should be Knocked Off when the Cancel Sales Credit Memo is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandInt(100);

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

        // [GIVEN] Update Reason Code in Sales Header.
        UpdateReasonCodeinSalesHeader(SalesHeader);

        // [WHEN] Post a Sales Document.
        PostAndVerifyCancelSalesCreditMemo(SalesHeader);

        // [VERIFY] Verify Sustainability Ledger entry should be Kocked Off when the Cancel Sales Credit Memo is posted.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.CalcSums("CO2e Emission", "Emission CO2", "Emission CH4", "Emission N2O");
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), 0, SustainabilityLedgerEntry.TableCaption()));
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
    procedure VerifySustainabilityLedgerEntryShouldBeKnockedOffWhenCorrectiveSalesCreditMemoIsPosted()
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability Ledger entry should be Kocked Off when the Corrective Sales Credit Memo is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandInt(20);

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

        // [GIVEN] Update Reason Code in Sales Header.
        UpdateReasonCodeinSalesHeader(SalesHeader);

        // [WHEN] Post a Sales Document.
        PostAndVerifyCorrectiveSalesCreditMemo(SalesHeader);

        // [VERIFY] Verify Sustainability Ledger entry should be Kocked Off when the Corrective Sales Credit Memo is posted.
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.CalcSums("CO2e Emission", "Emission CO2", "Emission CH4", "Emission N2O");
        Assert.AreEqual(
            0,
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), 0, SustainabilityLedgerEntry.TableCaption()));
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
    procedure VerifySustainabilityFieldsInSalesShipmentLineAndSalesInvoiceLine()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        PostedSalesInvoiceSubform: TestPage "Posted Sales Invoice Subform";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability Fields in Sales Shipment Line and Sales Invoice Line.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandInt(20);

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
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify();

        // [WHEN] Post a Sales Document.
        PostedInvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [VERIFY] Verify Sustainability Fields In Sales Receipt Line and Sales Invoice Line.
        PostedSalesInvoiceSubform.OpenEdit();
        PostedSalesInvoiceSubform.FILTER.SetFilter("Document No.", PostedInvoiceNo);
        PostedSalesInvoiceSubform."Total CO2e".AssertEquals(TotalCO2e);
        PostedSalesInvoiceSubform."Sust. Account No.".AssertEquals(AccountCode);

        SalesShipmentLine.SetRange("Sell-to Customer No.", SalesLine."Sell-to Customer No.");
        SalesShipmentLine.FindFirst();
        Assert.AreEqual(
            AccountCode,
            SalesShipmentLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, SalesShipmentLine.FieldCaption("Sust. Account No."), AccountCode, SalesShipmentLine.TableCaption()));
        Assert.AreEqual(
            TotalCO2e,
            SalesShipmentLine."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, SalesShipmentLine.FieldCaption("Total CO2e"), TotalCO2e, SalesShipmentLine.TableCaption()));
    end;

    [Test]
    procedure VerifyPostedTotalCO2eInSalesLine()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537481] Verify "Posted Total CO2e" field in the Sales line.
        LibrarySustainability.CleanUpBeforeTesting();

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
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(5, 5));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", LibraryRandom.RandInt(20));
        SalesLine.Modify();

        // [GIVEN] Save Expected "Total CO2e".
        TotalCO2e := SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5) * -1;

        // [WHEN] Post a Sales Document.
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [VERIFY] Verify "Posted Total CO2e" in the Sales line.
        SalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        Assert.AreEqual(
            TotalCO2e,
            SalesLine."Posted Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, SalesLine.FieldCaption("Posted Total CO2e"), TotalCO2e, SalesLine.TableCaption()));
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

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandInt(20);

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

        // [GIVEN] Post a Sales Document.
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);
        LibraryVariableStorage.Enqueue(SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5) * -1);

        // [VERIFY] Verify Sustainability fields in Page "Sales Order Statistics" after partially posting of Sales order.
        OpenSalesOrderStatistics(SalesHeader."No.");
        LibraryVariableStorage.Clear();
    end;

    [Obsolete('The statistics action will be replaced with the SalesStatistics action. The new action uses RunObject and does not run the action trigger.', '26.0')]
    [Test]
    [HandlerFunctions('SalesInvoiceStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInSalesInvoiceStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability Fields in Sales Invoice Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Invoice, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Unit Price", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify();

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);
        LibraryVariableStorage.Enqueue(0);

        // [VERIFY] Verify Sustainability fields in Page "Sales Invoice Statistics" before posting of Sales Invoice.
        OpenSalesInvoiceStatistics(SalesHeader."No.");
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

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandInt(20);

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

        // [GIVEN] Post a Sales Document.
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);
        LibraryVariableStorage.Enqueue(SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5) * -1);

        // [VERIFY] Verify Sustainability fields in Page "Sales Order Statistics" after partially posting of Sales order.
        OpenSalesOrderStatisticsNM(SalesHeader."No.");
        LibraryVariableStorage.Clear();
    end;

    [Test]
    [HandlerFunctions('SalesInvoiceSalesStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInSalesInvoiceSalesStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability Fields in Sales Invoice Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Invoice, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Unit Price", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify();

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);
        LibraryVariableStorage.Enqueue(0);

        // [VERIFY] Verify Sustainability fields in Page "Sales Invoice Statistics" before posting of Sales Invoice.
        OpenSalesInvoiceSalesStatistics(SalesHeader."No.");
        LibraryVariableStorage.Clear();
    end;

    [Test]
    procedure VerifySustainabilityFieldsInPostedSalesInvoiceStatistics()
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
        // [SCENARIO 537481] Verify Sustainability Fields in Posted Sales Invoice Statistics.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandInt(20);

        // [GIVEN] Create a Sales Header.
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());

        // [GIVEN] Create a Sales Line.
        LibrarySales.CreateSalesLine(
            SalesLine,
            SalesHeader,
            "Sales Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Unit Price", "Sustainability Account No.", "Total CO2e" in the Sales line.
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify();

        // [GIVEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(-TotalCO2e);

        // [WHEN] Post Sales Document.
        PostedInvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [VERIFY] Verify Sustainability fields in Page "Posted Sales Invoice Statistics".
        VerifyPostedSalesInvoiceStatistics(PostedInvoiceNo);
        LibraryVariableStorage.Clear();
    end;

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the SalesStatistics action. The new action uses RunObject and does not run the action trigger.', '26.0')]
    [Test]
    [HandlerFunctions('SalesInvoiceStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInSalesCrMemoStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        CrMemoNo: Code[20];
        PostedCrMemoNo: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability fields in Posted Sales Cr Memo Statistics.
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
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(5, 5));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", LibraryRandom.RandInt(20));
        SalesLine.Modify();

        // [GIVEN] Save Expected "Total CO2e".
        TotalCO2e := SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);
        LibraryVariableStorage.Enqueue(0);

        // [GIVEN] Update Reason Code in Sales Header.
        UpdateReasonCodeinSalesHeader(SalesHeader);

        // [VERIFY] Verify Sustainability fields in Page "Sales Cr Memo Statistics" before posting of Sales Cr Memo.
        CrMemoNo := CreateCorrectiveCreditMemoAndOpenSalesCrMemoStatistics(SalesHeader);

        // [GIVEN] Post Corrective Credit Memo.
        SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", CrMemoNo);
        PostedCrMemoNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [GIVEN] Clear Variable Storage.
        LibraryVariableStorage.Clear();

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);

        // [VERIFY] Verify Sustainability fields in Page "Posted Sales Cr Memo Statistics" after posting of Sales Cr Memo.
        VerifyPostedSalesCrMemoStatistics(PostedCrMemoNo);
        LibraryVariableStorage.Clear();
    end;
#endif
    [Test]
    [HandlerFunctions('SalesInvoiceSalesStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInSalesCrMemoSalesStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        CrMemoNo: Code[20];
        PostedCrMemoNo: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability fields in Posted Sales Cr Memo Statistics.
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
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(5, 5));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", LibraryRandom.RandInt(20));
        SalesLine.Modify();

        // [GIVEN] Save Expected "Total CO2e".
        TotalCO2e := SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);
        LibraryVariableStorage.Enqueue(0);

        // [GIVEN] Update Reason Code in Sales Header.
        UpdateReasonCodeinSalesHeader(SalesHeader);

        // [VERIFY] Verify Sustainability fields in Page "Sales Cr Memo Statistics" before posting of Sales Cr Memo.
        CrMemoNo := CreateCorrectiveCreditMemoAndOpenSalesCrMemoSalesStatistics(SalesHeader);

        // [GIVEN] Post Corrective Credit Memo.
        SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", CrMemoNo);
        PostedCrMemoNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [GIVEN] Clear Variable Storage.
        LibraryVariableStorage.Clear();

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);

        // [VERIFY] Verify Sustainability fields in Page "Posted Sales Cr Memo Statistics" after posting of Sales Cr Memo.
        VerifyPostedSalesCrMemoStatistics(PostedCrMemoNo);
        LibraryVariableStorage.Clear();
    end;

    [Test]
    [HandlerFunctions('GLPostingPreviewHandlerForSales')]
    procedure VerifySustainabilityLedgerEntryShouldNotBeCreatedDuringPreviewPostingOfSalesOrder()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability Ledger Entry should not be created during Preview Posting of Sales order.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandInt(20);

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
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
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
    procedure VerifySustainabilityLedgerEntryShouldNotBeShownWhenNavigatingPostedSalesInvoice()
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
        // [SCENARIO 537481] Verify Sustainability Ledger Entry should not be shown when navigating Posted Sales Invoice through NavigateFindEntriesHandler handler.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "Total CO2e".
        TotalCO2e := LibraryRandom.RandInt(20);

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
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", TotalCO2e);
        SalesLine.Modify();

        // [WHEN] Post a Sales Document.
        PostedPurchInvNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [VERIFY] Verify Sustainability Ledger Entry should not be shown when navigating Posted Sales Invoice through NavigateFindEntriesHandler handler.
        SalesInvoiceHeader.Get(PostedPurchInvNo);
        SalesInvoiceHeader.Navigate();
    end;

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the SalesStatistics action. The new action uses RunObject and does not run the action trigger.', '26.0')]
    [Test]
    [HandlerFunctions('SalesInvoiceStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInSalesCrMemoSubFormPage()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoSubformPage: TestPage "Sales Cr. Memo Subform";
        PostedSalesCrMemoSubformPage: TestPage "Posted Sales Cr. Memo Subform";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        CrMemoNo: Code[20];
        PostedCrMemoNo: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability fields in Sales Cr Memo SubForm Page.
        LibrarySustainability.CleanUpBeforeTesting();

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
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(5, 5));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", LibraryRandom.RandInt(20));
        SalesLine.Modify();

        // [GIVEN] Save Expected "Total CO2e".
        TotalCO2e := SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);
        LibraryVariableStorage.Enqueue(0);

        // [GIVEN] Update Reason Code in Sales Header.
        UpdateReasonCodeinSalesHeader(SalesHeader);

        // [WHEN] Create Corrective Credit Memo.
        CrMemoNo := CreateCorrectiveCreditMemoAndOpenSalesCrMemoStatistics(SalesHeader);

        // [VERIFY] Verify Sustainability fields before posting of Corrective Credit Memo.
        SalesCrMemoSubformPage.OpenEdit();
        SalesCrMemoSubformPage.Filter.SetFilter("Document No.", CrMemoNo);
        SalesCrMemoSubformPage.Filter.SetFilter("No.", SalesLine."No.");
        SalesCrMemoSubformPage."Sust. Account No.".AssertEquals(AccountCode);
        SalesCrMemoSubformPage."Total CO2e".AssertEquals(TotalCO2e);

        // [GIVEN] Post Corrective Credit Memo.
        SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", CrMemoNo);
        PostedCrMemoNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [GIVEN] Clear Variable Storage.
        LibraryVariableStorage.Clear();

        // [VERIFY] Verify Sustainability fields After posting of Corrective Credit Memo.
        PostedSalesCrMemoSubformPage.OpenEdit();
        PostedSalesCrMemoSubformPage.Filter.SetFilter("Document No.", PostedCrMemoNo);
        PostedSalesCrMemoSubformPage.Filter.SetFilter("No.", SalesLine."No.");
        PostedSalesCrMemoSubformPage."Sust. Account No.".AssertEquals(AccountCode);
        PostedSalesCrMemoSubformPage."Total CO2e".AssertEquals(TotalCO2e);
    end;
#endif
    [Test]
    [HandlerFunctions('SalesInvoiceSalesStatisticsPageHandler')]
    procedure VerifySustainabilityFieldsInSalesCrMemoSubFormPageSalesStatistics()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoSubformPage: TestPage "Sales Cr. Memo Subform";
        PostedSalesCrMemoSubformPage: TestPage "Posted Sales Cr. Memo Subform";
        TotalCO2e: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
        CrMemoNo: Code[20];
        PostedCrMemoNo: Code[20];
    begin
        // [SCENARIO 537481] Verify Sustainability fields in Sales Cr Memo SubForm Page.
        LibrarySustainability.CleanUpBeforeTesting();

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
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 200));
        SalesLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(5, 5));
        SalesLine.Validate("Sust. Account No.", AccountCode);
        SalesLine.Validate("Total CO2e", LibraryRandom.RandInt(20));
        SalesLine.Modify();

        // [GIVEN] Save Expected "Total CO2e".
        TotalCO2e := SalesLine."CO2e per Unit" * SalesLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(TotalCO2e);
        LibraryVariableStorage.Enqueue(0);

        // [GIVEN] Update Reason Code in Sales Header.
        UpdateReasonCodeinSalesHeader(SalesHeader);

        // [WHEN] Create Corrective Credit Memo.
        CrMemoNo := CreateCorrectiveCreditMemoAndOpenSalesCrMemoSalesStatistics(SalesHeader);

        // [VERIFY] Verify Sustainability fields before posting of Corrective Credit Memo.
        SalesCrMemoSubformPage.OpenEdit();
        SalesCrMemoSubformPage.Filter.SetFilter("Document No.", CrMemoNo);
        SalesCrMemoSubformPage.Filter.SetFilter("No.", SalesLine."No.");
        SalesCrMemoSubformPage."Sust. Account No.".AssertEquals(AccountCode);
        SalesCrMemoSubformPage."Total CO2e".AssertEquals(TotalCO2e);

        // [GIVEN] Post Corrective Credit Memo.
        SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", CrMemoNo);
        PostedCrMemoNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [GIVEN] Clear Variable Storage.
        LibraryVariableStorage.Clear();

        // [VERIFY] Verify Sustainability fields After posting of Corrective Credit Memo.
        PostedSalesCrMemoSubformPage.OpenEdit();
        PostedSalesCrMemoSubformPage.Filter.SetFilter("Document No.", PostedCrMemoNo);
        PostedSalesCrMemoSubformPage.Filter.SetFilter("No.", SalesLine."No.");
        PostedSalesCrMemoSubformPage."Sust. Account No.".AssertEquals(AccountCode);
        PostedSalesCrMemoSubformPage."Total CO2e".AssertEquals(TotalCO2e);
    end;

    [Test]
    procedure VerifySustainabilityFieldsShouldBeUpdatedFromItemInAssemblyDocument()
    var
        CompItem: Record Item;
        ParentItem: Record Item;
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        SustainabilityAccount: Record "Sustainability Account";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        Quantity: Decimal;
        AccountCode: array[2] of Code[20];
        CO2ePerUnit: array[2] of Decimal;
    begin
        // [SCENARIO 537480] Verify Sustainability fields should be updated from Item When "Item No." and Quantity is validated in Assembly Header and Line.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode[1], CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode[1]);

        // [GIVEN] Generate Random "CO2e Per Unit" and Quantity.
        CO2ePerUnit[1] := LibraryRandom.RandIntInRange(10, 10);
        CO2ePerUnit[2] := LibraryRandom.RandIntInRange(20, 20);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Assembly Item.
        CreateAssembledItem(ParentItem, "Assembly Policy"::"Assemble-to-Order", 1, 1);
        ParentItem.Validate("Default Sust. Account", AccountCode[1]);
        ParentItem.Modify();

        // [GIVEN] Create Sustainability Account and update Sustainability Account No., "CO2e per unit" in Component item.
        CreateAndUpdateSustAccOnCompItem(ParentItem, CompItem, AccountCode[2], CO2ePerUnit[2]);

        // [WHEN] Create Assembly Document.
        LibraryAssembly.CreateAssemblyHeader(AssemblyHeader, WorkDate() + 1, ParentItem."No.", '', Quantity, '');
        AssemblyHeader.Validate("Location Code", '');
        AssemblyHeader.Modify();

        // [THEN] Verify "Sust. Account No.","CO2e per Unit","Total CO2e" in Assembly Header and Assembly Line.
        GetAssemblyLine(AssemblyHeader, AssemblyLine);
        Assert.AreEqual(
            AccountCode[1],
            AssemblyHeader."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, AssemblyHeader.FieldCaption("Sust. Account No."), AccountCode[1], AssemblyHeader.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit[2],
            AssemblyHeader."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, AssemblyHeader.FieldCaption("CO2e per Unit"), CO2ePerUnit[2], AssemblyHeader.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit[2] * Quantity,
            AssemblyHeader."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, AssemblyHeader.FieldCaption("Total CO2e"), CO2ePerUnit[2] * Quantity, AssemblyHeader.TableCaption()));
        Assert.AreEqual(
            AccountCode[2],
            AssemblyLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, AssemblyLine.FieldCaption("Sust. Account No."), AccountCode[2], AssemblyLine.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit[2],
            AssemblyLine."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, AssemblyLine.FieldCaption("CO2e per Unit"), CO2ePerUnit[2], AssemblyLine.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit[2] * Quantity,
            AssemblyLine."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, AssemblyLine.FieldCaption("Total CO2e"), CO2ePerUnit[2] * Quantity, AssemblyLine.TableCaption()));
        NotificationLifecycleMgt.RecallAllNotifications();
    end;

    [Test]
    procedure VerifySustainabilityFieldsShouldBeUpdatedWhenDocumentIsPosted()
    var
        CompItem: Record Item;
        ParentItem: Record Item;
        AssemblyHeader: Record "Assembly Header";
        PostedAssemblyHeader: Record "Posted Assembly Header";
        PostedAssemblyLine: Record "Posted Assembly Line";
        SustainabilityAccount: Record "Sustainability Account";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        Quantity: Decimal;
        AccountCode: array[2] of Code[20];
        CO2ePerUnit: array[2] of Decimal;
    begin
        // [SCENARIO 537480] Verify Sustainability fields should be updated When Document is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode[1], CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode[1]);

        // [GIVEN] Generate Random "CO2e Per Unit" and Quantity.
        CO2ePerUnit[1] := LibraryRandom.RandIntInRange(10, 10);
        CO2ePerUnit[2] := LibraryRandom.RandIntInRange(20, 20);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Assembly Item.
        CreateAssembledItem(ParentItem, "Assembly Policy"::"Assemble-to-Order", 1, 1);
        ParentItem.Validate("Default Sust. Account", AccountCode[1]);
        ParentItem.Validate("CO2e per Unit", CO2ePerUnit[1]);
        ParentItem.Modify();

        // [GIVEN] Create Sustainability Account and update Sustainability Account No., "CO2e per unit" in Component item.
        CreateAndUpdateSustAccOnCompItem(ParentItem, CompItem, AccountCode[2], CO2ePerUnit[2]);

        // [GIVEN] Increase Inventory of an Item.
        AddItemToInventory(CompItem, LibraryRandom.RandInt(1000));

        // [GIVEN] Create Assembly Document.
        LibraryAssembly.CreateAssemblyHeader(AssemblyHeader, WorkDate() + 1, ParentItem."No.", '', Quantity, '');

        // [WHEN] Post Assembly Document.
        LibraryAssembly.PostAssemblyHeader(AssemblyHeader, '');

        // [THEN] Verify "Sust. Account No.","CO2e per Unit","Total CO2e" in Posted Assembly Header and Posted Assembly Line.
        GetPostedAssemblyHeader(PostedAssemblyHeader, ParentItem."No.");
        GetPostedAssemblyLine(PostedAssemblyHeader, PostedAssemblyLine);
        Assert.AreEqual(
            AccountCode[1],
            PostedAssemblyHeader."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, PostedAssemblyHeader.FieldCaption("Sust. Account No."), AccountCode[1], PostedAssemblyHeader.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit[2],
            PostedAssemblyHeader."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, PostedAssemblyHeader.FieldCaption("CO2e per Unit"), CO2ePerUnit[2], PostedAssemblyHeader.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit[2] * Quantity,
            PostedAssemblyHeader."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, PostedAssemblyHeader.FieldCaption("Total CO2e"), CO2ePerUnit[2] * Quantity, PostedAssemblyHeader.TableCaption()));
        Assert.AreEqual(
            AccountCode[2],
            PostedAssemblyLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, PostedAssemblyLine.FieldCaption("Sust. Account No."), AccountCode[2], PostedAssemblyLine.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit[2],
            PostedAssemblyLine."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, PostedAssemblyLine.FieldCaption("CO2e per Unit"), CO2ePerUnit[2], PostedAssemblyLine.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit[2] * Quantity,
            PostedAssemblyLine."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, PostedAssemblyLine.FieldCaption("Total CO2e"), CO2ePerUnit[2] * Quantity, PostedAssemblyLine.TableCaption()));
        NotificationLifecycleMgt.RecallAllNotifications();
    end;

    [Test]
    procedure VerifySustainabilityFieldsShouldBeUpdatedWhenDocumentIsPartiallyPosted()
    var
        CompItem: Record Item;
        ParentItem: Record Item;
        AssemblyHeader: Record "Assembly Header";
        PostedAssemblyHeader: Record "Posted Assembly Header";
        PostedAssemblyLine: Record "Posted Assembly Line";
        SustainabilityAccount: Record "Sustainability Account";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        Quantity: Decimal;
        AccountCode: array[2] of Code[20];
        CO2ePerUnit: array[2] of Decimal;
    begin
        // [SCENARIO 537480] Verify Sustainability fields should be updated When Document is partially posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode[1], CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode[1]);

        // [GIVEN] Generate Random "CO2e Per Unit" and Quantity.
        CO2ePerUnit[1] := LibraryRandom.RandIntInRange(10, 10);
        CO2ePerUnit[2] := LibraryRandom.RandIntInRange(20, 20);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Assembly Item.
        CreateAssembledItem(ParentItem, "Assembly Policy"::"Assemble-to-Order", 1, 1);
        ParentItem.Validate("Default Sust. Account", AccountCode[1]);
        ParentItem.Validate("CO2e per Unit", CO2ePerUnit[1]);
        ParentItem.Modify();

        // [GIVEN] Create Sustainability Account and update Sustainability Account No., "CO2e per unit" in Component item.
        CreateAndUpdateSustAccOnCompItem(ParentItem, CompItem, AccountCode[2], CO2ePerUnit[2]);

        // [GIVEN] Increase Inventory of an Item.
        AddItemToInventory(CompItem, LibraryRandom.RandInt(1000));

        // [GIVEN] Create Assembly Document.
        LibraryAssembly.CreateAssemblyHeader(AssemblyHeader, WorkDate() + 1, ParentItem."No.", '', Quantity, '');
        AssemblyHeader.Validate("Quantity to Assemble", LibraryRandom.RandIntInRange(5, 5));
        AssemblyHeader.Modify();

        // [WHEN] Post Assembly Document.
        LibraryAssembly.PostAssemblyHeader(AssemblyHeader, '');

        // [THEN] Verify "Sust. Account No.","CO2e per Unit","Total CO2e" in Posted Assembly Header and Posted Assembly Line.
        GetPostedAssemblyHeader(PostedAssemblyHeader, ParentItem."No.");
        GetPostedAssemblyLine(PostedAssemblyHeader, PostedAssemblyLine);
        Assert.AreEqual(
            AccountCode[1],
            PostedAssemblyHeader."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, PostedAssemblyHeader.FieldCaption("Sust. Account No."), AccountCode[1], PostedAssemblyHeader.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit[2],
            PostedAssemblyHeader."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, PostedAssemblyHeader.FieldCaption("CO2e per Unit"), CO2ePerUnit[2], PostedAssemblyHeader.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit[2] * LibraryRandom.RandIntInRange(5, 5),
            PostedAssemblyHeader."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, PostedAssemblyHeader.FieldCaption("Total CO2e"), CO2ePerUnit[2] * LibraryRandom.RandIntInRange(5, 5), PostedAssemblyHeader.TableCaption()));
        Assert.AreEqual(
            AccountCode[2],
            PostedAssemblyLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, PostedAssemblyLine.FieldCaption("Sust. Account No."), AccountCode[2], PostedAssemblyLine.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit[2],
            PostedAssemblyLine."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, PostedAssemblyLine.FieldCaption("CO2e per Unit"), CO2ePerUnit[2], PostedAssemblyLine.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit[2] * LibraryRandom.RandIntInRange(5, 5),
            PostedAssemblyLine."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, PostedAssemblyLine.FieldCaption("Total CO2e"), CO2ePerUnit[2] * LibraryRandom.RandIntInRange(5, 5), PostedAssemblyLine.TableCaption()));
        NotificationLifecycleMgt.RecallAllNotifications();
    end;

    [Test]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenDocumentIsPosted()
    var
        CompItem: Record Item;
        ParentItem: Record Item;
        AssemblyHeader: Record "Assembly Header";
        PostedAssemblyHeader: Record "Posted Assembly Header";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        Quantity: Decimal;
        AccountCode: array[2] of Code[20];
        CO2ePerUnit: array[2] of Decimal;
    begin
        // [SCENARIO 537480] Verify Sustainability Value Entry should be created When Document is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode[1], CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode[1]);

        // [GIVEN] Generate Random "CO2e Per Unit" and Quantity.
        CO2ePerUnit[1] := LibraryRandom.RandIntInRange(10, 10);
        CO2ePerUnit[2] := LibraryRandom.RandIntInRange(20, 20);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Assembly Item.
        CreateAssembledItem(ParentItem, "Assembly Policy"::"Assemble-to-Order", 1, 1);
        ParentItem.Validate("Default Sust. Account", AccountCode[1]);
        ParentItem.Validate("CO2e per Unit", CO2ePerUnit[1]);
        ParentItem.Modify();

        // [GIVEN] Create Sustainability Account and update Sustainability Account No., "CO2e per unit" in Component item.
        CreateAndUpdateSustAccOnCompItem(ParentItem, CompItem, AccountCode[2], CO2ePerUnit[2]);

        // [GIVEN] Increase Inventory of an Item.
        AddItemToInventory(CompItem, LibraryRandom.RandInt(1000));

        // [GIVEN] Create Assembly Document.
        LibraryAssembly.CreateAssemblyHeader(AssemblyHeader, WorkDate() + 1, ParentItem."No.", '', Quantity, '');

        // [WHEN] Post Assembly Document.
        LibraryAssembly.PostAssemblyHeader(AssemblyHeader, '');

        // [THEN] Verify Sustainability Value Entry When Assembly Document is posted.
        GetPostedAssemblyHeader(PostedAssemblyHeader, ParentItem."No.");
        SustainabilityLedgerEntry.SetRange("Document No.", PostedAssemblyHeader."No.");
        Assert.RecordCount(SustainabilityLedgerEntry, 0);

        SustainabilityValueEntry.SetRange("Document No.", PostedAssemblyHeader."No.");
        Assert.RecordCount(SustainabilityValueEntry, 2);
        VerifySustainabilityValueEntry(ParentItem."No.", 0, CO2ePerUnit[2] * Quantity);
        VerifySustainabilityValueEntry(CompItem."No.", 0, -CO2ePerUnit[2] * Quantity);

        NotificationLifecycleMgt.RecallAllNotifications();
    end;

    [Test]
    procedure VerifySustainabilityValueEntryShouldBeCreatedWhenDocumentIsPartiallyPosted()
    var
        CompItem: Record Item;
        ParentItem: Record Item;
        AssemblyHeader: Record "Assembly Header";
        PostedAssemblyHeader: Record "Posted Assembly Header";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        Quantity: Decimal;
        AccountCode: array[2] of Code[20];
        CO2ePerUnit: array[2] of Decimal;
    begin
        // [SCENARIO 537480] Verify Sustainability Value Entry should be created When Document is partially posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode[1], CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode[1]);

        // [GIVEN] Generate Random "CO2e Per Unit" and Quantity.
        CO2ePerUnit[1] := LibraryRandom.RandIntInRange(10, 10);
        CO2ePerUnit[2] := LibraryRandom.RandIntInRange(20, 20);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Assembly Item.
        CreateAssembledItem(ParentItem, "Assembly Policy"::"Assemble-to-Order", 1, 1);
        ParentItem.Validate("Default Sust. Account", AccountCode[1]);
        ParentItem.Validate("CO2e per Unit", CO2ePerUnit[1]);
        ParentItem.Modify();

        // [GIVEN] Create Sustainability Account and update Sustainability Account No., "CO2e per unit" in Component item.
        CreateAndUpdateSustAccOnCompItem(ParentItem, CompItem, AccountCode[2], CO2ePerUnit[2]);

        // [GIVEN] Increase Inventory of an Item.
        AddItemToInventory(CompItem, LibraryRandom.RandInt(1000));

        // [GIVEN] Create Assembly Document.
        LibraryAssembly.CreateAssemblyHeader(AssemblyHeader, WorkDate() + 1, ParentItem."No.", '', Quantity, '');
        AssemblyHeader.Validate("Quantity to Assemble", LibraryRandom.RandIntInRange(5, 5));
        AssemblyHeader.Modify();

        // [WHEN] Post Assembly Document.
        LibraryAssembly.PostAssemblyHeader(AssemblyHeader, '');

        // [THEN] Verify Sustainability Value When Assembly Document is partially posted.
        GetPostedAssemblyHeader(PostedAssemblyHeader, ParentItem."No.");
        SustainabilityLedgerEntry.SetRange("Document No.", PostedAssemblyHeader."No.");
        Assert.RecordCount(SustainabilityLedgerEntry, 0);

        SustainabilityValueEntry.SetRange("Document No.", PostedAssemblyHeader."No.");
        Assert.RecordCount(SustainabilityValueEntry, 2);
        VerifySustainabilityValueEntry(ParentItem."No.", 0, CO2ePerUnit[2] * LibraryRandom.RandIntInRange(5, 5));
        VerifySustainabilityValueEntry(CompItem."No.", 0, -CO2ePerUnit[2] * LibraryRandom.RandIntInRange(5, 5));

        NotificationLifecycleMgt.RecallAllNotifications();
    end;

    [Test]
    [HandlerFunctions('GLPostingPreviewHandlerForAssemblyOrder')]
    procedure VerifySustainabilityValueEntryShouldBeCreatedDuringPreviewPostingOfAssemblyOrder()
    var
        CompItem: Record Item;
        ParentItem: Record Item;
        AssemblyHeader: Record "Assembly Header";
        SustainabilityAccount: Record "Sustainability Account";
        AssemblyPostYesNo: Codeunit "Assembly-Post (Yes/No)";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        Quantity: Decimal;
        AccountCode: array[2] of Code[20];
        CO2ePerUnit: array[2] of Decimal;
    begin
        // [SCENARIO 537480] Verify Sustainability Value Entry should be created during preview posting of Assembly Order.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode[1], CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode[1]);

        // [GIVEN] Generate Random "CO2e Per Unit" and Quantity.
        CO2ePerUnit[1] := LibraryRandom.RandIntInRange(10, 10);
        CO2ePerUnit[2] := LibraryRandom.RandIntInRange(20, 20);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Assembly Item.
        CreateAssembledItem(ParentItem, "Assembly Policy"::"Assemble-to-Order", 1, 1);
        ParentItem.Validate("Default Sust. Account", AccountCode[1]);
        ParentItem.Validate("CO2e per Unit", CO2ePerUnit[1]);
        ParentItem.Modify();

        // [GIVEN] Create Sustainability Account and update Sustainability Account No., "CO2e per unit" in Component item.
        CreateAndUpdateSustAccOnCompItem(ParentItem, CompItem, AccountCode[2], CO2ePerUnit[2]);

        // [GIVEN] Increase Inventory of an Item.
        AddItemToInventory(CompItem, LibraryRandom.RandInt(1000));

        // [GIVEN] Create Assembly Document.
        LibraryAssembly.CreateAssemblyHeader(AssemblyHeader, WorkDate() + 1, ParentItem."No.", '', Quantity, '');

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Preview Assembly Document.
        asserterror AssemblyPostYesNo.Preview(AssemblyHeader);

        // [VERIFY] No errors occurred - preview mode error only.
        Assert.ExpectedError('');
        NotificationLifecycleMgt.RecallAllNotifications();
    end;

    [Test]
    [HandlerFunctions('NavigateFindEntriesHandlerForAssemblyOrder')]
    procedure VerifySustainabilityValueEntryShouldBeShownWhenNavigatingPostedAssemblyOrder()
    var
        CompItem: Record Item;
        ParentItem: Record Item;
        AssemblyHeader: Record "Assembly Header";
        PostedAssemblyHeader: Record "Posted Assembly Header";
        SustainabilityAccount: Record "Sustainability Account";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        Quantity: Decimal;
        AccountCode: array[2] of Code[20];
        CO2ePerUnit: array[2] of Decimal;
    begin
        // [SCENARIO 537480] Verify Sustainability Value Entry should be shown when navigating Posted Assembly Order through NavigateFindEntriesHandler handler.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode[1], CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode[1]);

        // [GIVEN] Generate Random "CO2e Per Unit" and Quantity.
        CO2ePerUnit[1] := LibraryRandom.RandIntInRange(10, 10);
        CO2ePerUnit[2] := LibraryRandom.RandIntInRange(20, 20);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create a Assembly Item.
        CreateAssembledItem(ParentItem, "Assembly Policy"::"Assemble-to-Order", 1, 1);
        ParentItem.Validate("Default Sust. Account", AccountCode[1]);
        ParentItem.Validate("CO2e per Unit", CO2ePerUnit[1]);
        ParentItem.Modify();

        // [GIVEN] Create Sustainability Account and update Sustainability Account No., "CO2e per unit" in Component item.
        CreateAndUpdateSustAccOnCompItem(ParentItem, CompItem, AccountCode[2], CO2ePerUnit[2]);

        // [GIVEN] Increase Inventory of an Item.
        AddItemToInventory(CompItem, LibraryRandom.RandInt(1000));

        // [GIVEN] Create Assembly Document.
        LibraryAssembly.CreateAssemblyHeader(AssemblyHeader, WorkDate() + 1, ParentItem."No.", '', Quantity, '');

        // [WHEN] Post Assembly Document.
        LibraryAssembly.PostAssemblyHeader(AssemblyHeader, '');

        // [VERIFY] Verify Sustainability Value Entry should be shown when navigating Posted Sales Invoice through NavigateFindEntriesHandler handler.
        GetPostedAssemblyHeader(PostedAssemblyHeader, ParentItem."No.");
        PostedAssemblyHeader.Navigate();

        NotificationLifecycleMgt.RecallAllNotifications();
    end;

    [Test]
    procedure VerifySustainabilityFieldsShouldNotBeUpdatedFromItemInTransferLine()
    var
        SustainabilityAccount: Record "Sustainability Account";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        FromLocation: Record Location;
        ToLocation: Record Location;
        InTransitLocation: Record Location;
        Item: Record Item;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 563480] Verify Sustainability fields should not be updated from Item When "Item No." in Transfer Line.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per unit" and Quantity.
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 100);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create FromLocation, ToLocation and Intransit Location that will be used to create Transfer Order.
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);

        // [GIVEN] Create Item with Inventory.
        CreateItemWithInventory(Item, FromLocation.Code);

        // [GIVEN] Update "Default Sust. Account", "CO2e per Unit" in an Item.
        Item.Get(Item."No.");
        Item.Validate("Default Sust. Account", AccountCode);
        Item.Validate("CO2e per Unit", CO2ePerUnit);
        Item.Modify();

        // [WHEN] Create Transfer Order.
        LibraryWarehouse.CreateTransferHeader(TransferHeader, FromLocation.Code, ToLocation.Code, InTransitLocation.Code);
        LibraryWarehouse.CreateTransferLine(TransferHeader, TransferLine, Item."No.", Quantity);

        // [VERIFY] Verify Sustainability fields should not be updated from Item When "Item No." in Transfer Line.
        GetTransferLine(TransferHeader, TransferLine);
        Assert.AreEqual(
            AccountCode,
            TransferLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, TransferLine.FieldCaption("Sust. Account No."), AccountCode, TransferLine.TableCaption()));
        Assert.AreEqual(
            0,
            TransferLine."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, TransferLine.FieldCaption("CO2e per Unit"), CO2ePerUnit, TransferLine.TableCaption()));
        Assert.AreEqual(
            0,
            TransferLine."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, TransferLine.FieldCaption("Total CO2e"), CO2ePerUnit * Quantity, TransferLine.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityFieldsShouldBeUpdatedInTransferShipmentLine()
    var
        AccountingPeriod: Record "Accounting Period";
        SustainabilityAccount: Record "Sustainability Account";
        TransferShipmentLine: Record "Transfer Shipment Line";
        TransferHeader: Record "Transfer Header";
        FromLocation: Record Location;
        ToLocation: Record Location;
        InTransitLocation: Record Location;
        Item: Record Item;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537480] Verify Sustainability fields should be updated in "Transfer Shipment Line".
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Find Accounting Period.
        FindAccountingPeriod(AccountingPeriod);

        // [GIVEN] Change WorkDate.
        WorkDate(AccountingPeriod."Starting Date");

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per unit" and Quantity.
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 100);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create FromLocation, ToLocation and Intransit Location that will be used to create Transfer Order.
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);

        // [GIVEN] Create Item with Inventory.
        CreateItemWithInventory(Item, FromLocation.Code);

        // [GIVEN] Update "Default Sust. Account", "CO2e per Unit" in an Item.
        Item.Get(Item."No.");
        Item.Validate("Default Sust. Account", AccountCode);
        Item.Validate("CO2e per Unit", CO2ePerUnit);
        Item.Modify();

        // [GIVEN] Create Transfer Order.
        CreateTransferOrderWithLocation(TransferHeader, Item, FromLocation.Code, ToLocation.Code, InTransitLocation.Code, Quantity, CO2ePerUnit);

        // [WHEN] Post Transfer Order.
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, true);

        // [VERIFY] Verify Sustainability fields should be updated in "Transfer Shipment Line" and "Transfer Receipt Line".
        GetTransferShipmentLine(TransferShipmentLine, Item."No.");
        Assert.AreEqual(
            AccountCode,
            TransferShipmentLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, TransferShipmentLine.FieldCaption("Sust. Account No."), AccountCode, TransferShipmentLine.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit,
            TransferShipmentLine."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, TransferShipmentLine.FieldCaption("CO2e per Unit"), CO2ePerUnit, TransferShipmentLine.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit * Quantity,
            TransferShipmentLine."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, TransferShipmentLine.FieldCaption("Total CO2e"), CO2ePerUnit * Quantity, TransferShipmentLine.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityFieldsShouldBeUpdatedInTransferShipmentLineWhenDocumentIsPartiallyPosted()
    var
        AccountingPeriod: Record "Accounting Period";
        SustainabilityAccount: Record "Sustainability Account";
        TransferShipmentLine: Record "Transfer Shipment Line";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        FromLocation: Record Location;
        ToLocation: Record Location;
        InTransitLocation: Record Location;
        Item: Record Item;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537480] Verify Sustainability fields should be updated in "Transfer Shipment Line" When Transfer Order is partially posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Find Accounting Period.
        FindAccountingPeriod(AccountingPeriod);

        // [GIVEN] Change WorkDate.
        WorkDate(AccountingPeriod."Starting Date");

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per unit" and Quantity.
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 100);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create FromLocation, ToLocation and IntransitLocation that will be used to create Transfer Order.
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);

        // [GIVEN] Create Item with Inventory.
        CreateItemWithInventory(Item, FromLocation.Code);

        // [GIVEN] Update "Default Sust. Account", "CO2e per Unit" in an Item.
        Item.Get(Item."No.");
        Item.Validate("Default Sust. Account", AccountCode);
        Item.Validate("CO2e per Unit", CO2ePerUnit);
        Item.Modify();

        // [GIVEN] Create Transfer Order.
        CreateTransferOrderWithLocation(TransferHeader, Item, FromLocation.Code, ToLocation.Code, InTransitLocation.Code, Quantity, CO2ePerUnit);

        // [GIVEN] Update "Qty. to Ship" in Transfer Line.
        GetTransferLine(TransferHeader, TransferLine);
        TransferLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(5, 5));
        TransferLine.Modify();

        // [WHEN] Post Transfer Order.
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, true);

        // [VERIFY] Verify Sustainability fields should be updated in "Transfer Shipment Line".
        GetTransferShipmentLine(TransferShipmentLine, Item."No.");
        Assert.AreEqual(
            AccountCode,
            TransferShipmentLine."Sust. Account No.",
            StrSubstNo(ValueMustBeEqualErr, TransferShipmentLine.FieldCaption("Sust. Account No."), AccountCode, TransferShipmentLine.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit,
            TransferShipmentLine."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, TransferShipmentLine.FieldCaption("CO2e per Unit"), CO2ePerUnit, TransferShipmentLine.TableCaption()));
        Assert.AreEqual(
            CO2ePerUnit * LibraryRandom.RandIntInRange(5, 5),
            TransferShipmentLine."Total CO2e",
            StrSubstNo(ValueMustBeEqualErr, TransferShipmentLine.FieldCaption("Total CO2e"), CO2ePerUnit * LibraryRandom.RandIntInRange(5, 5), TransferShipmentLine.TableCaption()));
    end;

    [Test]
    procedure VerifySustainabilityValueEntryWhenDocumentIsPartiallyPosted()
    var
        AccountingPeriod: Record "Accounting Period";
        SustainabilityAccount: Record "Sustainability Account";
        TransferShipmentLine: Record "Transfer Shipment Line";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        FromLocation: Record Location;
        ToLocation: Record Location;
        InTransitLocation: Record Location;
        Item: Record Item;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537480] Verify Sustainability Value Entry When Transfer Order is partially posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Find Accounting Period.
        FindAccountingPeriod(AccountingPeriod);

        // [GIVEN] Change WorkDate.
        WorkDate(AccountingPeriod."Starting Date");

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per unit" and Quantity.
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 100);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create FromLocation, ToLocation and Intransit Location that will be used to create Transfer Order.
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);

        // [GIVEN] Create Item with Inventory.
        CreateItemWithInventory(Item, FromLocation.Code);

        // [GIVEN] Update "Default Sust. Account", "CO2e per Unit" in an Item.
        Item.Get(Item."No.");
        Item.Validate("Default Sust. Account", AccountCode);
        Item.Validate("CO2e per Unit", CO2ePerUnit);
        Item.Modify();

        // [GIVEN] Create Transfer Order.
        CreateTransferOrderWithLocation(TransferHeader, Item, FromLocation.Code, ToLocation.Code, InTransitLocation.Code, Quantity, CO2ePerUnit);

        // [GIVEN] Update "Qty. to Ship" in Transfer Line.
        GetTransferLine(TransferHeader, TransferLine);
        TransferLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(5, 5));
        TransferLine.Modify();

        // [WHEN] Post Transfer Order.
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, true);

        // [VERIFY] Verify Sustainability Value Entry for "Transfer Shipment".
        GetTransferShipmentLine(TransferShipmentLine, Item."No.");
        VerifySustainabilityValueEntryForTransferOrder(TransferShipmentLine."Document No.", CO2ePerUnit, CO2ePerUnit * LibraryRandom.RandIntInRange(5, 5));
        VerifySustainabilityLedgerEntryForTransferOrder(TransferShipmentLine."Document No.");
    end;

    [Test]
    [HandlerFunctions('TransferOrderPostOptionsHandler,GLPostingPreviewHandlerForTransferOrder')]
    procedure VerifySustainabilityValueEntryShouldBeCreatedForShipDuringPreviePostingOfTransferOrder()
    var
        AccountingPeriod: Record "Accounting Period";
        SustainabilityAccount: Record "Sustainability Account";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        FromLocation: Record Location;
        ToLocation: Record Location;
        InTransitLocation: Record Location;
        Item: Record Item;
        TransferOrderPostYesNo: Codeunit "TransferOrder-Post (Yes/No)";
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537480] Verify Sustainability Value Entry should be created for ship during preview posting of Transfer Order.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Find Accounting Period.
        FindAccountingPeriod(AccountingPeriod);

        // [GIVEN] Change WorkDate.
        WorkDate(AccountingPeriod."Starting Date");

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per unit" and Quantity.
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 100);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create FromLocation, ToLocation and Intransit Location that will be used to create Transfer Order.
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);

        // [GIVEN] Create Item with Inventory.
        CreateItemWithInventory(Item, FromLocation.Code);

        // [GIVEN] Update "Default Sust. Account", "CO2e per Unit" in an Item.
        Item.Get(Item."No.");
        Item.Validate("Default Sust. Account", AccountCode);
        Item.Validate("CO2e per Unit", CO2ePerUnit);
        Item.Modify();

        // [GIVEN] Create Transfer Order.
        CreateTransferOrderWithLocation(TransferHeader, Item, FromLocation.Code, ToLocation.Code, InTransitLocation.Code, Quantity, CO2ePerUnit);

        // [GIVEN] Update "Qty. to Ship" in Transfer Line.
        GetTransferLine(TransferHeader, TransferLine);
        TransferLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(5, 5));
        TransferLine.Modify();

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Preview Transfer Order for Ship.
        LibraryVariableStorage.Enqueue(1); // Choice 1 is ship
        asserterror TransferOrderPostYesNo.Preview(TransferHeader);

        // [VERIFY] No errors occurred - preview mode error only.
        Assert.ExpectedError('');
    end;

    [Test]
    [HandlerFunctions('NavigateFindEntriesHandlerForTransferOrder')]
    procedure VerifySustainabilityValueEntryShouldBeShownWhenNavigatingTransferShipment()
    var
        AccountingPeriod: Record "Accounting Period";
        SustainabilityAccount: Record "Sustainability Account";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        FromLocation: Record Location;
        ToLocation: Record Location;
        InTransitLocation: Record Location;
        Item: Record Item;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 537480] Verify Sustainability Value Entry should be shown when navigating Transfer Shipment through NavigateFindEntriesHandler handler.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Find Accounting Period.
        FindAccountingPeriod(AccountingPeriod);

        // [GIVEN] Change WorkDate.
        WorkDate(AccountingPeriod."Starting Date");

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per unit" and Quantity.
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 100);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create FromLocation, ToLocation and Intransit Location that will be used to create Transfer Order.
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);

        // [GIVEN] Create Item with Inventory.
        CreateItemWithInventory(Item, FromLocation.Code);

        // [GIVEN] Update "Default Sust. Account", "CO2e per Unit" in an Item.
        Item.Get(Item."No.");
        Item.Validate("Default Sust. Account", AccountCode);
        Item.Validate("CO2e per Unit", CO2ePerUnit);
        Item.Modify();

        // [GIVEN] Create Transfer Order.
        CreateTransferOrderWithLocation(TransferHeader, Item, FromLocation.Code, ToLocation.Code, InTransitLocation.Code, Quantity, CO2ePerUnit);

        // [GIVEN] Update "Qty. to Ship" in Transfer Line.
        GetTransferLine(TransferHeader, TransferLine);
        TransferLine.Validate("Qty. to Ship", LibraryRandom.RandIntInRange(5, 5));
        TransferLine.Modify();

        // [WHEN] Post Transfer Order.
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, false);

        // [VERIFY] Verify Sustainability Value and Ledger Entry should be shown when navigating Transfer Shipment Header through NavigateFindEntriesHandler handler.
        GetTransferShipmentHeader(TransferShipmentHeader, FromLocation.Code);
        TransferShipmentHeader.Navigate();
    end;

    [Test]
    procedure VerifySustainabilityEntriesIfEnableValueChainTrackingIsFalseWhenPostPurchaseOrder()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        AccountCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        CategoryCode: Code[20];
        PostedInvoiceNo: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 561536] Verify Sustainability Ledger Entry is created but Sustainability Value Entry 
        // is not created when Post Purchase Order if Enable Value Chain Tracking is false in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

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
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify(true);

        // [WHEN] Post Purchase Document with Receiving and Invoicing.
        PostedInvoiceNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Find Sustainability Ledger Entry.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedInvoiceNo);

        // [THEN] Sustainability Ledger Entry is found.
        Assert.IsFalse(SustainabilityLedgerEntry.IsEmpty(), SustLedgerEntryShouldNotBeFoundErr);

        // [WHEN] Find Sustainability Value Entry.
        SustainabilityValueEntry.SetRange("Item No.", PurchaseLine."No.");

        // [THEN] Sustainability Value Entry is not found.
        Assert.IsTrue(SustainabilityValueEntry.IsEmpty(), SustValueEntryShouldNotBeFoundErr);
    end;

    [Test]
    procedure VerifySustainabilityEntriesIfEnableValueChainTrackingIsFalseWhenPostPurchaseCrMemo()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        PurchCrMemoSubformPage: TestPage "Purch. Cr. Memo Subform";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        CrMemoNo: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        PostedCrMemoNo: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 561536] Verify Sustainability Ledger Entry is created but Sustainability Value Entry 
        // is not created when Post Purchase Cr. Memo if Enable Value Chain Tracking is false in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

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
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Qty. to Receive", LibraryRandom.RandIntInRange(5, 5));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", LibraryRandom.RandInt(20));
        PurchaseLine.Validate("Emission CH4", LibraryRandom.RandInt(5));
        PurchaseLine.Validate("Emission N2O", LibraryRandom.RandInt(5));
        PurchaseLine.Modify(true);

        // [GIVEN] Save Expected Emission.
        EmissionCO2 := PurchaseLine."Emission CO2 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);
        EmissionCH4 := PurchaseLine."Emission CH4 Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);
        EmissionN2O := PurchaseLine."Emission N2O Per Unit" * PurchaseLine."Qty. per Unit of Measure" * LibraryRandom.RandIntInRange(5, 5);

        // [WHEN] Save Sustainability fields.
        LibraryVariableStorage.Enqueue(EmissionCO2);
        LibraryVariableStorage.Enqueue(EmissionCH4);
        LibraryVariableStorage.Enqueue(EmissionN2O);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);
        LibraryVariableStorage.Enqueue(0);

        // [GIVEN] Update Reason Code in Purchase Header.
        UpdateReasonCodeinPurchaseHeader(PurchaseHeader);

        // [WHEN] Create Corrective Credit Memo.
        CrMemoNo := CreateCorrectiveCreditMemo(PurchaseHeader);

        // [VERIFY] Verify Sustainability fields before posting of Corrective Credit Memo.
        PurchCrMemoSubformPage.OpenEdit();
        PurchCrMemoSubformPage.Filter.SetFilter("Document No.", CrMemoNo);
        PurchCrMemoSubformPage.Filter.SetFilter("No.", PurchaseLine."No.");
        PurchCrMemoSubformPage."Sust. Account No.".AssertEquals(AccountCode);
        PurchCrMemoSubformPage."Emission CH4".AssertEquals(EmissionCH4);
        PurchCrMemoSubformPage."Emission CO2".AssertEquals(EmissionCO2);
        PurchCrMemoSubformPage."Emission N2O".AssertEquals(EmissionN2O);

        // [GIVEN] Post Corrective Credit Memo.
        PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", CrMemoNo);
        PostedCrMemoNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Find Sustainability Ledger Entry.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedCrMemoNo);

        // [THEN] Sustainability Ledger Entry is found.
        Assert.IsFalse(SustainabilityLedgerEntry.IsEmpty(), SustLedgerEntryShouldNotBeFoundErr);

        // [WHEN] Find Sustainability Value Entry.
        SustainabilityValueEntry.SetRange("Item No.", PurchaseLine."No.");

        // [THEN] Sustainability Value Entry is not found.
        Assert.IsTrue(SustainabilityValueEntry.IsEmpty(), SustValueEntryShouldNotBeFoundErr);
    end;

    [Test]
    procedure VerifySustainabilityEntriesIfEnableValueChainTrackingIsFalseWhenPostPurchaseReturnOrder()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityValueEntry: Record "Sustainability Value Entry";
        AccountCode: Code[20];
        CategoryCode: Code[20];
        EmissionCO2: Decimal;
        EmissionCH4: Decimal;
        EmissionN2O: Decimal;
        PostedCrMemoNo: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 561536] Verify Sustainability Ledger Entry is created but Sustainability Value Entry 
        // is not created when Post Purchase Return Order if Enable Value Chain Tracking is false in Sustainability Setup.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(false);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Generate Emission.
        EmissionCO2 := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4 := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2O := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::"Return Order", LibraryPurchase.CreateVendorNo());

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Item,
            LibraryInventory.CreateItemNo(),
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update Sustainability Account No.,Emission CO2 ,Emission CH4 ,Emission N2O.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2", EmissionCO2);
        PurchaseLine.Validate("Emission CH4", EmissionCH4);
        PurchaseLine.Validate("Emission N2O", EmissionN2O);
        PurchaseLine.Modify(true);

        // [WHEN] Post Purchase Document with Receiving and Invoicing.
        PostedCrMemoNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Find Sustainability Ledger Entry.
        SustainabilityLedgerEntry.SetRange("Document No.", PostedCrMemoNo);

        // [THEN] Sustainability Ledger Entry is found.
        Assert.IsFalse(SustainabilityLedgerEntry.IsEmpty(), SustLedgerEntryShouldNotBeFoundErr);

        // [WHEN] Find Sustainability Value Entry.
        SustainabilityValueEntry.SetRange("Item No.", PurchaseLine."No.");

        // [THEN] Sustainability Value Entry is not found.
        Assert.IsTrue(SustainabilityValueEntry.IsEmpty(), SustValueEntryShouldNotBeFoundErr);
    end;

    [Test]
    procedure VerifyDefaultEmissionFieldsMustBeUpdatedInItemForReplenishmentSystemPurchase()
    var
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        AccountCode: Code[20];
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 563478] Verify "Default CO2 Emission", "Default CH4 Emission", "Default N2O Emission" must be updated in Item for "Replenishment System" Purchase.
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
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify "Default CO2 Emission", "Default CH4 Emission", "Default N2O Emission" must be updated in Item for "Replenishment System" Purchase.
        Item.Get(Item."No.");
        Assert.AreEqual(
            EmissionCO2PerUnit,
            Item."Default CO2 Emission",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("Default CO2 Emission"), EmissionCO2PerUnit, Item.TableCaption()));
        Assert.AreEqual(
            EmissionCH4PerUnit,
            Item."Default CH4 Emission",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("Default CH4 Emission"), EmissionCH4PerUnit, Item.TableCaption()));
        Assert.AreEqual(
            EmissionN2OPerUnit,
            Item."Default N2O Emission",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("Default N2O Emission"), EmissionN2OPerUnit, Item.TableCaption()));
    end;

    [Test]
    procedure VerifyDefaultEmissionFieldsMustNotBeUpdatedInItemIfDefaultSustAccountIsBlank()
    var
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        AccountCode: Code[20];
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 563478] Verify "Default CO2 Emission", "Default CH4 Emission", "Default N2O Emission" must not be updated in Item If "Default Sust. Account" is blank.
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

        // [GIVEN] Update "Sust. Account No.", "Emission CO2 Per Unit" ,"Emission CH4 Per Unit" ,"Emission N2O Per Unit" in Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify(true);

        // [WHEN] Post Purchase Document with Receiving and Invoicing.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify "Default CO2 Emission", "Default CH4 Emission", "Default N2O Emission" must not be updated in Item If "Default Sust. Account" is blank.
        Item.Get(Item."No.");
        Assert.AreEqual(
            0,
            Item."Default CO2 Emission",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("Default CO2 Emission"), 0, Item.TableCaption()));
        Assert.AreEqual(
            0,
            Item."Default CH4 Emission",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("Default CH4 Emission"), 0, Item.TableCaption()));
        Assert.AreEqual(
            0,
            Item."Default N2O Emission",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("Default N2O Emission"), 0, Item.TableCaption()));
    end;

    [Test]
    procedure VerifyDefaultEmissionFieldsMustNotBeUpdatedInItemForReplenishmentSystemProdOrder()
    var
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        AccountCode: Code[20];
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 563478] Verify "Default CO2 Emission", "Default CH4 Emission", "Default N2O Emission" must not be updated in Item for "Replenishment System" "Prod. Order".
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
        Item.Validate("Replenishment System", Item."Replenishment System"::"Prod. Order");
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
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify "Default CO2 Emission", "Default CH4 Emission", "Default N2O Emission" must not be updated in Item for "Replenishment System" "Prod. Order".
        Item.Get(Item."No.");
        Assert.AreEqual(
            0,
            Item."Default CO2 Emission",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("Default CO2 Emission"), 0, Item.TableCaption()));
        Assert.AreEqual(
            0,
            Item."Default CH4 Emission",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("Default CH4 Emission"), 0, Item.TableCaption()));
        Assert.AreEqual(
            0,
            Item."Default N2O Emission",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("Default N2O Emission"), 0, Item.TableCaption()));
    end;

    [Test]
    procedure VerifyDefaultEmissionFieldsMustBeUpdatedInResource()
    var
        Resource: Record Resource;
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        AccountCode: Code[20];
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 563478] Verify "Default CO2 Emission", "Default CH4 Emission", "Default N2O Emission" must be updated in Resource.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Generate Emission.
        EmissionCO2PerUnit := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4PerUnit := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2OPerUnit := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Find Resource.
        LibraryResource.CreateResourceNew(Resource);
        Resource.Validate("Default Sust. Account", AccountCode);
        Resource.Modify();

        // [GIVEN] Create a vendor.
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, Vendor."No.");

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Resource,
            Resource."No.",
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Emission CO2 Per Unit" ,"Emission CH4 Per Unit" ,"Emission N2O Per Unit" in Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify(true);

        // [WHEN] Post Purchase Document with Receiving and Invoicing.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify "Default CO2 Emission", "Default CH4 Emission", "Default N2O Emission" must be updated in Resource.
        Resource.Get(Resource."No.");
        Assert.AreEqual(
            EmissionCO2PerUnit,
            Resource."Default CO2 Emission",
            StrSubstNo(ValueMustBeEqualErr, Resource.FieldCaption("Default CO2 Emission"), EmissionCO2PerUnit, Resource.TableCaption()));
        Assert.AreEqual(
            EmissionCH4PerUnit,
            Resource."Default CH4 Emission",
            StrSubstNo(ValueMustBeEqualErr, Resource.FieldCaption("Default CH4 Emission"), EmissionCH4PerUnit, Resource.TableCaption()));
        Assert.AreEqual(
            EmissionN2OPerUnit,
            Resource."Default N2O Emission",
            StrSubstNo(ValueMustBeEqualErr, Resource.FieldCaption("Default N2O Emission"), EmissionN2OPerUnit, Resource.TableCaption()));
    end;

    [Test]
    procedure VerifyDefaultEmissionFieldsMustNotBeUpdatedInResourceIfDefaultSustAccountIsBlank()
    var
        Resource: Record Resource;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        AccountCode: Code[20];
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        // [SCENARIO 563478] Verify "Default CO2 Emission", "Default CH4 Emission", "Default N2O Emission" must not be updated in Resource 
        // If "Default Sust. Account" is blank.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        // [GIVEN] Generate Emission.
        EmissionCO2PerUnit := LibraryRandom.RandIntInRange(100, 100);
        EmissionCH4PerUnit := LibraryRandom.RandIntInRange(200, 200);
        EmissionN2OPerUnit := LibraryRandom.RandIntInRange(300, 300);

        // [GIVEN] Find Resource.
        LibraryResource.CreateResourceNew(Resource);
        Resource.Validate("Default Sust. Account", '');
        Resource.Modify();

        // [GIVEN] Create a vendor.
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] Create a Purchase Header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, Vendor."No.");

        // [GIVEN] Create a Purchase Line.
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine,
            PurchaseHeader,
            "Purchase Line Type"::Resource,
            Resource."No.",
            LibraryRandom.RandIntInRange(10, 10));

        // [GIVEN] Update "Sust. Account No.", "Emission CO2 Per Unit" ,"Emission CH4 Per Unit" ,"Emission N2O Per Unit" in Purchase Line.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify(true);

        // [WHEN] Post Purchase Document with Receiving and Invoicing.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Verify "Default CO2 Emission", "Default CH4 Emission", "Default N2O Emission" must not be updated in Resource.
        Resource.Get(Resource."No.");
        Assert.AreEqual(
            0,
            Resource."Default CO2 Emission",
            StrSubstNo(ValueMustBeEqualErr, Resource.FieldCaption("Default CO2 Emission"), 0, Resource.TableCaption()));
        Assert.AreEqual(
            0,
            Resource."Default CH4 Emission",
            StrSubstNo(ValueMustBeEqualErr, Resource.FieldCaption("Default CH4 Emission"), 0, Resource.TableCaption()));
        Assert.AreEqual(
            0,
            Resource."Default N2O Emission",
            StrSubstNo(ValueMustBeEqualErr, Resource.FieldCaption("Default N2O Emission"), 0, Resource.TableCaption()));
    end;

    [Test]
    procedure VerifyTotalCO2eMustBeZeroAndNonEditableIfTransferLineIsCompletelyShipment()
    var
        AccountingPeriod: Record "Accounting Period";
        SustainabilityAccount: Record "Sustainability Account";
        TransferHeader: Record "Transfer Header";
        FromLocation: Record Location;
        ToLocation: Record Location;
        InTransitLocation: Record Location;
        Item: Record Item;
        TransferOrder: TestPage "Transfer Order";
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 564924] Verify "Total CO2e" must be zero and non-editable in Transfer Line if Line is completely shipped.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Find Accounting Period.
        FindAccountingPeriod(AccountingPeriod);

        // [GIVEN] Change WorkDate.
        WorkDate(AccountingPeriod."Starting Date");

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per unit" and Quantity.
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 100);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create FromLocation, ToLocation and In transit Location that will be used to create Transfer Order.
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);

        // [GIVEN] Create Item with Inventory.
        CreateItemWithInventory(Item, FromLocation.Code);

        // [GIVEN] Update "Default Sust. Account", "CO2e per Unit" in an Item.
        Item.Get(Item."No.");
        Item.Validate("Default Sust. Account", AccountCode);
        Item.Validate("CO2e per Unit", CO2ePerUnit);
        Item.Modify();

        // [GIVEN] Create Transfer Order.
        CreateTransferOrderWithLocation(TransferHeader, Item, FromLocation.Code, ToLocation.Code, InTransitLocation.Code, Quantity, CO2ePerUnit);

        // [GIVEN] Post Transfer Order.
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, false);

        // [WHEN] Open Transfer Order.
        TransferOrder.OpenEdit();
        TransferOrder.GoToRecord(TransferHeader);

        // [THEN] Verify "Total CO2e" must be zero and non-editable in Transfer Line if Line is completely shipped.
        TransferOrder.TransferLines."Total CO2e".AssertEquals(0);
        Assert.IsFalse(
            TransferOrder.TransferLines."Total CO2e".Editable(),
            StrSubstNo(FieldShouldNotBeEditableErr, TransferOrder.TransferLines."Total CO2e".Caption(), TransferOrder.TransferLines.Caption()));
    end;

    [Test]
    procedure VerifyCO2ePerUnitMustBeZeroInItemWhenTransferOrderIsShipped()
    var
        AccountingPeriod: Record "Accounting Period";
        SustainabilityAccount: Record "Sustainability Account";
        TransferHeader: Record "Transfer Header";
        FromLocation: Record Location;
        ToLocation: Record Location;
        InTransitLocation: Record Location;
        Item: Record Item;
        CO2ePerUnit: Decimal;
        Quantity: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 564928] Verify "CO2e per Unit" must be zero in item when Transfer Order is shipped.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Find Accounting Period.
        FindAccountingPeriod(AccountingPeriod);

        // [GIVEN] Change WorkDate.
        WorkDate(AccountingPeriod."Starting Date");

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per unit" and Quantity.
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 100);
        Quantity := LibraryRandom.RandIntInRange(10, 10);

        // [GIVEN] Create FromLocation, ToLocation and In transit Location that will be used to create Transfer Order.
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);

        // [GIVEN] Create Item with Inventory.
        CreateItemWithInventory(Item, FromLocation.Code);

        // [GIVEN] Update "Default Sust. Account" in an Item.
        Item.Get(Item."No.");
        Item.Validate("Default Sust. Account", AccountCode);
        Item.Modify();

        // [GIVEN] Create Transfer Order.
        CreateTransferOrderWithLocation(TransferHeader, Item, FromLocation.Code, ToLocation.Code, InTransitLocation.Code, Quantity, CO2ePerUnit);

        // [WHEN] Post Transfer Order.
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, false);

        // [THEN] Verify "CO2e per Unit" must be zero in item when Transfer Order is shipped.
        Item.Get(Item."No.");
        Assert.AreEqual(
            0,
            Item."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("CO2e per Unit"), 0, Item.TableCaption()));
    end;

    [Test]
    procedure VerifyCO2ePerUnitMustBeUpdatedInItemWhenTransferOrderIsShipped()
    var
        EmissionFee: array[3] of Record "Emission Fee";
        AccountingPeriod: Record "Accounting Period";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TransferHeader: Record "Transfer Header";
        FromLocation: Record Location;
        ToLocation: Record Location;
        InTransitLocation: Record Location;
        Item: Record Item;
        EmissionCO2perUnit: Decimal;
        EmissionCH4perUnit: Decimal;
        EmissionN2OperUnit: Decimal;
        ExpectedCO2eEmission: Decimal;
        CO2ePerUnit: Decimal;
        ExpectedCO2ePerUnit: Decimal;
        PurchQty: Decimal;
        TransferQty: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 564928] Verify "CO2e per Unit" must be updated in item when Transfer Order is shipped.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Find Accounting Period.
        FindAccountingPeriod(AccountingPeriod);

        // [GIVEN] Change WorkDate.
        WorkDate(AccountingPeriod."Starting Date");

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per unit" and Quantity.
        CO2ePerUnit := LibraryRandom.RandIntInRange(100, 100);
        PurchQty := LibraryRandom.RandIntInRange(20, 20);
        TransferQty := LibraryRandom.RandIntInRange(10, 10);
        EmissionCO2perUnit := LibraryRandom.RandIntInRange(10, 100);
        EmissionCH4perUnit := LibraryRandom.RandIntInRange(10, 100);
        EmissionN2OperUnit := LibraryRandom.RandIntInRange(10, 100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmission := EmissionCH4perUnit * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2perUnit * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2OperUnit * EmissionFee[3]."Carbon Equivalent Factor";

        // [GIVEN] Create FromLocation, ToLocation and In transit Location that will be used to create Transfer Order.
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);

        // [GIVEN] Update "Default Sust. Account" in an Item.
        LibraryInventory.CreateItem(Item);
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
            PurchQty);

        // [GIVEN] Update "Emission CO2 Per Unit" ,"Emission CH4 Per Unit" ,"Emission N2O Per Unit" in Purchase Line.
        PurchaseLine.Validate("Location Code", FromLocation.Code);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 100));
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2perUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4perUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OperUnit);
        PurchaseLine.Modify(true);

        // [GIVEN] Post Purchase Document with Receiving and Invoicing.
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [GIVEN] Create Transfer Order.
        CreateTransferOrderWithLocation(TransferHeader, Item, FromLocation.Code, ToLocation.Code, InTransitLocation.Code, TransferQty, CO2ePerUnit);

        // [WHEN] Post Transfer Order.
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, false);
        ExpectedCO2ePerUnit := ((ExpectedCO2eEmission * PurchQty) + (CO2ePerUnit * TransferQty)) / PurchQty;

        // [THEN] Verify "CO2e per Unit" must be updated in item when Transfer Order is shipped.
        Item.Get(Item."No.");
        Assert.AreEqual(
            ExpectedCO2ePerUnit,
            Item."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("CO2e per Unit"), ExpectedCO2ePerUnit, Item.TableCaption()));
    end;

    [Test]
    procedure VerifyCO2PerUnitInItemWhenTransferIsPostedAfterTwoPurchaseOrdersWithDifferentEmissions()
    var
        EmissionFee: array[3] of Record "Emission Fee";
        AccountingPeriod: Record "Accounting Period";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        FromLocation: Record Location;
        ToLocation: Record Location;
        InTransitLocation: Record Location;
        Item: Record Item;
        EmissionCO2PerUnit: array[2] of Decimal;
        EmissionCH4PerUnit: array[2] of Decimal;
        EmissionN2OPerUnit: array[2] of Decimal;
        ExpectedCO2eEmissionPerUnit: array[2] of Decimal;
        TransferCO2ePerUnit: Decimal;
        ExpectedCO2ePerUnit: Decimal;
        PurchQty: array[2] of Decimal;
        TransferQty: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 564928] Verify "CO2e per Unit" must be updated in item when Transfer is posted after 2 purchase orders with different emissions.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Find Accounting Period.
        FindAccountingPeriod(AccountingPeriod);

        // [GIVEN] Change WorkDate.
        WorkDate(AccountingPeriod."Starting Date");

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per unit" and Quantity.
        TransferCO2ePerUnit := LibraryRandom.RandIntInRange(100, 100);
        PurchQty[1] := LibraryRandom.RandIntInRange(20, 20);
        PurchQty[2] := LibraryRandom.RandIntInRange(15, 15);
        TransferQty := LibraryRandom.RandIntInRange(10, 10);
        EmissionCO2PerUnit[1] := LibraryRandom.RandIntInRange(10, 100);
        EmissionCH4PerUnit[1] := LibraryRandom.RandIntInRange(10, 100);
        EmissionN2OPerUnit[1] := LibraryRandom.RandIntInRange(10, 100);
        EmissionCO2PerUnit[2] := LibraryRandom.RandIntInRange(10, 100);
        EmissionCH4PerUnit[2] := LibraryRandom.RandIntInRange(10, 100);
        EmissionN2OPerUnit[2] := LibraryRandom.RandIntInRange(10, 100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmissionPerUnit[1] := EmissionCH4PerUnit[1] * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2PerUnit[1] * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2OPerUnit[1] * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCO2eEmissionPerUnit[2] := EmissionCH4PerUnit[2] * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2PerUnit[2] * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2OPerUnit[2] * EmissionFee[3]."Carbon Equivalent Factor";

        // [GIVEN] Create FromLocation, ToLocation and In transit Location that will be used to create Transfer Order.
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);

        // [GIVEN] Update "Default Sust. Account" in an Item.
        LibraryInventory.CreateItem(Item);
        Item.Validate("Default Sust. Account", AccountCode);
        Item.Modify();

        // [WHEN] Create and Post Purchase Document.
        CreateAndPostPurchaseDocument(PurchaseHeader, Item."No.", PurchQty[1], FromLocation.Code, EmissionFee[1]."Country/Region Code", AccountCode, EmissionCO2PerUnit[1], EmissionCH4PerUnit[1], EmissionN2OPerUnit[1]);
        CreateAndPostPurchaseDocument(PurchaseHeader, Item."No.", PurchQty[2], FromLocation.Code, EmissionFee[1]."Country/Region Code", AccountCode, EmissionCO2PerUnit[2], EmissionCH4PerUnit[2], EmissionN2OPerUnit[2]);
        ExpectedCO2ePerUnit := ((ExpectedCO2eEmissionPerUnit[1] * PurchQty[1]) + (ExpectedCO2eEmissionPerUnit[2] * PurchQty[2])) / (PurchQty[1] + PurchQty[2]);

        // [THEN] Verify "CO2e per Unit" must be updated in item.
        Item.Get(Item."No.");
        Assert.AreEqual(
            ExpectedCO2ePerUnit,
            Item."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("CO2e per Unit"), ExpectedCO2ePerUnit, Item.TableCaption()));

        // [GIVEN] Create Transfer Order.
        CreateTransferOrderWithLocation(TransferHeader, Item, FromLocation.Code, ToLocation.Code, InTransitLocation.Code, TransferQty, TransferCO2ePerUnit);

        // [WHEN] Post Transfer Order.
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, false);
        ExpectedCO2ePerUnit := ((ExpectedCO2eEmissionPerUnit[1] * PurchQty[1]) + (ExpectedCO2eEmissionPerUnit[2] * PurchQty[2]) + (TransferCO2ePerUnit * TransferQty)) / (PurchQty[1] + PurchQty[2]);

        // [THEN] Verify "CO2e per Unit" must be updated in item when Transfer is posted after 2 purchase orders with different emissions.
        Item.Get(Item."No.");
        Assert.AreEqual(
            ExpectedCO2ePerUnit,
            Item."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("CO2e per Unit"), ExpectedCO2ePerUnit, Item.TableCaption()));
    end;

    [Test]
    procedure VerifyCO2PerUnitInItemWhenTransferIsPostedAfterTwoPurchaseOrdersWithSameEmissions()
    var
        EmissionFee: array[3] of Record "Emission Fee";
        AccountingPeriod: Record "Accounting Period";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        FromLocation: Record Location;
        ToLocation: Record Location;
        InTransitLocation: Record Location;
        Item: Record Item;
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        ExpectedCO2eEmissionPerUnit: Decimal;
        TransferCO2ePerUnit: Decimal;
        ExpectedCO2ePerUnit: Decimal;
        PurchQty: Decimal;
        TransferQty: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 564928] Verify "CO2e per Unit" must be updated in item when Transfer is posted after 2 purchase orders with same emissions.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Find Accounting Period.
        FindAccountingPeriod(AccountingPeriod);

        // [GIVEN] Change WorkDate.
        WorkDate(AccountingPeriod."Starting Date");

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per unit" and Quantity.
        TransferCO2ePerUnit := LibraryRandom.RandIntInRange(100, 100);
        PurchQty := LibraryRandom.RandIntInRange(20, 20);
        TransferQty := LibraryRandom.RandIntInRange(10, 10);
        EmissionCO2PerUnit := LibraryRandom.RandIntInRange(10, 100);
        EmissionCH4PerUnit := LibraryRandom.RandIntInRange(10, 100);
        EmissionN2OPerUnit := LibraryRandom.RandIntInRange(10, 100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmissionPerUnit := EmissionCH4PerUnit * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2PerUnit * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2OPerUnit * EmissionFee[3]."Carbon Equivalent Factor";

        // [GIVEN] Create FromLocation, ToLocation and In transit Location that will be used to create Transfer Order.
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);

        // [GIVEN] Update "Default Sust. Account" in an Item.
        LibraryInventory.CreateItem(Item);
        Item.Validate("Default Sust. Account", AccountCode);
        Item.Modify();

        // [WHEN] Create and Post Purchase Document.
        CreateAndPostPurchaseDocument(PurchaseHeader, Item."No.", PurchQty, FromLocation.Code, EmissionFee[1]."Country/Region Code", AccountCode, EmissionCO2PerUnit, EmissionCH4PerUnit, EmissionN2OPerUnit);
        CreateAndPostPurchaseDocument(PurchaseHeader, Item."No.", PurchQty, FromLocation.Code, EmissionFee[1]."Country/Region Code", AccountCode, EmissionCO2PerUnit, EmissionCH4PerUnit, EmissionN2OPerUnit);
        ExpectedCO2ePerUnit := ((ExpectedCO2eEmissionPerUnit * PurchQty) * 2) / (PurchQty * 2);

        // [THEN] Verify "CO2e per Unit" must be updated in item.
        Item.Get(Item."No.");
        Assert.AreEqual(
            ExpectedCO2ePerUnit,
            Item."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("CO2e per Unit"), ExpectedCO2ePerUnit, Item.TableCaption()));

        // [GIVEN] Create Transfer Order.
        CreateTransferOrderWithLocation(TransferHeader, Item, FromLocation.Code, ToLocation.Code, InTransitLocation.Code, TransferQty, TransferCO2ePerUnit);

        // [WHEN] Post Transfer Order.
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, false);
        ExpectedCO2ePerUnit := ((ExpectedCO2eEmissionPerUnit * PurchQty) * 2 + (TransferCO2ePerUnit * TransferQty)) / (PurchQty * 2);

        // [THEN] Verify "CO2e per Unit" must be updated in item when Transfer is posted after 2 purchase orders with same emissions.
        Item.Get(Item."No.");
        Assert.AreEqual(
            ExpectedCO2ePerUnit,
            Item."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("CO2e per Unit"), ExpectedCO2ePerUnit, Item.TableCaption()));
    end;

    [Test]
    procedure VerifyCO2PerUnitInItemWhenTransferIsPostedAfterOnePurchaseOrder()
    var
        EmissionFee: array[3] of Record "Emission Fee";
        AccountingPeriod: Record "Accounting Period";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        FromLocation: Record Location;
        ToLocation: Record Location;
        InTransitLocation: Record Location;
        Item: Record Item;
        EmissionCO2PerUnit: array[2] of Decimal;
        EmissionCH4PerUnit: array[2] of Decimal;
        EmissionN2OPerUnit: array[2] of Decimal;
        ExpectedCO2eEmissionPerUnit: array[2] of Decimal;
        TransferCO2ePerUnit: Decimal;
        ExpectedCO2ePerUnit: Decimal;
        PurchQty: array[2] of Decimal;
        TransferQty: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 564928] Verify "CO2e per Unit" must be updated in item when one purchase is posted before transfer and then purchase is again posted after transfer is posted.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Find Accounting Period.
        FindAccountingPeriod(AccountingPeriod);

        // [GIVEN] Change WorkDate.
        WorkDate(AccountingPeriod."Starting Date");

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per unit" and Quantity.
        TransferCO2ePerUnit := LibraryRandom.RandIntInRange(100, 100);
        PurchQty[1] := LibraryRandom.RandIntInRange(15, 15);
        PurchQty[2] := LibraryRandom.RandIntInRange(20, 20);
        TransferQty := LibraryRandom.RandIntInRange(10, 10);
        EmissionCO2PerUnit[1] := LibraryRandom.RandIntInRange(10, 100);
        EmissionCH4PerUnit[1] := LibraryRandom.RandIntInRange(10, 100);
        EmissionN2OPerUnit[1] := LibraryRandom.RandIntInRange(10, 100);
        EmissionCO2PerUnit[2] := LibraryRandom.RandIntInRange(10, 100);
        EmissionCH4PerUnit[2] := LibraryRandom.RandIntInRange(10, 100);
        EmissionN2OPerUnit[2] := LibraryRandom.RandIntInRange(10, 100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmissionPerUnit[1] := EmissionCH4PerUnit[1] * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2PerUnit[1] * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2OPerUnit[1] * EmissionFee[3]."Carbon Equivalent Factor";
        ExpectedCO2eEmissionPerUnit[2] := EmissionCH4PerUnit[2] * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2PerUnit[2] * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2OPerUnit[2] * EmissionFee[3]."Carbon Equivalent Factor";

        // [GIVEN] Create FromLocation, ToLocation and In transit Location that will be used to create Transfer Order.
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);

        // [GIVEN] Update "Default Sust. Account" in an Item.
        LibraryInventory.CreateItem(Item);
        Item.Validate("Default Sust. Account", AccountCode);
        Item.Modify();

        // [WHEN] Create and Post Purchase Document.
        CreateAndPostPurchaseDocument(PurchaseHeader, Item."No.", PurchQty[1], FromLocation.Code, EmissionFee[1]."Country/Region Code", AccountCode, EmissionCO2PerUnit[1], EmissionCH4PerUnit[1], EmissionN2OPerUnit[1]);
        ExpectedCO2ePerUnit := ((ExpectedCO2eEmissionPerUnit[1] * PurchQty[1])) / PurchQty[1];

        // [THEN] Verify "CO2e per Unit" must be updated in item when purchase is posted.
        Item.Get(Item."No.");
        Assert.AreEqual(
            ExpectedCO2ePerUnit,
            Item."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("CO2e per Unit"), ExpectedCO2ePerUnit, Item.TableCaption()));

        // [GIVEN] Create Transfer Order.
        CreateTransferOrderWithLocation(TransferHeader, Item, FromLocation.Code, ToLocation.Code, InTransitLocation.Code, TransferQty, TransferCO2ePerUnit);

        // [WHEN] Post Transfer Order.
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, false);
        ExpectedCO2ePerUnit := ((ExpectedCO2eEmissionPerUnit[1] * PurchQty[1]) + (TransferCO2ePerUnit * TransferQty)) / (PurchQty[1]);

        // [THEN] Verify "CO2e per Unit" must be updated in item when Transfer is posted after one purchase orders.
        Item.Get(Item."No.");
        Assert.AreEqual(
            ExpectedCO2ePerUnit,
            Item."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("CO2e per Unit"), ExpectedCO2ePerUnit, Item.TableCaption()));

        // [WHEN] Create and Post Purchase Document.
        CreateAndPostPurchaseDocument(PurchaseHeader, Item."No.", PurchQty[2], FromLocation.Code, EmissionFee[1]."Country/Region Code", AccountCode, EmissionCO2PerUnit[2], EmissionCH4PerUnit[2], EmissionN2OPerUnit[2]);
        ExpectedCO2ePerUnit := ((ExpectedCO2eEmissionPerUnit[1] * PurchQty[1]) + (ExpectedCO2eEmissionPerUnit[2] * PurchQty[2]) + (TransferCO2ePerUnit * TransferQty)) / (PurchQty[1] + PurchQty[2]);

        // [THEN] Verify "CO2e per Unit" must be updated in item when purchase is posted.
        Item.Get(Item."No.");
        Assert.AreEqual(
            ExpectedCO2ePerUnit,
            Item."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("CO2e per Unit"), ExpectedCO2ePerUnit, Item.TableCaption()));
    end;

    [Test]
    procedure VerifyCO2PerUnitInItemWhenTransferIsPartiallyPostedAfterTwoPurchaseOrdersWithSameEmissions()
    var
        EmissionFee: array[3] of Record "Emission Fee";
        AccountingPeriod: Record "Accounting Period";
        SustainabilityAccount: Record "Sustainability Account";
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        FromLocation: Record Location;
        ToLocation: Record Location;
        InTransitLocation: Record Location;
        Item: Record Item;
        TransferLine: Record "Transfer Line";
        TransferOrder: TestPage "Transfer Order";
        EmissionCO2PerUnit: Decimal;
        EmissionCH4PerUnit: Decimal;
        EmissionN2OPerUnit: Decimal;
        ExpectedCO2eEmissionPerUnit: Decimal;
        TransferCO2ePerUnit: Decimal;
        ExpectedCO2ePerUnit: Decimal;
        PurchQty: Decimal;
        TransferQty: Decimal;
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        // [SCENARIO 564928] Verify "CO2e per Unit" must be updated in item when Transfer is partially posted after 2 purchase orders with same emissions.
        LibrarySustainability.CleanUpBeforeTesting();

        // [GIVEN] Find Accounting Period.
        FindAccountingPeriod(AccountingPeriod);

        // [GIVEN] Change WorkDate.
        WorkDate(AccountingPeriod."Starting Date");

        // [GIVEN] Create Emission Fee With Emission Scope.
        CreateEmissionFeeWithEmissionScope(EmissionFee, SustainabilityAccount."Emission Scope", '');

        // [GIVEN] Update "Enable Value Chain Tracking" in Sustainability Setup.
        LibrarySustainability.UpdateValueChainTrackingInSustainabilitySetup(true);

        // [GIVEN] Create a Sustainability Account.
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));
        SustainabilityAccount.Get(AccountCode);

        // [GIVEN] Generate "CO2e per unit" and Quantity.
        TransferCO2ePerUnit := LibraryRandom.RandIntInRange(100, 100);
        PurchQty := LibraryRandom.RandIntInRange(20, 20);
        TransferQty := LibraryRandom.RandIntInRange(10, 10);
        EmissionCO2PerUnit := LibraryRandom.RandIntInRange(10, 100);
        EmissionCH4PerUnit := LibraryRandom.RandIntInRange(10, 100);
        EmissionN2OPerUnit := LibraryRandom.RandIntInRange(10, 100);

        // [GIVEN] Save Expected CO2e Emission.
        ExpectedCO2eEmissionPerUnit := EmissionCH4PerUnit * EmissionFee[1]."Carbon Equivalent Factor" + EmissionCO2PerUnit * EmissionFee[2]."Carbon Equivalent Factor" + EmissionN2OPerUnit * EmissionFee[3]."Carbon Equivalent Factor";

        // [GIVEN] Create FromLocation, ToLocation and In transit Location that will be used to create Transfer Order.
        LibraryWarehouse.CreateTransferLocations(FromLocation, ToLocation, InTransitLocation);

        // [GIVEN] Update "Default Sust. Account" in an Item.
        LibraryInventory.CreateItem(Item);
        Item.Validate("Default Sust. Account", AccountCode);
        Item.Modify();

        // [WHEN] Create and Post Purchase Document.
        CreateAndPostPurchaseDocument(PurchaseHeader, Item."No.", PurchQty, FromLocation.Code, EmissionFee[1]."Country/Region Code", AccountCode, EmissionCO2PerUnit, EmissionCH4PerUnit, EmissionN2OPerUnit);
        CreateAndPostPurchaseDocument(PurchaseHeader, Item."No.", PurchQty, FromLocation.Code, EmissionFee[1]."Country/Region Code", AccountCode, EmissionCO2PerUnit, EmissionCH4PerUnit, EmissionN2OPerUnit);
        ExpectedCO2ePerUnit := ((ExpectedCO2eEmissionPerUnit * PurchQty) * 2) / (PurchQty * 2);

        // [THEN] Verify "CO2e per Unit" must be updated in item.
        Item.Get(Item."No.");
        Assert.AreEqual(
            ExpectedCO2ePerUnit,
            Item."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("CO2e per Unit"), ExpectedCO2ePerUnit, Item.TableCaption()));

        // [GIVEN] Create Transfer Order.
        CreateTransferOrderWithLocation(TransferHeader, Item, FromLocation.Code, ToLocation.Code, InTransitLocation.Code, TransferQty, TransferCO2ePerUnit);

        // [GIVEN] Update "Qty. to Ship" in Transfer Line.
        GetTransferLine(TransferHeader, TransferLine);
        TransferLine.Validate("Qty. to Ship", (TransferQty / 2));
        TransferLine.Modify();

        // [WHEN] Post Transfer Order.
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, false);
        ExpectedCO2ePerUnit := ((ExpectedCO2eEmissionPerUnit * PurchQty) * 2 + (TransferCO2ePerUnit * (TransferQty / 2))) / (PurchQty * 2);

        // [THEN] Verify "CO2e per Unit" must be updated in item when Transfer is partially posted after 2 purchase orders with same emissions.
        Item.Get(Item."No.");
        Assert.AreEqual(
            ExpectedCO2ePerUnit,
            Item."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, Item.FieldCaption("CO2e per Unit"), ExpectedCO2ePerUnit, Item.TableCaption()));

        // [WHEN] Open Transfer Order.
        TransferOrder.OpenEdit();
        TransferOrder.GoToRecord(TransferHeader);

        // [THEN] Verify "Total CO2e" must not be zero and editable in Transfer Line if Line is partially shipped.
        TransferOrder.TransferLines."Total CO2e".AssertEquals(TransferCO2ePerUnit * TransferQty);
        Assert.IsTrue(
            TransferOrder.TransferLines."Total CO2e".Editable(),
            StrSubstNo(FieldShouldBeEditableErr, TransferOrder.TransferLines."Total CO2e".Caption(), TransferOrder.TransferLines.Caption()));
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

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the PurchaseStatistics action. The new action uses RunObject and does not run the action trigger', '26.0')]
    local procedure OpenPurchaseInvoiceStatistics(No: Code[20])
    var
        PurchaseInvoice: TestPage "Purchase Invoice";
    begin
        PurchaseInvoice.OpenEdit();
        PurchaseInvoice.FILTER.SetFilter("No.", No);
        PurchaseInvoice.Statistics.Invoke();
    end;
#endif

    local procedure OpenPurchInvoiceStatistics(No: Code[20])
    var
        PurchaseInvoice: TestPage "Purchase Invoice";
    begin
        PurchaseInvoice.OpenEdit();
        PurchaseInvoice.FILTER.SetFilter("No.", No);
        PurchaseInvoice.PurchaseStatistics.Invoke();
    end;

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the PurchaseStatistics action. The new action uses RunObject and does not run the action trigger', '26.0')]
    local procedure OpenPurchaseCrMemoStatistics(No: Code[20])
    var
        PurchaseCreditMemo: TestPage "Purchase Credit Memo";
    begin
        PurchaseCreditMemo.OpenEdit();
        PurchaseCreditMemo.FILTER.SetFilter("No.", No);
        PurchaseCreditMemo.Statistics.Invoke();
    end;
#endif

    local procedure OpenPurchCrMemoStatistics(No: Code[20])
    var
        PurchaseCreditMemo: TestPage "Purchase Credit Memo";
    begin
        PurchaseCreditMemo.OpenEdit();
        PurchaseCreditMemo.FILTER.SetFilter("No.", No);
        PurchaseCreditMemo.PurchaseStatistics.Invoke();
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

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the PurchaseStatistics action. The new action uses RunObject and does not run the action trigger', '26.0')]
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
#endif

    local procedure CreateCorrectiveCreditMemoAndOpenPurchCrMemoStatistics(PurchaseHeader: Record "Purchase Header"): Code[20]
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
        OpenPurchCrMemoStatistics(PurchaseHeader."No.");

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

    procedure GetAReadyToPostSustainabilityAccount(
        Scope: Enum "Emission Scope";
        CalcFoundation: Enum "Calculation Foundation";
        CO2: Boolean; CH4: Boolean; N2O: Boolean;
        CustomValue: Text[100]; CalcFromGL: Boolean;
        EFCO2: Decimal; EFCH4: Decimal; EFN2O: Decimal; RenewableEnergy: Boolean) Account: Record "Sustainability Account"
    var
        CategoryTok, SubcategoryTok, AccountTok : Code[20];
    begin
        CategoryTok := LibraryRandom.RandText(20);
        SubcategoryTok := LibraryRandom.RandText(20);
        AccountTok := Format(LibraryRandom.RandIntInRange(10000, 20000));
        LibrarySustainability.InsertAccountCategory(CategoryTok, '', Scope, CalcFoundation, CO2, CH4, N2O, CustomValue, CalcFromGL);
        LibrarySustainability.InsertAccountSubcategory(CategoryTok, SubcategoryTok, '', EFCO2, EFCH4, EFN2O, RenewableEnergy);
        Account := LibrarySustainability.InsertSustainabilityAccount(
            AccountTok, LibraryRandom.RandText(20), CategoryTok, SubcategoryTok, Enum::"Sustainability Account Type"::Posting, '', true);
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

    local procedure PostAndVerifyCorrectiveSalesCreditMemo(SalesHeader: Record "Sales Header")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        PostedDocNumber: Code[20];
    begin
        PostedDocNumber := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocNumber);

        // Create Corrective Credit Memo.
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);

        // Post Corrective Credit Memo.
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
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

    [Obsolete('The statistics action will be replaced with the SalesStatistics action. The new action uses RunObject and does not run the action trigger.', '26.0')]
    local procedure OpenSalesInvoiceStatistics(No: Code[20])
    var
        SalesInvoice: TestPage "Sales Invoice";
    begin
        SalesInvoice.OpenEdit();
        SalesInvoice.FILTER.SetFilter("No.", No);
        SalesInvoice.Statistics.Invoke();
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

    local procedure OpenSalesInvoiceSalesStatistics(No: Code[20])
    var
        SalesInvoice: TestPage "Sales Invoice";
    begin
        SalesInvoice.OpenEdit();
        SalesInvoice.FILTER.SetFilter("No.", No);
        SalesInvoice.SalesStatistics.Invoke();
    end;

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the SalesStatistics action. The new action uses RunObject and does not run the action trigger.', '26.0')]
    local procedure OpenSalesCrMemoStatistics(No: Code[20])
    var
        SalesCreditMemo: TestPage "Sales Credit Memo";
    begin
        SalesCreditMemo.OpenEdit();
        SalesCreditMemo.FILTER.SetFilter("No.", No);
        SalesCreditMemo.Statistics.Invoke();
    end;
#endif
    local procedure OpenSalesCrMemoSalesStatistics(No: Code[20])
    var
        SalesCreditMemo: TestPage "Sales Credit Memo";
    begin
        SalesCreditMemo.OpenEdit();
        SalesCreditMemo.FILTER.SetFilter("No.", No);
        SalesCreditMemo.SalesStatistics.Invoke();
    end;

    local procedure VerifyPostedSalesCrMemoStatistics(No: Code[20])
    var
        PostedSalesCreditMemoStatisticsPage: TestPage "Sales Credit Memo Statistics";
        PostedTotalCO2e: Variant;
    begin
        LibraryVariableStorage.Dequeue(PostedTotalCO2e);

        PostedSalesCreditMemoStatisticsPage.OpenEdit();
        PostedSalesCreditMemoStatisticsPage.FILTER.SetFilter("No.", No);
        PostedSalesCreditMemoStatisticsPage."Total CO2e".AssertEquals(PostedTotalCO2e);
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

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the SalesStatistics action. The new action uses RunObject and does not run the action trigger.', '26.0')]
    local procedure CreateCorrectiveCreditMemoAndOpenSalesCrMemoStatistics(SalesHeader: Record "Sales Header"): Code[20]
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        PostedDocNumber: Code[20];
    begin
        PostedDocNumber := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocNumber);

        // Create Corrective Credit Memo.
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);

        // Open Sales Cr Memo Statistics.
        OpenSalesCrMemoStatistics(SalesHeader."No.");

        exit(SalesHeader."No.");
    end;
#endif
    local procedure CreateCorrectiveCreditMemoAndOpenSalesCrMemoSalesStatistics(SalesHeader: Record "Sales Header"): Code[20]
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
        PostedDocNumber: Code[20];
    begin
        PostedDocNumber := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceHeader.Get(PostedDocNumber);

        // Create Corrective Credit Memo.
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);

        // Open Sales Cr Memo Statistics.
        OpenSalesCrMemoSalesStatistics(SalesHeader."No.");

        exit(SalesHeader."No.");
    end;

    local procedure CreateAssembledItem(var Item: Record Item; AssemblyPolicy: Enum "Assembly Policy"; NoOfComponents: Integer; QtyPer: Decimal)
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("Replenishment System", Item."Replenishment System"::Assembly);
        Item.Validate("Assembly Policy", AssemblyPolicy);
        Item.Modify(true);

        CreateAssemblyList(Item, NoOfComponents, QtyPer);
    end;

    local procedure CreateAssemblyList(ParentItem: Record Item; NoOfComponents: Integer; QtyPer: Decimal)
    var
        Item: Record Item;
        AssemblyLine: Record "Assembly Line";
        BOMComponent: Record "BOM Component";
        CompCount: Integer;
    begin
        // Add components - qty per is increasing same as no of components
        for CompCount := 1 to NoOfComponents do begin
            Clear(Item);
            LibraryInventory.CreateItem(Item);
            LibraryAssembly.AddEntityDimensions(AssemblyLine.Type::Item, Item."No.");
            AddComponentToAssemblyList(BOMComponent, "BOM Component Type"::Item, Item."No.", ParentItem."No.", '', Item."Base Unit of Measure", QtyPer);
        end;
    end;

    local procedure AddComponentToAssemblyList(var BOMComponent: Record "BOM Component"; ComponentType: Enum "BOM Component Type"; ComponentNo: Code[20]; ParentItemNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; QuantityPer: Decimal)
    begin
        LibraryInventory.CreateBOMComponent(BOMComponent, ParentItemNo, ComponentType, ComponentNo, QuantityPer, UOM);
        BOMComponent.Validate("Variant Code", VariantCode);
        if ComponentNo = '' then
            BOMComponent.Validate(Description,
              LibraryUtility.GenerateRandomCode(BOMComponent.FieldNo(Description), DATABASE::"BOM Component"));
        BOMComponent.Modify(true);
    end;

    local procedure CreateAndUpdateSustAccOnCompItem(ParentItem: Record Item; var CompItem: Record Item; var AccountCode: Code[20]; CO2ePerUnit: Decimal)
    var
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
    begin
        CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        CompItem.Get(GetBOMComponentItemNo(ParentItem));
        CompItem.Validate("Default Sust. Account", AccountCode);
        CompItem.Validate("CO2e per Unit", CO2ePerUnit);
        CompItem.Modify();
    end;

    local procedure GetBOMComponentItemNo(ParentItem: Record Item): Code[20]
    var
        BOMComponent: Record "BOM Component";
    begin
        BOMComponent.SetRange("Parent Item No.", ParentItem."No.");
        BOMComponent.FindSet();

        exit(BOMComponent."No.")
    end;

    local procedure GetAssemblyLine(AssemblyHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line")
    begin
        AssemblyLine.SetRange("Document Type", AssemblyHeader."Document Type");
        AssemblyLine.SetRange("Document No.", AssemblyHeader."No.");
        AssemblyLine.FindSet();
    end;

    local procedure GetPostedAssemblyHeader(var PostedAssemblyHeader: Record "Posted Assembly Header"; ItemNo: Code[20])
    begin
        PostedAssemblyHeader.SetRange("Item No.", ItemNo);
        PostedAssemblyHeader.FindSet();
    end;

    local procedure GetPostedAssemblyLine(PostedAssemblyHeader: Record "Posted Assembly Header"; var PostedAssemblyLine: Record "Posted Assembly Line")
    begin
        PostedAssemblyLine.SetRange("Document No.", PostedAssemblyHeader."No.");
        PostedAssemblyLine.FindSet();
    end;

    local procedure AddItemToInventory(Item: Record Item; Quantity: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        ItemJournalTemplate.SetRange(Type, ItemJournalTemplate.Type::Item);
        ItemJournalTemplate.SetRange(Recurring, false);
        ItemJournalTemplate.FindFirst();
        ItemJournalBatch.SetRange("Journal Template Name", ItemJournalTemplate.Name);
        ItemJournalBatch.FindFirst();

        LibraryInventory.CreateItemJournalLine(
            ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
            ItemJournalLine."Entry Type"::"Positive Adjmt.", Item."No.", Quantity);

        LibraryInventory.PostItemJournalLine(ItemJournalTemplate.Name, ItemJournalBatch.Name);
    end;

    local procedure VerifySustainabilityLedgerEntry(AccountCode: Code[20]; CO2eEmission: Decimal)
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
    begin
        SustainabilityLedgerEntry.SetRange("Account No.", AccountCode);
        SustainabilityLedgerEntry.FindFirst();

        Assert.AreEqual(
            CO2eEmission,
            SustainabilityLedgerEntry."CO2e Emission",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityLedgerEntry.FieldCaption("CO2e Emission"), CO2eEmission, SustainabilityLedgerEntry.TableCaption()));
    end;

    local procedure VerifySustainabilityValueEntry(ItemNo: Code[20]; CO2eEmissionExpected: Decimal; CO2eEmissionActual: Decimal)
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
    begin
        SustainabilityValueEntry.SetRange("Item No.", ItemNo);
        SustainabilityValueEntry.FindFirst();

        Assert.AreEqual(
            CO2eEmissionExpected,
            SustainabilityValueEntry."CO2e Amount (Expected)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Expected)"), CO2eEmissionExpected, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            CO2eEmissionActual,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), CO2eEmissionActual, SustainabilityValueEntry.TableCaption()));
    end;

    local procedure CreateItemWithInventory(var Item: Record Item; FromLocationCode: Code[10])
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        LibraryInventory.CreateItem(Item);
        LibraryInventory.CreateItemJournalLineInItemTemplate(ItemJournalLine, Item."No.", FromLocationCode, '', LibraryRandom.RandIntInRange(100, 200));
        LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
    end;

    local procedure CreateTransferOrderWithLocation(var TransferHeader: Record "Transfer Header"; Item: Record Item; FromLocationCode: Code[10]; ToLocationCode: Code[10]; IntransitLocationCode: Code[10]; Quantity: Decimal; CO2PerUnit: Decimal)
    var
        TransferLine: Record "Transfer Line";
    begin
        LibraryWarehouse.CreateTransferHeader(TransferHeader, FromLocationCode, ToLocationCode, IntransitLocationCode);

        LibraryWarehouse.CreateTransferLine(TransferHeader, TransferLine, Item."No.", Quantity);
        TransferLine.Validate("CO2e per Unit", CO2PerUnit);
        TransferLine.Modify();
    end;

    local procedure GetTransferLine(TransferHeader: Record "Transfer Header"; var TransferLine: Record "Transfer Line")
    begin
        TransferLine.SetRange("Document No.", TransferHeader."No.");
        TransferLine.FindSet();
    end;

    local procedure GetTransferShipmentHeader(var TransferShipmentHeader: Record "Transfer Shipment Header"; FromLocationCode: Code[10])
    begin
        TransferShipmentHeader.SetRange("Transfer-from Code", FromLocationCode);
        TransferShipmentHeader.FindSet();
    end;

    local procedure GetTransferShipmentLine(var TransferShipmentLine: Record "Transfer Shipment Line"; ItemNo: Code[20])
    begin
        TransferShipmentLine.SetRange("Item No.", ItemNo);
        TransferShipmentLine.FindSet();
    end;

    local procedure VerifySustainabilityValueEntryForTransferOrder(DocumentNo: Code[20]; CO2ePerUnit: Decimal; CO2eEmission: Decimal)
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
    begin
        SustainabilityValueEntry.SetRange("Document No.", DocumentNo);
        SustainabilityValueEntry.FindFirst();
        Assert.RecordCount(SustainabilityValueEntry, 1);
        Assert.AreEqual(
            CO2ePerUnit,
            SustainabilityValueEntry."CO2e per Unit",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e per Unit"), CO2ePerUnit, SustainabilityValueEntry.TableCaption()));
        Assert.AreEqual(
            CO2eEmission,
            SustainabilityValueEntry."CO2e Amount (Actual)",
            StrSubstNo(ValueMustBeEqualErr, SustainabilityValueEntry.FieldCaption("CO2e Amount (Actual)"), CO2eEmission, SustainabilityValueEntry.TableCaption()));
    end;

    local procedure VerifySustainabilityLedgerEntryForTransferOrder(DocumentNo: Code[20])
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
    begin
        SustainabilityLedgerEntry.SetRange("Document No.", DocumentNo);
        Assert.RecordCount(SustainabilityLedgerEntry, 0);
    end;

    local procedure CreateCorrectiveCreditMemo(PurchaseHeader: Record "Purchase Header"): Code[20]
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
        PurchaseHeader.Modify(true);

        exit(PurchaseHeader."No.");
    end;

    local procedure FindAccountingPeriod(var AccountingPeriod: Record "Accounting Period")
    begin
        AccountingPeriod.SetRange("New Fiscal Year", false);
        AccountingPeriod.SetRange(Closed, false);
        AccountingPeriod.SetRange("Date Locked", false);
        AccountingPeriod.FindFirst();
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

    local procedure CreateAndPostPurchaseDocument(var PurchaseHeader: Record "Purchase Header"; ItemNo: Code[20]; Quantity: Decimal; LocationCode: Code[20]; CountryRegionCode: Code[10]; AccountCode: Code[20]; EmissionCO2PerUnit: Decimal; EmissionCH4PerUnit: Decimal; EmissionN2OPerUnit: Decimal): Code[20]
    var
        PurchaseLine: Record "Purchase Line";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        PurchaseHeader."Buy-from Country/Region Code" := CountryRegionCode;
        PurchaseHeader.Modify();

        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, ItemNo, Quantity);
        PurchaseLine.Validate("Location Code", LocationCode);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 200));
        PurchaseLine.Validate("Sust. Account No.", AccountCode);
        PurchaseLine.Validate("Emission CO2 Per Unit", EmissionCO2PerUnit);
        PurchaseLine.Validate("Emission CH4 Per Unit", EmissionCH4PerUnit);
        PurchaseLine.Validate("Emission N2O Per Unit", EmissionN2OPerUnit);
        PurchaseLine.Modify();

        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
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

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the PurchaseStatistics action. The new action uses RunObject and does not run the action trigger', '26.0')]
    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure PurchaseInvoiceStatisticsPageHandler(var PurchaseStatisticsPage: TestPage "Purchase Statistics")
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

        PurchaseStatisticsPage."Emission C02".AssertEquals(EmissionCO2);
        PurchaseStatisticsPage."Emission CH4".AssertEquals(EmissionCH4);
        PurchaseStatisticsPage."Emission N2O".AssertEquals(EmissionN2O);
        PurchaseStatisticsPage."Posted Emission C02".AssertEquals(PostedEmissionCO2);
        PurchaseStatisticsPage."Posted Emission CH4".AssertEquals(PostedEmissionCH4);
        PurchaseStatisticsPage."Posted Emission N2O".AssertEquals(PostedEmissionN2O);
    end;
#endif

    [PageHandler]
    [Scope('OnPrem')]
    procedure PurchInvoiceStatisticsPageHandler(var PurchaseStatisticsPage: TestPage "Purchase Statistics")
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

        PurchaseStatisticsPage."Emission C02".AssertEquals(EmissionCO2);
        PurchaseStatisticsPage."Emission CH4".AssertEquals(EmissionCH4);
        PurchaseStatisticsPage."Emission N2O".AssertEquals(EmissionN2O);
        PurchaseStatisticsPage."Posted Emission C02".AssertEquals(PostedEmissionCO2);
        PurchaseStatisticsPage."Posted Emission CH4".AssertEquals(PostedEmissionCH4);
        PurchaseStatisticsPage."Posted Emission N2O".AssertEquals(PostedEmissionN2O);
    end;

#if not CLEAN26
    [Obsolete('The statistics action will be replaced with the SalesStatistics action. The new action uses RunObject and does not run the action trigger.', '26.0')]
    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure SalesInvoiceStatisticsPageHandler(var SalesStatisticsPage: TestPage "Sales Statistics")
    var
        TotalCO2e: Variant;
        PostedTotalCO2e: Variant;
    begin
        LibraryVariableStorage.Dequeue(TotalCO2e);
        LibraryVariableStorage.Dequeue(PostedTotalCO2e);

        SalesStatisticsPage."Total CO2e".AssertEquals(TotalCO2e);
        SalesStatisticsPage."Posted Total CO2e".AssertEquals(PostedTotalCO2e);
    end;
#endif
    [PageHandler]
    [Scope('OnPrem')]
    procedure SalesInvoiceSalesStatisticsPageHandler(var SalesStatisticsPage: TestPage "Sales Statistics")
    var
        TotalCO2e: Variant;
        PostedTotalCO2e: Variant;
    begin
        LibraryVariableStorage.Dequeue(TotalCO2e);
        LibraryVariableStorage.Dequeue(PostedTotalCO2e);

        SalesStatisticsPage."Total CO2e".AssertEquals(TotalCO2e);
        SalesStatisticsPage."Posted Total CO2e".AssertEquals(PostedTotalCO2e);
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
    procedure GLPostingPreviewHandlerForSales(var GLPostingPreview: TestPage "G/L Posting Preview")
    begin
        GLPostingPreview.Filter.SetFilter("Table ID", Format(Database::"Sustainability Ledger Entry"));
        GLPostingPreview."No. of Records".AssertEquals('');
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
    procedure NavigateFindEntriesHandlerForSales(var Navigate: TestPage Navigate)
    begin
        Navigate.Filter.SetFilter("Table ID", Format(Database::"Sustainability Ledger Entry"));
        Navigate."No. of Records".AssertEquals('');
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

    [PageHandler]
    [Scope('OnPrem')]
    procedure GLPostingPreviewHandlerForAssemblyOrder(var GLPostingPreview: TestPage "G/L Posting Preview")
    begin
        GLPostingPreview.Filter.SetFilter("Table ID", Format(Database::"Sustainability Value Entry"));
        GLPostingPreview."No. of Records".AssertEquals(2);

        GLPostingPreview.Filter.SetFilter("Table ID", Format(Database::"Sustainability Ledger Entry"));
        GLPostingPreview."No. of Records".AssertEquals('');
        GLPostingPreview.OK().Invoke();
    end;

    [PageHandler]
    [Scope('OnPrem')]

    procedure NavigateFindEntriesHandlerForAssemblyOrder(var Navigate: TestPage Navigate)
    begin
        Navigate.Filter.SetFilter("Table ID", Format(Database::"Sustainability Ledger Entry"));
        Navigate."No. of Records".AssertEquals('');

        Navigate.Filter.SetFilter("Table ID", Format(Database::"Sustainability Value Entry"));
        Navigate."No. of Records".AssertEquals(2);
        Navigate.OK().Invoke();
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure GLPostingPreviewHandlerForTransferOrder(var GLPostingPreview: TestPage "G/L Posting Preview")
    begin
        GLPostingPreview.Filter.SetFilter("Table ID", Format(Database::"Sustainability Value Entry"));
        GLPostingPreview."No. of Records".AssertEquals(1);

        GLPostingPreview.Filter.SetFilter("Table ID", Format(Database::"Sustainability Ledger Entry"));
        GLPostingPreview."No. of Records".AssertEquals('');
        GLPostingPreview.OK().Invoke();
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure NavigateFindEntriesHandlerForTransferOrder(var Navigate: TestPage Navigate)
    begin
        Navigate.Filter.SetFilter("Table ID", Format(Database::"Sustainability Ledger Entry"));
        Navigate."No. of Records".AssertEquals('');

        Navigate.Filter.SetFilter("Table ID", Format(Database::"Sustainability Value Entry"));
        Navigate."No. of Records".AssertEquals(1);
        Navigate.OK().Invoke();
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure TransferOrderPostOptionsHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := LibraryVariableStorage.DequeueInteger();
    end;
}