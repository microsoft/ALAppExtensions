// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.AI;
using System.Environment;
using System.Email;
using System.Security.AccessControl;
using System.Telemetry;

codeunit 4587 "SOA Impl"
{
    Access = Internal;
    Permissions = tabledata "Email Inbox" = rd, tabledata User = R;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CantCreateTaskErr: Label 'User cannot create tasks.';
        TelemetrySOASetupRecordNotValidLbl: Label 'SOA Setup record is not valid.', Locked = true;
        TelemetryAgentScheduledTaskCancelledLbl: Label 'Agent scheduled task cancelled.', Locked = true;
        TelemetryRecoveryScheduledTaskCancelledLbl: Label 'Recovery scheduled task cancelled.', Locked = true;
        TelemetryAgentScheduledLbl: Label 'Agent scheduled.', Locked = true;

    internal procedure ScheduleSOAgent(var SOASetup: Record "SOA Setup")
    var
        SOASetupCU: Codeunit "SOA Setup";
        ScheduledTaskId: Guid;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        if IsNullGuid(SOASetup.SystemId) then begin
            FeatureTelemetry.LogError('0000NDU', SOASetupCU.GetFeatureName(), 'Invalid SOA Setup', TelemetrySOASetupRecordNotValidLbl, GetLastErrorCallStack(), TelemetryDimensions);
            exit;
        end;

        if not TaskScheduler.CanCreateTask() then
            Error(CantCreateTaskErr);

        SOASetup.LockTable(); // Ensure that no other process can change the setup while we are scheduling the task
        SOASetup.GetBySystemId(SOASetup.SystemId);
        RemoveScheduledTask(SOASetup);

        ScheduledTaskId := TaskScheduler.CreateTask(Codeunit::"SOA Dispatcher", Codeunit::"SOA Error Handler", true, CompanyName(), CurrentDateTime() + ScheduleDelay(), SOASetup.RecordId);
        SOASetup."Agent Scheduled Task ID" := ScheduledTaskId;
        ScheduleSOARecovery(SOASetup);

        SOASetup.Modify();
        Commit();
        FeatureTelemetry.LogUsage('0000NGM', SOASetupCU.GetFeatureName(), TelemetryAgentScheduledLbl, TelemetryDimensions);
    end;

    /// <summary>
    /// Checks if the agent is active in the current company.
    /// Method must work even for users that have no access to Agent, thus we need to use User table to check if the agent is enabled.
    /// </summary>
    /// <returns>True if active agent exists, false otherwise.</returns>
    procedure ActiveAgentExistInCurrentCompany(): Boolean
    var
        SOASetup: Record "SOA Setup";
        User: Record User;
    begin
        SOASetup.ReadIsolation := IsolationLevel::ReadUncommitted;
        if not SOASetup.FindSet() then
            exit(false);

        // Picking safe option to assume it is enabled if no read permissions are in the system and there is SOA setup.
        User.ReadIsolation := IsolationLevel::ReadUncommitted;
        if not User.ReadPermission() then
            exit(true);

        repeat
            if User.Get(SOASetup."Agent User Security ID") then
                if User.State = User.State::Enabled then
                    exit(true);
        until SOASetup.Next() = 0;

        exit(false);
    end;

    local procedure ScheduleSOARecovery(var SOASetup: Record "SOA Setup")
    var
        ScheduledTaskId: Guid;
    begin
        ScheduledTaskId := TaskScheduler.CreateTask(Codeunit::"SOA Recovery", Codeunit::"SOA Recovery", true, CompanyName(), CurrentDateTime() + ScheduleRecoveryDelay(), SOASetup.RecordId);
        SOASetup."Recovery Scheduled Task ID" := ScheduledTaskId;
    end;

    internal procedure RemoveScheduledTask(var SOASetup: Record "SOA Setup")
    var
        SOASetupCU: Codeunit "SOA Setup";
        NullGuid: Guid;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        if TaskScheduler.TaskExists(SOASetup."Agent Scheduled Task ID") then begin
            TaskScheduler.CancelTask(SOASetup."Agent Scheduled Task ID");
            FeatureTelemetry.LogUsage('0000NGN', SOASetupCU.GetFeatureName(), TelemetryAgentScheduledTaskCancelledLbl, TelemetryDimensions);
        end;

        if TaskScheduler.TaskExists(SOASetup."Recovery Scheduled Task ID") then begin
            TaskScheduler.CancelTask(SOASetup."Recovery Scheduled Task ID");
            FeatureTelemetry.LogUsage('0000NGO', SOASetupCU.GetFeatureName(), TelemetryRecoveryScheduledTaskCancelledLbl, TelemetryDimensions);
        end;

        SOASetup."Agent Scheduled Task ID" := NullGuid;
        SOASetup."Recovery Scheduled Task ID" := NullGuid;
    end;

    local procedure ScheduleDelay(): Integer
    begin
        exit(20 * 1000) // 20 seconds
    end;

    local procedure ScheduleRecoveryDelay(): Integer
    begin
        exit(4 * 60 * 60 * 1000) // 4 hours
    end;

    internal procedure GetProcessLimitPerDay(var SOASetup: Record "SOA Setup"): Integer
    begin
        exit(SOASetup."Message Limit");
    end;

    procedure RemoveTaskLogsOlderThan24hrs()
    var
        SOATask: Record "SOA Task";
        Limit: DateTime;
    begin
        Limit := CreateDateTime(CalcDate('<-1D>', CurrentDateTime().Date), 0T);

        SOATask.SetFilter(SystemCreatedAt, '<%1', Limit);
        if not SOATask.FindSet() then
            exit;

        SOATask.DeleteAll();
        Commit();
    end;

    procedure RegisterCapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        EnvironmentInformation: Codeunit "Environment Information";
        LearnMoreUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2281481', Locked = true;
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit;

        if CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"Sales Order Agent") then
            CopilotCapability.ModifyCapability(Enum::"Copilot Capability"::"Sales Order Agent", Enum::"Copilot Availability"::"Generally Available", Enum::"Copilot Billing Type"::"Microsoft Billed", LearnMoreUrlTxt)
        else
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"Sales Order Agent", Enum::"Copilot Availability"::"Generally Available", Enum::"Copilot Billing Type"::"Microsoft Billed", LearnMoreUrlTxt);
    end;
}