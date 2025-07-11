// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Workflow;

using Microsoft.Sustainability.Journal;
using System.Automation;
using System.Utilities;

codeunit 6279 "Sust. Approvals Mgmt."
{
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowEventHandling: Codeunit "Sust. Workflow Event Handling";
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';
        PendingJournalBatchApprovalExistsErr: Label 'An approval request already exists.', Comment = '%1 is the Document No. of the journal line';
        ApprovedJournalBatchApprovalExistsMsg: Label 'An approval request for this batch has already been sent and approved. Do you want to send another approval request?';
        PreventDeleteRecordWithOpenApprovalEntryMsg: Label 'You can''t delete a record that has open approval entries. Do you want to cancel the approval request first?';
        PreventInsertRecordWithOpenApprovalEntryForCurrUserMsg: Label 'You can''t insert a record for active batch approval request. To insert a record, you can Reject approval and document requested changes in approval comment lines.';
        PreventInsertRecordWithOpenApprovalEntryMsg: Label 'You can''t insert a record that has active approval request. Do you want to cancel the batch approval request first?';
        PendingApprovalLbl: Label 'Pending Approval';
        RestrictBatchUsageDetailsLbl: Label 'The restriction was imposed because the journal batch requires approval.';
        ImposedRestrictionLbl: Label 'Imposed restriction';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnPopulateApprovalEntryArgument, '', false, false)]
    local procedure PopulateApprovalEntryArgument(WorkflowStepInstance: Record "Workflow Step Instance"; var ApprovalEntryArgument: Record "Approval Entry"; var RecRef: RecordRef)
    var
        SustJournalBatch: Record "Sustainability Jnl. Batch";
    begin
        if RecRef.Number <> Database::"Sustainability Jnl. Batch" then
            exit;

        RecRef.SetTable(SustJournalBatch);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPreventDeletingRecordWithOpenApprovalEntryElseCase', '', false, false)]
    local procedure OnPreventDeletingRecordWithOpenApprovalEntryElseCase(RecRef: RecordRef)
    var
        SustJournalBatch: Record "Sustainability Jnl. Batch";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if RecRef.Number <> Database::"Sustainability Jnl. Batch" then
            exit;

        if ConfirmManagement.GetResponseOrDefault(PreventDeleteRecordWithOpenApprovalEntryMsg, true) then begin
            RecRef.SetTable(SustJournalBatch);
            OnCancelSustainabilityJournalBatchApprovalRequest(SustJournalBatch);
        end else
            Error('');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPreventInsertRecIfOpenApprovalEntryExistElseCase', '', false, false)]
    local procedure OnPreventInsertRecIfOpenApprovalEntryExistElseCase(RecRef: RecordRef)
    var
        SustJournalBatch: Record "Sustainability Jnl. Batch";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if RecRef.Number <> Database::"Sustainability Jnl. Batch" then
            exit;

        if ApprovalsMgmt.HasOpenOrPendingApprovalEntriesForCurrentUser(RecRef.RecordId) and ApprovalsMgmt.CanCancelApprovalForRecord(RecRef.RecordId) then
            Error(PreventInsertRecordWithOpenApprovalEntryForCurrUserMsg);

        if (ApprovalsMgmt.HasOpenApprovalEntries(RecRef.RecordId) and ApprovalsMgmt.CanCancelApprovalForRecord(RecRef.RecordId)) then
            if ConfirmManagement.GetResponseOrDefault(PreventInsertRecordWithOpenApprovalEntryMsg, true) then begin
                RecRef.SetTable(SustJournalBatch);
                OnCancelSustainabilityJournalBatchApprovalRequest(SustJournalBatch);
            end else
                Error('');
    end;


    [EventSubscriber(ObjectType::Table, Database::"Sustainability Jnl. Batch", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteApprovalEntriesAfterDeleteSustJournalBatch(var Rec: Record "Sustainability Jnl. Batch"; RunTrigger: Boolean)
    var
        SustJnlTemplate: Record "Sustainability Jnl. Batch";
    begin
        if Rec.IsTemporary then
            exit;

        if SustJnlTemplate.Get(Rec."Journal Template Name") then
            ApprovalsMgmt.DeleteApprovalEntries(Rec.RecordId);
    end;

    internal procedure ApproveSustJournalLineRequest(SustJournalLine: Record "Sustainability Jnl. Line")
    var
        SustJournalBatch: Record "Sustainability Jnl. Batch";
        ApprovalEntry: Record "Approval Entry";
    begin
        SustJournalBatch.Get(SustJournalLine."Journal Template Name", SustJournalLine."Journal Batch Name");
        if ApprovalsMgmt.FindOpenApprovalEntryForCurrUser(ApprovalEntry, SustJournalBatch.RecordId) then
            ApprovalsMgmt.ApproveRecordApprovalRequest(SustJournalBatch.RecordId);
    end;

    internal procedure RejectSustJournalLineRequest(SustJournalLine: Record "Sustainability Jnl. Line")
    var
        SustJournalBatch: Record "Sustainability Jnl. Batch";
        ApprovalEntry: Record "Approval Entry";
    begin
        SustJournalBatch.Get(SustJournalLine."Journal Template Name", SustJournalLine."Journal Batch Name");
        if ApprovalsMgmt.FindOpenApprovalEntryForCurrUser(ApprovalEntry, SustJournalBatch.RecordId) then
            ApprovalsMgmt.RejectRecordApprovalRequest(SustJournalBatch.RecordId);
    end;

    internal procedure DelegateSustJournalLineRequest(SustJournalLine: Record "Sustainability Jnl. Line")
    var
        SustJournalBatch: Record "Sustainability Jnl. Batch";
        ApprovalEntry: Record "Approval Entry";
    begin
        SustJournalBatch.Get(SustJournalLine."Journal Template Name", SustJournalLine."Journal Batch Name");
        if ApprovalsMgmt.FindOpenApprovalEntryForCurrUser(ApprovalEntry, SustJournalBatch.RecordId) then
            ApprovalsMgmt.DelegateRecordApprovalRequest(SustJournalBatch.RecordId);
    end;

    internal procedure TrySendJournalBatchApprovalRequest(var SustJournalLine: Record "Sustainability Jnl. Line")
    var
        SustJournalBatch: Record "Sustainability Jnl. Batch";
    begin
        GetSustJournalBatch(SustJournalBatch, SustJournalLine);
        CheckSustJournalBatchApprovalsWorkflowEnabled(SustJournalBatch);
        if ApprovalsMgmt.HasOpenApprovalEntries(SustJournalBatch.RecordId) or
           HasAnyOpenJournalLineApprovalEntries(SustJournalBatch."Journal Template Name", SustJournalBatch.Name)
        then
            Error(PendingJournalBatchApprovalExistsErr);
        if ApprovalsMgmt.HasApprovedApprovalEntries(SustJournalBatch.RecordId) then
            if not Confirm(ApprovedJournalBatchApprovalExistsMsg) then
                exit;
        OnSendSustainabilityJournalBatchForApproval(SustJournalBatch);
    end;

    internal procedure TryCancelJournalBatchApprovalRequest(var SustJournalLine: Record "Sustainability Jnl. Line")
    var
        SustJournalBatch: Record "Sustainability Jnl. Batch";
    begin
        GetSustJournalBatch(SustJournalBatch, SustJournalLine);
        OnCancelSustainabilityJournalBatchApprovalRequest(SustJournalBatch);
    end;

    internal procedure IsSustJournalBatchApprovalsWorkflowEnabled(var SustJournalBatch: Record "Sustainability Jnl. Batch") Result: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeIsSustJournalBatchApprovalsWorkflowEnabled(SustJournalBatch, Result, IsHandled);
        if IsHandled then
            exit(Result);

        exit(WorkflowManagement.CanExecuteWorkflow(SustJournalBatch,
            WorkflowEventHandling.RunWorkflowOnSendSustJournalBatchForApprovalCode()));
    end;

    procedure CheckSustJournalBatchApprovalsWorkflowEnabled(var SustJournalBatch: Record "Sustainability Jnl. Batch"): Boolean
    begin
        if not WorkflowManagement.CanExecuteWorkflow(SustJournalBatch, WorkflowEventHandling.RunWorkflowOnSendSustJournalBatchForApprovalCode()) then
            Error(NoWorkflowEnabledErr);

        exit(true);
    end;

    internal procedure HasAnyOpenJournalLineApprovalEntries(JournalTemplateName: Code[20]; JournalBatchName: Code[20]): Boolean
    var
        SustJournalLine: Record "Sustainability Jnl. Line";
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.SetRange("Table ID", DATABASE::"Sustainability Jnl. Line");
        ApprovalEntry.SetRange(Status, ApprovalEntry.Status::Open);
        // Initial check before performing an expensive query due to the "Related to Change" flow field.
        if not ApprovalEntry.IsEmpty() then
            ApprovalEntry.SetRange("Related to Change", false);
        if ApprovalEntry.IsEmpty() then
            exit(false);

        SustJournalLine.SetRange("Journal Template Name", JournalTemplateName);
        SustJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        if SustJournalLine.IsEmpty() then
            exit(false);

        if SustJournalLine.Count < ApprovalEntry.Count then begin
            SustJournalLine.FindSet();
            repeat
                if ApprovalsMgmt.HasOpenApprovalEntries(SustJournalLine.RecordId) then
                    exit(true);
            until SustJournalLine.Next() = 0;
        end else begin
            ApprovalEntry.FindSet();
            repeat
                if HasApprovalEntryRecordIDWithSameTemplateAndBatchName(ApprovalEntry, JournalTemplateName, JournalBatchName) then
                    exit(true);
            until ApprovalEntry.Next() = 0;
        end;
    end;

    internal procedure ShowJournalApprovalEntries(var SustJournalLine: Record "Sustainability Jnl. Line")
    var
        ApprovalEntry: Record "Approval Entry";
        SustJournalBatch: Record "Sustainability Jnl. Batch";
    begin
        GetSustJournalBatch(SustJournalBatch, SustJournalLine);

        ApprovalEntry.SetFilter("Table ID", '%1|%2', Database::"Sustainability Jnl. Batch", Database::"Sustainability Jnl. Line");
        ApprovalEntry.SetFilter("Record ID to Approve", '%1|%2', SustJournalBatch.RecordId(), SustJournalLine.RecordId());
        ApprovalEntry.SetRange("Related to Change", false);
        Page.Run(Page::"Approval Entries", ApprovalEntry);
    end;

    internal procedure GetSustJnlBatchApprovalStatus(SustJournalLine: Record "Sustainability Jnl. Line"; var SustJnlBatchApprovalStatus: Text[20]; EnabledSustJnlBatchWorkflowsExist: Boolean)
    var
        ApprovalEntry: Record "Approval Entry";
        SustJournalBatch: Record "Sustainability Jnl. Batch";
    begin
        Clear(SustJnlBatchApprovalStatus);
        if not EnabledSustJnlBatchWorkflowsExist then
            exit;
        if not SustJournalBatch.Get(SustJournalLine."Journal Template Name", SustJournalLine."Journal Batch Name") then
            exit;

        if ApprovalsMgmt.FindLastApprovalEntryForCurrUser(ApprovalEntry, SustJournalBatch.RecordId) then
            SustJnlBatchApprovalStatus := GetApprovalStatusFromApprovalEntry(ApprovalEntry, SustJournalBatch)
        else
            if ApprovalsMgmt.FindApprovalEntryByRecordId(ApprovalEntry, SustJournalBatch.RecordId) then
                SustJnlBatchApprovalStatus := GetApprovalStatusFromApprovalEntry(ApprovalEntry, SustJournalBatch);
    end;

    internal procedure CleanSustJournalApprovalStatus(SustJournalLine: Record "Sustainability Jnl. Line"; var GenJnlBatchApprovalStatus: Text[20])
    var
        SustJournalBatch: Record "Sustainability Jnl. Batch";
        ApprovalEntry: Record "Approval Entry";
    begin
        if SustJournalBatch.Get(SustJournalLine."Journal Template Name", SustJournalLine."Journal Batch Name") then
            if IsSustJournalBatchApprovalsWorkflowEnabled(SustJournalBatch) then
                if ApprovalsMgmt.FindLastApprovalEntryForCurrUser(ApprovalEntry, SustJournalBatch.RecordId) and (ApprovalEntry.Status = ApprovalEntry.Status::Approved) then
                    GenJnlBatchApprovalStatus := CopyStr(ImposedRestrictionLbl, 1, 20)
                else
                    if ApprovalsMgmt.FindApprovalEntryByRecordId(ApprovalEntry, SustJournalBatch.RecordId) and (ApprovalEntry.Status = ApprovalEntry.Status::Approved) then
                        GenJnlBatchApprovalStatus := CopyStr(ImposedRestrictionLbl, 1, 20);
    end;

    local procedure HasApprovalEntryRecordIDWithSameTemplateAndBatchName(ApprovalEntry: Record "Approval Entry"; JournalTemplateName: Code[20]; JournalBatchName: Code[20]): Boolean
    var
        SustJournalLine: Record "Sustainability Jnl. Line";
        SustJournalLineRecRef: RecordRef;
        SustJournalLineRecordID: RecordID;
    begin
        SustJournalLineRecordID := ApprovalEntry."Record ID to Approve";
        SustJournalLineRecRef := SustJournalLineRecordID.GetRecord();
        SustJournalLineRecRef.SetTable(SustJournalLine);
        if (SustJournalLine."Journal Template Name" = JournalTemplateName) and
           (SustJournalLine."Journal Batch Name" = JournalBatchName)
        then
            exit(true);
    end;

    local procedure GetSustJournalBatch(var SustJournalBatch: Record "Sustainability Jnl. Batch"; var SustJournalLine: Record "Sustainability Jnl. Line")
    begin
        if not SustJournalBatch.Get(SustJournalLine."Journal Template Name", SustJournalLine."Journal Batch Name") then
            SustJournalBatch.Get(SustJournalLine.GetFilter("Journal Template Name"), SustJournalLine.GetFilter("Journal Batch Name"));
    end;

    local procedure GetApprovalStatusFromApprovalEntry(var ApprovalEntry: Record "Approval Entry"; SustJournalBatch: Record "Sustainability Jnl. Batch"): Text[20]
    var
        RestrictedRecord: Record "Restricted Record";
        SustJournalLine: Record "Sustainability Jnl. Line";
        FieldRef: FieldRef;
        ApprovalStatusName: Text;
    begin
        GetApprovalEntryStatusFieldRef(FieldRef, ApprovalEntry);
        ApprovalStatusName := GetApprovalEntryStatusValueName(FieldRef, ApprovalEntry);
        if ApprovalStatusName = 'Open' then
            exit(CopyStr(PendingApprovalLbl, 1, 20));
        if ApprovalStatusName = 'Approved' then begin
            RestrictedRecord.SetRange(Details, RestrictBatchUsageDetailsLbl);
            if not RestrictedRecord.IsEmpty() then begin
                RestrictedRecord.Reset();
                SustJournalLine.ReadIsolation(IsolationLevel::ReadUncommitted);
                SustJournalLine.SetLoadFields("Journal Template Name", "Journal Batch Name", "Line No.");
                SustJournalLine.SetRange("Journal Template Name", SustJournalBatch."Journal Template Name");
                SustJournalLine.SetRange("Journal Batch Name", SustJournalBatch.Name);
                if SustJournalLine.FindSet() then
                    repeat
                        RestrictedRecord.SetRange("Record ID", SustJournalLine.RecordId);
                        if not RestrictedRecord.IsEmpty() then
                            exit(CopyStr(ImposedRestrictionLbl, 1, 20));
                    until SustJournalLine.Next() = 0;
            end;
        end;
        exit(CopyStr(GetApprovalEntryStatusValueCaption(FieldRef, ApprovalEntry), 1, 20));
    end;

    local procedure GetApprovalEntryStatusFieldRef(var FieldRef: FieldRef; var ApprovalEntry: Record "Approval Entry")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(ApprovalEntry);
        FieldRef := RecordRef.Field(ApprovalEntry.FieldNo(Status));
    end;

    local procedure GetApprovalEntryStatusValueName(var FieldRef: FieldRef; ApprovalEntry: Record "Approval Entry"): Text
    begin
        exit(FieldRef.GetEnumValueName(ApprovalEntry.Status.AsInteger() + 1));
    end;

    local procedure GetApprovalEntryStatusValueCaption(var FieldRef: FieldRef; ApprovalEntry: Record "Approval Entry"): Text
    begin
        exit(FieldRef.GetEnumValueCaption(ApprovalEntry.Status.AsInteger() + 1));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsSustJournalBatchApprovalsWorkflowEnabled(var SustJournalBatch: Record "Sustainability Jnl. Batch"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendSustainabilityJournalBatchForApproval(var SustJournalBatch: Record "Sustainability Jnl. Batch")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelSustainabilityJournalBatchApprovalRequest(var SustJournalBatch: Record "Sustainability Jnl. Batch")
    begin
    end;
}