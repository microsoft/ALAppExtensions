// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Setup;

report 31240 "Calculate Depreciation CZF"
{
    AdditionalSearchTerms = 'write down fixed asset';
    ApplicationArea = FixedAssets;
    Caption = 'Calculate Depreciation';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Fixed Asset"; "Fixed Asset")
        {
            RequestFilterFields = "No.", "FA Class Code", "FA Subclass Code", "Budgeted Asset";

            trigger OnAfterGetRecord()
            var
                FADeprBook: Record "FA Depreciation Book";
            begin
                if Inactive or Blocked then
                    CurrReport.Skip();

                if not FADeprBook.Get("No.", DeprBookCode) then
                    CurrReport.Skip();
                if FADeprBook."Depreciation Starting Date" = 0D then
                    CurrReport.Skip();
                if (FADeprBook."Straight-Line %" = 0) and (FADeprBook."Fixed Depr. Amount" = 0) and
                   (FADeprBook."Declining-Balance %" = 0) and (FADeprBook."Depreciation Ending Date" = 0D) and
                   (FADeprBook."Tax Deprec. Group Code CZF" = '') and
                   (FADeprBook."Depreciation Method" = FADeprBook."Depreciation Method"::"Straight-Line")
                then
                    CurrReport.Skip();

                DepreciationInterrupted := FADeprBook."Deprec. Interrupted up to CZF" >= DeprUntilDate;

                OnBeforeCalculateDepreciation(
                    "No.", TempGenJournalLine, TempFAJournalLine, DeprAmount, NumberOfDays, DeprBookCode, DeprUntilDate, EntryAmounts, DaysInPeriod);

                CalculateDepreciation.Calculate(
                    DeprAmount, Custom1Amount, NumberOfDays, Custom1NumberOfDays, "No.", DeprBookCode, DeprUntilDate, EntryAmounts, 0D, DaysInPeriod);

                if (DeprAmount <> 0) or (Custom1Amount <> 0) then
                    WindowDialog.Update(1, "No.")
                else
                    WindowDialog.Update(2, "No.");

                Custom1Amount := round(Custom1Amount, GeneralLedgerSetup."Amount Rounding Precision");
                DeprAmount := round(DeprAmount, GeneralLedgerSetup."Amount Rounding Precision");

                OnAfterCalculateDepreciation(
                    "No.", TempGenJournalLine, TempFAJournalLine, DeprAmount, NumberOfDays, DeprBookCode, DeprUntilDate, EntryAmounts, DaysInPeriod);

                if Custom1Amount <> 0 then
                    if not DepreciationBook."G/L Integration - Custom 1" or "Budgeted Asset" then begin
                        TempFAJournalLine."FA No." := "No.";
                        TempFAJournalLine."FA Posting Type" := TempFAJournalLine."FA Posting Type"::"Custom 1";
                        TempFAJournalLine.Amount := Custom1Amount;
                        TempFAJournalLine."No. of Depreciation Days" := Custom1NumberOfDays;
                        TempFAJournalLine."Line No." += 1;
                        TempFAJournalLine.Insert();
                    end else begin
                        TempGenJournalLine."Account No." := "No.";
                        TempGenJournalLine."FA Posting Type" := TempGenJournalLine."FA Posting Type"::"Custom 1";
                        TempGenJournalLine.Amount := Custom1Amount;
                        TempGenJournalLine."No. of Depreciation Days" := Custom1NumberOfDays;
                        TempGenJournalLine."Line No." += 1;
                        TempGenJournalLine.Insert();
                    end;

                if DeprAmount <> 0 then
                    if not DepreciationBook."G/L Integration - Depreciation" or "Budgeted Asset" then begin
                        TempFAJournalLine."FA No." := "No.";
                        TempFAJournalLine."FA Posting Type" := TempFAJournalLine."FA Posting Type"::Depreciation;
                        TempFAJournalLine.Amount := DeprAmount;
                        if DepreciationInterrupted then
                            TempFAJournalLine.Amount := 0;
                        TempFAJournalLine."No. of Depreciation Days" := NumberOfDays;
                        TempFAJournalLine."Line No." += 1;
                        TempFAJournalLine.Insert();
                    end else begin
                        TempGenJournalLine."Account No." := "No.";
                        TempGenJournalLine."FA Posting Type" := TempGenJournalLine."FA Posting Type"::Depreciation;
                        TempGenJournalLine.Amount := DeprAmount;
                        if DepreciationInterrupted then
                            TempGenJournalLine.Amount := 0;
                        TempGenJournalLine."No. of Depreciation Days" := NumberOfDays;
                        TempGenJournalLine."Line No." += 1;
                        TempGenJournalLine.Insert();
                    end;
            end;

            trigger OnPostDataItem()
            begin
                if TempFAJournalLine.FindSet() then begin
                    FAJournalLine.LockTable();
                    FAJournalSetup.FAJnlName(DepreciationBook, FAJournalLine, FAJnlNextLineNo);
                    NoSeries := FAJournalSetup.GetFANoSeries(FAJournalLine);
                    if DocumentNo = '' then
                        if FAJournalLine.FindLast() then
                            DocumentNo2 := FAJournalLine."Document No."
                        else
                            DocumentNo2 := FAJournalSetup.GetFAJnlDocumentNo(FAJournalLine, DeprUntilDate, true)
                    else
                        DocumentNo2 := DocumentNo;
                end;
                if TempFAJournalLine.FindSet() then
                    repeat
                        FAJournalLine.Init();
                        FAJournalLine."Line No." := 0;
                        FAJournalSetup.SetFAJnlTrailCodes(FAJournalLine);
                        LineNo := LineNo + 1;
                        WindowDialog.Update(3, LineNo);
                        FAJournalLine."Posting Date" := PostingDate;
                        FAJournalLine."FA Posting Date" := DeprUntilDate;
                        if FAJournalLine."Posting Date" = FAJournalLine."FA Posting Date" then
                            FAJournalLine."Posting Date" := 0D;
                        FAJournalLine."FA Posting Type" := TempFAJournalLine."FA Posting Type";
                        FAJournalLine.Validate(FAJournalLine."FA No.", TempFAJournalLine."FA No.");
                        FAJournalLine."Document No." := DocumentNo2;
                        FAJournalLine."Posting No. Series" := NoSeries;
                        FAJournalLine.Description := BuildDescription(TempFAJournalLine."FA No.", PostingDate);
                        FAJournalLine.Validate(FAJournalLine."Depreciation Book Code", DeprBookCode);
                        FAJournalLine.Validate(FAJournalLine.Amount, TempFAJournalLine.Amount);
                        FAJournalLine."No. of Depreciation Days" := TempFAJournalLine."No. of Depreciation Days";
                        FAJournalLine."FA Error Entry No." := TempFAJournalLine."FA Error Entry No.";
                        FAJnlNextLineNo := FAJnlNextLineNo + 10000;
                        FAJournalLine."Line No." := FAJnlNextLineNo;
                        OnBeforeFAJnlLineInsert(TempFAJournalLine, FAJournalLine);
                        FAJournalLine.Insert(true);
                        FAJnlLineCreatedCount += 1;
                    until TempFAJournalLine.Next() = 0;

                if TempGenJournalLine.FindSet() then begin
                    GenJournalLine.LockTable();
                    FAJournalSetup.GenJnlName(DepreciationBook, GenJournalLine, GenJnlNextLineNo);
                    NoSeries := FAJournalSetup.GetGenNoSeries(GenJournalLine);
                    if DocumentNo = '' then
                        if GenJournalLine.FindLast() then
                            DocumentNo2 := GenJournalLine."Document No."
                        else
                            DocumentNo2 := FAJournalSetup.GetGenJnlDocumentNo(GenJournalLine, DeprUntilDate, true)
                    else
                        DocumentNo2 := DocumentNo;
                end;
                if TempGenJournalLine.FindSet() then
                    repeat
                        GenJournalLine.Init();
                        GenJournalLine."Line No." := 0;
                        FAJournalSetup.SetGenJnlTrailCodes(GenJournalLine);
                        LineNo := LineNo + 1;
                        WindowDialog.Update(3, LineNo);
                        GenJournalLine."Posting Date" := PostingDate;
                        GenJournalLine."VAT Reporting Date" := PostingDate;
                        GenJournalLine."FA Posting Date" := DeprUntilDate;
                        if GenJournalLine."Posting Date" = GenJournalLine."FA Posting Date" then
                            GenJournalLine."FA Posting Date" := 0D;
                        GenJournalLine."FA Posting Type" := TempGenJournalLine."FA Posting Type";
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Fixed Asset";
                        GenJournalLine.Validate(GenJournalLine."Account No.", TempGenJournalLine."Account No.");
                        GenJournalLine.Description := BuildDescription(TempGenJournalLine."Account No.", PostingDate);
                        GenJournalLine."Document No." := DocumentNo2;
                        GenJournalLine."Posting No. Series" := NoSeries;
                        GenJournalLine.Validate(GenJournalLine."Depreciation Book Code", DeprBookCode);
                        GenJournalLine.Validate(GenJournalLine.Amount, TempGenJournalLine.Amount);
                        GenJournalLine."No. of Depreciation Days" := TempGenJournalLine."No. of Depreciation Days";
                        GenJournalLine."FA Error Entry No." := TempGenJournalLine."FA Error Entry No.";
                        GenJnlNextLineNo := GenJnlNextLineNo + 1000;
                        GenJournalLine."Line No." := GenJnlNextLineNo;
                        OnBeforeGenJnlLineInsert(TempGenJournalLine, GenJournalLine);
                        GenJournalLine.Insert(true);
                        GenJnlLineCreatedCount += 1;
                        if BalAccount then begin
                            BindSubscription(SuppUpdtSourceHandlerCZF);
                            FAInsertGLAccount.GetBalAcc(GenJournalLine, GenJnlNextLineNo);
                            UnBindSubscription(SuppUpdtSourceHandlerCZF);
                        end;
                        OnAfterFAInsertGLAccGetBalAcc(GenJournalLine, GenJnlNextLineNo, BalAccount);
                    until TempGenJournalLine.Next() = 0;
                OnAfterPostDataItem();
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
                    field(DepreciationBookCode; DeprBookCode)
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
                        ToolTip = 'Specifies the fixed asset posting date to be used by the batch job. The batch job includes ledger entries up to this date. This date appears in the FA Posting Date field in the resulting journal lines. If the Use Same FA+G/L Posting Dates field has been activated in the depreciation book that is used in the batch job, then this date must be the same as the posting date entered in the Posting Date field.';

                        trigger OnValidate()
                        begin
                            DeprUntilDateModified := true;
                        end;
                    }
                    field(UseForceNoOfDaysCZF; UseForceNoOfDays)
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
                    field(PostingDateCZF; PostingDate)
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
                    field(DocumentNoCZF; DocumentNo)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies, if you leave the field empty, the next available number on the resulting journal line. If a number series is not set up, enter the document number that you want assigned to the resulting journal line.';
                    }
                    field(PostingDescriptionCZF; PostingDescription)
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
    }

    trigger OnPostReport()
    var
        PageGenJournalLine: Record "Gen. Journal Line";
        PageFAJournalLine: Record "FA Journal Line";
        IsHandled: Boolean;
    begin
        WindowDialog.Close();
        if (FAJnlLineCreatedCount = 0) and (GenJnlLineCreatedCount = 0) then begin
            Message(CompletionStatsMsg);
            exit;
        end;

        if FAJnlLineCreatedCount > 0 then begin
            IsHandled := false;
            OnPostReportOnBeforeConfirmShowFAJournalLines(DepreciationBook, FAJournalLine, FAJnlLineCreatedCount, IsHandled);
            if not IsHandled then
                if Confirm(CompletionStatsFAJnlQst, true, FAJnlLineCreatedCount) then begin
                    PageFAJournalLine.SetRange("Journal Template Name", FAJournalLine."Journal Template Name");
                    PageFAJournalLine.SetRange("Journal Batch Name", FAJournalLine."Journal Batch Name");
                    PageFAJournalLine.FindFirst();
                    PAGE.Run(PAGE::"Fixed Asset Journal", PageFAJournalLine);
                end;
        end;

        if GenJnlLineCreatedCount > 0 then begin
            IsHandled := false;
            OnPostReportOnBeforeConfirmShowGenJournalLines(DepreciationBook, GenJournalLine, GenJnlLineCreatedCount, IsHandled);
            if not IsHandled then
                if Confirm(CompletionStatsGenJnlQst, true, GenJnlLineCreatedCount) then begin
                    PageGenJournalLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
                    PageGenJournalLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
                    PageGenJournalLine.FindFirst();
                    PAGE.Run(PAGE::"Fixed Asset G/L Journal", PageGenJournalLine);
                end;
        end;
    end;

    trigger OnPreReport()
    begin
        DepreciationBook.Get(DeprBookCode);
        if DeprUntilDate = 0D then
            Error(MustSpecifyErr, FAJournalLine.FieldCaption("FA Posting Date"));
        if PostingDate = 0D then
            PostingDate := DeprUntilDate;
        if UseForceNoOfDays and (DaysInPeriod = 0) then
            Error(ForceNoDaysErr);

        if DepreciationBook."Use Same FA+G/L Posting Dates" and (DeprUntilDate <> PostingDate) then
            Error(
              PostingDateIdenticalErr,
              FAJournalLine.FieldCaption("FA Posting Date"),
              FAJournalLine.FieldCaption("Posting Date"),
              DepreciationBook.FieldCaption("Use Same FA+G/L Posting Dates"),
              false,
              DepreciationBook.TableCaption,
              DepreciationBook.FieldCaption(Code),
              DepreciationBook.Code);

        WindowDialog.Open(Text003Txt + Text004Txt + Text005Txt);
    end;

    var
        GenJournalLine: Record "Gen. Journal Line";
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        FASetup: Record "FA Setup";
        FAJournalLine: Record "FA Journal Line";
        TempFAJournalLine: Record "FA Journal Line" temporary;
        DepreciationBook: Record "Depreciation Book";
        FAJournalSetup: Record "FA Journal Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        CalculateDepreciation: Codeunit "Calculate Depreciation";
        FAInsertGLAccount: Codeunit "FA Insert G/L Account";
        SuppUpdtSourceHandlerCZF: Codeunit "Supp. Updt. Source Handler CZF";
        WindowDialog: Dialog;
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
        NoSeries: Code[20];
        PostingDescription: Text[100];
        DeprBookCode: Code[10];
        BalAccount: Boolean;
        FAJnlNextLineNo: Integer;
        GenJnlNextLineNo: Integer;
        EntryAmounts: array[4] of Decimal;
        LineNo: Integer;
        DepreciationInterrupted: Boolean;
        CompletionStatsMsg: Label 'The depreciation has been calculated.\\No journal lines were created.';
        FAJnlLineCreatedCount: Integer;
        GenJnlLineCreatedCount: Integer;
        CompletionStatsFAJnlQst: Label 'The depreciation has been calculated.\\%1 fixed asset journal lines were created.\\Do you want to open the Fixed Asset Journal window?', Comment = '%1 = Number of created FA Journal Lines';
        CompletionStatsGenJnlQst: Label 'The depreciation has been calculated.\\%1 fixed asset G/L journal lines were created.\\Do you want to open the Fixed Asset G/L Journal window?', Comment = '%1 = Number of created Gen. Journal Lines';
        DeprUntilDateModified: Boolean;
        MustSpecifyErr: Label 'You must specify %1.', Comment = '%1 = FA Posting Date FieldCaption';
        ForceNoDaysErr: Label 'Force No. of Days must be activated.';
        PostingDateIdenticalErr: Label '%1 and %2 must be identical. %3 must be %4 in %5 %6 = %7.', Comment = '%1 = FA Posting Date FieldCaption, %2 = Posting Date FieldCaption, %3 = Use Same Dates FieldCaption, %4 = false, %5 = Depreciation Book TableCaption, %6 = Depreciation Book Code FieldCaption, %7 = Depreciation Book Code';
        Text003Txt: Label 'Depreciating fixed asset      #1##########\', Comment = '%1 = Fixed Asset No.';
        Text004Txt: Label 'Not depreciating fixed asset  #2##########\', Comment = '%1 = Fixed Asset No.';
        Text005Txt: Label 'Inserting journal lines       #3##########', Comment = '%1 = Line No.';
        UseForceNoOfDaysErr: Label 'Use Force No. of Days must be activated.';

    procedure InitializeRequest(DeprBookCodeFrom: Code[10]; DeprUntilDateFrom: Date; UseForceNoOfDaysFrom: Boolean; DaysInPeriodFrom: Integer; PostingDateFrom: Date; DocumentNoFrom: Code[20]; PostingDescriptionFrom: Text[100]; BalAccountFrom: Boolean)
    begin
        DeprBookCode := DeprBookCodeFrom;
        DeprUntilDate := DeprUntilDateFrom;
        UseForceNoOfDays := UseForceNoOfDaysFrom;
        DaysInPeriod := DaysInPeriodFrom;
        PostingDate := PostingDateFrom;
        DocumentNo := DocumentNoFrom;
        PostingDescription := PostingDescriptionFrom;
        BalAccount := BalAccountFrom;
    end;

    local procedure BuildDescription(FANo: Code[20]; PeriodDate: Date): Text[100]
    begin
        exit(StrSubstNo(PostingDescription, FANo, StrSubstNo('%1/%2', Date2DMY(PeriodDate, 3), Date2DMY(PeriodDate, 2))));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateDepreciation(FANo: Code[20]; var TempGenJournalLine: Record "Gen. Journal Line" temporary; var TempFAJournalLine: Record "FA Journal Line" temporary; var DeprAmount: Decimal; var NumberOfDays: Integer; DeprBookCode: Code[10]; DeprUntilDate: Date; EntryAmounts: array[4] of Decimal; DaysInPeriod: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFAInsertGLAccGetBalAcc(var GenJournalLine: Record "Gen. Journal Line"; var GenJnlNextLineNo: Integer; var BalAccount: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostDataItem()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateDepreciation(FANo: Code[20]; var TempGenJournalLine: Record "Gen. Journal Line" temporary; var TempFAJournalLine: Record "FA Journal Line" temporary; var DeprAmount: Decimal; var NumberOfDays: Integer; DeprBookCode: Code[10]; DeprUntilDate: Date; EntryAmounts: array[4] of Decimal; DaysInPeriod: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFAJnlLineInsert(var TempFAJournalLine: Record "FA Journal Line" temporary; var FAJournalLine: Record "FA Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGenJnlLineInsert(var TempGenJournalLine: Record "Gen. Journal Line" temporary; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostReportOnBeforeConfirmShowFAJournalLines(DepreciationBook: Record "Depreciation Book"; FAJournalLine: Record "FA Journal Line"; FAJnlLineCreatedCount: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostReportOnBeforeConfirmShowGenJournalLines(DepreciationBook: Record "Depreciation Book"; GenJournalLine: Record "Gen. Journal Line"; GenJnlLineCreatedCount: Integer; var IsHandled: Boolean)
    begin
    end;
}
