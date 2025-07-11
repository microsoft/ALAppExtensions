// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup.ChargeOnPurchase;

using Microsoft.Finance.ChargeGroup.ChargeGroupBase;
using Microsoft.Purchases.Document;

codeunit 18517 "Purch. Charge Group Management"
{
    TableNo = "Purchase Line";

    var
        CanInsertChargeGroupLinesQst: label 'Do you want to insert Charge Group line(s) for Document: %1?', Comment = '%1 Document No.';

    trigger OnRun()
    var
        PurchaseLine: Record "Purchase Line";
        IsHandled: Boolean;
    begin
        OnBeforeOnRun(Rec, IsHandled);
        if IsHandled then
            exit;

        PurchaseLine.Copy(Rec);
        Code(PurchaseLine);
        Rec := PurchaseLine;
    end;

    local procedure Code(var PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
        ChargeGroupManagement: Codeunit "Charge Group Management";
        IsHandled: Boolean;
    begin
        OnBeforeConfirmInsertChargeLines(PurchaseLine, IsHandled);
        if IsHandled then
            exit;

        if GuiAllowed then
            if not Confirm(CanInsertChargeGroupLinesQst, true, PurchaseLine."Document No.") then
                exit;

        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        ChargeGroupManagement.InsertChargeItemOnLine(PurchaseHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnRun(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmInsertChargeLines(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;
}
