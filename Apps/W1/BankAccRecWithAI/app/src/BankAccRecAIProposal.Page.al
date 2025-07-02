namespace Microsoft.Bank.Reconciliation;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Bank.Statement;
using System.IO;
using System.Telemetry;

page 7250 "Bank Acc. Rec. AI Proposal"
{
    Caption = 'Reconcile with Copilot';
    DataCaptionExpression = PageCaptionLbl;
    PageType = PromptDialog;
    IsPreview = false;
    Extensible = false;
    ApplicationArea = All;
    Editable = true;
    SourceTable = "Bank Acc. Rec. AI Proposal";
    SourceTableTemporary = true;
    Permissions = tabledata "Data Exch." = rimd;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Prompt)
        {
            field(ChooseBankAccount; BankAccNo)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the bank account number';
                Caption = 'Perform reconciliation for this bank account';
                Editable = false;

                trigger OnAssistEdit()
                var
                    BankAccount: Record "Bank Account";
                    BankAccountList: Page "Bank Account List";
                begin
                    if DisableAttachItButton then
                        exit;

                    if FileName <> '' then
                        exit;

                    BankAccount.SetFilter("Bank Statement Import Format", '<>''''');
                    case BankAccount.Count() of
                        0:
                            if Confirm(NoBankAccountWithImportFormatQst) then
                                Page.Run(Page::"Bank Account List");
                        1:
                            begin
                                BankAccount.FindFirst();
                                BankAccNo := BankAccount."No.";
                                if Confirm(OnlyOneWithImportFormatQst) then
                                    Page.Run(Page::"Bank Account List");
                            end;
                        else begin
                            BankAccountList.SetTableView(BankAccount);
                            BankAccountList.LookupMode := true;
                            if BankAccountList.RunModal() = ACTION::LookupOK then begin
                                BankAccountList.GetRecord(BankAccount);
                                BankAccNo := BankAccount."No.";
                            end;
                        end;
                    end;
                    FileName := '';
                    ImportTransactionDataValueTxt := ImportTransactionDataLbl;
                    CurrPage.Update();
                end;
            }

            field(ImportTransactionData; ImportTransactionDataValueTxt)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies how to import transaction data';
                Caption = 'Use transaction data from';
                Visible = (not DisableAttachItButton);
                Editable = false;

                trigger OnDrillDown()
                begin
                    ImportTransactionsIntoBankAccountReconciliation();
                end;
            }
            group(StatementInfo)
            {
                Caption = '';
                ShowCaption = false;
                Visible = (StatementNo <> '');

                field("Statement Date"; StatementDate)
                {
                    ApplicationArea = All;
                    Caption = 'Statement Date';
                    Editable = StatementNo <> '';
                    ToolTip = 'Specifies the bank statement date';

                    trigger OnValidate()
                    var
                        LocalBankAccReconciliation: Record "Bank Acc. Reconciliation";
                    begin
                        if LocalBankAccReconciliation.Get(LocalBankAccReconciliation."Statement Type"::"Bank Reconciliation", BankAccNo, StatementNo) then begin
                            LocalBankAccReconciliation."Statement Date" := StatementDate;
                            LocalBankAccReconciliation.Modify(true);
                        end;
                    end;
                }
                field("Statement No."; StatementNo)
                {
                    ApplicationArea = All;
                    Caption = 'Statement No.';
                    Editable = false;
                    ToolTip = 'Specifies the bank statement number';
                }
            }
        }
        area(Content)
        {
            group(BankAccRecHeader)
            {
                Caption = ' ';
                ShowCaption = false;

                field("Auto-matched Lines"; AutoMatchedLinesTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Auto-matched';
                    Editable = false;
                    ToolTip = 'Specifies the number of automatic matches created and saved by Business Central';

                    trigger OnDrillDown()
                    var
                        BankAccReconciliation: Record "Bank Acc. Reconciliation";
                    begin
                        BankAccReconciliation.SetRange("Statement Type", Rec."Statement Type"::"Bank Reconciliation");
                        BankAccReconciliation.SetRange("Bank Account No.", BankAccNo);
                        BankAccReconciliation.SetRange("Statement No.", StatementNo);
                        if BankAccReconciliation.FindFirst() then
                            Page.Run(Page::"Bank Acc. Reconciliation", BankAccReconciliation);
                    end;
                }
                field("Lines matched by Copilot"; LinesMatchedByCopilotTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Copilot matched';
                    Editable = false;
                    ToolTip = 'Specifies the number of matches proposed by Copilot';
                }
                field("Summary Text"; SummaryTxt)
                {
                    ApplicationArea = All;
                    Caption = '';
                    ShowCaption = false;
                    Editable = false;
                    StyleExpr = SummaryStyleTxt;
                    ToolTip = 'Specifies the matching summary';
                }
                field("Statement Ending Balance"; StatementEndingBalance)
                {
                    ApplicationArea = All;
                    Caption = 'Statement Ending Balance';
                    Editable = true;
                    ToolTip = 'Specifies the ending balance shown on the bank''s statement that you want to reconcile with the bank account.';

                    trigger OnValidate()
                    var
                        LocalBankAccReconciliation: Record "Bank Acc. Reconciliation";
                    begin
                        if LocalBankAccReconciliation.Get(LocalBankAccReconciliation."Statement Type"::"Bank Reconciliation", BankAccNo, StatementNo) then begin
                            LocalBankAccReconciliation."Statement Ending Balance" := StatementEndingBalance;
                            LocalBankAccReconciliation.Modify();
                        end;
                    end;
                }
                group(Posting)
                {
                    Caption = ' ';
                    ShowCaption = false;
                    Visible = ShouldAskToOpenBankRecOnOK;

                    field("Post if fully Applied"; PostIfFullyApplied)
                    {
                        ApplicationArea = All;
                        Caption = 'Post if fully applied';
                        Editable = PostIfFullyAppliedEditable;
                        ToolTip = 'Specifies if the bank account reconciliation should be posted if it gets fully applied by the matching proposals.';
                    }
                }
            }
            group(Warning)
            {
                Caption = '';
                ShowCaption = false;
                Visible = (WarningTxt <> '');

                field("Warning Text"; WarningTxt)
                {
                    ApplicationArea = All;
                    Caption = '';
                    ShowCaption = false;
                    Editable = false;
                    Style = Ambiguous;
                    MultiLine = true;
                    ToolTip = 'Specifies a warning text';
                }
            }
            part(ProposalDetails; "Bank Acc. Rec. AI Proposal Sub")
            {
                Caption = 'Match proposals';
                ShowFilter = false;
                ApplicationArea = All;
                Editable = true;
                Enabled = true;
            }
        }

    }

    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Generate';
                Enabled = ((FileName <> '') or SkipNativeAutoMatchingAlgorithm);
                ToolTip = 'Generate bank account reconciliation and run auto-matching with Copilot.';

                trigger OnAction()
                begin
                    AutoMatchWithCopilot();
                end;

            }
            systemaction(Attach)
            {
                Caption = '';
                Enabled = ((BankAccNo <> '') and (not DisableAttachItButton));
                ToolTip = 'Import bank transaction data either from a file or via an online bank statement provider';

                trigger OnAction()
                begin
                    ImportTransactionsIntoBankAccountReconciliation();
                end;
            }
            systemaction(OK)
            {
                Caption = 'Keep it';
                ToolTip = 'Save bank account reconciliation matches proposed by Copilot.';
            }
            systemaction(Cancel)
            {
                Caption = 'Discard it';
                ToolTip = 'Discard bank account reconciliation matches proposed by Copilot.';
            }
        }
    }

    trigger OnOpenPage()
    var
        BankAccount: Record "Bank Account";
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
    begin
        if BankAccNo <> '' then
            exit;

        BankAccount.SetFilter("Bank Statement Import Format", '<>''''');
        if BankAccount.Count() = 1 then
            if BankAccount.FindFirst() then begin
                BankAccNo := BankAccount."No.";
                Session.LogMessage('0000LEE', TelemetryAutoSelectingBankAccountTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', BankRecAIMatchingImpl.FeatureName());
                ImportTransactionDataValueTxt := ImportTransactionDataLbl;
                CurrPage.Update();
            end;

        SummaryStyleTxt := 'Ambiguous';
        CurrPage.ProposalDetails.Page.SetProposalFieldCaption(ProposalTxt);
    end;

    local procedure AutoMatchWithCopilot()
    var
        BankAccount: Record "Bank Account";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        MatchBankRecLines: Codeunit "Match Bank Rec. Lines";
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
    begin
        if BankAccNo = '' then begin
            Session.LogMessage('0000LEF', TelemetryUserInvokingCopilotMatchingNoBankAccountTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', BankRecAIMatchingImpl.FeatureName());
            exit;
        end;

        if not BankAccount.Get(BankAccNo) then begin
            Session.LogMessage('0000LEG', TelemetryUserInvokingCopilotMatchingInvalidBankAccountTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', BankRecAIMatchingImpl.FeatureName());
            exit;
        end;

        if not BankAccReconciliation.Get(BankAccReconciliation."Statement Type"::"Bank Reconciliation", BankAccount."No.", StatementNo) then begin
            Session.LogMessage('0000LEH', TelemetryUserInvokingCopilotMatchingInvalidBankAccountReconciliationTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', BankRecAIMatchingImpl.FeatureName());
            exit;
        end;

        if not SkipNativeAutoMatchingAlgorithm then
            MatchBankRecLines.BankAccReconciliationAutoMatch(BankAccReconciliation, DaysTolerance, false, false); // do not raise FindBestMatches event, do not show match summary.

        BankAccountLedgerEntry.SetBankReconciliationCandidatesFilter(BankAccReconciliation);
        MatchBankRecLines.InitializeBLEMatchingTempTable(TempBankAccLedgerEntryMatchingBuffer, BankAccountLedgerEntry);
        BankAccReconciliationLine.Reset();
        BankAccReconciliationLine.FilterBankRecLinesByDate(BankAccReconciliation, false);
        GenerateCopilotMatchProposals();
        if not Rec.Insert() then
            Rec.Modify();
        PageCaptionLbl := StrSubstNo(ContentAreaCaptionTxt, BankAccNo, StatementNo, StatementDate);
    end;

    local procedure ImportTransactionsIntoBankAccountReconciliation()
    var
        BankAccount: Record "Bank Account";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        DataExch: Record "Data Exch.";
        LocalBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        OnlineBankStatementFeed: Boolean;
        TelemetryCategories: Dictionary of [Text, Text];
    begin
        Session.LogMessage('0000LEI', TelemetryUserImportingBankStatementTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', BankRecAIMatchingImpl.FeatureName());

        if BankAccNo = '' then begin
            Session.LogMessage('0000LEJ', TelemetryUserImportingBankStatementNoBankAccountTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', BankRecAIMatchingImpl.FeatureName());
            exit;
        end;

        if not BankAccount.Get(BankAccNo) then begin
            Session.LogMessage('0000LEK', TelemetryUserImportingBankStatementInvalidBankAccountTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', BankRecAIMatchingImpl.FeatureName());
            exit;
        end;

        if not BankAccReconciliation.Get(BankAccReconciliation."Statement Type"::"Bank Reconciliation", BankAccount."No.", StatementNo) then begin
            BankAccReconciliation.Validate("Statement Type", BankAccReconciliation."Statement Type"::"Bank Reconciliation");
            BankAccReconciliation.Validate("Bank Account No.", BankAccount."No.");
            BankAccReconciliation.Insert(true);
            StatementNo := BankAccReconciliation."Statement No.";
        end;
        LocalBankAccReconciliationLine.SetRange("Statement Type", BankAccReconciliation."Statement Type"::"Bank Reconciliation");
        LocalBankAccReconciliationLine.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        LocalBankAccReconciliationLine.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        if not LocalBankAccReconciliationLine.IsEmpty() then begin
            Session.LogMessage('0000LEL', TelemetryUserReImportingBankStatementTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', BankRecAIMatchingImpl.FeatureName(), 'BankAccountReconciliationId', BankAccReconciliation.SystemId);
            LocalBankAccReconciliationLine.DeleteAll();
        end;

        Commit();
        BankAccReconciliation.ImportBankStatement();
        if not LocalBankAccReconciliationLine.IsEmpty() then begin
            LocalBankAccReconciliationLine.SetCurrentKey("Transaction Date");
            LocalBankAccReconciliationLine.SetAscending("Transaction Date", false);
            LocalBankAccReconciliationLine.FindFirst();
            BankAccReconciliation."Statement Date" := LocalBankAccReconciliationLine."Transaction Date";
            BankAccReconciliation.Modify();
        end;
        StatementDate := BankAccReconciliation."Statement Date";
        DaysTolerance := 1;
        BalanceLastStatement := BankAccReconciliation."Balance Last Statement";
        if BankAccReconciliation."Statement Ending Balance" <> 0 then
            StatementEndingBalance := BankAccReconciliation."Statement Ending Balance"
        else begin
            StatementEndingBalance := BalanceLastStatement;
            if LocalBankAccReconciliationLine.FindSet() then
                repeat
                    StatementEndingBalance += LocalBankAccReconciliationLine."Statement Amount";
                until LocalBankAccReconciliationLine.Next() = 0;
            BankAccReconciliation."Statement Ending Balance" := StatementEndingBalance;
            BankAccReconciliation.Modify();
        end;

        if DataExch.Get(LocalBankAccReconciliationLine."Data Exch. Entry No.") then begin
            FileName := DataExch."File Name";
            if BankAccount.IsLinkedToBankStatementServiceProvider() then begin
                OnlineBankStatementFeed := true;
                ImportTransactionDataValueTxt := OnlineBankTransactionFeedLbl
            end
            else
                ImportTransactionDataValueTxt := FileName;
        end;
        FeatureTelemetry.LogUptake('0000LED', BankRecAIMatchingImpl.FeatureName(), Enum::"Feature Uptake Status"::"Set up");
        TelemetryCategories.Add('Category', BankRecAIMatchingImpl.FeatureName());
        TelemetryCategories.Add('BankAccountReconciliationId', Format(BankAccReconciliation.SystemId));
        TelemetryCategories.Add('IsOnlineBankStatementFeed', Format(OnlineBankStatementFeed));
        Session.LogMessage('0000LEM', TelemetryUserImportingBankStatementSuccessTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryCategories);
        CurrPage.Update();
    end;

    local procedure GenerateCopilotMatchProposals()
    var
        LocalBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        LocalBankAccReconciliation: Record "Bank Acc. Reconciliation";
        TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary;
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TelemetryDimensions: Dictionary of [Text, Text];
        Pct: Decimal;
    begin
        BankRecAIMatchingImpl.GenerateMatchProposals(TempBankAccRecAIProposal, BankAccReconciliationLine, TempBankAccLedgerEntryMatchingBuffer, TempBankStatementMatchingBuffer, DaysTolerance);
        ProposedLines := CurrPage.ProposalDetails.Page.Load(TempBankAccRecAIProposal);
        LocalBankAccReconciliationLine.SetRange("Statement Type", LocalBankAccReconciliationLine."Statement Type"::"Bank Reconciliation");
        LocalBankAccReconciliationLine.SetRange("Statement No.", StatementNo);
        LocalBankAccReconciliationLine.SetRange("Bank Account No.", BankAccNo);
        TotalLines := LocalBankAccReconciliationLine.Count();
        LocalBankAccReconciliationLine.SetFilter("Applied Entries", '>0');
        AppliedLinesUpFront := LocalBankAccReconciliationLine.Count();
        Pct := Round((AppliedLinesUpFront / TotalLines) * 100, 0.1);
        AutoMatchedLinesTxt := StrSubstNo(AutoMatchedLinesLbl, AppliedLinesUpFront, TotalLines, Pct);
        Pct := Round((ProposedLines / TotalLines) * 100, 0.1);
        LinesMatchedByCopilotTxt := StrSubstNo(AutoMatchedLinesLbl, ProposedLines, TotalLines, Pct);
        PostIfFullyAppliedEditable := (TotalLines <= ProposedLines + AppliedLinesUpFront);
        if PostIfFullyAppliedEditable then begin
            SummaryStyleTxt := 'Favorable';
            SummaryTxt := AllLinesMatchedTxt;
        end
        else begin
            Pct := Round(((AppliedLinesUpFront + ProposedLines) / TotalLines) * 100, 0.1);
            SummaryStyleTxt := 'Ambiguous';
            SummaryTxt := StrSubstNo(SubsetOfLinesMatchedTxt, Pct);
        end;
        if BankRecAIMatchingImpl.FoundInputWithReservedWords() then
            WarningTxt := InputWithReservedWordsRemovedTxt;
        TelemetryDimensions.Add('Category', BankRecAIMatchingImpl.FeatureName());
        TelemetryDimensions.Add('TotalLines', Format(TotalLines));
        TelemetryDimensions.Add('AppliedLinesUpFront', Format(AppliedLinesUpFront));
        TelemetryDimensions.Add('ProposedLines', Format(ProposedLines));
        if LocalBankAccReconciliation.Get(LocalBankAccReconciliation."Statement Type"::"Bank Reconciliation", StatementNo, BankAccNo) then begin
            StatementDate := LocalBankAccReconciliation."Statement Date";
            TelemetryDimensions.Add('BankAccReconciliationId', Format(LocalBankAccReconciliation.SystemId));
        end;
        CurrPage.Update();
        Session.LogMessage('0000LEN', TelemetryCopilotProposedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDimensions);
        FeatureTelemetry.LogUsage('0000PGU', BankRecAIMatchingImpl.FeatureName(), TelemetryCopilotProposedTxt);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        LocalBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        LocalBankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccountStatement: Record "Bank Account Statement";
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TelemetryDimensions: Dictionary of [Text, Text];
        OpenCardQuestion: Text;
    begin
        TelemetryDimensions.Add('Category', BankRecAIMatchingImpl.FeatureName());
        TelemetryDimensions.Add('TotalLines', Format(TotalLines));
        TelemetryDimensions.Add('AppliedLinesUpFront', Format(AppliedLinesUpFront));
        TelemetryDimensions.Add('ProposedLines', Format(ProposedLines));
        TelemetryDimensions.Add('AcceptedProposalCount', Format(AcceptedProposalCount));
        if CloseAction = CloseAction::OK then begin
            ApplyToProposedLedgerEntries();
            if LocalBankAccReconciliation.Get(LocalBankAccReconciliation."Statement Type"::"Bank Reconciliation", BankAccNo, StatementNo) then begin
                OpenCardQuestion := OpenBankRecCardQst;
                if PostIfFullyApplied then begin
                    TelemetryDimensions.Add('BankAccReconciliationId', Format(LocalBankAccReconciliation.SystemId));
                    Session.LogMessage('0000LEO', TelemetryUserAttemptedToPostFromProposalsPageTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDimensions);
                    LocalBankAccReconciliationLine.SetRange("Statement Type", LocalBankAccReconciliationLine."Statement Type"::"Bank Reconciliation");
                    LocalBankAccReconciliationLine.SetRange("Statement No.", StatementNo);
                    LocalBankAccReconciliationLine.SetRange("Bank Account No.", BankAccNo);
                    LocalBankAccReconciliationLine.SetFilter(Difference, '<>0');
                    if LocalBankAccReconciliationLine.IsEmpty() then begin
                        Commit();
                        Codeunit.Run(Codeunit::"Bank Acc. Reconciliation Post", LocalBankAccReconciliation);
                        if BankAccountStatement.Get(BankAccNo, StatementNo) then begin
                            TelemetryDimensions.Add('BankAccountStatementId', Format(BankAccountStatement.SystemId));
                            Session.LogMessage('0000LEP', TelemetryUserSuccessfullyPostedFromProposalsPageTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDimensions);
                            if Confirm(SuccessfullPostedQst) then
                                Page.Run(Page::"Bank Account Statement", BankAccountStatement);
                            exit;
                        end
                    end
                    else begin
                        Session.LogMessage('0000LEQ', TelemetryUserAttemptedToPostFromProposalsPageNotFullyAppliedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDimensions);
                        OpenCardQuestion := OpenBankRecCardUnappliedLinesQst;
                    end;
                end;
                if ShouldAskToOpenBankRecOnOK then
                    if Confirm(OpenCardQuestion) then
                        Page.Run(Page::"Bank Acc. Reconciliation", LocalBankAccReconciliation);
            end
        end
        else begin
            if LocalBankAccReconciliation.Get(LocalBankAccReconciliation."Statement Type"::"Bank Reconciliation", BankAccNo, StatementNo) then
                TelemetryDimensions.Add('BankAccReconciliationId', Format(LocalBankAccReconciliation.SystemId));
            Session.LogMessage('0000LER', TelemetryUserNotAcceptedProposalsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDimensions);
            FeatureTelemetry.LogUsage('0000PGV', BankRecAIMatchingImpl.FeatureName(), TelemetryUserAcceptedProposalsTxt);
            if ShouldDeleteBankRecOnCancel then
                if LocalBankAccReconciliation.Delete(true) then;
        end;
    end;

    local procedure ApplyToProposedLedgerEntries()
    var
        TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary;
        LocalBankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        CurrPage.ProposalDetails.Page.GetTempRecord(TempBankAccRecAIProposal);
        AcceptedProposalCount := BankRecAIMatchingImpl.ApplyToProposedLedgerEntries(TempBankAccRecAIProposal, TempBankStatementMatchingBuffer);
        TelemetryDimensions.Add('Category', BankRecAIMatchingImpl.FeatureName());
        TelemetryDimensions.Add('TotalLines', Format(TotalLines));
        TelemetryDimensions.Add('AppliedLinesUpFront', Format(AppliedLinesUpFront));
        TelemetryDimensions.Add('ProposedLines', Format(ProposedLines));
        TelemetryDimensions.Add('AcceptedProposalCount', Format(AcceptedProposalCount));
        LocalBankAccReconciliation.SetLoadFields(SystemId);
        if LocalBankAccReconciliation.Get(LocalBankAccReconciliation."Statement Type"::"Bank Reconciliation", BankAccNo, StatementNo) then
            TelemetryDimensions.Add('BankAccReconciliationId', Format(LocalBankAccReconciliation.SystemId));
        Session.LogMessage('0000LES', TelemetryUserAcceptedProposalsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDimensions);
        FeatureTelemetry.LogUsage('0000PGW', BankRecAIMatchingImpl.FeatureName(), TelemetryUserAcceptedProposalsTxt);
    end;

    internal procedure SetBankAccReconciliationLines(var InputBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line");
    begin
        BankAccReconciliationLine.Copy(InputBankAccReconciliationLine);
    end;

    internal procedure SetTempBankAccLedgerEntryMatchingBuffer(var InputTempBankAccLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary);
    begin
        if not InputTempBankAccLedgerEntryMatchingBuffer.IsEmpty() then
            TempBankAccLedgerEntryMatchingBuffer.Copy(InputTempBankAccLedgerEntryMatchingBuffer, true);
    end;

    internal procedure SetDisableAttachItButton(InputDisableAttachItButton: Boolean);
    begin
        DisableAttachItButton := InputDisableAttachItButton;
    end;

    internal procedure SetSkipNativeAutoMatchingAlgorithm(InputSkipNativeAutoMatchingAlgorithm: Boolean);
    begin
        SkipNativeAutoMatchingAlgorithm := InputSkipNativeAutoMatchingAlgorithm;
    end;

    internal procedure SetDaysTolerance(InputDaysTolerance: Integer);
    begin
        DaysTolerance := InputDaysTolerance;
    end;

    internal procedure SetBankAccountNo(InputBankAccountNo: Code[20]);
    begin
        BankAccNo := InputBankAccountNo;
    end;

    internal procedure SetStatementNo(InputStatementNo: Code[20]);
    begin
        StatementNo := InputStatementNo;
    end;

    internal procedure SetStatementDate(InputStatementDate: Date);
    begin
        StatementDate := InputStatementDate;
    end;

    internal procedure SetBalanceLastStatement(InputBalanceLastStatement: Decimal);
    begin
        BalanceLastStatement := InputBalanceLastStatement;
    end;

    internal procedure SetStatementEndingBalance(InputStatementEndingBalance: Decimal);
    begin
        StatementEndingBalance := InputStatementEndingBalance;
    end;

    internal procedure SetGenerateMode();
    begin
        CurrPage.PromptMode := PromptMode::Generate;
    end;

    internal procedure SetShouldAskToOpenBankRecOnOK(InputShouldAskToOpenBankRec: Boolean);
    begin
        ShouldAskToOpenBankRecOnOK := InputShouldAskToOpenBankRec;
    end;

    internal procedure SetShouldDeleteBankRecOnCancel(InputShouldDeleteBankRecOnCancel: Boolean);
    begin
        ShouldDeleteBankRecOnCancel := InputShouldDeleteBankRecOnCancel;
    end;

    internal procedure SetPageCaption(InputPageCaption: Text);
    begin
        PageCaptionLbl := InputPageCaption;
    end;

    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        TempBankAccLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary;
        TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary;
        AutoMatchedLinesTxt: Text;
        LinesMatchedByCopilotTxt: Text;
        AutoMatchedLinesLbl: label '%1 of %2 lines (%3%)', Comment = '%1 - an integer; %2 - an integer; %3 a decimal between 0 and 100';
        PageCaptionLbl: Text;
        OnlineBankTransactionFeedLbl: label 'Online bank transaction feed';
        OpenBankRecCardUnappliedLinesQst: label 'There are still unapplied lines in the bank account reconciliation. Do you want to open it now?';
        OpenBankRecCardQst: label 'The bank account reconciliation is not posted yet. Do you want to open it now?';
        SuccessfullPostedQst: label 'The bank account reconciliation is posted successfully. Do you want to view the posted bank reconciliation details?';
        NoBankAccountWithImportFormatQst: label 'You must specify a bank statement import format on at least one bank account. Open the card of a bank account and either choose action ''Link to Online Bank Account'' or let the notification guide you how to set up a file import format. Do you want to open the Bank Accounts list?';
        OnlyOneWithImportFormatQst: label 'The selected bank account is the only one with a bank statement import format. To set up bank statement import format for another bank account, Open its card and either choose action ''Link to Online Bank Account'' or let the notification guide you how to set up a file import format. Do you want to open the Bank Accounts list?';
        ImportTransactionDataLbl: label 'Import transaction data...';
        TelemetryCopilotProposedTxt: label 'Copilot proposed matches of statement lines to bank account ledger entries', Locked = true;
        TelemetryUserAcceptedProposalsTxt: label 'User accepted Copilot proposals for matching statement lines with ledger entries', Locked = true;
        TelemetryUserNotAcceptedProposalsTxt: label 'User closed Copilot proposals page without accepting', Locked = true;
        TelemetryUserAttemptedToPostFromProposalsPageTxt: label 'User attempted to post from proposals page.', Locked = true;
        TelemetryUserAttemptedToPostFromProposalsPageNotFullyAppliedTxt: label 'User attempted to post from proposals page, but there are still unapplied amounts.', Locked = true;
        TelemetryUserSuccessfullyPostedFromProposalsPageTxt: label 'User posted the bank account reconciliation from proposals page.', Locked = true;
        TelemetryUserInvokingCopilotMatchingNoBankAccountTxt: label 'User invoking Copilot matching with no bank account chosen.', Locked = true;
        TelemetryUserInvokingCopilotMatchingInvalidBankAccountTxt: label 'User invoking Copilot matching with invalid bank account no.', Locked = true;
        TelemetryUserInvokingCopilotMatchingInvalidBankAccountReconciliationTxt: label 'User invoking Copilot matching with invalid bank account reconciliation no.', Locked = true;
        TelemetryAutoSelectingBankAccountTxt: label 'User has only one bank account with Bank Statement Import Format - auto-picking that bank account.';
        TelemetryUserImportingBankStatementNoBankAccountTxt: label 'User trying to import bank statement with no bank account chosen.', Locked = true;
        TelemetryUserImportingBankStatementInvalidBankAccountTxt: label 'User trying to import bank statement with invalid bank account no.', Locked = true;
        TelemetryUserReImportingBankStatementTxt: label 'User trying to re-import bank statement.', Locked = true;
        TelemetryUserImportingBankStatementTxt: label 'User trying to import bank statement.', Locked = true;
        TelemetryUserImportingBankStatementSuccessTxt: label 'User successfully imported bank statement.', Locked = true;
        ContentAreaCaptionTxt: label 'Reconciling %1 statement %2 for %3', Comment = '%1 - bank account code, %2 - statement number, %3 - statement date';
        AllLinesMatchedTxt: label 'All lines (100%) are matched. Review match proposals.';
        SubsetOfLinesMatchedTxt: label '%1% of lines are matched. Review match proposals.', Comment = '%1 - a decimal between 0 and 100';
        InputWithReservedWordsRemovedTxt: label 'Statement line descriptions or ledger entry descriptions with reserved AI chat completion prompt words were detected. For security reasons, they were excluded from the auto-matching process. You must match these statement lines or ledger entries manually.';
        ProposalTxt: label 'Match Entry';
        StatementDate: Date;
        BalanceLastStatement: Decimal;
        StatementEndingBalance: Decimal;
        BankAccNo: Code[20];
        StatementNo: Code[20];
        DaysTolerance: Integer;
        FileName: Text[250];
        DisableAttachItButton: Boolean;
        SkipNativeAutoMatchingAlgorithm: Boolean;
        ImportTransactionDataValueTxt: Text;
        PostIfFullyApplied: Boolean;
        ProposedLines: Integer;
        AcceptedProposalCount: Integer;
        TotalLines: Integer;
        AppliedLinesUpFront: Integer;
        ShouldAskToOpenBankRecOnOK: Boolean;
        ShouldDeleteBankRecOnCancel: Boolean;
        PostIfFullyAppliedEditable: Boolean;
        SummaryTxt: Text;
        SummaryStyleTxt: Text;
        WarningTxt: Text;
}