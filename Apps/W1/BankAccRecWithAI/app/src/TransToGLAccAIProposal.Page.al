namespace Microsoft.Bank.Reconciliation;

using Microsoft.Bank.Statement;
using Microsoft.Finance.GeneralLedger.Journal;

page 7252 "Trans. To GL Acc. AI Proposal"
{
    Caption = 'Copilot Proposals for Posting Differences to G/L Accounts';
    DataCaptionExpression = PageCaptionLbl;
    PageType = PromptDialog;
    IsPreview = false;
    Extensible = false;
    PromptMode = Generate;
    ApplicationArea = All;
    Editable = true;
    SourceTable = "Bank Acc. Rec. AI Proposal";
    SourceTableTemporary = true;
    InherentPermissions = X;
    InherentEntitlements = X;

    layout
    {
        area(Prompt)
        {
            field("BankAccountNo"; BankAccNo)
            {
                ApplicationArea = All;
                Caption = 'Bank Account No.';
                Editable = false;
                ToolTip = 'Specifies the bank account number';
            }
            field("Statement Date"; StatementDate)
            {
                ApplicationArea = All;
                Caption = 'Statement Date';
                Editable = true;
                ToolTip = 'Specifies the bank statement date';
            }
            field("Statement No."; StatementNo)
            {
                ApplicationArea = All;
                Caption = 'Statement No.';
                Editable = false;
                ToolTip = 'Specifies the bank statement number';
            }
        }
        area(Content)
        {
            group(BankAccRecHeader)
            {
                Caption = ' ';
                ShowCaption = false;

                field(AutoMatchedLines; AutoMatchedLinesTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Auto-matched';
                    Editable = false;
                    ToolTip = 'Specifies the automatic matches created and saved by Business Central';

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
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the template for the journal batch in which the proposed payments will be created.';

                    trigger OnValidate()
                    var
                        GenJournalBatch: Record "Gen. Journal Batch";
                    begin
                        GenJournalBatch.SetRange("Journal Template Name", Rec."Journal Template Name");
                        if GenJournalBatch.Count() = 1 then begin
                            GenJournalBatch.FindFirst();
                            Rec."Journal Batch Name" := GenJournalBatch.Name;
                            JournalBatchName := GenJournalBatch.Name;
                        end
                        else begin
                            Rec."Journal Batch Name" := '';
                            JournalBatchName := '';
                        end;
                        JournalTemplateName := Rec."Journal Template Name";
                        Rec.Modify();
                    end;
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the journal batch in which the proposed payments will be created.';

                    trigger OnValidate()
                    begin
                        JournalBatchName := Rec."Journal Batch Name";
                        Rec.Modify();
                    end;
                }
                group(Posting)
                {
                    Caption = ' ';
                    ShowCaption = false;
                    Visible = false;

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
                Enabled = (BankAccNo <> '');
                ToolTip = 'Generate bank accout reconciliation and run auto-matching with Copilot.';

                trigger OnAction()
                begin
                    GenerateTransferToGLAccountProposals();
                end;
            }
            systemaction(OK)
            {
                Caption = 'Keep it';
                ToolTip = 'Post the difference amounts to G/L Accounts as proposed by Copilot.';
                Enabled = (JournalTemplateName <> '') and (JournalBatchName <> '');
            }
            systemaction(Cancel)
            {
                Caption = 'Discard it';
                ToolTip = 'Discard the Copilot proposals for posting difference amounts to G/L Accounts.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        SummaryStyleTxt := 'Ambiguous';
    end;

    local procedure InitializeJournalBatch()
    var
        TransToGLAccJnlBatch: Record "Trans. to G/L Acc. Jnl. Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        if TransToGLAccJnlBatch.FindFirst() then
            if GenJournalTemplate.Get(TransToGLAccJnlBatch."Journal Template Name") then begin
                Rec."Journal Template Name" := GenJournalTemplate.Name;
                JournalTemplateName := GenJournalTemplate.Name;
                if GenJournalBatch.Get(GenJournalTemplate.Name, TransToGLAccJnlBatch."Journal Batch Name") then begin
                    Rec."Journal Batch Name" := GenJournalBatch.Name;
                    JournalBatchName := GenJournalBatch.Name;
                end;
            end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        LocalBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        LocalBankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccountStatement: Record "Bank Account Statement";
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        TelemetryDimensions.Add('Category', BankRecAIMatchingImpl.FeatureName());
        TelemetryDimensions.Add('TotalLines', Format(TotalLines));
        TelemetryDimensions.Add('AppliedLinesUpFront', Format(AppliedLinesUpFront));
        TelemetryDimensions.Add('ProposedLines', Format(ProposedLines));
        TelemetryDimensions.Add('AcceptedProposalCount', Format(AcceptedProposalCount));
        if CloseAction = CloseAction::OK then begin
            PostNewPaymentsToProposedGLAccounts();
            if PostIfFullyApplied then
                if LocalBankAccReconciliation.Get(LocalBankAccReconciliation."Statement Type"::"Bank Reconciliation", BankAccNo, StatementNo) then begin
                    TelemetryDimensions.Add('BankAccReconciliationId', Format(LocalBankAccReconciliation.SystemId));
                    Session.LogMessage('0000LF8', TelemetryUserAttemptedToPostFromProposalsPageTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDimensions);
                    LocalBankAccReconciliationLine.SetRange("Statement Type", LocalBankAccReconciliationLine."Statement Type"::"Bank Reconciliation");
                    LocalBankAccReconciliationLine.SetRange("Statement No.", StatementNo);
                    LocalBankAccReconciliationLine.SetRange("Bank Account No.", BankAccNo);
                    LocalBankAccReconciliationLine.SetFilter(Difference, '<>0');
                    if LocalBankAccReconciliationLine.IsEmpty() then begin
                        Commit();
                        Codeunit.Run(Codeunit::"Bank Acc. Reconciliation Post", LocalBankAccReconciliation);
                        if BankAccountStatement.Get(BankAccNo, StatementNo) then begin
                            TelemetryDimensions.Add('BankAccountStatementId', Format(BankAccountStatement.SystemId));
                            Session.LogMessage('0000LF9', TelemetryUserSuccessfullyPostedFromProposalsPageTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDimensions);
                            if Confirm(SuccessfullPostedQst) then
                                Page.Run(Page::"Bank Account Statement", BankAccountStatement);
                        end
                    end
                    else begin
                        Session.LogMessage('0000LFA', TelemetryUserAttemptedToPostFromProposalsPageNotFullyAppliedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDimensions);
                        Message(OpenBankRecCardMsg);
                    end;
                end;
        end
        else begin
            if LocalBankAccReconciliation.Get(LocalBankAccReconciliation."Statement Type"::"Bank Reconciliation", BankAccNo, StatementNo) then
                TelemetryDimensions.Add('BankAccReconciliationId', Format(LocalBankAccReconciliation.SystemId));
            Session.LogMessage('0000LFB', TelemetryUserNotAcceptedProposalsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDimensions);
        end;
    end;

    local procedure GenerateTransferToGLAccountProposals()
    var
        LocalBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        LocalBankAccReconciliation: Record "Bank Acc. Reconciliation";
        TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary;
        BankAccRecTransToAcc: Codeunit "Bank Acc. Rec. Trans. to Acc.";
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        TelemetryDimensions: Dictionary of [Text, Text];
        Pct: Decimal;
    begin
        BankAccRecTransToAcc.GenerateTransferToGLAccountProposals(TempBankAccRecAIProposal, BankAccReconciliationLine, TempBankStatementMatchingBuffer);
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
        if BankAccRecTransToAcc.FoundInputWithReservedWords() then
            WarningTxt := InputWithReservedWordsRemovedTxt;
        TelemetryDimensions.Add('Category', BankRecAIMatchingImpl.FeatureName());
        TelemetryDimensions.Add('TotalLines', Format(TotalLines));
        TelemetryDimensions.Add('AppliedLinesUpFront', Format(AppliedLinesUpFront));
        TelemetryDimensions.Add('ProposedLines', Format(ProposedLines));
        if LocalBankAccReconciliation.Get(Rec."Statement Type", Rec."Statement No.", Rec."Bank Account No.") then begin
            StatementDate := LocalBankAccReconciliation."Statement Date";
            TelemetryDimensions.Add('BankAccReconciliationId', Format(LocalBankAccReconciliation.SystemId));
        end;
        InitializeJournalBatch();
        if not Rec.Insert() then
            Rec.Modify();
        PageCaptionLbl := StrSubstNo(ContentAreaCaptionTxt, BankAccNo, StatementNo, StatementDate);
        Session.LogMessage('0000LFC', TelemetryCopilotProposedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDimensions);
    end;

    local procedure PostNewPaymentsToProposedGLAccounts()
    var
        TransToGLAccJnlBatch: Record "Trans. to G/L Acc. Jnl. Batch";
        TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary;
        LocalBankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccRecTransToAcc: Codeunit "Bank Acc. Rec. Trans. to Acc.";
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        if not TransToGLAccJnlBatch.FindFirst() then begin
            TransToGLAccJnlBatch.Init();
            TransToGLAccJnlBatch.Insert();
        end;
        TransToGLAccJnlBatch.Validate("Journal Template Name", JournalTemplateName);
        TransToGLAccJnlBatch.Validate("Journal Batch Name", JournalBatchName);
        TransToGLAccJnlBatch.Modify();
        CurrPage.ProposalDetails.Page.GetTempRecord(TempBankAccRecAIProposal);
        AcceptedProposalCount := BankAccRecTransToAcc.PostNewPaymentsToProposedGLAccounts(TempBankAccRecAIProposal, TempBankStatementMatchingBuffer, TransToGLAccJnlBatch);
        TelemetryDimensions.Add('Category', BankRecAIMatchingImpl.FeatureName());
        TelemetryDimensions.Add('TotalLines', Format(TotalLines));
        TelemetryDimensions.Add('AppliedLinesUpFront', Format(AppliedLinesUpFront));
        TelemetryDimensions.Add('ProposedLines', Format(ProposedLines));
        TelemetryDimensions.Add('AcceptedProposalCount', Format(AcceptedProposalCount));
        LocalBankAccReconciliation.SetLoadFields(SystemId);
        if LocalBankAccReconciliation.Get(LocalBankAccReconciliation."Statement Type"::"Bank Reconciliation", BankAccNo, StatementNo) then
            TelemetryDimensions.Add('BankAccReconciliationId', Format(LocalBankAccReconciliation.SystemId));
        Session.LogMessage('0000LFD', TelemetryUserAcceptedProposalsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, TelemetryDimensions);
    end;

    internal procedure SetBankAccReconciliationLines(var InputBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line");
    begin
        BankAccReconciliationLine.Copy(InputBankAccReconciliationLine);
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

    internal procedure SetStatementEndingBalance(InputStatementEndingBalance: Decimal);
    begin
        StatementEndingBalance := InputStatementEndingBalance;
    end;

    internal procedure SetPageCaption(InputPageCaption: Text);
    begin
        PageCaptionLbl := InputPageCaption;
    end;

    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary;
        AutoMatchedLinesTxt: Text;
        LinesMatchedByCopilotTxt: Text;
        AutoMatchedLinesLbl: label '%1 of %2 lines (%3%)', Comment = '%1 - an integer; %2 - an integer; %3 a decimal between 0 and 100';
        PageCaptionLbl: Text;
        OpenBankRecCardMsg: label 'There are statement lines with amounts that are not fully applied. Before posting, you must apply all statement line amounts in the bank account reconciliation.';
        SuccessfullPostedQst: label 'The bank account reconciliation is posted successfully. Do you want to view the posted bank reconciliation details?';
        TelemetryUserAcceptedProposalsTxt: label 'User accepted Copilot proposals for posting differences to G/L Account', Locked = true;
        TelemetryCopilotProposedTxt: label 'Copilot proposed posting differences to G/L Account, using cosine similarity threshold of 0.6', Locked = true;
        TelemetryUserNotAcceptedProposalsTxt: label 'User closed Copilot proposals page without accepting', Locked = true;
        TelemetryUserAttemptedToPostFromProposalsPageTxt: label 'User attempted to post from proposals page.', Locked = true;
        TelemetryUserAttemptedToPostFromProposalsPageNotFullyAppliedTxt: label 'User attempted to post from proposals page, but there are still unapplied amounts.', Locked = true;
        TelemetryUserSuccessfullyPostedFromProposalsPageTxt: label 'User posted the bank account reconciliation from proposals page.', Locked = true;
        ContentAreaCaptionTxt: label 'Reconciling %1 statement %2 for %3', Comment = '%1 - bank account code, %2 - statement number, %3 - statement date';
        AllLinesMatchedTxt: label 'All lines (100%) are matched. Review match proposals.';
        SubsetOfLinesMatchedTxt: label '%1% of lines are matched. Review match proposals.', Comment = '%1 - a decimal between 0 and 100';
        InputWithReservedWordsRemovedTxt: label 'Statement line descriptions or G/L Account names with reserved AI chat completion prompt words were detected. For security reasons, they were excluded from the auto-matching process. You must match these statement lines or G/L Accounts manually.';
        StatementDate: Date;
        StatementEndingBalance: Decimal;
        BankAccNo: Code[20];
        StatementNo: Code[20];
        PostIfFullyApplied: Boolean;
        ProposedLines: Integer;
        AcceptedProposalCount: Integer;
        TotalLines: Integer;
        AppliedLinesUpFront: Integer;
        PostIfFullyAppliedEditable: Boolean;
        SummaryTxt: Text;
        SummaryStyleTxt: Text;
        WarningTxt: Text;
        JournalTemplateName: Code[10];
        JournalBatchName: Code[10];
}