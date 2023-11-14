// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Text;

using System.AI;
using System.Environment;
using System.Upgrade;

codeunit 2015 "Entity Text AI Upgrade"
{
    Subtype = Upgrade;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnUpgradePerDatabase()
    begin
        RegisterCapability();
    end;

    local procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        EnvironmentInformation: Codeunit "Environment Information";
        UpgradeTag: Codeunit "Upgrade Tag";
        LearnMoreUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2226375', Locked = true;
    begin
        if not UpgradeTag.HasUpgradeTag(GetRegisterMarketingTextCapabilityTag()) then begin
            if EnvironmentInformation.IsSaaSInfrastructure() then
                if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Entity Text") then
                    CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Entity Text", Enum::"Copilot Availability"::"Generally Available", LearnMoreUrlTxt);

            UpgradeTag.SetUpgradeTag(GetRegisterMarketingTextCapabilityTag());
        end;
    end;

    internal procedure GetRegisterMarketingTextCapabilityTag(): Code[250]
    begin
        exit('MS-490070-RegisterMarketingTextCapability-20231031');
    end;

}