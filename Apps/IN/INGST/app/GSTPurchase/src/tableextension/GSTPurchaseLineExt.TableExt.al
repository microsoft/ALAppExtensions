// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Purchase;
using Microsoft.Finance.GST.Subcontracting;
using Microsoft.Manufacturing.Document;
using Microsoft.Purchases.History;


tableextension 18083 "GST Purchase Line Ext" extends "Purchase Line"
{
    fields
    {
        field(18080; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            TableRelation = "GST Group";
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                Rec."HSN/SAC Code" := '';
            end;
        }
        field(18081; "GST Group Type"; enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18082; Exempted; Boolean)
        {
            Caption = 'Exempted';
            DataClassification = CustomerContent;
        }
        field(18083; "GST Jurisdiction Type"; enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18084; "Custom Duty Amount"; Decimal)
        {
            Caption = 'Custom Duty Amount';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            begin
                UpdateAmounts();
                UpdateUnitCost();
            end;
        }
        field(18085; "GST Reverse Charge"; Boolean)
        {
            Caption = 'GST Reverse Charge';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18086; "GST Assessable Value"; Decimal)
        {
            Caption = 'GST Assessable Value';
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateAmounts();
                UpdateUnitCost();
            end;
        }
        field(18087; "Order Address Code"; Code[10])
        {
            Caption = 'Order Address Code';
            DataClassification = CustomerContent;
        }
        field(18088; "Buy-From GST Registration No"; Code[20])
        {
            Caption = 'Buy-From GST Registration No';
            DataClassification = CustomerContent;
        }
        field(18089; "GST Rounding Line"; Boolean)
        {
            Caption = 'GST Rounding Line';
            DataClassification = CustomerContent;
        }
        field(18090; "Bill to-Location(POS)"; Code[20])
        {
            Caption = 'Bill to-Location(POS)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18091; "Non-GST Line"; Boolean)
        {
            Caption = 'Non-GST Line';
            DataClassification = CustomerContent;
        }
        field(18092; "Supplementary"; Boolean)
        {
            Caption = 'Supplementary';
            DataClassification = CustomerContent;
        }
        field(18093; "Source Document Type"; Enum "GST Source Document Type")
        {
            Caption = 'Source Document Type';
            DataClassification = CustomerContent;
        }
        field(18094; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Source Document Type" = filter("Posted Invoice")) "Purch. Inv. Header"."No."
            else
            if ("Source Document Type" = filter("Posted Credit Memo")) "Purch. Cr. Memo Hdr."."No.";
        }
        field(18095; "GST Credit"; Enum "GST Credit")
        {
            Caption = 'GST Credit';
            DataClassification = CustomerContent;
        }
        field(18096; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = CustomerContent;
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
        }
        field(18113; Subcontracting; Boolean)
        {
            Caption = 'Subcontracting';
            DataClassification = CustomerContent;
        }
        field(18114; "Subcon. Order No."; Code[20])
        {
            Caption = 'Subcon. Order No.';
            DataClassification = CustomerContent;
        }
        field(18115; "Subcon. Order Line No."; Integer)
        {
            Caption = 'Subcon. Order Line No.';
            DataClassification = CustomerContent;
        }
        field(18116; SubConSend; Boolean)
        {
            Caption = 'SubConSend';
            DataClassification = CustomerContent;
        }
        field(18117; "Delivery Challan Posted"; Integer)
        {
            Caption = 'Delivery Challan Posted';
            DataClassification = CustomerContent;
        }
        field(18118; "Qty. to Reject (Rework)"; Decimal)
        {
            Caption = 'Qty. to Reject (Rework)';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
        }
        field(18119; "Qty. Rejected (Rework)"; Decimal)
        {
            Caption = 'Qty. Rejected (Rework)';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18120; SendForRework; Boolean)
        {
            Caption = 'SendForRework';
            DataClassification = CustomerContent;
        }
        field(18121; "Qty. to Reject (C.E.)"; Decimal)
        {
            Caption = 'Qty. to Reject (C.E.)';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateSubConOrderLines();
                ValidateQuantity();
            end;
        }
        field(18122; "Qty. to Reject (V.E.)"; Decimal)
        {
            Caption = 'Qty. to Reject (V.E.)';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateSubConOrderLines();
                ValidateQuantity();
            end;
        }
        field(18123; "Qty. Rejected (C.E.)"; Decimal)
        {
            Caption = 'Qty. Rejected (C.E.)';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            begin
                UpdateSubConOrderLines();
                ValidateQuantity();
            end;
        }
        field(18124; "Qty. Rejected (V.E.)"; Decimal)
        {
            Caption = 'Qty. Rejected (V.E.)';
            DecimalPlaces = 0 : 3;
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18125; "Deliver Comp. For"; Decimal)
        {
            Caption = 'Deliver Comp. For';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 3;

            trigger OnValidate()
            var
                SubOrderComponents: Record "Sub Order Component List";
            begin
                UpdateSubConOrderLines();
                SubOrderComponents.UpdateIssueDetails(Rec, "Deliver Comp. For", "Qty. to Reject (Rework)");
            end;
        }
        field(18126; SubConReceive; Boolean)
        {
            Caption = 'SubConReceive';
            DataClassification = CustomerContent;
        }
        field(18127; "Component Item No."; Code[20])
        {
            Caption = 'Component Item No.';
            DataClassification = CustomerContent;
        }
        field(18128; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                UpdateSubConOrderLines();
            end;
        }
        field(18129; Status; Enum "Subcon Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                OnValidateStatus();
            end;
        }
        field(18130; "Vendor Shipment No."; Code[20])
        {
            Caption = 'Vendor Shipment No.';
            DataClassification = CustomerContent;
        }
        field(18131; "Released Production Order"; Code[20])
        {
            Caption = 'Released Production Order';
            DataClassification = CustomerContent;
        }
        field(18132; "Applies-to ID (Delivery)"; Code[50])
        {
            Caption = 'Applies-to ID (Delivery)';
            DataClassification = CustomerContent;
        }
        field(18133; "Applies-to ID (Receipt)"; Code[50])
        {
            Caption = 'Applies-to ID (Receipt)';
            DataClassification = CustomerContent;
        }
        field(18134; "Delivery Challan Date"; Date)
        {
            Caption = 'Delivery Challan Date';
            DataClassification = CustomerContent;
        }
        field(18135; "Subcon. Receiving"; Boolean)
        {
            Caption = 'Subcon. Receiving';
            DataClassification = CustomerContent;
        }
        field(18136; FOC; Boolean)
        {
            Caption = 'FOC';
            DataClassification = CustomerContent;
        }
        field(18137; "GST Vendor Type"; Enum "GST Vendor Type")
        {
            Caption = 'GST Vendor Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    local procedure UpdateSubConOrderLines()
    var
        SubOrderCompList: Record "Sub Order Component List";
        SubOrderCompListVend: Record "Sub Order Comp. List Vend";
    begin
        if Status = Status::Closed Then
            Error(ClosedStatusErr);

        SubOrderCompList.Reset();
        SubOrderCompList.SetRange("Document No.", "Document No.");
        SubOrderCompList.SetRange("Document Line No.", "Line No.");
        if SubOrderCompList.FindSet() then
            repeat
                SubOrderCompList.Validate("Quantity To Send", ("Deliver Comp. For" * SubOrderCompList."Quantity per"));
                if SubOrderCompList."Scrap %" <> 0 Then
                    SubOrderCompList."Quantity To Send" :=
                        SubOrderCompList."Quantity To Send" + (SubOrderCompList."Quantity To Send" / 100) * SubOrderCompList."Scrap %";

                SubOrderCompList.Validate("Qty. for Rework", (SubOrderCompList."Quantity per" * "Qty. to Reject (Rework)"));
                SubOrderCompList.Validate("Posting date", "Posting Date");
                SubOrderCompList.Modify();
            until SubOrderCompList.Next() = 0;

        SubOrderCompListVend.Reset();
        SubOrderCompListVend.SetRange("Document No.", "Document No.");
        SubOrderCompListVend.SetRange("Document Line No.", "Line No.");
        if SubOrderCompListVend.FindSet() then
            repeat
                SubOrderCompListVend.Validate("Qty. to Consume", "Qty. to Receive" * SubOrderCompListVend."Quantity per" * SubOrderCompListVend."Qty. per Unit of Measure");
                SubOrderCompListVend.Validate("Qty. to Return (C.E.)", "Qty. to Reject (C.E.)" * SubOrderCompListVend."Quantity per");
                SubOrderCompListVend.Validate("Qty. To Return (V.E.)", (SubOrderCompListVend."Quantity per" * "Qty. to Reject (V.E.)"));
                SubOrderCompListVend.Validate("Posting Date", "Posting Date");
                if SubOrderCompListVend."Scrap %" <> 0 Then begin
                    SubOrderCompListVend."Qty. to Consume" += (SubOrderCompListVend."Qty. to Consume" / 100) * SubOrderCompListVend."Scrap %";
                    SubOrderCompListVend."Qty. to Return (C.E.)" +=
                      (SubOrderCompListVend."Qty. to Return (C.E.)" / 100) * SubOrderCompListVend."Scrap %";
                    SubOrderCompListVend."Qty. To Return (V.E.)" +=
                      (SubOrderCompListVend."Qty. To Return (V.E.)" / 100) * SubOrderCompListVend."Scrap %";
                end;
                SubOrderCompListVend.Modify();
            until SubOrderCompListVend.Next() = 0;
    end;

    procedure ValidateQuantity()
    begin
        if Status = Status::Closed then
            Error(ClosedStatusErr);

        if ("Qty. to Receive" + "Qty. to Reject (Rework)" +
            "Qty. to Reject (V.E.)" + "Qty. to Reject (C.E.)") >
            (Quantity - ("Quantity Received" + "Qty. Rejected (C.E.)" +
            "Qty. Rejected (V.E.)"))
        then
            Error(InvalidQtyErr);
    end;

    local procedure OnValidateStatus()
    var
        SubOrderCompListVend: Record "Sub Order Comp. List Vend";
        ProdOrder: Record "Production Order";
        SubOrderCompList: Record "Sub Order Component List";
    begin
        if Status = Status::Closed then begin
            "Qty. to Receive" := 0;
            "Qty. to Receive (Base)" := 0;

            // InitQtyToInvoice;
            SubOrderCompListVend.SetCurrentKey("Document No.", "Document Line No.", "Parent Item No.");
            SubOrderCompListVend.SetRange("Document No.", "Document No.");
            SubOrderCompListVend.SetRange("Document Line No.", "Line No.");
            SubOrderCompListVend.SetRange("Parent Item No.", "No.");
            if SubOrderCompListVend.FindSet() then
                repeat
                    SubOrderCompListVend.CalcFields("Quantity at Vendor Location");
                    if SubOrderCompListVend."Quantity at Vendor Location" <> 0 then
                        Error(CompPendingErr);

                    SubOrderCompListVend."Qty. to Receive" := 0;
                    SubOrderCompListVend."Qty. to Consume" := 0;
                    SubOrderCompListVend."Qty. to Return (C.E.)" := 0;
                    SubOrderCompListVend."Qty. To Return (V.E.)" := 0;
                    SubOrderCompListVend.Modify();
                until SubOrderCompListVend.Next() = 0;

            SubOrderCompList.SetCurrentKey("Document No.", "Document Line No.", "Parent Item No.");
            SubOrderCompList.SetRange("Document No.", "Document No.");
            SubOrderCompList.SetRange("Document Line No.", "Line No.");
            SubOrderCompList.SetRange("Parent Item No.", "No.");
            if SubOrderCompList.FindSet() then
                repeat
                    SubOrderCompList."Quantity To Send" := 0;
                    SubOrderCompList."Qty. for Rework" := 0;
                    SubOrderCompList.Modify();
                until SubOrderCompList.Next() = 0;
        end else
            if xRec.Status = Status::Closed then
                ProdOrder.SetRange(Status, ProdOrder.Status::Released);

        ProdOrder.SetRange("No.", "Prod. Order No.");
        if ProdOrder.IsEmpty() then
            Error(ProdOrdReopenErr, "Prod. Order No.");
    end;

    var
        ClosedStatusErr: Label 'No Transaction allowed; Status is Closed.';
        InvalidQtyErr: label 'Quantity should be less than or equal to outstanding quantity.';
        CompPendingErr: Label 'There is still components pending at vendor location.';
        ProdOrdReopenErr: Label 'Reopening is not allowed Production Order %1 has already been reported as Finished.',
            comment = '%1 = Production Order No';
}
