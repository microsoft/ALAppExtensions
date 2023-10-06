// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.TaxEngine.UseCaseBuilder;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Posting;
using Microsoft.Inventory.Requisition;
using Microsoft.Inventory.Tracking;
using Microsoft.Manufacturing.Document;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using Microsoft.Warehouse.Document;

codeunit 18469 "Subcontracting Subscribers"
{
    var
        DeliveryChallanExistsErr: Label 'You cannot delete this document. Delivery Challan exist for Subcontracting Order no. %1.', Comment = '%1 = Subcontracting Order No.';
        QutstandingQuantityErr: Label 'Cannot delete Subcontracting order No: %1 as there is remaining quantity pending to be received. Continue with next order?', Comment = '%1 = Document No.';

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeTestNoSeries', '', false, false)]
    local procedure TestSubcontractingNoSeries(var PurchaseHeader: Record "Purchase Header"; Var Ishandled: boolean)
    var
        PurchSetup: Record "Purchases & Payables Setup";
    begin
        PurchSetup.Get();
        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::Order:
                if PurchaseHeader.Subcontracting then begin
                    PurchSetup.TestField("Subcontracting Order Nos.");
                    Ishandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, database::"Purchase Header", 'OnAfterGetNoSeriesCode', '', false, false)]
    local procedure OnAfterGetNoSubcontractingSeriesCode(
        var PurchHeader: Record "Purchase Header";
        PurchSetup: Record "Purchases & Payables Setup";
        var NoSeriesCode: Code[20])
    begin
        case PurchHeader."Document Type" of
            PurchHeader."Document Type"::Order:
                if PurchHeader.Subcontracting then
                    NoSeriesCode := PurchSetup."Subcontracting Order Nos.";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", 'OnBeforePurchOrderHeaderInsert', '', false, false)]
    local procedure SubcontractingPurchOrderHeaderInsert(
        var PurchaseHeader: Record "Purchase Header";
        RequisitionLine: Record "Requisition Line")
    var
        Vendor: Record Vendor;
    begin
        if RequisitionLine."Prod. Order No." <> '' then
            if Vendor.Get(RequisitionLine."Vendor No.") and (Vendor.Subcontractor) then
                PurchaseHeader.Subcontracting := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", 'OnAfterInitPurchOrderLine', '', false, false)]
    local procedure InitSubcontractingPurchOrderLine(var PurchaseLine: Record "Purchase Line"; RequisitionLine: Record "Requisition Line")
    var
        Vendor: Record Vendor;
    begin
        if RequisitionLine."Prod. Order No." <> '' then
            if Vendor.Get(RequisitionLine."Vendor No.") and (Vendor.Subcontractor) then
                PurchaseLine.Subcontracting := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", 'OnAfterPurchOrderLineInsert', '', false, false)]
    local procedure UpdateSubcontractingDetail(var PurchOrderLine: Record "Purchase Line"; var RequisitionLine: Record "Requisition Line")
    var
        UpdateSubcontractDetails: Codeunit "Update Subcontract Details";
    begin
        if PurchOrderLine.Subcontracting then begin
            PurchOrderLine."Delivery Challan Date" := PurchOrderLine."Posting Date";
            UpdateSubcontractDetails.InsertSubComponentsDetails(PurchOrderLine);
            UpdateSubcontractDetails.UpdateProdOrderline(RequisitionLine, PurchOrderLine)
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', false, false)]
    local procedure OnAfterInitItemLedgEntryforSubcontractingPost(
        ItemJournalLine: Record "Item Journal Line";
        var NewItemLedgEntry: Record "Item Ledger Entry")
    begin
        NewItemLedgEntry."Subcon Order No." := ItemJournalLine."Subcon Order No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Tracking Management", 'OnIsOrderNetworkEntity', '', false, false)]
    local procedure OnIsOrderNetworkEntityofItemTracking(Type: Integer; Subtype: Integer; var IsNetworkEntity: Boolean)
    begin
        case Type of
            Database::"Sub Order Component List":
                IsNetworkEntity := true;
            Database::"Applied Delivery Challan Entry":
                IsNetworkEntity := true;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnAfterGetHandleSource', '', false, false)]
    local procedure OnAfterGetHandleSourceItemTracking(TrackingSpecification: Record "Tracking Specification"; var QtyToHandleColumnIsHidden: Boolean)
    begin
        QtyToHandleColumnIsHidden := false;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnAfterGetInvoiceSource', '', false, false)]
    local procedure OnAfterGetInvoiceSourceItemTracking(TrackingSpecification: Record "Tracking Specification"; var QtyToInvoiceColumnIsHidden: Boolean)
    begin
        QtyToInvoiceColumnIsHidden := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterSignFactor', '', false, false)]
    local procedure OnAfterSignFactorofCreateResrvEntry(ReservationEntry: Record "Reservation Entry"; var Sign: Integer)
    begin
        case ReservationEntry."Source Type" of
            Database::"Sub Order Component List":
                Sign := -1;
            Database::"Applied Delivery Challan Entry":
                Sign := -1;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Order Status Management", 'OnAfterCalculateQtyToPost', '', false, false)]
    local procedure OnAfterCalculateQtyToPostSubcon(ProdOrderComponent: Record "Prod. Order Component"; var QtyToPost: Decimal)
    begin
        if (ProdOrderComponent."Subcontracting Order No." <> '') and (ProdOrderComponent."Subcontractor Code" <> '') then
            QtyToPost := 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Use Case Event Library", 'OnAddUseCaseEventstoLibrary', '', false, false)]
    local procedure OnAddUseCaseEventstoLibraryDeliveryChallanLine()
    var
        TaxUseCaseCU: Codeunit "Use Case Event Library";
    begin
        TaxUseCaseCU.AddUseCaseEventToLibrary('OnAfterGSTBaseAmountUpdate', Database::"Delivery Challan Line", 'After Update GST Base Amount');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Delivery Challan Line", 'OnAfterValidateEvent', 'GST Base Amount', false, false)]
    local procedure HandleDeliveryChallanLineUseCase(var Rec: Record "Delivery Challan Line")
    var
        TaxCaseExecution: Codeunit "Use Case Execution";
    begin
        TaxCaseExecution.HandleEvent('OnAfterGSTBaseAmountUpdate', Rec, '', 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Delivery Challan Line", 'OnAfterValidateEvent', 'GST Group Code', false, false)]
    local procedure CalculateTaxDeliveryChallanLineGSTGroupCode(var Rec: Record "Delivery Challan Line")
    var
        TaxCaseExecution: Codeunit "Use Case Execution";
    begin
        TaxCaseExecution.HandleEvent('OnAfterGSTBaseAmountUpdate', Rec, '', 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Delivery Challan Line", 'OnAfterValidateEvent', 'HSN/SAC Code', false, false)]
    local procedure CalculateTaxDeliveryChallanHSNSACCode(var Rec: Record "Delivery Challan Line")
    var
        TaxCaseExecution: Codeunit "Use Case Execution";
    begin
        TaxCaseExecution.HandleEvent('OnAfterGSTBaseAmountUpdate', Rec, '', 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Transaction Value", 'OnBeforeTableFilterApplied', '', false, false)]
    local procedure OnBeforeTableFilterAppliedDeliveryChallanLine(var TaxRecordID: RecordID; LineNoFilter: Integer; DocumentNoFilter: Text)
    var
        DeliveryChallanLine: Record "Delivery Challan Line";
    begin
        DeliveryChallanLine.Reset();
        DeliveryChallanLine.SetRange("Delivery Challan No.", DocumentNoFilter);
        DeliveryChallanLine.SetRange("Line No.", LineNoFilter);
        if DeliveryChallanLine.FindFirst() then
            TaxRecordID := DeliveryChallanLine.RecordId();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Use Case Event Library", 'OnAddUseCaseEventstoLibrary', '', false, false)]
    local procedure OnAddUseCaseEventstoLibrary()
    var
        TaxUseCaseCU: Codeunit "Use Case Event Library";
    begin
        TaxUseCaseCU.AddUseCaseEventToLibrary('OnAfterGSTBaseAmountUpdate', Database::"GST Liability Line", 'After Update GST Base Amount');
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Liability Line", 'OnAfterValidateEvent', 'GST Base Amount', false, false)]
    local procedure HandleGSTLiabilityLineUseCase(var Rec: Record "GST Liability Line")
    var
        TaxCaseExecution: Codeunit "Use Case Execution";
    begin
        TaxCaseExecution.HandleEvent('OnAfterGSTBaseAmountUpdate', Rec, '', 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Liability Line", 'OnAfterValidateEvent', 'GST Group Code', false, false)]
    local procedure CalculateGSTLiabilityLineGSTGroupCode(var Rec: Record "GST Liability Line")
    var
        TaxCaseExecution: Codeunit "Use Case Execution";
    begin
        TaxCaseExecution.HandleEvent('OnAfterGSTBaseAmountUpdate', Rec, '', 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Liability Line", 'OnAfterValidateEvent', 'HSN/SAC Code', false, false)]
    local procedure CalculateGSTLiabilityLineHSNSACCode(var Rec: Record "GST Liability Line")
    var
        TaxCaseExecution: Codeunit "Use Case Execution";
    begin
        TaxCaseExecution.HandleEvent('OnAfterGSTBaseAmountUpdate', Rec, '', 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tax Transaction Value", 'OnBeforeTableFilterApplied', '', false, false)]
    local procedure OnBeforeTableFilterApplied(var TaxRecordID: RecordID; LineNoFilter: Integer; DocumentNoFilter: Text)
    var
        GSTLiabilityLine: Record "GST Liability Line";
    begin
        GSTLiabilityLine.Reset();
        GSTLiabilityLine.SetRange("Liability Document No.", DocumentNoFilter);
        GSTLiabilityLine.SetRange("Liability Document Line No.", LineNoFilter);
        if GSTLiabilityLine.FindFirst() then
            TaxRecordID := GSTLiabilityLine.RecordId();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnValidateQtyToReceiveOnAfterInitQty', '', false, false)]
    local procedure OnValidateQtyToReceiveOnAfterInitQtySubcon(
        var PurchaseLine: Record "Purchase Line";
        var xPurchaseLine: Record "Purchase Line";
        CallingFieldNo: Integer;
        var IsHandled: Boolean)
    begin
        if (PurchaseLine.Subcontracting) and
            (PurchaseLine."Prod. Order No." <> '') and
            (PurchaseLine."Prod. Order Line No." <> 0) then begin
            IsHandled := true;
            PurchaseLine.ValidateQuantity();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterCheckTrackingAndWarehouseForReceive', '', false, false)]
    local procedure OnAfterCheckTrackingAndWarehouseForReceiveSubcon(
        var PurchaseHeader: Record "Purchase Header";
        var Receive: Boolean;
        CommitIsSupressed: Boolean;
        var TempWarehouseShipmentHeader: Record "Warehouse Shipment Header";
        var TempWarehouseReceiptHeader: Record "Warehouse Receipt Header";
        var TempPurchaseLine: Record "Purchase Line")
    begin
        if PurchaseHeader.Subcontracting then
            Receive := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", 'OnInitPurchOrderLineOnAfterValidateLineDiscount', '', false, false)]
    local procedure OnInitPurchOrderLineOnAfterValidateLineDiscount(var PurchOrderLine: Record "Purchase Line"; PurchOrderHeader: Record "Purchase Header"; RequisitionLine: Record "Requisition Line")
    begin
        UpdateSubcontractingPostingDate(PurchOrderLine, PurchOrderHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PostPurch-Delete", 'OnBeforeInitDeleteHeader', '', false, false)]
    local procedure OnBeforeInitDeleteHeader(var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var ReturnShptHeader: Record "Return Shipment Header"; var PurchInvHeaderPrepmt: Record "Purch. Inv. Header"; var PurchCrMemoHdrPrepmt: Record "Purch. Cr. Memo Hdr."; var SourceCode: Code[10])
    begin
        ValidateDeliveryChallanCreatedForOrder(PurchHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PostPurch-Delete", 'OnAfterInitDeleteHeader', '', false, false)]
    local procedure OnAfterInitDeleteHeader(var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var ReturnShptHeader: Record "Return Shipment Header"; var PurchInvHeaderPrepmt: Record "Purch. Inv. Header"; var PurchCrMemoHdrPrepmt: Record "Purch. Cr. Memo Hdr.")
    begin
        RemoveSubcontractingLinkFromProdOrderLine(PurchHeader);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Delete Invoiced Purch. Orders", 'OnAfterSetPurchLineFilters', '', false, false)]
    local procedure OnAfterSetPurchLineFilters(var PurchaseLine: Record "Purchase Line")
    var
        PurchHeader: Record "Purchase Header";
    begin
        if PurchaseLine.FindFirst() then begin
            PurchHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
            if not PurchHeader.Subcontracting then
                exit;

            if GuiAllowed then
                if not Confirm(QutstandingQuantityErr, true, PurchaseLine."Document No.") then
                    Error('Order not deleted');
        end;
    end;

    local procedure ValidateDeliveryChallanCreatedForOrder(PurchHeader: Record "Purchase Header")
    var
        DeliveryChallanLine: Record "Delivery Challan Line";
        PurchaseLine: Record "Purchase Line";
    begin
        if not PurchHeader.Subcontracting then
            exit;

        PurchaseLine.LoadFields("Document Type", "Document No.");
        PurchaseLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                PurchaseLine.TestField("Quantity Received", 0);
            until PurchaseLine.Next() = 0;

        DeliveryChallanLine.LoadFields("Document No.", "Remaining Quantity");
        DeliveryChallanLine.SetRange("Document No.", PurchHeader."No.");
        DeliveryChallanLine.SetFilter("Remaining Quantity", '<>0');
        if not DeliveryChallanLine.IsEmpty() then
            Error(DeliveryChallanExistsErr, PurchHeader."No.");
    end;

    local procedure RemoveSubcontractingLinkFromProdOrderLine(PurchHeader: Record "Purchase Header")
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        if not PurchHeader.Subcontracting then
            exit;

        ProdOrderLine.SetRange("Subcontracting Order No.", PurchHeader."No.");
        ProdOrderLine.ModifyAll("Subcontractor Code", '');
        ProdOrderLine.ModifyAll("Subcontracting Order No.", '');
    end;

    local procedure UpdateSubcontractingPostingDate(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header")
    begin
        if not PurchaseHeader.Subcontracting then
            exit;

        PurchaseLine."Posting Date" := PurchaseHeader."Posting Date";
    end;
}
