// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Requisition;
using Microsoft.Inventory.Setup;
using Microsoft.Manufacturing.Document;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;

codeunit 18471 "Update Subcontract Details"
{
    var
        DeliveryChallanLineExistsErr: Label 'Line cannot be deleted. Delivery Challan exist for Subcontracting Order no. %1, Line No. %2', Comment = '%1 = Subcontracting Order No., %2 = and Line No.';

    procedure InsertSubComponentsDetails(PurchLine: Record "Purchase Line")
    var
        SubOrderComponents: Record "Sub Order Component List";
        ProdOrderComponent: Record "Prod. Order Component";
        SubOrderCompListVend: Record "Sub Order Comp. List Vend";
        InventorySetup: Record "Inventory Setup";
        Item: Record Item;
        Vendor: Record Vendor;
        UOMMgt: Codeunit "Unit of Measure Management";
    begin
        InventorySetup.Get();
        ProdOrderComponent.SetRange(Status, ProdOrderComponent.Status::Released);
        ProdOrderComponent.SetRange("Prod. Order No.", PurchLine."Prod. Order No.");
        ProdOrderComponent.SetRange("Prod. Order Line No.", PurchLine."Prod. Order Line No.");
        if ProdOrderComponent.FindSet() then
            repeat
                SubOrderComponents.Init();
                SubOrderComponents."Document No." := PurchLine."Document No.";
                SubOrderComponents."Document Line No." := PurchLine."Line No.";
                SubOrderComponents."Production Order No." := PurchLine."Prod. Order No.";
                SubOrderComponents."Production Order Line No." := PurchLine."Prod. Order Line No.";
                SubOrderComponents."Line No." := ProdOrderComponent."Line No.";
                SubOrderComponents."Parent Item No." := PurchLine."No.";
                if PurchLine."Dimension Set ID" <> 0 then
                    SubOrderComponents."Dimension Set ID" := PurchLine."Dimension Set ID";
                SubOrderComponents.Insert();

                SubOrderComponents."Item No." := ProdOrderComponent."Item No.";
                SubOrderComponents."Unit of Measure Code" := ProdOrderComponent."Unit of Measure Code";
                SubOrderComponents.Description := COPYSTR(ProdOrderComponent.Description, 1, 30);
                SubOrderComponents."Quantity per" := ProdOrderComponent."Quantity per";
                SubOrderComponents."Quantity To Send" := ProdOrderComponent."Expected Quantity";

                Item.Get(SubOrderComponents."Item No.");
                SubOrderComponents."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
                SubOrderComponents."Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, SubOrderComponents."Unit of Measure Code");
                SubOrderComponents."Quantity (Base)" := Round(
                    SubOrderComponents."Quantity To Send" *
                    SubOrderComponents."Qty. per Unit of Measure", 0.00001);
                SubOrderComponents."Quantity To Send (Base)" := SubOrderComponents."Quantity (Base)";
                SubOrderComponents.Description := CopyStr(ProdOrderComponent.Description, 1, 30);
                SubOrderComponents.Validate("Scrap %", ProdOrderComponent."Scrap %");
                SubOrderComponents."Variant Code" := ProdOrderComponent."Variant Code";

                Item.Get(SubOrderComponents."Parent Item No.");
                SubOrderComponents."Company Location" := UpdateSubCompLocation(Item);

                Vendor.Get(PurchLine."Buy-from Vendor No.");
                Vendor.TestField("Vendor Location");

                SubOrderComponents."Vendor Location" := Vendor."Vendor Location";

                InventorySetup.TestField("Job Work Return Period");

                SubOrderComponents."Job Work Return Period" := InventorySetup."Job Work Return Period";
                SubOrderComponents.Modify();
            until ProdOrderComponent.Next() = 0;

        ProdOrderComponent.Reset();
        ProdOrderComponent.SetRange(Status, ProdOrderComponent.Status::Released);
        ProdOrderComponent.SetRange("Prod. Order No.", PurchLine."Prod. Order No.");
        ProdOrderComponent.SetRange("Prod. Order Line No.", PurchLine."Prod. Order Line No.");
        if ProdOrderComponent.FindSet() then
            repeat
                SubOrderCompListVend.Init();
                SubOrderCompListVend."Document No." := PurchLine."Document No.";
                SubOrderCompListVend."Document Line No." := PurchLine."Line No.";
                SubOrderCompListVend."Production Order No." := PurchLine."Prod. Order No.";
                SubOrderCompListVend."Production Order Line No." := PurchLine."Prod. Order Line No.";
                SubOrderCompListVend."Line No." := ProdOrderComponent."Line No.";
                SubOrderCompListVend."Parent Item No." := PurchLine."No.";
                SubOrderCompListVend.Insert();

                SubOrderCompListVend."Item No." := ProdOrderComponent."Item No.";
                SubOrderCompListVend."Unit of Measure" := ProdOrderComponent."Unit of Measure Code";
                SubOrderCompListVend.Description := COPYSTR(ProdOrderComponent.Description, 1, 30);
                SubOrderCompListVend."Quantity per" := ProdOrderComponent."Quantity per";

                Item.Get(SubOrderCompListVend."Item No.");
                SubOrderCompListVend."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
                SubOrderCompListVend."Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, SubOrderCompListVend."Unit of Measure");
                SubOrderCompListVend.Description := CopyStr(ProdOrderComponent.Description, 1, 30);
                SubOrderCompListVend.Validate("Scrap %", ProdOrderComponent."Scrap %");
                SubOrderCompListVend."Variant Code" := ProdOrderComponent."Variant Code";
                Item.Get(SubOrderCompListVend."Parent Item No.");
                SubOrderCompListVend."Company Location" := UpdateSubCompLocation(Item);

                Vendor.Get(PurchLine."Buy-from Vendor No.");
                Vendor.TestField("Vendor Location");

                SubOrderCompListVend."Vendor Location" := Vendor."Vendor Location";
                SubOrderCompListVend.Modify();
            until ProdOrderComponent.Next() = 0;
        PurchLine.Modify();
    end;

    procedure UpdateProdOrderline(ReqLine: Record "Requisition Line"; PurchOrderHeader: Record "Purchase Line")
    var
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrdComp: Record "Prod. Order Component";
    begin
        ProdOrderLine.Reset();
        ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Released);
        ProdOrderLine.SetRange("Prod. Order No.", ReqLine."Prod. Order No.");
        ProdOrderLine.SetRange("Line No.", ReqLine."Prod. Order Line No.");
        if ProdOrderLine.FindFirst() then begin
            ProdOrderLine."Subcontracting Order No." := PurchOrderHeader."Document No.";
            ProdOrderLine."Subcontractor Code" := PurchOrderHeader."Buy-from Vendor No.";
            ProdOrderLine.Modify();

            //Update Prod. Order Component
            ProdOrdComp.Reset();
            ProdOrdComp.SetRange(Status, ProdOrderLine.Status);
            ProdOrdComp.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
            ProdOrdComp.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
            if ProdOrdComp.FindSet() then
                repeat
                    ProdOrdComp."Subcontracting Order No." := ProdOrderLine."Subcontracting Order No.";
                    ProdOrdComp."Subcontractor Code" := ProdOrderLine."Subcontractor Code";
                    ProdOrdComp.Modify();
                until ProdOrdComp.Next() = 0;
        end;
    end;

    procedure ValidateOrUpdateBeforeSubConOrderLineDelete(PurchaseLine: Record "Purchase Line")
    var
        DeliveryChallanLine: Record "Delivery Challan Line";
    begin
        if not PurchaseLine.Subcontracting then
            exit;

        if PurchaseLine."Quantity Received" > 0 then
            PurchaseLine.TestField("Quantity Received", 0);

        DeliveryChallanLine.LoadFields("Document No.", "Production Order No.", "Production Order Line No.", "Parent Item No.");
        DeliveryChallanLine.SetRange("Document No.", PurchaseLine."Document No.");
        DeliveryChallanLine.SetRange("Production Order No.", PurchaseLine."Prod. Order No.");
        DeliveryChallanLine.SetRange("Production Order Line No.", PurchaseLine."Prod. Order Line No.");
        DeliveryChallanLine.SetRange("Parent Item No.", PurchaseLine."No.");
        if not DeliveryChallanLine.IsEmpty() then
            Error(DeliveryChallanLineExistsErr, PurchaseLine."Document No.", PurchaseLine."Line No.");

        if PurchaseLine.Type = PurchaseLine.Type::Item then
            UpdateProductionOrderLineOnDeleteSubconOrderLine(PurchaseLine);
    end;

    local procedure UpdateProductionOrderLineOnDeleteSubconOrderLine(PurchaseLine: Record "Purchase Line")
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        if not ProdOrderLine.Get(ProdOrderLine.Status::Released, PurchaseLine."Prod. Order No.", PurchaseLine."Prod. Order Line No.") then
            exit;

        ProdOrderLine.TestField("Subcontracting Order No.", PurchaseLine."Document No.");
        ProdOrderLine.TestField("Item No.", PurchaseLine."No.");
        ProdOrderLine."Subcontractor Code" := '';
        ProdOrderLine."Subcontracting Order No." := '';
        ProdOrderLine.Modify();
    end;

    local procedure UpdateSubCompLocation(Item: Record Item): Code[10]
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        if Item."Sub. Comp. Location" <> '' then
            exit(Item."Sub. Comp. Location")
        else
            exit(InventorySetup."Sub. Component Location");
    end;
}
