// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Sales.Document;
using System.AI;
using System.Agents;

codeunit 4590 "SOA Billing"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "SOA Billing Log" = rmi, tabledata "Agent Task Message" = r, tabledata "SOA Billing Task Setup" = rmi;

    procedure LogEmailRead(AgentTaskMessageID: Guid; AgentTaskID: BigInteger)
    begin
        LogSOATrackingRecord(AgentTaskID, "SOA Billing Operation"::"Inbound Message", AgentTaskMessageID, Database::"Agent Task Message", AnalyzedIncomingEmailLbl, BlankSOABillingLog."Copilot Quota Usage Type"::"Generative AI Answer");
    end;

    procedure LogEmailGenerated(AgentTaskMessageID: Guid; AgentTaskID: BigInteger): Boolean
    begin
        if EmailLoggedAlready(AgentTaskMessageID, AgentTaskID) then
            exit(false);

        LogSOATrackingRecord(AgentTaskID, "SOA Billing Operation"::"Outbound Message", AgentTaskMessageID, Database::"Agent Task Message", GeneratedOutgoingEmailLbl, BlankSOABillingLog."Copilot Quota Usage Type"::"Generative AI Answer");
        exit(true);
    end;

    procedure LogQuoteModified(DocumentID: Guid; AgentTaskID: BigInteger): Boolean
    begin
        if not IsNewTurnForAutonomousActions(AgentTaskID) then begin
            AppendDescriptionToLog(AgentTaskID, QuoteUpdateLbl, Enum::"SOA Billing Operation"::"Quote Action");
            exit(false);
        end;

        LogSOATrackingRecord(AgentTaskID, "SOA Billing Operation"::"Quote Action", DocumentID, Database::"Sales Header", QuoteUpdateLbl, BlankSOABillingLog."Copilot Quota Usage Type"::"Autonomous Action");
        exit(true);
    end;

    procedure LogOrderModified(DocumentID: Guid; AgentTaskID: BigInteger): Boolean
    begin
        if not IsNewTurnForAutonomousActions(AgentTaskID) then begin
            AppendDescriptionToLog(AgentTaskID, OrderUpdatedLbl, Enum::"SOA Billing Operation"::"Order Action");
            exit(false);
        end;

        LogSOATrackingRecord(AgentTaskID, "SOA Billing Operation"::"Order Action", DocumentID, Database::"Sales Header", OrderUpdatedLbl, BlankSOABillingLog."Copilot Quota Usage Type"::"Autonomous Action");
        exit(true);
    end;

    procedure LogInventoryInquiryReplied(AgentTaskID: BigInteger): Boolean
    begin
        if not IsNewTurnForAutonomousActions(AgentTaskID) then begin
            AppendDescriptionToLog(AgentTaskID, InventoryCheckLbl, Enum::"SOA Billing Operation"::"Quote Action");
            exit(false);
        end;

        LogSOATrackingRecord(AgentTaskID, "SOA Billing Operation"::"Quote Action", GetInputRecordSystemID(AgentTaskID), Database::"Agent Task Message", InventoryCheckLbl, BlankSOABillingLog."Copilot Quota Usage Type"::"Autonomous Action");
        exit(true);
    end;

    procedure GetDescription(var SOABillingLog: Record "SOA Billing Log"): Text
    var
        DetailsInStream: InStream;
        DetailsText: Text;
    begin
        SOABillingLog.CalcFields(Details);
        if not SOABillingLog.Details.HasValue() then
            exit('');

        SOABillingLog.Details.CreateInStream(DetailsInStream, GetLogEncoding());
        DetailsInStream.Read(DetailsText);
        exit(DetailsText);
    end;

    procedure AddToDescription(var SOABillingLog: Record "SOA Billing Log"; NewDescriptionText: Text)
    var
        DetailsOutStream: OutStream;
        LogDescription: Text;
    begin
        LogDescription := GetDescription(SOABillingLog);
        if LogDescription.EndsWith(NewDescriptionText) then
            exit;

        if LogDescription = '' then
            LogDescription := NewDescriptionText
        else
            LogDescription += DescriptionSeparatorLbl + NewDescriptionText;
        SOABillingLog.Details.CreateOutStream(DetailsOutStream, GetLogEncoding());
        DetailsOutStream.Write(LogDescription);
        SOABillingLog.Modify(true);
    end;

    procedure TooManyUnpaidEntries(): Boolean
    var
        SOABillingLog: Record "SOA Billing Log";
    begin
        SOABillingLog.ReadIsolation := IsolationLevel::ReadCommitted;
        SOABillingLog.SetRange(Charged, false);
        exit(SOABillingLog.Count() > 200);
    end;

    local procedure EmailLoggedAlready(AgentTaskMessageID: Guid; AgentTaskID: BigInteger): Boolean
    var
        SOABillingLog: Record "SOA Billing Log";
    begin
        SOABillingLog.ReadIsolation := IsolationLevel::ReadCommitted;
        SOABillingLog.SetRange("Agent Task ID", AgentTaskID);
        SOABillingLog.SetRange("Record System ID", AgentTaskMessageID);
        SOABillingLog.SetRange("Record Table", Database::"Agent Task Message");
        exit(not SOABillingLog.IsEmpty());
    end;

    local procedure GetLogEncoding(): TextEncoding
    begin
        exit(TextEncoding::UTF8);
    end;

    local procedure LogSOATrackingRecord(AgentTaskID: BigInteger; Operation: Enum "SOA Billing Operation"; RecordSystemID: Guid;
                                                                                 RecordTable: Integer;
                                                                                 OperationDetails: Text; CopilotQuotaUsageType: Enum "Copilot Quota Usage Type")
    var
        SOABillingLog: Record "SOA Billing Log";
        SOAImpl: Codeunit "SOA Impl";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        SOABillingLog."Agent Task ID" := AgentTaskID;
        SOABillingLog.Operation := Operation;
        SOABillingLog."Record System ID" := RecordSystemID;
        SOABillingLog."Record Table" := RecordTable;
#pragma warning disable AA0139
        SOABillingLog."Company Name" := CompanyName();
#pragma warning restore AA0139
        SOABillingLog."Copilot Quota Usage Type" := CopilotQuotaUsageType;
        SOABillingLog.Insert();
        TelemetryDimensions := SOAImpl.GetCustomDimensions();
        TelemetryDimensions.Add('Operation', Format(Operation, 0, 9));
        Session.LogMessage('0000OT5', CreatedSOABillingOperationMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDimensions);
        AddToDescription(SOABillingLog, OperationDetails);
    end;

    local procedure AppendDescriptionToLog(AgentTaskID: BigInteger; OperationDetails: Text; BillingOperation: Enum "SOA Billing Operation")
    var
        SOABillingLog: Record "SOA Billing Log";
    begin
        SOABillingLog.ReadIsolation := IsolationLevel::ReadCommitted;
        SOABillingLog.SetRange("Agent Task ID", AgentTaskID);
        SOABillingLog.SetRange(Operation, BillingOperation);
        if SOABillingLog.FindLast() then
            AddToDescription(SOABillingLog, OperationDetails);
    end;

    local procedure GetInputRecordSystemID(AgentTaskID: BigInteger): Guid
    var
        AgentTaskMessage: Record "Agent Task Message";
    begin
        AgentTaskMessage.ReadIsolation := IsolationLevel::ReadCommitted;
        AgentTaskMessage.SetRange("Task ID", AgentTaskID);
        AgentTaskMessage.SetRange(Type, AgentTaskMessage.Type::Input);
        if AgentTaskMessage.FindLast() then;

        exit(AgentTaskMessage.SystemId);
    end;

    local procedure IsNewTurnForAutonomousActions(AgentTaskID: BigInteger): Boolean
    var
        SOABillingLog: Record "SOA Billing Log";
    begin
        SOABillingLog.ReadIsolation := IsolationLevel::ReadCommitted;
        SOABillingLog.SetRange("Agent Task ID", AgentTaskID);
        if not SOABillingLog.FindLast() then
            exit(true);

        // Autonomous action starts with a new incoming message
        if SOABillingLog.Operation = SOABillingLog.Operation::"Inbound Message" then
            exit(true);

        exit(false);
    end;

    procedure LogUsageSafe(CostType: Enum "Copilot Quota Usage Type"): Boolean
    var
        CopilotQuota: Codeunit "Copilot Quota";
        SOAImpl: Codeunit "SOA Impl";
    begin
        if not CopilotQuota.TryLogQuotaUsage("Copilot Capability"::"Sales Order Agent", 1, CostType) then begin
            Session.LogMessage('0000ORQ', FailedToLogUsageMsg, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, SOAImpl.GetCustomDimensions());
            exit(false);
        end;

        exit(true);
    end;

    procedure GetTooManyUnpaidEntriesMessage(): Text
    begin
        exit(StrSubstNo(TheAgentCannotRunTooManyUnpaidEntriesMsg, GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"SOA Billing Overview")));
    end;

    procedure GetBillingTaskSetupSafe(var SOABillingTaskSetup: Record "SOA Billing Task Setup")
    begin
        if not SOABillingTaskSetup.Get() then
            SOABillingTaskSetup.Insert();
    end;

    var
        BlankSOABillingLog: Record "SOA Billing Log";
        FailedToLogUsageMsg: Label 'Failed to log usage.', Locked = true;
        InventoryCheckLbl: Label 'Inventory Inquiry';
        QuoteUpdateLbl: Label 'Updated quote';
        OrderUpdatedLbl: Label 'Updated order';
        AnalyzedIncomingEmailLbl: Label 'Analyzed incoming email';
        GeneratedOutgoingEmailLbl: Label 'Generated outgoing email';
        CreatedSOABillingOperationMsg: Label 'Created SOA billing operation', Locked = true;
        TheAgentCannotRunTooManyUnpaidEntriesMsg: Label 'There are too many unpaid entries. The agent will not be able to start until they are paid. Open the page 4585 - "Sales Order Agent - Billing Overview" and invoke the "Pay entries" action. To open the page, use the following link: %1', Locked = true;
        DescriptionSeparatorLbl: Label '; ', Locked = true;
}