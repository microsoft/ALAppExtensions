namespace Microsoft.Bank.Reconciliation;

using System.AI;
using System.Environment;

codeunit 7252 "Bank Acc. Rec. AI Install"
{
    Subtype = Install;
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnInstallAppPerDatabase()
    begin
        RegisterCapability();
    end;

    local procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        EnvironmentInformation: Codeunit "Environment Information";
        LearnMoreUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2248547', Locked = true;
    begin
        if EnvironmentInformation.IsSaaSInfrastructure() then
            if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Bank Account Reconciliation") then
                CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Bank Account Reconciliation", LearnMoreUrlTxt);
    end;
}