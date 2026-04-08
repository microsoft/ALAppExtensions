// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

using System.Agents.Designer.CustomAgent;

codeunit 4354 "Agent Designer Install"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        AgentDesignerEnvironment: Codeunit "Agent Designer Environment";
    begin
        AgentDesignerEnvironment.VerifyCanRunOnCurrentEnvironment();
    end;

    trigger OnInstallAppPerDatabase()
    var
        CustomAgentSetup: Codeunit "Custom Agent Setup";
    begin
        CustomAgentSetup.RegisterCapability();
    end;
}