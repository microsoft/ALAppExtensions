// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Setup;

tableextension 31072 "Purchases & Payables Setup CZZ" extends "Purchases & Payables Setup"
{
    procedure IsDocumentTotalAmountsAllowedCZZ(PurchAdvLetterHeader: Record "Purch. Adv. Letter Header CZZ") IsAllowed: Boolean
    begin
        IsAllowed := Rec."Check Doc. Total Amounts";
        OnIsDocumentTotalAmountsAllowedCZZZ(PurchAdvLetterHeader, IsAllowed);
    end;

    procedure IsDocumentTotalAmountsEditableCZZ(PurchAdvLetterHeader: Record "Purch. Adv. Letter Header CZZ") IsEditable: Boolean
    begin
        IsEditable := PurchAdvLetterHeader.Status = PurchAdvLetterHeader.Status::"New";
        OnIsDocumentTotalAmountsEditableCZZ(PurchAdvLetterHeader, IsEditable);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsDocumentTotalAmountsAllowedCZZZ(PurchAdvLetterHeader: Record "Purch. Adv. Letter Header CZZ"; var IsAllowed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsDocumentTotalAmountsEditableCZZ(PurchAdvLetterHeader: Record "Purch. Adv. Letter Header CZZ"; var IsEditable: Boolean)
    begin
    end;
}