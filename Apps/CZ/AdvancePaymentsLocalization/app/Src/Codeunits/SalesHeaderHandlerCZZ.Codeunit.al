// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.Document;

codeunit 31092 "Sales Header Handler CZZ"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure SalesHeaderOnAfterDelete(var Rec: Record "Sales Header")
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
    begin
        if (Rec.IsTemporary) or (Rec."Document Type" <> Rec."Document Type"::Order) or (Rec."No." = '') then
            exit;

        SalesAdvLetterHeaderCZZ.SetRange("Order No.", Rec."No.");
        SalesAdvLetterHeaderCZZ.ModifyAll("Order No.", '');
    end;
}
