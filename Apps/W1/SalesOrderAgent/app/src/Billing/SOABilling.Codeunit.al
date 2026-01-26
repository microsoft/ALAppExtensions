// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Sales.Document;
using System.Agents;
using System.AI;
using System.Telemetry;

codeunit 4590 "SOA Billing"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Agent Task Message" = r;

    procedure LogEmailRead(AgentTaskMessageID: Guid; AgentTaskID: BigInteger)
    begin
        LogSOATrackingRecord(AgentTaskID, AgentTaskMessageID, "SOA Billing Operation"::"Inbound Message", AgentTaskMessageID, Database::"Agent Task Message", AnalyzedIncomingEmailLbl, Enum::"Copilot Quota Usage Type"::"Generative AI Answer", '');
    end;

    procedure LogEmailGenerated(AgentTaskMessageID: Guid; AgentTaskID: BigInteger; AgentMessageID: Guid): Boolean
    begin
        LogSOATrackingRecord(AgentTaskID, AgentMessageID, "SOA Billing Operation"::"Outbound Message", AgentTaskMessageID, Database::"Agent Task Message", GeneratedOutgoingEmailLbl, Enum::"Copilot Quota Usage Type"::"Generative AI Answer", '');
        exit(true);
    end;

    procedure LogQuoteModified(DocumentID: Guid; AgentTaskID: BigInteger): Boolean
    var
        AgentMessageID: Guid;
    begin
        LogSOATrackingRecord(AgentTaskID, AgentMessageID, "SOA Billing Operation"::"Quote Action", DocumentID, Database::"Sales Header", QuoteUpdateLbl, Enum::"Copilot Quota Usage Type"::"Autonomous Action", '');
        exit(true);
    end;

    procedure LogOrderModified(DocumentID: Guid; AgentTaskID: BigInteger): Boolean
    var
        AgentMessageID: Guid;
    begin
        LogSOATrackingRecord(AgentTaskID, AgentMessageID, "SOA Billing Operation"::"Order Action", DocumentID, Database::"Sales Header", OrderUpdatedLbl, Enum::"Copilot Quota Usage Type"::"Autonomous Action", '');
        exit(true);
    end;

    procedure LogInventoryInquiryReplied(AgentTaskID: BigInteger): Boolean
    var
        AgentMessageID: Guid;
    begin
        LogSOATrackingRecord(AgentTaskID, AgentMessageID, "SOA Billing Operation"::"Item Availability", AgentMessageID, Database::"Agent Task Message", InventoryCheckLbl, Enum::"Copilot Quota Usage Type"::"Autonomous Action", '');
        exit(true);
    end;

    procedure LogRelevantAttachment(AgentTaskMessageAttachmentID: Guid; AgentTaskID: BigInteger; AgentMessageID: Guid; FileID: BigInteger)
    begin
        LogSOATrackingRecord(AgentTaskID, AgentTaskMessageAttachmentID, "SOA Billing Operation"::"Relevant Attachment", AgentTaskMessageAttachmentID, Database::"Agent Task Message Attachment", AnalyzedAttachmentLbl, Enum::"Copilot Quota Usage Type"::"Autonomous Action", Format(FileID, 0, 9));
    end;

    procedure LogIrrelevantAttachment(AgentTaskMessageAttachmentID: Guid; AgentTaskID: BigInteger; AgentMessageID: Guid; FileID: BigInteger)
    begin
        LogSOATrackingRecord(AgentTaskID, AgentMessageID, "SOA Billing Operation"::"Irrelevant Attachment", AgentTaskMessageAttachmentID, Database::"Agent Task Message Attachment", AnalyzedAttachmentLbl, Enum::"Copilot Quota Usage Type"::"Generative AI Answer", Format(FileID, 0, 9));
    end;

    local procedure LogSOATrackingRecord(AgentTaskID: BigInteger; AgentMessageID: Guid; Operation: Enum "SOA Billing Operation"; RecordSystemID: Guid; RecordTable: Integer; OperationDetails: Text; CopilotQuotaUsageType: Enum "Copilot Quota Usage Type"; AdditionalIdentifier: Text)
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SOASetup: Codeunit "SOA Setup";
        CopilotQuota: Codeunit "Copilot Quota";
        TelemetryDimensions: Dictionary of [Text, Text];
        UniqueID: Text[1024];
    begin
        UniqueID := GetUniqueID(AgentTaskID, Operation, RecordSystemID, RecordTable, AdditionalIdentifier);
        if CopilotQuota.IsAgentUserAIConsumptionLogged(UniqueID) then
            exit;

        // Log telemetry 
        TelemetryDimensions.Add('AgentUserSecurityID', UserSecurityId());
        TelemetryDimensions.Add('TaskID', Format(AgentTaskID));
        TelemetryDimensions.Add('MessageID', Format(AgentMessageID));
        TelemetryDimensions.Add('Operation', Format(Operation, 0, 9));
        FeatureTelemetry.LogUsage('0000OT5', SOASetup.GetFeatureName(), CreatedSOABillingOperationMsg, TelemetryDimensions);

        if Operation in [Operation::"Order Action", Operation::"Quote Action"] then
            FeatureTelemetry.LogUptake('0000QB2', SOASetup.GetFeatureName(), Enum::"Feature Uptake Status"::Used, TelemetryDimensions);

        CopilotQuota.LogAgentUserAIConsumption(Enum::"Copilot Capability"::"Sales Order Agent", 1, CopilotQuotaUsageType, AgentTaskID, Format(Operation), OperationDetails, UniqueID);
    end;

    local procedure GetUniqueID(AgentTaskID: BigInteger; Operation: Enum "SOA Billing Operation"; RecordSystemID: Guid; RecordTable: Integer; AdditionalIdentifier: Text): Text[1024]
    var
        UniqueID: Text[1024];
    begin
        UniqueID := Format(Enum::"Agent Metadata Provider"::"SO Agent", 0, 9) + '-' + Format(AgentTaskID, 0, 9) + '-' + Format(GetTurn(AgentTaskID), 0, 9) + '-' + Format(Operation, 0, 9);

        if ((Operation = Operation::"Inbound Message") or
            (Operation = Operation::"Outbound Message") or
            (Operation = Operation::"Relevant Attachment") or
            (Operation = Operation::"Irrelevant Attachment")) then
            UniqueID += '-' + Format(RecordTable, 0, 9) + '-' + Format(RecordSystemID);

        if ((Operation = Operation::"Relevant Attachment") or
            (Operation = Operation::"Irrelevant Attachment")) then
            UniqueID += '-' + AdditionalIdentifier;
        exit(UniqueID);
    end;

    local procedure GetTurn(AgentTaskID: BigInteger): Integer
    var
        AgentTaskMessage: Record "Agent Task Message";
        TurnID: Integer;
    begin
        AgentTaskMessage.SetRange("Task ID", AgentTaskID);
        AgentTaskMessage.SetRange(Type, AgentTaskMessage.Type::Input);
        AgentTaskMessage.SetFilter(Status, '<>%1&<>%2&<>%3', AgentTaskMessage.Status::" ", AgentTaskMessage.Status::Discarded, AgentTaskMessage.Status::Rejected);
        AgentTaskMessage.ReadIsolation := IsolationLevel::ReadUncommitted;
        TurnID := AgentTaskMessage.Count();
        if TurnID = 0 then  // Cover the case when we issue a charge before the message is inserted
            exit(1);

        exit(TurnID);
    end;

    var
        InventoryCheckLbl: Label 'Inventory Inquiry';
        QuoteUpdateLbl: Label 'Updated quote';
        OrderUpdatedLbl: Label 'Updated order';
        AnalyzedIncomingEmailLbl: Label 'Analyzed incoming email';
        AnalyzedAttachmentLbl: Label 'Analyzed attachment';
        GeneratedOutgoingEmailLbl: Label 'Generated outgoing email';
        CreatedSOABillingOperationMsg: Label 'Created SOA billing operation', Locked = true;
}