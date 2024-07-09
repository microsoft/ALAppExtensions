// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.CashDesk;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Posting;

codeunit 31022 "Purch.-Post Handler CZZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure PurchPostOnBeforePostPurchaseDoc(var PurchaseHeader: Record "Purchase Header")
    var
        PurchAdvLetterManagement: Codeunit "PurchAdvLetterManagement CZZ";
    begin
        if (not PurchaseHeader.Invoice) or (not PurchaseHeader.IsAdvanceLetterDocTypeCZZ()) then
            exit;

        PurchAdvLetterManagement.CheckAdvancePayment(PurchaseHeader.GetAdvLetterUsageDocTypeCZZ(), PurchaseHeader)
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase Handler CZP", 'OnBeforeCreateCashDocument', '', false, false)]
    local procedure SalesPostOnBeforeCreateCashDocument(var PurchHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        PurchPostOnAfterFinalizePostingOnBeforeCommit(PurchHeader, PurchInvHeader, GenJnlPostLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure PurchPostOnAfterFinalizePostingOnBeforeCommit(var PurchHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GetLastGLEntryNoCZZ: Codeunit "Get Last G/L Entry No. CZZ";
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
        AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ";
    begin
        if (not PurchHeader.Invoice) or (not PurchHeader.IsAdvanceLetterDocTypeCZZ()) then
            exit;

        PurchInvHeader.CalcFields("Remaining Amount");
        if PurchInvHeader."Remaining Amount" = 0 then
            exit;

        AdvLetterUsageDocTypeCZZ := PurchHeader.GetAdvLetterUsageDocTypeCZZ();

        VendorLedgerEntry.Get(PurchInvHeader."Vendor Ledger Entry No.");
        BindSubscription(GetLastGLEntryNoCZZ);
        PurchAdvLetterManagementCZZ.PostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ, PurchHeader."No.", PurchInvHeader, VendorLedgerEntry, GenJnlPostLine, false);
        UnbindSubscription(GetLastGLEntryNoCZZ);

        if not PurchHeader.Get(PurchHeader."Document Type", PurchHeader."No.") then begin
            AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Purchase);
            AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvLetterUsageDocTypeCZZ);
            AdvanceLetterApplicationCZZ.SetRange("Document No.", PurchHeader."No.");
            AdvanceLetterApplicationCZZ.DeleteAll(true);
        end;

        OnAfterPurchPostOnAfterFinalizePostingOnBeforeCommit(PurchHeader, PurchInvHeader, GenJnlPostLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeCreatePrepmtLines', '', false, false)]
    local procedure DisablePrepmtLinesOnBeforeCreatePrepmtLines(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeTestStatusRelease', '', false, false)]
    local procedure DisableCheckOnBeforeTestStatusRelease(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPurchPostOnAfterFinalizePostingOnBeforeCommit(var PurchHeader: Record "Purchase Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;
}
