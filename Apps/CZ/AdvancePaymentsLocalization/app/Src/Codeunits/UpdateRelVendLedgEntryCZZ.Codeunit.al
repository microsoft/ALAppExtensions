// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Payables;

codeunit 11734 "Update Rel.Vend.Ledg.Entry CZZ"
{
    Access = Internal;
    EventSubscriberInstance = Manual;
    TableNo = "Vendor Ledger Entry";

    trigger OnRun()
    var
        RelatedVendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        if IsActivated() then
            exit;

        Activate();

        RelatedVendorLedgerEntry.ReadIsolation(IsolationLevel::UpdLock);
        RelatedVendorLedgerEntry.SetCurrentKey("Document No.");
        RelatedVendorLedgerEntry.SetRange("Document No.", Rec."Document No.");
        RelatedVendorLedgerEntry.SetFilter("Entry No.", '<>%1', Rec."Entry No.");
        if RelatedVendorLedgerEntry.FindSet() then
            repeat
                RelatedVendorLedgerEntry."Specific Symbol CZL" := Rec."Specific Symbol CZL";
                RelatedVendorLedgerEntry."Variable Symbol CZL" := Rec."Variable Symbol CZL";
                RelatedVendorLedgerEntry."Constant Symbol CZL" := Rec."Constant Symbol CZL";
                RelatedVendorLedgerEntry."Bank Account Code CZL" := Rec."Bank Account Code CZL";
                RelatedVendorLedgerEntry."Bank Account No. CZL" := Rec."Bank Account No. CZL";
                RelatedVendorLedgerEntry."Transit No. CZL" := Rec."Transit No. CZL";
                RelatedVendorLedgerEntry."IBAN CZL" := Rec."IBAN CZL";
                RelatedVendorLedgerEntry."SWIFT Code CZL" := Rec."SWIFT Code CZL";
                RelatedVendorLedgerEntry."VAT Date CZL" := Rec."VAT Date CZL";
                RelatedVendorLedgerEntry."External Document No." := Rec."External Document No.";
                Codeunit.Run(Codeunit::"Vend. Entry-Edit", RelatedVendorLedgerEntry);
            until RelatedVendorLedgerEntry.Next() = 0;

        Deactivate();
    end;

    local procedure Activate()
    begin
        BindSubscription(this);
    end;

    local procedure Deactivate()
    begin
        UnbindSubscription(this);
    end;

    local procedure IsActivated() Result: Boolean
    begin
        OnIsActivated(Result);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsActivated(var Result: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Update Rel.Vend.Ledg.Entry CZZ", OnIsActivated, '', false, false)]
    local procedure SetTrueOnIsActivated(var Result: Boolean)
    begin
        Result := true;
    end;
}