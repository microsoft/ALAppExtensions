// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Setup;

using Microsoft.Finance.Analysis;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.Period;
using Microsoft.Utilities;
using System.Globalization;
using System.Utilities;

report 11755 "Open Balance Sheet CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Open Balance Sheet';
    Permissions = tabledata "G/L Entry" = m;
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = sorting("No.") where("Account Type" = const(Posting), "Income/Balance" = const("Balance Sheet"));
            RequestFilterFields = "G/L Account Group CZL";
            dataitem("G/L Entry"; "G/L Entry")
            {
                DataItemLink = "G/L Account No." = field("No.");
                DataItemTableView = sorting("G/L Account No.", "Posting Date");

                trigger OnAfterGetRecord()
                var
                    TempDimBuf: Record "Dimension Buffer" temporary;
                    TempDimBuf2: Record "Dimension Buffer" temporary;
                    EntryNo: Integer;
                begin
                    if FieldActive("Business Unit Code") and
                       (ClosePerBusUnit or ClosePerGlobalDim1 or ClosePerGlobalDim2 or not ClosePerGlobalDimOnly)
                    then begin
                        SetRange("Business Unit Code", "Business Unit Code");
                        GenJournalLine."Business Unit Code" := "Business Unit Code";
                    end;
                    if FieldActive("Global Dimension 1 Code") and
                       (ClosePerGlobalDim1 or ClosePerGlobalDim2 or not ClosePerGlobalDimOnly)
                    then
                        SetRange("Global Dimension 1 Code", "Global Dimension 1 Code");
                    if FieldActive("Global Dimension 2 Code") and
                       (ClosePerGlobalDim2 or not ClosePerGlobalDimOnly)
                    then
                        SetRange("Global Dimension 2 Code", "Global Dimension 2 Code");
                    if not ClosePerGlobalDimOnly then
                        SetRange("Close Income Statement Dim. ID", "Close Income Statement Dim. ID");

                    CalcSumsInFilter();
                    if (Amount <> 0) or ("Additional-Currency Amount" <> 0) then begin
                        if ClosePerGlobalDimOnly then begin
                            EntryNo := "Entry No.";
                            GetGLEntryDimensions(EntryNo, TempDimBuf);
                        end else begin
                            EntryNo := "Close Income Statement Dim. ID";
                            DimensionBufferManagement.GetDimensions(EntryNo, TempDimBuf);
                        end;
                        if not TempDimBuf2.IsEmpty then
                            TempDimBuf2.DeleteAll();
                        if TempSelectedDimension.FindSet() then
                            repeat
                                if TempDimBuf.Get(Database::"G/L Entry", EntryNo, TempSelectedDimension."Dimension Code")
                                then begin
                                    TempDimBuf2."Table ID" := TempDimBuf."Table ID";
                                    TempDimBuf2."Dimension Code" := TempDimBuf."Dimension Code";
                                    TempDimBuf2."Dimension Value Code" := TempDimBuf."Dimension Value Code";
                                    TempDimBuf2.Insert();
                                end;
                            until TempSelectedDimension.Next() = 0;

                        EntryNo := SecondDimensionBufferManagement.FindDimensions(TempDimBuf2);
                        if EntryNo = 0 then
                            EntryNo := SecondDimensionBufferManagement.InsertDimensions(TempDimBuf2);

                        TempEntryNoAmountBuffer.Reset();
                        if ClosePerBusUnit and FieldActive("Business Unit Code") then
                            TempEntryNoAmountBuffer."Business Unit Code" := "Business Unit Code"
                        else
                            TempEntryNoAmountBuffer."Business Unit Code" := '';
                        TempEntryNoAmountBuffer."Entry No." := EntryNo;
                        if TempEntryNoAmountBuffer.Find() then begin
                            TempEntryNoAmountBuffer.Amount := TempEntryNoAmountBuffer.Amount + Amount;
                            TempEntryNoAmountBuffer.Amount2 := TempEntryNoAmountBuffer.Amount2 + "Additional-Currency Amount";
                            TempEntryNoAmountBuffer.Modify();
                        end else begin
                            TempEntryNoAmountBuffer.Amount := Amount;
                            TempEntryNoAmountBuffer.Amount2 := "Additional-Currency Amount";
                            TempEntryNoAmountBuffer.Insert();
                        end;
                    end;
                    FindLast();
                    if FieldActive("Business Unit Code") then
                        SetRange("Business Unit Code");
                    if FieldActive("Global Dimension 1 Code") then
                        SetRange("Global Dimension 1 Code");
                    if FieldActive("Global Dimension 2 Code") then
                        SetRange("Global Dimension 2 Code");
                    SetRange("Close Income Statement Dim. ID");
                end;

                trigger OnPostDataItem()
                var
                    TempDimBuf2: Record "Dimension Buffer" temporary;
                    GlobalDimVal1: Code[20];
                    GlobalDimVal2: Code[20];
                    NewDimensionID: Integer;
                begin
                    TempEntryNoAmountBuffer.Reset();
                    if TempEntryNoAmountBuffer.FindSet() then
                        repeat
                            if (TempEntryNoAmountBuffer.Amount <> 0) or (TempEntryNoAmountBuffer.Amount2 <> 0) then begin
                                GenJournalLine."Line No." := GenJournalLine."Line No." + 10000;
                                GenJournalLine."Account No." := "G/L Account No.";
                                GenJournalLine."Source Code" := SourceCodeSetup."Open Balance Sheet CZL";
                                GenJournalLine."Reason Code" := GenJournalBatch."Reason Code";
                                GenJournalLine.Validate(Amount, -TempEntryNoAmountBuffer.Amount);
                                GenJournalLine."Source Currency Amount" := -TempEntryNoAmountBuffer.Amount2;
                                GenJournalLine."Business Unit Code" := TempEntryNoAmountBuffer."Business Unit Code";

                                TempDimBuf2.DeleteAll();
                                SecondDimensionBufferManagement.GetDimensions(TempEntryNoAmountBuffer."Entry No.", TempDimBuf2);
                                NewDimensionID := DimensionManagement.CreateDimSetIDFromDimBuf(TempDimBuf2);
                                GenJournalLine."Dimension Set ID" := NewDimensionID;
                                DimensionManagement.UpdateGlobalDimFromDimSetID(NewDimensionID, GlobalDimVal1, GlobalDimVal2);
                                GenJournalLine."Shortcut Dimension 1 Code" := '';
                                if ClosePerGlobalDim1 then
                                    GenJournalLine."Shortcut Dimension 1 Code" := GlobalDimVal1;
                                GenJournalLine."Shortcut Dimension 2 Code" := '';
                                if ClosePerGlobalDim2 then
                                    GenJournalLine."Shortcut Dimension 2 Code" := GlobalDimVal2;

                                if PostToOpeningBalanceSheetAcc = PostToOpeningBalanceSheetAcc::Details then begin
                                    GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                                    GenJournalLine."Bal. Account No." := OpeningBalanceSheetGLAccount."No.";
                                end;

                                GenJournalLine.AdjustDebitCreditCZL(false);
                                HandleGenJnlLine();
                            end;
                        until TempEntryNoAmountBuffer.Next() = 0;

                    if not TempEntryNoAmountBuffer.IsEmpty then
                        TempEntryNoAmountBuffer.DeleteAll();
                end;

                trigger OnPreDataItem()
                begin
                    if ClosePerBusUnit or ClosePerGlobalDim1 or ClosePerGlobalDim2 or not ClosePerGlobalDimOnly then
                        SetCurrentKey(
                          "G/L Account No.", "Business Unit Code",
                          "Global Dimension 1 Code", "Global Dimension 2 Code", "Close Income Statement Dim. ID",
                          "Posting Date")
                    else
                        SetCurrentKey("G/L Account No.", "Posting Date");
                    SetRange("Posting Date", FiscYearClosingDate);

                    if not TempEntryNoAmountBuffer.IsEmpty then
                        TempEntryNoAmountBuffer.DeleteAll();

                    Clear(SecondDimensionBufferManagement);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                WindowDialog.Update(1, "No.");
                UpdateCloseIncomeStmtDimID("No.");
            end;

            trigger OnPostDataItem()
            begin
                if ((TotalAmount <> 0) or ((TotalAmountAddCurr <> 0) and (GeneralLedgerSetup."Additional Reporting Currency" <> ''))) and
                   (PostToOpeningBalanceSheetAcc = PostToOpeningBalanceSheetAcc::Balance)
                then begin
                    GenJournalLine."Business Unit Code" := '';
                    GenJournalLine."Shortcut Dimension 1 Code" := '';
                    GenJournalLine."Shortcut Dimension 2 Code" := '';
                    GenJournalLine."Line No." := GenJournalLine."Line No." + 10000;
                    GenJournalLine."Account No." := OpeningBalanceSheetGLAccount."No.";
                    GenJournalLine."Source Code" := SourceCodeSetup."Open Balance Sheet CZL";
                    GenJournalLine."Reason Code" := GenJournalBatch."Reason Code";
                    GenJournalLine."Currency Code" := '';
                    GenJournalLine."Additional-Currency Posting" :=
                      GenJournalLine."Additional-Currency Posting"::None;
                    GenJournalLine.Correction := false;
                    GenJournalLine.Validate(Amount, TotalAmount);
                    GenJournalLine."Source Currency Amount" := TotalAmountAddCurr;
                    HandleGenJnlLine();
                    WindowDialog.Update(1, GenJournalLine."Account No.");
                end;
            end;

            trigger OnPreDataItem()
            begin
                SetRange("G/L Account Group CZL", GLAccountGroup);
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
                    field(FiscalYearEndingDateFld; EndDateReq)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Fiscal Year Ending Date';
                        ToolTip = 'Specifies the end date fiscal year to close the balance sheet.';

                        trigger OnValidate()
                        begin
                            ValidateEndDate(true);
                        end;
                    }
                    field(GenJournalTemplateFld; GenJournalLine."Journal Template Name")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Gen. Journal Template';
                        TableRelation = "Gen. Journal Template" where(Type = const(General), Recurring = const(false));
                        ToolTip = 'Specifies the journal template. This template will be used as the format for report results.';

                        trigger OnValidate()
                        begin
                            GenJournalLine."Journal Batch Name" := '';
                            DocNo := '';
                        end;
                    }
                    field(GenJournalBatchFld; GenJournalLine."Journal Batch Name")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Gen. Journal Batch';
                        Lookup = true;
                        ToolTip = 'Specifies the relevant general journal batch name.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            GenJournalLine.TestField("Journal Template Name");
                            GenJournalTemplate.Get(GenJournalLine."Journal Template Name");
                            GenJournalBatch.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
                            GenJournalBatch."Journal Template Name" := GenJournalLine."Journal Template Name";
                            GenJournalBatch.Name := GenJournalLine."Journal Batch Name";
                            if PAGE.RunModal(0, GenJournalBatch) = ACTION::LookupOK then begin
                                GenJournalLine."Journal Batch Name" := GenJournalBatch.Name;
                                ValidateJnl();
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            if GenJournalLine."Journal Batch Name" <> '' then begin
                                GenJournalLine.TestField("Journal Template Name");
                                GenJournalBatch.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name");
                            end;
                            ValidateJnl();
                        end;
                    }
                    field(DocumentNoFld; DocNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies a document number for the journal line.';
                    }
                    field(OpeningBalanceSheetAccFld; OpeningBalanceSheetGLAccount."No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Opening Balance Sheet Account';
                        TableRelation = "G/L Account";
                        ToolTip = 'Specifies a opening balance sheet account.';

                        trigger OnValidate()
                        begin
                            if OpeningBalanceSheetGLAccount."No." <> '' then begin
                                OpeningBalanceSheetGLAccount.Find();
                                OpeningBalanceSheetGLAccount.CheckGLAcc();
                            end;
                        end;
                    }
                    field(PostToOpeningBalanceSheetAccFld; PostToOpeningBalanceSheetAcc)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Post to Opening Balance Sheet Acc.';
                        OptionCaption = 'Balance,Details';
                        ToolTip = 'Specifies if the resulting entries are posted with the Opening Balance Sheet account as a balancing account on each line (Details) or if balance sheets are posted as an extra line with a summarized amount (Balance).';
                    }
                    field(PostingDescriptionFld; PostingDescription)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posting Description';
                        ToolTip = 'Specifies a posting description.';
                    }
                    field(GLAccountGroupFld; GLAccountGroup)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'G/L Account Group';
                        ToolTip = 'Specifies the type of accounting area, that will be processed in opening operation.';
                    }
                    group("Open by")
                    {
                        Caption = 'Open by';
                        field(ClosePerBusUnitFld; ClosePerBusUnit)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Business Unit Code';
                            ToolTip = 'Specifies to display the business unit code that the budget entry is linked to.';
                        }
                        field(ColumnDimFld; ColumnDim)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Dimensions';
                            Editable = false;
                            ToolTip = 'Specifies the relevant dimension code. Dimension codes are used to group entries with similar characteristics.';

                            trigger OnAssistEdit()
                            begin
                                DimensionSelectionBuffer.SetDimSelectionMultiple(3, Report::"Open Balance Sheet CZL", ColumnDim);
                            end;
                        }
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if PostingDescription = '' then
                PostingDescription :=
                  CopyStr(ObjectTranslation.TranslateObject(ObjectTranslation."Object Type"::Report, Report::"Open Balance Sheet CZL"), 1, 30);
            EndDateReq := 0D;
            AccountingPeriod.SetRange("New Fiscal Year", true);
            AccountingPeriod.SetRange("Date Locked", true);
            if AccountingPeriod.FindLast() then begin
                EndDateReq := AccountingPeriod."Starting Date" - 1;
                if not ValidateEndDate(false) then
                    EndDateReq := 0D;
            end;
            ValidateJnl();
            ColumnDim := DimensionSelectionBuffer.GetDimSelectionText(3, Report::"Open Balance Sheet CZL", '');
        end;
    }

    trigger OnPostReport()
    var
        UpdateAnalysisView: Codeunit "Update Analysis View";
    begin
        UpdateAnalysisView.UpdateAll(0, true);
    end;

    trigger OnPreReport()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        CheckDimResultText: Text;
    begin
        if EndDateReq = 0D then
            Error(EnterEndingDateErr);
        ValidateEndDate(true);
        if DocNo = '' then
            Error(EnterDocumentNoErr);

        GeneralLedgerSetup.Get();
        SelectedDimension.GetSelectedDim(CopyStr(UserId(), 1, 50), 3, Report::"Open Balance Sheet CZL", '', TempSelectedDimension);
        CheckDimResultText := CheckDimPostingRules(TempSelectedDimension);
        if (CheckDimResultText <> '') and GeneralLedgerSetup."Do Not Check Dimensions CZL" then
            if not ConfirmManagement.GetResponse(CheckDimResultText + CreateJournalQst, false) then
                Error('');

        GenJournalBatch.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name");
        SourceCodeSetup.Get();
        if GeneralLedgerSetup."Additional Reporting Currency" <> '' then begin
            if OpeningBalanceSheetGLAccount."No." = '' then
                Error(EnterOpeningBalSheetAccErr);
            if not ConfirmManagement.GetResponse(AdditionalRepCurrPostingQst, false) then
                CurrReport.Quit();
        end;

        ClosePerGlobalDim1 := false;
        ClosePerGlobalDim2 := false;
        ClosePerGlobalDimOnly := true;

        if TempSelectedDimension.FindSet() then
            repeat
                if TempSelectedDimension."Dimension Code" = GeneralLedgerSetup."Global Dimension 1 Code" then
                    ClosePerGlobalDim1 := true;
                if TempSelectedDimension."Dimension Code" = GeneralLedgerSetup."Global Dimension 2 Code" then
                    ClosePerGlobalDim2 := true;
                if (TempSelectedDimension."Dimension Code" <> GeneralLedgerSetup."Global Dimension 1 Code") and
                   (TempSelectedDimension."Dimension Code" <> GeneralLedgerSetup."Global Dimension 2 Code")
                then
                    ClosePerGlobalDimOnly := false;
            until TempSelectedDimension.Next() = 0;

        CollectCloseIncomeStmtDimID();

        GenJournalLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        if not GenJournalLine.FindLast() then;
        GenJournalLine.Init();
        GenJournalLine."Posting Date" := FiscYearClosingDate;
        GenJournalLine."Document No." := DocNo;
        GenJournalLine.Description := PostingDescription;
        GenJournalLine."Posting No. Series" := GenJournalBatch."Posting No. Series";
        WindowDialog.Open(CreatingJnlDialogTxt);
    end;

    var
        AccountingPeriod: Record "Accounting Period";
        SourceCodeSetup: Record "Source Code Setup";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        OpeningBalanceSheetGLAccount: Record "G/L Account";
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionSelectionBuffer: Record "Dimension Selection Buffer";
        SelectedDimension: Record "Selected Dimension";
        TempSelectedDimension: Record "Selected Dimension" temporary;
        TempEntryNoAmountBuffer: Record "Entry No. Amount Buffer" temporary;
        ObjectTranslation: Record "Object Translation";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DimensionManagement: Codeunit DimensionManagement;
        DimensionBufferManagement: Codeunit "Dimension Buffer Management";
        SecondDimensionBufferManagement: Codeunit "Dimension Buffer Management";
        WindowDialog: Dialog;
        FiscalYearStartDate: Date;
        FiscYearClosingDate: Date;
        EndDateReq: Date;
        DocNo: Code[20];
        PostingDescription: Text[50];
        ClosePerBusUnit: Boolean;
        ClosePerGlobalDim1: Boolean;
        ClosePerGlobalDim2: Boolean;
        ClosePerGlobalDimOnly: Boolean;
        TotalAmount: Decimal;
        TotalAmountAddCurr: Decimal;
        ColumnDim: Text[250];
        NextDimID: Integer;
        GLAccountGroup: Enum "G/L Account Group CZL";
        EnterEndingDateErr: Label 'Please enter the ending date for the fiscal year.';
        EnterDocumentNoErr: Label 'Please enter a Document No.';
        EnterOpeningBalSheetAccErr: Label 'Please enter Opening Balance Sheet Account No.';
        AdditionalRepCurrPostingQst: Label 'With the use of an additional reporting currency, this batch job will post closing entries directly to the general ledger. These closing entries will not be transferred to a general journal before the program posts them to the general ledger.\\Do you wish to continue?';
        CreatingJnlDialogTxt: Label 'Creating general journal lines...\\Account No. #1##########', Comment = '%1 = G/L Account No.';
        FiscalYearMustBeClosedErr: Label 'The fiscal year must be closed before the balance sheet can be opened.';
        FiscalYearNotExistErr: Label 'The fiscal year does not exist.';
        MandatoryDimTxt: Label 'The following G/L Accounts have mandatory dimension codes:';
        SelectPostingDimTxt: Label '\\In order to post to this journal you may also select these dimensions:';
        CreateJournalQst: Label '\\Continue and create journal?';
        PostToOpeningBalanceSheetAcc: Option Balance,Details;

    local procedure ValidateEndDate(RealMode: Boolean): Boolean
    var
        IsValid: Boolean;
    begin
        if EndDateReq = 0D then
            exit;

        IsValid := AccountingPeriod.Get(EndDateReq + 1);
        if IsValid then
            IsValid := AccountingPeriod."New Fiscal Year";
        if IsValid then begin
            if not AccountingPeriod."Date Locked" then begin
                if not RealMode then
                    exit;
                Error(FiscalYearMustBeClosedErr);
            end;
            FiscYearClosingDate := ClosingDate(EndDateReq);
            AccountingPeriod.SetRange("New Fiscal Year", true);
            IsValid := AccountingPeriod.Find('<');
            FiscalYearStartDate := AccountingPeriod."Starting Date";
        end;
        if not IsValid then begin
            if not RealMode then
                exit;
            Error(FiscalYearNotExistErr);
        end;
        exit(true);
    end;

    local procedure ValidateJnl()
    var
        NoSeries: Codeunit "No. Series";
    begin
        DocNo := '';
        if GenJournalBatch.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name") then
            if GenJournalBatch."No. Series" <> '' then
                DocNo := NoSeries.PeekNextNo(GenJournalBatch."No. Series", EndDateReq);
    end;

    local procedure HandleGenJnlLine()
    begin
        GenJournalLine."Additional-Currency Posting" :=
          GenJournalLine."Additional-Currency Posting"::None;
        if GeneralLedgerSetup."Additional Reporting Currency" <> '' then begin
            GenJournalLine."Source Currency Code" := GeneralLedgerSetup."Additional Reporting Currency";
            if (GenJournalLine.Amount = 0) and
               (GenJournalLine."Source Currency Amount" <> 0)
            then begin
                GenJournalLine."Additional-Currency Posting" :=
                  GenJournalLine."Additional-Currency Posting"::"Additional-Currency Amount Only";
                GenJournalLine.Validate(Amount, GenJournalLine."Source Currency Amount");
                GenJournalLine."Source Currency Amount" := 0;
            end;
            if GenJournalLine.Amount <> 0 then
                GenJnlPostLine.RunWithCheck(GenJournalLine);
        end else
            GenJournalLine.Insert();
    end;

    local procedure CollectCloseIncomeStmtDimID()
    var
        GLEntry: Record "G/L Entry";
        DimensionSetEntry: Record "Dimension Set Entry";
        TempDimensionBuffer: Record "Dimension Buffer" temporary;
    begin
        if ClosePerGlobalDimOnly then
            exit;

        GLEntry.SetCurrentKey("Close Income Statement Dim. ID");
        GLEntry.SetFilter("Close Income Statement Dim. ID", '>1');
        if GLEntry.FindSet() then begin
            repeat
                DimensionSetEntry.SetRange("Dimension Set ID", GLEntry."Dimension Set ID");
                if DimensionSetEntry.FindSet() then begin
                    if not TempDimensionBuffer.IsEmpty then
                        TempDimensionBuffer.DeleteAll();

                    repeat
                        TempDimensionBuffer."Table ID" := Database::"G/L Entry";
                        TempDimensionBuffer."Entry No." := GLEntry."Entry No.";
                        TempDimensionBuffer."Dimension Code" := DimensionSetEntry."Dimension Code";
                        TempDimensionBuffer."Dimension Value Code" := DimensionSetEntry."Dimension Value Code";
                        TempDimensionBuffer.Insert();
                    until DimensionSetEntry.Next() = 0;

                    DimensionBufferManagement.InsertDimensionsUsingEntryNo(
                      TempDimensionBuffer, GLEntry."Close Income Statement Dim. ID");
                end;
                GLEntry.SetFilter(
                  "Close Income Statement Dim. ID", '>%1', GLEntry."Close Income Statement Dim. ID");
            until GLEntry.Next() = 0;
            NextDimID := GLEntry."Close Income Statement Dim. ID" + 1;
        end else
            NextDimID := 2; // 1 is used when there are no dimensions on the entry
    end;

    local procedure UpdateCloseIncomeStmtDimID(AccNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
        TempDimensionBuffer: Record "Dimension Buffer" temporary;
        DimID: Integer;
    begin
        if ClosePerGlobalDimOnly then
            exit;

        GLEntry.SetCurrentKey(
          "G/L Account No.", "Business Unit Code",
          "Global Dimension 1 Code", "Global Dimension 2 Code", "Close Income Statement Dim. ID",
          "Posting Date");
        GLEntry.SetRange("G/L Account No.", AccNo);
        GLEntry.SetRange("Close Income Statement Dim. ID", 0);
        GLEntry.SetRange("Posting Date", FiscalYearStartDate, FiscYearClosingDate);

        while GLEntry.FindFirst() do begin
            GetGLEntryDimensions(GLEntry."Entry No.", TempDimensionBuffer);
            if TempDimensionBuffer.FindFirst() then begin
                DimID := DimensionBufferManagement.FindDimensions(TempDimensionBuffer);
                if DimID = 0 then begin
                    DimensionBufferManagement.InsertDimensionsUsingEntryNo(TempDimensionBuffer, NextDimID);
                    DimID := NextDimID;
                    NextDimID := NextDimID + 1;
                end;
            end else
                DimID := 1;
            GLEntry."Close Income Statement Dim. ID" := DimID;
            GLEntry.Modify();
        end;
    end;

    local procedure CalcSumsInFilter()
    begin
        "G/L Entry".CalcSums(Amount);
        TotalAmount := TotalAmount + "G/L Entry".Amount;
        if GeneralLedgerSetup."Additional Reporting Currency" <> '' then begin
            "G/L Entry".CalcSums("Additional-Currency Amount");
            TotalAmountAddCurr := TotalAmountAddCurr + "G/L Entry"."Additional-Currency Amount";
        end;
    end;

    local procedure GetGLEntryDimensions(EntryNo: Integer; var DimensionBuffer: Record "Dimension Buffer")
    var
        GLEntry: Record "G/L Entry";
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        DimensionBuffer.DeleteAll();
        GLEntry.Get(EntryNo);
        DimensionSetEntry.SetRange("Dimension Set ID", GLEntry."Dimension Set ID");
        if DimensionSetEntry.FindSet() then
            repeat
                DimensionBuffer."Table ID" := Database::"G/L Entry";
                DimensionBuffer."Entry No." := EntryNo;
                DimensionBuffer."Dimension Code" := DimensionSetEntry."Dimension Code";
                DimensionBuffer."Dimension Value Code" := DimensionSetEntry."Dimension Value Code";
                DimensionBuffer.Insert();
            until DimensionSetEntry.Next() = 0;
    end;

    local procedure CheckDimPostingRules(var SelectedDimension: Record "Selected Dimension"): Text
    var
        DefaultDimension: Record "Default Dimension";
        GLAccount: Record "G/L Account";
        PrevAcc: Code[20];
        ErrorText: Text;
        DimText: Text;
    begin
        DefaultDimension.SetRange("Table ID", Database::"G/L Account");
        DefaultDimension.SetFilter(
          "Value Posting", '%1|%2',
          DefaultDimension."Value Posting"::"Same Code", DefaultDimension."Value Posting"::"Code Mandatory");
        Clear(PrevAcc);
        if DefaultDimension.FindSet() then
            repeat
                if DefaultDimension."No." <> GLAccount."No." then
                    if not GLAccount.Get(DefaultDimension."No.") then
                        GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Income Statement";

                SelectedDimension.SetRange("Dimension Code", DefaultDimension."Dimension Code");
                if (not SelectedDimension.FindFirst()) and (GLAccount."Income/Balance" = GLAccount."Income/Balance"::"Balance Sheet") then begin
                    if StrPos(DimText, DefaultDimension."Dimension Code") < 1 then
                        DimText := DimText + ' ' + Format(DefaultDimension."Dimension Code");
                    if PrevAcc <> DefaultDimension."No." then begin
                        PrevAcc := DefaultDimension."No.";
                        if ErrorText = '' then
                            ErrorText := MandatoryDimTxt;
                        ErrorText := ErrorText + ' ' + Format(DefaultDimension."No.");
                    end;
                end;
                SelectedDimension.SetRange("Dimension Code");
            until (DefaultDimension.Next() = 0) or (StrLen(ErrorText) > MaxStrLen(ErrorText) - MaxStrLen(DefaultDimension."No.") - StrLen(SelectPostingDimTxt) - 1);

        if ErrorText <> '' then
            ErrorText := CopyStr(ErrorText + SelectPostingDimTxt + DimText, 1, MaxStrLen(ErrorText));
        exit(ErrorText);
    end;
}
