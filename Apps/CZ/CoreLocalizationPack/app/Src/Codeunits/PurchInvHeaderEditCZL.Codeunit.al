// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.History;

using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;

codeunit 11759 "Purch. Inv. Header - Edit CZL"
{
    Access = Internal;
    EventSubscriberInstance = Manual;
    TableNo = "Purch. Inv. Header";

    trigger OnRun()
    begin
        BindSubscription(this);

        PurchInvHeader := Rec;
        Codeunit.Run(Codeunit::"Purch. Inv. Header - Edit", Rec);

        UnbindSubscription(this);
    end;

    var
        PurchInvHeader: Record "Purch. Inv. Header";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vend. Entry-Edit", OnBeforeOnRun, '', false, false)]
    local procedure SuppressUpdateVendorLedgerEntryOnBeforeOnRun(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Mgt.", OnAfterSetFilterForExternalDocNo, '', false, false)]
    local procedure SetTrueOnIsActivated(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        VendorLedgerEntry.SetFilter("Entry No.", '<>%1', PurchInvHeader."Vendor Ledger Entry No.");
    end;
}