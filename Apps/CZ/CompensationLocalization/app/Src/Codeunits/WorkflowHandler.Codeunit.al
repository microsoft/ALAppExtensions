codeunit 31277 "Workflow Handler CZC"
{
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowSetup: Codeunit "Workflow Setup";
        CompensationSendForApprovalEventDescTxt: Label 'Approval of a compensation is requested.';
        CompensationApprReqCancelledEventDescTxt: Label 'An approval request for a compensation is canceled.';
        CompensationReleasedEventDescTxt: Label 'A compensation is released.';

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
    begin
        WorkflowSetup.InsertTableRelation(Database::"Compensation Header CZC", 0,
          Database::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));
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
