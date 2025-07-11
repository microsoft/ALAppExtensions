// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Document;

codeunit 31066 "Purchase Header Handler CZZ"
{
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure PurchaseHeaderOnAfterDelete(var Rec: Record "Purchase Header")
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
    begin
        if (Rec.IsTemporary) or (Rec."Document Type" <> Rec."Document Type"::Order) or (Rec."No." = '') then
            exit;

        PurchAdvLetterHeaderCZZ.SetRange("Order No.", Rec."No.");
        PurchAdvLetterHeaderCZZ.ModifyAll("Order No.", '');
    end;
}
