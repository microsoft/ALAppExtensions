// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Agent.SalesOrderAgent;

using System.Agents;

codeunit 4396 "SOA Email Setup"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    internal procedure GetMaxNoOfEmails(): Integer
    begin
        exit(50);
    end;

    internal procedure GetEmailCountProcessedWithin24hrs(): Integer
    var
        SOAEmail: Record "SOA Email";
        StartFromDT: DateTime;
    begin
        StartFromDT := CreateDateTime(CalcDate('<-1D>', CurrentDateTime().Date), 0T);

        SOAEmail.SetRange(Processed, true);
        SOAEmail.SetFilter(SystemModifiedAt, '>=%1', StartFromDT);
        exit(SOAEmail.Count());
    end;

    internal procedure GetNumberOfAttachments(var AgentTaskMessage: Record "Agent Task Message"): Integer
    var
        AgentTaskMessageAttachment: Record "Agent Task Message Attachment";
    begin
        AgentTaskMessageAttachment.SetRange("Task ID", AgentTaskMessage."Task ID");
        AgentTaskMessageAttachment.SetRange("Message ID", AgentTaskMessage.ID);
        AgentTaskMessageAttachment.ReadIsolation := IsolationLevel::ReadUncommitted;
        exit(AgentTaskMessageAttachment.Count());
    end;

    procedure RemoveProcessedEmailsOutsideLast24hrs()
    var
        SOAEmail: Record "SOA Email";
        Limit: DateTime;
    begin
        Limit := CreateDateTime(CalcDate('<-1D>', CurrentDateTime().Date), 0T);

        SOAEmail.SetRange(Processed, true);
        SOAEmail.SetFilter(SystemModifiedAt, '<%1', Limit);
        SOAEmail.SetRange("Agent Task Message Exist", false);
        SOAEmail.ReadIsolation := IsolationLevel::ReadCommitted;

        if not SOAEmail.FindSet() then
            exit;

        repeat
            SOAEmail.Delete(true);
        until SOAEmail.Next() = 0;
        Commit();
    end;
}