// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Upgrade;
using System.AI;
using System.Environment;

codeunit 4589 "SOA Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    InherentEntitlements = X;
    InherentPermissions = X;

    var
        SOAImpl: Codeunit "SOA Impl";

    trigger OnUpgradePerDatabase()
    begin
        RegisterCapability();
        AddBillingTypeToCapability();
    end;

    trigger OnUpgradePerCompany()
    begin
        AddDailyEmailLimit();
    end;

    local procedure RegisterCapability()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not UpgradeTag.HasUpgradeTag(GetRegisterSalesOrderAgentCapabilityTag()) then begin
            SOAImpl.RegisterCapability();

            UpgradeTag.SetUpgradeTag(GetRegisterSalesOrderAgentCapabilityTag());
        end;
    end;

    local procedure AddBillingTypeToCapability()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        CopilotCapability: Codeunit "Copilot Capability";
        EnvironmentInformation: Codeunit "Environment Information";
        LearnMoreUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2281481', Locked = true;
    begin
        if not UpgradeTag.HasUpgradeTag(GetAddBillingTypeToSOACapabilityTag()) then begin
            if EnvironmentInformation.IsSaaSInfrastructure() then
                if CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Sales Order Agent") then
                    CopilotCapability.ModifyCapability(Enum::"Copilot Capability"::"Sales Order Agent", Enum::"Copilot Availability"::Preview, Enum::"Copilot Billing Type"::"Microsoft Billed", LearnMoreUrlTxt);

            UpgradeTag.SetUpgradeTag(GetAddBillingTypeToSOACapabilityTag());
        end;
    end;

    local procedure AddDailyEmailLimit()
    var
        SOASetup: Record "SOA Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not UpgradeTag.HasUpgradeTag(GetSetDailyEmailLimitTag()) then begin
            if SOASetup.FindFirst() then begin
                SOASetup."Message Limit" := SOASetup.GetDefaultMessageLimit();
                SOASetup.Modify();
            end;

            UpgradeTag.SetUpgradeTag(GetSetDailyEmailLimitTag());
        end;
    end;

    internal procedure GetRegisterSalesOrderAgentCapabilityTag(): Code[250]
    begin
        exit('MS-539550-SalesOrderAgentCapability-20240802');
    end;

    internal procedure GetAddBillingTypeToSOACapabilityTag(): Code[250]
    begin
        exit('MS-581366-BillingTypeToSalesOrderAgentCapability-20250731');
    end;

    internal procedure GetSetDailyEmailLimitTag(): Code[250]
    begin
        exit('MS-597734-DailyEmailLimit-20250822');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", OnGetPerDatabaseUpgradeTags, '', false, false)]
    local procedure RegisterPerDatabaseUpgradeTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        PerDatabaseUpgradeTags.Add(GetAddBillingTypeToSOACapabilityTag());
    end;
}