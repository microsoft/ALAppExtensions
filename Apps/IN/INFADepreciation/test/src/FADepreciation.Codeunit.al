codeunit 18649 "FA Depreciation"
{
    Subtype = Test;

    var
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryAssert: Codeunit "Library Assert";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryERM: Codeunit "Library - ERM";
        IsInitialized: Boolean;
        StorageDec: Dictionary of [Text, Decimal];
        CompanyLbl: Label 'COMPANY', Locked = true;
        IncomeTaxLbl: Label 'INCOMETAX', Locked = true;
        XDepRateTok: Label 'DepRate', Locked = true;
        XAddlDepRateTok: Label 'AddlDepRate', Locked = true;
        AmountErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Amount and Amount';

    [Test]
    procedure VerifyFAStockUponNewFAPurchaseStraightLine()
    var
        DepreciationBook: Record "Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        FAClass: Record "FA Class";
        FixedAssetBlock: Record "Fixed Asset Block";
        FASubclass: Record "FA Subclass";
        FALocation: Record "FA Location";
        FADepreciationBook: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
        DepreciationMethod: Enum "Depreciation Method";
        AcquisitionAmount: Decimal;
        AssetNo: Integer;
        BlockBookValue: Decimal;
    begin
        // [SCENARIO] [382671] Check that a new FA card is created correctly
        // [SCENARIO] [382681] Acquisition of new FA through FA Journal 
        // [SCENARIO] [382657] Check that the FA Blocks are calculating the Book value and the No. of assets correctly
        Initialize();

        // [GIVEN] Created Fixed Asset Setup as per Income Tax Act
        CreateFABasicsWithIncTaxDepBook(DepreciationBook, FAClass, FixedAssetBlock, FASubclass, FALocation, FAPostingGroup);
        InitializeBlockValue(FixedAssetBlock, AssetNo, BlockBookValue);
        CreateNewFixedAsset(FixedAsset, FAClass.Code, FASubclass.Code, FALocation.Code, FixedAssetBlock.Code, false);
        CreateFADepreciationBookWithIncTaxDepBook(FADepreciationBook, FixedAsset."No.", DepreciationBook.Code, DepreciationMethod::"Straight-Line", FixedAssetBlock."Depreciation %");

        // [WHEN] Post FA Journal for Acquisition
        CreateAndPostFAAcqusitionLine(FADepreciationBook, AcquisitionAmount);

        // [THEN] FA Book Value and Block Value are created
        CheckFAValueAndBookValue(FADepreciationBook, FixedAsset, AcquisitionAmount, AssetNo, BlockBookValue);
    end;

    [Test]
    [HandlerFunctions('PostConfirmation')]
    procedure VerifyDepreciationDecliningBalance()
    var
        DepreciationBook: Record "Depreciation Book";
        FAJournalLine: Record "FA Journal Line";
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        DepreciationMethod: Enum "Depreciation Method";
        DeprAmount: Decimal;
        FAValueOld: Decimal;
        BLockValueOld: Decimal;
        DocNo: Code[20];
        NewPostingDate: Date;
    begin
        //  [SCENARIO] [382752] Check if the system is calculating Depreciation on Written Down Value
        Initialize();

        // [GIVEN] Created,Aquired Fixed Asset and checked FA Value.
        CreateAcquireAndVerifyFAValueWithIncTaxDepBook(DepreciationBook, FixedAsset, FADepreciationBook, DepreciationMethod::"Declining-Balance 1", false);

        // [WHEN] Calculate depreciation for full Year and check depreciation value.Post FA Journal for Depreciation.
        RunCalDeprAndVerifyFirstYrUtilise(FAJournalLine, FixedAsset."No.", DepreciationBook.Code, DocNo, DeprAmount, NewPostingDate, false, true);
        GetFAAndBlockValue(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld);
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);

        // [THEN] FA Book Value, Block Value and FA ledger Entries are created
        VerifyFAValueAfterDepreciation(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld, DeprAmount);
        VerifyFALedgerEntriesFirstYrUtilise(DepreciationBook, FixedAsset, FADepreciationBook, DocNo, DeprAmount, NewPostingDate, false, true);
    end;

    [Test]
    [HandlerFunctions('PostConfirmation')]
    procedure VerifyDepreciationStraightLine()
    var
        DepreciationBook: Record "Depreciation Book";
        FAJournalLine: Record "FA Journal Line";
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        DepreciationMethod: Enum "Depreciation Method";
        DeprAmount: Decimal;
        FAValueOld: Decimal;
        BLockValueOld: Decimal;
        DocNo: Code[20];
        NewPostingDate: Date;
    begin
        //  [SCENARIO] [382756] Check if the system is calculating Depreciation on Straight Line Method
        Initialize();

        // [GIVEN] Created Fixed Asset Setup as per Income Tax Act, Created,Aquired Fixed Asset and checked FA Value.
        CreateAcquireAndVerifyFAValueWithIncTaxDepBook(DepreciationBook, FixedAsset, FADepreciationBook, DepreciationMethod::"Straight-Line", false);

        // [WHEN] Calculate depreciation for full Year and check depreciation value.Post FA Journal for Depreciation.
        RunCalDeprAndVerifyFirstYrUtilise(FAJournalLine, FixedAsset."No.", DepreciationBook.Code, DocNo, DeprAmount, NewPostingDate, false, true);
        GetFAAndBlockValue(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld);
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);

        // [THEN] FA Book Value, Block Value and FA ledger Entries are Created
        VerifyFAValueAfterDepreciation(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld, DeprAmount);
        VerifyFALedgerEntriesFirstYrUtilise(DepreciationBook, FixedAsset, FADepreciationBook, DocNo, DeprAmount, NewPostingDate, false, true);
    end;

    [Test]
    [HandlerFunctions('PostConfirmation')]
    procedure VerifyDepreciationDecliningBalanceAddlDep()
    var
        DepreciationBook: Record "Depreciation Book";
        FAJournalLine: Record "FA Journal Line";
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        DepreciationMethod: Enum "Depreciation Method";
        DeprAmount: Decimal;
        FAValueOld: Decimal;
        BLockValueOld: Decimal;
        DocNo: Code[20];
        NewPostingDate: Date;
    begin
        //  [SCENARIO] [382697] Computation of Additional Depreciation
        Initialize();

        // [GIVEN] Created,Aquired Fixed Asset and checked FA Value.
        CreateAcquireAndVerifyFAValueWithIncTaxDepBook(DepreciationBook, FixedAsset, FADepreciationBook, DepreciationMethod::"Declining-Balance 1", true);

        // [WHEN] Calculate depreciation for full Year and check depreciation value.Post FA Journal for Depreciation.
        RunCalDeprAndVerifyFirstYrUtilise(FAJournalLine, FixedAsset."No.", DepreciationBook.Code, DocNo, DeprAmount, NewPostingDate, true, true);
        GetFAAndBlockValue(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld);
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);

        // [THEN] FA Book Value, Block Value and FA ledger Entries are created
        VerifyFAValueAfterDepreciation(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld, DeprAmount);
        VerifyFALedgerEntriesFirstYrUtilise(DepreciationBook, FixedAsset, FADepreciationBook, DocNo, DeprAmount, NewPostingDate, true, true);
    end;

    [Test]
    [HandlerFunctions('PostConfirmation')]
    procedure VerifyDepreciationDecliningBalanceNormalDepFirstYearHalfUtilize()
    var
        DepreciationBook: Record "Depreciation Book";
        FAJournalLine: Record "FA Journal Line";
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        DepreciationMethod: Enum "Depreciation Method";
        DeprAmount: Decimal;
        FAValueOld: Decimal;
        BLockValueOld: Decimal;
        DocNo: Code[20];
        NewPostingDate: Date;
    begin
        //  [SCENARIO] [382699] Check if the system is applying 50% of applicable depreciation rate if the Fixed Asset is put to use less than 180 days during the year
        Initialize();

        // [GIVEN] Created,Aquired Fixed Asset and checked FA Value.
        CreateAcquireAndVerifyFAValueWithIncTaxDepBook(DepreciationBook, FixedAsset, FADepreciationBook, DepreciationMethod::"Declining-Balance 1", false);

        // [WHEN] Calculate depreciation for full Year and check depreciation value.Post FA Journal for Depreciation.
        RunCalDeprAndVerifyFirstYrUtilise(FAJournalLine, FixedAsset."No.", DepreciationBook.Code, DocNo, DeprAmount, NewPostingDate, false, false);
        GetFAAndBlockValue(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld);
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);

        // [THEN] FA Book Value, Block Value and FA ledger Entries are created
        VerifyFAValueAfterDepreciation(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld, DeprAmount);
        VerifyFALedgerEntriesFirstYrUtilise(DepreciationBook, FixedAsset, FADepreciationBook, DocNo, DeprAmount, NewPostingDate, false, false);
    end;

    [Test]
    [HandlerFunctions('PostConfirmation')]
    procedure VerifyDepreciationDecliningBalanceAddlDepFirstYearHalfUtilize()
    var
        DepreciationBook: Record "Depreciation Book";
        FAJournalLine: Record "FA Journal Line";
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        DepreciationMethod: Enum "Depreciation Method";
        DeprAmount: Decimal;
        FAValueOld: Decimal;
        BLockValueOld: Decimal;
        DocNo: Code[20];
        NewPostingDate: Date;
    begin
        //  [SCENARIO] [382701] Check if the system is applying 50% of applicable additional depreciation rate if the Fixed Asset is put to use less than 180 days during the year
        Initialize();

        // [GIVEN] Created,Aquired Fixed Asset and checked FA Value.
        CreateAcquireAndVerifyFAValueWithIncTaxDepBook(DepreciationBook, FixedAsset, FADepreciationBook, DepreciationMethod::"Declining-Balance 1", true);

        // [WHEN] Calculate depreciation for full Year and check depreciation value.Post FA Journal for Depreciation.
        RunCalDeprAndVerifyFirstYrUtilise(FAJournalLine, FixedAsset."No.", DepreciationBook.Code, DocNo, DeprAmount, NewPostingDate, true, false);
        GetFAAndBlockValue(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld);
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);

        // [THEN] FA Book Value, Block Value and FA ledger Entries are created
        VerifyFAValueAfterDepreciation(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld, DeprAmount);
        VerifyFALedgerEntriesFirstYrUtilise(DepreciationBook, FixedAsset, FADepreciationBook, DocNo, DeprAmount, NewPostingDate, true, false);
    end;

    [Test]
    [HandlerFunctions('DepreciationNotCalculatedMsgHandler')]
    procedure VerifyDepreciationDecliningBalanceBlockAllAssetSoldBelowWDV()
    var
        DepreciationBook: Record "Depreciation Book";
        FAJournalLine: Record "FA Journal Line";
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        DepreciationMethod: Enum "Depreciation Method";
        DeprAmount: Decimal;
        DocNo: Code[20];
        NewPostingDate: Date;
        DisposalAmount: Decimal;
        DisposalDate: Date;
        DisposalDoc: Code[20];
    begin
        //  [SCENARIO] [383312] Depreciation calculation for a Block of Assets where all the assets of that block have been sold for a consideration lesser than the WDV of the block
        Initialize();

        // [GIVEN] Created,Aquired Fixed Asset and checked FA Value.        
        CreateAcquireAndVerifyFAValueWithIncTaxDepBook(DepreciationBook, FixedAsset, FADepreciationBook, DepreciationMethod::"Declining-Balance 1", false);

        // [WHEN] Post FA Journal for Disposal. Calculate depreciation for full Year and check depreciation value.
        FADepreciationBook.CalcFields("Book Value");
        DisposalAmount := FADepreciationBook."Book Value" - LibraryRandom.RandInt(100);
        CreateAndPostFADisposalLine(FADepreciationBook, DisposalAmount, DisposalDate, DisposalDoc);
        RunCalDeprAndVerifyFirstYrUtilise(FAJournalLine, FixedAsset."No.", DepreciationBook.Code, DocNo, DeprAmount, NewPostingDate, false, true);
    end;

    [Test]
    [HandlerFunctions('DepreciationNotCalculatedMsgHandler')]
    procedure VerifyDepreciationDecliningBalanceBlockAllAssetSoldAboveWDV()
    var
        DepreciationBook: Record "Depreciation Book";
        FAJournalLine: Record "FA Journal Line";
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        DepreciationMethod: Enum "Depreciation Method";
        DeprAmount: Decimal;
        DocNo: Code[20];
        NewPostingDate: Date;
        DisposalAmount: Decimal;
        DisposalDate: Date;
        DisposalDoc: Code[20];
    begin
        //  [SCENARIO] [383313] Depreciation calculation for a Block of Assets where all the assets of that block have been sold for a consideration greater than the WDV of the block
        Initialize();

        // [GIVEN] Created,Aquired Fixed Asset and checked FA Value.        
        CreateAcquireAndVerifyFAValueWithIncTaxDepBook(DepreciationBook, FixedAsset, FADepreciationBook, DepreciationMethod::"Declining-Balance 1", false);

        // [WHEN] Post FA Journal for Disposal. Calculate depreciation for full Year and check depreciation value.
        FADepreciationBook.CalcFields("Book Value");
        DisposalAmount := FADepreciationBook."Book Value" + LibraryRandom.RandInt(100);
        CreateAndPostFADisposalLine(FADepreciationBook, DisposalAmount, DisposalDate, DisposalDoc);
        RunCalDeprAndVerifyFirstYrUtilise(FAJournalLine, FixedAsset."No.", DepreciationBook.Code, DocNo, DeprAmount, NewPostingDate, false, true);
    end;

    [Test]
    [HandlerFunctions('PostConfirmation')]
    procedure VerifyDepreciationDecliningBalanceBlockOneAssetSoldAboveWDV()
    var
        DepreciationBook: Record "Depreciation Book";
        FAJournalLine: Record "FA Journal Line";
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        FixedAsset2: Record "Fixed Asset";
        FADepreciationBook2: Record "FA Depreciation Book";
        DepreciationMethod: Enum "Depreciation Method";
        DeprAmount: Decimal;
        DocNo: Code[20];
        NewPostingDate: Date;
        DisposalAmount: Decimal;
        DisposalDate: Date;
        DisposalDoc: Code[20];
        FAValueOld: Decimal;
        BlockValueOld: Decimal;
    begin
        //  [SCENARIO] [383199] Depreciation calculation for a Block of Assets where a part of the block has been sold for a consideration greater than the WDV of the block
        Initialize();

        // [GIVEN] Created,Aquired Fixed Asset and checked FA Value.        
        CreateAcquireAndVerifyFAValueWithIncTaxDepBook(DepreciationBook, FixedAsset, FADepreciationBook, DepreciationMethod::"Declining-Balance 1", false);
        CreateAcquireAndVerifyFAValueWithIncTaxDepBook(DepreciationBook, FixedAsset2, FADepreciationBook2, DepreciationMethod::"Declining-Balance 1", false);

        // [WHEN] Post FA Journal for Disposal. Calculate depreciation for full Year and check depreciation value.Post FA Journal for Depreciation.
        FADepreciationBook.CalcFields("Book Value");
        FADepreciationBook2.CalcFields("Book Value");
        DisposalAmount := FADepreciationBook2."Book Value" + LibraryRandom.RandInt(100);
        CreateAndPostFADisposalLine(FADepreciationBook2, DisposalAmount, DisposalDate, DisposalDoc);
        RunCalDeprAndVerifyFirstYrUtilise(FAJournalLine, FixedAsset."No.", DepreciationBook.Code, DocNo, DeprAmount, NewPostingDate, false, true);
        GetFAAndBlockValue(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld);
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);

        // [THEN] FA Book Value, Block Value and FA ledger Entries are created
        VerifyFAValueAfterDepreciation(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld, DeprAmount);
        VerifyFALedgerEntriesFirstYrUtilise(DepreciationBook, FixedAsset, FADepreciationBook, DocNo, DeprAmount, NewPostingDate, false, true);
    end;

    [Test]
    [HandlerFunctions('PostConfirmation')]
    procedure VerifyDepreciationDecliningBalanceBlockOneAssetSoldBelowWDV()
    var
        DepreciationBook: Record "Depreciation Book";
        FAJournalLine: Record "FA Journal Line";
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        FixedAsset2: Record "Fixed Asset";
        FADepreciationBook2: Record "FA Depreciation Book";
        DepreciationMethod: Enum "Depreciation Method";
        DeprAmount: Decimal;
        DocNo: Code[20];
        NewPostingDate: Date;
        DisposalAmount: Decimal;
        DisposalDate: Date;
        DisposalDoc: Code[20];
        FAValueOld: Decimal;
        BLockValueOld: Decimal;
    begin
        //  [SCENARIO] [383210] Depreciation calculation for a Block of Assets where a part of the block has been sold for a consideration lesser than the WDV of the block
        Initialize();

        // [GIVEN] Created,Aquired Fixed Asset and checked FA Value.        
        CreateAcquireAndVerifyFAValueWithIncTaxDepBook(DepreciationBook, FixedAsset, FADepreciationBook, DepreciationMethod::"Declining-Balance 1", false);
        CreateAcquireAndVerifyFAValueWithIncTaxDepBook(DepreciationBook, FixedAsset2, FADepreciationBook2, DepreciationMethod::"Declining-Balance 1", false);

        // [WHEN] Post FA Journal for Disposal. Calculate depreciation for full Year and check depreciation value.Post FA Journal for Depreciation.
        FADepreciationBook2.CalcFields("Book Value");
        DisposalAmount := FADepreciationBook2."Book Value" - LibraryRandom.RandInt(100);
        CreateAndPostFADisposalLine(FADepreciationBook2, DisposalAmount, DisposalDate, DisposalDoc);
        RunCalDeprAndVerifyFirstYrUtilise(FAJournalLine, FixedAsset."No.", DepreciationBook.Code, DocNo, DeprAmount, NewPostingDate, false, true);
        GetFAAndBlockValue(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld);
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);

        // [THEN] FA Book Value, Block Value and FA ledger Entries are created
        VerifyFAValueAfterDepreciation(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld, DeprAmount);
        VerifyFALedgerEntriesFirstYrUtilise(DepreciationBook, FixedAsset, FADepreciationBook, DocNo, DeprAmount, NewPostingDate, false, true);
    end;

    [Test]
    [HandlerFunctions('PostConfirmation')]
    procedure VerifyDepreciationDecliningBalanceAfterRevaluation()
    var
        DepreciationBook: Record "Depreciation Book";
        FAJournalLine: Record "FA Journal Line";
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        DepreciationMethod: Enum "Depreciation Method";
        DeprAmount: Decimal;
        FAValueOld: Decimal;
        BLockValueOld: Decimal;
        DocNo: Code[20];
        NewPostingDate: Date;
        AcquisitionAmount: Decimal;
    begin
        //  [SCENARIO] [382940] Check that the depreciation is being calculated in case of Revaluation of Fixed Asset
        Initialize();

        // [GIVEN] Created,Aquired Fixed Asset and checked FA Value.
        CreateAcquireAndVerifyFAValueWithIncTaxDepBook(DepreciationBook, FixedAsset, FADepreciationBook, DepreciationMethod::"Declining-Balance 1", false);
        CreateAndPostFAAcqusitionLine(FADepreciationBook, AcquisitionAmount);

        // [WHEN] Calculate depreciation for full Year and check depreciation value.Post FA Journal for Depreciation.
        RunCalDeprAndVerifyFirstYrUtilise(FAJournalLine, FixedAsset."No.", DepreciationBook.Code, DocNo, DeprAmount, NewPostingDate, false, true);
        GetFAAndBlockValue(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld);
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);

        // [THEN] FA Book Value, Block Value and FA ledger Entries are created
        VerifyFAValueAfterDepreciation(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld, DeprAmount);
        VerifyFALedgerEntriesFirstYrUtilise(DepreciationBook, FixedAsset, FADepreciationBook, DocNo, DeprAmount, NewPostingDate, false, true);
    end;

    [Test]
    procedure VerifyFAStockUponNewFAPurchaseWithCompanyDepBook()
    var
        DepreciationBook: Record "Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        FAClass: Record "FA Class";
        FixedAssetBlock: Record "Fixed Asset Block";
        FASubclass: Record "FA Subclass";
        FALocation: Record "FA Location";
        FADepreciationBook: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
        DepreciationMethod: Enum "Depreciation Method";
        AcquisitionAmount: Decimal;
        AssetNo: Integer;
        BlockBookValue: Decimal;
        FALedgerEntryFAPostingType: Enum "FA Ledger Entry FA Posting Type";
    begin
        //  [SCENARIO] [382952] Acquisition of new FA through Purchase Invoice
        Initialize();

        // [GIVEN] Created Fixed Asset Setup as per Income Tax Act
        CreateFABasicsWithCompanyDepBook(DepreciationBook, FAClass, FixedAssetBlock, FASubclass, FALocation, FAPostingGroup);
        InitializeBlockValue(FixedAssetBlock, AssetNo, BlockBookValue);
        CreateNewFixedAsset(FixedAsset, FAClass.Code, FASubclass.Code, FALocation.Code, FixedAssetBlock.Code, false);
        CreateFADepreciationBookWithCompanyDepBook(FADepreciationBook, FixedAsset."No.", DepreciationBook.Code, DepreciationMethod::"Straight-Line", FixedAssetBlock."Depreciation %");

        // [WHEN] Post Purchase Document for Acquisition
        CreateAndPostPurchaseInvoice(FixedAsset, AcquisitionAmount);

        // [THEN] FA Book Value and Block Value are created
        CheckFAValueAndBookValue(FADepreciationBook, FixedAsset, AcquisitionAmount, AssetNo, BlockBookValue);
        VerifyAmountInFALedgerEntry(FixedAsset."No.", FALedgerEntryFAPostingType::"Acquisition Cost", AcquisitionAmount);
    end;

    [Test]
    [HandlerFunctions('PostConfirmation')]
    procedure VerifyDepreciationDecliningBalanceWithCompanyDepBook()
    var
        DepreciationBook: Record "Depreciation Book";
        FAGLJournalLine: Record "Gen. Journal Line";
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        DepreciationMethod: Enum "Depreciation Method";
        DeprAmount: Decimal;
        FAValueOld: Decimal;
        BLockValueOld: Decimal;
        DocNo: Code[20];
        NewPostingDate: Date;
    begin
        //  [SCENARIO] [383159] Check if the system is calculating depreciation on Written down Value method
        Initialize();

        // [GIVEN] Created,Aquired Fixed Asset and checked FA Value.
        CreateAcquireAndVerifyFAValueWithCompanyDepBook(DepreciationBook, FixedAsset, FADepreciationBook, DepreciationMethod::"Declining-Balance 1", false);

        // [WHEN] Calculate depreciation for full Year and check depreciation value.Post FA Journal for Depreciation.
        RunCalDeprAndVerifyFirstYrUtiliseWithCompanyDepBook(FAGLJournalLine, FixedAsset."No.", DepreciationBook.Code, DocNo, DeprAmount, NewPostingDate, true);
        GetFAAndBlockValue(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld);
        LibraryERM.PostGeneralJnlLine(FAGLJournalLine);

        // [THEN] FA Book Value, Block Value and FA ledger Entries are created
        VerifyFAValueAfterDepreciation(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld, DeprAmount);
        VerifyFALedgerEntriesFirstYrUtilise(DepreciationBook, FixedAsset, FADepreciationBook, DocNo, DeprAmount, NewPostingDate, false, true);
    end;

    [Test]
    [HandlerFunctions('PostConfirmation')]
    procedure VerifyDepreciationStraightLineSeasonalWithCompanyDepBook()
    var
        DepreciationBook: Record "Depreciation Book";
        FAGLJournalLine: Record "Gen. Journal Line";
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        FixedAssetShift: Record "Fixed Asset Shift";
        DepreciationMethod: Enum "Depreciation Method";
        ShiftType: Enum "Shift Type";
        IndustryType: Enum "Industry type";
        DeprAmount: Decimal;
        FAValueOld: Decimal;
        BLockValueOld: Decimal;
        DocNo: Code[20];
        NewPostingDate: Date;
    begin
        //  [SCENARIO] [383159] Check if the system is calculating depreciation on Written down Value method
        Initialize();

        // [GIVEN] Created,Aquired Fixed Asset and checked FA Value.
        CreateAcquireAndVerifyFAValueWithCompanyDepBook(DepreciationBook, FixedAsset, FADepreciationBook, DepreciationMethod::"Straight-Line", false);
        UpdateFAShift(FixedAsset, FADepreciationBook, FixedAssetShift, ShiftType::Double, IndustryType::Seasonal);

        // [WHEN] Calculate depreciation for full Year and check depreciation value.Post FA Journal for Depreciation.
        RunCalDeprAndVerifyFirstYrUtiliseWithCompanyDepBook(FAGLJournalLine, FixedAsset."No.", DepreciationBook.Code, DocNo, DeprAmount, NewPostingDate, true);
        GetFAAndBlockValue(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld);
        LibraryERM.PostGeneralJnlLine(FAGLJournalLine);

        // [THEN] FA Book Value, Block Value and FA ledger Entries are created
        VerifyFAValueAfterDepreciation(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld, DeprAmount);
        VerifyFALedgerEntriesFirstYrUtilise(DepreciationBook, FixedAsset, FADepreciationBook, DocNo, DeprAmount, NewPostingDate, false, true);
    end;

    [Test]
    [HandlerFunctions('PostConfirmation')]
    procedure VerifyDepreciationStraightLineNonSeasonalWithCompanyDepBook()
    var
        DepreciationBook: Record "Depreciation Book";
        FAGLJournalLine: Record "Gen. Journal Line";
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        FixedAssetShift: Record "Fixed Asset Shift";
        DepreciationMethod: Enum "Depreciation Method";
        ShiftType: Enum "Shift Type";
        IndustryType: Enum "Industry type";
        DeprAmount: Decimal;
        FAValueOld: Decimal;
        BLockValueOld: Decimal;
        DocNo: Code[20];
        NewPostingDate: Date;
    begin
        //  [SCENARIO] [383159] Check if the system is calculating depreciation on Written down Value method
        Initialize();

        // [GIVEN] Created,Aquired Fixed Asset and checked FA Value.
        CreateAcquireAndVerifyFAValueWithCompanyDepBook(DepreciationBook, FixedAsset, FADepreciationBook, DepreciationMethod::"Straight-Line", false);
        UpdateFAShift(FixedAsset, FADepreciationBook, FixedAssetShift, ShiftType::Double, IndustryType::"Non Seasonal");

        // [WHEN] Calculate depreciation for full Year and check depreciation value.Post FA Journal for Depreciation.
        RunCalDeprAndVerifyFirstYrUtiliseWithCompanyDepBook(FAGLJournalLine, FixedAsset."No.", DepreciationBook.Code, DocNo, DeprAmount, NewPostingDate, true);
        GetFAAndBlockValue(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld);
        LibraryERM.PostGeneralJnlLine(FAGLJournalLine);

        // [THEN] FA Book Value, Block Value and FA ledger Entries are created
        VerifyFAValueAfterDepreciation(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld, DeprAmount);
        VerifyFALedgerEntriesFirstYrUtilise(DepreciationBook, FixedAsset, FADepreciationBook, DocNo, DeprAmount, NewPostingDate, false, true);
    end;

    [Test]
    [HandlerFunctions('PostConfirmation')]
    procedure VerifyDepreciationStraightLineWithResidualWithCompanyDepBook()
    var
        DepreciationBook: Record "Depreciation Book";
        FAGLJournalLine: Record "Gen. Journal Line";
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        DepreciationMethod: Enum "Depreciation Method";
        DeprAmount: Decimal;
        FAValueOld: Decimal;
        BLockValueOld: Decimal;
        DocNo: Code[20];
        NewPostingDate: Date;
    begin
        //  [SCENARIO] [382959] Check if the system is calculating Depreciation as per asset useful life with residual value
        Initialize();

        // [GIVEN] Created,Aquired Fixed Asset and checked FA Value.
        CreateAcquireAndVerifyFAValueWithCompanyDepBook(DepreciationBook, FixedAsset, FADepreciationBook, DepreciationMethod::"Declining-Balance 1", false);

        // [WHEN] Calculate depreciation for full Year and check depreciation value.Post FA Journal for Depreciation.
        RunCalDeprAndVerifyFirstYrUtiliseWithCompanyDepBook(FAGLJournalLine, FixedAsset."No.", DepreciationBook.Code, DocNo, DeprAmount, NewPostingDate, true);
        GetFAAndBlockValue(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld);
        LibraryERM.PostGeneralJnlLine(FAGLJournalLine);

        // [THEN] FA Book Value, Block Value and FA ledger Entries are created
        VerifyFAValueAfterDepreciation(FixedAsset, FADepreciationBook, FAValueOld, BLockValueOld, DeprAmount);
        VerifyFALedgerEntriesFirstYrUtilise(DepreciationBook, FixedAsset, FADepreciationBook, DocNo, DeprAmount, NewPostingDate, false, true);
    end;

    [Test]
    [HandlerFunctions('PostConfirmation')]
    procedure VerifyNumberofDaysCalculationForLeapYear()
    var
        DepreciationBook: Record "Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        FAClass: Record "FA Class";
        FixedAssetBlock: Record "Fixed Asset Block";
        FASubclass: Record "FA Subclass";
        FALocation: Record "FA Location";
        FADepreciationBook: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
        DepreciationMethod: Enum "Depreciation Method";
        DocNo: Code[20];
        AcquisitionAmount: Decimal;
    begin
        // [SCENARIO] [497185] Calculate number of days in leap year while calculating FA Depreciation Report
        InitializeFAIncomeTaxPeriod(DMY2Date(01, 01, 2024));

        // [GIVEN] Create FA Card and depreciation book with Straight Line for 3 Years
        CreateFABasicsWithCompanyDepBook(DepreciationBook, FAClass, FixedAssetBlock, FASubclass, FALocation, FAPostingGroup);
        CreateNewFixedAsset(FixedAsset, FAClass.Code, FASubclass.Code, FALocation.Code, '', false);
        CreateFADepreciationBookWithCompanyDepBookForLeapYear(FADepreciationBook, FixedAsset."No.", DepreciationBook.Code, DepreciationMethod::"Straight-Line", 0, DMY2Date(01, 01, 2024), 3);
        CreateAndPostPurchaseInvoice(FixedAsset, AcquisitionAmount);
        UpdateFiscalYear365DaysInDeprBook(DepreciationBook, true);


        // [WHEN] Run FA Depreciation Report for Leap Year
        RunCalculateDepreciation(FixedAsset."No.", DepreciationBook.Code, false, GetFiscalYearEndDateInc(DMY2Date(01, 01, 2024)), DocNo);

        // [THEN] Check Number of Days For Leap Year
        VerifyNumberofDaysInGenJournalLine(DocNo, GetFiscalYearEndDateInc(DMY2Date(01, 01, 2024)), 91);
    end;

    local procedure InitializeFAIncomeTaxPeriod(StartDate: Date)
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        WorkDate := System.WorkDate(DMY2Date(01, 01, 2024));
        CreateFAIncomeTaxAccPeriod(StartDate);
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        CreateFAIncomeTaxAccPeriod(WorkDate());
    end;

    local procedure CreateFAIncomeTaxAccPeriod(CurrentDate: Date)
    var
        FAAccountingPeriodIncTax: Record "FA Accounting Period Inc. Tax";
        PeriodLength: DateFormula;
        StartingDate: Date;
        FiscalYearStartDate: Date;
        i: Integer;
    begin
        StartingDate := CalcDate('<CY+1D-1Y>', CurrentDate);

        FiscalYearStartDate := StartingDate;
        Evaluate(PeriodLength, '<1M>');

        for i := 1 to 13 do begin
            FAAccountingPeriodIncTax.Init();
            FAAccountingPeriodIncTax."Starting Date" := FiscalYearStartDate;
            FAAccountingPeriodIncTax.Validate("Starting Date");
            if (i = 1) or (i = 13) then
                FAAccountingPeriodIncTax."New Fiscal Year" := true;
            if not FAAccountingPeriodIncTax.Find() then
                FAAccountingPeriodIncTax.Insert();
            FiscalYearStartDate := CalcDate(PeriodLength, FiscalYearStartDate);
        end;
    end;

    local procedure CreateAcquireAndVerifyFAValueWithCompanyDepBook(
        var DepreciationBook: Record "Depreciation Book";
        var FixedAsset: Record "Fixed Asset";
        var FADepreciationBook: Record "FA Depreciation Book";
        DepreciationMethod: Enum "Depreciation Method";
        AddlDep: Boolean)
    var
        FAClass: Record "FA Class";
        FixedAssetBlock: Record "Fixed Asset Block";
        FASubclass: Record "FA Subclass";
        FALocation: Record "FA Location";
        FAPostingGroup: Record "FA Posting Group";
        AcquisitionAmount: Decimal;
        AssetNo: Integer;
        BlockBookValue: Decimal;
    begin
        CreateFABasicsWithCompanyDepBook(DepreciationBook, FAClass, FixedAssetBlock, FASubclass, FALocation, FAPostingGroup);
        InitializeBlockValue(FixedAssetBlock, AssetNo, Blockbookvalue);
        CreateNewFixedAsset(FixedAsset, FAClass.Code, FASubclass.Code, FALocation.Code, FixedAssetBlock.Code, AddlDep);
        CreateFADepreciationBookWithCompanyDepBook(FADepreciationBook, FixedAsset."No.", DepreciationBook.Code, DepreciationMethod, FixedAssetBlock."Depreciation %");
        CreateAndPostPurchaseInvoice(FixedAsset, AcquisitionAmount);
        CheckFAValueAndBookValue(FADepreciationBook, FixedAsset, AcquisitionAmount, AssetNo, Blockbookvalue);
    end;

    local procedure CreateAcquireAndVerifyFAValueWithIncTaxDepBook(
        var DepreciationBook: Record "Depreciation Book";
        var FixedAsset: Record "Fixed Asset";
        var FADepreciationBook: Record "FA Depreciation Book";
        DepreciationMethod: Enum "Depreciation Method";
                                AddlDep: Boolean)
    var
        FAClass: Record "FA Class";
        FixedAssetBlock: Record "Fixed Asset Block";
        FASubclass: Record "FA Subclass";
        FALocation: Record "FA Location";
        FAPostingGroup: Record "FA Posting Group";
        AcquisitionAmount: Decimal;
        AssetNo: Integer;
        BlockBookValue: Decimal;
    begin
        CreateFABasicsWithIncTaxDepBook(DepreciationBook, FAClass, FixedAssetBlock, FASubclass, FALocation, FAPostingGroup);
        InitializeBlockValue(FixedAssetBlock, AssetNo, Blockbookvalue);
        CreateNewFixedAsset(FixedAsset, FAClass.Code, FASubclass.Code, FALocation.Code, FixedAssetBlock.Code, AddlDep);
        CreateFADepreciationBookWithIncTaxDepBook(FADepreciationBook, FixedAsset."No.", DepreciationBook.Code, DepreciationMethod, FixedAssetBlock."Depreciation %");
        CreateAndPostFAAcqusitionLine(FADepreciationBook, AcquisitionAmount);
        CheckFAValueAndBookValue(FADepreciationBook, FixedAsset, AcquisitionAmount, AssetNo, Blockbookvalue);
    end;

    local procedure CreateFABasicsWithCompanyDepBook(
        var DepreciationBook: Record "Depreciation Book";
        var FAClass: Record "FA Class";
        var FixedAssetBlock: Record "Fixed Asset Block";
        var FASubclass: Record "FA Subclass";
        var FALocation: Record "FA Location";
        var FAPostingGroup: Record "FA Posting Group")
    begin
        CreateAndValidateDepreciationBook(DepreciationBook, CompanyLbl, false);
        LibraryFixedAsset.CreateFAClass(FAClass);
        CreateAndValidateFABlock(FixedAssetBlock, FAClass.Code);
        LibraryFixedAsset.CreateFASubclass(FASubclass);
        CreateFALocation(FALocation);
        LibraryFixedAsset.CreateFAPostingGroup(FAPostingGroup);
    end;

    local procedure CreateFABasicsWithIncTaxDepBook(
        var DepreciationBook: Record "Depreciation Book";
        var FAClass: Record "FA Class";
        var FixedAssetBlock: Record "Fixed Asset Block";
        var FASubclass: Record "FA Subclass";
        var FALocation: Record "FA Location";
        var FAPostingGroup: Record "FA Posting Group")
    begin
        CreateAndValidateDepreciationBook(DepreciationBook, IncomeTaxLbl, true);
        LibraryFixedAsset.CreateFAClass(FAClass);
        CreateAndValidateFABlock(FixedAssetBlock, FAClass.Code);
        LibraryFixedAsset.CreateFASubclass(FASubclass);
        CreateFALocation(FALocation);
        LibraryFixedAsset.CreateFAPostingGroup(FAPostingGroup);
    end;

    local procedure CreateAndValidateDepreciationBook(var DepreciationBook: Record "Depreciation Book"; DepreciationBookCode: Code[10]; ThresholdApplicable: Boolean)
    begin
        DepreciationBook.SetRange(Code, DepreciationBookCode);
        if DepreciationBook.FindSet() then
            exit;

        CreateDepreciationBook(DepreciationBook, DepreciationBookCode);
        ValidateDeprBook(DepreciationBook, ThresholdApplicable);
        CreateAndValidateFAJournalSetup(DepreciationBook);
    end;

    local procedure CreateDepreciationBook(var DepreciationBook: Record "Depreciation Book"; DepreciationBookCode: Code[10])
    begin
        DepreciationBook.SetRange(Code, DepreciationBookCode);
        if DepreciationBook.FindSet() then
            exit;

        DepreciationBook.Init();
        DepreciationBook.Validate(Code, DepreciationBookCode);
        if DepreciationBook.Code = IncomeTaxLbl then
            DepreciationBook.Validate("FA Book Type", DepreciationBook."FA Book Type"::"Income Tax");
        DepreciationBook.Validate(Description, DepreciationBook.Code);
        DepreciationBook.Insert(true);
    end;

    local procedure ValidateDeprBook(DepreciationBook: Record "Depreciation Book"; ThresholdApplicable: Boolean)
    begin
        if ThresholdApplicable then begin
            DepreciationBook.Validate("Depr. Threshold Days", 180);
            DepreciationBook.Validate("Depr. Reduction %", 50);
        end;
        DepreciationBook.Validate("Allow Changes in Depr. Fields", true);
        DepreciationBook.Validate("G/L Integration - Acq. Cost", false);
        DepreciationBook.Validate("G/L Integration - Appreciation", false);
        DepreciationBook.Validate("G/L Integration - Custom 1", false);
        DepreciationBook.Validate("G/L Integration - Custom 2", false);
        DepreciationBook.Validate("G/L Integration - Depreciation", false);
        DepreciationBook.Validate("G/L Integration - Disposal", false);
        DepreciationBook.Validate("G/L Integration - Maintenance", false);
        DepreciationBook.Validate("G/L Integration - Write-Down", false);
        DepreciationBook.Modify(true);
    end;

    local procedure CreateAndValidateFAJournalSetup(DepreciationBook: Record "Depreciation Book")
    var
        FAJournalSetup: Record "FA Journal Setup";
        DefautFAJournalSetup: Record "FA Journal Setup";
    begin
        LibraryFixedAsset.CreateFAJournalSetup(FAJournalSetup, DepreciationBook.Code, '');
        DefautFAJournalSetup.SetRange("Depreciation Book Code", LibraryFixedAsset.GetDefaultDeprBook());
        DefautFAJournalSetup.FindFirst();
        FAJournalSetup.TransferFields(DefautFAJournalSetup, false);
        FAJournalSetup.Modify(true);
    end;

    local procedure CreateAndValidateFABlock(var FixedAssetBlock: Record "Fixed Asset Block"; FAClassCode: Code[10])
    begin
        CreateFABlock(FixedAssetBlock, FAClassCode);
        FixedAssetBlock.Validate("Depreciation %", LibraryRandom.RandInt(10));
        FixedAssetBlock.Validate("Add. Depreciation %", LibraryRandom.RandInt(10));
        FixedAssetBlock.Modify(true);
        StorageDec.Set(XDepRateTok, FixedAssetBlock."Depreciation %");
        StorageDec.Set(XAddlDepRateTok, FixedAssetBlock."Add. Depreciation %");
    end;

    local procedure CreateFABlock(var FixedAssetBlock: Record "Fixed Asset Block"; FAClassCode: Code[10])
    begin
        FixedAssetBlock.Init();
        FixedAssetBlock.Validate("FA Class Code", FAClassCode);
        FixedAssetBlock.Code := CopyStr(
                LibraryUtility.GenerateRandomCode(FixedAssetBlock.FieldNo(Code), Database::"Fixed Asset Block"),
                1, LibraryUtility.GetFieldLength(Database::"Fixed Asset Block", FixedAssetBlock.FieldNo(Code)));
        FixedAssetBlock.Validate(Description, FixedAssetBlock.Code + ' ' + FixedAssetBlock."FA Class Code");
        FixedAssetBlock.Insert(true);
    end;

    local procedure CreateFALocation(var FALocation: Record "FA Location")
    begin
        FALocation.Init();
        FALocation.Validate(
            Code,
            CopyStr(
                LibraryUtility.GenerateRandomCode(FALocation.FieldNo(Code), Database::"FA Location"), 1,
                LibraryUtility.GetFieldLength(Database::"FA Location", FALocation.FieldNo(Code))));
        FALocation.Insert(true);
    end;

    local procedure InitializeBlockValue(FixedAssetBlock: Record "Fixed Asset Block"; var AssetNo: Integer; var BlockBookValue: Decimal)
    begin
        FixedAssetBlock.CalcFields("No. of Assets", "Book Value");
        AssetNo := FixedAssetBlock."No. of Assets";
        BlockBookValue := FixedAssetBlock."Book Value";
    end;

    local procedure CreateNewFixedAsset(var FixedAsset: Record "Fixed Asset"; FAClass: Code[10]; FASubClass: Code[10]; FALocation: Code[10]; FixedAssetBlock: Code[10]; AddlDep: Boolean)
    begin
        LibraryFixedAsset.CreateFAWithPostingGroup(FixedAsset);
        FixedAsset.Validate("Add. Depr. Applicable", AddlDep);
        FixedAsset.Validate("FA Class Code", FAClass);
        FixedAsset.Validate("FA Subclass Code", FASubClass);
        FixedAsset.Validate("FA Location Code", FALocation);
        FixedAsset.Validate("FA Block Code", FixedAssetBlock);
        FixedAsset.Modify(true);
    end;

    local procedure CreateFADepreciationBookWithCompanyDepBook(
        var FADepreciationBook: Record "FA Depreciation Book";
        FANo: Code[20];
        DepreciationBookCode: Code[10];
        DepreciationMethod: Enum "Depreciation Method";
        DepreciationPct: Decimal)
    var
        FixedAsset: Record "Fixed Asset";
    begin
        FixedAsset.Get(FANo);
        LibraryFixedAsset.CreateFADepreciationBook(FADepreciationBook, FANo, DepreciationBookCode);
        FADepreciationBook.Validate("FA Book Type", FADepreciationBook."FA Book Type"::" ");
        FADepreciationBook.Validate("Depreciation Method", DepreciationMethod);
        FADepreciationBook.Validate("Depreciation Starting Date", GetFiscalYearStartDateInc(WorkDate()));
        Case FADepreciationBook."Depreciation Method" of
            FADepreciationBook."Depreciation Method"::"Straight-Line":
                FADepreciationBook.Validate("Straight-Line %", DepreciationPct);
            FADepreciationBook."Depreciation Method"::"Declining-Balance 1":
                FADepreciationBook.Validate("Declining-Balance %", DepreciationPct);
        end;
        FADepreciationBook.Validate("FA Posting Group", FixedAsset."FA Posting Group");
        FADepreciationBook.Modify(true);
        Case FADepreciationBook."Depreciation Method" of
            FADepreciationBook."Depreciation Method"::"Straight-Line":
                LibraryAssert.AreNearlyEqual(DepreciationPct, FADepreciationBook."Straight-Line %", 1,
                StrSubstNo(AmountErr, FADepreciationBook.FieldCaption("Straight-Line %"), FADepreciationBook.TableCaption));
            FADepreciationBook."Depreciation Method"::"Declining-Balance 1":
                LibraryAssert.AreNearlyEqual(DepreciationPct, FADepreciationBook."Declining-Balance %", 1,
                StrSubstNo(AmountErr, FADepreciationBook.FieldCaption("Declining-Balance %"), FADepreciationBook.TableCaption));
        end;
    end;

    local procedure CreateFADepreciationBookWithCompanyDepBookForLeapYear(
        var FADepreciationBook: Record "FA Depreciation Book";
        FANo: Code[20];
        DepreciationBookCode: Code[10];
        DepreciationMethod: Enum "Depreciation Method";
        DepreciationPct: Decimal;
        LeapYearDate: Date;
        NoofYears: Integer)
    var
        FixedAsset: Record "Fixed Asset";
    begin
        FixedAsset.Get(FANo);
        LibraryFixedAsset.CreateFADepreciationBook(FADepreciationBook, FANo, DepreciationBookCode);
        FADepreciationBook.Validate("FA Book Type", FADepreciationBook."FA Book Type"::" ");
        FADepreciationBook.Validate("Depreciation Method", DepreciationMethod);
        FADepreciationBook.Validate("Depreciation Starting Date", GetFiscalYearStartDateInc(LeapYearDate));
        Case FADepreciationBook."Depreciation Method" of
            FADepreciationBook."Depreciation Method"::"Straight-Line":
                FADepreciationBook.Validate("Straight-Line %", DepreciationPct);
            FADepreciationBook."Depreciation Method"::"Declining-Balance 1":
                FADepreciationBook.Validate("Declining-Balance %", DepreciationPct);
        end;
        FADepreciationBook.Validate("FA Posting Group", FixedAsset."FA Posting Group");
        FADepreciationBook.Validate("No. of Depreciation Years", NoofYears);
        FADepreciationBook.Validate("Acquisition Date", GetFiscalYearStartDateInc(LeapYearDate));
        FADepreciationBook.Modify(true);
        Case FADepreciationBook."Depreciation Method" of
            FADepreciationBook."Depreciation Method"::"Straight-Line":
                LibraryAssert.AreNearlyEqual(DepreciationPct, FADepreciationBook."Straight-Line %", 1,
                StrSubstNo(AmountErr, FADepreciationBook.FieldCaption("Straight-Line %"), FADepreciationBook.TableCaption));
            FADepreciationBook."Depreciation Method"::"Declining-Balance 1":
                LibraryAssert.AreNearlyEqual(DepreciationPct, FADepreciationBook."Declining-Balance %", 1,
                StrSubstNo(AmountErr, FADepreciationBook.FieldCaption("Declining-Balance %"), FADepreciationBook.TableCaption));
        end;
    end;

    local procedure UpdateFiscalYear365DaysInDeprBook(var DepreciationBook: Record "Depreciation Book"; FiscalYear365Days: Boolean)
    begin
        DepreciationBook.Validate("Fiscal Year 365 Days", FiscalYear365Days);
        DepreciationBook.Modify();
    end;

    local procedure CreateFADepreciationBookWithIncTaxDepBook(
        var FADepreciationBook: Record "FA Depreciation Book";
        FANo: Code[20];
        DepreciationBookCode: Code[10];
        DepreciationMethod: Enum "Depreciation Method";
        DepreciationPct: Decimal)
    begin
        LibraryFixedAsset.CreateFADepreciationBook(FADepreciationBook, FANo, DepreciationBookCode);
        FADepreciationBook.Validate("FA Book Type", FADepreciationBook."FA Book Type"::"Income Tax");
        FADepreciationBook.Validate("Depreciation Method", DepreciationMethod);
        FADepreciationBook.Validate("Depreciation Starting Date", GetFiscalYearStartDateInc(WorkDate()));
        FADepreciationBook.Modify(true);
        Case FADepreciationBook."Depreciation Method" of
            FADepreciationBook."Depreciation Method"::"Straight-Line":
                LibraryAssert.AreNearlyEqual(DepreciationPct, FADepreciationBook."Straight-Line %", 1,
                StrSubstNo(AmountErr, FADepreciationBook.FieldCaption("Straight-Line %"), FADepreciationBook.TableCaption));
            FADepreciationBook."Depreciation Method"::"Declining-Balance 1":
                LibraryAssert.AreNearlyEqual(DepreciationPct, FADepreciationBook."Declining-Balance %", 1,
                StrSubstNo(AmountErr, FADepreciationBook.FieldCaption("Declining-Balance %"), FADepreciationBook.TableCaption));
        end;
    end;

    local procedure GetFiscalYearStartDateInc(EndingDate: Date): Date
    var
        FAAccountingPeriodIncTax: Record "FA Accounting Period Inc. Tax";
    begin
        FAAccountingPeriodIncTax.SetRange("New Fiscal Year", true);
        FAAccountingPeriodIncTax.SetRange("Starting Date", 0D, EndingDate);
        if FAAccountingPeriodIncTax.FindLast() then
            exit(FAAccountingPeriodIncTax."Starting Date");
    end;

    local procedure GetFiscalYearEndDateInc(EndingDate: Date): Date
    var
        FAAccountingPeriodIncTax: Record "FA Accounting Period Inc. Tax";
    begin
        FAAccountingPeriodIncTax.SetRange("New Fiscal Year", true);
        FAAccountingPeriodIncTax.SetFilter("Starting Date", '>%1', EndingDate);
        if FAAccountingPeriodIncTax.FindFirst() then
            exit(FAAccountingPeriodIncTax."Starting Date" - 1);
    end;

    local procedure CreateAndPostFAAcqusitionLine(FADepreciationBook: Record "FA Depreciation Book"; var Amount: Decimal)
    var
        FAJournalLine: Record "FA Journal Line";
    begin
        CreateFAJournalLine(FAJournalLine, FADepreciationBook."FA No.", FADepreciationBook."Depreciation Book Code", FAJournalLine."FA Posting Type"::"Acquisition Cost");
        Amount := FAJournalLine.Amount;
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);
    end;

    local procedure CreateFAJournalLine(
        var FAJournalLine: Record "FA Journal Line";
        FANo: Code[20];
        DepreciationBookCode: Code[10];
        FAPostingType: Enum "FA Journal Line FA Posting Type")
    var
        FAJournalBatch: Record "FA Journal Batch";
        FAJournalTemplate: Record "FA Journal Template";
    begin
        FAJournalTemplate.SetRange(Recurring, false);
        LibraryFixedAsset.CreateJournalTemplate(FAJournalTemplate);
        LibraryFixedAsset.CreateFAJournalBatch(FAJournalBatch, FAJournalTemplate.Name);
        FAJournalBatch.Validate("No. Series", LibraryUtility.GetGlobalNoSeriesCode());
        FAJournalBatch.Modify(true);
        LibraryFixedAsset.CreateFAJournalLine(FAJournalLine, FAJournalBatch."Journal Template Name", FAJournalBatch.Name);
        FAJournalLine.Validate("Document No.", GetDocumentNo(FAJournalBatch));
        FAJournalLine.Validate("Posting Date", GetFiscalYearStartDateInc(WorkDate()));
        FAJournalLine.Validate("FA Posting Date", GetFiscalYearStartDateInc(WorkDate()));
        FAJournalLine.Validate("FA Posting Type", FAPostingType);
        FAJournalLine.Validate("FA No.", FANo);
        FAJournalLine.Validate(Amount, LibraryRandom.RandIntInRange(1000, 1000));
        FAJournalLine.Validate("Depreciation Book Code", DepreciationBookCode);
        FAJournalLine.Modify(true);
    end;

    local procedure GetDocumentNo(FAJournalBatch: Record "FA Journal Batch"): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        NoSeries.Get(FAJournalBatch."No. Series");
        exit(NoSeriesManagement.GetNextNo(FAJournalBatch."No. Series", WorkDate(), FALSE));
    end;

    local procedure CheckFAValueAndBookValue(
        FADepreciationBook: Record "FA Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        ExpectedAmount: Decimal;
        AssetNo: Integer;
        BlockBookValue: Decimal)
    var
        FixedAssetBlock: Record "Fixed Asset Block";
    begin
        FADepreciationBook.CalcFields("Book Value");
        FixedAssetBlock.Get(FixedAsset."FA Class Code", FixedAsset."FA Block Code");
        FixedAssetBlock.CalcFields("No. of Assets", "Book Value");
        LibraryAssert.AreNearlyEqual(ExpectedAmount, FADepreciationBook."Book Value", 1,
            StrSubstNo(AmountErr, FADepreciationBook.FieldCaption("Book Value"), FADepreciationBook.TableCaption));
        if FADepreciationBook."Depreciation Book Code" = IncomeTaxLbl then begin
            LibraryAssert.AreNearlyEqual(ExpectedAmount, FixedAssetBlock."Book Value" - BlockBookValue, 1,
                StrSubstNo(AmountErr, FixedAssetBlock.FieldCaption("Book Value"), FixedAssetBlock.TableCaption));
            LibraryAssert.AreEqual(1, FixedAssetBlock."No. of Assets" - AssetNo,
                StrSubstNo(AmountErr, FixedAssetBlock.FieldCaption("No. of Assets"), FixedAssetBlock.TableCaption));
        end;
    end;

    local procedure RunCalDeprAndVerifyFirstYrUtilise(
        var FAJournalLine: Record "FA Journal Line";
        No: Code[20];
        DepreciationBookCode: Code[10];
        var DocNo: Code[20];
        var DeprAmount: Decimal;
        var NewPostingDate: Date;
        AddlDepApplicable: Boolean;
        FirstYearUtilizationFullYear: Boolean)
    var
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        DayCalculation: DateFormula;
    begin
        DepreciationBook.SetRange(Code, DepreciationBookCode);
        DepreciationBook.FindFirst();
        NewPostingDate := GetFiscalYearEndDateInc(WorkDate());
        FADepreciationBook.Get(No, DepreciationBookCode);
        if FirstYearUtilizationFullYear then
            Evaluate(DayCalculation, Format(-DepreciationBook."Depr. Threshold Days" - LibraryRandom.RandInt(DepreciationBook."Depr. Threshold Days")) + 'D')
        else
            Evaluate(DayCalculation, Format(-LibraryRandom.RandInt(DepreciationBook."Depr. Threshold Days")) + 'D');
        FADepreciationBook.Validate("Depreciation Starting Date", CalcDate(DayCalculation, NewPostingDate));
        FADepreciationBook.Modify();
        RunCalculateDepreciation(No, DepreciationBookCode, false, NewPostingDate, DocNo);
        if FirstYearUtilizationFullYear then
            VerifyDeprBeforePostingFullYr(FAJournalLine, NewPostingDate, DocNo, No, DepreciationBookCode, DeprAmount, AddlDepApplicable)
        else
            VerifyDeprBeforePostingHalfYr(FAJournalLine, NewPostingDate, DocNo, No, DepreciationBookCode, DeprAmount, AddlDepApplicable);
    end;

    local procedure RunCalDeprAndVerifyFirstYrUtiliseWithCompanyDepBook(
        var FAGLJournalLine: Record "Gen. Journal Line";
        No: Code[20];
        DepreciationBookCode: Code[10];
        var DocNo: Code[20];
        var DeprAmount: Decimal;
        var NewPostingDate: Date;
        FirstYearUtilizationFullYear: Boolean)
    var
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        DayCalculation: DateFormula;
    begin
        DepreciationBook.SetRange(Code, DepreciationBookCode);
        DepreciationBook.FindFirst();
        NewPostingDate := GetFiscalYearEndDateInc(WorkDate());
        FADepreciationBook.Get(No, DepreciationBookCode);
        case FADepreciationBook."Depreciation Method" of
            FADepreciationBook."Depreciation Method"::"Straight-Line":
                FADepreciationBook.Validate("Straight-Line %", StorageDec.Get(XDepRateTok));
            FADepreciationBook."Depreciation Method"::"Declining-Balance 1":
                FADepreciationBook.Validate("Declining-Balance %", StorageDec.Get(XDepRateTok));
        end;
        Evaluate(DayCalculation, Format(-DepreciationBook."Depr. Threshold Days" - LibraryRandom.RandInt(DepreciationBook."Depr. Threshold Days")) + 'D');
        FADepreciationBook.validate("Depreciation Starting Date", CalcDate(DayCalculation, NewPostingDate));
        FADepreciationBook.Modify();
        RunCalculateDepreciation(No, DepreciationBookCode, true, NewPostingDate, DocNo);
        if FirstYearUtilizationFullYear then
            VerifyDeprBeforePostingFullYrWithCompanyDepBook(FAGLJournalLine, NewPostingDate, DocNo, No, DepreciationBookCode, DeprAmount)
        else
            VerifyDeprBeforePostingHalfYrWithCompanyDepBook(FAGLJournalLine, NewPostingDate, DocNo, No, DepreciationBookCode, DeprAmount);
    end;

    local procedure RunCalculateDepreciation(No: Code[20]; DepreciationBookCode: Code[10]; BalAccount: Boolean; NewPostingDate: Date; VAR DocNo: Code[20])
    var
        FAJnlSetup: Record "FA Journal Setup";
        FixedAsset: Record "Fixed Asset";
        FAJournalBatch: Record "FA Journal Batch";
        CalculateDepreciation: Report "Calculate Depreciation";
    begin
        Clear(CalculateDepreciation);
        FixedAsset.SetRange("No.", No);
        FAJnlSetup.SetRange("Depreciation Book Code", DepreciationBookCode);
        FAJnlSetup.FindFirst();
        FAJournalBatch.SetRange("Journal Template Name", FAJnlSetup."FA Jnl. Template Name");
        FAJournalBatch.SetRange(Name, FAJnlSetup."FA Jnl. Batch Name");
        FAJournalBatch.FindFirst();
        DocNo := GetDocumentNo(FAJournalBatch);
        CalculateDepreciation.SetTableView(FixedAsset);
        CalculateDepreciation.InitializeRequest(DepreciationBookCode, NewPostingDate, false, 0, NewPostingDate, DocNo, FixedAsset.Description, BalAccount);
        CalculateDepreciation.UseRequestPage(false);
        CalculateDepreciation.Run();
    end;

    local procedure VerifyDeprBeforePostingFullYr(
        var FAJournalLine: Record "FA Journal Line";
        PostingDate: Date;
        DocNo: Code[20];
        FANo: Code[20];
        DeprBookCode: Code[10];
        var VerifyAmount: Decimal;
        AddlDepApplicable: Boolean)
    var
        FixedAsset: Record "Fixed Asset";
        AddDeprAmt: Decimal;
        DeprAmt: Decimal;
    begin
        FAJournalLine.SetRange("FA No.", FANo);
        FAJournalLine.SetRange("Document No.", DocNo);
        if FAJournalLine.FindFirst() then begin
            FAJournalLine.TestField("FA Posting Date", PostingDate);
            FAJournalLine.TestField("Depreciation Book Code", DeprBookCode);
            FAJournalLine.TestField("FA Posting Type", FAJournalLine."FA Posting Type"::Depreciation);
            FixedAsset.SetRange("No.", FANo);
            FixedAsset.FindFirst();
            GetDeprAmtFullYr(FixedAsset, DeprBookCode, AddDeprAmt, DeprAmt, AddlDepApplicable);
            VerifyAmount := AddDeprAmt + DeprAmt;
            LibraryAssert.AreNearlyEqual(VerifyAmount, -FAJournalLine.Amount, 1,
                StrSubstNo(AmountErr, FAJournalLine.FieldCaption(Amount), FAJournalLine.TableCaption));
        end;
    end;

    local procedure VerifyNumberofDaysInGenJournalLine(DocumentNo: Code[20]; PostingDate: Date; NumberofDays: Integer)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Document No.", DocumentNo);
        GenJournalLine.SetRange("Posting Date", PostingDate);
        GenJournalLine.FindFirst();
        LibraryAssert.AreNearlyEqual(GenJournalLine."No. of Depreciation Days", NumberofDays, 1,
        StrSubstNo(AmountErr, GenJournalLine.FieldCaption("No. of Depreciation Days"), GenJournalLine.TableCaption));
    end;

    local procedure VerifyDeprBeforePostingHalfYr(
        var FAJournalLine: Record "FA Journal Line";
        PostingDate: Date;
        DocNo: Code[20];
        FANo: Code[20];
        DeprBookCode: Code[10];
        var VerifyAmount: Decimal;
        AddlDepApplicable: Boolean)
    var
        FixedAsset: Record "Fixed Asset";
        AddDeprAmt: Decimal;
        DeprAmt: Decimal;
    begin
        FAJournalLine.SetRange("FA No.", FANo);
        FAJournalLine.SetRange("Document No.", DocNo);
        FAJournalLine.FindFirst();
        FAJournalLine.TestField("FA Posting Date", PostingDate);
        FAJournalLine.TestField("Depreciation Book Code", DeprBookCode);
        FAJournalLine.TestField("FA Posting Type", FAJournalLine."FA Posting Type"::Depreciation);
        FixedAsset.SetRange("No.", FANo);
        FixedAsset.FindFirst();
        GetDeprAmtHalfYr(FixedAsset, DeprBookCode, AddDeprAmt, DeprAmt, AddlDepApplicable);
        VerifyAmount := AddDeprAmt + DeprAmt;
        LibraryAssert.AreNearlyEqual(VerifyAmount, -FAJournalLine.Amount, 1,
            StrSubstNo(AmountErr, FAJournalLine.FieldCaption(Amount), FAJournalLine.TableCaption));
    end;

    local procedure VerifyDeprBeforePostingFullYrWithCompanyDepBook(
        var FAGLJournalLine: Record "Gen. Journal Line";
        PostingDate: Date;
        DocNo: Code[20];
        FANo: Code[20];
        DeprBookCode: Code[10];
        var VerifyAmount: Decimal)
    var
        FixedAsset: Record "Fixed Asset";
        AddDeprAmt: Decimal;
        DeprAmt: Decimal;
    begin
        FAGLJournalLine.SetRange("Account No.", FANo);
        FAGLJournalLine.SetRange("Document No.", DocNo);
        FAGLJournalLine.FindFirst();
        FAGLJournalLine.TestField("Posting Date", PostingDate);
        FAGLJournalLine.TestField("Depreciation Book Code", DeprBookCode);
        FAGLJournalLine.TestField("FA Posting Type", FAGLJournalLine."FA Posting Type"::Depreciation);
        FixedAsset.SetRange("No.", FANo);
        FixedAsset.FindFirst();
        GetDeprAmtFullYr(FixedAsset, DeprBookCode, AddDeprAmt, DeprAmt, false);
        VerifyAmount := AddDeprAmt + DeprAmt;
        LibraryAssert.AreNearlyEqual(VerifyAmount, Abs(FAGLJournalLine.Amount), 1,
            StrSubstNo(AmountErr, FAGLJournalLine.FieldCaption(Amount), FAGLJournalLine.TableCaption));
    end;

    local procedure VerifyDeprBeforePostingHalfYrWithCompanyDepBook(
        var FAGLJournalLine: Record "Gen. Journal Line";
        PostingDate: Date;
        DocNo: Code[20];
        FANo: Code[20];
        DeprBookCode: Code[10];
        var VerifyAmount: Decimal)
    var
        FixedAsset: Record "Fixed Asset";
        AddDeprAmt: Decimal;
        DeprAmt: Decimal;
    begin
        FAGLJournalLine.SetRange("Account No.", FANo);
        FAGLJournalLine.SetRange("Document No.", DocNo);
        FAGLJournalLine.FindFirst();
        FAGLJournalLine.TestField("Posting Date", PostingDate);
        FAGLJournalLine.TestField("Depreciation Book Code", DeprBookCode);
        FAGLJournalLine.TestField("FA Posting Type", FAGLJournalLine."FA Posting Type"::Depreciation);
        FixedAsset.SetRange("No.", FANo);
        FixedAsset.FindFirst();
        GetDeprAmtHalfYr(FixedAsset, DeprBookCode, AddDeprAmt, DeprAmt, false);
        VerifyAmount := AddDeprAmt + DeprAmt;
        LibraryAssert.AreNearlyEqual(VerifyAmount, Abs(FAGLJournalLine.Amount), 1,
            StrSubstNo(AmountErr, FAGLJournalLine.FieldCaption(Amount), FAGLJournalLine.TableCaption));
    end;

    local procedure GetDeprAmtFullYr(FixedAsset: Record "Fixed Asset"; DeprBookCode: Code[10]; var AddDeprAmt: Decimal; var DeprAmt: Decimal; AddlDepApplicable: Boolean)
    var
        FixedAssetBlock: Record "Fixed Asset Block";
        FALedgEntry: Record "FA Ledger Entry";
        BookValue: Decimal;
        SalvageValue: Decimal;
    begin
        FixedAssetBlock.SetRange("FA Class Code", FixedAsset."FA Class Code");
        FixedAssetBlock.SetRange(Code, FixedAsset."FA Block Code");
        FixedAssetBlock.FindFirst();
        FALedgEntry.SetRange("FA No.", FixedAsset."No.");
        FALedgEntry.SetRange("Depreciation Book Code", DeprBookCode);
        FALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type"::"Salvage Value");
        if FALedgEntry.FindSet() then
            repeat
                SalvageValue += FALedgEntry.Amount;
            until FALedgEntry.Next() = 0;

        FALedgEntry.SetRange("FA No.", FixedAsset."No.");
        FALedgEntry.SetRange("Depreciation Book Code", DeprBookCode);
        FALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type"::"Acquisition Cost");
        if FALedgEntry.FindSet() then
            repeat
                BookValue += FALedgEntry.Amount;
            until FALedgEntry.Next() = 0;

        if AddlDepApplicable then
            AddDeprAmt += ((BookValue + SalvageValue) * FixedAssetBlock."Add. Depreciation %") / 100;
        DeprAmt += ((BookValue + SalvageValue) * FixedAssetBlock."Depreciation %") / 100;
    end;

    local procedure GetDeprAmtHalfYr(FixedAsset: Record "Fixed Asset"; DeprBookCode: Code[10]; var AddDeprAmt: Decimal; var DeprAmt: Decimal; AddlDepApplicable: Boolean)
    var
        FixedAssetBlock: Record "Fixed Asset Block";
        FALedgEntry: Record "FA Ledger Entry";
        DepreciationBook: Record "Depreciation Book";
    begin
        FixedAssetBlock.SetRange("FA Class Code", FixedAsset."FA Class Code");
        FixedAssetBlock.SetRange(Code, FixedAsset."FA Block Code");
        FixedAssetBlock.FindFirst();
        FALedgEntry.SetRange("FA No.", FixedAsset."No.");
        FALedgEntry.SetRange("Depreciation Book Code", DeprBookCode);
        FALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type"::"Acquisition Cost");
        if FALedgEntry.FindSet() then
            repeat
                DepreciationBook.Get(DeprBookCode);
                if AddlDepApplicable then
                    AddDeprAmt += ((FALedgEntry.Amount * FixedAssetBlock."Add. Depreciation %") / 100) * DepreciationBook."Depr. Reduction %" / 100;
                DeprAmt += ((FALedgEntry.Amount * FixedAssetBlock."Depreciation %") / 100) * DepreciationBook."Depr. Reduction %" / 100;
            until FALedgEntry.Next() = 0;
    end;

    local procedure GetFAAndBlockValue(FixedAsset: Record "Fixed Asset"; FADepreciationBook: Record "FA Depreciation Book"; var FAValue: Decimal; var BLockValue: Decimal)
    var
        FixedAssetBlock: Record "Fixed Asset Block";
    begin
        FADepreciationBook.CalcFields("Book Value");
        FAValue := FADepreciationBook."Book Value";
        FixedAssetBlock.Get(FixedAsset."FA Class Code", FixedAsset."FA Block Code");
        FixedAssetBlock.CalcFields("Book Value");
        BLockValue := FixedAssetBlock."Book Value";
    end;

    local procedure VerifyFAValueAfterDepreciation(
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        FAValueOld: Decimal;
        BLockValueOld: Decimal;
        ExpectedAmount: Decimal)
    var
        FixedAssetBlock: Record "Fixed Asset Block";
    begin
        FADepreciationBook.CalcFields("Book Value");
        FixedAssetBlock.Get(FixedAsset."FA Class Code", FixedAsset."FA Block Code");
        FixedAssetBlock.CalcFields("Book Value");
        LibraryAssert.AreNearlyEqual(ExpectedAmount, FAValueOld - FADepreciationBook."Book Value", 1,
            StrSubstNo(AmountErr, FADepreciationBook.FieldCaption("Book Value"), FADepreciationBook.TableCaption));
        if FADepreciationBook."Depreciation Book Code" = IncomeTaxLbl then
            LibraryAssert.AreNearlyEqual(ExpectedAmount, BLockValueOld - FixedAssetBlock."Book Value", 1,
                StrSubstNo(AmountErr, FixedAssetBlock.FieldCaption("Book Value"), FixedAssetBlock.TableCaption));
    end;

    local procedure VerifyFALedgerEntriesFirstYrUtilise(
        DepreciationBook: Record "Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        DocNo: Code[20];
        ExpectedAmount: Decimal;
        NewPostingDate: Date;
        AddlDepApplicable: Boolean;
        FirstYearUtilizationFullYear: Boolean)
    var
        FALedgerEntry: Record "FA Ledger Entry";
        DeprPct: Decimal;
        AddDeprPct: Decimal;
        DeprAmt: Decimal;
        AddDeprAmt: Decimal;
    begin
        FALedgerEntry.SetRange("Document No.", DocNo);
        FALedgerEntry.FindFirst();
        FALedgerEntry.TestField("Posting Date", NewPostingDate);
        FALedgerEntry.TestField("FA Posting Type", FALedgerEntry."FA Posting Type"::Depreciation);
        if FirstYearUtilizationFullYear then begin
            GetDepreciationPctFullYr(DeprPct, AddDeprPct, FixedAsset."FA Block Code", FixedAsset."FA Class Code");
            GetDeprAmtFullYr(FixedAsset, DepreciationBook.Code, AddDeprAmt, DeprAmt, AddlDepApplicable);
        end else begin
            GetDepreciationPctHalflYr(DeprPct, AddDeprPct, FixedAsset."FA Block Code", FixedAsset."FA Class Code", DepreciationBook."Depr. Reduction %");
            GetDeprAmtHalfYr(FixedAsset, DepreciationBook.Code, AddDeprAmt, DeprAmt, AddlDepApplicable);
        end;

        if AddlDepApplicable then
            case FADepreciationBook."Depreciation Method" of
                FADepreciationBook."Depreciation Method"::"Straight-Line":
                    LibraryAssert.AreNearlyEqual((DeprPct + AddDeprPct), FALedgerEntry."Straight-Line %", 1,
                        StrSubstNo(AmountErr, FALedgerEntry.FieldCaption("Straight-Line %"), FALedgerEntry.TableCaption));
                FADepreciationBook."Depreciation Method"::"Declining-Balance 1":
                    LibraryAssert.AreNearlyEqual((DeprPct + AddDeprPct), FALedgerEntry."Declining-Balance %", 1,
                        StrSubstNo(AmountErr, FALedgerEntry.FieldCaption("Declining-Balance %"), FALedgerEntry.TableCaption));
            end
        else
            case FADepreciationBook."Depreciation Method" of
                FADepreciationBook."Depreciation Method"::"Straight-Line":
                    LibraryAssert.AreNearlyEqual(DeprPct, FALedgerEntry."Straight-Line %", 1,
                        StrSubstNo(AmountErr, FALedgerEntry.FieldCaption("Straight-Line %"), FALedgerEntry.TableCaption));
                FADepreciationBook."Depreciation Method"::"Declining-Balance 1":
                    LibraryAssert.AreNearlyEqual((DeprPct), FALedgerEntry."Declining-Balance %", 1,
                        StrSubstNo(AmountErr, FALedgerEntry.FieldCaption("Declining-Balance %"), FALedgerEntry.TableCaption));
            end;

        if AddlDepApplicable then begin
            FALedgerEntry.TestField("Add. Depreciation", true);
            LibraryAssert.AreNearlyEqual(AddDeprAmt, -FALedgerEntry."Add. Depreciation Amount", 1,
                StrSubstNo(AmountErr, FALedgerEntry.FieldCaption("Add. Depreciation Amount"), FALedgerEntry.TableCaption));
        end;
        LibraryAssert.AreNearlyEqual(ExpectedAmount, -FALedgerEntry.Amount, 1,
            StrSubstNo(AmountErr, FALedgerEntry.FieldCaption(Amount), FALedgerEntry.TableCaption));
    end;

    local procedure GetDepreciationPctFullYr(var DepreciationPct: Decimal; var AddlDepreciationPct: Decimal; FABlockCode: Code[10]; FAClassCode: Code[10])
    var
        FixedAssetBlock: Record "Fixed Asset Block";
    begin
        FixedAssetBlock.SetRange("FA Class Code", FAClassCode);
        FixedAssetBlock.SetRange(Code, FABlockCode);
        FixedAssetBlock.FindFirst();
        DepreciationPct := FixedAssetBlock."Depreciation %";
        AddlDepreciationPct := FixedAssetBlock."Add. Depreciation %";
    end;

    local procedure GetDepreciationPctHalflYr(var DepreciationPct: Decimal; var AddlDepreciationPct: Decimal; FABlockCode: Code[10]; FAClassCode: Code[10]; Reductionpct: Decimal)
    var
        FixedAssetBlock: Record "Fixed Asset Block";
    begin
        FixedAssetBlock.SetRange("FA Class Code", FAClassCode);
        FixedAssetBlock.SetRange(Code, FABlockCode);
        FixedAssetBlock.FindFirst();
        DepreciationPct := FixedAssetBlock."Depreciation %" * Reductionpct / 100;
        AddlDepreciationPct := FixedAssetBlock."Add. Depreciation %" * Reductionpct / 100;
    end;

    local procedure CreateAndPostPurchaseInvoice(FixedAsset: Record "Fixed Asset"; var Amount: Decimal)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        Amount := LibraryRandom.RandIntInRange(1000, 1000);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        PurchaseHeader.Validate("Posting Date", GetFiscalYearStartDateInc(WorkDate()));
        PurchaseHeader.Modify(true);
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"Fixed Asset", FixedAsset."No.", 1);
        PurchaseLine.Validate("Direct Unit Cost", Amount);
        PurchaseLine.Modify(true);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);
    end;

    local procedure VerifyAmountInFALedgerEntry(FANo: Code[20]; FALedgerEntryFAPostingType: Enum "FA Ledger Entry FA Posting Type"; Amount: Decimal)
    var
        FALedgerEntry: Record "FA Ledger Entry";
    begin
        FALedgerEntry.SetRange("FA No.", FANo);
        FALedgerEntry.SetRange("FA Posting Type", FALedgerEntryFAPostingType);
        FALedgerEntry.FindFirst();
        FALedgerEntry.TestField(Amount, Amount);
    end;

    local procedure CreateAndPostFADisposalLine(var FADepreciationBook: Record "FA Depreciation Book"; var Amount: Decimal; var DisposalPostingDate: Date; var DisposalDoc: Code[20])
    var
        FAJournalLine: Record "FA Journal Line";
    begin
        CreateFAJournalLine(FAJournalLine, FADepreciationBook."FA No.", FADepreciationBook."Depreciation Book Code", FAJournalLine."FA Posting Type"::Disposal);
        FAJournalLine.Validate("FA Posting Date", WorkDate());
        FAJournalLine.Validate("Posting Date", FAJournalLine."FA Posting Date");
        FAJournalLine.Amount := -Amount;
        FAJournalLine.Modify(true);
        Amount := FAJournalLine.Amount;
        DisposalPostingDate := FAJournalLine."Posting Date";
        DisposalDoc := FAJournalLine."Document No.";
        LibraryFixedAsset.PostFAJournalLine(FAJournalLine);
    end;

    local procedure UpdateFAShift(
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        var FAShitf: Record "Fixed Asset Shift";
        ShiftType: Enum "Shift Type";
        IndustryType: Enum "Industry type")
    begin
        FAShitf.Init();
        FAShitf.Validate("FA No.", FixedAsset."No.");
        FAShitf.Validate("Depreciation Book Code", FADepreciationBook."Depreciation Book Code");
        FAShitf.Validate("Fixed Asset Posting Group", FixedAsset."FA Posting Group");
        FAShitf.Validate("Depreciation Starting Date", GetFiscalYearStartDateInc(WorkDate()));
        FAShitf.Validate("Depreciation ending Date", GetFiscalYearEndDateInc(WorkDate()));
        FAShitf.Validate("Depreciation Method", FAShitf."Depreciation Method"::"Straight-Line");
        FAShitf.Validate("Straight-Line %", FADepreciationBook."Straight-Line %");
        FAShitf.Validate("Shift Type", ShiftType::Double);
        FAShitf.Validate("Industry Type", IndustryType::Seasonal);
        FAShitf.Validate("Used No. of Days", LibraryRandom.RandIntInRange(100, 100));
        FAShitf.Insert(true);
    end;

    [ConfirmHandler]
    procedure PostConfirmation(Question: Text; var Reply: Boolean)
    begin
        Reply := false;
    end;

    [MessageHandler]
    procedure DepreciationNotCalculatedMsgHandler(MsgTxt: Text[1024])
    begin
    end;
}