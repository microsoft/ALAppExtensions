// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Sales.Document;
using Microsoft.Foundation.Attachment;
using System.Agents;
using System.Telemetry;

codeunit 4600 "SOA Document Events"
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
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."Document Type" = Rec."Document Type"::Order then
            SOABilling.LogOrderModified(Rec.SystemId, AgentTaskID);

        if Rec."Document Type" = Rec."Document Type"::Quote then begin
            SOABilling.LogQuoteModified(Rec.SystemId, AgentTaskID);
            AddAttachmentsToDocument(Rec);
        end;

        SOABillingTask.ScheduleBillingTask();
    end;

    local procedure AddAttachmentsToDocument(var Rec: Record "Sales Header")
    var
        SOAEmail: Record "SOA Email";
        AgentTaskMessageAttachment: Record "Agent Task Message Attachment";
        AgentTaskFile: Record "Agent Task File";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SOASetupCU: Codeunit "SOA Setup";
        TelemetryDimensions: Dictionary of [Text, Text];
        FileInStream: InStream;
    begin
        SOAEmail.SetRange("Task ID", AgentTaskID);
        SOAEmail.SetRange("Attachment Transferred", false);
        TelemetryDimensions.Add('TaskId', Format(AgentTaskID));
        if SOAEmail.FindSet() then
            repeat
                TelemetryDimensions.Set('TaskMessageId', Format(SOAEmail."Task Message ID"));
                AgentTaskMessageAttachment.SetRange("Task ID", AgentTaskID);
                AgentTaskMessageAttachment.SetRange("Message ID", SOAEmail."Task Message ID");
                if AgentTaskMessageAttachment.FindSet() then
                    repeat
                        AgentTaskFile.Reset();
                        AgentTaskFile.SetRange("ID", AgentTaskMessageAttachment."File ID");
                        if AgentTaskFile.FindFirst() then begin
                            AgentTaskFile.CalcFields(Content);
                            if AgentTaskFile.Content.HasValue() then begin
                                AgentTaskFile.Content.CreateInStream(FileInStream);
                                CopyToDocument(FileInStream, Rec, AgentTaskFile."File Name");
                            end;
                        end;
                    until AgentTaskMessageAttachment.Next() = 0;
                SOAEmail."Attachment Transferred" := true;
                SOAEmail.Modify();
                FeatureTelemetry.LogUsage('0000QF5', SOASetupCU.GetFeatureName(), AttachmentsTransferredToDocLbl, TelemetryDimensions);
            until SOAEmail.Next() = 0;
    end;

    local procedure CopyToDocument(FileInStream: InStream; SalesHeader: Record "Sales Header"; FileName: Text)
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        DocumentAttachment.Init();
        DocumentAttachment.SaveAttachmentFromStream(FileInStream, SalesHeader, FileName);
    end;

    procedure SetAgentTaskID(NewAgentTaskID: BigInteger)
    begin
        AgentTaskID := NewAgentTaskID;
    end;

    var
        AgentTaskID: BigInteger;
        AttachmentsTransferredToDocLbl: Label 'Attachments successfully transferred to the document.';
}