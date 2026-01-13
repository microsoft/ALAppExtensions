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
        IsCalendarYear: Boolean;

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
        FiscalYear: Integer;
        RequestedPeriod: Integer;
        EndDate: Date;
    begin
        if SLPeriodListWorkTable.IsEmpty() then
            InitializePeriodWorkTable();
        if not Evaluate(FiscalYear, GLPeriod.Substring(1, 4)) then
            exit(0D);
        if not Evaluate(RequestedPeriod, GLPeriod.Substring(5, 2)) then
            exit(0D);
        AssignCalendarYearsToPeriods(FiscalYear);
        EndDate := GetPeriodEndDate(RequestedPeriod);
        exit(EndDate);
    end;

    internal procedure InitializePeriodWorkTable()
    var
        SLPeriodListWorkTable: Record "SL Period List Work Table";
        PeriodCounter: Integer;
        MonthOneTxt: Label '01', Locked = true;
    begin
        SLPeriodListWorkTable.DeleteAll();

        for PeriodCounter := 1 to NumberOfPeriods do begin
            Clear(SLPeriodListWorkTable);
            SLPeriodListWorkTable.Period := PeriodCounter;
            SLPeriodListWorkTable.MonthDay := GetFiscalPeriodEndDate(PeriodCounter);
            if PeriodCounter = 1 then
                if SLPeriodListWorkTable.MonthDay.Substring(1, 2) = MonthOneTxt then
                    IsCalendarYear := true;
            SLPeriodListWorkTable.Insert();
        end;
    end;

    internal procedure GetFiscalPeriodEndDate(PeriodNumber: Integer): Text[4]
    begin
        case PeriodNumber of
            1:
                exit(SLGLSetup.FiscalPerEnd00);
            2:
                exit(SLGLSetup.FiscalPerEnd01);
            3:
                exit(SLGLSetup.FiscalPerEnd02);
            4:
                exit(SLGLSetup.FiscalPerEnd03);
            5:
                exit(SLGLSetup.FiscalPerEnd04);
            6:
                exit(SLGLSetup.FiscalPerEnd05);
            7:
                exit(SLGLSetup.FiscalPerEnd06);
            8:
                exit(SLGLSetup.FiscalPerEnd07);
            9:
                exit(SLGLSetup.FiscalPerEnd08);
            10:
                exit(SLGLSetup.FiscalPerEnd09);
            11:
                exit(SLGLSetup.FiscalPerEnd10);
            12:
                exit(SLGLSetup.FiscalPerEnd11);
            13:
                exit(SLGLSetup.FiscalPerEnd12);
            else
                exit('');
        end;
    end;

    internal procedure AssignCalendarYearsToPeriods(FiscalYear: Integer)
    var
        SLPeriodListWorkTable: Record "SL Period List Work Table";
        PeriodOfMaxMD: Integer;
    begin
        PeriodOfMaxMD := GetPeriodWithLatestMonthDay();
        SLPeriodListWorkTable.Reset();
        if SLPeriodListWorkTable.FindSet() then
            repeat
                SLPeriodListWorkTable.year := Format(GetCalendarYearForPeriod(SLPeriodListWorkTable.Period, PeriodOfMaxMD, FiscalYear));
                SLPeriodListWorkTable.Modify();
            until SLPeriodListWorkTable.Next() = 0;
    end;

    internal procedure GetPeriodWithLatestMonthDay(): Integer
    var
        SLPeriodListWorkTable: Record "SL Period List Work Table";
    begin
        SLPeriodListWorkTable.Reset();
        SLPeriodListWorkTable.SetCurrentKey(MonthDay);
        if SLPeriodListWorkTable.FindLast() then
            exit(SLPeriodListWorkTable.Period);

        exit(0);
    end;

    internal procedure GetCalendarYearForPeriod(PeriodNumber: Integer; PeriodOfMaxMD: Integer; FiscalYear: Integer): Integer
    begin
        if IsCalendarYear then
            exit(FiscalYear);

        if PeriodNumber <= PeriodOfMaxMD then begin
            if BeginFiscalYear = 1 then
                exit(FiscalYear)
            else
                exit(FiscalYear - 1);
        end else
            if BeginFiscalYear = 1 then
                exit(FiscalYear + 1)
            else
                exit(FiscalYear);
    end;

    internal procedure GetPeriodEndDate(RequestedPeriod: Integer): Date
    var
        SLPeriodListWorkTable: Record "SL Period List Work Table";
        DateText: Text[10];
        EndDate: Date;
    begin
        SLPeriodListWorkTable.Reset();
        SLPeriodListWorkTable.SetRange(Period, RequestedPeriod);
        if SLPeriodListWorkTable.FindFirst() then begin
            DateText := SLPeriodListWorkTable.year + '-' +
                       SLPeriodListWorkTable.MonthDay.Substring(1, 2) + '-' +
                       SLPeriodListWorkTable.MonthDay.Substring(3, 2);

            if Evaluate(EndDate, DateText) then
                exit(EndDate);
        end;
        exit(0D);
    end;
}
