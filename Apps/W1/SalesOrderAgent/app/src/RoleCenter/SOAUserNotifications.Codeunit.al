// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Sales.Document;
using System.Agents;

codeunit 4566 "SOA User Notifications"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    EventSubscriberInstance = Manual;
    Permissions = tabledata "SOA KPI Entry" = r, tabledata "Agent Task Log Entry" = r;

    [EventSubscriber(ObjectType::Page, Page::"Sales Quote", OnAfterGetRecordEvent, '', false, false)]
    local procedure OnAfterLoadSalesQuote(var Rec: Record "Sales Header")
    begin
        if not IsDocumentUnderReview(Rec) then
            exit;

        ShowDocumentUnderReviewNotification();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", OnAfterGetRecordEvent, '', false, false)]
    local procedure OnAfterLoadSalesOrder(var Rec: Record "Sales Header")
    begin
        if not IsDocumentUnderReview(Rec) then
            exit;

        ShowDocumentUnderReviewNotification();
    end;

    local procedure IsDocumentUnderReview(var Rec: Record "Sales Header"): Boolean
    var
        SOAKPIEntry: Record "SOA KPI Entry";
        AgentTaskLogEntry: Record "Agent Task Log Entry";
        RecordType: Option;
    begin
        SOAKPIEntry.ReadIsolation := IsolationLevel::ReadCommitted;

        case Rec."Document Type" of
            Rec."Document Type"::Order:
                RecordType := SOAKPIEntry."Record Type"::"Sales Order";
            Rec."Document Type"::Quote:
                RecordType := SOAKPIEntry."Record Type"::"Sales Quote";
            else
                exit(false);
        end;

        if not SOAKPIEntry.Get(RecordType, Rec."No.") then
            exit(false);

        if SOAKPIEntry."Task ID" = 0 then
            exit(false);

        AgentTaskLogEntry.SetRange("Task ID", SOAKPIEntry."Task ID");
        if not AgentTaskLogEntry.FindLast() then
            exit(false);

        exit(AgentTaskLogEntry.Type = AgentTaskLogEntry.Type::"User Intervention Request");
    end;

    local procedure ShowDocumentUnderReviewNotification()
    var
        DocumentIsUnderReviewNotification: Notification;
    begin
        DocumentIsUnderReviewNotification.Id := '3dc968a6-1faa-496e-b390-020dce9e1a07';
        DocumentIsUnderReviewNotification.Message := AgentCreatedDocumentUnderReviewLbl;
        DocumentIsUnderReviewNotification.AddAction(LearnMoreActionLbl, Codeunit::"SOA User Notifications", 'ShowAgentDocumentUnderReviewMessage');
        DocumentIsUnderReviewNotification.Scope := NotificationScope::LocalScope;
        if DocumentIsUnderReviewNotification.Recall() then;
        DocumentIsUnderReviewNotification.Send();
    end;

    procedure ShowAgentDocumentUnderReviewMessage(LearnMoreNotification: Notification)
    begin
        Message(AgentCreatedDocumentUnderReviewMsg);
    end;

    var
        AgentCreatedDocumentUnderReviewLbl: Label 'Sales Order Agent made changes to this page that await review.';
        AgentCreatedDocumentUnderReviewMsg: Label 'Sales Order Agent recently created or updated this page as part of a task. A user assigned to this agent must review the page before the agent can proceed with the task.';
        LearnMoreActionLbl: Label 'Learn more';
}
