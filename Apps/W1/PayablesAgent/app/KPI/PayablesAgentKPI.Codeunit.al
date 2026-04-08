// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;


codeunit 3306 "Payables Agent KPI"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure InsertKPIEntry(KPIScenario: Enum "PA KPI Scenario")
    var
        PayablesAgentKPI: Record "Payables Agent KPI";
    begin
        PayablesAgentKPI := GetAggregateKPI(KPIScenario);
        PayablesAgentKPI.Count += 1;
        PayablesAgentKPI.Modify();
        Clear(PayablesAgentKPI);
        PayablesAgentKPI.Count := 1;
        PayablesAgentKPI."KPI Scenario" := KPIScenario;
        PayablesAgentKPI."Is Aggregate" := false;
        PayablesAgentKPI.Insert();
    end;

    procedure GetAggregateKPI(KPIScenario: Enum "PA KPI Scenario") PayablesAgentKPI: Record "Payables Agent KPI"
    begin
        Clear(PayablesAgentKPI);
        PayablesAgentKPI.SetRange("Is Aggregate", true);
        PayablesAgentKPI.SetRange("KPI Scenario", KPIScenario);
        if not PayablesAgentKPI.FindFirst() then begin
            PayablesAgentKPI."Is Aggregate" := true;
            PayablesAgentKPI."KPI Scenario" := KPIScenario;
            PayablesAgentKPI.Insert();
        end;
    end;

}