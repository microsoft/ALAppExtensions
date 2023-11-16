// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using System.Apps;
using System.Automation;

codeunit 31350 "Workflow Handler CZB"
{
    Permissions = tabledata "NAV App Installed App" = r;

    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        WorkflowRequestPageHandling: Codeunit "Workflow Request Page Handling";
        WorkflowSetup: Codeunit "Workflow Setup";
        BlankDateFormula: DateFormula;
        FinCategoryTxt: Label 'FIN', Locked = true;
        PaymOrderSendForApprovalEventDescTxt: Label 'Approval of a payment order is requested.';
        PaymOrderApprReqCancelledEventDescTxt: Label 'An approval request for a payment order is canceled.';
        PaymOrderReleasedEventDescTxt: Label 'A payment order is released.';
        PaymentOrderApprWorkflowCodeTxt: Label 'PMTORDAPWCZB', Locked = true;
        PaymentOrderApprWorkflowDescTxt: Label 'Payment Order Approval Workflow';
        PaymentOrderCodeTxt: Label 'PMTORD', Locked = true;
        PaymentOrderDescTxt: Label 'Payment Order';
        PaymentOrderHeaderTypeCondnTxt: Label '<?xml version="1.0" encoding="utf-8" standalone="yes"?><ReportParameters><DataItems><DataItem name="Payment Order Header CZB">%1</DataItem><DataItem name="Payment Order Line CZB">%2</DataItem></DataItems></ReportParameters>', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure AddWorkflowEventsToLibrary()
    begin
        WorkflowEventHandling.AddEventToLibrary(
          RunWorkflowOnSendPaymentOrderForApprovalCode(), Database::"Payment Order Header CZB",
          PaymOrderSendForApprovalEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(
          RunWorkflowOnCancelPaymentOrderApprovalRequestCode(), Database::"Payment Order Header CZB",
          PaymOrderApprReqCancelledEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(
          RunWorkflowOnAfterIssuePaymentOrderCode(), Database::"Payment Order Header CZB",
          PaymOrderReleasedEventDescTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', false, false)]
    local procedure AddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    begin
        case EventFunctionName of
            RunWorkflowOnCancelPaymentOrderApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  RunWorkflowOnCancelPaymentOrderApprovalRequestCode(),
                  RunWorkflowOnSendPaymentOrderForApprovalCode());
            WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode(),
                  RunWorkflowOnSendPaymentOrderForApprovalCode());
            WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode(),
                  RunWorkflowOnSendPaymentOrderForApprovalCode());
            WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode(),
                  RunWorkflowOnSendPaymentOrderForApprovalCode());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowTableRelationsToLibrary', '', false, false)]
    local procedure AddWorkflowTableRelationsToLibrary()
    var
        ApprovalEntry: Record "Approval Entry";
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
    begin
        WorkflowSetup.InsertTableRelation(Database::"Payment Order Header CZB", 0,
          Database::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));
        WorkflowSetup.InsertTableRelation(Database::"Payment Order Header CZB", PaymentOrderHeaderCZB.FieldNo("No."),
          Database::"Payment Order Line CZB", PaymentOrderLineCZB.FieldNo("Payment Order No."));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure AddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    begin
        case ResponseFunctionName of
            WorkflowResponseHandling.SetStatusToPendingApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendPaymentOrderForApprovalCode());
            WorkflowResponseHandling.CreateApprovalRequestsCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendPaymentOrderForApprovalCode());
            WorkflowResponseHandling.SendApprovalRequestForApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendPaymentOrderForApprovalCode());
            WorkflowResponseHandling.OpenDocumentCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnCancelPaymentOrderApprovalRequestCode());
            WorkflowResponseHandling.CancelAllApprovalRequestsCode():
                WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnCancelPaymentOrderApprovalRequestCode());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure ReleasePaymentOrder(RecRef: RecordRef; var Handled: Boolean)
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
    begin
        if Handled then
            exit;

        if RecRef.Number = Database::"Payment Order Header CZB" then begin
            RecRef.SetTable(PaymentOrderHeaderCZB);
            Codeunit.Run(Codeunit::"Issue Payment Order CZB", PaymentOrderHeaderCZB);
            Handled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure OpenPaymentOrder(RecRef: RecordRef; var Handled: Boolean)
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        BankingApprovalsMgtCZB: Codeunit "Banking Approvals Mgt. CZB";
    begin
        if Handled then
            exit;

        if RecRef.Number = Database::"Payment Order Header CZB" then begin
            RecRef.SetTable(PaymentOrderHeaderCZB);
            BankingApprovalsMgtCZB.ReopenPaymentOrder(PaymentOrderHeaderCZB);
            Handled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Approval Entry", 'OnAfterGetRecordDetails', '', false, false)]
    local procedure GetDetailsOnAfterGetRecordDetails(RecRef: RecordRef; ChangeRecordDetails: Text; var Details: Text)
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        ThreePlaceholdersTok: Label '%1 ; %2: %3', Locked = true;
    begin
        case RecRef.Number() of
            Database::"Payment Order Header CZB":
                begin
                    RecRef.SetTable(PaymentOrderHeaderCZB);
                    PaymentOrderHeaderCZB.CalcFields("Bank Account Name", Amount);
                    Details := StrSubstNo(ThreePlaceholdersTok, PaymentOrderHeaderCZB."Bank Account Name",
                        PaymentOrderHeaderCZB.FieldCaption(Amount), PaymentOrderHeaderCZB.Amount);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Banking Approvals Mgt. CZB", 'OnSendPaymentOrderForApproval', '', false, false)]
    local procedure RunWorkflowOnSendPaymOrderForApproval(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendPaymentOrderForApprovalCode(), PaymentOrderHeaderCZB);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Banking Approvals Mgt. CZB", 'OnCancelPaymentOrderApprovalRequest', '', false, false)]
    local procedure RunWorkflowOnCancelPaymOrderApprovalRequest(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelPaymentOrderApprovalRequestCode(), PaymentOrderHeaderCZB);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Issue Payment Order CZB", 'OnAfterIssuePaymentOrder', '', false, false)]
    local procedure RunWorkflowOnAfterReleasePaymentOrder(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnAfterIssuePaymentOrderCode(), PaymentOrderHeaderCZB);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Order Header CZB", 'OnCheckPaymentOrderIssueRestrictions', '', false, false)]
    local procedure CheckPaymentOrderIssueRestrictions(var Sender: Record "Payment Order Header CZB")
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.CheckRecordHasUsageRestrictions(Sender);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Order Header CZB", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure RemovePaymentOrderHeaderRestrictionsOnBeforeDeleteEvent(var Rec: Record "Payment Order Header CZB"; RunTrigger: Boolean)
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.AllowRecordUsage(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Order Header CZB", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdatePaymentOrderHeaderRestrictionsOnAfterRenameEvent(var Rec: Record "Payment Order Header CZB"; var xRec: Record "Payment Order Header CZB"; RunTrigger: Boolean)
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

        InsertPaymentOrderApprovalWorkflowTemplate();
    end;

    local procedure IsTestingEnvironment(): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        exit(NAVAppInstalledApp.Get('c4795dd0-aee3-47cc-b020-2ee93a47d4c4')); // application "Tests-Workflow"
    end;

    local procedure InsertPaymentOrderApprovalWorkflowTemplate()
    var
        Workflow: Record Workflow;
    begin
        if Workflow.Get(WorkflowSetup.GetWorkflowTemplateCode(PaymentOrderApprWorkflowCodeTxt)) then
            exit;
        WorkflowSetup.InsertWorkflowTemplate(Workflow, PaymentOrderApprWorkflowCodeTxt, PaymentOrderApprWorkflowDescTxt, FinCategoryTxt);
        InsertPaymentOrderApprovalWorkflowDetails(Workflow);
        WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
    end;

    local procedure InsertPaymentOrderApprovalWorkflowDetails(var Workflow: Record Workflow)
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        WorkflowSetup.InitWorkflowStepArgument(
            WorkflowStepArgument, WorkflowStepArgument."Approver Type"::"Salesperson/Purchaser",
            WorkflowStepArgument."Approver Limit Type"::"Direct Approver", 0, '', BlankDateFormula, true);

        WorkflowSetup.InsertDocApprovalWorkflowSteps(
            Workflow,
            BuildPaymentOrderHeaderTypeConditions(PaymentOrderHeaderCZB.Status::Open),
            RunWorkflowOnSendPaymentOrderForApprovalCode(),
            BuildPaymentOrderHeaderTypeConditions(PaymentOrderHeaderCZB.Status::"Pending Approval"),
            RunWorkflowOnCancelPaymentOrderApprovalRequestCode(),
            WorkflowStepArgument, true);
    end;

    procedure BuildPaymentOrderHeaderTypeConditions(Status: Enum "Payment Order Head. Status CZB"): Text
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
    begin
        PaymentOrderHeaderCZB.SetRange(Status, Status);
        exit(StrSubstNo(PaymentOrderHeaderTypeCondnTxt,
                WorkflowSetup.Encode(PaymentOrderHeaderCZB.GetView(false)),
                WorkflowSetup.Encode(PaymentOrderLineCZB.GetView(false))));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Request Page Handling", 'OnAfterAssignEntitiesToWorkflowEvents', '', false, false)]
    local procedure AssignEntitiesToWorkflowEvents()
    begin
        WorkflowRequestPageHandling.AssignEntityToWorkflowEvent(Database::"Payment Order Header CZB", PaymentOrderCodeTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Request Page Handling", 'OnAfterInsertRequestPageEntities', '', false, false)]
    local procedure InsertRequestPageEntities()
    begin
        WorkflowRequestPageHandling.InsertReqPageEntity(PaymentOrderCodeTxt, PaymentOrderDescTxt, Database::"Payment Order Header CZB", Database::"Payment Order Line CZB");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Request Page Handling", 'OnAfterInsertRequestPageFields', '', false, false)]
    local procedure InsertRequestPageFields()
    var
        DummyPaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        DummyPaymentOrderLineCZB: Record "Payment Order Line CZB";
    begin
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Payment Order Header CZB", DummyPaymentOrderHeaderCZB.FieldNo("Bank Account No."));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Payment Order Header CZB", DummyPaymentOrderHeaderCZB.FieldNo("Account No."));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Payment Order Header CZB", DummyPaymentOrderHeaderCZB.FieldNo(Amount));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Payment Order Header CZB", DummyPaymentOrderHeaderCZB.FieldNo("Currency Code"));

        WorkflowRequestPageHandling.InsertDynReqPageField(DATABASE::"Payment Order Line CZB", DummyPaymentOrderLineCZB.FieldNo(Type));
        WorkflowRequestPageHandling.InsertDynReqPageField(DATABASE::"Payment Order Line CZB", DummyPaymentOrderLineCZB.FieldNo("No."));
        WorkflowRequestPageHandling.InsertDynReqPageField(DATABASE::"Payment Order Line CZB", DummyPaymentOrderLineCZB.FieldNo(Amount));
    end;

    procedure RunWorkflowOnSendPaymentOrderForApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnSendPaymentOrderForApprovalCZB'));
    end;

    procedure RunWorkflowOnCancelPaymentOrderApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelPaymentOrderApprovalRequestCZB'));
    end;

    procedure RunWorkflowOnAfterIssuePaymentOrderCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnAfterIssuePaymentOrderCZB'));
    end;
}
