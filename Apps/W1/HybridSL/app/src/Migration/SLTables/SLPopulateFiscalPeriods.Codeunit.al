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
        NumberOfPeriods: Integer;
        BeginFiscalYear: Integer;

    internal procedure CreateSLFiscalPeriodsFromGLSetup()
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
        YearLength: Integer;
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
        FiscalPeriod: Text[6];
    begin
        YearLength := 4;

        SLGLSetup.Reset();
        if SLGLSetup.FindFirst() then begin
            Evaluate(CurFiscalYear, CopyStr(SLGLSetup.PerNbr, 1, YearLength));
            Evaluate(PrevFiscalYear, CopyStr(SLGLSetup.PerNbr, 1, YearLength));
            PrevFiscalYear := PrevFiscalYear - 1;
            NumberOfPeriods := SLGLSetup.NbrPer;
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
            while Index <= NumberOfPeriods do begin
                case Index of
                    1:
                        begin
                            FiscalPeriod := Format(IndexYear) + '01';
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(FiscalPeriod);
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(FiscalPeriod);
                            SLFiscalPeriods.PeriodID := 01;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    2:
                        begin
                            FiscalPeriod := Format(IndexYear) + '02';
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(FiscalPeriod);
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(FiscalPeriod);
                            SLFiscalPeriods.PeriodID := 02;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    3:
                        begin
                            FiscalPeriod := Format(IndexYear) + '03';
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(FiscalPeriod);
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(FiscalPeriod);
                            SLFiscalPeriods.PeriodID := 03;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    4:
                        begin
                            FiscalPeriod := Format(IndexYear) + '04';
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(FiscalPeriod);
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(FiscalPeriod);
                            SLFiscalPeriods.PeriodID := 04;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    5:
                        begin
                            FiscalPeriod := Format(IndexYear) + '05';
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(FiscalPeriod);
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(FiscalPeriod);
                            SLFiscalPeriods.PeriodID := 05;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    6:
                        begin
                            FiscalPeriod := Format(IndexYear) + '06';
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(FiscalPeriod);
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(FiscalPeriod);
                            SLFiscalPeriods.PeriodID := 06;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    7:
                        begin
                            FiscalPeriod := Format(IndexYear) + '07';
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(FiscalPeriod);
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(FiscalPeriod);
                            SLFiscalPeriods.PeriodID := 07;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    8:
                        begin
                            FiscalPeriod := Format(IndexYear) + '08';
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(FiscalPeriod);
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(FiscalPeriod);
                            SLFiscalPeriods.PeriodID := 08;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    9:
                        begin
                            FiscalPeriod := Format(IndexYear) + '09';
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(FiscalPeriod);
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(FiscalPeriod);
                            SLFiscalPeriods.PeriodID := 09;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    10:
                        begin
                            FiscalPeriod := Format(IndexYear) + '10';
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(FiscalPeriod);
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(FiscalPeriod);
                            SLFiscalPeriods.PeriodID := 10;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    11:
                        begin
                            FiscalPeriod := Format(IndexYear) + '11';
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(FiscalPeriod);
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(FiscalPeriod);
                            SLFiscalPeriods.PeriodID := 11;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    12:
                        begin
                            FiscalPeriod := Format(IndexYear) + '12';
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(FiscalPeriod);
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(FiscalPeriod);
                            SLFiscalPeriods.PeriodID := 12;
                            SLFiscalPeriods.Year1 := IndexYear;
                            SLFiscalPeriods.PeriodDT := FPDateBeg;
                            SLFiscalPeriods.PerEndDT := FPDateEnd;
                            SLFiscalPeriods.Insert();
                        end;
                    13:
                        begin
                            FiscalPeriod := Format(IndexYear) + '13';
                            FPDateEnd := GetCalendarEndDateOfGLPeriod(FiscalPeriod);
                            FPDateBeg := GetCalendarBegDateOfGLPeriod(FiscalPeriod);
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

    internal procedure GetPeriodStartDateFromEndDate(EndDate: Date): Date
    var
        StartDate: Date;
        DateExpression: Text[30];
    begin
        DateExpression := '<-1M+1D>';
        StartDate := CalcDate(DateExpression, EndDate);
        Message(DateExpression, EndDate, StartDate);
        exit(StartDate)
    end;

    internal procedure GetCalendarBegDateOfGLPeriod(GLPeriod: Text[6]): Date
    var
        CurrentPeriodBeginDate: Date;
        PreviousPeriodEndDate: Date;
        CurrentPeriodYear: Integer;
        PreviousFiscalYear: Integer;
        PreviousMonth: Integer;
        CurrentMonth: Integer;
        CurrentFiscalMonthTxt: Text[2];
        NumberOfPeriodsTxt: Text[2];
        PreviousFiscalMonthTxt: Text[2];
        PreviousFiscalPeriod: Text[6];
        DateExpression: Text[30];
    begin
        Evaluate(CurrentPeriodYear, GLPeriod.Substring(1, 4));
        PreviousFiscalYear := CurrentPeriodYear - 1;
        CurrentFiscalMonthTxt := GLPeriod.Substring(5, 2);
        NumberOfPeriodsTxt := Format(NumberOfPeriods);
        DateExpression := '<+1D>';

        if CurrentFiscalMonthTxt = '01' then begin
            if NumberOfPeriods <= 9 then
                PreviousFiscalMonthTxt := '0' + Format(NumberOfPeriods)
            else
                PreviousFiscalMonthTxt := Format(NumberOfPeriods);
            PreviousFiscalPeriod := Format(PreviousFiscalYear) + PreviousFiscalMonthTxt;
        end else begin
            Evaluate(CurrentMonth, CurrentFiscalMonthTxt);
            PreviousMonth := CurrentMonth - 1;
            if PreviousMonth <= 9 then
                PreviousFiscalMonthTxt := '0' + Format(PreviousMonth)
            else
                PreviousFiscalMonthTxt := Format(PreviousMonth);
            PreviousFiscalPeriod := Format(CurrentPeriodYear) + PreviousFiscalMonthTxt;
        end;

        PreviousPeriodEndDate := GetCalendarEndDateOfGLPeriod(PreviousFiscalPeriod);
        CurrentPeriodBeginDate := CalcDate(DateExpression, PreviousPeriodEndDate);
        exit(CurrentPeriodBeginDate);
    end;

    internal procedure GetCalendarEndDateOfGLPeriod(GLPeriod: Text[6]): Date
    var
        SLPeriodListWorkTable: Record "SL Period List Work Table";
        FPDateEnd: Date;
        PeriodCounter: Integer;
        FiscalYear: Integer;
        PeriodOfMaxMD: Integer;
        MaxMonthDay: Text[4];
        ReturnDate: Text[10];
    begin
        PeriodCounter := 1;
        if not SLPeriodListWorkTable.FindFirst() then
            while PeriodCounter <= NumberOfPeriods do begin
                SLPeriodListWorkTable.Period := PeriodCounter;
                case PeriodCounter of
                    1:
                        SLPeriodListWorkTable.MonthDay := SLGLSetup.FiscalPerEnd00;
                    2:
                        SLPeriodListWorkTable.MonthDay := SLGLSetup.FiscalPerEnd01;
                    3:
                        SLPeriodListWorkTable.MonthDay := SLGLSetup.FiscalPerEnd02;
                    4:
                        SLPeriodListWorkTable.MonthDay := SLGLSetup.FiscalPerEnd03;
                    5:
                        SLPeriodListWorkTable.MonthDay := SLGLSetup.FiscalPerEnd04;
                    6:
                        SLPeriodListWorkTable.MonthDay := SLGLSetup.FiscalPerEnd05;
                    7:
                        SLPeriodListWorkTable.MonthDay := SLGLSetup.FiscalPerEnd06;
                    8:
                        SLPeriodListWorkTable.MonthDay := SLGLSetup.FiscalPerEnd07;
                    9:
                        SLPeriodListWorkTable.MonthDay := SLGLSetup.FiscalPerEnd08;
                    10:
                        SLPeriodListWorkTable.MonthDay := SLGLSetup.FiscalPerEnd09;
                    11:
                        SLPeriodListWorkTable.MonthDay := SLGLSetup.FiscalPerEnd10;
                    12:
                        SLPeriodListWorkTable.MonthDay := SLGLSetup.FiscalPerEnd11;
                    else
                        SLPeriodListWorkTable.MonthDay := SLGLSetup.FiscalPerEnd12;
                end;

                SLPeriodListWorkTable.Insert();
                Commit();
                PeriodCounter += 1;
            end;

        Evaluate(FiscalYear, GLPeriod.Substring(1, 4));

        SLPeriodListWorkTable.Reset();
        SLPeriodListWorkTable.SetCurrentKey(MonthDay);
        if SLPeriodListWorkTable.Find('+') then begin
            MaxMonthDay := SLPeriodListWorkTable.MonthDay;
            PeriodOfMaxMD := SLPeriodListWorkTable.Period;
        end;

        SLPeriodListWorkTable.Reset();
        if SLPeriodListWorkTable.FindSet() then
            repeat
                if SLPeriodListWorkTable.Period <= PeriodOfMaxMD then begin
                    if BeginFiscalYear = 1 then
                        SLPeriodListWorkTable.year := Format(FiscalYear)
                    else
                        SLPeriodListWorkTable.year := Format(FiscalYear - 1);
                end else
                    if BeginFiscalYear = 1 then
                        SLPeriodListWorkTable.year := Format(FiscalYear + 1)
                    else
                        SLPeriodListWorkTable.year := Format(FiscalYear);
                SLPeriodListWorkTable.Modify();
                Commit();
            until SLPeriodListWorkTable.Next() = 0;

        SLPeriodListWorkTable.Reset();
        SLPeriodListWorkTable.SetFilter(Period, GLPeriod.Substring(5, 2));
        if SLPeriodListWorkTable.FindFirst() then begin
            ReturnDate := SLPeriodListWorkTable.year + '-' + SLPeriodListWorkTable.MonthDay.Substring(1, 2) + '-' + SLPeriodListWorkTable.MonthDay.Substring(3, 2);
            Evaluate(FPDateEnd, ReturnDate);
        end;
        exit(FPDateEnd);
    end;
}
