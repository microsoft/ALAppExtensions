// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Setup;
using Microsoft.FixedAssets.Ledger;

report 18631 "Calculate FA Depreciation"
{
    AdditionalSearchTerms = 'write down fixed asset';
    ApplicationArea = FixedAssets;
    Caption = 'Calculate Depreciation Report';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Fixed Asset"; "Fixed Asset")
        {
            RequestFilterFields = "No.", "FA Class Code", "FA Block Code", "FA Subclass Code", "Budgeted Asset";

            trigger OnAfterGetRecord()
            begin
                if Inactive or Blocked then
                    CurrReport.Skip();

                if not CalculateFAShifts() then begin
                    CalculateDepr.Calculate(
                      DeprAmount, Custom1Amount, NumberOfDays, Custom1NumberOfDays,
                      "No.", DeprBookCode, DeprUntilDate, EntryAmounts, 0D, DaysInPeriod);
                    InsertTempJournal(0);
                end;

                if (DeprAmount <> 0) or (Custom1Amount <> 0) then
                    Window.Update(1, "No.")
                else
                    Window.Update(2, "No.");

                OnAfterCalculateDepreciation(
                  "No.", TempGenJnlLine, TempFAJnlLine, DeprAmount, NumberOfDays, DeprBookCode, DeprUntilDate, EntryAmounts, DaysInPeriod);
            end;

            trigger OnPostDataItem()
            var
                NoSeries: Code[20];
                FAJnlNextLineNo: Integer;
                GenJnlNextLineNo: Integer;
                LineNo: Integer;
            begin
                if TempFAJnlLine.FindFirst() then begin
                    LockTable();
                    FAJnlSetup.FAJnlName(DeprBook, FAJnlLine, FAJnlNextLineNo);
                    NoSeries := FAJnlSetup.GetFANoSeries(FAJnlLine);
                    if DocumentNo = '' then
                        DocumentNo2 := FAJnlSetup.GetFAJnlDocumentNo(FAJnlLine, DeprUntilDate, true)
                    else
                        DocumentNo2 := DocumentNo;
                end;

                if TempFAJnlLine.FindSet() then
                    repeat
                        LineNo := LineNo + 1;
                        Window.Update(3, LineNo);

                        FAJnlNextLineNo := FAJnlNextLineNo + 10000;

                        FAJnlLine.Init();
                        FAJnlLine."Line No." := FAJnlNextLineNo;
                        FAJnlSetup.SetFAJnlTrailCodes(FAJnlLine);
                        FAJnlLine."Posting Date" := PostingDate;
                        FAJnlLine."FA Posting Date" := DeprUntilDate;
                        if FAJnlLine."Posting Date" = FAJnlLine."FA Posting Date" then
                            FAJnlLine."Posting Date" := 0D;

                        FAJnlLine."FA Posting Type" := TempFAJnlLine."FA Posting Type";
                        FAJnlLine.Validate("FA No.", TempFAJnlLine."FA No.");
                        FAJnlLine."Document No." := DocumentNo2;
                        FAJnlLine."Posting No. Series" := NoSeries;
                        FAJnlLine.Description := PostingDescription;
                        FAJnlLine.Validate("Depreciation Book Code", DeprBookCode);
                        FAJnlLine.Validate(Amount, TempFAJnlLine.Amount);
                        FAJnlLine."No. of Depreciation Days" := TempFAJnlLine."No. of Depreciation Days";
                        FAJnlLine."FA Error Entry No." := TempFAJnlLine."FA Error Entry No.";
                        FAJnlLine."FA Shift Line No." := TempFAJnlLine."FA Shift Line No.";
                        FAJnlLine."Shift Type" := TempFAJnlLine."Shift Type";
                        FAJnlLine."Industry Type" := TempFAJnlLine."Industry Type";
                        FAJnlLine."No. of Days for Shift" := TempFAJnlLine."No. of Days for Shift";

                        OnBeforeFAJnlLineInsert(TempFAJnlLine, FAJnlLine);
                        FAJnlLine.Insert(true);

                        FAJnlLineCreatedCount += 1;
                    until TempFAJnlLine.Next() = 0;

                if TempGenJnlLine.FindFirst() then begin
                    GenJnlLine.LockTable();
                    FAJnlSetup.GenJnlName(DeprBook, GenJnlLine, GenJnlNextLineNo);
                    NoSeries := FAJnlSetup.GetGenNoSeries(GenJnlLine);
                    if DocumentNo = '' then
                        DocumentNo2 := FAJnlSetup.GetGenJnlDocumentNo(GenJnlLine, DeprUntilDate, true)
                    else
                        DocumentNo2 := DocumentNo;
                end;

                if TempGenJnlLine.FindSet() then
                    repeat
                        LineNo := LineNo + 1;
                        Window.Update(3, LineNo);

                        GenJnlNextLineNo := GenJnlNextLineNo + 1000;

                        GenJnlLine.Init();
                        GenJnlLine."Line No." := GenJnlNextLineNo;
                        FAJnlSetup.SetGenJnlTrailCodes(GenJnlLine);
                        GenJnlLine."Posting Date" := PostingDate;
                        GenJnlLine."FA Posting Date" := DeprUntilDate;
                        if GenJnlLine."Posting Date" = GenJnlLine."FA Posting Date" then
                            GenJnlLine."FA Posting Date" := 0D;

                        GenJnlLine."FA Posting Type" := TempGenJnlLine."FA Posting Type";
                        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"Fixed Asset";
                        GenJnlLine.Validate("Account No.", TempGenJnlLine."Account No.");
                        GenJnlLine.Description := PostingDescription;
                        GenJnlLine."Document No." := DocumentNo2;
                        GenJnlLine."Posting No. Series" := NoSeries;
                        GenJnlLine.Validate("Depreciation Book Code", DeprBookCode);
                        GenJnlLine.Validate(Amount, TempGenJnlLine.Amount);
                        GenJnlLine."No. of Depreciation Days" := TempGenJnlLine."No. of Depreciation Days";
                        GenJnlLine."FA Error Entry No." := TempGenJnlLine."FA Error Entry No.";
                        GenJnlLine."FA Shift Line No." := TempGenJnlLine."FA Shift Line No.";
                        GenJnlLine."Shift Type" := TempGenJnlLine."Shift Type";
                        GenJnlLine."Industry Type" := TempGenJnlLine."Industry Type";
                        GenJnlLine."No. of Days for Shift" := TempGenJnlLine."No. of Days for Shift";

                        OnBeforeGenJnlLineInsert(TempGenJnlLine, GenJnlLine);
                        GenJnlLine.Insert(true);

                        GenJnlLineCreatedCount += 1;
                        if BalAccount then
                            FAInsertGLAcc.GetBalAcc(GenJnlLine, GenJnlNextLineNo);

                    until TempGenJnlLine.Next() = 0;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DepreciationBook; DeprBookCode)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Depreciation Book';
                        TableRelation = "Depreciation Book";
                        ToolTip = 'Specifies the code for the depreciation book to be included in the report or batch job.';
                    }
                    field(FAPostingDate; DeprUntilDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'FA Posting Date';
                        Importance = Additional;
                        ToolTip = 'Specifies the fixed asset posting date to be used by the batch job. The batch job includes ledger entries up to this date. This date appears in the FA Posting Date field in the resulting journal lines. if the Use Same FA+G/L Posting Dates field has been activated in the depreciation book that is used in the batch job, then this date must be the same as the posting date entered in the Posting Date field.';

                        trigger OnValidate()
                        begin
                            DeprUntilDateModified := true;
                        end;
                    }
                    field(UseForceDaysInNo; UseForceNoOfDays)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Use Force No. of Days';
                        Importance = Additional;
                        ToolTip = 'Specifies if you want the program to use the number of days, as specified in the field below, in the depreciation calculation.';

                        trigger OnValidate()
                        begin
                            if not UseForceNoOfDays then
                                DaysInPeriod := 0;
                        end;
                    }
                    field(ForceNoOfDays; DaysInPeriod)
                    {
                        ApplicationArea = FixedAssets;
                        BlankZero = true;
                        Caption = 'Force No. of Days';
                        Importance = Additional;
                        MinValue = 0;
                        ToolTip = 'Specifies if you want the program to use the number of days, as specified in the field below, in the depreciation calculation.';

                        trigger OnValidate()
                        begin
                            if not UseForceNoOfDays and (DaysInPeriod <> 0) then
                                Error(UseForceNoOfDaysErr);
                        end;
                    }
                    field(DeprPostingDate; PostingDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the posting date to be used by the batch job.';

                        trigger OnValidate()
                        begin
                            if not DeprUntilDateModified then
                                DeprUntilDate := PostingDate;
                        end;
                    }
                    field(DeprDocumentNo; DocumentNo)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies, if you leave the field empty, the next available number on the resulting journal line. if a number series is not set up, enter the document number that you want assigned to the resulting journal line.';
                    }
                    field(DeprPostingDescription; PostingDescription)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Posting Description';
                        ToolTip = 'Specifies the posting date to be used by the batch job as a filter.';
                    }
                    field(InsertBalAccount; BalAccount)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Insert Bal. Account';
                        Importance = Additional;
                        ToolTip = 'Specifies if you want the batch job to automatically insert fixed asset entries with balancing accounts.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            BalAccount := true;
            PostingDate := WorkDate();
            DeprUntilDate := WorkDate();
            if DeprBookCode = '' then begin
                FASetup.Get();
                DeprBookCode := FASetup."Default Depr. Book";
            end;
        end;

        trigger OnClosePage()
        begin
            OnAfterCloseRequestPage(DeprUntilDate, PostingDate);
        end;
    }

    trigger OnPostReport()
    var
        PageGenJnlLine: Record "Gen. Journal Line";
        PageFAJnlLine: Record "FA Journal Line";
    begin
        Window.Close();
        if (FAJnlLineCreatedCount = 0) and (GenJnlLineCreatedCount = 0) then begin
            Message(CompletionStatsMsg);
            exit;
        end;

        if FAJnlLineCreatedCount > 0 then
            if Confirm(CompletionStatsFAJnlQst, true, FAJnlLineCreatedCount) then begin
                PageFAJnlLine.SetRange("Journal Template Name", FAJnlLine."Journal Template Name");
                PageFAJnlLine.SetRange("Journal Batch Name", FAJnlLine."Journal Batch Name");
                if not PageFAJnlLine.IsEmpty() then
                    Page.Run(Page::"Fixed Asset Journal", PageFAJnlLine);
            end;

        if GenJnlLineCreatedCount > 0 then
            if Confirm(CompletionStatsGenJnlQst, true, GenJnlLineCreatedCount) then begin
                PageGenJnlLine.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
                PageGenJnlLine.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
                if not PageGenJnlLine.IsEmpty() then
                    Page.Run(Page::"Fixed Asset G/L Journal", PageGenJnlLine);
            end;
    end;

    trigger OnPreReport()
    begin
        DeprBook.Get(DeprBookCode);
        if DeprUntilDate = 0D then
            Error(FieldErr, FAJnlLine.FieldCaption("FA Posting Date"));

        if PostingDate = 0D then
            PostingDate := DeprUntilDate;

        if UseForceNoOfDays and (DaysInPeriod = 0) then
            Error(ForceNoOfDaysErr);

        if DeprBook."Use Same FA+G/L Posting Dates" and (DeprUntilDate <> PostingDate) then
            Error(
              FieldIdentificationErr,
              FAJnlLine.FieldCaption("FA Posting Date"),
              FAJnlLine.FieldCaption("Posting Date"),
              DeprBook.FieldCaption("Use Same FA+G/L Posting Dates"),
              false,
              DeprBook.TableCaption,
              DeprBook.FieldCaption(Code),
              DeprBook.Code);

        Window.Open(
          DeprFAMsg +
          NonDeprFAMsg +
          InsertJnlLinesMsg);
    end;

    var
        GenJnlLine: Record "Gen. Journal Line";
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
        FASetup: Record "FA Setup";
        FAJnlLine: Record "FA Journal Line";
        TempFAJnlLine: Record "FA Journal Line" temporary;
        DeprBook: Record "Depreciation Book";
        FixedAssetShiftJrnlLine: Record "Fixed Asset Shift";
        FAJnlSetup: Record "FA Journal Setup";
        CalculateDepr: Codeunit "Calculate Depreciation";
        FAInsertGLAcc: Codeunit "FA Insert G/L Account";
        Window: Dialog;
        DeprAmount: Decimal;
        Custom1Amount: Decimal;
        NumberOfDays: Integer;
        Custom1NumberOfDays: Integer;
        DeprUntilDate: Date;
        UseForceNoOfDays: Boolean;
        DaysInPeriod: Integer;
        PostingDate: Date;
        DocumentNo: Code[20];
        DocumentNo2: Code[20];
        PostingDescription: Text[100];
        DeprBookCode: Code[10];
        BalAccount: Boolean;
        FAJnlLineCreatedCount: Integer;
        GenJnlLineCreatedCount: Integer;
        EntryAmounts: array[4] of Decimal;
        DeprUntilDateModified: Boolean;
        FieldErr: Label 'You must specify %1.', Comment = '%1 = field caption';
        ForceNoOfDaysErr: Label 'Force No. of Days must be activated.';
        FieldIdentificationErr: Label '%1 and %2 must be identical. %3 must be %4 in %5 %6 = %7.',
            Comment = '%1= date, %2= date, %3= date, %4= boolean, %5= table caption, %6= field caption, %7= code';
        DeprFAMsg: Label 'Depreciating fixed asset      #1##########\', Comment = '%1= fixed asset no';
        NonDeprFAMsg: Label 'Not depreciating fixed asset  #2##########\', Comment = '%1= fixed asset no';
        InsertJnlLinesMsg: Label 'Inserting journal lines       #3##########', Comment = '%1= line no';
        UseForceNoOfDaysErr: Label 'Use Force No. of Days must be activated.';
        NoOfDaysNonSeasonalErr: Label 'Define %1 in %2 in the %3.', Comment = '%1= integer, %2= field caption, %3= table caption';
        FAShiftFieldErr: Label '%1 %2 should not be defined for %3 %4 for asset %5.',
            Comment = '%1= shift type, %2= shift type, %3= field caption, %4= industry type, %5= FA No';
        CompletionStatsMsg: Label 'The depreciation has been calculated.\\No journal lines were created.';
        CompletionStatsFAJnlQst: Label 'The depreciation has been calculated.\\%1 fixed asset journal lines were created.\\Do you want to open the Fixed Asset Journal window?', Comment = '%1= interger';
        CompletionStatsGenJnlQst: Label 'The depreciation has been calculated.\\%1 fixed asset G/L journal lines were created.\\Do you want to open the Fixed Asset G/L Journal window?', Comment = '%1= interger';

    procedure FADepreciationDate(FADepreciationDate: Date): Date
    begin
        exit(DeprUntilDate);
    end;

    local procedure CalculateFAShifts(): Boolean
    var
        FixedAssetShift: Record "Fixed Asset Shift";
        FALedgEntry: Record "FA Ledger Entry";
        DepreciationCalc: Codeunit "Depreciation Calculation";
        FADateCalcSubcriber: Codeunit "Fixed Asset Date Calculation";
        WrknDays: Integer;
        TotalDeprAmt: Decimal;
        SkipItteration: Boolean;
        NonSeasonal: Boolean;
        Seasonal: Boolean;
        LastDeprDate: Date;
        StartingDate: Date;
        EndingDate: Date;
    begin
        WrknDays := 0;
        SkipItteration := false;
        DeprBook.Get(DeprBookCode);
        if DeprBook."FA Book Type" = DeprBook."FA Book Type"::"Income Tax" then
            exit(false);

        FALedgEntry.Reset();
        FALedgEntry.SetCurrentKey("FA No.", "Depreciation Book Code", "FA Posting Date");
        FALedgEntry.SetRange("FA No.", "Fixed Asset"."No.");
        FALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type"::Depreciation);
        FALedgEntry.SetRange("Depreciation Book Code", DeprBookCode);
        if FALedgEntry.FindLast() then
            LastDeprDate := FALedgEntry."FA Posting Date";

        if LastDeprDate <> 0D then
            LastDeprDate := LastDeprDate + 1;

        StartingDate := FADateCalcSubcriber.GetFiscalYearStartDate(DeprUntilDate);
        EndingDate := FADateCalcSubcriber.GetFiscalYearendDate(DeprUntilDate);
        if LastDeprDate < StartingDate then
            StartingDate := LastDeprDate;

        FixedAssetShift.Reset();
        FixedAssetShift.SetCurrentKey("Industry Type", "FA No.", "Depreciation Book Code");
        FixedAssetShift.SetRange("FA No.", "Fixed Asset"."No.");
        FixedAssetShift.SetRange("Depreciation Book Code", DeprBookCode);
        FixedAssetShift.SetFilter("Depreciation Starting Date", '>=%1', StartingDate);
        FixedAssetShift.SetFilter("Depreciation ending Date", '<=%1', EndingDate);
        if FixedAssetShift.FindSet() then
            repeat
                FixedAssetShift.TestField("Depreciation ending Date");
                if (FixedAssetShift."Shift Type" = FixedAssetShift."Shift Type"::Single) and
                    (FixedAssetShift."Industry Type" <> FixedAssetShift."Industry Type"::Normal)
                then
                    Error(FAShiftFieldErr,
                        FixedAssetShift.FieldCaption("Shift Type"),
                        FixedAssetShift."Shift Type",
                        FixedAssetShift.FieldCaption("Industry Type"),
                        FixedAssetShift."Industry Type",
                        FixedAssetShift."FA No.");

                if (FixedAssetShift."Shift Type" <> FixedAssetShift."Shift Type"::Single) and (FixedAssetShift."Industry Type" = FixedAssetShift."Industry Type"::Normal) then
                    Error(FAShiftFieldErr,
                        FixedAssetShift.FieldCaption("Shift Type"),
                        FixedAssetShift."Shift Type",
                        FixedAssetShift.FieldCaption("Industry Type"),
                        FixedAssetShift."Industry Type", FixedAssetShift."FA No.");

                if DeprUntilDate >= FixedAssetShift."Depreciation ending Date" then begin
                    if FixedAssetShift."Depreciation Method" in
                       [FixedAssetShift."Depreciation Method"::"Straight-Line",
                       FixedAssetShift."Depreciation Method"::"DB1/SL",
                       FixedAssetShift."Depreciation Method"::"DB2/SL"] then
                        FixedAssetShift.TestField("Straight-Line %");

                    if FixedAssetShift."Depreciation Method" in
                       [FixedAssetShift."Depreciation Method"::"Declining-Balance 1",
                       FixedAssetShift."Depreciation Method"::"Declining-Balance 2",
                       FixedAssetShift."Depreciation Method"::"DB1/SL",
                       FixedAssetShift."Depreciation Method"::"DB2/SL"] then
                        FixedAssetShift.TestField("Declining-Balance %");

                    if FixedAssetShift."Line No." > 0 then begin
                        FixedAssetShift."Calculate FA Depreciation" := true;
                        FixedAssetShift.Modify();
                    end;

                    CalculateDepr.Calculate(
                        DeprAmount,
                        Custom1Amount,
                        NumberOfDays,
                        Custom1NumberOfDays,
                        "Fixed Asset"."No.",
                        DeprBookCode,
                        FixedAssetShift."Depreciation ending Date",
                        EntryAmounts,
                        0D,
                        FixedAssetShift."Used No. of Days");

                    FixedAssetShift.CalcFields("Book Value");
                    TotalDeprAmt += -DeprAmount;
                    if TotalDeprAmt > FixedAssetShift."Book Value" then begin
                        DeprAmount := -(FixedAssetShift."Book Value" - (TotalDeprAmt + DeprAmount));
                        SkipItteration := true;
                    end;

                    FixedAssetShiftJrnlLine := FixedAssetShift;

                    FixedAssetShift."Calculate FA Depreciation" := false;
                    FixedAssetShift.Modify();

                    InsertTempJournal(FixedAssetShift."Line No.");
                    if FixedAssetShift."Used No. of Days" <> 0 then
                        WrknDays += FixedAssetShift."Used No. of Days"
                    else
                        WrknDays += DepreciationCalc.DeprDays(
                            FixedAssetShift."Depreciation Starting Date",
                            FixedAssetShift."Depreciation ending Date",
                            DeprBook."Fiscal Year 365 Days");

                    if FixedAssetShift."Industry Type" = FixedAssetShift."Industry Type"::"Non Seasonal" then
                        NonSeasonal := true;

                    if FixedAssetShift."Industry Type" = FixedAssetShift."Industry Type"::Seasonal then
                        Seasonal := true;
                end;
            until (FixedAssetShift.Next() = 0) or SkipItteration
        else
            exit(false);

        if (WrknDays > DeprBook."No. of Days Non Seasonal") and NonSeasonal then
            Error(NoOfDaysNonSeasonalErr, WrknDays, DeprBook.FieldCaption("No. of Days Non Seasonal"), DeprBook.TableCaption);

        if (WrknDays > DeprBook."No. of Days Seasonal") and Seasonal then
            Error(NoOfDaysNonSeasonalErr, WrknDays, DeprBook.FieldCaption("No. of Days Seasonal"), DeprBook.TableCaption);

        exit(true);
    end;

    local procedure InsertTempJournal(FAShiftLineNo: Integer)
    begin
        if Custom1Amount <> 0 then
            if not DeprBook."G/L Integration - Custom 1" or "Fixed Asset"."Budgeted Asset" then begin
                TempFAJnlLine."FA No." := "Fixed Asset"."No.";
                TempFAJnlLine."FA Posting Type" := TempFAJnlLine."FA Posting Type"::"Custom 1";
                TempFAJnlLine.Amount := Custom1Amount;
                TempFAJnlLine."No. of Depreciation Days" := Custom1NumberOfDays;
                TempFAJnlLine."Line No." := TempFAJnlLine."Line No." + 1;
                TempFAJnlLine."FA Shift Line No." := FAShiftLineNo;
                TempFAJnlLine."Shift Type" := FixedAssetShiftJrnlLine."Shift Type";
                TempFAJnlLine."Industry Type" := FixedAssetShiftJrnlLine."Industry Type";
                if TempFAJnlLine."Industry Type" = TempFAJnlLine."Industry Type"::"Non Seasonal" then
                    TempFAJnlLine."No. of Days for Shift" := DeprBook."No. of Days Non Seasonal";

                if TempFAJnlLine."Industry Type" = TempFAJnlLine."Industry Type"::Seasonal then
                    TempFAJnlLine."No. of Days for Shift" := DeprBook."No. of Days Seasonal";

                TempFAJnlLine.Insert();
            end else begin
                TempGenJnlLine."Account No." := "Fixed Asset"."No.";
                TempGenJnlLine."FA Posting Type" := TempGenJnlLine."FA Posting Type"::"Custom 1";
                TempGenJnlLine.Amount := Custom1Amount;
                TempGenJnlLine."No. of Depreciation Days" := Custom1NumberOfDays;
                TempGenJnlLine."Line No." := TempGenJnlLine."Line No." + 1;
                TempGenJnlLine."FA Shift Line No." := FAShiftLineNo;
                TempGenJnlLine."Shift Type" := FixedAssetShiftJrnlLine."Shift Type";
                TempGenJnlLine."Industry Type" := FixedAssetShiftJrnlLine."Industry Type";
                if TempGenJnlLine."Industry Type" = TempGenJnlLine."Industry Type"::"Non Seasonal" then
                    TempGenJnlLine."No. of Days for Shift" := DeprBook."No. of Days Non Seasonal";

                if TempGenJnlLine."Industry Type" = TempGenJnlLine."Industry Type"::Seasonal then
                    TempGenJnlLine."No. of Days for Shift" := DeprBook."No. of Days Seasonal";

                TempGenJnlLine.Insert();
            end;

        if DeprAmount <> 0 then
            if not DeprBook."G/L Integration - Depreciation" or "Fixed Asset"."Budgeted Asset" then begin
                TempFAJnlLine."FA No." := "Fixed Asset"."No.";
                TempFAJnlLine."FA Posting Type" := TempFAJnlLine."FA Posting Type"::Depreciation;
                TempFAJnlLine.Amount := DeprAmount;
                TempFAJnlLine."No. of Depreciation Days" := NumberOfDays;
                TempFAJnlLine."Line No." := TempFAJnlLine."Line No." + 1;
                TempFAJnlLine."FA Shift Line No." := FAShiftLineNo;
                TempFAJnlLine."Shift Type" := FixedAssetShiftJrnlLine."Shift Type";
                TempFAJnlLine."Industry Type" := FixedAssetShiftJrnlLine."Industry Type";
                if TempFAJnlLine."Industry Type" = TempFAJnlLine."Industry Type"::"Non Seasonal" then
                    TempFAJnlLine."No. of Days for Shift" := DeprBook."No. of Days Non Seasonal";

                if TempFAJnlLine."Industry Type" = TempFAJnlLine."Industry Type"::Seasonal then
                    TempFAJnlLine."No. of Days for Shift" := DeprBook."No. of Days Seasonal";

                TempFAJnlLine.Insert();
            end else begin
                TempGenJnlLine."Account No." := "Fixed Asset"."No.";
                TempGenJnlLine."FA Posting Type" := TempGenJnlLine."FA Posting Type"::Depreciation;
                TempGenJnlLine.Amount := DeprAmount;
                TempGenJnlLine."No. of Depreciation Days" := NumberOfDays;
                TempGenJnlLine."Line No." := TempGenJnlLine."Line No." + 1;
                TempGenJnlLine."FA Shift Line No." := FAShiftLineNo;
                TempGenJnlLine."Shift Type" := FixedAssetShiftJrnlLine."Shift Type";
                TempGenJnlLine."Industry Type" := FixedAssetShiftJrnlLine."Industry Type";
                if TempGenJnlLine."Industry Type" = TempGenJnlLine."Industry Type"::"Non Seasonal" then
                    TempGenJnlLine."No. of Days for Shift" := DeprBook."No. of Days Non Seasonal";

                if TempGenJnlLine."Industry Type" = TempGenJnlLine."Industry Type"::Seasonal then
                    TempGenJnlLine."No. of Days for Shift" := DeprBook."No. of Days Seasonal";

                TempGenJnlLine.Insert();
            end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCloseRequestPage(FAPostingDate: Date; PostingDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateDepreciation(
        FANo: Code[20];
        var TempGenJournalLine: Record "Gen. Journal Line" temporary;
        var TempFAJournalLine: Record "FA Journal Line" temporary;
        var DeprAmount: Decimal;
        var NumberOfDays: Integer;
        DeprBookCode: Code[10];
        DeprUntilDate: Date;
        EntryAmounts: array[4] of Decimal;
        DaysInPeriod: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFAJnlLineInsert(
        var TempFAJournalLine: Record "FA Journal Line" temporary;
        var FAJournalLine: Record "FA Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGenJnlLineInsert(
        var TempGenJournalLine: Record "Gen. Journal Line" temporary;
        var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;
}
