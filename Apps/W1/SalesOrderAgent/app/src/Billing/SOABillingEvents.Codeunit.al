// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Sales.Document;

codeunit 4599 "SOA Billing Events"
{
    EventSubscriberInstance = Manual;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterModifyEvent, '', false, false)]
    local procedure OnChangeSalesHeader(var Rec: Record "Sales Header")
    var
        SOABilling: Codeunit "SOA Billing";
        SOABillingTask: Codeunit "SOA Billing Task";
        ScheduleTask: Boolean;
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."Document Type" = Rec."Document Type"::Order then
            ScheduleTask := SOABilling.LogOrderModified(Rec.SystemId, AgentTaskID);

        if Rec."Document Type" = Rec."Document Type"::Quote then
            ScheduleTask := SOABilling.LogQuoteModified(Rec.SystemId, AgentTaskID);

        if not ScheduleTask then
            exit;

        LastBillingTaskTime := SOABillingTask.ScheduleBillingTaskInNextInterval(LastBillingTaskTime);
    end;

    [EventSubscriber(ObjectType::Page, Page::"SOA Multi Items Availability", OnOpenPageEvent, '', false, false)]
    local procedure LogInventoryInquiryReplied()
    var
        SOABilling: Codeunit "SOA Billing";
        SOABillingTask: Codeunit "SOA Billing Task";
    begin
        if not SOABilling.LogInventoryInquiryReplied(AgentTaskID) then
            exit;

        LastBillingTaskTime := SOABillingTask.ScheduleBillingTaskInNextInterval(LastBillingTaskTime);
    end;

    procedure SetAgentTaskID(NewAgentTaskID: BigInteger)
    begin
        AgentTaskID := NewAgentTaskID;
    end;

    var
        AgentTaskID: BigInteger;
        LastBillingTaskTime: DateTime;
}