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
        if (not PurchaseHeader.Invoice) or (not (PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::Order, PurchaseHeader."Document Type"::Invoice])) then
            exit;

        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then
            PurchAdvLetterManagement.CheckAdvancePayment("Adv. Letter Usage Doc.Type CZZ"::"Purchase Order", PurchaseHeader)
        else
            PurchAdvLetterManagement.CheckAdvancePayment("Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader);
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
        if (not PurchHeader.Invoice) or (not (PurchHeader."Document Type" in [PurchHeader."Document Type"::Order, PurchHeader."Document Type"::Invoice])) then
            exit;

        if PurchHeader."Document Type" = PurchHeader."Document Type"::Order then
            AdvLetterUsageDocTypeCZZ := AdvLetterUsageDocTypeCZZ::"Purchase Order"
        else
            AdvLetterUsageDocTypeCZZ := AdvLetterUsageDocTypeCZZ::"Purchase Invoice";

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
}
