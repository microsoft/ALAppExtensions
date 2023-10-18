// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Depreciation;

codeunit 18631 "Calc Normal Depreciation"
{
    procedure CheckAddedDeprApplicable(
        FADeprBook: Record "FA Depreciation Book";
        TillDate: Date;
        AddedDeprApplicable: Boolean): Boolean
    var
        FADateCalcSubscriber: Codeunit "Fixed Asset Date Calculation";
    begin
        if FADeprBook."FA Book Type" <> "Fixed Asset Book Type"::"Income Tax" then
            exit(false);

        exit(
          (FADateCalcSubscriber.GetFiscalYearStartDateInc(FADeprBook."Depreciation Starting Date") =
           FADateCalcSubscriber.GetFiscalYearStartDateInc(TillDate)) and
           CheckDisposal(FADeprBook."FA No.", FADeprBook."Depreciation Book Code") and
           AddedDeprApplicable);
    end;

    procedure CheckDeprRedApllicable(
        FALedgEntry: Record "FA Ledger Entry";
        FADepBook: Record "FA Depreciation Book";
        ThresholdDays: Integer;
        TillDate: Date): Boolean
    var
        FixedAssetLedgEntry: Record "FA Ledger Entry";
        FADateCalcSubscriber: Codeunit "Fixed Asset Date Calculation";
        FAPostingDate: Date;
        FiscalYearStartDate: Date;
        ReferenceDate: Date;
    begin
        if FADepBook."FA Book Type" <> "Fixed Asset Book Type"::"Income Tax" then
            exit(false);

        FixedAssetLedgEntry.Reset();
        FixedAssetLedgEntry.SetCurrentKey("FA No.", "Depreciation Book Code", "FA Posting Category", "FA Posting Type", "Posting Date");
        FixedAssetLedgEntry.SetRange("FA No.", FADepBook."FA No.");
        FixedAssetLedgEntry.SetRange("Depreciation Book Code", FADepBook."Depreciation Book Code");
        FixedAssetLedgEntry.SetRange("FA Posting Category", FixedAssetLedgEntry."FA Posting Category"::" ");
        FixedAssetLedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type"::"Acquisition Cost");
        if FixedAssetLedgEntry.FindFirst() then
            FAPostingDate := FixedAssetLedgEntry."FA Posting Date"
        else
            exit(false);

        FiscalYearStartDate := FADateCalcSubscriber.GetFiscalYearStartDateInc(FADepBook."Depreciation Starting Date");
        ReferenceDate := FiscalYearStartDate + ThresholdDays;
        exit(
          (FADepBook."Depreciation Starting Date" > ReferenceDate) and
          (FiscalYearStartDate = FADateCalcSubscriber.GetFiscalYearStartDateInc(FAPostingDate)) and
          (FADepBook."FA Book Type" = FADepBook."FA Book Type"::"Income Tax") and
          (FiscalYearStartDate = FADateCalcSubscriber.GetFiscalYearStartDateInc(TillDate)));
    end;

    local procedure CheckDisposal(FANo: Code[20]; DeprBookCode: Code[20]): Boolean
    var
        FALedgerEntry: Record "FA Ledger Entry";
    begin
        FALedgerEntry.Reset();
        FALedgerEntry.SetRange("FA No.", FANo);
        FALedgerEntry.SetRange("Depreciation Book Code", DeprBookCode);
        FALedgerEntry.SetRange("FA Posting Category", FALedgerEntry."FA Posting Category"::Disposal);
        exit(FALedgerEntry.IsEmpty());
    end;
}
