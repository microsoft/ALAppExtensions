// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Bank;
using Microsoft.Purchases.Setup;
using Microsoft.Finance.VAT.Setup;

codeunit 31018 "Rel. Purch.Adv.Letter Doc. CZZ"
{
    TableNo = "Purch. Adv. Letter Header CZZ";

    trigger OnRun()
    begin
        PurchAdvLetterHeaderCZZ.Copy(Rec);
        Code();
        Rec := PurchAdvLetterHeaderCZZ;
    end;

    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        ApprovalProcessReleaseErr: Label 'This document can only be released when the approval process is complete.';
        ApprovalProcessReopenErr: Label 'The approval process must be cancelled or completed to reopen this document.';
        NegativeAmountErr: Label 'must not be negative';
        VATProdPostingGroupWithCoeffErr: Label 'cannot be used because it is allowed to be used for non-deductible VAT. Enable non-deductible VAT for advances in the VAT setup or choose another VAT Prod. Posting Group.';
        CheckTotalAmountPurchLinesErr: Label '%1 (%2) is not equal to total of lines (%3)', Comment = '%1 = FieldCaption of Doc. Amount Incl. VAT; %2 = Doc. Amount Incl. VAT; %3 = Amount Including VAT ';
        CheckTotalAmountVATPurchLinesErr: Label '%1 (%2) is not equal to total of VAT on lines (%3)', Comment = '%1 = Doc. Amount VAT; %2 = Doc. Amount VAT; %3 = Amount Including VAT - PurchAdvLetterHeader.Amount';

    local procedure Code()
    var
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";
        VariableSymbol: Code[10];
        IsHandled: Boolean;
    begin
        if not (PurchAdvLetterHeaderCZZ.Status in [PurchAdvLetterHeaderCZZ.Status::New, PurchAdvLetterHeaderCZZ.Status::"Pending Approval"]) then
            exit;

        IsHandled := false;
        OnBeforeReleaseDoc(PurchAdvLetterHeaderCZZ, IsHandled);
        if IsHandled then
            exit;

        PurchAdvLetterHeaderCZZ.CheckPurchaseAdvanceLetterReleaseRestrictions();
        PurchAdvLetterHeaderCZZ.TestField("Pay-to Vendor No.");

        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", Amount, "Amount Including VAT (LCY)");
        PurchAdvLetterHeaderCZZ.TestField("Amount Including VAT");
        if PurchAdvLetterHeaderCZZ."Amount Including VAT" < 0 then
            PurchAdvLetterHeaderCZZ.FieldError("Amount Including VAT", NegativeAmountErr);
        CheckDocumentTotalAmounts(PurchAdvLetterHeaderCZZ);
        CheckPurchAdvLetterLines(PurchAdvLetterHeaderCZZ);
        if PurchAdvLetterHeaderCZZ."Variable Symbol" = '' then begin
            VariableSymbol := BankOperationsFunctionsCZL.CreateVariableSymbol(PurchAdvLetterHeaderCZZ."Vendor Adv. Letter No.");
            OnUpdateVariableSymbol(PurchAdvLetterHeaderCZZ, VariableSymbol);
            PurchAdvLetterHeaderCZZ."Variable Symbol" := VariableSymbol;
        end;

        PurchAdvLetterManagementCZZ.AdvEntryInit(false);
        PurchAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::"Initial Entry", PurchAdvLetterHeaderCZZ."No.", PurchAdvLetterHeaderCZZ."Posting Date",
            -PurchAdvLetterHeaderCZZ."Amount Including VAT", -PurchAdvLetterHeaderCZZ."Amount Including VAT (LCY)",
            PurchAdvLetterHeaderCZZ."Currency Code", PurchAdvLetterHeaderCZZ."Currency Factor", PurchAdvLetterHeaderCZZ."No.", '',
            PurchAdvLetterHeaderCZZ."Shortcut Dimension 1 Code", PurchAdvLetterHeaderCZZ."Shortcut Dimension 2 Code", PurchAdvLetterHeaderCZZ."Dimension Set ID", false);

        PurchAdvLetterHeaderCZZ.UpdateStatus(PurchAdvLetterHeaderCZZ.Status::"To Pay");

        OnAfterReleaseDoc(PurchAdvLetterHeaderCZZ);
    end;

    procedure PerformManualRelease(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    var
        AdvPaymentsApprovMgtCZZ: Codeunit "Adv. Payments Approv. Mgt. CZZ";
    begin
        if AdvPaymentsApprovMgtCZZ.IsPurchaseAdvanceLetterApprovalsWorkflowEnabled(PurchAdvLetterHeaderCZZ) and
           (PurchAdvLetterHeaderCZZ.Status = PurchAdvLetterHeaderCZZ.Status::New)
        then
            Error(ApprovalProcessReleaseErr);

        Codeunit.Run(Codeunit::"Rel. Purch.Adv.Letter Doc. CZZ", PurchAdvLetterHeaderCZZ);
    end;


    procedure Reopen(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    var
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
    begin
        OnBeforeReopenDoc(PurchAdvLetterHeaderCZZ);

        if PurchAdvLetterHeaderCZZ.Status = PurchAdvLetterHeaderCZZ.Status::New then
            exit;

        PurchAdvLetterManagementCZZ.CancelInitEntry(PurchAdvLetterHeaderCZZ, 0D, true);
        PurchAdvLetterHeaderCZZ.UpdateStatus(PurchAdvLetterHeaderCZZ.Status::New);

        OnAfterReopenDoc(PurchAdvLetterHeaderCZZ);
    end;

    procedure PerformManualReopen(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        if PurchAdvLetterHeaderCZZ.Status = PurchAdvLetterHeaderCZZ.Status::"Pending Approval" then
            Error(ApprovalProcessReopenErr);

        Reopen(PurchAdvLetterHeaderCZZ);
    end;

    local procedure CheckPurchAdvLetterLines(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    var
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        VATSetup: Record "VAT Setup";
    begin
        VATSetup.Get();
        if VATSetup."Use For Advances CZZ" then
            exit;

        PurchAdvLetterLineCZZ.SetRange("Document No.", PurchAdvLetterHeaderCZZ."No.");
        if PurchAdvLetterLineCZZ.FindSet() then
            repeat
                if VATPostingSetup.IsNonDeductibleVATAllowed(PurchAdvLetterLineCZZ."VAT Bus. Posting Group", PurchAdvLetterLineCZZ."VAT Prod. Posting Group") then
                    PurchAdvLetterLineCZZ.FieldError("VAT Prod. Posting Group", VATProdPostingGroupWithCoeffErr);
            until PurchAdvLetterLineCZZ.Next() = 0;
    end;

    local procedure CheckDocumentTotalAmounts(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckDocumentTotalAmounts(PurchAdvLetterHeaderCZZ, IsHandled);
        if IsHandled then
            exit;

        PurchasesPayablesSetup.Get();
        if not PurchasesPayablesSetup.IsDocumentTotalAmountsAllowedCZZ(PurchAdvLetterHeaderCZZ) then
            exit;

        if PurchAdvLetterHeaderCZZ."Amount Including VAT" <> PurchAdvLetterHeaderCZZ."Doc. Amount Incl. VAT" then
            Error(ErrorInfo.Create(
                    StrSubstNo(CheckTotalAmountPurchLinesErr, PurchAdvLetterHeaderCZZ.FieldCaption("Doc. Amount Incl. VAT"), PurchAdvLetterHeaderCZZ."Doc. Amount Incl. VAT", PurchAdvLetterHeaderCZZ."Amount Including VAT"), true, PurchAdvLetterHeaderCZZ));
        if (PurchAdvLetterHeaderCZZ."Amount Including VAT" - PurchAdvLetterHeaderCZZ.Amount) <> PurchAdvLetterHeaderCZZ."Doc. Amount VAT" then
            Error(ErrorInfo.Create(
                    StrSubstNo(CheckTotalAmountVATPurchLinesErr, PurchAdvLetterHeaderCZZ.FieldCaption("Doc. Amount VAT"), PurchAdvLetterHeaderCZZ."Doc. Amount VAT", PurchAdvLetterHeaderCZZ."Amount Including VAT" - PurchAdvLetterHeaderCZZ.Amount), true, PurchAdvLetterHeaderCZZ));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReleaseDoc(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReleaseDoc(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReopenDoc(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReopenDoc(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateVariableSymbol(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var VariableSymbol: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDocumentTotalAmounts(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;
}
