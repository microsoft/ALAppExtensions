codeunit 18488 "GST FA Reclass Journal Tests"
{
    Subtype = Test;

    var
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        LibraryERM: Codeunit "Library - ERM";
        LibraryFiscalYear: Codeunit "Library - Fiscal Year";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        LibraryGSTJournals: Codeunit "Library GST Journals";
        LibraryGST: Codeunit "Library GST";
        Storage: Dictionary of [Text[20], Text[20]];
        ComponentPerArray: array[20] of Decimal;
        isInitialized: Boolean;
        FAFromLocationCodeLbl: Label 'FAFromLocationCode', Locked = true;
        FAToLocationCodeLbl: Label 'FAToLocationCode', Locked = true;
        LocationCodeLbl: Label 'LocationCode', Locked = true;
        LocationStateCodeLbl: Label 'LocationStateCode', Locked = true;
        GSTGroupCodeLbl: Label 'GSTGroupCode', Locked = true;
        HSNSACCodeLbl: Label 'HSNSACCode', Locked = true;
        FromStateCodeLbl: Label 'FromStateCode', Locked = true;
        ToStateCodeLbl: Label 'ToStateCode', Locked = true;
        PeriodTxt: Label '12';
        CompletionStatsTok: Label 'The depreciation has been calculated.';


    [Test]
    [HandlerFunctions('TaxRatePageHandler,DepreciationCalcConfirmHandler,MessageHandler')]
    procedure ReclassifyFixedAssetWithInterState()
    var
        DepreciationBook: Record "Depreciation Book";
        GenJournalBatch: Record "Gen. Journal Batch";
        FixedAsset: Record "Fixed Asset";
        FixedAsset2: Record "Fixed Asset";
        FADepreciationBook2: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
        VATPostingSetup: Record "VAT Posting Setup";
        AcquisitionCostAfterReclassification: Decimal;
        ReclassifyAcqCostPct: Decimal;
        BookValue: Decimal;
        DocumentNo: Code[20];
        FAExempted: Boolean;
    begin
        // [FEATURE] [AI TEST]
        // Check GL Entries after posting FA Reclass Journals.

        // 1. Setup: Create GST Setup, Locations, create and modify Depreciation Book, create FA Posting Group, create two Fixed Assets.
        Initialize();
        LibraryFiscalYear.CreateFiscalYear();
        CreateGSTSetup(false, false);

        LibraryGST.CreateNewFixedAssetsForReclassificationWithGSTDetails(FixedAsset, FixedAsset2, VATPostingSetup, DepreciationBook, FADepreciationBook2, CopyStr(Storage.Get(GSTGroupCodeLbl), 1, 20), CopyStr(Storage.Get(HSNSACCodeLbl), 1, 10), FixedAsset."FA Posting Group", true, FAExempted);

        // Create and post FA G/L Journal for Acquisition with Random Amounts.        
        CreateAndPostFAGLJnlforAquisition(GenJournalBatch, FixedAsset."No.", DepreciationBook, WorkDate());

        // 2. Exercise: Create and Post FA Raclass Journal.
        LibraryLowerPermissions.SetO365FAEdit();
        LibraryLowerPermissions.AddJournalsPost();
        ReclassifyAcqCostPct := LibraryRandom.RandIntInRange(10, 20);  // Take Random value for Reclassify Acq Cost %.
        BookValue := CalcFABookValue(FixedAsset."No.", WorkDate());
        AcquisitionCostAfterReclassification := Round(BookValue * ReclassifyAcqCostPct / 100);
        DocumentNo := CreateFAReclassJournalLine(FixedAsset."No.", FixedAsset2."No.", DepreciationBook.Code, ReclassifyAcqCostPct);
        FindAndPostGenJournalLines(GenJournalBatch, DocumentNo);

        // 3. Verify: Verify GL Entries after Reclassification.
        FAPostingGroup.Get(FixedAsset."FA Posting Group");
        VerifyGLEntry(FixedAsset."No.", DocumentNo, FAPostingGroup."Acquisition Cost Account", -AcquisitionCostAfterReclassification);
        LibraryFixedAsset.VerifyLastFARegisterGLRegisterOneToOneRelation();
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,DepreciationCalcConfirmHandler,MessageHandler')]
    procedure ReclassifyFixedAssetWithIntraState()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        DepreciationBook: Record "Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        FixedAsset2: Record "Fixed Asset";
        FADepreciationBook2: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
        VATPostingSetup: Record "VAT Posting Setup";
        AcquisitionCostAfterReclassification: Decimal;
        ReclassifyAcqCostPct: Decimal;
        BookValue: Decimal;
        DocumentNo: Code[20];
        FAExempted: Boolean;
    begin
        // [FEATURE] [AI TEST]
        // Check GL Entries after posting FA Reclass Journals.

        // 1. Setup: Create GST Setup, Locations, create and modify Depreciation Book, create FA Posting Group, create two Fixed Assets.
        Initialize();
        LibraryFiscalYear.CreateFiscalYear();
        CreateGSTSetup(true, false);

        LibraryGST.CreateNewFixedAssetsForReclassificationWithGSTDetails(FixedAsset, FixedAsset2, VATPostingSetup, DepreciationBook, FADepreciationBook2, CopyStr(Storage.Get(GSTGroupCodeLbl), 1, 20), CopyStr(Storage.Get(HSNSACCodeLbl), 1, 10), FixedAsset."FA Posting Group", true, FAExempted);

        // Create and post FA G/L Journal for Acquisition with Random Amounts.
        CreateAndPostFAGLJnlforAquisition(GenJournalBatch, FixedAsset."No.", DepreciationBook, WorkDate());

        // 2. Exercise: Create and Post FA Raclass Journal.
        LibraryLowerPermissions.SetO365FAEdit();
        LibraryLowerPermissions.AddJournalsPost();
        ReclassifyAcqCostPct := LibraryRandom.RandIntInRange(10, 20);  // Take Random value for Reclassify Acq Cost %.
        BookValue := CalcFABookValue(FixedAsset."No.", WorkDate());
        AcquisitionCostAfterReclassification := Round(BookValue * ReclassifyAcqCostPct / 100);
        DocumentNo := CreateFAReclassJournalLine(FixedAsset."No.", FixedAsset2."No.", DepreciationBook.Code, ReclassifyAcqCostPct);
        FindAndPostGenJournalLines(GenJournalBatch, DocumentNo);

        // 3. Verify: Verify GL Entries after Reclassification.
        FAPostingGroup.Get(FixedAsset."FA Posting Group");
        VerifyGLEntry(FixedAsset."No.", DocumentNo, FAPostingGroup."Acquisition Cost Account", -AcquisitionCostAfterReclassification);
        LibraryFixedAsset.VerifyLastFARegisterGLRegisterOneToOneRelation();
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        CreateFAIncomeTaxAccPeriod(WorkDate());
    end;

    local procedure CreateGSTSetup(
        IntraState: Boolean;
        ReverseCharge: Boolean)
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        TaxComponent: Record "Tax Component";
        CompanyInformation: Record "Company information";
        LocationStateCode: Code[10];
        LocationCode: Code[10];
        FAFromLocationStateCode: Code[10];
        FAFromLocationCode: Code[10];
        FromFALocationGSTRegNo: Code[15];
        FAToLocationStateCode: Code[10];
        FAToLocationCOde: COde[10];
        ToFALocationGSTRegNo: Code[15];
        LocPANNo: Code[20];
        LocationGSTRegNo: Code[15];
        GSTGroupCode: Code[20];
        HSNSACCode: Code[10];
        HsnSacType: Enum "GST Goods And Services Type";
        GSTGroupType: Enum "GST Group Type";
        GSTComponentCode: Text[30];
    begin
        CompanyInformation.Get();
        if CompanyInformation."P.A.N. No." = '' then begin
            CompanyInformation."P.A.N. No." := LibraryGST.CreatePANNos();
            CompanyInformation.Modify();
        end else
            LocPANNo := CompanyInformation."P.A.N. No.";

        LocPANNo := CompanyInformation."P.A.N. No.";

        LocationStateCode := LibraryGST.CreateInitialSetup();
        SetStorageGSTJournalText(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(LocationStateCode, LocPANNo);

        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.Modify(true);
        end;

        LocationCode := LibraryGST.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        SetStorageGSTJournalText(LocationCodeLbl, LocationCode);

        FAFromLocationStateCode := LibraryGST.CreateInitialSetup();
        FromFALocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(FAFromLocationStateCode, LocPANNo);
        FAFromLocationCode := LibraryGST.CreateLocationSetup(FAFromLocationStateCode, FromFALocationGSTRegNo, false);
        SetStorageGSTJournalText(FAFromLocationCodeLbl, FAFromLocationCode);

        if IntraState then
            FAToLocationStateCode := FAFromLocationStateCode
        else
            FAToLocationStateCode := LibraryGST.CreateInitialSetup();

        ToFALocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(FAToLocationStateCode, LocPANNo);
        FAToLocationCode := LibraryGST.CreateLocationSetup(FAToLocationStateCode, ToFALocationGSTRegNo, false);
        SetStorageGSTJournalText(FAToLocationCodeLbl, FAToLocationCode);

        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType::Goods, GSTGroup."GST Place Of Supply"::"Bill-to Address", ReverseCharge);
        SetStorageGSTJournalText(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        SetStorageGSTJournalText(HSNSACCodeLbl, HSNSACCode);

        if IntraState then
            InitializeTaxRateParameters(IntraState, FAFromLocationStateCode, FAToLocationStateCode)
        else begin
            InitializeTaxRateParameters(IntraState, FAFromLocationStateCode, FAToLocationStateCode);
            InitializeTaxRateParameters(IntraState, FAToLocationStateCode, FAFromLocationStateCode);
        end;

        CreateTaxRate();
        LibraryGST.CreateGSTComponentAndPostingSetup(IntraState, FAFromLocationStateCode, TaxComponent, GSTComponentCode);
        LibraryGST.CreateGSTComponentAndPostingSetup(IntraState, FAToLocationStateCode, TaxComponent, GSTComponentCode);
    end;

    local procedure CreateAndPostFAGLJnlforAquisition(var GenJournalBatch: Record "Gen. Journal Batch"; FixedAssetNo: Code[20]; DepreciationBook: Record "Depreciation Book"; PostingDate: Date)
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        LibraryJournals: Codeunit "Library - Journals";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);

        ModifyDepreciationBookAndGenJournalBatch(DepreciationBook);

        LibraryJournals.CreateGenJournalLine(GenJournalLine,
            GenJournalTemplate.Name,
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::"Fixed Asset",
            FixedAssetNo,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            CreateGLAccountWithDirectPostingNoVAT(),
            LibraryRandom.RandDecInRange(10000, 20000, 2));
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::Sale);
        GenJournalLine.Validate("FA Posting Type", GenJournalLine."FA Posting Type"::"Acquisition Cost");
        GenJournalLine.Modify(true);

        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure ModifyDepreciationBookAndGenJournalBatch(var DepreciationBook: Record "Depreciation Book")
    var
        FAJournalSetup: Record "FA Journal Setup";
    begin
        LibraryFixedAsset.CreateFAJournalSetup(FAJournalSetup, DepreciationBook.Code, '');
        UpdateFAJournalSetup(FAJournalSetup);
        DepreciationBook.Validate("Allow more than 360/365 Days", true);
        DepreciationBook.Modify(true);
    end;

    local procedure UpdateFAJournalSetup(var FAJournalSetup: Record "FA Journal Setup")
    var
        FAJournalSetup2: Record "FA Journal Setup";
        FASetup: Record "FA Setup";
    begin
        FASetup.FindFirst();
        FAJournalSetup2.SetRange("Depreciation Book Code", FASetup."Insurance Depr. Book");
        FAJournalSetup2.FindFirst();
        FAJournalSetup.TransferFields(FAJournalSetup2, false);
        FAJournalSetup.Modify(true);
    end;


    local procedure CalcFABookValue(FACode: Code[20]; PostingDate: Date) BookValue: Decimal;
    var
        FALedgerEntry: Record "FA Ledger Entry";
    begin
        FALedgerEntry.SetFilter("FA No.", FACode);
        FALedgerEntry.SetRange("Posting Date", 0D, PostingDate);
        if FALedgerEntry.FindSet() then
            repeat
                BookValue += FALedgerEntry.Amount;
            until FALedgerEntry.Next() = 0;
    end;

    local procedure CreateFAReclassJournalLine(FANo: Code[20]; NewFANo: Code[20]; DepreciationBookCode: Code[10]; ReclassifyAcqCostPct: Decimal) DocumentNo: Code[20]
    var
        FAReclassJournalTemplate: Record "FA Reclass. Journal Template";
        FAReclassJournalBatch: Record "FA Reclass. Journal Batch";
        FAReclassJournalLine: Record "FA Reclass. Journal Line";
    begin
        FAReclassJournalTemplate.FindFirst();

        LibraryFixedAsset.CreateFAReclassJournalBatch(FAReclassJournalBatch, FAReclassJournalTemplate.Name);
        LibraryFixedAsset.CreateFAReclassJournal(
          FAReclassJournalLine, FAReclassJournalBatch."Journal Template Name", FAReclassJournalBatch.Name);

        FAReclassJournalLine.Validate("FA Posting Date", CalcDate('<' + PeriodTxt + 'M>', WorkDate()));
        DocumentNo := LibraryUtility.GenerateGUID();
        FAReclassJournalLine.Validate("Document No.", DocumentNo);
        FAReclassJournalLine.Validate("FA No.", FANo);
        FAReclassJournalLine.Validate("New FA No.", NewFANo);
        FAReclassJournalLine.Validate("Depreciation Book Code", DepreciationBookCode);
        FAReclassJournalLine.Validate("Reclassify Acq. Cost %", ReclassifyAcqCostPct);
        FAReclassJournalLine.Validate("Reclassify Acquisition Cost", true);
        FAReclassJournalLine.Validate("Reclassify Depreciation", false);
        FAReclassJournalLine.Validate("From Location Code", CopyStr(Storage.Get(FAFromLocationCodeLbl), 1, 10));
        FAReclassJournalLine.Validate("To Location Code", CopyStr(Storage.Get(FAToLocationCodeLbl), 1, 10));
        FAReclassJournalLine.Modify(true);
        Codeunit.Run(Codeunit::"FA Reclass. Jnl.-Transfer", FAReclassJournalLine);
    end;


    local procedure CreateGLAccountWithDirectPostingNoVAT(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get(LibraryERM.CreateGLAccountNoWithDirectPosting());
        GLAccount.Validate("Gen. Prod. Posting Group", GetGenProdPostingGroup());
        GLAccount.Validate("VAT Prod. Posting Group", GetNOVATProdPostingGroup());
        GLAccount.Modify();

        exit(GLAccount."No.");
    end;

    local procedure GetGenProdPostingGroup(): Code[20]
    var
        GenProdPostingGroup: Record "Gen. Product Posting Group";
    begin
        GenProdPostingGroup.FindFirst();

        exit(GenProdPostingGroup.Code);
    end;

    local procedure GetNOVATProdPostingGroup(): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetRange("VAT %", 0);
        if VATPostingSetup.FindFirst() then
            exit(VATPostingSetup."VAT Prod. Posting Group");
    end;

    local procedure SetStorageGSTJournalText(KeyValue: Text[20]; Value: Text[20])
    begin
        Storage.Set(KeyValue, Value);
        LibraryGSTJournals.SetStorageGSTJournalText(Storage);
    end;

    local procedure InitializeTaxRateParameters(IntraState: Boolean; FromState: Code[10]; ToState: Code[10]) GSTTaxPercent: Decimal;
    begin
        SetStorageGSTJournalText(FromStateCodeLbl, FromState);
        SetStorageGSTJournalText(ToStateCodeLbl, ToState);
        GSTTaxPercent := LibraryRandom.RandDecInRange(10, 18, 0);
        if IntraState then begin
            ComponentPerArray[1] := (GSTTaxPercent / 2);
            ComponentPerArray[2] := (GSTTaxPercent / 2);
        end else
            ComponentPerArray[4] := GSTTaxPercent;
    end;

    local procedure CreateTaxRate()
    var
        GSTSetup: Record "GST Setup";
        TaxTypes: TestPage "Tax Types";
    begin
        if not GSTSetup.Get() then
            exit;
        TaxTypes.OpenEdit();
        TaxTypes.Filter.SetFilter(Code, GSTSetup."GST Tax Type");
        TaxTypes.TaxRates.Invoke();
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

    local procedure VerifyGLEntry(SourceNo: Code[20]; DocumentNo: Code[20]; GLAccountNo: Code[20]; Amount: Decimal)
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("FA Entry Type", GLEntry."FA Entry Type"::"Fixed Asset");
        GLEntry.SetRange("Source No.", SourceNo);
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.FindFirst();
        GLEntry.TestField(Amount, Amount);
    end;

    local procedure FindAndPostGenJournalLines(GenJournalBatch: Record "Gen. Journal Batch"; DocumentNo: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Document No.", DocumentNo);
        GenJournalLine.FindSet();
        repeat
            GenJournalLine.Validate("Journal Template Name", GenJournalBatch."Journal Template Name");
            GenJournalLine.Validate("Journal Batch Name", GenJournalBatch.Name);
            GenJournalLine.Validate(Description, GenJournalBatch.Name);
            GenJournalLine.Validate("FA Posting Date", GenJournalLine."Posting Date");
            GenJournalLine.Modify(true);
        until GenJournalLine.Next() = 0;

        GenJournalLine.Reset();
        GenJournalLine.SetRange("Document No.", DocumentNo);
        GenJournalLine.FindSet();
        CalculateTax.CallTaxEngineOnGenJnlLine(GenJournalLine, GenJournalLine);

        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    [ConfirmHandler]
    procedure DepreciationCalcConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        if 0 <> StrPos(Question, CompletionStatsTok) then
            Reply := false
        else
            Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        // Dummy message handler
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates")
    begin
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(Storage.Get(GSTGroupCodeLbl));
        TaxRates.AttributeValue2.SetValue(Storage.Get(HSNSACCodeLbl));
        TaxRates.AttributeValue3.SetValue(Storage.Get(FromStateCodeLbl));
        TaxRates.AttributeValue4.SetValue(Storage.Get(ToStateCodeLbl));
        TaxRates.AttributeValue5.SetValue(WorkDate());
        TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', WorkDate()));
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]); // SGST
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]); // CGST
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[4]); // IGST
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[5]); // KFloodCess        

        if (Storage.Get(FromStateCodeLbl)) <> (Storage.Get(ToStateCodeLbl)) then begin
            TaxRates.New();
            TaxRates.AttributeValue1.SetValue(Storage.Get(GSTGroupCodeLbl));
            TaxRates.AttributeValue2.SetValue(Storage.Get(HSNSACCodeLbl));
            TaxRates.AttributeValue3.SetValue(Storage.Get(ToStateCodeLbl));
            TaxRates.AttributeValue4.SetValue(Storage.Get(FromStateCodeLbl));
            TaxRates.AttributeValue5.SetValue(WorkDate());
            TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', WorkDate()));
            TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]); // SGST
            TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]); // CGST
            TaxRates.AttributeValue9.SetValue(ComponentPerArray[4]); // IGST
            TaxRates.AttributeValue10.SetValue(ComponentPerArray[5]); // KFloodCess
        end;

        TaxRates.OK().Invoke();
    end;

}