// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Planning;
using Microsoft.Inventory.Tracking;
using Microsoft.Manufacturing.Setup;

codeunit 18472 "Apply Delivery Challan Mgt."
{
    SingleInstance = true;

    var
        ForAppDelChEntry: Record "Applied Delivery Challan Entry";
        CalcReservEntry: Record "Reservation Entry";
        CalcReservEntry3: Record "Reservation Entry";
        AppDelChallanNo: Code[20];
        AppDelChallan: Boolean;

    procedure SetAppliedDeliveryChallanEntry(NewAppDelChEntry: Record "Applied Delivery Challan Entry")
    var
        Item2: Record Item;
        DeliveryChallanLine: Record "Delivery Challan Line";
    begin
        ClearAll();
        ForAppDelChEntry := NewAppDelChEntry;
        CalcReservEntry."Source Type" := DATABASE::"Applied Delivery Challan Entry";
        CalcReservEntry."Source ID" := '';
        CalcReservEntry."Source Prod. Order Line" := 0;
        CalcReservEntry."Source Ref. No." := NewAppDelChEntry."Entry No.";
        CalcReservEntry."Item No." := NewAppDelChEntry."Item No.";

        if DeliveryChallanLine.Get(NewAppDelChEntry."Applied Delivery Challan No.", NewAppDelChEntry."App. Delivery Challan Line No.") then begin
            CalcReservEntry."Variant Code" := DeliveryChallanLine."Variant Code";
            CalcReservEntry."Location Code" := DeliveryChallanLine."Vendor Location";
            CalcReservEntry."Qty. per Unit of Measure" := DeliveryChallanLine."Quantity per";
        end;

        CalcReservEntry."Serial No." := '';
        CalcReservEntry."Lot No." := '';

        if Item2.Get(NewAppDelChEntry."Item No.") then
            CalcReservEntry.Description := Item2.Description;

        CalcReservEntry3 := CalcReservEntry;
        GetItemSetup(CalcReservEntry);
        SetPointerFilter(CalcReservEntry3);
    end;

    local procedure GetItemSetup(var ReservEntry: Record "Reservation Entry")
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        SKU: Record "Stockkeeping Unit";
        MfgSetup: Record "Manufacturing Setup";
        GetPlanningParameters: Codeunit "Planning-Get Parameters";
    begin
        if ReservEntry."Item No." <> Item."No." then begin
            Item.Get(ReservEntry."Item No.");
            if Item."Item Tracking Code" <> '' then
                ItemTrackingCode.Get(Item."Item Tracking Code")
            else
                ItemTrackingCode.Init();

            GetPlanningParameters.AtSKU(SKU, ReservEntry."Item No.", ReservEntry."Variant Code", ReservEntry."Location Code");
            MfgSetup.Get();
        end;
    end;

    local procedure SetPointerFilter(var ReservEntry: Record "Reservation Entry")
    begin
        ReservEntry.SetCurrentKey("Source ID", "Source Ref. No.", "Source Type", "Source Subtype",
                                    "Source Batch Name", "Source Prod. Order Line", "Reservation Status",
                                    "Shipment Date", "Expected Receipt Date");
        ReservEntry.SetRange("Source ID", ReservEntry."Source ID");
        ReservEntry.SetRange("Source Ref. No.", ReservEntry."Source Ref. No.");
        ReservEntry.SetRange("Source Type", ReservEntry."Source Type");
        ReservEntry.SetRange("Source Subtype", ReservEntry."Source Subtype");
        ReservEntry.SetRange("Source Batch Name", ReservEntry."Source Batch Name");
        ReservEntry.SetRange("Source Prod. Order Line", ReservEntry."Source Prod. Order Line");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reservation Management", 'OnBeforeDeleteReservEntries', '', false, false)]
    local procedure OnBeforeDeleteReservEntries(var CalcReservEntry2: Record "Reservation Entry"; var ReservationEntry: Record "Reservation Entry")
    begin
        if CalcReservEntry2."Source Type" = 0 then begin
            CalcReservEntry2 := CalcReservEntry3;
            if CalcReservEntry3.GetFilter("Source Type") = Format(Database::"Applied Delivery Challan Entry") then begin
                CalcReservEntry2.CopyFilters(CalcReservEntry3);
                ReservationEntry.CopyFilters(CalcReservEntry3);
            end;
        end;
    end;

    procedure SetAppDelChallan(FromAppDelChallanFrom: Boolean; DeliveryChallanNoFrom: Code[20])
    begin
        AppDelChallan := FromAppDelChallanFrom;
        AppDelChallanNo := DeliveryChallanNoFrom;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Tracking Data Collection", 'OnRetrieveLookupDataOnBeforeTransferToTempRec', '', false, false)]
    local procedure FilterItemLedgEntry(var TempTrackingSpecification: Record "Tracking Specification" temporary; var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        if (TempTrackingSpecification."Source Type" = Database::"Applied Delivery Challan Entry") and AppDelChallan then
            ItemLedgerEntry.SetRange("External Document No.", AppDelChallanNo);
    end;
}
