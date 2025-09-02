// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;
using System.Environment;

codeunit 4532 "SOA Billing Task"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Agent Task Message" = r,
                  tabledata "Scheduled Task" = r,
                  tabledata "SOA Billing Log" = rmi,
                  tabledata "SOA Billing Task Setup" = rmi;

    trigger OnRun()
    var
        SOABillingTaskSetup: Record "SOA Billing Task Setup";
    begin
        if not MarkTaskAsStarted(SOABillingTaskSetup) then
            exit;

        LogGeneratedEmails(SOABillingTaskSetup);
        IssueChargeCalls();
    end;

    local procedure MarkTaskAsStarted(var SOABillingTaskSetup: Record "SOA Billing Task Setup"): Boolean
    var
        SOABilling: Codeunit "SOA Billing";
        SOAImpl: Codeunit "SOA Impl";
        TelemetryDictionary: Dictionary of [Text, Text];
    begin
        // There is a risk of concurrent task execution, so we need to lock the record
        SOABilling.GetBillingTaskSetupSafe(SOABillingTaskSetup);
        LockBillingTaskSetup(SOABillingTaskSetup);

        TelemetryDictionary := SOAImpl.GetCustomDimensions();
        // Leave some time between the tasks to avoid concurrent task execution
        if not SkipConcurrentTaskCheck then
            if SOABillingTaskSetup."Billing Task Start DateTime" <> 0DT then
                if CurrentDateTime() < (SOABillingTaskSetup."Billing Task Start DateTime" + GetMinimumWaitingTimeForBillingTask()) then begin
                    Session.LogMessage('0000OW4', BillingTaskRescheduledMsg, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDictionary);
                    ScheduleBillingTask();
                    exit(false);
                end;

        SOABillingTaskSetup."Billing Task Start DateTime" := CurrentDateTime();
        SOABillingTaskSetup.Modify();
        Commit();
        Session.LogMessage('0000OW5', StartingBillingTaskMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDictionary);
        exit(true);
    end;

    local procedure LogGeneratedEmails(var SOABillingTaskSetup: Record "SOA Billing Task Setup")
    var
        AgentTaskMessage: Record "Agent Task Message";
        SOABilling: Codeunit "SOA Billing";
        SOAImpl: Codeunit "SOA Impl";
        TelemetryDictionary: Dictionary of [Text, Text];
    begin
        LockBillingTaskSetup(SOABillingTaskSetup);

        AgentTaskMessage.SetRange(Type, AgentTaskMessage.Type::Output);
        AgentTaskMessage.SetFilter(SystemCreatedAt, '>=%1', SOABillingTaskSetup."Last Billing Update At");
        TelemetryDictionary := SOAImpl.GetCustomDimensions();
        TelemetryDictionary.Add('LogMessagesFrom', Format(SOABillingTaskSetup."Last Billing Update At", 0, 9));
        Session.LogMessage('0000OT2', StartChargeOutputMessagesMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDictionary);
        if AgentTaskMessage.FindSet() then
            repeat
                SOABilling.LogEmailGenerated(AgentTaskMessage.ID, AgentTaskMessage."Task ID");
            until AgentTaskMessage.Next() = 0;

        SOABillingTaskSetup."Last Billing Update At" := CurrentDateTime();
        SOABillingTaskSetup.Modify();
        Commit();
    end;

    local procedure IssueChargeCalls()
    var
        SOABillingLog: Record "SOA Billing Log";
        SOAImpl: Codeunit "SOA Impl";
        TelemetryDictionary: Dictionary of [Text, Text];
        FailedCount: Integer;
        SuccessCount: Integer;
    begin
        SOABillingLog.SetRange(Charged, false);
        SOABillingLog.ReadIsolation := IsolationLevel::ReadCommitted;
        TelemetryDictionary := SOAImpl.GetCustomDimensions();

        if not SOABillingLog.FindSet() then begin
            Session.LogMessage('0000OT3', NothingToChargeMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDictionary);
            exit;
        end;

        repeat
            if ChargeLogEntry(SOABillingLog) then
                SuccessCount += 1
            else
                FailedCount += 1;
        until SOABillingLog.Next() = 0;

        TelemetryDictionary.Add('FailedCount', Format(FailedCount, 0, 9));
        TelemetryDictionary.Add('SuccessCount', Format(SuccessCount, 0, 9));
        Session.LogMessage('0000OT4', EndingIssueChargeCallsMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDictionary);
    end;

    procedure ScheduleBillingTask()
    var
        NextBillingTaskDateTime: DateTime;
    begin
        ScheduleBillingTask(NextBillingTaskDateTime);
    end;

    local procedure ScheduleBillingTask(var NextBillingTaskDateTime: DateTime): Boolean
    var
        ScheduledTask: Record "Scheduled Task";
        SOAImpl: Codeunit "SOA Impl";
        BlankDateTime: DateTime;
        TelemetryDimensions: Dictionary of [Text, Text];
        ScheduledTaskID: Guid;
    begin
        Clear(BlankDateTime);
        if not TaskScheduler.CanCreateTask() then begin
            Session.LogMessage('0000OTS', CannotScheduleBillingTaskErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDimensions);
            exit(false);
        end;

        ScheduledTask.SetRange("Run Codeunit", Codeunit::"SOA Billing Task");
        ScheduledTask.SetRange(Company, CompanyName());
        if ScheduledTask.ReadPermission() then begin
            if ScheduledTask.Count() >= GetMaximumAllowedScheduledTaskCount() then
                exit(false);

            if ScheduledTask.FindLast() then
                NextBillingTaskDateTime := ScheduledTask."Not Before" + GetNextTaskTime();
        end;
        if NextBillingTaskDateTime = BlankDateTime then
            NextBillingTaskDateTime := CurrentDateTime() + GetNextTaskTime();

        ScheduledTaskID := TaskScheduler.CreateTask(Codeunit::"SOA Billing Task", 0, true, CompanyName(), NextBillingTaskDateTime);

        TelemetryDimensions := SOAImpl.GetCustomDimensions();
        TelemetryDimensions.Add('NextBillingTaskDateTime', Format(NextBillingTaskDateTime, 0, 9));
        TelemetryDimensions.Add('ScheduledTaskID', Format(ScheduledTaskID, 0, 9));
        Session.LogMessage('0000OT6', ScheduledSOABillingOperationMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDimensions);
        exit(true);
    end;

    local procedure GetMaximumAllowedScheduledTaskCount(): Integer
    begin
        // There is maximum 3 allowed tasks to run to cover 1 - 1.5 hours of running
        // More than this would be too much and can cause issues with number of parallel tasks allowed
        exit(3);
    end;

    local procedure ChargeLogEntry(var SOABillingLog: Record "SOA Billing Log"): Boolean
    var
        UpdateSOABillingLog: Record "SOA Billing Log";
        SOABilling: Codeunit "SOA Billing";
        Success: Boolean;
    begin
        // Lock to avoid concurrent charging
        UpdateSOABillingLog.Copy(SOABillingLog);
        UpdateSOABillingLog.ReadIsolation := IsolationLevel::UpdLock;
        UpdateSOABillingLog.Find();

        UpdateSOABillingLog.Charged := true;
        UpdateSOABillingLog.Modify();

        // This is to avoid charging too many times. We need to update the table first, as table update can fail
        if not SOABilling.LogUsageSafe(UpdateSOABillingLog."Copilot Quota Usage Type") then begin
            UpdateSOABillingLog.Charged := false;
            UpdateSOABillingLog.Modify();
            Success := false;
        end else
            Success := true;

        Commit();
        exit(Success);
    end;

    local procedure GetNextTaskTime(): Duration
    begin
        exit(1800000); // 30 minutes from now
    end;

    local procedure GetMinimumWaitingTimeForBillingTask(): Duration
    begin
        exit(300000); // 5 minutes
    end;

    internal procedure SetCheckOtherTasks(NewSkipConcurrentTaskCheck: Boolean)
    begin
        SkipConcurrentTaskCheck := NewSkipConcurrentTaskCheck;
    end;

    local procedure LockBillingTaskSetup(var SOABillingTaskSetup: Record "SOA Billing Task Setup")
    begin
        SOABillingTaskSetup.ReadIsolation := IsolationLevel::UpdLock;
        SOABillingTaskSetup.Find();
    end;

    internal procedure ScheduleBillingTaskInNextInterval(NextTimeToRunTask: DateTime): DateTime
    var
        NewNextTimeToRunTask: DateTime;
    begin
        if (CurrentDateTime() < NextTimeToRunTask) then
            exit(NextTimeToRunTask);

        if ScheduleBillingTask(NewNextTimeToRunTask) then
            NextTimeToRunTask := NewNextTimeToRunTask;
    end;

    var
        StartChargeOutputMessagesMsg: Label 'Starting charge of output messages', Locked = true;
        EndingIssueChargeCallsMsg: Label 'Ending issue charge calls', Locked = true;
        NothingToChargeMsg: Label 'There is nothing to charge', Locked = true;
        ScheduledSOABillingOperationMsg: Label 'Scheduled SOA billing task', Locked = true;
        StartingBillingTaskMsg: Label 'Starting billing task', Locked = true;
        BillingTaskRescheduledMsg: Label 'Billing task was rescheduled', Locked = true;
        CannotScheduleBillingTaskErr: Label 'Cannot schedule task. It is not possible to create a billing session.', Locked = true;
        SkipConcurrentTaskCheck: Boolean;
}