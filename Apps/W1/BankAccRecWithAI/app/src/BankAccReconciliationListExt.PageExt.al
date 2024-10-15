namespace Microsoft.Bank.Reconciliation;

using System.AI;
using System.Telemetry;

pageextension 7254 BankAccReconciliationListExt extends "Bank Acc. Reconciliation List"
{
    actions
    {
#if not CLEAN24
        addbefore(Category_Posting)
        {
            actionref("Reconcile With Copilot_Promoted"; "Reconcile With Copilot")
            {
                Visible = false;
                ObsoleteReason = 'Action in the Prompting area.';
                ObsoleteState = Pending;
                ObsoleteTag = '24.0';
            }
        }
#endif
        addfirst(Prompting)
        {
            action("Reconcile With Copilot")
            {
                ApplicationArea = All;
                Caption = 'Reconcile';
#pragma warning disable AL0482
                Image = SparkleFilled;
#pragma warning restore AL0482
                ToolTip = 'Match statement lines with the assistance of Copilot';
                Visible = CopilotActionsVisible;
                Enabled = CopilotActionsVisible;

                trigger OnAction()
                var
                    FeatureTelemetry: Codeunit "Feature Telemetry";
                    BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
                    AzureOpenAI: Codeunit "Azure OpenAI";
                    BankAccRecAIProposal: Page "Bank Acc. Rec. AI Proposal";
                begin
                    BankRecAIMatchingImpl.RegisterCapability();

                    if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Bank Account Reconciliation") then
                        exit;

                    FeatureTelemetry.LogUptake('0000LF4', BankRecAIMatchingImpl.FeatureName(), Enum::"Feature Uptake Status"::Discovered);
                    BankAccRecAIProposal.SetShouldDeleteBankRecOnCancel(true);
                    BankAccRecAIProposal.SetShouldAskToOpenBankRecOnOK(true);
                    BankAccRecAIProposal.LookupMode := true;
                    BankAccRecAIProposal.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        CopilotCapability: Codeunit "Copilot Capability";
    begin
        CopilotActionsVisible := CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Bank Account Reconciliation");
    end;

    var
        CopilotActionsVisible: Boolean;
}