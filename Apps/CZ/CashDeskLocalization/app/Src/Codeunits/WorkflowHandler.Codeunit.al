// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using System.Apps;
using System.Automation;

codeunit 11739 "Workflow Handler CZP"
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
        CashDocSendForApprovalEventDescTxt: Label 'Approval of a cash document is requested.';
        CashDocApprReqCancelledEventDescTxt: Label 'An approval request for a cash document is canceled.';
        CashDocReleasedEventDescTxt: Label 'A cash document is released.';
        CashDocApprWorkflowCodeTxt: Label 'CDAPWCZP', Locked = true;
        CashDocApprWorkflowDescTxt: Label 'Cash Document Approval Workflow';
        CashDocHeaderTypeCondnTxt: Label '<?xml version="1.0" encoding="utf-8" standalone="yes"?><ReportParameters><DataItems><DataItem name="Cash Document Header CZP">%1</DataItem><DataItem name="Cash Document Line CZP">%2</DataItem></DataItems></ReportParameters>', Locked = true;
        CashDocumentCodeTxt: Label 'CASHDOC', Locked = true;
        CashDocumentDescTxt: Label 'Cash Document';
        FinCategoryTxt: Label 'FIN', Locked = true;

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
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        WorkflowSetup.InsertTableRelation(Database::"Cash Document Header CZP", 0,
          Database::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));
        WorkflowSetup.InsertTableRelation(Database::"Cash Document Header CZP", CashDocumentHeaderCZP.FieldNo("Cash Desk No."),
          Database::"Cash Document Line CZP", CashDocumentLineCZP.FieldNo("Cash Desk No."));
        WorkflowSetup.InsertTableRelation(Database::"Cash Document Header CZP", CashDocumentHeaderCZP.FieldNo("No."),
          Database::"Cash Document Line CZP", CashDocumentLineCZP.FieldNo("Cash Document No."));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure AddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    begin
        case ResponseFunctionName of
            WorkflowResponseHandlingCZL.CheckReleaseDocumentCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendCashDocForApprovalCode());
            WorkflowResponseHandling.SetStatusToPendingApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendCashDocForApprovalCode());
            WorkflowResponseHandling.CreateApprovalRequestsCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendCashDocForApprovalCode());
            WorkflowResponseHandling.SendApprovalRequestForApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendCashDocForApprovalCode());
            WorkflowResponseHandling.OpenDocumentCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnCancelCashDocApprovalRequestCode());
            WorkflowResponseHandling.CancelAllApprovalRequestsCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnCancelCashDocApprovalRequestCode());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure ReleaseCashDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentReleaseCZP: Codeunit "Cash Document-Release CZP";
    begin
        if Handled then
            exit;

        if RecRef.Number = Database::"Cash Document Header CZP" then begin
            RecRef.SetTable(CashDocumentHeaderCZP);
            CashDocumentReleaseCZP.PerformManualRelease(CashDocumentHeaderCZP);
            Handled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure OpenCashDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentReleaseCZP: Codeunit "Cash Document-Release CZP";
    begin
        if Handled then
            exit;

        if RecRef.Number = Database::"Cash Document Header CZP" then begin
            RecRef.SetTable(CashDocumentHeaderCZP);
            CashDocumentReleaseCZP.Reopen(CashDocumentHeaderCZP);
            Handled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Approval Entry", 'OnAfterGetRecordDetails', '', false, false)]
    local procedure GetDetailsOnAfterGetRecordDetails(RecRef: RecordRef; ChangeRecordDetails: Text; var Details: Text)
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        ThreePlaceholdersTok: Label '%1 ; %2: %3', Locked = true;
    begin
        case RecRef.Number() of
            Database::"Cash Document Header CZP":
                begin
                    RecRef.SetTable(CashDocumentHeaderCZP);
                    CashDocumentHeaderCZP.CalcFields(Amount);
                    Details := StrSubstNo(ThreePlaceholdersTok, CashDocumentHeaderCZP."Document Type",
                        CashDocumentHeaderCZP.FieldCaption(Amount), CashDocumentHeaderCZP.Amount);
                end;
        end;
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling CZL", 'OnCheckReleaseDocument', '', false, false)]
    local procedure CheckCashDocumentOnCheckReleaseDocument(InputRecordRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentReleaseCZP: Codeunit "Cash Document-Release CZP";
    begin
        if IsHandled then
            exit;

        if InputRecordRef.Number = Database::"Cash Document Header CZP" then begin
            CashDocumentHeaderCZP := Variant;
            CashDocumentReleaseCZP.CheckCashDocument(CashDocumentHeaderCZP);
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Document Header CZP", 'OnCheckCashDocReleaseRestrictions', '', false, false)]
    local procedure CheckCashDocReleaseRestrictions(var Sender: Record "Cash Document Header CZP")
    begin
        CheckRecordHasUsageRestrictions(Sender);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Document Header CZP", 'OnCheckCashDocPostRestrictions', '', false, false)]
    local procedure CheckCashDocPostRestrictions(var Sender: Record "Cash Document Header CZP")
    begin
        CheckRecordHasUsageRestrictions(Sender);
    end;

    local procedure CheckRecordHasUsageRestrictions(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.CheckRecordHasUsageRestrictions(CashDocumentHeaderCZP);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Document Header CZP", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure RemoveCashDocumentHeaderRestrictionsOnBeforeDeleteEvent(var Rec: Record "Cash Document Header CZP"; RunTrigger: Boolean)
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.AllowRecordUsage(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Document Header CZP", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateCashDocumentHeaderRestrictionsOnAfterRenameEvent(var Rec: Record "Cash Document Header CZP"; var xRec: Record "Cash Document Header CZP"; RunTrigger: Boolean)
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

        InsertCashDocumentApprovalWorkflowTemplate();
    end;

    local procedure IsTestingEnvironment(): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        exit(NAVAppInstalledApp.Get('c4795dd0-aee3-47cc-b020-2ee93a47d4c4')); // application "Tests-Workflow"
    end;

    local procedure InsertCashDocumentApprovalWorkflowTemplate()
    var
        Workflow: Record Workflow;
    begin
        if Workflow.Get(WorkflowSetup.GetWorkflowTemplateCode(CashDocApprWorkflowCodeTxt)) then
            exit;
        WorkflowSetup.InsertWorkflowTemplate(Workflow, CashDocApprWorkflowCodeTxt, CashDocApprWorkflowDescTxt, FinCategoryTxt);
        InsertCashDocumentApprovalWorkflowDetails(Workflow);
        WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
    end;

    local procedure InsertCashDocumentApprovalWorkflowDetails(var Workflow: Record Workflow)
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        WorkflowSetup.InitWorkflowStepArgument(
            WorkflowStepArgument, WorkflowStepArgument."Approver Type"::"Salesperson/Purchaser",
            WorkflowStepArgument."Approver Limit Type"::"Direct Approver", 0, '', BlankDateFormula, true);

        WorkflowSetup.InsertDocApprovalWorkflowSteps(Workflow,
            BuildCashDocumentHeaderTypeConditions(CashDocumentHeaderCZP.Status::Open),
            RunWorkflowOnSendCashDocForApprovalCode(),
            BuildCashDocumentHeaderTypeConditions(CashDocumentHeaderCZP.Status::"Pending Approval"),
            RunWorkflowOnCancelCashDocApprovalRequestCode(),
            WorkflowStepArgument, true);

        ModifyCashDocumentApprovalWorkflowSteps(Workflow);
    end;

    procedure BuildCashDocumentHeaderTypeConditions(Status: Enum "Cash Document Status CZP"): Text
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        CashDocumentHeaderCZP.SetRange(Status, Status);
        exit(StrSubstNo(CashDocHeaderTypeCondnTxt,
                WorkflowSetup.Encode(CashDocumentHeaderCZP.GetView(false)),
                WorkflowSetup.Encode(CashDocumentLineCZP.GetView(false))));
    end;

    local procedure ModifyCashDocumentApprovalWorkflowSteps(Workflow: Record Workflow)
    var
        WorkflowStepRecord: Record "Workflow Step";
        CheckReleaseDocumentResponseID: Integer;
        RestrictRecordUsageResponseID: Integer;
    begin
        WorkflowStepRecord.SetRange("Workflow Code", Workflow.Code);
        WorkflowStepRecord.SetRange("Function Name", WorkflowResponseHandling.RestrictRecordUsageCode());
        WorkflowStepRecord.FindFirst();
        RestrictRecordUsageResponseID := WorkflowStepRecord.ID;

        WorkflowStepRecord.SetRange("Function Name", WorkflowResponseHandling.SetStatusToPendingApprovalCode());
        WorkflowStepRecord.FindFirst();
        WorkflowStepRecord.Validate("Previous Workflow Step ID", 0);
        WorkflowStepRecord.Modify();

        CheckReleaseDocumentResponseID := WorkflowSetup.InsertResponseStep(Workflow,
            WorkflowResponseHandlingCZL.CheckReleaseDocumentCode(), RestrictRecordUsageResponseID);

        WorkflowStepRecord.Validate("Previous Workflow Step ID", CheckReleaseDocumentResponseID);
        WorkflowStepRecord.Modify();
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
        WorkflowRequestPageHandling.AssignEntityToWorkflowEvent(Database::"Cash Document Header CZP", CashDocumentCodeTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Request Page Handling", 'OnAfterInsertRequestPageEntities', '', false, false)]
    local procedure InsertRequestPageEntities()
    begin
        WorkflowRequestPageHandling.InsertReqPageEntity(CashDocumentCodeTxt, CashDocumentDescTxt, Database::"Cash Document Header CZP", Database::"Cash Document Line CZP");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Request Page Handling", 'OnAfterInsertRequestPageFields', '', false, false)]
    local procedure InsertRequestPageFields()
    var
        DummyCashDocumentHeaderCZP: Record "Cash Document Header CZP";
        DummyCashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Cash Document Header CZP", DummyCashDocumentHeaderCZP.FieldNo("Cash Desk No."));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Cash Document Header CZP", DummyCashDocumentHeaderCZP.FieldNo("Document Type"));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Cash Document Header CZP", DummyCashDocumentHeaderCZP.FieldNo(Amount));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Cash Document Header CZP", DummyCashDocumentHeaderCZP.FieldNo("Currency Code"));

        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Cash Document Line CZP", DummyCashDocumentLineCZP.FieldNo("Account Type"));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Cash Document Line CZP", DummyCashDocumentLineCZP.FieldNo("Account No."));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Cash Document Line CZP", DummyCashDocumentLineCZP.FieldNo(Amount));
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
