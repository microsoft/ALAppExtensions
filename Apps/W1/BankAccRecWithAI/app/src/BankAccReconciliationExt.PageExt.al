namespace Microsoft.Bank.Reconciliation;

using System.AI;
using Microsoft.Finance.GeneralLedger.Journal;
using System.Telemetry;

pageextension 7253 BankAccReconciliationExt extends "Bank Acc. Reconciliation"
{
    actions
    {
        addfirst(Prompting)
        {
            action("Match With Copilot")
            {
                ApplicationArea = All;
                Caption = 'Reconcile';
                ToolTip = 'Match statement lines with the assistance of Copilot';
                Visible = CopilotActionsVisible;
                Enabled = CopilotActionsVisible;
#pragma warning disable AL0482
                Image = SparkleFilled;
#pragma warning restore AL0482

                trigger OnAction()
                var
                    MatchBankRecLines: Codeunit "Match Bank Rec. Lines";
                    FeatureTelemetry: Codeunit "Feature Telemetry";
                    BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
                    AzureOpenAI: Codeunit "Azure OpenAI";
                begin
                    BankRecAIMatchingImpl.RegisterCapability();

                    if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Bank Account Reconciliation") then
                        exit;

                    FeatureTelemetry.LogUptake('0000LF2', BankRecAIMatchingImpl.FeatureName(), Enum::"Feature Uptake Status"::Discovered);
                    FeatureTelemetry.LogUptake('0000LF3', BankRecAIMatchingImpl.FeatureName(), Enum::"Feature Uptake Status"::"Set up");
                    MatchBankRecLines.BankAccReconciliationAutoMatch(Rec, 1, true, false);
                end;
            }

            action("Transfer to G/L Account")
            {
                ApplicationArea = All;
                Caption = 'Post difference to G/L account';
                ToolTip = 'Find suitable G/L Accounts for selected statement lines, post their differences as new payments and reconcile statement lines with the new payments';
                Visible = CopilotActionsVisible;
                Enabled = CopilotActionsVisible;
#pragma warning disable AL0482
                Image = SparkleFilled;
#pragma warning restore AL0482

                trigger OnAction()
                var
                    TempBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line" temporary;
                    BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
                    BankAccReconciliation: Record "Bank Acc. Reconciliation";
                    TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary;
                    TransToGLAccountBatch: Record "Trans. to G/L Acc. Jnl. Batch";
                    GenJournalBatch: Record "Gen. Journal Batch";
                    FeatureTelemetry: Codeunit "Feature Telemetry";
                    BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
                    AzureOpenAI: Codeunit "Azure OpenAI";
                    GenJnlManagement: Codeunit GenJnlManagement;
                    TransToGLAccAIProposal: Page "Trans. To GL Acc. AI Proposal";
                    LineNoFilter: Text;
                begin
                    BankRecAIMatchingImpl.RegisterCapability();

                    if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Bank Account Reconciliation") then
                        exit;

                    FeatureTelemetry.LogUptake('0000LF0', BankRecAIMatchingImpl.FeatureName(), Enum::"Feature Uptake Status"::Discovered);
                    CurrPage.StmtLine.PAGE.GetSelectedRecords(TempBankAccReconciliationLine);
#pragma warning disable AA0210
                    TempBankAccReconciliationLine.SetRange(Difference, 0);
#pragma warning restore AA0210
                    TempBankAccReconciliationLine.DeleteAll();
#pragma warning disable AA0210
                    TempBankAccReconciliationLine.SetRange(Difference);
#pragma warning restore AA0210
                    if TempBankAccReconciliationLine.IsEmpty() then
                        error(NoBankAccReconcilliationLnWithDiffSellectedErr);

#pragma warning disable AA0210
                    TempBankAccReconciliationLine.SetRange("Transaction Date", 0D);
#pragma warning restore AA0210
                    if not TempBankAccReconciliationLine.IsEmpty() then
                        error(NoTransactionDateErr);
#pragma warning disable AA0210
                    TempBankAccReconciliationLine.SetRange("Transaction Date");
#pragma warning restore AA0210

                    TempBankAccReconciliationLine.FindSet();
                    BankAccReconciliationLine.SetRange("Statement Type", TempBankAccReconciliationLine."Statement Type");
                    BankAccReconciliationLine.SetRange("Bank Account No.", TempBankAccReconciliationLine."Bank Account No.");
                    BankAccReconciliationLine.SetRange("Statement No.", TempBankAccReconciliationLine."Statement No.");
                    repeat
                        if LineNoFilter = '' then
                            LineNoFilter := Format(TempBankAccReconciliationLine."Statement Line No.")
                        else
                            LineNoFilter += ('|' + Format(TempBankAccReconciliationLine."Statement Line No."));
                    until TempBankAccReconciliationLine.Next() = 0;
                    BankAccReconciliationLine.SetFilter("Statement Line No.", LineNoFilter);

                    TempBankAccRecAIProposal."Bank Account No." := BankAccReconciliationLine."Bank Account No.";
                    TempBankAccRecAIProposal."Statement No." := BankAccReconciliationLine."Statement No.";
                    TempBankAccRecAIProposal."Statement Type" := BankAccReconciliationLine."Statement Type";
                    TempBankAccRecAIProposal.Insert();
                    if BankAccReconciliationLine.FindSet() then begin
                        Commit();
                        TransToGLAccAIProposal.SetRecord(TempBankAccRecAIProposal);
                        TransToGLAccAIProposal.SetStatementNo(BankAccReconciliationLine."Statement No.");
                        TransToGLAccAIProposal.SetBankAccountNo(BankAccReconciliationLine."Bank Account No.");
                        if BankAccReconciliation.Get(BankAccReconciliationLine."Statement Type", BankAccReconciliationLine."Bank Account No.", BankAccReconciliationLine."Statement No.") then begin
                            TransToGLAccAIProposal.SetStatementDate(BankAccReconciliation."Statement Date");
                            TransToGLAccAIProposal.SetStatementEndingBalance(BankAccReconciliation."Statement Ending Balance");
                            TransToGLAccAIProposal.SetPageCaption(StrSubstNo(ContentAreaCaptionTxt, BankAccReconciliationLine."Bank Account No.", BankAccReconciliationLine."Statement No.", BankAccReconciliation."Statement Date"));
                        end;
                        TransToGLAccAIProposal.SetBankAccReconciliationLines(BankAccReconciliationLine);
                        FeatureTelemetry.LogUptake('0000LF1', BankRecAIMatchingImpl.FeatureName(), Enum::"Feature Uptake Status"::"Set up");
                        TransToGLAccAIProposal.LookupMode(true);
                        if TransToGLAccAIProposal.RunModal() = Action::OK then
                            CurrPage.Update();

                        if TransToGLAccountBatch.FindFirst() then
                            if TransToGLAccountBatch."Open Journal Batch" then
                                if GenJournalBatch.Get(TransToGLAccountBatch."Journal Template Name", TransToGLAccountBatch."Journal Batch Name") then
                                    GenJnlManagement.TemplateSelectionFromBatch(GenJournalBatch);
                    end;
                end;
            }
        }
#if not CLEAN25
        addbefore("Transfer to General Journal_Promoted")
        {
            actionref("Match With Copilot_Promoted"; "Match With Copilot")
            {
                Visible = false;
                ObsoleteReason = 'Actions no longer promoted, but shown in the Prompting area';
                ObsoleteState = Pending;
                ObsoleteTag = '25.0';
            }
            actionref("Transfer to G/L Account_Promoted"; "Transfer to G/L Account")
            {
                Visible = false;
                ObsoleteReason = 'Actions no longer promoted, but shown in the Prompting area';
                ObsoleteState = Pending;
                ObsoleteTag = '25.0';
            }
        }
        addbefore(MatchAutomatically_Promoted)
        {
            actionref("Match With Copilot_Promoted2"; "Match With Copilot")
            {
                Visible = false;
                ObsoleteReason = 'Actions no longer promoted, but shown in the Prompting area';
                ObsoleteState = Pending;
                ObsoleteTag = '25.0';
            }
        }
#endif
    }

    trigger OnOpenPage()
    var
        CopilotCapability: Codeunit "Copilot Capability";
    begin
        CopilotActionsVisible := CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Bank Account Reconciliation");
    end;

    var
        CopilotActionsVisible: Boolean;
        NoTransactionDateErr: Label 'You must specify the transaction date on all the selected statement lines.';
        NoBankAccReconcilliationLnWithDiffSellectedErr: Label 'Select the bank statement lines that have differences to transfer to the general journal.';
        ContentAreaCaptionTxt: label 'Reconciling %1 statement %2 for %3', Comment = '%1 - bank account code, %2 - statement number, %3 - statement date';

}