// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.EU3PartyTrade;

using Microsoft.Inventory.Requisition;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;

codeunit 4884 "EU3 Purch.-Get Drop Shpt Sbscr"
{
    Access = Internal;
    Permissions = tabledata "Requisition Line" = r,
                  tabledata "Purchase Header" = rm,
                  tabledata "Sales Header" = r;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Purch.-Get Drop Shpt.", 'OnCodeOnBeforeModify', '', false, false)]
    local procedure OnCodeOnBeforeModify(var PurchaseHeader: Record "Purchase Header"; SalesHeader: Record "Sales Header")
    var
        ConfirmSameEU3PartyTradeMsg: Label '%1 on %2 %3 is %4.\Do you wish to change %5 on %6 %7 from %8 to %9?', Comment = '%1 = EU 3-Party Trade field caption, %2 = Sales Header table name, %3 = EU 3-Party Trade field value, %4 = Field Caption of EU 3 Party Trade in Purchase Header, %5 = Table caption, %6 = Purchase Header number, %7 = Field value, %8 = Field value';
    begin
        if SalesHeader."EU 3-Party Trade" <> PurchaseHeader."EU 3 Party Trade" then
            if Confirm(ConfirmSameEU3PartyTradeMsg, true,
              SalesHeader.FieldCaption("EU 3-Party Trade"), SalesHeader.TableCaption(), SalesHeader."No.",
              SalesHeader."EU 3-Party Trade", PurchaseHeader.FieldCaption("EU 3 Party Trade"),
              PurchaseHeader.TableCaption(), PurchaseHeader."No.", PurchaseHeader."EU 3 Party Trade",
              SalesHeader."EU 3-Party Trade") then
                PurchaseHeader."EU 3 Party Trade" := SalesHeader."EU 3-Party Trade";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", 'OnAfterInsertPurchOrderHeader', '', false, false)]
    local procedure OnAfterInsertPurchOrderHeader(var RequisitionLine: Record "Requisition Line"; var PurchaseOrderHeader: Record "Purchase Header"; CommitIsSuppressed: Boolean; SpecialOrder: Boolean)
    var
        SalesHeader: Record "Sales Header";
    begin
        if (RequisitionLine."Sales Order No." = '') or (RequisitionLine."Sales Order Line No." = 0) or (not RequisitionLine."Drop Shipment") then
            exit;

        SalesHeader.SetLoadFields("EU 3-Party Trade");
        if not SalesHeader.Get(SalesHeader."Document Type"::Order, RequisitionLine."Sales Order No.") then
            exit;

        PurchaseOrderHeader.Validate("EU 3 Party Trade", SalesHeader."EU 3-Party Trade");
    end;
}
