namespace Microsoft.Bank.Reconciliation;

using System.AI;
using System.Environment;
using System.Environment.Configuration;
using System.Telemetry;

pageextension 7254 BankAccReconciliationListExt extends "Bank Acc. Reconciliation List"
{
    actions
    {
        addbefore(ChangeStatementNo)
        {
            action("Reconcile With Copilot")
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
        addbefore(Category_Posting)
        {
            actionref("Reconcile With Copilot_Promoted"; "Reconcile With Copilot")
            {
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureKey: Record "Feature Key";
        FeatureManagementFacade: Codeunit "Feature Management Facade";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not FeatureKey.Get(BankAccRecWithAILbl) then
            CopilotActionsVisible := true
        else
            CopilotActionsVisible := FeatureManagementFacade.IsEnabled(BankAccRecWithAILbl);

        if CopilotActionsVisible then
            CopilotActionsVisible := EnvironmentInformation.IsSaaSInfrastructure();
    end;

    var
        CopilotActionsVisible: Boolean;
        BankAccRecWithAILbl: label 'BankAccRecWithAI', Locked = true;
}