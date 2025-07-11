// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;

codeunit 18632 "Depr Calculation Subscribers"
{
    var
        DecliningBalancePercentErr: Label '%2 must not be 100 for %1.', Comment = '%1 = Fixed Asset Name, %2 = Field Caption';
        DepreciationMethodErr: Label '%2 must be %3 if %4 %5 = %6 for %1.',
            Comment = '%1 = FA Name, %2 = Field Caption, %3 = Depreciation Method, %4 = Table Caption, %5 = Field Caption, %6 = Period';
        DepreciationDateErr: Label '%2 must not be later than %3 for %1.', Comment = '%1 = FA Name, %2 = Field Caption, %3 = Field Caption';
        DeprBookCodeLbl: Label 'DeprBookCode', Locked = true;
        DeprTableCodeLbl: Label 'DeprTableCode', Locked = true;
        DateFromProjectionLbl: Label 'DateFromProjection', Locked = true;
        EndDateLbl: Label 'EndDate', Locked = true;
        DeprStartingDateLbl: Label 'DeprStartingDate', Locked = true;
        FirstUserDefinedDeprDateLbl: Label 'FirstUserDefinedDeprDate', Locked = true;
        AcquisitionDateLbl: Label 'AcquisitionDate', Locked = true;
        DisposalDateLbl: Label 'DisposalDate', Locked = true;
        DaysInFiscalYearLbl: Label 'DaysInFiscalYear', Locked = true;
        BookValueLbl: Label 'BookValue', Locked = true;
        MinusBookValueLbl: Label 'MinusBookValue', Locked = true;
        DeprBasisLbl: Label 'DeprBasis', Locked = true;
        SalvageValueLbl: Label 'SalvageValue', Locked = true;
        CopyBookValueLbl: Label 'CopyBookValue', Locked = true;
        SLPercentLbl: Label 'SLPercent', Locked = true;
        DBPercentLbl: Label 'DBPercent', Locked = true;
        DeprYearsLbl: Label 'DeprYears', Locked = true;
        FixedAmountLbl: Label 'FixedAmount', Locked = true;
        FinalRoundingAmountLbl: Label 'FinalRoundingAmount', Locked = true;
        EndingBookValueLbl: Label 'EndingBookValue', Locked = true;
        PercentBelowZeroLbl: Label 'PercentBelowZero', Locked = true;
        AmountBelowZeroLbl: Label 'AmountBelowZero', Locked = true;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Normal Depreciation", 'OnCalculateOnBeforeTransferValue', '', false, false)]
    local procedure OnBeforeCalculateTransferValue(
        FANo: Code[20];
        var StorageDecimal: Dictionary of [Text, Decimal];
        var StorageInterger: Dictionary of [Text, Integer];
        var StorageDate: Dictionary of [Text, Date];
        var StorageCode: Dictionary of [Text, Code[10]];
        var EntryAmounts2: array[4] of Decimal;
        var EntryAmounts: array[4] of Decimal;
        var DeprMethod: Enum "FA Depr. Method Internal";
        var Year365Days: Boolean;
        var IsHandled: Boolean)
    begin
        CalculateTransferValue(
            FANo,
            StorageDecimal,
            StorageInterger,
            StorageDate,
            StorageCode,
            EntryAmounts,
            DeprMethod,
            Year365Days,
            IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Normal Depreciation", 'OnBeforeSkipRecord', '', false, false)]
    local procedure OnBeforeSkipRecord(
        FixedAsset: Record "Fixed Asset";
        DeprBook: Record "Depreciation Book";
        DisposalDate: Date;
        AcquisitionDate: Date;
        UntilDate: Date;
        FADeprMethod: Enum "FA Depreciation Method";
        BookValue: Decimal;
        DeprBasis: Decimal;
        SalvageValue: Decimal;
        MinusBookValue: Decimal;
        var ReturnValue: Boolean;
        var IsHandled: Boolean)
    var
        FixedAssetShift: Record "Fixed Asset Shift";
        DepreciationCalc: Codeunit "Depreciation Calculation";
        Sign: Integer;
    begin
        if DeprBook."FA Book Type" = DeprBook."FA Book Type"::"Income Tax" then
            IsHandled := true;

        ReturnValue := ((AcquisitionDate = 0D) or (FADeprMethod = FADeprMethod::Manual) or (AcquisitionDate > UntilDate) or (FixedAsset.Inactive) or (FixedAsset.Blocked));

        FixedAssetShift.Reset();
        FixedAssetShift.SetRange("FA No.", FixedAsset."No.");
        FixedAssetShift.SetRange("Calculate FA Depreciation", true);
        if FixedAssetShift.FindFirst() then begin
            if not FixedAssetShift."Use FA Ledger Check" then begin
                if DeprBook."Use FA Ledger Check" then
                    FixedAssetShift.TestField("Use FA Ledger Check", true);

                FixedAssetShift.TestField("Fixed Depr. Amount below Zero", 0);
                FixedAssetShift.TestField("Depr. below Zero %", 0);

                Sign := DepreciationCalc.GetSign(BookValue, DeprBasis, SalvageValue, MinusBookValue);
                if Sign = 0 then
                    exit;

                if Sign = -1 then
                    DepreciationCalc.GetNewSigns(BookValue, DeprBasis, SalvageValue, MinusBookValue);
            end;

            if (FixedAssetShift."Fixed Depr. Amount below Zero" > 0) or (FixedAssetShift."Depr. below Zero %" > 0) then
                FixedAssetShift.TestField("Use FA Ledger Check", true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Normal Depreciation", 'OnBeforeNumberofDayCalculateNumberofDays', '', false, false)]
    local procedure CalculateNumberofDays(
        FixedAsset: Record "Fixed Asset";
        DeprBook: Record "Depreciation Book";
        var NumberofDays: Integer;
        FirstDeprDate: Date;
        UntilDate: Date;
        Year365Days: Boolean;
        var IsHandled: Boolean)
    var
        FixedAssetShift: Record "Fixed Asset Shift";
        DepreciationCalc: Codeunit "Depreciation Calculation";
    begin
        FixedAssetShift.Reset();
        FixedAssetShift.SetRange("FA No.", FixedAsset."No.");
        FixedAssetShift.SetRange("Calculate FA Depreciation", true);
        if FixedAssetShift.FindFirst() then
            if FixedAssetShift."Line No." = 0 then
                NumberofDays := DepreciationCalc.DeprDays(FirstDeprDate, UntilDate, Year365Days)
            else begin
                if (FixedAssetShift."Used No. of Days" <> 0) and (UntilDate >= FirstDeprDate) then
                    NumberofDays := FixedAssetShift."Used No. of Days";

                if FixedAssetShift."Used No. of Days" = 0 then
                    NumberOfDays := DepreciationCalc.DeprDays(FirstDeprDate, UntilDate, Year365Days);
            end;

        if (DeprBook."FA Book Type" = DeprBook."FA Book Type"::"Income Tax") or (DeprBook."Fiscal Year 365 Days") then
            NumberOfDays := CalculateDeprDays(FirstDeprDate, UntilDate);

        OnAfterCalculateNumberofDays(FixedAsset, DeprBook, NumberofDays, FirstDeprDate, UntilDate, Year365Days);

        if NumberofDays > 0 then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Normal Depreciation", 'UpdateDaysInFiscalYear', '', false, false)]
    local procedure UpdateDaysInFiscalYears(
        FixedAsset: Record "Fixed Asset";
        DeprBook: Record "Depreciation Book";
        var NumberofDays: Integer;
        var DaysInFiscalYear: Integer;
        var IsHandled: Boolean)
    var
        FixedAssetShift: Record "Fixed Asset Shift";
    begin
        FixedAssetShift.Reset();
        FixedAssetShift.SetRange("FA No.", FixedAsset."No.");
        FixedAssetShift.SetRange("Calculate FA Depreciation", true);
        if not FixedAssetShift.FindFirst() then
            exit;

        if (DeprBook."FA Book Type" = DeprBook."FA Book Type"::"Income Tax") then
            exit;

        if FixedAssetShift."Industry Type" = FixedAssetShift."Industry Type"::"Non Seasonal" then begin
            DeprBook.TestField("No. of Days Non Seasonal");

            if NumberOfDays <= DeprBook."No. of Days Non Seasonal" then
                DaysInFiscalYear := DeprBook."No. of Days Non Seasonal";
        end;

        if FixedAssetShift."Industry Type" = FixedAssetShift."Industry Type"::Seasonal then begin
            DeprBook.TestField("No. of Days Seasonal");

            if NumberOfDays <= DeprBook."No. of Days Seasonal" then
                DaysInFiscalYear := DeprBook."No. of Days Seasonal";
        end;

        OnAfterUpdateDaysInFiscalYear(FixedAsset, DeprBook, NumberofDays, DaysInFiscalYear);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Table Depr. Calculation", 'OnBeforeValidateYear365Days', '', false, false)]
    local procedure OnBeforeValidateYear365Days(DepreBook: Record "Depreciation Book"; var IsHandled: Boolean)
    begin
        if DepreBook."FA Book Type" in [DepreBook."FA Book Type"::" ", DepreBook."FA Book Type"::"Income Tax"] then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Normal Depreciation", 'OnAfterCalcFinalDeprAmount', '', false, false)]
    local procedure OnAfterCalcFinalDeprAmount(
        FANo: Code[20];
        FADeprBook: Record "FA Depreciation Book";
        DepreBook: Record "Depreciation Book";
        Sign: Integer;
        BookValue: Decimal;
        var DeprAmount: Decimal;
        var IsHandled: Boolean)
    var
        FixedAsset: Record "Fixed Asset";
        FABlock: Record "Fixed Asset Block";
    begin
        if (Sign * DeprAmount > 0) and (DepreBook."FA Book Type" <> DepreBook."FA Book Type"::"Income Tax") then
            IsHandled := true;

        if (DepreBook."FA Book Type" = DepreBook."FA Book Type"::"Income Tax") then begin
            FixedAsset.Get((FANo));
            FixedAsset.TestField("FA Class Code");
            FixedAsset.TestField("FA Block Code");

            FABlock.Get(FixedAsset."FA Class Code", FixedAsset."FA Block Code");
            FABlock.CalcFields("Book Value", "No. of Assets");

            if (FABlock."Book Value" <= 0) or (FABlock."No. of Assets" = 0) or ((FADeprBook."Disposal Date" <> 0D) and (BookValue = 0)) then
                DeprAmount := 0;

            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Normal Depreciation", 'OnAfterTransferValues2', '', false, false)]
    local procedure OnAfterTransferValuesEvent(
        FADepreciationBook: Record "FA Depreciation Book";
        FixedAsset: Record "Fixed Asset";
        Year365Days: Boolean;
        var DeprYears: Decimal;
        var DeprBasis: Decimal;
        var BookValue: Decimal;
        var DeprMethod: Enum "FA Depr. Method Internal")
    var
        FABlock: Record "Fixed Asset Block";
        DeprBook: Record "Depreciation Book";
    begin
        DeprBook.Get(FADepreciationBook."Depreciation Book Code");
        if (DeprBook."FA Book Type" = DeprBook."FA Book Type"::"Income Tax") and (FADepreciationBook."Disposal Date" <> 0D) then begin
            FixedAsset.TestField("FA Class Code");
            FixedAsset.TestField("FA Block Code");
            FABlock.Get(FixedAsset."FA Class Code", FixedAsset."FA Block Code");

            DeprBasis := FilterFALedger(FixedAsset."No.", DeprBook.Code, true);
            BookValue := FilterFALedger(FixedAsset."No.", DeprBook.Code, false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Normal Depreciation", 'OnAfterBookValueRecalculateBookValue', '', false, false)]
    local procedure RecalculateBookValue(
        FixedAsset: Record "Fixed Asset";
        DeprBook: Record "Depreciation Book";
        FAledgEntry2: Record "FA Ledger Entry";
        var DeprBasis: Decimal;
        var BookValue: Decimal;
        DisposalDate: Date;
        var DeprEndingDate: Date)
    begin
        if (DeprBook."FA Book Type" = DeprBook."FA Book Type"::"Income Tax") and (DisposalDate <> 0D) then begin
            DeprBasis := FilterFALedger(FixedAsset."No.", DeprBook.Code, true);
            BookValue := FilterFALedger(FixedAsset."No.", DeprBook.Code, false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Normal Depreciation", 'OnAfterBookValueCheckAddedDeprApplicable', '', false, false)]
    local procedure CheckAddedDepreciationApplicable(
        FADepBook: Record "FA Depreciation Book";
        DeprBook: Record "Depreciation Book";
        FALedgerEntry: Record "FA Ledger Entry";
        UntilDate: Date;
        var DBPercent: Decimal;
        var SlPercent: Decimal)
    var
        FixedAsset: Record "Fixed Asset";
        FABlock: Record "Fixed Asset Block";
        CalcNormalDepr: Codeunit "Calc Normal Depreciation";
        AddedDeprApplicable: Boolean;
        DeprRedApllicable: Boolean;
    begin
        if FADepBook."FA Book Type" <> FADepBook."FA Book Type"::"Income Tax" then
            exit;

        FixedAsset.Get(FADepBook."FA No.");
        FixedAsset.TestField("FA Class Code");
        FixedAsset.TestField("FA Block Code");
        FABlock.Get(FixedAsset."FA Class Code", FixedAsset."FA Block Code");

        if FixedAsset."Add. Depr. Applicable" then begin
            AddedDeprApplicable := CalcNormalDepr.CheckAddedDeprApplicable(FADepBook, UntilDate, FixedAsset."Add. Depr. Applicable");
            if AddedDeprApplicable then begin
                FABlock.TestField("Add. Depreciation %");
                DBPercent += FABlock."Add. Depreciation %";
                SLPercent += FABlock."Add. Depreciation %";
            end;
        end;

        DeprRedApllicable := CalcNormalDepr.CheckDeprRedApllicable(FALedgerEntry, FADepBook, DeprBook."Depr. Threshold Days", UntilDate);

        if DeprRedApllicable then begin
            DeprBook.TestField("Depr. Reduction %");
            DBPercent -= (DBPercent * DeprBook."Depr. Reduction %" / 100);
            SLPercent -= (SLPercent * DeprBook."Depr. Reduction %" / 100);
        end
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Normal Depreciation", 'OnAfterDaysinFYRecalculateDaysInFiscalYear', '', false, false)]
    local procedure CheckingDaysInFiscalYear(
        DeprBook: Record "Depreciation Book";
        FADepBook: Record "FA Depreciation Book";
        UntilDate: Date;
        var DaysInFiscalYear: Integer;
        Year365Days: Boolean)
    begin
        if not (DeprBook."FA Book Type" in [DeprBook."FA Book Type"::" ", DeprBook."FA Book Type"::"Income Tax"]) then
            exit;

        DaysInFiscalYear := CheckDaysInFiscalYear(DeprBook.Code, FADepBook, UntilDate);

        OnAfterCheckingDaysInFiscalYear(DeprBook, FADepBook, UntilDate, DaysInFiscalYear, Year365Days);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Normal Depreciation", 'OnAfterCalculateFinalAmount', '', false, false)]
    local procedure OnAfterCalculateFinalAmount(
    DepreBook: Record "Depreciation Book";
    var Amount: Decimal;
    var IsHandled: Boolean)
    begin
        if (DepreBook."FA Book Type" = DepreBook."FA Book Type"::"Income Tax") then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Normal Depreciation", 'OnAfterSkipOnZeroValue', '', false, false)]
    local procedure OnAfterSkipOnZeroValue(
        DepreBook: Record "Depreciation Book";
        var SkiponZero: Boolean;
        var IsHandled: Boolean)
    begin
        if (SkipOnZero) and (DepreBook."FA Book Type" = DepreBook."FA Book Type"::"Income Tax") then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Check Consistency", 'OnBeforeCreateDisposerError', '', false, false)]
    local procedure OnBeforeCreateDisposerError(FixedAsset: Record "Fixed Asset"; DeprBookCode: Code[10]; var IsHandled: Boolean)
    var
        DeprBook: Record "Depreciation Book";
    begin
        DeprBook.Get(DeprBookCode);
        if DeprBook."FA Book Type" = DeprBook."FA Book Type"::"Income Tax" then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Check Consistency", 'OnBeforeCreatePostingTypeError', '', false, false)]
    local procedure OnBeforeCreatePostingTypeError(
        FAJnlLine: Record "FA Journal Line";
        FALedgEntry2: Record "FA Ledger Entry";
        DeprBook: Record "Depreciation Book";
        var IsHandled: Boolean)
    begin
        if not (DeprBook."FA Book Type" in [DeprBook."FA Book Type"::" ", DeprBook."FA Book Type"::"Income Tax"]) then
            exit;

        FAJnlLine."FA Posting Type" := FALedgEntry2."FA Posting Type";
        if (DeprBook."FA Book Type" = DeprBook."FA Book Type"::"Income Tax") and (FAJnlLine."FA Posting Type" = FAJnlLine."FA Posting Type"::Depreciation) then
            IsHandled := true;
        exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Depreciation", 'OnAfterCalcDeprYearCalculateAdditionalDepr2ndYear', '', false, false)]
    local procedure CalculateAdditionalDeprSecondYear(var DeprAmount: Decimal; FANo: Code[20]; DepreBookCode: Code[10])
    var
        FixedAsset: Record "Fixed Asset";
        DeprBook: Record "Depreciation Book";
    begin
        if FixedAsset.Get(FANo) then begin
            DeprBook.Get(DepreBookCode);
            if FixedAsset."Add. Depr. Applicable" then
                CalcAddDeprForSecondYear(DeprAmount, FANo, DepreBookCode, DeprBook."Depr. Threshold Days");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Normal Depreciation", 'OnAfterCalcSL', '', false, false)]
    local procedure OnAfterCalculateSLAmount(
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        UntilDate: Date;
        BookValue: Decimal;
        DeprBasis: Decimal;
        DeprYears: Decimal;
        NumberOfDays: Integer;
        DaysInFiscalYear: Integer;
        var ExitValue: Decimal;
        var IsHandled: Boolean;
        var RemainingLife: Decimal)
    var
        DepreciationBook: Record "Depreciation Book";
        DepreciationCalculation: Codeunit "Depreciation Calculation";
        DeprStartingDate: Date;
        DeprEndingDate: Date;
        FirstDeprDate: Date;
        SalvageValue: Decimal;
        MinusBookValue: Decimal;
        UseDeprStartingDate: Boolean;
    begin
        DepreciationBook.Get(FADepreciationBook."Depreciation Book Code");
        if not DepreciationBook."Fiscal Year 365 Days" then
            exit;

        FADepreciationBook.CalcFields("Salvage Value");
        DeprStartingDate := FADepreciationBook."Depreciation Starting Date";
        DeprEndingDate := FADepreciationBook."Depreciation Ending Date";
        FirstDeprDate := DepreciationCalculation.GetFirstDeprDate(FixedAsset."No.", FADepreciationBook."Depreciation Book Code", DepreciationBook."Fiscal Year 365 Days");
        UseDeprStartingDate := DepreciationCalculation.UseDeprStartingDate(FixedAsset."No.", FADepreciationBook."Depreciation Book Code");
        IF UseDeprStartingDate THEN
            FirstDeprDate := DeprStartingDate;
        IF FirstDeprDate < DeprStartingDate THEN
            FirstDeprDate := DeprStartingDate;

        SalvageValue := FADepreciationBook."Salvage Value";
        MinusBookValue := DepreciationCalculation.GetMinusBookValue(FixedAsset."No.", FADepreciationBook."Depreciation Book Code", 0D, 0D);
        RemainingLife := (DeprEndingDate - DeprStartingDate) - (FirstDeprDate - DeprStartingDate) + 1;
        ExitValue := (-(BookValue + SalvageValue - MinusBookValue) * NumberOfDays / RemainingLife);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Check Consistency", 'OnCheckNormalPostingOnAfterSetFALedgerEntryFilters', '', false, false)]
    local procedure CheckNormalPostingError(DepreciationBookCode: Code[10]; FANo: Code[20])
    var
        FADeprBook: Record "FA Depreciation Book";
    begin
        if (FADeprBook.Get(FANo, DepreciationBookCode) and (FADeprBook."Disposal Date" > 0D)) then
            CreateDisposedError(DepreciationBookCode, FANo);
    end;

    local procedure FilterFALedger(FANo: Code[20]; DeprBookCode2: Code[10]; IncludeGainLoss: Boolean): Decimal
    var
        FALedgEntry: Record "FA Ledger Entry";
    begin
        FALedgEntry.Reset();
        FALedgEntry.SetCurrentKey("FA No.", "Depreciation Book Code", "FA Posting Category", "FA Posting Type", "Posting Date");
        FALedgEntry.SetRange("FA No.", FANo);
        FALedgEntry.SetRange("Depreciation Book Code", DeprBookCode2);
        FALedgEntry.SetRange("FA Posting Category", FALedgEntry."FA Posting Category"::" ");
        if IncludeGainLoss then
            FALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type"::"Gain/Loss")
        else
            FALedgEntry.SetFilter("FA Posting Type", '<>%1', FALedgEntry."FA Posting Type"::"Gain/Loss");

        FALedgEntry.CalcSums(Amount);

        exit(FALedgEntry.Amount);
    end;

    local procedure CalcAddDeprForSecondYear(
        var AddDeprAmount: Decimal;
        FANumber: Code[20];
        DeprBookCode2: Code[10];
        DeprBookThresholdDays: Integer)
    var
        FALedgerEntry: Record "FA Ledger Entry";
        FixedAssetDateCalculation: Codeunit "Fixed Asset Date Calculation";
        "Count": Integer;
        AcqisitionFiscalEndDate: Date;
    begin
        FALedgerEntry.SetRange("FA No.", FANumber);
        FALedgerEntry.SetRange("Depreciation Book Code", DeprBookCode2);
        FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Acquisition Cost");
        if FALedgerEntry.FindFirst() then
            AcqisitionFiscalEndDate := FixedAssetDateCalculation.GetFiscalYearEndDateInc(FALedgerEntry."Posting Date");

        FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::Depreciation);
        if not FALedgerEntry.FindFirst() then
            exit;

        Count := FALedgerEntry.Count;

        if FALedgerEntry."Posting Date" <= AcqisitionFiscalEndDate then
            if (Count = 1) and (FALedgerEntry."Add. Depreciation Amount" <> 0) and
               (FALedgerEntry."No. of Depreciation Days" <= DeprBookThresholdDays)
            then
                AddDeprAmount += FALedgerEntry."Add. Depreciation Amount";
    end;

    local procedure CalculateDeprDays(StartingDate: Date; EndingDate: Date): Integer
    begin
        if EndingDate < StartingDate then
            exit(0);

        if (StartingDate = 0D) or (EndingDate = 0D) then
            exit(0);

        exit(1 + (EndingDate - StartingDate));
    end;

    local procedure CreateDisposedError(DepreciationBookCode: Code[20]; FANo: Code[20])
    var
        FixedAsset: Record "Fixed Asset";
        DeprBook: Record "Depreciation Book";
        DisposedErr: Label '%1 is disposed.', Comment = '%1 = FA Description';
    begin
        if FixedAsset.Get(FANo) then
            if (DeprBook.Get(DepreciationBookCode)) then
                if (DeprBook."FA Book Type" <> DeprBook."FA Book Type"::"Income Tax") then
                    Error(DisposedErr, FixedAsset.Description);
    end;

    local procedure CalculateTransferValue(FANo: Code[20]; DecimalStore: Dictionary of [Text, Decimal]; IntergerStore: Dictionary of [Text, Integer]; DateStore: Dictionary of [Text, Date]; CodeStore: Dictionary of [Text, Code[10]]; var EntryAmounts: array[4] of Decimal; var DeprMethod: Option StraightLine,DB1,DB2,DB1SL,DB2SL,"User-Defined",Manual,BelowZero; var Year365Days: Boolean; var IsHandled: Boolean)
    var
        FixedAsset: Record "Fixed Asset";
        FixedAssetShiftLine: Record "Fixed Asset Shift";
        FADeprBook: Record "FA Depreciation Book";
        DeprBook: Record "Depreciation Book";
    begin
        FixedAsset.Get(FANo);

        FixedAssetShiftLine.Reset();
        FixedAssetShiftLine.SetRange("FA No.", FixedAsset."No.");
        FixedAssetShiftLine.SetRange("Calculate FA Depreciation", true);
        if (FixedAssetShiftLine.IsEmpty()) then
            exit;

        IsHandled := true;
        FADeprBook.Get(FANo, CodeStore.Get(DeprBookCodeLbl));
        DeprBook.Get(FADeprBook."Depreciation Book Code");
        Year365Days := DeprBook."Fiscal Year 365 Days";

        TransferValuesShift(FixedAsset, EntryAmounts, DeprMethod, Year365Days, IntergerStore, CodeStore, DateStore, DecimalStore);
    end;

    local procedure TransferValuesShift(FixedAsset: Record "Fixed Asset"; var EntryAmounts: array[4] of Decimal; var DeprMethod: Option StraightLine,DB1,DB2,DB1SL,DB2SL,"User-Defined",Manual,BelowZero; Year365Days: Boolean; IntegerStore: Dictionary of [Text, Integer]; CodeStore: Dictionary of [Text, Code[10]]; DateStore: Dictionary of [Text, Date]; DecimalStore: Dictionary of [Text, Decimal])
    var
        DeprBook: Record "Depreciation Book";
        FADeprBook: Record "FA Depreciation Book";
        FixedAssetShift: Record "Fixed Asset Shift";
        DepreciationCalc: Codeunit "Depreciation Calculation";
        DaysInFiscalYear2: Integer;
        DeprStartingDate2: Date;
        FirstUserDefinedDeprDate2: Date;
        BookValue2: Decimal;
        DeprYears2: Decimal;
        FinalRoundingAmount2: Decimal;
        EndingBookValue2: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforeTransferValuesShift(FixedAsset, EntryAmounts, DeprMethod, Year365Days, IntegerStore, CodeStore, DateStore, DecimalStore, IsHandled);
        if IsHandled then
            exit;

        FixedAssetShift.Reset();
        FixedAssetShift.SetRange("FA No.", FixedAsset."No.");
        FixedAssetShift.SetRange("Calculate FA Depreciation", true);
        if not FixedAssetShift.FindFirst() then
            exit;

        FixedAssetShift.TestField("Depreciation Starting Date");
        if FixedAssetShift."Depreciation Method" = "Depreciation Method"::"User-Defined" then begin
            FixedAssetShift.TestField("Depreciation Table Code");
            FixedAssetShift.TestField("First User-Defined Depr. Date");
        end;

        case FixedAssetShift."Depreciation Method" of
            "Depreciation Method"::"Declining-Balance 1",
              "Depreciation Method"::"Declining-Balance 2",
              "Depreciation Method"::"DB1/SL",
              "Depreciation Method"::"DB2/SL":
                if FixedAssetShift."Declining-Balance %" >= 100 then
                    Error(DecliningBalancePercentErr, FixedAsset.Description, FixedAssetShift.FieldCaption("Declining-Balance %"));
        end;

        if (DeprBook."Periodic Depr. Date Calc." = DeprBook."Periodic Depr. Date Calc."::"Last Depr. Entry") and
           (FixedAssetShift."Depreciation Method" <> "Depreciation Method"::"Straight-Line")
        then begin
            FixedAssetShift."Depreciation Method" := "Depreciation Method"::"Straight-Line";
            Error(
              DepreciationMethodErr,
              FixedAsset.Description,
              FixedAssetShift.FieldCaption("Depreciation Method"),
              FixedAssetShift."Depreciation Method",
              DeprBook.TableCaption,
              DeprBook.FieldCaption("Periodic Depr. Date Calc."),
              DeprBook."Periodic Depr. Date Calc.");
        end;

        if DateStore.Get(DateFromProjectionLbl) = 0D then begin
            FixedAssetShift.CalcFields("Book Value");
            BookValue2 := FixedAssetShift."Book Value";
        end else
            BookValue2 := EntryAmounts[1];

        FixedAssetShift.CalcFields("Depreciable Basis", "Salvage Value");
        DecimalStore.Set(BookValueLbl, BookValue2);
        DecimalStore.Set(MinusBookValueLbl, DepreciationCalc.GetMinusBookValue(FixedAsset."No.", CodeStore.Get(DeprBookCodeLbl), 0D, 0D));
        DecimalStore.Set(DeprBasisLbl, FixedAssetShift."Depreciable Basis");
        DecimalStore.Set(SalvageValueLbl, FixedAssetShift."Salvage Value");
        DecimalStore.Set(CopyBookValueLbl, BookValue2);
        DeprMethod := ConvertDeprMethod(FixedAssetShift);
        DeprStartingDate2 := FixedAssetShift."Depreciation Starting Date";
        DateStore.Set(DeprStartingDateLbl, DeprStartingDate2);

        CodeStore.Set(DeprTableCodeLbl, FixedAssetShift."Depreciation Table Code");
        FirstUserDefinedDeprDate2 := FixedAssetShift."First User-Defined Depr. Date";
        DateStore.Set(FirstUserDefinedDeprDateLbl, FirstUserDefinedDeprDate2);

        if (FixedAssetShift."Depreciation Method" = "Depreciation Method"::"User-Defined") and (FirstUserDefinedDeprDate2 > DeprStartingDate2) then
            Error(DepreciationDateErr, FixedAsset.Description, FixedAssetShift.FieldCaption("First User-Defined Depr. Date"), FixedAssetShift.FieldCaption("Depreciation Starting Date"));

        DecimalStore.Set(SLPercentLbl, FixedAssetShift."Straight-Line %");
        DecimalStore.Set(DBPercentLbl, FixedAssetShift."Declining-Balance %");
        DeprYears2 := FixedAssetShift."No. of Depreciation Years";

        if FixedAssetShift."Depreciation Ending Date" > 0D then begin
            if FixedAssetShift."Depreciation Starting Date" > FixedAssetShift."Depreciation Ending Date" then
                Error(DepreciationDateErr, FixedAsset.Description, FixedAssetShift.FieldCaption("Depreciation Starting Date"), FixedAssetShift.FieldCaption("Depreciation Ending Date"));

            DeprYears2 :=
              DepreciationCalc.DeprDays(FixedAssetShift."Depreciation Starting Date", FixedAssetShift."Depreciation Ending Date", true) / 360;
        end;

        DecimalStore.Set(FixedAmountLbl, FixedAssetShift."Fixed Depr. Amount");
        FinalRoundingAmount2 := FixedAssetShift."Final Rounding Amount";

        if FinalRoundingAmount2 = 0 then
            FinalRoundingAmount2 := DeprBook."Default Final Rounding Amount";

        DecimalStore.Set(FinalRoundingAmountLbl, FinalRoundingAmount2);

        EndingBookValue2 := FixedAssetShift."Ending Book Value";

        if EndingBookValue2 = 0 then
            EndingBookValue2 := DeprBook."Default Ending Book Value";

        DecimalStore.Set(EndingBookValueLbl, EndingBookValue2);

        DateStore.Set(AcquisitionDateLbl, FixedAssetShift."Acquisition Date");
        DateStore.Set(DisposalDateLbl, FixedAssetShift."Disposal Date");
        DecimalStore.Set(PercentBelowZeroLbl, FixedAssetShift."Depr. below Zero %");
        DecimalStore.Set(AmountBelowZeroLbl, FixedAssetShift."Fixed Depr. Amount below Zero");
        DaysInFiscalYear2 := DeprBook."No. of Days in Fiscal Year";

        if DaysInFiscalYear2 = 0 then
            DaysInFiscalYear2 := CheckDaysInFiscalYear(FixedAssetShift."Depreciation Book Code", FADeprBook, DateStore.Get(EndDateLbl));

        IntegerStore.Set(DaysInFiscalYearLbl, DaysInFiscalYear2);

        if Year365Days then begin
            DeprBook.Get(FixedAssetShift."Depreciation Book Code");
            DeprYears2 :=
              DepreciationCalc.DeprDays(
                FixedAssetShift."Depreciation Starting Date", FixedAssetShift."Depreciation Ending Date", true) / DaysInFiscalYear2;
        end;
        DecimalStore.Set(DeprYearsLbl, DeprYears2);

        OnAfterTransferValuesShift(FixedAsset, EntryAmounts, DeprMethod, Year365Days, IntegerStore, CodeStore, DateStore, DecimalStore);
    end;

    local procedure ConvertDeprMethod(FixedAssetShift: Record "Fixed Asset Shift"): Option
    var
        DepreMethodOption: Option StraightLine,DB1,DB2,DB1SL,DB2SL,"User-Defined",Manual,BelowZero;
    begin
        case FixedAssetShift."Depreciation Method" of
            FixedAssetShift."Depreciation Method"::"Straight-Line":
                DepreMethodOption := DepreMethodOption::StraightLine;
            FixedAssetShift."Depreciation Method"::"Declining-Balance 1":
                DepreMethodOption := DepreMethodOption::DB1;
            FixedAssetShift."Depreciation Method"::"Declining-Balance 2":
                DepreMethodOption := DepreMethodOption::DB2;
            FixedAssetShift."Depreciation Method"::"DB1/SL":
                DepreMethodOption := DepreMethodOption::DB1SL;
            FixedAssetShift."Depreciation Method"::"DB2/SL":
                DepreMethodOption := DepreMethodOption::DB2SL;
            FixedAssetShift."Depreciation Method"::"User-Defined":
                DepreMethodOption := DepreMethodOption::"User-Defined";
            FixedAssetShift."Depreciation Method"::Manual:
                DepreMethodOption := DepreMethodOption::Manual;
            FixedAssetShift."Depreciation Method"::BelowZero:
                DepreMethodOption := DepreMethodOption::BelowZero;
        end;
        exit(DepreMethodOption);
    end;

    local procedure CheckDaysInFiscalYear(DeprBookCode: Code[10]; FADeprBook: Record "FA Depreciation Book"; UntilDate: Date): Integer
    var
        DepriciationBook: Record "Depreciation Book";
        FixedAssetDateCalculation: Codeunit "Fixed Asset Date Calculation";
        Year365Days: Boolean;
    begin
        DepriciationBook.Get(DeprBookCode);
        if DepriciationBook."FA Book Type" = DepriciationBook."FA Book Type"::"Income Tax" then begin
            if FixedAssetDateCalculation.GetFiscalYearStartDateInc(UntilDate) =
               FixedAssetDateCalculation.GetFiscalYearStartDateInc(FADeprBook."Depreciation Starting Date")
            then
                exit(
                  FixedAssetDateCalculation.GetFiscalYearEndDateInc(FADeprBook."Depreciation Starting Date") -
                  FADeprBook."Depreciation Starting Date" + 1);

            exit(FixedAssetDateCalculation.GetDaysInFiscalYearInc(UntilDate));
        end;

        if DepriciationBook."No. of Days in Fiscal Year" <> 0 then
            exit(DepriciationBook."No. of Days in Fiscal Year");

        Year365Days := DepriciationBook."Fiscal Year 365 Days";

        if Year365Days then
            exit(FixedAssetDateCalculation.GetDaysInFiscalYear(UntilDate));

        exit(360);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateNumberofDays(FixedAsset: Record "Fixed Asset"; DeprBook: Record "Depreciation Book"; var NumberofDays: Integer; FirstDeprDate: date; var UntilDate: Date; Year365Days: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckingDaysInFiscalYear(DeprBook: Record "Depreciation Book"; FADepBook: Record "FA Depreciation Book"; UntilDate: Date; var DaysInFiscalYear: Integer; Year365Days: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateDaysInFiscalYear(FixedAsset: Record "Fixed Asset"; DeprBook: Record "Depreciation Book"; var NumberofDays: Integer; var DaysInFiscalYear: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTransferValuesShift(FixedAsset: Record "Fixed Asset"; var EntryAmounts: array[4] of Decimal; var DeprMethod: Option StraightLine,DB1,DB2,DB1SL,DB2SL,"User-Defined",Manual,BelowZero; Year365Days: Boolean; IntegerStore: Dictionary of [Text, Integer]; CodeStore: Dictionary of [Text, Code[10]]; DateStore: Dictionary of [Text, Date]; DecimalStore: Dictionary of [Text, Decimal]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferValuesShift(FixedAsset: Record "Fixed Asset"; var EntryAmounts: array[4] of Decimal; var DeprMethod: Option StraightLine,DB1,DB2,DB1SL,DB2SL,"User-Defined",Manual,BelowZero; Year365Days: Boolean; IntegerStore: Dictionary of [Text, Integer]; CodeStore: Dictionary of [Text, Code[10]]; DateStore: Dictionary of [Text, Date]; DecimalStore: Dictionary of [Text, Decimal])
    begin
    end;
}
