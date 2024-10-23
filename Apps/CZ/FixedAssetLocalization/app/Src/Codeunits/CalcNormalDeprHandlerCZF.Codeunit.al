// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Posting;
using Microsoft.Foundation.Period;
using System.Utilities;

#pragma warning disable AL0432
codeunit 31247 "Calc. Normal Depr. Handler CZF"
{
    var
        DepreciationCalculation: Codeunit "Depreciation Calculation";
        AcquisitionDate: Date;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Normal Depreciation", 'OnAfterTransferValues2', '', false, false)]
    local procedure SetTaxDepreciationOnAfterTransferValues(FADepreciationBook: Record "FA Depreciation Book"; var DeprMethod: Enum "FA Depr. Method Internal")
    begin
        if IsTaxDeprBook(FADepreciationBook) then
            DeprMethod := Enum::"FA Depr. Method Internal".FromInteger(31240);  // Tax Depreciations
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Normal Depreciation", 'OnCalculateDeprAmountOnDeprMethodCaseLastEntry', '', false, false)]
    local procedure OnCalculateTaxDeprAmountOnDeprMethodCaseLastEntry(FADepreciationBook: Record "FA Depreciation Book";
                        DeprYears: Decimal; DaysInFiscalYear: Integer; NumberOfDays: Integer; BookValue: Decimal; var Amount: Decimal;
                        DateFromProjection: Date; UntilDate: Date)
    begin
        if IsTaxDeprBook(FADepreciationBook) then
            Amount := CalcTaxAmount(FADepreciationBook, DeprYears, DaysInFiscalYear, NumberOfDays, BookValue, DateFromProjection, UntilDate);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Normal Depreciation", 'OnCalculateDeprAmountOnDeprMethodCaseLastDeprEntry', '', false, false)]
    local procedure OnCalculateTaxDeprAmountOnDeprMethodCaseLastDeprEntry(FADepreciationBook: Record "FA Depreciation Book";
                        DeprYears: Decimal; DaysInFiscalYear: Integer; NumberOfDays: Integer; BookValue: Decimal; var Amount: Decimal;
                        DateFromProjection: Date; UntilDate: Date)
    begin
        if IsTaxDeprBook(FADepreciationBook) then
            Amount += CalcTaxAmount(FADepreciationBook, DeprYears, DaysInFiscalYear, NumberOfDays, BookValue, DateFromProjection, UntilDate);
    end;

    local procedure IsTaxDeprBook(var FADepreciationBook: Record "FA Depreciation Book"): Boolean
    begin
        exit((FADepreciationBook."Tax Deprec. Group Code CZF" <> '') or (FADepreciationBook."Sum. Deprec. Entries From CZF" <> ''));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Normal Depreciation", 'OnAfterCalcSL', '', false, false)]
    local procedure OnAfterCalcSL(FADepreciationBook: Record "FA Depreciation Book"; BookValue: Decimal; var ExitValue: Decimal; var IsHandled: Boolean; var RemainingLife: Decimal)
    begin
        if not FADepreciationBook."Keep Deprec. Ending Date CZF" then
            RemainingLife += CalcDeprBreakDays(FADepreciationBook, 0D, 0D, true);
        if RemainingLife < 1 then begin
            IsHandled := true;
            ExitValue := -BookValue;
        end;
    end;

    procedure CalcTaxAmount(var FADepreciationBook: Record "FA Depreciation Book"; DeprYears: Decimal; DaysInFiscalYear: Integer; NumberOfDays: Integer; BookValue: Decimal; DateFromProjection: Date; UntilDate: Date): Decimal
    var
        DepreciationBook: Record "Depreciation Book";
        TaxDepreciationGroupCZF: Record "Tax Depreciation Group CZF";
        CalculatedFADepreciationBook: Record "FA Depreciation Book";
        FALedgerEntry: Record "FA Ledger Entry";
        DateLastAppr, DateLastDepr, TempFromDate, TempToDate, DeprStartingDate, FirstDeprDate : Date;
        TempNoDays, CounterDepr : Integer;
        TaxDeprAmount, TempFaktor, TempDepBasis, TempBookValue, RemainingLife, DepreciatedDays, Denominator : Decimal;
        Year365Days, UseDeprStartingDate, UseRounding : Boolean;
    begin
        if BookValue = 0 then
            exit(0);
        DepreciationBook.Get(FADepreciationBook."Depreciation Book Code");
        AcquisitionDate := FADepreciationBook."Acquisition Date";
        DateLastAppr := AcquisitionDate;
        DateLastDepr := FADepreciationBook."Last Depreciation Date";
        if DateLastDepr = 0D then
            DateLastDepr := CalcDate('<-1Y>', CalcEndOfFiscalYear(AcquisitionDate));
        DaysInFiscalYear := DepreciationBook."No. of Days in Fiscal Year";
        if DaysInFiscalYear = 0 then
            DaysInFiscalYear := 360;
        Year365Days := DepreciationBook."Fiscal Year 365 Days";
        if Year365Days then begin
            DaysInFiscalYear := 365;
            DeprYears :=
              DepreciationCalculation.DeprDays(FADepreciationBook."Depreciation Starting Date", FADepreciationBook."Depreciation Ending Date", true) / DaysInFiscalYear;
        end;
        DeprStartingDate := FADepreciationBook."Depreciation Starting Date";
        if DateFromProjection > 0D then
            FirstDeprDate := DateFromProjection
        else begin
            FirstDeprDate := DepreciationCalculation.GetFirstDeprDate(FADepreciationBook."FA No.", FADepreciationBook."Depreciation Book Code", Year365Days);
            if FirstDeprDate > UntilDate then
                exit(0);
            UseDeprStartingDate := DepreciationCalculation.UseDeprStartingDate(FADepreciationBook."FA No.", FADepreciationBook."Depreciation Book Code");
            if UseDeprStartingDate then
                FirstDeprDate := DeprStartingDate;
        end;
        TempNoDays := NumberOfDays;
        TempToDate := DateLastDepr;

        if TempNoDays < DaysInFiscalYear then
            TempFaktor := TempNoDays / DaysInFiscalYear
        else
            TempFaktor := 1;

        CalculatedFADepreciationBook.Get(FADepreciationBook."FA No.", FADepreciationBook."Depreciation Book Code");

        FALedgerEntry.SetCurrentKey("FA No.", "Depreciation Book Code", "FA Posting Category", "FA Posting Type", "FA Posting Date");
        FALedgerEntry.SetRange("FA Posting Category", FALedgerEntry."FA Posting Category"::" ");
        FALedgerEntry.SetRange("FA No.", FADepreciationBook."FA No.");
        FALedgerEntry.SetRange("Depreciation Book Code", FADepreciationBook."Depreciation Book Code");
        FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::Appreciation);

        if DateFromProjection <> 0D then
            TempFromDate := DateFromProjection
        else
            TempFromDate := TempToDate + 1;
        if TempNoDays >= DaysInFiscalYear then
            TempToDate := CalcEndOfFiscalYear(TempFromDate)
        else
            TempToDate := UntilDate;

        TaxDepreciationGroupCZF.SetRange(Code, FADepreciationBook."Tax Deprec. Group Code CZF");
        TaxDepreciationGroupCZF.SetRange("Starting Date", 0D, TempFromDate);
        if not TaxDepreciationGroupCZF.FindLast() then
            if FADepreciationBook."Sum. Deprec. Entries From CZF" = '' then
                exit(0);

        CalculatedFADepreciationBook.SetFilter("FA Posting Date Filter", '..%1', UntilDate);
        CalculatedFADepreciationBook.CalcFields("Depreciable Basis", "Book Value", "Salvage Value");
        if BookValue < CalculatedFADepreciationBook."Book Value" then
            CalculatedFADepreciationBook."Book Value" := BookValue;
        TempDepBasis := CalculatedFADepreciationBook."Depreciable Basis";
        TempBookValue := CalculatedFADepreciationBook."Book Value" - TaxDeprAmount + CalculatedFADepreciationBook."Salvage Value";
        if TaxDepreciationGroupCZF."Depreciation Type" <> TaxDepreciationGroupCZF."Depreciation Type"::"Straight-line Intangible" then
            if FADepreciationBook."Prorated CZF" then begin
                CalculatedFADepreciationBook.SetRange("FA Posting Date Filter", CalcStartOfFiscalYear(UntilDate), UntilDate);
                CalculatedFADepreciationBook.CalcFields(Depreciation);
                TempBookValue := TempBookValue - CalculatedFADepreciationBook.Depreciation;
            end;

        FALedgerEntry.SetFilter("FA Posting Date", '..%1', UntilDate);
        if FALedgerEntry.FindLast() then
            DateLastAppr := FALedgerEntry."FA Posting Date";
        FALedgerEntry.SetRange("FA Posting Date", CalcEndOfFiscalYear(AcquisitionDate) + 1, UntilDate);
        if FALedgerEntry.FindFirst() then;

        if FADepreciationBook."Sum. Deprec. Entries From CZF" <> '' then begin
            TaxDeprAmount :=
              CalcDepreciatedAmount(FADepreciationBook."FA No.", FADepreciationBook."Sum. Deprec. Entries From CZF", TempFromDate, UntilDate);
            exit(-Round(TaxDeprAmount, 1, '>'));
        end;
        case TaxDepreciationGroupCZF."Depreciation Type" of
            TaxDepreciationGroupCZF."Depreciation Type"::"Straight-line":
                if not IsNonZeroDeprecation(FADepreciationBook."FA No.", FADepreciationBook."Depreciation Book Code", TempFromDate, DateFromProjection, FADepreciationBook."Prorated CZF") then
                    TaxDeprAmount := TaxDeprAmount + TempDepBasis * TaxDepreciationGroupCZF."Straight First Year" / 100
                else
                    if CalcEndOfFiscalYear(DateLastAppr) = CalcEndOfFiscalYear(AcquisitionDate) then
                        TaxDeprAmount := TaxDeprAmount + TempDepBasis * TaxDepreciationGroupCZF."Straight Next Years" / 100
                    else
                        TaxDeprAmount := TaxDeprAmount + TempDepBasis * TaxDepreciationGroupCZF."Straight Appreciation" / 100;
            TaxDepreciationGroupCZF."Depreciation Type"::"Declining-Balance":
                begin
                    CounterDepr := CalcDepr(CalcEndOfFiscalYear(DateLastAppr), CalcEndOfFiscalYear(UntilDate), FALedgerEntry);
                    if not IsNonZeroDeprecation(FADepreciationBook."FA No.", FADepreciationBook."Depreciation Book Code", TempFromDate, DateFromProjection, FADepreciationBook."Prorated CZF") then begin
                        TaxDeprAmount := TaxDeprAmount + TempDepBasis / TaxDepreciationGroupCZF."Declining First Year";
                        if TaxDepreciationGroupCZF."Declining Depr. Increase %" <> 0 then
                            TaxDeprAmount := TaxDeprAmount + (TempDepBasis * TaxDepreciationGroupCZF."Declining Depr. Increase %" / 100);
                    end else begin
                        CalculatedFADepreciationBook.CalcFields(Depreciation);
                        if CalcEndOfFiscalYear(DateLastAppr) = CalcEndOfFiscalYear(AcquisitionDate) then begin
                            Denominator := TaxDepreciationGroupCZF."Declining Next Years" - CounterDepr;
                            if Denominator < 2 then
                                Denominator := 2;
                            TaxDeprAmount := TaxDeprAmount + (2 * TempBookValue / Denominator)
                        end else
                            if CounterDepr = 0 then
                                TaxDeprAmount := TaxDeprAmount + 2 * TempBookValue / TaxDepreciationGroupCZF."Declining Appreciation"
                            else begin
                                Denominator := TaxDepreciationGroupCZF."Declining Appreciation" - CounterDepr;
                                if Denominator < 2 then
                                    Denominator := 2;
                                TaxDeprAmount := TaxDeprAmount + (2 * TempBookValue / Denominator);
                            end;
                    end;
                end;
            TaxDepreciationGroupCZF."Depreciation Type"::"Straight-line Intangible":
                begin
                    RemainingLife := (DeprYears * DaysInFiscalYear) -
                      DepreciationCalculation.DeprDays(DeprStartingDate, DepreciationCalculation.Yesterday(FirstDeprDate, Year365Days), Year365Days) +
                      CalcDeprBreakDays(FADepreciationBook, 0D, 0D, true);
                    if DateLastAppr <> AcquisitionDate then begin
                        DepreciatedDays := CalcDeprBreakDays(FADepreciationBook, CalcDate('<CM+1D>', DateLastAppr), UntilDate, false);
                        if RemainingLife + DepreciatedDays < TaxDepreciationGroupCZF."Min. Months After Appreciation" * 30 then
                            RemainingLife := TaxDepreciationGroupCZF."Min. Months After Appreciation" * 30 - DepreciatedDays;
                    end;
                    if RemainingLife <> 0 then
                        TaxDeprAmount := TempBookValue / RemainingLife * TempNoDays;
                end;
        end;

        if TaxDepreciationGroupCZF."Depreciation Type" <> TaxDepreciationGroupCZF."Depreciation Type"::"Straight-line Intangible" then
            if FADepreciationBook."Prorated CZF" then
                if DateFromProjection = 0D then
                    TaxDeprAmount := TaxDeprAmount * DepreciationCalculation.DeprDays(CalcStartOfFiscalYear(UntilDate), UntilDate, Year365Days) / 360 -
                        CalcDepreciatedAmount(FADepreciationBook."FA No.", FADepreciationBook."Depreciation Book Code", 0D, UntilDate)
                else
                    TaxDeprAmount := TaxDeprAmount * DepreciationCalculation.DeprDays(DateFromProjection, UntilDate, Year365Days) / 360
            else
                if TempFaktor < 1 then
                    TaxDeprAmount := TaxDeprAmount * TempFaktor;

        UseRounding := DepreciationBook."Use Rounding in Periodic Depr.";
        OnCalcTaxAmountOnBeforeCalcRounding(DepreciationBook, TaxDeprAmount, TaxDeprAmount, UseRounding);
        if UseRounding then
            TaxDeprAmount := Round(Round(TaxDeprAmount), 1, '>');

        exit(-TaxDeprAmount);
    end;

    procedure CalcStartOfFiscalYear(StartingDate: Date) StartFiscYear: Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        AccountingPeriod.SetRange("New Fiscal Year", true);
        AccountingPeriod.SetFilter("Starting Date", '>%1', StartingDate);
        if AccountingPeriod.FindFirst() then
            StartFiscYear := CalcDate('<-1Y>', AccountingPeriod."Starting Date")
        else
            StartFiscYear := CalcDate('<-CY>', StartingDate);
    end;

    local procedure CalcEndOfFiscalYear(StartingDate: Date) EndFiscYear: Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        AccountingPeriod.SetRange("New Fiscal Year", true);
        AccountingPeriod.SetFilter("Starting Date", '>%1', StartingDate);
        if AccountingPeriod.FindFirst() then
            EndFiscYear := CalcDate('<-1D>', AccountingPeriod."Starting Date")
        else
            EndFiscYear := CalcDate('<CY>', StartingDate);
    end;

    local procedure CalcDepreciatedAmount(FANo: Code[20]; FADeprBookCode: Code[10]; StartDate: Date; EndDate: Date): Decimal
    var
        FADepreciationBook2: Record "FA Depreciation Book";
    begin
        FADepreciationBook2.Get(FANo, FADeprBookCode);
        if StartDate <> 0D then
            FADepreciationBook2.SetRange("FA Posting Date Filter", StartDate, EndDate)
        else
            FADepreciationBook2.SetRange("FA Posting Date Filter", CalcStartOfFiscalYear(EndDate), EndDate);
        FADepreciationBook2.CalcFields(Depreciation);
        exit(-FADepreciationBook2.Depreciation);
    end;

    local procedure CalcDepr(LastAppr: Date; UntilDate: Date; var FALedgerEntry: Record "FA Ledger Entry"): Integer
    var
        CalculatedFALedgerEntry: Record "FA Ledger Entry";
        TempYearInteger: Record "Integer" temporary;
    begin
        CalculatedFALedgerEntry.CopyFilters(FALedgerEntry);
        CalculatedFALedgerEntry.SetRange("FA Posting Type", CalculatedFALedgerEntry."FA Posting Type"::Depreciation);
        CalculatedFALedgerEntry.SetRange("FA Posting Date", LastAppr, UntilDate);
        CalculatedFALedgerEntry.SetRange(Amount, 0);
        if CalculatedFALedgerEntry.FindSet() then
            repeat
                TempYearInteger.Number := Date2DMY(CalculatedFALedgerEntry."FA Posting Date", 3);
                if TempYearInteger.Insert() then;
            until CalculatedFALedgerEntry.Next() = 0;
        exit(FiscalYearCount(LastAppr, UntilDate, FALedgerEntry.GetFilter("FA No.")) - TempYearInteger.Count());
    end;

    local procedure CalcDeprBreakDays(FADepreciationBook: Record "FA Depreciation Book"; StartDate: Date; EndDate: Date; DeprBreak: Boolean) DeprBreakDays: Decimal
    var
        CalculatedFALedgerEntry: Record "FA Ledger Entry";
    begin
        Clear(DeprBreakDays);
        CalculatedFALedgerEntry.SetCurrentKey("FA No.", "Depreciation Book Code", "FA Posting Category", "FA Posting Type", "FA Posting Date");
        CalculatedFALedgerEntry.SetRange("FA Posting Category", CalculatedFALedgerEntry."FA Posting Category"::" ");
        CalculatedFALedgerEntry.SetRange("FA No.", FADepreciationBook."FA No.");
        CalculatedFALedgerEntry.SetRange("Depreciation Book Code", FADepreciationBook."Depreciation Book Code");
        CalculatedFALedgerEntry.SetRange("FA Posting Type", CalculatedFALedgerEntry."FA Posting Type"::Depreciation);
        if (StartDate <> 0D) and (EndDate <> 0D) then
            CalculatedFALedgerEntry.SetRange("FA Posting Date", StartDate + 1, EndDate);
        if DeprBreak then
            CalculatedFALedgerEntry.SetRange(Amount, 0)
        else
            CalculatedFALedgerEntry.SetFilter(Amount, '<>%1', 0);
        if CalculatedFALedgerEntry.FindSet() then
            repeat
                DeprBreakDays += CalculatedFALedgerEntry."No. of Depreciation Days";
            until CalculatedFALedgerEntry.Next() = 0;
        exit(DeprBreakDays);
    end;

    local procedure IsNonZeroDeprecation(FANo: Code[20]; DeprBookCode: Code[10]; FromDate: Date; DateFromProjection: Date; Prorated: Boolean): Boolean
    var
        CalculatedFALedgerEntry: Record "FA Ledger Entry";
    begin
        if (DateFromProjection <> 0D) or Prorated then
            exit(FromDate >= CalcEndOfFiscalYear(AcquisitionDate));

        DepreciationCalculation.SetFAFilter(CalculatedFALedgerEntry, FANo, DeprBookCode, true);
        CalculatedFALedgerEntry.SetRange("FA Posting Type", CalculatedFALedgerEntry."FA Posting Type"::Depreciation);
        CalculatedFALedgerEntry.SetFilter(Amount, '<>%1', 0);
        exit(not CalculatedFALedgerEntry.IsEmpty);
    end;

    local procedure FiscalYearCount(LastAppr: Date; UntilDate: Date; FANo: Text): Integer;
    var
        AccountingPeriod: Record "Accounting Period";
        AccountingPeriodErr: Label 'Accounting Period for %1 is missing.\Tax Depreciation for Fixed Asset %2 cannot be calculated correctly.\Create Accounting Periods for all life cycle of Fixed Asset %2 for correct Tax Depreciation calculation.', Comment = '%1 = Fiscal Year Date; %2 = Fixed Asset No. filter';
    begin
        AccountingPeriod.SetFilter("Starting Date", '%1..', UntilDate);
        if AccountingPeriod.IsEmpty() then
            Error(AccountingPeriodErr, UntilDate, FANo);
        AccountingPeriod.SetFilter("Starting Date", '..%1', LastAppr);
        if AccountingPeriod.IsEmpty() then
            Error(AccountingPeriodErr, LastAppr, FANo);

        AccountingPeriod.SetRange("Starting Date", LastAppr, UntilDate);
        AccountingPeriod.SetRange("New Fiscal Year", true);
        exit(AccountingPeriod.Count());
    end;

    #region Use FA Ledger Check
    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnAfterValidateEvent', 'Depreciation Book Code', false, false)]
    local procedure SetUseFALedgerCheckOnAfterValidateDepreciationBookCode(var Rec: Record "FA Depreciation Book"; var xRec: Record "FA Depreciation Book")
    var
        DepreciationBook: Record "Depreciation Book";
    begin
        if (Rec."Depreciation Book Code" <> xRec."Depreciation Book Code") and (Rec."Depreciation Book Code" <> '') then begin
            DepreciationBook.Get(Rec."Depreciation Book Code");
            Rec."Use FA Ledger Check" := DepreciationBook."Use FA Ledger Check";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Normal Depreciation", 'OnAfterGetDeprBooks', '', false, false)]
    local procedure SetUseFALedgerCheckOnAfterGetDepreciationBooksCalculateNormalDepreciation(var DepreciationBook: Record "Depreciation Book"; var FADepreciationBook: Record "FA Depreciation Book")
    begin
        DepreciationBook."Use FA Ledger Check" := FADepreciationBook."Use FA Ledger Check";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Custom 1 Depr.", 'OnAfterGetDeprBooks', '', false, false)]
    local procedure SetUseFALedgerCheckOnAfterGetDepreciationBooksCalculateCustom1Depreciation(var DepreciationBook: Record "Depreciation Book"; var FADepreciationBook: Record "FA Depreciation Book")
    begin
        DepreciationBook."Use FA Ledger Check" := FADepreciationBook."Use FA Ledger Check";
    end;
    #endregion Use FA Ledger Check

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Depreciation Calculation", 'OnBeforeCalcRounding', '', false, false)]
    local procedure RoundUpOnBeforeCalcRounding(DeprBook: Record "Depreciation Book"; var DeprAmount: Decimal; var IsHandled: Boolean)
    begin
        if DeprBook."Use Rounding in Periodic Depr." then begin
            DeprAmount := Round(DeprAmount, 1, '>');
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Depreciation Calculation", 'OnAfterGetFAPostingTypeSetup', '', false, false)]
    local procedure CheckOnAfterGetFAPostingTypeSetup(var FAPostingTypeSetup: Record "FA Posting Type Setup"; Type: Option IncludeInDeprCalc,IncludeInGainLoss,DepreciationType,ReverseType)
    begin
        if Type = Type::IncludeInGainLoss then
            FAPostingTypeSetup.TestField("Include in Gain/Loss Calc.", true);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCalcTaxAmountOnBeforeCalcRounding(DepreciationBook: Record "Depreciation Book"; OrigTaxDeprAmount: Decimal; var TaxDeprAmount: Decimal; var UseRounding: Boolean)
    begin
    end;
}
