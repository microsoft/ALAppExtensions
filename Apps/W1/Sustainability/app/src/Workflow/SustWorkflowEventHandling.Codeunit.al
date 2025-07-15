// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Workflow;

using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Posting;
using Microsoft.Utilities;
using System.Automation;

codeunit 6280 "Sust. Workflow Event Handling"
{
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        WorkflowRequestPageHandling: Codeunit "Workflow Request Page Handling";
        WorkflowSetup: Codeunit "Workflow Setup";
        BlankDateFormula: DateFormula;
        ESGCategoryTxt: Label 'ESG', Locked = true;
        ESGCategoryDescriptionTxt: Label 'Sustainability';
        SustJournalBatchApprWorkflowCodeTxt: Label 'SustJBAPW', Locked = true;
        SustJournalBatchApprWorkflowDescTxt: Label 'Sustainability Journal Batch Approval Workflow';
        SustJournalBatchTypeCondnTxt: Label '<?xml version="1.0" encoding="utf-8" standalone="yes"?><ReportParameters><DataItems><DataItem name="Sustainability Journal Batch">%1</DataItem></DataItems></ReportParameters>', Locked = true;
        SustJournalBatchSendForApprovalEventDescTxt: Label 'Approval of a Sustainability journal batch is requested.';
        SustJournalBatchApprovalRequestCancelEventDescTxt: Label 'An approval request for a Sustainability journal batch is canceled.';
        ApprovalRequestCanceledMsg: Label 'The approval request for the record has been canceled.';
        RestrictBatchUsageDetailsTxt: Label 'The restriction was imposed because the journal batch requires approval.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure AddWorkflowEventsToLibrary()
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendSustJournalBatchForApprovalCode(), Database::"Sustainability Jnl. Batch", SustJournalBatchSendForApprovalEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelSustJournalBatchApprovalRequestCode(), Database::"Sustainability Jnl. Batch", SustJournalBatchApprovalRequestCancelEventDescTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', false, false)]
    local procedure AddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    begin
        case EventFunctionName of
            RunWorkflowOnCancelSustJournalBatchApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  RunWorkflowOnCancelSustJournalBatchApprovalRequestCode(),
                  RunWorkflowOnSendSustJournalBatchForApprovalCode());
            WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode(),
                  RunWorkflowOnSendSustJournalBatchForApprovalCode());
            WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode(),
                  RunWorkflowOnSendSustJournalBatchForApprovalCode());
            WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode(),
                  RunWorkflowOnSendSustJournalBatchForApprovalCode());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAfterInsertApprovalsTableRelations', '', false, false)]
    local procedure OnAfterInsertApprovalsTableRelations()
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        WorkflowSetup.InsertTableRelation(Database::"Sustainability Jnl. Batch", 0, Database::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowTableRelationsToLibrary', '', false, false)]
    local procedure AddWorkflowTableRelationsToLibrary()
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        WorkflowSetup.InsertTableRelation(Database::"Sustainability Jnl. Batch", 0, Database::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure AddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    begin
        case ResponseFunctionName of
            WorkflowResponseHandling.CreateApprovalRequestsCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendSustJournalBatchForApprovalCode());
            WorkflowResponseHandling.SendApprovalRequestForApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendSustJournalBatchForApprovalCode());
            WorkflowResponseHandling.CancelAllApprovalRequestsCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnCancelSustJournalBatchApprovalRequestCode());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sust. Approvals Mgmt.", 'OnSendSustainabilityJournalBatchForApproval', '', false, false)]
    local procedure RunWorkflowOnSendSustJournalBatchForApproval(var SustJournalBatch: Record "Sustainability Jnl. Batch")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendSustJournalBatchForApprovalCode(), SustJournalBatch);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sust. Approvals Mgmt.", 'OnCancelSustainabilityJournalBatchApprovalRequest', '', false, false)]
    local procedure RunWorkflowOnCancelSustJournalBatchApprovalRequest(var SustJournalBatch: Record "Sustainability Jnl. Batch")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelSustJournalBatchApprovalRequestCode(), SustJournalBatch);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", OnAddWorkflowCategoriesToLibrary, '', false, false)]
    local procedure OnAddWorkflowCategoriesToLibrary()
    begin
        WorkflowSetup.InsertWorkflowCategory(ESGCategoryTxt, ESGCategoryDescriptionTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAfterInitWorkflowTemplates', '', false, false)]
    local procedure InsertWorkflowTemplates()
    begin
        InsertSustJournalBatchApprovalWorkflowTemplate();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Request Page Handling", 'OnAfterInsertRequestPageFields', '', false, false)]
    local procedure InsertRequestPageFields()
    var
        SustJournalBatch: Record "Sustainability Jnl. Batch";
    begin
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Sustainability Jnl. Batch", SustJournalBatch.FieldNo(Name));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Sustainability Jnl. Batch", SustJournalBatch.FieldNo(Recurring));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sustainability Jnl. Batch", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure RemoveSustJournalBatchRestrictionsBeforeDelete(var Rec: Record "Sustainability Jnl. Batch"; RunTrigger: Boolean)
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.AllowRecordUsage(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sustainability Jnl. Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure RemoveSustJournalLineRestrictionsBeforeDelete(var Rec: Record "Sustainability Jnl. Line"; RunTrigger: Boolean)
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.AllowRecordUsage(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sustainability Jnl. Batch", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateSustJournalBatchRestrictionsAfterRename(var Rec: Record "Sustainability Jnl. Batch"; var xRec: Record "Sustainability Jnl. Batch"; RunTrigger: Boolean)
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.UpdateRestriction(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sustainability Jnl. Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure RestrictSustJournalLineAfterInsert(var Rec: Record "Sustainability Jnl. Line"; RunTrigger: Boolean)
    begin
        RestrictSustJournalLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sustainability Jnl. Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure RestrictSustJournalLineAfterModify(var Rec: Record "Sustainability Jnl. Line"; var xRec: Record "Sustainability Jnl. Line"; RunTrigger: Boolean)
    begin
        if Format(Rec) = Format(xRec) then
            exit;

        RestrictSustJournalLine(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sustainability Jnl.-Check", 'OnAfterCheckSustainabilityJournalLine', '', false, false)]
    local procedure OnAfterCheckSustainabilityJournalLine(SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    begin
        CheckRecordHasUsageRestrictions(SustainabilityJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnBeforeAllowRecordUsageDefault', '', false, false)]
    local procedure OnBeforeAllowRecordUsageDefault(var Variant: Variant; var Handled: Boolean)
    var
        SustJournalBatch: Record "Sustainability Jnl. Batch";
        RecRef: RecordRef;
    begin
        if Handled then
            exit;

        RecRef.GetTable(Variant);
        if RecRef.Number = Database::"Sustainability Jnl. Batch" then begin
            RecRef.SetTable(SustJournalBatch);
            AllowSustJournalBatchUsage(SustJournalBatch);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnConditionalCardPageIDNotFound', '', false, false)]
    local procedure OnConditionalCardPageIDNotFound(RecordRef: RecordRef; var CardPageID: Integer)
    begin
        case RecordRef.Number of
            Database::"Sustainability Jnl. Batch":
                CardPageID := GetSustJournalBatchPageID(RecordRef);
            Database::"Sustainability Jnl. Line":
                CardPageID := GetSustJournalLinePageID(RecordRef);
        end;
    end;

    internal procedure RunWorkflowOnSendSustJournalBatchForApprovalCode(): Code[128]
    begin
        exit(UpperCase('RUNWORKFLOWONSENDSUSTJOURNALBATCHFORAPPROVAL'));
    end;

    internal procedure RunWorkflowOnCancelSustJournalBatchApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RUNWORKFLOWONCANCELSUSTJOURNALBATCHAPPROVALREQUEST'));
    end;

    internal procedure SustJournalBatchApprovalWorkflowCode(): Code[17]
    begin
        exit(SustJournalBatchApprWorkflowCodeTxt);
    end;

    internal procedure AllowSustJournalBatchUsage(SustJournalBatch: Record "Sustainability Jnl. Batch")
    var
        SustJournalLine: Record "Sustainability Jnl. Line";
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.AllowRecordUsage(SustJournalBatch);

        SustJournalLine.SetRange("Journal Template Name", SustJournalBatch."Journal Template Name");
        SustJournalLine.SetRange("Journal Batch Name", SustJournalBatch.Name);
        if SustJournalLine.FindSet() then
            repeat
                RecordRestrictionMgt.AllowRecordUsage(SustJournalLine);
            until SustJournalLine.Next() = 0;
    end;

    local procedure CheckRecordHasUsageRestrictions(SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    var
        SustJournalBatch: Record "Sustainability Jnl. Batch";
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        SustJournalBatch.Get(SustainabilityJnlLine."Journal Template Name", SustainabilityJnlLine."Journal Batch Name");

        RecordRestrictionMgt.CheckRecordHasUsageRestrictions(SustJournalBatch);
        RecordRestrictionMgt.CheckRecordHasUsageRestrictions(SustainabilityJnlLine);
    end;

    local procedure RestrictSustJournalLine(var SustJournalLine: Record "Sustainability Jnl. Line")
    var
        SustJournalBatch: Record "Sustainability Jnl. Batch";
        ApprovalsMgmt: Codeunit "Sust. Approvals Mgmt.";
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        if SustJournalBatch.Get(SustJournalLine."Journal Template Name", SustJournalLine."Journal Batch Name") then
            if ApprovalsMgmt.IsSustJournalBatchApprovalsWorkflowEnabled(SustJournalBatch) then
                RecordRestrictionMgt.RestrictRecordUsage(SustJournalLine, RestrictBatchUsageDetailsTxt);
    end;

    local procedure InsertSustJournalBatchApprovalWorkflowTemplate()
    var
        Workflow: Record Workflow;
    begin
        if Workflow.Get(WorkflowSetup.GetWorkflowTemplateCode(SustJournalBatchApprWorkflowCodeTxt)) then
            exit;

        WorkflowSetup.InsertWorkflowTemplate(Workflow, SustJournalBatchApprWorkflowCodeTxt, SustJournalBatchApprWorkflowDescTxt, ESGCategoryTxt);
        InsertSustJournalBatchApprovalWorkflowDetails(Workflow);
        WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
    end;

    local procedure InsertSustJournalBatchApprovalWorkflowDetails(var Workflow: Record Workflow)
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        WorkflowSetup.InitWorkflowStepArgument(
            WorkflowStepArgument, WorkflowStepArgument."Approver Type"::Approver,
            WorkflowStepArgument."Approver Limit Type"::"Direct Approver",
            0, '', BlankDateFormula, true);

        InsertSustJnlBatchApprovalWorkflowSteps(Workflow, BuildSustJournalBatchTypeConditions(),
          RunWorkflowOnSendSustJournalBatchForApprovalCode(),
          WorkflowResponseHandling.CreateApprovalRequestsCode(),
          WorkflowResponseHandling.SendApprovalRequestForApprovalCode(),
          RunWorkflowOnCancelSustJournalBatchApprovalRequestCode(),
          WorkflowStepArgument, true);
    end;

    local procedure BuildSustJournalBatchTypeConditions(): Text
    var
        SustJournalBatch: Record "Sustainability Jnl. Batch";
    begin
        exit(BuildSustJournalBatchTypeConditionsFromRec(SustJournalBatch));
    end;

    local procedure BuildSustJournalBatchTypeConditionsFromRec(var SustJournalBatch: Record "Sustainability Jnl. Batch"): Text
    begin
        exit(StrSubstNo(SustJournalBatchTypeCondnTxt, WorkflowSetup.Encode(SustJournalBatch.GetView(false))));
    end;

    local procedure InsertSustJnlBatchApprovalWorkflowSteps(Workflow: Record Workflow; ConditionString: Text; RecSendForApprovalEventCode: Code[128]; RecCreateApprovalRequestsCode: Code[128]; RecSendApprovalRequestForApprovalCode: Code[128]; RecCanceledEventCode: Code[128]; WorkflowStepArgument: Record "Workflow Step Argument"; ShowConfirmationMessage: Boolean)
    var
        SentForApprovalEventID: Integer;
        CreateApprovalRequestResponseID: Integer;
        SendApprovalRequestResponseID: Integer;
        OnAllRequestsApprovedEventID: Integer;
        OnRequestApprovedEventID: Integer;
        SendApprovalRequestResponseID2: Integer;
        OnRequestRejectedEventID: Integer;
        RejectAllApprovalsResponseID: Integer;
        OnRequestCanceledEventID: Integer;
        CancelAllApprovalsResponseID: Integer;
        OnRequestDelegatedEventID: Integer;
        SentApprovalRequestResponseID3: Integer;
        ShowMessageResponseID: Integer;
        RestrictUsageResponseID: Integer;
    begin
        SentForApprovalEventID := WorkflowSetup.InsertEntryPointEventStep(Workflow, RecSendForApprovalEventCode);
        WorkflowSetup.InsertEventArgument(SentForApprovalEventID, ConditionString);

        RestrictUsageResponseID := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.RestrictRecordUsageCode(),
            SentForApprovalEventID);
        CreateApprovalRequestResponseID := WorkflowSetup.InsertResponseStep(Workflow, RecCreateApprovalRequestsCode,
            RestrictUsageResponseID);
        WorkflowSetup.InsertApprovalArgument(CreateApprovalRequestResponseID,
          WorkflowStepArgument."Approver Type", WorkflowStepArgument."Approver Limit Type",
          WorkflowStepArgument."Workflow User Group Code", WorkflowStepArgument."Approver User ID",
          WorkflowStepArgument."Due Date Formula", ShowConfirmationMessage);
        SendApprovalRequestResponseID := WorkflowSetup.InsertResponseStep(Workflow, RecSendApprovalRequestForApprovalCode,
            CreateApprovalRequestResponseID);
        WorkflowSetup.InsertNotificationArgument(SendApprovalRequestResponseID, false, '', 0, '');

        OnAllRequestsApprovedEventID := WorkflowSetup.InsertEventStep(Workflow, WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode(),
            SendApprovalRequestResponseID);
        WorkflowSetup.InsertEventArgument(OnAllRequestsApprovedEventID, WorkflowSetup.BuildNoPendingApprovalsConditions());
        WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.AllowRecordUsageCode(), OnAllRequestsApprovedEventID);

        OnRequestApprovedEventID := WorkflowSetup.InsertEventStep(Workflow, WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode(),
            SendApprovalRequestResponseID);
        WorkflowSetup.InsertEventArgument(OnRequestApprovedEventID, WorkflowSetup.BuildPendingApprovalsConditions());
        SendApprovalRequestResponseID2 := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.SendApprovalRequestForApprovalCode(),
            OnRequestApprovedEventID);

        WorkflowSetup.SetNextStep(Workflow, SendApprovalRequestResponseID2, SendApprovalRequestResponseID);

        OnRequestRejectedEventID := WorkflowSetup.InsertEventStep(Workflow, WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode(),
            SendApprovalRequestResponseID);
        RejectAllApprovalsResponseID := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.RejectAllApprovalRequestsCode(),
            OnRequestRejectedEventID);
        WorkflowSetup.InsertNotificationArgument(RejectAllApprovalsResponseID, true, '', WorkflowStepArgument."Link Target Page", '');

        OnRequestCanceledEventID := WorkflowSetup.InsertEventStep(Workflow, RecCanceledEventCode, SendApprovalRequestResponseID);
        CancelAllApprovalsResponseID := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.CancelAllApprovalRequestsCode(),
            OnRequestCanceledEventID);
        WorkflowSetup.InsertNotificationArgument(CancelAllApprovalsResponseID, false, '', WorkflowStepArgument."Link Target Page", '');
        ShowMessageResponseID := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.ShowMessageCode(), CancelAllApprovalsResponseID);
        WorkflowSetup.InsertMessageArgument(ShowMessageResponseID, ApprovalRequestCanceledMsg);

        OnRequestDelegatedEventID := WorkflowSetup.InsertEventStep(Workflow, WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode(),
            SendApprovalRequestResponseID);
        SentApprovalRequestResponseID3 := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.SendApprovalRequestForApprovalCode(),
            OnRequestDelegatedEventID);

        WorkflowSetup.SetNextStep(Workflow, SentApprovalRequestResponseID3, SendApprovalRequestResponseID);
    end;

    local procedure GetSustJournalBatchPageID(RecRef: RecordRef): Integer
    var
        SustJournalBatch: Record "Sustainability Jnl. Batch";
        SustJournalLine: Record "Sustainability Jnl. Line";
    begin
        RecRef.SetTable(SustJournalBatch);

        SustJournalLine.SetRange("Journal Template Name", SustJournalBatch."Journal Template Name");
        SustJournalLine.SetRange("Journal Batch Name", SustJournalBatch.Name);
        if not SustJournalLine.FindFirst() then begin
            SustJournalLine."Journal Template Name" := SustJournalBatch."Journal Template Name";
            SustJournalLine."Journal Batch Name" := SustJournalBatch.Name;
            RecRef.GetTable(SustJournalLine);
            exit(Page::"Sustainability Journal");
        end;

        RecRef.GetTable(SustJournalLine);
        exit(GetSustJournalLinePageID(RecRef));
    end;

    local procedure GetSustJournalLinePageID(RecRef: RecordRef): Integer
    var
        SustJournalLine: Record "Sustainability Jnl. Line";
        SustJournalTemplate: Record "Sustainability Jnl. Template";
    begin
        RecRef.SetTable(SustJournalLine);
        SustJournalTemplate.Get(SustJournalLine."Journal Template Name");

        exit(Page::"Sustainability Journal");
    end;
}