// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Foundation.Company;
using Microsoft.Inventory.Availability;
using Microsoft.Inventory.Item;

codeunit 4413 "SOA Shipment Date Mgt."
{
    Access = Internal;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        ItemNo: Code[20];
        VariantCode, LocationCode, InUOMCode : Code[10];
        NeededDate, EarliestShipmentDate : Date;
        NeededQty: Decimal;
        SOAShipmentDateMgtLbl: Label 'SOA-SHIPMENTDATEMGT', Locked = true;

    trigger OnRun()
    begin
        EarliestShipmentDate := CalculateEarliestShipmentDate();
    end;

    internal procedure SetParamenters(ItemNo2: Code[20]; VariantCode2: Code[10]; LocationCode2: Code[10]; InUOMCode2: Code[10]; NeededDate2: Date; NeededQty2: Decimal)
    begin
        ItemNo := ItemNo2;
        VariantCode := VariantCode2;
        LocationCode := LocationCode2;
        InUOMCode := InUOMCode2;
        NeededDate := NeededDate2;
        if NeededQty2 > 0 then
            NeededQty := NeededQty2
        else
            NeededQty := 1;
    end;

    internal procedure GetEarliestShipmentDate(): Date
    begin
        exit(EarliestShipmentDate);
    end;

    local procedure CalculateEarliestShipmentDate() ShipmentDate: Date
    var
        CompanyInfo: Record "Company Information";
        Item: Record Item;
        CapableToPromise: Codeunit "Capable to Promise";
        LastValidLine: Integer;
        DocumentNo: Code[20];
    begin
        if InUOMCode = '' then
            if Item.Get(ItemNo) then
                InUOMCode := Item."Sales Unit of Measure";

        CompanyInfo.Get();
        DocumentNo := SOAShipmentDateMgtLbl;

        BindSubscription(this);
        ShipmentDate := CapableToPromise.CalcCapableToPromiseDate(
            ItemNo, VariantCode, LocationCode, NeededDate, NeededQty, InUOMCode,
            DocumentNo, 10000, LastValidLine, CompanyInfo."Check-Avail. Time Bucket",
            CompanyInfo."Check-Avail. Period Calc.");
        UnbindSubscription(this);

        CapableToPromise.RemoveReqLines(DocumentNo, 10000, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Available to Promise", 'OnAfterQtyAvailableToPromise', '', false, false)]
    local procedure OnAfterQtyAvailableToPromise(var Item: Record Item; ScheduledReceipt: Decimal; GrossRequirement: Decimal; var AvailableToPromise: Decimal)
    begin
        // To intoriduce a sales demand without creating a sales line, we use the OnAfterQtyAvailableToPromise event with manual binding.
        if (NeededDate >= Item.GetRangeMin("Date Filter")) and (NeededDate <= Item.GetRangeMax("Date Filter")) then
            AvailableToPromise -= NeededQty;
    end;
}