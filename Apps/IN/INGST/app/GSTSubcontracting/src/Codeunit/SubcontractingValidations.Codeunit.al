// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Inventory.Ledger;
using Microsoft.Manufacturing.Document;
using Microsoft.Purchases.Document;

codeunit 18470 "Subcontracting Validations"
{
    TableNo = "Purchase Line";
    Permissions = tabledata "Item Ledger Entry" = im;

    var
        ClosedStatusErr: label 'No Transaction allowed; Status is Closed.';
        InvalidQtyErr: label 'Quantity should be less than or equal to outstanding quantity.';

    procedure UpdateSubConOrderLines(PurchaseLine: Record "Purchase Line")
    var
        SubOrderComponents: Record "Sub Order Component List";
        SubOrderCompListVend: Record "Sub Order Comp. List Vend";
    begin
        if PurchaseLine.Status = PurchaseLine.Status::Closed then
            Error(ClosedStatusErr);

        SubOrderComponents.Reset();
        SubOrderComponents.SetRange("Document No.", PurchaseLine."Document No.");
        SubOrderComponents.SetRange("Document Line No.", PurchaseLine."Line No.");
        SubOrderComponents.FindSet();
        repeat
            SubOrderComponents.Validate("Quantity To Send", (PurchaseLine."Deliver Comp. For" * SubOrderComponents."Quantity per"));

            if SubOrderComponents."Scrap %" <> 0 then
                SubOrderComponents."Quantity To Send" := SubOrderComponents."Quantity To Send" +
                  (SubOrderComponents."Quantity To Send" / 100) * SubOrderComponents."Scrap %";

            SubOrderComponents.Validate("Qty. for Rework", (SubOrderComponents."Quantity per" * PurchaseLine."Qty. to Reject (Rework)"));
            SubOrderComponents.Validate("Posting date", PurchaseLine."Posting Date");
            SubOrderComponents.Modify();
        until SubOrderComponents.Next() = 0;

        SubOrderCompListVend.Reset();
        SubOrderCompListVend.SetRange("Document No.", PurchaseLine."Document No.");
        SubOrderCompListVend.SetRange("Document Line No.", PurchaseLine."Line No.");
        SubOrderCompListVend.FindSet();
        repeat
            SubOrderCompListVend.Validate("Qty. to Consume", PurchaseLine."Qty. to Receive" * SubOrderCompListVend."Quantity per" * SubOrderCompListVend."Qty. per Unit of Measure");
            SubOrderCompListVend.Validate("Qty. to Return (C.E.)", PurchaseLine."Qty. to Reject (C.E.)" * SubOrderCompListVend."Quantity per");
            SubOrderCompListVend.Validate("Qty. To Return (V.E.)", (SubOrderCompListVend."Quantity per" * PurchaseLine."Qty. to Reject (V.E.)"));
            SubOrderCompListVend.Validate("Posting Date", PurchaseLine."Posting Date");

            if SubOrderCompListVend."Scrap %" <> 0 then begin
                SubOrderCompListVend."Qty. to Consume" += (SubOrderCompListVend."Qty. to Consume" / 100) * SubOrderCompListVend."Scrap %";
                SubOrderCompListVend."Qty. to Return (C.E.)" +=
                  (SubOrderCompListVend."Qty. to Return (C.E.)" / 100) * SubOrderCompListVend."Scrap %";
                SubOrderCompListVend."Qty. To Return (V.E.)" +=
                  (SubOrderCompListVend."Qty. To Return (V.E.)" / 100) * SubOrderCompListVend."Scrap %";
            end;

            SubOrderCompListVend.Modify();
        until SubOrderCompListVend.Next() = 0;
    end;

    procedure ValidateQuantity(PurchaseLine: Record "Purchase Line")
    begin
        if PurchaseLine.Status = PurchaseLine.Status::Closed then
            Error(ClosedStatusErr);

        if (PurchaseLine."Qty. to Receive" +
            PurchaseLine."Qty. to Reject (Rework)" +
            PurchaseLine."Qty. to Reject (V.E.)" +
            PurchaseLine."Qty. to Reject (C.E.)") >
            (PurchaseLine.Quantity -
            (PurchaseLine."Quantity Received" +
            PurchaseLine."Qty. Rejected (C.E.)" +
            PurchaseLine."Qty. Rejected (V.E.)"))
        then
            Error(InvalidQtyErr);
    end;

    procedure UpdateIssueDetails(PurchaseLine: Record "Purchase Line")
    var
        PurchLine: Record "purchase line";
        SubOrderComponents: Record "Sub Order Component List";
    begin
        PurchLine.Reset();
        PurchLine.SetRange("Document No.", PurchaseLine."Document No.");
        PurchLine.SetRange("Document Type", PurchaseLine."Document Type");
        PurchLine.SetRange("Line No.", PurchaseLine."Line No.");
        if PurchLine.FindFirst() then
            SubOrderComponents.UpdateIssueDetails(PurchLine, PurchaseLine."Deliver Comp. For", PurchaseLine."Qty. to Reject (Rework)");
    end;

    procedure SetSubconAppliestoID(ID: Code[20]; VAR PurchLine: Record "Purchase Line"; Delivery: Boolean)
    begin
        if Delivery then begin
            if PurchLine.FindSet() then
                repeat
                    if PurchLine."Applies-to ID (Delivery)" <> ID then
                        PurchLine."Applies-to ID (Delivery)" := ID
                    else
                        PurchLine."Applies-to ID (Delivery)" := '';

                    PurchLine.Modify();
                until PurchLine.Next() = 0;
        end else
            if PurchLine.FindSet() then
                repeat
                    if PurchLine."Applies-to ID (Receipt)" <> ID then
                        PurchLine."Applies-to ID (Receipt)" := ID
                    else
                        PurchLine."Applies-to ID (Receipt)" := '';

                    PurchLine.Modify();
                until PurchLine.Next() = 0;
    end;

    procedure MultipleDeliveryChallanList(PurchaseLine: Record "Purchase Line")
    var
        DeliveryChallanHeader: Record "Delivery Challan Header";
        DeliveryChallanLine: Record "Delivery Challan Line";
        DelivChallanListMult: Page "Multi. Delivery Challan List";
    begin
        DeliveryChallanHeader.Reset();
        DeliveryChallanHeader.SetRange("Vendor No.", PurchaseLine."Buy-from Vendor No.");
        if DeliveryChallanHeader.FindSet() then
            repeat
                DeliveryChallanLine.Reset();
                DeliveryChallanLine.SetRange("Delivery Challan No.", DeliveryChallanHeader."No.");
                DeliveryChallanLine.SetRange("Document No.", PurchaseLine."Document No.");
                DeliveryChallanLine.SetRange("Document Line No.", PurchaseLine."Line No.");
                if not DeliveryChallanLine.IsEmpty() then
                    DeliveryChallanHeader.Mark(true);

            until DeliveryChallanHeader.Next() = 0;

        DeliveryChallanHeader.MarkedOnly(true);
        Clear(DelivChallanListMult);
        DelivChallanListMult.SetTableView(DeliveryChallanHeader);
        DelivChallanListMult.Run();
    end;

    procedure ShowSubOrderDetailsForm(PurchLine: Record "Purchase Line")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchLine."Document Type");
        PurchaseLine.SetRange("Document No.", PurchLine."Document No.");
        PurchaseLine.SetRange("No.", PurchLine."No.");
        PurchaseLine.SetRange("Line No.", PurchLine."Line No.");
        Page.RunModal(Page::"Ord. Subcon Details Delv. List", PurchaseLine);
    end;

    procedure ShowSubOrderRcptForm(PurchLine: Record "Purchase Line")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", PurchLine."Document Type");
        PurchaseLine.SetRange("Document No.", PurchLine."Document No.");
        PurchaseLine.SetRange("No.", PurchLine."No.");
        PurchaseLine.SetRange("Line No.", PurchLine."Line No.");
        Page.RunModal(Page::"Ord. Subcon Details Rcpt.List", PurchaseLine)
    end;

    procedure GetProdOrderCompUnitCost(ProdOrderNo: Code[20]; ProdOrderLineNo: Integer; ItemNo: Code[20]): Decimal
    var
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        ProdOrderComponent.SetRange("Prod. Order No.", ProdOrderNo);
        ProdOrderComponent.SetRange("Prod. Order Line No.", ProdOrderLineNo);
        ProdOrderComponent.SetRange("Item No.", ItemNo);
        if ProdOrderComponent.FindFirst() then
            exit(ProdOrderComponent."Unit Cost");
    end;

    procedure GetTotalGSTAmount(RecID: RecordId): Decimal
    var
        GSTSetup: Record "GST Setup";
        TaxTransValue: Record "Tax Transaction Value";
        LineTotalGSTAmount: Decimal;
    begin
        if not GSTSetup.Get() then
            exit;

        TaxTransValue.Reset();
        TaxTransValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxTransValue.SetRange("Tax Record ID", RecID);
        TaxTransValue.SetRange("Value Type", TaxTransValue."Value Type"::COMPONENT);
        TaxTransValue.SetFilter(Percent, '<>%1', 0);
        if TaxTransValue.FindSet() then
            repeat
                LineTotalGSTAmount += TaxTransValue.Amount;
            until TaxTransValue.Next() = 0;

        exit(LineTotalGSTAmount);
    end;

    [EventSubscriber(ObjectType::Table, database::"Purchase Line", 'OnAfterValidateEvent', 'Qty. to Reject (Rework)', false, false)]
    local procedure OnAfterValidateQty2RejectRework(var Rec: Record "Purchase Line")
    var
        SubOrderComponents: Record "Sub Order Component List";
    begin
        UpdateSubConOrderLines(Rec);
        ValidateQuantity(Rec);
        SubOrderComponents.UpdateIssueDetails(Rec, Rec."Deliver Comp. For", Rec."Qty. to Reject (Rework)");
    end;

    [EventSubscriber(ObjectType::Table, database::"Purchase Line", 'OnAfterValidateEvent', 'Qty. Rejected (Rework)', false, false)]
    local procedure OnAfterValidateEventQtyRejectedRework(var Rec: Record "Purchase Line")
    begin
        UpdateSubConOrderLines(Rec);
        ValidateQuantity(Rec);
    end;

    [EventSubscriber(ObjectType::Table, database::"Purchase Line", 'OnAfterValidateEvent', 'Qty. to Reject (C.E.)', false, false)]
    local procedure OnAfterValidateEventQty2RejectCE(var Rec: Record "Purchase Line")
    begin
        UpdateSubConOrderLines(Rec);
        ValidateQuantity(Rec);
    end;

    [EventSubscriber(ObjectType::Table, database::"Purchase Line", 'OnAfterValidateEvent', 'Qty. to Reject (V.E.)', false, false)]
    local procedure OnAfterValidateEventQty2RejectVE(var Rec: Record "Purchase Line")
    begin
        UpdateSubConOrderLines(Rec);
        ValidateQuantity(Rec);
    end;

    [EventSubscriber(ObjectType::Table, database::"Purchase Line", 'OnAfterValidateEvent', 'Qty. Rejected (C.E.)', false, false)]
    local procedure OnAfterValidateEventQtyRejectedCE(var Rec: Record "Purchase Line")
    begin
        UpdateSubConOrderLines(Rec);
        ValidateQuantity(Rec);
    end;

    [EventSubscriber(ObjectType::Table, database::"Purchase Line", 'OnAfterValidateEvent', 'Qty. Rejected (V.E.)', false, false)]
    local procedure OnAfterValidateEventQtyRejectedVE(var Rec: Record "Purchase Line")
    begin
        UpdateSubConOrderLines(Rec);
        ValidateQuantity(Rec);
    end;

    [EventSubscriber(ObjectType::Table, database::"Purchase Line", 'OnAfterValidateEvent', 'Deliver Comp. For', false, false)]
    local procedure OnAfterValidateEventdeliverCompFor(var Rec: Record "Purchase Line")
    var
        SubOrderComponents: Record "Sub Order Component List";
    begin
        UpdateSubConOrderLines(Rec);
        SubOrderComponents.UpdateIssueDetails(Rec, Rec."Deliver Comp. For", Rec."Qty. to Reject (Rework)")
    end;

    [EventSubscriber(ObjectType::Table, database::"Purchase Line", 'OnAfterValidateEvent', 'Posting Date', false, false)]
    local procedure OnAfterValidateEventdePostingDate(var Rec: Record "Purchase Line")
    begin
        UpdateSubConOrderLines(Rec);
    end;

    [EventSubscriber(ObjectType::Table, database::"Purchase Line", 'OnAfterValidateEvent', 'Status', false, false)]
    local procedure OnAfterValidateEventdeSubconStatus(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line")
    var
        SubOrderCompListVend: Record "Sub Order Comp. List Vend";
        ProdOrder: Record "Production Order";
        SubOrderCompList: Record "Sub Order Component List";

        QtyVendorLocationErr: label 'There is still components pending at vendor location.';
        ReopenErr: label 'Reopening is not allowed Production Order %1 has already been reported as Finished.',
            Comment = '%1 = Production Order No';
    begin
        if Rec.Status = Rec.Status::Closed then begin
            Rec."Qty. to Receive" := 0;
            Rec."Qty. to Receive (Base)" := 0;
            Rec.InitQtyToInvoice();

            SubOrderCompListVend.SetCurrentKey("Document No.", "Document Line No.", "Parent Item No.");
            SubOrderCompListVend.SetRange("Document No.", Rec."Document No.");
            SubOrderCompListVend.SetRange("Document Line No.", Rec."Line No.");
            SubOrderCompListVend.SetRange("Parent Item No.", Rec."No.");
            if SubOrderCompListVend.FindSet() then
                repeat
                    SubOrderCompListVend.CalcFields("Quantity at Vendor Location");
                    if SubOrderCompListVend."Quantity at Vendor Location" <> 0 then
                        Error(QtyVendorLocationErr);

                    SubOrderCompListVend."Qty. to Receive" := 0;
                    SubOrderCompListVend."Qty. to Consume" := 0;
                    SubOrderCompListVend."Qty. to Return (C.E.)" := 0;
                    SubOrderCompListVend."Qty. To Return (V.E.)" := 0;
                    SubOrderCompListVend.Modify();
                until SubOrderCompListVend.Next() = 0;

            SubOrderCompList.SetCurrentKey("Document No.", "Document Line No.", "Parent Item No.");
            SubOrderCompList.SetRange("Document No.", Rec."Document No.");
            SubOrderCompList.SetRange("Document Line No.", Rec."Line No.");
            SubOrderCompList.SetRange("Parent Item No.", Rec."No.");
            if SubOrderCompList.FindSet() then
                repeat
                    SubOrderCompList."Quantity To Send" := 0;
                    SubOrderCompList."Qty. for Rework" := 0;
                    SubOrderCompList.Modify();
                until SubOrderCompList.Next() = 0;
        end else
            if xRec.Status = Rec.Status::Closed then
                ProdOrder.SetRange(Status, ProdOrder.Status::Released);

        ProdOrder.SetRange("No.", Rec."Prod. Order No.");

        if ProdOrder.IsEmpty() then
            Error(ReopenErr, Rec."Prod. Order No.");
    end;
}
