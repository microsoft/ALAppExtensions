// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;
using System.Automation;
using System.Security.User;

codeunit 31383 "Adv. Payments Approv. Mgt. CZZ"
{
    var
        ApprovalAmount: Decimal;
        ApprovalAmountLCY: Decimal;
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';

    procedure CalcSalesAdvanceLetterAmount(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var ApprovalAmount: Decimal; var ApprovalAmountLCY: Decimal)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        ApprovalAmount := SalesAdvLetterHeaderCZZ."Amount Including VAT";
        ApprovalAmountLCY := CurrencyExchangeRate.ExchangeAmtFCYToLCY(
          SalesAdvLetterHeaderCZZ."Posting Date",
          SalesAdvLetterHeaderCZZ."Currency Code",
          SalesAdvLetterHeaderCZZ."Amount Including VAT",
          SalesAdvLetterHeaderCZZ."Currency Factor");
    end;

    procedure CalcPurchaseAdvanceLetterAmount(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var ApprovalAmount: Decimal; var ApprovalAmountLCY: Decimal)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        ApprovalAmount := PurchAdvLetterHeaderCZZ."Amount Including VAT";
        ApprovalAmountLCY := CurrencyExchangeRate.ExchangeAmtFCYToLCY(
          PurchAdvLetterHeaderCZZ."Posting Date",
          PurchAdvLetterHeaderCZZ."Currency Code",
          PurchAdvLetterHeaderCZZ."Amount Including VAT",
          PurchAdvLetterHeaderCZZ."Currency Factor");
    end;

    procedure PrePostApprovalCheckSalesAdvanceLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"): Boolean
    var
        PrePostCheckSalesAdvanceLetterErr: Label 'Sales advance letter %1 must be approved and released before you can perform this action.', Comment = '%1 = Document No.';
    begin
        if (SalesAdvLetterHeaderCZZ.Status = SalesAdvLetterHeaderCZZ.Status::New) and
           IsSalesAdvanceLetterApprovalsWorkflowEnabled(SalesAdvLetterHeaderCZZ)
        then
            Error(PrePostCheckSalesAdvanceLetterErr, SalesAdvLetterHeaderCZZ."No.");

        exit(true);
    end;

    procedure PrePostApprovalCheckPurchaseAdvanceLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"): Boolean
    var
        PrePostCheckPurchaseAdvanceLetterErr: Label 'Purchase advance letter %1 must be approved and released before you can perform this action.', Comment = '%1 = Document No.';
    begin
        if (PurchAdvLetterHeaderCZZ.Status = PurchAdvLetterHeaderCZZ.Status::New) and
           IsPurchaseAdvanceLetterApprovalsWorkflowEnabled(PurchAdvLetterHeaderCZZ)
        then
            Error(PrePostCheckPurchaseAdvanceLetterErr, PurchAdvLetterHeaderCZZ."No.");

        exit(true);
    end;

    procedure IsSalesAdvanceLetterApprovalsWorkflowEnabled(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"): Boolean
    var
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowHandlerCZZ: Codeunit "Workflow Handler CZZ";
    begin
        exit(WorkflowManagement.CanExecuteWorkflow(SalesAdvLetterHeaderCZZ,
          WorkflowHandlerCZZ.RunWorkflowOnSendSalesAdvanceLetterForApprovalCode()));
    end;

    procedure IsPurchaseAdvanceLetterApprovalsWorkflowEnabled(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"): Boolean
    var
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowHandlerCZZ: Codeunit "Workflow Handler CZZ";
    begin
        exit(WorkflowManagement.CanExecuteWorkflow(PurchAdvLetterHeaderCZZ,
          WorkflowHandlerCZZ.RunWorkflowOnSendPurchaseAdvanceLetterForApprovalCode()));
    end;

    local procedure IsSufficientSalesApprover(UserSetup: Record "User Setup"; ApprovalAmountLCY: Decimal): Boolean
    begin
        if UserSetup."User ID" = UserSetup."Approver ID" then
            exit(true);

        if UserSetup."Unlimited Sales Approval" or
           ((ApprovalAmountLCY <= UserSetup."Sales Amount Approval Limit") and (UserSetup."Sales Amount Approval Limit" <> 0))
        then
            exit(true);

        exit(false);
    end;

    local procedure IsSufficientPurchApprover(UserSetup: Record "User Setup"; ApprovalAmountLCY: Decimal): Boolean
    begin
        if UserSetup."User ID" = UserSetup."Approver ID" then
            exit(true);

        if UserSetup."Unlimited Purchase Approval" or
           ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") and (UserSetup."Purchase Amount Approval Limit" <> 0))
        then
            exit(true);

        exit(false);
    end;

    procedure CheckSalesAdvanceLetterApprovalsWorkflowEnabled(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"): Boolean
    begin
        if not IsSalesAdvanceLetterApprovalsWorkflowEnabled(SalesAdvLetterHeaderCZZ) then
            Error(NoWorkflowEnabledErr);

        exit(true);
    end;

    procedure CheckPurchaseAdvanceLetterApprovalsWorkflowEnabled(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"): Boolean
    begin
        if not IsPurchaseAdvanceLetterApprovalsWorkflowEnabled(PurchAdvLetterHeaderCZZ) then
            Error(NoWorkflowEnabledErr);

        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Management CZL", 'OnSetStatusToApproved', '', false, false)]
    local procedure SetAdvanceLetterDocumentStatusToApproved(InputRecordRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
    begin
        if IsHandled then
            exit;

        case InputRecordRef.Number of
            Database::"Sales Adv. Letter Header CZZ":
                begin
                    InputRecordRef.SetTable(SalesAdvLetterHeaderCZZ);
                    SalesAdvLetterHeaderCZZ.Validate(Status, SalesAdvLetterHeaderCZZ.Status::"To Pay");
                    SalesAdvLetterHeaderCZZ.Modify();
                    Variant := SalesAdvLetterHeaderCZZ;
                    IsHandled := true;
                end;
            Database::"Purch. Adv. Letter Header CZZ":
                begin
                    InputRecordRef.SetTable(PurchAdvLetterHeaderCZZ);
                    PurchAdvLetterHeaderCZZ.Validate(Status, PurchAdvLetterHeaderCZZ.Status::"To Pay");
                    PurchAdvLetterHeaderCZZ.Modify();
                    Variant := PurchAdvLetterHeaderCZZ;
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure ApprovalsMgmtOnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry")
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
    begin
        case RecRef.Number of
            Database::"Sales Adv. Letter Header CZZ":
                begin
                    RecRef.SetTable(SalesAdvLetterHeaderCZZ);
                    CalcSalesAdvanceLetterAmount(SalesAdvLetterHeaderCZZ, ApprovalAmount, ApprovalAmountLCY);
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::" ";
                    ApprovalEntryArgument."Document No." := SalesAdvLetterHeaderCZZ."No.";
                    ApprovalEntryArgument."Salespers./Purch. Code" := SalesAdvLetterHeaderCZZ."Salesperson Code";
                    ApprovalEntryArgument.Amount := ApprovalAmount;
                    ApprovalEntryArgument."Amount (LCY)" := ApprovalAmountLCY;
                    ApprovalEntryArgument."Currency Code" := SalesAdvLetterHeaderCZZ."Currency Code";
                end;
            Database::"Purch. Adv. Letter Header CZZ":
                begin
                    RecRef.SetTable(PurchAdvLetterHeaderCZZ);
                    CalcPurchaseAdvanceLetterAmount(PurchAdvLetterHeaderCZZ, ApprovalAmount, ApprovalAmountLCY);
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::" ";
                    ApprovalEntryArgument."Document No." := PurchAdvLetterHeaderCZZ."No.";
                    ApprovalEntryArgument."Salespers./Purch. Code" := PurchAdvLetterHeaderCZZ."Purchaser Code";
                    ApprovalEntryArgument.Amount := ApprovalAmount;
                    ApprovalEntryArgument."Amount (LCY)" := ApprovalAmountLCY;
                    ApprovalEntryArgument."Currency Code" := PurchAdvLetterHeaderCZZ."Currency Code";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnAfterIsSufficientApprover', '', false, false)]
    local procedure ApprovalsMgmtOnAfterIsSufficientApprover(UserSetup: Record "User Setup"; ApprovalEntryArgument: Record "Approval Entry"; var IsSufficient: Boolean)
    begin
        case ApprovalEntryArgument."Table ID" of
            Database::"Sales Adv. Letter Header CZZ":
                IsSufficient := IsSufficientSalesApprover(UserSetup, ApprovalEntryArgument."Amount (LCY)");
            Database::"Purch. Adv. Letter Header CZZ":
                IsSufficient := IsSufficientPurchApprover(UserSetup, ApprovalEntryArgument."Amount (LCY)");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure ApprovalsMgmtOnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
    begin
        if IsHandled then
            exit;

        case RecRef.Number of
            Database::"Sales Adv. Letter Header CZZ":
                begin
                    RecRef.SetTable(SalesAdvLetterHeaderCZZ);
                    SalesAdvLetterHeaderCZZ.Validate(Status, SalesAdvLetterHeaderCZZ.Status::"Pending Approval");
                    SalesAdvLetterHeaderCZZ.Modify();
                    Variant := SalesAdvLetterHeaderCZZ;
                    IsHandled := true;
                end;
            Database::"Purch. Adv. Letter Header CZZ":
                begin
                    RecRef.SetTable(PurchAdvLetterHeaderCZZ);
                    PurchAdvLetterHeaderCZZ.Validate(Status, PurchAdvLetterHeaderCZZ.Status::"Pending Approval");
                    PurchAdvLetterHeaderCZZ.Modify();
                    Variant := PurchAdvLetterHeaderCZZ;
                    IsHandled := true;
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendSalesAdvanceLetterForApproval(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelSalesAdvanceLetterApprovalRequest(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendPurchaseAdvanceLetterForApproval(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelPurchaseAdvanceLetterApprovalRequest(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;
}
