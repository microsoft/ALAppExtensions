// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using System.Automation;
using System.Security.User;

codeunit 11713 "Cash Document Approv. Mgt. CZP"
{
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        ApprovalAmount: Decimal;
        ApprovalAmountLCY: Decimal;
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';

    procedure CalcCashDocAmount(CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var ApprovalAmount: Decimal; var ApprovalAmountLCY: Decimal)
    begin
        CashDocumentHeaderCZP.CalcFields(Amount, "Amount (LCY)");
        ApprovalAmount := CashDocumentHeaderCZP.Amount;
        ApprovalAmountLCY := CashDocumentHeaderCZP."Amount (LCY)";
    end;

    procedure PrePostApprovalCheckCashDoc(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"): Boolean
    var
        PrePostCheckCashDocErr: Label 'Cash Document %1 of type %2 must be approved and released before you can perform this action.', Comment = '%1 = Document No., %2 = Document Type';
    begin
        if (CashDocumentHeaderCZP.Status = CashDocumentHeaderCZP.Status::Open) and IsCashDocApprovalsWorkflowEnabled(CashDocumentHeaderCZP) then
            Error(PrePostCheckCashDocErr, CashDocumentHeaderCZP."No.", CashDocumentHeaderCZP."Document Type");

        exit(true);
    end;

    procedure IsCashDocApprovalsWorkflowEnabled(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"): Boolean
    var
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowHandlerCZP: Codeunit "Workflow Handler CZP";
    begin
        exit(WorkflowManagement.CanExecuteWorkflow(CashDocumentHeaderCZP,
          WorkflowHandlerCZP.RunWorkflowOnSendCashDocForApprovalCode()));
    end;

    local procedure IsSufficientCashDeskApprover(UserSetup: Record "User Setup"; ApprovalAmountLCY: Decimal): Boolean
    begin
        if UserSetup."User ID" = UserSetup."Approver ID" then
            exit(true);

        if UserSetup."Unlimited Cash Desk Appr. CZP" or
           ((ApprovalAmountLCY <= UserSetup."Cash Desk Amt. Appr. Limit CZP") and (UserSetup."Cash Desk Amt. Appr. Limit CZP" <> 0))
        then
            exit(true);

        exit(false);
    end;

    procedure CheckCashDocApprovalsWorkflowEnabled(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"): Boolean
    begin
        if not IsCashDocApprovalsWorkflowEnabled(CashDocumentHeaderCZP) then
            Error(NoWorkflowEnabledErr);

        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Management CZL", 'OnSetStatusToApproved', '', false, false)]
    local procedure SetCashDocumentStatusToApproved(InputRecordRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        ApprovedCashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        if IsHandled then
            exit;

        if InputRecordRef.Number = Database::"Cash Document Header CZP" then begin
            InputRecordRef.SetTable(ApprovedCashDocumentHeaderCZP);
            ApprovedCashDocumentHeaderCZP.Validate(Status, ApprovedCashDocumentHeaderCZP.Status::Approved);
            ApprovedCashDocumentHeaderCZP.Modify();
            Variant := ApprovedCashDocumentHeaderCZP;
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure ApprovalsMgmtOnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry")
    begin
        if RecRef.Number = Database::"Cash Document Header CZP" then begin
            RecRef.SetTable(CashDocumentHeaderCZP);
            CalcCashDocAmount(CashDocumentHeaderCZP, ApprovalAmount, ApprovalAmountLCY);
            ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::" ";
            ApprovalEntryArgument."Document No." := CashDocumentHeaderCZP."No.";
            ApprovalEntryArgument."Salespers./Purch. Code" := CashDocumentHeaderCZP."Salespers./Purch. Code";
            ApprovalEntryArgument.Amount := ApprovalAmount;
            ApprovalEntryArgument."Amount (LCY)" := ApprovalAmountLCY;
            ApprovalEntryArgument."Currency Code" := CashDocumentHeaderCZP."Currency Code";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnAfterIsSufficientApprover', '', false, false)]
    local procedure ApprovalsMgmtOnAfterIsSufficientApprover(UserSetup: Record "User Setup"; ApprovalEntryArgument: Record "Approval Entry"; var IsSufficient: Boolean)
    begin
        if ApprovalEntryArgument."Table ID" = Database::"Cash Document Header CZP" then
            IsSufficient := IsSufficientCashDeskApprover(UserSetup, ApprovalEntryArgument."Amount (LCY)");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure ApprovalsMgmtOnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        ApprovedCashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        if IsHandled then
            exit;

        if RecRef.Number = Database::"Cash Document Header CZP" then begin
            RecRef.SetTable(ApprovedCashDocumentHeaderCZP);
            ApprovedCashDocumentHeaderCZP.Validate(Status, ApprovedCashDocumentHeaderCZP.Status::"Pending Approval");
            ApprovedCashDocumentHeaderCZP.Modify(true);
            Variant := ApprovedCashDocumentHeaderCZP;
            IsHandled := true;
        end;
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendCashDocumentForApproval(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelCashDocumentApprovalRequest(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
    end;
}
