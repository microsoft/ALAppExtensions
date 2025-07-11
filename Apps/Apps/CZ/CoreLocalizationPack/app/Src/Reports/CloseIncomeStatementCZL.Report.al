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
using Microsoft.Inventory.Setup;
using Microsoft.Foundation.Period;
using Microsoft.Utilities;
using System.Globalization;
using System.Utilities;

report 11753 "Close Income Statement CZL"
{
    AdditionalSearchTerms = 'year closing statement,close accounting period statement,close fiscal year statement';
    ApplicationArea = Basic, Suite;
    Caption = 'Close Income Statement CZ';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = sorting("No.") where("Account Type" = const(Posting), "Income/Balance" = const("Income Statement"));
            RequestFilterFields = "G/L Account Group CZL";
            dataitem("G/L Entry"; "G/L Entry")
            {
                DataItemLink = "G/L Account No." = field("No.");
                DataItemTableView = sorting("G/L Account No.", "Posting Date");

                trigger OnAfterGetRecord()
                var
                    TempDimBuf: Record "Dimension Buffer" temporary;
                    TempDimBuf2: Record "Dimension Buffer" temporary;
                    DimensionBufferID: Integer;
                    RowOffset: Integer;
                begin
                    EntryCount := EntryCount + 1;
                    if CurrentDateTime - LastWindowUpdateDateTime > 1000 then begin
                        LastWindowUpdateDateTime := CurrentDateTime;
                        WindowDialog.Update(3, Round(EntryCount / MaxEntry * 10000, 1));
                    end;

                    if GroupSum() then begin
                        CalcSumsInFilter("G/L Entry", RowOffset);
                        GetGLEntryDimensions("Entry No.", TempDimBuf, "Dimension Set ID");
                    end;

                    if (Amount <> 0) or ("Additional-Currency Amount" <> 0) then begin
                        if not GroupSum() then begin
                            TotalAmount += Amount;
                            if GeneralLedgerSetup."Additional Reporting Currency" <> '' then
                                TotalAmountAddCurr += "Additional-Currency Amount";

                            GetGLEntryDimensions("Entry No.", TempDimBuf, "Dimension Set ID");
                        end;

                        if TempSelectedDimension.FindSet() then
                            repeat
                                if TempDimBuf.Get(Database::"G/L Entry", "Entry No.", TempSelectedDimension."Dimension Code")
                                then begin
                                    TempDimBuf2."Table ID" := TempDimBuf."Table ID";
                                    TempDimBuf2."Dimension Code" := TempDimBuf."Dimension Code";
                                    TempDimBuf2."Dimension Value Code" := TempDimBuf."Dimension Value Code";
                                    TempDimBuf2.Insert();
                                end;
                            until TempSelectedDimension.Next() = 0;

                        DimensionBufferID := DimensionBufferManagement.GetDimensionId(TempDimBuf2);

                        TempEntryNoAmountBuffer.Reset();
                        if ClosePerBusUnit and FieldActive("Business Unit Code") then
                            TempEntryNoAmountBuffer."Business Unit Code" := "Business Unit Code"
                        else
                            TempEntryNoAmountBuffer."Business Unit Code" := '';
                        TempEntryNoAmountBuffer."Entry No." := DimensionBufferID;
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

                    if GroupSum() then
                        Next(RowOffset);
                end;

                trigger OnPostDataItem()
                var
                    TempDimBuf2: Record "Dimension Buffer" temporary;
                    GlobalDimVal1: Code[20];
                    GlobalDimVal2: Code[20];
                    NewDimensionID: Integer;
                begin
                    TempEntryNoAmountBuffer.Reset();
                    MaxEntry := TempEntryNoAmountBuffer.Count();
                    EntryCount := 0;
                    WindowDialog.Update(2, CreatingGenJnlLinesTxt);
                    WindowDialog.Update(3, 0);

                    if TempEntryNoAmountBuffer.FindSet() then
                        repeat
                            EntryCount := EntryCount + 1;
                            if CurrentDateTime - LastWindowUpdateDateTime > 1000 then begin
                                LastWindowUpdateDateTime := CurrentDateTime;
                                WindowDialog.Update(3, Round(EntryCount / MaxEntry * 10000, 1));
                            end;

                            if (TempEntryNoAmountBuffer.Amount <> 0) or (TempEntryNoAmountBuffer.Amount2 <> 0) then begin
                                GenJournalLine."Line No." := GenJournalLine."Line No." + 10000;
                                GenJournalLine."Account No." := "G/L Account No.";
                                GenJournalLine."Source Code" := SourceCodeSetup."Close Income Statement";
                                GenJournalLine."Reason Code" := GenJournalBatch."Reason Code";
                                GenJournalLine.Validate(Amount, -TempEntryNoAmountBuffer.Amount);
                                GenJournalLine."Source Currency Amount" := -TempEntryNoAmountBuffer.Amount2;
                                GenJournalLine."Business Unit Code" := TempEntryNoAmountBuffer."Business Unit Code";

                                TempDimBuf2.DeleteAll();
                                DimensionBufferManagement.RetrieveDimensions(TempEntryNoAmountBuffer."Entry No.", TempDimBuf2);
                                NewDimensionID := DimensionManagement.CreateDimSetIDFromDimBuf(TempDimBuf2);
                                GenJournalLine."Dimension Set ID" := NewDimensionID;
                                DimensionManagement.UpdateGlobalDimFromDimSetID(NewDimensionID, GlobalDimVal1, GlobalDimVal2);
                                GenJournalLine."Shortcut Dimension 1 Code" := '';
                                if ClosePerGlobalDim1 then
                                    GenJournalLine."Shortcut Dimension 1 Code" := GlobalDimVal1;
                                GenJournalLine."Shortcut Dimension 2 Code" := '';
                                if ClosePerGlobalDim2 then
                                    GenJournalLine."Shortcut Dimension 2 Code" := GlobalDimVal2;

                                if PostToRetainedEarningsAcc = PostToRetainedEarningsAcc::Details then begin
                                    GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                                    GenJournalLine."Bal. Account No." := RetainedEarningsGLAccount."No.";
                                end;

                                HandleGenJnlLine();
                            end;
                        until TempEntryNoAmountBuffer.Next() = 0;

                    TempEntryNoAmountBuffer.DeleteAll();
                end;

                trigger OnPreDataItem()
                begin
                    WindowDialog.Update(2, CalcAmountsTxt);
                    WindowDialog.Update(3, 0);

                    if ClosePerGlobalDimOnly or ClosePerBusUnit then
                        case true of
                            ClosePerBusUnit and (ClosePerGlobalDim1 or ClosePerGlobalDim2):
                                SetCurrentKey(
                                  "G/L Account No.", "Business Unit Code",
                                  "Global Dimension 1 Code", "Global Dimension 2 Code", "Posting Date");
                            ClosePerBusUnit and not (ClosePerGlobalDim1 or ClosePerGlobalDim2):
                                SetCurrentKey(
                                  "G/L Account No.", "Business Unit Code", "Posting Date");
                            not ClosePerBusUnit and (ClosePerGlobalDim1 or ClosePerGlobalDim2):
                                SetCurrentKey(
                                  "G/L Account No.", "Global Dimension 1 Code", "Global Dimension 2 Code", "Posting Date");
                        end;

                    SetRange("Posting Date", FiscalYearStartDate, FiscYearClosingDate);

                    MaxEntry := Count();

                    TempEntryNoAmountBuffer.DeleteAll();
                    EntryCount := 0;

                    LastWindowUpdateDateTime := CurrentDateTime;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                ThisAccountNo := ThisAccountNo + 1;
                WindowDialog.Update(1, "No.");
                WindowDialog.Update(4, Round(ThisAccountNo / NoOfAccounts * 10000, 1));
                WindowDialog.Update(2, '');
                WindowDialog.Update(3, 0);
            end;

            trigger OnPostDataItem()
            begin
                if ((TotalAmount <> 0) or ((TotalAmountAddCurr <> 0) and (GeneralLedgerSetup."Additional Reporting Currency" <> ''))) and
                   (PostToRetainedEarningsAcc = PostToRetainedEarningsAcc::Balance)
                then begin
                    GenJournalLine."Business Unit Code" := '';
                    GenJournalLine."Shortcut Dimension 1 Code" := '';
                    GenJournalLine."Shortcut Dimension 2 Code" := '';
                    GenJournalLine."Dimension Set ID" := 0;
                    GenJournalLine."Line No." := GenJournalLine."Line No." + 10000;
                    GenJournalLine."Account No." := RetainedEarningsGLAccount."No.";
                    GenJournalLine."Source Code" := SourceCodeSetup."Close Income Statement";
                    GenJournalLine."Reason Code" := GenJournalBatch."Reason Code";
                    GenJournalLine."Currency Code" := '';
                    GenJournalLine."Additional-Currency Posting" :=
                      GenJournalLine."Additional-Currency Posting"::None;
                    GenJournalLine.Validate(Amount, TotalAmount);
                    GenJournalLine."Source Currency Amount" := TotalAmountAddCurr;
                    HandleGenJnlLine();
                    WindowDialog.Update(1, GenJournalLine."Account No.");
                end;
            end;

            trigger OnPreDataItem()
            begin
                NoOfAccounts := Count();
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
                        ToolTip = 'Specifies the last date in the closed fiscal year. This date is used to determine the closing date.';

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
                        ToolTip = 'Specifies the general journal template that is used by the batch job.';

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
                        ToolTip = 'Specifies the general journal batch that is used by the batch job.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            GenJournalLine.TestField("Journal Template Name");
                            GenJournalTemplate.Get(GenJournalLine."Journal Template Name");
                            GenJournalBatch.FilterGroup(2);
                            GenJournalBatch.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
                            GenJournalBatch.FilterGroup(0);
                            GenJournalBatch."Journal Template Name" := GenJournalLine."Journal Template Name";
                            GenJournalBatch.Name := GenJournalLine."Journal Batch Name";
                            if PAGE.RunModal(0, GenJournalBatch) = ACTION::LookupOK then begin
                                Text := GenJournalBatch.Name;
                                exit(true);
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
                        ToolTip = 'Specifies the number of the document that is processed by the report or batch job.';
                    }
                    field(RetainedEarningsAccFld; RetainedEarningsGLAccount."No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Retained Earnings Acc.';
                        TableRelation = "G/L Account" where("Account Type" = const(Posting),
                                                             "Account Category" = filter(" " | Equity),
                                                             "Income/Balance" = const("Balance Sheet"));
                        ToolTip = 'Specifies the retained earnings account that the batch job posts to. This account should be the same as the account that is used by the Close Income Statement batch job.';

                        trigger OnValidate()
                        begin
                            if RetainedEarningsGLAccount."No." <> '' then begin
                                RetainedEarningsGLAccount.Find();
                                RetainedEarningsGLAccount.CheckGLAcc();
                            end;
                        end;
                    }
                    field(PostToRetainedEarningsAccountFld; PostToRetainedEarningsAcc)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Post to Retained Earnings Acc.';
                        OptionCaption = 'Balance,Details';
                        ToolTip = 'Specifies if the resulting entries are posted with the Retained Earnings account as a balancing account on each line (Details) or if retained earnings are posted as an extra line with a summarized amount (Balance).';
                    }
                    field(PostingDescriptionFld; PostingDescription)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posting Description';
                        ToolTip = 'Specifies the description that accompanies the posting.';
                    }
                    field(GLAccountGroupFld; GLAccountGroup)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'G/L Account Group';
                        ToolTip = 'Specifies the type of accounting area, that will be processed in closing operation.';
                    }
                    group("Close by")
                    {
                        Caption = 'Close by';
                        field(ClosePerBusUnitFld; ClosePerBusUnit)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Business Unit Code';
                            ToolTip = 'Specifies the code for the business unit, in a company group structure.';
                        }
                        field(DimensionsFld; ColumnDim)
                        {
                            ApplicationArea = Dimensions;
                            Caption = 'Dimensions';
                            Editable = false;
                            ToolTip = 'Specifies dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                            trigger OnAssistEdit()
                            var
                                TempSelectedDim2: Record "Selected Dimension" temporary;
                                s: Text;
                            begin
                                DimensionSelectionBuffer.SetDimSelectionMultiple(3, Report::"Close Income Statement CZL", ColumnDim);
                                SelectedDimension.GetSelectedDim(CopyStr(UserId(), 1, 50), 3, Report::"Close Income Statement CZL", '', TempSelectedDim2);
                                s := CheckDimPostingRules(TempSelectedDim2);
                                if s <> '' then
                                    Message(s);
                            end;
                        }
                    }
                    field(InventoryPeriodClosedFld; IsInvtPeriodClosed())
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Inventory Period Closed';
                        ToolTip = 'Specifies that the inventory period has been closed.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        var
            GLAccount: Record "G/L Account";
            GLAccountCategory: Record "G/L Account Category";
        begin
            if PostingDescription = '' then
                PostingDescription :=
                  CopyStr(ObjectTranslation.TranslateObject(ObjectTranslation."Object Type"::Report, Report::"Close Income Statement CZL"), 1, 30);
            EndDateReq := 0D;
            AccountingPeriod.SetRange("New Fiscal Year", true);
            AccountingPeriod.SetRange("Date Locked", true);
            if AccountingPeriod.FindLast() then begin
                EndDateReq := AccountingPeriod."Starting Date" - 1;
                if not ValidateEndDate(false) then
                    EndDateReq := 0D;
            end else
                if EndDateReq = 0D then
                    Error(NoFiscalYearsErr);
            ValidateJnl();
            ColumnDim := DimensionSelectionBuffer.GetDimSelectionText(3, Report::"Close Income Statement CZL", '');
            if RetainedEarningsGLAccount."No." = '' then begin
                GLAccountCategory.SetRange("Account Category", GLAccountCategory."Account Category"::Equity);
                GLAccountCategory.SetRange(
                  "Additional Report Definition", GLAccountCategory."Additional Report Definition"::"Retained Earnings");
                if GLAccountCategory.FindFirst() then begin
                    GLAccount.SetRange("Account Subcategory Entry No.", GLAccountCategory."Entry No.");
                    if GLAccount.FindFirst() then
                        RetainedEarningsGLAccount."No." := GLAccount."No.";
                end;
            end;
        end;
    }

    trigger OnPostReport()
    var
        UpdateAnalysisView: Codeunit "Update Analysis View";
    begin
        WindowDialog.Close();
        Commit();
        if GeneralLedgerSetup."Additional Reporting Currency" <> '' then begin
            Message(ClosingEntriesPostedMsg);
            UpdateAnalysisView.UpdateAll(0, true);
        end else
            Message(JournalLinesCreatedMsg);
    end;

    trigger OnPreReport()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        CheckDimResultText: Text;
        IsHandled: Boolean;
    begin
        if EndDateReq = 0D then
            Error(EnterEndingDateErr);
        ValidateEndDate(true);
        if DocNo = '' then
            Error(EnterDocumentNoErr);

        GeneralLedgerSetup.Get();
        SelectedDimension.GetSelectedDim(CopyStr(UserId(), 1, 50), 3, Report::"Close Income Statement CZL", '', TempSelectedDimension);
        IsHandled := false;
        OnPreReportOnBeforeCheckDimPostingRules(IsHandled);
        if not IsHandled then begin
            CheckDimResultText := CheckDimPostingRules(TempSelectedDimension);
            if (CheckDimResultText <> '') and GeneralLedgerSetup."Do Not Check Dimensions CZL" then
                if not ConfirmManagement.GetResponse(CheckDimResultText + ShouldContinueQst, false) then
                    Error('');
        end;

        GenJournalBatch.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name");
        SourceCodeSetup.Get();
        if GeneralLedgerSetup."Additional Reporting Currency" <> '' then begin
            if RetainedEarningsGLAccount."No." = '' then
                Error(EnterRetainedEarningsAccountErr);
            if not ConfirmManagement.GetResponse(AdditionalRepCurrPostingQst, false) then
                Error('');
        end;

        WindowDialog.Open(CreatingJnlDialogTxt + AccountNoDialogTxt + Progress4Tok + PerformingActionDialogTxt + Progress3Tok);

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

        GenJournalLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        if not GenJournalLine.FindLast() then;
        GenJournalLine.Init();
        GenJournalLine."Posting Date" := FiscYearClosingDate;
        GenJournalLine."Document No." := DocNo;
        GenJournalLine.Description := PostingDescription;
        GenJournalLine."Posting No. Series" := GenJournalBatch."Posting No. Series";
        Clear(GenJnlPostLine);
    end;

    var
        AccountingPeriod: Record "Accounting Period";
        SourceCodeSetup: Record "Source Code Setup";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        RetainedEarningsGLAccount: Record "G/L Account";
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionSelectionBuffer: Record "Dimension Selection Buffer";
        ObjectTranslation: Record "Object Translation";
        SelectedDimension: Record "Selected Dimension";
        TempSelectedDimension: Record "Selected Dimension" temporary;
        TempEntryNoAmountBuffer: Record "Entry No. Amount Buffer" temporary;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DimensionManagement: Codeunit DimensionManagement;
        DimensionBufferManagement: Codeunit "Dimension Buffer Management";
        WindowDialog: Dialog;
        FiscalYearStartDate: Date;
        FiscYearClosingDate: Date;
        EndDateReq: Date;
        DocNo: Code[20];
        PostingDescription: Text[100];
        ClosePerBusUnit: Boolean;
        ClosePerGlobalDim1: Boolean;
        ClosePerGlobalDim2: Boolean;
        ClosePerGlobalDimOnly: Boolean;
        TotalAmount: Decimal;
        TotalAmountAddCurr: Decimal;
        ColumnDim: Text[250];
        NoOfAccounts: Integer;
        ThisAccountNo: Integer;
        GLAccountGroup: Enum "G/L Account Group CZL";
        EnterEndingDateErr: Label 'Enter the ending date for the fiscal year.';
        EnterDocumentNoErr: Label 'Enter a Document No.';
        EnterRetainedEarningsAccountErr: Label 'Enter Retained Earnings Account No.';
        AdditionalRepCurrPostingQst: Label 'With the use of an additional reporting currency, this batch job will post closing entries directly to the general ledger. These closing entries will not be transferred to a general journal before the program posts them to the general ledger.\\Do you wish to continue?';
        ShouldContinueQst: Label '\Do you want to continue?';
        CreatingJnlDialogTxt: Label 'Creating general journal lines...\\';
        AccountNoDialogTxt: Label 'Account No.         #1##################\', Comment = '%1 = G/L Account No.';
        PerformingActionDialogTxt: Label 'Now performing      #2##################\', Comment = '%1 = Operation Text';
        Progress3Tok: Label '                    @3@@@@@@@@@@@@@@@@@@\', Comment = '@3 = Progress Ratio';
        Progress4Tok: Label '                    @4@@@@@@@@@@@@@@@@@@\', Comment = '@4 = Progress Ratio';
        CreatingGenJnlLinesTxt: Label 'Creating Gen. Journal lines';
        CalcAmountsTxt: Label 'Calculating Amounts';
        FiscalYearMustBeClosedErr: Label 'The fiscal year must be closed before the income statement can be closed.';
        FiscalYearNotExistErr: Label 'The fiscal year does not exist.';
        JournalLinesCreatedMsg: Label 'The journal lines have successfully been created.';
        ClosingEntriesPostedMsg: Label 'The closing entries have successfully been posted.';
        MandatoryDimTxt: Label 'The following G/L Accounts have mandatory dimension codes that have not been selected:';
        SelectPostingDimTxt: Label '\\In order to post to these accounts you must also select these dimensions:';
        MaxEntry: Integer;
        EntryCount: Integer;
        LastWindowUpdateDateTime: DateTime;
        NoFiscalYearsErr: Label 'No closed fiscal year exists.';
        PostToRetainedEarningsAcc: Option Balance,Details;

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
    var
        NoSeriesBatch: Codeunit "No. Series - Batch";
    begin
        OnBeforeHandleGenJnlLine(GenJournalLine);

        GenJournalLine."Additional-Currency Posting" :=
          GenJournalLine."Additional-Currency Posting"::None;
        if GeneralLedgerSetup."Additional Reporting Currency" <> '' then begin
            GenJournalLine."Source Currency Code" := GeneralLedgerSetup."Additional Reporting Currency";
            if ZeroGenJnlAmount() then begin
                GenJournalLine."Additional-Currency Posting" :=
                  GenJournalLine."Additional-Currency Posting"::"Additional-Currency Amount Only";
                GenJournalLine.Validate(Amount, GenJournalLine."Source Currency Amount");
                GenJournalLine."Source Currency Amount" := 0;
            end;
            if GenJournalLine.Amount <> 0 then begin
                GenJnlPostLine.Run(GenJournalLine);
                if DocNo = NoSeriesBatch.GetNextNo(GenJournalBatch."No. Series", EndDateReq) then
                    NoSeriesBatch.SaveState();
            end;
        end else
            if not ZeroGenJnlAmount() then
                GenJournalLine.Insert();
    end;

    local procedure CalcSumsInFilter(var SourceGLEntry: Record "G/L Entry"; var Offset: Integer)
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.CopyFilters(SourceGLEntry);
        if ClosePerBusUnit then begin
            GLEntry.SetRange("Business Unit Code", SourceGLEntry."Business Unit Code");
            GenJournalLine."Business Unit Code" := SourceGLEntry."Business Unit Code";
        end;
        if ClosePerGlobalDim1 then begin
            GLEntry.SetRange("Global Dimension 1 Code", SourceGLEntry."Global Dimension 1 Code");
            if ClosePerGlobalDim2 then
                GLEntry.SetRange("Global Dimension 2 Code", SourceGLEntry."Global Dimension 2 Code");
        end;

        GLEntry.CalcSums(Amount);
        SourceGLEntry.Amount := GLEntry.Amount;
        TotalAmount += SourceGLEntry.Amount;
        if GeneralLedgerSetup."Additional Reporting Currency" <> '' then begin
            GLEntry.CalcSums("Additional-Currency Amount");
            SourceGLEntry."Additional-Currency Amount" := GLEntry."Additional-Currency Amount";
            TotalAmountAddCurr += SourceGLEntry."Additional-Currency Amount";
        end;
        Offset := GLEntry.Count - 1;
    end;

    local procedure GetGLEntryDimensions(EntryNo: Integer; var DimensionBuffer: Record "Dimension Buffer"; DimensionSetID: Integer)
    var
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        DimensionSetEntry.SetRange("Dimension Set ID", DimensionSetID);
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
        PrevAcc: Code[20];
        ErrorText: Text;
        DimText: Text;
        Handled: Boolean;
    begin
        OnBeforeCheckDimPostingRules(SelectedDimension, ErrorText, Handled, GenJournalLine);
        if Handled then
            exit(ErrorText);

        DefaultDimension.SetRange("Table ID", Database::"G/L Account");
        DefaultDimension.SetFilter(
          "Value Posting", '%1|%2',
          DefaultDimension."Value Posting"::"Same Code", DefaultDimension."Value Posting"::"Code Mandatory");
        Clear(PrevAcc);
        if DefaultDimension.FindSet() then
            repeat
                SelectedDimension.SetRange("Dimension Code", DefaultDimension."Dimension Code");
                if not SelectedDimension.FindFirst() then begin
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

    local procedure IsInvtPeriodClosed(): Boolean
    var
        ClosedAccountingPeriod: Record "Accounting Period";
        ClosedInventoryPeriod: Record "Inventory Period";
    begin
        if EndDateReq = 0D then
            exit;
        ClosedAccountingPeriod."Starting Date" := EndDateReq + 1;
        ClosedAccountingPeriod.Find();
        ClosedAccountingPeriod.Next(-1);
        exit(ClosedInventoryPeriod.IsInvtPeriodClosed(ClosedAccountingPeriod."Starting Date"));
    end;

    procedure InitializeRequestTest(EndDate: Date; GenJournalLine: Record "Gen. Journal Line"; GLAccount: Record "G/L Account"; CloseByBU: Boolean)
    begin
        EndDateReq := EndDate;
        GenJournalLine := GenJournalLine;
        ValidateJnl();
        RetainedEarningsGLAccount := GLAccount;
        ClosePerBusUnit := CloseByBU;
    end;

    local procedure ZeroGenJnlAmount(): Boolean
    begin
        exit((GenJournalLine.Amount = 0) and (GenJournalLine."Source Currency Amount" <> 0))
    end;

    local procedure GroupSum(): Boolean
    begin
        exit(ClosePerGlobalDimOnly and (ClosePerBusUnit or ClosePerGlobalDim1));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDimPostingRules(var SelectedDimension: Record "Selected Dimension"; var ErrorText: Text; var Handled: Boolean; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPreReportOnBeforeCheckDimPostingRules(var IsHandled: Boolean)
    begin
    end;
}
