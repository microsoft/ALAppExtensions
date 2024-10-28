// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

codeunit 42003 "SL Populate Fiscal Periods"
{
    Access = Internal;

    var
        slGlSetup: Record "SL GLSetup";
        NumPeriods: Integer;
        begFiscalYr: Integer;

    internal procedure CreateFiscalPeriodsFromGLSetup()
    var
        slFiscalPeriods: Record "SL Fiscal Periods";
        slAcctHist: Record "SL AcctHist";
        FPDateBeg: Date;
        FPDateEnd: Date;
        CurFiscalYear: Integer;
        PrevFiscalYear: Integer;
        FirstFiscalYear: Integer;
        idx: Integer;
        idxYear: Integer;
        FiscalPerEnd00: Text[4];
        FiscalPerEnd01: Text[4];
        FiscalPerEnd02: Text[4];
        FiscalPerEnd03: Text[4];
        FiscalPerEnd04: Text[4];
        FiscalPerEnd05: Text[4];
        FiscalPerEnd06: Text[4];
        FiscalPerEnd07: Text[4];
        FiscalPerEnd08: Text[4];
        FiscalPerEnd09: Text[4];
        FiscalPerEnd10: Text[4];
        FiscalPerEnd11: Text[4];
        FiscalPerEnd12: Text[4];
        yearPeriod: Text[6];
    begin
        // initialize variables
        NumPeriods := 0;
        CurFiscalYear := 1999;
        FirstFiscalYear := 1999;
        idxYear := 0;

        slGlSetup.Reset();
        if slGlSetup.FindFirst() then begin
            Evaluate(CurFiscalYear, slGlSetup.PerNbr.Substring(1, 4));
            Evaluate(PrevFiscalYear, slGlSetup.PerNbr.Substring(1, 4));
            PrevFiscalYear := PrevFiscalYear - 1;
            NumPeriods := slGlSetup.NbrPer;
            begFiscalYr := slGlSetup.BegFiscalYr;
            FiscalPerEnd00 := slGlSetup.FiscalPerEnd00;
            FiscalPerEnd01 := slGlSetup.FiscalPerEnd01;
            FiscalPerEnd02 := slGlSetup.FiscalPerEnd02;
            FiscalPerEnd03 := slGlSetup.FiscalPerEnd03;
            FiscalPerEnd04 := slGlSetup.FiscalPerEnd04;
            FiscalPerEnd05 := slGlSetup.FiscalPerEnd05;
            FiscalPerEnd06 := slGlSetup.FiscalPerEnd06;
            FiscalPerEnd07 := slGlSetup.FiscalPerEnd07;
            FiscalPerEnd08 := slGlSetup.FiscalPerEnd08;
            FiscalPerEnd09 := slGlSetup.FiscalPerEnd09;
            FiscalPerEnd10 := slGlSetup.FiscalPerEnd10;
            FiscalPerEnd11 := slGlSetup.FiscalPerEnd11;
            FiscalPerEnd12 := slGlSetup.FiscalPerEnd12;
        end else begin
            Message('SL GL Setup not migrated.  Please migrate this record');
            exit;
        end;
        slAcctHist.Reset();
        slAcctHist.SetCurrentKey(FiscYr);
        if slAcctHist.FindFirst() then
            Evaluate(FirstFiscalYear, slAcctHist.FiscYr)
        else
            FirstFiscalYear := CurFiscalYear;
        slAcctHist.Reset();
        idxYear := FirstFiscalYear;
        slFiscalPeriods.Reset();
        slFiscalPeriods.DeleteAll();
        Commit();
        while idxYear <= CurFiscalYear do begin
            idx := 1;
            while idx <= NumPeriods do begin
                case idx of
                    1:
                        begin
                            yearPeriod := Format(idxYear) + '01';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(yearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(yearPeriod);
                            slFiscalPeriods.PeriodID := 01;
                            slFiscalPeriods.Year1 := idxYear;
                            slFiscalPeriods.PeriodDT := FPDateBeg;
                            slFiscalPeriods.PerEndDT := FPDateEnd;
                            slFiscalPeriods.Insert();
                        end;
                    2:
                        begin
                            yearPeriod := Format(idxYear) + '02';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(yearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(yearPeriod);
                            slFiscalPeriods.PeriodID := 02;
                            slFiscalPeriods.Year1 := idxYear;
                            slFiscalPeriods.PeriodDT := FPDateBeg;
                            slFiscalPeriods.PerEndDT := FPDateEnd;
                            slFiscalPeriods.Insert();
                        end;
                    3:
                        begin
                            yearPeriod := Format(idxYear) + '03';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(yearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(yearPeriod);
                            slFiscalPeriods.PeriodID := 03;
                            slFiscalPeriods.Year1 := idxYear;
                            slFiscalPeriods.PeriodDT := FPDateBeg;
                            slFiscalPeriods.PerEndDT := FPDateEnd;
                            slFiscalPeriods.Insert();
                        end;
                    4:
                        begin
                            yearPeriod := Format(idxYear) + '04';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(yearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(yearPeriod);
                            slFiscalPeriods.PeriodID := 04;
                            slFiscalPeriods.Year1 := idxYear;
                            slFiscalPeriods.PeriodDT := FPDateBeg;
                            slFiscalPeriods.PerEndDT := FPDateEnd;
                            slFiscalPeriods.Insert();
                        end;
                    5:
                        begin
                            yearPeriod := Format(idxYear) + '05';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(yearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(yearPeriod);
                            slFiscalPeriods.PeriodID := 05;
                            slFiscalPeriods.Year1 := idxYear;
                            slFiscalPeriods.PeriodDT := FPDateBeg;
                            slFiscalPeriods.PerEndDT := FPDateEnd;
                            slFiscalPeriods.Insert();
                        end;
                    6:
                        begin
                            yearPeriod := Format(idxYear) + '06';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(yearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(yearPeriod);
                            slFiscalPeriods.PeriodID := 06;
                            slFiscalPeriods.Year1 := idxYear;
                            slFiscalPeriods.PeriodDT := FPDateBeg;
                            slFiscalPeriods.PerEndDT := FPDateEnd;
                            slFiscalPeriods.Insert();
                        end;
                    7:
                        begin
                            yearPeriod := Format(idxYear) + '07';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(yearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(yearPeriod);
                            slFiscalPeriods.PeriodID := 07;
                            slFiscalPeriods.Year1 := idxYear;
                            slFiscalPeriods.PeriodDT := FPDateBeg;
                            slFiscalPeriods.PerEndDT := FPDateEnd;
                            slFiscalPeriods.Insert();
                        end;
                    8:
                        begin
                            yearPeriod := Format(idxYear) + '08';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(yearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(yearPeriod);
                            slFiscalPeriods.PeriodID := 08;
                            slFiscalPeriods.Year1 := idxYear;
                            slFiscalPeriods.PeriodDT := FPDateBeg;
                            slFiscalPeriods.PerEndDT := FPDateEnd;
                            slFiscalPeriods.Insert();
                        end;
                    9:
                        begin
                            yearPeriod := Format(idxYear) + '09';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(yearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(yearPeriod);
                            slFiscalPeriods.PeriodID := 09;
                            slFiscalPeriods.Year1 := idxYear;
                            slFiscalPeriods.PeriodDT := FPDateBeg;
                            slFiscalPeriods.PerEndDT := FPDateEnd;
                            slFiscalPeriods.Insert();
                        end;
                    10:
                        begin
                            yearPeriod := Format(idxYear) + '10';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(yearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(yearPeriod);
                            slFiscalPeriods.PeriodID := 10;
                            slFiscalPeriods.Year1 := idxYear;
                            slFiscalPeriods.PeriodDT := FPDateBeg;
                            slFiscalPeriods.PerEndDT := FPDateEnd;
                            slFiscalPeriods.Insert();
                        end;
                    11:
                        begin
                            yearPeriod := Format(idxYear) + '11';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(yearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(yearPeriod);
                            slFiscalPeriods.PeriodID := 11;
                            slFiscalPeriods.Year1 := idxYear;
                            slFiscalPeriods.PeriodDT := FPDateBeg;
                            slFiscalPeriods.PerEndDT := FPDateEnd;
                            slFiscalPeriods.Insert();
                        end;
                    12:
                        begin
                            yearPeriod := Format(idxYear) + '12';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(yearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(yearPeriod);
                            slFiscalPeriods.PeriodID := 12;
                            slFiscalPeriods.Year1 := idxYear;
                            slFiscalPeriods.PeriodDT := FPDateBeg;
                            slFiscalPeriods.PerEndDT := FPDateEnd;
                            slFiscalPeriods.Insert();
                        end;
                    13:
                        begin
                            yearPeriod := Format(idxYear) + '13';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(yearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(yearPeriod);
                            slFiscalPeriods.PeriodID := 13;
                            slFiscalPeriods.Year1 := idxYear;
                            slFiscalPeriods.PeriodDT := FPDateBeg;
                            slFiscalPeriods.PerEndDT := FPDateEnd;
                            slFiscalPeriods.Insert();
                        end;
                end;
                Commit();
                idx := idx + 1;
            end;
            idxYear := idxYear + 1;
        end;
    end;

    internal procedure GetCalendarBegDateOfGLPeriod(vParm1: Text[6]): Date
    var
        FPDateEnd: Date;
        CurYear: Integer;
        PrevYear: Integer;
        PrevMonthVal: Integer;
        CurMonth: Integer;
        CurMonthStr: Text[2];
        PrevMonthStr: Text[2];
        txtNumPeriods: Text[2];
        FiscPerStr: Text[6];
    begin
        Evaluate(CurYear, vParm1.Substring(1, 4));
        PrevYear := CurYear - 1;
        CurMonthStr := vParm1.Substring(5, 2);
        txtNumPeriods := Format(NumPeriods);
        PrevMonthVal := 0;

        if CurMonthStr = '01' then begin
            if StrLen(txtNumPeriods.Trim()) = 1 then
                PrevMonthStr := '0' + txtNumPeriods.Trim()
            else
                PrevMonthStr := txtNumPeriods;
            FiscPerStr := Format(PrevYear) + PrevMonthStr;
        end else begin
            Evaluate(CurMonth, CurMonthStr);
            PrevMonthVal := CurMonth - 1;
            PrevMonthStr := Format(PrevMonthVal);

            if StrLen(PrevMonthStr.Trim()) = 1 then
                PrevMonthStr := '0' + PrevMonthStr.Trim();
            FiscPerStr := Format(CurYear) + PrevMonthStr;
        end;

        FPDateEnd := GetCalendarEndDateOfGLPeriod(FiscPerStr);
        exit(FPDateEnd);
    end;

    internal procedure GetCalendarEndDateOfGLPeriod(vPeriod: Text[6]): Date
    var
        periodList: Record SLPeriodListWrkTbl;
        FPDateEnd: Date;
        i: Integer;
        locYear: Integer;
        periodOfMaxMD: Integer;
        maxMonthDay: Text[4];
        returnDate: Text[10];
    begin
        i := 1;
        locYear := 1999;
        FPDateEnd := 19990101D;
        periodList.Reset();
        if not periodList.FindFirst() then
            while i <= NumPeriods do begin
                periodList.period := i;
                case i of
                    1:
                        periodList.md := slGlSetup.FiscalPerEnd00;
                    2:
                        periodList.md := slGlSetup.FiscalPerEnd01;
                    3:
                        periodList.md := slGlSetup.FiscalPerEnd02;
                    4:
                        periodList.md := slGlSetup.FiscalPerEnd03;
                    5:
                        periodList.md := slGlSetup.FiscalPerEnd04;
                    6:
                        periodList.md := slGlSetup.FiscalPerEnd05;
                    7:
                        periodList.md := slGlSetup.FiscalPerEnd06;
                    8:
                        periodList.md := slGlSetup.FiscalPerEnd07;
                    9:
                        periodList.md := slGlSetup.FiscalPerEnd08;
                    10:
                        periodList.md := slGlSetup.FiscalPerEnd09;
                    11:
                        periodList.md := slGlSetup.FiscalPerEnd10;
                    12:
                        periodList.md := slGlSetup.FiscalPerEnd11;
                    else
                        periodList.md := slGlSetup.FiscalPerEnd12;
                end;

                periodList.Insert();
                Commit();
                i += 1;
            end;

        Evaluate(locYear, vPeriod.Substring(1, 4));

        periodList.Reset();
        periodList.SetCurrentKey(md);
        if periodList.Find('+') then begin
            maxMonthDay := periodList.md;
            periodOfMaxMD := periodList.period;
        end;

        periodList.Reset();
        if periodList.FindSet() then
            repeat
                if periodList.period <= periodOfMaxMD then begin
                    if begFiscalYr = 1 then
                        periodList.year := Format(locYear)
                    else
                        periodList.year := Format(locYear - 1);
                end else
                    if begFiscalYr = 1 then
                        periodList.year := Format(locYear + 1)
                    else
                        periodList.year := Format(locYear);
                periodList.Modify();
                Commit();
            until periodList.Next() = 0;

        periodList.Reset();
        periodList.SetFilter(period, vPeriod.Substring(5, 2));
        if periodList.FindFirst() then begin
            returnDate := periodList.year + '-' + periodList.md.Substring(1, 2) + '-' + periodList.md.Substring(3, 2);
            Evaluate(FPDateEnd, returnDate);
        end;
        exit(FPDateEnd);
    end;
}
