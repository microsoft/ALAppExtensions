// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

codeunit 47003 "SL Populate Fiscal Periods"
{
    Access = Internal;

    var
        SLGLSetup: Record "SL GLSetup";
        NumPeriods: Integer;
        BeginFiscalYear: Integer;

    internal procedure CreateFiscalPeriodsFromGLSetup()
    var
        SLFiscalPeriods: Record "SL Fiscal Periods";
        SLAcctHist: Record "SL AcctHist";
        FPDateBeg: Date;
        FPDateEnd: Date;
        CurFiscalYear: Integer;
        PrevFiscalYear: Integer;
        FirstFiscalYear: Integer;
        Index: Integer;
        IndexYear: Integer;
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
        YearPeriod: Text[6];
    begin
        // initialize variables
        NumPeriods := 0;
        CurFiscalYear := 1999;
        FirstFiscalYear := 1999;
        IndexYear := 0;

        SLGLSetup.Reset();
        if SLGLSetup.FindFirst() then begin
            Evaluate(CurFiscalYear, SLGLSetup.PerNbr.Substring(1, 4));
            Evaluate(PrevFiscalYear, SLGLSetup.PerNbr.Substring(1, 4));
            PrevFiscalYear := PrevFiscalYear - 1;
            NumPeriods := SLGLSetup.NbrPer;
            BeginFiscalYear := SLGLSetup.BegFiscalYr;
            FiscalPerEnd00 := SLGLSetup.FiscalPerEnd00;
            FiscalPerEnd01 := SLGLSetup.FiscalPerEnd01;
            FiscalPerEnd02 := SLGLSetup.FiscalPerEnd02;
            FiscalPerEnd03 := SLGLSetup.FiscalPerEnd03;
            FiscalPerEnd04 := SLGLSetup.FiscalPerEnd04;
            FiscalPerEnd05 := SLGLSetup.FiscalPerEnd05;
            FiscalPerEnd06 := SLGLSetup.FiscalPerEnd06;
            FiscalPerEnd07 := SLGLSetup.FiscalPerEnd07;
            FiscalPerEnd08 := SLGLSetup.FiscalPerEnd08;
            FiscalPerEnd09 := SLGLSetup.FiscalPerEnd09;
            FiscalPerEnd10 := SLGLSetup.FiscalPerEnd10;
            FiscalPerEnd11 := SLGLSetup.FiscalPerEnd11;
            FiscalPerEnd12 := SLGLSetup.FiscalPerEnd12;
        end else begin
            Message('SL GL Setup not migrated.  Please migrate this record');
            exit;
        end;
        SLAcctHist.Reset();
        SLAcctHist.SetCurrentKey(FiscYr);
        if SLAcctHist.FindFirst() then
            Evaluate(FirstFiscalYear, SLAcctHist.FiscYr)
        else
            FirstFiscalYear := CurFiscalYear;
        SLAcctHist.Reset();
        IndexYear := FirstFiscalYear;
        SLFiscalPeriods.Reset();
        SLFiscalPeriods.DeleteAll();
        Commit();
        while IndexYear <= CurFiscalYear do begin
            Index := 1;
            while Index <= NumPeriods do begin
                case Index of
                    1:
                        begin
                            YearPeriod := Format(IndexYear) + '01';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(YearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(YearPeriod);
                            SLFiscalPeriods.PeriodID := 01;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    2:
                        begin
                            YearPeriod := Format(IndexYear) + '02';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(YearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(YearPeriod);
                            SLFiscalPeriods.PeriodID := 02;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    3:
                        begin
                            YearPeriod := Format(IndexYear) + '03';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(YearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(YearPeriod);
                            SLFiscalPeriods.PeriodID := 03;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    4:
                        begin
                            YearPeriod := Format(IndexYear) + '04';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(YearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(YearPeriod);
                            SLFiscalPeriods.PeriodID := 04;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    5:
                        begin
                            YearPeriod := Format(IndexYear) + '05';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(YearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(YearPeriod);
                            SLFiscalPeriods.PeriodID := 05;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    6:
                        begin
                            YearPeriod := Format(IndexYear) + '06';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(YearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(YearPeriod);
                            SLFiscalPeriods.PeriodID := 06;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    7:
                        begin
                            YearPeriod := Format(IndexYear) + '07';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(YearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(YearPeriod);
                            SLFiscalPeriods.PeriodID := 07;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    8:
                        begin
                            YearPeriod := Format(IndexYear) + '08';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(YearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(YearPeriod);
                            SLFiscalPeriods.PeriodID := 08;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    9:
                        begin
                            YearPeriod := Format(IndexYear) + '09';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(YearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(YearPeriod);
                            SLFiscalPeriods.PeriodID := 09;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    10:
                        begin
                            YearPeriod := Format(IndexYear) + '10';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(YearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(YearPeriod);
                            SLFiscalPeriods.PeriodID := 10;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    11:
                        begin
                            YearPeriod := Format(IndexYear) + '11';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(YearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(YearPeriod);
                            SLFiscalPeriods.PeriodID := 11;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    12:
                        begin
                            YearPeriod := Format(IndexYear) + '12';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(YearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(YearPeriod);
                            SLFiscalPeriods.PeriodID := 12;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    13:
                        begin
                            YearPeriod := Format(IndexYear) + '13';
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(YearPeriod);
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(YearPeriod);
                            SLFiscalPeriods.PeriodID := 13;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                end;
                Commit();
                Index := Index + 1;
            end;
            IndexYear := IndexYear + 1;
        end;
    end;

    internal procedure GetCalendarBegDateOfGLPeriod(GLPeriod: Text[6]): Date
    var
        FPDateEnd: Date;
        CurYear: Integer;
        PrevYear: Integer;
        PrevMonthVal: Integer;
        CurMonth: Integer;
        CurMonthStr: Text[2];
        FiscPerStr: Text[6];
        NumPeriodsTxt: Text[2];
        PrevMonthStr: Text[2];
    begin
        Evaluate(CurYear, GLPeriod.Substring(1, 4));
        PrevYear := CurYear - 1;
        CurMonthStr := GLPeriod.Substring(5, 2);
        NumPeriodsTxt := Format(NumPeriods);
        PrevMonthVal := 0;

        if CurMonthStr = '01' then begin
            if StrLen(NumPeriodsTxt.Trim()) = 1 then
                PrevMonthStr := '0' + NumPeriodsTxt.Trim()
            else
                PrevMonthStr := NumPeriodsTxt;
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

    internal procedure GetCalendarEndDateOfGLPeriod(GLPeriod: Text[6]): Date
    var
        PeriodList: Record SLPeriodListWrkTbl;
        FPDateEnd: Date;
        I: Integer;
        LocYear: Integer;
        PeriodOfMaxMD: Integer;
        MaxMonthDay: Text[4];
        ReturnDate: Text[10];
    begin
        I := 1;
        LocYear := 1999;
        FPDateEnd := 19990101D;
        if not PeriodList.FindFirst() then
            while I <= NumPeriods do begin
                PeriodList.period := I;
                case I of
                    1:
                        PeriodList.md := SLGLSetup.FiscalPerEnd00;
                    2:
                        PeriodList.md := SLGLSetup.FiscalPerEnd01;
                    3:
                        PeriodList.md := SLGLSetup.FiscalPerEnd02;
                    4:
                        PeriodList.md := SLGLSetup.FiscalPerEnd03;
                    5:
                        PeriodList.md := SLGLSetup.FiscalPerEnd04;
                    6:
                        PeriodList.md := SLGLSetup.FiscalPerEnd05;
                    7:
                        PeriodList.md := SLGLSetup.FiscalPerEnd06;
                    8:
                        PeriodList.md := SLGLSetup.FiscalPerEnd07;
                    9:
                        PeriodList.md := SLGLSetup.FiscalPerEnd08;
                    10:
                        PeriodList.md := SLGLSetup.FiscalPerEnd09;
                    11:
                        PeriodList.md := SLGLSetup.FiscalPerEnd10;
                    12:
                        PeriodList.md := SLGLSetup.FiscalPerEnd11;
                    else
                        PeriodList.md := SLGLSetup.FiscalPerEnd12;
                end;

                PeriodList.Insert();
                Commit();
                I += 1;
            end;

        Evaluate(LocYear, GLPeriod.Substring(1, 4));

        PeriodList.Reset();
        PeriodList.SetCurrentKey(md);
        if PeriodList.Find('+') then begin
            MaxMonthDay := PeriodList.md;
            PeriodOfMaxMD := PeriodList.period;
        end;

        PeriodList.Reset();
        if PeriodList.FindSet() then
            repeat
                if PeriodList.period <= PeriodOfMaxMD then begin
                    if BeginFiscalYear = 1 then
                        PeriodList.year := Format(LocYear)
                    else
                        PeriodList.year := Format(LocYear - 1);
                end else
                    if BeginFiscalYear = 1 then
                        PeriodList.year := Format(LocYear + 1)
                    else
                        PeriodList.year := Format(LocYear);
                PeriodList.Modify();
                Commit();
            until PeriodList.Next() = 0;

        PeriodList.Reset();
        PeriodList.SetFilter(period, GLPeriod.Substring(5, 2));
        if PeriodList.FindFirst() then begin
            ReturnDate := PeriodList.year + '-' + PeriodList.md.Substring(1, 2) + '-' + PeriodList.md.Substring(3, 2);
            Evaluate(FPDateEnd, ReturnDate);
        end;
        exit(FPDateEnd);
    end;
}
