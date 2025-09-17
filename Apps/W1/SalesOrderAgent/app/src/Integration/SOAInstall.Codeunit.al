// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.AI;

codeunit 4588 "SOA Install"
{
    Access = Internal;
    Subtype = Install;

    InherentEntitlements = X;
    InherentPermissions = X;

    var
        SOAImpl: Codeunit "SOA Impl";

    trigger OnInstallAppPerDatabase()
    begin
        SOAImpl.RegisterCapability();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Copilot AI Capabilities", 'OnRegisterCopilotCapability', '', false, false)]
    local procedure OnRegisterCopilotCapability()
    begin
        SOAImpl.RegisterCapability();
    end;
}