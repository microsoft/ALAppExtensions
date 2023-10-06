// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.Journal;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 18638 "Make FA Led. Entry Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Make FA Ledger Entry", 'OnAfterCopyFromFAJnlLine', '', false, false)]
    local procedure OnAfterCopyFromFAJnlLine(FAJournalLine: Record "FA Journal Line"; var FALedgerEntry: Record "FA Ledger Entry")
    begin
        UpdateFALedgerEntry(FAJournalLine, FALedgerEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Make FA Ledger Entry", 'OnAfterCopyFromFACard', '', false, false)]
    local procedure OnAfterCopyFromFACard(var FALedgerEntry: Record "FA Ledger Entry"; var FixedAsset: Record "Fixed Asset"; var FADepreciationBook: Record "FA Depreciation Book")
    begin
        CopyfromFixedAssetCard(FALedgerEntry, FixedAsset, FADepreciationBook);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Make FA Ledger Entry", 'OnAfterCopyFromGenJnlLine', '', false, false)]
    local procedure OnAfterCopyFromGenJnlLine(GenJournalLine: Record "Gen. Journal Line"; var FALedgerEntry: Record "FA Ledger Entry")
    var
        FADeprBook: Record "FA Depreciation Book";
    begin
        FALedgerEntry."Shift Type" := GenJournalLine."Shift Type";
        FALedgerEntry."Industry Type" := GenJournalLine."Industry Type";
        FALedgerEntry."No. of Days for Shift" := GenJournalLine."No. of Days for Shift";
        FALedgerEntry."Shift Entry" := GenJournalLine."FA Shift Line No." <> 0;
        FALedgerEntry."FA Shift Line No" := GenJournalLine."FA Shift Line No.";

        FADeprBook.Reset();
        FADeprBook.SetRange("FA No.", GenJournalLine."Account No.");
        FADeprBook.SetRange("Depreciation Book Code", FALedgerEntry."Depreciation Book Code");
        if FADeprBook.FindFirst() then begin
            FALedgerEntry."Straight-Line %" := FADeprBook."Straight-Line %";
            FALedgerEntry."No. of Depreciation Years" := FADeprBook."No. of Depreciation Years";
            FALedgerEntry."Depreciation Ending Date" := FADeprBook."Depreciation Ending Date";

            if FALedgerEntry."FA Posting Group" = '' then
                FALedgerEntry."FA Posting Group" := FADeprBook."FA Posting Group";

            if FALedgerEntry.Description = '' then
                FALedgerEntry.Description := FADeprBook.Description;
        end;
    end;

    local procedure CopyfromFixedAssetCard(var FALedgerEntry: Record "FA Ledger Entry"; var FixedAsset: Record "Fixed Asset"; var FADepreciationBook: Record "FA Depreciation Book")
    var
        FixedAssetShift: Record "Fixed Asset Shift";
        FixedAssetBlock: Record "Fixed Asset Block";
        DepreciationBook: Record "Depreciation Book";
        DeprCalculation: Codeunit "Depreciation Calculation";
        CalcNormalDeprSubscriber: Codeunit "Calc Normal Depreciation";
        AddDeprPct: Decimal;
        AddDeprAmt: array[2] of Decimal;
        FixedAssetShiftLineNo: Integer;
    begin
        FixedAssetShiftLineNo := 0;
        FixedAssetShift.Reset();
        FixedAssetShift.SetRange("FA No.", FixedAsset."No.");
        FixedAssetShift.SetRange("Depreciation Book Code", FALedgerEntry."Depreciation Book Code");
        FixedAssetShift.SetRange("Line No.", FALedgerEntry."FA Shift Line No");
        FixedAssetShift.SetRange("Fixed Asset Posting Group", FALedgerEntry."FA Posting Group");
        if FixedAssetShift.FindFirst() then
            FixedAssetShiftLineNo := FixedAssetShift."Line No.";

        if FixedAssetShiftLineNo = 0 then begin
            FALedgerEntry."FA Exchange Rate" := FADepreciationBook.GetExchangeRate();
            FALedgerEntry."Depreciation Method" := FADepreciationBook."Depreciation Method";
            FALedgerEntry."Depreciation Starting Date" := FADepreciationBook."Depreciation Starting Date";
        end else begin
            FALedgerEntry."FA Exchange Rate" := FixedAssetShift.GetExchangeRate();
            FALedgerEntry."Depreciation Method" := FixedAssetShift."Depreciation Method";
            FALedgerEntry."Depreciation Starting Date" := FixedAssetShift."Depreciation Starting Date";
        end;

        if FADepreciationBook."FA Book Type" = FADepreciationBook."FA Book Type"::"Income Tax" then begin
            CheckFiscalYearForIncTax(FALedgerEntry."FA Posting Date");
            DepreciationBook.Get(FALedgerEntry."Depreciation Book Code");
            FixedAsset.TestField("FA Block Code");
            FixedAssetBlock.Get(FALedgerEntry."FA Class Code", FixedAsset."FA Block Code");

            if FALedgerEntry."Depreciation Method" in [
                "Depreciation Method"::"Straight-Line",
                "Depreciation Method"::"DB1/SL",
                "Depreciation Method"::"DB2/SL"]
            then
                AddDeprAmt[1] := FixedAssetBlock."Add. Depreciation %";

            if FALedgerEntry."Depreciation Method" in [
                "Depreciation Method"::"Declining-Balance 1",
                "Depreciation Method"::"Declining-Balance 2",
                "Depreciation Method"::"DB1/SL", "Depreciation Method"::"DB2/SL"]
            then
                AddDeprAmt[2] := FixedAssetBlock."Add. Depreciation %";

            if (FALedgerEntry."FA Posting Type" = FALedgerEntry."FA Posting Type"::Depreciation) and
                (FALedgerEntry."Depreciation Starting Date" <> 0D)
            then begin
                FALedgerEntry."Add. Depreciation" :=
                    CalcNormalDeprSubscriber.CheckAddedDeprApplicable(
                        FADepreciationBook,
                        FALedgerEntry."FA Posting Date",
                        FixedAsset."Add. Depr. Applicable") and
                    (FALedgerEntry."FA Posting Category" = FALedgerEntry."FA Posting Category"::" ") and
                    (FixedAssetBlock."Add. Depreciation %" <> 0);

                if FALedgerEntry."Add. Depreciation" then begin
                    FALedgerEntry."Add. Depreciation Amount" :=
                        FALedgerEntry.Amount * FixedAssetBlock."Add. Depreciation %" /
                        (FixedAssetBlock."Depreciation %" + FixedAssetBlock."Add. Depreciation %");

                    if DepreciationBook."Use Rounding in Periodic Depr." then
                        FALedgerEntry."Add. Depreciation Amount" :=
                            DeprCalculation.CalcRounding(FALedgerEntry."Depreciation Book Code", FALedgerEntry."Add. Depreciation Amount");
                end else begin
                    AddDeprAmt[1] := 0;
                    AddDeprAmt[2] := 0;
                end;

                if FixedAsset."Add. Depr. Applicable" then
                    if CalcAddDeprSecondYear(
                      FALedgerEntry."Add. Depreciation Amount",
                      AddDeprPct,
                      FixedAsset."No.",
                      FALedgerEntry."Depreciation Book Code",
                      DepreciationBook."Depr. Threshold Days")
                    then
                        FALedgerEntry."Add. Depreciation" := true;

                FALedgerEntry."Depr. Reduction Applied" :=
                   CalcNormalDeprSubscriber.CheckDeprRedApllicable(
                       FALedgerEntry,
                       FADepreciationBook,
                       DepreciationBook."Depr. Threshold Days",
                       FALedgerEntry."FA Posting Date");
            end;
        end;

        if FixedAssetShiftLineNo = 0 then begin
            FALedgerEntry."Depreciation ending Date" := FADepreciationBook."Depreciation ending Date";
            FALedgerEntry."Straight-Line %" := FADepreciationBook."Straight-Line %" + AddDeprAmt[1];
            if FALedgerEntry."Depr. Reduction Applied" then
                FALedgerEntry."Straight-Line %" -= (FALedgerEntry."Straight-Line %" * DepreciationBook."Depr. Reduction %" / 100);

            FALedgerEntry."No. of Depreciation Years" := FADepreciationBook."No. of Depreciation Years";
            FALedgerEntry."Fixed Depr. Amount" := FADepreciationBook."Fixed Depr. Amount";
            FALedgerEntry."Declining-Balance %" := FADepreciationBook."Declining-Balance %" + AddDeprAmt[2];
            if FALedgerEntry."Depr. Reduction Applied" then
                FALedgerEntry."Declining-Balance %" -= (FALedgerEntry."Declining-Balance %" * DepreciationBook."Depr. Reduction %" / 100);

        end else begin
            FALedgerEntry."Depreciation ending Date" := FixedAssetShift."Depreciation ending Date";
            FALedgerEntry."Straight-Line %" := FixedAssetShift."Straight-Line %";
            FALedgerEntry."No. of Depreciation Years" := FixedAssetShift."No. of Depreciation Years";
            FALedgerEntry."Fixed Depr. Amount" := FixedAssetShift."Fixed Depr. Amount";
            FALedgerEntry."Declining-Balance %" := FixedAssetShift."Declining-Balance %";
            FALedgerEntry."Shift Type" := FixedAssetShift."Shift Type";
            FALedgerEntry."Industry Type" := FixedAssetShift."Industry Type";
            FALedgerEntry."Shift Entry" := true;
            FALedgerEntry."Depreciation Table Code" := FixedAssetShift."Depreciation Table Code";
            FALedgerEntry."Use FA Ledger Check" := FixedAssetShift."Use FA Ledger Check";
            FALedgerEntry."Depr. Starting Date (Custom 1)" := FixedAssetShift."Depr. Starting Date (Custom 1)";
            FALedgerEntry."Depr. ending Date (Custom 1)" := FixedAssetShift."Depr. ending Date (Custom 1)";
            FALedgerEntry."Accum. Depr. % (Custom 1)" := FixedAssetShift."Accum. Depr. % (Custom 1)";
            FALedgerEntry."Depr. % this year (Custom 1)" := FixedAssetShift."Depr. This Year % (Custom 1)";
            FALedgerEntry."Property Class (Custom 1)" := ConvertPropertyClassType(FixedAssetShift);
        end;

        if FALedgerEntry."Add. Depreciation" then
            CalcAddDeprPercentage(FALedgerEntry, AddDeprPct, FixedAsset."No.", FALedgerEntry."Depreciation Book Code");
    end;

    local procedure ConvertPropertyClassType(FixedAssetShift: Record "Fixed Asset Shift"): Option
    var
        PropertyClassEnum: Enum "Property Class Custom 1";
        OrdinalValue: Integer;
    begin
        case FixedAssetShift."Property Class (Custom 1)" of
            FixedAssetShift."Property Class (Custom 1)"::" ":
                PropertyClassEnum := PropertyClassEnum::" ";
            FixedAssetShift."Property Class (Custom 1)"::"Personal Property":
                PropertyClassEnum := PropertyClassEnum::"Personal Property";
            FixedAssetShift."Property Class (Custom 1)"::"Real Property":
                PropertyClassEnum := PropertyClassEnum::"Real Property";
        end;
        OrdinalValue := PropertyClassEnum.AsInteger();
        exit(OrdinalValue);
    end;

    local procedure CheckFiscalYearForIncTax(TillDate: Date)
    var
        AccountingPeriodIncTax: Record "FA Accounting Period Inc. Tax";
        FAPostingDateErr: Label 'FA Posting Date for Income Tax is beyond the fiscal year end date.';
    begin
        AccountingPeriodIncTax.Reset();
        AccountingPeriodIncTax.SetRange(Closed, false);
        if AccountingPeriodIncTax.FindSet() then
            repeat
                if TillDate < AccountingPeriodIncTax."Starting Date" then
                    exit;
            until AccountingPeriodIncTax.Next() = 0;

        Error(FAPostingDateErr);
    end;

    local procedure CalcAddDeprSecondYear(var AddDeprAmount: Decimal; var AddDeprPct: Decimal; FANumber: Code[20]; DeprBookCode2: Code[10]; DeprBookThresholdDays: Integer): Boolean
    var
        FALedgerEntry: Record "FA Ledger Entry";
        FADateCalculation: Codeunit "Fixed Asset Date Calculation";
        "Count": Integer;
        AcquisitionCost: Decimal;
        AcquisitionFiscalendDate: Date;
    begin
        FALedgerEntry.SetRange("FA No.", FANumber);
        FALedgerEntry.SetRange("Depreciation Book Code", DeprBookCode2);
        FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Acquisition Cost");
        if FALedgerEntry.FindFirst() then
            AcquisitionCost := FALedgerEntry.Amount;

        AcquisitionFiscalendDate := FADateCalculation.GetFiscalYearendDateInc(FALedgerEntry."Posting Date");
        FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::Depreciation);
        if not FALedgerEntry.FindFirst() then
            exit(false);

        Count := FALedgerEntry.Count;

        if FALedgerEntry."Posting Date" <= AcquisitionFiscalendDate then begin
            if (Count = 1) and (FALedgerEntry."Add. Depreciation Amount" <> 0) and
               (FALedgerEntry."No. of Depreciation Days" <= DeprBookThresholdDays)
            then begin
                AddDeprAmount += FALedgerEntry."Add. Depreciation Amount";
                AddDeprPct := Abs((AddDeprAmount / AcquisitionCost) * 100);
                exit(true);
            end;
            exit(false);
        end;
        exit(false);
    end;

    local procedure CalcAddDeprPercentage(var FALedgerEntry: Record "FA Ledger Entry"; AddDeprPct: Decimal; FANumber: Code[20]; DeprBkCode: Code[10])
    var
        FixedAssetLedgerEntry: Record "FA Ledger Entry";
        DeprBaseAmount: Decimal;
    begin
        FixedAssetLedgerEntry.SetRange("FA No.", FANumber);
        FixedAssetLedgerEntry.SetRange("Depreciation Book Code", DeprBkCode);
        FixedAssetLedgerEntry.SetRange("FA Posting Type", FixedAssetLedgerEntry."FA Posting Type"::Depreciation);
        if FixedAssetLedgerEntry.IsEmpty then
            exit;

        if FALedgerEntry."Straight-Line %" <> 0 then
            FALedgerEntry."Straight-Line %" += AddDeprPct
        else
            if FALedgerEntry."Declining-Balance %" <> 0 then begin
                FixedAssetLedgerEntry.SetRange("FA Posting Type");
                if FixedAssetLedgerEntry.FindSet() then
                    repeat
                        DeprBaseAmount += FixedAssetLedgerEntry.Amount;
                    until FixedAssetLedgerEntry.Next() = 0;

                FALedgerEntry."Declining-Balance %" := Abs((FALedgerEntry.Amount / DeprBaseAmount) * 100);
            end;
    end;

    local procedure UpdateFALedgerEntry(FAJournalLine: Record "FA Journal Line"; var FALedgerEntry: Record "FA Ledger Entry")
    var
        FADeprBook: Record "FA Depreciation Book";
        FixedAssetShift: Record "Fixed Asset Shift";
    begin
        FALedgerEntry."Shift Type" := FAJournalLine."Shift Type";
        FALedgerEntry."Industry Type" := FAJournalLine."Industry Type";
        FALedgerEntry."No. of Days for Shift" := FAJournalLine."No. of Days for Shift";
        FALedgerEntry."Shift Entry" := FAJournalLine."FA Shift Line No." <> 0;

        FADeprBook.Reset();
        FADeprBook.SetRange("FA No.", FALedgerEntry."FA No.");
        FADeprBook.SetRange("Depreciation Book Code", FALedgerEntry."Depreciation Book Code");
        if FADeprBook.FindFirst() then begin
            FALedgerEntry."Straight-Line %" := FADeprBook."Straight-Line %";
            FALedgerEntry."No. of Depreciation Years" := FADeprBook."No. of Depreciation Years";
            FALedgerEntry."Depreciation Ending Date" := FADeprBook."Depreciation Ending Date";

            if FALedgerEntry."FA Posting Group" = '' then
                FALedgerEntry."FA Posting Group" := FADeprBook."FA Posting Group";

            if FALedgerEntry.Description = '' then
                FALedgerEntry.Description := FADeprBook.Description;

            FixedAssetShift.Reset();
            FixedAssetShift.SetRange("FA No.", FADeprBook."FA No.");
            FixedAssetShift.SetRange("Fixed Asset Posting Group", FALedgerEntry."FA Posting Group");
            FixedAssetShift.SetRange("Depreciation Starting Date", FALedgerEntry."Depreciation Starting Date");
            FixedAssetShift.SetRange("Depreciation ending Date", FALedgerEntry."Depreciation Ending Date");
            FixedAssetShift.SetRange("Shift Type", FALedgerEntry."Shift Type");
            if FixedAssetShift.FindFirst() then begin
                FALedgerEntry."Depreciation Starting Date" := FixedAssetShift."Depreciation Starting Date";
                FALedgerEntry."Depreciation Ending Date" := FixedAssetShift."Depreciation ending Date";
                FALedgerEntry."No. of Depreciation Years" := FixedAssetShift."No. of Depreciation Years";
                FALedgerEntry."Straight-Line %" := FixedAssetShift."Straight-Line %";
                FALedgerEntry.Modify();
            end;
        end;
    end;
}
