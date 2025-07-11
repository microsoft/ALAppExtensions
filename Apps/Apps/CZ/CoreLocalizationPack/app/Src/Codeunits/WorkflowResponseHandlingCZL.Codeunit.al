// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Automation;

codeunit 31396 "Workflow Response Handling CZL"
{
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        SetStatusToApprovedTxt: Label 'Set document status to Approved.';
        CheckReleaseDocumentTxt: Label 'Check release the document.';
        UnsupportedRecordTypeErr: Label 'Record type %1 is not supported by this workflow response.', Comment = '%1 = record type; Record type Customer is not supported by this workflow response.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsesToLibrary', '', false, false)]
    local procedure AddWorkflowResponsesToLibrary()
    begin
        WorkflowResponseHandling.AddResponseToLibrary(SetStatusToApprovedCode(), 0, SetStatusToApprovedTxt, 'GROUP 0');
        WorkflowResponseHandling.AddResponseToLibrary(CheckReleaseDocumentCode(), 0, CheckReleaseDocumentTxt, 'GROUP 0');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure AddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    begin
        if ResponseFunctionName = SetStatusToApprovedCode() then
            WorkflowResponseHandling.AddResponsePredecessor(SetStatusToApprovedCode(), WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnExecuteWorkflowResponse', '', false, false)]
    local procedure ExecuteWorkflowResponse(var ResponseExecuted: Boolean; Variant: Variant; xVariant: Variant; ResponseWorkflowStepInstance: Record "Workflow Step Instance")
    begin
        case ResponseWorkflowStepInstance."Function Name" of
            SetStatusToApprovedCode():
                begin
                    SetStatusToApproved(Variant);
                    ResponseExecuted := true;
                end;
            CheckReleaseDocumentCode():
                begin
                    CheckReleaseDocument(Variant);
                    ResponseExecuted := true;
                end;
        end;
    end;

    procedure SetStatusToApprovedCode(): Code[128]
    begin
        exit(UpperCase('SetStatusToApprovedCZL'));
    end;

    procedure CheckReleaseDocumentCode(): Code[128]
    begin
        exit(UpperCase('CheckReleaseDocumentCZL'));
    end;

    local procedure SetStatusToApproved(var Variant: Variant)
    var
        ApprovalsManagement: Codeunit "Approvals Management CZL";
    begin
        ApprovalsManagement.SetStatusToApproved(Variant);
    end;

    local procedure CheckReleaseDocument(var Variant: Variant)
    var
        InputRecordRef: RecordRef;
        IsHandled: Boolean;
    begin
        InputRecordRef.GetTable(Variant);

        IsHandled := false;
        OnCheckReleaseDocument(InputRecordRef, Variant, IsHandled);
        if not IsHandled then
            Error(UnsupportedRecordTypeErr, InputRecordRef.Caption);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckReleaseDocument(InputRecordRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    begin
    end;
}

