// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;

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

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Line", 'OnBeforeCalcVATAmountLines', '', false, false)]
    local procedure ExcludePrepaymentLinesOnBeforeCalcVATAmountLines(SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; var TempVATAmountLine: Record "VAT Amount Line" temporary; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        TempVATAmountLine.DeleteAll();
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        SalesInvLine.SetRange("Prepayment Line", false); // Exclude prepayment lines created by the legacy advance payment implementation
        if SalesInvLine.FindSet() then
            repeat
                TempVATAmountLine.Init();
                TempVATAmountLine.CopyFromSalesInvLine(SalesInvLine);
                TempVATAmountLine.InsertLine();
            until SalesInvLine.Next() = 0;

        IsHandled := true;
    end;
}
