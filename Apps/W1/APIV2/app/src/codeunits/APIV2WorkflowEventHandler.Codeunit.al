// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.API.V2;

using Microsoft.Inventory.Requisition;
using System;
using System.Automation;

codeunit 30006 "APIV2 - Workflow Event Handler"
{
    [EventSubscriber(ObjectType::Table, Database::"Workflow Webhook Subscription", 'OnCreateWorkflowEventConditions', '', false, false)]
    local procedure OnCreateWorkflowEventConditions(EventCode: Code[128]; ConditionsObject: DotNet JObject; var EventConditions: FilterPageBuilder; var ConditionsCount: Integer; var Result: Text; var IsHandled: Boolean; sender: Record "Workflow Webhook Subscription")
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        WorkflowWebhookSetup: Codeunit "Workflow Webhook Setup";
    begin
        case EventCode of
            WorkflowEventHandling.RunWorkflowOnSendRequisitionWkshBatchForApprovalCode():
                begin
                    IsHandled := true;
                    sender.AddEventConditionsWrapper('Conditions', ConditionsObject, Page::"APIV2 - Requisition Wksh. Name", EventConditions, ConditionsCount);
                    Result := RequestPageParametersHelper.GetViewFromDynamicRequestPage(EventConditions, WorkflowWebhookSetup.GetPurchPayCategoryTxt(), Database::"Requisition Wksh. Name");
                end;
        end;
    end;
}