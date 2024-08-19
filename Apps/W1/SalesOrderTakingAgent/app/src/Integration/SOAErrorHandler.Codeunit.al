// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Integration;

using System.Telemetry;
using Agent.SalesOrderTaker;

codeunit 4585 "SOA Error Handler"
{
    Access = Internal;
    TableNo = "SOA Setup";

    trigger OnRun()
    begin
        RunSOAErrorHandler(Rec);
    end;

    var
        TelemetryAgentTaskFailedLbl: Label 'Sales order taker agent task failed', Locked = true;

    procedure RunSOAErrorHandler(Setup: Record "SOA Setup")
    var
        SOAImpl: Codeunit "SOA Impl";
        Telemetry: Codeunit Telemetry;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        CustomDimensions.Add('ErrorCallStack', GetLastErrorCallStack());
        CustomDimensions.Add('SOASetupId', Format(Setup.ID));
        Telemetry.LogMessage('0000NDM', TelemetryAgentTaskFailedLbl, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);

        SOAImpl.ScheduleSOA(Setup);
    end;
}