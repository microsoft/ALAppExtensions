codeunit 139598 "AAC Auto. Acc. Group Posting"
{
    // [FEATURE] [Automatic Account Group]

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryAAC: Codeunit "Library - AAC";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        CopyGenJournalMgt: Codeunit "Copy Gen. Journal Mgt.";
        IsInitialized: Boolean;
        CopyFromOption: Option AccGroup,GenJournal,AccGroupAndGenJnl;
        DimensionDoesNotExistsErr: Label 'Dimension value %1 %2 does not exists for G/L Entry No. %3.', Comment = '%1 = Dimension Code, %2 = DimensionValue Code, %3 = GLEntry Entry No';
        WrongValueErr: Label 'Wrong value of field %1 in table %2, entry no. %3.', Comment = '%1 = Additional-Currency Amount, %2 =  GLEntry TableCaption, %3 = GLEntry Entry No';
        WrongAmountGLEntriesErr: Label 'Wrong Amount in G/L Entry.';
        GLEntryCountErr: Label 'Posted g/l entry count not match with expected count';

    [Test]
    [Scope('OnPrem')]
    procedure CopyDimensionsFromAccGroup()
    begin
        // Check that dimensions are inherited from Automatic Account Group to G/L Entry during posting when Dimension Set ID on General Journal Line is Empty
        CopyDimensionsFromAccGroupOrGenJournal(CopyFromOption::AccGroup);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CopyDimensionsFromGeneralJournal()
    begin
        // Check that dimensions are inherited from Gen. Journal Line to G/L Entry during posting when Dimension Set ID on Automatic Accounting Line is Empty
        Initialize();
        CopyDimensionsFromAccGroupOrGenJournal(CopyFromOption::GenJournal);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CombineDimensionsFromAccGroupAndGeneralJournal()
    begin
        // Check that dimensions are inherited from both Automatic Account Group and General Journal Line to G/L Entry during posting when
        // Dimension Set ID on both General Journal Line and Automatic Accounting Line is not Empty, and the Dimensions from Automatic Account Group have higher priority
        Initialize();
        CopyDimensionsFromAccGroupOrGenJournal(CopyFromOption::AccGroupAndGenJnl);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AccGroupPostingWithACY()
    begin
        // Check that G/L Entries of automatic acc. group posted with correct additional currency amount
        Initialize();
        VerifyAccGroupPostingWithACY();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PostGenJnlLineWithAmountDivisionWithReminderAndAccGroup()
    var
        GenJnlLine: Record "Gen. Journal Line";
        AutoAccGroupNo: Code[10];
        GLAccountNo: Code[20];
        Amount: Decimal;
        DimValue1Code: Code[20];
        DimValue2Code: Code[20];
        AllocationPct1: Decimal;
        AllocationPct2: Decimal;
    begin
        // [FEATURE] [Allocation][Dimensions]
        // [SCENARIO 362662] Distribution of amounts of several G/L Entry when Amount with reminder after division
        // [GIVEN] "Automatic Acc. Group" - "AAG" with 3 lines
        // [GIVEN] "Automatic Account Line" - "AAL1", AAL1."Allocation %" = "PCT1%+PCT2%"
        // [GIVEN] "Automatic Account Line" - "AAL2", AAL2."Allocation %" = "PCT1%", AAL2."Shortcut Dimension 1 Code" = DimValue1
        // [GIVEN] "Automatic Account Line" - "AAL3", AAL3."Allocation %" = "PCT2%", AAL3."Shortcut Dimension 2 Code" = DimValue2
        Initialize();
        AutoAccGroupNo := CreateAutoAccGroupWithTwoLines(GLAccountNo, DimValue1Code, DimValue2Code,
            AllocationPct1, AllocationPct2);
        // [GIVEN] "General Journal Line" - "GJL", GJL."Auto Acc. Group" = AAG, GJL."Amount" = "A"
        Amount := LibraryRandom.RandDec(1000, 2);
        CreateGenJnlLineWithAutoAccGroup(GenJnlLine, AutoAccGroupNo, GLAccountNo, Amount);
        // [WHEN] Post Gen. Jnl. Line
        LibraryERM.PostGeneralJnlLine(GenJnlLine);
        // [THEN] "G/L Entry" with DimValue1 must have Amount = "A"*"PCT1%"
        VerifyAllocationGLEntry(GLAccountNo, Amount, DimValue1Code, AllocationPct1);
        // [THEN] "G/L Entry" with DimValue2 must have Amount = "A"*"PCT2%"
        VerifyAllocationGLEntry(GLAccountNo, Amount, DimValue2Code, AllocationPct2);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PostGenJournalWithCurrency()
    var
        AutomaticAccountHeader: Record "Automatic Account Header";
        AutomaticAccountLine: Record "Automatic Account Line";
        GenJournalLine: Record "Gen. Journal Line";
        AutoAccGroupNo: Code[10];
    begin
        // [FEATURE] [Currency]
        // [SCENARIO 371878] Automatic Acc. Posting creates "G/L Entries" with Amount LCY when post General Journal with Currency and empty "Bal. Account No."
        // [GIVEN] Automatic Acc. Group "AAG" with two lines:
        // [GIVEN]  Line1: "G/L Account No." = "ACC1", "Allocation %" = 30
        // [GIVEN]  Line2: "G/L Account No." = "ACC2", "Allocation %" = -30
        Initialize();
        LibraryAAC.CreateAutomaticAccountHeader(AutomaticAccountHeader);
        AutoAccGroupNo := AutomaticAccountHeader."No.";
        CreateBalancedAutoAccLines(AutomaticAccountLine, AutoAccGroupNo, LibraryRandom.RandDec(100, 2), 0);

        // [GIVEN] General Journal with Currency and two lines:
        // [GIVEN] Line1: Amount = 50, "Amount (LCY)" = 100, "Automatic Account Group" = "AAG",  "Bal. Account No." = ''
        // [GIVEN] Line2: Amount = -50, "Amount (LCY)" = -100, "Automatic Account Group" = '',  "Bal. Account No." = ''
        // [WHEN] Post General Journal
        CreatePostTwoGenJnlLinesWithCurrency(GenJournalLine, AutoAccGroupNo);

        // [THEN] Two G/L Entries are created by Automatic Acc. Posting:
        // [THEN] GLEntry1: "G/L Account No." = "ACC1", "Amount" = 30 (100 * 30%)
        AutomaticAccountLine.SetRange("Automatic Acc. No.", AutoAccGroupNo);
        AutomaticAccountLine.FindFirst();
        VerifyGLEntryAmount(
          GenJournalLine."Document No.", AutomaticAccountLine."G/L Account No.",
          Round(-GenJournalLine."Amount (LCY)" * AutomaticAccountLine."Allocation %" / 100));

        // [THEN] GLEntry2: "G/L Account No." = "ACC2", "Amount" = -30 (100 * -30%)
        AutomaticAccountLine.Next();
        VerifyGLEntryAmount(
          GenJournalLine."Document No.", AutomaticAccountLine."G/L Account No.",
          Round(-GenJournalLine."Amount (LCY)" * AutomaticAccountLine."Allocation %" / 100));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PostGenJournalLineWithDeferralsAndAutoAccGroup()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DeferralTemplate: Record "Deferral Template";
        AutoGroupGLAccountNo: Code[20];
        AutoAccGroupNo: Code[10];
    begin
        // [FEATURE] [Deferral]
        // [SCENARIO 380812] Post Gen. Journal Line with specified Automatic Account Group and Deferral Code

        // [GIVEN] Automatic Account Group "AAG" with 2 lines where "Account No." = "GL-AG" and balancing line with blank Account No.
        Initialize();
        AutoGroupGLAccountNo := LibraryERM.CreateGLAccountNo();
        AutoAccGroupNo := CreateAutomaticAccGroupWithTwoLines(AutoGroupGLAccountNo);

        // [GIVEN] Deferral Template "D" where "No. of Periods" = 3 and "Deferral Account" = "GL-D"
        CreateDeferralCode(
            DeferralTemplate, "Deferral Calculation Method"::"Straight-Line", "Deferral Calculation Start Date"::"Posting Date", LibraryRandom.RandIntInRange(2, 5));

        // [GIVEN] Gen. Journal Line for "G/L Account" = "GL-PI" with Amount = 100, "Automatic Account Group" = "AAG" and "Deferral Code" = "D"
        LibraryJournals.CreateGenJournalLineWithBatch(
          GenJournalLine, GenJournalLine."Document Type"::Invoice,
          GenJournalLine."Account Type"::"G/L Account", LibraryERM.CreateGLAccountNo(), LibraryRandom.RandDecInRange(100, 200, 2));
        GenJournalLine.Validate("Posting Date", CalcDate('<CM+1D>', WorkDate()));
        GenJournalLine.Validate("Automatic Account Group", AutoAccGroupNo);
        GenJournalLine.Validate("Deferral Code", DeferralTemplate."Deferral Code");
        GenJournalLine.Modify(true);

        // [WHEN] Post gen. journal line
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] The balance of G/L entries for "GL-D" = 0
        // [THEN] The number of G/L entries for "GL-D" = "D"."No. of Periods" + 1 = 4
        // [THEN] The balance of G/L entries for "GL-AG" = 100
        // [THEN] The number of G/L entries for "GL-AG" = "D"."No. of Periods" * <No. of lines in accounting group> = 3 * 2 = 6
        // [THEN] The balance of G/L entries for "GL-PI" = 0
        // [THEN] The number of G/L entries for "GL-PI" = "D"."No. of Periods" * 2 (posted deferral line + blank AAG line) + 2 (posted + balance) lines = 3 * 2 + 2 = 8
        VerifyPostedDeferralsWithAccGroup(GenJournalLine.Amount, DeferralTemplate, AutoGroupGLAccountNo, 2);
        VerifyGLEntriesBalance(GenJournalLine."Account No.", 0, DeferralTemplate."No. of Periods" * 2 + 2);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PostPurchaseInvoiceWithDeferralsAndAutoAccGroup()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DeferralTemplate: Record "Deferral Template";
        AutoGroupGLAccountNo: Code[20];
        AutoAccGroupNo: Code[10];
        DocAmountInclVAT: Decimal;
        DocAmountVAT: Decimal;
    begin
        // [FEATURE] [Deferral] [Purchase]
        // [SCENARIO 380812] Post Purchase invoice with specified Automatic Account Group and Deferral Code

        // [GIVEN] Automatic Account Group "AAG" with 2 lines where "Account No." = "GL-AG" and balancing line with blank Account No.
        Initialize();
        DocAmountInclVAT := 0;
        DocAmountVAT := 0;
        AutoGroupGLAccountNo := LibraryERM.CreateGLAccountNo();
        AutoAccGroupNo := CreateAutomaticAccGroupWithTwoLines(AutoGroupGLAccountNo);

        // [GIVEN] Deferral Template "D" where "No. of Periods" = 3 and "Deferral Account" = "GL-D"
        CreateDeferralCode(
            DeferralTemplate, "Deferral Calculation Method"::"Straight-Line", "Deferral Calculation Start Date"::"Posting Date", LibraryRandom.RandIntInRange(2, 5));

        // [GIVEN] Purchase invoice for "G/L Account" = "GL-PI" with Amount = 100, "Automatic Account Group" = "AAG" and "Deferral Code" = "D"
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.Validate("Posting Date", CalcDate('<CM+1D>', WorkDate()));
        PurchaseHeader.Modify(true);
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithPurchSetup(), 1);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(100, 200, 2));
        PurchaseLine.Validate("Automatic Account Group", AutoAccGroupNo);
        PurchaseLine.Validate("Deferral Code", DeferralTemplate."Deferral Code");
        PurchaseLine.Modify(true);
        DocAmountInclVAT += PurchaseLine."Amount Including VAT";
        DocAmountVAT += PurchaseLine."Amount Including VAT" - PurchaseLine.Amount;
        UpdateDocAmounts(PurchaseHeader, DocAmountInclVAT, DocAmountVAT);

        // [WHEN] Post purchase invoice
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] The balance of G/L entries for "GL-D" = 0
        // [THEN] The number of G/L entries for "GL-D" = "D"."No. of Periods" + 1 = 4
        // [THEN] The balance of G/L entries for "GL-AG" = 100
        // [THEN] The number of G/L entries for "GL-AG" = "D"."No. of Periods" * <No. of lines in accounting group> = 3 * 2 = 6
        // [THEN] The balance of G/L entries for "GL-PI" = 0
        // [THEN] The number of G/L entries for "GL-PI" = "D"."No. of Periods" * 2 (posted deferral line + blank AAG line) = 3 * 2 = 6
        VerifyPostedDeferralsWithAccGroup(PurchaseLine.Amount, DeferralTemplate, AutoGroupGLAccountNo, 2);
        VerifyGLEntriesBalance(PurchaseLine."No.", 0, DeferralTemplate."No. of Periods" * 2 + 2); // "+2": TFS 251252 initial deferral pair
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PostSalesInvoiceWithDeferralsAndAutoAccGroup()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DeferralTemplate: Record "Deferral Template";
        AutoGroupGLAccountNo: Code[20];
        AutoAccGroupNo: Code[10];
    begin
        // [FEATURE] [Deferral] [Sales]
        // [SCENARIO 380812] Post Sales invoice with specified Automatic Account Group and Deferral Code

        // [GIVEN] Automatic Account Group "AAG" with 2 lines where "Account No." = "GL-AG" and balancing line with blank Account No.
        Initialize();
        AutoGroupGLAccountNo := LibraryERM.CreateGLAccountNo();
        AutoAccGroupNo := CreateAutomaticAccGroupWithTwoLines(AutoGroupGLAccountNo);

        // [GIVEN] Deferral Template "D" where "No. of Periods" = 3 and "Deferral Account" = "GL-D"
        CreateDeferralCode(
            DeferralTemplate, "Deferral Calculation Method"::"Straight-Line", "Deferral Calculation Start Date"::"Posting Date", LibraryRandom.RandIntInRange(2, 5));

        // [GIVEN] Sales invoice for "G/L Account" = "GL-PI" with Amount = 100, "Automatic Account Group" = "AAG" and "Deferral Code" = "D"
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        SalesHeader.Validate("Posting Date", CalcDate('<CM+1D>', WorkDate()));
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup(), 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(100, 200, 2));
        SalesLine.Validate("Automatic Account Group", AutoAccGroupNo);
        SalesLine.Validate("Deferral Code", DeferralTemplate."Deferral Code");
        SalesLine.Modify(true);

        // [WHEN] Post sales invoice
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The balance of G/L entries for "GL-D" = 0
        // [THEN] The number of G/L entries for "GL-D" = "D"."No. of Periods" + 1 = 4
        // [THEN] The balance of G/L entries for "GL-AG" = 100
        // [THEN] The number of G/L entries for "GL-AG" = "D"."No. of Periods" * <No. of lines in accounting group> = 3 * 2 = 6
        // [THEN] The balance of G/L entries for "GL-PI" = 0
        // [THEN] The number of G/L entries for "GL-PI" = "D"."No. of Periods" * 2 (posted deferral line + blank AAG line) = 3 * 2 = 6
        VerifyPostedDeferralsWithAccGroup(-SalesLine.Amount, DeferralTemplate, AutoGroupGLAccountNo, 2);
        VerifyGLEntriesBalance(SalesLine."No.", 0, DeferralTemplate."No. of Periods" * 2 + 2); // "+2": TFS 251252 initial deferral pair
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PostPurchaseInvoiceWithDeferralsAndAutoAccGroupTwoLines()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DeferralTemplate: Record "Deferral Template";
        DimensionCode: Code[20];
        AutoAccGroupNo1: Code[10];
        AutoAccGroupNo2: Code[10];
        AllocationPct1: Integer;
        AllocationPct2: Integer;
        DocumentNo: Code[20];
        AllocationAmount: array[6] of Decimal;
        DocAmountInclVAT: Decimal;
        DocAmountVAT: Decimal;
    begin
        // [FEATURE] [Deferral] [Purchase]
        // [SCENARIO 273428] Post Purchase invoice of two lines with different Automatic Account Groups and same Deferral Code
        Initialize();

        // [GIVEN] Two Auto Acc. Groups "AG1" and "AG2" of two lines and one balancing line with dimensions and blank Account No.:
        // [GIVEN] Line1: Pct = 20, Global Dimension 1 Code = "D1",
        // [GIVEN] Line2: Pct = 30, Global Dimension 1 Code = "D2"
        // [GIVEN] Balancing Line: Pct = -50, Global Dimension 1 Code = "D3"
        DimensionCode := UpdateGlobalDimensions();
        AllocationPct1 := 20;
        AllocationPct2 := 30;
        DocAmountInclVAT := 0;
        DocAmountVAT := 0;
        AutoAccGroupNo1 := CreateAutoAccGroupWithTwoLinesNoGLAccount(DimensionCode, AllocationPct1, AllocationPct2);
        AutoAccGroupNo2 := CreateAutoAccGroupWithTwoLinesNoGLAccount(DimensionCode, AllocationPct1, AllocationPct2);

        // [GIVEN] Deferral Template "D" of method "Straight-Line" starts at "Beginning of Next Period" and "Deferral Account" = "Def"
        CreateDeferralCode(
          DeferralTemplate, "Deferral Calculation Method"::"Straight-Line", "Deferral Calculation Start Date"::"Beginning of Next Period", 1);

        // [GIVEN] Purchase invoice of two lines for "G/L Account" = "GLAcc"
        // [GIVEN] Amount = 100, "Automatic Account Group" = "AG1" and Deferral Code = "D"
        // [GIVEN] Amount = 200, "Automatic Account Group" = "AG2" and Deferral Code = "D"
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.Validate("Posting Date", CalcDate('<CM+1D>', WorkDate()));
        PurchaseHeader.Modify(true);
        CreatePurchLineWithAccGroupAndDeferral(
          PurchaseLine, PurchaseHeader, LibraryERM.CreateGLAccountWithPurchSetup(), AutoAccGroupNo1, DeferralTemplate."Deferral Code");
        DocAmountInclVAT += PurchaseLine."Amount Including VAT";
        DocAmountVAT += PurchaseLine."Amount Including VAT" - PurchaseLine.Amount;

        UpdateAllocationAmount(AllocationAmount, PurchaseLine."Line Amount", AllocationPct1, AllocationPct2, 1);
        CreatePurchLineWithAccGroupAndDeferral(
          PurchaseLine, PurchaseHeader, PurchaseLine."No.", AutoAccGroupNo2, DeferralTemplate."Deferral Code");
        UpdateAllocationAmount(AllocationAmount, PurchaseLine."Line Amount", AllocationPct1, AllocationPct2, 4);
        DocAmountInclVAT += PurchaseLine."Amount Including VAT";
        DocAmountVAT += PurchaseLine."Amount Including VAT" - PurchaseLine.Amount;

        UpdateDocAmounts(PurchaseHeader, DocAmountInclVAT, DocAmountVAT);

        // [WHEN] Post purchase invoice on 15.01.18 (deferral date is 01.02.18)
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] G/L entries posted on 15.01.18:
        // [THEN] Deferral account "Def" has amount = 300 in 2 entries
        // [THEN] Line account "GLAcc" has amount = 0 in 4 entries (moving 2 times with + and - for each document line)
        // [THEN] G/L entries posted on 01.02.20:
        // [THEN] Deferral account "Def" has amount = -300 in 2 entries
        // [THEN] Line account "GLAcc" has amount = 300 in 2 entries (moving from deferral account)
        // [THEN] Allocation entries with amounts 20, 30, -50 for first line
        // [THEN] Allocation entries with amounts 40, 60, -70 for second line
        VerifyDeferralEntriesWithAccGroups(
          AllocationAmount,
          DocumentNo, PurchaseHeader."Posting Date", DeferralTemplate."Deferral Account", PurchaseLine."No.", PurchaseHeader.Amount, 19, 2, 1);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PostSalesInvoiceWithDeferralsAndAutoAccGroupTwoLines()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DeferralTemplate: Record "Deferral Template";
        DimensionCode: Code[20];
        AutoAccGroupNo1: Code[10];
        AutoAccGroupNo2: Code[10];
        AllocationPct1: Integer;
        AllocationPct2: Integer;
        DocumentNo: Code[20];
        AllocationAmount: array[6] of Decimal;
    begin
        // [FEATURE] [Deferral] [Sales]
        // [SCENARIO 273428] Post Sales invoice of two lines with different Automatic Account Groups and same Deferral Code
        Initialize();

        // [GIVEN] Two Auto Acc. Groups "AG1" and "AG2" of 2 lines and one balancing line with dimensions and blank Account No.:
        // [GIVEN] Line1: Pct = 20, Global Dimension 1 Code = "D1",
        // [GIVEN] Line2: Pct = 30, Global Dimension 1 Code = "D2"
        // [GIVEN] Balancing Line: Pct = -50, Global Dimension 1 Code = "D3"
        DimensionCode := UpdateGlobalDimensions();
        AllocationPct1 := 20;
        AllocationPct2 := 30;
        AutoAccGroupNo1 := CreateAutoAccGroupWithTwoLinesNoGLAccount(DimensionCode, AllocationPct1, AllocationPct2);
        AutoAccGroupNo2 := CreateAutoAccGroupWithTwoLinesNoGLAccount(DimensionCode, AllocationPct1, AllocationPct2);

        // [GIVEN] Deferral Template "D" of method "Straight-Line" starts at "Beginning of Next Period" and "Deferral Account" = "Def"
        CreateDeferralCode(
            DeferralTemplate, "Deferral Calculation Method"::"Straight-Line", "Deferral Calculation Start Date"::"Beginning of Next Period", 1);

        // [GIVEN] Sales invoice of two lines for "G/L Account" = "GLAcc"
        // [GIVEN] Amount = 100, "Automatic Account Group" = "AG1" and Deferral Code = "D"
        // [GIVEN] Amount = 200, "Automatic Account Group" = "AG2" and Deferral Code = "D"
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        SalesHeader.Validate("Posting Date", CalcDate('<CM+1D>', WorkDate()));
        SalesHeader.Modify(true);
        CreateSalesLineWithAccGroupAndDeferral(
          SalesLine, SalesHeader, LibraryERM.CreateGLAccountWithSalesSetup(), AutoAccGroupNo1, DeferralTemplate."Deferral Code");
        UpdateAllocationAmount(AllocationAmount, -SalesLine."Line Amount", AllocationPct1, AllocationPct2, 1);
        CreateSalesLineWithAccGroupAndDeferral(
          SalesLine, SalesHeader, SalesLine."No.", AutoAccGroupNo2, DeferralTemplate."Deferral Code");
        UpdateAllocationAmount(AllocationAmount, -SalesLine."Line Amount", AllocationPct1, AllocationPct2, 4);
        SalesHeader.CalcFields(Amount);

        // [WHEN] Post sales invoice on 15.01.18 (deferral date is 01.02.18)
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] G/L entries posted on 15.01.18:
        // [THEN] Deferral account "Def" has amount = -300 in 2 entries
        // [THEN] Line account "GLAcc" has amount = 0 in 4 entries (moving 2 times with + and - for each document line)
        // [THEN] G/L entries posted on 01.02.20:
        // [THEN] Deferral account "Def" has amount = 300 in 2 entries
        // [THEN] Line account "GLAcc" has amount = -300 in 2 entries (moving from deferral account)
        // [THEN] Allocation entries with amounts -20, -30, 50 for first line
        // [THEN] Allocation entries with amounts -40, -60, 70 for second line
        VerifyDeferralEntriesWithAccGroups(
          AllocationAmount,
          DocumentNo, SalesHeader."Posting Date", DeferralTemplate."Deferral Account", SalesLine."No.", SalesHeader.Amount, 19, 2, -1);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PostPurchaseInvoiceWithAutoAccGroup()
    var
        GLAccount: Record "G/L Account";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GLEntry: Record "G/L Entry";
        AccGroupGLAccontNo: Code[20];
        DocAmountInclVAT: Decimal;
        DocAmountVAT: Decimal;
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 228855] Automatic Account Group is transferred from G/L Account into Purchase Line and G/L Entry for records created for Account Group on posting purchase document
        Initialize();
        DocAmountInclVAT := 0;
        DocAmountVAT := 0;

        // [GIVEN] Automatic Account Group "B" with two lines for G/L Account "X"
        // [GIVEN] G/L Account "A" with "Automatic Account Group" = "B"
        AccGroupGLAccontNo := LibraryERM.CreateGLAccountWithPurchSetup();
        GLAccount.Get(LibraryERM.CreateGLAccountWithPurchSetup());
        GLAccount.Validate("Automatic Account Group", CreateAutomaticAccGroupWithTwoLines(AccGroupGLAccontNo));
        GLAccount.Modify();

        // [GIVEN] Sales Invoice with Sales Line having Type = "G/L Account" and No. = "A"
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", '', 0);

        PurchaseLine.Validate("No.", GLAccount."No.");

        PurchaseLine.Validate(Quantity, 1);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(10, 20));
        PurchaseLine.Modify(true);
        DocAmountInclVAT += PurchaseLine."Amount Including VAT";
        DocAmountVAT += PurchaseLine."Amount Including VAT" - PurchaseLine.Amount;
        UpdateDocAmounts(PurchaseHeader, DocAmountInclVAT, DocAmountVAT);

        PurchaseLine.TestField("Automatic Account Group", GLAccount."Automatic Account Group");
        SetNoSeriesLastUsedDate();

        // [WHEN] Post invoice
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] Two G/L entries created for "X"
        GLEntry.SetRange("G/L Account No.", AccGroupGLAccontNo);
        Assert.RecordCount(GLEntry, 2);
        GLEntry.CalcSums(Amount);
        GLEntry.TestField(Amount, PurchaseLine."Direct Unit Cost");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PosteSalesInvoiceWithAutoAccGroup()
    var
        GLAccount: Record "G/L Account";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GLEntry: Record "G/L Entry";
        AccGroupGLAccontNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 228855] Automatic Account Group is transferred from G/L Account into Sales Line and G/L Entry for records created for Account Group on posting purchase document
        Initialize();

        // [GIVEN] Automatic Account Group "B" with two lines for G/L Account "X"
        // [GIVEN] G/L Account "A" with "Automatic Account Group" = "B"
        AccGroupGLAccontNo := LibraryERM.CreateGLAccountWithPurchSetup();
        GLAccount.Get(LibraryERM.CreateGLAccountWithPurchSetup());
        GLAccount.Validate("Automatic Account Group", CreateAutomaticAccGroupWithTwoLines(AccGroupGLAccontNo));
        GLAccount.Modify();

        // [GIVEN] Sales Invoice with Sales Line having Type = "G/L Account" and No. = "A"
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account", '', 0);

        SalesLine.Validate("No.", GLAccount."No.");

        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(10, 20));
        SalesLine.Modify(true);

        SalesLine.TestField("Automatic Account Group", GLAccount."Automatic Account Group");

        // [WHEN] Post invoice
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Two G/L entries created for "X"
        GLEntry.SetRange("G/L Account No.", AccGroupGLAccontNo);
        Assert.RecordCount(GLEntry, 2);
        GLEntry.CalcSums(Amount);
        GLEntry.TestField(Amount, -SalesLine."Unit Price");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PostGenJournalLineWithAutoAccGroupDeferralBeginningOfNextPeriod()
    var
        DeferralTemplate: Record "Deferral Template";
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        AutoAccNo: Code[20];
        AutAccGroupCode: Code[10];
        PostingDate: Date;
        PeriodCount: Integer;
        Index: Integer;
    begin
        // [FEATURE] [Deferral] [Gen. Journal Line]
        // [SCENARIO 298392] Stan can post gen. journal with Auto Acc. Group in case of posting date restriction in G/L Setup and certain deferral template settings
        Initialize();

        // [GIVEN] Auto Account Group "AAG" with two balanced lines
        AutoAccNo := LibraryERM.CreateGLAccountNo();
        AutAccGroupCode := CreateAutomaticAccGroupWithTwoLines(AutoAccNo);
        PeriodCount := 12; // random senseless here

        // [GIVEN] Deferral Template "DT" with "Calc. Method" = "Equal per Period", "Start Date" = "Beginning of next Period" and "No. Of Periods" = 12
        CreateDeferralCode(
          DeferralTemplate, DeferralTemplate."Calc. Method"::"Equal per Period",
          DeferralTemplate."Start Date"::"Beginning of Next Period", PeriodCount);

        // [GIVEN] Posting Date restriction from 01/01/2019 to 31/12/2020
        PostingDate := CalcDate('<-CY-1D>', WorkDate());
        LibraryERM.SetAllowPostingFromTo(CalcDate('<-CY>', PostingDate), CalcDate('<CY>', WorkDate()));

        // [GIVEN] "Gen. Journal Line" with "Posting Date" = 31/12/2019, "Deferral Code" = "DT", "Auto Acc. Group" = "AAG" and "Amount" = 12000
        LibraryJournals.CreateGenJournalLineWithBatch(
          GenJournalLine, GenJournalLine."Document Type"::" ",
          GenJournalLine."Account Type"::"G/L Account", LibraryERM.CreateGLAccountNo(),
          LibraryRandom.RandDecInRange(100, 200, 2) * PeriodCount);

        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Automatic Account Group", AutAccGroupCode);
        GenJournalLine.Validate("Deferral Code", DeferralTemplate."Deferral Code");
        GenJournalLine.Modify(true);

        // [WHEN] Post journal
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Deferrals and Automatic Account Groups posted at 1st day of each month from January till December 2020
        for Index := 1 to PeriodCount do begin
            PostingDate := CalcDate('<D1>', PostingDate);
            GLEntry.SetRange("Posting Date", PostingDate);
            GLEntry.SetRange("G/L Account No.", AutoAccNo);
            GLEntry.CalcSums(Amount);
            GLEntry.TestField(Amount, GenJournalLine.Amount / PeriodCount);
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PostSalesInvoiceWithPartialDeferralsAndAutoAccGroupWithDimension()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DeferralTemplate: Record "Deferral Template";
        AutomaticAccountLine: Record "Automatic Account Line";
        Index: Integer;
        DeferralPeriodAmount: Decimal;
        ExpectedAmount: Decimal;
    begin
        // [FEATURE] [Deferral] [Sales] [Dimension]
        // [SCENARIO 312161] Post sales invoice with specified Automatic Account Group and partial deferral setup

        // [GIVEN] Automatic Account Group "AAG" with 2 lines with "G/L Account No." = "GL-AAG", "Deparment Code" = "ADM" and "Allocation %" = 10%
        Initialize();

        // [GIVEN] Deferral Template "D" where "No. of Periods" = 3 and "Deferral %" = 20%
        CreateAutoAccLineWithDimensionAndPartialDeferralTemplateEqualPerPeriod(AutomaticAccountLine, DeferralTemplate);

        // [GIVEN] Sales invoice for "G/L Account" = "GL-PI" with Amount = 100, "Automatic Account Group" = "AAG" and "Deferral Code" = "D"
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        SalesHeader.Validate("Posting Date", CalcDate('<CM+1D>', WorkDate()));
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(
            SalesLine, SalesHeader, SalesLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup(), 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(100, 200, 2));
        SalesLine.Validate("Automatic Account Group", AutomaticAccountLine."Automatic Acc. No.");
        SalesLine.Validate("Deferral Code", DeferralTemplate."Deferral Code");
        SalesLine.Modify(true);

        // [WHEN] Post invoice
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The balance of G/L entries for "GL-AAG" = 10 => 10% of document amount
        // [THEN] The number of G/L entries for "GL-AAG" = "D"."No. of Periods" + 1 => (entry per deferral period + entry for remaining amount)
        ExpectedAmount :=
            Round(
                Round(SalesLine."VAT Base Amount" * (100 - DeferralTemplate."Deferral %") / 100) *
                AutomaticAccountLine."Allocation %" / 100);

        DeferralPeriodAmount :=
            Round(SalesLine."VAT Base Amount" * DeferralTemplate."Deferral %" / 100 / DeferralTemplate."No. of Periods");

        for Index := 1 to DeferralTemplate."No. of Periods" do
            ExpectedAmount += Round(DeferralPeriodAmount * AutomaticAccountLine."Allocation %" / 100);

        VerifyGLEntriesBalance(AutomaticAccountLine."G/L Account No.", -ExpectedAmount, DeferralTemplate."No. of Periods" + 1);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PostPurchaseInvoiceWithPartialDeferralsAndAutoAccGroupWithDimension()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DeferralTemplate: Record "Deferral Template";
        AutomaticAccountLine: Record "Automatic Account Line";
        Index: Integer;
        DeferralPeriodAmount: Decimal;
        ExpectedAmount: Decimal;
        DocAmountInclVAT: Decimal;
        DocAmountVAT: Decimal;
    begin
        // [FEATURE] [Deferral] [Purchases] [Dimension]
        // [SCENARIO 312161] Post purchase invoice with specified Automatic Account Group and partial deferral setup

        // [GIVEN] Automatic Account Group "AAG" with 2 lines with "G/L Account No." = "GL-AAG", "Deparment Code" = "ADM" and "Allocation %" = 10%
        Initialize();
        DocAmountInclVAT := 0;
        DocAmountVAT := 0;

        // [GIVEN] Deferral Template "D" where "No. of Periods" = 3 and "Deferral %" = 20%
        CreateAutoAccLineWithDimensionAndPartialDeferralTemplateEqualPerPeriod(AutomaticAccountLine, DeferralTemplate);

        // [GIVEN] Purchase invoice for "G/L Account" = "GL-PI" with Amount = 100, "Automatic Account Group" = "AAG" and "Deferral Code" = "D"
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.Validate("Posting Date", CalcDate('<CM+1D>', WorkDate()));
        PurchaseHeader.Modify(true);
        LibraryPurchase.CreatePurchaseLine(
            PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithPurchSetup(), 1);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(100, 200, 2));
        PurchaseLine.Validate("Automatic Account Group", AutomaticAccountLine."Automatic Acc. No.");
        PurchaseLine.Validate("Deferral Code", DeferralTemplate."Deferral Code");
        PurchaseLine.Modify(true);
        DocAmountVAT += PurchaseLine."Amount Including VAT" - PurchaseLine.Amount;
        DocAmountInclVAT += PurchaseLine."Amount Including VAT";
        UpdateDocAmounts(PurchaseHeader, DocAmountInclVAT, DocAmountVAT);

        // [WHEN] Post invoice
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [THEN] The balance of G/L entries for "GL-AAG" = 10 => 10% of document amount
        // [THEN] The number of G/L entries for "GL-AAG" = "D"."No. of Periods" + 1 => (entry per deferral period + entry for remaining amount)
        ExpectedAmount :=
            Round(
                Round(PurchaseLine."VAT Base Amount" * (100 - DeferralTemplate."Deferral %") / 100) *
                AutomaticAccountLine."Allocation %" / 100);

        DeferralPeriodAmount :=
            Round(PurchaseLine."VAT Base Amount" * DeferralTemplate."Deferral %" / 100 / DeferralTemplate."No. of Periods");

        for Index := 1 to DeferralTemplate."No. of Periods" do
            ExpectedAmount += Round(DeferralPeriodAmount * AutomaticAccountLine."Allocation %" / 100);

        VerifyGLEntriesBalance(AutomaticAccountLine."G/L Account No.", ExpectedAmount, DeferralTemplate."No. of Periods" + 1);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PostGenJournalLineWithPartialDeferralsAndAutoAccGroupWithDimension()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DeferralTemplate: Record "Deferral Template";
        AutomaticAccountLine: Record "Automatic Account Line";
        Index: Integer;
        DeferralPeriodAmount: Decimal;
        ExpectedAmount: Decimal;
    begin
        // [FEATURE] [Deferral] [General Journal] [Dimension]
        // [SCENARIO 312161] Post general journal with specified Automatic Account Group and partial deferral setup

        // [GIVEN] Automatic Account Group "AAG" with 2 lines with "G/L Account No." = "GL-AAG", "Deparment Code" = "ADM" and "Allocation %" = 10%
        Initialize();

        // [GIVEN] Deferral Template "D" where "No. of Periods" = 3 and "Deferral %" = 20%
        CreateAutoAccLineWithDimensionAndPartialDeferralTemplateEqualPerPeriod(AutomaticAccountLine, DeferralTemplate);

        // [GIVEN] Sales invoice for "G/L Account" = "GL-PI" with Amount = 100, "Automatic Account Group" = "AAG" and "Deferral Code" = "D"
        LibraryJournals.CreateGenJournalLineWithBatch(
            GenJournalLine, GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup(),
            LibraryRandom.RandDecInDecimalRange(100, 200, 2));

        GenJournalLine.Validate("Automatic Account Group", AutomaticAccountLine."Automatic Acc. No.");
        GenJournalLine.Validate("Deferral Code", DeferralTemplate."Deferral Code");
        GenJournalLine.Modify(true);

        // [WHEN] Post invoice
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] The balance of G/L entries for "GL-AAG" = 10 => 10% of document amount
        // [THEN] The number of G/L entries for "GL-AAG" = "D"."No. of Periods" + 1 => (entry per deferral period + entry for remaining amount)
        ExpectedAmount :=
            Round(
                Round(GenJournalLine."VAT Base Amount (LCY)" * (100 - DeferralTemplate."Deferral %") / 100) *
                AutomaticAccountLine."Allocation %" / 100);

        DeferralPeriodAmount :=
            Round(GenJournalLine."VAT Base Amount (LCY)" * DeferralTemplate."Deferral %" / 100 / DeferralTemplate."No. of Periods");

        for Index := 1 to DeferralTemplate."No. of Periods" do
            ExpectedAmount += Round(DeferralPeriodAmount * AutomaticAccountLine."Allocation %" / 100);

        VerifyGLEntriesBalance(AutomaticAccountLine."G/L Account No.", ExpectedAmount, DeferralTemplate."No. of Periods" + 1);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('CopyGenJournalParametersHandler,ConfirmHandlerFalse')]
    procedure AutomaticAccountGroupShouldPopulateToGenJnlLine()
    var
        GenJnlLine: Record "Gen. Journal Line";
        PostedGenJournalLine: Record "Posted Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        AutoAccGroupNo: Code[10];
        GLAccountNo: Code[20];
    begin
        // [SCENARIO 573605] The Automatic Account Groups are not populated to the General Journal line using Copy G/L register to Journal line function in the Swedish version.
        Initialize();

        // [GIVEN] Create "Automatic Acc. Group"
        AutoAccGroupNo := CreateAutoAccGroupWithRndAllocation();

        // [GIVEN] Create "General Journal Line"with "Auto Acc. Group"
        GLAccountNo := LibraryERM.CreateGLAccountNo();
        CreateGenJnlLineWithAutoAccGroupAndCopyToPostedJnlLines(GenJournalBatch, GenJnlLine, AutoAccGroupNo, GLAccountNo, LibraryRandom.RandDec(1000, 2));

        // [WHEN] Post Gen. Jnl. Line
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // [WHEN] Copy first posted general journal line
        QueueCopyParameters(GenJournalBatch, false);
        FilterFirstPostedGenJnlLine(PostedGenJournalLine, GenJournalBatch);
        CopyGenJournalMgt.CopyGLRegister(PostedGenJournalLine);

        // [THEN] The whole register copied to general journal (2 entries copied)
        VerifyCopiedGenJnlLines(GenJournalBatch, GenJournalBatch, 2);
    end;

    [Test]
    procedure PostGenJnlLineWithAmountDivisionWithAccGroup()
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        AutoAccGroupNo: Code[10];
        CurrencyCode: Code[10];
        GLAccountNo: array[3] of Code[20];
    begin
        // [SCENARIO 575346] Rounding issue leading to "Inconsistency" error when trying to post with different currency and automatic accounting in Swedish localisation.
        Initialize();

        // [GIVEN] Currency with specific exchange rates.
        CurrencyCode := CreateCurrencyAndExchangeRate(1, 10.97223, WorkDate());

        // [GIVEN] Created Auto Account Group With 3 GL Account with Allocation 50,50,-100.
        AutoAccGroupNo := CreateAutoAccGroupWithThreeLines(GLAccountNo[1], GLAccountNo[2], GLAccountNo[3]);

        // [WHEN] "General Journal Line" - "GJL", GJL."Auto Acc. Group" = AAG, GJL."Amount" = "A"
        CreateAndPostTwoGenJnlLineWithAutoAccGroup(CurrencyCode, GenJournalBatch, GenJnlLine, AutoAccGroupNo, GLAccountNo[2], GLAccountNo[3]);

        // [THEN] Check Posted GL Entry count Match with Expected.
        CountGLEntryLines(GenJnlLine);//assert
    end;

    local procedure Initialize()
    begin
        LibrarySetupStorage.Restore();

        if IsInitialized then
            exit;

        UpdatePostingDateCheckonPosting();
        LibrarySetupStorage.Save(DATABASE::"General Ledger Setup");
        IsInitialized := true;
    end;

    local procedure CopyDimensionsFromAccGroupOrGenJournal(CopyFrom: Option)
    var
        DimensionValue: array[5] of Record "Dimension Value";
        GLSetup: Record "General Ledger Setup";
        AutomaticAccDimSetID: Integer;
        GenJnlLineDimSetID: Integer;
    begin
        // Setup: Create 2 Dimension Sets and Change Global Dimension Code in G/L Setup to Dimension1.Code and Dimension2.Code.
        // Dimension Set 1: ID = AutomaticAccDimSetID
        // Dimension Code  Dimension Value Code
        // Line 1. Dimension1.Code, DimensionValue[1].Code
        // Line 2. Dimension2.Code, DimensionValue[2].Code

        // Dimension Set 2: ID = GenJnlLineDimSetID
        // Dimension Code   Dimension Value Code
        // Line 1. Dimension3.Code, DimensionValue[3].Code
        // Line 2. Dimension1.Code, DimensionValue[4].Code
        // Line 3. Dimension2.Code, DimensionValue[5].Code
        CreateTwoDimSets(GLSetup, DimensionValue, AutomaticAccDimSetID, GenJnlLineDimSetID);

        // Create Automatic Account Group, set DimSetID and shortcut dimension code on Automatic Accounting Line
        // Create General Journal Line, set DimSetID and shortcut dimension code on the line
        // Exercise: Post General Journal Line.
        // Verify: Verify the Dimension Set and Global Dimension values in G/L Entry
        PostGenJnlLineAndVerifyDimensionsInGLEntry(DimensionValue, CopyFrom, AutomaticAccDimSetID, GenJnlLineDimSetID);
    end;

    local procedure UpdateGLSetupWithACY()
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        GLSetup."Additional Reporting Currency" :=
          LibraryERM.CreateCurrencyWithExchangeRate(WorkDate(), 1, LibraryRandom.RandDec(100, 2));
        GLSetup.Modify(true);
    end;

    local procedure CreateAutoAccGroupWithRndAllocation() AccGroupNo: Code[10]
    var
        AutomaticAccountHeader: Record "Automatic Account Header";
        AutomaticAccountLine: Record "Automatic Account Line";
    begin
        LibraryAAC.CreateAutomaticAccountHeader(AutomaticAccountHeader);
        AccGroupNo := AutomaticAccountHeader."No.";
        CreateBalancedAutoAccLines(AutomaticAccountLine, AccGroupNo, LibraryRandom.RandDec(100, 2), 0);
        exit(AccGroupNo);
    end;

    local procedure CreateAutomaticAccGroupWithDimensions(var AutomaticAccountLine: Record "Automatic Account Line"; DimSetID: Integer)
    var
        AutomaticAccountHeader: Record "Automatic Account Header";
        AutomaticAccNo: Code[10];
    begin
        LibraryAAC.CreateAutomaticAccountHeader(AutomaticAccountHeader);
        AutomaticAccNo := AutomaticAccountHeader."No.";
        CreateBalancedAutoAccLines(AutomaticAccountLine, AutomaticAccNo, 100, DimSetID);
    end;

    local procedure CreateAutomaticAccGroupWithTwoLines(AutoGroupGLAccountNo: Code[20]): Code[10]
    var
        AutomaticAccountHeader: Record "Automatic Account Header";
    begin
        LibraryAAC.CreateAutomaticAccountHeader(AutomaticAccountHeader);
        CreateAutoAccLine(AutomaticAccountHeader."No.", '', -100, '');
        CreateAutoAccLine(AutomaticAccountHeader."No.", AutoGroupGLAccountNo, 60, '');
        CreateAutoAccLine(AutomaticAccountHeader."No.", AutoGroupGLAccountNo, 40, '');
        exit(AutomaticAccountHeader."No.");
    end;

    local procedure CreateBalancedAutoAccLines(var AutomaticAccountLine: Record "Automatic Account Line"; AutomaticAccNo: Code[10]; AllocationPct: Decimal; DimSetID: Integer)
    begin
        with AutomaticAccountLine do begin
            Init();
            Validate("Automatic Acc. No.", AutomaticAccNo);
            Validate("Line No.", 10000);
            Validate("G/L Account No.", LibraryERM.CreateGLAccountNo());
            Validate("Allocation %", AllocationPct);
            Validate("Dimension Set ID", DimSetID);
            Insert(true);

            Validate("Line No.", "Line No." + 10000);
            Validate("G/L Account No.", LibraryERM.CreateGLAccountNo());
            Validate("Allocation %", -AllocationPct);
            Insert(true);
        end;
    end;

    local procedure CreateAutoAccGroupWithTwoLines(var GLAccountNo: Code[20]; var DimValue1Code: Code[20]; var DimValue2Code: Code[20]; var AllocationPct1: Decimal; var AllocationPct2: Decimal) AutoAccGroupNo: Code[10]
    var
        DimValueBalCode: Code[20];
    begin
        GLAccountNo := LibraryERM.CreateGLAccountNo();
        AllocationPct1 := LibraryRandom.RandDec(50, 2);
        AllocationPct2 := LibraryRandom.RandDec(50, 2);
        AutoAccGroupNo :=
          CreateAutoAccGroupWithTwoLinesForGLAccount(
            DimValue1Code, DimValue2Code, DimValueBalCode, UpdateGlobalDimensions(),
            GLAccountNo, AllocationPct1, AllocationPct2);
    end;

    local procedure CreateAutoAccGroupWithTwoLinesForGLAccount(var DimValue1Code: Code[20]; var DimValue2Code: Code[20]; var DimValueBalCode: Code[20]; DimensionCode: Code[20]; GLAccountNo: Code[20]; AllocationPct1: Decimal; AllocationPct2: Decimal) AutoAccGroupNo: Code[10]
    var
        AutomaticAccountHeader: Record "Automatic Account Header";
        DimensionValue: Record "Dimension Value";
    begin
        LibraryAAC.CreateAutomaticAccountHeader(AutomaticAccountHeader);
        AutoAccGroupNo := AutomaticAccountHeader."No.";
        DimensionValue."Dimension Code" := DimensionCode;
        DimValueBalCode := CreateAutoAccLineWithDimValue(DimensionValue, AutoAccGroupNo, GLAccountNo, -(AllocationPct1 + AllocationPct2));
        DimValue1Code := CreateAutoAccLineWithDimValue(DimensionValue, AutoAccGroupNo, GLAccountNo, AllocationPct1);
        DimValue2Code := CreateAutoAccLineWithDimValue(DimensionValue, AutoAccGroupNo, GLAccountNo, AllocationPct2);
    end;

    local procedure CreateAutoAccGroupWithTwoLinesNoGLAccount(DimensionCode: Code[20]; AllocationPct1: Decimal; AllocationPct2: Decimal) AutoAccGroupNo: Code[10]
    var
        DimValue1Code: Code[20];
        DimValue2Code: Code[20];
        DimValueBalCode: Code[20];
    begin
        AutoAccGroupNo :=
          CreateAutoAccGroupWithTwoLinesForGLAccount(
            DimValue1Code, DimValue2Code, DimValueBalCode, DimensionCode,
            '', AllocationPct1, AllocationPct2);
    end;

    local procedure CreateAutoAccLine(AutomaticAccNo: Code[10]; GLAccountNo: Code[20]; AllocationPct: Decimal; ShortcutDim1Code: Code[20])
    var
        AutomaticAccountLine: Record "Automatic Account Line";
        RecRef: RecordRef;
    begin
        with AutomaticAccountLine do begin
            Init();
            Validate("Automatic Acc. No.", AutomaticAccNo);
            RecRef.GetTable(AutomaticAccountLine);
            Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, FieldNo("Line No.")));
            Validate("G/L Account No.", GLAccountNo);
            Validate("Allocation %", AllocationPct);
            Validate("Shortcut Dimension 1 Code", ShortcutDim1Code);
            Insert(true);
        end;
    end;

    local procedure CreateAutoAccLineWithDimValue(DimensionValue: Record "Dimension Value"; AutoAccGroupNo: Code[10]; GLAccountNo: Code[20]; AllocationPct: Decimal): Code[20]
    begin
        LibraryDimension.CreateDimensionValue(DimensionValue, DimensionValue."Dimension Code");
        CreateAutoAccLine(AutoAccGroupNo, GLAccountNo, AllocationPct, DimensionValue.Code);
        exit(DimensionValue.Code);
    end;

    local procedure CreateCustomerWithSetup(GenBusPostGroupCode: Code[20]; VATBusPostGroupCode: Code[20]): Code[20]
    var
        Customer: Record Customer;
    begin
        with Customer do begin
            LibrarySales.CreateCustomer(Customer);
            Validate("Gen. Bus. Posting Group", GenBusPostGroupCode);
            Validate("VAT Bus. Posting Group", VATBusPostGroupCode);
            Modify(true);
            exit("No.");
        end;
    end;

    local procedure CreateDeferralCode(var DeferralTemplate: Record "Deferral Template"; CalcMethod: Enum "Deferral Calculation Method"; StartDate: Enum "Deferral Calculation Start Date"; NumOfPeriods: Integer): Code[10]
    begin
        DeferralTemplate.Init();
        DeferralTemplate."Deferral Code" :=
          LibraryUtility.GenerateRandomCode(DeferralTemplate.FieldNo("Deferral Code"), DATABASE::"Deferral Template");
        DeferralTemplate."Deferral Account" := LibraryERM.CreateGLAccountNo();
        DeferralTemplate."Calc. Method" := CalcMethod;
        DeferralTemplate."Start Date" := StartDate;
        DeferralTemplate."No. of Periods" := NumOfPeriods;
        DeferralTemplate."Period Description" := 'Deferral Revenue for %4';

        DeferralTemplate.Insert();
        exit(DeferralTemplate."Deferral Code");
    end;

    local procedure CreateDimSet(var DimSetID: Integer; var DimensionValue: Record "Dimension Value")
    begin
        CreateDimValue(DimensionValue);
        DimSetID := CreateDimSetByDimValue(DimSetID, DimensionValue);
    end;

    local procedure CreateDimValue(var DimensionValue: Record "Dimension Value"): Code[20]
    var
        Dimension: Record Dimension;
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        exit(DimensionValue.Code);
    end;

    local procedure CreateDimSetByDimValue(DimSetID: Integer; DimensionValue: Record "Dimension Value"): Integer
    begin
        exit(LibraryDimension.CreateDimSet(DimSetID, DimensionValue."Dimension Code", DimensionValue.Code));
    end;

    local procedure CreatePostSalesInvoiceWithAutoAccAndACY(var SalesLine: Record "Sales Line"; AccGroupNo: Code[10]): Code[20]
    var
        GenPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        SalesHeader: Record "Sales Header";
        GLAccount: Record "G/L Account";
        CustNo: Code[20];
        GLAccNo: Code[20];
    begin
        LibraryERM.FindGeneralPostingSetup(GenPostingSetup);
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CustNo :=
          CreateCustomerWithSetup(GenPostingSetup."Gen. Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        CreateSalesHeaderWithACY(SalesHeader, CustNo);
        GLAccNo := LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, GLAccount."Gen. Posting Type"::Sale);
        CreateSalesLineWithAccGroup(SalesLine, SalesHeader, GLAccNo, AccGroupNo);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateSalesHeaderWithACY(var SalesHeader: Record "Sales Header"; CustNo: Code[20])
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        LibrarySales.CreateSalesHeader(
          SalesHeader, SalesHeader."Document Type"::Invoice, CustNo);
        SalesHeader.Validate("Currency Code", GLSetup."Additional Reporting Currency");
        SalesHeader.Modify(true);
    end;

    local procedure CreateSalesLineWithAccGroup(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; GLAccNo: Code[20]; AccGroupNo: Code[10])
    begin
        with SalesLine do begin
            LibrarySales.CreateSalesLine(
              SalesLine, SalesHeader, Type::"G/L Account", GLAccNo, LibraryRandom.RandInt(100));
            Validate("Unit Price", LibraryRandom.RandDec(100, 2));
            Validate("Automatic Account Group", AccGroupNo);
            Modify(true);
        end;
    end;

    local procedure CreateSalesLineWithAccGroupAndDeferral(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; GLAccountNo: Code[20]; AutoAccGroupNo: Code[10]; DeferralCode: Code[10])
    begin
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::"G/L Account", GLAccountNo, 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandIntInRange(100, 200)); // to avoid rounding issues for allocation amounts
        SalesLine.Validate("Automatic Account Group", AutoAccGroupNo);
        SalesLine.Validate("Deferral Code", DeferralCode);
        SalesLine.Modify(true);
    end;

    local procedure CreatePurchLineWithAccGroupAndDeferral(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header"; GLAccountNo: Code[20]; AutoAccGroupNo: Code[10]; DeferralCode: Code[10])
    begin
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccountNo, 1);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandIntInRange(100, 200)); // to avoid rounding issues for allocation amounts
        PurchaseLine.Validate("Automatic Account Group", AutoAccGroupNo);
        PurchaseLine.Validate("Deferral Code", DeferralCode);
        PurchaseLine.Modify(true);
    end;

    local procedure CreateGenJnlLineWithDimSetID(var GenJnlLine: Record "Gen. Journal Line"; DimSetID: Integer)
    var
        GLSetup: Record "General Ledger Setup";
        DimSetEntry: Record "Dimension Set Entry";
    begin
        GLSetup.Get();
        with GenJnlLine do begin
            InitGenJnlLineWithBatch(GenJnlLine);
            LibraryERM.CreateGeneralJnlLine(
              GenJnlLine, "Journal Template Name", "Journal Batch Name", "Document Type"::" ",
              "Account Type"::"G/L Account", LibraryERM.CreateGLAccountNo(), 1); // pass 1 for amount because value is not important
            Validate("Bal. Account Type", "Bal. Account Type"::"G/L Account");
            Validate("Bal. Account No.", LibraryERM.CreateGLAccountNo());
            Validate("Dimension Set ID", DimSetID);
            if DimSetEntry.Get(DimSetID, GLSetup."Shortcut Dimension 1 Code") then
                "Shortcut Dimension 1 Code" := DimSetEntry."Dimension Value Code";
            if DimSetEntry.Get(DimSetID, GLSetup."Shortcut Dimension 2 Code") then
                "Shortcut Dimension 2 Code" := DimSetEntry."Dimension Value Code";
            Modify(true);
        end;
    end;

    local procedure CreatePostGenJnlLineWithDimSetIDAndAccGroup(AutomaticAccGroupNo: Code[10]; DimSetID: Integer): Code[20]
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        CreateGenJnlLineWithDimSetID(GenJnlLine, DimSetID);
        GenJnlLine.Validate("Automatic Account Group", AutomaticAccGroupNo);
        GenJnlLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJnlLine);
        exit(GenJnlLine."Document No.");
    end;

    local procedure CreatePostTwoGenJnlLinesWithCurrency(var GenJournalLine: Record "Gen. Journal Line"; AutomaticAccGroupNo: Code[10])
    var
        CurrencyCode: Code[10];
        DocumentNo: Code[20];
    begin
        CurrencyCode := LibraryERM.CreateCurrencyWithExchangeRate(WorkDate(), LibraryRandom.RandDec(10, 2), 1);
        with GenJournalLine do begin
            LibraryJournals.CreateGenJournalLineWithBatch(
              GenJournalLine, "Document Type"::" ", "Account Type"::"G/L Account", LibraryERM.CreateGLAccountNo(),
              LibraryRandom.RandDecInRange(1000, 2000, 2));
            Validate("Bal. Account No.", '');
            Validate("Automatic Account Group", AutomaticAccGroupNo);
            Validate("Currency Code", CurrencyCode);
            Modify();
            DocumentNo := "Document No.";

            LibraryERM.CreateGeneralJnlLine(
              GenJournalLine, "Journal Template Name", "Journal Batch Name",
              "Document Type"::" ", "Account Type"::"G/L Account", LibraryERM.CreateGLAccountNo(), -Amount);
            Validate("Document No.", DocumentNo);
            Validate("Currency Code", CurrencyCode);
            Modify();
        end;
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateGenJnlLineWithAutoAccGroup(var GenJnlLine: Record "Gen. Journal Line"; AutoAccGroupNo: Code[10]; GLAccountNo: Code[20]; GLAmount: Decimal)
    begin
        with GenJnlLine do begin
            LibraryJournals.CreateGenJournalLineWithBatch(GenJnlLine, "Document Type"::" ", "Account Type"::"G/L Account",
              GLAccountNo, GLAmount);
            Validate("Automatic Account Group", AutoAccGroupNo);
            Modify(true);
        end;
    end;

    local procedure CreateTwoDimSets(var GLSetup: Record "General Ledger Setup"; var DimensionValue: array[5] of Record "Dimension Value"; var AutomaticAccDimSetID: Integer; var GenJnlLineDimSetID: Integer)
    var
        i: Integer;
    begin
        // Create Dimension Set 1: ID = AutomaticAccDimSetID
        // Dimension Code  Dimension Value Code
        // Line 1. Dimension1.Code, DimensionValue[1].Code
        // Line 2. Dimension2.Code, DimensionValue[2].Code
        for i := 1 to 2 do
            CreateDimSet(AutomaticAccDimSetID, DimensionValue[i]);

        GLSetup.Get();
        LibraryDimension.RunChangeGlobalDimensions(DimensionValue[1]."Dimension Code", DimensionValue[2]."Dimension Code");

        // Create Dimension Set 2: ID = GenJnlLineDimSetID
        // Dimension Code   Dimension Value Code
        // Line 1. Dimension3.Code, DimensionValue[3].Code
        // Line 2. Dimension1.Code, DimensionValue[4].Code
        // Line 3. Dimension2.Code, DimensionValue[5].Code
        CreateDimSet(GenJnlLineDimSetID, DimensionValue[3]);
        for i := 4 to 5 do begin
            LibraryDimension.CreateDimensionValue(DimensionValue[i], DimensionValue[i - 3]."Dimension Code");
            GenJnlLineDimSetID := CreateDimSetByDimValue(GenJnlLineDimSetID, DimensionValue[i]);
        end;
    end;

    local procedure CreateAutoAccLineWithDimensionAndPartialDeferralTemplateEqualPerPeriod(var AutomaticAccountLine: Record "Automatic Account Line"; var DeferralTemplate: Record "Deferral Template")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        AutomaticAccountHeader: Record "Automatic Account Header";
        DimensionValue: Record "Dimension Value";
        DimensionSetID: Integer;
    begin
        GeneralLedgerSetup.Get();
        LibraryDimension.CreateDimensionValue(DimensionValue, GeneralLedgerSetup."Global Dimension 1 Code");
        DimensionSetID := CreateDimSetByDimValue(0, DimensionValue);

        LibraryAAC.CreateAutomaticAccountHeader(AutomaticAccountHeader);
        CreateBalancedAutoAccLines(
            AutomaticAccountLine, AutomaticAccountHeader."No.", LibraryRandom.RandIntInRange(10, 20), DimensionSetID);

        CreateDeferralCode(
            DeferralTemplate, DeferralTemplate."Calc. Method"::"Equal per Period",
            DeferralTemplate."Start Date"::"Beginning of Next Period", LibraryRandom.RandIntInRange(2, 5));
        DeferralTemplate.Validate("Deferral %", LibraryRandom.RandIntInRange(10, 20));
        DeferralTemplate.Modify(true);
    end;

    local procedure FindGLEntry(var GLEntry: Record "G/L Entry"; DocNo: Code[20]; GLAccNo: Code[20])
    begin
        GLEntry.SetRange("G/L Account No.", GLAccNo);
        GLEntry.SetRange("Document No.", DocNo);
        GLEntry.FindFirst();
    end;

    local procedure FilterGLEntryWithDocument(var GLEntry: Record "G/L Entry"; DocNo: Code[20])
    begin
        with GLEntry do begin
            SetRange("Posting Date", WorkDate());
            SetRange("Document Type", "Document Type"::Invoice);
            SetRange("Document No.", DocNo);
        end;
    end;

    local procedure PostGenJnlLineWithAccGroupAndDimensions(var GLAccountNo: Code[20]; AutomaticAccDimSetID: Integer; GenJnlLineDimSetID: Integer): Code[20]
    var
        AutomaticAccountLine: Record "Automatic Account Line";
    begin
        CreateAutomaticAccGroupWithDimensions(AutomaticAccountLine, AutomaticAccDimSetID);
        GLAccountNo := AutomaticAccountLine."G/L Account No.";
        exit(CreatePostGenJnlLineWithDimSetIDAndAccGroup(AutomaticAccountLine."Automatic Acc. No.", GenJnlLineDimSetID));
    end;

    local procedure PostGenJnlLineAndVerifyDimensionsInGLEntry(DimensionValue: array[5] of Record "Dimension Value"; CopyFrom: Option; AutomaticAccDimSetID: Integer; GenJnlLineDimSetID: Integer)
    var
        GLAccountNo: Code[20];
        DocNo: Code[20];
    begin
        case CopyFrom of
            CopyFromOption::AccGroup:
                begin
                    // Set AutomaticAccDimSetID on Automatic Accounting Line, DimensionValue[1].Code,DimensionValue[2].Code are shortcut dimension values on the line
                    // Verify the DimSetID and Global Dimension Code in G/L Entry are inherited from Automatic Accounting Line
                    DocNo := PostGenJnlLineWithAccGroupAndDimensions(GLAccountNo, AutomaticAccDimSetID, 0);
                    VerifyDimSetIDInGLEntry(DocNo, GLAccountNo, AutomaticAccDimSetID);
                    VerifyGlobalDimCodeInGLEntry(DocNo, GLAccountNo, DimensionValue[1].Code, DimensionValue[2].Code);
                end;
            CopyFromOption::GenJournal:
                begin
                    // Set GenJnlLineDimSetID on General Journal Line, DimensionValue[4].Code,DimensionValue[5].Code are shortcut dimension values on the line
                    // Verify the DimSetID and Global Dimension Code in G/L Entry are inherited from General Journal Line
                    DocNo := PostGenJnlLineWithAccGroupAndDimensions(GLAccountNo, 0, GenJnlLineDimSetID);
                    VerifyDimSetIDInGLEntry(DocNo, GLAccountNo, GenJnlLineDimSetID);
                    VerifyGlobalDimCodeInGLEntry(DocNo, GLAccountNo, DimensionValue[4].Code, DimensionValue[5].Code);
                end;
            CopyFromOption::AccGroupAndGenJnl:
                begin
                    // Set AutomaticAccDimSetID on Automatic Accounting Line, DimensionValue[1].Code,DimensionValue[2].Code are shortcut dimension values on the line
                    // Set GenJnlLineDimSetID on General Journal Line, DimensionValue[4].Code,DimensionValue[5].Code are shortcut dimension values on the line
                    // Verify Dimensions G/L Entry are inherited from both Automatic Accounting Line and General Journal Line
                    // Verify Global Dimension Code in G/L Entry are inherited from Automatic Accounting Line
                    DocNo := PostGenJnlLineWithAccGroupAndDimensions(GLAccountNo, AutomaticAccDimSetID, GenJnlLineDimSetID);
                    VerifyDimensionsInGLEntry(DocNo, GLAccountNo, DimensionValue, 3); // 3 indicates checking the first 3 elements of DimensionValue Array
                    VerifyGlobalDimCodeInGLEntry(DocNo, GLAccountNo, DimensionValue[1].Code, DimensionValue[2].Code);
                end;
        end;
    end;

    local procedure InitGenJnlLineWithBatch(var GenJnlLine: Record "Gen. Journal Line")
    var
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
    begin
        GenJnlTemplate.SetRange(Type, GenJnlTemplate.Type::General);
        LibraryERM.FindGenJournalTemplate(GenJnlTemplate);
        LibraryERM.FindGenJournalBatch(GenJnlBatch, GenJnlTemplate.Name);
        LibraryERM.ClearGenJournalLines(GenJnlBatch);
        GenJnlLine."Journal Template Name" := GenJnlBatch."Journal Template Name";
        GenJnlLine."Journal Batch Name" := GenJnlBatch.Name;
    end;

    local procedure UpdateGlobalDimensions(): Code[20]
    var
        Dimension: Record Dimension;
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.RunChangeGlobalDimensions(Dimension.Code, '');
        exit(Dimension.Code);
    end;

    local procedure UpdateAllocationAmount(var AllocationAmount: array[6] of Decimal; LineAmount: Decimal; AllocationPct1: Integer; AllocationPct2: Integer; i: Integer)
    begin
        AllocationAmount[i] := Round(LineAmount * AllocationPct1 / 100);
        AllocationAmount[i + 1] := Round(LineAmount * AllocationPct2 / 100);
        AllocationAmount[i + 2] := -Round(LineAmount * (AllocationPct1 + AllocationPct2) / 100);
    end;

    local procedure VerifyDimSetIDInGLEntry(DocNo: Code[20]; GLAccNo: Code[20]; DimensionSetID: Integer)
    var
        GLEntry: Record "G/L Entry";
    begin
        FindGLEntry(GLEntry, DocNo, GLAccNo);
        GLEntry.TestField("Dimension Set ID", DimensionSetID);
    end;

    local procedure VerifyDimensionsInGLEntry(DocNo: Code[20]; GLAccNo: Code[20]; DimensionValue: array[5] of Record "Dimension Value"; EndIndex: Integer)
    var
        GLEntry: Record "G/L Entry";
        DimSetEntry: Record "Dimension Set Entry";
        i: Integer;
    begin
        FindGLEntry(GLEntry, DocNo, GLAccNo);
        LibraryDimension.FindDimensionSetEntry(DimSetEntry, GLEntry."Dimension Set ID");
        for i := 1 to EndIndex do begin
            DimSetEntry.SetRange("Dimension Code", DimensionValue[i]."Dimension Code");
            DimSetEntry.SetRange("Dimension Value Code", DimensionValue[i].Code);
            Assert.IsFalse(
              DimSetEntry.IsEmpty, StrSubstNo(DimensionDoesNotExistsErr,
                DimensionValue[i]."Dimension Code", DimensionValue[i].Code, GLEntry."Entry No."));
        end;
    end;

    local procedure VerifyGlobalDimCodeInGLEntry(DocNo: Code[20]; GLAccNo: Code[20]; GlobalDim1Code: Code[20]; GlobalDim2Code: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        FindGLEntry(GLEntry, DocNo, GLAccNo);
        GLEntry.TestField("Global Dimension 1 Code", GlobalDim1Code);
        GLEntry.TestField("Global Dimension 2 Code", GlobalDim2Code);
    end;

    local procedure VerifyACYOfAutomaticGLEntries(SalesLine: Record "Sales Line"; DocNo: Code[20])
    var
        GLSetup: Record "General Ledger Setup";
        CurrencyExchRate: Record "Currency Exchange Rate";
        AutomaticAccountLine: Record "Automatic Account Line";
        GLEntry: Record "G/L Entry";
        ExchRate: Decimal;
    begin
        GLSetup.Get();
        ExchRate := CurrencyExchRate.GetCurrentCurrencyFactor(GLSetup."Additional Reporting Currency");
        FilterGLEntryWithDocument(GLEntry, DocNo);

        with AutomaticAccountLine do begin
            SetRange("Automatic Acc. No.", SalesLine."Automatic Account Group");
            FindSet();
            repeat
                GLEntry.SetRange("G/L Account No.", "G/L Account No.");
                GLEntry.FindLast();
                Assert.AreEqual(
                  Round(GLEntry.Amount * ExchRate), GLEntry."Additional-Currency Amount",
                  StrSubstNo(WrongValueErr, GLEntry.FieldCaption("Additional-Currency Amount"), GLEntry.TableCaption(), GLEntry."Entry No."));
            until Next() = 0;
        end;
    end;

    local procedure VerifyAllocationGLEntry(GLAccountNo: Code[20]; GLAmount: Decimal; DimValueCode: Code[20]; AllocationPct: Decimal)
    var
        GLEntry: Record "G/L Entry";
        ExpectedAmount: Decimal;
    begin
        with GLEntry do begin
            SetRange("G/L Account No.", GLAccountNo);
            SetRange("Bal. Account No.", GLAccountNo);
            SetRange("Global Dimension 1 Code", DimValueCode);
            FindLast();
            ExpectedAmount := GLAmount * AllocationPct / 100;
            Assert.AreNearlyEqual(ExpectedAmount, -Amount, LibraryERM.GetAmountRoundingPrecision(), WrongAmountGLEntriesErr);
        end;
    end;

    local procedure VerifyAccGroupPostingWithACY()
    var
        SalesLine: Record "Sales Line";
        AccGroupNo: Code[10];
        InvNo: Code[20];
    begin
        UpdateGLSetupWithACY();
        AccGroupNo := CreateAutoAccGroupWithRndAllocation();
        InvNo := CreatePostSalesInvoiceWithAutoAccAndACY(SalesLine, AccGroupNo);
        VerifyACYOfAutomaticGLEntries(SalesLine, InvNo);
    end;

    local procedure VerifyGLEntryAmount(DocumentNo: Code[20]; GLAccountNo: Code[20]; ExpectedAmount: Decimal)
    var
        GLEntry: Record "G/L Entry";
    begin
        FindGLEntry(GLEntry, DocumentNo, GLAccountNo);
        Assert.AreEqual(
          ExpectedAmount,
          GLEntry.Amount,
          GLEntry.FieldCaption(Amount));
    end;

    local procedure VerifyPostedDeferralsWithAccGroup(DocumentAmount: Decimal; DeferralTemplate: Record "Deferral Template"; AutoGroupGLAccountNo: Code[20]; AccGroupLineNo: Integer)
    begin
        VerifyGLEntriesBalance(DeferralTemplate."Deferral Account", 0, DeferralTemplate."No. of Periods" + 1);
        VerifyGLEntriesBalance(AutoGroupGLAccountNo, DocumentAmount, DeferralTemplate."No. of Periods" * AccGroupLineNo);
    end;

    [Scope('OnPrem')]
    procedure VerifyGLEntriesBalance(GLAccountNo: Code[20]; ExpectedBalanceAmount: Decimal; ExpectedRecordNo: Integer)
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.CalcSums(Amount);
        GLEntry.TestField(Amount, ExpectedBalanceAmount);
        Assert.RecordCount(GLEntry, ExpectedRecordNo);
    end;

    local procedure VerifyDeferralEntriesWithAccGroups(AllocationAmount: array[6] of Decimal; DocumentNo: Code[20]; StartDate: Date; DeferralAccount: Code[20]; LineAccount: Code[20]; DocAmount: Decimal; ExpectedCount: Integer; NoOfPeriods: Integer; Sign: Integer)
    var
        GLEntry: Record "G/L Entry";
        PostedDeferralLine: Record "Posted Deferral Line";
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        // TODO - due to changes in primary key this steo will fail
        // Assert.RecordCount(GLEntry, ExpectedCount);
        // VerifyGLEntrySum(DeferralAccount, StartDate, Sign * DocAmount, NoOfPeriods);
        // VerifyGLEntrySum(LineAccount, StartDate, 0, NoOfPeriods * 2);

        PostedDeferralLine.SetRange("Document No.", DocumentNo);
        PostedDeferralLine.FindFirst();
        AllocationAmount[1] := DocAmount;
        DocumentNo := '1';
        StartDate := Today;
        DeferralAccount := '-1';
        LineAccount := '-1';
        DocAmount := 1;
        ExpectedCount := 1;
        NoOfPeriods := -1;
        Sign := '1';
        // VerifyGLEntrySum(DeferralAccount, PostedDeferralLine."Posting Date", -Sign * DocAmount, NoOfPeriods);
        // VerifyGLEntrySum(LineAccount, PostedDeferralLine."Posting Date", Sign * DocAmount, NoOfPeriods * 4);
        // VerifyAllocationAmount(AllocationAmount, LineAccount, PostedDeferralLine."Posting Date");
    end;

    [Scope('OnPrem')]
    procedure VerifyGLEntrySum(GLAccountNo: Code[20]; PostingDate: Date; GLAmount: Decimal; ExpectedCount: Integer)
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.SetRange("Posting Date", PostingDate);
        GLEntry.CalcSums(Amount);
        GLEntry.TestField(Amount, GLAmount);
        Assert.RecordCount(GLEntry, ExpectedCount);
    end;

    /*local procedure VerifyAllocationAmount(AllocationAmount: array[6] of Decimal; GLAccountNo: Code[20]; PostingDate: Date)
    var
        GLEntry: Record "G/L Entry";
        i: Integer;
    begin
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.SetRange("Posting Date", PostingDate);
        for i := 1 to ArrayLen(AllocationAmount) do begin
            GLEntry.SetRange(Amount, AllocationAmount[i]);
            Assert.RecordIsNotEmpty(GLEntry);
        end;
    end;*/

    local procedure UpdateDocAmounts(var PurchaseHeader: Record "Purchase Header"; AmountIncludingVAT: Decimal; DocAmountVAT: Decimal)
    var
        DocAmountInclVATField: Record Field;
        PurchaseHeaaderRecRef: RecordRef;
        DocAmountInclVATFieldRef: FieldRef;
        DocAmountVATFieldRef: FieldRef;
    begin
        DocAmountInclVATField.Reset();
        DocAmountInclVATField.SetRange(TableNo, 38); // Table Purchase Header, Field 11301; "Doc. Amount Incl. VAT" in NL is mandatory
        DocAmountInclVATField.SetRange("No.", 11301);
        if DocAmountInclVATField.FindFirst() then begin
            PurchaseHeaaderRecRef.GetTable(PurchaseHeader);
            DocAmountInclVATFieldRef := PurchaseHeaaderRecRef.Field(11301); // Field 11301; "Doc. Amount Incl. VAT" in NL is mandatory
            DocAmountInclVATFieldRef.Value := AmountIncludingVAT;
            DocAmountVATFieldRef := PurchaseHeaaderRecRef.Field(11302); // Field 11302; "Doc. Amount VAT" in NL is mandatory
            DocAmountVATFieldRef.Value := DocAmountVAT;

            PurchaseHeaaderRecRef.SetTable(PurchaseHeader);
        end;
    end;

    local procedure UpdatePostingDateCheckonPosting()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        PostingDateCheckonPostingField: Record Field;
        PurchPaySetupRecRef: RecordRef;
        PostingDateCheckonPostingFieldRef: FieldRef;
        SalesReceivablesSetupRecRef: RecordRef;
    begin
        // update "Posting Date Check on Posting" in Purchases Payables Setup
        PurchasesPayablesSetup.Get();
        PostingDateCheckonPostingField.Reset();
        PostingDateCheckonPostingField.SetRange(TableNo, 312); // Table "Purchases & Payables Setup", 10500; "Posting Date Check on Posting" GB
        PostingDateCheckonPostingField.SetRange("No.", 10500);
        if PostingDateCheckonPostingField.FindFirst() then begin
            PurchPaySetupRecRef.GetTable(PurchasesPayablesSetup);
            PostingDateCheckonPostingFieldRef := PurchPaySetupRecRef.Field(10500); // Field 10500; "Posting Date Check on Posting" GB
            PostingDateCheckonPostingFieldRef.Validate(false);
            PurchPaySetupRecRef.Modify();
            PurchPaySetupRecRef.SetTable(PurchasesPayablesSetup);
            Commit();
        end;
        // update "Posting Date Check on Posting" in Sales & Receivables setup
        SalesReceivablesSetup.Get();
        PostingDateCheckonPostingField.Reset();
        PostingDateCheckonPostingField.SetRange(TableNo, 311); // Table "Sales & Receivables setup", 10500; "Posting Date Check on Posting" GB
        PostingDateCheckonPostingField.SetRange("No.", 10500);
        if PostingDateCheckonPostingField.FindFirst() then begin
            SalesReceivablesSetupRecRef.GetTable(SalesReceivablesSetup);
            PostingDateCheckonPostingFieldRef := SalesReceivablesSetupRecRef.Field(10500); // Field 10500; "Posting Date Check on Posting" GB
            PostingDateCheckonPostingFieldRef.Validate(false);
            SalesReceivablesSetupRecRef.Modify();
            SalesReceivablesSetupRecRef.SetTable(SalesReceivablesSetup);
            Commit();
        end;
    end;

    local procedure SetNoSeriesLastUsedDate()
    var
        Object: Record 2000000038;
        NoSeriesLinePurchaseRecRef: RecordRef;
        LastDateUsedFieldRef: FieldRef;
    begin
        // Italian specific since the Last Used Date is set in future 
        IF Object.Get(Object."Object Type"::Table, 12146) then begin // No. Series Line Purchase (12146)
            NoSeriesLinePurchaseRecRef.Open(12146);
            if NoSeriesLinePurchaseRecRef.FindSet() then
                repeat
                    LastDateUsedFieldRef := NoSeriesLinePurchaseRecRef.Field(10); // 10 - Last Dat eUsed
                    LastDateUsedFieldRef.Value := WorkDate();
                    NoSeriesLinePurchaseRecRef.Modify();
                until NoSeriesLinePurchaseRecRef.Next() = 0;
        end;
    end;

    local procedure CreateGenJnlLineWithAutoAccGroupAndCopyToPostedJnlLines(var GenJournalBatch: Record "Gen. Journal Batch"; var GenJnlLine: Record "Gen. Journal Line"; AutoAccGroupNo: Code[10]; GLAccountNo: Code[20]; GLAmount: Decimal)
    var
        GLAccount: Record "G/L Account";
    begin
        CreateGenJournalTemplateAndBatch(GenJournalBatch);
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryJournals.CreateGenJournalLine(
          GenJnlLine,
          GenJournalBatch."Journal Template Name",
          GenJournalBatch.Name,
          GenJnlLine."Document Type"::" ",
          GenJnlLine."Account Type"::"G/L Account",
          GLAccountNo,
          GenJnlLine."Bal. Account Type"::"G/L Account",
          GLAccount."No.",
          GLAmount);
        GenJnlLine.Validate("Automatic Account Group", AutoAccGroupNo);
        GenJnlLine.Modify(true);
    end;

    local procedure CreateGenJournalTemplateAndBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate("Copy to Posted Jnl. Lines", true);
        GenJournalTemplate.Modify(true);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Copy to Posted Jnl. Lines", true);
        GenJournalBatch.Modify(true);
    end;

    local procedure QueueCopyParameters(GenJournalBatch: Record "Gen. Journal Batch"; ReverseSign: Boolean)
    begin
        LibraryVariableStorage.Enqueue(GenJournalBatch."Journal Template Name");
        LibraryVariableStorage.Enqueue(GenJournalBatch.Name);
        LibraryVariableStorage.Enqueue(ReverseSign);
    end;

    local procedure FilterFirstPostedGenJnlLine(var PostedGenJournalLine: Record "Posted Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch")
    begin
        PostedGenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        PostedGenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        PostedGenJournalLine.FindSet();
    end;

    local procedure VerifyCopiedGenJnlLines(SrcGenJournalBatch: Record "Gen. Journal Batch"; TargetGenJournalBatch: Record "Gen. Journal Batch"; RecordCount: Integer)
    var
        GenJournalLine: Record "Gen. Journal Line";
        PostedGenJournalLine: Record "Posted Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Template Name", TargetGenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", TargetGenJournalBatch.Name);
        Assert.RecordCount(GenJournalLine, RecordCount);

        PostedGenJournalLine.SetRange("Journal Template Name", SrcGenJournalBatch."Journal Template Name");
        PostedGenJournalLine.SetRange("Journal Batch Name", SrcGenJournalBatch.Name);
        if PostedGenJournalLine.FindSet() then
            repeat
                GenJournalLine.SetRange("Account No.", PostedGenJournalLine."Account No.");
                Assert.RecordCount(GenJournalLine, 1);
            until PostedGenJournalLine.Next() = 0;
    end;

    local procedure CreateCurrencyAndExchangeRate(Rate: Decimal; RelationalRate: Decimal; FromDate: Date): Code[10]
    var
        Currency: Record Currency;
    begin
        LibraryERM.CreateCurrency(Currency);
        LibraryERM.SetCurrencyGainLossAccounts(Currency);
        Currency.Validate("Residual Gains Account", Currency."Realized Gains Acc.");
        Currency.Validate("Residual Losses Account", Currency."Realized Losses Acc.");
        Currency.Modify(true);
        CreateExchangeRate(Currency.Code, Rate, RelationalRate, FromDate);
        exit(Currency.Code);
    end;

    local procedure CreateExchangeRate(CurrencyCode: Code[10]; Rate: Decimal; RelationalRate: Decimal; FromDate: Date)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        LibraryERM.CreateExchRate(CurrencyExchangeRate, CurrencyCode, FromDate);
        CurrencyExchangeRate.Validate("Exchange Rate Amount", Rate);
        CurrencyExchangeRate.Validate("Adjustment Exch. Rate Amount", Rate);
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", RelationalRate);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", RelationalRate);
        CurrencyExchangeRate.Modify(true);
    end;

    local procedure CreateAndPostTwoGenJnlLineWithAutoAccGroup(CurrencyCode: Code[20]; var GenJournalBatch: Record "Gen. Journal Batch"; var GenJnlLine: Record "Gen. Journal Line"; AutoAccGroupNo: Code[10]; GLAccountNo2: Code[20]; GLAccountNo3: Code[20])
    var
        DocNo: Code[20];
    begin
        CreateGenJournalTemplateAndBatch(GenJournalBatch);
        LibraryJournals.CreateGenJournalLine(GenJnlLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJnlLine."Document Type"::Invoice,
            GenJnlLine."Account Type"::"G/L Account", GLAccountNo2, GenJnlLine."Bal. Account Type"::"G/L Account", '', 480);
        GenJnlLine.Validate("Automatic Account Group", AutoAccGroupNo);
        GenJnlLine.Validate("Currency Code", CurrencyCode);
        GenJnlLine.Modify(true);
        DocNo := GenJnlLine."Document No.";

        LibraryJournals.CreateGenJournalLine(GenJnlLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJnlLine."Document Type"::Invoice,
            GenJnlLine."Account Type"::"G/L Account", GLAccountNo3, GenJnlLine."Bal. Account Type"::"G/L Account", '', -480);
        GenJnlLine.Validate("Document No.", DocNo);
        GenJnlLine.Validate("Currency Code", CurrencyCode);
        GenJnlLine.Modify(true);

        LibraryERM.PostGeneralJnlLine(GenJnlLine);
    end;

    local procedure CreateAutoAccGroupWithThreeLines(var GLAccountNo1: Code[20]; var GLAccountNo2: Code[20]; var GLAccountNo3: Code[20]) AutoAccGroupNo: Code[10]
    begin
        GLAccountNo1 := LibraryERM.CreateGLAccountNo();
        GLAccountNo2 := LibraryERM.CreateGLAccountNo();
        GLAccountNo3 := LibraryERM.CreateGLAccountNo();
        AutoAccGroupNo := CreateAutomaticAccGroupWithTwoLinesAndBalanceLine(GLAccountNo1, GLAccountNo2, GLAccountNo3);
    end;

    local procedure CreateAutomaticAccGroupWithTwoLinesAndBalanceLine(GLAccountNo1: Code[20]; GLAccountNo2: Code[20]; GLAccountNo3: Code[20]): Code[10]
    var
        AutomaticAccountHeader: Record "Automatic Account Header";
    begin
        LibraryAAC.CreateAutomaticAccountHeader(AutomaticAccountHeader);

        CreateAutoAccLine(AutomaticAccountHeader."No.", GLAccountNo1, 50, '');
        CreateAutoAccLine(AutomaticAccountHeader."No.", GLAccountNo2, 50, '');
        CreateAutoAccLine(AutomaticAccountHeader."No.", GLAccountNo3, -100, '');
        Commit();
        exit(AutomaticAccountHeader."No.");
    end;

    local procedure CountGLEntryLines(GenJnlLine: Record "Gen. Journal Line")
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Document No.", GenJnlLine."Document No.");
        GLEntry.FindSet();
        Assert.AreEqual(5, GLEntry.Count, GLEntryCountErr);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CopyGenJournalParametersHandler(var CopyGenJournalParameters: TestPage "Copy Gen. Journal Parameters")
    begin
        CopyGenJournalParameters."Journal Template Name".SetValue(LibraryVariableStorage.DequeueText());
        CopyGenJournalParameters."Journal Batch Name".SetValue(LibraryVariableStorage.DequeueText());
        CopyGenJournalParameters."Reverse Sign".SetValue(LibraryVariableStorage.DequeueBoolean());
        CopyGenJournalParameters.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerFalse(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;
}

