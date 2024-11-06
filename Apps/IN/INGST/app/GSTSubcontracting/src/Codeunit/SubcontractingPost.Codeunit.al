// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Posting;
using Microsoft.Inventory.Tracking;
using Microsoft.Manufacturing.Document;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Vendor;

codeunit 18466 "Subcontracting Post"
{
    TableNo = "Purchase Line";

    var
        SubOrderComponentList: Record "Sub Order Component List";
        ItemJnlLine: Record "Item Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        CompanyInformation: Record "Company Information";
        DeliveryChallanHeader: Record "Delivery Challan Header";
        GLEntry: Record "G/L Entry";
        SubCompRcptHeader: Record "Sub. Comp. Rcpt. Header";
        SubCompRcptLine: Record "Sub. Comp. Rcpt. Line";
        Purchline2: Record "Purchase Line";
        TypeQty: Option Consume,RejectVE,RejectCE,Receive,Rework;
        DeliveryChallanNo: Code[20];
        ReceiptNo: Code[20];
        SubconOrderNo: Code[20];
        NotEnoughInvtoryErr: Label 'Not enough inventory available at vendor location for this order';
        ReleasedPrdOrderErr: Label 'Related Production Order No. %1 stands in Finished state', comment = '%1 is Related Production Order No.';
        NothingtoSendErr: Label 'Nothing to Send';
        ConsumeComponentQst: Label 'Do you want to consume components available with Vendor?';
        PostInterupErr: Label 'The posting has been interrupted to respect the user''s decision';
        PostConfirmationQst: Label 'Do you want to Post the Receipt and Report the Consumption on the Received Material';
        SentDeliveryChallanMsg: Label 'Items sent against Delivery Challan No. = %1.', Comment = '%1 is Delivery Challan No.';
        AppliedDeliveryChallanErr:
            Label '%1 applied against delivery challan line must be equal to %2 in Document No.=%3, Document Line No.=%4, Parent Item No.=%5, Line No.=%6.',
            Comment = '%1 = Field Caption, %2 = Qyantity, %3 = Document No, %4 = Document Line No, %5 = Parent Item No, %6 = Line No';
        ReceiptDateErr: Label 'Receipt Date %1 must be greater than Delivery Date %2', Comment = '%1 = Posting Date, %2 = Posting Date of Item Ledger Entry';
        ApplyDeliveryChallanLineErr: Label 'You must apply Delivery Challan Line in Document No.=%1, Document Line No.=%2, Parent Item No.=%3, Line No.=%4..',
            Comment = '%1 = Document No., %2 = Document Line No., %3 = Parent Item No., %4 = Line No.';
        TrackingQtyMatchErr: Label 'The %1 does not match the quantity defined in item tracking.', comment = '%1 = Field Caption';
        TrackingNoMsg: Label '<>%1', Comment = '%1 = Serial or Lot No.';
        SerialNoErr: Label 'Serial Number is required for Item %1.', Comment = '%1 = Item No.';
        LotNoErr: Label 'Lot Number is required for Item %1.', Comment = '%1 = Item No.';
        SubConVendCompErr: Label 'Production Order does not exist, No %1, Production Line No %2, Line No %3',
            comment = '%1 = Production Order No, %2 = Production Order Line No, %3 = Line No';
        GSTLiabilityErr: Label 'GST liability has already been created. Date of Receipt must be greater than %1 in Delivery Challan No=%2, Line No=%3.', Comment = '%1 = Subcon Receipt Date, %2 = Challan No, %3 = Line No.';
        GSTChallanErr: Label 'You must create GST Liability for Delivery Challan No.=%1, Line No.=%2 before receiving components.', Comment = '%1 = Delivery Challan, %2 = Line No.';
        UnitCostErr: Label 'UnitCost should not be empty in %1.', Comment = '%1 = Delivery Challan Item No.';

    trigger OnRun()
    begin
        CompanyInformation.Get();
        SubconOrderNo := Rec."Document No.";
        Rec.SubConSend := true;
        InitSubconPosting(Rec);
    end;

    local procedure InitSubconPosting(var PurchaseLine: Record "Purchase Line")
    begin
        if PurchaseLine.SubConSend then
            PurchaseLine.TestField("Delivery Challan Date");

        SubOrderComponentList.SetRange("Document No.", PurchaseLine."Document No.");
        SubOrderComponentList.SetRange("Document Line No.", PurchaseLine."Line No.");
        SubOrderComponentList.SetRange("Parent Item No.", PurchaseLine."No.");
        if SubOrderComponentList.FindSet() then
            CreateDeliveryChallan(SubOrderComponentList, PurchaseLine);
        if SubOrderComponentList.FindSet() then
            repeat
                SubOrderComponentList.TestField("Job Work Return Period");
                if SubOrderComponentList."Quantity To Send" <> 0 then begin
                    FillSendCompItemJnlLineAndPost(SubOrderComponentList);
                    SubOrderComponentList."Quantity To Send" := 0;
                end;

                if SubOrderComponentList."Qty. for Rework" <> 0 then begin
                    RecieveBackCompRW(SubOrderComponentList);
                    SendAgain(SubOrderComponentList);
                    SubOrderComponentList."Qty. for Rework" := 0;
                end;

                SubOrderComponentList.Modify();
            until SubOrderComponentList.Next() = 0;

        PurchaseLine."Qty. to Reject (Rework)" := 0;
        PurchaseLine."Deliver Comp. For" := 0;
        PurchaseLine.Modify();

        Message(SentDeliveryChallanMsg, DeliveryChallanHeader."No.");
    end;

    local procedure FillSendCompItemJnlLineAndPost(SubOrderCompList: Record "Sub Order Component List")
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Record "Item Tracking Setup";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        Inbound: Boolean;
        SNRequired: Boolean;
        LotRequired: Boolean;
        SNInfoRequired: Boolean;
        LotInfoRequired: Boolean;
        CheckTrackingLine: Boolean;
        TrackingQtyHandled: Decimal;
        TrackingQtyToHandle: Decimal;
        QuantitySent: Decimal;
        IsHandled: Boolean;
    begin
        ItemJnlLine.Init();
        ItemJnlLine."Posting Date" := DeliveryChallanHeader."Challan Date";
        ItemJnlLine."Document Date" := DeliveryChallanHeader."Challan Date";
        ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Item;
        ItemJnlLine."Document No." := SubOrderCompList."Production Order No.";
        ItemJnlLine."External Document No." := DeliveryChallanNo;
        ItemJnlLine."Subcon Order No." := SubconOrderNo;
        ItemJnlLine."Order Type" := ItemJnlLine."Order Type"::Production;
        ItemJnlLine."Order No." := SubOrderCompList."Production Order No.";
        ItemJnlLine."Order Line No." := SubOrderCompList."Production Order Line No.";
        ItemJnlLine."Prod. Order Comp. Line No." := SubOrderCompList."Line No.";
        ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Transfer;
        ItemJnlLine."Item No." := SubOrderCompList."Item No.";
        ItemJnlLine.Validate("Location Code", SubOrderCompList."Company Location");
        ItemJnlLine.Validate("New Location Code", SubOrderCompList."Vendor Location");
        if SubOrderCompList."Bin Code" <> '' then
            ItemJnlLine.Validate("Bin Code", SubOrderCompList."Bin Code");
        ItemJnlLine.Description := SubOrderCompList.Description;
        ItemJnlLine."Gen. Prod. Posting Group" := SubOrderCompList."Gen. Prod. Posting Group";
        ItemJnlLine.Quantity := SubOrderCompList."Quantity To Send";
        ItemJnlLine."Unit of Measure Code" := SubOrderCompList."Unit of Measure Code";
        ItemJnlLine."Qty. per Unit of Measure" := SubOrderCompList."Quantity per";
        ItemJnlLine."Invoiced Quantity" := SubOrderCompList."Quantity To Send";
        ItemJnlLine."Unit of Measure Code" := SubOrderCompList."Unit of Measure Code";
        ItemJnlLine."Qty. per Unit of Measure" := SubOrderCompList."Qty. per Unit of Measure";
        ItemJnlLine."Quantity (Base)" := SubOrderCompList."Quantity To Send (Base)";
        ItemJnlLine."Invoiced Qty. (Base)" := SubOrderCompList."Quantity To Send (Base)";

        GetDimensionsFromPurchaseLine(ItemJnlLine, SubOrderCompList);

        if SubOrderCompList."Applies-to Entry (Sending)" <> 0 then
            ItemJnlLine."Applies-to Entry" := SubOrderCompList."Applies-to Entry (Sending)";

        Item.Get(SubOrderCompList."Item No.");
        ItemJnlLine."Variant Code" := SubOrderCompList."Variant Code";
        ItemJnlLine."Item Category Code" := Item."Item Category Code";
        ItemJnlLine."Inventory Posting Group" := Item."Inventory Posting Group";
        ItemJnlLine."Gen. Prod. Posting Group" := SubOrderCompList."Gen. Prod. Posting Group";

        if Item."Item Tracking Code" <> '' then begin
            Inbound := false;
            ItemTrackingCode.Code := Item."Item Tracking Code";
            ItemTrackingManagement.GetItemTrackingSetup(
                ItemTrackingCode,
                ItemJnlLine."Entry Type",
                Inbound,
                ItemTrackingSetup);
            SNRequired := ItemTrackingSetup."Serial No. Required";
            LotRequired := ItemTrackingSetup."Lot No. Required";
            SNInfoRequired := ItemTrackingSetup."Serial No. Info Required";
            LotInfoRequired := ItemTrackingSetup."Lot No. Info Required";

            CheckTrackingLine := (SNRequired = false) and (LotRequired = false);
            QuantitySent := 0;
            if CheckTrackingLine then
                CheckTrackingLine := GetTrackingQuantities(SubOrderCompList, 0, SubOrderCompList."Quantity To Send", QuantitySent);
        end else
            CheckTrackingLine := false;

        TrackingQtyToHandle := 0;
        TrackingQtyHandled := 0;

        if CheckTrackingLine then begin
            GetTrackingQuantities(SubOrderCompList, 1, TrackingQtyToHandle, TrackingQtyHandled);
            if ((TrackingQtyHandled + TrackingQtyToHandle) <> SubOrderCompList."Quantity To Send") or
               (TrackingQtyToHandle <> SubOrderCompList."Quantity To Send")
            then
                Error(TrackingQtyMatchErr, SubOrderCompList.FieldCaption("Quantity To Send"));
        end;

        if Item."Item Tracking Code" <> '' then
            TransferTrackingToItemJnlLine(SubOrderCompList, ItemJnlLine, SubOrderCompList."Quantity To Send", 0);

        OnBeforeSubcontCompSendPost(ItemJnlLine, DeliveryChallanHeader, SubOrderCompList, IsHandled);
        if IsHandled then
            exit;

        PostItemJnlLine(ItemJnlLine);

        OnAfterSubcontractComponentSendPost(ItemJnlLine, DeliveryChallanHeader, SubOrderCompList);
    end;

    local procedure PostItemJnlLine(ItemJnlLine: Record "Item Journal Line")
    var
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
    begin
        if ItemJnlLine."Value Entry Type" <> ItemJnlLine."Value Entry Type"::Revaluation then begin
            if not ItemJnlPostLine.RunWithCheck(ItemJnlLine) then
                ItemJnlPostLine.CheckItemTracking();
            ItemJnlPostLine.CollectTrackingSpecification(TempTrackingSpecification);
            ItemJnlPostBatch.PostWhseJnlLine(ItemJnlLine, ItemJnlLine.Quantity, ItemJnlLine."Quantity (Base)", TempTrackingSpecification);
            Clear(ItemJnlPostLine);
            Clear(ItemJnlPostBatch);
        end;
    end;

    local procedure PostSubcontractingComponentLines(
        var ProdOrderComp: Record "Prod. Order Component";
        var ProdOrder: Record "Production Order";
        var ProdOrderLine: Record "Prod. Order Line";
        var PurchLine: Record "Purchase Line")
    begin
        OnBeforePostSubcontractOrder(ProdOrderComp, ProdOrder, ProdOrderLine, PurchLine);

        PostAppliedDeliveryChallan(ProdOrderComp);
        PostSubconCompCE(ProdOrder, ProdOrderLine, ProdOrderComp, PurchLine);
        PostSubconComp(ProdOrder, ProdOrderLine, ProdOrderComp, PurchLine);
        PostScrapAtVE(ProdOrder, ProdOrderLine, ProdOrderComp, PurchLine);
        RecieveBackComp(ProdOrder, ProdOrderLine, ProdOrderComp);
        DelAppDelChallan(ProdOrder, ProdOrderLine, ProdOrderComp);

        OnAfterPostSubcontractOrder(ProdOrderComp, ProdOrder, ProdOrderLine, PurchLine);
    end;

    local procedure GetTrackingQuantitiesVend(
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        FunctionType: Option CheckTrackingExists,GetQty;
        var TrackingQtyToHandle: Decimal;
        var TrackingQtyHandled: Decimal;
        Type_: Option Consume,RejectVE,RejectCE,Receive,Rework): Boolean
    var
        TrackingSpecification: Record "Tracking Specification";
        ReservEntry: Record "Reservation Entry";
        DeliveryChallanLine: Record "Delivery Challan Line";
        AppDelChEntry: Record "Applied Delivery Challan Entry";

    begin
        DeliveryChallanLine.Get(AppliedDeliveryChallan."Applied Delivery Challan No.", AppliedDeliveryChallan."App. Delivery Challan Line No.");
        AppDelChEntry.Reset();
        AppDelChEntry.SetRange("Document No.", AppliedDeliveryChallan."Document No.");
        AppDelChEntry.SetRange("Document Line No.", AppliedDeliveryChallan."Document Line No.");
        AppDelChEntry.SetRange("Applied Delivery Challan No.", AppliedDeliveryChallan."Applied Delivery Challan No.");
        AppDelChEntry.SetRange("App. Delivery Challan Line No.", AppliedDeliveryChallan."App. Delivery Challan Line No.");
        AppDelChEntry.SetRange("Parent Item No.", AppliedDeliveryChallan."Parent Item No.");
        AppDelChEntry.SetRange("Line No.", AppliedDeliveryChallan."Line No.");
        AppDelChEntry.SetRange("Item No.", AppliedDeliveryChallan."Item No.");
        AppDelChEntry.SetRange("Type of Quantity", Type_);
        if AppDelChEntry.FindFirst() then;

        TrackingSpecification.SetCurrentKey(
            "Source ID",
            "Source Type",
            "Source Subtype",
            "Source Batch Name",
            "Source Prod. Order Line",
            "Source Ref. No.",
            "Location Code",
            "Item No.",
            "Variant Code");
        TrackingSpecification.SetRange("Source ID", '');
        TrackingSpecification.SetRange("Source Type", Database::"Applied Delivery Challan Entry");
        TrackingSpecification.SetRange("Source Batch Name", '');
        TrackingSpecification.SetRange("Source Prod. Order Line", 0);
        TrackingSpecification.SetRange("Source Ref. No.", AppDelChEntry."Entry No.");
        TrackingSpecification.SetRange("Location Code", DeliveryChallanLine."Vendor Location");
        TrackingSpecification.SetRange("Item No.", AppliedDeliveryChallan."Item No.");
        TrackingSpecification.SetRange("Variant Code", DeliveryChallanLine."Variant Code");

        ReservEntry.SetCurrentKey(
            "Source ID",
            "Source Ref. No.",
            "Source Type",
            "Source Subtype",
            "Source Batch Name",
            "Source Prod. Order Line",
            "Location Code",
            "Item No.",
            "Variant Code");
        ReservEntry.SetRange("Source ID", '');
        ReservEntry.SetRange("Source Ref. No.", AppDelChEntry."Entry No.");
        ReservEntry.SetRange("Source Type", Database::"Applied Delivery Challan Entry");
        ReservEntry.SetRange("Source Batch Name", '');
        ReservEntry.SetRange("Source Prod. Order Line", 0);
        ReservEntry.SetRange("Item No.", AppliedDeliveryChallan."Item No.");
        ReservEntry.SetRange("Location Code", DeliveryChallanLine."Vendor Location");
        ReservEntry.SetRange("Variant Code", DeliveryChallanLine."Variant Code");

        Case FunctionType of
            FunctionType::CheckTrackingExists:
                begin
                    TrackingSpecification.SetRange(Correction, false);
                    if not TrackingSpecification.Isempty() then
                        exit(true);

                    ReservEntry.SetFilter("Serial No.", TrackingNoMsg, '');
                    if not ReservEntry.Isempty() then
                        exit(true);

                    ReservEntry.SetRange("Serial No.");
                    ReservEntry.SetFilter("Lot No.", TrackingNoMsg, '');
                    if not ReservEntry.Isempty() then
                        exit(true);
                end;
            FunctionType::GetQty:
                begin
                    TrackingSpecification.CalcSums("Quantity Handled (Base)");
                    TrackingQtyHandled := TrackingSpecification."Quantity Handled (Base)";
                    if ReservEntry.FindSet() then
                        repeat
                            if (ReservEntry."Lot No." <> '') or (ReservEntry."Serial No." <> '') then
                                TrackingQtyToHandle := TrackingQtyToHandle + ReservEntry."Qty. to Handle (Base)";
                        until ReservEntry.Next() = 0;
                end;
        end;
    end;

    local procedure GetDimensionsFromAppliedDeliveryChallan(
        var ItemJournalLine: Record "Item Journal Line";
        AppliedDeliveryChallan: Record "Applied Delivery Challan")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", AppliedDeliveryChallan."Document No.");
        PurchaseLine.SetRange("Line No.", AppliedDeliveryChallan."Document Line No.");
        PurchaseLine.SetRange("No.", AppliedDeliveryChallan."Parent Item No.");
        if PurchaseLine.FindFirst() then begin
            ItemJournalLine.Validate("Dimension Set ID", PurchaseLine."Dimension Set ID");
            if ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Transfer then begin
                ItemJournalLine."New Dimension Set ID" := ItemJournalLine."Dimension Set ID";
                ItemJournalLine."New Shortcut Dimension 1 Code" := ItemJournalLine."Shortcut Dimension 1 Code";
                ItemJournalLine."New Shortcut Dimension 2 Code" := ItemJournalLine."Shortcut Dimension 2 Code";
            end
        end;
    end;

    local procedure CheckSubcontractingOrder(DocType: Enum "Purchase Document Type"; DocumentNo: Code[20]; LineNo: Integer): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if PurchaseLine.Get(DocType, DocumentNo, LineNo) then
            exit(PurchaseLine.Subcontracting);
    end;

    local procedure CheckGSTSubcon(
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        ItemJournalLine: Record "Item Journal Line";
        ItemLedgerEntry: Record "Item Ledger Entry")
    var
        Item: Record Item;
        DeliveryChallanLine: Record "Delivery Challan Line";
    begin
        CompanyInformation.Get();
        if CompanyInformation."GST Registration No." = '' then
            exit;

        if Item.Get(ItemLedgerEntry."Item No.") then
            if (Item."GST Credit" = Item."GST Credit"::Availment) and (not Item.Exempted) and (Item."GST Group Code" <> '') then begin
                DeliveryChallanLine.SetCurrentKey("Delivery Challan No.", "Line No.");
                DeliveryChallanLine.SetRange("Delivery Challan No.", AppliedDeliveryChallan."Applied Delivery Challan No.");
                DeliveryChallanLine.SetRange("Line No.", AppliedDeliveryChallan."App. Delivery Challan Line No.");
                if (ItemLedgerEntry."Posting Date" + AppliedDeliveryChallan."Job Work Return Period") > ItemJournalLine."Posting Date" then begin
                    DeliveryChallanLine.SetFilter("GST Liability Created", '<>%1', 0);
                    if DeliveryChallanLine.FindFirst() then
                        Error(GSTLiabilityErr,
                            DeliveryChallanLine."Last Date",
                            DeliveryChallanLine."Delivery Challan No.",
                            DeliveryChallanLine."Line No.");
                end else
                    if (ItemLedgerEntry."Posting Date" + AppliedDeliveryChallan."Job Work Return Period") <= ItemJournalLine."Posting Date" then
                        if DeliveryChallanLine.FindFirst() then
                            if DeliveryChallanLine."GST Liability Created" = 0 then
                                Error(GSTChallanErr,
                                    AppliedDeliveryChallan."Applied Delivery Challan No.",
                                    AppliedDeliveryChallan."App. Delivery Challan Line No.");
            end;
    end;

    procedure PostPurchOrder(PurchLine: Record "Purchase Line")
    var
        PurchHeader: Record "Purchase Header";
        PurchPost: Codeunit "Purch.-Post";
    begin
        if not Confirm(PostConfirmationQst) then
            exit;

        PurchHeader.SetRange("Document Type", PurchLine."Document Type");
        PurchHeader.SetRange("No.", PurchLine."Document No.");
        if PurchHeader.FindFirst() then begin
            PurchHeader.Validate("Vendor Shipment No.", PurchLine."Vendor Shipment No.");
            PurchHeader.Validate("Posting Date", PurchLine."Posting Date");
            PurchHeader.Validate("Document Date", PurchLine."Posting Date");
            PurchHeader.Validate(Receive, true);
            PurchHeader.Validate(Invoice, false);
            PurchHeader.Validate(SubConPostLine, PurchLine."Line No.");

            PurchPost.Run(PurchHeader);
            PurchHeader.SubConPostLine := 0;
            PurchHeader.Modify();
        end;
    end;

    procedure PostSubcon(var PurchLine: Record "Purchase Line")
    var
        ProdOrderComp: Record "Prod. Order Component";
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
    begin
        if GLEntry.FindLast() then;

        Purchline2 := PurchLine;
        PurchLine.TestField("Posting Date");
        PurchLine.TestField("Vendor Shipment No.");
        SourceCodeSetup.Get();
        CreatePostedReceipt(PurchLine);

        ProdOrder.SetRange(Status, ProdOrder.Status::Released);
        ProdOrder.SetRange("No.", PurchLine."Prod. Order No.");
        if not ProdOrder.FindFirst() then
            Error(ReleasedPrdOrderErr, PurchLine."Prod. Order No.");

        ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Released);
        ProdOrderLine.SetRange("Prod. Order No.", PurchLine."Prod. Order No.");
        ProdOrderLine.SetRange("Line No.", PurchLine."Prod. Order Line No.");
        if not ProdOrderLine.FindFirst() then
            Error(ReleasedPrdOrderErr, PurchLine."Prod. Order No.");

        ProdOrderComp.SetRange(Status, ProdOrderComp.Status::Released);
        ProdOrderComp.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
        ProdOrderComp.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
        if ProdOrderComp.FindSet() then
            repeat
                PostSubcontractingComponentLines(ProdOrderComp, ProdOrder, ProdOrderLine, PurchLine);
            until ProdOrderComp.Next() = 0;

        ReInitializeSubConQtys(PurchLine);
    end;

    procedure CreateDeliveryChallan(var SubOrderComponentList: Record "Sub Order Component List"; PurchLine: Record "Purchase Line")
    var
        DeliveryChallanLine: Record "Delivery Challan Line";
        Item: Record Item;
        Vendor: Record Vendor;
        SubOrderCompListCheck: Record "Sub Order Component List";
        PurchaseHeader: Record "Purchase Header";
        SubcontractingValidations: Codeunit "Subcontracting Validations";
        TotalQty: Decimal;
        NextlineNo: Integer;
        UnitCost: Decimal;
    begin
        SubOrderCompListCheck.Copy(SubOrderComponentList);
        SubOrderCompListCheck.FindSet();
        SubOrderCompListCheck.CalcSums("Quantity To Send", "Qty. for Rework");
        TotalQty := SubOrderCompListCheck."Quantity To Send" + SubOrderCompListCheck."Qty. for Rework";

        if TotalQty = 0 then
            Error(NothingtoSendErr);

        SubOrderComponentList.FindFirst();

        OnBeforeDeliveryChallanHeaderInsert(DeliveryChallanHeader, SubOrderComponentList, PurchLine);

        DeliveryChallanHeader.Init();
        DeliveryChallanHeader."No." := '';
        DeliveryChallanHeader."Prod. Order No." := SubOrderComponentList."Production Order No.";
        DeliveryChallanHeader."Prod. Order Line No." := SubOrderComponentList."Production Order Line No.";
        DeliveryChallanHeader."Item No." := SubOrderComponentList."Parent Item No.";
        Item.Get(SubOrderComponentList."Parent Item No.");
        DeliveryChallanHeader.Description := Item.Description;
        DeliveryChallanHeader."Process Description" := PurchLine.Description;
        DeliveryChallanHeader."Challan Date" := PurchLine."Delivery Challan Date";
        DeliveryChallanHeader."Sub. order No." := PurchLine."Document No.";
        DeliveryChallanHeader."Sub. Order Line No." := PurchLine."Line No.";
        DeliveryChallanHeader."Posting Date" := PurchLine."Delivery Challan Date";
        DeliveryChallanHeader."Vendor No." := PurchLine."Buy-from Vendor No.";
        DeliveryChallanHeader."Quantity for rework" := PurchLine."Qty. to Reject (Rework)";

        Vendor.Get(DeliveryChallanHeader."Vendor No.");
        DeliveryChallanHeader."Commissioner's Permission No." := Vendor."Commissioner's Permission No.";
        DeliveryChallanHeader.Insert(true);

        DeliveryChallanNo := DeliveryChallanHeader."No.";

        DeliveryChallanLine.SetRange("Delivery Challan No.", DeliveryChallanHeader."No.");
        DeliveryChallanLine.SetRange("Document No.", DeliveryChallanHeader."Sub. order No.");
        DeliveryChallanLine.SetRange("Document Line No.", DeliveryChallanHeader."Sub. Order Line No.");
        if DeliveryChallanLine.FindLast() then
            NextlineNo := DeliveryChallanLine."Line No." + 10000
        else
            NextlineNo := 10000;

        OnAfterDeliveryChallanHeaderInsert(DeliveryChallanHeader, SubOrderComponentList, PurchLine, DeliveryChallanNo, SubconOrderNo);
        repeat
            OnBeforeDeliveryChallanLineInsert(DeliveryChallanLine, DeliveryChallanNo, SubconOrderNo);

            Item.Get(SubOrderComponentList."Item No.");

            DeliveryChallanLine.Init();
            DeliveryChallanLine."Delivery Challan No." := DeliveryChallanHeader."No.";
            DeliveryChallanLine."Document No." := DeliveryChallanHeader."Sub. order No.";
            DeliveryChallanLine."Document Line No." := DeliveryChallanHeader."Sub. Order Line No.";
            DeliveryChallanLine."Posting Date" := DeliveryChallanHeader."Challan Date";
            DeliveryChallanLine."Line No." := NextlineNo;
            DeliveryChallanLine."Vendor No." := PurchLine."Buy-from Vendor No.";
            DeliveryChallanLine."Parent Item No." := SubOrderComponentList."Parent Item No.";
            DeliveryChallanLine."Item No." := SubOrderComponentList."Item No.";
            DeliveryChallanLine."Unit of Measure" := SubOrderComponentList."Unit of Measure Code";
            DeliveryChallanLine.Description := CopyStr(SubOrderComponentList.Description, 1, 30);
            DeliveryChallanLine."Scrap %" := SubOrderComponentList."Scrap %";
            DeliveryChallanLine."Variant Code" := SubOrderComponentList."Variant Code";
            DeliveryChallanLine."Quantity per" := SubOrderComponentList."Quantity per";
            DeliveryChallanLine."Company Location" := SubOrderComponentList."Company Location";
            DeliveryChallanLine."Vendor Location" := SubOrderComponentList."Vendor Location";
            DeliveryChallanLine."Production Order No." := SubOrderComponentList."Production Order No.";
            DeliveryChallanLine."Production Order Line No." := SubOrderComponentList."Production Order Line No.";
            DeliveryChallanLine."Line Type" := SubOrderComponentList."Line Type";
            DeliveryChallanLine."Gen. Prod. Posting Group" := SubOrderComponentList."Gen. Prod. Posting Group";
            DeliveryChallanLine."Total Scrap Quantity" := SubOrderComponentList."Total Scrap Quantity";
            DeliveryChallanLine.Quantity := SubOrderComponentList."Quantity To Send";
            DeliveryChallanLine."Components in Rework Qty." := SubOrderComponentList."Qty. for Rework";
            DeliveryChallanLine."Prod. BOM Quantity" := SubOrderComponentList."Prod. Order Qty.";
            DeliveryChallanLine."Process Description" := CopyStr(PurchLine.Description, 1, 30);
            DeliveryChallanLine."Prod. Order Comp. Line No." := SubOrderComponentList."Line No.";
            DeliveryChallanLine."Dimension Set ID" := SubOrderComponentList."Dimension Set ID";
            DeliveryChallanLine."Job Work Return Period" := SubOrderComponentList."Job Work Return Period";
            DeliveryChallanLine."Last Date" := DeliveryChallanLine."Posting Date" + DeliveryChallanLine."Job Work Return Period" - 1;
            DeliveryChallanLine."GST Group Code" := Item."GST Group Code";
            DeliveryChallanLine."HSN/SAC Code" := Item."HSN/SAC Code";
            DeliveryChallanLine."GST Credit" := Item."GST Credit";
            DeliveryChallanLine.Exempted := Item.Exempted;
            DeliveryChallanLine."GST Jurisdiction Type" := PurchLine."GST Jurisdiction Type";

            if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, DeliveryChallanLine."Document No.") then begin
                DeliveryChallanLine."Location State Code" := PurchaseHeader."Location State Code";
                DeliveryChallanLine."Location GST Reg. No." := PurchaseHeader."Location GST Reg. No.";
                DeliveryChallanLine."GST Vendor Type" := PurchaseHeader."GST Vendor Type";
                DeliveryChallanLine."Vendor State Code" := PurchaseHeader.State;
                DeliveryChallanLine."Vendor GST Reg. No." := PurchaseHeader."Vendor GST Reg. No.";
            end;

            UnitCost := 0;
            UnitCost := SubcontractingValidations.GetProdOrderCompUnitCost(
                DeliveryChallanLine."Production Order No.",
                DeliveryChallanLine."Production Order Line No.",
                DeliveryChallanLine."Item No.");
            if UnitCost = 0 then
                Error(UnitCostErr, DeliveryChallanLine."Item No.");

            DeliveryChallanLine.Validate("GST Base Amount", (UnitCost * DeliveryChallanLine."Quantity"));
            DeliveryChallanLine."Total GST Amount" := SubcontractingValidations.GetTotalGSTAmount(DeliveryChallanLine.RecordId);
            DeliveryChallanLine."GST Amount Remaining" := DeliveryChallanLine."Total GST Amount";

            DeliveryChallanLine.Insert(true);

            NextlineNo += 10000;
            OnAfterDeliveryChallanLineInsert(DeliveryChallanLine, DeliveryChallanNo, SubconOrderNo);
        until SubOrderComponentList.Next() = 0;
    end;

    procedure PostSubconComp(
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        Purchaseline: Record "Purchase line")
    var
        CompItem: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        SubOrderCompVend: Record "Sub Order Comp. List Vend";
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        OldReservEntry: Record "Reservation Entry";
        ItemTrackingCode: Record "Item Tracking Code";
        Item: Record Item;
        ItemTrackingSetup: Record "Item Tracking Setup";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        Inbound: Boolean;
        SNRequired: Boolean;
        LotRequired: Boolean;
        CheckTrackingLine: Boolean;
        TrackingQtyHandled: Decimal;
        TrackingQtyToHandle: Decimal;
        QuantitySent: Decimal;
        RemQtytoPost: Decimal;
        TotalQtyToPost: Decimal;
        Completed: Boolean;
        SNInfoRequired: Boolean;
        LotInfoRequired: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforePostSubconComp(ProdOrder, ProdOrderLine, ProdOrderComp, Purchaseline, IsHandled);
        if IsHandled then
            exit;

        SubOrderCompVend.SetRange("Document No.", Purchaseline."Document No.");
        SubOrderCompVend.SetRange("Production Order No.", ProdOrderComp."Prod. Order No.");
        SubOrderCompVend.SetRange("Production Order Line No.", ProdOrderComp."Prod. Order Line No.");
        SubOrderCompVend.SetRange("Line No.", ProdOrderComp."Line No.");
        if SubOrderCompVend.FindFirst() then begin
            SourceCodeSetup.Get();
            CheckIfAppDelChallan(SubOrderCompVend);
            CheckAppDelChallan(SubOrderCompVend);
        end;

        CompItem.Get(ProdOrderComp."Item No.");
        CompItem.TestField("Rounding Precision");

        AppliedDeliveryChallan.SetRange("Document No.", SubOrderCompVend."Document No.");
        AppliedDeliveryChallan.SetRange("Document Line No.", SubOrderCompVend."Document Line No.");
        AppliedDeliveryChallan.SetRange("Parent Item No.", SubOrderCompVend."Parent Item No.");
        AppliedDeliveryChallan.SetRange("Line No.", SubOrderCompVend."Line No.");
        AppliedDeliveryChallan.SetRange("Item No.", SubOrderCompVend."Item No.");
        if AppliedDeliveryChallan.FindSet() then
            repeat
                Completed := false;
                TotalQtyToPost := Round(AppliedDeliveryChallan."Qty. to Consume", 0.00001);
                TotalQtyToPost := Round(TotalQtyToPost, CompItem."Rounding Precision", '>');
                RemQtytoPost := TotalQtyToPost;
                CheckItemTracking(AppliedDeliveryChallan, TypeQty::Consume);

                ItemLedgerEntry.Reset();
                GetApplicationLines(ProdOrderComp, SubOrderCompVend, ItemLedgerEntry, TotalQtyToPost, AppliedDeliveryChallan);
                if ItemLedgerEntry.FindSet() then
                    repeat
                        OldReservEntry.Reset();
                        if FindReservEntryVendBef(AppliedDeliveryChallan, OldReservEntry, 0, ItemLedgerEntry, TypeQty::Consume) then
                            if RemQtytoPost <> 0 then begin
                                OnBeforePostSubcontractComponent(
                                    ItemJnlLine,
                                    AppliedDeliveryChallan,
                                    SubOrderCompVend,
                                    ProdOrderComp,
                                    ProdOrderLine,
                                    ItemLedgerEntry);

                                ItemJnlLine.Init();
                                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::Consumption);
                                ItemJnlLine.Validate("Posting Date", SubOrderCompVend."Posting Date");
                                ItemJnlLine."Order Type" := ItemJnlLine."Order Type"::Production;
                                ItemJnlLine."Order No." := ProdOrderLine."Prod. Order No.";
                                ItemJnlLine."Order Line No." := ProdOrderLine."Line No.";
                                ItemJnlLine."Document No." := ProdOrderLine."Prod. Order No.";
                                ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Item;
                                ItemJnlLine."Source No." := ProdOrderLine."Item No.";
                                ItemJnlLine."Subcon Order No." := Purchaseline."Document No.";
                                ItemJnlLine.Validate("Prod. Order Comp. Line No.", ProdOrderComp."Line No.");
                                ItemJnlLine.Validate("Item No.", ProdOrderComp."Item No.");
                                ItemJnlLine.Validate("Unit of Measure Code", ProdOrderComp."Unit of Measure Code");
                                OnAfterValidateUnitofMeasureCodeSubcontract(ItemJnlLine, ProdOrderComp);
                                ItemJnlLine."Qty. per Unit of Measure" := ProdOrderComp."Qty. per Unit of Measure";
                                ItemJnlLine.Description := ProdOrderComp.Description;
                                GetDimensionsFromAppliedDeliveryChallan(ItemJnlLine, AppliedDeliveryChallan);

                                Item.Get(ItemJnlLine."Item No.");
                                if (Item."Item Tracking Code" = '') then begin
                                    ItemJnlLine.Subcontracting := Purchaseline.Subcontracting;
                                    ItemJnlLine."Work Center No." := Purchaseline."Work Center No.";
                                end;

                                OldReservEntry.CalcSums("Qty. to Invoice (Base)");
                                if ItemLedgerEntry."Remaining Quantity" <> 0 then
                                    if (Abs(OldReservEntry."Qty. to Invoice (Base)") <> Abs(ItemLedgerEntry."Remaining Quantity")) and
                                       (Item."Item Tracking Code" <> '') then
                                        if RemQtytoPost > Abs(OldReservEntry."Qty. to Invoice (Base)") then begin
                                            RemQtytoPost -= Abs(OldReservEntry."Qty. to Invoice (Base)");
                                            ItemJnlLine.Validate(Quantity, Abs(OldReservEntry."Qty. to Invoice (Base)"));
                                        end else begin
                                            ItemJnlLine.Validate(Quantity, RemQtytoPost);
                                            Completed := true;
                                        end
                                    else
                                        if RemQtytoPost > ItemLedgerEntry."Remaining Quantity" then begin
                                            RemQtytoPost -= ItemLedgerEntry."Remaining Quantity";
                                            ItemJnlLine.Validate(Quantity, ItemLedgerEntry."Remaining Quantity");
                                        end else begin
                                            ItemJnlLine.Validate(Quantity, RemQtytoPost);
                                            Completed := true;
                                        end;

                                ItemJnlLine."Quantity (Base)" := ItemJnlLine.Quantity;
                                ItemJnlLine."Invoiced Quantity" := ItemJnlLine.Quantity;
                                ItemJnlLine."Invoiced Qty. (Base)" := ItemJnlLine.Quantity;

                                if (ItemLedgerEntry."Lot No." = '') and (ItemLedgerEntry."Serial No." = '') then
                                    ItemJnlLine.Validate("Applies-to Entry", ItemLedgerEntry."Entry No.");

                                ItemJnlLine.Validate("Unit Cost", ProdOrderComp."Unit Cost");
                                ItemJnlLine.Validate("Location Code", SubOrderCompVend."Vendor Location");
                                ItemJnlLine."External Document No." := Purchaseline."Vendor Shipment No.";
                                ItemJnlLine."Source Code" := SourceCodeSetup."Consumption Journal";
                                ItemJnlLine."Gen. Bus. Posting Group" := ProdOrder."Gen. Bus. Posting Group";
                                ItemJnlLine."Gen. Prod. Posting Group" := CompItem."Gen. Prod. Posting Group";
                                ItemJnlLine."Item Category Code" := CompItem."Item Category Code";
                                ItemJnlLine."Inventory Posting Group" := CompItem."Inventory Posting Group";

                                if ItemJnlLine."Posting Date" < ItemLedgerEntry."Posting Date" then
                                    Error(ReceiptDateErr, ItemJnlLine."Posting Date", ItemLedgerEntry."Posting Date");

                                CheckGSTSubcon(AppliedDeliveryChallan, ItemJnlLine, ItemLedgerEntry);

                                if Item."Item Tracking Code" <> '' then begin
                                    Inbound := true;
                                    ItemTrackingCode.Code := Item."Item Tracking Code";
                                    ItemTrackingManagement.GetItemTrackingSetup(
                                        ItemTrackingCode,
                                        ItemJnlLine."Entry Type",
                Inbound,
                                        ItemTrackingSetup);
                                    SNRequired := ItemTrackingSetup."Serial No. Required";
                                    LotRequired := ItemTrackingSetup."Lot No. Required";
                                    SNInfoRequired := ItemTrackingSetup."Serial No. Info Required";
                                    LotInfoRequired := ItemTrackingSetup."Lot No. Info Required";

                                    CheckTrackingLine := (SNRequired = false) and (LotRequired = false);
                                    QuantitySent := 0;

                                    if CheckTrackingLine then
                                        CheckTrackingLine := GetTrackingQuantitiesVend(
                                            AppliedDeliveryChallan,
                                            0,
                                            ItemJnlLine.Quantity,
                                            QuantitySent,
                                            TypeQty::Consume);
                                end else
                                    CheckTrackingLine := false;

                                TrackingQtyToHandle := 0;
                                TrackingQtyHandled := 0;

                                if CheckTrackingLine then begin
                                    GetTrackingQuantitiesVend(
                                        AppliedDeliveryChallan, 1, TrackingQtyToHandle, TrackingQtyHandled, TypeQty::Consume);
                                    if ((TrackingQtyHandled + TrackingQtyToHandle) <> ItemJnlLine.Quantity) or
                                       (TrackingQtyToHandle <> ItemJnlLine.Quantity)
                                    then
                                        Error(TrackingQtyMatchErr, ItemJnlLine.FieldCaption(Quantity));
                                end;

                                if Item."Item Tracking Code" <> '' then
                                    TransferTrackingToItemJnlLineV(
                                        AppliedDeliveryChallan,
                                        ItemJnlLine,
                                        ItemJnlLine.Quantity,
                                        0,
                                        ItemLedgerEntry,
                                        TypeQty::Consume);

                                ItemJnlPostLine.Run(ItemJnlLine);

                                OnAfterPostSubcontractComponent(
                                    ItemJnlLine,
                                    AppliedDeliveryChallan,
                                    SubOrderCompVend,
                                    ProdOrderComp,
                                    ProdOrderLine,
                                    ItemLedgerEntry);
                            end;
                    until (ItemLedgerEntry.Next() = 0) or Completed;

                AppliedDeliveryChallan."Qty. to Consume" := 0;
                AppliedDeliveryChallan.Modify();

            until AppliedDeliveryChallan.Next() = 0;

        SubOrderCompVend."Qty. to Consume" := 0;
        SubOrderCompVend.Modify();
    end;

    procedure RecieveBackCompRW(SubOrderCompList: Record "Sub Order Component List")
    var
        CompItem: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        CopyItemLedgerEntry: Record "Item Ledger Entry";
        SubOrderCompVend: Record "Sub Order Comp. List Vend";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        AvailableQty: Decimal;
        RemQtytoPost: Decimal;
        TotalQtyToPost: Decimal;
        Completed: Boolean;
    begin
        SubOrderCompVend.SetRange("Production Order No.", SubOrderComponentList."Production Order No.");
        SubOrderCompVend.SetRange("Production Order Line No.", SubOrderComponentList."Production Order Line No.");
        SubOrderCompVend.SetRange("Line No.", SubOrderComponentList."Line No.");
        if SubOrderCompVend.IsEmpty() then
            Error(SubConVendCompErr,
                SubOrderCompList."Production Order No.",
                SubOrderCompList."Production Order Line No.",
                SubOrderCompList."Line No.");

        SourceCodeSetup.Get();
        CompItem.Get(SubOrderComponentList."Item No.");
        CompItem.TestField("Rounding Precision");

        TotalQtyToPost := Round(SubOrderComponentList."Qty. for Rework" * SubOrderComponentList."Qty. per Unit of Measure", 0.00001);
        TotalQtyToPost := Round(TotalQtyToPost, CompItem."Rounding Precision", '>');
        RemQtytoPost := TotalQtyToPost;

        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Prod. Order Comp. Line No.", "Entry Type", "Location Code");
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
        ItemLedgerEntry.SetRange("Order No.", SubOrderComponentList."Production Order No.");
        ItemLedgerEntry.SetRange("Order Line No.", SubOrderComponentList."Production Order Line No.");
        ItemLedgerEntry.SetRange("Prod. Order Comp. Line No.", SubOrderComponentList."Line No.");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
        ItemLedgerEntry.SetRange("Location Code", SubOrderComponentList."Vendor Location");

        CopyItemLedgerEntry.Copy(ItemLedgerEntry);
        if CopyItemLedgerEntry.FindSet() then begin
            CopyItemLedgerEntry.CalcSums("Remaining Quantity");
            AvailableQty := CopyItemLedgerEntry."Remaining Quantity";
        end;

        if AvailableQty < TotalQtyToPost then
            Error(NotEnoughInvtoryErr);

        ItemLedgerEntry.FindSet();
        repeat
            ItemJnlLine.Init();
            ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Transfer;
            ItemJnlLine.Validate("Posting Date", Today());
            ItemJnlLine."Document No." := SubOrderComponentList."Production Order No.";
            ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Item;
            ItemJnlLine."Source No." := SubOrderComponentList."Item No.";
            ItemJnlLine."Order Type" := ItemJnlLine."Order Type"::Production;
            ItemJnlLine."Order No." := SubOrderComponentList."Production Order No.";
            ItemJnlLine."Order Line No." := SubOrderComponentList."Production Order Line No.";
            ItemJnlLine.Validate("Prod. Order Comp. Line No.", SubOrderComponentList."Line No.");
            ItemJnlLine.Validate("Item No.", SubOrderComponentList."Item No.");
            ItemJnlLine.Validate("Unit of Measure Code", SubOrderComponentList."Unit of Measure Code");
            ItemJnlLine.Description := SubOrderComponentList.Description;

            GetDimensionsFromPurchaseLine(ItemJnlLine, SubOrderComponentList);

            if ItemLedgerEntry."Remaining Quantity" <> 0 then begin
                if RemQtytoPost > ItemLedgerEntry."Remaining Quantity" then begin
                    RemQtytoPost -= ItemLedgerEntry."Remaining Quantity";
                    ItemJnlLine.Validate(Quantity, ItemLedgerEntry."Remaining Quantity");
                end else begin
                    ItemJnlLine.Validate(Quantity, RemQtytoPost);
                    Completed := true;
                end;

                ItemJnlLine.Validate("Applies-to Entry", ItemLedgerEntry."Entry No.");
                ItemJnlLine."Location Code" := SubOrderComponentList."Vendor Location";
                ItemJnlLine."New Location Code" := SubOrderComponentList."Company Location";
                ItemJnlLine."Variant Code" := SubOrderComponentList."Variant Code";
                ItemJnlLine."Gen. Prod. Posting Group" := CompItem."Gen. Prod. Posting Group";
                ItemJnlLine."Item Category Code" := CompItem."Item Category Code";
                ItemJnlLine."Inventory Posting Group" := CompItem."Inventory Posting Group";
                ItemJnlPostLine.Run(ItemJnlLine);
            end;
        until (ItemLedgerEntry.Next() = 0) or Completed;
    end;

    procedure PostScrapAtVE(
            ProdOrder: Record "Production Order";
            ProdOrderLine: Record "Prod. Order Line";
            ProdOrderComp: Record "Prod. Order Component";
            PurchaseLine: Record "Purchase Line")
    var
        CompItem: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        SubOrderCompVend: Record "Sub Order Comp. List Vend";
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        OldReservEntry: Record "Reservation Entry";
        ItemTrackingSetup: Record "Item Tracking Setup";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        RemQtytoPost: Decimal;
        TotalQtyToPost: Decimal;
        Completed: Boolean;
        Inbound: Boolean;
        SNRequired: Boolean;
        LotRequired: Boolean;
        SNInfoRequired: Boolean;
        LotInfoRequired: Boolean;
        CheckTrackingLine: Boolean;
        IsHandled: Boolean;
        TrackingQtyHandled: Decimal;
        TrackingQtyToHandle: Decimal;
        QuantitySent: Decimal;
    begin
        IsHandled := false;
        OnBeforePostScrapAtVE(ProdOrder, ProdOrderLine, ProdOrderComp, PurchaseLine, IsHandled);
        if IsHandled then
            exit;

        CompanyInformation.Get();
        SourceCodeSetup.Get();
        SubOrderCompVend.SetRange("Document No.", Purchline2."Document No.");
        SubOrderCompVend.SetRange("Production Order No.", ProdOrderComp."Prod. Order No.");
        SubOrderCompVend.SetRange("Production Order Line No.", ProdOrderComp."Prod. Order Line No.");
        SubOrderCompVend.SetRange("Line No.", ProdOrderComp."Line No.");
        if SubOrderCompVend.FindFirst() then begin
            CheckIfAppDelChallan(SubOrderCompVend);
            CheckAppDelChallan(SubOrderCompVend);
        end;

        CompItem.Get(ProdOrderComp."Item No.");
        CompItem.TestField("Rounding Precision");
        AppliedDeliveryChallan.Reset();
        AppliedDeliveryChallan.SetRange("Document No.", SubOrderCompVend."Document No.");
        AppliedDeliveryChallan.SetRange("Document Line No.", SubOrderCompVend."Document Line No.");
        AppliedDeliveryChallan.SetRange("Parent Item No.", SubOrderCompVend."Parent Item No.");
        AppliedDeliveryChallan.SetRange("Line No.", SubOrderCompVend."Line No.");
        AppliedDeliveryChallan.SetRange("Item No.", SubOrderCompVend."Item No.");
        if AppliedDeliveryChallan.FindSet() then
            repeat
                Completed := false;
                TotalQtyToPost := Round(AppliedDeliveryChallan."Qty. To Return (V.E.)" * SubOrderCompVend."Qty. per Unit of Measure", 0.00001);
                TotalQtyToPost := Round(TotalQtyToPost, CompItem."Rounding Precision", '>');
                RemQtytoPost := TotalQtyToPost;

                CheckItemTracking(AppliedDeliveryChallan, TypeQty::RejectVE);
                if TotalQtyToPost <> 0 then
                    GetApplicationLines(ProdOrderComp, SubOrderCompVend, ItemLedgerEntry, TotalQtyToPost, AppliedDeliveryChallan);

                if ItemLedgerEntry.FindSet() then
                    if RemQtytoPost <> 0 then
                        repeat
                            OldReservEntry.Reset();
                            if FindReservEntryVendBef(AppliedDeliveryChallan, OldReservEntry, 0, ItemLedgerEntry, TypeQty::RejectVE) then begin
                                ItemJnlLine.Init();
                                ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Negative Adjmt.";
                                ItemJnlLine.Validate("Posting Date", SubOrderCompVend."Posting Date");
                                ItemJnlLine."Document No." := SubOrderCompVend."Production Order No.";
                                ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Item;
                                ItemJnlLine."Source No." := SubOrderCompVend."Item No.";
                                ItemJnlLine."Order Type" := ItemJnlLine."Order Type"::Production;
                                ItemJnlLine."Order No." := SubOrderCompVend."Production Order No.";
                                ItemJnlLine."Order Line No." := SubOrderCompVend."Production Order Line No.";
                                ItemJnlLine."Subcon Order No." := ProdOrderLine."Subcontracting Order No.";
                                ItemJnlLine.Validate("Prod. Order Comp. Line No.", SubOrderCompVend."Line No.");
                                ItemJnlLine.Validate("Item No.", SubOrderCompVend."Item No.");
                                ItemJnlLine.Validate("Unit of Measure Code", SubOrderCompVend."Unit of Measure");
                                ItemJnlLine.Description := SubOrderCompVend.Description;
                                GetDimensionsFromAppliedDeliveryChallan(ItemJnlLine, AppliedDeliveryChallan);
                                if ItemJnlLine."Posting Date" < ItemLedgerEntry."Posting Date" then
                                    Error(ReceiptDateErr, ItemJnlLine."Posting Date", ItemLedgerEntry."Posting Date");

                                Item.Get(ItemJnlLine."Item No.");
                                if (Item."Item Tracking Code" = '') then
                                    ItemJnlLine.Subcontracting := Purchaseline.Subcontracting;

                                OldReservEntry.CalcSums("Qty. to Invoice (Base)");

                                if ItemLedgerEntry."Remaining Quantity" <> 0 then begin
                                    if (Abs(OldReservEntry."Qty. to Invoice (Base)") <> Abs(ItemLedgerEntry."Remaining Quantity")) and
                                       (Item."Item Tracking Code" <> '')
                                    then
                                        if RemQtytoPost > Abs(OldReservEntry."Qty. to Invoice (Base)") then begin
                                            RemQtytoPost -= Abs(OldReservEntry."Qty. to Invoice (Base)");
                                            ItemJnlLine.Validate(Quantity, Abs(OldReservEntry."Qty. to Invoice (Base)"));
                                        end else begin
                                            ItemJnlLine.Validate(Quantity, RemQtytoPost);
                                            Completed := true;
                                        end else
                                        if RemQtytoPost > ItemLedgerEntry."Remaining Quantity" then begin
                                            RemQtytoPost -= ItemLedgerEntry."Remaining Quantity";
                                            ItemJnlLine.Validate(Quantity, ItemLedgerEntry."Remaining Quantity");
                                        end else begin
                                            ItemJnlLine.Validate(Quantity, RemQtytoPost);
                                            Completed := true;
                                        end;

                                    if (ItemLedgerEntry."Lot No." = '') and (ItemLedgerEntry."Serial No." = '') then
                                        ItemJnlLine.Validate("Applies-to Entry", ItemLedgerEntry."Entry No.");

                                    ItemJnlLine."Location Code" := SubOrderCompVend."Vendor Location";
                                    ItemJnlLine."Variant Code" := SubOrderCompVend."Variant Code";
                                    ItemJnlLine."Gen. Prod. Posting Group" := CompItem."Gen. Prod. Posting Group";
                                    ItemJnlLine."Item Category Code" := CompItem."Item Category Code";
                                    ItemJnlLine."Inventory Posting Group" := CompItem."Inventory Posting Group";

                                    if Item."Item Tracking Code" <> '' then begin
                                        Inbound := true;
                                        ItemTrackingCode.Code := Item."Item Tracking Code";
                                        ItemTrackingManagement.GetItemTrackingSetup(
                                            ItemTrackingCode,
                                            ItemJnlLine."Entry Type",
                                        Inbound,
                                        ItemTrackingSetup);
                                        SNRequired := ItemTrackingSetup."Serial No. Required";
                                        LotRequired := ItemTrackingSetup."Lot No. Required";
                                        SNInfoRequired := ItemTrackingSetup."Serial No. Info Required";
                                        LotInfoRequired := ItemTrackingSetup."Lot No. Info Required";

                                        CheckTrackingLine := (SNRequired = false) and (LotRequired = false);
                                        QuantitySent := 0;

                                        if CheckTrackingLine then
                                            CheckTrackingLine := GetTrackingQuantitiesVend(
                                                AppliedDeliveryChallan,
                                                0,
                                                ItemJnlLine.Quantity,
                                                QuantitySent,
                                                TypeQty::RejectVE);
                                    end else
                                        CheckTrackingLine := false;

                                    TrackingQtyToHandle := 0;
                                    TrackingQtyHandled := 0;
                                    if CheckTrackingLine then begin
                                        GetTrackingQuantitiesVend(
                                            AppliedDeliveryChallan,
                                            1,
                                            TrackingQtyToHandle,
                                            TrackingQtyHandled,
                                            TypeQty::RejectVE);

                                        if ((TrackingQtyHandled + TrackingQtyToHandle) <> ItemJnlLine.Quantity) or
                                           (TrackingQtyToHandle <> ItemJnlLine.Quantity)
                                        then
                                            Error(TrackingQtyMatchErr, ItemJnlLine.FieldCaption(Quantity));
                                    end;

                                    if Item."Item Tracking Code" <> '' then
                                        TransferTrackingToItemJnlLineV(
                                            AppliedDeliveryChallan,
                                            ItemJnlLine,
                                            ItemJnlLine.Quantity,
                                            0,
                                            ItemLedgerEntry,
                                            TypeQty::RejectVE);

                                    ItemJnlPostLine.Run(ItemJnlLine);
                                end;
                            end;
                        until (ItemLedgerEntry.Next() = 0) or Completed;

                AppliedDeliveryChallan."Qty. To Return (V.E.)" := 0;
                AppliedDeliveryChallan.Modify();

            until AppliedDeliveryChallan.Next() = 0;

        SubOrderCompVend."Qty. To Return (V.E.)" := 0;
        SubOrderCompVend.Modify();
    end;

    procedure SendAgain(SubOrderCompList: Record "Sub Order Component List")
    var
        CompItem: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        RemQtytoPost: Decimal;
        TotalQtyToPost: Decimal;
        Completed: Boolean;
    begin
        SourceCodeSetup.Get();
        CompItem.Get(SubOrderCompList."Item No.");
        CompItem.TestField("Rounding Precision");
        TotalQtyToPost := Round(SubOrderComponentList."Qty. for Rework" * SubOrderComponentList."Qty. per Unit of Measure", 0.00001);
        TotalQtyToPost := Round(TotalQtyToPost, CompItem."Rounding Precision", '>');
        RemQtytoPost := TotalQtyToPost;

        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Prod. Order Comp. Line No.", "Entry Type", "Location Code");
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
        ItemLedgerEntry.SetRange("Order No.", SubOrderComponentList."Production Order No.");
        ItemLedgerEntry.SetRange("Order Line No.", SubOrderComponentList."Production Order Line No.");
        ItemLedgerEntry.SetRange("Prod. Order Comp. Line No.", SubOrderComponentList."Line No.");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
        ItemLedgerEntry.SetRange("Location Code", SubOrderComponentList."Company Location");
        ItemLedgerEntry.SetCurrentKey("Entry No.");
        ItemLedgerEntry.Ascending := true;
        if ItemLedgerEntry.FindSet() then
            repeat
                ItemJnlLine.Init();
                ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Transfer;
                ItemJnlLine.Validate("Posting Date", SubOrderComponentList."Posting date");
                ItemJnlLine."Document No." := SubOrderComponentList."Production Order No.";
                ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Item;
                ItemJnlLine."Source No." := SubOrderComponentList."Item No.";
                ItemJnlLine."Order Type" := ItemJnlLine."Order Type"::Production;
                ItemJnlLine."Order No." := SubOrderComponentList."Production Order No.";
                ItemJnlLine."Order Line No." := SubOrderComponentList."Production Order Line No.";
                ItemJnlLine."External Document No." := DeliveryChallanNo;
                ItemJnlLine.Validate("Prod. Order Comp. Line No.", SubOrderComponentList."Line No.");
                ItemJnlLine.Validate("Item No.", SubOrderComponentList."Item No.");
                ItemJnlLine.Validate("Unit of Measure Code", SubOrderComponentList."Unit of Measure Code");
                ItemJnlLine.Description := SubOrderComponentList.Description;

                GetDimensionsFromPurchaseLine(ItemJnlLine, SubOrderComponentList);

                if ItemLedgerEntry."Remaining Quantity" <> 0 then begin
                    if RemQtytoPost > ItemLedgerEntry."Remaining Quantity" then begin
                        RemQtytoPost -= ItemLedgerEntry."Remaining Quantity";
                        ItemJnlLine.Validate(Quantity, ItemLedgerEntry."Remaining Quantity");
                    end else begin
                        ItemJnlLine.Validate(Quantity, RemQtytoPost);
                        Completed := true;
                    end;

                    ItemJnlLine.Validate("Applies-to Entry", ItemLedgerEntry."Entry No.");
                    ItemJnlLine."Location Code" := SubOrderComponentList."Company Location";
                    ItemJnlLine."New Location Code" := SubOrderComponentList."Vendor Location";
                    ItemJnlLine."Variant Code" := SubOrderComponentList."Variant Code";
                    ItemJnlLine."Gen. Prod. Posting Group" := CompItem."Gen. Prod. Posting Group";
                    ItemJnlLine."Item Category Code" := CompItem."Item Category Code";
                    ItemJnlLine."Inventory Posting Group" := CompItem."Inventory Posting Group";
                    ItemJnlPostLine.Run(ItemJnlLine);
                end;
            until (ItemLedgerEntry.Next() = 0) or Completed;
    end;

    procedure ReInitializeSubConQtys(var PurchLine: Record "Purchase Line")
    begin
        if PurchLine.Subcontracting then begin
            PurchLine."Qty. Rejected (Rework)" := PurchLine."Qty. Rejected (Rework)" + PurchLine."Qty. to Reject (Rework)";
            PurchLine."Qty. Rejected (C.E.)" := PurchLine."Qty. Rejected (C.E.)" + PurchLine."Qty. to Reject (C.E.)";
            PurchLine."Qty. Rejected (V.E.)" := PurchLine."Qty. Rejected (V.E.)" + PurchLine."Qty. to Reject (V.E.)";
            PurchLine."Qty. to Reject (Rework)" := 0;
            PurchLine."Qty. to Reject (C.E.)" := 0;
            PurchLine."Qty. to Reject (V.E.)" := 0;
            PurchLine."Qty. to Invoice" := 0;
            PurchLine."Qty. Invoiced (Base)" := 0;
            PurchLine.Modify();
        end;
    end;

    Procedure RecieveBackComp(
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component")
    var
        CompItem: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        CopyItemLedgerEntry: Record "Item Ledger Entry";
        SubOrderCompListVendLocal: Record "Sub Order Comp. List Vend";
        Item: Record Item;
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        ItemTrackingCode: Record "Item Tracking Code";
        OldReservEntry: Record "Reservation Entry";
        ItemTrackingSetup: Record "Item Tracking Setup";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        RemQtytoPost: Decimal;
        TotalQtyToPost: Decimal;
        Completed: Boolean;
        AvailableQty: Decimal;
        Inbound: Boolean;
        SNRequired: Boolean;
        LotRequired: Boolean;
        SNInfoRequired: Boolean;
        LotInfoRequired: Boolean;
        CheckTrackingLine: Boolean;
        TrackingQtyHandled: Decimal;
        TrackingQtyToHandle: Decimal;
        QuantitySent: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforeRecieveBackComp(ProdOrder, ProdOrderLine, ProdOrderComp, IsHandled);
        if IsHandled then
            exit;

        SubOrderCompListVendLocal.Reset();
        SubOrderCompListVendLocal.SetRange("Document No.", Purchline2."Document No.");
        SubOrderCompListVendLocal.SetRange("Production Order No.", ProdOrderComp."Prod. Order No.");
        SubOrderCompListVendLocal.SetRange("Production Order Line No.", ProdOrderComp."Prod. Order Line No.");
        SubOrderCompListVendLocal.SetRange("Line No.", ProdOrderComp."Line No.");
        if SubOrderCompListVendLocal.FindFirst() then begin
            CheckIfAppDelChallan(SubOrderCompListVendLocal);
            CheckAppDelChallan(SubOrderCompListVendLocal);
        end;

        SourceCodeSetup.Get();
        CompItem.Get(SubOrderCompListVendLocal."Item No.");
        CompItem.TestField("Rounding Precision");

        AppliedDeliveryChallan.Reset();
        AppliedDeliveryChallan.SetRange("Document No.", SubOrderCompListVendLocal."Document No.");
        AppliedDeliveryChallan.SetRange("Document Line No.", SubOrderCompListVendLocal."Document Line No.");
        AppliedDeliveryChallan.SetRange("Parent Item No.", SubOrderCompListVendLocal."Parent Item No.");
        AppliedDeliveryChallan.SetRange("Line No.", SubOrderCompListVendLocal."Line No.");
        AppliedDeliveryChallan.SetRange("Item No.", SubOrderCompListVendLocal."Item No.");
        if AppliedDeliveryChallan.FindSet() then
            repeat
                Completed := false;
                TotalQtyToPost := AppliedDeliveryChallan."Qty. to Receive";
                TotalQtyToPost := Round(TotalQtyToPost, CompItem."Rounding Precision", '>');
                RemQtytoPost := TotalQtyToPost;
                CheckItemTracking(AppliedDeliveryChallan, TypeQty::Receive);
                if TotalQtyToPost <> 0 then begin
                    if SubOrderCompListVendLocal."Applies-to Entry" = 0 then begin
                        ItemLedgerEntry.Reset();
                        ItemLedgerEntry.SetCurrentKey(
                            "Order Type",
                            "Order No.",
                            "Order Line No.",
                            "Prod. Order Comp. Line No.",
                            "Entry Type",
                            "Location Code");
                        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
                        ItemLedgerEntry.SetRange("Order No.", SubOrderCompListVendLocal."Production Order No.");
                        ItemLedgerEntry.SetRange("Order Line No.", SubOrderCompListVendLocal."Production Order Line No.");
                        ItemLedgerEntry.SetRange("Prod. Order Comp. Line No.", SubOrderCompListVendLocal."Line No.");
                        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
                        ItemLedgerEntry.SetRange("Location Code", SubOrderCompListVendLocal."Vendor Location");

                        CopyItemLedgerEntry.Copy(ItemLedgerEntry);
                        if CopyItemLedgerEntry.FindSet() then begin
                            CopyItemLedgerEntry.CalcSums("Remaining Quantity");
                            AvailableQty := CopyItemLedgerEntry."Remaining Quantity";
                        end;

                        if AvailableQty < TotalQtyToPost then
                            Error(NotEnoughInvtoryErr);
                    end else
                        ItemLedgerEntry.SetRange("Entry No.", AppliedDeliveryChallan."Applies-to Entry");

                    if ItemLedgerEntry.FindSet() then
                        repeat
                            OldReservEntry.Reset();
                            if FindReservEntryVendBef(AppliedDeliveryChallan, OldReservEntry, 0, ItemLedgerEntry, TypeQty::Receive) then begin
                                ItemJnlLine.Init();
                                ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Transfer;
                                ItemJnlLine.Validate("Posting Date", SubOrderCompListVendLocal."Posting Date");
                                ItemJnlLine."Document No." := SubOrderCompListVendLocal."Production Order No.";
                                ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Item;
                                ItemJnlLine."Source No." := SubOrderCompListVendLocal."Item No.";
                                ItemJnlLine."Order Type" := ItemJnlLine."Order Type"::Production;
                                ItemJnlLine."Order No." := SubOrderCompListVendLocal."Production Order No.";
                                ItemJnlLine."Order Line No." := SubOrderCompListVendLocal."Production Order Line No.";
                                ItemJnlLine.Validate("Prod. Order Comp. Line No.", SubOrderCompListVendLocal."Line No.");
                                ItemJnlLine.Validate("Item No.", SubOrderCompListVendLocal."Item No.");
                                ItemJnlLine.Validate("Unit of Measure Code", SubOrderCompListVendLocal."Unit of Measure");
                                ItemJnlLine.Description := SubOrderCompListVendLocal.Description;
                                GetDimensionsFromAppliedDeliveryChallan(ItemJnlLine, AppliedDeliveryChallan);
                                if ItemJnlLine."Posting Date" < ItemLedgerEntry."Posting Date" then
                                    Error(ReceiptDateErr, ItemJnlLine."Posting Date", ItemLedgerEntry."Posting Date");

                                Item.Get(ItemJnlLine."Item No.");
                                if (Item."Item Tracking Code" = '') then
                                    ItemJnlLine.Subcontracting := CheckSubcontractingOrder(Purchline2."Document Type"::Order, SubOrderCompListVendLocal."Document No.", SubOrderCompListVendLocal."Document Line No.");

                                OldReservEntry.CalcSums("Qty. to Invoice (Base)");
                                if ItemLedgerEntry."Remaining Quantity" <> 0 then begin
                                    if (Abs(OldReservEntry."Qty. to Invoice (Base)") <> Abs(ItemLedgerEntry."Remaining Quantity")) and
                                       (Item."Item Tracking Code" <> '') then
                                        if RemQtytoPost > Abs(OldReservEntry."Qty. to Invoice (Base)") then begin
                                            RemQtytoPost -= Abs(OldReservEntry."Qty. to Invoice (Base)");
                                            ItemJnlLine.Validate(Quantity, Abs(OldReservEntry."Qty. to Invoice (Base)"));
                                        end else begin
                                            ItemJnlLine.Validate(Quantity, RemQtytoPost);
                                            Completed := true;
                                        end
                                    else
                                        if RemQtytoPost > ItemLedgerEntry."Remaining Quantity" then begin
                                            RemQtytoPost -= ItemLedgerEntry."Remaining Quantity";
                                            ItemJnlLine.Validate(Quantity, ItemLedgerEntry."Remaining Quantity");
                                        end else begin
                                            ItemJnlLine.Validate(Quantity, RemQtytoPost);
                                            Completed := true;
                                        end;

                                    if (ItemLedgerEntry."Lot No." = '') and (ItemLedgerEntry."Serial No." = '') then
                                        ItemJnlLine.Validate("Applies-to Entry", ItemLedgerEntry."Entry No.");

                                    ItemJnlLine.Validate("Location Code", SubOrderCompListVendLocal."Vendor Location");
                                    ItemJnlLine.Validate("New Location Code", SubOrderCompListVendLocal."Company Location");
                                    if SubOrderCompListVendLocal."Bin Code" <> '' then
                                        ItemJnlLine.Validate("New Bin Code", SubOrderCompListVendLocal."Bin Code");
                                    ItemJnlLine."Variant Code" := SubOrderCompListVendLocal."Variant Code";
                                    ItemJnlLine."Gen. Prod. Posting Group" := CompItem."Gen. Prod. Posting Group";
                                    ItemJnlLine."Item Category Code" := CompItem."Item Category Code";
                                    ItemJnlLine."Inventory Posting Group" := CompItem."Inventory Posting Group";

                                    if Item."Item Tracking Code" <> '' then begin
                                        Inbound := true;
                                        ItemTrackingCode.Code := Item."Item Tracking Code";
                                        ItemTrackingManagement.GetItemTrackingSetup(
                                            ItemTrackingCode,
                                            ItemJnlLine."Entry Type",
                                            Inbound,
                                            ItemTrackingSetup);
                                        SNRequired := ItemTrackingSetup."Serial No. Required";
                                        LotRequired := ItemTrackingSetup."Lot No. Required";
                                        SNInfoRequired := ItemTrackingSetup."Serial No. Info Required";
                                        LotInfoRequired := ItemTrackingSetup."Lot No. Info Required";

                                        CheckTrackingLine := (SNRequired = false) and (LotRequired = false);
                                        QuantitySent := 0;

                                        if CheckTrackingLine then
                                            CheckTrackingLine := GetTrackingQuantitiesVend(
                                                AppliedDeliveryChallan,
                                                0,
                                                ItemJnlLine.Quantity,
                                                QuantitySent,
                                                TypeQty::Receive);
                                    end else
                                        CheckTrackingLine := false;

                                    TrackingQtyToHandle := 0;
                                    TrackingQtyHandled := 0;

                                    if CheckTrackingLine then begin
                                        GetTrackingQuantitiesVend(
                                            AppliedDeliveryChallan, 1, TrackingQtyToHandle, TrackingQtyHandled, TypeQty::Receive);
                                        if ((TrackingQtyHandled + TrackingQtyToHandle) <> ItemJnlLine.Quantity) or
                                           (TrackingQtyToHandle <> ItemJnlLine.Quantity)
                                        then
                                            Error(TrackingQtyMatchErr, ItemJnlLine.FieldCaption(Quantity));
                                    end;

                                    if Item."Item Tracking Code" <> '' then
                                        TransferTrackingToItemJnlLineV(
                                            AppliedDeliveryChallan,
                                            ItemJnlLine,
                                            ItemJnlLine.Quantity,
                                            0,
                                            ItemLedgerEntry,
                                            TypeQty::Receive);

                                    ItemJnlPostLine.Run(ItemJnlLine);
                                end;
                            end;
                        until (ItemLedgerEntry.Next() = 0) or Completed;
                end;

                AppliedDeliveryChallan."Qty. to Receive" := 0;
                AppliedDeliveryChallan.Modify();

            until AppliedDeliveryChallan.Next() = 0;
        SubOrderCompListVendLocal."Qty. to Receive" := 0;
        SubOrderCompListVendLocal.Modify();
    end;

    Procedure PostSubconCompCE(
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        Purchline: Record "Purchase Line")
    var
        CompItem: Record "Item";
        ItemLedgerEntry: Record "Item Ledger Entry";
        SubOrderCompVend: Record "Sub Order Comp. List Vend";
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        OldReservEntry: Record "Reservation Entry";
        ItemTrackingSetup: Record "Item Tracking Setup";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        RemQtytoPost: Decimal;
        TotalQtyToPost: Decimal;
        Completed: Boolean;
        Inbound: Boolean;
        SNRequired: Boolean;
        LotRequired: Boolean;
        SNInfoRequired: Boolean;
        LotInfoRequired: Boolean;
        CheckTrackingLine: Boolean;
        TrackingQtyHandled: Decimal;
        TrackingQtyToHandle: Decimal;
        QuantitySent: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforePostSubconCompCE(ProdOrder, ProdOrderLine, ProdOrderComp, Purchline, IsHandled);
        if IsHandled then
            exit;

        SubOrderCompVend.SetRange("Document No.", Purchline."Document No.");
        SubOrderCompVend.SetRange("Production Order No.", ProdOrderComp."Prod. Order No.");
        SubOrderCompVend.SetRange("Production Order Line No.", ProdOrderComp."Prod. Order Line No.");
        SubOrderCompVend.SetRange("Line No.", ProdOrderComp."Line No.");
        if SubOrderCompVend.FindFirst() then begin
            SourceCodeSetup.Get();
            CheckIfAppDelChallan(SubOrderCompVend);
            CheckAppDelChallan(SubOrderCompVend);
        end;

        CompItem.Get(ProdOrderComp."Item No.");
        CompItem.TestField("Rounding Precision");
        AppliedDeliveryChallan.Reset();
        AppliedDeliveryChallan.SetRange("Document No.", SubOrderCompVend."Document No.");
        AppliedDeliveryChallan.SetRange("Document Line No.", SubOrderCompVend."Document Line No.");
        AppliedDeliveryChallan.SetRange("Parent Item No.", SubOrderCompVend."Parent Item No.");
        AppliedDeliveryChallan.SetRange("Line No.", SubOrderCompVend."Line No.");
        AppliedDeliveryChallan.SetRange("Item No.", SubOrderCompVend."Item No.");
        if AppliedDeliveryChallan.FindSet() then
            repeat
                Completed := false;
                TotalQtyToPost := AppliedDeliveryChallan."Qty. to Return (C.E.)";
                TotalQtyToPost := Round(TotalQtyToPost, CompItem."Rounding Precision", '>');
                RemQtytoPost := TotalQtyToPost;

                CheckItemTracking(AppliedDeliveryChallan, TypeQty::RejectCE);
                GetApplicationLines(ProdOrderComp, SubOrderCompVend, ItemLedgerEntry, TotalQtyToPost, AppliedDeliveryChallan);
                if ItemLedgerEntry.FindSet() then
                    if RemQtytoPost <> 0 then
                        repeat
                            OldReservEntry.Reset();
                            if FindReservEntryVendBef(AppliedDeliveryChallan, OldReservEntry, 0, ItemLedgerEntry, TypeQty::RejectCE) then begin
                                ItemJnlLine.Init();
                                ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Consumption;
                                ItemJnlLine.Validate("Posting Date", SubOrderCompVend."Posting Date");
                                ItemJnlLine."Document No." := ProdOrderLine."Prod. Order No.";
                                ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Item;
                                ItemJnlLine."Source No." := ProdOrderLine."Item No.";
                                ItemJnlLine."Order Type" := ItemJnlLine."Order Type"::Production;
                                ItemJnlLine."Order No." := ProdOrderLine."Prod. Order No.";
                                ItemJnlLine."Order Line No." := ProdOrderLine."Line No.";
                                ItemJnlLine."Subcon Order No." := ProdOrderLine."Subcontracting Order No.";
                                ItemJnlLine.Validate("Prod. Order Comp. Line No.", ProdOrderComp."Line No.");
                                ItemJnlLine.Validate("Item No.", ProdOrderComp."Item No.");
                                ItemJnlLine.Validate("Unit of Measure Code", ProdOrderComp."Unit of Measure Code");
                                ItemJnlLine.Description := ProdOrderComp.Description;
                                GetDimensionsFromAppliedDeliveryChallan(ItemJnlLine, AppliedDeliveryChallan);
                                if ItemJnlLine."Posting Date" < ItemLedgerEntry."Posting Date" then
                                    Error(ReceiptDateErr, ItemJnlLine."Posting Date", ItemLedgerEntry."Posting Date");

                                Item.Get(ItemJnlLine."Item No.");
                                if (Item."Item Tracking Code" = '') then
                                    ItemJnlLine.Subcontracting := CheckSubcontractingOrder(Purchline."Document Type"::Order, Purchline."Document No.", Purchline."Line No.");

                                OldReservEntry.CalcSums("Qty. to Invoice (Base)");

                                if ItemLedgerEntry."Remaining Quantity" <> 0 then
                                    if (Abs(OldReservEntry."Qty. to Invoice (Base)") <> Abs(ItemLedgerEntry."Remaining Quantity")) and
                                       (Item."Item Tracking Code" <> '')
                                    then
                                        if RemQtytoPost > Abs(OldReservEntry."Qty. to Invoice (Base)") then begin
                                            RemQtytoPost -= Abs(OldReservEntry."Qty. to Invoice (Base)");
                                            ItemJnlLine.Validate(Quantity, Abs(OldReservEntry."Qty. to Invoice (Base)"));
                                        end else begin
                                            ItemJnlLine.Validate(Quantity, RemQtytoPost);
                                            Completed := true;
                                        end
                                    else
                                        if RemQtytoPost > ItemLedgerEntry."Remaining Quantity" then begin
                                            RemQtytoPost -= ItemLedgerEntry."Remaining Quantity";
                                            ItemJnlLine.Validate(Quantity, ItemLedgerEntry."Remaining Quantity");
                                        end else begin
                                            ItemJnlLine.Validate(Quantity, RemQtytoPost);
                                            Completed := true;
                                        end;

                                if (ItemLedgerEntry."Lot No." = '') and (ItemLedgerEntry."Serial No." = '') then
                                    ItemJnlLine.Validate("Applies-to Entry", ItemLedgerEntry."Entry No.");

                                ItemJnlLine.Validate("Unit Cost", ProdOrderComp."Unit Cost");
                                ItemJnlLine."External Document No." := Purchline."Vendor Shipment No.";
                                ItemJnlLine."Location Code" := SubOrderCompVend."Vendor Location";
                                ItemJnlLine."Source Code" := SourceCodeSetup."Consumption Journal";
                                ItemJnlLine."Gen. Bus. Posting Group" := ProdOrder."Gen. Bus. Posting Group";
                                ItemJnlLine."Gen. Prod. Posting Group" := CompItem."Gen. Prod. Posting Group";

                                if Item."Item Tracking Code" <> '' then begin
                                    Inbound := true;
                                    ItemTrackingCode.Code := Item."Item Tracking Code";
                                    ItemTrackingManagement.GetItemTrackingSetup(
                                        ItemTrackingCode,
                                        ItemJnlLine."Entry Type",
                                        Inbound,
                                        ItemTrackingSetup);
                                    SNRequired := ItemTrackingSetup."Serial No. Required";
                                    LotRequired := ItemTrackingSetup."Lot No. Required";
                                    SNInfoRequired := ItemTrackingSetup."Serial No. Info Required";
                                    LotInfoRequired := ItemTrackingSetup."Lot No. Info Required";

                                    CheckTrackingLine := (SNRequired = false) and (LotRequired = false);
                                    QuantitySent := 0;

                                    if CheckTrackingLine then
                                        CheckTrackingLine := GetTrackingQuantitiesVend(
                                            AppliedDeliveryChallan,
                                            0,
                                            ItemJnlLine.Quantity,
                                            QuantitySent,
                                            TypeQty::RejectCE);
                                end else
                                    CheckTrackingLine := false;

                                TrackingQtyToHandle := 0;
                                TrackingQtyHandled := 0;

                                if CheckTrackingLine then begin
                                    GetTrackingQuantitiesVend(
                                        AppliedDeliveryChallan,
                                        1,
                                        TrackingQtyToHandle,
                                        TrackingQtyHandled,
                                        TypeQty::RejectCE);
                                    if ((TrackingQtyHandled + TrackingQtyToHandle) <> ItemJnlLine.Quantity) or
                                       (TrackingQtyToHandle <> ItemJnlLine.Quantity)
                                    then
                                        Error(TrackingQtyMatchErr, ItemJnlLine.FieldCaption(Quantity));
                                end;

                                if Item."Item Tracking Code" <> '' then
                                    TransferTrackingToItemJnlLineV(
                                        AppliedDeliveryChallan,
                                        ItemJnlLine,
                                        ItemJnlLine.Quantity,
                                        0,
                                        ItemLedgerEntry,
                                        TypeQty::RejectCE);

                                ItemJnlPostLine.Run(ItemJnlLine);
                            end;
                        until (ItemLedgerEntry.Next() = 0) or Completed;
                AppliedDeliveryChallan."Qty. to Return (C.E.)" := 0;

                OnBeforeModifyApplyDeliveryChallan(AppliedDeliveryChallan, SubOrderCompVend);
                AppliedDeliveryChallan.Modify();
                OnAfterModifyApplyDeliveryChallan(AppliedDeliveryChallan, SubOrderCompVend);

            until AppliedDeliveryChallan.Next() = 0;

        SubOrderCompVend."Qty. to Return (C.E.)" := 0;
        SubOrderCompVend.Modify();
    end;

    procedure GetApplicationLines(
        ProdOrderComp: Record "Prod. Order Component";
        SubOrderCompVend: Record "Sub Order Comp. List Vend";
        var ItemLedgerEntry: Record "Item Ledger Entry";
        TotalQtyToPost: Decimal;
        AppDelChallan: Record "Applied Delivery Challan")
    var
        CopyItemLedgerEntry: Record "Item Ledger Entry";
        IsHandled: Boolean;
        AvailableQty: Decimal;
    begin
        IsHandled := false;
        OnBeforeGetApplicationLines(ProdOrderComp, SubOrderCompVend, ItemLedgerEntry, TotalQtyToPost, AppDelChallan, IsHandled);
        if IsHandled then
            exit;

        ItemLedgerEntry.Reset();
        if AppDelChallan."Applies-to Entry" = 0 then begin
            ItemLedgerEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Prod. Order Comp. Line No.", "Entry Type", "Location Code");
            ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
            ItemLedgerEntry.SetRange("Order No.", ProdOrderComp."Prod. Order No.");
            ItemLedgerEntry.SetRange("Order Line No.", ProdOrderComp."Prod. Order Line No.");
            ItemLedgerEntry.SetRange("Prod. Order Comp. Line No.", ProdOrderComp."Line No.");
            ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
            ItemLedgerEntry.SetRange("Location Code", SubOrderCompVend."Vendor Location");

            CopyItemLedgerEntry.Copy(ItemLedgerEntry);
            if CopyItemLedgerEntry.FindSet() then begin
                CopyItemLedgerEntry.CalcSums("Remaining Quantity");
                AvailableQty := CopyItemLedgerEntry."Remaining Quantity";
            end;

            if AvailableQty < TotalQtyToPost then begin
                AvailableQty := 0;
                TotalQtyToPost := 0;
                ItemLedgerEntry.Reset();
                ItemLedgerEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Prod. Order Comp. Line No.", "Entry Type", "Location Code");
                ItemLedgerEntry.SetRange("Item No.", ProdOrderComp."Item No.");
                ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
                ItemLedgerEntry.SetRange("Location Code", SubOrderCompVend."Vendor Location");

                CopyItemLedgerEntry.Reset();
                CopyItemLedgerEntry.Copy(ItemLedgerEntry);
                if CopyItemLedgerEntry.FindSet() then begin
                    CopyItemLedgerEntry.CalcSums("Remaining Quantity");
                    AvailableQty := CopyItemLedgerEntry."Remaining Quantity";
                end;

                if not (AvailableQty < TotalQtyToPost) then
                    if not Confirm(NotEnoughInvtoryErr + '.\' + ConsumeComponentQst) then
                        Error(PostInterupErr);
            end;
        end else begin
            ItemLedgerEntry.Reset();
            ItemLedgerEntry.SetCurrentKey("Entry Type", "Location Code", "External Document No.", "Item No.");
            ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
            ItemLedgerEntry.SetRange("Location Code", SubOrderCompVend."Vendor Location");
            ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
            ItemLedgerEntry.SetRange("Order No.", AppDelChallan."Production Order No.");
            ItemLedgerEntry.SetRange("Order Line No.", AppDelChallan."Production Order Line No.");
            ItemLedgerEntry.SetRange("External Document No.", AppDelChallan."Applied Delivery Challan No.");
            ItemLedgerEntry.SetRange("Item No.", AppDelChallan."Item No.");
        end;
    end;

    procedure CreatePostedReceipt(PurchLine: Record "Purchase Line")
    var
        PurchHeader: Record "Purchase Header";
        SubconCompListVend: Record "Sub Order Comp. List Vend";

    begin
        SubconCompListVend.Reset();
        SubconCompListVend.SetRange("Document No.", PurchLine."Document No.");
        SubconCompListVend.SetRange("Document Line No.", PurchLine."Line No.");
        SubconCompListVend.SetRange("Parent Item No.", PurchLine."No.");
        if SubconCompListVend.FindSet() then begin
            PurchHeader.Get(PurchHeader."Document Type"::Order, PurchLine."Document No.");
            //Insert Subcon Component Receipt Header
            SubCompRcptHeader.Init();
            SubCompRcptHeader."Buy-from Vendor No." := PurchHeader."Buy-from Vendor No.";
            SubCompRcptHeader."Order Date" := PurchHeader."Order Date";
            SubCompRcptHeader."Posting Date" := PurchHeader."Posting Date";
            SubCompRcptHeader."Location Code" := PurchHeader."Location Code";
            SubCompRcptHeader."Vendor Order No." := PurchHeader."Vendor Order No.";
            SubCompRcptHeader."Vendor Shipment No." := PurchLine."Vendor Shipment No.";
            SubCompRcptHeader."Gen. Bus. Posting Group" := PurchHeader."Gen. Bus. Posting Group";
            SubCompRcptHeader."Buy-from Vendor Name" := PurchHeader."Buy-from Vendor Name";
            SubCompRcptHeader."Buy-from Vendor Name 2" := PurchHeader."Buy-from Vendor Name 2";
            SubCompRcptHeader."Buy-from Address" := PurchHeader."Buy-from Address";
            SubCompRcptHeader."Buy-from Address 2" := PurchHeader."Buy-from Address 2";
            SubCompRcptHeader."Buy-from City" := PurchHeader."Buy-from City";
            SubCompRcptHeader."Buy-from Contact" := PurchHeader."Buy-from Contact";
            SubCompRcptHeader."Buy-from Post Code" := PurchHeader."Buy-from Post Code";
            SubCompRcptHeader."Buy-from County" := PurchHeader."Buy-from County";
            SubCompRcptHeader."Buy-from Country/Region Code" := PurchHeader."Buy-from Country/Region Code";
            SubCompRcptHeader."Order Address Code" := PurchHeader."Order Address Code";
            SubCompRcptHeader."Document Date" := PurchHeader."Document Date";
            SubCompRcptHeader.Area := PurchHeader.Area;
            SubCompRcptHeader."Transaction Specification" := PurchHeader."Transaction Specification";
            SubCompRcptHeader."Payment Method Code" := PurchHeader."Payment Method Code";
            SubCompRcptHeader."No. Series" := PurchHeader."No. Series";
            SubCompRcptHeader."VAT Business Posting Group" := PurchHeader."VAT Bus. Posting Group";
            SubCompRcptHeader."No." := '';
            SubCompRcptHeader."Prod. Order No." := PurchLine."Prod. Order No.";
            SubCompRcptHeader."Prod. Order Line No." := PurchLine."Prod. Order Line No.";
            SubCompRcptHeader."Subcontracting Order Line No." := PurchLine."Line No.";
            SubCompRcptHeader.Insert(true);
            repeat
                SubCompRcptLine.Init();
                SubCompRcptLine."Document No." := SubCompRcptHeader."No.";
                SubCompRcptLine."Line No." := SubconCompListVend."Line No.";
                SubCompRcptLine.Insert();
                SubCompRcptLine."Buy-from Vendor No." := PurchLine."Buy-from Vendor No.";
                SubCompRcptLine.Validate("No.", SubconCompListVend."Item No.");
                SubCompRcptLine."Location Code" := SubconCompListVend."Vendor Location";
                SubCompRcptLine.Description := SubconCompListVend.Description;
                SubCompRcptLine."Unit of Measure" := SubconCompListVend."Unit of Measure";
                SubCompRcptLine.Quantity := SubconCompListVend."Qty. to Consume";
                SubCompRcptLine."Order No." := PurchLine."Document No.";
                SubCompRcptLine."Order Line No." := PurchLine."Line No.";
                SubCompRcptLine."Prod. Order No." := PurchLine."Prod. Order No.";
                SubCompRcptLine."Sub Order Component Line No." := SubconCompListVend."Line No.";
                SubCompRcptLine."Prod. Order Line No." := PurchLine."Prod. Order Line No.";
                SubCompRcptLine.Modify();
            until SubconCompListVend.Next() = 0;
        end;
    end;

    procedure SendFromDC(SubcontractorDeliveryChallan: Record "Subcontractor Delivery Challan")
    var
        SubconDeliveryChallanLine: Record "Subcon. Delivery Challan Line";
    begin
        CreatePostedDeliveryChallan(SubcontractorDeliveryChallan);
        SubconDeliveryChallanLine.SetRange("Document No.", SubcontractorDeliveryChallan."No.");
        if SubconDeliveryChallanLine.FindSet() then
            repeat
                PostDCLine(SubconDeliveryChallanLine);
            until SubconDeliveryChallanLine.Next() = 0;

        SubconDeliveryChallanLine.FindSet();
        SubconDeliveryChallanLine.DeleteAll();
        SubcontractorDeliveryChallan.DeleteAll();
    end;

    procedure PostDCLine(SubconDeliveryChallanLine: Record "Subcon. Delivery Challan Line")
    var
        Item: Record Item;
    begin
        ItemJnlLine.Init();
        ItemJnlLine."Document No." := SubconDeliveryChallanLine."Document No.";
        ItemJnlLine."Posting Date" := Today();
        ItemJnlLine."Document Date" := Today();
        ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Item;
        ItemJnlLine."External Document No." := DeliveryChallanNo;
        ItemJnlLine."Location Code" := SubconDeliveryChallanLine."Company Location";
        ItemJnlLine."New Location Code" := SubconDeliveryChallanLine."Vendor Location";
        ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Transfer;
        ItemJnlLine."Item No." := SubconDeliveryChallanLine."Item No.";
        ItemJnlLine.Description := SubconDeliveryChallanLine.Description;
        ItemJnlLine."Gen. Prod. Posting Group" := SubconDeliveryChallanLine."Gen. Prod. Posting Group";
        ItemJnlLine."Gen. Bus. Posting Group" := SubconDeliveryChallanLine."Gen. Bus. Posting Group";
        ItemJnlLine.Quantity := SubconDeliveryChallanLine."Quantity To Send";
        ItemJnlLine."Invoiced Quantity" := SubconDeliveryChallanLine."Quantity To Send";
        ItemJnlLine."Quantity (Base)" := SubconDeliveryChallanLine."Quantity To Send";
        ItemJnlLine."Invoiced Qty. (Base)" := SubconDeliveryChallanLine."Quantity To Send";
        ItemJnlLine."Subcon Order No." := SubconDeliveryChallanLine."Document No.";
        if SubconDeliveryChallanLine."Applies-to Entry" <> 0 then
            ItemJnlLine."Applies-to Entry" := SubconDeliveryChallanLine."Applies-to Entry";
        Item.Get(SubconDeliveryChallanLine."Item No.");
        ItemJnlLine."Item Category Code" := Item."Item Category Code";
        ItemJnlLine."Inventory Posting Group" := Item."Inventory Posting Group";

        Codeunit.Run(Codeunit::"Item Jnl.-Post Line", ItemJnlLine);
    end;

    procedure CreatePostedDeliveryChallan(SubcontractorDeliveryChallan: Record "Subcontractor Delivery Challan")
    var
        SubconDeliveryChallanLine: Record "Subcon. Delivery Challan Line";
        Vendor: Record Vendor;
        DeliveryChallanLine: Record "Delivery Challan Line";
        item: Record item;

        NextlineNo: Integer;
    begin
        DeliveryChallanHeader.Init();
        DeliveryChallanHeader."No." := '';
        DeliveryChallanHeader."Process Description" := 'NA';
        DeliveryChallanHeader."Challan Date" := Today();
        DeliveryChallanHeader."Posting Date" := Today();
        DeliveryChallanHeader."Vendor No." := SubcontractorDeliveryChallan."Subcontractor No.";
        Vendor.Get(SubcontractorDeliveryChallan."Subcontractor No.");
        DeliveryChallanHeader."Commissioner's Permission No." := Vendor."Commissioner's Permission No.";
        DeliveryChallanHeader.Insert(true);

        DeliveryChallanNo := DeliveryChallanHeader."No.";
        DeliveryChallanLine.SetRange("Document No.", DeliveryChallanHeader."No.");
        if DeliveryChallanLine.Findlast() then
            NextlineNo := DeliveryChallanLine."Line No." + 10000
        else
            NextlineNo := 10000;

        SubconDeliveryChallanLine.SetRange("Document No.", SubcontractorDeliveryChallan."No.");
        if SubconDeliveryChallanLine.FindSet() then
            repeat
                Item.Get(SubconDeliveryChallanLine."Item No.");

                DeliveryChallanLine.Init();
                DeliveryChallanLine."Delivery Challan No." := DeliveryChallanHeader."No.";
                DeliveryChallanLine."Posting Date" := DeliveryChallanHeader."Challan Date";
                DeliveryChallanLine."Line No." := NextlineNo;
                DeliveryChallanLine."Vendor No." := SubconDeliveryChallanLine."Subcontractor No.";
                DeliveryChallanLine."Item No." := SubconDeliveryChallanLine."Item No.";
                DeliveryChallanLine."Unit of Measure" := SubconDeliveryChallanLine."Unit of Measure";
                DeliveryChallanLine.Description := SubconDeliveryChallanLine.Description;
                DeliveryChallanLine."Quantity per" := SubconDeliveryChallanLine."Qty. per Unit of Measure";
                DeliveryChallanLine."Company Location" := SubconDeliveryChallanLine."Company Location";
                DeliveryChallanLine."Vendor Location" := SubconDeliveryChallanLine."Vendor Location";
                DeliveryChallanLine."Gen. Prod. Posting Group" := SubconDeliveryChallanLine."Gen. Prod. Posting Group";
                DeliveryChallanLine.Quantity := SubconDeliveryChallanLine."Quantity To Send";
                DeliveryChallanLine."Process Description" := 'NA';
                DeliveryChallanLine.Insert(true);

                NextlineNo += 10000;
            until SubconDeliveryChallanLine.Next() = 0;
    end;

    procedure CheckAppDelChallan(SubOrderCompListVend2: Record "Sub Order Comp. List Vend")
    var
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
    begin
        AppliedDeliveryChallan.Reset();
        AppliedDeliveryChallan.SetRange("Document No.", SubOrderCompListVend2."Document No.");
        AppliedDeliveryChallan.SetRange("Document Line No.", SubOrderCompListVend2."Document Line No.");
        AppliedDeliveryChallan.SetRange("Parent Item No.", SubOrderCompListVend2."Parent Item No.");
        AppliedDeliveryChallan.SetRange("Line No.", SubOrderCompListVend2."Line No.");
        AppliedDeliveryChallan.SetRange("Item No.", SubOrderCompListVend2."Item No.");
        AppliedDeliveryChallan.CalcSums("Qty. to Receive", "Qty. to Consume", "Qty. to Return (C.E.)", "Qty. To Return (V.E.)");

        if AppliedDeliveryChallan."Qty. to Receive" <> SubOrderCompListVend2."Qty. to Receive" then
            Error(AppliedDeliveryChallanErr,
                AppliedDeliveryChallan.FieldCaption("Qty. to Receive"),
                SubOrderCompListVend2."Qty. to Receive",
                SubOrderCompListVend2."Document No.",
                SubOrderCompListVend2."Document Line No.",
                SubOrderCompListVend2."Parent Item No.",
                SubOrderCompListVend2."Line No.");

        if AppliedDeliveryChallan."Qty. to Consume" <> SubOrderCompListVend2."Qty. to Consume" then
            Error(AppliedDeliveryChallanErr,
                AppliedDeliveryChallan.FieldCaption("Qty. to Consume"),
                SubOrderCompListVend2."Qty. to Consume",
                SubOrderCompListVend2."Document No.",
                SubOrderCompListVend2."Document Line No.",
                SubOrderCompListVend2."Parent Item No.",
                SubOrderCompListVend2."Line No.");

        if AppliedDeliveryChallan."Qty. to Return (C.E.)" <> SubOrderCompListVend2."Qty. to Return (C.E.)" then
            Error(AppliedDeliveryChallanErr,
                AppliedDeliveryChallan.FieldCaption("Qty. to Return (C.E.)"),
                SubOrderCompListVend2."Qty. to Return (C.E.)",
                SubOrderCompListVend2."Document No.",
                SubOrderCompListVend2."Document Line No.",
                SubOrderCompListVend2."Parent Item No.",
                SubOrderCompListVend2."Line No.");

        if AppliedDeliveryChallan."Qty. To Return (V.E.)" <> SubOrderCompListVend2."Qty. To Return (V.E.)" then
            Error(AppliedDeliveryChallanErr,
                AppliedDeliveryChallan.FieldCaption("Qty. To Return (V.E.)"),
                SubOrderCompListVend2."Qty. To Return (V.E.)",
                SubOrderCompListVend2."Document No.",
                SubOrderCompListVend2."Document Line No.",
                SubOrderCompListVend2."Parent Item No.",
                SubOrderCompListVend2."Line No.");
    end;

    procedure CheckIfAppDelChallan(SubOrderCompListVend2: Record "Sub Order Comp. List Vend")
    var
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
    begin
        AppliedDeliveryChallan.Reset();
        AppliedDeliveryChallan.SetRange("Document No.", SubOrderCompListVend2."Document No.");
        AppliedDeliveryChallan.SetRange("Document Line No.", SubOrderCompListVend2."Document Line No.");
        AppliedDeliveryChallan.SetRange("Parent Item No.", SubOrderCompListVend2."Parent Item No.");
        AppliedDeliveryChallan.SetRange("Line No.", SubOrderCompListVend2."Line No.");
        AppliedDeliveryChallan.SetRange("Item No.", SubOrderCompListVend2."Item No.");

        if SubOrderCompListVend2."Qty. to Receive" <> 0 then
            if not AppliedDeliveryChallan.FindFirst() then
                Error(ApplyDeliveryChallanLineErr,
                    SubOrderCompListVend2."Document No.",
                    SubOrderCompListVend2."Document Line No.",
                    SubOrderCompListVend2."Parent Item No.",
                    SubOrderCompListVend2."Line No.");

        if SubOrderCompListVend2."Qty. to Consume" <> 0 then
            if not AppliedDeliveryChallan.FindFirst() then
                Error(ApplyDeliveryChallanLineErr,
                    SubOrderCompListVend2."Document No.",
                    SubOrderCompListVend2."Document Line No.",
                    SubOrderCompListVend2."Parent Item No.",
                    SubOrderCompListVend2."Line No.");

        if SubOrderCompListVend2."Qty. to Return (C.E.)" <> 0 then
            if not AppliedDeliveryChallan.FindFirst() then
                Error(ApplyDeliveryChallanLineErr,
                    SubOrderCompListVend2."Document No.",
                    SubOrderCompListVend2."Document Line No.",
                    SubOrderCompListVend2."Parent Item No.",
                    SubOrderCompListVend2."Line No.");

        if SubOrderCompListVend2."Qty. To Return (V.E.)" <> 0 then
            if AppliedDeliveryChallan.IsEmpty() then
                Error(ApplyDeliveryChallanLineErr,
                    SubOrderCompListVend2."Document No.",
                    SubOrderCompListVend2."Document Line No.",
                    SubOrderCompListVend2."Parent Item No.",
                    SubOrderCompListVend2."Line No.");
    end;

    procedure DelAppDelChallan(
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component")
    var
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        SubOrderCompVend2: Record "Sub Order Comp. List Vend";
        AppDelChEntry: Record "Applied Delivery Challan Entry";
        IsHandled: Boolean;
    begin
        OnBeforeDelApplyDeliveryChallan(ProdOrder, ProdOrderLine, ProdOrderComp, IsHandled);
        if IsHandled then
            exit;

        SubOrderCompVend2.Reset();
        SubOrderCompVend2.SetRange("Production Order No.", ProdOrderComp."Prod. Order No.");
        SubOrderCompVend2.SetRange("Production Order Line No.", ProdOrderComp."Prod. Order Line No.");
        SubOrderCompVend2.SetRange("Line No.", ProdOrderComp."Line No.");
        if SubOrderCompVend2.FindSet() then
            repeat
                AppliedDeliveryChallan.SetRange("Document No.", SubOrderCompVend2."Document No.");
                AppliedDeliveryChallan.SetRange("Document Line No.", SubOrderCompVend2."Document Line No.");
                AppliedDeliveryChallan.SetRange("Parent Item No.", SubOrderCompVend2."Parent Item No.");
                AppliedDeliveryChallan.SetRange("Line No.", SubOrderCompVend2."Line No.");
                AppliedDeliveryChallan.SetRange("Item No.", SubOrderCompVend2."Item No.");
                if AppliedDeliveryChallan.FindSet() then
                    repeat
                        AppDelChEntry.Reset();
                        AppDelChEntry.SetRange("Document No.", AppliedDeliveryChallan."Document No.");
                        AppDelChEntry.SetRange("Document Line No.", AppliedDeliveryChallan."Document Line No.");
                        AppDelChEntry.SetRange("Applied Delivery Challan No.", AppliedDeliveryChallan."Applied Delivery Challan No.");
                        AppDelChEntry.SetRange("App. Delivery Challan Line No.", AppliedDeliveryChallan."App. Delivery Challan Line No.");
                        AppDelChEntry.SetRange("Parent Item No.", AppliedDeliveryChallan."Parent Item No.");
                        AppDelChEntry.SetRange("Line No.", AppliedDeliveryChallan."Line No.");
                        AppDelChEntry.DeleteAll();
                    until AppliedDeliveryChallan.Next() = 0;

                AppliedDeliveryChallan.DeleteAll();
            until SubOrderCompVend2.Next() = 0;
    end;

    procedure GetTrackingQuantities(
        SubOrderCompList: Record "Sub Order Component List";
        FunctionType: Option CheckTrackingExists,GetQty;
        var TrackingQtyToHandle: Decimal;
        var TrackingQtyHandled: Decimal): Boolean
    var
        ReservEntry: Record "Reservation Entry";
        TrackingSpecification: Record "Tracking Specification";
    begin
        TrackingSpecification.SetCurrentKey(
            "Source ID",
            "Source Type",
            "Source Subtype",
            "Source Batch Name",
            "Source Prod. Order Line",
            "Source Ref. No.",
            "Location Code",
            "Item No.",
            "Variant Code");
        TrackingSpecification.SetRange("Source ID", SubOrderCompList."Production Order No.");
        TrackingSpecification.SetRange("Source Type", Database::"Sub Order Component List");
        TrackingSpecification.SetRange("Source Batch Name", '');
        TrackingSpecification.SetRange("Source Prod. Order Line", SubOrderCompList."Production Order Line No.");
        TrackingSpecification.SetRange("Source Ref. No.", SubOrderCompList."Line No.");
        TrackingSpecification.SetRange("Location Code", SubOrderCompList."Company Location");
        TrackingSpecification.SetRange("Item No.", SubOrderCompList."Item No.");
        TrackingSpecification.SetRange("Variant Code", SubOrderCompList."Variant Code");

        ReservEntry.SetCurrentKey(
          "Source ID",
          "Source Ref. No.",
          "Source Type",
          "Source Subtype",
          "Source Batch Name",
          "Source Prod. Order Line",
          "Location Code",
          "Item No.",
          "Variant Code");
        ReservEntry.SetRange("Source ID", SubOrderCompList."Production Order No.");
        ReservEntry.SetRange("Source Ref. No.", SubOrderCompList."Line No.");
        ReservEntry.SetRange("Source Type", Database::"Sub Order Component List");
        ReservEntry.SetRange("Source Batch Name", '');
        ReservEntry.SetRange("Source Prod. Order Line", SubOrderCompList."Production Order Line No.");
        ReservEntry.SetRange("Item No.", SubOrderCompList."Item No.");
        ReservEntry.SetRange("Location Code", SubOrderCompList."Company Location");
        ReservEntry.SetRange("Variant Code", SubOrderCompList."Variant Code");

        Case FunctionType of
            FunctionType::CheckTrackingExists:
                begin
                    TrackingSpecification.SetRange(Correction, false);
                    if not TrackingSpecification.Isempty() then
                        exit(true);

                    ReservEntry.SetFilter("Serial No.", TrackingNoMsg, '');
                    if not ReservEntry.Isempty() then
                        exit(true);

                    ReservEntry.SetRange("Serial No.");
                    ReservEntry.SetFilter("Lot No.", TrackingNoMsg, '');
                    if not ReservEntry.Isempty() then
                        exit(true);
                end;
            FunctionType::GetQty:
                begin
                    TrackingSpecification.CalcSums("Quantity Handled (Base)");
                    TrackingQtyHandled := TrackingSpecification."Quantity Handled (Base)";
                    if ReservEntry.FindSet() then
                        repeat
                            if (ReservEntry."Lot No." <> '') or (ReservEntry."Serial No." <> '') then
                                TrackingQtyToHandle := TrackingQtyToHandle + ReservEntry."Qty. to Handle (Base)";
                        until ReservEntry.Next() = 0;
                end;
        end;
    end;

    procedure FilterReservFor(
        var FilterReservEntry: Record "Reservation Entry";
        SubOrderComp: Record "Sub Order Component List";
        Direction: Option Outbound,Inbound)
    begin
        FilterReservEntry.SetRange("Source Type", Database::"Sub Order Component List");
        FilterReservEntry.SetRange("Source Subtype", Direction);
        FilterReservEntry.SetRange("Source ID", SubOrderComp."Production Order No.");
        FilterReservEntry.SetRange("Source Batch Name", '');
        FilterReservEntry.SetRange("Source Prod. Order Line", SubOrderComp."Production Order Line No.");
        FilterReservEntry.SetRange("Source Ref. No.", SubOrderComp."Line No.");
        FilterReservEntry.SetRange("Item No.", SubOrderComp."Item No.");
        FilterReservEntry.SetRange("Location Code", SubOrderComp."Company Location");
        FilterReservEntry.SetRange("Variant Code", SubOrderComp."Variant Code");
    end;

    procedure FindReservEntry(
        SubOrderComp: Record "Sub Order Component List";
        var ReservEntry: Record "Reservation Entry";
        Direction: Option Outbound,Inbound): Boolean
    var
        ReservEngineMgt: Codeunit "Reservation Engine Mgt.";
    begin
        ReservEngineMgt.InitFilterAndSortingLookupFor(ReservEntry, false);
        FilterReservFor(ReservEntry, SubOrderComp, Direction);
        exit(ReservEntry.Findlast());
    end;

    procedure TransferTrackingToItemJnlLine(
        var SubOrderComp: Record "Sub Order Component List";
        var ItemJnlLine: Record "Item Journal Line";
        TransferQty: Decimal;
        Direction: Option Outbound,Inbound)
    var
        OldReservEntry: Record "Reservation Entry";
        ReservEngineMgt: Codeunit "Reservation Engine Mgt.";
        CreateReservEntry: Codeunit "Create Reserv. Entry";

        TransferLocation: Code[10];
    begin
        OldReservEntry.Reset();
        if not FindReservEntry(SubOrderComp, OldReservEntry, Direction) then
            exit;

        OldReservEntry.Lock();

        Case Direction of
            Direction::Outbound:
                begin
                    TransferLocation := SubOrderComp."Company Location";
                    ItemJnlLine.TestField("Location Code", TransferLocation);
                end;

            Direction::Inbound:
                begin
                    TransferLocation := SubOrderComp."Vendor Location";
                    ItemJnlLine.TestField("New Location Code", TransferLocation);
                end;
        end;

        ItemJnlLine.TestField("Item No.", SubOrderComp."Item No.");
        ItemJnlLine.TestField("Variant Code", SubOrderComp."Variant Code");

        if TransferQty = 0 then
            exit;

        if ReservEngineMgt.InitRecordSet(OldReservEntry) then
            repeat
                OldReservEntry.TestField("Item No.", SubOrderComp."Item No.");
                OldReservEntry.TestField("Variant Code", SubOrderComp."Variant Code");
                OldReservEntry.TestField("Location Code", TransferLocation);
                OldReservEntry."New Serial No." := OldReservEntry."Serial No.";
                OldReservEntry."New Lot No." := OldReservEntry."Lot No.";

                TransferQty := CreateReservEntry.TransferReservEntry(Database::"Item Journal Line",
                    ItemJournalLineEntryTypeEnum2EntryTypeOption(ItemJnlLine."Entry Type"), ItemJnlLine."Journal Template Name",
                    ItemJnlLine."Journal Batch Name", 0, ItemJnlLine."Line No.",
                    ItemJnlLine."Qty. per Unit of Measure", OldReservEntry, TransferQty);

            until (ReservEngineMgt.NEXTRecord(OldReservEntry) = 0) or (TransferQty = 0);
    end;

    procedure TransferTrackingToItemJnlLineV(
        var AppliedDeliveryChallan: Record "Applied Delivery Challan";
        var ItemJnlLine: Record "Item Journal Line";
        TransferQty: Decimal;
        Direction: Option Outbound,Inbound;
        ItemLedgerEntry: Record "Item Ledger Entry";
        Type_: Option Consume,RejectVE,RejectCE,Receive,Rework)
    var
        OldReservEntry: Record "Reservation Entry";
        DeliveryChallanLine: Record "Delivery Challan Line";
        ReservEngineMgt: Codeunit "Reservation Engine Mgt.";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        TransferLocation: Code[10];
    begin
        DeliveryChallanLine.Get(AppliedDeliveryChallan."Applied Delivery Challan No.", AppliedDeliveryChallan."App. Delivery Challan Line No.");
        OldReservEntry.Reset();
        if not FindReservEntryVend(AppliedDeliveryChallan, OldReservEntry, Direction, ItemLedgerEntry, Type_) then
            exit;

        OldReservEntry.Lock();

        Case Direction of
            Direction::Outbound:
                begin
                    TransferLocation := DeliveryChallanLine."Vendor Location";
                    ItemJnlLine.TestField("Location Code", TransferLocation);
                end;
            Direction::Inbound:
                begin
                    TransferLocation := DeliveryChallanLine."Company Location";
                    ItemJnlLine.TestField("New Location Code", TransferLocation);
                end;
        end;

        ItemJnlLine.TestField("Item No.", AppliedDeliveryChallan."Item No.");
        ItemJnlLine.TestField("Variant Code", DeliveryChallanLine."Variant Code");

        if TransferQty = 0 then
            exit;

        if ReservEngineMgt.InitRecordSet(OldReservEntry) then
            repeat
                OldReservEntry.TestField("Item No.", AppliedDeliveryChallan."Item No.");
                OldReservEntry.TestField("Variant Code", DeliveryChallanLine."Variant Code");
                OldReservEntry.TestField("Location Code", TransferLocation);
                OldReservEntry."New Serial No." := OldReservEntry."Serial No.";
                OldReservEntry."New Lot No." := OldReservEntry."Lot No.";

                TransferQty := CreateReservEntry.TransferReservEntry(Database::"Item Journal Line",
                    ItemJournalLineEntryTypeEnum2EntryTypeOption(ItemJnlLine."Entry Type"), ItemJnlLine."Journal Template Name",
                    ItemJnlLine."Journal Batch Name", 0, ItemJnlLine."Line No.",
                    ItemJnlLine."Qty. per Unit of Measure", OldReservEntry, TransferQty);

            until (ReservEngineMgt.NEXTRecord(OldReservEntry) = 0) or (TransferQty = 0);
    end;

    procedure FindReservEntryVend(
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        var ReservEntry: Record "Reservation Entry";
        Direction: Option Outbound,Inbound;
        ItemLedgerEntry: Record "Item Ledger Entry";
        Type_: Option Consume,RejectVE,RejectCE,Receive,Rework): Boolean
    var
        Item: Record Item;
        ReservEngineMgt: Codeunit "Reservation Engine Mgt.";
    begin
        Item.Get(AppliedDeliveryChallan."Item No.");
        if Item."Item Tracking Code" = '' then
            exit(true);

        ReservEngineMgt.InitFilterAndSortingLookupFor(ReservEntry, false);
        FilterReservForVend(ReservEntry, AppliedDeliveryChallan, Direction, ItemLedgerEntry, Type_);

        if ItemLedgerEntry."Serial No." <> '' then
            ReservEntry.SetRange("Serial No.", ItemLedgerEntry."Serial No.");

        if ItemLedgerEntry."Lot No." <> '' then
            ReservEntry.SetRange("Lot No.", ItemLedgerEntry."Lot No.");

        exit(ReservEntry.Findlast());
    end;

    procedure FilterReservForVend(
        var FilterReservEntry: Record "Reservation Entry";
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        Direction: Option Outbound,Inbound;
        ItemLedgerEntry: Record "Item Ledger Entry";
        Type_: Option Consume,RejectVE,RejectCE,Receive,Rework)
    var
        DeliveryChallanLine: Record "Delivery Challan Line";
        AppDelChEntry: Record "Applied Delivery Challan Entry";
    begin
        DeliveryChallanLine.Get(AppliedDeliveryChallan."Applied Delivery Challan No.",
          AppliedDeliveryChallan."App. Delivery Challan Line No.");

        FilterReservEntry.SetRange("Source Type", Database::"Applied Delivery Challan Entry");
        FilterReservEntry.SetRange("Source Subtype", Direction);
        FilterReservEntry.SetRange("Source ID", '');
        FilterReservEntry.SetRange("Source Batch Name", '');
        FilterReservEntry.SetRange("Source Prod. Order Line", 0);
        FilterReservEntry.SetRange("Item No.", AppliedDeliveryChallan."Item No.");
        FilterReservEntry.SetRange("Location Code", DeliveryChallanLine."Vendor Location");
        FilterReservEntry.SetRange("Variant Code", DeliveryChallanLine."Variant Code");

        AppDelChEntry.Reset();
        AppDelChEntry.SetRange("Document No.", AppliedDeliveryChallan."Document No.");
        AppDelChEntry.SetRange("Document Line No.", AppliedDeliveryChallan."Document Line No.");
        AppDelChEntry.SetRange("Applied Delivery Challan No.", AppliedDeliveryChallan."Applied Delivery Challan No.");
        AppDelChEntry.SetRange("App. Delivery Challan Line No.", AppliedDeliveryChallan."App. Delivery Challan Line No.");
        AppDelChEntry.SetRange("Parent Item No.", AppliedDeliveryChallan."Parent Item No.");
        AppDelChEntry.SetRange("Line No.", AppliedDeliveryChallan."Line No.");
        AppDelChEntry.SetRange("Item No.", AppliedDeliveryChallan."Item No.");
        AppDelChEntry.SetRange("Type of Quantity", Type_);
        if AppDelChEntry.FindFirst() then
            FilterReservEntry.SetRange("Source Ref. No.", AppDelChEntry."Entry No.");
    end;

    procedure FindReservEntryVendBef(
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        var ReservEntry: Record "Reservation Entry";
        Direction: Option Outbound,Inbound;
        ItemLedgerEntry: Record "Item Ledger Entry";
        Type_: Option Consume,RejectVE,RejectCE,Receive,Rework): Boolean
    var
        Item: Record Item;
    begin
        Item.Get(AppliedDeliveryChallan."Item No.");
        if Item."Item Tracking Code" = '' then
            exit(true);

        FilterReservForVend(ReservEntry, AppliedDeliveryChallan, Direction, ItemLedgerEntry, Type_);
        if ItemLedgerEntry."Serial No." <> '' then
            ReservEntry.SetRange("Serial No.", ItemLedgerEntry."Serial No.");

        if ItemLedgerEntry."Lot No." <> '' then
            ReservEntry.SetRange("Lot No.", ItemLedgerEntry."Lot No.");

        exit(ReservEntry.Findlast());
    end;

    procedure CheckItemTracking(
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        Type_: Option Consume,RejectVE,RejectCE,Receive,Rework)
    var
        AppDelChEntry: Record "Applied Delivery Challan Entry";
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ReservEntry: Record "Reservation Entry";
        DeliveryChallanLine: Record "Delivery Challan Line";
        ItemTrackingSetup: Record "Item Tracking Setup";
        ItemTrackingManagement: Codeunit "Item Tracking Management";

        Inbound: Boolean;
        SNRequired: Boolean;
        LotRequired: Boolean;
        SNInfoRequired: Boolean;
        LotInfoRequired: Boolean;
        QuantityTracked: Decimal;
    begin
        Item.Get(AppliedDeliveryChallan."Item No.");
        if Item."Item Tracking Code" = '' then
            exit;

        DeliveryChallanLine.Get(AppliedDeliveryChallan."Applied Delivery Challan No.", AppliedDeliveryChallan."App. Delivery Challan Line No.");
        QuantityTracked := 0;
        Inbound := true;
        ItemTrackingCode.Code := Item."Item Tracking Code";
        ItemTrackingManagement.GetItemTrackingSetup(
            ItemTrackingCode,
            ItemJnlLine."Entry Type",
                Inbound,
                ItemTrackingSetup);
        SNRequired := ItemTrackingSetup."Serial No. Required";
        LotRequired := ItemTrackingSetup."Lot No. Required";
        SNInfoRequired := ItemTrackingSetup."Serial No. Info Required";
        LotInfoRequired := ItemTrackingSetup."Lot No. Info Required";

        ReservEntry.Reset();
        ReservEntry.SetCurrentKey(
            "Source ID",
            "Source Ref. No.",
            "Source Type",
            "Source Subtype",
            "Source Batch Name",
            "Source Prod. Order Line",
            "Location Code",
            "Item No.",
            "Variant Code");
        ReservEntry.SetRange("Source Type", Database::"Applied Delivery Challan Entry");
        ReservEntry.SetRange("Source Subtype", 0);
        ReservEntry.SetRange("Source ID", '');
        ReservEntry.SetRange("Source Batch Name", '');
        ReservEntry.SetRange("Source Prod. Order Line", 0);
        ReservEntry.SetRange("Item No.", AppliedDeliveryChallan."Item No.");
        ReservEntry.SetRange("Location Code", DeliveryChallanLine."Vendor Location");
        ReservEntry.SetRange("Variant Code", DeliveryChallanLine."Variant Code");

        AppDelChEntry.Reset();
        AppDelChEntry.SetCurrentKey(
            "Document No.",
            "Document Line No.",
            "Applied Delivery Challan No.",
            "App. Delivery Challan Line No.",
            "Parent Item No.",
            "Line No.",
            "Item No.",
            "Type of Quantity");
        AppDelChEntry.SetRange("Document No.", AppliedDeliveryChallan."Document No.");
        AppDelChEntry.SetRange("Document Line No.", AppliedDeliveryChallan."Document Line No.");
        AppDelChEntry.SetRange("Applied Delivery Challan No.", AppliedDeliveryChallan."Applied Delivery Challan No.");
        AppDelChEntry.SetRange("App. Delivery Challan Line No.", AppliedDeliveryChallan."App. Delivery Challan Line No.");
        AppDelChEntry.SetRange("Parent Item No.", AppliedDeliveryChallan."Parent Item No.");
        AppDelChEntry.SetRange("Line No.", AppliedDeliveryChallan."Line No.");
        AppDelChEntry.SetRange("Item No.", AppliedDeliveryChallan."Item No.");
        AppDelChEntry.SetRange("Type of Quantity", Type_);
        if AppDelChEntry.FindSet() then
            repeat
                ReservEntry.SetRange("Source Ref. No.", AppDelChEntry."Entry No.");
                ReservEntry.CalcSums("Qty. to Invoice (Base)");
                QuantityTracked += ReservEntry."Qty. to Invoice (Base)";
            until AppDelChEntry.Next() = 0;

        QuantityTracked := Abs(QuantityTracked);

        TempTrackingSpecification.Init();
        TempTrackingSpecification."Entry No." := 1;
        TempTrackingSpecification."Item No." := AppliedDeliveryChallan."Item No.";
        if ReservEntry.FindFirst() then begin
            TempTrackingSpecification."Serial No." := ReservEntry."Serial No.";
            TempTrackingSpecification."Lot No." := ReservEntry."Lot No.";
        end;
        Case Type_ of
            Type_::Consume:
                begin
                    if (QuantityTracked = 0) and (QuantityTracked <> AppliedDeliveryChallan."Qty. to Consume") and SNRequired then
                        Error(SerialNoErr, AppliedDeliveryChallan."Item No.");

                    if (QuantityTracked = 0) and (QuantityTracked <> AppliedDeliveryChallan."Qty. to Consume") and LotRequired then
                        Error(LotNoErr, AppliedDeliveryChallan."Item No.");

                    TempTrackingSpecification.TestFieldError(
                        Copystr(AppliedDeliveryChallan.FieldCaption("Qty. to Consume"), 1, 80),
                        QuantityTracked,
                        AppliedDeliveryChallan."Qty. to Consume");
                end;
            Type_::RejectVE:
                begin
                    if (QuantityTracked = 0) and (QuantityTracked <> AppliedDeliveryChallan."Qty. To Return (V.E.)") and SNRequired then
                        Error(SerialNoErr, AppliedDeliveryChallan."Item No.");

                    if (QuantityTracked = 0) and (QuantityTracked <> AppliedDeliveryChallan."Qty. To Return (V.E.)") and lotRequired then
                        Error(LotNoErr, AppliedDeliveryChallan."Item No.");

                    TempTrackingSpecification.TestFieldError(
                        CopyStr(AppliedDeliveryChallan.FieldCaption("Qty. To Return (V.E.)"), 1, 80),
                        QuantityTracked,
                        AppliedDeliveryChallan."Qty. To Return (V.E.)");
                end;
            Type_::RejectCE:
                begin
                    if (QuantityTracked = 0) and (QuantityTracked <> AppliedDeliveryChallan."Qty. to Return (C.E.)") and (SNRequired) then
                        Error(SerialNoErr, AppliedDeliveryChallan."Item No.");

                    if (QuantityTracked = 0) and (QuantityTracked <> AppliedDeliveryChallan."Qty. to Return (C.E.)") and (LotRequired) then
                        Error(LotNoErr, AppliedDeliveryChallan."Item No.");

                    TempTrackingSpecification.TestFieldError(
                        CopyStr(AppliedDeliveryChallan.FieldCaption("Qty. to Return (C.E.)"), 1, 80),
                        QuantityTracked,
                        AppliedDeliveryChallan."Qty. to Return (C.E.)");
                end;
            Type_::Receive:
                begin
                    if (QuantityTracked = 0) and (QuantityTracked <> AppliedDeliveryChallan."Qty. to Receive") and (SNRequired) then
                        Error(SerialNoErr, AppliedDeliveryChallan."Item No.");

                    if (QuantityTracked = 0) and (QuantityTracked <> AppliedDeliveryChallan."Qty. to Receive") and (LotRequired) then
                        Error(LotNoErr, AppliedDeliveryChallan."Item No.");

                    TempTrackingSpecification.TestFieldError(
                        CopyStr(AppliedDeliveryChallan.FieldCaption("Qty. to Receive"), 1, 80),
                        QuantityTracked,
                        AppliedDeliveryChallan."Qty. to Receive");
                end;
        end;
    end;

    procedure GetReceiptNo(ReceivingNo: Code[20])
    begin
        ReceiptNo := ReceivingNo;
    end;

    procedure PostAppliedDeliveryChallan(ProdOrderComponent: Record "Prod. Order Component")
    var
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        SubOrderCompListVend2: Record "Sub Order Comp. List Vend";
        PostedAppliedDeliveryChallan: Record "Posted Applied DeliveryChallan";
    begin
        SubOrderCompListVend2.Reset();
        SubOrderCompListVend2.SetRange("Production Order No.", ProdOrderComponent."Prod. Order No.");
        SubOrderCompListVend2.SetRange("Production Order Line No.", ProdOrderComponent."Prod. Order Line No.");
        SubOrderCompListVend2.SetRange("Line No.", ProdOrderComponent."Line No.");
        if SubOrderCompListVend2.FindSet() then
            repeat
                AppliedDeliveryChallan.SetRange("Document No.", SubOrderCompListVend2."Document No.");
                AppliedDeliveryChallan.SetRange("Document Line No.", SubOrderCompListVend2."Document Line No.");
                AppliedDeliveryChallan.SetRange("Parent Item No.", SubOrderCompListVend2."Parent Item No.");
                AppliedDeliveryChallan.SetRange("Line No.", SubOrderCompListVend2."Line No.");
                AppliedDeliveryChallan.SetRange("Item No.", SubOrderCompListVend2."Item No.");
                if AppliedDeliveryChallan.FindSet() then
                    repeat
                        PostedAppliedDeliveryChallan.Init();
                        PostedAppliedDeliveryChallan.TransferFields(AppliedDeliveryChallan);
                        PostedAppliedDeliveryChallan."Posted Receipt No." := ReceiptNo;
                        PostedAppliedDeliveryChallan.Insert();
                    until AppliedDeliveryChallan.Next() = 0;
            until SubOrderCompListVend2.Next() = 0;
    end;

    procedure ItemJournalLineEntryTypeEnum2EntryTypeOption(ItemJournalType: Enum "Item Ledger Entry Type"): Option
    var
        EntryType: Option Purchase,Sale,"Positive Adjmt.","Negative Adjmt.",Transfer,Consumption,Output," ","Assembly Consumption","Assembly Output";
        ConversionErr: Label 'Entry Type %1 is not a valid option.', Comment = '%1 = Item Journal Entry Type';
    begin
        case ItemJournalType of
            ItemJournalType::Purchase:
                exit(EntryType::Purchase);
            ItemJournalType::Sale:
                exit(EntryType::Sale);
            ItemJournalType::"Positive Adjmt.":
                exit(EntryType::"Positive Adjmt.");
            ItemJournalType::"Negative Adjmt.":
                exit(EntryType::"Negative Adjmt.");
            ItemJournalType::Transfer:
                exit(EntryType::Transfer);
            ItemJournalType::Consumption:
                exit(EntryType::Consumption);
            ItemJournalType::Output:
                exit(EntryType::Output);
            ItemJournalType::" ":
                exit(EntryType::" ");
            ItemJournalType::"Assembly Consumption":
                exit(EntryType::"Assembly Consumption");
            ItemJournalType::"Assembly Output":
                exit(EntryType::"Assembly Output");
            else
                Error(ConversionErr, ItemJournalType);
        end;
    end;

    procedure GetDimensionsFromPurchaseLine(
        var ItemJournalLine: Record "Item Journal Line";
        SubOrderCompList: Record "Sub Order Component List")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        if not PurchaseLine.Get(PurchaseLine."Document Type"::Order, SubOrderCompList."Document No.", SubOrderCompList."Document Line No.") then
            exit;

        ItemJournalLine.Validate("Dimension Set ID", PurchaseLine."Dimension Set ID");
        if ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Transfer then begin
            ItemJournalLine."New Dimension Set ID" := ItemJournalLine."Dimension Set ID";
            ItemJournalLine."New Shortcut Dimension 1 Code" := ItemJournalLine."Shortcut Dimension 1 Code";
            ItemJournalLine."New Shortcut Dimension 2 Code" := ItemJournalLine."Shortcut Dimension 2 Code";
        end
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSubcontractComponentSendPost(
        ItemJrnlLine: Record "Item Journal Line";
        DeliveryChallanHeader: Record "Delivery Challan Header";
        SubOrderCompList: Record "Sub Order Component List")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostSubcontractOrder(
        var ProdOrderComponent: Record "Prod. Order Component";
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostSubcontractOrder(
        ProdOrderComponent: Record "Prod. Order Component";
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeliveryChallanHeaderInsert(
        var DeliveryChallanHeader: Record "Delivery Challan Header";
        SubOrderComponentList: Record "Sub Order Component List";
        PurchLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeliveryChallanHeaderInsert(
        DeliveryChallaneHeader: Record "Delivery Challan Header";
        SubOrderComponentList: Record "Sub Order Component List";
        PurchLine: Record "Purchase Line";
        DeliveryChallanNo: Code[20];
        SubcontractOrderNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeliveryChallanLineInsert(
        var DeliveryChallanLine: Record "Delivery Challan Line";
        DeliveryChallanNo: Code[20];
        SubcontractOrderNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeliveryChallanLineInsert(
        DeliveryChallanLine: Record "Delivery Challan Line";
        DeliveryChallanNo: Code[20];
        SubcontractOrderNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostSubcontractComponent(
        var ItemJnlLine: Record "Item Journal Line";
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        SubOrderCompListVendor: Record "Sub Order Comp. List Vend";
        ProdOrderComponent: Record "Prod. Order Component";
        ProdOrderLine: Record "Prod. Order Line";
        ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateUnitofMeasureCodeSubcontract(
        var ItemJournalLine: Record "Item Journal Line";
        ProdOrderComponent: Record "Prod. Order Component")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostSubcontractComponent(
        ItemJnlLine: Record "Item Journal Line";
        AppliedDeliveryChallan: Record "Applied Delivery Challan";
        SubOrderCompListVendor: Record "Sub Order Comp. List Vend";
        ProdOrderComponent: Record "Prod. Order Component";
        ProdOrderLine: Record "Prod. Order Line";
        ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeProcessAssocItemJnlLine', '', false, false)]
    local procedure OnBeforeProcessAssocItemJnlLineSubcon(var PurchaseLine: Record "Purchase Line"; IsHandled: Boolean)
    var
        PurchHeader: Record "Purchase Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
    begin
        PurchHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        if (not PurchHeader.Invoice) and (PurchaseLine.Type = PurchaseLine.Type::Item) and (PurchaseLine.Subcontracting) then begin
            if PurchRcptHeader.Get(PurchaseLine."Receipt No.") then
                if PurchRcptHeader.Subcontracting then
                    exit;

            GetReceiptNo(PurchHeader."Receiving No.");
            PostSubcon(PurchaseLine);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeAllowProdApplication', '', false, false)]
    local procedure OnBeforeAllowProdApplicationSubcon(
        OldItemLedgerEntry: Record "Item Ledger Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        var AllowApplication: Boolean)
    begin
        if (OldItemLedgerEntry."Subcon Order No." <> '') and
            (ItemLedgerEntry."Subcon Order No." <> '') and
            (OldItemLedgerEntry."Subcon Order No." = ItemLedgerEntry."Subcon Order No.") and
            (not AllowApplication)
        then
            AllowApplication := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostItemJnlLineCopyProdOrder', '', false, false)]
    local procedure OnAfterPostItemJnlLineCopyProdOrder(var ItemJnlLine: Record "Item Journal Line"; PurchLine: Record "Purchase Line")
    begin
        if ItemJnlLine."Entry Type" <> ItemJnlLine."Entry Type"::Output then
            exit;

        if (PurchLine."Prod. Order No." <> '') and (PurchLine."Subcon. Receiving") then
            ItemJnlLine."Posting Date" := PurchLine."Posting Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidateQtyToInvoice', '', false, false)]
    local procedure OnBeforeValidateQtyToInvoice(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
        if not PurchaseLine.Subcontracting then
            exit;

        IsHandled := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterModifyApplyDeliveryChallan(var AppliedDeliveryChallan: Record "Applied Delivery Challan"; SubOrderCompVend: Record "Sub Order Comp. List Vend")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyApplyDeliveryChallan(var AppliedDeliveryChallan: Record "Applied Delivery Challan"; SubOrderCompVend: Record "Sub Order Comp. List Vend")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDelApplyDeliveryChallan(var ProdOrder: Record "Production Order"; var ProdOrderLine: Record "Prod. Order Line"; var ProdOrderComp: Record "Prod. Order Component"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostSubconComp(var ProdOrder: Record "Production Order"; var ProdOrderLine: Record "Prod. Order Line"; var ProdOrderComp: Record "Prod. Order Component"; var Purchaseline: Record "Purchase line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRecieveBackComp(var ProdOrder: Record "Production Order"; var ProdOrderLine: Record "Prod. Order Line"; var ProdOrderComp: Record "Prod. Order Component"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostSubconCompCE(var ProdOrder: Record "Production Order"; var ProdOrderLine: Record "Prod. Order Line"; var ProdOrderComp: Record "Prod. Order Component"; var Purchline: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostScrapAtVE(
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        PurchaseLine: Record "Purchase Line";
        var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetApplicationLines(
        ProdOrderComp: Record "Prod. Order Component";
        SubOrderCompVend: Record "Sub Order Comp. List Vend";
        var ItemLedgerEntry: Record "Item Ledger Entry";
        TotalQtyToPost: Decimal;
        AppDelChallan: Record "Applied Delivery Challan";
        var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSubcontCompSendPost(
            var ItemJrnlLine: Record "Item Journal Line";
            DeliveryChallanHeader: Record "Delivery Challan Header";
            SubOrderCompList: Record "Sub Order Component List"; var IsHandled: Boolean)
    begin
    end;
}
