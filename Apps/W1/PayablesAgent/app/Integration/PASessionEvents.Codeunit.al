// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using System.Environment.Configuration;

codeunit 3315 "PA Session Events"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", OnAfterInitialization, '', false, false)]
    local procedure RegisterSubscribersOnAfterLogin()
    var
        PayablesAgent: Codeunit "Payables Agent";
        PayablesAgentSessionID: BigInteger;
    begin
        if not PayablesAgent.IsPayablesAgentSession(PayablesAgentSessionID) then
            exit;

        // Agent login must fail if we cannot register agent subscribers or if there are too many unpaid entries
        BindSubscription(PABilling);
    end;

    var
        PABilling: Codeunit "PA Billing";
}