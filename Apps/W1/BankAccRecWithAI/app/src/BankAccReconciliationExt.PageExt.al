namespace Microsoft.Bank.Reconciliation;

using System.AI;
using System.Environment.Configuration;
using System.Telemetry;

pageextension 7253 BankAccReconciliationExt extends "Bank Acc. Reconciliation"
{
    actions
    {
        addafter("Transfer to General Journal")
        {
            action("Transfer to G/L Account")
            {
                ApplicationArea = All;
                Caption = 'Transfer to G/L Account';
#pragma warning disable AL0482
                Image = SparkleFilled;
#pragma warning restore AL0482
                ToolTip = 'Find suitable G/L Accounts for selected statement lines, post new payments and reconcile statement lines with the new payments';
                Visible = CopilotActionsVisible;

                trigger OnAction()
                var
                    TempBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line" temporary;
                    BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
                    BankAccReconciliation: Record "Bank Acc. Reconciliation";
                    TempBankAccRecAIProposal: Record "Bank Acc. Rec. AI Proposal" temporary;
                    FeatureTelemetry: Codeunit "Feature Telemetry";
                    BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
                    AzureOpenAI: Codeunit "Azure OpenAI";
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
                        end;
                        TransToGLAccAIProposal.SetBankAccReconciliationLines(BankAccReconciliationLine);
                        FeatureTelemetry.LogUptake('0000LF1', BankRecAIMatchingImpl.FeatureName(), Enum::"Feature Uptake Status"::"Set up");
                        TransToGLAccAIProposal.LookupMode(true);
                        if TransToGLAccAIProposal.RunModal() = Action::LookupOK then
                            CurrPage.Update();
                    end;
                end;
            }
        }
        addafter(MatchAutomatically)
        {
            action("Match With Copilot")
            {
                ApplicationArea = All;
                Caption = 'Reconcile with Copilot';
#pragma warning disable AL0482
                Image = SparkleFilled;
#pragma warning restore AL0482
                ToolTip = 'Match statement lines with the assistance of Copilot';
                Visible = CopilotActionsVisible;

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
                    MatchBankRecLines.BankAccReconciliationAutoMatch(Rec, 1, true, true);
                end;
            }
        }
        addbefore("Transfer to General Journal_Promoted")
        {
            actionref("Match With Copilot_Promoted"; "Match With Copilot")
            {
            }
            actionref("Transfer to G/L Account_Promoted"; "Transfer to G/L Account")
            {
            }
        }
        addbefore(MatchAutomatically_Promoted)
        {
            actionref("Match With Copilot_Promoted2"; "Match With Copilot")
            {
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureKey: Record "Feature Key";
        FeatureManagementFacade: Codeunit "Feature Management Facade";
    begin
        if not FeatureKey.Get(BankAccRecWithAILbl) then
            CopilotActionsVisible := true
        else
            CopilotActionsVisible := FeatureManagementFacade.IsEnabled(BankAccRecWithAILbl);
    end;

    var
        CopilotActionsVisible: Boolean;
        BankAccRecWithAILbl: label 'BankAccRecWithAI', Locked = true;
        NoBankAccReconcilliationLnWithDiffSellectedErr: Label 'Select the bank statement lines that have differences to transfer to the general journal.';

}