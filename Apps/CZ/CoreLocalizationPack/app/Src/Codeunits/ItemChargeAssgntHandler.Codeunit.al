// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Shipping;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;

codeunit 31377 "Item Charge Assgnt Handler CZL"
{
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Charge Assgnt. (Purch.)", 'OnBeforeInsertItemChargeAssgntWithAssignValues', '', false, false)]
    local procedure InclPurchItemChargesOnBeforeInsertItemChargeAssgntWithAssignValues(var ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)"; FromItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)")
    var
        PurchaseHeader: Record "Purchase Header";
        ShipmentMethod: Record "Shipment Method";
        ItemCharge: Record "Item Charge";
    begin
        if not PurchaseHeader.Get(FromItemChargeAssgntPurch."Document Type", FromItemChargeAssgntPurch."Document No.") then
            exit;
        if PurchaseHeader."Shipment Method Code" <> '' then
            ShipmentMethod.Get(PurchaseHeader."Shipment Method Code");
        if ShipmentMethod."Incl. Item Charges (S.Val) CZL" or ShipmentMethod."Incl. Item Charges (Amt.) CZL" then begin
            ItemCharge.Get(ItemChargeAssgntPurch."Item Charge No.");
            if ShipmentMethod."Incl. Item Charges (Amt.) CZL" then
                ItemChargeAssgntPurch."Incl. in Intrastat Amount CZL" :=
#pragma warning disable AL0432
                    ItemCharge."Incl. in Intrastat Amount CZL" and ItemChargeAssgntPurch.SetIncludeAmountCZL();
#pragma warning restore AL0432
            if ShipmentMethod."Incl. Item Charges (S.Val) CZL" then
                ItemChargeAssgntPurch."Incl. in Intrastat S.Value CZL" := ItemCharge."Incl. in Intrastat S.Value CZL";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Charge Assgnt. (Sales)", 'OnBeforeInsertItemChargeAssgntWithAssignValues', '', false, false)]
    local procedure InclSalesItemChargesOnBeforeInsertItemChargeAssgntWithAssignValues(var ItemChargeAssgntSales: Record "Item Charge Assignment (Sales)"; FromItemChargeAssgntSales: Record "Item Charge Assignment (Sales)")
    var
        SalesHeader: Record "Sales Header";
        ShipmentMethod: Record "Shipment Method";
        ItemCharge: Record "Item Charge";
    begin
        if not SalesHeader.Get(FromItemChargeAssgntSales."Document Type", FromItemChargeAssgntSales."Document No.") then
            exit;
        if SalesHeader."Shipment Method Code" <> '' then
            ShipmentMethod.Get(SalesHeader."Shipment Method Code");
        if ShipmentMethod."Incl. Item Charges (S.Val) CZL" or ShipmentMethod."Incl. Item Charges (Amt.) CZL" then begin
            ItemCharge.Get(ItemChargeAssgntSales."Item Charge No.");
            if ShipmentMethod."Incl. Item Charges (Amt.) CZL" then
                ItemChargeAssgntSales."Incl. in Intrastat Amount CZL" := ItemCharge."Incl. in Intrastat Amount CZL";
            if ShipmentMethod."Incl. Item Charges (S.Val) CZL" then
                ItemChargeAssgntSales."Incl. in Intrastat S.Value CZL" := ItemCharge."Incl. in Intrastat S.Value CZL";
        end;
    end;
}
#endif
