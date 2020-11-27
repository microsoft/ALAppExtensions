codeunit 11739 "Workflow Handler CZP"
{
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowSetup: Codeunit "Workflow Setup";
        CashDocSendForApprovalEventDescTxt: Label 'Approval of a cash document is requested.';
        CashDocApprReqCancelledEventDescTxt: Label 'An approval request for a cash document is canceled.';
        CashDocReleasedEventDescTxt: Label 'A cash document is released.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure AddWorkflowEventsToLibrary()
    begin
        WorkflowEventHandling.AddEventToLibrary(
          RunWorkflowOnSendCashDocForApprovalCode(), Database::"Cash Document Header CZP",
          CashDocSendForApprovalEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(
          RunWorkflowOnCancelCashDocApprovalRequestCode(), Database::"Cash Document Header CZP",
          CashDocApprReqCancelledEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(
          RunWorkflowOnAfterReleaseCashDocCode(), Database::"Cash Document Header CZP",
          CashDocReleasedEventDescTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', false, false)]
    local procedure AddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    begin
        case EventFunctionName of
            RunWorkflowOnCancelCashDocApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  RunWorkflowOnCancelCashDocApprovalRequestCode(),
                  RunWorkflowOnSendCashDocForApprovalCode());
            WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode(),
                  RunWorkflowOnSendCashDocForApprovalCode());
            WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode(),
                  RunWorkflowOnSendCashDocForApprovalCode());
            WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode(),
                  RunWorkflowOnSendCashDocForApprovalCode());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowTableRelationsToLibrary', '', false, false)]
    local procedure AddWorkflowTableRelationsToLibrary()
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        WorkflowSetup.InsertTableRelation(Database::"Cash Document Header CZP", 0,
          Database::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document Approv. Mgt. CZP", 'OnSendCashDocumentForApproval', '', false, false)]
    local procedure RunWorkflowOnSendCashDocForApproval(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendCashDocForApprovalCode(), CashDocumentHeaderCZP);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document Approv. Mgt. CZP", 'OnCancelCashDocumentApprovalRequest', '', false, false)]
    local procedure RunWorkflowOnCancelCashDocApprovalRequest(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelCashDocApprovalRequestCode(), CashDocumentHeaderCZP);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document-Release CZP", 'OnAfterReleaseCashDocument', '', false, false)]
    local procedure RunWorkflowOnAfterReleaseCashDoc(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnAfterReleaseCashDocCode(), CashDocumentHeaderCZP);
    end;

    procedure RunWorkflowOnSendCashDocForApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnSendCashDocForApprovalCZP'));
    end;

    procedure RunWorkflowOnCancelCashDocApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelCashDocApprovalRequestCZP'));
    end;

    procedure RunWorkflowOnAfterReleaseCashDocCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnAfterReleaseCashDocCZP'));
    end;
}
