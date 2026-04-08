// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.History;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Purchases.Payables;
using System.Security.User;

codeunit 11761 "Ext. Doc. No. Changing CZL"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;
    Permissions = TableData "VAT Entry" = r,
                  TableData "G/L Entry" = r,
                  TableData "Purch. Inv. Header" = r;

    var
        VATEntryInVATCtrlReportErr: Label 'The VAT Entries are already included in the VAT Control Report.';
        VATEntryClosedErr: Label 'The VAT Entries are already closed.';

    procedure IsAllowed() Result: Boolean
    var
        UserSetupAdvManagement: Codeunit "User Setup Adv. Management CZL";
    begin
        Result := UserSetupAdvManagement.IsExtDocNoChangingAllowed();
        OnIsAllowed(Result);
    end;

    procedure IsActivated() Result: Boolean
    begin
        OnIsActivated(Result);
    end;

    internal procedure Init(FromVendorLedgerEntry: Record "Vendor Ledger Entry"; var ToVendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        if not CanBeActivate(FromVendorLedgerEntry."External Document No.", ToVendorLedgerEntry."External Document No.") then begin
            Deactivate();
            exit;
        end;

        CheckVATEntries(ToVendorLedgerEntry);
        ToVendorLedgerEntry."External Document No." := FromVendorLedgerEntry."External Document No.";

        Activate();
    end;

    internal procedure Init(FromPurchInvHeader: Record "Purch. Inv. Header"; var ToPurchInvHeader: Record "Purch. Inv. Header")
    begin
        if not CanBeActivate(FromPurchInvHeader."Vendor Invoice No.", ToPurchInvHeader."Vendor Invoice No.") then begin
            Deactivate();
            exit;
        end;

        FromPurchInvHeader.CheckAndConfirmExternalDocumentNumber();
        ToPurchInvHeader."Vendor Invoice No." := FromPurchInvHeader."Vendor Invoice No.";

        Activate();
    end;

    local procedure CanBeActivate(FromExternalDocumentNo: Code[35]; ToExternalDocumentNo: Code[35]): Boolean
    begin
        exit((FromExternalDocumentNo <> ToExternalDocumentNo) and IsAllowed());
    end;

    local procedure Activate()
    begin
        TryActivate();
    end;

    local procedure Deactivate()
    begin
        TryDeactivate();
    end;

    local procedure TryActivate(): Boolean
    begin
        exit(BindSubscription(this));
    end;

    local procedure TryDeactivate(): Boolean
    begin
        exit(UnbindSubscription(this));
    end;

    internal procedure CheckVATEntries(VendLedgEntry: Record "Vendor Ledger Entry")
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetCurrentKey("Document No.", "Posting Date");
        VATEntry.SetRange("Document No.", VendLedgEntry."Document No.");
        VATEntry.SetRange("Posting Date", VendLedgEntry."Posting Date");
        VATEntry.SetFilter("VAT Ctrl. Report No. CZL", '<>%1', '');
        if not VATEntry.IsEmpty() then
            Error(VATEntryInVATCtrlReportErr);

        VATEntry.SetRange("VAT Ctrl. Report No. CZL");
        VATEntry.SetRange(Closed, true);
        if not VATEntry.IsEmpty() then
            Error(VATEntryClosedErr);
    end;

    internal procedure UpdateVATEntries(VendLedgEntry: Record "Vendor Ledger Entry")
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.SetCurrentKey("Document No.", "Posting Date");
        VATEntry.SetRange("Document No.", VendLedgEntry."Document No.");
        VATEntry.SetRange("Posting Date", VendLedgEntry."Posting Date");
        VATEntry.SetRange(Closed, false);
        VATEntry.SetRange("VAT Ctrl. Report No. CZL", '');
        VATEntry.SetFilter("External Document No.", '<>%1', VendLedgEntry."External Document No.");
        if VATEntry.FindSet() then
            repeat
                VATEntry."External Document No." := VendLedgEntry."External Document No.";
                Codeunit.Run(Codeunit::"VAT Entry - Edit", VATEntry);
            until VATEntry.Next() = 0;
    end;

    internal procedure UpdateGLEntries(VendLedgEntry: Record "Vendor Ledger Entry")
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetCurrentKey("Document No.", "Posting Date");
        GLEntry.SetRange("Document No.", VendLedgEntry."Document No.");
        GLEntry.SetRange("Posting Date", VendLedgEntry."Posting Date");
        GLEntry.SetFilter("External Document No.", '<>%1', VendLedgEntry."External Document No.");
        if GLEntry.FindSet() then
            repeat
                GLEntry."External Document No." := VendLedgEntry."External Document No.";
                Codeunit.Run(Codeunit::"G/L Entry-Edit", GLEntry);
            until GLEntry.Next() = 0;
    end;

    internal procedure UpdatePurchInvHeader(VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        PurchInvHeader.SetRange("Vendor Ledger Entry No.", VendorLedgerEntry."Entry No.");
        if not PurchInvHeader.FindFirst() then
            exit;
        if PurchInvHeader."Vendor Invoice No." = VendorLedgerEntry."External Document No." then
            exit;
        PurchInvHeader."Vendor Invoice No." := VendorLedgerEntry."External Document No.";
        Codeunit.Run(Codeunit::"Update Purch. Inv. Header CZL", PurchInvHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsAllowed(var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsActivated(var Result: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Ext. Doc. No. Changing CZL", OnIsActivated, '', false, false)]
    local procedure SetOnIsActivated(var Result: Boolean)
    begin
        Result := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vend. Entry-Edit", 'OnRunOnAfterVendLedgEntryMofidy', '', false, false)]
    local procedure UpdateEntriesOnRunOnAfterVendLedgEntryMofidy(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        UpdateVATEntries(VendorLedgerEntry);
        UpdateGLEntries(VendorLedgerEntry);
        UpdatePurchInvHeader(VendorLedgerEntry);
    end;
}