// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using System.Automation;
using System.Security.User;

codeunit 31349 "Banking Approvals Mgt. CZB"
{
    var
        ApprovalAmount: Decimal;
        ApprovalAmountLCY: Decimal;
        ApprovalProcessReopenErr: Label 'The approval process must be cancelled or completed to reopen this document.';
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';

    procedure CalcPaymentOrderAmount(PaymentOrderHeaderCZB: Record "Payment Order Header CZB"; var ApprovalAmount: Decimal; var ApprovalAmountLCY: Decimal)
    begin
        PaymentOrderHeaderCZB.CalcFields(Amount, "Amount (LCY)");
        ApprovalAmount := PaymentOrderHeaderCZB.Amount;
        ApprovalAmountLCY := PaymentOrderHeaderCZB."Amount (LCY)";
    end;

    procedure PreIssueApprovalCheckPaymentOrder(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB"): Boolean
    var
        PreIssueCheckPaymentOrderErr: Label 'Payment Order %1 must be approved before you can perform this action.', Comment = '%1 = No.';
    begin
        if (PaymentOrderHeaderCZB.Status = PaymentOrderHeaderCZB.Status::Open) and IsPaymentOrderApprovalsWorkflowEnabled(PaymentOrderHeaderCZB) then
            Error(PreIssueCheckPaymentOrderErr, PaymentOrderHeaderCZB."No.");

        exit(true);
    end;

    procedure IsPaymentOrderApprovalsWorkflowEnabled(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB"): Boolean
    var
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowHandlerCZB: Codeunit "Workflow Handler CZB";
    begin
        exit(WorkflowManagement.CanExecuteWorkflow(PaymentOrderHeaderCZB,
          WorkflowHandlerCZB.RunWorkflowOnSendPaymentOrderForApprovalCode()));
    end;

    local procedure IsSufficientBankAccountApprover(UserSetup: Record "User Setup"; ApprovalAmountLCY: Decimal): Boolean
    begin
        if UserSetup."User ID" = UserSetup."Approver ID" then
            exit(true);

        if UserSetup."Unlimited Bank Approval CZB" or
           ((ApprovalAmountLCY <= UserSetup."Bank Amount Approval Limit CZB") and (UserSetup."Bank Amount Approval Limit CZB" <> 0))
        then
            exit(true);

        exit(false);
    end;

    procedure CheckPaymentOrderApprovalsWorkflowEnabled(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB"): Boolean
    begin
        if not IsPaymentOrderApprovalsWorkflowEnabled(PaymentOrderHeaderCZB) then
            Error(NoWorkflowEnabledErr);

        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Management CZL", 'OnSetStatusToApproved', '', false, false)]
    local procedure SetPaymentOrderStatusToApproved(InputRecordRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
    begin
        if IsHandled then
            exit;

        if InputRecordRef.Number = Database::"Payment Order Header CZB" then begin
            InputRecordRef.SetTable(PaymentOrderHeaderCZB);
            PaymentOrderHeaderCZB.Validate(Status, PaymentOrderHeaderCZB.Status::Approved);
            PaymentOrderHeaderCZB.Modify();
            Variant := PaymentOrderHeaderCZB;
            IsHandled := true;
        end;
    end;

    procedure ReopenPaymentOrder(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
        if PaymentOrderHeaderCZB.Status = PaymentOrderHeaderCZB.Status::Open then
            exit;

        PaymentOrderHeaderCZB.Validate(Status, PaymentOrderHeaderCZB.Status::Open);
        PaymentOrderHeaderCZB.Modify(true);
    end;

    procedure PerformManualReopenPaymentOrder(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
        if PaymentOrderHeaderCZB.Status = PaymentOrderHeaderCZB.Status::"Pending Approval" then
            Error(ApprovalProcessReopenErr);

        ReopenPaymentOrder(PaymentOrderHeaderCZB);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure ApprovalsMgmtOnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry")
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
    begin
        if RecRef.Number = Database::"Payment Order Header CZB" then begin
            RecRef.SetTable(PaymentOrderHeaderCZB);
            CalcPaymentOrderAmount(PaymentOrderHeaderCZB, ApprovalAmount, ApprovalAmountLCY);
            ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::" ";
            ApprovalEntryArgument."Document No." := PaymentOrderHeaderCZB."No.";
            ApprovalEntryArgument."Salespers./Purch. Code" := '';
            ApprovalEntryArgument.Amount := ApprovalAmount;
            ApprovalEntryArgument."Amount (LCY)" := ApprovalAmountLCY;
            ApprovalEntryArgument."Currency Code" := PaymentOrderHeaderCZB."Currency Code";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnAfterIsSufficientApprover', '', false, false)]
    local procedure ApprovalsMgmtOnAfterIsSufficientApprover(UserSetup: Record "User Setup"; ApprovalEntryArgument: Record "Approval Entry"; var IsSufficient: Boolean)
    begin
        if ApprovalEntryArgument."Table ID" = Database::"Payment Order Header CZB" then
            IsSufficient := IsSufficientBankAccountApprover(UserSetup, ApprovalEntryArgument."Amount (LCY)");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure ApprovalsMgmtOnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        ApprovedPaymentOrderHeaderCZB: Record "Payment Order Header CZB";
    begin
        if IsHandled then
            exit;

        if RecRef.Number = Database::"Payment Order Header CZB" then begin
            RecRef.SetTable(ApprovedPaymentOrderHeaderCZB);
            ApprovedPaymentOrderHeaderCZB.Validate(Status, ApprovedPaymentOrderHeaderCZB.Status::"Pending Approval");
            ApprovedPaymentOrderHeaderCZB.Modify(true);
            Variant := ApprovedPaymentOrderHeaderCZB;
            IsHandled := true;
        end;
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendPaymentOrderForApproval(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelPaymentOrderApprovalRequest(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
    end;
}
