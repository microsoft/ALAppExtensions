// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using System.Agents;
using System.AI;
using System.Environment;
using System.Upgrade;

codeunit 3305 "Payables Agent Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    InherentEntitlements = X;
    InherentPermissions = X;

    var
        UpgradeTag: Codeunit "Upgrade Tag";

    trigger OnUpgradePerCompany()
    begin
        AlwaysUpdateAgentInformationOnUpgrade();
        UpdatePayablesAgentSetupToUseUserSecurityId();
    end;

    trigger OnUpgradePerDatabase()
    begin
        RegisterCapability();
        AddBillingTypeToCapability();
    end;

    local procedure RegisterCapability()
    var
        PayablesAgent: Codeunit "Payables Agent";
    begin
        if not UpgradeTag.HasUpgradeTag(GetRegisterPayablesAgentCapabilityTag()) then begin
            PayablesAgent.RegisterCapability();

            UpgradeTag.SetUpgradeTag(GetRegisterPayablesAgentCapabilityTag());
        end;
    end;

    local procedure AlwaysUpdateAgentInformationOnUpgrade()
    var
        Agent: Record Agent;
        EnvironmentInformation: Codeunit "Environment Information";
        PayablesAgent: Codeunit "Payables Agent Setup";
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit;

        if PayablesAgent.GetAgent(Agent) then
            PayablesAgent.SetAgentInstructions(Agent."User Security ID");
    end;

    local procedure AddBillingTypeToCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        EnvironmentInformation: Codeunit "Environment Information";
        LearnMoreUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2304779', Locked = true;
    begin
        if not UpgradeTag.HasUpgradeTag(GetAddBillingTypeToPACapabilityTag()) then begin
            if EnvironmentInformation.IsSaaSInfrastructure() then
                if CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Payables Agent") then
                    CopilotCapability.ModifyCapability(Enum::"Copilot Capability"::"Payables Agent", Enum::"Copilot Availability"::"Generally Available", Enum::"Copilot Billing Type"::"Microsoft Billed", LearnMoreUrlTxt);

            UpgradeTag.SetUpgradeTag(GetAddBillingTypeToPACapabilityTag());
        end;
    end;

    local procedure UpdatePayablesAgentSetupToUseUserSecurityId()
    var
        PayablesAgentSetup: Record "Payables Agent Setup";
    begin
        if not UpgradeTag.HasUpgradeTag(GetUpdatePayablesAgentSetupToUseUserSecurityIdTag()) then begin
            if PayablesAgentSetup.FindFirst() then begin
                PayablesAgentSetup."User Security Id" := PayablesAgentSetup."Agent User Security Id";
                PayablesAgentSetup.Modify();
            end;
            UpgradeTag.SetUpgradeTag(GetUpdatePayablesAgentSetupToUseUserSecurityIdTag());
        end;
    end;

    local procedure GetRegisterPayablesAgentCapabilityTag(): Code[250]
    begin
        exit('MS-575373-PayablesAgentCapability-20251021');
    end;

    local procedure GetAddBillingTypeToPACapabilityTag(): Code[250]
    begin
        exit('MS-581366-BillingTypeToPayablesAgentCapability-20250731');
    end;

    local procedure GetUpdatePayablesAgentSetupToUseUserSecurityIdTag(): Code[250]
    begin
        exit('MS-617049-UpdatePayablesAgentSetupToUseUserSecurityId-20260224');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", OnGetPerDatabaseUpgradeTags, '', false, false)]
    local procedure RegisterPerDatabaseUpgradeTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        PerDatabaseUpgradeTags.Add(GetAddBillingTypeToPACapabilityTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", OnGetPerCompanyUpgradeTags, '', false, false)]
    local procedure RegisterPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetUpdatePayablesAgentSetupToUseUserSecurityIdTag());
    end;

}