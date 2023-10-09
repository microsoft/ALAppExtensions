// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

using Microsoft.Purchases.Posting;
using Microsoft.Sales.Posting;
using Microsoft.Inventory.Transfer;
using Microsoft.Finance.GST.Sales;
using Microsoft.Inventory.Setup;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Document;

codeunit 18604 "Gate Entry Subscribers"
{
    var
        InventorySetup: Record "Inventory Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPurchRcptHeaderInsert', '', false, false)]
    local procedure AttachGateEntryOnReceiptInsert(
        var PurchRcptHeader: Record "Purch. Rcpt. Header";
        var PurchaseHeader: Record "Purchase Header";
        CommitIsSupressed: Boolean)
    begin
        AttachGateEntryOnAfterPurchRcptHdrInsert(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterReturnRcptHeaderInsert', '', false, false)]
    local procedure AttachGateEntryOnReturnReceiptInsert(
        var ReturnReceiptHeader: Record "Return Receipt Header";
        SalesHeader: Record "Sales Header";
        SuppressCommit: Boolean)
    begin
        AttachGateEntryOnAfterReturnRcptHdrInsert(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, DataBase::"Transfer Shipment Header", 'OnAfterCopyFromTransferHeader', '', false, false)]
    local procedure InsertTransferShipmentVehicleDetails(
        var TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferHeader: Record "Transfer Header")
    begin
        DoInsertShipmentVehicleDetails(TransferShipmentHeader, TransferHeader);
    end;

    [EventSubscriber(ObjectType::Table, DataBase::"Transfer Receipt Header", 'OnAfterCopyFromTransferHeader', '', false, false)]
    local procedure InsertTransferReceiptVehicleDetails(
        var TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferHeader: Record "Transfer Header")
    begin
        DoInsertReceiptVehicleDetails(TransferReceiptHeader, TransferHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeTransRcptHeaderInsert', '', false, false)]
    local procedure AttachGateEntryOnTransReceiptInsert(
        var TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferHeader: Record "Transfer Header")
    begin
        AttachGateEntryOnAfterTransferRcptHdrInsert(TransferReceiptHeader, TransferHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure ValidateGateEntryAttachmentDelete(var Rec: Record "Transfer Header")
    var
        GateEntryAttachment: Record "Gate Entry Attachment";
    begin
        GateEntryAttachment.Reset();
        GateEntryAttachment.SetRange("Source Type", GateEntryAttachment."Source Type"::"Transfer Receipt");
        GateEntryAttachment.SetRange("Entry Type", GateEntryAttachment."Entry Type"::Inward);
        GateEntryAttachment.SetRange("Source No.", Rec."No.");
        GateEntryAttachment.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gate Entry Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateNoSeriesOnAfterInsertEvent(var Rec: Record "Gate Entry Header")
    begin
        Rec."Document Date" := WorkDate();
        Rec."Document Time" := Time;
        Rec."Posting Date" := WorkDate();
        Rec."Posting Time" := Time;
        Rec."User ID" := CopyStr(UserId(), 1, MaxStrLen(Rec."User ID"));
        InventorySetup.Get();

        case Rec."Entry Type" of
            Rec."Entry Type"::Inward:
                if Rec."No." = '' then begin
                    InventorySetup.TestField("Inward Gate Entry Nos.");
                    NoSeriesMgt.InitSeries(InventorySetup."Inward Gate Entry Nos.", Rec."No. Series", Rec."Posting Date", Rec."No.", Rec."No. Series");
                end;
            Rec."Entry Type"::Outward:
                if Rec."No." = '' then begin
                    InventorySetup.TestField("Outward Gate Entry Nos.");
                    NoSeriesMgt.InitSeries(InventorySetup."Outward Gate Entry Nos.", Rec."No. Series", Rec."Posting Date", Rec."No.", Rec."No. Series");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gate Entry Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure ValidateGateEntryCommentDelete(var Rec: Record "Gate Entry Header")
    var
        GateEntryLine: Record "Gate Entry Line";
        GateEntryCommentLine: Record "Gate Entry Comment Line";
    begin
        GateEntryLine.Reset();
        GateEntryLine.SetRange("Entry Type", Rec."Entry Type");
        GateEntryLine.SetRange("Gate Entry No.", Rec."No.");
        GateEntryLine.DeleteAll();
        GateEntryCommentLine.SetRange("Gate Entry Type", Rec."Entry Type");
        GateEntryCommentLine.SetRange("No.", Rec."No.");
        GateEntryCommentLine.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"e-Invoice Json Handler", 'OnAfterGetLRNoAndLrDate', '', false, false)]
    local procedure OnAfterGetLRNoAndLrDate(SalesInvHeader: Record "Sales Invoice Header"; var TransDocNo: Text[15]; var TransDocDt: Text[10])
    begin
        GetLRNoAndLRDateForEInvoice(SalesInvHeader, TransDocNo, TransDocDt);
    end;

    local procedure GetLRNoAndLRDateForEInvoice(SalesInvHeader: Record "Sales Invoice Header"; var TransDocNo: Text[15]; var TransDocDt: Text[10])
    begin
        if not SalesInvHeader.IsEmpty() then begin
            TransDocNo := SalesInvHeader."LR/RR No.";
            TransDocDt := Format(SalesInvHeader."LR/RR Date", 0, '<Day,2>/<Month,2>/<Year4>');
        end;
    end;

    local procedure AttachGateEntryOnAfterPurchRcptHdrInsert(PurchaseHeader: Record "Purchase Header")
    var
        PostedGateEntryAttachment: Record "Posted Gate Entry Attachment";
        PostedGateEntryLine: Record "Posted Gate Entry Line";
        GateEntryAttachment: Record "Gate Entry Attachment";
    begin
        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::Order:
                begin
                    GateEntryAttachment.SetRange("Source Type", GateEntryAttachment."Source Type"::"Purchase Order");
                    GateEntryAttachment.SetRange("Source No.", PurchaseHeader."No.");
                end;
            PurchaseHeader."Document Type"::Invoice:
                GateEntryAttachment.SetRange("Purchase Invoice No.", PurchaseHeader."No.");
        end;
        if GateEntryAttachment.FindSet() then
            repeat
                PostedGateEntryAttachment.Init();
                PostedGateEntryAttachment.TransferFields(GateEntryAttachment);
                PostedGateEntryAttachment."Receipt No." := PurchaseHeader."Receiving No.";
                PostedGateEntryAttachment.Insert();
                PostedGateEntryLine.Get(GateEntryAttachment."Entry Type", GateEntryAttachment."Gate Entry No.", GateEntryAttachment."Line No.");
                PostedGateEntryLine.TestField(Status, PostedGateEntryLine.Status::Open);
                PostedGateEntryLine.Status := PostedGateEntryLine.Status::Close;
                PostedGateEntryLine.Modify();
            until GateEntryAttachment.Next() = 0;
        GateEntryAttachment.DeleteAll();
    end;

    local procedure AttachGateEntryOnAfterReturnRcptHdrInsert(SalesHeader: Record "Sales Header")
    var
        PostedGateEntryAttachment: Record "Posted Gate Entry Attachment";
        PostedGateEntryLine: Record "Posted Gate Entry Line";
        GateEntryAttachment: Record "Gate Entry Attachment";
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::"Return Order":
                begin
                    GateEntryAttachment.SetRange("Source Type", GateEntryAttachment."Source Type"::"Sales Return Order");
                    GateEntryAttachment.SetRange("Source No.", SalesHeader."No.");
                end;
            SalesHeader."Document Type"::"Credit Memo":
                GateEntryAttachment.SetRange("Sales Credit Memo No.", SalesHeader."No.");
        end;
        if GateEntryAttachment.FindSet() then
            repeat
                PostedGateEntryAttachment.Init();
                PostedGateEntryAttachment.TransferFields(GateEntryAttachment);
                PostedGateEntryAttachment."Receipt No." := SalesHeader."Return Receipt No.";
                PostedGateEntryAttachment.Insert();
                PostedGateEntryLine.Get(GateEntryAttachment."Entry Type", GateEntryAttachment."Gate Entry No.",
                  GateEntryAttachment."Line No.");
                PostedGateEntryLine.TestField(Status, PostedGateEntryLine.Status::Open);
                PostedGateEntryLine.Status := PostedGateEntryLine.Status::Close;
                PostedGateEntryLine.Modify();
            until GateEntryAttachment.Next() = 0;
        GateEntryAttachment.DeleteAll();
    end;

    local procedure DoInsertShipmentVehicleDetails(
        var TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferHeader: Record "Transfer Header")
    begin
        TransferShipmentHeader."Vehicle No." := TransferHeader."Vehicle No.";
        case TransferHeader."Vehicle Type" of
            TransferHeader."Vehicle Type"::" ":
                TransferShipmentHeader."Vehicle Type" := TransferShipmentHeader."Vehicle Type"::" ";
            TransferHeader."Vehicle Type"::ODC:
                TransferShipmentHeader."Vehicle Type" := TransferShipmentHeader."Vehicle Type"::ODC;
            TransferHeader."Vehicle Type"::Regular:
                TransferShipmentHeader."Vehicle Type" := TransferShipmentHeader."Vehicle Type"::"Regular";
        end;
    end;

    local procedure DoInsertReceiptVehicleDetails(
        var TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferHeader: Record "Transfer Header")
    begin
        case TransferHeader."Vehicle Type" of
            TransferHeader."Vehicle Type"::" ":
                TransferReceiptHeader."Vehicle Type" := TransferReceiptHeader."Vehicle Type"::" ";
            TransferHeader."Vehicle Type"::ODC:
                TransferReceiptHeader."Vehicle Type" := TransferReceiptHeader."Vehicle Type"::ODC;
            TransferHeader."Vehicle Type"::Regular:
                TransferReceiptHeader."Vehicle Type" := TransferReceiptHeader."Vehicle Type"::"Regular";
        end;
    end;

    local procedure AttachGateEntryOnAfterTransferRcptHdrInsert(
        TransferReceiptHeader: Record "Transfer Receipt Header";
        TransferHeader: Record "Transfer Header")
    var
        PostedGateEntryAttachment: Record "Posted Gate Entry Attachment";
        PostedGateEntryLine: Record "Posted Gate Entry Line";
        GateEntryAttachment: Record "Gate Entry Attachment";
    begin
        GateEntryAttachment.SetRange("Source Type", GateEntryAttachment."Source Type"::"Transfer Receipt");
        GateEntryAttachment.SetRange("Source No.", TransferHeader."No.");
        if GateEntryAttachment.FindFirst() then
            repeat
                PostedGateEntryAttachment.Init();
                PostedGateEntryAttachment.TransferFields(GateEntryAttachment);
                PostedGateEntryAttachment."Receipt No." := TransferReceiptHeader."No.";
                PostedGateEntryAttachment.Insert();
                PostedGateEntryLine.Get(GateEntryAttachment."Entry Type", GateEntryAttachment."Gate Entry No.",
                  GateEntryAttachment."Line No.");
                PostedGateEntryLine.TestField(Status, PostedGateEntryLine.Status::Open);
                PostedGateEntryLine.Status := PostedGateEntryLine.Status::Close;
                PostedGateEntryLine.Modify();
            until GateEntryAttachment.Next() = 0;
        GateEntryAttachment.DeleteAll();
    end;
}
