// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Bank;

codeunit 31001 "Rel. Sales Adv.Letter Doc. CZZ"
{
    TableNo = "Sales Adv. Letter Header CZZ";

    trigger OnRun()
    begin
        SalesAdvLetterHeaderCZZ.Copy(Rec);
        Code();
        Rec := SalesAdvLetterHeaderCZZ;
    end;

    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        ApprovalProcessReleaseErr: Label 'This document can only be released when the approval process is complete.';
        ApprovalProcessReopenErr: Label 'The approval process must be cancelled or completed to reopen this document.';
        NegativeAmountErr: Label 'must not be negative';

    local procedure Code()
    var
        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";
        VariableSymbol: Code[10];
        IsHandled: Boolean;
    begin
        if not (SalesAdvLetterHeaderCZZ.Status in [SalesAdvLetterHeaderCZZ.Status::New, SalesAdvLetterHeaderCZZ.Status::"Pending Approval"]) then
            exit;

        IsHandled := false;
        OnBeforeReleaseDoc(SalesAdvLetterHeaderCZZ, IsHandled);
        if IsHandled then
            exit;

        SalesAdvLetterHeaderCZZ.CheckSalesAdvanceLetterReleaseRestrictions();

        SalesAdvLetterHeaderCZZ.TestField("Bill-to Customer No.");
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
        SalesAdvLetterHeaderCZZ.TestField("Amount Including VAT");
        if SalesAdvLetterHeaderCZZ."Amount Including VAT" < 0 then
            SalesAdvLetterHeaderCZZ.FieldError("Amount Including VAT", NegativeAmountErr);
        if SalesAdvLetterHeaderCZZ."Variable Symbol" = '' then begin
            VariableSymbol := BankOperationsFunctionsCZL.CreateVariableSymbol(SalesAdvLetterHeaderCZZ."No.");
            OnUpdateVariableSymbol(SalesAdvLetterHeaderCZZ, VariableSymbol);
            SalesAdvLetterHeaderCZZ."Variable Symbol" := VariableSymbol;
        end;

        SalesAdvLetterManagementCZZ.AdvEntryInit(false);
        SalesAdvLetterManagementCZZ.AdvEntryInsert("Advance Letter Entry Type CZZ"::"Initial Entry", SalesAdvLetterHeaderCZZ."No.", SalesAdvLetterHeaderCZZ."Posting Date",
            SalesAdvLetterHeaderCZZ."Amount Including VAT", SalesAdvLetterHeaderCZZ."Amount Including VAT (LCY)",
            SalesAdvLetterHeaderCZZ."Currency Code", SalesAdvLetterHeaderCZZ."Currency Factor", SalesAdvLetterHeaderCZZ."No.",
            SalesAdvLetterHeaderCZZ."Shortcut Dimension 1 Code", SalesAdvLetterHeaderCZZ."Shortcut Dimension 2 Code", SalesAdvLetterHeaderCZZ."Dimension Set ID", false);

        SalesAdvLetterManagementCZZ.UpdateStatus(SalesAdvLetterHeaderCZZ, SalesAdvLetterHeaderCZZ.Status::"To Pay");

        OnAfterReleaseDoc(SalesAdvLetterHeaderCZZ);
    end;

    procedure PerformManualRelease(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        AdvPaymentsApprovMgtCZZ: Codeunit "Adv. Payments Approv. Mgt. CZZ";
    begin
        if AdvPaymentsApprovMgtCZZ.IsSalesAdvanceLetterApprovalsWorkflowEnabled(SalesAdvLetterHeaderCZZ) and
           (SalesAdvLetterHeaderCZZ.Status = SalesAdvLetterHeaderCZZ.Status::New)
        then
            Error(ApprovalProcessReleaseErr);

        Codeunit.Run(Codeunit::"Rel. Sales Adv.Letter Doc. CZZ", SalesAdvLetterHeaderCZZ);
    end;

    procedure Reopen(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
    begin
        OnBeforeReopenDoc(SalesAdvLetterHeaderCZZ);

        if SalesAdvLetterHeaderCZZ.Status = SalesAdvLetterHeaderCZZ.Status::New then
            exit;

        SalesAdvLetterManagementCZZ.CancelInitEntry(SalesAdvLetterHeaderCZZ, 0D, true);
        SalesAdvLetterManagementCZZ.UpdateStatus(SalesAdvLetterHeaderCZZ, SalesAdvLetterHeaderCZZ.Status::New);

        OnAfterReopenDoc(SalesAdvLetterHeaderCZZ);
    end;

    procedure PerformManualReopen(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        if SalesAdvLetterHeaderCZZ.Status = SalesAdvLetterHeaderCZZ.Status::"Pending Approval" then
            Error(ApprovalProcessReopenErr);

        Reopen(SalesAdvLetterHeaderCZZ);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReleaseDoc(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReleaseDoc(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReopenDoc(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReopenDoc(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateVariableSymbol(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var VariableSymbol: Code[10])
    begin
    end;
}
