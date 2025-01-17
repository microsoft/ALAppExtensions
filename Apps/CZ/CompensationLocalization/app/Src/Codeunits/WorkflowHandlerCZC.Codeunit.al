// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using System.Apps;
using System.Automation;

codeunit 31277 "Workflow Handler CZC"
{
    Permissions = tabledata "NAV App Installed App" = r;

    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        WorkflowResponseHandlingCZL: Codeunit "Workflow Response Handling CZL";
        WorkflowRequestPageHandling: Codeunit "Workflow Request Page Handling";
        WorkflowSetup: Codeunit "Workflow Setup";
        BlankDateFormula: DateFormula;
        CompensationApprWorkflowCodeTxt: Label 'COAPWCZC', Locked = true;
        CompensationApprWorkflowDescTxt: Label 'Compensation Approval Workflow';
        CompensationCodeTxt: Label 'COMP', Locked = true;
        CompensationDescTxt: Label 'Compensation';
        CompensationHeaderTypeCondnTxt: Label '<?xml version="1.0" encoding="utf-8" standalone="yes"?><ReportParameters><DataItems><DataItem name="Compensation Header">%1</DataItem><DataItem name="Compensation Line">%2</DataItem></DataItems></ReportParameters>', Locked = true;
        CompensationSendForApprovalEventDescTxt: Label 'Approval of a compensation is requested.';
        CompensationApprReqCancelledEventDescTxt: Label 'An approval request for a compensation is canceled.';
        CompensationReleasedEventDescTxt: Label 'A compensation is released.';
        FinCategoryTxt: Label 'FIN', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure AddWorkflowEventsToLibrary()
    begin
        WorkflowEventHandling.AddEventToLibrary(
          RunWorkflowOnSendCompensationForApprovalCode(), Database::"Compensation Header CZC",
          CompensationSendForApprovalEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(
          RunWorkflowOnCancelCompensationApprovalRequestCode(), Database::"Compensation Header CZC",
          CompensationApprReqCancelledEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(
          RunWorkflowOnAfterReleaseCompensationCode(), Database::"Compensation Header CZC",
          CompensationReleasedEventDescTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', false, false)]
    local procedure AddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    begin
        case EventFunctionName of
            RunWorkflowOnCancelCompensationApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  RunWorkflowOnCancelCompensationApprovalRequestCode(),
                  RunWorkflowOnSendCompensationForApprovalCode());
            WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode(),
                  RunWorkflowOnSendCompensationForApprovalCode());
            WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode(),
                  RunWorkflowOnSendCompensationForApprovalCode());
            WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode(),
                  RunWorkflowOnSendCompensationForApprovalCode());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowTableRelationsToLibrary', '', false, false)]
    local procedure AddWorkflowTableRelationsToLibrary()
    var
        ApprovalEntry: Record "Approval Entry";
        CompensationHeaderCZC: Record "Compensation Header CZC";
        CompensationLineCZC: Record "Compensation Line CZC";
    begin
        WorkflowSetup.InsertTableRelation(Database::"Compensation Header CZC", 0,
          Database::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));
        WorkflowSetup.InsertTableRelation(Database::"Compensation Header CZC", CompensationHeaderCZC.FieldNo("No."),
          Database::"Compensation Line CZC", CompensationLineCZC.FieldNo("Compensation No."));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure AddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    begin
        case ResponseFunctionName of
            WorkflowResponseHandling.SetStatusToPendingApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendCompensationForApprovalCode());
            WorkflowResponseHandling.CreateApprovalRequestsCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendCompensationForApprovalCode());
            WorkflowResponseHandling.SendApprovalRequestForApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendCompensationForApprovalCode());
            WorkflowResponseHandling.OpenDocumentCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnCancelCompensationApprovalRequestCode());
            WorkflowResponseHandling.CancelAllApprovalRequestsCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnCancelCompensationApprovalRequestCode());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure ReleaseCompensationDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        ReleaseCompensDocumentCZC: Codeunit "Release Compens. Document CZC";
    begin
        if Handled then
            exit;

        if RecRef.Number = Database::"Compensation Header CZC" then begin
            RecRef.SetTable(CompensationHeaderCZC);
            ReleaseCompensDocumentCZC.PerformManualRelease(CompensationHeaderCZC);
            Handled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure OpenCompensationDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        ReleaseCompensDocumentCZC: Codeunit "Release Compens. Document CZC";
    begin
        if Handled then
            exit;

        if RecRef.Number = Database::"Compensation Header CZC" then begin
            RecRef.SetTable(CompensationHeaderCZC);
            ReleaseCompensDocumentCZC.Reopen(CompensationHeaderCZC);
            Handled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Approval Entry", 'OnAfterGetRecordDetails', '', false, false)]
    local procedure GetDetailsOnAfterGetRecordDetails(RecRef: RecordRef; ChangeRecordDetails: Text; var Details: Text)
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        ThreePlaceholdersTok: Label '%1 ; %2: %3', Locked = true;
    begin
        case RecRef.Number() of
            Database::"Compensation Header CZC":
                begin
                    RecRef.SetTable(CompensationHeaderCZC);
                    CompensationHeaderCZC.CalcFields("Compensation Balance (LCY)");
                    Details := StrSubstNo(ThreePlaceholdersTok, CompensationHeaderCZC."Company Name",
                        CompensationHeaderCZC.FieldCaption("Compensation Balance (LCY)"), CompensationHeaderCZC."Compensation Balance (LCY)");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Compensation Approv. Mgt. CZC", 'OnSendCompensationForApprovalCZC', '', false, false)]
    local procedure RunWorkflowOnSendCompensationForApproval(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendCompensationForApprovalCode(), CompensationHeaderCZC);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Compensation Approv. Mgt. CZC", 'OnCancelCompensationApprovalRequestCZC', '', false, false)]
    local procedure RunWorkflowOnCancelCompensationApprovalRequest(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelCompensationApprovalRequestCode(), CompensationHeaderCZC);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Compens. Document CZC", 'OnAfterReleaseCompensationCZC', '', false, false)]
    local procedure RunWorkflowOnAfterReleaseCompensation(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnAfterReleaseCompensationCode(), CompensationHeaderCZC);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Compensation Header CZC", 'OnCheckCompensationReleaseRestrictions', '', false, false)]
    local procedure CheckCompensationReleaseRestrictions(var Sender: Record "Compensation Header CZC")
    begin
        CheckRecordHasUsageRestrictions(Sender);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Compensation Header CZC", 'OnCheckCompensationPostRestrictions', '', false, false)]
    local procedure CheckCompensationPostRestrictions(var Sender: Record "Compensation Header CZC")
    begin
        CheckRecordHasUsageRestrictions(Sender);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Compensation Header CZC", 'OnCheckCompensationPrintRestrictions', '', false, false)]
    local procedure CheckCompensationPrintRestrictions(var Sender: Record "Compensation Header CZC")
    begin
        CheckRecordHasUsageRestrictions(Sender);
    end;

    local procedure CheckRecordHasUsageRestrictions(var CompensationHeaderCZC: Record "Compensation Header CZC")
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.CheckRecordHasUsageRestrictions(CompensationHeaderCZC);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Compensation Header CZC", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure RemoveCompensationHeaderRestrictionsOnBeforeDeleteEvent(var Rec: Record "Compensation Header CZC"; RunTrigger: Boolean)
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.AllowRecordUsage(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Compensation Header CZC", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateCompensationHeaderRestrictionsOnAfterRenameEvent(var Rec: Record "Compensation Header CZC"; var xRec: Record "Compensation Header CZC"; RunTrigger: Boolean)
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.UpdateRestriction(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAfterInitWorkflowTemplates', '', false, false)]
    local procedure InsertWorkflowTemplates()
    begin
        if IsTestingEnvironment() then
            exit;

        InsertCompensationApprovalWorkflowTemplate();
    end;

    local procedure IsTestingEnvironment(): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        exit(NAVAppInstalledApp.Get('c4795dd0-aee3-47cc-b020-2ee93a47d4c4')); // application "Tests-Workflow"
    end;

    local procedure InsertCompensationApprovalWorkflowTemplate()
    var
        Workflow: Record Workflow;
    begin
        if Workflow.Get(WorkflowSetup.GetWorkflowTemplateCode(CompensationApprWorkflowCodeTxt)) then
            exit;
        WorkflowSetup.InsertWorkflowTemplate(Workflow, CompensationApprWorkflowCodeTxt, CompensationApprWorkflowDescTxt, FinCategoryTxt);
        InsertCompensationApprovalWorkflowDetails(Workflow);
        WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
    end;

    local procedure InsertCompensationApprovalWorkflowDetails(var Workflow: Record Workflow)
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        WorkflowSetup.InitWorkflowStepArgument(
            WorkflowStepArgument, WorkflowStepArgument."Approver Type"::"Salesperson/Purchaser",
            WorkflowStepArgument."Approver Limit Type"::"Direct Approver", 0, '', BlankDateFormula, true);

        WorkflowSetup.InsertDocApprovalWorkflowSteps(Workflow,
            BuildCompensationHeaderTypeConditions(CompensationHeaderCZC.Status::Open),
            RunWorkflowOnSendCompensationForApprovalCode(),
            BuildCompensationHeaderTypeConditions(CompensationHeaderCZC.Status::"Pending Approval"),
            RunWorkflowOnCancelCompensationApprovalRequestCode(),
            WorkflowStepArgument, true);

        ModifyCompensationApprovalWorkflowSteps(Workflow);
    end;

    procedure BuildCompensationHeaderTypeConditions(Status: Enum "Compensation Status CZC"): Text
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        CompensationLineCZC: Record "Compensation Line CZC";
    begin
        CompensationHeaderCZC.SetRange(Status, Status);
        exit(StrSubstNo(CompensationHeaderTypeCondnTxt,
                WorkflowSetup.Encode(CompensationHeaderCZC.GetView(false)),
                WorkflowSetup.Encode(CompensationLineCZC.GetView(false))));
    end;

    local procedure ModifyCompensationApprovalWorkflowSteps(Workflow: Record Workflow)
    var
        WorkflowStepRecord: Record "Workflow Step";
    begin
        WorkflowStepRecord.SetRange("Workflow Code", Workflow.Code);
        WorkflowStepRecord.SetRange("Function Name", WorkflowResponseHandling.ReleaseDocumentCode());
        WorkflowStepRecord.FindFirst();
        WorkflowStepRecord.Delete(true);
        WorkflowStepRecord.SetRange("Function Name", WorkflowResponseHandling.AllowRecordUsageCode());
        WorkflowStepRecord.FindFirst();

        WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandlingCZL.SetStatusToApprovedCode(), WorkflowStepRecord.ID);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Request Page Handling", 'OnAfterAssignEntitiesToWorkflowEvents', '', false, false)]
    local procedure AssignEntitiesToWorkflowEvents()
    begin
        WorkflowRequestPageHandling.AssignEntityToWorkflowEvent(Database::"Compensation Header CZC", CompensationCodeTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Request Page Handling", 'OnAfterInsertRequestPageEntities', '', false, false)]
    local procedure InsertRequestPageEntities()
    begin
        WorkflowRequestPageHandling.InsertReqPageEntity(CompensationCodeTxt, CompensationDescTxt, Database::"Compensation Header CZC", Database::"Compensation Line CZC");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Request Page Handling", 'OnAfterInsertRequestPageFields', '', false, false)]
    local procedure InsertRequestPageFields()
    var
        DummyCompensationHeaderCZC: Record "Compensation Header CZC";
        DummyCompensationLineCZC: Record "Compensation Line CZC";
    begin
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Compensation Header CZC", DummyCompensationHeaderCZC.FieldNo("Company Type"));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Compensation Header CZC", DummyCompensationHeaderCZC.FieldNo("Company No."));

        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Compensation Line CZC", DummyCompensationLineCZC.FieldNo("Source Type"));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Compensation Line CZC", DummyCompensationLineCZC.FieldNo("Source No."));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Compensation Line CZC", DummyCompensationLineCZC.FieldNo("Document Type"));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Compensation Line CZC", DummyCompensationLineCZC.FieldNo("Document No."));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Compensation Line CZC", DummyCompensationLineCZC.FieldNo("Currency Code"));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Compensation Line CZC", DummyCompensationLineCZC.FieldNo(Amount));
    end;

    procedure RunWorkflowOnSendCompensationForApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnSendCompensationForApprovalCZC'));
    end;

    procedure RunWorkflowOnCancelCompensationApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelCompensationApprovalRequestCZC'));
    end;

    procedure RunWorkflowOnAfterReleaseCompensationCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnAfterReleaseCompensationCZC'));
    end;
}
