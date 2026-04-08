// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Format;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.EServices.EDocumentConnector.Microsoft365;
using System.Agents;
using System.Environment;

codeunit 3316 "PA Events"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. PDF File Format", OnAfterSetIStructureReceivedEDocumentForPdf, '', false, false)]
    local procedure UseMLLMWhenEnabledInSetup(var Result: Enum "Structure Received E-Doc.")
    var
        PayablesAgentSetup: Record "Payables Agent Setup";
    begin
        PayablesAgentSetup.GetSetup();
        if PayablesAgentSetup."Use MLLM Processing" then
            Result := "Structure Received E-Doc."::MLLM;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Import", OnAfterProcessIncomingEDocument, '', false, false)]
    local procedure TrackFinalizedEDocuments(EDocument: Record "E-Document")
    var
        PayablesAgent: Codeunit "Payables Agent";
        PayablesAgentKPI: Codeunit "Payables Agent KPI";
        PayablesAgentSetup: Codeunit "Payables Agent Setup";
        SessionID: BigInteger;
    begin
        if not PayablesAgentSetup.WasEDocumentCreatedByAgent(EDocument) then
            exit;
        EDocument.CalcFields("Import Processing Status");
        if EDocument."Import Processing Status" <> "Import E-Doc. Proc. Status"::Processed then
            exit;
        if not PayablesAgent.IsPayablesAgentSession(SessionID) then
            PayablesAgentKPI.InsertKPIEntry("PA KPI Scenario"::"Agent E-Docs Finalized by User")
        else
            PayablesAgentKPI.InsertKPIEntry("PA KPI Scenario"::"Agent E-Docs Finalized by Agent");
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", OnFeedbackEvent, '', false, false)]
    local procedure OnFeedbackEventForPayablesAgentTasks(PageId: Integer; Context: Dictionary of [Text, Text]; var Handled: Boolean)
    begin
        IsAgentTaskFeedbackContext(Context, Handled);
        if Handled then
            exit;
        IsAgentDraftPageFeedbackContext(Context, Handled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Purchase Draft Utility", OnInsertedEDocumentPurchaseHeader, '', false, false)]
    local procedure UpdateAgentTaskTitleOnPurchaseDocumentDraftCreated(EDocument: Record "E-Document"; EDocumentPurchaseHeader: Record "E-Document Purchase Header")
    var
        PayablesAgent: Codeunit "Payables Agent";
        PayablesAgentSetup: Codeunit "Payables Agent Setup";
        AgentTaskID: BigInteger;
    begin
        if EDocumentPurchaseHeader.IsTemporary() then
            exit;
        if not PayablesAgentSetup.WasEDocumentCreatedByAgent(EDocument) then
            exit;
        if not TryFindAgentTaskID(EDocument, AgentTaskID) then
            exit;

        PayablesAgent.SetAgentTaskTitle(AgentTaskID, CopyStr(EDocumentPurchaseHeader."Sales Invoice No.", 1, 50), CopyStr(EDocumentPurchaseHeader."Vendor Company Name", 1, 100));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. M365 Conn. Events", OnGetOutlookCategoryDescription, '', false, false)]
    local procedure OnGetOutlookCategoryDescription(var CategoryDescription: Text)
    var
        ProcessedByPayablesAgentEmailCategoryTok: Label 'Processed by Payables Agent', Locked = true;
    begin
        CategoryDescription := ProcessedByPayablesAgentEmailCategoryTok;
    end;

    local procedure TryFindAgentTaskID(EDocument: Record "E-Document"; var AgentTaskID: BigInteger) Found: Boolean
    var
        AgentTaskMessage: Record "Agent Task Message";
    begin
        AgentTaskMessage.SetRange("External ID", Format(EDocument."Entry No"));
        Found := AgentTaskMessage.FindFirst();
        AgentTaskID := AgentTaskMessage."Task ID";
        exit(Found);
    end;

    local procedure IsAgentDraftPageFeedbackContext(Context: Dictionary of [Text, Text]; var Handled: Boolean)
    var
        PayablesAgentOCV: Codeunit "Payables Agent OCV";
        FeedbackType: Text;
    begin
        // Scenario: Thumbs feedback from E-Document Purchase Draft page (Infotips)
        if not (Context.ContainsKey('FormName') and Context.ContainsKey('Copilot.Feedback.Target')) then
            exit;

        if Context.Get('FormName') <> 'E-Document Purchase Draft' then
            exit;

        if Context.ContainsKey('Feedback.Type') then
            FeedbackType := Context.Get('Feedback.Type');

        Handled := PayablesAgentOCV.TriggerPayableAgentDraftThumbsFeedback(FeedbackType);
    end;

    local procedure IsAgentTaskFeedbackContext(Context: Dictionary of [Text, Text]; var Handled: Boolean)
    var
        PayablesAgentOCV: Codeunit "Payables Agent OCV";
        FeedbackType: Text;
    begin
        // Scenario: Thumbs feedback from Payables Agent Tasks pane
        if not (Context.ContainsKey('Copilot.Agents.AgentTypeId') and Context.ContainsKey('Copilot.Agents.TaskId')) then
            exit;

        if Context.Get('Copilot.Agents.AgentTypeId') <> Format(Enum::"Agent Metadata Provider"::"Payables Agent".AsInteger()) then
            exit;

        if Context.ContainsKey('Feedback.Type') then
            FeedbackType := Context.Get('Feedback.Type');

        Handled := PayablesAgentOCV.TriggerPayablesAgentTaskThumbsFeedback(FeedbackType, Context.Get('Copilot.Agents.TaskId'));
    end;


}